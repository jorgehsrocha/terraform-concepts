data "google_project" "project" {}

resource "google_cloudbuild_trigger" "example_trigger" {
    name = "example-trigger"
    filename = "cloudbuild.yaml"
    service_account = google_service_account.cloudbuild_service_account.id

    trigger_template {
        project_id = var.gcp_project_id
        branch_name = var.branch
        repo_name = var.repo_name
    }

    substitutions = {
        _XYZ = "abc"
    }

    source_to_build {
        uri = var.repo_url
        repo_type = var.repo_provider
        ref = var.branch
    }

    depends_on = [
        google_project_iam_member.act_as,
        google_project_iam_member.logs_writer
    ]
}

resource "google_service_account" "cloudbuild_service_account" {
    account_id = var.gcp_account_id
}

resource "google_project_iam_member" "act_as" {
    project = data.google_project.project.project_id
    role = "roles/iam.serviceAccountUser"
    member = "serviceAccount:${google_service_account.cloudbuild_service_account.email}"
}

resource "google_project_iam_member" "logs_writer" {
  project = var.gcp_project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.cloudbuild_service_account.email}"
}