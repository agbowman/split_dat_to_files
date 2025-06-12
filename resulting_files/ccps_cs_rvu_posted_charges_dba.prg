CREATE PROGRAM ccps_cs_rvu_posted_charges:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin Date" = "CURDATE",
  "End Date" = "CURDATE",
  "Organization" = 0,
  "Report Type" = 0,
  "Summary By" = 0,
  "Physician Specific Sort" = 0
  WITH outdev, beg_date, end_date,
  organization, rpt_type, summary_by,
  phys_spec_sort
 DECLARE parsedateprompt(date_str=vc,default_date=vc,time=i4) = dq8
 DECLARE _evaluatedatestr(date_str=vc) = i4
 DECLARE _parsedate(date_str=vc) = i4
 SUBROUTINE parsedateprompt(date_str,default_date,time)
   DECLARE _return_val = dq8 WITH noconstant, private
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
   DECLARE _return_val = dq8 WITH noconstant, private
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
   DECLARE _dq8 = dq8 WITH noconstant, private
   DECLARE _parse = vc WITH constant(concat("set _dq8 = cnvtdatetime(",date_str,", 0) go")), private
   CALL parser(_parse)
   RETURN(cnvtdate(_dq8))
 END ;Subroutine
 DECLARE beg_dt_tm = dq8 WITH constant(parsedateprompt( $BEG_DATE,(curdate - 1),000000)), protect
 DECLARE end_dt_tm = dq8 WITH constant(parsedateprompt( $END_DATE,(curdate - 1),235959)), protect
 DECLARE ea_type_fin_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"FIN NBR")), protect
 DECLARE bill_code_cd = f8 WITH constant(uar_get_code_by("MEANING",13019,"BILL CODE")), protect
 DECLARE workload_cd = f8 WITH constant(uar_get_code_by("MEANING",13019,"WORKLOAD")), protect
 DECLARE standard_cd = f8 WITH constant(uar_get_code_by("MEANING",13031,"STANDARD")), protect
 DECLARE credit_chrg_type_cd = f8 WITH constant(uar_get_code_by("MEANING",13028,"CR")), protect
 DECLARE debit_chrg_type_cd = f8 WITH constant(uar_get_code_by("MEANING",13028,"DR")), protect
 DECLARE prompt_dates = vc WITH constant(concat("Begin Date:  ",format(beg_dt_tm,"@SHORTDATE"),
   "  End Date:  ",format(end_dt_tm,"@SHORTDATE")))
 DECLARE exec_date_str = vc WITH constant(concat("Execution Date/Time:  ",format(cnvtdatetime(curdate,
     curtime),"@SHORTDATETIME")))
 DECLARE no_data_title = vc WITH noconstant(" "), public
 DECLARE foot_summary_text = vc WITH constant("TOTAL Posted Charges")
 DECLARE foot_phys_summary_text = vc WITH constant("TOTAL Posted Charges with RVU")
 DECLARE summary_by_prompt = vc WITH noconstant("Posted Charge Summary")
 DECLARE phys_spec_sort_prompt = vc WITH noconstant("Verifying Physician Summary")
 DECLARE multi_select = vc WITH constant("Multiple Organizations Selected")
 DECLARE any_all_select = vc WITH constant("All Qualifying Organizations")
 DECLARE summary_by_prompt = vc WITH noconstant("Posted Charge Summary")
 DECLARE prompt_organization = vc WITH noconstant(" "), public
 DECLARE rpt_output_excel = i2 WITH constant(1), protect
 DECLARE rpt_output_paper_summary = i2 WITH constant(3), protect
 DECLARE rpt_output_paper_phys = i2 WITH constant(4), protect
 DECLARE rpt_output_type = i2 WITH noconstant(0), protect
 DECLARE temp_rvu = f8 WITH noconstant(0.00), public
 DECLARE num = i4 WITH noconstant(0), public
 DECLARE index = i4 WITH noconstant(0), public
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
     component_cnt = (component_cnt+ 1), component = trim(piece(entity,";",component_cnt,"Not Found"),
      3), component_head = trim(piece(cnvtlower(component),":",1,"Not Found"),3),
     component_value = trim(piece(component,":",2,"Not Found"),3)
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
 SET lastmod = "001  9/11/12   ML011047"
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
 IF ( NOT (validate(reply->status_data)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE ld_concept_person = i2 WITH public, constant(1)
 DECLARE ld_concept_prsnl = i2 WITH public, constant(2)
 DECLARE ld_concept_organization = i2 WITH public, constant(3)
 DECLARE ld_concept_healthplan = i2 WITH public, constant(4)
 DECLARE ld_concept_alias_pool = i2 WITH public, constant(5)
 DECLARE ld_concept_encounter = i2 WITH public, constant(6)
 DECLARE ld_concept_location = i2 WITH public, constant(7)
 DECLARE ld_concept_pft_encntr = i2 WITH public, constant(8)
 DECLARE ld_concept_billing = i2 WITH public, constant(9)
 DECLARE invalid_printer = i2 WITH public, constant(1)
 DECLARE invalid_user = i2 WITH public, constant(2)
 DECLARE invalid_ld = i2 WITH public, constant(3)
 DECLARE ops_scheduler = i4 WITH public, constant(4600)
 DECLARE ops_monitor = i4 WITH public, constant(4700)
 DECLARE ops_server = i4 WITH public, constant(4800)
 DECLARE isopsjob = i2 WITH public, constant(isopsexecution(null))
 DECLARE ismine = i2 WITH public, constant(ismine(null))
 DECLARE logical_domain_error = i4 WITH public, noconstant(0)
 DECLARE cur_logical_domain = f8 WITH public, constant(getcurrentlogicaldomain(reqinfo->updt_id))
 IF (cur_logical_domain < 0)
  SET logical_domain_error = cnvtint(abs(cur_logical_domain))
 ENDIF
 IF (textlen(trim(reflect(parameter(1,0)),3)) > 0)
  IF (ispromptsingle(1)
   AND substring(1,1,reflect(parameter(1,1)))="C")
   IF ( NOT (isprinterindomain(value(parameter(1,0)),cur_logical_domain)))
    SET logical_domain_error = invalid_printer
   ENDIF
  ENDIF
 ENDIF
 DECLARE isuserindomain(user_id=f8,log_domain_id=f8) = i2
 SUBROUTINE isuserindomain(user_id,log_domain_id)
   DECLARE return_val = i2 WITH noconstant(- (1)), protect
   DECLARE b_logicaldomain = i4 WITH constant(column_exists("PRSNL","LOGICAL_DOMAIN_ID")), protect
   DECLARE user_domain_grp_id = f8 WITH noconstant(0.0), protect
   IF (b_logicaldomain)
    SELECT INTO "nl:"
     FROM prsnl p
     PLAN (p
      WHERE p.person_id=user_id)
     HEAD p.person_id
      user_domain_grp_id = p.logical_domain_grp_id
      IF (user_domain_grp_id=0.0)
       IF (p.logical_domain_id=log_domain_id)
        return_val = 1
       ELSE
        return_val = 0
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF (user_domain_grp_id > 0.0)
     SELECT INTO "nl:"
      FROM logical_domain_grp_reltn ld
      PLAN (ld
       WHERE ld.logical_domain_grp_id=user_domain_grp_id
        AND ld.active_ind=1
        AND ld.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND ld.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      HEAD ld.logical_domain_grp_id
       return_val = 0
      HEAD ld.logical_domain_id
       IF (ld.logical_domain_id=log_domain_id)
        return_val = 1
       ENDIF
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 DECLARE isorgindomain(org_id=f8,log_domain_id=f8) = i2
 SUBROUTINE isorgindomain(org_id,log_domain_id)
   DECLARE return_val = i2 WITH noconstant(- (1)), protect
   DECLARE b_logicaldomain = i4 WITH constant(column_exists("ORGANIZATION","LOGICAL_DOMAIN_ID")),
   protect
   IF (b_logicaldomain)
    SELECT INTO "nl:"
     FROM organization o
     PLAN (o
      WHERE o.organization_id=org_id)
     HEAD o.organization_id
      IF (o.logical_domain_id=log_domain_id)
       return_val = 1
      ELSE
       return_val = 0
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 DECLARE isorginuserdomain(org_id=f8,user_id=f8) = i2
 SUBROUTINE isorginuserdomain(org_id,user_id)
   DECLARE return_val = i2 WITH noconstant(- (1)), protect
   DECLARE org_domain_id = f8 WITH noconstant(0.0), protect
   DECLARE b_logicaldomain = i4 WITH noconstant(column_exists("ORGANIZATION","LOGICAL_DOMAIN_ID")),
   protect
   IF (b_logicaldomain)
    SELECT INTO "nl:"
     FROM organization o
     PLAN (o
      WHERE o.organization_id=org_id)
     HEAD o.organization_id
      org_domain_id = o.logical_domain_id
     WITH nocounter
    ;end select
    SET return_val = isuserindomain(user_id,org_domain_id)
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 DECLARE islogicaldomainsactive(null) = i2
 SUBROUTINE islogicaldomainsactive(null)
   DECLARE return_val = i4 WITH noconstant(0), protect
   DECLARE b_logicaldomain = i4 WITH noconstant(column_exists("LOGICAL_DOMAIN","LOGICAL_DOMAIN_ID")),
   protect
   DECLARE ld_id = f8 WITH noconstant(0.0), protect
   DECLARE cnt = i4 WITH noconstant(0), protect
   IF (b_logicaldomain)
    SELECT INTO "nl:"
     FROM logical_domain ld
     PLAN (ld
      WHERE ld.logical_domain_id > 0.0
       AND ld.active_ind=1)
     ORDER BY ld.logical_domain_id
     HEAD ld.logical_domain_id
      return_val = 1
     WITH nocounter
    ;end select
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 DECLARE column_exists(stable=vc,scolumn=vc) = i4
 SUBROUTINE column_exists(stable,scolumn)
   DECLARE return_val = i4 WITH noconstant(0), protect
   DECLARE ce_temp = vc WITH noconstant(""), protect
   SET stable = cnvtupper(stable)
   SET scolumn = cnvtupper(scolumn)
   IF (((currev=8
    AND currevminor=2
    AND currevminor2 >= 4) OR (((currev=8
    AND currevminor > 2) OR (currev > 8)) )) )
    SET ce_temp = build('"',stable,".",scolumn,'"')
    SET stat = checkdic(parser(ce_temp),"A",0)
    IF (stat > 0)
     SET return_val = 1
    ENDIF
   ELSE
    SELECT INTO "nl:"
     l.attr_name
     FROM dtableattr a,
      dtableattrl l
     WHERE a.table_name=stable
      AND l.attr_name=scolumn
      AND l.structtype="F"
      AND btest(l.stat,11)=0
     DETAIL
      return_val = 1
     WITH nocounter
    ;end select
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 DECLARE getcurrentlogicaldomain(user_id=f8(value,0.0)) = f8
 SUBROUTINE getcurrentlogicaldomain(user_id)
   DECLARE return_val = f8 WITH noconstant(0.0), protect
   IF (isopsjob)
    SET return_val = getopslogicaldomain(null)
   ELSE
    IF (islogicaldomainsactive(null))
     SELECT INTO "nl:"
      FROM prsnl p
      PLAN (p
       WHERE p.person_id=user_id)
      HEAD p.person_id
       return_val = p.logical_domain_id
      WITH nocounter
     ;end select
     IF (curqual <= 0)
      SET return_val = - (2.0)
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].operationname = curprog
      SET reply->status_data.subeventstatus[1].targetobjectname = "getCurrentLogicalDomain"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = build2("User ",trim(cnvtstring(
         user_id),3)," is not related to a Logical Domain.")
     ENDIF
    ENDIF
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 DECLARE getopslogicaldomain(null) = f8
 SUBROUTINE getopslogicaldomain(null)
   DECLARE return_val = f8 WITH noconstant(0.0), protect
   DECLARE last_prompt = i4 WITH noconstant(0), protect
   DECLARE ld_prompt_val = vc WITH noconstant(""), protect
   DECLARE ld_prompt_prefix = vc WITH noconstant(""), protect
   DECLARE ld_prompt_id = vc WITH noconstant(""), protect
   IF (isopsjob)
    IF (islogicaldomainsactive(null))
     WHILE (textlen(trim(reflect(parameter((last_prompt+ 1),0)),3)) > 0)
       SET last_prompt = (last_prompt+ 1)
     ENDWHILE
     IF (last_prompt > 0
      AND ispromptsingle(last_prompt)
      AND substring(1,1,reflect(parameter(last_prompt,1)))="C")
      SET ld_prompt_val = trim(check(cnvtupper(value(parameter(last_prompt,1))),char(40)),3)
      SET ld_prompt_prefix = substring(1,3,ld_prompt_val)
      IF (ld_prompt_prefix="LD:")
       SET return_val = - (3.0)
       SET ld_prompt_id = substring(4,(textlen(ld_prompt_val) - 3),ld_prompt_val)
       IF (isnumeric(ld_prompt_id))
        SELECT INTO "nl:"
         FROM logical_domain ld
         PLAN (ld
          WHERE ld.logical_domain_id=cnvtreal(ld_prompt_id)
           AND ld.active_ind=1)
         ORDER BY ld.logical_domain_id
         HEAD ld.logical_domain_id
          return_val = ld.logical_domain_id
         WITH nocounter
        ;end select
       ENDIF
       IF ((return_val=- (3.0)))
        SET reply->status_data.subeventstatus[1].targetobjectvalue = build2("Logical Domain ID ",
         ld_prompt_id," is not valid.")
       ENDIF
      ELSE
       SET return_val = - (3.0)
       SET reply->status_data.subeventstatus[1].targetobjectvalue = build2(
        "Batch Selection is Missing the ","Logical Domain Prefix, e.g., 'LD:'.")
      ENDIF
     ELSE
      SET return_val = - (3.0)
      SET reply->status_data.subeventstatus[1].targetobjectvalue = build2(
       "Batch Selection is Missing the ","Logical Domain Prefix and ID, e.g., ","'LD:1234.00'.")
     ENDIF
     IF (return_val < 0.0)
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].operationname = curprog
      SET reply->status_data.subeventstatus[1].targetobjectname = "getOpsLogicalDomain"
     ENDIF
    ENDIF
   ELSE
    SET return_val = - (2.0)
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 DECLARE ismine(null) = i2
 SUBROUTINE ismine(null)
   DECLARE return_val = i2 WITH noconstant(0), private
   IF (textlen(trim(reflect(parameter(1,0)),3)) > 0)
    IF (ispromptsingle(1)
     AND substring(1,1,reflect(parameter(1,1)))="C")
     IF (((cnvtupper(validate(request->qual[1].parameter,"NOT MINE"))="MINE") OR (cnvtupper(trim(
       check(value(parameter(1,1)),char(40)),3))="MINE")) )
      SET return_val = 1
     ENDIF
    ENDIF
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 DECLARE isprinterindomain(output_dest=vc,log_domain_id=f8) = i2
 SUBROUTINE isprinterindomain(output_dest,log_domain_id)
   DECLARE cur_printer = vc WITH constant(trim(check(output_dest,char(40)),3)), protect
   DECLARE isvalid = i2 WITH noconstant(0), protect
   IF (islogicaldomainsactive(null))
    IF (checkqueue(cur_printer))
     SELECT INTO "nl:"
      FROM output_dest od,
       device d,
       location l,
       organization o
      PLAN (od
       WHERE od.name=cur_printer)
       JOIN (d
       WHERE d.device_cd=od.device_cd)
       JOIN (l
       WHERE l.location_cd=d.location_cd
        AND l.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND l.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
        AND l.active_ind=1)
       JOIN (o
       WHERE o.organization_id=l.organization_id
        AND o.logical_domain_id=log_domain_id
        AND o.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND o.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
        AND o.active_ind=1)
      ORDER BY o.logical_domain_id
      HEAD REPORT
       isvalid = 1
      WITH nocounter
     ;end select
     IF ( NOT (isvalid)
      AND  NOT (logical_domain_error))
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].operationname = curprog
      SET reply->status_data.subeventstatus[1].targetobjectname = "IsPrinterInDomain"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = build2("Printer ",cur_printer,
       " is not valid ","for Logical Domain ID ",trim(cnvtstring(log_domain_id),3),
       ".")
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 DECLARE getldconceptparser(pconcept=i2,pfield=vc,plogicaldomainid=f8,pprompt=i2(value,0),poption=i2(
   value,list_in)) = vc
 SUBROUTINE getldconceptparser(pconcept,pfield,plogicaldomainid,pprompt,poption)
   DECLARE return_val = vc WITH private, noconstant("1=1")
   IF (pprompt > 0)
    IF ( NOT (ispromptempty(pprompt))
     AND  NOT (ispromptany(pprompt)))
     SET return_val = getpromptlist(pprompt,pfield,poption)
    ENDIF
   ENDIF
   CASE (pconcept)
    OF ld_concept_person:
     IF (column_exists("PERSON","LOGICAL_DOMAIN_ID"))
      SET return_val = build2(return_val," and exists"," (select 1"," from person p_ld",
       " where p_ld.person_id = ",
       pfield," and p_ld.logical_domain_id = ",plogicaldomainid,")")
     ENDIF
    OF ld_concept_prsnl:
     IF (column_exists("PRSNL","LOGICAL_DOMAIN_ID"))
      SET return_val = build2(return_val," and exists"," (select 1"," from prsnl p_ld",
       " where p_ld.person_id = ",
       pfield," and p_ld.logical_domain_id = ",plogicaldomainid,")")
     ENDIF
    OF ld_concept_organization:
     IF (column_exists("ORGANIZATION","LOGICAL_DOMAIN_ID"))
      SET return_val = build2(return_val," and exists"," (select 1"," from organization o_ld",
       " where o_ld.organization_id = ",
       pfield," and o_ld.logical_domain_id = ",plogicaldomainid,")")
     ENDIF
    OF ld_concept_healthplan:
     IF (column_exists("HEALTH_PLAN","LOGICAL_DOMAIN_ID"))
      SET return_val = build2(return_val," and exists"," (select 1"," from health_plan hp_ld",
       " where hp_ld.health_plan_id = ",
       pfield," and hp_ld.logical_domain_id = ",plogicaldomainid,")")
     ENDIF
    OF ld_concept_alias_pool:
     IF (column_exists("ALIAS_POOL","LOGICAL_DOMAIN_ID"))
      SET return_val = build2(return_val," and exists"," (select 1"," from alias_pool ap_ld",
       " where ap_ld.alias_pool_cd = ",
       pfield," and ap_ld.logical_domain_id = ",plogicaldomainid,")")
     ENDIF
    OF ld_concept_encounter:
     IF (column_exists("PERSON","LOGICAL_DOMAIN_ID"))
      SET return_val = build2(return_val," and exists"," (select 1",
       " from encounter e_ld, person p_ld"," where e_ld.encntr_id = ",
       pfield," and p_ld.person_id = e_ld.person_id"," and p_ld.logical_domain_id = ",
       plogicaldomainid,")")
     ENDIF
    OF ld_concept_location:
     IF (column_exists("ORGANIZATION","LOGICAL_DOMAIN_ID"))
      SET return_val = build2(return_val," and exists"," (select 1",
       " from location l_ld, organization o_ld"," where l_ld.location_cd = ",
       pfield," and o_ld.organization_id = l_ld.organization_id"," and o_ld.logical_domain_id = ",
       plogicaldomainid,")")
     ENDIF
    OF ld_concept_pft_encntr:
     IF (column_exists("PERSON","LOGICAL_DOMAIN_ID"))
      SET return_val = build2(return_val," and exists"," (select 1",
       " from pft_encntr pe_ld, encounter e_ld, person p_ld"," where pe_ld.pft_encntr_id = ",
       pfield," and e_ld.encntr_id = pe_ld.encntr_id"," and p_ld.person_id = e_ld.person_id",
       " and p_ld.logical_domain_id = ",plogicaldomainid,
       ")")
     ENDIF
    OF ld_concept_billing:
     IF (column_exists("ORGANIZATION","LOGICAL_DOMAIN_ID"))
      SET return_val = build2(return_val," and exists"," (select 1",
       " from billing_entity be_ld, organization o_ld"," where be_ld.billing_entity_id = ",
       pfield," and o_ld.organization_id = be_ld.organization_id"," and o_ld.logical_domain_id = ",
       plogicaldomainid,")")
     ENDIF
    ELSE
     SET return_val = "0=1"
   ENDCASE
   RETURN(return_val)
 END ;Subroutine
 DECLARE isopsexecution(null) = i2
 SUBROUTINE isopsexecution(null)
   DECLARE return_val = i2 WITH private, noconstant(0)
   IF (validate(reqinfo->updt_app,- (1)) IN (ops_scheduler, ops_monitor, ops_server))
    SET return_val = true
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 IF ( NOT (validate(list_in)))
  DECLARE list_in = i2 WITH protect, constant(1)
 ENDIF
 IF ( NOT (validate(list_not_in)))
  DECLARE list_not_in = i2 WITH protect, constant(2)
 ENDIF
 IF ( NOT (validate(cs278_facility)))
  DECLARE cs278_facility = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!4977"))
 ENDIF
 IF ( NOT (validate(cs278_client)))
  DECLARE cs278_client = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!4974"))
 ENDIF
 IF ( NOT (validate(ccps_org_sec_rec)))
  RECORD ccps_org_sec_rec(
    1 cnt = i4
    1 list[*]
      2 organization_id = f8
      2 logical_domain_id = f8
      2 name = vc
    1 prsnl_id = f8
    1 org_type_cd = f8
    1 num = i4
  )
 ENDIF
 DECLARE isencntrorgsecurityon(null) = i2
 SUBROUTINE isencntrorgsecurityon(null)
   DECLARE return_val = i2 WITH protect, noconstant(0)
   IF (validate(ccldminfo->mode,0))
    IF ((ccldminfo->sec_org_reltn > 0))
     SET return_val = 1
    ENDIF
   ELSE
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_name="SEC_ORG_RELTN"
      AND di.info_domain="SECURITY"
      AND di.info_number > 0.0
     DETAIL
      return_val = 1
     WITH nocounter
    ;end select
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 DECLARE isconfidentialitysecurityon(null) = i2
 SUBROUTINE isconfidentialitysecurityon(null)
   DECLARE return_val = i2 WITH protect, noconstant(0)
   IF (validate(ccldminfo->mode,0))
    IF ((ccldminfo->sec_confid > 0))
     SET return_val = 1
    ENDIF
   ELSE
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_name="SEC_CONFID"
      AND di.info_domain="SECURITY"
      AND di.info_number > 0.0
     DETAIL
      return_val = 1
     WITH nocounter
    ;end select
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 DECLARE ispersonorgsecurityon(null) = i2
 SUBROUTINE ispersonorgsecurityon(null)
   DECLARE return_val = i2 WITH protect, noconstant(0)
   IF (validate(ccldminfo->mode,0))
    IF ((ccldminfo->person_org_sec > 0))
     SET return_val = 1
    ENDIF
   ELSE
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_name="PERSON_ORG_SEC"
      AND di.info_domain="SECURITY"
      AND di.info_number > 0.0
     DETAIL
      return_val = 1
     WITH nocounter
    ;end select
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 DECLARE getprsnlorglist(prsnl_id=f8,which_column=vc,which_option=i2(value,list_in),org_type_cd=f8(
   value,cs278_facility)) = vc
 SUBROUTINE getprsnlorglist(prsnl_id,which_column,which_option,org_type_cd)
   DECLARE option_str = vc WITH private, noconstant(" ")
   DECLARE idx = i4 WITH private, noconstant(0)
   DECLARE return_val = vc WITH private, noconstant("0=1")
   IF (getprsnlorgrecord(prsnl_id,org_type_cd))
    IF (which_option=list_not_in)
     SET option_str = " not in ("
    ELSE
     SET option_str = " in ("
    ENDIF
    SET return_val = concat("(",which_column,option_str)
    FOR (idx = 1 TO ccps_org_sec_rec->cnt)
     IF (mod(idx,1000)=1
      AND idx > 1)
      SET return_val = replace(return_val,",",")",2)
      SET return_val = concat(return_val," or ",which_column,option_str)
     ENDIF
     SET return_val = build(return_val,ccps_org_sec_rec->list[idx].organization_id,",")
    ENDFOR
    SET return_val = replace(return_val,",",")",2)
    SET return_val = concat(return_val,")")
   ENDIF
   CALL logmsg(concat("GetPrsnlOrgList: return value = ",return_val))
   RETURN(return_val)
 END ;Subroutine
 DECLARE getprsnlorgexpand(prsnl_id=f8,which_column=vc,which_option=i2(value,list_in),org_type_cd=f8(
   value,cs278_facility)) = vc
 SUBROUTINE getprsnlorgexpand(prsnl_id,which_column,which_option,org_type_cd)
   DECLARE return_val = vc WITH private, noconstant("0=1")
   DECLARE option_str = vc WITH private, noconstant(" ")
   IF (getprsnlorgrecord(prsnl_id,org_type_cd))
    IF (which_option=list_not_in)
     SET option_str = " NOT"
    ENDIF
    SET return_val = build(option_str," expand(ccps_org_sec_rec->num,","1,","ccps_org_sec_rec->cnt,",
     which_column,
     ",","ccps_org_sec_rec->list[ccps_org_sec_rec->num].organization_id)")
   ENDIF
   CALL logmsg(concat("GetPrsnlOrgExpand: return value = ",return_val))
   RETURN(return_val)
 END ;Subroutine
 DECLARE getprsnlorgrecord(prsnl_id=f8,org_type_cd=f8(value,cs278_facility)) = i2
 SUBROUTINE getprsnlorgrecord(prsnl_id,org_type_cd)
   DECLARE return_val = i2 WITH private, noconstant(0)
   SET ccps_org_sec_rec->prsnl_id = prsnl_id
   SET ccps_org_sec_rec->org_type_cd = org_type_cd
   SELECT INTO "nl:"
    FROM prsnl_org_reltn por,
     organization o,
     org_type_reltn otr
    PLAN (por
     WHERE por.person_id=prsnl_id
      AND por.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND por.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND por.active_ind=1)
     JOIN (o
     WHERE o.organization_id=por.organization_id
      AND o.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND o.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND o.active_ind=1)
     JOIN (otr
     WHERE otr.organization_id=o.organization_id
      AND ((otr.org_type_cd+ 0)=org_type_cd)
      AND otr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND otr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND otr.active_ind=1)
    ORDER BY por.organization_id
    HEAD REPORT
     cnt = 0
    HEAD por.organization_id
     cnt = (cnt+ 1)
     IF (mod(cnt,10)=1)
      stat = alterlist(ccps_org_sec_rec->list,(cnt+ 9))
     ENDIF
     ccps_org_sec_rec->list[cnt].organization_id = o.organization_id, ccps_org_sec_rec->list[cnt].
     logical_domain_id = o.logical_domain_id, ccps_org_sec_rec->list[cnt].name = trim(o.org_name,3)
    FOOT REPORT
     ccps_org_sec_rec->cnt = cnt, stat = alterlist(ccps_org_sec_rec->list,cnt)
    WITH nocounter
   ;end select
   IF ((ccps_org_sec_rec->cnt > 0))
    SET return_val = 1
   ELSE
    CALL logmsg("GetPrsnlOrgRecord: zero records qualified")
   ENDIF
   CALL logrecord(ccps_org_sec_rec)
   CALL logmsg(build("GetPrsnlOrgRecord: return value = ",return_val))
   RETURN(return_val)
 END ;Subroutine
 CALL logmsg("ccps_org_security 001 10/26/2012 ML011047")
 DECLARE isldactive = i2 WITH constant(islogicaldomainsactive(null)), protect
 DECLARE ld_parser = vc WITH noconstant("0=1"), protect
 DECLARE organization_parser = vc WITH noconstant("0=1"), protect
 DECLARE ld_failure_flag = i4 WITH noconstant(0), protect
 DECLARE display_message = vc WITH noconstant(" "), protect
 IF (logical_domain_error)
  SET display_message = reply->status_data.subeventstatus[1].targetobjectvalue
  SET ld_failure_flag = 1
  GO TO exit_prg
 ENDIF
 DECLARE createldorgparsers(prsnl_id=f8,ld_column=vc,org_prompt=i2,org_column=vc,which_option=i2(
   value,list_in)) = null
 SUBROUTINE createldorgparsers(prsnl_id,ld_column,org_prompt,org_column,which_option)
   DECLARE ld_mismatch = i2 WITH protect, noconstant(0)
   DECLARE org_cnt = i4 WITH protect, noconstant(0)
   DECLARE option_str = vc WITH private, noconstant(" ")
   IF (isldactive)
    IF (((ispromptany(org_prompt)) OR (ispromptempty(org_prompt))) )
     SET organization_parser = getprsnlorgexpand(prsnl_id,org_column,which_option,cs278_client)
    ELSEIF (((ispromptlist(org_prompt)) OR (ispromptsingle(org_prompt))) )
     CALL getpromptrecord(org_prompt,"org_prompt_rec")
     IF (validate(org_prompt_rec->cnt))
      SELECT INTO "nl:"
       FROM organization o,
        logical_domain ld
       PLAN (o
        WHERE expand(org_prompt_rec->num,1,org_prompt_rec->cnt,o.organization_id,org_prompt_rec->
         list[org_prompt_rec->num].number))
        JOIN (ld
        WHERE ld.logical_domain_id=o.logical_domain_id
         AND ld.active_ind=1)
       ORDER BY o.organization_id
       HEAD REPORT
        pos = 0, cs_logical_domain_id = 0.0
       DETAIL
        IF (cs_logical_domain_id=0.0)
         cs_logical_domain_id = o.logical_domain_id
        ELSE
         IF (cs_logical_domain_id != o.logical_domain_id)
          ld_mismatch = 1
         ENDIF
        ENDIF
        pos = locateval(org_prompt_rec->num,1,org_prompt_rec->cnt,o.organization_id,org_prompt_rec->
         list[org_prompt_rec->num].number)
        IF (pos > 0)
         org_prompt_rec->list[pos].string = trim(o.org_name,3)
        ENDIF
        org_cnt = (org_cnt+ 1)
       WITH nocounter, expand = 1
      ;end select
      IF (ld_mismatch=1)
       SET display_message = build2(
        "Logical domains are in use. Please verify each organization ID shares ",
        "the same logical_domain_id when running from operations.")
      ELSEIF ((org_cnt != org_prompt_rec->cnt))
       SET display_message = "Please verify each organization ID is valid."
      ELSE
       SET organization_parser = createexpandparser(org_column,"org_prompt_rec",which_option)
      ENDIF
     ENDIF
    ENDIF
    IF (which_option=list_not_in)
     SET option_str = " not in ("
    ELSE
     SET option_str = " in ("
    ENDIF
    SET ld_parser = build(ld_column,option_str,cur_logical_domain,")")
   ELSE
    IF (((ispromptany(org_prompt)) OR (ispromptempty(org_prompt))) )
     SET organization_parser = getprsnlorgexpand(prsnl_id,org_column,which_option,cs278_client)
    ELSEIF (((ispromptlist(org_prompt)) OR (ispromptsingle(org_prompt))) )
     CALL getpromptrecord(org_prompt,"org_prompt_rec")
     IF (validate(org_prompt_rec->cnt))
      SELECT INTO "nl:"
       FROM organization o
       PLAN (o
        WHERE expand(org_prompt_rec->num,1,org_prompt_rec->cnt,o.organization_id,org_prompt_rec->
         list[org_prompt_rec->num].number))
       ORDER BY o.organization_id
       HEAD REPORT
        pos = 0
       DETAIL
        pos = locateval(org_prompt_rec->num,1,org_prompt_rec->cnt,o.organization_id,org_prompt_rec->
         list[org_prompt_rec->num].number)
        IF (pos > 0)
         org_prompt_rec->list[pos].string = trim(o.org_name,3)
        ENDIF
        org_cnt = (org_cnt+ 1)
       WITH nocounter, expand = 1
      ;end select
      IF ((org_cnt=org_prompt_rec->cnt))
       SET organization_parser = createexpandparser(org_column,"org_prompt_rec",which_option)
      ELSE
       SET display_message = "Please verify each organization ID is valid."
      ENDIF
     ENDIF
    ENDIF
    SET ld_parser = "1=1"
   ENDIF
   IF (validate(org_prompt_rec))
    CALL logrecord(org_prompt_rec)
   ENDIF
   CALL logmsg(build2("* * * ld_parser is:     ",ld_parser))
   CALL logmsg(build2("* * * ORGANIZATION_PARSER is:     ",organization_parser))
   CALL logmsg(build2("* * * display_message is:     ",display_message))
   CALL logmsg(build2("* * * is opsjob:     ",isopsjob))
 END ;Subroutine
 CALL logmsg("ccps_cs_security 000 10/26/2012 ML011047")
 CALL createldorgparsers(reqinfo->updt_id,"o.logical_domain_id",4,"c.payor_id")
 IF (((ld_parser="0=1") OR (organization_parser="0=1")) )
  SET ld_failure_flag = 1
  SET display_message = "The logical domain and/or organization security validation failed."
  GO TO exit_prg
 ENDIF
 IF (validate(org_prompt_rec->cnt,0) > 0)
  IF ((org_prompt_rec->cnt > 1))
   SET prompt_organization = multi_select
  ELSE
   SET prompt_organization = org_prompt_rec->list[1].string
  ENDIF
 ELSEIF (validate(ccps_org_sec_rec->cnt,0) > 0)
  SET prompt_organization = any_all_select
 ENDIF
 IF (reflect(parameter(5,0))="I4")
  IF (cnvtint( $RPT_TYPE) IN (rpt_output_excel, rpt_output_paper_summary, rpt_output_paper_phys))
   SET rpt_output_type = cnvtint( $RPT_TYPE)
  ELSE
   SET rpt_output_type = rpt_output_excel
  ENDIF
 ENDIF
 IF (( $SUMMARY_BY > 0)
  AND ( $SUMMARY_BY < 8))
  IF (( $SUMMARY_BY=1))
   SET summary_by_prompt = "Posted Charge Summary by Activity Type"
  ELSEIF (( $SUMMARY_BY=2))
   SET summary_by_prompt = "Posted Charge Summary by Cost Center"
  ELSEIF (( $SUMMARY_BY=3))
   SET summary_by_prompt = "Posted Charge Summary by Encounter Type"
  ELSEIF (( $SUMMARY_BY=4))
   SET summary_by_prompt = "Posted Charge Summary by Interface File"
  ELSEIF (( $SUMMARY_BY=5))
   SET summary_by_prompt = "Posted Charge Summary by Organization"
  ELSEIF (( $SUMMARY_BY=6))
   SET summary_by_prompt = "Posted Charge Summary by Tier Group"
  ELSEIF (( $SUMMARY_BY=7))
   SET summary_by_prompt = "Posted Charge Summary by Verifying Physician"
  ENDIF
 ENDIF
 IF (( $PHYS_SPEC_SORT=1))
  SET phys_spec_sort_prompt = "Verifying Physician Summary by CPT4"
 ELSEIF (( $PHYS_SPEC_SORT=2))
  SET phys_spec_sort_prompt = "Verifying Physician Summary by Charge Description"
 ENDIF
 FREE RECORD reqinfo
 RECORD reqinfo(
   1 updt_id = f8
 )
 FREE RECORD charges
 RECORD charges(
   1 c_cnt = i4
   1 c_total_extended_price = f8
   1 c_detail[*]
     2 fin = vc
     2 patient_name = vc
     2 service_date_time = dq8
     2 cdm = vc
     2 cpt = vc
     2 description = vc
     2 charge_type = vc
     2 item_quantity = f8
     2 qcf = f8
     2 extended_quantity = i4
     2 rvu = f8
     2 item_price = f8
     2 extended_price = f8
     2 encntr_id = f8
     2 person_id = f8
     2 charge_item_id = f8
     2 bill_item_id = f8
     2 organization_id = f8
     2 organization_name = vc
     2 activity_type_cd = f8
     2 activity_type = vc
     2 cost_center_cd = f8
     2 cost_center = vc
     2 interface_file_id = f8
     2 interface_file_name = vc
     2 tier_group_cd = f8
     2 tier_group = vc
     2 encntr_type_cd = f8
     2 encntr_type = vc
     2 posted_date = dq8
     2 verify_phys_id = f8
     2 verify_phys_name = vc
     2 verify_phys_name_last_key = vc
     2 verify_phys_name_first_key = vc
 )
 FREE RECORD group_by_summary
 RECORD group_by_summary(
   1 gbs_cnt = i4
   1 gbs_total_cnt = i4
   1 gbs_total_extended_price = f8
   1 gbs_total_rvu = f8
   1 gbs_detail[*]
     2 group_by_thing_text = vc
     2 group_by_thing_cnt = i4
     2 group_by_extended_price = f8
     2 group_by_rvu = f8
 )
 FREE RECORD physician_summary
 RECORD physician_summary(
   1 ps_cnt = i4
   1 ps_total_cnt = i4
   1 ps_total_extended_price = f8
   1 ps_total_rvu = f8
   1 ps_detail[*]
     2 physician_id = f8
     2 physician_name = vc
     2 physician_name_last_key = vc
     2 physician_name_first_key = vc
     2 count_per_physician = i4
     2 physician_extended_price = f8
     2 physician_rvu = f8
     2 procedure_cnt = i4
     2 procedure_detail[*]
       3 procedure_description = vc
       3 procedure_extended_price = f8
       3 procedure_rvu = f8
       3 count_per_procedure = i4
 )
 SELECT INTO "nl:"
  FROM charge c,
   encounter e,
   organization o,
   interface_file ifile,
   person p,
   pft_charge pc,
   bill_item_modifier bim,
   workload_code wc,
   bill_org_payor bop,
   prsnl p1,
   encntr_alias eafin,
   encntr_combine ec,
   encntr_alias eafin2
  PLAN (c
   WHERE c.posted_dt_tm BETWEEN cnvtdatetime(beg_dt_tm) AND cnvtdatetime(end_dt_tm)
    AND parser(organization_parser)
    AND ((c.process_flg+ 0)=100)
    AND c.active_ind=1
    AND ((c.beg_effective_dt_tm+ 0) <= cnvtdatetime(curdate,curtime3))
    AND c.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (e
   WHERE e.encntr_id=c.encntr_id)
   JOIN (o
   WHERE o.organization_id=e.organization_id
    AND o.active_ind=1
    AND o.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND o.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND parser(ld_parser))
   JOIN (ifile
   WHERE ifile.interface_file_id=c.interface_file_id
    AND ifile.active_ind=1)
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (pc
   WHERE pc.charge_item_id=c.charge_item_id
    AND pc.active_ind=1
    AND pc.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pc.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (bim
   WHERE bim.bill_item_id=c.bill_item_id
    AND bim.bill_item_type_cd=workload_cd
    AND bim.active_ind=1
    AND ((bim.beg_effective_dt_tm+ 0) <= cnvtdatetime(curdate,curtime3))
    AND ((bim.end_effective_dt_tm+ 0) > cnvtdatetime(curdate,curtime3)))
   JOIN (wc
   WHERE wc.workload_code_id=bim.key3_id
    AND ((wc.active_ind+ 0)=1)
    AND ((wc.beg_effective_dt_tm+ 0) <= cnvtdatetime(curdate,curtime3))
    AND ((wc.end_effective_dt_tm+ 0) > cnvtdatetime(curdate,curtime3)))
   JOIN (bop
   WHERE bop.bill_org_type_id=wc.workload_standard_id
    AND bop.bill_org_type_cd=standard_cd
    AND bop.parent_entity_name="WORKLOAD_STANDARD"
    AND bop.organization_id=e.organization_id
    AND bop.active_ind=1
    AND bop.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND bop.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (p1
   WHERE p1.person_id=outerjoin(c.verify_phys_id)
    AND p1.active_ind=outerjoin(1)
    AND p1.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
    AND p1.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
   JOIN (eafin
   WHERE eafin.encntr_id=outerjoin(c.encntr_id)
    AND ((eafin.encntr_alias_type_cd+ 0)=outerjoin(ea_type_fin_cd))
    AND eafin.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
    AND eafin.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
   JOIN (ec
   WHERE ec.from_encntr_id=outerjoin(c.encntr_id)
    AND ec.active_ind=outerjoin(1))
   JOIN (eafin2
   WHERE eafin2.encntr_id=outerjoin(ec.to_encntr_id)
    AND ((eafin2.encntr_alias_type_cd+ 0)=outerjoin(ea_type_fin_cd))
    AND eafin2.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
    AND eafin2.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
  ORDER BY c.charge_item_id, wc.workload_code_id
  HEAD REPORT
   c_cnt = 0
  HEAD c.charge_item_id
   c_cnt = (c_cnt+ 1)
   IF (mod(c_cnt,100)=1)
    stat = alterlist(charges->c_detail,(c_cnt+ 99))
   ENDIF
   IF (textlen(trim(eafin.alias,3)) > 0)
    charges->c_detail[c_cnt].fin = cnvtalias(eafin.alias,eafin.alias_pool_cd)
   ELSE
    charges->c_detail[c_cnt].fin = cnvtalias(eafin2.alias,eafin2.alias_pool_cd)
   ENDIF
   charges->c_total_extended_price = (charges->c_total_extended_price+ c.item_extended_price),
   charges->c_detail[c_cnt].patient_name = p.name_full_formatted, charges->c_detail[c_cnt].
   service_date_time = c.service_dt_tm,
   charges->c_detail[c_cnt].description = c.charge_description, charges->c_detail[c_cnt].charge_type
    = uar_get_code_display(c.charge_type_cd), charges->c_detail[c_cnt].item_quantity = c
   .item_quantity,
   charges->c_detail[c_cnt].extended_quantity = pc.billing_quantity, charges->c_detail[c_cnt].
   item_price = c.item_price, charges->c_detail[c_cnt].extended_price = c.item_extended_price,
   charges->c_detail[c_cnt].encntr_id = c.encntr_id, charges->c_detail[c_cnt].person_id = c.person_id,
   charges->c_detail[c_cnt].charge_item_id = c.charge_item_id,
   charges->c_detail[c_cnt].bill_item_id = c.bill_item_id, charges->c_detail[c_cnt].organization_id
    = e.organization_id, charges->c_detail[c_cnt].organization_name = o.org_name,
   charges->c_detail[c_cnt].activity_type_cd = c.activity_type_cd, charges->c_detail[c_cnt].
   activity_type = uar_get_code_display(c.activity_type_cd), charges->c_detail[c_cnt].cost_center_cd
    = c.cost_center_cd,
   charges->c_detail[c_cnt].cost_center = uar_get_code_display(c.cost_center_cd), charges->c_detail[
   c_cnt].interface_file_id = c.interface_file_id, charges->c_detail[c_cnt].interface_file_name =
   ifile.description,
   charges->c_detail[c_cnt].tier_group_cd = c.tier_group_cd, charges->c_detail[c_cnt].tier_group =
   uar_get_code_display(c.tier_group_cd), charges->c_detail[c_cnt].encntr_type_cd = e.encntr_type_cd,
   charges->c_detail[c_cnt].encntr_type = uar_get_code_display(e.encntr_type_cd), charges->c_detail[
   c_cnt].posted_date = c.posted_dt_tm, charges->c_detail[c_cnt].verify_phys_id = p1.person_id,
   charges->c_detail[c_cnt].verify_phys_name = trim(p1.name_full_formatted), charges->c_detail[c_cnt]
   .verify_phys_name_first_key = trim(p1.name_first_key), charges->c_detail[c_cnt].
   verify_phys_name_last_key = trim(p1.name_last_key),
   temp_rvu = 0.00
  HEAD wc.workload_code_id
   IF ((bim.bim1_nbr != - (1)))
    temp_rvu = (temp_rvu+ bim.bim1_nbr)
   ELSE
    temp_rvu = (temp_rvu+ wc.units)
   ENDIF
  FOOT  wc.workload_code_id
   null
  FOOT  c.charge_item_id
   IF (c.charge_type_cd=debit_chrg_type_cd
    AND temp_rvu > 0.00)
    charges->c_detail[c_cnt].rvu = temp_rvu
   ELSEIF (c.charge_type_cd=credit_chrg_type_cd
    AND temp_rvu > 0.00)
    charges->c_detail[c_cnt].rvu = (temp_rvu * - (1.00))
   ENDIF
  FOOT REPORT
   stat = alterlist(charges->c_detail,c_cnt), charges->c_cnt = c_cnt
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM charge_mod cm,
   code_value cv
  PLAN (cm
   WHERE expand(index,1,charges->c_cnt,cm.charge_item_id,charges->c_detail[index].charge_item_id)
    AND cm.charge_mod_type_cd=bill_code_cd
    AND cm.field2_id=1)
   JOIN (cv
   WHERE cv.code_value=cm.field1_id
    AND ((cv.code_set+ 0)=14002)
    AND trim(cv.cdf_meaning) IN ("CDM_SCHED", "CPT4", "HCPCS")
    AND cv.active_ind=1)
  DETAIL
   pos = locatevalsort(num,1,charges->c_cnt,cm.charge_item_id,charges->c_detail[num].charge_item_id)
   IF (pos > 0)
    IF (uar_get_code_meaning(cm.field1_id)="CDM_SCHED")
     charges->c_detail[pos].cdm = trim(cm.field6)
    ELSEIF (uar_get_code_meaning(cm.field1_id)="CPT4")
     charges->c_detail[pos].cpt = trim(cm.field6)
    ELSEIF (uar_get_code_meaning(cm.field1_id)="HCPCS")
     charges->c_detail[pos].qcf = cm.cm1_nbr
    ENDIF
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 IF ((charges->c_cnt > 0))
  EXECUTE reportrtl
  DECLARE _createfonts(dummy) = null WITH protect
  DECLARE _createpens(dummy) = null WITH protect
  DECLARE pagebreak(dummy) = null WITH protect
  DECLARE finalizereport(ssendreport=vc) = null WITH protect
  DECLARE nodatasection0(ncalc=i2) = f8 WITH protect
  DECLARE nodatasection0abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
  DECLARE headpagesummarysection(ncalc=i2) = f8 WITH protect
  DECLARE headpagesummarysectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
  DECLARE headpagephysiciansection(ncalc=i2) = f8 WITH protect
  DECLARE headpagephysiciansectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
  DECLARE headphysiciansection(ncalc=i2) = f8 WITH protect
  DECLARE headphysiciansectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
  DECLARE detailsummarysection(ncalc=i2) = f8 WITH protect
  DECLARE detailsummarysectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
  DECLARE detailphysiciansection(ncalc=i2) = f8 WITH protect
  DECLARE detailphysiciansectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
  DECLARE footsummarysection(ncalc=i2) = f8 WITH protect
  DECLARE footsummarysectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
  DECLARE footphysiciansection(ncalc=i2) = f8 WITH protect
  DECLARE footphysiciansectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
  DECLARE footphysiciansummarysection(ncalc=i2) = f8 WITH protect
  DECLARE footphysiciansummarysectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
  DECLARE footreportsection0(ncalc=i2) = f8 WITH protect
  DECLARE footreportsection0abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
  DECLARE initializereport(dummy) = null WITH protect
  DECLARE _hreport = i4 WITH noconstant(0), protect
  DECLARE _yoffset = f8 WITH noconstant(0.0), protect
  DECLARE _xoffset = f8 WITH noconstant(0.0), protect
  DECLARE rpt_render = i2 WITH constant(0), protect
  DECLARE _crlf = vc WITH constant(concat(char(13),char(10))), protect
  DECLARE rpt_calcheight = i2 WITH constant(1), protect
  DECLARE _yshift = f8 WITH noconstant(0.0), protect
  DECLARE _xshift = f8 WITH noconstant(0.0), protect
  DECLARE _sendto = vc WITH noconstant(""), protect
  DECLARE _rpterr = i2 WITH noconstant(0), protect
  DECLARE _rptstat = i2 WITH noconstant(0), protect
  DECLARE _oldfont = i4 WITH noconstant(0), protect
  DECLARE _oldpen = i4 WITH noconstant(0), protect
  DECLARE _dummyfont = i4 WITH noconstant(0), protect
  DECLARE _dummypen = i4 WITH noconstant(0), protect
  DECLARE _fdrawheight = f8 WITH noconstant(0.0), protect
  DECLARE _rptpage = i4 WITH noconstant(0), protect
  DECLARE _diotype = i2 WITH noconstant(8), protect
  DECLARE _outputtype = i2 WITH noconstant(rpt_postscript), protect
  DECLARE _times8b0 = i4 WITH noconstant(0), protect
  DECLARE _times80 = i4 WITH noconstant(0), protect
  DECLARE _times10b0 = i4 WITH noconstant(0), protect
  DECLARE _times12b0 = i4 WITH noconstant(0), protect
  DECLARE _times100 = i4 WITH noconstant(0), protect
  DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
  SUBROUTINE pagebreak(dummy)
    SET _rptpage = uar_rptendpage(_hreport)
    SET _rptpage = uar_rptstartpage(_hreport)
    SET _yoffset = rptreport->m_margintop
  END ;Subroutine
  SUBROUTINE finalizereport(ssendreport)
    SET _rptpage = uar_rptendpage(_hreport)
    SET _rptstat = uar_rptendreport(_hreport)
    DECLARE sfilename = vc WITH noconstant(trim(ssendreport)), private
    DECLARE bprint = i2 WITH noconstant(0), private
    IF (textlen(sfilename) > 0)
     SET bprint = checkqueue(sfilename)
     IF (bprint)
      EXECUTE cpm_create_file_name "RPT", "PS"
      SET sfilename = cpm_cfn_info->file_name_path
     ENDIF
    ENDIF
    SET _rptstat = uar_rptprinttofile(_hreport,nullterm(sfilename))
    IF (bprint)
     SET spool value(sfilename) value(ssendreport) WITH deleted, dio = value(_diotype)
    ENDIF
    DECLARE _errorfound = i2 WITH noconstant(0), protect
    DECLARE _errcnt = i2 WITH noconstant(0), protect
    SET _errorfound = uar_rptfirsterror(_hreport,rpterror)
    WHILE (_errorfound=rpt_errorfound
     AND _errcnt < 512)
      SET _errcnt = (_errcnt+ 1)
      SET stat = alterlist(rpterrors->errors,_errcnt)
      SET rpterrors->errors[_errcnt].m_severity = rpterror->m_severity
      SET rpterrors->errors[_errcnt].m_text = rpterror->m_text
      SET rpterrors->errors[_errcnt].m_source = rpterror->m_source
      SET _errorfound = uar_rptnexterror(_hreport,rpterror)
    ENDWHILE
    SET _rptstat = uar_rptdestroyreport(_hreport)
  END ;Subroutine
  SUBROUTINE nodatasection0(ncalc)
    DECLARE a1 = f8 WITH noconstant(0.0), private
    SET a1 = nodatasection0abs(ncalc,_xoffset,_yoffset)
    RETURN(a1)
  END ;Subroutine
  SUBROUTINE nodatasection0abs(ncalc,offsetx,offsety)
    DECLARE sectionheight = f8 WITH noconstant(1.000000), private
    IF (ncalc=rpt_render)
     SET rptsd->m_flags = 16
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_linespacing = rpt_single
     SET rptsd->m_rotationangle = 0
     SET rptsd->m_y = (offsety+ 0.000)
     SET rptsd->m_x = (offsetx+ 0.750)
     SET rptsd->m_width = 9.000
     SET rptsd->m_height = 0.875
     SET _oldfont = uar_rptsetfont(_hreport,_times12b0)
     SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(no_data_title,char(0)))
     SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
     SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
     SET _yoffset = (offsety+ sectionheight)
    ENDIF
    RETURN(sectionheight)
  END ;Subroutine
  SUBROUTINE headpagesummarysection(ncalc)
    DECLARE a1 = f8 WITH noconstant(0.0), private
    SET a1 = headpagesummarysectionabs(ncalc,_xoffset,_yoffset)
    RETURN(a1)
  END ;Subroutine
  SUBROUTINE headpagesummarysectionabs(ncalc,offsetx,offsety)
    DECLARE sectionheight = f8 WITH noconstant(1.170000), private
    DECLARE __fieldname0 = vc WITH noconstant(build2(trim(summary_by_prompt),char(0))), protect
    IF (ncalc=rpt_render)
     SET rptsd->m_flags = 64
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_linespacing = rpt_single
     SET rptsd->m_rotationangle = 0
     SET rptsd->m_y = (offsety+ 0.281)
     SET rptsd->m_x = (offsetx+ 9.313)
     SET rptsd->m_width = 1.188
     SET rptsd->m_height = 0.260
     SET _oldfont = uar_rptsetfont(_hreport,_times80)
     SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(rpt_pageofpage,char(0)))
     SET rptsd->m_flags = 0
     SET rptsd->m_y = (offsety+ 0.281)
     SET rptsd->m_x = (offsetx+ 0.000)
     SET rptsd->m_width = 2.750
     SET rptsd->m_height = 0.260
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(exec_date_str,char(0)))
     SET rptsd->m_flags = 16
     SET rptsd->m_y = (offsety+ 0.281)
     SET rptsd->m_x = (offsetx+ 2.760)
     SET rptsd->m_width = 4.990
     SET rptsd->m_height = 0.302
     SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(prompt_dates,char(0)))
     SET rptsd->m_flags = 68
     SET rptsd->m_y = (offsety+ 0.990)
     SET rptsd->m_x = (offsetx+ 2.250)
     SET rptsd->m_width = 0.750
     SET rptsd->m_height = 0.198
     SET _dummyfont = uar_rptsetfont(_hreport,_times80)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("COUNT",char(0)))
     SET rptsd->m_flags = 4
     SET rptsd->m_y = (offsety+ 0.990)
     SET rptsd->m_x = (offsetx+ 3.125)
     SET rptsd->m_width = 2.500
     SET rptsd->m_height = 0.198
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("DESCRIPTION",char(0)))
     SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 1.147),(offsetx+ 10.500),(offsety
      + 1.147))
     SET rptsd->m_flags = 16
     SET rptsd->m_y = (offsety+ 0.000)
     SET rptsd->m_x = (offsetx+ 2.750)
     SET rptsd->m_width = 5.000
     SET rptsd->m_height = 0.292
     SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname0)
     SET rptsd->m_flags = 68
     SET rptsd->m_y = (offsety+ 0.990)
     SET rptsd->m_x = (offsetx+ 6.688)
     SET rptsd->m_width = 1.125
     SET rptsd->m_height = 0.198
     SET _dummyfont = uar_rptsetfont(_hreport,_times80)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("EXTENDED PRICE",char(0)))
     SET rptsd->m_y = (offsety+ 0.990)
     SET rptsd->m_x = (offsetx+ 5.750)
     SET rptsd->m_width = 0.771
     SET rptsd->m_height = 0.177
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("RVU",char(0)))
     SET rptsd->m_flags = 16
     SET rptsd->m_y = (offsety+ 0.490)
     SET rptsd->m_x = (offsetx+ 2.760)
     SET rptsd->m_width = 4.990
     SET rptsd->m_height = 0.260
     SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(prompt_organization,char(0)))
     SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
     SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
     SET _yoffset = (offsety+ sectionheight)
    ENDIF
    RETURN(sectionheight)
  END ;Subroutine
  SUBROUTINE headpagephysiciansection(ncalc)
    DECLARE a1 = f8 WITH noconstant(0.0), private
    SET a1 = headpagephysiciansectionabs(ncalc,_xoffset,_yoffset)
    RETURN(a1)
  END ;Subroutine
  SUBROUTINE headpagephysiciansectionabs(ncalc,offsetx,offsety)
    DECLARE sectionheight = f8 WITH noconstant(1.170000), private
    IF (ncalc=rpt_render)
     SET rptsd->m_flags = 64
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_linespacing = rpt_single
     SET rptsd->m_rotationangle = 0
     SET rptsd->m_y = (offsety+ 0.271)
     SET rptsd->m_x = (offsetx+ 9.313)
     SET rptsd->m_width = 1.188
     SET rptsd->m_height = 0.260
     SET _oldfont = uar_rptsetfont(_hreport,_times80)
     SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(rpt_pageofpage,char(0)))
     SET rptsd->m_flags = 0
     SET rptsd->m_y = (offsety+ 0.271)
     SET rptsd->m_x = (offsetx+ 0.000)
     SET rptsd->m_width = 2.750
     SET rptsd->m_height = 0.260
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(exec_date_str,char(0)))
     SET rptsd->m_flags = 16
     SET rptsd->m_y = (offsety+ 0.271)
     SET rptsd->m_x = (offsetx+ 2.750)
     SET rptsd->m_width = 5.000
     SET rptsd->m_height = 0.229
     SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(prompt_dates,char(0)))
     SET rptsd->m_flags = 4
     SET rptsd->m_y = (offsety+ 0.938)
     SET rptsd->m_x = (offsetx+ 0.750)
     SET rptsd->m_width = 2.250
     SET rptsd->m_height = 0.198
     SET _dummyfont = uar_rptsetfont(_hreport,_times80)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("PHYSICIAN NAME",char(0)))
     SET rptsd->m_y = (offsety+ 0.938)
     SET rptsd->m_x = (offsetx+ 3.125)
     SET rptsd->m_width = 2.750
     SET rptsd->m_height = 0.198
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("DESCRIPTION",char(0)))
     SET rptsd->m_flags = 68
     SET rptsd->m_y = (offsety+ 0.938)
     SET rptsd->m_x = (offsetx+ 6.000)
     SET rptsd->m_width = 1.000
     SET rptsd->m_height = 0.198
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("COUNT",char(0)))
     SET rptsd->m_y = (offsety+ 0.938)
     SET rptsd->m_x = (offsetx+ 7.125)
     SET rptsd->m_width = 1.250
     SET rptsd->m_height = 0.198
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("RVU",char(0)))
     SET rptsd->m_y = (offsety+ 0.938)
     SET rptsd->m_x = (offsetx+ 8.500)
     SET rptsd->m_width = 1.250
     SET rptsd->m_height = 0.198
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("EXT PRICE",char(0)))
     SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.031),(offsety+ 1.094),(offsetx+ 10.489),(offsety
      + 1.094))
     SET rptsd->m_flags = 16
     SET rptsd->m_y = (offsety+ 0.000)
     SET rptsd->m_x = (offsetx+ 2.760)
     SET rptsd->m_width = 4.990
     SET rptsd->m_height = 0.260
     SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(phys_spec_sort_prompt,char(0)))
     SET rptsd->m_flags = 32
     SET rptsd->m_y = (offsety+ 0.542)
     SET rptsd->m_x = (offsetx+ 0.250)
     SET rptsd->m_width = 4.000
     SET rptsd->m_height = 0.260
     SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(phys_name_display,char(0)))
     SET rptsd->m_flags = 64
     SET rptsd->m_y = (offsety+ 0.542)
     SET rptsd->m_x = (offsetx+ 6.250)
     SET rptsd->m_width = 4.000
     SET rptsd->m_height = 0.260
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(prompt_organization,char(0)))
     SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
     SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
     SET _yoffset = (offsety+ sectionheight)
    ENDIF
    RETURN(sectionheight)
  END ;Subroutine
  SUBROUTINE headphysiciansection(ncalc)
    DECLARE a1 = f8 WITH noconstant(0.0), private
    SET a1 = headphysiciansectionabs(ncalc,_xoffset,_yoffset)
    RETURN(a1)
  END ;Subroutine
  SUBROUTINE headphysiciansectionabs(ncalc,offsetx,offsety)
    DECLARE sectionheight = f8 WITH noconstant(0.310000), private
    DECLARE __fieldname7 = vc WITH noconstant(build2(physician_summary->ps_detail[i].physician_name,
      char(0))), protect
    IF (ncalc=rpt_render)
     SET rptsd->m_flags = 0
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_linespacing = rpt_single
     SET rptsd->m_rotationangle = 0
     SET rptsd->m_y = (offsety+ 0.000)
     SET rptsd->m_x = (offsetx+ 0.750)
     SET rptsd->m_width = 2.250
     SET rptsd->m_height = 0.260
     SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
     SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname7)
     SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
     SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    ENDIF
    RETURN(sectionheight)
  END ;Subroutine
  SUBROUTINE detailsummarysection(ncalc)
    DECLARE a1 = f8 WITH noconstant(0.0), private
    SET a1 = detailsummarysectionabs(ncalc,_xoffset,_yoffset)
    RETURN(a1)
  END ;Subroutine
  SUBROUTINE detailsummarysectionabs(ncalc,offsetx,offsety)
    DECLARE sectionheight = f8 WITH noconstant(0.200000), private
    DECLARE __fieldname0 = vc WITH noconstant(build2(group_by_summary->gbs_detail[i].
      group_by_thing_cnt,char(0))), protect
    DECLARE __fieldname1 = vc WITH noconstant(build2(group_by_summary->gbs_detail[i].
      group_by_thing_text,char(0))), protect
    DECLARE __fieldname2 = vc WITH noconstant(build2(group_by_summary->gbs_detail[i].
      group_by_extended_price,char(0))), protect
    DECLARE __fieldname3 = vc WITH noconstant(build2(group_by_summary->gbs_detail[i].group_by_rvu,
      char(0))), protect
    IF (ncalc=rpt_render)
     SET rptsd->m_flags = 64
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_linespacing = rpt_single
     SET rptsd->m_rotationangle = 0
     SET rptsd->m_y = (offsety+ 0.000)
     SET rptsd->m_x = (offsetx+ 2.250)
     SET rptsd->m_width = 0.750
     SET rptsd->m_height = 0.198
     SET _oldfont = uar_rptsetfont(_hreport,_times80)
     SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname0)
     SET rptsd->m_flags = 0
     SET rptsd->m_y = (offsety+ 0.000)
     SET rptsd->m_x = (offsetx+ 3.125)
     SET rptsd->m_width = 2.500
     SET rptsd->m_height = 0.198
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname1)
     SET rptsd->m_flags = 64
     SET rptsd->m_y = (offsety+ 0.000)
     SET rptsd->m_x = (offsetx+ 6.688)
     SET rptsd->m_width = 1.125
     SET rptsd->m_height = 0.198
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname2)
     SET rptsd->m_y = (offsety+ 0.000)
     SET rptsd->m_x = (offsetx+ 5.750)
     SET rptsd->m_width = 0.750
     SET rptsd->m_height = 0.198
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname3)
     SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
     SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
     SET _yoffset = (offsety+ sectionheight)
    ENDIF
    RETURN(sectionheight)
  END ;Subroutine
  SUBROUTINE detailphysiciansection(ncalc)
    DECLARE a1 = f8 WITH noconstant(0.0), private
    SET a1 = detailphysiciansectionabs(ncalc,_xoffset,_yoffset)
    RETURN(a1)
  END ;Subroutine
  SUBROUTINE detailphysiciansectionabs(ncalc,offsetx,offsety)
    DECLARE sectionheight = f8 WITH noconstant(0.250000), private
    DECLARE __fieldname10 = vc WITH noconstant(build2(physician_summary->ps_detail[i].
      procedure_detail[ii].procedure_description,char(0))), protect
    DECLARE __fieldname15 = vc WITH noconstant(build2(physician_summary->ps_detail[i].
      procedure_detail[ii].count_per_procedure,char(0))), protect
    DECLARE __fieldname16 = vc WITH noconstant(build2(physician_summary->ps_detail[i].
      procedure_detail[ii].procedure_rvu,char(0))), protect
    DECLARE __fieldname17 = vc WITH noconstant(build2(physician_summary->ps_detail[i].
      procedure_detail[ii].procedure_extended_price,char(0))), protect
    IF (ncalc=rpt_render)
     SET rptsd->m_flags = 0
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_linespacing = rpt_single
     SET rptsd->m_rotationangle = 0
     SET rptsd->m_y = (offsety+ 0.000)
     SET rptsd->m_x = (offsetx+ 3.125)
     SET rptsd->m_width = 2.750
     SET rptsd->m_height = 0.250
     SET _oldfont = uar_rptsetfont(_hreport,_times80)
     SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname10)
     SET rptsd->m_flags = 64
     SET rptsd->m_y = (offsety+ 0.000)
     SET rptsd->m_x = (offsetx+ 6.000)
     SET rptsd->m_width = 1.000
     SET rptsd->m_height = 0.198
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname15)
     SET rptsd->m_y = (offsety+ 0.000)
     SET rptsd->m_x = (offsetx+ 7.125)
     SET rptsd->m_width = 1.250
     SET rptsd->m_height = 0.198
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname16)
     SET rptsd->m_y = (offsety+ 0.000)
     SET rptsd->m_x = (offsetx+ 8.500)
     SET rptsd->m_width = 1.250
     SET rptsd->m_height = 0.198
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname17)
     SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
     SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
     SET _yoffset = (offsety+ sectionheight)
    ENDIF
    RETURN(sectionheight)
  END ;Subroutine
  SUBROUTINE footsummarysection(ncalc)
    DECLARE a1 = f8 WITH noconstant(0.0), private
    SET a1 = footsummarysectionabs(ncalc,_xoffset,_yoffset)
    RETURN(a1)
  END ;Subroutine
  SUBROUTINE footsummarysectionabs(ncalc,offsetx,offsety)
    DECLARE sectionheight = f8 WITH noconstant(0.740000), private
    DECLARE __fieldname1 = vc WITH noconstant(build2(group_by_summary->gbs_total_cnt,char(0))),
    protect
    DECLARE __fieldname2 = vc WITH noconstant(build2(group_by_summary->gbs_total_extended_price,char(
       0))), protect
    DECLARE __fieldname6 = vc WITH noconstant(build2(group_by_summary->gbs_total_rvu,char(0))),
    protect
    IF (ncalc=rpt_render)
     SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
     SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.250),(offsety+ 0.130),(offsetx+ 3.010),(offsety
      + 0.130))
     SET rptsd->m_flags = 64
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_linespacing = rpt_single
     SET rptsd->m_rotationangle = 0
     SET rptsd->m_y = (offsety+ 0.260)
     SET rptsd->m_x = (offsetx+ 2.000)
     SET rptsd->m_width = 1.000
     SET rptsd->m_height = 0.260
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname1)
     SET rptsd->m_y = (offsety+ 0.260)
     SET rptsd->m_x = (offsetx+ 6.625)
     SET rptsd->m_width = 1.219
     SET rptsd->m_height = 0.260
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname2)
     SET rptsd->m_flags = 0
     SET rptsd->m_y = (offsety+ 0.260)
     SET rptsd->m_x = (offsetx+ 3.125)
     SET rptsd->m_width = 2.500
     SET rptsd->m_height = 0.260
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(foot_summary_text,char(0)))
     SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.750),(offsety+ 0.130),(offsetx+ 6.510),(offsety
      + 0.130))
     SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.063),(offsety+ 0.130),(offsetx+ 7.823),(offsety
      + 0.130))
     SET rptsd->m_flags = 64
     SET rptsd->m_y = (offsety+ 0.260)
     SET rptsd->m_x = (offsetx+ 5.313)
     SET rptsd->m_width = 1.177
     SET rptsd->m_height = 0.260
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname6)
     SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
     SET _yoffset = (offsety+ sectionheight)
    ENDIF
    RETURN(sectionheight)
  END ;Subroutine
  SUBROUTINE footphysiciansection(ncalc)
    DECLARE a1 = f8 WITH noconstant(0.0), private
    SET a1 = footphysiciansectionabs(ncalc,_xoffset,_yoffset)
    RETURN(a1)
  END ;Subroutine
  SUBROUTINE footphysiciansectionabs(ncalc,offsetx,offsety)
    DECLARE sectionheight = f8 WITH noconstant(0.750000), private
    DECLARE __fieldname4 = vc WITH noconstant(build2(physician_summary->ps_detail[i].
      count_per_physician,char(0))), protect
    DECLARE __fieldname5 = vc WITH noconstant(build2(physician_summary->ps_detail[i].
      physician_extended_price,char(0))), protect
    DECLARE __fieldname6 = vc WITH noconstant(build2(physician_summary->ps_detail[i].physician_rvu,
      char(0))), protect
    DECLARE __fieldname7 = vc WITH noconstant(build2(concat("TOTAL for ",physician_summary->
       ps_detail[i].physician_name),char(0))), protect
    IF (ncalc=rpt_render)
     SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
     SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.625),(offsety+ 0.146),(offsetx+ 8.385),(offsety
      + 0.146))
     SET _rptstat = uar_rptline(_hreport,(offsetx+ 9.000),(offsety+ 0.146),(offsetx+ 9.760),(offsety
      + 0.146))
     SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.250),(offsety+ 0.146),(offsetx+ 7.010),(offsety
      + 0.146))
     SET rptsd->m_flags = 64
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_linespacing = rpt_single
     SET rptsd->m_rotationangle = 0
     SET rptsd->m_y = (offsety+ 0.313)
     SET rptsd->m_x = (offsetx+ 6.000)
     SET rptsd->m_width = 1.000
     SET rptsd->m_height = 0.260
     SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname4)
     SET rptsd->m_y = (offsety+ 0.313)
     SET rptsd->m_x = (offsetx+ 8.500)
     SET rptsd->m_width = 1.250
     SET rptsd->m_height = 0.271
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname5)
     SET rptsd->m_y = (offsety+ 0.313)
     SET rptsd->m_x = (offsetx+ 7.125)
     SET rptsd->m_width = 1.250
     SET rptsd->m_height = 0.260
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname6)
     SET rptsd->m_flags = 0
     SET rptsd->m_y = (offsety+ 0.313)
     SET rptsd->m_x = (offsetx+ 3.125)
     SET rptsd->m_width = 2.625
     SET rptsd->m_height = 0.323
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname7)
     SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
     SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
     SET _yoffset = (offsety+ sectionheight)
    ENDIF
    RETURN(sectionheight)
  END ;Subroutine
  SUBROUTINE footphysiciansummarysection(ncalc)
    DECLARE a1 = f8 WITH noconstant(0.0), private
    SET a1 = footphysiciansummarysectionabs(ncalc,_xoffset,_yoffset)
    RETURN(a1)
  END ;Subroutine
  SUBROUTINE footphysiciansummarysectionabs(ncalc,offsetx,offsety)
    DECLARE sectionheight = f8 WITH noconstant(0.750000), private
    DECLARE __fieldname4 = vc WITH noconstant(build2(physician_summary->ps_total_extended_price,char(
       0))), protect
    DECLARE __fieldname5 = vc WITH noconstant(build2(physician_summary->ps_total_rvu,char(0))),
    protect
    DECLARE __fieldname6 = vc WITH noconstant(build2(physician_summary->ps_total_cnt,char(0))),
    protect
    IF (ncalc=rpt_render)
     SET rptsd->m_flags = 0
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_linespacing = rpt_single
     SET rptsd->m_rotationangle = 0
     SET rptsd->m_y = (offsety+ 0.313)
     SET rptsd->m_x = (offsetx+ 3.125)
     SET rptsd->m_width = 2.438
     SET rptsd->m_height = 0.260
     SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
     SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(foot_phys_summary_text,char(0)))
     SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.250),(offsety+ 0.130),(offsetx+ 7.010),(offsety
      + 0.130))
     SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.625),(offsety+ 0.130),(offsetx+ 8.385),(offsety
      + 0.130))
     SET _rptstat = uar_rptline(_hreport,(offsetx+ 9.000),(offsety+ 0.130),(offsetx+ 9.760),(offsety
      + 0.130))
     SET rptsd->m_flags = 64
     SET rptsd->m_y = (offsety+ 0.313)
     SET rptsd->m_x = (offsetx+ 8.500)
     SET rptsd->m_width = 1.250
     SET rptsd->m_height = 0.260
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname4)
     SET rptsd->m_y = (offsety+ 0.313)
     SET rptsd->m_x = (offsetx+ 7.125)
     SET rptsd->m_width = 1.250
     SET rptsd->m_height = 0.260
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname5)
     SET rptsd->m_y = (offsety+ 0.313)
     SET rptsd->m_x = (offsetx+ 6.000)
     SET rptsd->m_width = 1.000
     SET rptsd->m_height = 0.260
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname6)
     SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
     SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
     SET _yoffset = (offsety+ sectionheight)
    ENDIF
    RETURN(sectionheight)
  END ;Subroutine
  SUBROUTINE footreportsection0(ncalc)
    DECLARE a1 = f8 WITH noconstant(0.0), private
    SET a1 = footreportsection0abs(ncalc,_xoffset,_yoffset)
    RETURN(a1)
  END ;Subroutine
  SUBROUTINE footreportsection0abs(ncalc,offsetx,offsety)
    DECLARE sectionheight = f8 WITH noconstant(1.000000), private
    IF (ncalc=rpt_render)
     SET rptsd->m_flags = 16
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_linespacing = rpt_single
     SET rptsd->m_rotationangle = 0
     SET rptsd->m_y = (offsety+ 0.500)
     SET rptsd->m_x = (offsetx+ 1.750)
     SET rptsd->m_width = 7.000
     SET rptsd->m_height = 0.198
     SET _oldfont = uar_rptsetfont(_hreport,_times8b0)
     SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("< < End of Report > >",char(0)))
     SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
     SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
     SET _yoffset = (offsety+ sectionheight)
    ENDIF
    RETURN(sectionheight)
  END ;Subroutine
  SUBROUTINE initializereport(dummy)
    SET rptreport->m_recsize = 100
    SET rptreport->m_reportname = "CCPS_CS_RVU_POSTED_CHARGES"
    SET rptreport->m_pagewidth = 8.50
    SET rptreport->m_pageheight = 11.00
    SET rptreport->m_orientation = rpt_landscape
    SET rptreport->m_marginleft = 0.25
    SET rptreport->m_marginright = 0.25
    SET rptreport->m_margintop = 0.25
    SET rptreport->m_marginbottom = 0.25
    SET rptreport->m_horzprintoffset = _xshift
    SET rptreport->m_vertprintoffset = _yshift
    SET _yoffset = rptreport->m_margintop
    SET _xoffset = rptreport->m_marginleft
    SET _hreport = uar_rptcreatereport(rptreport,_outputtype,rpt_inches)
    SET _rpterr = uar_rptseterrorlevel(_hreport,rpt_error)
    SET _rptstat = uar_rptstartreport(_hreport)
    SET _rptpage = uar_rptstartpage(_hreport)
    CALL _createfonts(0)
    CALL _createpens(0)
  END ;Subroutine
  SUBROUTINE _createfonts(dummy)
    SET rptfont->m_recsize = 50
    SET rptfont->m_fontname = rpt_times
    SET rptfont->m_pointsize = 10
    SET rptfont->m_bold = rpt_off
    SET rptfont->m_italic = rpt_off
    SET rptfont->m_underline = rpt_off
    SET rptfont->m_strikethrough = rpt_off
    SET rptfont->m_rgbcolor = rpt_black
    SET _times100 = uar_rptcreatefont(_hreport,rptfont)
    SET rptfont->m_pointsize = 12
    SET rptfont->m_bold = rpt_on
    SET _times12b0 = uar_rptcreatefont(_hreport,rptfont)
    SET rptfont->m_pointsize = 8
    SET rptfont->m_bold = rpt_off
    SET _times80 = uar_rptcreatefont(_hreport,rptfont)
    SET rptfont->m_pointsize = 10
    SET rptfont->m_bold = rpt_on
    SET _times10b0 = uar_rptcreatefont(_hreport,rptfont)
    SET rptfont->m_pointsize = 8
    SET _times8b0 = uar_rptcreatefont(_hreport,rptfont)
  END ;Subroutine
  SUBROUTINE _createpens(dummy)
    SET rptpen->m_recsize = 16
    SET rptpen->m_penwidth = 0.014
    SET rptpen->m_penstyle = 0
    SET rptpen->m_rgbcolor = rpt_black
    SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
  END ;Subroutine
  IF (rpt_output_type=rpt_output_paper_summary)
   SET d0 = initializereport(0)
   SELECT INTO "nl:"
    summary_sort =
    IF (( $SUMMARY_BY=1)) trim(substring(1,40,charges->c_detail[d.seq].activity_type),3)
    ELSEIF (( $SUMMARY_BY=2)) trim(substring(1,40,charges->c_detail[d.seq].cost_center),3)
    ELSEIF (( $SUMMARY_BY=3)) trim(substring(1,40,charges->c_detail[d.seq].encntr_type),3)
    ELSEIF (( $SUMMARY_BY=4)) trim(substring(1,100,charges->c_detail[d.seq].interface_file_name),3)
    ELSEIF (( $SUMMARY_BY=5)) trim(substring(1,100,charges->c_detail[d.seq].organization_name),3)
    ELSEIF (( $SUMMARY_BY=6)) trim(substring(1,100,charges->c_detail[d.seq].tier_group),3)
    ELSEIF (( $SUMMARY_BY=7)) concat(trim(substring(1,100,charges->c_detail[d.seq].
        verify_phys_name_last_key),3),", ",trim(substring(1,100,charges->c_detail[d.seq].
        verify_phys_name_first_key),3),", ",trim(cnvtstring(charges->c_detail[d.seq].verify_phys_id))
      )
    ENDIF
    FROM (dummyt d  WITH seq = value(charges->c_cnt))
    PLAN (d)
    ORDER BY summary_sort
    HEAD PAGE
     gbs_cnt = 0
    HEAD summary_sort
     gbs_cnt = (gbs_cnt+ 1), stat = alterlist(group_by_summary->gbs_detail,gbs_cnt)
     IF (( $SUMMARY_BY > 0)
      AND ( $SUMMARY_BY < 7))
      group_by_summary->gbs_detail[gbs_cnt].group_by_thing_text = summary_sort
     ELSEIF (( $SUMMARY_BY=7))
      group_by_summary->gbs_detail[gbs_cnt].group_by_thing_text = trim(substring(1,100,charges->
        c_detail[d.seq].verify_phys_name),3)
     ENDIF
     group_by_summary_cnt = 0
    DETAIL
     group_by_summary_cnt = (group_by_summary_cnt+ 1), group_by_summary->gbs_total_cnt = (
     group_by_summary->gbs_total_cnt+ 1), group_by_summary->gbs_total_extended_price = (
     group_by_summary->gbs_total_extended_price+ charges->c_detail[d.seq].extended_price),
     group_by_summary->gbs_total_rvu = (group_by_summary->gbs_total_rvu+ charges->c_detail[d.seq].rvu
     ), group_by_summary->gbs_detail[gbs_cnt].group_by_extended_price = (group_by_summary->
     gbs_detail[gbs_cnt].group_by_extended_price+ charges->c_detail[d.seq].extended_price),
     group_by_summary->gbs_detail[gbs_cnt].group_by_rvu = (group_by_summary->gbs_detail[gbs_cnt].
     group_by_rvu+ charges->c_detail[d.seq].rvu)
    FOOT  summary_sort
     group_by_summary->gbs_detail[gbs_cnt].group_by_thing_cnt = group_by_summary_cnt
    FOOT REPORT
     group_by_summary->gbs_cnt = gbs_cnt
    WITH nocounter
   ;end select
   SELECT INTO  $OUTDEV
    FROM (dummyt d  WITH seq = value(group_by_summary->gbs_cnt))
    PLAN (d)
    HEAD PAGE
     d0 = headpagesummarysection(rpt_render)
    DETAIL
     i = d.seq
     IF (((_yoffset+ detailsummarysection(rpt_calcheight)) > 7.6))
      d0 = pagebreak(0), d0 = headpagesummarysection(rpt_render)
     ENDIF
     d0 = detailsummarysection(rpt_render)
    FOOT REPORT
     IF (((_yoffset+ footsummarysection(rpt_calcheight)) > 7.6))
      d0 = pagebreak(0), d0 = headpagesummarysection(rpt_render)
     ENDIF
     do = footsummarysection(rpt_render)
     IF (((_yoffset+ footreportsection0(rpt_calcheight)) > 7.6))
      d0 = pagebreak(0), d0 = headpagesummarysection(rpt_render)
     ENDIF
     d0 = footreportsection0(rpt_render)
    WITH nocounter
   ;end select
   SET d0 = finalizereport( $OUTDEV)
  ELSEIF (rpt_output_type=rpt_output_paper_phys)
   SET d0 = initializereport(0)
   SELECT INTO "nl:"
    prim_sort = concat(trim(substring(1,100,charges->c_detail[d.seq].verify_phys_name_last_key),3),
     ", ",trim(substring(1,100,charges->c_detail[d.seq].verify_phys_name_first_key),3),", ",trim(
      cnvtstring(charges->c_detail[d.seq].verify_phys_id))), sec_sort =
    IF (( $PHYS_SPEC_SORT=1)) concat(trim(substring(1,10,charges->c_detail[d.seq].cpt),3)," - ",trim(
       substring(1,200,charges->c_detail[d.seq].description),3))
    ELSEIF (( $PHYS_SPEC_SORT=2)) trim(substring(1,200,charges->c_detail[d.seq].description),3)
    ENDIF
    FROM (dummyt d  WITH seq = value(charges->c_cnt))
    PLAN (d)
    ORDER BY prim_sort, sec_sort
    HEAD PAGE
     ps_cnt = 0
    HEAD prim_sort
     ps_cnt = (ps_cnt+ 1), stat = alterlist(physician_summary->ps_detail,ps_cnt), physician_summary->
     ps_detail[ps_cnt].physician_name = trim(charges->c_detail[d.seq].verify_phys_name),
     physician_summary->ps_detail[ps_cnt].physician_id = charges->c_detail[d.seq].verify_phys_id,
     physician_summary->ps_detail[ps_cnt].physician_name_first_key = trim(charges->c_detail[d.seq].
      verify_phys_name_first_key), physician_summary->ps_detail[ps_cnt].physician_name_last_key =
     trim(charges->c_detail[d.seq].verify_phys_name_last_key),
     procedure_cnt = 0
    HEAD sec_sort
     procedure_cnt = (procedure_cnt+ 1)
     IF (mod(procedure_cnt,10)=1)
      stat = alterlist(physician_summary->ps_detail[ps_cnt].procedure_detail,(procedure_cnt+ 9))
     ENDIF
     IF (textlen(trim(charges->c_detail[d.seq].cpt,3)) > 0)
      physician_summary->ps_detail[ps_cnt].procedure_detail[procedure_cnt].procedure_description =
      sec_sort
     ELSE
      physician_summary->ps_detail[ps_cnt].procedure_detail[procedure_cnt].procedure_description =
      trim(charges->c_detail[d.seq].description)
     ENDIF
    DETAIL
     physician_summary->ps_total_cnt = (physician_summary->ps_total_cnt+ 1), physician_summary->
     ps_total_extended_price = (physician_summary->ps_total_extended_price+ charges->c_detail[d.seq].
     extended_price), physician_summary->ps_total_rvu = (physician_summary->ps_total_rvu+ charges->
     c_detail[d.seq].rvu),
     physician_summary->ps_detail[ps_cnt].count_per_physician = (physician_summary->ps_detail[ps_cnt]
     .count_per_physician+ 1), physician_summary->ps_detail[ps_cnt].physician_extended_price = (
     physician_summary->ps_detail[ps_cnt].physician_extended_price+ charges->c_detail[d.seq].
     extended_price), physician_summary->ps_detail[ps_cnt].physician_rvu = (physician_summary->
     ps_detail[ps_cnt].physician_rvu+ charges->c_detail[d.seq].rvu),
     physician_summary->ps_detail[ps_cnt].procedure_detail[procedure_cnt].count_per_procedure = (
     physician_summary->ps_detail[ps_cnt].procedure_detail[procedure_cnt].count_per_procedure+ 1),
     physician_summary->ps_detail[ps_cnt].procedure_detail[procedure_cnt].procedure_extended_price =
     (physician_summary->ps_detail[ps_cnt].procedure_detail[procedure_cnt].procedure_extended_price+
     charges->c_detail[d.seq].extended_price), physician_summary->ps_detail[ps_cnt].procedure_detail[
     procedure_cnt].procedure_rvu = (physician_summary->ps_detail[ps_cnt].procedure_detail[
     procedure_cnt].procedure_rvu+ charges->c_detail[d.seq].rvu)
    FOOT  sec_sort
     null
    FOOT  prim_sort
     stat = alterlist(physician_summary->ps_detail[ps_cnt].procedure_detail,procedure_cnt),
     physician_summary->ps_detail[ps_cnt].procedure_cnt = procedure_cnt
    FOOT REPORT
     physician_summary->ps_cnt = ps_cnt
    WITH nocounter
   ;end select
   SELECT INTO  $OUTDEV
    phys_sort = concat(trim(substring(1,100,physician_summary->ps_detail[d.seq].
       physician_name_last_key),3),", ",trim(substring(1,100,physician_summary->ps_detail[d.seq].
       physician_name_first_key),3),", ",trim(cnvtstring(physician_summary->ps_detail[d.seq].
       physician_id))), detail_sort = trim(substring(1,200,physician_summary->ps_detail[d.seq].
      procedure_detail[d2.seq].procedure_description),3)
    FROM (dummyt d  WITH seq = value(physician_summary->ps_cnt)),
     (dummyt d2  WITH seq = 1)
    PLAN (d
     WHERE maxrec(d2,physician_summary->ps_detail[d.seq].procedure_cnt))
     JOIN (d2)
    ORDER BY phys_sort, detail_sort
    HEAD REPORT
     first_physician = 0
    HEAD PAGE
     IF (d.seq=1)
      phys_name_display = trim(physician_summary->ps_detail[1].physician_name,3)
     ENDIF
     d0 = headpagephysiciansection(rpt_render)
    HEAD phys_sort
     i = d.seq, phys_name_display = trim(physician_summary->ps_detail[d.seq].physician_name,3)
     IF (first_physician=0)
      first_physician = 1
     ELSE
      d0 = pagebreak(0), d0 = headpagephysiciansection(rpt_render)
     ENDIF
     IF (((_yoffset+ headphysiciansection(rpt_calcheight)) > 7.6))
      d0 = pagebreak(0), d0 = headpagephysiciansection(rpt_render)
     ENDIF
     d0 = headphysiciansection(rpt_render)
    HEAD detail_sort
     null
    DETAIL
     ii = d2.seq
     IF (((_yoffset+ detailphysiciansection(rpt_calcheight)) > 7.6))
      d0 = pagebreak(0), d0 = headpagephysiciansection(rpt_render)
     ENDIF
     d0 = detailphysiciansection(rpt_render)
    FOOT  detail_sort
     null
    FOOT  phys_sort
     IF (((_yoffset+ footphysiciansection(rpt_calcheight)) > 7.6))
      d0 = pagebreak(0), d0 = headpagephysiciansection(rpt_render)
     ENDIF
     d0 = footphysiciansection(rpt_render)
    FOOT REPORT
     IF (((_yoffset+ footphysiciansummarysection(rpt_calcheight)) > 7.6))
      d0 = pagebreak(0), d0 = headpagephysiciansection(rpt_render)
     ENDIF
     do = footphysiciansummarysection(rpt_render)
     IF (((_yoffset+ footreportsection0(rpt_calcheight)) > 7.6))
      d0 = pagebreak(0), d0 = headpagephysiciansection(rpt_render)
     ENDIF
     d0 = footreportsection0(rpt_render)
    WITH nocounter
   ;end select
   SET d0 = finalizereport( $OUTDEV)
  ELSE
   SELECT INTO  $OUTDEV
    interface_filename = trim(substring(1,100,charges->c_detail[d.seq].interface_file_name),3),
    tier_group = trim(substring(1,100,charges->c_detail[d.seq].tier_group),3), posted_date =
    substring(1,17,format(charges->c_detail[d.seq].posted_date,"@SHORTDATETIME")),
    organization_name = trim(substring(1,100,charges->c_detail[d.seq].organization_name),3),
    cost_center = trim(substring(1,40,charges->c_detail[d.seq].cost_center),3), fin = trim(substring(
      1,40,charges->c_detail[d.seq].fin),3),
    encounter_type = trim(substring(1,40,charges->c_detail[d.seq].encntr_type),3), patient_name =
    trim(substring(1,100,charges->c_detail[d.seq].patient_name),3), service_date_time = substring(1,
     17,format(charges->c_detail[d.seq].service_date_time,"@SHORTDATETIME")),
    cdm = trim(substring(1,40,charges->c_detail[d.seq].cdm),3), cpt = trim(substring(1,40,charges->
      c_detail[d.seq].cpt),3), description = trim(substring(1,200,charges->c_detail[d.seq].
      description),3),
    activity_type = trim(substring(1,40,charges->c_detail[d.seq].activity_type),3), charge_type =
    trim(substring(1,40,charges->c_detail[d.seq].charge_type),3), item_quantity = charges->c_detail[d
    .seq].item_quantity,
    qcf = charges->c_detail[d.seq].qcf, extended_quantity = charges->c_detail[d.seq].
    extended_quantity, verifying_physician_name = trim(substring(1,100,charges->c_detail[d.seq].
      verify_phys_name),3),
    rvu = charges->c_detail[d.seq].rvu, item_price = charges->c_detail[d.seq].item_price,
    extended_price = charges->c_detail[d.seq].extended_price
    FROM (dummyt d  WITH seq = value(charges->c_cnt))
    PLAN (d)
    ORDER BY organization_name, fin, activity_type,
     description
    WITH nocounter, separator = " ", format
   ;end select
  ENDIF
 ELSE
  EXECUTE reportrtl
  DECLARE _createfonts(dummy) = null WITH protect
  DECLARE _createpens(dummy) = null WITH protect
  DECLARE pagebreak(dummy) = null WITH protect
  DECLARE finalizereport(ssendreport=vc) = null WITH protect
  DECLARE nodatasection0(ncalc=i2) = f8 WITH protect
  DECLARE nodatasection0abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
  DECLARE headpagesummarysection(ncalc=i2) = f8 WITH protect
  DECLARE headpagesummarysectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
  DECLARE headpagephysiciansection(ncalc=i2) = f8 WITH protect
  DECLARE headpagephysiciansectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
  DECLARE headphysiciansection(ncalc=i2) = f8 WITH protect
  DECLARE headphysiciansectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
  DECLARE detailsummarysection(ncalc=i2) = f8 WITH protect
  DECLARE detailsummarysectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
  DECLARE detailphysiciansection(ncalc=i2) = f8 WITH protect
  DECLARE detailphysiciansectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
  DECLARE footsummarysection(ncalc=i2) = f8 WITH protect
  DECLARE footsummarysectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
  DECLARE footphysiciansection(ncalc=i2) = f8 WITH protect
  DECLARE footphysiciansectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
  DECLARE footphysiciansummarysection(ncalc=i2) = f8 WITH protect
  DECLARE footphysiciansummarysectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
  DECLARE footreportsection0(ncalc=i2) = f8 WITH protect
  DECLARE footreportsection0abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
  DECLARE initializereport(dummy) = null WITH protect
  DECLARE _hreport = i4 WITH noconstant(0), protect
  DECLARE _yoffset = f8 WITH noconstant(0.0), protect
  DECLARE _xoffset = f8 WITH noconstant(0.0), protect
  DECLARE rpt_render = i2 WITH constant(0), protect
  DECLARE _crlf = vc WITH constant(concat(char(13),char(10))), protect
  DECLARE rpt_calcheight = i2 WITH constant(1), protect
  DECLARE _yshift = f8 WITH noconstant(0.0), protect
  DECLARE _xshift = f8 WITH noconstant(0.0), protect
  DECLARE _sendto = vc WITH noconstant(""), protect
  DECLARE _rpterr = i2 WITH noconstant(0), protect
  DECLARE _rptstat = i2 WITH noconstant(0), protect
  DECLARE _oldfont = i4 WITH noconstant(0), protect
  DECLARE _oldpen = i4 WITH noconstant(0), protect
  DECLARE _dummyfont = i4 WITH noconstant(0), protect
  DECLARE _dummypen = i4 WITH noconstant(0), protect
  DECLARE _fdrawheight = f8 WITH noconstant(0.0), protect
  DECLARE _rptpage = i4 WITH noconstant(0), protect
  DECLARE _diotype = i2 WITH noconstant(8), protect
  DECLARE _outputtype = i2 WITH noconstant(rpt_postscript), protect
  DECLARE _times8b0 = i4 WITH noconstant(0), protect
  DECLARE _times80 = i4 WITH noconstant(0), protect
  DECLARE _times10b0 = i4 WITH noconstant(0), protect
  DECLARE _times12b0 = i4 WITH noconstant(0), protect
  DECLARE _times100 = i4 WITH noconstant(0), protect
  DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
  SUBROUTINE pagebreak(dummy)
    SET _rptpage = uar_rptendpage(_hreport)
    SET _rptpage = uar_rptstartpage(_hreport)
    SET _yoffset = rptreport->m_margintop
  END ;Subroutine
  SUBROUTINE finalizereport(ssendreport)
    SET _rptpage = uar_rptendpage(_hreport)
    SET _rptstat = uar_rptendreport(_hreport)
    DECLARE sfilename = vc WITH noconstant(trim(ssendreport)), private
    DECLARE bprint = i2 WITH noconstant(0), private
    IF (textlen(sfilename) > 0)
     SET bprint = checkqueue(sfilename)
     IF (bprint)
      EXECUTE cpm_create_file_name "RPT", "PS"
      SET sfilename = cpm_cfn_info->file_name_path
     ENDIF
    ENDIF
    SET _rptstat = uar_rptprinttofile(_hreport,nullterm(sfilename))
    IF (bprint)
     SET spool value(sfilename) value(ssendreport) WITH deleted, dio = value(_diotype)
    ENDIF
    DECLARE _errorfound = i2 WITH noconstant(0), protect
    DECLARE _errcnt = i2 WITH noconstant(0), protect
    SET _errorfound = uar_rptfirsterror(_hreport,rpterror)
    WHILE (_errorfound=rpt_errorfound
     AND _errcnt < 512)
      SET _errcnt = (_errcnt+ 1)
      SET stat = alterlist(rpterrors->errors,_errcnt)
      SET rpterrors->errors[_errcnt].m_severity = rpterror->m_severity
      SET rpterrors->errors[_errcnt].m_text = rpterror->m_text
      SET rpterrors->errors[_errcnt].m_source = rpterror->m_source
      SET _errorfound = uar_rptnexterror(_hreport,rpterror)
    ENDWHILE
    SET _rptstat = uar_rptdestroyreport(_hreport)
  END ;Subroutine
  SUBROUTINE nodatasection0(ncalc)
    DECLARE a1 = f8 WITH noconstant(0.0), private
    SET a1 = nodatasection0abs(ncalc,_xoffset,_yoffset)
    RETURN(a1)
  END ;Subroutine
  SUBROUTINE nodatasection0abs(ncalc,offsetx,offsety)
    DECLARE sectionheight = f8 WITH noconstant(1.000000), private
    IF (ncalc=rpt_render)
     SET rptsd->m_flags = 16
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_linespacing = rpt_single
     SET rptsd->m_rotationangle = 0
     SET rptsd->m_y = (offsety+ 0.000)
     SET rptsd->m_x = (offsetx+ 0.750)
     SET rptsd->m_width = 9.000
     SET rptsd->m_height = 0.875
     SET _oldfont = uar_rptsetfont(_hreport,_times12b0)
     SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(no_data_title,char(0)))
     SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
     SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
     SET _yoffset = (offsety+ sectionheight)
    ENDIF
    RETURN(sectionheight)
  END ;Subroutine
  SUBROUTINE headpagesummarysection(ncalc)
    DECLARE a1 = f8 WITH noconstant(0.0), private
    SET a1 = headpagesummarysectionabs(ncalc,_xoffset,_yoffset)
    RETURN(a1)
  END ;Subroutine
  SUBROUTINE headpagesummarysectionabs(ncalc,offsetx,offsety)
    DECLARE sectionheight = f8 WITH noconstant(1.170000), private
    DECLARE __fieldname0 = vc WITH noconstant(build2(trim(summary_by_prompt),char(0))), protect
    IF (ncalc=rpt_render)
     SET rptsd->m_flags = 64
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_linespacing = rpt_single
     SET rptsd->m_rotationangle = 0
     SET rptsd->m_y = (offsety+ 0.281)
     SET rptsd->m_x = (offsetx+ 9.313)
     SET rptsd->m_width = 1.188
     SET rptsd->m_height = 0.260
     SET _oldfont = uar_rptsetfont(_hreport,_times80)
     SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(rpt_pageofpage,char(0)))
     SET rptsd->m_flags = 0
     SET rptsd->m_y = (offsety+ 0.281)
     SET rptsd->m_x = (offsetx+ 0.000)
     SET rptsd->m_width = 2.750
     SET rptsd->m_height = 0.260
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(exec_date_str,char(0)))
     SET rptsd->m_flags = 16
     SET rptsd->m_y = (offsety+ 0.281)
     SET rptsd->m_x = (offsetx+ 2.760)
     SET rptsd->m_width = 4.990
     SET rptsd->m_height = 0.302
     SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(prompt_dates,char(0)))
     SET rptsd->m_flags = 68
     SET rptsd->m_y = (offsety+ 0.990)
     SET rptsd->m_x = (offsetx+ 2.250)
     SET rptsd->m_width = 0.750
     SET rptsd->m_height = 0.198
     SET _dummyfont = uar_rptsetfont(_hreport,_times80)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("COUNT",char(0)))
     SET rptsd->m_flags = 4
     SET rptsd->m_y = (offsety+ 0.990)
     SET rptsd->m_x = (offsetx+ 3.125)
     SET rptsd->m_width = 2.500
     SET rptsd->m_height = 0.198
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("DESCRIPTION",char(0)))
     SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 1.147),(offsetx+ 10.500),(offsety
      + 1.147))
     SET rptsd->m_flags = 16
     SET rptsd->m_y = (offsety+ 0.000)
     SET rptsd->m_x = (offsetx+ 2.750)
     SET rptsd->m_width = 5.000
     SET rptsd->m_height = 0.292
     SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname0)
     SET rptsd->m_flags = 68
     SET rptsd->m_y = (offsety+ 0.990)
     SET rptsd->m_x = (offsetx+ 6.688)
     SET rptsd->m_width = 1.125
     SET rptsd->m_height = 0.198
     SET _dummyfont = uar_rptsetfont(_hreport,_times80)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("EXTENDED PRICE",char(0)))
     SET rptsd->m_y = (offsety+ 0.990)
     SET rptsd->m_x = (offsetx+ 5.750)
     SET rptsd->m_width = 0.771
     SET rptsd->m_height = 0.177
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("RVU",char(0)))
     SET rptsd->m_flags = 16
     SET rptsd->m_y = (offsety+ 0.490)
     SET rptsd->m_x = (offsetx+ 2.760)
     SET rptsd->m_width = 4.990
     SET rptsd->m_height = 0.260
     SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(prompt_organization,char(0)))
     SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
     SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
     SET _yoffset = (offsety+ sectionheight)
    ENDIF
    RETURN(sectionheight)
  END ;Subroutine
  SUBROUTINE headpagephysiciansection(ncalc)
    DECLARE a1 = f8 WITH noconstant(0.0), private
    SET a1 = headpagephysiciansectionabs(ncalc,_xoffset,_yoffset)
    RETURN(a1)
  END ;Subroutine
  SUBROUTINE headpagephysiciansectionabs(ncalc,offsetx,offsety)
    DECLARE sectionheight = f8 WITH noconstant(1.170000), private
    IF (ncalc=rpt_render)
     SET rptsd->m_flags = 64
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_linespacing = rpt_single
     SET rptsd->m_rotationangle = 0
     SET rptsd->m_y = (offsety+ 0.271)
     SET rptsd->m_x = (offsetx+ 9.313)
     SET rptsd->m_width = 1.188
     SET rptsd->m_height = 0.260
     SET _oldfont = uar_rptsetfont(_hreport,_times80)
     SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(rpt_pageofpage,char(0)))
     SET rptsd->m_flags = 0
     SET rptsd->m_y = (offsety+ 0.271)
     SET rptsd->m_x = (offsetx+ 0.000)
     SET rptsd->m_width = 2.750
     SET rptsd->m_height = 0.260
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(exec_date_str,char(0)))
     SET rptsd->m_flags = 16
     SET rptsd->m_y = (offsety+ 0.271)
     SET rptsd->m_x = (offsetx+ 2.750)
     SET rptsd->m_width = 5.000
     SET rptsd->m_height = 0.229
     SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(prompt_dates,char(0)))
     SET rptsd->m_flags = 4
     SET rptsd->m_y = (offsety+ 0.938)
     SET rptsd->m_x = (offsetx+ 0.750)
     SET rptsd->m_width = 2.250
     SET rptsd->m_height = 0.198
     SET _dummyfont = uar_rptsetfont(_hreport,_times80)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("PHYSICIAN NAME",char(0)))
     SET rptsd->m_y = (offsety+ 0.938)
     SET rptsd->m_x = (offsetx+ 3.125)
     SET rptsd->m_width = 2.750
     SET rptsd->m_height = 0.198
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("DESCRIPTION",char(0)))
     SET rptsd->m_flags = 68
     SET rptsd->m_y = (offsety+ 0.938)
     SET rptsd->m_x = (offsetx+ 6.000)
     SET rptsd->m_width = 1.000
     SET rptsd->m_height = 0.198
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("COUNT",char(0)))
     SET rptsd->m_y = (offsety+ 0.938)
     SET rptsd->m_x = (offsetx+ 7.125)
     SET rptsd->m_width = 1.250
     SET rptsd->m_height = 0.198
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("RVU",char(0)))
     SET rptsd->m_y = (offsety+ 0.938)
     SET rptsd->m_x = (offsetx+ 8.500)
     SET rptsd->m_width = 1.250
     SET rptsd->m_height = 0.198
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("EXT PRICE",char(0)))
     SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.031),(offsety+ 1.094),(offsetx+ 10.489),(offsety
      + 1.094))
     SET rptsd->m_flags = 16
     SET rptsd->m_y = (offsety+ 0.000)
     SET rptsd->m_x = (offsetx+ 2.760)
     SET rptsd->m_width = 4.990
     SET rptsd->m_height = 0.260
     SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(phys_spec_sort_prompt,char(0)))
     SET rptsd->m_flags = 32
     SET rptsd->m_y = (offsety+ 0.542)
     SET rptsd->m_x = (offsetx+ 0.250)
     SET rptsd->m_width = 4.000
     SET rptsd->m_height = 0.260
     SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(phys_name_display,char(0)))
     SET rptsd->m_flags = 64
     SET rptsd->m_y = (offsety+ 0.542)
     SET rptsd->m_x = (offsetx+ 6.250)
     SET rptsd->m_width = 4.000
     SET rptsd->m_height = 0.260
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(prompt_organization,char(0)))
     SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
     SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
     SET _yoffset = (offsety+ sectionheight)
    ENDIF
    RETURN(sectionheight)
  END ;Subroutine
  SUBROUTINE headphysiciansection(ncalc)
    DECLARE a1 = f8 WITH noconstant(0.0), private
    SET a1 = headphysiciansectionabs(ncalc,_xoffset,_yoffset)
    RETURN(a1)
  END ;Subroutine
  SUBROUTINE headphysiciansectionabs(ncalc,offsetx,offsety)
    DECLARE sectionheight = f8 WITH noconstant(0.310000), private
    DECLARE __fieldname7 = vc WITH noconstant(build2(physician_summary->ps_detail[i].physician_name,
      char(0))), protect
    IF (ncalc=rpt_render)
     SET rptsd->m_flags = 0
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_linespacing = rpt_single
     SET rptsd->m_rotationangle = 0
     SET rptsd->m_y = (offsety+ 0.000)
     SET rptsd->m_x = (offsetx+ 0.750)
     SET rptsd->m_width = 2.250
     SET rptsd->m_height = 0.260
     SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
     SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname7)
     SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
     SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    ENDIF
    RETURN(sectionheight)
  END ;Subroutine
  SUBROUTINE detailsummarysection(ncalc)
    DECLARE a1 = f8 WITH noconstant(0.0), private
    SET a1 = detailsummarysectionabs(ncalc,_xoffset,_yoffset)
    RETURN(a1)
  END ;Subroutine
  SUBROUTINE detailsummarysectionabs(ncalc,offsetx,offsety)
    DECLARE sectionheight = f8 WITH noconstant(0.200000), private
    DECLARE __fieldname0 = vc WITH noconstant(build2(group_by_summary->gbs_detail[i].
      group_by_thing_cnt,char(0))), protect
    DECLARE __fieldname1 = vc WITH noconstant(build2(group_by_summary->gbs_detail[i].
      group_by_thing_text,char(0))), protect
    DECLARE __fieldname2 = vc WITH noconstant(build2(group_by_summary->gbs_detail[i].
      group_by_extended_price,char(0))), protect
    DECLARE __fieldname3 = vc WITH noconstant(build2(group_by_summary->gbs_detail[i].group_by_rvu,
      char(0))), protect
    IF (ncalc=rpt_render)
     SET rptsd->m_flags = 64
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_linespacing = rpt_single
     SET rptsd->m_rotationangle = 0
     SET rptsd->m_y = (offsety+ 0.000)
     SET rptsd->m_x = (offsetx+ 2.250)
     SET rptsd->m_width = 0.750
     SET rptsd->m_height = 0.198
     SET _oldfont = uar_rptsetfont(_hreport,_times80)
     SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname0)
     SET rptsd->m_flags = 0
     SET rptsd->m_y = (offsety+ 0.000)
     SET rptsd->m_x = (offsetx+ 3.125)
     SET rptsd->m_width = 2.500
     SET rptsd->m_height = 0.198
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname1)
     SET rptsd->m_flags = 64
     SET rptsd->m_y = (offsety+ 0.000)
     SET rptsd->m_x = (offsetx+ 6.688)
     SET rptsd->m_width = 1.125
     SET rptsd->m_height = 0.198
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname2)
     SET rptsd->m_y = (offsety+ 0.000)
     SET rptsd->m_x = (offsetx+ 5.750)
     SET rptsd->m_width = 0.750
     SET rptsd->m_height = 0.198
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname3)
     SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
     SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
     SET _yoffset = (offsety+ sectionheight)
    ENDIF
    RETURN(sectionheight)
  END ;Subroutine
  SUBROUTINE detailphysiciansection(ncalc)
    DECLARE a1 = f8 WITH noconstant(0.0), private
    SET a1 = detailphysiciansectionabs(ncalc,_xoffset,_yoffset)
    RETURN(a1)
  END ;Subroutine
  SUBROUTINE detailphysiciansectionabs(ncalc,offsetx,offsety)
    DECLARE sectionheight = f8 WITH noconstant(0.250000), private
    DECLARE __fieldname10 = vc WITH noconstant(build2(physician_summary->ps_detail[i].
      procedure_detail[ii].procedure_description,char(0))), protect
    DECLARE __fieldname15 = vc WITH noconstant(build2(physician_summary->ps_detail[i].
      procedure_detail[ii].count_per_procedure,char(0))), protect
    DECLARE __fieldname16 = vc WITH noconstant(build2(physician_summary->ps_detail[i].
      procedure_detail[ii].procedure_rvu,char(0))), protect
    DECLARE __fieldname17 = vc WITH noconstant(build2(physician_summary->ps_detail[i].
      procedure_detail[ii].procedure_extended_price,char(0))), protect
    IF (ncalc=rpt_render)
     SET rptsd->m_flags = 0
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_linespacing = rpt_single
     SET rptsd->m_rotationangle = 0
     SET rptsd->m_y = (offsety+ 0.000)
     SET rptsd->m_x = (offsetx+ 3.125)
     SET rptsd->m_width = 2.750
     SET rptsd->m_height = 0.250
     SET _oldfont = uar_rptsetfont(_hreport,_times80)
     SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname10)
     SET rptsd->m_flags = 64
     SET rptsd->m_y = (offsety+ 0.000)
     SET rptsd->m_x = (offsetx+ 6.000)
     SET rptsd->m_width = 1.000
     SET rptsd->m_height = 0.198
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname15)
     SET rptsd->m_y = (offsety+ 0.000)
     SET rptsd->m_x = (offsetx+ 7.125)
     SET rptsd->m_width = 1.250
     SET rptsd->m_height = 0.198
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname16)
     SET rptsd->m_y = (offsety+ 0.000)
     SET rptsd->m_x = (offsetx+ 8.500)
     SET rptsd->m_width = 1.250
     SET rptsd->m_height = 0.198
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname17)
     SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
     SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
     SET _yoffset = (offsety+ sectionheight)
    ENDIF
    RETURN(sectionheight)
  END ;Subroutine
  SUBROUTINE footsummarysection(ncalc)
    DECLARE a1 = f8 WITH noconstant(0.0), private
    SET a1 = footsummarysectionabs(ncalc,_xoffset,_yoffset)
    RETURN(a1)
  END ;Subroutine
  SUBROUTINE footsummarysectionabs(ncalc,offsetx,offsety)
    DECLARE sectionheight = f8 WITH noconstant(0.740000), private
    DECLARE __fieldname1 = vc WITH noconstant(build2(group_by_summary->gbs_total_cnt,char(0))),
    protect
    DECLARE __fieldname2 = vc WITH noconstant(build2(group_by_summary->gbs_total_extended_price,char(
       0))), protect
    DECLARE __fieldname6 = vc WITH noconstant(build2(group_by_summary->gbs_total_rvu,char(0))),
    protect
    IF (ncalc=rpt_render)
     SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
     SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.250),(offsety+ 0.130),(offsetx+ 3.010),(offsety
      + 0.130))
     SET rptsd->m_flags = 64
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_linespacing = rpt_single
     SET rptsd->m_rotationangle = 0
     SET rptsd->m_y = (offsety+ 0.260)
     SET rptsd->m_x = (offsetx+ 2.000)
     SET rptsd->m_width = 1.000
     SET rptsd->m_height = 0.260
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname1)
     SET rptsd->m_y = (offsety+ 0.260)
     SET rptsd->m_x = (offsetx+ 6.625)
     SET rptsd->m_width = 1.219
     SET rptsd->m_height = 0.260
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname2)
     SET rptsd->m_flags = 0
     SET rptsd->m_y = (offsety+ 0.260)
     SET rptsd->m_x = (offsetx+ 3.125)
     SET rptsd->m_width = 2.500
     SET rptsd->m_height = 0.260
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(foot_summary_text,char(0)))
     SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.750),(offsety+ 0.130),(offsetx+ 6.510),(offsety
      + 0.130))
     SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.063),(offsety+ 0.130),(offsetx+ 7.823),(offsety
      + 0.130))
     SET rptsd->m_flags = 64
     SET rptsd->m_y = (offsety+ 0.260)
     SET rptsd->m_x = (offsetx+ 5.313)
     SET rptsd->m_width = 1.177
     SET rptsd->m_height = 0.260
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname6)
     SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
     SET _yoffset = (offsety+ sectionheight)
    ENDIF
    RETURN(sectionheight)
  END ;Subroutine
  SUBROUTINE footphysiciansection(ncalc)
    DECLARE a1 = f8 WITH noconstant(0.0), private
    SET a1 = footphysiciansectionabs(ncalc,_xoffset,_yoffset)
    RETURN(a1)
  END ;Subroutine
  SUBROUTINE footphysiciansectionabs(ncalc,offsetx,offsety)
    DECLARE sectionheight = f8 WITH noconstant(0.750000), private
    DECLARE __fieldname4 = vc WITH noconstant(build2(physician_summary->ps_detail[i].
      count_per_physician,char(0))), protect
    DECLARE __fieldname5 = vc WITH noconstant(build2(physician_summary->ps_detail[i].
      physician_extended_price,char(0))), protect
    DECLARE __fieldname6 = vc WITH noconstant(build2(physician_summary->ps_detail[i].physician_rvu,
      char(0))), protect
    DECLARE __fieldname7 = vc WITH noconstant(build2(concat("TOTAL for ",physician_summary->
       ps_detail[i].physician_name),char(0))), protect
    IF (ncalc=rpt_render)
     SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
     SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.625),(offsety+ 0.146),(offsetx+ 8.385),(offsety
      + 0.146))
     SET _rptstat = uar_rptline(_hreport,(offsetx+ 9.000),(offsety+ 0.146),(offsetx+ 9.760),(offsety
      + 0.146))
     SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.250),(offsety+ 0.146),(offsetx+ 7.010),(offsety
      + 0.146))
     SET rptsd->m_flags = 64
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_linespacing = rpt_single
     SET rptsd->m_rotationangle = 0
     SET rptsd->m_y = (offsety+ 0.313)
     SET rptsd->m_x = (offsetx+ 6.000)
     SET rptsd->m_width = 1.000
     SET rptsd->m_height = 0.260
     SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname4)
     SET rptsd->m_y = (offsety+ 0.313)
     SET rptsd->m_x = (offsetx+ 8.500)
     SET rptsd->m_width = 1.250
     SET rptsd->m_height = 0.271
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname5)
     SET rptsd->m_y = (offsety+ 0.313)
     SET rptsd->m_x = (offsetx+ 7.125)
     SET rptsd->m_width = 1.250
     SET rptsd->m_height = 0.260
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname6)
     SET rptsd->m_flags = 0
     SET rptsd->m_y = (offsety+ 0.313)
     SET rptsd->m_x = (offsetx+ 3.125)
     SET rptsd->m_width = 2.625
     SET rptsd->m_height = 0.323
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname7)
     SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
     SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
     SET _yoffset = (offsety+ sectionheight)
    ENDIF
    RETURN(sectionheight)
  END ;Subroutine
  SUBROUTINE footphysiciansummarysection(ncalc)
    DECLARE a1 = f8 WITH noconstant(0.0), private
    SET a1 = footphysiciansummarysectionabs(ncalc,_xoffset,_yoffset)
    RETURN(a1)
  END ;Subroutine
  SUBROUTINE footphysiciansummarysectionabs(ncalc,offsetx,offsety)
    DECLARE sectionheight = f8 WITH noconstant(0.750000), private
    DECLARE __fieldname4 = vc WITH noconstant(build2(physician_summary->ps_total_extended_price,char(
       0))), protect
    DECLARE __fieldname5 = vc WITH noconstant(build2(physician_summary->ps_total_rvu,char(0))),
    protect
    DECLARE __fieldname6 = vc WITH noconstant(build2(physician_summary->ps_total_cnt,char(0))),
    protect
    IF (ncalc=rpt_render)
     SET rptsd->m_flags = 0
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_linespacing = rpt_single
     SET rptsd->m_rotationangle = 0
     SET rptsd->m_y = (offsety+ 0.313)
     SET rptsd->m_x = (offsetx+ 3.125)
     SET rptsd->m_width = 2.438
     SET rptsd->m_height = 0.260
     SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
     SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(foot_phys_summary_text,char(0)))
     SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.250),(offsety+ 0.130),(offsetx+ 7.010),(offsety
      + 0.130))
     SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.625),(offsety+ 0.130),(offsetx+ 8.385),(offsety
      + 0.130))
     SET _rptstat = uar_rptline(_hreport,(offsetx+ 9.000),(offsety+ 0.130),(offsetx+ 9.760),(offsety
      + 0.130))
     SET rptsd->m_flags = 64
     SET rptsd->m_y = (offsety+ 0.313)
     SET rptsd->m_x = (offsetx+ 8.500)
     SET rptsd->m_width = 1.250
     SET rptsd->m_height = 0.260
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname4)
     SET rptsd->m_y = (offsety+ 0.313)
     SET rptsd->m_x = (offsetx+ 7.125)
     SET rptsd->m_width = 1.250
     SET rptsd->m_height = 0.260
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname5)
     SET rptsd->m_y = (offsety+ 0.313)
     SET rptsd->m_x = (offsetx+ 6.000)
     SET rptsd->m_width = 1.000
     SET rptsd->m_height = 0.260
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname6)
     SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
     SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
     SET _yoffset = (offsety+ sectionheight)
    ENDIF
    RETURN(sectionheight)
  END ;Subroutine
  SUBROUTINE footreportsection0(ncalc)
    DECLARE a1 = f8 WITH noconstant(0.0), private
    SET a1 = footreportsection0abs(ncalc,_xoffset,_yoffset)
    RETURN(a1)
  END ;Subroutine
  SUBROUTINE footreportsection0abs(ncalc,offsetx,offsety)
    DECLARE sectionheight = f8 WITH noconstant(1.000000), private
    IF (ncalc=rpt_render)
     SET rptsd->m_flags = 16
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_linespacing = rpt_single
     SET rptsd->m_rotationangle = 0
     SET rptsd->m_y = (offsety+ 0.500)
     SET rptsd->m_x = (offsetx+ 1.750)
     SET rptsd->m_width = 7.000
     SET rptsd->m_height = 0.198
     SET _oldfont = uar_rptsetfont(_hreport,_times8b0)
     SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("< < End of Report > >",char(0)))
     SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
     SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
     SET _yoffset = (offsety+ sectionheight)
    ENDIF
    RETURN(sectionheight)
  END ;Subroutine
  SUBROUTINE initializereport(dummy)
    SET rptreport->m_recsize = 100
    SET rptreport->m_reportname = "CCPS_CS_RVU_POSTED_CHARGES"
    SET rptreport->m_pagewidth = 8.50
    SET rptreport->m_pageheight = 11.00
    SET rptreport->m_orientation = rpt_landscape
    SET rptreport->m_marginleft = 0.25
    SET rptreport->m_marginright = 0.25
    SET rptreport->m_margintop = 0.25
    SET rptreport->m_marginbottom = 0.25
    SET rptreport->m_horzprintoffset = _xshift
    SET rptreport->m_vertprintoffset = _yshift
    SET _yoffset = rptreport->m_margintop
    SET _xoffset = rptreport->m_marginleft
    SET _hreport = uar_rptcreatereport(rptreport,_outputtype,rpt_inches)
    SET _rpterr = uar_rptseterrorlevel(_hreport,rpt_error)
    SET _rptstat = uar_rptstartreport(_hreport)
    SET _rptpage = uar_rptstartpage(_hreport)
    CALL _createfonts(0)
    CALL _createpens(0)
  END ;Subroutine
  SUBROUTINE _createfonts(dummy)
    SET rptfont->m_recsize = 50
    SET rptfont->m_fontname = rpt_times
    SET rptfont->m_pointsize = 10
    SET rptfont->m_bold = rpt_off
    SET rptfont->m_italic = rpt_off
    SET rptfont->m_underline = rpt_off
    SET rptfont->m_strikethrough = rpt_off
    SET rptfont->m_rgbcolor = rpt_black
    SET _times100 = uar_rptcreatefont(_hreport,rptfont)
    SET rptfont->m_pointsize = 12
    SET rptfont->m_bold = rpt_on
    SET _times12b0 = uar_rptcreatefont(_hreport,rptfont)
    SET rptfont->m_pointsize = 8
    SET rptfont->m_bold = rpt_off
    SET _times80 = uar_rptcreatefont(_hreport,rptfont)
    SET rptfont->m_pointsize = 10
    SET rptfont->m_bold = rpt_on
    SET _times10b0 = uar_rptcreatefont(_hreport,rptfont)
    SET rptfont->m_pointsize = 8
    SET _times8b0 = uar_rptcreatefont(_hreport,rptfont)
  END ;Subroutine
  SUBROUTINE _createpens(dummy)
    SET rptpen->m_recsize = 16
    SET rptpen->m_penwidth = 0.014
    SET rptpen->m_penstyle = 0
    SET rptpen->m_rgbcolor = rpt_black
    SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
  END ;Subroutine
  SET d0 = initializereport(0)
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    no_data_title = "There are no posted charges for the selected prompts.", d0 = nodatasection0(
     rpt_render)
   WITH nocounter
  ;end select
  SET d0 = finalizereport( $OUTDEV)
 ENDIF
#exit_prg
 IF (ld_failure_flag=1)
  EXECUTE reportrtl
  DECLARE _createfonts(dummy) = null WITH protect
  DECLARE _createpens(dummy) = null WITH protect
  DECLARE pagebreak(dummy) = null WITH protect
  DECLARE finalizereport(ssendreport=vc) = null WITH protect
  DECLARE nodatasection0(ncalc=i2) = f8 WITH protect
  DECLARE nodatasection0abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
  DECLARE headpagesummarysection(ncalc=i2) = f8 WITH protect
  DECLARE headpagesummarysectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
  DECLARE headpagephysiciansection(ncalc=i2) = f8 WITH protect
  DECLARE headpagephysiciansectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
  DECLARE headphysiciansection(ncalc=i2) = f8 WITH protect
  DECLARE headphysiciansectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
  DECLARE detailsummarysection(ncalc=i2) = f8 WITH protect
  DECLARE detailsummarysectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
  DECLARE detailphysiciansection(ncalc=i2) = f8 WITH protect
  DECLARE detailphysiciansectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
  DECLARE footsummarysection(ncalc=i2) = f8 WITH protect
  DECLARE footsummarysectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
  DECLARE footphysiciansection(ncalc=i2) = f8 WITH protect
  DECLARE footphysiciansectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
  DECLARE footphysiciansummarysection(ncalc=i2) = f8 WITH protect
  DECLARE footphysiciansummarysectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
  DECLARE footreportsection0(ncalc=i2) = f8 WITH protect
  DECLARE footreportsection0abs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
  DECLARE initializereport(dummy) = null WITH protect
  DECLARE _hreport = i4 WITH noconstant(0), protect
  DECLARE _yoffset = f8 WITH noconstant(0.0), protect
  DECLARE _xoffset = f8 WITH noconstant(0.0), protect
  DECLARE rpt_render = i2 WITH constant(0), protect
  DECLARE _crlf = vc WITH constant(concat(char(13),char(10))), protect
  DECLARE rpt_calcheight = i2 WITH constant(1), protect
  DECLARE _yshift = f8 WITH noconstant(0.0), protect
  DECLARE _xshift = f8 WITH noconstant(0.0), protect
  DECLARE _sendto = vc WITH noconstant(""), protect
  DECLARE _rpterr = i2 WITH noconstant(0), protect
  DECLARE _rptstat = i2 WITH noconstant(0), protect
  DECLARE _oldfont = i4 WITH noconstant(0), protect
  DECLARE _oldpen = i4 WITH noconstant(0), protect
  DECLARE _dummyfont = i4 WITH noconstant(0), protect
  DECLARE _dummypen = i4 WITH noconstant(0), protect
  DECLARE _fdrawheight = f8 WITH noconstant(0.0), protect
  DECLARE _rptpage = i4 WITH noconstant(0), protect
  DECLARE _diotype = i2 WITH noconstant(8), protect
  DECLARE _outputtype = i2 WITH noconstant(rpt_postscript), protect
  DECLARE _times8b0 = i4 WITH noconstant(0), protect
  DECLARE _times80 = i4 WITH noconstant(0), protect
  DECLARE _times10b0 = i4 WITH noconstant(0), protect
  DECLARE _times12b0 = i4 WITH noconstant(0), protect
  DECLARE _times100 = i4 WITH noconstant(0), protect
  DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
  SUBROUTINE pagebreak(dummy)
    SET _rptpage = uar_rptendpage(_hreport)
    SET _rptpage = uar_rptstartpage(_hreport)
    SET _yoffset = rptreport->m_margintop
  END ;Subroutine
  SUBROUTINE finalizereport(ssendreport)
    SET _rptpage = uar_rptendpage(_hreport)
    SET _rptstat = uar_rptendreport(_hreport)
    DECLARE sfilename = vc WITH noconstant(trim(ssendreport)), private
    DECLARE bprint = i2 WITH noconstant(0), private
    IF (textlen(sfilename) > 0)
     SET bprint = checkqueue(sfilename)
     IF (bprint)
      EXECUTE cpm_create_file_name "RPT", "PS"
      SET sfilename = cpm_cfn_info->file_name_path
     ENDIF
    ENDIF
    SET _rptstat = uar_rptprinttofile(_hreport,nullterm(sfilename))
    IF (bprint)
     SET spool value(sfilename) value(ssendreport) WITH deleted, dio = value(_diotype)
    ENDIF
    DECLARE _errorfound = i2 WITH noconstant(0), protect
    DECLARE _errcnt = i2 WITH noconstant(0), protect
    SET _errorfound = uar_rptfirsterror(_hreport,rpterror)
    WHILE (_errorfound=rpt_errorfound
     AND _errcnt < 512)
      SET _errcnt = (_errcnt+ 1)
      SET stat = alterlist(rpterrors->errors,_errcnt)
      SET rpterrors->errors[_errcnt].m_severity = rpterror->m_severity
      SET rpterrors->errors[_errcnt].m_text = rpterror->m_text
      SET rpterrors->errors[_errcnt].m_source = rpterror->m_source
      SET _errorfound = uar_rptnexterror(_hreport,rpterror)
    ENDWHILE
    SET _rptstat = uar_rptdestroyreport(_hreport)
  END ;Subroutine
  SUBROUTINE nodatasection0(ncalc)
    DECLARE a1 = f8 WITH noconstant(0.0), private
    SET a1 = nodatasection0abs(ncalc,_xoffset,_yoffset)
    RETURN(a1)
  END ;Subroutine
  SUBROUTINE nodatasection0abs(ncalc,offsetx,offsety)
    DECLARE sectionheight = f8 WITH noconstant(1.000000), private
    IF (ncalc=rpt_render)
     SET rptsd->m_flags = 16
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_linespacing = rpt_single
     SET rptsd->m_rotationangle = 0
     SET rptsd->m_y = (offsety+ 0.000)
     SET rptsd->m_x = (offsetx+ 0.750)
     SET rptsd->m_width = 9.000
     SET rptsd->m_height = 0.875
     SET _oldfont = uar_rptsetfont(_hreport,_times12b0)
     SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(no_data_title,char(0)))
     SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
     SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
     SET _yoffset = (offsety+ sectionheight)
    ENDIF
    RETURN(sectionheight)
  END ;Subroutine
  SUBROUTINE headpagesummarysection(ncalc)
    DECLARE a1 = f8 WITH noconstant(0.0), private
    SET a1 = headpagesummarysectionabs(ncalc,_xoffset,_yoffset)
    RETURN(a1)
  END ;Subroutine
  SUBROUTINE headpagesummarysectionabs(ncalc,offsetx,offsety)
    DECLARE sectionheight = f8 WITH noconstant(1.170000), private
    DECLARE __fieldname0 = vc WITH noconstant(build2(trim(summary_by_prompt),char(0))), protect
    IF (ncalc=rpt_render)
     SET rptsd->m_flags = 64
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_linespacing = rpt_single
     SET rptsd->m_rotationangle = 0
     SET rptsd->m_y = (offsety+ 0.281)
     SET rptsd->m_x = (offsetx+ 9.313)
     SET rptsd->m_width = 1.188
     SET rptsd->m_height = 0.260
     SET _oldfont = uar_rptsetfont(_hreport,_times80)
     SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(rpt_pageofpage,char(0)))
     SET rptsd->m_flags = 0
     SET rptsd->m_y = (offsety+ 0.281)
     SET rptsd->m_x = (offsetx+ 0.000)
     SET rptsd->m_width = 2.750
     SET rptsd->m_height = 0.260
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(exec_date_str,char(0)))
     SET rptsd->m_flags = 16
     SET rptsd->m_y = (offsety+ 0.281)
     SET rptsd->m_x = (offsetx+ 2.760)
     SET rptsd->m_width = 4.990
     SET rptsd->m_height = 0.302
     SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(prompt_dates,char(0)))
     SET rptsd->m_flags = 68
     SET rptsd->m_y = (offsety+ 0.990)
     SET rptsd->m_x = (offsetx+ 2.250)
     SET rptsd->m_width = 0.750
     SET rptsd->m_height = 0.198
     SET _dummyfont = uar_rptsetfont(_hreport,_times80)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("COUNT",char(0)))
     SET rptsd->m_flags = 4
     SET rptsd->m_y = (offsety+ 0.990)
     SET rptsd->m_x = (offsetx+ 3.125)
     SET rptsd->m_width = 2.500
     SET rptsd->m_height = 0.198
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("DESCRIPTION",char(0)))
     SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 1.147),(offsetx+ 10.500),(offsety
      + 1.147))
     SET rptsd->m_flags = 16
     SET rptsd->m_y = (offsety+ 0.000)
     SET rptsd->m_x = (offsetx+ 2.750)
     SET rptsd->m_width = 5.000
     SET rptsd->m_height = 0.292
     SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname0)
     SET rptsd->m_flags = 68
     SET rptsd->m_y = (offsety+ 0.990)
     SET rptsd->m_x = (offsetx+ 6.688)
     SET rptsd->m_width = 1.125
     SET rptsd->m_height = 0.198
     SET _dummyfont = uar_rptsetfont(_hreport,_times80)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("EXTENDED PRICE",char(0)))
     SET rptsd->m_y = (offsety+ 0.990)
     SET rptsd->m_x = (offsetx+ 5.750)
     SET rptsd->m_width = 0.771
     SET rptsd->m_height = 0.177
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("RVU",char(0)))
     SET rptsd->m_flags = 16
     SET rptsd->m_y = (offsety+ 0.490)
     SET rptsd->m_x = (offsetx+ 2.760)
     SET rptsd->m_width = 4.990
     SET rptsd->m_height = 0.260
     SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(prompt_organization,char(0)))
     SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
     SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
     SET _yoffset = (offsety+ sectionheight)
    ENDIF
    RETURN(sectionheight)
  END ;Subroutine
  SUBROUTINE headpagephysiciansection(ncalc)
    DECLARE a1 = f8 WITH noconstant(0.0), private
    SET a1 = headpagephysiciansectionabs(ncalc,_xoffset,_yoffset)
    RETURN(a1)
  END ;Subroutine
  SUBROUTINE headpagephysiciansectionabs(ncalc,offsetx,offsety)
    DECLARE sectionheight = f8 WITH noconstant(1.170000), private
    IF (ncalc=rpt_render)
     SET rptsd->m_flags = 64
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_linespacing = rpt_single
     SET rptsd->m_rotationangle = 0
     SET rptsd->m_y = (offsety+ 0.271)
     SET rptsd->m_x = (offsetx+ 9.313)
     SET rptsd->m_width = 1.188
     SET rptsd->m_height = 0.260
     SET _oldfont = uar_rptsetfont(_hreport,_times80)
     SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(rpt_pageofpage,char(0)))
     SET rptsd->m_flags = 0
     SET rptsd->m_y = (offsety+ 0.271)
     SET rptsd->m_x = (offsetx+ 0.000)
     SET rptsd->m_width = 2.750
     SET rptsd->m_height = 0.260
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(exec_date_str,char(0)))
     SET rptsd->m_flags = 16
     SET rptsd->m_y = (offsety+ 0.271)
     SET rptsd->m_x = (offsetx+ 2.750)
     SET rptsd->m_width = 5.000
     SET rptsd->m_height = 0.229
     SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(prompt_dates,char(0)))
     SET rptsd->m_flags = 4
     SET rptsd->m_y = (offsety+ 0.938)
     SET rptsd->m_x = (offsetx+ 0.750)
     SET rptsd->m_width = 2.250
     SET rptsd->m_height = 0.198
     SET _dummyfont = uar_rptsetfont(_hreport,_times80)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("PHYSICIAN NAME",char(0)))
     SET rptsd->m_y = (offsety+ 0.938)
     SET rptsd->m_x = (offsetx+ 3.125)
     SET rptsd->m_width = 2.750
     SET rptsd->m_height = 0.198
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("DESCRIPTION",char(0)))
     SET rptsd->m_flags = 68
     SET rptsd->m_y = (offsety+ 0.938)
     SET rptsd->m_x = (offsetx+ 6.000)
     SET rptsd->m_width = 1.000
     SET rptsd->m_height = 0.198
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("COUNT",char(0)))
     SET rptsd->m_y = (offsety+ 0.938)
     SET rptsd->m_x = (offsetx+ 7.125)
     SET rptsd->m_width = 1.250
     SET rptsd->m_height = 0.198
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("RVU",char(0)))
     SET rptsd->m_y = (offsety+ 0.938)
     SET rptsd->m_x = (offsetx+ 8.500)
     SET rptsd->m_width = 1.250
     SET rptsd->m_height = 0.198
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("EXT PRICE",char(0)))
     SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.031),(offsety+ 1.094),(offsetx+ 10.489),(offsety
      + 1.094))
     SET rptsd->m_flags = 16
     SET rptsd->m_y = (offsety+ 0.000)
     SET rptsd->m_x = (offsetx+ 2.760)
     SET rptsd->m_width = 4.990
     SET rptsd->m_height = 0.260
     SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(phys_spec_sort_prompt,char(0)))
     SET rptsd->m_flags = 32
     SET rptsd->m_y = (offsety+ 0.542)
     SET rptsd->m_x = (offsetx+ 0.250)
     SET rptsd->m_width = 4.000
     SET rptsd->m_height = 0.260
     SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(phys_name_display,char(0)))
     SET rptsd->m_flags = 64
     SET rptsd->m_y = (offsety+ 0.542)
     SET rptsd->m_x = (offsetx+ 6.250)
     SET rptsd->m_width = 4.000
     SET rptsd->m_height = 0.260
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(prompt_organization,char(0)))
     SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
     SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
     SET _yoffset = (offsety+ sectionheight)
    ENDIF
    RETURN(sectionheight)
  END ;Subroutine
  SUBROUTINE headphysiciansection(ncalc)
    DECLARE a1 = f8 WITH noconstant(0.0), private
    SET a1 = headphysiciansectionabs(ncalc,_xoffset,_yoffset)
    RETURN(a1)
  END ;Subroutine
  SUBROUTINE headphysiciansectionabs(ncalc,offsetx,offsety)
    DECLARE sectionheight = f8 WITH noconstant(0.310000), private
    DECLARE __fieldname7 = vc WITH noconstant(build2(physician_summary->ps_detail[i].physician_name,
      char(0))), protect
    IF (ncalc=rpt_render)
     SET rptsd->m_flags = 0
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_linespacing = rpt_single
     SET rptsd->m_rotationangle = 0
     SET rptsd->m_y = (offsety+ 0.000)
     SET rptsd->m_x = (offsetx+ 0.750)
     SET rptsd->m_width = 2.250
     SET rptsd->m_height = 0.260
     SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
     SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname7)
     SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
     SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    ENDIF
    RETURN(sectionheight)
  END ;Subroutine
  SUBROUTINE detailsummarysection(ncalc)
    DECLARE a1 = f8 WITH noconstant(0.0), private
    SET a1 = detailsummarysectionabs(ncalc,_xoffset,_yoffset)
    RETURN(a1)
  END ;Subroutine
  SUBROUTINE detailsummarysectionabs(ncalc,offsetx,offsety)
    DECLARE sectionheight = f8 WITH noconstant(0.200000), private
    DECLARE __fieldname0 = vc WITH noconstant(build2(group_by_summary->gbs_detail[i].
      group_by_thing_cnt,char(0))), protect
    DECLARE __fieldname1 = vc WITH noconstant(build2(group_by_summary->gbs_detail[i].
      group_by_thing_text,char(0))), protect
    DECLARE __fieldname2 = vc WITH noconstant(build2(group_by_summary->gbs_detail[i].
      group_by_extended_price,char(0))), protect
    DECLARE __fieldname3 = vc WITH noconstant(build2(group_by_summary->gbs_detail[i].group_by_rvu,
      char(0))), protect
    IF (ncalc=rpt_render)
     SET rptsd->m_flags = 64
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_linespacing = rpt_single
     SET rptsd->m_rotationangle = 0
     SET rptsd->m_y = (offsety+ 0.000)
     SET rptsd->m_x = (offsetx+ 2.250)
     SET rptsd->m_width = 0.750
     SET rptsd->m_height = 0.198
     SET _oldfont = uar_rptsetfont(_hreport,_times80)
     SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname0)
     SET rptsd->m_flags = 0
     SET rptsd->m_y = (offsety+ 0.000)
     SET rptsd->m_x = (offsetx+ 3.125)
     SET rptsd->m_width = 2.500
     SET rptsd->m_height = 0.198
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname1)
     SET rptsd->m_flags = 64
     SET rptsd->m_y = (offsety+ 0.000)
     SET rptsd->m_x = (offsetx+ 6.688)
     SET rptsd->m_width = 1.125
     SET rptsd->m_height = 0.198
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname2)
     SET rptsd->m_y = (offsety+ 0.000)
     SET rptsd->m_x = (offsetx+ 5.750)
     SET rptsd->m_width = 0.750
     SET rptsd->m_height = 0.198
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname3)
     SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
     SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
     SET _yoffset = (offsety+ sectionheight)
    ENDIF
    RETURN(sectionheight)
  END ;Subroutine
  SUBROUTINE detailphysiciansection(ncalc)
    DECLARE a1 = f8 WITH noconstant(0.0), private
    SET a1 = detailphysiciansectionabs(ncalc,_xoffset,_yoffset)
    RETURN(a1)
  END ;Subroutine
  SUBROUTINE detailphysiciansectionabs(ncalc,offsetx,offsety)
    DECLARE sectionheight = f8 WITH noconstant(0.250000), private
    DECLARE __fieldname10 = vc WITH noconstant(build2(physician_summary->ps_detail[i].
      procedure_detail[ii].procedure_description,char(0))), protect
    DECLARE __fieldname15 = vc WITH noconstant(build2(physician_summary->ps_detail[i].
      procedure_detail[ii].count_per_procedure,char(0))), protect
    DECLARE __fieldname16 = vc WITH noconstant(build2(physician_summary->ps_detail[i].
      procedure_detail[ii].procedure_rvu,char(0))), protect
    DECLARE __fieldname17 = vc WITH noconstant(build2(physician_summary->ps_detail[i].
      procedure_detail[ii].procedure_extended_price,char(0))), protect
    IF (ncalc=rpt_render)
     SET rptsd->m_flags = 0
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_linespacing = rpt_single
     SET rptsd->m_rotationangle = 0
     SET rptsd->m_y = (offsety+ 0.000)
     SET rptsd->m_x = (offsetx+ 3.125)
     SET rptsd->m_width = 2.750
     SET rptsd->m_height = 0.250
     SET _oldfont = uar_rptsetfont(_hreport,_times80)
     SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname10)
     SET rptsd->m_flags = 64
     SET rptsd->m_y = (offsety+ 0.000)
     SET rptsd->m_x = (offsetx+ 6.000)
     SET rptsd->m_width = 1.000
     SET rptsd->m_height = 0.198
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname15)
     SET rptsd->m_y = (offsety+ 0.000)
     SET rptsd->m_x = (offsetx+ 7.125)
     SET rptsd->m_width = 1.250
     SET rptsd->m_height = 0.198
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname16)
     SET rptsd->m_y = (offsety+ 0.000)
     SET rptsd->m_x = (offsetx+ 8.500)
     SET rptsd->m_width = 1.250
     SET rptsd->m_height = 0.198
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname17)
     SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
     SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
     SET _yoffset = (offsety+ sectionheight)
    ENDIF
    RETURN(sectionheight)
  END ;Subroutine
  SUBROUTINE footsummarysection(ncalc)
    DECLARE a1 = f8 WITH noconstant(0.0), private
    SET a1 = footsummarysectionabs(ncalc,_xoffset,_yoffset)
    RETURN(a1)
  END ;Subroutine
  SUBROUTINE footsummarysectionabs(ncalc,offsetx,offsety)
    DECLARE sectionheight = f8 WITH noconstant(0.740000), private
    DECLARE __fieldname1 = vc WITH noconstant(build2(group_by_summary->gbs_total_cnt,char(0))),
    protect
    DECLARE __fieldname2 = vc WITH noconstant(build2(group_by_summary->gbs_total_extended_price,char(
       0))), protect
    DECLARE __fieldname6 = vc WITH noconstant(build2(group_by_summary->gbs_total_rvu,char(0))),
    protect
    IF (ncalc=rpt_render)
     SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
     SET _rptstat = uar_rptline(_hreport,(offsetx+ 2.250),(offsety+ 0.130),(offsetx+ 3.010),(offsety
      + 0.130))
     SET rptsd->m_flags = 64
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_linespacing = rpt_single
     SET rptsd->m_rotationangle = 0
     SET rptsd->m_y = (offsety+ 0.260)
     SET rptsd->m_x = (offsetx+ 2.000)
     SET rptsd->m_width = 1.000
     SET rptsd->m_height = 0.260
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname1)
     SET rptsd->m_y = (offsety+ 0.260)
     SET rptsd->m_x = (offsetx+ 6.625)
     SET rptsd->m_width = 1.219
     SET rptsd->m_height = 0.260
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname2)
     SET rptsd->m_flags = 0
     SET rptsd->m_y = (offsety+ 0.260)
     SET rptsd->m_x = (offsetx+ 3.125)
     SET rptsd->m_width = 2.500
     SET rptsd->m_height = 0.260
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(foot_summary_text,char(0)))
     SET _rptstat = uar_rptline(_hreport,(offsetx+ 5.750),(offsety+ 0.130),(offsetx+ 6.510),(offsety
      + 0.130))
     SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.063),(offsety+ 0.130),(offsetx+ 7.823),(offsety
      + 0.130))
     SET rptsd->m_flags = 64
     SET rptsd->m_y = (offsety+ 0.260)
     SET rptsd->m_x = (offsetx+ 5.313)
     SET rptsd->m_width = 1.177
     SET rptsd->m_height = 0.260
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname6)
     SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
     SET _yoffset = (offsety+ sectionheight)
    ENDIF
    RETURN(sectionheight)
  END ;Subroutine
  SUBROUTINE footphysiciansection(ncalc)
    DECLARE a1 = f8 WITH noconstant(0.0), private
    SET a1 = footphysiciansectionabs(ncalc,_xoffset,_yoffset)
    RETURN(a1)
  END ;Subroutine
  SUBROUTINE footphysiciansectionabs(ncalc,offsetx,offsety)
    DECLARE sectionheight = f8 WITH noconstant(0.750000), private
    DECLARE __fieldname4 = vc WITH noconstant(build2(physician_summary->ps_detail[i].
      count_per_physician,char(0))), protect
    DECLARE __fieldname5 = vc WITH noconstant(build2(physician_summary->ps_detail[i].
      physician_extended_price,char(0))), protect
    DECLARE __fieldname6 = vc WITH noconstant(build2(physician_summary->ps_detail[i].physician_rvu,
      char(0))), protect
    DECLARE __fieldname7 = vc WITH noconstant(build2(concat("TOTAL for ",physician_summary->
       ps_detail[i].physician_name),char(0))), protect
    IF (ncalc=rpt_render)
     SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
     SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.625),(offsety+ 0.146),(offsetx+ 8.385),(offsety
      + 0.146))
     SET _rptstat = uar_rptline(_hreport,(offsetx+ 9.000),(offsety+ 0.146),(offsetx+ 9.760),(offsety
      + 0.146))
     SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.250),(offsety+ 0.146),(offsetx+ 7.010),(offsety
      + 0.146))
     SET rptsd->m_flags = 64
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_linespacing = rpt_single
     SET rptsd->m_rotationangle = 0
     SET rptsd->m_y = (offsety+ 0.313)
     SET rptsd->m_x = (offsetx+ 6.000)
     SET rptsd->m_width = 1.000
     SET rptsd->m_height = 0.260
     SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname4)
     SET rptsd->m_y = (offsety+ 0.313)
     SET rptsd->m_x = (offsetx+ 8.500)
     SET rptsd->m_width = 1.250
     SET rptsd->m_height = 0.271
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname5)
     SET rptsd->m_y = (offsety+ 0.313)
     SET rptsd->m_x = (offsetx+ 7.125)
     SET rptsd->m_width = 1.250
     SET rptsd->m_height = 0.260
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname6)
     SET rptsd->m_flags = 0
     SET rptsd->m_y = (offsety+ 0.313)
     SET rptsd->m_x = (offsetx+ 3.125)
     SET rptsd->m_width = 2.625
     SET rptsd->m_height = 0.323
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname7)
     SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
     SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
     SET _yoffset = (offsety+ sectionheight)
    ENDIF
    RETURN(sectionheight)
  END ;Subroutine
  SUBROUTINE footphysiciansummarysection(ncalc)
    DECLARE a1 = f8 WITH noconstant(0.0), private
    SET a1 = footphysiciansummarysectionabs(ncalc,_xoffset,_yoffset)
    RETURN(a1)
  END ;Subroutine
  SUBROUTINE footphysiciansummarysectionabs(ncalc,offsetx,offsety)
    DECLARE sectionheight = f8 WITH noconstant(0.750000), private
    DECLARE __fieldname4 = vc WITH noconstant(build2(physician_summary->ps_total_extended_price,char(
       0))), protect
    DECLARE __fieldname5 = vc WITH noconstant(build2(physician_summary->ps_total_rvu,char(0))),
    protect
    DECLARE __fieldname6 = vc WITH noconstant(build2(physician_summary->ps_total_cnt,char(0))),
    protect
    IF (ncalc=rpt_render)
     SET rptsd->m_flags = 0
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_linespacing = rpt_single
     SET rptsd->m_rotationangle = 0
     SET rptsd->m_y = (offsety+ 0.313)
     SET rptsd->m_x = (offsetx+ 3.125)
     SET rptsd->m_width = 2.438
     SET rptsd->m_height = 0.260
     SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
     SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(foot_phys_summary_text,char(0)))
     SET _rptstat = uar_rptline(_hreport,(offsetx+ 6.250),(offsety+ 0.130),(offsetx+ 7.010),(offsety
      + 0.130))
     SET _rptstat = uar_rptline(_hreport,(offsetx+ 7.625),(offsety+ 0.130),(offsetx+ 8.385),(offsety
      + 0.130))
     SET _rptstat = uar_rptline(_hreport,(offsetx+ 9.000),(offsety+ 0.130),(offsetx+ 9.760),(offsety
      + 0.130))
     SET rptsd->m_flags = 64
     SET rptsd->m_y = (offsety+ 0.313)
     SET rptsd->m_x = (offsetx+ 8.500)
     SET rptsd->m_width = 1.250
     SET rptsd->m_height = 0.260
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname4)
     SET rptsd->m_y = (offsety+ 0.313)
     SET rptsd->m_x = (offsetx+ 7.125)
     SET rptsd->m_width = 1.250
     SET rptsd->m_height = 0.260
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname5)
     SET rptsd->m_y = (offsety+ 0.313)
     SET rptsd->m_x = (offsetx+ 6.000)
     SET rptsd->m_width = 1.000
     SET rptsd->m_height = 0.260
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname6)
     SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
     SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
     SET _yoffset = (offsety+ sectionheight)
    ENDIF
    RETURN(sectionheight)
  END ;Subroutine
  SUBROUTINE footreportsection0(ncalc)
    DECLARE a1 = f8 WITH noconstant(0.0), private
    SET a1 = footreportsection0abs(ncalc,_xoffset,_yoffset)
    RETURN(a1)
  END ;Subroutine
  SUBROUTINE footreportsection0abs(ncalc,offsetx,offsety)
    DECLARE sectionheight = f8 WITH noconstant(1.000000), private
    IF (ncalc=rpt_render)
     SET rptsd->m_flags = 16
     SET rptsd->m_borders = rpt_sdnoborders
     SET rptsd->m_padding = rpt_sdnoborders
     SET rptsd->m_paddingwidth = 0.000
     SET rptsd->m_linespacing = rpt_single
     SET rptsd->m_rotationangle = 0
     SET rptsd->m_y = (offsety+ 0.500)
     SET rptsd->m_x = (offsetx+ 1.750)
     SET rptsd->m_width = 7.000
     SET rptsd->m_height = 0.198
     SET _oldfont = uar_rptsetfont(_hreport,_times8b0)
     SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("< < End of Report > >",char(0)))
     SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
     SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
     SET _yoffset = (offsety+ sectionheight)
    ENDIF
    RETURN(sectionheight)
  END ;Subroutine
  SUBROUTINE initializereport(dummy)
    SET rptreport->m_recsize = 100
    SET rptreport->m_reportname = "CCPS_CS_RVU_POSTED_CHARGES"
    SET rptreport->m_pagewidth = 8.50
    SET rptreport->m_pageheight = 11.00
    SET rptreport->m_orientation = rpt_landscape
    SET rptreport->m_marginleft = 0.25
    SET rptreport->m_marginright = 0.25
    SET rptreport->m_margintop = 0.25
    SET rptreport->m_marginbottom = 0.25
    SET rptreport->m_horzprintoffset = _xshift
    SET rptreport->m_vertprintoffset = _yshift
    SET _yoffset = rptreport->m_margintop
    SET _xoffset = rptreport->m_marginleft
    SET _hreport = uar_rptcreatereport(rptreport,_outputtype,rpt_inches)
    SET _rpterr = uar_rptseterrorlevel(_hreport,rpt_error)
    SET _rptstat = uar_rptstartreport(_hreport)
    SET _rptpage = uar_rptstartpage(_hreport)
    CALL _createfonts(0)
    CALL _createpens(0)
  END ;Subroutine
  SUBROUTINE _createfonts(dummy)
    SET rptfont->m_recsize = 50
    SET rptfont->m_fontname = rpt_times
    SET rptfont->m_pointsize = 10
    SET rptfont->m_bold = rpt_off
    SET rptfont->m_italic = rpt_off
    SET rptfont->m_underline = rpt_off
    SET rptfont->m_strikethrough = rpt_off
    SET rptfont->m_rgbcolor = rpt_black
    SET _times100 = uar_rptcreatefont(_hreport,rptfont)
    SET rptfont->m_pointsize = 12
    SET rptfont->m_bold = rpt_on
    SET _times12b0 = uar_rptcreatefont(_hreport,rptfont)
    SET rptfont->m_pointsize = 8
    SET rptfont->m_bold = rpt_off
    SET _times80 = uar_rptcreatefont(_hreport,rptfont)
    SET rptfont->m_pointsize = 10
    SET rptfont->m_bold = rpt_on
    SET _times10b0 = uar_rptcreatefont(_hreport,rptfont)
    SET rptfont->m_pointsize = 8
    SET _times8b0 = uar_rptcreatefont(_hreport,rptfont)
  END ;Subroutine
  SUBROUTINE _createpens(dummy)
    SET rptpen->m_recsize = 16
    SET rptpen->m_penwidth = 0.014
    SET rptpen->m_penstyle = 0
    SET rptpen->m_rgbcolor = rpt_black
    SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
  END ;Subroutine
  SET d0 = initializereport(0)
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    d0 = nodatasection0(rpt_render)
   WITH nocounter
  ;end select
  SET d0 = finalizereport( $OUTDEV)
 ENDIF
 SET last_mod = "10/24/12 MP9098 "
END GO
