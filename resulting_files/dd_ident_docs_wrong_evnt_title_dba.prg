CREATE PROGRAM dd_ident_docs_wrong_evnt_title:dba
 PROMPT
  "Start date in DD-MMM-YYYY format (defaults to 20-APR-2021):" = "20-APR-2021",
  "End date in DD-MMM-YYYY format   (defaults to current date):" = "CURDATE",
  "Enter the number of DAYS/HOURS to process per batch (.5 = 12 hrs, 1 = 1 day, defaults to 1):" =
  "1"
  WITH sdttmstart, sdttmend, sbatchsize
 DECLARE soutputfilename = vc WITH constant(build("cer_temp:dd_ident_docs_wrong_evnt_title_log",
   format(curdate,"yymmdd;;d"),format(curtime,"hhmm;;m"),".csv"))
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
 DECLARE identifydocswitheventtitlemissingprsnl(null) = null
 DECLARE getprsnl(null) = null
 FREE RECORD addendadoc_event_ids
 RECORD addendadoc_event_ids(
   1 list_ids[*]
     2 clinical_event_id = f8
     2 event_id = f8
     2 performed_prsnl_id = f8
     2 performed_dt_tm = dq8
     2 event_title_text = vc
 )
 FREE RECORD report_event_ids
 RECORD report_event_ids(
   1 list_ids[*]
     2 clinical_event_id = f8
     2 event_id = f8
     2 performed_prsnl_name = vc
 )
 FREE RECORD prsnl_request
 RECORD prsnl_request(
   1 person_id = f8
   1 providers[*]
     2 person_id = f8
 )
 FREE RECORD prsnl_reply
 RECORD prsnl_reply(
   1 person_id = f8
   1 name_full_formatted = vc
   1 name_last = vc
   1 name_first = vc
   1 username = vc
   1 position_cd = f8
   1 position_disp = vc
   1 physician_ind = i2
   1 department_cd = f8
   1 department_disp = vc
   1 section_cd = f8
   1 section_disp = vc
   1 email = vc
   1 active_ind = i2
   1 lookup_status = i4
   1 providers[*]
     2 person_id = f8
     2 name_full_formatted = vc
     2 name_last = vc
     2 name_first = vc
     2 name_middle = vc
     2 username = vc
     2 email = vc
     2 physician_ind = i2
     2 position_cd = f8
     2 position_disp = vc
     2 position_mean = vc
     2 department_cd = f8
     2 department_disp = vc
     2 department_mean = vc
     2 physician_status_cd = f8
     2 physician_status_disp = vc
     2 physician_status_mean = vc
     2 section_cd = f8
     2 section_disp = vc
     2 section_mean = vc
     2 active_ind = i2
     2 name_hist[*]
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 name_full_formatted = vc
       3 name_last = vc
       3 name_first = vc
       3 name_middle = vc
       3 normal_record = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
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
   CALL getprsnl(null)
   CALL identifydocswitheventtitlemissingprsnl(null)
   CALL outputreport(batchdttmstart,batchdttmend)
   SET batchdttmstart = batchdttmend
   SET batchdttmend = datetimeadd(batchdttmstart,bucketsize)
   SET stat = initrec(addendadoc_event_ids)
   SET stat = initrec(report_event_ids)
   SET stat = initrec(prsnl_request)
   SET stat = initrec(prsnl_reply)
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
 SUBROUTINE (queryaddendadocs(batchdttmstart=f8,batchdttmend=f8) =null)
   DECLARE ieventidx = i4 WITH protect, noconstant(0)
   DECLARE ddyndocentrymodecd = f8 WITH constant(uar_get_code_by("MEANING",29520,"DYNDOC"))
   DECLARE ddoccd = f8 WITH constant(uar_get_code_by("MEANING",53,"DOC")), protect
   DECLARE iaddprsnl = i4 WITH noconstant(0)
   SELECT INTO "nl:"
    FROM clinical_event ce
    PLAN (ce
     WHERE ce.updt_dt_tm >= cnvtdatetime(batchdttmstart)
      AND ce.updt_dt_tm < cnvtdatetime(batchdttmend)
      AND ce.performed_prsnl_id != 0.0
      AND trim(ce.event_title_text) != null
      AND ce.entry_mode_cd=ddyndocentrymodecd
      AND ce.event_class_cd=ddoccd)
    ORDER BY ce.event_id, ce.updt_dt_tm
    DETAIL
     ieventidx += 1
     IF (mod(ieventidx,500)=1)
      stat = alterlist(addendadoc_event_ids->list_ids,(ieventidx+ 499))
     ENDIF
     addendadoc_event_ids->list_ids[ieventidx].clinical_event_id = ce.clinical_event_id,
     addendadoc_event_ids->list_ids[ieventidx].event_id = ce.event_id, addendadoc_event_ids->
     list_ids[ieventidx].performed_prsnl_id = ce.performed_prsnl_id,
     addendadoc_event_ids->list_ids[ieventidx].performed_dt_tm = ce.performed_dt_tm,
     addendadoc_event_ids->list_ids[ieventidx].event_title_text = ce.event_title_text, iaddprsnl =
     addprsnl(ce.performed_prsnl_id)
    FOOT REPORT
     stat = alterlist(addendadoc_event_ids->list_ids,ieventidx)
    WITH nocounter, orahintcbo("index(ce XIE12CLINICAL_EVENT)")
   ;end select
 END ;Subroutine
 SUBROUTINE identifydocswitheventtitlemissingprsnl(null)
   DECLARE doccnt = i4 WITH protect, constant(size(addendadoc_event_ids->list_ids,5))
   DECLARE idocidx = i4 WITH protect, noconstant(0)
   DECLARE snamefullformatted = vc WITH protect, noconstant("")
   DECLARE ireportidx = i4 WITH protect, noconstant(0)
   DECLARE sprsnlpiece = vc WITH protect, noconstant("")
   DECLARE spreviouseventtitletext = vc WITH protect, noconstant("")
   FOR (idocidx = 1 TO doccnt)
    SET snamefullformatted = getprsnlnamebycalendar(addendadoc_event_ids->list_ids[idocidx].
     performed_prsnl_id,cnvtdatetime(addendadoc_event_ids->list_ids[idocidx].performed_dt_tm))
    IF ((addendadoc_event_ids->list_ids[idocidx].event_title_text != patstring(concat("*",
      snamefullformatted,"*"))))
     CALL echo(build("sNameFullFormatted - ",snamefullformatted))
     SET spreviouseventtitletext = trim(addendadoc_event_ids->list_ids[idocidx].event_title_text)
     SET sprsnlpiece = piece(spreviouseventtitletext," ",3,"notfnd")
     IF (((trim(sprsnlpiece)=null) OR (trim(sprsnlpiece)="por"
      AND trim(piece(spreviouseventtitletext," ",4,"notfnd"))=null)) )
      SET ireportidx += 1
      IF (mod(ireportidx,500)=1)
       SET stat = alterlist(report_event_ids->list_ids,(ireportidx+ 499))
      ENDIF
      SET report_event_ids->list_ids[ireportidx].clinical_event_id = addendadoc_event_ids->list_ids[
      idocidx].clinical_event_id
      SET report_event_ids->list_ids[ireportidx].event_id = addendadoc_event_ids->list_ids[idocidx].
      event_id
      SET report_event_ids->list_ids[ireportidx].performed_prsnl_name = snamefullformatted
     ENDIF
    ENDIF
   ENDFOR
   IF (ireportidx != 0)
    SET stat = alterlist(report_event_ids->list_ids,ireportidx)
   ENDIF
 END ;Subroutine
 SUBROUTINE (addprsnl(prsnl_id=f8) =i4)
   DECLARE id_exists = i4 WITH protect, noconstant(0)
   DECLARE new_prsnl_cnt = i4 WITH protect, noconstant(0)
   IF (prsnl_id <= 0)
    RETURN
   ENDIF
   SET provider_cnt = size(prsnl_request->providers,5)
   IF (provider_cnt > 0)
    SET iterator = 0
    SET index_loc = locateval(iterator,1,provider_cnt,prsnl_id,prsnl_request->providers[iterator].
     person_id)
    IF (index_loc > 0)
     SET id_exists = 1
    ENDIF
   ENDIF
   IF (id_exists=0)
    SET new_prsnl_cnt = (provider_cnt+ 1)
    SET stat = alterlist(prsnl_request->providers,new_prsnl_cnt)
    SET prsnl_request->providers[new_prsnl_cnt].person_id = prsnl_id
   ENDIF
 END ;Subroutine
 SUBROUTINE getprsnl(null)
   IF (size(prsnl_request->providers,5) > 0)
    SET modify = nopredeclare
    EXECUTE pts_get_prsnl_demo  WITH replace("REQUEST","PRSNL_REQUEST"), replace("REPLY",
     "PRSNL_REPLY")
    SET modify = predeclare
   ENDIF
 END ;Subroutine
 SUBROUTINE (getprsnlnamebycalendar(prsnlid=f8,performeddttm=f8) =vc)
   DECLARE provider_size = i4 WITH protect, noconstant(0)
   DECLARE name_hist_cnt = i4 WITH protect, noconstant(0)
   SET provider_size = size(prsnl_reply->providers,5)
   SET iterator = 0
   SET index_loc = locateval(iterator,1,provider_size,prsnlid,prsnl_reply->providers[iterator].
    person_id)
   IF (index_loc > 0)
    FOR (name_hist_cnt = 1 TO size(prsnl_reply->providers[index_loc].name_hist,5))
      IF (cnvtdatetime(prsnl_reply->providers[index_loc].name_hist[name_hist_cnt].beg_effective_dt_tm
       ) <= performeddttm
       AND cnvtdatetime(prsnl_reply->providers[index_loc].name_hist[name_hist_cnt].
       end_effective_dt_tm) >= performeddttm)
       RETURN(prsnl_reply->providers[index_loc].name_hist[name_hist_cnt].name_full_formatted)
      ENDIF
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE (outputreport(batchdttmstart=f8,batchdttmend=f8) =null)
   DECLARE report_event_count = i4 WITH protect, constant(size(report_event_ids->list_ids,5))
   CALL echo(build("   REPORT_EVENT_COUNT: ",report_event_count))
   DECLARE ddoccd = f8 WITH constant(uar_get_code_by("MEANING",53,"DOC")), protect
   IF (report_event_count > 0)
    DECLARE eventcount = i4 WITH noconstant(0)
    DECLARE recstr = vc WITH noconstant("")
    SELECT INTO value(soutputfilename)
     FROM (dummyt d  WITH seq = value(report_event_count)),
      clinical_event ce,
      person p
     PLAN (d)
      JOIN (ce
      WHERE (ce.clinical_event_id=report_event_ids->list_ids[d.seq].clinical_event_id))
      JOIN (p
      WHERE p.person_id=ce.person_id)
     ORDER BY ce.clinical_event_id
     HEAD REPORT
      eventcount = 0
      IF (identifiedeventtotalcount=0)
       '"Clinical Event Id","Event Id","Encounter Id","Patient Name","Service Date and Time","Event Title Text"',
       ',"Author Name","Author Id","Patient Id","Note Type","Note Status","Perform Date and Time"',
       row + 1
      ENDIF
     DETAIL
      eventcount += 1, recstr = "", quote_str = "",
      comma_str = "",
      CALL subr_out(build(ce.clinical_event_id)), comma_str = ",",
      CALL subr_out(build(ce.event_id)), comma_str = ",",
      CALL subr_out(build(ce.encntr_id)),
      comma_str = ",", quote_str = '"',
      CALL subr_out(build(p.name_full_formatted)),
      quote_str = "",
      CALL subr_out(build(format(ce.event_end_dt_tm,"@SHORTDATETIME"))), quote_str = '"',
      CALL subr_out(build(ce.event_title_text)),
      CALL subr_out(build(report_event_ids->list_ids[d.seq].performed_prsnl_name)), quote_str = "",
      CALL subr_out(build(ce.performed_prsnl_id)),
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
      identifiedeventtotalcount += eventcount
     WITH nocounter, check, format = variable,
      noformfeed, maxcol = 700, maxrow = 1,
      append
    ;end select
   ENDIF
 END ;Subroutine
#endscript
END GO
