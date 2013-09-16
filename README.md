ec2ssh
======

a helper gem for ssh'ing into EC2 instances


Usage Examples
--------

`./ec2ssh ssh_aliases -k XXXXXXXX -s XXXXXXXX -r "us-west-2" -f "test" -u ubuntu -i ~/.ssh/key.pem -p 2200 --shortnames`
`./ec2ssh ssh_config -k XXXXXXXX -s XXXXXXXX -r "us-west-2" -f "production" -u ubuntu -i ~/.ssh/key.pem -p 2200 --shortnames`
`./ec2ssh ssh -k XXXXXXXX -s XXXXXXXX -r "us-west-2" -u ubuntu -i ~/.ssh/key.pem -p 2200 production-cache-1 'df -h'`
