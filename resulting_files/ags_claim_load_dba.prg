CREATE PROGRAM ags_claim_load:dba
 IF (validate(reply,"!")="!")
  FREE RECORD reply
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH persistscript
 ENDIF
 CALL echo("***")
 CALL echo("***   BEG AGS_CLAIM_LOAD")
 CALL echo("***")
 IF (validate(request,"!")="!")
  RECORD request(
    1 debug_logging = i4
    1 ags_task_id = f8
  )
  SET request->debug_logging = 4
  SET request->ags_task_id = 0
 ENDIF
 IF (validate(ags_get_code_defined,0)=0)
  EXECUTE ags_get_code
 ENDIF
 IF (validate(ags_log_header_defined,0)=0)
  EXECUTE ags_log_header
 ENDIF
 CALL set_log_level(request->debug_logging)
 DECLARE working_task_id = f8 WITH public, noconstant(request->ags_task_id)
 IF (get_script_status(0) != esuccessful)
  GO TO exit_script
 ENDIF
 DECLARE job_contributor_system_cd = f8 WITH public, noconstant(0.0)
 DECLARE working_sending_system = vc WITH public, noconstant(" ")
 DECLARE working_mode = i2 WITH public, noconstant(0)
 DECLARE working_job_id = f8 WITH public, noconstant(0.0)
 DECLARE working_kill_ind = i2 WITH public, noconstant(0)
 DECLARE beg_data_id = f8 WITH public, noconstant(0.0)
 DECLARE end_data_id = f8 WITH public, noconstant(0.0)
 DECLARE max_data_id = f8 WITH public, noconstant(0.0)
 DECLARE data_size = i4 WITH public, noconstant(1000)
 DECLARE default_data_size = i4 WITH public, noconstant(1000)
 DECLARE data_knt = i4 WITH public, noconstant(0)
 DECLARE it_avg = i4 WITH public, noconstant(0)
 DECLARE create_orgs = i2 WITH public, noconstant(false)
 DECLARE provider_dir_enabled = i2 WITH public, noconstant(false)
 FREE RECORD contrib_rec
 RECORD contrib_rec(
   1 qual_knt = i4
   1 qual[*]
     2 sending_facility = vc
     2 contributor_system_cd = f8
     2 contributor_source_cd = f8
     2 time_zone_flag = i2
     2 time_zone = vc
     2 time_zone_idx = i4
     2 prsnl_person_id = f8
     2 organization_id = f8
     2 ext_alias_pool_cd = f8
     2 ext_alias_type_cd = f8
     2 ssn_alias_pool_cd = f8
     2 ssn_alias_type_cd = f8
     2 attend_doc_alias_pool_cd = f8
     2 attend_doc_alias_type_cd = f8
     2 admit_doc_alias_pool_cd = f8
     2 admit_doc_alias_type_cd = f8
     2 billing_org_alias_pool_cd = f8
     2 billing_org_alias_type_cd = f8
     2 billing_prsnl_alias_pool_cd = f8
     2 billing_prsnl_alias_type_cd = f8
     2 billing_ext_alias_pool_cd = f8
     2 billing_ext_alias_type_cd = f8
     2 billing_cva_alias_stamp = vc
 )
 FREE RECORD dates
 RECORD dates(
   1 now_dt_tm = dq8
   1 end_dt_tm = dq8
   1 batch_start_dt_tm = dq8
   1 it_end_dt_tm = dq8
   1 it_est_end_dt_tm = dq8
 )
 SET dates->now_dt_tm = cnvtdatetime(curdate,curtime3)
 SET dates->batch_start_dt_tm = cnvtdatetime(dates->now_dt_tm)
 SET dates->end_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00")
 SET current_dt_tm = cnvtdatetime(curdate,curtime3)
 SET max_date = cnvtdatetime("31-DEC-2100 00:00:00.00")
 DECLARE found_default_contrib_system = i2 WITH public, noconstant(false)
 DECLARE visit_type_default_cd = f8 WITH public, noconstant(0.0)
 DECLARE num = i4 WITH public, noconstant(0)
 DECLARE pos = i4 WITH public, noconstant(0)
 DECLARE auth_data_status_cd = f8 WITH public, constant(ags_get_code_by("MEANING",8,"AUTH"))
 DECLARE unauth_data_status_cd = f8 WITH public, constant(ags_get_code_by("MEANING",8,"UNAUTH"))
 DECLARE active_active_status_cd = f8 WITH public, constant(ags_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE inactive_active_status_cd = f8 WITH public, constant(ags_get_code_by("MEANING",48,"INACTIVE"
   ))
 DECLARE cernerchr_contributor_source_cd = f8 WITH public, constant(ags_get_code_by("MEANING",73,
   "CERNERCHR"))
 DECLARE esi_default_cd = f8 WITH public, constant(ags_get_code_by("DISPLAY",73,"Default"))
 DECLARE ama_contributor_system_cd = f8 WITH public, constant(ags_get_code_by("DISPLAY",89,"AMA"))
 DECLARE hcfa_contributor_system_cd = f8 WITH public, constant(ags_get_code_by("DISPLAY",89,"HCFA"))
 DECLARE umls_contributor_system_cd = f8 WITH public, constant(ags_get_code_by("DISPLAY",89,"UMLS"))
 DECLARE facility_loc_type_cd = f8 WITH public, constant(ags_get_code_by("MEANING",222,"FACILITY"))
 DECLARE cpt4_source_voc_cd = f8 WITH public, constant(ags_get_code_by("MEANING",400,"CPT4"))
 DECLARE hcpcs_source_voc_cd = f8 WITH public, constant(ags_get_code_by("MEANING",400,"HCPCS"))
 DECLARE icd9_source_voc_cd = f8 WITH public, constant(ags_get_code_by("MEANING",400,"ICD9"))
 DECLARE ssn_alias_field_cd = f8 WITH public, constant(ags_get_code_by("MEANING",4001891,"PRSNSSN"))
 DECLARE ext_alias_field_cd = f8 WITH public, constant(ags_get_code_by("MEANING",4001891,
   "PRSNEXTALIAS"))
 DECLARE admit_doc_alias_field_cd = f8 WITH public, constant(ags_get_code_by("MEANING",4001891,
   "CLMADMIT"))
 DECLARE attend_doc_alias_field_cd = f8 WITH public, constant(ags_get_code_by("MEANING",4001891,
   "CLMATTEND"))
 DECLARE billing_org_alias_field_cd = f8 WITH public, constant(ags_get_code_by("MEANING",4001891,
   "CLMBILLORG"))
 DECLARE billing_prsnl_alias_field_cd = f8 WITH public, constant(ags_get_code_by("MEANING",4001891,
   "CLMBILLPRSNL"))
 DECLARE billing_ext_alias_field_cd = f8 WITH public, constant(ags_get_code_by("MEANING",4001891,
   "ORGEXTALIAS"))
 DECLARE male_sex_cd = f8 WITH public, constant(ags_get_code_by("MEANING",57,"MALE"))
 DECLARE female_sex_cd = f8 WITH public, constant(ags_get_code_by("MEANING",57,"FEMALE"))
 CALL echo("***")
 CALL echo("***   Log Starting Conditions")
 CALL echo("***")
 CALL echo(concat("*** request->ags_task_id   :",cnvtstring(working_task_id)))
 CALL echo(concat("*** request->debug_logging :",cnvtstring(request->debug_logging)))
 CALL echo("***")
 SELECT INTO "nl:"
  FROM dm_info di
  PLAN (di
   WHERE di.info_name="AGS_CREATE_ORGS")
  DETAIL
   IF (di.info_number > 0)
    create_orgs = true
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM dm_info di
  PLAN (di
   WHERE di.info_domain="AGS"
    AND di.info_name="PROVIDER_DIRECTORY")
  DETAIL
   IF (di.info_number > 0)
    provider_dir_enabled = true
   ENDIF
  WITH nocounter
 ;end select
 IF (working_task_id > 0)
  CALL echo("***")
  CALL echo("***   Update Task to Processing")
  CALL echo("***")
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  UPDATE  FROM ags_task t
   SET t.status = "PROCESSING", t.status_dt_tm = cnvtdatetime(curdate,curtime3), t.batch_start_dt_tm
     = cnvtdatetime(dates->batch_start_dt_tm),
    t.batch_end_dt_tm = cnvtdatetime(dates->end_dt_tm)
   PLAN (t
    WHERE t.ags_task_id=working_task_id)
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   CALL ags_set_status_block(eupdate,efailure,"Update Task to Processing",trim(serrmsg))
   GO TO exit_script
  ENDIF
  COMMIT
 ELSE
  CALL ags_set_status_block(eattribute,efailure,"AGS_TASK","Invalid Task Id")
  GO TO exit_script
 ENDIF
 IF (male_sex_cd < 1)
  CALL ags_set_status_block(eattribute,efailure,"MALE_SEX_CD",
   "CODE_VALUE for CDF_MEANING MALE invalid from CODE_SET 57")
  GO TO exit_script
 ENDIF
 IF (female_sex_cd < 1)
  CALL ags_set_status_block(eattribute,efailure,"FEMALE_SEX_CD",
   "CODE_VALUE for CDF_MEANING FEMALE invalid from CODE_SET 57")
  GO TO exit_script
 ENDIF
 IF (esi_default_cd < 1)
  CALL ags_set_status_block(eattribute,efailure,"ESI_DEFAULT_CD",
   "CODE_VALUE for display Default invalid from CODE_SET 73")
  GO TO exit_script
 ENDIF
 IF (ext_alias_field_cd < 1)
  CALL ags_set_status_block(eattribute,efailure,"EXT_ALIAS_FIELD_CD",
   "CODE_VALUE for meaning PRSNEXTALIAS invalid from CODE_SET 4001891")
  GO TO exit_script
 ENDIF
 IF (cernerchr_contributor_source_cd < 1)
  CALL ags_set_status_block(eattribute,efailure,"CERNERCHR_CONTRIBUTOR_SOURCE_CD",
   "CODE_VALUE for meaning CERNERCHR invalid from CODE_SET 73")
  GO TO exit_script
 ENDIF
 IF (billing_ext_alias_field_cd < 1)
  CALL ags_set_status_block(eattribute,efailure,"BILLING_EXT_ALIAS_FIELD_CD",
   "CODE_VALUE for meaning ORGEXTALIAS invalid from CODE_SET 4001891")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_value_alias cva
  WHERE cva.code_set=4001892
   AND cva.alias="99"
   AND cva.contributor_source_cd=cernerchr_contributor_source_cd
  DETAIL
   visit_type_default_cd = cva.code_value
  WITH nocounter
 ;end select
 IF (visit_type_default_cd < 1)
  CALL ags_set_status_block(eattribute,efailure,"VISIT_TYPE_DEFAULT_CD",
   "CODE_VALUE_ALIAS for Default invalid from CODE_SET 4001892")
  GO TO exit_script
 ENDIF
 CALL echo("***")
 CALL echo("***   Get Task Data")
 CALL echo("***")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM ags_task t,
   ags_job j,
   code_value_alias cva
  PLAN (t
   WHERE t.ags_task_id=working_task_id)
   JOIN (j
   WHERE j.ags_job_id=t.ags_job_id)
   JOIN (cva
   WHERE cva.code_set=89
    AND cva.alias=j.sending_system
    AND cva.contributor_source_cd=esi_default_cd)
  HEAD REPORT
   beg_data_id = t.batch_start_id
   IF (t.iteration_start_id > 0)
    beg_data_id = t.iteration_start_id
   ENDIF
   max_data_id = t.batch_end_id, data_size = t.batch_size
   IF (data_size < 1)
    data_size = default_data_size
   ENDIF
   job_contributor_system_cd = cva.code_value, working_job_id = t.ags_job_id, working_mode = t
   .mode_flag,
   working_kill_ind = t.kill_ind
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  CALL ags_set_status_block(eselect,efailure,"TASK DATA",trim(serrmsg))
  GO TO exit_script
 ENDIF
 IF (curqual < 1)
  CALL ags_set_status_block(eattribute,efailure,"TASK DATA","Invalid TASK_ID")
  GO TO exit_script
 ENDIF
 IF (working_kill_ind > 0)
  CALL ags_set_status_block(eattribute,efailure,"TASK DATA","KILL_IND Set to Kill")
  GO TO exit_script
 ENDIF
 IF (beg_data_id < 1)
  CALL ags_set_status_block(eattribute,efailure,"TASK DATA","BEG_DATA_ID :: Less Than 1")
  GO TO exit_script
 ENDIF
 CALL echo("***")
 CALL echo(build("***   beg_data_id    :",beg_data_id))
 CALL echo(build("***   max_data_id    :",max_data_id))
 CALL echo(build("***   data_size      :",data_size))
 CALL echo(build("***   working_job_id :",working_job_id))
 CALL echo(build("***   working_mode   :",working_mode))
 CALL echo("***")
 CALL echo("***")
 CALL echo("***   Process Data")
 CALL echo("***")
 IF (((beg_data_id+ data_size) > max_data_id))
  SET end_data_id = max_data_id
 ELSE
  SET end_data_id = ((beg_data_id+ data_size) - 1)
 ENDIF
 IF (end_data_id < 1
  AND working_mode=3)
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  SELECT INTO "nl:"
   max_id = max(o.ags_claim_data_id), dknt = count(o.ags_claim_data_id)
   FROM ags_claim_data o
   PLAN (o
    WHERE o.ags_claim_data_id >= beg_data_id
     AND trim(o.status) IN ("IN ERROR", "BACK OUT"))
   HEAD REPORT
    x = 1
   DETAIL
    x = 1
   FOOT REPORT
    max_data_id = max_id, data_knt = dknt
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   CALL ags_set_status_block(eselect,efailure,"MODE 3 CHK",trim(serrmsg))
   GO TO exit_script
  ENDIF
  IF (data_knt <= data_size)
   SET end_data_id = max_data_id
  ELSE
   SET end_data_id = ((beg_data_id+ data_size) - 1)
  ENDIF
  CALL echo("***")
  CALL echo("***   Update Task Batch End")
  CALL echo("***")
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  UPDATE  FROM ags_task t
   SET t.batch_end_id = max_data_id
   PLAN (t
    WHERE t.ags_task_id=working_task_id)
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   CALL ags_set_status_block(eupdate,efailure,"BATCH_END_ID",trim(serrmsg))
   GO TO exit_script
  ENDIF
  COMMIT
 ENDIF
 CALL echo("***")
 CALL echo(build("***   beg_data_id    :",beg_data_id))
 CALL echo(build("***   end_data_id    :",end_data_id))
 CALL echo(build("***   max_data_id    :",max_data_id))
 CALL echo(build("***   data_size      :",data_size))
 CALL echo(build("***   working_job_id :",working_job_id))
 CALL echo(build("***   working_mode   :",working_mode))
 CALL echo("***")
 WHILE (beg_data_id <= end_data_id
  AND working_kill_ind < 1)
   CALL ags_set_status_block(ecustom,einfo,"BEGIN PROCESSING",concat("BEG_DATA_ID :: ",trim(
      cnvtstring(beg_data_id))," :: END_DATA_ID :: ",trim(cnvtstring(end_data_id)),
     " :: MAX_DATA_ID :: ",
     trim(cnvtstring(max_data_id))))
   CALL echo("***")
   CALL echo(build("***   beg_data_id    :",beg_data_id))
   CALL echo(build("***   end_data_id    :",end_data_id))
   CALL echo(build("***   working_job_id :",working_job_id))
   CALL echo(build("***   job_contributor_system_cd :",job_contributor_system_cd))
   CALL echo("***")
   FREE RECORD hold
   RECORD hold(
     1 qual_knt = i4
     1 qual[*]
       2 contrib_idx = i4
       2 run_nbr = i4
       2 ags_claim_data_id = f8
       2 hea_claim_visit_id = f8
       2 person_id = f8
       2 person_alias = vc
       2 status = vc
       2 stat_msg = vc
       2 claim_identifier = vc
       2 prev_claim_identifier = vc
       2 action = vc
       2 ext_alias = vc
       2 ssn_alias = vc
       2 not_valid_ssn_chk = i2
       2 birth_date = vc
       2 birth_dt_tm = dq8
       2 abs_birth_dt_tm = dq8
       2 name_first = vc
       2 name_last = vc
       2 gender = vc
       2 sex_cd = f8
       2 start_service_date = vc
       2 end_service_date = vc
       2 visit_type = vc
       2 billing_ext_alias = vc
       2 admitting_ext_alias = vc
       2 attending_ext_alias = vc
       2 procedure1 = vc
       2 procedure2 = vc
       2 procedure3 = vc
       2 procedure4 = vc
       2 procedure5 = vc
       2 procedure6 = vc
       2 procedure7 = vc
       2 procedure8 = vc
       2 procedure9 = vc
       2 procedure10 = vc
       2 diagnosis1 = vc
       2 diagnosis2 = vc
       2 diagnosis3 = vc
       2 diagnosis4 = vc
       2 diagnosis5 = vc
       2 diagnosis6 = vc
       2 diagnosis7 = vc
       2 diagnosis8 = vc
       2 diagnosis9 = vc
       2 diagnosis10 = vc
       2 diagnosis11 = vc
       2 diagnosis12 = vc
       2 diagnosis13 = vc
       2 diagnosis14 = vc
       2 diagnosis15 = vc
       2 claim_cnt = i4
       2 current_count = i4
       2 visit_type_cd = f8
       2 start_service_dt_tm = dq8
       2 end_service_dt_tm = dq8
       2 attending_person_id = f8
       2 admitting_person_id = f8
       2 procedure1_id = f8
       2 procedure2_id = f8
       2 procedure3_id = f8
       2 procedure4_id = f8
       2 procedure5_id = f8
       2 procedure6_id = f8
       2 procedure7_id = f8
       2 procedure8_id = f8
       2 procedure9_id = f8
       2 procedure10_id = f8
       2 diagnosis1_id = f8
       2 diagnosis2_id = f8
       2 diagnosis3_id = f8
       2 diagnosis4_id = f8
       2 diagnosis5_id = f8
       2 diagnosis6_id = f8
       2 diagnosis7_id = f8
       2 diagnosis8_id = f8
       2 diagnosis9_id = f8
       2 diagnosis10_id = f8
       2 diagnosis11_id = f8
       2 diagnosis12_id = f8
       2 diagnosis13_id = f8
       2 diagnosis14_id = f8
       2 diagnosis15_id = f8
       2 billing_provider_id = f8
       2 billing_facility_cd = f8
       2 billing_org_id = f8
       2 person_exists_ind = i4
       2 ext_alias_exists_ind = i4
       2 ext_alias_person_alias_id = f8
       2 ssn_alias_exists_ind = i4
       2 ssn_alias_person_alias_id = f8
       2 sending_facility = vc
       2 contributor_system_cd = f8
       2 prsnl_person_id = f8
       2 qual2_knt = i4
       2 qual2[*]
         3 elementcd = i2
         3 logcd = i2
   )
   FREE RECORD proclist
   RECORD proclist(
     1 qual[*]
       2 idx = i4
       2 element_name = vc
       2 source_identifier = vc
       2 nomenclature_id = f8
       2 claim_dt_tm = dq8
       2 date_match_ind = i4
       2 primary_system_ind = i4
   )
   FREE RECORD diaglist
   RECORD diaglist(
     1 qual[*]
       2 idx = i4
       2 element_name = vc
       2 source_identifier = vc
       2 nomenclature_id = f8
       2 claim_dt_tm = dq8
       2 date_match_ind = i4
       2 primary_system_ind = i4
   )
   SET proc_cnt = 0
   SET diag_cnt = 0
   SET dates->now_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   SELECT
    IF (working_mode=0)
     PLAN (o
      WHERE o.ags_claim_data_id >= beg_data_id
       AND o.ags_claim_data_id <= end_data_id
       AND ((o.person_id+ 0) < 1)
       AND ((o.hea_claim_visit_id+ 0) < 1)
       AND trim(o.status)="WAITING")
      JOIN (j
      WHERE j.ags_job_id=o.ags_job_id)
    ELSEIF (working_mode=1)
     PLAN (o
      WHERE o.ags_claim_data_id >= beg_data_id
       AND o.ags_claim_data_id <= end_data_id)
      JOIN (j
      WHERE j.ags_job_id=o.ags_job_id)
    ELSEIF (working_mode=2)
     PLAN (o
      WHERE o.ags_claim_data_id >= beg_data_id
       AND o.ags_claim_data_id <= end_data_id
       AND ((o.person_id+ 0) < 1)
       AND ((o.hea_claim_visit_id+ 0) < 1))
      JOIN (j
      WHERE j.ags_job_id=o.ags_job_id)
    ELSE
     PLAN (o
      WHERE o.ags_claim_data_id >= beg_data_id
       AND o.ags_claim_data_id <= end_data_id
       AND trim(o.status) IN ("IN ERROR", "BACK OUT"))
      JOIN (j
      WHERE j.ags_job_id=o.ags_job_id)
    ENDIF
    INTO "nl:"
    FROM ags_claim_data o,
     ags_job j
    HEAD REPORT
     stat = alterlist(hold->qual,data_size), idx = 0
    HEAD o.ags_claim_data_id
     idx = (idx+ 1)
     IF (idx > size(hold->qual,5))
      stat = alterlist(hold->qual,(idx+ data_size))
     ENDIF
     hold->qual[idx].status = "S", hold->qual[idx].stat_msg = ""
     IF ((contrib_rec->qual_knt > 0))
      IF (size(trim(o.sending_facility,3)) > 0)
       pos = 0, pos = locateval(num,1,contrib_rec->qual_knt,o.sending_facility,contrib_rec->qual[num]
        .sending_facility)
       IF (pos > 0)
        hold->qual[idx].contrib_idx = pos
       ELSE
        contrib_rec->qual_knt = (contrib_rec->qual_knt+ 1), stat = alterlist(contrib_rec->qual,
         contrib_rec->qual_knt), contrib_rec->qual[contrib_rec->qual_knt].sending_facility = trim(o
         .sending_facility,3),
        hold->qual[idx].contrib_idx = contrib_rec->qual_knt
       ENDIF
      ELSEIF (size(trim(j.sending_system,3)) > 0)
       pos = 0, pos = locateval(num,1,contrib_rec->qual_knt,j.sending_system,contrib_rec->qual[num].
        sending_facility)
       IF (pos > 0)
        hold->qual[idx].contrib_idx = pos
       ELSE
        contrib_rec->qual_knt = (contrib_rec->qual_knt+ 1), stat = alterlist(contrib_rec->qual,
         contrib_rec->qual_knt), contrib_rec->qual[contrib_rec->qual_knt].sending_facility = trim(j
         .sending_system,3),
        hold->qual[idx].contrib_idx = contrib_rec->qual_knt
       ENDIF
      ELSE
       hold->qual[idx].contrib_idx = - (1), hold->qual[idx].status = "F", hold->qual[idx].stat_msg =
       concat(trim(hold->qual[idx].stat_msg),"[contrib]"),
       hold->qual[idx].qual2_knt = (hold->qual[idx].qual2_knt+ 1), stat = alterlist(hold->qual[idx].
        qual2,hold->qual[idx].qual2_knt), hold->qual[idx].qual2[hold->qual[idx].qual2_knt].elementcd
        = esendfacility,
       hold->qual[idx].qual2[hold->qual[idx].qual2_knt].logcd = emissing
      ENDIF
     ELSE
      IF (size(trim(o.sending_facility,3)) > 0)
       contrib_rec->qual_knt = (contrib_rec->qual_knt+ 1), stat = alterlist(contrib_rec->qual,
        contrib_rec->qual_knt), contrib_rec->qual[contrib_rec->qual_knt].sending_facility = trim(o
        .sending_facility,3),
       hold->qual[idx].contrib_idx = contrib_rec->qual_knt
      ELSEIF (size(trim(j.sending_system,3)) > 0)
       contrib_rec->qual_knt = (contrib_rec->qual_knt+ 1), stat = alterlist(contrib_rec->qual,
        contrib_rec->qual_knt), contrib_rec->qual[contrib_rec->qual_knt].sending_facility = trim(j
        .sending_system,3),
       hold->qual[idx].contrib_idx = contrib_rec->qual_knt
      ELSE
       hold->qual[idx].contrib_idx = - (1), hold->qual[idx].status = "F", hold->qual[idx].stat_msg =
       concat(trim(hold->qual[idx].stat_msg),"[contrib]"),
       hold->qual[idx].qual2_knt = (hold->qual[idx].qual2_knt+ 1), stat = alterlist(hold->qual[idx].
        qual2,hold->qual[idx].qual2_knt), hold->qual[idx].qual2[hold->qual[idx].qual2_knt].elementcd
        = esendfacility,
       hold->qual[idx].qual2[hold->qual[idx].qual2_knt].logcd = emissing
      ENDIF
     ENDIF
     hold->qual[idx].run_nbr = o.run_nbr, hold->qual[idx].claim_identifier = trim(o.claim_identifier,
      3), hold->qual[idx].prev_claim_identifier = trim(o.prev_claim_identifier,3),
     hold->qual[idx].action = trim(o.action,3), sextalias = trim(o.ext_alias,3)
     IF (size(trim(sextalias)) > 0)
      hold->qual[idx].ext_alias = sextalias
     ELSE
      hold->qual[idx].stat_msg = concat(trim(hold->qual[idx].stat_msg),"[x]am"), hold->qual[idx].
      qual2_knt = (hold->qual[idx].qual2_knt+ 1), stat = alterlist(hold->qual[idx].qual2,hold->qual[
       idx].qual2_knt),
      hold->qual[idx].qual2[hold->qual[idx].qual2_knt].elementcd = eextalias, hold->qual[idx].qual2[
      hold->qual[idx].qual2_knt].logcd = emissing
     ENDIF
     sssnalias = trim(o.ssn_alias,3)
     IF (size(trim(sssnalias)) > 0)
      hold->qual[idx].ssn_alias = sssnalias
     ELSE
      hold->qual[idx].not_valid_ssn_chk = true, hold->qual[idx].stat_msg = concat(trim(hold->qual[idx
        ].stat_msg),"[s]am"), hold->qual[idx].qual2_knt = (hold->qual[idx].qual2_knt+ 1),
      stat = alterlist(hold->qual[idx].qual2,hold->qual[idx].qual2_knt), hold->qual[idx].qual2[hold->
      qual[idx].qual2_knt].elementcd = essnalias, hold->qual[idx].qual2[hold->qual[idx].qual2_knt].
      logcd = emissing
     ENDIF
     snamefirst = trim(o.name_first,3)
     IF (size(trim(snamefirst)) > 0)
      hold->qual[idx].name_first = snamefirst
     ELSE
      hold->qual[idx].not_valid_ssn_chk = true, hold->qual[idx].stat_msg = concat(trim(hold->qual[idx
        ].stat_msg),"[nf]m"), hold->qual[idx].qual2_knt = (hold->qual[idx].qual2_knt+ 1),
      stat = alterlist(hold->qual[idx].qual2,hold->qual[idx].qual2_knt), hold->qual[idx].qual2[hold->
      qual[idx].qual2_knt].elementcd = enamefirst, hold->qual[idx].qual2[hold->qual[idx].qual2_knt].
      logcd = emissing
     ENDIF
     snamelast = trim(o.name_last,3)
     IF (size(trim(snamelast)) > 0)
      hold->qual[idx].name_last = snamelast
     ELSE
      hold->qual[idx].not_valid_ssn_chk = true, hold->qual[idx].stat_msg = concat(trim(hold->qual[idx
        ].stat_msg),"[nl]m"), hold->qual[idx].qual2_knt = (hold->qual[idx].qual2_knt+ 1),
      stat = alterlist(hold->qual[idx].qual2,hold->qual[idx].qual2_knt), hold->qual[idx].qual2[hold->
      qual[idx].qual2_knt].elementcd = enamelast, hold->qual[idx].qual2[hold->qual[idx].qual2_knt].
      logcd = emissing
     ENDIF
     sgender = trim(o.gender,3)
     IF (size(trim(sgender,3)) > 0)
      hold->qual[idx].gender = sgender
     ELSE
      hold->qual[idx].stat_msg = concat(trim(hold->qual[idx].stat_msg),"[g]m"), hold->qual[idx].
      qual2_knt = (hold->qual[idx].qual2_knt+ 1), stat = alterlist(hold->qual[idx].qual2,hold->qual[
       idx].qual2_knt),
      hold->qual[idx].qual2[hold->qual[idx].qual2_knt].elementcd = egender, hold->qual[idx].qual2[
      hold->qual[idx].qual2_knt].logcd = emissing
     ENDIF
     hold->qual[idx].sex_cd =
     IF ((hold->qual[idx].gender="M")) male_sex_cd
     ELSEIF ((hold->qual[idx].gender="F")) female_sex_cd
     ELSE 0
     ENDIF
     IF ((hold->qual[idx].sex_cd=0))
      hold->qual[idx].not_valid_ssn_chk = true
     ENDIF
     sbirthdate = trim(o.birth_date,3)
     IF (size(trim(sbirthdate)) > 0)
      hold->qual[idx].birth_date = sbirthdate, hold->qual[idx].birth_dt_tm = cnvtdate2(sbirthdate,
       "YYYYMMDD")
     ELSE
      hold->qual[idx].not_valid_ssn_chk = true, hold->qual[idx].stat_msg = concat(trim(hold->qual[idx
        ].stat_msg),"[bd]m"), hold->qual[idx].qual2_knt = (hold->qual[idx].qual2_knt+ 1),
      stat = alterlist(hold->qual[idx].qual2,hold->qual[idx].qual2_knt), hold->qual[idx].qual2[hold->
      qual[idx].qual2_knt].elementcd = ebirthdate, hold->qual[idx].qual2[hold->qual[idx].qual2_knt].
      logcd = emissing
     ENDIF
     hold->qual[idx].sending_facility = trim(o.sending_facility,3), hold->qual[idx].
     start_service_date = trim(o.start_service_date,3), hold->qual[idx].end_service_date = trim(o
      .end_service_date,3),
     hold->qual[idx].visit_type = trim(o.visit_type,3), hold->qual[idx].billing_ext_alias = trim(o
      .billing_ext_alias), hold->qual[idx].admitting_ext_alias = trim(o.admitting_ext_alias,3),
     hold->qual[idx].attending_ext_alias = trim(o.attending_ext_alias,3), hold->qual[idx].procedure1
      = trim(o.procedure1,3), hold->qual[idx].procedure2 = trim(o.procedure2,3),
     hold->qual[idx].procedure3 = trim(o.procedure3,3), hold->qual[idx].procedure4 = trim(o
      .procedure4,3), hold->qual[idx].procedure5 = trim(o.procedure5,3),
     hold->qual[idx].procedure6 = trim(o.procedure6,3), hold->qual[idx].procedure7 = trim(o
      .procedure7,3), hold->qual[idx].procedure8 = trim(o.procedure8,3),
     hold->qual[idx].procedure9 = trim(o.procedure9,3), hold->qual[idx].procedure10 = trim(o
      .procedure10,3), hold->qual[idx].diagnosis1 = trim(o.diagnosis1,3),
     hold->qual[idx].diagnosis2 = trim(o.diagnosis2,3), hold->qual[idx].diagnosis3 = trim(o
      .diagnosis3,3), hold->qual[idx].diagnosis4 = trim(o.diagnosis4,3),
     hold->qual[idx].diagnosis5 = trim(o.diagnosis5,3), hold->qual[idx].diagnosis6 = trim(o
      .diagnosis6,3), hold->qual[idx].diagnosis7 = trim(o.diagnosis7,3),
     hold->qual[idx].diagnosis8 = trim(o.diagnosis8,3), hold->qual[idx].diagnosis9 = trim(o
      .diagnosis9,3), hold->qual[idx].diagnosis10 = trim(o.diagnosis10,3),
     hold->qual[idx].diagnosis11 = trim(o.diagnosis11,3), hold->qual[idx].diagnosis12 = trim(o
      .diagnosis12,3), hold->qual[idx].diagnosis13 = trim(o.diagnosis13,3),
     hold->qual[idx].diagnosis14 = trim(o.diagnosis14,3), hold->qual[idx].diagnosis15 = trim(o
      .diagnosis15,3), hold->qual[idx].ags_claim_data_id = o.ags_claim_data_id,
     hold->qual[idx].hea_claim_visit_id = o.hea_claim_visit_id, hold->qual[idx].person_id = o
     .person_id, hold->qual[idx].start_service_dt_tm = cnvtdate2(hold->qual[idx].start_service_date,
      "YYYYMMDD"),
     hold->qual[idx].end_service_dt_tm = cnvtdate2(hold->qual[idx].end_service_date,"YYYYMMDD"), hold
     ->qual[idx].attending_person_id = 0, hold->qual[idx].admitting_person_id = 0,
     hold->qual[idx].billing_provider_id = 0, hold->qual[idx].billing_facility_cd = 0, hold->qual[idx
     ].billing_org_id = 0,
     hold->qual[idx].procedure1_id = 0, hold->qual[idx].procedure2_id = 0, hold->qual[idx].
     procedure3_id = 0,
     hold->qual[idx].procedure4_id = 0, hold->qual[idx].procedure5_id = 0, hold->qual[idx].
     procedure6_id = 0,
     hold->qual[idx].procedure7_id = 0, hold->qual[idx].procedure8_id = 0, hold->qual[idx].
     procedure9_id = 0,
     hold->qual[idx].procedure10_id = 0, hold->qual[idx].diagnosis1_id = 0, hold->qual[idx].
     diagnosis2_id = 0,
     hold->qual[idx].diagnosis3_id = 0, hold->qual[idx].diagnosis4_id = 0, hold->qual[idx].
     diagnosis5_id = 0,
     hold->qual[idx].diagnosis6_id = 0, hold->qual[idx].diagnosis7_id = 0, hold->qual[idx].
     diagnosis8_id = 0,
     hold->qual[idx].diagnosis9_id = 0, hold->qual[idx].diagnosis10_id = 0, hold->qual[idx].
     diagnosis11_id = 0,
     hold->qual[idx].diagnosis12_id = 0, hold->qual[idx].diagnosis13_id = 0, hold->qual[idx].
     diagnosis14_id = 0,
     hold->qual[idx].diagnosis15_id = 0
     IF (size(trim(o.procedure1)) > 0)
      proc_cnt = (proc_cnt+ 1), stat = alterlist(proclist->qual,proc_cnt), proclist->qual[proc_cnt].
      idx = idx,
      proclist->qual[proc_cnt].element_name = "procedure1_id", proclist->qual[proc_cnt].
      source_identifier = trim(o.procedure1,3), proclist->qual[proc_cnt].nomenclature_id = 0,
      proclist->qual[proc_cnt].claim_dt_tm = hold->qual[idx].start_service_dt_tm, proclist->qual[
      proc_cnt].date_match_ind = 0, proclist->qual[proc_cnt].primary_system_ind = 0
     ENDIF
     IF (size(trim(o.procedure2)) > 0)
      proc_cnt = (proc_cnt+ 1), stat = alterlist(proclist->qual,proc_cnt), proclist->qual[proc_cnt].
      idx = idx,
      proclist->qual[proc_cnt].element_name = "procedure2_id", proclist->qual[proc_cnt].
      source_identifier = trim(o.procedure2,3), proclist->qual[proc_cnt].nomenclature_id = 0,
      proclist->qual[proc_cnt].claim_dt_tm = hold->qual[idx].start_service_dt_tm, proclist->qual[
      proc_cnt].date_match_ind = 0, proclist->qual[proc_cnt].primary_system_ind = 0
     ENDIF
     IF (size(trim(o.procedure3)) > 0)
      proc_cnt = (proc_cnt+ 1), stat = alterlist(proclist->qual,proc_cnt), proclist->qual[proc_cnt].
      idx = idx,
      proclist->qual[proc_cnt].element_name = "procedure3_id", proclist->qual[proc_cnt].
      source_identifier = trim(o.procedure3,3), proclist->qual[proc_cnt].nomenclature_id = 0,
      proclist->qual[proc_cnt].claim_dt_tm = hold->qual[idx].start_service_dt_tm, proclist->qual[
      proc_cnt].date_match_ind = 0, proclist->qual[proc_cnt].primary_system_ind = 0
     ENDIF
     IF (size(trim(o.procedure4)) > 0)
      proc_cnt = (proc_cnt+ 1), stat = alterlist(proclist->qual,proc_cnt), proclist->qual[proc_cnt].
      idx = idx,
      proclist->qual[proc_cnt].element_name = "procedure4_id", proclist->qual[proc_cnt].
      source_identifier = trim(o.procedure4,3), proclist->qual[proc_cnt].nomenclature_id = 0,
      proclist->qual[proc_cnt].claim_dt_tm = hold->qual[idx].start_service_dt_tm, proclist->qual[
      proc_cnt].date_match_ind = 0, proclist->qual[proc_cnt].primary_system_ind = 0
     ENDIF
     IF (size(trim(o.procedure5)) > 0)
      proc_cnt = (proc_cnt+ 1), stat = alterlist(proclist->qual,proc_cnt), proclist->qual[proc_cnt].
      idx = idx,
      proclist->qual[proc_cnt].element_name = "procedure5_id", proclist->qual[proc_cnt].
      source_identifier = trim(o.procedure5,3), proclist->qual[proc_cnt].nomenclature_id = 0,
      proclist->qual[proc_cnt].claim_dt_tm = hold->qual[idx].start_service_dt_tm, proclist->qual[
      proc_cnt].date_match_ind = 0, proclist->qual[proc_cnt].primary_system_ind = 0
     ENDIF
     IF (size(trim(o.procedure6)) > 0)
      proc_cnt = (proc_cnt+ 1), stat = alterlist(proclist->qual,proc_cnt), proclist->qual[proc_cnt].
      idx = idx,
      proclist->qual[proc_cnt].element_name = "procedure6_id", proclist->qual[proc_cnt].
      source_identifier = trim(o.procedure6,3), proclist->qual[proc_cnt].nomenclature_id = 0,
      proclist->qual[proc_cnt].claim_dt_tm = hold->qual[idx].start_service_dt_tm, proclist->qual[
      proc_cnt].date_match_ind = 0, proclist->qual[proc_cnt].primary_system_ind = 0
     ENDIF
     IF (size(trim(o.procedure7)) > 0)
      proc_cnt = (proc_cnt+ 1), stat = alterlist(proclist->qual,proc_cnt), proclist->qual[proc_cnt].
      idx = idx,
      proclist->qual[proc_cnt].element_name = "procedure7_id", proclist->qual[proc_cnt].
      source_identifier = trim(o.procedure7,3), proclist->qual[proc_cnt].nomenclature_id = 0,
      proclist->qual[proc_cnt].claim_dt_tm = hold->qual[idx].start_service_dt_tm, proclist->qual[
      proc_cnt].date_match_ind = 0, proclist->qual[proc_cnt].primary_system_ind = 0
     ENDIF
     IF (size(trim(o.procedure8)) > 0)
      proc_cnt = (proc_cnt+ 1), stat = alterlist(proclist->qual,proc_cnt), proclist->qual[proc_cnt].
      idx = idx,
      proclist->qual[proc_cnt].element_name = "procedure8_id", proclist->qual[proc_cnt].
      source_identifier = trim(o.procedure8,3), proclist->qual[proc_cnt].nomenclature_id = 0,
      proclist->qual[proc_cnt].claim_dt_tm = hold->qual[idx].start_service_dt_tm, proclist->qual[
      proc_cnt].date_match_ind = 0, proclist->qual[proc_cnt].primary_system_ind = 0
     ENDIF
     IF (size(trim(o.procedure9)) > 0)
      proc_cnt = (proc_cnt+ 1), stat = alterlist(proclist->qual,proc_cnt), proclist->qual[proc_cnt].
      idx = idx,
      proclist->qual[proc_cnt].element_name = "procedure9_id", proclist->qual[proc_cnt].
      source_identifier = trim(o.procedure9,3), proclist->qual[proc_cnt].nomenclature_id = 0,
      proclist->qual[proc_cnt].claim_dt_tm = hold->qual[idx].start_service_dt_tm, proclist->qual[
      proc_cnt].date_match_ind = 0, proclist->qual[proc_cnt].primary_system_ind = 0
     ENDIF
     IF (size(trim(o.procedure10)) > 0)
      proc_cnt = (proc_cnt+ 1), stat = alterlist(proclist->qual,proc_cnt), proclist->qual[proc_cnt].
      idx = idx,
      proclist->qual[proc_cnt].element_name = "procedure10_id", proclist->qual[proc_cnt].
      source_identifier = trim(o.procedure10,3), proclist->qual[proc_cnt].nomenclature_id = 0,
      proclist->qual[proc_cnt].claim_dt_tm = hold->qual[idx].start_service_dt_tm, proclist->qual[
      proc_cnt].date_match_ind = 0, proclist->qual[proc_cnt].primary_system_ind = 0
     ENDIF
     IF (size(trim(o.diagnosis1)) > 0)
      diag_cnt = (diag_cnt+ 1), stat = alterlist(diaglist->qual,diag_cnt), diaglist->qual[diag_cnt].
      idx = idx,
      diaglist->qual[diag_cnt].element_name = "diagnosis1_id", diaglist->qual[diag_cnt].
      source_identifier = trim(o.diagnosis1,3), diaglist->qual[diag_cnt].nomenclature_id = 0,
      diaglist->qual[diag_cnt].claim_dt_tm = hold->qual[idx].start_service_dt_tm, diaglist->qual[
      diag_cnt].date_match_ind = 0, diaglist->qual[diag_cnt].primary_system_ind = 0
     ENDIF
     IF (size(trim(o.diagnosis2)) > 0)
      diag_cnt = (diag_cnt+ 1), stat = alterlist(diaglist->qual,diag_cnt), diaglist->qual[diag_cnt].
      idx = idx,
      diaglist->qual[diag_cnt].element_name = "diagnosis2_id", diaglist->qual[diag_cnt].
      source_identifier = trim(o.diagnosis2,3), diaglist->qual[diag_cnt].nomenclature_id = 0,
      diaglist->qual[diag_cnt].claim_dt_tm = hold->qual[idx].start_service_dt_tm, diaglist->qual[
      diag_cnt].date_match_ind = 0, diaglist->qual[diag_cnt].primary_system_ind = 0
     ENDIF
     IF (size(trim(o.diagnosis3)) > 0)
      diag_cnt = (diag_cnt+ 1), stat = alterlist(diaglist->qual,diag_cnt), diaglist->qual[diag_cnt].
      idx = idx,
      diaglist->qual[diag_cnt].element_name = "diagnosis3_id", diaglist->qual[diag_cnt].
      source_identifier = trim(o.diagnosis3,3), diaglist->qual[diag_cnt].nomenclature_id = 0,
      diaglist->qual[diag_cnt].claim_dt_tm = hold->qual[idx].start_service_dt_tm, diaglist->qual[
      diag_cnt].date_match_ind = 0, diaglist->qual[diag_cnt].primary_system_ind = 0
     ENDIF
     IF (size(trim(o.diagnosis4)) > 0)
      diag_cnt = (diag_cnt+ 1), stat = alterlist(diaglist->qual,diag_cnt), diaglist->qual[diag_cnt].
      idx = idx,
      diaglist->qual[diag_cnt].element_name = "diagnosis4_id", diaglist->qual[diag_cnt].
      source_identifier = trim(o.diagnosis4,3), diaglist->qual[diag_cnt].nomenclature_id = 0,
      diaglist->qual[diag_cnt].claim_dt_tm = hold->qual[idx].start_service_dt_tm, diaglist->qual[
      diag_cnt].date_match_ind = 0, diaglist->qual[diag_cnt].primary_system_ind = 0
     ENDIF
     IF (size(trim(o.diagnosis5)) > 0)
      diag_cnt = (diag_cnt+ 1), stat = alterlist(diaglist->qual,diag_cnt), diaglist->qual[diag_cnt].
      idx = idx,
      diaglist->qual[diag_cnt].element_name = "diagnosis5_id", diaglist->qual[diag_cnt].
      source_identifier = trim(o.diagnosis5,3), diaglist->qual[diag_cnt].nomenclature_id = 0,
      diaglist->qual[diag_cnt].claim_dt_tm = hold->qual[idx].start_service_dt_tm, diaglist->qual[
      diag_cnt].date_match_ind = 0, diaglist->qual[diag_cnt].primary_system_ind = 0
     ENDIF
     IF (size(trim(o.diagnosis6)) > 0)
      diag_cnt = (diag_cnt+ 1), stat = alterlist(diaglist->qual,diag_cnt), diaglist->qual[diag_cnt].
      idx = idx,
      diaglist->qual[diag_cnt].element_name = "diagnosis6_id", diaglist->qual[diag_cnt].
      source_identifier = trim(o.diagnosis6,3), diaglist->qual[diag_cnt].nomenclature_id = 0,
      diaglist->qual[diag_cnt].claim_dt_tm = hold->qual[idx].start_service_dt_tm, diaglist->qual[
      diag_cnt].date_match_ind = 0, diaglist->qual[diag_cnt].primary_system_ind = 0
     ENDIF
     IF (size(trim(o.diagnosis7)) > 0)
      diag_cnt = (diag_cnt+ 1), stat = alterlist(diaglist->qual,diag_cnt), diaglist->qual[diag_cnt].
      idx = idx,
      diaglist->qual[diag_cnt].element_name = "diagnosis7_id", diaglist->qual[diag_cnt].
      source_identifier = trim(o.diagnosis7,3), diaglist->qual[diag_cnt].nomenclature_id = 0,
      diaglist->qual[diag_cnt].claim_dt_tm = hold->qual[idx].start_service_dt_tm, diaglist->qual[
      diag_cnt].date_match_ind = 0, diaglist->qual[diag_cnt].primary_system_ind = 0
     ENDIF
     IF (size(trim(o.diagnosis8)) > 0)
      diag_cnt = (diag_cnt+ 1), stat = alterlist(diaglist->qual,diag_cnt), diaglist->qual[diag_cnt].
      idx = idx,
      diaglist->qual[diag_cnt].element_name = "diagnosis8_id", diaglist->qual[diag_cnt].
      source_identifier = trim(o.diagnosis8,3), diaglist->qual[diag_cnt].nomenclature_id = 0,
      diaglist->qual[diag_cnt].claim_dt_tm = hold->qual[idx].start_service_dt_tm, diaglist->qual[
      diag_cnt].date_match_ind = 0, diaglist->qual[diag_cnt].primary_system_ind = 0
     ENDIF
     IF (size(trim(o.diagnosis9)) > 0)
      diag_cnt = (diag_cnt+ 1), stat = alterlist(diaglist->qual,diag_cnt), diaglist->qual[diag_cnt].
      idx = idx,
      diaglist->qual[diag_cnt].element_name = "diagnosis9_id", diaglist->qual[diag_cnt].
      source_identifier = trim(o.diagnosis9,3), diaglist->qual[diag_cnt].nomenclature_id = 0,
      diaglist->qual[diag_cnt].claim_dt_tm = hold->qual[idx].start_service_dt_tm, diaglist->qual[
      diag_cnt].date_match_ind = 0, diaglist->qual[diag_cnt].primary_system_ind = 0
     ENDIF
     IF (size(trim(o.diagnosis10)) > 0)
      diag_cnt = (diag_cnt+ 1), stat = alterlist(diaglist->qual,diag_cnt), diaglist->qual[diag_cnt].
      idx = idx,
      diaglist->qual[diag_cnt].element_name = "diagnosis10_id", diaglist->qual[diag_cnt].
      source_identifier = trim(o.diagnosis10,3), diaglist->qual[diag_cnt].nomenclature_id = 0,
      diaglist->qual[diag_cnt].claim_dt_tm = hold->qual[idx].start_service_dt_tm, diaglist->qual[
      diag_cnt].date_match_ind = 0, diaglist->qual[diag_cnt].primary_system_ind = 0
     ENDIF
     IF (size(trim(o.diagnosis11)) > 0)
      diag_cnt = (diag_cnt+ 1), stat = alterlist(diaglist->qual,diag_cnt), diaglist->qual[diag_cnt].
      idx = idx,
      diaglist->qual[diag_cnt].element_name = "diagnosis11_id", diaglist->qual[diag_cnt].
      source_identifier = trim(o.diagnosis11,3), diaglist->qual[diag_cnt].nomenclature_id = 0,
      diaglist->qual[diag_cnt].claim_dt_tm = hold->qual[idx].start_service_dt_tm, diaglist->qual[
      diag_cnt].date_match_ind = 0, diaglist->qual[diag_cnt].primary_system_ind = 0
     ENDIF
     IF (size(trim(o.diagnosis12)) > 0)
      diag_cnt = (diag_cnt+ 1), stat = alterlist(diaglist->qual,diag_cnt), diaglist->qual[diag_cnt].
      idx = idx,
      diaglist->qual[diag_cnt].element_name = "diagnosis12_id", diaglist->qual[diag_cnt].
      source_identifier = trim(o.diagnosis12,3), diaglist->qual[diag_cnt].nomenclature_id = 0,
      diaglist->qual[diag_cnt].claim_dt_tm = hold->qual[idx].start_service_dt_tm, diaglist->qual[
      diag_cnt].date_match_ind = 0, diaglist->qual[diag_cnt].primary_system_ind = 0
     ENDIF
     IF (size(trim(o.diagnosis13)) > 0)
      diag_cnt = (diag_cnt+ 1), stat = alterlist(diaglist->qual,diag_cnt), diaglist->qual[diag_cnt].
      idx = idx,
      diaglist->qual[diag_cnt].element_name = "diagnosis13_id", diaglist->qual[diag_cnt].
      source_identifier = trim(o.diagnosis13,3), diaglist->qual[diag_cnt].nomenclature_id = 0,
      diaglist->qual[diag_cnt].claim_dt_tm = hold->qual[idx].start_service_dt_tm, diaglist->qual[
      diag_cnt].date_match_ind = 0, diaglist->qual[diag_cnt].primary_system_ind = 0
     ENDIF
     IF (size(trim(o.diagnosis14)) > 0)
      diag_cnt = (diag_cnt+ 1), stat = alterlist(diaglist->qual,diag_cnt), diaglist->qual[diag_cnt].
      idx = idx,
      diaglist->qual[diag_cnt].element_name = "diagnosis14_id", diaglist->qual[diag_cnt].
      source_identifier = trim(o.diagnosis14,3), diaglist->qual[diag_cnt].nomenclature_id = 0,
      diaglist->qual[diag_cnt].claim_dt_tm = hold->qual[idx].start_service_dt_tm, diaglist->qual[
      diag_cnt].date_match_ind = 0, diaglist->qual[diag_cnt].primary_system_ind = 0
     ENDIF
     IF (size(trim(o.diagnosis15)) > 0)
      diag_cnt = (diag_cnt+ 1), stat = alterlist(diaglist->qual,diag_cnt), diaglist->qual[diag_cnt].
      idx = idx,
      diaglist->qual[diag_cnt].element_name = "diagnosis15_id", diaglist->qual[diag_cnt].
      source_identifier = trim(o.diagnosis15,3), diaglist->qual[diag_cnt].nomenclature_id = 0,
      diaglist->qual[diag_cnt].claim_dt_tm = hold->qual[idx].start_service_dt_tm, diaglist->qual[
      diag_cnt].date_match_ind = 0, diaglist->qual[diag_cnt].primary_system_ind = 0
     ENDIF
    FOOT REPORT
     hold->qual_knt = idx, stat = alterlist(hold->qual,idx)
    WITH nocounter
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    CALL ags_set_status_block(eselect,efailure,"AGS_CLAIM_DATA",trim(serrmsg))
    GO TO exit_script
   ENDIF
   IF ((hold->qual_knt > 0))
    IF ((contrib_rec->qual_knt < 1))
     CALL ags_set_status_block(eattribute,efailure,"CONTRIBUTOR_SYSTEMS","contrib_rec->qual_knt < 1")
     GO TO exit_script
    ENDIF
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SELECT INTO "nl:"
     FROM code_value_alias cva,
      contributor_system cs,
      esi_alias_trans eat,
      (dummyt d  WITH seq = value(contrib_rec->qual_knt))
     PLAN (d
      WHERE (contrib_rec->qual[d.seq].contributor_system_cd < 1))
      JOIN (cva
      WHERE cva.code_set=89
       AND (cva.alias=contrib_rec->qual[d.seq].sending_facility)
       AND cva.contributor_source_cd=esi_default_cd)
      JOIN (cs
      WHERE cs.contributor_system_cd=cva.code_value
       AND cs.active_ind=1)
      JOIN (eat
      WHERE eat.contributor_system_cd=cs.contributor_system_cd
       AND eat.active_ind=1)
     HEAD cva.alias
      contrib_rec->qual[d.seq].sending_facility = cva.alias, contrib_rec->qual[d.seq].
      contributor_system_cd = cs.contributor_system_cd, contrib_rec->qual[d.seq].
      contributor_source_cd = cs.contributor_source_cd,
      contrib_rec->qual[d.seq].time_zone_flag = cs.time_zone_flag, contrib_rec->qual[d.seq].time_zone
       = cs.time_zone, contrib_rec->qual[d.seq].time_zone_idx = datetimezonebyname(contrib_rec->qual[
       d.seq].time_zone),
      contrib_rec->qual[d.seq].prsnl_person_id = cs.prsnl_person_id, contrib_rec->qual[d.seq].
      organization_id = cs.organization_id, found_ext_alias = false,
      found_ssn_alias = false, found_attend_doc_alias = false, found_admit_doc_alias = false,
      found_billing_org_alias = false, found_billing_prsnl_alias = false, found_billing_ext_alias =
      false
     DETAIL
      IF (found_ext_alias=false
       AND eat.esi_alias_field_cd=ext_alias_field_cd)
       found_ext_alias = true, contrib_rec->qual[d.seq].ext_alias_pool_cd = eat.alias_pool_cd,
       contrib_rec->qual[d.seq].ext_alias_type_cd = eat.alias_entity_alias_type_cd
      ENDIF
      IF (found_ssn_alias=false
       AND eat.esi_alias_field_cd=ssn_alias_field_cd)
       found_ssn_alias = true, contrib_rec->qual[d.seq].ssn_alias_pool_cd = eat.alias_pool_cd,
       contrib_rec->qual[d.seq].ssn_alias_type_cd = eat.alias_entity_alias_type_cd
      ENDIF
      IF (found_admit_doc_alias=false
       AND eat.esi_alias_field_cd=admit_doc_alias_field_cd)
       found_admit_doc_alias = true, contrib_rec->qual[d.seq].admit_doc_alias_pool_cd = eat
       .alias_pool_cd, contrib_rec->qual[d.seq].admit_doc_alias_type_cd = eat
       .alias_entity_alias_type_cd
      ENDIF
      IF (found_attend_doc_alias=false
       AND eat.esi_alias_field_cd=attend_doc_alias_field_cd)
       found_attend_doc_alias = true, contrib_rec->qual[d.seq].attend_doc_alias_pool_cd = eat
       .alias_pool_cd, contrib_rec->qual[d.seq].attend_doc_alias_type_cd = eat
       .alias_entity_alias_type_cd
      ENDIF
      IF (found_billing_org_alias=false
       AND eat.esi_alias_field_cd=billing_org_alias_field_cd)
       found_billing_org_alias = true, contrib_rec->qual[d.seq].billing_org_alias_pool_cd = eat
       .alias_pool_cd, contrib_rec->qual[d.seq].billing_org_alias_type_cd = eat
       .alias_entity_alias_type_cd,
       contrib_rec->qual[d.seq].billing_cva_alias_stamp = concat("~",trim(cnvtupper(cnvtalphanum(
           ags_get_code_display(eat.alias_pool_cd)))),"~",trim(cnvtupper(cnvtalphanum(
           ags_get_code_display(eat.alias_entity_alias_type_cd)))))
      ENDIF
      IF (found_billing_prsnl_alias=false
       AND eat.esi_alias_field_cd=billing_prsnl_alias_field_cd)
       found_billing_prsnl_alias = true, contrib_rec->qual[d.seq].billing_prsnl_alias_pool_cd = eat
       .alias_pool_cd, contrib_rec->qual[d.seq].billing_prsnl_alias_type_cd = eat
       .alias_entity_alias_type_cd
      ENDIF
     WITH nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     CALL ags_set_status_block(eselect,efailure,"CONTRIBUTOR_SYSTEMS",trim(serrmsg))
     GO TO exit_script
    ENDIF
    FOR (fidx = 1 TO hold->qual_knt)
      IF ((hold->qual[fidx].contrib_idx > 0))
       IF ((contrib_rec->qual[hold->qual[fidx].contrib_idx].contributor_system_cd < 1))
        SET hold->qual[fidx].contrib_idx = - (1)
        SET hold->qual[fidx].status = "F"
        SET hold->qual[fidx].stat_msg = concat(trim(hold->qual[fidx].stat_msg),"[contrib]")
        SET hold->qual[fidx].qual2_knt = (hold->qual[fidx].qual2_knt+ 1)
        SET stat = alterlist(hold->qual[fidx].qual2,hold->qual[fidx].qual2_knt)
        SET hold->qual[fidx].qual2[hold->qual[fidx].qual2_knt].elementcd = esendfacility
        SET hold->qual[fidx].qual2[hold->qual[fidx].qual2_knt].logcd = elookup
       ENDIF
      ENDIF
    ENDFOR
    CALL echorecord(contrib_rec)
    CALL ags_set_status_block(ecustom,einfo,"DATA ROWS",concat(trim(cnvtstring(hold->qual_knt)),
      " Rows Found For Processing"))
    CALL echo("***")
    CALL echo("***   EXT_ALIAS MATCH")
    CALL echo("***")
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(hold->qual_knt)),
      person_alias p
     PLAN (d
      WHERE (hold->qual[d.seq].ext_alias > " ")
       AND (hold->qual[d.seq].person_id=0)
       AND (hold->qual[d.seq].contrib_idx > 0))
      JOIN (p
      WHERE p.alias=trim(hold->qual[d.seq].ext_alias)
       AND (p.alias_pool_cd=contrib_rec->qual[hold->qual[d.seq].contrib_idx].ext_alias_pool_cd)
       AND (p.person_alias_type_cd=contrib_rec->qual[hold->qual[d.seq].contrib_idx].ext_alias_type_cd
      )
       AND p.active_ind=1)
     HEAD REPORT
      x = 1
     DETAIL
      hold->qual[d.seq].person_exists_ind = 1, hold->qual[d.seq].person_id = p.person_id, hold->qual[
      d.seq].ext_alias_exists_ind = 1,
      hold->qual[d.seq].ext_alias_person_alias_id = p.person_alias_id
     FOOT REPORT
      IF (curqual < 1)
       hold->qual[d.seq].qual2_knt = (hold->qual[d.seq].qual2_knt+ 1), stat = alterlist(hold->qual[d
        .seq].qual2,hold->qual[d.seq].qual2_knt), hold->qual[d.seq].qual2[hold->qual[d.seq].qual2_knt
       ].elementcd = eextalias,
       hold->qual[d.seq].qual2[hold->qual[d.seq].qual2_knt].logcd = elookup
      ENDIF
     WITH format, nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     CALL ags_set_status_block(eselect,efailure,"EXT_ALIAS",trim(serrmsg))
     GO TO exit_script
    ENDIF
    CALL echo("***")
    CALL echo("***   SSN MATCH")
    CALL echo("***")
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(hold->qual_knt)),
      person_alias p,
      person per
     PLAN (d
      WHERE (hold->qual[d.seq].person_id < 1)
       AND (hold->qual[d.seq].ssn_alias > " ")
       AND (hold->qual[d.seq].not_valid_ssn_chk=false)
       AND (hold->qual[d.seq].contrib_idx > 0))
      JOIN (p
      WHERE p.alias=trim(cnvtstring(cnvtint(hold->qual[d.seq].ssn_alias)))
       AND (p.alias_pool_cd=contrib_rec->qual[hold->qual[d.seq].contrib_idx].ssn_alias_pool_cd)
       AND (p.person_alias_type_cd=contrib_rec->qual[hold->qual[d.seq].contrib_idx].ssn_alias_type_cd
      )
       AND p.active_ind=1)
      JOIN (per
      WHERE per.person_id=p.person_id
       AND per.abs_birth_dt_tm=datetimezone(hold->qual[d.seq].birth_dt_tm,contrib_rec->qual[hold->
       qual[d.seq].contrib_idx].time_zone_idx,1)
       AND per.name_first_key=cnvtupper(cnvtalphanum(hold->qual[d.seq].name_first))
       AND per.name_last_key=cnvtupper(cnvtalphanum(hold->qual[d.seq].name_last))
       AND (per.sex_cd=hold->qual[d.seq].sex_cd))
     HEAD REPORT
      x = 1
     DETAIL
      hold->qual[d.seq].person_exists_ind = 1, hold->qual[d.seq].person_id = p.person_id, hold->qual[
      d.seq].ssn_alias_exists_ind = 1,
      hold->qual[d.seq].ssn_alias_person_alias_id = p.person_alias_id
     FOOT REPORT
      IF (curqual < 1)
       hold->qual[d.seq].qual2_knt = (hold->qual[d.seq].qual2_knt+ 1), stat = alterlist(hold->qual[d
        .seq].qual2,hold->qual[d.seq].qual2_knt), hold->qual[d.seq].qual2[hold->qual[d.seq].qual2_knt
       ].elementcd = essnalias,
       hold->qual[d.seq].qual2[hold->qual[d.seq].qual2_knt].logcd = elookup
      ENDIF
     WITH format, nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     CALL ags_set_status_block(eselect,efailure,"SSN_ALIAS",trim(serrmsg))
     GO TO exit_script
    ENDIF
    CALL echo("***")
    CALL echo("***   Personnel look-ups")
    CALL echo("***")
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SELECT INTO "nl:"
     FROM prsnl_alias pa,
      (dummyt d  WITH seq = value(hold->qual_knt))
     PLAN (d
      WHERE (hold->qual[d.seq].attending_person_id=0)
       AND (hold->qual[d.seq].attending_ext_alias > " ")
       AND (hold->qual[d.seq].contrib_idx > 0))
      JOIN (pa
      WHERE (pa.alias=hold->qual[d.seq].attending_ext_alias)
       AND (pa.alias_pool_cd=contrib_rec->qual[hold->qual[d.seq].contrib_idx].
      attend_doc_alias_pool_cd)
       AND (pa.prsnl_alias_type_cd=contrib_rec->qual[hold->qual[d.seq].contrib_idx].
      attend_doc_alias_type_cd)
       AND pa.active_ind=1)
     HEAD REPORT
      x = 1
     DETAIL
      hold->qual[d.seq].attending_person_id = pa.person_id
     FOOT REPORT
      IF (curqual < 1)
       hold->qual[d.seq].qual2_knt = (hold->qual[d.seq].qual2_knt+ 1), stat = alterlist(hold->qual[d
        .seq].qual2,hold->qual[d.seq].qual2_knt), hold->qual[d.seq].qual2[hold->qual[d.seq].qual2_knt
       ].elementcd = eperfextalias,
       hold->qual[d.seq].qual2[hold->qual[d.seq].qual2_knt].logcd = elookup
      ENDIF
     WITH nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     CALL ags_set_status_block(eselect,efailure,"ATTENDING_PRSNL",trim(serrmsg))
     GO TO exit_script
    ENDIF
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SELECT INTO "nl:"
     FROM prsnl_alias pa,
      (dummyt d  WITH seq = value(hold->qual_knt))
     PLAN (d
      WHERE (hold->qual[d.seq].admitting_person_id=0)
       AND (hold->qual[d.seq].admitting_ext_alias > " ")
       AND (hold->qual[d.seq].contrib_idx > 0))
      JOIN (pa
      WHERE (pa.alias=hold->qual[d.seq].admitting_ext_alias)
       AND (pa.alias_pool_cd=contrib_rec->qual[hold->qual[d.seq].contrib_idx].admit_doc_alias_pool_cd
      )
       AND (pa.prsnl_alias_type_cd=contrib_rec->qual[hold->qual[d.seq].contrib_idx].
      admit_doc_alias_type_cd)
       AND pa.active_ind=1)
     HEAD REPORT
      x = 1
     DETAIL
      hold->qual[d.seq].admitting_person_id = pa.person_id
     FOOT REPORT
      IF (curqual < 1)
       hold->qual[d.seq].qual2_knt = (hold->qual[d.seq].qual2_knt+ 1), stat = alterlist(hold->qual[d
        .seq].qual2,hold->qual[d.seq].qual2_knt), hold->qual[d.seq].qual2[hold->qual[d.seq].qual2_knt
       ].elementcd = eperfextalias,
       hold->qual[d.seq].qual2[hold->qual[d.seq].qual2_knt].logcd = elookup
      ENDIF
     WITH nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     CALL ags_set_status_block(eselect,efailure,"ADMITTING_PRSNL",trim(serrmsg))
     GO TO exit_script
    ENDIF
    CALL echo("***")
    CALL echo("***  BILLING PROVIDER")
    CALL echo("***")
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(hold->qual_knt)),
      prsnl_alias pa
     PLAN (d
      WHERE (hold->qual[d.seq].billing_provider_id=0)
       AND (hold->qual[d.seq].billing_ext_alias > " "))
      JOIN (pa
      WHERE (pa.alias=hold->qual[d.seq].billing_ext_alias)
       AND (pa.alias_pool_cd=contrib_rec->qual[hold->qual[d.seq].contrib_idx].
      billing_prsnl_alias_pool_cd)
       AND (pa.prsnl_alias_type_cd=contrib_rec->qual[hold->qual[d.seq].contrib_idx].
      billing_prsnl_alias_type_cd)
       AND pa.active_ind=1)
     HEAD REPORT
      x = 1
     DETAIL
      hold->qual[d.seq].billing_provider_id = pa.person_id
     FOOT REPORT
      IF (curqual < 1)
       hold->qual[d.seq].qual2_knt = (hold->qual[d.seq].qual2_knt+ 1), stat = alterlist(hold->qual[d
        .seq].qual2,hold->qual[d.seq].qual2_knt), hold->qual[d.seq].qual2[hold->qual[d.seq].qual2_knt
       ].elementcd = eperfextalias,
       hold->qual[d.seq].qual2[hold->qual[d.seq].qual2_knt].logcd = elookup
      ENDIF
     WITH nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     CALL ags_set_status_block(eselect,efailure,"PRSNL BILLING_EXT_ALIAS",trim(serrmsg))
     GO TO exit_script
    ENDIF
    IF (((create_orgs=true) OR (provider_dir_enabled=true)) )
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(hold->qual_knt)),
       organization_alias oa,
       location l
      PLAN (d
       WHERE (hold->qual[d.seq].billing_facility_cd=0)
        AND (hold->qual[d.seq].billing_org_id=0)
        AND (hold->qual[d.seq].billing_provider_id=0)
        AND (hold->qual[d.seq].billing_ext_alias > " ")
        AND (hold->qual[d.seq].contrib_idx > 0))
       JOIN (oa
       WHERE (oa.alias=hold->qual[d.seq].billing_ext_alias)
        AND (oa.alias_pool_cd=contrib_rec->qual[hold->qual[d.seq].contrib_idx].
       billing_org_alias_pool_cd)
        AND (oa.org_alias_type_cd=contrib_rec->qual[hold->qual[d.seq].contrib_idx].
       billing_org_alias_type_cd)
        AND oa.active_ind=1)
       JOIN (l
       WHERE l.organization_id=oa.organization_id
        AND l.location_type_cd=facility_loc_type_cd
        AND l.active_ind=1)
      HEAD REPORT
       x = 1
      DETAIL
       hold->qual[d.seq].billing_org_id = oa.organization_id, hold->qual[d.seq].billing_facility_cd
        = l.location_cd
      FOOT REPORT
       IF (curqual < 1)
        hold->qual[d.seq].qual2_knt = (hold->qual[d.seq].qual2_knt+ 1), stat = alterlist(hold->qual[d
         .seq].qual2,hold->qual[d.seq].qual2_knt), hold->qual[d.seq].qual2[hold->qual[d.seq].
        qual2_knt].elementcd = eperfextalias,
        hold->qual[d.seq].qual2[hold->qual[d.seq].qual2_knt].logcd = elookup
       ENDIF
      WITH nocounter
     ;end select
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      CALL ags_set_status_block(eselect,efailure,"ORG BILLING_EXT_ALIAS",trim(serrmsg))
      GO TO exit_script
     ENDIF
    ELSE
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(hold->qual_knt)),
       code_value_alias cva
      PLAN (d
       WHERE (hold->qual[d.seq].billing_facility_cd=0)
        AND (hold->qual[d.seq].billing_provider_id=0)
        AND (hold->qual[d.seq].billing_ext_alias > " ")
        AND (hold->qual[d.seq].contrib_idx > 0))
       JOIN (cva
       WHERE operator(cva.alias,"LIKE",patstring(concat(trim(hold->qual[d.seq].billing_ext_alias),
          trim(contrib_rec->qual[hold->qual[d.seq].contrib_idx].billing_cva_alias_stamp),"*"),1))
        AND ((cva.code_set+ 0)=220)
        AND ((cva.contributor_source_cd+ 0)=contrib_rec->qual[hold->qual[d.seq].contrib_idx].
       contributor_source_cd)
        AND cva.alias_type_meaning="ORGEXTALIAS")
      HEAD REPORT
       x = 1
      DETAIL
       hold->qual[d.seq].billing_facility_cd = cva.code_value
      FOOT REPORT
       IF (curqual < 1)
        hold->qual[d.seq].qual2_knt = (hold->qual[d.seq].qual2_knt+ 1), stat = alterlist(hold->qual[d
         .seq].qual2,hold->qual[d.seq].qual2_knt), hold->qual[d.seq].qual2[hold->qual[d.seq].
        qual2_knt].elementcd = eperfextalias,
        hold->qual[d.seq].qual2[hold->qual[d.seq].qual2_knt].logcd = elookup
       ENDIF
      WITH nocounter
     ;end select
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      CALL ags_set_status_block(eselect,efailure,"BILLING_FACILITY_CD",trim(serrmsg))
      GO TO exit_script
     ENDIF
    ENDIF
    CALL echo("***")
    CALL echo("***  PLACE OF SERVICE")
    CALL echo("***")
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(hold->qual_knt)),
      code_value_alias cva
     PLAN (d
      WHERE (hold->qual[d.seq].visit_type > " "))
      JOIN (cva
      WHERE (cva.alias=hold->qual[d.seq].visit_type)
       AND cva.code_set=4001892
       AND cva.contributor_source_cd=cernerchr_contributor_source_cd)
     DETAIL
      hold->qual[d.seq].visit_type_cd = cva.code_value
     WITH nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     CALL ags_set_status_block(eselect,efailure,"PLACE_OF_SERVICE",trim(serrmsg))
     GO TO exit_script
    ENDIF
    CALL echo("***")
    CALL echo("***  PLACE OF SERVICE 2")
    CALL echo("***")
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(hold->qual_knt)),
      code_value_alias cva
     PLAN (d
      WHERE (hold->qual[d.seq].visit_type_cd=0)
       AND (hold->qual[d.seq].visit_type > " "))
      JOIN (cva
      WHERE (cva.alias=hold->qual[d.seq].visit_type)
       AND cva.code_set=4001892
       AND (cva.contributor_source_cd=contrib_rec->qual[hold->qual[d.seq].contrib_idx].
      contributor_source_cd))
     DETAIL
      hold->qual[d.seq].visit_type_cd = cva.code_value
     WITH nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     CALL ags_set_status_block(eselect,efailure,"PLACE_OF_SERVICE 2",trim(serrmsg))
     GO TO exit_script
    ENDIF
    FOR (temp_i = 1 TO hold->qual_knt)
      IF ((hold->qual[temp_i].visit_type_cd=0))
       SET hold->qual[temp_i].visit_type_cd = visit_type_default_cd
       SET hold->qual[temp_i].stat_msg = concat(trim(hold->qual[temp_i].stat_msg),"[w-visittype]")
       SET hold->qual[temp_i].qual2_knt = (hold->qual[temp_i].qual2_knt+ 1)
       SET stat = alterlist(hold->qual[temp_i].qual2,hold->qual[temp_i].qual2_knt)
       SET hold->qual[temp_i].qual2[hold->qual[temp_i].qual2_knt].elementcd = eplaceofserv
       SET hold->qual[temp_i].qual2[hold->qual[temp_i].qual2_knt].logcd = elookup
      ENDIF
    ENDFOR
    CALL echo("***")
    CALL echo("***   NOMENCLATURE - PROCEDURE")
    CALL echo("***")
    IF (proc_cnt > 0)
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     SELECT INTO "nl:"
      order_seq = evaluate(n.contributor_system_cd,contrib_rec->qual[hold->qual[proclist->qual[d.seq]
       .idx].contrib_idx].contributor_system_cd,1,job_contributor_system_cd,2,
       ama_contributor_system_cd,3,hcfa_contributor_system_cd,3)
      FROM nomenclature n,
       (dummyt d  WITH seq = value(proc_cnt))
      PLAN (d
       WHERE (proclist->qual[d.seq].nomenclature_id=0))
       JOIN (n
       WHERE n.source_vocabulary_cd IN (cpt4_source_voc_cd, hcpcs_source_voc_cd)
        AND (n.source_identifier=proclist->qual[d.seq].source_identifier)
        AND ((n.active_ind+ 0)=1)
        AND ((n.contributor_system_cd+ 0) IN (ama_contributor_system_cd, hcfa_contributor_system_cd,
       job_contributor_system_cd, contrib_rec->qual[hold->qual[proclist->qual[d.seq].idx].contrib_idx
       ].contributor_system_cd)))
      ORDER BY d.seq, order_seq, n.beg_effective_dt_tm,
       n.end_effective_dt_tm
      FOOT  d.seq
       proclist->qual[d.seq].nomenclature_id = n.nomenclature_id
      WITH nocounter
     ;end select
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      CALL ags_set_status_block(eselect,efailure,"PROCEDURE",trim(serrmsg))
      GO TO exit_script
     ENDIF
     FOR (temp_i = 1 TO proc_cnt)
       SET cur_index = proclist->qual[temp_i].idx
       IF ((proclist->qual[temp_i].element_name="procedure1_id"))
        SET hold->qual[cur_index].procedure1_id = proclist->qual[temp_i].nomenclature_id
       ELSEIF ((proclist->qual[temp_i].element_name="procedure2_id"))
        SET hold->qual[cur_index].procedure2_id = proclist->qual[temp_i].nomenclature_id
       ELSEIF ((proclist->qual[temp_i].element_name="procedure3_id"))
        SET hold->qual[cur_index].procedure3_id = proclist->qual[temp_i].nomenclature_id
       ELSEIF ((proclist->qual[temp_i].element_name="procedure4_id"))
        SET hold->qual[cur_index].procedure4_id = proclist->qual[temp_i].nomenclature_id
       ELSEIF ((proclist->qual[temp_i].element_name="procedure5_id"))
        SET hold->qual[cur_index].procedure5_id = proclist->qual[temp_i].nomenclature_id
       ELSEIF ((proclist->qual[temp_i].element_name="procedure6_id"))
        SET hold->qual[cur_index].procedure6_id = proclist->qual[temp_i].nomenclature_id
       ELSEIF ((proclist->qual[temp_i].element_name="procedure7_id"))
        SET hold->qual[cur_index].procedure7_id = proclist->qual[temp_i].nomenclature_id
       ELSEIF ((proclist->qual[temp_i].element_name="procedure8_id"))
        SET hold->qual[cur_index].procedure8_id = proclist->qual[temp_i].nomenclature_id
       ELSEIF ((proclist->qual[temp_i].element_name="procedure9_id"))
        SET hold->qual[cur_index].procedure9_id = proclist->qual[temp_i].nomenclature_id
       ELSEIF ((proclist->qual[temp_i].element_name="procedure10_id"))
        SET hold->qual[cur_index].procedure10_id = proclist->qual[temp_i].nomenclature_id
       ENDIF
       IF ((proclist->qual[temp_i].nomenclature_id=0))
        SET hold->qual[cur_index].qual2_knt = (hold->qual[cur_index].qual2_knt+ 1)
        SET stat = alterlist(hold->qual[cur_index].qual2,hold->qual[cur_index].qual2_knt)
        SET hold->qual[cur_index].qual2[hold->qual[cur_index].qual2_knt].elementcd = eprocnomen
        SET hold->qual[cur_index].qual2[hold->qual[cur_index].qual2_knt].logcd = elookup
       ENDIF
     ENDFOR
    ENDIF
    CALL echo("***")
    CALL echo("***   NOMENCLATURE - DIAGNOSIS")
    CALL echo("***")
    IF (diag_cnt > 0)
     SET ierrcode = error(serrmsg,1)
     SET ierrcode = 0
     SELECT INTO "nl:"
      order_seq = evaluate(n.contributor_system_cd,contrib_rec->qual[hold->qual[diaglist->qual[d.seq]
       .idx].contrib_idx].contributor_system_cd,1,job_contributor_system_cd,2,
       ama_contributor_system_cd,3,hcfa_contributor_system_cd,3,umls_contributor_system_cd,
       3)
      FROM nomenclature n,
       (dummyt d  WITH seq = value(diag_cnt))
      PLAN (d
       WHERE (diaglist->qual[d.seq].nomenclature_id=0))
       JOIN (n
       WHERE n.source_vocabulary_cd=icd9_source_voc_cd
        AND (n.source_identifier=diaglist->qual[d.seq].source_identifier)
        AND ((n.active_ind+ 0)=1)
        AND ((n.contributor_system_cd+ 0) IN (ama_contributor_system_cd, hcfa_contributor_system_cd,
       umls_contributor_system_cd, job_contributor_system_cd, contrib_rec->qual[hold->qual[diaglist->
       qual[d.seq].idx].contrib_idx].contributor_system_cd)))
      ORDER BY d.seq, order_seq, n.beg_effective_dt_tm,
       n.end_effective_dt_tm
      FOOT  d.seq
       diaglist->qual[d.seq].nomenclature_id = n.nomenclature_id
      WITH nocounter
     ;end select
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      CALL ags_set_status_block(eselect,efailure,"DIAGNOSIS",trim(serrmsg))
      GO TO exit_script
     ENDIF
     FOR (temp_i = 1 TO diag_cnt)
       SET cur_index = diaglist->qual[temp_i].idx
       IF ((diaglist->qual[temp_i].element_name="diagnosis1_id"))
        SET hold->qual[cur_index].diagnosis1_id = diaglist->qual[temp_i].nomenclature_id
       ELSEIF ((diaglist->qual[temp_i].element_name="diagnosis2_id"))
        SET hold->qual[cur_index].diagnosis2_id = diaglist->qual[temp_i].nomenclature_id
       ELSEIF ((diaglist->qual[temp_i].element_name="diagnosis3_id"))
        SET hold->qual[cur_index].diagnosis3_id = diaglist->qual[temp_i].nomenclature_id
       ELSEIF ((diaglist->qual[temp_i].element_name="diagnosis4_id"))
        SET hold->qual[cur_index].diagnosis4_id = diaglist->qual[temp_i].nomenclature_id
       ELSEIF ((diaglist->qual[temp_i].element_name="diagnosis5_id"))
        SET hold->qual[cur_index].diagnosis5_id = diaglist->qual[temp_i].nomenclature_id
       ELSEIF ((diaglist->qual[temp_i].element_name="diagnosis6_id"))
        SET hold->qual[cur_index].diagnosis6_id = diaglist->qual[temp_i].nomenclature_id
       ELSEIF ((diaglist->qual[temp_i].element_name="diagnosis7_id"))
        SET hold->qual[cur_index].diagnosis7_id = diaglist->qual[temp_i].nomenclature_id
       ELSEIF ((diaglist->qual[temp_i].element_name="diagnosis8_id"))
        SET hold->qual[cur_index].diagnosis8_id = diaglist->qual[temp_i].nomenclature_id
       ELSEIF ((diaglist->qual[temp_i].element_name="diagnosis9_id"))
        SET hold->qual[cur_index].diagnosis9_id = diaglist->qual[temp_i].nomenclature_id
       ELSEIF ((diaglist->qual[temp_i].element_name="diagnosis10_id"))
        SET hold->qual[cur_index].diagnosis10_id = diaglist->qual[temp_i].nomenclature_id
       ELSEIF ((diaglist->qual[temp_i].element_name="diagnosis11_id"))
        SET hold->qual[cur_index].diagnosis11_id = diaglist->qual[temp_i].nomenclature_id
       ELSEIF ((diaglist->qual[temp_i].element_name="diagnosis12_id"))
        SET hold->qual[cur_index].diagnosis12_id = diaglist->qual[temp_i].nomenclature_id
       ELSEIF ((diaglist->qual[temp_i].element_name="diagnosis13_id"))
        SET hold->qual[cur_index].diagnosis13_id = diaglist->qual[temp_i].nomenclature_id
       ELSEIF ((diaglist->qual[temp_i].element_name="diagnosis14_id"))
        SET hold->qual[cur_index].diagnosis14_id = diaglist->qual[temp_i].nomenclature_id
       ELSEIF ((diaglist->qual[temp_i].element_name="diagnosis15_id"))
        SET hold->qual[cur_index].diagnosis15_id = diaglist->qual[temp_i].nomenclature_id
       ENDIF
       IF ((diaglist->qual[temp_i].nomenclature_id=0))
        SET hold->qual[cur_index].qual2_knt = (hold->qual[cur_index].qual2_knt+ 1)
        SET stat = alterlist(hold->qual[cur_index].qual2,hold->qual[cur_index].qual2_knt)
        SET hold->qual[cur_index].qual2[hold->qual[cur_index].qual2_knt].elementcd = ediagnomen
        SET hold->qual[cur_index].qual2[hold->qual[cur_index].qual2_knt].logcd = elookup
       ENDIF
     ENDFOR
    ENDIF
    FOR (temp_i = 1 TO hold->qual_knt)
      IF ((hold->qual[temp_i].person_id < 1))
       SET hold->qual[temp_i].contrib_idx = - (1)
       SET hold->qual[temp_i].status = "F"
       SET hold->qual[temp_i].stat_msg = concat(trim(hold->qual[temp_i].stat_msg),"[mrn]")
      ENDIF
      IF ((hold->qual[temp_i].diagnosis1 > "")
       AND (hold->qual[temp_i].diagnosis1_id=0))
       SET hold->qual[temp_i].contrib_idx = - (1)
       SET hold->qual[temp_i].status = "F"
       SET hold->qual[temp_i].stat_msg = concat(trim(hold->qual[temp_i].stat_msg),"[diagid]")
       SET hold->qual[cur_index].qual2_knt = (hold->qual[cur_index].qual2_knt+ 1)
       SET stat = alterlist(hold->qual[cur_index].qual2,hold->qual[cur_index].qual2_knt)
       SET hold->qual[cur_index].qual2[hold->qual[cur_index].qual2_knt].elementcd = ediagnomen
       SET hold->qual[cur_index].qual2[hold->qual[cur_index].qual2_knt].logcd = emissing
      ENDIF
      SET temp_level = eerrorlevel
      IF ((hold->qual[temp_i].person_id > 0)
       AND (hold->qual[temp_i].contrib_idx > 0))
       SET temp_level = ewarninglevel
      ENDIF
      FOR (temp_j = 1 TO hold->qual[temp_i].qual2_knt)
        CALL ags_log_msg(temp_level,hold->qual[temp_i].ags_claim_data_id,eclaimload,hold->qual[temp_i
         ].qual2[temp_j].logcd,hold->qual[temp_i].qual2[temp_j].elementcd,
         "")
      ENDFOR
      IF ((hold->qual[temp_i].contrib_idx > 0))
       SELECT INTO "nl:"
        FROM hea_claim_visit c
        WHERE c.claim_identifier=trim(hold->qual[temp_i].claim_identifier)
        DETAIL
         hold->qual[temp_i].hea_claim_visit_id = c.hea_claim_visit_id
        WITH nocounter
       ;end select
       SET contrib_rec_size = size(contrib_rec->qual,5)
       FOR (z = 1 TO contrib_rec_size)
         IF ((contrib_rec->qual[z].sending_facility=hold->qual[temp_i].sending_facility))
          SET hold->qual[temp_i].contributor_system_cd = contrib_rec->qual[z].contributor_system_cd
          SET hold->qual[temp_i].prsnl_person_id = contrib_rec->qual[z].prsnl_person_id
         ENDIF
       ENDFOR
       IF ((hold->qual[temp_i].hea_claim_visit_id=0))
        SELECT INTO "nl:"
         y = seq(hea_seq,nextval)"##################;rp0"
         FROM dual
         DETAIL
          hold->qual[temp_i].hea_claim_visit_id = cnvtreal(y)
         WITH format, nocounter
        ;end select
        CALL echo("***")
        CALL echo("*** Doing insert HEA_CLAIM_VISIT")
        CALL echo("***")
        INSERT  FROM hea_claim_visit c
         SET c.hea_claim_visit_id = hold->qual[temp_i].hea_claim_visit_id, c.claim_identifier = hold
          ->qual[temp_i].claim_identifier, c.visit_type_cd = hold->qual[temp_i].visit_type_cd,
          c.start_service_dt_tm = cnvtdatetime(hold->qual[temp_i].start_service_dt_tm), c
          .end_service_dt_tm = cnvtdatetime(hold->qual[temp_i].end_service_dt_tm), c
          .attending_person_id = hold->qual[temp_i].attending_person_id,
          c.admitting_person_id = hold->qual[temp_i].admitting_person_id, c.procedure1_id = hold->
          qual[temp_i].procedure1_id, c.procedure2_id = hold->qual[temp_i].procedure2_id,
          c.procedure3_id = hold->qual[temp_i].procedure3_id, c.procedure4_id = hold->qual[temp_i].
          procedure4_id, c.procedure5_id = hold->qual[temp_i].procedure5_id,
          c.procedure6_id = hold->qual[temp_i].procedure6_id, c.procedure7_id = hold->qual[temp_i].
          procedure7_id, c.procedure8_id = hold->qual[temp_i].procedure8_id,
          c.procedure9_id = hold->qual[temp_i].procedure9_id, c.procedure10_id = hold->qual[temp_i].
          procedure10_id, c.diagnosis1_id = hold->qual[temp_i].diagnosis1_id,
          c.diagnosis2_id = hold->qual[temp_i].diagnosis2_id, c.diagnosis3_id = hold->qual[temp_i].
          diagnosis3_id, c.diagnosis4_id = hold->qual[temp_i].diagnosis4_id,
          c.diagnosis5_id = hold->qual[temp_i].diagnosis5_id, c.diagnosis6_id = hold->qual[temp_i].
          diagnosis6_id, c.diagnosis7_id = hold->qual[temp_i].diagnosis7_id,
          c.diagnosis8_id = hold->qual[temp_i].diagnosis8_id, c.diagnosis9_id = hold->qual[temp_i].
          diagnosis9_id, c.diagnosis10_id = hold->qual[temp_i].diagnosis10_id,
          c.diagnosis11_id = hold->qual[temp_i].diagnosis11_id, c.diagnosis12_id = hold->qual[temp_i]
          .diagnosis12_id, c.diagnosis13_id = hold->qual[temp_i].diagnosis13_id,
          c.diagnosis14_id = hold->qual[temp_i].diagnosis14_id, c.diagnosis15_id = hold->qual[temp_i]
          .diagnosis15_id, c.billing_provider_id = hold->qual[temp_i].billing_provider_id,
          c.billing_facility_cd = hold->qual[temp_i].billing_facility_cd, c.billing_org_id = hold->
          qual[temp_i].billing_org_id, c.person_id = hold->qual[temp_i].person_id,
          c.updt_dt_tm = cnvtdatetime(current_dt_tm), c.updt_id = hold->qual[temp_i].prsnl_person_id,
          c.updt_task = 424990,
          c.updt_cnt = 0, c.updt_applctx = 424990, c.data_status_cd = auth_data_status_cd,
          c.data_status_dt_tm = cnvtdatetime(current_dt_tm), c.data_status_prsnl_id = hold->qual[
          temp_i].prsnl_person_id, c.contributor_system_cd = hold->qual[temp_i].contributor_system_cd,
          c.active_ind = 1, c.active_status_cd = active_active_status_cd, c.active_status_prsnl_id =
          hold->qual[temp_i].prsnl_person_id,
          c.active_status_dt_tm = cnvtdatetime(current_dt_tm), c.beg_effective_dt_tm = cnvtdatetime(
           current_dt_tm), c.end_effective_dt_tm = cnvtdatetime(max_date)
         WITH nocounter
        ;end insert
        SET ierrcode = error(serrmsg,1)
        IF (ierrcode > 0)
         CALL ags_set_status_block(einsert,efailure,"INSERT HEA_CLAIM_VISIT",trim(serrmsg))
         GO TO exit_script
        ENDIF
       ELSEIF ((hold->qual[temp_i].hea_claim_visit_id > 0))
        IF (cnvtint(hold->qual[temp_i].action) > 0)
         CALL echo("***")
         CALL echo("*** Doing update HEA_CLAIM_VISIT")
         CALL echo("***")
         UPDATE  FROM hea_claim_visit c
          SET c.claim_identifier = hold->qual[temp_i].claim_identifier, c.visit_type_cd = hold->qual[
           temp_i].visit_type_cd, c.start_service_dt_tm = cnvtdatetime(hold->qual[temp_i].
            start_service_dt_tm),
           c.end_service_dt_tm = cnvtdatetime(hold->qual[temp_i].end_service_dt_tm), c
           .attending_person_id = hold->qual[temp_i].attending_person_id, c.admitting_person_id =
           hold->qual[temp_i].admitting_person_id,
           c.procedure1_id = hold->qual[temp_i].procedure1_id, c.procedure2_id = hold->qual[temp_i].
           procedure2_id, c.procedure3_id = hold->qual[temp_i].procedure3_id,
           c.procedure4_id = hold->qual[temp_i].procedure4_id, c.procedure5_id = hold->qual[temp_i].
           procedure5_id, c.procedure6_id = hold->qual[temp_i].procedure6_id,
           c.procedure7_id = hold->qual[temp_i].procedure7_id, c.procedure8_id = hold->qual[temp_i].
           procedure8_id, c.procedure9_id = hold->qual[temp_i].procedure9_id,
           c.procedure10_id = hold->qual[temp_i].procedure10_id, c.diagnosis1_id = hold->qual[temp_i]
           .diagnosis1_id, c.diagnosis2_id = hold->qual[temp_i].diagnosis2_id,
           c.diagnosis3_id = hold->qual[temp_i].diagnosis3_id, c.diagnosis4_id = hold->qual[temp_i].
           diagnosis4_id, c.diagnosis5_id = hold->qual[temp_i].diagnosis5_id,
           c.diagnosis6_id = hold->qual[temp_i].diagnosis6_id, c.diagnosis7_id = hold->qual[temp_i].
           diagnosis7_id, c.diagnosis8_id = hold->qual[temp_i].diagnosis8_id,
           c.diagnosis9_id = hold->qual[temp_i].diagnosis9_id, c.diagnosis10_id = hold->qual[temp_i].
           diagnosis10_id, c.diagnosis11_id = hold->qual[temp_i].diagnosis11_id,
           c.diagnosis12_id = hold->qual[temp_i].diagnosis12_id, c.diagnosis13_id = hold->qual[temp_i
           ].diagnosis13_id, c.diagnosis14_id = hold->qual[temp_i].diagnosis14_id,
           c.diagnosis15_id = hold->qual[temp_i].diagnosis15_id, c.billing_provider_id = hold->qual[
           temp_i].billing_provider_id, c.billing_facility_cd = hold->qual[temp_i].
           billing_facility_cd,
           c.billing_org_id = hold->qual[temp_i].billing_org_id, c.person_id = hold->qual[temp_i].
           person_id, c.updt_dt_tm = cnvtdatetime(current_dt_tm),
           c.updt_id = hold->qual[temp_i].prsnl_person_id, c.updt_task = 424990, c.updt_cnt = (c
           .updt_cnt+ 1),
           c.updt_applctx = 424990, c.data_status_cd = auth_data_status_cd, c.data_status_dt_tm =
           cnvtdatetime(current_dt_tm),
           c.data_status_prsnl_id = hold->qual[temp_i].prsnl_person_id, c.contributor_system_cd =
           hold->qual[temp_i].contributor_system_cd, c.active_ind = 1,
           c.active_status_cd = active_active_status_cd, c.active_status_prsnl_id = hold->qual[temp_i
           ].prsnl_person_id, c.active_status_dt_tm = cnvtdatetime(current_dt_tm),
           c.end_effective_dt_tm = cnvtdatetime(max_date)
          WHERE (c.hea_claim_visit_id=hold->qual[temp_i].hea_claim_visit_id)
           AND working_mode != 2
          WITH nocounter
         ;end update
         SET ierrcode = error(serrmsg,1)
         IF (ierrcode > 0)
          CALL ags_set_status_block(eupdate,efailure,"UPDATE HEA_CLAIM_VISIT",trim(serrmsg))
          GO TO exit_script
         ENDIF
        ELSEIF (cnvtint(hold->qual[temp_i].action) < 1)
         CALL echo("***")
         CALL echo("*** Doing update HEA_CLAIM_VISIT")
         CALL echo("***")
         UPDATE  FROM hea_claim_visit c
          SET c.active_ind = 0, c.active_status_cd = active_active_status_cd, c
           .active_status_prsnl_id = hold->qual[temp_i].prsnl_person_id,
           c.active_status_dt_tm = cnvtdatetime(current_dt_tm), c.end_effective_dt_tm = cnvtdatetime(
            current_dt_tm)
          WHERE (c.hea_claim_visit_id=hold->qual[temp_i].hea_claim_visit_id)
           AND working_mode != 2
          WITH nocounter
         ;end update
         SET ierrcode = error(serrmsg,1)
         IF (ierrcode > 0)
          CALL ags_set_status_block(eupdate,efailure,"UPDATE HEA_CLAIM_VISIT INACTIVATE",trim(serrmsg
            ))
          GO TO exit_script
         ENDIF
        ENDIF
       ENDIF
      ENDIF
    ENDFOR
    CALL echo("***")
    CALL echo("***   Update Data to Complete")
    CALL echo("***")
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    UPDATE  FROM ags_claim_data o,
      (dummyt d  WITH seq = value(hold->qual_knt))
     SET o.status = "COMPLETE", o.stat_msg = "", o.status_dt_tm = cnvtdatetime(dates->now_dt_tm),
      o.person_id = hold->qual[d.seq].person_id, o.hea_claim_visit_id = hold->qual[d.seq].
      hea_claim_visit_id, o.contributor_system_cd = contrib_rec->qual[hold->qual[d.seq].contrib_idx].
      contributor_system_cd
     PLAN (d
      WHERE (hold->qual[d.seq].ags_claim_data_id > 0)
       AND (hold->qual[d.seq].contrib_idx > 0))
      JOIN (o
      WHERE (o.ags_claim_data_id=hold->qual[d.seq].ags_claim_data_id))
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     CALL ags_set_status_block(eupdate,efailure,"CLAIM_DATA COMPLETE",trim(serrmsg))
     GO TO exit_script
    ENDIF
    COMMIT
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    UPDATE  FROM ags_claim_data o,
      (dummyt d  WITH seq = value(hold->qual_knt))
     SET o.status = "IN ERROR", o.status_dt_tm = cnvtdatetime(curdate,curtime3), o.stat_msg = trim(
       substring(1,40,hold->qual[d.seq].stat_msg))
     PLAN (d
      WHERE (hold->qual[d.seq].contrib_idx < 1))
      JOIN (o
      WHERE (o.ags_claim_data_id=hold->qual[d.seq].ags_claim_data_id))
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     CALL ags_set_status_block(eupdate,efailure,"CLAIM_DATA IN ERROR",trim(serrmsg))
     GO TO exit_script
    ENDIF
    COMMIT
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    UPDATE  FROM hea_claim_visit c,
      (dummyt d  WITH seq = value(hold->qual_knt))
     SET c.active_ind = 0, c.active_status_cd = inactive_active_status_cd, c.active_status_dt_tm =
      cnvtdatetime(dates->now_dt_tm),
      c.active_status_prsnl_id = hold->qual[d.seq].prsnl_person_id
     PLAN (d
      WHERE (hold->qual[d.seq].prev_claim_identifier > " ")
       AND (hold->qual[d.seq].status != "F")
       AND (hold->qual[d.seq].contrib_idx > 0))
      JOIN (c
      WHERE (c.claim_identifier=hold->qual[d.seq].prev_claim_identifier)
       AND (c.contributor_system_cd=contrib_rec->qual[hold->qual[d.seq].contrib_idx].
      contributor_system_cd))
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     CALL ags_set_status_block(eupdate,efailure,"INACTIVE CLAIM_DATA COMPLETE",trim(serrmsg))
     GO TO exit_script
    ENDIF
    COMMIT
   ELSE
    CALL ags_set_status_block(ecustom,einfo,"DATA ROWS","No Rows Found For Processing")
   ENDIF
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   SELECT INTO "nl:"
    FROM ags_task t
    PLAN (t
     WHERE t.ags_task_id=working_task_id)
    DETAIL
     working_kill_ind = t.kill_ind
    WITH nocounter
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    CALL ags_set_status_block(eselect,efailure,"KILL_IND",trim(serrmsg))
    GO TO exit_script
   ENDIF
   SET dates->it_end_dt_tm = cnvtdatetime(curdate,curtime3)
   SET it_avg = 0
   IF ((hold->qual_knt > 0))
    SET it_avg = (cnvtreal(hold->qual_knt)/ datetimediff(dates->it_end_dt_tm,dates->now_dt_tm,5))
   ENDIF
   IF (it_avg > 0)
    SET dates->it_est_end_dt_tm = cnvtlookahead(concat(cnvtstring(ceil((cnvtreal(((max_data_id -
         end_data_id)+ 1))/ it_avg))),",S"),dates->it_end_dt_tm)
   ENDIF
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   UPDATE  FROM ags_task t
    SET t.iteration_start_id = beg_data_id, t.iteration_end_id = end_data_id, t.iteration_count =
     hold->qual_knt,
     t.iteration_start_dt_tm = cnvtdatetime(dates->now_dt_tm), t.iteration_end_dt_tm = cnvtdatetime(
      dates->it_end_dt_tm), t.iteration_average = it_avg,
     t.est_completion_dt_tm = cnvtdatetime(dates->it_est_end_dt_tm)
    PLAN (t
     WHERE t.ags_task_id=working_task_id)
    WITH nocounter
   ;end update
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    CALL ags_set_status_block(eupdate,efailure,"ITERATION",trim(serrmsg))
    GO TO exit_script
   ENDIF
   COMMIT
   CALL ags_set_status_block(ecustom,einfo,"END PROCESSING",concat("BEG_DATA_ID :: ",trim(cnvtstring(
       beg_data_id))," :: END_DATA_ID :: ",trim(cnvtstring(end_data_id))," :: MAX_DATA_ID :: ",
     trim(cnvtstring(max_data_id))))
   SET beg_data_id = (end_data_id+ 1)
   IF (((beg_data_id+ data_size) > max_data_id))
    SET end_data_id = max_data_id
   ELSE
    SET end_data_id = ((beg_data_id+ data_size) - 1)
   ENDIF
 ENDWHILE
 IF (working_task_id > 0
  AND working_kill_ind < 1)
  CALL echo("***")
  CALL echo("***   Update Task to Complete")
  CALL echo("***")
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  UPDATE  FROM ags_task t
   SET t.status = "COMPLETE", t.status_dt_tm = cnvtdatetime(curdate,curtime3), t.batch_end_dt_tm =
    cnvtdatetime(curdate,curtime3)
   PLAN (t
    WHERE t.ags_task_id=working_task_id)
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   CALL ags_set_status_block(eselect,efailure,"AGS_TASK COMPLETE",trim(serrmsg))
   GO TO exit_script
  ENDIF
  SET job_complete = true
  SELECT INTO "nl:"
   FROM ags_task t
   WHERE t.ags_job_id=working_job_id
    AND t.status != "COMPLETE"
   DETAIL
    job_complete = false
   WITH nocounter
  ;end select
  IF (job_complete)
   UPDATE  FROM ags_job j
    SET j.status = "COMPLETE", j.status_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE j.ags_job_id=working_job_id
    WITH nocounter
   ;end update
  ENDIF
 ELSEIF (working_task_id > 0
  AND working_kill_ind > 0)
  CALL echo("***")
  CALL echo("***   Update Task to Waiting Kill_ind = 1")
  CALL echo("***")
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  UPDATE  FROM ags_task t
   SET t.status = "WAITING", t.status_dt_tm = cnvtdatetime(curdate,curtime3), t.batch_end_dt_tm =
    cnvtdatetime(curdate,curtime3)
   PLAN (t
    WHERE t.ags_task_id=working_task_id)
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   CALL ags_set_status_block(eselect,efailure,"AGS_TASK KILL_IND WAITING",trim(serrmsg))
   GO TO exit_script
  ENDIF
 ENDIF
 COMMIT
#exit_script
 CALL echo("***")
 CALL echo("***   Exit Script")
 CALL echo("***")
 IF (ags_log_status(0)=0)
  CALL echo("***")
  CALL echo("***   Update Task to Error")
  CALL echo("***")
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  UPDATE  FROM ags_task t
   SET t.status = "IN ERROR", t.status_dt_tm = cnvtdatetime(curdate,curtime3)
   PLAN (t
    WHERE t.ags_task_id=working_task_id)
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   CALL ags_set_status_block(eselect,efailure,"AGS_TASK ERROR",trim(serrmsg))
  ENDIF
 ENDIF
 COMMIT
 CALL echo("***")
 CALL echo("***   END AGS_CLAIM_LOAD")
 CALL echo("***")
 SET script_ver = "016 11/22/06"
END GO
