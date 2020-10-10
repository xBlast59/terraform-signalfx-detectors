resource "signalfx_detector" "heartbeat" {
  name      = format("%s %s", local.name_start, "DNS heartbeat")
  max_delay = 900

  program_text = <<-EOF
    from signalfx.detectors.not_reporting import not_reporting
    signal = data('dns.result_code', filter=(not filter('aws_state', '{Code: 32,Name: shutting-down', '{Code: 48,Name: terminated}', '{Code: 62,Name: stopping}', '{Code: 80,Name: stopped}')) and (not filter('gcp_status', '{Code=3, Name=STOPPING}', '{Code=4, Name=TERMINATED}')) and (not filter('azure_power_state', 'PowerState/stopping', 'PowerState/stopped', 'PowerState/deallocating', 'PowerState/deallocated')) and ${module.filter-tags.filter_custom})${var.heartbeat_aggregation_function}.publish('signal')
    not_reporting.detector(stream=signal, resource_identifier=None, duration='${var.heartbeat_timeframe}').publish('CRIT')
EOF

  rule {
    description           = "has not reported in ${var.heartbeat_timeframe}"
    severity              = "Critical"
    detect_label          = "CRIT"
    disabled              = coalesce(var.heartbeat_disabled, var.detectors_disabled)
    notifications         = coalescelist(lookup(var.heartbeat_notifications, "critical", []), var.notifications.critical)
    parameterized_subject = local.subject_novalue
    parameterized_body    = local.body
  }
}

resource "signalfx_detector" "dns_query_time" {
  name = format("%s %s", local.name_start, "DNS query time")

  program_text = <<-EOF
    signal = data('dns.query_time_ms', filter=filter('plugin', 'telegraf/dns') and ${module.filter-tags.filter_custom})${var.dns_query_time_aggregation_function}${var.dns_query_time_transformation_function}.publish('signal')
    detect(when(signal > ${var.dns_query_time_threshold_critical})).publish('CRIT')
    detect(when(signal > ${var.dns_query_time_threshold_major}) and when(signal <= ${var.dns_query_time_threshold_critical})).publish('MAJOR')
EOF

  rule {
    description           = "is too high > ${var.dns_query_time_threshold_critical}"
    severity              = "Critical"
    detect_label          = "CRIT"
    disabled              = coalesce(var.dns_query_time_disabled_critical, var.dns_query_time_disabled, var.detectors_disabled)
    notifications         = coalescelist(lookup(var.dns_query_time_notifications, "critical", []), var.notifications.critical)
    parameterized_subject = local.subject
    parameterized_body    = local.body
  }

  rule {
    description           = "is too high > ${var.dns_query_time_threshold_major}"
    severity              = "Major"
    detect_label          = "MAJOR"
    disabled              = coalesce(var.dns_query_time_disabled_major, var.dns_query_time_disabled, var.detectors_disabled)
    notifications         = coalescelist(lookup(var.dns_query_time_notifications, "major", []), var.notifications.major)
    parameterized_subject = local.subject
    parameterized_body    = local.body
  }
}

resource "signalfx_detector" "dns_result_code" {
  name = format("%s %s", local.name_start, "DNS query result")

  program_text = <<-EOF
    signal = data('dns.result_code', filter=filter('plugin', 'telegraf/dns') and ${module.filter-tags.filter_custom})${var.dns_result_code_aggregation_function}${var.dns_result_code_transformation_function}.publish('signal')
    detect(when(signal > 0)).publish('CRIT')
EOF

  rule {
    description           = "is not successful"
    severity              = "Critical"
    detect_label          = "CRIT"
    disabled              = coalesce(var.dns_result_code_disabled_critical, var.dns_result_code_disabled, var.detectors_disabled)
    notifications         = coalescelist(lookup(var.dns_result_code_notifications, "critical", []), var.notifications.critical)
    parameterized_subject = local.subject
    parameterized_body    = local.body
  }

}
