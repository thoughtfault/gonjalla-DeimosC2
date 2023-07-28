terraform {
  required_version = ">= 0.13"

  required_providers {
    njalla = {
      source  = "Sighery/njalla"                                                                                                                                                                                                            version = "~> 0.10.0"
    }
  }
}

resource "tls_private_key" "this" {
        algorithm       = "RSA"
        rsa_bits        = 4096
}

resource "local_file" "this" {
        filename                = "${var.key_name}.pem"
        content                 = tls_private_key.this.private_key_pem
        file_permission = "0600"
}

resource "njalla_server" "teamserver" {
        name            = "teamserver"
        instance_type   = var.teamserver_instance_type
        os              = var.teamserver_os
        public_key      = tls_private_key.this.public_key_openssh
        months          = 1

        depends_on      = [local_file.this]

        provisioner "remote-exec" {
                connection {
                        host            = self.public_ip
                        user            = "root"
                        private_key     = file("./${var.key_name}.pem")
                }
                inline  = ["echo connected"]
        }

        provisioner "local-exec" {
                command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook --inventory '${self.public_ip},' --private-key=${var.key_name}.pem --extra-vars \"operator_ip='${var.operator_ip}'\" install-teamserver.yml"
        }
}

resource "njalla_server" "forwarder" {
        name            = "forwarder"
        instance_type   = var.forwarder_instance_type
        os              = var.forwarder_os
        public_key      = tls_private_key.this.public_key_openssh
        months          = 1

        depends_on      = [local_file.this]

        provisioner "remote-exec" {
                connection {
                        host            = self.public_ip
                        user            = "root"
                        private_key     = file("./${var.key_name}.pem")
                }
                inline  = ["echo connected"]
        }

        provisioner "local-exec" {
                command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook --inventory '${self.public_ip},' --private-key=${var.key_name}.pem --extra-vars \"teamserver_ip='${njalla_server.teamserver.public_ip}'\" install-forwarder.yml"
        }
}

resource "njalla_domain" "this" {
		name    = "${var.domain_name}"
		years   = 1
}

resource "njalla_record_a" "this" {
        domain  = "${var.domain_name}"
        ttl     = 10800
        content = njalla_server.forwarder.public_ip
}
