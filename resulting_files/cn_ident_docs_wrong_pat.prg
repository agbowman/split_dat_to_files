CREATE PROGRAM cn_ident_docs_wrong_pat
 PROMPT
  "Start date in DD-MMM-YYYY format:                           						" = "01-JUN-2015",
  "End date in DD-MMM-YYYY format   (defaults to current date):						" = "CURDATE",
  "Enter the number of DAYS/HOURS to process per batch (.5 = 12 hrs, 1 = 1 day): 		" = "1"
  WITH sdttmstart, sdttmend, sbatchsize,
  sbatchtype
 DECLARE soutputfilename = vc WITH constant(build("cer_temp:cn_docs_with_wrong_pat_log",format(
    curdate,"yymmdd;;d"),format(curtime,"hhmm;;m"),".csv"))
 DECLARE dttmstart = dq8 WITH protect, noconstant(cnvtdatetime(cnvtdate2( $SDTTMSTART,"DD-MMM-YYYY"),
   0))
 DECLARE dttmstartconst = dq8 WITH constant(dttmstart)
 DECLARE dttmend = dq8 WITH protect, noconstant(cnvtdatetime(cnvtdate2( $SDTTMSTART,"DD-MMM-YYYY"),0)
  )
 DECLARE bucketsize = f8 WITH constant(cnvtreal( $SBATCHSIZE))
 DECLARE identifiedeventtotalcount = i4 WITH noconstant(0)
 IF (( $SDTTMEND="CURDATE"))
  SET dttmend = cnvtdatetime(curdate,curtime)
 ELSE
  SET dttmend = cnvtdatetime(cnvtdate2( $SDTTMEND,"DD-MMM-YYYY"),235959)
 ENDIF
 DECLARE queryanticipateddocs(batchdttmstart,batchdttmend) = null
 DECLARE outputreport(batchdttmstart,batchdttmend) = null
 FREE RECORD anticipateddoc_event_ids
 RECORD anticipateddoc_event_ids(
   1 list_ids[*]
     2 event_id = f8
     2 encntr_id = f8
 )
 DECLARE totaldaterange = f8 WITH constant(datetimediff(dttmend,dttmstart))
 DECLARE numberofiteration = i4 WITH constant(ceil((cnvtreal(totaldaterange)/ cnvtreal(bucketsize))))
 DECLARE batchdttmstart = f8 WITH noconstant(dttmstart)
 DECLARE batchdttmend = f8 WITH noconstant(datetimeadd(batchdttmstart,bucketsize))
 DECLARE iteration = i4 WITH noconstant(1)
 FOR (iteration = 1 TO numberofiteration)
   IF (iteration=numberofiteration)
    SET batchdttmend = dttmend
   ENDIF
   CALL queryanticipateddocs(batchdttmstart,batchdttmend)
   CALL outputreport(batchdttmstart,batchdttmend)
   SET batchdttmstart = batchdttmend
   SET batchdttmend = datetimeadd(batchdttmstart,bucketsize)
   SET stat = initrec(anticipateddoc_event_ids)
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
 SUBROUTINE queryanticipateddocs(batchdttmstart,batchdttmend)
   DECLARE danticipatedcd = f8 WITH constant(uar_get_code_by("MEANING",8,"ANTICIPATED"))
   DECLARE ieventidx = i4 WITH protect, noconstant(0)
   DECLARE ddoceventid = f8 WITH noconstant(0.0)
   DECLARE ddocencntrid = f8 WITH noconstant(0.0)
   DECLARE dundefentrymodecd = f8 WITH constant(uar_get_code_by("MEANING",29520,"UNDEFINED"))
   DECLARE ddoccd = f8 WITH constant(uar_get_code_by("MEANING",53,"DOC")), protect
   SELECT INTO "nl:"
    FROM clinical_event ce,
     clinical_event ce1
    PLAN (ce
     WHERE ce.updt_dt_tm >= cnvtdatetime(batchdttmstart)
      AND ce.updt_dt_tm < cnvtdatetime(batchdttmend)
      AND ce.result_status_cd=danticipatedcd
      AND ce.valid_until_dt_tm < cnvtdatetime("31-DEC-2100"))
     JOIN (ce1
     WHERE ce1.parent_event_id=ce.event_id
      AND ce1.entry_mode_cd=dundefentrymodecd
      AND ce1.event_class_cd=ddoccd
      AND ce1.encntr_id != ce.encntr_id)
    ORDER BY ce1.parent_event_id, ce1.updt_dt_tm
    HEAD ce1.parent_event_id
     ddoceventid = ce1.parent_event_id, ddocencntrid = ce1.encntr_id, ieventidx = (ieventidx+ 1)
     IF (mod(ieventidx,500)=1)
      stat = alterlist(anticipateddoc_event_ids->list_ids,(ieventidx+ 499))
     ENDIF
     anticipateddoc_event_ids->list_ids[ieventidx].event_id = ddoceventid, anticipateddoc_event_ids->
     list_ids[ieventidx].encntr_id = ddocencntrid
    WITH nocounter, orahintcbo("index(ce XIE12CLINICAL_EVENT)")
   ;end select
   IF (ieventidx != 0)
    IF (ddoceventid != 0.0)
     SET stat = alterlist(anticipateddoc_event_ids->list_ids,ieventidx)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE outputreport(batchdttmstart,batchdttmend)
   DECLARE report_event_count = i4 WITH protect, constant(size(anticipateddoc_event_ids->list_ids,5))
   CALL echo(build("   REPORT_EVENT_COUNT: ",report_event_count))
   DECLARE ddoccd = f8 WITH constant(uar_get_code_by("MEANING",53,"DOC")), protect
   IF (report_event_count > 0)
    DECLARE eventcount = i4 WITH noconstant(0)
    DECLARE recstr = vc WITH noconstant("")
    SELECT INTO value(soutputfilename)
     FROM (dummyt d  WITH seq = value(report_event_count)),
      clinical_event ce,
      person p,
      prsnl author
     PLAN (d)
      JOIN (ce
      WHERE (ce.parent_event_id=anticipateddoc_event_ids->list_ids[d.seq].event_id)
       AND ce.updt_dt_tm >= cnvtdatetime(batchdttmstart)
       AND ce.updt_dt_tm < cnvtdatetime(dttmend)
       AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
       AND ce.event_class_cd=ddoccd)
      JOIN (p
      WHERE p.person_id=ce.person_id)
      JOIN (author
      WHERE author.person_id=ce.performed_prsnl_id)
     ORDER BY ce.parent_event_id
     HEAD REPORT
      eventcount = 0
      IF (identifiedeventtotalcount=0)
       '"Event Id","Encounter Id","Patient Name","Service Date and Time","Author Name","Author Id","Patient Id"',
       ',"Note Type","Note Status","Perform Date and Time"', row + 1
      ENDIF
     DETAIL
      eventcount = (eventcount+ 1), recstr = "", quote_str = "",
      comma_str = "",
      CALL subr_out(build(ce.parent_event_id)), comma_str = ",",
      CALL subr_out(build(ce.encntr_id)), comma_str = ",", quote_str = '"',
      CALL subr_out(build(p.name_full_formatted)), quote_str = "",
      CALL subr_out(build(format(ce.event_end_dt_tm,"@SHORTDATETIME"))),
      quote_str = '"',
      CALL subr_out(build(author.name_full_formatted)), quote_str = "",
      CALL subr_out(build(author.person_id)),
      CALL subr_out(build(p.person_id)),
      CALL subr_out(build(uar_get_code_display(ce.event_cd))),
      CALL subr_out(build(uar_get_code_display(ce.result_status_cd))),
      CALL subr_out(format(ce.performed_dt_tm,"@SHORTDATETIME"))
      IF (eventcount != 1)
       row + 1
      ENDIF
      col 1, recstr,
      SUBROUTINE subr_out(p_data)
        recstr = concat(trim(recstr),trim(comma_str),trim(quote_str),build(p_data),trim(quote_str))
      END ;Subroutine report
     FOOT REPORT
      identifiedeventtotalcount = (identifiedeventtotalcount+ eventcount)
     WITH nocounter, check, format = variable,
      noformfeed, maxcol = 700, maxrow = 1,
      append
    ;end select
   ENDIF
 END ;Subroutine
#endscript
END GO
