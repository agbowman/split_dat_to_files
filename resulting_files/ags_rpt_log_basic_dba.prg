CREATE PROGRAM ags_rpt_log_basic:dba
 PROMPT
  "AGS_JOB_ID (0.0) = " = 0.0,
  "File Type = " = "",
  "Anchor Date (DD-MMM-YYYY) = " = ""
  WITH did, stype, sdate
 IF ( NOT (validate(reply,0)))
  FREE RECORD reply
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 IF (validate(ags_get_code_defined,0)=0)
  EXECUTE ags_get_code
 ENDIF
 IF (validate(ags_log_header_defined,0)=0)
  EXECUTE ags_log_header
 ENDIF
 IF (get_script_status(0) != esuccessful)
  GO TO exit_script
 ENDIF
 CALL set_log_level(5)
 CALL echo("***")
 CALL echo("***   BEG> AGS_RPT_LOG_BASIC")
 CALL echo("***")
 DECLARE djobid = f8 WITH protect, noconstant(0.0)
 DECLARE sfiletype = vc WITH protect, noconstant("")
 DECLARE sanchordate = vc WITH protect, noconstant("")
 FREE RECORD date
 RECORD date(
   1 anchordttm = dq8
   1 begdttm = dq8
   1 enddttm = dq8
 )
 DECLARE found_job = i2 WITH protect, noconstant(false)
 DECLARE sdaynbr = vc WITH protect, noconstant("")
 DECLARE idaynbr = i2 WITH protect, noconstant(0)
 DECLARE smonth = vc WITH protect, noconstant("")
 DECLARE syear = vc WITH protect, noconstant("")
 DECLARE iyear = i4 WITH protect, noconstant(0)
 DECLARE check_date = vc WITH protect, noconstant("")
 DECLARE idashpos = i4 WITH protect, noconstant(0)
 DECLARE ibegpos = i4 WITH protect, noconstant(1)
 DECLARE iendpos = i4 WITH protect, noconstant(0)
 DECLARE ibegday = i2 WITH protect, noconstant(1)
 DECLARE iendday = i2 WITH protect, noconstant(0)
 DECLARE max_job_line_1_length = i4 WITH protect, constant(120)
 DECLARE max_job_line_n_length = i4 WITH protect, constant(115)
 DECLARE max_grp_line_1_length = i4 WITH protect, constant(110)
 DECLARE max_grp_line_n_length = i4 WITH protect, constant(105)
 DECLARE max_itm_line_1_length = i4 WITH protect, constant(100)
 DECLARE max_itm_line_n_length = i4 WITH protect, constant(95)
 DECLARE temp_line_1 = vc WITH protect, noconstant("")
 DECLARE temp_line_n = vc WITH protect, noconstant("")
 FREE RECORD pt
 RECORD pt(
   1 line_cnt = i2
   1 lns[*]
     2 line = vc
 )
 FREE RECORD data_rec
 RECORD data_rec(
   1 job_knt = i4
   1 job[*]
     2 ags_job_id = f8
     2 job_line = vc
     2 wrap_line_knt = i4
     2 wrap_line[*]
       3 value = vc
     2 grp_knt = i4
     2 grp[*]
       3 ags_grp_id = f8
       3 beg_dt_tm = dq8
       3 end_dt_tm = dq8
       3 grp_line = vc
       3 wrap_line_knt = i4
       3 wrap_line[*]
         4 value = vc
       3 error_rec_knt = i4
       3 error_rec[*]
         4 error_line = vc
         4 wrap_line_knt = i4
         4 wrap_line[*]
           5 value = vc
       3 warning_rec_knt = i4
       3 warning_rec[*]
         4 warning_line = vc
         4 wrap_line_knt = i4
         4 wrap_line[*]
           5 value = vc
       3 debug_rec_knt = i4
       3 debug_rec[*]
         4 debug_line = vc
         4 wrap_line_knt = i4
         4 wrap_line[*]
           5 value = vc
       3 audit_rec_knt = i4
       3 audit_rec[*]
         4 audit_line = vc
         4 wrap_line_knt = i4
         4 wrap_line[*]
           5 value = vc
       3 info_rec_knt = i4
       3 info_rec[*]
         4 info_line = vc
         4 wrap_line_knt = i4
         4 wrap_line[*]
           5 value = vc
       3 unknown_rec_knt = i4
       3 unknown_rec[*]
         4 unknown_line = vc
         4 wrap_line_knt = i4
         4 wrap_line[*]
           5 value = vc
 )
 SET djobid =  $DID
 SET sfiletype =  $STYPE
 SET sanchordate =  $SDATE
 SET sfiletype = cnvtupper(trim(sfiletype))
 IF (djobid > 0)
  SET found_job = false
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  SELECT INTO "nl:"
   FROM ags_job j
   PLAN (j
    WHERE j.ags_job_id=djobid)
   DETAIL
    found_job = true
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   CALL ags_set_status_block(eselect,efailure,"dJobId VALIDATION",trim(serrmsg))
   GO TO exit_script
  ENDIF
  IF (found_job=false)
   CALL ags_set_status_block(eattribute,efailure,"dJobId VALIDATION",
    "dJobId Must be on the AGS_JOB table")
   GO TO exit_script
  ENDIF
 ELSE
  SET found_job = true
 ENDIF
 SET sanchordate = cnvtupper(trim(sanchordate))
 IF (textlen(trim(sanchordate)) > 0)
  SET idashpos = findstring("-",trim(sanchordate),ibegpos,0)
  IF (idashpos > 1
   AND idashpos < 4)
   SET sdaynbr = substring(ibegpos,(idashpos - ibegpos),trim(sanchordate))
   SET ibegpos = (idashpos+ 1)
   SET idashpos = findstring("-",trim(sanchordate),ibegpos,0)
   IF (idashpos > ibegpos)
    SET smonth = cnvtupper(substring(ibegpos,(idashpos - ibegpos),trim(sanchordate)))
    SET ibegpos = (idashpos+ 1)
    SET iendpos = textlen(trim(sanchordate))
    IF (iendpos > ibegpos)
     IF ((((iendpos - ibegpos)+ 1)=4))
      SET syear = substring(ibegpos,4,trim(sanchordate))
     ELSE
      CALL ags_set_status_block(eattribute,efailure,"ANCHOR_DATE VALIDATION",
       "Anchor Date must be in the format DD-MMM-YYYY")
      GO TO exit_script
     ENDIF
    ELSE
     CALL ags_set_status_block(eattribute,efailure,"ANCHOR_DATE VALIDATION",
      "Anchor Date must be in the format DD-MMM-YYYY")
     GO TO exit_script
    ENDIF
   ELSE
    CALL ags_set_status_block(eattribute,efailure,"ANCHOR_DATE VALIDATION",
     "Anchor Date must be in the format DD-MMM-YYYY")
    GO TO exit_script
   ENDIF
  ELSE
   CALL ags_set_status_block(eattribute,efailure,"ANCHOR_DATE VALIDATION",
    "Anchor Date must be in the format DD-MMM-YYYY")
   GO TO exit_script
  ENDIF
  IF ( NOT (smonth IN ("JAN", "FEB", "MAR", "APR", "MAY",
  "JUN", "JUL", "AUG", "SEP", "OCT",
  "NOV", "DEC")))
   CALL ags_set_status_block(eattribute,efailure,"ANCHOR_DATE VALIDATION",
    "The month must be a valid 3 letter month abbreviation")
   GO TO exit_script
  ELSE
   IF (isnumeric(syear)=1)
    SET iyear = cnvtint(syear)
    IF (iyear >= 1800
     AND iyear <= 2200)
     SET check_date = concat("15-",trim(smonth),"-",trim(syear))
     SET iendday = 0
     SET iendday = day(datetimefind(cnvtdatetime(value(check_date)),"M","E","P"))
     IF (isnumeric(sdaynbr)=1)
      SET idaynbr = cnvtint(sdaynbr)
      IF (((idaynbr < ibegday) OR (idaynbr > iendday)) )
       CALL ags_set_status_block(eattribute,efailure,"ANCHOR_DATE VALIDATION",concat("Invalid day (",
         trim(sdaynbr),") for the month (",trim(smonth),")"))
       GO TO exit_script
      ELSE
       SET check_date = concat(trim(sdaynbr),"-",trim(smonth),"-",trim(syear),
        " 00:00:00")
       SET date->anchordttm = cnvtdatetime(value(check_date))
      ENDIF
     ELSE
      CALL ags_set_status_block(eattribute,efailure,"ANCHOR_DATE VALIDATION",concat("The day (",trim(
         sdaynbr),") of the month must be a number"))
      GO TO exit_script
     ENDIF
    ELSE
     CALL ags_set_status_block(eattribute,efailure,"ANCHOR_DATE VALIDATION",
      "Year must be between 1800 and 2200")
     GO TO exit_script
    ENDIF
   ELSE
    CALL ags_set_status_block(eattribute,efailure,"ANCHOR_DATE VALIDATION",
     "Year must be between 1800 and 2200")
    GO TO exit_script
   ENDIF
  ENDIF
 ELSE
  IF (djobid < 1
   AND textlen(sfiletype) < 1)
   CALL ags_set_status_block(eattribute,efailure,"PROMPT VALIDATION",
    "If the JOB_ID or FILE_TYPE are not valued then the ANCHOR_DATE must be valued")
   GO TO exit_script
  ENDIF
 ENDIF
 IF (djobid > 0)
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  SELECT INTO "nl:"
   FROM ags_job j,
    ags_log a
   PLAN (j
    WHERE j.ags_job_id=djobid)
    JOIN (a
    WHERE a.ags_job_id=j.ags_job_id)
   ORDER BY a.ags_job_id DESC, a.ags_log_grp_id DESC, a.log_dt_tm DESC
   HEAD REPORT
    current_meaning = fillstring(12,""), jknt = 0, stat = alterlist(data_rec->job,10)
   HEAD a.ags_job_id
    jknt = (jknt+ 1)
    IF (mod(jknt,10)=1
     AND jknt != 1)
     stat = alterlist(data_rec->job,(jknt+ 9))
    ENDIF
    data_rec->job[jknt].job_line = concat(trim(j.file_type)," (",trim(cnvtstring(j.ags_job_id)),
     ") Run Nbr: ",trim(cnvtstring(j.run_nbr))), gknt = 0, stat = alterlist(data_rec->job[jknt].grp,
     10)
   HEAD a.ags_log_grp_id
    gknt = (gknt+ 1)
    IF (mod(gknt,10)=1
     AND gknt != 1)
     stat = alterlist(data_rec->job[jknt].grp,(gknt+ 9))
    ENDIF
    data_rec->job[jknt].grp[gknt].end_dt_tm = a.log_dt_tm, eknt = 0, stat = alterlist(data_rec->job[
     jknt].grp[gknt].error_rec,10),
    wknt = 0, stat = alterlist(data_rec->job[jknt].grp[gknt].warning_rec,10), dknt = 0,
    stat = alterlist(data_rec->job[jknt].grp[gknt].debug_rec,10), aknt = 0, stat = alterlist(data_rec
     ->job[jknt].grp[gknt].audit_rec,10),
    iknt = 0, stat = alterlist(data_rec->job[jknt].grp[gknt].info_rec,10), uknt = 0,
    stat = alterlist(data_rec->job[jknt].grp[gknt].unknown_rec,10), current_meaning = ""
   DETAIL
    current_meaning = uar_get_code_meaning(a.log_level_cd)
    IF (trim(current_meaning)="ERROR")
     eknt = (eknt+ 1)
     IF (mod(eknt,10)=1
      AND eknt != 1)
      stat = alterlist(data_rec->job[jknt].grp[gknt].error_rec,(eknt+ 9))
     ENDIF
     IF (size(trim(a.message),1) > 0)
      data_rec->job[jknt].grp[gknt].error_rec[eknt].error_line = concat(trim(current_meaning),": ",
       trim(uar_get_code_display(a.element_cd))," (",trim(cnvtstring(a.ags_table_id)),
       ") ",trim(uar_get_code_display(a.log_cd))," - ",trim(a.message))
     ELSE
      data_rec->job[jknt].grp[gknt].error_rec[eknt].error_line = concat(trim(current_meaning),": ",
       trim(uar_get_code_display(a.element_cd))," (",trim(cnvtstring(a.ags_table_id)),
       ") ",trim(uar_get_code_display(a.log_cd)))
     ENDIF
    ELSEIF (trim(current_meaning)="WARNING")
     wknt = (wknt+ 1)
     IF (mod(wknt,10)=1
      AND wknt != 1)
      stat = alterlist(data_rec->job[jknt].grp[gknt].warning_rec,(wknt+ 9))
     ENDIF
     IF (size(trim(a.message),1) > 0)
      data_rec->job[jknt].grp[gknt].warning_rec[wknt].warning_line = concat(trim(current_meaning),
       ": ",trim(uar_get_code_display(a.element_cd))," (",trim(cnvtstring(a.ags_table_id)),
       ") ",trim(uar_get_code_display(a.log_cd))," - ",trim(a.message))
     ELSE
      data_rec->job[jknt].grp[gknt].warning_rec[wknt].warning_line = concat(trim(current_meaning),
       ": ",trim(uar_get_code_display(a.element_cd))," (",trim(cnvtstring(a.ags_table_id)),
       ") ",trim(uar_get_code_display(a.log_cd)))
     ENDIF
    ELSEIF (trim(current_meaning)="DEBUG")
     dknt = (dknt+ 1)
     IF (mod(dknt,10)=1
      AND dknt != 1)
      stat = alterlist(data_rec->job[jknt].grp[gknt].debug_rec,(dknt+ 9))
     ENDIF
     IF (size(trim(a.message),1) > 0)
      data_rec->job[jknt].grp[gknt].debug_rec[dknt].debug_line = concat(trim(current_meaning),": ",
       trim(uar_get_code_display(a.element_cd))," (",trim(cnvtstring(a.ags_table_id)),
       ") ",trim(uar_get_code_display(a.log_cd))," - ",trim(a.message))
     ELSE
      data_rec->job[jknt].grp[gknt].debug_rec[dknt].debug_line = concat(trim(current_meaning),": ",
       trim(uar_get_code_display(a.element_cd))," (",trim(cnvtstring(a.ags_table_id)),
       ") ",trim(uar_get_code_display(a.log_cd)))
     ENDIF
    ELSEIF (trim(current_meaning)="AUDIT")
     aknt = (aknt+ 1)
     IF (mod(aknt,10)=1
      AND aknt != 1)
      stat = alterlist(data_rec->job[jknt].grp[gknt].audit_rec,(aknt+ 9))
     ENDIF
     IF (size(trim(a.message),1) > 0)
      data_rec->job[jknt].grp[gknt].audit_rec[aknt].audit_line = concat(trim(current_meaning),": ",
       trim(uar_get_code_display(a.element_cd))," (",trim(cnvtstring(a.ags_table_id)),
       ") ",trim(uar_get_code_display(a.log_cd))," - ",trim(a.message))
     ELSE
      data_rec->job[jknt].grp[gknt].audit_rec[aknt].audit_line = concat(trim(current_meaning),": ",
       trim(uar_get_code_display(a.element_cd))," (",trim(cnvtstring(a.ags_table_id)),
       ") ",trim(uar_get_code_display(a.log_cd)))
     ENDIF
    ELSEIF (trim(current_meaning)="INFO")
     iknt = (iknt+ 1)
     IF (mod(iknt,10)=1
      AND iknt != 1)
      stat = alterlist(data_rec->job[jknt].grp[gknt].info_rec,(iknt+ 9))
     ENDIF
     IF (size(trim(a.message),1) > 0)
      data_rec->job[jknt].grp[gknt].info_rec[iknt].info_line = concat(trim(current_meaning),": ",trim
       (uar_get_code_display(a.element_cd))," (",trim(cnvtstring(a.ags_table_id)),
       ") ",trim(uar_get_code_display(a.log_cd))," - ",trim(a.message))
     ELSE
      data_rec->job[jknt].grp[gknt].info_rec[iknt].info_line = concat(trim(current_meaning),": ",trim
       (uar_get_code_display(a.element_cd))," (",trim(cnvtstring(a.ags_table_id)),
       ") ",trim(uar_get_code_display(a.log_cd)))
     ENDIF
    ELSE
     uknt = (uknt+ 1)
     IF (mod(uknt,10)=1
      AND uknt != 1)
      stat = alterlist(data_rec->job[jknt].grp[gknt].unknown_rec,(uknt+ 9))
     ENDIF
     IF (size(trim(a.message),1) > 0)
      data_rec->job[jknt].grp[gknt].unknown_rec[uknt].unknown_line = concat(trim(current_meaning),
       ": ",trim(uar_get_code_display(a.element_cd))," (",trim(cnvtstring(a.ags_table_id)),
       ") ",trim(uar_get_code_display(a.log_cd))," - ",trim(a.message))
     ELSE
      data_rec->job[jknt].grp[gknt].unknown_rec[uknt].unknown_line = concat(trim(current_meaning),
       ": ",trim(uar_get_code_display(a.element_cd))," (",trim(cnvtstring(a.ags_table_id)),
       ") ",trim(uar_get_code_display(a.log_cd)))
     ENDIF
    ENDIF
   FOOT  a.ags_log_grp_id
    data_rec->job[jknt].grp[gknt].beg_dt_tm = a.log_dt_tm, data_rec->job[jknt].grp[gknt].grp_line =
    concat("Load Instance ",trim(cnvtstring(gknt)),": Beg Date/Time (",format(cnvtdatetime(data_rec->
       job[jknt].grp[gknt].beg_dt_tm),"dd-mmm-yyyy hh:mm:ss;;q"),") End Date/Time (",
     format(cnvtdatetime(data_rec->job[jknt].grp[gknt].end_dt_tm),"dd-mmm-yyyy hh:mm:ss;;q"),")"),
    data_rec->job[jknt].grp[gknt].error_rec_knt = eknt,
    stat = alterlist(data_rec->job[jknt].grp[gknt].error_rec,eknt), data_rec->job[jknt].grp[gknt].
    warning_rec_knt = wknt, stat = alterlist(data_rec->job[jknt].grp[gknt].warning_rec,wknt),
    data_rec->job[jknt].grp[gknt].debug_rec_knt = dknt, stat = alterlist(data_rec->job[jknt].grp[gknt
     ].debug_rec,dknt), data_rec->job[jknt].grp[gknt].audit_rec_knt = aknt,
    stat = alterlist(data_rec->job[jknt].grp[gknt].audit_rec,aknt), data_rec->job[jknt].grp[gknt].
    info_rec_knt = iknt, stat = alterlist(data_rec->job[jknt].grp[gknt].info_rec,iknt),
    data_rec->job[jknt].grp[gknt].unknown_rec_knt = uknt, stat = alterlist(data_rec->job[jknt].grp[
     gknt].unknown_rec,uknt)
   FOOT  a.ags_job_id
    data_rec->job[jknt].grp_knt = gknt, stat = alterlist(data_rec->job[jknt].grp,gknt)
   FOOT REPORT
    data_rec->job_knt = jknt, stat = alterlist(data_rec->job,jknt)
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   CALL ags_set_status_block(eselect,efailure,"AGS_LOG by dJobId",trim(serrmsg))
   GO TO exit_script
  ENDIF
 ELSEIF (textlen(trim(sfiletype)) > 0
  AND (date->anchordttm > 0))
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  SELECT INTO "nl:"
   FROM ags_job j,
    ags_log a
   PLAN (j
    WHERE j.file_type=trim(sfiletype))
    JOIN (a
    WHERE a.ags_job_id=j.ags_job_id
     AND a.log_dt_tm >= cnvtdatetime(date->anchordttm))
   ORDER BY a.ags_job_id DESC, a.ags_log_grp_id DESC, a.log_dt_tm DESC
   HEAD REPORT
    current_meaning = fillstring(12,""), jknt = 0, stat = alterlist(data_rec->job,10)
   HEAD a.ags_job_id
    jknt = (jknt+ 1)
    IF (mod(jknt,10)=1
     AND jknt != 1)
     stat = alterlist(data_rec->job,(jknt+ 9))
    ENDIF
    data_rec->job[jknt].job_line = concat(trim(j.file_type)," (",trim(cnvtstring(j.ags_job_id)),
     ") Run Nbr: ",trim(cnvtstring(j.run_nbr))), gknt = 0, stat = alterlist(data_rec->job[jknt].grp,
     10)
   HEAD a.ags_log_grp_id
    gknt = (gknt+ 1)
    IF (mod(gknt,10)=1
     AND gknt != 1)
     stat = alterlist(data_rec->job[jknt].grp,(gknt+ 9))
    ENDIF
    data_rec->job[jknt].grp[gknt].end_dt_tm = a.log_dt_tm, eknt = 0, stat = alterlist(data_rec->job[
     jknt].grp[gknt].error_rec,10),
    wknt = 0, stat = alterlist(data_rec->job[jknt].grp[gknt].warning_rec,10), dknt = 0,
    stat = alterlist(data_rec->job[jknt].grp[gknt].debug_rec,10), aknt = 0, stat = alterlist(data_rec
     ->job[jknt].grp[gknt].audit_rec,10),
    iknt = 0, stat = alterlist(data_rec->job[jknt].grp[gknt].info_rec,10), uknt = 0,
    stat = alterlist(data_rec->job[jknt].grp[gknt].unknown_rec,10), current_meaning = ""
   DETAIL
    current_meaning = uar_get_code_meaning(a.log_level_cd)
    IF (trim(current_meaning)="ERROR")
     eknt = (eknt+ 1)
     IF (mod(eknt,10)=1
      AND eknt != 1)
      stat = alterlist(data_rec->job[jknt].grp[gknt].error_rec,(eknt+ 9))
     ENDIF
     IF (size(trim(a.message),1) > 0)
      data_rec->job[jknt].grp[gknt].error_rec[eknt].error_line = concat(trim(current_meaning),": ",
       trim(uar_get_code_display(a.element_cd))," (",trim(cnvtstring(a.ags_table_id)),
       ") ",trim(uar_get_code_display(a.log_cd))," - ",trim(a.message))
     ELSE
      data_rec->job[jknt].grp[gknt].error_rec[eknt].error_line = concat(trim(current_meaning),": ",
       trim(uar_get_code_display(a.element_cd))," (",trim(cnvtstring(a.ags_table_id)),
       ") ",trim(uar_get_code_display(a.log_cd)))
     ENDIF
    ELSEIF (trim(current_meaning)="WARNING")
     wknt = (wknt+ 1)
     IF (mod(wknt,10)=1
      AND wknt != 1)
      stat = alterlist(data_rec->job[jknt].grp[gknt].warning_rec,(wknt+ 9))
     ENDIF
     IF (size(trim(a.message),1) > 0)
      data_rec->job[jknt].grp[gknt].warning_rec[wknt].warning_line = concat(trim(current_meaning),
       ": ",trim(uar_get_code_display(a.element_cd))," (",trim(cnvtstring(a.ags_table_id)),
       ") ",trim(uar_get_code_display(a.log_cd))," - ",trim(a.message))
     ELSE
      data_rec->job[jknt].grp[gknt].warning_rec[wknt].warning_line = concat(trim(current_meaning),
       ": ",trim(uar_get_code_display(a.element_cd))," (",trim(cnvtstring(a.ags_table_id)),
       ") ",trim(uar_get_code_display(a.log_cd)))
     ENDIF
    ELSEIF (trim(current_meaning)="DEBUG")
     dknt = (dknt+ 1)
     IF (mod(dknt,10)=1
      AND dknt != 1)
      stat = alterlist(data_rec->job[jknt].grp[gknt].debug_rec,(dknt+ 9))
     ENDIF
     IF (size(trim(a.message),1) > 0)
      data_rec->job[jknt].grp[gknt].debug_rec[dknt].debug_line = concat(trim(current_meaning),": ",
       trim(uar_get_code_display(a.element_cd))," (",trim(cnvtstring(a.ags_table_id)),
       ") ",trim(uar_get_code_display(a.log_cd))," - ",trim(a.message))
     ELSE
      data_rec->job[jknt].grp[gknt].debug_rec[dknt].debug_line = concat(trim(current_meaning),": ",
       trim(uar_get_code_display(a.element_cd))," (",trim(cnvtstring(a.ags_table_id)),
       ") ",trim(uar_get_code_display(a.log_cd)))
     ENDIF
    ELSEIF (trim(current_meaning)="AUDIT")
     aknt = (aknt+ 1)
     IF (mod(aknt,10)=1
      AND aknt != 1)
      stat = alterlist(data_rec->job[jknt].grp[gknt].audit_rec,(aknt+ 9))
     ENDIF
     IF (size(trim(a.message),1) > 0)
      data_rec->job[jknt].grp[gknt].audit_rec[aknt].audit_line = concat(trim(current_meaning),": ",
       trim(uar_get_code_display(a.element_cd))," (",trim(cnvtstring(a.ags_table_id)),
       ") ",trim(uar_get_code_display(a.log_cd))," - ",trim(a.message))
     ELSE
      data_rec->job[jknt].grp[gknt].audit_rec[aknt].audit_line = concat(trim(current_meaning),": ",
       trim(uar_get_code_display(a.element_cd))," (",trim(cnvtstring(a.ags_table_id)),
       ") ",trim(uar_get_code_display(a.log_cd)))
     ENDIF
    ELSEIF (trim(current_meaning)="INFO")
     iknt = (iknt+ 1)
     IF (mod(iknt,10)=1
      AND iknt != 1)
      stat = alterlist(data_rec->job[jknt].grp[gknt].info_rec,(iknt+ 9))
     ENDIF
     IF (size(trim(a.message),1) > 0)
      data_rec->job[jknt].grp[gknt].info_rec[iknt].info_line = concat(trim(current_meaning),": ",trim
       (uar_get_code_display(a.element_cd))," (",trim(cnvtstring(a.ags_table_id)),
       ") ",trim(uar_get_code_display(a.log_cd))," - ",trim(a.message))
     ELSE
      data_rec->job[jknt].grp[gknt].info_rec[iknt].info_line = concat(trim(current_meaning),": ",trim
       (uar_get_code_display(a.element_cd))," (",trim(cnvtstring(a.ags_table_id)),
       ") ",trim(uar_get_code_display(a.log_cd)))
     ENDIF
    ELSE
     uknt = (uknt+ 1)
     IF (mod(uknt,10)=1
      AND uknt != 1)
      stat = alterlist(data_rec->job[jknt].grp[gknt].unknown_rec,(uknt+ 9))
     ENDIF
     IF (size(trim(a.message),1) > 0)
      data_rec->job[jknt].grp[gknt].unknown_rec[uknt].unknown_line = concat(trim(current_meaning),
       ": ",trim(uar_get_code_display(a.element_cd))," (",trim(cnvtstring(a.ags_table_id)),
       ") ",trim(uar_get_code_display(a.log_cd))," - ",trim(a.message))
     ELSE
      data_rec->job[jknt].grp[gknt].unknown_rec[uknt].unknown_line = concat(trim(current_meaning),
       ": ",trim(uar_get_code_display(a.element_cd))," (",trim(cnvtstring(a.ags_table_id)),
       ") ",trim(uar_get_code_display(a.log_cd)))
     ENDIF
    ENDIF
   FOOT  a.ags_log_grp_id
    data_rec->job[jknt].grp[gknt].beg_dt_tm = a.log_dt_tm, data_rec->job[jknt].grp[gknt].grp_line =
    concat("Load Instance ",trim(cnvtstring(gknt)),": Beg Date/Time (",format(cnvtdatetime(data_rec->
       job[jknt].grp[gknt].beg_dt_tm),"dd-mmm-yyyy hh:mm:ss;;q"),") End Date/Time (",
     format(cnvtdatetime(data_rec->job[jknt].grp[gknt].end_dt_tm),"dd-mmm-yyyy hh:mm:ss;;q"),")"),
    data_rec->job[jknt].grp[gknt].error_rec_knt = eknt,
    stat = alterlist(data_rec->job[jknt].grp[gknt].error_rec,eknt), data_rec->job[jknt].grp[gknt].
    warning_rec_knt = wknt, stat = alterlist(data_rec->job[jknt].grp[gknt].warning_rec,wknt),
    data_rec->job[jknt].grp[gknt].debug_rec_knt = dknt, stat = alterlist(data_rec->job[jknt].grp[gknt
     ].debug_rec,dknt), data_rec->job[jknt].grp[gknt].audit_rec_knt = aknt,
    stat = alterlist(data_rec->job[jknt].grp[gknt].audit_rec,aknt), data_rec->job[jknt].grp[gknt].
    info_rec_knt = iknt, stat = alterlist(data_rec->job[jknt].grp[gknt].info_rec,iknt),
    data_rec->job[jknt].grp[gknt].unknown_rec_knt = uknt, stat = alterlist(data_rec->job[jknt].grp[
     gknt].unknown_rec,uknt)
   FOOT  a.ags_job_id
    data_rec->job[jknt].grp_knt = gknt, stat = alterlist(data_rec->job[jknt].grp,gknt)
   FOOT REPORT
    data_rec->job_knt = jknt, stat = alterlist(data_rec->job,jknt)
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   CALL ags_set_status_block(eselect,efailure,"AGS_LOG by Type/Date",trim(serrmsg))
   GO TO exit_script
  ENDIF
 ELSEIF (size(trim(sfiletype),1) > 0)
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  SELECT INTO "nl:"
   FROM ags_job j,
    ags_log a
   PLAN (j
    WHERE j.file_type=trim(sfiletype))
    JOIN (a
    WHERE a.ags_job_id=j.ags_job_id)
   ORDER BY a.ags_job_id DESC, a.ags_log_grp_id DESC, a.log_dt_tm DESC
   HEAD REPORT
    current_meaning = fillstring(12,""), jknt = 0, stat = alterlist(data_rec->job,10)
   HEAD a.ags_job_id
    jknt = (jknt+ 1)
    IF (mod(jknt,10)=1
     AND jknt != 1)
     stat = alterlist(data_rec->job,(jknt+ 9))
    ENDIF
    data_rec->job[jknt].job_line = concat(trim(j.file_type)," (",trim(cnvtstring(j.ags_job_id)),
     ") Run Nbr: ",trim(cnvtstring(j.run_nbr))), gknt = 0, stat = alterlist(data_rec->job[jknt].grp,
     10)
   HEAD a.ags_log_grp_id
    gknt = (gknt+ 1)
    IF (mod(gknt,10)=1
     AND gknt != 1)
     stat = alterlist(data_rec->job[jknt].grp,(gknt+ 9))
    ENDIF
    data_rec->job[jknt].grp[gknt].end_dt_tm = a.log_dt_tm, eknt = 0, stat = alterlist(data_rec->job[
     jknt].grp[gknt].error_rec,10),
    wknt = 0, stat = alterlist(data_rec->job[jknt].grp[gknt].warning_rec,10), dknt = 0,
    stat = alterlist(data_rec->job[jknt].grp[gknt].debug_rec,10), aknt = 0, stat = alterlist(data_rec
     ->job[jknt].grp[gknt].audit_rec,10),
    iknt = 0, stat = alterlist(data_rec->job[jknt].grp[gknt].info_rec,10), uknt = 0,
    stat = alterlist(data_rec->job[jknt].grp[gknt].unknown_rec,10), current_meaning = ""
   DETAIL
    current_meaning = uar_get_code_meaning(a.log_level_cd)
    IF (trim(current_meaning)="ERROR")
     eknt = (eknt+ 1)
     IF (mod(eknt,10)=1
      AND eknt != 1)
      stat = alterlist(data_rec->job[jknt].grp[gknt].error_rec,(eknt+ 9))
     ENDIF
     IF (size(trim(a.message),1) > 0)
      data_rec->job[jknt].grp[gknt].error_rec[eknt].error_line = concat(trim(current_meaning),": ",
       trim(uar_get_code_display(a.element_cd))," (",trim(cnvtstring(a.ags_table_id)),
       ") ",trim(uar_get_code_display(a.log_cd))," - ",trim(a.message))
     ELSE
      data_rec->job[jknt].grp[gknt].error_rec[eknt].error_line = concat(trim(current_meaning),": ",
       trim(uar_get_code_display(a.element_cd))," (",trim(cnvtstring(a.ags_table_id)),
       ") ",trim(uar_get_code_display(a.log_cd)))
     ENDIF
    ELSEIF (trim(current_meaning)="WARNING")
     wknt = (wknt+ 1)
     IF (mod(wknt,10)=1
      AND wknt != 1)
      stat = alterlist(data_rec->job[jknt].grp[gknt].warning_rec,(wknt+ 9))
     ENDIF
     IF (size(trim(a.message),1) > 0)
      data_rec->job[jknt].grp[gknt].warning_rec[wknt].warning_line = concat(trim(current_meaning),
       ": ",trim(uar_get_code_display(a.element_cd))," (",trim(cnvtstring(a.ags_table_id)),
       ") ",trim(uar_get_code_display(a.log_cd))," - ",trim(a.message))
     ELSE
      data_rec->job[jknt].grp[gknt].warning_rec[wknt].warning_line = concat(trim(current_meaning),
       ": ",trim(uar_get_code_display(a.element_cd))," (",trim(cnvtstring(a.ags_table_id)),
       ") ",trim(uar_get_code_display(a.log_cd)))
     ENDIF
    ELSEIF (trim(current_meaning)="DEBUG")
     dknt = (dknt+ 1)
     IF (mod(dknt,10)=1
      AND dknt != 1)
      stat = alterlist(data_rec->job[jknt].grp[gknt].debug_rec,(dknt+ 9))
     ENDIF
     IF (size(trim(a.message),1) > 0)
      data_rec->job[jknt].grp[gknt].debug_rec[dknt].debug_line = concat(trim(current_meaning),": ",
       trim(uar_get_code_display(a.element_cd))," (",trim(cnvtstring(a.ags_table_id)),
       ") ",trim(uar_get_code_display(a.log_cd))," - ",trim(a.message))
     ELSE
      data_rec->job[jknt].grp[gknt].debug_rec[dknt].debug_line = concat(trim(current_meaning),": ",
       trim(uar_get_code_display(a.element_cd))," (",trim(cnvtstring(a.ags_table_id)),
       ") ",trim(uar_get_code_display(a.log_cd)))
     ENDIF
    ELSEIF (trim(current_meaning)="AUDIT")
     aknt = (aknt+ 1)
     IF (mod(aknt,10)=1
      AND aknt != 1)
      stat = alterlist(data_rec->job[jknt].grp[gknt].audit_rec,(aknt+ 9))
     ENDIF
     IF (size(trim(a.message),1) > 0)
      data_rec->job[jknt].grp[gknt].audit_rec[aknt].audit_line = concat(trim(current_meaning),": ",
       trim(uar_get_code_display(a.element_cd))," (",trim(cnvtstring(a.ags_table_id)),
       ") ",trim(uar_get_code_display(a.log_cd))," - ",trim(a.message))
     ELSE
      data_rec->job[jknt].grp[gknt].audit_rec[aknt].audit_line = concat(trim(current_meaning),": ",
       trim(uar_get_code_display(a.element_cd))," (",trim(cnvtstring(a.ags_table_id)),
       ") ",trim(uar_get_code_display(a.log_cd)))
     ENDIF
    ELSEIF (trim(current_meaning)="INFO")
     iknt = (iknt+ 1)
     IF (mod(iknt,10)=1
      AND iknt != 1)
      stat = alterlist(data_rec->job[jknt].grp[gknt].info_rec,(iknt+ 9))
     ENDIF
     IF (size(trim(a.message),1) > 0)
      data_rec->job[jknt].grp[gknt].info_rec[iknt].info_line = concat(trim(current_meaning),": ",trim
       (uar_get_code_display(a.element_cd))," (",trim(cnvtstring(a.ags_table_id)),
       ") ",trim(uar_get_code_display(a.log_cd))," - ",trim(a.message))
     ELSE
      data_rec->job[jknt].grp[gknt].info_rec[iknt].info_line = concat(trim(current_meaning),": ",trim
       (uar_get_code_display(a.element_cd))," (",trim(cnvtstring(a.ags_table_id)),
       ") ",trim(uar_get_code_display(a.log_cd)))
     ENDIF
    ELSE
     uknt = (uknt+ 1)
     IF (mod(uknt,10)=1
      AND uknt != 1)
      stat = alterlist(data_rec->job[jknt].grp[gknt].unknown_rec,(uknt+ 9))
     ENDIF
     IF (size(trim(a.message),1) > 0)
      data_rec->job[jknt].grp[gknt].unknown_rec[uknt].unknown_line = concat(trim(current_meaning),
       ": ",trim(uar_get_code_display(a.element_cd))," (",trim(cnvtstring(a.ags_table_id)),
       ") ",trim(uar_get_code_display(a.log_cd))," - ",trim(a.message))
     ELSE
      data_rec->job[jknt].grp[gknt].unknown_rec[uknt].unknown_line = concat(trim(current_meaning),
       ": ",trim(uar_get_code_display(a.element_cd))," (",trim(cnvtstring(a.ags_table_id)),
       ") ",trim(uar_get_code_display(a.log_cd)))
     ENDIF
    ENDIF
   FOOT  a.ags_log_grp_id
    data_rec->job[jknt].grp[gknt].beg_dt_tm = a.log_dt_tm, data_rec->job[jknt].grp[gknt].grp_line =
    concat("Load Instance ",trim(cnvtstring(gknt)),": Beg Date/Time (",format(cnvtdatetime(data_rec->
       job[jknt].grp[gknt].beg_dt_tm),"dd-mmm-yyyy hh:mm:ss;;q"),") End Date/Time (",
     format(cnvtdatetime(data_rec->job[jknt].grp[gknt].end_dt_tm),"dd-mmm-yyyy hh:mm:ss;;q"),")"),
    data_rec->job[jknt].grp[gknt].error_rec_knt = eknt,
    stat = alterlist(data_rec->job[jknt].grp[gknt].error_rec,eknt), data_rec->job[jknt].grp[gknt].
    warning_rec_knt = wknt, stat = alterlist(data_rec->job[jknt].grp[gknt].warning_rec,wknt),
    data_rec->job[jknt].grp[gknt].debug_rec_knt = dknt, stat = alterlist(data_rec->job[jknt].grp[gknt
     ].debug_rec,dknt), data_rec->job[jknt].grp[gknt].audit_rec_knt = aknt,
    stat = alterlist(data_rec->job[jknt].grp[gknt].audit_rec,aknt), data_rec->job[jknt].grp[gknt].
    info_rec_knt = iknt, stat = alterlist(data_rec->job[jknt].grp[gknt].info_rec,iknt),
    data_rec->job[jknt].grp[gknt].unknown_rec_knt = uknt, stat = alterlist(data_rec->job[jknt].grp[
     gknt].unknown_rec,uknt)
   FOOT  a.ags_job_id
    data_rec->job[jknt].grp_knt = gknt, stat = alterlist(data_rec->job[jknt].grp,gknt)
   FOOT REPORT
    data_rec->job_knt = jknt, stat = alterlist(data_rec->job,jknt)
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   CALL ags_set_status_block(eselect,efailure,"AGS_LOG by Type",trim(serrmsg))
   GO TO exit_script
  ENDIF
 ELSEIF ((date->anchordttm > 0))
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  SELECT INTO "nl:"
   FROM ags_job j,
    ags_log a
   PLAN (a
    WHERE a.log_dt_tm >= cnvtdatetime(date->anchordttm))
    JOIN (j
    WHERE j.ags_job_id=a.ags_job_id)
   ORDER BY a.ags_job_id DESC, a.ags_log_grp_id DESC, a.log_dt_tm DESC
   HEAD REPORT
    current_meaning = fillstring(12,""), jknt = 0, stat = alterlist(data_rec->job,10)
   HEAD a.ags_job_id
    jknt = (jknt+ 1)
    IF (mod(jknt,10)=1
     AND jknt != 1)
     stat = alterlist(data_rec->job,(jknt+ 9))
    ENDIF
    data_rec->job[jknt].job_line = concat(trim(j.file_type)," (",trim(cnvtstring(j.ags_job_id)),
     ") Run Nbr: ",trim(cnvtstring(j.run_nbr))), gknt = 0, stat = alterlist(data_rec->job[jknt].grp,
     10)
   HEAD a.ags_log_grp_id
    gknt = (gknt+ 1)
    IF (mod(gknt,10)=1
     AND gknt != 1)
     stat = alterlist(data_rec->job[jknt].grp,(gknt+ 9))
    ENDIF
    data_rec->job[jknt].grp[gknt].end_dt_tm = a.log_dt_tm, eknt = 0, stat = alterlist(data_rec->job[
     jknt].grp[gknt].error_rec,10),
    wknt = 0, stat = alterlist(data_rec->job[jknt].grp[gknt].warning_rec,10), dknt = 0,
    stat = alterlist(data_rec->job[jknt].grp[gknt].debug_rec,10), aknt = 0, stat = alterlist(data_rec
     ->job[jknt].grp[gknt].audit_rec,10),
    iknt = 0, stat = alterlist(data_rec->job[jknt].grp[gknt].info_rec,10), uknt = 0,
    stat = alterlist(data_rec->job[jknt].grp[gknt].unknown_rec,10), current_meaning = ""
   DETAIL
    current_meaning = uar_get_code_meaning(a.log_level_cd)
    IF (trim(current_meaning)="ERROR")
     eknt = (eknt+ 1)
     IF (mod(eknt,10)=1
      AND eknt != 1)
      stat = alterlist(data_rec->job[jknt].grp[gknt].error_rec,(eknt+ 9))
     ENDIF
     IF (size(trim(a.message),1) > 0)
      data_rec->job[jknt].grp[gknt].error_rec[eknt].error_line = concat(trim(current_meaning),": ",
       trim(uar_get_code_display(a.element_cd))," (",trim(cnvtstring(a.ags_table_id)),
       ") ",trim(uar_get_code_display(a.log_cd))," - ",trim(a.message))
     ELSE
      data_rec->job[jknt].grp[gknt].error_rec[eknt].error_line = concat(trim(current_meaning),": ",
       trim(uar_get_code_display(a.element_cd))," (",trim(cnvtstring(a.ags_table_id)),
       ") ",trim(uar_get_code_display(a.log_cd)))
     ENDIF
    ELSEIF (trim(current_meaning)="WARNING")
     wknt = (wknt+ 1)
     IF (mod(wknt,10)=1
      AND wknt != 1)
      stat = alterlist(data_rec->job[jknt].grp[gknt].warning_rec,(wknt+ 9))
     ENDIF
     IF (size(trim(a.message),1) > 0)
      data_rec->job[jknt].grp[gknt].warning_rec[wknt].warning_line = concat(trim(current_meaning),
       ": ",trim(uar_get_code_display(a.element_cd))," (",trim(cnvtstring(a.ags_table_id)),
       ") ",trim(uar_get_code_display(a.log_cd))," - ",trim(a.message))
     ELSE
      data_rec->job[jknt].grp[gknt].warning_rec[wknt].warning_line = concat(trim(current_meaning),
       ": ",trim(uar_get_code_display(a.element_cd))," (",trim(cnvtstring(a.ags_table_id)),
       ") ",trim(uar_get_code_display(a.log_cd)))
     ENDIF
    ELSEIF (trim(current_meaning)="DEBUG")
     dknt = (dknt+ 1)
     IF (mod(dknt,10)=1
      AND dknt != 1)
      stat = alterlist(data_rec->job[jknt].grp[gknt].debug_rec,(dknt+ 9))
     ENDIF
     IF (size(trim(a.message),1) > 0)
      data_rec->job[jknt].grp[gknt].debug_rec[dknt].debug_line = concat(trim(current_meaning),": ",
       trim(uar_get_code_display(a.element_cd))," (",trim(cnvtstring(a.ags_table_id)),
       ") ",trim(uar_get_code_display(a.log_cd))," - ",trim(a.message))
     ELSE
      data_rec->job[jknt].grp[gknt].debug_rec[dknt].debug_line = concat(trim(current_meaning),": ",
       trim(uar_get_code_display(a.element_cd))," (",trim(cnvtstring(a.ags_table_id)),
       ") ",trim(uar_get_code_display(a.log_cd)))
     ENDIF
    ELSEIF (trim(current_meaning)="AUDIT")
     aknt = (aknt+ 1)
     IF (mod(aknt,10)=1
      AND aknt != 1)
      stat = alterlist(data_rec->job[jknt].grp[gknt].audit_rec,(aknt+ 9))
     ENDIF
     IF (size(trim(a.message),1) > 0)
      data_rec->job[jknt].grp[gknt].audit_rec[aknt].audit_line = concat(trim(current_meaning),": ",
       trim(uar_get_code_display(a.element_cd))," (",trim(cnvtstring(a.ags_table_id)),
       ") ",trim(uar_get_code_display(a.log_cd))," - ",trim(a.message))
     ELSE
      data_rec->job[jknt].grp[gknt].audit_rec[aknt].audit_line = concat(trim(current_meaning),": ",
       trim(uar_get_code_display(a.element_cd))," (",trim(cnvtstring(a.ags_table_id)),
       ") ",trim(uar_get_code_display(a.log_cd)))
     ENDIF
    ELSEIF (trim(current_meaning)="INFO")
     iknt = (iknt+ 1)
     IF (mod(iknt,10)=1
      AND iknt != 1)
      stat = alterlist(data_rec->job[jknt].grp[gknt].info_rec,(iknt+ 9))
     ENDIF
     IF (size(trim(a.message),1) > 0)
      data_rec->job[jknt].grp[gknt].info_rec[iknt].info_line = concat(trim(current_meaning),": ",trim
       (uar_get_code_display(a.element_cd))," (",trim(cnvtstring(a.ags_table_id)),
       ") ",trim(uar_get_code_display(a.log_cd))," - ",trim(a.message))
     ELSE
      data_rec->job[jknt].grp[gknt].info_rec[iknt].info_line = concat(trim(current_meaning),": ",trim
       (uar_get_code_display(a.element_cd))," (",trim(cnvtstring(a.ags_table_id)),
       ") ",trim(uar_get_code_display(a.log_cd)))
     ENDIF
    ELSE
     uknt = (uknt+ 1)
     IF (mod(uknt,10)=1
      AND uknt != 1)
      stat = alterlist(data_rec->job[jknt].grp[gknt].unknown_rec,(uknt+ 9))
     ENDIF
     IF (size(trim(a.message),1) > 0)
      data_rec->job[jknt].grp[gknt].unknown_rec[uknt].unknown_line = concat(trim(current_meaning),
       ": ",trim(uar_get_code_display(a.element_cd))," (",trim(cnvtstring(a.ags_table_id)),
       ") ",trim(uar_get_code_display(a.log_cd))," - ",trim(a.message))
     ELSE
      data_rec->job[jknt].grp[gknt].unknown_rec[uknt].unknown_line = concat(trim(current_meaning),
       ": ",trim(uar_get_code_display(a.element_cd))," (",trim(cnvtstring(a.ags_table_id)),
       ") ",trim(uar_get_code_display(a.log_cd)))
     ENDIF
    ENDIF
   FOOT  a.ags_log_grp_id
    data_rec->job[jknt].grp[gknt].beg_dt_tm = a.log_dt_tm, data_rec->job[jknt].grp[gknt].grp_line =
    concat("Load Instance ",trim(cnvtstring(gknt)),": Beg Date/Time (",format(cnvtdatetime(data_rec->
       job[jknt].grp[gknt].beg_dt_tm),"dd-mmm-yyyy hh:mm:ss;;q"),") End Date/Time (",
     format(cnvtdatetime(data_rec->job[jknt].grp[gknt].end_dt_tm),"dd-mmm-yyyy hh:mm:ss;;q"),")"),
    data_rec->job[jknt].grp[gknt].error_rec_knt = eknt,
    stat = alterlist(data_rec->job[jknt].grp[gknt].error_rec,eknt), data_rec->job[jknt].grp[gknt].
    warning_rec_knt = wknt, stat = alterlist(data_rec->job[jknt].grp[gknt].warning_rec,wknt),
    data_rec->job[jknt].grp[gknt].debug_rec_knt = dknt, stat = alterlist(data_rec->job[jknt].grp[gknt
     ].debug_rec,dknt), data_rec->job[jknt].grp[gknt].audit_rec_knt = aknt,
    stat = alterlist(data_rec->job[jknt].grp[gknt].audit_rec,aknt), data_rec->job[jknt].grp[gknt].
    info_rec_knt = iknt, stat = alterlist(data_rec->job[jknt].grp[gknt].info_rec,iknt),
    data_rec->job[jknt].grp[gknt].unknown_rec_knt = uknt, stat = alterlist(data_rec->job[jknt].grp[
     gknt].unknown_rec,uknt)
   FOOT  a.ags_job_id
    data_rec->job[jknt].grp_knt = gknt, stat = alterlist(data_rec->job[jknt].grp,gknt)
   FOOT REPORT
    data_rec->job_knt = jknt, stat = alterlist(data_rec->job,jknt)
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   CALL ags_set_status_block(eselect,efailure,"AGS_LOG by Date",trim(serrmsg))
   GO TO exit_script
  ENDIF
 ELSE
  CALL ags_set_status_block(eattribute,efailure,"PROMPT VALIDATION",
   "One of the Prompts (JOB_ID,FILE_TYPE,ANCHOR_DATE) must be valued")
  GO TO exit_script
 ENDIF
 IF ((data_rec->job_knt > 0))
  FOR (fdx1 = 1 TO data_rec->job_knt)
   IF (size(trim(data_rec->job[fdx1].job_line),1) > max_job_line_1_length)
    SET pt->line_cnt = 0
    EXECUTE dcp_parse_text value(trim(data_rec->job[fdx1].job_line)), value(max_job_line_1_length)
    SET data_rec->job[fdx1].wrap_line_knt = 1
    SET stat = alterlist(data_rec->job[fdx1].wrap_line,1)
    SET data_rec->job[fdx1].wrap_line[1].value = trim(pt->lns[1].line)
    SET temp_line_n = trim(substring((size(pt->lns[1].line,1)+ 1),((textlen(data_rec->job[fdx1].
       job_line) - size(pt->lns[1].line,1))+ 1),data_rec->job[fdx1].job_line),3)
    SET pt->line_cnt = 0
    EXECUTE dcp_parse_text value(temp_line_n), value(max_job_line_n_length)
    SET data_rec->job[fdx1].wrap_line_knt = (1+ pt->line_cnt)
    SET stat = alterlist(data_rec->job[fdx1].wrap_line,(1+ pt->line_cnt))
    FOR (pknt = 1 TO pt->line_cnt)
      SET data_rec->job[fdx1].wrap_line[(1+ pknt)].value = trim(pt->lns[pknt].line,3)
    ENDFOR
   ELSE
    SET data_rec->job[fdx1].wrap_line_knt = 1
    SET stat = alterlist(data_rec->job[fdx1].wrap_line,1)
    SET data_rec->job[fdx1].wrap_line[1].value = trim(data_rec->job[fdx1].job_line)
   ENDIF
   IF ((data_rec->job[fdx1].grp_knt > 0))
    FOR (fdx2 = 1 TO data_rec->job[fdx1].grp_knt)
      IF (size(trim(data_rec->job[fdx1].grp[fdx2].grp_line),1) > max_grp_line_1_length)
       SET pt->line_cnt = 0
       EXECUTE dcp_parse_text value(trim(data_rec->job[fdx1].grp[fdx2].grp_line)), value(
        max_grp_line_1_length)
       SET data_rec->job[fdx1].grp[fdx2].wrap_line_knt = 1
       SET stat = alterlist(data_rec->job[fdx1].grp[fdx2].wrap_line,1)
       SET data_rec->job[fdx1].grp[fdx2].wrap_line[1].value = trim(pt->lns[1].line)
       SET temp_line_n = trim(substring((size(pt->lns[1].line,1)+ 1),((textlen(data_rec->job[fdx1].
          grp[fdx2].grp_line) - size(pt->lns[1].line,1))+ 1),data_rec->job[fdx1].grp[fdx2].grp_line),
        3)
       SET pt->line_cnt = 0
       EXECUTE dcp_parse_text value(temp_line_n), value(max_grp_line_n_length)
       SET data_rec->job[fdx1].grp[fdx2].wrap_line_knt = (1+ pt->line_cnt)
       SET stat = alterlist(data_rec->job[fdx1].grp[fdx2].wrap_line,(1+ pt->line_cnt))
       FOR (pknt = 1 TO pt->line_cnt)
         SET data_rec->job[fdx1].grp[fdx2].wrap_line[(1+ pknt)].value = trim(pt->lns[pknt].line,3)
       ENDFOR
      ELSE
       SET data_rec->job[fdx1].grp[fdx2].wrap_line_knt = 1
       SET stat = alterlist(data_rec->job[fdx1].grp[fdx2].wrap_line,1)
       SET data_rec->job[fdx1].grp[fdx2].wrap_line[1].value = trim(data_rec->job[fdx1].grp[fdx2].
        grp_line)
      ENDIF
      IF ((data_rec->job[fdx1].grp[fdx2].error_rec_knt > 0))
       FOR (fdx3 = 1 TO data_rec->job[fdx1].grp[fdx2].error_rec_knt)
         IF (size(trim(data_rec->job[fdx1].grp[fdx2].error_rec[fdx3].error_line),1) >
         max_itm_line_1_length)
          SET pt->line_cnt = 0
          EXECUTE dcp_parse_text value(trim(data_rec->job[fdx1].grp[fdx2].error_rec[fdx3].error_line)
           ), value(max_itm_line_1_length)
          SET data_rec->job[fdx1].grp[fdx2].error_rec[fdx3].wrap_line_knt = 1
          SET stat = alterlist(data_rec->job[fdx1].grp[fdx2].error_rec[fdx3].wrap_line,1)
          SET data_rec->job[fdx1].grp[fdx2].error_rec[fdx3].wrap_line[1].value = trim(pt->lns[1].line
           )
          SET temp_line_n = trim(substring((size(pt->lns[1].line,1)+ 1),((textlen(data_rec->job[fdx1]
             .grp[fdx2].error_rec[fdx3].error_line) - size(pt->lns[1].line,1))+ 1),data_rec->job[fdx1
            ].grp[fdx2].error_rec[fdx3].error_line),3)
          SET pt->line_cnt = 0
          EXECUTE dcp_parse_text value(temp_line_n), value(max_itm_line_n_length)
          SET data_rec->job[fdx1].grp[fdx2].error_rec[fdx3].wrap_line_knt = (1+ pt->line_cnt)
          SET stat = alterlist(data_rec->job[fdx1].grp[fdx2].error_rec[fdx3].wrap_line,(1+ pt->
           line_cnt))
          FOR (pknt = 1 TO pt->line_cnt)
            SET data_rec->job[fdx1].grp[fdx2].error_rec[fdx3].wrap_line[(1+ pknt)].value = trim(pt->
             lns[pknt].line)
          ENDFOR
         ELSE
          SET data_rec->job[fdx1].grp[fdx2].error_rec[fdx3].wrap_line_knt = 1
          SET stat = alterlist(data_rec->job[fdx1].grp[fdx2].error_rec[fdx3].wrap_line,1)
          SET data_rec->job[fdx1].grp[fdx2].error_rec[fdx3].wrap_line[1].value = trim(data_rec->job[
           fdx1].grp[fdx2].error_rec[fdx3].error_line)
         ENDIF
       ENDFOR
      ENDIF
      IF ((data_rec->job[fdx1].grp[fdx2].warning_rec_knt > 0))
       FOR (fdx3 = 1 TO data_rec->job[fdx1].grp[fdx2].warning_rec_knt)
         IF (size(trim(data_rec->job[fdx1].grp[fdx2].warning_rec[fdx3].warning_line),1) >
         max_itm_line_1_length)
          SET pt->line_cnt = 0
          EXECUTE dcp_parse_text value(trim(data_rec->job[fdx1].grp[fdx2].warning_rec[fdx3].
            warning_line)), value(max_itm_line_1_length)
          SET data_rec->job[fdx1].grp[fdx2].warning_rec[fdx3].wrap_line_knt = 1
          SET stat = alterlist(data_rec->job[fdx1].grp[fdx2].warning_rec[fdx3].wrap_line,1)
          SET data_rec->job[fdx1].grp[fdx2].warning_rec[fdx3].wrap_line[1].value = trim(pt->lns[1].
           line)
          SET temp_line_n = trim(substring((size(pt->lns[1].line,1)+ 1),((textlen(data_rec->job[fdx1]
             .grp[fdx2].warning_rec[fdx3].warning_line) - size(pt->lns[1].line,1))+ 1),data_rec->job[
            fdx1].grp[fdx2].warning_rec[fdx3].warning_line),3)
          SET pt->line_cnt = 0
          EXECUTE dcp_parse_text value(temp_line_n), value(max_itm_line_n_length)
          SET data_rec->job[fdx1].grp[fdx2].warning_rec[fdx3].wrap_line_knt = (1+ pt->line_cnt)
          SET stat = alterlist(data_rec->job[fdx1].grp[fdx2].warning_rec[fdx3].wrap_line,(1+ pt->
           line_cnt))
          FOR (pknt = 1 TO pt->line_cnt)
            SET data_rec->job[fdx1].grp[fdx2].warning_rec[fdx3].wrap_line[(1+ pknt)].value = trim(pt
             ->lns[pknt].line)
          ENDFOR
         ELSE
          SET data_rec->job[fdx1].grp[fdx2].warning_rec[fdx3].wrap_line_knt = 1
          SET stat = alterlist(data_rec->job[fdx1].grp[fdx2].warning_rec[fdx3].wrap_line,1)
          SET data_rec->job[fdx1].grp[fdx2].warning_rec[fdx3].wrap_line[1].value = trim(data_rec->
           job[fdx1].grp[fdx2].warning_rec[fdx3].warning_line)
         ENDIF
       ENDFOR
      ENDIF
      IF ((data_rec->job[fdx1].grp[fdx2].debug_rec_knt > 0))
       FOR (fdx3 = 1 TO data_rec->job[fdx1].grp[fdx2].debug_rec_knt)
         IF (size(trim(data_rec->job[fdx1].grp[fdx2].debug_rec[fdx3].debug_line),1) >
         max_itm_line_1_length)
          SET pt->line_cnt = 0
          EXECUTE dcp_parse_text value(trim(data_rec->job[fdx1].grp[fdx2].debug_rec[fdx3].debug_line)
           ), value(max_itm_line_1_length)
          SET data_rec->job[fdx1].grp[fdx2].debug_rec[fdx3].wrap_line_knt = 1
          SET stat = alterlist(data_rec->job[fdx1].grp[fdx2].debug_rec[fdx3].wrap_line,1)
          SET data_rec->job[fdx1].grp[fdx2].debug_rec[fdx3].wrap_line[1].value = trim(pt->lns[1].line
           )
          SET temp_line_n = trim(substring((size(pt->lns[1].line,1)+ 1),((textlen(data_rec->job[fdx1]
             .grp[fdx2].debug_rec[fdx3].debug_line) - size(pt->lns[1].line,1))+ 1),data_rec->job[fdx1
            ].grp[fdx2].debug_rec[fdx3].debug_line),3)
          SET pt->line_cnt = 0
          EXECUTE dcp_parse_text value(temp_line_n), value(max_itm_line_n_length)
          SET data_rec->job[fdx1].grp[fdx2].debug_rec[fdx3].wrap_line_knt = (1+ pt->line_cnt)
          SET stat = alterlist(data_rec->job[fdx1].grp[fdx2].debug_rec[fdx3].wrap_line,(1+ pt->
           line_cnt))
          FOR (pknt = 1 TO pt->line_cnt)
            SET data_rec->job[fdx1].grp[fdx2].debug_rec[fdx3].wrap_line[(1+ pknt)].value = trim(pt->
             lns[pknt].line)
          ENDFOR
         ELSE
          SET data_rec->job[fdx1].grp[fdx2].debug_rec[fdx3].wrap_line_knt = 1
          SET stat = alterlist(data_rec->job[fdx1].grp[fdx2].debug_rec[fdx3].wrap_line,1)
          SET data_rec->job[fdx1].grp[fdx2].debug_rec[fdx3].wrap_line[1].value = trim(data_rec->job[
           fdx1].grp[fdx2].debug_rec[fdx3].debug_line)
         ENDIF
       ENDFOR
      ENDIF
      IF ((data_rec->job[fdx1].grp[fdx2].audit_rec_knt > 0))
       FOR (fdx3 = 1 TO data_rec->job[fdx1].grp[fdx2].audit_rec_knt)
         IF (size(trim(data_rec->job[fdx1].grp[fdx2].audit_rec[fdx3].audit_line),1) >
         max_itm_line_1_length)
          SET pt->line_cnt = 0
          EXECUTE dcp_parse_text value(trim(data_rec->job[fdx1].grp[fdx2].audit_rec[fdx3].audit_line)
           ), value(max_itm_line_1_length)
          SET data_rec->job[fdx1].grp[fdx2].audit_rec[fdx3].wrap_line_knt = 1
          SET stat = alterlist(data_rec->job[fdx1].grp[fdx2].audit_rec[fdx3].wrap_line,1)
          SET data_rec->job[fdx1].grp[fdx2].audit_rec[fdx3].wrap_line[1].value = trim(pt->lns[1].line
           )
          SET temp_line_n = trim(substring((size(pt->lns[1].line,1)+ 1),((textlen(data_rec->job[fdx1]
             .grp[fdx2].audit_rec[fdx3].audit_line) - size(pt->lns[1].line,1))+ 1),data_rec->job[fdx1
            ].grp[fdx2].audit_rec[fdx3].audit_line),3)
          SET pt->line_cnt = 0
          EXECUTE dcp_parse_text value(temp_line_n), value(max_itm_line_n_length)
          SET data_rec->job[fdx1].grp[fdx2].audit_rec[fdx3].wrap_line_knt = (1+ pt->line_cnt)
          SET stat = alterlist(data_rec->job[fdx1].grp[fdx2].audit_rec[fdx3].wrap_line,(1+ pt->
           line_cnt))
          FOR (pknt = 1 TO pt->line_cnt)
            SET data_rec->job[fdx1].grp[fdx2].audit_rec[fdx3].wrap_line[(1+ pknt)].value = trim(pt->
             lns[pknt].line)
          ENDFOR
         ELSE
          SET data_rec->job[fdx1].grp[fdx2].audit_rec[fdx3].wrap_line_knt = 1
          SET stat = alterlist(data_rec->job[fdx1].grp[fdx2].audit_rec[fdx3].wrap_line,1)
          SET data_rec->job[fdx1].grp[fdx2].audit_rec[fdx3].wrap_line[1].value = trim(data_rec->job[
           fdx1].grp[fdx2].audit_rec[fdx3].audit_line)
         ENDIF
       ENDFOR
      ENDIF
      IF ((data_rec->job[fdx1].grp[fdx2].info_rec_knt > 0))
       FOR (fdx3 = 1 TO data_rec->job[fdx1].grp[fdx2].info_rec_knt)
         IF (size(trim(data_rec->job[fdx1].grp[fdx2].info_rec[fdx3].info_line),1) >
         max_itm_line_1_length)
          SET pt->line_cnt = 0
          EXECUTE dcp_parse_text value(trim(data_rec->job[fdx1].grp[fdx2].info_rec[fdx3].info_line)),
          value(max_itm_line_1_length)
          SET data_rec->job[fdx1].grp[fdx2].info_rec[fdx3].wrap_line_knt = 1
          SET stat = alterlist(data_rec->job[fdx1].grp[fdx2].info_rec[fdx3].wrap_line,1)
          SET data_rec->job[fdx1].grp[fdx2].info_rec[fdx3].wrap_line[1].value = trim(pt->lns[1].line)
          SET temp_line_n = trim(substring((size(pt->lns[1].line,1)+ 1),((textlen(data_rec->job[fdx1]
             .grp[fdx2].info_rec[fdx3].info_line) - size(pt->lns[1].line,1))+ 1),data_rec->job[fdx1].
            grp[fdx2].info_rec[fdx3].info_line),3)
          SET pt->line_cnt = 0
          EXECUTE dcp_parse_text value(temp_line_n), value(max_itm_line_n_length)
          SET data_rec->job[fdx1].grp[fdx2].info_rec[fdx3].wrap_line_knt = (1+ pt->line_cnt)
          SET stat = alterlist(data_rec->job[fdx1].grp[fdx2].info_rec[fdx3].wrap_line,(1+ pt->
           line_cnt))
          FOR (pknt = 1 TO pt->line_cnt)
            SET data_rec->job[fdx1].grp[fdx2].info_rec[fdx3].wrap_line[(1+ pknt)].value = trim(pt->
             lns[pknt].line)
          ENDFOR
         ELSE
          SET data_rec->job[fdx1].grp[fdx2].info_rec[fdx3].wrap_line_knt = 1
          SET stat = alterlist(data_rec->job[fdx1].grp[fdx2].info_rec[fdx3].wrap_line,1)
          SET data_rec->job[fdx1].grp[fdx2].info_rec[fdx3].wrap_line[1].value = trim(data_rec->job[
           fdx1].grp[fdx2].info_rec[fdx3].info_line)
         ENDIF
       ENDFOR
      ENDIF
      IF ((data_rec->job[fdx1].grp[fdx2].unknown_rec_knt > 0))
       FOR (fdx3 = 1 TO data_rec->job[fdx1].grp[fdx2].unknown_rec_knt)
         IF (size(trim(data_rec->job[fdx1].grp[fdx2].unknown_rec[fdx3].unknown_line),1) >
         max_itm_line_1_length)
          SET pt->line_cnt = 0
          EXECUTE dcp_parse_text value(trim(data_rec->job[fdx1].grp[fdx2].unknown_rec[fdx3].
            unknown_line)), value(max_itm_line_1_length)
          SET data_rec->job[fdx1].grp[fdx2].unknown_rec[fdx3].wrap_line_knt = 1
          SET stat = alterlist(data_rec->job[fdx1].grp[fdx2].unknown_rec[fdx3].wrap_line,1)
          SET data_rec->job[fdx1].grp[fdx2].unknown_rec[fdx3].wrap_line[1].value = trim(pt->lns[1].
           line)
          SET temp_line_n = trim(substring((size(pt->lns[1].line,1)+ 1),((textlen(data_rec->job[fdx1]
             .grp[fdx2].unknown_rec[fdx3].unknown_line) - size(pt->lns[1].line,1))+ 1),data_rec->job[
            fdx1].grp[fdx2].unknown_rec[fdx3].unknown_line),3)
          SET pt->line_cnt = 0
          EXECUTE dcp_parse_text value(temp_line_n), value(max_itm_line_n_length)
          SET data_rec->job[fdx1].grp[fdx2].unknown_rec[fdx3].wrap_line_knt = (1+ pt->line_cnt)
          SET stat = alterlist(data_rec->job[fdx1].grp[fdx2].unknown_rec[fdx3].wrap_line,(1+ pt->
           line_cnt))
          FOR (pknt = 1 TO pt->line_cnt)
            SET data_rec->job[fdx1].grp[fdx2].unknown_rec[fdx3].wrap_line[(1+ pknt)].value = trim(pt
             ->lns[pknt].line)
          ENDFOR
         ELSE
          SET data_rec->job[fdx1].grp[fdx2].unknown_rec[fdx3].wrap_line_knt = 1
          SET stat = alterlist(data_rec->job[fdx1].grp[fdx2].unknown_rec[fdx3].wrap_line,1)
          SET data_rec->job[fdx1].grp[fdx2].unknown_rec[fdx3].wrap_line[1].value = trim(data_rec->
           job[fdx1].grp[fdx2].unknown_rec[fdx3].unknown_line)
         ENDIF
       ENDFOR
      ENDIF
    ENDFOR
   ENDIF
  ENDFOR
 ELSE
  CALL ags_set_status_block(ecustom,einfo,"Get Data",concat("No Data Found for JobId (",trim(
     cnvtstring(djobid)),") File Type (",trim(sfiletype),") Date (",
    trim(sanchordate)))
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "MINE"
  FROM (dummyt d  WITH seq = value(data_rec->job_knt))
  PLAN (d
   WHERE d.seq > 0)
  HEAD REPORT
   job_line = fillstring(120,""), grp_line = fillstring(110,""), itm_line = fillstring(100,"")
  HEAD d.seq
   job_line = "", grp_line = "", itm_line = "",
   row + 1
   FOR (wdx = 1 TO data_rec->job[d.seq].wrap_line_knt)
     job_line = trim(data_rec->job[d.seq].wrap_line[wdx].value)
     IF (wdx=1)
      col 0, job_line
     ELSE
      col 5, job_line
     ENDIF
     row + 1
   ENDFOR
   FOR (gdx = 1 TO data_rec->job[d.seq].grp_knt)
     FOR (wdx = 1 TO data_rec->job[d.seq].grp[gdx].wrap_line_knt)
       grp_line = data_rec->job[d.seq].grp[gdx].wrap_line[wdx].value
       IF (wdx=1)
        col 10, grp_line
       ELSE
        col 15, grp_line
       ENDIF
       row + 1
     ENDFOR
     IF ((data_rec->job[d.seq].grp[gdx].error_rec_knt > 0))
      FOR (mdx = 1 TO data_rec->job[d.seq].grp[gdx].error_rec_knt)
        FOR (wdx = 1 TO data_rec->job[d.seq].grp[gdx].error_rec[mdx].wrap_line_knt)
          itm_line = trim(data_rec->job[d.seq].grp[gdx].error_rec[mdx].wrap_line[wdx].value)
          IF (wdx=1)
           col 20, itm_line
          ELSE
           col 25, itm_line
          ENDIF
          row + 1
        ENDFOR
      ENDFOR
     ENDIF
     IF ((data_rec->job[d.seq].grp[gdx].warning_rec_knt > 0))
      FOR (mdx = 1 TO data_rec->job[d.seq].grp[gdx].warning_rec_knt)
        FOR (wdx = 1 TO data_rec->job[d.seq].grp[gdx].warning_rec[mdx].wrap_line_knt)
          itm_line = trim(data_rec->job[d.seq].grp[gdx].warning_rec[mdx].wrap_line[wdx].value)
          IF (wdx=1)
           col 20, itm_line
          ELSE
           col 25, itm_line
          ENDIF
          row + 1
        ENDFOR
      ENDFOR
     ENDIF
     IF ((data_rec->job[d.seq].grp[gdx].debug_rec_knt > 0))
      FOR (mdx = 1 TO data_rec->job[d.seq].grp[gdx].debug_rec_knt)
        FOR (wdx = 1 TO data_rec->job[d.seq].grp[gdx].debug_rec[mdx].wrap_line_knt)
          itm_line = trim(data_rec->job[d.seq].grp[gdx].debug_rec[mdx].wrap_line[wdx].value)
          IF (wdx=1)
           col 20, itm_line
          ELSE
           col 25, itm_line
          ENDIF
          row + 1
        ENDFOR
      ENDFOR
     ENDIF
     IF ((data_rec->job[d.seq].grp[gdx].audit_rec_knt > 0))
      FOR (mdx = 1 TO data_rec->job[d.seq].grp[gdx].audit_rec_knt)
        FOR (wdx = 1 TO data_rec->job[d.seq].grp[gdx].audit_rec[mdx].wrap_line_knt)
          itm_line = trim(data_rec->job[d.seq].grp[gdx].audit_rec[mdx].wrap_line[wdx].value)
          IF (wdx=1)
           col 20, itm_line
          ELSE
           col 25, itm_line
          ENDIF
          row + 1
        ENDFOR
      ENDFOR
     ENDIF
     IF ((data_rec->job[d.seq].grp[gdx].info_rec_knt > 0))
      FOR (mdx = 1 TO data_rec->job[d.seq].grp[gdx].info_rec_knt)
        FOR (wdx = 1 TO data_rec->job[d.seq].grp[gdx].info_rec[mdx].wrap_line_knt)
          itm_line = trim(data_rec->job[d.seq].grp[gdx].info_rec[mdx].wrap_line[wdx].value)
          IF (wdx=1)
           col 20, itm_line
          ELSE
           col 25, itm_line
          ENDIF
          row + 1
        ENDFOR
      ENDFOR
     ENDIF
     IF ((data_rec->job[d.seq].grp[gdx].unknown_rec_knt > 0))
      FOR (mdx = 1 TO data_rec->job[d.seq].grp[gdx].unknown_rec_knt)
        FOR (wdx = 1 TO data_rec->job[d.seq].grp[gdx].unknown_rec[mdx].wrap_line_knt)
          itm_line = trim(data_rec->job[d.seq].grp[gdx].unknown_rec[mdx].wrap_line[wdx].value)
          IF (wdx=1)
           col 20, itm_line
          ELSE
           col 25, itm_line
          ENDIF
          row + 1
        ENDFOR
      ENDFOR
     ENDIF
   ENDFOR
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  CALL ags_set_status_block(eselect,efailure,"Create Report",trim(serrmsg))
  GO TO exit_script
 ENDIF
 CALL ags_set_status_block(ecustom,einfo,"AGS_RPT_LOG_BASIC TESTING",build2("dJobId (",djobid,
   ") sFileType (",sfiletype,") AnchorDtTm (",
   format(date->anchordttm,"DD-MMM-YYYY;;q"),")"))
 GO TO exit_script
#exit_script
 CALL echo("***")
 CALL echo("***   END> AGS_RPT_LOG_BASIC")
 CALL echo("***")
 SET script_ver = "000 11/28/06"
END GO
