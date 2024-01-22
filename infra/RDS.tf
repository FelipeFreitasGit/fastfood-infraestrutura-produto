resource "random_pet" "name" {
  length = 1
}

resource "aws_db_subnet_group" "education" {
  name       = "${random_pet.name.id}-education"
  subnet_ids = module.vpc.public_subnets
}

resource "aws_security_group" "rds" {
  name   = "${random_pet.name.id}_education_rds"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_parameter_group" "education" {
  name_prefix = "${random_pet.name.id}-education"
  family      = "postgres14"

  parameter {
    name  = "log_connections"
    value = "1"
  }

}

resource "aws_db_instance" "education" {
  identifier                  = "${random_pet.name.id}education"
  instance_class              = "db.t3.micro"
  allocated_storage           = 10
  apply_immediately           = true
  engine                      = "postgres"
  engine_version              = "14"
  db_name                     = "fast_food_produto"
  username                    = "postgres"
  password                    = "Postgres2023"
  allow_major_version_upgrade = true
  db_subnet_group_name        = aws_db_subnet_group.education.name
  vpc_security_group_ids      = [aws_security_group.rds.id]
  parameter_group_name        = aws_db_parameter_group.education.name
  publicly_accessible         = true
  skip_final_snapshot         = true
  backup_retention_period     = 1
}