CREATE PROGRAM dcp_get_assay_equation:dba
 RECORD reply(
   1 task_assay_cd = f8
   1 service_resource_cd = f8
   1 equation_id = f8
   1 species_cd = f8
   1 age_from_units_cd = f8
   1 age_from_minutes = i4
   1 age_to_units_cd = f8
   1 age_to_minutes = i4
   1 sex_cd = f8
   1 equation_description = vc
   1 default_ind = i2
   1 default_equation_used_ind = i2
   1 equation_comp[*]
     2 sequence = i4
     2 result_status_cd = f8
     2 included_assay_cd = f8
     2 name = vc
     2 default_value = f8
     2 cross_drawn_dt_tm_ind = i2
     2 time_window_minutes = i4
     2 result_req_flag = i2
     2 component_flag = i2
     2 constant_value = f8
     2 result_found_ind = i2
     2 result_id = f8
     2 perform_result_id = f8
     2 result_value_numeric = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD default(
   1 equation_id = f8
   1 task_assay_cd = f8
   1 service_resource_cd = f8
   1 species_cd = f8
   1 age_from_units_cd = f8
   1 age_from_minutes = i4
   1 age_to_units_cd = f8
   1 age_to_minutes = i4
   1 sex_cd = f8
   1 equation_description = vc
   1 default_ind = i2
 )
 SELECT INTO "nl:"
  e.equation_id
  FROM equation e
  WHERE (e.task_assay_cd=request->task_assay_cd)
   AND e.active_ind=1
  HEAD REPORT
   q_cnt = 0, equation_match_flag = 0, species_match_ind = 0,
   sex_match_ind = 0, age_match_ind = 0, default_found_ind = 0
  DETAIL
   species_match_ind = 0, sex_match_ind = 0, age_match_ind = 0
   IF (e.default_ind=1)
    default_found_ind = 1, default->equation_id = e.equation_id, default->task_assay_cd = e
    .task_assay_cd,
    default->service_resource_cd = e.service_resource_cd, default->species_cd = e.species_cd, default
    ->age_from_units_cd = e.age_from_units_cd,
    default->age_from_minutes = e.age_from_minutes, default->age_to_units_cd = e.age_to_units_cd,
    default->age_to_minutes = e.age_to_minutes,
    default->sex_cd = e.sex_cd, default->equation_description = e.equation_description, default->
    default_ind = e.default_ind
   ENDIF
   IF (((e.species_cd <= 0.0) OR (e.species_cd > 0.0
    AND (e.species_cd=request->species_cd))) )
    species_match_ind = 1
   ENDIF
   IF (((e.sex_cd <= 0.0) OR (e.sex_cd > 0.0
    AND (e.sex_cd=request->sex_cd))) )
    sex_match_ind = 1
   ENDIF
   IF (((e.age_from_minutes=0
    AND e.age_to_minutes=0) OR (((e.age_from_minutes != 0) OR (e.age_to_minutes != 0))
    AND (e.age_from_minutes <= request->age_in_minutes)
    AND (e.age_to_minutes >= request->age_in_minutes))) )
    age_match_ind = 1
   ENDIF
   IF (species_match_ind=1
    AND sex_match_ind=1
    AND age_match_ind=1
    AND e.service_resource_cd <= 0.0
    AND equation_match_flag=0)
    equation_match_flag = 1, reply->task_assay_cd = e.task_assay_cd, reply->service_resource_cd = e
    .service_resource_cd,
    reply->equation_id = e.equation_id, reply->species_cd = e.species_cd, reply->age_from_units_cd =
    e.age_from_units_cd,
    reply->age_from_minutes = e.age_from_minutes, reply->age_to_units_cd = e.age_to_units_cd, reply->
    age_to_minutes = e.age_to_minutes,
    reply->sex_cd = e.sex_cd, reply->equation_description = e.equation_description, reply->
    default_ind = e.default_ind,
    reply->default_equation_used_ind = 0
   ENDIF
   IF (species_match_ind=1
    AND sex_match_ind=1
    AND age_match_ind=1
    AND (e.service_resource_cd=request->service_resource_cd)
    AND equation_match_flag < 2)
    equation_match_flag = 2, reply->task_assay_cd = e.task_assay_cd, reply->service_resource_cd = e
    .service_resource_cd,
    reply->equation_id = e.equation_id, reply->species_cd = e.species_cd, reply->age_from_units_cd =
    e.age_from_units_cd,
    reply->age_from_minutes = e.age_from_minutes, reply->age_to_units_cd = e.age_to_units_cd, reply->
    age_to_minutes = e.age_to_minutes,
    reply->sex_cd = e.sex_cd, reply->equation_description = e.equation_description, reply->
    default_ind = e.default_ind,
    reply->default_equation_used_ind = 0
   ENDIF
   IF (equation_match_flag=0
    AND default_found_ind=1)
    reply->task_assay_cd = default->task_assay_cd, reply->service_resource_cd = default->
    service_resource_cd, reply->equation_id = default->equation_id,
    reply->species_cd = default->species_cd, reply->age_from_units_cd = default->age_from_units_cd,
    reply->age_from_minutes = default->age_from_minutes,
    reply->age_to_units_cd = default->age_to_units_cd, reply->age_to_minutes = default->
    age_to_minutes, reply->sex_cd = default->sex_cd,
    reply->equation_description = default->equation_description, reply->default_ind = default->
    default_ind, reply->default_equation_used_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  ec.seq
  FROM equation_component ec
  WHERE (ec.equation_id=reply->equation_id)
   AND (reply->equation_id > 0.0)
  HEAD REPORT
   q_cnt = 0, ec_cnt = 0
  DETAIL
   ec_cnt = (ec_cnt+ 1), stat = alterlist(reply->equation_comp,ec_cnt), reply->equation_comp[ec_cnt].
   sequence = ec.sequence,
   reply->equation_comp[ec_cnt].result_status_cd = ec.result_status_cd, reply->equation_comp[ec_cnt].
   included_assay_cd = ec.included_assay_cd, reply->equation_comp[ec_cnt].name = ec.name,
   reply->equation_comp[ec_cnt].default_value = ec.default_value, reply->equation_comp[ec_cnt].
   cross_drawn_dt_tm_ind = ec.cross_drawn_dt_tm_ind, reply->equation_comp[ec_cnt].time_window_minutes
    = ec.time_window_minutes,
   reply->equation_comp[ec_cnt].result_req_flag = ec.result_req_flag, reply->equation_comp[ec_cnt].
   constant_value = ec.constant_value, reply->equation_comp[ec_cnt].component_flag = ec
   .component_flag
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echo(build("equation",reply->equation_description))
END GO
