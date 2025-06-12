CREATE PROGRAM cp_smrt_tmplt_current_visit:dba
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
 IF (validate(optimers)=0)
  RECORD optimers(
    1 cnt = i4
    1 qual[*]
      2 operationdisplay = vc
      2 operationtype = vc
      2 operationmeaning = vc
      2 begintime = dq8
      2 endtime = dq8
      2 elapsedhsec = f8
  ) WITH protect
 ENDIF
 IF (validate(prim_event_cd)=0)
  RECORD prim_event_cd(
    1 prim_event_cd_cnt = i4
    1 prim_event_cds[*]
      2 event_cat_mean = vc
      2 event_cd = f8
      2 event_cd_disp = vc
  ) WITH protect
 ENDIF
 IF (validate(encntrs)=0)
  FREE RECORD encntrs
  RECORD encntrs(
    1 prsnl_cnt = i4
    1 prsnl_list[*]
      2 prsnl_id = f8
      2 person_cnt = i4
      2 person_list[*]
        3 person_id = f8
        3 last_updt_dt_tm = dq8
        3 encntr_cnt = i4
        3 encntr_list[*]
          4 value = f8
  ) WITH persist
 ENDIF
 DECLARE execute_cust_prg(_proj=vc,_page=vc,_recname=vc) = vc
 DECLARE initoptimers(null) = null WITH protect
 DECLARE initprimeventsets(null) = null WITH protect
 DECLARE loadprimeventsets(null) = null WITH protect
 DECLARE tempchar = vc WITH protect, noconstant("")
 DECLARE tempdttm = dq8 WITH protect
 DECLARE stat = i4 WITH protect
 DECLARE requestblobin = vc WITH protect, noconstant("")
 IF (validate(request->blob_in))
  SET request->blob_in = trim(request->blob_in,3)
  IF ((request->blob_in > ""))
   SET requestblobin = request->blob_in
  ENDIF
 ENDIF
 SUBROUTINE (formatfreetext(freetext=vc) =vc)
   DECLARE formattedfreetext = vc WITH protect, noconstant(freetext)
   SET formattedfreetext = replace(formattedfreetext,char(9),"    ",0)
   SET formattedfreetext = replace(formattedfreetext,char(10),char(13),0)
   SET formattedfreetext = replace(formattedfreetext,concat(char(13),char(13)),char(13),0)
   SET formattedfreetext = replace(formattedfreetext,char(13)," <br/>",0)
   RETURN(formattedfreetext)
 END ;Subroutine
 SUBROUTINE (formathtmlcharactercodes(freetext=vc) =vc)
   DECLARE formattedfreetext = vc WITH protect, noconstant(freetext)
   SET formattedfreetext = replace(formattedfreetext,"&#34;",'"',0)
   SET formattedfreetext = replace(formattedfreetext,"&#94;","^",0)
   SET formattedfreetext = replace(formattedfreetext,"&#10;",char(10),0)
   SET formattedfreetext = replace(formattedfreetext,"&#13;",char(13),0)
   RETURN(formattedfreetext)
 END ;Subroutine
 SUBROUTINE (errorhandler(operationname=vc,operationstatus=c1,targetobjectname=vc,recorddata=vc(ref)
  ) =null)
   DECLARE serrmsg = c132 WITH protect, noconstant(" ")
   DECLARE ierrcode = i4 WITH protect, noconstant(error(serrmsg,1))
   DECLARE error_cnt = i2 WITH private, noconstant(0)
   SET error_cnt = size(recorddata->status_data.subeventstatus,5)
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     IF (((error_cnt > 1) OR (error_cnt=1
      AND (recorddata->status_data.subeventstatus[error_cnt].operationstatus != ""))) )
      SET error_cnt += 1
     ENDIF
     SET lstat = alter(recorddata->status_data.subeventstatus,error_cnt)
     SET recorddata->status_data.status = "F"
     SET recorddata->status_data.subeventstatus[error_cnt].operationname = trim(operationname)
     SET recorddata->status_data.subeventstatus[error_cnt].operationstatus = trim(operationstatus)
     SET recorddata->status_data.subeventstatus[error_cnt].targetobjectname = trim(targetobjectname)
     SET recorddata->status_data.subeventstatus[error_cnt].targetobjectvalue = trim(serrmsg)
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
 END ;Subroutine
 SUBROUTINE (ajaxreply(jsonstr=vc) =null)
   IF (trim(jsonstr) != "")
    IF (validate(_memory_reply_string))
     SET _memory_reply_string = jsonstr
    ELSE
     FREE SET putrequest
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
     FREE SET putreply
     RECORD putreply(
       1 info_line[*]
         2 new_line = vc
       1 status_data
         2 status = c1
         2 subeventstatus[1]
           3 operationname = c25
           3 operationstatus = c1
           3 targetobjectname = c25
           3 targetobjectvalue = vc
     )
     SET putrequest->source_dir =  $OUTDEV
     SET putrequest->isblob = "1"
     SET putrequest->document_size = size(jsonstr)
     SET putrequest->document = jsonstr
     EXECUTE eks_put_source  WITH replace(request,"PUTREQUEST"), replace(reply,"PUTREPLY")
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (loadeventcodes(eventsetcd=f8) =null)
   SELECT INTO "nl:"
    FROM v500_event_set_explode e
    PLAN (e
     WHERE e.event_set_cd=eventsetcd)
    ORDER BY e.event_cd
    DETAIL
     CALL loadeventcd(e.event_cd)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE execute_cust_prg(_proj,_page,_recname,_page2,_recname2)
   FREE RECORD ic_exec_cmds
   RECORD ic_exec_cmds(
     1 cnt = i4
     1 qual[*]
       2 cmd = vc
   )
   SET stat = initrec(ic_exec_cmds)
   DECLARE execstr = vc WITH protect, noconstant(" ")
   IF (checkdic("CUST_COND_SUMMARY_DATA","T",0) != 0)
    SELECT INTO "nl:"
     FROM cust_cond_summary_data c
     PLAN (c
      WHERE c.project=_proj
       AND c.section_name=_page
       AND c.data_type="XTRA")
     ORDER BY c.long_desc
     HEAD REPORT
      row + 0, cntr = 0,
      CALL echo(build("MPAGE ---->",_page)),
      CALL echo(build("RECORD ---->",_recname))
     HEAD c.long_desc
      IF (checkprg(cnvtupper(trim(c.long_desc))) > 0)
       cntr += 1
       IF (mod(cntr,10)=1)
        now = alterlist(ic_exec_cmds->qual,(cntr+ 9))
       ENDIF
       execstr = build2("execute ",trim(c.long_desc),' with replace ("',_page,'","',
        _recname,'") ',', replace ("',_page2,'","',
        _recname2,'") go'), ic_exec_cmds->qual[cntr].cmd = execstr,
       CALL echo(build("EXECUTING ---->",execstr))
      ELSE
       CALL echo(build("PROGRAM NOT FOUND ---->",trim(c.long_desc)))
      ENDIF
     FOOT REPORT
      now = alterlist(ic_exec_cmds->qual,cntr), ic_exec_cmds->cnt = cntr
     WITH nocounter
    ;end select
    CALL echorecord(ic_exec_cmds)
    FOR (i = 1 TO ic_exec_cmds->cnt)
      CALL parser(ic_exec_cmds->qual[i].cmd)
    ENDFOR
    IF ((ic_exec_cmds->cnt > 0))
     CALL parser(concat("call echorecord( ",_recname," ) go"))
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE initprimeventsets(null)
   SET stat = initrec(prim_event_cd)
 END ;Subroutine
 SUBROUTINE (addprimeventsetcd(event_cd=f8) =null WITH protect)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   SET prim_event_cd->prim_event_cd_cnt += 1
   SET cnt = prim_event_cd->prim_event_cd_cnt
   IF (mod(cnt,10)=1)
    SET stat = alterlist(prim_event_cd->prim_event_cds,(cnt+ 9))
   ENDIF
   SET prim_event_cd->prim_event_cds[cnt].event_cd = event_cd
   SET prim_event_cd->prim_event_cds[cnt].event_cd_disp = trim(uar_get_code_display(event_cd))
   SET prim_event_cd->prim_event_cds[cnt].event_cat_mean = cur_event_cat_mean
 END ;Subroutine
 SUBROUTINE loadprimeventsets(null)
   SET stat = alterlist(prim_event_cd->prim_event_cds,prim_event_cd->prim_event_cd_cnt)
   CALL echorecord(prim_event_cd)
   DECLARE idx = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = prim_event_cd->prim_event_cd_cnt),
     v500_event_set_explode e
    PLAN (d1)
     JOIN (e
     WHERE (e.event_set_cd=prim_event_cd->prim_event_cds[d1.seq].event_cd)
      AND e.event_cd > 0.0)
    ORDER BY e.event_cd
    DETAIL
     cur_event_cat_mean = prim_event_cd->prim_event_cds[d1.seq].event_cat_mean,
     CALL loadeventcd(e.event_cd)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE (addnewrequesteventcd(event_cd=f8,event_cat_mean=vc,event_cat_seq=i4) =f8 WITH protect)
   DECLARE event_cd_index = i4 WITH protect, noconstant(0)
   SET request->event_cd_cnt += 1
   SET event_cd_index = request->event_cd_cnt
   IF ((size(request->event_cds,5) < request->event_cd_cnt))
    SET stat = alterlist(request->event_cds,(event_cd_index+ 9))
   ENDIF
   SET request->event_cds[event_cd_index].event_cd = event_cd
   SET request->event_cds[event_cd_index].event_cd_disp = trim(uar_get_code_display(event_cd))
   SET request->event_cds[event_cd_index].event_cat_mean = event_cat_mean
   SET request->event_cds[event_cd_index].event_cat_seq = event_cat_seq
   RETURN(event_cd_index)
 END ;Subroutine
 SUBROUTINE (addnewrequesteventcdcatmean(event_cd_index=i4,event_cat_mean=vc,event_cat_seq=i4) =null
  WITH protect)
   DECLARE cat_mean_cnt = i4 WITH protect, noconstant(0)
   SET cat_mean_cnt = (request->event_cds[event_cd_index].event_cat_mean_cnt+ 1)
   SET request->event_cds[event_cd_index].event_cat_mean_cnt = cat_mean_cnt
   SET stat = alterlist(request->event_cds[event_cd_index].event_cat_means,cat_mean_cnt)
   SET request->event_cds[event_cd_index].event_cat_means[cat_mean_cnt].event_cat_mean =
   event_cat_mean
   SET request->event_cds[event_cd_index].event_cat_means[cat_mean_cnt].event_cat_seq = event_cat_seq
 END ;Subroutine
 SUBROUTINE (addnewrequestmicroeventcd(event_cd=f8,event_cat_mean=vc,event_cat_seq=i4) =f8 WITH
  protect)
   DECLARE event_cd_index = i4 WITH protect, noconstant(0)
   SET request->micro_event_cnt += 1
   SET event_cd_index = request->micro_event_cnt
   IF ((size(request->micro_event_cds,5) < request->micro_event_cnt))
    SET stat = alterlist(request->micro_event_cds,(event_cd_index+ 9))
   ENDIF
   SET request->micro_event_cds[event_cd_index].event_cd = event_cd
   SET request->micro_event_cds[event_cd_index].event_cd_disp = trim(uar_get_code_display(event_cd))
   SET request->micro_event_cds[event_cd_index].event_cat_mean = event_cat_mean
   SET request->micro_event_cds[event_cd_index].event_cat_seq = event_cat_seq
   RETURN(event_cd_index)
 END ;Subroutine
 SUBROUTINE (addnewrequestmicroeventcdcatmean(event_cd_index=i4,event_cat_mean=vc,event_cat_seq=i4) =
  null WITH protect)
   DECLARE cat_mean_cnt = i4 WITH protect, noconstant(0)
   SET cat_mean_cnt = (request->micro_event_cds[event_cd_index].event_cat_mean_cnt+ 1)
   SET request->micro_event_cds[event_cd_index].event_cat_mean_cnt = cat_mean_cnt
   SET stat = alterlist(request->micro_event_cds[event_cd_index].event_cat_means,cat_mean_cnt)
   SET request->micro_event_cds[event_cd_index].event_cat_means[cat_mean_cnt].event_cat_mean =
   event_cat_mean
   SET request->micro_event_cds[event_cd_index].event_cat_means[cat_mean_cnt].event_cat_seq =
   event_cat_seq
 END ;Subroutine
 SUBROUTINE (findreplyeventcdcatmean(pt_index=i4,ce_index=i4,event_cat_mean=vc) =i4 WITH protect)
   DECLARE search_num = i4 WITH protect, noconstant(0)
   DECLARE event_cat_mean_index = i4 WITH protect, noconstant(0)
   SET event_cat_mean_index = locateval(search_num,1,reply->pts[pt_index].ce[ce_index].
    event_cat_mean_cnt,event_cat_mean,reply->pts[pt_index].ce[ce_index].event_cat_means[search_num].
    event_cat_mean)
   RETURN(event_cat_mean_index)
 END ;Subroutine
 SUBROUTINE (findreplymicroeventcdcatmean(pt_index=i4,ce_index=i4,event_cat_mean=vc) =i4 WITH protect
  )
   DECLARE search_num = i4 WITH protect, noconstant(0)
   DECLARE event_cat_mean_index = i4 WITH protect, noconstant(0)
   SET event_cat_mean_index = locateval(search_num,1,reply->pts[pt_index].micro_ce[ce_index].
    event_cat_mean_cnt,event_cat_mean,reply->pts[pt_index].micro_ce[ce_index].event_cat_means[
    search_num].event_cat_mean)
   RETURN(event_cat_mean_index)
 END ;Subroutine
 SUBROUTINE (loadclinicaleventcd(event_cd=f8,event_cat_mean=vc,event_cat_seq=i4) =null WITH protect)
   DECLARE search_num = i4 WITH protect, noconstant(0)
   DECLARE event_cd_index = i4 WITH protect, noconstant(0)
   SET event_cd_index = locateval(search_num,1,request->event_cd_cnt,event_cd,request->event_cds[
    search_num].event_cd)
   IF (event_cd_index > 0)
    IF (locateval(search_num,1,request->event_cds[event_cd_index].event_cat_mean_cnt,event_cat_mean,
     request->event_cds[event_cd_index].event_cat_means[search_num].event_cat_mean) > 0)
     RETURN(null)
    ENDIF
   ELSE
    SET event_cd_index = addnewrequesteventcd(event_cd,event_cat_mean,event_cat_seq)
   ENDIF
   CALL addnewrequesteventcdcatmean(event_cd_index,event_cat_mean,event_cat_seq)
   SET event_cd_index = locateval(search_num,1,request->micro_event_cnt,event_cd,request->
    micro_event_cds[search_num].event_cd)
   IF (event_cd_index > 0)
    CALL addnewrequestmicroeventcdcatmean(event_cd_index,event_cat_mean,event_cat_seq)
   ENDIF
   RETURN(null)
 END ;Subroutine
 SUBROUTINE (loadmicroclinicaleventcd(event_cd=f8,event_cat_mean=vc,event_cat_seq=i4) =null WITH
  protect)
   DECLARE search_num = i4 WITH protect, noconstant(0)
   DECLARE cat_mean_cnt = i4 WITH protect, noconstant(0)
   DECLARE event_cd_index = i4 WITH protect, noconstant(0)
   SET event_cd_index = locateval(search_num,1,request->micro_event_cnt,event_cd,request->
    micro_event_cds[search_num].event_cd)
   IF (event_cd_index > 0)
    IF (locateval(search_num,1,request->micro_event_cds[event_cd_index].event_cat_mean_cnt,
     event_cat_mean,request->micro_event_cds[event_cd_index].event_cat_means[search_num].
     event_cat_mean) > 0)
     RETURN(null)
    ENDIF
   ELSE
    SET event_cd_index = addnewrequestmicroeventcd(event_cd,event_cat_mean,event_cat_seq)
   ENDIF
   CALL addnewrequestmicroeventcdcatmean(event_cd_index,event_cat_mean,event_cat_seq)
   SET event_cd_index = locateval(search_num,1,request->event_cd_cnt,event_cd,request->event_cds[
    search_num].event_cd)
   IF (event_cd_index > 0)
    CALL addnewrequesteventcdcatmean(event_cd_index,event_cat_mean,event_cat_seq)
   ENDIF
   RETURN(null)
 END ;Subroutine
 SUBROUTINE initoptimers(null)
   SET stat = initrec(optimers)
 END ;Subroutine
 SUBROUTINE (startoptimer(operationmeaning=vc,operationtype=vc,operationdisplay=vc,updateind=i2) =i4
  WITH protect)
   DECLARE timerseq = i4 WITH protect, noconstant(0)
   DECLARE createind = i4 WITH protect, noconstant(0)
   IF (updateind)
    SET createind = 0
   ELSE
    SET createind = 1
   ENDIF
   SET timerseq = getoptimerseq(operationmeaning,1)
   IF (timerseq > 0)
    SET optimers->qual[timerseq].operationmeaning = operationmeaning
    SET optimers->qual[timerseq].operationtype = operationtype
    SET optimers->qual[timerseq].operationdisplay = operationdisplay
    SET optimers->qual[timerseq].begintime = cnvtdatetime(sysdate)
   ENDIF
   RETURN(timerseq)
 END ;Subroutine
 SUBROUTINE (stopoptimer(operationmeaning=vc) =i4 WITH protect)
   DECLARE timerseq = i4 WITH protect, noconstant(0)
   SET timerseq = getoptimerseq(operationmeaning,0)
   IF (timerseq > 0)
    SET optimers->qual[timerseq].endtime = cnvtdatetime(sysdate)
    SET optimers->qual[timerseq].elapsedhsec = datetimediff(optimers->qual[timerseq].endtime,optimers
     ->qual[timerseq].begintime,6)
   ENDIF
   RETURN(timerseq)
 END ;Subroutine
 SUBROUTINE (getoptimerseq(operationmeaning=vc,createind=i2) =i4 WITH protect)
   DECLARE timerseq = i4 WITH protect, noconstant(0)
   DECLARE tcntr = i4 WITH protect, noconstant(0)
   IF (createind=1)
    SET optimers->cnt += 1
    SET stat = alterlist(optimers->qual,optimers->cnt)
    SET timerseq = optimers->cnt
   ELSE
    SET timerseq = locateval(tcntr,1,optimers->cnt,operationmeaning,optimers->qual[tcntr].
     operationmeaning)
   ENDIF
   RETURN(timerseq)
 END ;Subroutine
 SUBROUTINE (addcatalogcd(referencerecord=vc(ref),code=f8,event_cat_mean=vc) =null WITH protect)
   DECLARE search_cntr = i4 WITH protect, noconstant(0)
   DECLARE cur_code_index = i4 WITH protect, noconstant(0)
   DECLARE cur_event_cat_mean_index = i4 WITH protect, noconstant(0)
   IF (validate(referencerecord)=1)
    SET cur_code_index = locateval(search_cntr,1,referencerecord->catalog_cd_cnt,code,referencerecord
     ->catalog_cds[search_cntr].catalog_cd)
    IF (cur_code_index=0)
     SET referencerecord->catalog_cd_cnt += 1
     SET cur_code_index = referencerecord->catalog_cd_cnt
     SET stat = alterlist(referencerecord->catalog_cds,referencerecord->catalog_cd_cnt)
     SET referencerecord->catalog_cds[cur_code_index].catalog_cd = code
     SET referencerecord->catalog_cds[cur_code_index].catalog_cd_disp = trim(uar_get_code_display(
       code))
    ENDIF
    IF (locateval(search_cntr,1,referencerecord->catalog_cds[cur_code_index].event_cat_mean_cnt,trim(
      event_cat_mean),referencerecord->catalog_cds[cur_code_index].event_cat_means[search_cntr].
     event_cat_mean)=0)
     SET referencerecord->catalog_cds[cur_code_index].event_cat_mean_cnt += 1
     SET cur_event_cat_mean_index = referencerecord->catalog_cds[cur_code_index].event_cat_mean_cnt
     SET stat = alterlist(referencerecord->catalog_cds[cur_code_index].event_cat_means,
      referencerecord->catalog_cds[cur_code_index].event_cat_mean_cnt)
     SET referencerecord->catalog_cds[cur_code_index].event_cat_means[cur_event_cat_mean_index].
     event_cat_mean = event_cat_mean
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (addactivitytypecd(referencerecord=vc(ref),code=f8,event_cat_mean=vc) =null WITH protect)
   DECLARE search_cntr = i4 WITH protect, noconstant(0)
   DECLARE cur_code_index = i4 WITH protect, noconstant(0)
   DECLARE cur_event_cat_mean_index = i4 WITH protect, noconstant(0)
   IF (validate(referencerecord)=1)
    SET cur_code_index = locateval(search_cntr,1,referencerecord->activity_type_cd_cnt,code,
     referencerecord->activity_type_cds[search_cntr].activity_type_cd)
    IF (cur_code_index=0)
     SET referencerecord->activity_type_cd_cnt += 1
     SET cur_code_index = referencerecord->activity_type_cd_cnt
     SET stat = alterlist(referencerecord->activity_type_cds,referencerecord->activity_type_cd_cnt)
     SET referencerecord->activity_type_cds[cur_code_index].activity_type_cd = code
     SET referencerecord->activity_type_cds[cur_code_index].activity_type_cd_disp = trim(
      uar_get_code_display(code))
    ENDIF
    IF (locateval(search_cntr,1,referencerecord->activity_type_cds[cur_code_index].event_cat_mean_cnt,
     trim(event_cat_mean),referencerecord->activity_type_cds[cur_code_index].event_cat_means[
     search_cntr].event_cat_mean)=0)
     SET referencerecord->activity_type_cds[cur_code_index].event_cat_mean_cnt += 1
     SET cur_event_cat_mean_index = referencerecord->activity_type_cds[cur_code_index].
     event_cat_mean_cnt
     SET stat = alterlist(referencerecord->activity_type_cds[cur_code_index].event_cat_means,
      referencerecord->activity_type_cds[cur_code_index].event_cat_mean_cnt)
     SET referencerecord->activity_type_cds[cur_code_index].event_cat_means[cur_event_cat_mean_index]
     .event_cat_mean = event_cat_mean
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (addcatalogtypecd(referencerecord=vc(ref),code=f8,event_cat_mean=vc) =null WITH protect)
   DECLARE search_cntr = i4 WITH protect, noconstant(0)
   DECLARE cur_code_index = i4 WITH protect, noconstant(0)
   DECLARE cur_event_cat_mean_index = i4 WITH protect, noconstant(0)
   IF (validate(referencerecord)=1)
    SET cur_code_index = locateval(search_cntr,1,referencerecord->catalog_type_cd_cnt,code,
     referencerecord->catalog_type_cds[search_cntr].catalog_type_cd)
    IF (cur_code_index=0)
     SET referencerecord->catalog_type_cd_cnt += 1
     SET cur_code_index = referencerecord->catalog_type_cd_cnt
     SET stat = alterlist(referencerecord->catalog_type_cds,referencerecord->catalog_type_cd_cnt)
     SET referencerecord->catalog_type_cds[cur_code_index].catalog_type_cd = code
     SET referencerecord->catalog_type_cds[cur_code_index].catalog_type_cd_disp = trim(
      uar_get_code_display(code))
    ENDIF
    IF (locateval(search_cntr,1,referencerecord->catalog_type_cds[cur_code_index].event_cat_mean_cnt,
     trim(event_cat_mean),referencerecord->catalog_type_cds[cur_code_index].event_cat_means[
     search_cntr].event_cat_mean)=0)
     SET referencerecord->catalog_type_cds[cur_code_index].event_cat_mean_cnt += 1
     SET cur_event_cat_mean_index = referencerecord->catalog_type_cds[cur_code_index].
     event_cat_mean_cnt
     SET stat = alterlist(referencerecord->catalog_type_cds[cur_code_index].event_cat_means,
      referencerecord->catalog_type_cds[cur_code_index].event_cat_mean_cnt)
     SET referencerecord->catalog_type_cds[cur_code_index].event_cat_means[cur_event_cat_mean_index].
     event_cat_mean = event_cat_mean
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (getbedrockfilterindexbymeaning(filtermeaning=vc) =i4 WITH protect)
   DECLARE filter_index = i4 WITH protect, noconstant(0)
   DECLARE filter_size = i4 WITH protect, noconstant(0)
   DECLARE search_cntr = i4 WITH protect, noconstant(0)
   SET filter_size = size(filter->filters,5)
   SET filter_index = locateval(search_cntr,1,filter_size,filtermeaning,filter->filters[search_cntr].
    fileventmean)
   RETURN(filter_index)
 END ;Subroutine
 SUBROUTINE (loadbedrockcodevalues(filtermeaning=vc,referencerecord=vc(ref),event_cat_mean=vc) =null
  WITH protect)
   DECLARE filter_index = i4 WITH protect, noconstant(0)
   DECLARE val_cntr = i4 WITH protect, noconstant(0)
   DECLARE val_size = i4 WITH protect, noconstant(0)
   DECLARE val_idx = i4 WITH protect, noconstant(0)
   SET filter_index = getbedrockfilterindexbymeaning(filtermeaning)
   IF (filter_index > 0)
    SET val_size = size(filter->filters[filter_index].values,5)
    FOR (val_cntr = 1 TO val_size)
      CASE (filter->filters[filter_index].fileventcatmean)
       OF "ACTIVITY_TYPE_CDS":
        CALL addactivitytypecd(referencerecord,filter->filters[filter_index].values[val_cntr].
         valeventcd,event_cat_mean)
       OF "CATALOG_TYPE_CDS":
        CALL addcatalogtypecd(referencerecord,filter->filters[filter_index].values[val_cntr].
         valeventcd,event_cat_mean)
       OF "ORDER":
        CALL addcatalogcd(referencerecord,filter->filters[filter_index].values[val_cntr].valeventcd,
         event_cat_mean)
       OF "PRIM_EVENT_SET":
       OF "EVENT_SET":
        CALL addeventsetcd(referencerecord,filter->filters[filter_index].values[val_cntr].valeventcd,
         event_cat_mean)
       OF "EVENT":
        CALL addeventcd(referencerecord,filter_index,val_cntr,event_cat_mean)
       OF "ORDER_ENTRY_FIELD_CDS":
        CALL addorderentryfieldcd(referencerecord,filter->filters[filter_index].values[val_cntr].
         valeventcd,event_cat_mean)
       ELSE
        CALL addcodevalue(referencerecord,filter->filters[filter_index].values[val_cntr].valeventcd,
         event_cat_mean)
      ENDCASE
    ENDFOR
    IF ((filter->filters[filter_index].fileventcatmean IN ("PRIM_EVENT_SET", "EVENT_SET")))
     SET val_size = size(referencerecord->event_set_cds,5)
     IF (val_size > 0
      AND validate(referencerecord->event_set_cds[1].event_set_name))
      SELECT INTO "nl:"
       FROM v500_event_set_code v
       PLAN (v
        WHERE expand(val_cntr,1,val_size,v.event_set_cd,referencerecord->event_set_cds[val_cntr].
         event_set_cd))
       ORDER BY v.event_set_cd
       HEAD v.event_set_cd
        val_idx = locateval(val_cntr,1,val_size,v.event_set_cd,referencerecord->event_set_cds[
         val_cntr].event_set_cd), referencerecord->event_set_cds[val_idx].event_set_name = trim(v
         .event_set_name,3)
       WITH nocounter
      ;end select
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (loadbedrockfreetextvalue(filtermeaning=vc,valuetype=vc,referencevariable=vc(ref)) =null
  WITH protect)
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
 SUBROUTINE (populatepatientupdateeventlist(updatedata=vc(ref),pt_index=i4,eventset_list=vc(ref)) =
  null WITH protect)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE evtsetcnt = i4 WITH noconstant(0), protect
   SELECT INTO "nl:"
    evt_cd = updatedata->data[pt_index].clineventlist[d.seq].event_cd
    FROM (dummyt d  WITH seq = size(updatedata->data[pt_index].clineventlist,5)),
     v500_event_set_explode vese
    PLAN (d)
     JOIN (vese
     WHERE (vese.event_cd=updatedata->data[pt_index].clineventlist[d.seq].event_cd))
    ORDER BY evt_cd
    HEAD evt_cd
     evtsetcnt += 1, stat = alterlist(eventset_list->qual,evtsetcnt), eventset_list->qual[evtsetcnt].
     value = updatedata->data[pt_index].clineventlist[d.seq].event_cd
    DETAIL
     evtsetcnt += 1, stat = alterlist(eventset_list->qual,evtsetcnt), eventset_list->qual[evtsetcnt].
     value = vese.event_set_cd
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE (checkcelistinbrfilters(eventset_list=vc(ref),filter_record=vc(ref)) =i2 WITH protect)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE checkcelist = i2 WITH noconstant(0), protect
   SELECT INTO "nl:"
    br_val = filter_record->filters[d.seq].values[d1.seq].valeventcd
    FROM (dummyt d  WITH seq = size(filter_record->filters,5)),
     (dummyt d1  WITH seq = 1),
     (dummyt d2  WITH seq = size(eventset_list->qual,5))
    PLAN (d
     WHERE maxrec(d1,size(filter_record->filters[d.seq].values,5))
      AND (filter_record->filters[d.seq].fileventcatmean IN ("EVENT", "EVENT_SET", "PRIM_EVENT_SET"))
     )
     JOIN (d1)
     JOIN (d2
     WHERE (eventset_list->qual[d2.seq].value=filter_record->filters[d.seq].values[d1.seq].valeventcd
     ))
    WITH nocounter
   ;end select
   IF (curqual > 0)
    SET checkcelist = 1
   ENDIF
   RETURN(checkcelist)
 END ;Subroutine
 SUBROUTINE (populatepatientupdateorderlist(updatedata=vc(ref),pt_index=i4,ordercd_list=vc(ref)) =
  null WITH protect)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE ordcdcnt = i4 WITH noconstant(0), protect
   SELECT INTO "nl:"
    order_id = updatedata->data[pt_index].orderlist[d.seq].order_id
    FROM (dummyt d  WITH seq = size(updatedata->data[pt_index].orderlist,5)),
     orders o
    PLAN (d)
     JOIN (o
     WHERE (o.order_id=updatedata->data[pt_index].orderlist[d.seq].order_id))
    ORDER BY o.catalog_type_cd, o.activity_type_cd, o.catalog_cd
    HEAD o.catalog_type_cd
     ordcdcnt += 1, stat = alterlist(ordercd_list->qual,ordcdcnt), ordercd_list->qual[ordcdcnt].value
      = o.catalog_type_cd
    HEAD o.activity_type_cd
     ordcdcnt += 1, stat = alterlist(ordercd_list->qual,ordcdcnt), ordercd_list->qual[ordcdcnt].value
      = o.activity_type_cd
    HEAD o.catalog_cd
     ordcdcnt += 1, stat = alterlist(ordercd_list->qual,ordcdcnt), ordercd_list->qual[ordcdcnt].value
      = o.catalog_cd
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE (checkorderlistinbrfilters(ordercd_list=vc(ref),filter_record=vc(ref)) =i2 WITH protect)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE checkorderlist = i2 WITH noconstant(0), protect
   SELECT INTO "nl:"
    br_val = filter_record->filters[d.seq].values[d1.seq].valeventcd
    FROM (dummyt d  WITH seq = size(filter_record->filters,5)),
     (dummyt d1  WITH seq = 1),
     (dummyt d2  WITH seq = size(ordercd_list->qual,5))
    PLAN (d
     WHERE maxrec(d1,size(filter_record->filters[d.seq].values,5))
      AND (filter_record->filters[d.seq].fileventcatmean IN ("ACTIVITY_TYPE_CDS", "CATALOG_TYPE_CDS",
     "ORDER")))
     JOIN (d1)
     JOIN (d2
     WHERE (ordercd_list->qual[d2.seq].value=filter_record->filters[d.seq].values[d1.seq].valeventcd)
     )
    WITH nocounter
   ;end select
   IF (curqual > 0)
    SET checkorderlist = 1
   ENDIF
   RETURN(checkorderlist)
 END ;Subroutine
 SUBROUTINE (getbestbatchsize(querysize=i4) =i4 WITH protect)
   IF (querysize <= 1)
    RETURN(querysize)
   ELSEIF (querysize <= 5)
    RETURN(5)
   ELSEIF (querysize <= 10)
    RETURN(10)
   ENDIF
   DECLARE minquerycount = i4 WITH constant(((querysize+ 199)/ 200))
   DECLARE bestbatchsize = i4 WITH constant(ceil((cnvtreal(querysize)/ minquerycount)))
   RETURN((20 * ceil((cnvtreal(bestbatchsize)/ 20))))
 END ;Subroutine
 SUBROUTINE (addproblemnomenclature(referencerecord=vc(ref),nomenclature_id=f8,display=vc,
  event_cat_mean=vc) =null WITH protect)
   DECLARE search_cntr = i4 WITH protect, noconstant(0)
   DECLARE cur_code_index = i4 WITH protect, noconstant(0)
   DECLARE cur_event_cat_mean_index = i4 WITH protect, noconstant(0)
   IF (validate(referencerecord)=1)
    SET cur_code_index = locateval(search_cntr,1,referencerecord->nomenclature_id_cnt,nomenclature_id,
     referencerecord->nomenclature_ids[search_cntr].nomenclature_id)
    IF (cur_code_index=0)
     SET referencerecord->nomenclature_id_cnt += 1
     SET cur_code_index = referencerecord->nomenclature_id_cnt
     SET stat = alterlist(referencerecord->nomenclature_ids,referencerecord->nomenclature_id_cnt)
     SET referencerecord->nomenclature_ids[cur_code_index].nomenclature_id = nomenclature_id
     SET referencerecord->nomenclature_ids[cur_code_index].nomenclature_disp = trim(display,3)
    ENDIF
    IF (locateval(search_cntr,1,referencerecord->nomenclature_ids[cur_code_index].event_cat_mean_cnt,
     trim(event_cat_mean),referencerecord->nomenclature_ids[cur_code_index].event_cat_means[
     search_cntr].event_cat_mean)=0)
     SET referencerecord->nomenclature_ids[cur_code_index].event_cat_mean_cnt += 1
     SET cur_event_cat_mean_index = referencerecord->nomenclature_ids[cur_code_index].
     event_cat_mean_cnt
     SET stat = alterlist(referencerecord->nomenclature_ids[cur_code_index].event_cat_means,
      referencerecord->nomenclature_ids[cur_code_index].event_cat_mean_cnt)
     SET referencerecord->nomenclature_ids[cur_code_index].event_cat_means[cur_event_cat_mean_index].
     event_cat_mean = event_cat_mean
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (loadbedrocknomenclaturevalues(filtermeaning=vc,referencerecord=vc(ref),event_cat_mean=vc
  ) =null WITH protect)
   DECLARE filter_index = i4 WITH protect, noconstant(0)
   DECLARE val_cntr = i4 WITH protect, noconstant(0)
   DECLARE val_size = i4 WITH protect, noconstant(0)
   SET filter_index = getbedrockfilterindexbymeaning(filtermeaning)
   IF (filter_index > 0)
    SET val_size = size(filter->filters[filter_index].values,5)
    FOR (val_cntr = 1 TO val_size)
      CASE (filter->filters[filter_index].fileventcatmean)
       OF "PROBLEM":
        CALL addproblemnomenclature(referencerecord,filter->filters[filter_index].values[val_cntr].
         valeventcd,filter->filters[filter_index].values[val_cntr].valeventnomdisp,event_cat_mean)
      ENDCASE
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE (addeventsetcd(referencerecord=vc(ref),code=f8,event_cat_mean=vc) =null WITH protect)
   DECLARE search_cntr = i4 WITH protect, noconstant(0)
   DECLARE cur_code_index = i4 WITH protect, noconstant(0)
   DECLARE cur_event_cat_mean_index = i4 WITH protect, noconstant(0)
   IF (validate(referencerecord)=1)
    SET cur_code_index = locateval(search_cntr,1,referencerecord->event_set_cd_cnt,code,
     referencerecord->event_set_cds[search_cntr].event_set_cd)
    IF (cur_code_index=0)
     SET referencerecord->event_set_cd_cnt += 1
     SET cur_code_index = referencerecord->event_set_cd_cnt
     SET stat = alterlist(referencerecord->event_set_cds,referencerecord->event_set_cd_cnt)
     SET referencerecord->event_set_cds[cur_code_index].event_set_cd = code
     SET referencerecord->event_set_cds[cur_code_index].event_set_cd_disp = trim(uar_get_code_display
      (code))
    ENDIF
    IF (locateval(search_cntr,1,referencerecord->event_set_cds[cur_code_index].event_cat_mean_cnt,
     trim(event_cat_mean),referencerecord->event_set_cds[cur_code_index].event_cat_means[search_cntr]
     .event_cat_mean)=0)
     SET referencerecord->event_set_cds[cur_code_index].event_cat_mean_cnt += 1
     SET cur_event_cat_mean_index = referencerecord->event_set_cds[cur_code_index].event_cat_mean_cnt
     SET stat = alterlist(referencerecord->event_set_cds[cur_code_index].event_cat_means,
      referencerecord->event_set_cds[cur_code_index].event_cat_mean_cnt)
     SET referencerecord->event_set_cds[cur_code_index].event_cat_means[cur_event_cat_mean_index].
     event_cat_mean = event_cat_mean
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (addeventcd(referencerecord=vc(ref),filter_index=i4,value_index=i4,event_cat_mean=vc) =
  null WITH protect)
   DECLARE search_cntr = i4 WITH protect, noconstant(0)
   DECLARE cur_code_index = i4 WITH protect, noconstant(0)
   DECLARE cur_event_cat_mean_index = i4 WITH protect, noconstant(0)
   DECLARE event_cd = f8 WITH protect, noconstant(filter->filters[filter_index].values[value_index].
    valeventcd)
   DECLARE filter_event_seq = i4 WITH protect, noconstant(filter->filters[filter_index].fileventseq)
   DECLARE value_event_seq = i4 WITH protect, noconstant(filter->filters[filter_index].values[
    value_index].valeventseq)
   IF (validate(referencerecord)=1)
    SET cur_code_index = locateval(search_cntr,1,referencerecord->event_cd_cnt,event_cd,
     referencerecord->event_cds[search_cntr].event_cd)
    IF (cur_code_index=0)
     SET referencerecord->event_cd_cnt += 1
     SET cur_code_index = referencerecord->event_cd_cnt
     SET stat = alterlist(referencerecord->event_cds,referencerecord->event_cd_cnt)
     SET referencerecord->event_cds[cur_code_index].event_cd = event_cd
     SET referencerecord->event_cds[cur_code_index].event_cd_disp = trim(uar_get_code_display(
       event_cd))
     CALL addeventnomenclature(filter_index,filter_event_seq,value_event_seq)
    ENDIF
    IF (locateval(search_cntr,1,referencerecord->event_cds[cur_code_index].event_cat_mean_cnt,trim(
      event_cat_mean),referencerecord->event_cds[cur_code_index].event_cat_means[search_cntr].
     event_cat_mean)=0)
     SET referencerecord->event_cds[cur_code_index].event_cat_mean_cnt += 1
     SET cur_event_cat_mean_index = referencerecord->event_cds[cur_code_index].event_cat_mean_cnt
     SET stat = alterlist(referencerecord->event_cds[cur_code_index].event_cat_means,referencerecord
      ->event_cds[cur_code_index].event_cat_mean_cnt)
     SET referencerecord->event_cds[cur_code_index].event_cat_means[cur_event_cat_mean_index].
     event_cat_mean = event_cat_mean
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (addeventnomenclature(eventfilterindex=i4,filtereventseq=i4,valueeventseq=i4) =null)
   DECLARE search_cntr = i4 WITH protect, noconstant(0)
   DECLARE nomen_filter_index = i4 WITH protect, noconstant((eventfilterindex+ 1))
   DECLARE value_cntr = i4 WITH protect, noconstant(0)
   DECLARE value_size = i4 WITH protect, noconstant(0)
   DECLARE event_nomen_index = i4 WITH protect, noconstant(0)
   WHILE (nomen_filter_index > 0
    AND (nomen_filter_index <= filter->filterscnt))
    SET nomen_filter_index = locateval(search_cntr,nomen_filter_index,filter->filterscnt,
     filtereventseq,filter->filters[search_cntr].fileventseq)
    IF (nomen_filter_index > 0)
     SET value_size = size(filter->filters[nomen_filter_index].values,5)
     FOR (value_cntr = 1 TO value_size)
       IF ((filter->filters[nomen_filter_index].values[value_cntr].valeventseq=valueeventseq))
        SET referencerecord->event_cds[cur_code_index].event_nomen_cnt += 1
        SET event_nomen_index = referencerecord->event_cds[cur_code_index].event_nomen_cnt
        IF ((referencerecord->event_cds[cur_code_index].event_nomen_cnt > size(referencerecord->
         event_cds[cur_code_index].event_nomens,5)))
         SET stat = alterlist(referencerecord->event_cds[cur_code_index].event_nomens,(
          referencerecord->event_cds[cur_code_index].event_nomen_cnt+ 10))
        ENDIF
        SET referencerecord->event_cds[cur_code_index].event_nomens[event_nomen_index].
        nomenclature_id = filter->filters[nomen_filter_index].values[value_cntr].valeventcd
        SET referencerecord->event_cds[cur_code_index].event_nomens[event_nomen_index].
        nomenclature_disp = filter->filters[nomen_filter_index].values[value_cntr].valeventnomdisp
        SET referencerecord->event_cds[cur_code_index].event_nomens[event_nomen_index].operation =
        filter->filters[nomen_filter_index].values[value_cntr].valeventoper
        SET referencerecord->event_cds[cur_code_index].event_nomens[event_nomen_index].
        operation_qual_flag = filter->filters[nomen_filter_index].values[value_cntr].valqualflag
        SET referencerecord->event_cds[cur_code_index].event_nomens[event_nomen_index].freetext_value
         = filter->filters[nomen_filter_index].values[value_cntr].valeventftx
        SET referencerecord->event_cds[cur_code_index].event_nomens[event_nomen_index].event_type =
        filter->filters[nomen_filter_index].values[value_cntr].valeventtype
        SET referencerecord->event_cds[cur_code_index].event_nomens[event_nomen_index].filter_mean =
        filter->filters[nomen_filter_index].fileventmean
       ENDIF
     ENDFOR
     SET nomen_filter_index += 1
    ENDIF
   ENDWHILE
   SET stat = alterlist(referencerecord->event_cds[cur_code_index].event_nomens,referencerecord->
    event_cds[cur_code_index].event_nomen_cnt)
 END ;Subroutine
 SUBROUTINE (evaluatebedrockeventresult(referencerecord=vc(ref),eventcode=f8,resultfiltermeaning=vc,
  resultvalue=vc,nomenclaturerecord=vc(ref),enforcecriteria=i2) =i2 WITH protect)
   DECLARE event_cd_index = i4 WITH protect, noconstant(0)
   DECLARE search_cntr = i4 WITH protect, noconstant(0)
   DECLARE retval = i2 WITH protect, noconstant(0)
   DECLARE x = i4 WITH protect, noconstant(0)
   DECLARE nomloc = i2 WITH protect, noconstant(0)
   DECLARE nomenclatureid = f8 WITH protect, noconstant(0)
   DECLARE nomcntr = i4 WITH protect, noconstant(0)
   SET retval = 0
   SET event_cd_index = locateval(search_cntr,1,referencerecord->event_cd_cnt,eventcode,
    referencerecord->event_cds[search_cntr].event_cd)
   IF (event_cd_index > 0)
    IF ((referencerecord->event_cds[event_cd_index].event_nomen_cnt=0))
     IF (enforcecriteria=1)
      SET retval = 2
     ELSE
      SET retval = 1
     ENDIF
    ELSE
     FOR (x = 1 TO referencerecord->event_cds[event_cd_index].event_nomen_cnt)
       IF ((referencerecord->event_cds[event_cd_index].event_nomens[x].operation > " "))
        IF ((referencerecord->event_cds[event_cd_index].event_nomens[x].filter_mean=
        resultfiltermeaning))
         IF ((referencerecord->event_cds[event_cd_index].event_nomens[x].event_type=1))
          IF ((referencerecord->event_cds[event_cd_index].event_nomens[x].nomenclature_id > 0))
           IF (operator(cnvtreal(resultvalue),referencerecord->event_cds[event_cd_index].
            event_nomens[x].operation,cnvtreal(referencerecord->event_cds[event_cd_index].
             event_nomens[x].nomenclature_disp)))
            SET retval = x
            SET x = referencerecord->event_cds[event_cd_index].event_nomen_cnt
           ENDIF
          ELSEIF ((referencerecord->event_cds[event_cd_index].event_nomens[x].freetext_value > " "))
           IF (operator(cnvtreal(resultvalue),referencerecord->event_cds[event_cd_index].
            event_nomens[x].operation,cnvtreal(referencerecord->event_cds[event_cd_index].
             event_nomens[x].freetext_value)))
            SET retval = x
            SET x = referencerecord->event_cds[event_cd_index].event_nomen_cnt
           ENDIF
          ENDIF
         ELSEIF ((referencerecord->event_cds[event_cd_index].event_nomens[x].event_type=2))
          IF (cnvtreal(referencerecord->event_cds[event_cd_index].event_nomens[x].freetext_value) > 0
          )
           IF (operator(cnvtreal(resultvalue),referencerecord->event_cds[event_cd_index].
            event_nomens[x].operation,cnvtreal(referencerecord->event_cds[event_cd_index].
             event_nomens[x].freetext_value)))
            SET retval = x
            SET x = referencerecord->event_cds[event_cd_index].event_nomen_cnt
           ENDIF
          ELSEIF ((referencerecord->event_cds[event_cd_index].event_nomens[x].freetext_value > " "))
           IF (operator(resultvalue,referencerecord->event_cds[event_cd_index].event_nomens[x].
            operation,referencerecord->event_cds[event_cd_index].event_nomens[x].freetext_value))
            SET retval = x
            SET x = referencerecord->event_cds[event_cd_index].event_nomen_cnt
           ENDIF
          ENDIF
         ELSEIF ((referencerecord->event_cds[event_cd_index].event_nomens[x].event_type=0))
          FOR (nomcntr = 1 TO nomenclaturerecord->cnt)
           SET nomenclatureid = nomenclaturerecord->qual[nomcntr].nomenclature_id
           IF (nomenclatureid > 0
            AND (referencerecord->event_cds[event_cd_index].event_nomens[x].nomenclature_id > 0))
            IF (operator(nomenclatureid,referencerecord->event_cds[event_cd_index].event_nomens[x].
             operation,referencerecord->event_cds[event_cd_index].event_nomens[x].nomenclature_id))
             SET retval = x
             SET x = referencerecord->event_cds[event_cd_index].event_nomen_cnt
            ENDIF
           ELSEIF (nomenclatureid > 0
            AND (referencerecord->event_cds[event_cd_index].event_nomens[x].freetext_value > " "))
            IF (operator(resultvalue,referencerecord->event_cds[event_cd_index].event_nomens[x].
             operation,referencerecord->event_cds[event_cd_index].event_nomens[x].freetext_value))
             SET retval = x
             SET x = referencerecord->event_cds[event_cd_index].event_nomen_cnt
            ENDIF
           ELSEIF (resultvalue > " "
            AND (referencerecord->event_cds[event_cd_index].event_nomens[x].freetext_value > " "))
            IF (operator(resultvalue,referencerecord->event_cds[event_cd_index].event_nomens[x].
             operation,referencerecord->event_cds[event_cd_index].event_nomens[x].freetext_value))
             SET retval = x
             SET x = referencerecord->event_cds[event_cd_index].event_nomen_cnt
            ENDIF
           ELSEIF (resultvalue > " "
            AND (referencerecord->event_cds[event_cd_index].event_nomens[x].nomenclature_id > 0))
            IF (operator(resultvalue,referencerecord->event_cds[event_cd_index].event_nomens[x].
             operation,referencerecord->event_cds[event_cd_index].event_nomens[x].nomenclature_disp))
             SET retval = x
             SET x = referencerecord->event_cds[event_cd_index].event_nomen_cnt
            ENDIF
           ENDIF
          ENDFOR
         ENDIF
        ENDIF
       ELSE
        SET retval = 1
        SET x = referencerecord->event_cds[event_cd_index].event_nomen_cnt
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
   RETURN(retval)
 END ;Subroutine
 SUBROUTINE (getidbysequence(seq_type=vc,refrecord=vc(ref)) =f8)
   CALL echo(build("seq_type...",seq_type))
   DECLARE new_id = f8 WITH protect, noconstant(0.0)
   IF (seq_type="LONG_DATA_SEQ")
    SELECT INTO "nl:"
     nextseqnum = seq(long_data_seq,nextval)"###########################;rp0"
     FROM dual
     DETAIL
      new_id = nextseqnum
     WITH format, nocounter
    ;end select
   ELSEIF (seq_type="EKS_SEQ")
    SELECT INTO "nl:"
     nextseqnum = seq(eks_seq,nextval)"###########################;rp0"
     FROM dual
     DETAIL
      new_id = nextseqnum
     WITH format, nocounter
    ;end select
   ELSEIF (seq_type="ORDER_SEQ")
    SELECT INTO "nl:"
     nextseqnum = seq(order_seq,nextval)"###########################;rp0"
     FROM dual
     DETAIL
      new_id = nextseqnum
     WITH format, nocounter
    ;end select
   ELSEIF (seq_type="MPAGES_SEQ")
    SELECT INTO "nl:"
     nextseqnum = seq(mpages_seq,nextval)"###########################;rp0"
     FROM dual
     DETAIL
      new_id = nextseqnum
     WITH format, nocounter
    ;end select
   ELSEIF (seq_type="REFERENCE_SEQ")
    SELECT INTO "nl:"
     nextseqnum = seq(reference_seq,nextval)"###########################;rp0"
     FROM dual
     DETAIL
      new_id = nextseqnum
     WITH format, nocounter
    ;end select
   ENDIF
   CALL echo(build(seq_type,"...",new_id))
   CALL errorhandler("Generate New ID","F",script_name,refrecord)
   RETURN(new_id)
 END ;Subroutine
 SUBROUTINE (loadbedrocksynonyms(filtermeaning=vc,referencerecord=vc(ref),event_cat_mean=vc) =null
  WITH protect)
   DECLARE filter_index = i4 WITH protect, noconstant(0)
   DECLARE val_cntr = i4 WITH protect, noconstant(0)
   DECLARE val_size = i4 WITH protect, noconstant(0)
   SET filter_index = getbedrockfilterindexbymeaning(filtermeaning)
   IF (filter_index > 0)
    SET val_size = size(filter->filters[filter_index].values,5)
    FOR (val_cntr = 1 TO val_size)
      CASE (filter->filters[filter_index].fileventcatmean)
       OF "SYNONYM":
        CALL addsynonymid(referencerecord,filter->filters[filter_index].values[val_cntr].valeventcd,
         filter->filters[filter_index].values[val_cntr].valeventnomdisp,event_cat_mean)
      ENDCASE
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE (addsynonymid(referencerecord=vc(ref),synonym_id=f8,display=vc,event_cat_mean=vc) =null
  WITH protect)
   DECLARE search_cntr = i4 WITH protect, noconstant(0)
   DECLARE cur_code_index = i4 WITH protect, noconstant(0)
   DECLARE cur_event_cat_mean_index = i4 WITH protect, noconstant(0)
   IF (validate(referencerecord)=1)
    SET cur_code_index = locateval(search_cntr,1,referencerecord->synonym_id_cnt,synonym_id,
     referencerecord->synonym_ids[search_cntr].synonym_id)
    IF (cur_code_index=0)
     SET referencerecord->synonym_id_cnt += 1
     SET cur_code_index = referencerecord->synonym_id_cnt
     SET stat = alterlist(referencerecord->synonym_ids,referencerecord->synonym_id_cnt)
     SET referencerecord->synonym_ids[cur_code_index].synonym_id = synonym_id
    ENDIF
    IF (locateval(search_cntr,1,referencerecord->synonym_ids[cur_code_index].event_cat_mean_cnt,trim(
      event_cat_mean),referencerecord->synonym_ids[cur_code_index].event_cat_means[search_cntr].
     event_cat_mean)=0)
     SET referencerecord->synonym_ids[cur_code_index].event_cat_mean_cnt += 1
     SET cur_event_cat_mean_index = referencerecord->synonym_ids[cur_code_index].event_cat_mean_cnt
     SET stat = alterlist(referencerecord->synonym_ids[cur_code_index].event_cat_means,
      referencerecord->synonym_ids[cur_code_index].event_cat_mean_cnt)
     SET referencerecord->synonym_ids[cur_code_index].event_cat_means[cur_event_cat_mean_index].
     event_cat_mean = event_cat_mean
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (loadbedrockdrugclasses(filtermeaning=vc,referencerecord=vc(ref),event_cat_mean=vc) =null
   WITH protect)
   DECLARE filter_index = i4 WITH protect, noconstant(0)
   DECLARE val_cntr = i4 WITH protect, noconstant(0)
   DECLARE val_size = i4 WITH protect, noconstant(0)
   SET filter_index = getbedrockfilterindexbymeaning(filtermeaning)
   IF (filter_index > 0)
    SET val_size = size(filter->filters[filter_index].values,5)
    FOR (val_cntr = 1 TO val_size)
      CASE (filter->filters[filter_index].fileventcatmean)
       OF "MULTUM_CAT":
        CALL adddrugclassid(referencerecord,filter->filters[filter_index].values[val_cntr].valeventcd,
         filter->filters[filter_index].values[val_cntr].valeventnomdisp,event_cat_mean)
      ENDCASE
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE (adddrugclassid(referencerecord=vc(ref),drug_class_id=f8,display=vc,event_cat_mean=vc) =
  null WITH protect)
   DECLARE search_cntr = i4 WITH protect, noconstant(0)
   DECLARE cur_code_index = i4 WITH protect, noconstant(0)
   DECLARE cur_event_cat_mean_index = i4 WITH protect, noconstant(0)
   IF (validate(referencerecord)=1)
    SET cur_code_index = locateval(search_cntr,1,referencerecord->drug_class_id_cnt,drug_class_id,
     referencerecord->drug_class_ids[search_cntr].drug_class_id)
    IF (cur_code_index=0)
     SET referencerecord->drug_class_id_cnt += 1
     SET cur_code_index = referencerecord->drug_class_id_cnt
     SET stat = alterlist(referencerecord->drug_class_ids,referencerecord->drug_class_id_cnt)
     SET referencerecord->drug_class_ids[cur_code_index].drug_class_id = drug_class_id
    ENDIF
    IF (locateval(search_cntr,1,referencerecord->drug_class_ids[cur_code_index].event_cat_mean_cnt,
     trim(event_cat_mean),referencerecord->drug_class_ids[cur_code_index].event_cat_means[search_cntr
     ].event_cat_mean)=0)
     SET referencerecord->drug_class_ids[cur_code_index].event_cat_mean_cnt += 1
     SET cur_event_cat_mean_index = referencerecord->drug_class_ids[cur_code_index].
     event_cat_mean_cnt
     SET stat = alterlist(referencerecord->drug_class_ids[cur_code_index].event_cat_means,
      referencerecord->drug_class_ids[cur_code_index].event_cat_mean_cnt)
     SET referencerecord->drug_class_ids[cur_code_index].event_cat_means[cur_event_cat_mean_index].
     event_cat_mean = event_cat_mean
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (loadretrieveceresultvalue(cereply=vc(ref),eventresults=vc(ref),resultindex=i4) =null
  WITH protect)
   DECLARE resultdisplay = vc WITH protect, noconstant("")
   DECLARE resultvalue = vc WITH protect, noconstant("")
   DECLARE event_result_value = vc WITH protect, noconstant("")
   DECLARE eventcd = f8 WITH protect, noconstant(0.0)
   DECLARE eventsearchindex = i4 WITH protect, noconstant(0)
   IF (size(cereply->results[resultindex].clinical_events,5) > 0)
    IF (size(cereply->results[resultindex].clinical_events[1].unclassifieds,5))
     SET eventcd = cereply->results[resultindex].clinical_events[1].unclassifieds[1].event_cd
     SET resultdisplay = trim(cereply->results[resultindex].clinical_events[1].unclassifieds[1].
      event_title_text,3)
     IF (textlen(resultdisplay)=0)
      SET eventfilterindex = locateval(eventsearchindex,1,size(cereply->codes,5),eventcd,cereply->
       codes[eventsearchindex].code)
      IF (eventfilterindex > 0)
       SET resultdisplay = cereply->codes[eventfilterindex].display
      ENDIF
     ENDIF
     SET eventresults->event_result_display = resultdisplay
     SET eventresults->event_result_value = resultdisplay
     SET eventresults->event_result_dt_tm = cereply->results[resultindex].clinical_events[1].
     unclassifieds[1].effective_dt_tm
    ENDIF
    IF (size(cereply->results[resultindex].clinical_events[1].documents,5))
     SET eventcd = cereply->results[resultindex].clinical_events[1].documents[1].event_cd
     SET resultdisplay = trim(cereply->results[resultindex].clinical_events[1].documents[1].
      custom_display,3)
     IF (textlen(resultdisplay)=0)
      SET eventfilterindex = locateval(eventsearchindex,1,size(cereply->codes,5),eventcd,cereply->
       codes[eventsearchindex].code)
      IF (eventfilterindex > 0)
       SET resultdisplay = cereply->codes[eventfilterindex].display
      ENDIF
     ENDIF
     SET eventresults->event_result_display = resultdisplay
     SET eventresults->event_result_value = resultdisplay
     SET eventresults->event_result_dt_tm = cereply->results[resultindex].clinical_events[1].
     documents[1].effective_dt_tm
    ENDIF
    IF (size(cereply->results[resultindex].clinical_events[1].measurements,5))
     SET eventcd = cereply->results[resultindex].clinical_events[1].measurements[1].event_cd
     CALL getmeasurementresult(cereply,resultindex,1,1)
     SET eventfilterindex = locateval(eventsearchindex,1,size(cereply->codes,5),eventcd,cereply->
      codes[eventsearchindex].code)
     SET eventresults->event_result_dt_tm = cereply->results[resultindex].clinical_events[1].
     measurements[1].effective_dt_tm
     IF ((temp_meas_res_rec->res_type != 3))
      SET eventresults->event_result_value = temp_meas_res_rec->result
      IF (eventfilterindex > 0)
       SET eventresults->event_result_display = build2(cereply->codes[eventfilterindex].display," = ",
        eventresults->event_result_value)
      ENDIF
     ELSE
      IF (eventfilterindex > 0)
       SET eventresults->event_result_value = cereply->codes[eventfilterindex].display
       SET eventresults->event_result_display = eventresults->event_result_value
      ENDIF
      SET eventresults->event_result_display = build2(eventresults->event_result_display," = ",format
       (cereply->results[resultindex].clinical_events[1].measurements[1].date_value[1].dt_tm,
        "mm/dd/yyyy hh:mm;;d"))
     ENDIF
     IF (validate(debug_ind,0)=1)
      CALL echorecord(eventresults)
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (getceresultnomenclatureids(cereply=vc(ref),nomenclaturerecord=vc(ref),resultindex=i4) =
  null WITH protect)
   DECLARE event_nomenclature_id = f8 WITH protect, noconstant(0.0)
   DECLARE nomen_cntr = i4 WITH protect, noconstant(0)
   DECLARE nomen_size = i4 WITH protect, noconstant(0)
   SET stat = initrec(nomenclaturerecord)
   IF (size(cereply->results[resultindex].clinical_events,5) > 0)
    IF (size(cereply->results[resultindex].clinical_events[1].measurements,5) > 0)
     IF (size(cereply->results[resultindex].clinical_events[1].measurements[1].code_value,5) > 0)
      IF (size(cereply->results[resultindex].clinical_events[1].measurements[1].code_value[1].values,
       5) > 0)
       SET nomen_size = size(cereply->results[resultindex].clinical_events[1].measurements[1].
        code_value[1].values,5)
       SET nomenclaturerecord->cnt = nomen_size
       SET stat = alterlist(nomenclaturerecord->qual,nomenclaturerecord->cnt)
       FOR (nomen_cntr = 1 TO nomen_size)
         SET nomenclaturerecord->qual[nomen_cntr].nomenclature_id = cereply->results[resultindex].
         clinical_events[1].measurements[1].code_value[1].values[nomen_cntr].nomenclature_id
       ENDFOR
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF ((nomenclaturerecord->cnt=0))
    SET nomenclaturerecord->cnt = 1
    SET stat = alterlist(nomenclaturerecord->qual,1)
    SET nomenclaturerecord->qual[1].nomenclature_id = event_nomenclature_id
   ENDIF
 END ;Subroutine
 SUBROUTINE (getbedrockflexparententityid(encntr_id=f8,personnel_id=f8,category_meaning=vc) =f8 WITH
  protect)
   DECLARE flex_parent_entity_id = f8 WITH protect, noconstant(0)
   DECLARE flex_flag = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM br_datamart_category b
    PLAN (b
     WHERE b.category_mean=category_meaning)
    DETAIL
     flex_flag = b.flex_flag
    WITH nocounter
   ;end select
   CASE (flex_flag)
    OF 1:
     SELECT INTO "nl:"
      FROM prsnl p
      PLAN (p
       WHERE p.person_id=personnel_id)
      DETAIL
       flex_parent_entity_id = p.position_cd
      WITH nocounter
     ;end select
    OF 2:
     SELECT INTO "nl:"
      FROM encounter e
      PLAN (e
       WHERE e.encntr_id=encntr_id)
      DETAIL
       flex_parent_entity_id = e.loc_facility_cd
      WITH nocounter
     ;end select
   ENDCASE
   RETURN(flex_parent_entity_id)
 END ;Subroutine
 SUBROUTINE (loadbedrockmultifreetext(filtermeaning=vc,referencerecord=vc(ref),event_cat_mean=vc) =
  null WITH protect)
   DECLARE filter_index = i4 WITH protect, noconstant(0)
   DECLARE f_cntr = i4 WITH protect, noconstant(0)
   DECLARE val_size = i4 WITH protect, noconstant(0)
   DECLARE cur_freetext_value = vc WITH protect, noconstant("")
   SET filter_index = getbedrockfilterindexbymeaning(filtermeaning)
   IF (filter_index > 0)
    SET val_size = size(filter->filters[filter_index].values,5)
    SELECT
     group_seq = filter->filters[filter_index].values[d1.seq].valeventgrpseq, value_seq = filter->
     filters[filter_index].values[d1.seq].valeventseq
     FROM (dummyt d1  WITH seq = val_size)
     ORDER BY group_seq, value_seq
     HEAD group_seq
      f_cntr += 1
      IF ((f_cntr > br_multi_freetext->freetext_cnt))
       stat = alterlist(br_multi_freetext->freetexts,(f_cntr+ 10))
      ENDIF
     HEAD value_seq
      cur_freetext_value = trim(filter->filters[filter_index].values[d1.seq].valeventftx,3)
      CASE (value_seq)
       OF 0:
        br_multi_freetext->freetexts[f_cntr].long_name = cur_freetext_value
       OF 1:
        br_multi_freetext->freetexts[f_cntr].display_name = cur_freetext_value
      ENDCASE
     FOOT REPORT
      br_multi_freetext->freetext_cnt = f_cntr, stat = alterlist(br_multi_freetext->freetexts,
       br_multi_freetext->freetext_cnt)
     WITH nocounter
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE (addorderentryfieldcd(referencerecord=vc(ref),code=f8,event_cat_mean=vc) =null WITH
  protect)
   DECLARE search_cntr = i4 WITH protect, noconstant(0)
   DECLARE cur_code_index = i4 WITH protect, noconstant(0)
   DECLARE cur_event_cat_mean_index = i4 WITH protect, noconstant(0)
   IF (validate(referencerecord)=1)
    SET cur_code_index = locateval(search_cntr,1,referencerecord->oe_field_cd_cnt,code,
     referencerecord->oe_field_cds[search_cntr].oe_field_cd)
    IF (cur_code_index=0)
     SET referencerecord->oe_field_cd_cnt += 1
     SET cur_code_index = referencerecord->oe_field_cd_cnt
     SET stat = alterlist(referencerecord->oe_field_cds,referencerecord->oe_field_cd_cnt)
     SET referencerecord->oe_field_cds[cur_code_index].oe_field_cd = code
     SET referencerecord->oe_field_cds[cur_code_index].oe_field_cd_disp = trim(uar_get_code_display(
       code))
    ENDIF
    IF (locateval(search_cntr,1,referencerecord->oe_field_cds[cur_code_index].event_cat_mean_cnt,trim
     (event_cat_mean),referencerecord->oe_field_cds[cur_code_index].event_cat_means[search_cntr].
     event_cat_mean)=0)
     SET referencerecord->oe_field_cds[cur_code_index].event_cat_mean_cnt += 1
     SET cur_event_cat_mean_index = referencerecord->oe_field_cds[cur_code_index].event_cat_mean_cnt
     SET stat = alterlist(referencerecord->oe_field_cds[cur_code_index].event_cat_means,
      referencerecord->oe_field_cds[cur_code_index].event_cat_mean_cnt)
     SET referencerecord->oe_field_cds[cur_code_index].event_cat_means[cur_event_cat_mean_index].
     event_cat_mean = event_cat_mean
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (addcodevalue(referencerecord=vc(ref),code=f8,event_cat_mean=vc) =null WITH protect)
   DECLARE search_cntr = i4 WITH protect, noconstant(0)
   DECLARE cur_code_index = i4 WITH protect, noconstant(0)
   DECLARE cur_event_cat_mean_index = i4 WITH protect, noconstant(0)
   IF (validate(referencerecord)=1)
    SET cur_code_index = locateval(search_cntr,1,referencerecord->code_value_cnt,code,referencerecord
     ->code_values[search_cntr].code_value)
    IF (cur_code_index=0)
     SET referencerecord->code_value_cnt += 1
     SET cur_code_index = referencerecord->code_value_cnt
     SET stat = alterlist(referencerecord->code_values,referencerecord->code_value_cnt)
     SET referencerecord->code_values[cur_code_index].code_value = code
     SET referencerecord->code_values[cur_code_index].code_value_disp = trim(uar_get_code_display(
       code))
    ENDIF
    IF (locateval(search_cntr,1,referencerecord->code_values[cur_code_index].event_cat_mean_cnt,trim(
      event_cat_mean),referencerecord->code_values[cur_code_index].event_cat_means[search_cntr].
     event_cat_mean)=0)
     SET referencerecord->code_values[cur_code_index].event_cat_mean_cnt += 1
     SET cur_event_cat_mean_index = referencerecord->code_values[cur_code_index].event_cat_mean_cnt
     SET stat = alterlist(referencerecord->code_values[cur_code_index].event_cat_means,
      referencerecord->code_values[cur_code_index].event_cat_mean_cnt)
     SET referencerecord->code_values[cur_code_index].event_cat_means[cur_event_cat_mean_index].
     event_cat_mean = event_cat_mean
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (getviewableencounters(personid=f8,prsnlid=f8,encntr_rec=vc(ref)) =null WITH protect)
   CALL log_message("In GetViewableEncounters()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE x = i4 WITH noconstant(0), protect
   DECLARE num = i4 WITH noconstant(0), protect
   DECLARE prsnl_pos = i4 WITH noconstant(0), protect
   DECLARE person_pos = i4 WITH noconstant(0), protect
   DECLARE retrieve_encntrs = i4 WITH noconstant(0), protect
   DECLARE last_encntr_updt_dt_tm = dq8 WITH noconstant(0), protect
   SET prsnl_pos = locateval(num,1,encntrs->prsnl_cnt,prsnlid,encntrs->prsnl_list[num].prsnl_id)
   IF (prsnl_pos=0)
    CALL log_message(build2("IN GetViewableEncounters: ","PRSNL NOT FOUND"),log_level_debug)
    CALL log_message(cnvtstring(prsnlid),log_level_debug)
    SET encntrs->prsnl_cnt += 1
    SET stat = alterlist(encntrs->prsnl_list,encntrs->prsnl_cnt)
    SET prsnl_pos = encntrs->prsnl_cnt
    SET encntrs->prsnl_list[prsnl_pos].prsnl_id = prsnlid
   ENDIF
   SET person_pos = locateval(num,1,encntrs->prsnl_list[prsnl_pos].person_cnt,personid,encntrs->
    prsnl_list[prsnl_pos].person_list[num].person_id)
   SELECT INTO "NL:"
    FROM encounter e
    WHERE e.person_id=personid
    ORDER BY e.updt_dt_tm DESC
    HEAD REPORT
     last_encntr_updt_dt_tm = e.updt_dt_tm
    WITH nocounter
   ;end select
   IF (person_pos=0)
    SET retrieve_encntrs = 1
    SET encntrs->prsnl_list[prsnl_pos].person_cnt += 1
    SET person_pos = encntrs->prsnl_list[prsnl_pos].person_cnt
    SET stat = alterlist(encntrs->prsnl_list[prsnl_pos].person_list,person_pos)
    SET encntrs->prsnl_list[prsnl_pos].person_list[person_pos].person_id = personid
    SET encntrs->prsnl_list[prsnl_pos].person_list[person_pos].last_updt_dt_tm =
    last_encntr_updt_dt_tm
   ELSEIF (cnvtdatetime(last_encntr_updt_dt_tm) > cnvtdatetime(encntrs->prsnl_list[prsnl_pos].
    person_list[person_pos].last_updt_dt_tm))
    CALL echo(build2("last_encntr_updt_dt_tm:",cnvtdatetime(last_encntr_updt_dt_tm)))
    CALL echo(build2("last_updt_dt_tm:",cnvtdatetime(encntrs->prsnl_list[prsnl_pos].person_list[
       person_pos].last_updt_dt_tm)))
    SET retrieve_encntrs = 1
    SET encntrs->prsnl_list[prsnl_pos].person_list[person_pos].last_updt_dt_tm =
    last_encntr_updt_dt_tm
   ENDIF
   IF (retrieve_encntrs=1)
    CALL log_message(build2("IN GetViewableEncounters-encntrs: ","Refreshing"),log_level_debug)
    CALL log_message(cnvtstring(personid),log_level_debug)
    RECORD 115424_request(
      1 read_not_active_ind = i2
      1 read_not_effective_ind = i2
      1 person_qual[*]
        2 person_id = f8
      1 filters
        2 encntr_type_class_cds[*]
          3 encntr_type_class_cd = f8
        2 facility_cds[*]
          3 facility_cd = f8
        2 organization_ids[*]
          3 organization_id = f8
      1 skip_org_security_ind = i2
      1 user_id = f8
      1 debug_ind = i2
      1 debug
        2 org_security_level = i4
        2 lifetime_reltn_override_level = i4
        2 use_dynamic_security_ind = i2
        2 trust_id = f8
      1 load
        2 encntr_prsnl_reltns_ind = i2
    )
    RECORD 115424_reply(
      1 person_qual_cnt = i4
      1 person_qual[*]
        2 person_id = f8
        2 encounter_qual_cnt = i4
        2 encounter_qual[*]
          3 encounter_id = f8
          3 encounter_prsnl_reltn_qual[*]
            4 encntr_prsnl_reltn_id = f8
            4 encntr_prsnl_r_cd = f8
            4 beg_effective_dt_tm = dq8
            4 end_effective_dt_tm = dq8
        2 active_encounter_cnt = i4
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    )
    SET stat = alterlist(115424_request->person_qual,1)
    SET 115424_request->person_qual[1].person_id = personid
    SET 115424_request->user_id = prsnlid
    EXECUTE pm_get_encounter_by_person  WITH replace("REQUEST","115424_REQUEST"), replace("REPLY",
     "115424_REPLY")
    IF ((115424_reply->person_qual_cnt=1))
     IF ((115424_reply->person_qual[1].encounter_qual_cnt > 0))
      SET stat = alterlist(encntrs->prsnl_list[prsnl_pos].person_list[person_pos].encntr_list,
       115424_reply->person_qual[1].encounter_qual_cnt)
      SET encntrs->prsnl_list[prsnl_pos].person_list[person_pos].encntr_cnt = 115424_reply->
      person_qual[1].encounter_qual_cnt
      FOR (x = 1 TO 115424_reply->person_qual[1].encounter_qual_cnt)
        SET encntrs->prsnl_list[prsnl_pos].person_list[person_pos].encntr_list[x].value =
        115424_reply->person_qual[1].encounter_qual[x].encounter_id
      ENDFOR
     ENDIF
    ENDIF
   ENDIF
   SET dencntr_vc = cnvtrectojson(encntrs)
   CALL log_message(build2("IN GetViewableEncounters-encntrs: ",dencntr_vc),log_level_debug)
   SET stat = moverec(encntrs->prsnl_list[prsnl_pos].person_list[person_pos].encntr_list,encntr_rec->
    qual)
   SET encntr_rec->cnt = encntrs->prsnl_list[prsnl_pos].person_list[person_pos].encntr_cnt
   CALL log_message(build("Exit GetViewableEncounters(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 IF ( NOT (validate(template_display)))
  RECORD template_display(
    1 pathway_tmplt_title = vc
    1 pathway_start_dt = dq8
    1 pathway_start_dt_string = vc
    1 node_cnt = i4
    1 nodes[*]
      2 node_id = f8
      2 start_dt = dq8
      2 start_dt_string = vc
      2 node_display = vc
      2 action_cnt = i4
      2 actions[*]
        3 action_id = f8
        3 action_mean = vc
        3 action_display = vc
        3 action_detail_cnt = i4
        3 action_details[*]
          4 detail_mean_disp = vc
          4 detail_display = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
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
 FREE RECORD pathway_activity_reply
 RECORD pathway_activity_reply(
   1 activity_cnt = i4
   1 activity_qual[*]
     2 pathway_name = vc
     2 auto_added_ind = i2
     2 beg_effective_dt_tm = dq8
     2 comment_txt = vc
     2 cp_pathway_activity_id = f8
     2 cp_pathway_id = f8
     2 pathway_instance_id = f8
     2 encntr_id = f8
     2 end_effective_dt_tm = dq8
     2 pathway_activity_status_cd = f8
     2 pathway_activity_status_mean = vc
     2 person_id = f8
     2 rowid = vc
     2 updt_id = f8
     2 updt_name = vc
     2 updt_dt_tm = dq8
     2 off_pathway_ind = i2
     2 clinical_trial_ind = i2
     2 diagnosis_nomen_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD pathway_trail_data
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
 FREE RECORD action_log
 RECORD action_log(
   1 actions[*]
     2 term_display = vc
     2 term_ocid = vc
     2 term_state = vc
     2 timestamp = vc
     2 group_display = vc
     2 group_ocid = vc
     2 group_type = vc
 )
 DECLARE main(null) = f8
 DECLARE getpathwaytraildata(pathway_id=f8,pathway_instance_id=f8,pathway_name=vc) = null
 DECLARE buildrtftext(null) = null
 DECLARE getheadertext(null) = null
 DECLARE getbodytext(null) = null
 DECLARE gettrailjsonactions(seq=i4) = null
 DECLARE orders_disp = vc WITH constant("Orders"), protect
 DECLARE person_id = f8 WITH constant(request->person[1].person_id), protect
 DECLARE encounter_id = f8 WITH constant(request->visit[1].encntr_id), protect
 DECLARE assessment_cd = f8 WITH constant(uar_get_code_by("MEANING",4003278,"ASSESSMENT")), protect
 DECLARE treatment_cd = f8 WITH constant(uar_get_code_by("MEANING",4003278,"TREATMENTS")), protect
 DECLARE error_action_detail_status_mean = vc WITH constant("INERROR"), protect
 DECLARE assessment_disp = vc WITH constant(uar_get_code_display(assessment_cd))
 DECLARE treatment_disp = vc WITH constant(uar_get_code_display(treatment_cd))
 DECLARE ordselect_mean = vc WITH constant("ORDSELECT"), protect
 DECLARE onpathway_mean = vc WITH constant("ONPATHWAY"), protect
 DECLARE offpathway_mean = vc WITH constant("OFFPATHWAY"), protect
 DECLARE offclintrial_mean = vc WITH constant("OFFCLINTRIAL"), protect
 DECLARE onclintrial_mean = vc WITH constant("ONCLINTRIAL"), protect
 DECLARE commitassess_mean = vc WITH constant("COMMITASSESS"), protect
 DECLARE committreat_mean = vc WITH constant("COMMITTREAT"), protect
 DECLARE trailjson_mean = vc WITH constant("TRAILJSON"), protect
 DECLARE savedoc_mean = vc WITH constant("SAVEDOC"), protect
 DECLARE inerrordoc_mean = vc WITH constant("INERRORDOC"), protect
 DECLARE ordsuggest_mean = vc WITH constant("ORDSUGGEST"), protect
 DECLARE treatsuggest_mean = vc WITH constant("TREATSUGGEST"), protect
 DECLARE treatselect_mean = vc WITH constant("TREATSELECT"), protect
 DECLARE offclintrial_cd = f8 WITH constant(uar_get_code_by("MEANING",4003135,offclintrial_mean))
 DECLARE onclintrial_cd = f8 WITH constant(uar_get_code_by("MEANING",4003135,onclintrial_mean))
 DECLARE onpathway_cd = f8 WITH constant(uar_get_code_by("MEANING",4003135,onpathway_mean))
 DECLARE offpathway_cd = f8 WITH constant(uar_get_code_by("MEANING",4003135,offpathway_mean))
 DECLARE term_state_0 = vc WITH constant("0"), protect
 DECLARE term_state_1 = vc WITH constant("1"), protect
 DECLARE term_state_2 = vc WITH constant("2"), protect
 DECLARE term_state_yes = vc WITH constant(" Y "), protect
 DECLARE term_state_no = vc WITH constant(" N "), protect
 DECLARE current_dt_tm = dq8 WITH constant(cnvtdatetime(sysdate)), protect
 DECLARE current_tm = dq8 WITH constant(curtime3), protect
 DECLARE active_status_cd = f8 WITH constant(uar_get_code_by("MEANING",4003352,"ACTIVE")), protect
 DECLARE bold = vc WITH constant(" \b{{BOLD_SIZE}} "), protect
 DECLARE italic = vc WITH constant(" \i{{ITALIC_SIZE}} "), protect
 DECLARE endbold = vc WITH constant(" \b0 "), protect
 DECLARE enditalic = vc WITH constant(" \i0 "), protect
 DECLARE c_return = vc WITH constant("\par"), protect
 DECLARE ul = vc WITH constant("\ul "), protect
 DECLARE ul_end = vc WITH constant(" \ulnone "), protect
 DECLARE font_size = vc WITH constant(" \fs{{FONT_SIZE}} "), protect
 DECLARE hyphen = vc WITH constant(" \endash "), protect
 DECLARE active_pathway_id = f8 WITH noconstant(0), protect
 DECLARE active_pathway_name = vc WITH noconstant(""), protect
 DECLARE active_pathway_instance_id = f8 WITH noconstant(0), protect
 DECLARE active_pathway_begin_dt_tm = dq8
 DECLARE option_1_header = vc WITH noconstant(""), protect
 DECLARE reply_text = vc WITH noconstant(""), protect
 DECLARE option_1_body = vc WITH noconstant(""), protect
 SUBROUTINE main(null)
   CALL log_message("In main() ",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   CALL getpathwayactivity(person_id,encounter_id)
   IF (active_pathway_id != 0
    AND active_pathway_instance_id != 0)
    CALL getpathwaytraildata(active_pathway_id,active_pathway_instance_id,active_pathway_begin_dt_tm,
     active_pathway_name)
   ENDIF
   CALL buildrtftext(null)
   CALL log_message(build("Exit main(), Time (in secs) : ",((curtime3 - begin_curtime3)/ 100.0)),
    log_level_debug)
 END ;Subroutine
 SUBROUTINE (getpathwayactivity(person_id=f8,encounter_id=f8) =null)
   CALL log_message(" In getPathwayActivity() ",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE acnt = i4 WITH noconstant(0), protect
   SET vcparserstring = build("execute cp_get_pathway_activity ^NOFORMS^, ",person_id,",0 go")
   CALL parser(vcparserstring)
   IF (validate(debug_ind,0)=1)
    CALL echorecord(pathway_activity_reply)
   ENDIF
   IF ((pathway_activity_reply->activity_cnt != 0))
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = pathway_activity_reply->activity_cnt)
     PLAN (d1
      WHERE (d1.seq <= pathway_activity_reply->activity_cnt)
       AND (pathway_activity_reply->activity_qual[d1.seq].end_effective_dt_tm > current_dt_tm)
       AND (pathway_activity_reply->activity_qual[d1.seq].pathway_activity_status_cd=active_status_cd
      ))
     ORDER BY pathway_activity_reply->activity_qual[d1.seq].beg_effective_dt_tm DESC
     HEAD d1.seq
      acnt += 1
      IF (acnt <= 1)
       active_pathway_id = pathway_activity_reply->activity_qual[d1.seq].cp_pathway_id,
       active_pathway_name = pathway_activity_reply->activity_qual[d1.seq].pathway_name,
       active_pathway_instance_id = pathway_activity_reply->activity_qual[d1.seq].pathway_instance_id,
       active_pathway_begin_dt_tm = pathway_activity_reply->activity_qual[d1.seq].beg_effective_dt_tm
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   IF (validate(debug_ind,0)=1)
    CALL echo(build("Current Active Pathway 		 ------> ",active_pathway_id))
    CALL echo(build("Current Active Instance Pathway ------> ",active_pathway_instance_id))
   ENDIF
   CALL log_message(build(" Exit getPathwayActivity(), Time (in secs) : ",((curtime3 - begin_curtime3
     )/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getpathwaytraildata(pathway_id,pathway_instance_id,pathway_dt_tm,pathway_name)
   CALL log_message(" In getPathwayTrailData() ",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE dcnt = i4 WITH noconstant(0), protect
   DECLARE loc = i4 WITH noconstant(0), protect
   DECLARE indx = i4 WITH noconstant(0), protect
   DECLARE tnode = f8 WITH noconstant(0), protect
   DECLARE currdisp = vc WITH noconstant(""), protect
   DECLARE vcparserstring = vc WITH noconstant(""), private
   DECLARE node_id = f8 WITH noconstant(0), protect
   DECLARE currmean = vc WITH noconstant(""), protect
   DECLARE detailmean = vc WITH noconstant(""), protect
   DECLARE curractionid = f8 WITH noconstant(0), protect
   SET vcparserstring = build("execute cp_retrieve_pathway_trail_data ^NOFORMS^,",pathway_id,",",
    pathway_instance_id,",",
    person_id,",",encounter_id," go")
   CALL parser(vcparserstring)
   IF (validate(debug_ind,0)=1)
    CALL echo(build("Parameters -------> ",vcparserstring))
    CALL echorecord(pathway_trail_data)
   ENDIF
   SET template_display->pathway_tmplt_title = pathway_name
   SET template_display->pathway_start_dt = cnvtdate(pathway_dt_tm)
   SET template_display->pathway_start_dt_string = format(pathway_dt_tm,"mm/dd/yy;;d")
   CALL echo(build("ENCOUNTER_ID : ",encounter_id))
   IF ((pathway_trail_data->action_cnt != 0))
    SELECT
     node_id = pathway_trail_data->actions[d1.seq].node_id, actionflag = evaluate(pathway_trail_data
      ->actions[d1.seq].action_detail_entity_mean,trailjson_mean,1,ordselect_mean,2,
      treatselect_mean,3,4), action_dt_tm = pathway_trail_data->actions[d1.seq].action_dt_tm
     FROM (dummyt d1  WITH seq = pathway_trail_data->action_cnt)
     PLAN (d1
      WHERE (d1.seq <= pathway_trail_data->action_cnt)
       AND (pathway_trail_data->actions[d1.seq].encntr_id=encounter_id)
       AND (pathway_trail_data->actions[d1.seq].node_id > 0)
       AND (pathway_trail_data->actions[d1.seq].action_detail_entity_id > 0)
       AND (pathway_trail_data->actions[d1.seq].action_id > 0)
       AND  NOT ((pathway_trail_data->actions[d1.seq].action_detail_entity_mean IN (savedoc_mean,
      ordsuggest_mean, treatsuggest_mean, inerrordoc_mean)))
       AND  NOT ((pathway_trail_data->actions[d1.seq].action_detail_status_mean IN (
      error_action_detail_status_mean)))
       AND  NOT ((pathway_trail_data->actions[d1.seq].action_mean IN (onpathway_mean, offpathway_mean
      ))))
     ORDER BY node_id, actionflag, action_dt_tm,
      d1.seq
     HEAD REPORT
      loc = 0
     HEAD node_id
      dcnt += 1, stat = alterlist(template_display->nodes,dcnt), template_display->node_cnt = dcnt,
      template_display->nodes[dcnt].node_id = pathway_trail_data->actions[d1.seq].node_id,
      template_display->nodes[dcnt].node_display = pathway_trail_data->actions[d1.seq].node_display,
      template_display->nodes[dcnt].start_dt = cnvtdate(pathway_trail_data->actions[d1.seq].
       action_dt_tm),
      template_display->nodes[dcnt].start_dt_string = format(pathway_trail_data->actions[d1.seq].
       action_dt_tm,"mm/dd/yy;;d")
     HEAD d1.seq
      detailmean = pathway_trail_data->actions[d1.seq].action_detail_entity_mean
      IF ((pathway_trail_data->actions[d1.seq].action_detail_entity_mean=ordselect_mean))
       currmean = ordselect_mean, currdisp = orders_disp
      ELSE
       currmean = pathway_trail_data->actions[d1.seq].action_mean, currdisp = getactiondisplay(
        pathway_trail_data->actions[seq].action_mean), curractionid = pathway_trail_data->actions[d1
       .seq].action_id
      ENDIF
      CALL addactiondetails(dcnt,d1.seq)
     WITH nocounter
    ;end select
   ENDIF
   IF (validate(debug_ind,0)=1)
    CALL echorecord(template_display)
   ENDIF
   CALL log_message(build(" Exit getPathwayTrailData(), Time (in secs) : ",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (getactiondisplay(actionmeaning=vc) =vc)
   CALL log_message(" In getActionDisplay() ",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE returndisplay = vc WITH noconstant(""), protect
   CASE (actionmeaning)
    OF commitassess_mean:
     SET returndisplay = assessment_disp
    OF committreat_mean:
     SET returndisplay = treatment_disp
    OF offclintrial_mean:
     SET returndisplay = uar_get_code_display(offclintrial_cd)
    OF onclintrial_mean:
     SET returndisplay = uar_get_code_display(onclintrial_cd)
    OF onpathway_mean:
     SET returndisplay = uar_get_code_display(onpathway_cd)
    OF offpathway_mean:
     SET returndisplay = uar_get_code_display(offpathway_cd)
   ENDCASE
   RETURN(returndisplay)
   CALL log_message(build(" Exit getActionDisplay(), Time (in secs) : ",((curtime3 - begin_curtime3)
     / 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (addactiondetails(indx=i4,seq=i4) =null)
   CALL log_message(" In addActionDetails() ",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE acnt = i4 WITH noconstant(0), protect
   DECLARE adcnt = i4 WITH noconstant(0), protect
   DECLARE aloc = i4 WITH noconstant(0), protect
   DECLARE aindx = i4 WITH noconstant(0), protect
   DECLARE asize = i4 WITH constant(size(template_display->nodes[indx].actions,5)), protect
   SET aloc = locateval(aindx,1,asize,curractionid,template_display->nodes[indx].actions[aindx].
    action_id)
   IF (curractionid > 0
    AND aloc > 0)
    SET acnt = aloc
   ELSE
    SET acnt = template_display->nodes[indx].action_cnt
    SET acnt += 1
    SET stat = alterlist(template_display->nodes[indx].actions,acnt)
    SET template_display->nodes[indx].action_cnt = acnt
    SET template_display->nodes[indx].actions[acnt].action_display = currdisp
    SET template_display->nodes[indx].actions[acnt].action_mean = currmean
    SET template_display->nodes[indx].actions[acnt].action_id = curractionid
   ENDIF
   SET adcnt = template_display->nodes[indx].actions[acnt].action_detail_cnt
   IF (detailmean=trailjson_mean)
    CALL gettrailjsonactions(seq,indx,acnt,adcnt)
   ELSE
    CALL addtemplatedisplaydata(seq,indx,acnt,adcnt)
   ENDIF
   CALL log_message(build(" Exit addActionDetails(), Time (in secs) : ",((curtime3 - begin_curtime3)
     / 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (getactiondetaildisplay(meaning=vc) =vc)
   CALL log_message(" In getActionDetailDisplay() ",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE action_detail_cd = f8 WITH noconstant(0), protect
   DECLARE action_detail_disp = vc WITH noconstant(" "), protect
   IF (meaning != "")
    SET action_detail_cd = uar_get_code_by("MEANING",4003199,meaning)
    IF (action_detail_cd > 0)
     SET action_detail_disp = uar_get_code_display(action_detail_cd)
    ENDIF
   ENDIF
   CALL log_message(build(" Exit getActionDetailDisplay(), Time (in secs) : ",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
   RETURN(action_detail_disp)
 END ;Subroutine
 SUBROUTINE addtemplatedisplaydata(seq,nindx,aindx,adindx)
   CALL log_message(" In addTemplateDisplayData() ",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE adcnt = i4 WITH noconstant(adindx), protect
   SET adcnt += 1
   SET stat = alterlist(template_display->nodes[indx].actions[aindx].action_details,adcnt)
   SET template_display->nodes[indx].actions[aindx].action_detail_cnt = adcnt
   SET template_display->nodes[nindx].actions[aindx].action_details[adcnt].detail_mean_disp =
   getactiondetaildisplay(pathway_trail_data->actions[seq].action_detail_entity_mean)
   SET template_display->nodes[nindx].actions[aindx].action_details[adcnt].detail_display =
   pathway_trail_data->actions[seq].action_detail_entity_value
   CALL log_message(build(" Exit addTemplateDisplayData(), Time (in secs) : ",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE gettrailjsonactions(seq,nindx,aindx,adindx)
   CALL log_message(" In getTrailJSONActions() ",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE jsonentityvalue = vc WITH noconstant(""), protect
   DECLARE acnt = i4 WITH noconstant(0), protect
   DECLARE i = i4 WITH noconstant(0), protect
   DECLARE currstate = vc WITH noconstant(""), protect
   DECLARE adcnt = i4 WITH noconstant(adindx), protect
   SET jsonentityvalue = pathway_trail_data->actions[seq].action_detail_entity_value
   IF (jsonentityvalue != "")
    SET jsonentityvalue = replace(jsonentityvalue,'\"','"',0)
    SET jrec = cnvtjsontorec(jsonentityvalue)
    IF (jrec=1)
     SET acnt = size(action_log->actions,5)
     FOR (i = 1 TO acnt)
       IF ((action_log->actions[i].term_state != term_state_0))
        IF ((action_log->actions[i].term_state=term_state_1))
         SET currstate = term_state_yes
        ELSE
         SET currstate = term_state_no
        ENDIF
        SET adcnt += 1
        SET stat = alterlist(template_display->nodes[indx].actions[aindx].action_details,adcnt)
        SET template_display->nodes[indx].actions[aindx].action_detail_cnt = adcnt
        SET template_display->nodes[nindx].actions[aindx].action_details[adcnt].detail_mean_disp =
        action_log->actions[i].term_display
        SET template_display->nodes[nindx].actions[aindx].action_details[adcnt].detail_display =
        concat(currstate,"  (",format(cnvtdatetimeutc(pathway_trail_data->actions[seq].action_dt_tm,4
           ),"MM/DD/YYYY HH:MM;;D"),")")
       ENDIF
     ENDFOR
    ELSE
     CALL echo(build("Error parsing trail data for entity id : ",pathway_trail_data->actions[seq].
       action_detail_entity_id," for node ",pathway_trail_data->actions[seq].node_display," node id ",
       pathway_trail_data->actions[seq].node_id))
    ENDIF
   ENDIF
   CALL log_message(build(" Exit getTrailJSONActions(), Time (in secs) : ",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getheadertext(null)
   DECLARE header = vc WITH protect, noconstant("")
   SET header = concat("{\rtf1\ansi\ {\fonttbl{\f0\fswiss\fprq2\fcharset0 ","{{FONT_NAME}}",
    ";}}\b\f0\fs","{{SIZE}} ","{{TITLE}}")
   RETURN(header)
 END ;Subroutine
 SUBROUTINE getbodytext(null)
   DECLARE body = vc WITH protect, noconstant("")
   SET body = concat("\ul\b\f0\fs14","{{TITLE}}","\ulnone\b0 ")
   RETURN(body)
 END ;Subroutine
 SUBROUTINE (getdisplayline(type=vc,details=vc) =vc)
   DECLARE text = vc WITH protect, noconstant("")
   IF (trim(type,3) != ""
    AND trim(details,3) != "")
    SET text = concat(" ",type," "," : ",details,
     c_return)
   ELSE
    SET text = concat(" ",type," ","  ",details,
     c_return)
   ENDIF
   RETURN(text)
 END ;Subroutine
 SUBROUTINE buildrtftext(null)
   DECLARE header_text = vc WITH protect, noconstant(" ")
   DECLARE body_text = vc WITH protect, noconstant(" ")
   DECLARE option_1_body = vc WITH protect, noconstant(" ")
   DECLARE option_1_header = vc WITH protect, noconstant(" ")
   DECLARE title = vc WITH protect, noconstant("Pathway current visit : ")
   DECLARE temptext = vc WITH protect, noconstant("")
   DECLARE bcnt = i4 WITH protect, noconstant(0)
   DECLARE acnt = i4 WITH protect, noconstant(0)
   DECLARE dcnt = i4 WITH protect, noconstant(0)
   DECLARE nodecount = i4 WITH protect, constant(template_display->node_cnt)
   DECLARE actioncount = i4 WITH protect, noconstant(0)
   DECLARE detailcount = i4 WITH protect, noconstant(0)
   DECLARE actiondisplay = vc WITH protect, noconstant(" ")
   DECLARE prevactionheader = vc WITH protect, noconstant("")
   DECLARE curractionheader = vc WITH protect, noconstant("")
   SET header_text = getheadertext(null)
   SET body_text = getbodytext(null)
   IF ((template_display->pathway_tmplt_title != "")
    AND (template_display->pathway_start_dt_string != ""))
    SET title = concat(title,template_display->pathway_tmplt_title," (",template_display->
     pathway_start_dt_string,")")
   ENDIF
   SET option_1_header = replace(header_text,"{{FONT_NAME}}"," Calibri")
   SET option_1_header = replace(option_1_header,"{{SIZE}}","22")
   SET option_1_header = replace(option_1_header,"{{TITLE}}",title)
   SET option_1_header = concat(option_1_header,endbold,c_return)
   IF (nodecount > 0)
    FOR (bcnt = 1 TO nodecount)
      SET temptext = getdisplayline(" ",template_display->nodes[bcnt].node_display)
      SET option_1_body = concat(option_1_body,"\b",temptext,"\b0")
      SET prevactionheader = ""
      SET curractionheader = ""
      SET actioncount = template_display->nodes[bcnt].action_cnt
      FOR (acnt = 1 TO actioncount)
        SET curractionheader = template_display->nodes[bcnt].actions[acnt].action_display
        SET detailcount = template_display->nodes[bcnt].actions[acnt].action_detail_cnt
        FOR (dcnt = 1 TO detailcount)
          IF (dcnt=1
           AND prevactionheader != curractionheader)
           SET prevactionheader = curractionheader
           SET temptext = getdisplayline(" ",curractionheader)
           SET option_1_body = concat(option_1_body,"   ",temptext)
          ENDIF
          IF ((((template_display->nodes[bcnt].actions[acnt].action_mean=commitassess_mean)) OR ((
          template_display->nodes[bcnt].actions[acnt].action_mean=committreat_mean))) )
           SET actiondisplay = template_display->nodes[bcnt].actions[acnt].action_details[dcnt].
           detail_mean_disp
          ENDIF
          IF ((template_display->nodes[bcnt].actions[acnt].action_mean=offpathway_mean))
           IF (dcnt=1)
            SET temptext = concat(" ",template_display->nodes[bcnt].actions[acnt].action_details[dcnt
             ].detail_display)
           ELSE
            SET temptext = concat("( ",template_display->nodes[bcnt].actions[acnt].action_details[
             dcnt].detail_display," )",c_return)
           ENDIF
          ELSE
           SET temptext = getdisplayline(actiondisplay,template_display->nodes[bcnt].actions[acnt].
            action_details[dcnt].detail_display)
          ENDIF
          SET option_1_body = concat(option_1_body,"\tab",temptext)
        ENDFOR
      ENDFOR
    ENDFOR
   ELSE
    SET option_1_body = concat(option_1_body,"\tab"," No data found ")
   ENDIF
   SET reply_text = concat(option_1_header,option_1_body,"}")
   IF (validate(debug_ind,0)=1)
    CALL echorecord(template_display)
    CALL echo(reply_text)
   ENDIF
 END ;Subroutine
 SET log_program_name = "cp_smrt_tmplt_summary_data"
 CALL log_message("Start Program Execution()",log_level_debug)
 CALL main(null)
 CALL log_message(build("Stop Program Execution,Time (in secs) :",((curtime3 - current_tm)/ 100.0)),
  log_level_debug)
#exit_script
 SET reply->text = reply_text
 CALL log_message(concat("Exiting script: ",log_program_name),log_level_debug)
 CALL log_message(build("Total time in seconds:",datetimediff(cnvtdatetime(sysdate),current_date_time,
    5)),log_level_debug)
END GO
