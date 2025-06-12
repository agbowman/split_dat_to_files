CREATE PROGRAM bhs_him_softmed_prelim_onetime:dba
 EXECUTE bhs_sys_stand_subroutine
 FREE RECORD him_esec_new_final
 RECORD him_esec_new_final(
   1 md_beg_dt_tm = dq8
   1 md_end_dt_tm = dq8
   1 encntrs[*]
     2 mf_encntr_id = f8
     2 ms_patient_fin = vc
     2 mf_person_id = f8
     2 ms_patient_mrn = vc
     2 ms_patient_lname = vc
     2 ms_prov_name = vc
     2 ms_signed_dt = vc
     2 ms_softmed_docid = vc
     2 ms_doc_name = vc
 ) WITH protect
 SET month = month((curdate - 30))
 IF (((month=1) OR (((3) OR (((5) OR (((7) OR (((8) OR (((10) OR (12)) )) )) )) )) )) )
  SET days = 180
 ELSEIF (month=2)
  SET days = 180
 ELSEIF (((month=4) OR (((6) OR (((9) OR (11)) )) )) )
  SET days = 30
 ENDIF
 CALL echo(build("month",month))
 SET him_esec_new_final->md_beg_dt_tm = cnvtdatetime((curdate - 60),000000)
 SET him_esec_new_final->md_end_dt_tm = cnvtdatetime(curdate,235900)
 CALL echo("TIMES:")
 CALL echo(format(cnvtdatetime(him_esec_new_final->md_beg_dt_tm),";;q"))
 CALL echo(format(cnvtdatetime(him_esec_new_final->md_end_dt_tm),";;q"))
 SET logical him_prelim_rpt_file "bhscust:bhs_him_prelim_onetime_rpt.csv"
 DECLARE mf_softmed_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",89,"SOFTMED"))
 DECLARE mf_doc_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"DOC"))
 DECLARE mf_mdoc_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"MDOC"))
 DECLARE mf_prelim_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"UNAUTH"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_transum_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"TRANSFERSUMMARY")
  )
 DECLARE mf_hispsy_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "HISTORYANDPHYSICAL"))
 DECLARE mf_carsuroprpt_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "CARDIACSURGOPERATIVEREPORT"))
 DECLARE mf_elecphyrpt_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ELECTROPHYSIOLOGYREPORT"))
 DECLARE mf_optvrpt_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"OPERATIVEREPORT")
  )
 DECLARE mf_specprogasnote_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SPECIALPROCEDUREGASTRONOTE"))
 DECLARE mf_psychphy_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PSYCHIATRICPHYSICAL"))
 DECLARE mf_dischsum_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "DISCHARGESUMMARY"))
 DECLARE mf_orthpedhisphy_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ORTHOPEDICHISTORYANDPHYSICAL"))
 DECLARE mf_orthpedoprpt_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ORTHOPEDICOPERATIVEREPORT"))
 DECLARE mf_progntbmc_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PROGRESSNOTEBMC"))
 DECLARE mf_progntbfmc_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PROGRESSNOTEBFMC"))
 DECLARE mf_progntbmlh_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PROGRESSNOTEBMLH"))
 DECLARE mf_traumanhp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "TRAUMARESUSCITATIONHP"))
 DECLARE mf_signprov_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",320,"PRSNLID"))
 DECLARE mc_delimiter = c1 WITH protect, noconstant(",")
 DECLARE ms_line = vc WITH protect, noconstant(" ")
 DECLARE ms_hold_orig_dt = dq8 WITH procect, noconstant(0)
 DECLARE ml_e_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_pv_cnt = i4 WITH protect, noconstant(0)
 DECLARE ms_dclcom_str = vc WITH protect, noconstant(" ")
 DECLARE mn_dclcom_len = i4 WITH protect, noconstant(0)
 DECLARE mn_dclcom_stat = i4 WITH protect, noconstant(0)
 DECLARE mn_test_ind = i4 WITH protect, noconstant(0)
 DECLARE mf_fac_cd = f8 WITH protect, noconstant(0.0)
 DECLARE ms_email_filename = vc WITH protect, noconstant(" ")
 SET ms_email_filename = "bhs_him_prelim_onetime_rpt.csv"
 CALL echo(mf_prelim_cd)
 CALL echo(mf_transum_cd)
 CALL echo(mf_hispsy_cd)
 CALL echo(mf_carsuroprpt_cd)
 CALL echo(mf_elecphyrpt_cd)
 CALL echo(mf_optvrpt_cd)
 CALL echo(mf_specprogasnote_cd)
 CALL echo(mf_psychphy_cd)
 CALL echo(mf_dischsum_cd)
 CALL echo(mf_orthpedhisphy_cd)
 CALL echo(mf_orthpedoprpt_cd)
 CALL echo(mf_progntbmc_cd)
 CALL echo(mf_progntbfmc_cd)
 CALL echo(mf_progntbmlh_cd)
 CALL echo(mf_traumanhp_cd)
 SELECT INTO "NL:"
  FROM clinical_event ce,
   encounter e,
   person p,
   encntr_alias ea,
   encntr_alias ea1,
   prsnl ep
  PLAN (ce
   WHERE ce.contributor_system_cd=689445.00
    AND ce.result_status_cd=mf_prelim_cd
    AND ce.event_class_cd IN (mf_doc_cd, mf_mdoc_cd)
    AND ce.event_cd IN (mf_transum_cd, mf_hispsy_cd, mf_carsuroprpt_cd, mf_elecphyrpt_cd,
   mf_optvrpt_cd,
   mf_specprogasnote_cd, mf_psychphy_cd, mf_dischsum_cd, mf_orthpedhisphy_cd, mf_orthpedoprpt_cd,
   mf_progntbmc_cd, mf_progntbfmc_cd, mf_progntbmlh_cd, mf_traumanhp_cd)
    AND ce.performed_dt_tm BETWEEN cnvtdatetime(him_esec_new_final->md_beg_dt_tm) AND cnvtdatetime(
    him_esec_new_final->md_end_dt_tm)
    AND ce.valid_until_dt_tm > sysdate)
   JOIN (e
   WHERE e.encntr_id=ce.encntr_id
    AND e.active_ind=1)
   JOIN (ea1
   WHERE ea1.encntr_id=e.encntr_id
    AND ea1.active_ind=1
    AND ea1.encntr_alias_type_cd=mf_fin_cd)
   JOIN (p
   WHERE p.person_id=ce.person_id
    AND p.active_ind=1)
   JOIN (ea
   WHERE ea.encntr_id=ce.encntr_id
    AND ea.active_ind=1
    AND ea.encntr_alias_type_cd=mf_mrn_cd)
   JOIN (ep
   WHERE ep.person_id=ce.performed_prsnl_id
    AND ep.active_ind=1)
  ORDER BY ce.encntr_id, ce.performed_dt_tm
  HEAD REPORT
   ce.encntr_id, ml_e_cnt = 0, mn_test_ind = 0
  HEAD ce.encntr_id
   ml_e_cnt = (ml_e_cnt+ 1)
   IF (ml_e_cnt > size(him_esec_new_final->encntrs,5))
    stat = alterlist(him_esec_new_final->encntrs,ml_e_cnt)
   ENDIF
   him_esec_new_final->encntrs[ml_e_cnt].mf_encntr_id = ce.encntr_id, him_esec_new_final->encntrs[
   ml_e_cnt].ms_patient_fin = ea1.alias, him_esec_new_final->encntrs[ml_e_cnt].mf_person_id = ce
   .person_id,
   him_esec_new_final->encntrs[ml_e_cnt].ms_patient_mrn = ea.alias, him_esec_new_final->encntrs[
   ml_e_cnt].ms_patient_lname = p.name_full_formatted, him_esec_new_final->encntrs[ml_e_cnt].
   ms_signed_dt = format(cnvtdatetime(ce.performed_dt_tm),"MM/DD/YY HH:MM;;q"),
   him_esec_new_final->encntrs[ml_e_cnt].ms_prov_name = ep.name_full_formatted, him_esec_new_final->
   encntrs[ml_e_cnt].ms_softmed_docid = ce.reference_nbr, him_esec_new_final->encntrs[ml_e_cnt].
   ms_doc_name = uar_get_code_display(ce.event_cd)
  FOOT REPORT
   stat = alterlist(him_esec_new_final->encntrs,ml_e_cnt)
  WITH nocounter
 ;end select
 IF (curqual < 1)
  GO TO exit_script
 ENDIF
 SELECT DISTINCT INTO him_prelim_rpt_file
  FROM (dummyt d  WITH seq = size(him_esec_new_final->encntrs,5))
  ORDER BY him_esec_new_final->encntrs[d.seq].mf_encntr_id
  HEAD REPORT
   ms_line = build("Pat Encounter #",mc_delimiter,"Patient Account #",mc_delimiter,"Person ID",
    mc_delimiter,"Patient MRN #",mc_delimiter,"Patient Name",mc_delimiter,
    "Date/Time Signed",mc_delimiter,"Provider Name",mc_delimiter,"SoftMED DOC ID",
    mc_delimiter,"Document Old Name"), row 0, col 0,
   ms_line
  DETAIL
   ms_line = build(him_esec_new_final->encntrs[d.seq].mf_encntr_id,mc_delimiter,trim(
     him_esec_new_final->encntrs[d.seq].ms_patient_fin,3),mc_delimiter,him_esec_new_final->encntrs[d
    .seq].mf_person_id,
    mc_delimiter,trim(him_esec_new_final->encntrs[d.seq].ms_patient_lname,3),mc_delimiter,trim(
     him_esec_new_final->encntrs[d.seq].ms_signed_dt,3),mc_delimiter,
    trim(him_esec_new_final->encntrs[d.seq].ms_prov_name,3),mc_delimiter,trim(him_esec_new_final->
     encntrs[d.seq].ms_softmed_docid,3),mc_delimiter,trim(him_esec_new_final->encntrs[d.seq].
     ms_doc_name,3)), row + 1, col 0,
   ms_line
  WITH nocounter, formfeed = none, maxcol = 2000,
   format = variable, maxrow = 1
 ;end select
 CALL echo("emailing")
 SET email_list = concat("tracy.baker@bhs.org")
 SET ms_tmp_str = concat("Files Emailed ",format(sysdate,"dd-mmm-yyyy hh:mm:ss;;d"))
 CALL emailfile(concat("$bhscust/",ms_email_filename),concat("$bhscust/",ms_email_filename),
  email_list,ms_tmp_str,1)
 IF (findfile(concat("bhscust:",ms_email_filename))=1)
  CALL echo("Unable to delete emailed file")
 ELSE
  CALL echo("Emailed File Deleted")
 ENDIF
#exit_script
END GO
