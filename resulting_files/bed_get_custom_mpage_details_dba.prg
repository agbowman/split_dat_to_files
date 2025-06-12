CREATE PROGRAM bed_get_custom_mpage_details:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 components[*]
      2 id = f8
      2 display = vc
      2 mean = vc
      2 status_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE error_flag = vc
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET ccnt = 0
 SELECT INTO "nl:"
  FROM br_datamart_report r,
   br_datamart_value v
  PLAN (r
   WHERE (r.br_datamart_category_id=request->view_id))
   JOIN (v
   WHERE v.parent_entity_name="BR_DATAMART_REPORT"
    AND v.parent_entity_id=r.br_datamart_report_id
    AND v.mpage_param_mean="mp_vb_component_status")
  ORDER BY r.report_name
  DETAIL
   ccnt = (ccnt+ 1), stat = alterlist(reply->components,ccnt), reply->components[ccnt].id = r
   .br_datamart_report_id,
   reply->components[ccnt].display = r.report_name, reply->components[ccnt].mean = r.report_mean
   IF (isnumeric(v.mpage_param_value))
    reply->components[ccnt].status_ind = cnvtint(v.mpage_param_value)
   ENDIF
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
