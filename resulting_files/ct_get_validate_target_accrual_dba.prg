CREATE PROGRAM ct_get_validate_target_accrual:dba
 RECORD reply(
   1 grouptargetaccrual = i2
   1 grouptargetaccrued = i2
   1 targetaccrual = i2
   1 totalaccrued = i2
   1 excludedpersonind = i2
   1 bfound = i2
   1 accrual_estimate_only_ind = i2
   1 track_tw_accrual = i2
   1 excluded_person_cnt = i4
   1 over_accrual_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF ( NOT (validate(domain_reply)))
  RECORD domain_reply(
    1 logical_domain_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 EXECUTE ct_get_logical_domain_id  WITH replace("REPLY",domain_reply)
 SET reply->status_data.status = "F"
 SET reply->excludedpersonind = 0
 DECLARE fail_flag = i2 WITH protect, noconstant(0)
 DECLARE enrolled_accrual = i2 WITH protect, noconstant(0)
 DECLARE count = i2 WITH protect, noconstant(0)
 DECLARE assigned_checklist_accrual = i2 WITH protect, noconstant(0)
 DECLARE not_assigned_checklist_accrual = i2 WITH protect, noconstant(0)
 DECLARE trial_enrolled_accrual = i2 WITH protect, noconstant(0)
 DECLARE trial_assigned_checklist_accrual = i2 WITH protect, noconstant(0)
 DECLARE trial_not_assigned_checklist_accrual = i2 WITH protect, noconstant(0)
 DECLARE open_cd = f8 WITH public, noconstant(0.0)
 DECLARE yes_cd = f8 WITH public, noconstant(0.0)
 DECLARE enrolling_cd = f8 WITH public, noconstant(0.0)
 DECLARE coordinst_cd = f8 WITH protect, noconstant(0.0)
 DECLARE accrualrequired = f8 WITH public, noconstant(0.0)
 DECLARE mrn_cd = f8 WITH protect, noconstant(0.0)
 DECLARE get_both_ind = i2 WITH protect, noconstant(0)
 DECLARE stat = i2 WITH private, noconstant(0)
 DECLARE aliaspoolcount = i4 WITH protect, noconstant(0)
 DECLARE aliaspoollist = vc WITH protect, noconstant("")
 DECLARE open_found = i2 WITH protect, noconstant(0)
 DECLARE collab_ind = i2 WITH protect, noconstant(0)
 DECLARE parent_prot_master_id = f8 WITH protect, noconstant(0.0)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE trialwide_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17906,"TRIALWIDE"))
 DECLARE def_org_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17906,"DEFAULTORG"))
 DECLARE trialwide_ind = i2 WITH protect, noconstant(0)
 DECLARE def_org_ind = i2 WITH protect, noconstant(0)
 DECLARE collab_site_org_id = f8 WITH protect, noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(17274,"ACTIVATED",1,open_cd)
 SET stat = uar_get_meaning_by_codeset(17438,"YES",1,yes_cd)
 SET stat = uar_get_meaning_by_codeset(17900,"ENROLLING",1,enrolling_cd)
 SET stat = uar_get_meaning_by_codeset(4,"MRN",1,mrn_cd)
 SET stat = uar_get_meaning_by_codeset(17441,"COORDINST",1,coordinst_cd)
 SET reply->bfound = false
 DECLARE search_for_enrolled = i2 WITH private, constant(1)
 DECLARE search_for_assigned = i2 WITH private, constant(2)
 DECLARE search_for_amd = i2 WITH private, constant(3)
 DECLARE search_for_not_assigned = i2 WITH private, constant(4)
 DECLARE search_for_coordinst = i2 WITH private, constant(5)
 IF ((request->prot_amendment_id > 0))
  SELECT INTO "nl:"
   pa.targeted_accrual
   FROM prot_amendment pa,
    prot_master pm,
    ct_prot_type_config cfg
   PLAN (pa
    WHERE (pa.prot_amendment_id=request->prot_amendment_id))
    JOIN (pm
    WHERE pm.prot_master_id=pa.prot_master_id)
    JOIN (cfg
    WHERE cfg.protocol_type_cd=pa.participation_type_cd
     AND cfg.end_effective_dt_tm > cnvtdatetime(sysdate)
     AND ((cfg.item_cd=trialwide_cd) OR (cfg.item_cd=def_org_cd))
     AND (cfg.logical_domain_id=domain_reply->logical_domain_id))
   DETAIL
    IF ((request->participation_type_cd=0))
     request->participation_type_cd = pa.participation_type_cd
    ENDIF
    IF (cfg.item_cd=trialwide_cd
     AND uar_get_code_meaning(cfg.config_value_cd)="YES")
     trialwide_ind = 1
    ENDIF
    IF (cfg.item_cd=def_org_cd
     AND uar_get_code_meaning(cfg.config_value_cd)="YES")
     def_org_ind = 1
    ENDIF
    IF (trialwide_ind=1
     AND def_org_ind=1)
     reply->track_tw_accrual = 1, get_both_ind = 1, reply->grouptargetaccrual = pa
     .groupwide_targeted_accrual
    ENDIF
    reply->targetaccrual = pa.targeted_accrual, accrualrequired = pa.accrual_required_indc_cd,
    request->prot_master_id = pa.prot_master_id,
    parent_prot_master_id = pm.parent_prot_master_id
    IF (pa.accrual_required_indc_cd=yes_cd)
     reply->accrual_estimate_only_ind = 0
    ELSE
     reply->accrual_estimate_only_ind = 1
    ENDIF
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_data.status = "F"
   GO TO check_error
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ELSE
  SET open_found = 0
  SELECT INTO "nl:"
   pa.targeted_accrual
   FROM prot_amendment pa,
    prot_master pm,
    ct_prot_type_config cfg
   PLAN (pa
    WHERE (pa.prot_master_id=request->prot_master_id))
    JOIN (pm
    WHERE pm.prot_master_id=pa.prot_master_id)
    JOIN (cfg
    WHERE cfg.protocol_type_cd=pa.participation_type_cd
     AND cfg.end_effective_dt_tm > cnvtdatetime(sysdate)
     AND ((cfg.item_cd=trialwide_cd) OR (cfg.item_cd=def_org_cd))
     AND (cfg.logical_domain_id=domain_reply->logical_domain_id))
   HEAD pa.prot_amendment_id
    IF (open_found=0)
     IF ((request->participation_type_cd=0))
      request->participation_type_cd = pa.participation_type_cd
     ENDIF
     reply->targetaccrual = pa.targeted_accrual, accrualrequired = pa.accrual_required_indc_cd,
     request->prot_amendment_id = pa.prot_amendment_id,
     parent_prot_master_id = pm.parent_prot_master_id,
     CALL echo(build("parent:",parent_prot_master_id))
     IF (pa.accrual_required_indc_cd=yes_cd)
      reply->accrual_estimate_only_ind = 0
     ELSE
      reply->accrual_estimate_only_ind = 1
     ENDIF
     collab_site_org_id = pm.collab_site_org_id
    ENDIF
   DETAIL
    IF (open_found=0)
     IF (cfg.item_cd=trialwide_cd
      AND uar_get_code_meaning(cfg.config_value_cd)="YES")
      trialwide_ind = 1
     ENDIF
     IF (cfg.item_cd=def_org_cd
      AND uar_get_code_meaning(cfg.config_value_cd)="YES")
      def_org_ind = 1
     ENDIF
     IF (trialwide_ind=1
      AND def_org_ind=1)
      reply->track_tw_accrual = 1, get_both_ind = 1, reply->grouptargetaccrual = pa
      .groupwide_targeted_accrual
     ENDIF
    ENDIF
   FOOT  pa.prot_amendment_id
    IF (pa.amendment_status_cd=open_cd)
     open_found = 1
    ENDIF
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_data.status = "F"
   GO TO check_error
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
 IF ((parent_prot_master_id != request->prot_master_id))
  SET collab_ind = 1
  SET open_found = 0
  SELECT INTO "nl:"
   pa.targeted_accrual
   FROM prot_amendment pa,
    prot_master pm,
    ct_prot_type_config cfg
   PLAN (pa
    WHERE pa.prot_master_id=parent_prot_master_id)
    JOIN (pm
    WHERE pm.prot_master_id=pa.prot_master_id)
    JOIN (cfg
    WHERE cfg.protocol_type_cd=pa.participation_type_cd
     AND cfg.end_effective_dt_tm > cnvtdatetime(sysdate)
     AND ((cfg.item_cd=trialwide_cd) OR (cfg.item_cd=def_org_cd))
     AND (cfg.logical_domain_id=domain_reply->logical_domain_id))
   HEAD pa.prot_amendment_id
    IF (open_found=0)
     IF ((request->participation_type_cd=0))
      request->participation_type_cd = pa.participation_type_cd
     ENDIF
    ENDIF
   DETAIL
    IF (open_found=0)
     IF (cfg.item_cd=trialwide_cd
      AND uar_get_code_meaning(cfg.config_value_cd)="YES")
      trialwide_ind = 1
     ENDIF
     IF (cfg.item_cd=def_org_cd
      AND uar_get_code_meaning(cfg.config_value_cd)="YES")
      def_org_ind = 1
     ENDIF
     IF (trialwide_ind=1
      AND def_org_ind=1)
      reply->track_tw_accrual = 1, get_both_ind = 1, reply->grouptargetaccrual = pa
      .groupwide_targeted_accrual
     ENDIF
    ENDIF
   FOOT  pa.prot_amendment_id
    IF (pa.amendment_status_cd=open_cd)
     open_found = 1
    ENDIF
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_data.status = "F"
   GO TO check_error
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
 CALL echo(build("get_both_ind =",get_both_ind))
 IF (((accrualrequired=yes_cd) OR ((request->requiredaccrualcd=yes_cd))) )
  CALL echo(build("Trial Target is: ",reply->grouptargetaccrual))
  CALL echo(build("Target is: ",reply->targetaccrual))
  IF ((request->requiredaccrualcd != 0.0))
   IF ((request->requiredaccrualcd != accrualrequired))
    SET accrualrequired = request->requiredaccrualcd
   ENDIF
  ENDIF
  IF (accrualrequired=yes_cd)
   IF (get_both_ind=1)
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
     EXECUTE ct_get_pref  WITH replace("REQUEST_STRUCT","PREF_REQUEST"), replace("REPLY","PREF_REPLY"
      )
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
    CALL echo(build("bfound ",reply->bfound))
    IF ((reply->status_data.status="F"))
     SET fail_flag = search_for_coordinst
     GO TO check_error
    ENDIF
    IF ((reply->bfound=false))
     SET get_both_ind = 0
    ENDIF
   ENDIF
   IF (get_both_ind=0)
    SET aliaspoollist = "p_a.alias_pool_cd NOT IN (-1)"
   ELSE
    SET aliaspoollist = "p_a.alias_pool_cd NOT IN ("
    SELECT INTO "NL:"
     oap.alias_pool_cd
     FROM org_alias_pool_reltn oap,
      ct_excluded_clients ec,
      organization o
     PLAN (ec
      WHERE ec.active_ind=1)
      JOIN (o
      WHERE o.organization_id=ec.organization_id
       AND (o.logical_domain_id=domain_reply->logical_domain_id))
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
    CALL echo(build("AliasPoolList is: ",aliaspoollist))
   ENDIF
   IF ((request->person_id > 0.0))
    SELECT INTO "nl:"
     FROM person_alias p_a
     WHERE (p_a.person_id=request->person_id)
      AND p_a.person_alias_type_cd=mrn_cd
      AND p_a.active_ind=1
      AND p_a.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND p_a.end_effective_dt_tm >= cnvtdatetime(sysdate)
     DETAIL
      IF (parser(aliaspoollist))
       reply->excludedpersonind = 0
      ELSE
       reply->excludedpersonind = 1
      ENDIF
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET reply->status_data.status = "Z"
    ELSE
     SET reply->status_data.status = "S"
    ENDIF
   ENDIF
   IF (size(request->person_list,5) > 0)
    SELECT INTO "nl:"
     FROM person_alias p_a,
      (dummyt d  WITH d.seq = value(size(request->person_list,5)))
     PLAN (d)
      JOIN (p_a
      WHERE (p_a.person_id=request->person_list[d.seq].person_id)
       AND p_a.person_alias_type_cd=mrn_cd
       AND p_a.active_ind=1
       AND p_a.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND p_a.end_effective_dt_tm >= cnvtdatetime(sysdate))
     HEAD p_a.person_id
      IF ( NOT (parser(aliaspoollist)))
       reply->excluded_person_cnt += 1
      ENDIF
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET reply->status_data.status = "Z"
    ELSE
     SET reply->status_data.status = "S"
    ENDIF
   ENDIF
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
     IF (get_both_ind=0)
      IF (pm.collab_site_org_id > 0
       AND collab_ind=1
       AND pm.collab_site_org_id=collab_site_org_id)
       IF (pm.prot_master_id != parent_prot_master_id)
        enrolled_accrual += 1
       ENDIF
      ELSE
       IF (collab_ind=0)
        IF (pm.prot_master_id=parent_prot_master_id)
         enrolled_accrual += 1
        ENDIF
       ENDIF
      ENDIF
     ELSE
      IF (parser(aliaspoollist))
       trial_enrolled_accrual += 1
       IF (pm.collab_site_org_id > 0
        AND collab_ind=1
        AND pm.collab_site_org_id=collab_site_org_id)
        enrolled_accrual += 1
       ELSE
        IF (collab_ind=0
         AND pm.collab_site_org_id=0)
         enrolled_accrual += 1
        ENDIF
       ENDIF
      ELSE
       IF (pm.collab_site_org_id > 0
        AND collab_ind=1
        AND pm.collab_site_org_id=collab_site_org_id)
        enrolled_accrual += 1
       ENDIF
       trial_enrolled_accrual += 1
      ENDIF
     ENDIF
    WITH counter
   ;end select
   CALL echo(build("Enrolled is: ",enrolled_accrual))
   CALL echo(build("Trial_Enrolled_Accrual is: ",trial_enrolled_accrual))
   IF (curqual=0)
    IF (enrolled_accrual=0
     AND trial_enrolled_accrual=0)
     SET reply->status_data.status = "Z"
    ELSE
     SET reply->status_data.status = "F"
     GO TO check_error
    ENDIF
   ELSE
    IF (((enrolled_accrual > 0) OR (trial_enrolled_accrual > 0)) )
     SET reply->status_data.status = "S"
    ENDIF
   ENDIF
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
     IF (get_both_ind=0)
      IF (pm.collab_site_org_id > 0
       AND collab_ind=1
       AND pm.collab_site_org_id=collab_site_org_id)
       IF (pm.prot_master_id != parent_prot_master_id)
        not_assigned_checklist_accrual += 1
       ENDIF
      ELSE
       IF (collab_ind=0)
        IF (pm.prot_master_id=parent_prot_master_id)
         not_assigned_checklist_accrual += 1
        ENDIF
       ENDIF
      ENDIF
     ELSE
      IF (parser(aliaspoollist))
       trial_not_assigned_checklist_accrual += 1
       IF (pm.collab_site_org_id > 0
        AND collab_ind=1
        AND pm.collab_site_org_id=collab_site_org_id)
        not_assigned_checklist_accrual += 1
       ELSE
        IF (collab_ind=0
         AND pm.collab_site_org_id=0)
         not_assigned_checklist_accrual += 1
        ENDIF
       ENDIF
      ELSE
       IF (pm.collab_site_org_id > 0
        AND collab_ind=1
        AND pm.collab_site_org_id=collab_site_org_id)
        not_assigned_checklist_accrual += 1
       ENDIF
       trial_not_assigned_checklist_accrual += 1
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
      IF (get_both_ind=0)
       IF (pm.collab_site_org_id > 0
        AND collab_ind=1
        AND pm.collab_site_org_id=collab_site_org_id)
        IF (pm.prot_master_id != parent_prot_master_id)
         not_assigned_checklist_accrual += 1
        ENDIF
       ELSE
        IF (collab_ind=0)
         IF (pm.prot_master_id=parent_prot_master_id)
          not_assigned_checklist_accrual += 1
         ENDIF
        ENDIF
       ENDIF
      ELSE
       IF (parser(aliaspoollist))
        trial_not_assigned_checklist_accrual += 1
        IF (pm.collab_site_org_id > 0
         AND collab_ind=1
         AND pm.collab_site_org_id=collab_site_org_id)
         not_assigned_checklist_accrual += 1
        ELSE
         IF (collab_ind=0
          AND pm.collab_site_org_id=0)
          not_assigned_checklist_accrual += 1
         ENDIF
        ENDIF
       ELSE
        IF (pm.collab_site_org_id > 0
         AND collab_ind=1
         AND pm.collab_site_org_id=collab_site_org_id)
         not_assigned_checklist_accrual += 1
        ENDIF
        trial_not_assigned_checklist_accrual += 1
       ENDIF
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   CALL echo(build("Not_Assigned_Checklist_Accrual is: ",not_assigned_checklist_accrual))
   CALL echo(build("Trial_Not_Assigned_Checklist_Accrual is: ",trial_not_assigned_checklist_accrual))
   IF (curqual=0)
    IF (not_assigned_checklist_accrual=0
     AND trial_not_assigned_checklist_accrual=0)
     SET reply->status_data.status = "Z"
    ELSE
     SET reply->status_data.status = "F"
     GO TO check_error
    ENDIF
   ELSE
    IF (((not_assigned_checklist_accrual > 0) OR (trial_not_assigned_checklist_accrual > 0)) )
     SET reply->status_data.status = "S"
    ENDIF
   ENDIF
   IF (get_both_ind=0)
    SET reply->totalaccrued = ((assigned_checklist_accrual+ enrolled_accrual)+
    not_assigned_checklist_accrual)
   ELSE
    SET reply->grouptargetaccrued = ((trial_assigned_checklist_accrual+ trial_enrolled_accrual)+
    trial_not_assigned_checklist_accrual)
    SET reply->totalaccrued = ((assigned_checklist_accrual+ enrolled_accrual)+
    not_assigned_checklist_accrual)
   ENDIF
   IF ((reply->accrual_estimate_only_ind=0))
    SET count = size(request->person_list,5)
    IF (count > 0)
     IF ((reply->bfound=1))
      IF ((count > (reply->grouptargetaccrual - reply->grouptargetaccrued)))
       SET reply->over_accrual_ind = 1
      ELSEIF (((count - reply->excluded_person_cnt) > (reply->targetaccrual - reply->totalaccrued)))
       SET reply->over_accrual_ind = 1
      ENDIF
     ELSE
      IF ((count > (reply->targetaccrual - reply->totalaccrued)))
       SET reply->over_accrual_ind = 1
      ENDIF
     ENDIF
    ELSEIF ((request->person_id > 0))
     IF ((reply->bfound=1))
      IF ((reply->excludedpersonind=0))
       IF ((reply->totalaccrued >= reply->targetaccrual))
        SET reply->over_accrual_ind = 1
       ENDIF
      ENDIF
      IF ((reply->track_tw_accrual=1)
       AND (reply->grouptargetaccrued >= reply->grouptargetaccrual))
       SET reply->over_accrual_ind = 1
      ENDIF
     ELSE
      IF ((((reply->totalaccrued < reply->targetaccrual)) OR ((reply->grouptargetaccrual=0))) )
       SET reply->over_accrual_ind = 0
      ELSE
       SET reply->over_accrual_ind = 1
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  ELSE
   SET reply->totalaccrued = 0
   SET reply->targetaccrual = 0
   SET reply->grouptargetaccrual = 0
   SET reply->grouptargetaccrued = 0
   SET reply->status_data.status = "Z"
  ENDIF
 ELSE
  SET reply->totalaccrued = 0
  SET reply->targetaccrual = 0
  SET reply->grouptargetaccrual = 0
  SET reply->grouptargetaccrued = 0
  SET reply->status_data.status = "S"
 ENDIF
#check_error
 IF (fail_flag=0)
  SET reply->status_data.status = "S"
  SET reply->status_data.subeventstatus[1].operationname = ""
  SET reply->status_data.subeventstatus[1].operationstatus = "S"
  SET reply->status_data.subeventstatus[1].targetobjectname = ""
  SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
 ELSE
  CASE (fail_flag)
   OF search_for_enrolled:
    SET reply->status_data.subeventstatus[1].operationname = "SELECT"
    SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Searching for enrollments"
   OF search_for_assigned:
    SET reply->status_data.subeventstatus[1].operationname = "SELECT"
    SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Searching for assignments"
   OF search_for_not_assigned:
    SET reply->status_data.subeventstatus[1].operationname = "SELECT"
    SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Searching for non-assignments"
   OF search_for_amd:
    SET reply->status_data.subeventstatus[1].operationname = "SELECT"
    SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Searching for amendment"
   OF search_for_coordinst:
    SET reply->status_data.subeventstatus[1].operationname = "SEARCH"
    SET reply->status_data.subeventstatus[1].targetobjectname = "COORDINATING"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Searching for coordinating institution"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
    SET reply->status_data.subeventstatus[1].targetobjectname = ""
    SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
  ENDCASE
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
 ENDIF
 SET last_mod = "014"
 SET mod_date = "July 30, 2019"
END GO
