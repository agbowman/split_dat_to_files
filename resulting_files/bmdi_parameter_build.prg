CREATE PROGRAM bmdi_parameter_build
 CALL video(rbw)
 CALL text(14,2,"Please wait...")
 SELECT
  service_resource = uar_get_code_display(bdp.device_cd), event_cd = uar_get_code_display(bdp
   .event_cd), bdp.parameter_alias,
  result_type = uar_get_code_display(bdp.result_type_cd)
  FROM bmdi_device_parameter bdp
  WHERE bdp.active_ind=1
  ORDER BY service_resource, event_cd
  WITH nocounter
 ;end select
END GO
