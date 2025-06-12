CREATE PROGRAM bhs_him_new_final_rpt:dba
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
     2 ms_interface = vc
 ) WITH protect
 SET month = month((curdate - 30))
 IF (((month=1) OR (((3) OR (((5) OR (((7) OR (((8) OR (((10) OR (12)) )) )) )) )) )) )
  SET days = 30
 ELSEIF (month=2)
  SET days = 28
 ELSEIF (((month=4) OR (((6) OR (((9) OR (11)) )) )) )
  SET days = 30
 ENDIF
 CALL echo(build("month",month))
 SET him_esec_new_final->md_beg_dt_tm = cnvtdatetime((curdate - 10),000000)
 SET him_esec_new_final->md_end_dt_tm = cnvtdatetime(curdate,235900)
 CALL echo("TIMES:")
 CALL echo(format(cnvtdatetime(him_esec_new_final->md_beg_dt_tm),";;q"))
 CALL echo(format(cnvtdatetime(him_esec_new_final->md_end_dt_tm),";;q"))
 SET logical him_new_esec_file "bhscust:bhs_him_newesec_rpt.txt"
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_altered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE mf_final_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",8,"FINAL"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_softmed_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",89,"SOFTMED"))
 DECLARE mf_nuance_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",89,"NUANCE"))
 DECLARE mf_doc_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"DOC"))
 DECLARE mf_mdoc_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"MDOC"))
 DECLARE mf_prognthsp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PROGRESSNOTEHOSPITAL"))
 DECLARE mf_procnote_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"PROCEDURENOTE"))
 DECLARE mf_distrntphsp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "DISCHARGETRANSFERNOTEHOSPITAL"))
 DECLARE mc_delimiter = c1 WITH protect, noconstant(",")
 DECLARE ms_line = vc WITH protect, noconstant(" ")
 DECLARE ms_start_date = vc WITH protect, noconstant(" ")
 DECLARE ms_end_date = vc WITH protect, noconstant(" ")
 DECLARE ms_prev_reason = vc WITH protect, noconstant(" ")
 DECLARE ms_email_filename = vc WITH protect, noconstant(" ")
 DECLARE ms_dclcom_str = vc WITH protect, noconstant(" ")
 DECLARE mn_dclcom_len = i4 WITH protect, noconstant(0)
 DECLARE mn_dclcom_stat = i4 WITH protect, noconstant(0)
 DECLARE mf_fac_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mn_test_ind = i4 WITH protect, noconstant(0)
 DECLARE ml_e_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_pat_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_tot_cnt = i4 WITH protect, noconstant(0)
 DECLARE ms_temp = vc WITH protect, noconstant(" ")
 SET ms_email_filename = "bhs_him_newesec_rpt.txt"
 SET mf_hispsy_cd = 150226250.00
 SET mf_connt_cd = 150226293.00
 SET mf_optvrpt_cd = 150226296.00
 CALL echo(mf_hispsy_cd)
 CALL echo(mf_connt_cd)
 CALL echo(mf_optvrpt_cd)
 CALL echo(mf_prognthsp_cd)
 CALL echo(mf_procnote_cd)
 CALL echo(mf_distrntphsp_cd)
 SELECT INTO "NL:"
  FROM clinical_event ce,
   encounter e,
   person p,
   encntr_alias ea,
   encntr_alias ea1,
   prsnl ep
  PLAN (ce
   WHERE ce.contributor_system_cd=mf_softmed_cd
    AND ce.result_status_cd IN (mf_auth_cd, mf_modified_cd, mf_altered_cd, mf_final_cd)
    AND ce.event_class_cd IN (mf_doc_cd, mf_mdoc_cd)
    AND ce.event_cd IN (mf_hispsy_cd, mf_connt_cd, mf_optvrpt_cd, mf_prognthsp_cd, mf_procnote_cd,
   mf_distrntphsp_cd)
    AND ce.reference_nbr="*err*"
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
  ORDER BY ce.encntr_id
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
   ms_signed_dt = format(cnvtdatetime(ce.performed_dt_tm),"MM/DD/YY HH:MM;;q")
   IF (ep.name_full_formatted IN ("*NUANCE*"))
    him_esec_new_final->encntrs[ml_e_cnt].ms_prov_name = "Nuance"
   ELSE
    him_esec_new_final->encntrs[ml_e_cnt].ms_prov_name = ep.name_full_formatted
   ENDIF
   him_esec_new_final->encntrs[ml_e_cnt].ms_softmed_docid = substring(1,7,ce.reference_nbr),
   him_esec_new_final->encntrs[ml_e_cnt].ms_doc_name = uar_get_code_display(ce.event_cd),
   him_esec_new_final->encntrs[ml_e_cnt].ms_interface = uar_get_code_display(ce.contributor_system_cd
    )
  FOOT REPORT
   stat = alterlist(him_esec_new_final->encntrs,ml_e_cnt)
  WITH nocounter
 ;end select
 CALL echorecord(him_esec_new_final)
 IF (curqual < 1)
  GO TO exit_script
 ENDIF
 SELECT INTO him_new_esec_file
  FROM (dummyt d  WITH seq = size(him_esec_new_final->encntrs,5))
  PLAN (d)
  ORDER BY him_esec_new_final->encntrs[d.seq].ms_interface, him_esec_new_final->encntrs[d.seq].
   mf_encntr_id
  HEAD REPORT
   mn_test_ind = 1, ms_start_date = format(cnvtdatetime(him_esec_new_final->md_beg_dt_tm),
    "MM/DD/YY;;d"), ms_end_date = format(cnvtdatetime(him_esec_new_final->md_end_dt_tm),"MM/DD/YY;;d"
    ),
   col 50, "Total Patient Documents in New Folder", row + 1,
   col 50, "From: ", col 58,
   ms_start_date, col 66, " To: ",
   col 72, ms_end_date, row + 1,
   col 0, "Interface", col 11,
   "Account #", col 21, " MRN#",
   col 30, "Patient Name", col 55,
   "Provider Name", col 88, "Signed Date",
   col 104, "Document ID", col 112,
   "Document Name", col 0, row + 2
  DETAIL
   col 2, him_esec_new_final->encntrs[d.seq].ms_interface, col 11,
   him_esec_new_final->encntrs[d.seq].ms_patient_fin, col 21, him_esec_new_final->encntrs[d.seq].
   ms_patient_mrn,
   col 30, him_esec_new_final->encntrs[d.seq].ms_patient_lname, col 55,
   him_esec_new_final->encntrs[d.seq].ms_prov_name, col 88, him_esec_new_final->encntrs[d.seq].
   ms_signed_dt,
   col 104, him_esec_new_final->encntrs[d.seq].ms_softmed_docid, col 112,
   him_esec_new_final->encntrs[d.seq].ms_doc_name, ml_tot_cnt = (ml_tot_cnt+ 1), row + 1
  FOOT REPORT
   row + 1, col 16, "Total Patient Documents in New Folder ",
   col + 1, ml_tot_cnt, row + 2,
   col 10, "***** END OF REPORT *****"
  WITH nocounter, formfeed = none, maxcol = 200,
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
