terraform {
    backend "gcs" {
        bucket  = "infra-lab-tfstate-snotmax123"
        prefix  = "envs/default"
    }
}