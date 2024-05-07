# main.tf
# Define the provider
provider "google" {
    credentials = file("/Users/joshua/Desktop/GCPcutoff/jae-fleming-adfc3e3b9a68.json")
    project     = "jae-fleming"
    region      = "us-central1"
}

# Create a VPC
resource "google_compute_network" "vpc" {
    name                    = "jaeger-vpc"
    auto_create_subnetworks = false
}

# Create a subnet within the VPC
resource "google_compute_subnetwork" "subnet" {
    name          = "public-subnet"
    ip_cidr_range = "10.192.0.0/24"
    network       = google_compute_network.vpc.self_link
}

# Create a firewall rule to allow incoming HTTP traffic
resource "google_compute_firewall" "http" {
    name    = "allow-http"
    network = google_compute_network.vpc.self_link

    allow {
        protocol = "tcp"
        ports    = ["80"]
    }

    source_ranges = ["0.0.0.0/0"]
}

# Create a VM within the subnet
resource "google_compute_instance" "vm" {
    name         = "jaeger-vm"
    machine_type = "e2-medium"
    zone         = "us-central1-a"
    boot_disk {
        initialize_params {
            image = "debian-cloud/debian-10"
        }
    }
    network_interface {
        network    = google_compute_network.vpc.self_link
        subnetwork = google_compute_subnetwork.subnet.self_link
    }
    metadata_startup_script = <<EOF
        #!/bin/bash
        echo "Hello, World!" > /var/www/html/index.html
        service apache2 restart
    EOF
}

# Output the public IP, VPC, subnet, and internal IP of the VM

output "public_ip" {
    value = google_compute_instance.vm.network_interface[0].network_ip
}
output "vpc" {
    value = google_compute_network.vpc.self_link
}

output "subnet" {
    value = google_compute_subnetwork.subnet.self_link
}

output "internal_ip" {
    value = google_compute_instance.vm.network_interface[0].network_ip
}
