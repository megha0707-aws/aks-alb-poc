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
      "alb.networking.azure.io/alb-id" = "/subscriptions/91ea5a42-5e9b-4c0c-a766-ea2a2aaa3ace/resourceGroups/rg-alb-poc/providers/Microsoft.ServiceNetworking/trafficControllers/alb-poc"
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