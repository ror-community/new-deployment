# ROR API — shared Terraform
This directory is the Terraform root for **account-wide API shared resources** only. Right now that is one object: the Cloud Map private DNS namespace.
A change here should queue a run on `ror/ror-services-api-shared` and nowhere else. If development, staging, production, or the old combined workspace also run, the trigger patterns are wrong.
