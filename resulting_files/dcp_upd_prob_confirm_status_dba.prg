CREATE PROGRAM dcp_upd_prob_confirm_status:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "Readme failed: Starting script dcp_upd_prob_confirm_status..."
 DECLARE error_msg = c132 WITH protect, noconstant("")
 DECLARE problem_cnt = i4 WITH protect, noconstant(0)
 DECLARE cnt = i4 WITH protect, noconstant(1)
 DECLARE pcnt = i4 WITH protect, noconstant(1)
 DECLARE transition_cnt = f8 WITH protect, noconstant(0.0)
 DECLARE systemuserid = f8 WITH protect, noconstant(0.0)
 DECLARE inactive = f8 WITH protect, noconstant(0.0)
 DECLARE active = f8 WITH protect, noconstant(0.0)
 DECLARE auth = f8 WITH protect, noconstant(0.0)
 DECLARE cconfirmed = f8 WITH protect, noconstant(0.0)
 DECLARE cpossible = f8 WITH protect, noconstant(0.0)
 DECLARE cprobable = f8 WITH protect, noconstant(0.0)
 DECLARE cprovisional = f8 WITH protect, noconstant(0.0)
 DECLARE econfirmed = f8 WITH protect, noconstant(0.0)
 DECLARE epossible = f8 WITH protect, noconstant(0.0)
 DECLARE epotential = f8 WITH protect, noconstant(0.0)
 DECLARE eprobable = f8 WITH protect, noconstant(0.0)
 DECLARE eprovisional = f8 WITH protect, noconstant(0.0)
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=12031
  DETAIL
   IF (cv.cdf_meaning="CONFIRMED")
    cconfirmed = cv.code_value
   ELSEIF (cv.cdf_meaning="POSSIBLE")
    cpossible = cv.code_value
   ELSEIF (cv.cdf_meaning="PROBABLE")
    cprobable = cv.code_value
   ELSEIF (cv.cdf_meaning="PROVISIONAL")
    cprovisional = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 IF (error(error_msg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Error retrieving code values for code set 12031: ",error_msg)
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=4002123
  DETAIL
   IF (cv.cdf_meaning="CONFIRMED")
    econfirmed = cv.code_value
   ELSEIF (cv.cdf_meaning="POSSIBLE")
    epossible = cv.code_value
   ELSEIF (cv.cdf_meaning="POTENTIAL")
    epotential = cv.code_value
   ELSEIF (cv.cdf_meaning="PROBABLE")
    eprobable = cv.code_value
   ELSEIF (cv.cdf_meaning="PROVISIONAL")
    eprovisional = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 IF (error(error_msg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Error retrieving code values for code set 4002123: ",error_msg)
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=48
  DETAIL
   IF (cv.cdf_meaning="INACTIVE")
    inactive = cv.code_value
   ELSEIF (cv.cdf_meaning="ACTIVE")
    active = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 IF (error(error_msg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Error retrieving code values for code set 48: ",error_msg)
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=8
   AND cv.cdf_meaning="AUTH"
  DETAIL
   IF (cv.cdf_meaning="AUTH")
    auth = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 IF (error(error_msg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Error retrieving code values for code set 8: ",error_msg)
  GO TO exit_program
 ENDIF
 FREE RECORD problem_list
 RECORD problem_list(
   1 problem[*]
     2 problem_id = f8
     2 problem_instance_id = f8
     2 problem_instance_uuid = vc
     2 confirmation_status_cd = f8
 )
 FREE RECORD instance_id_list
 RECORD instance_id_list(
   1 item[*]
     2 instance_id = f8
 )
 FREE RECORD m_dm2_seq_stat
 RECORD m_dm2_seq_stat(
   1 n_status = i4
   1 s_error_msg = vc
 )
 EXECUTE ccluarxrtl
 SELECT INTO "nl:"
  FROM problem p,
   pregnancy_instance pi,
   nomenclature nm,
   nomenclature nm1,
   person pr,
   organization org
  PLAN (p
   WHERE p.active_ind=1
    AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND p.problem_type_flag=2
    AND p.confirmation_status_cd IN (econfirmed, epossible, epotential, eprobable, eprovisional))
   JOIN (pi
   WHERE pi.person_id=p.person_id
    AND p.problem_id=pi.problem_id
    AND pi.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (nm
   WHERE p.nomenclature_id=nm.nomenclature_id)
   JOIN (nm1
   WHERE p.originating_nomenclature_id=nm1.nomenclature_id)
   JOIN (pr
   WHERE p.person_id=pr.person_id)
   JOIN (org
   WHERE p.organization_id=org.organization_id)
  HEAD REPORT
   problem_cnt = 0
  DETAIL
   problem_cnt = (problem_cnt+ 1)
   IF (mod(problem_cnt,100)=1)
    stat = alterlist(problem_list->problem,(problem_cnt+ 99))
   ENDIF
   problem_list->problem[problem_cnt].problem_instance_id = p.problem_instance_id, problem_list->
   problem[problem_cnt].problem_id = p.problem_id, problem_list->problem[problem_cnt].
   problem_instance_uuid = uar_createuuid(0)
   IF (p.confirmation_status_cd=econfirmed)
    problem_list->problem[problem_cnt].confirmation_status_cd = cconfirmed
   ELSEIF (((p.confirmation_status_cd=epossible) OR (p.confirmation_status_cd=epotential)) )
    problem_list->problem[problem_cnt].confirmation_status_cd = cpossible
   ELSEIF (p.confirmation_status_cd=eprobable)
    problem_list->problem[problem_cnt].confirmation_status_cd = cprobable
   ELSEIF (p.confirmation_status_cd=eprovisional)
    problem_list->problem[problem_cnt].confirmation_status_cd = cprovisional
   ENDIF
  FOOT REPORT
   stat = alterlist(problem_list->problem,problem_cnt)
  WITH nocounter
 ;end select
 IF (error(error_msg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Error retrieving problem_list: ",error_msg)
  GO TO exit_program
 ENDIF
 IF (problem_cnt <= 0)
  SET readme_data->status = "S"
  SET readme_data->message = concat(
   "Auto-success: No problem rows were affected with an invalid confirmation_status_cd")
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  userid = p.person_id
  FROM prsnl p
  WHERE p.name_last_key="SYSTEM"
   AND p.name_first_key="SYSTEM"
   AND p.active_ind=1
   AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  DETAIL
   systemuserid = userid
  WITH nocounter
 ;end select
 IF (error(error_msg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Error retrieving SYSTEM person Id: ",error_msg)
  GO TO exit_program
 ENDIF
 SET stat = alterlist(instance_id_list->item,problem_cnt)
 EXECUTE dm2_dar_get_bulk_seq "instance_id_list->item", problem_cnt, "instance_id",
 1, "PROBLEM_SEQ"
 IF ((m_dm2_seq_stat->n_status != 1))
  SET readme_data->status = "F"
  SET readme_data->message = concat("Error executing script DM2_DAR_GET_BULK_SEQ : ",error_msg)
  GO TO exit_program
 ENDIF
 FOR (pcnt = 1 TO problem_cnt)
   INSERT  FROM problem
    (problem_id, nomenclature_id, problem_ftdesc,
    person_id, estimated_resolution_dt_tm, actual_resolution_dt_tm,
    classification_cd, persistence_cd, life_cycle_status_cd,
    life_cycle_dt_tm, onset_dt_cd, onset_dt_tm,
    ranking_cd, certainty_cd, probability,
    person_aware_cd, prognosis_cd, person_aware_prognosis_cd,
    family_aware_cd, sensitivity, active_ind,
    beg_effective_dt_tm, contributor_system_cd, course_cd,
    cancel_reason_cd, onset_dt_flag, status_updt_precision_cd,
    status_updt_flag, status_updt_dt_tm, qualifier_cd,
    annotated_display, severity_class_cd, severity_cd,
    severity_ftdesc, onset_tz, beg_effective_tz,
    life_cycle_tz, del_ind, cond_type_flag,
    life_cycle_dt_cd, life_cycle_dt_flag, problem_uuid,
    organization_id, problem_type_flag, show_in_pm_history_ind,
    laterality_cd, originating_nomenclature_id, problem_instance_id,
    confirmation_status_cd, active_status_cd, active_status_dt_tm,
    active_status_prsnl_id, end_effective_dt_tm, data_status_cd,
    data_status_dt_tm, data_status_prsnl_id, problem_instance_uuid,
    updt_cnt, updt_id, updt_applctx,
    updt_task, updt_dt_tm)(SELECT
     p.problem_id, p.nomenclature_id, p.problem_ftdesc,
     p.person_id, p.estimated_resolution_dt_tm, p.actual_resolution_dt_tm,
     p.classification_cd, p.persistence_cd, p.life_cycle_status_cd,
     p.life_cycle_dt_tm, p.onset_dt_cd, p.onset_dt_tm,
     p.ranking_cd, p.certainty_cd, p.probability,
     p.person_aware_cd, p.prognosis_cd, p.person_aware_prognosis_cd,
     p.family_aware_cd, p.sensitivity, p.active_ind,
     p.beg_effective_dt_tm, p.contributor_system_cd, p.course_cd,
     p.cancel_reason_cd, p.onset_dt_flag, p.status_updt_precision_cd,
     p.status_updt_flag, p.status_updt_dt_tm, p.qualifier_cd,
     p.annotated_display, p.severity_class_cd, p.severity_cd,
     p.severity_ftdesc, p.onset_tz, p.beg_effective_tz,
     p.life_cycle_tz, p.del_ind, p.cond_type_flag,
     p.life_cycle_dt_cd, p.life_cycle_dt_flag, p.problem_uuid,
     p.organization_id, p.problem_type_flag, p.show_in_pm_history_ind,
     p.laterality_cd, p.originating_nomenclature_id, problem_instance_id = instance_id_list->item[
     pcnt].instance_id,
     confirmation_status_cd = problem_list->problem[pcnt].confirmation_status_cd, active_status_cd =
     active, active_status_dt_tm = cnvtdatetime(curdate,curtime3),
     active_status_prsnl_id = systemuserid, end_effective_dt_tm = cnvtdatetime(
      "31-DEC-2100 00:00:00.00"), data_status_cd = auth,
     data_status_dt_tm = cnvtdatetime(curdate,curtime3), data_status_prsnl_id = systemuserid,
     problem_instance_uuid = problem_list->problem[pcnt].problem_instance_uuid,
     updt_cnt = 0, updt_id = systemuserid, updt_applctx = reqinfo->updt_applctx,
     updt_task = reqinfo->updt_task, updt_dt_tm = cnvtdatetime(curdate,curtime3)
     FROM problem p
     WHERE (p.problem_instance_id=problem_list->problem[pcnt].problem_instance_id))
   ;end insert
   IF (((error(error_msg,0) != 0) OR (curqual != 1)) )
    SET readme_data->status = "F"
    SET readme_data->message = concat("Error inserting Problem table: ",error_msg)
    GO TO exit_program
   ENDIF
   UPDATE  FROM problem p
    SET p.active_ind = 0, p.updt_cnt = (p.updt_cnt+ 1), p.updt_id = systemuserid,
     p.updt_applctx = reqinfo->updt_applctx, p.updt_task = reqinfo->updt_task, p.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     p.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), p.active_status_cd = inactive, p
     .active_status_prsnl_id = systemuserid,
     p.active_status_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE (p.problem_instance_id=problem_list->problem[pcnt].problem_instance_id)
   ;end update
   IF (((error(error_msg,0) != 0) OR (curqual != 1)) )
    SET readme_data->status = "F"
    SET readme_data->message = concat("Error updating Problem table: ",error_msg)
    GO TO exit_program
   ENDIF
   INSERT  FROM problem_action pa
    SET pa.action_dt_tm = cnvtdatetime(curdate,curtime3), pa.action_type_mean = "REVIEW", pa
     .problem_action_id = seq(problem_seq,nextval),
     pa.problem_id = problem_list->problem[pcnt].problem_id, pa.problem_instance_id =
     instance_id_list->item[pcnt].instance_id, pa.prsnl_id = systemuserid,
     pa.updt_cnt = 0, pa.updt_id = systemuserid, pa.updt_applctx = reqinfo->updt_applctx,
     pa.updt_task = reqinfo->updt_task, pa.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   ;end insert
   IF (((error(error_msg,0) != 0) OR (curqual != 1)) )
    SET readme_data->status = "F"
    SET readme_data->message = concat("Error inserting Problem_action table: ",error_msg)
    GO TO exit_program
   ELSE
    SET transition_cnt = (transition_cnt+ 1)
   ENDIF
 ENDFOR
 IF (transition_cnt=problem_cnt)
  SET readme_data->status = "S"
  SET readme_data->message = concat("Readme updated ",trim(cnvtstring(transition_cnt)),
   " record(s) successfully.")
 ELSE
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme updated ",trim(cnvtstring(transition_cnt)),
   " record(s) out of",problem_cnt)
 ENDIF
#exit_program
 IF ((readme_data->status="F"))
  ROLLBACK
 ELSE
  COMMIT
 ENDIF
 FREE RECORD problem_list
 FREE RECORD instance_id_list
 FREE RECORD m_dm2_seq_stat
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
