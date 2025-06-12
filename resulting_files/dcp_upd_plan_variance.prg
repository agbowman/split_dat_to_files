CREATE PROGRAM dcp_upd_plan_variance
 RECORD reply(
   1 variancelist[*]
     2 variance_reltn_id = f8
     2 event_id = f8
     2 parent_entity_id = f8
     2 status_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE update_variance_text(idx=i4) = c1
 DECLARE insert_variance(idx=i4) = c1
 DECLARE remove_variance(idx=i4) = c1
 DECLARE insert_long_text(idx=i4,texttype=i2) = c1
 DECLARE remove_long_text(long_text_id=f8,updt_cnt=i4) = c1
 DECLARE report_failure(opname=vc,opstatus=c1,targetname=vc,targetvalue=vc) = null
 DECLARE variance_cnt = i4 WITH constant(value(size(request->variancelist,5)))
 DECLARE actiontext = i2 WITH constant(1)
 DECLARE reasontext = i2 WITH constant(2)
 DECLARE notetext = i2 WITH constant(3)
 DECLARE cstatus = c1 WITH noconstant("S")
 DECLARE cfailed = c1 WITH noconstant("F")
 DECLARE action_text_id = f8 WITH noconstant(0.0), protect
 DECLARE reason_text_id = f8 WITH noconstant(0.0), protect
 DECLARE note_text_id = f8 WITH noconstant(0.0), protect
 DECLARE i = i4 WITH noconstant(0), protect
 DECLARE replycnt = i4 WITH noconstant(0), protect
 DECLARE pw_variance_reltn_id = f8 WITH protect, noconstant(0.0)
 DECLARE stat = i2 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET stat = alterlist(reply->variancelist,variance_cnt)
 FOR (i = 1 TO variance_cnt)
  SET cstatus = update_variance_text(i)
  IF (cstatus="F")
   SET replycnt = (replycnt+ 1)
   SET reply->variancelist[replycnt].status_ind = 0
   SET reply->variancelist[replycnt].variance_reltn_id = request->variancelist[i].variance_reltn_id
   SET reply->variancelist[replycnt].event_id = request->variancelist[i].event_id
   SET reply->variancelist[replycnt].parent_entity_id = request->variancelist[i].parent_entity_id
  ELSEIF ((request->variancelist[i].action_meaning="CREATE")
   AND (request->variancelist[i].parent_entity_id > 0))
   SET cstatus = insert_variance(i)
   SET replycnt = (replycnt+ 1)
   IF (cstatus="F")
    CALL report_failure("INSERT","F","DCP_UPD_PLAN_VARIANCE",
     "Unable to create new PW_VARIANCE_RELTN record")
    SET reply->variancelist[replycnt].status_ind = 0
   ELSE
    SET reply->variancelist[replycnt].status_ind = 1
   ENDIF
   SET reply->variancelist[replycnt].variance_reltn_id = pw_variance_reltn_id
   SET reply->variancelist[replycnt].event_id = request->variancelist[i].event_id
   SET reply->variancelist[replycnt].parent_entity_id = request->variancelist[i].parent_entity_id
  ELSEIF ((request->variancelist[i].action_meaning="REMOVE")
   AND (request->variancelist[i].variance_reltn_id > 0))
   SET cstatus = remove_variance(i)
   SET replycnt = (replycnt+ 1)
   IF (cstatus="F")
    CALL report_failure("DELETE","F","DCP_UPD_PLAN_VARIANCE",
     "Unable to remove PW_VARIANCE_RELTN record")
    SET reply->variancelist[replycnt].status_ind = 0
   ELSE
    SET reply->variancelist[replycnt].status_ind = 1
   ENDIF
   SET reply->variancelist[replycnt].variance_reltn_id = request->variancelist[i].variance_reltn_id
   SET reply->variancelist[replycnt].event_id = request->variancelist[i].event_id
   SET reply->variancelist[replycnt].parent_entity_id = request->variancelist[i].parent_entity_id
  ENDIF
 ENDFOR
 SET stat = alterlist(reply->variancelist,replycnt)
 SUBROUTINE update_variance_text(idx)
   SET action_text_id = 0
   SET reason_text_id = 0
   SET note_text_id = 0
   IF ((request->variancelist[idx].action_meaning="REMOVE")
    AND (request->variancelist[idx].action_text_id > 0))
    SET clocstatus = remove_long_text(request->variancelist[idx].action_text_id,request->
     variancelist[idx].action_text_updt_cnt)
    IF (clocstatus="F")
     CALL report_failure("REMOVE","F","DCP_UPD_PLAN_VARIANCE","Unable to remove a LONG_TEXT record")
     RETURN("F")
    ENDIF
   ENDIF
   IF ((request->variancelist[idx].action_meaning="REMOVE")
    AND (request->variancelist[idx].reason_text_id > 0))
    SET clocstatus = remove_long_text(request->variancelist[idx].reason_text_id,request->
     variancelist[idx].reason_text_updt_cnt)
    IF (clocstatus="F")
     CALL report_failure("REMOVE","F","DCP_UPD_PLAN_VARIANCE","Unable to remove a LONG_TEXT record")
     RETURN("F")
    ENDIF
   ENDIF
   IF ((request->variancelist[idx].action_meaning="REMOVE")
    AND (request->variancelist[idx].note_text_id > 0))
    SET clocstatus = remove_long_text(request->variancelist[idx].note_text_id,request->variancelist[
     idx].note_text_updt_cnt)
    IF (clocstatus="F")
     CALL report_failure("REMOVE","F","DCP_UPD_PLAN_VARIANCE","Unable to remove a LONG_TEXT record")
     RETURN("F")
    ENDIF
   ENDIF
   IF ((request->variancelist[idx].action_meaning="CREATE")
    AND (request->variancelist[i].action_text != null))
    SET clocstatus = insert_long_text(idx,actiontext)
    IF (clocstatus="F")
     CALL report_failure("INSERT","F","DCP_UPD_PLAN_VARIANCE","Unable to create new LONG_TEXT record"
      )
     RETURN("F")
    ENDIF
   ENDIF
   IF ((request->variancelist[idx].action_meaning="CREATE")
    AND (request->variancelist[i].reason_text != null))
    SET clocstatus = insert_long_text(idx,reasontext)
    IF (clocstatus="F")
     CALL report_failure("INSERT","F","DCP_UPD_PLAN_VARIANCE","Unable to create new LONG_TEXT record"
      )
     RETURN("F")
    ENDIF
   ENDIF
   IF ((request->variancelist[idx].action_meaning="CREATE")
    AND (request->variancelist[i].note_text != null))
    SET clocstatus = insert_long_text(idx,notetext)
    IF (clocstatus="F")
     CALL report_failure("INSERT","F","DCP_UPD_PLAN_VARIANCE","Unable to create new LONG_TEXT record"
      )
     RETURN("F")
    ENDIF
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE insert_variance(idx)
   SET pw_variance_reltn_id = 0
   SELECT INTO "nl:"
    nextseqnum = seq(carenet_seq,nextval)
    FROM dual
    DETAIL
     pw_variance_reltn_id = nextseqnum
    WITH nocounter
   ;end select
   IF (pw_variance_reltn_id=0.0)
    CALL report_failure("INSERT","F","DCP_UPD_PLAN_VARIANCE",
     "Unable to generate new pw_variance_reltn_id for variance")
    RETURN("F")
   ENDIF
   INSERT  FROM pw_variance_reltn pvr
    SET pvr.pw_variance_reltn_id = pw_variance_reltn_id, pvr.action_cd = request->variancelist[idx].
     action_cd, pvr.action_text_id = action_text_id,
     pvr.parent_entity_name = request->variancelist[idx].parent_entity_name, pvr.parent_entity_id =
     request->variancelist[idx].parent_entity_id, pvr.event_id = request->variancelist[idx].event_id,
     pvr.variance_type_cd = request->variancelist[idx].variance_type_cd, pvr.active_ind = 1, pvr
     .reason_cd = request->variancelist[idx].reason_cd,
     pvr.reason_text_id = reason_text_id, pvr.note_text_id = note_text_id, pvr.pathway_id = request->
     variancelist[idx].pathway_id,
     pvr.chart_prsnl_id = reqinfo->updt_id, pvr.chart_dt_tm = cnvtdatetime(curdate,curtime3), pvr
     .chart_tz = curtimezoneapp,
     pvr.updt_dt_tm = cnvtdatetime(curdate,curtime3), pvr.updt_id = reqinfo->updt_id, pvr.updt_task
      = reqinfo->updt_task,
     pvr.updt_cnt = 0, pvr.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL report_failure("INSERT","F","DCP_UPD_PLAN_VARIANCE",
     "Unable to insert into PW_VARIANCE_RELTN")
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE insert_long_text(idx,texttype)
   DECLARE long_text_id = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    nextseqnum = seq(long_data_seq,nextval)
    FROM dual
    DETAIL
     long_text_id = nextseqnum
    WITH nocounter
   ;end select
   IF (long_text_id=0.0)
    CALL report_failure("INSERT","F","DCP_UPD_PLAN_VARIANCE",
     "Unable to generate new long_text_id for variance text")
    RETURN("F")
   ENDIF
   IF (texttype=actiontext)
    SET action_text_id = long_text_id
   ELSEIF (texttype=reasontext)
    SET reason_text_id = long_text_id
   ELSEIF (texttype=notetext)
    SET note_text_id = long_text_id
   ENDIF
   INSERT  FROM long_text lt
    SET lt.long_text_id = long_text_id, lt.parent_entity_name = request->variancelist[idx].
     parent_entity_name, lt.parent_entity_id = request->variancelist[idx].parent_entity_id,
     lt.long_text =
     IF (texttype=actiontext) request->variancelist[idx].action_text
     ELSEIF (texttype=reasontext) request->variancelist[idx].reason_text
     ELSEIF (texttype=notetext) request->variancelist[idx].note_text
     ENDIF
     , lt.active_ind = 1, lt.active_status_cd = reqdata->active_status_cd,
     lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lt.active_status_prsnl_id = reqinfo->
     updt_id, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_cnt = 0,
     lt.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL report_failure("INSERT","F","DCP_UPD_PLAN_VARIANCE","Unable to insert into LONG_TEXT")
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE remove_long_text(long_text_id,updt_cnt)
   DECLARE text_updt_cnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    lt.*
    FROM long_text lt
    WHERE lt.long_text_id=long_text_id
    HEAD REPORT
     text_updt_cnt = lt.updt_cnt
    WITH forupdate(lt), nocounter
   ;end select
   IF (curqual=0)
    CALL report_failure("UPDATE","F","DCP_UPD_PLAN_VARIANCE",build(
      "Unable to get a lock on LONG_TEXT. LONG_TEXT_ID=",long_text_id))
    RETURN("F")
   ENDIF
   IF (text_updt_cnt != updt_cnt)
    CALL report_failure("UPDATE","F","DCP_UPD_PLAN_VARIANCE",build(
      "Unable to inactivate a row on LONG_TEXT table.  Row was changed by another user. LONG_TEXT_ID=",
      long_text_id))
    RETURN("F")
   ENDIF
   UPDATE  FROM long_text lt
    SET lt.active_ind = 0, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3), lt.updt_id = reqinfo->
     updt_id,
     lt.updt_task = reqinfo->updt_task, lt.updt_cnt = (lt.updt_cnt+ 1), lt.updt_applctx = reqinfo->
     updt_applctx
    WHERE lt.long_text_id=long_text_id
   ;end update
   IF (curqual=0)
    CALL report_failure("UPDATE","F","DCP_UPD_PLAN_VARIANCE",build(
      "Failed to inactivate a row on LONG_TEXT table.  LONG_TEXT_ID=",long_text_id))
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE remove_variance(idx)
   DECLARE pvr_updt_cnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    pvr.*
    FROM pw_variance_reltn pvr
    WHERE (pvr.pw_variance_reltn_id=request->variancelist[idx].variance_reltn_id)
    HEAD REPORT
     pvr_updt_cnt = pvr.updt_cnt
    WITH forupdate(pvr), nocounter
   ;end select
   IF (curqual=0)
    CALL report_failure("REMOVE","F","DCP_UPD_PLAN_VARIANCE",build(
      "Failed to remove  row from PW_VRAINCE_RELTN for VARIANCE_RELTN_ID=",request->variancelist[idx]
      .variance_reltn_id))
    RETURN("F")
   ENDIF
   IF ((pvr_updt_cnt != request->variancelist[idx].updt_cnt))
    CALL report_failure("REMOVE","F","DCP_UPD_PLAN_VARIANCE",build(
      "Unable to update PW_VARIANCE_RELTN table.  Row was changed by another user. VARIANCE_RELTN_ID=",
      request->variancelist[idx].variance_reltn_id))
    RETURN("F")
   ENDIF
   UPDATE  FROM pw_variance_reltn pvr
    SET pvr.active_ind = 0, pvr.unchart_prsnl_id = reqinfo->updt_id, pvr.unchart_dt_tm = cnvtdatetime
     (curdate,curtime3),
     pvr.unchart_tz = curtimezoneapp, pvr.updt_dt_tm = cnvtdatetime(curdate,curtime3), pvr.updt_id =
     reqinfo->updt_id,
     pvr.updt_task = reqinfo->updt_task, pvr.updt_applctx = reqinfo->updt_applctx, pvr.updt_cnt = (
     pvr.updt_cnt+ 1)
    WHERE (pvr.pw_variance_reltn_id=request->variancelist[idx].variance_reltn_id)
   ;end update
   IF (curqual=0)
    CALL report_failure("REMOVE","F","DCP_UPD_PLAN_VARIANCE",build(
      "Unable to update PW_VARIANCE_RELTN.  VARIANCE_RELTN_ID=",request->variancelist[idx].
      variance_reltn_id))
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE report_failure(opname,opstatus,targetname,targetvalue)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET cfailed = "T"
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
 SET reqinfo->commit_ind = 1
 SET reply->status_data.status = "S"
END GO
