CREATE PROGRAM dcp_get_act_phase_list:dba
 SET modify = predeclare
 RECORD temp(
   1 planlist[*]
     2 pw_group_nbr = f8
     2 pw_group_desc = vc
     2 type_mean = c12
     2 start_dt_tm = dq8
     2 activated_ind = i2
     2 start_tz = i4
     2 phaselist[*]
       3 pathway_id = f8
       3 description = vc
       3 pw_status_cd = f8
       3 calc_status_cd = f8
       3 type_mean = c12
       3 started_ind = i2
       3 start_dt_tm = dq8
       3 calc_end_dt_tm = dq8
       3 order_dt_tm = dq8
       3 pathway_s_id = f8
       3 sequence = i4
       3 sub_sequence = i4
       3 display_method_cd = f8
       3 parent_phase_desc = vc
       3 parent_phase_id = f8
       3 start_tz = i4
       3 calc_end_tz = i4
       3 order_tz = i4
       3 pathway_type_cd = f8
       3 treatment_schedule_desc = vc
 )
 RECORD subphases(
   1 list[*]
     2 pw_group_nbr = f8
     2 pathway_id = f8
     2 sequence = i4
 )
 DECLARE stat = i2 WITH noconstant(0)
 DECLARE idx = i4 WITH noconstant(0)
 DECLARE subidx = i4 WITH noconstant(0)
 DECLARE i = i4 WITH noconstant(0)
 DECLARE j = i4 WITH noconstant(0)
 DECLARE subphasecnt = i4 WITH noconstant(0)
 DECLARE phasecnt = i4 WITH noconstant(0)
 DECLARE plancnt = i4 WITH noconstant(0)
 DECLARE pos = i4 WITH noconstant(0)
 DECLARE seq = i4 WITH noconstant(0)
 DECLARE num = i4 WITH noconstant(0)
 DECLARE subhigh = i4 WITH noconstant(0)
 DECLARE planhigh = i4 WITH noconstant(0)
 DECLARE phasehigh = i4 WITH noconstant(0)
 DECLARE found = i4 WITH noconstant(0)
 DECLARE high = i4 WITH noconstant(0)
 DECLARE where_clause = vc WITH noconstant(fillstring(200," "))
 DECLARE protocol_phase_name = vc WITH noconstant(fillstring(100," "))
 SET reply->status_data.status = "F"
 IF ((request->encntrid > 0))
  SET where_clause = "pw.encntr_id = request->encntrId AND pw.pw_group_nbr > 0"
 ELSE
  SET where_clause = "pw.person_id = request->personId AND pw.pw_group_nbr > 0"
 ENDIF
 SELECT INTO "nl:"
  pw.pw_group_nbr, pw.pathway_id, pw.type_mean,
  pw.pathway_group_id, pwr.pathway_s_id, pwr.pathway_t_id,
  is_dot_phase = evaluate(pw.type_mean,"DOT",1,0)
  FROM pathway pw,
   pathway_reltn pwr
  PLAN (pw
   WHERE parser(trim(where_clause)))
   JOIN (pwr
   WHERE pwr.pathway_t_id=outerjoin(pw.pathway_id))
  ORDER BY pw.pw_group_nbr, pw.pathway_group_id, is_dot_phase,
   pw.pathway_id
  HEAD REPORT
   plancnt = 0
  HEAD pw.pw_group_nbr
   phasecnt = 0, plancnt = (plancnt+ 1)
   IF (plancnt > size(temp->planlist,5))
    stat = alterlist(temp->planlist,(plancnt+ 10))
   ENDIF
   temp->planlist[plancnt].pw_group_nbr = pw.pw_group_nbr, temp->planlist[plancnt].pw_group_desc =
   trim(pw.pw_group_desc)
  HEAD pw.pathway_group_id
   protocol_phase_name = fillstring(100," "), protocol_phase_name = trim(pw.description)
  HEAD is_dot_phase
   dummy = 0
  HEAD pw.pathway_id
   IF (pw.type_mean != "TAPERPLAN")
    IF (pw.type_mean="PHASE")
     temp->planlist[plancnt].type_mean = "PATHWAY"
    ELSEIF (pw.type_mean="CAREPLAN")
     temp->planlist[plancnt].type_mean = "CAREPLAN"
    ENDIF
    phasecnt = (phasecnt+ 1)
    IF (phasecnt > size(temp->planlist[plancnt].phaselist,5))
     stat = alterlist(temp->planlist[plancnt].phaselist,(phasecnt+ 10))
    ENDIF
    temp->planlist[plancnt].phaselist[phasecnt].pathway_id = pw.pathway_id, temp->planlist[plancnt].
    phaselist[phasecnt].description = trim(pw.description), temp->planlist[plancnt].phaselist[
    phasecnt].pw_status_cd = pw.pw_status_cd,
    temp->planlist[plancnt].phaselist[phasecnt].type_mean = pw.type_mean, temp->planlist[plancnt].
    phaselist[phasecnt].started_ind = pw.started_ind, temp->planlist[plancnt].phaselist[phasecnt].
    start_dt_tm = cnvtdatetime(pw.start_dt_tm),
    temp->planlist[plancnt].phaselist[phasecnt].calc_end_dt_tm = cnvtdatetime(pw.calc_end_dt_tm),
    temp->planlist[plancnt].phaselist[phasecnt].order_dt_tm = cnvtdatetime(pw.order_dt_tm), temp->
    planlist[plancnt].phaselist[phasecnt].start_tz = pw.start_tz,
    temp->planlist[plancnt].phaselist[phasecnt].calc_end_tz = pw.calc_end_tz, temp->planlist[plancnt]
    .phaselist[phasecnt].order_tz = pw.order_tz, temp->planlist[plancnt].phaselist[phasecnt].
    pathway_type_cd = pw.pathway_type_cd
    IF (pwr.type_mean="SUCCEED")
     temp->planlist[plancnt].phaselist[phasecnt].pathway_s_id = pwr.pathway_s_id
    ENDIF
    temp->planlist[plancnt].phaselist[phasecnt].display_method_cd = pw.display_method_cd, temp->
    planlist[plancnt].phaselist[phasecnt].parent_phase_desc = trim(pw.parent_phase_desc)
    IF (pwr.type_mean="SUBPHASE")
     temp->planlist[plancnt].phaselist[phasecnt].parent_phase_id = pwr.pathway_s_id
    ENDIF
    IF (pw.type_mean="DOT")
     IF (is_dot_phase=1)
      temp->planlist[plancnt].phaselist[phasecnt].treatment_schedule_desc = trim(protocol_phase_name)
     ENDIF
    ENDIF
    IF (pw.started_ind=1)
     temp->planlist[plancnt].activated_ind = 1
     IF (((cnvtdatetime(temp->planlist[plancnt].start_dt_tm) > cnvtdatetime(temp->planlist[plancnt].
      phaselist[phasecnt].start_dt_tm)) OR (cnvtdatetime(temp->planlist[plancnt].start_dt_tm)=null))
     )
      temp->planlist[plancnt].start_dt_tm = cnvtdatetime(temp->planlist[plancnt].phaselist[phasecnt].
       start_dt_tm), temp->planlist[plancnt].start_tz = temp->planlist[plancnt].phaselist[phasecnt].
      start_tz
     ENDIF
    ENDIF
    IF (pw.type_mean="SUBPHASE")
     subphasecnt = (subphasecnt+ 1)
     IF (subphasecnt > size(subphases->list,5))
      stat = alterlist(subphases->list,(subphasecnt+ 10))
     ENDIF
     subphases->list[subphasecnt].pathway_id = pw.pathway_id, subphases->list[subphasecnt].
     pw_group_nbr = pw.pw_group_nbr
    ENDIF
   ENDIF
  FOOT  pw.pathway_id
   dummy = 0
  FOOT  is_dot_phase
   dummy = 0
  FOOT  pw.pathway_group_id
   dummy = 0
  FOOT  pw.pw_group_nbr
   stat = alterlist(temp->planlist[plancnt].phaselist,phasecnt)
  FOOT REPORT
   stat = alterlist(temp->planlist,plancnt), stat = alterlist(subphases->list,subphasecnt)
  WITH nocounter
 ;end select
 SET subhigh = value(size(subphases->list,5))
 IF (subhigh > 0)
  SELECT INTO "nl:"
   FROM act_pw_comp apc
   PLAN (apc
    WHERE expand(num,1,subhigh,apc.parent_entity_id,subphases->list[num].pathway_id)
     AND apc.parent_entity_name="PATHWAY")
   HEAD REPORT
    idx = 0
   DETAIL
    idx = locateval(idx,1,subhigh,apc.parent_entity_id,subphases->list[idx].pathway_id), subphases->
    list[idx].sequence = apc.sequence
   FOOT REPORT
    idx = 0
   WITH nocounter
  ;end select
 ENDIF
 FOR (i = 1 TO value(size(temp->planlist,5)))
   IF ((temp->planlist[i].type_mean="PATHWAY"))
    SET seq = 1
    SET found = 0
    SET idx = 0
    SET high = value(size(temp->planlist[i].phaselist,5))
    WHILE (found=0
     AND idx < high)
     SET idx = (idx+ 1)
     IF ((temp->planlist[i].phaselist[idx].pathway_s_id=0.0)
      AND (temp->planlist[i].phaselist[idx].type_mean="PHASE"))
      SET found = 1
      SET pos = idx
     ENDIF
    ENDWHILE
    SET temp->planlist[i].phaselist[idx].sequence = seq
    WHILE (pos > 0)
     SET pos = locateval(idx,1,high,temp->planlist[i].phaselist[pos].pathway_id,temp->planlist[i].
      phaselist[idx].pathway_s_id)
     IF (pos > 0)
      SET seq = (seq+ 1)
      SET temp->planlist[i].phaselist[pos].sequence = seq
     ENDIF
    ENDWHILE
    FOR (j = 1 TO high)
      IF ((temp->planlist[i].phaselist[j].type_mean="SUBPHASE"))
       SET idx = locateval(idx,1,high,temp->planlist[i].phaselist[j].parent_phase_id,temp->planlist[i
        ].phaselist[idx].pathway_id)
       SET temp->planlist[i].phaselist[j].sequence = temp->planlist[i].phaselist[idx].sequence
      ENDIF
    ENDFOR
   ENDIF
 ENDFOR
 SET planhigh = value(size(temp->planlist,5))
 FOR (i = 1 TO value(size(subphases->list,5)))
   SET idx = locateval(idx,1,planhigh,subphases->list[i].pw_group_nbr,temp->planlist[idx].
    pw_group_nbr)
   SET phasehigh = value(size(temp->planlist[idx].phaselist,5))
   SET subidx = locateval(subidx,1,phasehigh,subphases->list[i].pathway_id,temp->planlist[idx].
    phaselist[subidx].pathway_id)
   SET temp->planlist[idx].phaselist[subidx].sub_sequence = subphases->list[i].sequence
 ENDFOR
 IF (value(size(temp->planlist,5)) > 0)
  SELECT INTO "nl:"
   pw_group_nbr = temp->planlist[d1.seq].pw_group_nbr, sequence = temp->planlist[d1.seq].phaselist[d2
   .seq].sequence, sub_sequence = temp->planlist[d1.seq].phaselist[d2.seq].sub_sequence
   FROM (dummyt d1  WITH seq = value(size(temp->planlist,5))),
    (dummyt d2  WITH seq = 5)
   PLAN (d1
    WHERE (temp->planlist[d1.seq].activated_ind=1)
     AND maxrec(d2,size(temp->planlist[d1.seq].phaselist,5)) > 0)
    JOIN (d2
    WHERE (temp->planlist[d1.seq].phaselist[d2.seq].started_ind=1))
   ORDER BY pw_group_nbr, sequence, sub_sequence
   HEAD REPORT
    phscnt = 0
   HEAD pw_group_nbr
    phaseseq = 0
   HEAD sequence
    dummy = 0
   HEAD sub_sequence
    dummy = 0
   DETAIL
    phscnt = (phscnt+ 1)
    IF (phscnt > size(reply->phaselist,5))
     stat = alterlist(reply->phaselist,(phscnt+ 10))
    ENDIF
    reply->phaselist[phscnt].pw_group_nbr = temp->planlist[d1.seq].pw_group_nbr, reply->phaselist[
    phscnt].pw_type_mean = temp->planlist[d1.seq].type_mean, reply->phaselist[phscnt].pw_group_desc
     = temp->planlist[d1.seq].pw_group_desc,
    reply->phaselist[phscnt].pw_start_dt_tm = cnvtdatetime(temp->planlist[d1.seq].start_dt_tm), reply
    ->phaselist[phscnt].pathway_id = temp->planlist[d1.seq].phaselist[d2.seq].pathway_id, reply->
    phaselist[phscnt].pw_status_cd = temp->planlist[d1.seq].phaselist[d2.seq].pw_status_cd,
    reply->phaselist[phscnt].description = temp->planlist[d1.seq].phaselist[d2.seq].description,
    reply->phaselist[phscnt].type_mean = temp->planlist[d1.seq].phaselist[d2.seq].type_mean, reply->
    phaselist[phscnt].start_dt_tm = temp->planlist[d1.seq].phaselist[d2.seq].start_dt_tm,
    reply->phaselist[phscnt].calc_end_dt_tm = temp->planlist[d1.seq].phaselist[d2.seq].calc_end_dt_tm,
    reply->phaselist[phscnt].order_dt_tm = temp->planlist[d1.seq].phaselist[d2.seq].order_dt_tm,
    phaseseq = (phaseseq+ 1),
    reply->phaselist[phscnt].sequence = phaseseq, reply->phaselist[phscnt].display_method_cd = temp->
    planlist[d1.seq].phaselist[d2.seq].display_method_cd, reply->phaselist[phscnt].parent_phase_desc
     = temp->planlist[d1.seq].phaselist[d2.seq].parent_phase_desc,
    reply->phaselist[phscnt].pw_start_tz = temp->planlist[d1.seq].start_tz, reply->phaselist[phscnt].
    start_tz = temp->planlist[d1.seq].phaselist[d2.seq].start_tz, reply->phaselist[phscnt].
    calc_end_tz = temp->planlist[d1.seq].phaselist[d2.seq].calc_end_tz,
    reply->phaselist[phscnt].order_tz = temp->planlist[d1.seq].phaselist[d2.seq].order_tz, reply->
    phaselist[phscnt].pathway_type_cd = temp->planlist[d1.seq].phaselist[d2.seq].pathway_type_cd,
    reply->phaselist[phscnt].treatment_schedule_desc = temp->planlist[d1.seq].phaselist[d2.seq].
    treatment_schedule_desc
   FOOT  sub_sequence
    dummy = 0
   FOOT  sequence
    dummy = 0
   FOOT  pw_group_nbr
    dummy = 0
   FOOT REPORT
    IF (phscnt > 0)
     stat = alterlist(reply->phaselist,phscnt)
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   pathwayid = reply->phaselist[d.seq].pathway_id
   FROM (dummyt d  WITH seq = value(size(reply->phaselist,5))),
    pathway_action pwa,
    prsnl p
   PLAN (d)
    JOIN (pwa
    WHERE (reply->phaselist[d.seq].pathway_id=pwa.pathway_id))
    JOIN (p
    WHERE pwa.action_prsnl_id=p.person_id)
   ORDER BY pathwayid, pwa.pw_action_seq
   HEAD REPORT
    idx = 0
   HEAD pathwayid
    actcnt = 0
   DETAIL
    actcnt = (actcnt+ 1)
    IF (actcnt > size(reply->phaselist[d.seq].actionlist,5))
     stat = alterlist(reply->phaselist[d.seq].actionlist,(actcnt+ 10))
    ENDIF
    reply->phaselist[d.seq].actionlist[actcnt].action_type_cd = pwa.action_type_cd, reply->phaselist[
    d.seq].actionlist[actcnt].action_dt_tm = cnvtdatetime(pwa.action_dt_tm), reply->phaselist[d.seq].
    actionlist[actcnt].action_prsnl_id = pwa.action_prsnl_id,
    reply->phaselist[d.seq].actionlist[actcnt].action_prsnl_disp = trim(p.name_full_formatted), reply
    ->phaselist[d.seq].actionlist[actcnt].pw_action_seq = pwa.pw_action_seq, reply->phaselist[d.seq].
    actionlist[actcnt].pw_status_cd = pwa.pw_status_cd,
    reply->phaselist[d.seq].actionlist[actcnt].action_tz = pwa.action_tz
   FOOT  pathwayid
    stat = alterlist(reply->phaselist[d.seq].actionlist,actcnt)
   FOOT REPORT
    dummy = 0
   WITH nocounter
  ;end select
 ENDIF
 FREE RECORD temp
 SET reply->status_data.status = "S"
END GO
