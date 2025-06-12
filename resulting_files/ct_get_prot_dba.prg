CREATE PROGRAM ct_get_prot:dba
 RECORD reply(
   1 primary_mnemonic = vc
   1 prot_purpose_cd = f8
   1 prot_purpose_disp = c50
   1 prot_purpose_desc = c50
   1 prot_purpose_mean = c12
   1 program_cd = f8
   1 program_disp = c50
   1 program_desc = c50
   1 program__mean = c12
   1 prot_phase_cd = f8
   1 prot_phase_disp = c50
   1 prot_phase_desc = c50
   1 prot_phase_mean = c12
   1 participation_type_cd = f8
   1 participation_type_disp = c50
   1 participation_type_desc = c50
   1 participation_type_mean = c12
   1 prot_type_cd = f8
   1 prot_type_disp = c50
   1 prot_type_desc = c50
   1 prot_type_mean = c12
   1 prot_status_cd = f8
   1 prot_status_disp = c50
   1 prot_status_desc = c50
   1 prot_status_mean = c12
   1 initiating_service_cd = f8
   1 initiating_service_disp = c50
   1 initiating_service_desc = c50
   1 initiating_service_mean = c12
   1 initiating_service_desc = vc
   1 initiating_service_other_desc = vc
   1 prot_title = vc
   1 collab_site_org_id = f8
   1 collab_site_org_name = vc
   1 parent_prot_master_id = f8
   1 contributing_depts[*]
     2 dept_id = f8
     2 dept_cd = f8
     2 dept_disp = c50
     2 dept_desc = c50
     2 dept_mean = c12
     2 dept_other_desc = vc
     2 dept_updt_cnt = i4
   1 regulatory[*]
     2 regulatory_id = f8
     2 reporting_type_cd = f8
     2 reporting_type_disp = c50
     2 reporting_type_desc = c50
     2 reporting_type_mean = c12
     2 updt_cnt = i4
   1 accession_nbr_last = i4
   1 accession_nbr_prefix = vc
   1 accession_nbr_sig_dig = i4
   1 enroll_stratification_type_cd = f8
   1 enroll_stratification_type_disp = vc
   1 enroll_stratification_type_desc = vc
   1 enroll_stratification_type_mean = c12
   1 reviewers[*]
     2 reviewer_id = f8
     2 organization_id = f8
     2 org_name = vc
     2 reviewer_status_cd = f8
     2 reviewer_status_disp = c50
     2 reviewer_status_desc = c50
     2 reviewer_status_mean = c12
     2 reviewer_updt_cnt = i4
   1 prot_aliases[*]
     2 alias_id = f8
     2 alias = vc
     2 alias_type_cd = f8
     2 alias_type_disp = c50
     2 alias_type_desc = c50
     2 alias_type_mean = c12
     2 alias_pool_cd = f8
     2 alias_pool_disp = c50
     2 alias_pool_desc = c50
     2 alias_pool_mean = c12
     2 alias_format = c100
     2 alias_updt_cnt = i4
   1 eligible_alias_pools[*]
     2 alias_pool_cd = f8
     2 alias_pool_disp = c50
     2 alias_pool_desc = c50
     2 alias_pool_mean = c12
     2 alias_entity_type_cd = f8
     2 alias_entity_type_disp = c50
     2 alias_entity_type_desc = c50
     2 alias_entity_type_mean = c12
     2 format_mask = c100
     2 unique_ind = i2
   1 updt_cnt = i4
   1 display_ind = i2
   1 prsnl_roles[*]
     2 prot_role_id = f8
     2 prsnl_id = f8
     2 role_cd = f8
     2 role_disp = c50
     2 role_desc = c50
     2 role_mean = c12
     2 updt_cnt = i4
   1 highest_amd_id = f8
   1 sub_initiating_service_cd = f8
   1 sub_initiating_service_disp = c50
   1 sub_initiating_service_desc = c50
   1 sub_initiating_service_mean = c12
   1 sub_initiating_service_desc = vc
   1 sub_initiating_service_other_desc = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD role_request(
   1 prot_amendment_id = f8
 )
 RECORD role_reply(
   1 amendment_status_cd = f8
   1 amendment_status_disp = c50
   1 amendment_status_desc = c50
   1 amendment_status_mean = c12
   1 qual[*]
     2 prot_role_id = f8
     2 person_full_name = vc
     2 organization_id = f8
     2 org_name = vc
     2 person_id = f8
     2 prot_role_cd = f8
     2 prot_role_disp = c50
     2 prot_role_desc = c50
     2 prot_role_mean = c12
     2 prot_role_type_cd = f8
     2 prot_role_type_disp = c50
     2 prot_role_type_desc = c50
     2 prot_role_type_mean = c12
     2 position_cd = f8
     2 position_disp = c50
     2 position_desc = c50
     2 position_mean = c12
     2 primary_ind = i2
     2 updt_cnt = i4
   1 primary_contacts_list_ordered[*]
     2 prot_role_id = f8
     2 primary_contact_rank_nbr = i4
     2 contact_person_id = f8
     2 phone_num = vc
     2 pager_num = vc
     2 email_addr = vc
     2 organization_name = vc
     2 role_name = vc
     2 person_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE institutional_cd = f8 WITH protect, noconstant(0.0)
 DECLARE prot_alias_cd = f8 WITH protect, noconstant(0.0)
 DECLARE role_cnt = i2 WITH protect, noconstant(0)
 DECLARE personal_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17296,"PERSONAL"))
 DECLARE i = i2 WITH protect, noconstant(0)
 CALL echo("INIT OK")
 SELECT INTO "NL:"
  a.*
  FROM prot_master pm,
   organization o
  PLAN (pm
   WHERE (pm.prot_master_id=request->prot_master_id)
    AND pm.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (o
   WHERE (pm.collab_site_org_id= Outerjoin(o.organization_id)) )
  DETAIL
   reply->primary_mnemonic = pm.primary_mnemonic, reply->prot_purpose_cd = pm.prot_purpose_cd, reply
   ->program_cd = pm.program_cd,
   reply->prot_type_cd = pm.prot_type_cd, reply->prot_phase_cd = pm.prot_phase_cd, reply->
   prot_status_cd = pm.prot_status_cd,
   reply->initiating_service_cd = pm.initiating_service_cd, reply->sub_initiating_service_cd = pm
   .sub_initiating_service_cd, reply->initiating_service_desc = pm.initiating_service_desc,
   reply->prot_phase_cd = pm.prot_phase_cd, reply->accession_nbr_last = pm.accession_nbr_last, reply
   ->accession_nbr_prefix = pm.accession_nbr_prefix,
   reply->accession_nbr_sig_dig = pm.accession_nbr_sig_dig, reply->updt_cnt = pm.updt_cnt, reply->
   display_ind = pm.display_ind,
   reply->collab_site_org_id = pm.collab_site_org_id, reply->collab_site_org_name = o.org_name, reply
   ->parent_prot_master_id = pm.parent_prot_master_id
  WITH nocounter
 ;end select
 CALL echo(build("protMAsterID:",request->prot_master_id))
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF ((request->concept_amd_id > 0))
  SELECT INTO "nl:"
   pa.*
   FROM prot_amendment pa
   WHERE (pa.prot_amendment_id=request->concept_amd_id)
   DETAIL
    reply->prot_title = pa.prot_title,
    CALL echo(build("concept title -",reply->prot_title))
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_data.status = "Z"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
 SET pmid = request->prot_master_id
 SET highestamdnbr = 0
 SET highestamdid = 0
 EXECUTE ct_get_highest_a_nbr
 CALL echo(build("amd no-",highestamdid))
 SET reply->highest_amd_id = highestamdid
 SELECT INTO "nl:"
  pa.*
  FROM prot_amendment pa
  WHERE pa.prot_amendment_id=highestamdid
  DETAIL
   IF ((request->concept_amd_id=0))
    reply->prot_title = pa.prot_title
   ENDIF
   reply->enroll_stratification_type_cd = pa.enroll_stratification_type_cd, reply->
   participation_type_cd = pa.participation_type_cd,
   CALL echo(build("title2-",reply->prot_title))
  WITH nocounter
 ;end select
 CALL echo("before depts")
 CALL echo(build("title3-",reply->prot_title))
 SELECT INTO "nl:"
  d.*
  FROM contributing_dept d
  WHERE (d.prot_master_id=request->prot_master_id)
   AND d.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00")
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->contributing_depts,(cnt+ 9))
   ENDIF
   reply->contributing_depts[cnt].dept_cd = d.dept_cd, reply->contributing_depts[cnt].dept_other_desc
    = d.dept_desc, reply->contributing_depts[cnt].dept_id = d.contributing_dept_id,
   reply->contributing_depts[cnt].dept_updt_cnt = d.updt_cnt,
   CALL echo(d.dept_desc)
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->contributing_depts,cnt)
 CALL echo("before select- regulatory")
 SET cnt = 0
 SELECT INTO "nl:"
  p_r.*
  FROM prot_regulatory_req p_r
  WHERE (p_r.prot_master_id=request->prot_master_id)
   AND p_r.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00")
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->regulatory,(cnt+ 9))
   ENDIF
   reply->regulatory[cnt].reporting_type_cd = p_r.reg_reporting_type_cd, reply->regulatory[cnt].
   regulatory_id = p_r.prot_regulatory_req_id, reply->regulatory[cnt].updt_cnt = p_r.updt_cnt
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->regulatory,cnt)
 CALL echo("before select- reviewer")
 SET cnt = 0
 SELECT INTO "NL:"
  p_r.*
  FROM peer_reviewer p_r,
   organization o
  PLAN (p_r
   WHERE (p_r.prot_master_id=request->prot_master_id))
   JOIN (o
   WHERE p_r.organization_id=o.organization_id)
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    new = (cnt+ 10), stat = alterlist(reply->reviewers,new)
   ENDIF
   reply->reviewers[cnt].reviewer_id = p_r.peer_reviewer_id, reply->reviewers[cnt].reviewer_status_cd
    = p_r.peer_reviewer_status_cd, reply->reviewers[cnt].organization_id = p_r.organization_id,
   reply->reviewers[cnt].org_name = o.org_name, reply->reviewers[cnt].reviewer_updt_cnt = p_r
   .updt_cnt
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->reviewers,cnt)
 CALL echo("before select- aliases")
 SET cnt = 0
 SELECT INTO "nl:"
  d.*
  FROM prot_alias p,
   alias_pool a
  PLAN (p
   WHERE (p.prot_master_id=request->prot_master_id)
    AND p.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (a
   WHERE p.alias_pool_cd=a.alias_pool_cd)
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->prot_aliases,(cnt+ 9))
   ENDIF
   reply->prot_aliases[cnt].alias_id = p.prot_alias_id, reply->prot_aliases[cnt].alias = p.prot_alias,
   reply->prot_aliases[cnt].alias_pool_cd = a.alias_pool_cd,
   reply->prot_aliases[cnt].alias_format = a.format_mask, reply->prot_aliases[cnt].alias_type_cd = p
   .prot_alias_type_cd, reply->prot_aliases[cnt].alias_updt_cnt = p.updt_cnt,
   CALL echo(build("description:",p.prot_alias)),
   CALL echo(build("description:",a.description))
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->prot_aliases,cnt)
 CALL echo(build("cnt of aliases:",cnt))
 CALL echo("before select- eligible alias pools")
 SET cnt = 0
 SET stat = uar_get_meaning_by_codeset(17296,"INSTITUTION",1,institutional_cd)
 SELECT DISTINCT INTO "nl:"
  p.alias_pool_cd
  FROM alias_pool p,
   prot_role r,
   org_alias_pool_reltn oar,
   code_value v
  PLAN (r
   WHERE r.prot_amendment_id=highestamdid
    AND r.prot_role_type_cd=institutional_cd
    AND r.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (oar
   WHERE oar.organization_id=r.organization_id
    AND oar.active_ind=1
    AND oar.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (v
   WHERE oar.alias_entity_alias_type_cd=v.code_value
    AND v.code_set=12801)
   JOIN (p
   WHERE oar.alias_pool_cd=p.alias_pool_cd
    AND p.active_ind=1
    AND p.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00"))
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->eligible_alias_pools,(cnt+ 9))
   ENDIF
   reply->eligible_alias_pools[cnt].alias_pool_cd = p.alias_pool_cd, reply->eligible_alias_pools[cnt]
   .format_mask = p.format_mask, reply->eligible_alias_pools[cnt].unique_ind = p.unique_ind,
   reply->eligible_alias_pools[cnt].alias_entity_type_cd = oar.alias_entity_alias_type_cd,
   CALL echo(build("description:",p.description)),
   CALL echo(build("unique_ind:",reply->eligible_alias_pools[cnt].unique_ind))
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->eligible_alias_pools,cnt)
 CALL echo(build("cnt of elig pools:",cnt))
 CALL echo(build("return status:",reply->status_data.status))
 SET role_request->prot_amendment_id = highestamdid
 EXECUTE ct_get_prot_role  WITH replace("REQUEST","ROLE_REQUEST"), replace("REPLY","ROLE_REPLY")
 SET role_cnt = size(role_reply->qual,5)
 SET stat = alterlist(reply->prsnl_roles,role_cnt)
 FOR (i = 1 TO role_cnt)
   SET reply->prsnl_roles[i].prot_role_id = role_reply->qual[i].prot_role_id
   SET reply->prsnl_roles[i].prsnl_id = role_reply->qual[i].person_id
   SET reply->prsnl_roles[i].role_cd = role_reply->qual[i].prot_role_cd
   SET reply->prsnl_roles[i].role_disp = role_reply->qual[i].prot_role_disp
   SET reply->prsnl_roles[i].role_desc = role_reply->qual[i].prot_role_desc
   SET reply->prsnl_roles[i].role_mean = role_reply->qual[i].prot_role_mean
   SET reply->prsnl_roles[i].updt_cnt = role_reply->qual[i].updt_cnt
 ENDFOR
 SET last_mod = "008"
 SET mod_date = "September 02, 2022"
END GO
