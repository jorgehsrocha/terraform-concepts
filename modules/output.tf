output "trigger_name" {
    value = google_cloudbuild_trigger.example_trigger.name
}

output "trigger_id" {
  value = google_cloudbuild_trigger.example_trigger.id
}

output "trigger_project" {
  value = google_cloudbuild_trigger.example_trigger.project
}