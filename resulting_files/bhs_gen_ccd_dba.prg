CREATE PROGRAM bhs_gen_ccd:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "encounter type" = "",
  "Beg Date" = "SYSDATE",
  "End Date" = "SYSDATE",
  "Batch Size:" = 0,
  "Batch pause in Seconds" = 0,
  "CSV Recipient" = ""
  WITH outdev, s_encntr_type, s_beg_dt_tm,
  s_end_dt_tm, l_batch_size, l_pause_seconds,
  s_csv_recipient
 EXECUTE bhs_check_domain:dba
 EXECUTE bhs_hlp_ccl
 FREE RECORD m_rec
 RECORD m_rec(
   1 vit[*]
     2 f_code_value = f8
     2 s_disp = vc
   1 ccd[*]
     2 f_person_id = f8
     2 f_encntr_id = f8
     2 f_event_id = f8
     2 s_id_type = vc
     2 f_event_dt_tm = f8
     2 s_event_dt_tm = vc
     2 s_cmrn = vc
     2 s_fin = vc
   1 ccd_sort[*]
     2 f_person_id = f8
     2 f_encntr_id = f8
     2 f_event_id = f8
     2 s_id_type = vc
     2 f_event_dt_tm = f8
     2 s_event_dt_tm = vc
     2 s_cmrn = vc
     2 s_fin = vc
     2 c_status = c1
 ) WITH protect
 IF (validate(reply->status_data[1].status)=0)
  RECORD reply(
    1 status_data[1]
      2 status = c1
  ) WITH protect
 ENDIF
 DECLARE ms_encntr_type = vc WITH protect, constant(trim(cnvtupper( $S_ENCNTR_TYPE)))
 DECLARE ml_pause_seconds = i4 WITH protect, constant( $L_PAUSE_SECONDS)
 DECLARE ms_dm_info_name = vc WITH protect, constant(concat(trim(cnvtupper( $S_ENCNTR_TYPE)),
   "_STOP_DT_TM"))
 DECLARE ml_inpat_max_hrs = i4 WITH protect, constant(24)
 DECLARE ml_outpat_max_hrs = i4 WITH protect, constant(8)
 DECLARE ml_inpat_job_hrs = i4 WITH protect, constant(12)
 DECLARE ml_outpat_job_hrs = i4 WITH protect, constant(2)
 DECLARE ms_loc_dir = vc WITH protect, constant(build(logical("bhscust"),"/ftp/bhs_gen_ccd/"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_cmrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"CMRN"))
 DECLARE mf_outp_typ_cls_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",69,"OUTPATIENT")
  )
 DECLARE mf_obsv_typ_cls_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",69,"OBSERVATION"
   ))
 DECLARE mf_recr_typ_cls_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",69,"RECURRING"))
 DECLARE mf_inpt_typ_cls_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",69,"INPATIENT"))
 DECLARE mf_pharm_typ_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6000,"PHARMACY"))
 DECLARE mf_pharm_act_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,"PHARMACY"))
 DECLARE mf_active_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE"))
 DECLARE mf_vitals_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",93,"VITALS"))
 DECLARE mf_immunizations_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",93,
   "IMMUNIZATIONS"))
 DECLARE mf_ordered_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED"))
 DECLARE mf_completed_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"COMPLETED"))
 DECLARE mf_discontinued_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,
   "DISCONTINUED"))
 DECLARE mf_inprocess_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"INPROCESS"))
 DECLARE mf_pendreview_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,
   "PENDINGREVIEW"))
 DECLARE mf_pendcomplete_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,
   "PENDINGCOMPLETE"))
 DECLARE mf_pchart_contr_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",89,"POWERCHART")
  )
 DECLARE mf_ops_inprocess_status_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",460,
   "INPROCESS"))
 DECLARE ms_ops_job_name = vc WITH protect, constant("HIE CCD Generation Outpatient")
 DECLARE mf_pre1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"PREADMITDAYSTAY"))
 DECLARE mf_pre2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"PREADMITIP"))
 DECLARE mf_pre3_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"PRECMTYOFFICEVISIT")
  )
 DECLARE mf_pre4_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"PREOFFICEVISIT"))
 DECLARE mf_pre5_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "PREOUTPATIENTONETIME"))
 DECLARE mf_pre6_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"PREOUTPT"))
 DECLARE mf_pre7_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"PRERECUROFFICEVISIT"
   ))
 DECLARE ms_start_script_dt_tm = vc WITH protect, constant(format(sysdate,"dd-mmm-yyyy hh:mm:ss;;d"))
 DECLARE ml_max_rows_to_process = i4 WITH protect, constant(8000)
 DECLARE ml_gen_ccd_file = vc WITH protect, constant(build(logical("bhscust"),
   "/bhs_ccd_gen/bhs_gen_ccd_",format(sysdate,"ddmmmyyyy;;d"),".dat"))
 DECLARE ml_batch_size = i4 WITH protect, noconstant( $L_BATCH_SIZE)
 DECLARE mn_ops = i2 WITH protect, noconstant(0)
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ms_beg_dt_tm = vc WITH protect, noconstant( $S_BEG_DT_TM)
 DECLARE ms_end_dt_tm = vc WITH protect, noconstant( $S_END_DT_TM)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_num = i4 WITH protect, noconstant(0)
 DECLARE mf_vitals_evt_set_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mf_encntr_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mf_encntr_type_cd2 = f8 WITH protect, noconstant(0.0)
 DECLARE mf_encntr_type_cd3 = f8 WITH protect, noconstant(0.0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_ccd_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_fail_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_recs = i4 WITH protect, noconstant(0)
 DECLARE ml_blocks = i4 WITH protect, noconstant(0)
 DECLARE ml_beg = i4 WITH protect, noconstant(0)
 DECLARE ml_end = i4 WITH protect, noconstant(0)
 DECLARE ms_log = vc WITH protect, noconstant(" ")
 DECLARE ms_dm_stop_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_recipient = vc WITH protect, noconstant(trim( $S_CSV_RECIPIENT))
 DECLARE ms_filename = vc WITH protect, noconstant(build(ms_loc_dir,concat("bhs_gen_ccd_",trim(format
     (sysdate,"mmddyyhhmmss;;d")),".csv")))
 DECLARE ms_max_hrs = vc WITH protect, noconstant(" ")
 DECLARE ms_job_hrs = vc WITH protect, noconstant(" ")
 DECLARE ms_template_param = vc WITH protect, noconstant(" ")
 DECLARE mn_csv_ind = i2 WITH protect, noconstant(0)
 DECLARE mn_prod_ind = i4 WITH protect, noconstant(0)
 DECLARE ms_dcl = vc WITH protect, noconstant(" ")
 DECLARE mn_dcl_stat = i4 WITH protect, noconstant(0)
 DECLARE ml_catchup_ind = i4 WITH protect, noconstant(0)
 DECLARE ml_loop_cnt = i4 WITH protect, noconstant(0)
 DECLARE mf_hours_offset = f8 WITH protect, noconstant(0.0)
 DECLARE ml_i = i4 WITH protect, noconstant(0)
 DECLARE ml_process_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_rows_found = i4 WITH protect, noconstant(0)
 CALL echo(concat("mf_OUTP_TYP_CLS_CD: ",trim(cnvtstring(mf_outp_typ_cls_cd))))
 CALL echo(concat("mf_INPT_TYP_CLS_CD: ",trim(cnvtstring(mf_inpt_typ_cls_cd))))
 CALL echo(concat("mf_ACTIVE_CD: ",trim(cnvtstring(mf_active_cd))))
 CALL echo(concat("ml_batch_size: ",trim(cnvtstring(ml_batch_size))))
 CALL echo(concat("ml_PAUSE_SECONDS: ",trim(cnvtstring(ml_pause_seconds))))
 CALL echo(build2("mf_PCHART_CONTR_CD: ",mf_pchart_contr_cd))
 CALL bhs_sbr_log("start","",0,"",0.0,
  "","Begin Script","")
 SET reply->status_data[1].status = "F"
 IF (gl_bhs_prod_flag=1)
  SET mn_prod_ind = 1
 ENDIF
 IF (((validate(request->batch_selection)) OR (mn_ops=1)) )
  SET mn_ops = 1
  CALL echo("*** OPS ***")
 ELSE
  IF (((textlen(trim(ms_beg_dt_tm))=0) OR (textlen(trim(ms_beg_dt_tm))=0)) )
   SET ms_log = "Warning: For non-ops runs of the script, you have to enter date range - exiting"
   GO TO exit_script
  ENDIF
 ENDIF
 IF (mn_ops=1)
  SELECT INTO "nl:"
   FROM ops2_job oj,
    ops2_sched_job osj
   PLAN (oj
    WHERE oj.job_name=ms_ops_job_name
     AND oj.active_ind=1
     AND oj.end_effective_dt_tm > sysdate)
    JOIN (osj
    WHERE osj.ops2_job_id=oj.ops2_job_id
     AND osj.status_cd=mf_ops_inprocess_status_cd
     AND osj.active_ind=1
     AND osj.end_effective_dt_tm > sysdate)
   DETAIL
    ml_process_cnt += 1
   WITH nocounter
  ;end select
  IF (ml_process_cnt > 1)
   CALL echo("*** TWO PROCESSES RUNNING - EXIT SCRIPT ***")
   SET reply->status_data[1].status = "I"
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   FROM dm_info d
   WHERE d.info_domain="BHS_GEN_CCD_OPS"
    AND d.info_name=ms_dm_info_name
   DETAIL
    ms_beg_dt_tm = trim(format(d.info_date,"dd-mmm-yyyy hh:mm:ss;;d"))
   WITH nocounter
  ;end select
  IF (curqual < 1)
   SET ms_log = "001 - DM_INFO row not found"
   SET ms_beg_dt_tm = trim(format(sysdate,"dd-mmm-yyyy hh:mm;;d"))
   GO TO send_page
  ENDIF
  IF (ms_encntr_type="OUTPATIENT")
   CALL echo("*** OUTPATIENT ***")
   IF (datetimediff(sysdate,cnvtdatetime(ms_beg_dt_tm),3) > ml_outpat_max_hrs)
    SET ms_max_hrs = trim(cnvtstring(ml_outpat_max_hrs))
    SET ms_job_hrs = trim(cnvtstring(ml_outpat_job_hrs))
    SET ml_catchup_ind = 1
    CALL echo("*** LAST RUN MORE THAN 8 HOURS OLD ***")
   ENDIF
  ELSEIF (ms_encntr_type="INPATIENT")
   IF (datetimediff(sysdate,cnvtdatetime(ms_beg_dt_tm),3) > ml_inpat_max_hrs)
    SET ms_log = concat("002 - Last job ended over ",trim(cnvtstring(ml_inpat_max_hrs))," hrs ago")
    SET ms_max_hrs = trim(cnvtstring(ml_inpat_max_hrs))
    SET ms_job_hrs = trim(cnvtstring(ml_inpat_job_hrs))
    GO TO send_page
   ENDIF
  ENDIF
  SET ms_end_dt_tm = trim(format(sysdate,"dd-mmm-yyyy hh:mm:ss;;d"))
 ENDIF
 IF (((findstring("@",ms_recipient) > 0) OR (cnvtupper(ms_recipient)="FTP")) )
  SET mn_csv_ind = 1
 ELSEIF (textlen(ms_recipient) > 0
  AND findstring("@",ms_recipient)=0
  AND mn_ops=0)
  SET ms_log = "Recipient email is invalid"
 ENDIF
 IF (ms_encntr_type="OUTPATIENT")
  SET mf_encntr_type_cd = mf_outp_typ_cls_cd
  SET mf_encntr_type_cd2 = mf_obsv_typ_cls_cd
  SET mf_encntr_type_cd3 = mf_recr_typ_cls_cd
 ELSEIF (ms_encntr_type="INPATIENT")
  SET mf_encntr_type_cd = mf_inpt_typ_cls_cd
  SET mf_encntr_type_cd2 = mf_inpt_typ_cls_cd
  SET mf_encntr_type_cd3 = mf_inpt_typ_cls_cd
 ENDIF
 SELECT INTO "nl:"
  cv.display, cv.code_value
  FROM v500_event_set_explode vese,
   code_value cv
  PLAN (vese
   WHERE vese.event_set_cd IN (mf_vitals_cd, mf_immunizations_cd)
    AND vese.event_cd > 0.0)
   JOIN (cv
   WHERE cv.code_value=vese.event_cd)
  ORDER BY cv.display
  HEAD REPORT
   pl_cnt = 0
  DETAIL
   pl_cnt += 1, stat = alterlist(m_rec->vit,pl_cnt), m_rec->vit[pl_cnt].f_code_value = cv.code_value,
   m_rec->vit[pl_cnt].s_disp = trim(cv.display)
  WITH nocounter
 ;end select
 IF (ml_catchup_ind=1)
  SET mf_hours_offset = datetimediff(sysdate,cnvtdatetime(ms_beg_dt_tm),3)
  SET ml_loop_cnt = ceil((mf_hours_offset/ 2))
  CALL echo(build("*** LOOP CNT - ",ml_loop_cnt," ***"))
  IF (ml_loop_cnt >= 10)
   SET ms_log = concat("002 - Last job ended over ",trim(cnvtstring(mf_hours_offset))," hrs ago")
   GO TO send_page
  ENDIF
 ELSE
  SET ml_loop_cnt = 1
 ENDIF
 FOR (ml_i = 1 TO ml_loop_cnt)
   CALL echo(build("*** LOOP - ",ml_i," ***"))
   IF (ml_catchup_ind=1)
    IF (ml_i > 1)
     SET ms_beg_dt_tm = trim(format(cnvtdatetime(ms_end_dt_tm),"dd-mmm-yyyy hh:mm:ss;;d"))
    ENDIF
    SET ms_end_dt_tm = trim(format(cnvtlookahead("2,H",cnvtdatetime(ms_beg_dt_tm)),
      "dd-mmm-yyyy hh:mm:ss;;d"))
    IF (ms_end_dt_tm > ms_start_script_dt_tm)
     SET ms_end_dt_tm = ms_start_script_dt_tm
    ENDIF
   ENDIF
   CALL echo(build("BEG DT TM: ",ms_beg_dt_tm))
   CALL echo(build("END DT TM: ",ms_end_dt_tm))
   CALL echo(build("START SCRIPT DT TM: ",ms_start_script_dt_tm))
   CALL echo("get clin events")
   SELECT INTO "nl:"
    FROM clinical_event ce,
     encounter e,
     encntr_alias ea
    PLAN (ce
     WHERE ce.performed_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
      AND expand(ml_num,1,size(m_rec->vit,5),ce.event_cd,m_rec->vit[ml_num].f_code_value))
     JOIN (e
     WHERE e.encntr_id=ce.encntr_id
      AND e.encntr_type_class_cd IN (mf_encntr_type_cd, mf_encntr_type_cd2, mf_encntr_type_cd3)
      AND e.active_ind=1
      AND  NOT (e.encntr_type_cd IN (mf_pre1_cd, mf_pre2_cd, mf_pre3_cd, mf_pre4_cd, mf_pre5_cd,
     mf_pre6_cd, mf_pre7_cd)))
     JOIN (ea
     WHERE ea.encntr_id=e.encntr_id
      AND ea.active_ind=1
      AND ea.end_effective_dt_tm > sysdate
      AND ea.encntr_alias_type_cd=mf_fin_cd
      AND ea.alias != "ATR*"
      AND ea.alias != "WALS*")
    ORDER BY ce.encntr_id
    HEAD REPORT
     pl_cnt = 0
    HEAD ce.encntr_id
     pl_cnt += 1, stat = alterlist(m_rec->ccd,pl_cnt), m_rec->ccd[pl_cnt].f_encntr_id = ce.encntr_id,
     m_rec->ccd[pl_cnt].f_person_id = ce.person_id, m_rec->ccd[pl_cnt].f_event_id = ce.event_id,
     m_rec->ccd[pl_cnt].s_id_type = "CLINICAL_EVENT_ID",
     m_rec->ccd[pl_cnt].f_event_dt_tm = ce.clinsig_updt_dt_tm, m_rec->ccd[pl_cnt].s_event_dt_tm =
     trim(format(ce.clinsig_updt_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d")), m_rec->ccd[pl_cnt].s_fin = trim(
      ea.alias)
    FOOT REPORT
     CALL echo(concat(trim(cnvtstring(pl_cnt))," rows found on clinical event"))
    WITH nocounter
   ;end select
   CALL echo("get orders")
   SELECT INTO "nl:"
    FROM orders o,
     encounter e,
     encntr_alias ea
    PLAN (o
     WHERE o.orig_order_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
      AND o.catalog_type_cd=mf_pharm_typ_cd
      AND o.order_status_cd IN (mf_completed_cd, mf_discontinued_cd, mf_inprocess_cd,
     mf_pendreview_cd, mf_pendcomplete_cd)
      AND o.orig_ord_as_flag IN (1, 2)
      AND o.active_ind=1)
     JOIN (e
     WHERE e.encntr_id=o.encntr_id
      AND e.encntr_type_class_cd IN (mf_encntr_type_cd, mf_encntr_type_cd2, mf_encntr_type_cd3)
      AND e.active_ind=1)
     JOIN (ea
     WHERE ea.encntr_id=e.encntr_id
      AND ea.active_ind=1
      AND ea.end_effective_dt_tm > sysdate
      AND ea.encntr_alias_type_cd=mf_fin_cd
      AND ea.alias != "ATR*")
    ORDER BY o.encntr_id
    HEAD REPORT
     pl_cnt = size(m_rec->ccd,5), pl_ord_cnt = 0
    HEAD o.encntr_id
     ml_idx = locateval(ml_num,1,size(m_rec->ccd,5),o.encntr_id,m_rec->ccd[ml_num].f_encntr_id,
      o.person_id,m_rec->ccd[ml_num].f_person_id)
     IF (ml_idx=0)
      pl_cnt += 1, pl_ord_cnt += 1, stat = alterlist(m_rec->ccd,pl_cnt),
      m_rec->ccd[pl_cnt].f_encntr_id = o.encntr_id, m_rec->ccd[pl_cnt].f_person_id = o.person_id,
      m_rec->ccd[pl_cnt].f_event_id = o.order_id,
      m_rec->ccd[pl_cnt].s_id_type = "ORDER_ID", m_rec->ccd[pl_cnt].f_event_dt_tm = o
      .orig_order_dt_tm, m_rec->ccd[pl_cnt].s_event_dt_tm = trim(format(o.orig_order_dt_tm,
        "dd-mmm-yyyy hh:mm:ss;;d")),
      m_rec->ccd[pl_cnt].s_fin = trim(ea.alias)
     ENDIF
    FOOT REPORT
     CALL echo(concat(trim(cnvtstring(pl_ord_cnt))," rows found on orders"))
    WITH nocounter
   ;end select
   CALL echo("get problems")
   SELECT INTO "nl:"
    FROM problem p,
     encounter e,
     encntr_alias ea
    PLAN (p
     WHERE p.active_ind=1
      AND p.active_status_cd=mf_active_cd
      AND p.beg_effective_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
      AND p.contributor_system_cd=mf_pchart_contr_cd
      AND  NOT (p.updt_id IN (1.0, 3.0, 22226380, 19526987)))
     JOIN (e
     WHERE e.person_id=p.person_id
      AND e.active_ind=1
      AND e.reg_dt_tm <= p.beg_effective_dt_tm
      AND ((e.disch_dt_tm >= p.beg_effective_dt_tm) OR (e.disch_dt_tm=null)) )
     JOIN (ea
     WHERE ea.encntr_id=e.encntr_id
      AND ea.active_ind=1
      AND ea.end_effective_dt_tm > sysdate
      AND ea.encntr_alias_type_cd=mf_fin_cd
      AND ea.alias != "ATR*")
    ORDER BY p.person_id, e.reg_dt_tm DESC
    HEAD REPORT
     pl_cnt = size(m_rec->ccd,5), pl_prob_cnt = 0
    HEAD p.person_id
     ml_idx = locateval(ml_num,1,size(m_rec->ccd,5),e.encntr_id,m_rec->ccd[ml_num].f_encntr_id,
      p.person_id,m_rec->ccd[ml_num].f_person_id)
     IF (ml_idx=0)
      pl_cnt += 1, pl_prob_cnt += 1, stat = alterlist(m_rec->ccd,pl_cnt),
      m_rec->ccd[pl_cnt].f_person_id = p.person_id, m_rec->ccd[pl_cnt].f_encntr_id = e.encntr_id,
      m_rec->ccd[pl_cnt].f_event_id = p.problem_id,
      m_rec->ccd[pl_cnt].s_id_type = "PROBLEM_ID", m_rec->ccd[pl_cnt].f_event_dt_tm = p
      .beg_effective_dt_tm, m_rec->ccd[pl_cnt].s_event_dt_tm = trim(format(p.beg_effective_dt_tm,
        "dd-mmm-yyyy hh:mm:ss;;d")),
      m_rec->ccd[pl_cnt].s_fin = trim(ea.alias)
     ENDIF
    FOOT REPORT
     CALL echo(concat(trim(cnvtstring(pl_prob_cnt))," rows found on problem"))
    WITH nocounter
   ;end select
   CALL echo("get diag")
   SELECT INTO "nl:"
    FROM diagnosis d,
     encounter e,
     encntr_alias ea
    PLAN (d
     WHERE d.active_ind=1
      AND d.active_status_cd=mf_active_cd
      AND d.beg_effective_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
      AND d.contributor_system_cd=mf_pchart_contr_cd)
     JOIN (e
     WHERE e.encntr_id=d.encntr_id
      AND e.encntr_type_class_cd IN (mf_encntr_type_cd, mf_encntr_type_cd2, mf_encntr_type_cd3)
      AND e.active_ind=1)
     JOIN (ea
     WHERE ea.encntr_id=e.encntr_id
      AND ea.active_ind=1
      AND ea.end_effective_dt_tm > sysdate
      AND ea.encntr_alias_type_cd=mf_fin_cd
      AND ea.alias != "ATR*")
    ORDER BY d.person_id
    HEAD REPORT
     pl_cnt = size(m_rec->ccd,5), pl_dx_cnt = 0
    HEAD d.person_id
     ml_idx = locateval(ml_num,1,size(m_rec->ccd,5),d.encntr_id,m_rec->ccd[ml_num].f_encntr_id,
      d.person_id,m_rec->ccd[ml_num].f_person_id)
     IF (ml_idx=0)
      pl_cnt += 1, pl_dx_cnt += 1, stat = alterlist(m_rec->ccd,pl_cnt),
      m_rec->ccd[pl_cnt].f_person_id = d.person_id, m_rec->ccd[pl_cnt].f_encntr_id = d.encntr_id,
      m_rec->ccd[pl_cnt].f_event_id = d.diagnosis_id,
      m_rec->ccd[pl_cnt].s_id_type = "DIAGNOSIS_ID", m_rec->ccd[pl_cnt].f_event_dt_tm = d
      .beg_effective_dt_tm, m_rec->ccd[pl_cnt].s_event_dt_tm = trim(format(d.beg_effective_dt_tm,
        "dd-mmm-yyyy hh:mm:ss;;d")),
      m_rec->ccd[pl_cnt].s_fin = trim(ea.alias)
     ENDIF
    FOOT REPORT
     CALL echo(concat(trim(cnvtstring(pl_dx_cnt))," rows found on diagnosis"))
    WITH nocounter
   ;end select
   CALL echo("get allergies")
   SELECT INTO "nl:"
    FROM allergy a,
     encounter e,
     encntr_alias ea
    PLAN (a
     WHERE a.active_ind=1
      AND a.end_effective_dt_tm > sysdate
      AND a.beg_effective_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm))
     JOIN (e
     WHERE e.encntr_id=a.encntr_id
      AND e.encntr_type_class_cd IN (mf_encntr_type_cd, mf_encntr_type_cd2, mf_encntr_type_cd3)
      AND e.active_ind=1)
     JOIN (ea
     WHERE ea.encntr_id=e.encntr_id
      AND ea.active_ind=1
      AND ea.end_effective_dt_tm > sysdate
      AND ea.encntr_alias_type_cd=mf_fin_cd
      AND ea.alias != "ATR*")
    ORDER BY a.person_id
    HEAD REPORT
     pl_cnt = size(m_rec->ccd,5), pl_a_cnt = 0
    HEAD a.person_id
     ml_idx = locateval(ml_num,1,size(m_rec->ccd,5),a.encntr_id,m_rec->ccd[ml_num].f_encntr_id,
      a.person_id,m_rec->ccd[ml_num].f_person_id)
     IF (ml_idx=0)
      pl_cnt += 1, pl_a_cnt += 1, stat = alterlist(m_rec->ccd,pl_cnt),
      m_rec->ccd[pl_cnt].f_person_id = a.person_id, m_rec->ccd[pl_cnt].f_encntr_id = a.encntr_id,
      m_rec->ccd[pl_cnt].f_event_id = a.allergy_id,
      m_rec->ccd[pl_cnt].s_id_type = "ALLERGY_ID", m_rec->ccd[pl_cnt].f_event_dt_tm = a
      .beg_effective_dt_tm, m_rec->ccd[pl_cnt].s_event_dt_tm = trim(format(a.beg_effective_dt_tm,
        "dd-mmm-yyyy hh:mm:ss;;d")),
      m_rec->ccd[pl_cnt].s_fin = trim(ea.alias)
     ENDIF
    FOOT REPORT
     CALL echo(concat(trim(cnvtstring(pl_a_cnt))," rows found on allergy"))
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM encounter e,
     encntr_alias ea
    PLAN (e
     WHERE e.active_ind=1
      AND e.end_effective_dt_tm > sysdate
      AND e.disch_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
      AND e.encntr_type_class_cd IN (mf_encntr_type_cd, mf_encntr_type_cd2, mf_encntr_type_cd3))
     JOIN (ea
     WHERE ea.encntr_id=e.encntr_id
      AND ea.active_ind=1
      AND ea.end_effective_dt_tm > sysdate
      AND ea.encntr_alias_type_cd=mf_fin_cd
      AND ea.alias != "ATR*")
    ORDER BY e.encntr_id
    HEAD REPORT
     pl_cnt = size(m_rec->ccd,5), pl_e_cnt = 0
    HEAD e.encntr_id
     ml_idx = locateval(ml_num,1,size(m_rec->ccd,5),e.encntr_id,m_rec->ccd[ml_num].f_encntr_id,
      e.person_id,m_rec->ccd[ml_num].f_person_id)
     IF (ml_idx=0)
      pl_cnt += 1, pl_e_cnt += 1, stat = alterlist(m_rec->ccd,pl_cnt),
      m_rec->ccd[pl_cnt].f_person_id = e.person_id, m_rec->ccd[pl_cnt].f_encntr_id = e.encntr_id,
      m_rec->ccd[pl_cnt].f_event_id = e.encntr_id,
      m_rec->ccd[pl_cnt].s_id_type = "ENCNTR_ID", m_rec->ccd[pl_cnt].f_event_dt_tm = e.disch_dt_tm,
      m_rec->ccd[pl_cnt].s_event_dt_tm = trim(format(e.disch_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d")),
      m_rec->ccd[pl_cnt].s_fin = trim(ea.alias)
     ENDIF
    FOOT REPORT
     CALL echo(concat(trim(cnvtstring(pl_e_cnt))," rows found for new discharge"))
    WITH nocounter
   ;end select
   SET ml_rows_found = size(m_rec->ccd,5)
   IF (ml_rows_found=0)
    SET ms_log = "No CCDs found"
    CALL bhs_sbr_log("log","",0,"CCD",0.0,
     "","NO CCDs FOUND","S")
    IF (mn_ops=1)
     UPDATE  FROM dm_info d
      SET d.info_date = cnvtdatetime(ms_end_dt_tm), d.updt_dt_tm = sysdate, d.updt_id = reqinfo->
       updt_id
      WHERE d.info_domain="BHS_GEN_CCD_OPS"
       AND d.info_name=ms_dm_info_name
      WITH nocounter
     ;end update
     COMMIT
     IF (curqual > 0)
      CALL echo("dm_info row updated")
     ENDIF
    ENDIF
   ELSE
    IF (mn_ops=1
     AND ml_rows_found > ml_max_rows_to_process)
     UPDATE  FROM dm_info d
      SET d.info_date = cnvtdatetime(ms_end_dt_tm), d.updt_dt_tm = sysdate, d.updt_id = reqinfo->
       updt_id
      WHERE d.info_domain="BHS_GEN_CCD_OPS"
       AND d.info_name=ms_dm_info_name
      WITH nocounter
     ;end update
     COMMIT
     IF (curqual > 0)
      CALL echo("dm_info row updated")
     ENDIF
     SELECT INTO value(ml_gen_ccd_file)
      FROM (dummyt d  WITH seq = value(ml_rows_found))
      DETAIL
       col 0, m_rec->ccd[d.seq].f_person_id, ",",
       col + 1, m_rec->ccd[d.seq].f_encntr_id, row + 1
      WITH nocounter, format = variable, maxrow = 1,
       maxcol = 5000
     ;end select
     CALL uar_send_mail(nullterm("jason.mullinnix@bhs.org"),nullterm(concat(gs_bhs_domain_name," ",
        ms_encntr_type," CCD OPS FAIL ",ms_beg_dt_tm)),nullterm("Max rows to process logic fired."),
      nullterm("CCD OPS JOB"),1,
      nullterm("IPM.NOTE"))
     GO TO exit_script
    ENDIF
    CALL echo("sort the list")
    SELECT INTO "nl:"
     pd_event_dt_tm = m_rec->ccd[d.seq].f_event_dt_tm
     FROM (dummyt d  WITH seq = value(size(m_rec->ccd,5))),
      person_alias pa
     PLAN (d)
      JOIN (pa
      WHERE (pa.person_id=m_rec->ccd[d.seq].f_person_id)
       AND pa.active_ind=1
       AND pa.end_effective_dt_tm > sysdate
       AND pa.person_alias_type_cd=mf_cmrn_cd)
     ORDER BY pd_event_dt_tm
     HEAD REPORT
      pl_cnt = 0
     DETAIL
      pl_cnt += 1, stat = alterlist(m_rec->ccd_sort,pl_cnt), m_rec->ccd_sort[pl_cnt].f_encntr_id =
      m_rec->ccd[d.seq].f_encntr_id,
      m_rec->ccd_sort[pl_cnt].f_person_id = m_rec->ccd[d.seq].f_person_id, m_rec->ccd_sort[pl_cnt].
      f_event_id = m_rec->ccd[d.seq].f_event_id, m_rec->ccd_sort[pl_cnt].s_id_type = m_rec->ccd[d.seq
      ].s_id_type,
      m_rec->ccd_sort[pl_cnt].f_event_dt_tm = m_rec->ccd[d.seq].f_event_dt_tm, m_rec->ccd_sort[pl_cnt
      ].s_event_dt_tm = m_rec->ccd[d.seq].s_event_dt_tm, m_rec->ccd_sort[pl_cnt].s_fin = m_rec->ccd[d
      .seq].s_fin,
      m_rec->ccd_sort[pl_cnt].s_cmrn = trim(pa.alias)
     WITH nocounter
    ;end select
    CALL echo(build2("call gen ccd script: ",size(m_rec->ccd_sort,5)," CCDs"))
    CALL bhs_sbr_log("log","",0,"CCD",0.0,
     "",trim(build2("Total CCDs found: ",size(m_rec->ccd,5))),"R")
    SET ml_recs = size(m_rec->ccd_sort,5)
    IF (ml_batch_size=0)
     SET ml_batch_size = ml_recs
    ENDIF
    IF (ml_recs > ml_batch_size)
     SET ml_blocks = (ml_recs/ ml_batch_size)
     IF (mod(ml_recs,ml_batch_size) > 0)
      SET ml_blocks += 1
     ENDIF
    ELSE
     SET ml_blocks = 1
     CALL echo(build2("blocks: ",ml_blocks))
    ENDIF
    FOR (ml_cnt = 1 TO ml_blocks)
      SET ml_beg = (((ml_cnt - 1) * ml_batch_size)+ 1)
      IF (((ml_beg+ ml_batch_size) > ml_recs))
       SET ml_end = ml_recs
      ELSE
       SET ml_end = ((ml_beg - 1)+ ml_batch_size)
      ENDIF
      FOR (ml_idx = ml_beg TO ml_end)
        SET ml_ccd_cnt += 1
        IF (validate(reply2))
         SET stat = initrec(reply2)
        ELSE
         RECORD reply2(
           1 status_data[1]
             2 status = c1
         )
        ENDIF
        IF (gl_bhs_prod_flag=0)
         SET ms_template_param = "T:680884409.00;O:0.00;C:437720951.00;D:1;L:22;PI:1;A:0"
        ELSE
         SET ms_template_param = "T:680884409.00;O:0.00;C:437720951.00;D:1;L:22;PI:1;A:0"
        ENDIF
        SET trace = recpersist
        EXECUTE bhs_si_ccd_trigger 0, ms_template_param, m_rec->ccd_sort[ml_idx].f_person_id,
        m_rec->ccd_sort[ml_idx].f_encntr_id, "" WITH replace("REPLY","REPLY2")
        IF ((reply2->status_data[1].status != "S"))
         CALL echo("reply 2 status failed")
         SET ml_fail_cnt += 1
         SET m_rec->ccd_sort[ml_idx].c_status = "F"
        ELSE
         SET m_rec->ccd_sort[ml_idx].c_status = "S"
        ENDIF
        SET trace = norecpersist
        SET ms_tmp = concat("latest CCD-",trim(cnvtstring(ml_ccd_cnt))," of ",trim(cnvtstring(ml_recs
           )),": ",
         trim(m_rec->ccd_sort[ml_idx].s_event_dt_tm)," ID: ",trim(cnvtstring(m_rec->ccd_sort[ml_idx].
           f_event_id))," ",m_rec->ccd_sort[ml_idx].s_id_type)
        CALL bhs_sbr_log("stop","",0,"",0.0,
         "",ms_tmp,"R")
        CALL bhs_sbr_log("log","",0,m_rec->ccd_sort[ml_idx].s_id_type,m_rec->ccd_sort[ml_idx].
         f_event_id,
         concat("Encounter_ID:",cnvtstring(m_rec->ccd_sort[ml_idx].f_encntr_id)),trim(concat("CDA: ",
           trim(cnvtstring(ml_idx))," of ",trim(cnvtstring(size(m_rec->ccd_sort,5))))),m_rec->
         ccd_sort[ml_idx].c_status)
        IF (mn_ops=1)
         UPDATE  FROM dm_info d
          SET d.info_date = cnvtlookahead("1,S",cnvtdatetime(m_rec->ccd_sort[ml_idx].s_event_dt_tm)),
           d.updt_dt_tm = sysdate, d.updt_id = reqinfo->updt_id
          WHERE d.info_domain="BHS_GEN_CCD_OPS"
           AND d.info_name=ms_dm_info_name
          WITH nocounter
         ;end update
         IF (curqual > 0)
          CALL echo("dm_info row updated")
         ENDIF
        ENDIF
      ENDFOR
      CALL pause(ml_pause_seconds)
    ENDFOR
    IF (mn_csv_ind=1)
     SELECT INTO value(ms_filename)
      FROM (dummyt d  WITH seq = value(size(m_rec->ccd_sort,5)))
      PLAN (d)
      HEAD REPORT
       ms_tmp = "encntr_id,person_id,event_name,event_id,event_dt_tm,fin,cmrn,send_status", col 0,
       ms_tmp
      DETAIL
       row + 1, ms_tmp = concat('"',trim(cnvtstring(m_rec->ccd_sort[d.seq].f_encntr_id)),'",','"',
        trim(cnvtstring(m_rec->ccd_sort[d.seq].f_person_id)),
        '",','"',m_rec->ccd_sort[d.seq].s_id_type,'",','"',
        trim(cnvtstring(m_rec->ccd_sort[d.seq].f_event_id)),'",','"',m_rec->ccd_sort[d.seq].
        s_event_dt_tm,'",',
        '"',m_rec->ccd_sort[d.seq].s_fin,'",','"',m_rec->ccd_sort[d.seq].s_cmrn,
        '",','"',m_rec->ccd_sort[d.seq].c_status,'"'), col 0,
       ms_tmp
      WITH nocounter
     ;end select
     CALL bhs_sbr_log("log","",0,"CCD",0.0,
      "",concat("CCD csv file generated: ",ms_filename),"R")
    ENDIF
   ENDIF
   SET ms_tmp = trim(concat("CCDs found: ",trim(cnvtstring(ml_recs)),"; sent: ",trim(cnvtstring(
       ml_ccd_cnt)),"; failed: ",
     trim(cnvtstring(ml_fail_cnt))))
   CALL bhs_sbr_log("log","",0,"CCD",0.0,
    "",ms_tmp,"S")
   SET reply->status_data[1].status = "S"
   IF (mn_csv_ind=1)
    IF (cnvtupper(ms_recipient)="FTP")
     CALL echo("FTP file to share")
     IF (ml_recs=0)
      SET ms_filename = replace(ms_filename,".csv",".txt")
      SELECT INTO value(ms_filename)
       FROM dummyt d
       HEAD REPORT
        col 0, "No data found",
        CALL echo("no data found")
       WITH nocounter
      ;end select
     ENDIF
    ENDIF
    IF (((cnvtupper(ms_recipient) != "FTP") OR (mn_ops=1)) )
     EXECUTE bhs_ma_email_file
     SET ms_tmp = concat(gs_bhs_domain_name," ",ms_encntr_type," CCD job: ",ms_beg_dt_tm,
      " - ",ms_end_dt_tm)
     IF (ml_recs > 0)
      IF (findstring("@",ms_recipient) > 0)
       CALL emailfile(value(ms_filename),ms_filename,ms_recipient,ms_tmp,0)
      ENDIF
     ELSE
      IF (findstring("@",ms_recipient) > 0)
       CALL uar_send_mail(nullterm(ms_recipient),nullterm(ms_tmp),nullterm(
         "no ccds found for this job"),nullterm("CCD OPS JOB"),1,
        nullterm("IPM.NOTE"))
      ENDIF
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 GO TO exit_script
#send_page
 SET ms_tmp = concat("*** ",gs_bhs_domain_name," ",ms_encntr_type," CCD OPS JOB FAILURE ***",
  char(13),char(13),"Job Name: HIE CCD Generation ",ms_encntr_type,char(13),
  "Job Date: ",ms_beg_dt_tm,char(13),"Error: ",ms_log,
  char(13),char(13))
 IF (ms_log="001*")
  SET ms_tmp = concat(ms_tmp,"Please ensure that the DM_INFO row for BHS_GEN_CCD has been inserted",
   char(13),"and dm_info.info_dt_tm has been set appropriately.",char(13),
   char(13))
  SET ms_tmp = concat(ms_tmp,"Once the appropriate start_dt_tm for this job has been determined, ",
   "use the following command to insert the dm_info_row:",char(13),char(13),
   "   insert into dm_info d",char(13),"   set",char(13),"     d.info_domain = 'BHS_GEN_CCD_OPS',",
   char(13),"     d.info_name = '",ms_encntr_type,"_STOP_DT_TM',",char(13),
   "     d.info_date = <date_tm>,",char(13),"     d.updt_dt_tm = sysdate,",char(13),
   "     d.updt_id = reqinfo->updt_id",
   char(13),"   with nocounter go commit go")
 ELSEIF (ms_log="002*")
  SET ms_tmp = concat(ms_tmp,"The time gap since the last CCD job ended is greater than ",ms_max_hrs,
   " hrs for ",ms_encntr_type,
   ".",char(13),"Please run the jobs manually in increments of ",ms_job_hrs,
   " hrs to cover the time gap.",
   char(13),
   "Once complete, update the dm_info.info_dt_tm to an appropriate time to begin the ops job.",char(
    13),char(13))
  SET ms_tmp = concat(ms_tmp,"Once the appropriate start_dt_tm for this job has been determined, ",
   "use the following command to update the dm_info_row:",char(13),char(13),
   "   update into dm_info d",char(13),"   set",char(13),"     d.info_date = <date_tm>,",
   char(13),"     d.updt_dt_tm = sysdate,",char(13),"     d.updt_id = reqinfo->updt_id",char(13),
   "   where d.info_domain = 'BHS_GEN_CCD_OPS'",char(13),"     and d.info_name = '",ms_encntr_type,
   "_STOP_DT_TM'",
   char(13),"   with nocounter go commit go")
 ENDIF
 CALL uar_send_mail(nullterm("ciscore@bhs.org"),nullterm(concat(gs_bhs_domain_name," ",ms_encntr_type,
    " CCD OPS FAIL ",ms_beg_dt_tm)),nullterm(ms_tmp),nullterm("CCD OPS JOB"),1,
  nullterm("IPM.NOTE"))
 IF (mn_prod_ind=1)
  SET ms_tmp = concat(ms_encntr_type," CDAFail-seeCoreInbox",trim(format(sysdate,"mm/dd/yy hh:mm;;d")
    ))
  CALL uar_send_mail(nullterm("94556@epage.bhs.org"),nullterm("CDA Ops Fail"),nullterm(ms_tmp),
   nullterm("CCD OPS JOB"),1,
   nullterm("IPM.NOTE"))
 ENDIF
#exit_script
 COMMIT
 CALL echo(concat("Log: ",ms_log))
 IF ((reply->status_data[1].status="S"))
  CALL bhs_sbr_log("stop","",0,"",0.0,
   trim(build2("CCDs found and sent successfully: ",size(m_rec->ccd_sort,5))),"End Time","S")
 ELSEIF ((reply->status_data[1].status="I"))
  CALL bhs_sbr_log("stop","",0,"",0.0,
   "Previous job still running.","End Time","S")
 ELSE
  CALL bhs_sbr_log("stop","",0,"",0.0,
   trim(build2("Failed: ",ms_log)),"End Time","F")
 ENDIF
 IF (mn_ops=0)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    ms_tmp = concat("CCDs executes for range ",ms_beg_dt_tm," to ",ms_end_dt_tm), col 0, ms_tmp
    IF ((reply->status_data[1].status="F"))
     col 0, row + 1, "script failed",
     CALL echo("script failed")
    ELSE
     ms_tmp = trim(concat("CCDs found: ",trim(cnvtstring(ml_recs)),"; sent: ",trim(cnvtstring(
         ml_ccd_cnt)),"; failed: ",
       trim(cnvtstring(ml_fail_cnt)))),
     CALL echo(ms_tmp), col 0,
     row + 1, ms_tmp, col 0,
     row + 1, "Log:", ms_log
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 FREE RECORD m_rec
END GO
