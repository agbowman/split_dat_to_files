CREATE PROGRAM ct_get_general:dba
 RECORD reply(
   1 amd_status_cd = f8
   1 amd_status_disp = c40
   1 amd_status_desc = c60
   1 amd_status_mean = c12
   1 prot_status_cd = f8
   1 prot_status_disp = c40
   1 prot_status_desc = c60
   1 prot_status_mean = c12
   1 prot_accrual = i2
   1 amd_accrual = i2
   1 target_accrual = i4
   1 group_target_accrual = i2
   1 group_accrual = i2
   1 prot_title = vc
   1 primary_mnemonic = c255
   1 collab_site_org_name = c255
   1 network_flag = i2
   1 prot_aliases[*]
     2 alias = vc
     2 alias_pool_cd = f8
     2 alias_pool_disp = c40
     2 alias_pool_desc = c60
     2 alias_pool_mean = c12
     2 alias_format = c100
   1 amd_aliases[*]
     2 alias = vc
     2 alias_pool_cd = f8
     2 alias_pool_disp = c40
     2 alias_pool_desc = c60
     2 alias_pool_mean = c12
     2 alias_format = c100
   1 pi = c50
   1 init_service_cd = f8
   1 init_service_disp = c40
   1 init_service_desc = c60
   1 init_service_mean = c12
   1 type_cd = f8
   1 type_disp = c40
   1 type_desc = c60
   1 type_mean = c12
   1 prot_phase_cd = f8
   1 prot_phase_disp = c40
   1 prot_phase_desc = c60
   1 prot_phase_mean = c12
   1 program_cd = f8
   1 program_disp = c40
   1 program_desc = c60
   1 program_mean = c12
   1 participation_type_cd = f8
   1 participation_type_disp = c40
   1 participation_type_desc = c60
   1 participation_type_mean = c12
   1 modalities[*]
     2 modality_cd = f8
     2 modality_disp = c40
   1 primary_sponsor = c100
   1 secondary[*]
     2 secondary_sponsor = c100
   1 date_activated = dq8
   1 first_date_activated = dq8
   1 date_closed = dq8
   1 date_completed = dq8
   1 first_irb_approved = dq8
   1 amd_irb_approved = dq8
   1 next_review_due_by = dq8
   1 diseases[*]
     2 disease_type_cd = f8
     2 disease_type_disp = c40
     2 disease_type_desc = c60
     2 disease_type_mean = c12
   1 bfound = i2
   1 revision_nbr_txt = c30
   1 amendment_nbr = i4
   1 revision_description = vc
   1 revision_reasons[*]
     2 reason_type_cd = f8
     2 reason_type_disp = c40
     2 reason_type_desc = c60
     2 reason_type_mean = c12
   1 primary_contacts[*]
     2 primary_contact_name = vc
     2 primary_contact_role = vc
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
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE ncount = i2 WITH protect, noconstant(0)
 DECLARE mrn_cd = f8 WITH protect, noconstant(0.0)
 DECLARE enrolling_cd = f8 WITH public, noconstant(0.0)
 DECLARE coordinst_cd = f8 WITH protect, noconstant(0.0)
 DECLARE aliaspoolcount = i4 WITH protect, noconstant(0)
 DECLARE aliaspoollist = vc WITH protect, noconstant("")
 DECLARE prot_master_id = f8 WITH protect, noconstant(0.0)
 DECLARE cnt = i2 WITH protect, noconstant(0)
 DECLARE contactcountcntr = i2 WITH protect, noconstant(0)
 DECLARE lookup_primary_cd = f8 WITH protect, noconstant(0.0)
 DECLARE action_cd = f8 WITH protect, noconstant(0.0)
 DECLARE sponsor_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE irb_cd = f8 WITH protect, noconstant(0.0)
 DECLARE amendment_id = f8 WITH protect, noconstant(0.0)
 DECLARE temp_id = f8 WITH protect, noconstant(0.0)
 DECLARE parent_prot_master_id = f8 WITH protect, noconstant(0.0)
 DECLARE collab_ind = i2 WITH protect, noconstant(0)
 DECLARE track_tw_accrual = i2 WITH protect, noconstant(0)
 DECLARE collab_site_org_id = f8 WITH protect, noconstant(0.0)
 DECLARE trialwide_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",17906,"TRIALWIDE"))
 DECLARE def_org_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",17906,"DEFAULTORG"))
 SET stat = uar_get_meaning_by_codeset(17900,"ENROLLING",1,enrolling_cd)
 SET stat = uar_get_meaning_by_codeset(4,"MRN",1,mrn_cd)
 SET stat = uar_get_meaning_by_codeset(17441,"COORDINST",1,coordinst_cd)
 SET track_tw_accrual = 0
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
     AND ((cfg.item_cd=trialwide_cd) OR (cfg.item_cd=def_org_cd))
     AND (cfg.logical_domain_id=domain_reply->logical_domain_id))
   DETAIL
    parent_prot_master_id = pa.prot_master_id
    IF (((cfg.item_cd=trialwide_cd
     AND uar_get_code_meaning(cfg.config_value_cd)="YES") OR (cfg.item_cd=def_org_cd
     AND uar_get_code_meaning(cfg.config_value_cd)="YES")) )
     track_tw_accrual += 1
    ENDIF
    reply->group_target_accrual = pa.groupwide_targeted_accrual
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
     AND ((cfg.item_cd=trialwide_cd) OR (cfg.item_cd=def_org_cd))
     AND (cfg.logical_domain_id=domain_reply->logical_domain_id))
   DETAIL
    prot_master_id = pa.prot_master_id, parent_prot_master_id = pa.prot_master_id, reply->
    participation_type_cd = pa.participation_type_cd
    IF (((cfg.item_cd=trialwide_cd
     AND uar_get_code_meaning(cfg.config_value_cd)="YES") OR (cfg.item_cd=def_org_cd
     AND uar_get_code_meaning(cfg.config_value_cd)="YES")) )
     track_tw_accrual += 1
    ENDIF
    reply->group_target_accrual = pa.groupwide_targeted_accrual
   WITH nocounter
  ;end select
 ENDIF
 IF (track_tw_accrual > 1)
  SET track_tw_accrual = 1
 ELSE
  SET track_tw_accrual = 0
 ENDIF
 CALL echo(build("collab_site_org_id =",collab_site_org_id))
 CALL echo(build("track_tw_accrual =",track_tw_accrual))
 CALL echo(build("groupwide =",reply->group_target_accrual))
 CALL echo(build("parent =",parent_prot_master_id))
 SET reply->bfound = false
 IF (track_tw_accrual=1)
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
  CALL echo(build("prot amendment id is:",request->prot_amendment_id))
  IF ((reply->status_data.status="F"))
   SET fail_flag = search_for_coordinst
   GO TO check_error
  ENDIF
  IF ((reply->bfound=false))
   SET track_tw_accrual = 0
  ENDIF
 ENDIF
 CALL echo(build("track_tw_accrual is ",track_tw_accrual))
 SET aliaspoollist = "p_a.alias_pool_cd NOT IN ("
 SELECT DISTINCT INTO "NL:"
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
   IF (track_tw_accrual=0)
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
   IF (track_tw_accrual=0)
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
    IF (track_tw_accrual=0)
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
 CALL echo(reply->prot_accrual)
 CALL echo(reply->group_accrual)
 CALL echo("accrual calculation ok")
 SELECT INTO "nl:"
  p.*
  FROM prot_alias p,
   alias_pool a,
   prot_amendment pa
  PLAN (pa
   WHERE (pa.prot_amendment_id=request->prot_amendment_id))
   JOIN (p
   WHERE p.prot_master_id=pa.prot_master_id
    AND p.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (a
   WHERE p.alias_pool_cd=a.alias_pool_cd)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->prot_aliases,(cnt+ 9))
   ENDIF
   reply->prot_aliases[cnt].alias = p.prot_alias, reply->prot_aliases[cnt].alias_pool_cd = p
   .alias_pool_cd, reply->prot_aliases[cnt].alias_format = a.format_mask
  FOOT REPORT
   stat = alterlist(reply->prot_aliases,cnt)
  WITH nocounter
 ;end select
 CALL echo("PROTOCOL ALIASES OK")
 SELECT INTO "nl:"
  p.*
  FROM amendment_alias aa,
   alias_pool ap
  PLAN (aa
   WHERE (aa.prot_amendment_id=request->prot_amendment_id)
    AND aa.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (ap
   WHERE ap.alias_pool_cd=aa.alias_pool_cd)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->amd_aliases,(cnt+ 9))
   ENDIF
   reply->amd_aliases[cnt].alias = aa.amendment_alias, reply->amd_aliases[cnt].alias_pool_cd = aa
   .alias_pool_cd, reply->amd_aliases[cnt].alias_format = ap.format_mask
  FOOT REPORT
   stat = alterlist(reply->amd_aliases,cnt)
  WITH nocounter
 ;end select
 CALL echo("AMENDMENT ALIASES OK")
 SET stat = uar_get_meaning_by_codeset(17441,"PRIMARY",1,lookup_primary_cd)
 CALL echo(build("PI cd = ",lookup_primary_cd))
 SELECT INTO "nl:"
  p.name_full_formatted
  FROM prot_role pt,
   prsnl p
  PLAN (pt
   WHERE (pt.prot_amendment_id=request->prot_amendment_id)
    AND pt.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND pt.prot_role_cd=lookup_primary_cd)
   JOIN (p
   WHERE p.person_id=pt.person_id)
  DETAIL
   reply->pi = p.name_full_formatted,
   CALL echo("inside detail - pi"),
   CALL echo(build("pi id = ",p.person_id)),
   CALL echo(build("pi name = ",p.name_full_formatted))
  WITH nocounter
 ;end select
 CALL echo("PI OK")
 SET cnt = 0
 SELECT INTO "nl:"
  p.name_full_formatted
  FROM prot_role pt,
   prsnl p
  PLAN (pt
   WHERE (pt.prot_amendment_id=request->prot_amendment_id)
    AND pt.primary_contact_ind=1
    AND pt.primary_contact_rank_nbr > 0
    AND pt.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (p
   WHERE p.person_id=pt.person_id)
  ORDER BY pt.primary_contact_rank_nbr, p.name_last, p.name_first
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->primary_contacts,(cnt+ 9))
   ENDIF
   reply->primary_contacts[cnt].primary_contact_name = p.name_full_formatted, reply->
   primary_contacts[cnt].primary_contact_role = uar_get_code_display(pt.prot_role_cd)
  FOOT REPORT
   stat = alterlist(reply->primary_contacts,cnt), contactcountcntr = cnt
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  p.name_full_formatted
  FROM prot_role pt,
   prsnl p
  PLAN (pt
   WHERE (pt.prot_amendment_id=request->prot_amendment_id)
    AND pt.primary_contact_ind=1
    AND pt.primary_contact_rank_nbr=0
    AND pt.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (p
   WHERE p.person_id=pt.person_id)
  ORDER BY pt.primary_contact_rank_nbr, p.name_last, p.name_first
  HEAD REPORT
   stat = alterlist(reply->primary_contacts,(contactcountcntr+ 10))
  DETAIL
   contactcountcntr += 1
   IF (mod(contactcountcntr,10)=1)
    stat = alterlist(reply->primary_contacts,(contactcountcntr+ 9))
   ENDIF
   reply->primary_contacts[contactcountcntr].primary_contact_name = p.name_full_formatted, reply->
   primary_contacts[contactcountcntr].primary_contact_role = uar_get_code_display(pt.prot_role_cd)
  FOOT REPORT
   stat = alterlist(reply->primary_contacts,contactcountcntr)
  WITH nocounter
 ;end select
 SET stat = uar_get_meaning_by_codeset(17271,"PRIMARY",1,sponsor_type_cd)
 CALL echo("CD PSponsor CALCULATION OK")
 SELECT INTO "nl:"
  org.org_name
  FROM prot_grant_sponsor pgs,
   organization org
  PLAN (pgs
   WHERE (pgs.prot_amendment_id=request->prot_amendment_id))
   JOIN (org
   WHERE org.organization_id=pgs.organization_id
    AND pgs.primary_secondary_cd=sponsor_type_cd)
  DETAIL
   reply->primary_sponsor = org.org_name
  WITH nocounter
 ;end select
 CALL echo("ORG SPONSOR OK")
 SELECT INTO "nl:"
  o1.org_name
  FROM prot_grant_sponsor pg1,
   organization o1
  PLAN (pg1
   WHERE (pg1.prot_amendment_id=request->prot_amendment_id)
    AND pg1.primary_secondary_cd != sponsor_type_cd)
   JOIN (o1
   WHERE o1.organization_id=pg1.organization_id)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->secondary,(cnt+ 9))
   ENDIF
   reply->secondary[cnt].secondary_sponsor = o1.org_name
  FOOT REPORT
   stat = alterlist(reply->secondary,cnt)
  WITH nocounter
 ;end select
 CALL echo("ORG SECONDARY SPONSOR OK")
 SELECT INTO "NL:"
  pm.modality_cd
  FROM prot_modality pt
  WHERE (pt.prot_amendment_id=request->prot_amendment_id)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->modalities,(cnt+ 9))
   ENDIF
   reply->modalities[cnt].modality_cd = pt.modality_cd
  FOOT REPORT
   stat = alterlist(reply->modalities,cnt)
  WITH nocounter
 ;end select
 CALL echo("MODALITIES OK")
 CALL echo("before select- diseases")
 SELECT INTO "NL:"
  d.*
  FROM appl_disease d
  WHERE (d.prot_amendment_id=request->prot_amendment_id)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    new = (cnt+ 10), stat = alterlist(reply->diseases,new)
   ENDIF
   reply->diseases[cnt].disease_type_cd = d.disease_type_cd
  FOOT REPORT
   stat = alterlist(reply->diseases,cnt)
  WITH nocounter
 ;end select
 CALL echo("DISEASES OK")
 CALL echo("before select - reasons")
 SELECT INTO "NL:"
  ar.*
  FROM amendment_reason ar
  WHERE (ar.prot_amendment_id=request->prot_amendment_id)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    new = (cnt+ 10), stat = alterlist(reply->revision_reasons,new)
   ENDIF
   reply->revision_reasons[cnt].reason_type_cd = ar.amendment_reason_cd
  FOOT REPORT
   stat = alterlist(reply->revision_reasons,cnt)
  WITH nocounter
 ;end select
 CALL echo("REASONS Otay")
 SET stat = uar_get_meaning_by_codeset(26954,"NEXTCONTREV",1,action_cd)
 CALL echo(build("NEXTCONTREV ",action_cd))
 SELECT INTO "NL:"
  c.performed_dt_tm
  FROM ct_prot_milestones c
  WHERE c.prot_master_id=prot_master_id
   AND c.activity_cd=action_cd
   AND c.performed_dt_tm < cnvtdatetime("31-DEC-2100 00:00:00.00")
  ORDER BY c.performed_dt_tm
  DETAIL
   reply->next_review_due_by = c.performed_dt_tm
  WITH nocounter
 ;end select
 SET stat = uar_get_meaning_by_codeset(17876,"APPROVED",1,action_cd)
 CALL echo(build("APPROVED ",action_cd))
 SET stat = uar_get_meaning_by_codeset(22209,"IRB",1,irb_cd)
 SELECT INTO "nl:"
  c.performed_dt_tm
  FROM ct_milestones c,
   committee co
  PLAN (c
   WHERE c.activity_cd=action_cd
    AND (c.prot_amendment_id=request->prot_amendment_id)
    AND c.entity_type_flag=2
    AND c.performed_dt_tm < cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (co
   WHERE co.committee_id=c.committee_id
    AND co.committee_type_cd=irb_cd)
  DETAIL
   reply->amd_irb_approved = c.performed_dt_tm
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  c.performed_dt_tm
  FROM ct_milestones c,
   prot_amendment a,
   committee co
  PLAN (a
   WHERE a.prot_master_id=prot_master_id)
   JOIN (c
   WHERE c.prot_amendment_id=a.prot_amendment_id
    AND c.activity_cd=action_cd
    AND c.entity_type_flag=2
    AND c.performed_dt_tm < cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (co
   WHERE co.committee_id=c.committee_id
    AND co.committee_type_cd=irb_cd)
  ORDER BY c.performed_dt_tm DESC
  DETAIL
   reply->first_irb_approved = c.performed_dt_tm
  WITH nocounter
 ;end select
 SET stat = uar_get_meaning_by_codeset(17876,"ACTIVATEDBY",1,action_cd)
 SELECT INTO "nl:"
  a.activated_dt_tm
  FROM prot_amendment a
  WHERE a.prot_master_id=prot_master_id
   AND a.amendment_dt_tm < cnvtdatetime("31-DEC-2100 00:00:00.00")
  ORDER BY a.amendment_dt_tm DESC
  DETAIL
   reply->first_date_activated = a.amendment_dt_tm
   IF ((a.prot_amendment_id=request->prot_amendment_id))
    reply->date_activated = a.amendment_dt_tm
   ENDIF
  WITH nocounter
 ;end select
 SET stat = uar_get_meaning_by_codeset(17876,"CLOSED",1,action_cd)
 SELECT INTO "nl:"
  c.performed_dt_tm
  FROM ct_milestones c
  WHERE c.activity_cd=action_cd
   AND (c.prot_amendment_id=request->prot_amendment_id)
   AND c.performed_dt_tm < cnvtdatetime("31-DEC-2100 00:00:00.00")
  DETAIL
   reply->date_closed = c.performed_dt_tm
  WITH nocounter
 ;end select
 CALL echo("DATE CLOSE OK")
 SET stat = uar_get_meaning_by_codeset(17876,"COMPLETED",1,action_cd)
 SELECT INTO "nl:"
  c.performed_dt_tm
  FROM ct_milestones c
  WHERE c.activity_cd=action_cd
   AND (c.prot_amendment_id=request->prot_amendment_id)
   AND c.performed_dt_tm < cnvtdatetime("31-DEC-2100 00:00:00.00")
  DETAIL
   reply->date_completed = c.performed_dt_tm
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  p.prot_status_cd, a.prot_title, p.initiating_service_cd,
  p.prot_type_cd, p.program_cd
  FROM prot_master p,
   prot_amendment a,
   revision r,
   organization o
  PLAN (a
   WHERE (a.prot_amendment_id=request->prot_amendment_id))
   JOIN (p
   WHERE p.prot_master_id=a.prot_master_id)
   JOIN (r
   WHERE (r.prot_amendment_id= Outerjoin(a.prot_amendment_id)) )
   JOIN (o
   WHERE (o.organization_id= Outerjoin(p.collab_site_org_id)) )
  DETAIL
   reply->amd_status_cd = a.amendment_status_cd, reply->prot_status_cd = p.prot_status_cd, reply->
   prot_title = a.prot_title,
   reply->init_service_cd = p.initiating_service_cd, reply->type_cd = p.prot_type_cd, reply->
   program_cd = p.program_cd,
   reply->prot_phase_cd = p.prot_phase_cd, reply->primary_mnemonic = p.primary_mnemonic, reply->
   target_accrual = a.targeted_accrual,
   reply->revision_nbr_txt = a.revision_nbr_txt, reply->amendment_nbr = a.amendment_nbr, reply->
   revision_description = r.revision_description,
   reply->collab_site_org_name = o.org_name, reply->network_flag = p.network_flag
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echo(build("status:",reply->status_data.status))
 SET last_mod = " 028 "
 SET mod_date = "Sep 03, 2019"
END GO
