CREATE PROGRAM dcp_save_regimen_documentation
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
 DECLARE response_cnt = i4 WITH constant(value(size(request->responselist,5)))
 DECLARE updt_cnt = i4 WITH protect, noconstant(0)
 DECLARE long_text_id = f8 WITH protect, noconstant(0.0)
 DECLARE insert_response(idx=i4) = c1
 DECLARE remove_response(idx=i4) = c1
 DECLARE report_failure(opname=vc,opstatus=c1,targetname=vc,targetvalue=vc) = null
 FOR (i = 1 TO response_cnt)
   IF ((request->responselist[i].add_ind=1))
    SET cstatus = insert_response(i)
    IF (cstatus="F")
     GO TO exit_script
    ENDIF
   ELSEIF ((request->responselist[i].remove_ind=1))
    SET cstatus = remove_response(i)
    IF (cstatus="F")
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
 SUBROUTINE insert_response(idx)
   SET long_text_id = 0.0
   IF ((request->responselist[idx].long_text != null))
    SELECT INTO "nl:"
     nextseqnum = seq(long_data_seq,nextval)
     FROM dual
     DETAIL
      long_text_id = nextseqnum
     WITH nocounter
    ;end select
    IF (long_text_id=0.0)
     CALL report_failure("INSERT","F","DCP_SAVE_REGIMEN_DOCUMENTATION",
      "Unable to generate new long_text_id for LONG_TEXT table")
     RETURN("F")
    ENDIF
   ENDIF
   IF ((request->responselist[idx].long_text != null))
    INSERT  FROM long_text lt
     SET lt.long_text_id = long_text_id, lt.parent_entity_name = "REGIMEN_DOCUMENTATION", lt
      .parent_entity_id = request->responselist[idx].regimen_documentation_id,
      lt.long_text = request->responselist[idx].long_text, lt.active_ind = 1, lt.active_status_cd =
      reqdata->active_status_cd,
      lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lt.active_status_prsnl_id = reqinfo->
      updt_id, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_cnt = 0,
      lt.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     CALL report_failure("INSERT","F","DCP_SAVE_REGIMEN_DOCUMENTATION",
      "Unable to insert LONG_TEXT record")
     RETURN("F")
    ENDIF
   ENDIF
   INSERT  FROM regimen_documentation rd
    SET rd.active_ind = 1, rd.chart_dt_tm = cnvtdatetime(request->responselist[idx].chart_dt_tm), rd
     .chart_prsnl_id = request->responselist[idx].prsnl_id,
     rd.chart_tz = request->responselist[idx].prsnl_tz, rd.long_text_id = long_text_id, rd
     .regimen_detail_id = request->responselist[idx].regimen_detail_id,
     rd.regimen_documentation_id = request->responselist[idx].regimen_documentation_id, rd.regimen_id
      = request->responselist[idx].regimen_id, rd.response_cd = request->responselist[idx].
     response_cd,
     rd.type_flag = request->responselist[idx].type_flag, rd.updt_applctx = reqinfo->updt_applctx, rd
     .updt_cnt = 0,
     rd.updt_dt_tm = cnvtdatetime(curdate,curtime3), rd.updt_id = reqinfo->updt_id, rd.updt_task =
     reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL report_failure("INSERT","F","DCP_SAVE_REGIMEN_DOCUMENTATION",
     "Unable to insert REGIMEN_DOCUMENTATION record")
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE remove_response(idx)
   SET updt_cnt = 0
   SELECT INTO "n1:"
    rd.*
    FROM regimen_documentation rd
    WHERE (rd.regimen_documentation_id=request->responselist[idx].regimen_documentation_id)
    HEAD REPORT
     updt_cnt = rd.updt_cnt
    WITH forupdate(rd), nocounter
   ;end select
   IF (curqual=0)
    CALL report_failure("UPDATE","F","DCP_SAVE_REGIMEN_DOCUMENTATION",
     "Unable to lock REGIMEN_DOCUMENTATION record")
    RETURN("F")
   ENDIF
   IF ((updt_cnt != request->responselist[idx].updt_cnt))
    CALL report_failure("UPDATE","F","DCP_SAVE_REGIMEN_DOCUMENTATION",
     "UPDT_CNT does not match request->responseList[idx]->updt_cnt for REGIMEN_DOCUMENTATION record")
    RETURN("F")
   ENDIF
   UPDATE  FROM regimen_documentation rd
    SET rd.active_ind = 0, rd.unchart_dt_tm = cnvtdatetime(request->responselist[idx].chart_dt_tm),
     rd.unchart_prsnl_id = request->responselist[idx].prsnl_id,
     rd.unchart_tz = request->responselist[idx].prsnl_tz, rd.updt_dt_tm = cnvtdatetime(curdate,
      curtime3), rd.updt_id = reqinfo->updt_id,
     rd.updt_task = reqinfo->updt_task, rd.updt_applctx = reqinfo->updt_applctx, rd.updt_cnt = (rd
     .updt_cnt+ 1)
    WHERE (rd.regimen_documentation_id=request->responselist[idx].regimen_documentation_id)
   ;end update
   IF (curqual=0)
    CALL report_failure("UPDATE","F","DCP_SAVE_REGIMEN_DOCUMENTATION",
     "Unable to remove REGIMEN_DOCUMENTATION record")
    RETURN("F")
   ENDIF
   RETURN("S")
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
