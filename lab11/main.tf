
variable "credentials_file" { 
  default = "../secrets/cis-91.key" 
}

variable "project" {
  default = "phonic-arcana-324121"
}

variable "region" {
  default = "us-central1"
}

variable "zone" {
  default = "us-central1-c"
}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.5.0"
    }
  }
}

provider "google" {
  credentials = file(var.credentials_file)
  region  = var.region
  zone    = var.zone 
  project = var.project
}

// Create VPC
resource "google_compute_network" "vpc_network" {
  name = "lab11-network"
  description = "Lab 11 network for three regions of the United States"
  auto_create_subnetworks = false
}

// Create three subnets
resource "google_compute_subnetwork" "subnet1" {
  name          = "us1-subnet"
  ip_cidr_range = "10.91.0.0/24"
  description = "Central region of the US"
  region        = "us-central1"
  network       = google_compute_network.vpc_network.name
}

resource "google_compute_subnetwork" "subnet2" {
  name          = "us2-subnet"
  ip_cidr_range = "10.91.1.0/29"
  description = "East region of the US"
  region        = "us-east1"
  network       = google_compute_network.vpc_network.name
}

resource "google_compute_subnetwork" "subnet3" {
  name          = "us3-subnet"
  ip_cidr_range = "10.91.2.0/25"
  description = "West region of the US"
  region        = "us-west3"
  network       = google_compute_network.vpc_network.name
}

resource "google_compute_instance" "vm_instance" {
  name         = "cis91"
  machine_type = "e2-micro"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
    }
  }
}

// VPC firewall configuration
resource "google_compute_firewall" "default-firewall" {
  name = "default-firewall"
  network = google_compute_network.vpc_network.name
  allow {
    protocol = "tcp"
    ports = ["22", "80"]
  }
  allow {
      protocol = "icmp" // allow from any source to all the network ip
  }
  allow {
      protocol = "all" // allow connectivity between instances on any port
  }
  source_ranges = ["0.0.0.0/0"]
}

output "external-ip" {
  value = google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip
}
