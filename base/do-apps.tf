# Provides a DigitalOcean App resource.
# Docs: https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/app
#
resource "digitalocean_app" "soursa-addon-test" {

  spec {
    # The name of the app. Must be unique across all apps in the same account.
    name   = "soursa-addon-test"
    region = "ams" # Amsterdam
    # domain {
    #   # The hostname for the domain.
    #   name = "soursa.ondigitalocean.app"
    #   # The domain type
    #   type = "DEFAULT" # The default .ondigitalocean.app domain assigned to this app.
    # }

    # Describes an alert policy for the app.
    alert {
      rule = "DEPLOYMENT_FAILED"
    }

    # Backend service
    service {
      # The name of the component
      name = "backend"

      # An environment slug describing the type of this app.
      # environment_slug = "backend"

      # The amount of instances that this component should be scaled to.
      instance_count = 1

      # The instance size to use for this component.
      # This determines the plan (basic or professional) and the available CPU and memory.
      # The list of available instance sizes can be found with the API
      #   or using the doctl CLI (doctl apps tier instance-size list).
      instance_size_slug = "basic-xxs"

      # A list of ports on which this service will listen for internal traffic.
      internal_ports = [3000]

      # A Git repo to use as the component's source.
      git {
        repo_clone_url = format("https://%s@bitbucket.org/soursa/soursa_backend.git", var.GIT_CREDS)
        branch = "main"
      }

      # An optional build command to run while building this component from source.
      build_command = "yarn build"

      # An optional run command to override the component's default.
      run_command = "yarn run start"
    }

    # Postgresql database
    database {
      # The name of the component
      name = "soursa-db"

      # The database engine to use (MYSQL, PG, REDIS, or MONGODB).
      engine = "PG"

      # Whether this is a production or dev database.
      production = false

      # The name of the underlying DigitalOcean DBaaS cluster.
      # This is required for production databases.
      # For dev databases, if cluster_name is not set, a new cluster will be provisioned.
      cluster_name = "soursa"

      # The name of the MySQL or PostgreSQL database to configure.
      db_name = "soursa"

      # The name of the MySQL or PostgreSQL user to configure.
      db_user = "soursa"
    }

  }
}
