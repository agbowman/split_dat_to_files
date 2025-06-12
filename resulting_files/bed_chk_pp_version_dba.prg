CREATE PROGRAM bed_chk_pp_version:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 testing_version_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE error_flag = vc
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 IF (checkdic(trim("DCP_RELEASE_PLAN_CATALOG"),"P",0)=2)
  SET reply->testing_version_ind = 1
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
