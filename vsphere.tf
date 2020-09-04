variable "vsphere_user" {
  type = string
  default = "" #User vCenter
}
variable "vsphere_password" {
  type = string
  default = "" #Password vCenter
}
variable "vsphere_server" {
  type = string
  default = "" #IP vCenter
}
variable "network" {
    type = string
    default = "vlan51"
}
variable "datastore" {
    type = string
    default = "datastore1 (1)"
}
variable "datacenter" {
    type = string
    default = "k8s_datacenter"
}
variable "vm_temp" {
    type = "string"
    default = "Centos7_Temp"
}
variable "cluster_name" {
    type = "string"
    default = "k8s_cluster"
}
variable "server_settings" {
    type = "map"
    default = {
        "server1" = {
            IP = "192.168.51.208",
            NETMASK = 24,
            GATEWAY = "192.168.51.1",            
            RAM = 1024,
            CPU = 2,
            DISK = 60
        },
        "server2" = {
            IP = "192.168.51.209",
            NETMASK = 24, 
            GATEWAY = "192.168.51.1",                       
            RAM = 1024,
            CPU = 2,
            DISK = 60
        },
        "server3" = {
            IP = "192.168.51.210",
            RAM = 1024,
            NETMASK = 24,
            GATEWAY = "192.168.51.1",           
            CPU = 2,
            DISK = 60
        }
    }
}

provider "vsphere" {
  user           = var.vsphere_user
  password       = var.vsphere_password
  vsphere_server = var.vsphere_server
  allow_unverified_ssl = true
}
data "vsphere_datacenter" "dc" {
    name = var.datacenter
}
data "vsphere_compute_cluster" "cluster" {
    name = var.cluster_name
    datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_datastore" "datastore" {
    name = var.datastore
    datacenter_id = data.vsphere_datacenter.dc.id 
}
data "vsphere_network" "network" {
    name = var.network
    datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_virtual_machine" "template" {
    name = var.vm_temp
    datacenter_id = data.vsphere_datacenter.dc.id 
}
resource "vsphere_virtual_machine" "vm" {
    for_each = var.server_settings
    name = each.key
    resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
    datastore_id = data.vsphere_datastore.datastore.id 
    num_cpus = each.value.CPU
    memory = each.value.RAM
    guest_id = data.vsphere_virtual_machine.template.guest_id
    network_interface {
        network_id   = data.vsphere_network.network.id
        adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
    }
    disk {
        label            = "disk0"
        size             = each.value.DISK
    }
    clone {
        template_uuid = data.vsphere_virtual_machine.template.id
        customize {
            linux_options {
                host_name = each.key
                domain    = each.key
            }
            network_interface {
                ipv4_address = each.value.IP
                ipv4_netmask = each.value.NETMASK
            }

            ipv4_gateway = each.value.GATEWAY
    }
  }
}
