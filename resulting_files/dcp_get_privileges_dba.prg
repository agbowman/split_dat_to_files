CREATE PROGRAM dcp_get_privileges:dba
 SET modify = predeclare
 RECORD reply(
   1 privilegelist[*]
     2 privilegeid = f8
     2 privlocreltnid = f8
     2 personid = f8
     2 personname = vc
     2 privilege_cd = f8
     2 privilege_disp = c40
     2 privilge_desc = vc
     2 privilege_mean = c12
     2 priv_value_cd = f8
     2 priv_value_disp = c40
     2 priv_value_desc = vc
     2 priv_value_mean = c12
     2 log_group_cd = f8
     2 log_group_disp = c40
     2 log_group_desc = vc
     2 log_group_mean = c12
     2 exceptiongrouplist[*]
       3 log_group_cd = f8
     2 position_cd = f8
     2 position_disp = c40
     2 position_desc = vc
     2 position_mean = c12
     2 ppr_cd = f8
     2 ppr_disp = c40
     2 ppr_desc = vc
     2 ppr_mean = c12
     2 location_cd = f8
     2 location_disp = c40
     2 location_desc = vc
     2 location_mean = c12
     2 exceptionlist[*]
       3 privilegeexceptionid = f8
       3 exception_type_cd = f8
       3 exception_type_disp = c40
       3 exception_type_desc = vc
       3 exception_type_mean = c12
       3 exceptionentityname = c40
       3 eventsetname = c100
       3 exceptionid = f8
     2 activity_name = vc
     2 activity_ident = c25
     2 priv_updt_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD reptemp(
   1 privilegelist[*]
     2 privilegeid = f8
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
 DECLARE dcp_script_version = vc
 SET reply->status_data.status = "F"
 DECLARE logmsg = vc
 DECLARE replyprivcnt = i4 WITH noconstant(0)
 DECLARE eind = i4 WITH noconstant(0)
 DECLARE replyexceptioncnt = i4 WITH noconstant(0)
 DECLARE replygroupcnt = i4 WITH noconstant(0)
 DECLARE reqpersoncnt = i4 WITH noconstant(0)
 DECLARE reqpositioncnt = i4 WITH noconstant(0)
 DECLARE reqpprcnt = i4 WITH noconstant(0)
 DECLARE reqlocationcnt = i4 WITH noconstant(0)
 DECLARE reqactcnt = i4 WITH noconstant(0)
 DECLARE exitscript(scriptstatus=vc) = null
 DECLARE buildplanandjoinoption1(null) = null
 DECLARE retrieveprivilegesoption1(null) = null
 DECLARE buildplanandjoinoption2(null) = null
 DECLARE retrieveprivilegesoption2(null) = null
 DECLARE retrieveprivilegesoption3(null) = null
 DECLARE retrieveprivilegesoption4(null) = null
 DECLARE retrieveprivilegegroups(null) = null
 DECLARE dynamicplan = vc
 DECLARE dynamicjoin = vc
 DECLARE dynamicapr = vc
 DECLARE batch_size = i4 WITH constant(40)
 DECLARE retrievedeletedexceptionstime(null) = null
 DECLARE retrieveexceptionstime(null) = null
 SET reqpositioncnt = size(request->positionlist,5)
 SET reqpprcnt = size(request->pprlist,5)
 SET reqpersoncnt = size(request->personlist,5)
 SET reqlocationcnt = size(request->locationlist,5)
 SET reqactcnt = size(request->activitylist,5)
 IF ((request->privilegecd > 0))
  CALL buildplanandjoinoption1(null)
  IF ((request->withnoexceptions=0))
   CALL retrieveprivilegesoption1(null)
  ELSE
   CALL retrieveprivilegesoption3(null)
  ENDIF
 ELSE
  CALL buildplanandjoinoption2(null)
  IF ((request->withnoexceptions=0))
   CALL retrieveprivilegesoption2(null)
  ELSE
   CALL retrieveprivilegesoption4(null)
  ENDIF
 ENDIF
 CALL exitscript("S")
 SUBROUTINE buildplanandjoinoption1(null)
   SET dynamicplan = build(dynamicplan,"p.privilege_cd = request->privilegeCd and p.active_ind = 1")
   IF ((request->privilegevaluecd > 0))
    SET dynamicplan = build(dynamicplan," and p.priv_value_cd = request->privilegeValueCd ")
   ENDIF
   SET dynamicjoin = build(dynamicjoin,"plr.priv_loc_reltn_id = p.priv_loc_reltn_id")
   IF (reqpersoncnt > 0)
    SET dynamicjoin = build(dynamicjoin,
     " and expand(eInd,1,reqPersonCnt,plr.person_id,request->personList[eInd].personId, reqPersonCnt)"
     )
   ENDIF
   IF (reqpositioncnt > 0)
    SET dynamicjoin = build(dynamicjoin,
     " and expand(eInd,1,reqPositionCnt,plr.position_cd,request->positionList[eInd].positionCd, reqPositionCnt)"
     )
   ENDIF
   IF (reqpprcnt > 0)
    SET dynamicjoin = build(dynamicjoin,
     " and expand(eInd,1,reqPprCnt,plr.ppr_cd,request->pprList[eInd].pprCd, reqPprCnt)")
   ENDIF
   IF (reqlocationcnt > 0)
    SET dynamicjoin = build(dynamicjoin,
     " and expand(eInd,1,reqLocationCnt,plr.location_cd,request->locationList[eInd].locationCd, reqLocationCnt)"
     )
   ENDIF
   SET dynamicapr = build(dynamicapr,"apr.privilege_id = outerjoin(p.privilege_id)")
   IF (reqactcnt > 0)
    SET dynamicapr = build(dynamicapr,
     " and apr.activity_privilege_def_id = request->activityList[eInd].activityDefId ")
   ENDIF
 END ;Subroutine
 SUBROUTINE buildplanandjoinoption2(null)
   IF (reqpersoncnt > 0)
    SET dynamicplan = build(dynamicplan,
     "expand(eInd,1,reqPersonCnt,plr.person_id,request->personList[eInd].personId)")
   ENDIF
   IF (reqpositioncnt > 0)
    IF (dynamicplan > "")
     SET dynamicplan = build(dynamicplan," and ")
    ENDIF
    SET dynamicplan = build(dynamicplan,
     " expand(eInd,1,reqPositionCnt,plr.position_cd,request->positionList[eInd].positionCd, reqPositionCnt)"
     )
   ENDIF
   IF (reqpprcnt > 0)
    IF (dynamicplan > "")
     SET dynamicplan = build(dynamicplan," and ")
    ENDIF
    SET dynamicplan = build(dynamicplan,
     " expand(eInd,1,reqPprCnt,plr.ppr_cd,request->pprList[eInd].pprCd, reqPprCnt)")
   ENDIF
   IF (reqlocationcnt > 0)
    IF (dynamicplan > "")
     SET dynamicplan = build(dynamicplan," and ")
    ENDIF
    SET dynamicplan = build(dynamicplan,
     " expand(eInd,1,reqLocationCnt,plr.location_cd,request->locationList[eInd].locationCd, reqLocationCnt)"
     )
   ENDIF
   IF (dynamicplan > "")
    SET dynamicplan = build(dynamicplan," and ")
   ENDIF
   SET dynamicplan = build(dynamicplan," plr.active_ind <= 1")
   SET dynamicjoin = build(dynamicjoin,"p.priv_loc_reltn_id = plr.priv_loc_reltn_id")
   IF ((request->privilegevaluecd > 0))
    SET dynamicjoin = build(dynamicjoin," and p.priv_value_cd = request->privilegeValueCd")
   ENDIF
   SET dynamicapr = build(dynamicapr,"apr.privilege_id = outerjoin(p.privilege_id)")
   IF (reqactcnt > 0)
    IF (dynamicapr > "")
     SET dynamicapr = build(dynamicapr," and ")
    ENDIF
    SET dynamicapr = build(dynamicapr,
     " expand(eInd,1,reqActCnt,apr.activity_privilege_def_id,request->activityList[eInd].activityDefId,reqActCnt)"
     )
   ENDIF
 END ;Subroutine
 SUBROUTINE retrieveprivilegesoption1(null)
  SELECT DISTINCT INTO "nl:"
   FROM privilege p,
    privilege_exception pe,
    priv_loc_reltn plr,
    prsnl prsn,
    activity_privilege_reltn apr,
    activity_privilege_definition apd
   PLAN (p
    WHERE parser(dynamicplan))
    JOIN (plr
    WHERE parser(dynamicjoin))
    JOIN (pe
    WHERE pe.privilege_id=outerjoin(p.privilege_id))
    JOIN (prsn
    WHERE prsn.person_id=plr.person_id)
    JOIN (apr
    WHERE parser(dynamicapr))
    JOIN (apd
    WHERE apd.activity_privilege_def_id=outerjoin(apr.activity_privilege_def_id))
   ORDER BY p.privilege_id
   HEAD p.privilege_id
    replyexceptioncnt = 0, replyprivcnt = (replyprivcnt+ 1)
    IF (replyprivcnt > size(reply->privilegelist,5))
     stat = alterlist(reply->privilegelist,(replyprivcnt+ 9))
    ENDIF
    reply->privilegelist[replyprivcnt].privilegeid = p.privilege_id, reply->privilegelist[
    replyprivcnt].privilege_cd = p.privilege_cd, reply->privilegelist[replyprivcnt].priv_value_cd = p
    .priv_value_cd,
    reply->privilegelist[replyprivcnt].privlocreltnid = p.priv_loc_reltn_id, reply->privilegelist[
    replyprivcnt].log_group_cd = p.log_grouping_cd, reply->privilegelist[replyprivcnt].position_cd =
    plr.position_cd,
    reply->privilegelist[replyprivcnt].ppr_cd = plr.ppr_cd, reply->privilegelist[replyprivcnt].
    personid = plr.person_id, reply->privilegelist[replyprivcnt].personname = prsn
    .name_full_formatted,
    reply->privilegelist[replyprivcnt].location_cd = plr.location_cd, reply->privilegelist[
    replyprivcnt].priv_updt_dt_tm = p.updt_dt_tm
    IF (apr.activity_privilege_reltn_id > 0)
     reply->privilegelist[replyprivcnt].activity_name = apd.activity_name, reply->privilegelist[
     replyprivcnt].activity_ident = apd.activity_identifier
    ENDIF
   DETAIL
    IF (pe.privilege_exception_id > 0)
     replyexceptioncnt = (replyexceptioncnt+ 1)
     IF (replyexceptioncnt > size(reply->privilegelist[replyprivcnt].exceptionlist,5))
      stat = alterlist(reply->privilegelist[replyprivcnt].exceptionlist,(replyexceptioncnt+ 9))
     ENDIF
     reply->privilegelist[replyprivcnt].exceptionlist[replyexceptioncnt].privilegeexceptionid = pe
     .privilege_exception_id, reply->privilegelist[replyprivcnt].exceptionlist[replyexceptioncnt].
     exceptionid = pe.exception_id, reply->privilegelist[replyprivcnt].exceptionlist[
     replyexceptioncnt].exceptionentityname = pe.exception_entity_name,
     reply->privilegelist[replyprivcnt].exceptionlist[replyexceptioncnt].exception_type_cd = pe
     .exception_type_cd, reply->privilegelist[replyprivcnt].exceptionlist[replyexceptioncnt].
     eventsetname = pe.event_set_name
     IF ((pe.updt_dt_tm > reply->privilegelist[replyprivcnt].priv_updt_dt_tm))
      reply->privilegelist[replyprivcnt].priv_updt_dt_tm = pe.updt_dt_tm
     ENDIF
    ENDIF
   FOOT  p.privilege_id
    IF (replyexceptioncnt > 0)
     stat = alterlist(reply->privilegelist[replyprivcnt].exceptionlist,replyexceptioncnt)
    ENDIF
   WITH nocounter
  ;end select
  IF (replyprivcnt > 0)
   SET stat = alterlist(reply->privilegelist,replyprivcnt)
   CALL retrievedeletedexceptionstime(null)
   CALL retrieveprivilegegroups(null)
   CALL exitscript("S")
  ELSE
   SET logmsg = "No Privileges Found"
   CALL log_status("GET","S","PRIVILEGE",logmsg)
   CALL exitscript("S")
  ENDIF
 END ;Subroutine
 SUBROUTINE retrieveprivilegesoption2(null)
  SELECT DISTINCT INTO "nl:"
   FROM privilege p,
    privilege_exception pe,
    priv_loc_reltn plr,
    prsnl prsn,
    activity_privilege_reltn apr,
    activity_privilege_definition apd
   PLAN (plr
    WHERE parser(dynamicplan))
    JOIN (p
    WHERE parser(dynamicjoin))
    JOIN (pe
    WHERE pe.privilege_id=outerjoin(p.privilege_id))
    JOIN (prsn
    WHERE prsn.person_id=plr.person_id)
    JOIN (apr
    WHERE parser(dynamicapr))
    JOIN (apd
    WHERE apd.activity_privilege_def_id=outerjoin(apr.activity_privilege_def_id))
   ORDER BY p.privilege_id
   HEAD p.privilege_id
    replyexceptioncnt = 0, replyprivcnt = (replyprivcnt+ 1)
    IF (replyprivcnt > size(reply->privilegelist,5))
     stat = alterlist(reply->privilegelist,(replyprivcnt+ 9))
    ENDIF
    reply->privilegelist[replyprivcnt].privilegeid = p.privilege_id, reply->privilegelist[
    replyprivcnt].privilege_cd = p.privilege_cd, reply->privilegelist[replyprivcnt].priv_value_cd = p
    .priv_value_cd,
    reply->privilegelist[replyprivcnt].privlocreltnid = p.priv_loc_reltn_id, reply->privilegelist[
    replyprivcnt].log_group_cd = p.log_grouping_cd, reply->privilegelist[replyprivcnt].position_cd =
    plr.position_cd,
    reply->privilegelist[replyprivcnt].ppr_cd = plr.ppr_cd, reply->privilegelist[replyprivcnt].
    personid = plr.person_id, reply->privilegelist[replyprivcnt].personname = prsn
    .name_full_formatted,
    reply->privilegelist[replyprivcnt].location_cd = plr.location_cd, reply->privilegelist[
    replyprivcnt].priv_updt_dt_tm = p.updt_dt_tm
    IF (apr.activity_privilege_reltn_id > 0)
     reply->privilegelist[replyprivcnt].activity_name = apd.activity_name, reply->privilegelist[
     replyprivcnt].activity_ident = apd.activity_identifier
    ENDIF
   DETAIL
    IF (pe.privilege_exception_id > 0)
     replyexceptioncnt = (replyexceptioncnt+ 1)
     IF (replyexceptioncnt > size(reply->privilegelist[replyprivcnt].exceptionlist,5))
      stat = alterlist(reply->privilegelist[replyprivcnt].exceptionlist,(replyexceptioncnt+ 9))
     ENDIF
     reply->privilegelist[replyprivcnt].exceptionlist[replyexceptioncnt].privilegeexceptionid = pe
     .privilege_exception_id, reply->privilegelist[replyprivcnt].exceptionlist[replyexceptioncnt].
     exceptionid = pe.exception_id, reply->privilegelist[replyprivcnt].exceptionlist[
     replyexceptioncnt].exceptionentityname = pe.exception_entity_name,
     reply->privilegelist[replyprivcnt].exceptionlist[replyexceptioncnt].exception_type_cd = pe
     .exception_type_cd, reply->privilegelist[replyprivcnt].exceptionlist[replyexceptioncnt].
     eventsetname = pe.event_set_name
     IF ((pe.updt_dt_tm > reply->privilegelist[replyprivcnt].priv_updt_dt_tm))
      reply->privilegelist[replyprivcnt].priv_updt_dt_tm = pe.updt_dt_tm
     ENDIF
    ENDIF
   FOOT  p.privilege_id
    IF (replyexceptioncnt > 0)
     stat = alterlist(reply->privilegelist[replyprivcnt].exceptionlist,replyexceptioncnt)
    ENDIF
   WITH nocounter
  ;end select
  IF (replyprivcnt > 0)
   SET stat = alterlist(reply->privilegelist,replyprivcnt)
   CALL retrievedeletedexceptionstime(null)
   CALL retrieveprivilegegroups(null)
   CALL exitscript("S")
  ELSE
   SET logmsg = "No items found"
   CALL log_status("GET","Z","PRIVILEGE",logmsg)
   CALL exitscript("Z")
  ENDIF
 END ;Subroutine
 SUBROUTINE retrieveprivilegesoption3(null)
  SELECT DISTINCT INTO "nl:"
   FROM privilege p,
    priv_loc_reltn plr,
    prsnl prsn,
    activity_privilege_reltn apr,
    activity_privilege_definition apd
   PLAN (p
    WHERE parser(dynamicplan))
    JOIN (plr
    WHERE parser(dynamicjoin))
    JOIN (prsn
    WHERE prsn.person_id=plr.person_id)
    JOIN (apr
    WHERE parser(dynamicapr))
    JOIN (apd
    WHERE apd.activity_privilege_def_id=outerjoin(apr.activity_privilege_def_id))
   ORDER BY p.privilege_id
   HEAD p.privilege_id
    replyexceptioncnt = 0, replyprivcnt = (replyprivcnt+ 1)
    IF (replyprivcnt > size(reply->privilegelist,5))
     stat = alterlist(reply->privilegelist,(replyprivcnt+ 9))
    ENDIF
    reply->privilegelist[replyprivcnt].privilegeid = p.privilege_id, reply->privilegelist[
    replyprivcnt].privilege_cd = p.privilege_cd, reply->privilegelist[replyprivcnt].priv_value_cd = p
    .priv_value_cd,
    reply->privilegelist[replyprivcnt].privlocreltnid = p.priv_loc_reltn_id, reply->privilegelist[
    replyprivcnt].log_group_cd = p.log_grouping_cd, reply->privilegelist[replyprivcnt].position_cd =
    plr.position_cd,
    reply->privilegelist[replyprivcnt].ppr_cd = plr.ppr_cd, reply->privilegelist[replyprivcnt].
    personid = plr.person_id, reply->privilegelist[replyprivcnt].personname = prsn
    .name_full_formatted,
    reply->privilegelist[replyprivcnt].location_cd = plr.location_cd, reply->privilegelist[
    replyprivcnt].priv_updt_dt_tm = p.updt_dt_tm
    IF (apr.activity_privilege_reltn_id > 0)
     reply->privilegelist[replyprivcnt].activity_name = apd.activity_name, reply->privilegelist[
     replyprivcnt].activity_ident = apd.activity_identifier
    ENDIF
   WITH nocounter
  ;end select
  IF (replyprivcnt > 0)
   SET stat = alterlist(reply->privilegelist,replyprivcnt)
   CALL retrieveexceptionstime(null)
   CALL retrievedeletedexceptionstime(null)
   CALL exitscript("S")
  ELSE
   SET logmsg = "No Privileges Found"
   CALL log_status("GET","S","PRIVILEGE",logmsg)
   CALL exitscript("S")
  ENDIF
 END ;Subroutine
 SUBROUTINE retrieveprivilegesoption4(null)
  SELECT DISTINCT INTO "nl:"
   FROM privilege p,
    priv_loc_reltn plr,
    prsnl prsn,
    activity_privilege_reltn apr,
    activity_privilege_definition apd
   PLAN (plr
    WHERE parser(dynamicplan))
    JOIN (p
    WHERE parser(dynamicjoin))
    JOIN (prsn
    WHERE prsn.person_id=plr.person_id)
    JOIN (apr
    WHERE parser(dynamicapr))
    JOIN (apd
    WHERE apd.activity_privilege_def_id=outerjoin(apr.activity_privilege_def_id))
   ORDER BY p.privilege_id
   HEAD p.privilege_id
    replyexceptioncnt = 0, replyprivcnt = (replyprivcnt+ 1)
    IF (replyprivcnt > size(reply->privilegelist,5))
     stat = alterlist(reply->privilegelist,(replyprivcnt+ 9))
    ENDIF
    reply->privilegelist[replyprivcnt].privilegeid = p.privilege_id, reply->privilegelist[
    replyprivcnt].privilege_cd = p.privilege_cd, reply->privilegelist[replyprivcnt].priv_value_cd = p
    .priv_value_cd,
    reply->privilegelist[replyprivcnt].privlocreltnid = p.priv_loc_reltn_id, reply->privilegelist[
    replyprivcnt].log_group_cd = p.log_grouping_cd, reply->privilegelist[replyprivcnt].position_cd =
    plr.position_cd,
    reply->privilegelist[replyprivcnt].ppr_cd = plr.ppr_cd, reply->privilegelist[replyprivcnt].
    personid = plr.person_id, reply->privilegelist[replyprivcnt].personname = prsn
    .name_full_formatted,
    reply->privilegelist[replyprivcnt].location_cd = plr.location_cd, reply->privilegelist[
    replyprivcnt].priv_updt_dt_tm = p.updt_dt_tm
    IF (apr.activity_privilege_reltn_id > 0)
     reply->privilegelist[replyprivcnt].activity_name = apd.activity_name, reply->privilegelist[
     replyprivcnt].activity_ident = apd.activity_identifier
    ENDIF
   FOOT  p.privilege_id
    IF (replyexceptioncnt > 0)
     stat = alterlist(reply->privilegelist[replyprivcnt].exceptionlist,replyexceptioncnt)
    ENDIF
   WITH nocounter
  ;end select
  IF (replyprivcnt > 0)
   SET stat = alterlist(reply->privilegelist,replyprivcnt)
   CALL retrieveexceptionstime(null)
   CALL retrievedeletedexceptionstime(null)
   CALL exitscript("S")
  ELSE
   SET logmsg = "No items found"
   CALL log_status("GET","Z","PRIVILEGE",logmsg)
   CALL exitscript("Z")
  ENDIF
 END ;Subroutine
 SUBROUTINE retrieveprivilegegroups(null)
   DECLARE idx = i4 WITH noconstant(0)
   DECLARE nstart = i4 WITH noconstant(1)
   DECLARE num = i4 WITH noconstant(0)
   DECLARE start = i4 WITH noconstant(1)
   DECLARE new_list_size = i4
   DECLARE loop_cnt = i4
   DECLARE i = i4 WITH noconstant(0)
   SET stat = alterlist(reptemp->privilegelist,size(reply->privilegelist,5))
   FOR (i = 1 TO size(reply->privilegelist,5))
     SET reptemp->privilegelist[i].privilegeid = reply->privilegelist[i].privilegeid
   ENDFOR
   SET loop_cnt = ceil((cnvtreal(size(reptemp->privilegelist,5))/ batch_size))
   SET new_list_size = (loop_cnt * batch_size)
   SET stat = alterlist(reptemp->privilegelist,new_list_size)
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(loop_cnt)),
     privilege p,
     priv_group_reltn pgr
    PLAN (d1
     WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
     JOIN (p
     WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),p.privilege_id,reptemp->privilegelist[idx].
      privilegeid)
      AND p.privilege_id > 0)
     JOIN (pgr
     WHERE pgr.privilege_id=outerjoin(p.privilege_id))
    ORDER BY p.privilege_id
    HEAD p.privilege_id
     replygroupcnt = 0, num = 0, pos = locateval(num,start,size(reply->privilegelist,5),p
      .privilege_id,reply->privilegelist[num].privilegeid)
    DETAIL
     IF (pos != 0)
      IF (pgr.priv_group_reltn_id > 0)
       replygroupcnt = (replygroupcnt+ 1)
       IF (replygroupcnt > size(reply->privilegelist[pos].exceptiongrouplist,5))
        stat = alterlist(reply->privilegelist[pos].exceptiongrouplist,(replygroupcnt+ 9))
       ENDIF
       reply->privilegelist[pos].exceptiongrouplist[replygroupcnt].log_group_cd = pgr.log_grouping_cd
      ELSEIF (p.log_grouping_cd > 0
       AND replygroupcnt <= 0)
       replygroupcnt = (replygroupcnt+ 1)
       IF (replygroupcnt > size(reply->privilegelist[pos].exceptiongrouplist,5))
        stat = alterlist(reply->privilegelist[pos].exceptiongrouplist,(replygroupcnt+ 9))
       ENDIF
       reply->privilegelist[pos].exceptiongrouplist[replygroupcnt].log_group_cd = p.log_grouping_cd
      ENDIF
     ENDIF
    FOOT  p.privilege_id
     IF (replygroupcnt > 0)
      stat = alterlist(reply->privilegelist[pos].exceptiongrouplist,replygroupcnt)
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE retrievedeletedexceptionstime(null)
   DECLARE recind = i4 WITH noconstant(0)
   DECLARE delcnt = i4 WITH noconstant(0)
   SELECT INTO "nl:"
    FROM privilege_deletion pd
    WHERE expand(delcnt,1,size(reply->privilegelist,5),pd.privilege_id,reply->privilegelist[delcnt].
     privilegeid)
    ORDER BY pd.updt_dt_tm DESC
    HEAD pd.privilege_id
     recind = 0, pos = locateval(recind,1,size(reply->privilegelist,5),pd.privilege_id,reply->
      privilegelist[recind].privilegeid)
    DETAIL
     IF ((pd.updt_dt_tm > reply->privilegelist[pos].priv_updt_dt_tm))
      reply->privilegelist[pos].priv_updt_dt_tm = pd.updt_dt_tm
     ENDIF
    WITH nocounter, expand = 1
   ;end select
 END ;Subroutine
 SUBROUTINE retrieveexceptionstime(null)
   DECLARE recind = i4 WITH noconstant(0)
   DECLARE excpcnt = i4 WITH noconstant(0)
   SELECT INTO "nl:"
    FROM privilege_exception pe
    WHERE expand(excpcnt,1,size(reply->privilegelist,5),pe.privilege_id,reply->privilegelist[excpcnt]
     .privilegeid)
    ORDER BY pe.updt_dt_tm DESC
    HEAD pe.privilege_id
     recind = 0, pos = locateval(recind,1,size(reply->privilegelist,5),pe.privilege_id,reply->
      privilegelist[recind].privilegeid)
    DETAIL
     IF ((pe.updt_dt_tm > reply->privilegelist[pos].priv_updt_dt_tm))
      reply->privilegelist[pos].priv_updt_dt_tm = pe.updt_dt_tm
     ENDIF
    WITH nocounter, expand = 1
   ;end select
 END ;Subroutine
 SUBROUTINE exitscript(scriptstatus)
  IF (scriptstatus="F")
   SET reply->status_data.status = "F"
  ELSEIF (scriptstatus="Z")
   SET reply->status_data.status = "Z"
  ELSEIF (scriptstatus="S")
   SET reply->status_data.status = "S"
  ENDIF
  GO TO endscript
 END ;Subroutine
#endscript
 SET dcp_script_version = "005 10/12/09 PA016718"
END GO
