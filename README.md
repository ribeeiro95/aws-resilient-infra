# 🌍 Multi-Region Resilient Infrastructure with Automatic Failover

[![Terraform](https://img.shields.io/badge/Terraform-1.0+-623CE4?logo=terraform&logoColor=white)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-Multi--Region-FF9900?logo=amazon-aws&logoColor=white)](https://aws.amazon.com/)
[![CI/CD](https://img.shields.io/badge/CI%2FCD-GitHub_Actions-2088FF?logo=github-actions&logoColor=white)](https://github.com/ribeeiro95/aws-resilient-infra/actions)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

> **Infraestrutura distribuída em múltiplas regiões AWS com failover automático via Route 53, demonstrando alta disponibilidade e disaster recovery.**

## 📋 Índice

- [Visão Geral](#-visão-geral)
- [Arquitetura](#-arquitetura)
- [Tecnologias Utilizadas](#-tecnologias-utilizadas)
- [Estrutura do Projeto](#-estrutura-do-projeto)
- [Pré-requisitos](#-pré-requisitos)
- [Instalação e Deploy](#-instalação-e-deploy)
- [Como Funciona o Failover](#-como-funciona-o-failover)
- [Custos Estimados](#-custos-estimados)
- [Monitoramento e Alertas](#-monitoramento-e-alertas)
- [Testes de Resiliência](#-testes-de-resiliência)
- [Troubleshooting](#-troubleshooting)
- [Melhorias Futuras](#-melhorias-futuras)
- [Aprendizados](#-aprendizados)

---

## 🎯 Visão Geral

Este projeto implementa uma **arquitetura multi-região** na AWS com failover automático, garantindo alta disponibilidade e disaster recovery. A aplicação está distribuída entre **us-east-1** (Virginia) e **us-west-2** (Oregon), com DNS inteligente via Route 53.

### 🌟 Destaques do Projeto

- ✅ **Multi-Region Deployment** - Infraestrutura em 2 regiões AWS
- ✅ **Automatic Failover** - Route 53 Health Checks com DNS failover
- ✅ **High Availability** - Load Balancers em cada região
- ✅ **Infrastructure as Code** - 100% Terraform com módulos reutilizáveis
- ✅ **CI/CD Pipeline** - GitHub Actions para validação automática
- ✅ **CloudWatch Monitoring** - Métricas e alarmes configurados
- ✅ **Production-Ready** - Arquitetura usada em ambientes reais

### 🎓 Objetivo Educacional

Demonstrar competências avançadas em:
- Arquitetura multi-região AWS
- High Availability e Disaster Recovery
- DNS failover com Route 53
- Terraform avançado com módulos
- CI/CD com GitHub Actions
- Observabilidade com CloudWatch

---

## 🏗️ Arquitetura

### 📊 Diagrama Geral

```
                          ┌──────────────────────┐
                          │     INTERNET         │
                          │    (End Users)       │
                          └──────────┬───────────┘
                                     │
                          ┌──────────▼───────────┐
                          │    Route 53 DNS      │
                          │  (Health Checks)     │
                          │  myapp.example.com   │
                          └──────────┬───────────┘
                                     │
                    ┌────────────────┴────────────────┐
                    │ PRIMARY                 SECONDARY│
                    │ (Active)              (Standby) │
         ┌──────────▼──────────┐           ┌─────────▼────────┐
         │   us-east-1         │           │   us-west-2      │
         │   (Virginia)        │           │   (Oregon)       │
         │                     │           │                  │
         │  ┌───────────────┐  │           │  ┌──────────────┐│
         │  │      ALB      │  │           │  │     ALB      ││
         │  │ (Primary LB)  │  │           │  │(Standby LB)  ││
         │  └───────┬───────┘  │           │  └──────┬───────┘│
         │          │           │           │         │        │
         │    ┌─────┴─────┐    │           │   ┌─────┴─────┐  │
         │    │           │    │           │   │           │  │
         │ ┌──▼──┐     ┌──▼──┐ │           │┌──▼──┐     ┌──▼─┐│
         │ │ EC2 │     │ EC2 │ │           ││ EC2 │     │EC2 ││
         │ │NGINX│     │NGINX│ │           ││NGINX│     │NGINX││
         │ └─────┘     └─────┘ │           │└─────┘     └────┘│
         │                     │           │                  │
         │  Multi-AZ VPC       │           │  Multi-AZ VPC    │
         └─────────────────────┘           └──────────────────┘
                    │                                 │
         ┌──────────▼──────────┐           ┌─────────▼────────┐
         │   CloudWatch        │           │   CloudWatch     │
         │   Monitoring        │           │   Monitoring     │
         └─────────────────────┘           └──────────────────┘

Health Check Status:
✅ Primary Healthy   → Traffic goes to us-east-1
❌ Primary Unhealthy → Traffic AUTOMATICALLY fails over to us-west-2
```

### 🔄 Fluxo de Failover

```
Cenário Normal:
User Request → Route 53 → Primary ALB (us-east-1) → EC2 Instances

Cenário de Failover (Primary Down):
User Request → Route 53 (detects unhealthy) → Secondary ALB (us-west-2) → EC2 Instances

Recovery (Primary Back):
Route 53 automatically switches back to Primary after it becomes healthy
```

### 📐 Arquitetura Detalhada por Região

#### Region: us-east-1 (Primary)
```
VPC: 10.0.0.0/16
├── Public Subnet 1a: 10.0.1.0/24
│   └── EC2 + NGINX (Primary Instance 1)
├── Public Subnet 1b: 10.0.2.0/24
│   └── EC2 + NGINX (Primary Instance 2)
├── Internet Gateway
├── Application Load Balancer
│   ├── Target Group: techstore-primary-tg
│   └── Health Check: HTTP:80/health
└── Security Groups
    ├── ALB-SG (Allow 80/443 from Internet)
    └── EC2-SG (Allow 80 from ALB only)
```

#### Region: us-west-2 (Secondary)
```
VPC: 10.1.0.0/16
├── Public Subnet 2a: 10.1.1.0/24
│   └── EC2 + NGINX (Secondary Instance 1)
├── Public Subnet 2b: 10.1.2.0/24
│   └── EC2 + NGINX (Secondary Instance 2)
├── Internet Gateway
├── Application Load Balancer
│   ├── Target Group: techstore-secondary-tg
│   └── Health Check: HTTP:80/health
└── Security Groups
    ├── ALB-SG (Allow 80/443 from Internet)
    └── EC2-SG (Allow 80 from ALB only)
```

---

## 🛠️ Tecnologias Utilizadas

### Infrastructure & Automation
- **Terraform** `~> 6.0` - Infrastructure as Code
- **GitHub Actions** - CI/CD pipeline
- **Bash/PowerShell** - Automation scripts

### AWS Services
- **Route 53** - DNS com health checks e failover
- **EC2** - Compute instances (t3.micro)
- **VPC** - Virtual Private Cloud (2 regiões)
- **Application Load Balancer** - Layer 7 load balancing
- **CloudWatch** - Monitoring e alarmes
- **IAM** - Identity and Access Management

### Web Server
- **NGINX** - High-performance web server

---

## 📁 Estrutura do Projeto

```
aws-resilient-infra/
│
├── .github/
│   └── workflows/
│       └── terraform.yml         # CI/CD pipeline
│
├── modules/                      # Módulos Terraform reutilizáveis
│   ├── vpc/                      # VPC, Subnets, IGW
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   │
│   ├── ec2-nginx/                # Instâncias EC2 com NGINX
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   │
│   ├── alb/                      # Application Load Balancer
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   │
│   ├── route53/                  # DNS e Failover
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   │
│   └── monitoring/               # CloudWatch
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
│
├── main.tf                       # Arquivo principal
├── variables.tf                  # Variáveis globais
├── outputs.tf                    # Outputs do projeto
├── terraform.tfvars.example      # Template de configuração
├── .gitignore                    # Arquivos ignorados
├── validate-modules.ps1          # Script de validação
└── README.md                     # Este arquivo
```

---

## ✅ Pré-requisitos

### 1. Ferramentas Necessárias

```bash
# Terraform >= 1.0
terraform -v

# AWS CLI configurado
aws --version
aws configure

# Git
git --version
```

### 2. Conta e Configurações AWS

- [x] Conta AWS ativa
- [x] Domínio registrado no Route 53
  ```bash
  # Criar Hosted Zone
  aws route53 create-hosted-zone \
    --name example.com \
    --caller-reference $(date +%s)
  ```

- [x] Usuário IAM com permissões:
  - EC2FullAccess
  - VPCFullAccess
  - ElasticLoadBalancingFullAccess
  - Route53FullAccess
  - CloudWatchFullAccess

### 3. Chaves SSH

```bash
# Criar chave em us-east-1
aws ec2 create-key-pair \
  --key-name resilient-key-east \
  --region us-east-1 \
  --query 'KeyMaterial' \
  --output text > resilient-key-east.pem

# Criar chave em us-west-2
aws ec2 create-key-pair \
  --key-name resilient-key-west \
  --region us-west-2 \
  --query 'KeyMaterial' \
  --output text > resilient-key-west.pem

# Configurar permissões
chmod 400 resilient-key-*.pem
```

---

## 🚀 Instalação e Deploy

### Passo 1: Clonar e Configurar

```bash
# Clone o repositório
git clone https://github.com/ribeeiro95/aws-resilient-infra.git
cd aws-resilient-infra

# Copiar template de variáveis
cp terraform.tfvars.example terraform.tfvars
```

### Passo 2: Configurar terraform.tfvars

```hcl
# AWS Credentials
aws_access_key = "YOUR_ACCESS_KEY"
aws_secret_key = "YOUR_SECRET_KEY"

# Primary Region (us-east-1)
ami_id_east   = "ami-0c55b159cbfafe1f0"  # Amazon Linux 2
instance_type = "t3.micro"

# Secondary Region (us-west-2)
ami_id_west = "ami-0d1cd67c26f5fca19"  # Amazon Linux 2

# Route 53
route53_zone_id = "Z1234567890ABC"      # Sua Hosted Zone ID
domain_name     = "myapp.example.com"   # Seu domínio

# Load Balancer Zone IDs (não mude)
lb_zone_id_east = "Z35SXDOTRQ7X7K"      # us-east-1
lb_zone_id_west = "Z1H1FL5HABSF5"       # us-west-2
```

### Passo 3: Inicializar Terraform

```bash
terraform init

# Output esperado:
# Initializing modules...
# - vpc_east in modules/vpc
# - vpc_west in modules/vpc
# ...
# Terraform has been successfully initialized!
```

### Passo 4: Validar Configuração

```bash
# Validar sintaxe
terraform validate

# Formatar código
terraform fmt -recursive

# Verificar o que será criado
terraform plan
```

**Recursos que serão criados:**
- 2 VPCs (uma em cada região)
- 4 Subnets públicas (2 por região)
- 4 Instâncias EC2
- 2 Application Load Balancers
- 2 Target Groups
- Security Groups
- Route 53 Records com Health Checks
- CloudWatch Alarms

### Passo 5: Deploy da Infraestrutura

```bash
terraform apply
```

**Tempo estimado:** 10-15 minutos ⏱️

### Passo 6: Verificar o Deploy

Após o apply, você verá:

```
Outputs:

primary_alb_dns = "resilient-alb-east-123456.us-east-1.elb.amazonaws.com"
secondary_alb_dns = "resilient-alb-west-789012.us-west-2.elb.amazonaws.com"
route53_domain = "myapp.example.com"
primary_region = "us-east-1"
secondary_region = "us-west-2"
```

Aguarde 2-3 minutos para DNS propagar e teste:

```bash
# Testar domínio principal
curl http://myapp.example.com

# Verificar qual servidor respondeu
curl -I http://myapp.example.com | grep Server
```

---

## 🔄 Como Funciona o Failover

### 1. Route 53 Health Checks

O Route 53 monitora continuamente o **Primary ALB** (us-east-1):

```yaml
Health Check Configuration:
  Protocol: HTTP
  Port: 80
  Path: /health
  Interval: 30 seconds
  Failure Threshold: 3 consecutive failures
  Timeout: 10 seconds
```

### 2. Processo de Failover

#### Cenário Normal (Primary Saudável):
```
1. User Request → DNS query para myapp.example.com
2. Route 53 verifica: Primary Health Check = ✅ HEALTHY
3. Route 53 retorna: IP do Primary ALB (us-east-1)
4. Traffic vai para: us-east-1
```

#### Cenário de Falha (Primary Down):
```
1. Primary ALB falha (servidor, rede, ou região)
2. Route 53 Health Check: 3 falhas consecutivas (90 segundos)
3. Route 53 marca Primary como: ❌ UNHEALTHY
4. Route 53 automaticamente retorna: IP do Secondary ALB (us-west-2)
5. Novo traffic vai para: us-west-2
6. TTL do DNS: 60 segundos (máximo de delay)
```

#### Recovery (Primary Volta):
```
1. Primary ALB se recupera
2. Route 53 Health Check: 3 sucessos consecutivos (90 segundos)
3. Route 53 marca Primary como: ✅ HEALTHY
4. Route 53 automaticamente volta a retornar: IP do Primary ALB
5. Traffic retorna para: us-east-1 (Primary)
```

### 3. Timeline do Failover

```
T+0s    : Primary ALB falha
T+30s   : Primeira falha detectada pelo Health Check
T+60s   : Segunda falha detectada
T+90s   : Terceira falha detectada → Primary marcado UNHEALTHY
T+90s   : Route 53 começa a retornar Secondary
T+150s  : Todos os clientes migraram (considerando TTL de 60s)

Total Downtime: ~2.5 minutos (90s detection + 60s TTL)
```

### 4. Melhorias para Reduzir Downtime

Para ambientes de produção:

```hcl
# Em modules/route53/main.tf
resource "aws_route53_health_check" "primary" {
  # Intervalo mais agressivo
  request_interval = "10"  # 10 segundos (ao invés de 30)
  
  # Menos falhas necessárias
  failure_threshold = "2"  # 2 falhas (ao invés de 3)
}

# TTL mais baixo
resource "aws_route53_record" "primary" {
  ttl = "30"  # 30 segundos (ao invés de 60)
}

# Novo Downtime: ~50 segundos (20s detection + 30s TTL)
```

---

## 💰 Custos Estimados

### 💵 Custo Mensal Detalhado

#### Region: us-east-1 (Primary)
| Serviço | Quantidade | Custo Unitário | Total |
|---------|------------|----------------|-------|
| EC2 t3.micro | 2 instâncias | $0.0104/hora | $15.29/mês |
| Application Load Balancer | 1 ALB | $0.0225/hora + LCU | $22.00/mês |
| EBS gp3 (8GB cada) | 2 volumes | $0.08/GB/mês | $1.28/mês |
| Data Transfer OUT | ~10GB | $0.09/GB | $0.90/mês |
| **Subtotal us-east-1** | | | **$39.47/mês** |

#### Region: us-west-2 (Secondary)
| Serviço | Quantidade | Custo Unitário | Total |
|---------|------------|----------------|-------|
| EC2 t3.micro | 2 instâncias | $0.0116/hora | $17.06/mês |
| Application Load Balancer | 1 ALB | $0.0225/hora + LCU | $22.00/mês |
| EBS gp3 (8GB cada) | 2 volumes | $0.096/GB/mês | $1.54/mês |
| Data Transfer OUT | ~10GB | $0.09/GB | $0.90/mês |
| **Subtotal us-west-2** | | | **$41.50/mês** |

#### Route 53
| Serviço | Quantidade | Custo |
|---------|------------|-------|
| Hosted Zone | 1 zona | $0.50/mês |
| Health Checks | 2 checks | $1.00/mês ($0.50 cada) |
| DNS Queries | ~1M queries | $0.40/mês |
| **Subtotal Route 53** | | **$1.90/mês** |

#### CloudWatch
| Serviço | Quantidade | Custo |
|---------|------------|-------|
| Standard Metrics | 20 métricas | FREE |
| Custom Metrics | 0 | $0.00 |
| Alarms | 4 alarms | FREE (primeiros 10) |
| **Subtotal CloudWatch** | | **$0.00/mês** |

### 💰 Resumo Total

| Categoria | Custo Mensal |
|-----------|--------------|
| us-east-1 (Primary) | $39.47 |
| us-west-2 (Secondary) | $41.50 |
| Route 53 | $1.90 |
| CloudWatch | $0.00 |
| **TOTAL** | **$82.87/mês** |

**Custo Anual:** ~$994.44

### 💡 Opções de Otimização

#### Opção 1: Reserved Instances (1 ano)
```
Economia: ~40% em EC2
Novo custo mensal: ~$63/mês
Economia anual: ~$238
```

#### Opção 2: Savings Plans (1 ano)
```
Economia: ~30% em EC2 + ALB
Novo custo mensal: ~$68/mês
Economia anual: ~$178
```

#### Opção 3: Standby "Cold" (instâncias paradas)
```
Manter Secondary stopped exceto em emergências
Novo custo mensal: ~$62/mês
Porém: Failover demora ~5 minutos (tempo de boot)
```

### ⚠️ Custos Adicionais Potenciais

- **Data Transfer entre regiões:** $0.02/GB (se sincronizar dados)
- **CloudWatch Logs:** $0.50/GB ingerido
- **Snapshots EBS:** $0.05/GB/mês
- **Traffic spike:** ALB cobra por LCU adicional

---

## 📊 Monitoramento e Alertas

### CloudWatch Métricas Principais

#### EC2 Instances
```
- CPUUtilization (%)
- NetworkIn/NetworkOut (bytes)
- StatusCheckFailed (count)
- DiskReadOps/DiskWriteOps
```

#### Application Load Balancer
```
- TargetResponseTime (seconds)
- HTTPCode_Target_2XX_Count
- HTTPCode_Target_5XX_Count
- UnHealthyHostCount
- ActiveConnectionCount
```

#### Route 53
```
- HealthCheckStatus (0 ou 1)
- HealthCheckPercentageHealthy
```

### Alarmes Configurados

#### Primary Region (us-east-1)
```hcl
Alarm: UnhealthyHostCount > 0
  Actions: SNS notification
  Period: 5 minutes
  Evaluation: 2 consecutive periods

Alarm: CPUUtilization > 80%
  Actions: SNS notification
  Period: 5 minutes
  Evaluation: 2 consecutive periods

Alarm: Route53 HealthCheck UNHEALTHY
  Actions: SNS notification + PagerDuty
  Period: 1 minute
  Evaluation: 3 consecutive periods
```

#### Secondary Region (us-west-2)
```hcl
# Mesmos alarmes da Primary
```

### Dashboard CloudWatch

Acesse: AWS Console > CloudWatch > Dashboards

Widgets recomendados:
```
1. Health Status Map (Primary vs Secondary)
2. Request Count Timeline (ambas regiões)
3. Latency Metrics (P50, P95, P99)
4. Error Rate (5XX) por região
5. Active Connections por ALB
```

---

## 🧪 Testes de Resiliência

### Teste 1: Simular Falha do Primary ALB

```bash
# 1. Obter ALB ARN do Primary
PRIMARY_ALB_ARN=$(aws elbv2 describe-load-balancers \
  --region us-east-1 \
  --query 'LoadBalancers[?LoadBalancerName==`resilient-alb-east`].LoadBalancerArn' \
  --output text)

# 2. Deletar TEMPORARIAMENTE o ALB (⚠️ CUIDADO!)
aws elbv2 delete-load-balancer \
  --load-balancer-arn $PRIMARY_ALB_ARN \
  --region us-east-1

# 3. Monitorar failover
watch -n 5 'dig +short myapp.example.com'

# 4. Verificar traffic no Secondary
curl http://myapp.example.com

# 5. Recriar Primary com Terraform
terraform apply -target=module.alb_east
```

**Resultado Esperado:**
- T+90s: Route 53 detecta Primary down
- T+150s: Todo traffic migrado para Secondary (us-west-2)
- Zero erros para usuários finais

### Teste 2: Chaos Engineering - Desligar Instâncias EC2

```bash
# 1. Listar instâncias Primary
aws ec2 describe-instances \
  --region us-east-1 \
  --filters "Name=tag:Environment,Values=resilient-prod" \
  --query 'Reservations[*].Instances[*].[InstanceId,State.Name]'

# 2. Parar UMA instância (ALB deve continuar funcionando)
aws ec2 stop-instances \
  --instance-ids i-1234567890abcdef \
  --region us-east-1

# 3. Verificar ALB Target Health
aws elbv2 describe-target-health \
  --target-group-arn $TARGET_GROUP_ARN \
  --region us-east-1

# 4. Parar TODAS instâncias Primary (forçar failover)
aws ec2 stop-instances \
  --instance-ids $(aws ec2 describe-instances \
    --region us-east-1 \
    --filters "Name=tag:Environment,Values=resilient-prod" \
    --query 'Reservations[*].Instances[*].InstanceId' \
    --output text) \
  --region us-east-1
```

### Teste 3: Latência e Performance

```bash
# Benchmark Primary
ab -n 1000 -c 10 http://myapp.example.com/

# Benchmark Secondary
ab -n 1000 -c 10 http://secondary.example.com/

# Comparar latências
echo "Comparando latências:"
echo "Primary:"
curl -w "@curl-format.txt" -o /dev/null -s http://myapp.example.com/
echo "\nSecondary:"
curl -w "@curl-format.txt" -o /dev/null -s http://secondary.example.com/
```

**curl-format.txt:**
```
time_namelookup:  %{time_namelookup}\n
time_connect:     %{time_connect}\n
time_starttransfer: %{time_starttransfer}\n
time_total:       %{time_total}\n
```

---

## 🔧 Troubleshooting

### Problema 1: Failover Não Funciona

**Sintoma:** Primary down mas traffic não migra para Secondary

**Debug:**
```bash
# 1. Verificar Health Check Status
aws route53 get-health-check-status \
  --health-check-id $HEALTH_CHECK_ID

# 2. Verificar DNS propagation
dig myapp.example.com

# 3. Verificar TTL
dig myapp.example.com | grep -A1 "ANSWER SECTION"

# 4. Testar Health Check endpoint manualmente
curl -I http://PRIMARY_ALB_DNS/health
curl -I http://SECONDARY_ALB_DNS/health
```

**Soluções:**
- Aguardar TTL expirar (60 segundos)
- Verificar Security Groups permitem Route 53 health checks
- Confirmar endpoint /health responde 200 OK

### Problema 2: Alto Custo Inesperado

**Sintoma:** Fatura AWS maior que $83/mês

**Debug:**
```bash
# 1. Cost Explorer via CLI
aws ce get-cost-and-usage \
  --time-period Start=2025-11-01,End=2025-11-30 \
  --granularity DAILY \
  --metrics UnblendedCost \
  --group-by Type=SERVICE

# 2. Verificar Data Transfer
aws cloudwatch get-metric-statistics \
  --namespace AWS/EC2 \
  --metric-name NetworkOut \
  --dimensions Name=InstanceId,Value=i-xxxxx \
  --start-time 2025-11-01T00:00:00Z \
  --end-time 2025-11-30T23:59:59Z \
  --period 86400 \
  --statistics Sum
```

**Causas Comuns:**
- Data transfer entre regiões
- ALB com muitos LCU (traffic alto)
- Instâncias maiores que t3.micro
- Snapshots EBS não deletados

### Problema 3: Latência Alta no Secondary

**Sintoma:** Secondary região mais lenta que Primary

**Debug:**
```bash
# 1. Comparar instance types
aws ec2 describe-instances --region us-east-1 \
  --query 'Reservations[*].Instances[*].[InstanceType,State.Name]'

aws ec2 describe-instances --region us-west-2 \
  --query 'Reservations[*].Instances[*].[InstanceType,State.Name]'

# 2. Verificar CPU e Network
# CloudWatch Console > Metrics > EC2 > Per-Instance Metrics
```

**Soluções:**
- Usar mesmo instance type em ambas regiões
- Verificar user-data executou corretamente
- Considerar instância maior (t3.small) se necessário

### Problema 4: GitHub Actions CI/CD Falhando

**Sintoma:** Pipeline de validação falhando

**Debug:**
```bash
# 1. Verificar secrets do GitHub
# Settings > Secrets > Actions

# 2. Testar Terraform localmente
terraform init
terraform validate
terraform fmt -check

# 3. Verificar AWS credentials
aws sts get-caller-identity
```

---

## 🚀 Melhorias Futuras

### Fase 1: Database Replication
- [ ] RDS Multi-Region com read replicas
- [ ] DynamoDB Global Tables
- [ ] Redis cluster multi-region

### Fase 2: Application-Level Failover
- [ ] Active-Active deployment (ambas regiões ativas)
- [ ] GeoDNS routing (closest region)
- [ ] Session replication entre regiões

### Fase 3: Advanced Monitoring
- [ ] AWS X-Ray para distributed tracing
- [ ] Grafana dashboards customizados
- [ ] Prometheus exporters
- [ ] PagerDuty integration

### Fase 4: Automation
- [ ] Auto-remediation com Lambda
- [ ] Runbooks automatizados
- [ ] Chaos Engineering contínuo (Gremlin)

### Fase 5: Security Enhancements
- [ ] WAF (Web Application Firewall)
- [ ] AWS Shield Advanced (DDoS protection)
- [ ] VPC Peering entre regiões
- [ ] Private Link para serviços internos

---

## 📚 Aprendizados

### Competências Desenvolvidas

✅ **Multi-Region Architecture**
- Design de sistemas distribuídos geograficamente
- Trade-offs entre consistency e availability (CAP theorem)
- Estratégias de disaster recovery

✅ **DNS e Failover**
- Route 53 health checks avançados
- Políticas de roteamento (failover, geolocation, weighted)
- TTL optimization para RTO

✅ **High Availability**
- SLA calculation (99.9%, 99.99%, etc.)
- RTO (Recovery Time Objective) vs RPO (Recovery Point Objective)
- Active-passive vs active-active

✅ **Terraform Avançado**
- Módulos reutilizáveis e parametrizados
- Provider configuration para múltiplas regiões
- Workspaces e remote state

✅ **CI/CD**
- GitHub Actions workflows
- Automated testing de infraestrutura
- Git-based infrastructure workflows

### Desafios Superados

1. **Configuração de Route 53 Failover**
   - Entendimento profundo de health checks
   - Configuração de alarmes e notificações

2. **Gerenciamento Multi-Region**
   - Uso de múltiplos providers Terraform
   - Nomenclatura consistente entre regiões

3. **Otimização de Custos**
   - Balancear resiliência com economia
   - Estratégias para minimizar data transfer

4. **Testing de Disaster Recovery**
   - Desenvolvimento de plano de testes
   - Automation de chaos engineering

---

## 📖 Recursos Adicionais

### Documentação
- [AWS Well-Architected Framework - Reliability Pillar](https://docs.aws.amazon.com/wellarchitected/latest/reliability-pillar/)
- [Route 53 Failover Routing](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-policy-failover.html)
- [Multi-Region Terraform](https://developer.hashicorp.com/terraform/tutorials/aws/aws-multiple-regions)

### Artigos Recomendados
- [Netflix: Active-Active for Multi-Regional Resiliency](https://netflixtechblog.com/active-active-for-multi-regional-resiliency-c47719f6685b)
- [AWS Disaster Recovery Whitepaper](https://docs.aws.amazon.com/whitepapers/latest/disaster-recovery-workloads-on-aws/)

---

## 📞 Contato

**Gustavo Ribeiro do Vale**

- 💼 [LinkedIn](https://www.linkedin.com/in/GustavoRibeiro95/)
- 🐙 [GitHub](https://github.com/Ribeeiro95)
- 📧 Email: gustavordovale@hotmail.com
- 🌍 Localização: Americana, SP - Brasil

---

## 📄 Licença

Este projeto está sob a licença MIT.

---

⭐ **Se este projeto demonstrou competências valiosas, considere dar uma estrela no repositório!**

---

**Desenvolvido com ❤️ por Gustavo Ribeiro | DevOps Engineer em transição de carreira**
