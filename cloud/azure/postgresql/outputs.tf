output "cpu_usage" {
  description = "Detector resource for cpu_usage"
  value       = signalfx_detector.cpu_usage
}

output "free_storage" {
  description = "Detector resource for free_storage"
  value       = signalfx_detector.free_storage
}

output "heartbeat" {
  description = "Detector resource for heartbeat"
  value       = signalfx_detector.heartbeat
}

output "io_consumption" {
  description = "Detector resource for io_consumption"
  value       = signalfx_detector.io_consumption
}

output "memory_usage" {
  description = "Detector resource for memory_usage"
  value       = signalfx_detector.memory_usage
}

output "no_connection" {
  description = "Detector resource for no_connection"
  value       = signalfx_detector.no_connection
}

output "serverlog_free_storage" {
  description = "Detector resource for serverlog_free_storage"
  value       = signalfx_detector.serverlog_free_storage
}

