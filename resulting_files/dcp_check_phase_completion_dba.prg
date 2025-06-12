CREATE PROGRAM dcp_check_phase_completion:dba
 IF (validate(reply)=0)
  RECORD reply(
    1 phaselist[*]
      2 pathway_id = f8
      2 pw_status_cd = f8
      2 calc_status_cd = f8
      2 updt_cnt = i4
      2 pw_comp_dt_tm = dq8
      2 calc_started_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE RECORD sub_phase_hierarchy
 RECORD sub_phase_hierarchy(
   1 phases[*]
     2 pathway_id = f8
     2 temp_phase_idx = i4
     2 sub_phase_size = i4
     2 sub_phase_processing_count = i4
     2 sub_phase_complete_count = i4
     2 sub_phase_incomplete_count = i4
     2 sub_phases[*]
       3 pathway_id = f8
       3 temp_phase_idx = i4
 )
 RECORD temp(
   1 last_sub_phase_idx = i4
   1 phaselist[*]
     2 pathway_id = f8
     2 pw_status_cd = f8
     2 calc_status_cd = f8
     2 updt_cnt = i4
     2 pw_comp_dt_tm = dq8
     2 hasorders = i2
     2 hasrx = i2
     2 ord_comp_dt_tm = dq8
     2 hasoutcomes = i2
     2 out_comp_dt_tm = dq8
     2 sub_comp_dt_tm = dq8
     2 add_to_reply_ind = i2
     2 phase_idx = i4
     2 sub_phase_idx = i4
     2 started_ind = i2
     2 reply_idx = i4
     2 hasphases = i2
     2 phases[*]
       3 temp_idx = i4
     2 hascomponents = i2
     2 pathway_group_id = f8
     2 has_future_rx_ind = i2
     2 start_dt_tm = dq8
     2 has_end_dt_tm_ind = i2
     2 phase_in_process = i2
     2 end_dt_tm_reached_ind = i2
 )
 DECLARE request_count = i4 WITH protect, constant(value(size(request->phaselist,5)))
 DECLARE cur_dt_tm = dq8 WITH protect, constant(cnvtdatetime(sysdate))
 DECLARE debug = i2 WITH protect, constant(validate(request->debug,0))
 DECLARE ignore_sub_phases_ind = i2 WITH protect, constant(validate(request->ignore_sub_phases_ind,0)
  )
 DECLARE cfailed = c1 WITH protect, noconstant("F")
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE num = i4 WITH protect, noconstant(0)
 DECLARE high = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE reply_phase_idx = i4 WITH protect, noconstant(0)
 DECLARE bissubphase = i2 WITH protect, noconstant(0)
 DECLARE bhassubphases = i2 WITH protect, noconstant(0)
 DECLARE ballsubphasescomplete = i2 WITH protect, noconstant(0)
 DECLARE ballorderscomplete = i2 WITH protect, noconstant(0)
 DECLARE balloutcomescomplete = i2 WITH protect, noconstant(0)
 DECLARE request_idx = i4 WITH protect, noconstant(0)
 DECLARE temp_item_idx = i4 WITH protect, noconstant(0)
 DECLARE phase_idx = i4 WITH protect, noconstant(0)
 DECLARE sub_phase_idx = i4 WITH protect, noconstant(0)
 DECLARE temp_item_count = i4 WITH protect, noconstant(0)
 DECLARE temp_list_size = i4 WITH protect, noconstant(0)
 DECLARE phase_item_count = i4 WITH protect, noconstant(0)
 DECLARE phase_list_size = i4 WITH protect, noconstant(0)
 DECLARE sub_phase_item_count = i4 WITH protect, noconstant(0)
 DECLARE sub_phase_list_size = i4 WITH protect, noconstant(0)
 DECLARE count = i4 WITH protect, noconstant(0)
 DECLARE size = i4 WITH protect, noconstant(0)
 DECLARE lplannedcount = i4 WITH protect, noconstant(0)
 DECLARE linitiatedcount = i4 WITH protect, noconstant(0)
 DECLARE lfuturecount = i4 WITH protect, noconstant(0)
 DECLARE linitiatedreviewcount = i4 WITH protect, noconstant(0)
 DECLARE lfuturereviewcount = i4 WITH protect, noconstant(0)
 DECLARE lcompletedcount = i4 WITH protect, noconstant(0)
 DECLARE lcompletedfrominitiatedcount = i4 WITH protect, noconstant(0)
 DECLARE ldiscontinuedcount = i4 WITH protect, noconstant(0)
 DECLARE ldiscontinuedfrominitiatedcount = i4 WITH protect, noconstant(0)
 DECLARE lskippedcount = i4 WITH protect, noconstant(0)
 DECLARE lvoidcount = i4 WITH protect, noconstant(0)
 DECLARE linprogresscount = i4 WITH protect, noconstant(0)
 DECLARE ldonecount = i4 WITH protect, noconstant(0)
 DECLARE lvalidphasecount = i4 WITH protect, noconstant(0)
 DECLARE bphasestatusdetermined = i2 WITH protect, noconstant(0)
 DECLARE bhasinitiatedphase = i2 WITH protect, noconstant(0)
 DECLARE canceled_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"CANCELED"))
 DECLARE completed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"COMPLETED"))
 DECLARE deleted_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"DELETED"))
 DECLARE discontinued_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"DISCONTINUED"))
 DECLARE trans_cancel_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"TRANS/CANCEL"))
 DECLARE voidedwrslt_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"VOIDEDWRSLT"))
 DECLARE ordered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 DECLARE future_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"FUTURE"))
 DECLARE pw_completed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,"COMPLETED"))
 DECLARE pw_discontinued_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,
   "DISCONTINUED"))
 DECLARE pw_skipped_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,"SKIPPED"))
 DECLARE pw_future_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,"FUTURE"))
 DECLARE pw_futurereview_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,
   "FUTUREREVIEW"))
 DECLARE pw_initiated_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,"INITIATED"))
 DECLARE pw_initreview_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,"INITREVIEW"))
 DECLARE pw_planned_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,"PLANNED"))
 DECLARE pw_void_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,"VOID"))
 DECLARE pw_excluded_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,"EXCLUDED"))
 DECLARE pw_future_proposed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,
   "FUTURPROPOSE"))
 DECLARE pw_initiate_proposed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,
   "INITPROPOSE"))
 DECLARE pw_planned_proposed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,
   "PLANPROPOSE"))
 DECLARE order_comp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16750,"ORDER CREATE"))
 DECLARE prescription_comp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16750,
   "PRESCRIPTION"))
 DECLARE outcome_comp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16750,"RESULT OUTCO"))
 DECLARE subphase_comp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16750,"SUBPHASE"))
 DECLARE outcome_activated_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",30182,"ACTIVATED"
   ))
 DECLARE outcome_void_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",30182,"VOID"))
 DECLARE outcome_future_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",30182,"FUTURE"))
 IF (debug=1)
  CALL echorecord(request)
 ENDIF
 SET high = request_count
 IF (ignore_sub_phases_ind=0)
  SELECT INTO "nl:"
   apc.pathway_id
   FROM act_pw_comp apc
   PLAN (apc
    WHERE expand(num,1,high,apc.pathway_id,request->phaselist[num].pathwayid)
     AND apc.comp_type_cd=subphase_comp_cd
     AND apc.activated_ind=1)
   ORDER BY apc.pathway_id
   HEAD REPORT
    temp_item_count = 0, temp_list_size = 0, phase_item_count = 0,
    phase_list_size = 0
   HEAD apc.pathway_id
    sub_phase_item_count = 0, sub_phase_list_size = 0, phase_item_count += 1
    IF (phase_item_count > phase_list_size)
     phase_list_size += 20, stat = alterlist(sub_phase_hierarchy->phases,phase_list_size)
    ENDIF
    sub_phase_hierarchy->phases[phase_item_count].pathway_id = apc.pathway_id
   DETAIL
    sub_phase_item_count += 1
    IF (sub_phase_item_count > sub_phase_list_size)
     sub_phase_list_size += 20, stat = alterlist(sub_phase_hierarchy->phases[phase_item_count].
      sub_phases,sub_phase_list_size)
    ENDIF
    sub_phase_hierarchy->phases[phase_item_count].sub_phases[sub_phase_item_count].pathway_id = apc
    .parent_entity_id, temp_item_count += 1
    IF (temp_item_count > temp_list_size)
     temp_list_size += 20, stat = alterlist(temp->phaselist,temp_list_size)
    ENDIF
    temp->phaselist[temp_item_count].pathway_id = apc.parent_entity_id, temp->phaselist[
    temp_item_count].phase_idx = phase_item_count, temp->phaselist[temp_item_count].sub_phase_idx =
    sub_phase_item_count,
    sub_phase_hierarchy->phases[phase_item_count].sub_phases[sub_phase_item_count].temp_phase_idx =
    temp_item_count
   FOOT  apc.pathway_id
    IF (sub_phase_item_count > 0)
     sub_phase_hierarchy->phases[phase_item_count].sub_phase_size = sub_phase_item_count,
     sub_phase_hierarchy->phases[phase_item_count].sub_phase_processing_count = sub_phase_item_count
     IF (sub_phase_item_count < sub_phase_list_size)
      stat = alterlist(sub_phase_hierarchy->phases[phase_item_count].sub_phases,sub_phase_item_count)
     ENDIF
    ENDIF
   FOOT REPORT
    IF (phase_item_count > 0
     AND phase_item_count < phase_list_size)
     phase_list_size = phase_item_count, stat = alterlist(sub_phase_hierarchy->phases,
      phase_item_count)
    ENDIF
    IF (temp_item_count > 0
     AND temp_item_count < temp_list_size)
     temp_list_size = temp_item_count, stat = alterlist(temp->phaselist,temp_item_count)
    ENDIF
   WITH nocounter, expand = 1
  ;end select
 ENDIF
 SET temp->last_sub_phase_idx = temp_item_count
 FOR (request_idx = 1 TO request_count)
   SET temp_item_idx = 0
   IF ((temp->last_sub_phase_idx > 0))
    SET temp_item_idx = locateval(temp_item_idx,1,temp->last_sub_phase_idx,request->phaselist[
     request_idx].pathwayid,temp->phaselist[temp_item_idx].pathway_id)
   ENDIF
   IF (temp_item_idx > 0)
    SET temp->phaselist[temp_item_idx].add_to_reply_ind = 1
   ELSE
    SET temp_item_count += 1
    IF (temp_item_count > temp_list_size)
     SET temp_list_size += 20
     SET stat = alterlist(temp->phaselist,temp_list_size)
    ENDIF
    SET temp->phaselist[temp_item_count].pathway_id = request->phaselist[request_idx].pathwayid
    SET temp->phaselist[temp_item_count].add_to_reply_ind = 1
    SET phase_idx = locateval(phase_idx,1,phase_list_size,request->phaselist[request_idx].pathwayid,
     sub_phase_hierarchy->phases[phase_idx].pathway_id)
    IF (phase_idx > 0)
     SET sub_phase_hierarchy->phases[phase_idx].temp_phase_idx = temp_item_count
     SET temp->phaselist[temp_item_count].phase_idx = phase_idx
    ENDIF
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  apc.pathway_id
  FROM pathway_reltn pr
  PLAN (pr
   WHERE expand(num,1,high,pr.pathway_s_id,request->phaselist[num].pathwayid)
    AND pr.type_mean IN ("GROUP"))
  ORDER BY pr.pathway_s_id, pr.pathway_t_id, pr.type_mean
  HEAD REPORT
   lparentphaseindex = 0, lchildphaseindex = 0, lchildphasecount = 0
  HEAD pr.pathway_s_id
   lchildphasecount = 0, lparentphaseindex = locateval(lparentphaseindex,1,temp_item_count,pr
    .pathway_s_id,temp->phaselist[lparentphaseindex].pathway_id)
  HEAD pr.pathway_t_id
   IF (lparentphaseindex > 0)
    lchildphaseindex = locateval(lchildphaseindex,1,temp_item_count,pr.pathway_t_id,temp->phaselist[
     lchildphaseindex].pathway_id)
    IF (lchildphaseindex <= 0)
     temp_item_count += 1
     IF (temp_item_count > temp_list_size)
      temp_list_size += 20, stat = alterlist(temp->phaselist,temp_list_size)
     ENDIF
     lchildphaseindex = temp_item_count, temp->phaselist[lchildphaseindex].pathway_id = pr
     .pathway_t_id
    ENDIF
    IF (lchildphaseindex > 0)
     temp->phaselist[lparentphaseindex].hasphases = 1, lchildphasecount += 1, stat = alterlist(temp->
      phaselist[lparentphaseindex].phases,lchildphasecount),
     temp->phaselist[lparentphaseindex].phases[lchildphasecount].temp_idx = lchildphaseindex
    ENDIF
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 IF (debug=1)
  CALL echorecord(temp)
 ENDIF
 IF (temp_item_count > 0
  AND temp_item_count < temp_list_size)
  SET temp_list_size = temp_item_count
  SET stat = alterlist(temp->phaselist,temp_list_size)
 ENDIF
 SET high = temp_list_size
 SELECT INTO "nl:"
  FROM pathway p
  PLAN (p
   WHERE expand(num,1,high,p.pathway_id,temp->phaselist[num].pathway_id))
  HEAD REPORT
   cnt = 0, bissubphase = 0
  DETAIL
   bissubphase = 0, cnt = locateval(num,1,high,p.pathway_id,temp->phaselist[num].pathway_id)
   IF (cnt > 0)
    phase_idx = temp->phaselist[cnt].phase_idx, sub_phase_idx = temp->phaselist[cnt].sub_phase_idx
    IF (phase_idx > 0
     AND sub_phase_idx > 0)
     bissubphase = 1
    ENDIF
    IF (bissubphase=1)
     sub_phase_hierarchy->phases[phase_idx].sub_phase_processing_count -= 1, sub_phase_hierarchy->
     phases[phase_idx].sub_phase_incomplete_count += 1
    ENDIF
    temp->phaselist[cnt].pathway_id = p.pathway_id, temp->phaselist[cnt].pw_status_cd = p
    .pw_status_cd, temp->phaselist[cnt].updt_cnt = p.updt_cnt,
    temp->phaselist[cnt].started_ind = p.started_ind, temp->phaselist[cnt].pathway_group_id = p
    .pathway_group_id, temp->phaselist[cnt].start_dt_tm = cnvtdatetime(p.start_dt_tm)
    IF (((p.duration_qty > 0
     AND p.duration_unit_cd > 0.0) OR (p.calc_end_dt_tm != null)) )
     temp->phaselist[cnt].has_end_dt_tm_ind = 1
    ENDIF
    IF (p.calc_end_dt_tm != null
     AND cnvtdatetime(p.calc_end_dt_tm) <= cnvtdatetime(cur_dt_tm))
     temp->phaselist[cnt].end_dt_tm_reached_ind = 1
    ENDIF
    IF (p.pw_status_cd != pw_initiated_cd
     AND p.pw_status_cd != pw_future_cd)
     temp->phaselist[cnt].calc_status_cd = p.pw_status_cd
     IF (bissubphase=1)
      IF (p.pw_status_cd IN (pw_completed_cd, pw_discontinued_cd, pw_void_cd))
       temp_item_idx = sub_phase_hierarchy->phases[phase_idx].temp_phase_idx
       IF ((((temp->phaselist[temp_item_idx].sub_comp_dt_tm=null)
        AND p.calc_end_dt_tm != null) OR (cnvtdatetime(temp->phaselist[temp_item_idx].sub_comp_dt_tm)
        < cnvtdatetime(p.calc_end_dt_tm))) )
        temp->phaselist[temp_item_idx].sub_comp_dt_tm = cnvtdatetime(p.calc_end_dt_tm)
       ENDIF
      ENDIF
     ENDIF
    ELSEIF (p.pw_status_cd=pw_initiated_cd
     AND p.calc_end_dt_tm != null
     AND cnvtdatetime(p.calc_end_dt_tm) <= cnvtdatetime(cur_dt_tm))
     temp->phaselist[cnt].calc_status_cd = pw_completed_cd, temp->phaselist[cnt].pw_comp_dt_tm =
     cnvtdatetime(p.calc_end_dt_tm)
    ELSE
     IF (p.pw_status_cd=pw_initiated_cd
      AND p.calc_end_dt_tm != null)
      temp->phaselist[cnt].phase_in_process = 1
     ENDIF
     temp->phaselist[cnt].calc_status_cd = 0
    ENDIF
   ENDIF
  FOOT REPORT
   dummy = 0
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  apc.pathway_id
  FROM act_pw_comp apc,
   orders o
  PLAN (apc
   WHERE expand(num,1,high,apc.pathway_id,temp->phaselist[num].pathway_id)
    AND apc.comp_type_cd IN (order_comp_cd, prescription_comp_cd)
    AND apc.activated_ind=1)
   JOIN (o
   WHERE (o.order_id= Outerjoin(apc.parent_entity_id)) )
  ORDER BY apc.pathway_id
  HEAD REPORT
   idx = 0
  HEAD apc.pathway_id
   idx = locateval(idx,1,high,apc.pathway_id,temp->phaselist[idx].pathway_id), phasecomplete = "Y",
   oneactiveorder = "N",
   oneactiverx = "N"
   IF ((((temp->phaselist[idx].calc_status_cd != 0)) OR ((temp->phaselist[idx].hasphases=1))) )
    skip = "Y"
   ELSE
    skip = "N"
   ENDIF
  DETAIL
   IF (skip="N")
    IF (o.order_id > 0)
     IF (apc.comp_type_cd=order_comp_cd)
      oneactiveorder = "Y", temp->phaselist[idx].hasorders = 1
      IF (phasecomplete="Y")
       IF (o.order_status_cd != canceled_cd
        AND o.order_status_cd != completed_cd
        AND o.order_status_cd != deleted_cd
        AND o.order_status_cd != discontinued_cd
        AND o.order_status_cd != trans_cancel_cd
        AND o.order_status_cd != voidedwrslt_cd)
        phasecomplete = "N"
       ENDIF
      ENDIF
      IF ((((temp->phaselist[idx].ord_comp_dt_tm=null)
       AND o.projected_stop_dt_tm != null) OR (cnvtdatetime(temp->phaselist[idx].ord_comp_dt_tm) <
      cnvtdatetime(o.projected_stop_dt_tm))) )
       temp->phaselist[idx].ord_comp_dt_tm = cnvtdatetime(o.projected_stop_dt_tm)
      ENDIF
     ELSEIF (apc.comp_type_cd=prescription_comp_cd)
      oneactiverx = "Y", temp->phaselist[idx].hasrx = 1
      IF ((temp->phaselist[idx].pw_status_cd=pw_future_cd)
       AND o.order_status_cd=future_cd)
       temp->phaselist[idx].has_future_rx_ind = 1
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  FOOT  apc.pathway_id
   IF (skip="N")
    IF (phasecomplete="N"
     AND oneactiveorder="Y")
     temp->phaselist[idx].calc_status_cd = temp->phaselist[idx].pw_status_cd
    ELSE
     IF (oneactiveorder="N"
      AND oneactiverx="N")
      temp->phaselist[idx].hasorders = 2, temp->phaselist[idx].hasrx = 2
     ENDIF
    ENDIF
   ENDIF
  FOOT REPORT
   dummy = 0
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  apc.pathway_id
  FROM act_pw_comp apc,
   outcome_activity oa
  PLAN (apc
   WHERE expand(num,1,high,apc.pathway_id,temp->phaselist[num].pathway_id)
    AND apc.comp_type_cd=outcome_comp_cd
    AND apc.included_ind=1)
   JOIN (oa
   WHERE (oa.outcome_activity_id= Outerjoin(apc.parent_entity_id)) )
  ORDER BY apc.pathway_id
  HEAD REPORT
   idx = 0
  HEAD apc.pathway_id
   idx = locateval(idx,1,high,apc.pathway_id,temp->phaselist[idx].pathway_id), phasecomplete = "Y",
   oneactive = "N"
   IF ((((temp->phaselist[idx].calc_status_cd != 0)) OR ((temp->phaselist[idx].hasphases=1))) )
    skip = "Y"
   ELSE
    skip = "N"
   ENDIF
  DETAIL
   IF (skip="N")
    IF (oa.outcome_activity_id > 0)
     oneactive = "Y", temp->phaselist[idx].hasoutcomes = 1
     IF (phasecomplete="Y")
      IF (((oa.outcome_status_cd=outcome_activated_cd
       AND ((oa.end_dt_tm=null) OR (cnvtdatetime(oa.end_dt_tm) > cnvtdatetime(cur_dt_tm))) ) OR (oa
      .outcome_status_cd=outcome_future_cd)) )
       phasecomplete = "N"
      ENDIF
     ENDIF
     IF (oa.outcome_status_cd=outcome_void_cd
      AND ((oa.end_dt_tm=null
      AND oa.outcome_status_dt_tm != null) OR (oa.end_dt_tm != null
      AND cnvtdatetime(oa.end_dt_tm) > cnvtdatetime(oa.outcome_status_dt_tm)))
      AND (((temp->phaselist[idx].out_comp_dt_tm=null)
      AND oa.outcome_status_dt_tm != null) OR (cnvtdatetime(temp->phaselist[idx].out_comp_dt_tm) <
     cnvtdatetime(oa.outcome_status_dt_tm))) )
      temp->phaselist[idx].out_comp_dt_tm = cnvtdatetime(oa.outcome_status_dt_tm)
     ELSEIF ((((temp->phaselist[idx].out_comp_dt_tm=null)
      AND oa.end_dt_tm != null) OR (cnvtdatetime(temp->phaselist[idx].out_comp_dt_tm) < cnvtdatetime(
      oa.end_dt_tm))) )
      temp->phaselist[idx].out_comp_dt_tm = cnvtdatetime(oa.end_dt_tm)
     ENDIF
    ENDIF
   ENDIF
  FOOT  apc.pathway_id
   IF (skip="N")
    IF (phasecomplete="N"
     AND oneactive="Y")
     temp->phaselist[idx].calc_status_cd = temp->phaselist[idx].pw_status_cd
    ELSEIF (oneactive="N")
     temp->phaselist[idx].hasoutcomes = 2
    ENDIF
   ENDIF
  FOOT REPORT
   dummy = 0
  WITH nocounter, expand = 1
 ;end select
 SET stat = alterlist(reply->phaselist,request_count)
 SET reply_phase_idx = 0
 FOR (i = 1 TO high)
   SET bhassubphases = 0
   SET bissubphase = 0
   SET ballorderscomplete = 1
   SET balloutcomescomplete = 1
   SET ballsubphasescomplete = 1
   SET phase_idx = temp->phaselist[i].phase_idx
   SET sub_phase_idx = temp->phaselist[i].sub_phase_idx
   IF ((temp->phaselist[i].hasphases=0))
    IF (phase_idx > 0)
     IF (sub_phase_idx > 0)
      SET bissubphase = 1
     ELSEIF ((sub_phase_hierarchy->phases[phase_idx].sub_phase_size > 0))
      SET bhassubphases = 1
      SET temp->phaselist[i].hascomponents = 1
     ENDIF
    ENDIF
    IF ((temp->phaselist[i].calc_status_cd=0))
     IF (bhassubphases=1
      AND ignore_sub_phases_ind=0)
      IF ((((sub_phase_hierarchy->phases[phase_idx].sub_phase_incomplete_count > 0)) OR ((
      sub_phase_hierarchy->phases[phase_idx].sub_phase_size=sub_phase_hierarchy->phases[phase_idx].
      sub_phase_processing_count))) )
       SET ballsubphasescomplete = 0
      ENDIF
     ENDIF
     IF ((((temp->phaselist[i].hasorders != 0)) OR ((temp->phaselist[i].hasoutcomes != 0))) )
      SET temp->phaselist[i].hascomponents = 1
     ENDIF
     IF ((temp->phaselist[i].hasorders=2))
      SET ballorderscomplete = 0
     ENDIF
     IF ((temp->phaselist[i].hasoutcomes=2))
      SET balloutcomescomplete = 0
     ENDIF
     IF ((temp->phaselist[i].hascomponents=0)
      AND (temp->phaselist[i].hasrx=1)
      AND (temp->phaselist[i].pathway_group_id <= 0.0))
      IF ((temp->phaselist[i].pw_status_cd=pw_future_cd)
       AND (temp->phaselist[i].has_future_rx_ind=1))
       SET temp->phaselist[i].calc_status_cd = pw_future_cd
      ELSEIF ((temp->phaselist[i].pw_status_cd=pw_future_cd)
       AND (temp->phaselist[i].has_end_dt_tm_ind=1)
       AND (temp->phaselist[i].end_dt_tm_reached_ind=0))
       SET temp->phaselist[i].calc_status_cd = pw_future_cd
      ELSEIF ((((temp->phaselist[i].has_end_dt_tm_ind=0)) OR ((temp->phaselist[i].pw_status_cd=
      pw_future_cd))) )
       SET temp->phaselist[i].pw_comp_dt_tm = cnvtdatetime(temp->phaselist[i].start_dt_tm)
       SET temp->phaselist[i].calc_status_cd = pw_completed_cd
      ELSEIF ((temp->phaselist[i].has_end_dt_tm_ind=1)
       AND (temp->phaselist[i].phase_in_process=1))
       SET temp->phaselist[i].calc_status_cd = temp->phaselist[i].pw_status_cd
      ENDIF
     ELSEIF ((temp->phaselist[i].hascomponents=1)
      AND ballsubphasescomplete=1
      AND ballorderscomplete=1
      AND balloutcomescomplete=1)
      IF ((temp->phaselist[i].pw_status_cd=pw_future_cd)
       AND (temp->phaselist[i].has_future_rx_ind=1))
       SET temp->phaselist[i].calc_status_cd = pw_future_cd
      ELSE
       SET temp->phaselist[i].calc_status_cd = pw_completed_cd
      ENDIF
     ELSE
      SET temp->phaselist[i].calc_status_cd = temp->phaselist[i].pw_status_cd
     ENDIF
    ENDIF
    IF ((temp->phaselist[i].calc_status_cd=pw_completed_cd))
     IF ((temp->phaselist[i].pw_comp_dt_tm=null))
      IF ((temp->phaselist[i].hasoutcomes=1)
       AND (temp->phaselist[i].hasorders=0))
       SET temp->phaselist[i].pw_comp_dt_tm = cnvtdatetime(temp->phaselist[i].out_comp_dt_tm)
      ELSEIF ((temp->phaselist[i].hasoutcomes=0)
       AND (temp->phaselist[i].hasorders=1))
       SET temp->phaselist[i].pw_comp_dt_tm = cnvtdatetime(temp->phaselist[i].ord_comp_dt_tm)
      ELSEIF ((temp->phaselist[i].hasoutcomes=1)
       AND (temp->phaselist[i].hasorders=1))
       IF (cnvtdatetime(temp->phaselist[i].ord_comp_dt_tm) > cnvtdatetime(temp->phaselist[i].
        out_comp_dt_tm))
        SET temp->phaselist[i].pw_comp_dt_tm = cnvtdatetime(temp->phaselist[i].ord_comp_dt_tm)
       ELSE
        SET temp->phaselist[i].pw_comp_dt_tm = cnvtdatetime(temp->phaselist[i].out_comp_dt_tm)
       ENDIF
      ENDIF
      IF ((((temp->phaselist[i].pw_comp_dt_tm=null)
       AND (temp->phaselist[i].sub_comp_dt_tm != null)) OR (cnvtdatetime(temp->phaselist[i].
       pw_comp_dt_tm) < cnvtdatetime(temp->phaselist[i].sub_comp_dt_tm))) )
       SET temp->phaselist[i].pw_comp_dt_tm = cnvtdatetime(temp->phaselist[i].sub_comp_dt_tm)
      ENDIF
     ENDIF
    ENDIF
    IF ((temp->phaselist[i].calc_status_cd IN (pw_completed_cd, pw_discontinued_cd, pw_void_cd)))
     IF (bissubphase=1)
      SET temp_item_idx = sub_phase_hierarchy->phases[phase_idx].temp_phase_idx
      IF ((sub_phase_hierarchy->phases[phase_idx].sub_phase_incomplete_count > 0))
       SET sub_phase_hierarchy->phases[phase_idx].sub_phase_complete_count += 1
       SET sub_phase_hierarchy->phases[phase_idx].sub_phase_incomplete_count -= 1
      ENDIF
      IF (temp_item_idx > 0)
       IF ((((temp->phaselist[temp_item_idx].sub_comp_dt_tm=null)
        AND (temp->phaselist[i].pw_comp_dt_tm != null)) OR (cnvtdatetime(temp->phaselist[
        temp_item_idx].sub_comp_dt_tm) < cnvtdatetime(temp->phaselist[i].pw_comp_dt_tm))) )
        SET temp->phaselist[temp_item_idx].sub_comp_dt_tm = cnvtdatetime(temp->phaselist[i].
         pw_comp_dt_tm)
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF ((temp->phaselist[i].add_to_reply_ind=1))
    SET reply_phase_idx += 1
    SET reply->phaselist[reply_phase_idx].pathway_id = temp->phaselist[i].pathway_id
    SET reply->phaselist[reply_phase_idx].pw_status_cd = temp->phaselist[i].pw_status_cd
    SET reply->phaselist[reply_phase_idx].calc_status_cd = temp->phaselist[i].calc_status_cd
    SET reply->phaselist[reply_phase_idx].updt_cnt = temp->phaselist[i].updt_cnt
    SET reply->phaselist[reply_phase_idx].pw_comp_dt_tm = cnvtdatetime(temp->phaselist[i].
     pw_comp_dt_tm)
    IF (validate(reply->phaselist[reply_phase_idx].calc_started_ind)=1)
     SET reply->phaselist[reply_phase_idx].calc_started_ind = temp->phaselist[i].started_ind
    ENDIF
    SET temp->phaselist[i].reply_idx = reply_phase_idx
   ENDIF
 ENDFOR
 SET temp_item_idx_old = 0
 SET temp_item_idx = locateval(temp_item_idx,1,temp_item_count,1,temp->phaselist[temp_item_idx].
  hasphases)
 WHILE (temp_item_idx > 0)
   SET temp_item_idx_old = temp_item_idx
   SET reply_phase_idx = temp->phaselist[temp_item_idx].reply_idx
   IF (reply_phase_idx > 0)
    SET count = size(temp->phaselist[temp_item_idx].phases,5)
    SET bhasinitiatedphase = 0
    SET bphasestatusdetermined = 0
    SET lplannedcount = 0
    SET linitiatedcount = 0
    SET lfuturecount = 0
    SET linitiatedreviewcount = 0
    SET lfuturereviewcount = 0
    SET lcompletedcount = 0
    SET ldiscontinuedcount = 0
    SET lskippedcount = 0
    SET lvoidcount = 0
    SET linprogresscount = 0
    SET ldonecount = 0
    SET lvalidphasecount = count
    FOR (i = 1 TO count)
     SET phase_idx = temp->phaselist[temp_item_idx].phases[i].temp_idx
     IF (phase_idx > 0)
      IF ((temp->phaselist[phase_idx].started_ind=1))
       SET bhasinitiatedphase = 1
      ENDIF
      CASE (temp->phaselist[phase_idx].calc_status_cd)
       OF pw_planned_cd:
        SET reply->phaselist[reply_phase_idx].calc_status_cd = temp->phaselist[phase_idx].
        calc_status_cd
        SET bphasestatusdetermined = 1
       OF pw_initreview_cd:
        SET reply->phaselist[reply_phase_idx].calc_status_cd = temp->phaselist[phase_idx].
        calc_status_cd
        SET bphasestatusdetermined = 1
       OF pw_futurereview_cd:
        SET reply->phaselist[reply_phase_idx].calc_status_cd = temp->phaselist[phase_idx].
        calc_status_cd
        SET bphasestatusdetermined = 1
       OF pw_initiated_cd:
        SET reply->phaselist[reply_phase_idx].calc_status_cd = temp->phaselist[phase_idx].
        calc_status_cd
        SET bphasestatusdetermined = 1
       OF pw_future_proposed_cd:
        SET reply->phaselist[reply_phase_idx].calc_status_cd = temp->phaselist[phase_idx].
        calc_status_cd
        SET bphasestatusdetermined = 1
       OF pw_initiate_proposed_cd:
        SET reply->phaselist[reply_phase_idx].calc_status_cd = temp->phaselist[phase_idx].
        calc_status_cd
        SET bphasestatusdetermined = 1
       OF pw_planned_proposed_cd:
        SET reply->phaselist[reply_phase_idx].calc_status_cd = temp->phaselist[phase_idx].
        calc_status_cd
        SET bphasestatusdetermined = 1
       OF pw_future_cd:
        SET lfuturecount += 1
       OF pw_void_cd:
        SET ldonecount += 1
        SET lvoidcount += 1
       OF pw_completed_cd:
        SET ldonecount += 1
        SET lcompletedcount += 1
       OF pw_discontinued_cd:
        SET ldonecount += 1
        SET ldiscontinuedcount += 1
       OF pw_skipped_cd:
        SET ldonecount += 1
        SET lskippedcount += 1
       OF pw_excluded_cd:
        SET lvalidphasecount -= 1
      ENDCASE
      IF (bphasestatusdetermined=1)
       SET i = (count+ 1)
      ENDIF
     ENDIF
    ENDFOR
    IF (lvalidphasecount > 0)
     IF (bphasestatusdetermined=0)
      IF (ldonecount=lvalidphasecount)
       IF (lcompletedcount > 0)
        SET reply->phaselist[reply_phase_idx].calc_status_cd = pw_completed_cd
       ELSEIF (ldiscontinuedcount > 0)
        SET reply->phaselist[reply_phase_idx].calc_status_cd = pw_discontinued_cd
       ELSEIF (lskippedcount > 0)
        SET reply->phaselist[reply_phase_idx].calc_status_cd = pw_discontinued_cd
       ELSEIF (lvoidcount > 0)
        SET reply->phaselist[reply_phase_idx].calc_status_cd = pw_void_cd
       ENDIF
      ELSEIF (lfuturecount > 0)
       IF (bhasinitiatedphase=1)
        SET reply->phaselist[reply_phase_idx].calc_status_cd = pw_initiated_cd
       ELSE
        SET reply->phaselist[reply_phase_idx].calc_status_cd = pw_future_cd
       ENDIF
      ELSE
       SET reply->phaselist[reply_phase_idx].calc_status_cd = pw_excluded_cd
      ENDIF
     ENDIF
    ELSE
     SET reply->phaselist[reply_phase_idx].calc_status_cd = pw_excluded_cd
    ENDIF
   ENDIF
   SET temp_item_idx = locateval(temp_item_idx,(temp_item_idx_old+ 1),temp_item_count,1,temp->
    phaselist[temp_item_idx].hasphases)
 ENDWHILE
#exit_script
 IF (cfailed="T")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF (debug=1)
  CALL echorecord(sub_phase_hierarchy)
  CALL echorecord(temp)
  CALL echorecord(reply)
  DECLARE cur_dt_tm2 = dq8 WITH protect, constant(cnvtdatetime(sysdate))
  CALL echo(concat("Total script time = ",build(datetimediff(cur_dt_tm2,cur_dt_tm,5))))
 ENDIF
 FREE RECORD sub_phase_hierarchy
 FREE RECORD temp
 SET last_mod = "014"
END GO
