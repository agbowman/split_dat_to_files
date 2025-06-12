CREATE PROGRAM bed_get_interp:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 reference_ranges[*]
      2 dcp_interp_id = f8
      2 sex_code_value = f8
      2 sex_display = vc
      2 sex_meaning = vc
      2 age_from_minutes = i4
      2 age_to_minutes = i4
      2 components[*]
        3 code_value = f8
        3 description = vc
        3 mnemonic = vc
        3 sequence = i4
        3 numeric_or_calc_ind = i2
        3 look_back_minutes = i4
        3 look_ahead_minutes = i4
        3 look_direction_ind = i2
      2 states[*]
        3 assay_code_value = f8
        3 state = i4
        3 numeric_low = i4
        3 numeric_high = i4
        3 nomenclature_id = f8
        3 resulting_state = i4
        3 result_nomenclature_id = f8
        3 numeric_low_double = f8
        3 numeric_high_double = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE error_flag = vc
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET rcnt = 0
 SET ccnt = 0
 SET scnt = 0
 SELECT INTO "nl:"
  FROM dcp_interp di,
   dcp_interp_component dc,
   discrete_task_assay dta
  PLAN (di
   WHERE (di.task_assay_cd=request->assay_code_value))
   JOIN (dc
   WHERE dc.dcp_interp_id=di.dcp_interp_id)
   JOIN (dta
   WHERE dta.task_assay_cd=dc.component_assay_cd)
  ORDER BY di.dcp_interp_id, dc.component_sequence
  HEAD di.dcp_interp_id
   rcnt = (rcnt+ 1), stat = alterlist(reply->reference_ranges,rcnt), reply->reference_ranges[rcnt].
   dcp_interp_id = di.dcp_interp_id,
   reply->reference_ranges[rcnt].sex_code_value = di.sex_cd, reply->reference_ranges[rcnt].
   sex_display = uar_get_code_display(di.sex_cd), reply->reference_ranges[rcnt].sex_meaning =
   uar_get_code_meaning(di.sex_cd),
   reply->reference_ranges[rcnt].age_from_minutes = di.age_from_minutes, reply->reference_ranges[rcnt
   ].age_to_minutes = di.age_to_minutes, ccnt = 0
  DETAIL
   ccnt = (ccnt+ 1), stat = alterlist(reply->reference_ranges[rcnt].components,ccnt), reply->
   reference_ranges[rcnt].components[ccnt].code_value = dc.component_assay_cd,
   reply->reference_ranges[rcnt].components[ccnt].description = dc.description, reply->
   reference_ranges[rcnt].components[ccnt].mnemonic = dta.mnemonic, reply->reference_ranges[rcnt].
   components[ccnt].sequence = dc.component_sequence,
   reply->reference_ranges[rcnt].components[ccnt].numeric_or_calc_ind = dc.flags, reply->
   reference_ranges[rcnt].components[ccnt].look_back_minutes = dc.look_back_minutes, reply->
   reference_ranges[rcnt].components[ccnt].look_ahead_minutes = dc.look_ahead_minutes,
   reply->reference_ranges[rcnt].components[ccnt].look_direction_ind = dc.look_time_direction_flag
  WITH nocounter
 ;end select
 IF (rcnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = rcnt),
    dcp_interp_state ds
   PLAN (d)
    JOIN (ds
    WHERE (ds.dcp_interp_id=reply->reference_ranges[d.seq].dcp_interp_id))
   ORDER BY d.seq, ds.resulting_state
   HEAD d.seq
    scnt = 0
   DETAIL
    scnt = (scnt+ 1), stat = alterlist(reply->reference_ranges[d.seq].states,scnt), reply->
    reference_ranges[d.seq].states[scnt].assay_code_value = ds.input_assay_cd,
    reply->reference_ranges[d.seq].states[scnt].state = ds.state, reply->reference_ranges[d.seq].
    states[scnt].numeric_low_double = ds.numeric_low, reply->reference_ranges[d.seq].states[scnt].
    numeric_high_double = ds.numeric_high,
    reply->reference_ranges[d.seq].states[scnt].nomenclature_id = ds.nomenclature_id, reply->
    reference_ranges[d.seq].states[scnt].resulting_state = ds.resulting_state, reply->
    reference_ranges[d.seq].states[scnt].result_nomenclature_id = ds.result_nomenclature_id
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
