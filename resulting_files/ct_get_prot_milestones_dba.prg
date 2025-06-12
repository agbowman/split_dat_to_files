CREATE PROGRAM ct_get_prot_milestones:dba
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 prot_mnemonic = vc
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
 )
 FREE SET hold_com
 RECORD hold_com(
   1 qual[*]
     2 com_id = f8
     2 row = i2
 )
 SET is_prot_role = 0
 SET is_organization = 1
 SET is_committee = 2
 SET true = 1
 SET false = 0
 SET reply->status_data.status = "F"
 SET cnt_org = 0
 SELECT INTO "nl:"
  FROM prot_master pm
  WHERE (pm.prot_master_id=request->prot_master_id)
  DETAIL
   reply->prot_mnemonic = pm.primary_mnemonic
  WITH nocounter
 ;end select
 IF (curqual=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM ct_prot_milestones cpm
  WHERE (cpm.prot_master_id=request->prot_master_id)
  ORDER BY cpm.sequence_nbr
  HEAD REPORT
   cnt = 0, cnt_com = 0, cnt_org = 0
  DETAIL
   cnt = (cnt+ 1), bstat = alterlist(reply->qual,cnt), reply->qual[cnt].activity_cd = cpm.activity_cd,
   reply->qual[cnt].sequence_nbr = cpm.sequence_nbr, reply->qual[cnt].entity_type_flag = cpm
   .entity_type_flag, reply->qual[cnt].ct_milestones_id = cpm.ct_prot_milestones_id,
   reply->qual[cnt].performed_dt_tm = cpm.performed_dt_tm
   CASE (cpm.entity_type_flag)
    OF is_organization:
     reply->qual[cnt].organization_id = cpm.organization_id,cnt_org = (cnt_org+ 1),bstat = alterlist(
      hold_org->qual,cnt_org),
     hold_org->qual[cnt_org].org_id = cpm.organization_id,hold_org->qual[cnt_org].row = cnt
    OF is_committee:
     reply->qual[cnt].committee_id = cpm.committee_id,cnt_com = (cnt_com+ 1),bstat = alterlist(
      hold_com->qual,cnt_com),
     hold_com->qual[cnt_com].com_id = cpm.committee_id,hold_com->qual[cnt_com].row = cnt
    ELSE
     reply->qual[cnt].prot_role_cd = cpm.prot_role_cd
   ENDCASE
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
  GO TO get_codes
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
#get_codes
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
   cnt = (cnt+ 1), stat = alterlist(reply->roles,cnt), reply->roles[cnt].code_value = cv.code_value,
   reply->roles[cnt].cdf_meaning = cv.cdf_meaning, reply->roles[cnt].display = cv.display
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
#exit_script
END GO
