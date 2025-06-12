CREATE PROGRAM dcp_ens_pregnancy:dba
 RECORD reply(
   1 pregnancy_id = f8
   1 problem_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD dxrequest(
   1 item[*]
     2 action_ind = i2
     2 diagnosis_id = f8
     2 diagnosis_group = f8
     2 encntr_id = f8
     2 person_id = f8
     2 nomenclature_id = f8
     2 concept_cki = vc
     2 diag_ft_desc = vc
     2 diagnosis_display = vc
     2 conditional_qual_cd = f8
     2 confirmation_status_cd = f8
     2 diag_dt_tm = dq8
     2 classification_cd = f8
     2 clinical_service_cd = f8
     2 diag_type_cd = f8
     2 ranking_cd = f8
     2 severity_cd = f8
     2 severity_ftdesc = vc
     2 severity_class_cd = f8
     2 certainty_cd = f8
     2 probability = i4
     2 long_blob_id = f8
     2 comment = gvc
     2 active_ind = i2
     2 diag_prsnl_id = f8
     2 diag_prsnl_name = vc
     2 diag_priority = i4
     2 clinical_diag_priority = i4
     2 secondary_desc_list[*]
       3 group_sequence = i4
       3 group[*]
         4 secondary_desc_id = f8
         4 nomenclature_id = f8
         4 sequence = i4
     2 related_dx_list[*]
       3 active_ind = i2
       3 child_entity_id = f8
       3 reltn_subtype_cd = f8
       3 priority = i4
       3 child_dx_type_cd = f8
       3 child_clin_srv_cd = f8
       3 child_nomen_id = f8
       3 child_ft_desc = vc
     2 related_proc_list[*]
       3 active_ind = i2
       3 procedure_id = f8
       3 reltn_subtype_cd = f8
       3 priority = i4
 )
 FREE RECORD probrequest
 RECORD probrequest(
   1 person_id = f8
   1 problem[*]
     2 problem_action_ind = i2
     2 problem_id = f8
     2 problem_instance_id = f8
     2 nomenclature_id = f8
     2 annotated_display = vc
     2 organization_id = f8
     2 source_vocabulary_cd = f8
     2 source_identifier = vc
     2 problem_ftdesc = vc
     2 classification_cd = f8
     2 confirmation_status_cd = f8
     2 qualifier_cd = f8
     2 life_cycle_status_cd = f8
     2 life_cycle_dt_tm = dq8
     2 life_cycle_dt_flag = i2
     2 life_cycle_dt_cd = f8
     2 persistence_cd = f8
     2 certainty_cd = f8
     2 ranking_cd = f8
     2 probability = f8
     2 onset_dt_flag = i2
     2 onset_dt_cd = f8
     2 onset_dt_tm = dq8
     2 onset_tz = i4
     2 course_cd = f8
     2 severity_class_cd = f8
     2 severity_cd = f8
     2 severity_ftdesc = vc
     2 prognosis_cd = f8
     2 person_aware_cd = f8
     2 family_aware_cd = f8
     2 person_aware_prognosis_cd = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 status_upt_precision_flag = i2
     2 status_upt_precision_cd = f8
     2 status_upt_dt_tm = dq8
     2 cancel_reason_cd = f8
     2 originating_nomenclature_id = f8
     2 problem_comment[*]
       3 problem_comment_id = f8
       3 comment_action_ind = i2
       3 comment_dt_tm = dq8
       3 comment_tz = i4
       3 comment_prsnl_id = f8
       3 comment_prsnl_name = vc
       3 problem_comment = vc
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
     2 problem_discipline[*]
       3 discipline_action_ind = i2
       3 problem_discipline_id = f8
       3 management_discipline_cd = f8
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
     2 problem_prsnl[*]
       3 prsnl_action_ind = i2
       3 problem_reltn_dt_tm = dq8
       3 problem_reltn_cd = f8
       3 problem_prsnl_id = f8
       3 problem_reltn_prsnl_id = f8
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
     2 secondary_desc_list[*]
       3 group_sequence = i4
       3 group[*]
         4 secondary_desc_id = f8
         4 nomenclature_id = f8
         4 sequence = i4
     2 problem_uuid = vc
     2 problem_instance_uuid = vc
     2 contributor_system_cd = f8
     2 problem_type_flag = i2
     2 show_in_pm_history_ind = i2
   1 skip_fsi_trigger = i2
 )
 SUBROUTINE (reportfailure(opname=vc,opstatus=vc,targetname=vc,targetvalue=vc) =null)
  SET reply->status_data.status = "F"
  CALL fillsubeventstatus(opname,opstatus,targetname,targetvalue)
 END ;Subroutine
 SUBROUTINE (fillsubeventstatus(opname=vc,opstatus=vc,objname=vc,objvalue=vc) =null)
   DECLARE dcp_substatus_cnt = i4 WITH protect, noconstant(size(reply->status_data.subeventstatus,5))
   SET dcp_substatus_cnt += 1
   IF (dcp_substatus_cnt != 1)
    SET stat = alter(reply->status_data.subeventstatus,dcp_substatus_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].operationname = trim(opname)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].targetobjectname = trim(objname)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].targetobjectvalue = trim(objvalue)
 END ;Subroutine
 DECLARE fillproblemrequest() = null
 DECLARE filldiagnosisrequest() = null
 DECLARE findnomenclature() = null
 DECLARE ensurepregnancydata() = null
 DECLARE deactivatepregnancy() = null
 DECLARE logpregnancyaction() = null
 DECLARE getpregnancyproblemid() = null
 DECLARE problem_item_cnt = i4 WITH protected, constant(size(request->problem_data,5))
 DECLARE diagnosis_item_cnt = i4 WITH protected, constant(size(request->diagnosis_data,5))
 DECLARE nomen_vocab_cd = f8 WITH protected, constant(uar_get_code_by("MEANING",400,nullterm(request
    ->nomen_vocab_mean)))
 DECLARE conf_type_cd = f8 WITH protected, constant(uar_get_code_by("MEANING",4002108,"CONFIRMETHOD")
  )
 DECLARE responsible_cd = f8 WITH protected, constant(uar_get_code_by("MEANING",12038,"RESPONSIBLE"))
 DECLARE active_lifecycle_cd = f8 WITH protected, constant(uar_get_code_by("MEANING",12030,"ACTIVE"))
 DECLARE cancel_lifecycle_cd = f8 WITH protected, constant(uar_get_code_by("MEANING",12030,"CANCELED"
   ))
 DECLARE create_action_cd = f8 WITH protected, constant(uar_get_code_by("MEANING",4002114,"CREATE"))
 DECLARE update_action_cd = f8 WITH protected, constant(uar_get_code_by("MEANING",4002114,"UPDATE"))
 DECLARE cancel_action_cd = f8 WITH protected, constant(uar_get_code_by("MEANING",4002114,"CANCEL"))
 DECLARE preg_ens_mode = i2 WITH protected, noconstant(0)
 DECLARE pregprobid = f8 WITH protected, noconstant(0.0)
 DECLARE idx = i4 WITH protected, noconstant(0)
 DECLARE failure_ind = i2 WITH protected, noconstant(false)
 DECLARE nomen_id = f8 WITH protected, noconstant(0.0)
 DECLARE preg_problem_id = f8 WITH protected, noconstant(0.0)
 DECLARE master_preg_id = f8 WITH protected, noconstant(0.0)
 DECLARE master_preg_inst_id = f8 WITH protected, noconstant(0.0)
 DECLARE active_pregnancy_problem_ind = i2 WITH protected, noconstant(0)
 DECLARE annotated_display = vc WITH protected, noconstant
 DECLARE active_problem_instance_id = f8 WITH protected, noconstant(0.0)
 DECLARE active_problem_id = f8 WITH protected, noconstant(0.0)
 DECLARE classification_cd = f8 WITH protect, noconstant(0.0)
 DECLARE serrormsg = vc WITH protect, noconstant("")
 DECLARE ierrorcode = i2 WITH protect, noconstant(0)
 DECLARE prob_onset_dt_tm = dq8 WITH protect, noconstant(0.0)
 IF (validate(request->classification_cd))
  SET classification_cd = request->classification_cd
 ENDIF
 SUBROUTINE (checkactivepregnancy(argpersonid=f8) =f8)
   RETURN(checkactivepregnancyorg(argpersonid,0,0))
 END ;Subroutine
 SUBROUTINE (checkactivepregnancyorg(argpersonid=f8,argencntrid=f8,argorgsecoverride=i2) =f8)
   CALL echo("[TRACE]: CheckActivePregnancy")
   DECLARE retval = f8 WITH noconstant(0.0), private
   RECORD actchkrequest(
     1 patient_id = f8
     1 encntr_id = f8
     1 org_sec_override = i2
   )
   SET actchkrequest->patient_id = argpersonid
   SET actchkrequest->encntr_id = argencntrid
   SET actchkrequest->org_sec_override = argorgsecoverride
   EXECUTE dcp_chk_active_preg  WITH replace("REQUEST",actchkrequest), replace("REPLY",actchkreply)
   IF ((actchkreply->status_data.status="F"))
    CALL echo("[FAIL]: DCP_CHK_ACTIVE_PREG failed")
   ELSEIF ((actchkreply->status_data.status="Z"))
    SET retval = 0.0
   ELSE
    CALL echo("[TRACE]: Active Pregnancy found for patient")
    SET retval = actchkreply->pregnancy_id
   ENDIF
   RETURN(retval)
 END ;Subroutine
 DECLARE loadpregnancyorganizationsecuritylist() = null
 IF (validate(preg_org_sec_ind)=0)
  DECLARE preg_org_sec_ind = i4 WITH noconstant(0)
  SELECT INTO "nl:"
   FROM dm_info d1,
    dm_info d2
   WHERE d1.info_domain="SECURITY"
    AND d1.info_name="SEC_ORG_RELTN"
    AND d1.info_number=1
    AND d2.info_domain="SECURITY"
    AND d2.info_name="SEC_PREG_ORG_RELTN"
    AND d2.info_number=1
   DETAIL
    preg_org_sec_ind = 1
   WITH nocounter
  ;end select
  CALL echo(build("preg_org_sec_ind=",preg_org_sec_ind))
  IF (preg_org_sec_ind=1)
   FREE RECORD preg_sec_orgs
   RECORD preg_sec_orgs(
     1 qual[*]
       2 org_id = f8
       2 confid_level = i4
   )
   CALL loadpregnancyorganizationsecuritylist(null)
  ENDIF
 ENDIF
 SUBROUTINE loadpregnancyorganizationsecuritylist(null)
   DECLARE org_cnt = i2 WITH noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (validate(sac_org)=1)
    FREE RECORD sac_org
   ENDIF
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
   SET org_cnt = size(sac_org->organizations,5)
   CALL echo(build("org_cnt: ",org_cnt))
   SET stat = alterlist(preg_sec_orgs->qual,(org_cnt+ 1))
   FOR (count = 1 TO org_cnt)
    SET preg_sec_orgs->qual[count].org_id = sac_org->organizations[count].organization_id
    SET preg_sec_orgs->qual[count].confid_level = sac_org->organizations[count].confid_level
   ENDFOR
   SET preg_sec_orgs->qual[(org_cnt+ 1)].org_id = 0.00
   SET preg_sec_orgs->qual[(org_cnt+ 1)].confid_level = 0
 END ;Subroutine
 SET reply->status_data.status = "F"
 DECLARE pregid = f8 WITH protected, noconstant(checkactivepregnancyorg(request->patient_id,request->
   encntr_id,request->org_sec_override))
 CALL echo(build("Pregnancy_id = ",pregid))
 IF (pregid > 0)
  CALL getpregnancyproblemid(null)
 ENDIF
 IF (pregid != 0.0)
  IF ((request->problem_data[1].life_cycle_status_cd=cancel_lifecycle_cd))
   CALL echo("[TRACE] Changing mode to cancel")
   SET preg_ens_mode = 2
  ELSE
   CALL echo("[TRACE] Changing mode to modify")
   SET preg_ens_mode = 1
  ENDIF
  SET master_preg_id = pregid
 ENDIF
 CALL findnomenclature(null)
 CALL fillproblemrequest(null)
 EXECUTE kia_ens_problem  WITH replace("REQUEST",probrequest), replace("REPLY",probreply)
 IF ((probreply->status_data.status="F"))
  CALL fillsubeventstatus("dcp_ens_pregnancy","F","kia_ens_problem",
   "kia_ens_problem script failed to ensure problem")
  CALL echo("*Failed - problem ensure*")
  SET failure_ind = true
  GO TO failure
 ELSE
  SET preg_problem_id = probreply->problem_list[1].problem_id
  SET prob_onset_dt_tm = cnvtdatetime(probrequest->problem[1].onset_dt_tm)
  SET reply->problem_id = probreply->problem_list[1].problem_id
  CALL echo("Pregnancy Problem Ensured")
 ENDIF
 IF (diagnosis_item_cnt > 0
  AND preg_ens_mode=0)
  CALL filldiagnosisrequest(null)
  EXECUTE kia_ens_clin_dx  WITH replace("REQUEST",dxrequest), replace("REPLY",dxreply)
  IF ((dxreply->status_data.status="F"))
   CALL echo("*Failed - diagnosis ensure*")
   CALL echorecord(dxreply)
   CALL fillsubeventstatus("dcp_ens_pregnancy","F","kia_ens_clin_dx",
    "kia_ens_clin_dx script failed to ensure diagnosis")
   SET failure_ind = true
   GO TO failure
  ELSE
   CALL echo("Pregnancy Diagnosis Ensured")
  ENDIF
 ENDIF
 IF (((preg_ens_mode=1) OR (preg_ens_mode=2)) )
  CALL deactivatepregnancy(null)
 ENDIF
 CALL ensurepregnancydata(null)
 CALL logpregnancyaction(null)
 CALL echo("Success - Pregnancy Ensure")
#failure
 SET ierrorcode = error(serrormsg,1)
 IF (ierrorcode != 0)
  CALL echo("*********************************")
  CALL echo(build("ERROR MESSAGE : ",serrormsg))
  CALL echo("*********************************")
  CALL reportfailure("ERROR","F","DCP_ENS_PREGNANCY",serrormsg)
  SET reqinfo->commit_ind = false
 ELSEIF (failure_ind=true)
  CALL echo("*Ensure Pregnancy Script failed*")
  SET reqinfo->commit_ind = false
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
  EXECUTE srvrtl
  EXECUTE crmrtl
  DECLARE happ = i4 WITH private, noconstant(0)
  DECLARE htask = i4 WITH private, noconstant(0)
  DECLARE hreq = i4 WITH private, noconstant(0)
  DECLARE hrequest = i4 WITH protect, noconstant(0)
  DECLARE probcount = i4 WITH private, noconstant(0)
  DECLARE disciplinecount = i4 WITH private, noconstant(0)
  DECLARE personnelcount = i4 WITH private, noconstant(0)
  DECLARE commentcount = i4 WITH private, noconstant(0)
  DECLARE lcrmstatus = i4 WITH private, noconstant(0)
  SET stat = uar_crmbeginapp(4170101,happ)
  IF (stat != 0)
   RETURN
  ENDIF
  SET stat = uar_crmbegintask(happ,4170147,htask)
  IF (stat != 0)
   CALL uar_crmendapp(happ)
   RETURN
  ENDIF
  SET stat = uar_crmbeginreq(htask,"kia_prb_outbound_async",4170168,hreq)
  IF (stat != 0)
   CALL uar_crmendtask(htask)
   CALL uar_crmendapp(happ)
   RETURN
  ENDIF
  SET hrequest = uar_crmgetrequest(hreq)
  IF (hrequest)
   SET probcount = 0
   CALL echo("Test problem")
   CALL echo(kia_do_ob_add)
   CALL echorecord(kia_ob_add)
   IF (kia_do_ob_add=true)
    SET stat = uar_srvsetdouble(hrequest,"person_id",kia_ob_add->person_id)
    WHILE (probcount < size(kia_ob_add->problem,5))
      SET probcount += 1
      SET hproblemitem = uar_srvadditem(hrequest,"problem")
      IF (hproblemitem)
       SET stat = uar_srvsetshort(hproblemitem,"ob_action_ind",1)
       SET stat = uar_srvsetdouble(hproblemitem,"interface_action_cd",kia_ob_add->problem[probcount].
        interface_action_cd)
       SET stat = uar_srvsetdouble(hproblemitem,"problem_id",kia_ob_add->problem[probcount].
        problem_id)
       SET stat = uar_srvsetdouble(hproblemitem,"problem_instance_id",kia_ob_add->problem[probcount].
        problem_instance_id)
       SET stat = uar_srvsetstring(hproblemitem,"problem_uuid",kia_ob_add->problem[probcount].
        problem_uuid)
       SET stat = uar_srvsetstring(hproblemitem,"problem_instance_uuid",kia_ob_add->problem[probcount
        ].problem_instance_uuid)
       SET stat = uar_srvsetdouble(hproblemitem,"contributor_system_cd",kia_ob_add->problem[probcount
        ].contributor_system_cd)
       SET disciplinecount = 0
       WHILE (disciplinecount < size(kia_ob_add->problem[probcount].discipline,5))
         SET disciplinecount += 1
         SET hdisciplineitem = uar_srvadditem(hproblemitem,"discipline")
         IF (hdisciplineitem)
          SET stat = uar_srvsetdouble(hdisciplineitem,"interface_action_cd",kia_ob_add->problem[
           probcount].discipline[disciplinecount].interface_action_cd)
          SET stat = uar_srvsetdouble(hdisciplineitem,"problem_discipline_id",kia_ob_add->problem[
           probcount].discipline[disciplinecount].problem_discipline_id)
         ENDIF
       ENDWHILE
       SET personnelcount = 0
       WHILE (personnelcount < size(kia_ob_add->problem[probcount].prsnl,5))
         SET personnelcount += 1
         SET hprsnlitem = uar_srvadditem(hproblemitem,"prsnl")
         IF (hprsnlitem)
          SET stat = uar_srvsetdouble(hprsnlitem,"interface_action_cd",kia_ob_add->problem[probcount]
           .prsnl[personnelcount].interface_action_cd)
          SET stat = uar_srvsetdouble(hprsnlitem,"problem_prsnl_id",kia_ob_add->problem[probcount].
           prsnl[personnelcount].problem_prsnl_id)
         ENDIF
       ENDWHILE
       SET commentcount = 0
       WHILE (commentcount < size(kia_ob_add->problem[probcount].comment,5))
         SET commentcount += 1
         SET hcommentitem = uar_srvadditem(hproblemitem,"comment")
         IF (hcommentitem)
          SET stat = uar_srvsetdouble(hcommentitem,"problem_comment_id",kia_ob_add->problem[probcount
           ].comment[commentcount].problem_comment_id)
         ENDIF
       ENDWHILE
      ENDIF
    ENDWHILE
   ENDIF
   CALL echorecord(kia_ob_upd)
   SET probcount = 0
   IF (kia_do_ob_upd=true)
    SET stat = uar_srvsetdouble(hrequest,"person_id",kia_ob_upd->person_id)
    WHILE (probcount < size(kia_ob_upd->problem,5))
      SET probcount += 1
      SET hproblemitem = uar_srvadditem(hrequest,"problem")
      IF (hproblemitem)
       SET stat = uar_srvsetshort(hproblemitem,"ob_action_ind",2)
       SET stat = uar_srvsetdouble(hproblemitem,"interface_action_cd",kia_ob_upd->problem[probcount].
        interface_action_cd)
       SET stat = uar_srvsetdouble(hproblemitem,"problem_id",kia_ob_upd->problem[probcount].
        problem_id)
       SET stat = uar_srvsetdouble(hproblemitem,"problem_instance_id",kia_ob_upd->problem[probcount].
        problem_instance_id)
       SET stat = uar_srvsetdouble(hproblemitem,"contributor_system_cd",kia_ob_upd->problem[probcount
        ].contributor_system_cd)
       SET stat = uar_srvsetstring(hproblemitem,"problem_uuid",kia_ob_upd->problem[probcount].
        problem_uuid)
       SET stat = uar_srvsetstring(hproblemitem,"problem_instance_uuid",kia_ob_upd->problem[probcount
        ].problem_instance_uuid)
       SET disciplinecount = 0
       WHILE (disciplinecount < size(kia_ob_upd->problem[probcount].discipline,5))
         SET disciplinecount += 1
         SET hdisciplineitem = uar_srvadditem(hproblemitem,"discipline")
         IF (hdisciplineitem)
          SET stat = uar_srvsetdouble(hdisciplineitem,"interface_action_cd",kia_ob_upd->problem[
           probcount].discipline[disciplinecount].interface_action_cd)
          SET stat = uar_srvsetdouble(hdisciplineitem,"problem_discipline_id",kia_ob_upd->problem[
           probcount].discipline[disciplinecount].problem_discipline_id)
         ENDIF
       ENDWHILE
       SET personnelcount = 0
       WHILE (personnelcount < size(kia_ob_upd->problem[probcount].prsnl,5))
         SET personnelcount += 1
         SET hprsnlitem = uar_srvadditem(hproblemitem,"prsnl")
         IF (hprsnlitem)
          SET stat = uar_srvsetdouble(hprsnlitem,"interface_action_cd",kia_ob_upd->problem[probcount]
           .prsnl[personnelcount].interface_action_cd)
          SET stat = uar_srvsetdouble(hprsnlitem,"problem_prsnl_id",kia_ob_upd->problem[probcount].
           prsnl[personnelcount].problem_prsnl_id)
         ENDIF
       ENDWHILE
       SET commentcount = 0
       WHILE (commentcount < size(kia_ob_upd->problem[probcount].comment,5))
         SET commentcount += 1
         SET hcommentitem = uar_srvadditem(hproblemitem,"comment")
         IF (hcommentitem)
          SET stat = uar_srvsetdouble(hcommentitem,"problem_comment_id",kia_ob_upd->problem[probcount
           ].comment[commentcount].problem_comment_id)
         ENDIF
       ENDWHILE
      ENDIF
    ENDWHILE
   ENDIF
  ENDIF
  SET lcrmstatus = uar_crmperform(hreq)
  CALL uar_crmendreq(hreq)
  CALL uar_crmendtask(htask)
  CALL uar_crmendapp(happ)
 ENDIF
 CALL echorecord(reply)
 CALL echo("DCP_ENS_PREGNANCY Last Modified = 009 28/04/15")
 SUBROUTINE fillproblemrequest(null)
   DECLARE record_idx = i4 WITH private, noconstant(0)
   DECLARE sub_idx = i4 WITH private, noconstant(0)
   DECLARE problem_cmt_cnt = i4 WITH private, noconstant(0)
   DECLARE status = i4 WITH private, noconstant(0)
   SET probrequest->person_id = request->patient_id
   CALL echo(build("problemsize:",problem_item_cnt))
   SET status = alterlist(probrequest->problem,problem_item_cnt)
   SET probrequest->skip_fsi_trigger = 1
   FOR (record_idx = 1 TO problem_item_cnt)
     IF (active_pregnancy_problem_ind=false)
      SET probrequest->problem[record_idx].problem_action_ind = 4
     ELSE
      IF (((preg_ens_mode=1) OR (preg_ens_mode=2)) )
       SET probrequest->problem[record_idx].problem_action_ind = 2
      ELSE
       SET probrequest->problem[record_idx].problem_action_ind = 1
      ENDIF
     ENDIF
     IF ((request->problem_data[record_idx].problem_id > 0))
      SET probrequest->problem[record_idx].problem_id = request->problem_data[record_idx].problem_id
     ELSE
      SET probrequest->problem[record_idx].problem_id = active_problem_id
     ENDIF
     SET probrequest->problem[record_idx].problem_instance_id = active_problem_instance_id
     SET probrequest->problem[record_idx].organization_id = request->org_id
     SET probrequest->problem[record_idx].nomenclature_id = nomen_id
     SET probrequest->problem[record_idx].originating_nomenclature_id = nomen_id
     SET probrequest->problem[record_idx].annotated_display = annotated_display
     SET probrequest->problem[record_idx].confirmation_status_cd = request->problem_data[record_idx].
     confirmation_status_cd
     SET probrequest->problem[record_idx].life_cycle_status_cd = request->problem_data[record_idx].
     life_cycle_status_cd
     SET probrequest->problem[record_idx].onset_dt_tm = request->problem_data[record_idx].onset_dt_tm
     IF (validate(request->problem_data[record_idx].onset_tz))
      SET probrequest->problem[record_idx].onset_tz = request->problem_data[record_idx].onset_tz
     ENDIF
     SET probrequest->problem[record_idx].classification_cd = classification_cd
     SET problem_cmt_cnt = size(request->problem_data[record_idx].problem_comment,5)
     CALL echo(build("commentsize:",problem_cmt_cnt))
     SET status = alterlist(probrequest->problem[record_idx].problem_comment,problem_cmt_cnt)
     FOR (sub_idx = 1 TO problem_cmt_cnt)
       SET probrequest->problem[record_idx].problem_comment.problem_comment_id = request->
       problem_data[record_idx].problem_comment[sub_idx].problem_comment_id
       SET probrequest->problem[record_idx].problem_comment.comment_prsnl_id = request->problem_data[
       record_idx].problem_comment[sub_idx].comment_prsnl_id
       SET probrequest->problem[record_idx].problem_comment.comment_prsnl_name = request->
       problem_data[record_idx].problem_comment[sub_idx].comment_prsnl_name
       SET probrequest->problem[record_idx].problem_comment.problem_comment = request->problem_data[
       record_idx].problem_comment[sub_idx].problem_comment_text
       SET probrequest->problem[record_idx].problem_comment.comment_dt_tm = cnvtdatetime(sysdate)
       SET probrequest->problem[record_idx].problem_comment.comment_action_ind = 4
     ENDFOR
     SET status = alterlist(probrequest->problem[record_idx].problem_prsnl,1)
     IF (active_pregnancy_problem_ind=false)
      SET probrequest->problem[record_idx].problem_prsnl[1].prsnl_action_ind = 4
     ELSE
      IF (((preg_ens_mode=1) OR (preg_ens_mode=2)) )
       SET probrequest->problem[record_idx].problem_prsnl[1].prsnl_action_ind = 2
      ELSE
       SET probrequest->problem[record_idx].problem_prsnl[1].prsnl_action_ind = 1
      ENDIF
     ENDIF
     SET probrequest->problem[record_idx].problem_prsnl[1].problem_reltn_cd = responsible_cd
     SET probrequest->problem[record_idx].problem_prsnl[1].problem_reltn_prsnl_id = request->
     problem_data[record_idx].problem_prsnl_id
     SET probrequest->problem[record_idx].problem_type_flag = 2
   ENDFOR
   CALL echorecord(probrequest)
 END ;Subroutine
 SUBROUTINE filldiagnosisrequest(null)
   DECLARE record_idx = i4 WITH private, noconstant(0)
   DECLARE status = i4 WITH private, noconstant(0)
   DECLARE prsnl_name = vc
   SELECT INTO "nl:"
    pr.name_full_formatted
    FROM prsnl pr
    WHERE (pr.person_id=request->problem_data[1].problem_prsnl_id)
    DETAIL
     prsnl_name = pr.name_full_formatted
    WITH nocounter
   ;end select
   SET status = alterlist(dxrequest->item,diagnosis_item_cnt)
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = diagnosis_item_cnt)
    HEAD REPORT
     record_idx = 0
    DETAIL
     record_idx += 1, dxrequest->item[record_idx].action_ind = 1, dxrequest->item[record_idx].
     diagnosis_id = request->diagnosis_data[record_idx].diagnosis_id,
     dxrequest->item[record_idx].nomenclature_id = nomen_id, dxrequest->item[record_idx].
     diagnosis_display = annotated_display, dxrequest->item[record_idx].encntr_id = request->
     diagnosis_data[record_idx].encntr_id,
     dxrequest->item[record_idx].person_id = request->patient_id, dxrequest->item[record_idx].
     diag_prsnl_id = request->problem_data[1].problem_prsnl_id, dxrequest->item[record_idx].
     diag_prsnl_name = prsnl_name,
     dxrequest->item[record_idx].confirmation_status_cd = request->problem_data[1].
     confirmation_status_cd, dxrequest->item[record_idx].diag_dt_tm = cnvtdatetime(sysdate),
     dxrequest->item[record_idx].classification_cd = classification_cd
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE findnomenclature(null)
   SELECT INTO "nl:"
    FROM nomenclature nm
    WHERE (nm.source_identifier=request->nomen_source_id)
     AND nm.source_vocabulary_cd=nomen_vocab_cd
     AND nm.primary_cterm_ind=1
     AND nm.active_ind=true
    DETAIL
     nomen_id = nm.nomenclature_id, annotated_display = nm.source_string
    WITH nocounter
   ;end select
   CALL echo(build("nomen id: ",nomen_id))
   IF (nomen_id <= 0)
    CALL fillsubeventstatus("dcp_ens_pregnancy","F","FindNomenclature",
     "failed - nomenclature could not be found")
    SET failure_ind = true
    CALL echo("*failed - nomenclature couldn't be found*")
    GO TO failure
   ENDIF
 END ;Subroutine
 SUBROUTINE ensurepregnancydata(null)
   CALL echo("Creating new Pregnancy Instance")
   DECLARE seqnum = f8 WITH protected, noconstant(0.0)
   SELECT INTO "nl:"
    j = seq(pregnancy_seq,nextval)
    FROM dual
    DETAIL
     seqnum = cnvtreal(j)
    WITH nocounter
   ;end select
   CALL echo(build("sequence is:",value(seqnum)))
   SET master_preg_inst_id = value(seqnum)
   IF (preg_ens_mode=0)
    SET master_preg_id = value(seqnum)
   ENDIF
   SET reply->pregnancy_id = master_preg_id
   DECLARE set_active = i2 WITH protected, noconstant(true)
   DECLARE preg_end_dt = dq8 WITH protected, noconstant(cnvtdatetime("31-DEC-2100"))
   IF (preg_ens_mode=2)
    SET set_active = false
    SET preg_end_dt = cnvtdatetime(sysdate)
   ENDIF
   INSERT  FROM pregnancy_instance pi
    SET pi.pregnancy_instance_id = master_preg_inst_id, pi.pregnancy_id = master_preg_id, pi
     .person_id = request->patient_id,
     pi.organization_id = request->org_id, pi.sensitive_ind = 0, pi.confirmed_dt_tm = cnvtdatetime(
      cnvtdate(request->confirmation_dt_tm),0000),
     pi.problem_id = preg_problem_id, pi.preg_start_dt_tm = cnvtdatetime(prob_onset_dt_tm), pi
     .preg_end_dt_tm = cnvtdatetime(preg_end_dt),
     pi.override_comment = null, pi.active_ind = set_active, pi.beg_effective_dt_tm = cnvtdatetime(
      sysdate),
     pi.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), pi.updt_id = reqinfo->updt_id, pi
     .updt_dt_tm = cnvtdatetime(sysdate),
     pi.updt_applctx = reqinfo->updt_applctx, pi.updt_cnt = 0, pi.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL fillsubeventstatus("dcp_ens_pregnancy","F","EnsurePregnancyData",
     "FAILED: Couldn't insert pregnancy_instance")
    SET failure_ind = true
    CALL echo("FAILED: Couldn't insert pregnancy_instance")
    GO TO failure
   ELSE
    DECLARE request_check = i2 WITH protect, constant(validate(request->confirmation_tz))
    IF (request_check=1)
     UPDATE  FROM pregnancy_instance pi
      SET pi.confirmed_tz = request->confirmation_tz
      WHERE pi.pregnancy_instance_id=master_preg_inst_id
      WITH nocounter
     ;end update
    ENDIF
   ENDIF
   INSERT  FROM pregnancy_entity_r pe
    SET pe.pregnancy_entity_id = seq(pregnancy_seq,nextval), pe.pregnancy_instance_id =
     master_preg_inst_id, pe.pregnancy_id = master_preg_id,
     pe.parent_entity_id = request->confirmation_method_cd, pe.parent_entity_name = "CODE_VALUE", pe
     .component_type_cd = conf_type_cd,
     pe.beg_effective_dt_tm = cnvtdatetime(sysdate), pe.end_effective_dt_tm = cnvtdatetime(
      "31-DEC-2100"), pe.active_ind = true,
     pe.updt_id = reqinfo->updt_id, pe.updt_dt_tm = cnvtdatetime(sysdate), pe.updt_applctx = reqinfo
     ->updt_applctx,
     pe.updt_cnt = 0, pe.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL fillsubeventstatus("dcp_ens_pregnancy","F","EnsurePregnancyData",
     "FAILED: Couldn't insert pregnancy_entity_r")
    SET failure_ind = true
    CALL echo("FAILED: Couldn't insert pregnancy_entity_r")
    GO TO failure
   ENDIF
 END ;Subroutine
 SUBROUTINE deactivatepregnancy(null)
   CALL echo("Deactivating pregnancy")
   UPDATE  FROM pregnancy_instance pi
    SET pi.active_ind = false, pi.end_effective_dt_tm = cnvtdatetime(sysdate), pi.updt_id = reqinfo->
     updt_id,
     pi.updt_dt_tm = cnvtdatetime(sysdate), pi.updt_applctx = reqinfo->updt_applctx, pi.updt_cnt = (
     pi.updt_cnt+ 1),
     pi.updt_task = reqinfo->updt_task
    WHERE pi.pregnancy_id=master_preg_id
     AND ((pi.active_ind+ 0)=true)
    WITH nocounter
   ;end update
   IF (curqual=0)
    CALL echo("Pregnancy could not be deactivated")
    CALL fillsubeventstatus("dcp_ens_pregnancy","F","DeactivatePregnancy",
     "FAILED: Pregnancy could not be deactivated")
    SET failure_ind = true
    GO TO failure
   ENDIF
   CALL echo("Update pregnancy_entity_r")
   UPDATE  FROM pregnancy_entity_r pe
    SET pe.active_ind = false, pe.end_effective_dt_tm = cnvtdatetime(sysdate), pe.updt_id = reqinfo->
     updt_id,
     pe.updt_dt_tm = cnvtdatetime(sysdate), pe.updt_applctx = reqinfo->updt_applctx, pe.updt_cnt = (
     pe.updt_cnt+ 1),
     pe.updt_task = reqinfo->updt_task
    WHERE pe.pregnancy_id=master_preg_id
     AND pe.active_ind=true
    WITH nocounter
   ;end update
 END ;Subroutine
 SUBROUTINE getpregnancyproblemid(null)
   SELECT INTO "nl:"
    FROM pregnancy_instance pi,
     problem p
    PLAN (pi
     WHERE pi.pregnancy_id=pregid
      AND pi.active_ind=1
      AND pi.preg_end_dt_tm=cnvtdatetime("31-DEC-2100"))
     JOIN (p
     WHERE p.person_id=pi.person_id
      AND p.problem_id=pi.problem_id
      AND p.active_ind=1)
    HEAD pi.pregnancy_id
     active_pregnancy_problem_ind = true, active_problem_instance_id = p.problem_instance_id,
     active_problem_id = p.problem_id
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE logpregnancyaction(null)
   DECLARE ensure_action = f8 WITH protected, noconstant(0.0)
   IF (preg_ens_mode=0)
    SET ensure_action = create_action_cd
   ELSEIF (preg_ens_mode=1)
    SET ensure_action = update_action_cd
   ELSEIF (preg_ens_mode=2)
    SET ensure_action = cancel_action_cd
   ENDIF
   CALL echo("[TRACE] logging ensure action")
   DECLARE new_seq = f8 WITH protected, noconstant(0.0)
   SELECT INTO "nl:"
    j = seq(pregnancy_seq,nextval)
    FROM dual
    DETAIL
     new_seq = cnvtreal(j)
    WITH nocounter
   ;end select
   INSERT  FROM pregnancy_action pa
    SET pa.prsnl_id =
     IF (preg_ens_mode=2) reqinfo->updt_id
     ELSE request->problem_data[1].problem_prsnl_id
     ENDIF
     , pa.pregnancy_id = reply->pregnancy_id, pa.pregnancy_action_id = new_seq,
     pa.action_dt_tm = cnvtdatetime(sysdate), pa.action_tz = request->action_tz, pa.action_type_cd =
     ensure_action,
     pa.pregnancy_instance_id = master_preg_inst_id, pa.updt_id = reqinfo->updt_id, pa.updt_applctx
      = reqinfo->updt_applctx,
     pa.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
 END ;Subroutine
END GO
