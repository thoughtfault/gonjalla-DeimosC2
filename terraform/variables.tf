variable "domain_name" {
        type            = string
        description     = "Domain to use"
}

variable "key_name" {
        type            = string
        description     = "The saved private key name"
}

variable "operator_ip" {
        type            = string
        description     = "The IPv4 address of the jumpbox/operator"
}

variable "teamserver_instance_type" {
        type            = string
        description     = "The instance type of the teamserver"
}

variable "forwarder_instance_type" {
        type            = string
        description     = "The instance type of the forwarder"
}

variable "teamserver_os" {
        type            = string
        description     = "The os of the teamserver"
}

variable "forwarder_os" {
        type            = string
        description     = "The os of the forwarder"
}
