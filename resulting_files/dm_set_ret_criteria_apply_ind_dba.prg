CREATE PROGRAM dm_set_ret_criteria_apply_ind:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 UPDATE  FROM dm_retention_criteria d
  SET d.apply_ind = 1
  WHERE (d.organization_id=request->org_id)
   AND (d.encntr_type_cd=request->encntr_type_cd)
   AND d.active_ind=1
  WITH nocounter
 ;end update
 IF (curqual > 0)
  COMMIT
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
END GO
