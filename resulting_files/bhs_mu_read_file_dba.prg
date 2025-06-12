CREATE PROGRAM bhs_mu_read_file:dba
 EXECUTE bhs_hlp_csv
 EXECUTE bhs_hlp_err
 DECLARE ml_debug_flag = i4 WITH protect, constant(validate(bhs_debug_flag,0))
 DECLARE ms_input_logical = vc WITH protect, constant("mu_in_rf")
 DECLARE md_service_dt_tm = dq8 WITH protect, noconstant(sysdate)
 DECLARE ms_service_dt = vc WITH protect, noconstant(" ")
 DECLARE ms_date = vc WITH protect, noconstant(" ")
 DECLARE ms_time = vc WITH protect, noconstant(" ")
 DECLARE ms_fin = vc WITH protect, noconstant(" ")
 DECLARE ms_str = vc WITH protect, noconstant(" ")
 DECLARE ms_wnerta_pid = vc WITH protect, noconstant(" ")
 DECLARE mc_ed_ind = c1 WITH protect, noconstant(" ")
 DECLARE mf_phy_npi = f8 WITH protect, noconstant(0.0)
 DECLARE ml_pos = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_year = i4 WITH protect, noconstant(0)
 DECLARE ml_month = i4 WITH protect, noconstant(0)
 DECLARE ml_day = i4 WITH protect, noconstant(0)
 IF (validate(murf_reply->c_status)=0)
  RECORD murf_reply(
    1 s_file_type = vc
    1 qual[*]
      2 s_fin = vc
      2 d_service_dt_tm = dq8
      2 f_phy_npi = f8
      2 c_ed_ind = c1
    1 c_status = c1
  )
 ENDIF
 SET murf_reply->c_status = "F"
 IF (validate(murf_request->s_filename)=0)
  CALL echo(concat("[",curprog,"] No file specified... Exiting."))
  GO TO exit_script
 ENDIF
 SET logical mu_in_rf value(trim(murf_request->s_filename,3))
 CALL echo(build("LOGICAL mu_in_rf :",logical(ms_input_logical)))
 IF (bhs_error_thrown(0)=1)
  CALL echo(concat("[",curprog,"] Error thrown during setup.  Exiting."))
  GO TO exit_script
 ENDIF
 IF (ml_debug_flag >= 1)
  CALL echo(concat("Starting script ",curprog))
 ENDIF
 IF ((((murf_request->s_filename="*BFMC_Meaningful*.txt")) OR ((((murf_request->s_filename=
 "*BMC_Meaningful*.txt")) OR ((((murf_request->s_filename="*BLH_Meaningful*.txt")) OR ((((
 murf_request->s_filename="*mu_inpt_*.txt")) OR ((murf_request->s_filename="*mu_inpt_*.csv"))) )) ))
 )) )
  SET murf_reply->s_file_type = "INPATIENT"
 ELSEIF (cnvtlower(murf_request->s_filename)="*mu_amb_*.csv")
  SET murf_reply->s_file_type = "AMBULATORY"
 ELSEIF ((murf_request->s_filename="*mu_sms_*.csv"))
  SET murf_reply->s_file_type = "SMS"
 ELSEIF ((murf_request->s_filename="*mu_wnerta_*.csv"))
  SET murf_reply->s_file_type = "WNERTA"
 ELSEIF ((murf_request->s_filename="*mu_recur_*.csv"))
  SET murf_reply->s_file_type = "RECURRING"
 ELSE
  SET murf_reply->s_file_type = "UNKNOWN"
  CALL echo(build("Input file does not match any known pattern:",murf_request->s_filename))
  SET murf_reply->c_status = "Z"
  GO TO exit_script
 ENDIF
 IF ((murf_reply->s_file_type IN ("INPATIENT", "AMBULATORY", "SMS", "WNERTA", "RECURRING"))
  AND findfile(ms_input_logical)=0)
  CALL echo(build('The input file "',logical(ms_input_logical),'" was not found.'))
  GO TO exit_script
 ENDIF
 FREE DEFINE rtl2
 DEFINE rtl2 ms_input_logical
 SELECT INTO "nl:"
  FROM rtl2t r
  WHERE r.line > " "
   AND r.line != "Provider,Provider NPI,Patient,Visit Number,MRN,DOB,*"
   AND r.line != "PROVIDER #,PROVIDER NAME,PROVIDER NPI,PATIENT NAME,*"
   AND r.line != "Charge Performing Provider,PRVNPI,Patient Name,*"
   AND r.line != "encounter_id,acct_num,encntr_type,service_dt_tm,*"
  HEAD REPORT
   ml_cnt = 0
  DETAIL
   IF (ml_debug_flag >= 80)
    CALL echo(build("LINE:",r.line))
   ENDIF
   CASE (murf_reply->s_file_type)
    OF "INPATIENT":
     mc_ed_ind = cnvtupper(substring(52,1,r.line)),
     IF (mc_ed_ind != "Y")
      mc_ed_ind = "N"
     ENDIF
     ,ms_fin = substring(8,9,r.line),ms_date = concat(substring(57,4,r.line),substring(55,2,r.line)),
     ms_time = substring(61,6,r.line),
     md_service_dt_tm = cnvtdatetime(cnvtdate(cnvtint(ms_date)),cnvtint(ms_time))
    OF "AMBULATORY":
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
      md_service_dt_tm = cnvtdatetime(cnvtdate2(ms_str,"MM/DD/YYYY"),0)
     ENDIF
     ,stat = getcsvcolumnatindex(r.line,2,ms_str,",",'"'),
     IF (stat=1)
      mf_phy_npi = cnvtreal(ms_str)
     ENDIF
    OF "SMS":
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
      md_service_dt_tm = cnvtdatetime(cnvtdate2(ms_str,"MM/DD/YYYY"),0)
     ENDIF
     ,stat = getcsvcolumnatindex(r.line,3,ms_str,",",'"'),
     IF (stat=1)
      mf_phy_npi = cnvtreal(ms_str)
     ENDIF
    OF "WNERTA":
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
        ms_service_dt = ms_str, stat = getcsvcolumnatindex(ms_service_dt,1,ms_str,"/",'"'), ml_month
         = cnvtint(ms_str),
        stat = getcsvcolumnatindex(ms_service_dt,2,ms_str,"/",'"'), ml_day = cnvtint(ms_str), stat =
        getcsvcolumnatindex(ms_service_dt,3,ms_str,"/",'"'),
        ml_year = cnvtint(ms_str), ms_service_dt = build(format(ml_month,"##;P0"),"/",format(ml_day,
          "##;P0"),"/",format(ml_year,"####;P0")), md_service_dt_tm = cnvtdatetime(cnvtdate2(
          ms_service_dt,"MM/DD/YYYY"),0)
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
    OF "RECURRING":
     stat = getcsvcolumnatindex(r.line,2,ms_str,",",'"'),
     IF (stat=1)
      ms_fin = ms_str
     ENDIF
     ,stat = getcsvcolumnatindex(r.line,4,ms_str,",",'"'),
     IF (stat=1
      AND textlen(ms_str)=20)
      md_service_dt_tm = cnvtdatetime(ms_str)
     ENDIF
     ,stat = getcsvcolumnatindex(r.line,9,ms_str,",",'"'),
     IF (stat=1)
      mf_phy_npi = cnvtreal(ms_str)
     ENDIF
   ENDCASE
   IF ( NOT (ms_fin IN ("", " ", null)))
    ml_pos = locateval(ml_idx,1,size(murf_reply->qual,5),ms_fin,murf_reply->qual[ml_idx].s_fin)
    IF (ml_pos=0)
     IF (mod(ml_cnt,100)=0)
      stat = alterlist(murf_reply->qual,(ml_cnt+ 100))
     ENDIF
     ml_cnt = (ml_cnt+ 1), murf_reply->qual[ml_cnt].s_fin = ms_fin, murf_reply->qual[ml_cnt].
     d_service_dt_tm = md_service_dt_tm,
     murf_reply->qual[ml_cnt].c_ed_ind = mc_ed_ind, murf_reply->qual[ml_cnt].f_phy_npi = mf_phy_npi
     IF (ml_debug_flag >= 100)
      CALL echo(build("FIN:",murf_reply->qual[ml_cnt].s_fin,", Service date:",format(murf_reply->
        qual[ml_cnt].d_service_dt_tm,"MM/DD/YYYY;;D"),", Phy NPI:",
       cnvtstring(murf_reply->qual[ml_cnt].f_phy_npi)))
     ENDIF
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(murf_reply->qual,ml_cnt)
  WITH nocounter
 ;end select
 IF (bhs_error_thrown(0)=1)
  CALL echo(concat("Error thrown while reading ", $INPUT_FILE,".  Exiting."))
  GO TO exit_script
 ENDIF
 SET murf_reply->c_status = "S"
#exit_script
 IF (validate(murf_request->s_filename) != 0)
  CALL echo(build("MU encounters inputted:",size(murf_reply->qual,5)))
 ENDIF
 SET stat = bhs_clear_error(0)
 CALL echo(concat("Exiting script ",curprog," with status ",murf_reply->c_status))
END GO
