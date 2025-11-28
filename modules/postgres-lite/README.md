## modules/postgres-lite - demo Postgres on EC2

This module creates a **minimal, non-HA Postgres instance on EC2** for demo purposes:

- A small EC2 instance (for example, `t3.micro`) running Postgres.
- A dedicated EBS volume for Postgres data.
- A security group that allows inbound `5432` **only** from the app/ECS security group.
- A **Secrets Manager secret** containing DB connection details (username, password, host, db name).

> This is not production-grade. It has no redundancy, no automated backups, and
> a very simple configuration. It is intended only to support the demo stack.

### Inputs

- `environment` (string): Environment name (for example: `dev`, `stage`, `prod`).
- `project` (string): Project tag value (default: `infra-project`).
- `vpc_id` (string): VPC ID where the instance lives.
- `subnet_id` (string): Subnet ID for the instance.
- `app_security_group_id` (string): Security group ID used by the app/ECS tasks; only this SG can reach Postgres on 5432.
- `instance_type` (string): EC2 instance type (default: `t3.micro`).
- `ami_id` (string): AMI ID to use (for example, Amazon Linux 2 in your region).
- `db_name` (string): Demo database name (default: `appdb`).
- `db_username` (string): Demo database username (default: `appuser`).
- `data_volume_size_gb` (number): EBS data volume size in GiB (default: `20`).

### Key resources

- `aws_security_group.postgres`: restricts access to port 5432 from `app_security_group_id` only.
- `aws_ebs_volume.postgres_data` + `aws_volume_attachment.postgres_data`: dedicated data volume for Postgres.
- `aws_instance.postgres`: EC2 instance running Postgres, bootstrapped with `userdata/postgres-setup.sh`.
- `random_password.db`: generates a strong password for the DB user.
- `aws_secretsmanager_secret.db` + `aws_secretsmanager_secret_version.db`: stores connection details as a JSON secret.

### User data script

The file `userdata/postgres-setup.sh`:

- Formats and mounts `/dev/xvdb` to `/var/lib/pgsql`.
- Installs Postgres server packages.
- Initializes the database and configures it to listen on all interfaces.
- Loosens `pg_hba.conf` to allow remote connections (relying on the SG to restrict source).
- Creates the demo database and user using the generated credentials.

### Example usage (from a root stack)

```hcl
module "postgres_lite" {
  source = "../../modules/postgres-lite"

  environment          = "dev"
  project              = "infra-project"
  vpc_id               = module.vpc.vpc_id
  subnet_id            = module.vpc.public_subnet_ids[0]
  app_security_group_id = module.vpc.app_security_group_id
  instance_type        = "t3.micro"
  ami_id               = "ami-xxxxxxxx" # Amazon Linux 2 AMI in your region
  db_name              = "appdb"
  db_username          = "appuser"
}
```

### Manual DR steps (demo only)

Because this is a single EC2 instance with EBS-backed storage, disaster recovery is manual:

1. **Take a snapshot** of the data volume (`aws_ebs_volume.postgres_data`) from the AWS console or CLI before risky changes.  
2. **Restore from snapshot** by creating a new volume from the snapshot and attaching it to a replacement EC2 instance.  
3. **Update DNS / configuration** to point the app to the new Postgres instance (new private IP).  
4. **Delete old resources** (old instance and old volume) once traffic is fully cut over and verified.  


