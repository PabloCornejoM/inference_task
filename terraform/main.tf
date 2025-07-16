/**
 * Terraform configuration for model inference service on GCP
 * 
 * This configuration creates:
 * - Google Artifact Registry repository
 * - Cloud Run service
 * - IAM roles and service accounts
 * - Monitoring and alerting
 */

terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# Variables
variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "us-central1"
}

variable "service_name" {
  description = "Name of the Cloud Run service"
  type        = string
  default     = "model-inference-api"
}

variable "image_tag" {
  description = "Docker image tag"
  type        = string
  default     = "latest"
}

# Provider configuration
provider "google" {
  project = var.project_id
  region  = var.region
}

# Enable required APIs
resource "google_project_service" "required_apis" {
  for_each = toset([
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com"
  ])
  
  service = each.value
  project = var.project_id
  
  disable_on_destroy = false
}

# Artifact Registry repository
resource "google_artifact_registry_repository" "model_repo" {
  location      = var.region
  repository_id = var.service_name
  description   = "Docker repository for ML model inference service"
  format        = "DOCKER"
  
  depends_on = [google_project_service.required_apis]
}

# Service account for Cloud Run
resource "google_service_account" "cloud_run_sa" {
  account_id   = "${var.service_name}-sa"
  display_name = "Service Account for ${var.service_name}"
  description  = "Service account used by Cloud Run service"
}

# IAM binding for service account
resource "google_project_iam_member" "cloud_run_sa_roles" {
  for_each = toset([
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/cloudtrace.agent"
  ])
  
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}

# Cloud Run service
resource "google_cloud_run_service" "model_service" {
  name     = var.service_name
  location = var.region
  
  template {
    spec {
      service_account_name = google_service_account.cloud_run_sa.email
      
      containers {
        image = "${var.region}-docker.pkg.dev/${var.project_id}/${var.service_name}/${var.service_name}:${var.image_tag}"
        
        ports {
          container_port = 8080
        }
        
        env {
          name  = "PORT"
          value = "8080"
        }
        
        resources {
          limits = {
            cpu    = "1000m"
            memory = "2Gi"
          }
        }
        
        liveness_probe {
          http_get {
            path = "/health"
            port = 8080
          }
          initial_delay_seconds = 30
          period_seconds        = 10
          timeout_seconds       = 5
          failure_threshold     = 3
        }
        
        startup_probe {
          http_get {
            path = "/health"
            port = 8080
          }
          initial_delay_seconds = 10
          period_seconds        = 5
          timeout_seconds       = 3
          failure_threshold     = 10
        }
      }
    }
    
    metadata {
      annotations = {
        "autoscaling.knative.dev/minScale"         = "0"
        "autoscaling.knative.dev/maxScale"         = "10"
        "run.googleapis.com/cpu-throttling"        = "false"
        "run.googleapis.com/execution-environment" = "gen2"
      }
    }
  }
  
  traffic {
    percent         = 100
    latest_revision = true
  }
  
  depends_on = [
    google_project_service.required_apis,
    google_artifact_registry_repository.model_repo
  ]
}

# IAM policy for public access
resource "google_cloud_run_service_iam_member" "public_access" {
  location = google_cloud_run_service.model_service.location
  project  = google_cloud_run_service.model_service.project
  service  = google_cloud_run_service.model_service.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# Monitoring - Uptime check
resource "google_monitoring_uptime_check_config" "service_uptime" {
  display_name = "${var.service_name}-uptime-check"
  timeout      = "10s"
  period       = "60s"
  
  http_check {
    path         = "/health"
    port         = "443"
    use_ssl      = true
    validate_ssl = true
  }
  
  monitored_resource {
    type = "uptime_url"
    labels = {
      project_id = var.project_id
      host       = google_cloud_run_service.model_service.status[0].url
    }
  }
  
  depends_on = [google_cloud_run_service.model_service]
}

# Monitoring - Alert policy for service availability
resource "google_monitoring_alert_policy" "service_availability" {
  display_name = "${var.service_name}-availability-alert"
  combiner     = "OR"
  
  conditions {
    display_name = "Service is down"
    
    condition_threshold {
      filter          = "metric.type=\"monitoring.googleapis.com/uptime_check/check_passed\" AND resource.type=\"uptime_url\""
      duration        = "300s"
      comparison      = "COMPARISON_EQUAL"
      threshold_value = 0
      
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_NEXT_OLDER"
      }
    }
  }
  
  notification_channels = []
  
  depends_on = [google_monitoring_uptime_check_config.service_uptime]
}

# Outputs
output "service_url" {
  description = "URL of the deployed Cloud Run service"
  value       = google_cloud_run_service.model_service.status[0].url
}

output "artifact_registry_url" {
  description = "URL of the Artifact Registry repository"
  value       = google_artifact_registry_repository.model_repo.name
}

output "service_account_email" {
  description = "Email of the service account"
  value       = google_service_account.cloud_run_sa.email
} 