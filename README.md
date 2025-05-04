

## 1. Aurora/RDS Configuration

```shell
Choose database creation method: Standard create                       # Full control over version, storage, network
Engine options:  Engine type: PostgreSQL                               # Open‑source, stable, Rails‑friendly
Engine version: PostgreSQL 17.2‑R2                                     # Latest patched release
Enable RDS Extended Support: Unchecked                                 # Avoid extra cost; upgrade before EOL
Templates: Free tier                                                   # Dev/test eligible
Availability and durability: Single‑AZ DB instance (1 instance)        # Cost‑effective; non‑prod
DB instance identifier: rorchatapp                                     # Logical name
Master username: myuser                                                # Admin credentials
Credentials management: Self managed                                   # Manual password
Master password: mypassword                                            # Store securely
Confirm Master password: mypassword
DB instance class: db.t4g.micro                                        # Burstable, low‑cost
Storage type: General Purpose SSD (gp2)                                # Balanced I/O
Allocated storage: 20 GiB                                              # Minimum free‑tier
Compute resource: Don’t connect to an EC2 compute resource             # Keep DB decoupled
Network type: IPv4                                                     # Standard
VPC: Default VPC (vpc‑02853bd379618f5ca)                                # User’s default
DB subnet group: default‑vpc‑02853bd379618f5ca
Public access: No                                                      # Private only
VPC security groups: sg‑0ded60800cd8a90fd, rds‑sg, sg‑0a35e9086b143cac5, default  
Availability Zone: No preference                                       # AWS selects  
Certificate authority: rds‑ca‑rsa2048‑g1 (default)                     # AWS default CA  
Database authentication: Password authentication  
Monitoring: Database Insights‑Standard; Performance Insights enabled  
Initial database name: rorchatapp  
DB parameter group: default.postgres17  
Backup: Automated backups enabled  
Maintenance: Auto minor version upgrade enabled  
Maintenance window: No preference  
Endpoint: rorchatapp.c342ea4cs6ny.ap-south-1.rds.amazonaws.com  
```

---

## 2. ECR Configuration

```shell
Create private repository  
Repository name: 339713104321.dkr.ecr.ap-south-1.amazonaws.com/final-ror-ecr  # ECR URI  
All other settings: default                                                  # Standard private repo  
```

---

## 3. CodeBuild Configuration

```shell
Project name: final-ror-codebuild                # Logical identifier  
Source provider: GitHub  
Repository: https://github.com/Mallick17/ROR-AWS-ECS  
Webhook events: default                        # Trigger on push  
Environment:  
  Provisioning model: On‑demand  
  Image: aws/codebuild/standard:7.0             # Ubuntu standard build image  
  Compute: EC2, Container mode  
  Service role: arn:aws:iam::339713104321:role/codebuild-ror-app-role  
Buildspec: use buildspec.yml in repo  
Logs: CloudWatch logs                          # Default logging  
```

---

## 4. ECS Cluster & Auto Scaling Group

```shell
Cluster name: final-ror-cluster  
Infrastructure: Amazon EC2 Instances  
Auto Scaling group: Create new ASG  
  Provisioning model: On‑demand  
  AMI: Amazon Linux 2 (kernel 5.10)  
  Instance type: t3.medium  
  EC2 instance role: ecsInstanceRole  
  Desired capacity: min 1, max 5  
  SSH key pair: Myops  
  Root EBS volume: 30 GiB  
VPC: vpc‑02853bd379618f5ca  
Subnets:  
  subnet‑0738b2e70f37fe442 (ap‑south‑1a / 172.31.32.0/20)  
  subnet‑04cf194b656ad564e (ap‑south‑1c / 172.31.16.0/20)  
  subnet‑03b17848527227137 (ap‑south‑1b / 172.31.0.0/20)  
Security group: sg‑0a35e9086b143cac5  
Monitoring: Container Insights (enhanced)  
```

---

## 5. Launch Template (used by ASG)

```shell
Launch template ID: lt-02966e6de779bb634  
Name: ECSLaunchTemplate_UV74RFdQo9l0  
AMI ID: ami-0c1962fdaf1a23f7d  
Instance type: t3.medium  
Key pair: Myops  
Security groups: sg‑0a35e9086b143cac5, sg‑0106a2994ff8e49aa  
Root device: /dev/xvda, 30 GiB  
Request Spot Instances: No  
Capacity distribution: Balanced across AZs (1a,1b,1c)  
Health check: EC2, grace period 0  
Scaling policy: Target tracking (Custom CloudWatch metric at 100), warm‑up 300 s  
Lifecycle hook: ecs‑managed‑draining‑termination‑hook (EC2_INSTANCE_TERMINATING, CONTINUE, timeout 3600s)  
```

---

## 6. Task Definition

```shell
Family: final-ror-task-definition  
Launch type: EC2  
Network mode: bridge  
CPU: 2 vCPU, Memory: 3 GB  
Execution role: ecsTaskExecutionRole  
Container “app”:  
  Image: 339713104321.dkr.ecr.ap-south-1.amazonaws.com/mallow-ror-app  
  Essential: Yes  
  Ports: Host 80 → Container 80 (TCP, HTTP)  
  CPU: 0.5 units, Memory hard 1 GB  
  Env vars:  
    RAILS_ENV=production  
    DB_USER=myuser  
    DB_PASSWORD=mypassword  
    DB_HOST=ror-chat-app.c342ea4cs6ny.ap-south-1.rds.amazonaws.com  
    DB_PORT=5432  
    DB_NAME=ror-chat-app  
    REDIS_URL=redis://redis:6379/0  
    RAILS_MASTER_KEY=c3ca922688d4bf22ac7fe38430dd8849  
    SECRET_KEY_BASE=600f21de02355f788c759ff862a2cb22ba84ccbf072487992f4c2c49ae260f87c7593a1f5f6cf2e45457c76994779a8b30014ee9597e35a2818ca91e33bb7233  
Container “redis” (startup dependency):  
  Image: redis:7  
  Essential: No  
  Ports: Container 6379  
  CPU: 0.256 units, Memory hard 0.512 GB  
Startup ordering: wait for “redis” before “app”  
```

---

## 7. ECS Service

```shell
Service name: final-ror-cluster-service  
Cluster: final-ror-cluster  
Launch type: EC2  
Task definition: final-ror-task-definition  
Service type: Replica  
Desired tasks: 1  
AZ rebalancing: On  
Deployment: Rolling update (min 100%, max 200%)  
Circuit breaker: Enabled (rollback on failure)  
Placement: AZ balanced spread  
```

---

## 8. IAM Roles & Policies

### ecsInstanceRole

```json
Policy: AmazonEC2ContainerRegistryReadOnly
Actions: ecr:GetAuthorizationToken, BatchCheckLayerAvailability, GetDownloadUrlForLayer, …
Resource: *
```

```json
Policy: AmazonEC2ContainerServiceforEC2Role
Actions: ec2:DescribeTags, ecs:CreateCluster, ecs:RegisterContainerInstance, ecr:GetAuthorizationToken, logs:CreateLogStream, …
Resource: *
Condition: TagResource only on CreateCluster/RegisterContainerInstance
```

### codebuild-ror-app-role

– Attached managed policies: AWSCodeBuildRole, etc., as required.

---


