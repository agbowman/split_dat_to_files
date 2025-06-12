CREATE PROGRAM bbt_get_interp_comps:dba
 RECORD reply(
   1 comp_data[*]
     2 interp_detail_id = f8
     2 inc_assay_cd = f8
     2 inc_assay_disp = vc
     2 sequence = i2
     2 verified_flag = i2
     2 result_status_cd_disp = vc
     2 cross_tm_ind = i2
     2 time_min = i4
     2 time_units_cd = f8
     2 time_units_cd_disp = vc
     2 result_req_flag = i4
     2 meaning = vc
     2 updt_cnt = i4
     2 bb_result_cd = f8
     2 bb_result_cd_disp = c40
     2 bb_result_cd_mean = c12
   1 range_data[*]
     2 interp_range_id = f8
     2 inc_assay_cd = f8
     2 sequence = i4
     2 nomenclature_id = f8
     2 nomenclature_disp = vc
     2 age_from_units = i4
     2 age_from_units_cd = f8
     2 age_from_units_disp = vc
     2 age_to_units = i4
     2 age_to_units_cd = f8
     2 age_to_units_cd_disp = vc
     2 species_cd = f8
     2 species_cd_disp = vc
     2 race_cd = f8
     2 race_cd_disp = vc
     2 gender_cd = f8
     2 gender_cd_disp = vc
     2 updt_cnt = i4
     2 unknown_age_ind = i2
   1 hash_data[*]
     2 result_hash_id = f8
     2 inc_assay_cd = f8
     2 sequence = i4
     2 from_result_range = f8
     2 to_result_range = f8
     2 result_hash = vc
     2 nomenclature_id = f8
     2 nomenclature_disp = vc
     2 donor_eligibility_cd = f8
     2 donor_eligibility_cd_disp = vc
     2 donor_reason_cd = f8
     2 donor_reason_cd_disp = vc
     2 days_ineligible = i4
     2 result_cd = f8
     2 result_cd_disp = vc
     2 interp_range_id = f8
     2 updt_cnt = i4
     2 biohazard_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET comp_cnt = 0
 SET rng_cnt = 0
 SET hash_cnt = 0
 SET hold_comp_id = 0.0
 SET hold_from = 0.0
 SET hold_to = 0.0
 SET c_idx = 0
 IF ((request->donor_interp_ind=1))
  SELECT INTO "nl:"
   ic.*, apr.default_result_type_cd, d.default_result_type_cd,
   cdf_meaning = decode(apr.seq,uar_get_code_meaning(apr.default_result_type_cd),uar_get_code_meaning
    (d.default_result_type_cd))
   FROM interp_component ic,
    interp_task_assay ita,
    service_directory s,
    discrete_task_assay d,
    assay_processing_r apr,
    (dummyt d1  WITH seq = 1),
    (dummyt d2  WITH seq = 1)
   PLAN (ic
    WHERE (ic.interp_id=request->interp_id)
     AND ic.active_ind=1)
    JOIN (d
    WHERE ic.included_assay_cd=d.task_assay_cd)
    JOIN (d1
    WHERE d1.seq=1)
    JOIN (apr
    WHERE apr.task_assay_cd=d.task_assay_cd
     AND apr.active_ind=1)
    JOIN (d2
    WHERE d2.seq=1)
    JOIN (ita
    WHERE ita.task_assay_cd=ic.included_assay_cd
     AND ita.active_ind=1)
    JOIN (s
    WHERE s.catalog_cd=ita.order_cat_cd
     AND s.active_ind=1)
   DETAIL
    IF (hold_comp_id != d.task_assay_cd)
     hold_comp_id = d.task_assay_cd, comp_cnt = (comp_cnt+ 1), stat = alterlist(reply->comp_data,
      comp_cnt),
     reply->comp_data[comp_cnt].interp_detail_id = ic.interp_detail_id, reply->comp_data[comp_cnt].
     sequence = ic.sequence, reply->comp_data[comp_cnt].verified_flag = ic.verified_flag,
     reply->comp_data[comp_cnt].inc_assay_cd = ic.included_assay_cd, reply->comp_data[comp_cnt].
     inc_assay_disp = d.mnemonic, reply->comp_data[comp_cnt].cross_tm_ind = ic.cross_drawn_dt_tm_ind,
     reply->comp_data[comp_cnt].time_min = ic.time_window_minutes, reply->comp_data[comp_cnt].
     time_units_cd = ic.time_window_units_cd, reply->comp_data[comp_cnt].result_req_flag = ic
     .result_req_flag,
     reply->comp_data[comp_cnt].updt_cnt = ic.updt_cnt, reply->comp_data[comp_cnt].bb_result_cd = s
     .bb_processing_cd, reply->comp_data[comp_cnt].meaning = cdf_meaning
    ENDIF
   WITH counter, outerjoin(d1), outerjoin = d2
  ;end select
  IF (curqual != 0)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "Z"
   GO TO exitscript
  ENDIF
 ELSE
  SELECT INTO "nl:"
   ic.*, cdf_meaning = decode(apr.seq,uar_get_code_meaning(apr.default_result_type_cd),
    uar_get_code_meaning(d.default_result_type_cd))
   FROM interp_component ic,
    discrete_task_assay d,
    assay_processing_r apr,
    (dummyt d1  WITH seq = 1)
   PLAN (ic
    WHERE (ic.interp_id=request->interp_id)
     AND ic.active_ind=1)
    JOIN (d
    WHERE ic.included_assay_cd=d.task_assay_cd)
    JOIN (d1
    WHERE d1.seq=1)
    JOIN (apr
    WHERE apr.task_assay_cd=d.task_assay_cd
     AND apr.active_ind=1)
   DETAIL
    IF (hold_comp_id != d.task_assay_cd)
     hold_comp_id = d.task_assay_cd, comp_cnt = (comp_cnt+ 1), stat = alterlist(reply->comp_data,
      comp_cnt),
     reply->comp_data[comp_cnt].interp_detail_id = ic.interp_detail_id, reply->comp_data[comp_cnt].
     sequence = ic.sequence, reply->comp_data[comp_cnt].verified_flag = ic.verified_flag,
     reply->comp_data[comp_cnt].inc_assay_cd = ic.included_assay_cd, reply->comp_data[comp_cnt].
     inc_assay_disp = d.mnemonic, reply->comp_data[comp_cnt].cross_tm_ind = ic.cross_drawn_dt_tm_ind,
     reply->comp_data[comp_cnt].time_min = ic.time_window_minutes, reply->comp_data[comp_cnt].
     time_units_cd = ic.time_window_units_cd, reply->comp_data[comp_cnt].result_req_flag = ic
     .result_req_flag,
     reply->comp_data[comp_cnt].updt_cnt = ic.updt_cnt, reply->comp_data[comp_cnt].bb_result_cd = 0,
     reply->comp_data[comp_cnt].meaning = cdf_meaning
    ENDIF
   WITH counter, outerjoin(d1)
  ;end select
  IF (curqual != 0)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "Z"
   GO TO exitscript
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  ir.*
  FROM interp_range ir
  WHERE (ir.interp_id=request->interp_id)
   AND ir.active_ind=1
  DETAIL
   rng_cnt = (rng_cnt+ 1), stat = alterlist(reply->range_data,rng_cnt), reply->range_data[rng_cnt].
   interp_range_id = ir.interp_range_id,
   reply->range_data[rng_cnt].sequence = ir.sequence, reply->range_data[rng_cnt].inc_assay_cd = ir
   .included_assay_cd, reply->range_data[rng_cnt].age_from_units = ir.age_from_minutes,
   reply->range_data[rng_cnt].age_from_units_cd = ir.age_from_units_cd, reply->range_data[rng_cnt].
   age_to_units = ir.age_to_minutes, reply->range_data[rng_cnt].age_to_units_cd = ir.age_to_units_cd,
   reply->range_data[rng_cnt].species_cd = ir.species_cd, reply->range_data[rng_cnt].race_cd = ir
   .race_cd, reply->range_data[rng_cnt].gender_cd = ir.gender_cd,
   reply->range_data[rng_cnt].unknown_age_ind = ir.unknown_age_ind, reply->range_data[rng_cnt].
   updt_cnt = ir.updt_cnt
  WITH counter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "R"
  GO TO exitscript
 ENDIF
 SELECT INTO "nl:"
  rh.*
  FROM result_hash rh,
   nomenclature n
  PLAN (rh
   WHERE (rh.interp_id=request->interp_id)
    AND rh.active_ind=1)
   JOIN (n
   WHERE n.nomenclature_id=rh.nomenclature_id)
  DETAIL
   hash_cnt = (hash_cnt+ 1), stat = alterlist(reply->hash_data,hash_cnt), reply->hash_data[hash_cnt].
   result_hash_id = rh.result_hash_id,
   reply->hash_data[hash_cnt].sequence = rh.sequence, reply->hash_data[hash_cnt].from_result_range =
   rh.from_result_range, reply->hash_data[hash_cnt].to_result_range = rh.to_result_range,
   reply->hash_data[hash_cnt].result_hash = rh.result_hash, reply->hash_data[hash_cnt].
   nomenclature_id = rh.nomenclature_id, reply->hash_data[hash_cnt].nomenclature_disp = n.mnemonic,
   reply->hash_data[hash_cnt].result_cd = rh.result_cd, reply->hash_data[hash_cnt].updt_cnt = rh
   .updt_cnt, reply->hash_data[hash_cnt].interp_range_id = rh.interp_range_id,
   reply->hash_data[hash_cnt].inc_assay_cd = rh.included_assay_cd, reply->hash_data[hash_cnt].
   days_ineligible = rh.days_ineligible, reply->hash_data[hash_cnt].donor_eligibility_cd = rh
   .donor_eligibility_cd,
   reply->hash_data[hash_cnt].result_cd = rh.result_cd, reply->hash_data[hash_cnt].donor_reason_cd =
   rh.donor_reason_cd, reply->hash_data[hash_cnt].biohazard_ind = rh.biohazard_ind
  WITH counter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
  GO TO exitscript
 ENDIF
#exitscript
END GO
