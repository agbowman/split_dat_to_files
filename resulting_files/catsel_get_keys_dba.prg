CREATE PROGRAM catsel_get_keys:dba
 RECORD reply(
   1 qual_cnt = i4
   1 qual[*]
     2 display = vc
     2 keyval = vc
     2 code = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE search_string = vc WITH protect, noconstant(
  "ocs.mnemonic_key_cap between begin_string and end_string")
 DECLARE trim_upper_seed = vc WITH protect, noconstant("")
 DECLARE proc_contains_search = i2 WITH protect, noconstant(false)
 DECLARE proc_cache_size = i4 WITH protect, noconstant(0)
 DECLARE surgery_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6000,"SURGERY"))
 DECLARE ancillary_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"ANCILLARY"))
 DECLARE sr_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",223,"SURGAREA"))
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE num = i4 WITH protect, noconstant(0)
 DECLARE where_string = vc WITH protect, noconstant("1=1")
 DECLARE last_mod = c3 WITH protect, noconstant("000")
 DECLARE s_cnt = i4 WITH protect, noconstant(0)
 DECLARE handle = i4 WITH protect, noconstant(0)
 DECLARE begin_string = c32 WITH protect, noconstant("")
 DECLARE end_string = c32 WITH protect, noconstant("")
 DECLARE errmsg = vc WITH protect, noconstant(" ")
 DECLARE count1 = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET proc_cache_size = 100
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
 IF ((((reqinfo->updt_app=820000)) OR ((((reqinfo->updt_app=801400)) OR ((((reqinfo->updt_app=610000)
 ) OR ((((reqinfo->updt_app=4250111)) OR ((((reqinfo->updt_app=600005)) OR ((((reqinfo->updt_app=
 4006000)) OR ((((reqinfo->updt_app=4100001)) OR ((reqinfo->updt_app=4180000))) )) )) )) )) )) )) )
  SELECT INTO "nl:"
   snvp.pref_name, snvp.pref_value
   FROM sn_doc_ref sdr,
    sn_name_value_prefs snvp
   WHERE (sdr.area_cd=request->surg_area_cd)
    AND snvp.parent_entity_id=sdr.area_cd
    AND snvp.pref_name="PROC_SEARCH_WITH_CONTAINS"
    AND snvp.parent_entity_name="AREA_PREFS"
   DETAIL
    IF (snvp.pref_value="1")
     proc_contains_search = true
    ENDIF
   WITH nocounter
  ;end select
  IF (proc_contains_search=true)
   SELECT INTO "nl:"
    snvp.pref_name, snvp.pref_value
    FROM sn_doc_ref sdr,
     sn_name_value_prefs snvp
    WHERE (sdr.area_cd=request->surg_area_cd)
     AND snvp.parent_entity_id=sdr.area_cd
     AND snvp.pref_name="PROC_CACHE_SIZE"
     AND snvp.parent_entity_name="AREA_PREFS"
    DETAIL
     proc_cache_size = cnvtint(snvp.pref_value)
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF ((reqinfo->updt_app=800100))
  SELECT INTO "nl:"
   FROM sn_name_value_prefs snvp,
    sn_app_prefs sap
   PLAN (snvp
    WHERE snvp.parent_entity_name="SN_APP_PREFS"
     AND snvp.pref_name="ProcSearchType")
    JOIN (sap
    WHERE sap.app_prefs_id=snvp.parent_entity_id
     AND (sap.person_id=reqinfo->updt_id))
   DETAIL
    IF (snvp.pref_value="1")
     proc_contains_search = true
    ENDIF
   WITH nocounter
  ;end select
  IF (proc_contains_search=true)
   SELECT INTO "nl:"
    FROM sn_name_value_prefs snvp,
     sn_app_prefs sap
    PLAN (snvp
     WHERE snvp.parent_entity_name="SN_APP_PREFS"
      AND snvp.pref_name="ProcCacheSize")
     JOIN (sap
     WHERE sap.app_prefs_id=snvp.parent_entity_id
      AND (sap.person_id=reqinfo->updt_id))
    DETAIL
     proc_cache_size = cnvtint(snvp.pref_value)
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 SET handle = uar_i18nalphabet_init()
 IF (size(request->seed,1) > 0)
  SET begin_string = cnvtupper(request->seed)
  CALL uar_i18nalphabet_highchar(handle,end_string,size(end_string,1))
  SET end_string = cnvtupper(trim(end_string))
 ELSE
  CALL uar_i18nalphabet_lowchar(handle,begin_string,size(begin_string,1))
  CALL uar_i18nalphabet_highchar(handle,end_string,size(end_string,1))
  SET begin_string = cnvtupper(trim(begin_string))
  SET end_string = cnvtupper(trim(end_string))
 ENDIF
 CALL uar_i18nalphabet_end(handle)
 IF (proc_contains_search=true
  AND (request->seed != "!")
  AND (request->seed != " "))
  SET trim_upper_seed = trim(cnvtupper(request->seed),3)
  SET search_string = "ocs.mnemonic_key_cap = patstring(concat('*',trim_upper_seed, '*'))"
 ELSE
  SET search_string = "ocs.mnemonic_key_cap between begin_string and end_string"
  SET proc_cache_size = 100
 ENDIF
 IF ((request->catalog_types[1].catalog_type_cd != surgery_cd))
  SET request->mnemonic_type_cnt += 1
  SET stat = alterlist(request->mnemonic_types,request->mnemonic_type_cnt)
  SET request->mnemonic_types[request->mnemonic_type_cnt].mnemonic_type_cd = ancillary_cd
 ENDIF
 IF ((request->show_inactive_ind=0))
  SET where_string = build(where_string," and ocs.active_ind = 1")
 ENDIF
 IF ((request->mnemonic_type_cnt > 0))
  SET where_string = build(where_string," and expand (num, 1, request->mnemonic_type_cnt,")
  SET where_string = build(where_string,
   " ocs.mnemonic_type_cd+0, request->mnemonic_types[num].mnemonic_type_cd)")
 ENDIF
 IF ((request->catalog_type_cnt > 0))
  SET where_string = build(where_string," and expand (num, 1, request->catalog_type_cnt,")
  SET where_string = build(where_string,
   " ocs.catalog_type_cd, request->catalog_types[num].catalog_type_cd) ")
 ENDIF
 IF ((request->surg_area_cd=0))
  IF ((reqinfo->updt_app=800100))
   SELECT INTO "nl:"
    FROM order_catalog_synonym ocs
    WHERE parser(search_string)
     AND parser(where_string)
     AND ocs.catalog_cd IN (
    (SELECT DISTINCT
     spd.catalog_cd
     FROM service_resource sr,
      surg_proc_detail spd
     WHERE expand(idx,1,size(sac_org->organizations,5),sr.organization_id,sac_org->organizations[idx]
      .organization_id)
      AND sr.active_ind=1
      AND sr.service_resource_type_cd=sr_type_cd
      AND spd.surg_area_cd=sr.service_resource_cd))
    ORDER BY ocs.mnemonic_key_cap
    HEAD REPORT
     s_cnt = 0, count1 = 0
    DETAIL
     IF (count1 < proc_cache_size)
      s_cnt += 1, count1 += 1
      IF (mod(s_cnt,10)=1)
       stat = alterlist(reply->qual,(s_cnt+ 9))
      ENDIF
      reply->qual[s_cnt].display = ocs.mnemonic, reply->qual[s_cnt].keyval = ocs.mnemonic_key_cap,
      reply->qual[s_cnt].code = ocs.synonym_id
     ELSE
      CALL cancel(1)
     ENDIF
    WITH nocounter, expand = 1
   ;end select
  ELSE
   SELECT INTO "nl:"
    FROM order_catalog_synonym ocs
    WHERE parser(search_string)
     AND parser(where_string)
    ORDER BY ocs.mnemonic_key_cap
    HEAD REPORT
     s_cnt = 0, count1 = 0
    DETAIL
     IF (count1 < proc_cache_size)
      s_cnt += 1, count1 += 1
      IF (mod(s_cnt,10)=1)
       stat = alterlist(reply->qual,(s_cnt+ 9))
      ENDIF
      reply->qual[s_cnt].display = ocs.mnemonic, reply->qual[s_cnt].keyval = ocs.mnemonic_key_cap,
      reply->qual[s_cnt].code = ocs.synonym_id
     ELSE
      CALL cancel(1)
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
 ELSE
  SELECT INTO "nl:"
   FROM order_catalog_synonym ocs
   PLAN (ocs
    WHERE parser(search_string)
     AND parser(where_string)
     AND (( NOT ( EXISTS (
    (SELECT
     sp.catalog_cd
     FROM surgical_procedure sp
     WHERE sp.catalog_cd=ocs.catalog_cd)))) OR ( EXISTS (
    (SELECT
     spd.catalog_cd
     FROM surg_proc_detail spd
     WHERE spd.catalog_cd=ocs.catalog_cd
      AND (spd.surg_area_cd=request->surg_area_cd))))) )
   ORDER BY ocs.mnemonic_key_cap
   HEAD REPORT
    s_cnt = 0
   DETAIL
    IF (count1 < proc_cache_size)
     s_cnt += 1, count1 += 1
     IF (mod(s_cnt,10)=1)
      stat = alterlist(reply->qual,(s_cnt+ 9))
     ENDIF
     reply->qual[s_cnt].display = ocs.mnemonic, reply->qual[s_cnt].keyval = ocs.mnemonic_key_cap,
     reply->qual[s_cnt].code = ocs.synonym_id
    ELSE
     CALL cancel(1)
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alterlist(reply->qual,s_cnt)
 IF (error(errmsg,0) != 0)
  SET reply->status_data.subeventstatus[1].operationname = "GET"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "ORDER_CATALOG_SYNONYM"
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
  SET reply->qual_cnt = s_cnt
 ENDIF
 SET script_version = "006 06/17/09 SA016585"
 SET last_mod = "006"
END GO
