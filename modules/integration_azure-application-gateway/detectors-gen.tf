resource "signalfx_detector" "capacity_units" {
  name = format("%s %s", local.detector_name_prefix, "Azure Application Gateway capacity units")

  program_text = <<-EOF
    base_filtering = filter('resource_type', 'Microsoft.Network/applicationGateways') and filter('primary_aggregation_type', 'true')
    signal = data('CapacityUnits', filter=base_filtering and ${module.filter-tags.filter_custom})${var.capacity_units_aggregation_function}${var.capacity_units_transformation_function}.publish('signal')
    detect(when(signal > ${var.capacity_units_threshold_major})).publish('MAJOR')
EOF

  rule {
    description           = "is too high > ${var.capacity_units_threshold_major}"
    severity              = "Major"
    detect_label          = "MAJOR"
    disabled              = coalesce(var.capacity_units_disabled, var.detectors_disabled)
    notifications         = coalescelist(lookup(var.capacity_units_notifications, "major", []), var.notifications.major)
    parameterized_subject = local.rule_subject
    parameterized_body    = local.rule_body
  }
}

