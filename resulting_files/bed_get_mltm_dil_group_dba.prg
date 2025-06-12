CREATE PROGRAM bed_get_mltm_dil_group:dba
 FREE SET reply
 RECORD reply(
   1 dil_exist_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 display = vc
   1 code_value = f8
 )
 SET reply->status_data.status = "F"
 DECLARE powerchart_application_num = i4 WITH protect
 SET powerchart_application_num = 600005
 SELECT INTO "nl:"
  FROM v500_event_set_code v
  WHERE v.event_set_name_key="DILUENTS"
   AND trim(cnvtupper(v.event_set_name))="DILUENTS"
  DETAIL
   reply->dil_exist_ind = 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM v500_event_set_code ves
  PLAN (ves
   WHERE trim(cnvtupper(ves.event_set_cd_disp))=trim(cnvtupper(request->event_set_name)))
  DETAIL
   reply->display = request->event_set_name, reply->code_value = ves.event_set_cd
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
