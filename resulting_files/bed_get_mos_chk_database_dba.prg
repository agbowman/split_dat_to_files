CREATE PROGRAM bed_get_mos_chk_database:dba
 FREE SET reply
 RECORD reply(
   1 multum_ind = i2
   1 activity_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM mltm_order_sent m,
   mltm_order_sent_detail d
  PLAN (m)
   JOIN (d
   WHERE d.external_identifier=m.external_identifier)
  HEAD REPORT
   reply->multum_ind = 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM br_ordsent bo,
   br_ordsent_detail bod
  PLAN (bo)
   JOIN (bod
   WHERE bod.br_ordsent_id=bo.br_ordsent_id)
  HEAD REPORT
   reply->activity_ind = 1
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
