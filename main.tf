resource "kubernetes_deployment" "nginx" {
  metadata {
    name = "sample-web"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "sample-web"
      }
    }

    template {
      metadata {
        labels = {
          app = "sample-web"
        }
      }

      spec {
        container {
          name  = "nginx"
          image = "nginx"

          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "nginx" {
  metadata {
    name = "sample-web-service"
  }

  spec {
    selector = {
      app = "sample-web"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_manifest" "gateway" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "Gateway"
    metadata = {
      name      = "sample-gateway"
      namespace = "default"
      annotations = {
        "alb.networking.azure.io/alb-id"         = "/subscriptions/91ea5a42-5e9b-4c0c-a766-ea2a2aaa3ace/resourceGroups/rg-alb-poc/providers/Microsoft.ServiceNetworking/trafficControllers/alb-poc"
        "alb.networking.azure.io/frontend-name" = "public-frontend"
      }
    }

    spec = {
      gatewayClassName = "azure-alb-external"

      listeners = [
        {
          name     = "http"
          port     = 80
          protocol = "HTTP"
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "httproute" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"
    metadata = {
      name      = "sample-route"
      namespace = "default"
    }

    spec = {
      parentRefs = [
        {
          name = "sample-gateway"
        }
      ]

      rules = [
        {
          matches = [
            {
              path = {
                type  = "PathPrefix"
                value = "/"
              }
            }
          ]

          backendRefs = [
            {
              name = "sample-web-service"
              port = 80
            }
          ]
        }
      ]
    }
  }
}