CREATE PROGRAM bhs_rpt_nonendorsed_results:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "email" = ""
  WITH outdev, ms_email
 EXECUTE bhs_hlp_ftp
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
 DECLARE mf_extremehigh_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",52,"EXTREMEHIGH"))
 DECLARE mf_panichigh_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",52,"PANICHIGH"))
 DECLARE mf_high_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",52,"HIGH"))
 DECLARE mf_extremelow_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",52,"EXTREMELOW"))
 DECLARE mf_paniclow_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",52,"PANICLOW"))
 DECLARE mf_low_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",52,"LOW"))
 DECLARE mf_positive_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",52,"POSITIVE"))
 DECLARE mf_vabnormal_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",52,"VABNORMAL"))
 DECLARE mf_abnormal_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",52,"ABNORMAL"))
 DECLARE mf_critical_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",52,"CRITICAL"))
 DECLARE mf_a_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",52,"A"))
 DECLARE mf_ll_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",52,"LL"))
 DECLARE mf_hh_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",52,"HH"))
 DECLARE mf_authverified_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",8,"AUTHVERIFIED"
   ))
 DECLARE mf_altered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE mf_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_endorse_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",21,"ENDORSE"))
 DECLARE mf_completed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",103,"COMPLETED"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_cmrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"CMRN"))
 DECLARE mf_order_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6003,"ORDER"))
 DECLARE ms_filename = vc WITH protect, constant(concat("bhs_non_endorsed_",trim(cnvtstring(rand(0),
     20),3),"_",format(cnvtdatetime(sysdate),"YYYYMMDDHHMMSS;;d"),".csv"))
 DECLARE ms_loc_dir = vc WITH protect, constant(logical("ccluserdir"))
 DECLARE ms_ftp_host = vc WITH protect, constant("transfer.baystatehealth.org")
 DECLARE ms_ftp_username = vc WITH protect, constant("CernerFTP")
 DECLARE ms_ftp_password = vc WITH protect, constant("gJeZD64")
 DECLARE ms_ftp_path = vc WITH protect, constant("ciscore/surginet/implant_analysis")
 DECLARE ms_ftp_cmd = vc WITH protect, constant(concat("put ",ms_filename))
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ms_dclcom = vc WITH protect, noconstant("")
 DECLARE ml_stat = i4 WITH protect, noconstant(0)
 FREE RECORD res
 RECORD res(
   1 l_cnt = i4
   1 qual[*]
     2 s_fin = vc
     2 s_cmrn = vc
     2 s_pat_name = vc
     2 f_encntr_id = f8
     2 f_order_id = f8
     2 f_event_cd = f8
     2 s_event_cd_disp = vc
     2 s_normality_cd_disp = vc
     2 s_perform_dt = vc
     2 s_order_dt = vc
     2 s_cat_cd_display = vc
     2 s_ref_nbr = vc
     2 s_order_provider = vc
 )
 FREE RECORD ecode
 RECORD ecode(
   1 l_cnt = i4
   1 qual[*]
     2 f_event_cd = f8
 ) WITH protect
 SELECT INTO "nl:"
  FROM v500_event_set_code vesc,
   v500_event_set_explode vese
  PLAN (vesc
   WHERE vesc.event_set_name IN (ms_laboratory))
   JOIN (vese
   WHERE vese.event_set_cd=vesc.event_set_cd)
  HEAD REPORT
   ecode->l_cnt = 0
  DETAIL
   ecode->l_cnt += 1, stat = alterlist(ecode->qual,ecode->l_cnt), ecode->qual[ecode->l_cnt].
   f_event_cd = vese.event_cd
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM clinical_event ce,
   encounter e,
   person p,
   orders o,
   order_action oa,
   prsnl pr,
   encntr_alias ea,
   person_alias pa,
   dummyt d1,
   ce_event_prsnl cep
  PLAN (ce
   WHERE ce.view_level=1
    AND expand(ml_idx,1,ecode->l_cnt,ce.event_cd,ecode->qual[ml_idx].f_event_cd)
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND ce.performed_dt_tm BETWEEN cnvtdatetime((curdate - 30),0) AND cnvtdatetime(sysdate)
    AND ce.result_status_cd IN (mf_authverified_cd, mf_altered_cd, mf_modified_cd)
    AND ce.normalcy_cd IN (mf_extremehigh_cd, mf_panichigh_cd, mf_high_cd, mf_extremelow_cd,
   mf_paniclow_cd,
   mf_low_cd, mf_positive_cd, mf_vabnormal_cd, mf_abnormal_cd, mf_critical_cd,
   mf_a_cd, mf_ll_cd, mf_hh_cd))
   JOIN (o
   WHERE (o.order_id= Outerjoin(ce.order_id)) )
   JOIN (oa
   WHERE (oa.order_id= Outerjoin(o.order_id))
    AND (oa.action_type_cd= Outerjoin(mf_order_cd)) )
   JOIN (pr
   WHERE (pr.person_id= Outerjoin(oa.order_provider_id)) )
   JOIN (e
   WHERE e.encntr_id=ce.encntr_id
    AND e.encntr_type_cd IN (mf_activecmtyofficevisit_cd, mf_daystay_cd, mf_dischdaystay_cd,
   mf_dischrecurofficevisit_cd, mf_dischrecurringop_cd,
   mf_dischargedoutpatient_cd, mf_officevisit_cd, mf_onetimeop_cd, mf_outpatient_cd,
   mf_outpatientonetime_cd,
   mf_outpatientrecurring_cd, mf_preoutpatientonetime_cd, mf_preoutpt_cd, mf_preadmitdaystay_cd,
   mf_preadmitip_cd,
   mf_recurofficevisit_cd, mf_recurringop_cd, mf_smri_cd))
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (ea
   WHERE (ea.encntr_id= Outerjoin(e.encntr_id))
    AND (ea.end_effective_dt_tm> Outerjoin(sysdate))
    AND (ea.active_ind= Outerjoin(1))
    AND (ea.encntr_alias_type_cd= Outerjoin(mf_fin_cd)) )
   JOIN (pa
   WHERE (pa.person_id= Outerjoin(p.person_id))
    AND (pa.person_alias_type_cd= Outerjoin(mf_cmrn_cd))
    AND (pa.end_effective_dt_tm> Outerjoin(sysdate))
    AND (pa.active_ind= Outerjoin(1)) )
   JOIN (d1)
   JOIN (cep
   WHERE cep.event_id=ce.event_id
    AND cep.action_status_cd=mf_completed_cd
    AND cep.action_type_cd=mf_endorse_cd
    AND cep.action_prsnl_id != 0
    AND cep.person_id != 0
    AND cep.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
  ORDER BY ce.encntr_id, ce.event_id
  HEAD REPORT
   res->l_cnt = 0
  HEAD ce.event_id
   IF (cep.ce_event_prsnl_id IN (null, 0.0))
    res->l_cnt += 1, stat = alterlist(res->qual,res->l_cnt), res->qual[res->l_cnt].f_encntr_id = e
    .encntr_id,
    res->qual[res->l_cnt].f_event_cd = ce.event_cd, res->qual[res->l_cnt].f_order_id = ce.order_id,
    res->qual[res->l_cnt].s_event_cd_disp = trim(uar_get_code_display(ce.event_cd),3),
    res->qual[res->l_cnt].s_normality_cd_disp = trim(uar_get_code_display(ce.normalcy_cd),3), res->
    qual[res->l_cnt].s_fin = trim(ea.alias,3), res->qual[res->l_cnt].s_cmrn = trim(pa.alias,3),
    res->qual[res->l_cnt].s_pat_name = trim(p.name_full_formatted,3)
    IF (ce.catalog_cd > 0.0)
     res->qual[res->l_cnt].s_cat_cd_display = trim(uar_get_code_display(ce.catalog_cd),3)
    ENDIF
    res->qual[res->l_cnt].s_perform_dt = format(ce.performed_dt_tm,";;q"), res->qual[res->l_cnt].
    s_ref_nbr = trim(ce.reference_nbr,3), res->qual[res->l_cnt].s_order_dt = format(o
     .orig_order_dt_tm,";;q"),
    res->qual[res->l_cnt].s_order_provider = trim(pr.name_full_formatted,3)
   ENDIF
  WITH nocounter, outerjoin = d1, expand = 1,
   filesort
 ;end select
 CALL echo(res->l_cnt)
 FREE RECORD frec
 RECORD frec(
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
   1 file_name = vc
   1 file_buf = vc
 )
 SET frec->file_name = ms_filename
 SET frec->file_buf = "w"
 SET stat = cclio("OPEN",frec)
 SET frec->file_buf = concat(
  '"cmrn","Pat Name","FIN","cat_code","event_code","normality","order_date",',
  '"order_provider","performed_date","reference_nbr"',char(13))
 SET stat = cclio("WRITE",frec)
 IF ((res->l_cnt=0))
  SET frec->file_buf = concat(" ",char(13))
  SET stat = cclio("WRITE",frec)
 ENDIF
 FOR (ml_cnt = 1 TO res->l_cnt)
  SET frec->file_buf = concat('"',res->qual[ml_cnt].s_cmrn,'","',res->qual[ml_cnt].s_pat_name,'","',
   res->qual[ml_cnt].s_fin,'","',res->qual[ml_cnt].s_cat_cd_display,'","',res->qual[ml_cnt].
   s_event_cd_disp,
   '","',res->qual[ml_cnt].s_normality_cd_disp,'","',res->qual[ml_cnt].s_order_dt,'","',
   res->qual[ml_cnt].s_order_provider,'","',res->qual[ml_cnt].s_perform_dt,'","',res->qual[ml_cnt].
   s_ref_nbr,
   '"',char(13))
  SET stat = cclio("WRITE",frec)
 ENDFOR
 SET stat = cclio("CLOSE",frec)
 SET stat = bhs_ftp_cmd(ms_ftp_cmd,ms_ftp_host,ms_ftp_username,ms_ftp_password,ms_loc_dir,
  ms_ftp_path)
 EXECUTE bhs_ma_email_file
 CALL emailfile(frec->file_name,frec->file_name,trim( $MS_EMAIL,3),"non-endorsed results report",1)
 SELECT INTO  $OUTDEV
  FROM dummyt
  HEAD REPORT
   msg1 = concat("File has been emailed to: ",trim( $MS_EMAIL,3)), col 0,
   "{PS/792 0 translate 90 rotate/}",
   y_pos = 18, row + 1, "{F/1}{CPI/7}",
   CALL print(calcpos(36,(y_pos+ 0))), msg1
  WITH nocounter, dio = 08
 ;end select
#exit_script
END GO
