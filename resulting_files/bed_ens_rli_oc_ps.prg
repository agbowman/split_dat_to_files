CREATE PROGRAM bed_ens_rli_oc_ps
 RECORD requestin(
   1 list_0[*]
     2 description = c60
     2 hna_mnemonic = c40
     2 dept_name = c40
     2 catalog_type_cd = c40
     2 activity_type_cd = c40
     2 activity_subtype_cd = c40
     2 order_entry_format = c40
     2 dcp_clin_cat_cd = c40
     2 mnemonic_type = c40
     2 mnemonic = c40
     2 billcode = c25
     2 concept_cki = vc
     2 catalog_cki = vc
 )
 RECORD request_cv(
   1 cd_value_list[1]
     2 action_flag = i2
     2 cdf_meaning = vc
     2 cki = vc
     2 code_set = i4
     2 code_value = f8
     2 collation_seq = i4
     2 concept_cki = vc
     2 definition = vc
     2 description = vc
     2 display = vc
     2 begin_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 active_ind = i2
     2 display_key = vc
 )
 FREE SET reply
 RECORD reply(
   1 oc_list[*]
     2 catalog_cd = f8
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
 SET error_flag = "N"
 DECLARE error_msg = vc
 DECLARE catcnt = i4
 SET catcnt = 0
 SET catalog_type_code_value = 0.0
 SET activity_type_code_value = 0.0
 SET activity_subtype_code_value = 0.0
 SET dcp_code_value = 0.0
 SET oe_format_id = 0.0
 SET mnemonic_type_code_value = 0.0
 SET new_catalog_code_value = 0.0
 SET new_synonym_code_value = 0.0
 SET catalog_type_desc = fillstring(40," ")
 SET activity_type_desc = fillstring(40," ")
 SET activity_subtype_desc = fillstring(40," ")
 SET dcp_desc = fillstring(40," ")
 SET oe_format_desc = fillstring(40," ")
 SET mnemonic_type_desc = fillstring(40," ")
 SET cpt4_value = fillstring(100," ")
 SET primary_code_value = 0.0
 SET direct_code_value = 0.0
 SET ancillary_code_value = 0.0
 SET active_code_value = 0.0
 SET ord_cat_code_value = 0.0
 SET billcode_code_value = 0.0
 SET cpt4_code_value = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=6011
   AND cv.display="Primary"
   AND cv.active_ind=1
  DETAIL
   primary_code_value = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=6011
   AND cv.display="Direct Care Provider"
   AND cv.active_ind=1
  DETAIL
   direct_code_value = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=6011
   AND cv.display="Ancillary"
   AND cv.active_ind=1
  DETAIL
   ancillary_code_value = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=48
   AND cv.cdf_meaning="ACTIVE"
   AND cv.active_ind=1
  DETAIL
   active_code_value = cv.code_value
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
 SET orc_cnt = size(requestin->list_0,5)
 FOR (x = 1 TO orc_cnt)
   SET mnemonic_type_code_value = primary_code_value
   SET mnemonic_type_desc = fillstring(40," ")
   IF (((catalog_type_code_value=0) OR (catalog_type_desc != cnvtupper(cnvtalphanum(requestin->
     list_0[x].catalog_type_cd)))) )
    SET catalog_type_code_value = 0
    SET catalog_type_desc = fillstring(40," ")
    SET catalog_type_desc = cnvtupper(cnvtalphanum(requestin->list_0[x].catalog_type_cd))
    SELECT INTO "NL:"
     FROM code_value cv
     WHERE cv.code_set=6000
      AND cv.display_key=catalog_type_desc
      AND cv.active_ind=1
     DETAIL
      catalog_type_code_value = cv.code_value
     WITH nocounter
    ;end select
   ENDIF
   IF (((activity_type_code_value=0) OR (activity_type_desc != cnvtupper(cnvtalphanum(requestin->
     list_0[x].activity_type_cd)))) )
    SET activity_type_code_value = 0
    SET activity_type_desc = fillstring(40," ")
    SET activity_type_desc = cnvtupper(cnvtalphanum(requestin->list_0[x].activity_type_cd))
    SELECT INTO "NL:"
     FROM code_value cv
     WHERE cv.code_set=106
      AND cv.display_key=activity_type_desc
      AND cv.active_ind=1
     DETAIL
      activity_type_code_value = cv.code_value
     WITH nocounter
    ;end select
   ENDIF
   IF (((activity_subtype_code_value=0) OR (activity_subtype_desc != cnvtupper(cnvtalphanum(requestin
     ->list_0[x].activity_subtype_cd)))) )
    SET activity_subtype_code_value = 0.0
    SET activity_subtype_desc = fillstring(40," ")
    SET activity_subtype_desc = cnvtupper(cnvtalphanum(requestin->list_0[x].activity_subtype_cd))
    SELECT INTO "NL:"
     FROM code_value cv
     WHERE cv.code_set=5801
      AND cv.display_key=activity_subtype_desc
      AND cv.active_ind=1
     DETAIL
      activity_subtype_code_value = cv.code_value
     WITH nocounter
    ;end select
   ENDIF
   IF (((dcp_code_value=0) OR (dcp_desc != cnvtupper(cnvtalphanum(requestin->list_0[x].
     dcp_clin_cat_cd)))) )
    SET dcp_code_value = 0.0
    SET dcp_desc = fillstring(40," ")
    SET dcp_desc = cnvtupper(cnvtalphanum(requestin->list_0[x].dcp_clin_cat_cd))
    SELECT INTO "NL:"
     FROM code_value cv
     WHERE cv.code_set=16389
      AND cv.display_key=dcp_desc
      AND cv.active_ind=1
     DETAIL
      dcp_code_value = cv.code_value
     WITH nocounter
    ;end select
   ENDIF
   IF (((oe_format_id=0) OR (oe_format_desc != trim(requestin->list_0[x].order_entry_format))) )
    SET oe_format_id = 0.0
    SET oe_format_desc = fillstring(40," ")
    SET oe_format_desc = cnvtupper(trim(requestin->list_0[x].order_entry_format))
    SELECT INTO "NL:"
     FROM order_entry_format oe
     WHERE cnvtupper(oe.oe_format_name)=oe_format_desc
     DETAIL
      oe_format_id = oe.oe_format_id
     WITH nocounter
    ;end select
   ENDIF
   SET request_cv->cd_value_list[1].action_flag = 1
   SET request_cv->cd_value_list[1].code_set = 200
   SET request_cv->cd_value_list[1].display = substring(1,40,requestin->list_0[x].hna_mnemonic)
   SET request_cv->cd_value_list[1].description = substring(1,60,requestin->list_0[x].description)
   SET request_cv->cd_value_list[1].active_ind = 1
   SET request_cv->cd_value_list[1].cki = requestin->list_0[x].catalog_cki
   SET request_cv->cd_value_list[1].concept_cki = requestin->list_0[x].concept_cki
   SET request_cv->cd_value_list[1].definition = " "
   SET trace = recpersist
   EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
   IF ((reply_cv->status_data.status="S")
    AND (reply_cv->qual[1].code_value > 0))
    SET new_catalog_code_value = reply_cv->qual[1].code_value
    SET catcnt = (catcnt+ 1)
    SET stat = alterlist(reply->oc_list,catcnt)
    SET reply->oc_list[catcnt].catalog_cd = new_catalog_code_value
   ELSE
    SET error_flag = "Y"
    SET error_msg = concat("Unable to insert ",trim(requestin->list_0[x].hna_mnemonic),
     " into codeset 200.")
    GO TO exit_script
   ENDIF
   INSERT  FROM order_catalog oc
    SET oc.catalog_cd = new_catalog_code_value, oc.dcp_clin_cat_cd = dcp_code_value, oc
     .catalog_type_cd = catalog_type_code_value,
     oc.activity_type_cd = activity_type_code_value, oc.activity_subtype_cd =
     activity_subtype_code_value, oc.oe_format_id = oe_format_id,
     oc.resource_route_lvl = 1, oc.orderable_type_flag = 0, oc.active_ind = 1,
     oc.description = requestin->list_0[x].description, oc.primary_mnemonic = requestin->list_0[x].
     hna_mnemonic, oc.dept_display_name =
     IF ((requestin->list_0[x].dept_name > "   *")) requestin->list_0[x].dept_name
     ELSE requestin->list_0[x].hna_mnemonic
     ENDIF
     ,
     oc.cki =
     IF ((((requestin->list_0[x].catalog_cki=null)) OR ((requestin->list_0[x].catalog_cki=" "))) )
      null
     ELSE requestin->list_0[x].catalog_cki
     ENDIF
     , oc.concept_cki =
     IF ((((requestin->list_0[x].concept_cki=null)) OR ((requestin->list_0[x].concept_cki=" "))) )
      IF ((requestin->list_0[x].billcode > "   *")) cpt4_value
      ELSE null
      ENDIF
     ELSE requestin->list_0[x].concept_cki
     ENDIF
     , oc.consent_form_ind = 0,
     oc.inst_restriction_ind = 0, oc.schedule_ind = 0, oc.print_req_ind = 0,
     oc.quick_chart_ind = 0, oc.complete_upon_order_ind = 0, oc.comment_template_flag = 0,
     oc.dup_checking_ind = 0, oc.bill_only_ind = 0, oc.cont_order_method_flag = 0,
     oc.order_review_ind = 0, oc.ref_text_mask = 0, oc.cki = " ",
     oc.form_level = 0, oc.updt_dt_tm = cnvtdatetime(curdate,curtime3), oc.updt_id = reqinfo->updt_id,
     oc.updt_task = reqinfo->updt_task, oc.updt_applctx = reqinfo->updt_applctx, oc.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Unable to insert ",trim(requestin->list_0[x].hna_mnemonic),
     " into order_catalog table.")
    GO TO exit_script
   ENDIF
   INSERT  FROM bill_item bi
    SET bi.bill_item_id = seq(bill_item_seq,nextval), bi.ext_parent_reference_id =
     new_catalog_code_value, bi.ext_parent_contributor_cd = ord_cat_value,
     bi.ext_child_reference_id = 0.0, bi.ext_child_contributor_cd = 0.0, bi.ext_description =
     requestin->list_0[x].description,
     bi.ext_owner_cd = activity_type_code_value, bi.parent_qual_cd = 1.0, bi.charge_point_cd = 0.0,
     bi.physician_qual_cd = 0.0, bi.calc_type_cd = 0.0, bi.updt_cnt = 0,
     bi.updt_dt_tm = cnvtdatetime(curdate,curtime3), bi.updt_id = reqinfo->updt_id, bi.updt_task =
     reqinfo->updt_task,
     bi.updt_applctx = reqinfo->updt_applctx, bi.active_ind = 1, bi.active_status_cd =
     active_code_value,
     bi.active_status_dt_tm = cnvtdatetime(curdate,curtime3), bi.active_status_prsnl_id = reqinfo->
     updt_id, bi.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
     bi.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"), bi.ext_short_desc = substring(
      1,50,requestin->list_0[x].hna_mnemonic), bi.ext_parent_entity_name = "CODE_VALUE",
     bi.ext_child_entity_name = null, bi.careset_ind = 0.0, bi.workload_only_ind = 0.0,
     bi.parent_qual_ind = 0.0, bi.misc_ind = 0.0, bi.stats_only_ind = 0.0,
     bi.child_seq = 0.0, bi.num_hits = 0.0, bi.late_chrg_excl_ind = 0.0,
     bi.cost_basis_amt = 0.0, bi.tax_ind = 0.0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Unable to insert ",requestin->list_0[x].description,
     " into the bill_item table.")
    GO TO exit_script
   ENDIF
   IF ((requestin->list_0[x].dept_name > "   *")
    AND cnvtupper(trim(requestin->list_0[x].dept_name)) != cnvtupper(trim(requestin->list_0[x].
     hna_mnemonic))
    AND ((catalog_type_desc="LABORATORY") OR (catalog_type_desc="RADIOLOGY")) )
    INSERT  FROM service_directory l
     SET l.short_description = requestin->list_0[x].dept_name, l.description = requestin->list_0[x].
      description, l.catalog_cd = new_catalog_code_value,
      l.synonym_id = 0, l.active_ind = 1, l.active_status_cd = active_code_value,
      l.active_status_prsnl_id = reqinfo->updt_id, l.active_status_dt_tm = cnvtdatetime(curdate,
       curtime3), l.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
      l.end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00.00"), l.group_ind = 0, l.updt_dt_tm
       = cnvtdatetime(curdate,curtime3),
      l.updt_id = reqinfo->updt_id, l.updt_cnt = 0, l.updt_task = reqinfo->updt_task,
      l.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to insert ",trim(requestin->oc_list[x].dept_name),
      " into service_directory table.")
     GO TO exit_script
    ENDIF
   ENDIF
   IF (new_catalog_code_value > 0)
    SET new_synonym_code_value = 0.0
    SELECT INTO "nl:"
     y = seq(reference_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      new_synonym_code_value = cnvtreal(y)
     WITH format, nocounter
    ;end select
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable generate new synonym_id when processing ",trim(requestin->list_0[
       x].hna_mnemonic))
     GO TO exit_script
    ENDIF
    INSERT  FROM order_catalog_synonym ocs
     SET ocs.rx_mask = 0, ocs.dcp_clin_cat_cd = dcp_code_value, ocs.synonym_id =
      new_synonym_code_value,
      ocs.catalog_cd = new_catalog_code_value, ocs.catalog_type_cd = catalog_type_code_value, ocs
      .activity_type_cd = activity_type_code_value,
      ocs.activity_subtype_cd = activity_subtype_code_value, ocs.oe_format_id = oe_format_id, ocs
      .mnemonic = requestin->list_0[x].hna_mnemonic,
      ocs.mnemonic_key_cap = trim(cnvtupper(requestin->list_0[x].hna_mnemonic)), ocs.mnemonic_type_cd
       = mnemonic_type_code_value, ocs.active_ind = 1,
      ocs.orderable_type_flag = 0, ocs.ref_text_mask = 0, ocs.hide_flag = 0,
      ocs.cki = " ", ocs.virtual_view = " ", ocs.health_plan_view = " ",
      ocs.concentration_strength = 0, ocs.concentration_volume = 0, ocs.active_status_cd =
      active_code_value,
      ocs.active_status_dt_tm = cnvtdatetime(curdate,curtime3), ocs.active_status_prsnl_id = reqinfo
      ->updt_id, ocs.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      ocs.updt_id = reqinfo->updt_id, ocs.updt_task = reqinfo->updt_task, ocs.updt_applctx = reqinfo
      ->updt_applctx,
      ocs.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to insert synonym ",trim(requestin->list_0[x].hna_mnemonic),
      " for ",trim(requestin->list_0[x].hna_mnemonic)," into the order_catalog_synonym table.")
     GO TO exit_script
    ENDIF
    INSERT  FROM ocs_facility_r ofr
     SET ofr.synonym_id = new_synonym_code_value, ofr.facility_cd = 0.0, ofr.updt_applctx = reqinfo->
      updt_applctx,
      ofr.updt_cnt = 0, ofr.updt_dt_tm = cnvtdatetime(curdate,curtime), ofr.updt_id = reqinfo->
      updt_id,
      ofr.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
    IF ((requestin->list_0[x].mnemonic > " ")
     AND (requestin->list_0[x].mnemonic_type="ANCILLARY"))
     SET mnemonic_type_code_value = ancillary_code_value
     SET new_synonym_code_value = 0.0
     SELECT INTO "nl:"
      y = seq(reference_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       new_synonym_code_value = cnvtreal(y)
      WITH format, nocounter
     ;end select
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_msg = concat("Unable generate new synonym_id when processing ",trim(requestin->
        list_0[x].hna_mnemonic))
      GO TO exit_script
     ENDIF
     INSERT  FROM order_catalog_synonym ocs
      SET ocs.rx_mask = 0, ocs.dcp_clin_cat_cd = dcp_code_value, ocs.synonym_id =
       new_synonym_code_value,
       ocs.catalog_cd = new_catalog_code_value, ocs.catalog_type_cd = catalog_type_code_value, ocs
       .activity_type_cd = activity_type_code_value,
       ocs.activity_subtype_cd = activity_subtype_code_value, ocs.oe_format_id = oe_format_id, ocs
       .mnemonic = requestin->list_0[x].mnemonic,
       ocs.mnemonic_key_cap = trim(cnvtupper(requestin->list_0[x].mnemonic)), ocs.mnemonic_type_cd =
       mnemonic_type_code_value, ocs.active_ind = 1,
       ocs.orderable_type_flag = 0, ocs.ref_text_mask = 0, ocs.hide_flag = 0,
       ocs.cki = " ", ocs.virtual_view = " ", ocs.health_plan_view = " ",
       ocs.concentration_strength = 0, ocs.concentration_volume = 0, ocs.active_status_cd =
       active_code_value,
       ocs.active_status_dt_tm = cnvtdatetime(curdate,curtime3), ocs.active_status_prsnl_id = reqinfo
       ->updt_id, ocs.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       ocs.updt_id = reqinfo->updt_id, ocs.updt_task = reqinfo->updt_task, ocs.updt_applctx = reqinfo
       ->updt_applctx,
       ocs.updt_cnt = 0
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_msg = concat("Unable to insert synonym ",trim(requestin->list_0[x].hna_mnemonic),
       " for ",trim(requestin->list_0[x].hna_mnemonic)," into the order_catalog_synonym table.")
      GO TO exit_script
     ENDIF
     INSERT  FROM ocs_facility_r ofr
      SET ofr.synonym_id = new_synonym_code_value, ofr.facility_cd = 0.0, ofr.updt_applctx = reqinfo
       ->updt_applctx,
       ofr.updt_cnt = 0, ofr.updt_dt_tm = cnvtdatetime(curdate,curtime), ofr.updt_id = reqinfo->
       updt_id,
       ofr.updt_task = reqinfo->updt_task
      WITH nocounter
     ;end insert
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_ENS_RLI_OC_PS","  >> ERROR MSG: ",error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
