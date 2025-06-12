CREATE PROGRAM dd_ident_doc_with_dictat_field:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start date in DD-MMM-YYYY format (defaults to 01-JAN-2020):" = "01-JAN-2020",
  "End date in DD-MMM-YYYY format (defaults to current date):" = "CURDATE",
  "Enter the number of days to process per batch (defaults to 1):" = "1"
  WITH outdev, sdttmstart, sdttmend,
  sbatchsize
 IF ( NOT (validate(cmn_string_utils_imported)))
  EXECUTE cmn_string_utils
 ENDIF
 IF ( NOT (validate(stb_rtf_util_imported)))
  EXECUTE stb_rtf_util
 ENDIF
 DECLARE identifyinvalidhtml(null) = i2
 SUBROUTINE identifyinvalidhtml(null)
   DECLARE matchhtmltagpos = i4 WITH protect, noconstant(0)
   SET matchhtmltagpos = findstring("</html>",g_sblobxhtml,1,0)
   IF (matchhtmltagpos > 0)
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE mrn_var = f8 WITH constant(uar_get_code_by("MEANING",319,"MRN")), protect
 DECLARE finnbr_var = f8 WITH constant(uar_get_code_by("MEANING",319,"FIN NBR")), protect
 SET modify maxvarlen 268435456
 DECLARE soutputfilename = vc WITH constant(build("cer_temp:dd_documents_with_dictation_field",format
   (curdate,"yymmdd;;d"),format(curtime,"hhmm;;m"),".csv"))
 DECLARE dttmstart = dq8 WITH protect, noconstant(cnvtdatetime(cnvtdate2( $SDTTMSTART,"DD-MMM-YYYY"),
   0))
 DECLARE dttmstartconst = dq8 WITH constant(dttmstart)
 DECLARE dttmend = dq8 WITH protect
 DECLARE bucketsize = f8 WITH constant(cnvtreal( $SBATCHSIZE))
 DECLARE identifiedeventtotalcount = i4 WITH noconstant(0)
 IF (( $SDTTMEND="CURDATE"))
  SET dttmend = cnvtdatetime(curdate,curtime)
 ELSE
  SET dttmend = cnvtdatetime(cnvtdate2( $SDTTMEND,"DD-MMM-YYYY"),235959)
 ENDIF
 IF (datetimecmp(dttmstart,cnvtdatetime("01-JAN-2010")) < 0)
  GO TO exit_script
 ENDIF
 IF (bucketsize < 1)
  GO TO exit_script
 ENDIF
 DECLARE querydocrows(batchdttmstart,batchdttmend) = null WITH protect
 DECLARE identifybadnotes(null) = null WITH protect
 DECLARE outputreport(null) = null
 DECLARE identifynuancefieldsstring(null) = i2
 FREE RECORD dd_doc_event_ids
 RECORD dd_doc_event_ids(
   1 list_ids[*]
     2 event_id = f8
 )
 FREE RECORD report_event_ids
 RECORD report_event_ids(
   1 list_ids[*]
     2 event_id = f8
     2 ivalidhtmlind = i2
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
   CALL outputreport(null)
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
 SUBROUTINE querydocrows(batchdttmstart,batchdttmend)
   DECLARE dtxtcd = f8 WITH constant(uar_get_code_by("MEANING",53,"TXT")), protect
   DECLARE dwfcentrymodecd = f8 WITH constant(uar_get_code_by("MEANING",29520,"WKFDOCCOMP")), protect
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
     AND ce.event_class_cd IN (dtxtcd, ddoccd)
     AND ce.entry_mode_cd IN (dwfcentrymodecd, dddentrymodecd)
     AND  NOT (ce.result_status_cd IN (dinerror1, dinerror2, dinerror3, dinerror4))
    ORDER BY ce.parent_event_id, cnvtreal(ce.collating_seq)
    HEAD ce.parent_event_id
     icnt += 1
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
 SUBROUTINE (getblobxhtmlviaeventid(ddoceventid=f8) =i2)
   DECLARE ierror = i2 WITH protect, noconstant(0)
   DECLARE ibloblength = i4 WITH protect, noconstant(0)
   DECLARE isearchres = i4 WITH protect, noconstant(0)
   DECLARE sblobcompressed = vc WITH protect, noconstant("")
   DECLARE docfcompresscd = f8 WITH protect, constant(uar_get_code_by("MEANING",120,"OCFCOMP"))
   DECLARE docfnocompresscd = f8 WITH protect, constant(uar_get_code_by("MEANING",120,"NOCOMP"))
   SELECT INTO "nl:"
    FROM ce_blob c
    PLAN (c
     WHERE c.event_id=ddoceventid
      AND c.valid_until_dt_tm=cnvtdatetime("31-DEC-2100"))
    ORDER BY c.event_id, c.blob_seq_num
    HEAD c.event_id
     ierror = 0, sblobcompressed = " ", g_sblobxhtml = "",
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
      stat = uar_ocf_uncompress(sblobcompressed,size(sblobcompressed),g_sblobxhtml,size(g_sblobxhtml),
       ibloblength)
     ELSEIF (c.compression_cd=docfnocompresscd)
      g_sblobxhtml = sblobcompressed
     ELSE
      CALL echo("Unhandled compression code")
     ENDIF
    WITH nocounter
   ;end select
   IF (g_sblobxhtml != "")
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE identifybadnotes(null)
   DECLARE ireportidx = i4 WITH protect, noconstant(0)
   DECLARE doc_row_cnt = i4 WITH protect, constant(size(dd_doc_event_ids->list_ids,5))
   DECLARE ddoceventid = f8 WITH noconstant(0.0)
   DECLARE g_sblobxhtml = vc WITH public, noconstant("")
   DECLARE ihtmlvalid = i2 WITH protect, noconstant(0)
   SET stat = alterlist(report_event_ids->list_ids,500)
   FOR (ieventidx = 1 TO doc_row_cnt)
    SET ddoceventid = dd_doc_event_ids->list_ids[ieventidx].event_id
    IF (ddoceventid=0.0)
     CALL echo("Event id is 0.0")
    ELSE
     IF (getblobxhtmlviaeventid(ddoceventid)=0)
      CALL echo("Failed to get the XHTML from the BLOB")
      CALL echo(build("Failed to get the XHTML from the BLOB for event id: ",ddoceventid))
     ELSE
      SET ihtmlvalid = identifyinvalidhtml(null)
      IF (((ihtmlvalid=0) OR (identifynuancefieldsstring(null) != 0)) )
       SET ireportidx += 1
       IF (ireportidx > 500
        AND mod(ireportidx,500)=1)
        SET stat = alterlist(report_event_ids->list_ids,(ireportidx+ 499))
       ENDIF
       SET report_event_ids->list_ids[ireportidx].event_id = ddoceventid
       SET report_event_ids->list_ids[ireportidx].ivalidhtmlind = ihtmlvalid
      ENDIF
     ENDIF
    ENDIF
   ENDFOR
   SET stat = alterlist(report_event_ids->list_ids,ireportidx)
 END ;Subroutine
 SUBROUTINE identifynuancefieldsstring(null)
   DECLARE nuancefieldregex = vc WITH protect, noconstant("")
   RECORD matchdatapos(
     1 startpos = i4
     1 endpos = i4
   ) WITH protect
   SET nuancefieldregex =
'(background-i.*nuance.*\);\s*background-r[^;]+;\s*background-p[^;]+;\s*)|(background-i.*nuance.*\);\s*background-p[^;]+;\s\
*background-r[^;]+;\s*)|(background-r[^;]+;\s*background-i.*nuance.*\);\s*background-p[^;]+;\s*)|(background-r[^;]+;\s*bac\
kground-p[^;]+;\s*background-i.*nuance.*\);\s*)|(background-p[^;]+;\s*background-i.*nuance.*\);\s*background-r[^;]+;\s*)|(\
background-p[^;]+;\s*background-r[^;]+;\s*background-i.*nuance.*\);\s*)|NUSAI?_[c|f]\w*|<br data-nusa.*?="(.*?)">|data-nus\
a.*?="(.*?)"\
'
   CALL regexmatch(g_sblobxhtml,nuancefieldregex,1,true,matchdatapos)
   IF ((matchdatapos->startpos > 0)
    AND (matchdatapos->endpos > matchdatapos->startpos))
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (PUBLIC::errorcheck(replystructure=vc(ref),operation=vc) =null WITH public)
   DECLARE errormsg = c255 WITH protect, noconstant("")
   DECLARE errorcode = i4 WITH protect, noconstant(0)
   SET errorcode = error(errormsg,0)
   IF (errorcode != 0)
    WHILE (errorcode != 0)
      SET replystructure->status_data.subeventstatus[1].operationname = operation
      SET replystructure->status_data.subeventstatus[1].targetobjectname = cnvtstring(errorcode,10)
      SET replystructure->status_data.subeventstatus[1].targetobjectvalue = errormsg
      SET replystructure->status_data.status = "F"
      IF ((reqdata->loglevel >= 4))
       CALL echo(errormsg)
      ENDIF
      SET errorcode = error(errormsg,0)
    ENDWHILE
    GO TO exit_script
   ENDIF
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
      clinical_event ce,
      clinical_event ce1,
      encntr_alias ea,
      encntr_alias ea1,
      person p,
      prsnl author
     PLAN (d)
      JOIN (ce
      WHERE (ce.event_id=report_event_ids->list_ids[d.seq].event_id)
       AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100"))
      JOIN (ce1
      WHERE ce.parent_event_id=ce1.event_id)
      JOIN (ea
      WHERE (ea.encntr_id= Outerjoin(ce1.encntr_id))
       AND (ea.encntr_alias_type_cd= Outerjoin(mrn_var)) )
      JOIN (ea1
      WHERE (ea1.encntr_id= Outerjoin(ce1.encntr_id))
       AND (ea1.encntr_alias_type_cd= Outerjoin(finnbr_var)) )
      JOIN (p
      WHERE p.person_id=ce1.person_id)
      JOIN (author
      WHERE author.person_id=ce1.performed_prsnl_id)
     ORDER BY ce.parent_event_id
     HEAD REPORT
      eventcount = 0
      IF (identifiedeventtotalcount=0)
       '"Event Id","Provider Name","Provider Id","Patient Name","Patient Id","MRN","FIN","Date of Service","Note Title"',
       '"Note Type","Note Status","Perform Date and Time","Valid Html"', row + 1
      ENDIF
     HEAD ce.parent_event_id
      eventcount += 1, recstr = "", quote_str = "",
      comma_str = "",
      CALL subr_out(build(ce.parent_event_id)), comma_str = ",",
      quote_str = '"',
      CALL subr_out(build(author.name_full_formatted)), quote_str = "",
      CALL subr_out(build(author.person_id)), quote_str = '"',
      CALL subr_out(build(p.name_full_formatted)),
      CALL subr_out(build(p.person_id)),
      CALL subr_out(trim(ea.alias)),
      CALL subr_out(trim(ea1.alias)),
      quote_str = "",
      CALL subr_out(build(format(ce.event_end_dt_tm,"@SHORTDATETIME"))), quote_str = '"',
      CALL subr_out(trim(ce1.event_title_text)),
      CALL subr_out(build(uar_get_code_display(ce.event_cd))),
      CALL subr_out(build(uar_get_code_display(ce.result_status_cd))),
      CALL subr_out(build(format(ce.performed_dt_tm,"@SHORTDATETIME"))), quote_str = "",
      CALL subr_out(build(report_event_ids->list_ids[d.seq].ivalidhtmlind))
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
 IF (datetimecmp(dttmstart,cnvtdatetime("01-JAN-2011")) < 0)
  CALL echo("   You entered a date before 01-JAN-2011. Please pick a date on or after 01-JAN-2011")
 ENDIF
 IF (cnvtreal( $SBATCHSIZE) < 1)
  CALL echo("   You entered a batch size less than 1.")
 ENDIF
END GO
