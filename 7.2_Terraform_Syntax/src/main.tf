### PROVIDER

terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = var.yc_region
}

### VARIABLES

variable "yc_token" {
}

variable "yc_cloud_id" {
  default = "b1gkcbcelbsch7d0fkqt"
}

variable "yc_folder_id" {
  default = "b1gbd4sblmul9odvp6jq"
}

variable "yc_region" {
  default = "ru-central1-a"
}

variable "debian-11" {
  default = "fd872tdm7lq9lgbu959k"
}

### CONFIG

resource "yandex_compute_instance" "vm-1" {
  name = "terraform1"
  platform_id = "standard-v3"
  zone = var.yc_region
  hostname = "test-terraform"

  resources {
    cores  = 2
    memory = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = var.debian-11
      size = 4
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  scheduling_policy {
    preemptible = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

### NETWORK

resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = var.yc_region
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

### OUTPUT

output "internal_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.ip_address
}

output "external_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.nat_ip_address
}

