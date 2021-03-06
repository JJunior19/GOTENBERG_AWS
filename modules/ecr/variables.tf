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

variable "docker_gotenberg" {
    default = "thecodingmachine/gotenberg"
    description = "docker image to pull from docker hub"
    type = string
}