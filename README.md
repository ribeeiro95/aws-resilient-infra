# 🌐 Infraestrutura Resiliente Multi-Região na AWS com Terraform

## 📌 Visão Geral

Este projeto cria uma infraestrutura distribuída em duas regiões da AWS (`us-east-1` e `us-west-2`) com:

- EC2 rodando NGINX
- Load Balancers (ALB)
- DNS com failover via Route 53
- Monitoramento com CloudWatch
- Modularização com Terraform
- Execução via PowerShell no Windows

---

## 🗂️ Estrutura de Pastas

```bash
aws-resilient-infra/
├── main.tf
├── variables.tf
├── terraform.tfvars
├── outputs.tf
├── .gitignore
├── README.md
└── modules/
    ├── vpc/
    │   ├── main.tf
    │   └── outputs.tf
    ├── ec2-nginx/
    │   ├── main.tf
    │   └── outputs.tf
    ├── alb/
    │   ├── main.tf
    │   └── outputs.tf
    ├── route53/
    │   ├── main.tf
    │   └── outputs.tf
    └── monitoring/
        ├── main.tf
        └── outputs.tf
```

---

## ⚙️ Pré-requisitos

- Conta na AWS com acesso programático
- Terraform instalado
- PowerShell no Windows
- Domínio registrado no Route 53

---

## 🔐 .gitignore recomendado

```gitignore
*.tfstate
*.tfstate.backup
terraform.tfvars
.terraform/
*.pem
*.key
```

---

## 🧪 Execução no PowerShell

```powershell
# 1. Navegue até a pasta do projeto
cd "C:\Users\SeuUsuario\Desktop\aws-resilient-infra"

# 2. Inicialize o Terraform
terraform init

# 3. Visualize o plano de execução
terraform plan

# 4. Aplique a infraestrutura
terraform apply
```

---

## 📄 Preenchimento do `terraform.tfvars`

```hcl
aws_access_key    = "SEU_ACCESS_KEY"
aws_secret_key    = "SEU_SECRET_KEY"
ami_id_east       = "ami-xxxxxxxx"
ami_id_west       = "ami-yyyyyyyy"
instance_type     = "t3.micro"
route53_zone_id   = "Z1234567890ABC"
lb_zone_id        = "Z35SXDOTRQ7X7K"
```

---

## 🧠 Como funciona o failover

1. O ALB em `us-east-1` é o primário.
2. O ALB em `us-west-2` é o secundário.
3. O Route 53 monitora a saúde do ALB primário.
4. Se o ALB primário falhar, o DNS redireciona automaticamente para o secundário.

---

## 📡 Monitoramento

- CloudWatch monitora o número de hosts não saudáveis.
- Alarmes são criados por região.
- Pode ser integrado com SNS para alertas por e-mail ou SMS.

---

## 🧹 Para destruir a infraestrutura

```powershell
terraform destroy
```

---

## 📘 Referências

- [Documentação oficial do Terraform](https://developer.hashicorp.com/terraform/docs)
- [AWS Application Load Balancer](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html)
- [Route 53 Failover](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/dns-failover.html)

---