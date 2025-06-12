CREATE PROGRAM amb_mp_futureorder_cleanup
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "User ID:" = 0.0,
  "Position Cd:" = 0.0,
  "Start Date:" = "",
  "End Date:" = "",
  "Location Code:" = 0.0,
  "Order_provider:" = 0.0,
  "Person Id:" = 0.0,
  "Hide Error Order:" = 0
  WITH outdev, user_id, position_cd,
  start_dt, end_dt, loc_cd,
  order_provider, pid, hideord_ind
 FREE RECORD record_data
 RECORD record_data(
   1 start_check = vc
   1 end_check = vc
   1 orderproviderinfo[*]
     2 order_provider_id = f8
     2 order_provider_name = vc
   1 futureolist[*]
     2 person_id = f8
     2 person_name = vc
     2 gender = vc
     2 mrn = vc
     2 gender_char = vc
     2 dob = vc
     2 age = vc
     2 order_id = f8
     2 ordered_as_name = vc
     2 order_cdl = vc
     2 order_dt_tm = vc
     2 order_start_dt_tm = vc
     2 ordering_provider = vc
     2 ord_comment = vc
     2 order_sort_dt = dq8
     2 order_name = vc
     2 order_status = vc
     2 powerplan_ind = i2
     2 powerplan_name = vc
     2 order_diag = vc
     2 order_catalog_code = vc
     2 order_comment = vc
     2 order_updtcnt = i4
     2 order_comment_type_cd = f8
     2 order_comment_stringfind = i4
     2 order_modifyerror_ind = i2
     2 diag[*]
       3 text = vc
       3 code = vc
       3 voc_text = vc
       3 nomnid = f8
       3 mapind = i2
   1 provlist[*]
     2 order_provider_id = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
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
 DECLARE log_message(logmsg=vc,loglvl=i4) = null
 SUBROUTINE log_message(logmsg,loglvl)
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
 DECLARE error_message(logstatusblockind=i2) = i2
 SUBROUTINE error_message(logstatusblockind)
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
 DECLARE error_and_zero_check_rec(qualnum=i4,opname=vc,logmsg=vc,errorforceexit=i2,zeroforceexit=i2,
  recorddata=vc(ref)) = i2
 SUBROUTINE error_and_zero_check_rec(qualnum,opname,logmsg,errorforceexit,zeroforceexit,recorddata)
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
 DECLARE error_and_zero_check(qualnum=i4,opname=vc,logmsg=vc,errorforceexit=i2,zeroforceexit=i2) = i2
 SUBROUTINE error_and_zero_check(qualnum,opname,logmsg,errorforceexit,zeroforceexit)
   RETURN(error_and_zero_check_rec(qualnum,opname,logmsg,errorforceexit,zeroforceexit,
    reply))
 END ;Subroutine
 DECLARE populate_subeventstatus_rec(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),recorddata=vc(ref)) = i2
 SUBROUTINE populate_subeventstatus_rec(operationname,operationstatus,targetobjectname,
  targetobjectvalue,recorddata)
   IF (validate(recorddata->status_data.status,"-1") != "-1")
    SET lcrslsubeventcnt = size(recorddata->status_data.subeventstatus,5)
    SET lcrslsubeventsize = size(trim(recorddata->status_data.subeventstatus[lcrslsubeventcnt].
      operationname))
    SET lcrslsubeventsize = (lcrslsubeventsize+ size(trim(recorddata->status_data.subeventstatus[
      lcrslsubeventcnt].operationstatus)))
    SET lcrslsubeventsize = (lcrslsubeventsize+ size(trim(recorddata->status_data.subeventstatus[
      lcrslsubeventcnt].targetobjectname)))
    SET lcrslsubeventsize = (lcrslsubeventsize+ size(trim(recorddata->status_data.subeventstatus[
      lcrslsubeventcnt].targetobjectvalue)))
    IF (lcrslsubeventsize > 0)
     SET lcrslsubeventcnt = (lcrslsubeventcnt+ 1)
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
 DECLARE populate_subeventstatus(operationname=vc(value),operationstatus=vc(value),targetobjectname=
  vc(value),targetobjectvalue=vc(value)) = i2
 SUBROUTINE populate_subeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
   CALL populate_subeventstatus_rec(operationname,operationstatus,targetobjectname,targetobjectvalue,
    reply)
 END ;Subroutine
 DECLARE populate_subeventstatus_msg(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),loglevel=i2(value)) = i2
 SUBROUTINE populate_subeventstatus_msg(operationname,operationstatus,targetobjectname,
  targetobjectvalue,loglevel)
  CALL populate_subeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
  CALL log_message(targetobjectvalue,loglevel)
 END ;Subroutine
 DECLARE check_log_level(arg_log_level=i4) = i2
 SUBROUTINE check_log_level(arg_log_level)
   IF (((crsl_msg_level >= arg_log_level) OR (log_override_ind=1)) )
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 DECLARE current_date_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), protect
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
 DECLARE addcodetolist(p1=f8(val),p2=vc(ref)) = null WITH protect
 DECLARE addpersonneltolist(p1=f8(val),p2=vc(ref)) = null WITH protect
 DECLARE addpersonneltolistwithdate(p1=f8(val),p2=vc(ref),p3=f8(val)) = null WITH protect
 DECLARE addphonestolist(p1=f8(val),p2=vc(ref)) = null WITH protect
 DECLARE putjsonrecordtofile(p1=vc(ref)) = null WITH protect
 DECLARE putstringtofile(p1=vc(val)) = null WITH protect
 DECLARE outputcodelist(p1=vc(ref)) = null WITH protect
 DECLARE outputpersonnellist(p1=vc(ref)) = null WITH protect
 DECLARE outputphonelist(p1=vc(ref),p2=vc(ref)) = null WITH protect
 DECLARE getparametervalues(p1=i4(val),p2=vc(ref)) = null WITH protect
 DECLARE getlookbackdatebytype(p1=i4(val),p2=i4(val)) = dq8 WITH protect
 DECLARE getcodevaluesfromcodeset(p1=vc(ref),p2=vc(ref)) = null WITH protect
 DECLARE geteventsetnamesfromeventsetcds(p1=vc(ref),p2=vc(ref)) = null WITH protect
 DECLARE returnviewertype(p1=f8(val),p2=f8(val)) = vc WITH protect
 DECLARE cnvtisodttmtodq8(p1=vc) = dq8 WITH protect
 DECLARE cnvtdq8toisodttm(p1=f8) = vc WITH protect
 DECLARE getorgsecurityflag(null) = i2 WITH protect
 DECLARE getcomporgsecurityflag(p1=vc(val)) = i2 WITH protect
 DECLARE populateauthorizedorganizations(p1=f8(val),p2=vc(ref)) = null WITH protect
 DECLARE getuserlogicaldomain(p1=f8) = f8 WITH protect
 DECLARE getpersonneloverride(ppr_cd=f8(val)) = i2 WITH protect
 DECLARE cclimpersonation(null) = null WITH protect
 SUBROUTINE addcodetolist(code_value,record_data)
   IF (code_value != 0)
    IF (((codelistcnt=0) OR (locateval(code_idx,1,codelistcnt,code_value,record_data->codes[code_idx]
     .code) <= 0)) )
     SET codelistcnt = (codelistcnt+ 1)
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
 SUBROUTINE outputcodelist(record_data)
   CALL log_message("In OutputCodeList() @deprecated",log_level_debug)
 END ;Subroutine
 SUBROUTINE addpersonneltolist(prsnl_id,record_data)
   CALL addpersonneltolistwithdate(prsnl_id,record_data,current_date_time)
 END ;Subroutine
 SUBROUTINE addpersonneltolistwithdate(prsnl_id,record_data,active_date)
   DECLARE personnel_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",213,"PRSNL"))
   IF (((active_date=null) OR (active_date=0.0)) )
    SET active_date = current_date_time
   ENDIF
   IF (prsnl_id != 0)
    IF (((prsnllistcnt=0) OR (locateval(prsnl_idx,1,prsnllistcnt,prsnl_id,record_data->prsnl[
     prsnl_idx].id,
     active_date,record_data->prsnl[prsnl_idx].active_date) <= 0)) )
     SET prsnllistcnt = (prsnllistcnt+ 1)
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
 SUBROUTINE outputpersonnellist(report_data)
   CALL log_message("In OutputPersonnelList()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
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
       idx = (idx+ 1), filteredcnt = (filteredcnt+ 1), report_data->prsnl[idx].id = report_data->
       prsnl[d.seq].id,
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
      cnvtdatetime(curdate,curtime3),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE addphonestolist(prsnl_id,record_data)
   IF (prsnl_id != 0)
    IF (((phonelistcnt=0) OR (locateval(phone_idx,1,phonelistcnt,prsnl_id,record_data->phone_list[
     prsnl_idx].person_id) <= 0)) )
     SET phonelistcnt = (phonelistcnt+ 1)
     IF (phonelistcnt > size(record_data->phone_list,5))
      SET stat = alterlist(record_data->phone_list,(phonelistcnt+ 9))
     ENDIF
     SET record_data->phone_list[phonelistcnt].person_id = prsnl_id
     SET prsnl_cnt = (prsnl_cnt+ 1)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE outputphonelist(report_data,phone_types)
   CALL log_message("In OutputPhoneList()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
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
       AND ph.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND ph.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
       AND ph.active_ind=1
       AND ph.phone_type_seq=1
      ORDER BY ph.parent_entity_id, phone_sorter
     ELSE
      phone_sorter = locateval(idx2,1,size(phone_types->phone_codes,5),ph.phone_type_cd,phone_types->
       phone_codes[idx2].phone_cd)
      FROM phone ph
      WHERE expand(idx,1,personcnt,ph.parent_entity_id,report_data->phone_list[idx].person_id)
       AND ph.parent_entity_name="PERSON"
       AND ph.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND ph.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
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
      phonecnt = (phonecnt+ 1)
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
      cnvtdatetime(curdate,curtime3),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE putstringtofile(svalue)
   CALL log_message("In PutStringToFile()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
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
      cnvtdatetime(curdate,curtime3),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE putjsonrecordtofile(record_data)
   CALL log_message("In PutJSONRecordToFile()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
   CALL putstringtofile(cnvtrectojson(record_data))
   CALL log_message(build("Exit PutJSONRecordToFile(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(curdate,curtime3),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getparametervalues(index,value_rec)
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
     SET value_rec->cnt = (value_rec->cnt+ 1)
     SET stat = alterlist(value_rec->qual,value_rec->cnt)
     SET value_rec->qual[value_rec->cnt].value = param_value
    ENDIF
   ELSEIF (substring(1,1,par)="C")
    SET param_value_str = parameter(index,0)
    IF (trim(param_value_str,3) != "")
     SET value_rec->cnt = (value_rec->cnt+ 1)
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
        SET value_rec->cnt = (value_rec->cnt+ 1)
        SET stat = alterlist(value_rec->qual,value_rec->cnt)
        SET value_rec->qual[value_rec->cnt].value = param_value
       ENDIF
       SET lnum = (lnum+ 1)
      ELSEIF (substring(1,1,par)="C")
       SET param_value_str = parameter(index,lnum)
       IF (trim(param_value_str,3) != "")
        SET value_rec->cnt = (value_rec->cnt+ 1)
        SET stat = alterlist(value_rec->qual,value_rec->cnt)
        SET value_rec->qual[value_rec->cnt].value = trim(param_value_str,3)
       ENDIF
       SET lnum = (lnum+ 1)
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
 SUBROUTINE getlookbackdatebytype(units,flag)
   DECLARE looback_date = dq8 WITH noconstant(cnvtdatetime("01-JAN-1800 00:00:00"))
   IF (units != 0)
    CASE (flag)
     OF 1:
      SET looback_date = cnvtlookbehind(build(units,",H"),cnvtdatetime(curdate,curtime3))
     OF 2:
      SET looback_date = cnvtlookbehind(build(units,",D"),cnvtdatetime(curdate,curtime3))
     OF 3:
      SET looback_date = cnvtlookbehind(build(units,",W"),cnvtdatetime(curdate,curtime3))
     OF 4:
      SET looback_date = cnvtlookbehind(build(units,",M"),cnvtdatetime(curdate,curtime3))
     OF 5:
      SET looback_date = cnvtlookbehind(build(units,",Y"),cnvtdatetime(curdate,curtime3))
    ENDCASE
   ENDIF
   RETURN(looback_date)
 END ;Subroutine
 SUBROUTINE getcodevaluesfromcodeset(evt_set_rec,evt_cd_rec)
  DECLARE csidx = i4 WITH noconstant(0)
  SELECT DISTINCT INTO "nl:"
   FROM v500_event_set_explode vese
   WHERE expand(csidx,1,evt_set_rec->cnt,vese.event_set_cd,evt_set_rec->qual[csidx].value)
   DETAIL
    evt_cd_rec->cnt = (evt_cd_rec->cnt+ 1), stat = alterlist(evt_cd_rec->qual,evt_cd_rec->cnt),
    evt_cd_rec->qual[evt_cd_rec->cnt].value = vese.event_cd
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE geteventsetnamesfromeventsetcds(evt_set_rec,evt_set_name_rec)
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
       cnt = (cnt+ 1), evt_set_name_rec->qual[pos].value = v.event_set_name, pos = locateval(index,(
        pos+ 1),evt_set_rec->cnt,v.event_set_cd,evt_set_rec->qual[index].value)
     ENDWHILE
    FOOT REPORT
     pos = locateval(index,1,evt_set_name_rec->cnt,"",evt_set_name_rec->qual[index].value)
     WHILE (pos > 0)
       evt_set_name_rec->cnt = (evt_set_name_rec->cnt - 1), stat = alterlist(evt_set_name_rec->qual,
        evt_set_name_rec->cnt,(pos - 1)), pos = locateval(index,pos,evt_set_name_rec->cnt,"",
        evt_set_name_rec->qual[index].value)
     ENDWHILE
     evt_set_name_rec->cnt = cnt, stat = alterlist(evt_set_name_rec->qual,evt_set_name_rec->cnt)
    WITH nocounter, expand = value(evaluate(floor(((evt_set_rec->cnt - 1)/ 30)),0,0,1))
   ;end select
 END ;Subroutine
 SUBROUTINE returnviewertype(eventclasscd,eventid)
   CALL log_message("In returnViewerType()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
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
      cnvtdatetime(curdate,curtime3),begin_date_time,5)),log_level_debug)
   RETURN(sviewerflag)
 END ;Subroutine
 SUBROUTINE cnvtisodttmtodq8(isodttmstr)
   DECLARE converteddq8 = dq8 WITH protect, noconstant(0)
   SET converteddq8 = cnvtdatetimeutc2(substring(1,10,isodttmstr),"YYYY-MM-DD",substring(12,8,
     isodttmstr),"HH:MM:SS",4,
    curtimezonedef)
   RETURN(converteddq8)
 END ;Subroutine
 SUBROUTINE cnvtdq8toisodttm(dq8dttm)
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
 SUBROUTINE getcomporgsecurityflag(dminfo_name)
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
 SUBROUTINE populateauthorizedorganizations(personid,value_rec)
   DECLARE organization_cnt = i4 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM prsnl_org_reltn por
    WHERE por.person_id=personid
     AND por.active_ind=1
     AND por.beg_effective_dt_tm BETWEEN cnvtdatetime(lower_bound_date) AND cnvtdatetime(curdate,
     curtime3)
     AND por.end_effective_dt_tm BETWEEN cnvtdatetime(curdate,curtime3) AND cnvtdatetime(
     upper_bound_date)
    ORDER BY por.organization_id
    HEAD REPORT
     organization_cnt = 0
    DETAIL
     organization_cnt = (organization_cnt+ 1)
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
 SUBROUTINE getuserlogicaldomain(id)
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
 SUBROUTINE getpersonneloverride(ppr_cd)
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
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
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
      cnvtdatetime(curdate,curtime3),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SET log_program_name = "AMB_MP_FUTUREORDER_CLEANUP"
 DECLARE gatherorderingprovider(user_id=f8) = null WITH protect, copy
 DECLARE gatherfutureorder(encntrid=f8) = null WITH protect, copy
 DECLARE current_date_time_ftorder = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), protect
 DECLARE future = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"FUTURE"))
 DECLARE nomen_ent_rel_icd = f8 WITH public, constant(uar_get_code_by("MEANING",23549,"ORDERICD9"))
 DECLARE order_comment = f8 WITH public, constant(uar_get_code_by_cki("CKI.CODEVALUE!3944"))
 DECLARE vocabcd = f8 WITH public, constant(uar_get_code_by("MEANING",400,"ICD9"))
 DECLARE mrn_var = f8 WITH constant(uar_get_code_by("MEANING",4,"MRN")), protect
 DECLARE position_bedrock_settings = i2
 DECLARE user_pref_string = vc
 DECLARE user_pref_found = i2
 DECLARE num = i2
 DECLARE oseq = i2
 DECLARE order_pos = i2
 DECLARE start_parser = vc WITH public, noconstant("0")
 DECLARE end_parser = vc WITH public, noconstant("0")
 DECLARE person_id_filter = vc
 DECLARE dtformat = vc WITH public, constant("MM/DD/YYYY")
 DECLARE 222_building = f8 WITH constant(uar_get_code_by("MEANING",222,"BUILDING"))
 DECLARE 222_facility = f8 WITH constant(uar_get_code_by("MEANING",222,"FACILITY"))
 DECLARE diag_display_string = vc WITH protect, noconstant("")
 DECLARE logging = i4 WITH protect, noconstant(0)
 CALL log_message(concat("Begin script: ",log_program_name),log_level_debug)
 SET record_data->status_data.status = "F"
 DECLARE startdate = f8
 DECLARE enddate = f8
 SET startdate = cnvtdatetime(cnvtdate2( $START_DT,"MM/DD/YYYY"),0)
 SET enddate = cnvtdatetime(cnvtdate2( $END_DT,"MM/DD/YYYY"),2359)
 FREE RECORD temp_rec_loccds
 RECORD temp_rec_loccds(
   1 cnt = i4
   1 qual[*]
     2 value = f8
 )
 FREE RECORD loc_cds
 RECORD loc_cds(
   1 location_cds[*]
     2 loc_cds = f8
 )
 CALL getparametervalues(6,temp_rec_loccds)
 IF ((temp_rec_loccds->cnt > 0))
  SET stat = moverec(temp_rec_loccds->qual,loc_cds->location_cds)
 ENDIF
 FREE RECORD temp_rec_providerids
 RECORD temp_rec_providerids(
   1 cnt = i4
   1 qual[*]
     2 value = f8
 )
 FREE RECORD prov_ids
 RECORD prov_ids(
   1 provider_ids[*]
     2 provider_ids = f8
 )
 CALL getparametervalues(7,temp_rec_providerids)
 IF ((temp_rec_providerids->cnt > 0))
  SET stat = moverec(temp_rec_providerids->qual,prov_ids->provider_ids)
 ELSE
  CALL gatherorderingprovider(null)
 ENDIF
 IF (( $PID != 0.0))
  SET person_id_filter = concat("o.person_id = ",cnvtstring( $PID))
 ELSE
  SET person_id_filter = "1=1"
 ENDIF
 CALL gatherfutureorder(null)
 IF (( $HIDEORD_IND=1))
  FOR (x = size(record_data->futureolist,5) TO 1 BY - (1))
    IF ((record_data->futureolist[x].order_modifyerror_ind != 0))
     SET stat = alterlist(record_data->futureolist,(size(record_data->futureolist,5) - 1),(x - 1))
    ENDIF
  ENDFOR
 ENDIF
 SET record_data->status_data.status = "S"
 CALL echorecord(record_data)
 SET modify maxvarlen 20000000
 SET _memory_reply_string = cnvtrectojson(record_data)
 SUBROUTINE gatherorderingprovider(null)
   CALL log_message("In gatherPrsnl()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
   DECLARE dba_check = f8
   SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=88
     AND cdf_meaning="DBA"
    DETAIL
     dba_check = cv.code_value
    WITH nocounter
   ;end select
   DECLARE num2 = i2
   SELECT DISTINCT
    p.person_id, por.organization_id, p.name_full_formatted
    FROM location l,
     prsnl_org_reltn por,
     prsnl p
    PLAN (l
     WHERE expand(num2,1,size(loc_cds->location_cds,5),l.location_cd,loc_cds->location_cds[num2].
      loc_cds))
     JOIN (por
     WHERE por.organization_id=l.organization_id
      AND por.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
      AND por.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
      AND por.active_ind=1)
     JOIN (p
     WHERE p.person_id=por.person_id
      AND  NOT (p.position_cd=dba_check)
      AND p.username > " "
      AND p.active_ind=1
      AND p.physician_ind=1
      AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    ORDER BY p.name_full_formatted, p.person_id
    HEAD REPORT
     pcnt = 0
    HEAD p.person_id
     pcnt = (pcnt+ 1)
     IF (mod(pcnt,100)=1)
      stat = alterlist(prov_ids->provider_ids,(pcnt+ 99))
     ENDIF
     prov_ids->provider_ids[pcnt].provider_ids = p.person_id
    FOOT REPORT
     stat = alterlist(prov_ids->provider_ids,pcnt)
    WITH nocounter, expand = 1
   ;end select
   CALL error_and_zero_check_rec(curqual,"AMB_MP_FUTUREORDER_CLEANUP","gatherOrderingProvider",1,0,
    prov_ids)
   CALL log_message(build("Exit gatherOrderingProvider(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(curdate,curtime3),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE gatherfutureorder(dummy)
   CALL log_message("In GatherFutureOrder()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
   DECLARE provid = i2
   SELECT INTO "nl;"
    diag_string = build(n.source_identifier,"",n.source_string)
    FROM orders o,
     nomen_entity_reltn r,
     nomenclature n,
     person p,
     prsnl pr1,
     person_alias pa,
     order_action oa,
     order_comment oc,
     cmt_cross_map ccm,
     long_text lt
    PLAN (r
     WHERE r.parent_entity_id > 0
      AND r.parent_entity_name="ORDERS"
      AND r.reltn_type_cd=nomen_ent_rel_icd
      AND r.child_entity_name="NOMENCLATURE"
      AND r.active_ind=1
      AND r.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     JOIN (o
     WHERE o.template_order_id=0
      AND o.order_id=r.parent_entity_id
      AND o.order_status_cd=future
      AND o.current_start_dt_tm >= cnvtdatetime(startdate)
      AND o.current_start_dt_tm <= cnvtdatetime(enddate)
      AND o.active_ind=1
      AND parser(person_id_filter)
      AND o.protocol_order_id=0.0)
     JOIN (n
     WHERE n.nomenclature_id=r.child_entity_id
      AND n.source_vocabulary_cd=vocabcd
      AND n.active_ind=1)
     JOIN (ccm
     WHERE ccm.concept_cki=outerjoin(n.concept_cki)
      AND ccm.target_concept_cki=outerjoin("ICD10-CM*")
      AND ccm.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3))
      AND ccm.active_ind=outerjoin(1))
     JOIN (oa
     WHERE oa.order_id=o.order_id
      AND expand(provid,1,size(prov_ids->provider_ids,5),oa.order_provider_id,prov_ids->provider_ids[
      provid].provider_ids)
      AND oa.action_sequence=1)
     JOIN (p
     WHERE p.person_id=outerjoin(o.person_id))
     JOIN (pa
     WHERE pa.person_id=outerjoin(p.person_id)
      AND pa.person_alias_type_cd=outerjoin(mrn_var)
      AND pa.active_ind=outerjoin(1)
      AND pa.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
     JOIN (pr1
     WHERE pr1.person_id=oa.order_provider_id)
     JOIN (oc
     WHERE oc.order_id=outerjoin(o.order_id)
      AND oc.comment_type_cd=outerjoin(order_comment))
     JOIN (lt
     WHERE lt.long_text_id=outerjoin(oc.long_text_id))
    ORDER BY o.current_start_dt_tm, o.order_id, n.nomenclature_id,
     pa.beg_effective_dt_tm DESC, lt.long_text_id DESC
    HEAD REPORT
     ocnt = 0
    HEAD o.order_id
     ocnt = (ocnt+ 1)
     IF (mod(ocnt,100)=1)
      stat = alterlist(record_data->futureolist,(ocnt+ 99))
     ENDIF
     record_data->futureolist[ocnt].person_id = p.person_id, record_data->futureolist[ocnt].mrn =
     trim(pa.alias)
     IF (datetimezoneformat(p.birth_dt_tm,p.birth_tz,"MM/DD/YYYY") != "")
      record_data->futureolist[ocnt].dob = datetimezoneformat(p.birth_dt_tm,p.birth_tz,"MM/DD/YYYY")
     ELSE
      record_data->futureolist[ocnt].dob = "--"
     ENDIF
     IF (uar_get_code_display(p.sex_cd) != "")
      record_data->futureolist[ocnt].gender = uar_get_code_display(p.sex_cd), record_data->
      futureolist[ocnt].gender_char = cnvtupper(substring(1,1,record_data->futureolist[ocnt].gender))
     ELSE
      record_data->futureolist[ocnt].gender = "--", record_data->futureolist[ocnt].gender_char = ""
     ENDIF
     IF (trim(p.name_full_formatted) != "")
      record_data->futureolist[ocnt].person_name = trim(p.name_full_formatted)
     ELSE
      record_data->futureolist[ocnt].person_name = "--"
     ENDIF
     age_str = cnvtlower(trim(substring(1,12,cnvtage(p.birth_dt_tm)),4))
     IF (findstring("days",age_str,0) > 0)
      days = findstring("days",age_str,0), record_data->futureolist[ocnt].age = substring(1,days,
       age_str)
     ELSEIF (findstring("weeks",age_str,0) > 0)
      weeks = findstring("weeks",age_str,0), record_data->futureolist[ocnt].age = substring(1,weeks,
       age_str)
     ELSEIF (findstring("months",age_str,0) > 0)
      months = findstring("months",age_str,0), record_data->futureolist[ocnt].age = substring(1,
       months,age_str)
     ELSEIF (findstring("years",age_str,0) > 0)
      years = findstring("years",age_str,0), record_data->futureolist[ocnt].age = concat(substring(1,
        years,age_str),"rs")
     ENDIF
     record_data->futureolist[ocnt].order_id = o.order_id, record_data->futureolist[ocnt].
     ordered_as_name = trim(o.ordered_as_mnemonic), record_data->futureolist[ocnt].order_cdl = trim(o
      .clinical_display_line),
     record_data->futureolist[ocnt].order_dt_tm = trim(format(cnvtdatetimeutc(o.orig_order_dt_tm,3),
       "YYYY-MM-DDTHH:MM:SSZ;;Q"),3), record_data->futureolist[ocnt].order_start_dt_tm = trim(format(
       cnvtdatetimeutc(o.current_start_dt_tm,3),"YYYY-MM-DDTHH:MM:SSZ;;Q"),3), record_data->
     futureolist[ocnt].ordering_provider = trim(pr1.name_full_formatted),
     record_data->futureolist[ocnt].order_status = trim(uar_get_code_display(o.order_status_cd)),
     record_data->futureolist[ocnt].order_sort_dt = datetimezone(o.current_start_dt_tm,o
      .current_start_tz), record_data->futureolist[ocnt].order_catalog_code = uar_get_code_display(o
      .catalog_type_cd),
     record_data->futureolist[ocnt].order_updtcnt = o.updt_cnt, record_data->futureolist[ocnt].
     order_comment_type_cd = order_comment
     IF (trim(lt.long_text) != "")
      record_data->futureolist[ocnt].order_comment = trim(replace(lt.long_text,concat(char(13),char(
          10)),"; ",0))
     ELSE
      record_data->futureolist[ocnt].order_comment = "--"
     ENDIF
     record_data->futureolist[ocnt].order_comment_stringfind = findstring("ICD10 Update Remediation",
      record_data->futureolist[ocnt].order_comment,1,1)
     IF ((record_data->futureolist[ocnt].order_comment_stringfind != 0))
      record_data->futureolist[ocnt].order_modifyerror_ind = 1
     ELSE
      record_data->futureolist[ocnt].order_modifyerror_ind = 0
     ENDIF
     diag_cnt = 0
    HEAD n.nomenclature_id
     diag_cnt = (diag_cnt+ 1)
     IF (mod(diag_cnt,10)=1)
      stat = alterlist(record_data->futureolist[ocnt].diag,(ocnt+ 9))
     ENDIF
     record_data->futureolist[ocnt].diag[diag_cnt].code = trim(n.source_identifier), record_data->
     futureolist[ocnt].diag[diag_cnt].nomnid = n.nomenclature_id, record_data->futureolist[ocnt].
     diag[diag_cnt].voc_text = uar_get_code_display(n.source_vocabulary_cd),
     record_data->futureolist[ocnt].diag[diag_cnt].text = build(trim(n.source_identifier),"",trim(n
       .source_string))
     IF (ccm.source_vocabulary_cd > 0.0)
      record_data->futureolist[ocnt].diag[diag_cnt].mapind = 0
     ELSE
      record_data->futureolist[ocnt].diag[diag_cnt].mapind = 1
     ENDIF
     IF (diag_cnt > 1)
      diag_display_string = build2(diag_display_string,",",record_data->futureolist[ocnt].diag[
       diag_cnt].text)
     ELSE
      diag_display_string = record_data->futureolist[ocnt].diag[diag_cnt].text
     ENDIF
    FOOT  o.order_id
     record_data->futureolist[ocnt].order_diag = diag_display_string, diag_display_string = ""
     FOR (x = size(record_data->futureolist[ocnt].diag,5) TO 1 BY - (1))
       IF ((record_data->futureolist[ocnt].diag[x].mapind=1))
        ocnt = (ocnt - 1)
       ENDIF
     ENDFOR
     stat = alterlist(record_data->futureolist[ocnt].diag,diag_cnt)
    FOOT REPORT
     stat = alterlist(record_data->futureolist,ocnt)
    WITH nocounter, expand = 1
   ;end select
   CALL error_and_zero_check_rec(curqual,"AMB_MP_FUTUREORDER_CLEANUP","GatherFutureOrder",1,0,
    record_data)
   CALL log_message(build("Exit GatherFutureOrder(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(curdate,curtime3),begin_date_time,5)),log_level_debug)
 END ;Subroutine
#exit_script
 CALL log_message(concat("Exiting script: ",log_program_name),log_level_debug)
 CALL log_message(build("Total time in seconds:",datetimediff(cnvtdatetime(curdate,curtime3),
    current_date_time_ftorder,5)),log_level_debug)
 FREE RECORD record_data
END GO
