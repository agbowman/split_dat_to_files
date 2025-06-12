CREATE PROGRAM cpm_get_orders_flex:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Person ID:" = 0.0,
  "Encounter ID:" = 0.0,
  "Personnel ID:" = 0.0,
  "Concept CD:" = 0.0,
  "Concept Group CD:" = 0.0,
  "Intention CD:" = 0.0,
  "Alt sel cat Ids:" = 0.0,
  "OC Id:" = "",
  "Venue Type: " = 0
  WITH outdev, personid, encntrid,
  prsnlid, conceptcd, conceptgroupcd,
  intentioncd, altselcatids, ocid,
  venuetype
 FREE RECORD altsellist
 RECORD altsellist(
   1 cnt = i4
   1 qual[*]
     2 value = f8
 )
 IF ( NOT (validate(mpagereply)))
  RECORD mpagereply(
    1 person_id = f8
    1 encntr_id = f8
    1 cbt_mean = vc
    1 intention_mean = vc
    1 parent[*]
      2 category_id = f8
      2 description = vc
      2 hide_ind = i2
      2 hide_reason = vc
      2 open_ind = i2
      2 open_reason = vc
      2 recommend_ind = i2
      2 recommend_reason = vc
      2 child[*]
        3 sequence = i4
        3 list_type = i4
        3 category_id = f8
        3 description = vc
        3 synonym_id = f8
        3 synonym = vc
        3 sentence_id = f8
        3 sentence = vc
        3 comment_id = f8
        3 sentence_comment = vc
        3 path_cat_id = f8
        3 path_cat_syn_id = f8
        3 path_cat_syn_name = vc
        3 plan_description = vc
        3 reg_cat_id = f8
        3 reg_cat_syn_id = f8
        3 reg_cat_syn_display = vc
        3 catalog_cd = f8
        3 orderable_type_flag = i4
        3 hide_ind = i2
        3 hide_reason = vc
        3 open_ind = i2
        3 open_reason = vc
        3 recommend_ind = i2
        3 recommend_reason = vc
        3 synonyms[*]
          4 sequence = i4
          4 list_type = i4
          4 synonym_id = f8
          4 synonym = vc
          4 sentence_id = f8
          4 sentence = vc
          4 comment_id = f8
          4 sentence_comment = vc
          4 path_cat_id = f8
          4 path_cat_syn_id = f8
          4 path_cat_syn_name = vc
          4 plan_description = vc
          4 reg_cat_id = f8
          4 reg_cat_syn_id = f8
          4 reg_cat_syn_display = vc
          4 catalog_cd = f8
          4 orderable_type_flag = i4
          4 hide_ind = i2
          4 hide_reason = vc
          4 recommend_ind = i2
          4 recommend_reason = vc
    1 oc_id = vc
    1 venue_type_list[*]
      2 display = vc
      2 default_ind = i2
      2 source_component_list[*]
        3 value = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 FREE RECORD encntr_rec
 RECORD encntr_rec(
   1 facility_cd = f8
   1 encntr_type_cd = f8
   1 order_encntr_group_cd = f8
   1 encntr_venue_type = i2
 )
 FREE RECORD prefinforec
 RECORD prefinforec(
   1 prefinfomask = i4
   1 filterrxordersflag = i2
   1 filterordersflag = i2
   1 allowplanfavs = i2
   1 favssort = i2
   1 futureneworderpref = i2
   1 dischneworderpref = i2
   1 inpat_fav_cnt = i4
   1 inpat_fav[*]
     2 value = f8
   1 rx_fav_cnt = i4
   1 rx_fav[*]
     2 value = f8
   1 hx_fav_cnt = i4
   1 hx_fav[*]
     2 value = f8
   1 home_fav_cnt = i4
   1 home_fav[*]
     2 value = f8
   1 default_venue_val = i2
 )
 FREE RECORD venuetyperec
 RECORD venuetyperec(
   1 venue_type_list[*]
     2 display = vc
     2 default_ind = i2
     2 source_component_list[*]
       3 value = i2
 ) WITH protect
 FREE RECORD altselcatrec
 RECORD altselcatrec(
   1 ccnt = i4
   1 category_ids[*]
     2 category_id = f8
 )
 FREE RECORD alt_sel_req
 RECORD alt_sel_req(
   1 virtual_view_offset = i4
   1 alt_sel_list[*]
     2 alt_sel_category_id = f8
     2 owner_id = f8
     2 long_description_key_cap = vc
   1 order_encntr_group_cd = f8
   1 usage_flag = i2
   1 facility_cd = f8
   1 get_hidden_orders_flag = i2
   1 source_list[*]
     2 source_component_flag = i2
   1 view_plans_ind = i2
   1 view_regimens_ind = i2
   1 apply_facility_on_med_ind = i2
   1 apply_facility_on_nonmed_ind = i2
   1 plan_facility_cd = f8
   1 view_orders_ind = i2
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
 DECLARE getvenuetypelistflex(p1=i2(val),p2=i2(val),p1=vc(ref)) = null WITH protect
 SUBROUTINE (getencntrinfo(encntr_id=f8(val),encntr_rec=vc(ref)) =null WITH protect)
   CALL log_message("In GetEncntrInfo()",log_level_debug)
   DECLARE begin_time = dq8 WITH constant(curtime3), private
   DECLARE cs_order_encntr_group = f8 WITH protect, constant(29100.0)
   DECLARE enc_class_type_validated = i2 WITH protect, constant(validate(encntr_rec->
     encntr_class_type_cd))
   DECLARE encntr_class_type_code = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    FROM encounter e
    WHERE e.encntr_id=encntr_id
    DETAIL
     encntr_rec->encntr_type_cd = e.encntr_type_cd, encntr_rec->facility_cd = e.loc_facility_cd,
     encntr_class_type_code = e.encntr_type_class_cd
    WITH nocounter
   ;end select
   IF (enc_class_type_validated)
    SET encntr_rec->encntr_class_type_cd = encntr_class_type_code
   ENDIF
   SELECT INTO "nl:"
    FROM code_value_group cvg,
     code_value cv,
     code_value_extension cve
    PLAN (cvg
     WHERE (cvg.child_code_value=encntr_rec->encntr_type_cd))
     JOIN (cv
     WHERE cv.code_value=cvg.parent_code_value
      AND cv.code_set=cs_order_encntr_group
      AND cv.active_ind=1)
     JOIN (cve
     WHERE cve.code_value=cv.code_value)
    HEAD REPORT
     encntr_rec->order_encntr_group_cd = cv.code_value, encntr_rec->encntr_venue_type = cnvtint(cve
      .field_value)
    WITH nocounter
   ;end select
   CALL log_message(build("Exit GetEncntrInfo(), Elapsed time in seconds:",((curtime3 - begin_time)/
     100)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (getpowerordersprefs(iselvenuetype=i2(val),iencvenuetype=i2(val),prefinforec=vc(ref)) =
  null WITH protect)
   CALL log_message("In GetPowerOrdersPrefs()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE virt_view_ind = i4 WITH constant(0), protect
   DECLARE fav_folders_ind = i4 WITH constant(1), protect
   DECLARE cust_powerplan_ind = i4 WITH constant(2), protect
   DECLARE fav_sort_ind = i4 WITH constant(3), protect
   DECLARE future_new_ord_ind = i4 WITH constant(4), protect
   DECLARE dsch_new_ord_ind = i4 WITH constant(5), protect
   DECLARE default_venue_ind = i4 WITH constant(6), protect
   DECLARE prefcnt = i4 WITH protect, noconstant(0)
   DECLARE prefmask = i4 WITH protect, noconstant(prefinforec->prefinfomask)
   DECLARE ord_comp_ven_outpat = i2 WITH protect, constant(2)
   DECLARE dpositioncd = f8 WITH protect, noconstant(reqinfo->position_cd)
   DECLARE duserid = f8 WITH protect, noconstant(reqinfo->updt_id)
   DECLARE application_num = i4 WITH protect, constant(reqinfo->updt_app)
   DECLARE brxorderspreffound = i2 WITH protect, noconstant(0)
   DECLARE borderspreffound = i2 WITH protect, noconstant(0)
   DECLARE str = vc WITH protect, noconstant("")
   DECLARE notfnd = vc WITH protect, constant("<not_found>")
   DECLARE num = i4 WITH protect, noconstant(1)
   DECLARE pvc_str = vc WITH protect, noconstant("")
   DECLARE pref_not_configured = i2 WITH protect, constant(0)
   DECLARE pref_allow = i2 WITH protect, constant(1)
   DECLARE pref_reject = i2 WITH protect, constant(2)
   DECLARE pref_warn = i2 WITH protect, constant(3)
   FREE RECORD pvc_name_rec
   RECORD pvc_name_rec(
     1 pvc_cnt = i4
     1 pvc_list[*]
       2 pvc_name = vc
   ) WITH protect
   SET stat = alterlist(pvc_name_rec->pvc_list,10)
   IF (btest(prefmask,virt_view_ind))
    SET prefcnt += 1
    SET pvc_name_rec->pvc_list[prefcnt].pvc_name = "VIRTUAL_ORDER_CATALOG"
    SET prefcnt += 1
    SET pvc_name_rec->pvc_list[prefcnt].pvc_name = "RX_VIRTUAL_ORDER_CATALOG"
   ENDIF
   IF (btest(prefmask,fav_folders_ind))
    SET prefcnt += 1
    IF (iencvenuetype=ord_comp_ven_outpat)
     IF (iselvenuetype=1)
      SET pvc_name_rec->pvc_list[prefcnt].pvc_name = "AMBINOFFICE_CATALOG_BROWSER_HOME"
     ELSE
      SET pvc_name_rec->pvc_list[prefcnt].pvc_name = "AMBUL_CATALOG_BROWSER_HOME"
     ENDIF
     SET prefcnt += 1
     SET pvc_name_rec->pvc_list[prefcnt].pvc_name = "AMBUL_CATALOG_BROWSER_ROOT"
     SET prefcnt += 1
     SET pvc_name_rec->pvc_list[prefcnt].pvc_name = "AMBINOFFICE_CATALOG_BROWSER_ROOT"
    ELSE
     IF (iselvenuetype=1)
      SET pvc_name_rec->pvc_list[prefcnt].pvc_name = "INPT_CATALOG_BROWSER_HOME"
     ELSE
      SET pvc_name_rec->pvc_list[prefcnt].pvc_name = "DSCHMEDS_CATALOG_BROWSER_HOME"
     ENDIF
     SET prefcnt += 1
     SET pvc_name_rec->pvc_list[prefcnt].pvc_name = "INPT_CATALOG_BROWSER_ROOT"
     SET prefcnt += 1
     SET pvc_name_rec->pvc_list[prefcnt].pvc_name = "DSCHMEDS_CATALOG_BROWSER_ROOT"
    ENDIF
   ENDIF
   IF (btest(prefmask,cust_powerplan_ind))
    SET prefcnt += 1
    SET pvc_name_rec->pvc_list[prefcnt].pvc_name = "PLAN_FAVORITES"
   ENDIF
   IF (btest(prefmask,fav_sort_ind))
    SET prefcnt += 1
    SET pvc_name_rec->pvc_list[prefcnt].pvc_name = "FAVORITES_SORT"
   ENDIF
   IF (btest(prefmask,future_new_ord_ind))
    SET prefcnt += 1
    SET pvc_name_rec->pvc_list[prefcnt].pvc_name = "FUTURE_NEW_ORDER"
   ENDIF
   IF (btest(prefmask,dsch_new_ord_ind))
    SET prefcnt += 1
    SET pvc_name_rec->pvc_list[prefcnt].pvc_name = "DSCH_NEW_ORDER"
   ENDIF
   IF (btest(prefmask,default_venue_ind))
    SET prefcnt += 1
    IF (iencvenuetype=ord_comp_ven_outpat)
     SET pvc_name_rec->pvc_list[prefcnt].pvc_name = "DEFAULT_OUTPATIENT_VENUE"
    ELSE
     SET pvc_name_rec->pvc_list[prefcnt].pvc_name = "DEFAULT_INPATIENT_VENUE"
    ENDIF
   ENDIF
   SET stat = alterlist(pvc_name_rec->pvc_list,prefcnt)
   SET pvc_name_rec->pvc_cnt = prefcnt
   SELECT INTO "nl:"
    FROM app_prefs ap,
     name_value_prefs nv
    PLAN (ap
     WHERE ap.prsnl_id IN (0.0, duserid)
      AND ap.position_cd IN (0.0, dpositioncd)
      AND ap.application_number=application_num)
     JOIN (nv
     WHERE nv.parent_entity_id=ap.app_prefs_id
      AND nv.parent_entity_name="APP_PREFS"
      AND expand(num,1,pvc_name_rec->pvc_cnt,nv.pvc_name,pvc_name_rec->pvc_list[num].pvc_name)
      AND nv.active_ind > 0)
    ORDER BY nv.pvc_name, ap.prsnl_id DESC, ap.position_cd DESC
    HEAD nv.pvc_name
     str = "0.0", num = 1
     CASE (trim(cnvtupper(nv.pvc_name)))
      OF "INPT_CATALOG_BROWSER_ROOT":
      OF "AMBINOFFICE_CATALOG_BROWSER_ROOT":
       pvc_str = evaluate(findstring(";",nv.pvc_value),0,build(nv.pvc_value,";"),nv.pvc_value),
       WHILE (str != notfnd)
         str = piece(pvc_str,";",num,notfnd)
         IF (isnumeric(str) > 0)
          prefinforec->inpat_fav_cnt += 1, stat = alterlist(prefinforec->inpat_fav,prefinforec->
           inpat_fav_cnt), prefinforec->inpat_fav[prefinforec->inpat_fav_cnt].value = cnvtreal(str)
         ENDIF
         num += 1
       ENDWHILE
      OF "DSCHMEDS_CATALOG_BROWSER_ROOT":
      OF "AMBUL_CATALOG_BROWSER_ROOT":
       pvc_str = evaluate(findstring(";",nv.pvc_value),0,build(nv.pvc_value,";"),nv.pvc_value),
       WHILE (str != notfnd)
         str = piece(pvc_str,";",num,notfnd)
         IF (isnumeric(str) > 0)
          prefinforec->rx_fav_cnt += 1, stat = alterlist(prefinforec->rx_fav,prefinforec->rx_fav_cnt),
          prefinforec->rx_fav[prefinforec->rx_fav_cnt].value = cnvtreal(str)
         ENDIF
         num += 1
       ENDWHILE
      OF "INPT_CATALOG_BROWSER_HOME":
      OF "DSCHMEDS_CATALOG_BROWSER_HOME":
      OF "AMBINOFFICE_CATALOG_BROWSER_HOME":
      OF "AMBUL_CATALOG_BROWSER_HOME":
       pvc_str = evaluate(findstring(";",nv.pvc_value),0,build(nv.pvc_value,";"),nv.pvc_value),
       WHILE (str != notfnd)
         str = piece(pvc_str,";",num,notfnd)
         IF (isnumeric(str) > 0)
          prefinforec->home_fav_cnt += 1, stat = alterlist(prefinforec->home_fav,prefinforec->
           home_fav_cnt), prefinforec->home_fav[prefinforec->home_fav_cnt].value = cnvtreal(str)
         ENDIF
         num += 1
       ENDWHILE
      OF "RX_VIRTUAL_ORDER_CATALOG":
       IF (brxorderspreffound=0
        AND trim(nv.pvc_value,3)="PTFAC/VORC")
        prefinforec->filterrxordersflag = 1, brxorderspreffound = 1
       ELSEIF (brxorderspreffound=0)
        prefinforec->filterrxordersflag = 0, brxorderspreffound = 1
       ENDIF
      OF "VIRTUAL_ORDER_CATALOG":
       IF (borderspreffound=0
        AND trim(nv.pvc_value,3)="PTFAC/VORC")
        prefinforec->filterordersflag = 1, borderspreffound = 1
       ELSEIF (borderspreffound=0)
        prefinforec->filterordersflag = 0, borderspreffound = 1
       ENDIF
      OF "PLAN_FAVORITES":
       IF (trim(nv.pvc_value,3)="1")
        prefinforec->allowplanfavs = 1
       ENDIF
      OF "FAVORITES_SORT":
       IF (trim(nv.pvc_value,3)="1")
        prefinforec->favssort = 1
       ENDIF
      OF "FUTURE_NEW_ORDER":
       IF (trim(nv.pvc_value,3)="ALLOW")
        prefinforec->futureneworderpref = pref_allow
       ELSEIF (trim(nv.pvc_value,3)="REJECT")
        prefinforec->futureneworderpref = pref_reject
       ELSEIF (trim(nv.pvc_value,3)="WARN")
        prefinforec->futureneworderpref = pref_warn
       ENDIF
      OF "DSCH_NEW_ORDER":
       IF (findstring("ALLOW",nv.pvc_value,1,0)=1)
        prefinforec->dischneworderpref = pref_allow
       ELSEIF (findstring("REJECT",nv.pvc_value,1,0)=1)
        prefinforec->dischneworderpref = pref_reject
       ELSEIF (findstring("WARN",nv.pvc_value,1,0)=1)
        prefinforec->dischneworderpref = pref_warn
       ENDIF
      OF "DEFAULT_OUTPATIENT_VENUE":
      OF "DEFAULT_INPATIENT_VENUE":
       prefinforec->default_venue_val = cnvtreal(nv.pvc_value)
     ENDCASE
    WITH nocounter
   ;end select
   IF (validate(debug_ind)=1)
    CALL echorecord(prefinforec)
   ENDIF
   CALL log_message(build("Exit GetPowerOrdersPrefs(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getvenuetypelistflex(iencvenuetype,bdischneworderpref,venuetyperec,venuepref)
   CALL log_message("In GetVenueTypeListFlex()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE ord_comp_ven_outpat = i2 WITH protect, constant(2)
   DECLARE cs_54732 = i4 WITH constant(54732), protect
   DECLARE cv_54732_ambuloffice = f8 WITH constant(uar_get_code_by("MEANING",cs_54732,"AMBULOFFICE")),
   private
   DECLARE cv_54732_ambulatory = f8 WITH constant(uar_get_code_by("MEANING",cs_54732,"AMBULATORY")),
   private
   DECLARE cv_54732_inpatient = f8 WITH constant(uar_get_code_by("MEANING",cs_54732,"INPATIENT")),
   private
   DECLARE cv_54732_dischargemed = f8 WITH constant(uar_get_code_by("MEANING",cs_54732,"DISCHARGEMED"
     )), private
   DECLARE cv_54732_docmedbyhx = f8 WITH constant(uar_get_code_by("MEANING",cs_54732,"DOCMEDBYHX")),
   private
   DECLARE out_orders_rx = i2 WITH constant(2), private
   DECLARE out_orders_meds = i2 WITH constant(3), private
   DECLARE in_orders_med = i2 WITH constant(1), private
   DECLARE in_discharge_meds_rx = i2 WITH constant(2), private
   DECLARE vtidx = i4 WITH noconstant(0), private
   DECLARE vtidx2 = i4 WITH noconstant(0), private
   DECLARE venuedefault = i4 WITH noconstant(0), private
   IF (iencvenuetype=ord_comp_ven_outpat)
    SET venuedefault = evaluate2(
     IF (venuepref=2) out_orders_rx
     ELSEIF (venuepref=4) out_orders_meds
     ELSE 0
     ENDIF
     )
    IF (bdischneworderpref=2)
     SET stat = alterlist(venuetyperec->venue_type_list,1)
     SET vtidx += 1
     SET venuetyperec->venue_type_list[vtidx].display = uar_get_code_display(cv_54732_ambulatory)
     SET vtidx2 = 1
     SET stat = alterlist(venuetyperec->venue_type_list[vtidx].source_component_list,vtidx2)
     SET venuetyperec->venue_type_list[vtidx].source_component_list[vtidx2].value = 2
     IF ((venuetyperec->venue_type_list[vtidx].source_component_list[vtidx2].value=venuedefault))
      SET venuetyperec->venue_type_list[vtidx].default_ind = 1
     ENDIF
    ELSE
     SET stat = alterlist(venuetyperec->venue_type_list,2)
     SET vtidx += 1
     SET venuetyperec->venue_type_list[vtidx].display = uar_get_code_display(cv_54732_ambuloffice)
     SET vtidx2 = 1
     SET stat = alterlist(venuetyperec->venue_type_list[vtidx].source_component_list,vtidx2)
     SET venuetyperec->venue_type_list[vtidx].source_component_list[vtidx2].value = 3
     IF ((venuetyperec->venue_type_list[vtidx].source_component_list[vtidx2].value=venuedefault))
      SET venuetyperec->venue_type_list[vtidx].default_ind = 1
     ENDIF
     SET vtidx += 1
     SET venuetyperec->venue_type_list[vtidx].display = uar_get_code_display(cv_54732_ambulatory)
     SET vtidx2 = 1
     SET stat = alterlist(venuetyperec->venue_type_list[vtidx].source_component_list,vtidx2)
     SET venuetyperec->venue_type_list[vtidx].source_component_list[vtidx2].value = 2
     IF ((venuetyperec->venue_type_list[vtidx].source_component_list[vtidx2].value=venuedefault))
      SET venuetyperec->venue_type_list[vtidx].default_ind = 1
     ENDIF
    ENDIF
   ELSE
    SET venuedefault = evaluate2(
     IF (venuepref=1) in_orders_med
     ELSEIF (venuepref=8) in_discharge_meds_rx
     ELSE 0
     ENDIF
     )
    IF (bdischneworderpref=2)
     SET stat = alterlist(venuetyperec->venue_type_list,1)
     SET vtidx += 1
     SET venuetyperec->venue_type_list[vtidx].display = uar_get_code_display(cv_54732_dischargemed)
     SET vtidx2 = 1
     SET stat = alterlist(venuetyperec->venue_type_list[vtidx].source_component_list,vtidx2)
     SET venuetyperec->venue_type_list[vtidx].source_component_list[vtidx2].value = 2
     IF ((venuetyperec->venue_type_list[vtidx].source_component_list[vtidx2].value=venuedefault))
      SET venuetyperec->venue_type_list[vtidx].default_ind = 1
     ENDIF
    ELSE
     SET stat = alterlist(venuetyperec->venue_type_list,2)
     SET vtidx += 1
     SET venuetyperec->venue_type_list[vtidx].display = uar_get_code_display(cv_54732_dischargemed)
     SET vtidx2 = 1
     SET stat = alterlist(venuetyperec->venue_type_list[vtidx].source_component_list,vtidx2)
     SET venuetyperec->venue_type_list[vtidx].source_component_list[vtidx2].value = 2
     IF ((venuetyperec->venue_type_list[vtidx].source_component_list[vtidx2].value=venuedefault))
      SET venuetyperec->venue_type_list[vtidx].default_ind = 1
     ENDIF
     SET vtidx += 1
     SET venuetyperec->venue_type_list[vtidx].display = uar_get_code_display(cv_54732_inpatient)
     SET vtidx2 = 1
     SET stat = alterlist(venuetyperec->venue_type_list[vtidx].source_component_list,vtidx2)
     SET venuetyperec->venue_type_list[vtidx].source_component_list[vtidx2].value = 1
     IF ((venuetyperec->venue_type_list[vtidx].source_component_list[vtidx2].value=venuedefault))
      SET venuetyperec->venue_type_list[vtidx].default_ind = 1
     ENDIF
    ENDIF
   ENDIF
   IF (validate(debug_ind)=1)
    CALL echorecord(venuetyperec)
   ENDIF
   CALL log_message(build("Exit GetVenueTypeListFlex(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (retrievefeaturetoggle(togglename=vc) =i2 WITH protect)
   CALL log_message("In RetrieveFeatureToggle()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   FREE RECORD featuretogglerequest
   RECORD featuretogglerequest(
     1 togglename = vc
     1 username = vc
     1 positioncd = f8
     1 systemidentifier = vc
     1 solutionname = vc
   ) WITH protect
   FREE RECORD featuretogglereply
   RECORD featuretogglereply(
     1 togglename = vc
     1 isenabled = i2
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   ) WITH protect
   SET featuretogglerequest->togglename = togglename
   IF (checkprg("SYS_CHECK_FEATURE_TOGGLE") > 0)
    EXECUTE sys_check_feature_toggle  WITH replace("REQUEST",featuretogglerequest), replace("REPLY",
     featuretogglereply)
    IF ((featuretogglereply->status_data.status="S"))
     RETURN(featuretogglereply->isenabled)
    ELSE
     CALL log_message("Failed to get feature toggles",log_level_debug)
    ENDIF
   ELSE
    CALL log_message("Failed to get feature toggles - Feature toggle script unavailable.",
     log_level_debug)
   ENDIF
   RETURN(0)
   CALL log_message(build("Exit RetrieveFeatureToggle(),Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 DECLARE getconceptinfo(null) = null WITH protect
 DECLARE buildfolders(null) = null WITH protect
 DECLARE getfavorders(null) = null WITH protect
 DECLARE processreply(null) = null WITH protect
 DECLARE inputpersonid = f8 WITH protect, constant(cnvtreal( $PERSONID))
 DECLARE inputencntrid = f8 WITH protect, constant(cnvtreal( $ENCNTRID))
 DECLARE inputprsnlid = f8 WITH protect, constant(cnvtreal( $PRSNLID))
 DECLARE inputconceptcd = f8 WITH protect, constant(cnvtreal( $CONCEPTCD))
 DECLARE inputconceptgrpcd = f8 WITH protect, constant(cnvtreal( $CONCEPTGROUPCD))
 DECLARE inputintentioncd = f8 WITH protect, constant(cnvtreal( $INTENTIONCD))
 DECLARE inputocid = vc WITH protect, constant( $OCID)
 DECLARE inputvenuetype = i2 WITH protect, noconstant(cnvtint( $VENUETYPE))
 DECLARE ord_comp_ven_outpat = i2 WITH protect, constant(2)
 DECLARE inpt_venue_type = i2 WITH protect, constant(1)
 DECLARE prescrip_venue_type = i2 WITH protect, constant(2)
 DECLARE pharmacy_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6000,"PHARMACY"))
 DECLARE administration_ind = i2 WITH protect, noconstant(0)
 DECLARE prescriptionind = i2 WITH protect, noconstant(0)
 DECLARE ambinofficeflag = i2 WITH protect, noconstant(0)
 DECLARE ambmedsrxflag = i2 WITH protect, noconstant(0)
 DECLARE ruleind = i2 WITH protect, noconstant(0)
 DECLARE rulename = vc WITH protect, noconstant("")
 DECLARE cp_concept = vc WITH protect, noconstant("")
 DECLARE cp_intention = vc WITH protect, noconstant("")
 CALL getparametervalues(8,altsellist)
 IF (validate(debug_ind,0)=1)
  CALL echorecord(altsellist)
 ENDIF
 CALL getconceptinfo(null)
 FREE RECORD mpagerequest
 IF (ruleind=1)
  RECORD mpagerequest(
    1 person_id = f8
    1 encntr_id = f8
    1 cbt_mean = vc
    1 intention_mean = vc
    1 parent[*]
      2 category_id = f8
      2 description = vc
      2 hide_ind = i2
      2 hide_reason = vc
      2 open_ind = i2
      2 open_reason = vc
      2 recommend_ind = i2
      2 recommend_reason = vc
      2 child[*]
        3 sequence = i4
        3 list_type = i4
        3 category_id = f8
        3 description = vc
        3 synonym_id = f8
        3 synonym = vc
        3 sentence_id = f8
        3 sentence = vc
        3 comment_id = f8
        3 sentence_comment = vc
        3 path_cat_id = f8
        3 path_cat_syn_id = f8
        3 path_cat_syn_name = vc
        3 plan_description = vc
        3 reg_cat_id = f8
        3 reg_cat_syn_id = f8
        3 reg_cat_syn_display = vc
        3 catalog_cd = f8
        3 orderable_type_flag = i4
        3 hide_ind = i2
        3 hide_reason = vc
        3 open_ind = i2
        3 open_reason = vc
        3 recommend_ind = i2
        3 recommend_reason = vc
        3 synonyms[*]
          4 sequence = i4
          4 list_type = i4
          4 synonym_id = f8
          4 synonym = vc
          4 sentence_id = f8
          4 sentence = vc
          4 comment_id = f8
          4 sentence_comment = vc
          4 path_cat_id = f8
          4 path_cat_syn_id = f8
          4 path_cat_syn_name = vc
          4 plan_description = vc
          4 reg_cat_id = f8
          4 reg_cat_syn_id = f8
          4 reg_cat_syn_display = vc
          4 catalog_cd = f8
          4 orderable_type_flag = i4
          4 hide_ind = i2
          4 hide_reason = vc
          4 recommend_ind = i2
          4 recommend_reason = vc
    1 oc_id = vc
    1 venue_type_list[*]
      2 display = vc
      2 default_ind = i2
      2 source_component_list[*]
        3 value = i2
  ) WITH protect
 ELSE
  RECORD mpagerequest(
    1 person_id = f8
    1 encntr_id = f8
    1 cbt_mean = vc
    1 intention_mean = vc
    1 parent[*]
      2 category_id = f8
      2 description = vc
      2 hide_ind = i2
      2 hide_reason = vc
      2 open_ind = i2
      2 open_reason = vc
      2 recommend_ind = i2
      2 recommend_reason = vc
      2 child[*]
        3 sequence = i4
        3 list_type = i4
        3 category_id = f8
        3 description = vc
        3 synonym_id = f8
        3 synonym = vc
        3 sentence_id = f8
        3 sentence = vc
        3 comment_id = f8
        3 sentence_comment = vc
        3 path_cat_id = f8
        3 path_cat_syn_id = f8
        3 path_cat_syn_name = vc
        3 plan_description = vc
        3 reg_cat_id = f8
        3 reg_cat_syn_id = f8
        3 reg_cat_syn_display = vc
        3 catalog_cd = f8
        3 orderable_type_flag = i4
        3 hide_ind = i2
        3 hide_reason = vc
        3 open_ind = i2
        3 open_reason = vc
        3 recommend_ind = i2
        3 recommend_reason = vc
        3 synonyms[*]
          4 sequence = i4
          4 list_type = i4
          4 synonym_id = f8
          4 synonym = vc
          4 sentence_id = f8
          4 sentence = vc
          4 comment_id = f8
          4 sentence_comment = vc
          4 path_cat_id = f8
          4 path_cat_syn_id = f8
          4 path_cat_syn_name = vc
          4 plan_description = vc
          4 reg_cat_id = f8
          4 reg_cat_syn_id = f8
          4 reg_cat_syn_display = vc
          4 catalog_cd = f8
          4 orderable_type_flag = i4
          4 hide_ind = i2
          4 hide_reason = vc
          4 recommend_ind = i2
          4 recommend_reason = vc
    1 oc_id = vc
    1 venue_type_list[*]
      2 display = vc
      2 default_ind = i2
      2 source_component_list[*]
        3 value = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 SET mpagerequest->person_id = inputpersonid
 SET mpagerequest->encntr_id = inputencntrid
 SET mpagerequest->cbt_mean = cp_concept
 SET mpagerequest->intention_mean = cp_intention
 SET mpagerequest->oc_id = inputocid
 SET mpagereply->status_data.status = "F"
 CALL getencntrinfo(inputencntrid,encntr_rec)
 IF (inputvenuetype=0)
  SET prefinforec->prefinfomask = 97
 ELSE
  SET prefinforec->prefinfomask = 33
 ENDIF
 CALL getpowerordersprefs(inputvenuetype,encntr_rec->encntr_venue_type,prefinforec)
 CALL getvenuetypelistflex(encntr_rec->encntr_venue_type,prefinforec->dischneworderpref,mpagerequest,
  prefinforec->default_venue_val)
 IF (inputvenuetype=0)
  SET inputvenuetype = translatevenuedefault(prefinforec->default_venue_val)
 ENDIF
 CALL buildfolders(null)
 CALL getfavorders(null)
 CALL processreply(null)
 IF (ruleind=1)
  CALL executerule(rulename)
 ELSE
  SET stat = moverec(mpagerequest,mpagereply)
 ENDIF
 SET mpagereply->status_data.status = "S"
 IF (validate(debug_ind,0)=1)
  CALL echorecord(mpagereply)
 ENDIF
 SUBROUTINE getconceptinfo(null)
  SELECT INTO "nl:"
   FROM cp_concept_group cp
   PLAN (cp
    WHERE cp.concept_cd=inputconceptcd
     AND cp.concept_group_cd=inputconceptgrpcd
     AND cp.intention_cd=inputintentioncd)
   DETAIL
    cp_concept = cnvtupper(trim(uar_get_code_meaning(cp.concept_cd))), cp_group = cnvtupper(trim(
      uar_get_code_meaning(cp.concept_group_cd))), cp_intention = uar_get_code_meaning(cp
     .intention_cd),
    rulename = concat(trim(cp_concept),"_",trim(cp_group),"_",trim(cp_intention)), ruleind = cp
    .rule_ind
   WITH nocounter
  ;end select
  IF (validate(debug_ind,0)=1)
   CALL echo(build("RuleInd:",ruleind))
   CALL echo(build("RuleName:",rulename))
  ENDIF
 END ;Subroutine
 SUBROUTINE (executerule(null=vc) =null WITH protect)
   CALL log_message("In executeRule()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE eks_app_num = i4 WITH constant(3072000), protect
   DECLARE eks_task_num = i4 WITH constant(3072000), protect
   DECLARE eks_cbt_flex_req = i4 WITH constant(3072100), protect
   SET stat = tdbexecute(eks_app_num,eks_task_num,eks_cbt_flex_req,"REC",mpagerequest,
    "REC",mpagereply,1)
   IF (validate(debug_ind,0)=1)
    CALL echo("MPageReply after rule:")
    CALL echorecord(mpagereply)
   ENDIF
   CALL log_message(build("Exit executeRule(), Elapsed time in seconds:",((curtime3 - begin_curtime3)
     / 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE buildfolders(null)
   CALL log_message("In buildFolders()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE catcnt = i4 WITH noconstant(0), protect
   DECLARE idx = i4 WITH noconstant(0), protect
   DECLARE parentfoldercnt = i4 WITH noconstant(0), protect
   SET stat = alterlist(altselcatrec->category_ids,altsellist->cnt)
   SELECT INTO "nl:"
    FROM alt_sel_cat c,
     alt_sel_list l
    PLAN (c
     WHERE expand(idx,1,altsellist->cnt,c.alt_sel_category_id,altsellist->qual[idx].value))
     JOIN (l
     WHERE (l.alt_sel_category_id= Outerjoin(c.alt_sel_category_id)) )
    ORDER BY c.alt_sel_category_id, l.sequence
    HEAD c.alt_sel_category_id
     parentfoldercnt += 1, catcnt += 1, stat = alterlist(mpagerequest->parent,parentfoldercnt),
     stat = alterlist(altselcatrec->category_ids,catcnt), mpagerequest->parent[parentfoldercnt].
     category_id = c.alt_sel_category_id, altselcatrec->category_ids[catcnt].category_id = c
     .alt_sel_category_id,
     mpagerequest->parent[parentfoldercnt].description = c.short_description
    WITH expand = 1, nocounter
   ;end select
   SET altselcatrec->ccnt = catcnt
   IF (validate(debug_ind,0)=1)
    CALL echorecord(altselcatrec)
    CALL echorecord(mpagerequest)
   ENDIF
   CALL log_message(build("Exit buildFolders(), Elapsed time in seconds:",((curtime3 - begin_curtime3
     )/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getfavorders(dummy)
   CALL log_message("In getFavOrders()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE root_fav = vc WITH constant("FAVORITES"), private
   DECLARE favsize = i4 WITH noconstant(0), private
   DECLARE childsize = i4 WITH noconstant(0), private
   DECLARE x = i4 WITH noconstant(0), private
   DECLARE y = i4 WITH noconstant(0), private
   SET stat = initrec(alt_sel_req)
   IF ((altselcatrec->ccnt > 0))
    SET stat = alterlist(alt_sel_req->alt_sel_list,altselcatrec->ccnt)
    FOR (x = 1 TO altselcatrec->ccnt)
      SET alt_sel_req->alt_sel_list[x].alt_sel_category_id = altselcatrec->category_ids[x].
      category_id
    ENDFOR
   ENDIF
   SET stat = alterlist(alt_sel_req->source_list,1)
   SET alt_sel_req->source_list[1].source_component_flag = 0
   IF (inputvenuetype=inpt_venue_type)
    SET alt_sel_req->usage_flag = 1
    IF ((encntr_rec->encntr_venue_type=ord_comp_ven_outpat))
     SET ambinofficeflag = 1
    ELSE
     SET administration_ind = 1
    ENDIF
   ELSE
    SET prescriptionind = 1
    SET alt_sel_req->usage_flag = 2
    IF ((encntr_rec->encntr_venue_type=ord_comp_ven_outpat))
     SET ambmedsrxflag = 1
     SET alt_sel_req->usage_flag = 0
    ENDIF
   ENDIF
   IF (((administration_ind) OR (ambinofficeflag))
    AND (prefinforec->filterordersflag=1))
    SET alt_sel_req->apply_facility_on_nonmed_ind = 1
    SET alt_sel_req->apply_facility_on_med_ind = 1
   ELSEIF (prescriptionind)
    IF ((prefinforec->filterrxordersflag=1))
     SET alt_sel_req->apply_facility_on_med_ind = 1
    ENDIF
    IF ((prefinforec->filterordersflag=1)
     AND (encntr_rec->encntr_venue_type=2))
     SET alt_sel_req->apply_facility_on_nonmed_ind = 1
    ENDIF
   ENDIF
   SET alt_sel_req->order_encntr_group_cd = encntr_rec->order_encntr_group_cd
   SET alt_sel_req->facility_cd = encntr_rec->facility_cd
   SET alt_sel_req->view_plans_ind = 1
   SET alt_sel_req->view_regimens_ind = 1
   SET alt_sel_req->view_orders_ind = 1
   SET alt_sel_req->plan_facility_cd = encntr_rec->facility_cd
   IF (validate(debug_ind,0)=1)
    CALL echorecord(alt_sel_req)
   ENDIF
   EXECUTE mp_get_alt_sel  WITH replace("REQUEST","ALT_SEL_REQ")
   IF ((reply->status_data.status="F"))
    CALL handleerror(reply->status_data.subeventstatus[1].operationname,reply->status_data.
     subeventstatus[1].operationstatus,reply->status_data.subeventstatus[1].operationtargetobjectname,
     reply->status_data.subeventstatus[1].operationtargetobjectvalue,report_data)
   ELSE
    SET favsize = size(reply->get_list,5)
    CALL error_and_zero_check_rec(favsize,log_program_name,"GetFavOrders",1,0,
     mpagereply)
   ENDIF
   CALL log_message(build("Exit getFavOrders(), Elapsed time in seconds:",((curtime3 - begin_curtime3
     )/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE processreply(null)
   CALL log_message("In processReply()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE ccnt = i4 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = size(mpagerequest->parent,5)),
     (dummyt d2  WITH seq = size(reply->get_list,5)),
     (dummyt d3  WITH seq = 1)
    PLAN (d1)
     JOIN (d2
     WHERE (reply->get_list[d2.seq].alt_sel_category_id=mpagerequest->parent[d1.seq].category_id)
      AND maxrec(d3,size(reply->get_list[d2.seq].child_list,5)))
     JOIN (d3
     WHERE (reply->get_list[d2.seq].child_list[d3.seq].list_type IN (2, 6, 7)))
    ORDER BY d1.seq, d2.seq, d3.seq
    HEAD d1.seq
     ccnt = size(mpagerequest->parent[d1.seq].child,5)
    HEAD d3.seq
     IF (filterdischargerx(d2.seq,d3.seq))
      ccnt += 1, stat = alterlist(mpagerequest->parent[d1.seq].child,ccnt), mpagerequest->parent[d1
      .seq].child[ccnt].sequence = reply->get_list[d2.seq].child_list[d3.seq].sequence,
      mpagerequest->parent[d1.seq].child[ccnt].list_type = reply->get_list[d2.seq].child_list[d3.seq]
      .list_type, mpagerequest->parent[d1.seq].child[ccnt].category_id = reply->get_list[d2.seq].
      child_list[d3.seq].child_alt_sel_cat_id, mpagerequest->parent[d1.seq].child[ccnt].description
       = reply->get_list[d2.seq].child_list[d3.seq].mnemonic,
      mpagerequest->parent[d1.seq].child[ccnt].synonym_id = reply->get_list[d2.seq].child_list[d3.seq
      ].synonym_id, mpagerequest->parent[d1.seq].child[ccnt].synonym = reply->get_list[d2.seq].
      child_list[d3.seq].mnemonic, mpagerequest->parent[d1.seq].child[ccnt].sentence_id = reply->
      get_list[d2.seq].child_list[d3.seq].order_sentence_id,
      mpagerequest->parent[d1.seq].child[ccnt].sentence = reply->get_list[d2.seq].child_list[d3.seq].
      order_sentence_disp_line, mpagerequest->parent[d1.seq].child[ccnt].path_cat_id = reply->
      get_list[d2.seq].child_list[d3.seq].pathway_catalog_id, mpagerequest->parent[d1.seq].child[ccnt
      ].path_cat_syn_id = reply->get_list[d2.seq].child_list[d3.seq].pw_cat_synonym_id,
      mpagerequest->parent[d1.seq].child[ccnt].path_cat_syn_name = reply->get_list[d2.seq].
      child_list[d3.seq].pw_synonym_name, mpagerequest->parent[d1.seq].child[ccnt].plan_description
       = reply->get_list[d2.seq].child_list[d3.seq].plan_display_description, mpagerequest->parent[d1
      .seq].child[ccnt].catalog_cd = reply->get_list[d2.seq].child_list[d3.seq].catalog_cd,
      mpagerequest->parent[d1.seq].child[ccnt].orderable_type_flag = reply->get_list[d2.seq].
      child_list[d3.seq].orderable_type_flag, mpagerequest->parent[d1.seq].child[ccnt].reg_cat_id =
      reply->get_list[d2.seq].child_list[d3.seq].regimen_catalog_id, mpagerequest->parent[d1.seq].
      child[ccnt].reg_cat_syn_display = reply->get_list[d2.seq].child_list[d3.seq].regimen_synonym,
      mpagerequest->parent[d1.seq].child[ccnt].reg_cat_syn_id = reply->get_list[d2.seq].child_list[d3
      .seq].regimen_catalog_synonym_id
     ENDIF
    WITH nocounter
   ;end select
   IF (validate(debug_ind,0)=1)
    CALL echo("After populating parent folder synonyms")
    CALL echorecord(mpagerequest)
   ENDIF
   SET ccnt = 0
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = size(mpagerequest->parent,5)),
     (dummyt d2  WITH seq = 1),
     (dummyt d3  WITH seq = size(reply->get_list,5)),
     (dummyt d4  WITH seq = 1)
    PLAN (d1
     WHERE maxrec(d2,size(mpagerequest->parent[d1.seq].child,5)))
     JOIN (d2
     WHERE (mpagerequest->parent[d1.seq].child[d2.seq].category_id > 0))
     JOIN (d3
     WHERE (reply->get_list[d3.seq].alt_sel_category_id=mpagerequest->parent[d1.seq].child[d2.seq].
     category_id)
      AND maxrec(d4,size(reply->get_list[d3.seq].child_list,5)))
     JOIN (d4
     WHERE (reply->get_list[d3.seq].child_list[d4.seq].list_type IN (2, 6, 7)))
    ORDER BY d1.seq, d2.seq, d3.seq,
     d4.seq
    HEAD d2.seq
     ccnt = 0
    HEAD d4.seq
     IF (filterdischargerx(d2.seq,d3.seq))
      ccnt += 1, stat = alterlist(mpagerequest->parent[d1.seq].child[d2.seq].synonyms,ccnt),
      mpagerequest->parent[d1.seq].child[d2.seq].synonyms[ccnt].sequence = reply->get_list[d3.seq].
      child_list[d4.seq].sequence,
      mpagerequest->parent[d1.seq].child[d2.seq].synonyms[ccnt].list_type = reply->get_list[d3.seq].
      child_list[d4.seq].list_type, mpagerequest->parent[d1.seq].child[d2.seq].synonyms[ccnt].
      synonym_id = reply->get_list[d3.seq].child_list[d4.seq].synonym_id, mpagerequest->parent[d1.seq
      ].child[d2.seq].synonyms[ccnt].synonym = reply->get_list[d3.seq].child_list[d4.seq].mnemonic,
      mpagerequest->parent[d1.seq].child[d2.seq].synonyms[ccnt].sentence_id = reply->get_list[d3.seq]
      .child_list[d4.seq].order_sentence_id, mpagerequest->parent[d1.seq].child[d2.seq].synonyms[ccnt
      ].sentence = reply->get_list[d3.seq].child_list[d4.seq].order_sentence_disp_line, mpagerequest
      ->parent[d1.seq].child[d2.seq].synonyms[ccnt].path_cat_id = reply->get_list[d3.seq].child_list[
      d4.seq].pathway_catalog_id,
      mpagerequest->parent[d1.seq].child[d2.seq].synonyms[ccnt].path_cat_syn_id = reply->get_list[d3
      .seq].child_list[d4.seq].pw_cat_synonym_id, mpagerequest->parent[d1.seq].child[d2.seq].
      synonyms[ccnt].path_cat_syn_name = reply->get_list[d3.seq].child_list[d4.seq].pw_synonym_name,
      mpagerequest->parent[d1.seq].child[d2.seq].synonyms[ccnt].plan_description = reply->get_list[d3
      .seq].child_list[d4.seq].plan_display_description,
      mpagerequest->parent[d1.seq].child[d2.seq].synonyms[ccnt].catalog_cd = reply->get_list[d3.seq].
      child_list[d4.seq].catalog_cd, mpagerequest->parent[d1.seq].child[d2.seq].synonyms[ccnt].
      orderable_type_flag = reply->get_list[d3.seq].child_list[d4.seq].orderable_type_flag,
      mpagerequest->parent[d1.seq].child[d2.seq].synonyms[ccnt].reg_cat_id = reply->get_list[d3.seq].
      child_list[d4.seq].regimen_catalog_id,
      mpagerequest->parent[d1.seq].child[d2.seq].synonyms[ccnt].reg_cat_syn_display = reply->
      get_list[d3.seq].child_list[d4.seq].regimen_synonym, mpagerequest->parent[d1.seq].child[d2.seq]
      .synonyms[ccnt].reg_cat_syn_id = reply->get_list[d3.seq].child_list[d4.seq].
      regimen_catalog_synonym_id
     ENDIF
    WITH nocounter
   ;end select
   IF (validate(debug_ind,0)=1)
    CALL echo("After populating child folder synonyms")
    CALL echorecord(mpagerequest)
   ENDIF
   CALL log_message(build("Exit processReply(), Elapsed time in seconds:",((curtime3 - begin_curtime3
     )/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE filterdischargerx(listindex,childlistindex)
   CALL log_message("In FilterDischargeRx()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE careset_order_type = i4 WITH protect, constant(6)
   DECLARE dischargerxflag = i2 WITH protect, noconstant(0)
   IF (((ambmedsrxflag=1) OR ((((reply->get_list[listindex].child_list[childlistindex].list_type=1))
    OR (((prescriptionind=0) OR ((reply->get_list[listindex].child_list[childlistindex].
   catalog_type_cd=pharmacy_cd)
    AND (reply->get_list[listindex].child_list[childlistindex].orderable_type_flag !=
   careset_order_type)
    AND (reply->get_list[listindex].child_list[childlistindex].pw_cat_synonym_id=0.0))) )) )) )
    SET dischargerxflag = 1
   ENDIF
   CALL log_message(build("Exit FilterDischargeRx(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
   RETURN(dischargerxflag)
 END ;Subroutine
 SUBROUTINE translatevenuedefault(venuevalue)
   DECLARE ambulatory_in_office = i2 WITH constant(4), private
   DECLARE inpatient = i2 WITH constant(1), private
   IF (((venuevalue=inpatient) OR (venuevalue=ambulatory_in_office)) )
    RETURN(1)
   ELSE
    RETURN(2)
   ENDIF
 END ;Subroutine
#exit_script
 IF (( $OUTDEV != "NOFORMS"))
  CALL putjsonrecordtofile(mpagereply)
  FREE RECORD altsellist
  FREE RECORD mpagereply
  FREE RECORD encntr_rec
  FREE RECORD prefinforec
  FREE RECORD venuetyperec
  FREE RECORD altselcatrec
  FREE RECORD alt_sel_req
  FREE RECORD mpagerequest
 ENDIF
END GO
