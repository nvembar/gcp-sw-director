provider "google" {
# Assumes you've set the appropriate environment variables
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

data "google_organization" "org" {
    organization = "${var.org_id}"
}

resource "google_project" "sw_project" {
    name = "${var.project_name}"
    project_id = "nv-sw-swhost-project"
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
