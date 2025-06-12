CREATE PROGRAM ags_report:dba
 PROMPT
  "Date (DD-MMM-YYYY HH:MM:SS or LAST):" = "",
  "Task Type ORG            (1-Report): " = 0,
  "Task Type PRSNL          (1-Report): " = 0,
  "Task Type PERSON         (1-Report): " = 0,
  "Task Type BENEFIT LEVEL  (1-Report): " = 0,
  "Task Type CLAIM          (1-Report): " = 0,
  "Task Type CLAIM DETAIL   (1-Report): " = 0,
  "Task Type MEDS           (1-Report): " = 0,
  "Task Type IMMUN          (1-Report): " = 0,
  "Task Type RESULT         (1-Report): " = 0
 CALL echo("<===== AGS_REPORT Begin =====>")
 FREE RECORD reportdata
 RECORD reportdata(
   1 row_cnt = i4
   1 complete_cnt = i4
   1 hold_cnt = i4
   1 error_cnt = i4
   1 backout_cnt = i4
   1 waiting_cnt = i4
   1 percent_loaded = f8
   1 qual_cnt = i4
   1 qual[*]
     2 table_name = vc
     2 pk_name = vc
     2 fk_name = vc
     2 run_dt_tm = dq8
     2 row_cnt = i4
     2 complete_cnt = i4
     2 hold_cnt = i4
     2 error_cnt = i4
     2 backout_cnt = i4
     2 waiting_cnt = i4
     2 percent_loaded = f8
     2 stat_msg = vc
     2 qual2_cnt = i4
     2 qual2[*]
       3 ags_job_id = f8
 )
 DECLARE sdate = vc WITH public, noconstant(trim( $1))
 DECLARE borgreport = i2 WITH public, noconstant( $2)
 DECLARE bprsnlreport = i2 WITH public, noconstant( $3)
 DECLARE bpersonreport = i2 WITH public, noconstant( $4)
 DECLARE bbenefitlevelreport = i2 WITH public, noconstant( $5)
 DECLARE bclaimreport = i2 WITH public, noconstant( $6)
 DECLARE bclaimdetailreport = i2 WITH public, noconstant( $7)
 DECLARE bmedsreport = i2 WITH public, noconstant( $8)
 DECLARE bimmunreport = i2 WITH public, noconstant( $9)
 DECLARE bresultreport = i2 WITH public, noconstant( $10)
 DECLARE lorgidx = i4 WITH public, constant(1)
 DECLARE lprsnlidx = i4 WITH public, constant(2)
 DECLARE lpersonidx = i4 WITH public, constant(3)
 DECLARE lbenefitidx = i4 WITH public, constant(4)
 DECLARE lmedsidx = i4 WITH public, constant(5)
 DECLARE lclaimidx = i4 WITH public, constant(6)
 DECLARE lclaimdidx = i4 WITH public, constant(7)
 DECLARE limmunidx = i4 WITH public, constant(8)
 DECLARE lresultidx = i4 WITH public, constant(9)
 DECLARE lidx = i4 WITH public, noconstant(0)
 DECLARE lrowcnt = i4 WITH public, noconstant(0)
 DECLARE lloaded = i4 WITH public, noconstant(0)
 DECLARE dtdate = dq8 WITH public, noconstant(cnvtdatetime("01-JAN-1800 00:00:00"))
 DECLARE blast = i2 WITH public, noconstant(false)
 DECLARE sfiletype = vc WITH public, noconstant("all")
 DECLARE str0 = vc WITH public, noconstant("")
 DECLARE str1 = vc WITH public, noconstant("")
 DECLARE str2 = vc WITH public, noconstant("")
 DECLARE str3 = vc WITH public, noconstant("")
 DECLARE str4 = vc WITH public, noconstant("")
 DECLARE str5 = vc WITH public, noconstant("")
 DECLARE str6 = vc WITH public, noconstant("")
 DECLARE str7 = vc WITH public, noconstant("")
 DECLARE str8 = vc WITH public, noconstant("")
 DECLARE str9 = vc WITH public, noconstant("")
 SET reportdata->qual_cnt = lresultidx
 SET stat = alterlist(reportdata->qual,lresultidx)
 SET reportdata->qual[lorgidx].table_name = "AGS_ORG_DATA"
 SET reportdata->qual[lorgidx].pk_name = "AGS_ORG_DATA_ID"
 SET reportdata->qual[lorgidx].fk_name = "ORGANIZATION_ID"
 SET reportdata->qual[lprsnlidx].table_name = "AGS_PRSNL_DATA"
 SET reportdata->qual[lprsnlidx].pk_name = "AGS_PRSNL_DATA_ID"
 SET reportdata->qual[lprsnlidx].fk_name = "PERSON_ID"
 SET reportdata->qual[lprsnlidx].table_name = "AGS_PRSNL_DATA"
 SET reportdata->qual[lprsnlidx].pk_name = "AGS_PRSNL_DATA_ID"
 SET reportdata->qual[lprsnlidx].fk_name = "PERSON_ID"
 SET reportdata->qual[lpersonidx].table_name = "AGS_PERSON_DATA"
 SET reportdata->qual[lpersonidx].pk_name = "AGS_PERSON_DATA_ID"
 SET reportdata->qual[lpersonidx].fk_name = "PERSON_ID"
 SET reportdata->qual[lbenefitidx].table_name = "AGS_BENEFIT_LEVEL_DATA"
 SET reportdata->qual[lbenefitidx].pk_name = "AGS_BENEFIT_LEVEL_DATA_ID"
 SET reportdata->qual[lbenefitidx].fk_name = "PERSON_ID"
 SET reportdata->qual[lmedsidx].table_name = "AGS_MEDS_DATA"
 SET reportdata->qual[lmedsidx].pk_name = "AGS_MEDS_DATA_ID"
 SET reportdata->qual[lmedsidx].fk_name = "GS_MED_CLAIM_ID"
 SET reportdata->qual[lclaimidx].table_name = "AGS_CLAIM_DATA"
 SET reportdata->qual[lclaimidx].pk_name = "AGS_CLAIM_DATA_ID"
 SET reportdata->qual[lclaimidx].fk_name = "HEA_CLAIM_VISIT_ID"
 SET reportdata->qual[lclaimdidx].table_name = "AGS_CLAIM_DETAIL_DATA"
 SET reportdata->qual[lclaimdidx].pk_name = "AGS_CLAIM_DETAIL_DATA_ID"
 SET reportdata->qual[lclaimdidx].fk_name = "HEA_CLAIM_VISIT_DETAIL_ID"
 SET reportdata->qual[limmunidx].table_name = "AGS_IMMUN_DATA"
 SET reportdata->qual[limmunidx].pk_name = "AGS_IMMUN_DATA_ID"
 SET reportdata->qual[limmunidx].fk_name = "EVENT_ID"
 SET reportdata->qual[lresultidx].table_name = "AGS_RESULT_DATA"
 SET reportdata->qual[lresultidx].pk_name = "AGS_RESULT_DATA_ID"
 SET reportdata->qual[lresultidx].fk_name = "EVENT_ID"
 CALL echo("Determin Select Criteria...")
 IF (size(sdate) > 0)
  IF (cnvtupper(sdate)="LAST")
   SET blast = true
   SET sfiletype = "last"
  ELSE
   SET dtdate = cnvtdatetime(sdate)
   SET sfiletype = "date"
  ENDIF
 ENDIF
 CALL echo("Select AGS_JOB_IDs...")
 SELECT INTO "nl:"
  FROM ags_task t
  WHERE t.ags_task_id > 0.0
   AND t.batch_start_dt_tm >= cnvtdatetime(dtdate)
  ORDER BY t.batch_start_dt_tm DESC, t.ags_job_id
  HEAD t.ags_job_id
   IF (borgreport
    AND t.task_type="ORG")
    IF ((( NOT (blast)) OR (blast
     AND (reportdata->qual[lorgidx].qual2_cnt <= 0))) )
     lidx = (reportdata->qual[lorgidx].qual2_cnt+ 1), reportdata->qual[lorgidx].qual2_cnt = lidx,
     stat = alterlist(reportdata->qual[lorgidx].qual2,lidx),
     reportdata->qual[lorgidx].qual2[lidx].ags_job_id = t.ags_job_id
    ENDIF
   ENDIF
   IF (bprsnlreport
    AND t.task_type="PRSNL")
    IF ((( NOT (blast)) OR (blast
     AND (reportdata->qual[lprsnlidx].qual2_cnt <= 0))) )
     lidx = (reportdata->qual[lprsnlidx].qual2_cnt+ 1), reportdata->qual[lprsnlidx].qual2_cnt = lidx,
     stat = alterlist(reportdata->qual[lprsnlidx].qual2,lidx),
     reportdata->qual[lprsnlidx].qual2[lidx].ags_job_id = t.ags_job_id
    ENDIF
   ENDIF
   IF (bpersonreport
    AND t.task_type="PERSON")
    IF ((( NOT (blast)) OR (blast
     AND (reportdata->qual[lpersonidx].qual2_cnt <= 0))) )
     lidx = (reportdata->qual[lpersonidx].qual2_cnt+ 1), reportdata->qual[lpersonidx].qual2_cnt =
     lidx, stat = alterlist(reportdata->qual[lpersonidx].qual2,lidx),
     reportdata->qual[lpersonidx].qual2[lidx].ags_job_id = t.ags_job_id
    ENDIF
   ENDIF
   IF (bbenefitlevelreport
    AND t.task_type="BENEFIT LEVEL")
    IF ((( NOT (blast)) OR (blast
     AND (reportdata->qual[lbenefitidx].qual2_cnt <= 0))) )
     lidx = (reportdata->qual[lbenefitidx].qual2_cnt+ 1), reportdata->qual[lbenefitidx].qual2_cnt =
     lidx, stat = alterlist(reportdata->qual[lbenefitidx].qual2,lidx),
     reportdata->qual[lbenefitidx].qual2[lidx].ags_job_id = t.ags_job_id
    ENDIF
   ENDIF
   IF (bmedsreport
    AND t.task_type="MEDS")
    IF ((( NOT (blast)) OR (blast
     AND (reportdata->qual[lmedsidx].qual2_cnt <= 0))) )
     lidx = (reportdata->qual[lmedsidx].qual2_cnt+ 1), reportdata->qual[lmedsidx].qual2_cnt = lidx,
     stat = alterlist(reportdata->qual[lmedsidx].qual2,lidx),
     reportdata->qual[lmedsidx].qual2[lidx].ags_job_id = t.ags_job_id
    ENDIF
   ENDIF
   IF (bclaimreport
    AND t.task_type="CLAIM")
    IF ((( NOT (blast)) OR (blast
     AND (reportdata->qual[lclaimidx].qual2_cnt <= 0))) )
     lidx = (reportdata->qual[lclaimidx].qual2_cnt+ 1), reportdata->qual[lclaimidx].qual2_cnt = lidx,
     stat = alterlist(reportdata->qual[lclaimidx].qual2,lidx),
     reportdata->qual[lclaimidx].qual2[lidx].ags_job_id = t.ags_job_id
    ENDIF
   ENDIF
   IF (bclaimdetailreport
    AND t.task_type="CLAIM DETAIL")
    IF ((( NOT (blast)) OR (blast
     AND (reportdata->qual[lclaimdidx].qual2_cnt <= 0))) )
     lidx = (reportdata->qual[lclaimdidx].qual2_cnt+ 1), reportdata->qual[lclaimdidx].qual2_cnt =
     lidx, stat = alterlist(reportdata->qual[lclaimdidx].qual2,lidx),
     reportdata->qual[lclaimdidx].qual2[lidx].ags_job_id = t.ags_job_id
    ENDIF
   ENDIF
   IF (bimmunreport
    AND t.task_type="IMMUN")
    IF ((( NOT (blast)) OR (blast
     AND (reportdata->qual[limmunidx].qual2_cnt <= 0))) )
     lidx = (reportdata->qual[limmunidx].qual2_cnt+ 1), reportdata->qual[limmunidx].qual2_cnt = lidx,
     stat = alterlist(reportdata->qual[limmunidx].qual2,lidx),
     reportdata->qual[limmunidx].qual2[lidx].ags_job_id = t.ags_job_id
    ENDIF
   ENDIF
   IF (bresultreport
    AND t.task_type="RESULT")
    IF ((( NOT (blast)) OR (blast
     AND (reportdata->qual[lresultidx].qual2_cnt <= 0))) )
     lidx = (reportdata->qual[lresultidx].qual2_cnt+ 1), reportdata->qual[lresultidx].qual2_cnt =
     lidx, stat = alterlist(reportdata->qual[lresultidx].qual2,lidx),
     reportdata->qual[lresultidx].qual2[lidx].ags_job_id = t.ags_job_id
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("Select Data...")
 FOR (lidx = 1 TO reportdata->qual_cnt)
   IF ((reportdata->qual[lidx].qual2_cnt > 0))
    SET lrowcnt = 0
    SET str1 = concat('select into "nl:" ',
     "from (dummyt d with seq = value(ReportData->qual[lIdx]->qual2_cnt)), ",trim(reportdata->qual[
      lidx].table_name)," t")
    SET str2 = concat("plan d ","join t ",
     "where t.AGS_JOB_ID = ReportData->qual[lIdx]->qual2[d.seq]->ags_job_id")
    SET str3 = concat("head t.",trim(reportdata->qual[lidx].pk_name),"   lRowCnt = lRowCnt + 1",
     "   case( t.STATUS )",'   of "COMPLETE":',
     "      if( t.",trim(reportdata->qual[lidx].fk_name)," > 0.0 )",
     "         ReportData->qual[lIdx]->complete_cnt = ReportData->qual[lIdx]->complete_cnt + 1",
     "      endif",
     '   of "HOLD":',
     "      ReportData->qual[lIdx]->hold_cnt    = ReportData->qual[lIdx]->hold_cnt + 1",
     '   of "IN ERROR":',
     "      ReportData->qual[lIdx]->error_cnt   = ReportData->qual[lIdx]->error_cnt + 1",
     '   of "BACK OUT":',
     "      ReportData->qual[lIdx]->backout_cnt = ReportData->qual[lIdx]->backout_cnt + 1",
     '   of "WAITING":',
     "      ReportData->qual[lIdx]->waiting_cnt = ReportData->qual[lIdx]->waiting_cnt + 1",
     "   endcase","   if( size(t.STAT_MSG) > 0 )",
     "      ReportData->qual[lIdx]->stat_msg = ",
     "                  build( trim(ReportData->qual[lIdx]->stat_msg), t.STAT_MSG )","   endif")
    SET str4 = concat("foot report","   ReportData->qual[lIdx]->row_cnt   = lRowCnt",
     "   ReportData->qual[lIdx]->run_dt_tm = t.RUN_DT_TM ","with nocounter go")
    CALL parser(str1)
    CALL parser(str2)
    CALL parser(str3)
    CALL parser(str4)
    CALL echo(concat("Row Count - ",build(reportdata->qual[lidx].row_cnt)))
    SET reportdata->row_cnt = (reportdata->row_cnt+ reportdata->qual[lidx].row_cnt)
    CALL echo(concat("Complete Row Count - ",build(reportdata->qual[lidx].complete_cnt)))
    SET reportdata->complete_cnt = (reportdata->complete_cnt+ reportdata->qual[lidx].complete_cnt)
    CALL echo(concat("Replaced Row Count - ",build(reportdata->qual[lidx].hold_cnt)))
    SET reportdata->hold_cnt = (reportdata->hold_cnt+ reportdata->qual[lidx].hold_cnt)
    CALL echo(concat("Error Row Count    - ",build(reportdata->qual[lidx].error_cnt)))
    SET reportdata->error_cnt = (reportdata->error_cnt+ reportdata->qual[lidx].error_cnt)
    CALL echo(concat("Backout Row Count  - ",build(reportdata->qual[lidx].backout_cnt)))
    SET reportdata->backout_cnt = (reportdata->backout_cnt+ reportdata->qual[lidx].backout_cnt)
    CALL echo(concat("Waiting Row Count  - ",build(reportdata->qual[lidx].waiting_cnt)))
    SET reportdata->waiting_cnt = (reportdata->waiting_cnt+ reportdata->qual[lidx].waiting_cnt)
    SET lloaded = reportdata->qual[lidx].complete_cnt
    IF ((reportdata->qual[lidx].row_cnt > 0))
     SET reportdata->qual[lidx].percent_loaded = ((cnvtreal(lloaded)/ cnvtreal(reportdata->qual[lidx]
      .row_cnt)) * 100)
    ELSE
     CALL echo(concat("** No rows found on table: ",reportdata->qual[lidx].table_name))
    ENDIF
   ENDIF
 ENDFOR
 IF ((reportdata->row_cnt > 0))
  CALL echo("Build .CSV File...")
  SET reportdata->percent_loaded = ((cnvtreal(reportdata->complete_cnt)/ cnvtreal(reportdata->row_cnt
   )) * 100)
  SET logical output_file_location value(build("ags_report_",sfiletype,"_",format(curdate,
     "MMDDYYYY;;D"),".csv"))
  SELECT INTO "output_file_location"
   FROM (dummyt d  WITH seq = value(reportdata->qual_cnt))
   PLAN (d)
   HEAD REPORT
    str0 = concat(",,,UPLOAD DASHBOARD - ",cnvtupper(sfiletype)," RUN REPORT"), str0, row + 1,
    str0 =
    ",ORGANIZATION,PERSONNEL,MEMBER,BENEFIT LEVEL,MEDICATION,CLAIM HEADER,CLAIM DETAIL,IMMUNIZATION,LAB RESULT,TOTALS",
    str0, row + 1,
    str0 = "Status", str0, row + 1,
    str1 = "% Loaded,", str2 = "Records,", str3 = "Complete Records,",
    str4 = "Hold Records,", str5 = "Error Records,", str6 = "BackOut Records,",
    str7 = "Waiting Records,", str8 = "Run Date,", str9 = "Key Issues,"
   DETAIL
    str1 = concat(str1,trim(format(reportdata->qual[d.seq].percent_loaded,"###.#####"),3),"%,"),
    str2 = concat(str2,build(reportdata->qual[d.seq].row_cnt),","), str3 = concat(str3,build(
      reportdata->qual[d.seq].complete_cnt),","),
    str4 = concat(str4,build(reportdata->qual[d.seq].hold_cnt),","), str5 = concat(str5,build(
      reportdata->qual[d.seq].error_cnt),","), str6 = concat(str6,build(reportdata->qual[d.seq].
      backout_cnt),","),
    str7 = concat(str7,build(reportdata->qual[d.seq].waiting_cnt),","), str8 = concat(str8,trim(
      format(reportdata->qual[d.seq].run_dt_tm,"MM/DD/YYYY;;d")),",")
    IF (size(trim(reportdata->qual[d.seq].stat_msg,3)) > 100)
     str9 = concat(str9,substring(1,100,trim(reportdata->qual[d.seq].stat_msg,3)),",")
    ELSE
     str9 = concat(str9,trim(reportdata->qual[d.seq].stat_msg,3),",")
    ENDIF
   FOOT REPORT
    str1 = concat(str1,trim(format(reportdata->percent_loaded,"###.#####"),3),"%,"), str2 = concat(
     str2,build(reportdata->row_cnt),","), str3 = concat(str3,build(reportdata->complete_cnt),","),
    str4 = concat(str4,build(reportdata->hold_cnt),","), str5 = concat(str5,build(reportdata->
      error_cnt),","), str6 = concat(str6,build(reportdata->backout_cnt),","),
    str7 = concat(str7,build(reportdata->waiting_cnt),","), str8 = concat(str8,","), str9 = concat(
     str9,","),
    str1, row + 1, str2,
    row + 1, str3, row + 1,
    str4, row + 1, str5,
    row + 1, str6, row + 1,
    str7, row + 1, str8,
    row + 1, str9, row + 1
   WITH nocounter, maxcol = 950, format = variable,
    formfeed = none
  ;end select
 ENDIF
#exit_script
 CALL echo("<===== AGS_REPORT End =====>")
END GO
