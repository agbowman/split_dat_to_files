CREATE PROGRAM clairvia_clin_doc_br_standard:dba
 PROMPT
  "Printer" = "MINE",
  "FACILITY" = 0,
  "Start DD-MMM-YYYY HH:MM" = "",
  "End   DD-MMM-YYYY HH:MM" = "",
  "Bedrock Prefs Facility" = 0
  WITH outdev, facility, startdttm,
  enddttm, bedrock_facility
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
     2 person_id = f8
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
 RECORD br_prefs(
   1 report_location = vc
   1 report_name = vc
   1 fin_format = vc
   1 include_iview_ind = i2
   1 iview_events_cnt = i4
   1 iview_events[*]
     2 event_cd = f8
   1 include_labs_ind = i2
   1 lab_events_cnt = i4
   1 lab_events[*]
     2 event_cd = f8
   1 include_iv_ind = i2
   1 iv_ingredient_cnt = i4
   1 iv_ingredients[*]
     2 catalog_cd = f8
   1 include_bb_ind = i2
   1 bb_events_cnt = i4
   1 bb_events[*]
     2 event_cd = f8
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
   CALL clear_dminfo(null)
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
   CALL clear_dminfo(null)
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
   CALL clear_dminfo(null)
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
   CALL clear_dminfo(null)
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
   CALL clear_dminfo(null)
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
 SUBROUTINE clear_dminfo(null)
   IF (currev=8)
    SET stat = initrec(atg_dminfo_reqi)
    SET stat = initrec(atg_dminfo_reqw)
    SET stat = initrec(atg_dminfo_reqd)
   ELSE
    SET stat = alterlist(atg_dminfo_reqi->qual,0)
    SET atg_dminfo_reqi->allow_partial_ind = 0
    SET atg_dminfo_reqi->info_domaini = 0
    SET atg_dminfo_reqi->info_namei = 0
    SET atg_dminfo_reqi->info_datei = 0
    SET atg_dminfo_reqi->info_daten = 0
    SET atg_dminfo_reqi->info_chari = 0
    SET atg_dminfo_reqi->info_charn = 0
    SET atg_dminfo_reqi->info_numberi = 0
    SET atg_dminfo_reqi->info_numbern = 0
    SET atg_dminfo_reqi->info_long_idi = 0
    SET stat = alterlist(atg_dminfo_reqw->qual,0)
    SET atg_dminfo_reqw->allow_partial_ind = 0
    SET atg_dminfo_reqw->force_updt_ind = 0
    SET atg_dminfo_reqw->info_domainw = 0
    SET atg_dminfo_reqw->info_namew = 0
    SET atg_dminfo_reqw->info_datew = 0
    SET atg_dminfo_reqw->info_charw = 0
    SET atg_dminfo_reqw->info_numberw = 0
    SET atg_dminfo_reqw->info_long_idw = 0
    SET atg_dminfo_reqw->updt_applctxw = 0
    SET atg_dminfo_reqw->updt_dt_tmw = 0
    SET atg_dminfo_reqw->updt_cntw = 0
    SET atg_dminfo_reqw->updt_idw = 0
    SET atg_dminfo_reqw->updt_taskw = 0
    SET atg_dminfo_reqw->info_domainf = 0
    SET atg_dminfo_reqw->info_namef = 0
    SET atg_dminfo_reqw->info_datef = 0
    SET atg_dminfo_reqw->info_charf = 0
    SET atg_dminfo_reqw->info_numberf = 0
    SET atg_dminfo_reqw->info_long_idf = 0
    SET atg_dminfo_reqw->updt_cntf = 0
    SET stat = alterlist(atg_dminfo_reqd->qual,0)
    SET atg_dminfo_reqd->allow_partial_ind = 0
    SET atg_dminfo_reqd->info_domainw = 0
    SET atg_dminfo_reqd->info_namew = 0
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
 DECLARE end_dt_tm = dq8 WITH constant(parsedatepromptwithcurtime3( $ENDDTTM)), protect
 DECLARE dm_save_date = dq8 WITH public, noconstant(cnvtdatetime(end_dt_tm))
 DECLARE s_temp_result_val = vc WITH protect
 DECLARE b_found_nomen = i2 WITH protect, noconstant(false)
 DECLARE s_temp_nome_result = vc WITH protect
 DECLARE s_temp_mnemonic = vc WITH protect
 DECLARE num = i2 WITH protect, constant(0)
 DECLARE string_size = i4 WITH protect, noconstant(0)
 DECLARE output_string = vc WITH protect
 DECLARE msg_1 = vc WITH protect
 DECLARE msg_2 = vc WITH protect
 DECLARE alias = vc WITH protect
 DECLARE parent_flow_rate = vc WITH protect
 DECLARE bb_include = vc WITH protect
 DECLARE ivi_include = vc WITH protect
 DECLARE lab_include = vc WITH protect
 DECLARE iv_include = vc WITH protect
 DECLARE codesetloc = vc WITH protect
 DECLARE fin_format = vc WITH protect
 DECLARE manual_run_flag = i2 WITH protect, noconstant(0)
 DECLARE datediff = f8 WITH protect, noconstant(0.0)
 DECLARE e_idx = i4 WITH public, noconstant(0)
 DECLARE bcnt = i4 WITH public, noconstant(0)
 DECLARE fin_ind = i2 WITH protect, noconstant(0)
 DECLARE ld_mnemonic = vc WITH protect
 DECLARE nidx = i4 WITH protect, noconstant(0)
 DECLARE nfilterpos = i4 WITH protect, noconstant(0)
 DECLARE nvalidx = i4 WITH protect, noconstant(0)
 DECLARE fileloc = vc WITH protect, noconstant(trim(logical("cer_temp"),3))
 DECLARE filename = vc WITH protect
 DECLARE mnemonic = vc WITH protect
 DECLARE filewrite = vc WITH protect
 DECLARE carriage_return = c1 WITH constant(char(13))
 DECLARE line_feed = c1 WITH constant(char(10))
 DECLARE fac_parser = vc WITH protect, noconstant("0=1")
 SUBROUTINE parsedatepromptwithcurtime3(date_str)
   DECLARE _return_val = dq8 WITH noconstant(0.0), private
   DECLARE _date = i4 WITH constant(_parsedate(date_str)), private
   IF (_date=0.0)
    SET _return_val = cnvtdatetime(curdate,curtime3)
   ELSE
    SET _return_val = cnvtdatetime(_date,curtime3)
   ENDIF
   RETURN(_return_val)
 END ;Subroutine
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
 CALL loadbedrockfreetextvalue("FIN_FORMAT","ALPHA",br_prefs->fin_format)
 CALL loadbedrockfreetextvalue("INCLUDE_IVIEW","INTEGER",br_prefs->include_iview_ind)
 CALL loadbedrockfreetextvalue("INCLUDE_LABS","INTEGER",br_prefs->include_labs_ind)
 CALL loadbedrockfreetextvalue("INCLUDE_IV","INTEGER",br_prefs->include_iv_ind)
 CALL loadbedrockfreetextvalue("INCLUDE_BB","INTEGER",br_prefs->include_bb_ind)
 SET nfilterpos = locateval(nidx,1,size(filter->filters,5),"IVIEW_CLIN_EVENTS",filter->filters[nidx].
  fileventmean)
 SET nvalsize = size(filter->filters[nfilterpos].values,5)
 SET br_prefs->iview_events_cnt = nvalsize
 SET stat = alterlist(br_prefs->iview_events,br_prefs->iview_events_cnt)
 FOR (nvalidx = 1 TO br_prefs->iview_events_cnt)
   SET br_prefs->iview_events[nvalidx].event_cd = filter->filters[nfilterpos].values[nvalidx].
   valeventcd
 ENDFOR
 SET nfilterpos = locateval(nidx,1,size(filter->filters,5),"LAB_RESULTS",filter->filters[nidx].
  fileventmean)
 SET nvalsize = size(filter->filters[nfilterpos].values,5)
 SET br_prefs->lab_events_cnt = nvalsize
 SET stat = alterlist(br_prefs->lab_events,br_prefs->lab_events_cnt)
 FOR (nvalidx = 1 TO br_prefs->lab_events_cnt)
   SET br_prefs->lab_events[nvalidx].event_cd = filter->filters[nfilterpos].values[nvalidx].
   valeventcd
 ENDFOR
 SET nfilterpos = locateval(nidx,1,size(filter->filters,5),"IV_ORDERS",filter->filters[nidx].
  fileventmean)
 SET nvalsize = size(filter->filters[nfilterpos].values,5)
 SET br_prefs->iv_ingredient_cnt = nvalsize
 SET stat = alterlist(br_prefs->iv_ingredients,br_prefs->iv_ingredient_cnt)
 FOR (nvalidx = 1 TO br_prefs->iv_ingredient_cnt)
   SET br_prefs->iv_ingredients[nvalidx].catalog_cd = filter->filters[nfilterpos].values[nvalidx].
   valeventcd
 ENDFOR
 SET nfilterpos = locateval(nidx,1,size(filter->filters,5),"BB_EVENTS",filter->filters[nidx].
  fileventmean)
 SET nvalsize = size(filter->filters[nfilterpos].values,5)
 SET br_prefs->bb_events_cnt = nvalsize
 SET stat = alterlist(br_prefs->bb_events,br_prefs->bb_events_cnt)
 FOR (nvalidx = 1 TO br_prefs->bb_events_cnt)
   SET br_prefs->bb_events[nvalidx].event_cd = filter->filters[nfilterpos].values[nvalidx].valeventcd
 ENDFOR
 IF (textlen(trim(br_prefs->report_name,3)) > 0)
  SET filename = build2("CLAIRVIA_CLIN_DOC_",trim(br_prefs->report_name,3),"_",format(curdate,
    "mmddyyyy;;d"),"_",
   format(curtime3,"hhmmss;3;m"),".txt")
 ELSE
  SET filename = build2("CLAIRVIA_CLIN_DOC_",format(curdate,"mmddyyyy;;d"),"_",format(curtime3,
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
 IF (textlen(trim(br_prefs->fin_format,3))=0)
  SET fin_ind = 0
 ELSE
  SET fin_ind = 1
  SET fin_format = concat(trim(br_prefs->fin_format,3),";P0")
 ENDIF
 IF (((ispromptempty(3)) OR (ispromptempty(4))) )
  SET begin_dt_tm = get_dminfo_date("CCPS",build(curprog,"_",trim(cnvtupper(curdomain)),"_",trim(
     cnvtupper(br_prefs->report_name))))
  IF (cnvtint(begin_dt_tm)=0)
   SET begin_dt_tm = cnvtdatetime(curdate,curtime3)
   SET dm_save_dt = cnvtdatetime(curdate,curtime3)
   SET reply->status_data.status = "S"
   SET reply->ops_event = concat("Initial run for ",trim(cnvtupper(br_prefs->report_name)))
   GO TO exit_script
  ENDIF
 ELSE
  SET manual_run_flag = 1
  SET datediff = datetimediff(end_dt_tm,begin_dt_tm,3)
  IF (((cnvtint(begin_dt_tm)=0) OR (cnvtint(end_dt_tm)=0)) )
   SET msg_2 = build2("Invalid Date Range.  Enter valid dates and date range of up to 48 hours.  ",
    " Start: ",format(begin_dt_tm,"dd-mm-yyyy hh:mm;;d")," End: ",format(end_dt_tm,
     "dd-mm-yyyy hh:mm;;d"),
    " Hours: ",datediff)
   GO TO exit_script
  ENDIF
 ENDIF
 CALL echo(build(";manual_run_flag-->",manual_run_flag))
 SELECT INTO "nl:"
  FROM encntr_domain ed,
   encounter e,
   encntr_alias ea
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
   JOIN (ea
   WHERE ea.encntr_id=outerjoin(e.encntr_id)
    AND ea.encntr_alias_type_cd=outerjoin(319_fin_cd)
    AND ea.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3))
    AND ea.active_ind=outerjoin(1))
  ORDER BY e.encntr_id
  HEAD REPORT
   drec->encntr_qual_cnt = 0
  HEAD e.encntr_id
   drec->encntr_qual_cnt = (drec->encntr_qual_cnt+ 1)
   IF (mod(drec->encntr_qual_cnt,1000)=1)
    stat = alterlist(drec->encntr_qual,(drec->encntr_qual_cnt+ 999))
   ENDIF
   drec->encntr_qual[drec->encntr_qual_cnt].person_id = e.person_id, drec->encntr_qual[drec->
   encntr_qual_cnt].encntr_id = e.encntr_id
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
 CALL echo(build(";# of Patients-->",drec->encntr_qual_cnt))
 IF ((br_prefs->include_iview_ind=1)
  AND (br_prefs->iview_events_cnt > 0)
  AND (drec->encntr_qual_cnt > 0))
  SELECT INTO "nl:"
   FROM encounter e,
    clinical_event ce,
    (left JOIN ce_coded_result ccr ON ce.event_id=ccr.event_id
     AND ccr.valid_until_dt_tm > cnvtdatetime(curdate,curtime3)),
    (left JOIN nomenclature n ON n.nomenclature_id=ccr.nomenclature_id)
   PLAN (e
    WHERE expand(e_idx,1,drec->encntr_qual_cnt,e.encntr_id,drec->encntr_qual[e_idx].encntr_id))
    JOIN (ce
    WHERE expand(e_idx,1,br_prefs->iview_events_cnt,ce.event_cd,br_prefs->iview_events[e_idx].
     event_cd)
     AND ce.person_id=e.person_id
     AND ce.encntr_id=e.encntr_id
     AND ce.clinsig_updt_dt_tm BETWEEN cnvtdatetime(begin_dt_tm) AND cnvtdatetime(end_dt_tm)
     AND ce.event_class_cd IN (53_event_txt_cd, 53_event_num_cd, 53_date_class_cd)
     AND ce.performed_dt_tm != null
     AND ce.event_end_dt_tm != null
     AND ce.result_val > " "
     AND ce.result_status_cd IN (34_mod_status_cd, 34_auth_status_cd, 34_alt_status_cd)
     AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime3)
     AND ce.publish_flag=1)
    JOIN (ccr)
    JOIN (n)
   ORDER BY ce.ce_dynamic_label_id, ce.clinsig_updt_dt_tm, ce.event_id,
    ccr.sequence_nbr
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
    trans_cnt = (trans_cnt+ 1)
    IF (mod(trans_cnt,1000)=1)
     stat = alterlist(transaction->transactions,(trans_cnt+ 1000))
    ENDIF
    transaction->transactions[trans_cnt].dta_cd = ce.task_assay_cd, transaction->transactions[
    trans_cnt].result_val = trim(ce.result_val,3), transaction->transactions[trans_cnt].trans_string
     = build2(trim(format(ce.event_end_dt_tm,"YYYYMMDD|HHMM;;Q")),"|",alias,"|",trim(
      uar_get_code_display(ce.event_cd)),
     "|"),
    s_temp_result_val = trim(ce.result_val), b_found_nomen = false, s_temp_nome_result = ""
   HEAD ccr.sequence_nbr
    IF (n.nomenclature_id > 0.0)
     b_found_nomen = true, s_temp_result_val = replace(s_temp_result_val,trim(n.short_string),"",1)
     IF (textlen(trim(s_temp_nome_result,3)) > 0)
      s_temp_nome_result = substring(1,1000,build2(s_temp_nome_result,";",trim(n.source_string,3)))
     ELSE
      s_temp_nome_result = substring(1,1000,trim(n.source_string,3))
     ENDIF
    ENDIF
   FOOT  ce.event_id
    IF (ce.event_class_cd=53_date_class_cd)
     s_temp_result_val = concat(substring(7,2,ce.result_val),"/",substring(9,2,ce.result_val),"/",
      substring(3,4,ce.result_val),
      " ",substring(11,2,ce.result_val),":",substring(13,2,ce.result_val))
    ELSEIF (ce.event_class_cd=53_event_txt_cd
     AND n.nomenclature_id=0.0)
     IF (ce.view_level=1)
      s_temp_result_val = replace(ce.result_val,",",";"), s_temp_result_val = replace(
       s_temp_result_val,"; ",";")
     ENDIF
    ENDIF
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
      transaction->transactions[trans_cnt].trans_string = build2(transaction->transactions[trans_cnt]
       .trans_string,"L")
      IF (uar_get_code_meaning(ce.normalcy_cd) IN ("EXTREMELOW", "PANICLOW", "CRITICAL"))
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
      IF (uar_get_code_description(ce.normalcy_cd) IN ("EXTREMEHIGH", "PANICHIGH", "CRITICAL"))
       transaction->transactions[trans_cnt].trans_string = build2(transaction->transactions[trans_cnt
        ].trans_string,"H")
      ENDIF
     ENDIF
    ELSE
     transaction->transactions[trans_cnt].trans_string = build2(transaction->transactions[trans_cnt].
      trans_string)
    ENDIF
    transaction->transactions[trans_cnt].trans_string = build2(transaction->transactions[trans_cnt].
     trans_string,"|","QUERY1")
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
 CALL echo(build("Include Labs?-->",br_prefs->include_labs_ind))
 IF ((br_prefs->include_labs_ind=1)
  AND (br_prefs->lab_events_cnt > 0)
  AND (drec->encntr_qual_cnt > 0))
  SELECT INTO "NL:"
   FROM encounter e,
    clinical_event ce
   PLAN (e
    WHERE expand(e_idx,1,drec->encntr_qual_cnt,e.encntr_id,drec->encntr_qual[e_idx].encntr_id))
    JOIN (ce
    WHERE e.person_id=ce.person_id
     AND e.encntr_id=ce.encntr_id
     AND expand(e_idx,1,br_prefs->lab_events_cnt,ce.event_cd,br_prefs->lab_events[e_idx].event_cd)
     AND ce.clinsig_updt_dt_tm BETWEEN cnvtdatetime(begin_dt_tm) AND cnvtdatetime(end_dt_tm)
     AND ce.event_end_dt_tm != null
     AND textlen(trim(ce.result_val,3)) > 0
     AND ce.result_status_cd IN (34_mod_status_cd, 34_auth_status_cd, 34_alt_status_cd)
     AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime3)
     AND ce.publish_flag=1)
   ORDER BY ce.clinsig_updt_dt_tm, ce.event_id
   HEAD REPORT
    trans_cnt = size(transaction->transactions,5), stat = alterlist(transaction->transactions,(
     trans_cnt+ 1000))
   HEAD ce.clinsig_updt_dt_tm
    null
   HEAD ce.event_id
    s_temp_result_val = "", pos = locateval(num,1,drec->encntr_qual_cnt,e.encntr_id,drec->
     encntr_qual[num].encntr_id)
    WHILE (pos != 0)
     alias = drec->encntr_qual[pos].fin_id,pos = locateval(num,(pos+ 1),drec->encntr_qual_cnt,ce
      .encntr_id,drec->encntr_qual[num].encntr_id)
    ENDWHILE
    trans_cnt = (trans_cnt+ 1)
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
      IF (uar_get_code_meaning(ce.normalcy_cd) IN ("EXTREMELOW", "PANICLOW", "CRITICAL"))
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
      IF (uar_get_code_description(ce.normalcy_cd) IN ("EXTREMEHIGH", "PANICHIGH", "CRITICAL"))
       transaction->transactions[trans_cnt].trans_string = build2(transaction->transactions[trans_cnt
        ].trans_string,"H")
      ENDIF
     ENDIF
    ENDIF
    transaction->transactions[trans_cnt].trans_string = replace(transaction->transactions[trans_cnt].
     trans_string,char(13),""), transaction->transactions[trans_cnt].trans_string = replace(
     transaction->transactions[trans_cnt].trans_string,char(10),""), transaction->transactions[
    trans_cnt].trans_string = build2(transaction->transactions[trans_cnt].trans_string,"|",
     "QUERY3 Labs")
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
 IF ((br_prefs->include_iv_ind=1)
  AND (br_prefs->iv_ingredient_cnt > 0)
  AND (drec->encntr_qual_cnt > 0))
  SELECT INTO "nl:"
   dosage =
   IF (cnvtreal(ce1.result_val) > 0.00) format(cnvtreal(ce1.result_val),"########.##")
   ELSE format(cem.initial_dosage,"########.##")
   ENDIF
   , dosage_units =
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
    WHERE expand(e_idx,1,drec->encntr_qual_cnt,ce.encntr_id,drec->encntr_qual[e_idx].encntr_id,
     ce.person_id,drec->encntr_qual[e_idx].person_id)
     AND ce.clinsig_updt_dt_tm BETWEEN cnvtdatetime(begin_dt_tm) AND cnvtdatetime(end_dt_tm)
     AND ce.result_status_cd IN (34_mod_status_cd, 34_auth_status_cd, 34_alt_status_cd)
     AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime3)
     AND ce.publish_flag=1)
    JOIN (ce1
    WHERE ce.event_id=ce1.event_id
     AND ce1.valid_until_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (od
    WHERE outerjoin(ce1.order_id)=od.order_id
     AND outerjoin("RXROUTE")=od.oe_field_meaning
     AND ((od.oe_field_display_value="*IV*") OR (((cnvtupper(od.oe_field_display_value)="*INFUSION*")
     OR (cnvtupper(od.oe_field_display_value)="PCA*")) )) )
    JOIN (cem
    WHERE ce1.event_id=cem.event_id)
    JOIN (ocs
    WHERE cem.synonym_id=ocs.synonym_id
     AND expand(e_idx,1,br_prefs->iv_ingredient_cnt,ocs.catalog_cd,br_prefs->iv_ingredients[e_idx].
     catalog_cd))
    JOIN (ocs2
    WHERE ocs.catalog_cd=ocs2.catalog_cd
     AND ocs2.mnemonic_type_cd=6011_primary_cd
     AND ocs2.catalog_type_cd=6000_pharmacy_cd)
   ORDER BY ce1.parent_event_id, ce1.event_id
   HEAD ce1.event_id
    trans_cnt = (trans_cnt+ 1), stat = alterlist(transaction->transactions,trans_cnt), pos =
    locateval(num,1,drec->encntr_qual_cnt,ce.encntr_id,drec->encntr_qual[num].encntr_id)
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
 IF ((br_prefs->include_bb_ind=1)
  AND (br_prefs->bb_events_cnt > 0)
  AND (drec->encntr_qual_cnt > 0))
  SELECT INTO "NL:"
   FROM encounter e,
    clinical_event ce
   PLAN (e
    WHERE expand(e_idx,1,drec->encntr_qual_cnt,e.encntr_id,drec->encntr_qual[e_idx].encntr_id))
    JOIN (ce
    WHERE e.person_id=ce.person_id
     AND e.encntr_id=ce.encntr_id
     AND expand(e_idx,1,br_prefs->bb_events_cnt,ce.event_cd,br_prefs->bb_events[e_idx].event_cd)
     AND ce.clinsig_updt_dt_tm BETWEEN cnvtdatetime(begin_dt_tm) AND cnvtdatetime(end_dt_tm)
     AND ce.event_class_cd IN (53_event_txt_cd, 53_event_num_cd)
     AND ce.event_end_dt_tm != null
     AND textlen(trim(ce.result_val,3)) != 0
     AND ce.result_status_cd IN (34_mod_status_cd, 34_auth_status_cd, 34_alt_status_cd)
     AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime3)
     AND ce.publish_flag=1
     AND ce.ce_dynamic_label_id=0.00)
   ORDER BY ce.clinsig_updt_dt_tm, ce.event_id
   HEAD REPORT
    trans_cnt = size(transaction->transactions,5), stat = alterlist(transaction->transactions,(
     trans_cnt+ 1000))
   HEAD ce.clinsig_updt_dt_tm
    null
   HEAD ce.event_id
    pos = locateval(e_idx,1,drec->encntr_qual_cnt,e.encntr_id,drec->encntr_qual[e_idx].encntr_id)
    WHILE (pos != 0)
     alias = drec->encntr_qual[pos].fin_id,pos = locateval(num,(pos+ 1),drec->encntr_qual_cnt,ce
      .encntr_id,drec->encntr_qual[num].encntr_id)
    ENDWHILE
    trans_cnt = (trans_cnt+ 1)
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
     transaction->transactions[trans_cnt].trans_string,"|","QUERY5 BLOOD PRODUCTS")
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
   current_dttm = cnvtdatetime(curdate,curtime3),
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
 IF (manual_run_flag=0)
  CALL set_dminfo_date("CCPS",build(curprog,"_",trim(cnvtupper(curdomain)),"_",trim(cnvtupper(
      br_prefs->report_name))),dm_save_date)
 ENDIF
 IF ((transaction->trans_qual_cnt=0))
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "No Data Qualified"
 ELSE
  SET reply->status_data.status = "S"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = build("Qualified this many rows: ",
   transaction->trans_qual_cnt)
 ENDIF
 SET last_mod = "004 09/17/2019 MK6280 Added Bedrock Preferences"
END GO
