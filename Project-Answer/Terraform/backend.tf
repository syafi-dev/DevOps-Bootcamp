terraform {
  cloud {
    organization = "Inframesia"

    workspaces {
      name = "devops-bootcamp"
    }
  }
}