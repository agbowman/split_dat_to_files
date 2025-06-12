CREATE PROGRAM cqm_ins_trigger_wrapper:dba
 IF (validate(reply->trigger_id)=0)
  RECORD reply(
    1 trigger_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 EXECUTE cqm_ins_trigger
END GO
