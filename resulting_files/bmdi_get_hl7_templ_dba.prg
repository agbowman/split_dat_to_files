CREATE PROGRAM bmdi_get_hl7_templ:dba
 RECORD reply(
   1 service_resource_cd = f8
   1 map_fields[*]
     2 segment_cd = f8
     2 segment_disp = c40
     2 segment_desc = c60
     2 segment_mean = c12
     2 field = i4
     2 component = i4
     2 component_typ_cd = f8
     2 component_typ_disp = c40
     2 component_typ_desc = c60
     2 component_typ_mean = c12
     2 max_len = i4
     2 result_set_pos = i4
     2 required_ind = i2
     2 common_ind = i2
     2 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM device_hl7_map dhm
  PLAN (dhm
   WHERE (dhm.device_cd=request->service_resource_cd)
    AND dhm.active_ind=1)
  ORDER BY dhm.component_order
  HEAD REPORT
   count = 0, reply->service_resource_cd = dhm.device_cd,
   CALL echo("1 starting alterlist add"),
   stat = alterlist(reply->map_fields,10),
   CALL echo("1 finished alterlist add")
  DETAIL
   count = (count+ 1)
   IF (mod(count,10)=1
    AND count != 1)
    CALL echo("starting alterlist add"), stat = alterlist(reply->map_fields,(count+ 9)),
    CALL echo("finished alterlist add")
   ENDIF
   reply->map_fields[count].segment_cd = dhm.segment_cd, reply->map_fields[count].segment_disp =
   uar_get_code_display(dhm.segment_cd), reply->map_fields[count].segment_desc =
   uar_get_code_description(dhm.segment_cd),
   reply->map_fields[count].segment_mean = uar_get_code_meaning(dhm.segment_cd), reply->map_fields[
   count].field = dhm.field_position, reply->map_fields[count].component = dhm.component_position,
   reply->map_fields[count].component_typ_cd = dhm.component_cd, reply->map_fields[count].
   component_typ_disp = uar_get_code_display(dhm.component_cd), reply->map_fields[count].
   component_typ_desc = uar_get_code_description(dhm.component_cd),
   reply->map_fields[count].component_typ_mean = uar_get_code_meaning(dhm.component_cd), reply->
   map_fields[count].max_len = dhm.max_length, reply->map_fields[count].result_set_pos = dhm
   .result_set_position,
   reply->map_fields[count].required_ind = dhm.required_ind, reply->map_fields[count].common_ind =
   dhm.common_ind, reply->map_fields[count].active_ind = dhm.active_ind
  FOOT REPORT
   stat = alterlist(reply->map_fields,count)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ENDIF
 CALL echo(build("return status is",reply->status_data.status))
END GO
