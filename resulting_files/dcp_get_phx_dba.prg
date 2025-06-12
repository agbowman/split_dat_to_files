CREATE PROGRAM dcp_get_phx:dba
 RECORD reply(
   1 updt_dt_tm = dq8
   1 pregnancies[*]
     2 pregnancy_id = f8
     2 pregnancy_instance_id = f8
     2 person_id = f8
     2 problem_id = f8
     2 sensitive_ind = i2
     2 preg_start_dt_tm = dq8
     2 preg_end_dt_tm = dq8
     2 override_comment = vc
     2 confirmation_dt_tm = dq8
     2 updt_dt_tm = dq8
     2 pregnancy_entities[*]
       3 parent_entity_name = vc
       3 parent_entity_id = f8
       3 component_type_cd = f8
     2 pregnancy_actions[*]
       3 action_dt_tm = dq8
       3 action_tz = i4
       3 action_type_cd = f8
       3 prsnl_id = f8
     2 pregnancy_children[*]
       3 pregnancy_child_id = f8
       3 gender_cd = f8
       3 child_name = vc
       3 person_id = f8
       3 father_name = vc
       3 delivery_method_cd = f8
       3 delivery_hospital = vc
       3 gestation_age = i4
       3 labor_duration = i4
       3 weight_amt = f8
       3 weight_unit_cd = f8
       3 anesthesia_txt = vc
       3 preterm_labor_txt = vc
       3 delivery_dt_tm = dq8
       3 delivery_tz = i4
       3 neonate_outcome_cd = f8
       3 child_comment = vc
       3 child_entities[*]
         4 parent_entity_name = vc
         4 parent_entity_id = f8
         4 component_type_cd = f8
         4 entity_text = vc
       3 delivery_date_precision_flag = i2
       3 delivery_date_qualifier_flag = i2
       3 restrict_person_id_ind = i2
       3 gestation_term_txt = vc
     2 org_id = f8
     2 historical_ind = i2
   1 nomenclature_info[*]
     2 nomenclature_id = f8
     2 source_string = vc
   1 pregnancy_documents[*]
     2 event_id = f8
     2 event_cd = f8
     2 event_title_text = vc
     2 result_status_cd = f8
     2 performed_prsnl_id = f8
     2 event_end_dt_tm = dq8
   1 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH persistscript
 RECORD temp_rec_child(
   1 pregnancy_children[*]
     2 pregnancy_child_id = f8
     2 preg_child_idx = i4
     2 preg_idx = i4
     2 child_comment = f8
 )
 RECORD temp_rec_nomen(
   1 nomenclature_info[*]
     2 nomenclature_id = f8
 )
 RECORD temp_rec_lt(
   1 lt_info[*]
     2 long_text_id = f8
     2 preg_child_idx = i4
     2 preg_idx = i4
     2 preg_child_entity_idx = i4
 )
 RECORD temp_ce_struct(
   1 events[*]
     2 event_id = f8
     2 preg_idx = f8
     2 end_time = dq8
 )
 RECORD temp_rec_pi(
   1 pregnancies[*]
     2 pregnancy_id = f8
 )
 RECORD active_preg_request(
   1 patient_id = f8
   1 encntr_id = f8
   1 org_sec_override = i2
 )
 DECLARE preg_cnt = i4 WITH public, noconstant(size(request->pregnancies,5))
 DECLARE preg_idx = i4 WITH public, noconstant(0)
 DECLARE action_idx = i4 WITH public, noconstant(0)
 DECLARE entity_idx = i4 WITH public, noconstant(0)
 DECLARE child_idx = i4 WITH public, noconstant(0)
 DECLARE ce_idx = i4 WITH public, noconstant(0)
 DECLARE max_children = i4 WITH public, noconstant(0)
 DECLARE max_entities = i4 WITH public, noconstant(0)
 DECLARE end_date_str = vc WITH protected, constant("31-DEC-2100")
 DECLARE related_doc_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",4002108,"RELATEDDOC"))
 DECLARE doc_idx = i4 WITH public, noconstant(0)
 DECLARE ce_count = i4 WITH public, noconstant(0)
 DECLARE locate_idx = i4 WITH public, noconstant(0)
 DECLARE preg_inst_id = f8 WITH protect, noconstant(0.0)
 DECLARE batch_size = i4 WITH public, noconstant(50)
 DECLARE cur_list_size = i4 WITH public, noconstant(0)
 DECLARE loop_cnt = i4 WITH public, noconstant(0)
 DECLARE new_list_size = i4 WITH public, noconstant(0)
 DECLARE nstart = i4 WITH public, noconstant(0)
 DECLARE event_idx = i4 WITH public, noconstant(0)
 DECLARE stat = i4 WITH public, noconstant(0)
 DECLARE getpregnancyactions(null) = null
 DECLARE getpregnancychild(null) = null
 DECLARE getpregnancychildinfo(null) = null
 DECLARE getpregnancydocumentinfo(null) = null
 DECLARE getnomenclatureinfo(null) = null
 DECLARE getlongtextinfo(null) = null
 DECLARE fillpreginfo(null) = null
 DECLARE fillpregnancyentityinfo(null) = null
 SET modify = predeclare
 SET reply->status_data.status = "F"
 SET reply->active_ind = 0
 CALL echorecord(request)
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
 IF ((request->person_id > 0.0))
  SET active_preg_request->patient_id = request->person_id
  SET active_preg_request->encntr_id = request->encntr_id
  SET active_preg_request->org_sec_override = request->org_sec_override
  EXECUTE dcp_chk_active_preg  WITH replace("REQUEST",active_preg_request), replace("REPLY",
   active_preg_reply)
  IF ((active_preg_reply->status_data.status="F"))
   GO TO exit_script
  ELSEIF ((active_preg_reply->status_data.status="S"))
   SET reply->active_ind = 1
  ENDIF
 ENDIF
 IF (preg_cnt=0
  AND (request->person_id > 0.0))
  SELECT
   IF ((((request->org_sec_override=1)) OR (preg_org_sec_ind=0)) )
    FROM pregnancy_instance pi
    WHERE (pi.person_id=request->person_id)
   ELSE
    FROM pregnancy_instance pi,
     (dummyt d  WITH seq = size(preg_sec_orgs->qual,5))
    PLAN (pi
     WHERE (pi.person_id=request->person_id))
     JOIN (d
     WHERE (pi.organization_id=preg_sec_orgs->qual[d.seq].org_id))
   ENDIF
   INTO "nl:"
   pi.updt_dt_tm
   DETAIL
    preg_idx = 0
   FOOT REPORT
    reply->updt_dt_tm = max(pi.updt_dt_tm)
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_data.status = "Z"
   GO TO exit_script
  ENDIF
  SELECT
   IF ((((request->org_sec_override=1)) OR (preg_org_sec_ind=0)) )
    FROM pregnancy_instance pi,
     pregnancy_entity_r per
    PLAN (pi
     WHERE (pi.person_id=request->person_id)
      AND pi.active_ind=1
      AND pi.preg_end_dt_tm < cnvtdatetime(end_date_str))
     JOIN (per
     WHERE (per.pregnancy_id= Outerjoin(pi.pregnancy_id))
      AND (per.active_ind= Outerjoin(1)) )
   ELSE
    FROM pregnancy_instance pi,
     pregnancy_entity_r per,
     (dummyt d  WITH seq = size(preg_sec_orgs->qual,5))
    PLAN (pi
     WHERE (pi.person_id=request->person_id)
      AND pi.active_ind=1
      AND pi.preg_end_dt_tm < cnvtdatetime(end_date_str))
     JOIN (per
     WHERE (per.pregnancy_id= Outerjoin(pi.pregnancy_id))
      AND (per.active_ind= Outerjoin(1)) )
     JOIN (d
     WHERE (pi.organization_id=preg_sec_orgs->qual[d.seq].org_id))
   ENDIF
   INTO "nl:"
   ORDER BY pi.pregnancy_id
   HEAD REPORT
    preg_idx = 0, ce_count = 0
   HEAD pi.pregnancy_id
    CALL fillpreginfo(null), entity_idx = 0
   DETAIL
    IF (per.pregnancy_entity_id > 0)
     CALL fillpregentityinfo(null)
    ENDIF
   FOOT  pi.pregnancy_id
    stat = alterlist(reply->pregnancies[preg_idx].pregnancy_entities,entity_idx)
   FOOT REPORT
    stat = alterlist(reply->pregnancies,preg_idx), stat = alterlist(temp_ce_struct->events,ce_count)
   WITH nocounter
  ;end select
 ELSEIF (preg_cnt=0
  AND (request->problem_id > 0.0))
  SELECT
   IF ((((request->org_sec_override=1)) OR (preg_org_sec_ind=0)) )
    FROM pregnancy_instance pi,
     pregnancy_entity_r per
    PLAN (pi
     WHERE (pi.problem_id=request->problem_id)
      AND pi.active_ind=1
      AND pi.preg_end_dt_tm < cnvtdatetime(end_date_str))
     JOIN (per
     WHERE (per.pregnancy_id= Outerjoin(pi.pregnancy_id))
      AND (per.active_ind= Outerjoin(1)) )
   ELSE
    FROM pregnancy_instance pi,
     pregnancy_entity_r per,
     (dummyt d  WITH seq = size(preg_sec_orgs->qual,5))
    PLAN (pi
     WHERE (pi.problem_id=request->problem_id)
      AND pi.active_ind=1
      AND pi.preg_end_dt_tm < cnvtdatetime(end_date_str))
     JOIN (per
     WHERE (per.pregnancy_id= Outerjoin(pi.pregnancy_id))
      AND (per.active_ind= Outerjoin(1)) )
     JOIN (d
     WHERE (pi.organization_id=preg_sec_orgs->qual[d.seq].org_id))
   ENDIF
   INTO "nl:"
   ORDER BY pi.pregnancy_id
   HEAD REPORT
    preg_idx = 0
   HEAD pi.pregnancy_id
    CALL fillpreginfo(null), entity_idx = 0, ce_count = 0
   DETAIL
    IF (per.pregnancy_entity_id > 0)
     CALL fillpregentityinfo(null)
    ENDIF
   FOOT  pi.pregnancy_id
    stat = alterlist(reply->pregnancies[preg_idx].pregnancy_entities,entity_idx)
   FOOT REPORT
    stat = alterlist(reply->pregnancies,preg_idx), stat = alterlist(temp_ce_struct->events,ce_count),
    preg_cnt = preg_idx
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_data.status = "Z"
   GO TO exit_script
  ENDIF
 ELSE
  SET batch_size = 20
  SET loop_cnt = ceil((cnvtreal(preg_cnt)/ batch_size))
  SET new_list_size = (loop_cnt * batch_size)
  SET stat = alterlist(temp_rec_pi->pregnancies,new_list_size)
  FOR (idx = 1 TO preg_cnt)
    SET temp_rec_pi->pregnancies[idx].pregnancy_id = request->pregnancies[preg_cnt].pregnancy_id
  ENDFOR
  FOR (idx = (preg_cnt+ 1) TO new_list_size)
    SET temp_rec_pi->pregnancies[idx].pregnancy_id = temp_rec_pi->pregnancies[preg_cnt].pregnancy_id
  ENDFOR
  SET nstart = 1
  SELECT INTO "nl:"
   FROM (dummyt dpi  WITH seq = value(loop_cnt)),
    pregnancy_instance pi
   PLAN (dpi
    WHERE initarray(nstart,evaluate(dpi.seq,1,1,(nstart+ batch_size))))
    JOIN (pi
    WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),pi.pregnancy_id,temp_rec_pi->pregnancies[idx].
     pregnancy_id)
     AND pi.active_ind=1)
   ORDER BY pi.pregnancy_id
   HEAD REPORT
    preg_idx = 0
   HEAD pi.pregnancy_id
    CALL fillpreginfo(null)
   FOOT REPORT
    stat = alterlist(reply->pregnancies,preg_idx)
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_data.status = "Z"
   GO TO exit_script
  ENDIF
  SET nstart = 1
  SELECT INTO "nl:"
   FROM (dummyt dper  WITH seq = value(loop_cnt)),
    pregnancy_entity_r per
   PLAN (dper
    WHERE initarray(nstart,evaluate(dper.seq,1,1,(nstart+ batch_size))))
    JOIN (per
    WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),per.pregnancy_id,temp_rec_pi->pregnancies[idx]
     .pregnancy_id))
   ORDER BY per.pregnancy_id
   HEAD per.pregnancy_id
    entity_idx = 0, ce_count = 0, preg_idx = locateval(idx,1,preg_cnt,per.pregnancy_id,reply->
     pregnancies[idx].pregnancy_id)
   DETAIL
    IF (preg_idx != 0)
     CALL fillpregentityinfo(null)
    ENDIF
   FOOT  per.pregnancy_id
    stat = alterlist(reply->pregnancies[preg_idx].pregnancy_entities,entity_idx)
   WITH nocounter
  ;end select
 ENDIF
 SET batch_size = 20
 DECLARE preghx_cnt = i4 WITH noconstant(size(reply->pregnancies,5))
 IF (preghx_cnt=0)
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 SET loop_cnt = ceil((cnvtreal(preghx_cnt)/ batch_size))
 SET new_list_size = (loop_cnt * batch_size)
 SET stat = alterlist(reply->pregnancies,new_list_size)
 FOR (idx = (preghx_cnt+ 1) TO new_list_size)
   SET reply->pregnancies[idx].pregnancy_id = reply->pregnancies[preghx_cnt].pregnancy_id
 ENDFOR
 IF (validate(request->reopen_flag_ind,0)=1)
  SELECT INTO "n1"
   FROM pregnancy_child pc
   WHERE (pc.pregnancy_id=request->pregnancies[preg_cnt].pregnancy_id)
   ORDER BY pc.pregnancy_instance_id
   HEAD pc.pregnancy_instance_id
    preg_inst_id = pc.pregnancy_instance_id
   WITH nocounter
  ;end select
 ENDIF
 CALL getpregnancyactions(null)
 CALL getpregnancychild(null)
 CALL getpregnancychildinfo(null)
 CALL getpregnancydocumentinfo(null)
 CALL getnomenclatureinfo(null)
 CALL getlongtextinfo(null)
 FREE RECORD temp_rec_child
 FREE RECORD temp_rec_nomen
 FREE RECORD temp_ce_struct
 FREE RECORD temp_rec_lt
 FREE RECORD temp_rec_pi
 SET stat = alterlist(reply->pregnancies,preghx_cnt)
 SUBROUTINE fillpreginfo(null)
   SET preg_idx += 1
   IF (mod(preg_idx,5)=1)
    SET stat = alterlist(reply->pregnancies,(preg_idx+ 4))
   ENDIF
   SET reply->pregnancies[preg_idx].pregnancy_id = pi.pregnancy_id
   SET reply->pregnancies[preg_idx].pregnancy_instance_id = pi.pregnancy_instance_id
   SET reply->pregnancies[preg_idx].person_id = pi.person_id
   SET reply->pregnancies[preg_idx].org_id = pi.organization_id
   SET reply->pregnancies[preg_idx].problem_id = pi.problem_id
   SET reply->pregnancies[preg_idx].sensitive_ind = pi.sensitive_ind
   SET reply->pregnancies[preg_idx].preg_start_dt_tm = pi.preg_start_dt_tm
   SET reply->pregnancies[preg_idx].preg_end_dt_tm = pi.preg_end_dt_tm
   SET reply->pregnancies[preg_idx].override_comment = pi.override_comment
   SET reply->pregnancies[preg_idx].confirmation_dt_tm = pi.confirmed_dt_tm
   SET reply->pregnancies[preg_idx].updt_dt_tm = pi.updt_dt_tm
   SET reply->pregnancies[preg_idx].historical_ind = pi.historical_ind
 END ;Subroutine
 SUBROUTINE fillpregentityinfo(null)
   SET entity_idx += 1
   IF (mod(entity_idx,5)=1)
    SET stat = alterlist(reply->pregnancies[preg_idx].pregnancy_entities,(entity_idx+ 4))
   ENDIF
   SET reply->pregnancies[preg_idx].pregnancy_entities[entity_idx].component_type_cd = per
   .component_type_cd
   SET reply->pregnancies[preg_idx].pregnancy_entities[entity_idx].parent_entity_id = per
   .parent_entity_id
   SET reply->pregnancies[preg_idx].pregnancy_entities[entity_idx].parent_entity_name = per
   .parent_entity_name
   IF (per.component_type_cd=related_doc_cd)
    SET ce_count += 1
    IF (mod(ce_count,5)=1)
     SET stat = alterlist(temp_ce_struct->events,(ce_count+ 4))
    ENDIF
    SET temp_ce_struct->events[ce_count].event_id = per.parent_entity_id
    SET temp_ce_struct->events[ce_count].preg_idx = preg_idx
    SET temp_ce_struct->events[ce_count].end_time = cnvtdatetime(end_date_str)
   ENDIF
 END ;Subroutine
 SUBROUTINE getpregnancyactions(null)
  SET nstart = 1
  SELECT INTO "nl:"
   FROM (dummyt dpa  WITH seq = value(loop_cnt)),
    pregnancy_action pa
   PLAN (dpa
    WHERE initarray(nstart,evaluate(dpa.seq,1,1,(nstart+ batch_size))))
    JOIN (pa
    WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),pa.pregnancy_id,reply->pregnancies[idx].
     pregnancy_id))
   ORDER BY pa.pregnancy_id
   HEAD pa.pregnancy_id
    action_idx = 0, preg_idx = locateval(locate_idx,1,preghx_cnt,pa.pregnancy_id,reply->pregnancies[
     locate_idx].pregnancy_id)
   DETAIL
    IF ((reply->pregnancies[preg_idx].pregnancy_id=pa.pregnancy_id))
     action_idx += 1
     IF (mod(action_idx,5)=1)
      stat = alterlist(reply->pregnancies[preg_idx].pregnancy_actions,(action_idx+ 4))
     ENDIF
     reply->pregnancies[preg_idx].pregnancy_actions[action_idx].action_dt_tm = pa.action_dt_tm, reply
     ->pregnancies[preg_idx].pregnancy_actions[action_idx].action_type_cd = pa.action_type_cd, reply
     ->pregnancies[preg_idx].pregnancy_actions[action_idx].action_tz = pa.action_tz,
     reply->pregnancies[preg_idx].pregnancy_actions[action_idx].prsnl_id = pa.prsnl_id
    ENDIF
   FOOT  pa.pregnancy_id
    stat = alterlist(reply->pregnancies[preg_idx].pregnancy_actions,action_idx)
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE getpregnancychild(null)
   SET nstart = 1
   DECLARE linear_idx = i4 WITH noconstant(0)
   SELECT
    IF (validate(request->reopen_flag_ind,0)=1)
     FROM (dummyt dpc  WITH seq = value(loop_cnt)),
      pregnancy_child pc
     PLAN (dpc
      WHERE initarray(nstart,evaluate(dpc.seq,1,1,(nstart+ batch_size))))
      JOIN (pc
      WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),pc.pregnancy_id,reply->pregnancies[idx].
       pregnancy_id)
       AND pc.active_ind=0
       AND pc.pregnancy_instance_id=preg_inst_id)
    ELSE
     FROM (dummyt dpc  WITH seq = value(loop_cnt)),
      pregnancy_child pc
     PLAN (dpc
      WHERE initarray(nstart,evaluate(dpc.seq,1,1,(nstart+ batch_size))))
      JOIN (pc
      WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),pc.pregnancy_id,reply->pregnancies[idx].
       pregnancy_id)
       AND pc.active_ind=1)
    ENDIF
    INTO "nl:"
    ORDER BY pc.pregnancy_id
    HEAD pc.pregnancy_id
     child_idx = 0, preg_idx = locateval(locate_idx,1,preghx_cnt,pc.pregnancy_id,reply->pregnancies[
      locate_idx].pregnancy_id)
    DETAIL
     linear_idx += 1
     IF (mod(linear_idx,5)=1)
      stat = alterlist(temp_rec_child->pregnancy_children,(linear_idx+ 4))
     ENDIF
     child_idx += 1
     IF (mod(child_idx,5)=1)
      stat = alterlist(reply->pregnancies[preg_idx].pregnancy_children,(child_idx+ 4))
     ENDIF
     reply->pregnancies[preg_idx].pregnancy_children[child_idx].pregnancy_child_id = pc
     .pregnancy_child_id, reply->pregnancies[preg_idx].pregnancy_children[child_idx].gender_cd = pc
     .gender_cd, reply->pregnancies[preg_idx].pregnancy_children[child_idx].child_name = pc
     .child_name,
     reply->pregnancies[preg_idx].pregnancy_children[child_idx].person_id = pc.person_id, reply->
     pregnancies[preg_idx].pregnancy_children[child_idx].father_name = pc.father_name, reply->
     pregnancies[preg_idx].pregnancy_children[child_idx].delivery_method_cd = pc.delivery_method_cd,
     reply->pregnancies[preg_idx].pregnancy_children[child_idx].delivery_hospital = pc
     .delivery_hospital, reply->pregnancies[preg_idx].pregnancy_children[child_idx].gestation_age =
     pc.gestation_age, reply->pregnancies[preg_idx].pregnancy_children[child_idx].gestation_term_txt
      = pc.gestation_term_txt,
     reply->pregnancies[preg_idx].pregnancy_children[child_idx].labor_duration = pc.labor_duration,
     reply->pregnancies[preg_idx].pregnancy_children[child_idx].weight_amt = pc.weight_amt, reply->
     pregnancies[preg_idx].pregnancy_children[child_idx].weight_unit_cd = pc.weight_unit_cd,
     reply->pregnancies[preg_idx].pregnancy_children[child_idx].anesthesia_txt = pc.anesthesia_txt,
     reply->pregnancies[preg_idx].pregnancy_children[child_idx].preterm_labor_txt = pc
     .preterm_labor_txt, reply->pregnancies[preg_idx].pregnancy_children[child_idx].delivery_dt_tm =
     pc.delivery_dt_tm,
     reply->pregnancies[preg_idx].pregnancy_children[child_idx].delivery_tz = pc.delivery_tz, reply->
     pregnancies[preg_idx].pregnancy_children[child_idx].neonate_outcome_cd = pc.neonate_outcome_cd,
     reply->pregnancies[preg_idx].pregnancy_children[child_idx].delivery_date_precision_flag = pc
     .delivery_date_precision_flag,
     reply->pregnancies[preg_idx].pregnancy_children[child_idx].delivery_date_qualifier_flag = pc
     .delivery_date_qualifier_flag, reply->pregnancies[preg_idx].pregnancy_children[child_idx].
     restrict_person_id_ind = pc.restrict_person_id_ind, temp_rec_child->pregnancy_children[
     linear_idx].pregnancy_child_id = pc.pregnancy_child_id,
     temp_rec_child->pregnancy_children[linear_idx].preg_idx = preg_idx, temp_rec_child->
     pregnancy_children[linear_idx].preg_child_idx = child_idx, temp_rec_child->pregnancy_children[
     linear_idx].child_comment = pc.child_comment_id
    FOOT  pc.pregnancy_id
     stat = alterlist(reply->pregnancies[preg_idx].pregnancy_children,child_idx)
    FOOT REPORT
     stat = alterlist(temp_rec_child->pregnancy_children,linear_idx),
     CALL echorecord(temp_rec_child)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE getpregnancychildinfo(null)
   SET batch_size = 20
   SET cur_list_size = size(temp_rec_child->pregnancy_children,5)
   IF (cur_list_size=0)
    RETURN
   ENDIF
   SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
   SET new_list_size = (loop_cnt * batch_size)
   SET stat = alterlist(temp_rec_child->pregnancy_children,new_list_size)
   SET nstart = 1
   FOR (idx = (cur_list_size+ 1) TO new_list_size)
    SET temp_rec_child->pregnancy_children[idx].pregnancy_child_id = temp_rec_child->
    pregnancy_children[cur_list_size].pregnancy_child_id
    SET temp_rec_child->pregnancy_children[idx].child_comment = temp_rec_child->pregnancy_children[
    cur_list_size].child_comment
   ENDFOR
   DECLARE preg_chldidx = i4 WITH noconstant(0)
   DECLARE rep_preg_idx = i4 WITH noconstant(0)
   DECLARE rep_preg_chldidx = i4 WITH noconstant(0)
   DECLARE nomen_cnt = i4 WITH noconstant(0)
   DECLARE long_text_cnt = i4 WITH noconstant(0)
   SELECT INTO "nl:"
    FROM (dummyt dpcer  WITH seq = value(loop_cnt)),
     pregnancy_child_entity_r pcer
    PLAN (dpcer
     WHERE initarray(nstart,evaluate(dpcer.seq,1,1,(nstart+ batch_size))))
     JOIN (pcer
     WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),pcer.pregnancy_child_id,temp_rec_child->
      pregnancy_children[idx].pregnancy_child_id)
      AND pcer.active_ind=1)
    ORDER BY pcer.pregnancy_child_id
    HEAD REPORT
     nomen_cnt = 0, long_text_cnt = 0
    HEAD pcer.pregnancy_child_id
     rep_preg_idx = 0, rep_preg_chldidx = 0, ce_idx = 0,
     preg_chldidx = locateval(locate_idx,1,cur_list_size,pcer.pregnancy_child_id,temp_rec_child->
      pregnancy_children[locate_idx].pregnancy_child_id)
     IF (preg_chldidx != 0)
      rep_preg_idx = temp_rec_child->pregnancy_children[preg_chldidx].preg_idx, rep_preg_chldidx =
      temp_rec_child->pregnancy_children[preg_chldidx].preg_child_idx
     ENDIF
    DETAIL
     IF (rep_preg_idx != 0
      AND rep_preg_chldidx != 0)
      ce_idx += 1
      IF (mod(ce_idx,5)=1)
       stat = alterlist(reply->pregnancies[rep_preg_idx].pregnancy_children[rep_preg_chldidx].
        child_entities,(ce_idx+ 4))
      ENDIF
      reply->pregnancies[rep_preg_idx].pregnancy_children[rep_preg_chldidx].child_entities[ce_idx].
      component_type_cd = pcer.component_type_cd, reply->pregnancies[rep_preg_idx].
      pregnancy_children[rep_preg_chldidx].child_entities[ce_idx].parent_entity_id = pcer
      .parent_entity_id, reply->pregnancies[rep_preg_idx].pregnancy_children[rep_preg_chldidx].
      child_entities[ce_idx].parent_entity_name = pcer.parent_entity_name
     ENDIF
     IF (pcer.parent_entity_name="NOMENCLATURE")
      nomen_cnt += 1
      IF (mod(nomen_cnt,5)=1)
       stat = alterlist(temp_rec_nomen->nomenclature_info,(nomen_cnt+ 4))
      ENDIF
      temp_rec_nomen->nomenclature_info[nomen_cnt].nomenclature_id = pcer.parent_entity_id
     ENDIF
     IF (pcer.parent_entity_name="LONG_TEXT")
      long_text_cnt += 1
      IF (mod(long_text_cnt,5)=1)
       stat = alterlist(temp_rec_lt->lt_info,(long_text_cnt+ 5))
      ENDIF
      temp_rec_lt->lt_info[long_text_cnt].long_text_id = pcer.parent_entity_id, temp_rec_lt->lt_info[
      long_text_cnt].preg_idx = rep_preg_idx, temp_rec_lt->lt_info[long_text_cnt].preg_child_idx =
      rep_preg_chldidx,
      temp_rec_lt->lt_info[long_text_cnt].preg_child_entity_idx = ce_idx
     ENDIF
    FOOT  pcer.pregnancy_child_id
     stat = alterlist(reply->pregnancies[rep_preg_idx].pregnancy_children[rep_preg_chldidx].
      child_entities,ce_idx)
    FOOT REPORT
     stat = alterlist(temp_rec_nomen->nomenclature_info,nomen_cnt), stat = alterlist(temp_rec_lt->
      lt_info,long_text_cnt)
    WITH nocounter
   ;end select
   SET nstart = 1
   SELECT INTO "nl:"
    FROM (dummyt dlt  WITH seq = value(loop_cnt)),
     long_text lt
    PLAN (dlt
     WHERE initarray(nstart,evaluate(dlt.seq,1,1,(nstart+ batch_size))))
     JOIN (lt
     WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),lt.long_text_id,temp_rec_child->
      pregnancy_children[idx].child_comment))
    HEAD lt.long_text_id
     rep_preg_idx = 0, rep_preg_chldidx = 0, ce_idx = 0,
     preg_chldidx = locateval(locate_idx,1,cur_list_size,lt.long_text_id,temp_rec_child->
      pregnancy_children[locate_idx].child_comment)
     IF (preg_chldidx != 0)
      rep_preg_idx = temp_rec_child->pregnancy_children[preg_chldidx].preg_idx, rep_preg_chldidx =
      temp_rec_child->pregnancy_children[preg_chldidx].preg_child_idx
     ENDIF
    DETAIL
     IF (rep_preg_idx != 0
      AND rep_preg_chldidx != 0)
      reply->pregnancies[rep_preg_idx].pregnancy_children[rep_preg_chldidx].child_comment = lt
      .long_text
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE getpregnancydocumentinfo(null)
   CALL echorecord(temp_ce_struct)
   SET batch_size = 50
   SET cur_list_size = size(temp_ce_struct->events,5)
   IF (cur_list_size=0)
    RETURN
   ENDIF
   SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
   SET new_list_size = (loop_cnt * batch_size)
   SET stat = alterlist(temp_ce_struct->events,new_list_size)
   SET nstart = 1
   FOR (idx = (cur_list_size+ 1) TO new_list_size)
     SET temp_ce_struct->events[idx].event_id = temp_ce_struct->events[cur_list_size].event_id
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(loop_cnt)),
     clinical_event ce
    PLAN (d1
     WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
     JOIN (ce
     WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),ce.event_id,temp_ce_struct->events[idx].
      event_id)
      AND ce.valid_until_dt_tm=cnvtdatetime(end_date_str))
    HEAD REPORT
     doc_idx = 0, stat = alterlist(reply->pregnancy_documents,cur_list_size)
    DETAIL
     doc_idx += 1, reply->pregnancy_documents[doc_idx].event_id = ce.event_id, reply->
     pregnancy_documents[doc_idx].event_cd = ce.event_cd,
     reply->pregnancy_documents[doc_idx].event_title_text = ce.event_title_text, reply->
     pregnancy_documents[doc_idx].result_status_cd = ce.result_status_cd, reply->pregnancy_documents[
     doc_idx].performed_prsnl_id = ce.performed_prsnl_id,
     reply->pregnancy_documents[doc_idx].event_end_dt_tm = ce.event_end_dt_tm
    FOOT REPORT
     stat = alterlist(reply->pregnancy_documents,doc_idx)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE getnomenclatureinfo(null)
   SET batch_size = 50
   SET cur_list_size = size(temp_rec_nomen->nomenclature_info,5)
   SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
   IF (cur_list_size=0)
    RETURN
   ENDIF
   SET new_list_size = (loop_cnt * batch_size)
   SET stat = alterlist(temp_rec_nomen->nomenclature_info,new_list_size)
   SET nstart = 1
   FOR (idx = (cur_list_size+ 1) TO new_list_size)
     SET temp_rec_nomen->nomenclature_info[idx].nomenclature_id = temp_rec_nomen->nomenclature_info[
     cur_list_size].nomenclature_id
   ENDFOR
   IF (loop_cnt=0)
    RETURN
   ENDIF
   DECLARE nomen_idx = i4 WITH noconstant(0)
   SELECT INTO "nl:"
    FROM (dummyt dn  WITH seq = value(loop_cnt)),
     nomenclature n
    PLAN (dn
     WHERE initarray(nstart,evaluate(dn.seq,1,1,(nstart+ batch_size))))
     JOIN (n
     WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),n.nomenclature_id,temp_rec_nomen->
      nomenclature_info[idx].nomenclature_id))
    ORDER BY n.nomenclature_id
    HEAD n.nomenclature_id
     nomen_idx += 1
     IF (mod(nomen_idx,5)=1)
      stat = alterlist(reply->nomenclature_info,(nomen_idx+ 4))
     ENDIF
    DETAIL
     reply->nomenclature_info[nomen_idx].nomenclature_id = n.nomenclature_id, reply->
     nomenclature_info[nomen_idx].source_string = n.source_string
    FOOT REPORT
     stat = alterlist(reply->nomenclature_info,nomen_idx)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE getlongtextinfo(null)
   CALL echorecord(temp_rec_lt)
   SET batch_size = 20
   SET cur_list_size = size(temp_rec_lt->lt_info,5)
   IF (cur_list_size=0)
    RETURN
   ENDIF
   SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
   SET new_list_size = (loop_cnt * batch_size)
   SET stat = alterlist(temp_rec_lt->lt_info,new_list_size)
   SET nstart = 1
   FOR (idx = (cur_list_size+ 1) TO new_list_size)
     SET temp_rec_lt->lt_info[idx].long_text_id = temp_rec_lt->lt_info[cur_list_size].long_text_id
   ENDFOR
   IF (loop_cnt=0)
    RETURN
   ENDIF
   DECLARE long_idx = i4 WITH noconstant(0)
   DECLARE pidx = i4 WITH noconstant(0)
   DECLARE pcidx = i4 WITH noconstant(0)
   DECLARE pceidx = i4 WITH noconstant(0)
   SELECT INTO "nl:"
    FROM (dummyt dlt  WITH seq = value(loop_cnt)),
     long_text lt
    PLAN (dlt
     WHERE initarray(nstart,evaluate(dlt.seq,1,1,(nstart+ batch_size))))
     JOIN (lt
     WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),lt.long_text_id,temp_rec_lt->lt_info[idx].
      long_text_id))
    ORDER BY lt.long_text_id
    HEAD lt.long_text_id
     pidx = 0, pcidx = 0, pceidx = 0,
     long_idx = locateval(locate_idx,1,cur_list_size,lt.long_text_id,temp_rec_lt->lt_info[locate_idx]
      .long_text_id)
     IF (long_idx != 0)
      pidx = temp_rec_lt->lt_info[long_idx].preg_idx, pcidx = temp_rec_lt->lt_info[long_idx].
      preg_child_idx, pceidx = temp_rec_lt->lt_info[long_idx].preg_child_entity_idx
     ENDIF
    DETAIL
     IF (pidx != 0
      AND pcidx != 0
      AND pceidx != 0)
      reply->pregnancies[pidx].pregnancy_children[pcidx].child_entities[pceidx].entity_text = lt
      .long_text
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SET reply->status_data.status = "S"
#exit_script
 CALL echorecord(request)
 CALL echorecord(reply)
END GO
