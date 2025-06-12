CREATE PROGRAM ct_get_milestone:dba
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
 SET institution_cd = 0.0
 SET multicenter_cd = 0.0
 SET reply->status_data.status = "F"
 SET cnt_org = 0
 SET reply->first_amendment = true
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
    AND ps.end_effective_dt_tm=cnvtdatetime("31-dec-2100 00:00:00.00"))
  DETAIL
   reply->prot_title = pa.prot_title, reply->prot_mnemonic = pm.primary_mnemonic, reply->
   amendment_description = pa.amendment_description,
   reply->amendment_status_cd = pa.amendment_status_cd, reply->participation_type_cd = pm
   .participation_type_cd, reply->prot_master_id = pm.prot_master_id,
   reply->amendment_nbr = pa.amendment_nbr
   IF (ps.seq > 0)
    reply->prot_suspension_id = ps.prot_suspension_id
   ELSE
    reply->prot_suspension_id = 0.0
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
  WITH nocounter
 ;end select
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
 SET stat = uar_get_meaning_by_codeset(17344,"INSTITUTION",1,institution_cd)
 SET stat = uar_get_meaning_by_codeset(17344,"MULTICENTER",1,multicenter_cd)
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=17302
   AND cv.active_ind=1
  ORDER BY cv.display
  HEAD REPORT
   cnt = 0
  DETAIL
   IF ( NOT ((reply->participation_type_cd != institution_cd)
    AND (reply->participation_type_cd != multicenter_cd)
    AND cv.cdf_meaning="CONCEPT"))
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
END GO
