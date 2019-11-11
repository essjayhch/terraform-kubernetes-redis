locals {
  fullname = "${local.name}"
  chart    = "${format("%s-%s", local.name, local.version)}"

  redis_image = "${format("%s/%s:%s", var.redis_image_registry, var.redis_image_repository, var.redis_image_tag)}"

  default_resource_requests = {
    cpu    = "100m"
    memory = "256Mi"
  }

  default_resource_limits = {
    cpu    = "1000m"
    memory = "1Gi"
  }

  metrics_requests = merge(local.default_resource_requests, var.metrics_resource_requests)
  metrics_limits = merge(local.default_resource_limits, var.metrics_resource_limits)

  slave_requests = merge(local.default_resource_requests, var.slave_resource_requests)
  slave_limits   = merge(local.default_resource_limits, var.slave_resource_limits)

  master_requests = merge(local.default_resource_requests, var.master_resource_requests)
  master_limits = merge(local.default_resource_limits, var.master_resource_limits)
  metrics_image      = "${format("%s/%s:%s", var.metrics_image_registry, var.metrics_image_repository, var.metrics_image_tag)}"
  metrics_redis_addr = "${var.cluster_enabled ? format("%s-master:%s,%s-slave:%s", local.fullname, var.master_port, local.fullname, var.slave_port) : format("%s-master:%s", local.fullname, var.master_port)}"
}
