variable "ENV" {
  default     = "NON-PROD"
  description = "provide envirnment like prod,non-prod,dr.you can overide this when inheriting this module"
}
variable "vpc_id" {}
variable "name" {
}