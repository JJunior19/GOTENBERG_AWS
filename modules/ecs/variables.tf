variable "app_env" {
    default = "converter"
    description = "Entorn donde se despliega la infraestructura"
    type = string
}

variable "uocenv" {
    default = "labs"
    description = "TAG propio de la UOC"
    type = string
}

variable "departament" {
    default = "uoc-it"
    description="TAG propio de la UOC"
    type = string
}

# variable "repository" {
#     type = any
# }