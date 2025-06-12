CREATE PROGRAM ams_dynamic_doc_unlock_by_pt:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Patient" = 0,
  "Documents" = 0
  WITH outdev, person_id, dd_session_id
 IF ( NOT (validate(reply)))
  RECORD reply(
    1 status_data[1]
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "Z"
 RECORD sav(
   1 req[*]
     2 patient_id = f8
     2 unlock_flag = i4
     2 contributions[*]
       3 dd_contribution_id = f8
       3 dd_session_id = f8
       3 ensure_type = i4
 )
 DECLARE err_msg = vc
 DECLARE pt_name = vc
 DECLARE prompt_parser = vc
 DECLARE prog_name = vc WITH constant("ams_dynamic_doc_unlock_by_pt")
 DECLARE run_ind = i2 WITH noconstant(0)
 DECLARE stat_cnt = i2 WITH protect, noconstant(0)
 DECLARE dd_cnt = i4 WITH protect, noconstant(0)
 SUBROUTINE updtdminfo(prog_name)
   DECLARE found = i2 WITH noconstant(0)
   DECLARE info_nbr = i4
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="AMS_TOOLKIT"
     AND d.info_name=prog_name
    DETAIL
     found = 1, info_nbr = (d.info_number+ 1)
    WITH nocounter
   ;end select
   IF (found=0)
    INSERT  FROM dm_info d
     SET d.info_domain = "AMS_TOOLKIT", d.info_name = prog_name, d.info_date = cnvtdatetime(curdate,
       curtime3),
      d.info_number = 1, d.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WITH nocounter
    ;end insert
   ELSE
    UPDATE  FROM dm_info d
     SET d.info_number = info_nbr
     WHERE d.info_domain="AMS_TOOLKIT"
      AND d.info_name=prog_name
     WITH nocounter
    ;end update
   ENDIF
 END ;Subroutine
 SUBROUTINE amsuser(person_id)
   DECLARE user_ind = i2 WITH noconstant(0)
   DECLARE prsnl_cd = f8 WITH constant(uar_get_code_by("MEANING",213,"PRSNL")), protect
   SELECT
    p.person_id
    FROM person_name p
    WHERE (p.person_id=reqinfo->updt_id)
     AND p.name_type_cd=prsnl_cd
     AND p.name_title="Cerner AMS"
    DETAIL
     IF (p.person_id > 0)
      user_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   RETURN(user_ind)
 END ;Subroutine
 DECLARE unlockops(null) = null WITH protect
 SUBROUTINE unlockops(null)
  DECLARE note_cnt = i4 WITH noconstant(size(sav->req,5))
  IF (note_cnt > 0)
   DECLARE contrib_cnt = i4 WITH protect, noconstant(0)
   DECLARE happ = i4 WITH protect, noconstant(0)
   DECLARE htask = i4 WITH protect, noconstant(0)
   DECLARE hstep = i4 WITH protect, noconstant(0)
   DECLARE hrequest = i4 WITH protect, noconstant(0)
   DECLARE hreply = i4 WITH protect, noconstant(0)
   DECLARE hstatus = i4 WITH protect, noconstant(0)
   DECLARE hsubeventstatus = i4 WITH protect, noconstant(0)
   DECLARE stagstatus = vc WITH protect, noconstant("")
   SET ncrmstat = uar_crmbeginapp(3202004,happ)
   SET ncrmstat = uar_crmbegintask(happ,3202004,htask)
   FOR (i = 1 TO note_cnt)
     SET ncrmstat = uar_crmbeginreq(htask,0,969502,hstep)
     SET hrequest = uar_crmgetrequest(hstep)
     SET stat = uar_srvsetdouble(hrequest,"patient_id",sav->req[i].patient_id)
     SET stat = uar_srvsetlong(hrequest,"unlock_flag",sav->req[i].unlock_flag)
     SET contrib_cnt = size(sav->req[i].contributions,5)
     FOR (c = 1 TO contrib_cnt)
       SET hcont = uar_srvadditem(hrequest,"contributions")
       SET stat = uar_srvsetdouble(hcont,"dd_contribution_id",sav->req[i].contributions[c].
        dd_contribution_id)
       SET stat = uar_srvsetdouble(hcont,"dd_session_id",sav->req[i].contributions[c].dd_session_id)
       SET stat = uar_srvsetlong(hcont,"ensure_type",sav->req[i].contributions[c].ensure_type)
     ENDFOR
     SET ncrmstat = uar_crmperform(hstep)
     SET hreply = uar_crmgetreply(hstep)
     SET hstatus = uar_srvgetstruct(hreply,"status_data")
     SET stat_cnt = (stat_cnt+ 1)
     SET stat = alter(reply->status_data,stat_cnt)
     SET reply->status_data[stat_cnt].status = uar_srvgetstringptr(hstatus,"status")
     SET hsubeventstatus = uar_srvgetitem(hstatus,"subeventstatus",0)
     IF ((reply->status_data[stat_cnt].status="S"))
      SET reply->status_data[stat_cnt].subeventstatus.operationname = uar_srvgetstringptr(
       hsubeventstatus,"OperationName")
      SET reply->status_data[stat_cnt].subeventstatus.operationstatus = uar_srvgetstringptr(
       hsubeventstatus,"OperationStatus")
      SET reply->status_data[stat_cnt].subeventstatus.targetobjectname = uar_srvgetstringptr(
       hsubeventstatus,"TargetObjectName")
      SET reply->status_data[stat_cnt].subeventstatus.targetobjectvalue = uar_srvgetstringptr(
       hsubeventstatus,"TargetObjectValue")
     ELSE
      SET stat = alter(reply->status_data,stat_cnt)
      SET reply->status_data[stat_cnt].status = "F"
      SET reply->status_data[stat_cnt].subeventstatus.operationname = uar_srvgetstringptr(
       hsubeventstatus,"OperationName")
      SET reply->status_data[stat_cnt].subeventstatus.operationstatus = uar_srvgetstringptr(
       hsubeventstatus,"OperationStatus")
      SET reply->status_data[stat_cnt].subeventstatus.targetobjectname = uar_srvgetstringptr(
       hsubeventstatus,"TargetObjectName")
      SET reply->status_data[stat_cnt].subeventstatus.targetobjectvalue = uar_srvgetstringptr(
       hsubeventstatus,"TargetObjectValue")
     ENDIF
     CALL uar_srvdestroyhandle(hrequest)
     CALL uar_srvdestroyhandle(hreply)
   ENDFOR
  ELSE
   SET stat_cnt = (stat_cnt+ 1)
   SET stat = alter(reply->status_data,stat_cnt)
   SET reply->status_data[stat_cnt].status = "S"
   SET reply->status_data[stat_cnt].subeventstatus.operationname = "UPDATED"
   SET reply->status_data[stat_cnt].subeventstatus.operationstatus = "S"
   SET reply->status_data[stat_cnt].subeventstatus.targetobjectname = "No update needed"
   SET reply->status_data[stat_cnt].subeventstatus.targetobjectvalue =
   "No locked notes within given parameters"
  ENDIF
 END ;Subroutine
 DECLARE logmsg(mymsg=vc,msglvl=i2(value,2)) = null
 DECLARE logrecord(myrecstruct=vc(ref)) = null
 DECLARE finalizemsgs(outdest=vc(value,""),recsizezflag=i4(value,1)) = null
 DECLARE catcherrors(mymsg=vc) = i2
 DECLARE getreply(null) = vc
 DECLARE geterrorcount(null) = i4
 DECLARE getcodewithcheck(type=vc,code_set=i4(value,0),expression=vc(value,""),msglvl=i2(value,2)) =
 f8
 DECLARE setreply(mystat=vc) = null
 DECLARE populatesubeventstatus(errorcnt=i4(value),operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value)) = i2
 DECLARE writemlgmsg(msg=vc,lvl=i2) = null
 DECLARE ccps_json = i2 WITH protect, constant(0)
 DECLARE ccps_xml = i2 WITH protect, constant(1)
 DECLARE ccps_rec_listing = i2 WITH protect, constant(2)
 DECLARE ccps_info_domain = vc WITH protect, constant("CCPS_SCRIPT_LOGGING")
 DECLARE ccps_none_ind = i2 WITH protect, constant(0)
 DECLARE ccps_file_ind = i2 WITH protect, constant(1)
 DECLARE ccps_msgview_ind = i2 WITH protect, constant(2)
 DECLARE ccps_listing_ind = i2 WITH protect, constant(3)
 DECLARE ccps_log_error = i2 WITH protect, constant(0)
 DECLARE ccps_log_audit = i2 WITH protect, constant(2)
 DECLARE ccps_error_disp = vc WITH protect, noconstant("ERROR")
 DECLARE ccps_audit_disp = vc WITH protect, noconstant("AUDIT")
 DECLARE ccps_delim1 = vc WITH protect, noconstant("*")
 DECLARE ccps_delim2 = vc WITH protect, noconstant(";")
 DECLARE prev_ccps_delim1 = vc WITH protect, noconstant(":")
 DECLARE prev_ccps_delim2 = vc WITH protect, noconstant(";")
 DECLARE ccps_serrmsg = vc WITH protect, noconstant(fillstring(132," "))
 DECLARE ccps_ierrcode = i4 WITH protect, noconstant(error(ccps_serrmsg,1))
 EXECUTE msgrtl
 IF ( NOT (validate(debug_values)))
  RECORD debug_values(
    1 log_program_name = vc
    1 log_file_dest = vc
    1 inactive_dt_tm = vc
    1 log_level = i2
    1 log_level_override = i2
    1 logging_on = i2
    1 rec_format = i2
    1 suppress_rec = i2
    1 suppress_msg = i2
    1 debug_method = i4
  ) WITH protect
  SET debug_values->logging_on = false
  SET debug_values->log_program_name = curprog
 ENDIF
 IF ( NOT (validate(ccps_log)))
  RECORD ccps_log(
    1 ecnt = i4
    1 cnt = i4
    1 qual[*]
      2 msg = vc
      2 msg_type_id = i4
      2 msg_type_display = vc
  ) WITH protect
 ENDIF
 IF ( NOT (validate(frec)))
  RECORD frec(
    1 file_desc = i4
    1 file_offset = i4
    1 file_dir = i4
    1 file_name = vc
    1 file_buf = vc
  ) WITH protect
 ENDIF
 IF ( NOT (validate(reply)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 CALL setreply("F")
 SELECT INTO "nl:"
  FROM dm_info dm
  PLAN (dm
   WHERE dm.info_domain=ccps_info_domain
    AND (dm.info_name=debug_values->log_program_name)
    AND dm.info_date >= cnvtdatetime(curdate,curtime3))
  ORDER BY dm.info_name
  HEAD dm.info_name
   entity_cnt = 0, component_cnt = 0, entity = trim(piece(dm.info_char,",",(entity_cnt+ 1),
     "Not Found"),3),
   component = fillstring(4000," ")
   WHILE (component != "Not Found")
     component_cnt = (component_cnt+ 1)
     IF (findstring(ccps_delim2,entity,1)=0)
      component = trim(piece(entity,prev_ccps_delim2,component_cnt,"Not Found"),3), component_head =
      trim(piece(cnvtlower(component),prev_ccps_delim1,1,"Not Found"),3), component_value = trim(
       piece(component,prev_ccps_delim1,2,"Not Found"),3)
     ELSE
      component = trim(piece(entity,ccps_delim2,component_cnt,"Not Found"),3), component_head = trim(
       piece(cnvtlower(component),ccps_delim1,1,"Not Found"),3), component_value = trim(piece(
        component,ccps_delim1,2,"Not Found"),3)
     ENDIF
     CASE (component_head)
      OF "program":
       debug_values->log_program_name = component_value
      OF "debug_method":
       IF (component_value="None")
        debug_values->debug_method = ccps_none_ind
       ELSEIF (component_value="File")
        debug_values->debug_method = ccps_file_ind
       ELSEIF (component_value="Message View")
        debug_values->debug_method = ccps_msgview_ind
       ELSEIF (component_value="Listing")
        debug_values->debug_method = ccps_listing_ind
       ENDIF
      OF "file_name":
       debug_values->log_file_dest = component_value
      OF "inactive_dt_tm":
       debug_values->inactive_dt_tm = component_value
      OF "rec_type":
       debug_values->rec_format = cnvtint(component_value)
      OF "suppress_rec":
       debug_values->suppress_rec = cnvtint(component_value)
      OF "suppress_msg":
       debug_values->suppress_msg = cnvtint(component_value)
     ENDCASE
   ENDWHILE
   IF ((debug_values->debug_method != ccps_none_ind))
    debug_values->logging_on = true
   ELSE
    debug_values->logging_on = false
   ENDIF
  FOOT  dm.info_name
   null
  WITH nocounter
 ;end select
 IF (validate(ccps_debug))
  IF ( NOT (validate(ccps_file)))
   SET debug_values->log_file_dest = build(debug_values->log_program_name,"_DBG.dat")
  ELSE
   SET debug_values->log_file_dest = ccps_file
  ENDIF
  IF ( NOT (validate(ccps_rec_format)))
   IF (ccps_debug != ccps_listing_ind)
    SET debug_values->rec_format = ccps_json
   ELSE
    SET debug_values->rec_format = ccps_rec_listing
   ENDIF
  ELSE
   IF (ccps_rec_format=ccps_xml)
    SET debug_values->rec_format = ccps_xml
   ELSEIF (ccps_rec_format=ccps_json)
    SET debug_values->rec_format = ccps_json
   ELSE
    SET debug_values->rec_format = ccps_rec_listing
   ENDIF
  ENDIF
  IF ( NOT (validate(ccps_suppress_rec)))
   SET debug_values->suppress_rec = false
  ELSE
   IF (ccps_suppress_rec=true)
    SET debug_values->suppress_rec = true
   ELSE
    SET debug_values->suppress_rec = false
   ENDIF
  ENDIF
  IF ( NOT (validate(ccps_suppress_msg)))
   SET debug_values->suppress_msg = false
  ELSE
   IF (ccps_suppress_msg=true)
    SET debug_values->suppress_msg = true
   ELSE
    SET debug_values->suppress_msg = false
   ENDIF
  ENDIF
  CASE (ccps_debug)
   OF ccps_none_ind:
    SET debug_values->debug_method = ccps_none_ind
    SET debug_values->logging_on = false
   OF ccps_file_ind:
    SET debug_values->debug_method = ccps_file_ind
    SET debug_values->logging_on = true
   OF ccps_msgview_ind:
    SET debug_values->debug_method = ccps_msgview_ind
    SET debug_values->logging_on = true
   OF ccps_listing_ind:
    SET debug_values->debug_method = ccps_listing_ind
    SET debug_values->logging_on = true
  ENDCASE
 ENDIF
 IF (debug_values->logging_on)
  CALL echo("****************************")
  CALL echo("*** Logging is turned ON ***")
  CALL echo("****************************")
  CASE (debug_values->debug_method)
   OF ccps_file_ind:
    CALL echo(build("*** Will write to file: ",debug_values->log_file_dest,"***"))
   OF ccps_msgview_ind:
    CALL echo("*****************************")
    CALL echo("*** Will write to MsgView ***")
    CALL echo("*****************************")
   OF ccps_listing_ind:
    CALL echo("*********************************")
    CALL echo("*** Will write to the listing ***")
    CALL echo("*********************************")
  ENDCASE
  IF ((debug_values->suppress_rec=true))
   CALL echo("****************************")
   CALL echo("***  Suppress Rec is ON  ***")
   CALL echo("****************************")
  ENDIF
  IF ((debug_values->suppress_msg=true))
   CALL echo("****************************")
   CALL echo("***  Suppress Msg is ON  ***")
   CALL echo("****************************")
  ENDIF
 ELSE
  CALL echo("*****************************")
  CALL echo("*** Logging is turned OFF ***")
  CALL echo("*****************************")
 ENDIF
 SUBROUTINE logmsg(mymsg,msglvl)
   DECLARE seek_retval = i4 WITH private, noconstant
   DECLARE filelen = i4 WITH private, noconstant
   DECLARE write_stat = i2 WITH private, noconstant
   DECLARE imsglvl = i2 WITH private, noconstant
   DECLARE smsglvl = vc WITH private, noconstant
   DECLARE slogtext = vc WITH private, noconstant("")
   DECLARE start_char = i4 WITH private, noconstant
   SET imsglvl = msglvl
   SET slogtext = mymsg
   IF ((((debug_values->suppress_msg=false)) OR ((debug_values->suppress_msg=true)
    AND msglvl=ccps_log_error)) )
    IF (((imsglvl=ccps_log_error) OR ((debug_values->logging_on=true))) )
     SET ccps_log->cnt = (ccps_log->cnt+ 1)
     IF (msglvl=ccps_log_error)
      SET ccps_log->ecnt = (ccps_log->ecnt+ 1)
     ENDIF
     SET stat = alterlist(ccps_log->qual,ccps_log->cnt)
     SET ccps_log->qual[ccps_log->cnt].msg = trim(mymsg,3)
     SET ccps_log->qual[ccps_log->cnt].msg_type_id = msglvl
     IF (msglvl=ccps_log_error)
      SET ccps_log->qual[ccps_log->cnt].msg_type_display = ccps_error_disp
     ELSE
      SET ccps_log->qual[ccps_log->cnt].msg_type_display = ccps_audit_disp
     ENDIF
    ENDIF
    CASE (imsglvl)
     OF ccps_log_error:
      SET smsglvl = "Error"
     OF ccps_log_audit:
      SET smsglvl = "Audit"
    ENDCASE
    IF (imsglvl=ccps_log_error)
     CALL writemlgmsg(slogtext,imsglvl)
     CALL populatesubeventstatus(ccps_log->ecnt,ccps_error_disp,"F",build(curprog),trim(mymsg,3))
    ENDIF
    IF ((debug_values->logging_on=true))
     IF ((debug_values->debug_method=ccps_msgview_ind)
      AND msglvl != ccps_log_error)
      CALL writemlgmsg(slogtext,imsglvl)
     ELSEIF ((debug_values->debug_method=ccps_file_ind))
      SET frec->file_name = debug_values->log_file_dest
      SET frec->file_buf = "ab"
      SET stat = cclio("OPEN",frec)
      SET frec->file_dir = 2
      SET seek_retval = cclio("SEEK",frec)
      SET filelen = cclio("TELL",frec)
      SET frec->file_offset = filelen
      SET frec->file_buf = build2(format(cnvtdatetime(curdate,curtime3),"mm/dd/yyyy hh:mm:ss;;d"),
       fillstring(5," "),"{",smsglvl,"}",
       fillstring(5," "),mymsg,char(13),char(10))
      SET write_stat = cclio("WRITE",frec)
      SET stat = cclio("CLOSE",frec)
     ELSEIF ((debug_values->debug_method=ccps_listing_ind))
      CALL echo(build2("*** ",format(cnvtdatetime(curdate,curtime3),"mm/dd/yyyy hh:mm:ss;;d"),
        fillstring(5," "),"{",smsglvl,
        "}",fillstring(5," "),mymsg))
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE logrecord(myrecstruct)
   IF ((debug_values->suppress_rec=false))
    DECLARE smsgtype = vc WITH private, noconstant
    DECLARE write_stat = i4 WITH private, noconstant
    SET smsgtype = "Audit"
    IF ((debug_values->logging_on=true))
     IF ((debug_values->debug_method=ccps_file_ind))
      SET frec->file_name = debug_values->log_file_dest
      SET frec->file_buf = "ab"
      SET stat = cclio("OPEN",frec)
      SET frec->file_dir = 2
      SET seek_retval = cclio("SEEK",frec)
      SET filelen = cclio("TELL",frec)
      SET frec->file_offset = filelen
      SET frec->file_buf = build2(format(cnvtdatetime(curdate,curtime3),"mm/dd/yyyy hh:mm:ss;;d"),
       fillstring(5," "),"{",smsgtype,"}",
       fillstring(5," "))
      IF ((debug_values->rec_format=ccps_xml))
       CALL echoxml(myrecstruct,debug_values->log_file_dest,1)
      ELSEIF ((debug_values->rec_format=ccps_json))
       CALL echojson(myrecstruct,debug_values->log_file_dest,1)
      ELSE
       CALL echorecord(myrecstruct,debug_values->log_file_dest,1)
      ENDIF
      SET frec->file_buf = build(frec->file_buf,char(13),char(10))
      SET write_stat = cclio("WRITE",frec)
      SET stat = cclio("CLOSE",frec)
     ELSEIF ((debug_values->debug_method=ccps_listing_ind))
      CALL echo(build2("*** ",format(cnvtdatetime(curdate,curtime3),"mm/dd/yyyy hh:mm:ss;;d"),
        fillstring(5," "),"{",smsgtype,
        "}",fillstring(5," ")))
      IF ((debug_values->rec_format=ccps_xml))
       CALL echoxml(myrecstruct)
      ELSEIF ((debug_values->rec_format=ccps_json))
       CALL echojson(myrecstruct)
      ELSE
       CALL echorecord(myrecstruct)
      ENDIF
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE catcherrors(mymsg)
   DECLARE ccps_ierroroccurred = i2 WITH private, noconstant(0)
   SET ccps_ierrcode = error(ccps_serrmsg,0)
   WHILE (ccps_ierrcode > 0
    AND (ccps_log->ecnt < 50))
     SET ccps_ierroroccurred = 1
     CALL logmsg(trim(build2(mymsg," -- ",trim(ccps_serrmsg,3)),3),ccps_log_error)
     SET ccps_ierrcode = error(ccps_serrmsg,1)
   ENDWHILE
   RETURN(ccps_ierroroccurred)
 END ;Subroutine
 SUBROUTINE geterrorcount(null)
   RETURN(ccps_log->ecnt)
 END ;Subroutine
 SUBROUTINE finalizemsgs(outdest,recsizezflag)
   DECLARE errcnt = i4 WITH noconstant, private
   SET stat = catcherrors("Performing final check for errors...")
   SET errcnt = geterrorcount(null)
   IF (errcnt > 0)
    CALL setreply("F")
   ELSEIF (recsizezflag=0)
    CALL setreply("Z")
   ELSE
    CALL setreply("S")
   ENDIF
   IF ((ccps_log->ecnt > 0)
    AND cnvtstring(outdest) != "")
    SELECT INTO value(outdest)
     FROM (dummyt d  WITH seq = ccps_log->cnt)
     PLAN (d
      WHERE (ccps_log->qual[d.seq].msg_type_id=ccps_log_error))
     HEAD REPORT
      CALL print(build2(
       "*** Errors have occurred in the CCL Script.  Please contact your System Administrator ",
       "and/or Cerner for assistance with resolving the issue. ***",char(13),char(10),char(13),
       char(10)))
     DETAIL
      CALL print(ccps_log->qual[d.seq].msg), row + 1
     FOOT REPORT
      null
     WITH nocounter, maxcol = 500
    ;end select
   ENDIF
   IF ((debug_values->debug_method=ccps_listing_ind))
    CALL echo("********************************")
    CALL echo("*** Printing Logging Summary ***")
    CALL echo("********************************")
    CALL logrecord(ccps_log)
    CALL logrecord(reply)
   ENDIF
 END ;Subroutine
 SUBROUTINE setreply(mystat)
   IF (validate(reply->status_data.status)=1)
    SET reply->status_data.status = mystat
   ENDIF
 END ;Subroutine
 SUBROUTINE getreply(null)
   IF (validate(reply->status_data.status)=1)
    RETURN(reply->status_data.status)
   ELSE
    RETURN("Z")
   ENDIF
 END ;Subroutine
 SUBROUTINE getcodewithcheck(type,code_set,expression,msglvl)
   DECLARE cki_flag = i2 WITH private, noconstant(0)
   IF (code_set=0)
    DECLARE tmp_code_value = f8 WITH private, noconstant(uar_get_code_by_cki(type))
    SET cki_flag = 1
   ELSE
    DECLARE tmp_code_value = f8 WITH private, noconstant(uar_get_code_by(type,code_set,expression))
   ENDIF
   IF (tmp_code_value <= 0)
    IF (cki_flag=0)
     CALL logmsg(build2("*** ! Code value from code set ",trim(cnvtstring(code_set),3)," with ",type,
       " of ",
       expression," was not found !"),msglvl)
    ELSE
     CALL logmsg(build2("*** ! Code value with CKI of ",type," was not found !"),msglvl)
    ENDIF
   ENDIF
   RETURN(tmp_code_value)
 END ;Subroutine
 SUBROUTINE populatesubeventstatus(errorcnt,operationname,operationstatus,targetobjectname,
  targetobjectvalue)
   DECLARE ccps_isubeventcnt = i4 WITH protect, noconstant(0)
   DECLARE ccps_isubeventsize = i4 WITH protect, noconstant(0)
   IF (validate(reply->ops_event)=1
    AND errorcnt=1)
    SET reply->ops_event = targetobjectvalue
   ENDIF
   IF (validate(reply->status_data.status,"-1") != "-1")
    SET ccps_isubeventcnt = size(reply->status_data.subeventstatus,5)
    IF (ccps_isubeventcnt > 0)
     SET ccps_isubeventsize = size(trim(reply->status_data.subeventstatus[ccps_isubeventcnt].
       operationname))
     SET ccps_isubeventsize = (ccps_isubeventsize+ size(trim(reply->status_data.subeventstatus[
       ccps_isubeventcnt].operationstatus)))
     SET ccps_isubeventsize = (ccps_isubeventsize+ size(trim(reply->status_data.subeventstatus[
       ccps_isubeventcnt].targetobjectname)))
     SET ccps_isubeventsize = (ccps_isubeventsize+ size(trim(reply->status_data.subeventstatus[
       ccps_isubeventcnt].targetobjectvalue)))
    ENDIF
    IF (ccps_isubeventsize > 0)
     SET ccps_isubeventcnt = (ccps_isubeventcnt+ 1)
     SET iloggingstat = alter(reply->status_data.subeventstatus,ccps_isubeventcnt)
    ENDIF
    IF (ccps_isubeventcnt > 0)
     SET reply->status_data.subeventstatus[ccps_isubeventcnt].operationname = substring(1,25,
      operationname)
     SET reply->status_data.subeventstatus[ccps_isubeventcnt].operationstatus = substring(1,1,
      operationstatus)
     SET reply->status_data.subeventstatus[ccps_isubeventcnt].targetobjectname = substring(1,25,
      targetobjectname)
     SET reply->status_data.subeventstatus[ccps_isubeventcnt].targetobjectvalue = targetobjectvalue
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE writemlgmsg(msg,lvl)
   DECLARE sys_handle = i4 WITH noconstant(0), private
   DECLARE sys_status = i4 WITH noconstant(0), private
   CALL uar_syscreatehandle(sys_handle,sys_status)
   IF (sys_handle > 0)
    CALL uar_msgsetlevel(sys_handle,lvl)
    CALL uar_sysevent(sys_handle,lvl,nullterm(debug_values->log_program_name),nullterm(msg))
    CALL uar_sysdestroyhandle(sys_handle)
   ENDIF
 END ;Subroutine
 SET lastmod = "003 07/21/15 md8090"
 IF ( NOT (validate(list_in)))
  DECLARE list_in = i2 WITH protect, constant(1)
 ENDIF
 IF ( NOT (validate(list_not_in)))
  DECLARE list_not_in = i2 WITH protect, constant(2)
 ENDIF
 IF ( NOT (validate(ccps_records)))
  RECORD ccps_records(
    1 cnt = i4
    1 list[*]
      2 name = vc
    1 num = i4
  ) WITH persistscript
 ENDIF
 DECLARE ispromptany(which_prompt=i2) = i2
 SUBROUTINE ispromptany(which_prompt)
   DECLARE prompt_reflect = vc WITH private, noconstant(reflect(parameter(which_prompt,0)))
   DECLARE return_val = i2 WITH private, noconstant(0)
   IF (prompt_reflect="C1")
    IF (ichar(value(parameter(which_prompt,1)))=42)
     SET return_val = 1
    ENDIF
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 DECLARE ispromptlist(which_prompt=i2) = i2
 SUBROUTINE ispromptlist(which_prompt)
   DECLARE prompt_reflect = vc WITH private, noconstant(reflect(parameter(which_prompt,0)))
   DECLARE return_val = i2 WITH private, noconstant(0)
   IF (substring(1,1,prompt_reflect)="L")
    SET return_val = 1
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 DECLARE ispromptsingle(which_prompt=i2) = i2
 SUBROUTINE ispromptsingle(which_prompt)
   DECLARE prompt_reflect = vc WITH private, noconstant(reflect(parameter(which_prompt,0)))
   DECLARE return_val = i2 WITH private, noconstant(0)
   IF (textlen(trim(prompt_reflect,3)) > 0
    AND  NOT (ispromptany(which_prompt))
    AND  NOT (ispromptlist(which_prompt)))
    SET return_val = 1
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 DECLARE ispromptempty(which_prompt=i2) = i2
 SUBROUTINE ispromptempty(which_prompt)
   DECLARE prompt_reflect = vc WITH private, noconstant(reflect(parameter(which_prompt,0)))
   DECLARE return_val = i2 WITH private, noconstant(0)
   IF (textlen(trim(prompt_reflect,3))=0)
    SET return_val = 1
   ELSEIF (ispromptsingle(which_prompt))
    IF (substring(1,1,prompt_reflect)="C")
     IF (textlen(trim(value(parameter(which_prompt,0)),3))=0)
      SET return_val = 1
     ENDIF
    ELSE
     IF (cnvtreal(value(parameter(which_prompt,1)))=0)
      SET return_val = 1
     ENDIF
    ENDIF
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 DECLARE getpromptlist(which_prompt=i2,which_column=vc,which_option=i2(value,list_in)) = vc
 SUBROUTINE getpromptlist(which_prompt,which_column,which_option)
   DECLARE prompt_reflect = vc WITH noconstant(reflect(parameter(which_prompt,0))), private
   DECLARE count = i4 WITH noconstant(0), private
   DECLARE item_num = i4 WITH noconstant(0), private
   DECLARE option_str = vc WITH noconstant(""), private
   DECLARE return_val = vc WITH noconstant("0=1"), private
   IF (which_option=list_not_in)
    SET option_str = " NOT IN ("
   ELSE
    SET option_str = " IN ("
   ENDIF
   IF (ispromptany(which_prompt))
    SET return_val = "1=1"
   ELSEIF (ispromptlist(which_prompt))
    SET count = cnvtint(substring(2,(textlen(prompt_reflect) - 1),prompt_reflect))
   ELSEIF (ispromptsingle(which_prompt))
    SET count = 1
   ENDIF
   IF (count > 0)
    SET return_val = concat("(",which_column,option_str)
    FOR (item_num = 1 TO count)
     IF (mod(item_num,1000)=1
      AND item_num > 1)
      SET return_val = replace(return_val,",",")",2)
      SET return_val = concat(return_val," or ",which_column,option_str)
     ENDIF
     IF (substring(1,1,reflect(parameter(which_prompt,item_num)))="C")
      SET return_val = concat(return_val,"'",value(parameter(which_prompt,item_num)),"'",",")
     ELSE
      SET return_val = build(return_val,value(parameter(which_prompt,item_num)),",")
     ENDIF
    ENDFOR
    SET return_val = replace(return_val,",",")",2)
    SET return_val = concat(return_val,")")
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 DECLARE getpromptexpand(which_prompt=i2,which_column=vc,which_option=i2(value,list_in)) = vc
 SUBROUTINE getpromptexpand(which_prompt,which_column,which_option)
   DECLARE record_name = vc WITH private, noconstant(" ")
   DECLARE return_val = vc WITH private, noconstant("0=1")
   IF (ispromptany(which_prompt))
    SET return_val = "1=1"
   ELSEIF (((ispromptlist(which_prompt)) OR (ispromptsingle(which_prompt))) )
    SET record_name = getpromptrecord(which_prompt,which_column)
    IF (textlen(trim(record_name,3)) > 0)
     SET return_val = createexpandparser(which_column,record_name,which_option)
    ENDIF
   ENDIF
   CALL logmsg(concat("GetPromptExpand: return value = ",return_val))
   RETURN(return_val)
 END ;Subroutine
 DECLARE getpromptrecord(which_prompt=i2,which_rec=vc) = vc
 SUBROUTINE getpromptrecord(which_prompt,which_rec)
   DECLARE record_name = vc WITH private, noconstant(" ")
   DECLARE prompt_reflect = vc WITH private, noconstant(reflect(parameter(which_prompt,0))), private
   DECLARE count = i4 WITH private, noconstant(0)
   DECLARE item_num = i4 WITH private, noconstant(0)
   DECLARE idx = i4 WITH private, noconstant(0)
   DECLARE data_type = vc WITH private, noconstant(" ")
   DECLARE alias_parser = vc WITH private, noconstant(" ")
   DECLARE cnt_parser = vc WITH private, noconstant(" ")
   DECLARE alterlist_parser = vc WITH private, noconstant(" ")
   DECLARE data_type_parser = vc WITH private, noconstant(" ")
   DECLARE return_val = vc WITH private, noconstant(" ")
   IF ((( NOT (ispromptany(which_prompt))) OR ( NOT (ispromptempty(which_prompt)))) )
    SET record_name = createrecord(which_rec)
    IF (textlen(trim(record_name,3)) > 0)
     IF (ispromptlist(which_prompt))
      SET count = cnvtint(substring(2,(textlen(prompt_reflect) - 1),prompt_reflect))
     ELSEIF (ispromptsingle(which_prompt))
      SET count = 1
     ENDIF
     IF (count > 0)
      SET alias_parser = concat("set curalias = which_rec_alias ",record_name,"->list[idx] go")
      SET cnt_parser = build2("set ",record_name,"->cnt = ",count," go")
      SET alterlist_parser = build2("set stat = alterlist(",record_name,"->list,",record_name,
       "->cnt) go")
      SET data_type = cnvtupper(substring(1,1,reflect(parameter(which_prompt,1))))
      SET data_type_parser = concat("set ",record_name,"->data_type = '",data_type,"' go")
      CALL parser(alias_parser)
      CALL parser(cnt_parser)
      CALL parser(alterlist_parser)
      CALL parser(data_type_parser)
      CALL logmsg(concat("GetPromptRecord: alias_parser = ",alias_parser))
      CALL logmsg(concat("GetPromptRecord: cnt_parser = ",cnt_parser))
      CALL logmsg(concat("GetPromptRecord: alterlist_parser = ",alterlist_parser))
      CALL logmsg(concat("GetPromptRecord: data_type_parser = ",data_type_parser))
      FOR (item_num = 1 TO count)
       SET idx = (idx+ 1)
       CASE (data_type)
        OF "I":
         SET which_rec_alias->number = cnvtreal(value(parameter(which_prompt,item_num)))
        OF "F":
         SET which_rec_alias->number = cnvtreal(value(parameter(which_prompt,item_num)))
        OF "C":
         SET which_rec_alias->string = value(parameter(which_prompt,item_num))
       ENDCASE
      ENDFOR
      SET cnt_parser = concat(record_name,"->cnt")
      IF (validate(parser(cnt_parser),0) > 0)
       SET return_val = record_name
      ELSE
       CALL cclexception(999,"E","GetPromptRecord: failed to add the prompt values to the new record"
        )
      ENDIF
      SET alias_parser = concat("set curalias which_rec_alias off go")
      CALL parser(alias_parser)
      CALL logmsg(concat("GetPromptRecord: cnt_parser = ",cnt_parser))
      CALL logmsg(concat("GetPromptRecord: alias_parser = ",alias_parser))
     ELSE
      CALL logmsg("GetPromptRecord: zero records found")
     ENDIF
    ENDIF
   ELSE
    CALL logmsg("GetPromptRecord: prompt value is any(*) or empty")
   ENDIF
   IF (textlen(trim(record_name,3)) > 0)
    CALL parser(concat("call logRecord(",record_name,") go"))
   ENDIF
   CALL logmsg(concat("GetPromptRecord: return value = ",return_val))
   CALL catcherrors("An error occurred in GetPromptRecord()")
   RETURN(return_val)
 END ;Subroutine
 DECLARE createrecord(which_rec=vc(value,"")) = vc
 SUBROUTINE createrecord(which_rec)
   DECLARE record_name = vc WITH private, noconstant(" ")
   DECLARE record_parser = vc WITH private, noconstant(" ")
   DECLARE new_record_ind = i2 WITH private, noconstant(0)
   DECLARE return_val = vc WITH private, noconstant(" ")
   IF (textlen(trim(which_rec,3)) > 0)
    IF (findstring(".",which_rec,1,0) > 0)
     SET record_name = concat("ccps_",trim(which_rec,3),"_rec")
    ELSE
     SET record_name = trim(which_rec,3)
    ENDIF
   ELSE
    SET record_name = build("ccps_temp_",(ccps_records->cnt+ 1),"_rec")
   ENDIF
   SET record_name = concat(trim(replace(record_name,concat(
       'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890 !"#$%&',
       "'()*+,-./:;<=>?@[\]^_`{|}~"),concat(
       "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_______",
       "__________________________"),3),3))
   CALL logmsg(concat("CreateRecord: record_name = ",record_name))
   IF ( NOT (validate(parser(record_name))))
    SET record_parser = concat("record ",record_name," (1 cnt = i4",
     " 1 list[*] 2 string = vc 2 number = f8"," 1 data_type = c1 1 num = i4)",
     " with persistscript go")
    CALL logmsg(concat("CreateRecord: record parser = ",record_parser))
    CALL parser(record_parser)
    IF (validate(parser(record_name)))
     SET return_val = record_name
     SET ccps_records->cnt = (ccps_records->cnt+ 1)
     SET stat = alterlist(ccps_records->list,ccps_records->cnt)
     SET ccps_records->list[ccps_records->cnt].name = record_name
    ELSE
     CALL cclexception(999,"E","CreateRecord: failed to create record")
    ENDIF
   ELSE
    CALL cclexception(999,"E","CreateRecord: record already exists")
    CALL parser(concat("call logRecord(",record_name,") go"))
   ENDIF
   CALL logrecord(ccps_records)
   CALL logmsg(concat("CreateRecord: return value = ",return_val))
   CALL catcherrors("An error occurred in CreateRecord()")
   RETURN(return_val)
 END ;Subroutine
 DECLARE createexpandparser(which_column=vc,which_rec=vc,which_option=i2(value,list_in)) = vc
 SUBROUTINE createexpandparser(which_column,which_rec,which_option)
   DECLARE return_val = vc WITH private, noconstant("0=1")
   DECLARE option_str = vc WITH private, noconstant(" ")
   DECLARE record_member = vc WITH private, noconstant(" ")
   DECLARE data_type = vc WITH private, noconstant(" ")
   DECLARE data_type_parser = vc WITH private, noconstant(" ")
   IF (validate(parser(which_rec)))
    IF (which_option=list_not_in)
     SET option_str = " NOT"
    ENDIF
    SET data_type_parser = concat("set data_type = ",which_rec,"->data_type go")
    CALL parser(data_type_parser)
    CASE (data_type)
     OF "I":
      SET record_member = "number"
     OF "F":
      SET record_member = "number"
     OF "C":
      SET record_member = "string"
    ENDCASE
    SET return_val = build(option_str," expand(",which_rec,"->num",",",
     "1,",which_rec,"->cnt,",which_column,",",
     which_rec,"->list[",which_rec,"->num].",record_member,
     ")")
   ELSE
    CALL logmsg(concat("CreateExpandParser: ",which_rec," does not exist"))
   ENDIF
   CALL logmsg(concat("CreateExpandParser: return value = ",return_val))
   CALL catcherrors("An error occurred in CreateExpandParser()")
   RETURN(return_val)
 END ;Subroutine
 CALL logmsg("sc_cps_get_prompt_list 007 11/02/2012 ML011047")
 SET run_ind = amsuser(reqinfo->updt_id)
 IF (run_ind=1
  AND ispromptempty(3)=0)
  DECLARE last_mdoc_event_id = f8
  DECLARE contrib_cnt = i4
  SET prompt_parser = getpromptlist(3,"dd_session_id",1)
  IF (prompt_parser="1=1")
   SELECT INTO "nl:"
    FROM dd_contribution ddc,
     dd_session dds
    PLAN (ddc
     WHERE (ddc.person_id= $PERSON_ID))
     JOIN (dds
     WHERE ddc.dd_contribution_id=dds.parent_entity_id
      AND dds.parent_entity_name="DD_CONTRIBUTION")
    ORDER BY dds.dd_session_id
    HEAD REPORT
     prompt_parser = "dd_session_id IN ("
    HEAD dds.dd_session_id
     prompt_parser = concat(prompt_parser,cnvtstring(dds.dd_session_id),",")
     IF (last_mdoc_event_id != ddc.mdoc_event_id)
      dd_cnt = (dd_cnt+ 1), last_mdoc_event_id = ddc.mdoc_event_id, contrib_cnt = 0
     ENDIF
     contrib_cnt = (contrib_cnt+ 1)
     IF (contrib_cnt=1)
      stat = alterlist(sav->req,dd_cnt), sav->req[dd_cnt].patient_id = ddc.person_id, sav->req[dd_cnt
      ].unlock_flag = 1
     ENDIF
     stat = alterlist(sav->req[dd_cnt].contributions,contrib_cnt), sav->req[dd_cnt].contributions[
     contrib_cnt].dd_contribution_id = ddc.dd_contribution_id, sav->req[dd_cnt].contributions[
     contrib_cnt].dd_session_id = dds.dd_session_id,
     sav->req[dd_cnt].contributions[contrib_cnt].ensure_type = 0
    FOOT  dds.dd_session_id
     null
    FOOT REPORT
     prompt_parser = concat(substring(1,(size(prompt_parser,1) - 1),prompt_parser),")")
    WITH nocounter
   ;end select
  ELSE
   SET prompt_parser = replace(prompt_parser,"(dd_session_id","dds.dd_session_id",1)
   SET prompt_parser = replace(prompt_parser,"))",")",2)
   SELECT INTO "nl:"
    FROM dd_contribution ddc,
     dd_session dds
    PLAN (ddc
     WHERE (ddc.person_id= $PERSON_ID))
     JOIN (dds
     WHERE parser(prompt_parser)
      AND ddc.dd_contribution_id=dds.parent_entity_id
      AND dds.parent_entity_name="DD_CONTRIBUTION")
    ORDER BY ddc.mdoc_event_id
    HEAD dds.dd_session_id
     null
     IF (last_mdoc_event_id != ddc.mdoc_event_id)
      dd_cnt = (dd_cnt+ 1), last_mdoc_event_id = ddc.mdoc_event_id, contrib_cnt = 0
     ENDIF
     contrib_cnt = (contrib_cnt+ 1)
     IF (contrib_cnt=1)
      stat = alterlist(sav->req,dd_cnt), sav->req[dd_cnt].patient_id = ddc.person_id, sav->req[dd_cnt
      ].unlock_flag = 1
     ENDIF
     stat = alterlist(sav->req[dd_cnt].contributions,contrib_cnt), sav->req[dd_cnt].contributions[
     contrib_cnt].dd_contribution_id = ddc.dd_contribution_id, sav->req[dd_cnt].contributions[
     contrib_cnt].dd_session_id = dds.dd_session_id,
     sav->req[dd_cnt].contributions[contrib_cnt].ensure_type = 0
    WITH nocounter
   ;end select
  ENDIF
  SELECT INTO "nl:"
   FROM person p
   PLAN (p
    WHERE (p.person_id= $PERSON_ID))
   DETAIL
    pt_name = trim(p.name_full_formatted)
   WITH nocounter
  ;end select
  CALL unlockops(0)
  SET reply->status_data.status = "S"
  SET reply->status_data.subeventstatus[1].operationstatus = "S"
  SET reply->status_data.subeventstatus[1].operationname = "ams_dynamic_doc_unlock"
  CALL updtdminfo(prog_name)
 ELSE
  IF (run_ind=0)
   SET err_msg = "THIS PROGRAM IS INTENDED FOR USE BY AMS ASSOCIATES ONLY"
  ELSEIF (ispromptempty(3)=1)
   SET err_msg = "NO DOCUMENTS SELECTED"
  ELSE
   SET err_msg = "UNKNOWN ERROR"
  ENDIF
 ENDIF
#exit_script
 SELECT INTO  $OUTDEV
  FROM dummyt d
  PLAN (d)
  HEAD REPORT
   IF ((reply->status_data.status="S"))
    row 5, col 10, "DELETE SUCCESS",
    row 7, tempstring = concat(cnvtstring( $DD_SESSION_ID)," DELETED FOR PATIENT ",trim(pt_name)),
    col 10,
    tempstring, row 9, col 10,
    prompt_parser
   ELSE
    reply->status_data.status = "F", reply->status_data.subeventstatus[1].operationstatus = "F",
    reply->status_data.subeventstatus[1].operationname = prog_name,
    reply->status_data.subeventstatus[1].targetobjectname = "err_msg", reply->status_data.
    subeventstatus[1].targetobjectvalue = err_msg, row 5,
    col 10, "DELETE FAILURE", row 7,
    err_msg2 = substring(1,70,err_msg), col 10, "ERROR: ",
    err_msg2, row 9, col 10,
    prompt_parser
   ENDIF
  WITH nocounter
 ;end select
 SET last_mod = "001 07/01/16 CD047457 Unlock now calls EJS 389"
END GO
