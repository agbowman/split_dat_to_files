CREATE PROGRAM cn_updt_docs_wrong_pat
 PROMPT
  "Enter file name with the location of the file (eg. cer_temp:cn_docs_with_wrong_pat_log1502031408.csv): "
   = "",
  "Enter the username for the user who is running the update script (eg. mc014821): " = "mc014821"
  WITH sinputfile, susername
 DECLARE sinputfilename = vc WITH noconstant(build( $SINPUTFILE))
 IF (findfile(sinputfilename)=0)
  CALL echo("*************************************************************************")
  CALL echo(concat("Failed - could not find the file: ",sinputfilename))
  CALL echo("*************************************************************************")
  GO TO exit_script
 ENDIF
 DECLARE duserpersonid = f8 WITH noconstant(0.0)
 SELECT INTO "nl:"
  FROM prsnl author
  WHERE author.username=value(cnvtupper( $SUSERNAME))
  DETAIL
   duserpersonid = author.person_id
  WITH nocounter
 ;end select
 IF (duserpersonid=0.0)
  CALL echo("*************************************************************************")
  CALL echo(build("Failed - could not find the username in the prsnl table: ",value( $SUSERNAME)))
  CALL echo("*************************************************************************")
  GO TO exit_script
 ENDIF
 DECLARE sfaileddocsoutputfilename = vc WITH constant(build("cer_temp:cn_failed_to_updt_docs_log",
   format(curdate,"yymmdd;;d"),format(curtime,"hhmm;;m"),".csv"))
 DECLARE snoupdateneededdocsoutputfilename = vc WITH constant(build(
   "cer_temp:cn_no_updt_needed_docs_log",format(curdate,"yymmdd;;d"),format(curtime,"hhmm;;m"),".csv"
   ))
 DECLARE updatecedata(ddoceventid=f8,dpersonid=f8,dencounterid=f8) = i2 WITH protect
 DECLARE outputreport(soutput=vc,ireporteventidx=i4,deventid=f8) = null
 FREE DEFINE rtl3
 DEFINE rtl3 sinputfilename
 DECLARE eventcount = i4 WITH noconstant(0)
 DECLARE failedeventcount = i4 WITH noconstant(0)
 DECLARE noupdateneededeventcount = i4 WITH noconstant(0)
 DECLARE stat = i4 WITH noconstant(0)
 DECLARE notfnd = vc WITH constant("<not_found>")
 DECLARE ieventidx = i4 WITH noconstant(1)
 DECLARE bfailedevent = i2 WITH noconstant(0)
 SET stat = 0
 FREE RECORD clinicalnote_event_ids
 RECORD clinicalnote_event_ids(
   1 list_ids[*]
     2 event_id = f8
     2 encntr_id = f8
 )
 SELECT INTO "nl:"
  FROM rtl3t r
  WHERE r.line > ""
  DETAIL
   IF (mod(eventcount,100)=0)
    stat = alterlist(clinicalnote_event_ids->list_ids,(eventcount+ 100))
   ENDIF
   IF (cnvtreal(piece(r.line,",",1,"notfnd",0)) > 0.0)
    eventcount = (eventcount+ 1), clinicalnote_event_ids->list_ids[eventcount].event_id = cnvtreal(
     piece(r.line,",",1,"notfnd",0)), clinicalnote_event_ids->list_ids[eventcount].encntr_id =
    cnvtreal(piece(r.line,",",2,"notfnd",0))
   ENDIF
  FOOT REPORT
   IF (eventcount > 0)
    stat = alterlist(clinicalnote_event_ids->list_ids,eventcount)
   ENDIF
  WITH nocounter
 ;end select
 DECLARE ddoceventid = f8 WITH noconstant(0.0)
 DECLARE dencounterid = f8 WITH noconstant(0.0)
 DECLARE dpersonid = f8 WITH noconstant(0.0)
 FOR (ieventidx = 1 TO eventcount)
  IF (value(clinicalnote_event_ids->list_ids[ieventidx].event_id)=0.0)
   SET bfailedevent = 1
   CALL echo("Event id is 0.0")
  ELSE
   SET ddoceventid = clinicalnote_event_ids->list_ids[ieventidx].event_id
   SET dencounterid = clinicalnote_event_ids->list_ids[ieventidx].encntr_id
   SET dpersonid = 0.0
   SELECT INTO "nl:"
    e.person_id
    FROM encounter e
    WHERE e.encntr_id=dencounterid
    DETAIL
     dpersonid = e.person_id
    WITH nocounter
   ;end select
   IF (ddoceventid=0.0)
    SET bfailedevent = 1
    CALL echo("Event id does not exist in the clinical_event table")
   ELSEIF (dencounterid=0.0)
    SET bfailedevent = 1
    CALL echo("Encounter id does not exist in the clinical_event table")
   ELSE
    CALL updatecedata(ddoceventid,dpersonid,dencounterid)
    SET bfailedevent = 0
   ENDIF
  ENDIF
  IF (bfailedevent=1)
   SET failedeventcount = (failedeventcount+ 1)
   CALL outputreport(sfaileddocsoutputfilename,failedeventcount,value(clinicalnote_event_ids->
     list_ids[ieventidx].event_id))
  ENDIF
 ENDFOR
 COMMIT
 CALL echo("")
 CALL echo(build("   Total number of events: ",eventcount))
 CALL echo(build("   Total number of failed events: ",failedeventcount))
 CALL echo(build("   Output file name with location for failed to update events: ",
   sfaileddocsoutputfilename))
 CALL echo(build("   Total number of no update needed events: ",noupdateneededeventcount))
 CALL echo(build("   Output file name with location for no update needed events: ",
   snoupdateneededdocsoutputfilename))
 CALL echo("")
#exit_script
 SUBROUTINE updatecedata(ddoceventid,dpersonid,dencounterid)
   UPDATE  FROM clinical_event ce
    SET ce.person_id = dpersonid, ce.encntr_id = dencounterid, ce.updt_dt_tm = cnvtdatetime(curdate,
      curtime3),
     ce.updt_id = duserpersonid
    WHERE ce.parent_event_id=ddoceventid
   ;end update
 END ;Subroutine
 SUBROUTINE outputreport(soutput,ireporteventidx,deventid)
   DECLARE recstr = vc WITH noconstant("")
   IF (ireporteventidx=1)
    SELECT INTO value(soutput)
     DETAIL
      '"Event Id","Encounter Id","Patient Name","Service Date and Time","Author Name","Author Id","Patient Id","Note Type"',
      ',"Note Status","Perform Date and Time","Note Title"'
     WITH nocounter, format = variable, noformfeed,
      maxcol = 700, maxrow = 1, append
    ;end select
   ENDIF
   SELECT DISTINCT INTO value(soutput)
    FROM (dummyt d  WITH seq = value(1)),
     clinical_event ce,
     person p,
     prsnl author
    PLAN (d)
     JOIN (ce
     WHERE ce.event_id=deventid
      AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100"))
     JOIN (p
     WHERE p.person_id=ce.person_id)
     JOIN (author
     WHERE author.person_id=ce.performed_prsnl_id)
    DETAIL
     recstr = "", quote_str = "", comma_str = "",
     CALL subr_out(build(ce.parent_event_id)), comma_str = ",",
     CALL subr_out(build(ce.encntr_id)),
     comma_str = ",", quote_str = '"',
     CALL subr_out(build(p.name_full_formatted)),
     quote_str = "",
     CALL subr_out(build(format(ce.event_end_dt_tm,"@SHORTDATETIME"))), quote_str = '"',
     CALL subr_out(build(author.name_full_formatted)), quote_str = "",
     CALL subr_out(build(author.person_id)),
     CALL subr_out(build(p.person_id)),
     CALL subr_out(build(uar_get_code_display(ce.event_cd))),
     CALL subr_out(build(uar_get_code_display(ce.result_status_cd))),
     CALL subr_out(build(format(ce.performed_dt_tm,"@SHORTDATETIME"))), quote_str = '"',
     CALL subr_out(trim(ce.event_title_text)),
     col 1, recstr,
     SUBROUTINE subr_out(p_data)
       recstr = concat(trim(recstr),trim(comma_str),trim(quote_str),build(p_data),trim(quote_str))
     END ;Subroutine report
    WITH nocounter, check, format = variable,
     noformfeed, maxcol = 700, maxrow = 1,
     append
   ;end select
 END ;Subroutine
END GO
