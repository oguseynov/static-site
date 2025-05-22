terraform {
  source = "../modules"
}

inputs = {
  project   = "gcp-project-in-use"
  region    = "europe-west3"
  stage     = "dev"
  namespace = "dev"
}

