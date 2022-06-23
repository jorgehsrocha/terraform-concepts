provider "google" {
    project = var.gcp_project_id
    region = var.gcp_region
}

module "cloudbuild" {
    source = "./modules"
    gcp_project_id = var.gcp_project_id
    branch = var.branch
    repo_name = var.repo_name
    repo_url = var.repo_url
    repo_provider = var.repo_provider
    gcp_account_id = var.gcp_account_id
    gcp_region = var.gcp_region
}