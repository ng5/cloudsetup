provider "lxd" {}

variable "N" {
  default = 4
}

resource "lxd_container" "lxd" {
  count     = var.N
  name      = "lxd${count.index+1}"  
  image     = "local:ubuntu/focal"
  ephemeral = false

  config = {
    "boot.autostart" = true
  }

  limits = {
    cpu = 2
  }
}