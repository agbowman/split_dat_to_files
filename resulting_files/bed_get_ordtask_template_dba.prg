CREATE PROGRAM bed_get_ordtask_template:dba
 FREE SET reply
 RECORD reply(
   1 template_ind = i2
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
  FROM tl_quick_build_params t
  PLAN (t
   WHERE (t.catalog_type_cd=request->catalog_type_code_value)
    AND (t.activity_type_cd=request->activity_type_code_value))
  DETAIL
   reply->template_ind = 1
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
