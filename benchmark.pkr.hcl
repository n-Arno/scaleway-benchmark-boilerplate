source "scaleway" "main" {
  commercial_type      = "PLAY2-PICO"
  image                = "ubuntu_jammy"
  image_name           = "benchmark"
  server_name          = "benchmark"
  snapshot_name        = "benchmark"
  ssh_timeout          = "10m"
  ssh_username         = "root"
  zone                 = "fr-par-1"
}

build {
  sources = ["source.scaleway.main"]
  provisioner "file" {
    source = "run.sh"
    destination = "/tmp/run.sh"
  }
  provisioner "shell" {
    script = "install.sh"
  }
}

