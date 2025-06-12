CREATE PROGRAM bhs_rpt_flu_vax_progress:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin Date:" = "",
  "End Date:" = "CURDATE"
  WITH outdev, s_beg_dt, s_end_dt
 FREE RECORD m_rec
 RECORD m_rec(
   1 pcp[*]
     2 f_pcp_id = f8
     2 s_pcp_name = vc
     2 s_pcp_practice = vc
     2 l_admin_tot = i4
     2 l_doc_tot = i4
     2 l_tot_pcp_pats = i4
     2 s_percent_vax = vc
     2 vax[*]
       3 f_person_id = f8
       3 f_encntr_id = f8
       3 s_admin_loc = vc
       3 n_admin = i2
       3 n_doc_only = i2
 ) WITH protect
 FREE RECORD frec
 RECORD frec(
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
   1 file_name = vc
   1 file_buf = vc
 )
 IF (validate(reply->status_data[1].status)=0)
  RECORD reply(
    1 status_data[1]
      2 status = c1
  )
 ENDIF
 SET reply->status_data[1].status = "F"
 DECLARE mf_cs8_auth = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2628"))
 DECLARE mf_cs8_mod = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2636"))
 DECLARE mf_cs8_alter = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!16901"))
 DECLARE mf_cs72_fluvax_inact = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "INFLUENZAVIRUSVACCINEINACTIVATED"))
 DECLARE mf_cs72_fluvax_live = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "INFLUENZAVIRUSVACCINELIVE"))
 DECLARE mf_cs200_fluvax_inact = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "INFLUENZAVIRUSVACCINEINACTIVATED"))
 DECLARE mf_cs200_fluvax_live = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "INFLUENZAVIRUSVACCINELIVE"))
 CALL echo(build2("mf_CS72_FLUVAX_INACT: ",mf_cs72_fluvax_inact))
 CALL echo(build2("mf_CS72_FLUVAX_LIVE: ",mf_cs72_fluvax_live))
 CALL echo(build2("mf_CS200_FLUVAX_INACT: ",mf_cs200_fluvax_inact))
 CALL echo(build2("mf_CS200_FLUVAX_LIVE: ",mf_cs200_fluvax_live))
 DECLARE mf_cs331_pcp = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!4593"))
 CALL echo(build2("mf_CS331_PCP: ",mf_cs331_pcp))
 DECLARE mf_cs333_pcp = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",333,
   "PRIMARYCAREPHYSICIAN"))
 CALL echo(build2("mf_CS333_PCP: ",mf_cs333_pcp))
 DECLARE ms_beg_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_end_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE mn_ops = i2 WITH protect, noconstant(0)
 DECLARE ms_filename = vc WITH protect, noconstant(" ")
 DECLARE mf_tmp = f8 WITH protect, noconstant(0.0)
 DECLARE ml_tmp = i4 WITH protect, noconstant(0)
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 IF (validate(request->batch_selection)=0)
  CALL echo("not ops1")
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
  CALL echo("ops")
  SET mn_ops = 1
  SET ms_beg_dt_tm = "01-sep-2021"
  SET ms_end_dt_tm = trim(format(datetimefind(cnvtlookbehind("1,D",sysdate),"D","E","E"),
    "dd-mmm-yyyy hh:mm:ss;;d"),3)
 ENDIF
 CALL echo(build2("beg dt: ",ms_beg_dt_tm," end dt: ",ms_end_dt_tm))
 SELECT INTO "nl:"
  FROM clinical_event ce,
   encounter e,
   encntr_prsnl_reltn epr,
   prsnl pr,
   bhs_physician_location bphy,
   bhs_practice_location bpra
  PLAN (ce
   WHERE ce.event_end_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
    AND ce.event_cd IN (mf_cs72_fluvax_inact, mf_cs72_fluvax_live, mf_cs200_fluvax_inact,
   mf_cs200_fluvax_live)
    AND ce.result_status_cd IN (mf_cs8_auth, mf_cs8_mod, mf_cs8_alter)
    AND ce.valid_until_dt_tm > sysdate)
   JOIN (e
   WHERE e.encntr_id=ce.encntr_id)
   JOIN (epr
   WHERE epr.encntr_id=ce.encntr_id
    AND epr.active_ind=1
    AND epr.end_effective_dt_tm >= e.reg_dt_tm
    AND epr.encntr_prsnl_r_cd=mf_cs333_pcp)
   JOIN (pr
   WHERE pr.person_id=epr.prsnl_person_id)
   JOIN (bphy
   WHERE (bphy.person_id= Outerjoin(pr.person_id)) )
   JOIN (bpra
   WHERE (bpra.location_id= Outerjoin(bphy.location_id)) )
  ORDER BY pr.person_id, e.encntr_id, ce.event_end_dt_tm DESC,
   ce.event_id
  HEAD REPORT
   pl_phys_cnt = 0, pl_cnt = 0
  HEAD pr.person_id
   pl_cnt = 0, pl_phys_cnt += 1,
   CALL alterlist(m_rec->pcp,pl_phys_cnt),
   m_rec->pcp[pl_phys_cnt].f_pcp_id = pr.person_id, m_rec->pcp[pl_phys_cnt].s_pcp_name = trim(pr
    .name_full_formatted,3)
   IF (bpra.location_id > 0.0)
    m_rec->pcp[pl_phys_cnt].s_pcp_practice = trim(bpra.location_description,3)
   ENDIF
  HEAD e.encntr_id
   null
  HEAD ce.event_end_dt_tm
   null
  HEAD ce.event_id
   pl_cnt += 1
   IF (pl_cnt > size(m_rec->pcp[pl_phys_cnt].vax,5))
    CALL alterlist(m_rec->pcp[pl_phys_cnt].vax,(pl_cnt+ 10))
   ENDIF
   m_rec->pcp[pl_phys_cnt].vax[pl_cnt].f_person_id = e.person_id, m_rec->pcp[pl_phys_cnt].vax[pl_cnt]
   .f_encntr_id = e.encntr_id
   IF (ce.event_cd IN (mf_cs72_fluvax_inact, mf_cs72_fluvax_live))
    m_rec->pcp[pl_phys_cnt].l_doc_tot += 1, m_rec->pcp[pl_phys_cnt].vax[pl_cnt].n_doc_only = 1
   ELSEIF (ce.event_cd IN (mf_cs200_fluvax_inact, mf_cs200_fluvax_live))
    m_rec->pcp[pl_phys_cnt].l_admin_tot += 1, m_rec->pcp[pl_phys_cnt].vax[pl_cnt].n_admin = 1, m_rec
    ->pcp[pl_phys_cnt].vax[pl_cnt].s_admin_loc = trim(uar_get_code_display(e.loc_nurse_unit_cd),3)
   ENDIF
  FOOT  pr.person_id
   CALL alterlist(m_rec->pcp[pl_phys_cnt].vax,pl_cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(m_rec->pcp,5))),
   person_prsnl_reltn ppr
  PLAN (d)
   JOIN (ppr
   WHERE (ppr.prsnl_person_id=m_rec->pcp[d.seq].f_pcp_id)
    AND ppr.active_ind=1
    AND ppr.end_effective_dt_tm > sysdate
    AND ppr.person_prsnl_r_cd=mf_cs331_pcp)
  ORDER BY d.seq, ppr.person_id
  HEAD ppr.person_id
   m_rec->pcp[d.seq].l_tot_pcp_pats += 1
  FOOT  d.seq
   ml_tmp = (m_rec->pcp[d.seq].l_admin_tot+ m_rec->pcp[d.seq].l_doc_tot), mf_tmp = (cnvtreal(ml_tmp)
   / cnvtreal(m_rec->pcp[d.seq].l_tot_pcp_pats)), m_rec->pcp[d.seq].s_percent_vax = concat(trim(
     format(abs(mf_tmp),"####.##;r"),3),"%")
  WITH nocounter
 ;end select
 IF (mn_ops=0)
  CALL echo("not ops")
  SELECT INTO value( $OUTDEV)
   pcp = m_rec->pcp[d.seq].s_pcp_name, ambulatory_location = m_rec->pcp[d.seq].s_pcp_practice,
   flu_vaccines_administered = m_rec->pcp[d.seq].l_admin_tot,
   flu_vaccines_documented = m_rec->pcp[d.seq].l_doc_tot, total_vaccines_for_this_flu_season = (m_rec
   ->pcp[d.seq].l_admin_tot+ m_rec->pcp[d.seq].l_doc_tot), pcp_total_pats = m_rec->pcp[d.seq].
   l_tot_pcp_pats,
   pcp_pats_vaccinnated = m_rec->pcp[d.seq].s_percent_vax
   FROM (dummyt d  WITH seq = value(size(m_rec->pcp,5)))
   PLAN (d)
   ORDER BY pcp
   WITH nocounter, format, separator = " ",
    maxrow = 1
  ;end select
 ELSE
  CALL echo("create file")
  SET ms_filename = concat("bhs_rpt_flu_progress_",trim(format(sysdate,"mmddyyhhmm;;d"),3),".csv")
  CALL echo(build2("ms_filename: ",ms_filename))
  IF (size(m_rec->pcp,5))
   SET frec->file_name = ms_filename
   SET frec->file_buf = "w"
   SET stat = cclio("OPEN",frec)
   SET ms_tmp = concat(
    '"pcp","ambulatory_location","flu_vaccines_administered","flu_vaccines_documented"',
    '"total_vaccines_for_this_flu_season","pcp_total_pats","pcp_pats_vaccinnated"')
   SET frec->file_buf = concat(ms_tmp,char(13),char(10))
   SET stat = cclio("WRITE",frec)
   FOR (ml_loop = 1 TO size(m_rec->pcp,5))
     SET ms_tmp = concat('"',m_rec->pcp[ml_loop].s_pcp_name,'",','"',m_rec->pcp[ml_loop].
      s_pcp_practice,
      '",','"',trim(cnvtstring(m_rec->pcp[ml_loop].l_admin_tot)),'",','"',
      trim(cnvtstring(m_rec->pcp[ml_loop].l_doc_tot)),'",','"',trim(cnvtstring((m_rec->pcp[ml_loop].
        l_admin_tot+ m_rec->pcp[ml_loop].l_doc_tot))),'",',
      '"',trim(cnvtstring(m_rec->pcp[ml_loop].l_tot_pcp_pats)),'",','"',m_rec->pcp[ml_loop].
      s_percent_vax,
      '"')
     SET frec->file_buf = concat(ms_tmp,char(13),char(10))
     SET stat = cclio("WRITE",frec)
   ENDFOR
   SET stat = cclio("CLOSE",frec)
   EXECUTE bhs_ma_email_file
   SET ms_tmp = concat("Flu Progress 1-SEP-2021 to ",ms_end_dt_tm)
   CALL echo(build2("subject: ",ms_tmp))
   CALL emailfile(value(ms_filename),ms_filename,
    "glenn.alli@@baystatehealth.org, joe.echols@baystatehealth.org",ms_tmp,1)
  ENDIF
 ENDIF
 SET reply->status_data[1].status = "S"
#exit_script
 FREE RECORD m_rec
END GO
