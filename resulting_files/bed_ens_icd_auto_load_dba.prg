CREATE PROGRAM bed_ens_icd_auto_load:dba
 DECLARE child_status = vc
 IF ((request->load_ind=1))
  SET trace = recpersist
  EXECUTE kia_rdm_icd9_mltm
  SET child_status = readme_data->status
  SET trace = norecpersist
 ENDIF
#exit_script
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF (child_status="F")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL echorecord(reply)
END GO
