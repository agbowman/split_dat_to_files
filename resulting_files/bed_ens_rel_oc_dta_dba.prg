CREATE PROGRAM bed_ens_rel_oc_dta:dba
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
   1 assays[*]
     2 code_value = f8
     2 duplicate_event_ind = i2
 )
 FREE SET temp_oc
 RECORD temp_oc(
   1 oc_list[*]
     2 catalog_cd = f8
 )
 FREE SET temp_sr
 RECORD temp_sr(
   1 sr_list[*]
     2 service_resource_cd = f8
     2 ok_to_inactivate = i2
 )
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 SET error_flag = "N"
 SET active_code_value = 0.0
 SET inactive_code_value = 0.0
 SET mnemonic = fillstring(50," ")
 SET description = fillstring(100," ")
 SET result_type_cd = 0.0
 SET result_process_cd = 0.0
 SET update_only = 0
 DECLARE event_code = vc
 SET order_activity_type_cd = 0.0
 SET first_only_ind = 0
 SET oc_count = 0
 SET oc_tot_count = 0
 SET sr_count = 0
 SET sr_tot_count = 0
 SET auto_client_id = 0.0
 SELECT INTO "NL:"
  FROM br_client b
  DETAIL
   auto_client_id = b.autobuild_client_id
  WITH nocounter
 ;end select
 SET bill_item_id = 0.0
 SET catalog_type_cd = 0.0
 SET oc_contributor_cd = 0.0
 SET dta_contributor_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=13016
   AND cv.cdf_meaning IN ("ORD CAT", "TASK ASSAY")
   AND cv.active_ind=1
  DETAIL
   IF (cv.cdf_meaning="ORD CAT")
    oc_contributor_cd = cv.code_value
   ELSE
    dta_contributor_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
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
 SELECT INTO "nl:"
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
 SET micro_cd = 0.0
 SET bb_cd = 0.0
 SET ap_cd = 0.0
 SET hla_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.active_ind=1
   AND cv.code_set=106
   AND cv.cdf_meaning IN ("BB", "MICROBIOLOGY", "AP", "HLA")
  DETAIL
   CASE (cv.cdf_meaning)
    OF "BB":
     bb_cd = cv.code_value
    OF "MICROBIOLOGY":
     micro_cd = cv.code_value
    OF "AP":
     ap_cd = cv.code_value
    OF "HLA":
     hla_cd = cv.code_value
   ENDCASE
  WITH nocounter
 ;end select
 DECLARE hlx_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",106,"HLX"))
 SET rel_cnt = size(request->rel_list,5)
 SET stat = alterlist(reply->assays,rel_cnt)
 FOR (x = 1 TO rel_cnt)
   IF ((request->rel_list[x].action_flag=1))
    SET 14003_cd = 0.0
    SET mnemonic = fillstring(50," ")
    SET description = fillstring(100," ")
    SET result_type_cd = 0.0
    SET activity_type_cd = 0.0
    IF ((request->rel_list[x].dta_code_value > 0))
     SELECT INTO "NL:"
      FROM code_value cv
      WHERE cv.code_set=14003
       AND (cv.code_value=request->rel_list[x].dta_code_value)
      DETAIL
       14003_cd = cv.code_value
      WITH nocounter
     ;end select
    ENDIF
    SET update_only = 0
    IF (((curqual=0) OR ((request->rel_list[x].dta_code_value=0))) )
     SET dta_display_upper = fillstring(50," ")
     IF ((request->rel_list[x].dta_code_value > 0))
      SELECT INTO "NL:"
       FROM br_auto_dta b
       WHERE (b.task_assay_cd=request->rel_list[x].dta_code_value)
       DETAIL
        activity_type_cd = b.activity_type_cd, result_type_cd = b.result_type_cd, mnemonic = b
        .mnemonic,
        description = b.description, dta_display_upper = cnvtupper(b.mnemonic)
       WITH nocounter, skipbedrock = 1
      ;end select
      IF (curqual=0)
       SET error_flag = "Y"
       SET error_msg = concat("Unable to find  ",cnvtstring(request->rel_list[x].dta_code_value),
        " into cs 14003 and br_auto_dta table.")
       GO TO exit_script
      ENDIF
      IF (activity_type_cd != bb_cd)
       SELECT INTO "NL:"
        FROM discrete_task_assay dta
        WHERE dta.mnemonic_key_cap=dta_display_upper
        DETAIL
         request->rel_list[x].dta_code_value = dta.task_assay_cd, 14003_cd = request->rel_list[x].
         dta_code_value
        WITH nocounter
       ;end select
      ELSE
       SELECT INTO "NL:"
        FROM discrete_task_assay dta
        WHERE dta.mnemonic=mnemonic
        DETAIL
         request->rel_list[x].dta_code_value = dta.task_assay_cd, 14003_cd = request->rel_list[x].
         dta_code_value
        WITH nocounter
       ;end select
      ENDIF
     ENDIF
    ENDIF
    IF (14003_cd=0)
     SELECT INTO "NL:"
      j = seq(reference_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       request->rel_list[x].dta_code_value = cnvtreal(j), 14003_cd = request->rel_list[x].
       dta_code_value
      WITH format, counter
     ;end select
     IF ((request->rel_list[x].mnemonic > " "))
      SET mnemonic = request->rel_list[x].mnemonic
     ENDIF
     IF ((request->rel_list[x].description > " "))
      SET description = request->rel_list[x].description
     ENDIF
     IF ((request->rel_list[x].activity_type_code_value > 0))
      SET activity_type_cd = request->rel_list[x].activity_type_code_value
     ENDIF
     IF ((request->rel_list[x].result_type_code_value > 0))
      SET result_type_cd = request->rel_list[x].result_type_code_value
     ENDIF
     INSERT  FROM code_value cv
      SET cv.code_value = 14003_cd, cv.code_set = 14003, cv.active_ind = 1,
       cv.display = trim(substring(1,40,mnemonic)), cv.display_key = trim(cnvtupper(cnvtalphanum(
          substring(1,40,mnemonic)))), cv.description = trim(substring(1,60,description)),
       cv.definition = trim(substring(1,60,description)), cv.active_type_cd = active_code_value, cv
       .active_dt_tm = cnvtdatetime(curdate,curtime3),
       cv.active_status_prsnl_id = reqinfo->updt_id, cv.data_status_cd = auth_cd, cv
       .data_status_dt_tm = cnvtdatetime(curdate,curtime3),
       cv.data_status_prsnl_id = reqinfo->updt_id, cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv
       .updt_id = reqinfo->updt_id,
       cv.updt_task = reqinfo->updt_task, cv.updt_applctx = reqinfo->updt_applctx, cv.updt_cnt = 0
      WITH nocounter
     ;end insert
     INSERT  FROM discrete_task_assay dta
      SET dta.task_assay_cd = 14003_cd, dta.mnemonic_key_cap = cnvtupper(mnemonic), dta
       .activity_type_cd = activity_type_cd,
       dta.default_result_type_cd = result_type_cd, dta.mnemonic = mnemonic, dta.description =
       description,
       dta.bb_result_processing_cd = request->rel_list[x].result_process_code_value, dta.concept_cki
        = request->rel_list[x].concept_cki, dta.code_set = 0,
       dta.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), dta.end_effective_dt_tm =
       cnvtdatetime("31-dec-2100 00:00:00.00"), dta.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       dta.updt_id = reqinfo->updt_id, dta.updt_task = reqinfo->updt_task, dta.updt_applctx = reqinfo
       ->updt_applctx,
       dta.active_status_cd = active_code_value, dta.active_status_prsnl_id = reqinfo->updt_id, dta
       .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
       dta.active_ind = 1
      WITH nocounter
     ;end insert
     INSERT  FROM profile_task_r ptr
      SET ptr.task_assay_cd = 14003_cd, ptr.catalog_cd = request->rel_list[x].oc_code_value, ptr
       .sequence = request->rel_list[x].sequence,
       ptr.post_prompt_ind = request->rel_list[x].post_verify_ind, ptr.restrict_display_ind = request
       ->rel_list[x].restrict_display_ind, ptr.pending_ind = request->rel_list[x].required_ind,
       ptr.item_type_flag = request->rel_list[x].prompt_test_ind, ptr.version_nbr = 0, ptr.repeat_ind
        = 0,
       ptr.dup_chk_min = 0, ptr.active_status_cd = active_code_value, ptr.active_status_prsnl_id =
       reqinfo->updt_id,
       ptr.active_status_dt_tm = cnvtdatetime(curdate,curtime3), ptr.active_ind = 1, ptr
       .beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
       ptr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), ptr.updt_dt_tm = cnvtdatetime(curdate,
        curtime3), ptr.updt_id = reqinfo->updt_id,
       ptr.updt_task = reqinfo->updt_task, ptr.updt_cnt = 1, ptr.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_msg = concat("Unable to insert ",cnvtstring(request->rel_list[x].oc_code_value),
       " into profile_task_r table.")
      GO TO exit_script
     ENDIF
    ELSE
     SELECT INTO "NL:"
      FROM profile_task_r ptr
      WHERE (ptr.catalog_cd=request->rel_list[x].oc_code_value)
       AND (ptr.task_assay_cd=request->rel_list[x].dta_code_value)
      DETAIL
       update_only = 1
      WITH nocounter
     ;end select
     SET 14003_cd = request->rel_list[x].dta_code_value
     IF ((request->rel_list[x].mnemonic > " "))
      SET mnemonic = request->rel_list[x].mnemonic
     ENDIF
     IF ((request->rel_list[x].description > " "))
      SET description = request->rel_list[x].description
     ENDIF
     IF ((request->rel_list[x].activity_type_code_value > 0))
      SET activity_type_cd = request->rel_list[x].activity_type_code_value
     ENDIF
     IF ((request->rel_list[x].result_type_code_value > 0))
      SET result_type_cd = request->rel_list[x].result_type_code_value
     ENDIF
     IF ((request->rel_list[x].result_process_code_value > 0))
      SET result_process_cd = request->rel_list[x].result_process_code_value
     ENDIF
     IF (((mnemonic > " ") OR (((description > " ") OR (((activity_type_cd > 0) OR (((result_type_cd
      > 0) OR (((result_process_cd > 0) OR (size(trim(request->rel_list[x].concept_cki)) > 0)) )) ))
     )) )) )
      UPDATE  FROM discrete_task_assay dta
       SET dta.mnemonic_key_cap =
        IF (mnemonic > " ") cnvtupper(mnemonic)
        ELSE dta.mnemonic_key_cap
        ENDIF
        , dta.activity_type_cd =
        IF (activity_type_cd > 0) activity_type_cd
        ELSE dta.activity_type_cd
        ENDIF
        , dta.default_result_type_cd =
        IF (result_type_cd > 0) result_type_cd
        ELSE dta.default_result_type_cd
        ENDIF
        ,
        dta.mnemonic =
        IF (mnemonic > " ") mnemonic
        ELSE dta.mnemonic
        ENDIF
        , dta.description =
        IF (description > " ") description
        ELSE dta.description
        ENDIF
        , dta.bb_result_processing_cd =
        IF (result_process_cd > 0) result_process_cd
        ELSE dta.bb_result_processing_cd
        ENDIF
        ,
        dta.concept_cki =
        IF (size(trim(request->rel_list[x].concept_cki)) > 0) request->rel_list[x].concept_cki
        ELSE dta.concept_cki
        ENDIF
        , dta.updt_dt_tm = cnvtdatetime(curdate,curtime3), dta.updt_id = reqinfo->updt_id,
        dta.updt_task = reqinfo->updt_task, dta.updt_cnt = (dta.updt_cnt+ 1), dta.updt_applctx =
        reqinfo->updt_applctx
       WHERE dta.task_assay_cd=14003_cd
       WITH nocounter
      ;end update
     ENDIF
     IF (((mnemonic > " ") OR (description > " ")) )
      UPDATE  FROM code_value cv
       SET cv.display =
        IF (mnemonic > " ") trim(substring(1,40,mnemonic))
        ELSE cv.display
        ENDIF
        , cv.display_key =
        IF (mnemonic > " ") trim(cnvtupper(cnvtalphanum(substring(1,40,mnemonic))))
        ELSE cv.display_key
        ENDIF
        , cv.description =
        IF (description > " ") trim(substring(1,60,description))
        ELSE cv.description
        ENDIF
        ,
        cv.definition =
        IF (description > " ") trim(substring(1,60,description))
        ELSE cv.definition
        ENDIF
        , cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_id = reqinfo->updt_id,
        cv.updt_task = reqinfo->updt_task, cv.updt_applctx = reqinfo->updt_applctx, cv.updt_cnt = (cv
        .updt_cnt+ 1)
       WHERE cv.code_value=14003_cd
       WITH nocounter
      ;end update
      UPDATE  FROM bill_item b
       SET b.ext_description =
        IF (description > " ") description
        ELSE b.ext_description
        ENDIF
        , b.ext_short_desc =
        IF (mnemonic > " ") substring(1,50,mnemonic)
        ELSE b.ext_short_desc
        ENDIF
        , b.updt_dt_tm = cnvtdatetime(curdate,curtime3),
        b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_cnt = (b.updt_cnt+ 1),
        b.updt_applctx = reqinfo->updt_applctx
       WHERE b.ext_child_contributor_cd=dta_contributor_cd
        AND b.ext_child_reference_id=14003_cd
        AND b.ext_child_entity_name="CODE_VALUE"
       WITH nocounter
      ;end update
     ENDIF
     IF (update_only=0)
      INSERT  FROM profile_task_r ptr
       SET ptr.task_assay_cd = 14003_cd, ptr.catalog_cd = request->rel_list[x].oc_code_value, ptr
        .sequence = request->rel_list[x].sequence,
        ptr.post_prompt_ind = request->rel_list[x].post_verify_ind, ptr.restrict_display_ind =
        request->rel_list[x].restrict_display_ind, ptr.pending_ind = request->rel_list[x].
        required_ind,
        ptr.item_type_flag = request->rel_list[x].prompt_test_ind, ptr.version_nbr = 0, ptr
        .repeat_ind = 0,
        ptr.dup_chk_min = 0, ptr.active_status_cd = active_code_value, ptr.active_status_prsnl_id =
        reqinfo->updt_id,
        ptr.active_status_dt_tm = cnvtdatetime(curdate,curtime3), ptr.active_ind = 1, ptr
        .beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
        ptr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), ptr.updt_dt_tm = cnvtdatetime(curdate,
         curtime3), ptr.updt_id = reqinfo->updt_id,
        ptr.updt_task = reqinfo->updt_task, ptr.updt_cnt = 1, ptr.updt_applctx = reqinfo->
        updt_applctx
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET error_flag = "Y"
       SET error_msg = concat("Unable to insert ",cnvtstring(request->rel_list[x].oc_code_value),
        " into profile_task_r table.")
       GO TO exit_script
      ENDIF
     ELSE
      UPDATE  FROM profile_task_r ptr
       SET ptr.sequence = request->rel_list[x].sequence, ptr.post_prompt_ind = request->rel_list[x].
        post_verify_ind, ptr.restrict_display_ind = request->rel_list[x].restrict_display_ind,
        ptr.pending_ind = request->rel_list[x].required_ind, ptr.item_type_flag = request->rel_list[x
        ].prompt_test_ind, ptr.active_ind = 1,
        ptr.active_status_cd = active_code_value, ptr.active_status_prsnl_id = reqinfo->updt_id, ptr
        .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
        ptr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), ptr.updt_dt_tm = cnvtdatetime(
         curdate,curtime3), ptr.updt_id = reqinfo->updt_id,
        ptr.updt_task = reqinfo->updt_task, ptr.updt_cnt = 0, ptr.updt_applctx = reqinfo->
        updt_applctx
       WHERE (ptr.task_assay_cd=request->rel_list[x].dta_code_value)
        AND (ptr.catalog_cd=request->rel_list[x].oc_code_value)
       WITH nocounter
      ;end update
      IF (curqual=0)
       SET error_flag = "Y"
       SET error_msg = concat("Unable to update ",cnvtstring(request->rel_list[x].oc_code_value),
        " on the profile_task_r table.")
       GO TO exit_script
      ENDIF
     ENDIF
    ENDIF
    SET upd_bill_item = 0
    SET bill_mnemonic = fillstring(50," ")
    SET bill_description = fillstring(100," ")
    SELECT INTO "NL:"
     FROM discrete_task_assay dta
     WHERE dta.task_assay_cd=14003_cd
     DETAIL
      bill_mnemonic = dta.mnemonic, bill_description = dta.description, activity_type_cd = dta
      .activity_type_cd
     WITH nocounter
    ;end select
    SET catalog_type_cd = 0.0
    SELECT INTO "NL"
     FROM code_value cv106,
      code_value cv6000
     PLAN (cv106
      WHERE cv106.code_value=activity_type_cd)
      JOIN (cv6000
      WHERE cv6000.active_ind=1
       AND cv6000.code_set=6000
       AND cnvtupper(cv6000.cdf_meaning)=cnvtupper(cv106.definition))
     DETAIL
      catalog_type_cd = cv6000.code_value
     WITH nocounter
    ;end select
    SET oc_activity_type_cd = 0.0
    SELECT INTO "NL:"
     FROM order_catalog oc
     WHERE (oc.catalog_cd=request->rel_list[x].oc_code_value)
     DETAIL
      oc_activity_type_cd = oc.activity_type_cd
     WITH nocounter
    ;end select
    SET bill_item_id = 0.0
    SELECT INTO "NL:"
     FROM bill_item b
     WHERE b.ext_parent_reference_id=catalog_type_cd
      AND b.ext_parent_contributor_cd=oc_contributor_cd
      AND b.ext_parent_entity_name="CODE_VALUE"
      AND b.ext_child_reference_id=14003_cd
      AND b.ext_child_contributor_cd=dta_contributor_cd
      AND b.ext_child_entity_name="CODE_VALUE"
     DETAIL
      IF (((b.active_ind=0) OR (((b.ext_description != bill_description) OR (((b.ext_short_desc !=
      bill_mnemonic) OR (oc_activity_type_cd != b.ext_owner_cd)) )) )) )
       upd_bill_item = 1
      ENDIF
      bill_item_id = b.bill_item_id
     WITH nocounter
    ;end select
    IF (curqual=0)
     INSERT  FROM bill_item b
      SET b.bill_item_id = seq(bill_item_seq,nextval), b.ext_parent_reference_id = catalog_type_cd, b
       .ext_parent_contributor_cd = oc_contributor_cd,
       b.ext_parent_entity_name = "CODE_VALUE", b.ext_child_reference_id = 14003_cd, b
       .ext_child_contributor_cd = dta_contributor_cd,
       b.ext_child_entity_name = "CODE_VALUE", b.ext_description = bill_description, b.ext_short_desc
        = bill_mnemonic,
       b.ext_owner_cd = oc_activity_type_cd, b.active_ind = 1, b.active_status_cd = active_code_value,
       b.active_status_dt_tm = cnvtdatetime(curdate,curtime3), b.active_status_prsnl_id = reqinfo->
       updt_id, b.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
       b.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), b.updt_dt_tm = cnvtdatetime(curdate,
        curtime3), b.updt_id = reqinfo->updt_id,
       b.updt_task = reqinfo->updt_task, b.updt_cnt = 0, b.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
    ELSEIF (upd_bill_item=1
     AND bill_item_id > 0)
     UPDATE  FROM bill_item b
      SET b.ext_description = bill_description, b.ext_short_desc = bill_mnemonic, b.ext_owner_cd =
       oc_activity_type_cd,
       b.active_ind = 1, b.active_status_cd = active_code_value, b.updt_dt_tm = cnvtdatetime(curdate,
        curtime3),
       b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_cnt = (b.updt_cnt+ 1),
       b.updt_applctx = reqinfo->updt_applctx
      WHERE b.bill_item_id=bill_item_id
     ;end update
    ENDIF
    SET upd_bill_item = 0
    SET bill_item_id = 0.0
    SELECT INTO "NL:"
     FROM bill_item b
     WHERE b.ext_parent_reference_id=0.0
      AND b.ext_parent_contributor_cd=0.0
      AND b.ext_parent_entity_name=null
      AND b.ext_child_reference_id=14003_cd
      AND b.ext_child_contributor_cd=dta_contributor_cd
      AND b.ext_child_entity_name="CODE_VALUE"
     DETAIL
      IF (((b.active_ind=0) OR (((b.ext_description != bill_description) OR (b.ext_short_desc !=
      bill_mnemonic)) )) )
       upd_bill_item = 1
      ENDIF
      bill_item_id = b.bill_item_id
     WITH nocounter
    ;end select
    IF (curqual=0)
     INSERT  FROM bill_item b
      SET b.bill_item_id = seq(bill_item_seq,nextval), b.ext_parent_reference_id = 0.0, b
       .ext_parent_contributor_cd = 0.0,
       b.ext_parent_entity_name = null, b.ext_child_reference_id = 14003_cd, b
       .ext_child_contributor_cd = dta_contributor_cd,
       b.ext_child_entity_name = "CODE_VALUE", b.ext_description = bill_description, b.ext_short_desc
        = bill_mnemonic,
       b.active_ind = 1, b.active_status_cd = active_code_value, b.active_status_dt_tm = cnvtdatetime
       (curdate,curtime3),
       b.active_status_prsnl_id = reqinfo->updt_id, b.beg_effective_dt_tm = cnvtdatetime(curdate,
        curtime3), b.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
       b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task =
       reqinfo->updt_task,
       b.updt_cnt = 0, b.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
    ELSEIF (upd_bill_item=1
     AND bill_item_id > 0)
     UPDATE  FROM bill_item b
      SET b.ext_description = bill_description, b.ext_short_desc = bill_mnemonic, b.active_ind = 1,
       b.active_status_cd = active_code_value, b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b
       .updt_id = reqinfo->updt_id,
       b.updt_task = reqinfo->updt_task, b.updt_cnt = (b.updt_cnt+ 1), b.updt_applctx = reqinfo->
       updt_applctx
      WHERE b.bill_item_id=bill_item_id
     ;end update
    ENDIF
    UPDATE  FROM bill_item b
     SET b.ext_description = bill_description, b.ext_short_desc = bill_mnemonic, b.ext_owner_cd =
      oc_activity_type_cd,
      b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task =
      reqinfo->updt_task,
      b.updt_cnt = (b.updt_cnt+ 1), b.updt_applctx = reqinfo->updt_applctx
     WHERE b.ext_parent_reference_id > 0
      AND b.ext_parent_contributor_cd=oc_contributor_cd
      AND b.ext_parent_entity_name="CODE_VALUE"
      AND b.ext_child_reference_id=14003_cd
      AND b.ext_child_contributor_cd=dta_contributor_cd
      AND b.ext_child_entity_name="CODE_VALUE"
      AND b.active_ind=1
      AND ((b.ext_description != bill_description) OR (((b.ext_short_desc != bill_mnemonic) OR (b
     .ext_owner_cd != oc_activity_type_cd)) ))
     WITH nocounter
    ;end update
    SET upd_bill_item = 0
    SET bill_item_id = 0.0
    SELECT INTO "NL:"
     FROM bill_item b
     WHERE (b.ext_parent_reference_id=request->rel_list[x].oc_code_value)
      AND b.ext_parent_contributor_cd=oc_contributor_cd
      AND b.ext_parent_entity_name="CODE_VALUE"
      AND b.ext_child_reference_id=14003_cd
      AND b.ext_child_contributor_cd=dta_contributor_cd
      AND b.ext_child_entity_name="CODE_VALUE"
     DETAIL
      IF (b.active_ind=0)
       upd_bill_item = 1
      ENDIF
      bill_item_id = b.bill_item_id
     WITH nocounter
    ;end select
    IF (curqual=0)
     INSERT  FROM bill_item b
      SET b.bill_item_id = seq(bill_item_seq,nextval), b.ext_parent_reference_id = request->rel_list[
       x].oc_code_value, b.ext_parent_contributor_cd = oc_contributor_cd,
       b.ext_parent_entity_name = "CODE_VALUE", b.ext_child_reference_id = 14003_cd, b
       .ext_child_contributor_cd = dta_contributor_cd,
       b.ext_child_entity_name = "CODE_VALUE", b.ext_description = bill_description, b.ext_short_desc
        = bill_mnemonic,
       b.ext_owner_cd = oc_activity_type_cd, b.active_ind = 1, b.active_status_cd = active_code_value,
       b.active_status_dt_tm = cnvtdatetime(curdate,curtime3), b.active_status_prsnl_id = reqinfo->
       updt_id, b.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
       b.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), b.updt_dt_tm = cnvtdatetime(curdate,
        curtime3), b.updt_id = reqinfo->updt_id,
       b.updt_task = reqinfo->updt_task, b.updt_cnt = 0, b.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
    ELSEIF (upd_bill_item=1
     AND bill_item_id > 0)
     UPDATE  FROM bill_item b
      SET b.ext_description = bill_description, b.ext_short_desc = bill_mnemonic, b.ext_owner_cd =
       oc_activity_type_cd,
       b.active_ind = 1, b.active_status_cd = active_code_value, b.updt_dt_tm = cnvtdatetime(curdate,
        curtime3),
       b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_cnt = (b.updt_cnt+ 1),
       b.updt_applctx = reqinfo->updt_applctx
      WHERE b.bill_item_id=bill_item_id
      WITH nocounter
     ;end update
    ENDIF
    SET reltn_found = 0
    SELECT INTO "nl:"
     FROM code_value_event_r c
     PLAN (c
      WHERE (c.event_cd=request->rel_list[x].event.code_value)
       AND c.parent_cd=14003_cd)
     DETAIL
      reltn_found = 1
     WITH nocounter
    ;end select
    IF (reltn_found=0)
     IF ((request->rel_list[x].event.code_value > 0)
      AND 14003_cd > 0)
      SET event_found = 0
      SELECT INTO "nl:"
       FROM code_value_event_r c
       PLAN (c
        WHERE (c.event_cd=request->rel_list[x].event.code_value))
       DETAIL
        event_found = 1
       WITH nocounter
      ;end select
      IF (event_found=0)
       INSERT  FROM code_value_event_r c
        SET c.event_cd = request->rel_list[x].event.code_value, c.parent_cd = 14003_cd, c.flex1_cd =
         0,
         c.flex2_cd = 0, c.flex3_cd = 0, c.flex4_cd = 0,
         c.flex5_cd = 0, c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_id = reqinfo->updt_id,
         c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = 0
        PLAN (c)
        WITH nocounter
       ;end insert
      ELSE
       UPDATE  FROM code_value_event_r c
        SET c.parent_cd = 14003_cd, c.flex1_cd = 0, c.flex2_cd = 0,
         c.flex3_cd = 0, c.flex4_cd = 0, c.flex5_cd = 0,
         c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_id = reqinfo->updt_id, c.updt_task =
         reqinfo->updt_task,
         c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = (c.updt_cnt+ 1)
        PLAN (c
         WHERE (c.event_cd=request->rel_list[x].event.code_value))
        WITH nocounter
       ;end update
      ENDIF
     ENDIF
    ENDIF
    IF ((request->rel_list[x].event.display > " "))
     SET update_cv = 0
     SELECT INTO "nl:"
      FROM code_value cv
      PLAN (cv
       WHERE cv.code_set=72
        AND cnvtupper(cv.display)=cnvtupper(request->rel_list[x].event.display))
      DETAIL
       update_cv = 1
       IF ((cv.code_value != request->rel_list[x].event.code_value))
        reply->assays[x].duplicate_event_ind = 1
       ENDIF
       IF ((cv.code_value=request->rel_list[x].event.code_value)
        AND (cv.display != request->rel_list[x].event.display))
        update_cv = 0
       ENDIF
      WITH nocounter
     ;end select
     IF (update_cv=0
      AND (reply->assays[x].duplicate_event_ind != 1))
      UPDATE  FROM code_value cv
       SET cv.display = trim(substring(1,40,request->rel_list[x].event.display)), cv.display_key =
        trim(cnvtupper(cnvtalphanum(substring(1,40,request->rel_list[x].event.display)))), cv
        .description = trim(substring(1,60,request->rel_list[x].event.display)),
        cv.definition = trim(substring(1,100,request->rel_list[x].event.display)), cv.updt_dt_tm =
        cnvtdatetime(curdate,curtime3), cv.updt_id = reqinfo->updt_id,
        cv.updt_task = reqinfo->updt_task, cv.updt_applctx = reqinfo->updt_applctx, cv.updt_cnt = (cv
        .updt_cnt+ 1)
       WHERE (cv.code_value=request->rel_list[x].event.code_value)
       WITH nocounter
      ;end update
      UPDATE  FROM v500_event_code v
       SET v.event_cd_disp = trim(substring(1,40,request->rel_list[x].event.display)), v
        .event_cd_disp_key = trim(cnvtupper(cnvtalphanum(substring(1,40,request->rel_list[x].event.
            display)))), v.event_cd_descr = trim(substring(1,60,request->rel_list[x].event.display)),
        v.event_cd_definition = trim(substring(1,100,request->rel_list[x].event.display)), v
        .updt_dt_tm = cnvtdatetime(curdate,curtime3), v.updt_id = reqinfo->updt_id,
        v.updt_task = reqinfo->updt_task, v.updt_applctx = reqinfo->updt_applctx, v.updt_cnt = (v
        .updt_cnt+ 1)
       WHERE (v.event_cd=request->rel_list[x].event.code_value)
       WITH nocounter
      ;end update
     ENDIF
    ENDIF
    IF ((request->rel_list[x].dta_code_value > 0))
     SET reply->assays[x].code_value = request->rel_list[x].dta_code_value
    ELSE
     SET reply->assays[x].code_value = 14003_cd
    ENDIF
    SET order_activity_type_cd = 0.0
    SELECT INTO "NL"
     FROM orc_resource_list orl,
      order_catalog oc
     PLAN (oc
      WHERE (oc.catalog_cd=request->rel_list[x].oc_code_value))
      JOIN (orl
      WHERE orl.active_ind=1
       AND (orl.catalog_cd=request->rel_list[x].oc_code_value))
     HEAD REPORT
      stat = alterlist(temp_sr->sr_list,50), sr_count = 0, sr_tot_count = 0,
      order_activity_type_cd = oc.activity_type_cd
     DETAIL
      sr_count = (sr_count+ 1), sr_tot_count = (sr_tot_count+ 1)
      IF (sr_count > 50)
       stat = alterlist(temp_sr->sr_list,(sr_tot_count+ 50)), sr_count = 1
      ENDIF
      temp_sr->sr_list[sr_tot_count].service_resource_cd = orl.service_resource_cd
     FOOT REPORT
      stat = alterlist(temp_sr->sr_list,sr_tot_count)
     WITH nocounter
    ;end select
    IF (sr_tot_count > 0)
     FOR (s = 1 TO sr_tot_count)
       SET need_to_activate_ind = 0
       SET need_to_upd_result = 0
       IF (order_activity_type_cd IN (micro_cd, bb_cd, ap_cd, hla_cd, hlx_cd))
        SELECT INTO "NL:"
         FROM assay_processing_r apr
         WHERE (apr.service_resource_cd=temp_sr->sr_list[s].service_resource_cd)
          AND (apr.task_assay_cd=request->rel_list[x].dta_code_value)
         DETAIL
          IF (apr.active_ind=0)
           need_to_activate_ind = 1
          ENDIF
          IF ((apr.default_result_type_cd != request->rel_list[x].result_type_code_value))
           need_to_upd_result = 1
          ENDIF
         WITH nocounter
        ;end select
        IF (curqual > 0)
         IF (((need_to_activate_ind=1) OR (need_to_upd_result=1)) )
          UPDATE  FROM assay_processing_r apr
           SET apr.default_result_type_cd = request->rel_list[x].result_type_code_value, apr
            .active_ind = 1, apr.active_status_cd = active_code_value,
            apr.updt_dt_tm = cnvtdatetime(curdate,curtime3), apr.updt_id = reqinfo->updt_id, apr
            .updt_task = reqinfo->updt_task,
            apr.updt_applctx = reqinfo->updt_applctx
           WHERE (apr.service_resource_cd=temp_sr->sr_list[s].service_resource_cd)
            AND (apr.task_assay_cd=request->rel_list[x].dta_code_value)
           WITH nocounter
          ;end update
          IF (curqual=0)
           SET error_flag = "Y"
           SET error_msg = concat("Unable to activate and update service resource ",cnvtstring(
             temp_sr->sr_list[s].service_resource_cd)," assay ",cnvtstring(request->rel_list[x].
             dta_code_value)," on the assay_processing_r table.")
           GO TO exit_script
          ENDIF
         ENDIF
        ELSE
         INSERT  FROM assay_processing_r apr
          SET apr.service_resource_cd = temp_sr->sr_list[s].service_resource_cd, apr
           .default_result_type_cd = request->rel_list[x].result_type_code_value, apr
           .dnld_assay_alias = null,
           apr.downld_ind = 0, apr.active_ind = 1, apr.task_assay_cd = request->rel_list[x].
           dta_code_value,
           apr.display_sequence = 0, apr.updt_dt_tm = cnvtdatetime(curdate,curtime3), apr.updt_id =
           reqinfo->updt_id,
           apr.updt_task = reqinfo->updt_task, apr.updt_cnt = 1, apr.updt_applctx = reqinfo->
           updt_applctx,
           apr.active_status_cd = active_code_value, apr.active_status_prsnl_id = reqinfo->updt_id,
           apr.active_status_dt_tm = cnvtdatetime(curdate,curtime)
          WITH nocounter
         ;end insert
         IF (curqual=0)
          SET error_flag = "Y"
          SET error_msg = concat("Unable to insert service resource ",cnvtstring(temp_sr->sr_list[s].
            service_resource_cd)," assay ",cnvtstring(request->rel_list[x].dta_code_value),
           " on the assay_processing_r table.")
          GO TO exit_script
         ENDIF
        ENDIF
       ENDIF
       SET need_to_activate_ind = 0
       SELECT INTO "NL:"
        FROM assay_resource_translation art
        WHERE (art.service_resource_cd=temp_sr->sr_list[s].service_resource_cd)
         AND (art.task_assay_cd=request->rel_list[x].dta_code_value)
        DETAIL
         IF (art.active_ind=0)
          need_to_activate_ind = 1
         ENDIF
        WITH nocounter
       ;end select
       IF (curqual=0)
        INSERT  FROM assay_resource_translation art
         SET art.service_resource_cd = temp_sr->sr_list[s].service_resource_cd, art.active_ind = 1,
          art.process_sequence = null,
          art.task_assay_cd = request->rel_list[x].dta_code_value, art.updt_dt_tm = cnvtdatetime(
           curdate,curtime3), art.updt_id = reqinfo->updt_id,
          art.updt_task = reqinfo->updt_task, art.updt_cnt = 1, art.updt_applctx = reqinfo->
          updt_applctx,
          art.active_status_cd = active_code_value, art.active_status_prsnl_id = reqinfo->updt_id,
          art.active_status_dt_tm = cnvtdatetime(curdate,curtime)
         WITH nocounter
        ;end insert
       ELSEIF (need_to_activate_ind=1)
        UPDATE  FROM assay_resource_translation art
         SET art.active_ind = 1, art.active_status_cd = active_code_value, art.active_status_prsnl_id
           = reqinfo->updt_id,
          art.active_status_dt_tm = cnvtdatetime(curdate,curtime), art.updt_dt_tm = cnvtdatetime(
           curdate,curtime3), art.updt_id = reqinfo->updt_id,
          art.updt_task = reqinfo->updt_task, art.updt_cnt = (art.updt_cnt+ 1), art.updt_applctx =
          reqinfo->updt_applctx
         WHERE (art.service_resource_cd=temp_sr->sr_list[s].service_resource_cd)
          AND (art.task_assay_cd=request->rel_list[x].dta_code_value)
         WITH nocounter
        ;end update
       ENDIF
     ENDFOR
    ENDIF
   ELSEIF ((request->rel_list[x].action_flag=2))
    SET reply->assays[x].code_value = request->rel_list[x].dta_code_value
    UPDATE  FROM profile_task_r ptr
     SET ptr.sequence = request->rel_list[x].sequence, ptr.post_prompt_ind = request->rel_list[x].
      post_verify_ind, ptr.restrict_display_ind = request->rel_list[x].restrict_display_ind,
      ptr.pending_ind = request->rel_list[x].required_ind, ptr.item_type_flag = request->rel_list[x].
      prompt_test_ind, ptr.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      ptr.updt_id = reqinfo->updt_id, ptr.updt_task = reqinfo->updt_task, ptr.updt_cnt = (ptr
      .updt_cnt+ 1),
      ptr.updt_applctx = reqinfo->updt_applctx
     WHERE (ptr.task_assay_cd=request->rel_list[x].dta_code_value)
      AND (ptr.catalog_cd=request->rel_list[x].oc_code_value)
      AND ptr.active_ind=1
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to update ",cnvtstring(request->rel_list[x].oc_code_value),
      " on the profile_task_r table.")
     GO TO exit_script
    ENDIF
    SET 14003_cd = 0.0
    SET mnemonic = fillstring(50," ")
    SET description = fillstring(100," ")
    SET result_type_cd = 0.0
    SET activity_type_cd = 0.0
    SET 14003_cd = request->rel_list[x].dta_code_value
    IF ((request->rel_list[x].mnemonic > " "))
     SET mnemonic = request->rel_list[x].mnemonic
    ENDIF
    IF ((request->rel_list[x].description > " "))
     SET description = request->rel_list[x].description
    ENDIF
    IF ((request->rel_list[x].activity_type_code_value > 0))
     SET activity_type_cd = request->rel_list[x].activity_type_code_value
    ENDIF
    IF ((request->rel_list[x].result_type_code_value > 0))
     SET result_type_cd = request->rel_list[x].result_type_code_value
    ENDIF
    IF (((mnemonic > " ") OR (((description > " ") OR (((activity_type_cd > 0) OR (((result_type_cd
     > 0) OR (size(trim(request->rel_list[x].concept_cki)) > 0)) )) )) )) )
     UPDATE  FROM discrete_task_assay dta
      SET dta.mnemonic_key_cap =
       IF (mnemonic > " ") cnvtupper(mnemonic)
       ELSE dta.mnemonic_key_cap
       ENDIF
       , dta.activity_type_cd =
       IF (activity_type_cd > 0) activity_type_cd
       ELSE dta.activity_type_cd
       ENDIF
       , dta.default_result_type_cd =
       IF (result_type_cd > 0) result_type_cd
       ELSE dta.default_result_type_cd
       ENDIF
       ,
       dta.mnemonic =
       IF (mnemonic > " ") mnemonic
       ELSE dta.mnemonic
       ENDIF
       , dta.description =
       IF (description > " ") description
       ELSE dta.description
       ENDIF
       , dta.concept_cki =
       IF (size(trim(request->rel_list[x].concept_cki)) > 0) request->rel_list[x].concept_cki
       ELSE dta.concept_cki
       ENDIF
       ,
       dta.updt_dt_tm = cnvtdatetime(curdate,curtime3), dta.updt_id = reqinfo->updt_id, dta.updt_task
        = reqinfo->updt_task,
       dta.updt_cnt = (dta.updt_cnt+ 1), dta.updt_applctx = reqinfo->updt_applctx
      WHERE dta.task_assay_cd=14003_cd
      WITH nocounter
     ;end update
    ENDIF
    IF (((mnemonic > " ") OR (description > " ")) )
     UPDATE  FROM code_value cv
      SET cv.display =
       IF (mnemonic > " ") trim(substring(1,40,mnemonic))
       ELSE cv.display
       ENDIF
       , cv.display_key =
       IF (mnemonic > " ") trim(cnvtupper(cnvtalphanum(substring(1,40,mnemonic))))
       ELSE cv.display_key
       ENDIF
       , cv.description =
       IF (description > " ") trim(substring(1,60,description))
       ELSE cv.description
       ENDIF
       ,
       cv.definition =
       IF (description > " ") trim(substring(1,60,description))
       ELSE cv.definition
       ENDIF
       , cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_id = reqinfo->updt_id,
       cv.updt_task = reqinfo->updt_task, cv.updt_applctx = reqinfo->updt_applctx, cv.updt_cnt = (cv
       .updt_cnt+ 1)
      WHERE cv.code_value=14003_cd
      WITH nocounter
     ;end update
     UPDATE  FROM bill_item b
      SET b.ext_description =
       IF (description > " ") description
       ELSE b.ext_description
       ENDIF
       , b.ext_short_desc =
       IF (mnemonic > " ") substring(1,50,mnemonic)
       ELSE b.ext_short_desc
       ENDIF
       , b.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_cnt = (b.updt_cnt+ 1),
       b.updt_applctx = reqinfo->updt_applctx
      WHERE b.ext_child_contributor_cd=dta_contributor_cd
       AND b.ext_child_reference_id=14003_cd
       AND b.ext_child_entity_name="CODE_VALUE"
      WITH nocounter
     ;end update
    ENDIF
    SET bill_mnemonic = fillstring(50," ")
    SET bill_description = fillstring(100," ")
    SELECT INTO "NL:"
     FROM discrete_task_assay dta
     WHERE dta.task_assay_cd=14003_cd
     DETAIL
      bill_mnemonic = dta.mnemonic, bill_description = dta.description, activity_type_cd = dta
      .activity_type_cd
     WITH nocounter
    ;end select
    SET catalog_type_cd = 0.0
    SELECT INTO "NL"
     FROM code_value cv106,
      code_value cv6000
     PLAN (cv106
      WHERE cv106.code_value=activity_type_cd)
      JOIN (cv6000
      WHERE cv6000.active_ind=1
       AND cv6000.code_set=6000
       AND cnvtupper(cv6000.cdf_meaning)=cnvtupper(cv106.definition))
     DETAIL
      catalog_type_cd = cv6000.code_value
     WITH nocounter
    ;end select
    SET oc_activity_type_cd = 0.0
    SELECT INTO "NL:"
     FROM order_catalog oc
     WHERE (oc.catalog_cd=request->rel_list[x].oc_code_value)
     DETAIL
      oc_activity_type_cd = oc.activity_type_cd
     WITH nocounter
    ;end select
    SET upd_bill_item = 0
    SET bill_item_id = 0.0
    SELECT INTO "NL:"
     FROM bill_item b
     WHERE b.ext_parent_reference_id=catalog_type_cd
      AND b.ext_parent_contributor_cd=oc_contributor_cd
      AND b.ext_parent_entity_name="CODE_VALUE"
      AND b.ext_child_reference_id=14003_cd
      AND b.ext_child_contributor_cd=dta_contributor_cd
      AND b.ext_child_entity_name="CODE_VALUE"
     DETAIL
      IF (((b.active_ind=0) OR (((b.ext_description != bill_description) OR (((b.ext_short_desc !=
      bill_mnemonic) OR (oc_activity_type_cd != b.ext_owner_cd)) )) )) )
       upd_bill_item = 1
      ENDIF
      bill_item_id = b.bill_item_id
     WITH nocounter
    ;end select
    IF (curqual=0)
     INSERT  FROM bill_item b
      SET b.bill_item_id = seq(bill_item_seq,nextval), b.ext_parent_reference_id = catalog_type_cd, b
       .ext_parent_contributor_cd = oc_contributor_cd,
       b.ext_parent_entity_name = "CODE_VALUE", b.ext_child_reference_id = 14003_cd, b
       .ext_child_contributor_cd = dta_contributor_cd,
       b.ext_child_entity_name = "CODE_VALUE", b.ext_description = bill_description, b.ext_short_desc
        = bill_mnemonic,
       b.ext_owner_cd = oc_activity_type_cd, b.active_ind = 1, b.active_status_cd = active_code_value,
       b.active_status_dt_tm = cnvtdatetime(curdate,curtime3), b.active_status_prsnl_id = reqinfo->
       updt_id, b.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
       b.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), b.updt_dt_tm = cnvtdatetime(curdate,
        curtime3), b.updt_id = reqinfo->updt_id,
       b.updt_task = reqinfo->updt_task, b.updt_cnt = 0, b.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
    ELSEIF (upd_bill_item=1
     AND bill_item_id > 0)
     UPDATE  FROM bill_item b
      SET b.ext_description = bill_description, b.ext_short_desc = bill_mnemonic, b.ext_owner_cd =
       oc_activity_type_cd,
       b.active_ind = 1, b.active_status_cd = active_code_value, b.updt_dt_tm = cnvtdatetime(curdate,
        curtime3),
       b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_cnt = (b.updt_cnt+ 1),
       b.updt_applctx = reqinfo->updt_applctx
      WHERE b.bill_item_id=bill_item_id
     ;end update
    ENDIF
    SET upd_bill_item = 0
    SET bill_item_id = 0.0
    SELECT INTO "NL:"
     FROM bill_item b
     WHERE b.ext_parent_reference_id=0.0
      AND b.ext_parent_contributor_cd=0.0
      AND b.ext_parent_entity_name=null
      AND b.ext_child_reference_id=14003_cd
      AND b.ext_child_contributor_cd=dta_contributor_cd
      AND b.ext_child_entity_name="CODE_VALUE"
     DETAIL
      IF (((b.active_ind=0) OR (((b.ext_description != bill_description) OR (b.ext_short_desc !=
      bill_mnemonic)) )) )
       upd_bill_item = 1
      ENDIF
      bill_item_id = b.bill_item_id
     WITH nocounter
    ;end select
    IF (curqual=0)
     INSERT  FROM bill_item b
      SET b.bill_item_id = seq(bill_item_seq,nextval), b.ext_parent_reference_id = 0.0, b
       .ext_parent_contributor_cd = 0.0,
       b.ext_parent_entity_name = null, b.ext_child_reference_id = 14003_cd, b
       .ext_child_contributor_cd = dta_contributor_cd,
       b.ext_child_entity_name = "CODE_VALUE", b.ext_description = bill_description, b.ext_short_desc
        = bill_mnemonic,
       b.active_ind = 1, b.active_status_cd = active_code_value, b.active_status_dt_tm = cnvtdatetime
       (curdate,curtime3),
       b.active_status_prsnl_id = reqinfo->updt_id, b.beg_effective_dt_tm = cnvtdatetime(curdate,
        curtime3), b.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
       b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task =
       reqinfo->updt_task,
       b.updt_cnt = 0, b.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
    ELSEIF (upd_bill_item=1
     AND bill_item_id > 0)
     UPDATE  FROM bill_item b
      SET b.ext_description = bill_description, b.ext_short_desc = bill_mnemonic, b.active_ind = 1,
       b.active_status_cd = active_code_value, b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b
       .updt_id = reqinfo->updt_id,
       b.updt_task = reqinfo->updt_task, b.updt_cnt = (b.updt_cnt+ 1), b.updt_applctx = reqinfo->
       updt_applctx
      WHERE b.bill_item_id=bill_item_id
     ;end update
    ENDIF
    UPDATE  FROM bill_item b
     SET b.ext_description = bill_description, b.ext_short_desc = bill_mnemonic, b.ext_owner_cd =
      oc_activity_type_cd,
      b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task =
      reqinfo->updt_task,
      b.updt_cnt = (b.updt_cnt+ 1), b.updt_applctx = reqinfo->updt_applctx
     WHERE b.ext_parent_reference_id > 0
      AND b.ext_parent_contributor_cd=oc_contributor_cd
      AND b.ext_parent_entity_name="CODE_VALUE"
      AND b.ext_child_reference_id=14003_cd
      AND b.ext_child_contributor_cd=dta_contributor_cd
      AND b.ext_child_entity_name="CODE_VALUE"
      AND ((b.ext_description != bill_description) OR (((b.ext_short_desc != bill_mnemonic) OR (b
     .ext_owner_cd != oc_activity_type_cd)) ))
     WITH nocounter
    ;end update
    SET upd_bill_item = 0
    SET bill_item_id = 0.0
    SELECT INTO "NL:"
     FROM bill_item b
     WHERE (b.ext_parent_reference_id=request->rel_list[x].oc_code_value)
      AND b.ext_parent_contributor_cd=oc_contributor_cd
      AND b.ext_parent_entity_name="CODE_VALUE"
      AND b.ext_child_reference_id=14003_cd
      AND b.ext_child_contributor_cd=dta_contributor_cd
      AND b.ext_child_entity_name="CODE_VALUE"
     DETAIL
      IF (b.active_ind=0)
       upd_bill_item = 1
      ENDIF
      bill_item_id = b.bill_item_id
     WITH nocounter
    ;end select
    IF (curqual=0)
     INSERT  FROM bill_item b
      SET b.bill_item_id = seq(bill_item_seq,nextval), b.ext_parent_reference_id = request->rel_list[
       x].oc_code_value, b.ext_parent_contributor_cd = oc_contributor_cd,
       b.ext_parent_entity_name = "CODE_VALUE", b.ext_child_reference_id = 14003_cd, b
       .ext_child_contributor_cd = dta_contributor_cd,
       b.ext_child_entity_name = "CODE_VALUE", b.ext_description = bill_description, b.ext_short_desc
        = bill_mnemonic,
       b.ext_owner_cd = oc_activity_type_cd, b.active_ind = 1, b.active_status_cd = active_code_value,
       b.active_status_dt_tm = cnvtdatetime(curdate,curtime3), b.active_status_prsnl_id = reqinfo->
       updt_id, b.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
       b.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), b.updt_dt_tm = cnvtdatetime(curdate,
        curtime3), b.updt_id = reqinfo->updt_id,
       b.updt_task = reqinfo->updt_task, b.updt_cnt = 0, b.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
    ELSEIF (upd_bill_item=1
     AND bill_item_id > 0)
     UPDATE  FROM bill_item b
      SET b.ext_description = bill_description, b.ext_short_desc = bill_mnemonic, b.ext_owner_cd =
       oc_activity_type_cd,
       b.active_ind = 1, b.active_status_cd = active_code_value, b.updt_dt_tm = cnvtdatetime(curdate,
        curtime3),
       b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_cnt = (b.updt_cnt+ 1),
       b.updt_applctx = reqinfo->updt_applctx
      WHERE b.bill_item_id=bill_item_id
      WITH nocounter
     ;end update
    ENDIF
    IF ((request->rel_list[x].event.display > " "))
     SET update_cv = 0
     SELECT INTO "nl:"
      FROM code_value cv
      PLAN (cv
       WHERE cv.code_set=72
        AND cnvtupper(cv.display)=cnvtupper(request->rel_list[x].event.display))
      DETAIL
       update_cv = 1
       IF ((cv.code_value != request->rel_list[x].event.code_value))
        reply->assays[x].duplicate_event_ind = 1
       ENDIF
       IF ((cv.code_value=request->rel_list[x].event.code_value)
        AND (cv.display != request->rel_list[x].event.display))
        update_cv = 0
       ENDIF
      WITH nocounter
     ;end select
     IF (update_cv=0)
      UPDATE  FROM code_value cv
       SET cv.display = trim(substring(1,40,request->rel_list[x].event.display)), cv.display_key =
        trim(cnvtupper(cnvtalphanum(substring(1,40,request->rel_list[x].event.display)))), cv
        .description = trim(substring(1,60,request->rel_list[x].event.display)),
        cv.definition = trim(substring(1,100,request->rel_list[x].event.display)), cv.updt_dt_tm =
        cnvtdatetime(curdate,curtime3), cv.updt_id = reqinfo->updt_id,
        cv.updt_task = reqinfo->updt_task, cv.updt_applctx = reqinfo->updt_applctx, cv.updt_cnt = (cv
        .updt_cnt+ 1)
       WHERE (cv.code_value=request->rel_list[x].event.code_value)
       WITH nocounter
      ;end update
      UPDATE  FROM v500_event_code v
       SET v.event_cd_disp = trim(substring(1,40,request->rel_list[x].event.display)), v
        .event_cd_disp_key = trim(cnvtupper(cnvtalphanum(substring(1,40,request->rel_list[x].event.
            display)))), v.event_cd_descr = trim(substring(1,60,request->rel_list[x].event.display)),
        v.event_cd_definition = trim(substring(1,100,request->rel_list[x].event.display)), v
        .updt_dt_tm = cnvtdatetime(curdate,curtime3), v.updt_id = reqinfo->updt_id,
        v.updt_task = reqinfo->updt_task, v.updt_applctx = reqinfo->updt_applctx, v.updt_cnt = (v
        .updt_cnt+ 1)
       WHERE (v.event_cd=request->rel_list[x].event.code_value)
       WITH nocounter
      ;end update
     ENDIF
    ENDIF
    SET order_activity_type_cd = 0.0
    SELECT INTO "NL"
     FROM orc_resource_list orl,
      order_catalog oc
     PLAN (oc
      WHERE (oc.catalog_cd=request->rel_list[x].oc_code_value))
      JOIN (orl
      WHERE orl.active_ind=1
       AND (orl.catalog_cd=request->rel_list[x].oc_code_value))
     HEAD REPORT
      stat = alterlist(temp_sr->sr_list,50), sr_count = 0, sr_tot_count = 0,
      order_activity_type_cd = oc.activity_type_cd
     DETAIL
      sr_count = (sr_count+ 1), sr_tot_count = (sr_tot_count+ 1)
      IF (sr_count > 50)
       stat = alterlist(temp_sr->sr_list,(sr_tot_count+ 50)), sr_count = 1
      ENDIF
      temp_sr->sr_list[sr_tot_count].service_resource_cd = orl.service_resource_cd
     FOOT REPORT
      stat = alterlist(temp_sr->sr_list,sr_tot_count)
     WITH nocounter
    ;end select
    IF (sr_tot_count > 0)
     FOR (s = 1 TO sr_tot_count)
       SET need_to_activate_ind = 0
       SET need_to_upd_result = 0
       IF (order_activity_type_cd IN (micro_cd, bb_cd, ap_cd, hla_cd, hlx_cd))
        SELECT INTO "NL:"
         FROM assay_processing_r apr
         WHERE (apr.service_resource_cd=temp_sr->sr_list[s].service_resource_cd)
          AND (apr.task_assay_cd=request->rel_list[x].dta_code_value)
         DETAIL
          IF (apr.active_ind=0)
           need_to_activate_ind = 1
          ENDIF
          IF ((apr.default_result_type_cd != request->rel_list[x].result_type_code_value)
           AND (request->rel_list[x].result_type_code_value > 0))
           need_to_upd_result = 1
          ENDIF
         WITH nocounter
        ;end select
        IF (curqual > 0)
         IF (((need_to_activate_ind=1) OR (need_to_upd_result=1)) )
          UPDATE  FROM assay_processing_r apr
           SET apr.default_result_type_cd = request->rel_list[x].result_type_code_value, apr
            .active_ind = 1, apr.active_status_cd = active_code_value,
            apr.updt_dt_tm = cnvtdatetime(curdate,curtime3), apr.updt_id = reqinfo->updt_id, apr
            .updt_task = reqinfo->updt_task,
            apr.updt_applctx = reqinfo->updt_applctx
           WHERE (apr.service_resource_cd=temp_sr->sr_list[s].service_resource_cd)
            AND (apr.task_assay_cd=request->rel_list[x].dta_code_value)
           WITH nocounter
          ;end update
          IF (curqual=0)
           SET error_flag = "Y"
           SET error_msg = concat("Unable to activate and update service resource ",cnvtstring(
             temp_sr->sr_list[s].service_resource_cd)," assay ",cnvtstring(request->rel_list[x].
             dta_code_value)," on the assay_processing_r table.")
           GO TO exit_script
          ENDIF
         ENDIF
        ELSE
         INSERT  FROM assay_processing_r apr
          SET apr.service_resource_cd = temp_sr->sr_list[s].service_resource_cd, apr
           .default_result_type_cd = request->rel_list[x].result_type_code_value, apr
           .dnld_assay_alias = null,
           apr.downld_ind = 0, apr.active_ind = 1, apr.task_assay_cd = request->rel_list[x].
           dta_code_value,
           apr.display_sequence = 0, apr.updt_dt_tm = cnvtdatetime(curdate,curtime3), apr.updt_id =
           reqinfo->updt_id,
           apr.updt_task = reqinfo->updt_task, apr.updt_cnt = 1, apr.updt_applctx = reqinfo->
           updt_applctx,
           apr.active_status_cd = active_code_value, apr.active_status_prsnl_id = reqinfo->updt_id,
           apr.active_status_dt_tm = cnvtdatetime(curdate,curtime)
          WITH nocounter
         ;end insert
         IF (curqual=0)
          SET error_flag = "Y"
          SET error_msg = concat("Unable to insert service resource ",cnvtstring(temp_sr->sr_list[s].
            service_resource_cd)," assay ",cnvtstring(request->rel_list[x].dta_code_value),
           " on the assay_processing_r table.")
          GO TO exit_script
         ENDIF
        ENDIF
       ENDIF
       SET need_to_activate_ind = 0
       SELECT INTO "NL:"
        FROM assay_resource_translation art
        WHERE (art.service_resource_cd=temp_sr->sr_list[s].service_resource_cd)
         AND (art.task_assay_cd=request->rel_list[x].dta_code_value)
        DETAIL
         IF (art.active_ind=0)
          need_to_activate_ind = 1
         ENDIF
        WITH nocounter
       ;end select
       IF (curqual=0)
        INSERT  FROM assay_resource_translation art
         SET art.service_resource_cd = temp_sr->sr_list[s].service_resource_cd, art.active_ind = 1,
          art.process_sequence = null,
          art.task_assay_cd = request->rel_list[x].dta_code_value, art.updt_dt_tm = cnvtdatetime(
           curdate,curtime3), art.updt_id = reqinfo->updt_id,
          art.updt_task = reqinfo->updt_task, art.updt_cnt = 1, art.updt_applctx = reqinfo->
          updt_applctx,
          art.active_status_cd = active_code_value, art.active_status_prsnl_id = reqinfo->updt_id,
          art.active_status_dt_tm = cnvtdatetime(curdate,curtime)
         WITH nocounter
        ;end insert
       ELSEIF (need_to_activate_ind=1)
        UPDATE  FROM assay_resource_translation art
         SET art.active_ind = 1, art.active_status_cd = active_code_value, art.active_status_prsnl_id
           = reqinfo->updt_id,
          art.active_status_dt_tm = cnvtdatetime(curdate,curtime), art.updt_dt_tm = cnvtdatetime(
           curdate,curtime3), art.updt_id = reqinfo->updt_id,
          art.updt_task = reqinfo->updt_task, art.updt_cnt = (art.updt_cnt+ 1), art.updt_applctx =
          reqinfo->updt_applctx
         WHERE (art.service_resource_cd=temp_sr->sr_list[s].service_resource_cd)
          AND (art.task_assay_cd=request->rel_list[x].dta_code_value)
         WITH nocounter
        ;end update
       ENDIF
     ENDFOR
    ENDIF
   ELSEIF ((request->rel_list[x].action_flag=3))
    SET reply->assays[x].code_value = request->rel_list[x].dta_code_value
    UPDATE  FROM profile_task_r ptr
     SET ptr.active_ind = 0, ptr.pending_ind = 0, ptr.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      ptr.updt_id = reqinfo->updt_id, ptr.updt_task = reqinfo->updt_task, ptr.updt_cnt = (ptr
      .updt_cnt+ 1),
      ptr.updt_applctx = reqinfo->updt_applctx
     WHERE (ptr.task_assay_cd=request->rel_list[x].dta_code_value)
      AND (ptr.catalog_cd=request->rel_list[x].oc_code_value)
      AND ptr.active_ind=1
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to inactivate ",cnvtstring(request->rel_list[x].oc_code_value),
      " on the profile_task_r table.")
     GO TO exit_script
    ENDIF
    UPDATE  FROM bill_item b
     SET b.active_ind = 0, b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->
      updt_id,
      b.updt_task = reqinfo->updt_task, b.updt_cnt = (b.updt_cnt+ 1), b.updt_applctx = reqinfo->
      updt_applctx
     WHERE (b.ext_parent_reference_id=request->rel_list[x].oc_code_value)
      AND b.ext_parent_contributor_cd=oc_contributor_cd
      AND b.ext_parent_entity_name="CODE_VALUE"
      AND (b.ext_child_reference_id=request->rel_list[x].dta_code_value)
      AND b.ext_child_contributor_cd=dta_contributor_cd
      AND b.ext_child_entity_name="CODE_VALUE"
    ;end update
    IF ((request->rel_list[x].inactivate_event=1))
     SET event_code = " "
     SET event_cd = 0.0
     SELECT INTO "nl:"
      FROM br_dta_work b
      PLAN (b
       WHERE (b.match_dta_cd=request->rel_list[x].dta_code_value))
      DETAIL
       event_code = b.org_event_code
      WITH nocounter
     ;end select
     UPDATE  FROM br_dta_work b
      SET b.match_dta_cd = 0, b.updt_id = reqinfo->updt_id, b.updt_dt_tm = cnvtdatetime(curdate,
        curtime),
       b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = (b
       .updt_cnt+ 1),
       b.org_event_code = " "
      PLAN (b
       WHERE (b.match_dta_cd=request->rel_list[x].dta_code_value))
      WITH nocounter
     ;end update
     SELECT INTO "nl:"
      FROM code_value_event_r r
      PLAN (r
       WHERE (r.parent_cd=request->rel_list[x].dta_code_value))
      DETAIL
       event_cd = r.event_cd
      WITH nocounter
     ;end select
     IF (event_cd > 0)
      IF (event_code > " ")
       SELECT INTO "nl:"
        FROM code_value cv
        PLAN (cv
         WHERE cv.code_set=72
          AND cnvtupper(cv.display)=cnvtupper(event_code))
        DETAIL
         IF (cv.code_value != event_cd)
          reply->assays[x].duplicate_event_ind = 1
         ENDIF
        WITH nocounter
       ;end select
       IF ((reply->assays[x].duplicate_event_ind=0))
        UPDATE  FROM code_value cv
         SET cv.display = event_code, cv.display_key = cnvtupper(cnvtalphanum(event_code)), cv
          .description = event_code,
          cv.definition = event_code, cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_id =
          reqinfo->updt_id,
          cv.updt_task = reqinfo->updt_task, cv.updt_applctx = reqinfo->updt_applctx, cv.updt_cnt = (
          cv.updt_cnt+ 1)
         WHERE cv.code_value=event_cd
         WITH nocounter
        ;end update
        UPDATE  FROM v500_event_code v
         SET v.event_cd_disp = event_code, v.event_cd_disp_key = cnvtupper(cnvtalphanum(event_code)),
          v.event_cd_descr = event_code,
          v.event_cd_definition = event_code, v.updt_dt_tm = cnvtdatetime(curdate,curtime3), v
          .updt_id = reqinfo->updt_id,
          v.updt_task = reqinfo->updt_task, v.updt_applctx = reqinfo->updt_applctx, v.updt_cnt = (v
          .updt_cnt+ 1)
         WHERE v.event_cd=event_cd
         WITH nocounter
        ;end update
       ENDIF
      ENDIF
      DELETE  FROM code_value_event_r r
       WHERE r.event_cd=event_cd
        AND (r.parent_cd=request->rel_list[x].dta_code_value)
       WITH nocounter
      ;end delete
     ENDIF
    ENDIF
    SET first_only_ind = 1
    SELECT INTO "NL:"
     FROM order_catalog oc,
      profile_task_r ptr
     PLAN (ptr
      WHERE (ptr.task_assay_cd=request->rel_list[x].dta_code_value)
       AND ptr.active_ind=1)
      JOIN (oc
      WHERE oc.active_ind=1
       AND oc.catalog_cd=ptr.catalog_cd)
     HEAD REPORT
      stat = alterlist(temp_oc->oc_list,50), oc_count = 0, oc_tot_count = 0
     DETAIL
      IF (oc.resource_route_lvl != 1)
       first_only_ind = 0
      ELSEIF ((ptr.catalog_cd != request->rel_list[x].oc_code_value))
       oc_count = (oc_count+ 1), oc_tot_count = (oc_tot_count+ 1)
       IF (oc_count > 50)
        stat = alterlist(temp_oc->oc_list,(oc_tot_count+ 50)), oc_count = 1
       ENDIF
       temp_oc->oc_list[oc_tot_count].catalog_cd = oc.catalog_cd
      ENDIF
     FOOT REPORT
      stat = alterlist(temp_oc->oc_list,oc_tot_count)
     WITH nocounter
    ;end select
    IF (first_only_ind=1)
     SELECT INTO "NL"
      FROM orc_resource_list orl
      WHERE orl.active_ind=1
       AND (orl.catalog_cd=request->rel_list[x].oc_code_value)
      HEAD REPORT
       stat = alterlist(temp_sr->sr_list,50), sr_count = 0, sr_tot_count = 0
      DETAIL
       sr_count = (sr_count+ 1), sr_tot_count = (sr_tot_count+ 1)
       IF (sr_count > 50)
        stat = alterlist(temp_sr->sr_list,(sr_tot_count+ 50)), sr_count = 1
       ENDIF
       temp_sr->sr_list[sr_tot_count].service_resource_cd = orl.service_resource_cd, temp_sr->
       sr_list[sr_tot_count].ok_to_inactivate = 1
      FOOT REPORT
       stat = alterlist(temp_sr->sr_list,sr_tot_count)
      WITH nocounter
     ;end select
     IF (sr_tot_count > 0
      AND oc_tot_count > 0)
      SELECT INTO "NL:"
       FROM (dummyt d  WITH seq = oc_tot_count),
        orc_resource_list orl
       PLAN (d)
        JOIN (orl
        WHERE orl.active_ind=1
         AND (orl.catalog_cd=temp_oc->oc_list[d.seq].catalog_cd))
       ORDER BY orl.service_resource_cd
       HEAD orl.service_resource_cd
        FOR (i = 1 TO sr_tot_count)
          IF ((orl.service_resource_cd=temp_sr->sr_list[i].service_resource_cd))
           temp_sr->sr_list[i].ok_to_inactivate = 0, i = sr_tot_count
          ENDIF
        ENDFOR
       WITH nocounter
      ;end select
     ENDIF
     IF (sr_tot_count > 0)
      UPDATE  FROM assay_processing_r apr,
        (dummyt d  WITH seq = sr_tot_count)
       SET apr.active_ind = 0, apr.active_status_cd = inactive_code_value, apr.active_status_prsnl_id
         = reqinfo->updt_id,
        apr.active_status_dt_tm = cnvtdatetime(curdate,curtime)
       PLAN (d
        WHERE (temp_sr->sr_list[d.seq].ok_to_inactivate=1))
        JOIN (apr
        WHERE (apr.service_resource_cd=temp_sr->sr_list[d.seq].service_resource_cd)
         AND apr.active_ind=1
         AND (apr.task_assay_cd=request->rel_list[x].dta_code_value))
       WITH nocounter
      ;end update
      UPDATE  FROM assay_resource_translation art,
        (dummyt d  WITH seq = sr_tot_count)
       SET art.active_ind = 0, art.active_status_cd = inactive_code_value, art.active_status_prsnl_id
         = reqinfo->updt_id,
        art.active_status_dt_tm = cnvtdatetime(curdate,curtime)
       PLAN (d
        WHERE (temp_sr->sr_list[d.seq].ok_to_inactivate=1))
        JOIN (art
        WHERE (art.service_resource_cd=temp_sr->sr_list[d.seq].service_resource_cd)
         AND art.active_ind=1
         AND (art.task_assay_cd=request->rel_list[x].dta_code_value))
       WITH nocounter
      ;end update
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
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_ENS_REL_OC_DTA","  >> ERROR MSG: ",error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
