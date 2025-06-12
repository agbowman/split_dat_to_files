CREATE PROGRAM dcp_upd_lock_forms_activity:dba
 RECORD reply(
   1 prsnl_id = f8
   1 lock_create_dt_tm = dq8
   1 forms_activity_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD chkrequest(
   1 prsnl_id = f8
   1 forms_activity_id = f8
 )
 RECORD chkreply(
   1 prsnl_id = f8
   1 forms_activity_id = f8
   1 lock_create_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE failure_ind = i2 WITH protect, noconstant(false)
 DECLARE zero_ind = i2 WITH protect, noconstant(false)
 DECLARE anticipatedcd = f8 WITH constant(uar_get_code_by("MEANING",8,"ANTICIPATED"))
 DECLARE validaterequest(null) = null
 DECLARE checkexistinglockinfo(null) = null
 DECLARE lockexistingactivity(argactid=f8) = null
 DECLARE removelock(argactid=f8) = null
 SET modify = predeclare
 SET trace = debug
 SET reply->status_data.status = "F"
 CALL validaterequest(null)
 CALL checkexistinglockinfo(null)
 IF ((request->free_lock_flag=true))
  CALL removelock(chkrequest->forms_activity_id)
 ELSE
  IF ((chkreply->prsnl_id > 0.0)
   AND (request->override_existing_lock_flag=false))
   SET reply->forms_activity_id = chkreply->forms_activity_id
   SET reply->lock_create_dt_tm = chkreply->lock_create_dt_tm
   SET reply->prsnl_id = chkreply->prsnl_id
   SET reply->status_data.subeventstatus.targetobjectvalue =
   "Lock already exists and override flag was FALSE"
   SET zero_ind = true
   GO TO script_end
  ENDIF
  CALL lockexistingactivity(chkreply->forms_activity_id)
 ENDIF
#script_end
 IF (failure_ind=true)
  CALL echo("*Update Lock Forms Activity Script failed*")
 ELSEIF (zero_ind=true)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
 ENDIF
 CALL echorecord(reply)
 SUBROUTINE validaterequest(null)
   IF ((request->prsnl_id=0.0))
    SET reply->status_data.subeventstatus.targetobjectvalue = "No PRSNL_ID was given"
    SET failure_ind = true
    GO TO script_end
   ELSEIF ((request->forms_activity_id=0.0))
    SET reply->status_data.subeventstatus.targetobjectvalue = "No activity ID was found in request"
    SET failure_ind = true
    GO TO script_end
   ELSEIF ((request->forms_activity_id=0.0)
    AND (request->free_lock_flag=true))
    SET reply->status_data.subeventstatus.targetobjectvalue =
    "Unable to free lock; no activity id was given"
    SET failure_ind = true
    GO TO script_end
   ENDIF
 END ;Subroutine
 SUBROUTINE checkexistinglockinfo(null)
   SET chkrequest->forms_activity_id = request->forms_activity_id
   SET chkrequest->prsnl_id = request->prsnl_id
   EXECUTE dcp_chk_lock_forms_activity  WITH replace("REQUEST",chkrequest), replace("REPLY",chkreply)
   IF ((chkreply->status_data.status="F"))
    SET reply->status_data.subeventstatus.targetobjectvalue =
    "Child dcp_chk_lock_forms_activity failed"
    SET failure_ind = true
    GO TO script_end
   ELSEIF ((chkreply->status_data.status="S"))
    CALL echo("[TRACE]: Lock was found for request prsnl")
    IF ((request->free_lock_flag=false))
     SET reply->forms_activity_id = chkreply->forms_activity_id
     SET reply->lock_create_dt_tm = chkreply->lock_create_dt_tm
     SET reply->prsnl_id = chkreply->prsnl_id
     GO TO script_end
    ENDIF
   ELSEIF ((chkreply->forms_activity_id=0.0)
    AND (request->free_lock_flag=true))
    SET reply->status_data.subeventstatus.targetobjectvalue =
    "Unable to free lock, lock could not be found"
    SET zero_ind = true
    GO TO script_end
   ENDIF
 END ;Subroutine
 SUBROUTINE lockexistingactivity(argactid)
   UPDATE  FROM dcp_forms_activity fa
    SET fa.lock_prsnl_id = request->prsnl_id, fa.lock_create_dt_tm = cnvtdatetime(curdate,curtime3),
     fa.updt_cnt = (fa.updt_cnt+ 1),
     fa.updt_dt_tm = cnvtdatetime(curdate,curtime3), fa.updt_id = reqinfo->updt_id, fa.updt_task =
     reqinfo->updt_task,
     fa.updt_applctx = reqinfo->updt_applctx
    WHERE fa.dcp_forms_activity_id=argactid
    WITH nocounter
   ;end update
   IF (curqual != 1)
    SET reply->status_data.subeventstatus.targetobjectvalue =
    "Unexpected results when overriding lock"
    SET failure_ind = true
    GO TO script_end
   ENDIF
   SET reply->forms_activity_id = chkreply->forms_activity_id
   SET reply->prsnl_id = request->prsnl_id
   SET reply->lock_create_dt_tm = cnvtdatetime(curdate,curtime3)
 END ;Subroutine
 SUBROUTINE removelock(argactid)
  UPDATE  FROM dcp_forms_activity fa
   SET fa.lock_prsnl_id = 0.0, fa.lock_create_dt_tm = null, fa.updt_cnt = (fa.updt_cnt+ 1),
    fa.updt_dt_tm = cnvtdatetime(curdate,curtime3), fa.updt_id = reqinfo->updt_id, fa.updt_task =
    reqinfo->updt_task,
    fa.updt_applctx = reqinfo->updt_applctx
   WHERE fa.dcp_forms_activity_id=argactid
    AND fa.active_ind=true
   WITH nocounter
  ;end update
  IF (curqual != 1)
   SET reply->status_data.subeventstatus.targetobjectvalue = "Activity could not be unlocked"
   SET failure_ind = true
   GO TO script_end
  ENDIF
 END ;Subroutine
END GO
