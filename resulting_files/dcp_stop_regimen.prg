CREATE PROGRAM dcp_stop_regimen
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
 DECLARE cstatus = c1 WITH protect, noconstant("Z")
 DECLARE regimen_cnt = i4 WITH constant(value(size(request->regimenlist,5)))
 DECLARE updt_cnt = i4 WITH protect, noconstant(0)
 DECLARE dregimenactioncd = f8 WITH protect, noconstant(0.0)
 DECLARE long_text_id = f8 WITH protect, noconstant(0.0)
 DECLARE regimen_action_id = f8 WITH protect, noconstant(0.0)
 DECLARE regimen_status_cancel_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002501,
   "CANCELLED"))
 DECLARE regimen_status_discontinue_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002501,
   "DISCONTINUED"))
 DECLARE regimen_action_cancel_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002500,
   "CANCEL"))
 DECLARE regimen_action_discontinue_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002500,
   "DISCONTINUE"))
 DECLARE regimen_detail_status_cancelled = f8 WITH protect, constant(uar_get_code_by("MEANING",
   4002515,"CANCELLED"))
 DECLARE regimen_detail_status_skipped = f8 WITH protect, constant(uar_get_code_by("MEANING",4002515,
   "SKIPPED"))
 CALL echo("102961124.00")
 CALL echo(regimen_detail_status_skipped)
 DECLARE update_regimen(idx=i4) = c1
 DECLARE insert_regimen_action(idx=i4,action=f8) = c1
 DECLARE update_regimen_details(idx=i4) = null
 DECLARE report_failure(opname=vc,opstatus=c1,targetname=vc,targetvalue=vc) = null
 FOR (i = 1 TO regimen_cnt)
   CALL echo(request->regimenlist[i].reason_text)
   IF ((request->regimenlist[i].status_cd=regimen_status_cancel_cd))
    SET dregimenactioncd = regimen_action_cancel_cd
   ELSEIF ((request->regimenlist[i].status_cd=regimen_status_discontinue_cd))
    SET dregimenactioncd = regimen_action_discontinue_cd
   ENDIF
   SET cstatus = update_regimen(i)
   IF (cstatus="F")
    GO TO exit_script
   ENDIF
   CALL update_regimen_details(i)
   SET cstatus = insert_regimen_action(i,dregimenactioncd)
   IF (cstatus="F")
    GO TO exit_script
   ENDIF
 ENDFOR
 SUBROUTINE update_regimen(idx)
   SET updt_cnt = 0
   SELECT INTO "n1:"
    r.*
    FROM regimen r
    WHERE (r.regimen_id=request->regimenlist[idx].regimen_id)
    HEAD REPORT
     updt_cnt = r.updt_cnt
    WITH forupdate(r), nocounter
   ;end select
   IF (curqual=0)
    CALL report_failure("UPDATE","F","DCP_STOP_REGIMEN","Unable to lock REGIMEN record")
    RETURN("F")
   ENDIF
   IF ((updt_cnt != request->regimenlist[idx].updt_cnt))
    CALL report_failure("UPDATE","F","DCP_STOP_REGIMEN",
     "UPDT_CNT does not match request->updt_cnt for REGIMEN record")
    RETURN("F")
   ENDIF
   UPDATE  FROM regimen r
    SET r.regimen_status_cd = request->regimenlist[idx].status_cd, r.end_dt_tm = cnvtdatetime(curdate,
      curtime3), r.end_tz = request->regimenlist[idx].encntr_tz,
     r.updt_dt_tm = cnvtdatetime(curdate,curtime3), r.updt_id = reqinfo->updt_id, r.updt_task =
     reqinfo->updt_task,
     r.updt_applctx = reqinfo->updt_applctx, r.updt_cnt = (r.updt_cnt+ 1)
    WHERE (r.regimen_id=request->regimenlist[idx].regimen_id)
   ;end update
   IF (curqual=0)
    CALL report_failure("UPDATE","F","DCP_STOP_REGIMEN","Unable to update REGIMEN record")
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE insert_regimen_action(idx,action)
   SET regimen_action_id = 0.0
   SET long_text_id = 0.0
   SELECT INTO "nl:"
    nextseqnum = seq(carenet_seq,nextval)
    FROM dual
    DETAIL
     regimen_action_id = nextseqnum
    WITH nocounter
   ;end select
   IF (regimen_action_id=0.0)
    CALL report_failure("INSERT","F","DCP_STOP_REGIMEN",
     "Unable to generate new regimen_action_id for REGIMEN_ACTION table")
    RETURN("F")
   ENDIF
   IF ((request->regimenlist[idx].reason_text != null))
    SELECT INTO "nl:"
     nextseqnum = seq(long_data_seq,nextval)
     FROM dual
     DETAIL
      long_text_id = nextseqnum
     WITH nocounter
    ;end select
    IF (long_text_id=0.0)
     CALL report_failure("INSERT","F","DCP_STOP_REGIMEN",
      "Unable to generate new long_text_id for LONG_TEXT table")
     RETURN("F")
    ENDIF
   ENDIF
   IF ((request->regimenlist[idx].reason_text != null))
    INSERT  FROM long_text lt
     SET lt.long_text_id = long_text_id, lt.parent_entity_name = "REGIMEN_ACTION", lt
      .parent_entity_id = regimen_action_id,
      lt.long_text = request->regimenlist[idx].reason_text, lt.active_ind = 1, lt.active_status_cd =
      reqdata->active_status_cd,
      lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lt.active_status_prsnl_id = reqinfo->
      updt_id, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_cnt = 0,
      lt.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     CALL report_failure("INSERT","F","DCP_STOP_REGIMEN","Unable to insert LONG_TEXT record")
     RETURN("F")
    ENDIF
   ENDIF
   INSERT  FROM regimen_action ra
    SET ra.regimen_action_id = regimen_action_id, ra.action_dt_tm = cnvtdatetime(curdate,curtime3),
     ra.action_tz = request->user_tz,
     ra.regimen_id = request->regimenlist[idx].regimen_id, ra.action_type_cd = action, ra
     .action_prsnl_id = reqinfo->updt_id,
     ra.discontinue_reason_cd = request->regimenlist[idx].reason_cd, ra.long_text_id = long_text_id,
     ra.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     ra.updt_id = reqinfo->updt_id, ra.updt_task = reqinfo->updt_task, ra.updt_cnt = 0,
     ra.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL report_failure("INSERT","F","DCP_STOP_REGIMEN","Unable to insert REGIMEN_ACTION record")
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE update_regimen_details(idx)
  SELECT INTO "n1:"
   rd.*
   FROM regimen_detail rd
   WHERE (rd.regimen_id=request->regimenlist[idx].regimen_id)
    AND rd.activity_entity_id=0.0
    AND rd.regimen_detail_status_cd != regimen_detail_status_skipped
   WITH forupdate(r), nocounter
  ;end select
  UPDATE  FROM regimen_detail rd
   SET rd.regimen_detail_status_cd = regimen_detail_status_cancelled, rd.updt_dt_tm = cnvtdatetime(
     curdate,curtime3), rd.updt_id = reqinfo->updt_id,
    rd.updt_task = reqinfo->updt_task, rd.updt_cnt = (rd.updt_cnt+ 1), rd.updt_applctx = reqinfo->
    updt_applctx
   WHERE (rd.regimen_id=request->regimenlist[idx].regimen_id)
    AND rd.activity_entity_id=0.0
    AND rd.regimen_detail_status_cd != regimen_detail_status_skipped
   WITH nocounter
  ;end update
 END ;Subroutine
 SUBROUTINE report_failure(opname,opstatus,targetname,targetvalue)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET cnt = size(reply->status_data.subeventstatus,5)
   IF (((cnt != 1) OR (cnt=1
    AND (reply->status_data.subeventstatus[1].operationstatus != null))) )
    SET cnt = (cnt+ 1)
    SET stat = alter(reply->status_data.subeventstatus,value(cnt))
   ENDIF
   SET reply->status_data.subeventstatus[cnt].operationname = trim(opname)
   SET reply->status_data.subeventstatus[cnt].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[cnt].targetobjectname = trim(targetname)
   SET reply->status_data.subeventstatus[cnt].targetobjectvalue = trim(targetvalue)
 END ;Subroutine
#exit_script
 IF (cstatus="S")
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
 SET reply->status_data.status = cstatus
 CALL echorecord(reply)
END GO
