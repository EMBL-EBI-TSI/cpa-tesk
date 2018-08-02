output "external_ip" {
  value = "${openstack_networking_floatingip_v2.floatingip.address}"
}

output "k8s_master_private_ip" {
  value = "${openstack_compute_instance_v2.k8s-master.*.access_ip_v4[0]}"
}
