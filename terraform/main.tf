# -----------------------------------------------------
# 1. REDE (VPC, Subnets, Internet Gateway e Roteamento)
# -----------------------------------------------------

resource "aws_vpc" "linkonfood_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "linkonfood-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.linkonfood_vpc.id

  tags = {
    Name = "linkonfood-igw"
  }
}

resource "aws_subnet" "subnet_a" {
  vpc_id                  = aws_vpc.linkonfood_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true 

  tags = {
    Name = "linkonfood-subnet-1a"
  }
}

resource "aws_subnet" "subnet_b" {
  vpc_id                  = aws_vpc.linkonfood_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false 

  tags = {
    Name = "linkonfood-subnet-1b"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.linkonfood_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "linkonfood-public-rt"
  }
}

resource "aws_route_table_association" "assoc_a" {
  subnet_id      = aws_subnet.subnet_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "assoc_b" {
  subnet_id      = aws_subnet.subnet_b.id
  route_table_id = aws_route_table.public_rt.id
}

# ------------------------------
# 2. SECURITY GROUPS & CHAVE SSH
# ------------------------------

# Grupo de Segurança para o Servidor dos Microsserviços (EC2) - Trancado no seu IP
resource "aws_security_group" "ec2_sg" {
  name        = "linkonfood-ec2-sg"
  description = "Permite trafego apenas para o IP do Desenvolvedor"
  vpc_id      = aws_vpc.linkonfood_vpc.id

  # SSH (Acesso ao terminal da VM)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.meu_ip_publico]
  } 

  # API Gateway
  ingress {
    from_port   = 8082
    to_port     = 8082
    protocol    = "tcp"
    cidr_blocks = [var.meu_ip_publico]
  }

  # Painel do Netflix Eureka Server
  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = [var.meu_ip_publico]
  }

  # Painel do Kibana
  ingress {
    from_port   = 5601
    to_port     = 5601
    protocol    = "tcp"
    cidr_blocks = [var.meu_ip_publico]
  }

  # Saída livre para a internet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "linkonfood-ec2-sg"
  }
}

# Grupo de Segurança para o Banco de Dados (RDS) - Isolado da Internet
resource "aws_security_group" "rds_sg" {
  name        = "linkonfood-rds-sg"
  description = "Permite conexao ao MySQL apenas vinda da EC2 do LinkonFood"
  vpc_id      = aws_vpc.linkonfood_vpc.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "linkonfood-rds-sg"
  }
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "linkonfood_key"
  public_key = var.ssh_public_key
}

#----------------------------------------------------------
# 3. MÁQUINAS E COMPONENTES (EC2 Rocky Linux 9 & RDS MySQL)
#----------------------------------------------------------

data "aws_ami" "rocky9" {
  most_recent = true
  owners      = ["679593333241"] 
  filter {
    name   = "name"
    values = ["Rocky-9-EC2-Base-*.x86_64"]
  }
}

resource "aws_instance" "app_server" {
  ami                    = data.aws_ami.rocky9.id
  instance_type          = "t3.medium" 
  subnet_id              = aws_subnet.subnet_a.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name               = aws_key_pair.ssh_key.key_name

  # Script de inicialização automática e instalação do Docker Engine e Compose
  user_data = <<-EOF
              #!/bin/bash
              sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
              sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
              sudo systemctl enable --now docker
              sudo usermod -aG docker rocky
              EOF

  tags = {
    Name = "linkonfood-app-server"
  }
}

# Grupo com duas subnets em AZs diferentes para criar o RDS
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "linkonfood-db-subnet-group"
  subnet_ids = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]

  tags = {
    Name = "linkonfood-db-subnet-group"
  }
}

resource "aws_db_instance" "mysql_db" {
  allocated_storage      = 20
  max_allocated_storage  = 50
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro" 
  db_name                = "linkonfood_db"
  username               = "root"
  password               = var.database_password 
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true

  tags = {
    Name = "linkonfood-mysql-database"
  }
}
