CREATE PROGRAM clairvia_ref_data_br_standard:dba
 PROMPT
  "Printer" = "MINE",
  "Facility" = 0,
  "Start Date/Time" = "",
  "End Date/Time" = "",
  "Bedrock Facility" = 0
  WITH outdev, facility, startdttm,
  enddttm, bedrock_facility
 FREE RECORD map
 FREE RECORD drec
 FREE RECORD frec
 RECORD map(
   1 event_cnd_cnt = i4
   1 seq[*]
     2 event_code = f8
     2 clin_event_code = f8
     2 mnemonic = vc
     2 description = vc
     2 activity_type = vc
     2 result_type = vc
     2 code_cnt = i4
     2 response[*]
       3 sex = vc
       3 age_from = vc
       3 age_to = vc
       3 source_string = vc
     2 pf[*]
       3 form_desc = vc
       3 section_desc = vc
     2 iview[*]
       3 view_desc = vc
       3 section_desc = vc
 )
 RECORD drec(
   1 encntr_qual_cnt = i4
   1 encntr_qual[*]
     2 encntr_id = f8
     2 fin_id = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD frec(
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
   1 file_name = vc
   1 file_buf = vc
 )
 FREE RECORD br_prefs
 RECORD br_prefs(
   1 report_location = vc
   1 report_name = vc
   1 include_iview_ind = i2
   1 include_labs_ind = i2
   1 include_bb_ind = i2
   1 clin_doc_events_cnt = i4
   1 clin_doc_events[*]
     2 event_cd = f8
   1 include_iv_ind = i2
   1 iv_ingredient_cnt = i4
   1 iv_ingredients[*]
     2 catalog_cd = f8
 )
 DECLARE parsedateprompt(date_str=vc,default_date=vc,time=i4) = dq8
 DECLARE _evaluatedatestr(date_str=vc) = i4
 DECLARE _parsedate(date_str=vc) = i4
 SUBROUTINE parsedateprompt(date_str,default_date,time)
   DECLARE _return_val = dq8 WITH noconstant(0.0), private
   DECLARE _time = i4 WITH constant(cnvtint(time)), private
   DECLARE _date = i4 WITH constant(_parsedate(date_str)), private
   IF (_date=0.0)
    CASE (substring(1,1,reflect(default_date)))
     OF "F":
      SET _return_val = cnvtdatetime(cnvtdate(default_date),_time)
     OF "C":
      SET _return_val = cnvtdatetime(_evaluatedatestr(default_date),_time)
     OF "I":
      SET _return_val = cnvtdatetime(default_date,_time)
     ELSE
      SET _return_val = 0
    ENDCASE
   ELSE
    SET _return_val = cnvtdatetime(_date,_time)
   ENDIF
   RETURN(_return_val)
 END ;Subroutine
 SUBROUTINE _parsedate(date_str)
   DECLARE _return_val = dq8 WITH noconstant(0.0), private
   DECLARE _time = i4 WITH constant(0), private
   IF (isnumeric(date_str))
    DECLARE _date = vc WITH constant(trim(cnvtstring(date_str))), private
    SET _return_val = cnvtdatetime(cnvtdate(_date),_time)
    IF (_return_val=0.0)
     SET _return_val = cnvtdatetime(cnvtint(_date),_time)
    ENDIF
   ELSE
    DECLARE _date = vc WITH constant(trim(date_str)), private
    IF (textlen(trim(_date))=0)
     SET _return_val = 0
    ELSE
     IF (_date IN ("*CURDATE*"))
      SET _return_val = cnvtdatetime(_evaluatedatestr(_date),_time)
     ELSE
      SET _return_val = cnvtdatetime(cnvtdate2(_date,"DD-MMM-YYYY"),_time)
     ENDIF
    ENDIF
   ENDIF
   RETURN(cnvtdate(_return_val))
 END ;Subroutine
 SUBROUTINE _evaluatedatestr(date_str)
   DECLARE _dq8 = dq8 WITH noconstant(0.0), private
   DECLARE _parse = vc WITH constant(concat("set _dq8 = cnvtdatetime(",date_str,", 0) go")), private
   CALL parser(_parse)
   RETURN(cnvtdate(_dq8))
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
 IF ( NOT (validate(ccps_log_frec)))
  RECORD ccps_log_frec(
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
   DECLARE seek_retval = i4 WITH private, noconstant(0)
   DECLARE filelen = i4 WITH private, noconstant(0)
   DECLARE write_stat = i2 WITH private, noconstant(0)
   DECLARE imsglvl = i2 WITH private, noconstant(0)
   DECLARE smsglvl = vc WITH private, noconstant("")
   DECLARE slogtext = vc WITH private, noconstant("")
   DECLARE start_char = i4 WITH private, noconstant(0)
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
      SET ccps_log_frec->file_name = debug_values->log_file_dest
      SET ccps_log_frec->file_buf = "ab"
      SET stat = cclio("OPEN",ccps_log_frec)
      SET ccps_log_frec->file_dir = 2
      SET seek_retval = cclio("SEEK",ccps_log_frec)
      SET filelen = cclio("TELL",ccps_log_frec)
      SET ccps_log_frec->file_offset = filelen
      SET ccps_log_frec->file_buf = build2(format(cnvtdatetime(curdate,curtime3),
        "mm/dd/yyyy hh:mm:ss;;d"),fillstring(5," "),"{",smsglvl,"}",
       fillstring(5," "),mymsg,char(13),char(10))
      SET write_stat = cclio("WRITE",ccps_log_frec)
      SET stat = cclio("CLOSE",ccps_log_frec)
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
    DECLARE smsgtype = vc WITH private, noconstant("")
    DECLARE write_stat = i4 WITH private, noconstant(0)
    SET smsgtype = "Audit"
    IF ((debug_values->logging_on=true))
     IF ((debug_values->debug_method=ccps_file_ind))
      SET ccps_log_frec->file_name = debug_values->log_file_dest
      SET ccps_log_frec->file_buf = "ab"
      SET stat = cclio("OPEN",ccps_log_frec)
      SET ccps_log_frec->file_dir = 2
      SET seek_retval = cclio("SEEK",ccps_log_frec)
      SET filelen = cclio("TELL",ccps_log_frec)
      SET ccps_log_frec->file_offset = filelen
      SET ccps_log_frec->file_buf = build2(format(cnvtdatetime(curdate,curtime3),
        "mm/dd/yyyy hh:mm:ss;;d"),fillstring(5," "),"{",smsgtype,"}",
       fillstring(5," "))
      IF ((debug_values->rec_format=ccps_xml))
       CALL echoxml(myrecstruct,debug_values->log_file_dest,1)
      ELSEIF ((debug_values->rec_format=ccps_json))
       CALL echojson(myrecstruct,debug_values->log_file_dest,1)
      ELSE
       CALL echorecord(myrecstruct,debug_values->log_file_dest,1)
      ENDIF
      SET ccps_log_frec->file_buf = build(ccps_log_frec->file_buf,char(13),char(10))
      SET write_stat = cclio("WRITE",ccps_log_frec)
      SET stat = cclio("CLOSE",ccps_log_frec)
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
   DECLARE errcnt = i4 WITH noconstant(0), private
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
 SET lastmod = "005 08/31/2018 ML011047"
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
 DECLARE getbrfilters(allind=i2,report_meaning=vc(value,""),cache_ind=i2(value,0),logdom_ind=i2(value,
   1)) = vc WITH protect
 DECLARE getbrflexedfilters(allind=i2,report_meaning=vc(value,"")) = vc WITH protect
 DECLARE retrievebrfiltersbyflex(allind=i2,report_meaning=vc(value,"")) = vc WITH protect
 DECLARE getbestfilterbatchsize(querysize=i4,groupsize=i4) = i4 WITH protect
 DECLARE loadbrflexvalues(flex_parent_entity_id=f8) = null WITH protect
 DECLARE getbedrockfilterindexbymeaning(filtermeaning=vc) = i4 WITH protect
 DECLARE loadbedrockfreetextvalue(filtermeaning=vc,valuetype=vc,referencevariable=vc(ref)) = null
 WITH protect
 DECLARE copytofiltervaluesrecord(fromrec=vc(ref),filter_index=i4) = null WITH protect
 DECLARE copyfiltervaluesrecord(filter_index=i4,value_index=i4,torec=vc(ref)) = null WITH protect
 DECLARE getencounterfacilitycd(encntr_id=f8) = f8 WITH protect
 DECLARE getprsnldomain(null) = f8 WITH protect
 DECLARE loadbrflexflag(null) = null WITH protect
 DECLARE loadbrfilter(filter_index=i4) = null WITH protect
 DECLARE loadbrvalues(filter_index=i4) = null WITH protect
 DECLARE buildbrcachekey(null) = vc WITH protect
 DECLARE buildbrquerycriteria(report_meaning=vc) = null WITH protect
 DECLARE loadbrcategorydetails(category_meaning=vc) = null WITH protect
 DECLARE getbrflexidforposition(null) = null WITH protect
 DECLARE getbrflexidforfacility(null) = null WITH protect
 DECLARE getbrflexidforpositionlocation(null) = null WITH protect
 FREE RECORD filter
 RECORD filter(
   1 maincatid = f8
   1 maincatname = vc
   1 maincatmean = vc
   1 flexflag = i2
   1 allind = i2
   1 filterscnt = i4
   1 filters[*]
     2 fileventid = f8
     2 fileventcatmean = vc
     2 fileventmean = vc
     2 fileventdisp = vc
     2 fileventseq = i4
     2 fileventcatid = f8
     2 values[*]
       3 valeventid = f8
       3 valeventseq = i4
       3 valeventgrpseq = i4
       3 valeventcd = f8
       3 valeventcddisp = vc
       3 valeventtblnm = vc
       3 valeventcd2 = f8
       3 valeventcddisp2 = vc
       3 valeventtblnm2 = vc
       3 valqualflag = i4
       3 valeventoper = vc
       3 valeventtype = i4
       3 valeventftx = vc
       3 valeventnomdisp = vc
       3 valeventdcind = i2
       3 valeventmpmean = vc
       3 valeventmpval = vc
       3 valbrflexid = f8
       3 valbrflexparententityid = f8
       3 valbrflexparententityname = vc
       3 valbrflexparententitytypeflag = i2
 ) WITH protect
 FREE RECORD br_flex_by_values
 RECORD br_flex_by_values(
   1 position_cd = f8
   1 facility_cd = f8
   1 building_cd = f8
   1 nurse_unit_cd = f8
 )
 FREE RECORD br_flex_details
 RECORD br_flex_details(
   1 pos_loc_settings_ind = i2
   1 position_flex_id = f8
   1 facility_flex_id = f8
   1 building_flex_id = f8
   1 nurse_unit_flex_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD br_query_criteria
 RECORD br_query_criteria(
   1 br_cat_parse_str = vc
   1 br_rpt_parse_str = vc
   1 br_value_parse_str = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD br_cache_key
 RECORD br_cache_key(
   1 main_cat_mean = vc
   1 all_ind = i2
   1 filters[*]
     2 filter_mean = vc
   1 logical_domain_id = f8
   1 position_cd = f8
   1 facility_cd = f8
   1 building_cd = f8
   1 nurse_unit_cd = f8
 )
 DECLARE no_flexing = i4 WITH protect, constant(0)
 DECLARE position_flexing = i4 WITH protect, constant(1)
 DECLARE location_flexing = i4 WITH protect, constant(2)
 DECLARE position_location_flexing = i4 WITH protect, constant(3)
 DECLARE prsnl_logical_domain_id = f8 WITH protect, noconstant(0)
 DECLARE logical_domain_ind = i2 WITH protect, noconstant(checkdic(
   "BR_DATAMART_VALUE.LOGICAL_DOMAIN_ID","A",0))
 DECLARE br_load_default_logical_domain_ind = i2 WITH protect, noconstant(0)
 DECLARE cache_namespace = vc WITH noconstant("CUSTOM_CCL"), protect
 SET br_flex_by_values->position_cd = reqinfo->position_cd
 SUBROUTINE loadbrflexvalues(flex_parent_entity_id)
   RECORD defaultvaluesrec(
     1 values_cnt = i4
     1 values[*]
       2 valeventid = f8
       2 valeventseq = i4
       2 valeventgrpseq = i4
       2 valeventcd = f8
       2 valeventcddisp = vc
       2 valeventtblnm = vc
       2 valeventcd2 = f8
       2 valeventcddisp2 = vc
       2 valeventtblnm2 = vc
       2 valqualflag = i4
       2 valeventoper = vc
       2 valeventtype = i4
       2 valeventftx = vc
       2 valeventnomdisp = vc
       2 valeventdcind = i2
       2 valeventmpmean = vc
       2 valeventmpval = vc
       2 valbrflexid = f8
       2 valbrflexparententityid = f8
       2 valbrflexparententityname = vc
       2 valbrflexparententitytypeflag = i2
   ) WITH protect
   RECORD flexvaluesrec(
     1 values_cnt = i4
     1 values[*]
       2 valeventid = f8
       2 valeventseq = i4
       2 valeventgrpseq = i4
       2 valeventcd = f8
       2 valeventcddisp = vc
       2 valeventtblnm = vc
       2 valeventcd2 = f8
       2 valeventcddisp2 = vc
       2 valeventtblnm2 = vc
       2 valqualflag = i4
       2 valeventoper = vc
       2 valeventtype = i4
       2 valeventftx = vc
       2 valeventnomdisp = vc
       2 valeventdcind = i2
       2 valeventmpmean = vc
       2 valeventmpval = vc
       2 valbrflexid = f8
       2 valbrflexparententityid = f8
       2 valbrflexparententityname = vc
       2 valbrflexparententitytypeflag = i2
   ) WITH protect
   DECLARE icnt = i4 WITH protect, noconstant(0)
   DECLARE ifilcntr = i4 WITH protect, noconstant(0)
   DECLARE ifilterssize = i4 WITH protect, noconstant(size(filter->filters,5))
   DECLARE ivaluessize = i4 WITH protect, noconstant(0)
   FOR (ifilcntr = 1 TO ifilterssize)
     SET stat = initrec(defaultvaluesrec)
     SET stat = initrec(flexvaluesrec)
     SET ivaluessize = size(filter->filters[ifilcntr].values,5)
     FOR (icnt = 1 TO ivaluessize)
       IF ((filter->filters[ifilcntr].fileventcatmean="NUMERIC_VALUE"))
        IF (textlen(trim(filter->filters[ifilcntr].values[icnt].valeventftx,3)) > 0)
         IF ((filter->filters[ifilcntr].values[icnt].valbrflexparententityid=flex_parent_entity_id))
          CALL copyfiltervaluesrecord(ifilcntr,icnt,flexvaluesrec)
          SET icnt = (ivaluessize+ 1)
         ELSE
          IF ((filter->filters[ifilcntr].values[icnt].valbrflexparententityid=0.0))
           CALL copyfiltervaluesrecord(ifilcntr,icnt,defaultvaluesrec)
          ENDIF
         ENDIF
        ENDIF
       ELSE
        IF ((filter->filters[ifilcntr].values[icnt].valbrflexparententityid=flex_parent_entity_id))
         CALL copyfiltervaluesrecord(ifilcntr,icnt,flexvaluesrec)
        ELSE
         IF ((filter->filters[ifilcntr].values[icnt].valbrflexparententityid=0))
          CALL copyfiltervaluesrecord(ifilcntr,icnt,defaultvaluesrec)
         ENDIF
        ENDIF
       ENDIF
     ENDFOR
     SET stat = alterlist(filter->filters[ifilcntr].values,0)
     IF ((flexvaluesrec->values_cnt > 0))
      CALL copytofiltervaluesrecord(flexvaluesrec,ifilcntr)
     ELSEIF ((defaultvaluesrec->values_cnt > 0))
      CALL copytofiltervaluesrecord(defaultvaluesrec,ifilcntr)
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE loadbedrockfreetextvalue(filtermeaning,valuetype,referencevariable)
   DECLARE filter_index = i4 WITH protect, noconstant(0)
   SET filter_index = getbedrockfilterindexbymeaning(filtermeaning)
   IF (filter_index > 0)
    IF (size(filter->filters[filter_index].values,5)=1)
     CASE (cnvtupper(valuetype))
      OF "ALPHA":
       SET referencevariable = trim(filter->filters[filter_index].values[1].valeventftx,3)
      OF "FLOAT":
       SET referencevariable = cnvtreal(filter->filters[filter_index].values[1].valeventftx)
      OF "INTEGER":
       SET referencevariable = cnvtint(filter->filters[filter_index].values[1].valeventftx)
     ENDCASE
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE getbedrockfilterindexbymeaning(filtermeaning)
   DECLARE filter_index = i4 WITH protect, noconstant(0)
   DECLARE filter_size = i4 WITH protect, noconstant(0)
   DECLARE search_cntr = i4 WITH protect, noconstant(0)
   SET filter_size = size(filter->filters,5)
   SET filter_index = locateval(search_cntr,1,filter_size,filtermeaning,filter->filters[search_cntr].
    fileventmean)
   RETURN(filter_index)
 END ;Subroutine
 SUBROUTINE copytofiltervaluesrecord(fromrec,filter_index)
   DECLARE recsize = i4 WITH protect, constant(size(fromrec->values,5))
   DECLARE reccntr = i4 WITH protect, noconstant(0)
   SET stat = alterlist(filter->filters[filter_index].values,recsize)
   FOR (reccntr = 1 TO recsize)
     SET filter->filters[filter_index].values[reccntr].valeventid = fromrec->values[reccntr].
     valeventid
     SET filter->filters[filter_index].values[reccntr].valeventseq = fromrec->values[reccntr].
     valeventseq
     SET filter->filters[filter_index].values[reccntr].valeventgrpseq = fromrec->values[reccntr].
     valeventgrpseq
     SET filter->filters[filter_index].values[reccntr].valeventcd = fromrec->values[reccntr].
     valeventcd
     SET filter->filters[filter_index].values[reccntr].valeventcddisp = fromrec->values[reccntr].
     valeventcddisp
     SET filter->filters[filter_index].values[reccntr].valeventtblnm = fromrec->values[reccntr].
     valeventtblnm
     SET filter->filters[filter_index].values[reccntr].valeventcd2 = fromrec->values[reccntr].
     valeventcd2
     SET filter->filters[filter_index].values[reccntr].valeventcddisp2 = fromrec->values[reccntr].
     valeventcddisp2
     SET filter->filters[filter_index].values[reccntr].valeventtblnm2 = fromrec->values[reccntr].
     valeventtblnm2
     SET filter->filters[filter_index].values[reccntr].valqualflag = fromrec->values[reccntr].
     valqualflag
     SET filter->filters[filter_index].values[reccntr].valeventoper = fromrec->values[reccntr].
     valeventoper
     SET filter->filters[filter_index].values[reccntr].valeventtype = fromrec->values[reccntr].
     valeventtype
     SET filter->filters[filter_index].values[reccntr].valeventftx = fromrec->values[reccntr].
     valeventftx
     SET filter->filters[filter_index].values[reccntr].valeventnomdisp = fromrec->values[reccntr].
     valeventnomdisp
     SET filter->filters[filter_index].values[reccntr].valeventdcind = fromrec->values[reccntr].
     valeventdcind
     SET filter->filters[filter_index].values[reccntr].valeventmpmean = fromrec->values[reccntr].
     valeventmpmean
     SET filter->filters[filter_index].values[reccntr].valeventmpval = fromrec->values[reccntr].
     valeventmpval
     SET filter->filters[filter_index].values[reccntr].valbrflexid = fromrec->values[reccntr].
     valbrflexid
     SET filter->filters[filter_index].values[reccntr].valbrflexparententityid = fromrec->values[
     reccntr].valbrflexparententityid
     SET filter->filters[filter_index].values[reccntr].valbrflexparententityname = fromrec->values[
     reccntr].valbrflexparententityname
     SET filter->filters[filter_index].values[reccntr].valbrflexparententitytypeflag = fromrec->
     values[reccntr].valbrflexparententitytypeflag
   ENDFOR
 END ;Subroutine
 SUBROUTINE copyfiltervaluesrecord(filter_index,value_index,torec)
   SET torec->values_cnt = (torec->values_cnt+ 1)
   SET stat = alterlist(torec->values,torec->values_cnt)
   SET torec->values[torec->values_cnt].valeventid = filter->filters[filter_index].values[value_index
   ].valeventid
   SET torec->values[torec->values_cnt].valeventseq = filter->filters[filter_index].values[
   value_index].valeventseq
   SET torec->values[torec->values_cnt].valeventgrpseq = filter->filters[filter_index].values[
   value_index].valeventgrpseq
   SET torec->values[torec->values_cnt].valeventcd = filter->filters[filter_index].values[value_index
   ].valeventcd
   SET torec->values[torec->values_cnt].valeventcddisp = filter->filters[filter_index].values[
   value_index].valeventcddisp
   SET torec->values[torec->values_cnt].valeventtblnm = filter->filters[filter_index].values[
   value_index].valeventtblnm
   SET torec->values[torec->values_cnt].valeventcd2 = filter->filters[filter_index].values[
   value_index].valeventcd2
   SET torec->values[torec->values_cnt].valeventcddisp2 = filter->filters[filter_index].values[
   value_index].valeventcddisp2
   SET torec->values[torec->values_cnt].valeventtblnm2 = filter->filters[filter_index].values[
   value_index].valeventtblnm2
   SET torec->values[torec->values_cnt].valqualflag = filter->filters[filter_index].values[
   value_index].valqualflag
   SET torec->values[torec->values_cnt].valeventoper = filter->filters[filter_index].values[
   value_index].valeventoper
   SET torec->values[torec->values_cnt].valeventtype = filter->filters[filter_index].values[
   value_index].valeventtype
   SET torec->values[torec->values_cnt].valeventftx = filter->filters[filter_index].values[
   value_index].valeventftx
   SET torec->values[torec->values_cnt].valeventnomdisp = filter->filters[filter_index].values[
   value_index].valeventnomdisp
   SET torec->values[torec->values_cnt].valeventdcind = filter->filters[filter_index].values[
   value_index].valeventdcind
   SET torec->values[torec->values_cnt].valeventmpmean = filter->filters[filter_index].values[
   value_index].valeventmpmean
   SET torec->values[torec->values_cnt].valeventmpval = filter->filters[filter_index].values[
   value_index].valeventmpval
   SET torec->values[torec->values_cnt].valbrflexid = filter->filters[filter_index].values[
   value_index].valbrflexid
   SET torec->values[torec->values_cnt].valbrflexparententityid = filter->filters[filter_index].
   values[value_index].valbrflexparententityid
   SET torec->values[torec->values_cnt].valbrflexparententityname = filter->filters[filter_index].
   values[value_index].valbrflexparententityname
   SET torec->values[torec->values_cnt].valbrflexparententitytypeflag = filter->filters[filter_index]
   .values[value_index].valbrflexparententitytypeflag
 END ;Subroutine
 SUBROUTINE getencounterfacilitycd(encntr_id)
   DECLARE facility_cd = f8 WITH protect, noconstant(0)
   IF (encntr_id > 0.0)
    SELECT INTO "nl:"
     FROM encounter e
     PLAN (e
      WHERE e.encntr_id=encntr_id)
     DETAIL
      facility_cd = e.loc_facility_cd
     WITH nocounter
    ;end select
   ENDIF
   RETURN(facility_cd)
 END ;Subroutine
 SUBROUTINE loadbrflexflag(null)
   IF (validate(filter->flexflag)=1)
    SET filter->flexflag = b.flex_flag
   ENDIF
 END ;Subroutine
 SUBROUTINE loadbrfilter(filter_index)
   SET filter->filters[filter_index].fileventid = bd.br_datamart_filter_id
   SET filter->filters[filter_index].fileventcatmean = bd.filter_category_mean
   SET filter->filters[filter_index].fileventmean = bd.filter_mean
   SET filter->filters[filter_index].fileventdisp = bd.filter_display
   SET filter->filters[filter_index].fileventseq = bd.filter_seq
   SET filter->filters[filter_index].fileventcatid = bd.br_datamart_category_id
   SET cntx = 0
 END ;Subroutine
 SUBROUTINE loadbrvalues(filter_index)
   IF (bdv.br_datamart_filter_id > 0)
    SET cntx = (cntx+ 1)
    IF (mod(cntx,10)=1)
     SET now = alterlist(filter->filters[filter_index].values,(cntx+ 9))
    ENDIF
    SET filter->filters[filter_index].values[cntx].valeventid = bdv.br_datamart_value_id
    SET filter->filters[filter_index].values[cntx].valeventseq = bdv.value_seq
    SET filter->filters[filter_index].values[cntx].valeventgrpseq = bdv.group_seq
    SET filter->filters[filter_index].values[cntx].valeventcddisp = uar_get_code_display(bdv
     .parent_entity_id)
    SET filter->filters[filter_index].values[cntx].valeventcd = bdv.parent_entity_id
    SET filter->filters[filter_index].values[cntx].valeventtblnm = bdv.parent_entity_name
    SET filter->filters[filter_index].values[cntx].valqualflag = bdv.qualifier_flag
    SET filter->filters[filter_index].values[cntx].valeventtype = bdv.value_type_flag
    SET filter->filters[filter_index].values[cntx].valeventmpmean = bdv.mpage_param_mean
    SET filter->filters[filter_index].values[cntx].valeventmpval = bdv.mpage_param_value
    IF (bdv.qualifier_flag=1)
     SET filter->filters[filter_index].values[cntx].valeventoper = "="
    ELSEIF (bdv.qualifier_flag=2)
     SET filter->filters[filter_index].values[cntx].valeventoper = "!="
    ELSEIF (bdv.qualifier_flag=3)
     SET filter->filters[filter_index].values[cntx].valeventoper = ">"
    ELSEIF (bdv.qualifier_flag=4)
     SET filter->filters[filter_index].values[cntx].valeventoper = "<"
    ELSEIF (bdv.qualifier_flag=5)
     SET filter->filters[filter_index].values[cntx].valeventoper = ">="
    ELSEIF (bdv.qualifier_flag=6)
     SET filter->filters[filter_index].values[cntx].valeventoper = "<="
    ENDIF
    IF (bdv.parent_entity_id > 0
     AND bdv.parent_entity_name="NOMENCLATURE")
     SET filter->filters[filter_index].values[cntx].valeventnomdisp = trim(n.source_string)
    ELSEIF (textlen(trim(bdv.freetext_desc,3)) > 0)
     SET filter->filters[filter_index].values[cntx].valeventftx = trim(bdv.freetext_desc)
    ENDIF
    IF (validate(filter->filters[filter_index].values[cntx].valbrflexid)=1)
     SET filter->filters[filter_index].values[cntx].valbrflexid = bdf.br_datamart_flex_id
     SET filter->filters[filter_index].values[cntx].valbrflexparententityid = bdf.parent_entity_id
     SET filter->filters[filter_index].values[cntx].valbrflexparententityname = bdf
     .parent_entity_name
     SET filter->filters[filter_index].values[cntx].valbrflexparententitytypeflag = bdf
     .parent_entity_type_flag
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE getbestfilterbatchsize(querysize,groupsize)
   IF (querysize <= 1)
    RETURN(querysize)
   ELSEIF (querysize <= 5)
    RETURN(5)
   ELSEIF (querysize <= 10)
    RETURN(10)
   ENDIF
   DECLARE minquerycount = i4 WITH constant(((querysize+ (groupsize - 1))/ groupsize))
   DECLARE bestbatchsize = i4 WITH constant(ceil((cnvtreal(querysize)/ minquerycount)))
   RETURN((20 * ceil((cnvtreal(bestbatchsize)/ 20))))
 END ;Subroutine
 SUBROUTINE getbrfilters(allind,report_meaning,cache_ind,logdom_ind)
   DECLARE cache_val = vc WITH protect
   DECLARE cache_key = vc WITH protect
   DECLARE cntx = i4 WITH protect, noconstant(0)
   DECLARE pos = i4 WITH protect, noconstant(0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE batch_size = i4 WITH protect, noconstant(0)
   DECLARE loop_cnt = i4 WITH protect, noconstant(0)
   DECLARE num = i4 WITH protect, noconstant(0)
   CALL echo(build(";*** logdom_ind -->",logdom_ind))
   IF (logdom_ind=0)
    SET logical_domain_ind = 0
   ENDIF
   IF (cache_ind
    AND validate(filter->maincatmean)=1
    AND textlen(trim(filter->maincatmean,3)) > 0)
    SET cache_key = buildbrcachekey(null)
    IF (textlen(trim(cache_key,3)) > 0)
     SET cache_val = getnamespacedsettings(cache_namespace,cache_key)
    ENDIF
   ENDIF
   IF (textlen(trim(cache_val,3)) > 0)
    SET stat = cnvtjsontorec(cache_val)
   ELSE
    CALL buildbrquerycriteria(report_meaning)
    IF (allind=1)
     SELECT INTO "nl:"
      FROM br_datamart_category b,
       br_datamart_report bdr,
       br_datamart_report_filter_r bdrf,
       br_datamart_filter bd,
       br_datamart_value bdv,
       br_datamart_flex bdf,
       nomenclature n
      PLAN (b
       WHERE parser(br_query_criteria->br_cat_parse_str))
       JOIN (bdr
       WHERE parser(br_query_criteria->br_rpt_parse_str))
       JOIN (bdrf
       WHERE bdrf.br_datamart_report_id=bdr.br_datamart_report_id)
       JOIN (bd
       WHERE bd.br_datamart_filter_id=bdrf.br_datamart_filter_id)
       JOIN (bdv
       WHERE parser(br_query_criteria->br_value_parse_str))
       JOIN (bdf
       WHERE outerjoin(bdv.br_datamart_flex_id)=bdf.br_datamart_flex_id)
       JOIN (n
       WHERE n.nomenclature_id=outerjoin(bdv.parent_entity_id)
        AND n.end_effective_dt_tm > outerjoin(sysdate)
        AND n.active_ind=outerjoin(1))
      ORDER BY bd.br_datamart_filter_id, bd.filter_seq, bdv.group_seq,
       bdv.value_seq
      HEAD REPORT
       cntr = 0, filter->maincatid = b.br_datamart_category_id,
       CALL loadbrflexflag(null)
      HEAD bd.br_datamart_filter_id
       cntr = (cntr+ 1)
       IF (mod(cntr,10)=1)
        now = alterlist(filter->filters,(cntr+ 9))
       ENDIF
       CALL loadbrfilter(cntr)
      DETAIL
       CALL loadbrvalues(cntr)
      FOOT  bd.br_datamart_filter_id
       now = alterlist(filter->filters[cntr].values,cntx)
      FOOT REPORT
       now = alterlist(filter->filters,cntr), filter->filterscnt = cntr
      WITH nocounter, separator = " ", format
     ;end select
    ELSE
     SET batch_size = getbestfilterbatchsize(filter->filterscnt,100)
     SET loop_cnt = ceil((cnvtreal(filter->filterscnt)/ maxval(batch_size,1)))
     CALL echo("In GetBrFilters() - get select bedrock patient event filters")
     CALL echo(build(" batch_size -- > ",batch_size))
     CALL echo(build(" loop_cnt -- > ",loop_cnt))
     SELECT INTO "nl:"
      FROM (dummyt d1  WITH seq = loop_cnt),
       br_datamart_category b,
       br_datamart_report bdr,
       br_datamart_report_filter_r bdrf,
       br_datamart_filter bd,
       br_datamart_value bdv,
       br_datamart_flex bdf,
       nomenclature n
      PLAN (d1
       WHERE d1.seq > 0)
       JOIN (b
       WHERE parser(br_query_criteria->br_cat_parse_str))
       JOIN (bdr
       WHERE parser(br_query_criteria->br_rpt_parse_str))
       JOIN (bdrf
       WHERE bdrf.br_datamart_report_id=bdr.br_datamart_report_id)
       JOIN (bd
       WHERE bd.br_datamart_filter_id=bdrf.br_datamart_filter_id
        AND expand(idx,(1+ ((d1.seq - 1) * batch_size)),minval((d1.seq * batch_size),filter->
         filterscnt),cnvtupper(bd.filter_mean),filter->filters[idx].fileventmean,
        cnvtupper(bd.filter_category_mean),filter->filters[idx].fileventcatmean))
       JOIN (bdv
       WHERE parser(br_query_criteria->br_value_parse_str))
       JOIN (bdf
       WHERE outerjoin(bdv.br_datamart_flex_id)=bdf.br_datamart_flex_id)
       JOIN (n
       WHERE n.nomenclature_id=outerjoin(bdv.parent_entity_id)
        AND n.end_effective_dt_tm > outerjoin(sysdate)
        AND n.active_ind=outerjoin(1))
      ORDER BY bd.br_datamart_filter_id, bd.filter_seq, bdv.group_seq,
       bdv.value_seq
      HEAD REPORT
       cntr = 0, filter->maincatid = b.br_datamart_category_id,
       CALL loadbrflexflag(null)
      HEAD bd.br_datamart_filter_id
       pos = locateval(num,1,filter->filterscnt,bd.filter_mean,filter->filters[num].fileventmean,
        bd.filter_category_mean,filter->filters[num].fileventcatmean)
       IF (pos > 0)
        CALL loadbrfilter(pos)
       ENDIF
      DETAIL
       IF (pos > 0)
        CALL loadbrvalues(pos)
       ENDIF
      FOOT  bd.br_datamart_filter_id
       now = alterlist(filter->filters[pos].values,cntx)
      FOOT REPORT
       row + 0
      WITH nocounter, separator = " ", format
     ;end select
    ENDIF
    IF (textlen(trim(cache_key,3)) > 0
     AND cache_ind=1)
     CALL cachenamespacedsettings(cache_namespace,cache_key,cnvtrectojson(filter))
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE getprsnldomain(null)
   DECLARE prsnllogicaldomainid = f8 WITH protect, noconstant(0.0)
   IF (br_load_default_logical_domain_ind=0
    AND checkdic("PRSNL.LOGICAL_DOMAIN_ID","A",0)=2)
    SELECT INTO "nl:"
     FROM prsnl p
     PLAN (p
      WHERE (p.person_id=reqinfo->updt_id))
     DETAIL
      prsnllogicaldomainid = p.logical_domain_id
     WITH nocounter, separator = " ", format
    ;end select
   ENDIF
   RETURN(prsnllogicaldomainid)
 END ;Subroutine
 SUBROUTINE loadbrcategorydetails(category_meaning)
   SELECT INTO "nl:"
    FROM br_datamart_category b
    PLAN (b
     WHERE b.category_mean=category_meaning)
    HEAD REPORT
     filter->maincatid = b.br_datamart_category_id, filter->flexflag = b.flex_flag
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE getbrflexidforposition(null)
  IF ((br_flex_by_values->position_cd <= 0.0))
   RETURN(null)
  ENDIF
  SELECT INTO "nl:"
   FROM br_datamart_value bv,
    br_datamart_flex flex
   PLAN (bv
    WHERE (bv.br_datamart_category_id=filter->maincatid))
    JOIN (flex
    WHERE flex.br_datamart_flex_id=bv.br_datamart_flex_id
     AND (flex.parent_entity_id=br_flex_by_values->position_cd))
   ORDER BY flex.br_datamart_flex_id
   HEAD flex.br_datamart_flex_id
    br_flex_details->position_flex_id = flex.br_datamart_flex_id
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE getbrflexidforfacility(br_datamart_category_id)
  IF ((br_flex_by_values->facility_cd <= 0.0))
   RETURN(null)
  ENDIF
  SELECT INTO "nl:"
   FROM br_datamart_value bv,
    br_datamart_flex flex
   PLAN (bv
    WHERE (bv.br_datamart_category_id=filter->maincatid))
    JOIN (flex
    WHERE flex.br_datamart_flex_id=bv.br_datamart_flex_id
     AND (flex.parent_entity_id=br_flex_by_values->facility_cd))
   ORDER BY flex.br_datamart_flex_id
   HEAD flex.br_datamart_flex_id
    br_flex_details->facility_flex_id = flex.br_datamart_flex_id
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE getbrflexidforpositionlocation(br_datamart_category_id)
   IF ((br_flex_by_values->position_cd <= 0.0))
    RETURN(null)
   ENDIF
   SELECT INTO "nl:"
    FROM br_datamart_value bdv,
     br_datamart_flex flex1,
     br_datamart_flex flex2
    PLAN (bdv
     WHERE (bdv.br_datamart_category_id=filter->maincatid))
     JOIN (flex1
     WHERE flex1.br_datamart_flex_id=bdv.br_datamart_flex_id
      AND flex1.parent_entity_id IN (br_flex_by_values->nurse_unit_cd, br_flex_by_values->building_cd,
     br_flex_by_values->facility_cd)
      AND flex1.parent_entity_type_flag=2)
     JOIN (flex2
     WHERE flex2.br_datamart_flex_id=flex1.grouper_flex_id
      AND (flex2.parent_entity_id=br_flex_by_values->position_cd)
      AND flex2.parent_entity_type_flag=1)
    ORDER BY flex1.parent_entity_id, flex2.parent_entity_id
    HEAD flex1.parent_entity_id
     IF ((br_flex_by_values->nurse_unit_cd > 0.0)
      AND (flex1.parent_entity_id=br_flex_by_values->nurse_unit_cd))
      br_flex_details->nurse_unit_flex_id = flex1.br_datamart_flex_id, br_flex_details->
      pos_loc_settings_ind = 1
     ELSEIF ((br_flex_by_values->building_cd > 0.0)
      AND (flex1.parent_entity_id=br_flex_by_values->building_cd))
      br_flex_details->building_flex_id = flex1.br_datamart_flex_id, br_flex_details->
      pos_loc_settings_ind = 1
     ELSEIF ((br_flex_by_values->facility_cd > 0.0)
      AND (flex1.parent_entity_id=br_flex_by_values->facility_cd))
      br_flex_details->facility_flex_id = flex1.br_datamart_flex_id, br_flex_details->
      pos_loc_settings_ind = 1
     ENDIF
    HEAD flex2.parent_entity_id
     IF ((br_flex_by_values->position_cd > 0.0)
      AND (flex2.parent_entity_id=br_flex_by_values->position_cd))
      br_flex_details->position_flex_id = flex2.br_datamart_flex_id, br_flex_details->
      pos_loc_settings_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   CALL getbrflexidforposition(br_datamart_category_id)
 END ;Subroutine
 SUBROUTINE buildbrquerycriteria(report_meaning)
   SET stat = initrec(br_query_criteria)
   IF (validate(filter->maincatmean)=1
    AND textlen(trim(filter->maincatmean,3)) > 0)
    SET br_query_criteria->br_cat_parse_str = "b.category_mean = filter->mainCatMean"
   ELSE
    SET br_query_criteria->br_cat_parse_str = "b.category_name = filter->mainCatName"
   ENDIF
   SET br_query_criteria->br_rpt_parse_str =
   "bdr.br_datamart_category_id = b.br_datamart_category_id"
   IF (validate(report_meaning)=1
    AND textlen(trim(report_meaning,3)) > 0)
    SET br_query_criteria->br_rpt_parse_str = build2(br_query_criteria->br_rpt_parse_str,
     " and cnvtupper(bdr.report_mean) = cnvtupper(^",report_meaning,"^)")
   ENDIF
   SET br_query_criteria->br_value_parse_str = build2(
    "outerjoin(bd.br_datamart_category_id) = bdv.br_datamart_category_id",
    " and outerjoin(bd.br_datamart_filter_id) = bdv.br_datamart_filter_id",
    " and bdv.end_effective_dt_tm > outerjoin(sysdate)")
   IF (logical_domain_ind=2
    AND validate(prsnl_logical_domain_id))
    IF (prsnl_logical_domain_id=0)
     SET prsnl_logical_domain_id = getprsnldomain(null)
    ENDIF
    SET br_query_criteria->br_value_parse_str = build2(br_query_criteria->br_value_parse_str,
     " and bdv.logical_domain_id = outerjoin(prsnl_logical_domain_id)")
   ENDIF
   CALL echo(build("prsnl_logical_domain_id-->",prsnl_logical_domain_id))
   IF ((filter->flexflag > 0))
    SET br_query_criteria->br_value_parse_str = build2(br_query_criteria->br_value_parse_str,
     " and bdv.br_datamart_flex_id in (br_flex_details->nurse_unit_flex_id,",
     "br_flex_details->building_flex_id, br_flex_details->facility_flex_id,",
     "br_flex_details->position_flex_id, 0.0)")
   ENDIF
 END ;Subroutine
 SUBROUTINE getbrflexedfilters(allind,report_meaning)
   DECLARE cache_key = vc WITH protect
   DECLARE cache_val = vc WITH protect
   SET cache_key = buildbrcachekey(null)
   IF (textlen(trim(cache_key,3)) > 0)
    SET cache_val = getnamespacedsettings(cache_namespace,cache_key)
   ENDIF
   IF (textlen(trim(cache_val,3)) > 0)
    SET stat = cnvtjsontorec(cache_val)
   ELSE
    CALL loadbrcategorydetails(filter->maincatmean)
    CALL echo(build(" FILTERS->flexFlag -- > ",filter->flexflag))
    SET stat = initrec(br_flex_details)
    SET br_flex_details->position_flex_id = - (1)
    SET br_flex_details->facility_flex_id = - (1)
    SET br_flex_details->building_flex_id = - (1)
    SET br_flex_details->nurse_unit_flex_id = - (1)
    CASE (filter->flexflag)
     OF no_flexing:
      CALL echo("No flexing needs to be done.")
     OF position_flexing:
      CALL echo("Flexing by position")
      CALL getbrflexidforposition(null)
     OF location_flexing:
      CALL echo("Flexing by location")
      CALL getbrflexidforfacility(null)
     OF position_location_flexing:
      CALL echo("Flexing by position-location")
      CALL getbrflexidforpositionlocation(null)
     ELSE
      CALL echo("Doing nothing since the flex_flag is a number we aren't expecting.")
    ENDCASE
    CALL retrievebrfiltersbyflex(allind,report_meaning)
    IF (textlen(trim(cache_key,3)) > 0)
     SET stat = cachenamespacedsettings(cache_namespace,cache_key,cnvtrectojson(filter))
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE retrievebrfiltersbyflex(allind,report_meaning)
   DECLARE cntx = i4 WITH protect, noconstant(0)
   DECLARE searchcntr = i4 WITH protect, noconstant(0)
   DECLARE cntr = i4 WITH protect, noconstant(0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE addfiltervaluesind = f8 WITH protect, noconstant(0.0)
   DECLARE num = i4 WITH protect, noconstant(0)
   CALL buildbrquerycriteria(report_meaning)
   SET br_query_criteria->br_value_parse_str = replace(br_query_criteria->br_value_parse_str,
    "OUTERJOIN","")
   IF (allind=1)
    SELECT
     filter_flex_seq = evaluate(bdv.br_datamart_flex_id,br_flex_details->nurse_unit_flex_id,1,
      br_flex_details->building_flex_id,2,
      br_flex_details->facility_flex_id,3,br_flex_details->position_flex_id,4,5)
     FROM br_datamart_category b,
      br_datamart_report bdr,
      br_datamart_report_filter_r bdrf,
      br_datamart_filter bd,
      (left JOIN br_datamart_value bdv ON parser(br_query_criteria->br_value_parse_str)),
      (left JOIN br_datamart_flex bdf ON bdf.br_datamart_flex_id=bdv.br_datamart_flex_id),
      (left JOIN nomenclature n ON n.nomenclature_id=bdv.parent_entity_id
       AND n.end_effective_dt_tm > sysdate
       AND n.active_ind=1)
     PLAN (b
      WHERE parser(br_query_criteria->br_cat_parse_str))
      JOIN (bdr
      WHERE parser(br_query_criteria->br_rpt_parse_str))
      JOIN (bdrf
      WHERE bdrf.br_datamart_report_id=bdr.br_datamart_report_id)
      JOIN (bd
      WHERE bd.br_datamart_filter_id=bdrf.br_datamart_filter_id)
      JOIN (bdv)
      JOIN (bdf)
      JOIN (n)
     ORDER BY filter_flex_seq, bd.br_datamart_filter_id, bd.filter_seq,
      bd.filter_mean, bdv.group_seq, bdv.value_seq
     HEAD REPORT
      cntr = 0, filter->maincatid = b.br_datamart_category_id,
      CALL loadbrflexflag(null)
     HEAD filter_flex_seq
      row + 0
     HEAD bd.br_datamart_filter_id
      addfiltervaluesind = 0
      IF (locateval(searchcntr,1,cntr,bd.br_datamart_filter_id,filter->filters[searchcntr].fileventid
       )=0)
       cntr = (cntr+ 1)
       IF (mod(cntr,10)=1)
        now = alterlist(filter->filters,(cntr+ 9))
       ENDIF
       CALL loadbrfilter(cntr), addfiltervaluesind = 1
      ENDIF
     DETAIL
      IF (addfiltervaluesind)
       CALL loadbrvalues(cntr)
      ENDIF
     FOOT  bd.br_datamart_filter_id
      IF (addfiltervaluesind)
       now = alterlist(filter->filters[cntr].values,cntx)
      ENDIF
     FOOT REPORT
      now = alterlist(filter->filters,cntr), filter->filterscnt = cntr
     WITH nocounter, separator = " ", format
    ;end select
   ELSE
    SELECT
     filter_flex_seq = evaluate(bdv.br_datamart_flex_id,br_flex_details->nurse_unit_flex_id,1,
      br_flex_details->building_flex_id,2,
      br_flex_details->facility_flex_id,3,br_flex_details->position_flex_id,4,5)
     FROM br_datamart_category b,
      br_datamart_report bdr,
      br_datamart_report_filter_r bdrf,
      br_datamart_filter bd,
      (left JOIN br_datamart_value bdv ON parser(br_query_criteria->br_value_parse_str)),
      (left JOIN br_datamart_flex bdf ON bdf.br_datamart_flex_id=bdv.br_datamart_flex_id),
      (left JOIN nomenclature n ON n.nomenclature_id=bdv.parent_entity_id
       AND n.end_effective_dt_tm > sysdate
       AND n.active_ind=1)
     PLAN (b
      WHERE parser(br_query_criteria->br_cat_parse_str))
      JOIN (bdr
      WHERE parser(br_query_criteria->br_rpt_parse_str))
      JOIN (bdrf
      WHERE bdrf.br_datamart_report_id=bdr.br_datamart_report_id)
      JOIN (bd
      WHERE bd.br_datamart_filter_id=bdrf.br_datamart_filter_id
       AND expand(idx,1,filter->filterscnt,cnvtupper(bd.filter_mean),filter->filters[idx].
       fileventmean,
       cnvtupper(bd.filter_category_mean),filter->filters[idx].fileventcatmean))
      JOIN (bdv)
      JOIN (bdf)
      JOIN (n)
     ORDER BY filter_flex_seq, bd.br_datamart_filter_id, bd.filter_seq,
      bd.filter_mean, bdv.group_seq, bdv.value_seq
     HEAD REPORT
      cntr = 0, filter->maincatid = b.br_datamart_category_id,
      CALL loadbrflexflag(null)
     HEAD filter_flex_seq
      row + 0
     HEAD bd.br_datamart_filter_id
      addfiltervaluesind = 0, pos = locateval(num,1,filter->filterscnt,bd.filter_mean,filter->
       filters[num].fileventmean,
       bd.filter_category_mean,filter->filters[num].fileventcatmean)
      IF (pos > 0)
       CALL loadbrfilter(pos)
       IF (size(filter->filters[pos].values,5)=0)
        addfiltervaluesind = 1
       ENDIF
      ENDIF
     DETAIL
      IF (addfiltervaluesind)
       CALL loadbrvalues(pos)
      ENDIF
     FOOT  bd.br_datamart_filter_id
      IF (addfiltervaluesind)
       now = alterlist(filter->filters[pos].values,cntx)
      ENDIF
     FOOT REPORT
      row + 0
     WITH expand = 1
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE buildbrcachekey(null)
   DECLARE cache_key = vc WITH protect, noconstant("")
   DECLARE filter_length = i4 WITH protect, noconstant(0)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   IF (prsnl_logical_domain_id=0)
    SET prsnl_logical_domain_id = getprsnldomain(null)
   ENDIF
   IF (textlen(trim(filter->maincatmean,3)) > 0)
    SET br_cache_key->main_cat_mean = filter->maincatmean
    SET br_cache_key->all_ind = filter->allind
    SET br_cache_key->logical_domain_id = prsnl_logical_domain_id
    SET br_cache_key->position_cd = br_flex_by_values->position_cd
    SET br_cache_key->facility_cd = br_flex_by_values->facility_cd
    SET br_cache_key->building_cd = br_flex_by_values->building_cd
    SET br_cache_key->nurse_unit_cd = br_flex_by_values->nurse_unit_cd
    SET filter_length = size(filter->filters,5)
    IF (filter_length > 0)
     SET stat = alterlist(br_cache_key->filters,filter_length)
     SELECT INTO "nl:"
      filter_mean = substring(1,30,filter->filters[d.seq].fileventmean)
      FROM (dummyt d  WITH seq = value(filter_length))
      PLAN (d
       WHERE d.seq > 0)
      ORDER BY filter_mean
      HEAD REPORT
       cnt = 0
      DETAIL
       cnt = (cnt+ 1), br_cache_key->filters[cnt].filter_mean = filter_mean
      WITH nocounter
     ;end select
    ENDIF
    SET cache_key = cnvtrectojson(br_cache_key)
   ENDIF
   RETURN(cache_key)
 END ;Subroutine
 DECLARE 6011_primary_cd = f8 WITH public, constant(uar_get_code_by_cki("CKI.CODEVALUE!3128"))
 DECLARE 16389_ivsolutions_cd = f8 WITH public, constant(uar_get_code_by_cki("CKI.CODEVALUE!33873"))
 DECLARE 6000_pharmacy_cd = f8 WITH public, constant(uar_get_code_by_cki("CKI.CODEVALUE!3079"))
 DECLARE 34_alt_status_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!16901"))
 DECLARE 34_auth_status_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2628"))
 DECLARE 34_mod_status_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2636"))
 DECLARE 339_census_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!5203"))
 DECLARE 69_inpatient_class_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!17006")
  )
 DECLARE 69_observation_class_cd = f8 WITH protect, constant(uar_get_code_by_cki(
   "CKI.CODEVALUE!73451"))
 DECLARE 72_dcpgenericcode_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!1302386"
   ))
 DECLARE begin_dt_tm = dq8 WITH protect, constant(parsedateprompt( $STARTDTTM,curdate,000000))
 DECLARE end_dt_tm = dq8 WITH protect, constant(parsedateprompt( $ENDDTTM,curdate,235959))
 DECLARE this_row = vc WITH public
 DECLARE last_row = vc WITH public
 DECLARE line1 = vc WITH public
 DECLARE output_string = vc WITH public
 DECLARE nidx = i4 WITH public, noconstant(0)
 DECLARE nfilterpos = i4 WITH public, noconstant(0)
 DECLARE nvalsize = i4 WITH public, noconstant(0)
 DECLARE nstartcnt = i4 WITH public, noconstant(0)
 DECLARE e_idx = i4 WITH public, noconstant(0)
 DECLARE a_idx = i4 WITH public, noconstant(0)
 DECLARE b_idx = i4 WITH public, noconstant(0)
 DECLARE cnt = i4 WITH public, noconstant(0)
 DECLARE ln_cnt = i4 WITH public, noconstant(0)
 DECLARE rank_flag = i2 WITH public, noconstant(0)
 DECLARE fileloc = vc WITH protect, noconstant(trim(logical("cer_temp"),3))
 DECLARE filename = vc WITH protect
 DECLARE mnemonic = vc WITH protect
 DECLARE filewrite = vc WITH protect
 DECLARE commwx = vc WITH protect
 DECLARE codesetloc = vc WITH protect
 DECLARE carriage_return = c1 WITH constant(char(13))
 DECLARE line_feed = c1 WITH constant(char(10))
 IF (datetimediff(cnvtdatetime(end_dt_tm),cnvtdatetime(begin_dt_tm)) > 0)
  SET rank_flag = 1
 ENDIF
 IF (((ispromptany(2)) OR (ispromptempty(2))) )
  SET fac_parser = "1=1"
 ELSE
  SET fac_parser = trim(getpromptlist(parameter2( $FACILITY),"ed.loc_facility_cd"),3)
 ENDIF
 SET stat = initrec(filter)
 SET filter->maincatmean = "MP_CLAIRVIA"
 SET filter->allind = 1
 CALL getbrfilters(filter->allind)
 CALL loadbrflexvalues( $BEDROCK_FACILITY)
 CALL loadbedrockfreetextvalue("REPORT_LOCATION","ALPHA",br_prefs->report_location)
 CALL loadbedrockfreetextvalue("REPORT_MNEMONIC","ALPHA",br_prefs->report_name)
 CALL loadbedrockfreetextvalue("INCLUDE_IVIEW","INTEGER",br_prefs->include_iview_ind)
 CALL loadbedrockfreetextvalue("INCLUDE_LABS","INTEGER",br_prefs->include_labs_ind)
 CALL loadbedrockfreetextvalue("INCLUDE_IV","INTEGER",br_prefs->include_iv_ind)
 CALL loadbedrockfreetextvalue("INCLUDE_BB","INTEGER",br_prefs->include_bb_ind)
 IF ((br_prefs->include_iview_ind=1))
  SET nfilterpos = locateval(nidx,1,size(filter->filters,5),"IVIEW_CLIN_EVENTS",filter->filters[nidx]
   .fileventmean)
  SET nvalsize = size(filter->filters[nfilterpos].values,5)
  SET br_prefs->clin_doc_events_cnt = nvalsize
  SET stat = alterlist(br_prefs->clin_doc_events,br_prefs->clin_doc_events_cnt)
  FOR (nvalidx = 1 TO br_prefs->clin_doc_events_cnt)
    SET br_prefs->clin_doc_events[nvalidx].event_cd = filter->filters[nfilterpos].values[nvalidx].
    valeventcd
  ENDFOR
 ENDIF
 IF ((br_prefs->include_labs_ind=1))
  SET nfilterpos = locateval(nidx,1,size(filter->filters,5),"LAB_RESULTS",filter->filters[nidx].
   fileventmean)
  SET nvalsize = size(filter->filters[nfilterpos].values,5)
  IF (nvalsize > 0)
   SET nstartcnt = br_prefs->clin_doc_events_cnt
   SET br_prefs->clin_doc_events_cnt = (br_prefs->clin_doc_events_cnt+ nvalsize)
   SET stat = alterlist(br_prefs->clin_doc_events,br_prefs->clin_doc_events_cnt)
   FOR (nvalidx = 1 TO nvalsize)
     SET br_prefs->clin_doc_events[(nstartcnt+ nvalidx)].event_cd = filter->filters[nfilterpos].
     values[nvalidx].valeventcd
   ENDFOR
  ENDIF
 ENDIF
 IF ((br_prefs->include_bb_ind=1))
  SET nfilterpos = locateval(nidx,1,size(filter->filters,5),"BB_EVENTS",filter->filters[nidx].
   fileventmean)
  SET nvalsize = size(filter->filters[nfilterpos].values,5)
  IF (nvalsize > 0)
   SET nstartcnt = br_prefs->clin_doc_events_cnt
   SET br_prefs->clin_doc_events_cnt = (br_prefs->clin_doc_events_cnt+ nvalsize)
   SET stat = alterlist(br_prefs->clin_doc_events,br_prefs->clin_doc_events_cnt)
   FOR (nvalidx = 1 TO nvalsize)
     SET br_prefs->clin_doc_events[(nstartcnt+ nvalidx)].event_cd = filter->filters[nfilterpos].
     values[nvalidx].valeventcd
   ENDFOR
  ENDIF
 ENDIF
 SET nfilterpos = locateval(nidx,1,size(filter->filters,5),"IV_ORDERS",filter->filters[nidx].
  fileventmean)
 SET nvalsize = size(filter->filters[nfilterpos].values,5)
 SET br_prefs->iv_ingredient_cnt = nvalsize
 SET stat = alterlist(br_prefs->iv_ingredients,br_prefs->iv_ingredient_cnt)
 FOR (nvalidx = 1 TO br_prefs->iv_ingredient_cnt)
   SET br_prefs->iv_ingredients[nvalidx].catalog_cd = filter->filters[nfilterpos].values[nvalidx].
   valeventcd
 ENDFOR
 IF (textlen(trim(br_prefs->report_name,3)) > 0)
  SET filename = build2("CLAIRVIA_REF_DOC_",trim(br_prefs->report_name,3),"_",format(curdate,
    "mmddyyyy;;d"),"_",
   format(curtime3,"hhmmss;3;m"),".txt")
 ELSE
  SET filename = build2("CLAIRVIA_REF_DOC_",format(curdate,"mmddyyyy;;d"),"_",format(curtime3,
    "hhmmss;3;m"),".txt")
 ENDIF
 IF (textlen(trim(br_prefs->report_location,3)) > 0)
  IF (findstring(":",br_prefs->report_location) > 0)
   SET fileloc = br_prefs->report_location
  ELSEIF (substring(textlen(br_prefs->report_location),1,br_prefs->report_location)="/")
   SET fileloc = br_prefs->report_location
  ELSE
   SET fileloc = build2(br_prefs->report_location,"/")
  ENDIF
 ELSE
  IF (substring(textlen(fileloc),1,fileloc) != "/")
   SET fileloc = build2(fileloc,"/")
  ENDIF
 ENDIF
 SET filewrite = build2(fileloc,filename)
 CALL echo(build(";Filename: -->",filewrite))
 IF (((cnvtint(begin_dt_tm)=0) OR (cnvtint(end_dt_tm)=0))
  AND rank_flag=1)
  SET msg_2 = build2("Invalid Date Range.  Enter valid dates and date range of up to 48 hours.  ",
   " Start: ",format(begin_dt_tm,"dd-mm-yyyy hh:mm;;d")," End: ",format(end_dt_tm,
    "dd-mm-yyyy hh:mm;;d"),
   " Hours: ",datediff)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM encntr_domain ed,
   encounter e
  PLAN (ed
   WHERE ed.beg_effective_dt_tm <= cnvtdatetime(end_dt_tm)
    AND ed.end_effective_dt_tm > cnvtdatetime(begin_dt_tm)
    AND ed.active_ind=1
    AND ed.encntr_domain_type_cd=339_census_cd
    AND parser(fac_parser))
   JOIN (e
   WHERE e.encntr_id=ed.encntr_id
    AND e.loc_nurse_unit_cd > 0.00
    AND e.loc_bed_cd > 0.00)
  ORDER BY e.encntr_id
  HEAD REPORT
   drec->encntr_qual_cnt = 0
  HEAD e.encntr_id
   drec->encntr_qual_cnt = (drec->encntr_qual_cnt+ 1)
   IF (mod(drec->encntr_qual_cnt,1000)=1)
    stat = alterlist(drec->encntr_qual,(drec->encntr_qual_cnt+ 999))
   ENDIF
   drec->encntr_qual[drec->encntr_qual_cnt].encntr_id = e.encntr_id
  FOOT  e.encntr_id
   null
  FOOT REPORT
   stat = alterlist(drec->encntr_qual,drec->encntr_qual_cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  a.mnemonic, a.description, activity_type = uar_get_code_display(a.activity_type_cd),
  result_type = uar_get_code_display(a.default_result_type_cd), sex = substring(1,1,
   uar_get_code_display(f.sex_cd)), age_from = concat(trim(cnvtstring((((f.age_from_minutes/ 60)/ 24)
     / 365)))," ",uar_get_code_display(f.age_from_units_cd)),
  age_to = concat(trim(cnvtstring((((f.age_to_minutes/ 60)/ 24)/ 365)))," ",uar_get_code_display(f
    .age_to_units_cd)), nom.source_string, nom.mnemonic
  FROM discrete_task_assay a,
   data_map m,
   reference_range_factor f,
   alpha_responses ar,
   nomenclature nom
  PLAN (a
   WHERE expand(b_idx,1,br_prefs->clin_doc_events_cnt,a.event_cd,br_prefs->clin_doc_events[b_idx].
    event_cd)
    AND a.active_ind=1)
   JOIN (m
   WHERE m.task_assay_cd=outerjoin(a.task_assay_cd))
   JOIN (f
   WHERE f.task_assay_cd=outerjoin(a.task_assay_cd))
   JOIN (ar
   WHERE ar.reference_range_factor_id=outerjoin(f.reference_range_factor_id))
   JOIN (nom
   WHERE nom.nomenclature_id=outerjoin(ar.nomenclature_id))
  ORDER BY a.mnemonic, a.activity_type_cd, f.age_from_minutes,
   f.reference_range_factor_id, ar.sequence
  HEAD REPORT
   cnt = 0, stat = alterlist(map->seq,1000)
  HEAD a.mnemonic
   cnt = (cnt+ 1)
   IF (mod(cnt,1000)=1)
    stat = alterlist(map->seq,(cnt+ 1000))
   ENDIF
   map->seq[cnt].event_code = a.task_assay_cd, map->seq[cnt].clin_event_code = a.event_cd, map->seq[
   cnt].mnemonic = a.mnemonic,
   map->seq[cnt].description = a.description, map->seq[cnt].activity_type = uar_get_code_display(a
    .activity_type_cd), map->seq[cnt].result_type = uar_get_code_display(a.default_result_type_cd),
   r_cnt = 0, last_row = ""
  DETAIL
   IF (nom.source_string > " ")
    this_row = build(sex,"|",age_from,"|",age_to,
     "|",nom.source_string)
    IF (this_row != last_row)
     last_row = this_row, r_cnt = (r_cnt+ 1), stat = alterlist(map->seq[cnt].response,r_cnt),
     map->seq[cnt].response[r_cnt].sex = substring(1,1,uar_get_code_display(f.sex_cd)), map->seq[cnt]
     .response[r_cnt].age_from = concat(trim(cnvtstring((((f.age_from_minutes/ 60)/ 24)/ 365)))," ",
      uar_get_code_display(f.age_from_units_cd)), map->seq[cnt].response[r_cnt].age_to = concat(trim(
       cnvtstring((((f.age_to_minutes/ 60)/ 24)/ 365)))," ",uar_get_code_display(f.age_to_units_cd)),
     map->seq[cnt].response[r_cnt].source_string = nom.source_string
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(map->seq,cnt)
 ;end select
 SET map->event_cnd_cnt = cnt WITH nocounter, expand = 1
 SET ln_cnt = (ln_cnt+ 1)
 SELECT INTO "nl:"
  form_desc = substring(1,50,f.description), section_desc = substring(1,50,s.description)
  FROM dcp_forms_def d,
   dcp_forms_ref f,
   dcp_section_ref s,
   dcp_input_ref i,
   name_value_prefs prf
  PLAN (d
   WHERE d.active_ind=1)
   JOIN (f
   WHERE d.dcp_forms_ref_id=f.dcp_forms_ref_id
    AND f.active_ind=1
    AND f.end_effective_dt_tm > sysdate)
   JOIN (s
   WHERE s.dcp_section_ref_id=d.dcp_section_ref_id
    AND s.active_ind=1
    AND s.end_effective_dt_tm > sysdate)
   JOIN (i
   WHERE i.dcp_section_instance_id=s.dcp_section_instance_id
    AND i.active_ind=1)
   JOIN (prf
   WHERE i.dcp_input_ref_id=prf.parent_entity_id
    AND prf.merge_name="DISCRETE_TASK_ASSAY"
    AND prf.merge_id != 0.00
    AND prf.active_ind=1)
  ORDER BY prf.merge_id, f.description, s.description
  DETAIL
   this_row = build(f.description,s.description)
   IF (this_row != last_row)
    a_idx = locateval(b_idx,1,size(map->seq,5),prf.merge_id,map->seq[b_idx].event_code)
    IF (a_idx > 0)
     last_row = this_row, pf_cnt = (size(map->seq[a_idx].pf,5)+ 1), stat = alterlist(map->seq[a_idx].
      pf,pf_cnt),
     map->seq[a_idx].pf[pf_cnt].form_desc = f.description, map->seq[a_idx].pf[pf_cnt].section_desc =
     s.description
    ENDIF
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  wview = wv.display_name, section = substring(1,50,wvs.event_set_name), section_required =
  IF (wvs.required_ind=1) "y"
  ELSE "n"
  ENDIF
  ,
  section_included =
  IF (wvs.included_ind) "i"
  ELSE "e"
  ENDIF
  , event_set = substring(1,50,wvi.primitive_event_set_name), event_set_parent = substring(1,50,wvi
   .parent_event_set_name),
  item_event_cd = vec.event_cd, item_dta_event_cd = dta.task_assay_cd, item_included = wvi
  .included_ind,
  dta = dta.mnemonic, vec.event_cd
  FROM discrete_task_assay dta,
   v500_event_code vec,
   working_view_item wvi,
   working_view_section wvs,
   working_view wv
  PLAN (dta
   WHERE expand(b_idx,1,br_prefs->clin_doc_events_cnt,dta.event_cd,br_prefs->clin_doc_events[b_idx].
    event_cd))
   JOIN (vec
   WHERE vec.event_cd=dta.event_cd)
   JOIN (wvi
   WHERE cnvtupper(wvi.primitive_event_set_name)=cnvtupper(vec.event_set_name))
   JOIN (wvs
   WHERE wvs.working_view_section_id=wvi.working_view_section_id)
   JOIN (wv
   WHERE wv.working_view_id=wvs.working_view_id
    AND wv.active_ind=1)
  ORDER BY dta.task_assay_cd, wv.display_name, wvs.event_set_name
  DETAIL
   this_row = build(wv.display_name,wvs.event_set_name)
   IF (this_row != last_row)
    last_row = this_row, a_idx = locateval(b_idx,1,size(map->seq,5),dta.task_assay_cd,map->seq[b_idx]
     .event_code)
    IF (a_idx > 0)
     wv_cnt = (size(map->seq[a_idx].iview,5)+ 1), stat = alterlist(map->seq[a_idx].iview,wv_cnt), map
     ->seq[a_idx].iview[wv_cnt].view_desc = concat("IVIEW-",wv.display_name),
     map->seq[a_idx].iview[wv_cnt].section_desc = wvs.event_set_name
    ENDIF
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM order_catalog_synonym ocs,
   cs_component c,
   order_catalog_synonym ocs2,
   order_catalog_synonym ocs3
  PLAN (ocs
   WHERE ocs.catalog_type_cd=6000_pharmacy_cd
    AND ocs.dcp_clin_cat_cd=16389_ivsolutions_cd
    AND ocs.mnemonic_type_cd=6011_primary_cd
    AND  NOT (cnvtupper(ocs.mnemonic) IN ("ZZ*", "OBSOLETE*"))
    AND ocs.active_ind=1)
   JOIN (c
   WHERE c.catalog_cd=ocs.catalog_cd)
   JOIN (ocs2
   WHERE ocs2.synonym_id=c.comp_id)
   JOIN (ocs3
   WHERE ocs3.catalog_cd=ocs2.catalog_cd
    AND expand(b_idx,1,br_prefs->iv_ingredient_cnt,ocs3.catalog_cd,br_prefs->iv_ingredients[b_idx].
    catalog_cd)
    AND ocs3.mnemonic_type_cd=6011_primary_cd)
  ORDER BY ocs3.catalog_cd
  HEAD REPORT
   cnt = size(map->seq,5), stat = alterlist(map->seq,(cnt+ 1000))
  HEAD ocs3.catalog_cd
   cnt = (cnt+ 1)
   IF (mod(cnt,1000)=1)
    stat = alterlist(map->seq,(cnt+ 1000))
   ENDIF
   map->seq[cnt].event_code = ocs3.catalog_cd, map->seq[cnt].mnemonic = ocs3.mnemonic, map->seq[cnt].
   description = uar_get_code_display(ocs3.dcp_clin_cat_cd),
   map->seq[cnt].activity_type = uar_get_code_display(ocs.catalog_type_cd), map->seq[cnt].result_type
    = "AlphaNumeric", map->seq[cnt].clin_event_code = ocs3.catalog_cd
  FOOT REPORT
   stat = alterlist(map->seq,cnt)
 ;end select
 SET map->event_cnd_cnt = cnt WITH nocounter, expand = 1
 IF (rank_flag=0)
  GO TO mapping_output
 ENDIF
 SELECT INTO "nl:"
  FROM encounter e,
   clinical_event ce
  PLAN (e
   WHERE expand(e_idx,1,drec->encntr_qual_cnt,e.encntr_id,drec->encntr_qual[e_idx].encntr_id)
    AND e.encntr_type_class_cd IN (69_inpatient_class_cd, 69_observation_class_cd))
   JOIN (ce
   WHERE ce.person_id=e.person_id
    AND ((expand(b_idx,1,br_prefs->clin_doc_events_cnt,ce.event_cd,br_prefs->clin_doc_events[b_idx].
    event_cd)) OR (expand(b_idx,1,br_prefs->iv_ingredient_cnt,ce.catalog_cd,br_prefs->iv_ingredients[
    b_idx].catalog_cd)))
    AND ce.event_end_dt_tm != null
    AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime3)
    AND ce.clinsig_updt_dt_tm BETWEEN cnvtdatetime(begin_dt_tm) AND cnvtdatetime(end_dt_tm)
    AND ce.result_status_cd IN (34_mod_status_cd, 34_auth_status_cd, 34_alt_status_cd)
    AND ce.event_cd != 72_dcpgenericcode_cd
    AND ce.encntr_id=e.encntr_id)
  ORDER BY ce.event_cd
  HEAD ce.event_cd
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
  FOOT  ce.event_cd
   a_idx = 0, loop_cntr = 0
   WHILE (a_idx=0
    AND loop_cntr < size(map->seq,5))
    loop_cntr = (loop_cntr+ 1),
    IF ((((ce.task_assay_cd=map->seq[loop_cntr].event_code)) OR ((((ce.event_cd=map->seq[loop_cntr].
    clin_event_code)) OR ((ce.catalog_cd=map->seq[loop_cntr].event_code))) )) )
     a_idx = loop_cntr, map->seq[a_idx].code_cnt = cnt
    ENDIF
   ENDWHILE
  WITH nocounter, expand = 1
 ;end select
#mapping_output
 SET frec->file_name = filewrite
 SET frec->file_buf = "w"
 SET stat = cclio("OPEN",frec)
 SET ln_cnt = 0
 IF (stat > 0
  AND (map->event_cnd_cnt > 0))
  SET line1 = build("LINE|RANK|CODE_VALUE|MNE|DESCRIPTION|ACTIVITY_TYPE|RESULT_TYPE|",
   "SEX|AGE_FROM|AGE_TO|SOURCE_STRING|POWERFORM|PFSECTION|IVIEW|IVIEWSECTION|BEDROCK_PREF")
  SET frec->file_buf = concat(line1,carriage_return,line_feed)
  SET stat = cclio("WRITE",frec)
  FOR (x = 1 TO map->event_cnd_cnt)
    IF (((commwx != "Y") OR ((map->seq[x].code_cnt > 0))) )
     FOR (a = 1 TO maxval(1,size(map->seq[x].pf,5),size(map->seq[x].response,5),size(map->seq[x].
       iview,5)))
       SET ln_cnt = (ln_cnt+ 1)
       SET output_string = build(ln_cnt,"|",map->seq[x].code_cnt,"|",map->seq[x].event_code,
        "|",map->seq[x].mnemonic,"|",map->seq[x].description,"|",
        map->seq[x].activity_type,"|",map->seq[x].result_type,"|")
       IF (a <= size(map->seq[x].response,5))
        SET output_string = build(output_string,map->seq[x].response[a].sex,"|",map->seq[x].response[
         a].age_from,"|",
         map->seq[x].response[a].age_to,"|",map->seq[x].response[a].source_string,"|")
       ELSE
        SET output_string = build(output_string,"||||")
       ENDIF
       IF (a <= size(map->seq[x].pf,5))
        SET output_string = build(output_string,map->seq[x].pf[a].form_desc,"|",map->seq[x].pf[a].
         section_desc,"|")
       ELSE
        SET output_string = build(output_string,"||")
       ENDIF
       IF (a <= size(map->seq[x].iview,5))
        SET output_string = build(output_string,map->seq[x].iview[a].view_desc,"|",map->seq[x].iview[
         a].section_desc,"|")
       ELSE
        SET output_string = build(output_string,"||")
       ENDIF
       SET output_string = build(output_string,uar_get_code_display(map->seq[x].clin_event_code))
       SET output_string = replace(output_string,char(0),"")
       SET output_string = replace(output_string,char(10),"")
       SET output_string = replace(output_string,char(13),"")
       SET frec->file_buf = concat(output_string,carriage_return,line_feed)
       SET stat = cclio("WRITE",frec)
     ENDFOR
    ENDIF
  ENDFOR
  CALL logmsg(build2("Extract written to ",filewrite))
 ELSE
  CALL logmsg(build2("No Data found for date range ",format(begin_dt_tm,";;q")," to ",format(
     end_dt_tm,";;q")))
 ENDIF
 SET stat = cclio("CLOSE",frec)
#exit_script
 SELECT INTO  $OUTDEV
  FROM (dummyt d  WITH seq = 1)
  DETAIL
   CALL print(format(sysdate,";;q")), row + 1,
   CALL print(build2("Clairvia Reference Data Mapping Extract (",trim(curprog),") node:",curnode)),
   row + 1,
   CALL print(build2("Date Range: ",format(begin_dt_tm,";;q")," to ",format(end_dt_tm,";;q"))), row
    + 1
   IF (size(map->seq,5) > 0)
    CALL print(build2("Extract file written to: ",trim(filewrite,3)," The file should contain ",trim(
      cnvtstring(ln_cnt))," records."))
   ELSE
    CALL print("No qualifying data found.")
   ENDIF
  WITH nocounter, maxcol = 10000, separator = " ",
   format = variable, maxrow = 1
 ;end select
 SET last_mod =
 "000  10/29/2019   Michael Keesee CCPS-17434 - Utilize Bedrock filters to determine what data to reference"
END GO
