# ROR API — staging Terraform
This directory is the Terraform root for **staging only**.
A change here should queue a run on `ror/ror-services-api-staging` and nowhere else. If shared, development, production, or the old combined workspace also run, the trigger patterns are wrong.
