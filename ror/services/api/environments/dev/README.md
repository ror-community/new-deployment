# ROR API — development Terraform
This directory is the Terraform root for **development only**.
A change here should queue a run on `ror/ror-services-api-dev` and nowhere else. If shared, staging, prod, or the old combined workspace also run, the trigger patterns are wrong.