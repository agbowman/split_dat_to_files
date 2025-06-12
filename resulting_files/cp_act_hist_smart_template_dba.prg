CREATE PROGRAM cp_act_hist_smart_template:dba
 DECLARE log_program_name = vc WITH protect, noconstant("")
 DECLARE log_override_ind = i2 WITH protect, noconstant(0)
 SET log_program_name = curprog
 SET log_override_ind = 0
 DECLARE log_level_error = i2 WITH protect, noconstant(0)
 DECLARE log_level_warning = i2 WITH protect, noconstant(1)
 DECLARE log_level_audit = i2 WITH protect, noconstant(2)
 DECLARE log_level_info = i2 WITH protect, noconstant(3)
 DECLARE log_level_debug = i2 WITH protect, noconstant(4)
 DECLARE hsys = i4 WITH protect, noconstant(0)
 DECLARE sysstat = i4 WITH protect, noconstant(0)
 DECLARE serrmsg = c132 WITH protect, noconstant(" ")
 DECLARE ierrcode = i4 WITH protect, noconstant(error(serrmsg,1))
 DECLARE crsl_msg_default = i4 WITH protect, noconstant(0)
 DECLARE crsl_msg_level = i4 WITH protect, noconstant(0)
 EXECUTE msgrtl
 SET crsl_msg_default = uar_msgdefhandle()
 SET crsl_msg_level = uar_msggetlevel(crsl_msg_default)
 DECLARE lcrslsubeventcnt = i4 WITH protect, noconstant(0)
 DECLARE icrslloggingstat = i2 WITH protect, noconstant(0)
 DECLARE lcrslsubeventsize = i4 WITH protect, noconstant(0)
 DECLARE icrslloglvloverrideind = i2 WITH protect, noconstant(0)
 DECLARE scrsllogtext = vc WITH protect, noconstant("")
 DECLARE scrsllogevent = vc WITH protect, noconstant("")
 DECLARE icrslholdloglevel = i2 WITH protect, noconstant(0)
 DECLARE icrslerroroccured = i2 WITH protect, noconstant(0)
 DECLARE lcrsluarmsgwritestat = i4 WITH protect, noconstant(0)
 DECLARE crsl_info_domain = vc WITH protect, constant("DISCERNABU SCRIPT LOGGING")
 DECLARE crsl_logging_on = c1 WITH protect, constant("L")
 IF (((logical("MP_LOGGING_ALL") > " ") OR (logical(concat("MP_LOGGING_",log_program_name)) > " ")) )
  SET log_override_ind = 1
 ENDIF
 SUBROUTINE (log_message(logmsg=vc,loglvl=i4) =null)
   SET icrslloglvloverrideind = 0
   SET scrsllogtext = ""
   SET scrsllogevent = ""
   SET scrsllogtext = concat("{{Script::",value(log_program_name),"}} ",logmsg)
   IF (log_override_ind=0)
    SET icrslholdloglevel = loglvl
   ELSE
    IF (crsl_msg_level < loglvl)
     SET icrslholdloglevel = crsl_msg_level
     SET icrslloglvloverrideind = 1
    ELSE
     SET icrslholdloglevel = loglvl
    ENDIF
   ENDIF
   IF (icrslloglvloverrideind=1)
    SET scrsllogevent = "Script_Override"
   ELSE
    CASE (icrslholdloglevel)
     OF log_level_error:
      SET scrsllogevent = "Script_Error"
     OF log_level_warning:
      SET scrsllogevent = "Script_Warning"
     OF log_level_audit:
      SET scrsllogevent = "Script_Audit"
     OF log_level_info:
      SET scrsllogevent = "Script_Info"
     OF log_level_debug:
      SET scrsllogevent = "Script_Debug"
    ENDCASE
   ENDIF
   SET lcrsluarmsgwritestat = uar_msgwrite(crsl_msg_default,0,nullterm(scrsllogevent),
    icrslholdloglevel,nullterm(scrsllogtext))
   CALL echo(logmsg)
 END ;Subroutine
 SUBROUTINE (error_message(logstatusblockind=i2) =i2)
   SET icrslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET icrslerroroccured = 1
     IF (validate(reply))
      SET reply->status_data.status = "F"
     ENDIF
     CALL log_message(serrmsg,log_level_audit)
     IF (logstatusblockind=1)
      IF (validate(reply))
       CALL populate_subeventstatus("EXECUTE","F","CCL SCRIPT",serrmsg)
      ENDIF
     ENDIF
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   RETURN(icrslerroroccured)
 END ;Subroutine
 SUBROUTINE (error_and_zero_check_rec(qualnum=i4,opname=vc,logmsg=vc,errorforceexit=i2,zeroforceexit=
  i2,recorddata=vc(ref)) =i2)
   SET icrslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET icrslerroroccured = 1
     CALL log_message(serrmsg,log_level_audit)
     CALL populate_subeventstatus_rec(opname,"F",serrmsg,logmsg,recorddata)
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   IF (icrslerroroccured=1
    AND errorforceexit=1)
    SET recorddata->status_data.status = "F"
    GO TO exit_script
   ENDIF
   IF (qualnum=0
    AND zeroforceexit=1)
    SET recorddata->status_data.status = "Z"
    CALL populate_subeventstatus_rec(opname,"Z","No records qualified",logmsg,recorddata)
    GO TO exit_script
   ENDIF
   RETURN(icrslerroroccured)
 END ;Subroutine
 SUBROUTINE (error_and_zero_check(qualnum=i4,opname=vc,logmsg=vc,errorforceexit=i2,zeroforceexit=i2
  ) =i2)
   RETURN(error_and_zero_check_rec(qualnum,opname,logmsg,errorforceexit,zeroforceexit,
    reply))
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus_rec(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),recorddata=vc(ref)) =i2)
   IF (validate(recorddata->status_data.status,"-1") != "-1")
    SET lcrslsubeventcnt = size(recorddata->status_data.subeventstatus,5)
    SET lcrslsubeventsize = size(trim(recorddata->status_data.subeventstatus[lcrslsubeventcnt].
      operationname))
    SET lcrslsubeventsize += size(trim(recorddata->status_data.subeventstatus[lcrslsubeventcnt].
      operationstatus))
    SET lcrslsubeventsize += size(trim(recorddata->status_data.subeventstatus[lcrslsubeventcnt].
      targetobjectname))
    SET lcrslsubeventsize += size(trim(recorddata->status_data.subeventstatus[lcrslsubeventcnt].
      targetobjectvalue))
    IF (lcrslsubeventsize > 0)
     SET lcrslsubeventcnt += 1
     SET icrslloggingstat = alter(recorddata->status_data.subeventstatus,lcrslsubeventcnt)
    ENDIF
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt].operationname = substring(1,25,
     operationname)
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt].operationstatus = substring(1,1,
     operationstatus)
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt].targetobjectname = substring(1,25,
     targetobjectname)
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt].targetobjectvalue =
    targetobjectvalue
   ENDIF
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value)) =i2)
   CALL populate_subeventstatus_rec(operationname,operationstatus,targetobjectname,targetobjectvalue,
    reply)
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus_msg(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),loglevel=i2(value)) =i2)
  CALL populate_subeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
  CALL log_message(targetobjectvalue,loglevel)
 END ;Subroutine
 SUBROUTINE (check_log_level(arg_log_level=i4) =i2)
   IF (((crsl_msg_level >= arg_log_level) OR (log_override_ind=1)) )
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 DECLARE current_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), protect
 DECLARE current_time_zone = i4 WITH constant(datetimezonebyname(curtimezone)), protect
 DECLARE ending_date_time = dq8 WITH constant(cnvtdatetime("31-DEC-2100")), protect
 DECLARE bind_cnt = i4 WITH constant(50), protect
 DECLARE lower_bound_date = vc WITH constant("01-JAN-1800 00:00:00.00"), protect
 DECLARE upper_bound_date = vc WITH constant("31-DEC-2100 23:59:59.99"), protect
 DECLARE codelistcnt = i4 WITH noconstant(0), protect
 DECLARE prsnllistcnt = i4 WITH noconstant(0), protect
 DECLARE phonelistcnt = i4 WITH noconstant(0), protect
 DECLARE code_idx = i4 WITH noconstant(0), protect
 DECLARE prsnl_idx = i4 WITH noconstant(0), protect
 DECLARE phone_idx = i4 WITH noconstant(0), protect
 DECLARE prsnl_cnt = i4 WITH noconstant(0), protect
 DECLARE mpc_ap_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mpc_doc_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mpc_mdoc_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mpc_rad_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mpc_txt_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mpc_num_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mpc_immun_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mpc_med_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mpc_date_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mpc_done_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mpc_mbo_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mpc_procedure_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mpc_grp_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mpc_hlatyping_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE eventclasscdpopulated = i2 WITH protect, noconstant(0)
 DECLARE getorgsecurityflag(null) = i2 WITH protect
 DECLARE cclimpersonation(null) = null WITH protect
 SUBROUTINE (addcodetolist(code_value=f8(val),record_data=vc(ref)) =null WITH protect)
   IF (code_value != 0)
    IF (((codelistcnt=0) OR (locateval(code_idx,1,codelistcnt,code_value,record_data->codes[code_idx]
     .code) <= 0)) )
     SET codelistcnt += 1
     SET stat = alterlist(record_data->codes,codelistcnt)
     SET record_data->codes[codelistcnt].code = code_value
     SET record_data->codes[codelistcnt].sequence = uar_get_collation_seq(code_value)
     SET record_data->codes[codelistcnt].meaning = uar_get_code_meaning(code_value)
     SET record_data->codes[codelistcnt].display = uar_get_code_display(code_value)
     SET record_data->codes[codelistcnt].description = uar_get_code_description(code_value)
     SET record_data->codes[codelistcnt].code_set = uar_get_code_set(code_value)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (outputcodelist(record_data=vc(ref)) =null WITH protect)
   CALL log_message("In OutputCodeList() @deprecated",log_level_debug)
 END ;Subroutine
 SUBROUTINE (addpersonneltolist(prsnl_id=f8(val),record_data=vc(ref)) =null WITH protect)
   CALL addpersonneltolistwithdate(prsnl_id,record_data,current_date_time)
 END ;Subroutine
 SUBROUTINE (addpersonneltolistwithdate(prsnl_id=f8(val),record_data=vc(ref),active_date=f8(val)) =
  null WITH protect)
   DECLARE personnel_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",213,"PRSNL"))
   IF (((active_date=null) OR (active_date=0.0)) )
    SET active_date = current_date_time
   ENDIF
   IF (prsnl_id != 0)
    IF (((prsnllistcnt=0) OR (locateval(prsnl_idx,1,prsnllistcnt,prsnl_id,record_data->prsnl[
     prsnl_idx].id,
     active_date,record_data->prsnl[prsnl_idx].active_date) <= 0)) )
     SET prsnllistcnt += 1
     IF (prsnllistcnt > size(record_data->prsnl,5))
      SET stat = alterlist(record_data->prsnl,(prsnllistcnt+ 9))
     ENDIF
     SET record_data->prsnl[prsnllistcnt].id = prsnl_id
     IF (validate(record_data->prsnl[prsnllistcnt].active_date) != 0)
      SET record_data->prsnl[prsnllistcnt].active_date = active_date
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (outputpersonnellist(report_data=vc(ref)) =null WITH protect)
   CALL log_message("In OutputPersonnelList()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE prsnl_name_type_cd = f8 WITH constant(uar_get_code_by("MEANING",213,"PRSNL")), protect
   DECLARE active_date_ind = i2 WITH protect, noconstant(0)
   DECLARE filteredcnt = i4 WITH protect, noconstant(0)
   DECLARE prsnl_seq = i4 WITH protect, noconstant(0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   IF (prsnllistcnt > 0)
    SELECT INTO "nl:"
     FROM prsnl p,
      (left JOIN person_name pn ON pn.person_id=p.person_id
       AND pn.name_type_cd=prsnl_name_type_cd
       AND pn.active_ind=1)
     PLAN (p
      WHERE expand(idx,1,size(report_data->prsnl,5),p.person_id,report_data->prsnl[idx].id))
      JOIN (pn)
     ORDER BY p.person_id, pn.end_effective_dt_tm DESC
     HEAD REPORT
      prsnl_seq = 0, active_date_ind = validate(report_data->prsnl[1].active_date,0)
     HEAD p.person_id
      IF (active_date_ind=0)
       prsnl_seq = locateval(idx,1,prsnllistcnt,p.person_id,report_data->prsnl[idx].id)
       IF (pn.person_id > 0)
        report_data->prsnl[prsnl_seq].provider_name.name_full = trim(pn.name_full,3), report_data->
        prsnl[prsnl_seq].provider_name.name_first = trim(pn.name_first,3), report_data->prsnl[
        prsnl_seq].provider_name.name_middle = trim(pn.name_middle,3),
        report_data->prsnl[prsnl_seq].provider_name.name_last = trim(pn.name_last,3), report_data->
        prsnl[prsnl_seq].provider_name.username = trim(p.username,3), report_data->prsnl[prsnl_seq].
        provider_name.initials = trim(pn.name_initials,3),
        report_data->prsnl[prsnl_seq].provider_name.title = trim(pn.name_initials,3)
       ELSE
        report_data->prsnl[prsnl_seq].provider_name.name_full = trim(p.name_full_formatted,3),
        report_data->prsnl[prsnl_seq].provider_name.name_first = trim(p.name_first,3), report_data->
        prsnl[prsnl_seq].provider_name.name_last = trim(p.name_last,3),
        report_data->prsnl[prsnl_seq].provider_name.username = trim(p.username,3)
       ENDIF
      ENDIF
     DETAIL
      IF (active_date_ind != 0)
       prsnl_seq = locateval(idx,1,prsnllistcnt,p.person_id,report_data->prsnl[idx].id)
       WHILE (prsnl_seq > 0)
        IF ((report_data->prsnl[prsnl_seq].active_date BETWEEN pn.beg_effective_dt_tm AND pn
        .end_effective_dt_tm))
         IF (pn.person_id > 0)
          report_data->prsnl[prsnl_seq].person_name_id = pn.person_name_id, report_data->prsnl[
          prsnl_seq].beg_effective_dt_tm = pn.beg_effective_dt_tm, report_data->prsnl[prsnl_seq].
          end_effective_dt_tm = pn.end_effective_dt_tm,
          report_data->prsnl[prsnl_seq].provider_name.name_full = trim(pn.name_full,3), report_data->
          prsnl[prsnl_seq].provider_name.name_first = trim(pn.name_first,3), report_data->prsnl[
          prsnl_seq].provider_name.name_middle = trim(pn.name_middle,3),
          report_data->prsnl[prsnl_seq].provider_name.name_last = trim(pn.name_last,3), report_data->
          prsnl[prsnl_seq].provider_name.username = trim(p.username,3), report_data->prsnl[prsnl_seq]
          .provider_name.initials = trim(pn.name_initials,3),
          report_data->prsnl[prsnl_seq].provider_name.title = trim(pn.name_initials,3)
         ELSE
          report_data->prsnl[prsnl_seq].provider_name.name_full = trim(p.name_full_formatted,3),
          report_data->prsnl[prsnl_seq].provider_name.name_first = trim(p.name_first,3), report_data
          ->prsnl[prsnl_seq].provider_name.name_last = trim(pn.name_last,3),
          report_data->prsnl[prsnl_seq].provider_name.username = trim(p.username,3)
         ENDIF
         IF ((report_data->prsnl[prsnl_seq].active_date=current_date_time))
          report_data->prsnl[prsnl_seq].active_date = 0
         ENDIF
        ENDIF
        ,prsnl_seq = locateval(idx,(prsnl_seq+ 1),prsnllistcnt,p.person_id,report_data->prsnl[idx].id
         )
       ENDWHILE
      ENDIF
     FOOT REPORT
      stat = alterlist(report_data->prsnl,prsnllistcnt)
     WITH nocounter
    ;end select
    CALL error_and_zero_check_rec(curqual,"PRSNL","OutputPersonnelList",1,0,
     report_data)
    IF (active_date_ind != 0)
     SELECT INTO "nl:"
      end_effective_dt_tm = report_data->prsnl[d.seq].end_effective_dt_tm, person_name_id =
      report_data->prsnl[d.seq].person_name_id, prsnl_id = report_data->prsnl[d.seq].id
      FROM (dummyt d  WITH seq = size(report_data->prsnl,5))
      ORDER BY end_effective_dt_tm DESC, person_name_id, prsnl_id
      HEAD REPORT
       filteredcnt = 0, idx = size(report_data->prsnl,5), stat = alterlist(report_data->prsnl,(idx *
        2))
      HEAD end_effective_dt_tm
       donothing = 0
      HEAD prsnl_id
       idx += 1, filteredcnt += 1, report_data->prsnl[idx].id = report_data->prsnl[d.seq].id,
       report_data->prsnl[idx].person_name_id = report_data->prsnl[d.seq].person_name_id
       IF ((report_data->prsnl[d.seq].person_name_id > 0.0))
        report_data->prsnl[idx].beg_effective_dt_tm = report_data->prsnl[d.seq].beg_effective_dt_tm,
        report_data->prsnl[idx].end_effective_dt_tm = report_data->prsnl[d.seq].end_effective_dt_tm
       ELSE
        report_data->prsnl[idx].beg_effective_dt_tm = cnvtdatetime("01-JAN-1900"), report_data->
        prsnl[idx].end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
       ENDIF
       report_data->prsnl[idx].provider_name.name_full = report_data->prsnl[d.seq].provider_name.
       name_full, report_data->prsnl[idx].provider_name.name_first = report_data->prsnl[d.seq].
       provider_name.name_first, report_data->prsnl[idx].provider_name.name_middle = report_data->
       prsnl[d.seq].provider_name.name_middle,
       report_data->prsnl[idx].provider_name.name_last = report_data->prsnl[d.seq].provider_name.
       name_last, report_data->prsnl[idx].provider_name.username = report_data->prsnl[d.seq].
       provider_name.username, report_data->prsnl[idx].provider_name.initials = report_data->prsnl[d
       .seq].provider_name.initials,
       report_data->prsnl[idx].provider_name.title = report_data->prsnl[d.seq].provider_name.title
      FOOT REPORT
       stat = alterlist(report_data->prsnl,idx), stat = alterlist(report_data->prsnl,filteredcnt,0)
      WITH nocounter
     ;end select
     CALL error_and_zero_check_rec(curqual,"PRSNL","FilterPersonnelList",1,0,
      report_data)
    ENDIF
   ENDIF
   CALL log_message(build("Exit OutputPersonnelList(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (addphonestolist(prsnl_id=f8(val),record_data=vc(ref)) =null WITH protect)
   IF (prsnl_id != 0)
    IF (((phonelistcnt=0) OR (locateval(phone_idx,1,phonelistcnt,prsnl_id,record_data->phone_list[
     prsnl_idx].person_id) <= 0)) )
     SET phonelistcnt += 1
     IF (phonelistcnt > size(record_data->phone_list,5))
      SET stat = alterlist(record_data->phone_list,(phonelistcnt+ 9))
     ENDIF
     SET record_data->phone_list[phonelistcnt].person_id = prsnl_id
     SET prsnl_cnt += 1
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (outputphonelist(report_data=vc(ref),phone_types=vc(ref)) =null WITH protect)
   CALL log_message("In OutputPhoneList()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE personcnt = i4 WITH protect, constant(size(report_data->phone_list,5))
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE idx2 = i4 WITH protect, noconstant(0)
   DECLARE idx3 = i4 WITH protect, noconstant(0)
   DECLARE phonecnt = i4 WITH protect, noconstant(0)
   DECLARE prsnlidx = i4 WITH protect, noconstant(0)
   IF (phonelistcnt > 0)
    SELECT
     IF (size(phone_types->phone_codes,5)=0)
      phone_sorter = ph.phone_id
      FROM phone ph
      WHERE expand(idx,1,personcnt,ph.parent_entity_id,report_data->phone_list[idx].person_id)
       AND ph.parent_entity_name="PERSON"
       AND ph.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND ph.end_effective_dt_tm >= cnvtdatetime(sysdate)
       AND ph.active_ind=1
       AND ph.phone_type_seq=1
      ORDER BY ph.parent_entity_id, phone_sorter
     ELSE
      phone_sorter = locateval(idx2,1,size(phone_types->phone_codes,5),ph.phone_type_cd,phone_types->
       phone_codes[idx2].phone_cd)
      FROM phone ph
      WHERE expand(idx,1,personcnt,ph.parent_entity_id,report_data->phone_list[idx].person_id)
       AND ph.parent_entity_name="PERSON"
       AND ph.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND ph.end_effective_dt_tm >= cnvtdatetime(sysdate)
       AND ph.active_ind=1
       AND expand(idx2,1,size(phone_types->phone_codes,5),ph.phone_type_cd,phone_types->phone_codes[
       idx2].phone_cd)
       AND ph.phone_type_seq=1
      ORDER BY ph.parent_entity_id, phone_sorter
     ENDIF
     INTO "nl:"
     HEAD ph.parent_entity_id
      phonecnt = 0, prsnlidx = locateval(idx3,1,personcnt,ph.parent_entity_id,report_data->
       phone_list[idx3].person_id)
     HEAD phone_sorter
      phonecnt += 1
      IF (size(report_data->phone_list[prsnlidx].phones,5) < phonecnt)
       stat = alterlist(report_data->phone_list[prsnlidx].phones,(phonecnt+ 5))
      ENDIF
      report_data->phone_list[prsnlidx].phones[phonecnt].phone_id = ph.phone_id, report_data->
      phone_list[prsnlidx].phones[phonecnt].phone_type_cd = ph.phone_type_cd, report_data->
      phone_list[prsnlidx].phones[phonecnt].phone_type = uar_get_code_display(ph.phone_type_cd),
      report_data->phone_list[prsnlidx].phones[phonecnt].phone_num = formatphonenumber(ph.phone_num,
       ph.phone_format_cd,ph.extension)
     FOOT  ph.parent_entity_id
      stat = alterlist(report_data->phone_list[prsnlidx].phones,phonecnt)
     WITH nocounter, expand = value(evaluate(floor(((personcnt - 1)/ 30)),0,0,1))
    ;end select
    SET stat = alterlist(report_data->phone_list,prsnl_cnt)
    CALL error_and_zero_check_rec(curqual,"PHONE","OutputPhoneList",1,0,
     report_data)
   ENDIF
   CALL log_message(build("Exit OutputPhoneList(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (putstringtofile(svalue=vc(val)) =null WITH protect)
   CALL log_message("In PutStringToFile()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   IF (validate(_memory_reply_string)=1)
    SET _memory_reply_string = svalue
   ELSE
    FREE RECORD putrequest
    RECORD putrequest(
      1 source_dir = vc
      1 source_filename = vc
      1 nbrlines = i4
      1 line[*]
        2 linedata = vc
      1 overflowpage[*]
        2 ofr_qual[*]
          3 ofr_line = vc
      1 isblob = c1
      1 document_size = i4
      1 document = gvc
    )
    SET putrequest->source_dir =  $OUTDEV
    SET putrequest->isblob = "1"
    SET putrequest->document = svalue
    SET putrequest->document_size = size(putrequest->document)
    EXECUTE eks_put_source  WITH replace("REQUEST",putrequest), replace("REPLY",putreply)
   ENDIF
   CALL log_message(build("Exit PutStringToFile(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (putunboundedstringtofile(trec=vc(ref)) =null WITH protect)
   CALL log_message("In PutUnboundedStringToFile()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE curstringlength = i4 WITH noconstant(textlen(trec->val))
   DECLARE newmaxvarlen = i4 WITH noconstant(0)
   DECLARE origcurmaxvarlen = i4 WITH noconstant(0)
   IF (curstringlength > curmaxvarlen)
    SET origcurmaxvarlen = curmaxvarlen
    SET newmaxvarlen = (curstringlength+ 10000)
    SET modify maxvarlen newmaxvarlen
   ENDIF
   CALL putstringtofile(trec->val)
   IF (newmaxvarlen > 0)
    SET modify maxvarlen origcurmaxvarlen
   ENDIF
   CALL log_message(build("Exit PutUnboundedStringToFile(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (putjsonrecordtofile(record_data=vc(ref)) =null WITH protect)
   CALL log_message("In PutJSONRecordToFile()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   RECORD _tempjson(
     1 val = gvc
   )
   SET _tempjson->val = cnvtrectojson(record_data)
   CALL putunboundedstringtofile(_tempjson)
   CALL log_message(build("Exit PutJSONRecordToFile(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (getparametervalues(index=i4(val),value_rec=vc(ref)) =null WITH protect)
   DECLARE par = vc WITH noconstant(""), protect
   DECLARE lnum = i4 WITH noconstant(0), protect
   DECLARE num = i4 WITH noconstant(1), protect
   DECLARE cnt = i4 WITH noconstant(0), protect
   DECLARE cnt2 = i4 WITH noconstant(0), protect
   DECLARE param_value = f8 WITH noconstant(0.0), protect
   DECLARE param_value_str = vc WITH noconstant(""), protect
   SET par = reflect(parameter(index,0))
   IF (validate(debug_ind,0)=1)
    CALL echo(par)
   ENDIF
   IF (((par="F8") OR (par="I4")) )
    SET param_value = parameter(index,0)
    IF (param_value > 0)
     SET value_rec->cnt += 1
     SET stat = alterlist(value_rec->qual,value_rec->cnt)
     SET value_rec->qual[value_rec->cnt].value = param_value
    ENDIF
   ELSEIF (substring(1,1,par)="C")
    SET param_value_str = parameter(index,0)
    IF (trim(param_value_str,3) != "")
     SET value_rec->cnt += 1
     SET stat = alterlist(value_rec->qual,value_rec->cnt)
     SET value_rec->qual[value_rec->cnt].value = trim(param_value_str,3)
    ENDIF
   ELSEIF (substring(1,1,par)="L")
    SET lnum = 1
    WHILE (lnum > 0)
     SET par = reflect(parameter(index,lnum))
     IF (par != " ")
      IF (((par="F8") OR (par="I4")) )
       SET param_value = parameter(index,lnum)
       IF (param_value > 0)
        SET value_rec->cnt += 1
        SET stat = alterlist(value_rec->qual,value_rec->cnt)
        SET value_rec->qual[value_rec->cnt].value = param_value
       ENDIF
       SET lnum += 1
      ELSEIF (substring(1,1,par)="C")
       SET param_value_str = parameter(index,lnum)
       IF (trim(param_value_str,3) != "")
        SET value_rec->cnt += 1
        SET stat = alterlist(value_rec->qual,value_rec->cnt)
        SET value_rec->qual[value_rec->cnt].value = trim(param_value_str,3)
       ENDIF
       SET lnum += 1
      ENDIF
     ELSE
      SET lnum = 0
     ENDIF
    ENDWHILE
   ENDIF
   IF (validate(debug_ind,0)=1)
    CALL echorecord(value_rec)
   ENDIF
 END ;Subroutine
 SUBROUTINE (getlookbackdatebytype(units=i4(val),flag=i4(val)) =dq8 WITH protect)
   DECLARE looback_date = dq8 WITH noconstant(cnvtdatetime("01-JAN-1800 00:00:00"))
   IF (units != 0)
    CASE (flag)
     OF 1:
      SET looback_date = cnvtlookbehind(build(units,",H"),cnvtdatetime(sysdate))
     OF 2:
      SET looback_date = cnvtlookbehind(build(units,",D"),cnvtdatetime(sysdate))
     OF 3:
      SET looback_date = cnvtlookbehind(build(units,",W"),cnvtdatetime(sysdate))
     OF 4:
      SET looback_date = cnvtlookbehind(build(units,",M"),cnvtdatetime(sysdate))
     OF 5:
      SET looback_date = cnvtlookbehind(build(units,",Y"),cnvtdatetime(sysdate))
    ENDCASE
   ENDIF
   RETURN(looback_date)
 END ;Subroutine
 SUBROUTINE (getcodevaluesfromcodeset(evt_set_rec=vc(ref),evt_cd_rec=vc(ref)) =null WITH protect)
  DECLARE csidx = i4 WITH noconstant(0)
  SELECT DISTINCT INTO "nl:"
   FROM v500_event_set_explode vese
   WHERE expand(csidx,1,evt_set_rec->cnt,vese.event_set_cd,evt_set_rec->qual[csidx].value)
   DETAIL
    evt_cd_rec->cnt += 1, stat = alterlist(evt_cd_rec->qual,evt_cd_rec->cnt), evt_cd_rec->qual[
    evt_cd_rec->cnt].value = vese.event_cd
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE (geteventsetnamesfromeventsetcds(evt_set_rec=vc(ref),evt_set_name_rec=vc(ref)) =null
  WITH protect)
   DECLARE index = i4 WITH protect, noconstant(0)
   DECLARE pos = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM v500_event_set_code v
    WHERE expand(index,1,evt_set_rec->cnt,v.event_set_cd,evt_set_rec->qual[index].value)
    HEAD REPORT
     cnt = 0, evt_set_name_rec->cnt = evt_set_rec->cnt, stat = alterlist(evt_set_name_rec->qual,
      evt_set_rec->cnt)
    DETAIL
     pos = locateval(index,1,evt_set_rec->cnt,v.event_set_cd,evt_set_rec->qual[index].value)
     WHILE (pos > 0)
       cnt += 1, evt_set_name_rec->qual[pos].value = v.event_set_name, pos = locateval(index,(pos+ 1),
        evt_set_rec->cnt,v.event_set_cd,evt_set_rec->qual[index].value)
     ENDWHILE
    FOOT REPORT
     pos = locateval(index,1,evt_set_name_rec->cnt,"",evt_set_name_rec->qual[index].value)
     WHILE (pos > 0)
       evt_set_name_rec->cnt -= 1, stat = alterlist(evt_set_name_rec->qual,evt_set_name_rec->cnt,(pos
         - 1)), pos = locateval(index,pos,evt_set_name_rec->cnt,"",evt_set_name_rec->qual[index].
        value)
     ENDWHILE
     evt_set_name_rec->cnt = cnt, stat = alterlist(evt_set_name_rec->qual,evt_set_name_rec->cnt)
    WITH nocounter, expand = value(evaluate(floor(((evt_set_rec->cnt - 1)/ 30)),0,0,1))
   ;end select
 END ;Subroutine
 SUBROUTINE (returnviewertype(eventclasscd=f8(val),eventid=f8(val)) =vc WITH protect)
   CALL log_message("In returnViewerType()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   IF (eventclasscdpopulated=0)
    SET mpc_ap_type_cd = uar_get_code_by("MEANING",53,"AP")
    SET mpc_doc_type_cd = uar_get_code_by("MEANING",53,"DOC")
    SET mpc_mdoc_type_cd = uar_get_code_by("MEANING",53,"MDOC")
    SET mpc_rad_type_cd = uar_get_code_by("MEANING",53,"RAD")
    SET mpc_txt_type_cd = uar_get_code_by("MEANING",53,"TXT")
    SET mpc_num_type_cd = uar_get_code_by("MEANING",53,"NUM")
    SET mpc_immun_type_cd = uar_get_code_by("MEANING",53,"IMMUN")
    SET mpc_med_type_cd = uar_get_code_by("MEANING",53,"MED")
    SET mpc_date_type_cd = uar_get_code_by("MEANING",53,"DATE")
    SET mpc_done_type_cd = uar_get_code_by("MEANING",53,"DONE")
    SET mpc_mbo_type_cd = uar_get_code_by("MEANING",53,"MBO")
    SET mpc_procedure_type_cd = uar_get_code_by("MEANING",53,"PROCEDURE")
    SET mpc_grp_type_cd = uar_get_code_by("MEANING",53,"GRP")
    SET mpc_hlatyping_type_cd = uar_get_code_by("MEANING",53,"HLATYPING")
    SET eventclasscdpopulated = 1
   ENDIF
   DECLARE sviewerflag = vc WITH protect, noconstant("")
   CASE (eventclasscd)
    OF mpc_ap_type_cd:
     SET sviewerflag = "AP"
    OF mpc_doc_type_cd:
    OF mpc_mdoc_type_cd:
    OF mpc_rad_type_cd:
     SET sviewerflag = "DOC"
    OF mpc_txt_type_cd:
    OF mpc_num_type_cd:
    OF mpc_immun_type_cd:
    OF mpc_med_type_cd:
    OF mpc_date_type_cd:
    OF mpc_done_type_cd:
     SET sviewerflag = "EVENT"
    OF mpc_mbo_type_cd:
     SET sviewerflag = "MICRO"
    OF mpc_procedure_type_cd:
     SET sviewerflag = "PROC"
    OF mpc_grp_type_cd:
     SET sviewerflag = "GRP"
    OF mpc_hlatyping_type_cd:
     SET sviewerflag = "HLA"
    ELSE
     SET sviewerflag = "STANDARD"
   ENDCASE
   IF (eventclasscd=mpc_mdoc_type_cd)
    SELECT INTO "nl:"
     c2.*
     FROM clinical_event c1,
      clinical_event c2
     PLAN (c1
      WHERE c1.event_id=eventid)
      JOIN (c2
      WHERE c1.parent_event_id=c2.event_id
       AND c2.valid_until_dt_tm=cnvtdatetime("31-DEC-2100"))
     HEAD c2.event_id
      IF (c2.event_class_cd=mpc_ap_type_cd)
       sviewerflag = "AP"
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   CALL log_message(build("Exit returnViewerType(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
   RETURN(sviewerflag)
 END ;Subroutine
 SUBROUTINE (cnvtisodttmtodq8(isodttmstr=vc) =dq8 WITH protect)
   DECLARE converteddq8 = dq8 WITH protect, noconstant(0)
   SET converteddq8 = cnvtdatetimeutc2(substring(1,10,isodttmstr),"YYYY-MM-DD",substring(12,8,
     isodttmstr),"HH:MM:SS",4,
    curtimezonedef)
   RETURN(converteddq8)
 END ;Subroutine
 SUBROUTINE (cnvtdq8toisodttm(dq8dttm=f8) =vc WITH protect)
   DECLARE convertedisodttm = vc WITH protect, noconstant("")
   IF (dq8dttm > 0.0)
    SET convertedisodttm = build(replace(datetimezoneformat(cnvtdatetime(dq8dttm),datetimezonebyname(
        "UTC"),"yyyy-MM-dd HH:mm:ss",curtimezonedef)," ","T",1),"Z")
   ELSE
    SET convertedisodttm = nullterm(convertedisodttm)
   ENDIF
   RETURN(convertedisodttm)
 END ;Subroutine
 SUBROUTINE getorgsecurityflag(null)
   DECLARE org_security_flag = i2 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="SECURITY"
     AND di.info_name="SEC_ORG_RELTN"
    HEAD REPORT
     org_security_flag = 0
    DETAIL
     org_security_flag = cnvtint(di.info_number)
    WITH nocounter
   ;end select
   RETURN(org_security_flag)
 END ;Subroutine
 SUBROUTINE (getcomporgsecurityflag(dminfo_name=vc(val)) =i2 WITH protect)
   DECLARE org_security_flag = i2 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="SECURITY"
     AND di.info_name=dminfo_name
    HEAD REPORT
     org_security_flag = 0
    DETAIL
     org_security_flag = cnvtint(di.info_number)
    WITH nocounter
   ;end select
   RETURN(org_security_flag)
 END ;Subroutine
 SUBROUTINE (populateauthorizedorganizations(personid=f8(val),value_rec=vc(ref)) =null WITH protect)
   DECLARE organization_cnt = i4 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM prsnl_org_reltn por
    WHERE por.person_id=personid
     AND por.active_ind=1
     AND por.beg_effective_dt_tm BETWEEN cnvtdatetime(lower_bound_date) AND cnvtdatetime(sysdate)
     AND por.end_effective_dt_tm BETWEEN cnvtdatetime(sysdate) AND cnvtdatetime(upper_bound_date)
    ORDER BY por.organization_id
    HEAD REPORT
     organization_cnt = 0
    DETAIL
     organization_cnt += 1
     IF (mod(organization_cnt,20)=1)
      stat = alterlist(value_rec->organizations,(organization_cnt+ 19))
     ENDIF
     value_rec->organizations[organization_cnt].organizationid = por.organization_id
    FOOT REPORT
     value_rec->cnt = organization_cnt, stat = alterlist(value_rec->organizations,organization_cnt)
    WITH nocounter
   ;end select
   IF (validate(debug_ind,0)=1)
    CALL echorecord(value_rec)
   ENDIF
 END ;Subroutine
 SUBROUTINE (getuserlogicaldomain(id=f8) =f8 WITH protect)
   DECLARE returnid = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    FROM prsnl p
    WHERE p.person_id=id
    DETAIL
     returnid = p.logical_domain_id
    WITH nocounter
   ;end select
   RETURN(returnid)
 END ;Subroutine
 SUBROUTINE (getpersonneloverride(ppr_cd=f8(val)) =i2 WITH protect)
   DECLARE override_ind = i2 WITH protect, noconstant(0)
   IF (ppr_cd <= 0.0)
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    FROM code_value_extension cve
    WHERE cve.code_value=ppr_cd
     AND cve.code_set=331
     AND ((cve.field_value="1") OR (cve.field_value="2"))
     AND cve.field_name="Override"
    DETAIL
     override_ind = 1
    WITH nocounter
   ;end select
   RETURN(override_ind)
 END ;Subroutine
 SUBROUTINE cclimpersonation(null)
   CALL log_message("In cclImpersonation()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   EXECUTE secrtl
   DECLARE uar_secsetcontext(hctx=i4) = i2 WITH image_axp = "secrtl", image_aix =
   "libsec.a(libsec.o)", uar = "SecSetContext",
   persist
   DECLARE seccntxt = i4 WITH public
   DECLARE namelen = i4 WITH public
   DECLARE domainnamelen = i4 WITH public
   SET namelen = (uar_secgetclientusernamelen()+ 1)
   SET domainnamelen = (uar_secgetclientdomainnamelen()+ 2)
   SET stat = memalloc(name,1,build("C",namelen))
   SET stat = memalloc(domainname,1,build("C",domainnamelen))
   SET stat = uar_secgetclientusername(name,namelen)
   SET stat = uar_secgetclientdomainname(domainname,domainnamelen)
   SET setcntxt = uar_secimpersonate(nullterm(name),nullterm(domainname))
   CALL log_message(build("Exit cclImpersonation(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (geteventsetdisplaysfromeventsetcds(evt_set_rec=vc(ref),evt_set_disp_rec=vc(ref)) =null
  WITH protect)
   DECLARE index = i4 WITH protect, noconstant(0)
   DECLARE pos = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM v500_event_set_code v
    WHERE expand(index,1,evt_set_rec->cnt,v.event_set_cd,evt_set_rec->qual[index].value)
    HEAD REPORT
     cnt = 0, evt_set_disp_rec->cnt = evt_set_rec->cnt, stat = alterlist(evt_set_disp_rec->qual,
      evt_set_rec->cnt)
    DETAIL
     pos = locateval(index,1,evt_set_rec->cnt,v.event_set_cd,evt_set_rec->qual[index].value)
     WHILE (pos > 0)
       cnt += 1, evt_set_disp_rec->qual[pos].value = v.event_set_cd_disp, pos = locateval(index,(pos
        + 1),evt_set_rec->cnt,v.event_set_cd,evt_set_rec->qual[index].value)
     ENDWHILE
    FOOT REPORT
     pos = locateval(index,1,evt_set_disp_rec->cnt,"",evt_set_disp_rec->qual[index].value)
     WHILE (pos > 0)
       evt_set_disp_rec->cnt -= 1, stat = alterlist(evt_set_disp_rec->qual,evt_set_disp_rec->cnt,(pos
         - 1)), pos = locateval(index,pos,evt_set_disp_rec->cnt,"",evt_set_disp_rec->qual[index].
        value)
     ENDWHILE
     evt_set_disp_rec->cnt = cnt, stat = alterlist(evt_set_disp_rec->qual,evt_set_disp_rec->cnt)
    WITH nocounter, expand = value(evaluate(floor(((evt_set_rec->cnt - 1)/ 30)),0,0,1))
   ;end select
 END ;Subroutine
 SUBROUTINE (decodestringparameter(description=vc(val)) =vc WITH protect)
   DECLARE decodeddescription = vc WITH private
   SET decodeddescription = replace(description,"%3B",";",0)
   SET decodeddescription = replace(decodeddescription,"%25","%",0)
   RETURN(decodeddescription)
 END ;Subroutine
 SUBROUTINE (urlencode(json=vc(val)) =vc WITH protect)
   DECLARE encodedjson = vc WITH private
   SET encodedjson = replace(json,char(91),"%5B",0)
   SET encodedjson = replace(encodedjson,char(123),"%7B",0)
   SET encodedjson = replace(encodedjson,char(58),"%3A",0)
   SET encodedjson = replace(encodedjson,char(125),"%7D",0)
   SET encodedjson = replace(encodedjson,char(93),"%5D",0)
   SET encodedjson = replace(encodedjson,char(44),"%2C",0)
   SET encodedjson = replace(encodedjson,char(34),"%22",0)
   RETURN(encodedjson)
 END ;Subroutine
 SUBROUTINE (istaskgranted(task_number=i4(val)) =i2 WITH protect)
   CALL log_message("In IsTaskGranted",log_level_debug)
   DECLARE fntime = f8 WITH private, noconstant(curtime3)
   DECLARE task_granted = i2 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM task_access ta,
     application_group ag
    PLAN (ta
     WHERE ta.task_number=task_number
      AND ta.app_group_cd > 0.0)
     JOIN (ag
     WHERE (ag.position_cd=reqinfo->position_cd)
      AND ag.app_group_cd=ta.app_group_cd
      AND ag.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND ag.end_effective_dt_tm > cnvtdatetime(sysdate))
    DETAIL
     task_granted = 1
    WITH nocounter, maxqual(ta,1)
   ;end select
   CALL log_message(build("Exit IsTaskGranted - ",build2(cnvtint((curtime3 - fntime))),"0 ms"),
    log_level_debug)
   RETURN(task_granted)
 END ;Subroutine
 IF (validate(i18nuar_def,999)=999)
  CALL echo("Declaring i18nuar_def")
  DECLARE i18nuar_def = i2 WITH persist
  SET i18nuar_def = 1
  DECLARE uar_i18nlocalizationinit(p1=i4,p2=vc,p3=vc,p4=f8) = i4 WITH persist
  DECLARE uar_i18ngetmessage(p1=i4,p2=vc,p3=vc) = vc WITH persist
  DECLARE uar_i18nbuildmessage() = vc WITH persist
  DECLARE uar_i18ngethijridate(imonth=i2(val),iday=i2(val),iyear=i2(val),sdateformattype=vc(ref)) =
  c50 WITH image_axp = "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar =
  "uar_i18nGetHijriDate",
  persist
  DECLARE uar_i18nbuildfullformatname(sfirst=vc(ref),slast=vc(ref),smiddle=vc(ref),sdegree=vc(ref),
   stitle=vc(ref),
   sprefix=vc(ref),ssuffix=vc(ref),sinitials=vc(ref),soriginal=vc(ref)) = c250 WITH image_axp =
  "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar = "i18nBuildFullFormatName",
  persist
  DECLARE uar_i18ngetarabictime(ctime=vc(ref)) = c20 WITH image_axp = "shri18nuar", image_aix =
  "libi18n_locale.a(libi18n_locale.o)", uar = "i18n_GetArabicTime",
  persist
 ENDIF
 DECLARE i18nhandle = i4 WITH protect
 DECLARE class_begin_ts = dm12 WITH protect, constant(systimestamp)
 CREATE CLASS mp_i18n
 init
 IF (validate(debug_ind,0)=1)
  DECLARE PRIVATE::obj_create_start = dm12 WITH constant(systimestamp)
  CALL echo("BEGIN MP_I18N object creation")
 ENDIF
 RECORD PRIVATE::settings(
   1 i18nhandle = i4
   1 domainlocale = vc
   1 locale = vc
   1 langid = vc
   1 langlocaleid = vc
   1 logprgname = vc
   1 localeobjectname = vc
   1 localefilename = vc
   1 worklistfilename = vc
   1 localefilepath = vc
   1 worklistlocalefilepath = vc
 )
 DECLARE PRIVATE::overrideind = i2 WITH protect, noconstant(0)
 DECLARE PRIVATE::locidx = i4 WITH protect, noconstant(0)
 DECLARE PRIVATE::override_prg_global_pos = i4 WITH protect, noconstant(0)
 DECLARE PRIVATE::override_prg_prsnl_pos = i4 WITH protect, noconstant(0)
 DECLARE PRIVATE::override_all_global_pos = i4 WITH protect, noconstant(0)
 DECLARE PRIVATE::override_all_prsnl_pos = i4 WITH protect, noconstant(0)
 DECLARE PRIVATE::override_prg_global_str = vc WITH noconstant("")
 DECLARE PRIVATE::override_prg_user_str = vc WITH noconstant("")
 DECLARE PRIVATE::override_all_global_str = vc WITH noconstant("")
 DECLARE PRIVATE::override_all_usr_str = vc WITH noconstant("")
 DECLARE PRIVATE::override_prg_global_val = vc WITH noconstant("")
 DECLARE PRIVATE::override_prg_user_val = vc WITH noconstant("")
 DECLARE PRIVATE::override_all_global_val = vc WITH noconstant("")
 DECLARE PRIVATE::override_all_usr_val = vc WITH noconstant("")
 DECLARE _::getdomainlocale(null) = vc
 DECLARE _::getlocale(null) = vc
 DECLARE _::getlangid(null) = vc
 DECLARE _::getlanglocaleid(null) = vc
 DECLARE _::getlocaleobjectname(null) = vc
 DECLARE _::getlocalefilename(null) = vc
 DECLARE _::getworklistfilename(null) = vc
 DECLARE _::getlogprgname(null) = vc
 DECLARE _::geti18nhandle(null) = i4
 DECLARE _::getlocalefilepath(null) = vc
 DECLARE _::getworklistlocalefilepath(null) = vc
 DECLARE _::dump(null) = null
 DECLARE _::generatemasks(null) = null
 SUBROUTINE _::generatemasks(null)
   FREE RECORD datetimeformats
   RECORD datetimeformats(
     1 formatters
       2 decimal_point = vc
       2 thousands_sep = vc
       2 grouping = vc
       2 dollar = vc
       2 time24hr = vc
       2 time24hrnosec = vc
       2 shortdate2yr = vc
       2 fulldate2yr = vc
       2 fulldate4yr = vc
       2 fullmonth4yrnodate = vc
       2 full4yr = vc
       2 fulldatetime2yr = vc
       2 fulldatetime4yr = vc
     1 dateformats
       2 shortdate = vc
       2 mediumdate = vc
       2 longdate = vc
       2 shortdatetime = vc
       2 mediumdatetime = vc
       2 longdatetime = vc
       2 timewithseconds = vc
       2 timenoseconds = vc
       2 weekdaynumber = vc
       2 weekdayabbrev = vc
       2 weekdayname = vc
       2 monthname = vc
       2 monthnumber = vc
       2 monthabbrev = vc
       2 shortdate4yr = vc
       2 mediumdate4yr = vc
       2 shortdatetimenosec = vc
       2 datetimecondensed = vc
       2 datecondensed = vc
       2 mediumdate4yr2 = vc
       2 default = vc
       2 short_date2 = vc
       2 short_date3 = vc
       2 short_date4 = vc
       2 short_date5 = vc
       2 medium_date = vc
       2 long_date = vc
       2 short_time = vc
       2 medium_time = vc
       2 military_time = vc
       2 iso_date = vc
       2 iso_time = vc
       2 iso_date_time = vc
       2 iso_utc_date_time = vc
       2 long_date_time2 = vc
       2 long_date_time3 = vc
       2 medium_date_no_year = vc
       2 month_year = vc
     1 weekmonthnames
       2 weekabbrev = vc
       2 weekfull = vc
       2 monthabbrev = vc
       2 monthfull = vc
   ) WITH persistscript
   SET datetimeformats->dateformats.longdate = replace(cclfmt->longdate,";;d","")
   SET datetimeformats->dateformats.longdatetime = replace(cclfmt->longdatetime,";3;d","")
   SET datetimeformats->dateformats.mediumdate = replace(cclfmt->mediumdate,";;d","")
   SET datetimeformats->dateformats.mediumdatetime = replace(cclfmt->mediumdatetime,";3;d","")
   SET datetimeformats->dateformats.shortdate = replace(cclfmt->shortdate,";;d","")
   SET datetimeformats->dateformats.shortdatetime = replace(cclfmt->shortdatetime,";3;d","")
   SET datetimeformats->dateformats.timenoseconds = replace(cclfmt->timenoseconds,";3;m","")
   SET datetimeformats->dateformats.timewithseconds = replace(cclfmt->timewithseconds,";3;m","")
   SET datetimeformats->dateformats.shortdate4yr = replace(cclfmt->shortdate4yr,";;d","")
   SET datetimeformats->dateformats.mediumdate4yr = replace(cclfmt->mediumdate4yr,";;d","")
   SET datetimeformats->dateformats.shortdatetimenosec = replace(cclfmt->shortdatetimenosec,";3;d",""
    )
   SET datetimeformats->dateformats.datetimecondensed = replace(cclfmt->datetimecondensed,";3;d","")
   SET datetimeformats->dateformats.datecondensed = replace(cclfmt->datecondensed,";;d","")
   IF (validate(cclfmt->mediumdate4yr2))
    SET datetimeformats->dateformats.mediumdate4yr2 = replace(cclfmt->mediumdate4yr2,";;d","")
   ELSE
    SET datetimeformats->dateformats.mediumdate4yr2 = replace(cclfmt->shortdate4yr,";;d","")
   ENDIF
   SET datetimeformats->dateformats.monthname = replace(cclfmt->monthname,";;d","")
   SET datetimeformats->dateformats.monthabbrev = replace(cclfmt->monthabbrev,";;d","")
   SET datetimeformats->dateformats.monthnumber = replace(cclfmt->monthnumber,";;d","")
   SET datetimeformats->dateformats.weekdayabbrev = replace(cclfmt->weekdayabbrev,";;d","")
   SET datetimeformats->dateformats.weekdayname = replace(cclfmt->weekdayname,";;d","")
   SET datetimeformats->dateformats.weekdaynumber = replace(cclfmt->weekdaynumber,";;d","")
   SET datetimeformats->formatters.thousands_sep = notrim(curlocale("THOUSAND"))
   SET datetimeformats->formatters.decimal_point = curlocale("DECIMAL")
   SET datetimeformats->formatters.dollar = curlocale("DOLLAR")
   SET datetimeformats->formatters.grouping = "3"
   SET datetimeformats->formatters.time24hr = "HH:mm:ss"
   SET datetimeformats->formatters.time24hrnosec = "HH:mm"
   SET datetimeformats->formatters.full4yr = "yyyy"
   SET datetimeformats->formatters.shortdate2yr = datetimeformats->dateformats.shortdate
   SET datetimeformats->formatters.fulldate2yr = datetimeformats->dateformats.shortdate
   SET datetimeformats->formatters.fulldate4yr = datetimeformats->dateformats.shortdate4yr
   SET datetimeformats->formatters.fullmonth4yrnodate = "MMM/yyyy"
   SET datetimeformats->formatters.fulldatetime2yr = build2(datetimeformats->dateformats.shortdate,
    " ",datetimeformats->dateformats.timenoseconds)
   SET datetimeformats->formatters.fulldatetime4yr = build2(datetimeformats->dateformats.shortdate4yr,
    " ",datetimeformats->dateformats.timenoseconds)
   SET datetimeformats->dateformats.military_time = "HH:mm"
   SET datetimeformats->dateformats.iso_date = "yyyy-MM-dd"
   SET datetimeformats->dateformats.iso_time = "HH:mm:ss"
   SET datetimeformats->dateformats.iso_date_time = "yyyy-MM-dd'T'HH:mm:ss"
   SET datetimeformats->dateformats.iso_utc_date_time = "UTC:yyyy-MM-dd'T'HH:mm:ss'Z'"
   SET datetimeformats->dateformats.short_date5 = "yyyy"
   SET datetimeformats->dateformats.default = datetimeformats->dateformats.longdatetime
   SET datetimeformats->dateformats.short_date2 = datetimeformats->dateformats.shortdate4yr
   SET datetimeformats->dateformats.short_date3 = datetimeformats->dateformats.shortdate
   SET datetimeformats->dateformats.short_date4 = "MMM/yyyy"
   SET datetimeformats->dateformats.medium_date = datetimeformats->dateformats.mediumdate4yr2
   SET datetimeformats->dateformats.long_date = datetimeformats->dateformats.longdate
   SET datetimeformats->dateformats.short_time = datetimeformats->dateformats.timenoseconds
   SET datetimeformats->dateformats.medium_time = datetimeformats->dateformats.timewithseconds
   SET datetimeformats->dateformats.long_date_time2 = build2(datetimeformats->dateformats.shortdate,
    " ",datetimeformats->dateformats.timenoseconds)
   SET datetimeformats->dateformats.long_date_time3 = build2(datetimeformats->dateformats.
    shortdate4yr," ",datetimeformats->dateformats.timenoseconds)
   SET datetimeformats->dateformats.medium_date_no_year = "d mmm"
   SET datetimeformats->dateformats.month_year = "MAC. yyyy"
   SET datetimeformats->weekmonthnames.weekabbrev = curlocale("WEEKABBREV")
   SET datetimeformats->weekmonthnames.weekfull = curlocale("WEEKFULL")
   SET datetimeformats->weekmonthnames.monthabbrev = curlocale("MONTHABBREV")
   SET datetimeformats->weekmonthnames.monthfull = concat(format(cnvtdatetime("01-jan-2015"),
     "mmmmmmmmmmmm,;;q"),format(cnvtdatetime("01-feb-2015"),"mmmmmmmmmmmm,;;q"),format(cnvtdatetime(
      "01-mar-2015"),"mmmmmmmmmmmm,;;q"),format(cnvtdatetime("01-apr-2015"),"mmmmmmmmmmmm,;;q"),
    format(cnvtdatetime("01-may-2015"),"mmmmmmmmmmmm,;;q"),
    format(cnvtdatetime("01-jun-2015"),"mmmmmmmmmmmm,;;q"),format(cnvtdatetime("01-jul-2015"),
     "mmmmmmmmmmmm,;;q"),format(cnvtdatetime("01-aug-2015"),"mmmmmmmmmmmm,;;q"),format(cnvtdatetime(
      "01-sep-2015"),"mmmmmmmmmmmm,;;q"),format(cnvtdatetime("01-oct-2015"),"mmmmmmmmmmmm,;;q"),
    format(cnvtdatetime("01-nov-2015"),"mmmmmmmmmmmm,;;q"),format(cnvtdatetime("01-dec-2015"),
     "mmmmmmmmmmmm;;q"))
   IF (validate(debug_ind,0)=1)
    CALL echorecord(datetimeformats)
   ENDIF
 END ;Subroutine
 SUBROUTINE (_::setlocale(str=vc) =null)
   SET private::settings->locale = str
 END ;Subroutine
 SUBROUTINE (_::setlangid(str=vc) =null)
   SET private::settings->langid = str
 END ;Subroutine
 SUBROUTINE (_::setlanglocaleid(str=vc) =null)
   SET private::settings->langlocaleid = str
 END ;Subroutine
 SUBROUTINE (_::setlogprgname(str=vc) =null)
   SET private::settings->logprgname = str
 END ;Subroutine
 SUBROUTINE (_::setlocaleobjectname(str=vc) =null)
   SET private::settings->localeobjectname = str
 END ;Subroutine
 SUBROUTINE (_::setlocalefilename(str=vc) =null)
   SET private::settings->localefilename = str
 END ;Subroutine
 SUBROUTINE (_::setlocalefilepath(str=vc) =null)
   SET private::settings->localefilepath = str
 END ;Subroutine
 SUBROUTINE (_::setdomainlocale(str=vc) =null)
   SET private::settings->domainlocale = str
 END ;Subroutine
 SUBROUTINE (_::seti18nhandle(val=i4) =null)
   SET private::settings->i18nhandle = val
 END ;Subroutine
 SUBROUTINE (_::setworklistfilename(str=vc) =null)
   SET private::settings->worklistfilename = str
 END ;Subroutine
 SUBROUTINE (_::setworklistlocalefilepath(str=vc) =null)
   SET private::settings->worklistlocalefilepath = str
 END ;Subroutine
 SUBROUTINE _::getworklistfilename(null)
   RETURN(private::settings->worklistfilename)
 END ;Subroutine
 SUBROUTINE _::getlocale(null)
   RETURN(private::settings->locale)
 END ;Subroutine
 SUBROUTINE _::getlangid(null)
   RETURN(private::settings->langid)
 END ;Subroutine
 SUBROUTINE _::getlanglocaleid(null)
   RETURN(private::settings->langlocaleid)
 END ;Subroutine
 SUBROUTINE _::getlogprgname(null)
   RETURN(private::settings->logprgname)
 END ;Subroutine
 SUBROUTINE _::getdomainlocale(null)
   DECLARE tlocale = c5 WITH private, noconstant("     ")
   SET tlocale = cnvtupper(logical("CCL_LANG"))
   IF (tlocale=" ")
    SET tlocale = cnvtupper(logical("LANG"))
    IF (tlocale IN (" ", "C"))
     SET tlocale = "EN_US"
    ENDIF
   ENDIF
   CALL _::setdomainlocale(tlocale)
   RETURN(tlocale)
 END ;Subroutine
 SUBROUTINE _::getlocaleobjectname(null)
   RETURN(private::settings->localeobjectname)
 END ;Subroutine
 SUBROUTINE _::getlocalefilename(null)
   RETURN(private::settings->localefilename)
 END ;Subroutine
 SUBROUTINE _::getlocalefilepath(null)
   RETURN(private::settings->localefilepath)
 END ;Subroutine
 SUBROUTINE _::geti18nhandle(null)
   RETURN(private::settings->i18nhandle)
 END ;Subroutine
 SUBROUTINE _::getworklistlocalefilepath(null)
   RETURN(private::settings->worklistlocalefilepath)
 END ;Subroutine
 SUBROUTINE (_::initlocale(str=vc) =null)
   DECLARE tlangid = vc WITH private, noconstant("")
   DECLARE tlanglocaleid = vc WITH private, noconstant("")
   CALL _::setlocale(trim(str,3))
   IF (textlen(_::getlocale(null))=0)
    CALL _::setlocale(_::getdomainlocale(null))
   ELSE
    IF (validate(debug_ind,0)=1)
     CALL echo(build2("Current Domain locale value: ",_::getdomainlocale(null)))
     CALL echo(build2("Overriding locale to: ",str))
    ENDIF
    SET PRIVATE::overrideind = 1
   ENDIF
   CALL _::setlangid(cnvtlower(substring(1,2,_::getlocale(null))))
   CALL _::setlanglocaleid(cnvtupper(substring(4,2,_::getlocale(null))))
   SET tlangid = _::getlangid(null)
   SET tlanglocaleid = _::getlanglocaleid(null)
   CASE (tlangid)
    OF "en":
     CALL _::setlocalefilename("locale")
     CALL _::setlocaleobjectname("en_US")
     IF (((cnvtupper(_::getlocale(null))="EN_AU") OR (cnvtupper(_::getlocale(null))="EN_GB")) )
      CALL _::setlocaleobjectname(concat(tlangid,"_",tlanglocaleid))
      CALL _::setlocalefilename(concat("locale.",tlangid,"_",tlanglocaleid))
      CALL _::setworklistfilename(concat(cnvtupper(tlangid),"_",cnvtupper(tlanglocaleid)))
     ELSE
      CALL _::setworklistfilename("EN_US")
     ENDIF
    OF "es":
    OF "de":
    OF "fr":
    OF "pt":
     CALL _::setlocalefilename(concat("locale.",tlangid))
     CALL _::setlocaleobjectname(concat(tlangid,"_",tlanglocaleid))
     IF (cnvtupper(tlangid)="PT")
      CALL _::setworklistfilename("PT_BR")
     ELSE
      CALL _::setworklistfilename(concat(cnvtupper(tlangid),"_",cnvtupper(tlangid)))
     ENDIF
    ELSE
     CALL _::setlocalefilename("locale")
     CALL _::setlocaleobjectname("en_US")
     CALL _::setworklistfilename("EN_US")
   ENDCASE
   IF ((PRIVATE::overrideind=0))
    CALL uar_i18nlocalizationinit(i18nhandle,nullterm(curprog),nullterm(""),curcclrev)
    CALL _::seti18nhandle(i18nhandle)
   ELSE
    CALL uar_i18nlocalizationinit(i18nhandle,nullterm(curprog),nullterm(_::getlocale(null)),curcclrev
     )
    CALL _::seti18nhandle(i18nhandle)
    IF (validate(debug_ind,0)=1)
     CALL echo("**** OVERRIDING VALUES IN CCLFMT ****")
     CALL echo("CCLFMT BEFORE OVERRIDE:")
     CALL echorecord(cclfmt)
    ENDIF
    EXECUTE cclstartup_locale _::getlocale(null)
    IF (validate(debug_ind,0)=1)
     CALL echo("CCLFMT AFTER OVERRIDE:")
     CALL echorecord(cclfmt)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE _::dump(null)
   CALL echorecord(PRIVATE::settings)
 END ;Subroutine
 IF (validate(log_program_name))
  CALL _::setlogprgname(log_program_name)
 ELSE
  CALL _::setlogprgname(curprog)
 ENDIF
 IF (validate(_mp_18n_override))
  IF (validate(debug_ind,0)=1)
   CALL echorecord(_mp_18n_override)
  ENDIF
  SET PRIVATE::override_prg_global_pos = locateval(PRIVATE::locidx,1,size(_mp_18n_override->scripts,5
    ),cnvtupper(_::getlogprgname(null)),cnvtupper(_mp_18n_override->scripts[PRIVATE::locidx].name),
   0.0,_mp_18n_override->scripts[PRIVATE::locidx].prsnl_id)
  SET PRIVATE::override_prg_prsnl_pos = locateval(PRIVATE::locidx,1,size(_mp_18n_override->scripts,5),
   cnvtupper(_::getlogprgname(null)),cnvtupper(_mp_18n_override->scripts[PRIVATE::locidx].name),
   reqinfo->updt_id,_mp_18n_override->scripts[PRIVATE::locidx].prsnl_id)
  SET PRIVATE::override_all_global_pos = locateval(PRIVATE::locidx,1,size(_mp_18n_override->scripts,5
    ),"ALL",cnvtupper(_mp_18n_override->scripts[PRIVATE::locidx].name),
   0.0,_mp_18n_override->scripts[PRIVATE::locidx].prsnl_id)
  SET PRIVATE::override_all_prsnl_pos = locateval(PRIVATE::locidx,1,size(_mp_18n_override->scripts,5),
   "ALL",cnvtupper(_mp_18n_override->scripts[PRIVATE::locidx].name),
   reqinfo->updt_id,_mp_18n_override->scripts[PRIVATE::locidx].prsnl_id)
  IF ((PRIVATE::override_prg_prsnl_pos > 0))
   CALL _::setlocale(_mp_18n_override->scripts[PRIVATE::override_prg_prsnl_pos].locale)
   IF (validate(_mp_18n_override->scripts[PRIVATE::override_prg_prsnl_pos].localefile))
    CALL _::setlocalefilepath(_mp_18n_override->scripts[PRIVATE::override_prg_prsnl_pos].localefile)
   ENDIF
   IF (validate(_mp_18n_override->scripts[PRIVATE::override_prg_prsnl_pos].worklistlocalefile))
    CALL _::setworklistlocalefilepath(_mp_18n_override->scripts[PRIVATE::override_prg_prsnl_pos].
     worklistlocalefile)
   ENDIF
  ELSEIF ((PRIVATE::override_all_prsnl_pos > 0))
   CALL _::setlocale(_mp_18n_override->scripts[PRIVATE::override_all_prsnl_pos].locale)
   IF (validate(_mp_18n_override->scripts[PRIVATE::override_all_prsnl_pos].localefile))
    CALL _::setlocalefilepath(_mp_18n_override->scripts[PRIVATE::override_all_prsnl_pos].localefile)
   ENDIF
   IF (validate(_mp_18n_override->scripts[PRIVATE::override_all_prsnl_pos].worklistlocalefile))
    CALL _::setworklistlocalefilepath(_mp_18n_override->scripts[PRIVATE::override_all_prsnl_pos].
     worklistlocalefile)
   ENDIF
  ELSEIF ((PRIVATE::override_prg_global_pos > 0))
   CALL _::setlocale(_mp_18n_override->scripts[PRIVATE::override_prg_global_pos].locale)
   IF (validate(_mp_18n_override->scripts[PRIVATE::override_prg_global_pos].localefile))
    CALL _::setlocalefilepath(_mp_18n_override->scripts[PRIVATE::override_prg_global_pos].localefile)
   ENDIF
   IF (validate(_mp_18n_override->scripts[PRIVATE::override_prg_global_pos].worklistlocalefile))
    CALL _::setworklistlocalefilepath(_mp_18n_override->scripts[PRIVATE::override_prg_global_pos].
     worklistlocalefile)
   ENDIF
  ELSEIF ((PRIVATE::override_all_global_pos > 0))
   CALL _::setlocale(_mp_18n_override->scripts[PRIVATE::override_all_global_pos].locale)
   IF (validate(_mp_18n_override->scripts[PRIVATE::override_all_global_pos].localefile))
    CALL _::setlocalefilepath(_mp_18n_override->scripts[PRIVATE::override_all_global_pos].localefile)
   ENDIF
   IF (validate(_mp_18n_override->scripts[PRIVATE::override_all_global_pos].worklistlocalefile))
    CALL _::setworklistlocalefilepath(_mp_18n_override->scripts[PRIVATE::override_all_global_pos].
     worklistlocalefile)
   ENDIF
  ENDIF
 ENDIF
 CALL _::initlocale(_::getlocale(null))
 IF (checkfun("LOG_MESSAGE")=7)
  CALL log_message(concat("-mp_i18n Locale file name: ",_::getlocalefilename(null)),log_level_debug)
  CALL log_message(concat("-mp_i18n Worklist Locale file name: ",_::getworklistfilename(null)),
   log_level_debug)
  CALL log_message(concat("-mp_i18n Locale object name: ",_::getlocaleobjectname(null)),
   log_level_debug)
 ENDIF
 IF (validate(debug_ind,0)=1)
  CALL echo(concat("END MP_I18N object creation, Elapsed time:",cnvtstring(timestampdiff(systimestamp,
      class_begin_ts),17,4)))
  CALL _::dump(null)
 ENDIF
 END; class scope:init
 final
 IF ((PRIVATE::overrideind=1))
  EXECUTE cclstartup_locale _::getdomainlocale(null)
  IF (checkprg("CCLSTARTUP_CUSTREFLOG") > 0)
   EXECUTE cclstartup_custreflog
  ENDIF
  IF (validate(debug_ind,0)=1)
   CALL echo("**** REVERTED OVERRIDDEN VALUES IN CCLFMT ****")
   CALL echo("CCLFMT AFTER OVERRIDE REVERT:")
   CALL echorecord(cclfmt)
  ENDIF
 ENDIF
 END; class scope:final
 WITH copy = 0
 DECLARE MP::i18n = null WITH class(mp_i18n)
 DECLARE script_start_curtime3 = dq8 WITH constant(curtime3), private
 DECLARE eid = f8 WITH noconstant(0), protect
 DECLARE pid = f8 WITH noconstant(0), protect
 IF (validate(i18n_handle,999)=999)
  DECLARE i18n_handle = i4 WITH persistscript
  SET stat = uar_i18nlocalizationinit(i18n_handle,curprog,"",curcclrev)
 ENDIF
 IF (validate(i18nuar_def,999)=999)
  DECLARE i18nuar_def = i2 WITH persist, noconstant(1)
  DECLARE uar_i18nlocalizationinit(p1=i4,p2=vc,p3=vc,p4=f8) = i4 WITH persist
  DECLARE uar_i18ngetmessage(p1=i4,p2=vc,p3=vc) = vc WITH persist
 ENDIF
 DECLARE checkifnotetextisconfigured(null) = null
 DECLARE extractsavedocbodyhtml(vc) = vc
 DECLARE getattributepropertyfromchildocid(vc,i2) = vc
 DECLARE generatenodeoutput(null) = null
 DECLARE generatesortedsavedocbloblist(null) = null
 DECLARE generatetermstatetext(vc) = vc
 DECLARE getactivepathwayactions(null) = null
 DECLARE getactivepathways(null) = null
 DECLARE getdocumenttemplateid(null) = null
 DECLARE getsavedoceventtext(null) = null
 DECLARE getsortedattributes(null) = null
 DECLARE getstructuredoctemplate(null) = null
 DECLARE gettranslatedvalue(vc) = vc
 DECLARE main(null) = null
 RECORD action_log(
   1 actions[*]
     2 term_display = vc
     2 term_ocid = vc
     2 term_state = vc
     2 timestamp = vc
 )
 FREE RECORD active_pathways
 RECORD active_pathways(
   1 cnt = i4
   1 qual[*]
     2 cp_pathway_id = f8
     2 node_cnt = i4
     2 node_qual[*]
       3 cp_node_id = f8
       3 latest_savedoc_id = f8
       3 latest_savedoc_blob = vc
       3 node_display = vc
       3 cp_component_id = f8
       3 template_cnt = i4
       3 actions[*]
         4 term_display = vc
         4 term_ocid = vc
         4 term_state = vc
         4 timestamp = vc
       3 trailjson[*]
         4 version_number = i4
         4 template_id = vc
         4 template_instance_identifier = vc
         4 structure_template = vc
         4 sorted_attributes = vc
         4 note_text_configured_ind = i2
         4 savedoc_blob = vc
       3 output = vc
     2 pathway_name = vc
     2 pathway_instance_id = f8
 )
 RECORD pathway_trail_data(
   1 action_cnt = i4
   1 actions[*]
     2 encntr_id = f8
     2 node_id = f8
     2 node_display = vc
     2 cp_component_id = f8
     2 action_id = f8
     2 action_mean = vc
     2 action_dt_tm = dq8
     2 action_prsnl_id = f8
     2 action_prsnl_name = vc
     2 action_detail_id = f8
     2 action_detail_status_mean = vc
     2 action_detail_prsnl_id = f8
     2 action_detail_prsnl_name = vc
     2 action_detail_dt_tm = dq8
     2 action_detail_entity_id = f8
     2 action_detail_entity_id_status = vc
     2 action_detail_entity_name = vc
     2 action_detail_entity_mean = vc
     2 action_detail_entity_value = vc
     2 trigger_in_error_action_ind = i2
     2 action_detail_text = vc
     2 version_nbr = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF ( NOT (validate(request)))
  RECORD request(
    1 person[*]
      2 person_id = f8
    1 visit[*]
      2 encntr_id = f8
    1 prsnl[*]
      2 prsnl_id = f8
  )
 ENDIF
 IF ( NOT (validate(reply)))
  RECORD reply(
    1 text = vc
    1 large_text_qual[*]
      2 text_segment = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD sorted_attributes(
   1 attribute_cnt = i4
   1 attributes[*]
     2 ocid = vc
     2 attribute_menu_item_cnt = i4
     2 attribute_menu_items[*]
       3 ocid = vc
 )
 RECORD structure_template(
   1 concept_cki = vc
   1 section_ref[*]
     2 dd_sref_section_id = f8
     2 template_rltns[*]
       3 dd_sref_templ_instance_ident = vc
       3 dd_sref_chf_cmplnt_crit_id = f8
       3 parent_entity_id = f8
       3 parent_entity_name = vc
     2 groupbys[*]
       3 label = vc
       3 display_seq = i4
       3 displayflag = i2
       3 subgroupbys[*]
         4 label = vc
         4 display_seq = i4
         4 displayflag = i2
         4 items[*]
           5 value = vc
           5 priority = i2
           5 ocid = vc
           5 display_seq = i4
           5 displayflag = i2
           5 code[*]
             6 code_system = vc
             6 value = vc
           5 attributes[*]
             6 name = vc
             6 attrib_type = vc
             6 attribid = vc
             6 ocid = vc
             6 priority = i2
             6 display_seq = i4
             6 displayflag = i2
             6 code[*]
               7 code_system = vc
               7 value = vc
             6 attribute_menu_items[*]
               7 value = vc
               7 caption = vc
               7 user_input = i2
               7 data_type = vc
               7 ocid = vc
               7 normalfinding = vc
               7 display_seq = i4
               7 min_value = f8
               7 max_value = f8
               7 priority = i2
               7 ui_type = vc
               7 ui_value = vc
               7 label_id = vc
               7 child_label_id = vc
               7 code[*]
                 8 code_system = vc
                 8 value = vc
         4 code[*]
           5 code_system = vc
           5 value = vc
       3 items[*]
         4 value = vc
         4 priority = i2
         4 ocid = vc
         4 display_seq = i4
         4 displayflag = i2
         4 code[*]
           5 code_system = vc
           5 value = vc
         4 attributes[*]
           5 name = vc
           5 attrib_type = vc
           5 attribid = vc
           5 ocid = vc
           5 priority = i2
           5 display_seq = i4
           5 displayflag = i2
           5 code[*]
             6 code_system = vc
             6 value = vc
           5 attribute_menu_items[*]
             6 value = vc
             6 caption = vc
             6 user_input = i2
             6 data_type = vc
             6 ocid = vc
             6 normalfinding = vc
             6 display_seq = i4
             6 min_value = f8
             6 max_value = f8
             6 priority = i2
             6 ui_type = vc
             6 ui_value = vc
             6 label_id = vc
             6 child_label_id = vc
     2 template_xmls[*]
       3 template_xml = vc
     2 subsections[*]
       3 dd_sref_section_id = f8
       3 template_rltns[*]
         4 dd_sref_templ_instance_ident = vc
         4 dd_sref_chf_cmplnt_crit_id = f8
         4 parent_entity_id = f8
         4 parent_entity_name = vc
       3 groupbys[*]
         4 label = vc
         4 display_seq = i4
         4 displayflag = i2
         4 subgroupbys[*]
           5 label = vc
           5 display_seq = i4
           5 displayflag = i2
           5 items[*]
             6 value = vc
             6 priority = i2
             6 ocid = vc
             6 display_seq = i4
             6 displayflag = i2
             6 attributes[*]
               7 name = vc
               7 attrib_type = vc
               7 attribid = vc
               7 ocid = vc
               7 priority = i2
               7 display_seq = i4
               7 displayflag = i2
               7 attribute_menu_items[*]
                 8 value = vc
                 8 caption = vc
                 8 user_input = i2
                 8 data_type = vc
                 8 ocid = vc
                 8 normalfinding = vc
                 8 display_seq = i4
                 8 min_value = f8
                 8 max_value = f8
                 8 priority = i2
                 8 ui_type = vc
                 8 ui_value = vc
                 8 label_id = vc
                 8 child_label_id = vc
         4 items[*]
           5 value = vc
           5 priority = i2
           5 ocid = vc
           5 display_seq = i4
           5 displayflag = i2
           5 attributes[*]
             6 name = vc
             6 attrib_type = vc
             6 attribid = vc
             6 ocid = vc
             6 priority = i2
             6 display_seq = i4
             6 displayflag = i2
             6 attribute_menu_items[*]
               7 value = vc
               7 caption = vc
               7 user_input = i2
               7 data_type = vc
               7 ocid = vc
               7 normalfinding = vc
               7 display_seq = i4
               7 min_value = f8
               7 max_value = f8
               7 priority = i2
               7 ui_type = vc
               7 ui_value = vc
               7 label_id = vc
               7 child_label_id = vc
       3 template_xmls[*]
         4 template_xmls = vc
       3 section_label = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 document_events
     2 json = vc
   1 term_decorations
     2 json = vc
 )
 RECORD translated_strings(
   1 cnt = i4
   1 qual[*]
     2 locale_ident = vc
     2 header_text = vc
     2 no_answers_string = vc
     2 no_string = vc
     2 yes_string = vc
 )
 SUBROUTINE checkifnotetextisconfigured(null)
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = active_pathways->cnt),
     (dummyt d2  WITH seq = 1),
     (dummyt d3  WITH seq = 1),
     dd_sref_template dst,
     long_blob_reference lbr
    PLAN (d1
     WHERE (active_pathways->cnt > 0)
      AND maxrec(d2,active_pathways->qual[d1.seq].node_cnt))
     JOIN (d2
     WHERE (active_pathways->qual[d1.seq].node_cnt > 0)
      AND maxrec(d3,active_pathways->qual[d1.seq].node_qual[d2.seq].template_cnt))
     JOIN (d3)
     JOIN (dst
     WHERE (dst.dd_sref_tmpl_instance_ident=active_pathways->qual[d1.seq].node_qual[d2.seq].
     trailjson[d3.seq].template_instance_identifier))
     JOIN (lbr
     WHERE lbr.long_blob_id=dst.xml_long_blob_ref_id)
    DETAIL
     IF (findstring("TEMPLATE_ROW",lbr.long_blob) > 0)
      active_pathways->qual[d1.seq].node_qual[d2.seq].trailjson[d3.seq].note_text_configured_ind = 1
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE extractsavedocbodyhtml(savedoc_blob)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   CALL log_message("Begin extractSavedocBodyHtml()",log_level_debug)
   DECLARE savedoc_body_html = vc WITH noconstant(""), protect
   IF (findstring("ocid",savedoc_blob) > 0)
    DECLARE html_body_close_str = vc WITH protect, constant("</div>")
    DECLARE html_body_open_str = vc WITH protect, constant("<br /")
    DECLARE body_close_idx = i4 WITH protect, noconstant(0)
    DECLARE body_open_idx = i4 WITH protect, noconstant(0)
    SET body_open_idx = findstring(html_body_open_str,cnvtlower(savedoc_blob))
    SET body_open_idx = (findstring(">",cnvtlower(savedoc_blob),body_open_idx)+ 1)
    SET body_close_idx = findstring(html_body_close_str,cnvtlower(savedoc_blob),body_open_idx)
    SET savedoc_body_html = substring(body_open_idx,(body_close_idx - body_open_idx),savedoc_blob)
   ENDIF
   CALL log_message(build2("Exit extractSavedocBodyHtml(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
   RETURN(savedoc_body_html)
 END ;Subroutine
 SUBROUTINE getattributepropertyfromchildocid(child_ocid,return_type)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   CALL log_message("Begin getAttributePropertyFromChildOCID()",log_level_debug)
   DECLARE child_pos = i4 WITH noconstant(0), protect
   DECLARE property_val = vc WITH noconstant(""), protect
   DECLARE x = i4 WITH noconstant(0), protect
   DECLARE y = i4 WITH noconstant(0), protect
   DECLARE z = i4 WITH noconstant(0), protect
   FOR (x = 1 TO size(structure_template->section_ref[1].groupbys[1].items,5))
     FOR (y = 1 TO size(structure_template->section_ref[1].groupbys[1].items[x].attributes,5))
      SET child_pos = locateval(z,1,size(structure_template->section_ref[1].groupbys[1].items[x].
        attributes[y].attribute_menu_items,5),child_ocid,structure_template->section_ref[1].groupbys[
       1].items[x].attributes[y].attribute_menu_items[z].ocid)
      IF (child_pos > 0)
       CASE (return_type)
        OF "ATTRIB_NAME":
         SET property_val = structure_template->section_ref[1].groupbys[1].items[x].attributes[y].
         name
        OF "ATTRIB_OCID":
         SET property_val = structure_template->section_ref[1].groupbys[1].items[x].attributes[y].
         ocid
        OF "ATTRIB_TYPE":
         SET property_val = structure_template->section_ref[1].groupbys[1].items[x].attributes[y].
         attrib_type
       ENDCASE
      ENDIF
     ENDFOR
   ENDFOR
   CALL log_message(build2("Exit getAttributePropertyFromChildOCID(), Elapsed time in seconds:",((
     curtime3 - begin_curtime3)/ 100.0)),log_level_debug)
   RETURN(property_val)
 END ;Subroutine
 SUBROUTINE generatenodeoutput(null)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   CALL log_message("Begin generateNodeOutput()",log_level_debug)
   DECLARE replace_str = vc WITH noconstant(""), protect
   DECLARE attrib_name = vc WITH noconstant(""), protect
   DECLARE attrib_type = vc WITH noconstant(""), protect
   DECLARE term_state = vc WITH noconstant(""), protect
   DECLARE term_name = vc WITH noconstant(""), protect
   DECLARE savedoc_blob_ind = i2 WITH noconstant(0), protect
   DECLARE x = i4 WITH noconstant(0), protect
   DECLARE y = i4 WITH noconstant(0), protect
   DECLARE z = i4 WITH noconstant(0), protect
   DECLARE w = i4 WITH noconstant(0), protect
   FOR (x = 1 TO active_pathways->cnt)
     FOR (y = 1 TO active_pathways->qual[x].node_cnt)
       SET active_pathways->qual[x].node_qual[y].output = build2(active_pathways->qual[x].node_qual[y
        ].output,"\pard\par { \b\ul ",active_pathways->qual[x].pathway_name," - ",active_pathways->
        qual[x].node_qual[y].node_display,
        " \b0\ulnone} \par ")
       SET savedoc_blob_ind = 0
       IF ((active_pathways->qual[x].node_qual[y].template_cnt > 0)
        AND size(active_pathways->qual[x].node_qual[y].actions,5) > 0)
        FOR (w = 1 TO active_pathways->qual[x].node_qual[y].template_cnt)
         IF ((active_pathways->qual[x].node_qual[y].trailjson[w].savedoc_blob=""))
          SET u = 0
          SET stat = initrec(structure_template)
          SET stat = cnvtjsontorec(active_pathways->qual[x].node_qual[y].trailjson[w].
           structure_template)
          FOR (z = 1 TO size(active_pathways->qual[x].node_qual[y].actions,5))
            IF ((active_pathways->qual[x].node_qual[y].actions[z].term_state != "null"))
             SET attrib_type = getattributepropertyfromchildocid(active_pathways->qual[x].node_qual[y
              ].actions[z].term_ocid,"ATTRIB_TYPE")
             SET attrib_name = getattributepropertyfromchildocid(active_pathways->qual[x].node_qual[y
              ].actions[z].term_ocid,"ATTRIB_NAME")
             IF (attrib_type > "")
              IF (attrib_type != "YesNo")
               SET term_state = ""
               SET term_name = active_pathways->qual[x].node_qual[y].actions[z].term_display
              ELSE
               SET term_name = ""
               SET term_state = generatetermstatetext(active_pathways->qual[x].node_qual[y].actions[z
                ].term_state)
              ENDIF
              SET replace_str = attrib_name
              IF (term_name > "")
               SET replace_str = build2(attrib_name," ",term_name)
              ENDIF
              IF (term_state > "")
               SET replace_str = build2(replace_str," ",term_state)
              ENDIF
              IF ((active_pathways->qual[x].node_qual[y].trailjson[w].savedoc_blob=""))
               SET active_pathways->qual[x].node_qual[y].trailjson[w].savedoc_blob = build2(
                replace_str," \par ")
              ELSE
               SET active_pathways->qual[x].node_qual[y].trailjson[w].savedoc_blob = build2(
                active_pathways->qual[x].node_qual[y].trailjson[w].savedoc_blob," - ",replace_str,
                " \par ")
              ENDIF
             ENDIF
            ENDIF
          ENDFOR
         ENDIF
         IF ((active_pathways->qual[x].node_qual[y].trailjson[w].savedoc_blob != ""))
          SET active_pathways->qual[x].node_qual[y].output = build2(active_pathways->qual[x].
           node_qual[y].output," - ",active_pathways->qual[x].node_qual[y].trailjson[w].savedoc_blob,
           " \par ")
          SET savedoc_blob_ind = 1
         ENDIF
        ENDFOR
       ENDIF
       IF (savedoc_blob_ind=0)
        SET active_pathways->qual[x].node_qual[y].output = build2(active_pathways->qual[x].node_qual[
         y].output," - ",gettranslatedvalue("NO_ANSWERS_STRING")," \par ")
       ENDIF
     ENDFOR
   ENDFOR
   CALL log_message(build2("Exit generateNodeOutput(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE generateoutput(null)
   DECLARE output = vc WITH noconstant(""), protect
   DECLARE x = i4 WITH noconstant(0), protect
   DECLARE y = i4 WITH noconstant(0), protect
   SET output = "{\rtf1\ansi{\fonttbl{\f0\fswiss\fprq2\fcharset0  Calibri;}}"
   IF ((active_pathways->cnt > 0))
    SET output = concat(output,gettranslatedvalue("HEADER_TEXT_STRING")," \par")
    FOR (x = 1 TO active_pathways->cnt)
      FOR (y = 1 TO active_pathways->qual[x].node_cnt)
        SET output = concat(output,active_pathways->qual[x].node_qual[y].output)
      ENDFOR
    ENDFOR
   ENDIF
   SET output = concat(output,"}")
   IF (validate(debug_ind,0)=1)
    CALL echo(build2("FINAL OUTPUT: ",output))
   ENDIF
   SET reply->text = replace(output,"%7C","|")
 END ;Subroutine
 SUBROUTINE generatesortedsavedocbloblist(null)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   CALL log_message("Begin generateSortedSavedocBlobList()",log_level_debug)
   DECLARE ending_character_found_ind = i2 WITH noconstant(0), protect
   DECLARE latest_savedoc_blob = vc WITH noconstant(""), protect
   DECLARE string_length = i4 WITH noconstant(0), protect
   DECLARE find_string = vc WITH noconstant(""), protect
   DECLARE first_pos = i4 WITH noconstant(0), protect
   DECLARE match_pos = i4 WITH noconstant(0), protect
   DECLARE temp_blob = vc WITH noconstant(""), protect
   DECLARE blob_cnt = i4 WITH noconstant(0), protect
   DECLARE x = i4 WITH noconstant(0), protect
   DECLARE y = i4 WITH noconstant(0), protect
   DECLARE z = i4 WITH noconstant(0), protect
   DECLARE q = i4 WITH noconstant(0), protect
   DECLARE w = i4 WITH noconstant(0), protect
   FOR (x = 1 TO active_pathways->cnt)
     FOR (y = 1 TO active_pathways->qual[x].node_cnt)
      SET latest_savedoc_blob = active_pathways->qual[x].node_qual[y].latest_savedoc_blob
      FOR (w = 1 TO active_pathways->qual[x].node_qual[y].template_cnt)
        IF (latest_savedoc_blob > "")
         SET stat = initrec(sorted_attributes)
         SET stat = cnvtjsontorec(active_pathways->qual[x].node_qual[y].trailjson[w].
          sorted_attributes)
         FOR (z = 1 TO sorted_attributes->attribute_cnt)
           SET temp_blob = ""
           SET find_string = build2('<span dd:ocid="',sorted_attributes->attributes[z].ocid,'">')
           SET first_pos = findstring(find_string,latest_savedoc_blob)
           IF (first_pos > 0)
            SET string_length = textlen(find_string)
            SET ending_character_found_ind = 0
            WHILE ( NOT (ending_character_found_ind))
             IF (substring(first_pos,1,latest_savedoc_blob)="|")
              SET first_pos += 1
              SET string_length -= 1
              SET ending_character_found_ind = 1
             ELSE
              SET first_pos -= 1
              SET string_length += 1
             ENDIF
             IF (first_pos <= 0)
              SET ending_character_found_ind = 1
             ENDIF
            ENDWHILE
            SET find_string = "|"
            SET match_pos = findstring(find_string,latest_savedoc_blob,(first_pos+ string_length))
            IF (match_pos > 0)
             SET match_pos -= 1
             SET string_length = ((match_pos - first_pos)+ textlen(find_string))
             SET temp_blob = substring(first_pos,string_length,latest_savedoc_blob)
             IF (temp_blob > "")
              FOR (q = 1 TO sorted_attributes->attributes[z].attribute_menu_item_cnt)
                SET temp_blob = replace(temp_blob,build2('<span dd:ocid="',sorted_attributes->
                  attributes[z].attribute_menu_items[q].ocid,'">'),"")
              ENDFOR
              SET temp_blob = replace(temp_blob,build2('<span dd:ocid="',sorted_attributes->
                attributes[z].ocid,'">'),"")
              SET temp_blob = replace(temp_blob,"</span>","")
              IF ((active_pathways->qual[x].node_qual[y].trailjson[w].savedoc_blob=""))
               SET active_pathways->qual[x].node_qual[y].trailjson[w].savedoc_blob = build2(trim(
                 temp_blob,3)," \par ")
              ELSE
               SET active_pathways->qual[x].node_qual[y].trailjson[w].savedoc_blob = build2(
                active_pathways->qual[x].node_qual[y].trailjson[w].savedoc_blob," - ",trim(temp_blob,
                 3)," \par ")
              ENDIF
             ENDIF
            ENDIF
           ENDIF
         ENDFOR
        ENDIF
      ENDFOR
     ENDFOR
   ENDFOR
   CALL log_message(build2("Exit generateSortedSavedocBlobList(), Elapsed time in seconds:",((
     curtime3 - begin_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE generatetermstatetext(term_state)
   DECLARE state_text = vc WITH noconstant(""), protect
   CASE (term_state)
    OF "true":
     SET state_text = gettranslatedvalue("YES_STRING")
    OF "false":
     SET state_text = gettranslatedvalue("NO_STRING")
   ENDCASE
   RETURN(state_text)
 END ;Subroutine
 SUBROUTINE getactivepathwayactions(null)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   CALL log_message("Begin getActivePathwayActions()",log_level_debug)
   DECLARE action_mean = vc WITH noconstant(""), protect
   DECLARE node_pos = i4 WITH noconstant(0), protect
   DECLARE idx = i4 WITH noconstant(0), protect
   DECLARE x = i4 WITH noconstant(0), protect
   DECLARE y = i4 WITH noconstant(0), protect
   FOR (x = 1 TO active_pathways->cnt)
     SET stat = initrec(pathway_trail_data)
     EXECUTE cp_retrieve_pathway_trail_data "MINE", cnvtreal(active_pathways->qual[x].cp_pathway_id),
     cnvtreal(active_pathways->qual[x].pathway_instance_id),
     pid, eid
     FOR (y = 1 TO pathway_trail_data->action_cnt)
       IF ((pathway_trail_data->actions[y].encntr_id=eid))
        SET action_mean = pathway_trail_data->actions[y].action_detail_entity_mean
        IF (((action_mean="SAVEDOC") OR (action_mean="TRAILJSON")) )
         SET node_pos = locateval(idx,1,active_pathways->qual[x].node_cnt,pathway_trail_data->
          actions[y].node_id,active_pathways->qual[x].node_qual[idx].cp_node_id)
         IF (node_pos > 0)
          CASE (pathway_trail_data->actions[y].action_detail_entity_mean)
           OF "SAVEDOC":
            IF ((active_pathways->qual[x].node_qual[node_pos].latest_savedoc_id=0))
             SET active_pathways->qual[x].node_qual[node_pos].latest_savedoc_id = pathway_trail_data
             ->actions[y].action_detail_entity_id
            ENDIF
           OF "TRAILJSON":
            SET stat = initrec(action_log)
            SET stat = cnvtjsontorec(pathway_trail_data->actions[y].action_detail_entity_value)
            SET stat = movereclist(action_log->actions,active_pathways->qual[x].node_qual[node_pos].
             actions,1,size(active_pathways->qual[x].node_qual[node_pos].actions,5),size(action_log->
              actions,5),
             true)
          ENDCASE
         ENDIF
        ENDIF
       ENDIF
     ENDFOR
   ENDFOR
   CALL log_message(build2("Exit getActivePathwayActions(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getactivepathways(null)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   CALL log_message("Begin getActivePathways()",log_level_debug)
   DECLARE treatment_assessment_cd = f8 WITH noconstant(0), protect
   DECLARE gt_cd = f8 WITH noconstant(0), protect
   DECLARE activity_complete_cd = f8 WITH noconstant(0), protect
   DECLARE activity_active_cd = f8 WITH noconstant(0), protect
   DECLARE pathway_active_cd = f8 WITH noconstant(0), protect
   DECLARE activity_void_cd = f8 WITH noconstant(0), protect
   DECLARE active_cnt = i4 WITH noconstant(0), protect
   DECLARE node_cnt = i4 WITH noconstant(0), protect
   SET stat = uar_get_meaning_by_codeset(4003198,"ACTIVE",1,pathway_active_cd)
   SET stat = uar_get_meaning_by_codeset(4003352,"VOID",1,activity_void_cd)
   SET stat = uar_get_meaning_by_codeset(4003352,"ACTIVE",1,activity_active_cd)
   SET stat = uar_get_meaning_by_codeset(4003352,"COMPLETE",1,activity_complete_cd)
   SET stat = uar_get_meaning_by_codeset(4003130,"PATHWAY_DOC",1,treatment_assessment_cd)
   SET stat = uar_get_meaning_by_codeset(4003130,"GUIDEDTRMNT",1,gt_cd)
   SELECT INTO "nl:"
    FROM cp_pathway_activity cpa,
     cp_pathway cp,
     cp_node cn,
     cp_component cc
    PLAN (cpa
     WHERE cpa.person_id=pid
      AND cpa.pathway_activity_status_cd=activity_active_cd
      AND  NOT (cpa.pathway_instance_id IN (
     (SELECT
      cpa2.pathway_instance_id
      FROM cp_pathway_activity cpa2
      WHERE cpa2.person_id=pid
       AND cpa2.pathway_activity_status_cd=value(activity_void_cd,activity_complete_cd)))))
     JOIN (cp
     WHERE cp.pathway_status_cd=pathway_active_cd
      AND cp.active_ind=1
      AND cp.cp_pathway_id=cpa.cp_pathway_id)
     JOIN (cn
     WHERE cn.cp_pathway_id=cp.cp_pathway_id
      AND cn.active_ind=1)
     JOIN (cc
     WHERE cc.cp_node_id=cn.cp_node_id
      AND cc.comp_type_cd IN (treatment_assessment_cd, gt_cd))
    ORDER BY cp.pathway_name, cn.node_display
    HEAD cp.cp_pathway_id
     node_cnt = 0, active_cnt += 1
     IF (active_cnt > size(active_pathways->qual,5))
      stat = alterlist(active_pathways->qual,(active_cnt+ 10))
     ENDIF
     active_pathways->qual[active_cnt].pathway_name = cp.pathway_name, active_pathways->qual[
     active_cnt].cp_pathway_id = cp.cp_pathway_id, active_pathways->qual[active_cnt].
     pathway_instance_id = cpa.pathway_instance_id
    HEAD cn.cp_node_id
     node_cnt += 1
     IF (active_cnt > size(active_pathways->qual[active_cnt].node_qual,5))
      stat = alterlist(active_pathways->qual[active_cnt].node_qual,(node_cnt+ 10))
     ENDIF
     active_pathways->qual[active_cnt].node_qual[node_cnt].cp_node_id = cn.cp_node_id,
     active_pathways->qual[active_cnt].node_qual[node_cnt].node_display = cn.node_name,
     active_pathways->qual[active_cnt].node_qual[node_cnt].cp_component_id = cc.cp_component_id
    FOOT  cp.cp_pathway_id
     active_pathways->qual[active_cnt].node_cnt = node_cnt, stat = alterlist(active_pathways->qual[
      active_cnt].node_qual,node_cnt)
    FOOT REPORT
     active_pathways->cnt = active_cnt, stat = alterlist(active_pathways->qual,active_cnt)
    WITH nocounter
   ;end select
   CALL log_message(build2("Exit getActivePathways(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getdocumenttemplateid(null)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   CALL log_message("Begin getDocumentTemplateID()",log_level_debug)
   DECLARE doc_content_cd = f8 WITH noconstant(0), protect
   DECLARE template_cnt = i4 WITH noconstant(0), protect
   SET stat = uar_get_meaning_by_codeset(4003134,"DOCCONTENT",1,doc_content_cd)
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = active_pathways->cnt),
     (dummyt d2  WITH seq = 1),
     cp_component cc,
     cp_component_detail ccd
    PLAN (d1
     WHERE (active_pathways->cnt > 0)
      AND maxrec(d2,active_pathways->qual[d1.seq].node_cnt))
     JOIN (d2)
     JOIN (cc
     WHERE (cc.cp_component_id=active_pathways->qual[d1.seq].node_qual[d2.seq].cp_component_id))
     JOIN (ccd
     WHERE ccd.cp_component_id=cc.cp_component_id
      AND ccd.component_detail_reltn_cd=doc_content_cd
      AND ccd.component_ident > " ")
    ORDER BY ccd.component_ident
    HEAD d2.seq
     template_cnt = 0
    HEAD ccd.component_ident
     template_cnt += 1, stat = alterlist(active_pathways->qual[d1.seq].node_qual[d2.seq].trailjson,
      template_cnt), active_pathways->qual[d1.seq].node_qual[d2.seq].trailjson[template_cnt].
     template_id = ccd.component_ident,
     active_pathways->qual[d1.seq].node_qual[d2.seq].trailjson[template_cnt].version_number = ccd
     .version_nbr, active_pathways->qual[d1.seq].node_qual[d2.seq].template_cnt = template_cnt
    WITH nocounter
   ;end select
   CALL log_message(build2("Exit getDocumentTemplateID(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getsavedoceventtext(null)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   CALL log_message("Begin getSavedocEventText()",log_level_debug)
   DECLARE blob_data = vc WITH noconstant(""), protect
   DECLARE ocf_cd = f8 WITH noconstant(0), protect
   SET stat = uar_get_meaning_by_codeset(120,"OCFCOMP",1,ocf_cd)
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = active_pathways->cnt),
     (dummyt d2  WITH seq = 1),
     (dummyt d3  WITH seq = 1),
     clinical_event ce,
     ce_blob cb
    PLAN (d1
     WHERE (active_pathways->cnt > 0)
      AND maxrec(d2,active_pathways->qual[d1.seq].node_cnt))
     JOIN (d2
     WHERE maxrec(d3,active_pathways->qual[d1.seq].node_qual[d2.seq].template_cnt))
     JOIN (d3
     WHERE (active_pathways->qual[d1.seq].node_qual[d2.seq].trailjson[d3.seq].
     note_text_configured_ind=1))
     JOIN (ce
     WHERE (ce.event_id=active_pathways->qual[d1.seq].node_qual[d2.seq].latest_savedoc_id)
      AND ce.event_id > 0)
     JOIN (cb
     WHERE cb.event_id=ce.event_id
      AND cb.compression_cd=ocf_cd)
    HEAD ce.event_id
     blob_data = "", blobout = fillstring(32768," ")
    DETAIL
     CALL uar_ocf_uncompress(cb.blob_contents,cb.blob_length,blobout,size(blobout),32768), blob_data
      = build2(blob_data,blobout)
    FOOT  ce.event_id
     active_pathways->qual[d1.seq].node_qual[d2.seq].latest_savedoc_blob = replace(
      extractsavedocbodyhtml(blob_data)," .",".")
    WITH nocounter
   ;end select
   CALL log_message(build2("Exit getSavedocEventText(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getsortedattributes(null)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   CALL log_message("Begin getSortedAttributes()",log_level_debug)
   DECLARE sorted_attrib_menu_item_idx = i4 WITH noconstant(0), protect
   DECLARE sorted_attrib_idx = i4 WITH noconstant(0), protect
   DECLARE attrib_ocid = vc WITH noconstant(""), protect
   DECLARE idx = i4 WITH noconstant(0), protect
   DECLARE x = i4 WITH noconstant(0), protect
   DECLARE y = i4 WITH noconstant(0), protect
   DECLARE z = i4 WITH noconstant(0), protect
   DECLARE w = i4 WITH noconstant(0), protect
   FOR (x = 1 TO active_pathways->cnt)
     FOR (y = 1 TO active_pathways->qual[x].node_cnt)
       FOR (w = 1 TO active_pathways->qual[x].node_qual[y].template_cnt)
         SET stat = initrec(structure_template)
         SET stat = cnvtjsontorec(active_pathways->qual[x].node_qual[y].trailjson[w].
          structure_template)
         SET stat = initrec(sorted_attributes)
         FOR (z = 1 TO size(active_pathways->qual[x].node_qual[y].actions,5))
          SET attrib_ocid = getattributepropertyfromchildocid(active_pathways->qual[x].node_qual[y].
           actions[z].term_ocid,"ATTRIB_OCID")
          IF (attrib_ocid > "")
           SET sorted_attrib_idx = locateval(idx,1,sorted_attributes->attribute_cnt,attrib_ocid,
            sorted_attributes->attributes[idx].ocid)
           IF (sorted_attrib_idx=0)
            SET sorted_attributes->attribute_cnt += 1
            SET stat = alterlist(sorted_attributes->attributes,sorted_attributes->attribute_cnt)
            SET sorted_attributes->attributes[sorted_attributes->attribute_cnt].ocid = attrib_ocid
            SET sorted_attrib_idx = sorted_attributes->attribute_cnt
           ENDIF
           SET sorted_attrib_menu_item_idx = locateval(idx,1,sorted_attributes->attributes[
            sorted_attrib_idx].attribute_menu_item_cnt,active_pathways->qual[x].node_qual[y].actions[
            z].term_ocid,sorted_attributes->attributes[sorted_attrib_idx].attribute_menu_items[idx].
            ocid)
           IF (sorted_attrib_menu_item_idx=0)
            SET sorted_attributes->attributes[sorted_attrib_idx].attribute_menu_item_cnt += 1
            SET stat = alterlist(sorted_attributes->attributes[sorted_attrib_idx].
             attribute_menu_items,sorted_attributes->attributes[sorted_attrib_idx].
             attribute_menu_item_cnt)
            SET sorted_attributes->attributes[sorted_attrib_idx].attribute_menu_items[
            sorted_attributes->attributes[sorted_attrib_idx].attribute_menu_item_cnt].ocid =
            active_pathways->qual[x].node_qual[y].actions[z].term_ocid
           ENDIF
          ENDIF
         ENDFOR
         SET active_pathways->qual[x].node_qual[y].trailjson[w].sorted_attributes = cnvtrectojson(
          sorted_attributes)
       ENDFOR
     ENDFOR
   ENDFOR
   CALL log_message(build2("Exit getSortedAttributes(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getstructuredoctemplate(null)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   CALL log_message("Begin getStructureDocTemplate()",log_level_debug)
   DECLARE x = i4 WITH noconstant(0), protect
   DECLARE y = i4 WITH noconstant(0), protect
   DECLARE z = i4 WITH noconstant(0), protect
   FOR (x = 1 TO active_pathways->cnt)
     FOR (y = 1 TO active_pathways->qual[x].node_cnt)
       FOR (z = 1 TO active_pathways->qual[x].node_qual[y].template_cnt)
         EXECUTE cp_load_structure_doc "NOFORMS", active_pathways->qual[x].node_qual[y].trailjson[z].
         template_id WITH replace(record_data,structure_template)
         IF (size(structure_template->section_ref,5) > 0
          AND size(structure_template->section_ref[0].template_rltns) > 0)
          SET active_pathways->qual[x].node_qual[y].trailjson[z].template_instance_identifier =
          structure_template->section_ref[0].template_rltns[0].dd_sref_templ_instance_ident
         ENDIF
         SET active_pathways->qual[x].node_qual[y].trailjson[z].structure_template = cnvtrectojson(
          structure_template)
       ENDFOR
     ENDFOR
   ENDFOR
   CALL log_message(build2("Exit getStructureDocTemplate(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE gettranslatedvalue(value_ident)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   CALL log_message("Begin getTranslatedValue()",log_level_debug)
   DECLARE en_val = vc WITH noconstant(""), protect
   CASE (value_ident)
    OF "HEADER_TEXT_STRING":
     SET en_val = "The patient is being treated with consideration to the following criteria:"
    OF "NO_ANSWERS_STRING":
     SET en_val =
     "No questions and answers have been selected in the Treatment Assessment Component."
    OF "NO_STRING":
     SET en_val = "No"
    OF "YES_STRING":
     SET en_val = "Yes"
   ENDCASE
   CALL log_message(build2("Exit getTranslatedValue(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
   RETURN(uar_i18ngetmessage(i18n_handle,value_ident,nullterm(en_val)))
 END ;Subroutine
 SUBROUTINE main(null)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   CALL log_message("Begin main()",log_level_debug)
   SET pid = cnvtreal(request->person[1].person_id)
   SET eid = cnvtreal(request->visit[1].encntr_id)
   CALL getactivepathways(null)
   IF ((active_pathways->cnt > 0))
    CALL getactivepathwayactions(null)
    CALL getdocumenttemplateid(null)
    CALL getstructuredoctemplate(null)
    CALL checkifnotetextisconfigured(null)
    CALL getsavedoceventtext(null)
    CALL getsortedattributes(null)
    CALL generatesortedsavedocbloblist(null)
    CALL generatenodeoutput(null)
    CALL generateoutput(null)
    IF (validate(debug_ind,0)=1)
     CALL echorecord(active_pathways)
    ENDIF
   ENDIF
   CALL log_message(build2("Exit main(), Elapsed time in seconds:",((curtime3 - begin_curtime3)/
     100.0)),log_level_debug)
 END ;Subroutine
 CALL main(null)
#exit_script
 CALL log_message(concat("Exiting script: ",log_program_name),log_level_debug)
 CALL log_message(build2("Total time in seconds:",((curtime3 - script_start_curtime3)/ 100.0)),
  log_level_debug)
END GO
