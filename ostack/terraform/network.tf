resource "openstack_networking_floatingip_v2" "floatingip" {
  count = "${var.ip_address ? 0 : 1}"
  pool  = "${var.floating_ip_pool}"
}

resource "openstack_networking_floatingip_v2" "ip_address" {
  count   = "${var.ip_address ? 1 : 0}"
  address = "${var.ip_address}"
}
