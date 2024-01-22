provider "aws" {
  region = "us-east-1"
}

module "prod" {
    source = "../../infra"

    nome_repositorio = "fast-food-produto-repository"
    cargoIAM = "producao"
    ambiante = "producao"
}

output "IP_alb" {
  value = module.prod.IP
}