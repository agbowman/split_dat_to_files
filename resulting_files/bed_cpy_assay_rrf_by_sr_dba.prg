CREATE PROGRAM bed_cpy_assay_rrf_by_sr:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 FREE SET new_sr
 RECORD new_sr(
   1 sr_list[*]
     2 code_value = f8
 )
 FREE SET rrf
 RECORD rrf(
   1 rr_list[*]
     2 rrf_id = f8
     2 sequence = i4
     2 service_resource_cd = f8
 )
 FREE SET all_rrf
 RECORD all_rrf(
   1 rr_list[*]
     2 rrf_id = f8
     2 sequence = i4
 )
 RECORD version_request(
   1 task_assay_cd = f8
 )
 RECORD version_reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET assay_cnt = size(request->assays,5)
 SET count = 0
 SET tot_count = 0
 SET rlist_count = 0
 SET tot_rlist = 0
 SET all_rlist_count = 0
 SET all_tot_rlist = 0
 SET inactive_code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=48
   AND cv.cdf_meaning="INACTIVE"
   AND cv.active_ind=1
  DETAIL
   inactive_code_value = cv.code_value
  WITH nocounter
 ;end select
 IF (assay_cnt=0)
  GO TO exit_script
 ENDIF
 DECLARE error_msg = vc
 SET error_flag = "N"
 FOR (x = 1 TO assay_cnt)
   SET stat = alterlist(new_sr->sr_list,0)
   SET stat = alterlist(rrf->rr_list,0)
   SET stat = alterlist(all_rrf->rr_list,0)
   SET all_rlist_count = 0
   SET all_tot_rlist = 0
   SET rlist_count = 0
   SET tot_rlist = 0
   SET count = 0
   SET tot_count = 0
   SELECT INTO "NL:"
    FROM profile_task_r ptr,
     order_catalog oc,
     orc_resource_list orl,
     code_value cv
    PLAN (ptr
     WHERE ptr.active_ind=1
      AND (ptr.task_assay_cd=request->assays[x].code_value))
     JOIN (oc
     WHERE oc.catalog_cd=ptr.catalog_cd
      AND oc.active_ind=1)
     JOIN (orl
     WHERE orl.active_ind=1
      AND orl.catalog_cd=ptr.catalog_cd
      AND orl.service_resource_cd > 0
      AND  NOT ( EXISTS (
     (SELECT
      rrf.service_resource_cd
      FROM reference_range_factor rrf
      WHERE rrf.active_ind=1
       AND rrf.task_assay_cd=ptr.task_assay_cd
       AND rrf.service_resource_cd=orl.service_resource_cd))))
     JOIN (cv
     WHERE cv.code_value=orl.service_resource_cd
      AND cv.active_ind=1)
    ORDER BY orl.service_resource_cd
    HEAD REPORT
     stat = alterlist(new_sr->sr_list,100)
    HEAD orl.service_resource_cd
     count = (count+ 1), tot_count = (tot_count+ 1)
     IF (count > 100)
      stat = alterlist(new_sr->sr_list,(tot_count+ 100)), count = 1
     ENDIF
     new_sr->sr_list[tot_count].code_value = orl.service_resource_cd
    FOOT REPORT
     stat = alterlist(new_sr->sr_list,tot_count)
    WITH nocounter
   ;end select
   SELECT INTO "NL:"
    FROM profile_task_r ptr,
     order_catalog oc,
     assay_processing_r apr,
     code_value cv
    PLAN (ptr
     WHERE ptr.active_ind=1
      AND (ptr.task_assay_cd=request->assays[x].code_value))
     JOIN (oc
     WHERE oc.catalog_cd=ptr.catalog_cd
      AND oc.active_ind=1
      AND oc.resource_route_cd=2)
     JOIN (apr
     WHERE apr.active_ind=1
      AND (apr.task_assay_cd=request->assays[x].code_value)
      AND apr.service_resource_cd > 0
      AND  NOT ( EXISTS (
     (SELECT
      rrf.service_resource_cd
      FROM reference_range_factor rrf
      WHERE rrf.active_ind=1
       AND rrf.task_assay_cd=ptr.task_assay_cd
       AND rrf.service_resource_cd=apr.service_resource_cd))))
     JOIN (cv
     WHERE cv.code_value=apr.service_resource_cd
      AND cv.active_ind=1)
    ORDER BY apr.service_resource_cd
    HEAD apr.service_resource_cd
     found = 0
     FOR (i = 1 TO tot_count)
       IF ((new_sr->sr_list[i].code_value=apr.service_resource_cd))
        found = 1, i = tot_count
       ENDIF
     ENDFOR
     IF (found=0)
      tot_count = (tot_count+ 1), stat = alterlist(new_sr->sr_list,tot_count), new_sr->sr_list[
      tot_count].code_value = apr.service_resource_cd
     ENDIF
    WITH nocounter
   ;end select
   IF (tot_count > 0)
    FOR (i = 1 TO tot_count)
      INSERT  FROM data_map
       (task_assay_cd, min_digits, max_digits,
       min_decimal_places, service_resource_cd, data_map_type_flag,
       result_entry_format, active_status_cd, active_status_prsnl_id,
       active_status_dt_tm, active_ind, updt_applctx,
       updt_dt_tm, updt_cnt, updt_task,
       updt_id, beg_effective_dt_tm, end_effective_dt_tm)(SELECT
        request->assays[x].code_value, dm.min_digits, dm.max_digits,
        dm.min_decimal_places, new_sr->sr_list[i].code_value, dm.data_map_type_flag,
        dm.result_entry_format, dm.active_status_cd, reqinfo->updt_id,
        cnvtdatetime(curdate,curtime3), 1, reqinfo->updt_applctx,
        cnvtdatetime(curdate,curtime3), reqinfo->updt_id, 0,
        reqinfo->updt_task, cnvtdatetime(curdate,curtime3), cnvtdatetime("31-DEC-2100")
        FROM data_map dm
        WHERE dm.active_ind=1
         AND dm.service_resource_cd=0
         AND (dm.task_assay_cd=request->assays[x].code_value))
       WITH nocounter
      ;end insert
    ENDFOR
    SELECT INTO "NL:"
     FROM reference_range_factor rrf
     PLAN (rrf
      WHERE (rrf.task_assay_cd=request->assays[x].code_value)
       AND rrf.active_ind=1)
     ORDER BY rrf.precedence_sequence
     HEAD REPORT
      stat = alterlist(rrf->rr_list,50), stat = alterlist(all_rrf->rr_list,50)
     DETAIL
      IF (rrf.service_resource_cd=0)
       all_rlist_count = (all_rlist_count+ 1), all_tot_rlist = (all_tot_rlist+ 1)
       IF (all_rlist_count > 50)
        stat = alterlist(all_rrf->rr_list,(all_tot_rlist+ 50)), rlist_count = 1
       ENDIF
       all_rrf->rr_list[all_tot_rlist].rrf_id = rrf.reference_range_factor_id, all_rrf->rr_list[
       all_tot_rlist].sequence = rrf.precedence_sequence
      ELSE
       rlist_count = (rlist_count+ 1), tot_rlist = (tot_rlist+ 1)
       IF (rlist_count > 50)
        stat = alterlist(rrf->rr_list,(tot_rlist+ 50)), rlist_count = 1
       ENDIF
       rrf->rr_list[tot_rlist].rrf_id = rrf.reference_range_factor_id, rrf->rr_list[tot_rlist].
       sequence = rrf.precedence_sequence, rrf->rr_list[tot_rlist].service_resource_cd = rrf
       .service_resource_cd
      ENDIF
     FOOT REPORT
      stat = alterlist(rrf->rr_list,tot_rlist), stat = alterlist(all_rrf->rr_list,all_tot_rlist)
     WITH nocounter
    ;end select
    SET next_seq = all_rrf->rr_list[1].sequence
    FOR (y = 1 TO tot_count)
      FOR (i = 1 TO all_tot_rlist)
        SET new_rrf_id = 0.0
        SELECT INTO "NL:"
         j = seq(reference_seq,nextval)"##################;rp0"
         FROM dual
         DETAIL
          new_rrf_id = cnvtreal(j)
         WITH format, counter
        ;end select
        INSERT  FROM reference_range_factor
         (reference_range_factor_id, task_assay_cd, species_cd,
         organism_cd, service_resource_cd, active_ind,
         gestational_ind, unknown_age_ind, sex_cd,
         age_from_units_cd, age_from_minutes, age_to_units_cd,
         age_to_minutes, specimen_type_cd, patient_condition_cd,
         alpha_response_ind, default_result, review_ind,
         review_low, review_high, sensitive_ind,
         sensitive_low, sensitive_high, normal_ind,
         normal_low, normal_high, critical_ind,
         critical_low, critical_high, delta_check_type_cd,
         delta_minutes, delta_value, delta_chk_flag,
         updt_dt_tm, updt_id, updt_task,
         updt_cnt, updt_applctx, code_set,
         units_cd, precedence_sequence, active_status_cd,
         active_status_dt_tm, active_status_prsnl_id, beg_effective_dt_tm,
         end_effective_dt_tm, mins_back, def_result_ind,
         linear_ind, linear_low, linear_high,
         feasible_ind, feasible_low, feasible_high,
         dilute_ind, encntr_type_cd)(SELECT
          new_rrf_id, request->assays[x].code_value, rrf.species_cd,
          rrf.organism_cd, new_sr->sr_list[y].code_value, 1,
          rrf.gestational_ind, rrf.unknown_age_ind, rrf.sex_cd,
          rrf.age_from_units_cd, rrf.age_from_minutes, rrf.age_to_units_cd,
          rrf.age_to_minutes, rrf.specimen_type_cd, rrf.patient_condition_cd,
          rrf.alpha_response_ind, rrf.default_result, rrf.review_ind,
          rrf.review_low, rrf.review_high, rrf.sensitive_ind,
          rrf.sensitive_low, rrf.sensitive_high, rrf.normal_ind,
          rrf.normal_low, rrf.normal_high, rrf.critical_ind,
          rrf.critical_low, rrf.critical_high, rrf.delta_check_type_cd,
          rrf.delta_minutes, rrf.delta_value, rrf.delta_chk_flag,
          cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task,
          0, reqinfo->updt_applctx, rrf.code_set,
          rrf.units_cd, next_seq, rrf.active_status_cd,
          cnvtdatetime(curdate,curtime3), reqinfo->updt_id, cnvtdatetime(curdate,curtime3),
          cnvtdatetime("31-DEC-2100"), rrf.mins_back, rrf.def_result_ind,
          rrf.linear_ind, rrf.linear_low, rrf.linear_high,
          rrf.feasible_ind, rrf.feasible_low, rrf.feasible_high,
          rrf.dilute_ind, rrf.encntr_type_cd
          FROM reference_range_factor rrf
          WHERE (rrf.reference_range_factor_id=all_rrf->rr_list[i].rrf_id))
         WITH nocounter
        ;end insert
        SET next_seq = (next_seq+ 1)
        INSERT  FROM advanced_delta
         (advanced_delta_id, reference_range_factor_id, delta_ind,
         delta_low, delta_high, delta_check_type_cd,
         delta_minutes, delta_value, updt_dt_tm,
         updt_id, updt_task, updt_cnt,
         updt_applctx, active_ind, active_status_cd,
         active_status_dt_tm, active_status_prsnl_id, beg_effective_dt_tm,
         end_effective_dt_tm)(SELECT
          seq(reference_seq,nextval), new_rrf_id, ad.delta_ind,
          ad.delta_low, ad.delta_high, ad.delta_check_type_cd,
          ad.delta_minutes, ad.delta_value, cnvtdatetime(curdate,curtime3),
          reqinfo->updt_id, reqinfo->updt_task, 0,
          reqinfo->updt_applctx, 1, ad.active_status_cd,
          cnvtdatetime(curdate,curtime3), reqinfo->updt_id, cnvtdatetime(curdate,curtime3),
          cnvtdatetime("31-DEC-2100")
          FROM advanced_delta ad
          WHERE (ad.reference_range_factor_id=all_rrf->rr_list[i].rrf_id)
           AND ad.active_ind=1)
         WITH nocounter
        ;end insert
        INSERT  FROM alpha_responses
         (reference_range_factor_id, nomenclature_id, sequence,
         use_units_ind, result_process_cd, default_ind,
         description, updt_dt_tm, updt_id,
         updt_task, updt_cnt, updt_applctx,
         active_ind, active_status_cd, active_status_dt_tm,
         active_status_prsnl_id, beg_effective_dt_tm, end_effective_dt_tm,
         result_value, reference_ind, multi_alpha_sort_order)(SELECT
          new_rrf_id, ar.nomenclature_id, ar.sequence,
          ar.use_units_ind, ar.result_process_cd, ar.default_ind,
          ar.description, cnvtdatetime(curdate,curtime3), reqinfo->updt_id,
          reqinfo->updt_task, 0, reqinfo->updt_applctx,
          1, ar.active_status_cd, cnvtdatetime(curdate,curtime3),
          reqinfo->updt_id, cnvtdatetime(curdate,curtime3), cnvtdatetime("31-DEC-2100"),
          ar.result_value, ar.reference_ind, ar.multi_alpha_sort_order
          FROM alpha_responses ar
          WHERE (ar.reference_range_factor_id=all_rrf->rr_list[i].rrf_id)
           AND ar.active_ind=1)
         WITH nocounter
        ;end insert
      ENDFOR
    ENDFOR
    UPDATE  FROM alpha_responses ar,
      (dummyt d  WITH seq = all_tot_rlist)
     SET ar.active_ind = 0, ar.active_status_cd = inactive_code_value, ar.active_status_dt_tm =
      cnvtdatetime(curdate,curtime),
      ar.active_status_prsnl_id = reqinfo->updt_id, ar.updt_dt_tm = cnvtdatetime(curdate,curtime), ar
      .updt_id = reqinfo->updt_id,
      ar.updt_task = reqinfo->updt_task, ar.updt_cnt = (ar.updt_cnt+ 1), ar.updt_applctx = reqinfo->
      updt_applctx
     PLAN (d)
      JOIN (ar
      WHERE (ar.reference_range_factor_id=all_rrf->rr_list[d.seq].rrf_id)
       AND ar.active_ind=1)
     WITH nocounter
    ;end update
    UPDATE  FROM advanced_delta ad,
      (dummyt d  WITH seq = all_tot_rlist)
     SET ad.active_ind = 0, ad.active_status_cd = inactive_code_value, ad.active_status_dt_tm =
      cnvtdatetime(curdate,curtime),
      ad.active_status_prsnl_id = reqinfo->updt_id, ad.updt_dt_tm = cnvtdatetime(curdate,curtime), ad
      .updt_id = reqinfo->updt_id,
      ad.updt_task = reqinfo->updt_task, ad.updt_cnt = (ad.updt_cnt+ 1), ad.updt_applctx = reqinfo->
      updt_applctx
     PLAN (d)
      JOIN (ad
      WHERE (ad.reference_range_factor_id=all_rrf->rr_list[d.seq].rrf_id)
       AND ad.active_ind=1)
     WITH nocounter
    ;end update
    UPDATE  FROM reference_range_factor rrf,
      (dummyt d  WITH seq = all_tot_rlist)
     SET rrf.active_ind = 0, rrf.active_status_cd = inactive_code_value, rrf.active_status_dt_tm =
      cnvtdatetime(curdate,curtime),
      rrf.active_status_prsnl_id = reqinfo->updt_id, rrf.end_effective_dt_tm = cnvtdatetime(curdate,
       curtime), rrf.updt_id = reqinfo->updt_id,
      rrf.updt_dt_tm = cnvtdatetime(curdate,curtime), rrf.updt_task = reqinfo->updt_task, rrf
      .updt_applctx = reqinfo->updt_applctx,
      rrf.updt_cnt = (rrf.updt_cnt+ 1)
     PLAN (d)
      JOIN (rrf
      WHERE (rrf.reference_range_factor_id=all_rrf->rr_list[d.seq].rrf_id))
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to inactivate reference range for ",trim(request->assays[x].
       code_value),".")
     GO TO exit_script
    ENDIF
    IF (tot_rlist > 0)
     FOR (r = 1 TO tot_rlist)
       IF ((all_rrf->rr_list[1].sequence < rrf->rr_list[r].sequence))
        UPDATE  FROM reference_range_factor rrf
         SET rrf.precedence_sequence = next_seq, rrf.updt_id = reqinfo->updt_id, rrf.updt_dt_tm =
          cnvtdatetime(curdate,curtime),
          rrf.updt_task = reqinfo->updt_task, rrf.updt_applctx = reqinfo->updt_applctx, rrf.updt_cnt
           = (rrf.updt_cnt+ 1)
         WHERE (rrf.reference_range_factor_id=rrf->rr_list[r].rrf_id)
         WITH nocounter
        ;end update
        SET next_seq = (next_seq+ 1)
        IF (curqual=0)
         SET error_flag = "Y"
         SET error_msg = concat("Unable to update existing SR specific reference range for ",rrf->
          rr_list[r].rrf_id,".")
         GO TO exit_script
        ENDIF
       ENDIF
     ENDFOR
    ENDIF
    IF (checkprg("DCP_ADD_DTA_VERSION"))
     SET version_request->task_assay_cd = request->assays[x].code_value
     EXECUTE dcp_add_dta_version  WITH replace("REQUEST","VERSION_REQUEST"), replace("REPLY",
      "VERSION_REPLY")
     IF ((version_reply->status_data.status="F"))
      SET error_flag = "Y"
      SET error_msg = concat("Unable to version dta: ",cnvtstring(request->assays[x].code_value))
      GO TO exit_script
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  CALL echo(error_msg)
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
