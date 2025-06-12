CREATE PROGRAM cs_get_dup_flags:dba
 RECORD reply(
   1 display_dup_ind = i2
   1 display_key_dup_ind = i2
   1 cdf_meaning_dup_ind = i2
   1 active_ind_dup_ind = i2
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
  cvs.display_dup_ind, cvs.display_key_dup_ind, cvs.cdf_meaning_dup_ind,
  cvs.active_ind_dup_ind
  FROM code_value_set cvs
  WHERE (cvs.code_set=request->code_set)
  DETAIL
   reply->display_key_dup_ind = cvs.display_key_dup_ind, reply->cdf_meaning_dup_ind = cvs
   .cdf_meaning_dup_ind, reply->active_ind_dup_ind = cvs.active_ind_dup_ind,
   reply->display_dup_ind = cvs.display_dup_ind
  WITH nocounter
 ;end select
 IF (curqual=1)
  SET reply->status_data.status = "S"
  GO TO exit_script
 ENDIF
END GO
