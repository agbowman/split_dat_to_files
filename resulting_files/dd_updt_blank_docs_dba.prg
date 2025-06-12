CREATE PROGRAM dd_updt_blank_docs:dba
 PROMPT
  "Enter file name with the location of the file (eg. cer_temp:dd_empty_documents1502031408.csv): "
   = "",
  "Enter the username for the user who is running the update script (eg. mc014821): " = "mc014821"
  WITH sinputfile, susername
 SET modify maxvarlen 268435456
 DECLARE g_sblob = vc WITH public, noconstant("")
 DECLARE g_dttmcur = dq8 WITH public, noconstant(cnvtdatetime(curdate,curtime3))
 DECLARE g_duserid = f8 WITH public, noconstant(0.0)
 DECLARE g_ifailedeventcnt = i4 WITH public, noconstant(0)
 DECLARE g_inoupdteventcnt = i4 WITH public, noconstant(0)
 DECLARE stat = i4 WITH public, noconstant(0)
 DECLARE readinputcsv(null) = null WITH protect
 DECLARE processblankdoc(dmdoceventid=f8) = null WITH protect
 DECLARE getdoceventid(deventid=f8) = i4 WITH protect
 DECLARE getactiveblob(ddoceventid=f8) = i2 WITH protect
 DECLARE updateeventserver(ddoceventid=f8) = i2 WITH protect
 DECLARE outputreport(soutput=vc,ireporteventidx=i4,deventid=f8) = null WITH protect
 DECLARE identifyemptybodyelement(null) = i2 WITH protect
 DECLARE getlastnonemptyblob(ddoceventid=f8) = i2 WITH protect
 DECLARE ocf_compress_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",120,"OCFCOMP"))
 DECLARE ocf_no_compress_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",120,"NOCOMP"))
 DECLARE in_error_1_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"IN ERROR"))
 DECLARE in_error_2_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"INERROR"))
 DECLARE in_error_3_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"INERRNOVIEW"))
 DECLARE in_error_4_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"INERRNOMUT"))
 DECLARE event_class_doc_cd = f8 WITH public, constant(uar_get_code_by("MEANING",53,"DOC"))
 DECLARE dd_entry_mode_cd = f8 WITH public, constant(uar_get_code_by("MEANING",29520,"DYNDOC"))
 DECLARE sinputfilename = vc WITH protect, noconstant(build( $SINPUTFILE))
 IF (findfile(sinputfilename)=0)
  CALL echo("*************************************************************************")
  CALL echo(concat("Failed - could not find the file: ",sinputfilename))
  CALL echo("*************************************************************************")
  GO TO exit_script
 ENDIF
 FREE DEFINE rtl3
 DEFINE rtl3 sinputfilename
 SELECT INTO "nl:"
  FROM prsnl author
  WHERE author.username=value(cnvtupper( $SUSERNAME))
  DETAIL
   g_duserid = author.person_id
  WITH nocounter
 ;end select
 IF (g_duserid=0.0)
  CALL echo("*************************************************************************")
  CALL echo(build("Failed - could not find the username in the prsnl table: ",value( $SUSERNAME)))
  CALL echo("*************************************************************************")
  GO TO exit_script
 ENDIF
 DECLARE failed_log_file = vc WITH public, constant(build("cer_temp:dd_failed_to_updt_blank_docs_log",
   format(curdate,"yymmdd;;d"),format(curtime,"hhmm;;m"),".csv"))
 DECLARE no_updt_needed_log_file = vc WITH constant(build("cer_temp:dd_no_updt_needed_blank_docs_log",
   format(curdate,"yymmdd;;d"),format(curtime,"hhmm;;m"),".csv"))
 FREE RECORD dd_event_ids
 RECORD dd_event_ids(
   1 list_ids[*]
     2 mdoc_event_id = f8
 )
 CALL readinputcsv(null)
 DECLARE ieventidx = i4 WITH noconstant(1)
 FOR (ieventidx = 1 TO size(dd_event_ids->list_ids,5))
   CALL processblankdoc(dd_event_ids->list_ids[ieventidx].mdoc_event_id)
 ENDFOR
 COMMIT
 CALL echo("")
 CALL echo(build("   Total number of events: ",size(dd_event_ids->list_ids,5)))
 CALL echo(build("   Total number of successfully updated events: ",((size(dd_event_ids->list_ids,5)
    - g_ifailedeventcnt) - g_inoupdteventcnt)))
 CALL echo(build("   Total number of failed events: ",g_ifailedeventcnt))
 CALL echo(build("   Output file name with location for failed to update events: ",failed_log_file))
 CALL echo(build("   Total number of events that don't need updates: ",g_inoupdteventcnt))
 CALL echo(build("   Output file name with location for no update needed events: ",
   no_updt_needed_log_file))
 CALL echo("")
 SUBROUTINE readinputcsv(null)
  DECLARE ieventcnt = i4 WITH protect, noconstant(0)
  SELECT INTO "nl:"
   FROM rtl3t r
   WHERE r.line > ""
   DETAIL
    IF (mod(ieventcnt,100)=0)
     stat = alterlist(dd_event_ids->list_ids,(ieventcnt+ 100))
    ENDIF
    IF (cnvtreal(piece(r.line,",",1,"notfnd",0)) > 0.0)
     ieventcnt = (ieventcnt+ 1), dd_event_ids->list_ids[ieventcnt].mdoc_event_id = cnvtreal(piece(r
       .line,",",1,"notfnd",0))
    ENDIF
   FOOT REPORT
    IF (ieventcnt > 0)
     stat = alterlist(dd_event_ids->list_ids,ieventcnt)
    ENDIF
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE processblankdoc(dmdoceventid)
   IF (value(dmdoceventid)=0.0)
    CALL echo("Skipping event id of 0.0")
    RETURN
   ENDIF
   DECLARE ddoceventid = f8 WITH protect, noconstant(getdoceventid(dmdoceventid))
   IF (ddoceventid=0.0)
    CALL echo("DOC event id does not exist or is in error")
    CALL echo(build("MDOC event id: ",dmdoceventid))
    SET g_ifailedeventcnt = (g_ifailedeventcnt+ 1)
    CALL outputreport(failed_log_file,g_ifailedeventcnt,value(dd_event_ids->list_ids[ieventidx].
      mdoc_event_id))
    RETURN
   ENDIF
   IF (getactiveblob(ddoceventid)=0)
    CALL echo("Failed to get the XHTML from the BLOB")
    CALL echo(build("Failed to get the XHTML from the BLOB for event id: ",dmdoceventid))
    SET g_ifailedeventcnt = (g_ifailedeventcnt+ 1)
    CALL outputreport(failed_log_file,g_ifailedeventcnt,value(dd_event_ids->list_ids[ieventidx].
      mdoc_event_id))
    RETURN
   ENDIF
   IF (identifyemptybodyelement(null)=0)
    CALL echo(build("No update needed on the XHTML from the BLOB for event id: ",dmdoceventid))
    SET g_inoupdteventcnt = (g_inoupdteventcnt+ 1)
    CALL outputreport(no_updt_needed_log_file,g_inoupdteventcnt,dmdoceventid)
    RETURN
   ENDIF
   IF (findlastnonemptyblob(ddoceventid)=0)
    CALL echo("Failed to get the XHTML from the BLOB")
    CALL echo(build("Failed to get the XHTML from the BLOB for event id: ",dmdoceventid))
    SET g_ifailedeventcnt = (g_ifailedeventcnt+ 1)
    CALL outputreport(failed_log_file,g_ifailedeventcnt,value(dd_event_ids->list_ids[ieventidx].
      mdoc_event_id))
    RETURN
   ENDIF
   IF (updateeventserver(ddoceventid)=0)
    CALL echo(build("Failed to update the XHTML on the ce_blob table via event server for event id: ",
      dmdoceventid))
    SET g_ifailedeventcnt = (g_ifailedeventcnt+ 1)
    CALL outputreport(failed_log_file,g_ifailedeventcnt,value(dd_event_ids->list_ids[ieventidx].
      mdoc_event_id))
   ENDIF
 END ;Subroutine
 SUBROUTINE getdoceventid(dmdoceventid)
   DECLARE ddoceventid = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    FROM clinical_event ce
    WHERE ce.parent_event_id=dmdoceventid
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
     AND ce.event_class_cd=event_class_doc_cd
     AND ce.entry_mode_cd=dd_entry_mode_cd
     AND  NOT (ce.result_status_cd IN (in_error_1_cd, in_error_2_cd, in_error_3_cd, in_error_4_cd))
    ORDER BY ce.parent_event_id, cnvtreal(ce.collating_seq)
    HEAD ce.parent_event_id
     ddoceventid = ce.event_id
    WITH nocounter
   ;end select
   RETURN(ddoceventid)
 END ;Subroutine
 SUBROUTINE findlastnonemptyblob(ddoceventid)
   DECLARE ifoundvalidblob = i2 WITH protect, noconstant(0)
   DECLARE ierror = i2 WITH protect, noconstant(0)
   DECLARE ibloblength = i4 WITH protect, noconstant(0)
   DECLARE sblobcompressed = vc WITH protect, noconstant("")
   SET sblobcompressed = " "
   SET g_sblob = ""
   SELECT INTO "nl:"
    FROM ce_blob c
    PLAN (c
     WHERE c.event_id=ddoceventid
      AND c.valid_until_dt_tm < cnvtdatetime("31-DEC-2100"))
    ORDER BY c.valid_until_dt_tm, c.blob_seq_num
    HEAD c.valid_until_dt_tm
     IF (0=ifoundvalidblob)
      stat = memrealloc(g_sblob,1,build("C",c.blob_length))
     ENDIF
    DETAIL
     IF (0=ifoundvalidblob)
      isearchres = (findstring("ocf_blob",c.blob_contents,(size(trim(c.blob_contents)) - 10)) - 1)
      IF (isearchres < 1)
       isearchres = size(c.blob_contents)
      ENDIF
      sblobcompressed = notrim(concat(notrim(sblobcompressed),notrim(substring(1,isearchres,c
          .blob_contents))))
     ENDIF
    FOOT  c.valid_until_dt_tm
     IF (0=ifoundvalidblob)
      sblobcompressed = concat(notrim(sblobcompressed),"ocf_blob")
      IF (c.compression_cd=ocf_compress_cd)
       stat = uar_ocf_uncompress(sblobcompressed,size(sblobcompressed),g_sblob,size(g_sblob),
        ibloblength)
      ELSEIF (c.compression_cd=ocf_no_compress_cd)
       g_sblob = sblobcompressed
      ELSE
       ierror = 1
      ENDIF
      IF (identifyemptybodyelement(null) != 1)
       ifoundvalidblob = 1
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (ierror=1)
    CALL echo("Unhandled compression code")
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE getactiveblob(ddoceventid)
   DECLARE ierror = i2 WITH protect, noconstant(0)
   DECLARE ibloblength = i4 WITH protect, noconstant(0)
   DECLARE sblobcompressed = vc WITH protect, noconstant("")
   SET ierror = 0
   SET sblobcompressed = " "
   SET g_sblob = ""
   SELECT INTO "nl:"
    FROM ce_blob c
    PLAN (c
     WHERE c.event_id=ddoceventid
      AND c.valid_until_dt_tm=cnvtdatetime("31-DEC-2100"))
    ORDER BY c.event_id, c.blob_seq_num
   ;end select
   SELECT INTO "nl:"
    FROM ce_blob c
    PLAN (c
     WHERE c.event_id=ddoceventid
      AND c.valid_until_dt_tm=cnvtdatetime("31-DEC-2100"))
    ORDER BY c.event_id, c.blob_seq_num
    HEAD c.event_id
     stat = memrealloc(g_sblob,1,build("C",c.blob_length))
    DETAIL
     isearchres = (findstring("ocf_blob",c.blob_contents,(size(trim(c.blob_contents)) - 10)) - 1)
     IF (isearchres < 1)
      isearchres = size(c.blob_contents)
     ENDIF
     sblobcompressed = notrim(concat(notrim(sblobcompressed),notrim(substring(1,isearchres,c
         .blob_contents))))
    FOOT  c.event_id
     sblobcompressed = concat(notrim(sblobcompressed),"ocf_blob")
     IF (c.compression_cd=ocf_compress_cd)
      stat = uar_ocf_uncompress(sblobcompressed,size(sblobcompressed),g_sblob,size(g_sblob),
       ibloblength)
     ELSEIF (c.compression_cd=ocf_no_compress_cd)
      g_sblob = sblobcompressed
     ELSE
      ierror = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (ierror=1)
    CALL echo("Unhandled compression code")
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE updateeventserver(ddoceventid)
   EXECUTE crmrtl
   EXECUTE srvrtl
   DECLARE doc_class_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"DOC"))
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
   DECLARE populateeventstructure(hreq=i4,resultstatuscd=f8,dparenteventid=f8,ddoceventid=f8) = i2
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
   SUBROUTINE populateeventstructure(hreq,resultstatuscd,dparenteventid,ddoceventid)
     DECLARE auth_rest_status = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
     DECLARE modified_rest_status = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED")
      )
     DECLARE action_status_completed = f8 WITH protect, constant(uar_get_code_by("MEANING",103,
       "COMPLETED"))
     DECLARE action_type_modify = f8 WITH protect, constant(uar_get_code_by("MEANING",21,"MODIFY"))
     DECLARE populatemdocrow(hce=i4,dparenteventid=f8) = i2
     DECLARE populatedocrow(hchildevent=i4,dparenteventid=f8,ddoceventid=f8) = i2
     DECLARE addtoeventprsnllist(hreq,personid,actionprsnlid,actiontypecd,actionstatuscd,
      actiondttm) = null WITH protect
     SET srvstat = uar_srvsetshort(hreq,"ensure_type",2)
     SET hce = uar_srvgetstruct(hreq,"clin_event")
     IF (resultstatuscd=auth_rest_status)
      SET srvstat = uar_srvsetdouble(hce,"result_status_cd",modified_rest_status)
     ENDIF
     CALL addtoeventprsnllist(hce,g_duserid,g_duserid,action_type_modify,action_status_completed,
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
     SUBROUTINE populatemdocrow(hce,dparenteventid)
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
     SUBROUTINE populatedocrow(hchildevent,dparenteventid,ddoceventid)
       DECLARE succntypecd = f8 WITH constant(uar_get_code_by("MEANING",63,"FINAL"))
       DECLARE storagecd = f8 WITH constant(uar_get_code_by("MEANING",25,"BLOB"))
       DECLARE formatcd = f8 WITH constant(uar_get_code_by("MEANING",23,"XHTML"))
       SET srvstat = uar_srvsetshort(hchildevent,"ensure_type",2)
       SET srvstat = uar_srvsetdouble(hchildevent,"event_id",ddoceventid)
       IF (dparenteventid=ddoceventid)
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
       ENDIF
       SET hblobitem = uar_srvadditem(hchildevent,"blob_result")
       SET srvstat = uar_srvsetdouble(hblobitem,"succession_type_cd",succntypecd)
       SET srvstat = uar_srvsetdouble(hblobitem,"storage_cd",storagecd)
       SET srvstat = uar_srvsetdouble(hblobitem,"format_cd",formatcd)
       SET hblob = uar_srvadditem(hblobitem,"blob")
       IF (hblob)
        SET srvstat = uar_srvsetdouble(hblob,"compression_cd",ocf_no_compress_cd)
        SET lblobsize = size(g_sblob,1)
        SET srvstat = uar_srvsetasis(hblob,"blob_contents",g_sblob,lblobsize)
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
 SUBROUTINE outputreport(soutput,ireporteventidx,deventid)
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
 SUBROUTINE identifyemptybodyelement(null)
   DECLARE iopenbodypos = i4 WITH protect, constant(findstring("<body>",g_sblob))
   DECLARE iclosebodypos = i4 WITH protect, constant(findstring("</body>",g_sblob,(iopenbodypos+ 6)))
   IF (((iclosebodypos - iopenbodypos) < 9))
    RETURN(1)
   ENDIF
   RETURN(0)
 END ;Subroutine
#exit_script
END GO
