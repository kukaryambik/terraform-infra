stack {
  name = "my-infrastructure"

  component "cluster" {
    source = "./cluster"
  }

  component "content" {
    source = "./content"
    depends_on = ["component.cluster"]
  }
}