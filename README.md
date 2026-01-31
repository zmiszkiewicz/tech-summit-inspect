# Tech Summit Security Lab — NIOS-X Infrastructure

Terraform and Python scripts for the **Tech Summit Security** Instruqt lab. Deploys a security-focused environment in AWS with Infoblox NIOS-X servers, a Windows Client, and an Ubuntu workstation.

## Architecture

```
VPC: 10.100.0.0/16 (eu-central-1)
Public Subnet: 10.100.0.0/24

10.100.0.110  →  Windows Client      (t3.medium, Windows Server 2022)
10.100.0.130  →  Ubuntu Workstation   (t3.small, Ubuntu 22.04)
10.100.0.200  →  NIOS-X Server #1    (m5.2xlarge, AMI-based)
10.100.0.201  →  NIOS-X Server #2    (m5.2xlarge, AMI-based)
```

## Repository Structure

```
terraform/
├── providers.tf         # AWS provider
├── variables.tf         # Region, VPC CIDR, admin password, join tokens
├── main.tf              # VPC, subnet, IGW, SGs, Windows Client, Ubuntu EC2
├── niosx.tf             # 2x NIOS-X EC2 instances with cloud-init join tokens
├── outputs.tf           # Public IPs and SSH commands
└── scripts/
    ├── sandbox_api.py                 # CSP sandbox API client
    ├── create_sandbox.py              # Create Infoblox CSP sandbox
    ├── create_user.py                 # Create CSP user
    ├── deploy_api_key.py              # Generate and export API key
    ├── infoblox_create_join_token.py  # Generate 2 NIOS-X join tokens
    ├── delete_sandbox.py              # Delete CSP sandbox
    ├── delete_user.py                 # Delete CSP user
    ├── setup_dns.py                   # Create DNS A record for Windows Client
    ├── cleanup_dns_records.py         # Delete Windows Client DNS record
    ├── create_dns_niosx.py            # Create DNS A records for NIOS-X servers
    ├── clean_dns_niosx.py             # Delete NIOS-X DNS records
    ├── winrm-init.ps1.tpl             # Windows user_data (WinRM + RDP setup)
    └── cloud-init.yaml                # NIOS-X cloud-init (join token activation)
```

## Required Variables

| Variable | Description |
|---|---|
| `windows_admin_password` | Windows Administrator password (sensitive) |
| `infoblox_join_token_1` | CSP join token for NIOS-X server #1 (sensitive) |
| `infoblox_join_token_2` | CSP join token for NIOS-X server #2 (sensitive) |

## Required Environment Variables (for Python scripts)

| Variable | Description |
|---|---|
| `Infoblox_Token` | CSP API token |
| `INFOBLOX_EMAIL` | CSP login email |
| `INFOBLOX_PASSWORD` | CSP login password |
| `INSTRUQT_PARTICIPANT_ID` | Instruqt participant ID |
| `INSTRUQT_EMAIL` | Participant email |
| `DEMO_AWS_ACCESS_KEY_ID` | AWS key for Route 53 DNS management |
| `DEMO_AWS_SECRET_ACCESS_KEY` | AWS secret for Route 53 DNS management |
| `DEMO_HOSTED_ZONE_ID` | Route 53 hosted zone ID |

## Usage

```bash
cd terraform/

# Run Python scripts first to create sandbox, user, API key, and join tokens
cd scripts/
python3 create_sandbox.py
python3 create_user.py
python3 deploy_api_key.py
python3 infoblox_create_join_token.py
source ~/.bashrc
cd ..

# Deploy infrastructure
terraform init
terraform apply -auto-approve

# Create DNS records
cd scripts/
python3 setup_dns.py
python3 create_dns_niosx.py
```
