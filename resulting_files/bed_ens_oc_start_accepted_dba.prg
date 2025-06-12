CREATE PROGRAM bed_ens_oc_start_accepted:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 oc_list[*]
     2 catalog_code_value = f8
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 FREE SET request_cv
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
 FREE RECORD reply_cv
 RECORD reply_cv(
   1 curqual = i4
   1 qual[*]
     2 status = i2
     2 error_num = i4
     2 error_msg = vc
     2 code_value = f8
     2 cki = vc
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
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
 SET oc_cnt = 0
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
 SET active_ind = 0
 SET update_needed = 0
 SET procedure_type_code_value = 0
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
 IF (curqual=0)
  SET error_flag = "Y"
  SET error_msg = concat("Unable to retrieve the ACTIVE code value from codeset 48.")
  GO TO exit_script
 ENDIF
 SET inactive_code_value = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=48
   AND cv.cdf_meaning="INACTIVE"
   AND cv.active_ind=1
  DETAIL
   inactive_code_value = cv.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET error_flag = "Y"
  SET error_msg = concat("Unable to retrieve the INACTIVE code value from codeset 48.")
  GO TO exit_script
 ENDIF
 SET primary_code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=6011
   AND cv.cdf_meaning="PRIMARY"
   AND cv.active_ind=1
  DETAIL
   primary_code_value = cv.code_value
  WITH nocounter
 ;end select
 SET gen_lab_act_code_value = 0.0
 SET micro_act_code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=106
   AND ((cv.cdf_meaning="GLB") OR (cv.cdf_meaning="MICROBIOLOGY"))
   AND cv.active_ind=1
  DETAIL
   IF (cv.cdf_meaning="GLB")
    gen_lab_act_code_value = cv.code_value
   ELSE
    micro_act_code_value = cv.code_value
   ENDIF
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
 SET oc_cnt = size(request->oc_list,5)
 SET stat = alterlist(reply->oc_list,oc_cnt)
 FOR (x = 1 TO oc_cnt)
  SET reply->oc_list[x].catalog_code_value = request->oc_list[x].catalog_code_value
  IF ((request->oc_list[x].action_flag=3))
   SET update_needed = 0
   SELECT INTO "NL:"
    FROM order_catalog oc
    WHERE (oc.catalog_cd=request->oc_list[x].catalog_code_value)
    DETAIL
     IF (oc.active_ind=1)
      update_needed = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (update_needed=1)
    SET act_suffix = fillstring(2," ")
    SELECT INTO "NL:"
     FROM order_catalog_synonym ocs,
      order_catalog_synonym ocs2
     PLAN (ocs
      WHERE (ocs.catalog_cd=request->oc_list[x].catalog_code_value)
       AND ocs.mnemonic_type_cd=primary_code_value)
      JOIN (ocs2
      WHERE ocs2.mnemonic_key_cap=concat("ZZ",substring(1,98,ocs.mnemonic_key_cap))
       AND ocs2.mnemonic_type_cd=primary_code_value)
     DETAIL
      IF (ocs.activity_type_cd=gen_lab_act_code_value)
       act_suffix = "GL"
      ELSEIF (ocs.activity_type_cd=micro_act_code_value)
       act_suffix = "MB"
      ENDIF
     WITH nocounter
    ;end select
    UPDATE  FROM service_directory l
     SET l.description =
      IF (act_suffix="  ") concat("zz",substring(1,98,l.description))
      ELSE concat("zz",trim(substring(1,95,l.description))," ",act_suffix)
      ENDIF
      , l.short_description =
      IF (act_suffix="  ") concat("zz",substring(1,98,l.short_description))
      ELSE concat("zz",trim(substring(1,95,l.short_description))," ",act_suffix)
      ENDIF
      , l.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      l.updt_id = reqinfo->updt_id, l.updt_task = reqinfo->updt_task, l.updt_applctx = reqinfo->
      updt_applctx,
      l.updt_cnt = (l.updt_cnt+ 1)
     WHERE (l.catalog_cd=request->oc_list[x].catalog_code_value)
     WITH nocounter
    ;end update
    UPDATE  FROM order_catalog_synonym ocs
     SET ocs.mnemonic =
      IF (act_suffix="  ") concat("zz",substring(1,98,ocs.mnemonic))
      ELSE concat("zz",trim(substring(1,95,ocs.mnemonic))," ",act_suffix)
      ENDIF
      , ocs.mnemonic_key_cap =
      IF (act_suffix="  ") concat("ZZ",substring(1,98,ocs.mnemonic_key_cap))
      ELSE concat("ZZ",trim(substring(1,95,ocs.mnemonic_key_cap))," ",act_suffix)
      ENDIF
      , ocs.active_ind = 0,
      ocs.active_status_cd = inactive_code_value, ocs.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      ocs.updt_id = reqinfo->updt_id,
      ocs.updt_task = reqinfo->updt_task, ocs.updt_applctx = reqinfo->updt_applctx, ocs.updt_cnt = (
      ocs.updt_cnt+ 1)
     WHERE (ocs.catalog_cd=request->oc_list[x].catalog_code_value)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat(
      "Unable to inactivate orderable on order_catalog_synonym table with code_value = ",cnvtstring(
       request->oc_list[x].catalog_code_value))
     GO TO exit_script
    ENDIF
    UPDATE  FROM order_catalog oc
     SET oc.primary_mnemonic =
      IF (act_suffix="  ") concat("zz",substring(1,98,oc.primary_mnemonic))
      ELSE concat("zz",trim(substring(1,95,oc.primary_mnemonic))," ",act_suffix)
      ENDIF
      , oc.description =
      IF (act_suffix="  ") concat("zz",substring(1,98,oc.description))
      ELSE concat("zz",trim(substring(1,95,oc.description))," ",act_suffix)
      ENDIF
      , oc.dept_display_name =
      IF (act_suffix="  ") concat("zz",substring(1,98,oc.dept_display_name))
      ELSE concat("zz",trim(substring(1,95,oc.dept_display_name))," ",act_suffix)
      ENDIF
      ,
      oc.active_ind = 0, oc.updt_dt_tm = cnvtdatetime(curdate,curtime3), oc.updt_id = reqinfo->
      updt_id,
      oc.updt_task = reqinfo->updt_task, oc.updt_applctx = reqinfo->updt_applctx, oc.updt_cnt = (oc
      .updt_cnt+ 1)
     WHERE (oc.catalog_cd=request->oc_list[x].catalog_code_value)
      AND oc.active_ind=1
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat(
      "Unable to inactivate orderable on order_catalog table with code_value = ",cnvtstring(request->
       oc_list[x].catalog_code_value))
     GO TO exit_script
    ENDIF
    UPDATE  FROM bill_item bi
     SET bi.ext_short_desc =
      IF (act_suffix="  ") concat("zz",substring(1,48,bi.ext_short_desc))
      ELSE concat("zz",trim(substring(1,45,bi.ext_short_desc))," ",act_suffix)
      ENDIF
      , bi.ext_description =
      IF (act_suffix="  ") concat("zz",substring(1,98,bi.ext_description))
      ELSE concat("zz",trim(substring(1,95,bi.ext_description))," ",act_suffix)
      ENDIF
      , bi.active_ind = 0,
      bi.active_status_cd = inactive_code_value, bi.updt_dt_tm = cnvtdatetime(curdate,curtime3), bi
      .updt_id = reqinfo->updt_id,
      bi.updt_task = reqinfo->updt_task, bi.updt_applctx = reqinfo->updt_applctx, bi.updt_cnt = (bi
      .updt_cnt+ 1)
     WHERE (bi.ext_parent_reference_id=request->oc_list[x].catalog_code_value)
      AND bi.active_ind=1
      AND bi.parent_qual_cd=1.0
      AND bi.ext_parent_contributor_cd=ord_cat_value
      AND bi.ext_child_reference_id=0.0
     WITH nocounter
    ;end update
    SET new_display = fillstring(38," ")
    SET new_description = fillstring(58," ")
    SELECT INTO "NL:"
     FROM code_value cv
     WHERE (cv.code_value=request->oc_list[x].catalog_code_value)
      AND cv.code_set=200
     DETAIL
      IF (act_suffix="  ")
       new_display = concat("zz",substring(1,38,cv.display)), new_description = concat("zz",substring
        (1,58,cv.description))
      ELSE
       new_display = concat("zz",trim(substring(1,35,cv.display))," ",act_suffix), new_description =
       concat("zz",trim(substring(1,55,cv.description))," ",act_suffix)
      ENDIF
     WITH nocounter
    ;end select
    UPDATE  FROM code_value cv
     SET cv.display = new_display, cv.description = new_description, cv.display_key = cnvtupper(
       cnvtalphanum(new_display)),
      cv.active_ind = 0, cv.active_type_cd = inactive_code_value, cv.inactive_dt_tm = cnvtdatetime(
       curdate,curtime3),
      cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_id = reqinfo->updt_id, cv.updt_task =
      reqinfo->updt_task,
      cv.updt_applctx = reqinfo->updt_applctx, cv.updt_cnt = (cv.updt_cnt+ 1)
     WHERE (cv.code_value=request->oc_list[x].catalog_code_value)
    ;end update
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to inactivate orderable on code_value table with ",
      "code_value = ",cnvtstring(request->oc_list[x].catalog_code_value))
     GO TO exit_script
    ENDIF
   ENDIF
  ELSEIF ((request->oc_list[x].action_flag=2))
   UPDATE  FROM order_catalog_synonym ocs
    SET ocs.activity_type_cd = request->oc_list[x].activity_type_code_value, ocs.updt_dt_tm =
     cnvtdatetime(curdate,curtime3), ocs.updt_id = reqinfo->updt_id,
     ocs.updt_task = reqinfo->updt_task, ocs.updt_applctx = reqinfo->updt_applctx, ocs.updt_cnt = (
     ocs.updt_cnt+ 1)
    WHERE (ocs.catalog_cd=request->oc_list[x].catalog_code_value)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat(
     "Unable to update orderable on order_catalog_synonym table with code_value = ",cnvtstring(
      request->oc_list[x].catalog_code_value))
    GO TO exit_script
   ENDIF
   UPDATE  FROM order_catalog oc
    SET oc.activity_type_cd = request->oc_list[x].activity_type_code_value, oc.updt_dt_tm =
     cnvtdatetime(curdate,curtime3), oc.updt_id = reqinfo->updt_id,
     oc.updt_task = reqinfo->updt_task, oc.updt_applctx = reqinfo->updt_applctx, oc.updt_cnt = (oc
     .updt_cnt+ 1)
    WHERE (oc.catalog_cd=request->oc_list[x].catalog_code_value)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Unable to update orderable on order_catalog table with code_value = ",
     cnvtstring(request->oc_list[x].catalog_code_value))
    GO TO exit_script
   ENDIF
   UPDATE  FROM bill_item bi
    SET bi.ext_owner_cd = request->oc_list[x].activity_type_code_value, bi.updt_dt_tm = cnvtdatetime(
      curdate,curtime3), bi.updt_id = reqinfo->updt_id,
     bi.updt_task = reqinfo->updt_task, bi.updt_applctx = reqinfo->updt_applctx, bi.updt_cnt = (bi
     .updt_cnt+ 1)
    WHERE (bi.ext_parent_reference_id=request->oc_list[x].catalog_code_value)
     AND bi.parent_qual_cd=1.0
     AND bi.active_ind=1
     AND bi.ext_parent_contributor_cd=ord_cat_value
     AND bi.ext_child_reference_id=0.0
    WITH nocounter
   ;end update
   IF (curqual=0)
    INSERT  FROM bill_item bi
     SET bi.bill_item_id = seq(bill_item_seq,nextval), bi.ext_parent_reference_id = request->oc_list[
      x].catalog_code_value, bi.ext_parent_contributor_cd = ord_cat_value,
      bi.ext_parent_entity_name = "CODE_VALUE", bi.parent_qual_cd = 1.0, bi.ext_child_reference_id =
      0.0,
      bi.ext_child_contributor_cd = 0.0, bi.ext_child_entity_name = null, bi.ext_description =
      request->oc_list[x].description,
      bi.ext_owner_cd = request->oc_list[x].activity_type_code_value, bi.ext_short_desc = substring(1,
       50,request->oc_list[x].display), bi.active_ind = 1,
      bi.active_status_cd = active_code_value, bi.active_status_dt_tm = cnvtdatetime(curdate,curtime3
       ), bi.active_status_prsnl_id = reqinfo->updt_id,
      bi.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), bi.end_effective_dt_tm = cnvtdatetime(
       "31-DEC-2100"), bi.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      bi.updt_id = reqinfo->updt_id, bi.updt_task = reqinfo->updt_task, bi.updt_cnt = 0,
      bi.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
   ENDIF
  ELSEIF ((request->oc_list[x].action_flag=1))
   SET active_ind = 0
   SET new_display = fillstring(40," ")
   SET new_description = fillstring(60," ")
   SELECT INTO "NL:"
    FROM code_value cv
    WHERE cv.code_set=200
     AND (cv.code_value=request->oc_list[x].catalog_code_value)
    DETAIL
     active_ind = cv.active_ind
     IF (cv.display="zz*")
      new_display = substring(3,37,cv.display)
     ELSE
      new_display = cv.display
     ENDIF
     IF (cv.description="zz*")
      new_description = substring(3,57,cv.description)
     ELSE
      new_description = cv.description
     ENDIF
    WITH nocounter
   ;end select
   IF (curqual=0)
    SELECT INTO "NL:"
     FROM br_auto_order_catalog b
     WHERE (b.catalog_cd=request->oc_list[x].catalog_code_value)
     DETAIL
      IF ((request->oc_list[x].display > "    "))
       primary_mnemonic = trim(request->oc_list[x].display)
      ELSE
       primary_mnemonic = b.primary_mnemonic
      ENDIF
      IF ((request->oc_list[x].description > "   "))
       description = trim(request->oc_list[x].description)
      ELSE
       description = b.description
      ENDIF
      dept_name = b.dept_name, concept_cki = b.concept_cki, cki = b.cki,
      dcp_code_value = b.dcp_clin_cat_cd, cat_type_code_value = b.catalog_type_cd,
      act_type_code_value = b.activity_type_cd,
      act_subtype_code_value = b.activity_subtype_cd, oe_format_id = b.oe_format_id,
      procedure_type_code_value = b.bb_processing_cd
     WITH nocounter, skipbedrock = 1
    ;end select
    SET new_cv = 0.0
    SELECT INTO "NL:"
     j = seq(reference_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      new_cv = cnvtreal(j)
     WITH format, counter
    ;end select
    SET reply->oc_list[x].catalog_code_value = new_cv
    INSERT  FROM code_value cv
     SET cv.code_value = new_cv, cv.code_set = 200, cv.active_ind = 1,
      cv.display = trim(substring(1,40,primary_mnemonic)), cv.display_key = trim(cnvtupper(
        cnvtalphanum(substring(1,40,primary_mnemonic)))), cv.description = trim(substring(1,60,
        description)),
      cv.concept_cki =
      IF (concept_cki > " ") concept_cki
      ELSE " "
      ENDIF
      , cv.cki = trim(cki), cv.data_status_cd = auth_cd,
      cv.active_type_cd = active_code_value, cv.active_dt_tm = cnvtdatetime(curdate,curtime3), cv
      .updt_dt_tm = cnvtdatetime(curdate,curtime3),
      cv.updt_id = reqinfo->updt_id, cv.updt_task = reqinfo->updt_task, cv.updt_applctx = reqinfo->
      updt_applctx,
      cv.updt_cnt = 0
     WITH nocounter
    ;end insert
    INSERT  FROM order_catalog oc
     SET oc.catalog_cd = new_cv, oc.dcp_clin_cat_cd = dcp_code_value, oc.catalog_type_cd =
      IF ((request->oc_list[x].catalog_type_code_value > 0)) request->oc_list[x].
       catalog_type_code_value
      ELSE cat_type_code_value
      ENDIF
      ,
      oc.activity_type_cd =
      IF ((request->oc_list[x].activity_type_code_value > 0)) request->oc_list[x].
       activity_type_code_value
      ELSE act_type_code_value
      ENDIF
      , oc.activity_subtype_cd =
      IF ((request->oc_list[x].activity_subtype_code_value > 0)) request->oc_list[x].
       activity_subtype_code_value
      ELSE act_subtype_code_value
      ENDIF
      , oc.oe_format_id = oe_format_id,
      oc.description = description, oc.primary_mnemonic = primary_mnemonic, oc.dept_display_name =
      dept_name,
      oc.orderable_type_flag =
      IF ((request->oc_list[x].catalog_type_code_value=surgery_cat_value)) 1
      ELSE 0
      ENDIF
      , oc.active_ind = 1, oc.cki = cki,
      oc.concept_cki =
      IF (concept_cki > " ") concept_cki
      ELSE null
      ENDIF
      , oc.consent_form_ind = 0, oc.inst_restriction_ind = 0,
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
      bi.ext_owner_cd =
      IF ((request->oc_list[x].activity_type_code_value > 0)) request->oc_list[x].
       activity_type_code_value
      ELSE act_type_code_value
      ENDIF
      , bi.parent_qual_cd = 1.0, bi.charge_point_cd = 0.0,
      bi.physician_qual_cd = 0.0, bi.calc_type_cd = 0.0, bi.updt_cnt = 0,
      bi.updt_dt_tm = cnvtdatetime(curdate,curtime3), bi.updt_id = reqinfo->updt_id, bi.updt_task =
      reqinfo->updt_task,
      bi.updt_applctx = reqinfo->updt_applctx, bi.active_ind = 1, bi.active_status_cd =
      active_code_value,
      bi.active_status_dt_tm = cnvtdatetime(curdate,curtime3), bi.active_status_prsnl_id = reqinfo->
      updt_id, bi.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
      bi.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"), bi.ext_short_desc = substring
      (1,50,primary_mnemonic), bi.ext_parent_entity_name = "CODE_VALUE",
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
     WHERE (b.catalog_cd=request->oc_list[x].catalog_code_value)
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
       SET ocs.synonym_id = syn->slist[z].synonym_id, ocs.catalog_cd = new_cv, ocs.catalog_type_cd =
        IF ((request->oc_list[x].catalog_type_code_value > 0)) request->oc_list[x].
         catalog_type_code_value
        ELSE syn->slist[z].catalog_type_cd
        ENDIF
        ,
        ocs.activity_type_cd =
        IF ((request->oc_list[x].activity_type_code_value > 0)) request->oc_list[x].
         activity_type_code_value
        ELSE syn->slist[z].activity_type_cd
        ENDIF
        , ocs.activity_subtype_cd =
        IF ((request->oc_list[x].activity_subtype_code_value > 0)) request->oc_list[x].
         activity_subtype_code_value
        ELSE syn->slist[z].activity_subtype_cd
        ENDIF
        , ocs.oe_format_id = syn->slist[z].oe_format_id,
        ocs.dcp_clin_cat_cd = dcp_code_value, ocs.orderable_type_flag =
        IF ((request->oc_list[x].catalog_type_code_value=surgery_cat_value)) 1
        ELSE 0
        ENDIF
        , ocs.ref_text_mask = 0,
        ocs.hide_flag = 0, ocs.cki = " ", ocs.virtual_view = " ",
        ocs.health_plan_view = " ", ocs.concentration_strength = 0, ocs.concentration_volume = 0,
        ocs.mnemonic = syn->slist[z].mnemonic, ocs.mnemonic_key_cap = cnvtupper(syn->slist[z].
         mnemonic), ocs.mnemonic_type_cd = syn->slist[z].mnemonic_type_cd,
        ocs.active_status_cd = active_code_value, ocs.active_status_dt_tm = cnvtdatetime(curdate,
         curtime3), ocs.active_ind = 1,
        ocs.active_status_prsnl_id = reqinfo->updt_id, ocs.updt_dt_tm = cnvtdatetime(curdate,curtime3
         ), ocs.updt_id = reqinfo->updt_id,
        ocs.updt_task = reqinfo->updt_task, ocs.updt_applctx = reqinfo->updt_applctx, ocs.updt_cnt =
        0
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
       s.frozen_section_req_ind = null, s.def_anesth_type_cd = 0, s.updt_dt_tm = cnvtdatetime(curdate,
        curtime3),
       s.updt_id = reqinfo->updt_id, s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->
       updt_applctx,
       s.updt_cnt = 0, s.create_dt_tm = cnvtdatetime(curdate,curtime3), s.create_prsnl_id = reqinfo->
       updt_id,
       s.create_task = reqinfo->updt_task, s.create_applctx = reqinfo->updt_applctx, s.setup_time = 0,
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
      SET l.short_description = dept_name, l.description = dept_name, l.catalog_cd = new_cv,
       l.bb_processing_cd = procedure_type_code_value, l.active_ind = 1, l.active_status_cd =
       active_code_value,
       l.active_status_dt_tm = cnvtdatetime(curdate,curtime3), l.active_status_prsnl_id = reqinfo->
       updt_id, l.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
       l.end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00.00"), l.updt_dt_tm = cnvtdatetime(
        curdate,curtime3), l.updt_id = reqinfo->updt_id,
       l.updt_task = reqinfo->updt_task, l.updt_applctx = reqinfo->updt_applctx, l.updt_cnt = 0
      WITH nocounter
     ;end insert
    ENDIF
   ELSEIF (active_ind=0)
    UPDATE  FROM code_value cv
     SET cv.display = new_display, cv.description = new_description, cv.display_key = cnvtupper(
       cnvtalphanum(new_display)),
      cv.active_ind = 1, cv.active_type_cd = active_code_value, cv.active_dt_tm = cnvtdatetime(
       curdate,curtime3),
      cv.inactive_dt_tm = null, cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_id = reqinfo
      ->updt_id,
      cv.updt_task = reqinfo->updt_task, cv.updt_applctx = reqinfo->updt_applctx, cv.updt_cnt = (cv
      .updt_cnt+ 1)
     WHERE (cv.code_value=request->oc_list[x].catalog_code_value)
    ;end update
    SET new_display = fillstring(40," ")
    SET new_description = fillstring(60," ")
    SET new_dept = fillstring(100," ")
    SELECT INTO "NL:"
     FROM order_catalog oc
     WHERE (oc.catalog_cd=request->oc_list[x].catalog_code_value)
     DETAIL
      new_display = oc.primary_mnemonic, new_description = oc.description, new_dept = oc
      .dept_display_name
     WITH nocounter
    ;end select
    UPDATE  FROM order_catalog oc
     SET oc.active_ind = 1, oc.primary_mnemonic =
      IF (((new_display="zz*") OR (new_display="ZZ*")) ) substring(3,97,oc.primary_mnemonic)
      ELSE oc.primary_mnemonic
      ENDIF
      , oc.description =
      IF (((new_description="zz*") OR (new_description="ZZ*")) ) substring(3,97,oc.description)
      ELSE oc.description
      ENDIF
      ,
      oc.dept_display_name =
      IF (((new_dept="zz*") OR (new_dept="ZZ*")) ) substring(3,97,oc.dept_display_name)
      ELSE oc.dept_display_name
      ENDIF
      , oc.activity_type_cd =
      IF ((request->oc_list[x].activity_type_code_value > 0)) request->oc_list[x].
       activity_type_code_value
      ELSE oc.activity_type_cd
      ENDIF
      , oc.activity_subtype_cd =
      IF ((request->oc_list[x].activity_subtype_code_value > 0)) request->oc_list[x].
       activity_subtype_code_value
      ELSE oc.activity_subtype_cd
      ENDIF
      ,
      oc.updt_dt_tm = cnvtdatetime(curdate,curtime3), oc.updt_id = reqinfo->updt_id, oc.updt_task =
      reqinfo->updt_task,
      oc.updt_applctx = reqinfo->updt_applctx, oc.updt_cnt = (oc.updt_cnt+ 1)
     WHERE (oc.catalog_cd=request->oc_list[x].catalog_code_value)
     WITH nocounter
    ;end update
    UPDATE  FROM bill_item bi
     SET bi.active_ind = 1, bi.active_status_cd = active_code_value, bi.ext_short_desc =
      IF (((new_display="zz*") OR (new_display="ZZ*")) ) substring(3,47,bi.ext_short_desc)
      ELSE bi.ext_short_desc
      ENDIF
      ,
      bi.ext_description =
      IF (((new_description="zz*") OR (new_description="ZZ*")) ) substring(3,97,bi.ext_description)
      ELSE bi.ext_description
      ENDIF
      , bi.ext_owner_cd =
      IF ((request->oc_list[x].activity_type_code_value > 0)) request->oc_list[x].
       activity_type_code_value
      ELSE bi.ext_owner_cd
      ENDIF
      , bi.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      bi.updt_id = reqinfo->updt_id, bi.updt_task = reqinfo->updt_task, bi.updt_applctx = reqinfo->
      updt_applctx,
      bi.updt_cnt = (bi.updt_cnt+ 1)
     WHERE (bi.ext_parent_reference_id=request->oc_list[x].catalog_code_value)
      AND bi.parent_qual_cd=1.0
      AND bi.ext_parent_contributor_cd=ord_cat_value
      AND bi.ext_child_reference_id=0.0
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET new_display = fillstring(40," ")
     SET new_description = fillstring(60," ")
     SELECT INTO "NL:"
      FROM order_catalog oc
      WHERE (oc.catalog_cd=request->oc_list[x].catalog_code_value)
      DETAIL
       new_display = oc.primary_mnemonic, new_description = oc.description
      WITH nocounter
     ;end select
     INSERT  FROM bill_item bi
      SET bi.bill_item_id = seq(bill_item_seq,nextval), bi.ext_parent_reference_id = request->
       oc_list[x].catalog_code_value, bi.ext_parent_contributor_cd = ord_cat_value,
       bi.ext_parent_entity_name = "CODE_VALUE", bi.parent_qual_cd = 1.0, bi.ext_child_reference_id
        = 0.0,
       bi.ext_child_contributor_cd = 0.0, bi.ext_child_entity_name = null, bi.ext_description =
       new_description,
       bi.ext_owner_cd = request->oc_list[x].activity_type_code_value, bi.ext_short_desc = substring(
        1,50,new_display), bi.active_ind = 1,
       bi.active_status_cd = active_code_value, bi.active_status_dt_tm = cnvtdatetime(curdate,
        curtime3), bi.active_status_prsnl_id = reqinfo->updt_id,
       bi.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), bi.end_effective_dt_tm = cnvtdatetime
       ("31-DEC-2100"), bi.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       bi.updt_id = reqinfo->updt_id, bi.updt_task = reqinfo->updt_task, bi.updt_cnt = 0,
       bi.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
    ENDIF
    SET stat = alterlist(syn->slist,50)
    SET i = 0
    SELECT INTO "NL:"
     FROM order_catalog_synonym ocs
     WHERE (ocs.catalog_cd=request->oc_list[x].catalog_code_value)
     DETAIL
      i = (i+ 1), syn->slist[i].synonym_id = ocs.synonym_id, syn->slist[i].mnemonic = ocs.mnemonic
     WITH nocounter
    ;end select
    SET stat = alterlist(syn->slist,i)
    IF (i > 0)
     UPDATE  FROM order_catalog_synonym ocs,
       (dummyt d  WITH seq = i)
      SET ocs.active_ind = 1, ocs.active_status_cd = active_code_value, ocs.active_status_dt_tm =
       cnvtdatetime(curdate,curtime3),
       ocs.mnemonic =
       IF ((((syn->slist[d.seq].mnemonic="zz*")) OR ((syn->slist[d.seq].mnemonic="ZZ*"))) ) substring
        (3,97,ocs.mnemonic)
       ELSE ocs.mnemonic
       ENDIF
       , ocs.mnemonic_key_cap =
       IF ((((syn->slist[d.seq].mnemonic="zz*")) OR ((syn->slist[d.seq].mnemonic="ZZ*"))) ) cnvtupper
        (substring(3,97,ocs.mnemonic))
       ELSE cnvtupper(ocs.mnemonic)
       ENDIF
       , ocs.activity_type_cd =
       IF ((request->oc_list[x].activity_type_code_value > 0)) request->oc_list[x].
        activity_type_code_value
       ELSE ocs.activity_type_cd
       ENDIF
       ,
       ocs.activity_subtype_cd =
       IF ((request->oc_list[x].activity_subtype_code_value > 0)) request->oc_list[x].
        activity_subtype_code_value
       ELSE ocs.activity_subtype_cd
       ENDIF
       , ocs.updt_dt_tm = cnvtdatetime(curdate,curtime3), ocs.updt_id = reqinfo->updt_id,
       ocs.updt_task = reqinfo->updt_task, ocs.updt_applctx = reqinfo->updt_applctx, ocs.updt_cnt = (
       ocs.updt_cnt+ 1)
      PLAN (d)
       JOIN (ocs
       WHERE (ocs.synonym_id=syn->slist[d.seq].synonym_id))
      WITH nocounter
     ;end update
    ENDIF
    UPDATE  FROM service_directory l
     SET l.description =
      IF (((new_description="zz*") OR (new_description="ZZ*")) ) substring(3,97,new_description)
      ELSE new_description
      ENDIF
      , l.short_description =
      IF (((new_dept="zz*") OR (new_dept="ZZ*")) ) substring(3,97,new_dept)
      ELSE new_dept
      ENDIF
      , l.active_ind = 1,
      l.active_status_cd = active_code_value, l.active_dt_tm = cnvtdatetime(curdate,curtime3), l
      .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
      l.inactive_dt_tm = null, l.updt_dt_tm = cnvtdatetime(curdate,curtime3), l.updt_id = reqinfo->
      updt_id,
      l.updt_task = reqinfo->updt_task, l.updt_applctx = reqinfo->updt_applctx, l.updt_cnt = (l
      .updt_cnt+ 1)
     WHERE (l.catalog_cd=request->oc_list[x].catalog_code_value)
     WITH nocounter
    ;end update
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
       SET s.catalog_cd = request->oc_list[x].catalog_code_value, s.def_proc_dur = null, s
        .surg_specialty_id = 0,
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
     ENDIF
    ENDIF
   ELSEIF (active_ind=1)
    IF ((((request->oc_list[x].activity_type_code_value > 0)) OR ((request->oc_list[x].
    activity_subtype_code_value > 0))) )
     UPDATE  FROM order_catalog oc
      SET oc.activity_type_cd =
       IF ((request->oc_list[x].activity_type_code_value > 0)) request->oc_list[x].
        activity_type_code_value
       ELSE oc.activity_type_cd
       ENDIF
       , oc.activity_subtype_cd =
       IF ((request->oc_list[x].activity_subtype_code_value > 0)) request->oc_list[x].
        activity_subtype_code_value
       ELSE oc.activity_subtype_cd
       ENDIF
       , oc.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       oc.updt_id = reqinfo->updt_id, oc.updt_task = reqinfo->updt_task, oc.updt_applctx = reqinfo->
       updt_applctx,
       oc.updt_cnt = (oc.updt_cnt+ 1)
      WHERE (oc.catalog_cd=request->oc_list[x].catalog_code_value)
      WITH nocounter
     ;end update
     UPDATE  FROM bill_item bi
      SET bi.ext_owner_cd =
       IF ((request->oc_list[x].activity_type_code_value > 0)) request->oc_list[x].
        activity_type_code_value
       ELSE bi.ext_owner_cd
       ENDIF
       , bi.updt_dt_tm = cnvtdatetime(curdate,curtime3), bi.updt_id = reqinfo->updt_id,
       bi.updt_task = reqinfo->updt_task, bi.updt_applctx = reqinfo->updt_applctx, bi.updt_cnt = (bi
       .updt_cnt+ 1)
      WHERE (bi.ext_parent_reference_id=request->oc_list[x].catalog_code_value)
       AND bi.parent_qual_cd=1.0
       AND bi.active_ind=1
       AND bi.ext_parent_contributor_cd=ord_cat_value
       AND bi.ext_child_reference_id=0.0
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET new_display = fillstring(40," ")
      SET new_description = fillstring(60," ")
      SELECT INTO "NL:"
       FROM order_catalog oc
       WHERE (oc.catalog_cd=request->oc_list[x].catalog_code_value)
       DETAIL
        new_display = oc.primary_mnemonic, new_description = oc.description
       WITH nocounter
      ;end select
      INSERT  FROM bill_item bi
       SET bi.bill_item_id = seq(bill_item_seq,nextval), bi.ext_parent_reference_id = request->
        oc_list[x].catalog_code_value, bi.ext_parent_contributor_cd = ord_cat_value,
        bi.ext_parent_entity_name = "CODE_VALUE", bi.parent_qual_cd = 1.0, bi.ext_child_reference_id
         = 0.0,
        bi.ext_child_contributor_cd = 0.0, bi.ext_child_entity_name = null, bi.ext_description =
        new_description,
        bi.ext_owner_cd = request->oc_list[x].activity_type_code_value, bi.ext_short_desc = substring
        (1,50,new_display), bi.active_ind = 1,
        bi.active_status_cd = active_code_value, bi.active_status_dt_tm = cnvtdatetime(curdate,
         curtime3), bi.active_status_prsnl_id = reqinfo->updt_id,
        bi.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), bi.end_effective_dt_tm =
        cnvtdatetime("31-DEC-2100"), bi.updt_dt_tm = cnvtdatetime(curdate,curtime3),
        bi.updt_id = reqinfo->updt_id, bi.updt_task = reqinfo->updt_task, bi.updt_cnt = 0,
        bi.updt_applctx = reqinfo->updt_applctx
       WITH nocounter
      ;end insert
     ENDIF
     UPDATE  FROM order_catalog_synonym ocs
      SET ocs.activity_type_cd =
       IF ((request->oc_list[x].activity_type_code_value > 0)) request->oc_list[x].
        activity_type_code_value
       ELSE ocs.activity_type_cd
       ENDIF
       , ocs.activity_subtype_cd =
       IF ((request->oc_list[x].activity_subtype_code_value > 0)) request->oc_list[x].
        activity_subtype_code_value
       ELSE ocs.activity_subtype_cd
       ENDIF
       , ocs.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       ocs.updt_id = reqinfo->updt_id, ocs.updt_task = reqinfo->updt_task, ocs.updt_applctx = reqinfo
       ->updt_applctx,
       ocs.updt_cnt = (ocs.updt_cnt+ 1)
      WHERE (ocs.catalog_cd=request->oc_list[x].catalog_code_value)
      WITH nocounter
     ;end update
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
        SET s.catalog_cd = request->oc_list[x].catalog_code_value, s.def_proc_dur = null, s
         .surg_specialty_id = 0,
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
        SET error_msg = concat("Unable to insert ",trim(primary_mnemonic)," into surgical_procedure."
         )
        GO TO exit_script
       ENDIF
      ENDIF
     ENDIF
    ENDIF
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
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_ENS_OC_START_ACCEPTED","  >> ERROR MSG: ",
   error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
