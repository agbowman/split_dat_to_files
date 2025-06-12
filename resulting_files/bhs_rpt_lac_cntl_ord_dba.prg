CREATE PROGRAM bhs_rpt_lac_cntl_ord:dba
 PROMPT
  "FACILITY:" = - (l)
  WITH facility
 EXECUTE bhs_sys_stand_subroutine
 FREE RECORD cntl_lac_svc
 RECORD cntl_lac_svc(
   1 md_beg_dt_tm = dq8
   1 md_end_dt_tm = dq8
   1 encntrs[*]
     2 mf_encntr_id = f8
     2 ms_patient_fin = vc
     2 ms_patient_mrn = vc
     2 ms_patient_name = vc
     2 ms_orig_order_dt_tm = vc
     2 mf_order_id = f8
     2 ms_rsn_for_consult = vc
     2 mc_ord_provider = vc
 ) WITH protect
 FREE RECORD lac_nurse_units
 RECORD lac_nurse_units(
   1 nrsunts[*]
     2 mf_nurse_unit = f8
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
 SET cntl_lac_svc->md_beg_dt_tm = cnvtdatetime((curdate - days),000000)
 SET cntl_lac_svc->md_end_dt_tm = cnvtdatetime(curdate,235900)
 CALL echo("TIMES:")
 CALL echo(format(cnvtdatetime(cntl_lac_svc->md_beg_dt_tm),";;q"))
 CALL echo(format(cnvtdatetime(cntl_lac_svc->md_end_dt_tm),";;q"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_inpatient_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"INPATIENT"))
 DECLARE mf_dischip_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"DISCHIP"))
 DECLARE mf_lac_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "CONSULTLACTATIONSERVICES"))
 DECLARE mf_orddoc_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",333,"ORDERDOC"))
 DECLARE mf_consult_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6000,"CONSULTS"))
 DECLARE mf_nnura_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"NNURA"))
 DECLARE mf_nnurb_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"NNURB"))
 DECLARE mf_nnurc_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"NNURC"))
 DECLARE mf_nnurd_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"NNURD"))
 DECLARE mf_nccn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"NCCN"))
 DECLARE mf_ldrpa_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"LDRPA"))
 DECLARE mf_ldrpb_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"LDRPB"))
 DECLARE mf_ldrpc_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"LDRPC"))
 DECLARE mf_win2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"WIN2"))
 DECLARE mf_obgn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",220,"OBGN"))
 DECLARE mf_cd_set = f8 WITH protect, constant(220)
 SET mf_nsy_cd = 688877.00
 SET mf_nicu_cd = 686915.00
 DECLARE mc_delimiter = c1 WITH protect, noconstant(",")
 DECLARE ms_line = vc WITH protect, noconstant(" ")
 DECLARE ms_start_date = vc WITH protect, noconstant(" ")
 DECLARE ms_end_date = vc WITH protect, noconstant(" ")
 DECLARE ms_prev_reason = vc WITH protect, noconstant(" ")
 DECLARE ms_email_filename = vc WITH protect, noconstant(" ")
 DECLARE ms_dclcom_str = vc WITH protect, noconstant(" ")
 DECLARE ms_temp_prov = vc WITH protect, noconstant(" ")
 DECLARE mf_fac_cd = f8 WITH protect, noconstant(0.0)
 DECLARE ml_test_ind = i4 WITH protect, noconstant(0)
 DECLARE ml_e_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_pat_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_tot_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_n_cnt = i4 WITH protect, noconstant(0)
 IF (( $FACILITY="BMC"))
  SET logical lac_cntl_rpt_file "bhscust:bhs_rpt_bmclac_svc_ord3.csv"
  SET ms_email_filename = "bhs_rpt_bmclac_svc_ord3.csv"
 ENDIF
 IF (( $FACILITY="BFMC"))
  SET logical lac_cntl_rpt_file "bhscust:bhs_rpt_fmclac_svc_ord3.csv"
  SET ms_email_filename = "bhs_rpt_fmclac_svc_ord3.csv"
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=mf_cd_set
    AND cv.code_value IN (mf_nnura_cd, mf_nnurb_cd, mf_nnurc_cd, mf_nnurd_cd, mf_obgn_cd,
   mf_nicu_cd, mf_nccn_cd, mf_ldrpa_cd, mf_ldrpb_cd, mf_ldrpc_cd,
   mf_win2_cd, mf_nsy_cd)
    AND cv.active_ind=1
    AND cv.cdf_meaning=trim("NURSEUNIT",3)
    AND cv.data_status_cd=mf_auth_cd)
  HEAD REPORT
   ml_n_cnt = 0
  DETAIL
   ml_n_cnt = (ml_n_cnt+ 1), stat = alterlist(lac_nurse_units->nrsunts,ml_n_cnt)
   IF (( $FACILITY="BMC")
    AND ((cv.code_value=mf_nnura_cd) OR (((mf_nnurb_cd) OR (((mf_nnurc_cd) OR (((mf_nnurd_cd) OR (((
   mf_nicu_cd) OR (((mf_nccn_cd) OR (((mf_ldrpa_cd) OR (((mf_ldrpb_cd) OR (((mf_ldrpc_cd) OR (
   mf_win2_cd)) )) )) )) )) )) )) )) )) )
    lac_nurse_units->nrsunts[ml_n_cnt].mf_nurse_unit = cv.code_value
   ENDIF
   IF (( $FACILITY="BFMC")
    AND ((cv.code_value=mf_nsy_cd) OR (mf_obgn_cd)) )
    lac_nurse_units->nrsunts[ml_n_cnt].mf_nurse_unit = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual < 1)
  GO TO exit_script
 ENDIF
 SELECT DISTINCT INTO "nl:"
  elh.encntr_id, elh.beg_effective_dt_tm
  FROM code_value cv,
   (dummyt d  WITH seq = size(lac_nurse_units->nrsunts,5)),
   encntr_loc_hist elh
  PLAN (cv
   WHERE cv.code_set=mf_cd_set
    AND (cv.display_key= $FACILITY)
    AND cv.active_ind=1
    AND cv.cdf_meaning=trim("FACILITY",3)
    AND cv.data_status_cd=mf_auth_cd)
   JOIN (d)
   JOIN (elh
   WHERE elh.loc_facility_cd=cv.code_value
    AND elh.active_ind=1
    AND expand(ml_n_cnt,1,size(lac_nurse_units->nrsunts,5),elh.loc_nurse_unit_cd,lac_nurse_units->
    nrsunts[d.seq].mf_nurse_unit)
    AND elh.encntr_type_cd IN (mf_inpatient_cd, mf_dischip_cd)
    AND elh.beg_effective_dt_tm BETWEEN cnvtdatetime(cntl_lac_svc->md_beg_dt_tm) AND cnvtdatetime(
    cntl_lac_svc->md_end_dt_tm))
  ORDER BY elh.encntr_id
  DETAIL
   ml_e_cnt = (ml_e_cnt+ 1), stat = alterlist(cntl_lac_svc->encntrs,ml_e_cnt), cntl_lac_svc->encntrs[
   ml_e_cnt].mf_encntr_id = elh.encntr_id
  WITH nocounter
 ;end select
 IF (curqual < 1)
  GO TO exit_script
 ENDIF
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = size(cntl_lac_svc->encntrs,5)),
   encounter e,
   orders o,
   person p,
   encntr_alias ea,
   encntr_alias ea1,
   order_action oa,
   order_detail od,
   prsnl ep
  PLAN (d)
   JOIN (o
   WHERE o.encntr_id=outerjoin(cntl_lac_svc->encntrs[d.seq].mf_encntr_id)
    AND o.catalog_cd=mf_lac_cd
    AND o.active_ind=1
    AND o.orig_order_dt_tm BETWEEN cnvtdatetime(cntl_lac_svc->md_beg_dt_tm) AND cnvtdatetime(
    cntl_lac_svc->md_end_dt_tm))
   JOIN (e
   WHERE e.encntr_id=outerjoin(o.encntr_id)
    AND e.active_ind=1)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1)
   JOIN (ea
   WHERE ea.encntr_id=outerjoin(e.encntr_id)
    AND ea.active_ind=outerjoin(1)
    AND ea.encntr_alias_type_cd=outerjoin(mf_mrn_cd))
   JOIN (ea1
   WHERE ea1.encntr_id=outerjoin(e.encntr_id)
    AND ea1.active_ind=outerjoin(1)
    AND ea1.encntr_alias_type_cd=outerjoin(mf_fin_cd))
   JOIN (od
   WHERE od.order_id=o.order_id
    AND od.detail_sequence=1)
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_dt_tm BETWEEN cnvtdatetime(cntl_lac_svc->md_beg_dt_tm) AND cnvtdatetime(
    cntl_lac_svc->md_end_dt_tm))
   JOIN (ep
   WHERE ep.person_id=oa.order_provider_id)
  ORDER BY o.encntr_id
  HEAD REPORT
   o.encntr_id, ml_pat_cnt = 0
  HEAD o.encntr_id
   ml_pat_cnt = (ml_pat_cnt+ 1), stat = alterlist(cntl_lac_svc->encntrs,ml_pat_cnt), cntl_lac_svc->
   encntrs[ml_pat_cnt].ms_patient_name = p.name_full_formatted,
   cntl_lac_svc->encntrs[ml_pat_cnt].ms_patient_mrn = ea.alias, cntl_lac_svc->encntrs[ml_pat_cnt].
   mf_encntr_id = e.encntr_id, cntl_lac_svc->encntrs[ml_pat_cnt].ms_patient_fin = ea1.alias,
   cntl_lac_svc->encntrs[ml_pat_cnt].ms_orig_order_dt_tm = format(cnvtdatetime(o.orig_order_dt_tm),
    "MM/DD/YY HH:MM;;q"), cntl_lac_svc->encntrs[ml_pat_cnt].mf_order_id = o.order_id, cntl_lac_svc->
   encntrs[ml_pat_cnt].ms_rsn_for_consult = trim(od.oe_field_display_value,3),
   ms_temp_prov = replace(ep.name_full_formatted,","," ",1), cntl_lac_svc->encntrs[ml_pat_cnt].
   mc_ord_provider = ms_temp_prov
  FOOT REPORT
   stat = alterlist(cntl_lac_svc->encntrs,ml_pat_cnt)
  WITH nocounter
 ;end select
 IF (curqual < 1)
  GO TO exit_script
 ENDIF
 SELECT INTO lac_cntl_rpt_file
  FROM (dummyt d  WITH seq = size(cntl_lac_svc->encntrs,5))
  PLAN (d)
  ORDER BY cntl_lac_svc->encntrs[d.seq].ms_rsn_for_consult
  HEAD REPORT
   ml_test_ind = 1, ms_prev_reason = trim(cntl_lac_svc->encntrs[d.seq].ms_rsn_for_consult,3),
   ms_start_date = format(cnvtdatetime(cntl_lac_svc->md_beg_dt_tm),"MM/DD/YY;;d"),
   ms_end_date = format(cnvtdatetime(cntl_lac_svc->md_end_dt_tm),"MM/DD/YY;;d"), ms_line = build(
     $FACILITY," Lactation Services - Total Patients with CIS Ordered Consults "), row + 1,
   col 0, ms_line, ms_line = build("From: ",ms_start_date," To: ",ms_end_date),
   row + 1, col 0, ms_line,
   ms_line = build("PATIENT LNAME",mc_delimiter,"PATIENT FNAME",mc_delimiter,"  MRN",
    mc_delimiter,"ACCT NBR",mc_delimiter,"DT/TM ORDER ENTERED",mc_delimiter,
    "ORDERING PROV",mc_delimiter,"RSN FOR CONSULT"), row + 2, col 0,
   ms_line
  DETAIL
   ms_line = build(cntl_lac_svc->encntrs[d.seq].ms_patient_name,mc_delimiter,cntl_lac_svc->encntrs[d
    .seq].ms_patient_mrn,mc_delimiter,cntl_lac_svc->encntrs[d.seq].ms_patient_fin,
    mc_delimiter,cntl_lac_svc->encntrs[d.seq].ms_orig_order_dt_tm,mc_delimiter,cntl_lac_svc->encntrs[
    d.seq].mc_ord_provider,mc_delimiter,
    cntl_lac_svc->encntrs[d.seq].ms_rsn_for_consult), ml_tot_cnt = (ml_tot_cnt+ 1), row + 1,
   col 0, ms_line
  FOOT REPORT
   row + 1, col 16, "Total Patients with CIS Ordered Latation Consults: ",
   col + 1, ml_tot_cnt, row + 2,
   col 10, "***** END OF REPORT *****", stat = alterlist(cntl_lac_svc->encntrs,ml_pat_cnt)
  WITH nocounter, formfeed = none, maxcol = 2000,
   format = variable, maxrow = 1
 ;end select
 CALL echo("emailing")
 IF (ml_test_ind=1)
  SET email_list = "tracy.baker@bhs.org"
 ELSE
  IF (( $FACILITY="BMC"))
   SET email_list = "shirley.hamill@bhs.org,steven.downs@bhs.org,tracy.baker@bhs.org"
  ENDIF
  IF (( $FACILITY="BFMC"))
   SET email_list = "tracy.baker@bhs.org,linda.west@bhs.org,steven.downs@bhs.org"
  ENDIF
 ENDIF
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
