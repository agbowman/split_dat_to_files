CREATE PROGRAM ct_add_protocol:dba
 RECORD reply(
   1 prot_master_id = f8
   1 amd_id = f8
   1 debug = vc
   1 debugid = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD req_access_list(
   1 person_list[*]
     2 person_id = f8
     2 prot_amendment_id = f8
     2 action_ind = i2
 )
 RECORD reply_access(
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
 DECLARE master_id = f8 WITH protect, noconstant(0.0)
 DECLARE primary_id = f8 WITH protect, noconstant(0.0)
 DECLARE amendment_id = f8 WITH protect, noconstant(0.0)
 DECLARE prot_purpose_cd = f8 WITH protect, noconstant(0.0)
 DECLARE prot_status_cd = f8 WITH protect, noconstant(0.0)
 DECLARE peer_review_indicator_cd = f8 WITH protect, noconstant(0.0)
 DECLARE accrual_required_indc_cd = f8 WITH protect, noconstant(0.0)
 DECLARE anticipated_prot_dur_uom_cd = f8 WITH protect, noconstant(0.0)
 DECLARE creator_cd = f8 WITH protect, noconstant(0.0)
 DECLARE pr_role_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE prot_master_id = f8 WITH public, noconstant(0.0)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE pi_id = f8 WITH protect, noconstant(0.0)
 DECLARE role_cnt = i4 WITH protect, noconstant(0)
 DECLARE lp_cnt = f8 WITH protect, noconstant(0.0)
 DECLARE prsnl_cnt = i2 WITH protect, noconstant(0)
 DECLARE i = i2 WITH protect, noconstant(0)
 DECLARE prescreen_type = i2 WITH protect, noconstant(1)
 SET reply->status_data.status = "F"
 SET reply->debug = "INIT"
 SET failed = "F"
 SELECT INTO "NL:"
  pm.*
  FROM prot_master pm
  WHERE (pm.primary_mnemonic_key=request->primary_mnemonic_key)
   AND pm.end_effective_dt_tm > cnvtdatetime(sysdate)
   AND (pm.logical_domain_id=domain_reply->logical_domain_id)
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "M"
  SET reply->debug = "MNEM"
  GO TO endgo
 ENDIF
 IF ((request->collab_site_org_id > 0))
  SELECT INTO "NL:"
   pm.*
   FROM prot_master pm
   WHERE (pm.parent_prot_master_id=request->parent_prot_master_id)
    AND (pm.collab_site_org_id=request->collab_site_org_id)
    AND pm.end_effective_dt_tm > cnvtdatetime(sysdate)
  ;end select
  IF (curqual != 0)
   SET reply->status_data.status = "C"
   SET reply->debug = "COLLAB"
   GO TO endgo
  ENDIF
  SELECT INTO "NL:"
   FROM prot_master pm
   WHERE (pm.prot_master_id=request->parent_prot_master_id)
    AND pm.end_effective_dt_tm > cnvtdatetime(sysdate)
   DETAIL
    prescreen_type = pm.prescreen_type_flag
   WITH nocounter
  ;end select
 ENDIF
 SET stat = uar_get_meaning_by_codeset(17277,"UDEFINED",1,peer_review_indicator_cd)
 SET stat = uar_get_meaning_by_codeset(17276,"UDEFINED",1,prot_purpose_cd)
 IF ((request->concept_ind=1))
  SET stat = uar_get_meaning_by_codeset(17274,"CONCEPT",1,prot_status_cd)
 ELSE
  SET stat = uar_get_meaning_by_codeset(17274,"INDVLPMENT",1,prot_status_cd)
 ENDIF
 IF (prot_status_cd <= 0.0)
  SET reply->status_data.status = "F"
  SET reply->debug = "STATUS"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "protocol status CDF not set"
  GO TO endgo
 ENDIF
 SELECT INTO "nl:"
  num = seq(protocol_def_seq,nextval)
  FROM dual
  DETAIL
   master_id = num
  WITH format, counter
 ;end select
 SET reply->debugid = master_id
 CALL echo("before master")
 INSERT  FROM prot_master pm
  SET pm.prot_master_id = master_id, pm.initiating_service_cd = request->initiating_service_cd, pm
   .initiating_service_desc = request->initiating_service_desc,
   pm.peer_review_indicator_cd = peer_review_indicator_cd, pm.program_cd = request->program_cd, pm
   .prot_master_id = master_id,
   pm.prot_phase_cd = request->prot_phase_cd, pm.prot_purpose_cd = prot_purpose_cd, pm.prot_status_cd
    = prot_status_cd,
   pm.prot_type_cd = request->prot_type_cd, pm.primary_mnemonic = request->primary_mnemonic, pm
   .primary_mnemonic_key = request->primary_mnemonic_key,
   pm.accession_nbr_last = request->accession_nbr_last, pm.accession_nbr_prefix = request->
   accession_nbr_prefix, pm.accession_nbr_sig_dig = request->accession_nbr_sig_dig,
   pm.prescreen_type_flag = prescreen_type, pm.updt_dt_tm = cnvtdatetime(sysdate), pm.updt_id =
   reqinfo->updt_id,
   pm.updt_applctx = reqinfo->updt_applctx, pm.updt_task = reqinfo->updt_task, pm.updt_cnt = 0,
   pm.display_ind = request->display_ind, pm.parent_prot_master_id =
   IF ((request->parent_prot_master_id=0)) master_id
   ELSE request->parent_prot_master_id
   ENDIF
   , pm.collab_site_org_id = request->collab_site_org_id,
   pm.prev_prot_master_id = master_id, pm.beg_effective_dt_tm = cnvtdatetime(sysdate), pm
   .end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"),
   pm.screener_ind = request->screener_ind, pm.network_flag = request->network_flag, pm
   .sub_initiating_service_cd = request->sub_initiating_service_cd,
   pm.logical_domain_id = domain_reply->logical_domain_id
  WITH nocounter
 ;end insert
 CALL echo("after insert master")
 IF (curqual=0)
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "P"
  SET reply->debug = "MASTER"
  GO TO endgo
 ENDIF
 CALL echo("before depts")
 SET num_to_add = size(request->contributing_depts,5)
 FOR (i = 1 TO num_to_add)
  INSERT  FROM contributing_dept d
   SET d.contributing_dept_id = seq(protocol_def_seq,nextval), d.prot_master_id = master_id, d
    .dept_cd = request->contributing_depts[i].dept_cd,
    d.dept_desc = request->contributing_depts[i].dept_desc, d.beg_effective_dt_tm = cnvtdatetime(
     sysdate), d.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"),
    d.updt_dt_tm = cnvtdatetime(sysdate), d.updt_id = reqinfo->updt_id, d.updt_applctx = reqinfo->
    updt_applctx,
    d.updt_task = reqinfo->updt_task, d.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET reqinfo->commit_ind = 0
   SET reply->status_data.status = "F"
   SET reply->debug = "DEPTS"
   CALL echo("DEPTS FAILED")
   GO TO endgo
  ENDIF
 ENDFOR
 CALL echo("before regulatory")
 SET num_to_add = size(request->regulatory,5)
 FOR (i = 1 TO num_to_add)
  INSERT  FROM prot_regulatory_req p_r
   SET p_r.prot_regulatory_req_id = seq(protocol_def_seq,nextval), p_r.regulatory_req_id = seq(
     protocol_def_seq,currval), p_r.prot_master_id = master_id,
    p_r.reg_reporting_type_cd = request->regulatory[i].reg_reporting_cd, p_r.beg_effective_dt_tm =
    cnvtdatetime(sysdate), p_r.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"),
    p_r.updt_dt_tm = cnvtdatetime(sysdate), p_r.updt_id = reqinfo->updt_id, p_r.updt_applctx =
    reqinfo->updt_applctx,
    p_r.updt_task = reqinfo->updt_task, p_r.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET reqinfo->commit_ind = 0
   SET reply->status_data.status = "F"
   SET reply->debug = "REGULATORY"
   CALL echo("REGULATORY FAILED")
   GO TO endgo
  ENDIF
 ENDFOR
 IF ((request->concept_ind=1))
  SET primary_id = 0.0
  SET stat = uar_get_meaning_by_codeset(17278,"UNDEFINED",1,anticipated_prot_dur_uom_cd)
  SET stat = uar_get_meaning_by_codeset(17438,"UNDEFINED",1,accrual_required_indc_cd)
  SELECT INTO "nl:"
   num = seq(protocol_def_seq,nextval)
   FROM dual
   DETAIL
    amendment_id = num, reply->amd_id = amendment_id
   WITH format, counter
  ;end select
  CALL echo("before amend")
  INSERT  FROM prot_amendment pa
   SET pa.prot_amendment_id = amendment_id, pa.accrual_required_indc_cd = accrual_required_indc_cd,
    pa.enroll_stratification_type_cd = request->enroll_stratification_type_cd,
    pa.amendment_dt_tm = cnvtdatetime("31-dec-2100 00:00:00"), pa.amendment_nbr = - (1), pa
    .anticipated_prot_dur_value = 0.0,
    pa.anticipated_prot_dur_uom_cd = anticipated_prot_dur_uom_cd, pa.prot_master_id = master_id, pa
    .prot_title = request->prot_title,
    pa.amendment_status_cd = prot_status_cd, pa.participation_type_cd = request->
    participation_type_cd, pa.updt_dt_tm = cnvtdatetime(sysdate),
    pa.updt_id = reqinfo->updt_id, pa.updt_applctx = reqinfo->updt_applctx, pa.updt_task = reqinfo->
    updt_task,
    pa.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET reqinfo->commit_ind = 0
   SET reply->debug = "AMEND"
   SET reply->status_data.status = "F"
   GO TO endgo
  ENDIF
  SET stat = uar_get_meaning_by_codeset(17441,"CREATOR",1,creator_cd)
  SET stat = uar_get_meaning_by_codeset(17296,"PERSONAL",1,pr_role_type_cd)
  INSERT  FROM prot_role ro
   SET ro.prot_role_id = seq(protocol_def_seq,nextval), ro.prot_amendment_id = amendment_id, ro
    .prot_role_type_cd = pr_role_type_cd,
    ro.person_id = reqinfo->updt_id, ro.prot_role_cd = creator_cd, ro.beg_effective_dt_tm =
    cnvtdatetime(sysdate),
    ro.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"), ro.updt_dt_tm = cnvtdatetime(
     sysdate), ro.updt_id = reqinfo->updt_id,
    ro.updt_applctx = reqinfo->updt_applctx, ro.updt_task = reqinfo->updt_task, ro.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET reqinfo->commit_ind = 0
   SET reply->status_data.status = "F"
   SET reply->debug = "ROLE"
   CALL echo("CREATOR ROLE FAILED")
   GO TO endgo
  ENDIF
  SET role_cnt = size(request->roles,5)
  IF (role_cnt > 0)
   SET stat = alterlist(req_access_list->person_list,role_cnt)
   FOR (i = 1 TO role_cnt)
     INSERT  FROM prot_role ro
      SET ro.prot_role_id = seq(protocol_def_seq,nextval), ro.prot_amendment_id = amendment_id, ro
       .prot_role_type_cd = pr_role_type_cd,
       ro.person_id = request->roles[i].prsnl_id, ro.prot_role_cd = request->roles[i].role_cd, ro
       .beg_effective_dt_tm = cnvtdatetime(sysdate),
       ro.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"), ro.updt_dt_tm = cnvtdatetime
       (sysdate), ro.updt_id = reqinfo->updt_id,
       ro.updt_applctx = reqinfo->updt_applctx, ro.updt_task = reqinfo->updt_task, ro.updt_cnt = 0
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET reqinfo->commit_ind = 0
      SET reply->status_data.status = "F"
      SET reply->debug = "ROLE"
      CALL echo("ROLE FAILED")
      GO TO endgo
     ENDIF
     IF ((request->screener_ind=1))
      SET req_access_list->person_list[i].person_id = request->roles[i].prsnl_id
      SET req_access_list->person_list[i].prot_amendment_id = amendment_id
      SET req_access_list->person_list[i].action_ind = 1
     ENDIF
   ENDFOR
   IF ((request->screener_ind=1))
    EXECUTE ct_chg_screener_access  WITH replace("REQUEST","REQ_ACCESS_LIST"), replace("REPLY",
     "REPLY_ACCESS")
    IF ((reply_access->status_data.status != "S"))
     SET reqinfo->commit_ind = 0
     SET reply->status_data.status = "F"
     SET reply->debug = "ENTITY_ACCESS"
     CALL echo("Adding entity access failed.")
     GO TO endgo
    ENDIF
   ENDIF
  ENDIF
 ELSE
  SET prot_master_id = master_id
  EXECUTE ct_add_peer_reviewer
  EXECUTE ct_add_prot_alias
 ENDIF
 SET reqinfo->commit_ind = 1
 SET reply->prot_master_id = master_id
 SET reply->status_data.status = "S"
 SET last_mod = "010"
 SET mod_date = "July 30, 2019"
#endgo
 CALL echo(build("status:",reply->status_data.status))
END GO
