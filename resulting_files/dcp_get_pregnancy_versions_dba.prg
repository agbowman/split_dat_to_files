CREATE PROGRAM dcp_get_pregnancy_versions:dba
 SET modify = predeclare
 FREE RECORD reply
 RECORD reply(
   1 pregnancies[*]
     2 preg_instance[*]
       3 pregnancy_id = f8
       3 pregnancy_instance_id = f8
       3 person_id = f8
       3 problem_id = f8
       3 instance_prsnl_id = f8
       3 entered_dt_tm = dq8
       3 entered_tz = i4
       3 sensitive_ind = i2
       3 preg_start_dt_tm = dq8
       3 preg_end_dt_tm = dq8
       3 override_comment = vc
       3 confirmation_dt_tm = dq8
       3 updt_dt_tm = dq8
       3 pregnancy_entities[*]
         4 parent_entity_name = vc
         4 parent_entity_id = f8
         4 component_type_cd = f8
       3 pregnancy_children[*]
         4 pregnancy_child_id = f8
         4 gender_cd = f8
         4 child_name = vc
         4 person_id = f8
         4 father_name = vc
         4 delivery_method_cd = f8
         4 delivery_hospital = vc
         4 gestation_age = i4
         4 labor_duration = i4
         4 weight_amt = f8
         4 weight_unit_cd = f8
         4 anesthesia_txt = vc
         4 preterm_labor_txt = vc
         4 delivery_dt_tm = dq8
         4 delivery_tz = i4
         4 neonate_outcome_cd = f8
         4 child_comment = vc
         4 child_entities[*]
           5 parent_entity_name = vc
           5 parent_entity_id = f8
           5 component_type_cd = f8
           5 entity_text = vc
         4 delivery_date_precision_flag = i2
         4 delivery_date_qualifier_flag = i2
         4 gestation_term_txt = vc
       3 org_id = f8
       3 last_reviewed_dt_tm = dq8
       3 deleted_ind = i2
       3 auto_closed_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH persistscript
 FREE RECORD pregs
 RECORD pregs(
   1 preg_instance[*]
     2 pregnancy_id = f8
     2 pregnancy_instance_id = f8
     2 person_id = f8
     2 problem_id = f8
     2 instance_prsnl_id = f8
     2 entered_dt_tm = dq8
     2 entered_tz = i4
     2 sensitive_ind = i2
     2 preg_start_dt_tm = dq8
     2 preg_end_dt_tm = dq8
     2 override_comment = vc
     2 confirmation_dt_tm = dq8
     2 updt_id = f8
     2 updt_dt_tm = dq8
     2 org_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 preg_idx = i4
     2 inst_idx = i4
     2 last_reviewed_dt_tm = dq8
     2 deleted_ind = i2
     2 preg_entities[*]
       3 parent_entity_name = vc
       3 parent_entity_id = f8
       3 component_type_cd = f8
     2 auto_closed_ind = i2
 )
 FREE RECORD children
 RECORD children(
   1 child[*]
     2 pregnancy_child_id = f8
     2 pregnancy_instance_id = f8
     2 pregnancy_id = f8
     2 gender_cd = f8
     2 child_name = vc
     2 person_id = f8
     2 father_name = vc
     2 delivery_method_cd = f8
     2 delivery_hospital = vc
     2 gestation_age = i4
     2 labor_duration = i4
     2 weight_amt = f8
     2 weight_unit_cd = f8
     2 anesthesia_txt = vc
     2 preterm_labor_txt = vc
     2 delivery_dt_tm = dq8
     2 delivery_tz = i4
     2 neonate_outcome_cd = f8
     2 child_comment = vc
     2 delivery_date_precision_flag = i2
     2 delivery_date_qualifier_flag = i2
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 entities[*]
       3 pregnancy_child_id = f8
       3 parent_entity_id = f8
       3 parent_entity_name = vc
       3 component_type_cd = f8
       3 entity_text = vc
     2 gestation_term_txt = vc
 )
 FREE RECORD nomenclature
 RECORD nomenclature(
   1 nomens[*]
     2 nomenclature_id = f8
     2 source_string = vc
 )
 FREE RECORD long_text
 RECORD long_text(
   1 entities[*]
     2 long_text_id = f8
     2 long_text = vc
 )
 DECLARE fail_ind = i2 WITH protect, noconstant(false)
 DECLARE error_msg = vc WITH protect, noconstant("")
 DECLARE error_code = i2 WITH protect, noconstant(false)
 DECLARE zero_ind = i2 WITH protect, noconstant(false)
 DECLARE debug_ind = i2 WITH protect, noconstant(0)
 DECLARE last_mod = c12 WITH private, noconstant(fillstring(12," "))
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE create_action_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002114,"CREATE"))
 DECLARE update_action_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002114,"UPDATE"))
 DECLARE review_action_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002114,"REVIEW"))
 DECLARE reopen_action_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002114,"REOPEN"))
 DECLARE close_action_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002114,"CLOSE"))
 DECLARE auto_close_action_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002114,
   "AUTOCLOSE"))
 DECLARE delete_action_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002114,"DELETE"))
 DECLARE validaterequest(null) = null
 DECLARE querypersonforpregnancy(null) = null
 DECLARE querypregnancy(null) = null
 DECLARE querypregnancyaction(null) = null
 DECLARE addpregnancyinstances(null) = null
 DECLARE addchildrentopregnancy(null) = null
 DECLARE querynomenclature(null) = null
 DECLARE querylongtext(null) = null
 DECLARE querypregnancyreview(null) = null
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
 SET reply->status_data.status = "F"
 IF (validate(request->debug_ind)=1)
  IF ((request->debug_ind=1))
   SET debug_ind = 1
  ENDIF
 ENDIF
 CALL validaterequest(null)
 CALL querypregnancy(null)
 CALL addpregnancyinstances(null)
 CALL querypregnancychild(null)
 CALL addchildrentopregnancy(null)
 SUBROUTINE validaterequest(null)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE req_preg_cnt = i2 WITH protect, noconstant(size(request->pregnancies,5))
   IF (locateval(idx,1,size(request->pregnancies,5),0.0,request->pregnancies[idx].pregnancy_id) > 0)
    SET fail_ind = true
    CALL fillsubeventstatus("DCP_GET_PREGNANCY_VERSIONS","F","Verify Request",
     "Request contained a pregnancy_id = 0")
    GO TO exit_script
   ENDIF
   IF ((request->person_id > 0)
    AND req_preg_cnt=0)
    CALL querypersonforpregnancy(null)
   ELSEIF ((request->person_id > 0)
    AND req_preg_cnt > 0)
    SET fail_ind = true
    CALL fillsubeventstatus("DCP_GET_PREGNANCY_VERSIONS","F","Verify Request",
     "Request contained both pregnancy_id's and a person_id")
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE querypersonforpregnancy(null)
   DECLARE preg_cnt = i4 WITH protect, noconstant(0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE close_reopen_ind = i2 WITH protect, noconstant(0)
   SELECT
    IF (((preg_org_sec_ind=0) OR ((request->org_sec_override=1))) )
     FROM pregnancy_instance pi,
      pregnancy_action pa
     PLAN (pi
      WHERE (pi.person_id=request->person_id))
      JOIN (pa
      WHERE pa.pregnancy_id=pi.pregnancy_id)
    ELSE
     FROM pregnancy_instance pi,
      pregnancy_action pa,
      (dummyt d  WITH seq = size(preg_sec_orgs->qual,5))
     PLAN (pi
      WHERE (pi.person_id=request->person_id))
      JOIN (pa
      WHERE pa.pregnancy_id=pi.pregnancy_id)
      JOIN (d
      WHERE (pi.organization_id=preg_sec_orgs->qual[d.seq].org_id))
    ENDIF
    INTO "nl:"
    ORDER BY pi.pregnancy_id, pa.action_dt_tm DESC
    HEAD REPORT
     preg_cnt = 0
    HEAD pi.pregnancy_id
     close_reopen_ind = 0
    DETAIL
     IF (((pa.action_type_cd IN (close_action_cd, auto_close_action_cd)
      AND close_reopen_ind=0) OR (pi.historical_ind=1)) )
      close_reopen_ind = 1
      IF (locateval(idx,1,preg_cnt,pi.pregnancy_id,request->pregnancies[idx].pregnancy_id) <= 0)
       preg_cnt += 1
       IF (mod(preg_cnt,5)=1)
        stat = alterlist(request->pregnancies,(preg_cnt+ 4))
       ENDIF
       request->pregnancies[preg_cnt].pregnancy_id = pi.pregnancy_id
      ENDIF
     ELSEIF (pa.action_type_cd=reopen_action_cd
      AND close_reopen_ind=0)
      close_reopen_ind = 1
     ENDIF
    FOOT REPORT
     stat = alterlist(request->pregnancies,preg_cnt)
    WITH nocounter
   ;end select
   IF (debug_ind=1)
    CALL echorecord(request)
   ENDIF
 END ;Subroutine
 SUBROUTINE querypregnancy(null)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE inst_idx = i4 WITH protect, noconstant(0)
   DECLARE entity_idx = i4 WITH protect, noconstant(0)
   DECLARE preg_list_cnt = i4 WITH protect, noconstant(size(request->pregnancies,5))
   SELECT
    IF (((preg_org_sec_ind=0) OR ((request->org_sec_override=1))) )
     FROM pregnancy_instance pi,
      pregnancy_entity_r per
     PLAN (pi
      WHERE expand(idx,1,preg_list_cnt,pi.pregnancy_id,request->pregnancies[idx].pregnancy_id))
      JOIN (per
      WHERE (per.pregnancy_id= Outerjoin(pi.pregnancy_id)) )
    ELSE
     FROM pregnancy_instance pi,
      pregnancy_entity_r per,
      (dummyt d  WITH seq = size(preg_sec_orgs->qual,5))
     PLAN (pi
      WHERE expand(idx,1,preg_list_cnt,pi.pregnancy_id,request->pregnancies[idx].pregnancy_id))
      JOIN (per
      WHERE (per.pregnancy_id= Outerjoin(pi.pregnancy_id)) )
      JOIN (d
      WHERE (pi.organization_id=preg_sec_orgs->qual[d.seq].org_id))
    ENDIF
    INTO "nl:"
    ORDER BY pi.pregnancy_id, pi.end_effective_dt_tm DESC, pi.pregnancy_instance_id
    HEAD REPORT
     inst_idx = 0
    HEAD pi.pregnancy_instance_id
     entity_idx = 0, inst_idx += 1
     IF (mod(inst_idx,10)=1)
      stat = alterlist(pregs->preg_instance,(inst_idx+ 9))
     ENDIF
     pregs->preg_instance[inst_idx].pregnancy_id = pi.pregnancy_id, pregs->preg_instance[inst_idx].
     pregnancy_instance_id = pi.pregnancy_instance_id, pregs->preg_instance[inst_idx].person_id = pi
     .person_id,
     pregs->preg_instance[inst_idx].problem_id = pi.problem_id, pregs->preg_instance[inst_idx].
     sensitive_ind = pi.sensitive_ind, pregs->preg_instance[inst_idx].preg_start_dt_tm = pi
     .preg_start_dt_tm,
     pregs->preg_instance[inst_idx].preg_end_dt_tm = pi.preg_end_dt_tm, pregs->preg_instance[inst_idx
     ].override_comment = pi.override_comment, pregs->preg_instance[inst_idx].confirmation_dt_tm = pi
     .confirmed_dt_tm,
     pregs->preg_instance[inst_idx].updt_dt_tm = pi.updt_dt_tm, pregs->preg_instance[inst_idx].org_id
      = pi.organization_id, pregs->preg_instance[inst_idx].beg_effective_dt_tm = pi
     .beg_effective_dt_tm,
     pregs->preg_instance[inst_idx].end_effective_dt_tm = pi.end_effective_dt_tm
     IF (pi.active_ind=0
      AND pi.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100"))
      pregs->preg_instance[inst_idx].deleted_ind = 1
     ELSE
      pregs->preg_instance[inst_idx].deleted_ind = 0
     ENDIF
    DETAIL
     IF (per.pregnancy_instance_id=pi.pregnancy_instance_id)
      entity_idx += 1
      IF (mod(entity_idx,10)=1)
       stat = alterlist(pregs->preg_instance[inst_idx].preg_entities,(entity_idx+ 9))
      ENDIF
      pregs->preg_instance[inst_idx].preg_entities[entity_idx].parent_entity_name = per
      .parent_entity_name, pregs->preg_instance[inst_idx].preg_entities[entity_idx].parent_entity_id
       = per.parent_entity_id, pregs->preg_instance[inst_idx].preg_entities[entity_idx].
      component_type_cd = per.component_type_cd
     ENDIF
    FOOT  pi.pregnancy_instance_id
     stat = alterlist(pregs->preg_instance[inst_idx].preg_entities,entity_idx)
    FOOT REPORT
     stat = alterlist(pregs->preg_instance,inst_idx)
    WITH nocounter
   ;end select
   IF (curqual <= 0)
    CALL fillsubeventstatus("ZERO","Z","dcp_get_pregnancy_versions",
     "No qualifying pregnancies were found")
    CALL echo("[ZERO] No pregnancy was found")
    SET zero_ind = true
    GO TO exit_script
   ENDIF
   CALL querypregnancyaction(null)
   CALL querypregnancyreview(null)
 END ;Subroutine
 SUBROUTINE querypregnancyaction(null)
   DECLARE request_cnt = i4 WITH protect, noconstant(size(request->pregnancies,5))
   DECLARE preg_cnt = i4 WITH protect, noconstant(size(pregs->preg_instance,5))
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE inst_idx = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM pregnancy_action pa,
     (dummyt d  WITH seq = size(pregs->preg_instance,5))
    PLAN (d)
     JOIN (pa
     WHERE (pa.pregnancy_instance_id=pregs->preg_instance[d.seq].pregnancy_instance_id)
      AND ((pa.action_type_cd=create_action_cd) OR (((pa.action_type_cd=update_action_cd) OR (((pa
     .action_type_cd=close_action_cd) OR (((pa.action_type_cd=reopen_action_cd) OR (((pa
     .action_type_cd=delete_action_cd) OR (pa.action_type_cd=auto_close_action_cd)) )) )) )) )) )
    DETAIL
     pregs->preg_instance[d.seq].entered_dt_tm = pa.action_dt_tm, pregs->preg_instance[d.seq].
     entered_tz = pa.action_tz, pregs->preg_instance[d.seq].instance_prsnl_id = pa.prsnl_id
     IF (pa.action_type_cd=auto_close_action_cd)
      pregs->preg_instance[d.seq].auto_closed_ind = 1
     ELSE
      pregs->preg_instance[d.seq].auto_closed_ind = 0
     ENDIF
    WITH nocounter
   ;end select
   IF (debug_ind=1)
    CALL echorecord(pregs)
   ENDIF
 END ;Subroutine
 SUBROUTINE querypregnancyreview(null)
   DECLARE request_cnt = i4 WITH protect, noconstant(size(request->pregnancies,5))
   DECLARE preg_cnt = i4 WITH protect, noconstant(size(pregs->preg_instance,5))
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE inst_idx = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM pregnancy_action pa,
     (dummyt d  WITH seq = size(pregs->preg_instance,5))
    PLAN (d)
     JOIN (pa
     WHERE (pa.pregnancy_instance_id=pregs->preg_instance[d.seq].pregnancy_instance_id)
      AND pa.action_type_cd=review_action_cd
      AND (pa.prsnl_id=reqinfo->updt_id))
    ORDER BY pa.action_dt_tm DESC
    HEAD d.seq
     pregs->preg_instance[d.seq].last_reviewed_dt_tm = pa.action_dt_tm
    WITH nocounter
   ;end select
   IF (debug_ind=1)
    CALL echorecord(pregs)
   ENDIF
 END ;Subroutine
 SUBROUTINE addpregnancyinstances(null)
   DECLARE preg_list_cnt = i4 WITH protect, noconstant(size(request->pregnancies,5))
   DECLARE inst_cnt = i4 WITH protect, noconstant(size(pregs->preg_instance,5))
   DECLARE preg_id = f8 WITH protect, noconstant(0.0)
   DECLARE inst_idx = i4 WITH protect, noconstant(0)
   DECLARE bfound = i2 WITH protect, noconstant(0)
   DECLARE preg = i4 WITH protect, noconstant(0)
   DECLARE inst = i4 WITH protect, noconstant(0)
   DECLARE entity = i4 WITH protect, noconstant(0)
   DECLARE entity_cnt = i4 WITH protect, noconstant(0)
   SET stat = alterlist(reply->pregnancies,preg_list_cnt)
   FOR (preg = 1 TO preg_list_cnt)
     SET preg_id = request->pregnancies[preg].pregnancy_id
     SET inst_idx = 0
     SET bfound = 0
     FOR (inst = 1 TO inst_cnt)
       IF ((preg_id=pregs->preg_instance[inst].pregnancy_id))
        SET bfound = 1
        SET inst_idx += 1
        IF (mod(inst_idx,10)=1)
         SET stat = alterlist(reply->pregnancies[preg].preg_instance,(inst_idx+ 9))
        ENDIF
        SET reply->pregnancies[preg].preg_instance[inst_idx].pregnancy_id = pregs->preg_instance[inst
        ].pregnancy_id
        SET reply->pregnancies[preg].preg_instance[inst_idx].pregnancy_instance_id = pregs->
        preg_instance[inst].pregnancy_instance_id
        SET reply->pregnancies[preg].preg_instance[inst_idx].person_id = pregs->preg_instance[inst].
        person_id
        SET reply->pregnancies[preg].preg_instance[inst_idx].problem_id = pregs->preg_instance[inst].
        problem_id
        SET reply->pregnancies[preg].preg_instance[inst_idx].instance_prsnl_id = pregs->
        preg_instance[inst].instance_prsnl_id
        SET reply->pregnancies[preg].preg_instance[inst_idx].entered_dt_tm = pregs->preg_instance[
        inst].entered_dt_tm
        SET reply->pregnancies[preg].preg_instance[inst_idx].entered_tz = pregs->preg_instance[inst].
        entered_tz
        SET reply->pregnancies[preg].preg_instance[inst_idx].sensitive_ind = pregs->preg_instance[
        inst].sensitive_ind
        SET reply->pregnancies[preg].preg_instance[inst_idx].preg_start_dt_tm = pregs->preg_instance[
        inst].preg_start_dt_tm
        SET reply->pregnancies[preg].preg_instance[inst_idx].preg_end_dt_tm = pregs->preg_instance[
        inst].preg_end_dt_tm
        SET reply->pregnancies[preg].preg_instance[inst_idx].override_comment = pregs->preg_instance[
        inst].override_comment
        SET reply->pregnancies[preg].preg_instance[inst_idx].confirmation_dt_tm = pregs->
        preg_instance[inst].confirmation_dt_tm
        SET reply->pregnancies[preg].preg_instance[inst_idx].updt_dt_tm = pregs->preg_instance[inst].
        updt_dt_tm
        SET reply->pregnancies[preg].preg_instance[inst_idx].org_id = pregs->preg_instance[inst].
        org_id
        SET reply->pregnancies[preg].preg_instance[inst_idx].last_reviewed_dt_tm = pregs->
        preg_instance[inst].last_reviewed_dt_tm
        SET reply->pregnancies[preg].preg_instance[inst_idx].deleted_ind = pregs->preg_instance[inst]
        .deleted_ind
        SET reply->pregnancies[preg].preg_instance[inst_idx].auto_closed_ind = pregs->preg_instance[
        inst].auto_closed_ind
        SET pregs->preg_instance[inst].preg_idx = preg
        SET pregs->preg_instance[inst].inst_idx = inst_idx
        SET entity_cnt = size(pregs->preg_instance[inst].preg_entities,5)
        SET stat = alterlist(reply->pregnancies[preg].preg_instance[inst_idx].pregnancy_entities,
         entity_cnt)
        FOR (entity = 1 TO entity_cnt)
          SET reply->pregnancies[preg].preg_instance[inst_idx].pregnancy_entities[entity].
          parent_entity_id = pregs->preg_instance[inst].preg_entities[entity].parent_entity_id
          SET reply->pregnancies[preg].preg_instance[inst_idx].pregnancy_entities[entity].
          parent_entity_name = pregs->preg_instance[inst].preg_entities[entity].parent_entity_name
          SET reply->pregnancies[preg].preg_instance[inst_idx].pregnancy_entities[entity].
          component_type_cd = pregs->preg_instance[inst].preg_entities[entity].component_type_cd
        ENDFOR
       ENDIF
     ENDFOR
     IF (bfound=0)
      IF (debug_ind=1)
       CALL echo(build("Pregnancy_id: ",preg_id," has no qualifying data"))
      ENDIF
      CALL fillsubeventstatus("SELECT","Z","PREGNANCY_INSTANCE",build("pregnancy_id:",preg_id,
        " has no qualifying instances"))
     ELSE
      SET bfound = 0
     ENDIF
     SET stat = alterlist(reply->pregnancies[preg].preg_instance,inst_idx)
   ENDFOR
 END ;Subroutine
 SUBROUTINE querypregnancychild(null)
   DECLARE list_cnt = i4 WITH protect, noconstant(size(request->pregnancies,5))
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE child_idx = i4 WITH protect, noconstant(0)
   DECLARE entity_idx = i4 WITH protect, noconstant(0)
   DECLARE nomen_idx = i4 WITH protect, noconstant(0)
   DECLARE nomen_cnt = i4 WITH protect, noconstant(0)
   DECLARE lt_cnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM pregnancy_child pc,
     pregnancy_child_entity_r pcer,
     long_text lt
    PLAN (pc
     WHERE expand(idx,1,list_cnt,pc.pregnancy_id,request->pregnancies[idx].pregnancy_id))
     JOIN (pcer
     WHERE (pcer.pregnancy_child_id= Outerjoin(pc.pregnancy_child_id)) )
     JOIN (lt
     WHERE (lt.long_text_id= Outerjoin(pc.child_comment_id)) )
    ORDER BY pc.beg_effective_dt_tm DESC, pc.delivery_dt_tm, pc.pregnancy_child_id
    HEAD REPORT
     child_idx = 0
    HEAD pc.pregnancy_child_id
     entity_idx = 0, child_idx += 1
     IF (mod(child_idx,10)=1)
      stat = alterlist(children->child,(child_idx+ 9))
     ENDIF
     children->child[child_idx].pregnancy_child_id = pc.pregnancy_child_id, children->child[child_idx
     ].pregnancy_instance_id = pc.pregnancy_instance_id, children->child[child_idx].pregnancy_id = pc
     .pregnancy_id,
     children->child[child_idx].gender_cd = pc.gender_cd, children->child[child_idx].child_name = pc
     .child_name, children->child[child_idx].person_id = pc.person_id,
     children->child[child_idx].father_name = pc.father_name, children->child[child_idx].
     delivery_method_cd = pc.delivery_method_cd, children->child[child_idx].delivery_hospital = pc
     .delivery_hospital,
     children->child[child_idx].gestation_age = pc.gestation_age, children->child[child_idx].
     gestation_term_txt = pc.gestation_term_txt, children->child[child_idx].labor_duration = pc
     .labor_duration,
     children->child[child_idx].weight_amt = pc.weight_amt, children->child[child_idx].weight_unit_cd
      = pc.weight_unit_cd, children->child[child_idx].anesthesia_txt = pc.anesthesia_txt,
     children->child[child_idx].preterm_labor_txt = pc.preterm_labor_txt, children->child[child_idx].
     delivery_dt_tm = pc.delivery_dt_tm, children->child[child_idx].delivery_tz = pc.delivery_tz,
     children->child[child_idx].neonate_outcome_cd = pc.neonate_outcome_cd
     IF (lt.long_text_id > 0)
      children->child[child_idx].child_comment = lt.long_text
     ENDIF
     children->child[child_idx].delivery_date_precision_flag = pc.delivery_date_precision_flag,
     children->child[child_idx].delivery_date_qualifier_flag = pc.delivery_date_qualifier_flag,
     children->child[child_idx].beg_effective_dt_tm = pc.beg_effective_dt_tm,
     children->child[child_idx].end_effective_dt_tm = pc.end_effective_dt_tm
    DETAIL
     IF (pcer.parent_entity_id > 0)
      entity_idx += 1
      IF (mod(entity_idx,10)=1)
       stat = alterlist(children->child[child_idx].entities,(entity_idx+ 9))
      ENDIF
      children->child[child_idx].entities[entity_idx].parent_entity_id = pcer.parent_entity_id,
      children->child[child_idx].entities[entity_idx].pregnancy_child_id = pcer.pregnancy_child_id,
      children->child[child_idx].entities[entity_idx].parent_entity_name = pcer.parent_entity_name,
      children->child[child_idx].entities[entity_idx].component_type_cd = pcer.component_type_cd
      IF (pcer.parent_entity_name="NOMENCLATURE")
       nomen_cnt += 1
       IF (mod(nomen_cnt,5)=1)
        stat = alterlist(nomenclature->nomens,(nomen_cnt+ 4))
       ENDIF
       nomenclature->nomens[nomen_cnt].nomenclature_id = pcer.parent_entity_id
      ELSEIF (pcer.parent_entity_name="LONG_TEXT")
       lt_cnt += 1
       IF (mod(lt_cnt,5)=1)
        stat = alterlist(long_text->entities,(lt_cnt+ 4))
       ENDIF
       long_text->entities[lt_cnt].long_text_id = pcer.parent_entity_id
      ENDIF
     ENDIF
    FOOT  pc.pregnancy_child_id
     stat = alterlist(children->child[child_idx].entities,entity_idx)
    FOOT REPORT
     stat = alterlist(children->child,child_idx)
    WITH nocounter
   ;end select
   SET stat = alterlist(nomenclature->nomens,nomen_cnt)
   SET stat = alterlist(long_text->entities,lt_cnt)
   CALL querylongtext(null)
   CALL querynomenclature(null)
   IF (debug_ind=1)
    CALL echorecord(children)
   ENDIF
 END ;Subroutine
 SUBROUTINE querylongtext(null)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE lt_cnt = i4 WITH protect, noconstant(size(long_text->entities,5))
   DECLARE lt_idx = i4 WITH protect, noconstant(0)
   DECLARE child = i4 WITH protect, noconstant(0)
   DECLARE entity = i4 WITH protect, noconstant(0)
   DECLARE child_cnt = i4 WITH protect, noconstant(size(children->child,5))
   DECLARE entity_cnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM long_text lt
    PLAN (lt
     WHERE expand(idx,1,lt_cnt,lt.long_text_id,long_text->entities[idx].long_text_id))
    DETAIL
     lt_idx = locateval(idx,1,lt_cnt,lt.long_text_id,long_text->entities[idx].long_text_id)
     IF (lt_idx > 0)
      long_text->entities[lt_idx].long_text = lt.long_text
     ENDIF
    WITH nocounter
   ;end select
   FOR (child = 1 TO child_cnt)
    SET entity_cnt = size(children->child[child].entities,5)
    FOR (entity = 1 TO entity_cnt)
     SET lt_idx = locateval(idx,1,lt_cnt,children->child[child].entities[entity].parent_entity_id,
      long_text->entities[idx].long_text_id)
     IF (lt_idx > 0)
      SET children->child[child].entities[entity].entity_text = long_text->entities[lt_idx].long_text
     ENDIF
    ENDFOR
   ENDFOR
   IF (debug_ind=1)
    CALL echorecord(long_text)
   ENDIF
 END ;Subroutine
 SUBROUTINE querynomenclature(null)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE nomen_cnt = i4 WITH protect, noconstant(size(nomenclature->nomens,5))
   DECLARE nomen_idx = i4 WITH protect, noconstant(0)
   DECLARE child = i4 WITH protect, noconstant(0)
   DECLARE entity = i4 WITH protect, noconstant(0)
   DECLARE child_cnt = i4 WITH protect, noconstant(size(children->child,5))
   DECLARE entity_cnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM nomenclature n
    PLAN (n
     WHERE expand(idx,1,nomen_cnt,n.nomenclature_id,nomenclature->nomens[idx].nomenclature_id))
    DETAIL
     nomen_idx = locateval(idx,1,nomen_cnt,n.nomenclature_id,nomenclature->nomens[idx].
      nomenclature_id)
     IF (nomen_idx > 0)
      nomenclature->nomens[nomen_idx].source_string = n.source_string
     ENDIF
    WITH nocounter
   ;end select
   FOR (child = 1 TO child_cnt)
    SET entity_cnt = size(children->child[child].entities,5)
    FOR (entity = 1 TO entity_cnt)
     SET nomen_idx = locateval(idx,1,nomen_cnt,children->child[child].entities[entity].
      parent_entity_id,nomenclature->nomens[idx].nomenclature_id)
     IF (nomen_idx > 0)
      SET children->child[child].entities[entity].entity_text = nomenclature->nomens[nomen_idx].
      source_string
     ENDIF
    ENDFOR
   ENDFOR
   IF (debug_ind=1)
    CALL echorecord(nomenclature)
   ENDIF
 END ;Subroutine
 SUBROUTINE addchildrentopregnancy(null)
   DECLARE preg_idx = i4 WITH protect, noconstant(0)
   DECLARE inst_idx = i4 WITH protect, noconstant(0)
   DECLARE child_idx = i4 WITH protect, noconstant(0)
   DECLARE entity_idx = i4 WITH protect, noconstant(0)
   DECLARE preg_cnt = i4 WITH protect, noconstant(size(reply->pregnancies,5))
   DECLARE inst_cnt = i4 WITH protect, noconstant(0)
   DECLARE child_cnt = i4 WITH protect, noconstant(0)
   DECLARE entity_cnt = i4 WITH protect, noconstant(0)
   SET inst_cnt = size(pregs->preg_instance,5)
   FOR (inst = 1 TO inst_cnt)
     SET child_cnt = size(children->child,5)
     SET child_idx = 0
     SET preg_idx = 0
     SET inst_idx = 0
     FOR (child = 1 TO child_cnt)
       IF ((pregs->preg_instance[inst].pregnancy_instance_id=children->child[child].
       pregnancy_instance_id))
        SET entity_idx = 0
        SET preg_idx = pregs->preg_instance[inst].preg_idx
        SET inst_idx = pregs->preg_instance[inst].inst_idx
        SET child_idx += 1
        IF (mod(child_idx,10)=1)
         SET stat = alterlist(reply->pregnancies[preg_idx].preg_instance[inst_idx].pregnancy_children,
          (child_idx+ 9))
        ENDIF
        SET reply->pregnancies[preg_idx].preg_instance[inst_idx].pregnancy_children[child_idx].
        pregnancy_child_id = children->child[child].pregnancy_child_id
        SET reply->pregnancies[preg_idx].preg_instance[inst_idx].pregnancy_children[child_idx].
        gender_cd = children->child[child].gender_cd
        SET reply->pregnancies[preg_idx].preg_instance[inst_idx].pregnancy_children[child_idx].
        child_name = children->child[child].child_name
        SET reply->pregnancies[preg_idx].preg_instance[inst_idx].pregnancy_children[child_idx].
        person_id = children->child[child].person_id
        SET reply->pregnancies[preg_idx].preg_instance[inst_idx].pregnancy_children[child_idx].
        father_name = children->child[child].father_name
        SET reply->pregnancies[preg_idx].preg_instance[inst_idx].pregnancy_children[child_idx].
        delivery_method_cd = children->child[child].delivery_method_cd
        SET reply->pregnancies[preg_idx].preg_instance[inst_idx].pregnancy_children[child_idx].
        delivery_hospital = children->child[child].delivery_hospital
        SET reply->pregnancies[preg_idx].preg_instance[inst_idx].pregnancy_children[child_idx].
        gestation_age = children->child[child].gestation_age
        SET reply->pregnancies[preg_idx].preg_instance[inst_idx].pregnancy_children[child_idx].
        gestation_term_txt = children->child[child].gestation_term_txt
        SET reply->pregnancies[preg_idx].preg_instance[inst_idx].pregnancy_children[child_idx].
        labor_duration = children->child[child].labor_duration
        SET reply->pregnancies[preg_idx].preg_instance[inst_idx].pregnancy_children[child_idx].
        weight_amt = children->child[child].weight_amt
        SET reply->pregnancies[preg_idx].preg_instance[inst_idx].pregnancy_children[child_idx].
        weight_unit_cd = children->child[child].weight_unit_cd
        SET reply->pregnancies[preg_idx].preg_instance[inst_idx].pregnancy_children[child_idx].
        anesthesia_txt = children->child[child].anesthesia_txt
        SET reply->pregnancies[preg_idx].preg_instance[inst_idx].pregnancy_children[child_idx].
        preterm_labor_txt = children->child[child].preterm_labor_txt
        SET reply->pregnancies[preg_idx].preg_instance[inst_idx].pregnancy_children[child_idx].
        delivery_dt_tm = children->child[child].delivery_dt_tm
        SET reply->pregnancies[preg_idx].preg_instance[inst_idx].pregnancy_children[child_idx].
        delivery_tz = children->child[child].delivery_tz
        SET reply->pregnancies[preg_idx].preg_instance[inst_idx].pregnancy_children[child_idx].
        neonate_outcome_cd = children->child[child].neonate_outcome_cd
        SET reply->pregnancies[preg_idx].preg_instance[inst_idx].pregnancy_children[child_idx].
        child_comment = children->child[child].child_comment
        SET reply->pregnancies[preg_idx].preg_instance[inst_idx].pregnancy_children[child_idx].
        delivery_date_precision_flag = children->child[child].delivery_date_precision_flag
        SET reply->pregnancies[preg_idx].preg_instance[inst_idx].pregnancy_children[child_idx].
        delivery_date_qualifier_flag = children->child[child].delivery_date_qualifier_flag
        SET entity_cnt = size(children->child[child].entities,5)
        FOR (entity = 1 TO entity_cnt)
          SET entity_idx += 1
          IF (mod(entity_idx,10)=1)
           SET stat = alterlist(reply->pregnancies[preg_idx].preg_instance[inst_idx].
            pregnancy_children[child_idx].child_entities,(entity_idx+ 9))
          ENDIF
          SET reply->pregnancies[preg_idx].preg_instance[inst_idx].pregnancy_children[child_idx].
          child_entities[entity_idx].parent_entity_id = children->child[child].entities[entity].
          parent_entity_id
          SET reply->pregnancies[preg_idx].preg_instance[inst_idx].pregnancy_children[child_idx].
          child_entities[entity_idx].parent_entity_name = children->child[child].entities[entity].
          parent_entity_name
          SET reply->pregnancies[preg_idx].preg_instance[inst_idx].pregnancy_children[child_idx].
          child_entities[entity_idx].component_type_cd = children->child[child].entities[entity].
          component_type_cd
          SET reply->pregnancies[preg_idx].preg_instance[inst_idx].pregnancy_children[child_idx].
          child_entities[entity_idx].entity_text = children->child[child].entities[entity].
          entity_text
        ENDFOR
        SET stat = alterlist(reply->pregnancies[preg_idx].preg_instance[inst_idx].pregnancy_children[
         child_idx].child_entities,entity_idx)
       ENDIF
     ENDFOR
     IF (preg_idx > 0
      AND inst_idx > 0)
      SET stat = alterlist(reply->pregnancies[preg_idx].preg_instance[inst_idx].pregnancy_children,
       child_idx)
     ENDIF
   ENDFOR
 END ;Subroutine
#exit_script
 SET error_code = error(error_msg,1)
 IF (error_code != 0)
  SET reply->status_data.status = "F"
  CALL fillsubeventstatus("ERROR","F","dcp_get_pregnancy_versions",error_msg)
 ELSEIF (fail_ind=true)
  SET reply->status_data.status = "F"
  CALL echo("*Get Pregnancy Versions Failed*")
 ELSEIF (zero_ind=true)
  CALL echo("*Get Pregnancy Versions has no results*")
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 FREE RECORD pregs
 FREE RECORD children
 FREE RECORD nomenclature
 FREE RECORD long_text
 CALL echorecord(reply)
 SET last_mod = "003 07/10/15"
 CALL echo(build("Script was last modified on:",last_mod))
 SET modify = nopredeclare
END GO
