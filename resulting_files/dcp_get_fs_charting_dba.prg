CREATE PROGRAM dcp_get_fs_charting:dba
 RECORD reply(
   1 qual_cnt = i2
   1 qual[*]
     2 event_cd = f8
     2 task_assay_cd = f8
     2 task_assay_disp = c40
     2 mnemonic = vc
     2 description = vc
     2 default_result_type_cd = f8
     2 default_result_type_disp = c40
     2 default_result_type_desc = c60
     2 default_result_type_mean = vc
     2 io_flag = i2
     2 map_cnt = i2
     2 map[*]
       3 service_resource_cd = f8
       3 service_resource_disp = c40
       3 service_resource_desc = c60
       3 service_resource_mean = vc
       3 data_map_type_flag = i2
       3 result_entry_format = i4
       3 max_digits = i4
       3 min_digits = i4
       3 min_decimal_places = i4
     2 textd_cnt = i2
     2 textd[*]
       3 result_template_cd = f8
       3 template_used = i4
     2 ref_cnt = i2
     2 ref[*]
       3 reference_range_factor_id = f8
       3 service_resource_cd = f8
       3 service_resource_disp = c40
       3 service_resource_desc = c60
       3 service_resource_mean = vc
       3 organism_cd = f8
       3 def_result_ind = i2
       3 species_cd = f8
       3 sex_cd = f8
       3 unknown_age_ind = i2
       3 age_from_units_cd = f8
       3 age_from_minutes = i4
       3 age_to_units_cd = f8
       3 age_to_minutes = i4
       3 specimen_type_cd = f8
       3 patient_condition_cd = f8
       3 alpha_response_ind = i2
       3 default_result = f8
       3 units_cd = f8
       3 units_disp = c40
       3 units_desc = c60
       3 units_mean = vc
       3 review_ind = i2
       3 review_low = f8
       3 review_high = f8
       3 sensitive_ind = i2
       3 sensitive_low = f8
       3 sensitive_high = f8
       3 normal_ind = i2
       3 normal_low = f8
       3 normal_high = f8
       3 critical_ind = i2
       3 critical_low = f8
       3 critical_high = f8
       3 delta_check_type_cd = f8
       3 delta_minutes = f8
       3 delta_value = f8
       3 mins_back = i4
       3 gestational_ind = i2
       3 precedence_sequence = i4
       3 updt_cnt = i4
       3 active_ind = i2
       3 alpha_cnt = i4
       3 alpha[*]
         4 sequence = i4
         4 nomenclature_id = f8
         4 use_units_ind = i2
         4 result_process_cd = f8
         4 default_ind = i2
         4 description = vc
         4 result_value = f8
         4 mnemonic = c25
         4 short_string = vc
         4 multi_alpha_sort_order = i4
       3 feasible_ind = i2
       3 feasible_low = f8
       3 feasible_high = f8
       3 linear_ind = i2
       3 linear_low = f8
       3 linear_high = f8
   1 multidta_ec_cnt = i4
   1 multidta_ec[*]
     2 event_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET count2 = 0
 SET count3 = 0
 SET count4 = 0
 SET reply_cnt = 0
 SET ta_cnt = request->task_assay_cd_cnt
 SET ec_cnt = request->event_cd_cnt
 IF (((ec_cnt=0) OR (ec_cnt=null)) )
  IF (((ta_cnt=0) OR (ta_cnt=null)) )
   GO TO exit_script
  ELSE
   SET ec_cnt = 0
   SET reply_cnt = ta_cnt
  ENDIF
 ELSE
  SET ta_cnt = 0
  SET reply_cnt = ec_cnt
 ENDIF
 RECORD temp_rec(
   1 multimatch_dta_cnt = i4
   1 multimatch_dta[*]
     2 task_assay_cd = f8
 )
 SET multimatch_dta_cnt = 0
 IF (ec_cnt > 0)
  SET event_cd_in_clause = fillstring(5000," ")
  SET event_cd_in_clause = concat(" d.event_cd in (",trim(cnvtstring(request->ec[1].event_cd)))
  FOR (cnt = 2 TO ec_cnt)
    SET event_cd_in_clause = concat(trim(event_cd_in_clause),",",trim(cnvtstring(request->ec[cnt].
       event_cd)))
  ENDFOR
  SET event_cd_in_clause = concat(trim(event_cd_in_clause),")")
  SET md_ec_cnt = 0
  SET mm_dta_cnt = 0
  SELECT INTO "nl:"
   dta.task_assay_cd, dta.event_cd
   FROM discrete_task_assay dta
   WHERE dta.event_cd IN (
   (SELECT INTO "nl:"
    d.event_cd
    FROM discrete_task_assay d
    WHERE parser(event_cd_in_clause)
     AND d.active_ind=1
    GROUP BY d.event_cd
    HAVING count(*) > 1))
   ORDER BY dta.event_cd
   HEAD dta.event_cd
    md_ec_cnt = (md_ec_cnt+ 1)
    IF (md_ec_cnt > size(reply->multidta_ec,5))
     stat = alterlist(reply->multidta_ec,(md_ec_cnt+ 5))
    ENDIF
    reply->multidta_ec[md_ec_cnt].event_cd = dta.event_cd
   DETAIL
    mm_dta_cnt = (mm_dta_cnt+ 1)
    IF (mm_dta_cnt > size(temp_rec->multimatch_dta,5))
     stat = alterlist(temp_rec->multimatch_dta,(mm_dta_cnt+ 5))
    ENDIF
    temp_rec->multimatch_dta[mm_dta_cnt].task_assay_cd = dta.task_assay_cd
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->multidta_ec,md_ec_cnt)
  SET stat = alterlist(temp_rec->multimatch_dta,mm_dta_cnt)
  SET multimatch_dta_cnt = mm_dta_cnt
 ENDIF
 SELECT
  IF (ta_cnt > 0)
   PLAN (d1)
    JOIN (dta
    WHERE (dta.task_assay_cd=request->tac[d1.seq].task_assay_cd))
    JOIN (dm
    WHERE dm.task_assay_cd=outerjoin(dta.task_assay_cd)
     AND dm.active_ind=outerjoin(1))
  ELSE
   PLAN (d1)
    JOIN (dta
    WHERE dta.event_cd=outerjoin(request->ec[d1.seq].event_cd)
     AND dta.active_ind=outerjoin(1))
    JOIN (dm
    WHERE dm.task_assay_cd=outerjoin(dta.task_assay_cd)
     AND dm.active_ind=outerjoin(1))
  ENDIF
  INTO "nl:"
  dta.task_assay_cd, dm.task_assay_cd
  FROM discrete_task_assay dta,
   (dummyt d1  WITH seq = value(reply_cnt)),
   data_map dm
  HEAD dta.task_assay_cd
   isvaliddta = 1
   IF (multimatch_dta_cnt > 0)
    FOR (x = 1 TO multimatch_dta_cnt)
      IF ((dta.task_assay_cd=temp_rec->multimatch_dta[x].task_assay_cd))
       isvaliddta = 0, BREAK
      ENDIF
    ENDFOR
   ENDIF
   count2 = 0
   IF (isvaliddta)
    count1 = (count1+ 1)
    IF (count1 > size(reply->qual,5))
     stat = alterlist(reply->qual,(count1+ 5))
    ENDIF
    reply->qual[count1].event_cd = dta.event_cd, reply->qual[count1].task_assay_cd = dta
    .task_assay_cd, reply->qual[count1].mnemonic = dta.mnemonic,
    reply->qual[count1].description = dta.description, reply->qual[count1].default_result_type_cd =
    dta.default_result_type_cd, reply->qual[count1].io_flag = dta.io_flag,
    reply->qual[count1].map_cnt = 0, reply->qual[count1].textd_cnt = 0, reply->qual[count1].ref_cnt
     = 0
   ENDIF
  DETAIL
   IF (isvaliddta)
    IF (dm.task_assay_cd=dta.task_assay_cd
     AND dm.active_ind=1)
     count2 = (count2+ 1), stat = alterlist(reply->qual[count1].map,count2), reply->qual[count1].map[
     count2].service_resource_cd = dm.service_resource_cd,
     reply->qual[count1].map[count2].data_map_type_flag = dm.data_map_type_flag, reply->qual[count1].
     map[count2].result_entry_format = dm.result_entry_format, reply->qual[count1].map[count2].
     max_digits = dm.max_digits,
     reply->qual[count1].map[count2].min_digits = dm.min_digits, reply->qual[count1].map[count2].
     min_decimal_places = dm.min_decimal_places
    ENDIF
   ENDIF
  FOOT  dta.task_assay_cd
   IF (isvaliddta)
    reply->qual[count1].map_cnt = count2
   ENDIF
  WITH nocounter, maxqual(dta,1)
 ;end select
 SET stat = alterlist(reply->qual,count1)
 SET reply->qual_cnt = count1
 SET reply_cnt = count1
 IF (curqual=0)
  GO TO exit_script
 ENDIF
 IF (reply_cnt > 0)
  SELECT INTO "nl:"
   td.task_assay_cd
   FROM text_data td,
    (dummyt d1  WITH seq = value(reply_cnt))
   PLAN (d1)
    JOIN (td
    WHERE (td.task_assay_cd=reply->qual[d1.seq].task_assay_cd))
   HEAD td.task_assay_cd
    count3 = 0
   DETAIL
    IF ((td.task_assay_cd=reply->qual[d1.seq].task_assay_cd))
     count3 = (count3+ 1), stat = alterlist(reply->qual[d1.seq].textd,count3), reply->qual[d1.seq].
     textd[count3].result_template_cd = td.result_template_cd,
     reply->qual[d1.seq].textd[count3].template_used = td.template_used
    ENDIF
   FOOT  td.task_assay_cd
    reply->qual[d1.seq].textd_cnt = count3
   WITH nocounter
  ;end select
 ENDIF
 SET species_value = 32
 SET specimen_type_value = 16
 SET age_value = 8
 SET sex_value = 4
 SET resource_ts_value = 2
 SET resource_ts_group_value = 1
 SET pat_cond_value = 0
 SET tot_value = 0
 SET highest_tot_value = - (1)
 SET get_detail = 0
 IF (reply_cnt > 0)
  SELECT INTO "nl:"
   rr.task_assay_cd, rr.reference_range_factor_id, rr_exists = decode(rr.seq,"Y","N"),
   ar.sequence, n.seq
   FROM reference_range_factor rr,
    (dummyt d1  WITH seq = value(reply_cnt)),
    alpha_responses ar,
    nomenclature n
   PLAN (d1)
    JOIN (rr
    WHERE (rr.task_assay_cd=reply->qual[d1.seq].task_assay_cd)
     AND rr.active_ind=1)
    JOIN (ar
    WHERE ar.reference_range_factor_id=outerjoin(rr.reference_range_factor_id)
     AND ar.active_ind=outerjoin(1))
    JOIN (n
    WHERE n.nomenclature_id=outerjoin(ar.nomenclature_id)
     AND n.active_ind=outerjoin(1))
   ORDER BY rr.task_assay_cd, rr.reference_range_factor_id
   HEAD rr.task_assay_cd
    count3 = 0, highest_tot_value = 0
   HEAD rr.reference_range_factor_id
    get_detail = 0, count4 = 0, tot_value = 0
    IF (rr_exists="Y")
     IF ((rr.species_cd=request->species_cd))
      tot_value = (tot_value+ species_value)
     ENDIF
     IF ((rr.sex_cd=request->sex_cd))
      tot_value = (tot_value+ sex_value)
     ENDIF
     IF ((rr.age_from_minutes <= request->age_in_min)
      AND (rr.age_to_minutes >= request->age_in_min))
      tot_value = (tot_value+ age_value)
     ENDIF
     IF ((rr.service_resource_cd=request->service_resource_cd))
      tot_value = (tot_value+ resource_ts_value)
     ENDIF
     IF (tot_value > highest_tot_value
      AND (rr.task_assay_cd=reply->qual[d1.seq].task_assay_cd)
      AND rr.active_ind=1)
      highest_tot_value = tot_value, get_detail = 1
      IF (count3=0)
       count3 = (count3+ 1), stat = alterlist(reply->qual[d1.seq].ref,count3)
      ENDIF
      reply->qual[d1.seq].ref[count3].reference_range_factor_id = rr.reference_range_factor_id, reply
      ->qual[d1.seq].ref[count3].service_resource_cd = rr.service_resource_cd, reply->qual[d1.seq].
      ref[count3].organism_cd = rr.organism_cd,
      reply->qual[d1.seq].ref[count3].def_result_ind = rr.def_result_ind, reply->qual[d1.seq].ref[
      count3].species_cd = rr.species_cd, reply->qual[d1.seq].ref[count3].sex_cd = rr.sex_cd,
      reply->qual[d1.seq].ref[count3].unknown_age_ind = rr.unknown_age_ind, reply->qual[d1.seq].ref[
      count3].age_from_units_cd = rr.age_from_units_cd, reply->qual[d1.seq].ref[count3].
      age_from_minutes = rr.age_from_minutes,
      reply->qual[d1.seq].ref[count3].age_to_units_cd = rr.age_to_units_cd, reply->qual[d1.seq].ref[
      count3].age_to_minutes = rr.age_to_minutes, reply->qual[d1.seq].ref[count3].specimen_type_cd =
      rr.specimen_type_cd,
      reply->qual[d1.seq].ref[count3].patient_condition_cd = rr.patient_condition_cd, reply->qual[d1
      .seq].ref[count3].alpha_response_ind = rr.alpha_response_ind, reply->qual[d1.seq].ref[count3].
      default_result = rr.default_result,
      reply->qual[d1.seq].ref[count3].units_cd = rr.units_cd, reply->qual[d1.seq].ref[count3].
      review_ind = rr.review_ind, reply->qual[d1.seq].ref[count3].review_low = rr.review_low,
      reply->qual[d1.seq].ref[count3].review_high = rr.review_high, reply->qual[d1.seq].ref[count3].
      sensitive_ind = rr.sensitive_ind, reply->qual[d1.seq].ref[count3].sensitive_low = rr
      .sensitive_low,
      reply->qual[d1.seq].ref[count3].sensitive_high = rr.sensitive_high, reply->qual[d1.seq].ref[
      count3].normal_ind = rr.normal_ind, reply->qual[d1.seq].ref[count3].normal_low = rr.normal_low,
      reply->qual[d1.seq].ref[count3].normal_high = rr.normal_high, reply->qual[d1.seq].ref[count3].
      critical_ind = rr.critical_ind, reply->qual[d1.seq].ref[count3].critical_low = rr.critical_low,
      reply->qual[d1.seq].ref[count3].critical_high = rr.critical_high, reply->qual[d1.seq].ref[
      count3].feasible_ind = rr.feasible_ind, reply->qual[d1.seq].ref[count3].feasible_low = rr
      .feasible_low,
      reply->qual[d1.seq].ref[count3].feasible_high = rr.feasible_high, reply->qual[d1.seq].ref[
      count3].linear_ind = rr.linear_ind, reply->qual[d1.seq].ref[count3].linear_low = rr.linear_low,
      reply->qual[d1.seq].ref[count3].linear_high = rr.linear_high, reply->qual[d1.seq].ref[count3].
      delta_check_type_cd = rr.delta_check_type_cd, reply->qual[d1.seq].ref[count3].delta_minutes =
      rr.delta_minutes,
      reply->qual[d1.seq].ref[count3].delta_value = rr.delta_value, reply->qual[d1.seq].ref[count3].
      mins_back = rr.mins_back, reply->qual[d1.seq].ref[count3].gestational_ind = rr.gestational_ind,
      reply->qual[d1.seq].ref[count3].precedence_sequence = rr.precedence_sequence, reply->qual[d1
      .seq].ref[count3].updt_cnt = rr.updt_cnt, reply->qual[d1.seq].ref[count3].active_ind = rr
      .active_ind
     ENDIF
    ENDIF
   DETAIL
    IF (get_detail=1)
     IF (ar.reference_range_factor_id=rr.reference_range_factor_id
      AND ar.active_ind=1)
      count4 = (count4+ 1), stat = alterlist(reply->qual[d1.seq].ref[count3].alpha,count4), reply->
      qual[d1.seq].ref[count3].alpha[count4].sequence = ar.sequence,
      reply->qual[d1.seq].ref[count3].alpha[count4].nomenclature_id = ar.nomenclature_id, reply->
      qual[d1.seq].ref[count3].alpha[count4].use_units_ind = ar.use_units_ind, reply->qual[d1.seq].
      ref[count3].alpha[count4].result_process_cd = ar.result_process_cd,
      reply->qual[d1.seq].ref[count3].alpha[count4].default_ind = ar.default_ind, reply->qual[d1.seq]
      .ref[count3].alpha[count4].result_value = ar.result_value, reply->qual[d1.seq].ref[count3].
      alpha[count4].multi_alpha_sort_order = ar.multi_alpha_sort_order
      IF (n.nomenclature_id=ar.nomenclature_id
       AND n.active_ind=1)
       reply->qual[d1.seq].ref[count3].alpha[count4].description = n.source_string, reply->qual[d1
       .seq].ref[count3].alpha[count4].short_string = n.short_string, reply->qual[d1.seq].ref[count3]
       .alpha[count4].mnemonic = n.mnemonic
      ENDIF
     ENDIF
    ENDIF
   FOOT  rr.reference_range_factor_id
    IF (get_detail=1)
     reply->qual[d1.seq].ref[count3].alpha_cnt = count4, stat = alterlist(reply->qual[d1.seq].ref[
      count3].alpha,count4)
    ENDIF
   FOOT  rr.task_assay_cd
    reply->qual[d1.seq].ref_cnt = count3
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 IF (count1 > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
