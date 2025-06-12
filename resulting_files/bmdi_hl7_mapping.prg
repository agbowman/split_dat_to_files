CREATE PROGRAM bmdi_hl7_mapping
 CALL video(rbw)
 CALL text(14,2,"Please wait...")
 SELECT
  service_resource = uar_get_code_display(dhm.device_cd), segment = uar_get_code_meaning(dhm
   .segment_cd), field = dhm.field_position,
  sub_field = dhm.component_position, component = uar_get_code_display(dhm.component_cd), dhm
  .required_ind,
  dhm.common_ind, dhm.result_set_position, dhm.component_order
  FROM device_hl7_map dhm
  WHERE dhm.active_ind=1
  ORDER BY service_resource, segment, field,
   sub_field
  WITH nocounter
 ;end select
END GO
