variable "domain_name" {
  type = string
  description = "Domain Name"
}

variable "alternative_names" {
  type = list(string)
  description = "Alternative Domain Names"
}