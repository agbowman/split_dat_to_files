CREATE PROGRAM bhs_rpt_wetu_wait_time:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin Date:" = "CURDATE",
  "End Date:" = "CURDATE",
  "Disch Status:" = "both"
  WITH outdev, s_beg_dt, s_end_dt,
  s_disch_stat
 FREE RECORD m_rec
 RECORD m_rec(
   1 loc[*]
     2 s_unit_disp = vc
     2 f_unit_cd = f8
   1 enc[*]
     2 f_person_id = f8
     2 f_encntr_id = f8
     2 f_disch_dt_tm = f8
     2 n_wetu = i2
     2 f_tracking_id = f8
     2 s_pat_name = vc
     2 s_cmrn = vc
     2 s_fin = vc
     2 s_race = vc
     2 s_ethnicity = vc
     2 s_bmc_provider_group = vc
     2 s_ega = vc
     2 s_obhld_admit_dt_tm = vc
     2 f_wetu1_dt_tm = f8
     2 s_wetu1_dt_tm = vc
     2 f_wroom_dt_tm = f8
     2 s_wroom_dt_tm = vc
     2 f_obhld_dt_tm = f8
     2 s_obhld_dt_tm = vc
     2 f_ldr_dt_tm = f8
     2 s_ldr_dt_tm = vc
     2 f_non_wroom_dt_tm = f8
     2 s_non_wroom_dt_tm = vc
     2 l_wait_time = i4
     2 s_wait_time = vc
     2 l_wetu_admit_time = i4
     2 s_wetu_admit_time = vc
     2 l_ldrp_admit_delay = i4
     2 s_ldrp_admit_delay = vc
     2 l_wetu_disch_time = i4
     2 s_wetu_disch_time = vc
     2 l_wetu_gyn_time = i4
     2 s_wetu_gyn_time = vc
     2 l_avg_time = i4
     2 loc[*]
       3 f_tracking_locator_id = f8
       3 f_arrive_dt_tm = f8
       3 s_arrive_dt_tm = vc
       3 f_depart_dt_tm = f8
       3 s_arrive_dt_tm = vc
       3 f_nurse_unit = f8
       3 s_nurse_unit = vc
       3 f_room = f8
       3 s_room = vc
   1 wrooms[*]
     2 s_unit = vc
     2 f_unit = f8
     2 s_room = vc
     2 f_room = f8
 ) WITH protect
 FREE RECORD frec
 RECORD frec(
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
   1 file_name = vc
   1 file_buf = vc
 )
 SET frec->file_buf = "w"
 IF (validate(reply->status_data[1].status)=0)
  RECORD reply(
    1 status_data[1]
      2 status = c1
  )
 ENDIF
 SET reply->status_data[1].status = "F"
 DECLARE ms_disch_stat = vc WITH protect, constant(trim(cnvtlower( $S_DISCH_STAT),3))
 DECLARE mf_cs4_cmrn = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2621"))
 DECLARE mf_cs8_auth = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2628"))
 DECLARE mf_cs8_mod = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2636"))
 DECLARE mf_cs8_alter = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!16901"))
 DECLARE mf_cs8_active = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2627"))
 DECLARE mf_cs34_wetu = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",34,"WETU"))
 DECLARE mf_cs34_inp_obgyn = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",34,
   "INPATIENTOBGYN"))
 DECLARE mf_cs72_ob_prov_grp = f8 WITH protect, constant(uar_get_code_by_cki("CKI.EC!14833"))
 DECLARE mf_cs72_ega_doc = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "EGAATDOCUMENTEDDATETIME"))
 DECLARE mf_cs220_wrwetu1 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"WRWETU1"))
 DECLARE mf_cs319_fin = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2930"))
 DECLARE mf_cs355_user_def = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",355,"USERDEFINED"
   ))
 DECLARE mf_cs356_race1 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,"RACE1"))
 DECLARE mf_cs356_race2 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,"RACE2"))
 DECLARE mf_cs356_race3 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,"RACE3"))
 DECLARE mf_cs356_race4 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,"RACE4"))
 DECLARE mf_cs356_race5 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,"RACE5"))
 DECLARE mf_cs356_ethnicity = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,"ETHNICITY")
  )
 DECLARE ms_beg_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_end_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_file_name = vc WITH protect, noconstant(" ")
 DECLARE ms_disch_parse = vc WITH protect, noconstant(" ")
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE mf_cs220_wetu1 = f8 WITH protect, noconstant(0.0)
 DECLARE mf_cs220_win2 = f8 WITH protect, noconstant(0.0)
 DECLARE mf_cs220_ldrpa = f8 WITH protect, noconstant(0.0)
 DECLARE mf_cs220_ldrpb = f8 WITH protect, noconstant(0.0)
 DECLARE mf_cs220_ldrpc = f8 WITH protect, noconstant(0.0)
 DECLARE mf_cs220_obhld = f8 WITH protect, noconstant(0.0)
 DECLARE mf_cs220_wramb = f8 WITH protect, noconstant(0.0)
 DECLARE ml_exp = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_loc = i4 WITH protect, noconstant(0)
 DECLARE mn_ops = i4 WITH protect, noconstant(0)
 DECLARE ml_tot_wait = i4 WITH protect, noconstant(0)
 DECLARE ml_tot_wait_cnt = i4 WITH protect, noconstant(0)
 DECLARE mf_avg_wait = f8 WITH protect, noconstant(0.0)
 DECLARE ml_tot_admit_dec = i4 WITH protect, noconstant(0)
 DECLARE ml_tot_admit_dec_cnt = i4 WITH protect, noconstant(0)
 DECLARE mf_avg_admit_dec = f8 WITH protect, noconstant(0.0)
 DECLARE ml_tot_dec_to_adm = i4 WITH protect, noconstant(0)
 DECLARE ml_tot_dec_to_adm_cnt = i4 WITH protect, noconstant(0)
 DECLARE mf_avg_dec_to_adm = f8 WITH protect, noconstant(0.0)
 DECLARE ml_tot_time_to_disch = i4 WITH protect, noconstant(0)
 DECLARE ml_tot_time_to_disch_cnt = i4 WITH protect, noconstant(0)
 DECLARE mf_avg_time_to_disch = f8 WITH protect, noconstant(0.0)
 DECLARE ml_tot_time_to_other = i4 WITH protect, noconstant(0)
 DECLARE ml_tot_time_to_other_cnt = i4 WITH protect, noconstant(0)
 DECLARE mf_avg_time_to_other = f8 WITH protect, noconstant(0.0)
 DECLARE ml_adm_del_1_3hr = i4 WITH protect, noconstant(0)
 DECLARE ml_adm_del_3_5hr = i4 WITH protect, noconstant(0)
 DECLARE ml_adm_del_gt_5 = i4 WITH protect, noconstant(0)
 EXECUTE bhs_check_domain
 IF (validate(request->batch_selection)=0)
  IF (((textlen(trim( $S_BEG_DT,3))=0) OR (textlen(trim( $S_END_DT,3))=0)) )
   SET ms_log = "Both dates must be filled out"
   GO TO exit_script
  ENDIF
  IF (cnvtdatetime( $S_BEG_DT) > cnvtdatetime( $S_END_DT))
   SET ms_log = "End date must be greater than Beg date"
   GO TO exit_script
  ENDIF
  SET ms_beg_dt_tm = concat(trim( $S_BEG_DT,3)," 00:00:00")
  SET ms_end_dt_tm = concat(trim( $S_END_DT,3)," 23:59:59")
 ELSE
  SET mn_ops = 1
  SET ms_beg_dt_tm = trim(format(datetimefind(cnvtlookbehind("7,D",sysdate),"M","B","B"),
    "dd-mmm-yyyy hh:mm:ss;;d"),3)
  SET ms_end_dt_tm = trim(format(datetimefind(cnvtlookbehind("7,D",sysdate),"M","E","E"),
    "dd-mmm-yyyy hh:mm:ss;;d"),3)
 ENDIF
 CALL echo(build2("beg dt: ",ms_beg_dt_tm," end dt: ",ms_end_dt_tm))
 SELECT INTO "nl:"
  pl_sort =
  IF (cv.display_key="WETU1") 0
  ELSE 1
  ENDIF
  FROM code_value cv
  WHERE cv.code_set=220
   AND cv.active_ind=1
   AND cv.end_effective_dt_tm > sysdate
   AND cv.display_key IN ("WETU1", "LDRPA", "LDRPB", "LDRPC", "OBHLD",
  "WIN2", "WRAMBULATING")
   AND cv.cdf_meaning IN ("AMBULATORY", "NURSEUNIT", "WAITROOM")
  ORDER BY pl_sort, cv.display_key
  HEAD cv.display_key
   IF (cv.display_key="WETU1"
    AND cv.cdf_meaning="AMBULATORY")
    mf_cs220_wetu1 = cv.code_value
   ELSEIF (cv.display_key="LDRPA")
    mf_cs220_ldrpa = cv.code_value
   ELSEIF (cv.display_key="LDRPB")
    mf_cs220_ldrpb = cv.code_value
   ELSEIF (cv.display_key="LDRPC")
    mf_cs220_ldrpc = cv.code_value
   ELSEIF (cv.display_key="OBHLD")
    mf_cs220_obhld = cv.code_value
   ELSEIF (cv.display_key="WRAMBULATING")
    mf_cs220_wramb = cv.code_value,
    CALL alterlist(m_rec->wrooms,1), m_rec->wrooms[1].s_unit = "WETU1",
    m_rec->wrooms[1].f_unit = mf_cs220_wetu1, m_rec->wrooms[1].s_room = trim(uar_get_code_display(cv
      .code_value),3), m_rec->wrooms[1].f_room = mf_cs220_wramb
   ENDIF
  WITH nocounter
 ;end select
 IF (ms_disch_stat="discharged")
  SET ms_disch_parse = " e.disch_dt_tm != null "
 ELSEIF (ms_disch_stat="nondischarged")
  SET ms_disch_parse = " e.disch_dt_tm = null "
 ELSE
  SET ms_disch_parse = " 1=1"
 ENDIF
 SELECT INTO "nl:"
  ps_room = trim(uar_get_code_display(r.location_cd),3)
  FROM code_value cv,
   room r
  PLAN (cv
   WHERE cv.code_set=220
    AND cv.active_ind=1
    AND cv.end_effective_dt_tm > sysdate
    AND cv.display_key IN ("LDRPB", "WIN2", "WETU1"))
   JOIN (r
   WHERE r.loc_nurse_unit_cd=cv.code_value
    AND r.active_ind=1
    AND r.end_effective_dt_tm > sysdate)
  ORDER BY cv.code_value, ps_room
  HEAD REPORT
   pl_cnt = size(m_rec->wrooms,5)
  HEAD cv.code_value
   null
  HEAD ps_room
   IF (((cv.display_key="WETU1"
    AND ps_room="*") OR (cv.display_key != "WETU1")) )
    pl_cnt += 1
    IF (pl_cnt > size(m_rec->wrooms,5))
     CALL alterlist(m_rec->wrooms,(pl_cnt+ 25))
    ENDIF
    m_rec->wrooms[pl_cnt].s_unit = trim(uar_get_code_display(r.loc_nurse_unit_cd),3), m_rec->wrooms[
    pl_cnt].f_unit = r.loc_nurse_unit_cd, m_rec->wrooms[pl_cnt].s_room = trim(uar_get_code_display(r
      .location_cd),3),
    m_rec->wrooms[pl_cnt].f_room = r.location_cd
   ENDIF
  FOOT REPORT
   CALL alterlist(m_rec->wrooms,pl_cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM encounter e,
   encntr_alias ea,
   tracking_item ti,
   tracking_locator tl,
   person p,
   person_alias pa
  PLAN (e
   WHERE e.reg_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
    AND e.med_service_cd IN (mf_cs34_inp_obgyn, mf_cs34_wetu)
    AND e.active_ind=1
    AND parser(ms_disch_parse))
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > sysdate
    AND ea.encntr_alias_type_cd=mf_cs319_fin)
   JOIN (ti
   WHERE ti.encntr_id=e.encntr_id)
   JOIN (tl
   WHERE tl.tracking_id=ti.tracking_id)
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.active_ind=1
    AND pa.end_effective_dt_tm > sysdate
    AND pa.person_alias_type_cd=mf_cs4_cmrn)
  ORDER BY e.encntr_id, ti.tracking_id, tl.arrive_dt_tm,
   tl.tracking_locator_id
  HEAD REPORT
   pl_cnt = 0, pl_loc_cnt = 0
  HEAD e.encntr_id
   pl_loc_cnt = 0, pl_cnt += 1
   IF (pl_cnt > size(m_rec->enc,5))
    CALL alterlist(m_rec->enc,(pl_cnt+ 50))
   ENDIF
   m_rec->enc[pl_cnt].f_person_id = e.person_id, m_rec->enc[pl_cnt].f_encntr_id = e.encntr_id, m_rec
   ->enc[pl_cnt].f_tracking_id = ti.tracking_id,
   m_rec->enc[pl_cnt].s_pat_name = trim(p.name_full_formatted,3), m_rec->enc[pl_cnt].s_cmrn = trim(pa
    .alias,3), m_rec->enc[pl_cnt].s_fin = trim(ea.alias,3)
  HEAD ti.tracking_id
   null
  HEAD tl.arrive_dt_tm
   null
  HEAD tl.tracking_locator_id
   pl_loc_cnt += 1,
   CALL alterlist(m_rec->enc[pl_cnt].loc,pl_loc_cnt), m_rec->enc[pl_cnt].loc[pl_loc_cnt].
   f_tracking_locator_id = tl.tracking_locator_id,
   m_rec->enc[pl_cnt].loc[pl_loc_cnt].f_arrive_dt_tm = tl.arrive_dt_tm, m_rec->enc[pl_cnt].loc[
   pl_loc_cnt].s_arrive_dt_tm = trim(format(tl.arrive_dt_tm,"mm/dd/yy hh:mm;;d"),3), m_rec->enc[
   pl_cnt].loc[pl_loc_cnt].f_depart_dt_tm = tl.depart_dt_tm,
   m_rec->enc[pl_cnt].loc[pl_loc_cnt].s_arrive_dt_tm = trim(format(tl.depart_dt_tm,
     "mm/dd/yy hh:mm;;d"),3), m_rec->enc[pl_cnt].loc[pl_loc_cnt].f_nurse_unit = tl.loc_nurse_unit_cd,
   m_rec->enc[pl_cnt].loc[pl_loc_cnt].s_nurse_unit = trim(uar_get_code_display(tl.loc_nurse_unit_cd),
    3),
   m_rec->enc[pl_cnt].loc[pl_loc_cnt].f_room = tl.loc_room_cd, m_rec->enc[pl_cnt].loc[pl_loc_cnt].
   s_room = trim(uar_get_code_display(tl.loc_room_cd),3)
   CASE (tl.loc_nurse_unit_cd)
    OF mf_cs220_wetu1:
     IF (tl.loc_room_cd=mf_cs220_wrwetu1)
      m_rec->enc[pl_cnt].f_wetu1_dt_tm = tl.arrive_dt_tm, m_rec->enc[pl_cnt].s_wetu1_dt_tm = trim(
       format(tl.arrive_dt_tm,"mm/dd/yy hh:mm;;d"),3), m_rec->enc[pl_cnt].n_wetu = 1
     ELSEIF (locateval(ml_loc,1,size(m_rec->wrooms,5),tl.loc_room_cd,m_rec->wrooms[ml_loc].f_room,
      tl.loc_nurse_unit_cd,mf_cs220_wetu1) > 0)
      IF ((m_rec->enc[pl_cnt].f_obhld_dt_tm=0.0))
       m_rec->enc[pl_cnt].f_wroom_dt_tm = tl.arrive_dt_tm, m_rec->enc[pl_cnt].s_wroom_dt_tm = trim(
        format(tl.arrive_dt_tm,"mm/dd/yy hh:mm;;d"),3)
      ENDIF
     ENDIF
    OF mf_cs220_obhld:
     m_rec->enc[pl_cnt].s_obhld_admit_dt_tm = trim(format(tl.arrive_dt_tm,"mm/dd/yyyy hh:mm;;d"),3),
     m_rec->enc[pl_cnt].f_obhld_dt_tm = tl.arrive_dt_tm,m_rec->enc[pl_cnt].s_obhld_dt_tm = trim(
      format(tl.arrive_dt_tm,"mm/dd/yyyy hh:mm;;d"),3)
    OF mf_cs220_ldrpa:
     IF ((m_rec->enc[pl_cnt].f_ldr_dt_tm=0.0))
      m_rec->enc[pl_cnt].f_ldr_dt_tm = tl.arrive_dt_tm, m_rec->enc[pl_cnt].s_ldr_dt_tm = trim(format(
        tl.arrive_dt_tm,"mm/dd/yyyy hh:mm;;d"),3)
     ENDIF
    OF mf_cs220_ldrpb:
     IF ((m_rec->enc[pl_cnt].f_ldr_dt_tm=0.0))
      m_rec->enc[pl_cnt].f_ldr_dt_tm = tl.arrive_dt_tm, m_rec->enc[pl_cnt].s_ldr_dt_tm = trim(format(
        tl.arrive_dt_tm,"mm/dd/yyyy hh:mm;;d"),3)
     ENDIF
    OF mf_cs220_ldrpc:
     IF ((m_rec->enc[pl_cnt].f_ldr_dt_tm=0.0))
      m_rec->enc[pl_cnt].f_ldr_dt_tm = tl.arrive_dt_tm, m_rec->enc[pl_cnt].s_ldr_dt_tm = trim(format(
        tl.arrive_dt_tm,"mm/dd/yyyy hh:mm;;d"),3)
     ENDIF
    ELSE
     IF (locateval(ml_loc,1,size(m_rec->wrooms,5),tl.loc_room_cd,m_rec->wrooms[ml_loc].f_room)=0)
      m_rec->enc[pl_cnt].f_non_wroom_dt_tm = tl.arrive_dt_tm, m_rec->enc[pl_cnt].s_non_wroom_dt_tm =
      trim(format(tl.arrive_dt_tm,"mm/dd/yyyy hh:mm;;d"),3)
     ENDIF
   ENDCASE
  FOOT  ti.tracking_id
   m_rec->enc[pl_cnt].l_wait_time = datetimediff(m_rec->enc[pl_cnt].f_wroom_dt_tm,m_rec->enc[pl_cnt].
    f_wetu1_dt_tm,4), m_rec->enc[pl_cnt].s_wait_time = trim(cnvtstring(m_rec->enc[pl_cnt].l_wait_time
     ),3), m_rec->enc[pl_cnt].l_wetu_admit_time = datetimediff(m_rec->enc[pl_cnt].f_obhld_dt_tm,m_rec
    ->enc[pl_cnt].f_wroom_dt_tm,4),
   m_rec->enc[pl_cnt].s_wetu_admit_time = trim(cnvtstring(m_rec->enc[pl_cnt].l_wetu_admit_time),3),
   m_rec->enc[pl_cnt].l_ldrp_admit_delay = datetimediff(m_rec->enc[pl_cnt].f_ldr_dt_tm,m_rec->enc[
    pl_cnt].f_obhld_dt_tm,4), m_rec->enc[pl_cnt].s_ldrp_admit_delay = trim(cnvtstring(m_rec->enc[
     pl_cnt].l_ldrp_admit_delay),3)
   IF ((m_rec->enc[pl_cnt].f_ldr_dt_tm=0.0)
    AND e.disch_dt_tm != null)
    m_rec->enc[pl_cnt].l_wetu_disch_time = datetimediff(e.disch_dt_tm,m_rec->enc[pl_cnt].
     f_wroom_dt_tm,4), m_rec->enc[pl_cnt].s_wetu_disch_time = trim(cnvtstring(m_rec->enc[pl_cnt].
      l_wetu_disch_time),3)
   ENDIF
   IF ((m_rec->enc[pl_cnt].f_non_wroom_dt_tm > 0.0))
    m_rec->enc[pl_cnt].l_wetu_gyn_time = datetimediff(m_rec->enc[pl_cnt].f_non_wroom_dt_tm,m_rec->
     enc[pl_cnt].f_wroom_dt_tm,4), m_rec->enc[pl_cnt].s_wetu_gyn_time = trim(cnvtstring(m_rec->enc[
      pl_cnt].l_wetu_gyn_time),3)
   ENDIF
  FOOT REPORT
   CALL alterlist(m_rec->enc,pl_cnt)
  WITH nocounter
 ;end select
 IF (size(m_rec->enc,5)=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  pl_sort =
  IF (pi.info_sub_type_cd=mf_cs356_race1) 1
  ELSEIF (pi.info_sub_type_cd=mf_cs356_race2) 2
  ELSEIF (pi.info_sub_type_cd=mf_cs356_race3) 3
  ELSEIF (pi.info_sub_type_cd=mf_cs356_race4) 4
  ELSEIF (pi.info_sub_type_cd=mf_cs356_race5) 5
  ELSE 9
  ENDIF
  FROM (dummyt d  WITH seq = value(size(m_rec->enc,5))),
   person p,
   person_info pi
  PLAN (d
   WHERE (m_rec->enc[d.seq].f_person_id > 0.0))
   JOIN (p
   WHERE (p.person_id=m_rec->enc[d.seq].f_person_id))
   JOIN (pi
   WHERE pi.person_id=p.person_id
    AND pi.active_ind=1
    AND pi.end_effective_dt_tm > sysdate
    AND pi.info_type_cd=mf_cs355_user_def
    AND pi.info_sub_type_cd IN (mf_cs356_race1, mf_cs356_race2, mf_cs356_race3, mf_cs356_race4,
   mf_cs356_race5,
   mf_cs356_ethnicity))
  ORDER BY d.seq, pl_sort, pi.info_sub_type_cd,
   pi.beg_effective_dt_tm DESC
  HEAD p.person_id
   null
  HEAD pi.info_sub_type_cd
   IF (pi.info_sub_type_cd IN (mf_cs356_race1, mf_cs356_race2, mf_cs356_race3, mf_cs356_race4,
   mf_cs356_race5))
    IF (textlen(trim(m_rec->enc[d.seq].s_race,3))=0)
     m_rec->enc[d.seq].s_race = trim(uar_get_code_display(pi.value_cd),3)
    ELSEIF (pi.value_cd > 0.0)
     m_rec->enc[d.seq].s_race = concat(m_rec->enc[d.seq].s_race,", ",trim(uar_get_code_display(pi
        .value_cd),3))
    ENDIF
   ELSEIF (pi.info_sub_type_cd=mf_cs356_ethnicity)
    IF (p.ethnic_grp_cd > 0.0)
     m_rec->enc[d.seq].s_ethnicity = trim(uar_get_code_display(p.ethnic_grp_cd),3)
    ELSEIF (pi.info_sub_type_cd=mf_cs356_ethnicity)
     m_rec->enc[d.seq].s_ethnicity = trim(uar_get_code_display(pi.value_cd),3)
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM clinical_event ce
  PLAN (ce
   WHERE expand(ml_exp,1,size(m_rec->enc,5),ce.encntr_id,m_rec->enc[ml_exp].f_encntr_id)
    AND ce.event_cd IN (mf_cs72_ob_prov_grp, mf_cs72_ega_doc)
    AND ce.result_status_cd IN (mf_cs8_auth, mf_cs8_mod, mf_cs8_alter, mf_cs8_active)
    AND ce.valid_until_dt_tm > sysdate)
  ORDER BY ce.encntr_id, ce.event_cd, ce.event_end_dt_tm DESC
  HEAD ce.encntr_id
   ml_idx = locatevalsort(ml_loc,1,size(m_rec->enc,5),ce.encntr_id,m_rec->enc[ml_loc].f_encntr_id)
  HEAD ce.event_cd
   IF (ce.event_cd=mf_cs72_ob_prov_grp)
    m_rec->enc[ml_idx].s_bmc_provider_group = trim(ce.result_val,3)
   ELSEIF (ce.event_cd=mf_cs72_ega_doc)
    m_rec->enc[ml_idx].s_ega = trim(ce.result_val,3)
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(m_rec->enc,5)))
  ORDER BY d.seq
  HEAD REPORT
   null
  HEAD d.seq
   IF ((m_rec->enc[d.seq].l_wait_time > 0))
    ml_tot_wait += m_rec->enc[d.seq].l_wait_time, ml_tot_wait_cnt += 1
   ENDIF
   IF ((m_rec->enc[d.seq].l_wetu_admit_time > 0))
    ml_tot_admit_dec += m_rec->enc[d.seq].l_wetu_admit_time, ml_tot_admit_dec_cnt += 1
   ENDIF
   IF ((m_rec->enc[d.seq].l_ldrp_admit_delay > 0))
    ml_tot_dec_to_adm += m_rec->enc[d.seq].l_ldrp_admit_delay, ml_tot_dec_to_adm_cnt += 1
   ENDIF
   IF ((m_rec->enc[d.seq].l_wetu_disch_time > 0))
    ml_tot_time_to_disch += m_rec->enc[d.seq].l_wetu_disch_time, ml_tot_time_to_disch_cnt += 1
   ENDIF
   IF ((m_rec->enc[d.seq].l_wetu_gyn_time > 0))
    ml_tot_time_to_other += m_rec->enc[d.seq].l_wetu_gyn_time, ml_tot_time_to_other_cnt += 1
   ENDIF
   IF ((m_rec->enc[d.seq].l_ldrp_admit_delay BETWEEN 60 AND 180))
    ml_adm_del_1_3hr += 1
   ELSEIF ((m_rec->enc[d.seq].l_ldrp_admit_delay BETWEEN 181 AND 300))
    ml_adm_del_3_5hr += 1
   ELSEIF ((m_rec->enc[d.seq].l_ldrp_admit_delay > 300))
    ml_adm_del_gt_5 += 1
   ENDIF
  FOOT REPORT
   ml_idx = size(m_rec->enc,5)
   IF (ml_tot_wait_cnt > 0)
    mf_avg_wait = (cnvtreal(ml_tot_wait)/ cnvtreal(ml_tot_wait_cnt))
   ENDIF
   IF (ml_tot_admit_dec_cnt > 0)
    mf_avg_admit_dec = (cnvtreal(ml_tot_admit_dec)/ cnvtreal(ml_tot_admit_dec_cnt))
   ENDIF
   IF (ml_tot_dec_to_adm_cnt > 0)
    mf_avg_dec_to_adm = (cnvtreal(ml_tot_dec_to_adm)/ cnvtreal(ml_tot_dec_to_adm_cnt))
   ENDIF
   IF (ml_tot_time_to_disch_cnt > 0)
    mf_avg_time_to_disch = (cnvtreal(ml_tot_time_to_disch)/ cnvtreal(ml_tot_time_to_disch_cnt))
   ENDIF
   IF (ml_tot_time_to_other_cnt > 0)
    mf_avg_time_to_other = (cnvtreal(ml_tot_time_to_other)/ cnvtreal(ml_tot_time_to_other_cnt))
   ENDIF
   ml_idx += 2,
   CALL alterlist(m_rec->enc,ml_idx), m_rec->enc[(ml_idx - 1)].n_wetu = 1,
   m_rec->enc[ml_idx].n_wetu = 1, m_rec->enc[ml_idx].s_pat_name = "Summary", m_rec->enc[ml_idx].
   s_cmrn = "LDRP Admission Delay 1-3 hrs",
   m_rec->enc[ml_idx].s_fin = "LDRP Admission Delay 3-5 hrs", m_rec->enc[ml_idx].s_bmc_provider_group
    = "LDRP Admission Delay >5 hrs", m_rec->enc[ml_idx].s_wait_time = "Avg wait time",
   m_rec->enc[ml_idx].s_wetu_admit_time = "Avg admit decision time", m_rec->enc[ml_idx].
   s_ldrp_admit_delay = "Avg decision to admit time", m_rec->enc[ml_idx].s_wetu_disch_time =
   "Avg time until disch",
   m_rec->enc[ml_idx].s_wetu_gyn_time = "Avg time to other admit", ml_idx += 1,
   CALL alterlist(m_rec->enc,ml_idx),
   m_rec->enc[ml_idx].n_wetu = 1, m_rec->enc[ml_idx].s_cmrn = trim(cnvtstring(ml_adm_del_1_3hr),3),
   m_rec->enc[ml_idx].s_fin = trim(cnvtstring(ml_adm_del_3_5hr),3),
   m_rec->enc[ml_idx].s_bmc_provider_group = trim(cnvtstring(ml_adm_del_gt_5),3), m_rec->enc[ml_idx].
   s_wait_time = concat(trim(cnvtstring(mf_avg_wait),3)," mins"), m_rec->enc[ml_idx].
   s_wetu_admit_time = concat(trim(cnvtstring(mf_avg_admit_dec),3)," mins"),
   m_rec->enc[ml_idx].s_ldrp_admit_delay = concat(trim(cnvtstring(mf_avg_dec_to_adm),3)," mins"),
   m_rec->enc[ml_idx].s_wetu_disch_time = concat(trim(cnvtstring(mf_avg_time_to_disch),3)," mins"),
   m_rec->enc[ml_idx].s_wetu_gyn_time = concat(trim(cnvtstring(mf_avg_time_to_other),3)," mins")
  WITH nocounter
 ;end select
 IF (mn_ops=0)
  SELECT INTO value( $OUTDEV)
   patient_name = substring(1,75,m_rec->enc[d.seq].s_pat_name), cmrn = substring(1,50,m_rec->enc[d
    .seq].s_cmrn), fin = substring(1,50,m_rec->enc[d.seq].s_fin),
   race = substring(1,50,m_rec->enc[d.seq].s_race), hispanic = substring(1,25,m_rec->enc[d.seq].
    s_ethnicity), bmc_provider_group = substring(1,75,m_rec->enc[d.seq].s_bmc_provider_group),
   ega = substring(1,25,m_rec->enc[d.seq].s_ega), decision_to_admit_dt_tm = substring(1,16,trim(
     format(m_rec->enc[d.seq].f_obhld_dt_tm,"mm/dd/yyyy hh:mm;;d"),3)), wait_time = substring(1,25,
    m_rec->enc[d.seq].s_wait_time),
   wetu_eval_time_admit = substring(1,25,m_rec->enc[d.seq].s_wetu_admit_time), ldrp_delay = substring
   (1,26,m_rec->enc[d.seq].s_ldrp_admit_delay), wetu_los_dc = substring(1,25,m_rec->enc[d.seq].
    s_wetu_disch_time),
   time_to_other_admit = substring(1,25,m_rec->enc[d.seq].s_wetu_gyn_time)
   FROM (dummyt d  WITH seq = value(size(m_rec->enc,5)))
   PLAN (d
    WHERE (m_rec->enc[d.seq].n_wetu=1))
   WITH nocounter, format, separator = " ",
    maxrow = 1
  ;end select
 ELSE
  SET ms_file_name = concat("bhs_rpt_wetu_wait_time_",trim(format(sysdate,"mmddyyhhmm;;d"),3),".csv")
  CALL echo(ms_file_name)
  CALL echo("CCLIO")
  IF (size(m_rec->enc,5) > 0)
   SET frec->file_name = concat(ms_file_name)
   SET stat = cclio("OPEN",frec)
   SET ms_tmp = concat('"patient_name","cmrn","fin","race","hispanic","bmc_provider_group","ega",',
    '"decision_to_admit_dt_tm","wait_time","wetu_eval_time_admit","ldrp_delay","wetu_los_dc",',
    '"time_to_other_admit"')
   SET frec->file_buf = concat(ms_tmp,char(13),char(10))
   SET stat = cclio("WRITE",frec)
   FOR (ml_loop = 1 TO size(m_rec->enc,5))
     SET ms_tmp = concat('"',m_rec->enc[ml_loop].s_pat_name,'",','"',m_rec->enc[ml_loop].s_cmrn,
      '",','"',m_rec->enc[ml_loop].s_fin,'",','"',
      m_rec->enc[ml_loop].s_race,'",','"',m_rec->enc[ml_loop].s_ethnicity,'",',
      '"',m_rec->enc[ml_loop].s_bmc_provider_group,'",','"',m_rec->enc[ml_loop].s_ega,
      '",','"',trim(format(m_rec->enc[ml_loop].f_obhld_dt_tm,"mm/dd/yyyy hh:mm;;d"),3),'",','"',
      m_rec->enc[ml_loop].s_wait_time,'",','"',m_rec->enc[ml_loop].s_wetu_admit_time,'",',
      '"',m_rec->enc[ml_loop].s_ldrp_admit_delay,'",','"',m_rec->enc[ml_loop].s_wetu_disch_time,
      '",','"',m_rec->enc[ml_loop].s_wetu_gyn_time,'"')
     SET frec->file_buf = concat(ms_tmp,char(13),char(10))
     SET stat = cclio("WRITE",frec)
   ENDFOR
   SET stat = cclio("CLOSE",frec)
   EXECUTE bhs_ma_email_file
   SET ms_tmp = concat("WETU Wait Times for range: ",ms_beg_dt_tm," - ",ms_end_dt_tm)
   CALL emailfile(value(ms_file_name),ms_file_name,"WETUQualityReports@baystatehealth.org",ms_tmp,1)
  ENDIF
 ENDIF
 SET reply->status_data[1].status = "S"
#exit_script
 FREE RECORD m_rec
END GO
