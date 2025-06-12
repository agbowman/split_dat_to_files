CREATE PROGRAM dd_ident_blank_docs:dba
 PROMPT
  "Start date in DD-MMM-YYYY format (defaults to 01-SEP-2016):						  " = "01-SEP-2016",
  "End date in DD-MMM-YYYY format (defaults to current date):						 " = "CURDATE",
  "Enter the number of days to process per batch (defaults to 1):					   " = "1"
  WITH sdttmstart, sdttmend, sbatchsize
 SET modify maxvarlen 268435456
 DECLARE soutputfilename = vc WITH constant(build("cer_temp:dd_empty_documents",format(curdate,
    "yymmdd;;d"),format(curtime,"hhmm;;m"),".csv"))
 DECLARE dttmstart = dq8 WITH protect, noconstant(cnvtdatetime(cnvtdate2( $SDTTMSTART,"DD-MMM-YYYY"),
   0))
 DECLARE dttmstartconst = dq8 WITH constant(dttmstart)
 DECLARE dttmend = dq8 WITH protect, noconstant(0)
 DECLARE bucketsize = f8 WITH constant(cnvtreal( $SBATCHSIZE))
 DECLARE identifiedeventtotalcount = i4 WITH noconstant(0)
 IF (( $SDTTMEND="CURDATE"))
  SET dttmend = cnvtdatetime(curdate,curtime)
 ELSE
  SET dttmend = cnvtdatetime(cnvtdate2( $SDTTMEND,"DD-MMM-YYYY"),235959)
 ENDIF
 IF (datetimecmp(dttmstart,cnvtdatetime("01-AUG-2016")) < 0)
  GO TO endscript
 ENDIF
 IF (bucketsize < 1)
  GO TO endscript
 ENDIF
 DECLARE querydocrows(batchdttmstart,batchdttmend) = null
 DECLARE identifybadnotes(null) = null
 DECLARE outputreport(batchdttmstart,batchdttmend) = null
 FREE RECORD dd_doc_event_ids
 RECORD dd_doc_event_ids(
   1 list_ids[*]
     2 event_id = f8
 )
 FREE RECORD report_event_ids
 RECORD report_event_ids(
   1 list_ids[*]
     2 event_id = f8
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
   CALL querydocrows(batchdttmstart,batchdttmend)
   CALL identifybadnotes(null)
   CALL outputreport(batchdttmstart,batchdttmend)
   SET batchdttmstart = batchdttmend
   SET batchdttmend = datetimeadd(batchdttmstart,bucketsize)
   SET stat = initrec(dd_doc_event_ids)
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
 SUBROUTINE querydocrows(batchdttmstart,batchdttmend)
   DECLARE ddoccd = f8 WITH constant(uar_get_code_by("MEANING",53,"DOC")), protect
   DECLARE dddentrymodecd = f8 WITH constant(uar_get_code_by("MEANING",29520,"DYNDOC")), protect
   DECLARE icnt = i4 WITH noconstant(0), protect
   DECLARE dinerror1 = f8 WITH constant(uar_get_code_by("MEANING",8,"IN ERROR")), protect
   DECLARE dinerror2 = f8 WITH constant(uar_get_code_by("MEANING",8,"INERROR")), protect
   DECLARE dinerror3 = f8 WITH constant(uar_get_code_by("MEANING",8,"INERRNOVIEW")), protect
   DECLARE dinerror4 = f8 WITH constant(uar_get_code_by("MEANING",8,"INERRNOMUT")), protect
   SELECT INTO "nl:"
    FROM clinical_event ce
    WHERE ce.updt_dt_tm >= cnvtdatetime(batchdttmstart)
     AND ce.updt_dt_tm < cnvtdatetime(batchdttmend)
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
     AND ce.event_class_cd=ddoccd
     AND ce.entry_mode_cd=dddentrymodecd
     AND  NOT (ce.result_status_cd IN (dinerror1, dinerror2, dinerror3, dinerror4))
    ORDER BY ce.parent_event_id, cnvtreal(ce.collating_seq)
    HEAD ce.parent_event_id
     icnt = (icnt+ 1)
     IF (mod(icnt,500)=1)
      stat = alterlist(dd_doc_event_ids->list_ids,(icnt+ 499))
     ENDIF
     dd_doc_event_ids->list_ids[icnt].event_id = ce.event_id
    WITH nocounter
   ;end select
   IF (icnt != 0)
    SET stat = alterlist(dd_doc_event_ids->list_ids,icnt)
   ENDIF
 END ;Subroutine
 SUBROUTINE identifybadnotes(null)
   DECLARE docfcompresscd = f8 WITH protect, noconstant(0.0)
   DECLARE docfnocompresscd = f8 WITH protect, noconstant(0.0)
   DECLARE iaddtoreport = i2 WITH protect, noconstant(0)
   DECLARE ierror = i2 WITH protect, noconstant(0)
   DECLARE ireportidx = i4 WITH protect, noconstant(0)
   DECLARE ibloblength = i4 WITH protect, noconstant(0)
   DECLARE isearchres = i4 WITH protect, noconstant(0)
   DECLARE doc_row_cnt = i4 WITH protect, constant(size(dd_doc_event_ids->list_ids,5))
   DECLARE sblobcompressed = vc WITH protect, noconstant("")
   DECLARE icuridx = i4 WITH protect, noconstant(0)
   DECLARE identifyemptybodyelement(null) = i2
   DECLARE g_sblobxhtml = vc WITH public, noconstant("")
   SET stat = uar_get_meaning_by_codeset(120,"OCFCOMP",1,docfcompresscd)
   SET stat = uar_get_meaning_by_codeset(120,"NOCOMP",1,docfnocompresscd)
   FOR (icuridx = 1 TO doc_row_cnt)
     SET iaddtoreport = 0
     SET ierror = 0
     SET sblobcompressed = " "
     SET g_sblobxhtml = ""
     SELECT INTO "nl:"
      FROM ce_blob c
      PLAN (c
       WHERE (c.event_id=dd_doc_event_ids->list_ids[icuridx].event_id)
        AND c.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
        AND c.blob_length < 360)
      ORDER BY c.event_id, c.blob_seq_num
      HEAD c.event_id
       stat = memrealloc(g_sblobxhtml,1,build("C",c.blob_length))
      DETAIL
       isearchres = (findstring("ocf_blob",c.blob_contents,(size(trim(c.blob_contents)) - 10)) - 1)
       IF (isearchres < 1)
        isearchres = size(c.blob_contents)
       ENDIF
       sblobcompressed = notrim(concat(notrim(sblobcompressed),notrim(substring(1,isearchres,c
           .blob_contents))))
      FOOT  c.event_id
       sblobcompressed = concat(notrim(sblobcompressed),"ocf_blob")
       IF (c.compression_cd=docfcompresscd)
        stat = uar_ocf_uncompress(sblobcompressed,size(sblobcompressed),g_sblobxhtml,size(
          g_sblobxhtml),ibloblength)
       ELSEIF (c.compression_cd=docfnocompresscd)
        g_sblobxhtml = sblobcompressed
       ELSE
        ierror = 1
       ENDIF
      WITH nocounter
     ;end select
     IF (ierror=1)
      CALL echo("Unhandled compression code")
     ELSEIF (g_sblobxhtml != "")
      SET iaddtoreport = identifyemptybodyelement(null)
     ENDIF
     IF (iaddtoreport != 0)
      SET ireportidx = (ireportidx+ 1)
      IF (mod(ireportidx,500)=1)
       SET stat = alterlist(report_event_ids->list_ids,(ireportidx+ 499))
      ENDIF
      SET report_event_ids->list_ids[ireportidx].event_id = dd_doc_event_ids->list_ids[icuridx].
      event_id
     ENDIF
   ENDFOR
   IF (ireportidx != 0)
    SET stat = alterlist(report_event_ids->list_ids,ireportidx)
   ENDIF
   SUBROUTINE identifyemptybodyelement(null)
     DECLARE iopenbodypos = i4 WITH protect, constant(findstring("<body>",g_sblobxhtml))
     DECLARE iclosebodypos = i4 WITH protect, constant(findstring("</body>",g_sblobxhtml,(
       iopenbodypos+ 6)))
     IF (((iclosebodypos - iopenbodypos) < 9))
      RETURN(1)
     ENDIF
     RETURN(0)
   END ;Subroutine
 END ;Subroutine
 SUBROUTINE outputreport(batchdttmstart,batchdttmend)
   DECLARE report_event_count = i4 WITH protect, constant(size(report_event_ids->list_ids,5))
   CALL echo(build("   REPORT_EVENT_COUNT: ",report_event_count))
   CALL echo(build("   identifiedEventTotalCount: ",identifiedeventtotalcount))
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
      WHERE (ce.event_id=report_event_ids->list_ids[d.seq].event_id)
       AND ce.updt_dt_tm >= cnvtdatetime(batchdttmstart)
       AND ce.updt_dt_tm < cnvtdatetime(batchdttmend)
       AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100"))
      JOIN (p
      WHERE p.person_id=ce.person_id)
      JOIN (author
      WHERE author.person_id=ce.performed_prsnl_id)
     HEAD REPORT
      eventcount = 0
      IF (identifiedeventtotalcount=0)
       '"Event Id","Patient Name","Service Date and Time","Author Name","Author Id","Patient Id","Note Type"',
       ',"Note Status","Perform Date and Time","Note Title"', row + 1
      ENDIF
     DETAIL
      eventcount = (eventcount+ 1), recstr = "", quote_str = "",
      comma_str = "",
      CALL subr_out(build(ce.parent_event_id)), comma_str = ",",
      quote_str = '"',
      CALL subr_out(build(p.name_full_formatted)), quote_str = "",
      CALL subr_out(build(format(ce.event_end_dt_tm,"@SHORTDATETIME"))), quote_str = '"',
      CALL subr_out(build(author.name_full_formatted)),
      quote_str = "",
      CALL subr_out(build(author.person_id)),
      CALL subr_out(build(p.person_id)),
      CALL subr_out(build(uar_get_code_display(ce.event_cd))),
      CALL subr_out(build(uar_get_code_display(ce.result_status_cd))),
      CALL subr_out(build(format(ce.performed_dt_tm,"@SHORTDATETIME"))),
      quote_str = '"',
      CALL subr_out(trim(ce.event_title_text))
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
 IF (datetimecmp(dttmstart,cnvtdatetime("01-JAN-2011")) < 0)
  CALL echo("   You entered a date before 01-JAN-2011. Please pick a date on or after 01-JAN-2011")
 ENDIF
 IF (cnvtreal( $SBATCHSIZE) < 1)
  CALL echo("   You entered a batch size less than 1.")
 ENDIF
END GO
