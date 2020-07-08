variable "N" {
  default = 1
}
variable "htoken" {
  default = ""
}
# Configure the Hetzner Cloud Provider
provider "hcloud" {
  version = "~> 1.18"
  token = var.htoken
}

#  Main ssh key
resource "hcloud_ssh_key" "default" {
  name       = "build"
  public_key = file("~/.ssh/authorized_keys")
}
resource "hcloud_server" "hz" {
  count       = var.N
  location    = "nbg1"
  name        = "nbg${count.index+1}"
  image       = "ubuntu-20.04"
  server_type = "cpx11"
  ssh_keys    = ["${hcloud_ssh_key.default.name}"]

  user_data = <<-EOF
  #cloud-config
disable_root: 0
ssh_pwauth: 0
users:
  - name: root
    ssh-authorized-keys:
      - ${file("~/.ssh/authorized_keys")}
  - name: build
    groups: ['sudo']
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh-authorized-keys:
      - ${file("~/.ssh/authorized_keys")}
                EOF
}
resource "hcloud_network" "nbgNet" {
  name = "nbg"
  ip_range = "10.0.0.0/8"
}
resource "hcloud_network_subnet" "nbgNet" {
  network_id = hcloud_network.nbgNet.id
  type = "server"
  network_zone = "eu-central"
  ip_range = "10.0.1.0/24"
}
resource "hcloud_server_network" "nbgNet" {
  server_id = hcloud_server.hz[0].id
  network_id = hcloud_network.nbgNet.id
}

output "public_ip4" {
  value = "${hcloud_server.hz.*.ipv4_address}"
}