CREATE PROGRAM dcp_add_privilege:dba
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
 RECORD requestsupplement(
   1 contextlist[*]
     2 reltnid = f8
     2 privilegeid = f8
     2 dupprivrowflag = i2
     2 personname = vc
     2 existingrelationshipflag = i2
     2 exceptionlist[*]
       3 dupexceptionrowflag = i2
       3 loggroupflag = i2
   1 activityreltnid = f8
 )
 RECORD grouprecord(
   1 exceptionlist[*]
     2 exceptionid = f8
     2 exceptiontypecd = f8
     2 exceptionentityname = c40
     2 eventsetname = c100
 )
 RECORD reqtemp(
   1 grouplist[*]
     2 log_grouping_cd = f8
 )
 DECLARE dcp_script_version = vc
 SET reply->status_data.status = "F"
 DECLARE logmsg = vc
 DECLARE errmsg = vc
 DECLARE errorcode = i4
 DECLARE exitscript(scriptstatus=vc) = null
 DECLARE establishprivilegerelationship(null) = null
 DECLARE addprivlocreltn(null) = null
 DECLARE addprivilege(null) = null
 DECLARE flagduplicateprivileges(null) = null
 DECLARE reltnid = f8 WITH noconstant(0.0)
 DECLARE reqprivcnt = i4 WITH noconstant(0)
 DECLARE addexceptionlistcnt = i4 WITH noconstant(0)
 DECLARE audittransaction(null) = null
 DECLARE addprivilegeexception(null) = null
 DECLARE reseterrorinfo(null) = null
 DECLARE groupexceptcnt = i4 WITH noconstant(0)
 DECLARE itemfound = i2 WITH noconstant(0)
 DECLARE tmpexceptioncnt = i4 WITH noconstant(0)
 DECLARE bactivityprivflag = i2 WITH noconstant(false)
 DECLARE addactivityreltn(null) = null
 DECLARE preprocessrequest(null) = null
 DECLARE batch_size = i4 WITH constant(40)
 SET reqprivcnt = size(request->contextlist,5)
 IF (reqprivcnt=0
  AND (request->activityprivdefid <= 0))
  SET logmsg = "No privileges passed in to the request.  Nothing to add"
  CALL log_status("ADD","Z","PRIVILEGE DATA MODEL",logmsg)
  CALL exitscript("Z")
 ENDIF
 IF ((request->activityprivdefid > 0))
  SET bactivityprivflag = true
 ENDIF
 CALL preprocessrequest(null)
 CALL retrievgroupexceptions(null)
 SET addexceptionlistcnt = size(request->exceptionlist,5)
 CALL appendgroupexceptions(null)
 SET stat = alterlist(requestsupplement->contextlist,reqprivcnt)
 FOR (i = 1 TO reqprivcnt)
   SET stat = alterlist(requestsupplement->contextlist[i].exceptionlist,groupexceptcnt)
 ENDFOR
 IF (bactivityprivflag=false)
  CALL establishprivilegerelationship(null)
 ENDIF
 CALL addprivilege(null)
 IF (bactivityprivflag=true)
  CALL addactivityreltn(null)
 ENDIF
 IF (((addexceptionlistcnt > 0) OR (groupexceptcnt > 0
  AND bactivityprivflag=false)) )
  CALL addprivilegeexception(null)
 ENDIF
 IF (size(request->grouplist,5) > 0
  AND bactivityprivflag=false)
  CALL addprivgroupreltn(null)
 ENDIF
 CALL exitscript("S")
 SUBROUTINE preprocessrequest(null)
   DECLARE i = i4 WITH noconstant(0)
   DECLARE new_list_size = i4
   DECLARE cur_list_size = i4
   DECLARE loop_cnt = i4
   SET stat = alterlist(reqtemp->grouplist,size(request->grouplist,5))
   FOR (i = 1 TO size(request->grouplist,5))
     SET reqtemp->grouplist[i].log_grouping_cd = request->grouplist[i].log_grouping_cd
   ENDFOR
   SET cur_list_size = size(reqtemp->grouplist,5)
   SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
   SET new_list_size = (loop_cnt * batch_size)
   SET stat = alterlist(reqtemp->grouplist,new_list_size)
 END ;Subroutine
 SUBROUTINE reseterrorinfo(null)
   SET errorcode = 0
   SET errmsg = ""
   SET errorcode = error(errmsg,1)
 END ;Subroutine
 SUBROUTINE establishprivilegerelationship(null)
   DECLARE matchcnt = i4 WITH noconstant(0)
   SELECT INTO "nl:"
    FROM priv_loc_reltn plr,
     (dummyt d  WITH seq = reqprivcnt)
    PLAN (d)
     JOIN (plr
     WHERE (plr.person_id=request->contextlist[d.seq].personid)
      AND (plr.position_cd=request->contextlist[d.seq].positioncd)
      AND (plr.ppr_cd=request->contextlist[d.seq].pprcd)
      AND (plr.location_cd=request->contextlist[d.seq].locationcd)
      AND plr.active_ind=1)
    DETAIL
     requestsupplement->contextlist[d.seq].existingrelationshipflag = 1, requestsupplement->
     contextlist[d.seq].reltnid = plr.priv_loc_reltn_id, matchcnt = (matchcnt+ 1)
    WITH nocounter
   ;end select
   IF (matchcnt=reqprivcnt)
    RETURN
   ELSE
    CALL addprivlocreltn(null)
   ENDIF
 END ;Subroutine
 SUBROUTINE addprivlocreltn(null)
   CALL reseterrorinfo(null)
   FOR (i = 1 TO reqprivcnt)
     IF ((requestsupplement->contextlist[i].existingrelationshipflag=0))
      SELECT INTO "nl:"
       y = seq(reference_seq,nextval)"##################;rp0"
       FROM dual
       DETAIL
        requestsupplement->contextlist[i].reltnid = cnvtreal(y)
       WITH format, counter
      ;end select
     ENDIF
   ENDFOR
   FOR (i = 1 TO reqprivcnt)
     IF ((requestsupplement->contextlist[i].existingrelationshipflag != 1))
      INSERT  FROM priv_loc_reltn pl
       SET pl.priv_loc_reltn_id = requestsupplement->contextlist[i].reltnid, pl.person_id = request->
        contextlist[i].personid, pl.position_cd = request->contextlist[i].positioncd,
        pl.ppr_cd = request->contextlist[i].pprcd, pl.location_cd = request->contextlist[i].
        locationcd, pl.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
        pl.end_effective_dt_tm = cnvtdatetime("31-Dec-2100"), pl.active_status_dt_tm = cnvtdatetime(
         curdate,curtime3), pl.active_status_prsnl_id = reqinfo->updt_id,
        pl.updt_applctx = reqinfo->updt_applctx, pl.updt_id = reqinfo->updt_id, pl.active_ind = 1,
        pl.updt_cnt = 0, pl.updt_task = reqinfo->updt_task, pl.updt_dt_tm = cnvtdatetime(curdate,
         curtime3)
       WITH nocounter
      ;end insert
     ENDIF
   ENDFOR
   SET errorcode = error(errmsg,0)
   IF (errorcode > 0)
    SET logmsg = errmsg
    CALL log_status("INSERT","F","PRIV_LOC_RELTN",logmsg)
    CALL exitscript("F")
   ENDIF
   IF (curqual=0)
    SET logmsg = "unable to insert into priv_loc_reltn"
    CALL log_status("INSERT","F","PRIV_LOC_RELTN",logmsg)
    CALL exitscript("F")
   ENDIF
 END ;Subroutine
 SUBROUTINE flagduplicateprivileges(null)
  SELECT INTO "nl:"
   FROM privilege p,
    (dummyt d1  WITH seq = reqprivcnt)
   PLAN (d1)
    JOIN (p
    WHERE (p.priv_loc_reltn_id=requestsupplement->contextlist[d1.seq].reltnid)
     AND (p.privilege_cd=request->privilegecd)
     AND p.active_ind=1)
   DETAIL
    requestsupplement->contextlist[d1.seq].privilegeid = p.privilege_id, requestsupplement->
    contextlist[d1.seq].dupprivrowflag = 1, errmsg = concat("privilege already exists ",cnvtstring(p
      .privilege_id))
   WITH nocounter
  ;end select
  IF (curqual > 0)
   CALL log_status("INSERT","Z","PRIVILEGE",errmsg)
  ENDIF
 END ;Subroutine
 SUBROUTINE addprivilege(null)
   IF (bactivityprivflag=false)
    CALL flagduplicateprivileges(null)
   ENDIF
   CALL reseterrorinfo(null)
   FOR (i = 1 TO reqprivcnt)
     IF ((requestsupplement->contextlist[i].dupprivrowflag=0))
      SELECT INTO "nl:"
       y = seq(reference_seq,nextval)"##################;rp0"
       FROM dual
       DETAIL
        requestsupplement->contextlist[i].privilegeid = cnvtreal(y)
       WITH format, counter
      ;end select
     ENDIF
   ENDFOR
   INSERT  FROM privilege p,
     (dummyt d  WITH seq = value(reqprivcnt))
    SET p.privilege_id = requestsupplement->contextlist[d.seq].privilegeid, p.priv_loc_reltn_id =
     requestsupplement->contextlist[d.seq].reltnid, p.privilege_cd = request->privilegecd,
     p.priv_value_cd = request->privilegevaluecd, p.log_grouping_cd = request->loggroupcd, p
     .updt_applctx = reqinfo->updt_applctx,
     p.updt_id = reqinfo->updt_id, p.updt_cnt = 0, p.updt_task = reqinfo->updt_task,
     p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.active_status_dt_tm = cnvtdatetime(curdate,
      curtime3), p.active_status_prsnl_id = reqinfo->updt_id,
     p.active_ind = 1
    PLAN (d
     WHERE (requestsupplement->contextlist[d.seq].dupprivrowflag=0))
     JOIN (p)
    WITH nocounter
   ;end insert
   IF (errorcode > 0)
    SET logmsg = errmsg
    CALL log_status("INSERT","F","PRIVILEGE",logmsg)
    CALL exitscript("F")
   ENDIF
 END ;Subroutine
 SUBROUTINE addprivilegeexception(null)
   SET groupexceptcnt = size(grouprecord->exceptionlist,5)
   SELECT INTO "NL:"
    FROM privilege_exception pe,
     (dummyt d1  WITH seq = reqprivcnt),
     (dummyt d2  WITH seq = groupexceptcnt)
    PLAN (d1)
     JOIN (d2
     WHERE d2.seq <= groupexceptcnt)
     JOIN (pe
     WHERE (pe.privilege_id=requestsupplement->contextlist[d1.seq].privilegeid)
      AND (pe.exception_type_cd=grouprecord->exceptionlist[d2.seq].exceptiontypecd)
      AND (pe.exception_id=grouprecord->exceptionlist[d2.seq].exceptionid)
      AND (pe.exception_entity_name=grouprecord->exceptionlist[d2.seq].exceptionentityname)
      AND (pe.event_set_name=grouprecord->exceptionlist[d2.seq].eventsetname)
      AND pe.active_ind=1)
    DETAIL
     requestsupplement->contextlist[d1.seq].exceptionlist[d2.seq].dupexceptionrowflag = 1
    WITH nocounter
   ;end select
   CALL reseterrorinfo(null)
   INSERT  FROM privilege_exception pe,
     (dummyt d1  WITH seq = value(reqprivcnt)),
     (dummyt d2  WITH seq = value(groupexceptcnt))
    SET pe.privilege_exception_id = cnvtreal(seq(reference_seq,nextval)), pe.privilege_id =
     requestsupplement->contextlist[d1.seq].privilegeid, pe.exception_type_cd = grouprecord->
     exceptionlist[d2.seq].exceptiontypecd,
     pe.exception_entity_name = grouprecord->exceptionlist[d2.seq].exceptionentityname, pe
     .event_set_name = grouprecord->exceptionlist[d2.seq].eventsetname, pe.exception_id = grouprecord
     ->exceptionlist[d2.seq].exceptionid,
     pe.updt_dt_tm = cnvtdatetime(curdate,curtime), pe.updt_id = reqinfo->updt_id, pe.updt_task =
     reqinfo->updt_task,
     pe.updt_applctx = reqinfo->updt_applctx, pe.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
     pe.active_status_prsnl_id = reqinfo->updt_id,
     pe.active_ind = 1, pe.updt_cnt = 0
    PLAN (d1)
     JOIN (d2
     WHERE d2.seq <= groupexceptcnt
      AND (requestsupplement->contextlist[d1.seq].exceptionlist[d2.seq].dupexceptionrowflag=0))
     JOIN (pe)
    WITH nocounter
   ;end insert
   IF (errorcode > 0)
    SET logmsg = errmsg
    CALL log_status("INSERT","F","PRIVILEGE_EXCEPTION",logmsg)
    CALL exitscript("F")
   ENDIF
 END ;Subroutine
 SUBROUTINE retrievgroupexceptions(null)
   IF (size(request->grouplist,5) > 0)
    DECLARE idx = i4 WITH noconstant(0)
    DECLARE nstart = i4 WITH noconstant(1)
    DECLARE loop_cnt = i4
    SET loop_cnt = ceil((cnvtreal(size(reqtemp->grouplist,5))/ batch_size))
    DECLARE num = i4 WITH noconstant(0)
    DECLARE start = i4 WITH noconstant(1)
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = value(loop_cnt)),
      log_group_entry lge
     PLAN (d1
      WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
      JOIN (lge
      WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),lge.log_grouping_cd,reqtemp->grouplist[idx].
       log_grouping_cd)
       AND lge.log_grouping_cd > 0)
     HEAD REPORT
      groupexceptcnt = 0
     DETAIL
      pos = locateval(num,start,size(grouprecord->exceptionlist,5),lge.item_cd,grouprecord->
       exceptionlist[num].exceptionid)
      IF (pos <= 0)
       groupexceptcnt = (groupexceptcnt+ 1)
       IF (groupexceptcnt > size(grouprecord->exceptionlist,5))
        stat = alterlist(grouprecord->exceptionlist,(groupexceptcnt+ 9))
       ENDIF
       grouprecord->exceptionlist[groupexceptcnt].exceptionid = lge.item_cd, grouprecord->
       exceptionlist[groupexceptcnt].exceptionentityname = lge.exception_entity_name, grouprecord->
       exceptionlist[groupexceptcnt].exceptiontypecd = lge.exception_type_cd,
       grouprecord->exceptionlist[groupexceptcnt].eventsetname = lge.event_set_name
      ENDIF
     WITH nocounter
    ;end select
    SET stat = alterlist(grouprecord->exceptionlist,groupexceptcnt)
   ELSEIF ((request->loggroupcd > 0))
    SELECT INTO "nl:"
     FROM log_group_entry lge
     WHERE (lge.log_grouping_cd=request->loggroupcd)
      AND (request->loggroupcd > 0)
     HEAD REPORT
      groupexceptcnt = 0
     DETAIL
      groupexceptcnt = (groupexceptcnt+ 1)
      IF (groupexceptcnt > size(grouprecord->exceptionlist,5))
       stat = alterlist(grouprecord->exceptionlist,(groupexceptcnt+ 9))
      ENDIF
      grouprecord->exceptionlist[groupexceptcnt].exceptionid = lge.item_cd, grouprecord->
      exceptionlist[groupexceptcnt].exceptionentityname = lge.exception_entity_name, grouprecord->
      exceptionlist[groupexceptcnt].exceptiontypecd = lge.exception_type_cd,
      grouprecord->exceptionlist[groupexceptcnt].eventsetname = lge.event_set_name
     WITH nocounter
    ;end select
    SET stat = alterlist(grouprecord->exceptionlist,groupexceptcnt)
   ENDIF
 END ;Subroutine
 SUBROUTINE appendgroupexceptions(null)
   DECLARE num = i4 WITH noconstant(0)
   DECLARE start = i4 WITH noconstant(1)
   DECLARE pos = i4 WITH noconstant(0)
   SET tmpexceptioncnt = groupexceptcnt
   IF (groupexceptcnt=0)
    SET stat = alterlist(grouprecord->exceptionlist,addexceptionlistcnt)
    FOR (x = 1 TO addexceptionlistcnt)
      SET grouprecord->exceptionlist[x].exceptionid = request->exceptionlist[x].exceptionid
      SET grouprecord->exceptionlist[x].exceptionentityname = request->exceptionlist[x].
      exceptionentityname
      SET grouprecord->exceptionlist[x].exceptiontypecd = request->exceptionlist[x].exceptiontypecd
      SET grouprecord->exceptionlist[x].eventsetname = request->exceptionlist[x].eventsetname
    ENDFOR
    SET stat = alterlist(grouprecord->exceptionlist,addexceptionlistcnt)
   ELSE
    FOR (x = 1 TO addexceptionlistcnt)
      SET num = 0
      SET pos = 0
      SET pos = locateval(num,start,size(grouprecord->exceptionlist,5),request->exceptionlist[x].
       exceptionid,grouprecord->exceptionlist[num].exceptionid)
      IF (pos <= 0)
       SET groupexceptcnt = (groupexceptcnt+ 1)
       IF (groupexceptcnt > size(grouprecord->exceptionlist,5))
        SET stat = alterlist(grouprecord->exceptionlist,(groupexceptcnt+ 9))
       ENDIF
       SET grouprecord->exceptionlist[groupexceptcnt].exceptionid = request->exceptionlist[x].
       exceptionid
       SET grouprecord->exceptionlist[groupexceptcnt].exceptionentityname = request->exceptionlist[x]
       .exceptionentityname
       SET grouprecord->exceptionlist[groupexceptcnt].exceptiontypecd = request->exceptionlist[x].
       exceptiontypecd
       SET grouprecord->exceptionlist[groupexceptcnt].eventsetname = request->exceptionlist[x].
       eventsetname
      ENDIF
    ENDFOR
    SET stat = alterlist(grouprecord->exceptionlist,groupexceptcnt)
   ENDIF
 END ;Subroutine
 SUBROUTINE addactivityreltn(null)
   CALL echo("Activity Reltn")
   CALL reseterrorinfo(null)
   SELECT INTO "nl:"
    y = seq(reference_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     requestsupplement->activityreltnid = cnvtreal(y)
    WITH format, counter
   ;end select
   FOR (i = 1 TO reqprivcnt)
     INSERT  FROM activity_privilege_reltn apr
      SET apr.activity_privilege_reltn_id = requestsupplement->activityreltnid, apr.privilege_id =
       requestsupplement->contextlist[i].privilegeid, apr.activity_privilege_def_id = request->
       activityprivdefid,
       apr.active_status_dt_tm = cnvtdatetime(curdate,curtime3), apr.active_status_prsnl_id = reqinfo
       ->updt_id, apr.updt_applctx = reqinfo->updt_applctx,
       apr.updt_id = reqinfo->updt_id, apr.active_ind = 1, apr.updt_cnt = 0,
       apr.updt_task = reqinfo->updt_task, apr.updt_dt_tm = cnvtdatetime(curdate,curtime3)
      WITH nocounter
     ;end insert
   ENDFOR
   SET errorcode = error(errmsg,0)
   IF (errorcode > 0)
    SET logmsg = errmsg
    CALL log_status("INSERT","F","ACTIVITY_PRIVILEGE_RELTN",logmsg)
    CALL exitscript("F")
   ENDIF
   IF (curqual=0)
    SET logmsg = "unable to insert into activity_privilege_reltn"
    CALL log_status("INSERT","F","ACTIVITY_PRIVILEGE_RELTN",logmsg)
    CALL exitscript("F")
   ENDIF
 END ;Subroutine
 SUBROUTINE addprivgroupreltn(null)
   DECLARE groupcnt = i4 WITH noconstant(size(request->grouplist,5))
   INSERT  FROM priv_group_reltn pgr,
     (dummyt d1  WITH seq = value(reqprivcnt)),
     (dummyt d2  WITH seq = value(groupcnt))
    SET pgr.priv_group_reltn_id = cnvtreal(seq(reference_seq,nextval)), pgr.privilege_id =
     requestsupplement->contextlist[d1.seq].privilegeid, pgr.log_grouping_cd = request->grouplist[d2
     .seq].log_grouping_cd,
     pgr.updt_dt_tm = cnvtdatetime(curdate,curtime), pgr.updt_id = reqinfo->updt_id, pgr.updt_task =
     reqinfo->updt_task,
     pgr.updt_applctx = reqinfo->updt_applctx, pgr.updt_cnt = 0
    PLAN (d1)
     JOIN (d2
     WHERE d2.seq <= groupcnt)
     JOIN (pgr
     WHERE (requestsupplement->contextlist[d1.seq].privilegeid > 0)
      AND (request->grouplist[d2.seq].log_grouping_cd > 0))
    WITH nocounter
   ;end insert
   IF (errorcode > 0)
    SET logmsg = errmsg
    CALL log_status("INSERT","F","PRIV_GROUP_RELTN",logmsg)
    CALL exitscript("F")
   ENDIF
 END ;Subroutine
 SUBROUTINE audittransaction(null)
   DECLARE exceptioncnt = i4 WITH noconstant(0)
   DECLARE auditstring = vc WITH public, noconstant(fillstring(220," "))
   DECLARE personname = vc WITH public, noconstant(fillstring(100," "))
   DECLARE position = vc WITH public, noconstant(fillstring(40," "))
   DECLARE location = vc WITH public, noconstant(fillstring(40," "))
   DECLARE ppr = vc WITH public, noconstant(fillstring(40," "))
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(reqprivcnt)),
     person p
    PLAN (d)
     JOIN (p
     WHERE (p.person_id=request->contextlist[d.seq].personid))
    DETAIL
     IF ((request->contextlist[d.seq].personid > 0))
      requestsupplement->contextlist[d.seq].personname = trim(p.name_full_formatted)
     ENDIF
    WITH nocounter
   ;end select
   FOR (i = 1 TO reqprivcnt)
     SET exceptioncnt = 0
     IF ((requestsupplement->contextlist[i].personname > ""))
      SET auditstring = requestsupplement->contextlist[i].personname
     ENDIF
     IF ((request->contextlist[i].locationcd > 0))
      SET location = trim(uar_get_code_display(request->contextlist[i].locationcd))
      IF (location > "")
       IF (auditstring > "")
        SET auditstring = concat(auditstring,"/",location)
       ELSE
        SET auditstring = concat(auditstring,location)
       ENDIF
      ENDIF
     ENDIF
     IF ((request->contextlist[i].locationcd > 0))
      SET position = trim(uar_get_code_display(request->contextlist[i].positioncd))
      IF (position > "")
       IF (auditstring > "")
        SET auditstring = concat(auditstring,"/",position)
       ELSE
        SET auditstring = concat(auditstring,position)
       ENDIF
      ENDIF
     ENDIF
     IF ((request->contextlist[i].pprcd > 0))
      SET ppr = trim(uar_get_code_display(request->contextlist[i].pprcd))
      IF (ppr > "")
       IF (auditstring > "")
        SET auditstring = concat(auditstring,"/",ppr)
       ELSE
        SET auditstring = concat(auditstring,ppr)
       ENDIF
      ENDIF
     ENDIF
     EXECUTE cclaudit 0, "Maintain Reference Data", "Privilege",
     "Privilege", "Security Granularity Definition", "Privilege",
     "Origination", requestsupplement->contextlist[i].privilegeid, auditstring
     SET exceptioncnt = addexceptionlistcnt
     IF (exceptioncnt > 0)
      EXECUTE cclaudit 0, "Maintain Reference Data", "Exception",
      "Privilege", "Security Granularity Definition", "Privilege",
      "Origination", requestsupplement->contextlist[i].privilegeid, auditstring
     ENDIF
     IF ((requestsupplement->contextlist[i].existingrelationshipflag=0))
      EXECUTE cclaudit 0, "Maintain Reference Data", "RelationShip",
      "Privilege", "Security Granularity Definition", "Privilege",
      "Origination", requestsupplement->contextlist[i].privilegeid, auditstring
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE exitscript(scriptstatus)
  IF (scriptstatus="F")
   SET reply->status_data.status = "F"
   SET reqinfo->commit_ind = 0
  ELSEIF (scriptstatus="S")
   SET reply->status_data.status = "S"
   SET reqinfo->commit_ind = 1
   CALL audittransaction(size(request->contextlist,5))
  ENDIF
  GO TO endscript
 END ;Subroutine
#endscript
 SET dcp_script_version = "002 11/21/08 NC014668"
END GO
