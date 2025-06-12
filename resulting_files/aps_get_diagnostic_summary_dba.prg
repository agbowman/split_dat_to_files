CREATE PROGRAM aps_get_diagnostic_summary:dba
 RECORD reply(
   1 qual[*]
     2 diag_summary_prefix_id = f8
     2 prefix_id = f8
     2 task_assay_cd = f8
     2 required_ind = i2
     2 comment_ind = i2
     2 comment_length = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET reply->status_data.status = "F"
 DECLARE nprefixcounter = i2 WITH protect, noconstant(0)
 SELECT
  *
  FROM ap_prefix_diag_smry apds
  DETAIL
   nprefixcounter = (nprefixcounter+ 1)
   IF (nprefixcounter > size(reply->qual,5))
    stat = alterlist(reply->qual,(nprefixcounter+ 9))
   ENDIF
   reply->qual[nprefixcounter].diag_summary_prefix_id = apds.prefix_diag_smry_id, reply->qual[
   nprefixcounter].prefix_id = apds.prefix_id, reply->qual[nprefixcounter].task_assay_cd = apds
   .task_assay_cd,
   reply->qual[nprefixcounter].required_ind = apds.required_ind, reply->qual[nprefixcounter].
   comment_ind = apds.comment_ind, reply->qual[nprefixcounter].comment_length = apds
   .comment_length_qty
  FOOT REPORT
   stat = alterlist(reply->qual,nprefixcounter)
  WITH nocounter
 ;end select
 IF (nprefixcounter=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_PREFIX_DIAG_SMRY"
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO
