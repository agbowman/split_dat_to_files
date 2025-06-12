CREATE PROGRAM ct_get_amd_milestones:dba
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 prot_title = vc
    1 prot_mnemonic = vc
    1 amendment_description = vc
    1 amendment_status_cd = f8
    1 amendment_status_disp = vc
    1 amendment_status_mean = vc
    1 participation_type_cd = f8
    1 participation_type_disp = vc
    1 participation_type_mean = vc
    1 prot_master_id = f8
    1 prot_suspension_id = f8
    1 first_amendment = i2
    1 amendment_nbr = i2
    1 suspendedcnt = i2
    1 enrollmentcnt = i4
    1 revision_nbr_txt = c30
    1 can_activate = i2
    1 can_set_invalid = i2
    1 collab_site_ind = i2
    1 previous_status_cd = f8
    1 previous_status_disp = vc
    1 previous_status_mean = vc
    1 prot_status_cd = f8
    1 prot_status_disp = vc
    1 prot_status_mean = vc
    1 qual[*]
      2 ct_milestones_id = f8
      2 sequence_nbr = i4
      2 committee_id = f8
      2 committee_name = vc
      2 organization_id = f8
      2 org_name = vc
      2 prot_role_cd = f8
      2 prot_role_disp = vc
      2 prot_role_mean = vc
      2 entity_type_flag = i2
      2 activity_cd = f8
      2 activity_disp = vc
      2 activity_mean = vc
      2 performed_dt_tm = dq8
      2 committee_type_cd = f8
    1 type[*]
      2 default_list_type_cd = f8
      2 default_list_type_disp = vc
      2 default_list_type_mean = vc
    1 categories[*]
      2 category_cd = f8
      2 category_disp = c40
      2 category_desc = c60
      2 category_mean = c12
      2 item_list[*]
        3 ct_prot_type_config_id = f8
        3 item_cd = f8
        3 item_disp = c40
        3 item_desc = c60
        3 item_mean = c12
        3 item_info = vc
        3 value_cd = f8
        3 value_disp = c40
        3 value_desc = c60
        3 value_mean = c12
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE SET hold_org
 RECORD hold_org(
   1 qual[*]
     2 org_id = f8
     2 row = i2
 )
 FREE SET hold_com
 RECORD hold_com(
   1 qual[*]
     2 com_id = f8
     2 row = i2
 )
 DECLARE is_prot_role = i2 WITH protect, constant(0)
 DECLARE is_organization = i2 WITH protect, constant(1)
 DECLARE is_committee = i2 WITH protect, constant(2)
 DECLARE true = i2 WITH protect, constant(1)
 DECLARE false = i2 WITH protect, constant(0)
 SET reply->status_data.status = "F"
 DECLARE cnt_org = i2 WITH protect, noconstant(0)
 DECLARE discontinued_cd = f8 WITH protect, noconstant(0.0)
 DECLARE invalid_cd = f8 WITH protect, noconstant(0.0)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 SET stat = uar_get_meaning_by_codeset(17274,"DISCONTINUED",1,discontinued_cd)
 SET stat = uar_get_meaning_by_codeset(17274,"INVALID",1,invalid_cd)
 SET reply->first_amendment = true
 SET reply->can_activate = true
 SET reply->can_set_invalid = false
 SELECT INTO "nl:"
  FROM prot_amendment pa,
   prot_master pm,
   dummyt d,
   prot_suspension ps
  PLAN (pa
   WHERE (pa.prot_amendment_id=request->prot_amendment_id))
   JOIN (pm
   WHERE pm.prot_master_id=pa.prot_master_id)
   JOIN (d)
   JOIN (ps
   WHERE ps.prot_amendment_id=pa.prot_amendment_id
    AND ps.end_effective_dt_tm >= cnvtdatetime("31-dec-2100 00:00:00.00"))
  DETAIL
   reply->prot_title = pa.prot_title, reply->prot_mnemonic = pm.primary_mnemonic, reply->
   amendment_description = pa.amendment_description,
   reply->amendment_status_cd = pa.amendment_status_cd, reply->participation_type_cd = pa
   .participation_type_cd, reply->prot_master_id = pm.prot_master_id,
   reply->amendment_nbr = pa.amendment_nbr, reply->revision_nbr_txt = pa.revision_nbr_txt, reply->
   prot_status_cd = pm.prot_status_cd
   IF (ps.seq > 0)
    reply->prot_suspension_id = ps.prot_suspension_id
   ELSE
    reply->prot_suspension_id = 0.0
   ENDIF
   IF (pm.collab_site_org_id > 0.0)
    reply->collab_site_ind = 1
   ELSE
    reply->collab_site_ind = 0
   ENDIF
  WITH outerjoin = d, nocounter
 ;end select
 SET suspendedcnt = 0
 SELECT INTO "nl:"
  FROM prot_suspension ps
  PLAN (ps
   WHERE (ps.prot_amendment_id=request->prot_amendment_id))
  DETAIL
   suspendedcnt = (suspendedcnt+ 1)
  WITH nocounter
 ;end select
 SET reply->suspendedcnt = suspendedcnt
 CALL echo(build("Suspended this many times: ",suspendedcnt))
 SET enrollmentcnt = 0
 SELECT INTO "nl:"
  FROM pt_prot_reg ppr
  PLAN (ppr
   WHERE (ppr.prot_master_id=reply->prot_master_id)
    AND ppr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  DETAIL
   enrollmentcnt = (enrollmentcnt+ 1)
  WITH nocounter
 ;end select
 SET reply->enrollmentcnt = enrollmentcnt
 CALL echo(build("Number of persons enrolled: ",enrollmentcnt))
 SELECT INTO "nl:"
  pa.prot_amendment_id
  FROM prot_amendment pa
  WHERE (pa.prot_master_id=reply->prot_master_id)
   AND (pa.prot_amendment_id != request->prot_amendment_id)
  DETAIL
   IF ((pa.amendment_nbr != - (1))
    AND (pa.amendment_nbr < reply->amendment_nbr))
    reply->first_amendment = false
   ENDIF
   IF ((pa.amendment_nbr > reply->amendment_nbr)
    AND (reply->amendment_status_cd=discontinued_cd))
    IF (pa.amendment_dt_tm <= cnvtdatetime(curdate,curtime3))
     reply->can_activate = false
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF ((reply->amendment_status_cd=reply->prot_status_cd)
  AND (reply->collab_site_ind=0))
  SELECT INTO "nl:"
   pa.prot_amendment_id, pa.amendment_nbr, pa.revision_seq
   FROM prot_amendment pa
   WHERE (pa.prot_master_id=reply->prot_master_id)
   ORDER BY pa.amendment_nbr DESC, pa.revision_seq DESC
   DETAIL
    IF ((request->prot_amendment_id=pa.prot_amendment_id))
     reply->can_set_invalid = true
    ENDIF
   WITH maxrec = 1, nocounter
  ;end select
  IF ((reply->can_set_invalid=true))
   SELECT INTO "nl:"
    pm.prot_master_id
    FROM prot_master pm
    WHERE (pm.parent_prot_master_id=reply->prot_master_id)
     AND pm.prot_master_id != pm.parent_prot_master_id
     AND pm.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    ORDER BY pm.prot_master_id
    DETAIL
     CALL echo("can_set_invalid because is parent collab"), reply->can_set_invalid = false
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF ((reply->amendment_status_cd=invalid_cd))
  SET reply->previous_status_cd = 0
  SELECT INTO "nl:"
   FROM prot_master pm
   WHERE (pm.prev_prot_master_id=reply->prot_master_id)
   ORDER BY pm.updt_cnt DESC
   DETAIL
    IF ((reply->previous_status_cd=0)
     AND pm.prot_status_cd != invalid_cd)
     reply->previous_status_cd = pm.prot_status_cd
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 RECORD cfg_request(
   1 protocol_type_cd = f8
 )
 CALL echo(build("reply->participation_type_cd =",reply->participation_type_cd))
 SET cfg_request->protocol_type_cd = reply->participation_type_cd
 EXECUTE ct_get_prot_type_config  WITH replace("REQUEST","CFG_REQUEST")
 SELECT INTO "nl:"
  FROM ct_milestones cm
  WHERE (cm.prot_amendment_id=request->prot_amendment_id)
  ORDER BY cm.sequence_nbr
  HEAD REPORT
   cnt = 0, cnt_com = 0, cnt_org = 0
  DETAIL
   cnt = (cnt+ 1), bstat = alterlist(reply->qual,cnt), reply->qual[cnt].activity_cd = cm.activity_cd,
   reply->qual[cnt].sequence_nbr = cm.sequence_nbr, reply->qual[cnt].entity_type_flag = cm
   .entity_type_flag, reply->qual[cnt].ct_milestones_id = cm.ct_milestones_id,
   reply->qual[cnt].performed_dt_tm = cm.performed_dt_tm
   CASE (cm.entity_type_flag)
    OF is_organization:
     reply->qual[cnt].organization_id = cm.organization_id,cnt_org = (cnt_org+ 1),bstat = alterlist(
      hold_org->qual,cnt_org),
     hold_org->qual[cnt_org].org_id = cm.organization_id,hold_org->qual[cnt_org].row = cnt
    OF is_committee:
     reply->qual[cnt].committee_id = cm.committee_id,cnt_com = (cnt_com+ 1),bstat = alterlist(
      hold_com->qual,cnt_com),
     hold_com->qual[cnt_com].com_id = cm.committee_id,hold_com->qual[cnt_com].row = cnt
    ELSE
     reply->qual[cnt].prot_role_cd = cm.prot_role_cd
   ENDCASE
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
  GO TO get_default_type
 ENDIF
 SET org_size = size(hold_org->qual,5)
 IF (org_size > 0)
  SELECT INTO "nl:"
   d.seq
   FROM organization o,
    (dummyt d  WITH seq = value(org_size))
   PLAN (d)
    JOIN (o
    WHERE (o.organization_id=hold_org->qual[d.seq].org_id))
   HEAD d.seq
    x = hold_org->qual[d.seq].row
   DETAIL
    reply->qual[x].org_name = o.org_name
   WITH nocounter
  ;end select
  FREE SET hold_org
 ENDIF
 SET com_size = size(hold_com->qual,5)
 IF (com_size > 0)
  SELECT INTO "nl:"
   d.seq
   FROM committee c,
    (dummyt d  WITH seq = value(com_size))
   PLAN (d)
    JOIN (c
    WHERE (c.committee_id=hold_com->qual[d.seq].com_id))
   HEAD d.seq
    x = hold_com->qual[d.seq].row
   DETAIL
    reply->qual[x].committee_name = c.committee_name, reply->qual[x].committee_type_cd = c
    .committee_type_cd
   WITH nocounter
  ;end select
  FREE SET hold_com
 ENDIF
 GO TO end_script
#get_default_type
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=17302
   AND cv.active_ind=1
  ORDER BY cv.display
  HEAD REPORT
   cnt = 0
  DETAIL
   IF ( NOT (cv.cdf_meaning="CONCEPT"))
    cnt = (cnt+ 1), bstat = alterlist(reply->type,cnt), reply->type[cnt].default_list_type_cd = cv
    .code_value,
    reply->type[cnt].default_list_type_disp = cv.display, reply->type[cnt].default_list_type_mean =
    cv.cdf_meaning
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#end_script
 SET last_mod = "007"
 SET mod_date = "Oct 9, 2008"
END GO
