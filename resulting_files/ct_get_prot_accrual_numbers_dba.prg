CREATE PROGRAM ct_get_prot_accrual_numbers:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 collab_site_ind = i2
    1 parent_prot_master_id = f8
    1 active_parent_amend_id = f8
    1 prot_amendment_id = f8
    1 prot_master_id = f8
    1 requiredaccrualcd = f8
    1 person_id = f8
    1 participation_type_cd = f8
    1 application_nbr = i4
    1 pref_domain = vc
    1 pref_section = vc
    1 pref_name = vc
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 grouptargetaccrual = i2
    1 grouptargetaccrued = i2
    1 targetaccrual = i2
    1 totalaccrued = i2
    1 excludedpersonind = i2
    1 bfound = i2
    1 active_parent_amend_id = f8
    1 active_parent_amend_dt_tm = dq8
    1 group_target_accrual = i2
    1 participation_type_cd = f8
    1 prot_accrual = i2
    1 group_accrual = i2
    1 track_tw_accrual = i2
    1 collab_ind = i2
    1 is_parent = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE mrn_cd = f8 WITH protect, noconstant(0.0)
 DECLARE enrolling_cd = f8 WITH protect, noconstant(0.0)
 DECLARE collab_ind = i2 WITH protect, noconstant(0)
 DECLARE aliaspoolcount = i2 WITH protect, noconstant(0)
 DECLARE aliaspoollist = vc WITH protect, noconstant("")
 DECLARE coordinst_cd = f8 WITH public, noconstant(0.0)
 DECLARE orgid = f8 WITH protect, noconstant(0.0)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE parent_prot_master_id = f8 WITH public, noconstant(0.0)
 DECLARE prot_master_id = f8 WITH public, noconstant(0.0)
 DECLARE collab_site_org_id = f8 WITH public, noconstant(0.0)
 DECLARE trialwide_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17906,"TRIALWIDE"))
 DECLARE def_org_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17906,"DEFAULTORG"))
 RECORD pref_request(
   1 pref_entry = vc
 )
 FREE RECORD pref_reply
 RECORD pref_reply(
   1 pref_value = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET stat = uar_get_meaning_by_codeset(17441,"COORDINST",1,coordinst_cd)
 SET stat = uar_get_meaning_by_codeset(4,"MRN",1,mrn_cd)
 SET stat = uar_get_meaning_by_codeset(17900,"ENROLLING",1,enrolling_cd)
 IF ((request->parent_prot_master_id > 0)
  AND (request->active_parent_amend_id=0))
  SELECT INTO "nl:"
   FROM prot_master pm,
    prot_amendment pa
   PLAN (pm
    WHERE (pm.prot_master_id=request->parent_prot_master_id)
     AND pm.end_effective_dt_tm > cnvtdatetime(sysdate))
    JOIN (pa
    WHERE pa.prot_master_id=pm.prot_master_id
     AND pa.amendment_status_cd=pm.prot_status_cd)
   DETAIL
    request->active_parent_amend_id = pa.prot_amendment_id
   WITH nocounter
  ;end select
  CALL echo("Get the active parent amendment id")
 ENDIF
 SET reply->active_parent_amend_id = request->active_parent_amend_id
 IF ((request->active_parent_amend_id > 0))
  SELECT INTO "nl:"
   pa.prot_master_id
   FROM prot_amendment pa,
    ct_prot_type_config cfg
   PLAN (pa
    WHERE (pa.prot_amendment_id=request->active_parent_amend_id))
    JOIN (cfg
    WHERE cfg.protocol_type_cd=pa.participation_type_cd
     AND cfg.end_effective_dt_tm > cnvtdatetime(sysdate)
     AND ((cfg.item_cd=trialwide_cd) OR (cfg.item_cd=def_org_cd)) )
   DETAIL
    parent_prot_master_id = pa.prot_master_id, reply->active_parent_amend_dt_tm = pa.amendment_dt_tm
    IF (((cfg.item_cd=trialwide_cd
     AND uar_get_code_meaning(cfg.config_value_cd)="YES") OR (cfg.item_cd=def_org_cd
     AND uar_get_code_meaning(cfg.config_value_cd)="YES")) )
     reply->track_tw_accrual += 1
    ENDIF
    reply->group_target_accrual = pa.groupwide_targeted_accrual, reply->targetaccrual = pa
    .targeted_accrual
   WITH nocounter
  ;end select
  CALL echo(build("parent",parent_prot_master_id))
  SELECT INTO "nl:"
   pa.prot_master_id
   FROM prot_amendment pa,
    prot_master pm
   PLAN (pa
    WHERE (pa.prot_amendment_id=request->prot_amendment_id))
    JOIN (pm
    WHERE pm.prot_master_id=pa.prot_master_id)
   DETAIL
    prot_master_id = pa.prot_master_id, reply->participation_type_cd = pa.participation_type_cd,
    collab_ind = 1,
    collab_site_org_id = pm.collab_site_org_id
   WITH nocounter, maxrec = 1
  ;end select
 ELSE
  SELECT INTO "nl:"
   pa.prot_master_id
   FROM prot_amendment pa,
    ct_prot_type_config cfg
   PLAN (pa
    WHERE (pa.prot_amendment_id=request->prot_amendment_id))
    JOIN (cfg
    WHERE cfg.protocol_type_cd=pa.participation_type_cd
     AND cfg.end_effective_dt_tm > cnvtdatetime(sysdate)
     AND ((cfg.item_cd=trialwide_cd) OR (cfg.item_cd=def_org_cd)) )
   DETAIL
    prot_master_id = pa.prot_master_id, parent_prot_master_id = pa.prot_master_id, reply->
    participation_type_cd = pa.participation_type_cd
    IF (((cfg.item_cd=trialwide_cd
     AND uar_get_code_meaning(cfg.config_value_cd)="YES") OR (cfg.item_cd=def_org_cd
     AND uar_get_code_meaning(cfg.config_value_cd)="YES")) )
     reply->track_tw_accrual += 1
    ENDIF
    reply->group_target_accrual = pa.groupwide_targeted_accrual, reply->targetaccrual = pa
    .targeted_accrual
   WITH nocounter
  ;end select
 ENDIF
 IF ((reply->track_tw_accrual > 1))
  SET reply->track_tw_accrual = 1
 ELSE
  SET reply->track_tw_accrual = 0
 ENDIF
 CALL echo(build2("trialwide_cd = ",trialwide_cd))
 CALL echo(build2("def_org_cd = ",def_org_cd))
 CALL echo(build2("reply->track_tw_accrual = ",reply->track_tw_accrual))
 CALL echo(build2("groupwide = ",reply->group_target_accrual))
 SET reply->collab_ind = collab_ind
 IF ((reply->collab_ind=0))
  SET reply->is_parent = 0
  CALL echo(build("parent = ",parent_prot_master_id))
  CALL echo(build("prot_master_id = ",prot_master_id))
  SELECT INTO "nl:"
   pm.*
   FROM prot_master pm
   WHERE pm.parent_prot_master_id=parent_prot_master_id
    AND pm.prev_prot_master_id != prot_master_id
    AND pm.collab_site_org_id > 0
   DETAIL
    reply->is_parent = 1
   WITH nocounter, maxrec = 1
  ;end select
 ENDIF
 SET reply->bfound = false
 IF ((reply->track_tw_accrual != 0))
  IF ((request->active_parent_amend_id > 0))
   SET temp_id = request->prot_amendment_id
   SET request->prot_amendment_id = request->active_parent_amend_id
  ENDIF
  DECLARE orgid = f8 WITH protect, noconstant(0.0)
  DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
  DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
  RECORD pref_request(
    1 pref_entry = vc
  )
  RECORD pref_reply(
    1 pref_value = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
  IF (size(request->pref_name,1) > 0)
   SELECT INTO "nl:"
    dp.pref_nbr
    FROM dm_prefs dp
    PLAN (dp
     WHERE (dp.application_nbr=request->application_nbr)
      AND (dp.pref_domain=request->pref_domain)
      AND (dp.pref_name=request->pref_name)
      AND (dp.pref_section=request->pref_section))
    DETAIL
     IF (dp.pref_id > 0)
      orgid = dp.pref_nbr
     ENDIF
    WITH nocounter
   ;end select
   IF (curqual=0)
    IF (orgid=0.0)
     SET reply->status_data.status = "F"
    ELSE
     SET reply->status_data.status = "Z"
    ENDIF
   ELSE
    SET reply->status_data.status = "S"
   ENDIF
  ELSE
   SET pref_request->pref_entry = "default_org"
   EXECUTE ct_get_pref  WITH replace("REQUEST_STRUCT","PREF_REQUEST"), replace("REPLY","PREF_REPLY")
   CALL echo(pref_reply->pref_value)
   IF ((pref_reply->pref_value > 0))
    SET orgid = cnvtreal(pref_reply->pref_value)
    SET reply->status_data.status = "S"
   ELSE
    SET reply->status_data.status = "F"
   ENDIF
  ENDIF
  CALL echo(build("orgid:",orgid))
  SELECT INTO "nl:"
   pr.*
   FROM prot_role pr
   PLAN (pr
    WHERE (pr.prot_amendment_id=request->prot_amendment_id)
     AND pr.prot_role_cd=coordinst_cd
     AND pr.organization_id=orgid
     AND pr.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00"))
   DETAIL
    reply->bfound = true
   WITH nocounter
  ;end select
  IF (curqual=0)
   IF ((reply->bfound=true))
    SET reply->status_data.status = "F"
   ELSE
    SET reply->status_data.status = "Z"
   ENDIF
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
  SET last_mod = "001"
  SET mod_date = "Aug 30, 2006"
  IF ((request->active_parent_amend_id > 0))
   SET request->prot_amendment_id = temp_id
  ENDIF
  IF ((reply->status_data.status="F"))
   SET fail_flag = search_for_coordinst
   GO TO check_error
  ENDIF
  IF ((reply->bfound=false))
   CALL echo("inside bfound search")
   SET reply->track_tw_accrual = 0
  ENDIF
 ENDIF
 CALL echo(build2("reply->bFound is ",reply->bfound))
 CALL echo(build2("reply->track_tw_accrual is ",reply->track_tw_accrual))
 SET aliaspoollist = "p_a.alias_pool_cd NOT IN ("
 SET aliaspoolcount = 0
 SELECT INTO "NL:"
  oap.alias_pool_cd
  FROM org_alias_pool_reltn oap,
   ct_excluded_clients ec
  PLAN (ec
   WHERE ec.active_ind=1)
   JOIN (oap
   WHERE oap.organization_id=ec.organization_id)
  DETAIL
   aliaspoolcount += 1
   IF (aliaspoolcount=1)
    aliaspoollist = build(aliaspoollist,oap.alias_pool_cd)
   ELSE
    aliaspoollist = build(aliaspoollist,", ",oap.alias_pool_cd)
   ENDIF
  WITH nocounter
 ;end select
 IF (aliaspoolcount=0)
  SET aliaspoollist = "p_a.alias_pool_cd NOT IN (-1)"
 ELSE
  SET aliaspoollist = build(aliaspoollist,")")
 ENDIF
 CALL echo(build2("AliasPoolList is: ",aliaspoollist))
 SELECT DISTINCT INTO "nl:"
  pp.reg_id
  FROM pt_prot_reg pp,
   prot_amendment pa,
   ct_pt_amd_assignment c,
   person_alias p_a,
   prot_master pm
  PLAN (pm
   WHERE pm.parent_prot_master_id=parent_prot_master_id
    AND pm.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (pa
   WHERE pa.prot_master_id=pm.prot_master_id)
   JOIN (c
   WHERE c.prot_amendment_id=pa.prot_amendment_id
    AND c.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (pp
   WHERE pp.reg_id=c.reg_id
    AND pp.reg_id > 0
    AND pp.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (p_a
   WHERE (p_a.person_id= Outerjoin(pp.person_id))
    AND (p_a.person_alias_type_cd= Outerjoin(mrn_cd))
    AND (p_a.active_ind= Outerjoin(1))
    AND (p_a.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
    AND (p_a.end_effective_dt_tm>= Outerjoin(cnvtdatetime(sysdate))) )
  ORDER BY pp.reg_id
  HEAD pp.reg_id
   CALL echo(concat("person alias:  ",build(p_a.alias_pool_cd)))
   IF ((reply->track_tw_accrual=0))
    IF (pm.collab_site_org_id > 0
     AND collab_ind=1
     AND pm.collab_site_org_id=collab_site_org_id)
     IF (pm.prot_master_id != parent_prot_master_id)
      reply->prot_accrual += 1
     ENDIF
    ELSE
     IF (collab_ind=0)
      IF (pm.prot_master_id=parent_prot_master_id)
       reply->prot_accrual += 1
      ENDIF
     ENDIF
    ENDIF
    reply->group_accrual += 1
   ELSE
    IF (parser(aliaspoollist))
     reply->group_accrual += 1
     IF (pm.collab_site_org_id > 0
      AND collab_ind=1
      AND pm.collab_site_org_id=collab_site_org_id)
      reply->prot_accrual += 1
     ELSE
      IF (collab_ind=0
       AND pm.collab_site_org_id=0)
       reply->prot_accrual += 1
      ENDIF
     ENDIF
    ELSE
     IF (pm.collab_site_org_id > 0
      AND collab_ind=1
      AND pm.collab_site_org_id=collab_site_org_id)
      reply->prot_accrual += 1
     ENDIF
     reply->group_accrual += 1
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
  p.pt_elig_tracking_id
  FROM pt_consent pco,
   pt_elig_consent_reltn pec,
   pt_elig_tracking p,
   prot_questionnaire pq,
   prot_amendment pa,
   person_alias p_a,
   prot_master pm
  PLAN (pm
   WHERE pm.parent_prot_master_id=parent_prot_master_id
    AND pm.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (pa
   WHERE pa.prot_master_id=pm.prot_master_id)
   JOIN (pq
   WHERE pq.prot_amendment_id=pa.prot_amendment_id
    AND pq.questionnaire_type_cd=enrolling_cd)
   JOIN (p
   WHERE p.prot_questionnaire_id=pq.prot_questionnaire_id)
   JOIN (pec
   WHERE pec.pt_elig_tracking_id=p.pt_elig_tracking_id)
   JOIN (pco
   WHERE pco.consent_id=pec.consent_id
    AND pco.not_returned_reason_cd=0
    AND pco.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND pco.consent_signed_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (p_a
   WHERE (p_a.person_id= Outerjoin(pco.person_id))
    AND (p_a.person_alias_type_cd= Outerjoin(mrn_cd))
    AND (p_a.active_ind= Outerjoin(1))
    AND (p_a.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
    AND (p_a.end_effective_dt_tm>= Outerjoin(cnvtdatetime(sysdate))) )
  ORDER BY p.pt_elig_tracking_id
  HEAD p.pt_elig_tracking_id
   IF ((reply->track_tw_accrual=0))
    IF (pm.collab_site_org_id > 0
     AND collab_ind=1
     AND pm.collab_site_org_id=collab_site_org_id)
     IF (pm.prot_master_id != parent_prot_master_id)
      reply->prot_accrual += 1
     ENDIF
    ELSE
     IF (collab_ind=0)
      IF (pm.prot_master_id=parent_prot_master_id)
       reply->prot_accrual += 1
      ENDIF
     ENDIF
    ENDIF
    reply->group_accrual += 1
   ELSE
    IF (parser(aliaspoollist))
     IF (pm.collab_site_org_id > 0
      AND collab_ind=1
      AND pm.collab_site_org_id=collab_site_org_id)
      reply->prot_accrual += 1
     ELSE
      IF (collab_ind=0
       AND pm.collab_site_org_id=0)
       reply->prot_accrual += 1
      ENDIF
     ENDIF
     reply->group_accrual += 1
    ELSE
     IF (pm.collab_site_org_id > 0
      AND collab_ind=1
      AND pm.collab_site_org_id=collab_site_org_id)
      reply->prot_accrual += 1
     ENDIF
     reply->group_accrual += 1
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
  pc.consent_id
  FROM pt_consent pc,
   prot_amendment pa,
   person_alias p_a,
   pt_elig_consent_reltn pecr,
   prot_master pm
  PLAN (pm
   WHERE pm.parent_prot_master_id=parent_prot_master_id
    AND pm.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (pa
   WHERE pa.prot_master_id=pm.prot_master_id)
   JOIN (pc
   WHERE pc.prot_amendment_id=pa.prot_amendment_id
    AND pc.not_returned_reason_cd=0
    AND pc.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND pc.consent_signed_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (pecr
   WHERE (pecr.consent_id= Outerjoin(pc.consent_id)) )
   JOIN (p_a
   WHERE (p_a.person_id= Outerjoin(pc.person_id))
    AND (p_a.person_alias_type_cd= Outerjoin(mrn_cd))
    AND (p_a.active_ind= Outerjoin(1))
    AND (p_a.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
    AND (p_a.end_effective_dt_tm>= Outerjoin(cnvtdatetime(sysdate))) )
  ORDER BY pc.pt_consent_id
  HEAD pc.pt_consent_id
   IF (pecr.pt_elig_consent_reltn_id=0)
    IF ((reply->track_tw_accrual=0))
     IF (pm.collab_site_org_id > 0
      AND collab_ind=1
      AND pm.collab_site_org_id=collab_site_org_id)
      IF (pm.prot_master_id != parent_prot_master_id)
       reply->prot_accrual += 1
      ENDIF
     ELSE
      IF (collab_ind=0)
       IF (pm.prot_master_id=parent_prot_master_id)
        reply->prot_accrual += 1
       ENDIF
      ENDIF
     ENDIF
     reply->group_accrual += 1
    ELSE
     IF (parser(aliaspoollist))
      IF (pm.collab_site_org_id > 0
       AND collab_ind=1
       AND pm.collab_site_org_id=collab_site_org_id)
       reply->prot_accrual += 1
      ELSE
       IF (collab_ind=0
        AND pm.collab_site_org_id=0)
        reply->prot_accrual += 1
       ENDIF
      ENDIF
      reply->group_accrual += 1
     ELSE
      IF (pm.collab_site_org_id > 0
       AND collab_ind=1
       AND pm.collab_site_org_id=collab_site_org_id)
       reply->prot_accrual += 1
      ENDIF
      reply->group_accrual += 1
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (size(request->pref_name,1) > 0)
  SELECT INTO "nl:"
   dp.pref_nbr
   FROM dm_prefs dp
   PLAN (dp
    WHERE (dp.application_nbr=request->application_nbr)
     AND (dp.pref_domain=request->pref_domain)
     AND (dp.pref_name=request->pref_name)
     AND (dp.pref_section=request->pref_section))
   DETAIL
    IF (dp.pref_id > 0)
     orgid = dp.pref_nbr
    ENDIF
   WITH nocounter
  ;end select
  IF (curqual=0)
   IF (orgid=0.0)
    SET reply->status_data.status = "F"
   ELSE
    SET reply->status_data.status = "Z"
   ENDIF
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ELSE
  SET pref_request->pref_entry = "default_org"
  EXECUTE ct_get_pref  WITH replace("REQUEST_STRUCT","PREF_REQUEST"), replace("REPLY","PREF_REPLY")
  CALL echo(pref_reply->pref_value)
  IF ((pref_reply->pref_value > 0))
   SET orgid = cnvtreal(pref_reply->pref_value)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "F"
  ENDIF
 ENDIF
 CALL echo(build2("orgid:",orgid))
 SELECT INTO "nl:"
  pr.*
  FROM prot_role pr
  PLAN (pr
   WHERE (pr.prot_amendment_id=request->prot_amendment_id)
    AND pr.prot_role_cd=coordinst_cd
    AND pr.organization_id=orgid
    AND pr.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00"))
  DETAIL
   reply->bfound = true
  WITH nocounter
 ;end select
 IF (curqual=0)
  IF ((reply->bfound=true))
   SET reply->status_data.status = "F"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET last_mod = "008"
 SET mod_date = "July 21, 2010"
END GO
