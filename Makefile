all: packer terraform

packer:
	packer init config.pkr.hcl
	packer build benchmark.pkr.hcl

terraform:
	terraform init
	terraform apply --auto-approve

dist-clean:
	rm -rf .terraform terraform.tfstate terraform.tfstate terraform.tfstate.backup
