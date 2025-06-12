CREATE PROGRAM dcp_update_io_total_start_time:dba
 DECLARE idxcnt = i4 WITH protect, noconstant(0)
 DECLARE seq = f8 WITH protect, noconstant(0.0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE checkfortotalstartdttm(idx=i4) = null
 DECLARE updatetotalstartdttm(idx=i4) = null
 DECLARE inserttotalstartdttm(idx=i4) = null
 SET modify = predeclare
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 FOR (idxcnt = 1 TO size(request->qual,5))
   CALL checkfortotalstartdttm(idxcnt)
   IF (curqual > 0)
    CALL updatetotalstartdttm(idxcnt)
   ELSE
    CALL inserttotalstartdttm(idxcnt)
   ENDIF
   IF ((reply->status_data.status="F"))
    GO TO exit_script
   ENDIF
 ENDFOR
#exit_script
 IF ((reply->status_data.status="S"))
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
 SET modify = nopredeclare
 SUBROUTINE checkfortotalstartdttm(idx)
   SELECT INTO "nl:"
    FROM io_total_start_time iotst
    WHERE (iotst.event_cd=request->qual[idx].event_cd)
     AND (iotst.encntr_id=request->qual[idx].encntr_id)
    WITH nocounter
   ;end select
   SET errcode = error(errmsg,1)
   IF (errcode > 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus.operationname = concat("CheckForTotalStartDtTm - ",errmsg)
    GO TO exit_script
   ELSEIF (curqual=0)
    SET reply->status_data.status = "Z"
    SET reply->status_data.subeventstatus.operationname = "Zero qual in CheckForTotalStartDtTm"
   ELSE
    SET reply->status_data.status = "S"
    SET reply->status_data.subeventstatus.operationname = "Success"
   ENDIF
 END ;Subroutine
 SUBROUTINE updatetotalstartdttm(idx)
   UPDATE  FROM io_total_start_time iotst
    SET iotst.total_start_dt_tm = cnvtdatetime(request->qual[idx].total_start_dt_tm), iotst.event_cd
      = request->qual[idx].event_cd, iotst.encntr_id = request->qual[idx].encntr_id,
     iotst.active_ind = request->qual[idx].active_ind, iotst.updt_id = reqinfo->updt_id, iotst
     .updt_task = reqinfo->updt_task,
     iotst.updt_applctx = reqinfo->updt_applctx, iotst.updt_cnt = (iotst.updt_cnt+ 1), iotst
     .updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE (iotst.event_cd=request->qual[idx].event_cd)
     AND (iotst.encntr_id=request->qual[idx].encntr_id)
    WITH nocounter
   ;end update
   SET errcode = error(errmsg,1)
   IF (errcode > 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus.operationname = concat("UpdateTotal - ",errmsg)
    GO TO exit_script
   ELSEIF (curqual=0)
    SET reply->status_data.status = "Z"
    SET reply->status_data.subeventstatus.operationname = "Zero qual in Update"
   ELSE
    SET reply->status_data.status = "S"
    SET reply->status_data.subeventstatus.operationname = "Success"
   ENDIF
 END ;Subroutine
 SUBROUTINE inserttotalstartdttm(idx)
   INSERT  FROM io_total_start_time iotst
    SET iotst.io_total_start_time_id = seq(carenet_seq,nextval), iotst.total_start_dt_tm =
     cnvtdatetime(request->qual[idx].total_start_dt_tm), iotst.event_cd = request->qual[idx].event_cd,
     iotst.encntr_id = request->qual[idx].encntr_id, iotst.active_ind = request->qual[idx].active_ind,
     iotst.updt_id = reqinfo->updt_id,
     iotst.updt_task = reqinfo->updt_task, iotst.updt_applctx = reqinfo->updt_applctx, iotst.updt_cnt
      = 1,
     iotst.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WITH nocounter
   ;end insert
   SET errcode = error(errmsg,1)
   IF (errcode > 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus.operationname = concat("InsertTotal - ",errmsg)
    GO TO exit_script
   ELSEIF (curqual=0)
    SET reply->status_data.status = "Z"
    SET reply->status_data.subeventstatus.operationname = "Zero qual in Insert"
   ELSE
    SET reply->status_data.status = "S"
    SET reply->status_data.subeventstatus.operationname = "Success"
   ENDIF
 END ;Subroutine
END GO
