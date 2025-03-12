stack {
  name = "terraform-infra"

  component "cluster" {
    source = "./cluster"
  }

  component "content" {
    source = "./content"
    depends_on = ["component.cluster"]
  }
}