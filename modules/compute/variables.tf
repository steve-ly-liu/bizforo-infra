#-------- compute/variables.tf --------
#======================================
variable "region" {
    type = string
    default = "ca-central-1"
}

variable "subnet_ips" {
  
}

variable "security_group" {
  
}

variable "subnets" {
  
}

variable "ssh_key_public" {
  type = string
  #Replace this with the location of you public key .pub
  default = "/home/steveliu/.ssh/id_ed25519.pub"
}

variable "ssh_key_private" {
  type = string
  #Replace this with the location of your private key
  default = "/home/steveliu/.ssh/id_ed22519"
}