CREATE PROGRAM dcp_ops_ceprsnl_expire_drv:dba
 IF (validate(request->debug_ind,0) != 1)
  EXECUTE cclseclogin
 ENDIF
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
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 IF ( NOT (validate(reply,0)))
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
 RECORD req_get_ex_rules(
   1 prsnl_id = f8
 )
 RECORD rep_get_ex_rules(
   1 expire_rule[*]
     2 expire_rule_id = f8
     2 rule_name = vc
     2 prsnl_id = f8
     2 rule_dt_tm = dq8
     2 active_ind = i2
     2 authentic_flag_ind = i2
     2 rule_definition[*]
       3 rule_definition_id = f8
       3 parent_entity_id = f8
       3 parent_entity_name = vc
       3 rule_type_cd = f8
       3 param_name = vc
       3 param_value = vc
       3 merge_name = vc
       3 merge_id = f8
       3 location_cd = f8
       3 loc_facility_cd = f8
       3 seq_num = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD req_get_ceprsnl_to_ex(
   1 max_rec = f8
   1 start_ce_event_prsnl = f8
   1 expire_rule[*]
     2 rule_id = f8
     2 rule_definition[*]
       3 rule_definition_id = f8
       3 parent_entity_id = f8
       3 parent_entity_name = c30
       3 rule_type_cd = f8
       3 param_name = vc
       3 param_value = vc
       3 merge_name = vc
       3 merge_value = f8
       3 loc_facility_cd = f8
       3 seq_num = i4
       3 collation_seq = i4
 )
 RECORD rep_get_ceprsnl_to_ex(
   1 super_select = vc
   1 event_prsnl_list[*]
     2 event_id = f8
     2 encntr_id = f8
     2 person_id = f8
     2 event_prsnl_id = f8
     2 action_type_cd = f8
     2 action_status_cd = f8
     2 action_prsnl_id = f8
     2 req_dt_tm = dq8
     2 med_rec_num = vc
     2 financial_num = vc
     2 discharge_dt_tm = dq8
     2 encounter_type_cd = f8
     2 organization_id = f8
     2 org_name = vc
     2 facility_cd = f8
     2 event_cd = f8
     2 event_cd_disp = c40
     2 ce_event_prsnl_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD req_expire_audit(
   1 expire_rule[*]
     2 rule_id = f8
     2 rule_parameter = vc
     2 run_prsnl_id = f8
     2 run_type = i2
     2 rows_updated = i4
     2 run_dt_tm = dq8
 )
 RECORD rep_expire_audit(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD req_expire_rpt(
   1 rule_parameter = vc
   1 run_type_flag = i2
   1 run_prsnl_name_full = vc
   1 batch_selection = vc
   1 output_dist = vc
   1 event_prsnl_list[*]
     2 person_id = f8
     2 ce_event_prsnl_id = f8
     2 action_type_cd = f8
     2 action_status_cd = f8
     2 action_prsnl_id = f8
     2 req_dt_tm = dq8
     2 med_rec_num_str = vc
     2 financial_num_str = vc
     2 discharge_dt_tm = dq8
     2 encounter_type_cd = f8
     2 organization_id = f8
     2 facility_cd = f8
     2 location_cd = f8
     2 event_cd = f8
     2 event_cd_disp = c40
 )
 RECORD rep_expire_rpt(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD int_captions(
   1 ids_expire = vc
   1 ids_action = vc
   1 ids_for = vc
   1 ids_name_not_found = vc
   1 ids_age_of_req = vc
   1 ids_or = vc
   1 ids_doc_type = vc
   1 ids_encntrtype = vc
   1 ids_encntrstatus = vc
   1 ids_discharge = vc
   1 ids_org = vc
   1 ids_facility = vc
   1 ids_days = vc
 ) WITH protect
 SET int_captions->ids_expire = trim(uar_i18ngetmessage(i18nhandle,"IDS_EXPIRE","Expire "))
 SET int_captions->ids_action = trim(uar_i18ngetmessage(i18nhandle,"IDS_ACTION",
   "requested or pending"))
 SET int_captions->ids_for = trim(uar_i18ngetmessage(i18nhandle,"IDS_FOR"," for "))
 SET int_captions->ids_name_not_found = trim(uar_i18ngetmessage(i18nhandle,"IDS_NAME_NOT_FOUND",
   "PERSONAL NAME NOT FOUND"))
 SET int_captions->ids_age_of_req = trim(uar_i18ngetmessage(i18nhandle,"IDS_AGE_OF_REQ",
   "that are older than"))
 SET int_captions->ids_or = trim(uar_i18ngetmessage(i18nhandle,"IDS_OR","or"))
 SET int_captions->ids_doc_type = trim(uar_i18ngetmessage(i18nhandle,"IDS_DOC_TYPE",
   "and of document type"))
 SET int_captions->ids_encntrtype = trim(uar_i18ngetmessage(i18nhandle,"IDS_ENCNTRTYPE",
   "and for persons who are"))
 SET int_captions->ids_encntrstatus = trim(uar_i18ngetmessage(i18nhandle,"IDS_ENCNTRSTATUS",
   "and persons who are"))
 SET int_captions->ids_discharge = trim(uar_i18ngetmessage(i18nhandle,"IDS_DISCHARGE",
   "and days since discharge is"))
 SET int_captions->ids_org = trim(uar_i18ngetmessage(i18nhandle,"IDS_ORG","and from organization"))
 SET int_captions->ids_facility = trim(uar_i18ngetmessage(i18nhandle,"IDS_FACILITY",", facility"))
 SET int_captions->ids_days = trim(uar_i18ngetmessage(i18nhandle,"IDS_DAYS","days"))
 DECLARE get_expire_rule = vc WITH constant("DCP_GET_EXPIRE_RULES")
 DECLARE get_ceprsnls_to_expire = vc WITH constant("DCP_GET_CEPRSNLS_TO_EXPIRE")
 DECLARE add_expire_audit = vc WITH constant("DCP_ADD_EXPIRE_AUDIT")
 DECLARE rpt_expired_ceprsnl = vc WITH constant("DCP_RPT_EXPIRED_CEPRSNL")
 DECLARE text_length = i4 WITH constant(textlen(trim(request->batch_selection)))
 DECLARE empty = i2 WITH constant(1)
 DECLARE not_empty = i2 WITH constant(0)
 DECLARE batch_update = i2 WITH constant(2)
 DECLARE run_type = i2 WITH constant(0)
 DECLARE valid_until_dt_tm_ops = vc WITH constant("31-DEC-2100 00:00:00")
 DECLARE expired = f8 WITH constant(uar_get_code_by("MEANING",103,"EXPIRED"))
 DECLARE appid = i4 WITH constant(4600)
 DECLARE taskid = i4 WITH constant(4801)
 DECLARE reqid = i4 WITH constant(1000056)
 DECLARE prsnl_full_name = vc WITH noconstant
 DECLARE rule_params = vc WITH noconstant
 DECLARE file_loc = vc WITH noconstant, private
 DECLARE rule_name = vc WITH noconstant
 DECLARE ex_rule_counter = i4 WITH noconstant
 DECLARE get_ex_ruledef_cnt = i4 WITH noconstant
 DECLARE get_batch_ensure_cnt = i4 WITH noconstant
 DECLARE found = i2 WITH noconstant
 DECLARE rule_index_found = i4 WITH noconstant
 DECLARE rule_index = i4 WITH noconstant
 DECLARE ruledef_idx = i4 WITH noconstant
 DECLARE batch_ensure_index = i4 WITH noconstant
 DECLARE audit_index = i4 WITH noconstant
 DECLARE rpt_index = i4 WITH noconstant
 DECLARE happ = i4 WITH noconstant
 DECLARE iret = i4 WITH noconstant
 DECLARE htask = i4 WITH noconstant
 DECLARE hstep = i4 WITH noconstant
 DECLARE hreq = i4 WITH noconstant
 DECLARE hitem = i4 WITH noconstant
 DECLARE hsb = i4 WITH noconstant
 DECLARE hrep = i4 WITH noconstant
 DECLARE total_ensured = i4 WITH noconstant
 SET reply->status_data.status = "S"
 SET found = 0
 SET rule_index_found = 0
 SET rule_index = 1
 SET ruledef_idx = 1
 SET batch_ensure_index = 1
 SET audit_index = 1
 SET rpt_index = 1
 SET ex_rule_counter = 0
 SET get_ex_ruledef_cnt = 0
 SET get_batch_ensure_cnt = 0
 SET ensure_cnt = 0
 SET total_ensured = 0
 SET action_dt_tm = cnvtdatetime(request->ops_date)
 IF (text_length > 0)
  SET posa1 = findstring(";",request->batch_selection)
  IF (posa1 > 1)
   SET file_loc = substring(1,(posa1 - 1),request->batch_selection)
  ENDIF
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 IF (((posa1+ 1) < text_length))
  SET rule_name = substring((posa1+ 1),(text_length - posa1),request->batch_selection)
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 IF ((reply->status_data.status="F"))
  SET reply->ops_event = "FILE LOCATION AND/OR RULE NAME NOT DEFINED"
  GO TO exit_script
 ENDIF
 EXECUTE value(get_expire_rule)  WITH replace("REQUEST",req_get_ex_rules), replace("REPLY",
  rep_get_ex_rules)
 SET ex_rule_counter = cnvtint(size(rep_get_ex_rules->expire_rule,5))
 FOR (x = 1 TO ex_rule_counter)
   IF (rule_name=trim(rep_get_ex_rules->expire_rule[x].rule_name)
    AND (rep_get_ex_rules->expire_rule[x].active_ind=1))
    SET found = 1
    SET rule_index_found = x
    SET x = ex_rule_counter
   ENDIF
 ENDFOR
 IF (found != 1)
  SET reply->status_data.status = "F"
  SET reply->ops_event = "RULE NOT FOUND"
  GO TO exit_script
 ENDIF
 SET req_get_ceprsnl_to_ex->max_rec = 0
 SET req_get_ceprsnl_to_ex->start_ce_event_prsnl = 0
 IF (rule_index > size(req_get_ceprsnl_to_ex->expire_rule,5))
  SET stat = alterlist(req_get_ceprsnl_to_ex->expire_rule,rule_index)
 ENDIF
 SET req_get_ceprsnl_to_ex->expire_rule[rule_index].rule_id = rep_get_ex_rules->expire_rule[
 rule_index_found].expire_rule_id
 SET get_ex_ruledef_cnt = cnvtint(size(rep_get_ex_rules->expire_rule[rule_index_found].
   rule_definition,5))
 IF (get_ex_ruledef_cnt > size(req_get_ceprsnl_to_ex->expire_rule[rule_index].rule_definition,5))
  SET stat = alterlist(req_get_ceprsnl_to_ex->expire_rule[rule_index].rule_definition,
   get_ex_ruledef_cnt)
 ENDIF
 FOR (ruledef_idx = 1 TO get_ex_ruledef_cnt)
   SET req_get_ceprsnl_to_ex->expire_rule[rule_index].rule_definition[ruledef_idx].rule_type_cd =
   rep_get_ex_rules->expire_rule[rule_index_found].rule_definition[ruledef_idx].rule_type_cd
   SET req_get_ceprsnl_to_ex->expire_rule[rule_index].rule_definition[ruledef_idx].param_name =
   rep_get_ex_rules->expire_rule[rule_index_found].rule_definition[ruledef_idx].param_name
   SET req_get_ceprsnl_to_ex->expire_rule[rule_index].rule_definition[ruledef_idx].param_value =
   rep_get_ex_rules->expire_rule[rule_index_found].rule_definition[ruledef_idx].param_value
   SET req_get_ceprsnl_to_ex->expire_rule[rule_index].rule_definition[ruledef_idx].merge_name =
   rep_get_ex_rules->expire_rule[rule_index_found].rule_definition[ruledef_idx].merge_name
   SET req_get_ceprsnl_to_ex->expire_rule[rule_index].rule_definition[ruledef_idx].merge_value =
   rep_get_ex_rules->expire_rule[rule_index_found].rule_definition[ruledef_idx].merge_id
   SET req_get_ceprsnl_to_ex->expire_rule[rule_index].rule_definition[ruledef_idx].loc_facility_cd =
   rep_get_ex_rules->expire_rule[rule_index_found].rule_definition[ruledef_idx].loc_facility_cd
 ENDFOR
 EXECUTE value(get_ceprsnls_to_expire)  WITH replace("REQUEST",req_get_ceprsnl_to_ex), replace(
  "REPLY",rep_get_ceprsnl_to_ex)
 IF ((rep_get_ceprsnl_to_ex->status_data.status != "S"))
  IF ((rep_get_ceprsnl_to_ex->status="Z"))
   SET reply->status_data.status = "Z"
   SET reply->ops_event = "NO EVENTS TO EXPIRE"
  ELSE
   SET reply->status_data.status = "F"
   SET reply->ops_event = "FAILED TO GET EVENTS TO EXPIRE"
  ENDIF
  GO TO exit_script
 ENDIF
 SET iret = uar_crmbeginapp(appid,happ)
 IF (iret != 0)
  SET reply->status_data.status = "F"
  SET reply->ops_event = "FAILED TO ENSURE EVENTS:- App Error"
  GO TO exit_script
 ENDIF
 SET iret = uar_crmbegintask(happ,taskid,htask)
 IF (iret != 0)
  SET reply->status_data.status = "F"
  SET reply->ops_event = "FAILED TO ENSURE EVENTS:- Task Error"
  GO TO exit_script
 ENDIF
 SET iret = uar_crmbeginreq(htask,"",reqid,hstep)
 IF (iret != 0)
  SET reply->status_data.status = "F"
  SET reply->ops_event = "FAILED TO ENSURE EVENTS:- CrmBegin Failed"
  GO TO exit_script
 ENDIF
 SET hreq = uar_crmgetrequest(hstep)
 SET get_batch_ensure_cnt = size(rep_get_ceprsnl_to_ex->event_prsnl_list,5)
 FOR (batch_ensure_index = 1 TO get_batch_ensure_cnt)
   SET hitem = uar_srvadditem(hreq,"req")
   SET stat = uar_srvsetshort(hitem,"ensure_type",batch_update)
   SET hitem = uar_srvgetstruct(hitem,"event_prsnl")
   SET stat = uar_srvsetdouble(hitem,"action_prsnl_id",rep_get_ceprsnl_to_ex->event_prsnl_list[
    batch_ensure_index].action_prsnl_id)
   SET stat = uar_srvsetdouble(hitem,"action_type_cd",rep_get_ceprsnl_to_ex->event_prsnl_list[
    batch_ensure_index].action_type_cd)
   SET stat = uar_srvsetdate(hitem,"action_dt_tm",action_dt_tm)
   SET stat = uar_srvsetdouble(hitem,"proxy_prsnl_id",reqinfo->updt_id)
   SET stat = uar_srvsetdouble(hitem,"action_status_cd",expired)
   SET stat = uar_srvsetshort(hitem,"valid_from_dt_tm_ind",empty)
   SET stat = uar_srvsetdate(hitem,"valid_until_dt_tm",cnvtdatetime(valid_until_dt_tm_ops))
   SET stat = uar_srvsetshort(hitem,"request_dt_tm_ind",empty)
   SET stat = uar_srvsetshort(hitem,"action_dt_tm_ind",not_empty)
   SET stat = uar_srvsetshort(hitem,"change_since_action_flag",0)
   SET stat = uar_srvsetshort(hitem,"change_since_action_flag_ind",not_empty)
   SET stat = uar_srvsetshort(hitem,"defeat_succn_ind",1)
   SET stat = uar_srvsetdouble(hitem,"event_prsnl_id",rep_get_ceprsnl_to_ex->event_prsnl_list[
    batch_ensure_index].event_prsnl_id)
   SET ensure_cnt = (ensure_cnt+ 1)
   IF (ensure_cnt > 300
    AND batch_ensure_index < get_batch_ensure_cnt)
    SET iret = uar_crmperform(hstep)
    IF (getcrmreply(1))
     SET reply->status_data.status = "F"
     GO TO clean_up_ensure
    ENDIF
    IF (iret != 0)
     SET reply->ops_event = "FAILED:- CrmPerform Failed "
     SET reply->status_data.status = "F"
     GO TO clean_up_ensure
    ENDIF
    SET iret = uar_crmbeginreq(htask,"",reqid,hstep)
    IF (iret != 0)
     SET reply->ops_event = "FAILED:- CrmBegin Failed "
     SET reply->status_data.status = "F"
     GO TO clean_up_ensure
    ENDIF
    SET total_ensured = (total_ensured+ ensure_cnt)
    SET ensure_cnt = 0
    SET hreq = uar_crmgetrequest(hstep)
   ENDIF
 ENDFOR
 IF (get_batch_ensure_cnt >= 1
  AND ensure_cnt != 0)
  SET iret = uar_crmperform(hstep)
  IF (getcrmreply(1))
   SET reply->status_data.status = "F"
   GO TO clean_up_ensure
  ENDIF
  IF (iret != 0)
   SET reply->ops_event = "FAILED:- CrmPerform Failed "
   SET reply->status_data.status = "F"
   GO TO clean_up_ensure
  ENDIF
  SET total_ensured = (total_ensured+ ensure_cnt)
 ENDIF
#clean_up_ensure
 CALL echo(build("clean up total_ensured ### ",total_ensured))
 SET reply->ops_event = concat(reply->ops_event,build(total_ensured)," of ",build(
   get_batch_ensure_cnt)," ensured")
 CALL echo(build("#### ops_event ",reply->ops_event))
 IF (hstep != 0)
  CALL uar_crmendreq(hstep)
  SET hstep = 0
 ENDIF
 IF (htask != 0)
  CALL uar_crmendtask(htask)
  SET htask = 0
 ENDIF
 IF (happ != 0)
  CALL uar_crmendapp(happ)
  SET happ = 0
 ENDIF
 IF (total_ensured < 1)
  GO TO exit_script
 ENDIF
 SET rule_params = int_captions->ids_expire
 CALL buildactiontypesummary(1)
 CALL buildprsnlsummary(1)
 CALL buildreqsummary(1)
 CALL builddocsummary(1)
 CALL buildenctrtypesummary(1)
 CALL buildenctrstatussummary(1)
 CALL builddischargesummary(1)
 CALL buildorgsummary(1)
 CALL buildfacsummary(1)
 SET stat = alterlist(req_expire_audit->expire_rule,audit_index)
 SET req_expire_audit->expire_rule[audit_index].rule_id = rep_get_ex_rules->expire_rule[
 rule_index_found].expire_rule_id
 SET req_expire_audit->expire_rule[audit_index].rule_parameter = rule_params
 SET req_expire_audit->expire_rule[audit_index].run_prsnl_id = reqinfo->updt_id
 SET req_expire_audit->expire_rule[audit_index].run_type = run_type
 SET req_expire_audit->expire_rule[audit_index].rows_updated = total_ensured
 SET req_expire_audit->expire_rule[audit_index].run_dt_tm = cnvtdatetime(valid_until_dt_tm_ops)
 EXECUTE value(add_expire_audit)  WITH replace("REQUEST",req_expire_audit), replace("REPLY",
  rep_expire_audit)
 IF ((rep_get_ceprsnl_to_ex->status_data.status != "S"))
  SET reply->status_data.status = "F"
  SET reply->ops_event = concat(reply->ops_event,", ","FAILED ADD TO RULE_AUDIT")
 ENDIF
 IF (total_ensured > size(req_expire_rpt->event_prsnl_list,5))
  SET stat = alterlist(req_expire_rpt->event_prsnl_list,total_ensured)
 ENDIF
 SET req_expire_rpt->rule_parameter = rule_params
 SET req_expire_rpt->run_type_flag = run_type
 SET prsnl_full_name = getprsnlname(reqinfo->updt_id)
 SET req_expire_rpt->run_prsnl_name_full = prsnl_full_name
 SET req_expire_rpt->batch_selection = request->batch_selection
 SET req_expire_rpt->output_dist = request->output_dist
 FOR (rpt_index = 1 TO total_ensured)
   SET req_expire_rpt->event_prsnl_list[rpt_index].person_id = rep_get_ceprsnl_to_ex->
   event_prsnl_list[rpt_index].person_id
   SET req_expire_rpt->event_prsnl_list[rpt_index].action_type_cd = rep_get_ceprsnl_to_ex->
   event_prsnl_list[rpt_index].action_type_cd
   SET req_expire_rpt->event_prsnl_list[rpt_index].action_prsnl_id = rep_get_ceprsnl_to_ex->
   event_prsnl_list[rpt_index].action_prsnl_id
   SET req_expire_rpt->event_prsnl_list[rpt_index].req_dt_tm = rep_get_ceprsnl_to_ex->
   event_prsnl_list[rpt_index].req_dt_tm
   SET req_expire_rpt->event_prsnl_list[rpt_index].med_rec_num_str = rep_get_ceprsnl_to_ex->
   event_prsnl_list[rpt_index].med_rec_num
   SET req_expire_rpt->event_prsnl_list[rpt_index].financial_num_str = rep_get_ceprsnl_to_ex->
   event_prsnl_list[rpt_index].financial_num
   SET req_expire_rpt->event_prsnl_list[rpt_index].discharge_dt_tm = rep_get_ceprsnl_to_ex->
   event_prsnl_list[rpt_index].discharge_dt_tm
   SET req_expire_rpt->event_prsnl_list[rpt_index].encounter_type_cd = rep_get_ceprsnl_to_ex->
   event_prsnl_list[rpt_index].encounter_type_cd
   SET req_expire_rpt->event_prsnl_list[rpt_index].organization_id = rep_get_ceprsnl_to_ex->
   event_prsnl_list[rpt_index].organization_id
   SET req_expire_rpt->event_prsnl_list[rpt_index].facility_cd = rep_get_ceprsnl_to_ex->
   event_prsnl_list[rpt_index].facility_cd
   SET req_expire_rpt->event_prsnl_list[rpt_index].event_cd = rep_get_ceprsnl_to_ex->
   event_prsnl_list[rpt_index].event_cd
   SET req_expire_rpt->event_prsnl_list[rpt_index].event_cd_disp = rep_get_ceprsnl_to_ex->
   event_prsnl_list[rpt_index].event_cd_disp
 ENDFOR
 EXECUTE value(rpt_expired_ceprsnl)  WITH replace("REQUEST",req_expire_rpt), replace("REPLY",
  rep_expire_rpt)
 IF ((rep_expire_rpt->status_data.status != "S"))
  SET reply->status_data.status = "F"
  SET reply->ops_event = concat(reply->ops_event," FAILED PRINT REPORT")
  GO TO exit_script
 ENDIF
 GO TO exit_script
 SUBROUTINE buildactiontypesummary(x)
   DECLARE bactiontype = i2 WITH noconstant(0), private
   DECLARE saction = vc WITH noconstant, private
   DECLARE action_type_cd = f8 WITH constant(uar_get_code_by("MEANING",28842,"ACTIONTYPE")), private
   DECLARE private_ruledef_idx = i4 WITH noconstant(1), private
   DECLARE addor = i2 WITH noconstant(0), private
   WHILE (private_ruledef_idx <= get_ex_ruledef_cnt)
    IF ((action_type_cd=rep_get_ex_rules->expire_rule[rule_index_found].rule_definition[
    private_ruledef_idx].rule_type_cd))
     SET bactiontype = 1
     IF (addor=1)
      SET saction = concat(saction," ",int_captions->ids_or)
     ENDIF
     SET saction = concat(saction," ",trim(uar_get_code_display(rep_get_ex_rules->expire_rule[
        rule_index_found].rule_definition[private_ruledef_idx].merge_id)))
     SET addor = 1
    ENDIF
    SET private_ruledef_idx = (private_ruledef_idx+ 1)
   ENDWHILE
   IF (bactiontype=1)
    SET rule_params = concat(rule_params,saction," ",int_captions->ids_action)
   ENDIF
 END ;Subroutine
 SUBROUTINE buildprsnlsummary(x)
   DECLARE bactiontype = i2 WITH noconstant(0), private
   DECLARE saction = vc WITH noconstant, private
   DECLARE sprsnl = vc WITH noconstant, private
   DECLARE action_prsnl_cd = f8 WITH constant(uar_get_code_by("MEANING",28842,"ACTIONPRSNL")),
   private
   DECLARE private_ruledef_idx = i4 WITH noconstant(1), private
   DECLARE addor = i2 WITH noconstant(0), private
   WHILE (private_ruledef_idx <= get_ex_ruledef_cnt)
    IF ((action_prsnl_cd=rep_get_ex_rules->expire_rule[rule_index_found].rule_definition[
    private_ruledef_idx].rule_type_cd))
     SET bactiontype = 1
     IF (addor=1)
      SET saction = concat(saction," ",int_captions->ids_or)
     ENDIF
     SET sprsnl = getprsnlname(rep_get_ex_rules->expire_rule[rule_index_found].rule_definition[
      private_ruledef_idx].merge_id)
     SET saction = concat(saction," ",sprsnl)
     SET sprsnl = fillstring(100," ")
     SET addor = 1
    ENDIF
    SET private_ruledef_idx = (private_ruledef_idx+ 1)
   ENDWHILE
   IF (bactiontype=1)
    SET rule_params = concat(rule_params,int_captions->ids_for,saction)
   ENDIF
 END ;Subroutine
 SUBROUTINE buildreqsummary(x)
   DECLARE bactiontype = i2 WITH noconstant(0), private
   DECLARE saction = vc WITH noconstant, private
   DECLARE age_of_req = f8 WITH constant(uar_get_code_by("MEANING",28842,"AGEOFREQ")), private
   DECLARE private_ruledef_idx = i4 WITH noconstant(1), private
   WHILE (private_ruledef_idx <= get_ex_ruledef_cnt)
    IF ((age_of_req=rep_get_ex_rules->expire_rule[rule_index_found].rule_definition[
    private_ruledef_idx].rule_type_cd))
     SET bactiontype = 1
     SET saction = rep_get_ex_rules->expire_rule[rule_index_found].rule_definition[
     private_ruledef_idx].param_value
    ENDIF
    SET private_ruledef_idx = (private_ruledef_idx+ 1)
   ENDWHILE
   IF (bactiontype=1)
    SET rule_params = concat(rule_params," ",int_captions->ids_age_of_req," ",saction,
     " ",int_captions->ids_days," ")
   ENDIF
 END ;Subroutine
 SUBROUTINE builddocsummary(x)
   DECLARE bactiontype = i2 WITH noconstant(0), private
   DECLARE saction = vc WITH noconstant, private
   DECLARE doc_type = f8 WITH constant(uar_get_code_by("MEANING",28842,"DOCTYPE")), private
   DECLARE private_ruledef_idx = i4 WITH noconstant(1), private
   DECLARE addor = i2 WITH noconstant(0), private
   WHILE (private_ruledef_idx <= get_ex_ruledef_cnt)
    IF ((doc_type=rep_get_ex_rules->expire_rule[rule_index_found].rule_definition[private_ruledef_idx
    ].rule_type_cd))
     SET bactiontype = 1
     IF (addor=1)
      SET saction = concat(saction," ",int_captions->ids_or)
     ENDIF
     SET saction = concat(saction," ",trim(uar_get_code_display(rep_get_ex_rules->expire_rule[
        rule_index_found].rule_definition[private_ruledef_idx].merge_id)))
     SET addor = 1
    ENDIF
    SET private_ruledef_idx = (private_ruledef_idx+ 1)
   ENDWHILE
   IF (bactiontype=1)
    SET rule_params = concat(rule_params," ",int_captions->ids_doc_type,saction)
   ENDIF
 END ;Subroutine
 SUBROUTINE buildenctrtypesummary(x)
   DECLARE bactiontype = i2 WITH noconstant(0), private
   DECLARE saction = vc WITH noconstant, private
   DECLARE encntr_type = f8 WITH constant(uar_get_code_by("MEANING",28842,"ENCNTRTYPE")), private
   DECLARE private_ruledef_idx = i4 WITH noconstant(1), private
   DECLARE addor = i2 WITH noconstant(0), private
   WHILE (private_ruledef_idx <= get_ex_ruledef_cnt)
    IF ((encntr_type=rep_get_ex_rules->expire_rule[rule_index_found].rule_definition[
    private_ruledef_idx].rule_type_cd))
     SET bactiontype = 1
     IF (addor=1)
      SET saction = concat(saction," ",int_captions->ids_or)
     ENDIF
     SET saction = concat(saction," ",trim(uar_get_code_display(rep_get_ex_rules->expire_rule[
        rule_index_found].rule_definition[private_ruledef_idx].merge_id)))
     SET addor = 1
    ENDIF
    SET private_ruledef_idx = (private_ruledef_idx+ 1)
   ENDWHILE
   IF (bactiontype=1)
    SET rule_params = concat(rule_params," ",int_captions->ids_encntrtype,saction)
   ENDIF
 END ;Subroutine
 SUBROUTINE buildenctrstatussummary(x)
   DECLARE bactiontype = i2 WITH noconstant(0), private
   DECLARE saction = vc WITH noconstant, private
   DECLARE encntr_status = f8 WITH constant(uar_get_code_by("MEANING",28842,"ENCNTRSTATUS")), private
   DECLARE private_ruledef_idx = i4 WITH noconstant(1), private
   DECLARE addor = i2 WITH noconstant(0), private
   WHILE (private_ruledef_idx <= get_ex_ruledef_cnt)
    IF ((encntr_status=rep_get_ex_rules->expire_rule[rule_index_found].rule_definition[
    private_ruledef_idx].rule_type_cd))
     SET bactiontype = 1
     IF (addor=1)
      SET saction = concat(saction," ",int_captions->ids_or)
     ENDIF
     SET saction = concat(saction," ",trim(uar_get_code_display(rep_get_ex_rules->expire_rule[
        rule_index_found].rule_definition[private_ruledef_idx].merge_id)))
     SET addor = 1
    ENDIF
    SET private_ruledef_idx = (private_ruledef_idx+ 1)
   ENDWHILE
   IF (bactiontype=1)
    SET rule_params = concat(rule_params," ",int_captions->ids_encntrstatus,saction)
   ENDIF
 END ;Subroutine
 SUBROUTINE builddischargesummary(x)
   DECLARE bactiontype = i2 WITH noconstant(0), private
   DECLARE saction = vc WITH noconstant, private
   DECLARE days_since_dis = f8 WITH constant(uar_get_code_by("MEANING",28842,"DAYSINCEDSCH")),
   private
   DECLARE private_ruledef_idx = i4 WITH noconstant(1), private
   WHILE (private_ruledef_idx <= get_ex_ruledef_cnt)
    IF ((days_since_dis=rep_get_ex_rules->expire_rule[rule_index_found].rule_definition[
    private_ruledef_idx].rule_type_cd))
     SET bactiontype = 1
     SET saction = rep_get_ex_rules->expire_rule[rule_index_found].rule_definition[
     private_ruledef_idx].param_value
    ENDIF
    SET private_ruledef_idx = (private_ruledef_idx+ 1)
   ENDWHILE
   IF (bactiontype=1)
    SET rule_params = concat(rule_params," ",int_captions->ids_discharge," ",saction,
     " ",int_captions->ids_days)
   ENDIF
 END ;Subroutine
 SUBROUTINE buildorgsummary(x)
   DECLARE bactiontype = i2 WITH noconstant(0), private
   DECLARE saction = vc WITH noconstant, private
   DECLARE organization_cd = f8 WITH constant(uar_get_code_by("MEANING",28842,"ORGANIZATION")),
   private
   DECLARE private_ruledef_idx = i4 WITH noconstant(1), private
   DECLARE addor = i2 WITH noconstant(0), private
   WHILE (private_ruledef_idx <= get_ex_ruledef_cnt)
    IF ((organization_cd=rep_get_ex_rules->expire_rule[rule_index_found].rule_definition[
    private_ruledef_idx].rule_type_cd))
     SET bactiontype = 1
     IF (addor=1)
      SET saction = concat(saction," ",int_captions->ids_or)
     ENDIF
     SET saction = concat(saction," ",trim(rep_get_ex_rules->expire_rule[rule_index_found].
       rule_definition[private_ruledef_idx].param_name))
     SET addor = 1
    ENDIF
    SET private_ruledef_idx = (private_ruledef_idx+ 1)
   ENDWHILE
   IF (bactiontype=1)
    SET rule_params = concat(rule_params," ",int_captions->ids_org,saction)
   ENDIF
 END ;Subroutine
 SUBROUTINE buildfacsummary(x)
   DECLARE bactiontype = i2 WITH noconstant(0), private
   DECLARE saction = vc WITH noconstrule_foundrivate
   DECLARE organization_cd = f8 WITH constant(uar_get_code_by("MEANING",28842,"ORGANIZATION")),
   private
   DECLARE private_ruledef_idx = i4 WITH noconstant(1), private
   DECLARE addor = i2 WITH noconstant(0), private
   WHILE (private_ruledef_idx <= get_ex_ruledef_cnt)
    IF ((organization_cd=rep_get_ex_rules->expire_rule[rule_index_found].rule_definition[
    private_ruledef_idx].rule_type_cd))
     SET bactiontype = 1
     IF (addor=1)
      SET saction = concat(saction," ",int_captions->ids_or)
     ENDIF
     IF ((0 < rep_get_ex_rules->expire_rule[rule_index_found].rule_definition[private_ruledef_idx].
     loc_facility_cd))
      SET saction = concat(saction," ",trim(uar_get_code_display(rep_get_ex_rules->expire_rule[
         rule_index_found].rule_definition[private_ruledef_idx].loc_facility_cd)))
      SET addor = 1
     ENDIF
    ENDIF
    SET private_ruledef_idx = (private_ruledef_idx+ 1)
   ENDWHILE
   IF (bactiontype=1)
    SET rule_params = concat(rule_params,int_captions->ids_facility,saction)
   ENDIF
 END ;Subroutine
 SUBROUTINE getprsnlname(prsnlid)
   DECLARE full_name = vc WITH noconstant, protect
   SET full_name = fillstring(100," ")
   SELECT INTO "nl:"
    FROM prsnl p
    WHERE p.person_id=prsnlid
    DETAIL
     full_name = trim(p.name_full_formatted)
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET full_name = fillstring(100," ")
    SET full_name = trim(int_captions->ids_name_not_found)
   ENDIF
   RETURN(full_name)
 END ;Subroutine
 SUBROUTINE getcrmreply(x)
   DECLARE rtnval = i2 WITH noconstant, protect
   DECLARE ewarning = i2 WITH constant(2), private
   DECLARE severitycd = i4 WITH noconstant, private
   DECLARE statuscd = i4 WITH noconstant, private
   DECLARE statustext = vc WITH noconstant, private
   SET rtnval = 0
   SET hrep = uar_crmgetreply(hstep)
   SET hsb = uar_srvgetstruct(hrep,"sb")
   SET severitycd = uar_srvgetlong(hsb,"severityCD")
   SET statuscd = uar_srvgetlong(hsb,"statusCD")
   SET statustext = uar_srvgetstringptr(hsb,"statusText")
   IF (severitycd > ewarning)
    SET reply->ops_event = concat(reply->ops_event," severityCd =",build(severitycd)," statusCd =",
     build(statuscd),
     ", ",statustext)
    SET rtnval = 1
   ENDIF
   RETURN(rtnval)
 END ;Subroutine
#exit_script
 IF ((reply->status_data.status="S"))
  SET reply->status_data.subeventstatus.operationname = "Ops. expire clinical_events"
  SET reply->status_data.subeventstatus.targetobjectname = ""
  SET reply->status_data.subeventstatus.targetobjectvalue = "dcp_ops_ceprsnl_expire_drv"
  SET reply->status_data.subeventstatus.operationstatus = "S"
 ELSEIF ((reply->status_data.status="Z"))
  SET reply->status_data.subeventstatus.operationname = "Ops. expire clinical_events"
  SET reply->status_data.subeventstatus.targetobjectname = ""
  SET reply->status_data.subeventstatus.targetobjectvalue = "dcp_ops_ceprsnl_expire_drv"
  SET reply->status_data.subeventstatus.operationstatus = "Z"
 ELSE
  SET reply->status_data.subeventstatus.operationname = "Ops. expire clinical_events"
  SET reply->status_data.subeventstatus.targetobjectname = ""
  SET reply->status_data.subeventstatus.targetobjectvalue = "dcp_ops_ceprsnl_expire_drv"
  SET reply->status_data.subeventstatus.operationstatus = "F"
 ENDIF
 CALL echorecord(reply)
 IF (hstep != 0)
  CALL uar_crmendreq(hstep)
  SET hstep = 0
 ENDIF
 IF (htask != 0)
  CALL uar_crmendtask(htask)
  SET htask = 0
 ENDIF
 IF (happ != 0)
  CALL uar_crmendapp(happ)
  SET happ = 0
 ENDIF
END GO
