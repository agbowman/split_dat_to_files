CREATE PROGRAM cp_export_pathway
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "CP Pathway Id" = 0.0
  WITH outdev, dinputpathwayid
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
 SUBROUTINE (getentitydisplay_cpnode(val=f8) =vc WITH protect)
   CALL log_message("In GetEntityDisplay_CpNode()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE val_display = vc WITH protect
   SELECT INTO "nl:"
    FROM cp_node cn
    WHERE cn.cp_node_id=val
    DETAIL
     val_display = cn.node_display
    WITH nocounter
   ;end select
   CALL log_message(build("Exit GetEntityDisplay_CpNode(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
   RETURN(val_display)
 END ;Subroutine
 SUBROUTINE (getentitydisplay_pathwaycatalog(val=f8) =vc WITH protect)
   CALL log_message("In GetEntityDisplay_PathwayCatalog()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE val_display = vc WITH protect
   SELECT INTO "nl:"
    FROM pathway_catalog pc
    WHERE pc.pathway_catalog_id=val
    DETAIL
     val_display = pc.description
    WITH nocounter
   ;end select
   CALL log_message(build("Exit GetEntityDisplay_PathwayCatalog(), Elapsed time in seconds:",((
     curtime3 - begin_curtime3)/ 100.0)),log_level_debug)
   RETURN(val_display)
 END ;Subroutine
 SUBROUTINE (getentitydisplay_regimencatalog(val=f8) =vc WITH protect)
   CALL log_message("In GetEntityDisplay_RegimenCatalog()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE val_display = vc WITH protect
   SELECT INTO "nl:"
    FROM regimen_catalog rc
    WHERE rc.regimen_catalog_id=val
    DETAIL
     val_display = rc.regimen_name
    WITH nocounter
   ;end select
   CALL log_message(build("Exit GetEntityDisplay_RegimenCatalog(), Elapsed time in seconds:",((
     curtime3 - begin_curtime3)/ 100.0)),log_level_debug)
   RETURN(val_display)
 END ;Subroutine
 SUBROUTINE (getentitydisplay_ordersentence(val=f8) =vc WITH protect)
   CALL log_message("In GetEntityDisplay_OrderSentence()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE val_display = vc WITH protect
   SELECT INTO "nl:"
    FROM order_sentence os,
     (left JOIN order_catalog_synonym ocs ON ocs.synonym_id=os.parent_entity_id)
    PLAN (os
     WHERE os.order_sentence_id=val)
     JOIN (ocs)
    DETAIL
     IF (size(ocs.mnemonic) > 0)
      val_display = build2(trim(ocs.mnemonic,3)," (",trim(os.order_sentence_display_line,3),")")
     ELSE
      val_display = os.order_sentence_display_line
     ENDIF
    WITH nocounter
   ;end select
   CALL log_message(build("Exit GetEntityDisplay_OrderSentence(), Elapsed time in seconds:",((
     curtime3 - begin_curtime3)/ 100.0)),log_level_debug)
   RETURN(val_display)
 END ;Subroutine
 SUBROUTINE (getentitydisplay_ordercatalogsynonym(val=f8) =vc WITH protect)
   CALL log_message("In GetEntityDisplay_OrderCatalogSynonym()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE val_display = vc WITH protect
   SELECT INTO "nl:"
    FROM order_catalog_synonym ocs
    WHERE ocs.synonym_id=val
    DETAIL
     val_display = ocs.mnemonic
    WITH nocounter
   ;end select
   CALL log_message(build("Exit GetEntityDisplay_OrderCatalogSynonym(), Elapsed time in seconds:",((
     curtime3 - begin_curtime3)/ 100.0)),log_level_debug)
   RETURN(val_display)
 END ;Subroutine
 SUBROUTINE (getentitydisplay_longtextreference(val=f8) =vc WITH protect)
   CALL log_message("In GetEntityDisplay_AltSelCat()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE val_display = gvc WITH protect
   DECLARE outbuf = vc WITH protect, noconstant(" ")
   DECLARE totlen = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM long_text_reference ltr
    WHERE ltr.long_text_id=val
    DETAIL
     imagedatasize = blobgetlen(ltr.long_text), stat = memrealloc(outbuf,1,build("C",imagedatasize)),
     totlen = blobget(outbuf,0,ltr.long_text),
     val_display = notrim(outbuf)
    WITH nocounter
   ;end select
   CALL log_message(build("Exit GetEntityDisplay_LongTextReference(), Elapsed time in seconds:",((
     curtime3 - begin_curtime3)/ 100.0)),log_level_debug)
   RETURN(val_display)
 END ;Subroutine
 SUBROUTINE (getentitydisplay_altselcat(val=f8) =vc WITH protect)
   CALL log_message("In GetEntityDisplay_AltSelCat()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE val_display = vc WITH protect
   SELECT INTO "nl:"
    FROM alt_sel_cat a
    WHERE a.alt_sel_category_id=val
    DETAIL
     val_display = trim(a.long_description)
    WITH nocounter
   ;end select
   CALL log_message(build("Exit GetEntityDisplay_AltSelCat(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
   RETURN(val_display)
 END ;Subroutine
 SUBROUTINE (getentitydisplay_eventsetcd(val=f8) =vc WITH protect)
   CALL log_message("In GetEntityDisplay_EventSetCd()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE val_display = vc WITH protect
   SELECT INTO "nl:"
    FROM v500_event_set_code v
    WHERE v.event_set_cd=val
    DETAIL
     val_display = trim(v.event_set_name)
    WITH nocounter
   ;end select
   CALL log_message(build("Exit GetEntityDisplay_EventSetCd(), Elapsed time in seconds:",((curtime3
      - begin_curtime3)/ 100.0)),log_level_debug)
   RETURN(val_display)
 END ;Subroutine
 SUBROUTINE (getentitydisplay_outcomecatalog(val=f8) =vc WITH protect)
   CALL log_message("In GetEntityDisplay_OutcomeCatalog()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE val_display = vc WITH protect
   SELECT INTO "nl:"
    FROM outcome_catalog oc
    WHERE oc.outcome_catalog_id=val
    DETAIL
     IF (textlen(trim(oc.expectation)) > 0)
      val_display = build2(trim(oc.description)," - ",trim(oc.expectation))
     ELSE
      val_display = build2(trim(oc.description))
     ENDIF
    WITH nocounter
   ;end select
   CALL log_message(build("Exit GetEntityDisplay_OutcomeCatalog(), Elapsed time in seconds:",((
     curtime3 - begin_curtime3)/ 100.0)),log_level_debug)
   RETURN(val_display)
 END ;Subroutine
 SUBROUTINE (getentitydisplay_ordercatalog(val=f8) =vc WITH protect)
   CALL log_message("In GetEntityDisplay_OrderCatalog()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE val_display = vc WITH protect
   SELECT INTO "nl:"
    FROM order_catalog o
    WHERE o.catalog_cd=val
    DETAIL
     val_display = trim(o.primary_mnemonic)
    WITH nocounter
   ;end select
   CALL log_message(build("Exit GetEntityDisplay_OrderCatalog(), Elapsed time in seconds:",((curtime3
      - begin_curtime3)/ 100.0)),log_level_debug)
   RETURN(val_display)
 END ;Subroutine
 SUBROUTINE (getentitydisplay_nomenclature(val=f8) =vc WITH protect)
   CALL log_message("In GetEntityDisplay_Nomenclature()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE val_display = vc WITH protect
   SELECT INTO "nl:"
    FROM nomenclature n
    WHERE n.nomenclature_id=val
    DETAIL
     val_display = trim(n.mnemonic)
    WITH nocounter
   ;end select
   CALL log_message(build("Exit GetEntityDisplay_Nomenclature(), Elapsed time in seconds:",((curtime3
      - begin_curtime3)/ 100.0)),log_level_debug)
   RETURN(val_display)
 END ;Subroutine
 SUBROUTINE (getentitydisplay_datamartfilter(val=f8) =vc WITH protect)
   CALL log_message("In GetEntityDisplay_DatamartFilter()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE val_display = vc WITH protect
   SELECT INTO "nl:"
    FROM br_datamart_filter bdf
    WHERE bdf.br_datamart_filter_id=val
    DETAIL
     val_display = trim(bdf.filter_display)
    WITH nocounter
   ;end select
   CALL log_message(build("Exit GetEntityDisplay_DatamartFilter(), Elapsed time in seconds:",((
     curtime3 - begin_curtime3)/ 100.0)),log_level_debug)
   RETURN(val_display)
 END ;Subroutine
 SUBROUTINE (getentitydisplay_patedreltn(val=vc) =vc WITH protect)
   CALL log_message("In GetEntityDisplay_PatEdReltn()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE val_display = vc WITH protect
   SELECT INTO "nl:"
    FROM pat_ed_reltn p
    WHERE p.key_doc_ident=val
    DETAIL
     val_display = trim(p.pat_ed_reltn_desc)
    WITH nocounter
   ;end select
   CALL log_message(build("Exit GetEntityDisplay_PatEdReltn(), Elapsed time in seconds:",((curtime3
      - begin_curtime3)/ 100.0)),log_level_debug)
   RETURN(val_display)
 END ;Subroutine
 SUBROUTINE (getentitydisplay_hmexpect(val=f8) =vc WITH protect)
   CALL log_message("In GetEntityDisplay_HmExpect()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE val_display = vc WITH protect
   SELECT INTO "nl:"
    FROM hm_expect he
    WHERE he.expect_id=val
    DETAIL
     val_display = trim(he.expect_name)
    WITH nocounter
   ;end select
   CALL log_message(build("Exit GetEntityDisplay_HmExpect(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
   RETURN(val_display)
 END ;Subroutine
 SUBROUTINE (getentitydisplay_drugcats(val=f8) =vc WITH protect)
   CALL log_message("In GetEntityDisplay_DrugCats()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE val_display = vc WITH protect
   SELECT INTO "nl:"
    FROM mltm_drug_categories mdc
    WHERE mdc.multum_category_id=val
    DETAIL
     val_display = trim(mdc.category_name)
    WITH nocounter
   ;end select
   CALL log_message(build("Exit GetEntityDisplay_DrugCats(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
   RETURN(val_display)
 END ;Subroutine
 FREE RECORD pw_rec
 RECORD pw_rec(
   1 qual[*]
     2 cp_pathway_id = f8
     2 pathway_name = vc
     2 pathway_type_cd = f8
     2 pathway_type_mean = vc
     2 pathway_status_cd = f8
     2 pathway_status_mean = vc
     2 concept_cd = f8
     2 concept_group_cd = f8
     2 intention_cd = f8
     2 concept_display_key = vc
     2 pathway_diagram_url = vc
     2 node_cnt = i4
     2 node_list[*]
       3 cp_node_id = f8
       3 concept_cd = f8
       3 node_name = vc
       3 intention_cd = f8
       3 intention_mean = vc
       3 treatment_line_cd = f8
       3 category_mean = vc
       3 behavior_cnt = f8
       3 sequence = i4
       3 behaviors[*]
         4 reaction_entity_id = f8
         4 reaction_entity_name = vc
         4 reaction_type_mean = vc
         4 response_ident = vc
         4 response_entity_disp = vc
       3 comp_cnt = i4
       3 comp_list[*]
         4 cp_component_id = f8
         4 cp_node_id = f8
         4 comp_type_cd = f8
         4 comp_type_mean = vc
         4 concept_group_cd = f8
         4 concept_group_mean = vc
         4 comp_dtl_cnt = i4
         4 component_seq_txt = vc
         4 comp_dtl_list[*]
           5 cp_component_detail_id = f8
           5 cp_component_id = f8
           5 comp_detail_reltn_cd = f8
           5 comp_detail_reltn_mean = vc
           5 component_entity_id = f8
           5 component_entity_name = vc
           5 component_ident = vc
           5 component_text = vc
           5 comp_detail_entity_disp = vc
           5 version_nbr = i4
           5 version_text = vc
           5 default_ind = i2
           5 source_flag = i2
           5 version_flag = i2
         4 folder[*]
           5 id = f8
           5 short_desc = vc
           5 long_desc = vc
           5 parent_id = f8
           5 item[*]
             6 plan_desc = vc
             6 regimen_desc = vc
             6 synonym_id = f8
             6 synonym = vc
             6 key_cap = vc
             6 sentence_id = f8
             6 display = vc
             6 usage_flag = i2
             6 orderable_type_flag = i2
             6 format_id = f8
             6 format_name = vc
             6 parent_entity_name = vc
             6 parent_entity_id = f8
             6 parent_entity2_name = vc
             6 parent_entity2_id = f8
             6 details[*]
               7 sequence = i4
               7 oe_field_id = f8
               7 oe_field_display_value = vc
               7 oe_field_value = f8
               7 oe_field_meaning_id = f8
               7 field_type_flag = i2
     2 triggering_criteria[*]
       3 triggering_criteria_disp = vc
       3 criteria_type_mean = vc
       3 triggering_criteria_ident = vc
       3 triggering_entity_id = f8
       3 triggering_entity_name = vc
       3 triggering_criteria_terminology = vc
       3 triggering_criteria_group_mean = vc
     2 structured_content[*]
       3 sdoc_blob = gvc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH persistscript
 FREE RECORD export_reply
 RECORD export_reply(
   1 current_node_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD triggering_criteria_reply
 RECORD triggering_criteria_reply(
   1 cnt = i4
   1 qual[*]
     2 triggering_criteria_disp = vc
     2 criteria_type_mean = vc
     2 triggering_criteria_ident = vc
     2 triggering_entity_id = f8
     2 triggering_entity_name = vc
     2 triggering_criteria_terminology = vc
     2 triggering_criteria_group_mean = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD folder_ids_list
 RECORD folder_ids_list(
   1 qual[*]
     2 folder_id = f8
 ) WITH persistscript
 DECLARE loadpathwayconfig(null) = null WITH protect
 DECLARE buildpathwayexportstructure(null) = null WITH protect
 DECLARE buildnodeexportstructure(null) = null WITH protect
 DECLARE buildtriggeringcriteria(null) = null WITH protect
 DECLARE writejsontofile(null) = null WITH protect
 DECLARE dnumcount = f8 WITH protect, noconstant(0)
 DECLARE cppathwayid = f8 WITH protect, constant( $DINPUTPATHWAYID)
 DECLARE foldersjson = vc WITH protect
 CALL log_message(build2("Begin program ",log_program_name),log_level_debug)
 DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
 SET export_reply->status_data.status = "F"
 CALL loadpathwayconfig(null)
 CALL buildpathwayexportstructure(null)
 CALL buildtriggeringcriteria(null)
 SET export_reply->status_data.status = "S"
 CALL writejsontofile(null)
 SUBROUTINE loadpathwayconfig(null)
   CALL log_message("Begin LoadPathwayConfig()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   EXECUTE cp_load_pathway_config "NOFORMS",  $DINPUTPATHWAYID
   CALL log_message(build("Exit LoadPathwayConfig(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (getnodebehaviors(nodeidx=i4) =null WITH protect)
   CALL log_message("Begin GetNodeBehaviors()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE x = i4 WITH noconstant(0), protect
   DECLARE search_cntr = i4 WITH noconstant(0), protect
   DECLARE doc_comp_indx = i4 WITH noconstant(0), protect
   DECLARE doc_comp_det_indx = i4 WITH noconstant(0), protect
   DECLARE cur_doc_instance_ident = vc WITH noconstant(""), protect
   DECLARE behavior_cnt = i4 WITH noconstant(0), protect
   DECLARE node_id = f8 WITH noconstant(0), protect
   DECLARE initial_recommendations_prefix = vc WITH constant("InitialRecommendations_"), protect
   DECLARE initial_recommendations_ident = vc WITH noconstant(""), protect
   SET doc_comp_indx = locateval(search_cntr,1,size(reply->node_list[nodeidx].component_list,5),
    "GUIDEDTRMNT",reply->node_list[nodeidx].component_list[search_cntr].comp_type_cd_meaning)
   IF (doc_comp_indx=0)
    SET doc_comp_indx = locateval(search_cntr,1,size(reply->node_list[nodeidx].component_list,5),
     "PATHWAY_DOC",reply->node_list[nodeidx].component_list[search_cntr].comp_type_cd_meaning)
   ENDIF
   IF (doc_comp_indx > 0)
    SET doc_comp_det_indx = locateval(search_cntr,1,size(reply->node_list[nodeidx].component_list[
      doc_comp_indx].comp_detail_list,5),"DOCCONTENT",reply->node_list[nodeidx].component_list[
     doc_comp_indx].comp_detail_list[search_cntr].detail_reltn_cd_mean)
    IF (doc_comp_det_indx > 0
     AND (((reply->node_list[nodeidx].component_list[doc_comp_indx].comp_detail_list[
    doc_comp_det_indx].default_ind > 0)) OR ((reply->node_list[nodeidx].component_list[doc_comp_indx]
    .comp_detail_list[doc_comp_det_indx].version_nbr=0))) )
     SET cur_doc_instance_ident = reply->node_list[nodeidx].component_list[doc_comp_indx].
     comp_detail_list[doc_comp_det_indx].entity_ident
    ENDIF
   ENDIF
   IF (validate(debug_ind,0))
    CALL echo(build(" cur_doc_instance_ident --- > ",cur_doc_instance_ident))
   ENDIF
   SET node_id = reply->node_list[nodeidx].cp_node_id
   SET initial_recommendations_ident = concat(initial_recommendations_prefix,cnvtstring(node_id))
   SET stat = initrec(record_data)
   EXECUTE cp_get_node_bhvr "MINE", cppathwayid, node_id,
   nullterm(cur_doc_instance_ident)
   SET stat = alterlist(pw_rec->qual[1].node_list[nodeidx].behaviors,record_data->cnt)
   SET pw_rec->qual[1].node_list[nodeidx].behavior_cnt = record_data->cnt
   FOR (x = 1 TO record_data->cnt)
     SET pw_rec->qual[1].node_list[nodeidx].behaviors[x].reaction_entity_name = record_data->qual[x].
     reaction_entity_name
     SET pw_rec->qual[1].node_list[nodeidx].behaviors[x].reaction_type_mean = record_data->qual[x].
     reaction_type_mean
     SET pw_rec->qual[1].node_list[nodeidx].behaviors[x].response_ident = record_data->qual[x].
     response_ident
     SET pw_rec->qual[1].node_list[nodeidx].behaviors[x].response_entity_disp =
     getentitydisplaybyname(record_data->qual[x].reaction_entity_name,record_data->qual[x].
      reaction_entity_id,"")
   ENDFOR
   SET stat = initrec(record_data)
   EXECUTE cp_get_node_bhvr "MINE", cppathwayid, node_id,
   initial_recommendations_ident
   SET behavior_cnt = pw_rec->qual[1].node_list[nodeidx].behavior_cnt
   SET stat = alterlist(pw_rec->qual[1].node_list[nodeidx].behaviors,(behavior_cnt+ record_data->cnt)
    )
   FOR (x = 1 TO record_data->cnt)
     SET behavior_cnt += 1
     SET pw_rec->qual[1].node_list[nodeidx].behavior_cnt = behavior_cnt
     SET pw_rec->qual[1].node_list[nodeidx].behaviors[behavior_cnt].reaction_entity_name =
     record_data->qual[x].reaction_entity_name
     SET pw_rec->qual[1].node_list[nodeidx].behaviors[behavior_cnt].reaction_type_mean = record_data
     ->qual[x].reaction_type_mean
     SET pw_rec->qual[1].node_list[nodeidx].behaviors[behavior_cnt].response_ident = record_data->
     qual[x].response_ident
     SET pw_rec->qual[1].node_list[nodeidx].behaviors[behavior_cnt].response_entity_disp =
     getentitydisplaybyname(record_data->qual[x].reaction_entity_name,record_data->qual[x].
      reaction_entity_id,"")
   ENDFOR
   CALL log_message(build("Exit GetNodeBehaviors(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE buildpathwayexportstructure(null)
   CALL log_message("Begin BuildPathwayExportStructure()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   SET stat = alterlist(pw_rec->qual,1)
   SET pw_rec->qual[1].pathway_name = reply->pathway_name
   SET pw_rec->qual[1].pathway_type_cd = reply->pathway_type_cd
   SET pw_rec->qual[1].pathway_status_mean = reply->pathway_status_mean
   SET pw_rec->qual[1].pathway_status_cd = reply->pathway_status_cd
   SET pw_rec->qual[1].pathway_type_mean = reply->pathway_type_mean
   SELECT INTO "NL:"
    FROM code_value cv,
     cp_pathway cp
    WHERE (cv.code_value=reply->concept_list[1].concept_cd)
     AND (cp.cp_pathway_id=reply->pathway_id)
    HEAD REPORT
     pw_rec->qual[1].concept_display_key = cv.display_key, pw_rec->qual[1].pathway_diagram_url = cp
     .pathway_diagram_url
    WITH nocounter
   ;end select
   CALL buildnodeexportstructure(null)
   CALL log_message(build("Exit BuildPathwayExportStructure(), Elapsed time in seconds:",((curtime3
      - begin_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE buildnodeexportstructure(null)
   CALL log_message("Begin BuildNodeExportStructure()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE x = i4 WITH noconstant(0), protect
   DECLARE lnode_size = i4 WITH constant(size(reply->node_list,5)), protect
   SET stat = alterlist(pw_rec->qual[1].node_list,lnode_size)
   SET pw_rec->qual[1].node_cnt = lnode_size
   FOR (x = 1 TO lnode_size)
     SET pw_rec->qual[1].node_list[x].node_name = reply->node_list[x].node_name
     SET pw_rec->qual[1].node_list[x].intention_cd = reply->node_list[x].intention_cd
     SET pw_rec->qual[1].node_list[x].intention_mean = reply->node_list[x].intention_cd_meaning
     SET pw_rec->qual[1].node_list[x].category_mean = reply->node_list[x].category_mean
     SET pw_rec->qual[1].node_list[x].sequence = reply->node_list[x].sequence
     CALL buildcomponentexportstructure(x)
     CALL getnodebehaviors(x)
   ENDFOR
   CALL log_message(build("Exit BuildNodeExportStructure(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (buildcomponentexportstructure(nodeidx=i4) =null WITH protect)
   CALL log_message("Begin BuildComponentExportStructure()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE ii = i4 WITH noconstant(0), protect
   DECLARE x = i4 WITH noconstant(0), protect
   DECLARE y = i4 WITH noconstant(0), protect
   DECLARE z = i4 WITH noconstant(0), protect
   DECLARE lcomp_size = i4 WITH constant(size(reply->node_list[nodeidx].component_list,5)), protect
   SET stat = alterlist(pw_rec->qual[1].node_list[nodeidx].comp_list,lcomp_size)
   SET pw_rec->qual[1].node_list[nodeidx].comp_cnt = lcomp_size
   FOR (ii = 1 TO lcomp_size)
     SET curalias comp_reply reply->node_list[nodeidx].component_list[ii]
     SET curalias comp_export pw_rec->qual[1].node_list[nodeidx].comp_list[ii]
     SET comp_export->cp_node_id = reply->node_list[nodeidx].cp_node_id
     SET comp_export->comp_type_cd = comp_reply->comp_type_cd
     SET comp_export->comp_type_mean = comp_reply->comp_type_cd_meaning
     SET comp_export->concept_group_mean = comp_reply->concept_group_cd_meaning
     SET comp_export->component_seq_txt = comp_reply->comp_seq_txt
     CALL buildcomponentdetailexportstructure(nodeidx,ii)
     IF ((((comp_export->comp_type_mean="TREATMENTOPT")) OR ((comp_export->comp_type_mean=
     "GUIDEDTRMNT")))
      AND size(folder_ids_list->qual,5) > 0)
      SET foldersjson = cnvtrectojson(folder_ids_list)
      EXECUTE cp_export_folder_details "MINE", foldersjson
      SET stat = initrec(folder_ids_list)
      FOR (x = 1 TO size(pathway_folders->folder,5))
        SET stat = alterlist(comp_export->folder,x)
        SET comp_export->folder[x].id = pathway_folders->folder[x].id
        SET comp_export->folder[x].short_desc = pathway_folders->folder[x].short_desc
        SET comp_export->folder[x].long_desc = pathway_folders->folder[x].long_desc
        SET comp_export->folder[x].parent_id = pathway_folders->folder[x].parent_id
        FOR (y = 1 TO size(pathway_folders->folder[x].item,5))
          SET stat = alterlist(comp_export->folder[x].item,y)
          SET comp_export->folder[x].item[y].plan_desc = pathway_folders->folder[x].item[y].plan_desc
          SET comp_export->folder[x].item[y].regimen_desc = pathway_folders->folder[x].item[y].
          regimen_desc
          SET comp_export->folder[x].item[y].synonym_id = pathway_folders->folder[x].item[y].
          synonym_id
          SET comp_export->folder[x].item[y].synonym = pathway_folders->folder[x].item[y].synonym
          SET comp_export->folder[x].item[y].key_cap = pathway_folders->folder[x].item[y].key_cap
          SET comp_export->folder[x].item[y].sentence_id = pathway_folders->folder[x].item[y].
          sentence_id
          SET comp_export->folder[x].item[y].display = pathway_folders->folder[x].item[y].display
          SET comp_export->folder[x].item[y].usage_flag = pathway_folders->folder[x].item[y].
          usage_flag
          SET comp_export->folder[x].item[y].orderable_type_flag = pathway_folders->folder[x].item[y]
          .orderable_type_flag
          SET comp_export->folder[x].item[y].format_id = pathway_folders->folder[x].item[y].format_id
          SET comp_export->folder[x].item[y].format_name = pathway_folders->folder[x].item[y].
          format_name
          SET comp_export->folder[x].item[y].parent_entity_name = pathway_folders->folder[x].item[y].
          parent_entity_name
          SET comp_export->folder[x].item[y].parent_entity_id = pathway_folders->folder[x].item[y].
          parent_entity_id
          SET comp_export->folder[x].item[y].parent_entity2_name = pathway_folders->folder[x].item[y]
          .parent_entity2_name
          SET comp_export->folder[x].item[y].parent_entity2_id = pathway_folders->folder[x].item[y].
          parent_entity2_id
          FOR (z = 1 TO size(pathway_folders->folder[x].item[y].details,5))
            SET stat = alterlist(comp_export->folder[x].item[y].details,z)
            SET comp_export->folder[x].item[y].details[z].sequence = pathway_folders->folder[x].item[
            y].details[z].sequence
            SET comp_export->folder[x].item[y].details[z].oe_field_id = pathway_folders->folder[x].
            item[y].details[z].oe_field_id
            SET comp_export->folder[x].item[y].details[z].oe_field_display_value = pathway_folders->
            folder[x].item[y].details[z].oe_field_display_value
            SET comp_export->folder[x].item[y].details[z].oe_field_value = pathway_folders->folder[x]
            .item[y].details[z].oe_field_value
            SET comp_export->folder[x].item[y].details[z].oe_field_meaning_id = pathway_folders->
            folder[x].item[y].details[z].oe_field_meaning_id
            SET comp_export->folder[x].item[y].details[z].field_type_flag = pathway_folders->folder[x
            ].item[y].details[z].field_type_flag
          ENDFOR
        ENDFOR
      ENDFOR
     ENDIF
   ENDFOR
   CALL log_message(build("Exit BuildComponentExportStructure(), Elapsed time in seconds:",((curtime3
      - begin_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (buildcomponentdetailexportstructure(nodeidx=i4,compidx=i4) =null WITH protect)
   CALL log_message("Begin BuildComponentDetailExportStructure()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE x = i4 WITH noconstant(0), protect
   DECLARE sdocsize = i2 WITH noconstant(0), protect
   DECLARE stoppos = i2 WITH noconstant(0), protect
   DECLARE identsize = i2 WITH noconstant(0), protect
   DECLARE lcomp_detail_size = i4 WITH constant(size(reply->node_list[nodeidx].component_list[compidx
     ].comp_detail_list,5)), protect
   DECLARE outbuf = vc WITH protect, noconstant(" ")
   DECLARE totlen = i4 WITH protect, noconstant(0)
   DECLARE datasize = i4 WITH protect, noconstant(0)
   DECLARE foldercnt = i4 WITH protect
   SET stat = alterlist(pw_rec->qual[1].node_list[nodeidx].comp_list[compidx].comp_dtl_list,
    lcomp_detail_size)
   SET pw_rec->qual[1].node_list[nodeidx].comp_list[compidx].comp_dtl_cnt = lcomp_detail_size
   SET curalias comp_detail_reply reply->node_list[nodeidx].component_list[compidx].comp_detail_list[
   x]
   SET curalias comp_detail_export pw_rec->qual[1].node_list[nodeidx].comp_list[compidx].
   comp_dtl_list[x]
   FOR (x = 1 TO lcomp_detail_size)
     SET comp_detail_export->component_entity_name = comp_detail_reply->entity_name
     SET comp_detail_export->component_entity_id = comp_detail_reply->entity_id
     IF ((comp_detail_export->component_entity_name="ALT_SEL_CAT"))
      SET foldercnt += 1
      SET stat = alterlist(folder_ids_list->qual,foldercnt)
      SET folder_ids_list->qual[foldercnt].folder_id = comp_detail_export->component_entity_id
     ENDIF
     SET comp_detail_export->component_ident = comp_detail_reply->entity_ident
     SET comp_detail_export->component_text = comp_detail_reply->entity_text
     SET comp_detail_export->comp_detail_reltn_mean = comp_detail_reply->detail_reltn_cd_mean
     SET comp_detail_export->comp_detail_entity_disp = getentitydisplaybyname(comp_detail_reply->
      entity_name,comp_detail_reply->entity_id,comp_detail_reply->entity_ident)
     SET comp_detail_export->version_nbr = comp_detail_reply->version_nbr
     SET comp_detail_export->version_text = comp_detail_reply->version_text
     SET comp_detail_export->default_ind = comp_detail_reply->default_ind
     SET comp_detail_export->source_flag = comp_detail_reply->source_flag
     SET comp_detail_export->version_flag = comp_detail_reply->version_flag
     IF ((((pw_rec->qual[1].node_list[nodeidx].comp_list[compidx].comp_type_mean="PATHWAY_DOC")) OR (
     (pw_rec->qual[1].node_list[nodeidx].comp_list[compidx].comp_type_mean="GUIDEDTRMNT")))
      AND (comp_detail_export->comp_detail_reltn_mean="DOCCONTENT"))
      SET sdocsize = size(pw_rec->qual[1].structured_content,5)
      SET stoppos = findstring("!",comp_detail_reply->entity_ident,1,1)
      SET identsize = textlen(comp_detail_reply->entity_ident)
      SET stat = alterlist(pw_rec->qual[1].structured_content,(sdocsize+ 1))
      SELECT INTO "nl:"
       bloblen = textlen(lbr.long_blob)
       FROM dd_sref_template dst,
        long_blob_reference lbr
       PLAN (dst
        WHERE dst.cln_ident=substring(1,(stoppos - 1),comp_detail_reply->entity_ident)
         AND dst.version_nbr=cnvtreal(substring((stoppos+ 1),identsize,comp_detail_reply->
          entity_ident)))
        JOIN (lbr
        WHERE lbr.long_blob_id=dst.xml_long_blob_ref_id)
       DETAIL
        datasize = blobgetlen(lbr.long_blob), stat = memrealloc(outbuf,1,build("C",datasize)), totlen
         = blobget(outbuf,0,lbr.long_blob),
        pw_rec->qual[1].structured_content[(sdocsize+ 1)].sdoc_blob = notrim(outbuf)
       WITH nocounter
      ;end select
     ENDIF
   ENDFOR
   CALL log_message(build("Exit BuildComponentDetailExportStructure(), Elapsed time in seconds:",((
     curtime3 - begin_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE buildtriggeringcriteria(null)
   DECLARE is_care_pathway_build_tool = i2 WITH constant(1), protect
   CALL log_message("Begin BuildTriggeringCriteria()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   EXECUTE cp_retr_triggering_criteria "NOFORMS", cppathwayid, is_care_pathway_build_tool
   IF ((triggering_criteria_reply->cnt > 0))
    SET stat = movereclist(triggering_criteria_reply->qual,pw_rec->qual[1].triggering_criteria,1,0,
     triggering_criteria_reply->cnt,
     true)
   ENDIF
   CALL log_message(build("Exit BuildTriggeringCriteria(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (getentitydisplaybyname(entityname=vc,entityid=f8,entityident=vc) =vc WITH protect)
   CALL log_message("In GetEntityDisplayByName()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE val_display = vc WITH protect
   CASE (entityname)
    OF "ALT_SEL_CAT":
     SET val_display = getentitydisplay_altselcat(entityid)
    OF "V500_EVENT_SET_CODE":
     SET val_display = getentitydisplay_eventsetcd(entityid)
    OF "OUTCOME_CATALOG":
     SET val_display = getentitydisplay_outcomecatalog(entityid)
    OF "ORDER_CATALOG":
     SET val_display = getentitydisplay_ordercatalog(entityid)
    OF "BR_DATAMART_FILTER":
     SET val_display = getentitydisplay_datamartfilter(entityid)
    OF "PAT_ED_RELTN":
     SET val_display = getentitydisplay_patedreltn(entityident)
    OF "HM_EXPECT":
     SET val_display = getentitydisplay_hmexpect(entityid)
    OF "MLTM_DRUG_CATEGORIES":
     SET val_display = getentitydisplay_drugcats(entityid)
    OF "CODE_VALUE":
     SET val_display = uar_get_code_display(entityid)
    OF "LONG_TEXT_REFERENCE":
     SET val_display = getentitydisplay_longtextreference(entityid)
    OF "ALT_SEL_CAT":
     SET val_display = getentitydisplay_altselcat(entityid)
    OF "PATHWAY_CATALOG":
     SET val_display = getentitydisplay_pathwaycatalog(entityid)
    OF "REGIMEN_CATALOG":
     SET val_display = getentitydisplay_regimencatalog(entityid)
    OF "ORDER_SENTENCE":
     SET val_display = getentitydisplay_ordersentence(entityid)
    OF "ORDER_CATALOG_SYNONYM":
     SET val_display = getentitydisplay_ordercatalogsynonym(entityid)
    OF "CP_NODE":
     SET val_display = getentitydisplay_cpnode(entityid)
   ENDCASE
   CALL log_message(build("Exit GetEntityDisplayByName(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
   RETURN(val_display)
 END ;Subroutine
 SUBROUTINE writejsontofile(null)
   CALL log_message("Begin WriteJsonToFile()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
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
   SET putrequest->source_filename = build2("Pathway_",trim(cnvtalphanum(pw_rec->qual[1].pathway_name
      ),3),".json")
   SET putrequest->isblob = "1"
   SET putrequest->document = cnvtrectojson(pw_rec)
   SET putrequest->document_size = size(cnvtrectojson(pw_rec))
   EXECUTE eks_put_source  WITH replace("REQUEST",putrequest), replace("REPLY",putreply)
   SET export_reply->current_node_name = curnode
   CALL log_message(build("Exit WriteJsonToFile(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
#exit_script
 IF (validate(debug_ind,0))
  CALL echorecord(pw_rec)
  CALL echorecord(export_reply)
 ENDIF
 IF (( $OUTDEV != "NOFORMS"))
  CALL putjsonrecordtofile(export_reply)
  FREE RECORD export_reply
 ENDIF
 CALL log_message(build("Exit Script ",log_program_name,", Elapsed time in seconds:",((curtime3 -
   begin_curtime3)/ 100.0)),log_level_debug)
END GO
