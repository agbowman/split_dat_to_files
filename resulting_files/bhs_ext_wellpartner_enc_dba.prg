CREATE PROGRAM bhs_ext_wellpartner_enc:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin Date" = "CURDATE",
  "End Date" = "CURDATE",
  "Facility" = 2992202595.00,
  "Run Mode" = "0"
  WITH outdev, s_beg_dt, s_end_dt,
  f_facility, s_res_type
 FREE RECORD encntrs
 RECORD encntrs(
   1 f_cnt = f8
   1 qual[*]
     2 f_encntr_id = f8
     2 s_sponsor_code = vc
     2 s_loc_code = vc
     2 s_encntr_dt = vc
     2 s_admit_dt = vc
     2 s_disch_dt = vc
     2 s_mrn = vc
     2 s_pat_name_last = vc
     2 s_pat_name_first = vc
     2 s_pat_dob = vc
     2 s_prim_pres_npi = vc
     2 s_prim_pres_name_last = vc
     2 s_prim_pres_name_first = vc
 )
 FREE RECORD frec
 RECORD frec(
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
   1 file_name = vc
   1 file_buf = vc
 )
 IF (validate(reply->status_data[1].status)=0)
  RECORD reply(
    1 status_data[1]
      2 status = c1
  )
 ENDIF
 SET reply->status_data[1].status = "F"
 DECLARE mf_cs320_npi = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!2160654021")), protect
 DECLARE mf_cs319_mrn = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE mf_cs333_attendingphysician = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!4024")),
 protect
 DECLARE mf_cs333_admittingphysician = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!4023")),
 protect
 DECLARE ml_ops_scheduler = i4 WITH protect, constant(4600)
 DECLARE ml_ops_monitor = i4 WITH protect, constant(4700)
 DECLARE ml_ops_server = i4 WITH protect, constant(4800)
 DECLARE ml_ops_ex_server = i4 WITH protect, constant(3202004)
 DECLARE md_beg_dt_tm = dq8 WITH protect, noconstant(cnvtdatetime(sysdate))
 DECLARE md_end_dt_tm = dq8 WITH protect, noconstant(cnvtdatetime(sysdate))
 DECLARE mn_is_ops_job = i2 WITH protect, noconstant(0)
 DECLARE ml_num = i4 WITH noconstant(0), protect
 DECLARE ml_cntr = i4 WITH noconstant(0), protect
 DECLARE ms_loc_dir = vc WITH protect, constant(build(logical("bhscust"),
   "/ftp/bhs_ext_wellpartner_enc"))
 DECLARE ms_file_name = vc WITH protect, noconstant(" ")
 DECLARE ms_line = vc WITH protect, noconstant(" ")
 DECLARE ms_log = vc WITH protect, noconstant(" ")
 DECLARE ms_run_date = vc WITH protect, noconstant(format(sysdate,"YYYYMMDD;;d"))
 DECLARE ms_fac_code = vc WITH protect, noconstant("")
 DECLARE ms_fac_parser = vc WITH protect, noconstant("e.loc_nurse_unit_cd in (")
 CALL echo(build("Lower : ",ms_file_name))
 SUBROUTINE (parsedateprompt(date_str=vc,default_date=vc,time=i4) =dq8)
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
 SUBROUTINE (_parsedate(date_str=vc) =i4)
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
 SUBROUTINE (_evaluatedatestr(date_str=vc) =i4)
   DECLARE _dq8 = dq8 WITH noconstant, private
   DECLARE _parse = vc WITH constant(concat("set _dq8 = cnvtdatetime(",date_str,", 0) go")), private
   CALL parser(_parse)
   RETURN(cnvtdate(_dq8))
 END ;Subroutine
 SUBROUTINE (masterdateparser(pdateunits=vc,prangemode=c1(value,"B"),ptimemode=c1(value,"B")) =dq8)
   DECLARE return_date_mp = dq8 WITH private, noconstant(0.0)
   IF (((cnvtdatetime(trim(pdateunits,3)) > 0.0) OR (cnvtdatetime(cnvtdate(cnvtint(trim(pdateunits,3)
      )),0) > 0.0)) )
    SET return_date_mp = parsedateprompt(trim(pdateunits),curdate,000000)
   ELSE
    CALL echo(build("Operator1: ",operator(pdateunits,"REGEXPLIKE",
       "^CUR(DATE|WEEK|MONTH|QUARTER|YEAR)(\s)*(-|\+)*(\s)*[0-9]*$")))
    CALL echo(build("Operator2: ",operator(pdateunits,"REGEXPLIKE",
       "^(D|W|M|Q|Y)(\s)*(-|\+)*(\s)*[0-9]*$")))
    IF (((operator(cnvtupper(trim(pdateunits,3)),"REGEXPLIKE",
     "^CUR(DATE|WEEK|MONTH|QUARTER|YEAR)(\s)*(-|\+)*(\s)*[0-9]*$")) OR (operator(cnvtupper(trim(
       pdateunits,3)),"REGEXPLIKE","^(D|W|M|Q|Y)(\s)*(-|\+)*(\s)*[0-9]*$"))) )
     CALL echo(build(" Inside RegEXP pdateunits: ",pdateunits))
     SET return_date_mp = parsedateoperations(trim(pdateunits,3),prangemode,ptimemode)
    ENDIF
   ENDIF
   RETURN(return_date_mp)
 END ;Subroutine
 SUBROUTINE (parsedateoperations(pdateunits=vc,prangemode=c1,ptimemode=c1) =dq8)
   DECLARE type = vc WITH private, noconstant("")
   DECLARE units = i2 WITH private, noconstant(0)
   DECLARE interval_type = c1 WITH private, noconstant("")
   DECLARE date_mode = c1 WITH private, noconstant("")
   DECLARE return_date = dq8 WITH private, noconstant(0.0)
   DECLARE search_exp = c1 WITH private, noconstant("")
   IF (findstring("-",pdateunits,1))
    SET search_exp = "-"
   ELSEIF (findstring("+",pdateunits,1))
    SET search_exp = "+"
   ENDIF
   SET type = cnvtupper(trim(piece(pdateunits,search_exp,1,"CURDATE"),3))
   SET units = cnvtint(piece(pdateunits,search_exp,2,"0"))
   CASE (type)
    OF "CURDATE":
     SET interval_type = "D"
     SET date_mode = "D"
    OF "CURWEEK":
     SET interval_type = "W"
     SET date_mode = "W"
    OF "CURMONTH":
     SET interval_type = "M"
     SET date_mode = "M"
    OF "CURQUARTER":
     SET interval_type = "M"
     SET date_mode = "Q"
     SET units *= 3
    OF "CURYEAR":
     SET interval_type = "Y"
     SET date_mode = "Y"
    OF "D":
     SET interval_type = "D"
     SET date_mode = "D"
    OF "W":
     SET interval_type = "W"
     SET date_mode = "W"
    OF "M":
     SET interval_type = "M"
     SET date_mode = "M"
    OF "Q":
     SET interval_type = "M"
     SET date_mode = "Q"
     SET units *= 3
    OF "Y":
     SET interval_type = "Y"
     SET date_mode = "Y"
    ELSE
     SET interval_type = "D"
     SET date_mode = "D"
   ENDCASE
   IF (search_exp="-")
    SET return_date = cnvtlookbehind(build(units,",",interval_type),cnvtdatetime(sysdate))
   ELSE
    SET return_date = cnvtlookahead(build(units,",",interval_type),cnvtdatetime(sysdate))
   ENDIF
   SET return_date = datetimefind(cnvtdatetime(return_date),date_mode,prangemode,ptimemode)
   IF (cnvtdatetime(return_date)=0.0)
    SET return_date = cnvtdatetime(sysdate)
   ENDIF
   RETURN(return_date)
 END ;Subroutine
 DECLARE getreply(null) = vc
 DECLARE geterrorcount(null) = i4
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
    AND dm.info_date >= cnvtdatetime(sysdate))
  ORDER BY dm.info_name
  HEAD dm.info_name
   entity_cnt = 0, component_cnt = 0, entity = trim(piece(dm.info_char,",",(entity_cnt+ 1),
     "Not Found"),3),
   component = fillstring(4000," ")
   WHILE (component != "Not Found")
     component_cnt += 1
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
 SUBROUTINE (logmsg(mymsg=vc,msglvl=i2(value,2)) =null)
   DECLARE seek_retval = i4 WITH protect, noconstant(0)
   DECLARE filelen = i4 WITH protect, noconstant(0)
   DECLARE write_stat = i2 WITH protect, noconstant(0)
   DECLARE imsglvl = i2 WITH protect, noconstant(0)
   DECLARE smsglvl = vc WITH protect, noconstant("")
   DECLARE slogtext = vc WITH protect, noconstant("")
   DECLARE start_char = i4 WITH protect, noconstant(0)
   SET imsglvl = msglvl
   SET slogtext = mymsg
   IF ((((debug_values->suppress_msg=false)) OR ((debug_values->suppress_msg=true)
    AND msglvl=ccps_log_error)) )
    IF (((imsglvl=ccps_log_error) OR ((debug_values->logging_on=true))) )
     SET ccps_log->cnt += 1
     IF (msglvl=ccps_log_error)
      SET ccps_log->ecnt += 1
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
      SET ccps_log_frec->file_buf = build2(format(cnvtdatetime(sysdate),"mm/dd/yyyy hh:mm:ss;;d"),
       fillstring(5," "),"{",smsglvl,"}",
       fillstring(5," "),mymsg,char(13),char(10))
      SET write_stat = cclio("WRITE",ccps_log_frec)
      SET stat = cclio("CLOSE",ccps_log_frec)
     ELSEIF ((debug_values->debug_method=ccps_listing_ind))
      CALL echo(build2("*** ",format(cnvtdatetime(sysdate),"mm/dd/yyyy hh:mm:ss;;d"),fillstring(5," "
         ),"{",smsglvl,
        "}",fillstring(5," "),mymsg))
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (logrecord(myrecstruct=vc(ref)) =null)
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
      SET ccps_log_frec->file_buf = build2(format(cnvtdatetime(sysdate),"mm/dd/yyyy hh:mm:ss;;d"),
       fillstring(5," "),"{",smsgtype,"}",
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
      CALL echo(build2("*** ",format(cnvtdatetime(sysdate),"mm/dd/yyyy hh:mm:ss;;d"),fillstring(5," "
         ),"{",smsgtype,
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
 SUBROUTINE (catcherrors(mymsg=vc) =i2)
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
 SUBROUTINE (finalizemsgs(outdest=vc(value,""),recsizezflag=i4(value,1)) =null)
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
 SUBROUTINE (setreply(mystat=vc) =null)
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
 SUBROUTINE (getcodewithcheck(type=vc,code_set=i4(value,0),expression=vc(value,""),msglvl=i2(value,2)
  ) =f8)
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
 SUBROUTINE (populatesubeventstatus(errorcnt=i4(value),operationname=vc(value),operationstatus=vc(
   value),targetobjectname=vc(value),targetobjectvalue=vc(value)) =i2)
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
     SET ccps_isubeventsize += size(trim(reply->status_data.subeventstatus[ccps_isubeventcnt].
       operationstatus))
     SET ccps_isubeventsize += size(trim(reply->status_data.subeventstatus[ccps_isubeventcnt].
       targetobjectname))
     SET ccps_isubeventsize += size(trim(reply->status_data.subeventstatus[ccps_isubeventcnt].
       targetobjectvalue))
    ENDIF
    IF (ccps_isubeventsize > 0)
     SET ccps_isubeventcnt += 1
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
 SUBROUTINE (writemlgmsg(msg=vc,lvl=i2) =null)
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
 SUBROUTINE (ispromptany(which_prompt=i2) =i2)
   DECLARE prompt_reflect = vc WITH private, noconstant(reflect(parameter(which_prompt,0)))
   DECLARE return_val = i2 WITH private, noconstant(0)
   IF (prompt_reflect="C1")
    IF (ichar(value(parameter(which_prompt,1)))=42)
     SET return_val = 1
    ENDIF
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 SUBROUTINE (ispromptlist(which_prompt=i2) =i2)
   DECLARE prompt_reflect = vc WITH private, noconstant(reflect(parameter(which_prompt,0)))
   DECLARE return_val = i2 WITH private, noconstant(0)
   IF (substring(1,1,prompt_reflect)="L")
    SET return_val = 1
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 SUBROUTINE (ispromptsingle(which_prompt=i2) =i2)
   DECLARE prompt_reflect = vc WITH private, noconstant(reflect(parameter(which_prompt,0)))
   DECLARE return_val = i2 WITH private, noconstant(0)
   IF (textlen(trim(prompt_reflect,3)) > 0
    AND  NOT (ispromptany(which_prompt))
    AND  NOT (ispromptlist(which_prompt)))
    SET return_val = 1
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 SUBROUTINE (ispromptempty(which_prompt=i2) =i2)
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
 SUBROUTINE (getpromptlist(which_prompt=i2,which_column=vc,which_option=i2(value,list_in)) =vc)
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
 SUBROUTINE (getpromptexpand(which_prompt=i2,which_column=vc,which_option=i2(value,list_in)) =vc)
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
 SUBROUTINE (getpromptrecord(which_prompt=i2,which_rec=vc) =vc)
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
       SET idx += 1
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
 SUBROUTINE (createrecord(which_rec=vc(value,"")) =vc)
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
     SET ccps_records->cnt += 1
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
 SUBROUTINE (createexpandparser(which_column=vc,which_rec=vc,which_option=i2(value,list_in)) =vc)
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
 DECLARE f_card_rehabwellb_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"Card RehabWellB"))
 DECLARE f_bmc_diab_teach_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"BMC Diab Teach"))
 DECLARE f_bmc_ekg_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"BMC EKG"))
 DECLARE f_bmc_lactation_svc_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"BMC Lactation Svc")
  )
 DECLARE f_bmc_noninv_card_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"BMC NonInv Card"))
 DECLARE f_bmc_csc_preadmit_ts_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,
   "BMC CSC Preadmit Ts"))
 DECLARE f_bmc_pulm_lab_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"BMC Pulm Lab"))
 DECLARE f_bmc_pulm_rehab_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"BMC Pulm Rehab"))
 DECLARE f_spfld_psychcon_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld PsychCon"))
 DECLARE f_bmc_wps_mat_fet_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"BMC WPS Mat-Fet"))
 DECLARE f_spfld_bh_np_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld BH NP"))
 DECLARE f_transplant_pre_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Transplant Pre"))
 DECLARE f_transplant_post_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Transplant Post"))
 DECLARE f_spfld_gen_peds_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Gen Peds"))
 DECLARE f_spfld_pedipulm_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld PediPulm"))
 DECLARE f_spfld_pedneuro_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld PedNeuro"))
 DECLARE f_spfld_ped_id_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Ped ID"))
 DECLARE f_spfld_trav_med_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Trav Med"))
 DECLARE f_spfld_hshc_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld HSHC"))
 DECLARE f_spfld_wwc_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld WWC"))
 DECLARE f_spfld_brhc_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld BRHC"))
 DECLARE f_spfld_pain_ctr_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Pain Ctr"))
 DECLARE f_bmc_wound_care_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*BMC Wound Care"))
 DECLARE f_spfld_msq_tb_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld MSQ TB"))
 DECLARE f_spfld_msq_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld MSQ"))
 DECLARE f_spfld_pre_op_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Pre Op"))
 DECLARE f_spfld_bh_aop_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld BH AOP"))
 DECLARE f_bmc_s1_5_med_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"BMC S1-5 Med"))
 DECLARE f_bmc_neurosleep_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"BMC NeuroSleep"))
 DECLARE f_spfld_pedisurg_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld PediSurg"))
 DECLARE f_spfld_con_care_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Con Care"))
 DECLARE f_spfld_dev_peds_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Dev Peds"))
 DECLARE f_spfld_adol_med_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Adol Med"))
 DECLARE f_spfld_ped_nutrn_cd = f8 WITH constant(566067849)
 DECLARE f_spfld_pcard_tst_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"Spfld PCard Tst"))
 DECLARE f_spfld_3400_ibh_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld 3400 IBH"))
 DECLARE f_bmc_medical_stay_d3b_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,
   "BMC Medical Stay D3B"))
 DECLARE f_spfld_3300_ibh_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld 3300 IBH"))
 DECLARE f_spfld_pdnrotst_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld PdNroTst"))
 DECLARE f_bmc_wwg_759_ivf_cd = f8 WITH constant(573532032)
 DECLARE f_spfld_np3300_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld NP3300"))
 DECLARE f_spfld_op_psych_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld OP Psych"))
 DECLARE f_bmc_cont_care_nursery_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,
   "BMC Cont Care Nursery"))
 DECLARE f_ws_ibh_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*WS IBH"))
 DECLARE f_plmr_rheum_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Plmr Rheum"))
 DECLARE f_plmr_podiatry_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Plmr Podiatry"))
 DECLARE f_plmr_nephrolgy_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Plmr Nephrolgy"))
 DECLARE f_spfld_psynthrpy_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld PsyNthrpy"))
 DECLARE f_bmc_medstay_ppu_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"BMC MedStay PPU"))
 DECLARE f_spfld_geri_hc_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Geri HC"))
 DECLARE f_bmc_med_stay_mob_inf_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,
   "BMC Med Stay MOB Inf"))
 DECLARE f_spfld_brhc_gan_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld BRHC Gan"))
 DECLARE f_spfld_bh_wh_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld BH WH"))
 DECLARE f_spfld_pallitve_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Pallitve"))
 DECLARE f_trns_dnr_pst_srg_b_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,
   "*Trns Dnr Pst Srg B"))
 DECLARE f_spfld_coum_cln_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Coum Cln"))
 DECLARE f_vaccine_unit_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"Vaccine Unit"))
 DECLARE f_spfld_trach_cl_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Trach Cl"))
 DECLARE f_spfld_msq_midw_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld MSQ MidW"))
 DECLARE f_spfld_brhc_mid_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld BRHC Mid"))
 DECLARE f_spfld_ped_hemonc_cd = f8 WITH constant(1236719827)
 DECLARE f_spfld_nroenvas_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld NroEnVas"))
 DECLARE f_spfld_brhc_wh_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld BRHC WH"))
 DECLARE f_spfld_brhc_home_cd = f8 WITH constant(1369743813)
 DECLARE f_spfld_brst_spc_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Brst Spc"))
 DECLARE f_spfld_card_srg_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Card Srg"))
 DECLARE f_spfld_card_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Card"))
 DECLARE f_spfld_vad_clin_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld VAD Clin"))
 DECLARE f_spfld_device_c_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Device C"))
 DECLARE f_spfld_hrt_fail_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Hrt Fail"))
 DECLARE f_spfld_cbh_main_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld CBH Main"))
 DECLARE f_spfld_mcpap_4_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld MCPAP 4"))
 DECLARE f_spfld_cbh_wasn_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld CBH Wasn"))
 DECLARE f_spfld_mcpap_c_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld MCPAP C"))
 DECLARE f_spfld_endo_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Endo"))
 DECLARE f_spfld_fam_adv_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Fam Adv"))
 DECLARE f_spfld_gastro_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Gastro"))
 DECLARE f_spfld_gen_surg_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Gen Surg"))
 DECLARE f_spfld_gen_chst_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Gen Chst"))
 DECLARE f_spfld_gen_main_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Gen Main"))
 DECLARE f_spfld_gen_wasn_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Gen Wasn"))
 DECLARE f_spfld_gyn_onc_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld GYN Onc"))
 DECLARE f_spfld_id_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld ID"))
 DECLARE f_spfld_mid_wh_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Mid WH"))
 DECLARE f_spfld_neurolgy_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Neurolgy"))
 DECLARE f_spfld_neursrgm_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld NeurSrgM"))
 DECLARE f_spfld_ped_card_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Ped Card"))
 DECLARE f_spfld_ped_endo_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Ped Endo"))
 DECLARE f_spfld_pedi_gi_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Pedi GI"))
 DECLARE f_spfld_pmr_birn_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld PMR Birn"))
 DECLARE f_spfld_plst_srg_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Plst Srg"))
 DECLARE f_spfld_plstsg_w_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld PlstSg W"))
 DECLARE f_spfld_psyadm_c_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld PsyAdm C"))
 DECLARE f_long_pulm_cd = f8 WITH constant(1370024895)
 DECLARE f_spfld_pulm_mn_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Pulm Mn"))
 DECLARE f_spfld_pulm_was_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Pulm Was"))
 DECLARE f_spfld_sleep_ch_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Sleep Ch"))
 DECLARE f_spfld_neurdiag_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Neurdiag"))
 DECLARE f_spfld_thor_srg_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Thor Srg"))
 DECLARE f_spfld_traumasg_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld TraumaSg"))
 DECLARE f_spfld_urogyn_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld UroGyn"))
 DECLARE f_spfld_vas_svc_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Vas Svc"))
 DECLARE f_spfld_vas_lab_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld Vas Lab"))
 DECLARE f_spfld_wh_main_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld WH Main"))
 DECLARE f_spfld_bh_a_3400_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"Spfld BH A 3400"))
 DECLARE f_spfld_matfet_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld MatFet"))
 DECLARE f_spfld_hshccard_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld HSHCCard"))
 DECLARE f_spfld_hshcneur_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld HSHCNeur"))
 DECLARE f_spfld_hshc_pm_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld HSHC PM"))
 DECLARE f_spfld_hshc_rnl_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld HSHC Rnl"))
 DECLARE f_spfld_hshc_id_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld HSHC ID"))
 DECLARE f_spfld_ambpt_tst_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"Spfld AmbPt Tst"))
 DECLARE f_spfld_mcpap_3_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld MCPAP 3"))
 DECLARE f_spfldnicard3300_cd = f8 WITH constant(1371210367)
 DECLARE f_plmr_vas_lab_cd = f8 WITH constant(1372859467)
 DECLARE f_spfld_clintrl_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld ClinTrl"))
 DECLARE f_spfld_brhc_ibh_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld BRHC IBH"))
 DECLARE f_spfld_genpedibh_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld GenPedIBH"))
 DECLARE f_spfld_msq_ibh_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld MSQ IBH"))
 DECLARE f_spfld_hshc_ibh_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Spfld HSHC IBH"))
 DECLARE f_bmc_inf_plmr_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"BMC Inf Plmr"))
 DECLARE f_bmc_inf_wf_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"BMC Inf WF"))
 DECLARE f_bfmc_echo_card_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"BFMC Echo Card"))
 DECLARE f_bfmc_ekg_ecg_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"BFMC EKG/ECG"))
 DECLARE f_bfmc_nuc_med_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"BFMC Nuc Med"))
 DECLARE f_bfmc_nutri_svcs_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"BFMC Nutri Svcs"))
 DECLARE f_bfmc_pulm_funct_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"BFMC Pulm Funct"))
 DECLARE f_bfmc_sleep_stud_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"BFMC Sleep Stud"))
 DECLARE f_bfmc_card_stres_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"BFMC Card Stres"))
 DECLARE f_neurology_f_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"Neurology F"))
 DECLARE f_gnfld_fam_med_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Gnfld Fam Med"))
 DECLARE f_gnfld_gastro_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Gnfld Gastro"))
 DECLARE f_gnfld_pulm_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Gnfld Pulm"))
 DECLARE f_bfmc_vasc_lab_cd = f8 WITH constant(458576333)
 DECLARE f_grnfld_rehabpt_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Grnfld RehabPT"))
 DECLARE f_grnfld_ibh_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Grnfld IBH"))
 DECLARE f_gnfld_wound_cr_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Gnfld Wound Cr"))
 DECLARE f_gnfld_rehab_ot_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"Gnfld Rehab OT"))
 DECLARE f_gnfld_rehab_aud_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"Gnfld Rehab Aud"))
 DECLARE f_gnfld_rehab_st_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"Gnfld Rehab ST"))
 DECLARE f_gnfld_hrt_vasc_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Gnfld Hrt Vasc"))
 DECLARE f_plmr_bhtherapy_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Plmr BHTherapy"))
 DECLARE f_plmr_bhpsych_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Plmr BHPsych"))
 DECLARE f_fmc_bridge_prg_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*FMC Bridge Prg"))
 DECLARE f_gnfld_vac_ctr_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"Gnfld Vac Ctr"))
 DECLARE f_bfmc_bayinf_gfd_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"BFMC BayInf Gfd"))
 DECLARE f_gnfld_midobgyn_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Gnfld MidOBGYN"))
 DECLARE f_gnfld_brst_spc_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Gnfld Brst Spc"))
 DECLARE f_gnfld_gen_surg_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Gnfld Gen Surg"))
 DECLARE f_gnfld_id_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Gnfld ID"))
 DECLARE f_gnfld_neurolgy_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Gnfld Neurolgy"))
 DECLARE f_gnfld_plst_srg_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Gnfld Plst Srg"))
 DECLARE f_gnfld_sleep_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Gnfld Sleep"))
 DECLARE f_gnfld_urogyn_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Gnfld UroGyn"))
 DECLARE f_gnfld_urology_cd = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Gnfld Urology"))
 IF (validate(reqinfo->updt_app,- (1)) IN (ml_ops_scheduler, ml_ops_monitor, ml_ops_server,
 ml_ops_ex_server))
  SET mn_is_ops_job = 1
 ENDIF
 IF (( $S_RES_TYPE="0"))
  IF (((textlen(trim( $S_BEG_DT,3))=0) OR (textlen(trim( $S_END_DT,3))=0)) )
   SET ms_log = "Both dates must be filled out"
   GO TO exit_script
  ENDIF
 ENDIF
 IF (mn_is_ops_job=1)
  SET md_beg_dt_tm = datetimefind(cnvtlookbehind("1,D"),"D","B","B")
  SET md_end_dt_tm = datetimefind(cnvtlookbehind("1,D"),"D","E","E")
 ELSE
  IF (cnvtdatetime( $S_BEG_DT) > cnvtdatetime( $S_END_DT))
   SET ms_log = "End date must be greater than Beg date"
   GO TO exit_script
  ENDIF
  SET md_beg_dt_tm = parsedateprompt( $S_BEG_DT,curdate,000000)
  SET md_end_dt_tm = parsedateprompt( $S_END_DT,curdate,235959)
 ENDIF
 CALL echo(build2("beg dt: ",md_beg_dt_tm," end dt: ",md_end_dt_tm))
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=220
   AND cv.cdf_meaning="FACILITY"
   AND cv.active_ind=1
   AND cv.display_key IN ("BNH", "BMC", "BFMC")
   AND (cv.code_value= $F_FACILITY)
  ORDER BY cv.display DESC
  HEAD cv.display
   IF (cv.display="BNH")
    ms_fac_code = "BNH", ms_fac_parser = concat(ms_fac_parser,trim(build2( $F_FACILITY),3))
   ELSEIF (cv.display="BFMC")
    ms_fac_code = "BFMC", ms_fac_parser = concat(ms_fac_parser,trim(build2( $F_FACILITY),3))
   ELSEIF (cv.display="BMC")
    ms_fac_code = "BAYMC", ms_fac_parser = concat(ms_fac_parser,trim(build2( $F_FACILITY),3))
   ENDIF
  WITH nocounter
 ;end select
 IF (ms_fac_code="BAYMC")
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE cv.code_set=220
    AND cv.active_ind=1
    AND cv.cdf_meaning="AMBULATORY"
    AND cv.code_value IN (f_card_rehabwellb_cd, f_bmc_diab_teach_cd, f_bmc_ekg_cd,
   f_bmc_lactation_svc_cd, f_bmc_noninv_card_cd,
   f_bmc_csc_preadmit_ts_cd, f_bmc_pulm_lab_cd, f_bmc_pulm_rehab_cd, f_spfld_psychcon_cd,
   f_bmc_wps_mat_fet_cd,
   f_spfld_bh_np_cd, f_transplant_pre_cd, f_transplant_post_cd, f_spfld_gen_peds_cd,
   f_spfld_pedipulm_cd,
   f_spfld_pedneuro_cd, f_spfld_ped_id_cd, f_spfld_trav_med_cd, f_spfld_hshc_cd, f_spfld_wwc_cd,
   f_spfld_brhc_cd, f_spfld_pain_ctr_cd, f_bmc_wound_care_cd, f_spfld_msq_tb_cd, f_spfld_msq_cd,
   f_spfld_pre_op_cd, f_spfld_bh_aop_cd, f_bmc_s1_5_med_cd, f_bmc_neurosleep_cd, f_spfld_pedisurg_cd,
   f_spfld_con_care_cd, f_spfld_dev_peds_cd, f_spfld_adol_med_cd, f_spfld_ped_nutrn_cd,
   f_spfld_pcard_tst_cd,
   f_spfld_3400_ibh_cd, f_bmc_medical_stay_d3b_cd, f_spfld_3300_ibh_cd, f_spfld_pdnrotst_cd,
   f_bmc_wwg_759_ivf_cd,
   f_spfld_np3300_cd, f_spfld_op_psych_cd, f_bmc_cont_care_nursery_cd, f_ws_ibh_cd, f_plmr_rheum_cd,
   f_plmr_podiatry_cd, f_plmr_nephrolgy_cd, f_spfld_psynthrpy_cd, f_bmc_medstay_ppu_cd,
   f_spfld_geri_hc_cd,
   f_bmc_med_stay_mob_inf_cd, f_spfld_brhc_gan_cd, f_spfld_bh_wh_cd, f_spfld_pallitve_cd,
   f_trns_dnr_pst_srg_b_cd,
   f_spfld_coum_cln_cd, f_vaccine_unit_cd, f_spfld_trach_cl_cd, f_spfld_msq_midw_cd,
   f_spfld_brhc_mid_cd,
   f_spfld_ped_hemonc_cd, f_spfld_nroenvas_cd, f_spfld_brhc_wh_cd, f_spfld_brhc_home_cd,
   f_spfld_brst_spc_cd,
   f_spfld_card_srg_cd, f_spfld_card_cd, f_spfld_vad_clin_cd, f_spfld_device_c_cd,
   f_spfld_hrt_fail_cd,
   f_spfld_cbh_main_cd, f_spfld_mcpap_4_cd, f_spfld_cbh_wasn_cd, f_spfld_mcpap_c_cd, f_spfld_endo_cd,
   f_spfld_fam_adv_cd, f_spfld_gastro_cd, f_spfld_gen_surg_cd, f_spfld_gen_chst_cd,
   f_spfld_gen_main_cd,
   f_spfld_gen_wasn_cd, f_spfld_gyn_onc_cd, f_spfld_id_cd, f_spfld_mid_wh_cd, f_spfld_neurolgy_cd,
   f_spfld_neursrgm_cd, f_spfld_ped_card_cd, f_spfld_ped_endo_cd, f_spfld_pedi_gi_cd,
   f_spfld_pmr_birn_cd,
   f_spfld_plst_srg_cd, f_spfld_plstsg_w_cd, f_spfld_psyadm_c_cd, f_long_pulm_cd, f_spfld_pulm_mn_cd,
   f_spfld_pulm_was_cd, f_spfld_sleep_ch_cd, f_spfld_neurdiag_cd, f_spfld_thor_srg_cd,
   f_spfld_traumasg_cd,
   f_spfld_urogyn_cd, f_spfld_vas_svc_cd, f_spfld_vas_lab_cd, f_spfld_wh_main_cd,
   f_spfld_bh_a_3400_cd,
   f_spfld_matfet_cd, f_spfld_hshccard_cd, f_spfld_hshcneur_cd, f_spfld_hshc_pm_cd,
   f_spfld_hshc_rnl_cd,
   f_spfld_hshc_id_cd, f_spfld_ambpt_tst_cd, f_spfld_mcpap_3_cd, f_spfldnicard3300_cd,
   f_plmr_vas_lab_cd,
   f_spfld_clintrl_cd, f_spfld_brhc_ibh_cd, f_spfld_genpedibh_cd, f_spfld_msq_ibh_cd,
   f_spfld_hshc_ibh_cd,
   f_bmc_inf_plmr_cd, f_bmc_inf_wf_cd)
   ORDER BY cv.code_value
   HEAD cv.code_value
    ms_fac_parser = trim(build2(ms_fac_parser,",",cv.code_value),3)
   WITH nocounter
  ;end select
 ENDIF
 IF (ms_fac_code="BFMC")
  SELECT INTO "nl:"
   FROM code_value cv
   PLAN (cv
    WHERE cv.code_set=220
     AND cv.active_ind=1
     AND cv.cdf_meaning="AMBULATORY"
     AND cv.code_value IN (f_bfmc_echo_card_cd, f_bfmc_ekg_ecg_cd, f_bfmc_nuc_med_cd,
    f_bfmc_nutri_svcs_cd, f_bfmc_pulm_funct_cd,
    f_bfmc_sleep_stud_cd, f_bfmc_card_stres_cd, f_neurology_f_cd, f_gnfld_fam_med_cd,
    f_gnfld_gastro_cd,
    f_gnfld_pulm_cd, f_bfmc_vasc_lab_cd, f_grnfld_rehabpt_cd, f_grnfld_ibh_cd, f_gnfld_wound_cr_cd,
    f_gnfld_rehab_ot_cd, f_gnfld_rehab_aud_cd, f_gnfld_rehab_st_cd, f_gnfld_hrt_vasc_cd,
    f_plmr_bhtherapy_cd,
    f_plmr_bhpsych_cd, f_fmc_bridge_prg_cd, f_gnfld_vac_ctr_cd, f_bfmc_bayinf_gfd_cd,
    f_gnfld_midobgyn_cd,
    f_gnfld_brst_spc_cd, f_gnfld_gen_surg_cd, f_gnfld_id_cd, f_gnfld_neurolgy_cd, f_gnfld_plst_srg_cd,
    f_gnfld_sleep_cd, f_gnfld_urogyn_cd, f_gnfld_urology_cd))
   ORDER BY cv.code_value
   HEAD cv.code_value
    ms_fac_parser = trim(build2(ms_fac_parser,",",cv.code_value),3)
   WITH nocounter
  ;end select
 ENDIF
 SET ms_fac_parser = concat(ms_fac_parser,")")
 SET ms_file_name = trim(cnvtlower(build2("enctr_",trim(ms_fac_code,3),"_cerner",ms_run_date,".pipe")
   ),3)
 SELECT INTO "nl:"
  FROM encounter e,
   person p,
   encntr_alias ea
  PLAN (e
   WHERE e.disch_dt_tm BETWEEN cnvtdatetime(md_beg_dt_tm) AND cnvtdatetime(md_end_dt_tm)
    AND (((e.loc_facility_cd= $F_FACILITY)) OR (parser(ms_fac_parser)))
    AND e.beg_effective_dt_tm <= sysdate
    AND e.end_effective_dt_tm > sysdate
    AND e.active_ind=1)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.beg_effective_dt_tm <= sysdate
    AND p.end_effective_dt_tm > sysdate
    AND p.active_ind=1)
   JOIN (ea
   WHERE (ea.encntr_id= Outerjoin(e.encntr_id))
    AND (ea.encntr_alias_type_cd= Outerjoin(mf_cs319_mrn))
    AND (ea.beg_effective_dt_tm<= Outerjoin(sysdate))
    AND (ea.end_effective_dt_tm> Outerjoin(sysdate))
    AND ea.active_ind=1)
  ORDER BY e.encntr_id
  HEAD REPORT
   pl_cnt = 0
  HEAD e.encntr_id
   pl_cnt += 1
   IF (pl_cnt > size(encntrs->qual,5))
    CALL alterlist(encntrs->qual,(pl_cnt+ 100))
   ENDIF
   encntrs->qual[pl_cnt].f_encntr_id = e.encntr_id, encntrs->qual[pl_cnt].s_sponsor_code = trim(
    ms_fac_code,3), encntrs->qual[pl_cnt].s_loc_code = trim(uar_get_code_display(e.loc_nurse_unit_cd),
    3),
   encntrs->qual[pl_cnt].s_encntr_dt = trim(format(e.reg_dt_tm,"YYYYMMDD"),3), encntrs->qual[pl_cnt].
   s_admit_dt = trim(format(e.inpatient_admit_dt_tm,"YYYYMMDD"),3), encntrs->qual[pl_cnt].s_disch_dt
    = trim(format(e.disch_dt_tm,"YYYYMMDD"),3),
   encntrs->qual[pl_cnt].s_mrn = trim(ea.alias,3), encntrs->qual[pl_cnt].s_pat_name_last = trim(p
    .name_first,3), encntrs->qual[pl_cnt].s_pat_name_first = trim(p.name_last,3),
   encntrs->qual[pl_cnt].s_pat_dob = trim(format(cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p
       .birth_tz),1),"YYYYMMDD"),3)
  FOOT REPORT
   encntrs->f_cnt = pl_cnt,
   CALL alterlist(encntrs->qual,pl_cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM encntr_prsnl_reltn eprh,
   prsnl pr,
   prsnl_alias pra
  PLAN (eprh
   WHERE expand(ml_num,1,size(encntrs->qual,5),eprh.encntr_id,encntrs->qual[ml_num].f_encntr_id)
    AND eprh.encntr_prsnl_r_cd=mf_cs333_attendingphysician
    AND eprh.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
    AND eprh.end_effective_dt_tm > cnvtdatetime(curdate,curtime)
    AND eprh.active_ind=1)
   JOIN (pr
   WHERE pr.person_id=eprh.prsnl_person_id
    AND pr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
    AND pr.end_effective_dt_tm > cnvtdatetime(curdate,curtime)
    AND pr.active_ind=1)
   JOIN (pra
   WHERE (pra.person_id= Outerjoin(pr.person_id))
    AND (pra.prsnl_alias_type_cd= Outerjoin(mf_cs320_npi))
    AND (pra.beg_effective_dt_tm<= Outerjoin(sysdate))
    AND (pra.end_effective_dt_tm> Outerjoin(sysdate))
    AND (pra.active_ind= Outerjoin(1)) )
  ORDER BY eprh.encntr_id, pra.person_id
  HEAD eprh.encntr_id
   pl_pos = locateval(ml_num,1,size(encntrs->qual,5),eprh.encntr_id,encntrs->qual[ml_num].f_encntr_id
    ), encntrs->qual[pl_pos].s_prim_pres_npi = trim(pra.alias,3), encntrs->qual[pl_pos].
   s_prim_pres_name_first = trim(pr.name_first,3),
   encntrs->qual[pl_pos].s_prim_pres_name_last = trim(pr.name_last,3)
  WITH nocounter, expand = 2
 ;end select
 IF (size(encntrs->qual,5)=0)
  SET ms_log = "No records found"
  CALL echo(size(encntrs->qual,5))
  CALL echo("testing")
  GO TO exit_script
 ENDIF
 CALL echo(concat(ms_loc_dir,ms_file_name))
 IF (( $S_RES_TYPE="1"))
  IF (size(encntrs->qual,5) > 0)
   CALL echo(build2("ms_file_name: ",ms_file_name))
   SET frec->file_buf = "w"
   SET frec->file_name = build2(ms_loc_dir,"/",ms_file_name)
   SET stat = cclio("OPEN",frec)
   SET frec->file_buf = concat("SponsorCode|",
    "LocationCode|EncounterDate|AdmitDate|DischargeDate|PatientIdentifier|",
    "PatientLastName|PatientFirstName|PatientDOB|","PrimaryPrescriberNPI|PrimaryPrescriberLastName|",
    "PrimaryPrescriberFirstName|",
    char(10))
   SET stat = cclio("WRITE",frec)
   FOR (ml_loop = 1 TO size(encntrs->qual,5))
     SET ms_line = concat(encntrs->qual[ml_loop].s_sponsor_code,"|",encntrs->qual[ml_loop].s_loc_code,
      "|",encntrs->qual[ml_loop].s_encntr_dt,
      "|",encntrs->qual[ml_loop].s_admit_dt,"|",encntrs->qual[ml_loop].s_disch_dt,"|",
      encntrs->qual[ml_loop].s_mrn,"|",encntrs->qual[ml_loop].s_pat_name_last,"|",encntrs->qual[
      ml_loop].s_pat_name_first,
      "|",encntrs->qual[ml_loop].s_pat_dob,"|",encntrs->qual[ml_loop].s_prim_pres_npi,"|",
      encntrs->qual[ml_loop].s_prim_pres_name_last,"|",encntrs->qual[ml_loop].s_prim_pres_name_first,
      "|",char(10))
     SET frec->file_buf = ms_line
     SET stat = cclio("WRITE",frec)
   ENDFOR
   SET stat = cclio("CLOSE",frec)
   IF (mn_is_ops_job != 1)
    SELECT INTO  $OUTDEV
     FROM (dummyt d  WITH seq = 1)
     PLAN (d)
     HEAD REPORT
      "{lpi/12}{cpi/12}{font/0}", row + 1,
      CALL center(build2("{b}{u}",build2("BHS_MA Wellpartner Encounter File"),"{endb}{endu}"),0,106),
      row 8, col 0,
      CALL print(build2("PROGRAM:  ",cnvtlower(curprog),"       NODE:  ",curnode)),
      row 11, col 0,
      CALL print(build2("Execution Date/Time:  ",format(cnvtdatetime(curdate,curtime),
        "mm/dd/yyyy hh:mm:ss;;q"))),
      row 15, col 0,
      CALL print(build2("The extract filename is ",build2('"',frec->file_name,'"'))),
      row 18, col 0,
      CALL print(build2("Total Rows:",size(encntrs->qual,5))),
      row 22, col 0,
      CALL print(build2("The extract file path is ",build('"',trim(ms_loc_dir,3),'"')))
     WITH nocounter, nullreport, maxcol = 300,
      dio = postscript
    ;end select
   ENDIF
   SET ms_log = ""
  ENDIF
 ELSE
  IF (size(encntrs->qual,5) > 0)
   SELECT INTO  $OUTDEV
    sponsor_code = substring(1,30,encntrs->qual[d1.seq].s_sponsor_code), loc_code = substring(1,30,
     encntrs->qual[d1.seq].s_loc_code), encntr_dt = substring(1,30,encntrs->qual[d1.seq].s_encntr_dt),
    admit_dt = substring(1,30,encntrs->qual[d1.seq].s_admit_dt), disch_dt = substring(1,30,encntrs->
     qual[d1.seq].s_disch_dt), mrn = substring(1,30,encntrs->qual[d1.seq].s_mrn),
    pat_name_last = substring(1,30,encntrs->qual[d1.seq].s_pat_name_last), pat_name_first = substring
    (1,30,encntrs->qual[d1.seq].s_pat_name_first), pat_dob = substring(1,30,encntrs->qual[d1.seq].
     s_pat_dob),
    prim_prenpi = substring(1,30,encntrs->qual[d1.seq].s_prim_pres_npi), prim_prename_last =
    substring(1,30,encntrs->qual[d1.seq].s_prim_pres_name_last), prim_prename_first = substring(1,30,
     encntrs->qual[d1.seq].s_prim_pres_name_first)
    FROM (dummyt d1  WITH seq = size(encntrs->qual,5))
    PLAN (d1)
    WITH nocounter, separator = " ", format
   ;end select
  ELSE
   SELECT INTO  $OUTDEV
    FROM dummyt d
    DETAIL
     col 50, "No data qualified for the date range", row + 1
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
#exit_script
 IF (textlen(ms_log) > 1
  AND mn_is_ops_job != 1)
  SELECT INTO  $OUTDEV
   FROM dummyt d
   HEAD REPORT
    "{font/22}", col 50,
    CALL print(ms_log),
    row + 1
   WITH nocounter, dio = 8
  ;end select
 ENDIF
 CALL echorecord(encntrs)
 FREE RECORD encntrs
 SET reply->status_data[1].status = "S"
 SET last_mod = "001 04/08/2024 MH106303 BHS_MA Wellpartner CCPS-299"
END GO
