CREATE PROGRAM dd_updt_docs_missing_addenda:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter file name with the location of the file (eg.cer_temp:dd_ident_docs_missing_addenda_log1502031408.csv): "
   = "",
  "Enter the username for the user who is running the update script (eg. mc014821): " = "mc014821"
  WITH outdev, sinputfile, susername
 DECLARE sinputfilename = vc WITH protect, noconstant(build( $SINPUTFILE))
 IF (findfile(sinputfilename)=0)
  CALL echo("*************************************************************************")
  CALL echo(concat("Failed - could not find the file: ",sinputfilename))
  CALL echo("*************************************************************************")
  GO TO exit_script
 ENDIF
 DECLARE duserpersonid = f8 WITH public, noconstant(0.0)
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
 DECLARE sfaileddocsoutputfilename = vc WITH public, constant(build(
   "cer_temp:dd_failed_to_updt_docs_log",format(curdate,"yymmdd;;d"),format(curtime,"hhmm;;m"),".csv"
   ))
 DECLARE snoupdateneededdocsoutputfilename = vc WITH constant(build(
   "cer_temp:dd_no_updt_needed_docs_log",format(curdate,"yymmdd;;d"),format(curtime,"hhmm;;m"),".csv"
   ))
 SET modify maxvarlen 268435456
 DECLARE stat = i4 WITH public, noconstant(0)
 DECLARE g_sblobxhtml = vc WITH public, noconstant("")
 DECLARE g_dttmcur = dq8 WITH public, noconstant(cnvtdatetime(sysdate))
 DECLARE readinputcsv(null) = null WITH protect
 DECLARE identifyselfclosingtitleelement(null) = i2 WITH protect
 DECLARE updateblobxhtml(null) = i2 WITH protect
 FREE DEFINE rtl3
 DEFINE rtl3 sinputfilename
 DECLARE eventcount = i4 WITH noconstant(0)
 DECLARE failedeventcount = i4 WITH noconstant(0)
 DECLARE noupdateneededeventcount = i4 WITH noconstant(0)
 DECLARE notfnd = vc WITH constant("<not_found>")
 DECLARE ieventidx = i4 WITH noconstant(1)
 DECLARE bfailedevent = i2 WITH noconstant(0)
 DECLARE docfcompresscd = f8 WITH public, noconstant(uar_get_code_by("MEANING",120,"OCFCOMP"))
 DECLARE docfnocompresscd = f8 WITH public, noconstant(uar_get_code_by("MEANING",120,"NOCOMP"))
 FREE RECORD dd_event_ids
 RECORD dd_event_ids(
   1 list_ids[*]
     2 addenda_event_id = f8
 )
 CALL readinputcsv(null)
 DECLARE ddoceventid = f8 WITH noconstant(0.0)
 FOR (ieventidx = 1 TO eventcount)
  IF (value(dd_event_ids->list_ids[ieventidx].addenda_event_id)=0.0)
   SET bfailedevent = 1
   CALL echo("Event id is 0.0")
  ELSE
   SET ddoceventid = dd_event_ids->list_ids[ieventidx].addenda_event_id
   IF (getblobxhtmlviaeventid(ddoceventid)=0)
    SET bfailedevent = 1
    CALL echo("Failed to get the HTML from the BLOB")
    CALL echo(build("Failed to get the HTML from the BLOB for event id: ",ddoceventid))
   ELSE
    IF (identifyselfclosingtitleelement(null)=0)
     SET bfailedevent = 0
     SET noupdateneededeventcount += 1
     CALL outputreport(snoupdateneededdocsoutputfilename,noupdateneededeventcount,ddoceventid)
     CALL echo(build("No update needed on the xhtml from the BLOB for event id: ",ddoceventid))
    ELSE
     IF (updateblobxhtml(ddoceventid)=0)
      SET bfailedevent = 0
      SET noupdateneededeventcount += 1
      CALL outputreport(snoupdateneededdocsoutputfilename,noupdateneededeventcount,ddoceventid)
      CALL echo(build("No update needed on the xhtml from the BLOB for event id: ",ddoceventid))
     ELSE
      IF (updateeventserver(ddoceventid)=0)
       SET bfailedevent = 1
       CALL echo(build(
         "Failed to update the xhtml on the ce_blob table via event server for event id: ",
         ddoceventid))
      ELSE
       SET bfailedevent = 0
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  ENDIF
  IF (bfailedevent=1)
   SET failedeventcount += 1
   CALL outputreport(sfaileddocsoutputfilename,failedeventcount,value(dd_event_ids->list_ids[
     ieventidx].event_id))
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
 DECLARE stotalevents = vc WITH protect
 DECLARE sfailedevent = vc WITH protect
 DECLARE snoupdateneededevent = vc WITH protect
 SELECT INTO  $OUTDEV
  FROM (dummyt d  WITH seq = 1)
  PLAN (d)
  HEAD REPORT
   stotalevents = build("Total number of events: ",eventcount)
   IF (failedeventcount > 0)
    sfailedevent = build("Output file name with location for failed to update events: ",
     sfaileddocsoutputfilename)
   ENDIF
   IF (noupdateneededeventcount > 0)
    snoupdateneededevent = build("Output file name with location for no update needed events: ",
     snoupdateneededdocsoutputfilename)
   ENDIF
   row 0, col 0, stotalevents,
   row 1, col 0, sfailedevent,
   row 2, col 0, snoupdateneededevent
  WITH nocounter
 ;end select
#exit_script
 SUBROUTINE readinputcsv(null)
   SELECT INTO "nl:"
    FROM rtl3t r
    WHERE r.line > ""
    DETAIL
     IF (mod(eventcount,100)=0)
      stat = alterlist(dd_event_ids->list_ids,(eventcount+ 100))
     ENDIF
     IF (cnvtreal(piece(r.line,",",1,"notfnd",0)) > 0.0)
      eventcount += 1, dd_event_ids->list_ids[eventcount].addenda_event_id = cnvtreal(piece(r.line,
        ",",2,"notfnd",0))
     ENDIF
    FOOT REPORT
     IF (eventcount > 0)
      stat = alterlist(dd_event_ids->list_ids,eventcount)
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE (getblobxhtmlviaeventid(ddoceventid=f8) =i2 WITH protect)
   DECLARE applicationid = i4 WITH constant(1000011)
   DECLARE taskid = i4 WITH constant(1000011)
   DECLARE requestid = i4 WITH constant(1000011)
   DECLARE happ = i4 WITH noconstant(0)
   DECLARE htask = i4 WITH noconstant(0)
   DECLARE hstep = i4 WITH noconstant(0)
   DECLARE hrblist = i4 WITH noconstant(0)
   DECLARE query_mode = i4 WITH constant(3)
   DECLARE iret = i2 WITH noconstant(0)
   SET g_sblobxhtml = ""
   SET iret = calleventserver(ddoceventid)
   IF (iret=0)
    RETURN(0)
   ENDIF
   RETURN(1)
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
 END ;Subroutine
 SUBROUTINE identifyselfclosingtitleelement(null)
   DECLARE ititlepos = i4 WITH protect, constant(findstring("<title/>",g_sblobxhtml))
   IF (ititlepos > 0)
    RETURN(1)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE updateblobxhtml(null)
   DECLARE titleelementwithseparatetags = vc WITH protect, noconstant("<title></title>")
   DECLARE selfclosingtitletag = vc WITH protect, noconstant("<title/>")
   SET g_sblobxhtml = replace(g_sblobxhtml,selfclosingtitletag,titleelementwithseparatetags,0)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (updateeventserver(ddoceventid=f8) =i2 WITH protect)
   EXECUTE crmrtl
   EXECUTE srvrtl
   DECLARE lblobsize = i4
   DECLARE happ = i4
   DECLARE htask = i4
   DECLARE hstep = i4
   DECLARE hreq = i4
   DECLARE hblob = i4
   DECLARE hce = i4
   DECLARE hchildevent = i4
   DECLARE hcetype = i4 WITH noconstant(0), protect
   DECLARE hblobitem = i4
   DECLARE crmstatus = i2
   DECLARE ipopulateeventstructure = i2
   DECLARE srvstat = i4
   SET crmstatus = uar_crmbeginapp(1000012,happ)
   IF (crmstatus != 0)
    CALL echo("Error in Begin App for application 1000012.")
    CALL echo(build("Crm Status: ",crmstatus))
    CALL echo("Cannot call Event_Ensure. Exiting Script.")
    RETURN(0)
   ENDIF
   SET crmstatus = uar_crmbegintask(happ,1000012,htask)
   IF (crmstatus != 0)
    CALL echo("Error in Begin Task for task 1000012.")
    CALL echo(build("Crm Status: ",crmstatus))
    CALL echo("Cannot call Event_Ensure. Exiting Script.")
    IF (happ)
     CALL uar_crmendapp(happ)
    ENDIF
    RETURN(0)
   ENDIF
   SET crmstatus = uar_crmbeginreq(htask,"",1000012,hstep)
   IF (crmstatus != 0)
    CALL echo("Error in Begin Request for request 1000012.")
    CALL echo(build("Crm Status: ",crmstatus))
    IF (htask)
     CALL uar_crmendtask(htask)
    ENDIF
    IF (happ)
     CALL uar_crmendapp(happ)
    ENDIF
    RETURN(0)
   ELSE
    SET hreq = uar_crmgetrequest(hstep)
    SELECT INTO "nl:"
     FROM clinical_event ce
     WHERE ce.event_id=ddoceventid
      AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
     DETAIL
      ipopulateeventstructure = populateeventstructure(hreq,ce.result_status_cd,ce.parent_event_id,ce
       .event_id)
     WITH nocounter
    ;end select
    IF (ipopulateeventstructure=0)
     CALL echo("Failed to populate the event structure")
     RETURN(0)
    ENDIF
    SET crmstatus = uar_crmperform(hstep)
    IF (crmstatus != 0)
     CALL echo("Error in Perform Request for request 1000012.")
     CALL echo(build("Crm Status : ",crmstatus))
     IF (htask)
      CALL uar_crmendtask(htask)
     ENDIF
     IF (happ)
      CALL uar_crmendapp(happ)
     ENDIF
     IF (hstep)
      CALL uar_crmendapp(hstep)
     ENDIF
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
   SUBROUTINE (populateeventstructure(hreq=i4,resultstatuscd=f8,dparenteventid=f8,ddoceventid=f8) =i2
    )
     DECLARE auth_rest_status = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
     DECLARE modified_rest_status = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED")
      )
     DECLARE action_status_completed = f8 WITH protect, constant(uar_get_code_by("MEANING",103,
       "COMPLETED"))
     DECLARE action_type_modify = f8 WITH protect, constant(uar_get_code_by("MEANING",21,"MODIFY"))
     DECLARE addtoeventprsnllist(hreq,personid,actionprsnlid,actiontypecd,actionstatuscd,
      actiondttm) = null WITH protect
     SET srvstat = uar_srvsetshort(hreq,"ensure_type",2)
     SET hce = uar_srvgetstruct(hreq,"clin_event")
     IF (resultstatuscd=auth_rest_status)
      SET srvstat = uar_srvsetdouble(hce,"result_status_cd",modified_rest_status)
     ENDIF
     CALL addtoeventprsnllist(hce,duserpersonid,duserpersonid,action_type_modify,
      action_status_completed,
      cnvtdatetime(g_dttmcur))
     IF (dparenteventid != ddoceventid)
      IF (populatemdocrow(hce,dparenteventid)=0)
       RETURN(0)
      ENDIF
      SET hcetype = uar_srvcreatetypefrom(hreq,"clin_event")
      SET srvstat = uar_srvbinditemtype(hce,"child_event_list",hcetype)
      IF (hcetype)
       CALL uar_srvdestroytype(hcetype)
      ENDIF
      SET hchildevent = uar_srvadditem(hce,"child_event_list")
     ELSE
      SET hchildevent = hce
     ENDIF
     IF (populatedocrow(hchildevent,dparenteventid,ddoceventid)=0)
      RETURN(0)
     ENDIF
     RETURN(1)
     SUBROUTINE (populatemdocrow(hce=i4,dparenteventid=f8) =i2)
       SET srvstat = uar_srvsetshort(hce,"ensure_type",2)
       SET srvstat = uar_srvsetdouble(hce,"event_id",dparenteventid)
       SET srvstat = uar_srvsetshort(hce,"view_level_ind",1)
       SET srvstat = uar_srvsetshort(hce,"event_start_dt_tm_ind",1)
       SET srvstat = uar_srvsetshort(hce,"event_end_dt_tm_ind",1)
       SET srvstat = uar_srvsetshort(hce,"event_end_dt_tm_os_ind",1)
       SET srvstat = uar_srvsetshort(hce,"authentic_flag_ind",1)
       SET srvstat = uar_srvsetshort(hce,"publish_flag_ind",1)
       SET srvstat = uar_srvsetshort(hce,"subtable_bit_map_ind",1)
       SET srvstat = uar_srvsetshort(hce,"expiration_dt_tm_ind",1)
       SET srvstat = uar_srvsetshort(hce,"clinsig_updt_dt_tm_ind",1)
       SET srvstat = uar_srvsetshort(hce,"valid_until_dt_tm_ind",1)
       SET srvstat = uar_srvsetshort(hce,"valid_from_dt_tm_ind",1)
       SET srvstat = uar_srvsetshort(hce,"verified_dt_tm_ind",1)
       SET srvstat = uar_srvsetshort(hce,"performed_dt_tm_ind",1)
       SET srvstat = uar_srvsetshort(hce,"updt_dt_tm_ind",1)
       SET srvstat = uar_srvsetshort(hce,"updt_task_ind",1)
       SET srvstat = uar_srvsetshort(hce,"updt_cnt_ind",1)
       SET srvstat = uar_srvsetshort(hce,"updt_applctx_ind",1)
       RETURN(1)
     END ;Subroutine
     SUBROUTINE (populatedocrow(hchildevent=i4,dparenteventid=f8,ddoceventid=f8) =i2)
       DECLARE succntypecd = f8 WITH constant(uar_get_code_by("MEANING",63,"FINAL"))
       DECLARE storagecd = f8 WITH constant(uar_get_code_by("MEANING",25,"BLOB"))
       DECLARE formatcd = f8 WITH constant(uar_get_code_by("MEANING",23,"XHTML"))
       SET srvstat = uar_srvsetshort(hchildevent,"ensure_type",2)
       SET srvstat = uar_srvsetdouble(hchildevent,"event_id",ddoceventid)
       SET srvstat = uar_srvsetshort(hchildevent,"view_level_ind",1)
       SET srvstat = uar_srvsetshort(hchildevent,"event_start_dt_tm_ind",1)
       SET srvstat = uar_srvsetshort(hchildevent,"event_end_dt_tm_ind",1)
       SET srvstat = uar_srvsetshort(hchildevent,"event_end_dt_tm_os_ind",1)
       SET srvstat = uar_srvsetshort(hchildevent,"authentic_flag_ind",1)
       SET srvstat = uar_srvsetshort(hchildevent,"publish_flag_ind",1)
       SET srvstat = uar_srvsetshort(hchildevent,"subtable_bit_map_ind",1)
       SET srvstat = uar_srvsetshort(hchildevent,"expiration_dt_tm_ind",1)
       SET srvstat = uar_srvsetshort(hchildevent,"clinsig_updt_dt_tm_ind",1)
       SET srvstat = uar_srvsetshort(hchildevent,"valid_until_dt_tm_ind",1)
       SET srvstat = uar_srvsetshort(hchildevent,"valid_from_dt_tm_ind",1)
       SET srvstat = uar_srvsetshort(hchildevent,"verified_dt_tm_ind",1)
       SET srvstat = uar_srvsetshort(hchildevent,"performed_dt_tm_ind",1)
       SET srvstat = uar_srvsetshort(hchildevent,"updt_dt_tm_ind",1)
       SET srvstat = uar_srvsetshort(hchildevent,"updt_task_ind",1)
       SET srvstat = uar_srvsetshort(hchildevent,"updt_cnt_ind",1)
       SET srvstat = uar_srvsetshort(hchildevent,"updt_applctx_ind",1)
       SET hblobitem = uar_srvadditem(hchildevent,"blob_result")
       SET srvstat = uar_srvsetdouble(hblobitem,"succession_type_cd",succntypecd)
       SET srvstat = uar_srvsetdouble(hblobitem,"storage_cd",storagecd)
       SET srvstat = uar_srvsetdouble(hblobitem,"format_cd",formatcd)
       SET hblob = uar_srvadditem(hblobitem,"blob")
       IF (hblob)
        SET srvstat = uar_srvsetdouble(hblob,"compression_cd",docfnocompresscd)
        SET lblobsize = size(g_sblobxhtml,1)
        SET srvstat = uar_srvsetasis(hblob,"blob_contents",g_sblobxhtml,lblobsize)
        SET srvstat = uar_srvsetlong(hblob,"blob_length",lblobsize)
        RETURN(1)
       ELSE
        RETURN(0)
       ENDIF
     END ;Subroutine
     SUBROUTINE addtoeventprsnllist(hreq,personid,actionprsnlid,actiontypecd,actionstatuscd,
      actiondttm)
      DECLARE hprsnl = i4 WITH noconstant(0), private
      IF (hreq)
       SET hprsnl = uar_srvadditem(hreq,"event_prsnl_list")
       IF (hprsnl)
        SET srvstat = uar_srvsetdouble(hprsnl,"person_id",personid)
        SET srvstat = uar_srvsetdouble(hprsnl,"action_prsnl_id",actionprsnlid)
        SET srvstat = uar_srvsetdouble(hprsnl,"action_type_cd",actiontypecd)
        SET srvstat = uar_srvsetdouble(hprsnl,"action_status_cd",actionstatuscd)
        SET srvstat = uar_srvsetdate(hprsnl,"action_dt_tm",actiondttm)
       ENDIF
      ENDIF
     END ;Subroutine
   END ;Subroutine
 END ;Subroutine
 SUBROUTINE (outputreport(soutput=vc,ireporteventidx=i4,deventid=f8) =null WITH protect)
   DECLARE recstr = vc WITH noconstant("")
   IF (ireporteventidx=1)
    SELECT INTO value(soutput)
     DETAIL
      '"Event Id","Patient Name","Service Date and Time","Author Name","Author Id","Patient Id","Note Type"',
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
     CALL subr_out(build(ce.parent_event_id)), comma_str = ",", quote_str = '"',
     CALL subr_out(build(p.name_full_formatted)), quote_str = "",
     CALL subr_out(build(format(ce.event_end_dt_tm,"@SHORTDATETIME"))),
     quote_str = '"',
     CALL subr_out(build(author.name_full_formatted)), quote_str = "",
     CALL subr_out(build(author.person_id)),
     CALL subr_out(build(p.person_id)),
     CALL subr_out(build(uar_get_code_display(ce.event_cd))),
     CALL subr_out(build(uar_get_code_display(ce.result_status_cd))),
     CALL subr_out(build(format(ce.performed_dt_tm,"@SHORTDATETIME"))), quote_str = '"',
     CALL subr_out(trim(ce.event_title_text)), col 1, recstr,
     SUBROUTINE subr_out(p_data)
       recstr = concat(trim(recstr),trim(comma_str),trim(quote_str),build(p_data),trim(quote_str))
     END ;Subroutine report
    WITH nocounter, check, format = variable,
     noformfeed, maxcol = 700, maxrow = 1,
     append
   ;end select
 END ;Subroutine
END GO
