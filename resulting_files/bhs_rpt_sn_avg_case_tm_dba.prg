CREATE PROGRAM bhs_rpt_sn_avg_case_tm:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Pick Location" = 999999,
  "Surgeon Last Name" = "",
  "Select Surgeon" = 999999,
  "Recipient's Email" = ""
  WITH outdev, f_location, s_prsnl_last_name,
  f_surgeon_id, s_recipients
 FREE RECORD frec
 RECORD frec(
   1 file_name = vc
   1 file_buf = vc
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
 )
 RECORD rec(
   1 l_cnt = i4
   1 data[*]
     2 s_surgeon_name = vc
     2 s_surgical_area = vc
     2 s_proc_code = vc
     2 s_procedure_disp = vc
     2 s_procedure_desc = vc
     2 s_specialty = vc
     2 s_case_level = vc
     2 s_wound_class = vc
     2 s_anesthesia_type = vc
     2 s_subproc_dur = vc
     2 i_def_proc_dur = i4
     2 i_def_setup_dur = i4
     2 i_def_cleanup_dur = i4
     2 i_def_pre_incision_dur = i4
     2 i_def_post_closure_dur = i4
     2 i_hist_dur = i4
     2 i_hist_setup_dur = i4
     2 i_hist_cleanup_dur = i4
     2 i_hist_pre_incision_dur = i4
     2 i_hist_post_closure_dur = i4
     2 i_recent_proc_dur = i4
     2 i_recent_setup_dur = i4
     2 i_recent_cleanup_dur = i4
     2 i_recent_pre_incision_dur = i4
     2 i_recent_post_closure_dur = i4
     2 s_ancillary_name = vc
     2 s_primary_name = vc
     2 f_update_date = f8
     2 s_update_by = vc
 ) WITH protect
 EXECUTE bhs_ma_email_file
 DECLARE mf_6011_ancillary_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6011,
   "ANCILLARY"))
 DECLARE mf_6011_primary_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6011,"PRIMARY"))
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_num = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE mn_ops = i2 WITH protect, noconstant(0)
 DECLARE ms_error = vc WITH protect, noconstant(" ")
 DECLARE ms_temp = vc WITH protect, noconstant(" ")
 DECLARE ms_recipients = vc WITH protect, noconstant(trim( $S_RECIPIENTS))
 DECLARE ms_pick_loc = vc WITH protect, noconstant(" ")
 DECLARE ms_location_p = vc WITH protect, noconstant(" ")
 DECLARE ms_subject = vc WITH protect, noconstant(" ")
 DECLARE ms_surgeon_id_p = vc WITH protect, noconstant(" ")
 IF (( $F_LOCATION=999999))
  SET ms_location_p = "1=1"
 ELSE
  SET ms_location_p = cnvtstring( $F_LOCATION)
  SET ms_location_p = concat("s.surg_area_cd = ",trim(ms_location_p))
 ENDIF
 IF (( $F_SURGEON_ID=999999))
  SET ms_surgeon_id_p = "1=1"
 ELSE
  SET ms_surgeon_id_p = cnvtstring( $F_SURGEON_ID)
  SET ms_surgeon_id_p = concat("d.prsnl_id =",trim(ms_surgeon_id_p))
 ENDIF
 CALL echo(parser(ms_surgeon_id_p))
 SELECT DISTINCT INTO "nl:"
  surgeon_name = p1.name_full_formatted, surgical_area = uar_get_code_display(s.surg_area_cd),
  proc_code = uar_get_code_display(s.ud5_cd),
  procedure_desc = uar_get_code_description(s.catalog_cd), procedure_disp = uar_get_code_display(s
   .catalog_cd), specialty = uar_get_code_display(pg.prsnl_group_type_cd),
  case_level = uar_get_code_display(s.case_level_cd), wound_class = uar_get_code_display(s
   .wound_class_cd), anesthesia_type = uar_get_code_display(s.anesthesia_type_cd),
  subproc_dur = uar_get_code_display(s.ud4_cd), def_proc_dur = d.def_procedure_dur, def_setup_dur = d
  .def_setup_dur,
  def_cleanup_dur = d.def_cleanup_dur, def_pre_incision_dur = d.def_pre_incision_dur,
  def_post_closure_dur = d.def_post_closure_dur,
  hist_dur = d.hist_procedure_dur, hist_setup_dur = d.hist_setup_dur, hist_cleanup_dur = d
  .hist_cleanup_dur,
  hist_pre_incision_dur = d.hist_pre_incision_dur, hist_post_closure_dur = d.hist_post_closure_dur,
  recent_proc_dur = d.rec_procedure_dur,
  recent_setup_dur = d.rec_setup_dur, recent_cleanup_dur = d.rec_cleanup_dur, recent_pre_incision_dur
   = d.rec_pre_incision_dur,
  recent_post_closure_dur = d.rec_post_closure_dur, ancillary_name = ocs.mnemonic, primary_name =
  ocs2.mnemonic,
  update_date = s.updt_dt_tm, update_by = p2.name_full_formatted
  FROM surg_proc_detail s,
   surg_proc_duration d,
   order_catalog oc,
   order_catalog_synonym ocs,
   order_catalog_synonym ocs2,
   prsnl p1,
   prsnl p2,
   prsnl_group pg
  PLAN (s
   WHERE parser(ms_location_p))
   JOIN (d
   WHERE d.surg_proc_detail_id=s.surg_proc_detail_id
    AND parser(ms_surgeon_id_p))
   JOIN (oc
   WHERE oc.catalog_cd=s.catalog_cd)
   JOIN (ocs
   WHERE ocs.catalog_cd=oc.catalog_cd
    AND ocs.mnemonic_type_cd=mf_6011_ancillary_cd
    AND substring(1,1,ocs.mnemonic) IN ("0", "4", "6"))
   JOIN (ocs2
   WHERE ocs2.catalog_cd=oc.catalog_cd
    AND ocs2.mnemonic_type_cd=mf_6011_primary_cd)
   JOIN (p1
   WHERE p1.person_id=outerjoin(d.prsnl_id))
   JOIN (p2
   WHERE p2.person_id=outerjoin(s.updt_id))
   JOIN (pg
   WHERE pg.prsnl_group_id=outerjoin(s.surg_specialty_id))
  HEAD REPORT
   ml_cnt = 0
  DETAIL
   ml_cnt = (ml_cnt+ 1)
   IF (size(rec->data,5) < ml_cnt)
    CALL alterlist(rec->data,(ml_cnt+ 50))
   ENDIF
   rec->data[ml_cnt].s_surgeon_name = p1.name_full_formatted, rec->data[ml_cnt].s_surgical_area =
   uar_get_code_display(s.surg_area_cd), rec->data[ml_cnt].s_proc_code = uar_get_code_display(s
    .ud5_cd),
   rec->data[ml_cnt].s_procedure_desc = uar_get_code_description(s.catalog_cd), rec->data[ml_cnt].
   s_procedure_disp = uar_get_code_display(s.catalog_cd), rec->data[ml_cnt].s_specialty =
   uar_get_code_display(pg.prsnl_group_type_cd),
   rec->data[ml_cnt].s_case_level = uar_get_code_display(s.case_level_cd), rec->data[ml_cnt].
   s_wound_class = uar_get_code_display(s.wound_class_cd), rec->data[ml_cnt].s_anesthesia_type =
   uar_get_code_display(s.anesthesia_type_cd),
   rec->data[ml_cnt].s_subproc_dur = uar_get_code_display(s.ud4_cd), rec->data[ml_cnt].i_def_proc_dur
    = d.def_procedure_dur, rec->data[ml_cnt].i_def_setup_dur = d.def_setup_dur,
   rec->data[ml_cnt].i_def_cleanup_dur = d.def_cleanup_dur, rec->data[ml_cnt].i_def_pre_incision_dur
    = d.def_pre_incision_dur, rec->data[ml_cnt].i_def_post_closure_dur = d.def_post_closure_dur,
   rec->data[ml_cnt].i_hist_dur = d.hist_procedure_dur, rec->data[ml_cnt].i_hist_setup_dur = d
   .hist_setup_dur, rec->data[ml_cnt].i_hist_cleanup_dur = d.hist_cleanup_dur,
   rec->data[ml_cnt].i_hist_pre_incision_dur = d.hist_pre_incision_dur, rec->data[ml_cnt].
   i_hist_post_closure_dur = d.hist_post_closure_dur, rec->data[ml_cnt].i_recent_proc_dur = d
   .rec_procedure_dur,
   rec->data[ml_cnt].i_recent_setup_dur = d.rec_setup_dur, rec->data[ml_cnt].i_recent_cleanup_dur = d
   .rec_cleanup_dur, rec->data[ml_cnt].i_recent_pre_incision_dur = d.rec_pre_incision_dur,
   rec->data[ml_cnt].i_recent_post_closure_dur = d.rec_post_closure_dur, rec->data[ml_cnt].
   s_ancillary_name = ocs.mnemonic, rec->data[ml_cnt].s_primary_name = ocs2.mnemonic,
   rec->data[ml_cnt].f_update_date = s.updt_dt_tm, rec->data[ml_cnt].s_update_by = p2
   .name_full_formatted
  FOOT REPORT
   CALL alterlist(rec->data,ml_cnt), rec->l_cnt = ml_cnt
  WITH nocounter, separator = " ", format
 ;end select
 IF (curqual=0)
  SET ms_error = "No Data Found."
  GO TO exit_program
 ENDIF
 IF (textlen( $S_RECIPIENTS) > 1)
  SET frec->file_name = build("bhs_rpt_sn_avg_case_tm",format(cnvtdatetime(curdate,curtime3),
    "YYYYMMDD;;D"),".csv")
  SET frec->file_name = replace(frec->file_name,"/","_",0)
  SET frec->file_name = replace(frec->file_name," ","_",0)
  SET ms_subject = build2("SN Avg Case Report ",trim(format(cnvtdatetime(curdate,curtime3),
     "YYYYMMDD;;D")))
  SET frec->file_buf = "w"
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = build('"Surgeon Name",','"Surgical Area",','"Proc Code",',
   '"Procedure Description",','"Procedure Display",',
   '"Specialty",','"Case Level",','"Wound Class",','"Anesthesia Type",','"Subproc Dur",',
   '"def_proc_dur",','"def_setup_dur",','"def_cleanup_dur",','"def_pre_incision_dur",',
   '"def_post_closure_dur",',
   '"hist_dur",','"hist_setup_dur",','"hist_cleanup_dur",','"hist_pre_incision_dur",',
   '"hist_post_closure_dur",',
   '"recent_proc_dur",','"recent_setup_dur",','"recent_cleanup_dur",','"recent_pre_incision_dur",',
   '"recent_post_closure_dur",',
   '"ancillary_name",','"primary_name",','"update_date",','"update_by",','"',
   char(13))
  SET stat = cclio("WRITE",frec)
  FOR (ml_idx = 1 TO rec->l_cnt)
   SET frec->file_buf = build('"',trim(rec->data[ml_idx].s_surgeon_name,3),'","',trim(rec->data[
     ml_idx].s_surgical_area,3),'","',
    trim(rec->data[ml_idx].s_proc_code,3),'","',trim(rec->data[ml_idx].s_procedure_desc,3),'","',trim
    (rec->data[ml_idx].s_procedure_disp,3),
    '","',trim(rec->data[ml_idx].s_specialty,3),'","',trim(rec->data[ml_idx].s_case_level,3),'","',
    trim(rec->data[ml_idx].s_wound_class,3),'","',trim(rec->data[ml_idx].s_anesthesia_type,3),'","',
    trim(rec->data[ml_idx].s_subproc_dur,3),
    '","',rec->data[ml_idx].i_def_proc_dur,'","',rec->data[ml_idx].i_def_setup_dur,'","',
    rec->data[ml_idx].i_def_cleanup_dur,'","',rec->data[ml_idx].i_def_pre_incision_dur,'","',rec->
    data[ml_idx].i_def_post_closure_dur,
    '","',rec->data[ml_idx].i_hist_dur,'","',rec->data[ml_idx].i_hist_setup_dur,'","',
    rec->data[ml_idx].i_hist_cleanup_dur,'","',rec->data[ml_idx].i_hist_pre_incision_dur,'","',rec->
    data[ml_idx].i_hist_post_closure_dur,
    '","',rec->data[ml_idx].i_recent_proc_dur,'","',rec->data[ml_idx].i_recent_setup_dur,'","',
    rec->data[ml_idx].i_recent_cleanup_dur,'","',rec->data[ml_idx].i_recent_pre_incision_dur,'","',
    rec->data[ml_idx].i_recent_post_closure_dur,
    '","',trim(rec->data[ml_idx].s_ancillary_name,3),'","',trim(rec->data[ml_idx].s_primary_name,3),
    '","',
    format(rec->data[ml_idx].f_update_date,"mm/dd/yy;;d"),'","',trim(rec->data[ml_idx].s_update_by,3),
    '"',char(13))
   SET stat = cclio("WRITE",frec)
  ENDFOR
  SET stat = cclio("CLOSE",frec)
  CALL emailfile(value(frec->file_name),frec->file_name,concat('"',ms_recipients,'"'),ms_subject,1)
 ELSE
  SELECT INTO value( $OUTDEV)
   surgeon_name = substring(0,200,rec->data[d.seq].s_surgeon_name), surgical_area = substring(0,200,
    rec->data[d.seq].s_surgical_area), proc_code = substring(0,200,rec->data[d.seq].s_proc_code),
   procedure_desc = substring(0,200,rec->data[d.seq].s_procedure_desc), procedure_disp = substring(0,
    200,rec->data[d.seq].s_procedure_disp), specialty = substring(0,200,rec->data[d.seq].s_specialty),
   case_level = substring(0,200,rec->data[d.seq].s_case_level), wound_class = substring(0,200,rec->
    data[d.seq].s_wound_class), anesthesia_type = substring(0,200,rec->data[d.seq].s_anesthesia_type),
   subproc_dur = substring(0,200,rec->data[d.seq].s_subproc_dur), def_proc_dur = rec->data[d.seq].
   i_def_proc_dur, def_setup_dur = rec->data[d.seq].i_def_setup_dur,
   def_cleanup_dur = rec->data[d.seq].i_def_cleanup_dur, def_pre_incision_dur = rec->data[d.seq].
   i_def_pre_incision_dur, def_post_closure_dur = rec->data[d.seq].i_def_post_closure_dur,
   hist_dur = rec->data[d.seq].i_hist_dur, hist_setup_dur = rec->data[d.seq].i_hist_setup_dur,
   hist_cleanup_dur = rec->data[d.seq].i_hist_cleanup_dur,
   hist_pre_incision_dur = rec->data[d.seq].i_hist_pre_incision_dur, hist_post_closure_dur = rec->
   data[d.seq].i_hist_post_closure_dur, recent_proc_dur = rec->data[d.seq].i_recent_proc_dur,
   recent_setup_dur = rec->data[d.seq].i_recent_setup_dur, recent_cleanup_dur = rec->data[d.seq].
   i_recent_cleanup_dur, recent_pre_incision_dur = rec->data[d.seq].i_recent_pre_incision_dur,
   recent_post_closure_dur = rec->data[d.seq].i_recent_post_closure_dur, ancillary_name = substring(0,
    200,rec->data[d.seq].s_ancillary_name), primary_name = substring(0,200,rec->data[d.seq].
    s_primary_name),
   update_date = format(rec->data[d.seq].f_update_date,"mm/dd/yy;;d"), updated_by = substring(0,200,
    rec->data[d.seq].s_update_by)
   FROM (dummyt d  WITH seq = size(rec->data,5))
   PLAN (d)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
#exit_program
 IF (textlen( $S_RECIPIENTS) > 1
  AND textlen(trim(ms_error,3))=0)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    msg1 = "An email of the detailed report has been sent to:", msg2 = build2("    ", $S_RECIPIENTS),
    CALL print(calcpos(36,18)),
    msg1, row + 2, msg2
   WITH dio = 08
  ;end select
 ELSEIF (textlen(trim(ms_error,3)) != 0)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    msg1 = ms_error, row + 1, "{F/1}{CPI/7}",
    CALL print(calcpos(36,18)), msg1
   WITH dio = 08
  ;end select
 ENDIF
END GO
