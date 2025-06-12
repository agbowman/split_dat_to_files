CREATE PROGRAM dcp_chk_duplicate_dta
 RECORD reply(
   1 duplicate_ind = i2
   1 task_assay_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE failed = c1 WITH noconstant(fillstring(1,"F"))
 DECLARE serrormsg = vc WITH noconstant(fillstring(255," "))
 DECLARE error_code = f8 WITH noconstant(0.0)
 DECLARE dup_ind = i4 WITH noconstant(0)
 SET reply->duplicate_ind = 0
 SET error_code = error(serrormsg,1)
 SELECT INTO "nl:"
  d.mnemonic
  FROM discrete_task_assay d
  WHERE (d.mnemonic=request->mnemonic)
   AND (d.activity_type_cd=request->activity_type_cd)
  ORDER BY d.task_assay_cd
  DETAIL
   dup_ind = (dup_ind+ 1), reply->task_assay_cd = d.task_assay_cd
  WITH nocounter
 ;end select
 SET error_code = error(serrormsg,0)
 IF (error_code != 0)
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
  SET failed = "T"
  GO TO exit_script
 ENDIF
 IF (dup_ind > 0)
  SET reply->duplicate_ind = 1
  SET failed = "Z"
  SET reply->status_data.targetobjectvalue = "Duplicate DTA mnemonic found."
 ENDIF
#exit_script
 IF (failed="F")
  SET reply->status_data.status = "S"
  SET reply->status_data.targetobjectvalue = "No duplicate DTA mnemonic found."
 ELSEIF (failed="Z")
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
END GO
