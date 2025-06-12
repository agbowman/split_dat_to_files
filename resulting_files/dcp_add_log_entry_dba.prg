CREATE PROGRAM dcp_add_log_entry:dba
 SET modify = predeclare
 FREE RECORD reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE reportfailure(opname=vc,opstatus=vc,targetname=vc,targetvalue=vc) = null
 DECLARE fillsubeventstatus(opname=vc,opstatus=vc,objname=vc,objvalue=vc) = null
 SUBROUTINE reportfailure(opname,opstatus,targetname,targetvalue)
  SET reply->status_data.status = "F"
  CALL fillsubeventstatus(opname,opstatus,targetname,targetvalue)
 END ;Subroutine
 SUBROUTINE fillsubeventstatus(opname,opstatus,objname,objvalue)
   DECLARE dcp_substatus_cnt = i4 WITH protect, noconstant(size(reply->status_data.subeventstatus,5))
   SET dcp_substatus_cnt = (dcp_substatus_cnt+ 1)
   IF (dcp_substatus_cnt != 1)
    SET stat = alter(reply->status_data.subeventstatus,dcp_substatus_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].operationname = trim(opname)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].targetobjectname = trim(objname)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].targetobjectvalue = trim(objvalue)
 END ;Subroutine
 DECLARE slastmod = c14 WITH protect, noconstant("002 08/25/10")
 DECLARE bdebugind = i2 WITH protect, noconstant(0)
 DECLARE bstatus = i2 WITH protect, noconstant(0)
 DECLARE serrormsg = vc WITH protect, noconstant("")
 DECLARE ierrorcode = i2 WITH protect, noconstant(0)
 DECLARE bfailed = i2 WITH protect, noconstant(0)
 DECLARE get_log_id = f8 WITH protect, noconstant(0.0)
 DECLARE pcnt = i4 WITH protect, noconstant(0)
 DECLARE x = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 IF (validate(request->debug_ind))
  SET bdebugind = request->debug_ind
 ENDIF
 IF (bdebugind=1)
  CALL echo("*******************************************************")
  CALL echo("Request")
  CALL echorecord(request)
  CALL echo("*******************************************************")
 ENDIF
 SET pcnt = size(request->entries,5)
 FOR (x = 1 TO pcnt)
   SELECT INTO "nl:"
    nextseqnum = seq(carenet_seq,nextval)"#################;rp0"
    FROM dual
    DETAIL
     get_log_id = cnvtreal(nextseqnum)
    WITH format
   ;end select
   IF (get_log_id=0.0)
    CALL echo("GET SEQ# failed")
    CALL fillsubeventstatus("dcp_add_log_entry","F","SELECT","Unable to get a new sequence value.")
    SET bfailed = 1
    GO TO exit_script
   ENDIF
   INSERT  FROM dcp_activity_log dal
    SET dal.activity_log_id = get_log_id, dal.activity_type_cd = request->entries[x].activity_type_cd,
     dal.parent_entity_id = request->entries[x].parent_entity_id,
     dal.parent_entity_dt_tm = cnvtdatetime(request->entries[x].parent_entity_dt_tm), dal
     .activity_dt_tm = cnvtdatetime(request->entries[x].activity_dt_tm), dal.parent_entity_name =
     request->entries[x].parent_entity_name,
     dal.prsnl_id = request->entries[x].prsnl_id, dal.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     dal.updt_id = reqinfo->updt_id,
     dal.updt_task = reqinfo->updt_task, dal.updt_cnt = 0, dal.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL echo("Insert failed")
    CALL fillsubeventstatus("dcp_add_log_entry","F","INSERT","Failed to insert the log entry.")
    SET bfailed = 1
    GO TO exit_script
   ENDIF
 ENDFOR
#exit_script
 SET ierrorcode = error(serrormsg,1)
 IF (ierrorcode != 0)
  CALL echo("*********************************")
  CALL echo(build("ERROR MESSAGE : ",serrormsg))
  CALL echo("*********************************")
  CALL fillsubeventstatus("ERROR","F","dcp_add_log_entry",serrormsg)
  SET reply->status_data.status = "F"
  ROLLBACK
  SET reqinfo->commit_ind = 0
 ELSEIF (bfailed=1)
  SET reply->status_data.status = "F"
  ROLLBACK
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 IF (bdebugind=1)
  CALL echorecord(reply)
  CALL echo(build("Last Mod: ",slastmod))
 ENDIF
 SET modify = nopredeclare
END GO
