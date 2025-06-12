CREATE PROGRAM doc_ident_wrong_unpubl_docs
 PROMPT
  "Enter begin date (The default is 27-JAN-2005 00:00) after 01-JAN-2005 00:00:" =
  "27-JAN-2005 00:00",
  "Enter batch size in days (The default is 1. You can enter decimals for batch size less than a day):"
   = "1"
  WITH begindate, batchsize
 IF (datetimecmp(cnvtdatetime( $BEGINDATE),cnvtdatetime("01-JAN-2005 00:00")) <= 0)
  GO TO exit_script
 ENDIF
 IF (cnvtreal( $BATCHSIZE) <= 0)
  GO TO exit_script
 ENDIF
 DECLARE mdoc_cd = f8 WITH constant(uar_get_code_by("MEANING",53,"MDOC")), protect
 DECLARE doc_cd = f8 WITH constant(uar_get_code_by("MEANING",53,"DOC")), protect
 DECLARE auth_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH")), protect
 DECLARE modified_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"MODIFIED")), protect
 DECLARE altered_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"ALTERED")), protect
 DECLARE active_cd = f8 WITH constant(uar_get_code_by("MEANING",48,"ACTIVE")), protect
 DECLARE root_cd = f8 WITH constant(uar_get_code_by("MEANING",24,"ROOT")), protect
 DECLARE logfilename = vc WITH constant(build("cer_temp:ident_wrong_unpubl_docs_",format(curdate,
    "yymmdd;;d"),format(curtime,"hhmm;;m"),".csv"))
 DECLARE begindatetime = f8 WITH constant(cnvtdatetime( $BEGINDATE))
 DECLARE currentdatetime = f8 WITH constant(cnvtdatetime(curdate,curtime))
 DECLARE totaldaterange = f8 WITH constant(datetimediff(currentdatetime,begindatetime))
 DECLARE bucketsize = f8 WITH constant(cnvtreal( $BATCHSIZE))
 DECLARE eventtotalcount = i4 WITH noconstant(0)
 SELECT INTO value(logfilename)
  DETAIL
   '"clinical_event_id","event_id","person_id","event_end_dt_tm","performed_prsnl_id"',
   ',"verified_prsnl_id","event_cd","event_tag","event_title_text"'
  WITH nocounter, format = variable, noformfeed,
   maxcol = 700, maxrow = 1, append
 ;end select
 CALL echo(build("Output file name is: ",logfilename))
 CALL identifywrongunpubdocs(mdoc_cd)
 CALL identifywrongunpubdocs(doc_cd)
 SUBROUTINE identifywrongunpubdocs(deventclasscd)
   DECLARE titletext = vc WITH noconstant("")
   DECLARE iteration = i4 WITH noconstant(1)
   DECLARE eventcount = i4 WITH noconstant(0)
   DECLARE recstr = vc WITH noconstant("")
   DECLARE numberofiteration = i4 WITH constant(ceil((cnvtreal(totaldaterange)/ cnvtreal(bucketsize))
     ))
   CALL echo(build("   Number of Iterations: ",numberofiteration))
   DECLARE batchbegindttm = f8 WITH noconstant(begindatetime)
   DECLARE batchenddttm = f8 WITH noconstant(datetimeadd(batchbegindttm,bucketsize))
   FOR (iteration = 1 TO numberofiteration)
     IF (iteration=numberofiteration)
      SET batchenddttm = currentdatetime
     ENDIF
     CALL echo(concat("Begin date: ",format(batchbegindttm,"DD-MMM-YYYY HH:MM:SS;;D")))
     CALL echo(concat("End date: ",format(batchenddttm,"DD-MMM-YYYY HH:MM:SS;;D")))
     CALL echo("Processing the clinical_event table...Please Wait")
     SELECT
      IF (deventclasscd=doc_cd)
       FROM clinical_event ce
       WHERE ce.updt_dt_tm >= cnvtdatetime(batchbegindttm)
        AND ce.updt_dt_tm < cnvtdatetime(batchenddttm)
        AND ce.event_class_cd=doc_cd
        AND ce.parent_event_id=ce.event_id
        AND ce.publish_flag=0
        AND ce.verified_dt_tm != null
        AND ce.result_status_cd IN (auth_cd, modified_cd, altered_cd)
        AND ce.record_status_cd=active_cd
        AND ce.event_reltn_cd=root_cd
      ELSEIF (deventclasscd=mdoc_cd)
       FROM clinical_event ce
       WHERE ce.updt_dt_tm >= cnvtdatetime(batchbegindttm)
        AND ce.updt_dt_tm < cnvtdatetime(batchenddttm)
        AND ce.event_class_cd=mdoc_cd
        AND ce.publish_flag=0
        AND ce.verified_dt_tm != null
        AND ce.result_status_cd IN (auth_cd, modified_cd, altered_cd)
        AND ce.record_status_cd=active_cd
        AND ce.event_reltn_cd=root_cd
      ELSE
      ENDIF
      INTO value(logfilename)
      ce.clinical_event_id, ce.event_id, ce.person_id,
      ce.event_tag, ce.event_title_text, ce.event_end_dt_tm,
      ce.performed_prsnl_id, ce.verified_prsnl_id, ce.event_cd
      HEAD REPORT
       eventcount = 0
      DETAIL
       eventcount = (eventcount+ 1), recstr = "", quote_str = "",
       comma_str = "",
       CALL subr_out(build(ce.clinical_event_id)), comma_str = ",",
       CALL subr_out(build(ce.event_id)),
       CALL subr_out(build(ce.person_id)),
       CALL subr_out(build(format(ce.event_end_dt_tm,"MM/DD/YY;;D"))),
       CALL subr_out(build(ce.performed_prsnl_id)),
       CALL subr_out(build(ce.verified_prsnl_id)),
       CALL subr_out(build(ce.event_cd)),
       quote_str = '"',
       CALL subr_out(trim(ce.event_tag)),
       CALL subr_out(trim(ce.event_title_text))
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
      FOOT REPORT
       eventtotalcount = (eventtotalcount+ eventcount),
       CALL echo(build("   Number of affected events: ",eventcount))
      WITH nocounter, check, format = variable,
       noformfeed, maxcol = 700, maxrow = 1,
       append
     ;end select
     SET batchbegindttm = batchenddttm
     SET batchenddttm = datetimeadd(batchbegindttm,bucketsize)
   ENDFOR
   CALL echo("")
   CALL echo("")
   CALL echo(build("Number of total affected events: ",eventtotalcount))
   CALL echo(build("The Output file name is: ",logfilename))
   CALL echo("")
   DECLARE notificationtext = vc WITH protect
   SET notificationtext = "Note:- We identified these rows and placed them in the output file name."
   SET notificationtext = concat(notificationtext," You should look into these identified rows and")
   SET notificationtext = concat(notificationtext,
    " remove those rows that should not be updated from the file.")
   CALL echo(notificationtext)
   CALL echo("")
   CALL echo("")
 END ;Subroutine
#exit_script
 IF (datetimecmp(cnvtdatetime( $BEGINDATE),cnvtdatetime("01-JAN-2005 00:00")) <= 0)
  CALL echo(
   "You entered a date before 01-JAN-2005 00:00. Rerun the script and enter a date after 01-JAN-2005 00:00."
   )
 ENDIF
 IF (cnvtreal( $BATCHSIZE) <= 0)
  CALL echo(
   "You entered a batch size less than 0. Rerun the script and enter a batch size greater than 0.")
 ENDIF
END GO
