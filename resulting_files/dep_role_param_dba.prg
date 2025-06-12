CREATE PROGRAM dep_role_param:dba
 DECLARE warehouse_limit_parameter_id = i4 WITH public, constant(51)
 SET readme_data->status = "F"
 SET readme_data->message = "Beginning readme to update dep_role_param"
 SELECT INTO "nl:"
  FROM dep_role_param emc,
   (dummyt d1  WITH seq = value(size(requestin->list_0,5)))
  PLAN (d1)
   JOIN (emc
   WHERE emc.parameter_id=cnvtreal(requestin->list_0[d1.seq].parameter_id)
    AND emc.dep_env_id=dep_env_id)
  DETAIL
   requestin->list_0[d1.seq].exists_ind = "1"
  WITH nocounter
 ;end select
 IF (error(string_struct_c->ms_err_msg,0) != 0)
  SET readme_data->message = concat("Failure during dep_role_param SELECT:",string_struct_c->
   ms_err_msg)
  GO TO enditnow
 ENDIF
 SET profile_count = 0
 SELECT INTO "nl:"
  FROM dep_profile dp
  WHERE dp.dep_env_id=dep_env_id
  DETAIL
   profile_count = (profile_count+ 1)
  WITH nocounter
 ;end select
 IF (error(string_struct_c->ms_err_msg,0) != 0)
  SET readme_data->message = concat("Failure during dep_profile SELECT:",string_struct_c->ms_err_msg)
  GO TO enditnow
 ENDIF
 INSERT  FROM dep_role_param emc,
   (dummyt d1  WITH seq = value(size(requestin->list_0,5)))
  SET emc.parameter_id = cnvtreal(requestin->list_0[d1.seq].parameter_id), emc.parameter_name =
   requestin->list_0[d1.seq].parameter_name, emc.modification_type_cd = cnvtreal(requestin->list_0[d1
    .seq].modification_type_cd),
   emc.encrypted_ind = cnvtreal(requestin->list_0[d1.seq].encrypted_ind), emc.required_ind = cnvtreal
   (requestin->list_0[d1.seq].required_ind), emc.seq_number = cnvtreal(requestin->list_0[d1.seq].
    seq_number),
   emc.default_parameter_value =
   IF (textlen(trim(requestin->list_0[d1.seq].default_parameter_value)) > 0) requestin->list_0[d1.seq
    ].default_parameter_value
   ELSE null
   ENDIF
   , emc.help_text =
   IF (textlen(trim(requestin->list_0[d1.seq].help_text)) > 0) requestin->list_0[d1.seq].help_text
   ELSE null
   ENDIF
   , emc.overwrite_ind = cnvtreal(requestin->list_0[d1.seq].overwrite_ind),
   emc.parameter_pattern =
   IF (textlen(trim(requestin->list_0[d1.seq].parameter_pattern)) > 0) requestin->list_0[d1.seq].
    parameter_pattern
   ELSE null
   ENDIF
   , emc.dep_env_id = dep_env_id, emc.new_in_plan_ind = 1,
   emc.optional_param_name =
   IF (textlen(trim(requestin->list_0[d1.seq].optional_param_name)) > 0) requestin->list_0[d1.seq].
    optional_param_name
   ELSE null
   ENDIF
   , emc.conditional_req_param_name =
   IF (textlen(trim(requestin->list_0[d1.seq].conditional_req_param_name)) > 0) requestin->list_0[d1
    .seq].conditional_req_param_name
   ELSE null
   ENDIF
  PLAN (d1
   WHERE (requestin->list_0[d1.seq].exists_ind != "1"))
   JOIN (emc)
  WITH nocounter
 ;end insert
 IF (error(string_struct_c->ms_err_msg,0) != 0)
  SET readme_data->message = concat("Failure during dep_role_param INSERT:",string_struct_c->
   ms_err_msg)
  GO TO enditnow
 ENDIF
 UPDATE  FROM dep_role_param emc,
   (dummyt d1  WITH seq = value(size(requestin->list_0,5)))
  SET emc.parameter_id = cnvtreal(requestin->list_0[d1.seq].parameter_id), emc.parameter_name =
   requestin->list_0[d1.seq].parameter_name, emc.modification_type_cd = cnvtreal(requestin->list_0[d1
    .seq].modification_type_cd),
   emc.encrypted_ind = cnvtreal(requestin->list_0[d1.seq].encrypted_ind), emc.required_ind = cnvtreal
   (requestin->list_0[d1.seq].required_ind), emc.seq_number = cnvtreal(requestin->list_0[d1.seq].
    seq_number),
   emc.default_parameter_value =
   IF (cnvtreal(requestin->list_0[d1.seq].parameter_id)=warehouse_limit_parameter_id)
    IF (profile_count > 0) emc.default_parameter_value
    ELSE requestin->list_0[d1.seq].default_parameter_value
    ENDIF
   ELSEIF (cnvtint(requestin->list_0[d1.seq].overwrite_ind) > 0)
    IF (textlen(trim(requestin->list_0[d1.seq].default_parameter_value)) > 0) requestin->list_0[d1
     .seq].default_parameter_value
    ELSE null
    ENDIF
   ELSE emc.default_parameter_value
   ENDIF
   , emc.overwrite_ind = cnvtreal(requestin->list_0[d1.seq].overwrite_ind), emc.help_text =
   IF (textlen(trim(requestin->list_0[d1.seq].help_text)) > 0) requestin->list_0[d1.seq].help_text
   ELSE null
   ENDIF
   ,
   emc.parameter_pattern =
   IF (textlen(trim(requestin->list_0[d1.seq].parameter_pattern)) > 0) requestin->list_0[d1.seq].
    parameter_pattern
   ELSE null
   ENDIF
   , emc.dep_env_id = dep_env_id, emc.new_in_plan_ind = 0,
   emc.optional_param_name =
   IF (textlen(trim(requestin->list_0[d1.seq].optional_param_name)) > 0) requestin->list_0[d1.seq].
    optional_param_name
   ELSE null
   ENDIF
   , emc.conditional_req_param_name =
   IF (textlen(trim(requestin->list_0[d1.seq].conditional_req_param_name)) > 0) requestin->list_0[d1
    .seq].conditional_req_param_name
   ELSE null
   ENDIF
  PLAN (d1
   WHERE (requestin->list_0[d1.seq].exists_ind="1"))
   JOIN (emc
   WHERE emc.parameter_id=cnvtreal(requestin->list_0[d1.seq].parameter_id)
    AND emc.dep_env_id=dep_env_id)
  WITH nocounter
 ;end update
 IF (error(string_struct_c->ms_err_msg,0) != 0)
  SET readme_data->message = concat("Failure during dep_role_param UPDATE:",string_struct_c->
   ms_err_msg)
  GO TO enditnow
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "EUC role parameter list inserted successfully"
#enditnow
 IF ((readme_data->status="S"))
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
END GO
