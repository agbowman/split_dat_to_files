CREATE PROGRAM ce_med_result_76_ins:dba
 RECORD reply(
   1 array_size = i4
   1 num_inserted = i4
   1 error_code = i4
   1 error_msg = vc
 )
 SET reply->array_size = size(request->lst,5)
 DECLARE error_msg = vc WITH protect, noconstant("")
 SET error_code = 0
 INSERT  FROM ce_med_result t,
   (dummyt d  WITH seq = value(reply->array_size))
  SET t.event_id = evaluate2(
    IF ((request->lst[d.seq].event_id=- (1))) 0
    ELSE request->lst[d.seq].event_id
    ENDIF
    ), t.admin_note = request->lst[d.seq].admin_note, t.admin_prov_id = evaluate2(
    IF ((request->lst[d.seq].admin_prov_id=- (1))) 0
    ELSE request->lst[d.seq].admin_prov_id
    ENDIF
    ),
   t.admin_start_dt_tm = evaluate2(
    IF ((request->lst[d.seq].admin_start_dt_tm_ind=1)) null
    ELSE cnvtdatetimeutc(request->lst[d.seq].admin_start_dt_tm)
    ENDIF
    ), t.admin_end_dt_tm = evaluate2(
    IF ((request->lst[d.seq].admin_end_dt_tm_ind=1)) null
    ELSE cnvtdatetimeutc(request->lst[d.seq].admin_end_dt_tm)
    ENDIF
    ), t.admin_route_cd = evaluate2(
    IF ((request->lst[d.seq].admin_route_cd=- (1))) 0
    ELSE request->lst[d.seq].admin_route_cd
    ENDIF
    ),
   t.admin_site_cd = evaluate2(
    IF ((request->lst[d.seq].admin_site_cd=- (1))) 0
    ELSE request->lst[d.seq].admin_site_cd
    ENDIF
    ), t.admin_method_cd = evaluate2(
    IF ((request->lst[d.seq].admin_method_cd=- (1))) 0
    ELSE request->lst[d.seq].admin_method_cd
    ENDIF
    ), t.admin_pt_loc_cd = evaluate2(
    IF ((request->lst[d.seq].admin_pt_loc_cd=- (1))) 0
    ELSE request->lst[d.seq].admin_pt_loc_cd
    ENDIF
    ),
   t.initial_dosage = evaluate2(
    IF ((request->lst[d.seq].initial_dosage_ind=1)) null
    ELSE request->lst[d.seq].initial_dosage
    ENDIF
    ), t.admin_dosage = evaluate2(
    IF ((request->lst[d.seq].admin_dosage_ind=1)) null
    ELSE request->lst[d.seq].admin_dosage
    ENDIF
    ), t.dosage_unit_cd = evaluate2(
    IF ((request->lst[d.seq].dosage_unit_cd=- (1))) 0
    ELSE request->lst[d.seq].dosage_unit_cd
    ENDIF
    ),
   t.initial_volume = evaluate2(
    IF ((request->lst[d.seq].initial_volume_ind=1)) null
    ELSE request->lst[d.seq].initial_volume
    ENDIF
    ), t.total_intake_volume = evaluate2(
    IF ((request->lst[d.seq].total_intake_volume_ind=1)) null
    ELSE request->lst[d.seq].total_intake_volume
    ENDIF
    ), t.diluent_type_cd = evaluate2(
    IF ((request->lst[d.seq].diluent_type_cd=- (1))) 0
    ELSE request->lst[d.seq].diluent_type_cd
    ENDIF
    ),
   t.ph_dispense_id = evaluate2(
    IF ((request->lst[d.seq].ph_dispense_id=- (1))) 0
    ELSE request->lst[d.seq].ph_dispense_id
    ENDIF
    ), t.infusion_rate = evaluate2(
    IF ((request->lst[d.seq].infusion_rate_ind=1)) null
    ELSE request->lst[d.seq].infusion_rate
    ENDIF
    ), t.infusion_unit_cd = evaluate2(
    IF ((request->lst[d.seq].infusion_unit_cd=- (1))) 0
    ELSE request->lst[d.seq].infusion_unit_cd
    ENDIF
    ),
   t.infusion_time_cd = evaluate2(
    IF ((request->lst[d.seq].infusion_time_cd=- (1))) 0
    ELSE request->lst[d.seq].infusion_time_cd
    ENDIF
    ), t.medication_form_cd = evaluate2(
    IF ((request->lst[d.seq].medication_form_cd=- (1))) 0
    ELSE request->lst[d.seq].medication_form_cd
    ENDIF
    ), t.reason_required_flag = evaluate2(
    IF ((request->lst[d.seq].reason_required_flag_ind=1)) null
    ELSE request->lst[d.seq].reason_required_flag
    ENDIF
    ),
   t.response_required_flag = evaluate2(
    IF ((request->lst[d.seq].response_required_flag_ind=1)) null
    ELSE request->lst[d.seq].response_required_flag
    ENDIF
    ), t.admin_strength = evaluate2(
    IF ((request->lst[d.seq].admin_strength_ind=1)) null
    ELSE request->lst[d.seq].admin_strength
    ENDIF
    ), t.admin_strength_unit_cd = evaluate2(
    IF ((request->lst[d.seq].admin_strength_unit_cd=- (1))) 0
    ELSE request->lst[d.seq].admin_strength_unit_cd
    ENDIF
    ),
   t.substance_lot_number = request->lst[d.seq].substance_lot_number, t.substance_exp_dt_tm =
   evaluate2(
    IF ((request->lst[d.seq].substance_exp_dt_tm_ind=1)) null
    ELSE cnvtdatetimeutc(request->lst[d.seq].substance_exp_dt_tm)
    ENDIF
    ), t.substance_manufacturer_cd = evaluate2(
    IF ((request->lst[d.seq].substance_manufacturer_cd=- (1))) 0
    ELSE request->lst[d.seq].substance_manufacturer_cd
    ENDIF
    ),
   t.refusal_cd = evaluate2(
    IF ((request->lst[d.seq].refusal_cd=- (1))) 0
    ELSE request->lst[d.seq].refusal_cd
    ENDIF
    ), t.system_entry_dt_tm = evaluate2(
    IF ((request->lst[d.seq].system_entry_dt_tm_ind=1)) null
    ELSE cnvtdatetimeutc(request->lst[d.seq].system_entry_dt_tm)
    ENDIF
    ), t.valid_from_dt_tm = evaluate2(
    IF ((request->lst[d.seq].valid_from_dt_tm_ind=1)) null
    ELSE cnvtdatetimeutc(request->lst[d.seq].valid_from_dt_tm)
    ENDIF
    ),
   t.valid_until_dt_tm = evaluate2(
    IF ((request->lst[d.seq].valid_until_dt_tm_ind=1)) null
    ELSE cnvtdatetimeutc(request->lst[d.seq].valid_until_dt_tm)
    ENDIF
    ), t.updt_dt_tm = cnvtdatetimeutc(request->lst[d.seq].updt_dt_tm), t.updt_task = request->lst[d
   .seq].updt_task,
   t.updt_id = request->lst[d.seq].updt_id, t.updt_cnt = request->lst[d.seq].updt_cnt, t.updt_applctx
    = request->lst[d.seq].updt_applctx,
   t.synonym_id = request->lst[d.seq].synonym_id, t.immunization_type_cd = request->lst[d.seq].
   immunization_type_cd
  PLAN (d)
   JOIN (t)
  WITH rdbarrayinsert = 100, counter
 ;end insert
 SET error_code = error(error_msg,0)
 SET reply->num_inserted = curqual
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
END GO
