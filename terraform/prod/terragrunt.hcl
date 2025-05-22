terraform {
  source = "../modules"
}

inputs = {
  project   = "gcp-project-in-use"
  region    = "europe-west3"
  stage     = "prod"
  namespace = "prod"
}

