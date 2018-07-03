resource "google_project_iam_custom_role" "sw-runner-role" {
    role_id = "sw-runner-role"
    title = "Static Website Runner"
    description = "A role with limited access to manage a static website"
    # Way more permissive than needed
    permissions = [ "roles/storage.admin", "roles/compute.instanceAdmin.v1" ]
}

resource "google_service_account" "runner_acct" {
    account_id = "com-nv-sw-runner-acct"
    display_name = "Static Website Runner Account"
}

data "google_iam_policy" "sw-runner-policy" {
    binding {
        role = "sw-runner-role"
        members = [ "${resource.google_service_account.runner_acct.name}", ]
    }
}
