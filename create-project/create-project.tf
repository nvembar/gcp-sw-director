provider "google" {
# Assumes you've set the appropriate environment variables
}

# This is a string that will get prepended to certain IDs to help ensure uniqueness
variable "slug" {
    type = "string"
    default = "nvtrial"
}

variable "org_id" {
    type = "string"
}

variable "project_name" {
    type = "string"
}

variable "project_id" {
    type = "string"
}

variable "domain" {
    type = "string"
}

variable "subdomain" {
    type = "string"
}

data "google_organization" "org" {
    organization = "${var.org_id}"
}

resource "google_project" "sw_project" {
    name = "${var.project_name}"
    project_id = "${var.slug}-${var.project_id}"
    org_id = "${data.google_organization.org.id}"
}

resource "google_service_account" "sw_service_account" {
    account_id = "${var.project_id}-runner"
    display_name = "${var.project_name} Runner"
    project = "${google_project.sw_project.project_id}"
}

resource "google_service_account_iam_binding" "sw_sa_binding" {
    service_account_id = "${google_service_account.sw_service_account.unique_id}"
    role = "roles/storage.admin"
    members = [
        "serviceAccount:${google_service_account.sw_service_account.email}"
    ]
}

resource "google_storage_bucket" "website_bucket" {
    project = "${google_project.sw_project.project_id}"
    name = "${var.subdomain}.${var.domain}"
    website {
        main_page_suffix = "index.html"
    }
}

resource "google_storage_bucket_acl" "website_public_acl" {
    bucket = "${google_storage_bucket.website_bucket.name}"
    predefined_acl = "publicRead"
}

output "project" {
    value = "${google_project.sw_project.project_id}"
}
