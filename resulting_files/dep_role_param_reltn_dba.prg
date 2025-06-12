CREATE PROGRAM dep_role_param_reltn:dba
 FREE RECORD param_updates
 RECORD param_updates(
   1 profile[*]
     2 profile_id = f8
   1 parameter_ids[*]
     2 parameter_id = i4
 )
 FREE RECORD profile_param_reltn
 RECORD profile_param_reltn(
   1 profile_id = f8
   1 parameter_id = f8
   1 current_ind = i2
   1 parameter_value = vc
 )
 FREE RECORD profile_parameters
 RECORD profile_parameters(
   1 env_wide_mod[*]
     2 parameter_id = i4
     2 parameter_value = vc
     2 exists_ind = i2
 )
 FREE RECORD parameter_values
 RECORD parameter_values(
   1 parameters[*]
     2 parameter_value = vc
 )
 FREE RECORD clinical_migration_profile
 RECORD clinical_migration_profile(
   1 profile[*]
     2 profile_id = f8
 )
 FREE RECORD parameter_clinical_values
 RECORD parameter_clinical_values(
   1 parameters[*]
     2 parameter_value = vc
 )
 FREE RECORD profile_ids
 RECORD profile_ids(
   1 dep_profile[*]
     2 profile_id = f8
     2 parameter_id = i4
     2 default_parameter_value = vc
 )
 DECLARE profile_length = i4 WITH private, noconstant(0)
 DECLARE param_list_length = i4 WITH private, noconstant(0)
 SET environment_wide_modifiable = 5
 SET deployment_server_role_id = 13
 SET charting_server_role_id = 7
 SET network_username_parameter_id = 42
 SET network_password_parameter_id = 43
 SET gbl_network_username_parameter_id = 80
 SET gbl_network_password_parameter_id = 81
 SET gbl_clinical_db_host_parameter_id = 115
 SET gbl_clinical_db_sid_parameter_id = 116
 SET gbl_clinical_db_port_parameter_id = 117
 SET gbl_clinical_db_user_parameter_id = 118
 SET gbl_clinical_db_password_parameter_id = 119
 SET multum_cid = 125
 SET env_profile_id = (dep_env_id * - (1))
 SET hidden_parameter = 0
 SET domain_name_parameter_id = 53
 SET readme_data->status = "F"
 SET readme_data->message = "Beginning readme to update dep_role_param_reltn"
 DELETE  FROM dep_role_param_reltn drpr
  WHERE drpr.dep_env_id=dep_env_id
 ;end delete
 IF (error(string_struct_c->ms_err_msg,0) != 0)
  SET readme_data->message = concat("Failure during dep_role_param_reltn DELETE:",string_struct_c->
   ms_err_msg)
  GO TO enditnow
 ENDIF
 INSERT  FROM dep_role_param_reltn emc,
   (dummyt d1  WITH seq = value(size(requestin->list_0,5)))
  SET emc.role_id = cnvtreal(requestin->list_0[d1.seq].role_id), emc.parameter_id = cnvtreal(
    requestin->list_0[d1.seq].parameter_id), emc.dep_env_id = dep_env_id,
   emc.platform_type_cd = cnvtreal(requestin->list_0[d1.seq].platform_type_cd)
  PLAN (d1)
   JOIN (emc)
  WITH nocounter
 ;end insert
 IF (error(string_struct_c->ms_err_msg,0) != 0)
  SET readme_data->message = concat("Failure during dep_role_param_reltn INSERT:",string_struct_c->
   ms_err_msg)
  GO TO enditnow
 ENDIF
 SELECT INTO "nl:"
  emc.profile_id
  FROM dep_profile emc
  PLAN (emc
   WHERE emc.dep_env_id=dep_env_id)
  HEAD REPORT
   stat = alterlist(param_updates->profile,10), count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1
    AND count1 > 10)
    stat = alterlist(param_updates->profile,(count1+ 9))
   ENDIF
   param_updates->profile[count1].profile_id = emc.profile_id
  FOOT REPORT
   stat = alterlist(param_updates->profile,count1)
  WITH nocounter
 ;end select
 IF (error(string_struct_c->ms_err_msg,0) != 0)
  SET readme_data->message = concat("Failure finding profiles for environment SELECT:",
   string_struct_c->ms_err_msg)
  GO TO enditnow
 ENDIF
 SET profile_length = size(param_updates->profile,5)
 FOR (profile_index = 1 TO profile_length)
   SET stat = alterlist(param_updates->parameter_ids,0)
   SELECT DISTINCT INTO "nl:"
    drpr.parameter_id
    FROM dep_role_param_reltn drpr,
     dep_role_profile_reltn drpr2,
     dep_role_param drp,
     dep_profile dp
    WHERE drpr.dep_env_id=dep_env_id
     AND drpr.role_id=drpr2.role_id
     AND drp.parameter_id=drpr.parameter_id
     AND (drpr2.profile_id=param_updates->profile[profile_index].profile_id)
     AND (dp.profile_id=param_updates->profile[profile_index].profile_id)
     AND dp.platform_type_cd=drpr.platform_type_cd
     AND drp.dep_env_id=dep_env_id
     AND drp.overwrite_ind=2
     AND drp.modification_type_cd=0
     AND drp.new_in_plan_ind=0
    HEAD REPORT
     stat = alterlist(param_updates->parameter_ids,10), count1 = 0
    DETAIL
     count1 = (count1+ 1)
     IF (mod(count1,10)=1
      AND count1 > 10)
      stat = alterlist(param_updates->parameter_ids,(count1+ 9))
     ENDIF
     param_updates->parameter_ids[count1].parameter_id = drpr.parameter_id
    FOOT REPORT
     stat = alterlist(param_updates->parameter_ids,count1)
    WITH nocounter
   ;end select
   IF (error(string_struct_c->ms_err_msg,0) != 0)
    SET readme_data->message = concat("Failure finding parameters to update using SELECT:",
     string_struct_c->ms_err_msg)
    GO TO enditnow
   ENDIF
   SET param_list_length = size(param_updates->parameter_ids,5)
   FOR (param_index = 1 TO param_list_length)
     SET profile_param_reltn->profile_id = param_updates->profile[profile_index].profile_id
     SET profile_param_reltn->parameter_id = param_updates->parameter_ids[param_index].parameter_id
     SELECT INTO "nl:"
      FROM dep_role_param drp
      WHERE drp.dep_env_id=dep_env_id
       AND (drp.parameter_id=profile_param_reltn->parameter_id)
       AND drp.overwrite_ind=2
       AND drp.modification_type_cd=0
      DETAIL
       profile_param_reltn->parameter_value = drp.default_parameter_value
      WITH nocounter
     ;end select
     IF (error(string_struct_c->ms_err_msg,0) != 0)
      SET readme_data->message = concat("Failure finding parameter_value SELECT :",string_struct_c->
       ms_err_msg)
      GO TO enditnow
     ENDIF
     UPDATE  FROM dep_profile_param_reltn dppr
      SET dppr.parameter_value =
       IF (textlen(trim(profile_param_reltn->parameter_value)) > 0) profile_param_reltn->
        parameter_value
       ELSE null
       ENDIF
      WHERE (dppr.profile_id=profile_param_reltn->profile_id)
       AND (dppr.parameter_id=profile_param_reltn->parameter_id)
      WITH nocounter
     ;end update
     IF (error(string_struct_c->ms_err_msg,0) != 0)
      SET readme_data->message = concat("Failure during dep_profile_param_reltn UPDATE:",
       string_struct_c->ms_err_msg)
      GO TO enditnow
     ENDIF
   ENDFOR
   SET stat = alterlist(param_updates->parameter_ids,0)
   SELECT DISTINCT INTO "nl:"
    drpr.parameter_id
    FROM dep_role_param_reltn drpr,
     dep_role_profile_reltn drpr2,
     dep_profile dp
    WHERE drpr.dep_env_id=dep_env_id
     AND drpr.role_id=drpr2.role_id
     AND (drpr2.profile_id=param_updates->profile[profile_index].profile_id)
     AND (dp.profile_id=param_updates->profile[profile_index].profile_id)
     AND dp.platform_type_cd=drpr.platform_type_cd
     AND  NOT (drpr.parameter_id IN (
    (SELECT
     parameter_id
     FROM dep_profile_param_reltn
     WHERE (profile_id=param_updates->profile[profile_index].profile_id)
      AND current_ind=1)))
    HEAD REPORT
     stat = alterlist(param_updates->parameter_ids,10), count1 = 0
    DETAIL
     count1 = (count1+ 1)
     IF (mod(count1,10)=1
      AND count1 > 10)
      stat = alterlist(param_updates->parameter_ids,(count1+ 9))
     ENDIF
     param_updates->parameter_ids[count1].parameter_id = drpr.parameter_id
    FOOT REPORT
     stat = alterlist(param_updates->parameter_ids,count1)
    WITH nocounter
   ;end select
   IF (error(string_struct_c->ms_err_msg,0) != 0)
    SET readme_data->message = concat("Failure finding new parameters SELECT:",string_struct_c->
     ms_err_msg)
    GO TO enditnow
   ENDIF
   SET param_list_length = size(param_updates->parameter_ids,5)
   FOR (param_index = 1 TO param_list_length)
     SET profile_param_reltn->profile_id = param_updates->profile[profile_index].profile_id
     SET profile_param_reltn->parameter_id = param_updates->parameter_ids[param_index].parameter_id
     SELECT INTO "nl:"
      FROM dep_role_param drp
      WHERE drp.dep_env_id=dep_env_id
       AND (drp.parameter_id=profile_param_reltn->parameter_id)
      DETAIL
       profile_param_reltn->parameter_value = drp.default_parameter_value
      WITH nocounter
     ;end select
     IF (error(string_struct_c->ms_err_msg,0) != 0)
      SET readme_data->message = concat("Failure finding parameter_value SELECT :",string_struct_c->
       ms_err_msg)
      GO TO enditnow
     ENDIF
     FOR (cur_ind = 0 TO 1)
       SET profile_param_reltn->current_ind = cur_ind
       INSERT  FROM dep_profile_param_reltn dppr
        SET dppr.profile_id = profile_param_reltn->profile_id, dppr.parameter_id =
         profile_param_reltn->parameter_id, dppr.current_ind = profile_param_reltn->current_ind,
         dppr.parameter_value =
         IF (textlen(trim(profile_param_reltn->parameter_value)) > 0) profile_param_reltn->
          parameter_value
         ELSE null
         ENDIF
        WITH nocounter
       ;end insert
       IF (error(string_struct_c->ms_err_msg,0) != 0)
        SET readme_data->message = concat("Failure during dep_profile_param_reltn INSERT:",
         string_struct_c->ms_err_msg)
        GO TO enditnow
       ENDIF
     ENDFOR
   ENDFOR
 ENDFOR
 SELECT INTO "nl:"
  FROM dep_role_param drp
  PLAN (drp
   WHERE drp.dep_env_id=dep_env_id
    AND drp.modification_type_cd=environment_wide_modifiable)
  HEAD REPORT
   stat = alterlist(profile_parameters->env_wide_mod,10), count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1
    AND count1 > 10)
    stat = alterlist(profile_parameters->env_wide_mod,(count1+ 9))
   ENDIF
   profile_parameters->env_wide_mod[count1].exists_ind = 0, profile_parameters->env_wide_mod[count1].
   parameter_id = drp.parameter_id, profile_parameters->env_wide_mod[count1].parameter_value = drp
   .default_parameter_value
  FOOT REPORT
   stat = alterlist(profile_parameters->env_wide_mod,count1)
  WITH nocounter
 ;end select
 SET profile_length = size(profile_parameters->env_wide_mod,5)
 IF (error(string_struct_c->ms_err_msg,0) != 0)
  SET readme_data->message = concat("Failure during dep_role_param_reltn SELECT:",string_struct_c->
   ms_err_msg)
  GO TO enditnow
 ENDIF
 SELECT INTO "nl:"
  FROM dep_profile_param_reltn emc,
   (dummyt d1  WITH seq = value(size(profile_parameters->env_wide_mod,5)))
  PLAN (d1)
   JOIN (emc
   WHERE (emc.parameter_id=profile_parameters->env_wide_mod[d1.seq].parameter_id)
    AND emc.profile_id=env_profile_id)
  DETAIL
   profile_parameters->env_wide_mod[d1.seq].exists_ind = 1
  WITH nocounter
 ;end select
 IF (error(string_struct_c->ms_err_msg,0) != 0)
  SET readme_data->message = concat("Failure during dep_role_param_reltn SELECT:",string_struct_c->
   ms_err_msg)
  GO TO enditnow
 ENDIF
 SET env_profile_id = (dep_env_id * - (1))
 SET stat = alterlist(parameter_values->parameters,2)
 SET parameter_values->parameters[1].parameter_value = ""
 SET parameter_values->parameters[2].parameter_value = ""
 SELECT INTO "nl:"
  dppr.parameter_value
  FROM dep_profile_param_reltn dppr,
   dep_profile dp,
   dep_role_profile_reltn drpr,
   dep_profile_dev_reltn dpdr
  PLAN (dppr
   WHERE dppr.parameter_id IN (network_username_parameter_id, network_password_parameter_id)
    AND dppr.current_ind=0)
   JOIN (dp
   WHERE dp.dep_env_id=dep_env_id
    AND dppr.profile_id=dp.profile_id)
   JOIN (drpr
   WHERE drpr.role_id=deployment_server_role_id
    AND dppr.profile_id=drpr.profile_id)
   JOIN (dpdr
   WHERE dppr.profile_id=dpdr.profile_id)
  ORDER BY dppr.profile_id, dppr.parameter_id
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1), parameter_values->parameters[count1].parameter_value = dppr.parameter_value
  WITH nocounter, maxrec = 2
 ;end select
 IF (error(string_struct_c->ms_err_msg,0) != 0)
  SET readme_data->message = concat("Failure during dep_role_param_reltn SELECT:",string_struct_c->
   ms_err_msg)
  GO TO enditnow
 ENDIF
 SET stat = alterlist(clinical_migration_profile->profile,1)
 SET clinical_migration_profile->profile[1].profile_id = 0
 SET stat = alterlist(parameter_clinical_values->parameters,5)
 SET parameter_clinical_values->parameters[1].parameter_value = ""
 SET parameter_clinical_values->parameters[2].parameter_value = ""
 SET parameter_clinical_values->parameters[3].parameter_value = ""
 SET parameter_clinical_values->parameters[4].parameter_value = ""
 SET parameter_clinical_values->parameters[5].parameter_value = ""
 SELECT INTO "nl:"
  dp.profile_id
  FROM dep_profile_param_reltn dppr,
   dep_profile dp,
   dep_role_profile_reltn drpr,
   dep_profile_dev_reltn dpdr
  PLAN (dppr
   WHERE dppr.parameter_id=gbl_clinical_db_user_parameter_id
    AND dppr.current_ind=0
    AND dppr.parameter_value != "")
   JOIN (dp
   WHERE dp.dep_env_id=dep_env_id
    AND dppr.profile_id=dp.profile_id)
   JOIN (drpr
   WHERE drpr.role_id=charting_server_role_id
    AND dppr.profile_id=drpr.profile_id)
   JOIN (dpdr
   WHERE dppr.profile_id=dpdr.profile_id)
  DETAIL
   clinical_migration_profile->profile[1].profile_id = dp.profile_id
  WITH nocounter, maxrec = 1
 ;end select
 IF (error(string_struct_c->ms_err_msg,0) != 0)
  SET readme_data->message = concat("Failure during dep_role_param_reltn SELECT:",string_struct_c->
   ms_err_msg)
  GO TO enditnow
 ENDIF
 IF ((clinical_migration_profile->profile[1].profile_id != 0))
  SELECT INTO "nl:"
   dppr.parameter_value
   FROM dep_profile_param_reltn dppr
   PLAN (dppr
    WHERE dppr.parameter_id IN (gbl_clinical_db_host_parameter_id, gbl_clinical_db_sid_parameter_id,
    gbl_clinical_db_port_parameter_id, gbl_clinical_db_user_parameter_id,
    gbl_clinical_db_password_parameter_id)
     AND dppr.current_ind=0
     AND (dppr.profile_id=clinical_migration_profile->profile[1].profile_id))
   ORDER BY dppr.parameter_id
   HEAD REPORT
    count = 0
   DETAIL
    count = (count+ 1), parameter_clinical_values->parameters[count].parameter_value = dppr
    .parameter_value
   WITH nocounter, maxrec = 5
  ;end select
  IF (error(string_struct_c->ms_err_msg,0) != 0)
   SET readme_data->message = concat("Failure during dep_profile_param_reltn SELECT:",string_struct_c
    ->ms_err_msg)
   GO TO enditnow
  ENDIF
 ELSE
  SELECT INTO "nl:"
   dppr.parameter_value
   FROM dep_profile_param_reltn dppr,
    dep_profile dp,
    dep_role_profile_reltn drpr
   PLAN (dppr
    WHERE dppr.parameter_id=gbl_clinical_db_user_parameter_id
     AND dppr.current_ind=0
     AND dppr.parameter_value != "")
    JOIN (dp
    WHERE dp.dep_env_id=dep_env_id
     AND dppr.profile_id=dp.profile_id)
    JOIN (drpr
    WHERE drpr.role_id=charting_server_role_id
     AND dppr.profile_id=drpr.profile_id)
   DETAIL
    clinical_migration_profile->profile[1].profile_id = dp.profile_id
   WITH nocounter, maxrec = 1
  ;end select
  IF (error(string_struct_c->ms_err_msg,0) != 0)
   SET readme_data->message = concat("Failure during dep_role_param_reltn SELECT:",string_struct_c->
    ms_err_msg)
   GO TO enditnow
  ENDIF
  IF ((clinical_migration_profile->profile[1].profile_id != 0))
   SELECT INTO "nl:"
    dppr.parameter_value
    FROM dep_profile_param_reltn dppr
    PLAN (dppr
     WHERE dppr.parameter_id IN (gbl_clinical_db_host_parameter_id, gbl_clinical_db_sid_parameter_id,
     gbl_clinical_db_port_parameter_id, gbl_clinical_db_user_parameter_id,
     gbl_clinical_db_password_parameter_id)
      AND dppr.current_ind=0
      AND (dppr.profile_id=clinical_migration_profile->profile[1].profile_id))
    ORDER BY dppr.parameter_id
    HEAD REPORT
     count = 0
    DETAIL
     count = (count+ 1), parameter_clinical_values->parameters[count].parameter_value = dppr
     .parameter_value
    WITH nocounter, maxrec = 5
   ;end select
   IF (error(string_struct_c->ms_err_msg,0) != 0)
    SET readme_data->message = concat("Failure during dep_profile_param_reltn SELECT:",
     string_struct_c->ms_err_msg)
    GO TO enditnow
   ENDIF
  ENDIF
 ENDIF
 IF ((clinical_migration_profile->profile[1].profile_id=0))
  INSERT  FROM dep_profile_param_reltn dppr,
    (dummyt d1  WITH seq = value(size(profile_parameters->env_wide_mod,5)))
   SET dppr.profile_id = env_profile_id, dppr.parameter_id = profile_parameters->env_wide_mod[d1.seq]
    .parameter_id, dppr.current_ind = 1,
    dppr.parameter_value =
    IF ((profile_parameters->env_wide_mod[d1.seq].parameter_id=gbl_network_username_parameter_id))
     parameter_values->parameters[1].parameter_value
    ELSEIF ((profile_parameters->env_wide_mod[d1.seq].parameter_id=gbl_network_password_parameter_id)
    ) parameter_values->parameters[2].parameter_value
    ELSEIF (textlen(trim(profile_parameters->env_wide_mod[d1.seq].parameter_value)) > 0)
     profile_parameters->env_wide_mod[d1.seq].parameter_value
    ELSE null
    ENDIF
   PLAN (d1
    WHERE (profile_parameters->env_wide_mod[d1.seq].exists_ind != 1))
    JOIN (dppr)
   WITH nocounter
  ;end insert
  IF (error(string_struct_c->ms_err_msg,0) != 0)
   SET readme_data->message = concat("Failure during dep_role_param_reltn INSERT:",string_struct_c->
    ms_err_msg)
   GO TO enditnow
  ENDIF
  INSERT  FROM dep_profile_param_reltn dppr,
    (dummyt d1  WITH seq = value(size(profile_parameters->env_wide_mod,5)))
   SET dppr.profile_id = env_profile_id, dppr.parameter_id = profile_parameters->env_wide_mod[d1.seq]
    .parameter_id, dppr.current_ind = 0,
    dppr.parameter_value =
    IF ((profile_parameters->env_wide_mod[d1.seq].parameter_id=gbl_network_username_parameter_id))
     parameter_values->parameters[1].parameter_value
    ELSEIF ((profile_parameters->env_wide_mod[d1.seq].parameter_id=gbl_network_password_parameter_id)
    ) parameter_values->parameters[2].parameter_value
    ELSEIF (textlen(trim(profile_parameters->env_wide_mod[d1.seq].parameter_value)) > 0)
     profile_parameters->env_wide_mod[d1.seq].parameter_value
    ELSE null
    ENDIF
   PLAN (d1
    WHERE (profile_parameters->env_wide_mod[d1.seq].exists_ind != 1))
    JOIN (dppr)
   WITH nocounter
  ;end insert
  IF (error(string_struct_c->ms_err_msg,0) != 0)
   SET readme_data->message = concat("Failure during dep_role_param_reltn INSERT:",string_struct_c->
    ms_err_msg)
   GO TO enditnow
  ENDIF
 ELSE
  INSERT  FROM dep_profile_param_reltn dppr,
    (dummyt d1  WITH seq = value(size(profile_parameters->env_wide_mod,5)))
   SET dppr.profile_id = env_profile_id, dppr.parameter_id = profile_parameters->env_wide_mod[d1.seq]
    .parameter_id, dppr.current_ind = 1,
    dppr.parameter_value =
    IF ((profile_parameters->env_wide_mod[d1.seq].parameter_id=gbl_network_username_parameter_id))
     parameter_values->parameters[1].parameter_value
    ELSEIF ((profile_parameters->env_wide_mod[d1.seq].parameter_id=gbl_network_password_parameter_id)
    ) parameter_values->parameters[2].parameter_value
    ELSEIF ((profile_parameters->env_wide_mod[d1.seq].parameter_id=gbl_clinical_db_host_parameter_id)
    ) parameter_clinical_values->parameters[1].parameter_value
    ELSEIF ((profile_parameters->env_wide_mod[d1.seq].parameter_id=gbl_clinical_db_sid_parameter_id))
      parameter_clinical_values->parameters[2].parameter_value
    ELSEIF ((profile_parameters->env_wide_mod[d1.seq].parameter_id=gbl_clinical_db_port_parameter_id)
    ) parameter_clinical_values->parameters[3].parameter_value
    ELSEIF ((profile_parameters->env_wide_mod[d1.seq].parameter_id=gbl_clinical_db_user_parameter_id)
    ) parameter_clinical_values->parameters[4].parameter_value
    ELSEIF ((profile_parameters->env_wide_mod[d1.seq].parameter_id=
    gbl_clinical_db_password_parameter_id)) parameter_clinical_values->parameters[5].parameter_value
    ELSEIF (textlen(trim(profile_parameters->env_wide_mod[d1.seq].parameter_value)) > 0)
     profile_parameters->env_wide_mod[d1.seq].parameter_value
    ELSE null
    ENDIF
   PLAN (d1
    WHERE (profile_parameters->env_wide_mod[d1.seq].exists_ind != 1))
    JOIN (dppr)
   WITH nocounter
  ;end insert
  IF (error(string_struct_c->ms_err_msg,0) != 0)
   SET readme_data->message = concat("Failure during dep_role_param_reltn INSERT:",string_struct_c->
    ms_err_msg)
   GO TO enditnow
  ENDIF
  INSERT  FROM dep_profile_param_reltn dppr,
    (dummyt d1  WITH seq = value(size(profile_parameters->env_wide_mod,5)))
   SET dppr.profile_id = env_profile_id, dppr.parameter_id = profile_parameters->env_wide_mod[d1.seq]
    .parameter_id, dppr.current_ind = 0,
    dppr.parameter_value =
    IF ((profile_parameters->env_wide_mod[d1.seq].parameter_id=gbl_network_username_parameter_id))
     parameter_values->parameters[1].parameter_value
    ELSEIF ((profile_parameters->env_wide_mod[d1.seq].parameter_id=gbl_network_password_parameter_id)
    ) parameter_values->parameters[2].parameter_value
    ELSEIF ((profile_parameters->env_wide_mod[d1.seq].parameter_id=gbl_clinical_db_host_parameter_id)
    ) parameter_clinical_values->parameters[1].parameter_value
    ELSEIF ((profile_parameters->env_wide_mod[d1.seq].parameter_id=gbl_clinical_db_sid_parameter_id))
      parameter_clinical_values->parameters[2].parameter_value
    ELSEIF ((profile_parameters->env_wide_mod[d1.seq].parameter_id=gbl_clinical_db_port_parameter_id)
    ) parameter_clinical_values->parameters[3].parameter_value
    ELSEIF ((profile_parameters->env_wide_mod[d1.seq].parameter_id=gbl_clinical_db_user_parameter_id)
    ) parameter_clinical_values->parameters[4].parameter_value
    ELSEIF ((profile_parameters->env_wide_mod[d1.seq].parameter_id=
    gbl_clinical_db_password_parameter_id)) parameter_clinical_values->parameters[5].parameter_value
    ELSEIF (textlen(trim(profile_parameters->env_wide_mod[d1.seq].parameter_value)) > 0)
     profile_parameters->env_wide_mod[d1.seq].parameter_value
    ELSE null
    ENDIF
   PLAN (d1
    WHERE (profile_parameters->env_wide_mod[d1.seq].exists_ind != 1))
    JOIN (dppr)
   WITH nocounter
  ;end insert
  IF (error(string_struct_c->ms_err_msg,0) != 0)
   SET readme_data->message = concat("Failure during dep_role_param_reltn INSERT:",string_struct_c->
    ms_err_msg)
   GO TO enditnow
  ENDIF
  UPDATE  FROM dep_role_param drp
   SET drp.new_in_plan_ind = 1
   WHERE drp.dep_env_id=dep_env_id
    AND drp.parameter_id IN (gbl_clinical_db_host_parameter_id, gbl_clinical_db_sid_parameter_id,
   gbl_clinical_db_port_parameter_id, gbl_clinical_db_user_parameter_id,
   gbl_clinical_db_password_parameter_id)
   WITH nocounter
  ;end update
  IF (error(string_struct_c->ms_err_msg,0) != 0)
   SET readme_data->message = concat("Failure during dep_profile_param_reltn UPDATE:",string_struct_c
    ->ms_err_msg)
   GO TO enditnow
  ENDIF
 ENDIF
 SET stat = alterlist(parameter_values->parameters,1)
 SELECT DISTINCT INTO "nl:"
  dppr.parameter_value
  FROM dep_profile_param_reltn dppr
  PLAN (dppr
   WHERE dppr.parameter_id=gbl_network_password_parameter_id
    AND dppr.current_ind=0
    AND dppr.profile_id=env_profile_id
    AND dppr.parameter_value="*\\*")
  DETAIL
   parameter_values->parameters[1].parameter_value = dppr.parameter_value
  WITH nocounter
 ;end select
 IF (error(string_struct_c->ms_err_msg,0) != 0)
  SET readme_data->message = concat("Failure during dep_role_param_reltn SELECT:",string_struct_c->
   ms_err_msg)
  GO TO enditnow
 ENDIF
 IF (curqual > 0)
  UPDATE  FROM dep_profile_param_reltn dppr
   SET dppr.parameter_value =
    (SELECT INTO "nl"
     parameter_value
     FROM dep_profile_param_reltn
     WHERE profile_id=env_profile_id
      AND current_ind=0
      AND parameter_id=gbl_network_username_parameter_id
     WITH maxrec = 1)
   PLAN (dppr
    WHERE dppr.profile_id=env_profile_id
     AND dppr.parameter_id=gbl_network_password_parameter_id)
   WITH nocounter
  ;end update
  IF (error(string_struct_c->ms_err_msg,0) != 0)
   SET readme_data->message = concat("Failure during dep_role_param_reltn UPDATE:",string_struct_c->
    ms_err_msg)
   GO TO enditnow
  ENDIF
  UPDATE  FROM dep_profile_param_reltn dppr
   SET dppr.parameter_value = parameter_values->parameters[1].parameter_value
   PLAN (dppr
    WHERE dppr.profile_id=env_profile_id
     AND dppr.parameter_id=gbl_network_username_parameter_id)
   WITH nocounter
  ;end update
  IF (error(string_struct_c->ms_err_msg,0) != 0)
   SET readme_data->message = concat("Failure during dep_role_param_reltn UPDATE:",string_struct_c->
    ms_err_msg)
   GO TO enditnow
  ENDIF
 ENDIF
 DELETE  FROM dep_profile_param_reltn
  WHERE profile_id IN (
  (SELECT
   dp.profile_id
   FROM dep_profile dp,
    dep_role_profile_reltn drpr
   WHERE dp.profile_id=drpr.profile_id
    AND drpr.role_id=charting_server_role_id
    AND dp.dep_env_id=dep_env_id))
   AND parameter_id IN (gbl_clinical_db_host_parameter_id, gbl_clinical_db_sid_parameter_id,
  gbl_clinical_db_port_parameter_id, gbl_clinical_db_user_parameter_id,
  gbl_clinical_db_password_parameter_id)
 ;end delete
 IF (error(string_struct_c->ms_err_msg,0) != 0)
  SET readme_data->message = concat(
   "Failure during dep_role_param_reltn DELETE of existing clinical local parameters:",
   string_struct_c->ms_err_msg)
  GO TO enditnow
 ENDIF
 DELETE  FROM dep_role_param_reltn
  WHERE dep_env_id=dep_env_id
   AND role_id=charting_server_role_id
   AND parameter_id IN (gbl_clinical_db_host_parameter_id, gbl_clinical_db_sid_parameter_id,
  gbl_clinical_db_port_parameter_id, gbl_clinical_db_user_parameter_id,
  gbl_clinical_db_password_parameter_id)
 ;end delete
 IF (error(string_struct_c->ms_err_msg,0) != 0)
  SET readme_data->message = concat(
   "Failure during dep_role_param_reltn DELETE of existing clinical role association:",
   string_struct_c->ms_err_msg)
  GO TO enditnow
 ENDIF
 DELETE  FROM dep_profile_param_reltn
  WHERE profile_id IN (
  (SELECT
   dp.profile_id
   FROM dep_profile dp
   WHERE dp.dep_env_id=dep_env_id))
   AND parameter_id=multum_cid
 ;end delete
 IF (error(string_struct_c->ms_err_msg,0) != 0)
  SET readme_data->message = concat(
   "Failure during dep_role_param_reltn DELETE of existing multum cid local parameters:",
   string_struct_c->ms_err_msg)
  GO TO enditnow
 ENDIF
 DELETE  FROM dep_role_param_reltn
  WHERE dep_env_id=dep_env_id
   AND parameter_id=multum_cid
 ;end delete
 IF (error(string_struct_c->ms_err_msg,0) != 0)
  SET readme_data->message = concat(
   "Failure during dep_role_param_reltn DELETE of existing multum cid role association:",
   string_struct_c->ms_err_msg)
  GO TO enditnow
 ENDIF
 SELECT INTO "nl:"
  FROM dep_profile dp,
   dep_profile_param_reltn dppr,
   dep_role_param drp
  WHERE dp.dep_env_id=dep_env_id
   AND dp.dep_env_id=drp.dep_env_id
   AND drp.required_ind=0
   AND drp.modification_type_cd=hidden_parameter
   AND dppr.parameter_id=drp.parameter_id
   AND dp.profile_id=dppr.profile_id
   AND drp.parameter_id=domain_name_parameter_id
  HEAD REPORT
   stat = alterlist(profile_ids->dep_profile,10), count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1
    AND count1 > 10)
    stat = alterlist(profile_ids->dep_profile,(count1+ 9))
   ENDIF
   profile_ids->dep_profile[count1].profile_id = dp.profile_id, profile_ids->dep_profile[count1].
   parameter_id = drp.parameter_id, profile_ids->dep_profile[count1].default_parameter_value = drp
   .default_parameter_value,
   value = drp.parameter_id
  FOOT REPORT
   stat = alterlist(profile_ids->dep_profile,count1)
  WITH nocounter
 ;end select
 IF (error(string_struct_c->ms_err_msg,0) != 0)
  SET readme_data->message = concat("Failure during dep_profile, dep_profile_param_reltn SELECT:",
   string_struct_c->ms_err_msg)
  GO TO enditnow
 ENDIF
 UPDATE  FROM dep_profile_param_reltn dppr,
   (dummyt d1  WITH seq = value(size(profile_ids->dep_profile,5)))
  SET dppr.parameter_value = profile_ids->dep_profile[d1.seq].default_parameter_value
  PLAN (d1)
   JOIN (dppr
   WHERE dppr.profile_id=cnvtreal(profile_ids->dep_profile[d1.seq].profile_id)
    AND dppr.parameter_id=cnvtreal(profile_ids->dep_profile[d1.seq].parameter_id))
 ;end update
 IF (error(string_struct_c->ms_err_msg,0) != 0)
  SET readme_data->message = concat("Failure during dep_profile_param_reltn UPDATE:",string_struct_c
   ->ms_err_msg)
  GO TO enditnow
 ENDIF
 DELETE  FROM dep_is_coalesced dic
  WHERE dic.profile_id IN (
  (SELECT
   dp.profile_id
   FROM dep_profile dp
   WHERE dp.dep_env_id=dep_env_id))
 ;end delete
 IF (error(string_struct_c->ms_err_msg,0) != 0)
  SET readme_data->message = concat(
   "Failure during dep_role_param_reltn DELETE of dep_is_coalesced data:",string_struct_c->ms_err_msg
   )
  GO TO enditnow
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "EUC role/parameter relationship list inserted successfully"
#enditnow
 FREE RECORD param_updates
 FREE RECORD profile_param_reltn
 FREE RECORD profile_parameters
 FREE RECORD parameter_values
 FREE RECORD parameter_clinical_values
 FREE RECORD clinical_migration_profile
 FREE RECORD profile_ids
 IF ((readme_data->status="S"))
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
END GO
