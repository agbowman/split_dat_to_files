CREATE PROGRAM bhs_mu_qual_amb
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Dt/Tm:" = cnvtdatetime("01-JUL-2011"),
  "End Dt/Tm  :" = cnvtdatetime("29-SEP-2011")
  WITH outdev, beg_date, end_date
 EXECUTE bhs_hlp_err
 EXECUTE bhs_hlp_csv
 EXECUTE bhs_hlp_lock
 CALL echo("Variables and record structures")
 DECLARE mf_sbp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SYSTOLICBLOODPRESSURE"))
 DECLARE mf_dbp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "DIASTOLICBLOODPRESSURE"))
 DECLARE mf_smokingcess_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SMOKINGCESSATION"))
 DECLARE mf_smokingcesspedi_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SMOKINGCESSATIONAMBPEDI"))
 DECLARE mf_num_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",53,"NUM"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE mf_cmrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4,
   "CORPORATEMEDICALRECORDNUMBER"))
 DECLARE notdone_var = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"NOT DONE"))
 DECLARE in_error_var = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"IN ERROR"))
 DECLARE inerrnomut_var = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"INERRNOMUT"))
 DECLARE inerrnoview_var = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"INERRNOVIEW"))
 DECLARE inerror_var = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"INERROR"))
 DECLARE mf_satisfy_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",30281,"SATISFY"))
 DECLARE md_beg_dt_tm = dq8 WITH protect, constant(datetimefind(cnvtdatetime( $BEG_DATE),"D","B","B")
  )
 DECLARE md_end_dt_tm = dq8 WITH protect, constant(datetimefind(cnvtdatetime( $END_DATE),"D","E","E")
  )
 DECLARE ms_output = vc WITH protect, constant(value( $OUTDEV))
 DECLARE ms_dir_loc_mu_in = vc WITH protect, constant(build(logical("bhscust"),"/mu/in/all/"))
 DECLARE ms_dir_loc_mu_out = vc WITH protect, constant(build(logical("bhscust"),"/mu/out/all/"))
 DECLARE ms_mu_file_in_ls = vc WITH protect, constant("bhs_mu_qual_amb_ls.txt")
 DECLARE ms_lock_mu_domain = vc WITH protect, constant("BHS MU Locks")
 DECLARE ms_lock_mu_name = vc WITH protect, constant("Ambulatory Quality Measures Lock")
 DECLARE ml_debug_flag = i4 WITH protect, constant(validate(bhs_debug_flag,0))
 DECLARE mn_unknown = i4 WITH protect, constant(0)
 DECLARE mn_rpt_inpatient = i4 WITH protect, constant(1)
 DECLARE mn_rpt_ambulatory = i4 WITH protect, constant(2)
 DECLARE mn_rpt_sms = i4 WITH protect, constant(3)
 DECLARE mn_rpt_wnerta = i4 WITH protect, constant(4)
 DECLARE ms_input_logical = vc WITH protect, constant("mu_in_qual_amb")
 DECLARE md_timer_start = dq8 WITH protect, noconstant(sysdate)
 DECLARE md_timer_stop = dq8 WITH protect, noconstant(sysdate)
 DECLARE md_service_dt_tm = dq8 WITH protect, noconstant(sysdate)
 DECLARE ms_dclcom = vc WITH protect, noconstant(" ")
 DECLARE ms_line = vc WITH protect, noconstant(" ")
 DECLARE ms_file_out = vc WITH protect, noconstant(" ")
 DECLARE ms_ftp_cmd = vc WITH protect, noconstant(" ")
 DECLARE ms_str = vc WITH protect, noconstant(" ")
 DECLARE ms_fin = vc WITH protect, noconstant(" ")
 DECLARE ms_wnerta_pid = vc WITH protect, noconstant(" ")
 DECLARE ms_service_dt = vc WITH protect, noconstant(" ")
 DECLARE mf_phy_npi = f8 WITH protect, noconstant(0.0)
 DECLARE ml_year = i4 WITH protect, noconstant(0)
 DECLARE ml_month = i4 WITH protect, noconstant(0)
 DECLARE ml_day = i4 WITH protect, noconstant(0)
 DECLARE ml_pos = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt2 = i4 WITH protect, noconstant(0)
 DECLARE ml_rpt_type = i4 WITH protect, noconstant(0)
 DECLARE ml_lock_status = i4 WITH protect, noconstant(rl_lock_status_unknown)
 IF (validate(reply->c_status)=0)
  RECORD reply(
    1 c_status = c1
  )
 ENDIF
 SET reply->c_status = "F"
 FREE RECORD mu_in
 RECORD mu_in(
   1 qual[*]
     2 s_filename = vc
 )
 FREE RECORD input
 RECORD input(
   1 qual[*]
     2 s_fin = vc
     2 d_service_dt_tm = dq8
 )
 FREE RECORD enc
 RECORD enc(
   1 qual[*]
     2 s_fin = vc
     2 d_service_dt_tm = dq8
 )
 FREE RECORD hm_series
 RECORD hm_series(
   1 qual[*]
     2 s_series_name = vc
 )
 SET stat = alterlist(hm_series->qual,4)
 SET hm_series->qual[1].s_series_name = "Influenza"
 SET hm_series->qual[2].s_series_name = "Pap Smear"
 SET hm_series->qual[3].s_series_name = "Mammography"
 SET hm_series->qual[4].s_series_name = "Pneumococcal"
 FREE RECORD bp
 RECORD bp(
   1 qual[*]
     2 f_bp_cd = f8
 )
 SET stat = alterlist(bp->qual,2)
 SET bp->qual[1].f_bp_cd = mf_sbp_cd
 SET bp->qual[2].f_bp_cd = mf_dbp_cd
 FREE RECORD rpt
 RECORD rpt(
   1 enc[*]
     2 f_eid = f8
     2 s_fin = vc
     2 d_beg_encntr_dt_tm = dq8
     2 d_end_encntr_dt_tm = dq8
     2 f_pid = f8
     2 s_name_full_formatted = vc
     2 s_cmrn = vc
     2 d_birth_dt_tm = dq8
     2 c_sex = c1
     2 n_qm1_n = i2
     2 n_qm1_d = i2
     2 n_qm2a_n = i2
     2 n_qm2a_d = i2
     2 n_qm2b_n = i2
     2 n_qm2b_d = i2
     2 n_qm3_n = i2
     2 n_qm3_d = i2
     2 n_qm4_n = i2
     2 n_qm4_d = i2
     2 n_qm5_n = i2
     2 n_qm5_d = i2
     2 n_qm6_n = i2
     2 n_qm6_d = i2
 )
 CALL echo("Begin Logic")
 IF (ml_debug_flag >= 1)
  CALL echo(concat("Starting script ",curprog))
 ENDIF
 IF (bhs_lock(ms_lock_mu_domain,ms_lock_mu_name,1,0,ml_lock_status)=0)
  CALL echo("There is already an instance of this script running.  Exiting...")
  IF (bhs_last_locked(ms_lock_mu_domain,ms_lock_mu_name,rl_lock_success,ms_line)=1)
   CALL echo(ms_line)
  ENDIF
  GO TO exit_script
 ENDIF
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
   mu_in->qual[ml_cnt].s_filename = mu_in->qual[ml_cnt].s_filename,
   CALL echo(concat("  ",mu_in->qual[ml_cnt].s_filename))
  FOOT REPORT
   stat = alterlist(mu_in->qual,ml_cnt),
   CALL echo(build("Number of files to process:",size(mu_in->qual,5)))
  WITH nocounter
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
 SET ml_cnt2 = 0
 FOR (ml_cnt = 1 TO size(mu_in->qual,5))
  IF (cnvtlower(mu_in->qual[ml_cnt].s_filename)="mu_amb_*.csv")
   SET ml_rpt_type = mn_rpt_ambulatory
  ELSEIF ((mu_in->qual[ml_cnt].s_filename="mu_sms_*.csv"))
   SET ml_rpt_type = mn_rpt_sms
  ELSEIF ((mu_in->qual[ml_cnt].s_filename="mu_wnerta_*.csv"))
   SET ml_rpt_type = mn_rpt_wnerta
  ELSE
   SET ml_rpt_type = mn_unknown
   CALL echo(build("Input file does not match any known pattern:",mu_in->qual[ml_cnt].s_filename))
  ENDIF
  IF (ml_rpt_type IN (mn_rpt_ambulatory, mn_rpt_sms, mn_rpt_wnerta))
   CALL echo(concat("Reading input file [",trim(cnvtstring(ml_cnt)),"/",trim(cnvtstring(size(mu_in->
        qual,5))),"] type[",
     trim(build(ml_rpt_type)),"] ",mu_in->qual[ml_cnt].s_filename))
   SET logical mu_in_qual_amb value(build(ms_dir_loc_mu_in,mu_in->qual[ml_cnt].s_filename))
   CALL echo(build("LOGICAL mu_in_qual_amb :",logical(ms_input_logical)))
   IF (findfile(ms_input_logical)=0)
    CALL echo(build('The input file "',logical(ms_input_logical),'" was not found.'))
   ENDIF
   FREE DEFINE rtl2
   DEFINE rtl2 ms_input_logical
   SELECT INTO "nl:"
    FROM rtl2t r
    WHERE r.line > " "
     AND r.line != "Provider,Provider NPI,Patient,Visit Number,MRN,DOB,*"
     AND r.line != "PROVIDER #,PROVIDER NAME,PROVIDER NPI,PATIENT NAME,*"
     AND r.line != "Charge Performing Provider,PRVNPI,Patient Name,*"
    DETAIL
     IF (ml_debug_flag >= 80)
      CALL echo(build("LINE:",r.line))
     ENDIF
     CASE (ml_rpt_type)
      OF mn_rpt_ambulatory:
       stat = getcsvcolumnatindex(r.line,4,ms_str,",",'"'),
       IF (stat=1)
        WHILE (findstring("0",ms_str)=1)
          ms_str = substring(2,(textlen(ms_str) - 1),ms_str)
        ENDWHILE
        ms_fin = ms_str
       ENDIF
       ,stat = getcsvcolumnatindex(r.line,11,ms_str,",",'"'),
       IF (stat=1
        AND textlen(ms_str)=10)
        md_service_dt_tm = cnvtdatetime(cnvtdate2(ms_str,"MM/DD/YYYY"),235959)
       ENDIF
       ,stat = getcsvcolumnatindex(r.line,2,ms_str,",",'"'),
       IF (stat=1)
        mf_phy_npi = cnvtreal(ms_str)
       ENDIF
      OF mn_rpt_sms:
       stat = getcsvcolumnatindex(r.line,5,ms_str,",",'"'),
       IF (stat=1)
        WHILE (findstring("0",ms_str)=1)
          ms_str = substring(2,(textlen(ms_str) - 1),ms_str)
        ENDWHILE
        ms_fin = ms_str
       ENDIF
       ,stat = getcsvcolumnatindex(r.line,12,ms_str,",",'"'),
       IF (stat=1
        AND textlen(ms_str)=10)
        md_service_dt_tm = cnvtdatetime(cnvtdate2(ms_str,"MM/DD/YYYY"),235959)
       ENDIF
       ,stat = getcsvcolumnatindex(r.line,3,ms_str,",",'"'),
       IF (stat=1)
        mf_phy_npi = cnvtreal(ms_str)
       ENDIF
      OF mn_rpt_wnerta:
       ms_fin = " ",stat = getcsvcolumnatindex(r.line,4,ms_str,",",'"'),
       IF (stat=1)
        IF (cnvtint(ms_str) > 0)
         ms_wnerta_pid = ms_str
        ENDIF
        IF (ms_wnerta_pid IN ("", " ", null))
         CALL echo("### WARNING - Invalid WNERTA input file format.  No WNERTA person ID. ###")
        ELSE
         stat = getcsvcolumnatindex(r.line,6,ms_str,",",'"')
         IF (stat=1
          AND textlen(ms_str) > 0)
          ms_service_dt = ms_str, stat = getcsvcolumnatindex(ms_service_dt,1,ms_str,"/",'"'),
          ml_month = cnvtint(ms_str),
          stat = getcsvcolumnatindex(ms_service_dt,2,ms_str,"/",'"'), ml_day = cnvtint(ms_str), stat
           = getcsvcolumnatindex(ms_service_dt,3,ms_str,"/",'"'),
          ml_year = cnvtint(ms_str), ms_service_dt = build(format(ml_month,"##;P0"),"/",format(ml_day,
            "##;P0"),"/",format(ml_year,"####;P0")), md_service_dt_tm = cnvtdatetime(cnvtdate2(
            ms_service_dt,"MM/DD/YYYY"),235959)
          IF (textlen(ms_wnerta_pid) < 6)
           ms_fin = concat("WNR",format(cnvtint(ms_wnerta_pid),"######;P0"),format(md_service_dt_tm,
             "YYMMDD;;D"))
          ELSE
           ms_fin = concat("WNR",ms_wnerta_pid,format(md_service_dt_tm,"YYMMDD;;D"))
          ENDIF
          IF (ml_debug_flag >= 70)
           CALL echo(build("WNERTA enc FIN:",ms_fin))
          ENDIF
         ENDIF
        ENDIF
       ENDIF
       ,stat = getcsvcolumnatindex(r.line,2,ms_str,",",'"'),
       IF (stat=1
        AND cnvtreal(ms_str) > 0.0)
        mf_phy_npi = cnvtreal(ms_str)
       ENDIF
     ENDCASE
     IF ( NOT (ms_fin IN ("", " ", null))
      AND cnvtdatetime(md_service_dt_tm) BETWEEN cnvtdatetime(md_beg_dt_tm) AND cnvtdatetime(
      md_end_dt_tm))
      IF (mod(ml_cnt2,1000)=0)
       stat = alterlist(input->qual,(ml_cnt2+ 1000))
      ENDIF
      ml_cnt2 = (ml_cnt2+ 1), input->qual[ml_cnt2].s_fin = ms_fin, input->qual[ml_cnt2].
      d_service_dt_tm = cnvtdatetime(md_service_dt_tm)
      IF (ml_debug_flag >= 70)
       CALL echo(build("FIN:",input->qual[ml_cnt2].s_fin,", Service date:",format(cnvtdatetime(input
          ->qual[ml_cnt2].d_service_dt_tm),"MM/DD/YYYY;;D")))
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (bhs_error_thrown(0)=1)
    CALL echo("Error thrown while reading the input file...  Exiting.")
    GO TO exit_script
   ENDIF
   SET md_timer_stop = sysdate
   CALL echo(concat(curprog," time: ",trim(cnvtstring(datetimediff(md_timer_stop,md_timer_start,4)),3
      )," minutes"))
   CALL echo(build("Number of encounters so far:",ml_cnt2))
  ELSE
   CALL echo(concat("Skipping input file [",trim(cnvtstring(ml_cnt)),"/",trim(cnvtstring(size(mu_in->
        qual,5))),"] type[",
     trim(build(ml_rpt_type)),"] ",mu_in->qual[ml_cnt].s_filename))
  ENDIF
 ENDFOR
 SET stat = alterlist(input->qual,ml_cnt2)
 SET md_timer_stop = sysdate
 CALL echo(concat(curprog," time: ",trim(cnvtstring(datetimediff(md_timer_stop,md_timer_start,4)),3),
   " minutes"))
 CALL echo(build("Total number of encounters inputted:",size(input->qual,5)))
 SET md_timer_stop = sysdate
 CALL echo(concat(curprog," time: ",trim(cnvtstring(datetimediff(md_timer_stop,md_timer_start,4)),3),
   " minutes"))
 CALL echo("Determine unique encounters")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = size(input->qual,5))
  ORDER BY input->qual[d.seq].s_fin, input->qual[d.seq].d_service_dt_tm DESC
  HEAD REPORT
   ml_cnt2 = 0
  DETAIL
   IF (((ml_cnt2=0) OR ((input->qual[d.seq].s_fin != enc->qual[ml_cnt2].s_fin))) )
    IF (mod(ml_cnt2,1000)=0)
     stat = alterlist(enc->qual,(ml_cnt2+ 1000))
    ENDIF
    ml_cnt2 = (ml_cnt2+ 1), enc->qual[ml_cnt2].s_fin = input->qual[d.seq].s_fin, enc->qual[ml_cnt2].
    d_service_dt_tm = input->qual[d.seq].d_service_dt_tm
   ENDIF
   ms_fin = enc->qual[ml_cnt2].s_fin
  FOOT REPORT
   stat = alterlist(enc->qual,ml_cnt2)
  WITH nocounter
 ;end select
 IF (bhs_error_thrown(0)=1)
  CALL echo("Error thrown while determining unique encounters...  Exiting.")
  GO TO exit_script
 ENDIF
 IF (ml_debug_flag >= 90)
  CALL echorecord(enc)
 ENDIF
 FREE RECORD input
 SET md_timer_stop = sysdate
 CALL echo(concat(curprog," time: ",trim(cnvtstring(datetimediff(md_timer_stop,md_timer_start,4)),3),
   " minutes"))
 CALL echo(build("Number of unique encounters:",ml_cnt2))
 CALL echo("Query the encounters and patient info")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = size(enc->qual,5)),
   encntr_alias ea,
   encounter e,
   person p,
   person_alias pa,
   code_value cv
  PLAN (d)
   JOIN (ea
   WHERE (ea.alias=enc->qual[d.seq].s_fin)
    AND ea.active_ind=1
    AND ea.beg_effective_dt_tm < cnvtdatetime(md_end_dt_tm)
    AND ea.end_effective_dt_tm > cnvtdatetime(md_end_dt_tm)
    AND ea.encntr_alias_type_cd=mf_fin_cd)
   JOIN (e
   WHERE e.encntr_id=ea.encntr_id)
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.active_ind=1
    AND pa.beg_effective_dt_tm < cnvtdatetime(md_end_dt_tm)
    AND pa.end_effective_dt_tm > cnvtdatetime(md_end_dt_tm)
    AND pa.person_alias_type_cd=mf_cmrn_cd)
   JOIN (cv
   WHERE cv.code_value=p.sex_cd
    AND cv.active_ind=1
    AND cv.begin_effective_dt_tm < cnvtdatetime(md_end_dt_tm)
    AND cv.end_effective_dt_tm > cnvtdatetime(md_end_dt_tm))
  ORDER BY p.person_id, d.seq
  HEAD REPORT
   ml_cnt = 0
  HEAD p.person_id
   row + 0
  HEAD d.seq
   ml_cnt = (ml_cnt+ 1), stat = alterlist(rpt->enc,ml_cnt), rpt->enc[ml_cnt].f_eid = e.encntr_id,
   rpt->enc[ml_cnt].s_fin = enc->qual[d.seq].s_fin, rpt->enc[ml_cnt].d_beg_encntr_dt_tm =
   cnvtdatetime(cnvtdate(enc->qual[d.seq].d_service_dt_tm),0), rpt->enc[ml_cnt].d_end_encntr_dt_tm =
   cnvtdatetime(cnvtdate(enc->qual[d.seq].d_service_dt_tm),235959),
   rpt->enc[ml_cnt].f_pid = p.person_id, rpt->enc[ml_cnt].s_name_full_formatted = p
   .name_full_formatted, rpt->enc[ml_cnt].s_cmrn = pa.alias,
   rpt->enc[ml_cnt].d_birth_dt_tm = p.birth_dt_tm, rpt->enc[ml_cnt].c_sex = substring(1,1,cv
    .display_key)
  FOOT  p.person_id
   row + 0
  FOOT  d.seq
   row + 0
  FOOT REPORT
   row + 0
  WITH nocounter
 ;end select
 CALL echo(build("Total number of encounters being reported:",size(rpt->enc,5)))
 IF (size(rpt->enc,5)=0)
  CALL echo("No encounters qualified for reporting.  Generating empty output file.")
  GO TO generate_report
 ENDIF
 IF (bhs_error_thrown(0)=1)
  CALL echo("Error thrown while querying the encounters.  Exiting.")
  GO TO exit_script
 ENDIF
 IF (ml_debug_flag >= 90)
  CALL echorecord(rpt)
 ENDIF
 FREE RECORD enc
 IF (ml_debug_flag >= 95)
  SET ms_dclcom = concat("rm ",ms_dir_loc_mu_out,ms_mu_file_in_ls)
  CALL echo(build("DCL:",ms_dclcom))
  CALL dcl(ms_dclcom,size(trim(ms_dclcom)),stat)
 ENDIF
 SET md_timer_stop = sysdate
 CALL echo(concat(curprog," time: ",trim(cnvtstring(datetimediff(md_timer_stop,md_timer_start,4)),3),
   " minutes"))
 CALL echo("Quality Measures")
 CALL echo("QM1 D Problem of Hypertension")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(rpt->enc,5))),
   problem p,
   bhs_nomen_list bnl
  PLAN (d
   WHERE datetimediff(rpt->enc[d.seq].d_end_encntr_dt_tm,rpt->enc[d.seq].d_birth_dt_tm) > 6574)
   JOIN (p
   WHERE (p.person_id=rpt->enc[d.seq].f_pid)
    AND p.active_ind=1
    AND p.beg_effective_dt_tm < cnvtdatetime(rpt->enc[d.seq].d_end_encntr_dt_tm)
    AND p.end_effective_dt_tm > cnvtdatetime(rpt->enc[d.seq].d_end_encntr_dt_tm)
    AND p.nomenclature_id > 0)
   JOIN (bnl
   WHERE bnl.nomenclature_id=p.nomenclature_id
    AND bnl.active_ind=1
    AND bnl.nomen_list_key="REGISTRY-HYPERTENSION")
  DETAIL
   IF (ml_debug_flag >= 50)
    CALL echo(build("qm1 D1 fin:",rpt->enc[d.seq].s_fin))
   ENDIF
   rpt->enc[d.seq].n_qm1_d = 1
  WITH nocounter
 ;end select
 IF (bhs_error_thrown(0)=1)
  CALL echo("Error thrown on QM1 D1...  Exiting.")
  GO TO exit_script
 ENDIF
 SET md_timer_stop = sysdate
 CALL echo(concat(curprog," time: ",trim(cnvtstring(datetimediff(md_timer_stop,md_timer_start,4)),3),
   " minutes"))
 CALL echo("QM1 D Diagnosis of Hypertension")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(rpt->enc,5))),
   diagnosis p,
   bhs_nomen_list bnl
  PLAN (d
   WHERE (rpt->enc[d.seq].n_qm1_d=0)
    AND datetimediff(rpt->enc[d.seq].d_end_encntr_dt_tm,rpt->enc[d.seq].d_birth_dt_tm) > 6574)
   JOIN (p
   WHERE (p.person_id=rpt->enc[d.seq].f_pid)
    AND p.active_ind=1
    AND p.beg_effective_dt_tm < cnvtdatetime(rpt->enc[d.seq].d_end_encntr_dt_tm)
    AND p.end_effective_dt_tm > cnvtdatetime(rpt->enc[d.seq].d_end_encntr_dt_tm)
    AND p.nomenclature_id > 0)
   JOIN (bnl
   WHERE bnl.nomenclature_id=p.nomenclature_id
    AND bnl.active_ind=1
    AND bnl.nomen_list_key="REGISTRY-HYPERTENSION")
  DETAIL
   IF (ml_debug_flag >= 50)
    CALL echo(build("qm1 D2 fin:",rpt->enc[d.seq].s_fin))
   ENDIF
   rpt->enc[d.seq].n_qm1_d = 1
  WITH nocounter
 ;end select
 IF (bhs_error_thrown(0)=1)
  CALL echo("Error thrown on QM1 D2...  Exiting.")
  GO TO exit_script
 ENDIF
 SET md_timer_stop = sysdate
 CALL echo(concat(curprog," time: ",trim(cnvtstring(datetimediff(md_timer_stop,md_timer_start,4)),3),
   " minutes"))
 CALL echo("QM1 N - Blood Pressure Readings")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(rpt->enc,5))),
   (dummyt d2  WITH seq = value(size(bp->qual,5))),
   clinical_event ce
  PLAN (d
   WHERE (rpt->enc[d.seq].n_qm1_d=1))
   JOIN (d2)
   JOIN (ce
   WHERE (ce.encntr_id=rpt->enc[d.seq].f_eid)
    AND (ce.event_cd=bp->qual[d2.seq].f_bp_cd)
    AND ce.event_class_cd=mf_num_cd
    AND textlen(trim(ce.result_val)) > 0)
  ORDER BY d.seq
  HEAD d.seq
   mn_sbp_ind = 0, mn_dbp_ind = 0
  DETAIL
   IF (ce.event_cd=mf_sbp_cd)
    mn_sbp_ind = 1
   ELSEIF (ce.event_cd=mf_dbp_cd)
    mn_dbp_ind = 1
   ENDIF
  FOOT  d.seq
   IF (mn_sbp_ind=1
    AND mn_dbp_ind=1)
    IF (ml_debug_flag >= 50)
     CALL echo(build("qm1 N1 fin:",rpt->enc[d.seq].s_fin))
    ENDIF
    rpt->enc[d.seq].n_qm1_n = 1
   ENDIF
  WITH nocounter, maxqual(ce,1)
 ;end select
 IF (bhs_error_thrown(0)=1)
  CALL echo("Error thrown on QM1 N1...  Exiting.")
  GO TO exit_script
 ENDIF
 SET md_timer_stop = sysdate
 CALL echo(concat(curprog," time: ",trim(cnvtstring(datetimediff(md_timer_stop,md_timer_start,4)),3),
   " minutes"))
 CALL echo("QM2A D Patients 18+")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(rpt->enc,5)))
  PLAN (d
   WHERE datetimediff(rpt->enc[d.seq].d_end_encntr_dt_tm,rpt->enc[d.seq].d_birth_dt_tm) > 6574)
  DETAIL
   IF (ml_debug_flag >= 50)
    CALL echo(build("qm2a D1 fin:",rpt->enc[d.seq].s_fin))
   ENDIF
   rpt->enc[d.seq].n_qm2a_d = 1
  WITH nocounter
 ;end select
 IF (bhs_error_thrown(0)=1)
  CALL echo("Error thrown on QM2 D1...  Exiting.")
  GO TO exit_script
 ENDIF
 SET md_timer_stop = sysdate
 CALL echo(concat(curprog," time: ",trim(cnvtstring(datetimediff(md_timer_stop,md_timer_start,4)),3),
   " minutes"))
 CALL echo("QM2A N, QM2B D Smoking in Health Maintenance (Tobacco Screening)")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(rpt->enc,5))),
   hm_expect_mod hem,
   hm_expect_sat hes,
   hm_expect he
  PLAN (d
   WHERE (rpt->enc[d.seq].n_qm2a_d=1))
   JOIN (hem
   WHERE (hem.person_id=rpt->enc[d.seq].f_pid)
    AND hem.active_ind=1
    AND hem.modifier_dt_tm > datetimeadd(cnvtdatetime(rpt->enc[d.seq].d_end_encntr_dt_tm),- ((365 * 2
    ))))
   JOIN (hes
   WHERE hes.expect_sat_id=hem.expect_sat_id
    AND hes.active_ind=1)
   JOIN (he
   WHERE he.expect_id=hes.expect_id
    AND he.expect_name="Tobacco Screening"
    AND he.active_ind=1)
  DETAIL
   IF (ml_debug_flag >= 50)
    CALL echo(build("qm2a N1 fin:",rpt->enc[d.seq].s_fin))
   ENDIF
   rpt->enc[d.seq].n_qm2a_n = 1
   IF (hes.expect_sat_name IN ("Second Hand Smoke Exposure", "Counseled today"))
    IF (ml_debug_flag >= 50)
     CALL echo(build("qm2b D1 fin:",rpt->enc[d.seq].s_fin))
    ENDIF
    rpt->enc[d.seq].n_qm2b_d = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (bhs_error_thrown(0)=1)
  CALL echo("Error thrown on QM2 D1...  Exiting.")
  GO TO exit_script
 ENDIF
 SET md_timer_stop = sysdate
 CALL echo(concat(curprog," time: ",trim(cnvtstring(datetimediff(md_timer_stop,md_timer_start,4)),3),
   " minutes"))
 CALL echo("QM2A N, QM2B D Smoking in Health Maintenance (Tobacco Use)")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(rpt->enc,5))),
   hm_expect he,
   hm_expect_sat hes,
   hm_expect_mod hem,
   code_value cv
  PLAN (d
   WHERE (rpt->enc[d.seq].n_qm2a_d=1)
    AND (rpt->enc[d.seq].n_qm2b_d=0))
   JOIN (hem
   WHERE (hem.person_id=rpt->enc[d.seq].f_pid)
    AND hem.active_ind=1
    AND hem.modifier_dt_tm > datetimeadd(cnvtdatetime(rpt->enc[d.seq].d_end_encntr_dt_tm),- ((365 * 2
    ))))
   JOIN (hes
   WHERE hes.expect_sat_id=hem.expect_sat_id
    AND hes.active_ind=1)
   JOIN (he
   WHERE he.expect_id=hes.expect_id
    AND he.expect_name="Tobacco Use"
    AND he.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=hem.modifier_reason_cd
    AND cv.code_set=30443)
  DETAIL
   IF (ml_debug_flag >= 50)
    CALL echo(build("qm2a N2 fin:",rpt->enc[d.seq].s_fin))
   ENDIF
   rpt->enc[d.seq].n_qm2a_n = 1
   IF (cv.display_key="YES")
    IF (ml_debug_flag >= 50)
     CALL echo(build("qm2b D2 fin:",rpt->enc[d.seq].s_fin))
    ENDIF
    rpt->enc[d.seq].n_qm2b_d = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (bhs_error_thrown(0)=1)
  CALL echo("Error thrown on QM2 D2...  Exiting.")
  GO TO exit_script
 ENDIF
 SET md_timer_stop = sysdate
 CALL echo(concat(curprog," time: ",trim(cnvtstring(datetimediff(md_timer_stop,md_timer_start,4)),3),
   " minutes"))
 CALL echo("QM2A N, QM2B D&N Smoking Clinical Event (Smoking Cessation)")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(rpt->enc,5))),
   clinical_event ce
  PLAN (d
   WHERE (rpt->enc[d.seq].n_qm2a_d=1))
   JOIN (ce
   WHERE (ce.person_id=rpt->enc[d.seq].f_pid)
    AND ce.valid_until_dt_tm >= cnvtdatetime(rpt->enc[d.seq].d_end_encntr_dt_tm)
    AND ce.clinsig_updt_dt_tm > datetimeadd(cnvtdatetime(rpt->enc[d.seq].d_end_encntr_dt_tm),- ((365
     * 2)))
    AND ce.event_cd IN (mf_smokingcess_cd, mf_smokingcesspedi_cd)
    AND  NOT (ce.result_status_cd IN (notdone_var, in_error_var, inerror_var, inerrnomut_var,
   inerrnoview_var)))
  DETAIL
   IF (ml_debug_flag >= 50)
    CALL echo(build("qm2a    N1 fin:",rpt->enc[d.seq].s_fin))
   ENDIF
   rpt->enc[d.seq].n_qm2a_n = 1
   IF (ce.result_val IN ("Patient has smoked in the last 12 months"))
    IF (ml_debug_flag >= 50)
     CALL echo(build("qm2b D3 N1 fin:",rpt->enc[d.seq].s_fin))
    ENDIF
    rpt->enc[d.seq].n_qm2b_d = 1, rpt->enc[d.seq].n_qm2b_n = 1
   ELSEIF ((rpt->enc[d.seq].n_qm2b_d=1))
    IF (ml_debug_flag >= 50)
     CALL echo(build("qm2b    N2 fin:",rpt->enc[d.seq].s_fin))
    ENDIF
    rpt->enc[d.seq].n_qm2b_n = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (bhs_error_thrown(0)=1)
  CALL echo("Error thrown on QM2 D&N...  Exiting.")
  GO TO exit_script
 ENDIF
 SET md_timer_stop = sysdate
 CALL echo(concat(curprog," time: ",trim(cnvtstring(datetimediff(md_timer_stop,md_timer_start,4)),3),
   " minutes"))
 CALL echo("QM3 D 50+ years of age")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(rpt->enc,5)))
  PLAN (d
   WHERE datetimediff(rpt->enc[d.seq].d_end_encntr_dt_tm,rpt->enc[d.seq].d_birth_dt_tm) > 18262)
  DETAIL
   IF (ml_debug_flag >= 50)
    CALL echo(build("qm3 D1 fin:",rpt->enc[d.seq].s_fin))
   ENDIF
   rpt->enc[d.seq].n_qm3_d = 1
  WITH nocounter
 ;end select
 IF (bhs_error_thrown(0)=1)
  CALL echo("Error thrown on QM3 D1...  Exiting.")
  GO TO exit_script
 ENDIF
 SET md_timer_stop = sysdate
 CALL echo(concat(curprog," time: ",trim(cnvtstring(datetimediff(md_timer_stop,md_timer_start,4)),3),
   " minutes"))
 CALL echo("QM4 D Female age 18-65")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(rpt->enc,5)))
  PLAN (d
   WHERE datetimediff(rpt->enc[d.seq].d_end_encntr_dt_tm,rpt->enc[d.seq].d_birth_dt_tm) > 6574
    AND datetimediff(rpt->enc[d.seq].d_end_encntr_dt_tm,rpt->enc[d.seq].d_birth_dt_tm) < 23740
    AND (rpt->enc[d.seq].c_sex="F"))
  DETAIL
   IF (ml_debug_flag >= 50)
    CALL echo(build("qm4 D1 fin:",rpt->enc[d.seq].s_fin))
   ENDIF
   rpt->enc[d.seq].n_qm4_d = 1
  WITH nocounter
 ;end select
 IF (bhs_error_thrown(0)=1)
  CALL echo("Error thrown on QM4 D1...  Exiting.")
  GO TO exit_script
 ENDIF
 SET md_timer_stop = sysdate
 CALL echo(concat(curprog," time: ",trim(cnvtstring(datetimediff(md_timer_stop,md_timer_start,4)),3),
   " minutes"))
 CALL echo("QM5 D Female and 40-70")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(rpt->enc,5)))
  PLAN (d
   WHERE datetimediff(rpt->enc[d.seq].d_end_encntr_dt_tm,rpt->enc[d.seq].d_birth_dt_tm) > 14609
    AND datetimediff(rpt->enc[d.seq].d_end_encntr_dt_tm,rpt->enc[d.seq].d_birth_dt_tm) < 25566
    AND (rpt->enc[d.seq].c_sex="F"))
  DETAIL
   IF (ml_debug_flag >= 50)
    CALL echo(build("qm5 D1 fin:",rpt->enc[d.seq].s_fin))
   ENDIF
   rpt->enc[d.seq].n_qm5_d = 1
  WITH nocounter
 ;end select
 IF (bhs_error_thrown(0)=1)
  CALL echo("Error thrown on QM5 D1...  Exiting.")
  GO TO exit_script
 ENDIF
 SET md_timer_stop = sysdate
 CALL echo(concat(curprog," time: ",trim(cnvtstring(datetimediff(md_timer_stop,md_timer_start,4)),3),
   " minutes"))
 CALL echo("QM6 D 65+ years of age")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(rpt->enc,5)))
  PLAN (d
   WHERE datetimediff(rpt->enc[d.seq].d_end_encntr_dt_tm,rpt->enc[d.seq].d_birth_dt_tm) > 23740)
  DETAIL
   IF (ml_debug_flag >= 50)
    CALL echo(build("qm6 D1 fin:",rpt->enc[d.seq].s_fin))
   ENDIF
   rpt->enc[d.seq].n_qm6_d = 1
  WITH nocounter
 ;end select
 IF (bhs_error_thrown(0)=1)
  CALL echo("Error thrown on QM6 D1...  Exiting.")
  GO TO exit_script
 ENDIF
 SET md_timer_stop = sysdate
 CALL echo(concat(curprog," time: ",trim(cnvtstring(datetimediff(md_timer_stop,md_timer_start,4)),3),
   " minutes"))
 CALL echo("Health Maintenance - Manual Satisfiers")
 SELECT INTO "nl:"
  d.seq, series.expect_series_name
  FROM (dummyt d  WITH seq = value(size(rpt->enc,5))),
   (dummyt d2  WITH seq = value(size(hm_series->qual,5))),
   hm_expect_sched sched,
   hm_expect_series series,
   hm_expect he,
   hm_expect_sat sat,
   hm_expect_mod mod
  PLAN (d
   WHERE (((rpt->enc[d.seq].n_qm3_d=1)) OR ((((rpt->enc[d.seq].n_qm4_d=1)) OR ((((rpt->enc[d.seq].
   n_qm5_d=1)) OR ((rpt->enc[d.seq].n_qm6_d=1))) )) )) )
   JOIN (d2)
   JOIN (sched
   WHERE sched.active_ind=1
    AND sched.beg_effective_dt_tm < cnvtdatetime(rpt->enc[d.seq].d_end_encntr_dt_tm)
    AND sched.end_effective_dt_tm > cnvtdatetime(rpt->enc[d.seq].d_end_encntr_dt_tm))
   JOIN (series
   WHERE series.expect_sched_id=sched.expect_sched_id
    AND (series.expect_series_name=hm_series->qual[d2.seq].s_series_name)
    AND (((rpt->enc[d.seq].n_qm3_d=1)
    AND series.expect_series_name="Influenza") OR ((((rpt->enc[d.seq].n_qm4_d=1)
    AND series.expect_series_name="Pap Smear") OR ((((rpt->enc[d.seq].n_qm5_d=1)
    AND series.expect_series_name="Mammography") OR ((rpt->enc[d.seq].n_qm6_d=1)
    AND series.expect_series_name="Pneumococcal"
    AND series.active_ind=1
    AND series.beg_effective_dt_tm < cnvtdatetime(rpt->enc[d.seq].d_end_encntr_dt_tm)
    AND series.end_effective_dt_tm > cnvtdatetime(rpt->enc[d.seq].d_end_encntr_dt_tm))) )) )) )
   JOIN (he
   WHERE he.expect_series_id=series.expect_series_id
    AND he.active_ind=1
    AND he.beg_effective_dt_tm < cnvtdatetime(rpt->enc[d.seq].d_end_encntr_dt_tm)
    AND he.end_effective_dt_tm > cnvtdatetime(rpt->enc[d.seq].d_end_encntr_dt_tm))
   JOIN (sat
   WHERE sat.expect_id=he.expect_id
    AND sat.parent_type_flag=0
    AND sat.active_ind=1
    AND sat.beg_effective_dt_tm < cnvtdatetime(rpt->enc[d.seq].d_end_encntr_dt_tm)
    AND sat.end_effective_dt_tm > cnvtdatetime(rpt->enc[d.seq].d_end_encntr_dt_tm))
   JOIN (mod
   WHERE (mod.person_id=rpt->enc[d.seq].f_pid)
    AND mod.active_ind=1
    AND mod.beg_effective_dt_tm < cnvtdatetime(rpt->enc[d.seq].d_end_encntr_dt_tm)
    AND mod.end_effective_dt_tm > cnvtdatetime(rpt->enc[d.seq].d_end_encntr_dt_tm)
    AND mod.modifier_type_cd=mf_satisfy_cd
    AND ((sat.satisfied_duration=0) OR (mod.modifier_dt_tm > datetimeadd(cnvtdatetime(rpt->enc[d.seq]
     .d_end_encntr_dt_tm),(0 - sat.satisfied_duration)))) )
  DETAIL
   CASE (series.expect_series_name)
    OF "Influenza":
     IF (ml_debug_flag >= 50)
      CALL echo(build("qm3 HMN1 fin:",rpt->enc[d.seq].s_fin))
     ENDIF
     ,rpt->enc[d.seq].n_qm3_n = 1
    OF "Pap Smear":
     IF (ml_debug_flag >= 50)
      CALL echo(build("qm4 HMN1 fin:",rpt->enc[d.seq].s_fin))
     ENDIF
     ,rpt->enc[d.seq].n_qm4_n = 1
    OF "Mammography":
     IF (ml_debug_flag >= 50)
      CALL echo(build("qm5 HMN1 fin:",rpt->enc[d.seq].s_fin))
     ENDIF
     ,rpt->enc[d.seq].n_qm5_n = 1
    OF "Pneumococcal":
     IF (ml_debug_flag >= 50)
      CALL echo(build("qm6 HMN1 fin:",rpt->enc[d.seq].s_fin))
     ENDIF
     ,rpt->enc[d.seq].n_qm6_n = 1
   ENDCASE
  WITH nocounter, maxqual(mod,1)
 ;end select
 IF (bhs_error_thrown(0)=1)
  CALL echo("Error thrown on Health Maintenance - Manual...  Exiting.")
  GO TO exit_script
 ENDIF
 SET md_timer_stop = sysdate
 CALL echo(concat(curprog," time: ",trim(cnvtstring(datetimediff(md_timer_stop,md_timer_start,4)),3),
   " minutes"))
 CALL echo("Health Maintenance - Clinical Events")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(rpt->enc,5))),
   (dummyt d2  WITH seq = value(size(hm_series->qual,5))),
   hm_expect_sched sched,
   hm_expect_series series,
   hm_expect he,
   hm_expect_sat sat,
   code_value cv,
   clinical_event ce
  PLAN (d
   WHERE (((rpt->enc[d.seq].n_qm3_d=1)) OR ((((rpt->enc[d.seq].n_qm4_d=1)) OR ((((rpt->enc[d.seq].
   n_qm5_d=1)) OR ((rpt->enc[d.seq].n_qm6_d=1))) )) )) )
   JOIN (d2)
   JOIN (sched
   WHERE sched.active_ind=1
    AND sched.beg_effective_dt_tm < cnvtdatetime(rpt->enc[d.seq].d_end_encntr_dt_tm)
    AND sched.end_effective_dt_tm > cnvtdatetime(rpt->enc[d.seq].d_end_encntr_dt_tm))
   JOIN (series
   WHERE series.expect_sched_id=sched.expect_sched_id
    AND (series.expect_series_name=hm_series->qual[d2.seq].s_series_name)
    AND (((rpt->enc[d.seq].n_qm3_d=1)
    AND series.expect_series_name="Influenza") OR ((((rpt->enc[d.seq].n_qm4_d=1)
    AND series.expect_series_name="Pap Smear") OR ((((rpt->enc[d.seq].n_qm5_d=1)
    AND series.expect_series_name="Mammography") OR ((rpt->enc[d.seq].n_qm6_d=1)
    AND series.expect_series_name="Pneumococcal"
    AND series.active_ind=1
    AND series.beg_effective_dt_tm < cnvtdatetime(rpt->enc[d.seq].d_end_encntr_dt_tm)
    AND series.end_effective_dt_tm > cnvtdatetime(rpt->enc[d.seq].d_end_encntr_dt_tm))) )) )) )
   JOIN (he
   WHERE he.expect_series_id=series.expect_series_id
    AND he.active_ind=1
    AND he.beg_effective_dt_tm < cnvtdatetime(rpt->enc[d.seq].d_end_encntr_dt_tm)
    AND he.end_effective_dt_tm > cnvtdatetime(rpt->enc[d.seq].d_end_encntr_dt_tm))
   JOIN (sat
   WHERE sat.expect_id=he.expect_id
    AND sat.parent_type_flag=0
    AND sat.active_ind=1
    AND sat.beg_effective_dt_tm < cnvtdatetime(rpt->enc[d.seq].d_end_encntr_dt_tm)
    AND sat.end_effective_dt_tm > cnvtdatetime(rpt->enc[d.seq].d_end_encntr_dt_tm))
   JOIN (cv
   WHERE cv.display=sat.parent_value
    AND cv.code_set=72
    AND cv.active_ind=1
    AND cv.begin_effective_dt_tm < cnvtdatetime(rpt->enc[d.seq].d_end_encntr_dt_tm)
    AND cv.end_effective_dt_tm > cnvtdatetime(rpt->enc[d.seq].d_end_encntr_dt_tm))
   JOIN (ce
   WHERE (ce.person_id=rpt->enc[d.seq].f_pid)
    AND ce.event_cd=cv.code_value
    AND ce.valid_from_dt_tm < cnvtdatetime(rpt->enc[d.seq].d_end_encntr_dt_tm)
    AND ce.valid_until_dt_tm > cnvtdatetime(rpt->enc[d.seq].d_end_encntr_dt_tm)
    AND ((sat.satisfied_duration=0) OR (ce.event_end_dt_tm > datetimeadd(cnvtdatetime(rpt->enc[d.seq]
     .d_end_encntr_dt_tm),(0 - sat.satisfied_duration)))) )
  DETAIL
   CASE (series.expect_series_name)
    OF "Influenza":
     IF (ml_debug_flag >= 50)
      CALL echo(build("qm3 HMN2 fin:",rpt->enc[d.seq].s_fin))
     ENDIF
     ,rpt->enc[d.seq].n_qm3_n = 1
    OF "Pap Smear":
     IF (ml_debug_flag >= 50)
      CALL echo(build("qm4 HMN2 fin:",rpt->enc[d.seq].s_fin))
     ENDIF
     ,rpt->enc[d.seq].n_qm4_n = 1
    OF "Mammography":
     IF (ml_debug_flag >= 50)
      CALL echo(build("qm5 HMN2 fin:",rpt->enc[d.seq].s_fin))
     ENDIF
     ,rpt->enc[d.seq].n_qm5_n = 1
    OF "Pneumococcal":
     IF (ml_debug_flag >= 50)
      CALL echo(build("qm6 HMN2 fin:",rpt->enc[d.seq].s_fin))
     ENDIF
     ,rpt->enc[d.seq].n_qm6_n = 1
   ENDCASE
  WITH nocounter, maxqual(ce,1)
 ;end select
 IF (bhs_error_thrown(0)=1)
  CALL echo("Error thrown on Health Maintenance - Clinical Event...  Exiting.")
  GO TO exit_script
 ENDIF
 SET md_timer_stop = sysdate
 CALL echo(concat(curprog," time: ",trim(cnvtstring(datetimediff(md_timer_stop,md_timer_start,4)),3),
   " minutes"))
#generate_report
 CALL echo("Generate Report")
 SELECT INTO value(ms_output)
  FROM (dummyt d  WITH seq = 1)
  DETAIL
   ms_line = concat("name,cmrn,fin,sex,age,qm1_n,qm1_d,qm2a_n,qm2a_d,qm2b_n,qm2b_d,qm3_n,qm3_d,",
    "qm4_n,qm4_d,qm5_n,qm5_d,qm6_n,qm6_d"), row 0, col 0,
   ms_line
   FOR (ml_cnt = 1 TO size(rpt->enc,5))
     ms_line = build('"',rpt->enc[ml_cnt].s_name_full_formatted,'"',",",'"',
      rpt->enc[ml_cnt].s_cmrn,'"',",",'"',rpt->enc[ml_cnt].s_fin,
      '"',",",'"',rpt->enc[ml_cnt].c_sex,'"',
      ",",format(rpt->enc[ml_cnt].d_birth_dt_tm,"YYYY-MM-DD;;D"),",",cnvtstring(rpt->enc[ml_cnt].
       n_qm1_n),",",
      cnvtstring(rpt->enc[ml_cnt].n_qm1_d),",",cnvtstring(rpt->enc[ml_cnt].n_qm2a_n),",",cnvtstring(
       rpt->enc[ml_cnt].n_qm2a_d),
      ",",cnvtstring(rpt->enc[ml_cnt].n_qm2b_n),",",cnvtstring(rpt->enc[ml_cnt].n_qm2b_d),",",
      cnvtstring(rpt->enc[ml_cnt].n_qm3_n),",",cnvtstring(rpt->enc[ml_cnt].n_qm3_d),",",cnvtstring(
       rpt->enc[ml_cnt].n_qm4_n),
      ",",cnvtstring(rpt->enc[ml_cnt].n_qm4_d),",",cnvtstring(rpt->enc[ml_cnt].n_qm5_n),",",
      cnvtstring(rpt->enc[ml_cnt].n_qm5_d),",",cnvtstring(rpt->enc[ml_cnt].n_qm6_n),",",cnvtstring(
       rpt->enc[ml_cnt].n_qm6_d)), row + 1, col 0,
     ms_line
   ENDFOR
  WITH nocounter, formfeed = none, format = variable,
   maxcol = 500, maxrow = 1
 ;end select
#exit_script
 CALL echo("Exit Script")
 ROLLBACK
 SET md_timer_stop = sysdate
 CALL echo(concat(curprog," execution time: ",trim(cnvtstring(datetimediff(md_timer_stop,
      md_timer_start,4)),3)," minutes"))
 CALL echo(concat("Exiting script ",curprog," with status ",reply->c_status))
 SET stat = bhs_clear_error(0)
 IF (ml_debug_flag >= 1)
  CALL echo(concat("Exiting script ",curprog," with status ",reply->c_status))
 ENDIF
END GO
