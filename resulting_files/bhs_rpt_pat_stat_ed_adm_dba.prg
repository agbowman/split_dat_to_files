CREATE PROGRAM bhs_rpt_pat_stat_ed_adm:dba
 FREE RECORD ed_adm_ext
 RECORD ed_adm_ext(
   1 md_beg_dt_tm = dq8
   1 md_end_dt_tm = dq8
   1 encntrs[*]
     2 mf_encntr_id = f8
     2 ms_patient_fin = vc
     2 mf_person_id = f8
     2 ms_patient_mrn = vc
     2 ms_patient_lname = vc
     2 ms_patient_age = vc
     2 ms_admit_form_sign_dt = vc
     2 ms_pat_stat_ord_dt = vc
     2 ms_pat_stat_order = vc
     2 mc_pat_adm_prov_lname = c25
     2 ms_prov_reltn = vc
 ) WITH protect
 EXECUTE bhs_sys_stand_subroutine:dba
 SET month = month((curdate - 30))
 IF (((month=1) OR (((3) OR (((5) OR (((7) OR (((8) OR (((10) OR (12)) )) )) )) )) )) )
  SET days = 30
 ELSEIF (month=2)
  SET days = 28
 ELSEIF (((month=4) OR (((6) OR (((9) OR (11)) )) )) )
  SET days = 30
 ENDIF
 CALL echo(build("month",month))
 SET ed_adm_ext->md_beg_dt_tm = cnvtdatetime((curdate - days),000000)
 SET ed_adm_ext->md_end_dt_tm = cnvtdatetime(curdate,235900)
 CALL echo("TIMES:")
 CALL echo(format(cnvtdatetime(ed_adm_ext->md_beg_dt_tm),";;q"))
 CALL echo(format(cnvtdatetime(ed_adm_ext->md_end_dt_tm),";;q"))
 SET logical ed_adm_rpt_file "bhscust:bhs_pt_stat_ed_adm_rpt.csv"
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_altered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_inpatient_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"INPATIENT"))
 DECLARE mf_emergency_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"EMERGENCY"))
 DECLARE mf_observation_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"OBSERVATION")
  )
 DECLARE mf_dischip = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"DISCHIP"))
 DECLARE mf_dischobv = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"DISCHOBV"))
 DECLARE mf_expireip = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"EXPIREDIP"))
 DECLARE mf_expireobv = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"EXPIREDOBV"))
 DECLARE mf_adm_pat_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "ADMITINPATIENTSERVICE"))
 DECLARE mf_adm_stat_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "STATUSINPATIENT"))
 DECLARE mf_adm_form_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "EDADMISSIONREQUESTFORM"))
 DECLARE mf_stat_obs_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "STATUSOBSERVATIONPATIENT"))
 DECLARE mf_sel_adm_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "SELECTADMITINPATIENTSERVICE"))
 DECLARE mf_sel_obs_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "SELECTOBSERVATIONSTATUS"))
 DECLARE mf_admitdoc_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",333,"ADMITDOC"))
 DECLARE mf_loc_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",339,"LOCATION"))
 DECLARE mf_edmain_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"EDMAIN"))
 DECLARE mf_edpedi_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"EDPEDI"))
 DECLARE mf_eshld_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"ESHLD"))
 DECLARE mf_eda_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"EDA"))
 DECLARE mf_edx_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"EDX"))
 DECLARE mf_ede_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"EDE"))
 DECLARE mf_edg_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"EDG"))
 DECLARE mf_edp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"EDP"))
 DECLARE mf_ed_status_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE"))
 DECLARE mf_esa_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"ESA"))
 DECLARE mf_esb_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"ESB"))
 DECLARE mf_esc_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"ESC"))
 DECLARE mf_esd_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"ESD"))
 DECLARE mf_ese_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"ESE"))
 DECLARE mf_esp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"ESP"))
 DECLARE mf_esx_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"ESX"))
 DECLARE mf_esw_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"ESW"))
 DECLARE ms_email_filename = vc WITH protect, constant("bhs_pt_stat_ed_adm_rpt.csv")
 DECLARE mc_delimiter = c1 WITH protect, noconstant(",")
 DECLARE ms_line = vc WITH protect, noconstant(" ")
 DECLARE ms_hold_orig_dt = dq8 WITH procect, noconstant(0)
 DECLARE ml_e_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_pv_cnt = i4 WITH protect, noconstant(0)
 DECLARE mn_test_ind = i4 WITH protect, noconstant(0)
 DECLARE mf_fac_cd = f8 WITH protect, noconstant(0.0)
 SELECT DISTINCT INTO "nl:"
  o.encntr_id, format(o.current_start_dt_tm,"MM/DD/YY MM:MM:SS;;q")
  FROM code_value cv,
   orders o,
   encntr_domain ed,
   encntr_loc_hist elh,
   encounter e,
   person p,
   encntr_alias ea,
   encntr_alias ea1,
   clinical_event ce,
   encntr_prsnl_reltn epr1,
   prsnl ep
  PLAN (cv
   WHERE cv.code_set=220
    AND cv.display_key="BMC"
    AND cv.active_ind=1
    AND cv.cdf_meaning=trim("FACILITY",3)
    AND cv.data_status_cd=mf_auth_cd)
   JOIN (ed
   WHERE ((ed.loc_facility_cd+ 0)=cv.code_value)
    AND ed.beg_effective_dt_tm <= cnvtdatetime(ed_adm_ext->md_end_dt_tm)
    AND ed.end_effective_dt_tm >= cnvtdatetime(ed_adm_ext->md_beg_dt_tm))
   JOIN (elh
   WHERE elh.encntr_id=ed.encntr_id
    AND elh.active_ind=1
    AND elh.loc_nurse_unit_cd IN (mf_edmain_cd, mf_edpedi_cd, mf_eshld_cd, mf_eda_cd, mf_edx_cd,
   mf_ede_cd, mf_edg_cd, mf_edp_cd, mf_esa_cd, mf_esb_cd,
   mf_esc_cd, mf_esd_cd, mf_ese_cd, mf_esp_cd, mf_esx_cd,
   mf_esw_cd))
   JOIN (e
   WHERE e.encntr_id=elh.encntr_id
    AND e.active_ind=1
    AND e.encntr_type_cd IN (mf_inpatient_cd, mf_observation_cd, mf_dischip, mf_dischobv, mf_expireip,
   mf_expireobv))
   JOIN (ce
   WHERE ce.encntr_id=elh.encntr_id
    AND ce.valid_until_dt_tm >= cnvtdatetime(ed_adm_ext->md_end_dt_tm)
    AND ce.event_cd=mf_adm_form_cd
    AND ce.result_status_cd IN (mf_modified_cd, mf_altered_cd, mf_auth_cd))
   JOIN (o
   WHERE ((o.encntr_id+ 0)=ce.encntr_id)
    AND o.catalog_cd IN (mf_adm_stat_cd, mf_sel_adm_cd, mf_sel_obs_cd, mf_adm_pat_cd, mf_stat_obs_cd)
    AND o.orig_order_dt_tm BETWEEN cnvtdatetime(ed_adm_ext->md_beg_dt_tm) AND cnvtdatetime(ed_adm_ext
    ->md_end_dt_tm))
   JOIN (ea1
   WHERE ea1.encntr_id=o.encntr_id
    AND ea1.active_ind=1
    AND ea1.encntr_alias_type_cd=mf_fin_cd)
   JOIN (p
   WHERE p.person_id=o.person_id
    AND p.active_ind=1)
   JOIN (ea
   WHERE (ea.encntr_id= Outerjoin(o.encntr_id))
    AND (ea.active_ind= Outerjoin(1))
    AND (ea.encntr_alias_type_cd= Outerjoin(mf_mrn_cd)) )
   JOIN (epr1
   WHERE (epr1.encntr_id= Outerjoin(ea.encntr_id))
    AND (epr1.end_effective_dt_tm>= Outerjoin(cnvtdatetime(ed_adm_ext->md_end_dt_tm)))
    AND epr1.active_ind=1
    AND (epr1.encntr_prsnl_r_cd= Outerjoin(mf_admitdoc_cd)) )
   JOIN (ep
   WHERE (ep.person_id= Outerjoin(epr1.prsnl_person_id)) )
  ORDER BY o.encntr_id, o.current_start_dt_tm
  HEAD REPORT
   o.encntr_id, ml_e_cnt = 0, mn_test_ind = 0
  HEAD o.current_start_dt_tm
   ml_e_cnt += 1
   IF (ml_e_cnt > size(ed_adm_ext->encntrs,5))
    stat = alterlist(ed_adm_ext->encntrs,ml_e_cnt)
   ENDIF
   ed_adm_ext->encntrs[ml_e_cnt].mf_encntr_id = e.encntr_id, ed_adm_ext->encntrs[ml_e_cnt].
   ms_patient_fin = ea1.alias, ed_adm_ext->encntrs[ml_e_cnt].mf_person_id = p.person_id,
   ed_adm_ext->encntrs[ml_e_cnt].ms_patient_mrn = ea.alias, ed_adm_ext->encntrs[ml_e_cnt].
   ms_patient_age = trim(cnvtage(cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz),1),ce
     .event_end_dt_tm,0),3), ed_adm_ext->encntrs[ml_e_cnt].ms_patient_lname = p.name_full_formatted,
   ed_adm_ext->encntrs[ml_e_cnt].ms_admit_form_sign_dt = format(cnvtdatetime(ce.event_end_dt_tm),
    "MM/DD/YY HH:MM;;q"), ed_adm_ext->encntrs[ml_e_cnt].ms_pat_stat_ord_dt = format(cnvtdatetime(o
     .current_start_dt_tm),"MM/DD/YY HH:MM;;d"), ed_adm_ext->encntrs[ml_e_cnt].ms_pat_stat_order =
   uar_get_code_display(o.catalog_cd),
   ed_adm_ext->encntrs[ml_e_cnt].mc_pat_adm_prov_lname = ep.name_full_formatted, ed_adm_ext->encntrs[
   ml_e_cnt].ms_prov_reltn = uar_get_code_display(epr1.encntr_prsnl_r_cd)
  FOOT REPORT
   stat = alterlist(ed_adm_ext->encntrs,ml_e_cnt)
  WITH nocounter
 ;end select
 CALL echorecord(ed_adm_ext)
 IF (curqual < 1)
  GO TO exit_script
 ENDIF
 SELECT DISTINCT INTO ed_adm_rpt_file
  FROM (dummyt d  WITH seq = size(ed_adm_ext->encntrs,5))
  ORDER BY ed_adm_ext->encntrs[d.seq].ms_pat_stat_order, ed_adm_ext->encntrs[d.seq].
   mc_pat_adm_prov_lname
  HEAD REPORT
   ms_line = build("Provider LName",mc_delimiter,"Provider FName",mc_delimiter,"Admitting MR Reltn",
    mc_delimiter,"Pat LName",mc_delimiter,"Pat FName",mc_delimiter,
    "Pat Age",mc_delimiter,"MRN ",mc_delimiter,"Account #",
    mc_delimiter,"Date/Time ED ADM Form Signed",mc_delimiter,"Date/time of Status Order ",
    mc_delimiter,
    "First Status Order"), row 0, col 0,
   ms_line
  DETAIL
   ms_line = build(ed_adm_ext->encntrs[d.seq].mc_pat_adm_prov_lname,mc_delimiter,trim(ed_adm_ext->
     encntrs[d.seq].ms_prov_reltn,3),mc_delimiter,trim(ed_adm_ext->encntrs[d.seq].ms_patient_lname,3),
    mc_delimiter,trim(ed_adm_ext->encntrs[d.seq].ms_patient_age,3),mc_delimiter,trim(ed_adm_ext->
     encntrs[d.seq].ms_patient_mrn,3),mc_delimiter,
    trim(ed_adm_ext->encntrs[d.seq].ms_patient_fin,3),mc_delimiter,trim(ed_adm_ext->encntrs[d.seq].
     ms_admit_form_sign_dt,3),mc_delimiter,trim(ed_adm_ext->encntrs[d.seq].ms_pat_stat_ord_dt,3),
    mc_delimiter,trim(ed_adm_ext->encntrs[d.seq].ms_pat_stat_order,3)), row + 1, col 0,
   ms_line
  WITH nocounter, formfeed = none, maxcol = 2000,
   format = variable, maxrow = 1
 ;end select
 CALL echo("emailing")
 SET email_list = concat("carol.richardson@bhs.org,bonnie.geld@bhs.org,christine.bryson@bhs.org",
  "roy.sittig@bhs.org,beverly.siano@bhs.org,steven.downs@bhs.org,tracy.baker@bhs.org")
 SET ms_tmp_str = concat("Files Emailed ",format(sysdate,"dd-mmm-yyyy hh:mm:ss;;d"))
 CALL emailfile(concat("$bhscust/",ms_email_filename),concat("$bhscust/",ms_email_filename),
  email_list,ms_tmp_str,1)
#exit_script
END GO
