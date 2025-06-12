CREATE PROGRAM cn_updt_incorrect_child_docs:dba
 PROMPT
  "Enter begin date in DD-MMM-YYYY format (defaults to 18-JAN-2011) :" = "18-FEB-2011",
  "Enter the number of days to process per batch (defaults to 1)  :" = "1"
  WITH begindate, batchsize
 IF (datetimecmp(cnvtdatetime( $BEGINDATE),cnvtdatetime("18-FEB-2011")) < 0)
  GO TO exit_script
 ENDIF
 IF (cnvtreal( $BATCHSIZE) < 1)
  GO TO exit_script
 ENDIF
 DECLARE mdoc_cd = f8 WITH constant(uar_get_code_by("MEANING",53,"MDOC")), protect
 DECLARE doc_cd = f8 WITH constant(uar_get_code_by("MEANING",53,"DOC")), protect
 DECLARE unauth_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"UNAUTH")), protect
 DECLARE inprogress_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"IN PROGRESS")), protect
 DECLARE auth_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH")), protect
 DECLARE transcribed_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"TRANSCRIBED")), protect
 DECLARE logfilename = vc WITH constant(build("cer_temp:updt_incorrect_child_docs_log",format(curdate,
    "yymmdd;;d"),format(curtime,"hhmm;;m"),".csv"))
 DECLARE begindatetime = dq8 WITH constant(cnvtdatetime( $BEGINDATE))
 DECLARE begindatetimeconst = dq8 WITH constant(begindatetime)
 DECLARE currentdatetime = dq8 WITH constant(cnvtdatetime(curdate,curtime))
 DECLARE totaldaterange = f8 WITH constant(datetimediff(currentdatetime,begindatetime))
 DECLARE bucketsize = f8 WITH constant(cnvtreal( $BATCHSIZE))
 DECLARE eventtotalcount = i4 WITH noconstant(0)
 DECLARE maxcommit = i4 WITH constant(250000)
 DECLARE startindex = i4 WITH noconstant(1)
 DECLARE endindex = i4 WITH noconstant(value(0))
 DECLARE statusmsg = vc WITH noconstant("")
 DECLARE statusresult = vc WITH noconstant("")
 SELECT INTO value(logfilename)
  DETAIL
   '"Event Id","Author Name","Author Id","Patient Name","Patient Id","Note Type","Document Status"',
   ',"Document Title","Perform Date and Time","Service Date and Time","Authentic Flag","Publish Flag"'
  WITH nocounter, format = variable, noformfeed,
   maxcol = 700, maxrow = 1, append
 ;end select
 CALL echo(build("The processing status output file name is :",logfilename))
 FREE SET table_temp
 RECORD table_temp(
   1 list[maxcommit]
     2 event_id = f8
     2 publish_flag = i4
 )
 DECLARE iteration = i4 WITH noconstant(1)
 DECLARE eventcount = i4 WITH noconstant(0)
 DECLARE recstr = vc WITH noconstant("")
 DECLARE numberofiteration = i4 WITH constant(ceil((cnvtreal(totaldaterange)/ cnvtreal(bucketsize))))
 CALL echo(build("   Number of Iterations: ",numberofiteration))
 DECLARE batchbegindttm = f8 WITH noconstant(begindatetime)
 DECLARE batchenddttm = f8 WITH noconstant(datetimeadd(batchbegindttm,bucketsize))
 FOR (iteration = 1 TO numberofiteration)
   IF (iteration=numberofiteration)
    SET batchenddttm = currentdatetime
   ENDIF
   SET endindex = 0
   SELECT DISTINCT INTO "nl:"
    ce2.event_id, ce.publish_flag
    FROM clinical_event ce,
     clinical_event ce2
    PLAN (ce
     WHERE ce.updt_dt_tm >= cnvtdatetime(batchbegindttm)
      AND ce.updt_dt_tm < cnvtdatetime(batchenddttm)
      AND ce.performed_dt_tm > cnvtdatetime(begindatetimeconst)
      AND ce.event_class_cd=mdoc_cd
      AND ce.result_status_cd=auth_cd
      AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100"))
     JOIN (ce2
     WHERE ce2.parent_event_id=ce.event_id
      AND ce2.performed_dt_tm=ce.performed_dt_tm
      AND ce2.event_class_cd=doc_cd
      AND ce2.result_status_cd IN (unauth_cd, inprogress_cd, transcribed_cd)
      AND ce2.valid_until_dt_tm=cnvtdatetime("31-DEC-2100"))
    HEAD REPORT
     eventcount = 0
    DETAIL
     eventcount = (eventcount+ 1), table_temp->list[eventcount].event_id = ce2.event_id, table_temp->
     list[eventcount].publish_flag = ce.publish_flag
    FOOT REPORT
     eventtotalcount = (eventtotalcount+ eventcount), endindex = eventcount,
     CALL echo(build("   Number of affected events: ",eventcount))
    WITH nocounter
   ;end select
   SET batchbegindttm = batchenddttm
   SET batchenddttm = datetimeadd(batchbegindttm,bucketsize)
   IF (endindex > 0)
    UPDATE  FROM (dummyt d  WITH seq = value(endindex)),
      clinical_event ce
     SET ce.result_status_cd = auth_cd, ce.authentic_flag = 1, ce.publish_flag = table_temp->list[d
      .seq].publish_flag
     PLAN (d
      WHERE d.seq >= startindex
       AND d.seq <= endindex)
      JOIN (ce
      WHERE (ce.event_id=table_temp->list[d.seq].event_id)
       AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100"))
    ;end update
    SET statusmsg = concat("  Processing ",build(" ",curqual)," rows of qualifying events...")
    CALL echo(statusmsg)
    COMMIT
    IF ((curqual != ((endindex+ 1) - startindex)))
     SET statusresult = "   Result status is Failure"
    ELSE
     SET statusresult = "   Result status is Success"
    ENDIF
    CALL echo(statusresult)
    SELECT INTO value(logfilename)
     ce2.event_id
     FROM clinical_event ce,
      clinical_event ce2,
      prsnl p,
      person pat,
      (dummyt d  WITH seq = value(endindex))
     PLAN (d)
      JOIN (ce
      WHERE (ce.event_id=table_temp->list[d.seq].event_id)
       AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100"))
      JOIN (ce2
      WHERE ce2.event_id=ce.parent_event_id
       AND ce2.valid_until_dt_tm=cnvtdatetime("31-DEC-2100"))
      JOIN (p
      WHERE p.person_id=ce2.performed_prsnl_id)
      JOIN (pat
      WHERE pat.person_id=ce2.person_id)
     HEAD REPORT
      eventcount = 0
     DETAIL
      eventcount = (eventcount+ 1), recstr = "", quote_str = "",
      comma_str = "",
      CALL subr_out(build(ce2.event_id)), comma_str = ",",
      quote_str = '"',
      CALL subr_out(build(p.name_full_formatted)), quote_str = "",
      CALL subr_out(build(ce2.performed_prsnl_id)), quote_str = '"',
      CALL subr_out(build(pat.name_full_formatted)),
      quote_str = "",
      CALL subr_out(build(ce2.person_id)), quote_str = '"',
      CALL subr_out(build(uar_get_code_display(ce2.event_cd))),
      CALL subr_out(build(uar_get_code_display(ce2.result_status_cd))), quote_str = '"',
      CALL subr_out(trim(ce2.event_title_text)), quote_str = "",
      CALL subr_out(build(format(ce2.performed_dt_tm,"@SHORTDATETIME"))),
      CALL subr_out(build(format(ce2.event_end_dt_tm,"@SHORTDATETIME"))),
      CALL subr_out(build(ce2.authentic_flag)),
      CALL subr_out(build(ce2.publish_flag))
      IF (eventcount=1
       AND iteration=1)
       row + 1
      ELSEIF (eventcount != 1)
       row + 1
      ENDIF
      col 1, recstr,
      SUBROUTINE subr_out(p_data)
        recstr = concat(trim(recstr),trim(comma_str),trim(quote_str),build(p_data),trim(quote_str))
      END ;Subroutine report
     WITH nocounter, check, format = variable,
      noformfeed, maxcol = 700, maxrow = 1,
      append
    ;end select
   ENDIF
 ENDFOR
 CALL echo("")
 CALL echo("")
 CALL echo(build("   Number of total affected events: ",eventtotalcount))
 CALL echo("")
 CALL echo(build("The processing output file name with all updated events is :",logfilename))
#exit_script
 IF (datetimecmp(cnvtdatetime( $BEGINDATE),cnvtdatetime("18-FEB-2011")) < 0)
  CALL echo("   You entered a date before 18-FEB-2011. Please pick a date on or after 18-FEB-2011")
 ENDIF
 IF (cnvtreal( $BATCHSIZE) < 1)
  CALL echo("   You entered a batch size less than 1.")
 ENDIF
END GO
