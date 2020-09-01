provider "vsphere" {
  user           = "administrator@vsphere.local" #var.vsphere_user
  password       = "Vega123312##" #var.vsphere_password
  vsphere_server = "172.18.0.92" #var.vsphere_server
  allow_unverified_ssl = true
}
# resource "vsphere_folder" "k8s_folder" {
#   path = "k8s_Datacenter"
#   type = "datacenter"
# }
# resource "vsphere_datacenter" "k8s_datacenter" {
#   name = "k8s_datacenter"
#   folder = "/k8s_Datacenter/"
# }
# data "vsphere_datacenter" "k8s_datacenter" {
#   name = "k8s_datacenter"
# }
# resource "vsphere_host" "h1" {
#   hostname = "172.18.0.91"
#   username = "root"
#   password = "Vega123312##"
#   license = "JU2M0-DD15J-48D89-YHAQK-0LUQ0"
#   datacenter = data.vsphere_datacenter.k8s_datacenter.id
# }
data "vsphere_datacenter" "k8s_datacenter" {
    name = "k8s_datacenter"
}
data "vsphere_datastore" "datastore" {
    name = "datastore1"
    datacenter_id = "${data.vsphere_datacenter.k8s_datacenter.id}"
}
data "vsphere_compute_cluster" "cluster" {
  name = "k8s_resource_pool"
  datacenter_id = "${data.vsphere_datacenter.k8s_datacenter.id}"
}
data "vsphere_network" "network" {
  name = "VLAN181"
  datacenter_id = ${data.vsphere_datacenter.k8s_datacenter.id}
}
resource "vsphere_virtual_machine" "vm1" {
  name = "terraform-test"
  datastore = "${data.vsphere_datastore.datastore.id}"
  resource_pool_id = "${data.vsphere_compute_cluster.cluster.id}"
  num_cpus = 2
  memory = 1024
  guest_id = "k8s"
  network_interface {
    network_id = "${data.vsphere_network.network.id}"
  }
  disk {
    label = "disk0"
    size = 40
  }

}