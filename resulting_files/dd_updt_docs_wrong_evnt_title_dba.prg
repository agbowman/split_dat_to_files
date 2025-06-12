CREATE PROGRAM dd_updt_docs_wrong_evnt_title:dba
 PROMPT
  "Enter file name with the location of the file (eg. cer_temp:dd_ident_docs_event_title_text_log2106161525.csv): "
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
 DECLARE sfaileddocsoutputfilename = vc WITH constant(build("cer_temp:dd_failed_to_updt_docs_log",
   format(curdate,"yymmdd;;d"),format(curtime,"hhmm;;m"),".csv"))
 DECLARE snoupdateneededdocsoutputfilename = vc WITH constant(build(
   "cer_temp:dd_no_updt_needed_docs_log",format(curdate,"yymmdd;;d"),format(curtime,"hhmm;;m"),".csv"
   ))
 DECLARE supdateddocsoutputfilename = vc WITH constant(build("cer_temp:dd_updt_docs_log",format(
    curdate,"yymmdd;;d"),format(curtime,"hhmm;;m"),".csv"))
 FREE DEFINE rtl3
 DEFINE rtl3 sinputfilename
 DECLARE eventcount = i4 WITH noconstant(0)
 DECLARE failedeventcount = i4 WITH noconstant(0)
 DECLARE noupdateneededeventcount = i4 WITH noconstant(0)
 DECLARE updatedeventcount = i4 WITH noconstant(0)
 DECLARE stat = i4 WITH noconstant(0)
 DECLARE notfnd = vc WITH constant("<not_found>")
 DECLARE ieventidx = i4 WITH noconstant(1)
 DECLARE bfailedevent = i2 WITH noconstant(0)
 DECLARE updateeventtitletext(spreviouseventtitletext,sperformedprsnlname) = null WITH protect
 SET stat = 0
 FREE RECORD dd_event_ids
 RECORD dd_event_ids(
   1 list_ids[*]
     2 clinical_event_id = f8
     2 performed_prsnl_name = vc
 )
 SELECT INTO "nl:"
  FROM rtl3t r
  WHERE r.line > ""
  DETAIL
   IF (mod(eventcount,100)=0)
    stat = alterlist(dd_event_ids->list_ids,(eventcount+ 100))
   ENDIF
   IF (cnvtreal(piece(r.line,",",1,"notfnd",0)) > 0.0)
    eventcount += 1, dd_event_ids->list_ids[eventcount].clinical_event_id = cnvtreal(piece(r.line,",",
      1,"notfnd",0)), dd_event_ids->list_ids[eventcount].performed_prsnl_name = piece(r.line,",",7,
     "notfnd",3)
   ENDIF
  FOOT REPORT
   IF (eventcount > 0)
    stat = alterlist(dd_event_ids->list_ids,eventcount)
   ENDIF
  WITH nocounter
 ;end select
 DECLARE ddocclineventid = f8 WITH noconstant(0.0)
 DECLARE sperformedprsnlname = vc WITH noconstant(" ")
 DECLARE g_seventtitletext = vc WITH noconstant(" ")
 FOR (ieventidx = 1 TO eventcount)
   SET g_seventtitletext = " "
   IF (value(dd_event_ids->list_ids[ieventidx].clinical_event_id)=0.0)
    SET bfailedevent = 1
    CALL echo("Clinical event id is 0.0")
   ELSE
    SET ddocclineventid = dd_event_ids->list_ids[ieventidx].clinical_event_id
    SET sperformedprsnlname = dd_event_ids->list_ids[ieventidx].performed_prsnl_name
    IF (ddocclineventid=0.0)
     SET bfailedevent = 1
     CALL echo("Clinical Event id does not exist in the clinical_event table")
    ELSEIF (sperformedprsnlname=" ")
     SET bfailedevent = 1
     CALL echo("sPerformedPrsnlName is empty")
    ELSE
     IF (geteventtitleforeventid(ddocclineventid,sperformedprsnlname)=0)
      SET bfailedevent = 0
      SET noupdateneededeventcount += 1
      CALL outputreport(snoupdateneededdocsoutputfilename,noupdateneededeventcount,ddocclineventid)
      CALL echo(build("No update needed on the event title text clinical event id: ",ddocclineventid)
       )
     ELSE
      CALL updatecedata(ddocclineventid)
      SET bfailedevent = 0
      SET updatedeventcount += 1
      CALL outputreport(supdateddocsoutputfilename,updatedeventcount,ddocclineventid)
     ENDIF
    ENDIF
   ENDIF
   IF (bfailedevent=1)
    SET failedeventcount += 1
    CALL outputreport(sfaileddocsoutputfilename,failedeventcount,value(clinicalnote_event_ids->
      list_ids[ieventidx].clinical_event_id))
   ENDIF
 ENDFOR
 COMMIT
 CALL echo("")
 CALL echo(build("   Total number of events: ",eventcount))
 CALL echo(build("   Total number of updated events: ",updatedeventcount))
 CALL echo(build("   Output file name with location for updated events: ",supdateddocsoutputfilename)
  )
 CALL echo(build("   Total number of failed events: ",failedeventcount))
 CALL echo(build("   Output file name with location for failed to update events: ",
   sfaileddocsoutputfilename))
 CALL echo(build("   Total number of no update needed events: ",noupdateneededeventcount))
 CALL echo(build("   Output file name with location for no update needed events: ",
   snoupdateneededdocsoutputfilename))
 CALL echo("")
#exit_script
 SUBROUTINE (geteventtitleforeventid(deventid=f8,sperformedprsnlname=vc) =i2 WITH protect)
   DECLARE iupdateeventtext = i2 WITH protect, noconstant(0)
   DECLARE spreviouseventtitletext = vc WITH protect, noconstant(" ")
   SET g_seventtitletext = " "
   SET iupdateeventtext = 0
   SELECT INTO "nl:"
    FROM clinical_event ce
    WHERE ce.clinical_event_id=deventid
    DETAIL
     IF (ce.event_title_text != patstring(concat("*",sperformedprsnlname,"*")))
      spreviouseventtitletext = ce.event_title_text, iupdateeventtext = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (iupdateeventtext=1)
    CALL updateeventtitletext(trim(spreviouseventtitletext,7),trim(sperformedprsnlname,7))
   ENDIF
   RETURN(iupdateeventtext)
 END ;Subroutine
 SUBROUTINE updateeventtitletext(spreviouseventtitletext,sperformedprsnlname)
   DECLARE ncnt = i4 WITH protect, noconstant(0)
   DECLARE str = vc WITH protect, noconstant("")
   DECLARE iinsertprsnlpos = i4 WITH protect, noconstant(0)
   DECLARE sprsnlpiece = vc WITH protect, noconstant("")
   SET sprsnlpiece = trim(piece(spreviouseventtitletext," ",3,"notfnd"))
   IF (sprsnlpiece=null)
    SET iinsertprsnlpos = 3
   ELSEIF (sprsnlpiece="por"
    AND trim(piece(spreviouseventtitletext," ",4,"notfnd"))=null)
    SET iinsertprsnlpos = 4
   ENDIF
   WHILE (str != "notfnd")
     SET ncnt += 1
     SET str = piece(spreviouseventtitletext," ",ncnt,"notfnd")
     IF (ncnt=iinsertprsnlpos
      AND trim(str)=null)
      SET g_seventtitletext = build2(g_seventtitletext," ",sperformedprsnlname)
     ENDIF
     IF (str != "notfnd"
      AND trim(str) != null)
      SET g_seventtitletext = build2(g_seventtitletext," ",str)
     ENDIF
   ENDWHILE
 END ;Subroutine
 SUBROUTINE (updatecedata(ddoceventid=f8) =null WITH protect)
  SET g_seventtitletext = trim(g_seventtitletext,7)
  UPDATE  FROM clinical_event ce
   SET ce.event_title_text = g_seventtitletext
   WHERE ce.clinical_event_id=ddoceventid
  ;end update
 END ;Subroutine
 SUBROUTINE (outputreport(soutput=vc,ireporteventidx=i4,deventid=f8) =null)
   DECLARE recstr = vc WITH noconstant("")
   IF (ireporteventidx=1)
    SELECT INTO value(soutput)
     DETAIL
      '"Event Id","Encounter Id","Patient Name","Service Date and Time","Author Name","Author Id","Patient Id","Note Type"',
      ',"Note Status","Perform Date and Time","Previous Event Title Text", "New Event Title Text"'
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
     WHERE ce.clinical_event_id=deventid)
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
     CALL subr_out(trim(g_seventtitletext)), col 1, recstr,
     SUBROUTINE subr_out(p_data)
       recstr = concat(trim(recstr),trim(comma_str),trim(quote_str),build(p_data),trim(quote_str))
     END ;Subroutine report
    WITH nocounter, check, format = variable,
     noformfeed, maxcol = 700, maxrow = 1,
     append
   ;end select
 END ;Subroutine
END GO
