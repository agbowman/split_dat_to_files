CREATE PROGRAM dd_ident_docs_missing_addenda:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start date in DD-MMM-YYYY format (defaults to 26-SEP-2021):" = "26-SEP-2021",
  "End date in DD-MMM-YYYY format   (defaults to current date):" = "CURDATE",
  "Enter the number of DAYS to process per batch (defaults to 1):" = "1"
  WITH outdev, sdttmstart, sdttmend,
  sbatchsize
 DECLARE soutputfilename = vc WITH constant(build("cer_temp:dd_ident_docs_missing_addenda_log",format
   (curdate,"yymmdd;;d"),format(curtime,"hhmm;;m"),".csv"))
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
 IF (datetimecmp(dttmstart,cnvtdatetime("26-SEP-2021")) < 0)
  GO TO endscript
 ENDIF
 IF (bucketsize < 1)
  GO TO endscript
 ENDIF
 DECLARE identifybadnotes(null) = null WITH protect
 FREE RECORD addendadoc_event_ids
 RECORD addendadoc_event_ids(
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
   CALL queryaddendadocs(batchdttmstart,batchdttmend)
   CALL identifybadnotes(null)
   CALL outputreport(batchdttmstart,batchdttmend)
   SET batchdttmstart = batchdttmend
   SET batchdttmend = datetimeadd(batchdttmstart,bucketsize)
   SET stat = initrec(addendadoc_event_ids)
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
 SUBROUTINE (queryaddendadocs(batchdttmstart=f8,batchdttmend=f8) =null)
   DECLARE ieventidx = i4 WITH protect, noconstant(0)
   DECLARE ddyndocentrymodecd = f8 WITH constant(uar_get_code_by("MEANING",29520,"DYNDOC"))
   DECLARE ddoccd = f8 WITH constant(uar_get_code_by("MEANING",53,"DOC")), protect
   DECLARE dinerror1 = f8 WITH constant(uar_get_code_by("MEANING",8,"IN ERROR")), protect
   DECLARE dinerror2 = f8 WITH constant(uar_get_code_by("MEANING",8,"INERROR")), protect
   DECLARE dinerror3 = f8 WITH constant(uar_get_code_by("MEANING",8,"INERRNOVIEW")), protect
   DECLARE dinerror4 = f8 WITH constant(uar_get_code_by("MEANING",8,"INERRNOMUT")), protect
   SELECT INTO "nl:"
    FROM clinical_event ce
    PLAN (ce
     WHERE ce.updt_dt_tm >= cnvtdatetime(batchdttmstart)
      AND ce.updt_dt_tm < cnvtdatetime(batchdttmend)
      AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
      AND trim(ce.event_title_text) != null
      AND ce.entry_mode_cd=ddyndocentrymodecd
      AND ce.event_class_cd=ddoccd
      AND  NOT (ce.result_status_cd IN (dinerror1, dinerror2, dinerror3, dinerror4)))
    ORDER BY ce.event_id, ce.updt_dt_tm
    DETAIL
     ieventidx += 1
     IF (mod(ieventidx,500)=1)
      stat = alterlist(addendadoc_event_ids->list_ids,(ieventidx+ 499))
     ENDIF
     addendadoc_event_ids->list_ids[ieventidx].event_id = ce.event_id
    FOOT REPORT
     stat = alterlist(addendadoc_event_ids->list_ids,ieventidx)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE identifybadnotes(null)
   DECLARE doc_row_cnt = i4 WITH protect, constant(size(addendadoc_event_ids->list_ids,5))
   DECLARE ireportidx = i4 WITH protect, noconstant(0)
   DECLARE g_sblobxhtml = vc WITH public, noconstant("")
   DECLARE applicationid = i4 WITH constant(1000011)
   DECLARE taskid = i4 WITH constant(1000011)
   DECLARE requestid = i4 WITH constant(1000011)
   DECLARE happ = i4 WITH noconstant(0)
   DECLARE htask = i4 WITH noconstant(0)
   DECLARE hstep = i4 WITH noconstant(0)
   DECLARE hrblist = i4 WITH noconstant(0)
   DECLARE query_mode = i4 WITH constant(3)
   DECLARE iret = i2 WITH noconstant(0)
   DECLARE identifyselfclosingtitleelement(null) = i2
   FOR (icuridx = 1 TO doc_row_cnt)
     SET g_sblobrtf = ""
     SET iret = calleventserver(addendadoc_event_ids->list_ids[icuridx].event_id)
     IF (g_sblobxhtml != "")
      SET iaddtoreport = identifyselfclosingtitleelement(null)
     ENDIF
     IF (iaddtoreport != 0)
      SET ireportidx += 1
      IF (mod(ireportidx,500)=1)
       SET stat = alterlist(report_event_ids->list_ids,(ireportidx+ 499))
      ENDIF
      SET report_event_ids->list_ids[ireportidx].event_id = addendadoc_event_ids->list_ids[icuridx].
      event_id
     ENDIF
   ENDFOR
   IF (ireportidx != 0)
    SET stat = alterlist(report_event_ids->list_ids,ireportidx)
   ENDIF
   SUBROUTINE (calleventserver(deventid=f8) =i2)
     SET iret = uar_crmbeginapp(applicationid,happ)
     IF (iret != 0)
      CALL echo("uar_crm_begin_app failed in post_to_clinical_event")
      GO TO endscript
     ENDIF
     SET iret = uar_crmbegintask(happ,taskid,htask)
     IF (iret != 0)
      CALL echo("uar_crm_begin_task failed in post_to_clinical_event")
      GO TO endscript
     ENDIF
     SET iret = uar_crmbeginreq(htask,"",requestid,hstep)
     IF (iret != 0)
      CALL echo("uar_crm_begin_Request failed in post_to_clinical_event")
      GO TO endscript
     ENDIF
     SET hreq = uar_crmgetrequest(hstep)
     IF (hreq)
      SET srvstat = uar_srvsetulong(hreq,"query_mode",query_mode)
      SET srvstat = uar_srvsetdouble(hreq,"event_id",deventid)
      SET srvstat = uar_srvsetlong(hreq,"subtable_bit_map",0)
      SET srvstat = uar_srvsetshort(hreq,"subtable_bit_map_ind",1)
      SET srvstat = uar_srvsetshort(hreq,"valid_from_dt_tm_ind",1)
     ENDIF
     SET iret = uar_crmperform(hstep)
     SET hrep = uar_crmgetreply(hstep)
     IF (hrep=0)
      RETURN(false)
     ENDIF
     SET hrblist = uar_srvgetitem(hrep,"rb_list",0)
     IF (hrblist=0)
      RETURN(false)
     ENDIF
     CALL retrieveresults(hrblist)
     IF (hstep)
      CALL uar_crmendreq(hstep)
     ENDIF
     IF (htask)
      CALL uar_crmendtask(htask)
     ENDIF
     IF (happ)
      CALL uar_crmendapp(happ)
     ENDIF
     RETURN(true)
   END ;Subroutine
   SUBROUTINE (retrieveresults(hrbhandle=i4) =null)
     FREE RECORD blob
     RECORD blob(
       1 blob_length = i4
       1 blob_contents = gvc
       1 blob_version = i4
       1 status_data
         2 status = c1
         2 subeventstatus[1]
           3 operationname = c25
           3 operationstatus = c1
           3 targetobjectname = c25
           3 targetobjectvalue = vc
     )
     DECLARE blobresultidx = i4 WITH protect, noconstant(0)
     DECLARE blob_result_cnt = i4 WITH protect, noconstant(0)
     DECLARE blob_cnt = i4 WITH protect, noconstant(0)
     DECLARE hblobresulthandle = i4 WITH protect, noconstant(0)
     DECLARE hblobhandle = i4 WITH protect, noconstant(0)
     DECLARE blobidx = i4 WITH protect, noconstant(0)
     DECLARE blobresult = gvc WITH protect, noconstant("")
     DECLARE ierror = i2 WITH protect, noconstant(0)
     IF (hrbhandle=0)
      RETURN
     ENDIF
     SET blob_result_cnt = uar_srvgetitemcount(hrbhandle,nullterm("blob_result"))
     SET blob->blob_version = uar_srvgetlong(hrbhandle,nullterm("updt_cnt"),0)
     FOR (blobresultidx = 1 TO blob_result_cnt)
       SET hblobresulthandle = uar_srvgetitem(hrbhandle,nullterm("blob_result"),(blobresultidx - 1))
       SET blob_cnt = uar_srvgetitemcount(hblobresulthandle,nullterm("blob"))
       FOR (blobidx = 1 TO blob_cnt)
         SET hblobhandle = uar_srvgetitem(hblobresulthandle,nullterm("blob"),(blobidx - 1))
         SET blob->blob_length = uar_srvgetlong(hblobhandle,nullterm("blob_length"))
         SET blobresult = uar_srvgetasisptr(hblobhandle,nullterm("blob_contents"))
         SET blob->blob_contents = build2(blob->blob_contents,substring(0,blob->blob_length,
           blobresult))
       ENDFOR
     ENDFOR
     SET g_sblobxhtml = blob->blob_contents
   END ;Subroutine
   SUBROUTINE identifyselfclosingtitleelement(null)
     DECLARE ititlepos = i4 WITH protect, constant(findstring("<title/>",g_sblobxhtml))
     IF (ititlepos > 0)
      RETURN(1)
     ENDIF
     RETURN(0)
   END ;Subroutine
 END ;Subroutine
 SUBROUTINE (outputreport(batchdttmstart=f8,batchdttmend=f8) =null)
   DECLARE report_event_count = i4 WITH protect, constant(size(report_event_ids->list_ids,5))
   CALL echo(build("   REPORT_EVENT_COUNT: ",report_event_count))
   CALL echo(build("   identifiedEventTotalCount: ",identifiedeventtotalcount))
   IF (report_event_count > 0)
    DECLARE eventcount = i4 WITH noconstant(0)
    DECLARE recstr = vc WITH noconstant("")
    SELECT INTO value(soutputfilename)
     FROM (dummyt d  WITH seq = value(report_event_count)),
      clinical_event ce,
      clinical_event ce1,
      person p,
      prsnl author
     PLAN (d)
      JOIN (ce
      WHERE (ce.event_id=report_event_ids->list_ids[d.seq].event_id)
       AND ce.updt_dt_tm >= cnvtdatetime(batchdttmstart)
       AND ce.updt_dt_tm < cnvtdatetime(batchdttmend)
       AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100"))
      JOIN (ce1
      WHERE ce1.event_id=ce.parent_event_id
       AND ce1.valid_until_dt_tm=cnvtdatetime("31-DEC-2100"))
      JOIN (p
      WHERE p.person_id=ce.person_id)
      JOIN (author
      WHERE author.person_id=ce.performed_prsnl_id)
     HEAD REPORT
      eventcount = 0
      IF (identifiedeventtotalcount=0)
       '"Document Event Id","Addenda Event Id","Patient Name","Service Date and Time","Author Name"',
       ',"Author Id","Patient Id","Note Type","Note Status","Perform Date and Time","Note Title"',
       row + 1
      ENDIF
     DETAIL
      eventcount += 1, recstr = "", quote_str = "",
      comma_str = "",
      CALL subr_out(build(ce.parent_event_id)), comma_str = ",",
      CALL subr_out(build(ce.event_id)), quote_str = '"',
      CALL subr_out(build(p.name_full_formatted)),
      quote_str = "",
      CALL subr_out(build(format(ce.event_end_dt_tm,"@SHORTDATETIME"))), quote_str = '"',
      CALL subr_out(build(author.name_full_formatted)), quote_str = "",
      CALL subr_out(build(author.person_id)),
      CALL subr_out(build(p.person_id)),
      CALL subr_out(build(uar_get_code_display(ce.event_cd))),
      CALL subr_out(build(uar_get_code_display(ce1.result_status_cd))),
      CALL subr_out(build(format(ce.performed_dt_tm,"@SHORTDATETIME"))), quote_str = '"',
      CALL subr_out(trim(ce1.event_title_text))
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
#endscript
 IF (datetimecmp(dttmstart,cnvtdatetime("26-SEP-2021")) < 0)
  CALL echo("   You entered a date before 26-SEP-2021. Please pick a date on or after 26-SEP-2021")
 ENDIF
 IF (cnvtreal( $SBATCHSIZE) < 1)
  CALL echo("   You entered a batch size less than 1.")
 ENDIF
END GO
