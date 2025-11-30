# Architecture Documentation

## AWS ECS Fargate (Reference Implementation)

**Note:** This AWS architecture is kept as a reference. The actual deployment encountered AWS account restrictions (ALB blocked, vCPU quota = 1) and was migrated to Azure.

### Components:
- **VPC**: Single VPC per env with public subnets for demo.
- **ALB**: Public facing; routes traffic to ECS Fargate service target group.
- **ECS Fargate**: Service running single task revision (container from ECR).
- **ECR**: Private image registry with lifecycle policy.
- **Postgres (postgres-lite)**: Single EC2 instance with systemd-managed postgres for demo.
- **State**: S3 backend + DynamoDB lock; state bucket encrypted with KMS.
- **Secrets**: AWS Secrets Manager for DB credentials; KMS for encryption.
- **Observability**: CloudWatch metrics, logs, dashboards, and alarms.

---

## Azure Container Apps (Primary Implementation)

**Current working architecture** deployed on Azure using Container Apps (serverless, no VM quota required).

### Infrastructure Components:

#### **Azure Resource Group**
- **Name**: `rg-infra-project-dev`
- **Location**: East US
- **Purpose**: Logical container for all project resources
- **Created by**: Terraform Apply workflow

#### **Azure Container Registry (ACR)**
- **Name**: `infraacrdev`
- **SKU**: Basic
- **Admin Access**: Disabled (uses managed identity for authentication)
- **Purpose**: Stores Docker container images
- **Image Format**: `infraacrdev.azurecr.io/infra-project-dev-app:latest`

#### **Container App Environment**
- **Name**: `infra-project-dev-env`
- **Type**: Serverless platform
- **Purpose**: Hosts and manages Container Apps
- **Features**: Auto-scaling, load balancing, networking
- **Integration**: Connected to Log Analytics Workspace for observability

#### **Container App**
- **Name**: `infra-project-dev-app`
- **Runtime**: Node.js 20 (Alpine Linux)
- **Resources**: 
  - CPU: 0.25 cores
  - Memory: 0.5 GiB
  - Replicas: 1 (min/max)
- **Port**: 8080 (HTTP)
- **Ingress**: External (public internet access)
- **Image Source**: Pulls from ACR using managed identity
- **Health Check**: `/health` endpoint

#### **User-Assigned Managed Identity**
- **Name**: `infra-project-dev-container-app-identity`
- **Role**: AcrPull on ACR
- **Purpose**: Secure authentication to ACR without passwords/keys
- **Used by**: Container App for image pulls

#### **Log Analytics Workspace**
- **Name**: `infra-project-dev-logs`
- **SKU**: PerGB2018 (pay-per-use)
- **Retention**: 30 days
- **Purpose**: Centralized logging and monitoring
- **Data Sources**: 
  - Container App logs
  - Container App Environment logs
  - Application metrics

#### **Azure Storage (Terraform Backend)**
- **Name**: `tfstatebkdev7faa6`
- **Container**: `tfstate`
- **Key**: `infra-project/dev/terraform.tfstate`
- **Encryption**: Encrypted at rest
- **Purpose**: Remote Terraform state storage with locking

---

### CI/CD Pipeline (GitHub Actions):

#### **1. Terraform Plan Workflow**
- **Trigger**: Pull Request to `main` or `dev` branches
- **Steps**:
  - `terraform fmt` (formatting check)
  - `terraform validate` (syntax validation)
  - `tflint` (Terraform linting)
  - `tfsec` (security scanning)
  - `conftest` (policy-as-code validation)
  - `terraform plan` (infrastructure plan generation)
- **Outputs**:
  - Plan file (`plan.tfplan`)
  - Human-readable plan (`plan.txt`)
  - Plan JSON (for policy validation)
- **Actions**:
  - Posts plan as PR comment
  - Uploads plan artifacts
  - Reads/Writes Terraform state from Azure Storage

#### **2. Terraform Apply Workflow**
- **Trigger**: Manual workflow dispatch
- **Steps**:
  - `terraform init` (initialize backend)
  - `terraform plan` (generate fresh plan)
  - `terraform apply` (apply infrastructure changes)
- **Actions**:
  - Creates/Updates Azure resources in `rg-infra-project-dev`
  - Reads/Writes Terraform state from Azure Storage
  - Requires explicit approval (manual trigger)

#### **3. Image Build & Push Workflow**
- **Trigger**: Push to `main` or `dev` branches
- **Steps**:
  - `docker build` (build image from Dockerfile)
  - `trivy scan` (vulnerability scanning - fails on CRITICAL/HIGH only)
  - `trivy sbom` (generate Software Bill of Materials in CycloneDX format)
  - `docker push` (push to ACR)
- **Actions**:
  - Builds image: `infraacrdev.azurecr.io/infra-project-dev-app:latest`
  - Scans for vulnerabilities before push
  - Generates SBOM artifact
  - Pushes to ACR
  - **Note**: Container App automatically detects new images and creates new revisions

---

### Data Flow:

#### **Infrastructure Provisioning Flow:**
```
GitHub PR → Terraform Plan → Validate/Scan → Plan Comment
GitHub Manual → Terraform Apply → Create/Update Resources → State in Azure Storage
```

#### **Application Deployment Flow:**
```
Code Push → Image Build → Trivy Scan → SBOM Generation → Push to ACR
ACR Image Update → Container App Auto-Detection → New Revision Created
```

#### **Runtime Flow:**
```
Internet Users → HTTP :8080 → Container App (External Ingress)
Container App → Pulls Image from ACR (via Managed Identity)
Container App → Sends Logs/Metrics → Log Analytics Workspace
```

#### **Authentication Flow:**
```
Container App → Uses Managed Identity → AcrPull Role on ACR → Pulls Images
(No passwords or keys required)
```

---

### Key Architectural Decisions:

1. **Container Apps over App Service Plan**: 
   - Serverless (no VM quota required)
   - Consumption-based pricing with free tier
   - Modern platform designed for containers

2. **Managed Identity over Admin Keys**:
   - ACR admin access disabled
   - User-assigned managed identity with AcrPull role
   - No secrets to manage or rotate

3. **Log Analytics Integration**:
   - Container App Environment automatically sends logs
   - Centralized observability
   - 30-day retention for cost control

4. **GitHub Actions for CI/CD**:
   - Plan on PRs (validation before merge)
   - Manual apply (prevents accidental changes)
   - Automated image build/push on code changes

5. **Security Scanning**:
   - Trivy scans images before push
   - Only fails on CRITICAL/HIGH severity
   - SBOM generation for compliance

---

### Network Architecture:

- **Ingress**: External (public internet) on port 8080
- **Egress**: Container App can access:
  - ACR (for image pulls)
  - Log Analytics (for logging)
  - Internet (for outbound connections if needed)
- **Future Enhancement**: Can be configured for internal-only access via Container App Environment settings

---

### Monitoring & Observability:

- **Logs**: Automatically collected in Log Analytics Workspace
- **Metrics**: Container App metrics (CPU, memory, request count, latency) via Azure Monitor
- **Health Checks**: `/health` endpoint for application health
- **Future Enhancement**: Application Insights for distributed tracing

---

### Cost Optimization:

- **Container Apps**: Consumption-based (free tier: 180K vCPU seconds, 360K GiB seconds, 2M requests/month)
- **ACR**: Basic SKU (cost-effective for dev)
- **Log Analytics**: PerGB2018 (pay only for data ingested)
- **Storage**: Minimal cost for Terraform state

---

*Last updated: After Container Apps migration and full implementation*
