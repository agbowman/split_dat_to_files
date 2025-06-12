CREATE PROGRAM cp_maintain_br_wizard:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Mapping Dir" = "cer_install:"
  WITH outdev, mapdir
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
 IF (validate(br_maintain_req) != 1)
  RECORD br_maintain_req(
    1 deleted_components_cnt = i4
    1 new_components_cnt = i4
    1 cp_node_id = f8
    1 node_display = vc
    1 deleted_components[*]
      2 comp_display = vc
      2 comp_type_cd = f8
      2 report_mean = vc
    1 new_components[*]
      2 comp_display = vc
      2 comp_type_cd = f8
  )
 ENDIF
 IF (validate(br_maintain_rep) != 1)
  RECORD br_maintain_rep(
    1 category_display = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 IF (validate(comp_req) != 1)
  RECORD comp_req(
    1 components[*]
      2 name = vc
      2 report_mean = vc
      2 comp_type_mean = vc
      2 standard = i2
      2 care_pathway_only = i2
  )
 ENDIF
 IF (validate(bed_ens_req) != 1)
  RECORD bed_ens_req(
    1 action_flag = i2
    1 id = f8
    1 display = vc
    1 identifier = vc
    1 components[*]
      2 action_flag = i2
      2 id = f8
      2 status_ind = i2
    1 layout_flag = i2
  )
 ENDIF
 IF (validate(bed_ens_rep) != 1)
  RECORD bed_ens_rep(
    1 id = f8
    1 components[*]
      2 id = f8
      2 mean = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 IF (validate(bed_get_datamart_cat_req) != 1)
  RECORD bed_get_datamart_cat_req(
    1 category_type_flag = i2
  )
 ENDIF
 IF (validate(bed_get_datamart_cat_std) != 1)
  RECORD bed_get_datamart_cat_std(
    1 category[*]
      2 br_datamart_category_id = f8
      2 category_name = vc
      2 category_mean = vc
      2 text[*]
        3 text_type_mean = vc
        3 text = vc
        3 text_seq = i4
      2 reports[*]
        3 br_datamart_report_id = f8
        3 report_name = vc
        3 report_mean = vc
        3 report_seq = i4
        3 text[*]
          4 text_type_mean = vc
          4 text = vc
          4 text_seq = i4
        3 baseline_value = vc
        3 target_value = vc
        3 mpage_pos_flag = i2
        3 mpage_pos_seq = i4
        3 selected_ind = i2
        3 cond_report_mean = vc
        3 mpage_default_ind = i2
        3 layout_flags[*]
          4 layout_flag = i2
      2 cat_baseline_value = vc
      2 cat_target_value = vc
      2 flex_flag = i2
      2 rel_score_ind = i2
      2 base_target_ind = i2
      2 layout_flag = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 IF (validate(bed_get_datamart_cat_cp) != 1)
  RECORD bed_get_datamart_cat_cp(
    1 category[*]
      2 br_datamart_category_id = f8
      2 category_name = vc
      2 category_mean = vc
      2 text[*]
        3 text_type_mean = vc
        3 text = vc
        3 text_seq = i4
      2 reports[*]
        3 br_datamart_report_id = f8
        3 report_name = vc
        3 report_mean = vc
        3 report_seq = i4
        3 text[*]
          4 text_type_mean = vc
          4 text = vc
          4 text_seq = i4
        3 baseline_value = vc
        3 target_value = vc
        3 mpage_pos_flag = i2
        3 mpage_pos_seq = i4
        3 selected_ind = i2
        3 cond_report_mean = vc
        3 mpage_default_ind = i2
        3 layout_flags[*]
          4 layout_flag = i2
      2 cat_baseline_value = vc
      2 cat_target_value = vc
      2 flex_flag = i2
      2 rel_score_ind = i2
      2 base_target_ind = i2
      2 layout_flag = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 IF (validate(del_bed_view_req) != 1)
  RECORD del_bed_view_req(
    1 views[*]
      2 br_datamart_category_id = f8
  )
 ENDIF
 IF (validate(del_bed_view_rep) != 1)
  RECORD del_bed_view_rep(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 IF (validate(cp_component_request) != 1)
  RECORD cp_component_request(
    1 cp_node_id = f8
    1 br_datamart_cat_id = f8
    1 new_components[*]
      2 comp_mean = vc
      2 report_mean = vc
    1 deleted_components[*]
      2 comp_mean = vc
      2 report_mean = vc
  )
 ENDIF
 IF (validate(cp_component_reply) != 1)
  RECORD cp_component_reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 IF (validate(ens_dm_req) != 1)
  RECORD ens_dm_req(
    1 reports[*]
      2 br_datamart_report_id = f8
      2 mpage_pos_flag = i2
      2 mpage_pos_seq = i4
      2 flex_id = f8
      2 flex_types[*]
        3 parent_entity_value = f8
        3 parent_entity_name = vc
        3 parent_entity_type_flag = i2
      2 groups[*]
        3 parent_parent_entity_name = vc
        3 parent_parent_entity_id = f8
        3 parent_parent_entity_type_flag = i2
        3 child_parent_entity_name = vc
        3 child_parent_entity_id = f8
        3 child_parent_entity_type_flag = i2
  )
 ENDIF
 IF (validate(ens_dm_rep) != 1)
  RECORD ens_dm_rep(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 DECLARE main(null) = null
 DECLARE ensurebedrocktoremove(null) = null
 DECLARE ensurebedrocktoadd(null) = null
 DECLARE fetchbedrockreports(null) = null
 DECLARE readinputfileintorecord(null) = null
 DECLARE comprecfilename = vc WITH protect, constant("pathway_to_bedrock_comp_records.json")
 DECLARE current_date_time2 = dq8 WITH constant(curtime3), private
 DECLARE cattypeflagstnd = i2 WITH protect, constant(6)
 DECLARE cattypeflagcpw = i2 WITH protect, constant(7)
 DECLARE addind = i2 WITH protect, constant(1)
 DECLARE zeroflag = i2 WITH protect, constant(0)
 DECLARE statuscompind = i2 WITH protect, constant(2)
 DECLARE currbedcatid = f8 WITH protect, noconstant(0)
 DECLARE currbedcatmean = vc WITH protect, noconstant("")
 DECLARE currbedcatname = vc WITH protect, noconstant("")
 SUBROUTINE main(null)
   CALL log_message("Begin main()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   SET br_maintain_rep->status_data.status = "F"
   CALL errorcheck(null)
   CALL fetchcategoryid(null)
   CALL readinputfileintorecord(null)
   IF (validate(debug_ind,0)=1)
    CALL echo(build("Directory --> ", $MAPDIR))
    CALL echorecord(br_maintain_req)
   ENDIF
   CALL fetchbedrockreportsstandard(null)
   CALL fetchbedrockreportscpcomponents(null)
   IF ((br_maintain_req->new_components_cnt > 0))
    CALL ensurebedrocktoadd(null)
   ENDIF
   IF ((br_maintain_req->deleted_components_cnt > 0))
    CALL ensurebedrocktoremove(null)
   ENDIF
   CALL log_message(build("Exit main(), Elapsed time in seconds:",((curtime3 - begin_curtime3)/ 100.0
     )),log_level_debug)
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE fetchcategoryid(null)
   CALL log_message("Begin fetchCategoryId()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   SELECT INTO "nl:"
    FROM cp_node cn,
     br_datamart_category bdc
    PLAN (cn
     WHERE (cn.cp_node_id=br_maintain_req->cp_node_id))
     JOIN (bdc
     WHERE bdc.category_mean=cn.category_mean)
    HEAD cn.cp_node_id
     IF (cn.category_mean != "")
      currbedcatmean = cn.category_mean, currbedcatid = bdc.br_datamart_category_id, currbedcatname
       = bdc.category_name
     ENDIF
    WITH nocounter
   ;end select
   CALL log_message(build("Exit fetchCategoryId(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE errorcheck(null)
   CALL log_message("Begin errorCheck()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   IF ((br_maintain_req->new_components_cnt=0)
    AND (br_maintain_req->deleted_components_cnt=0))
    SET br_maintain_rep->status_data.status = "Z"
    SET br_maintain_rep->status_data.subeventstatus.operationname = "Init Delete"
    SET br_maintain_rep->status_data.subeventstatus.operationstatus = "Z"
    SET br_maintain_rep->status_data.subeventstatus.targetobjectname = "deleted_components_cnt"
    GO TO exit_script
   ENDIF
   IF ((br_maintain_req->cp_node_id=0))
    SET br_maintain_rep->status_data.status = "F"
    SET br_maintain_rep->status_data.subeventstatus.operationname = "Init Node"
    SET br_maintain_rep->status_data.subeventstatus.operationstatus = "F"
    SET br_maintain_rep->status_data.subeventstatus.targetobjectname = "Node ID cannot be zero"
    GO TO exit_script
   ENDIF
   CALL log_message(build("Exit errorCheck(), Elapsed time in seconds:",((curtime3 - begin_curtime3)
     / 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE readinputfileintorecord(null)
   CALL log_message("Begin ReadInputFileIntoRecord()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   RECORD getreply(
     1 info_line[*]
       2 new_line = vc
     1 data_blob = gvc
     1 data_blob_size = i4
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   RECORD getrequest(
     1 module_dir = vc
     1 module_name = vc
     1 basblob = i2
   )
   SET getrequest->module_dir =  $MAPDIR
   SET getrequest->module_name = comprecfilename
   SET getrequest->basblob = 1
   EXECUTE eks_get_source  WITH replace(request,getrequest), replace(reply,getreply)
   IF (validate(debug_ind,0)=1)
    CALL echorecord(getrequest)
    CALL echorecord(getreply)
   ENDIF
   SET stat = cnvtjsontorec(getreply->data_blob)
   IF (validate(debug_ind,0)=1)
    CALL echorecord(comp_req)
   ENDIF
   IF (size(comp_req->components,5)=0)
    SET br_maintain_rep->status_data.status = "Z"
    SET br_maintain_rep->status_data.subeventstatus.operationname = "No component configuration"
    SET br_maintain_rep->status_data.subeventstatus.operationstatus = "Z"
    SET br_maintain_rep->status_data.subeventstatus.targetobjectname =
    "check pathway_to_bedrock_comp_records.json file"
    GO TO exit_script
   ENDIF
   CALL log_message(build("Exit ReadInputFileIntoRecord(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (checkwizardid(node_id=f8) =null)
   CALL log_message("Begin checkWizardId()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE pathway_name = vc WITH protect, noconstant("")
   DECLARE node_name = vc WITH protect, noconstant("")
   DECLARE snode_id = vc WITH protect, noconstant(cnvtstring(br_maintain_req->cp_node_id))
   DECLARE timestamp = dq8 WITH protect
   SELECT INTO "nl:"
    FROM cp_node cn,
     cp_pathway cp
    PLAN (cn
     WHERE cn.cp_node_id=node_id
      AND cn.cp_node_id > 0)
     JOIN (cp
     WHERE cp.cp_pathway_id=cn.cp_pathway_id)
    HEAD cn.cp_node_id
     pathway_name = trim(trim(cp.pathway_name,4),1), node_name = trim(trim(cn.node_display,4),1)
    WITH nocounter
   ;end select
   IF (currbedcatmean=""
    AND currbedcatid=0)
    SET bed_ens_req->action_flag = addind
    SET bed_ens_req->id = zeroflag
    SET bed_ens_req->display = concat(pathway_name,"-",node_name)
    SET bed_ens_req->identifier = concat(trim(snode_id,3),"_",cnvtstring(cnvtdatetime(curdate,curtime
       )))
    SET bed_ens_req->layout_flag = zeroflag
   ELSE
    SET bed_ens_req->action_flag = zeroflag
    SET bed_ens_req->id = currbedcatid
    SET bed_ens_req->display = currbedcatname
    SET bed_ens_req->identifier = currbedcatmean
    SET bed_ens_req->layout_flag = zeroflag
   ENDIF
   CALL log_message(build("Exit checkWizardId(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE fetchbedrockreportsstandard(null)
   CALL log_message("Begin fetchBedrockReports()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   SET bed_get_datamart_cat_req->category_type_flag = cattypeflagstnd
   EXECUTE bed_get_datamart_cat_reports  WITH replace(request,bed_get_datamart_cat_req), replace(
    reply,bed_get_datamart_cat_std)
   IF (validate(debug_ind,0)=1)
    IF ((bed_get_datamart_cat_std->status_data.status="S"))
     CALL echo(build("---> Successfully loaded bedrock_categories",size(bed_get_datamart_cat_std->
        category,5)))
    ELSE
     SET br_maintain_rep->status_data.status = "F"
     SET br_maintain_rep->status_data.subeventstatus.operationname = "fetchBedrockReports"
     SET br_maintain_rep->status_data.subeventstatus.operationstatus = "F"
     SET br_maintain_rep->status_data.subeventstatus.targetobjectname =
     "Failed to fetch bedrock reports"
     GO TO exit_script
    ENDIF
   ENDIF
   CALL log_message(build("Exit fetchBedrockReports(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE fetchbedrockreportscpcomponents(null)
   CALL log_message("Begin fetchBedrockReports()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   SET bed_get_datamart_cat_req->category_type_flag = cattypeflagcpw
   EXECUTE bed_get_datamart_cat_reports  WITH replace(request,bed_get_datamart_cat_req), replace(
    reply,bed_get_datamart_cat_cp)
   IF (validate(debug_ind,0)=1)
    IF ((bed_get_datamart_cat_cp->status_data.status="S"))
     CALL echo(build("---> Successfully loaded bedrock_categories",size(bed_get_datamart_cat_cp->
        category,5)))
    ELSE
     SET br_maintain_rep->status_data.status = "F"
     SET br_maintain_rep->status_data.subeventstatus.operationname = "fetchBedrockReports"
     SET br_maintain_rep->status_data.subeventstatus.operationstatus = "F"
     SET br_maintain_rep->status_data.subeventstatus.targetobjectname =
     "Failed to fetch bedrock reports"
     GO TO exit_script
    ENDIF
   ENDIF
   CALL log_message(build("Exit fetchBedrockReports(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (getmappedreportmean(compcd=f8) =i4)
   CALL log_message("Begin getMappedReportMean()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE comp_cd_set = f8 WITH protect, constant(4003130)
   DECLARE comp_mean = vc WITH protect, noconstant("")
   DECLARE cindx = i4 WITH protect, noconstant(0)
   DECLARE cloc = i4 WITH protect, noconstant(0)
   DECLARE csize = i4 WITH protect, noconstant(size(comp_req->components,5))
   DECLARE reportmean = vc WITH protect, noconstant("")
   DECLARE nsacnt = i4 WITH protect, noconstant(0)
   DECLARE nsrcnt = i4 WITH protect, noconstant(0)
   SET comp_mean = uar_get_code_meaning(compcd)
   SET cloc = locateval(cindx,0,csize,comp_mean,comp_req->components[cindx].comp_type_mean)
   IF (cloc != 0)
    CALL echo(build("Found report meaning --> ",comp_req->components[cloc].report_mean))
   ELSE
    CALL echo(build("Not a valid component meaning --> ",comp_mean))
   ENDIF
   CALL log_message(build("Exit getMappedReportMean(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
   RETURN(cloc)
 END ;Subroutine
 SUBROUTINE (getbedrockcompmean(compcd=f8) =f8)
   CALL log_message("Begin getBedrockCompMean()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE reportid = f8 WITH protect, noconstant(0)
   DECLARE rindx = i4 WITH protect, noconstant(0)
   DECLARE rloc = i4 WITH protect, noconstant(0)
   DECLARE reportmean = vc WITH protect, noconstant("")
   DECLARE reporttype = i4 WITH protect, noconstant(0)
   SET rloc = getmappedreportmean(compcd)
   SET reportmean = comp_req->components[rloc].report_mean
   IF (rloc > 0)
    IF ((comp_req->components[rloc].care_pathway_only=1))
     SET reporttype = 2
    ELSEIF ((comp_req->components[rloc].standard=1))
     SET reporttype = 1
    ENDIF
   ENDIF
   IF (validate(debug_ind,0)=1)
    CALL echo(build("ReportMean --> ",reportmean))
    CALL echo(build("ReportType --> ",reporttype))
   ENDIF
   IF (reportmean != ""
    AND reporttype > 0)
    IF (reporttype=1)
     SELECT INTO "nl:"
      FROM (dummyt d1  WITH seq = value(size(bed_get_datamart_cat_std->category,5))),
       (dummyt d2  WITH seq = 2)
      PLAN (d1
       WHERE maxrec(d2,size(bed_get_datamart_cat_std->category[d1.seq].reports,5))
        AND size(bed_get_datamart_cat_std->category,5) > 0)
       JOIN (d2
       WHERE size(bed_get_datamart_cat_std->category[d1.seq].reports,5) > 0
        AND (bed_get_datamart_cat_std->category[d1.seq].reports[d2.seq].report_mean=cnvtupper(
        reportmean)))
      HEAD d2.seq
       reportid = bed_get_datamart_cat_std->category[d1.seq].reports[d2.seq].br_datamart_report_id
       IF (validate(debug_ind,0)=1)
        CALL echo(build("ReportMean --> ",bed_get_datamart_cat_std->category[d1.seq].reports[d2.seq].
         report_mean)),
        CALL echo(build("ReportID --> ",reportid))
       ENDIF
      WITH nocounter
     ;end select
    ELSEIF (reporttype=2)
     SELECT INTO "nl:"
      FROM (dummyt d1  WITH seq = value(size(bed_get_datamart_cat_cp->category,5))),
       (dummyt d2  WITH seq = 2)
      PLAN (d1
       WHERE maxrec(d2,size(bed_get_datamart_cat_cp->category[d1.seq].reports,5))
        AND size(bed_get_datamart_cat_cp->category,5) > 0)
       JOIN (d2
       WHERE size(bed_get_datamart_cat_cp->category[d1.seq].reports,5) > 0
        AND (bed_get_datamart_cat_cp->category[d1.seq].reports[d2.seq].report_mean=cnvtupper(
        reportmean)))
      HEAD d2.seq
       reportid = bed_get_datamart_cat_cp->category[d1.seq].reports[d2.seq].br_datamart_report_id
       IF (validate(debug_ind,0)=1)
        CALL echo(build("ReportMean --> ",bed_get_datamart_cat_cp->category[d1.seq].reports[d2.seq].
         report_mean)),
        CALL echo(build("ReportID --> ",reportid))
       ENDIF
      WITH nocounter
     ;end select
    ENDIF
   ELSE
    CALL echo(build("--->Failed to locate report in Standard and Non standard Components : ",
      reportmean))
   ENDIF
   IF (reportid=0)
    CALL echo(build("invalid report / component mean --> ",reportmean))
   ENDIF
   CALL log_message(build("Exit getBedrockCompMean(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
   RETURN(reportid)
 END ;Subroutine
 SUBROUTINE (updatecpnodecategory(categoryid=f8) =null)
   CALL log_message("Begin updateCpNodeCategory()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE updtchk = i2 WITH protect, noconstant(0)
   DECLARE currbedmean = vc WITH protect, noconstant("")
   IF (categoryid > 0)
    SELECT INTO "nl:"
     FROM br_datamart_category bdc
     PLAN (bdc
      WHERE bdc.br_datamart_category_id=categoryid)
     HEAD bdc.br_datamart_category_id
      currbedmean = bdc.category_mean, br_maintain_rep->category_display = bdc.category_name
     WITH nocounter
    ;end select
   ELSE
    SET currbedmean = ""
   ENDIF
   IF (categoryid > 0)
    UPDATE  FROM br_datamart_category bdc
     SET bdc.flex_flag = zeroflag, bdc.updt_cnt = (bdc.updt_cnt+ 1), bdc.updt_dt_tm = cnvtdatetime(
       sysdate),
      bdc.updt_applctx = reqinfo->updt_applctx, bdc.updt_task = reqinfo->updt_task
     WHERE bdc.br_datamart_category_id=categoryid
    ;end update
    IF (curqual=0)
     SET br_maintain_rep->status_data.status = "F"
     SET br_maintain_rep->status_data.subeventstatus[1].operationname = "updateCpNodeCategory"
     SET br_maintain_rep->status_data.subeventstatus[1].operationstatus = "F"
     SET br_maintain_rep->status_data.subeventstatus[1].targetobjectname = "BR_DATAMART_CATEGORY"
     SET br_maintain_rep->status_data.subeventstatus[1].targetobjectvalue = "FLEX_FLAG"
     GO TO exit_script
    ELSE
     CALL echo(build("Turned Off Flexing for Category --> ",categoryid," ",currbedmean))
    ENDIF
   ENDIF
   UPDATE  FROM cp_node cn
    SET cn.category_mean = currbedmean, cn.updt_cnt = (cn.updt_cnt+ 1), cn.updt_dt_tm = cnvtdatetime(
      sysdate),
     cn.updt_applctx = reqinfo->updt_applctx, cn.updt_task = reqinfo->updt_task
    PLAN (cn
     WHERE (cn.cp_node_id=br_maintain_req->cp_node_id))
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET br_maintain_rep->status_data.status = "F"
    SET br_maintain_rep->status_data.subeventstatus[1].operationname = "updateCpNodeCategory"
    SET br_maintain_rep->status_data.subeventstatus[1].operationstatus = "F"
    SET br_maintain_rep->status_data.subeventstatus[1].targetobjectname = "CP_NODE"
    SET br_maintain_rep->status_data.subeventstatus[1].targetobjectvalue = "CATEGORY_MEAN"
    GO TO exit_script
   ELSE
    CALL echo(build("New category mean added for node --> ",br_maintain_req->cp_node_id," ",
      currbedmean))
   ENDIF
   CALL log_message(build("Exit updateCpNodeCategory(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE ensurebedrocktoadd(null)
   CALL log_message("Begin ensureBedrockToAdd()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE asize = i4 WITH protect, noconstant(br_maintain_req->new_components_cnt)
   DECLARE acnt = i4 WITH protect, noconstant(0)
   DECLARE bcnt = i4 WITH protect, noconstant(0)
   DECLARE reportid = f8 WITH protect, noconstant(0)
   DECLARE ccnt = i4 WITH protect, noconstant(0)
   DECLARE dcnt = i4 WITH protect, noconstant(0)
   DECLARE ecnt = i4 WITH protect, noconstant(0)
   DECLARE newcnt = i4 WITH protect, noconstant(0)
   DECLARE gtcomp = f8 WITH protect, noconstant(0)
   SET stat = initrec(bed_ens_req)
   SET stat = initrec(bed_ens_rep)
   CALL checkwizardid(br_maintain_req->cp_node_id)
   FOR (acnt = 1 TO asize)
    SET reportid = getbedrockcompmean(br_maintain_req->new_components[acnt].comp_type_cd)
    IF (reportid > 0)
     SET ccnt += 1
     SET newcnt += 1
     SET stat = alterlist(bed_ens_req->components,ccnt)
     SET bed_ens_req->components[ccnt].action_flag = addind
     SET bed_ens_req->components[ccnt].id = reportid
     SET bed_ens_req->components[ccnt].status_ind = statuscompind
    ENDIF
   ENDFOR
   IF (currbedcatid > 0)
    SELECT INTO "nl:"
     FROM br_datamart_report bdr
     PLAN (bdr
      WHERE bdr.br_datamart_category_id=currbedcatid)
     HEAD bdr.br_datamart_report_id
      ccnt += 1, stat = alterlist(bed_ens_req->components,ccnt), bed_ens_req->components[ccnt].
      action_flag = zeroflag,
      bed_ens_req->components[ccnt].id = bdr.br_datamart_report_id, bed_ens_req->components[ccnt].
      status_ind = statuscompind
     WITH nocounter
    ;end select
   ENDIF
   IF (validate(debug_ind,0)=1)
    CALL echorecord(bed_ens_req)
   ENDIF
   IF (newcnt > 0)
    EXECUTE bed_ens_custom_mpage  WITH replace(request,bed_ens_req), replace(reply,bed_ens_rep)
    IF (validate(debug_ind,0)=1)
     CALL echorecord(bed_ens_rep)
    ENDIF
    IF ((bed_ens_rep->status_data.status="S"))
     IF ((bed_ens_req->action_flag=1))
      CALL updatecpnodecategory(bed_ens_rep->id)
     ENDIF
     IF ((bed_ens_rep->id > 0))
      SELECT INTO "nl:"
       FROM br_datamart_category bdc
       PLAN (bdc
        WHERE (bdc.br_datamart_category_id=bed_ens_rep->id))
       HEAD bdc.br_datamart_category_id
        br_maintain_rep->category_display = bdc.category_name
       WITH nocounter
      ;end select
      FOR (bcnt = 1 TO asize)
        IF ((bed_ens_rep->components[bcnt].id > 0))
         SET dcnt += 1
         SET stat = alterlist(ens_dm_req->reports,dcnt)
         SET ens_dm_req->reports[dcnt].br_datamart_report_id = bed_ens_rep->components[bcnt].id
         IF ((bed_ens_rep->components[bcnt].mean="PW_GUIDED_TREATMENT"))
          SET gtcomp = bed_ens_rep->components[bcnt].id
         ENDIF
        ENDIF
      ENDFOR
      SELECT INTO "nl:"
       FROM br_datamart_value bdv,
        br_datamart_report bdr
       PLAN (bdv
        WHERE (bdv.br_datamart_category_id=bed_ens_rep->id)
         AND bdv.mpage_param_value=null
         AND bdv.value_seq > 0
         AND bdv.parent_entity_name="BR_DATAMART_REPORT")
        JOIN (bdr
        WHERE bdr.br_datamart_report_id=bdv.parent_entity_id)
       DETAIL
        dcnt += 1, stat = alterlist(ens_dm_req->reports,dcnt), ens_dm_req->reports[dcnt].
        br_datamart_report_id = bdv.parent_entity_id
        IF (bdr.report_mean="PW_GUIDED_TREATMENT")
         gtcomp = bdr.br_datamart_report_id
        ENDIF
       WITH nocounter
      ;end select
      FOR (ecnt = 1 TO dcnt)
        SELECT INTO "nl:"
         FROM br_datamart_report bdr
         WHERE (bdr.br_datamart_report_id=ens_dm_req->reports[ecnt].br_datamart_report_id)
         DETAIL
          IF (bdr.br_datamart_report_id=gtcomp)
           ens_dm_req->reports[ecnt].mpage_pos_flag = 1, ens_dm_req->reports[ecnt].mpage_pos_seq = 1
          ELSE
           ens_dm_req->reports[ecnt].mpage_pos_flag = bdr.mpage_pos_flag, ens_dm_req->reports[ecnt].
           mpage_pos_seq = bdr.mpage_pos_seq
          ENDIF
         WITH nocounter
        ;end select
      ENDFOR
      IF (validate(debug_ind,0)=1)
       CALL echorecord(ens_dm_req)
      ENDIF
      EXECUTE bed_ens_datamart_report_val  WITH replace(request,ens_dm_req), replace(reply,ens_dm_rep
       )
     ENDIF
     CALL updatevpcapableind(bed_ens_rep->id)
    ELSE
     SET br_maintain_rep->status_data.status = bed_ens_rep->status_data.status
     SET stat = moverec(bed_ens_rep->status_data.subeventstatus,br_maintain_rep->status_data.
      subeventstatus)
     GO TO exit_script
    ENDIF
    SET br_maintain_rep->status_data.status = bed_ens_rep->status_data.status
    SET stat = moverec(bed_ens_rep->status_data.subeventstatus,br_maintain_rep->status_data.
     subeventstatus)
   ENDIF
   CALL log_message(build("Exit ensureBedrockToAdd(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (updatevpcapableind(categoryid=f8) =null)
   CALL log_message("Begin updateVPCapableInd()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   UPDATE  FROM br_datamart_category bdc
    SET bdc.viewpoint_capable_ind = zeroflag, bdc.updt_id = reqinfo->updt_id, bdc.updt_applctx =
     reqinfo->updt_applctx,
     bdc.updt_task = reqinfo->updt_task, bdc.updt_dt_tm = cnvtdatetime(sysdate), bdc.updt_cnt = (bdc
     .updt_cnt+ 1)
    WHERE bdc.br_datamart_category_id=categoryid
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET br_maintain_rep->status_data.status = "F"
    SET br_maintain_rep->status_data.subeventstatus[1].operationname = "updateVPCapableInd"
    SET br_maintain_rep->status_data.subeventstatus[1].operationstatus = "F"
    SET br_maintain_rep->status_data.subeventstatus[1].targetobjectname = "BR_DATAMART_CATEGORY"
    SET br_maintain_rep->status_data.subeventstatus[1].targetobjectvalue = "viewpoint_capable_ind"
    GO TO exit_script
   ELSE
    IF (validate(debug_ind,0)=1)
     CALL echo(build("Turned Off viewpoint capable ind for Category --> ",categoryid))
    ENDIF
   ENDIF
   CALL log_message(build("Exit updateVPCapableInd(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE ensurebedrocktoremove(null)
   CALL log_message("Begin ensureBedrockToRemove()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE msize = i4 WITH protect, noconstant(br_maintain_req->deleted_components_cnt)
   DECLARE mcnt = i4 WITH protect, noconstant(0)
   DECLARE ccnt = i4 WITH protect, noconstant(0)
   DECLARE reportmean = vc WITH protect, noconstant("")
   DECLARE rindx = i4 WITH protect, noconstant(0)
   DECLARE rloc = i4 WITH protect, noconstant(0)
   DECLARE rcnt = i4 WITH protect, noconstant(0)
   DECLARE reloc = i4 WITH protect, noconstant(0)
   SET stat = initrec(bed_ens_req)
   SET stat = initrec(bed_ens_rep)
   FREE RECORD delete_rep_mean
   CALL checkwizardid(br_maintain_req->cp_node_id)
   RECORD delete_rep_mean(
     1 reports[*]
       2 report_mean = vc
   )
   FOR (mcnt = 1 TO msize)
     SET reloc = getmappedreportmean(br_maintain_req->deleted_components[mcnt].comp_type_cd)
     SET reportmean = comp_req->components[reloc].report_mean
     IF (reportmean != ""
      AND reloc > 0)
      SET rcnt += 1
      SET stat = alterlist(delete_rep_mean->reports,rcnt)
      SET delete_rep_mean->reports[rcnt].report_mean = reportmean
     ELSEIF ((br_maintain_req->deleted_components[mcnt].report_mean != ""))
      SET rcnt += 1
      SET stat = alterlist(delete_rep_mean->reports,rcnt)
      SET delete_rep_mean->reports[rcnt].report_mean = br_maintain_req->deleted_components[mcnt].
      report_mean
     ENDIF
   ENDFOR
   IF (validate(debug_ind,0)=1)
    CALL echorecord(delete_rep_mean)
   ENDIF
   IF (rcnt > 0)
    SELECT INTO "nl:"
     FROM br_datamart_report bdr
     PLAN (bdr
      WHERE bdr.br_datamart_category_id=currbedcatid)
     HEAD REPORT
      rloc = 0
     HEAD bdr.br_datamart_report_id
      rloc = locateval(rindx,0,size(delete_rep_mean->reports,5),bdr.report_mean,delete_rep_mean->
       reports[rindx].report_mean)
      IF (rloc=0)
       ccnt += 1, stat = alterlist(bed_ens_req->components,ccnt), bed_ens_req->components[ccnt].
       action_flag = zeroflag,
       bed_ens_req->components[ccnt].id = bdr.br_datamart_report_id, bed_ens_req->components[ccnt].
       status_ind = statuscompind
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   IF (size(bed_ens_req->components,5) > 0)
    SET bed_ens_req->action_flag = 2
    EXECUTE bed_ens_custom_mpage  WITH replace(request,bed_ens_req), replace(reply,bed_ens_rep)
    IF (validate(debug_ind,0)=1)
     CALL echorecord(bed_ens_req)
     CALL echorecord(bed_ens_rep)
    ENDIF
    SET br_maintain_rep->status_data.status = bed_ens_rep->status_data.status
    SET stat = moverec(bed_ens_rep->status_data.subeventstatus,br_maintain_rep->status_data.
     subeventstatus)
   ELSEIF (rcnt > 0)
    CALL updatecpnodecategory(0.00)
    SET stat = alterlist(del_bed_view_req->views,1)
    SET del_bed_view_req->views[1].br_datamart_category_id = currbedcatid
    EXECUTE bed_del_vb_views  WITH replace(request,del_bed_view_req), replace(reply,del_bed_view_rep)
    SET br_maintain_rep->status_data.status = del_bed_view_rep->status_data.status
    SET stat = moverec(del_bed_view_rep->status_data.subeventstatus,br_maintain_rep->status_data.
     subeventstatus)
   ENDIF
   CALL log_message(build("Exit ensureBedrockToRemove(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 CALL main(null)
#exit_script
 IF ((br_maintain_rep->status_data.status="S"))
  CALL echo("***** Success :  cp_maintain_br_wizard ****")
  SET reqinfo->commit_ind = 1
 ELSE
  CALL echo("***** Failure :  cp_maintain_br_wizard ****")
  ROLLBACK
 ENDIF
 IF (validate(debug_ind,0)=1)
  CALL echorecord(br_maintain_rep)
 ENDIF
 CALL log_message(concat("Exiting script: ",log_program_name),log_level_debug)
 CALL log_message(build("Total time in seconds:",((curtime3 - current_date_time2)/ 100.0)),
  log_level_debug)
 CALL echo("***** END SCRIPT:  cp_maintain_br_wizard ****")
END GO
