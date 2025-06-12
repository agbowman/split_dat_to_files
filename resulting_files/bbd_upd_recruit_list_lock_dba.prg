CREATE PROGRAM bbd_upd_recruit_list_lock:dba
 RECORD reply(
   1 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET modify = predeclare
 DECLARE errorhandler(operationstatus=c1,targetobjectname=c25,targetobjectvalue=vc) = null
 DECLARE script_name = c25 WITH protect, constant("BBD_UPD_RECRUIT_LIST_LOCK")
 DECLARE lstat = i4 WITH protect, noconstant(0)
 DECLARE nlockind = i2 WITH public, noconstant(0)
 DECLARE errmsg = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE error_check = i2 WITH protect, noconstant(error(errmsg,1))
 SET reply->status_data.status = "F"
 IF ((request->lock_ind=1))
  SELECT INTO "nl:"
   rl.list_id, rl.lock_ind
   FROM bbd_recruiting_list rl
   WHERE (rl.list_id=request->list_id)
    AND (rl.updt_cnt=request->updt_cnt)
   DETAIL
    nlockind = rl.lock_ind
   WITH nocounter, forupdate(rl)
  ;end select
  SET error_check = error(errmsg,0)
  IF (error_check != 0)
   CALL errorhandler("F","Failed to lock rows.",errmsg)
  ENDIF
  IF (curqual=0)
   CALL errorhandler("F","BBD_UPD_RECRUIT_LIST_LOCK",
    "List does not exist on table - BBD_RECRUITING_LIST.")
  ENDIF
  IF (nlockind=1)
   CALL errorhandler("L","BBD_UPD_RECRUIT_LIST_LOCK",
    "List is previously locked on table - BBD_RECRUITING_LIST.")
  ENDIF
 ELSEIF ((request->lock_ind=0))
  SELECT INTO "nl:"
   rl.list_id
   FROM bbd_recruiting_list rl
   WHERE (rl.list_id=request->list_id)
    AND rl.lock_ind=1
    AND (rl.updt_cnt=request->updt_cnt)
   WITH nocounter, forupdate(rl)
  ;end select
  SET error_check = error(errmsg,0)
  IF (error_check != 0)
   CALL errorhandler("F","Failed to lock rows.",errmsg)
  ENDIF
  IF (curqual=0)
   CALL errorhandler("F","BBD_UPD_RECRUIT_LIST_LOCK",
    "Unable to find list_id with lock_ind = 1 on table - BBD_RECRUITING_LIST.")
  ENDIF
 ENDIF
 UPDATE  FROM bbd_recruiting_list rl
  SET rl.lock_ind = request->lock_ind, rl.updt_cnt = (request->updt_cnt+ 1), rl.updt_applctx =
   reqinfo->updt_applctx,
   rl.updt_dt_tm = cnvtdatetime(curdate,curtime3), rl.updt_id = reqinfo->updt_id, rl.updt_task =
   reqinfo->updt_task
  WHERE (rl.list_id=request->list_id)
   AND (rl.updt_cnt=request->updt_cnt)
  WITH nocounter
 ;end update
 SET error_check = error(errmsg,0)
 IF (error_check != 0)
  CALL errorhandler("F","Failed to update rows.",errmsg)
 ENDIF
 SET reply->updt_cnt = (request->updt_cnt+ 1)
 GO TO set_status
 SUBROUTINE errorhandler(operationstatus,targetobjectname,targetobjectvalue)
   DECLARE error_cnt = i2 WITH private, noconstant(0)
   SET error_cnt = size(reply->status_data.subeventstatus,5)
   IF (((error_cnt > 1) OR (error_cnt=1
    AND (reply->status_data.subeventstatus[error_cnt].operationstatus != ""))) )
    SET error_cnt = (error_cnt+ 1)
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[error_cnt].operationname = script_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = operationstatus
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = targetobjectname
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = targetobjectvalue
   SET reqinfo->commit_ind = 0
   GO TO exit_script
 END ;Subroutine
#set_status
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#exit_script
END GO
