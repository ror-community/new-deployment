# Overview of ROR Technical Infrastructure

The ROR technical infrastructure is hosted with Amazon Web Services (AWS). Some services are global, all infrastructure hosted in a particular region is in AWS EU-West-1 (Ireland).

ROR uses a standard architecture with the following major components:
1. Virtual Private Cloud (VPC) with a public and private subnet.
1. All application servers, databases and file storage are hosted in the private subnet, not directly accessible from the internet.
1. The public subnet connects the private subnet to the internet via application load balancers (ALB), a content delivery network (CDN, Cloudfront) and bastion host (SSH access for staff) for incoming traffic. ALB and CDN provide SSL termination, ROR services are only accessible via https. 
1. Our VPC hosts a production, staging and dev environment. Every resource in the production system is duplicated for high availability, in different AWS zones if possible (e.g. for databases).
1. The AWS infrastructure is managed by the Terraform service, which treats infrastructure as code. All configurations are stored in a (public) GitHub repository, and configuration changes in that repository trigger automatically trigger the intended changes in our infrastructure.
1. For service monitoring, we mainly rely on AWS Cloudwatch.
1. The Elasticsearch search engine run as services managed by AWS.
1. All compute resources run as Docker containers, with one small virtual machine (EC2) left for a special purpose (bastion host). The Docker containers are orchestrated (managed) by the AWS ECS Fargate service.
1. All static pages (i.e. homepage, search frontend) are stored in the Amazon file service (S3) and accessed via a content delivery network (CDN, Cloudfront) with multiple edge locations worldwide.
1. All data are stored in file storage, in addition to the version control in GitHub.

![Infrastructure Diagram](https://github.com/ror-community/new-deployment/blob/master/ror/architecture-diagram.png)
