#!/bin/bash
apt-get update 1>/dev/null 2>&1
apt-get install php php-zip -y 1>/dev/null 2>&1
curl -sSLO https://raw.githubusercontent.com/sergix44/php-benchmark-script/master/io.bench.php
curl -sSLO https://raw.githubusercontent.com/sergix44/php-benchmark-script/master/rand.bench.php
curl -sSLO https://raw.githubusercontent.com/SergiX44/php-benchmark-script/master/bench.php
php bench.php
