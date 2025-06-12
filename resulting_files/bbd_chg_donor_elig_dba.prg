CREATE PROGRAM bbd_chg_donor_elig:dba
 RECORD reply(
   1 encounter_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c15
       3 sourceobjectqual = i4
       3 sourceobjectvalue = c50
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c50
       3 sub_event_dt_tm = di8
 )
 SET modify = predeclare
 DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
 DECLARE new_encntr_nbr = f8 WITH protect, noconstant(0.0)
 DECLARE new_encntr_person_reltn_id = f8 WITH protect, noconstant(0.0)
 DECLARE new_contact_id = f8 WITH protect, noconstant(0.0)
 SET reply->status_data.status = "F"
 DECLARE failed = c1 WITH protect, noconstant("F")
 DECLARE error_count = i4 WITH protect, noconstant(0)
 DECLARE bbd_contact_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE contact_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE contributor_system = f8 WITH protect, noconstant(0.0)
 DECLARE data_status = i4 WITH protect, noconstant(0)
 DECLARE person_reltn_type_code = f8 WITH protect, noconstant(0.0)
 DECLARE codevalue = f8 WITH protect, noconstant(0.0)
 DECLARE encntr_status_code = f8 WITH protect, noconstant(0.0)
 DECLARE encntr_type_class_code = f8 WITH protect, noconstant(0.0)
 DECLARE encntr_type_code = f8 WITH protect, noconstant(0.0)
 DECLARE contact_status_code = f8 WITH protect, noconstant(0.0)
 DECLARE genetic = i4 WITH protect, noconstant(0)
 DECLARE nbr_of_exceptions = i4 WITH protect, noconstant(size(request->qual,5))
 DECLARE cdf_meaning = c12 WITH protect, noconstant(fillstring(12," "))
 DECLARE counter = i4 WITH protect, noconstant(0)
 DECLARE exception_status = c1 WITH protect, noconstant("I")
 DECLARE bb_exception_id = f8 WITH protect, noconstant(0.0)
 DECLARE successful_action = c1 WITH protect, noconstant("I")
 DECLARE code_value = f8 WITH protect, noconstant(0.0)
 DECLARE code_meaning = vc WITH protect, noconstant("DONATE")
 DECLARE code_set = i4 WITH protect, noconstant(14220)
 DECLARE code_cnt = i4 WITH protect, noconstant(1)
 DECLARE stat = i4 WITH protect, noconstant(0)
 SET stat = uar_get_meaning_by_codeset(14220,"DONATE",code_cnt,bbd_contact_type_cd)
 IF (bbd_contact_type_cd=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donor_elig"
  SET reply->status_data.subeventstatus[1].operationname = "retrieve"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "uar_get__meaning_by_codeset"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "unable to retrieve code value for 14420 and DONATE"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
  GO TO exit_script
 ENDIF
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(69,"BLOODDONOR",code_cnt,encntr_type_class_code)
 IF (encntr_type_class_code=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donor_elig"
  SET reply->status_data.subeventstatus[1].operationname = "retrieve"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "uar_get__meaning_by_codeset"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "unable to retrieve code value for 69 and BLOODDONOR"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  c.child_code_value
  FROM code_value_group c
  WHERE c.parent_code_value=encntr_type_class_code
  DETAIL
   encntr_type_code = c.child_code_value
  WITH nocounter
 ;end select
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(89,"CERNER",code_cnt,contributor_system)
 IF (contributor_system=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donor_elig"
  SET reply->status_data.subeventstatus[1].operationname = "retrieve"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "uar_get__meaning_by_codeset"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "unable to retrieve code value for 89 and CERNER"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
  GO TO exit_script
 ENDIF
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(8,"AUTH",code_cnt,contact_type_cd)
 IF (contact_type_cd=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donor_elig"
  SET reply->status_data.subeventstatus[1].operationname = "retrieve"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "uar_get__meaning_by_codeset"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "unable to retrieve code value for 8 and AUTH"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
  GO TO exit_script
 ENDIF
 SET code_set = 351
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(351,"BBRECIPIENT",code_cnt,person_reltn_type_code)
 IF (person_reltn_type_code=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donor_elig"
  SET reply->status_data.subeventstatus[1].operationname = "retrieve"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "uar_get__meaning_by_codeset"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "unable to retrieve code value for 351 and BBRECIPIENT"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
  GO TO exit_script
 ENDIF
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(261,"ACTIVE",code_cnt,encntr_status_code)
 IF (encntr_status_code=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donor_elig"
  SET reply->status_data.subeventstatus[1].operationname = "retrieve"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "uar_get__meaning_by_codeset"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "unable to retrieve code value for 261 and ACTIVE"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
  GO TO exit_script
 ENDIF
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(14224,"PENDING",code_cnt,contact_status_code)
 IF (contact_status_code=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donor_elig"
  SET reply->status_data.subeventstatus[1].operationname = "retrieve"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "uar_get__meaning_by_codeset"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "unable to retrieve code value for 14224 and PENDING"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_value c
  WHERE c.code_set=40
   AND (c.code_value=request->relation_cd)
  DETAIL
   IF (c.cdf_meaning="GENETIC")
    genetic = 1
   ELSE
    genetic = 0
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  seqn = seq(encounter_seq,nextval)
  FROM dual
  DETAIL
   new_encntr_person_reltn_id = seqn
  WITH format, counter
 ;end select
 SELECT INTO "nl:"
  seqn = seq(encounter_only_seq,nextval)
  FROM dual
  DETAIL
   new_encntr_nbr = seqn
  WITH format, counter
 ;end select
 INSERT  FROM encounter e
  SET e.encntr_id = new_encntr_nbr, e.person_id = request->person_id, e.updt_cnt = 0,
   e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = reqinfo->updt_id, e.updt_task = reqinfo
   ->updt_task,
   e.updt_applctx = reqinfo->updt_applctx, e.active_ind = 1, e.active_status_cd = reqdata->
   active_status_cd,
   e.active_status_dt_tm = cnvtdatetime(curdate,curtime3), e.active_status_prsnl_id = reqinfo->
   updt_id, e.create_dt_tm = cnvtdatetime(curdate,curtime3),
   e.create_prsnl_id = reqinfo->updt_id, e.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), e
   .end_effective_dt_tm = cnvtdatetime("31-DEC-2100 23:59:59:99"),
   e.encntr_class_cd = 0, e.encntr_type_cd = encntr_type_code, e.encntr_type_class_cd =
   encntr_type_class_code,
   e.encntr_status_cd = encntr_status_code, e.pre_reg_dt_tm = null, e.pre_reg_prsnl_id = 0,
   e.reg_dt_tm = cnvtdatetime(request->contact_dt_tm), e.reg_prsnl_id = reqinfo->updt_id, e
   .est_arrive_dt_tm = null,
   e.est_depart_dt_tm = null, e.arrive_dt_tm = null, e.depart_dt_tm = null,
   e.admit_type_cd = 0, e.admit_src_cd = 0, e.admit_mode_cd = 0,
   e.admit_with_medication_cd = 0, e.referring_comment = null, e.disch_disposition_cd = 0,
   e.disch_to_loctn_cd = 0, e.preadmit_nbr = null, e.preadmit_testing_cd = 0,
   e.readmit_cd = 0, e.accommodation_cd = 0, e.accommodation_request_cd = 0,
   e.alt_result_dest_cd = 0, e.ambulatory_cond_cd = 0, e.courtesy_cd = 0,
   e.diet_type_cd = 0, e.isolation_cd = 0, e.med_service_cd = 0,
   e.result_dest_cd = 0, e.confid_level_cd = 0, e.vip_cd = 0,
   e.name_last_key = null, e.name_first_key = null, e.name_full_formatted = null,
   e.name_last = null, e.name_first = null, e.name_phonetic = null,
   e.sex_cd = 0, e.birth_dt_cd = 0, e.birth_dt_tm = null,
   e.species_cd = 0, e.data_status_cd = contact_type_cd, e.data_status_dt_tm = cnvtdatetime(curdate,
    curtime3),
   e.data_status_prsnl_id = reqinfo->updt_id, e.contributor_system_cd = contributor_system, e
   .location_cd = 0,
   e.loc_facility_cd = 0, e.loc_building_cd = 0, e.loc_nurse_unit_cd = 0,
   e.loc_room_cd = 0, e.loc_bed_cd = 0, e.disch_dt_tm = null,
   e.guarantor_type_cd = 0, e.loc_temp_cd = 0, e.organization_id = 0,
   e.reason_for_visit = null, e.encntr_financial_id = 0, e.name_first_synonym_id = 0,
   e.financial_class_cd = 0, e.bbd_procedure_cd = request->bbd_procedure_cd
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donor_elig"
  SET reply->status_data.subeventstatus[1].operationname = "insert"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "encounter"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "encounter table"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
  GO TO exit_script
 ELSE
  SET reply->encounter_id = new_encntr_nbr
 ENDIF
 SET modify = nopredeclare
 DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
 SET new_pathnet_seq = 0
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   new_pathnet_seq = seqn
  WITH format, nocounter
 ;end select
 SET modify = predeclare
 SET new_contact_id = new_pathnet_seq
 INSERT  FROM bbd_donor_contact dc
  SET dc.contact_id = new_pathnet_seq, dc.person_id = request->person_id, dc.encntr_id =
   new_encntr_nbr,
   dc.organization_id = request->organization_id, dc.active_ind = 1, dc.active_status_cd = reqdata->
   active_status_cd,
   dc.active_status_dt_tm = cnvtdatetime(curdate,curtime3), dc.active_status_prsnl_id = reqinfo->
   updt_id, dc.updt_applctx = reqinfo->updt_applctx,
   dc.updt_dt_tm = cnvtdatetime(curdate,curtime3), dc.updt_id = reqinfo->updt_id, dc.updt_task =
   reqinfo->updt_task,
   dc.updt_cnt = 0, dc.contact_type_cd = bbd_contact_type_cd, dc.init_contact_prsnl_id = reqinfo->
   updt_id,
   dc.contact_outcome_cd = 0, dc.contact_dt_tm = cnvtdatetime(request->contact_dt_tm), dc
   .needed_dt_tm = cnvtdatetime(request->needed_dt),
   dc.contact_status_cd = contact_status_code, dc.inventory_area_cd = request->inventory_area_cd, dc
   .owner_area_cd = request->owner_area_cd
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donor_elig"
  SET reply->status_data.subeventstatus[1].operationname = "insert"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bbd_donor_contact"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "bbd donor contact table"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
  GO TO exit_script
 ENDIF
 IF ((request->update_encntr_person_reltn=0))
  GO TO person_donor
 ENDIF
 INSERT  FROM encntr_person_reltn p
  SET p.encntr_person_reltn_id = new_encntr_person_reltn_id, p.person_reltn_type_cd =
   person_reltn_type_code, p.encntr_id = new_encntr_nbr,
   p.person_reltn_cd = 0, p.related_person_reltn_cd = request->relation_cd, p.related_person_id =
   request->recipient_id,
   p.updt_cnt = 0, p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id = reqinfo->updt_id,
   p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx, p.active_ind = 1,
   p.active_status_cd = reqdata->active_status_cd, p.active_status_dt_tm = cnvtdatetime(curdate,
    curtime3), p.active_status_prsnl_id = reqinfo->updt_id,
   p.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), p.end_effective_dt_tm = cnvtdatetime(
    "31-DEC-2100 23:59:59:99"), p.data_status_cd = contact_type_cd,
   p.data_status_dt_tm = cnvtdatetime(curdate,curtime3), p.data_status_prsnl_id = reqinfo->updt_id, p
   .contributor_system_cd = contributor_system,
   p.contact_role_cd = 0, p.genetic_relationship_ind = 1, p.living_with_ind = 0,
   p.visitation_allowed_cd = 0, p.priority_seq = 0, p.free_text_cd = 0,
   p.ft_rel_person_name = null, p.internal_seq = 0
  WITH counter
 ;end insert
 IF (curqual=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donor_elig"
  SET reply->status_data.subeventstatus[1].operationname = "insert"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "encntr_person_reltn"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "encounter person relation table"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
  GO TO exit_script
 ENDIF
#person_donor
 SELECT INTO "nl:"
  pd.*
  FROM person_donor pd
  WHERE (pd.person_id=request->person_id)
  WITH counter, forupdate(pd)
 ;end select
 UPDATE  FROM person_donor pd
  SET pd.lock_ind = 0, pd.updt_cnt = (pd.updt_cnt+ 1), pd.updt_id = reqinfo->updt_id,
   pd.updt_task = reqinfo->updt_task, pd.updt_applctx = reqinfo->updt_applctx, pd.updt_dt_tm =
   cnvtdatetime(curdate,curtime3)
  WHERE (pd.person_id=request->person_id)
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donor_elig"
  SET reply->status_data.subeventstatus[1].operationname = "update"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "person_donor"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "person_donor update"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
  GO TO exit_script
 ENDIF
 IF ((request->override_ind=0))
  GO TO person_org
 ENDIF
 SET counter = 0
 SET modify = nopredeclare
 FOR (counter = 1 TO nbr_of_exceptions)
   SET exception_status = "I"
   SET bb_exception_id = 0
   CALL add_bb_exception(request->qual[counter].exception_type_mean,request->qual[counter].
    override_reason_cd,request->person_id,new_contact_id,bbd_contact_type_cd)
   IF (exception_status="S")
    SET failed = "F"
   ELSE
    SET failed = "T"
    GO TO exit_script
   ENDIF
 ENDFOR
 SET modify = predeclare
 IF (curqual=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donor_elig"
  SET reply->status_data.subeventstatus[1].operationname = "insert"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bb_exception"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "insert bb_exception"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
  GO TO exit_script
 ENDIF
#person_org
 SET successful_action = "I"
 SET modify = nopredeclare
 CALL add_per_org_reltn(request->person_id,request->organization_id)
 IF (successful_action="S")
  SET failed = "F"
 ELSE
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_donor_elig"
  SET reply->status_data.subeventstatus[1].operationname = "insert"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "person_org_reltn"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "insert person_org_reltn"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
  GO TO exit_script
 ENDIF
 SUBROUTINE add_per_org_reltn(new_person_id,new_organization_id)
   SET successful_action = "F"
   DECLARE donor_org_cd = f8 WITH protect, noconstant(0.0)
   DECLARE data_status_code = f8 WITH protect, noconstant(0.0)
   DECLARE leave_sub_flag = c1 WITH protect, noconstant("F")
   IF (new_organization_id=0)
    SET successful_action = "S"
   ENDIF
   SET cdf_meaning = "DONOR"
   SET code_set = 338
   SET code_cnt = 1
   SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,donor_org_cd)
   IF (donor_org_cd=0)
    SET successful_action = "F"
    SET leave_sub_flag = "T"
   ENDIF
   SELECT INTO "nl:"
    p.person_id
    FROM person_org_reltn p
    WHERE p.person_id=new_person_id
     AND p.organization_id=new_organization_id
     AND p.person_org_reltn_cd=donor_org_cd
     AND p.active_ind=1
    DETAIL
     successful_action = "S"
    WITH nocounter
   ;end select
   IF ((request->organization_id > 0)
    AND successful_action="F")
    SET cdf_meaning = "AUTH"
    SET code_set = 8
    SET code_cnt = 1
    SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,data_status_code)
    IF (data_status_code=0)
     SET successful_action = "F"
     SET leave_sub_flag = "T"
    ENDIF
    IF (leave_sub_flag="F")
     SET new_organization_seq = 0.0
     SELECT INTO "nl:"
      seqn = seq(organization_seq,nextval)
      FROM dual
      DETAIL
       new_organization_seq = seqn
      WITH format, nocounter
     ;end select
     INSERT  FROM person_org_reltn p
      SET p.person_org_reltn_id = new_organization_seq, p.person_id = new_person_id, p
       .person_org_reltn_cd = donor_org_cd,
       p.organization_id = new_organization_id, p.updt_cnt = 0, p.updt_dt_tm = cnvtdatetime(curdate,
        curtime3),
       p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->
       updt_applctx,
       p.active_ind = 1, p.active_status_cd = reqdata->active_status_cd, p.active_status_dt_tm =
       cnvtdatetime(curdate,curtime3),
       p.active_status_prsnl_id = reqinfo->updt_id, p.beg_effective_dt_tm = cnvtdatetime(curdate,
        curtime3), p.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 23:59:59:99"),
       p.data_status_cd = data_status_code, p.data_status_dt_tm = cnvtdatetime(curdate,curtime3), p
       .data_status_prsnl_id = reqinfo->updt_id,
       p.contributor_system_cd = 0, p.person_org_nbr = null, p.person_org_alias = null,
       p.empl_type_cd = 0, p.empl_status_cd = 0, p.empl_occupation_text = null,
       p.empl_occupation_cd = 0, p.empl_title = null, p.empl_position = null,
       p.empl_contact = null, p.empl_contact_title = null, p.free_text_ind = 0,
       p.ft_org_name = null, p.priority_seq = 0, p.internal_seq = 0,
       p.empl_retire_dt_tm = null, p.empl_hire_dt_tm = null, p.empl_term_dt_tm = null
      WITH counter
     ;end insert
     IF (curqual=0)
      SET successful_action = "F"
     ELSE
      SET successful_action = "S"
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE add_bb_exception(exception_type_mean,override_reason_cd_new,person_id,
  donor_contact_id_new,donor_contact_type_cd_new)
   DECLARE exception_type_cd_new = f8 WITH protect, noconstant(0.0)
   SET exception_status = "I"
   SET code_set = 0
   SET code_value = 0.0
   SET cdf_meaning = fillstring(80," ")
   SET code_cnt = 1
   SET cdf_meaning = exception_type_mean
   SET code_set = 14072
   SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,code_value)
   IF (code_value=0)
    SET exception_status = "F"
   ELSE
    SET exception_type_cd_new = code_value
    DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
    SET new_pathnet_seq = 0
    SELECT INTO "nl:"
     seqn = seq(pathnet_seq,nextval)
     FROM dual
     DETAIL
      new_pathnet_seq = seqn
     WITH format, nocounter
    ;end select
    SET bb_exception_id = new_pathnet_seq
    INSERT  FROM bb_exception b
     SET b.exception_id = bb_exception_id, b.product_event_id = 0, b.exception_type_cd =
      exception_type_cd_new,
      b.exception_dt_tm = cnvtdatetime(curdate,curtime3), b.event_type_cd = 0, b.from_abo_cd = 0,
      b.from_rh_cd = 0, b.to_abo_cd = 0, b.to_rh_cd = 0,
      b.override_reason_cd = override_reason_cd_new, b.result_id = 0, b.perform_result_id = 0,
      b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id,
      b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b.active_ind = 1,
      b.active_status_cd = reqdata->active_status_cd, b.active_status_dt_tm = cnvtdatetime(curdate,
       curtime3), b.active_status_prsnl_id = reqinfo->updt_id,
      b.person_id =
      IF (person_id > 0) person_id
      ELSE 0
      ENDIF
      , b.donor_contact_id = donor_contact_id_new, b.donor_contact_type_cd =
      donor_contact_type_cd_new
     WITH counter
    ;end insert
    IF (curqual=0)
     SET exception_status = "F"
    ELSE
     SET exception_status = "S"
    ENDIF
   ENDIF
 END ;Subroutine
 SET modify = predeclare
#exit_script
 IF (failed="T")
  ROLLBACK
  SET reply->status_data.status = "F"
 ELSE
  COMMIT
  SET reply->status_data.status = "S"
 ENDIF
END GO
