#!/bin/bash
set -e
sleep 20

# Define here Scaleway API Keys to install in image (need Object Storage and Instance access)
SCW_ACCESS_KEY=
SCW_SECRET_KEY=
SCW_DEFAULT_ORGANIZATION_ID=
SCW_DEFAULT_PROJECT_ID=
SCW_DEFAULT_REGION=fr-par
SCW_DEFAULT_ZONE=fr-par-1

# Install needed CLI
curl -s https://raw.githubusercontent.com/scaleway/scaleway-cli/master/scripts/get.sh | sh
apt-get update && apt-get install python3-pip -y
python3 -m pip install awscli awscli-plugin-endpoint

# Configure CLI
mkdir -p /root/.aws
cat<<EOF>/root/.aws/config
[plugins]
endpoint = awscli_plugin_endpoint

[default]
region = fr-par
s3 =
    signature_version = s3v4
    addressing_style = path
    endpoint_url = https://s3.fr-par.scw.cloud
    max_concurrent_requests = 100
    max_queue_size = 1000
    multipart_threshold = 500MB
    multipart_chunksize = 500MB

s3api =
  endpoint_url = https://s3.fr-par.scw.cloud
EOF

cat<<EOF>/root/.aws/credentials
[default]
aws_access_key_id = $SCW_ACCESS_KEY
aws_secret_access_key = $SCW_SECRET_KEY
EOF

mkdir -p /root/.config/scw
cat<<EOF>/root/.config/scw/config.yaml
access_key: $SCW_ACCESS_KEY
secret_key: $SCW_SECRET_KEY
default_organization_id: $SCW_DEFAULT_ORGANIZATION_ID
default_project_id: $SCW_DEFAULT_PROJECT_ID
default_region: $SCW_DEFAULT_REGION
default_zone: $SCW_DEFAULT_ZONE
EOF

# Build service to run benchmark
mkdir -p /opt/benchmark
touch /tmp/run.sh
cp /tmp/run.sh /opt/benchmark/run.sh
chmod +x /opt/benchmark/run.sh

cat<<EOF>/opt/benchmark/bench.sh
#!/bin/bash
set -e
DATE=\$(date +"%F-%H:%M")
echo "Benchmark run on \$(hostname) at \$DATE" > /opt/benchmark/output.log
echo "================================================" >> /opt/benchmark/output.log

# Run Benchmark
/opt/benchmark/run.sh >> /opt/benchmark/output.log
aws s3 cp /opt/benchmark/output.log s3://benchmark-results/bench-\$(hostname)-\$DATE.log

# Terminate self
scw instance server terminate \$(curl -sSL http://169.254.42.42/conf | egrep '^ID=' | cut -d'=' -f2) with-ip=true with-block=true &
EOF

chmod +x /opt/benchmark/bench.sh

cat<<EOF>/etc/systemd/system/benchmark.service
[Unit]
Description=Run Benchmark
After=apache2.service

[Service]
Environment="SCW_CONFIG_PATH=/root/.config/scw/config.yaml"
ExecStart=/opt/benchmark/bench.sh
WorkingDirectory=/opt/benchmark/
RemainAfterExit=true
Type=oneshot

[Install]
WantedBy=multi-user.target
EOF

# Enable service
systemctl daemon-reload
systemctl enable benchmark.service

#Finish
apt-get clean -y
rm -rf /tmp/run.sh
echo "Done!"

