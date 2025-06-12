CREATE PROGRAM dcp_acm_retrieve_filter_values:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "JSON_ARGS:" = ""
  WITH outdev, json_args
 SUBROUTINE (extractparamsfromrequest(req=vc(ref),default=vc) =vc WITH protect)
  IF (validate(req->blob_in)=1)
   IF (size(trim(req->blob_in)) > 0)
    RETURN(req->blob_in)
   ENDIF
  ENDIF
  RETURN(default)
 END ;Subroutine
 SET stat = cnvtjsontorec(extractparamsfromrequest(request, $JSON_ARGS))
 CALL echorecord(filter_request)
 FREE RECORD reply
 RECORD reply(
   1 query_type_cd = f8
   1 filter_list[*]
     2 argument_name = vc
     2 code_set = f8
     2 available_values[*]
       3 argument_value = vc
       3 argument_meaning = vc
       3 argument_type = vc
       3 parent_entity_name = vc
       3 parent_entity_id = f8
       3 child_values[*]
         4 argument_value = vc
         4 parent_entity_name = vc
         4 parent_entity_id = f8
   1 risk_flag = i2
   1 case_status_flag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD rule_consq_map
 RECORD rule_consq_map(
   1 rule_list[*]
     2 name = vc
     2 consq_list[*]
       3 name = vc
 )
 FREE RECORD encounters
 RECORD encounters(
   1 encntr_data[*]
     2 argument_value = vc
     2 parent_entity_name = vc
     2 parent_entity_id = f8
 )
 IF (validate(_sacrtl_org_inc_,99999)=99999)
  DECLARE _sacrtl_org_inc_ = i2 WITH constant(1)
  RECORD sac_org(
    1 organizations[*]
      2 organization_id = f8
      2 confid_cd = f8
      2 confid_level = i4
  )
  EXECUTE secrtl
  EXECUTE sacrtl
  DECLARE orgcnt = i4 WITH protected, noconstant(0)
  DECLARE secstat = i2
  DECLARE logontype = i4 WITH protect, noconstant(- (1))
  DECLARE dynamic_org_ind = i4 WITH protect, noconstant(- (1))
  DECLARE dcur_trustid = f8 WITH protect, noconstant(0.0)
  DECLARE dynorg_enabled = i4 WITH constant(1)
  DECLARE dynorg_disabled = i4 WITH constant(0)
  DECLARE logontype_nhs = i4 WITH constant(1)
  DECLARE logontype_legacy = i4 WITH constant(0)
  DECLARE confid_cnt = i4 WITH protected, noconstant(0)
  RECORD confid_codes(
    1 list[*]
      2 code_value = f8
      2 coll_seq = f8
  )
  CALL uar_secgetclientlogontype(logontype)
  CALL echo(build("logontype:",logontype))
  IF (logontype != logontype_nhs)
   SET dynamic_org_ind = dynorg_disabled
  ENDIF
  IF (logontype=logontype_nhs)
   SUBROUTINE (getdynamicorgpref(dtrustid=f8) =i4)
     DECLARE scur_trust = vc
     DECLARE pref_val = vc
     DECLARE is_enabled = i4 WITH constant(1)
     DECLARE is_disabled = i4 WITH constant(0)
     SET scur_trust = cnvtstring(dtrustid)
     SET scur_trust = concat(scur_trust,".00")
     IF ( NOT (validate(pref_req,0)))
      RECORD pref_req(
        1 write_ind = i2
        1 delete_ind = i2
        1 pref[*]
          2 contexts[*]
            3 context = vc
            3 context_id = vc
          2 section = vc
          2 section_id = vc
          2 subgroup = vc
          2 entries[*]
            3 entry = vc
            3 values[*]
              4 value = vc
      )
     ENDIF
     IF ( NOT (validate(pref_rep,0)))
      RECORD pref_rep(
        1 pref[*]
          2 section = vc
          2 section_id = vc
          2 subgroup = vc
          2 entries[*]
            3 pref_exists_ind = i2
            3 entry = vc
            3 values[*]
              4 value = vc
        1 status_data
          2 status = c1
          2 subeventstatus[1]
            3 operationname = c25
            3 operationstatus = c1
            3 targetobjectname = c25
            3 targetobjectvalue = vc
      )
     ENDIF
     SET stat = alterlist(pref_req->pref,1)
     SET stat = alterlist(pref_req->pref[1].contexts,2)
     SET stat = alterlist(pref_req->pref[1].entries,1)
     SET pref_req->pref[1].contexts[1].context = "organization"
     SET pref_req->pref[1].contexts[1].context_id = scur_trust
     SET pref_req->pref[1].contexts[2].context = "default"
     SET pref_req->pref[1].contexts[2].context_id = "system"
     SET pref_req->pref[1].section = "workflow"
     SET pref_req->pref[1].section_id = "UK Trust Security"
     SET pref_req->pref[1].entries[1].entry = "dynamic organizations"
     EXECUTE ppr_preferences  WITH replace("REQUEST","PREF_REQ"), replace("REPLY","PREF_REP")
     IF (cnvtupper(pref_rep->pref[1].entries[1].values[1].value)="ENABLED")
      RETURN(is_enabled)
     ELSE
      RETURN(is_disabled)
     ENDIF
   END ;Subroutine
   DECLARE hprop = i4 WITH protect, noconstant(0)
   DECLARE tmpstat = i2
   DECLARE spropname = vc
   DECLARE sroleprofile = vc
   SET hprop = uar_srvcreateproperty()
   SET tmpstat = uar_secgetclientattributesext(5,hprop)
   SET spropname = uar_srvfirstproperty(hprop)
   SET sroleprofile = uar_srvgetpropertyptr(hprop,nullterm(spropname))
   SELECT INTO "nl:"
    FROM prsnl_org_reltn_type prt,
     prsnl_org_reltn por
    PLAN (prt
     WHERE prt.role_profile=sroleprofile
      AND prt.active_ind=1
      AND prt.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND prt.end_effective_dt_tm > cnvtdatetime(sysdate))
     JOIN (por
     WHERE (por.organization_id= Outerjoin(prt.organization_id))
      AND (por.person_id= Outerjoin(prt.prsnl_id))
      AND (por.active_ind= Outerjoin(1))
      AND (por.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
      AND (por.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
    ORDER BY por.prsnl_org_reltn_id
    DETAIL
     orgcnt = 1, secstat = alterlist(sac_org->organizations,1), user_person_id = prt.prsnl_id,
     sac_org->organizations[1].organization_id = prt.organization_id, sac_org->organizations[1].
     confid_cd = por.confid_level_cd, confid_cd = uar_get_collation_seq(por.confid_level_cd),
     sac_org->organizations[1].confid_level =
     IF (confid_cd > 0) confid_cd
     ELSE 0
     ENDIF
    WITH maxrec = 1
   ;end select
   SET dcur_trustid = sac_org->organizations[1].organization_id
   SET dynamic_org_ind = getdynamicorgpref(dcur_trustid)
   CALL uar_srvdestroyhandle(hprop)
  ENDIF
  IF (dynamic_org_ind=dynorg_disabled)
   SET confid_cnt = 0
   SELECT INTO "NL:"
    c.code_value, c.collation_seq
    FROM code_value c
    WHERE c.code_set=87
    DETAIL
     confid_cnt += 1
     IF (mod(confid_cnt,10)=1)
      secstat = alterlist(confid_codes->list,(confid_cnt+ 9))
     ENDIF
     confid_codes->list[confid_cnt].code_value = c.code_value, confid_codes->list[confid_cnt].
     coll_seq = c.collation_seq
    WITH nocounter
   ;end select
   SET secstat = alterlist(confid_codes->list,confid_cnt)
   SELECT DISTINCT INTO "nl:"
    FROM prsnl_org_reltn por
    WHERE (por.person_id=reqinfo->updt_id)
     AND por.active_ind=1
     AND por.beg_effective_dt_tm < cnvtdatetime(sysdate)
     AND por.end_effective_dt_tm >= cnvtdatetime(sysdate)
    HEAD REPORT
     IF (orgcnt > 0)
      secstat = alterlist(sac_org->organizations,100)
     ENDIF
    DETAIL
     orgcnt += 1
     IF (mod(orgcnt,100)=1)
      secstat = alterlist(sac_org->organizations,(orgcnt+ 99))
     ENDIF
     sac_org->organizations[orgcnt].organization_id = por.organization_id, sac_org->organizations[
     orgcnt].confid_cd = por.confid_level_cd
    FOOT REPORT
     secstat = alterlist(sac_org->organizations,orgcnt)
    WITH nocounter
   ;end select
   SELECT INTO "NL:"
    FROM (dummyt d1  WITH seq = value(orgcnt)),
     (dummyt d2  WITH seq = value(confid_cnt))
    PLAN (d1)
     JOIN (d2
     WHERE (sac_org->organizations[d1.seq].confid_cd=confid_codes->list[d2.seq].code_value))
    DETAIL
     sac_org->organizations[d1.seq].confid_level = confid_codes->list[d2.seq].coll_seq
    WITH nocounter
   ;end select
  ELSEIF (dynamic_org_ind=dynorg_enabled)
   DECLARE nhstrustchild_org_org_reltn_cd = f8
   SET nhstrustchild_org_org_reltn_cd = uar_get_code_by("MEANING",369,"NHSTRUSTCHLD")
   SELECT INTO "nl:"
    FROM org_org_reltn oor
    PLAN (oor
     WHERE oor.organization_id=dcur_trustid
      AND oor.active_ind=1
      AND oor.beg_effective_dt_tm < cnvtdatetime(sysdate)
      AND oor.end_effective_dt_tm >= cnvtdatetime(sysdate)
      AND oor.org_org_reltn_cd=nhstrustchild_org_org_reltn_cd)
    HEAD REPORT
     IF (orgcnt > 0)
      secstat = alterlist(sac_org->organizations,10)
     ENDIF
    DETAIL
     IF (oor.related_org_id > 0)
      orgcnt += 1
      IF (mod(orgcnt,10)=1)
       secstat = alterlist(sac_org->organizations,(orgcnt+ 9))
      ENDIF
      sac_org->organizations[orgcnt].organization_id = oor.related_org_id
     ENDIF
    FOOT REPORT
     secstat = alterlist(sac_org->organizations,orgcnt)
    WITH nocounter
   ;end select
  ELSE
   CALL echo(build("Unexpected login type: ",dynamimc_org_ind))
  ENDIF
 ENDIF
 DECLARE querytype_acmgroup = vc WITH protect, constant("ACMGROUP")
 DECLARE dwl_category_mean = vc WITH protect, constant("MP_AMB_CARE_MGT")
 DECLARE argname_acmgroup = vc WITH protect, constant("ACMPRSNLGROUPS")
 DECLARE argname_singleprovider = vc WITH protect, constant("SINGLEPROVIDER")
 DECLARE argname_pprcode = vc WITH protect, constant("PPRCODES")
 DECLARE argname_eprcode = vc WITH protect, constant("EPRCODES")
 DECLARE argname_locations = vc WITH protect, constant("LOCATIONS")
 DECLARE argname_locationdays = vc WITH protect, constant("LOCATIONDAYS")
 DECLARE argname_locationweeks = vc WITH protect, constant("LOCATIONWEEKS")
 DECLARE argname_locationmonths = vc WITH protect, constant("LOCATIONMONTHS")
 DECLARE argname_locationunits = vc WITH protect, constant("LOCATIONUNITS")
 DECLARE argname_discharge = vc WITH protect, constant("DISCHARGE")
 DECLARE argname_dischargemonths = vc WITH protect, constant("DISCHARGEMONTHS")
 DECLARE argname_dischargedays = vc WITH protect, constant("DISCHARGEDAYS")
 DECLARE argname_dischargeweeks = vc WITH protect, constant("DISCHARGEWEEKS")
 DECLARE argname_autoremove = vc WITH protect, constant("AUTOREMOVEPATIENTS")
 DECLARE argname_casestatus = vc WITH protect, constant("CASESTATUS")
 DECLARE argname_race = vc WITH protect, constant("RACE")
 DECLARE argname_gender = vc WITH protect, constant("GENDER")
 DECLARE argname_language = vc WITH protect, constant("LANGUAGE")
 DECLARE argname_payer = vc WITH protect, constant("PAYER")
 DECLARE argname_healthplan = vc WITH protect, constant("HEALTHPLAN")
 DECLARE argname_financialclass = vc WITH protect, constant("FINANCIALCLASS")
 DECLARE argname_age = vc WITH protect, constant("AGE")
 DECLARE argname_agefrom = vc WITH protect, constant("AGEFROM")
 DECLARE argname_ageto = vc WITH protect, constant("AGETO")
 DECLARE argname_agegreater = vc WITH protect, constant("AGEGREATER")
 DECLARE argname_ageless = vc WITH protect, constant("AGELESS")
 DECLARE argname_ageequal = vc WITH protect, constant("AGEEQUAL")
 DECLARE argname_agedays = vc WITH protect, constant("AGEDAYS")
 DECLARE argname_ageweeks = vc WITH protect, constant("AGEWEEKS")
 DECLARE argname_agemonths = vc WITH protect, constant("AGEMONTHS")
 DECLARE argname_ageyears = vc WITH protect, constant("AGEYEARS")
 DECLARE argname_casemanager = vc WITH protect, constant("CASEMANAGER")
 DECLARE argname_barriers = vc WITH protect, constant("BARRIERS")
 DECLARE argname_problem = vc WITH protect, constant("PROBLEM")
 DECLARE argname_confidlevel = vc WITH protect, constant("CONFIDENTIALITYLEVEL")
 DECLARE argname_condition = vc WITH protect, constant("CONDITION")
 DECLARE argname_diagnosis = vc WITH protect, constant("DIAGNOSIS")
 DECLARE argname_measures = vc WITH protect, constant("MEASURES")
 DECLARE argname_admission = vc WITH protect, constant("ADMISSION")
 DECLARE argname_admissionmonths = vc WITH protect, constant("ADMISSIONMONTHS")
 DECLARE argname_admissionweeks = vc WITH protect, constant("ADMISSIONWEEKS")
 DECLARE argname_admissiondays = vc WITH protect, constant("ADMISSIONDAYS")
 DECLARE argname_admissionfrom = vc WITH protect, constant("ADMISSIONFROM")
 DECLARE argname_admissionto = vc WITH protect, constant("ADMISSIONTO")
 DECLARE argname_encounter = vc WITH protect, constant("ENCOUNTER")
 DECLARE argname_encountertype = vc WITH protect, constant("ENCOUNTERTYPE")
 DECLARE argname_registry = vc WITH protect, constant("REGISTRY")
 DECLARE argname_orderstatus = vc WITH protect, constant("ORDERSTATUS")
 DECLARE argname_resultfilter1 = vc WITH protect, constant("RESULTFILTER1")
 DECLARE argname_resultfilter2 = vc WITH protect, constant("RESULTFILTER2")
 DECLARE argname_resultfilter3 = vc WITH protect, constant("RESULTFILTER3")
 DECLARE argname_resultfilter4 = vc WITH protect, constant("RESULTFILTER4")
 DECLARE argname_resultfilter5 = vc WITH protect, constant("RESULTFILTER5")
 DECLARE argname_cond_operator = vc WITH protect, constant("CONDITION_OPERATOR")
 DECLARE argname_assocproviders = vc WITH protect, constant("ASSOC_PROVIDERS")
 DECLARE argname_assocreltn = vc WITH protect, constant("ASSOC_RELTN")
 DECLARE argname_apptstatus = vc WITH protect, constant("APPTSTATUS")
 DECLARE argname_apptfrom = vc WITH protect, constant("APPTFROM")
 DECLARE argname_apptto = vc WITH protect, constant("APPTTO")
 DECLARE argname_apptdateunit = vc WITH protect, constant("APPTDATEUNIT")
 DECLARE argname_noappt = vc WITH protect, constant("NOAPPT")
 DECLARE argname_ordersstatus = vc WITH protect, constant("ORDERSSTATUS")
 DECLARE argname_ordertype = vc WITH protect, constant("ORDERTYPE")
 DECLARE argname_orderfrom = vc WITH protect, constant("ORDERFROM")
 DECLARE argname_orderto = vc WITH protect, constant("ORDERTO")
 DECLARE argname_orderdateunit = vc WITH protect, constant("ORDERDATEUNIT")
 DECLARE argname_expectations = vc WITH protect, constant("EXPECTATIONS")
 DECLARE argname_recommstatus = vc WITH protect, constant("RECOMMSTATUS")
 DECLARE argname_risk = vc WITH protect, constant("RISK")
 DECLARE argname_ranking = vc WITH protect, constant("RANKING")
 DECLARE argname_qualifying = vc WITH protect, constant("QUALIFYING")
 DECLARE argname_communicate_pref = vc WITH protect, constant("COMMUNICATIONPREF")
 DECLARE argname_pending_work = vc WITH protect, constant("PENDING_WORK")
 DECLARE argval_neardue = vc WITH protect, constant("Near Due")
 DECLARE argval_due = vc WITH protect, constant("Due")
 DECLARE argval_overdue = vc WITH protect, constant("Overdue")
 DECLARE argval_notdue = vc WITH protect, constant("Not Due")
 FREE RECORD bedrock_prefs
 RECORD bedrock_prefs(
   1 case_mgr[*]
     2 case_mgr_cd = f8
   1 encntr_types[*]
     2 encntr_type_cd = f8
     2 encntr_group = i4
 )
 FREE RECORD user_orgs
 RECORD user_orgs(
   1 organizations[*]
     2 organization_id = f8
 )
 DECLARE argname_default = vc WITH protect, constant("LISTDEFAULT")
 DECLARE retrievecasemanagerfrombedrock(null) = null
 SUBROUTINE retrievecasemanagerfrombedrock(null)
   DECLARE case_mgr_cnt = i4 WITH noconstant(0)
   SELECT INTO "nl:"
    FROM br_datamart_category bc,
     br_datamart_filter bf,
     br_datamart_value bv
    PLAN (bc
     WHERE bc.category_mean="MP_AMB_CARE_MGT"
      AND bc.category_type_flag=1)
     JOIN (bf
     WHERE bf.br_datamart_category_id=bc.br_datamart_category_id
      AND bf.filter_mean="CASE_MGR_CDS")
     JOIN (bv
     WHERE bv.br_datamart_category_id=bf.br_datamart_category_id
      AND bv.br_datamart_filter_id=bf.br_datamart_filter_id
      AND bv.logical_domain_id=0)
    DETAIL
     IF (bv.parent_entity_id > 0)
      case_mgr_cnt += 1
      IF (mod(case_mgr_cnt,10)=1)
       stat = alterlist(bedrock_prefs->case_mgr,(case_mgr_cnt+ 9))
      ENDIF
      bedrock_prefs->case_mgr[case_mgr_cnt].case_mgr_cd = bv.parent_entity_id
     ENDIF
    WITH nocounter
   ;end select
   SET stat = alterlist(bedrock_prefs->case_mgr,case_mgr_cnt)
   IF (case_mgr_cnt=0)
    IF (uar_get_code_by("MEANING",331,"LIFECASEMGR") > 0)
     SET case_mgr_cnt += 1
     SET stat = alterlist(bedrock_prefs->case_mgr,case_mgr_cnt)
     SET bedrock_prefs->case_mgr[case_mgr_cnt].case_mgr_cd = uar_get_code_by("MEANING",331,
      "LIFECASEMGR")
    ENDIF
    IF (uar_get_code_by("MEANING",331,"CMADMIN") > 0)
     SET case_mgr_cnt += 1
     SET stat = alterlist(bedrock_prefs->case_mgr,case_mgr_cnt)
     SET bedrock_prefs->case_mgr[case_mgr_cnt].case_mgr_cd = uar_get_code_by("MEANING",331,"CMADMIN")
    ENDIF
    IF (uar_get_code_by("MEANING",331,"CMASSIST") > 0)
     SET case_mgr_cnt += 1
     SET stat = alterlist(bedrock_prefs->case_mgr,case_mgr_cnt)
     SET bedrock_prefs->case_mgr[case_mgr_cnt].case_mgr_cd = uar_get_code_by("MEANING",331,"CMASSIST"
      )
    ENDIF
    IF (uar_get_code_by("MEANING",331,"CASEMGMTPROV") > 0)
     SET case_mgr_cnt += 1
     SET stat = alterlist(bedrock_prefs->case_mgr,case_mgr_cnt)
     SET bedrock_prefs->case_mgr[case_mgr_cnt].case_mgr_cd = uar_get_code_by("MEANING",331,
      "CASEMGMTPROV")
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE getflexid(position_cd)
   CALL log_message("Begin GetFlexId()",log_level_debug)
   DECLARE begin_time = f8 WITH constant(curtime3), private
   DECLARE flex_id = f8 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM br_datamart_flex bdf
    WHERE bdf.parent_entity_id=position_cd
     AND bdf.parent_entity_type_flag=1
     AND bdf.grouper_ind=0
     AND bdf.grouper_flex_id=0.0
    HEAD bdf.br_datamart_flex_id
     flex_id = bdf.br_datamart_flex_id
    WITH nocounter
   ;end select
   CALL log_message(build2("Exit GetFlexId(), Elapsed time:",cnvtint((curtime3 - begin_time)),"0 ms"),
    log_level_debug)
   RETURN(flex_id)
 END ;Subroutine
 SUBROUTINE getcategoryid(category_mean)
   CALL log_message("Begin GetCategoryId()",log_level_debug)
   DECLARE begin_time = f8 WITH constant(curtime3), private
   DECLARE category_id = f8 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM br_datamart_category bdc
    WHERE bdc.category_mean=category_mean
     AND bdc.category_type_flag=1
    HEAD bdc.br_datamart_category_id
     category_id = bdc.br_datamart_category_id
    WITH nocounter
   ;end select
   CALL log_message(build2("Exit GetCategoryId(), Elapsed time:",cnvtint((curtime3 - begin_time)),
     "0 ms"),log_level_debug)
   RETURN(category_id)
 END ;Subroutine
 SUBROUTINE (retrieveassociatedorganizations(user_id=f8) =null)
   CALL log_message("Begin RetrieveAssociatedOrganizations()",log_level_debug)
   DECLARE begin_time = f8 WITH constant(curtime3), private
   DECLARE org_count = i4 WITH protect, constant(size(sac_org->organizations,5))
   IF (org_count > 0)
    DECLARE expand_start = i4 WITH protect, noconstant(1)
    DECLARE expand_stop = i4 WITH protect, noconstant(50)
    DECLARE expand_size = i4 WITH constant(50)
    DECLARE expand_total = i4 WITH protect, noconstant(0)
    DECLARE index = i4 WITH protect, noconstant(0)
    DECLARE idx = i4 WITH protect, noconstant(0)
    SET expand_total = (ceil((cnvtreal(org_count)/ expand_size)) * expand_size)
    SET stat = alterlist(sac_org->organizations,expand_total)
    FOR (index = (org_count+ 1) TO expand_total)
      SET sac_org->organizations[index].organization_id = sac_org->organizations[org_count].
      organization_id
    ENDFOR
    SELECT DISTINCT INTO "nl:"
     FROM (dummyt d  WITH seq = value((expand_total/ expand_size))),
      organization org
     PLAN (d
      WHERE assign(expand_start,evaluate(d.seq,1,1,(expand_start+ expand_size)))
       AND assign(expand_stop,(expand_start+ (expand_size - 1))))
      JOIN (org
      WHERE expand(idx,expand_start,expand_stop,org.organization_id,sac_org->organizations[idx].
       organization_id)
       AND org.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND org.end_effective_dt_tm >= cnvtdatetime(sysdate)
       AND org.active_ind=1)
     ORDER BY org.organization_id
     HEAD REPORT
      org_cnt = 0
     DETAIL
      org_cnt += 1
      IF (mod(org_cnt,100)=1)
       stat = alterlist(user_orgs->organizations,(org_cnt+ 99))
      ENDIF
      user_orgs->organizations[org_cnt].organization_id = org.organization_id
     FOOT REPORT
      stat = alterlist(user_orgs->organizations,org_cnt)
     WITH nocounter
    ;end select
   ENDIF
   SET errcode = error(errmsg,0)
   IF (errcode != 0)
    SET failed = 1
    SET fail_operation = "RetrieveAssociatedOrganizations"
    CALL replyfailure("SELECT")
   ENDIF
   CALL log_message(build2("Exit RetrieveAssociatedOrganizations(), Elapsed time:",cnvtint((curtime3
       - begin_time)),"0 ms"),log_level_debug)
 END ;Subroutine
 SUBROUTINE (formatphonenumber(phonenumber=vc,phoneformatcode=f8) =vc)
   CALL log_message("In FormatPhoneNumber()",log_level_debug)
   DECLARE begin_time = f8 WITH constant(curtime3), private
   DECLARE temp_phone = vc WITH noconstant(""), protect
   DECLARE format_phone = vc WITH noconstant(""), protect
   SET temp_phone = cnvtalphanum(phonenumber)
   IF (temp_phone != phonenumber)
    SET format_phone = phonenumber
   ELSE
    IF (phoneformatcode > 0)
     SET format_phone = cnvtphone(trim(phonenumber),phoneformatcode)
    ELSEIF (size(temp_phone) < 8)
     SET format_phone = format(temp_phone,"###-####")
    ELSE
     SET format_phone = format(temp_phone,"(###) ###-####")
    ENDIF
   ENDIF
   IF (size(format_phone) <= 0)
    SET format_phone = phonenumber
   ENDIF
   CALL log_message(build2("Exit FormatPhoneNumber(), Elapsed time:",cnvtint((curtime3 - begin_time)),
     "0 ms"),log_level_debug)
   RETURN(format_phone)
 END ;Subroutine
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
 SET modify maxvarlen 52428800
 CALL log_message("In dcp_acm_retrieve_filter_values",log_level_debug)
 DECLARE retrievebarriers(null) = null
 DECLARE retrieveproblems(null) = null
 DECLARE retrievediagnosis(null) = null
 DECLARE retrievemeasures(null) = null
 DECLARE replyfailure(null) = null
 DECLARE cnvtcclrec(null) = null
 DECLARE user_logical_domain_id = f8 WITH noconstant(0)
 DECLARE requested_filters_cnt = i4 WITH noconstant(0)
 DECLARE count = i4 WITH noconstant(0)
 DECLARE code_set = f8 WITH noconstant(0.0)
 DECLARE table_exists_with_access = i2 WITH constant(2), protect
 DECLARE fail_operation = vc
 DECLARE failed = i2 WITH noconstant(0)
 DECLARE dwl_category_id = f8 WITH noconstant(0.0)
 DECLARE pos_flex_id = f8 WITH noconstant(0.0)
 DECLARE system_flex_id = f8 WITH noconstant(0.0)
 SET dwl_category_id = getcategoryid(dwl_category_mean)
 SET pos_flex_id = getflexid(filter_request->pos_cd)
 SET system_flex_id = getflexid(0.0)
 SET reply->status_data.status = "Z"
 SET reply->query_type_cd = filter_request->query_type_cd
 SET errmsg = fillstring(132," ")
 SET errcode = error(errmsg,1)
 SELECT INTO "nl:"
  FROM prsnl p
  WHERE (p.person_id=filter_request->user_id)
  DETAIL
   user_logical_domain_id = p.logical_domain_id
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,0)
 IF (errcode != 0)
  SET failed = 1
  SET fail_operation = "Logical domain select"
  CALL replyfailure("SELECT")
 ENDIF
 SET requested_filters_cnt = size(filter_request->filter_list,5)
 IF (requested_filters_cnt > 0)
  SET stat = alterlist(reply->filter_list,requested_filters_cnt)
 ENDIF
 IF (checkdic("ENCNTR_CMNTY_CASE","T",0)=table_exists_with_access)
  SELECT INTO "nl:"
   rows = count(ecc.encntr_cmnty_case_id)
   FROM encntr_cmnty_case ecc
   HEAD REPORT
    IF (rows > 0)
     reply->case_status_flag = 1
    ELSE
     reply->case_status_flag = 0
    ENDIF
   WITH nocounter, maxqual(ecc,1)
  ;end select
  SET errcode = error(errmsg,0)
  IF (errcode != 0)
   SET failed = 1
   SET fail_operation = "Determine Case Status Usage"
   CALL replyfailure("SELECT")
  ENDIF
 ENDIF
 FOR (count = 1 TO requested_filters_cnt)
   SET reply->filter_list[count].argument_name = filter_request->filter_list[count].argument_name
   IF ((((filter_request->filter_list[count].argument_name=argname_pprcode)) OR ((((filter_request->
   filter_list[count].argument_name=argname_eprcode)) OR ((((filter_request->filter_list[count].
   argument_name=argname_race)) OR ((((filter_request->filter_list[count].argument_name=
   argname_gender)) OR ((((filter_request->filter_list[count].argument_name=argname_language)) OR (((
   (filter_request->filter_list[count].argument_name=argname_healthplan)) OR ((((filter_request->
   filter_list[count].argument_name=argname_financialclass)) OR ((((filter_request->filter_list[count
   ].argument_name=argname_confidlevel)) OR ((((filter_request->filter_list[count].argument_name=
   argname_orderstatus)) OR ((filter_request->filter_list[count].argument_name=argname_casestatus)
    AND (reply->case_status_flag=1))) )) )) )) )) )) )) )) )) )
    SET code_set = getcodeset(filter_request->filter_list[count].argument_name)
    IF (code_set > 0.0)
     SET reply->filter_list[count].code_set = code_set
     CALL retrievecodevalues(code_set,count)
    ENDIF
   ENDIF
   CASE (filter_request->filter_list[count].argument_name)
    OF argname_acmgroup:
     IF (size(user_orgs->organizations,5) <= 0)
      CALL retrieveassociatedorganizations(filter_request->user_id)
     ENDIF
     CALL retrieveacmgroups(count)
    OF argname_condition:
     CALL retrieveconsequentnames(null)
     CALL retrieveconditions(count)
    OF argname_registry:
     CALL retrieveregistries(count)
    OF argname_encountertype:
     CALL retrieveencountertypefrombedrock(count)
    OF argname_apptstatus:
     CALL retrieveappointmentstatuses(count)
    OF argname_ordersstatus:
     CALL retrieveorderstatuses(count)
    OF argname_expectations:
     CALL retrieveexpectations(count)
    OF argname_risk:
     CALL retrieverisklevels(count)
    OF argname_communicate_pref:
     CALL retrievecommunicationprefs(count)
    OF argname_pending_work:
     CALL retrievependingworktypes(count)
    OF argname_locations:
     IF (size(user_orgs->organizations,5) <= 0)
      CALL retrieveassociatedorganizations(null)
     ENDIF
     CALL retrievefacilities(count)
   ENDCASE
 ENDFOR
 GO TO exit_script
#exit_script
 IF ((reply->status_data.status="Z"))
  SET reply->status_data.status = "S"
 ENDIF
 CALL echo(failed)
 IF (failed=0)
  CALL cnvtcclrec(null)
 ENDIF
 SUBROUTINE (saveavailablevalue(idx_filter=i4,idx_val=i4,arg_val=vc,arg_mean=vc,arg_type=vc,
  parent_name=vc,parent_id=f8) =null)
   CALL log_message("Begin SaveAvailableValue()",log_level_debug)
   IF (arg_val != null)
    SET reply->filter_list[idx_filter].available_values[idx_val].argument_value = arg_val
   ENDIF
   IF (arg_mean != null)
    SET reply->filter_list[idx_filter].available_values[idx_val].argument_meaning = arg_mean
   ENDIF
   IF (arg_type != null)
    SET reply->filter_list[idx_filter].available_values[idx_val].argument_type = arg_type
   ENDIF
   IF (parent_name != null)
    SET reply->filter_list[idx_filter].available_values[idx_val].parent_entity_name = parent_name
   ENDIF
   IF (parent_id != null)
    SET reply->filter_list[idx_filter].available_values[idx_val].parent_entity_id = parent_id
   ENDIF
   CALL log_message("Exit SaveAvailableValue()",log_level_debug)
 END ;Subroutine
 SUBROUTINE (retrieverisklevels(filter_cnt=i4) =null)
   CALL log_message("In RetrieveRiskLevels()",log_level_debug)
   DECLARE begin_time = f8 WITH constant(curtime3), private
   IF (checkdic("LH_CNT_READMIT_RISK","T",0)=table_exists_with_access)
    DECLARE risk_cnt = i4 WITH private, noconstant(0)
    SET reply->risk_flag = 0
    SELECT DISTINCT
     lh.risk_factor_txt
     FROM lh_cnt_readmit_risk lh
     WHERE lh.active_ind=1
      AND lh.risk_factor_flag=5
      AND lh.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND lh.end_effective_dt_tm >= cnvtdatetime(sysdate)
     ORDER BY lh.risk_factor_txt
     HEAD REPORT
      reply->risk_flag = 1, risk_cnt = 0
     DETAIL
      risk_cnt += 1
      IF (mod(risk_cnt,20)=1)
       stat = alterlist(reply->filter_list[filter_cnt].available_values,(risk_cnt+ 19))
      ENDIF
      reply->filter_list[filter_cnt].available_values[risk_cnt].argument_value = lh.risk_factor_txt,
      reply->filter_list[filter_cnt].available_values[risk_cnt].parent_entity_id = risk_cnt, reply->
      filter_list[filter_cnt].available_values[risk_cnt].parent_entity_name = "RISK_VALUE"
     FOOT REPORT
      stat = alterlist(reply->filter_list[filter_cnt].available_values,risk_cnt)
     WITH nocounter
    ;end select
    SET errcode = error(errmsg,0)
    IF (errcode != 0)
     SET failed = 1
     SET fail_operation = "RetrieveRiskLevels"
     CALL replyfailure("SELECT")
    ENDIF
   ELSE
    CALL log_message("Table lh_cnt_readmit_risk does not exist.",log_level_debug)
   ENDIF
   CALL log_message(build2("Exit RetrieveRiskLevels(), Elapsed time:",cnvtint((curtime3 - begin_time)
      ),"0 ms"),log_level_debug)
 END ;Subroutine
 SUBROUTINE replyfailure(targetobjname)
   CALL log_message("In replyFailure()",log_level_debug)
   DECLARE begin_time = f8 WITH constant(curtime3), private
   CALL log_message(build2("Error: ",targetobjname," - ",trim(errmsg)),log_level_error)
   ROLLBACK
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = fail_operation
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = targetobjname
   SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
   CALL cnvtcclrec(null)
   CALL log_message(build2("Exit replyFailure(), Elapsed time:",cnvtint((curtime3 - begin_time)),
     "0 ms"),log_level_debug)
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE cnvtcclrec(null)
   CALL log_message("In CnvtCCLRec()",log_level_debug)
   DECLARE begin_time = f8 WITH constant(curtime3), private
   DECLARE strjson = vc
   SET strjson = cnvtrectojson(reply)
   SET _memory_reply_string = strjson
   CALL log_message(build2("Exit CnvtCCLRec(), Elapsed time:",cnvtint((curtime3 - begin_time)),"0 ms"
     ),log_level_debug)
 END ;Subroutine
 SUBROUTINE (getcodeset(argument_name=vc) =f8)
   CALL log_message("Begin GetCodeSet()",log_level_debug)
   DECLARE begin_time = f8 WITH constant(curtime3), private
   DECLARE return_value = f8
   CASE (argument_name)
    OF argname_pprcode:
     SET return_value = 331
    OF argname_eprcode:
     SET return_value = 333
    OF argname_race:
     SET return_value = 282
    OF argname_gender:
     SET return_value = 57
    OF argname_language:
     SET return_value = 36
    OF argname_healthplan:
     SET return_value = 367
    OF argname_financialclass:
     SET return_value = 354
    OF argname_confidlevel:
     SET return_value = 87
    OF argname_orderstatus:
     SET return_value = 6004
    OF argname_casestatus:
     SET return_value = 4003310
    ELSE
     SET return_value = 0
   ENDCASE
   CALL log_message(build2("Exit GetCodeSet(), Elapsed time:",cnvtint((curtime3 - begin_time)),"0 ms"
     ),log_level_debug)
   RETURN(return_value)
 END ;Subroutine
 SUBROUTINE (retrievefacilities(filter_cnt=i4) =null)
   CALL log_message("Begin RetrieveFacilities()",log_level_debug)
   DECLARE begin_time = f8 WITH constant(curtime3), private
   DECLARE deleted_type_cd = f8 WITH constant(uar_get_code_by("MEANING",48,"DELETED")), protect
   DECLARE facility_type_cd = f8 WITH constant(uar_get_code_by("MEANING",222,"FACILITY")), protect
   DECLARE exp_cnt = i4 WITH noconstant(0), protect
   DECLARE loc_cnt = i4 WITH noconstant(0), protect
   SELECT DISTINCT INTO "nl:"
    l.location_cd, cv.display
    FROM location l,
     location_group lg,
     code_value cv
    PLAN (l
     WHERE expand(exp_cnt,1,size(user_orgs->organizations,5),l.organization_id,user_orgs->
      organizations[exp_cnt].organization_id)
      AND l.location_type_cd=facility_type_cd
      AND l.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND l.end_effective_dt_tm >= cnvtdatetime(sysdate)
      AND l.active_ind=1)
     JOIN (lg
     WHERE lg.parent_loc_cd=l.location_cd
      AND lg.root_loc_cd=0
      AND lg.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND lg.end_effective_dt_tm >= cnvtdatetime(sysdate)
      AND lg.active_ind=1)
     JOIN (cv
     WHERE cv.code_value=l.location_cd
      AND cv.active_ind=1
      AND cv.active_type_cd != deleted_type_cd)
    ORDER BY cv.collation_seq, cv.display_key, l.location_cd
    DETAIL
     loc_cnt += 1
     IF (mod(loc_cnt,100)=1)
      stat = alterlist(reply->filter_list[filter_cnt].available_values,(loc_cnt+ 99))
     ENDIF
     reply->filter_list[filter_cnt].available_values[loc_cnt].argument_value = cv.display, reply->
     filter_list[filter_cnt].available_values[loc_cnt].parent_entity_id = l.location_cd, reply->
     filter_list[filter_cnt].available_values[loc_cnt].parent_entity_name = "CODE_VALUE"
    FOOT REPORT
     stat = alterlist(reply->filter_list[filter_cnt].available_values,loc_cnt)
    WITH nocounter, expand = 1
   ;end select
   SET errcode = error(errmsg,0)
   IF (errcode != 0)
    SET failed = 1
    SET fail_operation = "RetrieveFacilities"
    CALL replyfailure("SELECT")
   ENDIF
   CALL log_message(build2("Exit RetrieveFacilities(), Elapsed time:",cnvtint((curtime3 - begin_time)
      ),"0 ms"),log_level_debug)
 END ;Subroutine
 SUBROUTINE (retrieveacmgroups(filter_cnt=i4) =null)
   CALL log_message("Begin RetrieveACMGroups()",log_level_debug)
   DECLARE begin_time = f8 WITH constant(curtime3), private
   DECLARE expandindex = i4 WITH private, noconstant(0)
   DECLARE expcnt = i4
   DECLARE findindex = i4 WITH private, noconstant(0)
   DECLARE locatedval = i4 WITH private, noconstant(0)
   DECLARE prsnlgroupcd = f8 WITH constant(uar_get_code_by("MEANING",19189,"AMBCAREGRP"))
   DECLARE group_cnt = i4 WITH private, noconstant(0)
   DECLARE prov_cnt = i4 WITH private, noconstant(0)
   DECLARE skipdetail = i2 WITH noconstant(0)
   IF (prsnlgroupcd > 0.0)
    SELECT INTO "nl:"
     FROM prsnl_group pg,
      prsnl_group_reltn pgr2,
      prsnl p2
     PLAN (pg
      WHERE pg.prsnl_group_class_cd=prsnlgroupcd
       AND pg.active_ind=1
       AND pg.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND pg.end_effective_dt_tm >= cnvtdatetime(sysdate)
       AND pg.prsnl_group_id IN (
      (SELECT
       pgor.prsnl_group_id
       FROM prsnl_group_org_reltn pgor
       WHERE pgor.prsnl_group_id=pg.prsnl_group_id
        AND expand(expcnt,1,size(user_orgs->organizations,5),pgor.organization_id,user_orgs->
        organizations[expcnt].organization_id))))
      JOIN (pgr2
      WHERE pg.prsnl_group_id=pgr2.prsnl_group_id
       AND pgr2.active_ind=1
       AND pgr2.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND pgr2.end_effective_dt_tm >= cnvtdatetime(sysdate)
       AND  NOT ( EXISTS (
      (SELECT
       p3.logical_domain_id
       FROM prsnl p3,
        prsnl_group_reltn pgr3
       WHERE pgr3.prsnl_group_id=pgr2.prsnl_group_id
        AND pgr3.person_id=p3.person_id
        AND p3.logical_domain_id != user_logical_domain_id
        AND p3.active_ind=1))))
      JOIN (p2
      WHERE pgr2.person_id=p2.person_id
       AND p2.active_ind=1
       AND p2.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND p2.end_effective_dt_tm >= cnvtdatetime(sysdate))
     ORDER BY pg.prsnl_group_id
     HEAD REPORT
      group_cnt = 0
     HEAD pg.prsnl_group_id
      skipdetail = 1
      IF (uar_get_code_set(pg.prsnl_group_type_cd)=357)
       skipdetail = 0, group_cnt += 1, prov_cnt = 0
       IF (mod(group_cnt,20)=1)
        stat = alterlist(reply->filter_list[filter_cnt].available_values,(group_cnt+ 19))
       ENDIF
       reply->filter_list[filter_cnt].available_values[group_cnt].argument_value = pg
       .prsnl_group_name, reply->filter_list[filter_cnt].available_values[group_cnt].parent_entity_id
        = pg.prsnl_group_id, reply->filter_list[filter_cnt].available_values[group_cnt].
       parent_entity_name = "PRSNL_GROUP"
      ENDIF
     DETAIL
      IF (skipdetail=0)
       prov_cnt += 1
       IF (mod(prov_cnt,20)=1)
        stat = alterlist(reply->filter_list[filter_cnt].available_values[group_cnt].child_values,(
         prov_cnt+ 19))
       ENDIF
       reply->filter_list[filter_cnt].available_values[group_cnt].child_values[prov_cnt].
       argument_value = p2.name_full_formatted, reply->filter_list[filter_cnt].available_values[
       group_cnt].child_values[prov_cnt].parent_entity_id = pgr2.person_id, reply->filter_list[
       filter_cnt].available_values[group_cnt].child_values[prov_cnt].parent_entity_name = "PRSNL"
      ENDIF
     FOOT  pg.prsnl_group_id
      IF (skipdetail=0)
       stat = alterlist(reply->filter_list[filter_cnt].available_values[group_cnt].child_values,
        prov_cnt)
      ENDIF
     FOOT REPORT
      stat = alterlist(reply->filter_list[filter_cnt].available_values,group_cnt)
     WITH nocounter, expand = 1
    ;end select
   ENDIF
   SET errcode = error(errmsg,0)
   IF (errcode != 0)
    SET failed = 1
    SET fail_operation = "RetrieveACMGroups"
    CALL replyfailure("SELECT")
   ENDIF
   CALL log_message(build2("Exit RetrieveACMGroups(), Elapsed time:",cnvtint((curtime3 - begin_time)),
     "0 ms","RetrieveACMGroups found ",group_cnt),log_level_debug)
 END ;Subroutine
 SUBROUTINE (retrievecommunicationprefs(filter_cnt=i4) =null)
   CALL log_message("Begin RetrieveCommunicationPrefs()",log_level_debug)
   DECLARE begin_time = f8 WITH constant(curtime3), private
   DECLARE patientportal_cd = f8 WITH constant(uar_get_code_by("MEANING",23042,"PATPORTAL")), protect
   DECLARE nopreference_cd = f8 WITH constant(uar_get_code_by("MEANING",23042,"NOPREFERENCE")),
   protect
   DECLARE letter_cd = f8 WITH constant(uar_get_code_by("MEANING",23042,"LETTER")), protect
   DECLARE telephone_cd = f8 WITH constant(uar_get_code_by("MEANING",23042,"TELEPHONE")), protect
   DECLARE cv_cnt = i4 WITH noconstant(0), private
   DECLARE i18n_handle = i4 WITH noconstant(0), private
   DECLARE h = i4 WITH noconstant(uar_i18nlocalizationinit(i18n_handle,curprog,"",curcclrev)),
   protect
   DECLARE i18n_unknown = vc WITH constant(uar_i18ngetmessage(i18n_handle,"i18n_key_Unknown",
     "Unknown")), private
   DECLARE stat = i4 WITH noconstant(0), protect
   DECLARE code_cnt = i2 WITH constant(5)
   SET stat = alterlist(reply->filter_list[filter_cnt].available_values,code_cnt)
   IF (letter_cd > 0)
    SET cv_cnt += 1
    SET reply->filter_list[filter_cnt].available_values[cv_cnt].argument_value = uar_get_code_display
    (letter_cd)
    SET reply->filter_list[filter_cnt].available_values[cv_cnt].argument_meaning = "LETTER"
    SET reply->filter_list[filter_cnt].available_values[cv_cnt].parent_entity_id = letter_cd
    SET reply->filter_list[filter_cnt].available_values[cv_cnt].parent_entity_name = "CODE_VALUE"
   ENDIF
   IF (nopreference_cd > 0)
    SET cv_cnt += 1
    SET reply->filter_list[filter_cnt].available_values[cv_cnt].argument_value = uar_get_code_display
    (nopreference_cd)
    SET reply->filter_list[filter_cnt].available_values[cv_cnt].argument_meaning = "NOPREFERENCE"
    SET reply->filter_list[filter_cnt].available_values[cv_cnt].parent_entity_id = nopreference_cd
    SET reply->filter_list[filter_cnt].available_values[cv_cnt].parent_entity_name = "CODE_VALUE"
   ENDIF
   IF (patientportal_cd > 0)
    SET cv_cnt += 1
    SET reply->filter_list[filter_cnt].available_values[cv_cnt].argument_value = uar_get_code_display
    (patientportal_cd)
    SET reply->filter_list[filter_cnt].available_values[cv_cnt].argument_meaning = "PATPORTAL"
    SET reply->filter_list[filter_cnt].available_values[cv_cnt].parent_entity_id = patientportal_cd
    SET reply->filter_list[filter_cnt].available_values[cv_cnt].parent_entity_name = "CODE_VALUE"
   ENDIF
   IF (telephone_cd > 0)
    SET cv_cnt += 1
    SET reply->filter_list[filter_cnt].available_values[cv_cnt].argument_value = uar_get_code_display
    (telephone_cd)
    SET reply->filter_list[filter_cnt].available_values[cv_cnt].argument_meaning = "TELEPHONE"
    SET reply->filter_list[filter_cnt].available_values[cv_cnt].parent_entity_id = telephone_cd
    SET reply->filter_list[filter_cnt].available_values[cv_cnt].parent_entity_name = "CODE_VALUE"
   ENDIF
   SET cv_cnt += 1
   SET reply->filter_list[filter_cnt].available_values[cv_cnt].argument_value = i18n_unknown
   SET reply->filter_list[filter_cnt].available_values[cv_cnt].argument_meaning = "UNKNOWN"
   SET reply->filter_list[filter_cnt].available_values[cv_cnt].parent_entity_id = 0
   SET reply->filter_list[filter_cnt].available_values[cv_cnt].parent_entity_name = "COMM_PREF_NULL"
   SET stat = alterlist(reply->filter_list[filter_cnt].available_values,cv_cnt)
   CALL log_message(build2("Exit RetrieveCommunicationPrefs(), Elapsed time:",cnvtint((curtime3 -
      begin_time)),"0 ms","RetrieveCommunicationPrefs found ",cv_cnt,
     " communication preferences"),log_level_debug)
 END ;Subroutine
 SUBROUTINE (retrievependingworktypes(filter_cnt=i4) =null)
   CALL log_message("Begin RetrievePendingWorkTypes()",log_level_debug)
   DECLARE begin_time = f8 WITH constant(curtime3), private
   DECLARE type_cnt = i2 WITH noconstant(0), private
   DECLARE code_cnt = i2 WITH constant(5), private
   DECLARE i18n_handle = i4 WITH noconstant(0), private
   DECLARE h = i4 WITH noconstant(uar_i18nlocalizationinit(i18n_handle,curprog,"",curcclrev)),
   private
   DECLARE pending_actions = vc WITH constant(uar_i18ngetmessage(i18n_handle,
     "i18n_key_PendingActions","My Pending Actions")), priva
   DECLARE pending_phone_calls = vc WITH constant(uar_i18ngetmessage(i18n_handle,
     "i18n_key_PendingCalls","Pending Phone Calls")), pr
   SET stat = alterlist(reply->filter_list[filter_cnt].available_values,code_cnt)
   SET type_cnt += 1
   SET reply->filter_list[filter_cnt].available_values[type_cnt].argument_value = pending_actions
   SET reply->filter_list[filter_cnt].available_values[type_cnt].argument_meaning = "PENDING_ACTIONS"
   SET type_cnt += 1
   SET reply->filter_list[filter_cnt].available_values[type_cnt].argument_value = pending_phone_calls
   SET reply->filter_list[filter_cnt].available_values[type_cnt].argument_meaning =
   "PENDING_PHONE_CALLS"
   SET stat = alterlist(reply->filter_list[filter_cnt].available_values,type_cnt)
   CALL log_message(build2("Exit RetrievePendingWorkTypes(), Elapsed time:",cnvtint((curtime3 -
      begin_time)),"0 ms","RetrievePendingWorkTypes found ",type_cnt,
     " pending work types"),log_level_debug)
 END ;Subroutine
 SUBROUTINE (retrievecodevalues(code_set_num=f8,filter_cnt=i4) =null)
   CALL log_message("Begin RetrieveCodeValues()",log_level_debug)
   DECLARE begin_time = f8 WITH constant(curtime3), private
   DECLARE cv_cnt = i4 WITH private, noconstant(0)
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=code_set_num
     AND cv.active_ind=1
    ORDER BY cv.code_set, cv.code_value
    HEAD REPORT
     cv_cnt = 0
    HEAD cv.code_value
     cv_cnt += 1
     IF (mod(cv_cnt,20)=1)
      stat = alterlist(reply->filter_list[filter_cnt].available_values,(cv_cnt+ 19))
     ENDIF
     reply->filter_list[filter_cnt].available_values[cv_cnt].argument_value = cv.display, reply->
     filter_list[filter_cnt].available_values[cv_cnt].argument_meaning = cv.cdf_meaning, reply->
     filter_list[filter_cnt].available_values[cv_cnt].parent_entity_id = cv.code_value,
     reply->filter_list[filter_cnt].available_values[cv_cnt].parent_entity_name = "CODE_VALUE"
    FOOT REPORT
     stat = alterlist(reply->filter_list[filter_cnt].available_values,cv_cnt)
    WITH nocounter
   ;end select
   SET errcode = error(errmsg,0)
   IF (errcode != 0)
    SET failed = 1
    SET fail_operation = "RetrieveCodeValues"
    CALL replyfailure("SELECT")
   ENDIF
   CALL log_message(build2("Exit RetrieveCodeValues(), Elapsed time:",cnvtint((curtime3 - begin_time)
      ),"0 ms","RetrieveCodeValues found ",cv_cnt,
     " items for code set ",code_set_num),log_level_debug)
 END ;Subroutine
 SUBROUTINE (retrieveconditions(filter_cnt=i4) =null)
   CALL log_message("Begin RetrieveConditions()",log_level_debug)
   DECLARE begin_time = f8 WITH constant(curtime3), private
   DECLARE conditionindex = i4 WITH noconstant(0), private
   DECLARE ruleindex = i4 WITH noconstant(0), private
   DECLARE num = i4 WITH noconstant(0)
   DECLARE rulename = vc WITH noconstant("")
   SELECT INTO "nl:"
    FROM ac_class_def c,
     ac_class_he_rule r
    PLAN (c
     WHERE c.class_type_flag=2
      AND c.active_ind=1
      AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime)
      AND c.end_effective_dt_tm > cnvtdatetime(curdate,curtime)
      AND c.logical_domain_id=user_logical_domain_id
      AND c.ac_class_def_id > 0)
     JOIN (r
     WHERE ((r.ac_class_def_id=c.ac_class_def_id) OR (r.ac_class_he_rule_id=0)) )
    ORDER BY c.ac_class_def_id
    HEAD REPORT
     conditionindex = 0
    HEAD c.ac_class_def_id
     ruleindex = 0, conditionindex += 1
     IF (mod(conditionindex,20)=1)
      stat = alterlist(reply->filter_list[filter_cnt].available_values,(conditionindex+ 19))
     ENDIF
     reply->filter_list[filter_cnt].available_values[conditionindex].argument_value = c
     .class_display_name, reply->filter_list[filter_cnt].available_values[conditionindex].
     parent_entity_id = c.ac_class_def_id, reply->filter_list[filter_cnt].available_values[
     conditionindex].parent_entity_name = "AC_CLASS_DEF"
    DETAIL
     IF (r.ac_class_he_rule_id > 0
      AND r.health_expert_rule_txt != "")
      rulename = r.health_expert_rule_txt, pos = locateval(num,1,size(rule_consq_map->rule_list,5),
       rulename,rule_consq_map->rule_list[num].name)
      IF (pos > 0)
       consqindex = 0, newconsqsize = size(rule_consq_map->rule_list[pos].consq_list,5),
       existingconsqsize = size(reply->filter_list[filter_cnt].available_values[conditionindex].
        child_values,5),
       stat = alterlist(reply->filter_list[filter_cnt].available_values[conditionindex].child_values,
        (existingconsqsize+ newconsqsize))
       FOR (consqindex = 1 TO newconsqsize)
         reply->filter_list[filter_cnt].available_values[conditionindex].child_values[(consqindex+
         existingconsqsize)].argument_value = rule_consq_map->rule_list[pos].consq_list[consqindex].
         name, reply->filter_list[filter_cnt].available_values[conditionindex].child_values[(
         consqindex+ existingconsqsize)].parent_entity_name = "AC_CLASS_HE_RULE", reply->filter_list[
         filter_cnt].available_values[conditionindex].child_values[(consqindex+ existingconsqsize)].
         parent_entity_id = r.ac_class_he_rule_id
       ENDFOR
      ELSE
       CALL echo("could not find rule to match name saved in bedrock.")
      ENDIF
     ENDIF
    FOOT REPORT
     stat = alterlist(reply->filter_list[filter_cnt].available_values,conditionindex)
    WITH nocounter
   ;end select
   SET errcode = error(errmsg,0)
   IF (errcode != 0)
    SET failed = 1
    SET fail_operation = "RetrieveConditions"
    CALL replyfailure("SELECT")
   ENDIF
   CALL log_message(build2("Exit RetrieveConditions(), Elapsed time:",cnvtint((curtime3 - begin_time)
      ),"0 ms","RetrieveConditions found ",conditionindex),log_level_debug)
 END ;Subroutine
 SUBROUTINE (retrieveconsequentnames(null=i4) =null)
   CALL log_message("Begin RetrieveConsequentNames()",log_level_debug)
   DECLARE begin_time = f8 WITH constant(curtime3), private
   DECLARE hrule = i4 WITH noconstant(0), private
   DECLARE hconsq = i4 WITH noconstant(0), private
   DECLARE hparam = i4 WITH noconstant(0), private
   DECLARE hvalue = i4 WITH noconstant(0), private
   DECLARE iret = i4 WITH noconstant(0), private
   DECLARE consqvaluecnt = i4 WITH noconstant(0), private
   EXECUTE srvrtl
   SET hmsg = uar_srvselectmessage(966721)
   SET hrequest = uar_srvcreaterequest(hmsg)
   SET hreply = uar_srvcreatereply(hmsg)
   SET iret = uar_srvsetstring(hrequest,"rule_group_name","Conditions")
   SET stat = uar_srvexecute(hmsg,hrequest,hreply)
   CALL echo(build2("HRecommendation Server: SRV Perform, Status:",stat))
   IF (stat > 0)
    CALL uar_srvdestroyinstance(hreply)
    CALL uar_srvdestroyinstance(hrequest)
    SET failed = 1
    SET fail_operation = "HEALTH EXPERT REQUEST"
    CALL replyfailure("")
   ENDIF
   SET hstatus = uar_srvgetstruct(hreply,"status_data")
   SET status = uar_srvgetstringptr(hstatus,"status")
   SET statussize = uar_srvgetitemcount(hstatus,"subeventstatus")
   SET statuscount = 0
   FOR (statuscount = 0 TO statussize)
     SET hsubevent = uar_srvgetitem(hstatus,"subeventstatus",statuscount)
     SET stargetobjectname = uar_srvgetstringptr(hsubevent,"TargetObjectName")
     SET stargetobjectvalue = uar_srvgetstringptr(hsubevent,"TargetObjectValue")
     SET soperationname = uar_srvgetstringptr(hsubevent,"OperationName")
     SET soperationstatus = uar_srvgetstringptr(hsubevent,"OperationStatus")
     CALL echo(status)
     CALL echo(build("Target Object Name: ",stargetobjectname))
     CALL echo(build("Target Object Value: ",stargetobjectvalue))
     CALL echo(build("Operation Name: ",soperationname))
     CALL echo(build("Operation Status: ",soperationstatus))
   ENDFOR
   IF (status="F")
    CALL uar_srvdestroyinstance(hreply)
    CALL uar_srvdestroyinstance(hrequest)
    SET failed = 1
    SET fail_operation = "HEALTH EXPERT RETURN"
    CALL replyfailure("")
   ENDIF
   SET ruleiterator = 0
   SET rulecnt = uar_srvgetitemcount(hreply,"rules")
   CALL echo(build("found rules: ",rulecnt))
   SET stat = alterlist(rule_consq_map->rule_list,rulecnt)
   FOR (ruleiterator = 0 TO (rulecnt - 1))
     SET hrule = uar_srvgetitem(hreply,"rules",ruleiterator)
     SET rulename = uar_srvgetstringptr(hrule,"name")
     SET rule_consq_map->rule_list[(ruleiterator+ 1)].name = rulename
     SET consqcnt = uar_srvgetitemcount(hrule,"consequents")
     SET consqiterator = 0
     FOR (consqiterator = 0 TO (consqcnt - 1))
       SET hconsq = uar_srvgetitem(hrule,"consequents",consqiterator)
       SET paramcnt = uar_srvgetitemcount(hconsq,"parameters")
       SET paramiterator = 0
       SET consqvaluecnt = 0
       FOR (paramiterator = 0 TO (paramcnt - 1))
         SET hparam = uar_srvgetitem(hconsq,"parameters",paramiterator)
         SET valuecnt = uar_srvgetitemcount(hparam,"values")
         SET valueiterator = 0
         FOR (valueiterator = 0 TO (valuecnt - 1))
           SET hvalue = uar_srvgetitem(hparam,"values",valueiterator)
           SET consqvaluecnt += 1
           SET stat = alterlist(rule_consq_map->rule_list[(ruleiterator+ 1)].consq_list,consqvaluecnt
            )
           SET rule_consq_map->rule_list[(ruleiterator+ 1)].consq_list[consqvaluecnt].name =
           uar_srvgetstringptr(hvalue,"value")
         ENDFOR
       ENDFOR
     ENDFOR
   ENDFOR
   CALL echorecord(rule_consq_map)
   CALL log_message(build2("Exit RetrieveConsequentNames(), Elapsed time:",cnvtint((curtime3 -
      begin_time)),"0 ms","RetrieveConsequentNames found ",consqvaluecnt),log_level_debug)
 END ;Subroutine
 SUBROUTINE (retrieveregistries(filter_cnt=i4) =null)
   CALL log_message("Begin RetrieveRegistries()",log_level_debug)
   DECLARE begin_time = f8 WITH constant(curtime3), private
   DECLARE regcount = i4 WITH noconstant(0), private
   SELECT INTO "nl:"
    FROM ac_class_def cd
    WHERE cd.class_type_flag=1
     AND cd.active_ind=1
     AND cd.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime)
     AND cd.end_effective_dt_tm > cnvtdatetime(curdate,curtime)
     AND cd.logical_domain_id=user_logical_domain_id
     AND cd.ac_class_def_id > 0
    HEAD REPORT
     regcount = 0
    HEAD cd.ac_class_def_id
     regcount += 1
     IF (mod(regcount,20)=1)
      stat = alterlist(reply->filter_list[filter_cnt].available_values,(regcount+ 19))
     ENDIF
     reply->filter_list[filter_cnt].available_values[regcount].argument_value = cd.class_display_name,
     reply->filter_list[filter_cnt].available_values[regcount].parent_entity_id = cd.ac_class_def_id,
     reply->filter_list[filter_cnt].available_values[regcount].parent_entity_name = "AC_CLASS_DEF"
    FOOT REPORT
     stat = alterlist(reply->filter_list[filter_cnt].available_values,regcount)
    WITH nocounter
   ;end select
   SET errcode = error(errmsg,0)
   IF (errcode != 0)
    SET failed = 1
    SET fail_operation = "RetrieveRegistries"
    CALL replyfailure("SELECT")
   ENDIF
   CALL log_message(build2("Exit RetrieveRegistries(), Elapsed time:",cnvtint((curtime3 - begin_time)
      ),"0 ms","RetrieveRegistries found ",regcount),log_level_debug)
 END ;Subroutine
 SUBROUTINE (retrieveappointmentstatuses(filter_cnt=i4) =null)
   CALL log_message("Begin RetrieveAppointmentStatuses()",log_level_debug)
   DECLARE begin_time = f8 WITH constant(curtime3), private
   DECLARE custom_types_ind = i2 WITH noconstant(0)
   DECLARE value_count = i4 WITH noconstant(0)
   DECLARE flex_id_appt_status = f8 WITH noconstant(system_flex_id)
   SELECT INTO "nl:"
    cv_display = uar_get_code_display(bv.parent_entity_id)
    FROM br_datamart_filter bf,
     br_datamart_value bv
    PLAN (bf
     WHERE bf.br_datamart_category_id=dwl_category_id
      AND bf.filter_mean="APPOINTMENT_STATUS_STATUS")
     JOIN (bv
     WHERE bv.br_datamart_category_id=bf.br_datamart_category_id
      AND bv.br_datamart_filter_id=bf.br_datamart_filter_id
      AND bv.br_datamart_flex_id IN (pos_flex_id, system_flex_id)
      AND bv.parent_entity_name="CODE_VALUE"
      AND bv.logical_domain_id=0)
    ORDER BY bv.br_datamart_flex_id DESC, bv.updt_dt_tm
    HEAD cv_display
     IF (cv_display != "")
      IF (bv.br_datamart_flex_id=pos_flex_id
       AND flex_id_appt_status=system_flex_id)
       flex_id_appt_status = bv.br_datamart_flex_id
      ENDIF
      IF (bv.br_datamart_flex_id=flex_id_appt_status)
       value_count += 1
       IF (mod(value_count,20)=1)
        stat = alterlist(reply->filter_list[filter_cnt].available_values,(value_count+ 19))
       ENDIF
       custom_types_ind = 1, reply->filter_list[filter_cnt].available_values[value_count].
       argument_value = cv_display, reply->filter_list[filter_cnt].available_values[value_count].
       parent_entity_id = bv.parent_entity_id,
       reply->filter_list[filter_cnt].available_values[value_count].parent_entity_name = bv
       .parent_entity_name
      ENDIF
     ENDIF
    FOOT REPORT
     stat = alterlist(reply->filter_list[filter_cnt].available_values,value_count)
    WITH nocounter
   ;end select
   IF (errcode != 0)
    SET failed = 1
    SET fail_operation = "RetrieveAppointmentStatuses"
    CALL replyfailure("SELECT")
   ENDIF
   IF (custom_types_ind=0)
    SET stat = alterlist(reply->filter_list[filter_cnt].available_values,4)
    DECLARE canceled_cd = f8 WITH constant(uar_get_code_by("MEANING",14233,"CANCELED"))
    SET reply->filter_list[filter_cnt].available_values[1].argument_value = uar_get_code_display(
     canceled_cd)
    SET reply->filter_list[filter_cnt].available_values[1].parent_entity_id = canceled_cd
    SET reply->filter_list[filter_cnt].available_values[1].parent_entity_name = "CODE_VALUE"
    DECLARE noshow_cd = f8 WITH constant(uar_get_code_by("MEANING",14233,"NOSHOW"))
    SET reply->filter_list[filter_cnt].available_values[2].argument_value = uar_get_code_display(
     noshow_cd)
    SET reply->filter_list[filter_cnt].available_values[2].parent_entity_id = noshow_cd
    SET reply->filter_list[filter_cnt].available_values[2].parent_entity_name = "CODE_VALUE"
    DECLARE confirmed_cd = f8 WITH constant(uar_get_code_by("MEANING",14233,"CONFIRMED"))
    SET reply->filter_list[filter_cnt].available_values[3].argument_value = uar_get_code_display(
     confirmed_cd)
    SET reply->filter_list[filter_cnt].available_values[3].parent_entity_id = confirmed_cd
    SET reply->filter_list[filter_cnt].available_values[3].parent_entity_name = "CODE_VALUE"
    DECLARE scheduled_cd = f8 WITH constant(uar_get_code_by("MEANING",14233,"SCHEDULED"))
    SET reply->filter_list[filter_cnt].available_values[4].argument_value = uar_get_code_display(
     scheduled_cd)
    SET reply->filter_list[filter_cnt].available_values[4].parent_entity_id = scheduled_cd
    SET reply->filter_list[filter_cnt].available_values[4].parent_entity_name = "CODE_VALUE"
   ENDIF
   CALL log_message(build2("Exit RetrieveAppointmentStatuses(), Elapsed time:",cnvtint((curtime3 -
      begin_time)),"0 ms","RetrieveAppointmentStatuses found ",size(reply->filter_list[filter_cnt].
      available_values,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (retrieveexpectations(filter_cnt=i4) =null)
   CALL log_message("Begin RetrieveExpectations()",log_level_debug)
   DECLARE begin_time = f8 WITH constant(curtime3), private
   DECLARE expect_count = i4 WITH noconstant(0)
   SELECT DISTINCT INTO "nl:"
    FROM hm_expect hexpect,
     hm_expect_series hseries,
     hm_expect_sched hsched
    PLAN (hexpect
     WHERE hexpect.expect_id > 0
      AND hexpect.active_ind=1
      AND hexpect.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND hexpect.end_effective_dt_tm >= cnvtdatetime(sysdate))
     JOIN (hseries
     WHERE hexpect.expect_series_id=hseries.expect_series_id
      AND hseries.active_ind=1
      AND hseries.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND hseries.end_effective_dt_tm >= cnvtdatetime(sysdate))
     JOIN (hsched
     WHERE hseries.expect_sched_id=hsched.expect_sched_id
      AND hsched.active_ind=1
      AND hsched.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND hsched.end_effective_dt_tm >= cnvtdatetime(sysdate)
      AND hsched.expect_sched_type_flag=0)
    HEAD REPORT
     expect_count = 0
    HEAD hexpect.expect_id
     expect_count += 1
     IF (mod(expect_count,20)=1)
      stat = alterlist(reply->filter_list[filter_cnt].available_values,(expect_count+ 19))
     ENDIF
     reply->filter_list[filter_cnt].available_values[expect_count].argument_value = hexpect
     .expect_name, reply->filter_list[filter_cnt].available_values[expect_count].parent_entity_id =
     hexpect.expect_id, reply->filter_list[filter_cnt].available_values[expect_count].
     parent_entity_name = "HM_EXPECT"
    WITH nocounter
   ;end select
   SET stat = alterlist(reply->filter_list[filter_cnt].available_values,(expect_count+ 4))
   SET expect_count += 1
   SET reply->filter_list[filter_cnt].available_values[expect_count].argument_value = argval_neardue
   SET reply->filter_list[filter_cnt].available_values[expect_count].parent_entity_id = 1
   SET reply->filter_list[filter_cnt].available_values[expect_count].parent_entity_name =
   "RECOMMSTATUS"
   SET expect_count += 1
   SET reply->filter_list[filter_cnt].available_values[expect_count].argument_value = argval_due
   SET reply->filter_list[filter_cnt].available_values[expect_count].parent_entity_id = 2
   SET reply->filter_list[filter_cnt].available_values[expect_count].parent_entity_name =
   "RECOMMSTATUS"
   SET expect_count += 1
   SET reply->filter_list[filter_cnt].available_values[expect_count].argument_value = argval_overdue
   SET reply->filter_list[filter_cnt].available_values[expect_count].parent_entity_id = 3
   SET reply->filter_list[filter_cnt].available_values[expect_count].parent_entity_name =
   "RECOMMSTATUS"
   SET expect_count += 1
   SET reply->filter_list[filter_cnt].available_values[expect_count].argument_value = argval_notdue
   SET reply->filter_list[filter_cnt].available_values[expect_count].parent_entity_id = 4
   SET reply->filter_list[filter_cnt].available_values[expect_count].parent_entity_name =
   "RECOMMSTATUS"
   SET errcode = error(errmsg,0)
   IF (errcode != 0)
    SET failed = 1
    SET fail_operation = "RetrieveExpectations"
    CALL replyfailure("SELECT")
   ENDIF
   CALL log_message(build2("Exit RetrieveExpectations(), Elapsed time:",cnvtint((curtime3 -
      begin_time)),"0 ms","RetrieveExpectations found ",expect_count),log_level_debug)
 END ;Subroutine
 SUBROUTINE (retrieveorderstatuses(filter_cnt=i4) =null)
   CALL log_message("Begin RetrieveOrderStatuses()",log_level_debug)
   DECLARE begin_time = f8 WITH constant(curtime3), private
   DECLARE custom_types_ind = i2 WITH noconstant(0)
   DECLARE custom_status_ind = i2 WITH noconstant(0)
   DECLARE flex_types_id = f8 WITH noconstant(0.0)
   DECLARE flex_status_id = f8 WITH noconstant(0.0)
   DECLARE value_count = i4 WITH noconstant(0)
   DECLARE type_count = i4 WITH noconstant(0)
   DECLARE temp_arg_type = vc WITH noconstant("")
   SELECT INTO "nl:"
    cv_display = uar_get_code_display(bv.parent_entity_id)
    FROM br_datamart_filter bf,
     br_datamart_value bv
    PLAN (bf
     WHERE bf.br_datamart_category_id=dwl_category_id
      AND bf.filter_mean IN ("ORDER_STATUS_STATUS", "ORDER_STATUS_CAT_TYPE"))
     JOIN (bv
     WHERE bv.br_datamart_category_id=bf.br_datamart_category_id
      AND bv.br_datamart_filter_id=bf.br_datamart_filter_id
      AND bv.br_datamart_flex_id IN (pos_flex_id, system_flex_id)
      AND bv.parent_entity_name="CODE_VALUE"
      AND bv.logical_domain_id=0)
    ORDER BY bv.br_datamart_flex_id DESC, bv.updt_dt_tm
    HEAD bv.parent_entity_id
     IF (cv_display != ""
      AND ((bf.filter_mean="ORDER_STATUS_STATUS"
      AND ((custom_status_ind=0) OR (bv.br_datamart_flex_id=flex_status_id)) ) OR (bf.filter_mean=
     "ORDER_STATUS_CAT_TYPE"
      AND ((custom_types_ind=0) OR (bv.br_datamart_flex_id=flex_types_id)) )) )
      value_count += 1
      IF (mod(value_count,20)=1)
       stat = alterlist(reply->filter_list[filter_cnt].available_values,(value_count+ 19))
      ENDIF
      temp_arg_type = ""
      IF (bf.filter_mean="ORDER_STATUS_STATUS")
       custom_status_ind = 1, flex_status_id = bv.br_datamart_flex_id, temp_arg_type = "status"
      ELSEIF (bf.filter_mean="ORDER_STATUS_CAT_TYPE")
       custom_types_ind = 1, flex_types_id = bv.br_datamart_flex_id, temp_arg_type = "type"
      ENDIF
      CALL saveavailablevalue(filter_cnt,value_count,cv_display,null,temp_arg_type,bv
      .parent_entity_name,bv.parent_entity_id)
     ENDIF
    FOOT REPORT
     stat = alterlist(reply->filter_list[filter_cnt].available_values,value_count)
    WITH nocounter
   ;end select
   SET errcode = error(errmsg,0)
   IF (errcode != 0)
    SET failed = 1
    SET fail_operation = "RetrieveOrderSFromBedrock"
    CALL replyfailure("SELECT")
   ENDIF
   IF (custom_status_ind=0)
    SET type_count = (value_count+ 1)
    SET stat = alterlist(reply->filter_list[filter_cnt].available_values,(type_count+ 1))
    DECLARE incomplete_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"INCOMPLETE"))
    CALL saveavailablevalue(filter_cnt,type_count,uar_get_code_display(incomplete_cd),null,"status",
     "CODE_VALUE",incomplete_cd)
    SET type_count += 1
    DECLARE ordered_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"ORDERED"))
    CALL saveavailablevalue(filter_cnt,type_count,uar_get_code_display(ordered_cd),null,"status",
     "CODE_VALUE",ordered_cd)
    SET value_count = type_count
   ENDIF
   IF (custom_types_ind=0)
    SET type_count = (value_count+ 1)
    SET stat = alterlist(reply->filter_list[filter_cnt].available_values,(type_count+ 1))
    DECLARE genlab_cd = f8 WITH constant(uar_get_code_by("MEANING",6000,"GENERAL LAB"))
    CALL saveavailablevalue(filter_cnt,type_count,uar_get_code_display(genlab_cd),null,"type",
     "CODE_VALUE",genlab_cd)
    SET type_count += 1
    DECLARE referral_cd = f8 WITH constant(uar_get_code_by("MEANING",6000,"REFERRAL"))
    CALL saveavailablevalue(filter_cnt,type_count,uar_get_code_display(referral_cd),null,"type",
     "CODE_VALUE",referral_cd)
    SET value_count = type_count
   ENDIF
   CALL log_message(build2("Exit RetrieveOrderStatuses(), Elapsed time:",cnvtint((curtime3 -
      begin_time)),"0 ms","RetrieveOrderStatuses found ",value_count),log_level_debug)
 END ;Subroutine
 SUBROUTINE (retrieveencountertypefrombedrock(filter_cnt=i4) =null)
   CALL log_message("Begin RetrieveEncounterTypeFromBedrock()",log_level_debug)
   DECLARE begin_time = f8 WITH constant(curtime3), private
   DECLARE inpt_enc_type_ind = i2 WITH noconstant(0), private
   DECLARE outpt_enc_type_ind = i2 WITH noconstant(0), private
   DECLARE ed_enc_type_ind = i2 WITH noconstant(0), private
   DECLARE incr_cnt = i4 WITH noconstant(0), private
   DECLARE inpt_type_label_ind = i2 WITH noconstant(0), protect
   DECLARE outpt_type_label_ind = i2 WITH noconstant(0), protect
   DECLARE ed_type_label_ind = i2 WITH noconstant(0), protect
   DECLARE individual_enc_ind = vc WITH noconstant(""), protect
   DECLARE available_val_cnt = i4 WITH noconstant(0), protect
   DECLARE individual_enc_cnt = i4 WITH noconstant(0), protect
   DECLARE individual_enc_index = i4 WITH noconstant(0), protect
   DECLARE temp_cnt = i4 WITH noconstant(0), protect
   SET stat = alterlist(reply->filter_list[filter_cnt].available_values,6)
   DECLARE ind_lbl_inpt = i2 WITH noconstant(0)
   DECLARE ind_lbl_outpt = i2 WITH noconstant(0)
   DECLARE ind_lbl_ed = i2 WITH noconstant(0)
   DECLARE ind_lbl_grp1 = i2 WITH noconstant(0)
   DECLARE ind_lbl_grp2 = i2 WITH noconstant(0)
   DECLARE flex_id_inpt = f8 WITH noconstant(0.0)
   DECLARE flex_id_outpt = f8 WITH noconstant(0.0)
   DECLARE flex_id_ed = f8 WITH noconstant(0.0)
   DECLARE flex_id_grp1 = f8 WITH noconstant(0.0)
   DECLARE flex_id_grp2 = f8 WITH noconstant(0.0)
   DECLARE flex_id_indiv_enc_type = f8 WITH noconstant(0.0)
   DECLARE ind_indiv_enc_type = i2 WITH noconstant(0)
   SELECT INTO "nl:"
    FROM br_datamart_filter bf,
     br_datamart_value bv
    PLAN (bf
     WHERE bf.br_datamart_category_id=dwl_category_id
      AND bf.filter_mean IN ("INPT_ENC_TYPE_LABEL", "OUTPT_ENC_TYPE_LABEL", "ED_ENC_TYPE_LABEL",
     "GROUP1_ENC_TYPE_LABEL", "GROUP2_ENC_TYPE_LABEL",
     "INPT_ENC_TYPE", "OUTPT_ENC_TYPE", "ED_ENC_TYPE", "GROUP1_ENC_TYPE", "GROUP2_ENC_TYPE",
     "INDIVIDUAL_ENC_TYPE", "INDIVIDUAL_ENC_TYPE_IND"))
     JOIN (bv
     WHERE bv.br_datamart_category_id=bf.br_datamart_category_id
      AND bv.br_datamart_filter_id=bf.br_datamart_filter_id
      AND bv.br_datamart_flex_id IN (pos_flex_id, system_flex_id)
      AND bv.logical_domain_id=0)
    ORDER BY bv.br_datamart_flex_id DESC, bv.br_datamart_value_id
    HEAD bv.br_datamart_value_id
     IF (bf.filter_mean != "INDIVIDUAL_ENC_TYPE_IND"
      AND bv.freetext_desc != ""
      AND bv.freetext_desc != null)
      IF (bf.filter_mean="INPT_ENC_TYPE_LABEL"
       AND ind_lbl_inpt=0)
       ind_lbl_inpt = 1, inpt_type_label_ind = 1, available_val_cnt += 1,
       reply->filter_list[filter_cnt].available_values[available_val_cnt].argument_value = bv
       .freetext_desc, reply->filter_list[filter_cnt].available_values[available_val_cnt].
       parent_entity_id = 1
      ELSEIF (bf.filter_mean="OUTPT_ENC_TYPE_LABEL"
       AND ind_lbl_outpt=0)
       ind_lbl_outpt = 1, outpt_type_label_ind = 1, available_val_cnt += 1,
       reply->filter_list[filter_cnt].available_values[available_val_cnt].argument_value = bv
       .freetext_desc, reply->filter_list[filter_cnt].available_values[available_val_cnt].
       parent_entity_id = 2
      ELSEIF (bf.filter_mean="ED_ENC_TYPE_LABEL"
       AND ind_lbl_ed=0)
       ind_lbl_ed = 1, ed_type_label_ind = 1, available_val_cnt += 1,
       reply->filter_list[filter_cnt].available_values[available_val_cnt].argument_value = bv
       .freetext_desc, reply->filter_list[filter_cnt].available_values[available_val_cnt].
       parent_entity_id = 4
      ELSEIF (bf.filter_mean="GROUP1_ENC_TYPE_LABEL"
       AND ind_lbl_grp1=0)
       ind_lbl_grp1 = 1, available_val_cnt += 1, reply->filter_list[filter_cnt].available_values[
       available_val_cnt].argument_value = bv.freetext_desc,
       reply->filter_list[filter_cnt].available_values[available_val_cnt].parent_entity_id = 8
      ELSEIF (bf.filter_mean="GROUP2_ENC_TYPE_LABEL"
       AND ind_lbl_grp2=0)
       ind_lbl_grp2 = 1, available_val_cnt += 1, reply->filter_list[filter_cnt].available_values[
       available_val_cnt].argument_value = bv.freetext_desc,
       reply->filter_list[filter_cnt].available_values[available_val_cnt].parent_entity_id = 16
      ENDIF
     ELSEIF (((bf.filter_mean="INDIVIDUAL_ENC_TYPE") OR (bf.filter_mean="INDIVIDUAL_ENC_TYPE_IND")) )
      IF (individual_enc_index=0)
       available_val_cnt += 1, individual_enc_index = available_val_cnt, reply->filter_list[
       filter_cnt].available_values[individual_enc_index].argument_value = "Individual Encounters",
       reply->filter_list[filter_cnt].available_values[individual_enc_index].parent_entity_id = 32,
       reply->filter_list[filter_cnt].available_values[individual_enc_index].parent_entity_name =
       "INDIVIDUAL_ENC_TYPE"
      ENDIF
      IF (bf.filter_mean="INDIVIDUAL_ENC_TYPE_IND"
       AND ind_indiv_enc_type=0)
       ind_indiv_enc_type = 1, individual_enc_ind = bv.freetext_desc, reply->filter_list[filter_cnt].
       available_values[individual_enc_index].argument_meaning = individual_enc_ind
      ELSEIF (bf.filter_mean="INDIVIDUAL_ENC_TYPE")
       IF (bv.br_datamart_flex_id=pos_flex_id
        AND flex_id_indiv_enc_type=0.0)
        flex_id_indiv_enc_type = pos_flex_id
       ENDIF
       IF (bv.br_datamart_flex_id=flex_id_indiv_enc_type)
        individual_enc_cnt += 1, stat = alterlist(reply->filter_list[filter_cnt].available_values[
         individual_enc_index].child_values,individual_enc_cnt), reply->filter_list[filter_cnt].
        available_values[individual_enc_index].child_values[individual_enc_cnt].argument_value =
        uar_get_code_display(bv.parent_entity_id),
        reply->filter_list[filter_cnt].available_values[individual_enc_index].child_values[
        individual_enc_cnt].parent_entity_id = bv.parent_entity_id, reply->filter_list[filter_cnt].
        available_values[individual_enc_index].child_values[individual_enc_cnt].parent_entity_name =
        bf.filter_mean
       ENDIF
      ENDIF
     ELSE
      IF (bv.br_datamart_flex_id=pos_flex_id)
       IF (bf.filter_mean="INPT_ENC_TYPE"
        AND flex_id_inpt=0.0)
        flex_id_inpt = pos_flex_id
       ELSEIF (bf.filter_mean="OUTPT_ENC_TYPE"
        AND flex_id_outpt=0.0)
        flex_id_outpt = pos_flex_id
       ELSEIF (bf.filter_mean="ED_ENC_TYPE"
        AND flex_id_ed=0.0)
        flex_id_ed = pos_flex_id
       ELSEIF (bf.filter_mean="GROUP1_ENC_TYPE"
        AND flex_id_grp1=0.0)
        flex_id_grp1 = pos_flex_id
       ELSEIF (bf.filter_mean="GROUP2_ENC_TYPE"
        AND flex_id_grp2=0.0)
        flex_id_grp2 = pos_flex_id
       ENDIF
      ENDIF
      IF (((bf.filter_mean="INPT_ENC_TYPE"
       AND bv.br_datamart_flex_id=flex_id_inpt) OR (((bf.filter_mean="OUTPT_ENC_TYPE"
       AND bv.br_datamart_flex_id=flex_id_outpt) OR (((bf.filter_mean="ED_ENC_TYPE"
       AND bv.br_datamart_flex_id=flex_id_ed) OR (((bf.filter_mean="GROUP1_ENC_TYPE"
       AND bv.br_datamart_flex_id=flex_id_grp1) OR (bf.filter_mean="GROUP2_ENC_TYPE"
       AND bv.br_datamart_flex_id=flex_id_grp2)) )) )) )) )
       temp_cnt += 1, stat = alterlist(encounters->encntr_data,temp_cnt), encounters->encntr_data[
       temp_cnt].parent_entity_id = bv.parent_entity_id,
       encounters->encntr_data[temp_cnt].argument_value = uar_get_code_display(bv.parent_entity_id),
       encounters->encntr_data[temp_cnt].parent_entity_name = bf.filter_mean
      ENDIF
     ENDIF
    FOOT REPORT
     stat = alterlist(encounters->encntr_data,temp_cnt)
    WITH nocounter
   ;end select
   SET stat = alterlist(reply->filter_list[filter_cnt].available_values,available_val_cnt)
   IF (((inpt_type_label_ind=0) OR (((outpt_type_label_ind=0) OR (ed_type_label_ind=0)) )) )
    IF (validate(i18nuar_def,999)=999)
     CALL echo("Declaring i18nuar_def")
     DECLARE i18nuar_def = i2 WITH persist
     SET i18nuar_def = 1
     DECLARE uar_i18nlocalizationinit(p1=i4,p2=vc,p3=vc,p4=f8) = i4 WITH persist
     DECLARE uar_i18ngetmessage(p1=i4,p2=vc,p3=vc) = vc WITH persist
     DECLARE uar_i18nbuildmessage() = vc WITH persist
     DECLARE uar_i18ngethijridate(imonth=i2(val),iday=i2(val),iyear=i2(val),sdateformattype=vc(ref))
      = c50 WITH image_axp = "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar =
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
    DECLARE i18n_handle = i4 WITH noconstant(0), private
    DECLARE h = i4 WITH noconstant(uar_i18nlocalizationinit(i18n_handle,curprog,"",curcclrev)),
    private
    DECLARE encounter_type_cd = f8 WITH noconstant(0), private
    IF (inpt_type_label_ind=0)
     SET available_val_cnt += 1
     SET stat = alterlist(reply->filter_list[filter_cnt].available_values,available_val_cnt)
     DECLARE i18n_inpatientlabel = vc WITH noconstant(uar_i18ngetmessage(i18n_handle,
       "i18n_key_InpatientLabel","Inpatient")), private
     SET reply->filter_list[filter_cnt].available_values[available_val_cnt].argument_value =
     i18n_inpatientlabel
     SET reply->filter_list[filter_cnt].available_values[available_val_cnt].parent_entity_id = 1
    ENDIF
    IF (outpt_type_label_ind=0)
     SET available_val_cnt += 1
     SET stat = alterlist(reply->filter_list[filter_cnt].available_values,available_val_cnt)
     DECLARE i18n_outpatientlabel = vc WITH noconstant(uar_i18ngetmessage(i18n_handle,
       "i18n_key_OutpatientLabel","Outpatient")), private
     SET reply->filter_list[filter_cnt].available_values[available_val_cnt].argument_value =
     i18n_outpatientlabel
     SET reply->filter_list[filter_cnt].available_values[available_val_cnt].parent_entity_id = 2
    ENDIF
    IF (ed_type_label_ind=0)
     SET available_val_cnt += 1
     SET stat = alterlist(reply->filter_list[filter_cnt].available_values,available_val_cnt)
     DECLARE i18n_emergencylabel = vc WITH noconstant(uar_i18ngetmessage(i18n_handle,
       "i18n_key_EmergencyLabel","Emergency")), private
     SET reply->filter_list[filter_cnt].available_values[available_val_cnt].argument_value =
     i18n_emergencylabel
     SET reply->filter_list[filter_cnt].available_values[available_val_cnt].parent_entity_id = 4
    ENDIF
   ENDIF
   SET stat = alterlist(reply->filter_list[filter_cnt].available_values,available_val_cnt)
   IF (size(encounters->encntr_data,5) != 0)
    FOR (idx = 1 TO size(reply->filter_list[filter_cnt].available_values,5))
      FOR (idx2 = 1 TO size(encounters->encntr_data,5))
        IF ((((reply->filter_list[filter_cnt].available_values[idx].parent_entity_id=1)
         AND (encounters->encntr_data[idx2].parent_entity_name="INPT_ENC_TYPE")) OR ((((reply->
        filter_list[filter_cnt].available_values[idx].parent_entity_id=2)
         AND (encounters->encntr_data[idx2].parent_entity_name="OUTPT_ENC_TYPE")) OR ((((reply->
        filter_list[filter_cnt].available_values[idx].parent_entity_id=4)
         AND (encounters->encntr_data[idx2].parent_entity_name="ED_ENC_TYPE")) OR ((((reply->
        filter_list[filter_cnt].available_values[idx].parent_entity_id=8)
         AND (encounters->encntr_data[idx2].parent_entity_name="GROUP1_ENC_TYPE")) OR ((reply->
        filter_list[filter_cnt].available_values[idx].parent_entity_id=16)
         AND (encounters->encntr_data[idx2].parent_entity_name="GROUP2_ENC_TYPE"))) )) )) )) )
         SET incr_cnt = (size(reply->filter_list[filter_cnt].available_values[idx].child_values,5)+ 1
         )
         SET stat = alterlist(reply->filter_list[filter_cnt].available_values[idx].child_values,
          incr_cnt)
         SET reply->filter_list[filter_cnt].available_values[idx].child_values[incr_cnt].
         argument_value = encounters->encntr_data[idx2].argument_value
         SET reply->filter_list[filter_cnt].available_values[idx].child_values[incr_cnt].
         parent_entity_id = encounters->encntr_data[idx2].parent_entity_id
        ENDIF
        IF ((encounters->encntr_data[idx2].parent_entity_name="INPT_ENC_TYPE")
         AND inpt_enc_type_ind=0)
         SET inpt_enc_type_ind = 1
        ENDIF
        IF ((encounters->encntr_data[idx2].parent_entity_name="OUTPT_ENC_TYPE")
         AND outpt_enc_type_ind=0)
         SET outpt_enc_type_ind = 1
        ENDIF
        IF ((encounters->encntr_data[idx2].parent_entity_name="ED_ENC_TYPE")
         AND ed_enc_type_ind=0)
         SET ed_enc_type_ind = 1
        ENDIF
      ENDFOR
    ENDFOR
   ENDIF
   IF (((inpt_enc_type_ind=0) OR (((outpt_enc_type_ind=0) OR (ed_enc_type_ind=0)) )) )
    FOR (idx = 1 TO size(reply->filter_list[filter_cnt].available_values,5))
      IF ((reply->filter_list[filter_cnt].available_values[idx].parent_entity_id=1)
       AND inpt_enc_type_ind=0)
       SET stat = alterlist(reply->filter_list[filter_cnt].available_values[idx].child_values,1)
       SET encounter_type_cd = uar_get_code_by_cki("CKI.CODEVALUE!3958")
       SET reply->filter_list[filter_cnt].available_values[idx].child_values[1].argument_value =
       uar_get_code_display(encounter_type_cd)
       SET reply->filter_list[filter_cnt].available_values[idx].child_values[1].parent_entity_id =
       encounter_type_cd
      ENDIF
      IF ((reply->filter_list[filter_cnt].available_values[idx].parent_entity_id=2)
       AND outpt_enc_type_ind=0)
       SET stat = alterlist(reply->filter_list[filter_cnt].available_values[idx].child_values,1)
       SET encounter_type_cd = uar_get_code_by_cki("CKI.CODEVALUE!3959")
       SET reply->filter_list[filter_cnt].available_values[idx].child_values[1].argument_value =
       uar_get_code_display(encounter_type_cd)
       SET reply->filter_list[filter_cnt].available_values[idx].child_values[1].parent_entity_id =
       encounter_type_cd
      ENDIF
      IF ((reply->filter_list[filter_cnt].available_values[idx].parent_entity_id=4)
       AND ed_enc_type_ind=0)
       SET stat = alterlist(reply->filter_list[filter_cnt].available_values[idx].child_values,1)
       SET encounter_type_cd = uar_get_code_by_cki("CKI.CODEVALUE!3957")
       SET reply->filter_list[filter_cnt].available_values[idx].child_values[1].argument_value =
       uar_get_code_display(encounter_type_cd)
       SET reply->filter_list[filter_cnt].available_values[idx].child_values[1].parent_entity_id =
       encounter_type_cd
      ENDIF
    ENDFOR
   ENDIF
   IF (individual_enc_index != 0
    AND individual_enc_ind="1"
    AND individual_enc_cnt=0)
    SELECT INTO "nl:"
     FROM code_value cv
     PLAN (cv
      WHERE cv.code_set=71
       AND cv.active_ind=1)
     HEAD cv.display_key
      individual_enc_cnt += 1
      IF (mod(individual_enc_cnt,50)=1)
       stat = alterlist(reply->filter_list[filter_cnt].available_values[individual_enc_index].
        child_values,(individual_enc_cnt+ 49))
      ENDIF
      reply->filter_list[filter_cnt].available_values[individual_enc_index].child_values[
      individual_enc_cnt].argument_value = cv.display, reply->filter_list[filter_cnt].
      available_values[individual_enc_index].child_values[individual_enc_cnt].parent_entity_id = cv
      .code_value, reply->filter_list[filter_cnt].available_values[individual_enc_index].
      child_values[individual_enc_cnt].parent_entity_name = "INDIVIDUAL_ENC_TYPE"
     FOOT REPORT
      stat = alterlist(reply->filter_list[filter_cnt].available_values[individual_enc_index].
       child_values,individual_enc_cnt)
     WITH nocounter
    ;end select
   ENDIF
   SET errcode = error(errmsg,0)
   IF (errcode != 0)
    SET failed = 1
    SET fail_operation = "RetrieveEnctrFromBedrock"
    CALL replyfailure("SELECT")
   ENDIF
   CALL log_message(build2("Exit RetrieveEncounterTypeFromBedrock(), Elapsed time:",cnvtint((curtime3
       - begin_time)),"0 ms","RetrieveEncounterTypeFromBedrock found ",available_val_cnt),
    log_level_debug)
 END ;Subroutine
END GO
