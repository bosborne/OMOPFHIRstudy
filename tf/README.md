# Terraform scripts to set up demo environment
The script in `tfuser` creates an IAM user with limited permissions
which account is then used by the scripts in `tfmain` to create an RDS 
PostgreSQL instance and an EC2 instance.

The scripts make use of AWS Secrets Manager. A secret containing the
PostgreSQL username and password must be created and the ARN for this
secret added to `tfuser/user.tf` and the name of the secret added to
`tfmain/main.tf`. 

