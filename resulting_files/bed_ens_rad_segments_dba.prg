CREATE PROGRAM bed_ens_rad_segments:dba
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
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET failed = "N"
 SET cnt = 0
 SET acnt = 0
 SET 14003_cd = 0.0
 SET cnt = size(request->orderables,5)
 IF (cnt=0)
  GO TO exit_script
 ENDIF
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
 SET rad_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=106
    AND cv.cdf_meaning="RADIOLOGY"
    AND cv.active_ind=1)
  DETAIL
   rad_cd = cv.code_value
  WITH nocounter
 ;end select
 SET date_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=289
    AND cv.cdf_meaning="11"
    AND cv.active_ind=1)
  DETAIL
   date_cd = cv.code_value
  WITH nocounter
 ;end select
 SET text_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=289
    AND cv.display_key="TEXT"
    AND cv.active_ind=1)
  DETAIL
   text_cd = cv.code_value
  WITH nocounter
 ;end select
 SET active_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=48
    AND cv.cdf_meaning="ACTIVE"
    AND cv.active_ind=1)
  DETAIL
   active_cd = cv.code_value
  WITH nocounter
 ;end select
 SET ordcat_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=13016
    AND cv.cdf_meaning="ORD CAT"
    AND cv.active_ind=1)
  DETAIL
   ordcat_cd = cv.code_value
  WITH nocounter
 ;end select
 SET assay_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=13016
    AND cv.cdf_meaning="TASK ASSAY"
    AND cv.active_ind=1)
  DETAIL
   assay_cd = cv.code_value
  WITH nocounter
 ;end select
 FOR (x = 1 TO cnt)
  SET acnt = size(request->orderables[x].assays,5)
  IF (acnt > 0)
   FOR (y = 1 TO acnt)
     IF ((request->orderables[x].assays[y].action_flag=1))
      SET 14003_cd = 0.0
      SELECT INTO "nl:"
       FROM code_value c
       PLAN (c
        WHERE c.code_set=14003
         AND (c.display=request->orderables[x].assays[y].mnemonic))
       DETAIL
        14003_cd = c.code_value
       WITH nocounter
      ;end select
      IF (curqual=0)
       SET request_cv->cd_value_list[1].action_flag = 1
       SET request_cv->cd_value_list[1].code_set = 14003
       SET request_cv->cd_value_list[1].display = request->orderables[x].assays[y].mnemonic
       SET request_cv->cd_value_list[1].display_key = cnvtupper(cnvtalphanum(request->orderables[x].
         assays[y].mnemonic))
       SET request_cv->cd_value_list[1].description = request->orderables[x].assays[y].mnemonic
       SET request_cv->cd_value_list[1].definition = request->orderables[x].assays[y].mnemonic
       SET request_cv->cd_value_list[1].active_ind = 1
       SET trace = recpersist
       EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
       IF ((reply_cv->status_data.status="S")
        AND (reply_cv->qual[1].code_value > 0))
        SET 14003_cd = reply_cv->qual[1].code_value
       ELSE
        SET failed = "Y"
        SET reply->error_msg = "Failed to insert code value into code set 14003"
        GO TO exit_script
       ENDIF
       SET ierrcode = 0
       INSERT  FROM discrete_task_assay d
        SET d.task_assay_cd = 14003_cd, d.mnemonic_key_cap = cnvtupper(request->orderables[x].assays[
          y].mnemonic), d.activity_type_cd = rad_cd,
         d.default_result_type_cd = date_cd, d.mnemonic = request->orderables[x].assays[y].mnemonic,
         d.description = request->orderables[x].assays[y].mnemonic,
         d.active_ind = 1, d.updt_cnt = 0, d.updt_dt_tm = cnvtdatetime(curdate,curtime),
         d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->updt_task, d.updt_applctx = reqinfo->
         updt_applctx,
         d.code_set = 0, d.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), d
         .end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
         d.active_status_prsnl_id = reqinfo->updt_id, d.active_status_cd = active_cd, d
         .active_status_dt_tm = cnvtdatetime(curdate,curtime3)
        PLAN (d)
        WITH nocounter
       ;end insert
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET failed = "Y"
        SET reply->error_msg = serrmsg
        GO TO exit_script
       ENDIF
      ENDIF
      SET dta_type_cd = 0.0
      SELECT INTO "nl:"
       FROM discrete_task_assay d
       PLAN (d
        WHERE d.task_assay_cd=14003_cd)
       DETAIL
        dta_type_cd = d.default_result_type_cd
       WITH nocounter
      ;end select
      IF (dta_type_cd=text_cd)
       SET updt_bi = 0
       SELECT INTO "nl:"
        FROM bill_item b
        PLAN (b
         WHERE (b.ext_parent_reference_id=request->orderables[x].code_value)
          AND b.ext_child_reference_id=14003_cd)
        DETAIL
         updt_bi = 1
        WITH nocounter
       ;end select
       IF (updt_bi=1)
        SET ierrcode = 0
        UPDATE  FROM bill_item b
         SET b.updt_cnt = (b.updt_cnt+ 1), b.updt_dt_tm = cnvtdatetime(curdate,curtime), b.updt_id =
          reqinfo->updt_id,
          b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b
          .end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
          b.active_ind = 1, b.active_status_cd = active_cd
         PLAN (b
          WHERE (b.ext_parent_reference_id=request->orderables[x].code_value)
           AND b.ext_child_reference_id=14003_cd)
         WITH nocounter
        ;end update
        SET ierrcode = error(serrmsg,1)
        IF (ierrcode > 0)
         SET failed = "Y"
         SET reply->error_msg = serrmsg
         GO TO exit_script
        ENDIF
       ELSE
        SET ierrcode = 0
        INSERT  FROM bill_item b
         SET b.bill_item_id = seq(bill_item_seq,nextval), b.ext_parent_reference_id = request->
          orderables[x].code_value, b.ext_parent_contributor_cd = ordcat_cd,
          b.ext_child_reference_id = 14003_cd, b.ext_child_contributor_cd = assay_cd, b
          .ext_description = request->orderables[x].assays[y].mnemonic,
          b.ext_owner_cd = rad_cd, b.parent_qual_cd = 0, b.charge_point_cd = 0,
          b.physician_qual_cd = 0, b.calc_type_cd = 0, b.updt_cnt = 0,
          b.updt_dt_tm = cnvtdatetime(curdate,curtime), b.updt_id = reqinfo->updt_id, b.updt_task =
          reqinfo->updt_task,
          b.updt_applctx = reqinfo->updt_applctx, b.beg_effective_dt_tm = cnvtdatetime(curdate,
           curtime3), b.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
          b.active_ind = 1, b.active_status_prsnl_id = reqinfo->updt_id, b.active_status_cd =
          active_cd,
          b.active_status_dt_tm = cnvtdatetime(curdate,curtime3), b.ext_short_desc = substring(1,50,
           request->orderables[x].assays[y].mnemonic), b.ext_parent_entity_name = "CODE_VALUE",
          b.ext_child_entity_name = "CODE_VALUE", b.careset_ind = 0, b.workload_only_ind = 0,
          b.parent_qual_ind = 0, b.misc_ind = 0, b.stats_only_ind = 0,
          b.child_seq = 0, b.num_hits = 0, b.late_chrg_excl_ind = 0,
          b.cost_basis_amt = 0, b.tax_ind = 0
         PLAN (b)
         WITH nocounter
        ;end insert
        SET ierrcode = error(serrmsg,1)
        IF (ierrcode > 0)
         SET failed = "Y"
         SET reply->error_msg = serrmsg
         GO TO exit_script
        ENDIF
       ENDIF
      ENDIF
      IF (dta_type_cd=date_cd)
       SET updt_bi = 0
       SELECT INTO "nl:"
        FROM bill_item b
        PLAN (b
         WHERE (b.ext_parent_reference_id=request->orderables[x].code_value)
          AND b.ext_parent_contributor_cd=ordcat_cd
          AND b.ext_child_reference_id=14003_cd
          AND b.ext_child_contributor_cd=assay_cd)
        DETAIL
         updt_bi = 1
        WITH nocounter
       ;end select
       IF (updt_bi=1)
        SET ierrcode = 0
        UPDATE  FROM bill_item b
         SET b.updt_cnt = (b.updt_cnt+ 1), b.updt_dt_tm = cnvtdatetime(curdate,curtime), b.updt_id =
          reqinfo->updt_id,
          b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b
          .end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
          b.active_ind = 1, b.active_status_cd = active_cd
         PLAN (b
          WHERE (b.ext_parent_reference_id=request->orderables[x].code_value)
           AND b.ext_child_reference_id=14003_cd)
         WITH nocounter
        ;end update
        SET ierrcode = error(serrmsg,1)
        IF (ierrcode > 0)
         SET failed = "Y"
         SET reply->error_msg = serrmsg
         GO TO exit_script
        ENDIF
       ELSE
        SET ierrcode = 0
        INSERT  FROM bill_item b
         SET b.bill_item_id = seq(bill_item_seq,nextval), b.ext_parent_reference_id = request->
          orderables[x].code_value, b.ext_parent_contributor_cd = ordcat_cd,
          b.ext_child_reference_id = 14003_cd, b.ext_child_contributor_cd = assay_cd, b
          .ext_description = request->orderables[x].assays[y].mnemonic,
          b.ext_owner_cd = rad_cd, b.parent_qual_cd = 0, b.charge_point_cd = 0,
          b.physician_qual_cd = 0, b.calc_type_cd = 0, b.updt_cnt = 0,
          b.updt_dt_tm = cnvtdatetime(curdate,curtime), b.updt_id = reqinfo->updt_id, b.updt_task =
          reqinfo->updt_task,
          b.updt_applctx = reqinfo->updt_applctx, b.beg_effective_dt_tm = cnvtdatetime(curdate,
           curtime3), b.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
          b.active_ind = 1, b.active_status_prsnl_id = reqinfo->updt_id, b.active_status_cd =
          active_cd,
          b.active_status_dt_tm = cnvtdatetime(curdate,curtime3), b.ext_short_desc = substring(1,50,
           request->orderables[x].assays[y].mnemonic), b.ext_parent_entity_name = "CODE_VALUE",
          b.ext_child_entity_name = "CODE_VALUE", b.careset_ind = 0, b.workload_only_ind = 0,
          b.parent_qual_ind = 0, b.misc_ind = 0, b.stats_only_ind = 0,
          b.child_seq = 0, b.num_hits = 0, b.late_chrg_excl_ind = 0,
          b.cost_basis_amt = 0, b.tax_ind = 0
         PLAN (b)
         WITH nocounter
        ;end insert
        SET ierrcode = error(serrmsg,1)
        IF (ierrcode > 0)
         SET failed = "Y"
         SET reply->error_msg = serrmsg
         GO TO exit_script
        ENDIF
       ENDIF
       SET updt_bi = 0
       SELECT INTO "nl:"
        FROM bill_item b
        PLAN (b
         WHERE b.ext_parent_reference_id=0
          AND b.ext_parent_contributor_cd=0
          AND b.ext_child_reference_id=14003_cd
          AND b.ext_child_contributor_cd=assay_cd)
        DETAIL
         IF (b.active_ind=0)
          updt_bi = 1
         ENDIF
        WITH nocounter
       ;end select
       IF (curqual=0)
        SET ierrcode = 0
        INSERT  FROM bill_item b
         SET b.bill_item_id = seq(bill_item_seq,nextval), b.ext_parent_reference_id = 0, b
          .ext_parent_contributor_cd = 0,
          b.ext_child_reference_id = 14003_cd, b.ext_child_contributor_cd = assay_cd, b
          .ext_description = request->orderables[x].assays[y].mnemonic,
          b.ext_owner_cd = rad_cd, b.parent_qual_cd = 0, b.charge_point_cd = 0,
          b.physician_qual_cd = 0, b.calc_type_cd = 0, b.updt_cnt = 0,
          b.updt_dt_tm = cnvtdatetime(curdate,curtime), b.updt_id = reqinfo->updt_id, b.updt_task =
          reqinfo->updt_task,
          b.updt_applctx = reqinfo->updt_applctx, b.beg_effective_dt_tm = cnvtdatetime(curdate,
           curtime3), b.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
          b.active_ind = 1, b.active_status_prsnl_id = reqinfo->updt_id, b.active_status_cd =
          active_cd,
          b.active_status_dt_tm = cnvtdatetime(curdate,curtime3), b.ext_short_desc = substring(1,50,
           request->orderables[x].assays[y].mnemonic), b.ext_child_entity_name = "CODE_VALUE",
          b.careset_ind = 0, b.workload_only_ind = 0, b.parent_qual_ind = 0,
          b.misc_ind = 0, b.stats_only_ind = 0, b.child_seq = 0,
          b.num_hits = 0, b.late_chrg_excl_ind = 0, b.cost_basis_amt = 0,
          b.tax_ind = 0
         PLAN (b)
         WITH nocounter
        ;end insert
        SET ierrcode = error(serrmsg,1)
        IF (ierrcode > 0)
         SET failed = "Y"
         SET reply->error_msg = serrmsg
         GO TO exit_script
        ENDIF
       ENDIF
       IF (updt_bi=1)
        SET ierrcode = 0
        UPDATE  FROM bill_item b
         SET b.updt_cnt = (b.updt_cnt+ 1), b.updt_dt_tm = cnvtdatetime(curdate,curtime), b.updt_id =
          reqinfo->updt_id,
          b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b
          .end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
          b.active_ind = 1, b.active_status_cd = active_cd
         PLAN (b
          WHERE b.ext_parent_reference_id=0
           AND b.ext_parent_contributor_cd=0
           AND b.ext_child_reference_id=14003_cd
           AND b.ext_child_contributor_cd=assay_cd)
         WITH nocounter
        ;end update
        SET ierrcode = error(serrmsg,1)
        IF (ierrcode > 0)
         SET failed = "Y"
         SET reply->error_msg = serrmsg
         GO TO exit_script
        ENDIF
       ENDIF
      ENDIF
      SET updt_ptr = 0
      SELECT INTO "nl:"
       FROM profile_task_r p
       PLAN (p
        WHERE (p.catalog_cd=request->orderables[x].code_value)
         AND p.task_assay_cd=14003_cd)
       DETAIL
        updt_ptr = 1
       WITH nocounter
      ;end select
      IF (updt_ptr=0)
       SET ierrcode = 0
       INSERT  FROM profile_task_r p
        SET p.catalog_cd = request->orderables[x].code_value, p.task_assay_cd = 14003_cd, p
         .version_nbr = 0,
         p.group_cd = 0, p.item_type_flag = 0, p.pending_ind = request->orderables[x].assays[y].
         pending_ind,
         p.repeat_ind = 0, p.sequence = request->orderables[x].assays[y].sequence, p.dup_chk_min = 0,
         p.dup_chk_action_cd = 0, p.updt_cnt = 0, p.updt_dt_tm = cnvtdatetime(curdate,curtime),
         p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->
         updt_applctx,
         p.active_ind = 1, p.post_prompt_ind = 0, p.prompt_resource_cd = 0,
         p.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), p.end_effective_dt_tm = cnvtdatetime
         ("31-DEC-2100"), p.active_status_prsnl_id = reqinfo->updt_id,
         p.active_status_cd = active_cd, p.active_status_dt_tm = cnvtdatetime(curdate,curtime3), p
         .reference_task_id = 0,
         p.prompt_long_text_id = 0, p.restrict_display_ind = 0
        PLAN (p)
        WITH nocounter
       ;end insert
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET failed = "Y"
        SET reply->error_msg = serrmsg
        GO TO exit_script
       ENDIF
      ELSE
       SET ierrcode = 0
       UPDATE  FROM profile_task_r p
        SET p.pending_ind = request->orderables[x].assays[y].pending_ind, p.sequence = request->
         orderables[x].assays[y].sequence, p.updt_cnt = (p.updt_cnt+ 1),
         p.updt_dt_tm = cnvtdatetime(curdate,curtime), p.updt_id = reqinfo->updt_id, p.updt_task =
         reqinfo->updt_task,
         p.updt_applctx = reqinfo->updt_applctx, p.active_ind = 1, p.end_effective_dt_tm =
         cnvtdatetime("31-DEC-2100"),
         p.active_status_cd = active_cd
        PLAN (p
         WHERE (p.catalog_cd=request->orderables[x].code_value)
          AND p.task_assay_cd=14003_cd)
        WITH nocounter
       ;end update
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET failed = "Y"
        SET reply->error_msg = serrmsg
        GO TO exit_script
       ENDIF
      ENDIF
     ELSEIF ((request->orderables[x].assays[y].action_flag=2))
      SET 14003_cd = request->orderables[x].assays[y].code_value
      SET request_cv->cd_value_list[1].action_flag = 2
      SET request_cv->cd_value_list[1].code_value = 14003_cd
      SET request_cv->cd_value_list[1].code_set = 14003
      SET request_cv->cd_value_list[1].display = request->orderables[x].assays[y].mnemonic
      SET request_cv->cd_value_list[1].display_key = cnvtupper(cnvtalphanum(request->orderables[x].
        assays[y].mnemonic))
      SET request_cv->cd_value_list[1].description = request->orderables[x].assays[y].mnemonic
      SET request_cv->cd_value_list[1].definition = request->orderables[x].assays[y].mnemonic
      SET request_cv->cd_value_list[1].active_ind = 1
      SET trace = recpersist
      EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
      IF ((reply_cv->status_data.status="S")
       AND (reply_cv->qual[1].code_value > 0))
       SET 14003_cd = reply_cv->qual[1].code_value
      ELSE
       SET failed = "Y"
       SET reply->error_msg = "Failed to update code value on code set 14003"
       GO TO exit_script
      ENDIF
      SET ierrcode = 0
      UPDATE  FROM discrete_task_assay d
       SET d.mnemonic_key_cap = cnvtupper(request->orderables[x].assays[y].mnemonic), d.mnemonic =
        request->orderables[x].assays[y].mnemonic, d.description = request->orderables[x].assays[y].
        mnemonic,
        d.updt_cnt = (d.updt_cnt+ 1), d.updt_dt_tm = cnvtdatetime(curdate,curtime), d.updt_id =
        reqinfo->updt_id,
        d.updt_task = reqinfo->updt_task, d.updt_applctx = reqinfo->updt_applctx
       PLAN (d
        WHERE d.task_assay_cd=14003_cd)
       WITH nocounter
      ;end update
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET failed = "Y"
       SET reply->error_msg = serrmsg
       GO TO exit_script
      ENDIF
      SET ierrcode = 0
      UPDATE  FROM bill_item b
       SET b.ext_description = request->orderables[x].assays[y].mnemonic, b.ext_short_desc =
        substring(1,50,request->orderables[x].assays[y].mnemonic), b.updt_cnt = (b.updt_cnt+ 1),
        b.updt_dt_tm = cnvtdatetime(curdate,curtime), b.updt_id = reqinfo->updt_id, b.updt_task =
        reqinfo->updt_task,
        b.updt_applctx = reqinfo->updt_applctx
       PLAN (b
        WHERE b.ext_child_reference_id=14003_cd)
       WITH nocounter
      ;end update
      SET bi_found = 0
      SELECT INTO "nl:"
       FROM bill_item b
       PLAN (b
        WHERE (b.ext_parent_reference_id=request->orderables[x].code_value)
         AND b.ext_child_reference_id=14003_cd)
       DETAIL
        bi_found = 1
       WITH nocounter
      ;end select
      IF (bi_found=0)
       SET dta_type_cd = 0.0
       SELECT INTO "nl:"
        FROM discrete_task_assay d
        PLAN (d
         WHERE d.task_assay_cd=14003_cd)
        DETAIL
         dta_type_cd = d.default_result_type_cd
        WITH nocounter
       ;end select
       IF (dta_type_cd=text_cd)
        SET ierrcode = 0
        INSERT  FROM bill_item b
         SET b.bill_item_id = seq(bill_item_seq,nextval), b.ext_parent_reference_id = request->
          orderables[x].code_value, b.ext_parent_contributor_cd = ordcat_cd,
          b.ext_child_reference_id = 14003_cd, b.ext_child_contributor_cd = assay_cd, b
          .ext_description = request->orderables[x].assays[y].mnemonic,
          b.ext_owner_cd = rad_cd, b.parent_qual_cd = 0, b.charge_point_cd = 0,
          b.physician_qual_cd = 0, b.calc_type_cd = 0, b.updt_cnt = 0,
          b.updt_dt_tm = cnvtdatetime(curdate,curtime), b.updt_id = reqinfo->updt_id, b.updt_task =
          reqinfo->updt_task,
          b.updt_applctx = reqinfo->updt_applctx, b.beg_effective_dt_tm = cnvtdatetime(curdate,
           curtime3), b.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
          b.active_ind = 1, b.active_status_prsnl_id = reqinfo->updt_id, b.active_status_cd =
          active_cd,
          b.active_status_dt_tm = cnvtdatetime(curdate,curtime3), b.ext_short_desc = substring(1,50,
           request->orderables[x].assays[y].mnemonic), b.ext_parent_entity_name = "CODE_VALUE",
          b.ext_child_entity_name = "CODE_VALUE", b.careset_ind = 0, b.workload_only_ind = 0,
          b.parent_qual_ind = 0, b.misc_ind = 0, b.stats_only_ind = 0,
          b.child_seq = 0, b.num_hits = 0, b.late_chrg_excl_ind = 0,
          b.cost_basis_amt = 0, b.tax_ind = 0
         PLAN (b)
         WITH nocounter
        ;end insert
        SET ierrcode = error(serrmsg,1)
        IF (ierrcode > 0)
         SET failed = "Y"
         SET reply->error_msg = serrmsg
         GO TO exit_script
        ENDIF
       ENDIF
      ENDIF
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET failed = "Y"
       SET reply->error_msg = serrmsg
       GO TO exit_script
      ENDIF
      SET ptr_found = 0
      SELECT INTO "nl:"
       FROM profile_task_r p
       PLAN (p
        WHERE (p.catalog_cd=request->orderables[x].code_value)
         AND p.task_assay_cd=14003_cd)
       DETAIL
        ptr_found = 1
       WITH nocounter
      ;end select
      IF (ptr_found=0)
       SET ierrcode = 0
       INSERT  FROM profile_task_r p
        SET p.catalog_cd = request->orderables[x].code_value, p.task_assay_cd = 14003_cd, p
         .version_nbr = 0,
         p.group_cd = 0, p.item_type_flag = 0, p.pending_ind = request->orderables[x].assays[y].
         pending_ind,
         p.repeat_ind = 0, p.sequence = request->orderables[x].assays[y].sequence, p.dup_chk_min = 0,
         p.dup_chk_action_cd = 0, p.updt_cnt = 0, p.updt_dt_tm = cnvtdatetime(curdate,curtime),
         p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->
         updt_applctx,
         p.active_ind = 1, p.post_prompt_ind = 0, p.prompt_resource_cd = 0,
         p.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), p.end_effective_dt_tm = cnvtdatetime
         ("31-DEC-2100"), p.active_status_prsnl_id = reqinfo->updt_id,
         p.active_status_cd = active_cd, p.active_status_dt_tm = cnvtdatetime(curdate,curtime3), p
         .reference_task_id = 0,
         p.prompt_long_text_id = 0, p.restrict_display_ind = 0
        PLAN (p)
        WITH nocounter
       ;end insert
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET failed = "Y"
        SET reply->error_msg = serrmsg
        GO TO exit_script
       ENDIF
      ELSE
       SET ierrcode = 0
       UPDATE  FROM profile_task_r p
        SET p.pending_ind = request->orderables[x].assays[y].pending_ind, p.sequence = request->
         orderables[x].assays[y].sequence, p.updt_cnt = (p.updt_cnt+ 1),
         p.updt_dt_tm = cnvtdatetime(curdate,curtime), p.updt_id = reqinfo->updt_id, p.updt_task =
         reqinfo->updt_task,
         p.updt_applctx = reqinfo->updt_applctx, p.active_ind = 1, p.end_effective_dt_tm =
         cnvtdatetime("31-DEC-2100"),
         p.active_status_cd = active_cd
        PLAN (p
         WHERE (p.catalog_cd=request->orderables[x].code_value)
          AND p.task_assay_cd=14003_cd)
        WITH nocounter
       ;end update
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET failed = "Y"
        SET reply->error_msg = serrmsg
        GO TO exit_script
       ENDIF
      ENDIF
     ELSEIF ((request->orderables[x].assays[y].action_flag=3))
      SET 14003_cd = request->orderables[x].assays[y].code_value
      SET ierrcode = 0
      UPDATE  FROM profile_task_r p
       SET p.active_ind = 0, p.updt_cnt = (p.updt_cnt+ 1), p.updt_dt_tm = cnvtdatetime(curdate,
         curtime),
        p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->
        updt_applctx
       PLAN (p
        WHERE (p.catalog_cd=request->orderables[x].code_value)
         AND p.task_assay_cd=14003_cd)
       WITH nocounter
      ;end update
      SET ierrcode = 0
      UPDATE  FROM bill_item b
       SET b.active_ind = 0, b.updt_cnt = (b.updt_cnt+ 1), b.updt_dt_tm = cnvtdatetime(curdate,
         curtime),
        b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
        updt_applctx
       PLAN (b
        WHERE (b.ext_parent_reference_id=request->orderables[x].code_value)
         AND b.ext_child_reference_id=14003_cd)
       WITH nocounter
      ;end update
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET failed = "Y"
       SET reply->error_msg = serrmsg
       GO TO exit_script
      ENDIF
     ENDIF
   ENDFOR
  ENDIF
 ENDFOR
#exit_script
 IF (failed="Y")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL echorecord(reply)
END GO
