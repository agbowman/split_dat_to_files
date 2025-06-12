CREATE PROGRAM bed_ens_step_status:dba
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET error_flag = " "
 DECLARE error_msg = vc
 SET org_id = 0.0
 IF ((request->step_mean > " ")
  AND (request->status_flag IN (0, 1, 2)))
  SET error_flag = "N"
 ELSE
  SET error_flag = "F"
  SET error_msg = concat("Invalide request data, ",
   "step_mean must be values and step_status in (0,1,2).")
  GO TO exit_script
 ENDIF
 UPDATE  FROM br_client_item_reltn bcir
  SET bcir.status_flag = request->status_flag
  PLAN (bcir
   WHERE bcir.item_type="STEP"
    AND (bcir.item_mean=request->step_mean))
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET error_flag = "F"
  SET error_msg = concat("Error updating step status, br_client_id: ",cnvtstring(curclientid),
   " step mean: ",request->step_mean)
  GO TO exit_script
 ENDIF
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET stat = alterlist(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = error_msg
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
