CREATE PROGRAM bbt_add_interpretations:dba
 RECORD reply(
   1 interp_id = f8
   1 comp_data[*]
     2 comp_id = f8
     2 comp_assay_cd = f8
     2 range_data[*]
       3 range_id = f8
       3 hash_data[*]
         4 hash_id = f8
         4 hash_string = vc
         4 range_id = f8
   1 result_data[*]
     2 result_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c15
       3 sourceobjectqual = i4
       3 sourceobjectvalue = c50
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c50
       3 sub_event_dt_tm = di8
 )
 RECORD current(
   1 system_dt_tm = dq8
 )
 SET current->system_dt_tm = cnvtdatetime(curdate,curtime3)
 SET reply->status_data.status = "F"
 DECLARE failures = i4 WITH protect, noconstant(0)
 DECLARE hold_interp_cd = f8 WITH protect, noconstant(request->interp_id)
 DECLARE hold_comp_cd = f8 WITH protect, noconstant(0.0)
 DECLARE hold_range_cd = f8 WITH protect, noconstant(0.0)
 DECLARE hold_hash_cd = f8 WITH protect, noconstant(0.0)
 DECLARE new_interp_result_id = f8 WITH protect, noconstant(0.0)
 DECLARE next_code = f8 WITH protect, noconstant(0.0)
 DECLARE text_code = f8 WITH protect, noconstant(0.0)
 DECLARE count2 = i4 WITH protect, noconstant(0)
 IF ((request->task_assay_flag="T"))
  EXECUTE cpm_next_code
  SET hold_interp_cd = next_code
  INSERT  FROM interp_task_assay ita
   SET ita.interp_id = hold_interp_cd, ita.task_assay_cd = request->task_assay_cd, ita.interp_type_cd
     = request->interp_type_cd,
    ita.generate_interp_flag = request->system_ind, ita.interp_option_cd =
    IF ((request->interp_option_cd=0)) 0
    ELSE request->interp_option_cd
    ENDIF
    , ita.service_resource_cd =
    IF ((request->service_resource_cd=- (1))) 0
    ELSE request->service_resource_cd
    ENDIF
    ,
    ita.order_cat_cd =
    IF ((request->order_catalog_cd=- (1))) 0
    ELSE request->order_catalog_cd
    ENDIF
    , ita.phase_cd = 0, ita.active_ind = 1,
    ita.active_status_cd = reqdata->active_status_cd, ita.active_status_prsnl_id = reqinfo->updt_id,
    ita.active_status_dt_tm = cnvtdatetime(current->system_dt_tm),
    ita.updt_cnt = 0, ita.updt_dt_tm = cnvtdatetime(current->system_dt_tm), ita.updt_id = reqinfo->
    updt_id,
    ita.updt_task = reqinfo->updt_task, ita.updt_applctx = reqinfo->updt_applctx
  ;end insert
  SET reply->interp_id = hold_interp_cd WITH nocounter
  IF (curqual=0)
   SET failures = 1
   SET count2 = (count2+ 1)
   SET reply->status_data.subeventstatus[count2].sourceobjectname = "script"
   SET reply->status_data.subeventstatus[count2].sourceobjectvalue = "bbt_add_interpretations"
   SET reply->status_data.subeventstatus[count2].operationname = "Update"
   SET reply->status_data.subeventstatus[count2].operationstatus = "F"
   SET reply->status_data.subeventstatus[count2].targetobjectname = "Interp Task Assay"
   SET reply->status_data.subeventstatus[count2].targetobjectvalue = "task_assay_cd"
   SET reply->status_data.subeventstatus[count2].sourceobjectqual = 1
   SET reply->status_data.subeventstatus[count2].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
   GO TO exit_script
  ENDIF
 ENDIF
#insert_component
 FOR (x = 1 TO request->component_cnt)
  IF ((request->comp_data[x].component_flag="T"))
   SET next_code = 0.0
   EXECUTE cpm_next_code
   SET hold_comp_cd = next_code
   INSERT  FROM interp_component ic
    SET ic.interp_id = hold_interp_cd, ic.interp_detail_id = hold_comp_cd, ic.sequence = request->
     comp_data[x].sequence,
     ic.verified_flag = request->comp_data[x].verified_flag, ic.included_assay_cd = request->
     comp_data[x].inc_assay_cd, ic.cross_drawn_dt_tm_ind = request->comp_data[x].cross_time_ind,
     ic.time_window_minutes =
     IF ((request->comp_data[x].time_window_min=- (1))) null
     ELSE request->comp_data[x].time_window_min
     ENDIF
     , ic.time_window_units_cd =
     IF ((request->comp_data[x].time_window_units_cd=- (1))) 0
     ELSE request->comp_data[x].time_window_units_cd
     ENDIF
     , ic.result_req_flag = request->comp_data[x].result_required_flag,
     ic.active_ind = 1, ic.active_status_cd = reqdata->active_status_cd, ic.active_status_prsnl_id =
     reqinfo->updt_id,
     ic.active_status_dt_tm = cnvtdatetime(current->system_dt_tm), ic.updt_cnt = 0, ic.updt_dt_tm =
     cnvtdatetime(current->system_dt_tm),
     ic.updt_id = reqinfo->updt_id, ic.updt_task = reqinfo->updt_task, ic.updt_applctx = reqinfo->
     updt_applctx
   ;end insert
   SET stat = alterlist(reply->comp_data,x)
   SET reply->comp_data[x].comp_id = hold_comp_cd
   SET reply->comp_data[x].comp_assay_cd = request->comp_data[x].inc_assay_cd WITH counter
   IF (curqual=0)
    SET failures = 1
    SET count2 = (count2+ 1)
    SET reply->status_data.subeventstatus[count2].sourceobjectname = "script"
    SET reply->status_data.subeventstatus[count2].sourceobjectvalue = "bbt_add_interpretations"
    SET reply->status_data.subeventstatus[count2].operationname = "Update"
    SET reply->status_data.subeventstatus[count2].operationstatus = "F"
    SET reply->status_data.subeventstatus[count2].targetobjectname = "Interp Component"
    SET reply->status_data.subeventstatus[count2].targetobjectvalue = "inc_assay_cd"
    SET reply->status_data.subeventstatus[count2].sourceobjectqual = 1
    SET reply->status_data.subeventstatus[count2].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
    GO TO exit_script
   ENDIF
  ELSE
   SET stat = alterlist(reply->comp_data,x)
   SET reply->comp_data[x].comp_id = 0.0
   SET reply->comp_data[x].comp_assay_cd = 0.0
  ENDIF
  FOR (y = 1 TO request->comp_data[x].range_count)
   IF ((request->comp_data[x].range_data[y].range_flag="T"))
    SET next_code = 0.0
    EXECUTE cpm_next_code
    SET hold_range_cd = next_code
    INSERT  FROM interp_range ir
     SET ir.interp_range_id = hold_range_cd, ir.interp_detail_id =
      IF (hold_comp_cd=0.0) request->comp_data[x].comp_id
      ELSE hold_comp_cd
      ENDIF
      , ir.interp_id = hold_interp_cd,
      ir.sequence = request->comp_data[x].range_data[y].sequence, ir.included_assay_cd = request->
      comp_data[x].range_data[y].inc_assay_cd, ir.unknown_age_ind = request->comp_data[x].range_data[
      y].unknown_age_ind,
      ir.age_from_units_cd =
      IF ((request->comp_data[x].range_data[y].age_from_min_cd=- (1))) 0
      ELSE request->comp_data[x].range_data[y].age_from_min_cd
      ENDIF
      , ir.age_from_minutes =
      IF ((request->comp_data[x].range_data[y].age_from_min=- (1))) null
      ELSE request->comp_data[x].range_data[y].age_from_min
      ENDIF
      , ir.age_to_units_cd =
      IF ((request->comp_data[x].range_data[y].age_to_units_cd=- (1))) 0
      ELSE request->comp_data[x].range_data[y].age_to_units_cd
      ENDIF
      ,
      ir.age_to_minutes =
      IF ((request->comp_data[x].range_data[y].age_to_minutes=- (1))) null
      ELSE request->comp_data[x].range_data[y].age_to_minutes
      ENDIF
      , ir.species_cd =
      IF ((request->comp_data[x].range_data[y].species_cd=- (1))) 0
      ELSE request->comp_data[x].range_data[y].species_cd
      ENDIF
      , ir.gender_cd =
      IF ((request->comp_data[x].range_data[y].sex_cd=- (1))) 0
      ELSE request->comp_data[x].range_data[y].sex_cd
      ENDIF
      ,
      ir.race_cd =
      IF ((request->comp_data[x].range_data[y].race_cd=- (1))) 0
      ELSE request->comp_data[x].range_data[y].race_cd
      ENDIF
      , ir.active_ind = 1, ir.active_status_cd = reqdata->active_status_cd,
      ir.active_status_prsnl_id = reqinfo->updt_id, ir.active_status_dt_tm = cnvtdatetime(current->
       system_dt_tm), ir.updt_cnt = 0,
      ir.updt_dt_tm = cnvtdatetime(current->system_dt_tm), ir.updt_id = reqinfo->updt_id, ir
      .updt_task = reqinfo->updt_task,
      ir.updt_applctx = reqinfo->updt_applctx
    ;end insert
    SET stat = alterlist(reply->comp_data[x].range_data,y)
    SET reply->comp_data[x].range_data[y].range_id = hold_range_cd WITH counter
    IF (curqual=0)
     SET failures = 1
     SET count2 = (count2+ 1)
     SET reply->status_data.subeventstatus[count2].sourceobjectname = "script"
     SET reply->status_data.subeventstatus[count2].sourceobjectvalue = "bbt_add_interpretations"
     SET reply->status_data.subeventstatus[count2].operationname = "Update"
     SET reply->status_data.subeventstatus[count2].operationstatus = "F"
     SET reply->status_data.subeventstatus[count2].targetobjectname = "Interp Range"
     SET reply->status_data.subeventstatus[count2].targetobjectvalue = "inc_assay_cd"
     SET reply->status_data.subeventstatus[count2].sourceobjectqual = 1
     SET reply->status_data.subeventstatus[count2].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
     GO TO exit_script
    ENDIF
   ELSE
    SET stat = alterlist(reply->comp_data[x].range_data,y)
    SET reply->comp_data[x].range_data[y].range_id = request->comp_data[x].range_data[y].range_id
   ENDIF
   FOR (z = 1 TO request->comp_data[x].range_data[y].hash_count)
     IF ((request->comp_data[x].range_data[y].hash_data[z].hash_flag="T"))
      SET next_code = 0.0
      EXECUTE cpm_next_code
      SET hold_hash_cd = next_code
      INSERT  FROM result_hash r
       SET r.interp_range_id =
        IF (hold_range_cd=0.0) request->comp_data[x].range_data[y].range_id
        ELSE hold_range_cd
        ENDIF
        , r.interp_detail_id =
        IF (hold_comp_cd=0.0) request->comp_data[x].comp_id
        ELSE hold_comp_cd
        ENDIF
        , r.result_hash_id = hold_hash_cd,
        r.days_ineligible = request->comp_data[x].range_data[y].hash_data[z].days_ineligible, r
        .interp_id = hold_interp_cd, r.included_assay_cd = request->comp_data[x].range_data[y].
        inc_assay_cd,
        r.sequence = request->comp_data[x].range_data[y].hash_data[z].sequence, r.from_result_range
         =
        IF ((request->comp_data[x].range_data[y].hash_data[z].from_result_range_yn="N")) null
        ELSE request->comp_data[x].range_data[y].hash_data[z].from_result_range
        ENDIF
        , r.to_result_range =
        IF ((request->comp_data[x].range_data[y].hash_data[z].to_result_range_yn="N")) null
        ELSE request->comp_data[x].range_data[y].hash_data[z].to_result_range
        ENDIF
        ,
        r.result_hash = request->comp_data[x].range_data[y].hash_data[z].result_hash, r
        .nomenclature_id =
        IF ((request->comp_data[x].range_data[y].hash_data[z].nomenclature_id=- (1))) 0
        ELSE request->comp_data[x].range_data[y].hash_data[z].nomenclature_id
        ENDIF
        , r.donor_eligibility_cd = request->comp_data[x].range_data[y].hash_data[z].
        donor_eligibility_cd,
        r.donor_reason_cd = request->comp_data[x].range_data[y].hash_data[z].donor_reason_cd, r
        .result_cd =
        IF ((request->comp_data[x].range_data[y].hash_data[z].result_cd=- (1))) 0
        ELSE request->comp_data[x].range_data[y].hash_data[z].result_cd
        ENDIF
        , r.biohazard_ind = request->comp_data[x].range_data[y].hash_data[z].biohazard_ind,
        r.active_ind = 1, r.active_status_cd = reqdata->active_status_cd, r.active_status_prsnl_id =
        reqinfo->updt_id,
        r.active_status_dt_tm = cnvtdatetime(current->system_dt_tm), r.updt_cnt = 0, r.updt_dt_tm =
        cnvtdatetime(current->system_dt_tm),
        r.updt_id = reqinfo->updt_id, r.updt_task = reqinfo->updt_task, r.updt_applctx = reqinfo->
        updt_applctx
      ;end insert
      SET stat = alterlist(reply->comp_data[x].range_data[y].hash_data,z)
      SET reply->comp_data[x].range_data[y].hash_data[z].hash_id = hold_hash_cd
      SET reply->comp_data[x].range_data[y].hash_data[z].hash_string = request->comp_data[x].
      range_data[y].hash_data[z].hash_string
      SET reply->comp_data[x].range_data[y].hash_data[z].range_id = reply->comp_data[x].range_data[y]
      .range_id WITH counter
      IF (curqual=0)
       SET failures = 1
       SET count2 = (count2+ 1)
       SET reply->status_data.subeventstatus[count2].sourceobjectname = "script"
       SET reply->status_data.subeventstatus[count2].sourceobjectvalue = "bbt_add_interpretations"
       SET reply->status_data.subeventstatus[count2].operationname = "Update"
       SET reply->status_data.subeventstatus[count2].operationstatus = "F"
       SET reply->status_data.subeventstatus[count2].targetobjectname = "Result Hash"
       SET reply->status_data.subeventstatus[count2].targetobjectvalue = "inc_assay_cd"
       SET reply->status_data.subeventstatus[count2].sourceobjectqual = 1
       SET reply->status_data.subeventstatus[count2].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
       GO TO exit_script
      ENDIF
     ELSE
      SET stat = alterlist(reply->comp_data[x].range_data[y].hash_data,z)
      SET reply->comp_data[x].range_data[y].hash_data[z].hash_id = 0.0
     ENDIF
   ENDFOR
  ENDFOR
 ENDFOR
 FOR (y = 1 TO request->result_count)
   IF ((request->result_data[y].result_flag="T"))
    IF ((request->result_data[y].result_text > ""))
     SELECT INTO "nl:"
      seqn = seq(long_data_seq,nextval)
      FROM dual
      DETAIL
       text_code = seqn
      WITH format, nocounter
     ;end select
    ENDIF
    SET next_code = 0.0
    EXECUTE cpm_next_code
    SET new_interp_result_id = next_code
    IF ((request->result_data[y].result_text > ""))
     INSERT  FROM long_text_reference lt
      SET lt.long_text_id = text_code, lt.parent_entity_name = "INTERP_RESULT", lt.parent_entity_id
        = next_code,
       lt.long_text = request->result_data[y].result_text, lt.updt_cnt = 0, lt.updt_dt_tm =
       cnvtdatetime(current->system_dt_tm),
       lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
       updt_applctx,
       lt.active_ind = 1, lt.active_status_cd = reqdata->active_status_cd, lt.active_status_dt_tm =
       cnvtdatetime(current->system_dt_tm),
       lt.active_status_prsnl_id = reqinfo->updt_id
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET failures = 1
      SET count2 = (count2+ 1)
      SET reply->status_data.subeventstatus[count2].sourceobjectname = "script"
      SET reply->status_data.subeventstatus[count2].sourceobjectvalue = "bbt_add_interpretations"
      SET reply->status_data.subeventstatus[count2].operationname = "Update"
      SET reply->status_data.subeventstatus[count2].operationstatus = "F"
      SET reply->status_data.subeventstatus[count2].targetobjectname = "Long Text"
      SET reply->status_data.subeventstatus[count2].targetobjectvalue = "inc_assay_cd"
      SET reply->status_data.subeventstatus[count2].sourceobjectqual = 1
      SET reply->status_data.subeventstatus[count2].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
      GO TO exit_script
     ENDIF
    ENDIF
    INSERT  FROM interp_result ir
     SET ir.interp_result_id = next_code, ir.interp_id = hold_interp_cd, ir.result_nomenclature_id =
      IF ((request->result_data[y].result_nomenclature_id=- (1))) 0
      ELSE request->result_data[y].result_nomenclature_id
      ENDIF
      ,
      ir.result_cd =
      IF ((request->result_data[y].result_cd=- (1))) 0
      ELSE request->result_data[y].result_cd
      ENDIF
      , ir.hash_pattern = request->result_data[y].hash_pattern, ir.donor_eligibility_cd = request->
      result_data[y].donor_eligibility_cd,
      ir.days_ineligible = request->result_data[y].days_ineligible, ir.long_text_id = text_code, ir
      .active_ind = 1,
      ir.active_status_cd = reqdata->active_status_cd, ir.active_status_prsnl_id = reqinfo->updt_id,
      ir.active_status_dt_tm = cnvtdatetime(current->system_dt_tm),
      ir.updt_cnt = 0, ir.updt_dt_tm = cnvtdatetime(current->system_dt_tm), ir.updt_id = reqinfo->
      updt_id,
      ir.updt_task = reqinfo->updt_task, ir.updt_applctx = reqinfo->updt_applctx
    ;end insert
    SET stat = alterlist(reply->result_data,y)
    SET reply->result_data[y].result_id = next_code WITH counter
    IF (curqual=0)
     SET failures = 1
     SET count2 = (count2+ 1)
     SET reply->status_data.subeventstatus[count2].sourceobjectname = "script"
     SET reply->status_data.subeventstatus[count2].sourceobjectvalue = "bbt_add_interpretations"
     SET reply->status_data.subeventstatus[count2].operationname = "Update"
     SET reply->status_data.subeventstatus[count2].operationstatus = "F"
     SET reply->status_data.subeventstatus[count2].targetobjectname = "Result Hash"
     SET reply->status_data.subeventstatus[count2].targetobjectvalue = "inc_assay_cd"
     SET reply->status_data.subeventstatus[count2].sourceobjectqual = 1
     SET reply->status_data.subeventstatus[count2].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
     GO TO exit_script
    ENDIF
   ELSE
    SET stat = alterlist(reply->result_data,y)
    SET reply->result_data[y].result_id = 0.0
   ENDIF
 ENDFOR
#exit_script
 IF (failures=0)
  COMMIT
  SET reply->status_data.status = "S"
 ELSE
  ROLLBACK
  SET reply->status_data.status = "F"
 ENDIF
END GO
