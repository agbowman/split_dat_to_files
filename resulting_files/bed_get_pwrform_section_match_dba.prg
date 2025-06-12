CREATE PROGRAM bed_get_pwrform_section_match:dba
 FREE SET reply
 RECORD reply(
   1 section_uid = vc
   1 description = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM cnt_section_key2 sk
  PLAN (sk
   WHERE (sk.dcp_section_ref_id=request->dcp_section_ref_id))
  DETAIL
   reply->section_uid = sk.section_uid, reply->description = sk.section_definition
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
