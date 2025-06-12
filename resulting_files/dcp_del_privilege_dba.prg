CREATE PROGRAM dcp_del_privilege:dba
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
 RECORD insertprivdellegacy(
   1 qual_cnt = i4
   1 qual[*]
     2 privilege_cd = f8
     2 location_cd = f8
     2 person_id = f8
     2 position_cd = f8
     2 ppr_cd = f8
 )
 RECORD insertprivdelactivity(
   1 qual_cnt = i4
   1 qual[*]
     2 privilege_cd = f8
     2 activity_privilege_def_id = f8
 )
 RECORD privlocreltnid(
   1 priv_loc_reltn_id = f8
 )
 DECLARE stat = i4 WITH noconstant(0)
 DECLARE log_status(operationname=vc,operationstatus=vc,targetobjectname=vc,targetobjectvalue=vc) =
 null
 DECLARE log_count = i4 WITH noconstant(0)
 SUBROUTINE log_status(operationname,operationstatus,targetobjectname,targetobjectvalue)
   IF ( NOT (validate(reply,0)))
    RETURN
   ENDIF
   SET log_count = size(reply->status_data.subeventstatus,5)
   IF (log_count=1)
    IF (trim(reply->status_data.subeventstatus[1].targetobjectname) > "")
     SET log_count = (log_count+ 1)
    ENDIF
   ELSE
    SET log_count = (log_count+ 1)
   ENDIF
   SET stat = alter(reply->status_data.subeventstatus,log_count)
   SET reply->status_data.subeventstatus[log_count].operationname = operationname
   SET reply->status_data.subeventstatus[log_count].operationstatus = operationstatus
   SET reply->status_data.subeventstatus[log_count].targetobjectname = targetobjectname
   SET reply->status_data.subeventstatus[log_count].targetobjectvalue = targetobjectvalue
 END ;Subroutine
 SET reply->status_data.status = "F"
 DECLARE logmsg = vc
 DECLARE errmsg = vc
 DECLARE errorcode = i4
 DECLARE reqprivcnt = i4 WITH noconstant(0)
 DECLARE exitscript(scriptstatus=vc) = null
 DECLARE deleteprivilege(null) = null
 DECLARE deleteprivilegeexceptions(null) = null
 DECLARE deleteactivityprivreltn(null) = null
 DECLARE audittransaction(null) = null
 DECLARE reseterrorinfo(null) = null
 DECLARE insertprivilegedeletionlegacy(null) = null
 DECLARE insertprivilegedeletionactivity(null) = null
 DECLARE deleteprivgroupreltns(null) = null
 DECLARE dcp_script_version = vc
 SET reqprivcnt = size(request->privilegelist,5)
 CALL deleteprivilegeexceptions(null)
 CALL deleteactivityprivreltn(null)
 CALL deleteprivgroupreltns(null)
 CALL deleteprivilege(null)
 IF ((privlocreltnid->priv_loc_reltn_id > 0))
  CALL insertprivilegedeletionlegacy(null)
 ELSE
  CALL insertprivilegedeletionactivity(null)
 ENDIF
 CALL exitscript("S")
 SUBROUTINE reseterrorinfo(null)
   CALL echo("In here - error")
   SET errorcode = 0
   SET errmsg = ""
   SET errorcode = error(errmsg,1)
   CALL echo("!!!")
 END ;Subroutine
 SUBROUTINE insertprivilegedeletionlegacy(null)
   CALL reseterrorinfo(null)
   CALL echo("inside insert privilege deletion legacy")
   INSERT  FROM privilege_deletion pd,
     (dummyt d  WITH seq = reqprivcnt)
    SET pd.privilege_deletion_id = cnvtreal(seq(reference_seq,nextval)), pd.privilege_id = request->
     privilegelist[d.seq].privilegeid, pd.privilege_cd = insertprivdellegacy->qual[reqprivcnt].
     privilege_cd,
     pd.location_cd = insertprivdellegacy->qual[reqprivcnt].location_cd, pd.person_id =
     insertprivdellegacy->qual[reqprivcnt].person_id, pd.position_cd = insertprivdellegacy->qual[
     reqprivcnt].position_cd,
     pd.ppr_cd = insertprivdellegacy->qual[reqprivcnt].ppr_cd, pd.updt_dt_tm = cnvtdatetime(curdate,
      curtime3)
    PLAN (d)
     JOIN (pd)
    WITH nocounter
   ;end insert
 END ;Subroutine
 SUBROUTINE insertprivilegedeletionactivity(null)
   CALL reseterrorinfo(null)
   CALL echo("inside insert privilege deletion activity")
   INSERT  FROM privilege_deletion pd,
     (dummyt d  WITH seq = reqprivcnt)
    SET pd.privilege_deletion_id = cnvtreal(seq(reference_seq,nextval)), pd.privilege_id = request->
     privilegelist[d.seq].privilegeid, pd.privilege_cd = insertprivdelactivity->qual[reqprivcnt].
     privilege_cd,
     pd.activity_privilege_def_id = insertprivdelactivity->qual[reqprivcnt].activity_privilege_def_id,
     pd.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    PLAN (d)
     JOIN (pd)
    WITH nocounter
   ;end insert
 END ;Subroutine
 SUBROUTINE deleteprivilege(null)
   CALL reseterrorinfo(null)
   CALL echo("Inside Delete Privilege 1")
   SELECT INTO "NL:"
    FROM privilege p,
     priv_loc_reltn plr,
     (dummyt d  WITH seq = reqprivcnt)
    PLAN (d)
     JOIN (p
     WHERE (p.privilege_id=request->privilegelist[d.seq].privilegeid)
      AND p.priv_loc_reltn_id > 0)
     JOIN (plr
     WHERE plr.priv_loc_reltn_id=p.priv_loc_reltn_id)
    ORDER BY p.privilege_id
    HEAD REPORT
     insertprivdellegacycnt = 0
    DETAIL
     insertprivdellegacycnt = (insertprivdellegacycnt+ 1)
     IF (mod(insertprivdellegacycnt,10)=1)
      stat = alterlist(insertprivdellegacy->qual,(insertprivdellegacycnt+ 9))
     ENDIF
     insertprivdellegacy->qual[insertprivdellegacycnt].privilege_cd = p.privilege_cd,
     insertprivdellegacy->qual[insertprivdellegacycnt].location_cd = plr.location_cd,
     insertprivdellegacy->qual[insertprivdellegacycnt].person_id = plr.person_id,
     insertprivdellegacy->qual[insertprivdellegacycnt].position_cd = plr.position_cd,
     insertprivdellegacy->qual[insertprivdellegacycnt].ppr_cd = plr.ppr_cd, privlocreltnid->
     priv_loc_reltn_id = p.priv_loc_reltn_id
    FOOT REPORT
     stat = alterlist(insertprivdellegacy->qual,insertprivdellegacycnt), insertprivdellegacy->
     qual_cnt = insertprivdellegacycnt
    WITH nocounter
   ;end select
   CALL echo("Inside Delete Privilege 2")
   DELETE  FROM privilege p,
     (dummyt d  WITH seq = reqprivcnt)
    SET p.seq = 1
    PLAN (d)
     JOIN (p
     WHERE (p.privilege_id=request->privilegelist[d.seq].privilegeid)
      AND p.privilege_id > 0)
    WITH nocounter
   ;end delete
   IF (errorcode > 0)
    SET logmsg = errmsg
    CALL log_status("DELETE","F","PRIVILEGE",logmsg)
    CALL exitscript("F")
   ENDIF
 END ;Subroutine
 SUBROUTINE deleteprivilegeexceptions(null)
   CALL reseterrorinfo(null)
   DELETE  FROM privilege_exception pe,
     (dummyt d  WITH seq = reqprivcnt)
    SET pe.seq = 1
    PLAN (d)
     JOIN (pe
     WHERE (pe.privilege_id=request->privilegelist[d.seq].privilegeid)
      AND pe.privilege_id > 0)
    WITH nocounter
   ;end delete
   IF (errorcode > 0)
    SET logmsg = errmsg
    CALL log_status("DELETE","F","PRIVILEGE",logmsg)
    CALL exitscript("F")
   ENDIF
 END ;Subroutine
 SUBROUTINE deleteactivityprivreltn(null)
   CALL echo("Inside DeleteActivityPrivReltn Subroutine")
   CALL reseterrorinfo(null)
   SELECT INTO "NL:"
    FROM privilege p,
     activity_privilege_reltn apr,
     (dummyt d  WITH seq = reqprivcnt)
    PLAN (d)
     JOIN (p
     WHERE (p.privilege_id=request->privilegelist[d.seq].privilegeid))
     JOIN (apr
     WHERE (apr.privilege_id=request->privilegelist[d.seq].privilegeid))
    ORDER BY p.privilege_id
    HEAD REPORT
     insertprivdelactivitycnt = 0
    DETAIL
     insertprivdelactivitycnt = (insertprivdelactivitycnt+ 1)
     IF (mod(insertprivdelactivitycnt,10)=1)
      stat = alterlist(insertprivdelactivity->qual,(insertprivdelactivitycnt+ 9))
     ENDIF
     insertprivdelactivity->qual[insertprivdelactivitycnt].privilege_cd = p.privilege_cd,
     insertprivdelactivity->qual[insertprivdelactivitycnt].activity_privilege_def_id = apr
     .activity_privilege_def_id, privlocreltnid->priv_loc_reltn_id = p.priv_loc_reltn_id
    FOOT REPORT
     stat = alterlist(insertprivdelactivity->qual,insertprivdelactivitycnt), insertprivdelactivity->
     qual_cnt = insertprivdelactivitycnt
    WITH nocounter
   ;end select
   CALL echo("Inside DeleteActivityPrivReltn Subroutine 2")
   DELETE  FROM activity_privilege_reltn apr,
     (dummyt d  WITH seq = reqprivcnt)
    SET apr.seq = 1
    PLAN (d)
     JOIN (apr
     WHERE (apr.privilege_id=request->privilegelist[d.seq].privilegeid)
      AND apr.privilege_id > 0)
    WITH nocounter
   ;end delete
   IF (errorcode > 0)
    SET logmsg = errmsg
    CALL log_status("DELETE","F","PRIVILEGE",logmsg)
    CALL exitscript("F")
   ENDIF
 END ;Subroutine
 SUBROUTINE deleteprivgroupreltns(null)
   CALL reseterrorinfo(null)
   DELETE  FROM priv_group_reltn pgr,
     (dummyt d  WITH seq = reqprivcnt)
    SET pgr.seq = 1
    PLAN (d)
     JOIN (pgr
     WHERE (pgr.privilege_id=request->privilegelist[d.seq].privilegeid)
      AND pgr.privilege_id > 0)
    WITH nocounter
   ;end delete
   IF (errorcode > 0)
    SET logmsg = errmsg
    CALL log_status("DELETE","F","PRIV_GROUP_RELTN",logmsg)
    CALL exitscript("F")
   ENDIF
 END ;Subroutine
 SUBROUTINE audittransaction(null)
   FOR (x = 1 TO reqprivcnt)
     EXECUTE cclaudit 0, "Maintain Reference Data", "Privilege",
     "Privilege", "Security Granularity Definition", "Privilege",
     "Destruction", request->privilegelist[x].privilege_id, ""
   ENDFOR
 END ;Subroutine
 SUBROUTINE exitscript(scriptstatus)
  IF (scriptstatus="F")
   SET reply->status_data.status = "F"
   SET reqinfo->commit_ind = 0
  ELSE
   CALL audittransaction(null)
   SET reply->status_data.status = "S"
   SET reqinfo->commit_ind = 1
  ENDIF
  GO TO endscript
 END ;Subroutine
#endscript
 CALL echorecord(reply)
 SET dcp_script_version = "003 11/21/08 NC014668"
END GO
