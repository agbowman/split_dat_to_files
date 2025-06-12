CREATE PROGRAM bed_ens_assay:dba
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
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 assay_list[*]
      2 code_value = f8
    1 error_msg = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD arhold(
   1 arlist[*]
     2 hold_nomenclature_id = f8
     2 hold_sequence = i4
     2 hold_use_units_ind = i2
     2 hold_result_process_cd = f8
     2 hold_default_ind = i2
     2 hold_description = vc
     2 hold_active_ind = i2
     2 hold_active_status_cd = f8
     2 hold_active_status_dt_tm = dq8
     2 hold_active_status_prsnl_id = f8
     2 hold_beg_effective_dt_tm = dq8
     2 hold_end_effective_dt_tm = dq8
     2 hold_result_value = f8
     2 hold_reference_ind = i2
     2 hold_multi_alpha_sort_order = i4
     2 hold_truth_state_cd = f8
 )
 RECORD adhold(
   1 adlist[*]
     2 hold_advanced_delta_id = f8
     2 hold_delta_ind = i2
     2 hold_delta_low = f8
     2 hold_delta_high = f8
     2 hold_delta_check_type_cd = f8
     2 hold_delta_minutes = i4
     2 hold_delta_value = f8
     2 hold_active_ind = i2
     2 hold_active_status_cd = f8
     2 hold_active_status_dt_tm = dq8
     2 hold_active_status_prsnl_id = f8
     2 hold_beg_effective_dt_tm = dq8
     2 hold_end_effective_dt_tm = dq8
 )
 RECORD rrnthold(
   1 rrntlist[*]
     2 trigger_seq_nbr = i4
     2 trigger_name = vc
 )
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 DECLARE versioning_needed_ind = i2 WITH protect
 DECLARE error_flag = vc WITH protect, noconstant("N")
 SET versioning_needed_ind = 0
 DECLARE hold_code_set = i4
 DECLARE hold_alpha_response_ind = i2
 DECLARE hold_gestational_ind = i2
 DECLARE hold_species_cd = f8
 DECLARE hold_sensitive_low = f8
 DECLARE hold_sensitive_high = f8
 DECLARE hold_sensitive_ind = i2
 DECLARE hold_def_result_ind = i2
 DECLARE hold_delta_minutes = i4
 DECLARE hold_delta_value = f8
 DECLARE hold_delta_check_type_cd = f8
 DECLARE hold_mins_back = i4
 DECLARE hold_delta_chk_flag = i2
 DECLARE hold_encntr_type_cd = f8
 DECLARE sdtaconceptcki = vc WITH protect, noconstant("")
 DECLARE assay_cnt = i4 WITH protect, noconstant(0)
 DECLARE assay_code_value = f8 WITH protect, noconstant(0)
 DECLARE newtruthstatecd = f8 WITH protect, noconstant(0)
 DECLARE dlist_count = i4 WITH protect
 DECLARE tot_dlist = i4 WITH protect
 DECLARE rlist_count = i4 WITH protect
 DECLARE tot_rlist = i4 WITH protect
 DECLARE alist_count = i4 WITH protect
 DECLARE tot_alist = i4 WITH protect
 DECLARE rulelist_count = i4 WITH protect
 DECLARE tot_rulelist = i4 WITH protect
 DECLARE elist_count = i4 WITH protect
 DECLARE tot_elist = i4 WITH protect
 DECLARE found_add = i4 WITH protect
 DECLARE found_update = i4 WITH protect
 DECLARE found_delete = i4 WITH protect
 DECLARE found_no_action = i4 WITH protect
 DECLARE active_code_value = f8 WITH protect
 DECLARE inactive_code_value = f8 WITH protect
 DECLARE delta_code_value = f8 WITH protect
 DECLARE auth_code_value = f8 WITH protect
 DECLARE catalog_type_cd = f8 WITH protect
 DECLARE bill_item_id = f8 WITH protect
 DECLARE oc_contributor_cd = f8 WITH protect
 DECLARE dta_contributor_cd = f8 WITH protect
 DECLARE shared_domain_ind = i2 WITH protect
 DECLARE activity_type_cdf = vc WITH protect
 DECLARE new_cd_value = f8 WITH protect
 DECLARE rrf_id = f8 WITH protect
 DECLARE fndtbl = i4 WITH protect
 DECLARE mins_back = i4 WITH protect
 DECLARE arcnt = i4 WITH protect
 DECLARE rrntcnt = i4 WITH protect
 DECLARE first_eq = i4 WITH protect
 DECLARE related_entity_id = f8 WITH protect
 DECLARE fnd = i2 WITH protect
 DECLARE upd_bill_item = i2 WITH protect
 SET assay_cnt = size(request->assay_list,5)
 SET stat = alterlist(reply->assay_list,assay_cnt)
 SET assay_code_value = 0.0
 SET dlist_count = 0
 SET tot_dlist = 0
 SET rlist_count = 0
 SET tot_rlist = 0
 SET alist_count = 0
 SET tot_alist = 0
 SET rulelist_count = 0
 SET tot_rulelist = 0
 SET elist_count = 0
 SET tot_elist = 0
 SET found_add = 0
 SET found_update = 0
 SET found_delete = 0
 SET found_no_action = 0
 SET active_code_value = 0.0
 SET inactive_code_value = 0.0
 SET delta_code_value = 0.0
 SET auth_code_value = 0.0
 SET auth_code_value = uar_get_code_by("MEANING",8,"AUTH")
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
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=15189
   AND cv.cdf_meaning="DELTA"
   AND cv.active_ind=1
  DETAIL
   delta_code_value = cv.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET error_flag = "Y"
  SET error_msg = concat(
   "Unable to retrieve the Delta Related Procedure code value from codeset 15189.")
  GO TO exit_script
 ENDIF
 SET catalog_type_cd = 0.0
 SET bill_item_id = 0.0
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
 SET shared_domain_ind = 0
 RANGE OF c IS code_value_set
 SET fnd = validate(c.br_client_id)
 FREE RANGE c
 IF (fnd=1)
  SET shared_domain_ind = 1
 ELSE
  SET shared_domain_ind = 0
 ENDIF
 CALL echo(build("shared domain ind:",shared_domain_ind))
 FOR (x = 1 TO assay_cnt)
   SET sdtaconceptcki = validate(request->assay_list[x].general_info.concept_cki,"")
   SET versioning_needed_ind = 0
   IF ((request->assay_list[x].code_value > 0))
    SET assay_code_value = request->assay_list[x].code_value
   ELSE
    SET assay_code_value = 0.0
   ENDIF
   SET catalog_type_cd = 0.0
   SET activity_type_cdf = fillstring(12," ")
   SELECT INTO "NL"
    FROM code_value cv106,
     code_value cv6000
    PLAN (cv106
     WHERE (cv106.code_value=request->assay_list[x].general_info.activity_type_code_value))
     JOIN (cv6000
     WHERE cv6000.active_ind=1
      AND cv6000.code_set=6000
      AND cnvtupper(cv6000.cdf_meaning)=cnvtupper(cv106.definition))
    DETAIL
     catalog_type_cd = cv6000.code_value, activity_type_cdf = cv106.cdf_meaning
    WITH nocounter
   ;end select
   DECLARE sstring = vc
   DECLARE need_activate = i2
   IF ((request->assay_list[x].action_flag=1))
    SET sstring = replace(request->assay_list[x].display,"*","\*",0)
    SET need_activate = 0
    SELECT INTO "NL:"
     FROM discrete_task_assay dta
     PLAN (dta
      WHERE ((dta.mnemonic_key_cap=cnvtupper(sstring)
       AND activity_type_cdf != "BB") OR (dta.mnemonic=sstring
       AND activity_type_cdf="BB")) )
     DETAIL
      reply->assay_list[x].code_value = dta.task_assay_cd, assay_code_value = dta.task_assay_cd
      IF (dta.active_ind=0)
       need_activate = 1
      ENDIF
      IF ((request->assay_list[x].general_info.activity_type_code_value != dta.activity_type_cd))
       reply->status_data.status = "F", reply->assay_list[x].code_value = 0.0, error_flag = "Y",
       reply->error_msg = concat(trim(request->assay_list[x].display),
        " already exist in the database but with another ",
        "activity type.  The display must be modified in order to add to the database.")
      ENDIF
     WITH nocounter
    ;end select
    IF (error_flag="Y")
     GO TO exit_script
    ENDIF
    IF (curqual=0)
     SET new_cd_value = 0.0
     SELECT INTO "nl:"
      number = seq(reference_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       new_cd_value = cnvtreal(number)
      WITH format, counter
     ;end select
     INSERT  FROM code_value cv
      SET cv.active_dt_tm = cnvtdatetime(curdate,curtime3), cv.active_ind = 1, cv
       .active_status_prsnl_id = reqinfo->updt_id,
       cv.active_type_cd = active_code_value, cv.begin_effective_dt_tm = cnvtdatetime(curdate,
        curtime3), cv.cdf_meaning = null,
       cv.code_set = 14003, cv.code_value = new_cd_value, cv.collation_seq = 0,
       cv.concept_cki = sdtaconceptcki, cv.data_status_cd = auth_code_value, cv.data_status_dt_tm =
       cnvtdatetime(curdate,curtime3),
       cv.data_status_prsnl_id = reqinfo->updt_id, cv.definition = substring(1,60,request->
        assay_list[x].description), cv.description = substring(1,60,request->assay_list[x].
        description),
       cv.display = substring(1,40,request->assay_list[x].display), cv.display_key = trim(cnvtupper(
         cnvtalphanum(substring(1,40,request->assay_list[x].display)))), cv.end_effective_dt_tm =
       cnvtdatetime("31-DEC-2100"),
       cv.inactive_dt_tm = null, cv.updt_applctx = reqinfo->updt_applctx, cv.updt_cnt = 0,
       cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_id = reqinfo->updt_id, cv.updt_task =
       reqinfo->updt_task
      WITH nocounter
     ;end insert
     IF (curqual != 0)
      SET reply->assay_list[x].code_value = new_cd_value
      SET assay_code_value = new_cd_value
      INSERT  FROM discrete_task_assay dta
       SET dta.active_ind = 1, dta.active_status_cd = active_code_value, dta.active_status_dt_tm =
        cnvtdatetime(curdate,curtime3),
        dta.active_status_prsnl_id = reqinfo->updt_id, dta.task_assay_cd = assay_code_value, dta
        .strt_assay_id = 0,
        dta.description = request->assay_list[x].description, dta.mnemonic = request->assay_list[x].
        display, dta.mnemonic_key_cap = cnvtupper(request->assay_list[x].display),
        dta.activity_type_cd = request->assay_list[x].general_info.activity_type_code_value, dta
        .default_result_type_cd = request->assay_list[x].general_info.result_type_code_value, dta
        .bb_result_processing_cd = request->assay_list[x].general_info.res_proc_type_code_value,
        dta.concept_cki = sdtaconceptcki, dta.rad_section_type_cd = request->assay_list[x].
        general_info.rad_section_type_code_value, dta.io_flag = request->assay_list[x].general_info.
        io_flag,
        dta.single_select_ind = request->assay_list[x].general_info.single_select_ind, dta
        .default_type_flag = request->assay_list[x].general_info.default_type_flag, dta
        .sci_notation_ind = request->assay_list[x].general_info.sci_notation_ind,
        dta.event_cd = 0, dta.signature_line_ind = 0, dta.history_activity_type_cd = 0,
        dta.hla_loci_cd = 0, dta.code_set = 0, dta.beg_effective_dt_tm = cnvtdatetime(curdate,
         curtime3),
        dta.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), dta.updt_dt_tm = cnvtdatetime(curdate,
         curtime3), dta.updt_id = reqinfo->updt_id,
        dta.updt_task = reqinfo->updt_task, dta.updt_cnt = 0, dta.updt_applctx = reqinfo->
        updt_applctx
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET error_flag = "Y"
       SET error_msg = concat("Unable to insert ",trim(request->assay_list[x].display),
        " into discrete_task_assay table.")
       GO TO exit_script
      ENDIF
      INSERT  FROM bill_item b
       SET b.bill_item_id = seq(bill_item_seq,nextval), b.ext_parent_reference_id = catalog_type_cd,
        b.ext_parent_contributor_cd = oc_contributor_cd,
        b.ext_parent_entity_name = "CODE_VALUE", b.ext_child_reference_id = assay_code_value, b
        .ext_child_contributor_cd = dta_contributor_cd,
        b.ext_child_entity_name = "CODE_VALUE", b.ext_description = request->assay_list[x].
        description, b.ext_owner_cd = request->assay_list[x].general_info.activity_type_code_value,
        b.ext_short_desc = substring(1,50,request->assay_list[x].display), b.active_ind = 1, b
        .active_status_cd = active_code_value,
        b.active_status_dt_tm = cnvtdatetime(curdate,curtime3), b.active_status_prsnl_id = reqinfo->
        updt_id, b.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
        b.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), b.updt_dt_tm = cnvtdatetime(curdate,
         curtime3), b.updt_id = reqinfo->updt_id,
        b.updt_task = reqinfo->updt_task, b.updt_cnt = 0, b.updt_applctx = reqinfo->updt_applctx
       WITH nocounter
      ;end insert
      INSERT  FROM bill_item b
       SET b.bill_item_id = seq(bill_item_seq,nextval), b.ext_child_reference_id = assay_code_value,
        b.ext_child_contributor_cd = dta_contributor_cd,
        b.ext_child_entity_name = "CODE_VALUE", b.ext_description = request->assay_list[x].
        description, b.ext_owner_cd = request->assay_list[x].general_info.activity_type_code_value,
        b.ext_short_desc = substring(1,50,request->assay_list[x].display), b.active_ind = 1, b
        .active_status_cd = active_code_value,
        b.active_status_dt_tm = cnvtdatetime(curdate,curtime3), b.active_status_prsnl_id = reqinfo->
        updt_id, b.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
        b.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), b.updt_dt_tm = cnvtdatetime(curdate,
         curtime3), b.updt_id = reqinfo->updt_id,
        b.updt_task = reqinfo->updt_task, b.updt_cnt = 0, b.updt_applctx = reqinfo->updt_applctx
       WITH nocounter
      ;end insert
     ELSE
      SET error_flag = "Y"
      SET error_msg = concat("Unable to insert ",trim(request->assay_list[x].display),
       " into codeset 14003.")
      GO TO exit_script
     ENDIF
     IF ((((request->assay_list[x].general_info.delta_check_ind=1)) OR ((request->assay_list[x].
     general_info.inter_data_check_ind=1))) )
      INSERT  FROM br_assay ba
       SET ba.task_assay_cd = assay_code_value, ba.delta_checking_ind = request->assay_list[x].
        general_info.delta_check_ind, ba.interpretive_ind = request->assay_list[x].general_info.
        inter_data_check_ind
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET error_flag = "Y"
       SET error_msg = concat("Unable to insert ",trim(request->assay_list[x].display),
        " into br_assay table.")
       GO TO exit_script
      ENDIF
     ENDIF
    ELSEIF (need_activate=1)
     SET versioning_needed_ind = 1
     UPDATE  FROM code_value cv
      SET cv.definition = substring(1,60,request->assay_list[x].description), cv.description =
       substring(1,60,request->assay_list[x].description), cv.display = substring(1,40,request->
        assay_list[x].display),
       cv.display_key = trim(cnvtupper(cnvtalphanum(substring(1,40,request->assay_list[x].display)))),
       cv.active_dt_tm = cnvtdatetime(curdate,curtime3), cv.active_ind = 1,
       cv.active_status_prsnl_id = reqinfo->updt_id, cv.active_type_cd = active_code_value, cv
       .updt_applctx = reqinfo->updt_applctx,
       cv.updt_cnt = (cv.updt_cnt+ 1), cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_id =
       reqinfo->updt_id,
       cv.updt_task = reqinfo->updt_task
      WHERE cv.code_value=assay_code_value
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_msg = concat("Unable to activate ",trim(request->assay_list[x].display),
       " on code_value table.")
      GO TO exit_script
     ENDIF
     UPDATE  FROM discrete_task_assay dta
      SET dta.description = request->assay_list[x].description, dta.mnemonic = request->assay_list[x]
       .display, dta.mnemonic_key_cap = cnvtupper(request->assay_list[x].display),
       dta.active_ind = 1, dta.active_status_cd = active_code_value, dta.active_status_dt_tm =
       cnvtdatetime(curdate,curtime3),
       dta.active_status_prsnl_id = reqinfo->updt_id, dta.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       dta.updt_id = reqinfo->updt_id,
       dta.updt_task = reqinfo->updt_task, dta.updt_cnt = (dta.updt_cnt+ 1), dta.updt_applctx =
       reqinfo->updt_applctx
      WHERE dta.task_assay_cd=assay_code_value
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_msg = concat("Unable to activate ",trim(request->assay_list[x].display),
       " into code_value table.")
      GO TO exit_script
     ENDIF
     SET upd_bill_item = 0
     SET bill_item_id = 0.0
     SELECT INTO "NL:"
      FROM bill_item b
      WHERE b.ext_parent_reference_id=catalog_type_cd
       AND b.ext_parent_contributor_cd=oc_contributor_cd
       AND b.ext_parent_entity_name="CODE_VALUE"
       AND b.ext_child_reference_id=assay_code_value
       AND b.ext_child_contributor_cd=dta_contributor_cd
       AND b.ext_child_entity_name="CODE_VALUE"
      DETAIL
       IF (((b.active_ind=0) OR ((((b.ext_description != request->assay_list[x].description)) OR (b
       .ext_short_desc != substring(1,50,request->assay_list[x].display))) )) )
        upd_bill_item = 1
       ENDIF
       bill_item_id = b.bill_item_id
      WITH nocounter
     ;end select
     IF (curqual=0)
      INSERT  FROM bill_item b
       SET b.bill_item_id = seq(bill_item_seq,nextval), b.ext_parent_reference_id = catalog_type_cd,
        b.ext_parent_contributor_cd = oc_contributor_cd,
        b.ext_parent_entity_name = "CODE_VALUE", b.ext_child_reference_id = assay_code_value, b
        .ext_child_contributor_cd = dta_contributor_cd,
        b.ext_child_entity_name = "CODE_VALUE", b.ext_description = request->assay_list[x].
        description, b.ext_owner_cd = request->assay_list[x].general_info.activity_type_code_value,
        b.ext_short_desc = substring(1,50,request->assay_list[x].display), b.active_ind = 1, b
        .active_status_cd = active_code_value,
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
       SET b.ext_description = request->assay_list[x].description, b.ext_short_desc = substring(1,50,
         request->assay_list[x].display), b.active_ind = 1,
        b.active_status_cd = active_code_value, b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b
        .updt_id = reqinfo->updt_id,
        b.updt_task = reqinfo->updt_task, b.updt_cnt = (b.updt_cnt+ 1), b.updt_applctx = reqinfo->
        updt_applctx
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
       AND b.ext_child_reference_id=assay_code_value
       AND b.ext_child_contributor_cd=dta_contributor_cd
       AND b.ext_child_entity_name="CODE_VALUE"
      DETAIL
       IF (((b.active_ind=0) OR ((((b.ext_description != request->assay_list[x].description)) OR (b
       .ext_short_desc != substring(1,50,request->assay_list[x].display))) )) )
        upd_bill_item = 1
       ENDIF
       bill_item_id = b.bill_item_id
      WITH nocounter
     ;end select
     IF (curqual=0)
      INSERT  FROM bill_item b
       SET b.bill_item_id = seq(bill_item_seq,nextval), b.ext_parent_reference_id = 0.0, b
        .ext_parent_contributor_cd = 0.0,
        b.ext_parent_entity_name = null, b.ext_child_reference_id = assay_code_value, b
        .ext_child_contributor_cd = dta_contributor_cd,
        b.ext_child_entity_name = "CODE_VALUE", b.ext_description = request->assay_list[x].
        description, b.ext_owner_cd = request->assay_list[x].general_info.activity_type_code_value,
        b.ext_short_desc = substring(1,50,request->assay_list[x].display), b.active_ind = 1, b
        .active_status_cd = active_code_value,
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
       SET b.ext_description = request->assay_list[x].description, b.ext_short_desc = substring(1,50,
         request->assay_list[x].display), b.active_ind = 1,
        b.active_status_cd = active_code_value, b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b
        .updt_id = reqinfo->updt_id,
        b.updt_task = reqinfo->updt_task, b.updt_cnt = (b.updt_cnt+ 1), b.updt_applctx = reqinfo->
        updt_applctx
       WHERE b.bill_item_id=bill_item_id
      ;end update
     ENDIF
     IF ((((request->assay_list[x].general_info.delta_check_ind=1)) OR ((request->assay_list[x].
     general_info.inter_data_check_ind=1))) )
      UPDATE  FROM br_assay ba
       SET ba.delta_checking_ind = request->assay_list[x].general_info.delta_check_ind, ba
        .interpretive_ind = request->assay_list[x].general_info.inter_data_check_ind
       WHERE ba.task_assay_cd=assay_code_value
       WITH nocounter
      ;end update
      IF (curqual=0)
       SET error_flag = "Y"
       SET error_msg = concat("Unable to update ",trim(request->assay_list[x].display),
        " into br_assay table.")
       GO TO exit_script
      ENDIF
     ELSEIF ((request->assay_list[x].general_info.delta_check_ind=0)
      AND (request->assay_list[x].general_info.inter_data_check_ind=0))
      DELETE  FROM br_assay ba
       WHERE ba.task_assay_cd=assay_code_value
       WITH nocounter
      ;end delete
     ENDIF
    ENDIF
   ELSEIF ((request->assay_list[x].action_flag=2))
    SET versioning_needed_ind = 1
    UPDATE  FROM code_value cv
     SET cv.definition = substring(1,60,request->assay_list[x].description), cv.description =
      substring(1,60,request->assay_list[x].description), cv.display = substring(1,40,request->
       assay_list[x].display),
      cv.display_key = trim(cnvtupper(cnvtalphanum(substring(1,40,request->assay_list[x].display)))),
      cv.concept_cki = sdtaconceptcki, cv.active_dt_tm = cnvtdatetime(curdate,curtime3),
      cv.active_ind = 1, cv.active_status_prsnl_id = reqinfo->updt_id, cv.active_type_cd =
      active_code_value,
      cv.updt_applctx = reqinfo->updt_applctx, cv.updt_cnt = (cv.updt_cnt+ 1), cv.updt_dt_tm =
      cnvtdatetime(curdate,curtime3),
      cv.updt_id = reqinfo->updt_id, cv.updt_task = reqinfo->updt_task
     WHERE (cv.code_value=request->assay_list[x].code_value)
     WITH nocounter
    ;end update
    SET reply->assay_list[x].code_value = request->assay_list[x].code_value
    IF (curqual != 0)
     UPDATE  FROM discrete_task_assay dta
      SET dta.description = request->assay_list[x].description, dta.mnemonic = request->assay_list[x]
       .display, dta.mnemonic_key_cap = cnvtupper(request->assay_list[x].display),
       dta.default_result_type_cd = request->assay_list[x].general_info.result_type_code_value, dta
       .bb_result_processing_cd =
       IF ((request->assay_list[x].general_info.res_proc_type_code_value > 0)) request->assay_list[x]
        .general_info.res_proc_type_code_value
       ELSE dta.bb_result_processing_cd
       ENDIF
       , dta.concept_cki = sdtaconceptcki,
       dta.rad_section_type_cd =
       IF ((request->assay_list[x].general_info.rad_section_type_code_value > 0)) request->
        assay_list[x].general_info.rad_section_type_code_value
       ELSE dta.rad_section_type_cd
       ENDIF
       , dta.io_flag = request->assay_list[x].general_info.io_flag, dta.single_select_ind = request->
       assay_list[x].general_info.single_select_ind,
       dta.default_type_flag = request->assay_list[x].general_info.default_type_flag, dta
       .sci_notation_ind =
       IF ((request->assay_list[x].general_info.sci_notation_ind > 0)) request->assay_list[x].
        general_info.sci_notation_ind
       ELSE dta.sci_notation_ind
       ENDIF
       , dta.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       dta.updt_id = reqinfo->updt_id, dta.updt_task = reqinfo->updt_task, dta.updt_cnt = (dta
       .updt_cnt+ 1),
       dta.updt_applctx = reqinfo->updt_applctx
      WHERE (dta.task_assay_cd=request->assay_list[x].code_value)
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_msg = concat("Unable to update ",trim(request->assay_list[x].display),
       " on the discrete_task_assay table.")
      GO TO exit_script
     ENDIF
     UPDATE  FROM bill_item b
      SET b.ext_description = request->assay_list[x].description, b.ext_short_desc = request->
       assay_list[x].display, b.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_cnt = (b.updt_cnt+ 1),
       b.updt_applctx = reqinfo->updt_applctx
      WHERE b.ext_parent_reference_id > 0
       AND b.ext_parent_contributor_cd=oc_contributor_cd
       AND b.ext_parent_entity_name="CODE_VALUE"
       AND b.ext_child_reference_id=assay_code_value
       AND b.ext_child_contributor_cd=dta_contributor_cd
       AND b.ext_child_entity_name="CODE_VALUE"
       AND (((b.ext_description != request->assay_list[x].description)) OR (b.ext_short_desc !=
      substring(1,50,request->assay_list[x].display)))
      WITH nocounter
     ;end update
     SET upd_bill_item = 0
     SET bill_item_id = 0.0
     SELECT INTO "NL:"
      FROM bill_item b
      WHERE b.ext_parent_reference_id=catalog_type_cd
       AND b.ext_parent_contributor_cd=oc_contributor_cd
       AND b.ext_parent_entity_name="CODE_VALUE"
       AND b.ext_child_reference_id=assay_code_value
       AND b.ext_child_contributor_cd=dta_contributor_cd
       AND b.ext_child_entity_name="CODE_VALUE"
      DETAIL
       IF (((b.active_ind=0) OR ((((b.ext_description != request->assay_list[x].description)) OR (b
       .ext_short_desc != substring(1,50,request->assay_list[x].display))) )) )
        upd_bill_item = 1
       ENDIF
       bill_item_id = b.bill_item_id
      WITH nocounter
     ;end select
     IF (curqual=0)
      INSERT  FROM bill_item b
       SET b.bill_item_id = seq(bill_item_seq,nextval), b.ext_parent_reference_id = catalog_type_cd,
        b.ext_parent_contributor_cd = oc_contributor_cd,
        b.ext_parent_entity_name = "CODE_VALUE", b.ext_child_reference_id = assay_code_value, b
        .ext_child_contributor_cd = dta_contributor_cd,
        b.ext_child_entity_name = "CODE_VALUE", b.ext_description = request->assay_list[x].
        description, b.ext_owner_cd = request->assay_list[x].general_info.activity_type_code_value,
        b.ext_short_desc = substring(1,50,request->assay_list[x].display), b.active_ind = 1, b
        .active_status_cd = active_code_value,
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
       SET b.ext_description = request->assay_list[x].description, b.ext_short_desc = substring(1,50,
         request->assay_list[x].display), b.active_ind = 1,
        b.active_status_cd = active_code_value, b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b
        .updt_id = reqinfo->updt_id,
        b.updt_task = reqinfo->updt_task, b.updt_cnt = (b.updt_cnt+ 1), b.updt_applctx = reqinfo->
        updt_applctx
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
       AND b.ext_child_reference_id=assay_code_value
       AND b.ext_child_contributor_cd=dta_contributor_cd
       AND b.ext_child_entity_name="CODE_VALUE"
      DETAIL
       IF (((b.active_ind=0) OR ((((b.ext_description != request->assay_list[x].description)) OR (b
       .ext_short_desc != substring(1,50,request->assay_list[x].display))) )) )
        upd_bill_item = 1
       ENDIF
       bill_item_id = b.bill_item_id
      WITH nocounter
     ;end select
     IF (curqual=0)
      INSERT  FROM bill_item b
       SET b.bill_item_id = seq(bill_item_seq,nextval), b.ext_parent_reference_id = 0.0, b
        .ext_parent_contributor_cd = 0.0,
        b.ext_parent_entity_name = null, b.ext_child_reference_id = assay_code_value, b
        .ext_child_contributor_cd = dta_contributor_cd,
        b.ext_child_entity_name = "CODE_VALUE", b.ext_description = request->assay_list[x].
        description, b.ext_owner_cd = request->assay_list[x].general_info.activity_type_code_value,
        b.ext_short_desc = substring(1,50,request->assay_list[x].display), b.active_ind = 1, b
        .active_status_cd = active_code_value,
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
       SET b.ext_description = request->assay_list[x].description, b.ext_short_desc = substring(1,50,
         request->assay_list[x].display), b.active_ind = 1,
        b.active_status_cd = active_code_value, b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b
        .updt_id = reqinfo->updt_id,
        b.updt_task = reqinfo->updt_task, b.updt_cnt = (b.updt_cnt+ 1), b.updt_applctx = reqinfo->
        updt_applctx
       WHERE b.bill_item_id=bill_item_id
      ;end update
     ENDIF
     IF ((((request->assay_list[x].general_info.delta_check_ind=1)) OR ((request->assay_list[x].
     general_info.inter_data_check_ind=1))) )
      UPDATE  FROM br_assay ba
       SET ba.delta_checking_ind = request->assay_list[x].general_info.delta_check_ind, ba
        .interpretive_ind = request->assay_list[x].general_info.inter_data_check_ind
       WHERE ba.task_assay_cd=assay_code_value
       WITH nocounter
      ;end update
      IF (curqual=0)
       INSERT  FROM br_assay ba
        SET ba.task_assay_cd = assay_code_value, ba.delta_checking_ind = request->assay_list[x].
         general_info.delta_check_ind, ba.interpretive_ind = request->assay_list[x].general_info.
         inter_data_check_ind
        WITH nocounter
       ;end insert
       IF (curqual=0)
        SET error_flag = "Y"
        SET error_msg = concat("Unable to insert ",trim(request->assay_list[x].display),
         " into br_assay table.")
        GO TO exit_script
       ENDIF
      ENDIF
     ENDIF
    ELSE
     IF ((request->assay_list[x].general_info.delta_check_ind=0)
      AND (request->assay_list[x].general_info.inter_data_check_ind=0))
      DELETE  FROM br_assay ba
       WHERE ba.task_assay_cd=assay_code_value
       WITH nocounter
      ;end delete
     ENDIF
    ENDIF
   ELSEIF ((request->assay_list[x].action_flag=3))
    SET versioning_needed_ind = 1
    SET reply->assay_list[x].code_value = request->assay_list[x].code_value
    UPDATE  FROM code_value cv
     SET cv.display = substring(1,40,request->assay_list[x].display), cv.display_key = trim(cnvtupper
       (cnvtalphanum(substring(1,40,request->assay_list[x].display)))), cv.active_dt_tm =
      cnvtdatetime(curdate,curtime3),
      cv.inactive_dt_tm = cnvtdatetime(curdate,curtime3), cv.active_ind = 0, cv
      .active_status_prsnl_id = reqinfo->updt_id,
      cv.active_type_cd = inactive_code_value, cv.updt_applctx = reqinfo->updt_applctx, cv.updt_cnt
       = (cv.updt_cnt+ 1),
      cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_id = reqinfo->updt_id, cv.updt_task =
      reqinfo->updt_task
     WHERE (cv.code_value=request->assay_list[x].code_value)
     WITH nocounter
    ;end update
    IF (curqual != 0)
     UPDATE  FROM discrete_task_assay dta
      SET dta.active_ind = 0, dta.active_status_cd = inactive_code_value, dta.updt_id = reqinfo->
       updt_id,
       dta.updt_task = reqinfo->updt_task, dta.updt_cnt = (dta.updt_cnt+ 1), dta.updt_applctx =
       reqinfo->updt_applctx
      WHERE dta.task_assay_cd=assay_code_value
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_msg = concat("Unable to inactivate",trim(request->assay_list[x].display),
       " on the discrete_task_assay table.")
      GO TO exit_script
     ENDIF
     UPDATE  FROM bill_item b
      SET b.ext_description = request->assay_list[x].description, b.ext_short_desc = substring(1,50,
        request->assay_list[x].display), b.active_ind = 0,
       b.active_status_cd = inactive_code_value, b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b
       .updt_id = reqinfo->updt_id,
       b.updt_task = reqinfo->updt_task, b.updt_cnt = 0, b.updt_applctx = reqinfo->updt_applctx
      WHERE b.ext_parent_contributor_cd=oc_contributor_cd
       AND b.ext_parent_entity_name="CODE_VALUE"
       AND b.ext_child_contributor_cd=dta_contributor_cd
       AND (b.ext_child_reference_id=request->assay_list[x].code_value)
       AND b.ext_child_entity_name="CODE_VALUE"
      WITH nocounter
     ;end update
    ELSE
     SET error_flag = "Y"
     SET error_msg = concat("Unable to inactivate ",trim(request->assay_list[x].display),
      " on codeset 14003.")
     GO TO exit_script
    ENDIF
   ENDIF
   SET rlist_count = size(request->assay_list[x].rr_list,5)
   SET rrf_id = 0.0
   FOR (i = 1 TO rlist_count)
     SET rrf_id = 0.0
     IF ((request->assay_list[x].rr_list[i].action_flag=1))
      IF ((request->assay_list[x].action_flag != 1))
       SET versioning_needed_ind = 1
      ENDIF
      SELECT INTO "NL:"
       j = seq(reference_seq,nextval)"##################;rp0"
       FROM dual
       DETAIL
        rrf_id = cnvtreal(j)
       WITH format, counter
      ;end select
      INSERT  FROM reference_range_factor rrf
       SET rrf.reference_range_factor_id = rrf_id, rrf.task_assay_cd = assay_code_value, rrf.sex_cd
         = request->assay_list[x].rr_list[i].sex_code_value,
        rrf.code_set = 0, rrf.alpha_response_ind = 0, rrf.unknown_age_ind = request->assay_list[x].
        rr_list[i].unknown_age_ind,
        rrf.age_from_minutes = request->assay_list[x].rr_list[i].from_age, rrf.age_from_units_cd =
        request->assay_list[x].rr_list[i].from_age_code_value, rrf.age_to_minutes = request->
        assay_list[x].rr_list[i].to_age,
        rrf.age_to_units_cd = request->assay_list[x].rr_list[i].to_age_code_value, rrf
        .precedence_sequence = request->assay_list[x].rr_list[i].sequence, rrf.gestational_ind =
        request->assay_list[x].rr_list[i].gestational_ind,
        rrf.service_resource_cd = request->assay_list[x].rr_list[i].service_resource_code_value, rrf
        .species_cd = request->assay_list[x].rr_list[i].species_code_value, rrf.specimen_type_cd =
        request->assay_list[x].rr_list[i].specimen_type_code_value,
        rrf.sensitive_low = 0, rrf.sensitive_high = 0, rrf.sensitive_ind = 0,
        rrf.normal_low = request->assay_list[x].rr_list[i].ref_low, rrf.normal_high = request->
        assay_list[x].rr_list[i].ref_high, rrf.normal_ind = request->assay_list[x].rr_list[i].ref_ind,
        rrf.critical_low = request->assay_list[x].rr_list[i].crit_low, rrf.critical_high = request->
        assay_list[x].rr_list[i].crit_high, rrf.critical_ind = request->assay_list[x].rr_list[i].
        crit_ind,
        rrf.linear_low = request->assay_list[x].rr_list[i].linear_low, rrf.linear_high = request->
        assay_list[x].rr_list[i].linear_high, rrf.linear_ind = request->assay_list[x].rr_list[i].
        linear_ind,
        rrf.dilute_ind = request->assay_list[x].rr_list[i].dilute_ind, rrf.feasible_low = request->
        assay_list[x].rr_list[i].feasible_low, rrf.feasible_high = request->assay_list[x].rr_list[i].
        feasible_high,
        rrf.feasible_ind = request->assay_list[x].rr_list[i].feasible_ind, rrf.review_low = request->
        assay_list[x].rr_list[i].review_low, rrf.review_high = request->assay_list[x].rr_list[i].
        review_high,
        rrf.review_ind = request->assay_list[x].rr_list[i].review_ind, rrf.default_result = request->
        assay_list[x].rr_list[i].def_value, rrf.def_result_ind = 0,
        rrf.delta_minutes = request->assay_list[x].rr_list[i].delta_minutes, rrf.delta_value =
        request->assay_list[x].rr_list[i].delta_value, rrf.delta_check_type_cd = request->assay_list[
        x].rr_list[i].delta_check_type_code_value,
        rrf.delta_chk_flag = request->assay_list[x].rr_list[i].delta_chk_flag, rrf.units_cd = request
        ->assay_list[x].rr_list[i].uom_code_value, rrf.mins_back = request->assay_list[x].rr_list[i].
        mins_back,
        rrf.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), rrf.end_effective_dt_tm =
        cnvtdatetime("31-DEC-2100"), rrf.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
        rrf.active_status_prsnl_id = reqinfo->updt_id, rrf.active_status_cd = active_code_value, rrf
        .active_ind = 1,
        rrf.encntr_type_cd = 0, rrf.updt_cnt = 0, rrf.updt_dt_tm = cnvtdatetime(curdate,curtime3),
        rrf.updt_id = reqinfo->updt_id, rrf.updt_task = reqinfo->updt_task, rrf.updt_applctx =
        reqinfo->updt_applctx
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET error_flag = "Y"
       SET error_msg = concat("Unable to insert reference range for ",trim(request->assay_list[x].
         display),".")
       GO TO exit_script
      ENDIF
      DECLARE delta_count = i4 WITH protect
      SET delta_count = size(request->assay_list[x].rr_list[i].adv_deltas,5)
      INSERT  FROM advanced_delta ad,
        (dummyt y  WITH seq = delta_count)
       SET ad.reference_range_factor_id = rrf_id, ad.advanced_delta_id = seq(reference_seq,nextval),
        ad.delta_ind = request->assay_list[x].rr_list[i].adv_deltas[y.seq].delta_ind,
        ad.delta_low = request->assay_list[x].rr_list[i].adv_deltas[y.seq].delta_low, ad.delta_high
         = request->assay_list[x].rr_list[i].adv_deltas[y.seq].delta_high, ad.delta_check_type_cd =
        request->assay_list[x].rr_list[i].adv_deltas[y.seq].delta_check_type_code_value,
        ad.delta_minutes = request->assay_list[x].rr_list[i].adv_deltas[y.seq].delta_minutes, ad
        .delta_value = request->assay_list[x].rr_list[i].adv_deltas[y.seq].delta_value, ad
        .beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
        ad.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), ad.active_ind = 1, ad
        .active_status_prsnl_id = reqinfo->updt_id,
        ad.active_status_cd = active_code_value, ad.active_status_dt_tm = cnvtdatetime(curdate,
         curtime3), ad.updt_cnt = 0,
        ad.updt_dt_tm = cnvtdatetime(curdate,curtime3), ad.updt_id = reqinfo->updt_id, ad.updt_task
         = reqinfo->updt_task,
        ad.updt_applctx = reqinfo->updt_applctx
       PLAN (y)
        JOIN (ad)
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET error_flag = "Y"
       SET error_msg = concat("Unable to insert advanced delta for ",trim(request->assay_list[x].
         display),".")
       GO TO exit_script
      ENDIF
      SET alist_count = size(request->assay_list[x].rr_list[i].alpha_list,5)
      FOR (y = 1 TO alist_count)
        CALL insertintoalpharesponses(y)
      ENDFOR
      SET rulelist_count = size(request->assay_list[x].rr_list[i].rule_list,5)
      SET fndtbl = checkdic("REF_RANGE_NOTIFY_TRIG","T",0)
      IF (fndtbl=2)
       FOR (y = 1 TO rulelist_count)
        INSERT  FROM ref_range_notify_trig rrnt
         SET rrnt.reference_range_factor_id = rrf_id, rrnt.ref_range_notify_trig_id = seq(
           reference_seq,nextval), rrnt.trigger_name = request->assay_list[x].rr_list[i].rule_list[y]
          .trigger_name,
          rrnt.trigger_seq_nbr = request->assay_list[x].rr_list[i].rule_list[y].trigger_seq_nbr, rrnt
          .updt_cnt = 0, rrnt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
          rrnt.updt_id = reqinfo->updt_id, rrnt.updt_task = reqinfo->updt_task, rrnt.updt_applctx =
          reqinfo->updt_applctx
         WITH nocounter
        ;end insert
        IF (curqual=0)
         SET error_flag = "Y"
         SET error_msg = concat("Unable to insert ref range rules for ",trim(request->assay_list[x].
           display),".")
         GO TO exit_script
        ENDIF
       ENDFOR
      ENDIF
     ENDIF
     IF ((request->assay_list[x].rr_list[i].action_flag=2))
      SET versioning_needed_ind = 1
      SET hold_code_set = 0
      SET hold_alpha_response_ind = 0
      SET hold_gestational_ind = 0
      SET hold_species_cd = 0
      SET hold_sensitive_low = 0
      SET hold_sensitive_high = 0
      SET hold_sensitive_ind = 0
      SET hold_def_result_ind = 0
      SET hold_delta_minutes = 0
      SET hold_delta_value = 0
      SET hold_delta_check_type_cd = 0
      SET mins_back = 0
      SET hold_delta_chk_flag = 0
      SET hold_encntr_type_cd = 0
      SELECT INTO "nl:"
       FROM reference_range_factor rrf
       PLAN (rrf
        WHERE (rrf.reference_range_factor_id=request->assay_list[x].rr_list[i].rrf_id)
         AND rrf.task_assay_cd=assay_code_value)
       DETAIL
        hold_code_set = rrf.code_set, hold_alpha_response_ind = rrf.alpha_response_ind,
        hold_gestational_ind = rrf.gestational_ind,
        hold_species_cd = rrf.species_cd, hold_sensitive_low = rrf.sensitive_low, hold_sensitive_high
         = rrf.sensitive_high,
        hold_sensitive_ind = rrf.sensitive_ind, hold_def_result_ind = rrf.def_result_ind,
        hold_delta_minutes = rrf.delta_minutes,
        hold_delta_value = rrf.delta_value, hold_delta_check_type_cd = rrf.delta_check_type_cd,
        hold_mins_back = rrf.mins_back,
        hold_delta_chk_flag = rrf.delta_chk_flag, hold_encntr_type_cd = rrf.encntr_type_cd
       WITH nocounter
      ;end select
      SET arcnt = 0
      SELECT INTO "nl:"
       FROM alpha_responses ar
       PLAN (ar
        WHERE (ar.reference_range_factor_id=request->assay_list[x].rr_list[i].rrf_id)
         AND ar.active_ind=1)
       HEAD REPORT
        arcnt = 0
       DETAIL
        arcnt = (arcnt+ 1), stat = alterlist(arhold->arlist,arcnt), arhold->arlist[arcnt].
        hold_nomenclature_id = ar.nomenclature_id,
        arhold->arlist[arcnt].hold_sequence = ar.sequence, arhold->arlist[arcnt].hold_use_units_ind
         = ar.use_units_ind, arhold->arlist[arcnt].hold_result_process_cd = ar.result_process_cd,
        arhold->arlist[arcnt].hold_default_ind = ar.default_ind, arhold->arlist[arcnt].
        hold_description = ar.description, arhold->arlist[arcnt].hold_active_ind = ar.active_ind,
        arhold->arlist[arcnt].hold_active_status_cd = ar.active_status_cd, arhold->arlist[arcnt].
        hold_active_status_dt_tm = cnvtdatetime(ar.active_status_dt_tm), arhold->arlist[arcnt].
        hold_active_status_prsnl_id = ar.active_status_prsnl_id,
        arhold->arlist[arcnt].hold_beg_effective_dt_tm = cnvtdatetime(ar.beg_effective_dt_tm), arhold
        ->arlist[arcnt].hold_end_effective_dt_tm = cnvtdatetime(ar.end_effective_dt_tm), arhold->
        arlist[arcnt].hold_result_value = ar.result_value,
        arhold->arlist[arcnt].hold_reference_ind = ar.reference_ind, arhold->arlist[arcnt].
        hold_multi_alpha_sort_order = ar.multi_alpha_sort_order, arhold->arlist[arcnt].
        hold_truth_state_cd = ar.truth_state_cd
       WITH nocounter
      ;end select
      SET adcnt = 0
      SELECT INTO "nl:"
       FROM advanced_delta ad
       PLAN (ad
        WHERE (ad.reference_range_factor_id=request->assay_list[x].rr_list[i].rrf_id)
         AND ad.active_ind=1)
       HEAD REPORT
        adcnt = 0
       DETAIL
        adcnt = (adcnt+ 1), stat = alterlist(adhold->adlist,adcnt), adhold->adlist[adcnt].
        hold_advanced_delta_id = ad.advanced_delta_id,
        adhold->adlist[adcnt].hold_delta_ind = ad.delta_ind, adhold->adlist[adcnt].hold_delta_low =
        ad.delta_low, adhold->adlist[adcnt].hold_delta_high = ad.delta_high,
        adhold->adlist[adcnt].hold_delta_check_type_cd = ad.delta_check_type_cd, adhold->adlist[adcnt
        ].hold_delta_minutes = ad.delta_minutes, adhold->adlist[adcnt].hold_delta_value = ad
        .delta_value,
        adhold->adlist[adcnt].hold_active_ind = ad.active_ind, adhold->adlist[adcnt].
        hold_active_status_cd = ad.active_status_cd, adhold->adlist[adcnt].hold_active_status_dt_tm
         = cnvtdatetime(ad.active_status_dt_tm),
        adhold->adlist[adcnt].hold_active_status_prsnl_id = ad.active_status_prsnl_id, adhold->
        adlist[adcnt].hold_beg_effective_dt_tm = cnvtdatetime(ad.beg_effective_dt_tm), adhold->
        adlist[adcnt].hold_end_effective_dt_tm = cnvtdatetime(ad.end_effective_dt_tm)
       WITH nocounter
      ;end select
      SET rrntcnt = 0
      SET fndtbl = checkdic("REF_RANGE_NOTIFY_TRIG","T",0)
      IF (fndtbl=2)
       SELECT INTO "nl:"
        FROM ref_range_notify_trig rrnt
        PLAN (rrnt
         WHERE (rrnt.reference_range_factor_id=request->assay_list[x].rr_list[i].rrf_id))
        HEAD REPORT
         rrntcnt = 0
        DETAIL
         rrntcnt = (rrntcnt+ 1), stat = alterlist(rrnthold->rrntlist,rrntcnt), rrnthold->rrntlist[
         rrntcnt].trigger_name = rrnt.trigger_name,
         rrnthold->rrntlist[rrntcnt].trigger_seq_nbr = rrnt.trigger_seq_nbr
        WITH nocounter
       ;end select
      ENDIF
      UPDATE  FROM reference_range_factor rrf
       SET rrf.active_ind = 0, rrf.active_status_cd = inactive_code_value, rrf.active_status_dt_tm =
        cnvtdatetime(curdate,curtime),
        rrf.active_status_prsnl_id = reqinfo->updt_id, rrf.end_effective_dt_tm = cnvtdatetime(curdate,
         curtime), rrf.updt_id = reqinfo->updt_id,
        rrf.updt_dt_tm = cnvtdatetime(curdate,curtime), rrf.updt_task = reqinfo->updt_task, rrf
        .updt_applctx = reqinfo->updt_applctx,
        rrf.updt_cnt = (rrf.updt_cnt+ 1)
       WHERE (rrf.reference_range_factor_id=request->assay_list[x].rr_list[i].rrf_id)
        AND rrf.task_assay_cd=assay_code_value
       WITH nocounter
      ;end update
      IF (curqual=0)
       SET error_flag = "Y"
       SET error_msg = concat("Unable to delete reference range for ",trim(request->assay_list[x].
         display),".")
       GO TO exit_script
      ENDIF
      UPDATE  FROM alpha_responses ar
       SET ar.active_ind = 0, ar.active_status_cd = inactive_code_value, ar.active_status_dt_tm =
        cnvtdatetime(curdate,curtime),
        ar.active_status_prsnl_id = reqinfo->updt_id, ar.updt_dt_tm = cnvtdatetime(curdate,curtime),
        ar.updt_id = reqinfo->updt_id,
        ar.updt_task = reqinfo->updt_task, ar.updt_cnt = (ar.updt_cnt+ 1), ar.updt_applctx = reqinfo
        ->updt_applctx
       WHERE (ar.reference_range_factor_id=request->assay_list[x].rr_list[i].rrf_id)
        AND ar.active_ind=1
       WITH nocounter
      ;end update
      UPDATE  FROM advanced_delta ad
       SET ad.active_ind = 0, ad.active_status_cd = inactive_code_value, ad.active_status_dt_tm =
        cnvtdatetime(curdate,curtime),
        ad.active_status_prsnl_id = reqinfo->updt_id, ad.updt_dt_tm = cnvtdatetime(curdate,curtime),
        ad.updt_id = reqinfo->updt_id,
        ad.updt_task = reqinfo->updt_task, ad.updt_cnt = (ad.updt_cnt+ 1), ad.updt_applctx = reqinfo
        ->updt_applctx
       WHERE (ad.reference_range_factor_id=request->assay_list[x].rr_list[i].rrf_id)
        AND ad.active_ind=1
       WITH nocounter
      ;end update
      SELECT INTO "NL:"
       j = seq(reference_seq,nextval)"##################;rp0"
       FROM dual
       DETAIL
        rrf_id = cnvtreal(j)
       WITH format, counter
      ;end select
      SET request->assay_list[x].rr_list[i].rrf_id = rrf_id
      INSERT  FROM reference_range_factor rrf
       SET rrf.reference_range_factor_id = rrf_id, rrf.task_assay_cd = assay_code_value, rrf.sex_cd
         = request->assay_list[x].rr_list[i].sex_code_value,
        rrf.code_set = hold_code_set, rrf.alpha_response_ind = hold_alpha_response_ind, rrf
        .unknown_age_ind = request->assay_list[x].rr_list[i].unknown_age_ind,
        rrf.age_from_minutes = request->assay_list[x].rr_list[i].from_age, rrf.age_from_units_cd =
        request->assay_list[x].rr_list[i].from_age_code_value, rrf.age_to_minutes = request->
        assay_list[x].rr_list[i].to_age,
        rrf.age_to_units_cd = request->assay_list[x].rr_list[i].to_age_code_value, rrf
        .precedence_sequence = request->assay_list[x].rr_list[i].sequence, rrf.gestational_ind =
        hold_gestational_ind,
        rrf.service_resource_cd = request->assay_list[x].rr_list[i].service_resource_code_value, rrf
        .species_cd = hold_species_cd, rrf.specimen_type_cd = request->assay_list[x].rr_list[i].
        specimen_type_code_value,
        rrf.sensitive_low = hold_sensitive_low, rrf.sensitive_high = hold_sensitive_high, rrf
        .sensitive_ind = hold_sensitive_ind,
        rrf.normal_low = request->assay_list[x].rr_list[i].ref_low, rrf.normal_high = request->
        assay_list[x].rr_list[i].ref_high, rrf.normal_ind = request->assay_list[x].rr_list[i].ref_ind,
        rrf.critical_low = request->assay_list[x].rr_list[i].crit_low, rrf.critical_high = request->
        assay_list[x].rr_list[i].crit_high, rrf.critical_ind = request->assay_list[x].rr_list[i].
        crit_ind,
        rrf.linear_low = request->assay_list[x].rr_list[i].linear_low, rrf.linear_high = request->
        assay_list[x].rr_list[i].linear_high, rrf.linear_ind = request->assay_list[x].rr_list[i].
        linear_ind,
        rrf.dilute_ind = request->assay_list[x].rr_list[i].dilute_ind, rrf.feasible_low = request->
        assay_list[x].rr_list[i].feasible_low, rrf.feasible_high = request->assay_list[x].rr_list[i].
        feasible_high,
        rrf.feasible_ind = request->assay_list[x].rr_list[i].feasible_ind, rrf.review_low = request->
        assay_list[x].rr_list[i].review_low, rrf.review_high = request->assay_list[x].rr_list[i].
        review_high,
        rrf.review_ind = request->assay_list[x].rr_list[i].review_ind, rrf.default_result = request->
        assay_list[x].rr_list[i].def_value, rrf.def_result_ind = hold_def_result_ind,
        rrf.delta_minutes = hold_delta_minutes, rrf.delta_value = hold_delta_value, rrf
        .delta_check_type_cd = hold_delta_check_type_cd,
        rrf.units_cd = request->assay_list[x].rr_list[i].uom_code_value, rrf.mins_back =
        hold_mins_back, rrf.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
        rrf.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), rrf.active_status_dt_tm = cnvtdatetime
        (curdate,curtime3), rrf.active_status_prsnl_id = reqinfo->updt_id,
        rrf.active_status_cd = active_code_value, rrf.active_ind = 1, rrf.delta_chk_flag =
        hold_delta_chk_flag,
        rrf.encntr_type_cd = hold_encntr_type_cd, rrf.updt_cnt = 0, rrf.updt_dt_tm = cnvtdatetime(
         curdate,curtime3),
        rrf.updt_id = reqinfo->updt_id, rrf.updt_task = reqinfo->updt_task, rrf.updt_applctx =
        reqinfo->updt_applctx
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET error_flag = "Y"
       SET error_msg = concat("Unable to insert reference range for ",trim(request->assay_list[x].
         display),".")
       GO TO exit_script
      ENDIF
      FOR (y = 1 TO arcnt)
       INSERT  FROM alpha_responses ar
        SET ar.reference_range_factor_id = rrf_id, ar.nomenclature_id = arhold->arlist[y].
         hold_nomenclature_id, ar.active_status_prsnl_id = arhold->arlist[y].
         hold_active_status_prsnl_id,
         ar.active_status_cd = arhold->arlist[y].hold_active_status_cd, ar.active_status_dt_tm =
         cnvtdatetime(curdate,curtime3), ar.sequence = arhold->arlist[y].hold_sequence,
         ar.result_process_cd = arhold->arlist[y].hold_result_process_cd, ar.default_ind = arhold->
         arlist[y].hold_default_ind, ar.use_units_ind = arhold->arlist[y].hold_use_units_ind,
         ar.reference_ind = arhold->arlist[y].hold_reference_ind, ar.result_value = arhold->arlist[y]
         .hold_result_value, ar.multi_alpha_sort_order = arhold->arlist[y].
         hold_multi_alpha_sort_order,
         ar.truth_state_cd = arhold->arlist[y].hold_truth_state_cd, ar.description = arhold->arlist[y
         ].hold_description, ar.beg_effective_dt_tm = cnvtdatetime(arhold->arlist[y].
          hold_beg_effective_dt_tm),
         ar.end_effective_dt_tm = cnvtdatetime(arhold->arlist[y].hold_end_effective_dt_tm), ar
         .active_status_dt_tm = cnvtdatetime(arhold->arlist[y].hold_active_status_dt_tm), ar
         .active_ind = arhold->arlist[y].hold_active_ind,
         ar.updt_cnt = 0, ar.updt_dt_tm = cnvtdatetime(curdate,curtime3), ar.updt_id = reqinfo->
         updt_id,
         ar.updt_task = reqinfo->updt_task, ar.updt_applctx = reqinfo->updt_applctx
        WITH nocounter
       ;end insert
       IF (curqual=0)
        SET error_flag = "Y"
        SET error_msg = concat("Unable to insert alpha responses for ",trim(request->assay_list[x].
          display),".")
        GO TO exit_script
       ENDIF
      ENDFOR
      FOR (y = 1 TO adcnt)
       INSERT  FROM advanced_delta ad
        SET ad.reference_range_factor_id = rrf_id, ad.advanced_delta_id = seq(reference_seq,nextval),
         ad.delta_ind = adhold->adlist[y].hold_delta_ind,
         ad.delta_low = adhold->adlist[y].hold_delta_low, ad.delta_high = adhold->adlist[y].
         hold_delta_high, ad.delta_check_type_cd = adhold->adlist[y].hold_delta_check_type_cd,
         ad.delta_minutes = adhold->adlist[y].hold_delta_minutes, ad.delta_value = adhold->adlist[y].
         hold_delta_value, ad.beg_effective_dt_tm = cnvtdatetime(adhold->adlist[y].
          hold_beg_effective_dt_tm),
         ad.end_effective_dt_tm = cnvtdatetime(adhold->adlist[y].hold_end_effective_dt_tm), ad
         .active_status_prsnl_id = adhold->adlist[y].hold_active_status_prsnl_id, ad.active_status_cd
          = adhold->adlist[y].hold_active_status_cd,
         ad.active_status_dt_tm = cnvtdatetime(adhold->adlist[y].hold_active_status_dt_tm), ad
         .active_ind = adhold->adlist[y].hold_active_ind, ad.updt_cnt = 0,
         ad.updt_dt_tm = cnvtdatetime(curdate,curtime3), ad.updt_id = reqinfo->updt_id, ad.updt_task
          = reqinfo->updt_task,
         ad.updt_applctx = reqinfo->updt_applctx
        WITH nocounter
       ;end insert
       IF (curqual=0)
        SET error_flag = "Y"
        SET error_msg = concat("Unable to insert alpha responses for ",trim(request->assay_list[x].
          display),".")
        GO TO exit_script
       ENDIF
      ENDFOR
      FOR (y = 1 TO rrntcnt)
        INSERT  FROM ref_range_notify_trig rrnt
         SET rrnt.ref_range_notify_trig_id = seq(reference_seq,nextval), rrnt
          .reference_range_factor_id = rrf_id, rrnt.trigger_seq_nbr = rrnthold->rrntlist[y].
          trigger_seq_nbr,
          rrnt.trigger_name = rrnthold->rrntlist[y].trigger_name, rrnt.updt_id = reqinfo->updt_id,
          rrnt.updt_dt_tm = cnvtdatetime(curdate,curtime),
          rrnt.updt_task = reqinfo->updt_task, rrnt.updt_applctx = reqinfo->updt_applctx, rrnt
          .updt_cnt = 0
         WITH nocounter
        ;end insert
      ENDFOR
     ENDIF
     IF ((((request->assay_list[x].rr_list[i].action_flag=0)) OR ((request->assay_list[x].rr_list[i].
     action_flag=2))) )
      SET alist_count = size(request->assay_list[x].rr_list[i].alpha_list,5)
      FOR (y = 1 TO alist_count)
        IF ((request->assay_list[x].rr_list[i].alpha_list[y].action_flag=1))
         IF ((request->assay_list[x].action_flag != 1))
          SET versioning_needed_ind = 1
         ENDIF
         SET newtruthstatecd = 0.0
         IF ((validate(request->assay_list[x].rr_list[i].alpha_list[y].truth_state_cd,- (1)) != - (1)
         ))
          SET newtruthstatecd = request->assay_list[x].rr_list[i].alpha_list[y].truth_state_cd
         ENDIF
         INSERT  FROM alpha_responses ar
          SET ar.reference_range_factor_id = request->assay_list[x].rr_list[i].rrf_id, ar
           .nomenclature_id = request->assay_list[x].rr_list[i].alpha_list[y].nomenclature_id, ar
           .active_status_prsnl_id = reqinfo->updt_id,
           ar.active_status_cd = active_code_value, ar.active_status_dt_tm = cnvtdatetime(curdate,
            curtime3), ar.sequence = request->assay_list[x].rr_list[i].alpha_list[y].sequence,
           ar.result_process_cd = request->assay_list[x].rr_list[i].alpha_list[y].
           result_process_code_value, ar.default_ind = request->assay_list[x].rr_list[i].alpha_list[y
           ].default_ind, ar.use_units_ind = request->assay_list[x].rr_list[i].alpha_list[y].
           use_units_ind,
           ar.reference_ind = request->assay_list[x].rr_list[i].alpha_list[y].reference_ind, ar
           .truth_state_cd = newtruthstatecd, ar.result_value = request->assay_list[x].rr_list[i].
           alpha_list[y].result_value,
           ar.multi_alpha_sort_order =
           IF (validate(request->assay_list[x].rr_list[i].alpha_list[y].multi_alpha_sort_order))
            request->assay_list[x].rr_list[i].alpha_list[y].multi_alpha_sort_order
           ELSE 0
           ENDIF
           , ar.description = request->assay_list[x].rr_list[i].alpha_list[y].short_string, ar
           .beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
           ar.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), ar.active_ind = 1, ar.updt_cnt = 0,
           ar.updt_dt_tm = cnvtdatetime(curdate,curtime3), ar.updt_id = reqinfo->updt_id, ar
           .updt_task = reqinfo->updt_task,
           ar.updt_applctx = reqinfo->updt_applctx
          WITH nocounter
         ;end insert
         IF (curqual=0)
          SET error_flag = "Y"
          SET error_msg = concat("Unable to insert alpha responses for ",trim(request->assay_list[x].
            display),".")
          GO TO exit_script
         ENDIF
        ELSEIF ((request->assay_list[x].rr_list[i].alpha_list[y].action_flag=2))
         SET versioning_needed_ind = 1
         SET newtruthstatecd = 0.0
         IF ((validate(request->assay_list[x].rr_list[i].alpha_list[y].truth_state_cd,- (1)) != - (1)
         ))
          SET newtruthstatecd = request->assay_list[x].rr_list[i].alpha_list[y].truth_state_cd
         ENDIF
         UPDATE  FROM alpha_responses ar
          SET ar.sequence = request->assay_list[x].rr_list[i].alpha_list[y].sequence, ar
           .result_process_cd = request->assay_list[x].rr_list[i].alpha_list[y].
           result_process_code_value, ar.default_ind = request->assay_list[x].rr_list[i].alpha_list[y
           ].default_ind,
           ar.use_units_ind = request->assay_list[x].rr_list[i].alpha_list[y].use_units_ind, ar
           .reference_ind = request->assay_list[x].rr_list[i].alpha_list[y].reference_ind, ar
           .truth_state_cd = newtruthstatecd,
           ar.result_value =
           IF (validate(request->assay_list[x].rr_list[i].alpha_list[y].result_value)) request->
            assay_list[x].rr_list[i].alpha_list[y].result_value
           ELSE ar.result_value
           ENDIF
           , ar.multi_alpha_sort_order =
           IF (validate(request->assay_list[x].rr_list[i].alpha_list[y].multi_alpha_sort_order))
            request->assay_list[x].rr_list[i].alpha_list[y].multi_alpha_sort_order
           ELSE ar.multi_alpha_sort_order
           ENDIF
           , ar.description =
           IF (validate(request->assay_list[x].rr_list[i].alpha_list[y].short_string))
            IF (size(trim(request->assay_list[x].rr_list[i].alpha_list[y].short_string),1) > 0)
             request->assay_list[x].rr_list[i].alpha_list[y].short_string
            ELSE ar.description
            ENDIF
           ENDIF
           ,
           ar.updt_cnt = (ar.updt_cnt+ 1), ar.updt_dt_tm = cnvtdatetime(curdate,curtime3), ar.updt_id
            = reqinfo->updt_id,
           ar.updt_task = reqinfo->updt_task, ar.updt_applctx = reqinfo->updt_applctx
          WHERE (ar.reference_range_factor_id=request->assay_list[x].rr_list[i].rrf_id)
           AND (ar.nomenclature_id=request->assay_list[x].rr_list[i].alpha_list[y].nomenclature_id)
          WITH nocounter
         ;end update
         IF (curqual=0)
          SET error_flag = "Y"
          SET error_msg = concat("Unable to update alpha responses for ",trim(request->assay_list[x].
            display),".")
          GO TO exit_script
         ENDIF
        ELSEIF ((request->assay_list[x].rr_list[i].alpha_list[y].action_flag=3))
         SET versioning_needed_ind = 1
         DELETE  FROM alpha_responses ar
          WHERE (ar.reference_range_factor_id=request->assay_list[x].rr_list[i].rrf_id)
           AND (ar.nomenclature_id=request->assay_list[x].rr_list[i].alpha_list[y].nomenclature_id)
          WITH nocounter
         ;end delete
         IF (curqual=0)
          SET error_flag = "Y"
          SET error_msg = concat("Unable to delete alpha responses for ",trim(request->assay_list[x].
            display),".")
          GO TO exit_script
         ENDIF
        ENDIF
      ENDFOR
      SET fndtbl = checkdic("REF_RANGE_NOTIFY_TRIG","T",0)
      IF (fndtbl=2)
       SET rulelist_count = size(request->assay_list[x].rr_list[i].rule_list,5)
       FOR (y = 1 TO rulelist_count)
         IF ((request->assay_list[x].rr_list[i].rule_list[y].action_flag=2))
          UPDATE  FROM ref_range_notify_trig rrnt
           SET rrnt.trigger_seq_nbr = ((rrnt.trigger_seq_nbr+ 1) * - (1))
           WHERE (rrnt.ref_range_notify_trig_id=request->assay_list[x].rr_list[i].rule_list[y].
           ref_range_notify_trig_id)
           WITH nocounter
          ;end update
         ENDIF
       ENDFOR
       FOR (y = 1 TO rulelist_count)
         IF ((request->assay_list[x].rr_list[i].rule_list[y].action_flag=1))
          IF ((request->assay_list[x].action_flag != 1))
           SET versioning_needed_ind = 1
          ENDIF
          INSERT  FROM ref_range_notify_trig rrnt
           SET rrnt.ref_range_notify_trig_id = seq(reference_seq,nextval), rrnt
            .reference_range_factor_id = request->assay_list[x].rr_list[i].rrf_id, rrnt.trigger_name
             = request->assay_list[x].rr_list[i].rule_list[y].trigger_name,
            rrnt.trigger_seq_nbr = request->assay_list[x].rr_list[i].rule_list[y].trigger_seq_nbr,
            rrnt.updt_cnt = 0, rrnt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
            rrnt.updt_id = reqinfo->updt_id, rrnt.updt_task = reqinfo->updt_task, rrnt.updt_applctx
             = reqinfo->updt_applctx
           WITH nocounter
          ;end insert
          IF (curqual=0)
           SET error_flag = "Y"
           SET error_msg = concat("Unable to insert ref range rules for ",trim(request->assay_list[x]
             .display),".")
           GO TO exit_script
          ENDIF
         ELSEIF ((request->assay_list[x].rr_list[i].rule_list[y].action_flag=2))
          SET versioning_needed_ind = 1
          UPDATE  FROM ref_range_notify_trig rrnt
           SET rrnt.trigger_seq_nbr = request->assay_list[x].rr_list[i].rule_list[y].trigger_seq_nbr,
            rrnt.updt_cnt = (rrnt.updt_cnt+ 1), rrnt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
            rrnt.updt_id = reqinfo->updt_id, rrnt.updt_task = reqinfo->updt_task, rrnt.updt_applctx
             = reqinfo->updt_applctx
           WHERE (rrnt.ref_range_notify_trig_id=request->assay_list[x].rr_list[i].rule_list[y].
           ref_range_notify_trig_id)
           WITH nocounter
          ;end update
          IF (curqual=0)
           SET error_flag = "Y"
           SET error_msg = concat("Unable to update ref range rule for ",trim(request->assay_list[x].
             display),".")
           GO TO exit_script
          ENDIF
         ELSEIF ((request->assay_list[x].rr_list[i].rule_list[y].action_flag=3))
          SET versioning_needed_ind = 1
          DELETE  FROM ref_range_notify_trig rrnt
           WHERE (rrnt.ref_range_notify_trig_id=request->assay_list[x].rr_list[i].rule_list[y].
           ref_range_notify_trig_id)
           WITH nocounter
          ;end delete
          IF (curqual=0)
           SET error_flag = "Y"
           SET error_msg = concat("Unable to delete ref range rule for ",trim(request->assay_list[x].
             display),".")
           GO TO exit_script
          ENDIF
         ENDIF
       ENDFOR
      ENDIF
     ENDIF
     IF ((request->assay_list[x].rr_list[i].action_flag=3))
      SET versioning_needed_ind = 1
      UPDATE  FROM alpha_responses ar
       SET ar.active_ind = 0, ar.active_status_cd = inactive_code_value, ar.active_status_dt_tm =
        cnvtdatetime(curdate,curtime),
        ar.active_status_prsnl_id = reqinfo->updt_id, ar.updt_dt_tm = cnvtdatetime(curdate,curtime),
        ar.updt_id = reqinfo->updt_id,
        ar.updt_task = reqinfo->updt_task, ar.updt_cnt = (ar.updt_cnt+ 1), ar.updt_applctx = reqinfo
        ->updt_applctx
       WHERE (ar.reference_range_factor_id=request->assay_list[x].rr_list[i].rrf_id)
        AND ar.active_ind=1
       WITH nocounter
      ;end update
      UPDATE  FROM advanced_delta ad
       SET ad.active_ind = 0, ad.active_status_cd = inactive_code_value, ad.active_status_dt_tm =
        cnvtdatetime(curdate,curtime),
        ad.active_status_prsnl_id = reqinfo->updt_id, ad.updt_dt_tm = cnvtdatetime(curdate,curtime),
        ad.updt_id = reqinfo->updt_id,
        ad.updt_task = reqinfo->updt_task, ad.updt_cnt = (ad.updt_cnt+ 1), ad.updt_applctx = reqinfo
        ->updt_applctx
       WHERE (ad.reference_range_factor_id=request->assay_list[x].rr_list[i].rrf_id)
        AND ad.active_ind=1
       WITH nocounter
      ;end update
      UPDATE  FROM reference_range_factor rrf
       SET rrf.active_ind = 0, rrf.active_status_cd = inactive_code_value, rrf.active_status_dt_tm =
        cnvtdatetime(curdate,curtime),
        rrf.active_status_prsnl_id = reqinfo->updt_id, rrf.end_effective_dt_tm = cnvtdatetime(curdate,
         curtime), rrf.updt_id = reqinfo->updt_id,
        rrf.updt_dt_tm = cnvtdatetime(curdate,curtime), rrf.updt_task = reqinfo->updt_task, rrf
        .updt_applctx = reqinfo->updt_applctx,
        rrf.updt_cnt = (rrf.updt_cnt+ 1)
       WHERE (rrf.reference_range_factor_id=request->assay_list[x].rr_list[i].rrf_id)
        AND rrf.task_assay_cd=assay_code_value
       WITH nocounter
      ;end update
      IF (curqual=0)
       SET error_flag = "Y"
       SET error_msg = concat("Unable to delete reference range for ",trim(request->assay_list[x].
         display),".")
       GO TO exit_script
      ENDIF
     ENDIF
   ENDFOR
   SET dlist_count = size(request->assay_list[x].data_map,5)
   FOR (i = 1 TO dlist_count)
     IF ((request->assay_list[x].data_map[i].action_flag=4))
      SET versioning_needed_ind = 1
      UPDATE  FROM data_map dm
       SET dm.active_ind = 0, dm.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), dm
        .active_status_cd = inactive_code_value,
        dm.active_status_prsnl_id = reqinfo->updt_id, dm.active_status_dt_tm = cnvtdatetime(curdate,
         curtime3), dm.updt_cnt = dm.updt_cnt,
        dm.updt_dt_tm = cnvtdatetime(curdate,curtime3), dm.updt_id = reqinfo->updt_id, dm.updt_task
         = reqinfo->updt_task,
        dm.updt_applctx = reqinfo->updt_applctx
       WHERE dm.task_assay_cd=assay_code_value
        AND (dm.service_resource_cd=request->assay_list[x].data_map[i].service_resource_code_value)
        AND dm.data_map_type_flag=0
       WITH nocounter
      ;end update
     ELSE
      IF ((((request->assay_list[x].data_map[i].action_flag=2)) OR ((request->assay_list[x].data_map[
      i].action_flag=3))) )
       SET versioning_needed_ind = 1
       DELETE  FROM data_map dm
        WHERE dm.task_assay_cd=assay_code_value
         AND (dm.service_resource_cd=request->assay_list[x].data_map[i].service_resource_code_value)
         AND dm.data_map_type_flag=0
        WITH nocounter
       ;end delete
      ENDIF
      IF ((((request->assay_list[x].data_map[i].action_flag=1)) OR ((request->assay_list[x].data_map[
      i].action_flag=2))) )
       IF ((request->assay_list[x].action_flag != 1))
        SET versioning_needed_ind = 1
       ENDIF
       INSERT  FROM data_map dm
        SET dm.task_assay_cd = assay_code_value, dm.min_digits = request->assay_list[x].data_map[i].
         min_digits, dm.max_digits = request->assay_list[x].data_map[i].max_digits,
         dm.min_decimal_places = request->assay_list[x].data_map[i].dec_place, dm.service_resource_cd
          = request->assay_list[x].data_map[i].service_resource_code_value, dm.data_map_type_flag = 0,
         dm.result_entry_format = 0, dm.active_status_cd = active_code_value, dm
         .active_status_prsnl_id = reqinfo->updt_id,
         dm.active_status_dt_tm = cnvtdatetime(curdate,curtime3), dm.active_ind = 1, dm.updt_cnt = 0,
         dm.updt_dt_tm = cnvtdatetime(curdate,curtime3), dm.updt_id = reqinfo->updt_id, dm.updt_task
          = reqinfo->updt_task,
         dm.updt_applctx = reqinfo->updt_applctx, dm.beg_effective_dt_tm = cnvtdatetime(curdate,
          curtime3), dm.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
        WITH nocounter
       ;end insert
       IF (curqual=0)
        SET error_flag = "Y"
        SET error_msg = concat("Unable to update the data map for ",trim(request->assay_list[x].
          display),".")
        GO TO exit_script
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   IF (dlist_count=0)
    SET rlist_count = size(request->assay_list[x].rr_list,5)
    FOR (i = 1 TO rlist_count)
      IF ((request->assay_list[x].rr_list[i].uom_code_value > 0))
       SELECT INTO "NL:"
        FROM data_map dm
        WHERE dm.task_assay_cd=assay_code_value
         AND (dm.service_resource_cd=request->assay_list[x].rr_list[i].service_resource_code_value)
       ;end select
       IF (curqual=0)
        INSERT  FROM data_map dm
         SET dm.task_assay_cd = assay_code_value, dm.min_digits = 1, dm.max_digits = 8,
          dm.min_decimal_places = 0, dm.service_resource_cd = request->assay_list[x].rr_list[i].
          service_resource_code_value, dm.data_map_type_flag = 0,
          dm.result_entry_format = 0, dm.active_status_cd = active_code_value, dm
          .active_status_prsnl_id = reqinfo->updt_id,
          dm.active_status_dt_tm = cnvtdatetime(curdate,curtime3), dm.active_ind = 1, dm.updt_cnt = 0,
          dm.updt_dt_tm = cnvtdatetime(curdate,curtime3), dm.updt_id = reqinfo->updt_id, dm.updt_task
           = reqinfo->updt_task,
          dm.updt_applctx = reqinfo->updt_applctx, dm.beg_effective_dt_tm = cnvtdatetime(curdate,
           curtime3), dm.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
         WITH nocounter
        ;end insert
        IF (curqual=0)
         SET error_flag = "Y"
         SET error_msg = concat("Unable to update the data map for ",trim(request->assay_list[x].
           display),".")
         GO TO exit_script
        ENDIF
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   SET elist_count = size(request->assay_list[x].equivalent_assay,5)
   SET first_eq = 1
   SET related_entity_id = 0.0
   FOR (i = 1 TO elist_count)
    IF ((((request->assay_list[x].equivalent_assay[i].action_flag=2)) OR ((request->assay_list[x].
    equivalent_assay[i].action_flag=3))) )
     SELECT INTO "NL:"
      FROM related_assay ra
      WHERE ra.task_assay_cd=assay_code_value
      DETAIL
       related_entity_id = ra.related_entity_id
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_msg = concat("Unable to retreive the equivalent assays for ",trim(request->
        assay_list[x].display),".")
      GO TO exit_script
     ENDIF
     IF ((request->assay_list[x].equivalent_assay[i].action_flag=3))
      SET versioning_needed_ind = 1
      DELETE  FROM related_assay ra
       WHERE ra.related_entity_id=related_entity_id
        AND (ra.task_assay_cd=request->assay_list[x].equivalent_assay[i].code_value)
       WITH nocounter
      ;end delete
      IF (curqual=0)
       SET error_flag = "Y"
       SET error_msg = concat("Unable to delete the equivalent assay for ",trim(request->assay_list[x
         ].display),".")
       GO TO exit_script
      ENDIF
     ENDIF
    ENDIF
    IF ((((request->assay_list[x].equivalent_assay[i].action_flag=1)) OR ((request->assay_list[x].
    equivalent_assay[i].action_flag=2))) )
     IF ((request->assay_list[x].action_flag != 1))
      SET versioning_needed_flag = 1
     ENDIF
     IF ((request->assay_list[x].equivalent_assay[i].action_flag=1)
      AND first_eq=1)
      SET first_eq = 0
      SET related_entity_id = 0.0
      SELECT INTO "NL:"
       j = seq(reference_seq,nextval)"##################;rp0"
       FROM dual
       DETAIL
        related_entity_id = cnvtreal(j)
       WITH format, counter
      ;end select
     ENDIF
     INSERT  FROM related_assay ra
      SET ra.related_entity_id = related_entity_id, ra.task_assay_cd = request->assay_list[x].
       equivalent_assay[i].code_value, ra.rel_type_cd = delta_code_value,
       ra.active_status_cd = active_code_value, ra.active_status_prsnl_id = reqinfo->updt_id, ra
       .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
       ra.updt_cnt = 0, ra.updt_dt_tm = cnvtdatetime(curdate,curtime3), ra.updt_id = reqinfo->updt_id,
       ra.updt_task = reqinfo->updt_task, ra.updt_applctx = reqinfo->updt_applctx, ra
       .beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
       ra.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_msg = concat("Unable to update the equivalent assays for ",trim(request->assay_list[x
        ].display),".")
      GO TO exit_script
     ENDIF
    ENDIF
   ENDFOR
   IF (versioning_needed_ind=1
    AND shared_domain_ind=0)
    IF (checkprg("DCP_ADD_DTA_VERSION"))
     SET version_request->task_assay_cd = assay_code_value
     EXECUTE dcp_add_dta_version  WITH replace("REQUEST","VERSION_REQUEST"), replace("REPLY",
      "VERSION_REPLY")
     IF ((version_reply->status_data.status="F"))
      SET error_flag = "Y"
      SET error_msg = concat("Unable to version dta: ",cnvtstring(assay_code_value))
      GO TO exit_script
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 SUBROUTINE insertintoalpharesponses(y)
   SET newtruthstatecd = 0.0
   IF ((validate(request->assay_list[x].rr_list[i].alpha_list[y].truth_state_cd,- (1)) != - (1)))
    SET newtruthstatecd = request->assay_list[x].rr_list[i].alpha_list[y].truth_state_cd
   ENDIF
   INSERT  FROM alpha_responses ar
    SET ar.reference_range_factor_id = rrf_id, ar.nomenclature_id = request->assay_list[x].rr_list[i]
     .alpha_list[y].nomenclature_id, ar.active_status_prsnl_id = reqinfo->updt_id,
     ar.active_status_cd = active_code_value, ar.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
     ar.sequence = request->assay_list[x].rr_list[i].alpha_list[y].sequence,
     ar.result_process_cd = request->assay_list[x].rr_list[i].alpha_list[y].result_process_code_value,
     ar.default_ind = request->assay_list[x].rr_list[i].alpha_list[y].default_ind, ar.use_units_ind
      = request->assay_list[x].rr_list[i].alpha_list[y].use_units_ind,
     ar.reference_ind = request->assay_list[x].rr_list[i].alpha_list[y].reference_ind, ar
     .result_value = request->assay_list[x].rr_list[i].alpha_list[y].result_value, ar.truth_state_cd
      = newtruthstatecd,
     ar.multi_alpha_sort_order = request->assay_list[x].rr_list[i].alpha_list[y].
     multi_alpha_sort_order, ar.description = request->assay_list[x].rr_list[i].alpha_list[y].
     short_string, ar.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
     ar.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), ar.active_ind = 1, ar.updt_cnt = 0,
     ar.updt_dt_tm = cnvtdatetime(curdate,curtime3), ar.updt_id = reqinfo->updt_id, ar.updt_task =
     reqinfo->updt_task,
     ar.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Unable to insert alpha responses for ",trim(request->assay_list[x].
      display),".")
    GO TO exit_script
   ENDIF
 END ;Subroutine
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  IF ((reply->status_data.status != "S"))
   SET reply->status_data.status = "F"
   CALL echo(error_msg)
   SET reply->error_msg = concat("  >> PROGRAM NAME: BED_ENS_ASSAY","  >> ERROR MSG: ",error_msg)
  ELSE
   SET reply->status_data.status = "F"
  ENDIF
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
