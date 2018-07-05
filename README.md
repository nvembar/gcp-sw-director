# Static website hosting on GCP

## What does this do

This houses Terraform scripts which will create a static website hosted on Google Storage.

It uses an organization-wide bootstrapper to create inidividual projects per website and sets up the configuration of the static website on a per project level. 
It constructs individual directories with the Terraform plans for each project with the `projects/` directory, which is not checked into this repository (though it could be later on).

* The service account that runs this should have a custom role tied to the organization that allows it to create projects.
* The project that houses the service account should have the GCloud API turned on.

### To-Do

* Create a resource file or a Terraform file to create that organization, custom role, and project using the `gcloud` command line
* 
