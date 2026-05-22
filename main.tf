resource "kubernetes_namespace" "alb" {
  metadata {
    name = "azure-alb-system"
  }
}

resource "helm_release" "alb_controller" {
  name       = "alb-controller"
  namespace  = kubernetes_namespace.alb.metadata[0].name
  repository = "oci://mcr.microsoft.com/application-lb/charts"
  chart      = "alb-controller"
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