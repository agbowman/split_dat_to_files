CREATE PROGRAM bhs_rpt_clin_nutr_consult:dba
 PROMPT
  "Defaut Prompt for any error messages:" = "MINE",
  "Beginning Date:" = "SYSDATE",
  "End Date:" = "SYSDATE",
  "Select Facility" = 0,
  "Select Nursing Unit or Any(*) for All :" = 0,
  "Type in email address or leave default for report preview:" = "Report_Preview"
  WITH outdev, s_beg_dt_tm, s_end_dt_tm,
  f_fac_cd, f_unit_cd, s_email
 FREE RECORD m_rec
 RECORD m_rec(
   1 ord[*]
     2 f_encntr_id = f8
     2 f_person_id = f8
     2 s_pat_name = vc
     2 s_fin = vc
     2 s_ord_status = vc
     2 s_act_prsnl = vc
     2 f_order_id = f8
     2 f_cat_cd = f8
     2 s_cat_disp = vc
     2 l_ord_tot_ordered = i4
     2 l_ord_tot_stat_ordered = i4
     2 l_ord_tot_stat_compl = i4
     2 l_ord_tot_stat_dc_man = i4
     2 l_ord_tot_stat_dc_sys = i4
     2 l_tsk_tot_sys_gen = i4
     2 l_tsk_tot_vol_due = i4
     2 l_tsk_tot_vol_late = i4
     2 l_tsk_tot_vol_miss = i4
     2 s_fup_sched = vc
     2 fup[*]
       3 f_clin_event_id = f8
       3 d_perf_dt_tm = dq8
       3 d_create_dt_tm = dq8
       3 d_due_dt_tm = dq8
       3 n_stat_sys_gen = i4
       3 n_stat_vol_due = i4
       3 n_stat_vol_late = i4
       3 n_stat_vol_miss = i4
   1 rep[*]
     2 f_cat_cd = f8
     2 s_cat_disp = vc
     2 l_ord_tot_ordered = i4
     2 l_ord_tot_stat_ordered = i4
     2 l_ord_tot_stat_compl = i4
     2 l_ord_tot_stat_dc_man = i4
     2 l_ord_tot_stat_dc_sys = i4
     2 l_tsk_tot_sys_gen = i4
     2 l_tsk_tot_vol_due = i4
     2 l_tsk_tot_vol_late = i4
     2 l_tsk_tot_vol_miss = i4
 ) WITH protect
 DECLARE ms_beg_dt_tm = vc WITH protect, constant(trim( $S_BEG_DT_TM,3))
 DECLARE ms_end_dt_tm = vc WITH protect, constant(trim( $S_END_DT_TM,3))
 DECLARE ms_email = vc WITH protect, constant(trim( $S_EMAIL,3))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_nutr_svcs_ty_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6000,
   "NUTRITIONSERVICES"))
 DECLARE mf_high_risk_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "HIGHRISKNUTRITIONASSESSMENT"))
 DECLARE mf_nut_svc_cons_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "NUTRITIONSERVICECONSULTFOLLOWUP"))
 DECLARE mf_tube_feed_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "NUTRITIONASSESSMENTTUBEFEEDING"))
 DECLARE mf_oral_supp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "NUTRITIONASSESSMENTORALSUPPLEMENTS"))
 DECLARE mf_cons_nut_svc_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "CONSULTNUTRITIONSERVICES"))
 DECLARE mf_cons_per_pol_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "NUTRITIONASSESSMENTPERPOLICY"))
 DECLARE mf_home_tpn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "HOMEPNNUTRITIONASSESSMENT"))
 DECLARE mf_ordered_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED"))
 DECLARE mf_completed_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"COMPLETED"))
 DECLARE mf_dc_manual_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4038,"USERMANUALDC"
   ))
 DECLARE mf_dc_sys_stop_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4038,"SYSTEMAUTO"
   ))
 DECLARE mf_dc_sys_disch_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4038,
   "SYSTEMDISCH"))
 DECLARE mf_dc_sys_trans_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4038,
   "SYSTEMTRANS"))
 DECLARE mf_dc_sys_clean_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4038,
   "UPDBYCLEANUP"))
 DECLARE mf_dc_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"DISCONTINUED"))
 DECLARE mf_daily_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",100622,"DAILY"))
 DECLARE mf_mon_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",100622,"MONDAY"))
 DECLARE mf_tue_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",100622,"TUESDAY"))
 DECLARE mf_wed_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",100622,"WEDNESDAY"))
 DECLARE mf_thu_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",100622,"THURSDAY"))
 DECLARE mf_fri_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",100622,"FRIDAY"))
 DECLARE mf_mwf_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",100622,
   "MONDAYWEDNESDAYFRIDAY"))
 DECLARE mf_tf_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",100622,"TUESDAYFRIDAY"))
 CALL echo(build2("mf_NUTR_SVCS_TY_CD: ",mf_nutr_svcs_ty_cd))
 CALL echo(build2("mf_HIGH_RISK_CD: ",mf_high_risk_cd))
 DECLARE ml_exp = i4 WITH protect, noconstant(0)
 DECLARE ml_loc = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ms_log = vc WITH protect, noconstant(" ")
 DECLARE ms_tmp_sched = vc WITH protect, noconstant(" ")
 DECLARE ms_facility = vc WITH protect, noconstant(uar_get_code_display( $F_FAC_CD),3)
 DECLARE ms_nurse_unit = vc WITH protect, noconstant(" ")
 DECLARE ms_run_by = vc WITH protect, noconstant(" ")
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 DECLARE ml_loop2 = i4 WITH protect, noconstant(0)
 DECLARE ml_look = i4 WITH protect, noconstant(0)
 IF (cnvtdatetime(ms_beg_dt_tm) < cnvtlookbehind("31,D",cnvtdatetime(ms_end_dt_tm)))
  SET ms_log = "Begin date can't be > 31 days back"
  GO TO exit_script
 ENDIF
 IF (( $F_UNIT_CD=0.0))
  SET ms_nurse_unit = "Any"
 ELSE
  SET ms_nurse_unit = uar_get_code_display( $F_UNIT_CD)
 ENDIF
 SELECT INTO "nl:"
  FROM prsnl p
  WHERE (p.person_id=reqinfo->updt_id)
  DETAIL
   ms_run_by = trim(p.name_full_formatted)
  WITH nocounter
 ;end select
 SELECT
  IF (( $F_UNIT_CD=0.0))
   PLAN (o
    WHERE o.catalog_type_cd=mf_nutr_svcs_ty_cd
     AND o.catalog_cd IN (mf_high_risk_cd, mf_nut_svc_cons_cd, mf_tube_feed_cd, mf_oral_supp_cd,
    mf_cons_nut_svc_cd,
    mf_cons_per_pol_cd, mf_home_tpn_cd)
     AND o.orig_order_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm))
    JOIN (elh
    WHERE elh.encntr_id=o.encntr_id
     AND o.orig_order_dt_tm BETWEEN elh.beg_effective_dt_tm AND elh.end_effective_dt_tm)
    JOIN (ea
    WHERE ea.encntr_id=o.encntr_id
     AND ea.active_ind=1
     AND ea.end_effective_dt_tm > sysdate
     AND ea.encntr_alias_type_cd=mf_fin_cd)
    JOIN (p
    WHERE p.person_id=o.person_id)
    JOIN (oa
    WHERE oa.order_id=o.order_id
     AND oa.action_type_cd=2534)
    JOIN (pr
    WHERE pr.person_id=oa.action_personnel_id)
    JOIN (d)
    JOIN (od
    WHERE od.order_id=o.order_id
     AND od.oe_field_value IN (mf_daily_cd, mf_mon_cd, mf_tue_cd, mf_wed_cd, mf_thu_cd,
    mf_fri_cd, mf_mwf_cd, mf_tf_cd))
  ELSE
  ENDIF
  INTO "nl:"
  p.name_last, o.order_id, cat_ty = uar_get_code_display(o.catalog_type_cd),
  o.catalog_type_cd, cat_cd = uar_get_code_display(o.catalog_cd), o.catalog_cd,
  o.hna_order_mnemonic, stat = uar_get_code_display(o.order_status_cd), o.order_status_cd,
  o.order_detail_display_line
  FROM orders o,
   encntr_loc_hist elh,
   encntr_alias ea,
   person p,
   order_action oa,
   prsnl pr,
   dummyt d,
   order_detail od
  PLAN (o
   WHERE o.catalog_type_cd=mf_nutr_svcs_ty_cd
    AND o.catalog_cd IN (mf_high_risk_cd, mf_nut_svc_cons_cd, mf_tube_feed_cd, mf_oral_supp_cd,
   mf_cons_nut_svc_cd,
   mf_cons_per_pol_cd, mf_home_tpn_cd)
    AND o.orig_order_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm))
   JOIN (elh
   WHERE elh.encntr_id=o.encntr_id
    AND o.orig_order_dt_tm BETWEEN elh.beg_effective_dt_tm AND elh.end_effective_dt_tm
    AND (elh.loc_nurse_unit_cd= $F_UNIT_CD))
   JOIN (ea
   WHERE ea.encntr_id=o.encntr_id
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > sysdate
    AND ea.encntr_alias_type_cd=mf_fin_cd)
   JOIN (p
   WHERE p.person_id=o.person_id)
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_type_cd=2534)
   JOIN (pr
   WHERE pr.person_id=oa.action_personnel_id)
   JOIN (d)
   JOIN (od
   WHERE od.order_id=o.order_id
    AND od.oe_field_value IN (mf_daily_cd, mf_mon_cd, mf_tue_cd, mf_wed_cd, mf_thu_cd,
   mf_fri_cd, mf_mwf_cd, mf_tf_cd))
  ORDER BY o.person_id, o.catalog_cd, o.order_id
  HEAD REPORT
   pl_cnt = 0, pl_other_cnt = 0
  HEAD o.order_id
   CALL echo(build2("pat: ",trim(p.name_full_formatted,3)," ord: ",trim(uar_get_code_display(o
      .catalog_cd),3)," orderid: ",
    trim(cnvtstring(o.order_id),3)," ord_by_id: ",trim(cnvtstring(oa.action_personnel_id),3),
    " status: ",trim(uar_get_code_display(o.order_status_cd),3))), pl_cnt += 1,
   CALL alterlist(m_rec->ord,pl_cnt),
   m_rec->ord[pl_cnt].f_encntr_id = o.encntr_id, m_rec->ord[pl_cnt].f_person_id = o.person_id, m_rec
   ->ord[pl_cnt].s_pat_name = trim(p.name_full_formatted),
   m_rec->ord[pl_cnt].s_fin = trim(ea.alias,3), m_rec->ord[pl_cnt].s_ord_status = trim(
    uar_get_code_display(o.order_status_cd),3), m_rec->ord[pl_cnt].s_act_prsnl = trim(pr.name_last,3),
   m_rec->ord[pl_cnt].f_order_id = o.order_id, m_rec->ord[pl_cnt].f_cat_cd = o.catalog_cd, m_rec->
   ord[pl_cnt].s_cat_disp = trim(uar_get_code_display(o.catalog_cd),3),
   ml_idx = pl_cnt, m_rec->ord[ml_idx].l_ord_tot_ordered += 1
   CASE (o.order_status_cd)
    OF mf_ordered_cd:
     m_rec->ord[ml_idx].l_ord_tot_stat_ordered += 1
    OF mf_completed_cd:
     m_rec->ord[ml_idx].l_ord_tot_stat_compl += 1
    OF mf_dc_cd:
     CALL echo(build2("discontinue type: ",trim(uar_get_code_display(o.discontinue_type_cd),3),trim(
       cnvtstring(o.discontinue_type_cd),3)))
     IF (o.discontinue_type_cd=mf_dc_manual_cd)
      m_rec->ord[ml_idx].l_ord_tot_stat_dc_man += 1,
      CALL echo(build2("dc ml_idx: ",trim(cnvtstring(ml_idx),3)," dc_man_cnt: ",trim(cnvtstring(m_rec
         ->ord[ml_idx].l_ord_tot_stat_dc_man),3)))
     ELSE
      m_rec->ord[ml_idx].l_ord_tot_stat_dc_sys += 1,
      CALL echo(build2("sys ml_idx: ",trim(cnvtstring(ml_idx),3)," dc_man_cnt: ",trim(cnvtstring(
         m_rec->ord[ml_idx].l_ord_tot_stat_dc_man),3)))
     ENDIF
    ELSE
     pl_other_cnt += 1
   ENDCASE
  HEAD od.oe_field_display_value
   CALL echo(build2("detail pat: ",trim(p.name_full_formatted,3)," ord: ",trim(uar_get_code_display(o
      .catalog_cd),3)," orderid: ",
    trim(cnvtstring(o.order_id),3))),
   CALL echo("get followup schedule")
   CASE (od.oe_field_value)
    OF mf_daily_cd:
     m_rec->ord[ml_idx].s_fup_sched = concat(m_rec->ord[ml_idx].s_fup_sched,"12345")
    OF mf_mon_cd:
     m_rec->ord[ml_idx].s_fup_sched = concat(m_rec->ord[ml_idx].s_fup_sched,"1")
    OF mf_tue_cd:
     m_rec->ord[ml_idx].s_fup_sched = concat(m_rec->ord[ml_idx].s_fup_sched,"2")
    OF mf_wed_cd:
     m_rec->ord[ml_idx].s_fup_sched = concat(m_rec->ord[ml_idx].s_fup_sched,"3")
    OF mf_thu_cd:
     m_rec->ord[ml_idx].s_fup_sched = concat(m_rec->ord[ml_idx].s_fup_sched,"4")
    OF mf_fri_cd:
     m_rec->ord[ml_idx].s_fup_sched = concat(m_rec->ord[ml_idx].s_fup_sched,"5")
    OF mf_mwf_cd:
     m_rec->ord[ml_idx].s_fup_sched = concat(m_rec->ord[ml_idx].s_fup_sched,"135")
    OF mf_tf_cd:
     m_rec->ord[ml_idx].s_fup_sched = concat(m_rec->ord[ml_idx].s_fup_sched,"24")
    ELSE
     m_rec->ord[ml_idx].s_fup_sched = concat(m_rec->ord[ml_idx].s_fup_sched,"12345")
   ENDCASE
   IF (o.order_id=3974518679)
    CALL echo(build2("followup 3974518679: ",od.oe_field_value)),
    CALL echo(build2("followup: ",m_rec->ord[ml_idx].s_fup_sched))
   ENDIF
  FOOT REPORT
   CALL echo(build2("other count: ",pl_other_cnt))
  WITH nocounter, outerjoin = d
 ;end select
 SELECT INTO "nl:"
  FROM orders o,
   order_action oa,
   clinical_event ce,
   task_activity ta
  PLAN (o
   WHERE expand(ml_exp,1,size(m_rec->ord,5),o.order_id,m_rec->ord[ml_exp].f_order_id))
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_type_cd=2534)
   JOIN (ta
   WHERE ta.order_id=o.order_id
    AND ta.order_id > 0.0)
   JOIN (ce
   WHERE (ce.event_id= Outerjoin(ta.event_id)) )
  ORDER BY o.order_id, ce.event_end_dt_tm
  HEAD REPORT
   pl_cnt = 0, pl_due_day = 0, pl_ord_day = 0,
   pl_perf_day = 0, pl_cur_day = 0,
   MACRO (mcr_chk_sched)
    CALL echo(m_rec->ord[ml_idx].s_pat_name),
    CALL echo(m_rec->ord[ml_idx].s_cat_disp),
    CALL echo(build2("encntr: ",o.encntr_id)),
    CALL echo(build2("event_id: ",ce.event_id)),
    CALL echo(build2("performed: ",format(ce.performed_dt_tm,"mm/dd/yy hh:mm;;d"))),
    CALL echo(build2("order: ",o.order_id," ml_idx: ",ml_idx," pl_cnt: ",
     pl_cnt)),
    CALL echo(build2("order status: ",trim(uar_get_code_display(o.order_status_cd),3))), ms_tmp_sched
     = m_rec->ord[ml_idx].s_fup_sched,
    CALL echo(build2("ms_tmp_sched: ",ms_tmp_sched)),
    pl_ord_day = weekday(ta.task_create_dt_tm),
    CALL echo(build2("taskday: ",trim(cnvtstring(pl_ord_day))," ",format(ta.task_create_dt_tm,
      "mm/dd;;d"))),
    CALL echo(build2("curday: ",trim(cnvtstring(weekday(sysdate)))," ",format(sysdate,"mm/dd;;d"))),
    CALL echo(build2("action prsnl_id: ",oa.action_personnel_id))
    IF (oa.action_personnel_id <= 1
     AND o.order_status_cd=mf_ordered_cd)
     CALL echo(build2("sys gen - ord stat: ",trim(uar_get_code_display(o.order_status_cd),3))), m_rec
     ->ord[ml_idx].l_tsk_tot_sys_gen += 1
    ENDIF
    IF (ce.performed_dt_tm=null
     AND o.order_status_cd=mf_ordered_cd)
     CALL echo("not performed"), pl_due_day = 0
     FOR (ml_loop = 1 TO 5)
       IF (pl_due_day=0)
        IF (findstring(trim(cnvtstring(ml_loop)),ms_tmp_sched))
         CALL echo(build2("task day: ",pl_ord_day," ml_loop: ",ml_loop," sch: ",
          ms_tmp_sched))
         IF (((ml_loop > pl_ord_day) OR (pl_ord_day=5)) )
          pl_due_day = ml_loop,
          CALL echo(build2("pl_due_day: ",pl_due_day))
         ENDIF
        ENDIF
       ENDIF
     ENDFOR
     m_rec->ord[ml_idx].fup[pl_cnt].d_due_dt_tm = cnvtlookahead(concat(trim(cnvtstring((pl_due_day -
         pl_ord_day))),",D"),ta.task_create_dt_tm),
     CALL echo(build2("ord ",format(o.orig_order_dt_tm,"mm/dd;;d")," "," tsk ",format(ta
       .task_create_dt_tm,"mm/dd;;d"),
      " "," due ",format(cnvtlookahead(concat(trim(cnvtstring((pl_due_day - pl_ord_day))),",D"),ta
        .task_create_dt_tm),"mm/dd;;d")," tod ",format(sysdate,"mm/dd;;d")))
     IF (cnvtdate(sysdate) > cnvtdate(cnvtlookahead(concat(trim(cnvtstring((pl_due_day - pl_ord_day))
         ),",D"),ta.task_create_dt_tm)))
      CALL echo("missed"), m_rec->ord[ml_idx].l_tsk_tot_vol_miss += 1, m_rec->ord[ml_idx].fup[pl_cnt]
      .n_stat_vol_miss = 1
     ENDIF
    ELSE
     CALL echo("performed"), pl_perf_day = weekday(ce.performed_dt_tm),
     CALL echo(build2("prfday: ",trim(cnvtstring(pl_perf_day))," ",format(ce.performed_dt_tm,
       "mm/dd;;d"))),
     pl_cur_day = weekday(sysdate), pl_due_day = 0, pl_ord_day = weekday(ta.task_create_dt_tm)
     FOR (ml_loop = 1 TO 5)
       IF (pl_due_day=0)
        IF (findstring(trim(cnvtstring(ml_loop)),ms_tmp_sched))
         CALL echo(build2("task day: ",pl_ord_day," ml_loop: ",ml_loop," sch: ",
          ms_tmp_sched))
         IF (((ml_loop > pl_ord_day) OR (pl_ord_day >= 5)) )
          pl_due_day = ml_loop,
          CALL echo(build2("pl_due_day: ",pl_due_day))
         ENDIF
        ENDIF
       ENDIF
     ENDFOR
     ml_look = (7 - (pl_ord_day - pl_due_day)),
     CALL echo(build2("ord ",format(o.orig_order_dt_tm,"mm/dd;;d")," "," tsk ",format(ta
       .task_create_dt_tm,"mm/dd;;d"),
      " "," due ",format(cnvtlookahead(concat(trim(cnvtstring(ml_look)),",D"),ta.task_create_dt_tm),
       "mm/dd;;d")," perf ",format(ce.performed_dt_tm,"mm/dd;;d"),
      " "," tod ",format(sysdate,"mm/dd;;d"))),
     CALL echo(build2("pl_due_day: ",trim(cnvtstring(pl_due_day),3)," - pl_ord_day: ",trim(cnvtstring
       (pl_ord_day),3)))
     IF (cnvtdate(ce.performed_dt_tm) > cnvtdate(cnvtlookahead(concat(trim(cnvtstring(ml_look)),",D"),
       ta.task_create_dt_tm)))
      CALL echo("late"), m_rec->ord[ml_idx].l_tsk_tot_vol_late += 1, m_rec->ord[ml_idx].fup[pl_cnt].
      n_stat_vol_late = 1
     ELSE
      CALL echo("not late"), m_rec->ord[ml_idx].l_tsk_tot_vol_due += 1, m_rec->ord[ml_idx].fup[pl_cnt
      ].n_stat_vol_due = 1
     ENDIF
    ENDIF
   ENDMACRO
  HEAD o.order_id
   CALL echo("*** BEG ORDER ********************************"), pl_cnt = 0, ml_idx = locateval(ml_loc,
    1,size(m_rec->ord,5),o.order_id,m_rec->ord[ml_loc].f_order_id),
   CALL echo(build2("task order_id: ",o.order_id))
  DETAIL
   CALL echo(build2("event: ",trim(uar_get_code_display(ce.event_cd),3)," event_id: ",ce.event_id)),
   pl_cnt += 1
   IF (pl_cnt > size(m_rec->ord[ml_idx].fup,5))
    CALL alterlist(m_rec->ord[ml_idx].fup,(pl_cnt+ 10))
   ENDIF
   m_rec->ord[ml_idx].fup[pl_cnt].f_clin_event_id = ce.clinical_event_id, m_rec->ord[ml_idx].fup[
   pl_cnt].d_perf_dt_tm = ce.performed_dt_tm, m_rec->ord[ml_idx].fup[pl_cnt].d_create_dt_tm = ta
   .task_create_dt_tm,
   mcr_chk_sched
  FOOT  o.order_id
   CALL echo("*** END ORDER * *********************************"),
   CALL echo(" ... "),
   CALL alterlist(m_rec->ord[ml_idx].fup,pl_cnt)
  WITH nocounter, expand = 1
 ;end select
 IF (size(m_rec->ord,5) > 0)
  SELECT INTO "nl:"
   ps_cat_disp = m_rec->ord[d.seq].s_cat_disp, pl_sort =
   IF ((m_rec->ord[d.seq].f_cat_cd=mf_high_risk_cd)) 1
   ELSEIF ((m_rec->ord[d.seq].f_cat_cd=mf_oral_supp_cd)) 2
   ELSEIF ((m_rec->ord[d.seq].f_cat_cd=mf_tube_feed_cd)) 3
   ELSEIF ((m_rec->ord[d.seq].f_cat_cd=mf_cons_nut_svc_cd)) 4
   ELSEIF ((m_rec->ord[d.seq].f_cat_cd=mf_nut_svc_cons_cd)) 5
   ELSEIF ((m_rec->ord[d.seq].f_cat_cd=mf_cons_per_pol_cd)) 6
   ELSEIF ((m_rec->ord[d.seq].f_cat_cd=mf_home_tpn_cd)) 7
   ENDIF
   FROM (dummyt d  WITH seq = value(size(m_rec->ord,5)))
   ORDER BY pl_sort
   HEAD REPORT
    pl_cnt = 0, pl_subtot_ord = 0, pl_subtot_stat_ord = 0,
    pl_subtot_stat_comp = 0, pl_subtot_stat_dc_man = 0, pl_subtot_stat_dc_sys = 0,
    pl_subtot_tsk_sys_gen = 0, pl_subtot_tsk_vol_due = 0, pl_subtot_tsk_vol_late = 0,
    pl_subtot_tsk_vol_miss = 0, pl_tot_ord = 0, pl_tot_stat_ord = 0,
    pl_tot_stat_comp = 0, pl_tot_stat_dc_man = 0, pl_tot_stat_dc_sys = 0,
    pl_tot_tsk_sys_gen = 0, pl_tot_tsk_vol_due = 0, pl_tot_tsk_vol_late = 0,
    pl_tot_tsk_vol_miss = 0
   HEAD pl_sort
    pl_cnt += 1,
    CALL alterlist(m_rec->rep,pl_cnt), m_rec->rep[pl_cnt].f_cat_cd = m_rec->ord[d.seq].f_cat_cd,
    m_rec->rep[pl_cnt].s_cat_disp = m_rec->ord[d.seq].s_cat_disp
   DETAIL
    m_rec->rep[pl_cnt].l_ord_tot_ordered += 1, m_rec->rep[pl_cnt].l_ord_tot_stat_ordered += m_rec->
    ord[d.seq].l_ord_tot_stat_ordered, m_rec->rep[pl_cnt].l_ord_tot_stat_compl += m_rec->ord[d.seq].
    l_ord_tot_stat_compl,
    m_rec->rep[pl_cnt].l_ord_tot_stat_dc_man += m_rec->ord[d.seq].l_ord_tot_stat_dc_man, m_rec->rep[
    pl_cnt].l_ord_tot_stat_dc_sys += m_rec->ord[d.seq].l_ord_tot_stat_dc_sys, m_rec->rep[pl_cnt].
    l_tsk_tot_sys_gen += m_rec->ord[d.seq].l_tsk_tot_sys_gen,
    m_rec->rep[pl_cnt].l_tsk_tot_vol_late += m_rec->ord[d.seq].l_tsk_tot_vol_late, m_rec->rep[pl_cnt]
    .l_tsk_tot_vol_miss += m_rec->ord[d.seq].l_tsk_tot_vol_miss,
    CALL echo(build2("pl_cnt: ",trim(cnvtstring(pl_cnt))," ",trim(cnvtstring(m_rec->rep[pl_cnt].
       l_tsk_tot_vol_miss))," ",
     trim(cnvtstring(m_rec->ord[d.seq].l_tsk_tot_vol_miss))))
   FOOT  pl_sort
    pl_tot_ord += m_rec->rep[pl_cnt].l_ord_tot_ordered, pl_tot_stat_ord += m_rec->rep[pl_cnt].
    l_ord_tot_stat_ordered, pl_tot_stat_comp += m_rec->rep[pl_cnt].l_ord_tot_stat_compl,
    pl_tot_stat_dc_man += m_rec->rep[pl_cnt].l_ord_tot_stat_dc_man, pl_tot_stat_dc_sys += m_rec->rep[
    pl_cnt].l_ord_tot_stat_dc_sys, pl_tot_tsk_sys_gen += m_rec->rep[pl_cnt].l_tsk_tot_sys_gen,
    pl_tot_tsk_vol_due += m_rec->rep[pl_cnt].l_tsk_tot_vol_due, pl_tot_tsk_vol_late += m_rec->rep[
    pl_cnt].l_tsk_tot_vol_late, pl_tot_tsk_vol_miss += m_rec->rep[pl_cnt].l_tsk_tot_vol_miss
    IF ((m_rec->ord[d.seq].f_cat_cd IN (mf_high_risk_cd, mf_oral_supp_cd, mf_tube_feed_cd)))
     CALL echo("here inc subtotals"), pl_subtot_ord += m_rec->rep[pl_cnt].l_ord_tot_ordered,
     pl_subtot_stat_ord += m_rec->rep[pl_cnt].l_ord_tot_stat_ordered,
     pl_subtot_stat_comp += m_rec->rep[pl_cnt].l_ord_tot_stat_compl, pl_subtot_stat_dc_man += m_rec->
     rep[pl_cnt].l_ord_tot_stat_dc_man, pl_subtot_stat_dc_sys += m_rec->rep[pl_cnt].
     l_ord_tot_stat_dc_sys,
     pl_subtot_tsk_sys_gen += m_rec->rep[pl_cnt].l_tsk_tot_sys_gen, pl_subtot_tsk_vol_due += m_rec->
     rep[pl_cnt].l_tsk_tot_vol_due, pl_subtot_tsk_vol_late += m_rec->rep[pl_cnt].l_tsk_tot_vol_late,
     pl_subtot_tsk_vol_miss += m_rec->rep[pl_cnt].l_tsk_tot_vol_miss
    ENDIF
    IF (pl_sort=3)
     CALL echo("insert subtotals row"), pl_cnt += 1,
     CALL alterlist(m_rec->rep,pl_cnt),
     m_rec->rep[pl_cnt].s_cat_disp = "Totals for Preceeding Orders", m_rec->rep[pl_cnt].
     l_ord_tot_ordered = pl_subtot_ord, m_rec->rep[pl_cnt].l_ord_tot_stat_ordered =
     pl_subtot_stat_ord,
     m_rec->rep[pl_cnt].l_ord_tot_stat_compl = pl_subtot_stat_comp, m_rec->rep[pl_cnt].
     l_ord_tot_stat_dc_man = pl_subtot_stat_dc_man, m_rec->rep[pl_cnt].l_ord_tot_stat_dc_sys =
     pl_subtot_stat_dc_sys,
     m_rec->rep[pl_cnt].l_tsk_tot_sys_gen = pl_subtot_tsk_sys_gen, m_rec->rep[pl_cnt].
     l_tsk_tot_vol_due = pl_subtot_tsk_vol_due, m_rec->rep[pl_cnt].l_tsk_tot_vol_late =
     pl_subtot_tsk_vol_late,
     m_rec->rep[pl_cnt].l_tsk_tot_vol_miss = pl_subtot_tsk_vol_miss
    ENDIF
   FOOT REPORT
    pl_cnt += 1,
    CALL alterlist(m_rec->rep,pl_cnt), m_rec->rep[pl_cnt].s_cat_disp = "Grand Total All Orders",
    m_rec->rep[pl_cnt].l_ord_tot_ordered = pl_tot_ord, m_rec->rep[pl_cnt].l_ord_tot_stat_ordered =
    pl_tot_stat_ord, m_rec->rep[pl_cnt].l_ord_tot_stat_compl = pl_tot_stat_comp,
    m_rec->rep[pl_cnt].l_ord_tot_stat_dc_man = pl_tot_stat_dc_man, m_rec->rep[pl_cnt].
    l_ord_tot_stat_dc_sys = pl_tot_stat_dc_sys, m_rec->rep[pl_cnt].l_tsk_tot_sys_gen =
    pl_tot_tsk_sys_gen,
    m_rec->rep[pl_cnt].l_tsk_tot_vol_due = pl_tot_tsk_vol_due, m_rec->rep[pl_cnt].l_tsk_tot_vol_late
     = pl_tot_tsk_vol_late, m_rec->rep[pl_cnt].l_tsk_tot_vol_miss = pl_tot_tsk_vol_miss
   WITH nocounter
  ;end select
  SELECT INTO value( $OUTDEV)
   order_name = substring(1,50,m_rec->rep[d.seq].s_cat_disp), total_number_tasks = m_rec->rep[d.seq].
   l_ord_tot_ordered, pending_task_status = m_rec->rep[d.seq].l_ord_tot_stat_ordered,
   complete_task_status = m_rec->rep[d.seq].l_ord_tot_stat_compl, dc_manual_order_status = m_rec->
   rep[d.seq].l_ord_tot_stat_dc_man, dc_system_order_status = m_rec->rep[d.seq].l_ord_tot_stat_dc_sys,
   sys_generate_pending_task_status = m_rec->rep[d.seq].l_tsk_tot_sys_gen, volume_tasks_due = (m_rec
   ->rep[d.seq].l_ord_tot_stat_ordered - m_rec->rep[d.seq].l_ord_tot_stat_dc_man), volume_tasks_late
    = m_rec->rep[d.seq].l_tsk_tot_vol_late,
   overdue_task_status = m_rec->rep[d.seq].l_tsk_tot_vol_miss, beg_dt_prompt = ms_beg_dt_tm,
   end_dt_prompt = ms_end_dt_tm,
   facility_prompt = ms_facility, nursing_unit_prompt = ms_nurse_unit, run_time = trim(format(sysdate,
     "mm/dd/yy hh:mm;;d"),3),
   run_by = ms_run_by
   FROM (dummyt d  WITH seq = value(size(m_rec->rep,5)))
   PLAN (d)
   WITH nocounter, format, separator = " ",
    maxrow = 1
  ;end select
  DECLARE ms_file_name = vc WITH protect, constant(concat("nutrcons_",trim(format(sysdate,
      "mmddyyhhmmss;;d"),3),".csv"))
  FREE RECORD frec
  RECORD frec(
    1 file_desc = i4
    1 file_offset = i4
    1 file_dir = i4
    1 file_name = vc
    1 file_buf = vc
  )
  IF (((size(m_rec->ord,5) > 0) OR (size(m_rec->rep,5) > 0)) )
   SET frec->file_name = ms_file_name
   SET frec->file_buf = "w"
   SET stat = cclio("OPEN",frec)
   SET frec->file_buf = concat(
    '"NAME","FIN","ORDER","ORDER_ID","ORDER_STATUS","ORD_BY","SYS_GEN_PEND_TASK_STATUS",',
    '"VOLUME_TASKS_DUE","VOLUME_TASKS_LATE","OVERDUE_TASK_STATUS","DC_MAN",','"DC_SYS"',char(13),char
    (10))
   SET stat = cclio("WRITE",frec)
   IF (size(m_rec->ord,5) > 0)
    FOR (ml_loop = 1 TO size(m_rec->ord,5))
     SET frec->file_buf = concat('"',m_rec->ord[ml_loop].s_pat_name,'",','"',m_rec->ord[ml_loop].
      s_fin,
      '",','"',m_rec->ord[ml_loop].s_cat_disp,'",','"',
      trim(cnvtstring(m_rec->ord[ml_loop].f_order_id),3),'",','"',m_rec->ord[ml_loop].s_ord_status,
      '",',
      '"',m_rec->ord[ml_loop].s_act_prsnl,'",','"',trim(cnvtstring(m_rec->ord[ml_loop].
        l_tsk_tot_sys_gen),3),
      '",','"',trim(cnvtstring(m_rec->ord[ml_loop].l_tsk_tot_vol_due),3),'",','"',
      trim(cnvtstring(m_rec->ord[ml_loop].l_tsk_tot_vol_late),3),'",','"',trim(cnvtstring(m_rec->ord[
        ml_loop].l_tsk_tot_vol_miss),3),'",',
      '"',trim(cnvtstring(m_rec->ord[ml_loop].l_ord_tot_stat_dc_man),3),'",','"',trim(cnvtstring(
        m_rec->ord[ml_loop].l_ord_tot_stat_dc_sys),3),
      '"',char(13),char(10))
     SET stat = cclio("WRITE",frec)
    ENDFOR
   ENDIF
   IF (size(m_rec->rep,5) > 0)
    SET frec->file_buf = concat(",,,,,,,,,,,,",char(13),char(10))
    SET stat = cclio("WRITE",frec)
    SET frec->file_buf = concat(
     '"ORDER_NAME","TOTAL_NUMBER_ORDERED","ORD_STATUS_ORDERED","ORD_STATUS_COMPLETED",',
     '"ORD_STATUS_DC_MANUAL",',
     '"ORD_STATUS_DC_SYSTEM","ORD_STATUS_SYS_GENERATE","TSK_STATUS_VOLUME_DUE",',
     '"TSK_STATUS_VOLUME_LATE",',
     '"TSK_STATUS_VOLUME_MISSED","BEG_DT_PROMPT","END_DT_PROMPT","FACILITY_PROMPT",',
     '"NURSING_UNIT_PROMPT","RUN_TIME","RUN_BY"',char(13),char(10))
    SET stat = cclio("WRITE",frec)
    FOR (ml_loop = 1 TO size(m_rec->rep,5))
      IF ((m_rec->rep[ml_loop].s_cat_disp="Grand Total All Orders"))
       SET frec->file_buf = concat(",,,,,,,,,,,,",char(13),char(10))
       SET stat = cclio("WRITE",frec)
      ENDIF
      SET frec->file_buf = concat('"',m_rec->rep[ml_loop].s_cat_disp,'",','"',trim(cnvtstring(m_rec->
         rep[ml_loop].l_ord_tot_ordered),3),
       '",','"',trim(cnvtstring(m_rec->rep[ml_loop].l_ord_tot_stat_ordered),3),'",','"',
       trim(cnvtstring(m_rec->rep[ml_loop].l_ord_tot_stat_compl),3),'",','"',trim(cnvtstring(m_rec->
         rep[ml_loop].l_ord_tot_stat_dc_man),3),'",',
       '"',trim(cnvtstring(m_rec->rep[ml_loop].l_ord_tot_stat_dc_sys),3),'",','"',trim(cnvtstring(
         m_rec->rep[ml_loop].l_tsk_tot_sys_gen),3),
       '",','"',trim(cnvtstring(m_rec->rep[ml_loop].l_tsk_tot_vol_due),3),'",','"',
       trim(cnvtstring(m_rec->rep[ml_loop].l_tsk_tot_vol_late),3),'",','"',trim(cnvtstring(m_rec->
         rep[ml_loop].l_tsk_tot_vol_miss),3),'",',
       '"',ms_beg_dt_tm,'",','"',ms_end_dt_tm,
       '",','"',ms_facility,'",','"',
       ms_nurse_unit,'",','"',trim(format(sysdate,"mm/dd/yy hh:mm;;d"),3),'",',
       '"',ms_run_by,'"',char(13),char(10))
      SET stat = cclio("WRITE",frec)
      IF ((m_rec->rep[ml_loop].s_cat_disp="Totals for Preceeding Orders"))
       SET frec->file_buf = concat(",,,,,,,,,,,,",char(13),char(10))
       SET stat = cclio("WRITE",frec)
      ENDIF
    ENDFOR
   ENDIF
   SET stat = cclio("CLOSE",frec)
  ENDIF
  IF (ms_email != "no"
   AND findstring("@",ms_email) > 0)
   EXECUTE bhs_ma_email_file
   SET ms_tmp = concat("Nutrition Consult: ",format(sysdate,"mm/dd/yy hh:mm;;d"))
   CALL emailfile(value(ms_file_name),ms_file_name,ms_email,ms_tmp,1)
  ENDIF
 ELSE
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    col 0, "No Records Found for Selected Parameters"
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 IF (textlen(trim(ms_log,3)) > 0)
  CALL echo(ms_log)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    col 0, ms_log
   WITH nocounter
  ;end select
 ENDIF
 CALL echorecord(m_rec)
 FREE RECORD m_rec
END GO
