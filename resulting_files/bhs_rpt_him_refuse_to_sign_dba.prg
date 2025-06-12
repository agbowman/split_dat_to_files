CREATE PROGRAM bhs_rpt_him_refuse_to_sign:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "How many days should be included in the report ?" = 0
  WITH outdev, ml_days
 DECLARE mn_tracking_order_ind = i2 WITH protect, noconstant(0)
 DECLARE ml_num_of_days = i4 WITH protect, noconstant( $ML_DAYS)
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_action_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",103,"REFUSED"))
 DECLARE ml_refused_flag = i4 WITH protect, constant(3)
 DECLARE ml_cosign_flag = i4 WITH protect, constant(2)
 DECLARE ml_doc_review_flag = i4 WITH protect, constant(2)
 FREE RECORD brh_sign
 RECORD brh_sign(
   1 l_cnt = i4
   1 list[*]
     2 s_pat_name = vc
     2 s_mrn = vc
     2 s_fin = vc
     2 s_phys_name = vc
     2 s_comment = vc
     2 s_defic_name = vc
     2 f_refused_date = dq8
     2 f_request_date = dq8
     2 s_page_nbr = vc
 ) WITH protect
 SELECT INTO "nl:"
  FROM him_system_params hp
  WHERE hp.him_system_params_id > 0
  DETAIL
   mn_tracking_order_ind = hp.order_tracking_ind
  WITH nocounter
 ;end select
 CALL echo(mn_tracking_order_ind)
 SELECT INTO "nl:"
  pat_name = substring(1,50,p.name_full_formatted), mrn = substring(1,20,cnvtalias(ea1.alias,ea1
    .alias_pool_cd)), fin_nbr = substring(1,20,cnvtalias(ea2.alias,ea2.alias_pool_cd)),
  request_date = ce.request_dt_tm, refuse_date = ce.action_dt_tm, physician_name = substring(1,50,p2
   .name_full_formatted),
  defic_name = substring(1,100,uar_get_code_display(cl.event_cd)), action_comment = substring(1,120,
   ce.action_comment), page_nbr = c.page_nbr
  FROM ce_event_prsnl ce,
   clinical_event cl,
   him_event_extension h,
   person p,
   person p2,
   encntr_alias ea1,
   encntr_alias ea2,
   encounter e,
   cdi_sign_anno c
  PLAN (ce
   WHERE ce.action_status_cd=mf_action_cd
    AND ce.action_dt_tm >= cnvtdatetime((curdate - ml_num_of_days),0))
   JOIN (cl
   WHERE cl.event_id=ce.event_id
    AND cl.valid_until_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (ea1
   WHERE ea1.encntr_id=outerjoin(cl.encntr_id)
    AND ea1.encntr_alias_type_cd=outerjoin(mf_mrn_cd)
    AND ea1.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
    AND ea1.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3))
    AND ea1.active_ind=outerjoin(1))
   JOIN (ea2
   WHERE ea2.encntr_id=outerjoin(cl.encntr_id)
    AND ea2.encntr_alias_type_cd=outerjoin(mf_fin_cd)
    AND ea2.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
    AND ea2.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3))
    AND ea2.active_ind=outerjoin(1))
   JOIN (e
   WHERE e.encntr_id=cl.encntr_id)
   JOIN (h
   WHERE h.event_cd=cl.event_cd
    AND h.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND h.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND ((h.active_ind+ 0)=1)
    AND ((((h.organization_id+ 0)=e.organization_id)) OR (((h.organization_id+ 0)=0)))
    AND  NOT ( EXISTS (
   (SELECT
    oer.organization_id
    FROM org_event_set_reltn oer
    WHERE oer.organization_id=e.organization_id
     AND oer.active_ind=1))))
   JOIN (p
   WHERE p.person_id=ce.person_id
    AND p.active_ind=1)
   JOIN (p2
   WHERE p2.person_id=ce.action_prsnl_id
    AND p2.active_ind=1)
   JOIN (c
   WHERE c.event_prsnl_id=outerjoin(ce.event_prsnl_id))
  HEAD REPORT
   brh_sign->l_cnt = 0
  DETAIL
   brh_sign->l_cnt = (brh_sign->l_cnt+ 1), stat = alterlist(brh_sign->list,brh_sign->l_cnt), brh_sign
   ->list[brh_sign->l_cnt].s_pat_name = pat_name,
   brh_sign->list[brh_sign->l_cnt].s_mrn = mrn, brh_sign->list[brh_sign->l_cnt].s_fin = fin_nbr,
   brh_sign->list[brh_sign->l_cnt].s_phys_name = physician_name,
   brh_sign->list[brh_sign->l_cnt].s_comment = action_comment, brh_sign->list[brh_sign->l_cnt].
   s_defic_name = defic_name, brh_sign->list[brh_sign->l_cnt].f_refused_date = refuse_date,
   brh_sign->list[brh_sign->l_cnt].f_request_date = request_date
   IF (page_nbr > 0)
    brh_sign->list[brh_sign->l_cnt].s_page_nbr = cnvtstring(page_nbr)
   ENDIF
  WITH nocounter, orahintcbo("LEADING(CE,P,P2,C,CL,E,EA1,EA2,H)","INDEX(CE XIE4CE_EVENT_PRSNL)",
    "INDEX(P XPKPERSON)","INDEX(P2 XPKPERSON)","INDEX(C XAK1CDI_SIGN_ANNO)",
    "INDEX(CL XAK2CLINICAL_EVENT)","INDEX(E XPKENCOUNTER)","INDEX(EA1 XIE2ENCNTR_ALIAS)",
    "INDEX(EA2 XIE2ENCNTR_ALIAS)","INDEX(H XIE1HIM_EVENT_EXTENSION)",
    "INDEX(OER XPKORG_EVENT_SET_RELTN)","USE_NL(P)","USE_NL(P2)","USE_NL(C)","USE_NL(CL)",
    "USE_NL(E)","USE_NL(EA1)","USE_NL(EA2)","USE_NL(H)")
 ;end select
 CALL echo(mf_mrn_cd)
 CALL echo(mf_fin_cd)
 CALL echo(mf_action_cd)
 CALL echorecord(brh_sign)
 IF (mn_tracking_order_ind != 0)
  SELECT INTO "nl:"
   pat_name = substring(1,50,p.name_full_formatted), mrn = substring(1,20,cnvtalias(ea1.alias,ea1
     .alias_pool_cd)), fin_nbr = substring(1,20,cnvtalias(ea2.alias,ea2.alias_pool_cd)),
   request_date = o_n.notification_dt_tm, refuse_date = o_n.status_change_dt_tm, physician_name =
   substring(1,50,p2.name_full_formatted),
   defic_name = substring(1,100,o.hna_order_mnemonic), action_comment = uar_get_code_display(on2
    .notification_reason_cd)
   FROM order_notification o_n,
    orders o,
    order_review o_r,
    person p,
    person p2,
    encntr_alias ea1,
    encntr_alias ea2,
    order_notification on2
   PLAN (o_n
    WHERE o_n.notification_status_flag=ml_refused_flag
     AND o_n.notification_type_flag=ml_cosign_flag
     AND o_n.status_change_dt_tm >= cnvtdatetime((curdate - ml_num_of_days),0))
    JOIN (o_r
    WHERE o_r.order_id=o_n.order_id
     AND o_r.action_sequence=o_n.action_sequence
     AND o_r.review_type_flag=ml_doc_review_flag)
    JOIN (o
    WHERE o.order_id=o_r.order_id)
    JOIN (p
    WHERE p.person_id=o.person_id
     AND p.active_ind=1)
    JOIN (p2
    WHERE p2.person_id=o_n.to_prsnl_id
     AND p2.active_ind=1)
    JOIN (ea1
    WHERE ea1.encntr_id=outerjoin(o.encntr_id)
     AND ea1.encntr_alias_type_cd=outerjoin(mf_mrn_cd)
     AND ea1.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
     AND ea1.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3))
     AND ea1.active_ind=outerjoin(1))
    JOIN (ea2
    WHERE ea2.encntr_id=outerjoin(o.encntr_id)
     AND ea2.encntr_alias_type_cd=outerjoin(mf_fin_cd)
     AND ea2.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
     AND ea2.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3))
     AND ea2.active_ind=outerjoin(1))
    JOIN (on2
    WHERE on2.order_id=outerjoin(o_n.order_id)
     AND on2.parent_order_notification_id=outerjoin(o_n.order_notification_id))
   ORDER BY o_n.order_notification_id
   HEAD REPORT
    brh_sign->l_cnt = brh_sign->l_cnt
   HEAD o_n.order_notification_id
    brh_sign->l_cnt = (brh_sign->l_cnt+ 1), stat = alterlist(brh_sign->list,brh_sign->l_cnt),
    brh_sign->list[brh_sign->l_cnt].s_pat_name = pat_name,
    brh_sign->list[brh_sign->l_cnt].s_mrn = mrn, brh_sign->list[brh_sign->l_cnt].s_fin = fin_nbr,
    brh_sign->list[brh_sign->l_cnt].s_phys_name = physician_name,
    brh_sign->list[brh_sign->l_cnt].s_comment = action_comment, brh_sign->list[brh_sign->l_cnt].
    s_defic_name = defic_name, brh_sign->list[brh_sign->l_cnt].f_refused_date = refuse_date,
    brh_sign->list[brh_sign->l_cnt].f_request_date = request_date
   WITH nocounter
  ;end select
 ENDIF
 CALL echorecord(brh_sign)
 IF ((brh_sign->l_cnt != 0))
  SELECT INTO  $OUTDEV
   mrn = trim(substring(1,50,brh_sign->list[d.seq].s_mrn)), financial_number = trim(substring(1,50,
     brh_sign->list[d.seq].s_fin)), patient_name = trim(substring(1,100,brh_sign->list[d.seq].
     s_pat_name)),
   deficiency = trim(substring(1,100,brh_sign->list[d.seq].s_defic_name)), request_date = format(
    cnvtdatetime(brh_sign->list[d.seq].f_request_date),"dd-mmm-yyyy hh:mm:ss;;d"), physician_name =
   trim(substring(1,100,brh_sign->list[d.seq].s_phys_name)),
   reason = trim(substring(1,100,brh_sign->list[d.seq].s_comment)), refused_date = format(
    cnvtdatetime(brh_sign->list[d.seq].f_refused_date),"dd-mmm-yyyy hh:mm:ss;;d"), page_nbr = trim(
    substring(1,10,brh_sign->list[d.seq].s_page_nbr))
   FROM (dummyt d  WITH seq = brh_sign->l_cnt)
   PLAN (d
    WHERE d.seq > 0)
   ORDER BY mrn
   WITH nocounter, maxcol = 20000, format,
    separator = " ", memsort
  ;end select
 ELSE
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = "Report finished successfully. No data qualified.", col 0,
    "{PS/792 0 translate 90 rotate/}",
    y_pos = 18, row + 1, "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1
   WITH dio = 08
  ;end select
 ENDIF
END GO
