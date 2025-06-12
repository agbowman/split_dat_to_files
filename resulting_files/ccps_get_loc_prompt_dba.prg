CREATE PROGRAM ccps_get_loc_prompt:dba
 PROMPT
  "Data Type" = "",
  "Filter Type" = "",
  "Filter Value" = 0,
  "Logical Domain ID" = 0
  WITH data_type, filter_type, filter_value,
  ld
 EXECUTE ccl_prompt_api_dataset "autoset"
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
 DECLARE loc_type_cd = f8 WITH noconstant(0.0), protect
 DECLARE loc_type2_cd = f8 WITH noconstant(0.0), protect
 DECLARE logical_domain_parser = vc WITH noconstant(" "), protect
 DECLARE value_parser = vc WITH noconstant(" "), protect
 DECLARE orgsec_parser = vc WITH noconstant(getprsnlorgexpand(reqinfo->updt_id,"l.organization_id")),
 protect
 DECLARE data_type_prompt = vc WITH constant(trim(cnvtupper( $DATA_TYPE),3)), protect
 DECLARE ld_prompt = f8 WITH constant(evaluate(textlen(trim(reflect(parameter(4,0)),3)),0,- (1.0),
   cnvtreal(parameter(4,0)))), protect
 DECLARE filter_type_prompt = vc WITH noconstant, protect
 IF (textlen(trim(reflect(parameter(2,0)),3))=0)
  SET filter_type_prompt = "ALL"
 ELSE
  SET filter_type_prompt = trim(cnvtupper(value(parameter(2,0))),3)
 ENDIF
 DECLARE cve_field_name = vc WITH noconstant(" "), protect
 DECLARE cve_field_value = vc WITH noconstant(" "), protect
 DECLARE last_mod = vc WITH noconstant(" "), protect
 DECLARE prompt_error(error_msg=vc) = i2
 IF ( NOT (islogicaldomainsactive(null)))
  SET logical_domain_parser = "1=1"
 ELSEIF (ld_prompt <= 0.0)
  IF (cur_logical_domain < 0.0)
   SET stat = prompt_error("Invalid user or logical domain")
  ELSE
   SET logical_domain_parser = build("o.logical_domain_id in (",cur_logical_domain,")")
  ENDIF
 ELSE
  CASE (isuserindomain(reqinfo->updt_id,ld_prompt))
   OF 0:
    SET stat = prompt_error("User not associated to provided domain")
   OF - (1):
    SET stat = prompt_error("Invalid personnel")
  ENDCASE
  SET logical_domain_parser = getpromptlist(4,"o.logical_domain_id",list_in)
 ENDIF
 IF (data_type_prompt IN ("FACILITY", "BUILDING", "NURSEUNIT", "AMBULATORY", "NUAMB",
 "FAC_NURSEUNIT", "FAC_AMBULATORY", "FAC_NUAMB", "ROOM", "BED"))
  IF (data_type_prompt IN ("NUAMB", "FAC_NUAMB"))
   SET loc_type_cd = uar_get_code_by("MEANING",222,"NURSEUNIT")
   SET loc_type2_cd = uar_get_code_by("MEANING",222,"AMBULATORY")
  ELSE
   SET loc_type_cd = uar_get_code_by("MEANING",222,trim(replace(data_type_prompt,"FAC_",""),3))
   SET loc_type2_cd = - (1.0)
  ENDIF
 ELSE
  SET stat = prompt_error("Invalid data type (parameter 1)")
 ENDIF
 IF ( NOT (filter_type_prompt IN ("ALL", "DISPLAYKEY", "PARENT_ENTITY", "CV_EXTENSION")))
  SET stat = prompt_error(build("Invalid filter type (parameter 2) ",filter_type_prompt))
 ENDIF
 IF (filter_type_prompt="ALL")
  SELECT INTO "nl:"
   id = l.location_cd, disp = trim(substring(1,100,uar_get_code_description(l.location_cd)),3)
   FROM location l,
    organization o
   PLAN (l
    WHERE l.location_type_cd IN (loc_type_cd, loc_type2_cd)
     AND parser(orgsec_parser)
     AND l.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND l.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     AND l.active_ind=1)
    JOIN (o
    WHERE o.organization_id=l.organization_id
     AND parser(logical_domain_parser)
     AND o.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND o.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     AND o.active_ind=1)
   ORDER BY disp, id
   HEAD REPORT
    stat = makedataset(10)
   HEAD id
    stat = writerecord(0)
   FOOT REPORT
    stat = closedataset(0)
   WITH reporthelp, check, expand = 1
  ;end select
  IF (curqual < 1)
   CALL prompt_error("No Results Found!")
  ENDIF
 ELSEIF (filter_type_prompt="DISPLAYKEY")
  SET value_parser = getpromptlist(3,"cv.display_key",list_in)
  SELECT INTO "nl:"
   id = l.location_cd, disp = trim(substring(1,100,uar_get_code_description(l.location_cd)),3)
   FROM code_value cv,
    location l,
    organization o
   PLAN (cv
    WHERE cv.code_set=220
     AND parser(value_parser)
     AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND cv.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     AND cv.active_ind=1)
    JOIN (l
    WHERE l.location_cd=cv.code_value
     AND l.location_type_cd IN (loc_type_cd, loc_type2_cd)
     AND parser(orgsec_parser)
     AND l.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND l.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     AND l.active_ind=1)
    JOIN (o
    WHERE o.organization_id=l.organization_id
     AND parser(logical_domain_parser)
     AND o.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND o.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     AND o.active_ind=1)
   ORDER BY disp, id
   HEAD REPORT
    stat = makedataset(10)
   HEAD id
    stat = writerecord(0)
   FOOT REPORT
    stat = closedataset(0)
   WITH reporthelp, check, expand = 1
  ;end select
  IF (curqual < 1)
   CALL prompt_error("No Results Found!")
  ENDIF
 ELSEIF (filter_type_prompt="PARENT_ENTITY")
  IF (data_type_prompt="FACILITY")
   SET value_parser = getpromptlist(3,"l.organization_id",list_in)
   SELECT INTO "nl:"
    id = l.location_cd, disp = trim(substring(1,100,uar_get_code_description(l.location_cd)),3)
    FROM location l
    PLAN (l
     WHERE parser(value_parser)
      AND parser(orgsec_parser)
      AND l.location_type_cd IN (loc_type_cd, loc_type2_cd)
      AND l.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND l.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND l.active_ind=1)
    ORDER BY disp, id
    HEAD REPORT
     stat = makedataset(10)
    HEAD id
     stat = writerecord(0)
    FOOT REPORT
     stat = closedataset(0)
    WITH reporthelp, check, expand = 1
   ;end select
   IF (curqual < 1)
    CALL prompt_error("No Results Found!")
   ENDIF
  ELSEIF (data_type_prompt IN ("FAC_NURSEUNIT", "FAC_AMBULATORY", "FAC_NUAMB"))
   SET value_parser = getpromptlist(3,"lg.parent_loc_cd",list_in)
   SELECT INTO "nl:"
    id = lg2.child_loc_cd, disp = trim(substring(1,100,uar_get_code_description(lg2.child_loc_cd)),3)
    FROM location_group lg,
     location_group lg2,
     location l
    PLAN (lg
     WHERE parser(value_parser)
      AND lg.root_loc_cd=0
      AND lg.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND lg.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND lg.active_ind=1)
     JOIN (lg2
     WHERE lg2.parent_loc_cd=lg.child_loc_cd
      AND lg2.root_loc_cd=0
      AND lg2.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND lg2.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND lg2.active_ind=1)
     JOIN (l
     WHERE l.location_cd=lg2.child_loc_cd
      AND l.location_type_cd IN (loc_type_cd, loc_type2_cd)
      AND parser(orgsec_parser)
      AND l.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND l.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND l.active_ind=1)
    ORDER BY disp, id
    HEAD REPORT
     stat = makedataset(10)
    HEAD id
     stat = writerecord(0)
    FOOT REPORT
     stat = closedataset(0)
    WITH reporthelp, check, expand = 1
   ;end select
   IF (curqual < 1)
    CALL prompt_error("No Results Found!")
   ENDIF
  ELSE
   SET value_parser = getpromptlist(3,"lg.parent_loc_cd",list_in)
   SELECT INTO "nl:"
    id = lg.child_loc_cd, disp = trim(substring(1,100,uar_get_code_description(lg.child_loc_cd)),3)
    FROM location_group lg,
     location l
    PLAN (lg
     WHERE parser(value_parser)
      AND lg.root_loc_cd=0
      AND lg.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND lg.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND lg.active_ind=1)
     JOIN (l
     WHERE l.location_cd=lg.child_loc_cd
      AND l.location_type_cd IN (loc_type_cd, loc_type2_cd)
      AND parser(orgsec_parser)
      AND l.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND l.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND l.active_ind=1)
    ORDER BY disp, id
    HEAD REPORT
     stat = makedataset(10)
    HEAD id
     stat = writerecord(0)
    FOOT REPORT
     stat = closedataset(0)
    WITH reporthelp, check, expand = 1
   ;end select
   IF (curqual < 1)
    CALL prompt_error("No Results Found!")
   ENDIF
  ENDIF
 ELSEIF (filter_type_prompt="CV_EXTENSION")
  SET value_parser = trim(cnvtupper(value(parameter(3,0))),3)
  SET cve_field_name = trim(piece(value_parser,":",1,"NOTFOUND",1),3)
  IF (cve_field_name="NOTFOUND")
   SET stat = prompt_error("Invalid code value extension name (parameter 3)")
  ENDIF
  SET cve_field_value = trim(piece(value_parser,":",2,"1",1),3)
  SELECT INTO "nl:"
   id = l.location_cd, disp = trim(substring(1,100,uar_get_code_description(l.location_cd)),3)
   FROM code_value_extension cve,
    location l,
    organization o
   PLAN (cve
    WHERE cve.code_set=220
     AND cve.field_name=cve_field_name
     AND cve.field_value=cve_field_value)
    JOIN (l
    WHERE l.location_cd=cve.code_value
     AND l.location_type_cd IN (loc_type_cd, loc_type2_cd)
     AND parser(orgsec_parser)
     AND l.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND l.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     AND l.active_ind=1)
    JOIN (o
    WHERE o.organization_id=l.organization_id
     AND parser(logical_domain_parser)
     AND o.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND o.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     AND o.active_ind=1)
   ORDER BY disp, id
   HEAD REPORT
    stat = makedataset(10)
   HEAD id
    stat = writerecord(0)
   FOOT REPORT
    stat = closedataset(0)
   WITH reporthelp, check, expand = 1
  ;end select
  IF (curqual < 1)
   CALL prompt_error("No Results Found!")
  ENDIF
 ENDIF
 SUBROUTINE prompt_error(message)
  SELECT INTO "nl:"
   id = 0.0, disp = message
   FROM (dummyt d  WITH seq = 1)
   PLAN (d)
   HEAD REPORT
    stat = makedataset(10)
   DETAIL
    stat = writerecord(0)
   FOOT REPORT
    stat = closedataset(0)
   WITH reporthelp, check
  ;end select
  GO TO exit_script
 END ;Subroutine
#exit_script
 SET last_mod = concat(
  "005 12/08/16 RC5091 Declared loc_type2_cd because the script would fail when the FAC_NURSEUNIT prompt",
  "was utilized (as setting this variable to -1.0 caused problems).")
END GO
