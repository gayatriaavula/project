resource "aws_db_subnet_group" "main" {
  name       = "${var.app_name}-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id
  tags = {
    Name = "${var.app_name}-db-subnet-group"
  }
}

resource "aws_db_instance" "default" {
  identifier              = "${var.app_name}-db"
  engine                  = "mysql"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  db_name                 = var.db_name
  username                = var.db_username
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.main.name
  vpc_security_group_ids  = [aws_security_group.rds.id]
  skip_final_snapshot     = true
  publicly_accessible     = false
  deletion_protection     = false
  backup_retention_period = 0
  tags = {
    Name = "${var.app_name}-db"
  }
}
