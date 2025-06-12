CREATE PROGRAM bed_get_rad_acc_pool:dba
 FREE SET reply
 RECORD reply(
   1 accession_pool
     2 accession_assignment_pool_id = f8
     2 description = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE activity_type_cd = f8
 SET activity_type_cd = 0.0
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=106
   AND cv.cdf_meaning="RADIOLOGY"
   AND cv.active_ind=1
  DETAIL
   activity_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM accession_assign_xref ax,
   accession_assign_pool ap
  PLAN (ax
   WHERE (ax.accession_format_cd=request->accession_format_code_value)
    AND ax.activity_type_cd=activity_type_cd)
   JOIN (ap
   WHERE ap.accession_assignment_pool_id=ax.accession_assignment_pool_id)
  DETAIL
   reply->accession_pool.accession_assignment_pool_id = ap.accession_assignment_pool_id, reply->
   accession_pool.description = ap.description
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
