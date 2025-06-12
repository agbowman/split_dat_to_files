CREATE PROGRAM dd_ident_unpubl_doc_after_dict:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start date in DD-MMM-YYYY format (defaults to 30-NOV-2020):" = "30-NOV-2020",
  "End date in DD-MMM-YYYY format (defaults to current date):" = curdate,
  "Enter the number of days to process per batch (defaults to 1):" = "1"
  WITH outdev, sdttmstart, sdttmend,
  sbatchsize
 SET modify maxvarlen 268435456
 DECLARE soutputfilename = vc WITH constant(build("cer_temp:dd_ident_unpubl_doc_after_dict",format(
    curdate,"yymmdd;;d"),format(curtime,"hhmm;;m"),".csv"))
 DECLARE dttmstart = dq8 WITH protect, noconstant(cnvtdatetime(cnvtdate2( $SDTTMSTART,"DD-MMM-YYYY"),
   0))
 DECLARE dttmend = dq8 WITH protect
 DECLARE bucketsize = f8 WITH constant(cnvtreal( $SBATCHSIZE))
 DECLARE identifiedeventtotalcount = i4 WITH noconstant(0)
 IF (( $SDTTMEND="CURDATE"))
  SET dttmend = cnvtdatetime(curdate,curtime)
 ELSE
  SET dttmend = cnvtdatetime(cnvtdate2( $SDTTMEND,"DD-MMM-YYYY"),235959)
 ENDIF
 IF (datetimecmp(dttmstart,cnvtdatetime("30-NOV-2020")) < 0)
  GO TO exit_script
 ENDIF
 IF (bucketsize < 1)
  GO TO exit_script
 ENDIF
 DECLARE outputreport(null) = null
 FREE RECORD report_event_ids
 RECORD report_event_ids(
   1 list_ids[*]
     2 clinical_event_id = f8
 )
 DECLARE totaldaterange = f8 WITH constant(datetimediff(dttmend,dttmstart))
 DECLARE numberofiteration = i4 WITH constant(ceil((cnvtreal(totaldaterange)/ cnvtreal(bucketsize))))
 CALL echo(build("   Number of Iterations: ",numberofiteration))
 DECLARE batchdttmstart = f8 WITH noconstant(dttmstart)
 DECLARE batchdttmend = f8 WITH noconstant(datetimeadd(batchdttmstart,bucketsize))
 DECLARE iteration = i4 WITH noconstant(1)
 FOR (iteration = 1 TO numberofiteration)
   IF (iteration=numberofiteration)
    SET batchdttmend = dttmend
   ENDIF
   CALL identifywrongunpubdocs(batchdttmstart,batchdttmend)
   CALL outputreport(null)
   SET batchdttmstart = batchdttmend
   SET batchdttmend = datetimeadd(batchdttmstart,bucketsize)
   SET stat = initrec(report_event_ids)
 ENDFOR
 IF (identifiedeventtotalcount=0)
  DECLARE sout = vc WITH protect
  SELECT INTO value(soutputfilename)
   FROM (dummyt d  WITH seq = 1)
   PLAN (d)
   HEAD REPORT
    sout = build("No notes identified between",format(dttmstart," DD-MMM-YYYY HH:MM:SS ;3;Q")," and",
     format(dttmend," DD-MMM-YYYY HH:MM:SS;3;Q")),
    CALL echo(""),
    CALL echo(sout),
    row 0, col 0, sout
   WITH nocounter
  ;end select
 ENDIF
 CALL echo("")
 CALL echo(build("   Total number of potentially affected events: ",identifiedeventtotalcount))
 CALL echo(build("   Output file name for identified documents with location: ",soutputfilename))
 CALL echo("")
 DECLARE stemp = vc WITH protect
 DECLARE sidentifiedeventtotalcount = vc WITH protect
 SELECT INTO  $OUTDEV
  FROM (dummyt d  WITH seq = 1)
  PLAN (d)
  HEAD REPORT
   sidentifiedeventtotalcount = build("Total number of potentially affected events: ",
    identifiedeventtotalcount), stemp = build(
    "Output file name for identified documents with location: ",soutputfilename), row 0,
   col 0, stemp, row 1,
   col 0, sidentifiedeventtotalcount
  WITH nocounter
 ;end select
 SUBROUTINE (identifywrongunpubdocs(batchdttmstart=f8,batchdttmend=f8) =null WITH protect)
   DECLARE dtxtcd = f8 WITH constant(uar_get_code_by("MEANING",53,"TXT")), protect
   DECLARE dwfcentrymodecd = f8 WITH constant(uar_get_code_by("MEANING",29520,"WKFDOCCOMP")), protect
   DECLARE ddoccd = f8 WITH constant(uar_get_code_by("MEANING",53,"DOC")), protect
   DECLARE dddentrymodecd = f8 WITH constant(uar_get_code_by("MEANING",29520,"DYNDOC")), protect
   DECLARE dinerror1 = f8 WITH constant(uar_get_code_by("MEANING",8,"IN ERROR")), protect
   DECLARE dinerror2 = f8 WITH constant(uar_get_code_by("MEANING",8,"INERROR")), protect
   DECLARE dinerror3 = f8 WITH constant(uar_get_code_by("MEANING",8,"INERRNOVIEW")), protect
   DECLARE dinerror4 = f8 WITH constant(uar_get_code_by("MEANING",8,"INERRNOMUT")), protect
   DECLARE icnt = i4 WITH noconstant(0), protect
   CALL echo(concat("Begin date: ",format(batchdttmstart,"DD-MMM-YYYY HH:MM:SS;;D")))
   CALL echo(concat("End date: ",format(batchdttmend,"DD-MMM-YYYY HH:MM:SS;;D")))
   CALL echo("Processing the clinical_event table...Please Wait")
   SELECT INTO "nl:"
    FROM clinical_event ce,
     clinical_event ce1
    PLAN (ce
     WHERE ce.updt_dt_tm >= cnvtdatetime(batchdttmstart)
      AND ce.updt_dt_tm < cnvtdatetime(batchdttmend)
      AND ce.event_class_cd IN (ddoccd, dtxtcd)
      AND ce.entry_mode_cd IN (dwfcentrymodecd, dddentrymodecd)
      AND  NOT (ce.result_status_cd IN (dinerror1, dinerror2, dinerror3, dinerror4))
      AND ce.parent_event_id != ce.event_id
      AND ce.publish_flag=0
      AND ce.updt_task=1000012)
     JOIN (ce1
     WHERE ce1.event_id=ce.event_id
      AND ce1.parent_event_id != ce1.event_id
      AND ce1.publish_flag=1
      AND ce1.valid_until_dt_tm <= ce.valid_from_dt_tm
      AND ce1.updt_task != 1000012)
    DETAIL
     icnt += 1
     IF (mod(icnt,500)=1)
      stat = alterlist(report_event_ids->list_ids,(icnt+ 499))
     ENDIF
     report_event_ids->list_ids[icnt].clinical_event_id = ce.clinical_event_id
    WITH nocounter
   ;end select
   IF (icnt != 0)
    SET stat = alterlist(report_event_ids->list_ids,icnt)
   ENDIF
   CALL echorecord(report_event_ids)
 END ;Subroutine
 SUBROUTINE outputreport(null)
   DECLARE report_event_count = i4 WITH protect, constant(size(report_event_ids->list_ids,5))
   CALL echo(build("   REPORT_EVENT_COUNT: ",report_event_count))
   CALL echo(build("   identifiedEventTotalCount: ",identifiedeventtotalcount))
   IF (report_event_count > 0)
    DECLARE eventcount = i4 WITH noconstant(0)
    DECLARE recstr = vc WITH noconstant("")
    SELECT INTO value(soutputfilename)
     FROM (dummyt d  WITH seq = value(report_event_count)),
      clinical_event ce
     PLAN (d)
      JOIN (ce
      WHERE (ce.clinical_event_id=report_event_ids->list_ids[d.seq].clinical_event_id))
     HEAD REPORT
      eventcount = 0
      IF (identifiedeventtotalcount=0)
       '"clinical_event_id","event_id","publish_flag","person_id","event_end_dt_tm","performed_prsnl_id"',
       ',"verified_prsnl_id","event_cd","event_tag","event_title_text"', row + 1
      ENDIF
     DETAIL
      eventcount += 1, recstr = "", quote_str = "",
      comma_str = "",
      CALL subr_out(build(ce.clinical_event_id)), comma_str = ",",
      CALL subr_out(build(ce.event_id)),
      CALL subr_out(build(ce.publish_flag)),
      CALL subr_out(build(ce.person_id)),
      CALL subr_out(build(format(ce.event_end_dt_tm,"MM/DD/YY;;D"))),
      CALL subr_out(build(ce.performed_prsnl_id)),
      CALL subr_out(build(ce.verified_prsnl_id)),
      CALL subr_out(build(ce.event_cd)), quote_str = '"',
      CALL subr_out(trim(ce.event_tag)),
      CALL subr_out(trim(ce.event_title_text))
      IF (eventcount != 1)
       row + 1
      ENDIF
      col 1, recstr,
      SUBROUTINE subr_out(p_data)
        recstr = concat(trim(recstr),trim(comma_str),trim(quote_str),build(p_data),trim(quote_str))
      END ;Subroutine report
     FOOT REPORT
      identifiedeventtotalcount += eventcount
     WITH nocounter, check, format = variable,
      noformfeed, maxcol = 700, maxrow = 1,
      append
    ;end select
   ENDIF
 END ;Subroutine
#exit_script
 IF (datetimecmp(dttmstart,cnvtdatetime("30-NOV-2020")) < 0)
  CALL echo("   You entered a date before 30-NOV-2020. Please pick a date on or after 30-NOV-2020")
 ENDIF
 IF (cnvtreal( $SBATCHSIZE) < 1)
  CALL echo("   You entered a batch size less than 1.")
 ENDIF
END GO
