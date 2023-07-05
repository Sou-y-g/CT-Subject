######################################################################################
# KMS
######################################################################################
#db encrypt key
resource "aws_kms_key" "db_encrypt_key" {
  description = "db_encrypt_key"
  enable_key_rotation = true
  is_enabled = true
  deletion_window_in_days = 30
}

#key判別のためailas設定
resource "aws_kms_alias" "db_encrypt_key" {
  name = "alias/db_encrypt_key"
  target_key_id = aws_kms_key.db_encrypt_key.key_id
}

######################################################################################
# Parameter Store
######################################################################################
resource "aws_ssm_parameter" "db_user" {
  description = "user for database connection"
  name = "/db/user"
  value = "root"
  type = "String"
}

resource "aws_ssm_parameter" "db_pw" {
  description = "password for database connection"
  name = "/db/password"
  value = "uninitialized"
  type = "SecureString"

  lifecycle {
    ignore_changes = [value]
  }
}

#以下のaws cliコマンドにて上書き
#aws ssm put-parameter --name '/db/password' --type SecureString --value '<new_string>' --overwrite

######################################################################################
# RDS
######################################################################################
#dbのパラメータ
resource "aws_db_parameter_group" "cnf" {
  name = "cnf"
  family = "mysql8.0"

  parameter {
    name = "character_set_database"
    value = "utf8mb4"
  }

  parameter {
    name = "character_set_server"
    value = "utf8mb4"
  }
}

#dbのサブネットグループ(subnet_idは異なるAZに最低2つ必要)
resource "aws_db_subnet_group" "db_subnet" {
  name = "db_subnet"
  subnet_ids = [var.private2_id, var.private3_id]
}

#dbインスタンス作成
resource "aws_db_instance" "db" {
  identifier = "ct-6-1db"
  engine = "mysql"
  engine_version = "8.0.32"
  instance_class = "db.t3.micro"
  allocated_storage = 20
  max_allocated_storage = 100
  storage_type = "gp2"
  #kmsを使ってデータの暗号化
  storage_encrypted = true
  kms_key_id = aws_kms_key.db_encrypt_key.arn
  #parameterstoreから値を取得
  username = aws_ssm_parameter.db_user.value
  password = aws_ssm_parameter.db_pw.value
  multi_az = false
  #VPC外からのアクセス
  publicly_accessible = false
  port = 3306
  #db作成時にスナップショットを作成しない
  skip_final_snapshot = true
  #セキュリティグループ
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  #上で設定したdbのパラメータを反映
  parameter_group_name = aws_db_parameter_group.cnf.name
  #dbを配置するサブネット
  db_subnet_group_name = aws_db_subnet_group.db_subnet.name
}

#################################################################
# RDSのセキュリティグループ
#################################################################
resource "aws_security_group" "db_sg" {
  name = "db_security_group"
  vpc_id = var.vpc_id
  tags = {
    Name = "${var.tag}-db-sg"
  }
}

resource "aws_security_group_rule" "dbsg_in" {
    type        = "ingress"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.private1_cidr]

    security_group_id = aws_security_group.db_sg.id
}

resource "aws_security_group_rule" "dbsg_out" {
    type        = "egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.all_cidr]

    security_group_id = aws_security_group.db_sg.id
}