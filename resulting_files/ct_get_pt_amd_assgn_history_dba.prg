CREATE PROGRAM ct_get_pt_amd_assgn_history:dba
 RECORD reply(
   1 qual_one[*]
     2 prot_id = f8
     2 primary_mnemonic = vc
     2 therapeutic_ind = i2
     2 qual_two[*]
       3 reg_id = f8
       3 patient_identifier = vc
       3 on_study_dt_tm = dq8
       3 off_study_dt_tm = dq8
       3 off_treatment_dt_tm = dq8
       3 episode_id = f8
       3 qual_three[*]
         4 prot_title = vc
         4 amendment_id = f8
         4 amendment_nbr = i2
         4 assign_start_dt_tm = dq8
         4 assign_end_dt_tm = dq8
         4 filename = vc
         4 revision_ind = i2
         4 revision_nbr_txt = vc
         4 data_capture_ind = i2
         4 displayable_docs_ind = i2
         4 participation_type_cd = f8
         4 participation_type_disp = vc
         4 participation_type_desc = vc
         4 participation_type_mean = c12
         4 stratum_label = c100
         4 cohort_label = c30
     2 prot_amendment_id = f8
     2 prot_master_id = f8
     2 contact_person_id = f8
     2 prot_role_id = f8
     2 person_name = vc
     2 role_name = vc
     2 organization_name = vc
     2 phone_num = vc
     2 pager_num = vc
     2 email_addr = vc
     2 primary_contacts_info[*]
       3 prot_id = f8
       3 contact_person_id = f8
       3 prot_role_id = f8
       3 person_name = vc
       3 role_name = vc
       3 organization_name = vc
       3 phone_num = vc
       3 pager_num = vc
       3 email_addr = vc
     2 program_cd = f8
     2 program_disp = vc
     2 program_desc = vc
     2 program_mean = c12
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp_contact_request(
   1 protocols[*]
     2 prot_master_id = f8
     2 prot_amendment_id = f8
   1 person_id = f8
 )
 RECORD temp_contact_reply(
   1 contact_info[*]
     2 prot_amendment_id = f8
     2 prot_master_id = f8
     2 person_id = f8
     2 prot_role_id = f8
     2 person_name = vc
     2 role_name = vc
     2 organization_name = vc
     2 phone_num = vc
     2 pager_num = vc
     2 email_addr = vc
     2 alphapager = vc
   1 primary_contacts[*]
     2 primary_contact_info[*]
       3 prot_amendment_id = f8
       3 prot_master_id = f8
       3 person_id = f8
       3 prot_role_id = f8
       3 person_name = vc
       3 role_name = vc
       3 organization_name = vc
       3 phone_num = vc
       3 pager_num = vc
       3 email_addr = vc
       3 alphapager = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD user_org_reply(
   1 organizations[*]
     2 organization_id = f8
     2 confid_cd = f8
     2 confid_level = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE userorgsize = i2 WITH protect, noconstant(0)
 DECLARE orgidx = i2 WITH protect, noconstant(0)
 DECLARE orgstr = vc WITH protect
 SUBROUTINE (builduserorglist(tablestr=vc) =vc)
   EXECUTE ct_get_user_orgs  WITH replace("REPLY","USER_ORG_REPLY")
   SET userorgsize = size(user_org_reply->organizations,5)
   IF (userorgsize > 0)
    SET orgstr = build("expand(orgIdx, 1, userOrgSize, ",tablestr,
     ", user_org_reply->organizations[orgIdx]->organization_id)")
   ELSE
    SET orgstr = "1=1"
   ENDIF
   RETURN(orgstr)
 END ;Subroutine
 DECLARE cntr1 = i2 WITH protect, noconstant(0)
 DECLARE cntr2 = i2 WITH protect, noconstant(0)
 DECLARE cntr3 = i2 WITH protect, noconstant(0)
 DECLARE contact_cnt = i2 WITH protect, noconstant(0)
 DECLARE i = i2 WITH protect, noconstant(0)
 DECLARE j = i2 WITH protect, noconstant(0)
 DECLARE entity_alias = f8 WITH protect, noconstant(0.0)
 DECLARE failed = c1 WITH protect, noconstant("F")
 DECLARE whrdisplay = vc WITH protect, noconstant(fillstring(240," "))
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE userorgstr = vc WITH protect
 DECLARE registry_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17906,"REGISTRY"))
 DECLARE yes_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17907,"YES"))
 IF ((request->show_all_ind=0))
  SET whrdisplay = "pm.display_ind = 1"
 ELSE
  SET whrdisplay = "1=1"
 ENDIF
 IF ((request->org_security_ind=1))
  SET userorgstr = builduserorglist("ppr.enrolling_organization_id")
 ELSE
  SET userorgstr = "1=1"
 ENDIF
 CALL echo(userorgstr)
 SET stat = uar_get_meaning_by_codeset(4,"MRN",1,entity_alias)
 IF ((request->person_id=0.0))
  SELECT INTO "nl:"
   FROM org_alias_pool_reltn oapr,
    person_alias pa
   PLAN (oapr
    WHERE (oapr.organization_id=request->org_id)
     AND oapr.alias_entity_alias_type_cd=entity_alias
     AND oapr.active_ind=1
     AND oapr.end_effective_dt_tm >= cnvtdatetime("31-dec-2100 00:00:00.00"))
    JOIN (pa
    WHERE pa.alias_pool_cd=oapr.alias_pool_cd
     AND (pa.alias=request->mrn))
   DETAIL
    request->person_id = pa.person_id
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  ppr.prot_master_id, pm.primary_mnemonic, ppr.reg_id,
  ppr.on_study_dt_tm, ppr.off_study_dt_tm, caa.prot_amendment_id,
  caa.assign_start_dt_tm, caa.assign_end_dt_tm, pa.prot_title,
  pa.amendment_nbr, pm.program_cd
  FROM pt_prot_reg ppr,
   prot_master pm,
   ct_pt_amd_assignment caa,
   prot_amendment pa,
   assign_reg_reltn arr,
   prot_cohort pc,
   prot_stratum ps,
   ct_document cd,
   ct_document_version cdv,
   dummyt d,
   dummyt d3,
   ct_prot_type_config cfg
  PLAN (ppr
   WHERE (ppr.person_id=request->person_id)
    AND parser(userorgstr)
    AND ppr.end_effective_dt_tm >= cnvtdatetime("31-dec-2100 00:00:00.00"))
   JOIN (pm
   WHERE ppr.prot_master_id=pm.prot_master_id
    AND pm.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND parser(whrdisplay))
   JOIN (caa
   WHERE ppr.reg_id=caa.reg_id
    AND caa.end_effective_dt_tm >= cnvtdatetime("31-dec-2100 00:00:00.00"))
   JOIN (pa
   WHERE caa.prot_amendment_id=pa.prot_amendment_id)
   JOIN (cfg
   WHERE cfg.protocol_type_cd=pa.participation_type_cd
    AND cfg.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND cfg.item_cd=registry_cd
    AND (((request->view_mode=0)) OR ((((request->view_mode=1)
    AND cfg.config_value_cd != yes_cd) OR ((request->view_mode=2)
    AND cfg.config_value_cd=yes_cd)) )) )
   JOIN (d3)
   JOIN (arr
   WHERE arr.reg_id=ppr.reg_id
    AND arr.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (pc
   WHERE pc.cohort_id=arr.cohort_id
    AND pc.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (ps
   WHERE ps.stratum_id=pc.stratum_id
    AND ps.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (d)
   JOIN (cd
   WHERE (cd.prot_amendment_id= Outerjoin(caa.prot_amendment_id))
    AND (cd.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
   JOIN (cdv
   WHERE (cdv.ct_document_id= Outerjoin(cd.ct_document_id))
    AND (cdv.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate)))
    AND (cdv.display_ind= Outerjoin(1)) )
  ORDER BY ppr.prot_master_id, ppr.reg_id, pa.amendment_nbr,
   pa.revision_seq
  HEAD ppr.prot_master_id
   cntr1 += 1
   IF (mod(cntr1,10)=1)
    stat = alterlist(reply->qual_one,(cntr1+ 9))
   ENDIF
   reply->qual_one[cntr1].prot_id = ppr.prot_master_id, reply->qual_one[cntr1].primary_mnemonic = pm
   .primary_mnemonic, reply->qual_one[cntr1].program_cd = pm.program_cd,
   reply->qual_one[cntr1].program_desc = uar_get_code_description(pm.program_cd), reply->qual_one[
   cntr1].program_disp = uar_get_code_display(pm.program_cd), reply->qual_one[cntr1].program_mean =
   uar_get_code_meaning(pm.program_cd)
   IF (uar_get_code_meaning(pm.prot_type_cd)="THERAPEUTIC")
    reply->qual_one[cntr1].therapeutic_ind = 1
   ELSE
    reply->qual_one[cntr1].therapeutic_ind = 0
   ENDIF
   contact_cnt += 1
   IF (mod(contact_cnt,10)=1)
    stat = alterlist(temp_contact_request->protocols,(contact_cnt+ 9))
   ENDIF
   temp_contact_request->protocols[contact_cnt].prot_master_id = ppr.prot_master_id, cntr2 = 0
  HEAD ppr.reg_id
   cntr2 += 1
   IF (mod(cntr2,10)=1)
    stat = alterlist(reply->qual_one[cntr1].qual_two,(cntr2+ 9))
   ENDIF
   reply->qual_one[cntr1].qual_two[cntr2].reg_id = ppr.reg_id, reply->qual_one[cntr1].qual_two[cntr2]
   .on_study_dt_tm = ppr.on_study_dt_tm, reply->qual_one[cntr1].qual_two[cntr2].off_study_dt_tm = ppr
   .off_study_dt_tm,
   reply->qual_one[cntr1].qual_two[cntr2].off_treatment_dt_tm = ppr.tx_completion_dt_tm, reply->
   qual_one[cntr1].qual_two[cntr2].patient_identifier = ppr.prot_accession_nbr, reply->qual_one[cntr1
   ].qual_two[cntr2].episode_id = ppr.episode_id,
   cntr3 = 0
  HEAD caa.prot_amendment_id
   cntr3 += 1
   IF (mod(cntr3,10)=1)
    stat = alterlist(reply->qual_one[cntr1].qual_two[cntr2].qual_three,(cntr3+ 9))
   ENDIF
   reply->qual_one[cntr1].qual_two[cntr2].qual_three[cntr3].prot_title = pa.prot_title, reply->
   qual_one[cntr1].qual_two[cntr2].qual_three[cntr3].amendment_id = caa.prot_amendment_id, reply->
   qual_one[cntr1].qual_two[cntr2].qual_three[cntr3].amendment_nbr = pa.amendment_nbr,
   reply->qual_one[cntr1].qual_two[cntr2].qual_three[cntr3].assign_start_dt_tm = caa
   .assign_start_dt_tm, reply->qual_one[cntr1].qual_two[cntr2].qual_three[cntr3].assign_end_dt_tm =
   caa.assign_end_dt_tm, reply->qual_one[cntr1].qual_two[cntr2].qual_three[cntr3].revision_ind = pa
   .revision_ind,
   reply->qual_one[cntr1].qual_two[cntr2].qual_three[cntr3].revision_nbr_txt = pa.revision_nbr_txt,
   reply->qual_one[cntr1].qual_two[cntr2].qual_three[cntr3].data_capture_ind = pa.data_capture_ind,
   reply->qual_one[cntr1].qual_two[cntr2].qual_three[cntr3].participation_type_cd = pa
   .participation_type_cd,
   reply->qual_one[cntr1].qual_two[cntr2].qual_three[cntr3].stratum_label = ps.stratum_label
   IF (uar_get_code_meaning(ps.stratum_cohort_type_cd)="DEFAULT")
    reply->qual_one[cntr1].qual_two[cntr2].qual_three[cntr3].cohort_label = ""
   ELSE
    reply->qual_one[cntr1].qual_two[cntr2].qual_three[cntr3].cohort_label = pc.cohort_label
   ENDIF
   reply->qual_one[cntr1].prot_amendment_id = caa.prot_amendment_id
  DETAIL
   IF (cdv.display_ind=1)
    reply->qual_one[cntr1].qual_two[cntr2].qual_three[cntr3].displayable_docs_ind = 1
   ENDIF
  FOOT  ppr.reg_id
   stat = alterlist(reply->qual_one[cntr1].qual_two[cntr2].qual_three,cntr3), j += cntr3
  FOOT  ppr.prot_master_id
   stat = alterlist(reply->qual_one[cntr1].qual_two,cntr2), i += cntr2
  FOOT REPORT
   stat = alterlist(reply->qual_one,cntr1), stat = alterlist(temp_contact_request->protocols,
    contact_cnt)
  WITH nocounter, dontcare = cd, outerjoin = d3,
   dontcare = arr, dontcare = pc, dontcare = ps
 ;end select
 CALL echo(build("cntr1 of prot_master_id's = ",cntr1))
 CALL echo(build("cntr2 of reg_id's = ",i))
 CALL echo(build("cntr3 is total rows = ",j))
 IF (curqual < 1)
  SET failed = "Z"
  CALL echo(build("no amd history for patient"))
  GO TO exit_script
 ENDIF
 EXECUTE ct_get_contact_info  WITH replace("REQUEST","TEMP_CONTACT_REQUEST"), replace("REPLY",
  "TEMP_CONTACT_REPLY")
 CALL echorecord(temp_contact_reply)
 FOR (indx = 1 TO cntr1)
   SET contact_size = size(temp_contact_reply->primary_contacts[indx].primary_contact_info,5)
   SET stat = alterlist(reply->qual_one[indx].primary_contacts_info,contact_size)
   IF (contact_size > 0)
    FOR (contact_idx = 1 TO contact_size)
      IF ((reply->qual_one[indx].prot_id=temp_contact_reply->primary_contacts[indx].
      primary_contact_info[contact_idx].prot_master_id))
       SET reply->qual_one[indx].primary_contacts_info[contact_idx].prot_id = temp_contact_reply->
       primary_contacts[indx].primary_contact_info[contact_idx].prot_master_id
       SET reply->qual_one[indx].primary_contacts_info[contact_idx].contact_person_id =
       temp_contact_reply->primary_contacts[indx].primary_contact_info[contact_idx].person_id
       SET reply->qual_one[indx].primary_contacts_info[contact_idx].person_name = temp_contact_reply
       ->primary_contacts[indx].primary_contact_info[contact_idx].person_name
       SET reply->qual_one[indx].primary_contacts_info[contact_idx].role_name = temp_contact_reply->
       primary_contacts[indx].primary_contact_info[contact_idx].role_name
       SET reply->qual_one[indx].primary_contacts_info[contact_idx].organization_name =
       temp_contact_reply->primary_contacts[indx].primary_contact_info[contact_idx].organization_name
       SET reply->qual_one[indx].primary_contacts_info[contact_idx].phone_num = temp_contact_reply->
       primary_contacts[indx].primary_contact_info[contact_idx].phone_num
       SET reply->qual_one[indx].primary_contacts_info[contact_idx].pager_num = temp_contact_reply->
       primary_contacts[indx].primary_contact_info[contact_idx].pager_num
       SET reply->qual_one[indx].primary_contacts_info[contact_idx].email_addr = temp_contact_reply->
       primary_contacts[indx].primary_contact_info[contact_idx].email_addr
       SET reply->qual_one[indx].primary_contacts_info[contact_idx].prot_role_id = temp_contact_reply
       ->primary_contacts[indx].primary_contact_info[contact_idx].prot_role_id
      ENDIF
    ENDFOR
    IF ((reply->qual_one[indx].prot_id=temp_contact_reply->primary_contacts[indx].
    primary_contact_info[1].prot_master_id))
     SET reply->qual_one[indx].contact_person_id = temp_contact_reply->primary_contacts[indx].
     primary_contact_info[1].person_id
     SET reply->qual_one[indx].person_name = temp_contact_reply->primary_contacts[indx].
     primary_contact_info[1].person_name
     SET reply->qual_one[indx].role_name = temp_contact_reply->primary_contacts[indx].
     primary_contact_info[1].role_name
     SET reply->qual_one[indx].organization_name = temp_contact_reply->primary_contacts[indx].
     primary_contact_info[1].organization_name
     SET reply->qual_one[indx].phone_num = temp_contact_reply->primary_contacts[indx].
     primary_contact_info[1].phone_num
     SET reply->qual_one[indx].pager_num = temp_contact_reply->primary_contacts[indx].
     primary_contact_info[1].pager_num
     SET reply->qual_one[indx].email_addr = temp_contact_reply->primary_contacts[indx].
     primary_contact_info[1].email_addr
     SET reply->qual_one[indx].prot_role_id = temp_contact_reply->primary_contacts[indx].
     primary_contact_info[1].prot_role_id
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF (failed="Z")
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "Z"
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
 SET last_mod = "019"
 SET mod_date = "Jan 29, 2016"
 CALL echo(build("Status:",reply->status_data.status))
END GO
