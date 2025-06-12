CREATE PROGRAM ct_get_default_milestones:dba
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 type[*]
      2 default_list_type_cd = f8
      2 default_list_type_disp = vc
      2 default_list_type_mean = vc
      2 qual[*]
        3 ct_default_milestones_id = f8
        3 sequence_nbr = i4
        3 committee_id = f8
        3 committee_name = vc
        3 committee_type_cd = f8
        3 organization_id = f8
        3 org_name = vc
        3 prot_role_cd = f8
        3 prot_role_disp = vc
        3 prot_role_mean = vc
        3 entity_type_flag = i2
        3 activity_cd = f8
        3 activity_disp = vc
        3 activity_mean = vc
    1 roles[*]
      2 code_value = f8
      2 cdf_meaning = vc
      2 display = vc
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
     2 col = i2
 )
 FREE SET hold_com
 RECORD hold_com(
   1 qual[*]
     2 com_id = f8
     2 row = i2
     2 col = i2
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
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 SET is_prot_role = 0
 SET is_organization = 1
 SET is_committee = 2
 SET reply->status_data.status = "F"
 SET cnt_org = 0
 SELECT INTO "nl:"
  FROM code_value cv,
   ct_default_milestones cdm,
   dummyt d1
  PLAN (cv
   WHERE cv.code_set=17302)
   JOIN (d1)
   JOIN (cdm
   WHERE cdm.default_list_type_cd=cv.code_value
    AND cdm.ct_default_milestones_id != 0.0
    AND (cdm.logical_domain_id=domain_reply->logical_domain_id))
  ORDER BY cv.display, cdm.sequence_nbr
  HEAD REPORT
   cnt = 0, cnt_com = 0, cnt_org = 0
  HEAD cv.code_value
   cnt += 1, bstat = alterlist(reply->type,cnt), reply->type[cnt].default_list_type_cd = cv
   .code_value,
   reply->type[cnt].default_list_type_disp = cv.display, reply->type[cnt].default_list_type_mean = cv
   .cdf_meaning, cnt1 = 0
  DETAIL
   cnt1 += 1, bstat = alterlist(reply->type[cnt].qual,cnt1), reply->type[cnt].qual[cnt1].activity_cd
    = cdm.activity_cd,
   reply->type[cnt].qual[cnt1].sequence_nbr = cdm.sequence_nbr, reply->type[cnt].qual[cnt1].
   entity_type_flag = cdm.entity_type_flag, reply->type[cnt].qual[cnt1].ct_default_milestones_id =
   cdm.ct_default_milestones_id
   CASE (cdm.entity_type_flag)
    OF is_organization:
     reply->type[cnt].qual[cnt1].organization_id = cdm.organization_id,cnt_org += 1,bstat = alterlist
     (hold_org->qual,cnt_org),
     hold_org->qual[cnt_org].org_id = cdm.organization_id,hold_org->qual[cnt_org].row = cnt,hold_org
     ->qual[cnt_org].col = cnt1
    OF is_committee:
     reply->type[cnt].qual[cnt1].committee_id = cdm.committee_id,cnt_com += 1,bstat = alterlist(
      hold_com->qual,cnt_com),
     hold_com->qual[cnt_com].com_id = cdm.committee_id,hold_com->qual[cnt_com].row = cnt,hold_com->
     qual[cnt_com].col = cnt1
    ELSE
     reply->type[cnt].qual[cnt1].prot_role_cd = cdm.prot_role_cd
   ENDCASE
  FOOT  cv.display
   IF (cnt1=1)
    IF ((reply->type[cnt].qual[1].activity_cd=0.0)
     AND (reply->type[cnt].qual[1].ct_default_milestones_id=0.0))
     bstat = alterlist(reply->type[cnt].qual,0)
    ENDIF
   ENDIF
  FOOT REPORT
   cnt = 0
  WITH nocounter, outerjoin = d1
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
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
    x = hold_org->qual[d.seq].row, y = hold_org->qual[d.seq].col
   DETAIL
    reply->type[x].qual[y].org_name = o.org_name
   WITH nocounter
  ;end select
  FREE SET hold_org
 ENDIF
 SET com_size = size(hold_com->qual,5)
 IF (com_size > 0)
  SELECT INTO "nl:"
   FROM committee c,
    (dummyt d  WITH seq = value(com_size))
   PLAN (d)
    JOIN (c
    WHERE (c.committee_id=hold_com->qual[d.seq].com_id))
   HEAD d.seq
    x = hold_com->qual[d.seq].row, y = hold_com->qual[d.seq].col
   DETAIL
    reply->type[x].qual[y].committee_name = c.committee_name, reply->type[x].qual[y].
    committee_type_cd = c.committee_type_cd
   WITH nocounter
  ;end select
  FREE SET hold_com
 ENDIF
 SET revcd = 0.0
 SET stat = uar_get_meaning_by_codeset(26974,"REVIEWRPRTS",1,revcd)
 SET cnt = 0
 SELECT INTO "nl:"
  cvg.code_value_group_id, cv.code_value_id
  FROM code_value_group cvg,
   code_value cv
  PLAN (cvg
   WHERE cvg.parent_code_value=revcd
    AND cvg.code_set=17441)
   JOIN (cv
   WHERE cv.code_value=cvg.child_code_value
    AND cv.active_ind=1)
  DETAIL
   cnt += 1, stat = alterlist(reply->roles,cnt), reply->roles[cnt].code_value = cv.code_value,
   reply->roles[cnt].cdf_meaning = cv.cdf_meaning, reply->roles[cnt].display = cv.display
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "F"
 ENDIF
 SET last_mod = "002"
 SET mod_date = "June 17, 2019"
END GO
