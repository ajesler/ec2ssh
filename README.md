## ec2ssh

A helper gem for ssh'ing into EC2 instances. There are many gems like this that are far more powerful and easier to configure. You probably want one of them rather than this gem which was made as a short-lived experiment.  
ec2ssh can list all your AWS instances, as well as generating SSH config or alias entires to make connection easier.
Filtering hosts by regex and writing program output to a specified file are supported.

### Usage Examples

`./ec2ssh ssh_aliases -k AWS_KEY -s AWS_SECRET -r "us-west-2" -f "test" -u ubuntu -i ~/.ssh/key.pem -p 2200 --shortnames`  

`./ec2ssh ssh_config -k AWS_KEY -s AWS_SECRET -r "us-west-2" -f "test" -u ubuntu -i ~/.ssh/key.pem -p 2200 --shortnames`  


### Help Documenation 

When run with no arguments or as `ec2ssh help`, the help will be shown.  
To see the full list of options for each command, refer to [cli.rb](lib/cli.rb)
