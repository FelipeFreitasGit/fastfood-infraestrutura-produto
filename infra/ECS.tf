module "ecs" {
  source = "terraform-aws-modules/ecs/aws"

  cluster_name = var.ambiante
  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }
}

resource "aws_ecs_task_definition" "fast-food-produto-API" {
  family                   = "fast-food-produto-API"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.cargo.arn
  container_definitions = jsonencode([
    {
      "name"   : "producao",
      "image"  : "${data.aws_caller_identity.current.account_id}.dkr.ecr.us-east-1.amazonaws.com/fast-food-produto-repository:latest",
      "cpu"    : 256,
      "memory" : 512,
      "portMappings" = [
        {
          "containerPort" : 8080,
          "hostPort"      : 8080,
          "protocol"      : "tcp"
        }
      ],
      "essential" : true,
      "environment" : [
        {
          "name"  : "database_url",
          "value" : "jdbc:postgresql://${aws_db_instance.education.endpoint}/fast_food_produto?encoding=utf8&pool=40"
        },
        {
          "name"  : "database_user",
          "value" : "postgres"
        },
        {
          "name"  : "database_password",
          "value" : "Postgres2023"
        }
      ],
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : "fast_food_app",
          "awslogs-region" : "us-east-1",
          "awslogs-stream-prefix" : "producao"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "fast-food-produto-API" {
  name            = "fast-food-produto-API"
  cluster         = module.ecs.cluster_id
  task_definition = aws_ecs_task_definition.fast-food-produto-API.arn
  desired_count   = 3

  load_balancer {
    target_group_arn = aws_lb_target_group.alvo.arn
    container_name   = "producao"
    container_port   = 8080
  }

  network_configuration {
    subnets         = module.vpc.private_subnets
    security_groups = [aws_security_group.privado.id]
  }

  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
  }
}

resource "aws_cloudwatch_log_group" "fast_food_app" {
  name = "fast_food_app"
}