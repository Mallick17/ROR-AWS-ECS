# Deploying a Ruby on Rails (ROR) application using AWS services such as Auto Scaling Group (ASG), Launch Template, Amazon RDS, Amazon ECS (Cluster, Task Definition, Service), Amazon ECR, AWS CodeBuild, and IAM Roles. 
---

## RDS Configuration

<details>
  <summary>Click to view Aurora/RDS Configuration</summary>
  
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

</details>

### Create Database
- **Choose a database creation method**: `Standard create`  
  *Gives full control over database configuration, including version, storage, and networking options.*

- **Engine options**:  
  - **Engine type**: `PostgreSQL`  
    *Open-source, stable database engine; ideal for Rails applications due to its support for complex queries.*  
  - **Engine version**: `PostgreSQL 17.2-R2`  
    *Default version provided by AWS, includes the latest patches and features.*  
  - **Enable RDS Extended Support**: `Unchecked`  
    *Default; avoids additional costs by not opting for extended support; requires upgrading before community end-of-life (EOL).*

- **Templates**: `Free tier`  
  *Eligible for AWS Free Tier; suitable for development or testing environments with limited resources.*

- **Availability and durability**: `Single-AZ DB instance deployment (1 instance)`  
  *Cost-effective option with a single instance in one Availability Zone; no high availability; best for non-production use.*

- **Settings**:  
  - **DB instance identifier**: `rorchatapp`  
    *Custom name to uniquely identify the database instance in AWS.*  
  - **Credentials Settings**:  
    - **Master username**: `myuser`  
      *Administrative user for accessing and managing the database.*  
    - **Credentials management**: `Self managed`  
      *Manually manage the password instead of using AWS Secrets Manager.*  
    - **Master password**: `mypassword`  
      *Password for authentication; must be stored securely.*  
    - **Confirm Master password**: `mypassword`  
      *Confirmation of the master password.*

- **Instance configuration**:  
  - **DB instance class**: `Burstable classes (includes t classes)`  
    *Category of instances with burstable performance.*  
  - **DB instance class**: `db.t4g.micro`  
    *Low-cost, burstable instance type; suitable for development or testing.*

- **Storage**:  
  - **Storage type**: `General Purpose SSD (gp2)`  
    *Balanced storage option with support for burst performance; cost-effective for most workloads.*  
  - **Allocated storage**: `20`  
    *20 GiB of storage; minimum size eligible for Free Tier.*

- **Connectivity**:  
  - **Compute resource**: `Don’t connect to an EC2 compute resource`  
    *Default; keeps the database decoupled from EC2 instances for more flexible networking.*  
  - **Network type**: `IPv4`  
    *Default; uses standard IP format, widely supported.*  
  - **Virtual private cloud (VPC)**: `Default VPC (vpc-02853bd379618f5ca)`  
    *Uses the default VPC provided by AWS for this account.*  
  - **DB subnet group**: `default-vpc-02853bd379618f5ca`  
    *Default subnet group associated with the VPC.*  
  - **Public access**: `No`  
    *Default; enhances security by preventing public access to the database.*  
  - **VPC security group (firewall)**: `Choose existing`  
    *Uses existing security groups to control traffic.*  
    - **Existing VPC security groups**:  
      - `sg-0ded60800cd8a90fd`  
      - `rds-sg`  
      - `sg-0a35e9086b143cac5`  
      - `default`  
      *List of security groups applied to the RDS instance for network access control.*  
  - **Availability Zone**: `No preference`  
    *Default; allows AWS to select the Availability Zone.*

- **RDS Proxy**: `All default`  
  *Not using RDS Proxy; keeps the configuration simple.*

- **Certificate authority - optional**: `rds-ca-rsa2048-g1 (default)`  
  *Default certificate authority for SSL/TLS connections to the database.*

- **Tags - optional**: `None specified`  
  *No additional tags provided.*

- **Database authentication**: `Password authentication`  
  *Standard method using a username and password for database access.*

- **Monitoring**: `All default`  
  - **Database Insights**: `Standard`  
    *Default monitoring level for database activity.*  
  - **Performance Insights**: `Enable Performance Insights`  
    *Enabled to monitor and analyze database performance metrics.*

- **Additional configuration**:  
  - **Database options**:  
    - **Initial database name**: `rorchatapp`  
      *Name of the initial database created within the RDS instance.*  
    - **DB parameter group**: `default.postgres17`  
      *Default parameter group for PostgreSQL 17 settings.*  
  - **Backup**: `Enable automated backups`  
    *Default; ensures regular backups are taken for data recovery.*  
  - **Maintenance**: `Enable auto minor version upgrade`  
    *Default; automatically applies minor version upgrades during maintenance windows.*  
  - **Maintenance window**: `No preference`  
    *Default; AWS selects the maintenance window timing.*

- **Endpoint**: `rorchatapp.c342ea4cs6ny.ap-south-1.rds.amazonaws.com`  
  *The DNS endpoint used to connect to the database instance.*

**Action**: Create database

---

## ECR Configuration

<details>
  <summary>ECR Configuration</summary>
  
## 2. ECR Configuration

```shell
Create private repository  
Repository name: 339713104321.dkr.ecr.ap-south-1.amazonaws.com/final-ror-ecr  # ECR URI  
All other settings: default                                                  # Standard private repo  
```

</details>

### Create Private Repository
- **Repository name**: `339713104321.dkr.ecr.ap-south-1.amazonaws.com/final-ror-ecr`  
  *Unique name for the private Docker repository, including AWS account ID and region.*

- **Rest all default**  
  *Uses default settings for repository policies, encryption, and tags.*

**Action**: Create the repository

---

## CodeBuild Configuration

<details>
  <summary>CodeBuild Configuration</summary>
  
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

</details>

### Create Build Project
- **Project configuration**:  
  - **Project name**: `final-ror-codebuild`  
    *Name to identify the build project in AWS CodeBuild.*

- **All default**  
  *Uses default settings for project configuration unless specified.*

- **Source**:  
  - **Source provider**: `GitHub`  
    *Connects to GitHub as the source code provider.*  
  - **Repository**: `Repository in my GitHub account`  
    *Indicates the source is a personal GitHub repository.*  
  - **Repository**: `https://github.com/Mallick17/ROR-AWS-ECS`  
    *Specific URL of the GitHub repository containing the ROR application code.*

- **All default**  
  *Uses default settings for source configuration, such as authentication.*

- **Primary source webhook events**: `All default`  
  *Default webhook settings to trigger builds on code changes.*

- **Environment**:  
  - **Provisioning model**: `On-demand`  
    *Default; provisions compute resources as needed for builds.*  
  - **Environment image**: `Managed image`  
    *Default; uses an AWS-managed build environment image.*  
  - **Compute**: `EC2`  
    *Default; runs builds on EC2 instances.*  
  - **Running mode**: `Container`  
    *Default; executes builds within containers.*  
  - **Operating system**: `Ubuntu`  
    *Chosen OS for the build environment; widely supported.*  
  - **Runtime(s)**: `Standard`  
    *Default runtime environment.*  
  - **Image**: `aws/codebuild/standard:7.0`  
    *Specific AWS CodeBuild image version for the build environment.*  
  - **Service role**: `Existing service role`  
    *Uses an existing IAM role for CodeBuild permissions.*  
    - **Role ARN**: `arn:aws:iam::339713104321:role/codebuild-ror-app-role`  
      *ARN of the IAM role granting CodeBuild access to required AWS resources.*  
  - **Buildspec**: `Use a buildspec file`  
    *Indicates a `buildspec.yml` file in the repository defines the build process.*

- **All default**  
  *Uses default settings for environment configuration unless specified.*

- **CloudWatch**: `CloudWatch logs`  
  *Default; sends build logs to Amazon CloudWatch for monitoring.*

**Action**: Create build project and trigger it to build the Docker image

---

## ECS Cluster Configuration

<details>
  <summary>ECS Cluster & Auto Scaling Group</summary>
  
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

</details>

### Create Cluster
- **Cluster name**: `final-ror-cluster`  
  *Name to identify the ECS cluster.*

- **Infrastructure**: `Amazon EC2 Instances`  
  *Uses EC2 instances to run containers in the cluster.*

- **Auto Scaling group**: `Create new ASG`  
  *Creates a new Auto Scaling Group to manage EC2 instances for the cluster.*

- **Provisioning model**: `On-demand`  
  *Default; provisions EC2 instances as needed.*

- **Container instance Amazon Machine Image (AMI)**: `Amazon Linux 2 (kernel 5.10)`  
  *Default ECS-optimized AMI for running containers.*

- **EC2 instance type**: `t3.medium`  
  *Instance type for the cluster nodes; balances cost and performance.*

- **EC2 instance role**: `ecsInstanceRole`  
  *IAM role allowing EC2 instances to interact with ECS and other AWS services.*

- **Desired capacity**:  
  - **Minimum**: `1`  
  - **Maximum**: `5`  
    *Sets the scaling range for the Auto Scaling Group; minimum of 1 instance, maximum of 5.*

- **SSH Key pair**: `Myops`  
  *Key pair for SSH access to EC2 instances.*

- **Root EBS volume size**: `30`  
  *30 GiB root volume size for each EC2 instance.*

- **Network settings for Amazon EC2 instances**:  
  - **VPC**: `vpc-02853bd379618f5ca`  
    *Specific VPC used for the cluster.*  
  - **Subnets**:  
    - `subnet-0738b2e70f37fe442` (ap-south-1a)  
    - `subnet-04cf194b656ad564e` (ap-south-1c)  
    - `subnet-03b17848527227137` (ap-south-1b)  
      *Subnets across multiple Availability Zones for high availability.*  
  - **Security group**: `Use an existing security group`  
    - **Security group IDs**: `sg-0a35e9086b143cac5`  
      *Default security group controlling network traffic to the instances.*

- **Monitoring**: `Container Insights with enhanced observability`  
  *Enables detailed monitoring and metrics for containers in the cluster.*

- **All default**  
  *Uses default settings for other cluster configurations unless specified.*

**Action**: Create the cluster

---

## Task Definition

<details>
  <summary>Task Definition</summary>
  
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

</details>

### Create New Task Definition
- **Task definition family**: `final-ror-task-definition`  
  *Name for the task definition family; groups related task versions.*

- **Infrastructure requirements**:  
  - **Launch type**: `Amazon EC2 instances`  
    *Tasks run on EC2 instances within the ECS cluster.*  
  - **Operating system/Architecture**: `Linux/x86_64`  
    *Default; standard Linux architecture for compatibility.*  
  - **Network mode**: `bridge`  
    *Uses Docker’s bridge networking mode for container communication.*  
  - **Task size**:  
    - **CPU**: `2 vCPU`  
    - **Memory**: `3GB`  
      *Total resource limits allocated to the task.*  
  - **Task role**: `None`  
    *Default; no additional IAM role assigned to the task.*  
  - **Task execution role**: `ecsTaskExecutionRole`  
    *IAM role allowing ECS to manage task execution (e.g., pulling images, logging).*

- **Container 1**:  
  - **Container name**: `app`  
    *Name of the primary application container.*  
  - **Image**: `339713104321.dkr.ecr.ap-south-1.amazonaws.com/mallow-ror-app`  
    *Docker image from ECR containing the ROR application.*  
  - **Essential**: `Yes`  
    *Marks this container as essential; task stops if it fails.*  
  - **Private registry authentication**: `Unchecked`  
    *Default; no additional authentication needed for ECR.*  
  - **Port mappings**:  
    - **Host port**: `80`  
    - **Container port**: `80`  
    - **Protocol**: `TCP`  
    - **App protocol**: `HTTP`  
      *Maps port 80 on the host to port 80 in the container for HTTP traffic.*  
  - **Resource allocation limits**:  
    - **CPU**: `0.5`  
    - **Memory hard limit**: `1`  
    - **Memory soft limit**: `-`  
      *Limits the container to 0.5 vCPU and 1 GB of memory.*  
  - **Environment Variables**:  
    - **RAILS_ENV**: `production`  
      *Sets the Rails environment to production mode.*  
    - **DB_USER**: `myuser`  
      *Database username for the application.*  
    - **DB_PASSWORD**: `mypassword`  
      *Database password; must be securely managed.*  
    - **DB_HOST**: `ror-chat-app.c342ea4cs6ny.ap-south-1.rds.amazonaws.com`  
      *RDS endpoint for database connection.*  
    - **DB_PORT**: `5432`  
      *Default PostgreSQL port.*  
    - **DB_NAME**: `ror-chat-app`  
      *Name of the database the application uses.*  
    - **REDIS_URL**: `redis://redis:6379/0`  
      *URL for connecting to the Redis container.*  
    - **RAILS_MASTER_KEY**: `c3ca922688d4bf22ac7fe38430dd8849`  
      *Master key for Rails encrypted credentials.*  
    - **SECRET_KEY_BASE**: `600f21de02355f788c759ff862a2cb22ba84ccbf072487992f4c2c49ae260f87c7593a1f5f6cf2e45457c76994779a8b30014ee9597e35a2818ca91e33bb7233`  
      *Secret key for Rails application security.*  
  - **Log Collection**: `Optional - default values`  
    *Uses default logging configuration (e.g., CloudWatch logs).*  
  - **Startup dependency ordering**:  
    - **Container name**: `redis`  
    - **Condition**: `Start`  
      *Ensures the Redis container starts before the app container.*

- **Container 2**:  
  - **Container name**: `redis`  
    *Name of the Redis container.*  
  - **Image**: `redis:7`  
    *Official Redis image, version 7, from Docker Hub.*  
  - **Essential**: `No`  
    *Not essential; task can continue if this container fails.*  
  - **Port mappings**:  
    - **Host port**: `0`  
    - **Container port**: `6379`  
    - **Protocol**: `None`  
      *Maps container port 6379 (Redis default) to a dynamic host port.*  
  - **Resource allocation limits**:  
    - **CPU**: `0.256`  
    - **Memory hard limit**: `0.512`  
    - **Memory soft limit**: `-`  
      *Limits the container to 0.256 vCPU and 512 MB of memory.*

**Action**: Create task definition

---

## Cluster Service Configuration

<details>
  <summary>ECS Service Configuration</summary>
  
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

</details>

### Service Configuration
- **Task definition family**: `final-ror-task-definition`  
  *Uses the previously created task definition.*

- **Service name**: `final-ror-cluster-service`  
  *Name for the ECS service.*

- **Environment**:  
  - **Existing cluster**: `final-ror-cluster`  
    *Deploys the service to the existing ECS cluster.*  
  - **Compute configuration**: `Launch type: EC2`  
    *Runs tasks on EC2 instances within the cluster.*

- **Deployment configuration**: `All default`  
  - **Service type**: `Replica`  
    *Maintains a specified number of running tasks.*  
  - **Desired tasks**: `1`  
    *Runs one instance of the task at all times.*  
  - **Availability Zone rebalancing**: `Turn on`  
    *Ensures tasks are balanced across Availability Zones.*

- **Deployment options**:  
  - **Deployment type**: `Rolling update`  
    *Updates tasks gradually to minimize downtime.*  
  - **Min running tasks %**: `100`  
    *Ensures at least 100% of desired tasks run during deployment.*  
  - **Max running tasks %**: `200`  
    *Allows up to 200% capacity during deployment for smooth transitions.*

- **Deployment failure detection**:  
  - **Deployment circuit breaker**: `Checked`  
    *Stops deployment if tasks fail to start.*  
  - **Rollback on failure**: `Checked`  
    *Reverts to the previous version if deployment fails.*

- **Load Balancing**: `Unchecked`  
  *No load balancer configured for this service.*

- **Service Auto Scaling**: `All default`  
  *No auto scaling configured for the service.*

- **Task Placement**: `All default`  
  - **Placement templates**: `AZ balanced spread`  
    *Spreads tasks evenly across Availability Zones.*

**Action**: Create service and wait for it to run

---

## IAM Roles
### ECS Role (ecsInstanceRole)
This role is attached to the EC2 instances in the ECS cluster.

<details>
  <summary>codebuild-ror-app-role</summary>
  
### codebuild-ror-app-role

– Attached managed policies: AWSCodeBuildRole, etc., as required.

```json
{
  "Version": "2012-10-17",
  "Statement": [

    // --- ECR Permissions ---
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:GetRepositoryPolicy",
        "ecr:DescribeRepositories",
        "ecr:ListImages",
        "ecr:DescribeImages",
        "ecr:BatchGetImage",
        "ecr:GetLifecyclePolicy",
        "ecr:GetLifecyclePolicyPreview",
        "ecr:ListTagsForResource",
        "ecr:DescribeImageScanFindings",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload",
        "ecr:PutImage"
      ],
      "Resource": "*"
    },

    // --- CloudWatch Logs Full Access ---
    {
      "Sid": "CloudWatchLogsFullAccess",
      "Effect": "Allow",
      "Action": [
        "logs:*",
        "cloudwatch:GenerateQuery"
      ],
      "Resource": "*"
    },

    // --- Specific CloudWatch Logs and CodeBuild Reporting ---
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": [
        "arn:aws:logs:ap-south-1:339713104321:log-group:/aws/codebuild/mallow-ecs-ror-final-codebuild",
        "arn:aws:logs:ap-south-1:339713104321:log-group:/aws/codebuild/mallow-ecs-ror-final-codebuild:*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:CreateReportGroup",
        "codebuild:CreateReport",
        "codebuild:UpdateReport",
        "codebuild:BatchPutTestCases",
        "codebuild:BatchPutCodeCoverages"
      ],
      "Resource": [
        "arn:aws:codebuild:ap-south-1:339713104321:report-group/mallow-ecs-ror-final-codebuild-*"
      ]
    },

    // --- S3 Artifact and Pipeline Bucket Access ---
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:GetObjectVersion",
        "s3:GetBucketAcl",
        "s3:GetBucketLocation"
      ],
      "Resource": [
        "arn:aws:s3:::codepipeline-ap-south-1-*",
        "arn:aws:s3:::codepipelinestartertempla-codepipelineartifactsbuc-lkksehyipedk/*"
      ]
    },

    // --- CodeStar / CodeConnections Access (GitHub Connections) ---
    {
      "Effect": "Allow",
      "Action": [
        "codestar-connections:GetConnectionToken",
        "codestar-connections:GetConnection",
        "codeconnections:GetConnectionToken",
        "codeconnections:GetConnection",
        "codeconnections:UseConnection"
      ],
      "Resource": [
        "arn:aws:codestar-connections:ap-south-1:339713104321:connection/e78bca79-a1be-4f00-9f47-58e0d3058c09",
        "arn:aws:codeconnections:ap-south-1:339713104321:connection/e78bca79-a1be-4f00-9f47-58e0d3058c09"
      ]
    },

    // --- Secrets Manager, Lambda, CloudFormation, KMS, etc. ---
    {
      "Sid": "BasePermissions",
      "Effect": "Allow",
      "Action": [
        "secretsmanager:*",
        "cloudformation:CreateChangeSet",
        "cloudformation:DescribeChangeSet",
        "cloudformation:DescribeStackResource",
        "cloudformation:DescribeStacks",
        "cloudformation:ExecuteChangeSet",
        "docdb-elastic:GetCluster",
        "docdb-elastic:ListClusters",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSubnets",
        "ec2:DescribeVpcs",
        "kms:DescribeKey",
        "kms:ListAliases",
        "kms:ListKeys",
        "lambda:ListFunctions",
        "rds:DescribeDBClusters",
        "rds:DescribeDBInstances",
        "redshift:DescribeClusters",
        "redshift-serverless:ListWorkgroups",
        "redshift-serverless:GetNamespace",
        "tag:GetResources"
      ],
      "Resource": "*"
    },
    {
      "Sid": "LambdaPermissions",
      "Effect": "Allow",
      "Action": [
        "lambda:AddPermission",
        "lambda:CreateFunction",
        "lambda:GetFunction",
        "lambda:InvokeFunction",
        "lambda:UpdateFunctionConfiguration"
      ],
      "Resource": "arn:aws:lambda:*:*:function:SecretsManager*"
    },
    {
      "Sid": "SARPermissions",
      "Effect": "Allow",
      "Action": [
        "serverlessrepo:CreateCloudFormationChangeSet",
        "serverlessrepo:GetApplication"
      ],
      "Resource": "arn:aws:serverlessrepo:*:*:applications/SecretsManager*"
    },
    {
      "Sid": "S3PermissionsForSAR",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": [
        "arn:aws:s3:::awsserverlessrepo-changesets*",
        "arn:aws:s3:::secrets-manager-rotation-apps-*/*"
      ]
    }

  ]
}
```

---

</details>

<details>
  <summary>ecsInstanceRole</summary>

### ECS Role (ecsInstanceRole) 
This role is attached to the EC2 instances in the ECS cluster, granting permissions to interact with ECS and other AWS services.

#### Policies Attached:
- **Policies**:  
  - **AmazonEC2ContainerRegistryReadOnly**  
    *Grants read-only access to ECR repositories, allowing instances to pull Docker images.*
    
1. **AmazonEC2ContainerRegistryReadOnly**  
   ```json
   {
       "Version": "2012-10-17",
       "Statement": [
           {
               "Effect": "Allow",
               "Action": [
                   "ecr:GetAuthorizationToken",
                   "ecr:BatchCheckLayerAvailability",
                   "ecr:GetDownloadUrlForLayer",
                   "ecr:GetRepositoryPolicy",
                   "ecr:DescribeRepositories",
                   "ecr:ListImages",
                   "ecr:DescribeImages",
                   "ecr:BatchGetImage",
                   "ecr:GetLifecyclePolicy",
                   "ecr:GetLifecyclePolicyPreview",
                   "ecr:ListTagsForResource",
                   "ecr:DescribeImageScanFindings"
               ],
               "Resource": "*"
           }
       ]
   }
   ```  
   *Grants read-only access to ECR repositories, allowing instances to pull Docker images.*

</details>

<details>
  <summary>AmazonEC2ContainerServiceforEC2Role</summary>

  - **AmazonEC2ContainerServiceforEC2Role**  
    *Grants permissions for EC2 instances to register with ECS, pull images from ECR, and send logs to CloudWatch.*

2. **AmazonEC2ContainerServiceforEC2Role**  
   ```json
   {
       "Version": "2012-10-17",
       "Statement": [
           {
               "Effect": "Allow",
               "Action": [
                   "ec2:DescribeTags",
                   "ecs:CreateCluster",
                   "ecs:DeregisterContainerInstance",
                   "ecs:DiscoverPollEndpoint",
                   "ecs:Poll",
                   "ecs:RegisterContainerInstance",
                   "ecs:StartTelemetrySession",
                   "ecs:UpdateContainerInstancesState",
                   "ecs:Submit*",
                   "ecr:GetAuthorizationToken",
                   "ecr:BatchCheckLayerAvailability",
                   "ecr:GetDownloadUrlForLayer",
                   "ecr:BatchGetImage",
                   "logs:CreateLogStream",
                   "logs:PutLogEvents"
               ],
               "Resource": "*"
           },
           {
               "Effect": "Allow",
               "Action": "ecs:TagResource",
               "Resource": "*",
               "Condition": {
                   "StringEquals": {
                       "ecs:CreateAction": [
                           "CreateCluster",
                           "RegisterContainerInstance"
                       ]
                   }
               }
           }
       ]
   }
   ```  
   *Grants permissions for EC2 instances to register with ECS, pull images from ECR, and send logs to CloudWatch.*

---

</details>





---

## Environment created by Auto Scaling Group (ASG) while configuring ECS Cluster Configuration (By Default)

### ASG Details
This ASG was automatically created with the ECS cluster.

- **ASG Name**: `Infra-ECS-Cluster-ror-cluster-98b2597e-ECSAutoScalingGroup-ncGz1sN9wURC`  
  *Unique name assigned by AWS.*

- **Desired capacity**: `1`  
  *Maintains 1 instance.*

- **Scaling limits**: `1 - 5`  
  *Can scale between 1 and 5 instances.*

- **Launch template**: `lt-02966e6de779bb634 (ECSLaunchTemplate_UV74RFdQo9l0)`  
  - **AMI**: `ami-0c1962fdaf1a23f7d`  
    *ECS-optimized Amazon Linux 2 AMI.*  
  - **Instance type**: `t3.medium`  
    *Instance type for launched instances.*  
  - **Security groups**: `sg-0a35e9086b143cac5, sg-0106a2994ff8e49aa`  
    *Controls network access to instances.*

- **Network**:  
  - **Subnets**: `ap-south-1a, ap-south-1b, ap-south-1c`  
    *Subnets for instance deployment across multiple AZs.*

- **Health checks**: `EC2 health checks`  
  *Monitors instance health.*

- **Tags**:  
  - `AmazonECSManaged`  
  - `Name: ECS Instance - ror-cluster`  
    *Labels instances for identification.*

- **Scaling policy**: `Target tracking scaling based on a custom CloudWatch metric`  
  *Adjusts instance count to maintain a target metric.*

- **Instances**:  
  - `i-07e3a4c819103b493` in `ap-south-1a`  
    *One running instance.*

- **Lifecycle Hooks**:  
  - `ecs-managed-draining-termination-hook`  
    *Manages instance termination gracefully.*

---
## Launch Template Environment created by Auto Scaling Group (ASG) while configuring ECS Cluster Configuration (By Default)

<details>
  <summary>Launch Template</summary>
  
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

</details>








