CREATE PROGRAM bed_ens_oc_matches:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD syn(
   1 slist[*]
     2 synonym_id = f8
     2 catalog_type_cd = f8
     2 activity_type_cd = f8
     2 activity_subtype_cd = f8
     2 mnemonic = c100
     2 mnemonic_type_cd = f8
     2 oe_format_id = f8
 )
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 SET error_flag = "N"
 SET active_code_value = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=48
   AND cv.cdf_meaning="ACTIVE"
   AND cv.active_ind=1
  DETAIL
   active_code_value = cv.code_value
  WITH nocounter
 ;end select
 SET auth_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=8
    AND cv.cdf_meaning="AUTH")
  ORDER BY cv.code_value
  HEAD cv.code_value
   auth_cd = cv.code_value
  WITH nocounter
 ;end select
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
 SET primary_mnemonic = fillstring(100," ")
 SET description = fillstring(100," ")
 SET dept_name = fillstring(100," ")
 SET concept_cki = fillstring(255," ")
 SET cki = fillstring(255," ")
 SET dcp_code_value = 0.0
 SET cat_type_code_value = 0.0
 SET act_type_code_value = 0.0
 SET act_subtype_code_value = 0.0
 SET oe_format_id = 0.0
 SET oc_cnt = size(request->client_oc_list,5)
 FOR (x = 1 TO oc_cnt)
   SET new_cv = 0.0
   SELECT INTO "NL:"
    FROM code_value cv
    WHERE cv.code_set=200
     AND (cv.code_value=request->client_oc_list[x].catalog_code_value)
    DETAIL
     new_cv = cv.code_value
    WITH nocounter
   ;end select
   IF (new_cv=0)
    SELECT INTO "NL:"
     FROM br_auto_order_catalog b
     WHERE (b.catalog_cd=request->client_oc_list[x].catalog_code_value)
     DETAIL
      primary_mnemonic = b.primary_mnemonic, description = b.description, dept_name = b.dept_name,
      concept_cki = b.concept_cki, cki = b.cki, dcp_code_value = b.dcp_clin_cat_cd
      IF ((request->client_oc_list[x].catalog_type_code_value > 0))
       cat_type_code_value = request->client_oc_list[x].catalog_type_code_value
      ELSE
       cat_type_code_value = b.catalog_type_cd
      ENDIF
      IF ((request->client_oc_list[x].activity_type_code_value > 0))
       act_type_code_value = request->client_oc_list[x].activity_type_code_value
      ELSE
       act_type_code_value = b.activity_type_cd
      ENDIF
      act_subtype_code_value = b.activity_subtype_cd, oe_format_id = b.oe_format_id
     WITH nocounter, skipbedrock = 1
    ;end select
    SELECT INTO "NL:"
     FROM code_value cv
     WHERE cv.code_set=200
      AND cv.concept_cki=concept_cki
     DETAIL
      new_cv = cv.code_value
     WITH nocounter
    ;end select
    IF (new_cv=0)
     SELECT INTO "NL:"
      FROM order_catalog oc
      WHERE oc.primary_mnemonic=primary_mnemonic
      DETAIL
       new_cv = oc.catalog_cd
      WITH nocounter
     ;end select
    ENDIF
    CALL echo(new_cv)
    IF (new_cv=0)
     SELECT INTO "NL:"
      j = seq(reference_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       new_cv = cnvtreal(j)
      WITH format, counter
     ;end select
     CALL echo("inserting into code_valu")
     INSERT  FROM code_value cv
      SET cv.code_value = new_cv, cv.code_set = 200, cv.active_ind = 1,
       cv.display = trim(substring(1,40,primary_mnemonic)), cv.display_key = trim(cnvtupper(
         cnvtalphanum(substring(1,40,primary_mnemonic)))), cv.description = trim(substring(1,60,
         description)),
       cv.data_status_cd = auth_cd, cv.concept_cki = trim(concept_cki), cv.cki = trim(cki),
       cv.active_type_cd = active_code_value, cv.active_dt_tm = cnvtdatetime(curdate,curtime3), cv
       .updt_dt_tm = cnvtdatetime(curdate,curtime3),
       cv.updt_id = reqinfo->updt_id, cv.updt_task = reqinfo->updt_task, cv.updt_applctx = reqinfo->
       updt_applctx,
       cv.updt_cnt = 0
      WITH nocounter
     ;end insert
     INSERT  FROM order_catalog oc
      SET oc.catalog_cd = new_cv, oc.dcp_clin_cat_cd = dcp_code_value, oc.catalog_type_cd =
       cat_type_code_value,
       oc.activity_type_cd = act_type_code_value, oc.activity_subtype_cd = act_subtype_code_value, oc
       .oe_format_id = oe_format_id,
       oc.description = description, oc.primary_mnemonic = primary_mnemonic, oc.dept_display_name =
       dept_name,
       oc.orderable_type_flag =
       IF (cat_type_code_value=surgery_cat_value) 1
       ELSE 0
       ENDIF
       , oc.active_ind = 1, oc.cki = cki,
       oc.concept_cki = concept_cki, oc.consent_form_ind = 0, oc.inst_restriction_ind = 0,
       oc.schedule_ind = 0, oc.print_req_ind = 0, oc.quick_chart_ind = 0,
       oc.complete_upon_order_ind = 0, oc.comment_template_flag = 0, oc.dup_checking_ind = 0,
       oc.bill_only_ind = 0, oc.cont_order_method_flag = 0, oc.order_review_ind = 0,
       oc.ref_text_mask = 0, oc.form_level = 0, oc.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       oc.updt_id = reqinfo->updt_id, oc.updt_task = reqinfo->updt_task, oc.updt_applctx = reqinfo->
       updt_applctx,
       oc.updt_cnt = 0
      WITH nocounter
     ;end insert
     INSERT  FROM bill_item bi
      SET bi.bill_item_id = seq(bill_item_seq,nextval), bi.ext_parent_reference_id = new_cv, bi
       .ext_parent_contributor_cd = ord_cat_value,
       bi.ext_child_reference_id = 0.0, bi.ext_child_contributor_cd = 0.0, bi.ext_description =
       description,
       bi.ext_owner_cd = act_type_code_value, bi.parent_qual_cd = 1.0, bi.charge_point_cd = 0.0,
       bi.physician_qual_cd = 0.0, bi.calc_type_cd = 0.0, bi.updt_cnt = 0,
       bi.updt_dt_tm = cnvtdatetime(curdate,curtime3), bi.updt_id = reqinfo->updt_id, bi.updt_task =
       reqinfo->updt_task,
       bi.updt_applctx = reqinfo->updt_applctx, bi.active_ind = 1, bi.active_status_cd =
       active_code_value,
       bi.active_status_dt_tm = cnvtdatetime(curdate,curtime3), bi.active_status_prsnl_id = reqinfo->
       updt_id, bi.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
       bi.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"), bi.ext_short_desc =
       substring(1,50,primary_mnemonic), bi.ext_parent_entity_name = "CODE_VALUE",
       bi.ext_child_entity_name = null, bi.careset_ind = 0.0, bi.workload_only_ind = 0.0,
       bi.parent_qual_ind = 0.0, bi.misc_ind = 0.0, bi.stats_only_ind = 0.0,
       bi.child_seq = 0.0, bi.num_hits = 0.0, bi.late_chrg_excl_ind = 0.0,
       bi.cost_basis_amt = 0.0, bi.tax_ind = 0.0
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_msg = concat("Unable to insert ",description," into the bill_item table.")
      GO TO exit_script
     ENDIF
     SET stat = alterlist(syn->slist,50)
     SET i = 0
     SELECT INTO "NL:"
      FROM br_auto_oc_synonym b
      WHERE (b.catalog_cd=request->client_oc_list[x].catalog_code_value)
      DETAIL
       i = (i+ 1), syn->slist[i].synonym_id = 0.0, syn->slist[i].catalog_type_cd = b.catalog_type_cd,
       syn->slist[i].activity_type_cd = b.activity_type_cd, syn->slist[i].activity_subtype_cd = b
       .activity_subtype_cd, syn->slist[i].mnemonic = b.mnemonic,
       syn->slist[i].mnemonic_type_cd = b.mnemonic_type_cd, syn->slist[i].oe_format_id = b
       .oe_format_id
      WITH nocounter, skipbedrock = 1
     ;end select
     FOR (z = 1 TO i)
       SET syn_id = 0.0
       SELECT INTO "NL:"
        j = seq(reference_seq,nextval)"##################;rp0"
        FROM dual
        DETAIL
         syn_id = cnvtreal(j)
        WITH format, counter
       ;end select
       SET syn->slist[z].synonym_id = syn_id
       INSERT  FROM order_catalog_synonym ocs
        SET ocs.synonym_id = syn->slist[z].synonym_id, ocs.catalog_cd = new_cv, ocs.catalog_type_cd
          = cat_type_code_value,
         ocs.activity_type_cd = act_type_code_value, ocs.activity_subtype_cd = syn->slist[z].
         activity_subtype_cd, ocs.oe_format_id = syn->slist[z].oe_format_id,
         ocs.dcp_clin_cat_cd = dcp_code_value, ocs.orderable_type_flag =
         IF (cat_type_code_value=surgery_cat_value) 1
         ELSE 0
         ENDIF
         , ocs.ref_text_mask = 0,
         ocs.hide_flag = 0, ocs.cki = " ", ocs.virtual_view = " ",
         ocs.health_plan_view = " ", ocs.concept_cki = concept_cki, ocs.concentration_strength = 0,
         ocs.concentration_volume = 0, ocs.mnemonic = syn->slist[z].mnemonic, ocs.mnemonic_key_cap =
         cnvtupper(syn->slist[z].mnemonic),
         ocs.mnemonic_type_cd = syn->slist[z].mnemonic_type_cd, ocs.active_status_cd =
         active_code_value, ocs.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
         ocs.active_ind = 1, ocs.active_status_prsnl_id = reqinfo->updt_id, ocs.updt_dt_tm =
         cnvtdatetime(curdate,curtime3),
         ocs.updt_id = reqinfo->updt_id, ocs.updt_task = reqinfo->updt_task, ocs.updt_applctx =
         reqinfo->updt_applctx,
         ocs.updt_cnt = 0
       ;end insert
       INSERT  FROM ocs_facility_r ofr
        SET ofr.synonym_id = syn->slist[z].synonym_id, ofr.facility_cd = 0.0, ofr.updt_applctx =
         reqinfo->updt_applctx,
         ofr.updt_cnt = 0, ofr.updt_dt_tm = cnvtdatetime(curdate,curtime), ofr.updt_id = reqinfo->
         updt_id,
         ofr.updt_task = reqinfo->updt_task
        WITH nocounter
       ;end insert
     ENDFOR
     SET stat = alterlist(syn->slist,0)
     IF (cat_type_code_value=surgery_cat_value)
      INSERT  FROM surgical_procedure s
       SET s.catalog_cd = new_cv, s.def_proc_dur = null, s.surg_specialty_id = 0,
        s.def_wound_class_cd = 0, s.def_case_level_cd = 0, s.spec_req_ind = null,
        s.frozen_section_req_ind = null, s.def_anesth_type_cd = 0, s.updt_dt_tm = cnvtdatetime(
         curdate,curtime3),
        s.updt_id = reqinfo->updt_id, s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->
        updt_applctx,
        s.updt_cnt = 0, s.create_dt_tm = cnvtdatetime(curdate,curtime3), s.create_prsnl_id = reqinfo
        ->updt_id,
        s.create_task = reqinfo->updt_task, s.create_applctx = reqinfo->updt_applctx, s.setup_time =
        0,
        s.cleanup_time = 0
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET error_flag = "Y"
       SET error_msg = concat("Unable to insert ",trim(primary_mnemonic)," into surgical_procedure.")
       GO TO exit_script
      ENDIF
     ELSE
      INSERT  FROM service_directory l
       SET l.short_description = trim(dept_name), l.description = trim(description), l.catalog_cd =
        new_cv,
        l.active_ind = 1, l.active_status_cd = active_code_value, l.active_status_dt_tm =
        cnvtdatetime(curdate,curtime3),
        l.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), l.end_effective_dt_tm = cnvtdatetime(
         "31-dec-2100 00:00:00.00"), l.updt_dt_tm = cnvtdatetime(curdate,curtime3),
        l.updt_id = reqinfo->updt_id, l.updt_task = reqinfo->updt_task, l.updt_applctx = reqinfo->
        updt_applctx,
        l.updt_cnt = 0
       WITH nocounter
      ;end insert
     ENDIF
    ENDIF
   ENDIF
   IF ((((request->client_oc_list[x].match_type=5)) OR ((request->client_oc_list[x].match_type >= 1)
    AND (request->client_oc_list[x].match_value > "     "))) )
    UPDATE  FROM br_oc_work b
     SET b.status_ind = 1, b.match_ind = request->client_oc_list[x].match_type, b.match_orderable_cd
       = new_cv,
      b.match_value = request->client_oc_list[x].match_value, b.updt_dt_tm = cnvtdatetime(curdate,
       curtime3), b.updt_id = reqinfo->updt_id,
      b.updt_task = reqinfo->updt_task, b.updt_cnt = (b.updt_cnt+ 1), b.updt_applctx = reqinfo->
      updt_applctx
     WHERE (b.oc_id=request->client_oc_list[x].oc_id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to update the br_oc_work table with oc_id = ",cnvtstring(request
       ->client_oc_list[x].oc_id))
     GO TO exit_script
    ENDIF
    IF (cat_type_code_value=surgery_cat_value)
     SET sproc_ind = 0
     SELECT INTO "nl:"
      FROM surgical_procedure s
      WHERE s.catalog_cd=new_cv
      DETAIL
       sproc_ind = 1
      WITH nocounter
     ;end select
     IF (sproc_ind=0)
      INSERT  FROM surgical_procedure s
       SET s.catalog_cd = new_cv, s.def_proc_dur = null, s.surg_specialty_id = 0,
        s.def_wound_class_cd = 0, s.def_case_level_cd = 0, s.spec_req_ind = null,
        s.frozen_section_req_ind = null, s.def_anesth_type_cd = 0, s.updt_dt_tm = cnvtdatetime(
         curdate,curtime3),
        s.updt_id = reqinfo->updt_id, s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->
        updt_applctx,
        s.updt_cnt = 0, s.create_dt_tm = null, s.create_prsnl_id = 0,
        s.create_task = null, s.create_applctx = null, s.setup_time = 0,
        s.cleanup_time = 0
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET error_flag = "Y"
       SET error_msg = concat("Unable to insert ",trim(primary_mnemonic)," into surgical_procedure.")
       GO TO exit_script
      ENDIF
     ENDIF
    ENDIF
   ELSE
    SET error_flag = "Y"
    SET error_msg = concat("The match_type and match_value were not defined correctly for oc_id = ",
     cnvtstring(request->client_oc_list[x].oc_id))
    GO TO exit_script
   ENDIF
 ENDFOR
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_ENS_OC_MATCHES","  >> ERROR MSG: ",error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
