CREATE PROGRAM dcp_create_response_task:dba
 DECLARE program_version = vc WITH private, constant("010")
 DECLARE pharmacycatalogtypecd = f8 WITH constant(uar_get_code_by("MEANING",6000,"PHARMACY")),
 protect
 DECLARE routinetaskprioritycd = f8 WITH constant(uar_get_code_by("MEANING",4010,"ROUTINE")), protect
 DECLARE med = f8
 SET med = 0.0
 SET iret = uar_get_meaning_by_codeset(53,nullterm("MED"),1,med)
 DECLARE sch = f8
 SET sch = 0.0
 SET iret = uar_get_meaning_by_codeset(6025,nullterm("SCH"),1,sch)
 DECLARE chartnotdone = f8 WITH constant(uar_get_code_by("MEANING",14024,"DCP_NOTDONE")), protect
 DECLARE replycnt = i4
 SET replycnt = size(reply->result.task_list,5)
 DECLARE failcnt = i2
 SET failcnt = 0
 DECLARE eaction_create = i2 WITH constant(0)
 DECLARE eaction_propose = i2 WITH constant(1)
 DECLARE eaction_ignore = i2 WITH constant(2)
 DECLARE eroute_default = i2 WITH constant(1)
 DECLARE eroute_value = i2 WITH constant(2)
 DECLARE eroute_both = i2 WITH constant(3)
 DECLARE responsequalprnonly = i2 WITH constant(0), protect
 DECLARE responsequalprnandscheduled = i2 WITH constant(1), protect
 DECLARE adhocorderviabridge = i2 WITH constant(1), protect
 DECLARE origordasnormal = i2 WITH constant(0), protect
 DECLARE origordasperscription = i2 WITH constant(1), protect
 DECLARE origordasdocumented_homemeds = i2 WITH constant(2), protect
 DECLARE origordaspatientownmeds = i2 WITH constant(3), protect
 DECLARE origordaspharmchargeonly = i2 WITH constant(4), protect
 DECLARE origordassatelliteofficemeds = i2 WITH constant(5), protect
 RECORD newresponse(
   1 list[*]
     2 status = i1
     2 action_flag = i2
     2 route_cd_flag = i2
     2 response_task_id = f8
     2 response_task_desc = vc
     2 response_dt_tm = dq8
     2 new_task_id = f8
     2 task_reltn_id = f8
     2 event_id = f8
     2 task_type_cd = f8
     2 task_activity_cd = f8
     2 task_id = f8
     2 parent_task_admin_dt_tm = dq8
     2 parent_task_dt_tm = dq8
     2 response_minutes = f8
     2 person_id = f8
     2 encntr_id = f8
     2 order_id = f8
     2 reference_task_id = f8
     2 loc_room_cd = f8
     2 loc_bed_cd = f8
     2 location_cd = f8
     2 updt_id = f8
     2 task_tz = i4
     2 catalog_cd = f8
     2 qualification_flag = i2
 )
 DECLARE responsestobecreatedcnt = i4 WITH noconstant(0)
 DECLARE modcnt = i4
 SET modcnt = size(request->mod_list,5)
 IF (modcnt > 0)
  SELECT INTO "nl:"
   ta.task_id
   FROM (dummyt d  WITH seq = value(modcnt)),
    task_activity ta,
    orders o,
    order_task_response otr,
    order_task ot
   PLAN (d
    WHERE (((request->mod_list[d.seq].task_status_cd=complete)
     AND (previous_task_info->qual[d.seq].task_status_cd != validation)) OR ((request->mod_list[d.seq
    ].task_status_cd=validation)))
     AND (previous_task_info->qual[d.seq].status=1)
     AND (previous_task_info->qual[d.seq].task_type_cd != medrecon)
     AND (request->mod_list[d.seq].task_status_reason_cd != chartnotdone))
    JOIN (ta
    WHERE (ta.task_id=request->mod_list[d.seq].task_id)
     AND ta.order_id > 0)
    JOIN (o
    WHERE ta.order_id=o.order_id)
    JOIN (otr
    WHERE ta.reference_task_id=otr.reference_task_id)
    JOIN (ot
    WHERE ot.reference_task_id=otr.response_task_id)
   ORDER BY ta.task_id
   HEAD ta.task_id
    responsestobecreatedcnt += 1, stat = alterlist(newresponse->list,responsestobecreatedcnt),
    newresponse->list[responsestobecreatedcnt].action_flag = eaction_create,
    newresponse->list[responsestobecreatedcnt].status = 0, newresponse->list[responsestobecreatedcnt]
    .route_cd_flag = 0, newresponse->list[responsestobecreatedcnt].event_id = request->mod_list[d.seq
    ].event_id,
    newresponse->list[responsestobecreatedcnt].task_id = request->mod_list[d.seq].task_id,
    newresponse->list[responsestobecreatedcnt].reference_task_id = ta.reference_task_id, newresponse
    ->list[responsestobecreatedcnt].parent_task_admin_dt_tm = request->mod_list[d.seq].entered_dt_tm,
    newresponse->list[responsestobecreatedcnt].parent_task_dt_tm = ta.task_dt_tm, newresponse->list[
    responsestobecreatedcnt].task_tz = previous_task_info->qual[d.seq].task_tz, newresponse->list[
    responsestobecreatedcnt].person_id = ta.person_id,
    newresponse->list[responsestobecreatedcnt].encntr_id = ta.encntr_id, newresponse->list[
    responsestobecreatedcnt].order_id = ta.order_id, newresponse->list[responsestobecreatedcnt].
    loc_room_cd = ta.loc_room_cd,
    newresponse->list[responsestobecreatedcnt].loc_bed_cd = ta.loc_bed_cd, newresponse->list[
    responsestobecreatedcnt].location_cd = ta.location_cd, newresponse->list[responsestobecreatedcnt]
    .updt_id = ta.updt_id,
    newresponse->list[responsestobecreatedcnt].catalog_cd = ta.catalog_cd, newresponse->list[
    responsestobecreatedcnt].task_type_cd = ot.task_type_cd, newresponse->list[
    responsestobecreatedcnt].task_activity_cd = ot.task_activity_cd,
    newresponse->list[responsestobecreatedcnt].response_task_desc = ot.task_description
   DETAIL
    IF (otr.route_cd=0)
     newresponse->list[responsestobecreatedcnt].response_task_id = otr.response_task_id, newresponse
     ->list[responsestobecreatedcnt].qualification_flag = otr.qualification_flag, newresponse->list[
     responsestobecreatedcnt].response_minutes = otr.response_minutes
     IF ((newresponse->list[responsestobecreatedcnt].route_cd_flag=eroute_value))
      newresponse->list[responsestobecreatedcnt].route_cd_flag = eroute_both
     ELSE
      newresponse->list[responsestobecreatedcnt].route_cd_flag = eroute_default
     ENDIF
    ELSE
     IF ((newresponse->list[responsestobecreatedcnt].route_cd_flag=eroute_default))
      newresponse->list[responsestobecreatedcnt].route_cd_flag = eroute_both
     ELSEIF ((newresponse->list[responsestobecreatedcnt].route_cd_flag=0))
      newresponse->list[responsestobecreatedcnt].route_cd_flag = eroute_value
     ENDIF
    ENDIF
   FOOT  ta.task_id
    IF ((newresponse->list[responsestobecreatedcnt].route_cd_flag=eroute_value))
     newresponse->list[responsestobecreatedcnt].action_flag = eaction_ignore
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (responsestobecreatedcnt > 0)
  SELECT INTO "nl:"
   otr.response_task_id, otr.response_minutes
   FROM (dummyt d  WITH seq = value(responsestobecreatedcnt)),
    clinical_event ce,
    ce_med_result cemr,
    order_task_response otr,
    order_task ot
   PLAN (d
    WHERE (newresponse->list[d.seq].route_cd_flag IN (eroute_value, eroute_both)))
    JOIN (ce
    WHERE (ce.parent_event_id=newresponse->list[d.seq].event_id)
     AND ce.event_class_cd=med)
    JOIN (cemr
    WHERE cemr.event_id=ce.event_id
     AND cemr.valid_until_dt_tm=cnvtdatetime("31-DEC-2100"))
    JOIN (otr
    WHERE (otr.reference_task_id=newresponse->list[d.seq].reference_task_id)
     AND otr.route_cd=cemr.admin_route_cd)
    JOIN (ot
    WHERE ot.reference_task_id=otr.response_task_id)
   DETAIL
    newresponse->list[d.seq].action_flag = eaction_create, newresponse->list[d.seq].response_task_id
     = otr.response_task_id, newresponse->list[d.seq].task_type_cd = ot.task_type_cd,
    newresponse->list[d.seq].task_activity_cd = ot.task_activity_cd, newresponse->list[d.seq].
    response_task_desc = ot.task_description, newresponse->list[d.seq].qualification_flag = otr
    .qualification_flag,
    newresponse->list[d.seq].response_minutes = otr.response_minutes
   WITH maxread(ce,1), nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(responsestobecreatedcnt)),
    orders o,
    order_catalog oc
   PLAN (d
    WHERE (newresponse->list[d.seq].action_flag != eaction_ignore))
    JOIN (o
    WHERE (o.order_id=newresponse->list[d.seq].order_id))
    JOIN (oc
    WHERE oc.catalog_cd=o.catalog_cd)
   DETAIL
    IF ((newresponse->list[d.seq].qualification_flag=responsequalprnonly))
     IF (o.prn_ind=0)
      newresponse->list[d.seq].action_flag = eaction_ignore
     ENDIF
    ELSEIF ((newresponse->list[d.seq].qualification_flag=responsequalprnandscheduled))
     IF (((oc.complete_upon_order_ind=1) OR (((oc.bill_only_ind=1) OR (o.ad_hoc_order_flag=
     adhocorderviabridge)) )) )
      newresponse->list[d.seq].action_flag = eaction_ignore
     ELSEIF (o.catalog_type_cd=pharmacycatalogtypecd)
      IF (((o.iv_ind=1) OR (o.constant_ind=1)) )
       newresponse->list[d.seq].action_flag = eaction_ignore
      ELSEIF (o.orig_ord_as_flag IN (origordasperscription, origordasdocumented_homemeds,
      origordaspatientownmeds, origordaspharmchargeonly))
       newresponse->list[d.seq].action_flag = eaction_ignore
      ENDIF
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  FOR (x = 1 TO responsestobecreatedcnt)
    IF ((newresponse->list[x].action_flag=eaction_create))
     IF ((newresponse->list[x].parent_task_admin_dt_tm=0))
      IF ((newresponse->list[x].qualification_flag=responsequalprnandscheduled))
       SET script_status = "F"
       GO TO exit_response_script
      ELSEIF ((newresponse->list[x].qualification_flag=responsequalprnonly))
       SET newresponse->list[x].response_dt_tm = datetimeadd(newresponse->list[x].parent_task_dt_tm,(
        newresponse->list[x].response_minutes/ 1440.0))
      ENDIF
     ELSE
      SET newresponse->list[x].response_dt_tm = datetimeadd(newresponse->list[x].
       parent_task_admin_dt_tm,(newresponse->list[x].response_minutes/ 1440.0))
     ENDIF
    ENDIF
  ENDFOR
  SELECT INTO "nl:"
   tr.task_id, tr.prereq_task_id
   FROM (dummyt d  WITH seq = value(responsestobecreatedcnt)),
    task_reltn tr,
    task_activity ta
   PLAN (d
    WHERE (newresponse->list[d.seq].action_flag != eaction_ignore))
    JOIN (tr
    WHERE (tr.prereq_task_id=newresponse->list[d.seq].task_id))
    JOIN (ta
    WHERE ta.task_id=tr.task_id
     AND ta.task_status_cd=pending
     AND ta.task_dt_tm=cnvtdatetime(newresponse->list[d.seq].response_dt_tm))
   DETAIL
    newresponse->list[d.seq].action_flag = eaction_ignore
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(responsestobecreatedcnt)),
    dcp_entity_reltn der
   PLAN (d
    WHERE (newresponse->list[d.seq].action_flag != eaction_ignore))
    JOIN (der
    WHERE der.entity_reltn_mean="TASK/LOC"
     AND (newresponse->list[d.seq].location_cd=der.entity2_id)
     AND (newresponse->list[d.seq].task_type_cd=der.entity1_id)
     AND der.active_ind=1)
   DETAIL
    newresponse->list[d.seq].action_flag = eaction_ignore
   WITH nocounter
  ;end select
  DECLARE propcnt = i4
  SET propcnt = 0
  DECLARE proptaskcnt = i4
  SET proptaskcnt = 0
  SELECT INTO "nl:"
   tr.task_id, tr.prereq_task_id
   FROM (dummyt d  WITH seq = value(responsestobecreatedcnt)),
    task_reltn tr,
    task_activity ta,
    order_task ot
   PLAN (d
    WHERE (newresponse->list[d.seq].action_flag=eaction_create))
    JOIN (tr
    WHERE (tr.prereq_task_id=newresponse->list[d.seq].task_id))
    JOIN (ta
    WHERE ta.task_id=tr.task_id
     AND ta.task_status_cd=pending)
    JOIN (ot
    WHERE ot.reference_task_id=ta.reference_task_id)
   HEAD d.seq
    newresponse->list[d.seq].action_flag = eaction_propose, propcnt += 1, stat = alterlist(reply->
     result.proposal_list,propcnt),
    reply->result.proposal_list[propcnt].task_id = newresponse->list[d.seq].task_id, reply->result.
    proposal_list[propcnt].proposed_dt_tm = newresponse->list[d.seq].response_dt_tm
   DETAIL
    proptaskcnt += 1, stat = alterlist(reply->result.proposal_list[propcnt].task_list,proptaskcnt),
    reply->result.proposal_list[propcnt].task_list[proptaskcnt].task_id = ta.task_id,
    reply->result.proposal_list[propcnt].task_list[proptaskcnt].updt_cnt = ta.updt_cnt, reply->result
    .proposal_list[propcnt].task_list[proptaskcnt].updt_id = ta.updt_id, reply->result.proposal_list[
    propcnt].task_list[proptaskcnt].task_status_cd = ta.task_status_cd,
    reply->result.proposal_list[propcnt].task_list[proptaskcnt].task_class_cd = ta.task_class_cd,
    reply->result.proposal_list[propcnt].task_list[proptaskcnt].task_dt_tm = ta.task_dt_tm, reply->
    result.proposal_list[propcnt].task_list[proptaskcnt].task_description = ot.task_description
   WITH nocounter
  ;end select
  FOR (x = 1 TO responsestobecreatedcnt)
    IF ((newresponse->list[x].action_flag=eaction_create))
     SELECT INTO "nl:"
      y = seq(carenet_seq,nextval)
      FROM dual
      DETAIL
       newresponse->list[x].new_task_id = y
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      y = seq(profile_seq,nextval)
      FROM dual
      DETAIL
       newresponse->list[x].task_reltn_id = y
      WITH nocounter
     ;end select
    ENDIF
  ENDFOR
  INSERT  FROM task_activity ta,
    (dummyt d  WITH seq = value(responsestobecreatedcnt))
   SET ta.task_id = newresponse->list[d.seq].new_task_id, ta.person_id = newresponse->list[d.seq].
    person_id, ta.encntr_id = newresponse->list[d.seq].encntr_id,
    ta.reference_task_id = newresponse->list[d.seq].response_task_id, ta.task_type_cd = newresponse->
    list[d.seq].task_type_cd, ta.order_id = newresponse->list[d.seq].order_id,
    ta.task_activity_cd = newresponse->list[d.seq].task_activity_cd, ta.loc_room_cd = newresponse->
    list[d.seq].loc_room_cd, ta.loc_bed_cd = newresponse->list[d.seq].loc_bed_cd,
    ta.location_cd = newresponse->list[d.seq].location_cd, ta.catalog_cd = newresponse->list[d.seq].
    catalog_cd, ta.task_class_cd = sch,
    ta.task_status_cd = pending, ta.task_dt_tm = cnvtdatetime(newresponse->list[d.seq].response_dt_tm
     ), ta.task_tz =
    IF ((newresponse->list[d.seq].response_dt_tm != 0)) newresponse->list[d.seq].task_tz
    ELSE 0
    ENDIF
    ,
    ta.task_create_dt_tm = cnvtdatetime(sysdate), ta.updt_dt_tm = cnvtdatetime(sysdate), ta.updt_id
     = reqinfo->updt_id,
    ta.updt_task = reqinfo->updt_task, ta.updt_cnt = 0, ta.updt_applctx = reqinfo->updt_applctx,
    ta.active_ind = 1, ta.active_status_cd = reqdata->active_status_cd, ta.active_status_dt_tm =
    cnvtdatetime(sysdate),
    ta.active_status_prsnl_id = reqinfo->updt_id, ta.task_priority_cd = routinetaskprioritycd
   PLAN (d
    WHERE (newresponse->list[d.seq].action_flag=eaction_create))
    JOIN (ta)
   WITH nocounter, status(newresponse->list[d.seq].status)
  ;end insert
  INSERT  FROM task_reltn tr,
    (dummyt d  WITH seq = value(responsestobecreatedcnt))
   SET tr.task_reltn_id = newresponse->list[d.seq].task_reltn_id, tr.task_id = newresponse->list[d
    .seq].new_task_id, tr.prereq_task_id = newresponse->list[d.seq].task_id,
    tr.display_order_id = newresponse->list[d.seq].order_id, tr.beg_effective_dt_tm = cnvtdatetime(
     sysdate), tr.updt_cnt = 0,
    tr.updt_dt_tm = cnvtdatetime(sysdate), tr.updt_id = reqinfo->updt_id, tr.updt_task = reqinfo->
    updt_task,
    tr.updt_applctx = reqinfo->updt_applctx, tr.active_ind = 1, tr.active_status_cd = reqdata->
    active_status_cd,
    tr.active_status_dt_tm = cnvtdatetime(sysdate), tr.active_status_prsnl_id = reqinfo->updt_id
   PLAN (d
    WHERE (newresponse->list[d.seq].action_flag=eaction_create)
     AND (newresponse->list[d.seq].status=1))
    JOIN (tr)
   WITH nocounter, status(newresponse->list[d.seq].status)
  ;end insert
  SELECT INTO "nl:"
   ta.task_id
   FROM (dummyt d  WITH seq = value(responsestobecreatedcnt)),
    task_reltn tr,
    task_activity ta
   PLAN (d
    WHERE (newresponse->list[d.seq].action_flag=eaction_create)
     AND (newresponse->list[d.seq].status=1))
    JOIN (tr
    WHERE (tr.prereq_task_id=newresponse->list[d.seq].task_id))
    JOIN (ta
    WHERE ta.task_id=tr.task_id
     AND ta.task_status_cd != deleted)
   DETAIL
    replycnt += 1, stat = alterlist(reply->result.task_list,replycnt), reply->result.task_list[
    replycnt].task_id = ta.task_id,
    reply->result.task_list[replycnt].updt_cnt = ta.updt_cnt, reply->result.task_list[replycnt].
    updt_id = ta.updt_id, reply->result.task_list[replycnt].task_status_cd = ta.task_status_cd,
    reply->result.task_list[replycnt].parent_task_id = newresponse->list[d.seq].task_id, reply->
    result.task_list[replycnt].task_class_cd = ta.task_class_cd, reply->result.task_list[replycnt].
    task_dt_tm = ta.task_dt_tm,
    reply->result.task_list[replycnt].task_type_cd = ta.task_type_cd
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(responsestobecreatedcnt))
   PLAN (d
    WHERE (newresponse->list[d.seq].action_flag=eaction_create)
     AND (newresponse->list[d.seq].status=0))
   DETAIL
    failcnt += 1, stat = alterlist(reply->result.failure_list,failcnt), reply->result.failure_list[
    failcnt].parent_task_id = newresponse->list[d.seq].task_id,
    reply->result.failure_list[failcnt].updt_id = newresponse->list[d.seq].updt_id, reply->result.
    failure_list[failcnt].task_description = newresponse->list[d.seq].response_task_desc
   WITH nocounter
  ;end select
 ENDIF
 RECORD delresponse(
   1 list[*]
     2 status = i1
     2 task_id = f8
     2 parent_task_id = f8
     2 task_status_cd = f8
     2 updt_id = f8
     2 reference_task_id = f8
     2 task_dt_tm = dq8
     2 task_tz = i4
 )
 DECLARE delcnt = i4
 SET delcnt = 0
 IF (modcnt > 0)
  SELECT INTO "nl:"
   ta2.task_id
   FROM (dummyt d  WITH seq = value(modcnt)),
    task_activity ta,
    orders o,
    task_reltn tr,
    task_activity ta2
   PLAN (d
    WHERE (request->mod_list[d.seq].task_status_cd IN (inprocess, pending))
     AND (previous_task_info->qual[d.seq].status=1))
    JOIN (ta
    WHERE (ta.task_id=request->mod_list[d.seq].task_id)
     AND ta.order_id > 0)
    JOIN (o
    WHERE ta.order_id=o.order_id)
    JOIN (tr
    WHERE tr.prereq_task_id=ta.task_id)
    JOIN (ta2
    WHERE ta2.task_id=tr.task_id
     AND ta2.task_status_cd != deleted
     AND ta2.task_type_cd=response)
   DETAIL
    IF (ta2.task_status_cd=pending)
     delcnt += 1, stat = alterlist(delresponse->list,delcnt), delresponse->list[delcnt].status = 0,
     delresponse->list[delcnt].parent_task_id = request->mod_list[d.seq].task_id, delresponse->list[
     delcnt].task_id = ta2.task_id, delresponse->list[delcnt].task_status_cd = ta2.task_status_cd,
     delresponse->list[delcnt].updt_id = ta2.updt_id, delresponse->list[delcnt].reference_task_id =
     ta2.reference_task_id, delresponse->list[delcnt].task_dt_tm = ta2.task_dt_tm,
     delresponse->list[delcnt].task_tz = previous_task_info->qual[d.seq].task_tz
    ELSE
     replycnt += 1, stat = alterlist(reply->result.task_list,replycnt), reply->result.task_list[
     replycnt].task_id = ta2.task_id,
     reply->result.task_list[replycnt].updt_cnt = ta2.updt_cnt, reply->result.task_list[replycnt].
     updt_id = ta2.updt_id, reply->result.task_list[replycnt].task_status_cd = ta2.task_status_cd,
     reply->result.task_list[replycnt].parent_task_id = request->mod_list[d.seq].task_id, reply->
     result.task_list[replycnt].task_class_cd = ta2.task_class_cd, reply->result.task_list[replycnt].
     task_dt_tm = ta2.task_dt_tm
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (delcnt > 0)
  INSERT  FROM task_action tac,
    (dummyt d  WITH seq = value(delcnt))
   SET tac.seq = 1, tac.task_id = delresponse->list[d.seq].task_id, tac.task_action_seq = seq(
     carenet_seq,nextval),
    tac.task_status_cd =
    IF ((delresponse->list[d.seq].task_status_cd > 0.0)) delresponse->list[d.seq].task_status_cd
    ELSE null
    ENDIF
    , tac.task_dt_tm =
    IF ((delresponse->list[d.seq].task_dt_tm != 0)) cnvtdatetime(delresponse->list[d.seq].task_dt_tm)
    ELSE null
    ENDIF
    , tac.task_tz =
    IF ((delresponse->list[d.seq].task_dt_tm != 0)) delresponse->list[d.seq].task_tz
    ELSE 0
    ENDIF
    ,
    tac.updt_dt_tm = cnvtdatetime(sysdate), tac.updt_id = reqinfo->updt_id, tac.updt_task = reqinfo->
    updt_task,
    tac.updt_cnt = 0, tac.updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (tac)
   WITH nocounter, status(delresponse->list[d.seq].status)
  ;end insert
  UPDATE  FROM task_activity ta,
    (dummyt d  WITH seq = value(delcnt))
   SET ta.task_status_cd = deleted, ta.updt_dt_tm = cnvtdatetime(sysdate), ta.updt_id = reqinfo->
    updt_id,
    ta.updt_task = reqinfo->updt_task, ta.updt_cnt = (ta.updt_cnt+ 1), ta.updt_applctx = reqinfo->
    updt_applctx
   PLAN (d
    WHERE (delresponse->list[d.seq].status=1))
    JOIN (ta
    WHERE (ta.task_id=delresponse->list[d.seq].task_id))
   WITH nocounter, status(delresponse->list[d.seq].status)
  ;end update
  SELECT INTO "nl:"
   ta.task_id
   FROM (dummyt d  WITH seq = value(delcnt)),
    task_activity ta
   PLAN (d
    WHERE (delresponse->list[d.seq].status=1))
    JOIN (ta
    WHERE (ta.task_id=delresponse->list[d.seq].task_id))
   DETAIL
    replycnt += 1, stat = alterlist(reply->result.task_list,replycnt), reply->result.task_list[
    replycnt].task_id = ta.task_id,
    reply->result.task_list[replycnt].updt_cnt = ta.updt_cnt, reply->result.task_list[replycnt].
    updt_id = ta.updt_id, reply->result.task_list[replycnt].task_status_cd = ta.task_status_cd,
    reply->result.task_list[replycnt].parent_task_id = delresponse->list[d.seq].parent_task_id, reply
    ->result.task_list[replycnt].task_class_cd = ta.task_class_cd, reply->result.task_list[replycnt].
    task_dt_tm = ta.task_dt_tm,
    reply->result.task_list[replycnt].task_type_cd = ta.task_type_cd
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(delcnt)),
    order_task ot
   PLAN (d
    WHERE (delresponse->list[d.seq].status=0))
    JOIN (ot
    WHERE (ot.reference_task_id=delresponse->list[d.seq].reference_task_id))
   DETAIL
    failcnt += 1, stat = alterlist(reply->result.failure_list,failcnt), reply->result.failure_list[
    failcnt].task_id = delresponse->list[d.seq].task_id,
    reply->result.failure_list[failcnt].parent_task_id = delresponse->list[d.seq].parent_task_id,
    reply->result.failure_list[failcnt].updt_id = delresponse->list[d.seq].updt_id, reply->result.
    failure_list[failcnt].task_description = ot.task_description
   WITH nocounter
  ;end select
 ENDIF
#exit_response_script
END GO
