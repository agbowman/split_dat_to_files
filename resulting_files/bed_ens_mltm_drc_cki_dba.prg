CREATE PROGRAM bed_ens_mltm_drc_cki:dba
 RECORD request_kia(
   1 import_method_flag = i2
   1 domain_flag = i2
   1 drc_obj_list[*]
     2 drc_obj
       3 grouper_name = vc
       3 grouper_id = i4
       3 facility_flex_ind = i2
       3 facility_disp = vc
       3 qualifier_list[*]
         4 qualifier
           5 qualifier_id = i4
           5 age_operator = c12
           5 from_age = f8
           5 to_age = f8
           5 age_unit = vc
           5 age_unit_cki = vc
           5 pma_operator = vc
           5 from_pma = f8
           5 to_pma = f8
           5 pma_unit = vc
           5 pma_unit_cki = vc
           5 weight_operator = c12
           5 from_weight = f8
           5 to_weight = f8
           5 weight_unit = vc
           5 weight_unit_cki = vc
           5 renal_operator = c12
           5 from_renal = f8
           5 to_renal = f8
           5 renal_unit = vc
           5 renal_unit_cki = vc
           5 hepatic_dysfunction_ind = i2
           5 concept_cki = vc
           5 route_list[*]
             6 route
               7 route_id = i4
               7 route_disp = vc
               7 route_cki = vc
               7 active_ind = i2
           5 dose_range_list[*]
             6 dose_range
               7 dose_range_id = i4
               7 dose_range_type = vc
               7 from_dose_amount = f8
               7 to_dose_amount = f8
               7 dose_unit = vc
               7 dose_unit_cki = vc
               7 dose_days = f8
               7 active_ind = i2
               7 comment = vc
               7 max_dose = f8
               7 max_dose_unit = vc
               7 max_dose_unit_cki = vc
               7 from_variance_percent = f8
               7 to_variance_percent = f8
           5 active_ind = i2
           5 multum_case_id = i4
           5 route_group = vc
           5 drc_identifier = vc
       3 build_contributor = vc
       3 active_ind = i2
 )
 FREE SET temp_kia
 RECORD temp_kia(
   1 import_method_flag = i2
   1 domain_flag = i2
   1 drc_obj_list[*]
     2 drc_obj
       3 grouper_name = vc
       3 grouper_id = i4
       3 facility_flex_ind = i2
       3 facility_disp = vc
       3 qualifier_list[*]
         4 qualifier
           5 qualifier_id = i4
           5 age_operator = c12
           5 from_age = f8
           5 to_age = f8
           5 age_unit = vc
           5 age_unit_cki = vc
           5 pma_operator = vc
           5 from_pma = f8
           5 to_pma = f8
           5 pma_unit = vc
           5 pma_unit_cki = vc
           5 weight_operator = c12
           5 from_weight = f8
           5 to_weight = f8
           5 weight_unit = vc
           5 weight_unit_cki = vc
           5 renal_operator = c12
           5 from_renal = f8
           5 to_renal = f8
           5 renal_unit = vc
           5 renal_unit_cki = vc
           5 hepatic_dysfunction_ind = i2
           5 concept_cki = vc
           5 route_list[*]
             6 route
               7 route_id = i4
               7 route_disp = vc
               7 route_cki = vc
               7 active_ind = i2
           5 dose_range_list[*]
             6 dose_range
               7 dose_range_id = i4
               7 dose_range_type = vc
               7 from_dose_amount = f8
               7 to_dose_amount = f8
               7 dose_unit = vc
               7 dose_unit_cki = vc
               7 dose_days = f8
               7 active_ind = i2
               7 comment = vc
               7 max_dose = f8
               7 max_dose_unit = vc
               7 max_dose_unit_cki = vc
               7 from_variance_percent = f8
               7 to_variance_percent = f8
           5 active_ind = i2
           5 multum_case_id = i4
           5 route_group = vc
           5 drc_identifier = vc
       3 build_contributor = vc
       3 active_ind = i2
 )
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET sub_cnt = 0
 SET list_cnt = 0
 SET tot_cnt = 0
 SET cnt2 = 0
 SET tot_cnt2 = 0
 SET cnt = size(request->current_drc_info,5)
 FOR (x = 1 TO cnt)
   IF ((request->current_drc_info[x].action_flag=2))
    UPDATE  FROM drc_premise d
     SET d.active_ind = request->current_drc_info[x].active_ind, d.updt_dt_tm = cnvtdatetime(curdate,
       curtime3), d.updt_id = reqinfo->updt_id,
      d.updt_task = reqinfo->updt_task, d.updt_applctx = reqinfo->updt_applctx, d.updt_cnt = (d
      .updt_cnt+ 1)
     WHERE (d.drc_premise_id=request->current_drc_info[x].parent_premise_id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "Y"
     SET reply->error_msg = concat("Unable to update current data in the drc_premise table",
      " with parent_premise_id = ",cnvtstring(request->current_drc_info[x].parent_premise_id))
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
 SET cnt = size(request->new_drc_info,5)
 SET stat = alterlist(temp_kia->drc_obj_list,cnt)
 SET temp_kia->import_method_flag = 1
 SET temp_kia->domain_flag = 0
 IF (cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = cnt),
    mltm_drc_premise m,
    dcp_entity_reltn der,
    drc_form_reltn dfr,
    code_value cv
   PLAN (d)
    JOIN (m
    WHERE (m.grouper_id=request->new_drc_info[d.seq].grouper_id)
     AND (m.drc_identifier=request->new_drc_info[d.seq].drc_identifier))
    JOIN (der
    WHERE der.entity_reltn_mean="DRC/ROUTE"
     AND der.entity1_id=m.route_id
     AND der.active_ind=1)
    JOIN (dfr
    WHERE m.grouper_id=dfr.drc_group_id)
    JOIN (cv
    WHERE cv.code_value=der.entity2_id)
   ORDER BY d.seq, m.grouper_id, m.drc_identifier
   HEAD d.seq
    temp_kia->drc_obj_list[d.seq].drc_obj.grouper_name = m.grouper_name, temp_kia->drc_obj_list[d.seq
    ].drc_obj.grouper_id = m.grouper_id, temp_kia->drc_obj_list[d.seq].drc_obj.facility_flex_ind = 0,
    temp_kia->drc_obj_list[d.seq].drc_obj.facility_disp = "Default", temp_kia->drc_obj_list[d.seq].
    drc_obj.build_contributor = "MULTUM INSTALL", temp_kia->drc_obj_list[d.seq].drc_obj.active_ind =
    dfr.active_ind,
    cnt2 = 0, tot_cnt2 = 0, stat = alterlist(temp_kia->drc_obj_list[d.seq].drc_obj.qualifier_list,10)
   HEAD m.drc_identifier
    cnt2 = (cnt2+ 1), tot_cnt2 = (tot_cnt2+ 1)
    IF (tot_cnt2 > 10)
     stat = alterlist(temp_kia->drc_obj_list[d.seq].drc_obj.qualifier_list,(cnt2+ 10)), tot_cnt2 = 1
    ENDIF
    temp_kia->drc_obj_list[d.seq].drc_obj.qualifier_list[cnt2].qualifier.qualifier_id = 0.0, temp_kia
    ->drc_obj_list[d.seq].drc_obj.qualifier_list[cnt2].qualifier.age_operator = trim(substring(1,12,m
      .age_operator_txt)), temp_kia->drc_obj_list[d.seq].drc_obj.qualifier_list[cnt2].qualifier.
    from_age = m.age_low_nbr,
    temp_kia->drc_obj_list[d.seq].drc_obj.qualifier_list[cnt2].qualifier.to_age = m.age_high_nbr,
    temp_kia->drc_obj_list[d.seq].drc_obj.qualifier_list[cnt2].qualifier.age_unit = m.age_unit_disp,
    temp_kia->drc_obj_list[d.seq].drc_obj.qualifier_list[cnt2].qualifier.age_unit_cki = m
    .age_unit_cki,
    temp_kia->drc_obj_list[d.seq].drc_obj.qualifier_list[cnt2].qualifier.pma_operator = m
    .corrected_gest_age_oper_txt, temp_kia->drc_obj_list[d.seq].drc_obj.qualifier_list[cnt2].
    qualifier.from_pma = m.corrected_gest_age_low_nbr, temp_kia->drc_obj_list[d.seq].drc_obj.
    qualifier_list[cnt2].qualifier.to_pma = m.corrected_gest_age_high_nbr,
    temp_kia->drc_obj_list[d.seq].drc_obj.qualifier_list[cnt2].qualifier.pma_unit = m
    .corrected_gest_age_unit_disp, temp_kia->drc_obj_list[d.seq].drc_obj.qualifier_list[cnt2].
    qualifier.pma_unit_cki = m.corrected_gest_age_cki, temp_kia->drc_obj_list[d.seq].drc_obj.
    qualifier_list[cnt2].qualifier.weight_operator = trim(substring(1,12,m.weight_operator_txt)),
    temp_kia->drc_obj_list[d.seq].drc_obj.qualifier_list[cnt2].qualifier.from_weight = m
    .weight_low_value, temp_kia->drc_obj_list[d.seq].drc_obj.qualifier_list[cnt2].qualifier.to_weight
     = m.weight_high_value, temp_kia->drc_obj_list[d.seq].drc_obj.qualifier_list[cnt2].qualifier.
    weight_unit = m.weight_unit_disp,
    temp_kia->drc_obj_list[d.seq].drc_obj.qualifier_list[cnt2].qualifier.weight_unit_cki = m
    .weight_unit_cki, temp_kia->drc_obj_list[d.seq].drc_obj.qualifier_list[cnt2].qualifier.
    renal_operator = trim(substring(1,12,m.renal_operator_txt)), temp_kia->drc_obj_list[d.seq].
    drc_obj.qualifier_list[cnt2].qualifier.from_renal = m.renal_low_value,
    temp_kia->drc_obj_list[d.seq].drc_obj.qualifier_list[cnt2].qualifier.to_renal = m
    .renal_high_value, temp_kia->drc_obj_list[d.seq].drc_obj.qualifier_list[cnt2].qualifier.
    renal_unit = m.renal_unit_disp, temp_kia->drc_obj_list[d.seq].drc_obj.qualifier_list[cnt2].
    qualifier.renal_unit_cki = m.renal_unit_cki
    IF (cnvtupper(m.liver_desc)="YES")
     temp_kia->drc_obj_list[d.seq].drc_obj.qualifier_list[cnt2].qualifier.hepatic_dysfunction_ind = 1
    ELSE
     temp_kia->drc_obj_list[d.seq].drc_obj.qualifier_list[cnt2].qualifier.hepatic_dysfunction_ind = 0
    ENDIF
    temp_kia->drc_obj_list[d.seq].drc_obj.qualifier_list[cnt2].qualifier.concept_cki = m
    .condition_concept_cki, temp_kia->drc_obj_list[d.seq].drc_obj.qualifier_list[cnt2].qualifier.
    active_ind = request->new_drc_info[d.seq].active_ind, temp_kia->drc_obj_list[d.seq].drc_obj.
    qualifier_list[cnt2].qualifier.multum_case_id = m.multum_case_id,
    temp_kia->drc_obj_list[d.seq].drc_obj.qualifier_list[cnt2].qualifier.route_group = "", temp_kia->
    drc_obj_list[d.seq].drc_obj.qualifier_list[cnt2].qualifier.drc_identifier = m.drc_identifier,
    cnt3 = 0,
    tot_cnt3 = 0, cnt4 = 0, tot_cnt4 = 0,
    stat = alterlist(temp_kia->drc_obj_list[d.seq].drc_obj.qualifier_list[cnt2].qualifier.route_list,
     10), stat = alterlist(temp_kia->drc_obj_list[d.seq].drc_obj.qualifier_list[cnt2].qualifier.
     dose_range_list,10)
   HEAD m.route_id
    cnt3 = (cnt3+ 1), tot_cnt3 = (tot_cnt3+ 1)
    IF (tot_cnt3 > 10)
     stat = alterlist(temp_kia->drc_obj_list[d.seq].drc_obj.qualifier_list[cnt2].qualifier.route_list,
      (cnt3+ 10)), tot_cnt3 = 1
    ENDIF
    temp_kia->drc_obj_list[d.seq].drc_obj.qualifier_list[cnt2].qualifier.route_list[cnt3].route.
    route_id = 0, temp_kia->drc_obj_list[d.seq].drc_obj.qualifier_list[cnt2].qualifier.route_list[
    cnt3].route.route_disp = cv.display, temp_kia->drc_obj_list[d.seq].drc_obj.qualifier_list[cnt2].
    qualifier.route_list[cnt3].route.route_cki = "",
    temp_kia->drc_obj_list[d.seq].drc_obj.qualifier_list[cnt2].qualifier.route_list[cnt3].route.
    active_ind = 1
   DETAIL
    cnt4 = (cnt4+ 1), tot_cnt4 = (tot_cnt4+ 1)
    IF (tot_cnt4 > 10)
     stat = alterlist(temp_kia->drc_obj_list[d.seq].drc_obj.qualifier_list[cnt2].qualifier.
      dose_range_list,(cnt4+ 10)), tot_cnt4 = 1
    ENDIF
    temp_kia->drc_obj_list[d.seq].drc_obj.qualifier_list[cnt2].qualifier.dose_range_list[cnt4].
    dose_range.dose_range_id = 0.0, temp_kia->drc_obj_list[d.seq].drc_obj.qualifier_list[cnt2].
    qualifier.dose_range_list[cnt4].dose_range.dose_range_type = m.dose_range_type, temp_kia->
    drc_obj_list[d.seq].drc_obj.qualifier_list[cnt2].qualifier.dose_range_list[cnt4].dose_range.
    from_dose_amount = m.low_dose_value,
    temp_kia->drc_obj_list[d.seq].drc_obj.qualifier_list[cnt2].qualifier.dose_range_list[cnt4].
    dose_range.to_dose_amount = m.high_dose_value, temp_kia->drc_obj_list[d.seq].drc_obj.
    qualifier_list[cnt2].qualifier.dose_range_list[cnt4].dose_range.dose_unit = m.dose_unit_disp,
    temp_kia->drc_obj_list[d.seq].drc_obj.qualifier_list[cnt2].qualifier.dose_range_list[cnt4].
    dose_range.dose_unit_cki = m.dose_unit_cki,
    temp_kia->drc_obj_list[d.seq].drc_obj.qualifier_list[cnt2].qualifier.dose_range_list[cnt4].
    dose_range.dose_days = 0.0, temp_kia->drc_obj_list[d.seq].drc_obj.qualifier_list[cnt2].qualifier.
    dose_range_list[cnt4].dose_range.active_ind = 1, temp_kia->drc_obj_list[d.seq].drc_obj.
    qualifier_list[cnt2].qualifier.dose_range_list[cnt4].dose_range.comment = m.comment_txt,
    temp_kia->drc_obj_list[d.seq].drc_obj.qualifier_list[cnt2].qualifier.dose_range_list[cnt4].
    dose_range.from_variance_percent = 0, temp_kia->drc_obj_list[d.seq].drc_obj.qualifier_list[cnt2].
    qualifier.dose_range_list[cnt4].dose_range.to_variance_percent = 0, temp_kia->drc_obj_list[d.seq]
    .drc_obj.qualifier_list[cnt2].qualifier.dose_range_list[cnt4].dose_range.max_dose = m
    .max_dose_amt,
    temp_kia->drc_obj_list[d.seq].drc_obj.qualifier_list[cnt2].qualifier.dose_range_list[cnt4].
    dose_range.max_dose_unit = m.max_dose_unit_disp, temp_kia->drc_obj_list[d.seq].drc_obj.
    qualifier_list[cnt2].qualifier.dose_range_list[cnt4].dose_range.max_dose_unit_cki = m
    .max_dose_unit_cki
   FOOT  m.drc_identifier
    stat = alterlist(temp_kia->drc_obj_list[d.seq].drc_obj.qualifier_list[cnt2].qualifier.route_list,
     cnt3), stat = alterlist(temp_kia->drc_obj_list[d.seq].drc_obj.qualifier_list[cnt2].qualifier.
     dose_range_list,cnt4)
   FOOT  m.grouper_id
    stat = alterlist(temp_kia->drc_obj_list[d.seq].drc_obj.qualifier_list,cnt2)
   WITH nocounter
  ;end select
  SET exe_cnt = 0
  SET kia_size = size(temp_kia->drc_obj_list,5)
  FOR (gcnt = 1 TO kia_size)
    SET exe_cnt = (exe_cnt+ 1)
    SET stat = alterlist(request_kia->drc_obj_list,exe_cnt)
    SET request_kia->drc_obj_list[exe_cnt].drc_obj.grouper_name = temp_kia->drc_obj_list[gcnt].
    drc_obj.grouper_name
    SET request_kia->drc_obj_list[exe_cnt].drc_obj.grouper_id = temp_kia->drc_obj_list[gcnt].drc_obj.
    grouper_id
    SET request_kia->drc_obj_list[exe_cnt].drc_obj.facility_flex_ind = temp_kia->drc_obj_list[gcnt].
    drc_obj.facility_flex_ind
    SET request_kia->drc_obj_list[exe_cnt].drc_obj.facility_disp = temp_kia->drc_obj_list[gcnt].
    drc_obj.facility_disp
    SET request_kia->drc_obj_list[exe_cnt].drc_obj.build_contributor = temp_kia->drc_obj_list[gcnt].
    drc_obj.build_contributor
    SET request_kia->drc_obj_list[exe_cnt].drc_obj.active_ind = temp_kia->drc_obj_list[gcnt].drc_obj.
    active_ind
    SET q_kia_size = size(temp_kia->drc_obj_list[gcnt].drc_obj.qualifier_list,5)
    SET stat = alterlist(request_kia->drc_obj_list[exe_cnt].drc_obj.qualifier_list,q_kia_size)
    FOR (qcnt = 1 TO q_kia_size)
      SET request_kia->drc_obj_list[exe_cnt].drc_obj.qualifier_list[qcnt].qualifier.qualifier_id =
      temp_kia->drc_obj_list[gcnt].drc_obj.qualifier_list[qcnt].qualifier.qualifier_id
      SET request_kia->drc_obj_list[exe_cnt].drc_obj.qualifier_list[qcnt].qualifier.age_operator =
      temp_kia->drc_obj_list[gcnt].drc_obj.qualifier_list[qcnt].qualifier.age_operator
      SET request_kia->drc_obj_list[exe_cnt].drc_obj.qualifier_list[qcnt].qualifier.from_age =
      temp_kia->drc_obj_list[gcnt].drc_obj.qualifier_list[qcnt].qualifier.from_age
      SET request_kia->drc_obj_list[exe_cnt].drc_obj.qualifier_list[qcnt].qualifier.to_age = temp_kia
      ->drc_obj_list[gcnt].drc_obj.qualifier_list[qcnt].qualifier.to_age
      SET request_kia->drc_obj_list[exe_cnt].drc_obj.qualifier_list[qcnt].qualifier.age_unit =
      temp_kia->drc_obj_list[gcnt].drc_obj.qualifier_list[qcnt].qualifier.age_unit
      SET request_kia->drc_obj_list[exe_cnt].drc_obj.qualifier_list[qcnt].qualifier.age_unit_cki =
      temp_kia->drc_obj_list[gcnt].drc_obj.qualifier_list[qcnt].qualifier.age_unit_cki
      SET request_kia->drc_obj_list[exe_cnt].drc_obj.qualifier_list[qcnt].qualifier.pma_operator =
      temp_kia->drc_obj_list[gcnt].drc_obj.qualifier_list[qcnt].qualifier.pma_operator
      SET request_kia->drc_obj_list[exe_cnt].drc_obj.qualifier_list[qcnt].qualifier.from_pma =
      temp_kia->drc_obj_list[gcnt].drc_obj.qualifier_list[qcnt].qualifier.from_pma
      SET request_kia->drc_obj_list[exe_cnt].drc_obj.qualifier_list[qcnt].qualifier.to_pma = temp_kia
      ->drc_obj_list[gcnt].drc_obj.qualifier_list[qcnt].qualifier.to_pma
      SET request_kia->drc_obj_list[exe_cnt].drc_obj.qualifier_list[qcnt].qualifier.pma_unit =
      temp_kia->drc_obj_list[gcnt].drc_obj.qualifier_list[qcnt].qualifier.pma_unit
      SET request_kia->drc_obj_list[exe_cnt].drc_obj.qualifier_list[qcnt].qualifier.pma_unit_cki =
      temp_kia->drc_obj_list[gcnt].drc_obj.qualifier_list[qcnt].qualifier.pma_unit_cki
      SET request_kia->drc_obj_list[exe_cnt].drc_obj.qualifier_list[qcnt].qualifier.weight_operator
       = temp_kia->drc_obj_list[gcnt].drc_obj.qualifier_list[qcnt].qualifier.weight_operator
      SET request_kia->drc_obj_list[exe_cnt].drc_obj.qualifier_list[qcnt].qualifier.from_weight =
      temp_kia->drc_obj_list[gcnt].drc_obj.qualifier_list[qcnt].qualifier.from_weight
      SET request_kia->drc_obj_list[exe_cnt].drc_obj.qualifier_list[qcnt].qualifier.to_weight =
      temp_kia->drc_obj_list[gcnt].drc_obj.qualifier_list[qcnt].qualifier.to_weight
      SET request_kia->drc_obj_list[exe_cnt].drc_obj.qualifier_list[qcnt].qualifier.weight_unit =
      temp_kia->drc_obj_list[gcnt].drc_obj.qualifier_list[qcnt].qualifier.weight_unit
      SET request_kia->drc_obj_list[exe_cnt].drc_obj.qualifier_list[qcnt].qualifier.weight_unit_cki
       = temp_kia->drc_obj_list[gcnt].drc_obj.qualifier_list[qcnt].qualifier.weight_unit_cki
      SET request_kia->drc_obj_list[exe_cnt].drc_obj.qualifier_list[qcnt].qualifier.renal_operator =
      temp_kia->drc_obj_list[gcnt].drc_obj.qualifier_list[qcnt].qualifier.renal_operator
      SET request_kia->drc_obj_list[exe_cnt].drc_obj.qualifier_list[qcnt].qualifier.from_renal =
      temp_kia->drc_obj_list[gcnt].drc_obj.qualifier_list[qcnt].qualifier.from_renal
      SET request_kia->drc_obj_list[exe_cnt].drc_obj.qualifier_list[qcnt].qualifier.to_renal =
      temp_kia->drc_obj_list[gcnt].drc_obj.qualifier_list[qcnt].qualifier.to_renal
      SET request_kia->drc_obj_list[exe_cnt].drc_obj.qualifier_list[qcnt].qualifier.renal_unit =
      temp_kia->drc_obj_list[gcnt].drc_obj.qualifier_list[qcnt].qualifier.renal_unit
      SET request_kia->drc_obj_list[exe_cnt].drc_obj.qualifier_list[qcnt].qualifier.renal_unit_cki =
      temp_kia->drc_obj_list[gcnt].drc_obj.qualifier_list[qcnt].qualifier.renal_unit_cki
      SET request_kia->drc_obj_list[exe_cnt].drc_obj.qualifier_list[qcnt].qualifier.
      hepatic_dysfunction_ind = temp_kia->drc_obj_list[gcnt].drc_obj.qualifier_list[qcnt].qualifier.
      hepatic_dysfunction_ind
      SET request_kia->drc_obj_list[exe_cnt].drc_obj.qualifier_list[qcnt].qualifier.concept_cki =
      temp_kia->drc_obj_list[gcnt].drc_obj.qualifier_list[qcnt].qualifier.concept_cki
      SET request_kia->drc_obj_list[exe_cnt].drc_obj.qualifier_list[qcnt].qualifier.active_ind =
      temp_kia->drc_obj_list[gcnt].drc_obj.qualifier_list[qcnt].qualifier.active_ind
      SET request_kia->drc_obj_list[exe_cnt].drc_obj.qualifier_list[qcnt].qualifier.multum_case_id =
      temp_kia->drc_obj_list[gcnt].drc_obj.qualifier_list[qcnt].qualifier.multum_case_id
      SET request_kia->drc_obj_list[exe_cnt].drc_obj.qualifier_list[qcnt].qualifier.route_group =
      temp_kia->drc_obj_list[gcnt].drc_obj.qualifier_list[qcnt].qualifier.route_group
      SET request_kia->drc_obj_list[exe_cnt].drc_obj.qualifier_list[qcnt].qualifier.drc_identifier =
      temp_kia->drc_obj_list[gcnt].drc_obj.qualifier_list[qcnt].qualifier.drc_identifier
      SET kia_rcnt = size(temp_kia->drc_obj_list[gcnt].drc_obj.qualifier_list[qcnt].qualifier.
       route_list,5)
      SET stat = alterlist(request_kia->drc_obj_list[exe_cnt].drc_obj.qualifier_list[qcnt].qualifier.
       route_list,kia_rcnt)
      FOR (rcnt = 1 TO kia_rcnt)
        SET request_kia->drc_obj_list[exe_cnt].drc_obj.qualifier_list[qcnt].qualifier.route_list[rcnt
        ].route.route_id = temp_kia->drc_obj_list[gcnt].drc_obj.qualifier_list[qcnt].qualifier.
        route_list[rcnt].route.route_id
        SET request_kia->drc_obj_list[exe_cnt].drc_obj.qualifier_list[qcnt].qualifier.route_list[rcnt
        ].route.route_disp = temp_kia->drc_obj_list[gcnt].drc_obj.qualifier_list[qcnt].qualifier.
        route_list[rcnt].route.route_disp
        SET request_kia->drc_obj_list[exe_cnt].drc_obj.qualifier_list[qcnt].qualifier.route_list[rcnt
        ].route.route_cki = temp_kia->drc_obj_list[gcnt].drc_obj.qualifier_list[qcnt].qualifier.
        route_list[rcnt].route.route_cki
        SET request_kia->drc_obj_list[exe_cnt].drc_obj.qualifier_list[qcnt].qualifier.route_list[rcnt
        ].route.active_ind = temp_kia->drc_obj_list[gcnt].drc_obj.qualifier_list[qcnt].qualifier.
        route_list[rcnt].route.active_ind
      ENDFOR
      SET kia_dcnt = size(temp_kia->drc_obj_list[gcnt].drc_obj.qualifier_list[qcnt].qualifier.
       dose_range_list,5)
      SET stat = alterlist(request_kia->drc_obj_list[exe_cnt].drc_obj.qualifier_list[qcnt].qualifier.
       dose_range_list,kia_dcnt)
      FOR (dcnt = 1 TO kia_dcnt)
        SET request_kia->drc_obj_list[exe_cnt].drc_obj.qualifier_list[qcnt].qualifier.
        dose_range_list[dcnt].dose_range.dose_range_id = temp_kia->drc_obj_list[gcnt].drc_obj.
        qualifier_list[qcnt].qualifier.dose_range_list[dcnt].dose_range.dose_range_id
        SET request_kia->drc_obj_list[exe_cnt].drc_obj.qualifier_list[qcnt].qualifier.
        dose_range_list[dcnt].dose_range.dose_range_type = temp_kia->drc_obj_list[gcnt].drc_obj.
        qualifier_list[qcnt].qualifier.dose_range_list[dcnt].dose_range.dose_range_type
        SET request_kia->drc_obj_list[exe_cnt].drc_obj.qualifier_list[qcnt].qualifier.
        dose_range_list[dcnt].dose_range.from_dose_amount = temp_kia->drc_obj_list[gcnt].drc_obj.
        qualifier_list[qcnt].qualifier.dose_range_list[dcnt].dose_range.from_dose_amount
        SET request_kia->drc_obj_list[exe_cnt].drc_obj.qualifier_list[qcnt].qualifier.
        dose_range_list[dcnt].dose_range.to_dose_amount = temp_kia->drc_obj_list[gcnt].drc_obj.
        qualifier_list[qcnt].qualifier.dose_range_list[dcnt].dose_range.to_dose_amount
        SET request_kia->drc_obj_list[exe_cnt].drc_obj.qualifier_list[qcnt].qualifier.
        dose_range_list[dcnt].dose_range.dose_unit = temp_kia->drc_obj_list[gcnt].drc_obj.
        qualifier_list[qcnt].qualifier.dose_range_list[dcnt].dose_range.dose_unit
        SET request_kia->drc_obj_list[exe_cnt].drc_obj.qualifier_list[qcnt].qualifier.
        dose_range_list[dcnt].dose_range.dose_unit_cki = temp_kia->drc_obj_list[gcnt].drc_obj.
        qualifier_list[qcnt].qualifier.dose_range_list[dcnt].dose_range.dose_unit_cki
        SET request_kia->drc_obj_list[exe_cnt].drc_obj.qualifier_list[qcnt].qualifier.
        dose_range_list[dcnt].dose_range.dose_days = temp_kia->drc_obj_list[gcnt].drc_obj.
        qualifier_list[qcnt].qualifier.dose_range_list[dcnt].dose_range.dose_days
        SET request_kia->drc_obj_list[exe_cnt].drc_obj.qualifier_list[qcnt].qualifier.
        dose_range_list[dcnt].dose_range.active_ind = temp_kia->drc_obj_list[gcnt].drc_obj.
        qualifier_list[qcnt].qualifier.dose_range_list[dcnt].dose_range.active_ind
        SET request_kia->drc_obj_list[exe_cnt].drc_obj.qualifier_list[qcnt].qualifier.
        dose_range_list[dcnt].dose_range.comment = temp_kia->drc_obj_list[gcnt].drc_obj.
        qualifier_list[qcnt].qualifier.dose_range_list[dcnt].dose_range.comment
        SET request_kia->drc_obj_list[exe_cnt].drc_obj.qualifier_list[qcnt].qualifier.
        dose_range_list[dcnt].dose_range.from_variance_percent = temp_kia->drc_obj_list[gcnt].drc_obj
        .qualifier_list[qcnt].qualifier.dose_range_list[dcnt].dose_range.from_variance_percent
        SET request_kia->drc_obj_list[exe_cnt].drc_obj.qualifier_list[qcnt].qualifier.
        dose_range_list[dcnt].dose_range.to_variance_percent = temp_kia->drc_obj_list[gcnt].drc_obj.
        qualifier_list[qcnt].qualifier.dose_range_list[dcnt].dose_range.to_variance_percent
        SET request_kia->drc_obj_list[exe_cnt].drc_obj.qualifier_list[qcnt].qualifier.
        dose_range_list[dcnt].dose_range.max_dose = temp_kia->drc_obj_list[gcnt].drc_obj.
        qualifier_list[qcnt].qualifier.dose_range_list[dcnt].dose_range.max_dose
        SET request_kia->drc_obj_list[exe_cnt].drc_obj.qualifier_list[qcnt].qualifier.
        dose_range_list[dcnt].dose_range.max_dose_unit = temp_kia->drc_obj_list[gcnt].drc_obj.
        qualifier_list[qcnt].qualifier.dose_range_list[dcnt].dose_range.max_dose_unit
        SET request_kia->drc_obj_list[exe_cnt].drc_obj.qualifier_list[qcnt].qualifier.
        dose_range_list[dcnt].dose_range.max_dose_unit_cki = temp_kia->drc_obj_list[gcnt].drc_obj.
        qualifier_list[qcnt].qualifier.dose_range_list[dcnt].dose_range.max_dose_unit_cki
      ENDFOR
    ENDFOR
    IF (((exe_cnt=50) OR (gcnt=kia_size)) )
     SET request_kia->import_method_flag = temp_kia->import_method_flag
     SET request_kia->domain_flag = temp_kia->domain_flag
     FREE SET reply
     SET trace = recpersist
     EXECUTE kia_import_drc  WITH replace("REQUEST",request_kia)
     DECLARE child_status = c1
     SET child_status = reply->status_data.status
     SET trace = norecpersist
     FREE SET reply
     RECORD reply(
       1 error_msg = vc
       1 status_data
         2 status = c1
         2 subeventstatus[1]
           3 operationname = c25
           3 operationstatus = c1
           3 targetobjectname = c25
           3 targetobjectvalue = vc
     )
     IF (child_status="F")
      SET error_flag = "Y"
      SET reply->error_msg =
      "Unable to ensure all active groupers. View KIA_IMPORT_DRC.LOG for details."
      GO TO exit_script
     ENDIF
     SET stat = initrec(request_kia)
     SET exe_cnt = 0
    ENDIF
  ENDFOR
  SET trace = recpersist
  EXECUTE mltm_upd_mltm_drc_premise  WITH replace("REPLY",reply_mltm)
  IF ((reply_mltm->status_data.status="F"))
   SET error_flag = "Y"
   SET reply->error_msg =
   "Failure while updating mltm_drc_premise table with new drc_premise information."
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
