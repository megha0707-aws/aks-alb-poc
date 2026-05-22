resource "azurerm_resource_group" "alb_rg" {
  name     = "rg-alb-poc"
  location = "East US"
}

resource "azurerm_application_load_balancer" "alb" {
  name                = "alb-poc"
  resource_group_name = azurerm_resource_group.alb_rg.name
  location            = azurerm_resource_group.alb_rg.location
}

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

resource "kubernetes_ingress_v1" "nginx_ingress" {
  metadata {
    name = "sample-web-ingress"

    annotations = {
      "alb.networking.azure.io/alb-id" = azurerm_application_load_balancer.alb.id
    }
  }

  spec {
    ingress_class_name = "azure-alb-external"

    rule {
      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service.nginx.metadata[0].name

              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}