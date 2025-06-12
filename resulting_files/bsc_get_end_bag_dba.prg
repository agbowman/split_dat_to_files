CREATE PROGRAM bsc_get_end_bag:dba
 SET modify = predeclare
 RECORD reply(
   1 task_id = f8
   1 task_status_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE endbag_task_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6026,"IVENDBAG"))
 DECLARE last_mod = c12 WITH private, noconstant(fillstring(12," "))
 DECLARE error_msg = vc WITH protect, noconstant("")
 DECLARE error_cd = i2 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 IF ((request->order_id <= 0))
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM task_activity ta
  PLAN (ta
   WHERE (ta.order_id=request->order_id)
    AND ta.task_type_cd=endbag_task_cd)
  DETAIL
   reply->task_id = ta.task_id, reply->task_status_cd = ta.task_status_cd
  WITH nocounter
 ;end select
 IF ((reply->task_id > 0))
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SET error_cd = error(error_msg,1)
 IF (error_cd != 0)
  CALL echo("*********************************")
  CALL echo(build("ERROR MESSAGE : ",error_msg))
  CALL echo("*********************************")
  SET reply->status_data.status = "F"
 ENDIF
#exit_script
 SET last_mod = "000 1/25/10"
 SET modify = nopredeclare
END GO
