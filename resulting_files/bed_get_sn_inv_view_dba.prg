CREATE PROGRAM bed_get_sn_inv_view:dba
 FREE SET reply
 RECORD reply(
   1 view_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET reply->view_ind = 0
 SELECT INTO "nl:"
  FROM location_group lg,
   code_value cv
  PLAN (lg
   WHERE lg.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=lg.location_group_type_cd
    AND cv.code_set=222
    AND cv.cdf_meaning="INVVIEW")
  DETAIL
   reply->view_ind = 1
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
