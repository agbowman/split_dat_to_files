CREATE PROGRAM bed_ens_oc_add_or_remove:dba
 FREE SET reply
 RECORD reply(
   1 oc_list[*]
     2 oc_id = f8
     2 catalog_code_value = f8
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 SET error_flag = "N"
 SET new_catalog_cd = 0.0
 SET new_synonyn_cd = 0.0
 SET active_code_value = 0.0
 SET primary_code_value = 0.0
 SET oc_cnt = size(request->oc_list,5)
 SET stat = alterlist(reply->oc_list,oc_cnt)
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=48
   AND cv.cdf_meaning="ACTIVE"
   AND cv.active_ind=1
  DETAIL
   active_code_value = cv.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET error_flag = "Y"
  SET error_msg = concat("Unable to retrieve the ACTIVE code value from codeset 48.")
  GO TO exit_script
 ENDIF
 SET auth_code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=8
   AND cv.cdf_meaning="AUTH"
   AND cv.active_ind=1
  DETAIL
   auth_code_value = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=6011
   AND cv.display="Primary"
   AND cv.active_ind=1
  DETAIL
   primary_code_value = cv.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET error_flag = "Y"
  SET error_msg = concat("Unable to retrieve the Primary code value from codeset 6011.")
  GO TO exit_script
 ENDIF
 SET ord_cat_value = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=13016
   AND cv.cdf_meaning="ORD CAT"
   AND cv.active_ind=1
  DETAIL
   ord_cat_value = cv.code_value
  WITH nocounter
 ;end select
 SET surgery_cat_value = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=6000
   AND cv.cdf_meaning="SURGERY"
   AND cv.active_ind=1
  DETAIL
   surgery_cat_value = cv.code_value
  WITH nocounter
 ;end select
 FOR (x = 1 TO oc_cnt)
   SET new_catalog_cd = 0.0
   SET new_synonym_cd = 0.0
   SET reply->oc_list[x].oc_id = request->oc_list[x].oc_id
   IF ((request->oc_list[x].action_flag=1))
    SET new_catalog_cd = 0.0
    SELECT INTO "NL:"
     j = seq(reference_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      new_catalog_cd = cnvtreal(j)
     WITH format, counter
    ;end select
    INSERT  FROM code_value cv
     SET cv.code_value = new_catalog_cd, cv.code_set = 200, cv.active_ind = 1,
      cv.display = trim(substring(1,40,request->oc_list[x].primary_name)), cv.display_key = trim(
       cnvtupper(cnvtalphanum(substring(1,40,request->oc_list[x].primary_name)))), cv.description =
      trim(substring(1,60,request->oc_list[x].primary_name)),
      cv.data_status_cd = auth_code_value, cv.active_type_cd = active_code_value, cv.active_dt_tm =
      cnvtdatetime(curdate,curtime3),
      cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_id = reqinfo->updt_id, cv.updt_task =
      reqinfo->updt_task,
      cv.updt_applctx = reqinfo->updt_applctx, cv.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual > 0)
     SET reply->oc_list[x].catalog_code_value = new_catalog_cd
     INSERT  FROM order_catalog o
      SET o.catalog_cd = new_catalog_cd, o.active_ind = 1, o.description = trim(request->oc_list[x].
        primary_name),
       o.primary_mnemonic = trim(request->oc_list[x].primary_name), o.dept_display_name = trim(
        request->oc_list[x].primary_name), o.catalog_type_cd = request->oc_list[x].
       catalog_type_code_value,
       o.activity_type_cd = request->oc_list[x].activity_type_code_value, o.activity_subtype_cd =
       request->oc_list[x].subactivity_type_code_value, o.dcp_clin_cat_cd = request->oc_list[x].
       clin_cat_code_value,
       o.oe_format_id = request->oc_list[x].oe_format_id, o.orderable_type_flag =
       IF ((request->oc_list[x].catalog_type_code_value=surgery_cat_value)) 1
       ELSE 0
       ENDIF
       , o.schedule_ind = 0,
       o.dup_checking_ind = 0, o.consent_form_ind = 0, o.inst_restriction_ind = 0,
       o.print_req_ind = 0, o.quick_chart_ind = 0, o.complete_upon_order_ind = 0,
       o.comment_template_flag = 0, o.bill_only_ind = 0, o.cont_order_method_flag = 0,
       o.order_review_ind = 0, o.ref_text_mask = 0, o.cki = " ",
       o.form_level = 0, o.updt_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_id = reqinfo->updt_id,
       o.updt_task = reqinfo->updt_task, o.updt_cnt = 0, o.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_msg = concat("Unable to insert ",trim(request->oc_list[x].primary_name),
       " into the order_catalog table.")
      GO TO exit_script
     ENDIF
     INSERT  FROM bill_item bi
      SET bi.bill_item_id = seq(bill_item_seq,nextval), bi.ext_parent_reference_id = new_catalog_cd,
       bi.ext_parent_contributor_cd = ord_cat_value,
       bi.ext_child_reference_id = 0.0, bi.ext_child_contributor_cd = 0.0, bi.ext_description = trim(
        request->oc_list[x].primary_name),
       bi.ext_owner_cd = request->oc_list[x].activity_type_code_value, bi.parent_qual_cd = 1.0, bi
       .charge_point_cd = 0.0,
       bi.physician_qual_cd = 0.0, bi.calc_type_cd = 0.0, bi.updt_cnt = 0,
       bi.updt_dt_tm = cnvtdatetime(curdate,curtime3), bi.updt_id = reqinfo->updt_id, bi.updt_task =
       reqinfo->updt_task,
       bi.updt_applctx = reqinfo->updt_applctx, bi.active_ind = 1, bi.active_status_cd =
       active_code_value,
       bi.active_status_dt_tm = cnvtdatetime(curdate,curtime3), bi.active_status_prsnl_id = reqinfo->
       updt_id, bi.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
       bi.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"), bi.ext_short_desc =
       substring(1,50,request->oc_list[x].primary_name), bi.ext_parent_entity_name = "CODE_VALUE",
       bi.ext_child_entity_name = null, bi.careset_ind = 0.0, bi.workload_only_ind = 0.0,
       bi.parent_qual_ind = 0.0, bi.misc_ind = 0.0, bi.stats_only_ind = 0.0,
       bi.child_seq = 0.0, bi.num_hits = 0.0, bi.late_chrg_excl_ind = 0.0,
       bi.cost_basis_amt = 0.0, bi.tax_ind = 0.0
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_msg = concat("Unable to insert ",trim(request->oc_list[x].primary_name),
       " into the bill_item table.")
      GO TO exit_script
     ENDIF
    ELSE
     SET error_flag = "Y"
     SET error_msg = concat("Unable to insert ",trim(request->oc_list[x].primary_name),
      " into CodeSet 200.")
     GO TO exit_script
    ENDIF
    UPDATE  FROM br_oc_work b
     SET b.status_ind = 2, b.history_ind = request->oc_list[x].history_ind, b.match_orderable_cd =
      new_catalog_cd,
      b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task =
      reqinfo->updt_task,
      b.updt_cnt = (b.updt_cnt+ 1), b.updt_applctx = reqinfo->updt_applctx
     WHERE (b.oc_id=request->oc_list[x].oc_id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to update the br_oc_work table with oc_id = ",cnvtstring(request
       ->oc_list[x].oc_id))
     GO TO exit_script
    ENDIF
    SET new_synonym_cd = 0.0
    SELECT INTO "NL:"
     j = seq(reference_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      new_synonym_cd = cnvtreal(j)
     WITH format, counter
    ;end select
    IF (new_synonym_cd > 0)
     INSERT  FROM order_catalog_synonym ocs
      SET ocs.rx_mask = 0, ocs.dcp_clin_cat_cd = request->oc_list[x].clin_cat_code_value, ocs
       .synonym_id = new_synonym_cd,
       ocs.catalog_cd = new_catalog_cd, ocs.order_sentence_id = 0, ocs.catalog_type_cd = request->
       oc_list[x].catalog_type_code_value,
       ocs.activity_type_cd = request->oc_list[x].activity_type_code_value, ocs.activity_subtype_cd
        = request->oc_list[x].subactivity_type_code_value, ocs.oe_format_id = request->oc_list[x].
       oe_format_id,
       ocs.mnemonic = trim(request->oc_list[x].primary_name), ocs.mnemonic_key_cap = cnvtupper(
        request->oc_list[x].primary_name), ocs.mnemonic_type_cd = primary_code_value,
       ocs.active_ind = 1, ocs.orderable_type_flag =
       IF ((request->oc_list[x].catalog_type_code_value=surgery_cat_value)) 1
       ELSE 0
       ENDIF
       , ocs.hide_flag = request->oc_list[x].history_ind,
       ocs.cki = " ", ocs.ref_text_mask = 0, ocs.virtual_view = " ",
       ocs.health_plan_view = " ", ocs.concentration_volume = 0, ocs.concentration_volume_unit_cd = 0,
       ocs.concentration_strength = 0, ocs.concentration_strength_unit_cd = 0, ocs.active_status_cd
        = active_code_value,
       ocs.active_status_dt_tm = cnvtdatetime(curdate,curtime3), ocs.active_status_prsnl_id = reqinfo
       ->updt_id, ocs.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       ocs.updt_id = reqinfo->updt_id, ocs.updt_task = reqinfo->updt_task, ocs.updt_applctx = reqinfo
       ->updt_applctx,
       ocs.updt_cnt = 0
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_msg = concat("Unable to insert ",trim(request->oc_list[x].primary_name),
       " into the order_catalog_synonym table.")
      GO TO exit_script
     ENDIF
     INSERT  FROM ocs_facility_r ofr
      SET ofr.synonym_id = new_synonym_cd, ofr.facility_cd = 0.0, ofr.updt_applctx = reqinfo->
       updt_applctx,
       ofr.updt_cnt = 0, ofr.updt_dt_tm = cnvtdatetime(curdate,curtime), ofr.updt_id = reqinfo->
       updt_id,
       ofr.updt_task = reqinfo->updt_task
      WITH nocounter
     ;end insert
    ELSE
     SET error_flag = "Y"
     SET error_msg = concat("Unable to assign synonym_id for ",trim(request->oc_list[x].primary_name)
      )
     GO TO exit_script
    ENDIF
    IF ((request->oc_list[x].catalog_type_code_value=surgery_cat_value))
     INSERT  FROM surgical_procedure s
      SET s.catalog_cd = new_catalog_cd, s.def_proc_dur = null, s.surg_specialty_id = 0,
       s.def_wound_class_cd = 0, s.def_case_level_cd = 0, s.spec_req_ind = null,
       s.frozen_section_req_ind = null, s.def_anesth_type_cd = 0, s.updt_dt_tm = cnvtdatetime(curdate,
        curtime3),
       s.updt_id = reqinfo->updt_id, s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->
       updt_applctx,
       s.updt_cnt = 0, s.create_dt_tm = null, s.create_prsnl_id = 0,
       s.create_task = null, s.create_applctx = null, s.setup_time = 0,
       s.cleanup_time = 0
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_msg = concat("Unable to insert ",trim(request->oc_list[x].primary_name),
       " into surgical_procedure.")
      GO TO exit_script
     ENDIF
    ELSE
     INSERT  FROM service_directory l
      SET l.short_description = trim(request->oc_list[x].primary_name), l.description = trim(request
        ->oc_list[x].primary_name), l.catalog_cd = new_catalog_cd,
       l.synonym_id = 0, l.active_ind = 1, l.active_status_cd = active_code_value,
       l.bb_processing_cd = 0, l.bb_default_phases_cd = 0, l.active_status_prsnl_id = reqinfo->
       updt_id,
       l.active_status_dt_tm = cnvtdatetime(curdate,curtime3), l.beg_effective_dt_tm = cnvtdatetime(
        curdate,curtime3), l.end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00.00"),
       l.updt_dt_tm = cnvtdatetime(curdate,curtime3), l.updt_id = reqinfo->updt_id, l.updt_cnt = 0,
       l.updt_task = reqinfo->updt_task, l.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_msg = concat("Unable to insert ",trim(request->oc_list[x].primary_name),
       " into the service_directory table.")
      GO TO exit_script
     ENDIF
    ENDIF
   ELSEIF ((request->oc_list[x].action_flag=2))
    UPDATE  FROM br_oc_work b
     SET b.status_ind = 0, b.match_ind = 0, b.match_orderable_cd = 0.0,
      b.match_value = "    ", b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->
      updt_id,
      b.updt_task = reqinfo->updt_task, b.updt_cnt = (b.updt_cnt+ 1), b.updt_applctx = reqinfo->
      updt_applctx
     WHERE (b.oc_id=request->oc_list[x].oc_id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to update the br_oc_work table with oc_id = ",cnvtstring(request
       ->oc_list[x].oc_id))
     GO TO exit_script
    ENDIF
   ELSEIF ((request->oc_list[x].action_flag=3))
    UPDATE  FROM br_oc_work b
     SET b.status_ind = 3, b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->
      updt_id,
      b.updt_task = reqinfo->updt_task, b.updt_cnt = (b.updt_cnt+ 1), b.updt_applctx = reqinfo->
      updt_applctx
     WHERE (b.oc_id=request->oc_list[x].oc_id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to update the br_oc_work table with oc_id = ",cnvtstring(request
       ->oc_list[x].oc_id))
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  CALL echo(error_msg)
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_ENS_OC_ADD_OR_REMOVE","  >> ERROR MSG: ",
   error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
