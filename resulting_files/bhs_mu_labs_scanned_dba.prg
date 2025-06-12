CREATE PROGRAM bhs_mu_labs_scanned:dba
 PROMPT
  "Output to File/Printer/MINE:" = "MINE",
  "Start Dt/Tm:" = cnvtdatetime("15-JUN-2011"),
  "End Dt/Tm  :" = cnvtdatetime("14-SEP-2011")
  WITH outdev, beg_date, end_date
 EXECUTE bhs_hlp_csv
 EXECUTE bhs_hlp_err
 DECLARE ml_debug_flag = i4 WITH protect, constant(validate(bhs_debug_flag,0))
 DECLARE md_beg_dt_tm = dq8 WITH protect, constant(datetimefind(cnvtdatetime( $BEG_DATE),"D","B","B")
  )
 DECLARE md_end_dt_tm = dq8 WITH protect, constant(datetimefind(cnvtdatetime( $END_DATE),"D","E","E")
  )
 DECLARE mf_order_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6003,"ORDER"))
 DECLARE mf_lab = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",93,"LABORATORY"))
 DECLARE mf_lab_scanned = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",93,
   "LABORATORYRESULTSSCANNED"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE mf_npi_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",320,
   "NATIONALPROVIDERIDENTIFIER"))
 DECLARE ms_input_phy_logical = vc WITH protect, constant("mu_in_phy")
 DECLARE ms_dir_loc_mu_in = vc WITH protect, constant(build(logical("bhscust"),"/mu/in/all/"))
 DECLARE ms_dir_loc_mu_out = vc WITH protect, constant(build(logical("bhscust"),"/mu/out/all/"))
 DECLARE ms_mu_file_in_ls = vc WITH protect, constant("bhs_mu_lab_ls.txt")
 DECLARE md_timer_start = dq8 WITH protect, noconstant(sysdate)
 DECLARE md_timer_stop = dq8 WITH protect, noconstant(sysdate)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt2 = i4 WITH protect, noconstant(0)
 DECLARE ml_pos = i4 WITH protect, noconstant(0)
 DECLARE ml_unknown_phy_cnt = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE ms_str = vc WITH protect, noconstant(" ")
 DECLARE ms_line = vc WITH protect, noconstant(" ")
 DECLARE ms_dclcom = vc WITH protect, noconstant(" ")
 FREE RECORD phy
 RECORD phy(
   1 qual[*]
     2 s_phy_name = vc
     2 f_phy_npi = f8
     2 f_phy_pid = f8
     2 l_lab_cnt = i4
     2 l_lab_scan_cnt = i4
 )
 FREE RECORD scan
 RECORD scan(
   1 qual[*]
     2 f_clin_ev_id = f8
     2 f_encntr_id = f8
     2 s_acct_num = vc
     2 s_phy_name = vc
     2 f_phy_npi = f8
     2 f_phy_pid = f8
 )
 IF (validate(mulab_reply->c_status)=0)
  RECORD mulab_reply(
    1 c_status = c1
  )
 ENDIF
 SET mulab_reply->c_status = "F"
 RECORD murf_request(
   1 s_filename = vc
 )
 RECORD murf_reply(
   1 s_file_type = vc
   1 qual[*]
     2 s_fin = vc
     2 d_service_dt_tm = dq8
     2 f_phy_npi = f8
     2 c_ed_ind = c1
   1 c_status = c1
 )
 FREE RECORD mu_in
 RECORD mu_in(
   1 qual[*]
     2 s_filename = vc
 )
 FREE RECORD cv_rs_inv
 RECORD cv_rs_inv(
   1 qual[*]
     2 f_code_value = f8
     2 s_display = cv
 )
 SET logical mu_in_phy "mu_physicians_20110615_20110914.csv"
 CALL echo(build("LOGICAL mu_in_phy :",logical(ms_input_phy_logical)))
 IF (ml_debug_flag >= 1)
  CALL echo(concat("Starting script ",curprog))
 ENDIF
 CALL echo("Load the list of invalid result status codes")
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.active_ind=1
   AND cv.code_set=8
   AND cv.display_key IN ("INERROR", "NOTDONE")
  HEAD REPORT
   mn_cnt = 0
  DETAIL
   mn_cnt = (mn_cnt+ 1), stat = alterlist(cv_rs_inv->qual,mn_cnt), cv_rs_inv->qual[mn_cnt].
   f_code_value = cv.code_value,
   cv_rs_inv->qual[mn_cnt].s_display = cv.display
  FOOT REPORT
   row + 0
  WITH counter
 ;end select
 CALL echo(build("Number of undesired result status code values found:",size(cv_rs_inv->qual,5)))
 IF (bhs_error_thrown(0)=1)
  CALL echo("Error thrown while querying the undesired result status code values.  Exiting.")
  GO TO exit_script
 ENDIF
 CALL echo("Load the list of physicians")
 FREE DEFINE rtl2
 DEFINE rtl2 ms_input_phy_logical
 SELECT INTO "nl:"
  FROM rtl2t r
  WHERE r.line > " "
   AND r.line != "Physician_Name,NPI*"
  HEAD REPORT
   ml_cnt = 0
  DETAIL
   stat = getcsvcolumnatindex(r.line,2,ms_str,",",'"')
   IF (stat=1)
    ml_cnt = (ml_cnt+ 1), stat = alterlist(phy->qual,ml_cnt), phy->qual[ml_cnt].f_phy_npi = cnvtreal(
     ms_str),
    stat = getcsvcolumnatindex(r.line,1,ms_str,",",'"'), phy->qual[ml_cnt].s_phy_name = ms_str
   ENDIF
  FOOT REPORT
   row + 0
  WITH counter
 ;end select
 CALL echo(build("Number of physicians found within the input file:",size(phy->qual,5)))
 IF (bhs_error_thrown(0)=1)
  CALL echo("Error thrown while querying the undesired result status code values.  Exiting.")
  GO TO exit_script
 ENDIF
 CALL echo("Get physician information")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = size(phy->qual,5)),
   prsnl_alias pa,
   prsnl p
  PLAN (d)
   JOIN (pa
   WHERE pa.alias=cnvtstring(phy->qual[d.seq].f_phy_npi)
    AND pa.prsnl_alias_type_cd=mf_npi_cd
    AND pa.active_ind=1
    AND pa.beg_effective_dt_tm < sysdate
    AND pa.end_effective_dt_tm > sysdate)
   JOIN (p
   WHERE p.person_id=pa.person_id)
  DETAIL
   phy->qual[d.seq].f_phy_pid = p.person_id, phy->qual[d.seq].s_phy_name = p.name_full_formatted
  WITH counter
 ;end select
 CALL echo(build("Number of physicians found within CIS:",size(phy->qual,5)))
 IF (ml_debug_flag >= 50)
  CALL echorecord(phy)
 ENDIF
 IF (bhs_error_thrown(0)=1)
  CALL echo("Error thrown while querying physician info.  Exiting.")
  GO TO exit_script
 ENDIF
 CALL echo("Query the discrete labs")
 SELECT INTO "nl:"
  oa.order_provider_id, lab_count = count(ce.clinical_event_id)
  FROM v500_event_set_explode vese,
   code_value cv,
   order_action oa,
   clinical_event ce
  PLAN (vese
   WHERE vese.event_set_cd IN (mf_lab))
   JOIN (cv
   WHERE cv.active_ind=1
    AND cv.code_set=8
    AND cv.display_key IN ("INERROR", "NOTDONE"))
   JOIN (oa
   WHERE expand(ml_idx,1,size(phy->qual,5),oa.order_provider_id,phy->qual[ml_idx].f_phy_pid)
    AND oa.action_type_cd=mf_order_cd
    AND ((oa.action_dt_tm+ 0) BETWEEN datetimeadd(cnvtdatetime(md_beg_dt_tm),- (30)) AND cnvtdatetime
   (md_end_dt_tm)))
   JOIN (ce
   WHERE ce.order_id=oa.order_id
    AND ce.event_end_dt_tm BETWEEN cnvtdatetime(md_beg_dt_tm) AND cnvtdatetime(md_end_dt_tm)
    AND ce.event_cd=vese.event_cd
    AND  NOT (ce.result_status_cd IN (cv.code_value))
    AND ce.view_level > 0
    AND ce.valid_from_dt_tm < sysdate
    AND ce.valid_until_dt_tm > sysdate
    AND ce.event_end_dt_tm < sysdate)
  GROUP BY oa.order_provider_id
  DETAIL
   ml_pos = locateval(ml_idx,1,size(phy->qual,5),oa.order_provider_id,phy->qual[ml_idx].f_phy_pid)
   IF (ml_pos=0)
    stat = alterlist(phy->qual,(size(phy->qual,5)+ 1)), ml_pos = size(phy->qual,5)
   ENDIF
   phy->qual[ml_pos].l_lab_cnt = lab_count
  WITH counter
 ;end select
 CALL echo("Discrete lab querying complete")
 IF (ml_debug_flag >= 80)
  CALL echorecord(phy)
 ENDIF
 IF (bhs_error_thrown(0)=1)
  CALL echo("Error thrown while querying querying the discrete labs.  Exiting.")
  GO TO exit_script
 ENDIF
 CALL echo("Query the scanned labs")
 CALL echo("Locate the input files")
 SET md_timer_stop = sysdate
 CALL echo(concat(curprog," time: ",trim(cnvtstring(datetimediff(md_timer_stop,md_timer_start,4)),3),
   " minutes"))
 SET ms_dclcom = concat("ls -l ",ms_dir_loc_mu_in," > ",ms_dir_loc_mu_out,ms_mu_file_in_ls)
 CALL echo(build("DCL:",ms_dclcom))
 CALL dcl(ms_dclcom,size(trim(ms_dclcom)),stat)
 IF (bhs_error_thrown(0)=1)
  CALL echo("Error thrown while preparing input files.  Exiting.")
  GO TO exit_script
 ENDIF
 SET logical mu_in_ls value(build(ms_dir_loc_mu_out,ms_mu_file_in_ls))
 CALL echo(build("LOGICAL mu_in_ls:",logical("mu_in_ls")))
 FREE DEFINE rtl2
 DEFINE rtl2 "mu_in_ls"
 SELECT INTO "nl:"
  FROM rtl2t r
  WHERE  NOT (r.line IN ("", " ", null))
   AND r.line != "total *"
   AND r.line != "d*"
  HEAD REPORT
   ml_cnt = 0,
   CALL echo("Input files to process:")
  DETAIL
   ms_line = trim(r.line,3)
   IF (mod(ml_cnt,100)=0)
    stat = alterlist(mu_in->qual,(ml_cnt+ 100))
   ENDIF
   ml_cnt = (ml_cnt+ 1), ml_idx = findstring(" ",ms_line,1,1), mu_in->qual[ml_cnt].s_filename =
   substring((ml_idx+ 1),(textlen(ms_line) - ml_idx),ms_line),
   CALL echo(concat("  ",mu_in->qual[ml_cnt].s_filename))
  FOOT REPORT
   stat = alterlist(mu_in->qual,ml_cnt),
   CALL echo(build("Number of files to process:",size(mu_in->qual,5)))
  WITH counter
 ;end select
 IF (bhs_error_thrown(0)=1)
  CALL echo(concat("Error thrown while reading ",ms_mu_file_in_ls,".  Exiting."))
  GO TO exit_script
 ENDIF
 IF (ml_debug_flag >= 10)
  CALL echorecord(mu_in)
 ENDIF
 CALL echo("Read each input file")
 SET md_timer_stop = sysdate
 CALL echo(concat(curprog," time: ",trim(cnvtstring(datetimediff(md_timer_stop,md_timer_start,4)),3),
   " minutes"))
 FOR (ml_cnt = 1 TO size(mu_in->qual,5))
   IF ( NOT ((mu_in->qual[ml_cnt].s_filename IN ("mu_amb_*.csv", "mu_sms_*.csv", "mu_wnerta_*.csv")))
   )
    CALL echo(concat("Skipping input file for invalid file type [",trim(cnvtstring(ml_cnt)),"/",trim(
       cnvtstring(size(mu_in->qual,5))),"] ",
      mu_in->qual[ml_cnt].s_filename))
   ELSE
    CALL echo(concat("Processing input file [",trim(cnvtstring(ml_cnt)),"/",trim(cnvtstring(size(
         mu_in->qual,5))),"] ",
      mu_in->qual[ml_cnt].s_filename))
    SET md_timer_stop = sysdate
    CALL echo(concat(curprog," time: ",trim(cnvtstring(datetimediff(md_timer_stop,md_timer_start,4)),
       3)," minutes"))
    SET stat = initrec(murf_request)
    SET stat = initrec(murf_reply)
    SET murf_request->s_filename = build(ms_dir_loc_mu_in,mu_in->qual[ml_cnt].s_filename)
    EXECUTE bhs_mu_read_file
    IF ((murf_reply->s_file_type IN ("AMBULATORY", "SMS", "WNERTA")))
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(size(murf_reply->qual,5))),
       (dummyt d2  WITH seq = value(size(phy->qual,5))),
       v500_event_set_explode vese,
       encntr_alias ea,
       encounter e,
       clinical_event ce
      PLAN (d)
       JOIN (d2
       WHERE (murf_reply->qual[d.seq].f_phy_npi=phy->qual[d2.seq].f_phy_npi))
       JOIN (vese
       WHERE vese.event_set_cd IN (mf_lab_scanned))
       JOIN (ea
       WHERE (ea.alias=murf_reply->qual[d.seq].s_fin)
        AND ea.encntr_alias_type_cd=mf_fin_cd
        AND ea.active_ind=1
        AND ea.beg_effective_dt_tm < sysdate
        AND ea.end_effective_dt_tm > sysdate)
       JOIN (e
       WHERE e.encntr_id=ea.encntr_id
        AND e.active_ind=1
        AND e.beg_effective_dt_tm < sysdate
        AND e.end_effective_dt_tm > sysdate)
       JOIN (ce
       WHERE ((ce.encntr_id+ 0)=e.encntr_id)
        AND ce.person_id=e.person_id
        AND ce.event_cd=vese.event_cd
        AND ce.event_end_dt_tm BETWEEN cnvtdatetime(md_beg_dt_tm) AND cnvtdatetime(md_end_dt_tm)
        AND  NOT (expand(ml_idx,1,size(cv_rs_inv->qual,5),ce.result_status_cd,cv_rs_inv->qual[ml_idx]
        .f_code_value))
        AND ce.view_level > 0
        AND ce.valid_from_dt_tm < sysdate
        AND ce.valid_until_dt_tm > sysdate
        AND ce.event_end_dt_tm < sysdate)
      DETAIL
       ml_pos = locateval(ml_idx,1,size(scan->qual,5),ce.clinical_event_id,scan->qual[ml_idx].
        f_clin_ev_id)
       IF (ml_pos=0)
        ml_cnt2 = (ml_cnt2+ 1), stat = alterlist(scan->qual,ml_cnt2), scan->qual[ml_cnt2].s_acct_num
         = ea.alias,
        scan->qual[ml_cnt2].f_encntr_id = e.encntr_id, scan->qual[ml_cnt2].f_clin_ev_id = ce
        .clinical_event_id, scan->qual[ml_cnt2].f_phy_npi = murf_reply->qual[d.seq].f_phy_npi,
        ml_pos = locateval(ml_idx,1,size(phy->qual,5),scan->qual[ml_cnt2].f_phy_npi,phy->qual[ml_idx]
         .f_phy_npi)
        IF (ml_pos > 0)
         scan->qual[ml_cnt2].f_phy_pid = phy->qual[ml_pos].f_phy_pid, scan->qual[ml_cnt2].s_phy_name
          = phy->qual[ml_pos].s_phy_name
        ENDIF
       ENDIF
      WITH counter
     ;end select
     CALL echo("Scanned lab querying complete")
     IF (ml_debug_flag >= 80)
      CALL echorecord(phy)
     ENDIF
     IF (bhs_error_thrown(0)=1)
      CALL echo("Error thrown while querying querying the scanned labs.  Exiting.")
      GO TO exit_script
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 CALL echo("Scanned lab querying complete")
 IF (ml_debug_flag >= 80)
  CALL echorecord(phy)
 ENDIF
 IF (bhs_error_thrown(0)=1)
  CALL echo("Error thrown while querying querying the scanned labs.  Exiting.")
  GO TO exit_script
 ENDIF
 CALL echo("Match the scanned labs with the physicians")
 FOR (ml_cnt = 1 TO size(scan->qual,5))
   SET ml_pos = locateval(ml_idx,1,size(phy->qual,5),scan->qual[ml_cnt].f_phy_pid,phy->qual[ml_idx].
    f_phy_pid)
   IF (ml_pos=0)
    SET stat = alterlist(phy->qual,(size(phy->qual,5)+ 1))
    SET ml_pos = size(phy->qual,5)
   ENDIF
   SET phy->qual[ml_pos].l_lab_scan_cnt = (phy->qual[ml_pos].l_lab_scan_cnt+ 1)
 ENDFOR
 CALL echo("Generate Report")
 SELECT INTO value( $OUTDEV)
  FROM (dummyt d  WITH seq = 1)
  DETAIL
   ms_line = concat("phy_name,phy_npi,phy_person_id,lab_cnt,lab_scanned_cnt"), row 0, col 0,
   ms_line
   FOR (ml_cnt = 1 TO size(phy->qual,5))
     ms_line = build('"',phy->qual[ml_cnt].s_phy_name,'"',",",cnvtstring(phy->qual[ml_cnt].f_phy_npi),
      ",",cnvtstring(phy->qual[ml_cnt].f_phy_pid),",",phy->qual[ml_cnt].l_lab_cnt,",",
      phy->qual[ml_cnt].l_lab_scan_cnt), row + 1, col 0,
     ms_line
   ENDFOR
  WITH counter, formfeed = none, format = variable,
   maxcol = 300, maxrow = 1
 ;end select
 CALL echo("Lab querying complete")
 IF (ml_debug_flag >= 80)
  CALL echorecord(phy)
 ENDIF
 IF (bhs_error_thrown(0)=1)
  CALL echo("Error thrown while generating the report.  Exiting.")
  GO TO exit_script
 ENDIF
 SET mulab_reply->c_status = "S"
#exit_script
 IF (validate(murf_request->s_filename) != 0)
  CALL echo(build("MU Acct#'s inputted:",size(murf_reply->qual,5)))
 ENDIF
 SET stat = bhs_clear_error(0)
 CALL echo(concat("Exiting script ",curprog," with status ",mulab_reply->c_status))
END GO
