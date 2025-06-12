CREATE PROGRAM al_clairvia_clin_doc_export:dba
 PROMPT
  "Printer" = "MINE",
  "FACILITY" = 0,
  "Start DD-MMM-YYYY HH:MM" = "",
  "End   DD-MMM-YYYY HH:MM" = "",
  "Code Set Display Key" = ""
  WITH outdev, facility, startdttm,
  enddttm, codeset
 IF ( NOT (validate(reply->status_data)))
  RECORD reply(
    1 ops_event = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE RECORD transaction
 RECORD transaction(
   1 trans_qual_cnt = i4
   1 transactions[*]
     2 trans_string = vc
     2 dta_cd = f8
     2 result_val = vc
 )
 FREE RECORD frec
 RECORD frec(
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
   1 file_name = vc
   1 file_buf = vc
 )
 FREE RECORD drec
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
 FREE RECORD cv_extension
 RECORD cv_extension(
   1 cs_cnt = i4
   1 qual[*]
     2 code_set = f8
     2 cv_cnt = i4
     2 qual[*]
       3 code_value = f8
       3 alias = vc
 )
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
 RECORD atg_dminfo_reqi(
   1 allow_partial_ind = i2
   1 info_domaini = i2
   1 info_namei = i2
   1 info_datei = i2
   1 info_daten = i2
   1 info_chari = i2
   1 info_charn = i2
   1 info_numberi = i2
   1 info_numbern = i2
   1 info_long_idi = i2
   1 qual[*]
     2 info_domain = c80
     2 info_name = c255
     2 info_date = dq8
     2 info_char = c255
     2 info_number = f8
     2 info_long_id = f8
 )
 RECORD atg_dminfo_reqw(
   1 allow_partial_ind = i2
   1 force_updt_ind = i2
   1 info_domainw = i2
   1 info_namew = i2
   1 info_datew = i2
   1 info_charw = i2
   1 info_numberw = i2
   1 info_long_idw = i2
   1 updt_applctxw = i2
   1 updt_dt_tmw = i2
   1 updt_cntw = i2
   1 updt_idw = i2
   1 updt_taskw = i2
   1 info_domainf = i2
   1 info_namef = i2
   1 info_datef = i2
   1 info_charf = i2
   1 info_numberf = i2
   1 info_long_idf = i2
   1 updt_cntf = i2
   1 qual[*]
     2 info_domain = c80
     2 info_name = c255
     2 info_date = dq8
     2 info_char = c255
     2 info_number = f8
     2 info_long_id = f8
     2 updt_applctx = i4
     2 updt_dt_tm = dq8
     2 updt_cnt = i4
     2 updt_id = f8
     2 updt_task = i4
 )
 RECORD atg_dminfo_reqd(
   1 allow_partial_ind = i2
   1 info_domainw = i2
   1 info_namew = i2
   1 qual[*]
     2 info_domain = c80
     2 info_name = c255
 )
 RECORD atg_dminfo_rep(
   1 curqual = i4
   1 qual[*]
     2 status = i2
     2 error_num = i4
     2 error_msg = vc
     2 info_domain = c80
     2 info_name = c255
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE get_dminfo_number(sdomain,sname) = f8
 SUBROUTINE get_dminfo_number(sdomain,sname)
   DECLARE datgdminfovalue = f8 WITH protect, noconstant(0.0)
   SELECT INTO "NL"
    FROM dm_info di
    PLAN (di
     WHERE di.info_domain=sdomain
      AND di.info_name=sname)
    DETAIL
     datgdminfovalue = di.info_number
    WITH nocounter
   ;end select
   RETURN(datgdminfovalue)
 END ;Subroutine
 DECLARE get_dminfo_char(sdomain,sname) = c255
 SUBROUTINE get_dminfo_char(sdomain,sname)
   DECLARE satgdminfovalue = c255 WITH protect, noconstant("")
   SELECT INTO "NL"
    FROM dm_info di
    PLAN (di
     WHERE di.info_domain=sdomain
      AND di.info_name=sname)
    DETAIL
     satgdminfovalue = di.info_char
    WITH nocounter
   ;end select
   RETURN(satgdminfovalue)
 END ;Subroutine
 DECLARE get_dminfo_date(sdomain,sname) = dq8
 SUBROUTINE get_dminfo_date(sdomain,sname)
   DECLARE dtatgdminfovalue = dq8 WITH protect, noconstant
   SELECT INTO "NL"
    FROM dm_info di
    PLAN (di
     WHERE di.info_domain=sdomain
      AND di.info_name=sname)
    DETAIL
     dtatgdminfovalue = cnvtdatetime(di.info_date)
    WITH nocounter
   ;end select
   RETURN(dtatgdminfovalue)
 END ;Subroutine
 DECLARE get_dminfo_longid(sdomain,sname) = f8
 SUBROUTINE get_dminfo_longid(sdomain,sname)
   DECLARE datgdminfovalue = f8 WITH protect, noconstant(0.0)
   SELECT INTO "NL"
    FROM dm_info di
    PLAN (di
     WHERE di.info_domain=sdomain
      AND di.info_name=sname)
    DETAIL
     datgdminfovalue = di.info_long_id
    WITH nocounter
   ;end select
   RETURN(datgdminfovalue)
 END ;Subroutine
 SUBROUTINE set_dminfo_number(sdomain,sname,dvalue)
   SET stat = initrec(atg_dminfo_reqi)
   SET stat = initrec(atg_dminfo_reqw)
   SELECT INTO "NL:"
    FROM dm_info di
    PLAN (di
     WHERE di.info_domain=sdomain
      AND di.info_name=sname)
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET stat = alterlist(atg_dminfo_reqi->qual,1)
    SET atg_dminfo_reqi->qual[1].info_domain = sdomain
    SET atg_dminfo_reqi->qual[1].info_name = sname
    SET atg_dminfo_reqi->qual[1].info_number = dvalue
    SET atg_dminfo_reqi->info_domaini = 1
    SET atg_dminfo_reqi->info_namei = 1
    SET atg_dminfo_reqi->info_numberi = 1
    EXECUTE gm_i_dm_info2388  WITH replace("REQUEST","ATG_DMINFO_REQI"), replace("REPLY",
     "ATG_DMINFO_REP")
   ELSE
    SET stat = alterlist(atg_dminfo_reqw->qual,1)
    SET atg_dminfo_reqw->qual[1].info_domain = sdomain
    SET atg_dminfo_reqw->qual[1].info_name = sname
    SET atg_dminfo_reqw->qual[1].info_number = dvalue
    SET atg_dminfo_reqw->info_domainw = 1
    SET atg_dminfo_reqw->info_namew = 1
    SET atg_dminfo_reqw->info_numberf = 1
    SET atg_dminfo_reqw->force_updt_ind = 1
    EXECUTE gm_u_dm_info2388  WITH replace("REQUEST","ATG_DMINFO_REQW"), replace("REPLY",
     "ATG_DMINFO_REP")
   ENDIF
   IF ((reqinfo->commit_ind=1))
    COMMIT
   ENDIF
 END ;Subroutine
 SUBROUTINE set_dminfo_date(sdomain,sname,dtvalue)
   SET stat = initrec(atg_dminfo_reqi)
   SET stat = initrec(atg_dminfo_reqw)
   SELECT INTO "NL:"
    FROM dm_info di
    PLAN (di
     WHERE di.info_domain=sdomain
      AND di.info_name=sname)
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET stat = alterlist(atg_dminfo_reqi->qual,1)
    SET atg_dminfo_reqi->qual[1].info_domain = sdomain
    SET atg_dminfo_reqi->qual[1].info_name = sname
    SET atg_dminfo_reqi->qual[1].info_date = cnvtdatetime(dtvalue)
    SET atg_dminfo_reqi->info_domaini = 1
    SET atg_dminfo_reqi->info_namei = 1
    SET atg_dminfo_reqi->info_datei = 1
    EXECUTE gm_i_dm_info2388  WITH replace("REQUEST","ATG_DMINFO_REQI"), replace("REPLY",
     "ATG_DMINFO_REP")
   ELSE
    SET stat = alterlist(atg_dminfo_reqw->qual,1)
    SET atg_dminfo_reqw->qual[1].info_domain = sdomain
    SET atg_dminfo_reqw->qual[1].info_name = sname
    SET atg_dminfo_reqw->qual[1].info_date = cnvtdatetime(dtvalue)
    SET atg_dminfo_reqw->info_domainw = 1
    SET atg_dminfo_reqw->info_namew = 1
    SET atg_dminfo_reqw->info_datef = 1
    SET atg_dminfo_reqw->force_updt_ind = 1
    EXECUTE gm_u_dm_info2388  WITH replace("REQUEST","ATG_DMINFO_REQW"), replace("REPLY",
     "ATG_DMINFO_REP")
   ENDIF
   IF ((reqinfo->commit_ind=1))
    COMMIT
   ENDIF
 END ;Subroutine
 SUBROUTINE set_dminfo_char(sdomain,sname,svalue)
   SET stat = initrec(atg_dminfo_reqi)
   SET stat = initrec(atg_dminfo_reqw)
   SELECT INTO "NL:"
    FROM dm_info di
    PLAN (di
     WHERE di.info_domain=sdomain
      AND di.info_name=sname)
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET stat = alterlist(atg_dminfo_reqi->qual,1)
    SET atg_dminfo_reqi->qual[1].info_domain = sdomain
    SET atg_dminfo_reqi->qual[1].info_name = sname
    SET atg_dminfo_reqi->qual[1].info_char = svalue
    SET atg_dminfo_reqi->info_domaini = 1
    SET atg_dminfo_reqi->info_namei = 1
    SET atg_dminfo_reqi->info_chari = 1
    EXECUTE gm_i_dm_info2388  WITH replace("REQUEST","ATG_DMINFO_REQI"), replace("REPLY",
     "ATG_DMINFO_REP")
   ELSE
    SET stat = alterlist(atg_dminfo_reqw->qual,1)
    SET atg_dminfo_reqw->qual[1].info_domain = sdomain
    SET atg_dminfo_reqw->qual[1].info_name = sname
    SET atg_dminfo_reqw->qual[1].info_char = svalue
    SET atg_dminfo_reqw->info_domainw = 1
    SET atg_dminfo_reqw->info_namew = 1
    SET atg_dminfo_reqw->info_charf = 1
    SET atg_dminfo_reqw->force_updt_ind = 1
    EXECUTE gm_u_dm_info2388  WITH replace("REQUEST","ATG_DMINFO_REQW"), replace("REPLY",
     "ATG_DMINFO_REP")
   ENDIF
   IF ((reqinfo->commit_ind=1))
    COMMIT
   ENDIF
 END ;Subroutine
 SUBROUTINE set_dminfo_longid(sdomain,sname,dvalue)
   SET stat = initrec(atg_dminfo_reqi)
   SET stat = initrec(atg_dminfo_reqw)
   SELECT INTO "NL:"
    FROM dm_info di
    PLAN (di
     WHERE di.info_domain=sdomain
      AND di.info_name=sname)
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET stat = alterlist(atg_dminfo_reqi->qual,1)
    SET atg_dminfo_reqi->qual[1].info_domain = sdomain
    SET atg_dminfo_reqi->qual[1].info_name = sname
    SET atg_dminfo_reqi->qual[1].info_long_id = dvalue
    SET atg_dminfo_reqi->info_domaini = 1
    SET atg_dminfo_reqi->info_namei = 1
    SET atg_dminfo_reqi->info_long_idi = 1
    EXECUTE gm_i_dm_info2388  WITH replace("REQUEST","ATG_DMINFO_REQI"), replace("REPLY",
     "ATG_DMINFO_REP")
   ELSE
    SET stat = alterlist(atg_dminfo_reqw->qual,1)
    SET atg_dminfo_reqw->qual[1].info_domain = sdomain
    SET atg_dminfo_reqw->qual[1].info_name = sname
    SET atg_dminfo_reqw->qual[1].info_long_id = dvalue
    SET atg_dminfo_reqw->info_domainw = 1
    SET atg_dminfo_reqw->info_namew = 1
    SET atg_dminfo_reqw->info_long_idf = 1
    SET atg_dminfo_reqw->force_updt_ind = 1
    EXECUTE gm_u_dm_info2388  WITH replace("REQUEST","ATG_DMINFO_REQW"), replace("REPLY",
     "ATG_DMINFO_REP")
   ENDIF
   IF ((reqinfo->commit_ind=1))
    COMMIT
   ENDIF
 END ;Subroutine
 SUBROUTINE remove_dminfo(sdomain,sname)
   SET stat = initrec(atg_dminfo_reqd)
   SET stat = alterlist(atg_dminfo_reqd->qual,1)
   SET atg_dminfo_reqd->qual[1].info_domain = sdomain
   SET atg_dminfo_reqd->qual[1].info_name = sname
   SET atg_dminfo_reqd->info_domainw = 1
   SET atg_dminfo_reqd->info_namew = 1
   EXECUTE gm_d_dm_info2388  WITH replace("REQUEST","ATG_DMINFO_REQD"), replace("REPLY",
    "ATG_DMINFO_REP")
   IF ((reqinfo->commit_ind=1))
    COMMIT
   ENDIF
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
      SET frec->file_name = debug_values->log_file_dest
      SET frec->file_buf = "ab"
      SET stat = cclio("OPEN",frec)
      SET frec->file_dir = 2
      SET seek_retval = cclio("SEEK",frec)
      SET filelen = cclio("TELL",frec)
      SET frec->file_offset = filelen
      SET frec->file_buf = build2(format(cnvtdatetime(sysdate),"mm/dd/yyyy hh:mm:ss;;d"),fillstring(5,
        " "),"{",smsglvl,"}",
       fillstring(5," "),mymsg,char(13),char(10))
      SET write_stat = cclio("WRITE",frec)
      SET stat = cclio("CLOSE",frec)
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
      SET frec->file_buf = build2(format(cnvtdatetime(sysdate),"mm/dd/yyyy hh:mm:ss;;d"),fillstring(5,
        " "),"{",smsgtype,"}",
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
 SUBROUTINE (isuserindomain(user_id=f8,log_domain_id=f8) =i2)
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
        AND ld.beg_effective_dt_tm <= cnvtdatetime(sysdate)
        AND ld.end_effective_dt_tm > cnvtdatetime(sysdate))
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
 SUBROUTINE (isorgindomain(org_id=f8,log_domain_id=f8) =i2)
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
 SUBROUTINE (isorginuserdomain(org_id=f8,user_id=f8) =i2)
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
 SUBROUTINE (column_exists(stable=vc,scolumn=vc) =i4)
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
 SUBROUTINE (getcurrentlogicaldomain(user_id=f8(value,0.0)) =f8)
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
       SET last_prompt += 1
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
 SUBROUTINE (isprinterindomain(output_dest=vc,log_domain_id=f8) =i2)
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
        AND l.beg_effective_dt_tm <= cnvtdatetime(sysdate)
        AND l.end_effective_dt_tm > cnvtdatetime(sysdate)
        AND l.active_ind=1)
       JOIN (o
       WHERE o.organization_id=l.organization_id
        AND o.logical_domain_id=log_domain_id
        AND o.beg_effective_dt_tm <= cnvtdatetime(sysdate)
        AND o.end_effective_dt_tm > cnvtdatetime(sysdate)
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
 SUBROUTINE (getldconceptparser(pconcept=i2,pfield=vc,plogicaldomainid=f8,pprompt=i2(value,0),poption
  =i2(value,list_in)) =vc)
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
 DECLARE 34_alt_status_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!16901"))
 DECLARE 34_auth_status_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2628"))
 DECLARE 34_mod_status_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2636"))
 DECLARE 53_event_txt_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2698"))
 DECLARE 53_event_num_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2694"))
 DECLARE 53_date_class_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!13880"))
 DECLARE 72_ivparent_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3414964"))
 DECLARE 319_fin_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2930"))
 DECLARE 339_census_cd = f8 WITH protect, constant(uar_get_code_by("display_key",339,"CENSUS"))
 DECLARE 6000_generallab_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3081"))
 DECLARE 6000_generallab_act_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2833")
  )
 DECLARE 6000_pharmacy_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3079"))
 DECLARE 6011_primary_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3128"))
 DECLARE 16389_lab_clin_cat_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!36344")
  )
 DECLARE 16389_iv_clin_cat_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!33873"))
 DECLARE 16389_meds_clin_cat_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!33875"
   ))
 DECLARE trans_cnt = i4 WITH protect, noconstant(0)
 DECLARE begin_dt_tm = dq8 WITH noconstant(parsedateprompt( $STARTDTTM,curdate,000000)), protect
 DECLARE end_dt_tm = dq8 WITH constant(parsedateprompt( $ENDDTTM,curdate,curtime2)), protect
 DECLARE dm_save_date = dq8 WITH public, noconstant(cnvtdatetime(end_dt_tm))
 DECLARE s_temp_result_val = vc WITH protect, noconstant("")
 DECLARE b_found_nomen = i2 WITH protect, noconstant(false)
 DECLARE s_temp_nome_result = vc WITH protect, noconstant("")
 DECLARE num = i2 WITH protect, constant(0)
 DECLARE string_size = i4 WITH protect, noconstant(0)
 DECLARE output_string = vc WITH protect, noconstant(" ")
 DECLARE msg_1 = vc WITH protect, noconstant("")
 DECLARE msg_2 = vc WITH protect, noconstant("")
 DECLARE alias = vc WITH protect, noconstant(" ")
 DECLARE parent_flow_rate = vc WITH protect, noconstant(" ")
 DECLARE bb_include = vc WITH protect, noconstant(" ")
 DECLARE ivi_include = vc WITH protect, noconstant(" ")
 DECLARE lab_include = vc WITH protect, noconstant(" ")
 DECLARE iv_include = vc WITH protect, noconstant(" ")
 DECLARE codesetloc = vc WITH protect, noconstant(" ")
 DECLARE commwx = vc WITH protect, noconstant(" ")
 DECLARE fin_format = vc WITH protect, noconstant(" ")
 DECLARE manual_run_flag = i2 WITH protect, noconstant(0)
 DECLARE datediff = f8 WITH protect, noconstant(0.0)
 DECLARE e_idx = i4 WITH public, noconstant(0)
 DECLARE bcnt = i4 WITH public, noconstant(0)
 DECLARE fin_ind = i2 WITH protect, noconstant(0)
 DECLARE ld_mnemonic = vc WITH protect, noconstant(" ")
 DECLARE fileloc = vc WITH protect, noconstant(trim(logical("cer_temp"),3))
 DECLARE mnemonic = vc WITH protect, noconstant(" ")
 DECLARE filewrite = vc WITH protect, noconstant(" ")
 DECLARE carriage_return = c1 WITH constant(char(13))
 DECLARE line_feed = c1 WITH constant(char(10))
 DECLARE fac_parser = vc WITH protect, noconstant("0=1")
 DECLARE ms_dclcom = vc WITH protect, noconstant("")
 DECLARE ml_stat = i4 WITH protect, noconstant(0)
 EXECUTE bhs_check_domain
 IF (logical_domain_error)
  CALL logmsg(reply->status_data.subeventstatus[1].targetobjectvalue,ccps_log_error)
  GO TO exit_script
 ENDIF
 DECLARE ld_parser = vc WITH constant(getldconceptparser(ld_concept_location,"ed.loc_facility_cd",
   cur_logical_domain,2)), protect
 SELECT INTO "nl:"
  FROM logical_domain ld
  PLAN (ld
   WHERE ld.logical_domain_id=cur_logical_domain)
  HEAD REPORT
   ld_mnemonic = trim(ld.mnemonic,3)
   IF (textlen(ld_mnemonic) > 0)
    codesetloc = cnvtalphanum(cnvtupper(concat(ld_mnemonic,"CLAIRVIADATAINPUTS")),2)
   ELSEIF (textlen( $CODESET) > 1)
    codesetloc =  $CODESET
   ELSE
    codesetloc = "CLAIRVIADATAINPUTS"
   ENDIF
  WITH nocounter
 ;end select
 IF (catcherrors("An error occurred in the ld select statement."))
  GO TO exit_script
 ENDIF
 IF (((ispromptany(2)) OR (ispromptempty(2))) )
  SET fac_parser = "1=1"
 ELSE
  SET fac_parser = trim(getpromptlist(parameter2( $FACILITY),"ed.loc_facility_cd"),3)
 ENDIF
 SET filewrite = build2("al_test_clairvia_clin_doc_bhsma","_",format(curdate,"mmddyyyy;;d"),"_",
  format(curtime3,"hhmmss;3;m"),
  ".txt")
 CALL echo("HEYHEY")
 CALL echo(codesetloc)
 SET manual_run_flag = 1
 SELECT INTO "nl:"
  cv.description
  FROM code_value_set cvs,
   code_value cv
  PLAN (cvs
   WHERE cvs.display_key=codesetloc)
   JOIN (cv
   WHERE cvs.code_set=cv.code_set)
  DETAIL
   CASE (cv.cdf_meaning)
    OF "CLINFILENAME":
     mnemonic = trim(cv.description,3)
    OF "CLINFILELOC":
     fileloc = trim(cnvtupper(cv.description),3)
    OF "BB":
     bb_include = trim(cv.description,3)
    OF "IV":
     iv_include = trim(cv.description,3)
    OF "IVI":
     ivi_include = trim(cv.description,3)
    OF "LAB":
     lab_include = trim(cv.description,3)
    OF "FINFORMAT":
     fin_format = trim(cv.description,3)
    OF "COMMWX":
     commwx = trim(cv.description,3)
   ENDCASE
  WITH nocounter
 ;end select
 IF (textlen(commwx)=0)
  CALL logmsg("Contributor source doesn't exist for the current logical domain.",ccps_log_error)
  GO TO exit_script
 ENDIF
 IF (bb_include="Y")
  SELECT INTO "nl:"
   FROM code_value_extension cve
   WHERE cve.code_set=72.00
    AND cve.field_name IN (codesetloc)
   ORDER BY cve.code_set, cve.code_value
   HEAD REPORT
    cs_cnt = 0
   HEAD cve.code_set
    cs_cnt += 1
    IF (mod(cs_cnt,10)=1)
     stat = alterlist(cv_extension->qual,(cs_cnt+ 9))
    ENDIF
    cv_extension->qual[cs_cnt].code_set = cve.code_set, cv_cnt = 0
   DETAIL
    IF (cve.field_value="Y")
     cv_cnt += 1
     IF (mod(cv_cnt,100)=1)
      stat = alterlist(cv_extension->qual[cs_cnt].qual,(cv_cnt+ 99))
     ENDIF
     cv_extension->qual[cs_cnt].qual[cv_cnt].code_value = cve.code_value, cv_extension->qual[cs_cnt].
     qual[cv_cnt].alias = cve.field_value
    ENDIF
   FOOT  cve.code_set
    cv_extension->qual[cs_cnt].cv_cnt = cv_cnt, stat = alterlist(cv_extension->qual[cs_cnt].qual,
     cv_cnt)
   FOOT REPORT
    cv_extension->cs_cnt = cs_cnt, stat = alterlist(cv_extension->qual,cs_cnt)
   WITH nocounter
  ;end select
  IF ((cv_extension->cs_cnt <= 0))
   CALL logmsg(
    "Failed to locate the blood bank aliases.  Please build these out if you want to query blood bank items",
    ccps_log_error)
   GO TO exit_script
  ENDIF
 ENDIF
 IF (textlen(fin_format) <= 0)
  SET fin_ind = 0
 ELSE
  SET fin_ind = 1
  SET fin_format = concat(fin_format,";P0")
 ENDIF
 IF (((ispromptempty(3)) OR (ispromptempty(4))) )
  SET begin_dt_tm = get_dminfo_date("CCPS",build(curprog,"_",trim(cnvtupper(curdomain)),"_",trim(
     cnvtupper(mnemonic))))
  IF (cnvtint(begin_dt_tm)=0)
   SET begin_dt_tm = cnvtdatetime(sysdate)
   SET dm_save_dt = cnvtdatetime(sysdate)
   SET reply->status_data.status = "S"
   SET reply->ops_event = concat("Initial run for ",trim(cnvtupper(mnemonic)))
   GO TO exit_script
  ENDIF
 ELSE
  SET manual_run_flag = 1
  SET datediff = datetimediff(end_dt_tm,begin_dt_tm,3)
  IF (((((cnvtint(begin_dt_tm)=0) OR (cnvtint(end_dt_tm)=0)) ) OR ( NOT (datediff BETWEEN 0.0 AND
  48.0))) )
   SET msg_2 = build2("Invalid Date Range.  Enter valid dates and date range of up to 48 hours.  ",
    " Start: ",format(begin_dt_tm,"dd-mm-yyyy hh:mm;;d")," End: ",format(end_dt_tm,
     "dd-mm-yyyy hh:mm;;d"),
    " Hours: ",datediff)
   GO TO exit_script
  ENDIF
 ENDIF
 CALL echo(format(cnvtdatetime(begin_dt_tm),";;q"))
 CALL echo(format(cnvtdatetime(end_dt_tm),";;q"))
 SELECT INTO "nl:"
  FROM encntr_domain ed,
   encounter e,
   encntr_alias ea
  PLAN (ed
   WHERE ed.beg_effective_dt_tm <= cnvtdatetime(end_dt_tm)
    AND ed.end_effective_dt_tm > cnvtdatetime(begin_dt_tm)
    AND ed.active_ind=1
    AND ed.encntr_domain_type_cd=339_census_cd
    AND parser(fac_parser)
    AND parser(ld_parser))
   JOIN (e
   WHERE e.encntr_id=ed.encntr_id
    AND e.loc_nurse_unit_cd > 0.00
    AND e.loc_bed_cd > 0.00)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=319_fin_cd
    AND ea.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND ea.alias="861558253"
    AND ea.active_ind=1)
  ORDER BY e.encntr_id
  HEAD REPORT
   drec->encntr_qual_cnt = 0
  HEAD e.encntr_id
   drec->encntr_qual_cnt += 1
   IF (mod(drec->encntr_qual_cnt,1000)=1)
    stat = alterlist(drec->encntr_qual,(drec->encntr_qual_cnt+ 999))
   ENDIF
   drec->encntr_qual[drec->encntr_qual_cnt].encntr_id = e.encntr_id
   IF (fin_ind=1)
    drec->encntr_qual[drec->encntr_qual_cnt].fin_id = format(ea.alias,fin_format)
   ELSE
    drec->encntr_qual[drec->encntr_qual_cnt].fin_id = ea.alias
   ENDIF
  FOOT  e.encntr_id
   null
  FOOT REPORT
   stat = alterlist(drec->encntr_qual,drec->encntr_qual_cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM clinical_event ce,
   (left JOIN ce_coded_result ccr ON ce.event_id=ccr.event_id
    AND ccr.valid_until_dt_tm > cnvtdatetime(sysdate)),
   (left JOIN nomenclature n ON n.nomenclature_id=ccr.nomenclature_id),
   discrete_task_assay dta
  PLAN (ce
   WHERE expand(e_idx,1,drec->encntr_qual_cnt,ce.encntr_id,drec->encntr_qual[e_idx].encntr_id)
    AND ce.clinsig_updt_dt_tm BETWEEN cnvtdatetime(begin_dt_tm) AND cnvtdatetime(end_dt_tm)
    AND ce.event_class_cd IN (53_event_txt_cd, 53_event_num_cd)
    AND ce.performed_dt_tm != null
    AND ce.event_end_dt_tm != null
    AND ce.result_val > " "
    AND ce.result_status_cd IN (34_mod_status_cd, 34_auth_status_cd, 34_alt_status_cd)
    AND ce.valid_until_dt_tm > cnvtdatetime(sysdate)
    AND ce.publish_flag=1.00
    AND ce.ce_dynamic_label_id=0.00)
   JOIN (ccr)
   JOIN (n)
   JOIN (dta
   WHERE dta.task_assay_cd=ce.task_assay_cd
    AND dta.active_ind=1
    AND dta.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND dta.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND dta.activity_type_cd != 6000_generallab_act_cd)
  ORDER BY ce.clinsig_updt_dt_tm, ce.event_id, ccr.sequence_nbr
  HEAD REPORT
   null
  HEAD ce.clinsig_updt_dt_tm
   null
  HEAD ce.event_id
   pos = locateval(num,1,drec->encntr_qual_cnt,ce.encntr_id,drec->encntr_qual[num].encntr_id)
   WHILE (pos != 0)
    alias = drec->encntr_qual[pos].fin_id,pos = locateval(num,(pos+ 1),drec->encntr_qual_cnt,ce
     .encntr_id,drec->encntr_qual[num].encntr_id)
   ENDWHILE
   trans_cnt += 1
   IF (mod(trans_cnt,1000)=1)
    stat = alterlist(transaction->transactions,(trans_cnt+ 1000))
   ENDIF
   transaction->transactions[trans_cnt].dta_cd = ce.task_assay_cd, transaction->transactions[
   trans_cnt].result_val = trim(ce.result_val,3), transaction->transactions[trans_cnt].trans_string
    = build2(trim(format(ce.event_end_dt_tm,"YYYYMMDD|HHMM;;Q")),"|",alias,"|",trim(dta.mnemonic),
    "|"),
   s_temp_result_val = trim(ce.result_val), b_found_nomen = false, s_temp_nome_result = ""
  DETAIL
   IF (n.nomenclature_id > 0.0)
    b_found_nomen = true, s_temp_result_val = replace(s_temp_result_val,trim(n.short_string),"",0)
    IF (textlen(trim(s_temp_nome_result,3)) > 0)
     s_temp_nome_result = substring(1,100,build2(s_temp_nome_result,";",trim(n.source_string,3)))
    ELSE
     s_temp_nome_result = substring(1,100,trim(n.source_string,3))
    ENDIF
   ENDIF
  FOOT  ce.event_id
   IF (b_found_nomen=true)
    IF (textlen(trim(replace(s_temp_result_val,",","",0),3)) > 0)
     s_temp_result_val = trim(replace(s_temp_result_val,",","",0),3), s_temp_result_val = build2(
      s_temp_nome_result,";",s_temp_result_val)
    ELSE
     s_temp_result_val = s_temp_nome_result
    ENDIF
    transaction->transactions[trans_cnt].trans_string = build2(transaction->transactions[trans_cnt].
     trans_string,trim(s_temp_result_val,3),"|")
   ELSE
    s_temp_result_val = trim(replace(s_temp_result_val,",","",0),3), transaction->transactions[
    trans_cnt].trans_string = build2(transaction->transactions[trans_cnt].trans_string,trim(
      s_temp_result_val,3),"|")
   ENDIF
   IF (isnumeric(ce.normal_low) != 0
    AND isnumeric(ce.normal_high) != 0)
    IF (cnvtreal(ce.normal_low) > cnvtreal(ce.result_val))
     transaction->transactions[trans_cnt].trans_string = build2(transaction->transactions[trans_cnt].
      trans_string,"L")
    ELSEIF (cnvtreal(ce.result_val) >= cnvtreal(ce.normal_low)
     AND cnvtreal(ce.result_val) <= cnvtreal(ce.normal_high))
     transaction->transactions[trans_cnt].trans_string = build2(transaction->transactions[trans_cnt].
      trans_string,"N")
    ELSEIF (cnvtreal(ce.normal_high) < cnvtreal(ce.result_val))
     transaction->transactions[trans_cnt].trans_string = build2(transaction->transactions[trans_cnt].
      trans_string,"H")
    ENDIF
   ELSE
    transaction->transactions[trans_cnt].trans_string = build2(transaction->transactions[trans_cnt].
     trans_string)
   ENDIF
   transaction->transactions[trans_cnt].trans_string = build2(transaction->transactions[trans_cnt].
    trans_string,"||","QUERY1")
   IF (size(transaction->transactions[trans_cnt].trans_string,1) > string_size)
    string_size = size(transaction->transactions[trans_cnt].trans_string,1)
   ENDIF
  FOOT  ce.clinsig_updt_dt_tm
   null
  FOOT REPORT
   stat = alterlist(transaction->transactions,trans_cnt), transaction->trans_qual_cnt = trans_cnt
  WITH nocounter, expand = 1
 ;end select
 IF (ivi_include="Y")
  SELECT INTO "nl:"
   FROM clinical_event ce,
    ce_dynamic_label cdl,
    dynamic_label_template dlt,
    doc_set_ref dsr
   PLAN (ce
    WHERE expand(e_idx,1,drec->encntr_qual_cnt,ce.encntr_id,drec->encntr_qual[e_idx].encntr_id)
     AND ce.clinsig_updt_dt_tm BETWEEN cnvtdatetime(begin_dt_tm) AND cnvtdatetime(end_dt_tm)
     AND ce.event_class_cd IN (53_event_txt_cd, 53_date_class_cd)
     AND ce.performed_dt_tm != null
     AND ce.event_end_dt_tm != null
     AND ce.result_val > " "
     AND ce.result_status_cd IN (34_mod_status_cd, 34_auth_status_cd, 34_alt_status_cd)
     AND ce.valid_until_dt_tm > cnvtdatetime(sysdate)
     AND ce.publish_flag=1.00
     AND ce.ce_dynamic_label_id > 1.0)
    JOIN (cdl
    WHERE ce.ce_dynamic_label_id=cdl.ce_dynamic_label_id)
    JOIN (dlt
    WHERE cdl.label_template_id=dlt.label_template_id)
    JOIN (dsr
    WHERE dlt.doc_set_ref_id=dsr.doc_set_ref_id)
   ORDER BY ce.ce_dynamic_label_id, ce.clinsig_updt_dt_tm, ce.event_id
   HEAD REPORT
    trans_cnt = size(transaction->transactions,5), stat = alterlist(transaction->transactions,(
     trans_cnt+ 1000))
   DETAIL
    trans_cnt += 1
    IF (mod(trans_cnt,1000)=1)
     stat = alterlist(transaction->transactions,(trans_cnt+ 1000))
    ENDIF
    pos = locateval(num,1,drec->encntr_qual_cnt,ce.encntr_id,drec->encntr_qual[num].encntr_id)
    WHILE (pos != 0)
     alias = drec->encntr_qual[pos].fin_id,pos = locateval(num,(pos+ 1),drec->encntr_qual_cnt,ce
      .encntr_id,drec->encntr_qual[num].encntr_id)
    ENDWHILE
    IF (ce.event_class_cd=53_date_class_cd)
     s_temp_result_val = concat(substring(7,2,ce.result_val),"/",substring(9,2,ce.result_val),"/",
      substring(3,4,ce.result_val),
      " ",substring(11,2,ce.result_val),":",substring(13,2,ce.result_val))
    ELSE
     IF (ce.view_level=1)
      s_temp_result_val = replace(ce.result_val,",",";"), s_temp_result_val = replace(
       s_temp_result_val,"; ",";")
     ELSE
      s_temp_result_val = ce.result_val
     ENDIF
    ENDIF
    transaction->transactions[trans_cnt].dta_cd = ce.task_assay_cd, transaction->transactions[
    trans_cnt].result_val = trim(ce.result_val,3), transaction->transactions[trans_cnt].trans_string
     = build2(trim(format(ce.event_end_dt_tm,"YYYYMMDD|HHMM;;Q")),"|",alias,"|",trim(
      uar_get_code_display(ce.event_cd)),
     "|",trim(substring(1,100,s_temp_result_val),3),"||","   QUERY2 IVIEW"),
    s_temp_result_val = trim(ce.result_val), b_found_nomen = false, s_temp_nome_result = ""
    IF (size(transaction->transactions[trans_cnt].trans_string,1) > string_size)
     string_size = size(transaction->transactions[trans_cnt].trans_string,1)
    ENDIF
   FOOT REPORT
    stat = alterlist(transaction->transactions,trans_cnt), transaction->trans_qual_cnt = trans_cnt
   WITH nocounter, expand = 1
  ;end select
 ENDIF
 IF (lab_include="Y")
  SELECT INTO "NL:"
   FROM clinical_event ce,
    order_catalog oc,
    orders o
   PLAN (ce
    WHERE expand(e_idx,1,drec->encntr_qual_cnt,ce.encntr_id,drec->encntr_qual[e_idx].encntr_id)
     AND ce.clinsig_updt_dt_tm BETWEEN cnvtdatetime(begin_dt_tm) AND cnvtdatetime(end_dt_tm)
     AND ce.event_end_dt_tm != null
     AND ce.result_val > " "
     AND ce.result_status_cd IN (34_mod_status_cd, 34_auth_status_cd, 34_alt_status_cd)
     AND ce.valid_until_dt_tm > cnvtdatetime(sysdate)
     AND ce.publish_flag=1.00)
    JOIN (o
    WHERE ce.order_id=o.order_id)
    JOIN (oc
    WHERE ce.catalog_cd=oc.catalog_cd
     AND oc.catalog_type_cd=6000_generallab_cd
     AND oc.dcp_clin_cat_cd=16389_lab_clin_cat_cd)
   ORDER BY ce.clinsig_updt_dt_tm, ce.event_id
   HEAD REPORT
    trans_cnt = size(transaction->transactions,5), stat = alterlist(transaction->transactions,(
     trans_cnt+ 1000))
   HEAD ce.clinsig_updt_dt_tm
    null
   HEAD ce.event_id
    s_temp_result_val = "", pos = locateval(num,1,drec->encntr_qual_cnt,ce.encntr_id,drec->
     encntr_qual[num].encntr_id)
    WHILE (pos != 0)
     alias = drec->encntr_qual[pos].fin_id,pos = locateval(num,(pos+ 1),drec->encntr_qual_cnt,ce
      .encntr_id,drec->encntr_qual[num].encntr_id)
    ENDWHILE
    trans_cnt += 1
    IF (mod(trans_cnt,1000)=1)
     stat = alterlist(transaction->transactions,(trans_cnt+ 1000))
    ENDIF
    transaction->transactions[trans_cnt].dta_cd = ce.task_assay_cd, transaction->transactions[
    trans_cnt].result_val = trim(ce.result_val,3), transaction->transactions[trans_cnt].trans_string
     = build2(trim(format(ce.event_end_dt_tm,"YYYYMMDD|HHMM;;Q")),"|",alias,"|",trim(
      uar_get_code_display(ce.event_cd)),
     "|","|")
   FOOT  ce.event_id
    IF (isnumeric(ce.normal_low) != 0
     AND isnumeric(ce.normal_high) != 0)
     IF (cnvtreal(ce.normal_low) > cnvtreal(ce.result_val))
      transaction->transactions[trans_cnt].trans_string = build2(transaction->transactions[trans_cnt]
       .trans_string,"L")
      IF (uar_get_code_description(ce.normalcy_cd) IN ("Extreme Low", "Panic Low", "Critical"))
       transaction->transactions[trans_cnt].trans_string = build2(transaction->transactions[trans_cnt
        ].trans_string,"L")
      ENDIF
     ELSEIF (cnvtreal(ce.result_val) >= cnvtreal(ce.normal_low)
      AND cnvtreal(ce.result_val) <= cnvtreal(ce.normal_high))
      transaction->transactions[trans_cnt].trans_string = build2(transaction->transactions[trans_cnt]
       .trans_string,"N")
     ELSEIF (cnvtreal(ce.normal_high) < cnvtreal(ce.result_val))
      transaction->transactions[trans_cnt].trans_string = build2(transaction->transactions[trans_cnt]
       .trans_string,"H")
      IF (uar_get_code_description(ce.normalcy_cd) IN ("Extreme High", "Panic High", "Critical"))
       transaction->transactions[trans_cnt].trans_string = build2(transaction->transactions[trans_cnt
        ].trans_string,"H")
      ENDIF
     ENDIF
    ELSE
     transaction->transactions[trans_cnt].trans_string = build2(transaction->transactions[trans_cnt].
      trans_string)
    ENDIF
    transaction->transactions[trans_cnt].trans_string = build2(transaction->transactions[trans_cnt].
     trans_string,"||"), transaction->transactions[trans_cnt].trans_string = replace(transaction->
     transactions[trans_cnt].trans_string,char(13),""), transaction->transactions[trans_cnt].
    trans_string = replace(transaction->transactions[trans_cnt].trans_string,char(10),""),
    transaction->transactions[trans_cnt].trans_string = build2(transaction->transactions[trans_cnt].
     trans_string,"||","QUERY3 Labs")
    IF (size(transaction->transactions[trans_cnt].trans_string,1) > string_size)
     string_size = size(transaction->transactions[trans_cnt].trans_string,1)
    ENDIF
   FOOT  ce.clinsig_updt_dt_tm
    null
   FOOT REPORT
    stat = alterlist(transaction->transactions,trans_cnt), transaction->trans_qual_cnt = trans_cnt
   WITH nocounter, expand = 1
  ;end select
 ENDIF
 IF (iv_include="Y")
  SELECT INTO "nl:"
   ocs2.mnemonic, ce1.parent_event_id, ce1.event_id,
   ce1.event_title_text, ce1.event_tag, dosage =
   IF (cnvtreal(ce1.result_val) > 0.00) format(cnvtreal(ce1.result_val),"########.##")
   ELSE format(cem.initial_dosage,"########.##")
   ENDIF
   ,
   dosage_units =
   IF (cnvtreal(ce1.result_val) > 0.00) uar_get_code_display(ce1.result_units_cd)
   ELSE uar_get_code_display(cem.dosage_unit_cd)
   ENDIF
   FROM clinical_event ce,
    order_detail od,
    clinical_event ce1,
    ce_med_result cem,
    order_catalog_synonym ocs,
    order_catalog_synonym ocs2
   PLAN (ce
    WHERE expand(e_idx,1,drec->encntr_qual_cnt,ce.encntr_id,drec->encntr_qual[e_idx].encntr_id)
     AND ce.clinsig_updt_dt_tm BETWEEN cnvtdatetime(begin_dt_tm) AND cnvtdatetime(end_dt_tm)
     AND ce.result_status_cd IN (34_mod_status_cd, 34_auth_status_cd, 34_alt_status_cd)
     AND ce.valid_until_dt_tm > cnvtdatetime(sysdate)
     AND ce.publish_flag=1.00)
    JOIN (ce1
    WHERE ce.event_id=ce1.event_id)
    JOIN (od
    WHERE (od.order_id= Outerjoin(ce1.order_id))
     AND (od.oe_field_meaning= Outerjoin("RXROUTE"))
     AND ((od.oe_field_display_value="IV*") OR (((cnvtupper(od.oe_field_display_value)="*INFUSION*")
     OR (cnvtupper(od.oe_field_display_value)="PCA*")) )) )
    JOIN (cem
    WHERE ce1.event_id=cem.event_id)
    JOIN (ocs
    WHERE cem.synonym_id=ocs.synonym_id)
    JOIN (ocs2
    WHERE ocs.catalog_cd=ocs2.catalog_cd
     AND ocs2.mnemonic_type_cd=6011_primary_cd
     AND ocs2.catalog_type_cd=6000_pharmacy_cd)
   ORDER BY ce1.parent_event_id, ce1.event_id
   HEAD ce1.event_id
    trans_cnt += 1, stat = alterlist(transaction->transactions,trans_cnt), pos = locateval(num,1,drec
     ->encntr_qual_cnt,ce.encntr_id,drec->encntr_qual[num].encntr_id)
    WHILE (pos != 0)
     alias = drec->encntr_qual[pos].fin_id,pos = locateval(num,(pos+ 1),drec->encntr_qual_cnt,ce
      .encntr_id,drec->encntr_qual[num].encntr_id)
    ENDWHILE
    transaction->transactions[trans_cnt].trans_string = build2(trim(format(ce.event_end_dt_tm,
       "YYYYMMDD|HHMM;;Q"),3),"|",alias,"|",trim(ocs2.mnemonic),
     "|",trim(dosage,3),"||","  Query4 ",trim(od.oe_field_display_value))
   FOOT REPORT
    stat = alterlist(transaction->transactions,trans_cnt), transaction->trans_qual_cnt = trans_cnt
   WITH nocounter, expand = 1
  ;end select
 ENDIF
 IF (bb_include="Y")
  SELECT INTO "NL:"
   FROM clinical_event ce
   PLAN (ce
    WHERE expand(e_idx,1,drec->encntr_qual_cnt,ce.encntr_id,drec->encntr_qual[e_idx].encntr_id)
     AND ce.clinsig_updt_dt_tm BETWEEN cnvtdatetime(begin_dt_tm) AND cnvtdatetime(end_dt_tm)
     AND ce.event_class_cd IN (53_event_txt_cd, 53_event_num_cd)
     AND expand(bcnt,1,cv_extension->qual[1].cv_cnt,ce.event_cd,cv_extension->qual[1].qual[bcnt].
     code_value)
     AND ce.event_end_dt_tm != null
     AND textlen(trim(ce.result_val,3)) != 0
     AND ce.result_status_cd IN (34_mod_status_cd, 34_auth_status_cd, 34_alt_status_cd)
     AND ce.valid_until_dt_tm > cnvtdatetime(sysdate)
     AND ce.publish_flag=1.00
     AND ce.ce_dynamic_label_id=0.00)
   ORDER BY ce.clinsig_updt_dt_tm, ce.event_id
   HEAD REPORT
    trans_cnt = size(transaction->transactions,5), stat = alterlist(transaction->transactions,(
     trans_cnt+ 1000))
   HEAD ce.clinsig_updt_dt_tm
    null
   HEAD ce.event_id
    pos = locateval(num,1,drec->encntr_qual_cnt,ce.encntr_id,drec->encntr_qual[num].encntr_id)
    WHILE (pos != 0)
     alias = drec->encntr_qual[pos].fin_id,pos = locateval(num,(pos+ 1),drec->encntr_qual_cnt,ce
      .encntr_id,drec->encntr_qual[num].encntr_id)
    ENDWHILE
    trans_cnt += 1
    IF (mod(trans_cnt,1000)=1)
     stat = alterlist(transaction->transactions,(trans_cnt+ 1000))
    ENDIF
    transaction->transactions[trans_cnt].dta_cd = ce.task_assay_cd, transaction->transactions[
    trans_cnt].result_val = trim(ce.result_val,3), transaction->transactions[trans_cnt].trans_string
     = build2(trim(format(ce.event_end_dt_tm,"YYYYMMDD|HHMM;;Q"),3),"|",alias,"|",trim(substring(1,50,
       trim(uar_get_code_display(ce.event_cd),3)),3),
     "|"),
    s_temp_result_val = trim(ce.result_val,3)
   FOOT  ce.event_id
    s_temp_result_val = trim(replace(s_temp_result_val,",","",0),3), transaction->transactions[
    trans_cnt].trans_string = build2(transaction->transactions[trans_cnt].trans_string,trim(
      s_temp_result_val,3),"|"), transaction->transactions[trans_cnt].trans_string = build2(
     transaction->transactions[trans_cnt].trans_string,"||","QUERY5 BLOOD PRODUCTS")
    IF (size(transaction->transactions[trans_cnt].trans_string,1) > string_size)
     string_size = size(transaction->transactions[trans_cnt].trans_string,1)
    ENDIF
   FOOT  ce.clinsig_updt_dt_tm
    null
   FOOT REPORT
    stat = alterlist(transaction->transactions,trans_cnt), transaction->trans_qual_cnt = trans_cnt
   WITH nocounter, expand = 1
  ;end select
 ENDIF
 SET frec->file_name = filewrite
 SET frec->file_buf = "w"
 SET stat = cclio("OPEN",frec)
 IF (stat > 0
  AND (transaction->trans_qual_cnt > 0))
  FOR (x = 1 TO transaction->trans_qual_cnt)
    SET output_string = notrim(check(substring(1,string_size,trim(transaction->transactions[x].
        trans_string))))
    SET output_string = replace(output_string,char(0),"")
    SET output_string = replace(output_string,char(10),"")
    SET output_string = replace(output_string,char(13),"")
    SET frec->file_buf = concat(trim(output_string),carriage_return,line_feed)
    SET stat = cclio("WRITE",frec)
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
   current_dttm = cnvtdatetime(sysdate),
   CALL print(format(current_dttm,"MM/DD/YYYY HH:MM;;Q")), row + 1,
   CALL print(build2("Clairvia Clinical Documentation Extract (",trim(curprog),") node:",curnode)),
   row + 1,
   CALL print(build2("Date Range: ",format(begin_dt_tm,";;q")," to ",format(end_dt_tm,";;q"))),
   row + 1
   IF ((transaction->trans_qual_cnt > 0))
    CALL print(build2("Extract file written to: ",trim(filewrite,3)," The file should contain ",trim(
      cnvtstringchk(transaction->trans_qual_cnt),3)," records."))
   ELSE
    CALL print("No qualifying data found.")
   ENDIF
  WITH nocounter, maxcol = 10000, separator = " ",
   format = variable, maxrow = 1
 ;end select
 IF ((transaction->trans_qual_cnt=0))
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "No Data Qualified"
 ELSE
  SET reply->status_data.status = "S"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = build("Qualified this many rows: ",
   transaction->trans_qual_cnt)
 ENDIF
 SET last_mod = "002  7/23/18  Jason Mullinnix    Update ftp location"
END GO
