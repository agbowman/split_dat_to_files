CREATE PROGRAM dcp_get_act_plan_detail:dba
 SET modify = predeclare
 RECORD subphases(
   1 list[*]
     2 pw_group_nbr = f8
     2 pathway_id = f8
     2 sequence = i4
 )
 DECLARE last_mod = c3 WITH protect, noconstant(fillstring(3,"000"))
 DECLARE mod_date = c30 WITH protect, noconstant(fillstring(30," "))
 DECLARE cfailed = c1 WITH protect, noconstant("F")
 DECLARE foundplanevidence = c1 WITH protect, noconstant("N")
 DECLARE foundplanreference = c1 WITH protect, noconstant("N")
 DECLARE evidencecnt = i4 WITH protect, noconstant(0)
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE idx2 = i4 WITH protect, noconstant(0)
 DECLARE subidx = i4 WITH protect, noconstant(0)
 DECLARE i = i4 WITH protect, noconstant(0)
 DECLARE j = i4 WITH protect, noconstant(0)
 DECLARE num = i4 WITH protect, noconstant(0)
 DECLARE rhigh = i4 WITH protect, noconstant(0)
 DECLARE phasecnt = i4 WITH protect, noconstant(0)
 DECLARE subphasecnt = i4 WITH protect, noconstant(0)
 DECLARE debug = i2 WITH protect, constant(validate(request->debug))
 DECLARE pw_dropped_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,"DROPPED"))
 DECLARE dpwgroupnbr = f8 WITH protect, noconstant(0.0)
 DECLARE dpathwayid = f8 WITH protect, noconstant(0.0)
 DECLARE linkcnt = i4 WITH protect, noconstant(0)
 IF (debug=1)
  CALL echorecord(request)
 ENDIF
 IF (validate(request->pw_group_nbr)=0)
  GO TO exit_script
 ELSE
  SET dpwgroupnbr = request->pw_group_nbr
 ENDIF
 IF (validate(request->pathway_id)=0)
  GO TO exit_script
 ELSE
  SET dpathwayid = request->pathway_id
 ENDIF
 IF (dpwgroupnbr <= 0.0
  AND dpathwayid <= 0.0)
  GO TO exit_script
 ENDIF
 IF (dpwgroupnbr > 0.0)
  SELECT INTO "nl:"
   pw.pathway_id, pw.person_id, pw.encntr_id
   FROM pathway pw,
    pathway_action pa
   PLAN (pw
    WHERE pw.pw_group_nbr=dpwgroupnbr)
    JOIN (pa
    WHERE pa.pathway_id=pw.pathway_id)
   ORDER BY pw.pw_group_nbr, pw.pathway_id, pa.pw_action_seq DESC
   HEAD REPORT
    subphasecnt = 0
   HEAD pw.pw_group_nbr
    reply->pw_group_nbr = pw.pw_group_nbr, reply->pw_group_desc = trim(pw.pw_group_desc), reply->
    cross_encntr_ind = pw.cross_encntr_ind,
    reply->version = pw.pw_cat_version, reply->pathway_catalog_id = pw.pw_cat_group_id, reply->
    pathway_type_cd = pw.pathway_type_cd,
    reply->pathway_class_cd = pw.pathway_class_cd, reply->cycle_nbr = pw.cycle_nbr, reply->
    default_view_mean = pw.default_view_mean,
    reply->diagnosis_capture_ind = pw.diagnosis_capture_ind, reply->cycle_label_cd = pw
    .cycle_label_cd, reply->pathway_customized_plan_id = pw.pathway_customized_plan_id,
    phasecnt = 0
   HEAD pw.pathway_id
    IF (pw.type_mean="PHASE")
     reply->type_mean = "PATHWAY"
    ELSEIF (pw.type_mean="TAPERPLAN")
     reply->type_mean = "TAPERPLAN"
    ELSEIF (pw.type_mean="CAREPLAN")
     reply->type_mean = "CAREPLAN"
    ENDIF
    phasecnt += 1
    IF (phasecnt > size(reply->phaselist,5))
     stat = alterlist(reply->phaselist,(phasecnt+ 10))
    ENDIF
    reply->phaselist[phasecnt].pathway_id = pw.pathway_id, reply->phaselist[phasecnt].encntr_id = pw
    .encntr_id, reply->phaselist[phasecnt].pw_status_cd = pw.pw_status_cd,
    reply->phaselist[phasecnt].description = trim(pw.description), reply->phaselist[phasecnt].
    type_mean = pw.type_mean, reply->phaselist[phasecnt].duration_qty = pw.duration_qty,
    reply->phaselist[phasecnt].duration_unit_cd = pw.duration_unit_cd, reply->phaselist[phasecnt].
    started_ind = pw.started_ind, reply->phaselist[phasecnt].processing_ind = 0,
    reply->phaselist[phasecnt].updt_cnt = pw.updt_cnt, reply->phaselist[phasecnt].start_dt_tm = pw
    .start_dt_tm, reply->phaselist[phasecnt].calc_end_dt_tm = pw.calc_end_dt_tm,
    reply->phaselist[phasecnt].pathway_catalog_id = pw.pathway_catalog_id, reply->phaselist[phasecnt]
    .order_dt_tm = pw.order_dt_tm, reply->phaselist[phasecnt].display_method_cd = pw
    .display_method_cd,
    reply->phaselist[phasecnt].parent_phase_desc = pw.parent_phase_desc, reply->phaselist[phasecnt].
    start_tz = pw.start_tz, reply->phaselist[phasecnt].calc_end_tz = pw.calc_end_tz,
    reply->phaselist[phasecnt].order_tz = pw.order_tz, reply->phaselist[phasecnt].period_custom_label
     = pw.period_custom_label, reply->phaselist[phasecnt].period_nbr = pw.period_nbr,
    reply->phaselist[phasecnt].warning_level_bit = pw.warning_level_bit,
    CALL setphaseattributesintoreply(phasecnt,pw.copy_source_pathway_id,pw.review_required_sig_count,
    pw.linked_phase_ind)
    IF (pw.type_mean="SUBPHASE")
     subphasecnt += 1
     IF (subphasecnt > size(subphases->list,5))
      stat = alterlist(subphases->list,(subphasecnt+ 10))
     ENDIF
     subphases->list[subphasecnt].pathway_id = pw.pathway_id, subphases->list[subphasecnt].
     pw_group_nbr = pw.pw_group_nbr
    ENDIF
   FOOT  pw.pathway_id
    IF ((reply->type_mean=null))
     reply->type_mean = "CAREPLAN"
    ENDIF
   FOOT  pw.pw_group_nbr
    IF (phasecnt > 0)
     stat = alterlist(reply->phaselist,phasecnt)
    ENDIF
   FOOT REPORT
    IF (subphasecnt > 0)
     stat = alterlist(subphases->list,subphasecnt)
    ENDIF
   WITH nocounter
  ;end select
 ELSEIF (dpathwayid > 0.0)
  SELECT INTO "nl:"
   pw.pathway_id, pw.person_id, pw.encntr_id
   FROM pathway pw,
    pathway pw2,
    pathway_action pa
   PLAN (pw
    WHERE pw.pathway_id=dpathwayid)
    JOIN (pw2
    WHERE ((pw2.pathway_id=pw.pathway_id) OR (pw2.pw_group_nbr=pw.pw_group_nbr
     AND pw2.type_mean IN ("SUBPHASE", "DOT"))) )
    JOIN (pa
    WHERE pa.pathway_id=pw2.pathway_id)
   ORDER BY pw2.pw_group_nbr, pw2.pathway_id, pa.pw_action_seq DESC
   HEAD REPORT
    subphasecnt = 0
   HEAD pw2.pw_group_nbr
    reply->pw_group_nbr = pw2.pw_group_nbr, reply->pw_group_desc = trim(pw2.pw_group_desc), reply->
    cross_encntr_ind = pw2.cross_encntr_ind,
    reply->version = pw2.pw_cat_version, reply->pathway_catalog_id = pw2.pw_cat_group_id, reply->
    pathway_type_cd = pw2.pathway_type_cd,
    reply->pathway_class_cd = pw2.pathway_class_cd, reply->cycle_nbr = pw2.cycle_nbr, reply->
    default_view_mean = pw2.default_view_mean,
    reply->diagnosis_capture_ind = pw2.diagnosis_capture_ind, reply->cycle_label_cd = pw2
    .cycle_label_cd, phasecnt = 0
   HEAD pw2.pathway_id
    IF (pw2.type_mean="PHASE")
     reply->type_mean = "PATHWAY"
    ELSEIF (pw2.type_mean="TAPERPLAN")
     reply->type_mean = "TAPERPLAN"
    ELSEIF (pw2.type_mean="CAREPLAN")
     reply->type_mean = "CAREPLAN"
    ENDIF
    phasecnt += 1
    IF (phasecnt > size(reply->phaselist,5))
     stat = alterlist(reply->phaselist,(phasecnt+ 10))
    ENDIF
    reply->phaselist[phasecnt].pathway_id = pw2.pathway_id, reply->phaselist[phasecnt].encntr_id =
    pw2.encntr_id, reply->phaselist[phasecnt].pw_status_cd = pw2.pw_status_cd,
    reply->phaselist[phasecnt].description = trim(pw2.description), reply->phaselist[phasecnt].
    type_mean = pw2.type_mean, reply->phaselist[phasecnt].duration_qty = pw2.duration_qty,
    reply->phaselist[phasecnt].duration_unit_cd = pw2.duration_unit_cd, reply->phaselist[phasecnt].
    started_ind = pw2.started_ind, reply->phaselist[phasecnt].processing_ind = 0,
    reply->phaselist[phasecnt].updt_cnt = pw2.updt_cnt, reply->phaselist[phasecnt].start_dt_tm = pw2
    .start_dt_tm, reply->phaselist[phasecnt].calc_end_dt_tm = pw2.calc_end_dt_tm,
    reply->phaselist[phasecnt].pathway_catalog_id = pw2.pathway_catalog_id, reply->phaselist[phasecnt
    ].order_dt_tm = pw2.order_dt_tm, reply->phaselist[phasecnt].display_method_cd = pw2
    .display_method_cd,
    reply->phaselist[phasecnt].parent_phase_desc = pw2.parent_phase_desc, reply->phaselist[phasecnt].
    start_tz = pw2.start_tz, reply->phaselist[phasecnt].calc_end_tz = pw2.calc_end_tz,
    reply->phaselist[phasecnt].order_tz = pw2.order_tz, reply->phaselist[phasecnt].
    period_custom_label = pw2.period_custom_label, reply->phaselist[phasecnt].period_nbr = pw2
    .period_nbr,
    reply->phaselist[phasecnt].warning_level_bit = pw2.warning_level_bit,
    CALL setphaseattributesintoreply(phasecnt,pw2.copy_source_pathway_id,pw2
    .review_required_sig_count,pw2.linked_phase_ind)
    IF (pw2.type_mean="SUBPHASE")
     subphasecnt += 1
     IF (subphasecnt > size(subphases->list,5))
      stat = alterlist(subphases->list,(subphasecnt+ 10))
     ENDIF
     subphases->list[subphasecnt].pathway_id = pw2.pathway_id, subphases->list[subphasecnt].
     pw_group_nbr = pw2.pw_group_nbr
    ENDIF
   FOOT  pw2.pathway_id
    IF ((reply->type_mean=null))
     reply->type_mean = "CAREPLAN"
    ENDIF
   FOOT  pw2.pw_group_nbr
    IF (phasecnt > 0)
     stat = alterlist(reply->phaselist,phasecnt)
    ENDIF
   FOOT REPORT
    IF (subphasecnt > 0)
     stat = alterlist(subphases->list,subphasecnt)
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (subphasecnt > 0
  AND phasecnt > 0)
  SELECT INTO "nl:"
   FROM act_pw_comp apc
   PLAN (apc
    WHERE expand(num,1,subphasecnt,apc.parent_entity_id,subphases->list[num].pathway_id)
     AND apc.parent_entity_name="PATHWAY")
   ORDER BY apc.pathway_id, apc.sequence
   HEAD REPORT
    idx = 0
   DETAIL
    idx = locateval(idx,1,phasecnt,apc.parent_entity_id,reply->phaselist[idx].pathway_id)
    IF (idx > 0)
     reply->phaselist[idx].included_ind = apc.included_ind, idx2 = locateval(idx2,1,phasecnt,apc
      .pathway_id,reply->phaselist[idx2].pathway_id)
     IF (idx2 > 0)
      pwrcnt = (size(reply->phaselist[idx2].phasereltnlist,5)+ 1)
      IF (pwrcnt > size(reply->phaselist[idx2].phasereltnlist,5))
       stat = alterlist(reply->phaselist[idx2].phasereltnlist,pwrcnt)
      ENDIF
      reply->phaselist[idx2].phasereltnlist[pwrcnt].pathway_s_id = reply->phaselist[idx2].pathway_id,
      reply->phaselist[idx2].phasereltnlist[pwrcnt].pathway_t_id = reply->phaselist[idx].pathway_id,
      reply->phaselist[idx2].phasereltnlist[pwrcnt].type_mean = "SUBPHASE",
      reply->phaselist[idx2].sub_phase_ind = 1
     ENDIF
    ENDIF
   FOOT REPORT
    idx = 0
   WITH nocounter
  ;end select
 ENDIF
 SET phasecnt = size(reply->phaselist,5)
 IF (phasecnt <= 0)
  GO TO exit_script
 ENDIF
 DECLARE batch_size = i4 WITH protect, constant(10)
 DECLARE loop_count = i4 WITH protect, constant(ceil((cnvtreal(phasecnt)/ batch_size)))
 DECLARE new_list_size = i4 WITH protect, constant((loop_count * batch_size))
 DECLARE nstart = i4 WITH protect, noconstant(1)
 SET stat = alterlist(reply->phaselist,new_list_size)
 FOR (idx = (phasecnt+ 1) TO new_list_size)
  SET reply->phaselist[idx].pathway_id = reply->phaselist[phasecnt].pathway_id
  SET reply->phaselist[idx].pathway_catalog_id = reply->phaselist[phasecnt].pathway_catalog_id
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(loop_count)),
   pathway_reltn pr,
   pathway pw
  PLAN (d1
   WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
   JOIN (pr
   WHERE expand(num,nstart,(nstart+ (batch_size - 1)),pr.pathway_s_id,reply->phaselist[num].
    pathway_id)
    AND pr.active_ind=1)
   JOIN (pw
   WHERE pw.pathway_id=pr.pathway_t_id
    AND pw.pw_status_cd != pw_dropped_cd)
  ORDER BY pr.pathway_s_id
  HEAD REPORT
   pwrcnt = 0, idx = 0
  HEAD pr.pathway_s_id
   pwrcnt = 0, idx = locateval(idx,1,phasecnt,pr.pathway_s_id,reply->phaselist[idx].pathway_id)
   IF (idx > 0)
    pwrcnt = size(reply->phaselist[idx].phasereltnlist,5)
   ENDIF
  DETAIL
   IF (idx > 0)
    addrelation = 1
    IF (((dpathwayid > 0.0
     AND pr.type_mean="SUCCEED"
     AND (reply->phaselist[idx].type_mean IN ("PHASE", "CAREPLAN"))) OR (pr.type_mean="SUBPHASE")) )
     addrelation = 0
    ENDIF
    IF (addrelation=1)
     pwrcnt += 1
     IF (pwrcnt > size(reply->phaselist[idx].phasereltnlist,5))
      stat = alterlist(reply->phaselist[idx].phasereltnlist,(pwrcnt+ 10))
     ENDIF
     reply->phaselist[idx].phasereltnlist[pwrcnt].pathway_s_id = pr.pathway_s_id, reply->phaselist[
     idx].phasereltnlist[pwrcnt].pathway_t_id = pr.pathway_t_id, reply->phaselist[idx].
     phasereltnlist[pwrcnt].type_mean = pr.type_mean,
     reply->phaselist[idx].phasereltnlist[pwrcnt].offset_qty = pr.offset_qty, reply->phaselist[idx].
     phasereltnlist[pwrcnt].offset_unit_cd = pr.offset_unit_cd
     IF (pr.type_mean="SUCCEED")
      reply->phaselist[idx].succeed_id = pr.pathway_t_id
     ENDIF
    ENDIF
   ENDIF
  FOOT  pr.pathway_s_id
   IF (pwrcnt > 0)
    stat = alterlist(reply->phaselist[idx].phasereltnlist,pwrcnt)
   ENDIF
  FOOT REPORT
   pwrcnt = 0
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(loop_count)),
   pw_comp_act_reltn pcar
  PLAN (d1
   WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
   JOIN (pcar
   WHERE expand(num,nstart,(nstart+ (batch_size - 1)),pcar.pathway_id,reply->phaselist[num].
    pathway_id))
  ORDER BY pcar.pathway_id
  HEAD REPORT
   lcompphasereltncount = 0, lcompphasereltnsize = 0
  HEAD pcar.pathway_id
   linkcnt = 0, idx = locateval(idx,1,phasecnt,pcar.pathway_id,reply->phaselist[idx].pathway_id)
  DETAIL
   IF (trim(pcar.type_mean)="DOT")
    IF (idx > 0)
     linkcnt += 1
     IF (linkcnt > size(reply->phaselist[idx].treatmentlinkedcomponentlist,5))
      stat = alterlist(reply->phaselist[idx].treatmentlinkedcomponentlist,(size(reply->phaselist[idx]
        .treatmentlinkedcomponentlist,5)+ 10))
     ENDIF
     reply->phaselist[idx].treatmentlinkedcomponentlist[linkcnt].act_pw_comp_id = pcar.act_pw_comp_id
    ENDIF
   ELSE
    lcompphasereltncount += 1
    IF (lcompphasereltncount > lcompphasereltnsize)
     lcompphasereltnsize += 10, stat = alterlist(reply->compphasereltnlist,lcompphasereltnsize)
    ENDIF
    reply->compphasereltnlist[lcompphasereltncount].act_pw_comp_id = pcar.act_pw_comp_id, reply->
    compphasereltnlist[lcompphasereltncount].pathway_id = pcar.pathway_id, reply->compphasereltnlist[
    lcompphasereltncount].type_mean = trim(pcar.type_mean)
   ENDIF
  FOOT  pcar.pathway_id
   stat = alterlist(reply->phaselist[idx].treatmentlinkedcomponentlist,linkcnt)
  FOOT REPORT
   IF (lcompphasereltncount > 0
    AND lcompphasereltncount < lcompphasereltnsize)
    stat = alterlist(reply->compphasereltnlist,lcompphasereltncount)
   ENDIF
  WITH nocounter
 ;end select
 SET nstart = 1
 SET num = 0
 SET evidencecnt = 0
 SELECT INTO "nl:"
  per.pathway_catalog_id, per.type_mean
  FROM (dummyt d1  WITH seq = value(loop_count)),
   pw_evidence_reltn per
  PLAN (d1
   WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
   JOIN (per
   WHERE (((per.pathway_catalog_id=reply->pathway_catalog_id)) OR (expand(num,nstart,(nstart+ (
    batch_size - 1)),per.pathway_catalog_id,reply->phaselist[num].pathway_catalog_id))) )
  ORDER BY per.pathway_catalog_id, per.type_mean, per.evidence_sequence
  HEAD REPORT
   baddevidence = 0, baddreferencetextphase = 0
  DETAIL
   baddevidence = 0, baddreferencetextphase = 0
   IF ((per.pathway_catalog_id=reply->pathway_catalog_id))
    IF (per.type_mean IN ("ZYNX", "URL"))
     IF (foundplanevidence="N")
      baddevidence = 1, foundplanevidence = "Y"
     ENDIF
    ELSEIF (per.type_mean="REFTEXT")
     IF (foundplanreference="N")
      baddevidence = 1, foundplanreference = "Y", baddreferencetextphase = 1,
      reply->ref_text_ind = 1
     ENDIF
    ELSE
     baddevidence = 1
    ENDIF
   ELSE
    baddevidence = 1
    IF (per.type_mean="REFTEXT")
     baddreferencetextphase = 1
    ENDIF
   ENDIF
   IF (baddevidence=1)
    evidencecnt += 1
    IF (evidencecnt > size(reply->planevidencelist,5))
     stat = alterlist(reply->planevidencelist,(evidencecnt+ 5))
    ENDIF
    reply->planevidencelist[evidencecnt].dcp_clin_cat_cd = per.dcp_clin_cat_cd, reply->
    planevidencelist[evidencecnt].dcp_clin_sub_cat_cd = per.dcp_clin_sub_cat_cd, reply->
    planevidencelist[evidencecnt].pathway_comp_id = per.pathway_comp_id,
    reply->planevidencelist[evidencecnt].evidence_type_mean = per.type_mean, reply->planevidencelist[
    evidencecnt].pw_evidence_reltn_id = per.pw_evidence_reltn_id, reply->planevidencelist[evidencecnt
    ].evidence_locator = per.evidence_locator,
    reply->planevidencelist[evidencecnt].pathway_catalog_id = per.pathway_catalog_id, reply->
    planevidencelist[evidencecnt].evidence_sequence = per.evidence_sequence
    IF (baddreferencetextphase=1)
     idx = locateval(idx,1,phasecnt,per.pathway_catalog_id,reply->phaselist[idx].pathway_catalog_id)
     WHILE (idx > 0)
       reply->phaselist[idx].ref_text_ind = 1, idx2 = idx, idx = locateval(idx,(idx2+ 1),phasecnt,per
        .pathway_catalog_id,reply->phaselist[idx].pathway_catalog_id)
     ENDWHILE
    ENDIF
   ENDIF
  FOOT REPORT
   dummy = 0
  WITH nocounter
 ;end select
 IF (evidencecnt > 0)
  SET stat = alterlist(reply->planevidencelist,evidencecnt)
 ENDIF
 SET nstart = 1
 SET num = 0
 SELECT INTO "nl:"
  rtr.parent_entity_name, rtr.parent_entity_id
  FROM (dummyt d1  WITH seq = value(loop_count)),
   ref_text_reltn rtr
  PLAN (d1
   WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
   JOIN (rtr
   WHERE rtr.parent_entity_name="PATHWAY_CATALOG"
    AND (((rtr.parent_entity_id=reply->pathway_catalog_id)) OR (expand(num,nstart,(nstart+ (
    batch_size - 1)),rtr.parent_entity_id,reply->phaselist[num].pathway_catalog_id)))
    AND rtr.active_ind=1)
  ORDER BY rtr.parent_entity_name, rtr.parent_entity_id
  HEAD rtr.parent_entity_id
   IF (rtr.parent_entity_id > 0.0)
    IF ((rtr.parent_entity_id=reply->pathway_catalog_id))
     reply->ref_text_ind = 1
    ENDIF
    idx = locateval(idx,1,phasecnt,rtr.parent_entity_id,reply->phaselist[idx].pathway_catalog_id)
    WHILE (idx > 0)
      reply->phaselist[idx].ref_text_ind = 1, idx2 = idx, idx = locateval(idx,(idx2+ 1),phasecnt,rtr
       .parent_entity_id,reply->phaselist[idx].pathway_catalog_id)
    ENDWHILE
   ENDIF
  WITH nocounter
 ;end select
 IF ((reply->pathway_customized_plan_id > 0))
  SELECT INTO "nl:"
   FROM pathway_customized_plan pcp
   PLAN (pcp
    WHERE (reply->pathway_customized_plan_id=pcp.pathway_customized_plan_id))
   DETAIL
    reply->pathway_customized_plan_name = trim(pcp.plan_name)
   WITH nocounter
  ;end select
 ENDIF
 IF ((reply->pathway_catalog_id > 0))
  SELECT INTO "nl:"
   FROM pathway_catalog pc
   PLAN (pc
    WHERE (reply->pathway_catalog_id=pc.pathway_catalog_id))
   DETAIL
    reply->pathway_reference_plan_name = trim(pc.display_description)
   WITH nocounter
  ;end select
 ENDIF
 SET nstart = 1
 SET num = 0
 SELECT INTO "nl:"
  pwc.pathway_catalog_id
  FROM (dummyt d1  WITH seq = value(loop_count)),
   pathway_catalog pwc
  PLAN (d1
   WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
   JOIN (pwc
   WHERE (((pwc.pathway_catalog_id=reply->pathway_catalog_id)) OR (expand(num,nstart,(nstart+ (
    batch_size - 1)),pwc.pathway_catalog_id,reply->phaselist[num].pathway_catalog_id))) )
  ORDER BY pwc.pathway_catalog_id
  HEAD REPORT
   nautoinitateindex = 0, bautoinitiateset = 0
   IF (pwc.ref_owner_person_id > 0.0)
    reply->ref_owner_person_id = pwc.ref_owner_person_id
   ENDIF
  HEAD pwc.pathway_catalog_id
   nautoinitateindex = 0, bautoinitiateset = 0
   IF ((pwc.pathway_catalog_id=reply->pathway_catalog_id))
    reply->default_visit_type_flag = pwc.default_visit_type_flag, reply->prompt_on_selection_ind =
    pwc.prompt_on_selection_ind, reply->open_by_default_ind = pwc.open_by_default_ind,
    CALL setplanattributesintoreply(pwc.restricted_actions_bitmask,validate(pwc
     .override_mrd_on_plan_ind,0))
   ENDIF
   FOR (idx = 1 TO phasecnt)
     IF ((reply->phaselist[idx].pathway_catalog_id=pwc.pathway_catalog_id))
      IF (bautoinitiateset=0)
       bautoinitiateset = 1, nautoinitateindex = idx
      ELSE
       nautoinitateindex = 0
      ENDIF
      reply->phaselist[idx].alerts_on_plan_ind = pwc.alerts_on_plan_ind, reply->phaselist[idx].
      alerts_on_plan_upd_ind = pwc.alerts_on_plan_upd_ind, reply->phaselist[idx].
      default_action_inpt_future_cd = pwc.default_action_inpt_future_cd,
      reply->phaselist[idx].default_action_inpt_now_cd = pwc.default_action_inpt_now_cd, reply->
      phaselist[idx].default_action_outpt_future_cd = pwc.default_action_outpt_future_cd, reply->
      phaselist[idx].default_action_outpt_now_cd = pwc.default_action_outpt_now_cd,
      reply->phaselist[idx].optional_ind = pwc.optional_ind, reply->phaselist[idx].future_ind = pwc
      .future_ind, reply->phaselist[idx].route_for_review_ind = pwc.route_for_review_ind,
      reply->phaselist[idx].default_start_time_txt = trim(pwc.default_start_time_txt), reply->
      phaselist[idx].primary_ind = pwc.primary_ind, reply->phaselist[idx].
      reschedule_reason_accept_flag = pwc.reschedule_reason_accept_flag,
      reply->phaselist[idx].open_by_default_ind = pwc.open_by_default_ind,
      CALL setallowactivateallindicatorinreply(idx,evaluate(pwc.disable_activate_all_ind,1,0,0,1))
     ENDIF
   ENDFOR
   IF (nautoinitateindex > 0)
    reply->phaselist[nautoinitateindex].auto_initiate_ind = pwc.auto_initiate_ind
   ENDIF
  WITH nocounter
 ;end select
 SUBROUTINE (setallowactivateallindicatorinreply(lreplyphaseindex=i4,iallowactivateallindicator=i2) =
  null WITH protect)
   IF (validate(reply->phaselist[lreplyphaseindex].allow_activate_all_ind)=1)
    SET reply->phaselist[lreplyphaseindex].allow_activate_all_ind = iallowactivateallindicator
   ENDIF
 END ;Subroutine
 SUBROUTINE (setphaseattributesintoreply(lreplyphaseindex=i4,dcopysourcepathwayid=f8,
  lreviewrequiresigncount=i4,ilinkedphaseind=i2) =null WITH protect)
   IF (validate(reply->phaselist[lreplyphaseindex].copy_source_pathway_id)=1)
    SET reply->phaselist[lreplyphaseindex].copy_source_pathway_id = dcopysourcepathwayid
   ENDIF
   IF (validate(reply->phaselist[lreplyphaseindex].review_required_sig_count)=1)
    SET reply->phaselist[lreplyphaseindex].review_required_sig_count = lreviewrequiresigncount
   ENDIF
   IF (validate(reply->phaselist[lreplyphaseindex].linked_phase_ind)=1)
    SET reply->phaselist[lreplyphaseindex].linked_phase_ind = ilinkedphaseind
   ENDIF
 END ;Subroutine
 SUBROUTINE (setplanattributesintoreply(lrestrictedactionsbitmask=i4,ioverridemrdonplanindicator=i2
  ) =null WITH protect)
  IF (validate(reply->restricted_actions_bitmask)=1)
   SET reply->restricted_actions_bitmask = lrestrictedactionsbitmask
  ENDIF
  IF (validate(reply->override_mrd_on_plan_ind)=1)
   SET reply->override_mrd_on_plan_ind = ioverridemrdonplanindicator
  ENDIF
 END ;Subroutine
 IF (phasecnt > 0)
  SET stat = alterlist(reply->phaselist,phasecnt)
 ENDIF
#exit_script
 IF (cfailed="T")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF (debug=1)
  CALL echorecord(reply)
 ENDIF
 SET last_mod = "017"
 SET mod_date = "Feb 12, 2020"
END GO
