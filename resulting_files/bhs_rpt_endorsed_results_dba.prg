CREATE PROGRAM bhs_rpt_endorsed_results:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin Date Time" = "SYSDATE",
  "End Date Time" = "SYSDATE",
  "Email file" = ""
  WITH outdev, s_beg_dt_tm, s_end_dt_tm,
  s_email
 EXECUTE bhs_check_domain:dba
 EXECUTE bhs_hlp_ccl
 FREE RECORD m_rec
 RECORD m_rec(
   1 res[*]
     2 f_order_id = f8
     2 s_reference_nbr = vc
     2 f_parent_event_id = f8
     2 n_donot_release_ind = i2
     2 s_cmrn = vc
     2 s_fin = vc
     2 s_comment = vc
     2 f_contr_sys_cd = f8
     2 s_contr_sys_display = vc
     2 s_alias = vc
     2 f_order_ctlg_type_cd = f8
     2 s_order_ctlg_type_display = vc
 ) WITH protect
 IF (validate(reply)=0)
  RECORD reply(
    1 status_data[1]
      2 status = c1
  )
 ENDIF
 SET reply->status_data[1].status = "F"
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_cmrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"CMRN"))
 DECLARE mf_endorse_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",21,"ENDORSE"))
 DECLARE mf_endorse_save_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",21,"ENDORSESAVE"))
 DECLARE mf_perform_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",21,"PERFORM"))
 DECLARE mf_completed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",103,"COMPLETED"))
 DECLARE mf_refused_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",103,"REFUSED"))
 DECLARE ms_dm_info_domain = vc WITH protect, constant("BHS_RPT_ENDORSED_RESULTS")
 DECLARE ms_dm_info_name = vc WITH protect, constant("LAB_ENDORSEMENTS_STOP_DT_TM")
 DECLARE ml_job_max_hrs = f8 WITH protect, constant(8)
 DECLARE mf_activecmtyofficevisit_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "ACTIVECMTYOFFICEVISIT"))
 DECLARE mf_daystay_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"DAYSTAY"))
 DECLARE mf_dischdaystay_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "DISCHDAYSTAY"))
 DECLARE mf_dischrecurofficevisit_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "DISCHRECUROFFICEVISIT"))
 DECLARE mf_dischrecurringop_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "DISCHRECURRINGOP"))
 DECLARE mf_dischargedoutpatient_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "DISCHARGEDOUTPATIENT"))
 DECLARE mf_officevisit_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"OFFICEVISIT")
  )
 DECLARE mf_onetimeop_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"ONETIMEOP"))
 DECLARE mf_outpatient_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"OUTPATIENT"))
 DECLARE mf_outpatientonetime_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "OUTPATIENTONETIME"))
 DECLARE mf_outpatientrecurring_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "OUTPATIENTRECURRING"))
 DECLARE mf_preoutpatientonetime_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "PREOUTPATIENTONETIME"))
 DECLARE mf_preoutpt_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"PREOUTPT"))
 DECLARE mf_preadmitdaystay_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "PREADMITDAYSTAY"))
 DECLARE mf_preadmitip_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"PREADMITIP"))
 DECLARE mf_recurofficevisit_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "RECUROFFICEVISIT"))
 DECLARE mf_recurringop_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"RECURRINGOP")
  )
 DECLARE mf_smri_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"SMRI"))
 DECLARE ms_laboratory = vc WITH protect, constant("LABORATORY")
 DECLARE ms_cardiovasculartest = vc WITH protect, constant("CARDIOVASCULAR TEST")
 DECLARE ms_neuromuscular = vc WITH protect, constant("NEUROMUSCULAR")
 DECLARE ms_pulmonaryresults = vc WITH protect, constant("PULMONARY RESULTS")
 DECLARE ms_radiology = vc WITH protect, constant("RADIOLOGY")
 DECLARE mf_authverified_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",8,"AUTHVERIFIED"
   ))
 DECLARE mf_altered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE mf_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_ord_completed_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,
   "COMPLETED"))
 DECLARE ms_filename = vc WITH protect, noconstant(concat("bhs_labs_",trim(format(sysdate,
     "mmddyyhhmm;;d")),".csv"))
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ms_beg_dt_tm = vc WITH protect, noconstant( $S_BEG_DT_TM)
 DECLARE ms_end_dt_tm = vc WITH protect, noconstant( $S_END_DT_TM)
 DECLARE ms_recipients = vc WITH protect, noconstant(trim( $S_EMAIL))
 DECLARE mn_ops = i2 WITH protect, noconstant(0)
 DECLARE mn_test = i2 WITH protect, noconstant(0)
 DECLARE ms_msg = vc WITH protect, noconstant(" ")
 DECLARE ms_dcl = vc WITH protect, noconstant(" ")
 DECLARE mn_rows_found = i2 WITH protect, noconstant(0)
 DECLARE ms_lookback_interval_beg = vc WITH protect, noconstant(" ")
 DECLARE ms_lookback_interval_end = vc WITH protect, noconstant(" ")
 IF (gl_bhs_prod_flag=0)
  SET mn_test = 1
 ENDIF
 IF (textlen(ms_recipients) > 0)
  IF (findstring("@",ms_recipients)=0)
   SET ms_msg = "Recipient email is invalid"
   GO TO exit_script
  ENDIF
 ENDIF
 IF (((validate(request->batch_selection)) OR (mn_ops=1)) )
  SET mn_ops = 1
  SELECT INTO "nl:"
   FROM dm_info d
   WHERE d.info_domain=ms_dm_info_domain
    AND d.info_name=ms_dm_info_name
   DETAIL
    ms_beg_dt_tm = trim(format(d.info_date,"dd-mmm-yyyy hh:mm:ss;;d"))
   WITH nocounter
  ;end select
  IF (curqual < 1)
   SET ms_msg = "001 - DM_INFO row not found"
   GO TO send_page
  ENDIF
  IF (datetimediff(sysdate,cnvtdatetime(ms_beg_dt_tm),3) > ml_job_max_hrs)
   SET ms_msg = concat("002 - Last job ended over ",trim(cnvtstring(ml_job_max_hrs)),"hrs ago")
   GO TO send_page
  ENDIF
  SET ms_end_dt_tm = trim(format(sysdate,"dd-mmm-yyyy hh:mm:ss;;d"))
  SET ms_recipients = "oleksiy.kononenko@bhs.org"
  CASE (weekday(curdate))
   OF 0:
    SET ms_lookback_interval_beg = "5,D"
   OF 1:
    SET ms_lookback_interval_beg = "6,D"
   OF 2:
    SET ms_lookback_interval_beg = "6,D"
   OF 3:
    SET ms_lookback_interval_beg = "6,D"
   OF 4:
    SET ms_lookback_interval_beg = "6,D"
   OF 5:
    SET ms_lookback_interval_beg = "4,D"
   OF 6:
    SET ms_lookback_interval_beg = "4,D"
  ENDCASE
  SET ms_lookback_interval_end = ms_lookback_interval_beg
 ELSE
  IF (((textlen(trim(ms_beg_dt_tm))=0) OR (textlen(trim(ms_end_dt_tm))=0)) )
   SET ms_msg = "Warning: For non-ops runs of this script, you have to enter a date range - Exiting"
   GO TO exit_script
  ELSEIF (cnvtdatetime(ms_end_dt_tm) <= cnvtdatetime(ms_beg_dt_tm))
   SET ms_msg = "End Date must be later than Begin Date - Exiting"
   GO TO exit_script
  ENDIF
  CASE (weekday(cnvtdatetime(ms_beg_dt_tm)))
   OF 0:
    SET ms_lookback_interval_beg = "5,D"
   OF 1:
    SET ms_lookback_interval_beg = "6,D"
   OF 2:
    SET ms_lookback_interval_beg = "6,D"
   OF 3:
    SET ms_lookback_interval_beg = "6,D"
   OF 4:
    SET ms_lookback_interval_beg = "6,D"
   OF 5:
    SET ms_lookback_interval_beg = "4,D"
   OF 6:
    SET ms_lookback_interval_beg = "4,D"
  ENDCASE
  CASE (weekday(cnvtdatetime(ms_end_dt_tm)))
   OF 0:
    SET ms_lookback_interval_end = "5,D"
   OF 1:
    SET ms_lookback_interval_end = "6,D"
   OF 2:
    SET ms_lookback_interval_end = "6,D"
   OF 3:
    SET ms_lookback_interval_end = "6,D"
   OF 4:
    SET ms_lookback_interval_end = "6,D"
   OF 5:
    SET ms_lookback_interval_end = "4,D"
   OF 6:
    SET ms_lookback_interval_end = "4,D"
  ENDCASE
 ENDIF
 SELECT DISTINCT INTO "nl:"
  ce.parent_event_id
  FROM ce_event_prsnl cep,
   clinical_event ce,
   clinical_event ce2,
   encntr_alias ea,
   person_alias pa,
   code_value_alias cva,
   orders o
  PLAN (cep
   WHERE cep.action_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
    AND cep.action_status_cd=mf_completed_cd
    AND cep.action_type_cd=mf_endorse_cd
    AND cep.action_prsnl_id != 0
    AND cep.person_id != 0
    AND cep.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (ce
   WHERE ce.event_id=cep.event_id
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND ce.result_status_cd IN (mf_authverified_cd, mf_altered_cd, mf_modified_cd))
   JOIN (ce2
   WHERE ce2.event_id=ce.parent_event_id)
   JOIN (o
   WHERE o.order_id=ce.order_id)
   JOIN (cva
   WHERE cva.code_value=ce.catalog_cd
    AND cva.code_set=200)
   JOIN (ea
   WHERE ea.encntr_id=ce.encntr_id
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > sysdate
    AND ea.encntr_alias_type_cd=mf_fin_cd)
   JOIN (pa
   WHERE pa.person_id=ce.person_id
    AND pa.active_ind=1
    AND pa.person_alias_type_cd=mf_cmrn_cd)
  ORDER BY ce.parent_event_id, cep.action_dt_tm DESC
  HEAD REPORT
   pl_cnt = 0
  HEAD ce.parent_event_id
   mn_rows_found = 1, pl_cnt += 1
   IF (pl_cnt > size(m_rec->res,5))
    stat = alterlist(m_rec->res,(pl_cnt+ 10))
   ENDIF
   m_rec->res[pl_cnt].f_order_id = ce.order_id, m_rec->res[pl_cnt].s_reference_nbr = trim(ce2
    .reference_nbr), m_rec->res[pl_cnt].f_parent_event_id = ce.parent_event_id,
   m_rec->res[pl_cnt].s_cmrn = trim(pa.alias), m_rec->res[pl_cnt].s_fin = trim(ea.alias), m_rec->res[
   pl_cnt].f_contr_sys_cd = ce.contributor_system_cd,
   m_rec->res[pl_cnt].s_contr_sys_display = trim(uar_get_code_display(ce.contributor_system_cd)),
   m_rec->res[pl_cnt].s_alias = trim(cva.alias), m_rec->res[pl_cnt].f_order_ctlg_type_cd = o
   .catalog_type_cd,
   m_rec->res[pl_cnt].s_order_ctlg_type_display = trim(uar_get_code_display(o.catalog_type_cd))
  FOOT REPORT
   stat = alterlist(m_rec->res,pl_cnt)
  WITH nocounter, orahintcbo("index(cep xie3ce_event_prsnl)")
 ;end select
 SELECT DISTINCT INTO "nl:"
  ce.parent_event_id
  FROM ce_event_prsnl cep,
   clinical_event ce,
   clinical_event ce2,
   encntr_alias ea,
   person_alias pa,
   code_value_alias cva,
   orders o
  PLAN (cep
   WHERE cep.action_prsnl_id != 0
    AND cep.person_id != 0
    AND cep.action_type_cd=mf_endorse_cd
    AND cep.action_status_cd=mf_refused_cd
    AND cep.action_dt_tm BETWEEN cnvtlookbehind(ms_lookback_interval_beg,cnvtdatetime(ms_beg_dt_tm))
    AND cnvtlookbehind(ms_lookback_interval_end,cnvtdatetime(ms_end_dt_tm))
    AND cep.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (ce
   WHERE ce.event_id=cep.event_id
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND ce.result_status_cd IN (mf_authverified_cd, mf_altered_cd, mf_modified_cd)
    AND  EXISTS (
   (SELECT
    e.encntr_id
    FROM encounter e
    WHERE e.encntr_id=ce.encntr_id
     AND e.encntr_type_cd IN (mf_activecmtyofficevisit_cd, mf_daystay_cd, mf_dischdaystay_cd,
    mf_dischrecurofficevisit_cd, mf_dischrecurringop_cd,
    mf_dischargedoutpatient_cd, mf_officevisit_cd, mf_onetimeop_cd, mf_outpatient_cd,
    mf_outpatientonetime_cd,
    mf_outpatientrecurring_cd, mf_preoutpatientonetime_cd, mf_preoutpt_cd, mf_preadmitdaystay_cd,
    mf_preadmitip_cd,
    mf_recurofficevisit_cd, mf_recurringop_cd, mf_smri_cd))))
   JOIN (ce2
   WHERE ce2.event_id=ce.parent_event_id)
   JOIN (o
   WHERE o.order_id=ce.order_id)
   JOIN (cva
   WHERE cva.code_value=ce.catalog_cd
    AND cva.code_set=200)
   JOIN (ea
   WHERE ea.encntr_id=ce.encntr_id
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > sysdate
    AND ea.encntr_alias_type_cd=mf_fin_cd)
   JOIN (pa
   WHERE pa.person_id=ce.person_id
    AND pa.active_ind=1
    AND pa.person_alias_type_cd=mf_cmrn_cd)
  ORDER BY ce.parent_event_id, cep.action_dt_tm DESC
  HEAD REPORT
   pl_cnt = size(m_rec->res,5)
  HEAD ce.parent_event_id
   mn_rows_found = 1, pl_cnt += 1
   IF (pl_cnt > size(m_rec->res,5))
    stat = alterlist(m_rec->res,(pl_cnt+ 10))
   ENDIF
   m_rec->res[pl_cnt].f_order_id = ce.order_id, m_rec->res[pl_cnt].s_reference_nbr = trim(ce2
    .reference_nbr), m_rec->res[pl_cnt].f_parent_event_id = ce.parent_event_id,
   m_rec->res[pl_cnt].s_cmrn = trim(pa.alias), m_rec->res[pl_cnt].s_fin = trim(ea.alias), m_rec->res[
   pl_cnt].f_contr_sys_cd = ce.contributor_system_cd,
   m_rec->res[pl_cnt].s_contr_sys_display = trim(uar_get_code_display(ce.contributor_system_cd)),
   m_rec->res[pl_cnt].s_alias = trim(cva.alias), m_rec->res[pl_cnt].f_order_ctlg_type_cd = o
   .catalog_type_cd,
   m_rec->res[pl_cnt].s_order_ctlg_type_display = trim(uar_get_code_display(o.catalog_type_cd))
  FOOT REPORT
   stat = alterlist(m_rec->res,pl_cnt)
  WITH nocounter, orahintcbo("index(cep xie3ce_event_prsnl)")
 ;end select
 SELECT DISTINCT INTO "nl:"
  ce.parent_event_id
  FROM ce_event_action cea,
   ce_event_prsnl cep,
   clinical_event ce,
   clinical_event ce2,
   v500_event_set_explode vese,
   v500_event_set_code vesc,
   encntr_alias ea,
   person_alias pa,
   code_value_alias cva,
   prsnl pr,
   orders o
  PLAN (cea
   WHERE cea.updt_dt_tm BETWEEN cnvtlookbehind(ms_lookback_interval_beg,cnvtdatetime(ms_beg_dt_tm))
    AND cnvtlookbehind(ms_lookback_interval_end,cnvtdatetime(ms_end_dt_tm)))
   JOIN (cep
   WHERE cep.event_id=cea.parent_event_id
    AND cep.action_status_cd IN (mf_completed_cd, mf_endorse_save_cd)
    AND cep.action_prsnl_id != 0
    AND cep.person_id != 0
    AND cep.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (ce
   WHERE ce.event_id=cep.event_id
    AND ce.valid_until_dt_tm > sysdate
    AND ce.result_status_cd IN (mf_authverified_cd, mf_altered_cd, mf_modified_cd)
    AND  EXISTS (
   (SELECT
    e.encntr_id
    FROM encounter e
    WHERE e.encntr_id=ce.encntr_id
     AND e.encntr_type_cd IN (mf_activecmtyofficevisit_cd, mf_daystay_cd, mf_dischdaystay_cd,
    mf_dischrecurofficevisit_cd, mf_dischrecurringop_cd,
    mf_dischargedoutpatient_cd, mf_officevisit_cd, mf_onetimeop_cd, mf_outpatient_cd,
    mf_outpatientonetime_cd,
    mf_outpatientrecurring_cd, mf_preoutpatientonetime_cd, mf_preoutpt_cd, mf_preadmitdaystay_cd,
    mf_preadmitip_cd,
    mf_recurofficevisit_cd, mf_recurringop_cd, mf_smri_cd))))
   JOIN (ce2
   WHERE ce2.event_id=ce.parent_event_id)
   JOIN (vese
   WHERE vese.event_cd=ce.event_cd)
   JOIN (vesc
   WHERE vesc.event_set_cd=vese.event_set_cd
    AND vesc.event_set_name IN (ms_laboratory, ms_cardiovasculartest, ms_neuromuscular,
   ms_pulmonaryresults, ms_radiology))
   JOIN (pr
   WHERE pr.person_id=cea.action_prsnl_id
    AND  NOT (pr.name_last_key IN ("CONTRIBUTORSYSTEM")))
   JOIN (o
   WHERE o.order_id=ce.order_id)
   JOIN (cva
   WHERE cva.code_value=ce.catalog_cd
    AND cva.code_set=200)
   JOIN (ea
   WHERE ea.encntr_id=ce.encntr_id
    AND ea.end_effective_dt_tm > sysdate
    AND ea.encntr_alias_type_cd=mf_fin_cd)
   JOIN (pa
   WHERE pa.person_id=ce.person_id
    AND pa.person_alias_type_cd=mf_cmrn_cd)
  ORDER BY ce.parent_event_id, cep.action_dt_tm DESC
  HEAD REPORT
   pl_cnt = size(m_rec->res,5)
  HEAD ce.parent_event_id
   mn_rows_found = 1, pl_cnt += 1
   IF (pl_cnt > size(m_rec->res,5))
    stat = alterlist(m_rec->res,(pl_cnt+ 10))
   ENDIF
   m_rec->res[pl_cnt].f_order_id = ce.order_id, m_rec->res[pl_cnt].s_reference_nbr = trim(ce2
    .reference_nbr), m_rec->res[pl_cnt].s_cmrn = trim(pa.alias),
   m_rec->res[pl_cnt].s_fin = trim(ea.alias), m_rec->res[pl_cnt].f_contr_sys_cd = ce
   .contributor_system_cd, m_rec->res[pl_cnt].s_contr_sys_display = trim(uar_get_code_display(ce
     .contributor_system_cd)),
   m_rec->res[pl_cnt].s_alias = trim(cva.alias), m_rec->res[pl_cnt].f_order_ctlg_type_cd = o
   .catalog_type_cd, m_rec->res[pl_cnt].s_order_ctlg_type_display = trim(uar_get_code_display(o
     .catalog_type_cd))
  FOOT REPORT
   stat = alterlist(m_rec->res,pl_cnt)
  WITH nocounter
 ;end select
 IF (mn_rows_found < 1)
  SET ms_msg = "No rows found for this date range"
  CALL echo(ms_msg)
  SET reply->status_data[1].status = "S"
  IF (textlen(ms_recipients) > 0)
   CALL uar_send_mail(nullterm(ms_recipients),nullterm(concat("LAB ENDORSEMENTS ",trim(format(sysdate,
        "mm/dd/yy hh:mm;;d")))),nullterm(ms_msg),nullterm(curnode),1,
    nullterm("IPM.NOTE"))
  ENDIF
  GO TO exit_script
 ENDIF
 SELECT INTO value(ms_filename)
  FROM (dummyt d  WITH seq = value(size(m_rec->res,5)))
  WHERE (m_rec->res[d.seq].n_donot_release_ind != 1)
  HEAD REPORT
   pl_cnt = 0
  DETAIL
   pl_cnt += 1, ms_tmp = concat('"',trim(cnvtstring(m_rec->res[d.seq].f_order_id)),'"',',"',trim(
     m_rec->res[d.seq].s_reference_nbr),
    '"',',"',format(m_rec->res[d.seq].s_cmrn,"#######;p0"),'"'), ms_tmp = concat(ms_tmp,',"',trim(
     cnvtstring(m_rec->res[d.seq].f_contr_sys_cd)),'"',',"',
    m_rec->res[d.seq].s_contr_sys_display,'"',',"',m_rec->res[d.seq].s_alias,'"',
    ',"',trim(cnvtstring(m_rec->res[d.seq].f_order_ctlg_type_cd)),'"',',"',m_rec->res[d.seq].
    s_order_ctlg_type_display,
    '"')
   IF (isnumeric(m_rec->res[d.seq].s_fin) > 0
    AND textlen(m_rec->res[d.seq].s_fin)=9)
    ms_tmp = concat(ms_tmp,',"0',m_rec->res[d.seq].s_fin,'"',',"',
     '"')
   ELSE
    ms_tmp = concat(ms_tmp,',"',m_rec->res[d.seq].s_fin,'"',',"',
     '"')
   ENDIF
   IF (pl_cnt > 1)
    row + 1
   ENDIF
   col 0, ms_tmp
  WITH nocounter, format = variable, maxrow = 1,
   maxcol = 1000
 ;end select
 IF (mn_test=0)
  SET ms_dcl = concat(
   "$cust_script/bhs_sftp_file.ksh routerlive:/data/routerlive/bh/labendorsement/in ",ms_filename)
 ELSE
  SET ms_dcl = concat(
   "$cust_script/bhs_sftp_file.ksh routertest:/data/routertest/bh/labendorsement/in ",ms_filename)
 ENDIF
 CALL echo(ms_dcl)
 SET status = 0
 SET len = size(trim(ms_dcl))
 SET stat = dcl(ms_dcl,len,status)
 CALL echo(build2("stat: ",stat))
 IF (textlen(ms_recipients) > 0)
  CALL echo(ms_recipients)
  SET ms_tmp = concat(ms_dm_info_domain," ",ms_beg_dt_tm," - ",ms_end_dt_tm)
  EXECUTE bhs_ma_email_file
  CALL emailfile(ms_filename,ms_filename,ms_recipients,ms_tmp,1)
 ELSE
  CALL echo("null")
 ENDIF
 SET reply->status_data[1].status = "S"
 GO TO exit_script
#send_page
 SET ms_tmp = concat("*** BHS_RPT_LAB_ENDORSEMENTS FAILURE ",curnode," ***",char(13),
  "Job Name: MyHealth Lab Endorsements ",
  char(13),"Job Date: ",trim(format(sysdate,"mm/dd/yy hh:mm;;d")),char(13),"Error: ",
  ms_msg,char(13),char(13),"Manual Run: ExpMenu->Main->CIS Core Programs->",char(13))
 IF (ms_msg="001*")
  SET ms_tmp = concat(ms_tmp,
   "Please ensure that the DM_INFO row for BHS_RPT_LAB_ENDORSEMENTS has been inserted",char(13),
   "and dm_info.info_dt_tm has been set appropriately.",char(13),
   char(13))
  SET ms_tmp = concat(ms_tmp,"Once the appropriate start_dt_tm for this job has been determined, ",
   "use the following command to insert the dm_info_row:",char(13),char(13),
   "   insert into dm_info d",char(13),"   set",char(13),"     d.info_domain = '",
   ms_dm_info_domain,"',",char(13),"     d.info_name = '",ms_dm_info_name,
   "'",char(13),"     d.info_date = <date_tm>,",char(13),"     d.updt_dt_tm = sysdate,",
   char(13),"     d.updt_id = reqinfo->updt_id",char(13),"   with nocounter go commit go")
 ELSEIF (ms_msg="002*")
  SET ms_tmp = concat(ms_tmp,
   "The time gap since the last BHS_RPT_LAB_ENDORSEMENTS job ended is greater than ",trim(cnvtstring(
     ml_job_max_hrs))," hrs.",char(13),
   "Please run the jobs manually in increments of ",ms_job_hrs," hrs to cover the time gap.",char(13),
   "Once complete, update the dm_info.info_dt_tm to an appropriate time to begin the ops job.",
   char(13),char(13))
  SET ms_tmp = concat(ms_tmp,"Once the appropriate start_dt_tm for this job has been determined, ",
   "use the following command to update the dm_info_row:",char(13),char(13),
   "   update into dm_info d",char(13),"   set",char(13),"     d.info_date = <date_tm>,",
   char(13),"     d.updt_dt_tm = sysdate,",char(13),"     d.updt_id = reqinfo->updt_id",char(13),
   "   where d.info_domain = '",ms_dm_info_domain,"'",char(13),"     and d.info_name = '",
   ms_dm_info_name,"'",char(13),"   with nocounter go commit go")
 ENDIF
 IF (mn_test=0)
  CALL uar_send_mail(nullterm("ciscore@bhs.org"),nullterm(concat(
     "MyHealth Lab Endorsements Fail (PROD) ",trim(format(sysdate,"mm/dd/yy hh:mm;;d")))),nullterm(
    ms_tmp),nullterm(concat("MyHealth Lab Endorsements ",curnode)),1,
   nullterm("IPM.NOTE"))
 ELSE
  CALL uar_send_mail(nullterm("nicholas.boisjolie@bhs.org"),nullterm(concat(
     "MyHealth Lab Endorsements Fail (TEST) ",trim(format(sysdate,"mm/dd/yy hh:mm;;d")))),nullterm(
    ms_tmp),nullterm(concat("MyHealth Lab Endorsements ",curnode)),1,
   nullterm("IPM.NOTE"))
  CALL uar_send_mail(nullterm("oleksiy.kononenko@bhs.org"),nullterm(concat(
     "MyHealth Lab Endorsements Fail (TEST) ",trim(format(sysdate,"mm/dd/yy hh:mm;;d")))),nullterm(
    ms_tmp),nullterm(concat("MyHealth Lab Endorsements ",curnode)),1,
   nullterm("IPM.NOTE"))
 ENDIF
#exit_script
 IF (mn_ops=1
  AND (reply->status_data[1].status="S"))
  UPDATE  FROM dm_info d
   SET d.info_date = cnvtlookahead("1,S",cnvtdatetime(sysdate)), d.updt_dt_tm = sysdate, d.updt_id =
    reqinfo->updt_id
   WHERE d.info_domain=ms_dm_info_domain
    AND d.info_name=ms_dm_info_name
   WITH nocounter
  ;end update
  COMMIT
 ELSEIF (mn_ops=0)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    ms_tmp = concat("BHS_OPS_FAX_POWERNOTES executed for range ",ms_beg_dt_tm," to ",ms_end_dt_tm),
    col 0, ms_tmp,
    col 0, row + 2, ms_msg
    IF ((reply->status_data[1].status="F"))
     col 0, row + 2, "Job Failed"
    ELSE
     col 0, row + 2, "Job Succeeded"
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 FREE RECORD m_rec
END GO
