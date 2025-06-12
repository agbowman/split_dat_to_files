CREATE PROGRAM dcp_upd_plan_action
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
 IF (validate(debug,0)=1)
  CALL echorecord(request)
 ENDIF
 DECLARE insert_action(iplanindex=i4,iindex=i4) = c1
 DECLARE modify_action(iplanindex=i4,iindex=i4) = c1
 DECLARE remove_action(iplanindex=i4,iindex=i4) = c1
 DECLARE get_last_pathway_action_seq(ipathwayid=f8,ioldlastactionseq=i4(ref)) = null
 DECLARE update_pathway(ipathwayid=f8,inewlastactionseq=i4) = null
 DECLARE create_new_pathway_action_id(dnewpathwayactionid=f8(ref)) = null
 DECLARE report_failure(opname=vc,opstatus=c1,targetname=vc,targetvalue=vc) = null
 DECLARE istart = i4 WITH noconstant(1)
 DECLARE inumberofplans = i4 WITH protect, noconstant(size(request->qual,5))
 DECLARE inumberofactions = i4 WITH protect, noconstant(1)
 DECLARE ilastactionseq = i4 WITH protect, noconstant(1)
 DECLARE dnewpathwayactionid = f8 WITH protect, noconstant(0.0)
 DECLARE dnewlongtextid = f8 WITH noconstant(0.0)
 DECLARE cstatus = c1 WITH noconstant("S")
 DECLARE cfailed = c1 WITH noconstant("F")
 FOR (iplanindex = 1 TO inumberofplans)
   SET inumberofactions = size(request->qual[iplanindex].action,5)
   SET ilastactionseq = request->qual[iplanindex].last_action_seq
   IF (ilastactionseq < 0)
    CALL get_last_pathway_action_seq(request->qual[iplanindex].pathway_id,ilastactionseq)
   ENDIF
   FOR (iindex = 1 TO inumberofactions)
     CASE (request->qual[iplanindex].action[iindex].action_mean)
      OF "INSERT":
       SET cstatus = insert_action(iplanindex,iindex)
       IF (cstatus="F")
        CALL report_failure("INSERT","F","dcp_upd_plan_action","Unable to create new an action")
        GO TO exit_script
       ENDIF
      OF "MODIFY":
       SET cstatus = modify_action(iplanindex,iindex)
       IF (cstatus="F")
        CALL report_failure("INSERT","F","dcp_upd_plan_action","Unable to modify an action")
        GO TO exit_script
       ENDIF
      OF "REMOVE":
       SET cstatus = remove_action(iplanindex,iindex)
       IF (cstatus="F")
        CALL report_failure("INSERT","F","dcp_upd_plan_action","Unable to remove an action")
        GO TO exit_script
       ENDIF
     ENDCASE
   ENDFOR
   IF ((request->qual[iplanindex].last_action_seq < 0))
    CALL update_pathway(request->qual[iplanindex].pathway_id,ilastactionseq)
   ENDIF
 ENDFOR
 SUBROUTINE insert_action(iplanindex,iindex)
   SET dnewpathwayactionid = 0.0
   CALL create_new_pathway_action_id(dnewpathwayactionid)
   IF (dnewpathwayactionid=0.0)
    CALL report_failure("INSERT","F","dcp_upd_plan_action",
     "Unable to generate a new pathway action id")
    RETURN("F")
   ENDIF
   SET ilastactionseq = (ilastactionseq+ 1)
   INSERT  FROM pathway_action tnewpathwayaction
    SET tnewpathwayaction.pathway_action_id = dnewpathwayactionid, tnewpathwayaction.pathway_id =
     request->qual[iplanindex].pathway_id, tnewpathwayaction.pw_action_seq = ilastactionseq,
     tnewpathwayaction.pw_status_cd = request->qual[iplanindex].action[iindex].pw_status_cd,
     tnewpathwayaction.action_type_cd = request->qual[iplanindex].action[iindex].action_type_cd,
     tnewpathwayaction.action_dt_tm = cnvtdatetime(request->qual[iplanindex].action[iindex].
      action_dt_tm),
     tnewpathwayaction.action_tz = request->qual[iplanindex].action[iindex].action_tz,
     tnewpathwayaction.action_prsnl_id = reqinfo->updt_id, tnewpathwayaction.duration_qty = request->
     qual[iplanindex].action[iindex].duration_qty,
     tnewpathwayaction.duration_unit_cd = request->qual[iplanindex].action[iindex].duration_unit_cd,
     tnewpathwayaction.start_dt_tm = cnvtdatetime(request->qual[iplanindex].action[iindex].
      start_dt_tm), tnewpathwayaction.end_dt_tm = cnvtdatetime(request->qual[iplanindex].action[
      iindex].end_dt_tm),
     tnewpathwayaction.provider_id = request->qual[iplanindex].action[iindex].provider_id,
     tnewpathwayaction.communication_type_cd = request->qual[iplanindex].action[iindex].
     communication_type_cd, tnewpathwayaction.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     tnewpathwayaction.updt_id = reqinfo->updt_id, tnewpathwayaction.updt_task = reqinfo->updt_task,
     tnewpathwayaction.updt_cnt = 0,
     tnewpathwayaction.updt_applctx = reqinfo->updt_applctx, tnewpathwayaction.action_reason_cd =
     request->qual[iplanindex].action[iindex].action_reason_cd, tnewpathwayaction.action_comment =
     request->qual[iplanindex].action[iindex].action_comment
    WITH nocounter
   ;end insert
   RETURN("S")
 END ;Subroutine
 SUBROUTINE modify_action(iplanindex,iindex)
   RETURN("F")
 END ;Subroutine
 SUBROUTINE remove_action(iplanindex,iindex)
   RETURN("F")
 END ;Subroutine
 SUBROUTINE get_last_pathway_action_seq(ipathwayid,ioldlastactionseq)
   SELECT INTO "nl:"
    inumberofpathwayactionsontable = count(*)
    FROM pathway_action tpathwayaction
    WHERE tpathwayaction.pathway_id=ipathwayid
    DETAIL
     ioldlastactionseq = inumberofpathwayactionsontable
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE update_pathway(ipathwayid,inewlastactionseq)
   UPDATE  FROM pathway tpathway
    SET tpathway.last_action_seq = inewlastactionseq
    WHERE tpathway.pathway_id=ipathwayid
    WITH nocounter
   ;end update
 END ;Subroutine
 SUBROUTINE create_new_pathway_action_id(dnewpathwayactionid)
   SELECT INTO "nl:"
    nextseqnum = seq(carenet_seq,nextval)
    FROM dual
    DETAIL
     dnewpathwayactionid = nextseqnum
    WITH nocounter
   ;end select
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
#exit_script
 IF (cfailed="T")
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
 IF (validate(debug,0)=1)
  CALL echorecord(reply)
 ENDIF
END GO
