CREATE PROGRAM dcp_upd_privilege:dba
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
 RECORD reqtemp(
   1 privilegelist[*]
     2 privilegeid = f8
   1 delexceptionlist[*]
     2 privilegeexceptionid = f8
   1 addgrouplist[*]
     2 log_grouping_cd = f8
   1 delgrouplist[*]
     2 log_grouping_cd = f8
 )
 RECORD loggrpcdchangedlist(
   1 qual[*]
     2 privilege_id = f8
     2 prev_log_grouping_cd = f8
 )
 RECORD delgroupexceptlist(
   1 qual[*]
     2 privilege_id = f8
     2 exception_id = f8
 )
 RECORD addgroupexceptlist(
   1 qual[*]
     2 privilege_id = f8
     2 exception_id = f8
     2 exception_type_cd = f8
     2 exception_entity_name = vc
     2 event_set_name = vc
 )
 RECORD insertprivdel(
   1 qual_cnt = i4
   1 qual[*]
     2 privilege_cd = f8
     2 location_cd = f8
     2 person_id = f8
     2 position_cd = f8
     2 ppr_cd = f8
 )
 RECORD undeleteableprivilegeexceptions(
   1 privileges[*]
     2 privilege_id = f8
     2 exception_cnt = i4
     2 exceptions[*]
       3 item_cd = f8
 )
 RECORD addmultiplegroupexceptions(
   1 qual[*]
     2 exception_id = f8
     2 exception_type_cd = f8
     2 exception_entity_name = vc
     2 event_set_name = vc
 )
 RECORD privgroupreltnadditions(
   1 qual[*]
     2 privilege_id = f8
     2 log_group_cd = f8
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
   1 privilegelist[*]
     2 addexceptionlist[*]
       3 exceptionid = f8
       3 dupexceptionrowflag = i2
 )
 SET reply->status_data.status = "F"
 DECLARE dcp_script_version = vc
 DECLARE logmsg = vc
 DECLARE errmsg = vc
 DECLARE errorcode = i4 WITH noconstant(0)
 DECLARE reqprivcnt = i4 WITH noconstant(0)
 DECLARE loggrpcdchangedcnt = i2 WITH noconstant(0)
 DECLARE addgroupexceptcnt = i2 WITH noconstant(0)
 DECLARE delgroupexceptcnt = i2 WITH noconstant(0)
 DECLARE privgroupreltnadditionscnt = i2 WITH noconstant(0)
 DECLARE addexceptioncnt = i4 WITH noconstant(0)
 DECLARE delexceptioncnt = i4 WITH noconstant(0)
 DECLARE iactivityprivflag = i2 WITH noconstant(false)
 DECLARE batch_size = i4 WITH constant(40)
 DECLARE checkifloggrpcdchanged(null) = null
 DECLARE addgroupexception(null) = null
 DECLARE delgroupexception(null) = null
 DECLARE updateprivilege(null) = null
 DECLARE findmaxexceptionlistsizes(null) = null
 DECLARE delprivilegeexceptions(null) = null
 DECLARE addprivilegeexceptions(null) = null
 DECLARE exitscript(scriptstatus=vc) = null
 DECLARE reseterrorinfo(null) = null
 DECLARE audittransaction(null) = null
 DECLARE preprocessrequest(null) = null
 DECLARE removelegacygroupsfromprivileges(null) = null
 DECLARE delmultiplegroupexception(null) = null
 DECLARE delmultiplegroups(null) = null
 DECLARE addmultiplegroupexception(null) = null
 DECLARE addmultiplegroups(null) = null
 DECLARE insertprivilegedeletion(null) = null
 SET reqprivcnt = size(request->privilegelist,5)
 IF (reqprivcnt=0)
  SET errmsg = "No privileges passed in to the request.  Nothing to update"
  CALL log_status("ADD","Z","PRIVILEGE DATA MODEL",errmsg)
  CALL exitscript("Z")
 ENDIF
 IF ((request->updategroupflag=1))
  CALL checkifloggrpcdchanged(null)
  IF (loggrpcdchangedcnt > 0)
   CALL echo("THIS IS A TEST - inside update group flag, log grp changed")
   CALL delgroupexception(null)
   CALL insertprivilegedeletion(null)
   IF ((request->loggroupcd > 0)
    AND iactivityprivflag=0)
    CALL addgroupexception(null)
   ENDIF
  ENDIF
  CALL updateprivilege(reqprivcnt)
 ELSEIF ((request->updategroupflag=2))
  CALL preprocessrequest(null)
  CALL removelegacygroupsfromprivileges(null)
  IF (size(request->delgrouplist,5) > 0)
   CALL delmultiplegroupexception(null)
   CALL delmultiplegroups(null)
  ENDIF
  CALL insertprivilegedeletion(null)
  IF (size(request->addgrouplist,5) > 0)
   CALL addmultiplegroupexception(null)
   CALL addmultiplegroups(null)
  ENDIF
 ENDIF
 CALL findexceptionlistmaxsize(reqprivcnt)
 CALL delprivilegeexceptions(reqprivcnt)
 IF ((request->updategroupflag=0))
  CALL insertprivilegedeletion(null)
 ENDIF
 CALL addprivilegeexceptions(reqprivcnt)
 CALL exitscript("S")
 SUBROUTINE preprocessrequest(null)
   DECLARE i = i4 WITH noconstant(0)
   DECLARE new_list_size = i4
   DECLARE cur_list_size = i4
   DECLARE loop_cnt = i4
   SET stat = alterlist(reqtemp->privilegelist,size(request->privilegelist,5))
   SET stat = alterlist(reqtemp->addgrouplist,size(request->addgrouplist,5))
   SET stat = alterlist(reqtemp->delgrouplist,size(request->delgrouplist,5))
   SET stat = alterlist(undeleteableprivilegeexceptions->privileges,size(request->privilegelist,5))
   FOR (i = 1 TO size(request->privilegelist,5))
     SET reqtemp->privilegelist[i].privilegeid = request->privilegelist[i].privilegeid
   ENDFOR
   SET cur_list_size = size(reqtemp->privilegelist,5)
   SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
   SET new_list_size = (loop_cnt * batch_size)
   SET stat = alterlist(reqtemp->privilegelist,new_list_size)
   FOR (i = 1 TO size(request->addgrouplist,5))
     SET reqtemp->addgrouplist[i].log_grouping_cd = request->addgrouplist[i].log_group_cd
   ENDFOR
   SET cur_list_size = size(request->addgrouplist,5)
   SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
   SET new_list_size = (loop_cnt * batch_size)
   SET stat = alterlist(reqtemp->addgrouplist,new_list_size)
   FOR (i = 1 TO size(request->delgrouplist,5))
     SET reqtemp->delgrouplist[i].log_grouping_cd = request->delgrouplist[i].log_group_cd
   ENDFOR
   SET cur_list_size = size(request->delgrouplist,5)
   SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
   SET new_list_size = (loop_cnt * batch_size)
   SET stat = alterlist(reqtemp->delgrouplist,new_list_size)
   FOR (i = 1 TO size(request->privilegelist,5))
    SET undeleteableprivilegeexceptions->privileges[i].privilege_id = request->privilegelist[i].
    privilegeid
    SET undeleteableprivilegeexceptions->privileges[i].exception_cnt = 0
   ENDFOR
   SET cur_list_size = size(undeleteableprivilegeexceptions->privileges,5)
   SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
   SET new_list_size = (loop_cnt * batch_size)
   SET stat = alterlist(undeleteableprivilegeexceptions->privileges,new_list_size)
 END ;Subroutine
 SUBROUTINE removelegacygroupsfromprivileges(null)
   DECLARE idx = i4 WITH noconstant(0)
   DECLARE nstart = i4 WITH noconstant(1)
   DECLARE loop_cnt = i4
   SET loop_cnt = ceil((cnvtreal(size(reqtemp->privilegelist,5))/ batch_size))
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(loop_cnt)),
     privilege p
    PLAN (d1
     WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
     JOIN (p
     WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),p.privilege_id,reqtemp->privilegelist[idx].
      privilegeid)
      AND p.privilege_id > 0
      AND p.log_grouping_cd > 0)
    HEAD REPORT
     privgroupreltnadditionscnt = 0
    DETAIL
     privgroupreltnadditionscnt = (privgroupreltnadditionscnt+ 1)
     IF (mod(privgroupreltnadditionscnt,10)=1)
      stat = alterlist(privgroupreltnadditions->qual,(privgroupreltnadditionscnt+ 9))
     ENDIF
     privgroupreltnadditions->qual[privgroupreltnadditionscnt].privilege_id = p.privilege_id,
     privgroupreltnadditions->qual[privgroupreltnadditionscnt].log_group_cd = p.log_grouping_cd
    FOOT REPORT
     stat = alterlist(privgroupreltnadditions->qual,privgroupreltnadditionscnt)
    WITH nocounter
   ;end select
   IF (privgroupreltnadditionscnt > 0)
    INSERT  FROM priv_group_reltn pgr,
      (dummyt d1  WITH seq = size(privgroupreltnadditions->qual,5))
     SET pgr.priv_group_reltn_id = cnvtreal(seq(reference_seq,nextval)), pgr.privilege_id =
      privgroupreltnadditions->qual[d1.seq].privilege_id, pgr.log_grouping_cd =
      privgroupreltnadditions->qual[d1.seq].log_group_cd,
      pgr.updt_id = reqinfo->updt_id, pgr.updt_dt_tm = cnvtdatetime(curdate,curtime), pgr.updt_task
       = reqinfo->updt_task,
      pgr.updt_applctx = reqinfo->updt_applctx, pgr.updt_cnt = 0
     PLAN (d1)
      JOIN (pgr)
     WITH nocounter
    ;end insert
    CALL reseterrorinfo(null)
    SELECT INTO "nl:"
     p.privilege_id
     FROM (dummyt d1  WITH seq = value(privgroupreltnadditionscnt)),
      privilege p
     PLAN (d1)
      JOIN (p
      WHERE (p.privilege_id=privgroupreltnadditions->qual[d1.seq].privilege_id))
     WITH nocounter, forupdate(p)
    ;end select
    IF (curqual=0)
     SET logmsg = "unable to lock privilege row for update"
     CALL log_status("LOCK","F","PRIVILEGE",logmsg)
     CALL exitscript("F")
    ENDIF
    IF (errorcode > 0)
     SET logmsg = errmsg
     CALL log_status("PRIVILEGE","F","PRIVILEGE",logmsg)
     CALL exitscript("F")
    ENDIF
    CALL reseterrorinfo(null)
    UPDATE  FROM privilege p,
      (dummyt d  WITH seq = value(privgroupreltnadditionscnt))
     SET p.log_grouping_cd = 0, p.updt_applctx = reqinfo->updt_applctx, p.updt_id = reqinfo->updt_id,
      p.updt_cnt = (p.updt_cnt+ 1), p.updt_task = reqinfo->updt_task, p.updt_dt_tm = cnvtdatetime(
       curdate,curtime3),
      p.active_status_dt_tm = cnvtdatetime(curdate,curtime3), p.active_status_prsnl_id = reqinfo->
      updt_id
     PLAN (d)
      JOIN (p
      WHERE (p.privilege_id=privgroupreltnadditions->qual[d.seq].privilege_id)
       AND (request->updategroupflag > 0))
     WITH nocounter
    ;end update
    IF (errorcode > 0)
     SET logmsg = errmsg
     CALL log_status("PRIVILEGE","F","PRIVILEGE",logmsg)
     CALL exitscript("F")
    ENDIF
    IF (curqual=0)
     SET logmsg = "privilege table not updated"
     CALL log_status("UPDATE","I","PRIVILEGE",logmsg)
    ELSE
     CALL echo("NUMBER OF PRIVILEGES UPDATED")
     CALL echo(curqual)
    ENDIF
   ENDIF
   COMMIT
 END ;Subroutine
 SUBROUTINE delmultiplegroupexception(null)
   DECLARE idx = i4 WITH noconstant(0)
   DECLARE nstart = i4 WITH noconstant(1)
   DECLARE loop_cnt = i4
   SET loop_cnt = ceil((cnvtreal(size(undeleteableprivilegeexceptions->privileges,5))/ batch_size))
   DECLARE num = i4 WITH noconstant(0)
   DECLARE start = i4 WITH noconstant(1)
   DECLARE num2 = i4 WITH noconstant(0)
   DECLARE start2 = i4 WITH noconstant(1)
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(loop_cnt)),
     priv_group_reltn pgr,
     log_group_entry lge
    PLAN (d1
     WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
     JOIN (pgr
     WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),pgr.privilege_id,
      undeleteableprivilegeexceptions->privileges[idx].privilege_id)
      AND pgr.privilege_id > 0
      AND pgr.log_grouping_cd > 0)
     JOIN (lge
     WHERE lge.log_grouping_cd=pgr.log_grouping_cd)
    DETAIL
     pos = locateval(num,start,size(request->delgrouplist,5),lge.log_grouping_cd,request->
      delgrouplist[num].log_group_cd)
     IF (pos <= 0)
      pos = locateval(num,start,size(undeleteableprivilegeexceptions->privileges,5),pgr.privilege_id,
       undeleteableprivilegeexceptions->privileges[num].privilege_id)
      IF (pos != 0)
       pos2 = locateval(num2,start2,size(undeleteableprivilegeexceptions->privileges[pos].exceptions,
         5),lge.item_cd,undeleteableprivilegeexceptions->privileges[pos].exceptions[num2].item_cd)
       IF (pos2 <= 0)
        undeleteableprivilegeexceptions->privileges[pos].exception_cnt = (
        undeleteableprivilegeexceptions->privileges[pos].exception_cnt+ 1), stat = alterlist(
         undeleteableprivilegeexceptions->privileges[pos].exceptions,undeleteableprivilegeexceptions
         ->privileges[pos].exception_cnt), undeleteableprivilegeexceptions->privileges[pos].
        exceptions[undeleteableprivilegeexceptions->privileges[pos].exception_cnt].item_cd = lge
        .item_cd
       ENDIF
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   SET idx = 0
   SET nstart = 1
   SET loop_cnt = ceil((cnvtreal(size(reqtemp->privilegelist,5))/ batch_size))
   DECLARE idx2 = i4 WITH noconstant(0)
   DECLARE nstart2 = i4 WITH noconstant(1)
   DECLARE loop_cnt2 = i4
   SET loop_cnt2 = ceil((cnvtreal(size(reqtemp->delgrouplist,5))/ batch_size))
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(loop_cnt)),
     (dummyt d2  WITH seq = value(loop_cnt2)),
     priv_group_reltn pgr,
     log_group_entry lge
    PLAN (d1
     WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
     JOIN (d2
     WHERE initarray(nstart2,evaluate(d2.seq,1,1,(nstart2+ batch_size))))
     JOIN (pgr
     WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),pgr.privilege_id,reqtemp->privilegelist[idx].
      privilegeid)
      AND pgr.privilege_id > 0)
     JOIN (lge
     WHERE lge.log_grouping_cd=pgr.log_grouping_cd)
    HEAD REPORT
     delgroupexceptcnt = 0
    DETAIL
     pos = locateval(num,start,size(reqtemp->delgrouplist,5),pgr.log_grouping_cd,reqtemp->
      delgrouplist[num].log_grouping_cd)
     IF (pos != 0)
      num = 0, pos = locateval(num,start,size(undeleteableprivilegeexceptions->privileges,5),pgr
       .privilege_id,undeleteableprivilegeexceptions->privileges[num].privilege_id)
      IF (pos != 0)
       pos2 = locateval(num,start,size(undeleteableprivilegeexceptions->privileges[pos].exceptions,5),
        lge.item_cd,undeleteableprivilegeexceptions->privileges[pos].exceptions[num].item_cd)
       IF (pos2 <= 0)
        delgroupexceptcnt = (delgroupexceptcnt+ 1)
        IF (mod(delgroupexceptcnt,10)=1)
         stat = alterlist(delgroupexceptlist->qual,(delgroupexceptcnt+ 9))
        ENDIF
        delgroupexceptlist->qual[delgroupexceptcnt].privilege_id = pgr.privilege_id,
        delgroupexceptlist->qual[delgroupexceptcnt].exception_id = lge.item_cd
       ENDIF
      ENDIF
     ENDIF
    FOOT REPORT
     stat = alterlist(delgroupexceptlist->qual,delgroupexceptcnt)
    WITH nocounter
   ;end select
   IF (delgroupexceptcnt > 0)
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
      insertprivdelcnt = 0
     DETAIL
      insertprivdelcnt = (insertprivdelcnt+ 1)
      IF (mod(insertprivdelcnt,10)=1)
       stat = alterlist(insertprivdel->qual,(insertprivdelcnt+ 9))
      ENDIF
      insertprivdel->qual[insertprivdelcnt].privilege_cd = p.privilege_cd, insertprivdel->qual[
      insertprivdelcnt].location_cd = plr.location_cd, insertprivdel->qual[insertprivdelcnt].
      person_id = plr.person_id,
      insertprivdel->qual[insertprivdelcnt].position_cd = plr.position_cd, insertprivdel->qual[
      insertprivdelcnt].ppr_cd = plr.ppr_cd
     FOOT REPORT
      stat = alterlist(insertprivdel->qual,insertprivdelcnt), insertprivdel->qual_cnt =
      insertprivdelcnt
     WITH nocounter
    ;end select
    DELETE  FROM privilege_exception pe,
      (dummyt d  WITH seq = delgroupexceptcnt)
     SET pe.seq = 1
     PLAN (d)
      JOIN (pe
      WHERE (pe.privilege_id=delgroupexceptlist->qual[d.seq].privilege_id)
       AND (pe.exception_id=delgroupexceptlist->qual[d.seq].exception_id)
       AND pe.privilege_id > 0
       AND pe.exception_id > 0)
     WITH nocounter
    ;end delete
   ENDIF
 END ;Subroutine
 SUBROUTINE delmultiplegroups(null)
   DELETE  FROM priv_group_reltn pgr,
     (dummyt d1  WITH seq = size(request->delgrouplist,5)),
     (dummyt d2  WITH seq = size(request->privilegelist,5))
    SET pgr.seq = 1
    PLAN (d1)
     JOIN (d2
     WHERE d2.seq <= size(request->privilegelist,5))
     JOIN (pgr
     WHERE (pgr.privilege_id=request->privilegelist[d2.seq].privilegeid)
      AND (pgr.log_grouping_cd=request->delgrouplist[d1.seq].log_group_cd)
      AND pgr.privilege_id > 0
      AND pgr.log_grouping_cd > 0)
    WITH nocounter
   ;end delete
 END ;Subroutine
 SUBROUTINE addmultiplegroupexception(null)
   DECLARE idx = i4 WITH noconstant(0)
   DECLARE nstart = i4 WITH noconstant(1)
   DECLARE loop_cnt = i4
   SET loop_cnt = ceil((cnvtreal(size(reqtemp->addgrouplist,5))/ batch_size))
   DECLARE num = i4 WITH noconstant(0)
   DECLARE start = i4 WITH noconstant(1)
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(loop_cnt)),
     log_group_entry lge
    PLAN (d1
     WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
     JOIN (lge
     WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),lge.log_grouping_cd,reqtemp->addgrouplist[idx
      ].log_grouping_cd)
      AND lge.log_grouping_cd > 0)
    HEAD REPORT
     addgroupexceptcnt = 0
    DETAIL
     pos = locateval(num,start,size(addmultiplegroupexceptions->qual,5),lge.item_cd,
      addmultiplegroupexceptions->qual[num].exception_id)
     IF (pos <= 0)
      addgroupexceptcnt = (addgroupexceptcnt+ 1)
      IF (mod(addgroupexceptcnt,10)=1)
       stat = alterlist(addmultiplegroupexceptions->qual,(addgroupexceptcnt+ 9))
      ENDIF
      addmultiplegroupexceptions->qual[addgroupexceptcnt].exception_id = lge.item_cd,
      addmultiplegroupexceptions->qual[addgroupexceptcnt].exception_entity_name = lge
      .exception_entity_name, addmultiplegroupexceptions->qual[addgroupexceptcnt].exception_type_cd
       = lge.exception_type_cd,
      addmultiplegroupexceptions->qual[addgroupexceptcnt].event_set_name = lge.event_set_name
     ENDIF
    FOOT REPORT
     stat = alterlist(addmultiplegroupexceptions->qual,addgroupexceptcnt)
    WITH nocounter
   ;end select
   DECLARE i = i4
   DECLARE j = i4
   SET addgroupexceptcnt = 0
   FOR (i = 1 TO size(request->privilegelist,5))
     FOR (j = 1 TO size(addmultiplegroupexceptions->qual,5))
       SET addgroupexceptcnt = (addgroupexceptcnt+ 1)
       IF (mod(addgroupexceptcnt,10)=1)
        SET stat = alterlist(addgroupexceptlist->qual,(addgroupexceptcnt+ 9))
       ENDIF
       SET addgroupexceptlist->qual[addgroupexceptcnt].privilege_id = request->privilegelist[i].
       privilegeid
       SET addgroupexceptlist->qual[addgroupexceptcnt].exception_id = addmultiplegroupexceptions->
       qual[j].exception_id
       SET addgroupexceptlist->qual[addgroupexceptcnt].exception_entity_name =
       addmultiplegroupexceptions->qual[j].exception_entity_name
       SET addgroupexceptlist->qual[addgroupexceptcnt].exception_type_cd = addmultiplegroupexceptions
       ->qual[j].exception_type_cd
       SET addgroupexceptlist->qual[addgroupexceptcnt].event_set_name = addmultiplegroupexceptions->
       qual[j].event_set_name
     ENDFOR
   ENDFOR
   SET stat = alterlist(addgroupexceptlist->qual,addgroupexceptcnt)
   SELECT INTO "NL:"
    FROM privilege_exception pe,
     (dummyt d  WITH seq = addgroupexceptcnt)
    PLAN (d)
     JOIN (pe
     WHERE (pe.privilege_id=addgroupexceptlist->qual[d.seq].privilege_id)
      AND (pe.exception_id=addgroupexceptlist->qual[d.seq].exception_id)
      AND pe.active_ind=1)
    DETAIL
     addgroupexceptlist->qual[d.seq].privilege_id = 0
    WITH nocounter
   ;end select
   INSERT  FROM privilege_exception pe,
     (dummyt d1  WITH seq = addgroupexceptcnt)
    SET pe.privilege_exception_id = cnvtreal(seq(reference_seq,nextval)), pe.privilege_id =
     addgroupexceptlist->qual[d1.seq].privilege_id, pe.exception_type_cd = addgroupexceptlist->qual[
     d1.seq].exception_type_cd,
     pe.exception_entity_name = addgroupexceptlist->qual[d1.seq].exception_entity_name, pe
     .event_set_name = addgroupexceptlist->qual[d1.seq].event_set_name, pe.exception_id =
     addgroupexceptlist->qual[d1.seq].exception_id,
     pe.updt_dt_tm = cnvtdatetime(curdate,curtime), pe.updt_id = reqinfo->updt_id, pe.updt_task =
     reqinfo->updt_task,
     pe.updt_applctx = reqinfo->updt_applctx, pe.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
     pe.active_status_prsnl_id = reqinfo->updt_id,
     pe.active_ind = 1, pe.updt_cnt = 0
    PLAN (d1
     WHERE (addgroupexceptlist->qual[d1.seq].privilege_id > 0))
     JOIN (pe)
    WITH nocounter
   ;end insert
 END ;Subroutine
 SUBROUTINE addmultiplegroups(null)
   INSERT  FROM priv_group_reltn pgr,
     (dummyt d1  WITH seq = size(request->addgrouplist,5)),
     (dummyt d2  WITH seq = size(request->privilegelist,5))
    SET pgr.priv_group_reltn_id = cnvtreal(seq(reference_seq,nextval)), pgr.privilege_id = request->
     privilegelist[d2.seq].privilegeid, pgr.log_grouping_cd = request->addgrouplist[d1.seq].
     log_group_cd,
     pgr.updt_id = reqinfo->updt_id, pgr.updt_dt_tm = cnvtdatetime(curdate,curtime), pgr.updt_task =
     reqinfo->updt_task,
     pgr.updt_applctx = reqinfo->updt_applctx, pgr.updt_cnt = 0
    PLAN (d1)
     JOIN (d2
     WHERE d2.seq <= size(request->privilegelist,5))
     JOIN (pgr)
    WITH nocounter
   ;end insert
 END ;Subroutine
 SUBROUTINE checkifloggrpcdchanged(null)
   CALL echo("REQUEST!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
   CALL echorecord(request)
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(reqprivcnt)),
     privilege p,
     activity_privilege_reltn apr
    PLAN (d1)
     JOIN (p
     WHERE (p.privilege_id=request->privilegelist[d1.seq].privilegeid)
      AND (p.log_grouping_cd != request->loggroupcd))
     JOIN (apr
     WHERE apr.privilege_id=outerjoin(p.privilege_id))
    ORDER BY p.privilege_id
    HEAD REPORT
     loggrpcdchangedcnt = 0
    DETAIL
     IF (apr.activity_privilege_reltn_id > 0)
      iactivityprivflag = true
     ENDIF
     loggrpcdchangedcnt = (loggrpcdchangedcnt+ 1)
     IF (mod(loggrpcdchangedcnt,10)=1)
      stat = alterlist(loggrpcdchangedlist->qual,(loggrpcdchangedcnt+ 9))
     ENDIF
     loggrpcdchangedlist->qual[loggrpcdchangedcnt].privilege_id = p.privilege_id, loggrpcdchangedlist
     ->qual[loggrpcdchangedcnt].prev_log_grouping_cd = p.log_grouping_cd
    FOOT REPORT
     stat = alterlist(loggrpcdchangedlist->qual,loggrpcdchangedcnt)
    WITH nocounter
   ;end select
   CALL echo("CHANGE LIST!!!!!!!!!!!!!!!!!!!!!!!!!!")
   CALL echo(loggrpcdchangedcnt)
   CALL echorecord(loggrpcdchangedlist)
 END ;Subroutine
 SUBROUTINE delgroupexception(null)
   SELECT INTO "nl:"
    FROM log_group_entry lge,
     (dummyt d  WITH seq = loggrpcdchangedcnt)
    PLAN (d)
     JOIN (lge
     WHERE (lge.log_grouping_cd=loggrpcdchangedlist->qual[d.seq].prev_log_grouping_cd)
      AND (loggrpcdchangedlist->qual[d.seq].prev_log_grouping_cd > 0))
    HEAD REPORT
     delgroupexceptcnt = 0
    DETAIL
     delgroupexceptcnt = (delgroupexceptcnt+ 1)
     IF (mod(delgroupexceptcnt,10)=1)
      stat = alterlist(delgroupexceptlist->qual,(delgroupexceptcnt+ 9))
     ENDIF
     delgroupexceptlist->qual[delgroupexceptcnt].privilege_id = loggrpcdchangedlist->qual[d.seq].
     privilege_id, delgroupexceptlist->qual[delgroupexceptcnt].exception_id = lge.item_cd
    FOOT REPORT
     stat = alterlist(delgroupexceptlist->qual,delgroupexceptcnt)
    WITH nocounter
   ;end select
   CALL echo("Del List!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
   CALL echorecord(delgroupexceptlist)
   IF (delgroupexceptcnt > 0)
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
      insertprivdelcnt = 0
     DETAIL
      insertprivdelcnt = (insertprivdelcnt+ 1)
      IF (mod(insertprivdelcnt,10)=1)
       stat = alterlist(insertprivdel->qual,(insertprivdelcnt+ 9))
      ENDIF
      insertprivdel->qual[insertprivdelcnt].privilege_cd = p.privilege_cd, insertprivdel->qual[
      insertprivdelcnt].location_cd = plr.location_cd, insertprivdel->qual[insertprivdelcnt].
      person_id = plr.person_id,
      insertprivdel->qual[insertprivdelcnt].position_cd = plr.position_cd, insertprivdel->qual[
      insertprivdelcnt].ppr_cd = plr.ppr_cd
     FOOT REPORT
      stat = alterlist(insertprivdel->qual,insertprivdelcnt), insertprivdel->qual_cnt =
      insertprivdelcnt
     WITH nocounter
    ;end select
    DELETE  FROM privilege_exception pe,
      (dummyt d  WITH seq = delgroupexceptcnt)
     SET pe.seq = 1
     PLAN (d)
      JOIN (pe
      WHERE (pe.privilege_id=delgroupexceptlist->qual[d.seq].privilege_id)
       AND (pe.exception_id=delgroupexceptlist->qual[d.seq].exception_id)
       AND pe.privilege_id > 0
       AND pe.exception_id > 0)
     WITH nocounter
    ;end delete
   ENDIF
 END ;Subroutine
 SUBROUTINE addgroupexception(null)
   SELECT INTO "nl:"
    FROM log_group_entry lge,
     (dummyt d  WITH seq = loggrpcdchangedcnt)
    PLAN (d)
     JOIN (lge
     WHERE (lge.log_grouping_cd=request->loggroupcd)
      AND (request->loggroupcd > 0)
      AND (loggrpcdchangedlist->qual[d.seq].prev_log_grouping_cd != request->loggroupcd))
    HEAD REPORT
     addgroupexceptcnt = 0
    DETAIL
     addgroupexceptcnt = (addgroupexceptcnt+ 1)
     IF (mod(addgroupexceptcnt,10)=1)
      stat = alterlist(addgroupexceptlist->qual,(addgroupexceptcnt+ 9))
     ENDIF
     addgroupexceptlist->qual[addgroupexceptcnt].privilege_id = loggrpcdchangedlist->qual[d.seq].
     privilege_id, addgroupexceptlist->qual[addgroupexceptcnt].exception_id = lge.item_cd,
     addgroupexceptlist->qual[addgroupexceptcnt].exception_entity_name = lge.exception_entity_name,
     addgroupexceptlist->qual[addgroupexceptcnt].exception_type_cd = lge.exception_type_cd,
     addgroupexceptlist->qual[addgroupexceptcnt].event_set_name = lge.event_set_name
    FOOT REPORT
     stat = alterlist(addgroupexceptlist->qual,addgroupexceptcnt)
    WITH nocounter
   ;end select
   SELECT INTO "NL:"
    FROM privilege_exception pe,
     (dummyt d  WITH seq = loggrpcdchangedcnt)
    PLAN (d)
     JOIN (pe
     WHERE (pe.privilege_id=addgroupexceptlist->qual[d.seq].privilege_id)
      AND (pe.exception_type_cd=addgroupexceptlist->qual[d.seq].exception_type_cd)
      AND (pe.exception_id=addgroupexceptlist->qual[d.seq].exception_id)
      AND (pe.exception_entity_name=addgroupexceptlist->qual[d.seq].exception_entity_name)
      AND (pe.event_set_name=addgroupexceptlist->qual[d.seq].event_set_name)
      AND pe.active_ind=1)
    DETAIL
     addgroupexceptlist->qual[d.seq].privilege_id = 0
    WITH nocounter
   ;end select
   INSERT  FROM privilege_exception pe,
     (dummyt d1  WITH seq = addgroupexceptcnt)
    SET pe.privilege_exception_id = cnvtreal(seq(reference_seq,nextval)), pe.privilege_id =
     addgroupexceptlist->qual[d1.seq].privilege_id, pe.exception_type_cd = addgroupexceptlist->qual[
     d1.seq].exception_type_cd,
     pe.exception_entity_name = addgroupexceptlist->qual[d1.seq].exception_entity_name, pe
     .event_set_name = addgroupexceptlist->qual[d1.seq].event_set_name, pe.exception_id =
     addgroupexceptlist->qual[d1.seq].exception_id,
     pe.updt_dt_tm = cnvtdatetime(curdate,curtime), pe.updt_id = reqinfo->updt_id, pe.updt_task =
     reqinfo->updt_task,
     pe.updt_applctx = reqinfo->updt_applctx, pe.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
     pe.active_status_prsnl_id = reqinfo->updt_id,
     pe.active_ind = 1, pe.updt_cnt = 0
    PLAN (d1)
     JOIN (pe
     WHERE (addgroupexceptlist->qual[d1.seq].privilege_id > 0))
    WITH nocounter
   ;end insert
 END ;Subroutine
 SUBROUTINE updateprivilege(null)
   CALL reseterrorinfo(null)
   SELECT INTO "nl:"
    p.privilege_id
    FROM (dummyt d1  WITH seq = value(reqprivcnt)),
     privilege p
    PLAN (d1)
     JOIN (p
     WHERE (p.privilege_id=request->privilegelist[d1.seq].privilegeid))
    WITH nocounter, forupdate(p)
   ;end select
   IF (curqual=0)
    SET logmsg = "unable to lock privilege row for update"
    CALL log_status("LOCK","F","PRIVILEGE",logmsg)
    CALL exitscript("F")
   ENDIF
   IF (errorcode > 0)
    SET logmsg = errmsg
    CALL log_status("PRIVILEGE","F","PRIVILEGE",logmsg)
    CALL exitscript("F")
   ENDIF
   CALL reseterrorinfo(null)
   UPDATE  FROM privilege p,
     (dummyt d  WITH seq = value(reqprivcnt))
    SET p.log_grouping_cd = request->loggroupcd, p.updt_applctx = reqinfo->updt_applctx, p.updt_id =
     reqinfo->updt_id,
     p.updt_cnt = (p.updt_cnt+ 1), p.updt_task = reqinfo->updt_task, p.updt_dt_tm = cnvtdatetime(
      curdate,curtime3),
     p.active_status_dt_tm = cnvtdatetime(curdate,curtime3), p.active_status_prsnl_id = reqinfo->
     updt_id
    PLAN (d)
     JOIN (p
     WHERE (p.privilege_id=request->privilegelist[d.seq].privilegeid)
      AND (request->updategroupflag=1))
    WITH nocounter
   ;end update
   IF (errorcode > 0)
    SET logmsg = errmsg
    CALL log_status("PRIVILEGE","F","PRIVILEGE",logmsg)
    CALL exitscript("F")
   ENDIF
   IF (curqual=0)
    SET logmsg = "privilege table not updated"
    CALL log_status("UPDATE","I","PRIVILEGE",logmsg)
   ELSE
    CALL echo("NUMBER OF PRIVILEGES UPDATED")
    CALL echo(curqual)
   ENDIF
 END ;Subroutine
 SUBROUTINE findexceptionlistmaxsize(null)
   DECLARE i = i4
   SET stat = alterlist(requestsupplement->privilegelist,reqprivcnt)
   SET addexceptioncnt = size(request->addexceptionlist,5)
   SET delexceptioncnt = size(request->delexceptionlist,5)
   SET stat = alterlist(requestsupplement->privilegelist[i].addexceptionlist,addexceptioncnt)
   FOR (i = 1 TO reqprivcnt)
     SET stat = alterlist(requestsupplement->privilegelist[i].addexceptionlist,addexceptioncnt)
   ENDFOR
 END ;Subroutine
 SUBROUTINE delprivilegeexceptions(null)
   IF (delexceptioncnt=0)
    RETURN
   ENDIF
   CALL echo("ARE WE THERE YET!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
   CALL echo(delexceptioncnt)
   CALL echo(reqprivcnt)
   CALL reseterrorinfo(null)
   CALL echorecord(request)
   DECLARE num = i4 WITH noconstant(0)
   DECLARE start = i4 WITH noconstant(1)
   DECLARE pos = i4 WITH noconstant(0)
   DECLARE i = i4 WITH noconstant(1)
   DECLARE j = i4 WITH noconstant(1)
   FOR (i = 1 TO size(request->delexceptionlist,5))
     SET pos = 0
     FOR (j = 1 TO size(undeleteableprivilegeexceptions->privileges,5))
       SET num = 0
       SET pos = locateval(num,start,undeleteableprivilegeexceptions->privileges[j].exception_cnt,
        request->delexceptionlist[i].privilegeexceptionid,undeleteableprivilegeexceptions->
        privileges[j].exceptions[num].item_cd)
       IF (pos != 0)
        SET request->delexceptionlist[i].privilegeexceptionid = 0
       ENDIF
     ENDFOR
     IF ((request->delexceptionlist[i].privilegeexceptionid > 0))
      SET num = 0
      SET pos = locateval(num,start,size(addgroupexceptlist->qual,5),request->delexceptionlist[i].
       privilegeexceptionid,addgroupexceptlist->qual[num].exception_id)
      IF (pos != 0)
       SET request->delexceptionlist[i].privilegeexceptionid = 0
      ENDIF
     ENDIF
   ENDFOR
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
     insertprivdelcnt = 0
    DETAIL
     insertprivdelcnt = (insertprivdelcnt+ 1)
     IF (mod(insertprivdelcnt,10)=1)
      stat = alterlist(insertprivdel->qual,(insertprivdelcnt+ 9))
     ENDIF
     insertprivdel->qual[insertprivdelcnt].privilege_cd = p.privilege_cd, insertprivdel->qual[
     insertprivdelcnt].location_cd = plr.location_cd, insertprivdel->qual[insertprivdelcnt].person_id
      = plr.person_id,
     insertprivdel->qual[insertprivdelcnt].position_cd = plr.position_cd, insertprivdel->qual[
     insertprivdelcnt].ppr_cd = plr.ppr_cd
    FOOT REPORT
     stat = alterlist(insertprivdel->qual,insertprivdelcnt), insertprivdel->qual_cnt =
     insertprivdelcnt
    WITH nocounter
   ;end select
   DELETE  FROM privilege_exception pe,
     (dummyt d1  WITH seq = reqprivcnt),
     (dummyt d2  WITH seq = delexceptioncnt)
    SET pe.seq = 1
    PLAN (d1)
     JOIN (d2
     WHERE d2.seq <= delexceptioncnt)
     JOIN (pe
     WHERE (pe.exception_id=request->delexceptionlist[d2.seq].privilegeexceptionid)
      AND (request->privilegelist[d1.seq].privilegeid=pe.privilege_id)
      AND pe.exception_id > 0)
    WITH nocounter
   ;end delete
   IF (errorcode > 0)
    SET logmsg = errmsg
    CALL log_status("PRIVILEGE","F","PRIVILEGE",logmsg)
    CALL exitscript("F")
   ENDIF
 END ;Subroutine
 SUBROUTINE insertprivilegedeletion(null)
   CALL reseterrorinfo(null)
   CALL echo("inside insert privilege deletion legacy")
   INSERT  FROM privilege_deletion pd,
     (dummyt d  WITH seq = reqprivcnt)
    SET pd.privilege_deletion_id = cnvtreal(seq(reference_seq,nextval)), pd.privilege_id = request->
     privilegelist[d.seq].privilegeid, pd.privilege_cd = insertprivdel->qual[reqprivcnt].privilege_cd,
     pd.location_cd = insertprivdel->qual[reqprivcnt].location_cd, pd.person_id = insertprivdel->
     qual[reqprivcnt].person_id, pd.position_cd = insertprivdel->qual[reqprivcnt].position_cd,
     pd.ppr_cd = insertprivdel->qual[reqprivcnt].ppr_cd, pd.updt_dt_tm = cnvtdatetime(curdate,
      curtime3), pd.updt_id = reqinfo->updt_id,
     pd.updt_task = reqinfo->updt_task, pd.updt_applctx = reqinfo->updt_applctx
    PLAN (d)
     JOIN (pd)
    WITH nocounter
   ;end insert
 END ;Subroutine
 SUBROUTINE addprivilegeexceptions(null)
   IF (addexceptioncnt=0)
    RETURN
   ENDIF
   SELECT INTO "NL:"
    FROM privilege_exception pe,
     (dummyt d1  WITH seq = reqprivcnt),
     (dummyt d2  WITH seq = addexceptioncnt)
    PLAN (d1)
     JOIN (d2
     WHERE d2.seq <= size(request->addexceptionlist,5))
     JOIN (pe
     WHERE (pe.privilege_id=request->privilegelist[d1.seq].privilegeid)
      AND (pe.exception_type_cd=request->addexceptionlist[d2.seq].exceptiontypecd)
      AND (pe.exception_id=request->addexceptionlist[d2.seq].exceptionid)
      AND (pe.exception_entity_name=request->addexceptionlist[d2.seq].exceptionentityname)
      AND (pe.event_set_name=request->addexceptionlist[d2.seq].eventsetname)
      AND pe.active_ind=1)
    DETAIL
     requestsupplement->privilegelist[d1.seq].addexceptionlist[d2.seq].dupexceptionrowflag = 1
    WITH nocounter
   ;end select
   CALL reseterrorinfo(null)
   INSERT  FROM privilege_exception pe,
     (dummyt d1  WITH seq = reqprivcnt),
     (dummyt d2  WITH seq = addexceptioncnt)
    SET pe.privilege_exception_id = cnvtreal(seq(reference_seq,nextval)), pe.privilege_id = request->
     privilegelist[d1.seq].privilegeid, pe.exception_type_cd = request->addexceptionlist[d2.seq].
     exceptiontypecd,
     pe.exception_entity_name = request->addexceptionlist[d2.seq].exceptionentityname, pe
     .event_set_name = request->addexceptionlist[d2.seq].eventsetname, pe.exception_id = request->
     addexceptionlist[d2.seq].exceptionid,
     pe.updt_dt_tm = cnvtdatetime(curdate,curtime), pe.updt_id = reqinfo->updt_id, pe.updt_task =
     reqinfo->updt_task,
     pe.updt_applctx = reqinfo->updt_applctx, pe.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
     pe.active_status_prsnl_id = reqinfo->updt_id,
     pe.active_ind = 1, pe.updt_cnt = 0
    PLAN (d1)
     JOIN (d2
     WHERE d2.seq <= size(request->addexceptionlist,5)
      AND (requestsupplement->privilegelist[d1.seq].addexceptionlist[d2.seq].dupexceptionrowflag=0))
     JOIN (pe)
    WITH nocounter
   ;end insert
   IF (errorcode > 0)
    SET logmsg = errmsg
    CALL log_status("PRIVILEGE","F","PRIVILEGE",logmsg)
    CALL exitscript("F")
   ENDIF
 END ;Subroutine
 SUBROUTINE reseterrorinfo(null)
   SET errorcode = 0
   SET errmsg = ""
   SET errorcode = error(errmsg,1)
 END ;Subroutine
 SUBROUTINE audittransaction(null)
  DECLARE exceptioncnt = i4 WITH noconstant(0)
  FOR (i = 1 TO reqprivcnt)
    IF ((request->loggroupcd > 0))
     EXECUTE cclaudit 0, "Maintain Reference Data", "Privilege",
     "Privilege", "Security Granularity Definition", "Privilege",
     "Origination", request->privilegelist[i].privilegeid, ""
    ENDIF
    SET exceptioncnt = size(request->addexceptionlist,5)
    IF (exceptioncnt=0)
     SET exceptioncnt = size(request->delexceptionlist,5)
    ENDIF
    IF (exceptioncnt > 0)
     EXECUTE cclaudit 0, "Maintain Reference Data", "Exception",
     "Privilege", "Security Granularity Definition", "Privilege",
     "Origination", request->privilegelist[i].privilegeid, ""
    ENDIF
  ENDFOR
 END ;Subroutine
 SUBROUTINE exitscript(scriptstatus)
  IF (scriptstatus="F")
   SET reply->status_data.status = "F"
   SET reqinfo->commit_ind = 0
  ELSE
   SET reply->status_data.status = "S"
   SET reqinfo->commit_ind = 1
   CALL audittransaction(size(request->privilegelist,5))
  ENDIF
  GO TO endscript
 END ;Subroutine
#endscript
 FREE RECORD loggrpcdchangedlist
 FREE RECORD delgroupexceptlist
 FREE RECORD addgroupexceptlist
 SET dcp_script_version = "004 11/21/08 NC014668"
END GO
