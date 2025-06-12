CREATE PROGRAM bed_ens_rli_setup:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
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
 DECLARE error_flag = vc WITH private
 DECLARE error_msg = vc WITH private
 DECLARE supplier_flag = i4
 DECLARE supplier_meaning = vc
 DECLARE found = vc
 DECLARE hold_code_value = f8
 DECLARE call_lab_containter = f8
 DECLARE call_lab_coll_class = f8
 SET reply->status_data.status = "F"
 SET error_flag = "F"
 SET found = " "
 SET hold_code_value = 0.0
 SELECT INTO "nl:"
  FROM br_rli_supplier brs
  PLAN (brs
   WHERE (brs.supplier_flag=request->supplier_flag))
  DETAIL
   supplier_flag = brs.supplier_flag, supplier_meaning = brs.supplier_meaning
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET error_flag = "T"
  SET error_msg = concat("Unable to read rli supplier data for supplier flag: ",request->
   supplier_flag)
  SET fatal_err = "Y"
  SET errmsg = error_msg
  CALL logerrormessage(errmsg)
  GO TO exit_script
 ENDIF
 SET call_lab_container = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=2051
    AND cv.display_key="CALLLAB")
  DETAIL
   call_lab_container = cv.code_value
  WITH nocounter
 ;end select
 IF (call_lab_container=0.0)
  SET request_cv->cd_value_list[1].action_flag = 1
  SET request_cv->cd_value_list[1].code_set = 2051
  SET request_cv->cd_value_list[1].display = "Call Lab"
  SET request_cv->cd_value_list[1].display_key = "CALLLAB"
  SET request_cv->cd_value_list[1].description = "Call Lab"
  SET request_cv->cd_value_list[1].cdf_meaning = ""
  SET request_cv->cd_value_list[1].active_ind = 1
  SET trace = recpersist
  EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
  IF ((reply_cv->qual[1].code_value > 0))
   SET hold_code_value = reply_cv->qual[1].code_value
  ELSE
   SET error_msg = "Error creating container for Call Lab (code_value)"
   SET error_flag = "T"
   GO TO exit_script
  ENDIF
  INSERT  FROM specimen_container sc
   SET sc.spec_cntnr_cd = hold_code_value, sc.aliquot_ind = 0, sc.volume_units = null,
    sc.volume_units_cd = 0.0, sc.updt_cnt = 0, sc.updt_dt_tm = cnvtdatetime(curdate,curtime),
    sc.updt_id = reqinfo->updt_id, sc.updt_task = reqinfo->updt_task, sc.updt_applctx = reqinfo->
    updt_applctx
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET error_msg = "Error creating container for Call Lab (specimen container)"
   SET error_flag = "T"
   GO TO exit_script
  ENDIF
 ENDIF
 SET call_lab_coll_class = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=231
    AND cv.display_key="CALLLAB")
  DETAIL
   call_lab_coll_class = cv.code_value
  WITH nocounter
 ;end select
 IF (call_lab_coll_class=0.0)
  SET request_cv->cd_value_list[1].action_flag = 1
  SET request_cv->cd_value_list[1].code_set = 231
  SET request_cv->cd_value_list[1].display = "Call Lab"
  SET request_cv->cd_value_list[1].display_key = "CALLLAB"
  SET request_cv->cd_value_list[1].description = "Call Lab"
  SET request_cv->cd_value_list[1].cdf_meaning = ""
  SET request_cv->cd_value_list[1].active_ind = 1
  SET trace = recpersist
  EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
  IF ((reply_cv->qual[1].code_value > 0))
   SET hold_code_value = reply_cv->qual[1].code_value
  ELSE
   SET error_msg = "Error creating collection class for Call Lab"
   SET error_flag = "T"
   GO TO exit_script
  ENDIF
  INSERT  FROM br_coll_class bcc
   SET bcc.activity_type = "GLB", bcc.collection_class = "Call Lab", bcc.proposed_name_suffix = " ",
    bcc.facility_id = 0.0, bcc.display_name = " ", bcc.storage_tracking_ind = 0,
    bcc.code_value = reply_cv->qual[1].code_value, bcc.updt_cnt = 0, bcc.updt_dt_tm = cnvtdatetime(
     curdate,curtime),
    bcc.updt_id = reqinfo->updt_id, bcc.updt_task = reqinfo->updt_task, bcc.updt_applctx = reqinfo->
    updt_applctx
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET error_msg = "Error adding Call Lab to br_coll_class"
   SET error_flag = "T"
   GO TO exit_script
  ENDIF
  INSERT  FROM collection_class cc
   SET cc.coll_class_cd = hold_code_value, cc.max_class_volume = 10.0, cc.max_class_vol_units = null,
    cc.updt_applctx = reqinfo->updt_applctx, cc.updt_dt_tm = cnvtdatetime(curdate,curtime), cc
    .updt_id = reqinfo->updt_id,
    cc.updt_cnt = 0, cc.updt_task = reqinfo->updt_task, cc.max_accession_size = 12,
    cc.max_class_vol_units_cd = 0.0, cc.def_storage_minutes = 0, cc.symbology = "A",
    cc.smg_barcode_adjust = 0, cc.smg_format = "L", cc.container_id_print = "N",
    cc.transfer_temp_cd = 0.0, cc.storage_temp_cd = 0.0, cc.sequence = 0
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET error_msg = "Error adding Call Lab to collection_class table"
   SET error_flag = "T"
   GO TO exit_script
  ENDIF
 ENDIF
 CASE (supplier_flag)
  OF 1:
   CALL add_arup(supplier_flag)
  OF 2:
   CALL add_mayo(supplier_flag)
  OF 3:
   CALL add_labone(supplier_flag)
  OF 4:
   CALL add_quest(supplier_flag)
  OF 5:
   CALL add_quest(supplier_flag)
  OF 6:
   CALL add_quest(supplier_flag)
  OF 7:
   CALL add_correlagen(supplier_flag)
 ENDCASE
 GO TO exit_script
 SUBROUTINE add_arup(supplier_flag)
   SET found = "N"
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=73
      AND cv.display_key="ARUP")
    DETAIL
     found = "Y"
    WITH nocounter
   ;end select
   IF (found="N")
    SET request_cv->cd_value_list[1].action_flag = 1
    SET request_cv->cd_value_list[1].code_set = 73
    SET request_cv->cd_value_list[1].display = "ARUP RLI"
    SET request_cv->cd_value_list[1].display_key = "ARUPRLI"
    SET request_cv->cd_value_list[1].description = "ARUP RLI"
    SET request_cv->cd_value_list[1].cdf_meaning = ""
    SET request_cv->cd_value_list[1].active_ind = 1
    SET trace = recpersist
    EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
   ENDIF
   SET found = "N"
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=5801
      AND cv.display_key="ARUPRLI"
      AND cv.cdf_meaning="SEND OUT")
    DETAIL
     found = "Y"
    WITH nocounter
   ;end select
   IF (found="N")
    SET request_cv->cd_value_list[1].action_flag = 1
    SET request_cv->cd_value_list[1].code_set = 5801
    SET request_cv->cd_value_list[1].display = "ARUP RLI"
    SET request_cv->cd_value_list[1].display_key = "ARUPRLI"
    SET request_cv->cd_value_list[1].description = "ARUP RLI"
    SET request_cv->cd_value_list[1].cdf_meaning = "SEND OUT"
    SET request_cv->cd_value_list[1].definition = "GLB"
    SET request_cv->cd_value_list[1].active_ind = 1
    SET trace = recpersist
    EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
   ENDIF
   SET found = "N"
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=231
      AND cv.display_key="ARUPSENDOUTSFROZ")
    DETAIL
     found = "Y"
    WITH nocounter
   ;end select
   IF (found="N")
    SET request_cv->cd_value_list[1].action_flag = 1
    SET request_cv->cd_value_list[1].code_set = 231
    SET request_cv->cd_value_list[1].display = "ARUP Send Outs Froz"
    SET request_cv->cd_value_list[1].display_key = "ARUPSENDOUTSFROZ"
    SET request_cv->cd_value_list[1].description = "ARUP Send Outs Froz"
    SET request_cv->cd_value_list[1].cdf_meaning = ""
    SET request_cv->cd_value_list[1].active_ind = 1
    SET trace = recpersist
    EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
    IF ((reply_cv->qual[1].code_value > 0))
     SET hold_code_value = reply_cv->qual[1].code_value
    ELSE
     SET error_msg = "Error creating collection class for ARUP Send Outs Froz"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
    INSERT  FROM br_coll_class bcc
     SET bcc.activity_type = "RLI", bcc.collection_class = "ARUP SO Froz", bcc.proposed_name_suffix
       = " ",
      bcc.facility_id = 0.0, bcc.display_name = " ", bcc.storage_tracking_ind = 0,
      bcc.code_value = hold_code_value, bcc.updt_cnt = 0, bcc.updt_dt_tm = cnvtdatetime(curdate,
       curtime),
      bcc.updt_id = reqinfo->updt_id, bcc.updt_task = reqinfo->updt_task, bcc.updt_applctx = reqinfo
      ->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_msg = "Error adding ARUP SO Froz to br_coll_class"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
    INSERT  FROM collection_class cc
     SET cc.coll_class_cd = hold_code_value, cc.max_class_volume = 10.0, cc.max_class_vol_units =
      null,
      cc.updt_applctx = reqinfo->updt_applctx, cc.updt_dt_tm = cnvtdatetime(curdate,curtime), cc
      .updt_id = reqinfo->updt_id,
      cc.updt_cnt = 0, cc.updt_task = reqinfo->updt_task, cc.max_accession_size = 12,
      cc.max_class_vol_units_cd = 0.0, cc.def_storage_minutes = 0, cc.symbology = "A",
      cc.smg_barcode_adjust = 0, cc.smg_format = "L", cc.container_id_print = "N",
      cc.transfer_temp_cd = 0.0, cc.storage_temp_cd = 0.0, cc.sequence = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_msg = "Error adding ARUP SO Froz to collection_class table"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
   ENDIF
   SET found = "N"
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=231
      AND cv.display_key="ARUPSENDOUTSRMTEMP")
    DETAIL
     found = "Y"
    WITH nocounter
   ;end select
   IF (found="N")
    SET request_cv->cd_value_list[1].action_flag = 1
    SET request_cv->cd_value_list[1].code_set = 231
    SET request_cv->cd_value_list[1].display = "ARUP Send Outs Rm Temp"
    SET request_cv->cd_value_list[1].display_key = "ARUPSENDOUTSRMTEMP"
    SET request_cv->cd_value_list[1].description = "ARUP Send OutsRM Temp"
    SET request_cv->cd_value_list[1].cdf_meaning = ""
    SET request_cv->cd_value_list[1].active_ind = 1
    SET trace = recpersist
    EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
    IF ((reply_cv->qual[1].code_value > 0))
     SET hold_code_value = reply_cv->qual[1].code_value
    ELSE
     SET error_msg = "Error creating collection class for ARUP Send Outs Rm Temp"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
    INSERT  FROM br_coll_class bcc
     SET bcc.activity_type = "RLI", bcc.collection_class = "ARUP SO Rm Temp", bcc
      .proposed_name_suffix = " ",
      bcc.facility_id = 0.0, bcc.display_name = " ", bcc.storage_tracking_ind = 0,
      bcc.code_value = reply_cv->qual[1].code_value, bcc.updt_cnt = 0, bcc.updt_dt_tm = cnvtdatetime(
       curdate,curtime),
      bcc.updt_id = reqinfo->updt_id, bcc.updt_task = reqinfo->updt_task, bcc.updt_applctx = reqinfo
      ->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_msg = "Error adding ARUP SO Rm Temp to br_coll_class"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
    INSERT  FROM collection_class cc
     SET cc.coll_class_cd = hold_code_value, cc.max_class_volume = 10.0, cc.max_class_vol_units =
      null,
      cc.updt_applctx = reqinfo->updt_applctx, cc.updt_dt_tm = cnvtdatetime(curdate,curtime), cc
      .updt_id = reqinfo->updt_id,
      cc.updt_cnt = 0, cc.updt_task = reqinfo->updt_task, cc.max_accession_size = 12,
      cc.max_class_vol_units_cd = 0.0, cc.def_storage_minutes = 0, cc.symbology = "A",
      cc.smg_barcode_adjust = 0, cc.smg_format = "L", cc.container_id_print = "N",
      cc.transfer_temp_cd = 0.0, cc.storage_temp_cd = 0.0, cc.sequence = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_msg = "Error adding ARUP SO Rm Temp to collection_class table"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
   ENDIF
   SET found = "N"
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=231
      AND cv.display_key="ARUPSENDOUTSREFRIG")
    DETAIL
     found = "Y"
    WITH nocounter
   ;end select
   IF (found="N")
    SET request_cv->cd_value_list[1].action_flag = 1
    SET request_cv->cd_value_list[1].code_set = 231
    SET request_cv->cd_value_list[1].display = "ARUP Send Outs Refrig"
    SET request_cv->cd_value_list[1].display_key = "ARUPSENDOUTSREFRIG"
    SET request_cv->cd_value_list[1].description = "ARUP Send Outs Refrig"
    SET request_cv->cd_value_list[1].cdf_meaning = ""
    SET request_cv->cd_value_list[1].active_ind = 1
    SET trace = recpersist
    EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
    IF ((reply_cv->qual[1].code_value > 0))
     SET hold_code_value = reply_cv->qual[1].code_value
    ELSE
     SET error_msg = "Error creating collection class for ARUP Send Outs Refrig"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
    INSERT  FROM br_coll_class bcc
     SET bcc.activity_type = "RLI", bcc.collection_class = "ARUP SO Refrig", bcc.proposed_name_suffix
       = " ",
      bcc.facility_id = 0.0, bcc.display_name = " ", bcc.storage_tracking_ind = 0,
      bcc.code_value = reply_cv->qual[1].code_value, bcc.updt_cnt = 0, bcc.updt_dt_tm = cnvtdatetime(
       curdate,curtime),
      bcc.updt_id = reqinfo->updt_id, bcc.updt_task = reqinfo->updt_task, bcc.updt_applctx = reqinfo
      ->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_msg = "Error adding ARUP SO Refrig to br_coll_class"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
    INSERT  FROM collection_class cc
     SET cc.coll_class_cd = hold_code_value, cc.max_class_volume = 10.0, cc.max_class_vol_units =
      null,
      cc.updt_applctx = reqinfo->updt_applctx, cc.updt_dt_tm = cnvtdatetime(curdate,curtime), cc
      .updt_id = reqinfo->updt_id,
      cc.updt_cnt = 0, cc.updt_task = reqinfo->updt_task, cc.max_accession_size = 12,
      cc.max_class_vol_units_cd = 0.0, cc.def_storage_minutes = 0, cc.symbology = "A",
      cc.smg_barcode_adjust = 0, cc.smg_format = "L", cc.container_id_print = "N",
      cc.transfer_temp_cd = 0.0, cc.storage_temp_cd = 0.0, cc.sequence = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_msg = "Error adding ARUP SO Refrig to collection_class table"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
   ENDIF
   SET found = "N"
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=231
      AND cv.display_key="ARUPSENDOUTS")
    DETAIL
     found = "Y"
    WITH nocounter
   ;end select
   IF (found="N")
    SET request_cv->cd_value_list[1].action_flag = 1
    SET request_cv->cd_value_list[1].code_set = 231
    SET request_cv->cd_value_list[1].display = "ARUP Send Outs"
    SET request_cv->cd_value_list[1].display_key = "ARUPSENDOUTS"
    SET request_cv->cd_value_list[1].description = "ARUP Send Outs"
    SET request_cv->cd_value_list[1].cdf_meaning = ""
    SET request_cv->cd_value_list[1].active_ind = 1
    SET trace = recpersist
    EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
    IF ((reply_cv->qual[1].code_value > 0))
     SET hold_code_value = reply_cv->qual[1].code_value
    ELSE
     SET error_msg = "Error creating collection class for ARUP Send Outs"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
    INSERT  FROM br_coll_class bcc
     SET bcc.activity_type = "RLI", bcc.collection_class = "ARUP SO", bcc.proposed_name_suffix = " ",
      bcc.facility_id = 0.0, bcc.display_name = " ", bcc.storage_tracking_ind = 0,
      bcc.code_value = reply_cv->qual[1].code_value, bcc.updt_cnt = 0, bcc.updt_dt_tm = cnvtdatetime(
       curdate,curtime),
      bcc.updt_id = reqinfo->updt_id, bcc.updt_task = reqinfo->updt_task, bcc.updt_applctx = reqinfo
      ->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_msg = "Error adding ARUP SO to br_coll_class"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
    INSERT  FROM collection_class cc
     SET cc.coll_class_cd = hold_code_value, cc.max_class_volume = 10.0, cc.max_class_vol_units =
      null,
      cc.updt_applctx = reqinfo->updt_applctx, cc.updt_dt_tm = cnvtdatetime(curdate,curtime), cc
      .updt_id = reqinfo->updt_id,
      cc.updt_cnt = 0, cc.updt_task = reqinfo->updt_task, cc.max_accession_size = 12,
      cc.max_class_vol_units_cd = 0.0, cc.def_storage_minutes = 0, cc.symbology = "A",
      cc.smg_barcode_adjust = 0, cc.smg_format = "L", cc.container_id_print = "N",
      cc.transfer_temp_cd = 0.0, cc.storage_temp_cd = 0.0, cc.sequence = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_msg = "Error adding ARUP SO to collection_class table"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE add_mayo(supplier_flag)
   SET found = "N"
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=73
      AND cv.display_key="MAYORLI")
    DETAIL
     found = "Y"
    WITH nocounter
   ;end select
   IF (found="N")
    SET request_cv->cd_value_list[1].action_flag = 1
    SET request_cv->cd_value_list[1].code_set = 73
    SET request_cv->cd_value_list[1].display = "Mayo RLI"
    SET request_cv->cd_value_list[1].display_key = "MAYORLI"
    SET request_cv->cd_value_list[1].description = "Mayo RLI"
    SET request_cv->cd_value_list[1].cdf_meaning = ""
    SET request_cv->cd_value_list[1].active_ind = 1
    SET trace = recpersist
    EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
   ENDIF
   SET found = "N"
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=5801
      AND cv.display_key="MAYORLI"
      AND cv.cdf_meaning="SEND OUT")
    DETAIL
     found = "Y"
    WITH nocounter
   ;end select
   IF (found="N")
    SET request_cv->cd_value_list[1].action_flag = 1
    SET request_cv->cd_value_list[1].code_set = 5801
    SET request_cv->cd_value_list[1].display = "Mayo RLI"
    SET request_cv->cd_value_list[1].display_key = "MAYORLI"
    SET request_cv->cd_value_list[1].description = "Mayo RLI"
    SET request_cv->cd_value_list[1].cdf_meaning = "SEND OUT"
    SET request_cv->cd_value_list[1].definition = "GLB"
    SET request_cv->cd_value_list[1].active_ind = 1
    SET trace = recpersist
    EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
   ENDIF
   SET found = "N"
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=5801
      AND cv.display_key="MAYORLINEWENGLAND"
      AND cv.cdf_meaning="SEND OUT")
    DETAIL
     found = "Y"
    WITH nocounter
   ;end select
   IF (found="N")
    SET request_cv->cd_value_list[1].action_flag = 1
    SET request_cv->cd_value_list[1].code_set = 5801
    SET request_cv->cd_value_list[1].display = "Mayo RLI - New England"
    SET request_cv->cd_value_list[1].display_key = "MAYORLINEWENGLAND"
    SET request_cv->cd_value_list[1].description = "Mayo RLI - New England"
    SET request_cv->cd_value_list[1].cdf_meaning = "SEND OUT"
    SET request_cv->cd_value_list[1].definition = "GLB"
    SET request_cv->cd_value_list[1].active_ind = 1
    SET trace = recpersist
    EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
   ENDIF
   SET found = "N"
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=5801
      AND cv.display_key="MAYORLIROCHESTER"
      AND cv.cdf_meaning="SEND OUT")
    DETAIL
     found = "Y"
    WITH nocounter
   ;end select
   IF (found="N")
    SET request_cv->cd_value_list[1].action_flag = 1
    SET request_cv->cd_value_list[1].code_set = 5801
    SET request_cv->cd_value_list[1].display = "Mayo RLI - Rochester"
    SET request_cv->cd_value_list[1].display_key = "MAYORLIROCHESTER"
    SET request_cv->cd_value_list[1].description = "Mayo RLI - Rochester"
    SET request_cv->cd_value_list[1].cdf_meaning = "SEND OUT"
    SET request_cv->cd_value_list[1].definition = "GLB"
    SET request_cv->cd_value_list[1].active_ind = 1
    SET trace = recpersist
    EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
   ENDIF
   SET found = "N"
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=2056
      AND cv.display_key="MAYOSENDOUT")
    DETAIL
     found = "Y"
    WITH nocounter
   ;end select
   IF (found="N")
    SET request_cv->cd_value_list[1].action_flag = 1
    SET request_cv->cd_value_list[1].code_set = 2056
    SET request_cv->cd_value_list[1].display = "Mayo Send Out"
    SET request_cv->cd_value_list[1].display_key = "MAYOSENDOUT"
    SET request_cv->cd_value_list[1].description = "Mayo Send Out"
    SET request_cv->cd_value_list[1].cdf_meaning = ""
    SET request_cv->cd_value_list[1].active_ind = 1
    SET trace = recpersist
    EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
    IF ((reply_cv->qual[1].code_value > 0))
     SET hold_code_value = reply_cv->qual[1].code_value
    ELSE
     SET error_msg = "Error creating accession class for Mayo Send Out"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
    INSERT  FROM accession_class ac
     SET ac.accession_class_cd = hold_code_value, ac.accession_format_cd = 0.0, ac.updt_applctx =
      reqinfo->updt_applctx,
      ac.updt_dt_tm = cnvtdatetime(curdate,curtime), ac.updt_id = reqinfo->updt_id, ac.updt_cnt = 0,
      ac.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_msg = "Error adding MAYO Send Out to accession_class table"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
   ENDIF
   SET found = "N"
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=2052
      AND cv.display_key="MAYOREVIEW")
    DETAIL
     found = "Y"
    WITH nocounter
   ;end select
   IF (found="N")
    SET request_cv->cd_value_list[1].action_flag = 1
    SET request_cv->cd_value_list[1].code_set = 2052
    SET request_cv->cd_value_list[1].display = "Mayo Review"
    SET request_cv->cd_value_list[1].display_key = "MAYOREVIEW"
    SET request_cv->cd_value_list[1].description = "Mayo Review"
    SET request_cv->cd_value_list[1].cdf_meaning = ""
    SET request_cv->cd_value_list[1].active_ind = 1
    SET trace = recpersist
    EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
    IF ((reply_cv->qual[1].code_value > 0))
     SET hold_code_value = reply_cv->qual[1].code_value
    ELSE
     SET error_msg = "Error creating specimen type for Mayo Review"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
   ENDIF
   SET found = "N"
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=231
      AND cv.display_key="MAYONESENDOUTSFROZ")
    DETAIL
     found = "Y"
    WITH nocounter
   ;end select
   IF (found="N")
    SET request_cv->cd_value_list[1].action_flag = 1
    SET request_cv->cd_value_list[1].code_set = 231
    SET request_cv->cd_value_list[1].display = "Mayo NE Send Outs Froz"
    SET request_cv->cd_value_list[1].display_key = "MAYONESENDOUTSFROZ"
    SET request_cv->cd_value_list[1].description = "Mayo NE Send Outs Froz"
    SET request_cv->cd_value_list[1].cdf_meaning = ""
    SET request_cv->cd_value_list[1].active_ind = 1
    SET trace = recpersist
    EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
    IF ((reply_cv->qual[1].code_value > 0))
     SET hold_code_value = reply_cv->qual[1].code_value
    ELSE
     SET error_msg = "Error creating collection class for Mayo NE Send Outs Refrig"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
    INSERT  FROM br_coll_class bcc
     SET bcc.activity_type = "RLI", bcc.collection_class = "Mayo NE SO Froz", bcc
      .proposed_name_suffix = " ",
      bcc.facility_id = 0.0, bcc.display_name = " ", bcc.storage_tracking_ind = 0,
      bcc.code_value = reply_cv->qual[1].code_value, bcc.updt_cnt = 0, bcc.updt_dt_tm = cnvtdatetime(
       curdate,curtime),
      bcc.updt_id = reqinfo->updt_id, bcc.updt_task = reqinfo->updt_task, bcc.updt_applctx = reqinfo
      ->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_msg = "Error adding MAYO NE SO Frozen to br_coll_class"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
    INSERT  FROM collection_class cc
     SET cc.coll_class_cd = hold_code_value, cc.max_class_volume = 10.0, cc.max_class_vol_units =
      null,
      cc.updt_applctx = reqinfo->updt_applctx, cc.updt_dt_tm = cnvtdatetime(curdate,curtime), cc
      .updt_id = reqinfo->updt_id,
      cc.updt_cnt = 0, cc.updt_task = reqinfo->updt_task, cc.max_accession_size = 12,
      cc.max_class_vol_units_cd = 0.0, cc.def_storage_minutes = 0, cc.symbology = "A",
      cc.smg_barcode_adjust = 0, cc.smg_format = "L", cc.container_id_print = "N",
      cc.transfer_temp_cd = 0.0, cc.storage_temp_cd = 0.0, cc.sequence = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_msg = "Error adding MAYO NE SO Frozen to collection_class table"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
   ENDIF
   SET found = "N"
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=231
      AND cv.display_key="MAYONESENDOUTSRMTEMP")
    DETAIL
     found = "Y"
    WITH nocounter
   ;end select
   IF (found="N")
    SET request_cv->cd_value_list[1].action_flag = 1
    SET request_cv->cd_value_list[1].code_set = 231
    SET request_cv->cd_value_list[1].display = "Mayo NE Send Outs Rm Temp"
    SET request_cv->cd_value_list[1].display_key = "MAYONESENDOUTSRMTEMP"
    SET request_cv->cd_value_list[1].description = "Mayo NE Send Outs RM Temp"
    SET request_cv->cd_value_list[1].cdf_meaning = ""
    SET request_cv->cd_value_list[1].active_ind = 1
    SET trace = recpersist
    EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
    IF ((reply_cv->qual[1].code_value > 0))
     SET hold_code_value = reply_cv->qual[1].code_value
    ELSE
     SET error_msg = "Error creating collection class for Mayo Send Outs Rm Temp"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
    INSERT  FROM br_coll_class bcc
     SET bcc.activity_type = "RLI", bcc.collection_class = "Mayo NE SO Rm Temp", bcc
      .proposed_name_suffix = " ",
      bcc.facility_id = 0.0, bcc.display_name = " ", bcc.storage_tracking_ind = 0,
      bcc.code_value = reply_cv->qual[1].code_value, bcc.updt_cnt = 0, bcc.updt_dt_tm = cnvtdatetime(
       curdate,curtime),
      bcc.updt_id = reqinfo->updt_id, bcc.updt_task = reqinfo->updt_task, bcc.updt_applctx = reqinfo
      ->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_msg = "Error adding MAYO NE SO Rm Temp to br_coll_class"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
    INSERT  FROM collection_class cc
     SET cc.coll_class_cd = hold_code_value, cc.max_class_volume = 10.0, cc.max_class_vol_units =
      null,
      cc.updt_applctx = reqinfo->updt_applctx, cc.updt_dt_tm = cnvtdatetime(curdate,curtime), cc
      .updt_id = reqinfo->updt_id,
      cc.updt_cnt = 0, cc.updt_task = reqinfo->updt_task, cc.max_accession_size = 12,
      cc.max_class_vol_units_cd = 0.0, cc.def_storage_minutes = 0, cc.symbology = "A",
      cc.smg_barcode_adjust = 0, cc.smg_format = "L", cc.container_id_print = "N",
      cc.transfer_temp_cd = 0.0, cc.storage_temp_cd = 0.0, cc.sequence = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_msg = "Error adding MAYO NE SE Rm Temp to collection_class table"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
   ENDIF
   SET found = "N"
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=231
      AND cv.display_key="MAYONESENDOUTSREFRIG")
    DETAIL
     found = "Y"
    WITH nocounter
   ;end select
   IF (found="N")
    SET request_cv->cd_value_list[1].action_flag = 1
    SET request_cv->cd_value_list[1].code_set = 231
    SET request_cv->cd_value_list[1].display = "Mayo NE Send Outs Refrig"
    SET request_cv->cd_value_list[1].display_key = "MAYONESENDOUTSREFRIG"
    SET request_cv->cd_value_list[1].description = "Mayo NE Send Outs Refrig"
    SET request_cv->cd_value_list[1].cdf_meaning = ""
    SET request_cv->cd_value_list[1].active_ind = 1
    SET trace = recpersist
    EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
    IF ((reply_cv->qual[1].code_value > 0))
     SET hold_code_value = reply_cv->qual[1].code_value
    ELSE
     SET error_msg = "Error creating collection class for Mayo NE Send Outs Refrig"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
    INSERT  FROM br_coll_class bcc
     SET bcc.activity_type = "RLI", bcc.collection_class = "Mayo NE SO Refrig", bcc
      .proposed_name_suffix = " ",
      bcc.facility_id = 0.0, bcc.display_name = " ", bcc.storage_tracking_ind = 0,
      bcc.code_value = reply_cv->qual[1].code_value, bcc.updt_cnt = 0, bcc.updt_dt_tm = cnvtdatetime(
       curdate,curtime),
      bcc.updt_id = reqinfo->updt_id, bcc.updt_task = reqinfo->updt_task, bcc.updt_applctx = reqinfo
      ->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_msg = "Error adding MAYO NE SO Refrig to br_coll_class"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
    INSERT  FROM collection_class cc
     SET cc.coll_class_cd = hold_code_value, cc.max_class_volume = 10.0, cc.max_class_vol_units =
      null,
      cc.updt_applctx = reqinfo->updt_applctx, cc.updt_dt_tm = cnvtdatetime(curdate,curtime), cc
      .updt_id = reqinfo->updt_id,
      cc.updt_cnt = 0, cc.updt_task = reqinfo->updt_task, cc.max_accession_size = 12,
      cc.max_class_vol_units_cd = 0.0, cc.def_storage_minutes = 0, cc.symbology = "A",
      cc.smg_barcode_adjust = 0, cc.smg_format = "L", cc.container_id_print = "N",
      cc.transfer_temp_cd = 0.0, cc.storage_temp_cd = 0.0, cc.sequence = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_msg = "Error adding MAYO NE SO Refrig to collection_class table"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
   ENDIF
   SET found = "N"
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=231
      AND cv.display_key="MAYONESENDOUTS")
    DETAIL
     found = "Y"
    WITH nocounter
   ;end select
   IF (found="N")
    SET request_cv->cd_value_list[1].action_flag = 1
    SET request_cv->cd_value_list[1].code_set = 231
    SET request_cv->cd_value_list[1].display = "Mayo NE Send Outs"
    SET request_cv->cd_value_list[1].display_key = "MAYONESENDOUTS"
    SET request_cv->cd_value_list[1].description = "Mayo NE Send Outs"
    SET request_cv->cd_value_list[1].cdf_meaning = ""
    SET request_cv->cd_value_list[1].active_ind = 1
    SET trace = recpersist
    EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
    IF ((reply_cv->qual[1].code_value > 0))
     SET hold_code_value = reply_cv->qual[1].code_value
    ELSE
     SET error_msg = "Error creating collection class for Mayo NE Send Outs"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
    INSERT  FROM br_coll_class bcc
     SET bcc.activity_type = "RLI", bcc.collection_class = "Mayo NE SO", bcc.proposed_name_suffix =
      " ",
      bcc.facility_id = 0.0, bcc.display_name = " ", bcc.storage_tracking_ind = 0,
      bcc.code_value = reply_cv->qual[1].code_value, bcc.updt_cnt = 0, bcc.updt_dt_tm = cnvtdatetime(
       curdate,curtime),
      bcc.updt_id = reqinfo->updt_id, bcc.updt_task = reqinfo->updt_task, bcc.updt_applctx = reqinfo
      ->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_msg = "Error adding Mayo NE SO to br_coll_class"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
    INSERT  FROM collection_class cc
     SET cc.coll_class_cd = hold_code_value, cc.max_class_volume = 10.0, cc.max_class_vol_units =
      null,
      cc.updt_applctx = reqinfo->updt_applctx, cc.updt_dt_tm = cnvtdatetime(curdate,curtime), cc
      .updt_id = reqinfo->updt_id,
      cc.updt_cnt = 0, cc.updt_task = reqinfo->updt_task, cc.max_accession_size = 12,
      cc.max_class_vol_units_cd = 0.0, cc.def_storage_minutes = 0, cc.symbology = "A",
      cc.smg_barcode_adjust = 0, cc.smg_format = "L", cc.container_id_print = "N",
      cc.transfer_temp_cd = 0.0, cc.storage_temp_cd = 0.0, cc.sequence = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_msg = "Error adding MAYO NE SO to collection_class table"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
   ENDIF
   SET found = "N"
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=231
      AND cv.display_key="MAYOROCHSENDOUTSFROZ")
    DETAIL
     found = "Y"
    WITH nocounter
   ;end select
   IF (found="N")
    SET request_cv->cd_value_list[1].action_flag = 1
    SET request_cv->cd_value_list[1].code_set = 231
    SET request_cv->cd_value_list[1].display = "Mayo Roch Send Outs Froz"
    SET request_cv->cd_value_list[1].display_key = "MAYOROCHSENDOUTSFROZ"
    SET request_cv->cd_value_list[1].description = "Mayo Roch Send Outs Froz"
    SET request_cv->cd_value_list[1].cdf_meaning = ""
    SET request_cv->cd_value_list[1].active_ind = 1
    SET trace = recpersist
    EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
    IF ((reply_cv->qual[1].code_value > 0))
     SET hold_code_value = reply_cv->qual[1].code_value
    ELSE
     SET error_msg = "Error creating collection class for Mayo Roch Send Outs Froz"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
    INSERT  FROM br_coll_class bcc
     SET bcc.activity_type = "RLI", bcc.collection_class = "Mayo Roch SO Froz", bcc
      .proposed_name_suffix = " ",
      bcc.facility_id = 0.0, bcc.display_name = " ", bcc.storage_tracking_ind = 0,
      bcc.code_value = reply_cv->qual[1].code_value, bcc.updt_cnt = 0, bcc.updt_dt_tm = cnvtdatetime(
       curdate,curtime),
      bcc.updt_id = reqinfo->updt_id, bcc.updt_task = reqinfo->updt_task, bcc.updt_applctx = reqinfo
      ->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_msg = "Error adding Mayo Roch SO Froz to br_coll_class"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
    INSERT  FROM collection_class cc
     SET cc.coll_class_cd = hold_code_value, cc.max_class_volume = 10.0, cc.max_class_vol_units =
      null,
      cc.updt_applctx = reqinfo->updt_applctx, cc.updt_dt_tm = cnvtdatetime(curdate,curtime), cc
      .updt_id = reqinfo->updt_id,
      cc.updt_cnt = 0, cc.updt_task = reqinfo->updt_task, cc.max_accession_size = 12,
      cc.max_class_vol_units_cd = 0.0, cc.def_storage_minutes = 0, cc.symbology = "A",
      cc.smg_barcode_adjust = 0, cc.smg_format = "L", cc.container_id_print = "N",
      cc.transfer_temp_cd = 0.0, cc.storage_temp_cd = 0.0, cc.sequence = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_msg = "Error adding Mayo SO Refrig to collection_class table"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
   ENDIF
   SET found = "N"
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=231
      AND cv.display_key="MAYOROCHSENDOUTSRMTEMP")
    DETAIL
     found = "Y"
    WITH nocounter
   ;end select
   IF (found="N")
    SET request_cv->cd_value_list[1].action_flag = 1
    SET request_cv->cd_value_list[1].code_set = 231
    SET request_cv->cd_value_list[1].display = "Mayo Roch Send Outs Rm Temp"
    SET request_cv->cd_value_list[1].display_key = "MAYOROCHSENDOUTSRMTEMP"
    SET request_cv->cd_value_list[1].description = "Mayo Roch Send OutsRM Temp"
    SET request_cv->cd_value_list[1].cdf_meaning = ""
    SET request_cv->cd_value_list[1].active_ind = 1
    SET trace = recpersist
    EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
    IF ((reply_cv->qual[1].code_value > 0))
     SET hold_code_value = reply_cv->qual[1].code_value
    ELSE
     SET error_msg = "Error creating collection class for Mayo Roch Send Outs Rm Temp"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
    INSERT  FROM br_coll_class bcc
     SET bcc.activity_type = "RLI", bcc.collection_class = "Mayo Roch SO Rm Temp", bcc
      .proposed_name_suffix = " ",
      bcc.facility_id = 0.0, bcc.display_name = " ", bcc.storage_tracking_ind = 0,
      bcc.code_value = reply_cv->qual[1].code_value, bcc.updt_cnt = 0, bcc.updt_dt_tm = cnvtdatetime(
       curdate,curtime),
      bcc.updt_id = reqinfo->updt_id, bcc.updt_task = reqinfo->updt_task, bcc.updt_applctx = reqinfo
      ->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_msg = "Error adding Mayo Roch SO Rm Temp to br_coll_class"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
    INSERT  FROM collection_class cc
     SET cc.coll_class_cd = hold_code_value, cc.max_class_volume = 10.0, cc.max_class_vol_units =
      null,
      cc.updt_applctx = reqinfo->updt_applctx, cc.updt_dt_tm = cnvtdatetime(curdate,curtime), cc
      .updt_id = reqinfo->updt_id,
      cc.updt_cnt = 0, cc.updt_task = reqinfo->updt_task, cc.max_accession_size = 12,
      cc.max_class_vol_units_cd = 0.0, cc.def_storage_minutes = 0, cc.symbology = "A",
      cc.smg_barcode_adjust = 0, cc.smg_format = "L", cc.container_id_print = "N",
      cc.transfer_temp_cd = 0.0, cc.storage_temp_cd = 0.0, cc.sequence = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_msg = "Error adding MAYO Roch SO Rm Temp to collection_class table"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
   ENDIF
   SET found = "N"
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=231
      AND cv.display_key="MAYOROCHSENDOUTSREFRIG")
    DETAIL
     found = "Y"
    WITH nocounter
   ;end select
   IF (found="N")
    SET request_cv->cd_value_list[1].action_flag = 1
    SET request_cv->cd_value_list[1].code_set = 231
    SET request_cv->cd_value_list[1].display = "Mayo Roch Send Outs Refrig"
    SET request_cv->cd_value_list[1].display_key = "MAYOROCHSENDOUTSREFRIG"
    SET request_cv->cd_value_list[1].description = "Mayo Roch Send Outs Refrig"
    SET request_cv->cd_value_list[1].cdf_meaning = ""
    SET request_cv->cd_value_list[1].active_ind = 1
    SET trace = recpersist
    EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
    IF ((reply_cv->qual[1].code_value > 0))
     SET hold_code_value = reply_cv->qual[1].code_value
    ELSE
     SET error_msg = "Error creating collection class for Mayo Roch Send Outs Refrig"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
    INSERT  FROM br_coll_class bcc
     SET bcc.activity_type = "RLI", bcc.collection_class = "Mayo Roch SO Refrig", bcc
      .proposed_name_suffix = " ",
      bcc.facility_id = 0.0, bcc.display_name = " ", bcc.storage_tracking_ind = 0,
      bcc.code_value = reply_cv->qual[1].code_value, bcc.updt_cnt = 0, bcc.updt_dt_tm = cnvtdatetime(
       curdate,curtime),
      bcc.updt_id = reqinfo->updt_id, bcc.updt_task = reqinfo->updt_task, bcc.updt_applctx = reqinfo
      ->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_msg = "Error adding Mayo Roch SO Refrig to br_coll_class"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
    INSERT  FROM collection_class cc
     SET cc.coll_class_cd = hold_code_value, cc.max_class_volume = 10.0, cc.max_class_vol_units =
      null,
      cc.updt_applctx = reqinfo->updt_applctx, cc.updt_dt_tm = cnvtdatetime(curdate,curtime), cc
      .updt_id = reqinfo->updt_id,
      cc.updt_cnt = 0, cc.updt_task = reqinfo->updt_task, cc.max_accession_size = 12,
      cc.max_class_vol_units_cd = 0.0, cc.def_storage_minutes = 0, cc.symbology = "A",
      cc.smg_barcode_adjust = 0, cc.smg_format = "L", cc.container_id_print = "N",
      cc.transfer_temp_cd = 0.0, cc.storage_temp_cd = 0.0, cc.sequence = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_msg = "Error adding MAYO Roch SO Refrig to collection_class table"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
   ENDIF
   SET found = "N"
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=231
      AND cv.display_key="MAYOROCHSENDOUTS")
    DETAIL
     found = "Y"
    WITH nocounter
   ;end select
   IF (found="N")
    SET request_cv->cd_value_list[1].action_flag = 1
    SET request_cv->cd_value_list[1].code_set = 231
    SET request_cv->cd_value_list[1].display = "Mayo Roch Send Outs"
    SET request_cv->cd_value_list[1].display_key = "MAYOROCHSENDOUTS"
    SET request_cv->cd_value_list[1].description = "Mayo Roch Send Outs"
    SET request_cv->cd_value_list[1].cdf_meaning = ""
    SET request_cv->cd_value_list[1].active_ind = 1
    SET trace = recpersist
    EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
    IF ((reply_cv->qual[1].code_value > 0))
     SET hold_code_value = reply_cv->qual[1].code_value
    ELSE
     SET error_msg = "Error creating collection class for Mayo Roch Send Outs"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
    INSERT  FROM br_coll_class bcc
     SET bcc.activity_type = "RLI", bcc.collection_class = "Mayo Roch SO", bcc.proposed_name_suffix
       = " ",
      bcc.facility_id = 0.0, bcc.display_name = " ", bcc.storage_tracking_ind = 0,
      bcc.code_value = reply_cv->qual[1].code_value, bcc.updt_cnt = 0, bcc.updt_dt_tm = cnvtdatetime(
       curdate,curtime),
      bcc.updt_id = reqinfo->updt_id, bcc.updt_task = reqinfo->updt_task, bcc.updt_applctx = reqinfo
      ->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_msg = "Error adding Mayo Roch SO to br_coll_class"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
    INSERT  FROM collection_class cc
     SET cc.coll_class_cd = hold_code_value, cc.max_class_volume = 10.0, cc.max_class_vol_units =
      null,
      cc.updt_applctx = reqinfo->updt_applctx, cc.updt_dt_tm = cnvtdatetime(curdate,curtime), cc
      .updt_id = reqinfo->updt_id,
      cc.updt_cnt = 0, cc.updt_task = reqinfo->updt_task, cc.max_accession_size = 12,
      cc.max_class_vol_units_cd = 0.0, cc.def_storage_minutes = 0, cc.symbology = "A",
      cc.smg_barcode_adjust = 0, cc.smg_format = "L", cc.container_id_print = "N",
      cc.transfer_temp_cd = 0.0, cc.storage_temp_cd = 0.0, cc.sequence = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_msg = "Error adding MAYO Roch SO to collection_class table"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE add_labone(supplier_flag)
   SET found = "N"
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=73
      AND cv.display_key="LABONERLI")
    DETAIL
     found = "Y"
    WITH nocounter
   ;end select
   IF (found="N")
    SET request_cv->cd_value_list[1].action_flag = 1
    SET request_cv->cd_value_list[1].code_set = 73
    SET request_cv->cd_value_list[1].display = "LabOne RLI"
    SET request_cv->cd_value_list[1].display_key = "LABONERLI"
    SET request_cv->cd_value_list[1].description = "LabOne RLI"
    SET request_cv->cd_value_list[1].cdf_meaning = ""
    SET request_cv->cd_value_list[1].active_ind = 1
    SET trace = recpersist
    EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
   ENDIF
   SET found = "N"
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=5801
      AND cv.display_key="LABONERLI"
      AND cv.cdf_meaning="SEND OUT")
    DETAIL
     found = "Y"
    WITH nocounter
   ;end select
   IF (found="N")
    SET request_cv->cd_value_list[1].action_flag = 1
    SET request_cv->cd_value_list[1].code_set = 5801
    SET request_cv->cd_value_list[1].display = "LabOne RLI"
    SET request_cv->cd_value_list[1].display_key = "LABONERLI"
    SET request_cv->cd_value_list[1].description = "LabOne RLI"
    SET request_cv->cd_value_list[1].cdf_meaning = "SEND OUT"
    SET request_cv->cd_value_list[1].definition = "GLB"
    SET request_cv->cd_value_list[1].active_ind = 1
    SET trace = recpersist
    EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
   ENDIF
   SET found = "N"
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=231
      AND cv.display_key="LABONESENDOUTSFROZ")
    DETAIL
     found = "Y"
    WITH nocounter
   ;end select
   IF (found="N")
    SET request_cv->cd_value_list[1].action_flag = 1
    SET request_cv->cd_value_list[1].code_set = 231
    SET request_cv->cd_value_list[1].display = "LabOne Send Outs Froz"
    SET request_cv->cd_value_list[1].display_key = "LABONESENDOUTSFROZ"
    SET request_cv->cd_value_list[1].description = "LabOne Send Outs Froz"
    SET request_cv->cd_value_list[1].cdf_meaning = ""
    SET request_cv->cd_value_list[1].active_ind = 1
    SET trace = recpersist
    EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
    IF ((reply_cv->qual[1].code_value > 0))
     SET hold_code_value = reply_cv->qual[1].code_value
    ELSE
     SET error_msg = "Error creating collection class for LabOne Send Outs Froz"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
    CALL echo(build("hold_code_value = ",hold_code_value))
    INSERT  FROM br_coll_class bcc
     SET bcc.activity_type = "RLI", bcc.collection_class = "LabOne SO Froz", bcc.proposed_name_suffix
       = " ",
      bcc.facility_id = 0.0, bcc.display_name = " ", bcc.storage_tracking_ind = 0,
      bcc.code_value = reply_cv->qual[1].code_value, bcc.updt_cnt = 0, bcc.updt_dt_tm = cnvtdatetime(
       curdate,curtime),
      bcc.updt_id = reqinfo->updt_id, bcc.updt_task = reqinfo->updt_task, bcc.updt_applctx = reqinfo
      ->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_msg = "Error adding LabOne SO Froz to br_coll_class"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
    INSERT  FROM collection_class cc
     SET cc.coll_class_cd = hold_code_value, cc.max_class_volume = 10.0, cc.max_class_vol_units =
      null,
      cc.updt_applctx = reqinfo->updt_applctx, cc.updt_dt_tm = cnvtdatetime(curdate,curtime), cc
      .updt_id = reqinfo->updt_id,
      cc.updt_cnt = 0, cc.updt_task = reqinfo->updt_task, cc.max_accession_size = 12,
      cc.max_class_vol_units_cd = 0.0, cc.def_storage_minutes = 0, cc.symbology = "A",
      cc.smg_barcode_adjust = 0, cc.smg_format = "L", cc.container_id_print = "N",
      cc.transfer_temp_cd = 0.0, cc.storage_temp_cd = 0.0, cc.sequence = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_msg = "Error adding LabOne SO Refrig to collection_class table"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
   ENDIF
   SET found = "N"
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=231
      AND cv.display_key="LABONESENDOUTSRMTEMP")
    DETAIL
     found = "Y"
    WITH nocounter
   ;end select
   IF (found="N")
    SET request_cv->cd_value_list[1].action_flag = 1
    SET request_cv->cd_value_list[1].code_set = 231
    SET request_cv->cd_value_list[1].display = "LabOne Send Outs Rm Temp"
    SET request_cv->cd_value_list[1].display_key = "LABONESENDOUTSRMTEMP"
    SET request_cv->cd_value_list[1].description = "LabOne Send OutsRM Temp"
    SET request_cv->cd_value_list[1].cdf_meaning = ""
    SET request_cv->cd_value_list[1].active_ind = 1
    SET trace = recpersist
    EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
    IF ((reply_cv->qual[1].code_value > 0))
     SET hold_code_value = reply_cv->qual[1].code_value
    ELSE
     SET error_msg = "Error creating collection class for LabOne Send Outs Rm Temp"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
    CALL echo(build("hold_code_value = ",hold_code_value))
    INSERT  FROM br_coll_class bcc
     SET bcc.activity_type = "RLI", bcc.collection_class = "LabOne SO Rm Temp", bcc
      .proposed_name_suffix = " ",
      bcc.facility_id = 0.0, bcc.display_name = " ", bcc.storage_tracking_ind = 0,
      bcc.code_value = reply_cv->qual[1].code_value, bcc.updt_cnt = 0, bcc.updt_dt_tm = cnvtdatetime(
       curdate,curtime),
      bcc.updt_id = reqinfo->updt_id, bcc.updt_task = reqinfo->updt_task, bcc.updt_applctx = reqinfo
      ->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_msg = "Error adding LabOne SO Rm Temp to br_coll_class"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
    INSERT  FROM collection_class cc
     SET cc.coll_class_cd = hold_code_value, cc.max_class_volume = 10.0, cc.max_class_vol_units =
      null,
      cc.updt_applctx = reqinfo->updt_applctx, cc.updt_dt_tm = cnvtdatetime(curdate,curtime), cc
      .updt_id = reqinfo->updt_id,
      cc.updt_cnt = 0, cc.updt_task = reqinfo->updt_task, cc.max_accession_size = 12,
      cc.max_class_vol_units_cd = 0.0, cc.def_storage_minutes = 0, cc.symbology = "A",
      cc.smg_barcode_adjust = 0, cc.smg_format = "L", cc.container_id_print = "N",
      cc.transfer_temp_cd = 0.0, cc.storage_temp_cd = 0.0, cc.sequence = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_msg = "Error adding LabOne SO Rm Temp to collection_class table"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
   ENDIF
   SET found = "N"
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=231
      AND cv.display_key="LABONESENDOUTSREFRIG")
    DETAIL
     found = "Y"
    WITH nocounter
   ;end select
   IF (found="N")
    SET request_cv->cd_value_list[1].action_flag = 1
    SET request_cv->cd_value_list[1].code_set = 231
    SET request_cv->cd_value_list[1].display = "LabOne Send Outs Refrig"
    SET request_cv->cd_value_list[1].display_key = "LABONESENDOUTSREFRIG"
    SET request_cv->cd_value_list[1].description = "LabOne Send Outs Refrig"
    SET request_cv->cd_value_list[1].cdf_meaning = ""
    SET request_cv->cd_value_list[1].active_ind = 1
    SET trace = recpersist
    EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
    IF ((reply_cv->qual[1].code_value > 0))
     SET hold_code_value = reply_cv->qual[1].code_value
    ELSE
     SET error_msg = "Error creating collection class for LabOne Send Outs Refrig"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
    CALL echo(build("hold_code_value = ",hold_code_value))
    INSERT  FROM br_coll_class bcc
     SET bcc.activity_type = "RLI", bcc.collection_class = "LabOne SO Refrig", bcc
      .proposed_name_suffix = " ",
      bcc.facility_id = 0.0, bcc.display_name = " ", bcc.storage_tracking_ind = 0,
      bcc.code_value = reply_cv->qual[1].code_value, bcc.updt_cnt = 0, bcc.updt_dt_tm = cnvtdatetime(
       curdate,curtime),
      bcc.updt_id = reqinfo->updt_id, bcc.updt_task = reqinfo->updt_task, bcc.updt_applctx = reqinfo
      ->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_msg = "Error adding LabOne SO Refrig to br_coll_class"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
    INSERT  FROM collection_class cc
     SET cc.coll_class_cd = hold_code_value, cc.max_class_volume = 10.0, cc.max_class_vol_units =
      null,
      cc.updt_applctx = reqinfo->updt_applctx, cc.updt_dt_tm = cnvtdatetime(curdate,curtime), cc
      .updt_id = reqinfo->updt_id,
      cc.updt_cnt = 0, cc.updt_task = reqinfo->updt_task, cc.max_accession_size = 12,
      cc.max_class_vol_units_cd = 0.0, cc.def_storage_minutes = 0, cc.symbology = "A",
      cc.smg_barcode_adjust = 0, cc.smg_format = "L", cc.container_id_print = "N",
      cc.transfer_temp_cd = 0.0, cc.storage_temp_cd = 0.0, cc.sequence = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_msg = "Error adding LabOne SO Refrig to collection_class table"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
   ENDIF
   SET found = "N"
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=231
      AND cv.display_key="LABONESENDOUTS")
    DETAIL
     found = "Y"
    WITH nocounter
   ;end select
   IF (found="N")
    SET request_cv->cd_value_list[1].action_flag = 1
    SET request_cv->cd_value_list[1].code_set = 231
    SET request_cv->cd_value_list[1].display = "LabOne Send Outs"
    SET request_cv->cd_value_list[1].display_key = "LABONESENDOUTS"
    SET request_cv->cd_value_list[1].description = "LabOne Send Outs"
    SET request_cv->cd_value_list[1].cdf_meaning = ""
    SET request_cv->cd_value_list[1].active_ind = 1
    SET trace = recpersist
    EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
    IF ((reply_cv->qual[1].code_value > 0))
     SET hold_code_value = reply_cv->qual[1].code_value
    ELSE
     SET error_msg = "Error creating collection class for LabOne Send Outs"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
    CALL echo(build("hold_code_value = ",hold_code_value))
    INSERT  FROM br_coll_class bcc
     SET bcc.activity_type = "RLI", bcc.collection_class = "LabOne SO", bcc.proposed_name_suffix =
      " ",
      bcc.facility_id = 0.0, bcc.display_name = " ", bcc.storage_tracking_ind = 0,
      bcc.code_value = reply_cv->qual[1].code_value, bcc.updt_cnt = 0, bcc.updt_dt_tm = cnvtdatetime(
       curdate,curtime),
      bcc.updt_id = reqinfo->updt_id, bcc.updt_task = reqinfo->updt_task, bcc.updt_applctx = reqinfo
      ->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_msg = "Error adding LabOne SO to br_coll_class"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
    INSERT  FROM collection_class cc
     SET cc.coll_class_cd = hold_code_value, cc.max_class_volume = 10.0, cc.max_class_vol_units =
      null,
      cc.updt_applctx = reqinfo->updt_applctx, cc.updt_dt_tm = cnvtdatetime(curdate,curtime), cc
      .updt_id = reqinfo->updt_id,
      cc.updt_cnt = 0, cc.updt_task = reqinfo->updt_task, cc.max_accession_size = 12,
      cc.max_class_vol_units_cd = 0.0, cc.def_storage_minutes = 0, cc.symbology = "A",
      cc.smg_barcode_adjust = 0, cc.smg_format = "L", cc.container_id_print = "N",
      cc.transfer_temp_cd = 0.0, cc.storage_temp_cd = 0.0, cc.sequence = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_msg = "Error adding LabOne SO to collection_class table"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE add_quest(supplier_flag)
   SET stat = 1
 END ;Subroutine
 SUBROUTINE add_correlagen(supplier_flag)
   SET found = "N"
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=73
      AND cv.display_key="CORRELAGENRLI")
    DETAIL
     found = "Y"
    WITH nocounter
   ;end select
   IF (found="N")
    SET request_cv->cd_value_list[1].action_flag = 1
    SET request_cv->cd_value_list[1].code_set = 73
    SET request_cv->cd_value_list[1].display = "Correlagen RLI"
    SET request_cv->cd_value_list[1].display_key = "CORRELAGENRLI"
    SET request_cv->cd_value_list[1].description = "Correlagen RLI"
    SET request_cv->cd_value_list[1].cdf_meaning = ""
    SET request_cv->cd_value_list[1].active_ind = 1
    SET trace = recpersist
    EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
   ENDIF
   SET found = "N"
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=5801
      AND cv.display_key="CORRELAGENRLI"
      AND cv.cdf_meaning="SEND OUT")
    DETAIL
     found = "Y"
    WITH nocounter
   ;end select
   IF (found="N")
    SET request_cv->cd_value_list[1].action_flag = 1
    SET request_cv->cd_value_list[1].code_set = 5801
    SET request_cv->cd_value_list[1].display = "Correlagen RLI"
    SET request_cv->cd_value_list[1].display_key = "CORRELAGENRLI"
    SET request_cv->cd_value_list[1].description = "Correlagen RLI"
    SET request_cv->cd_value_list[1].cdf_meaning = "SEND OUT"
    SET request_cv->cd_value_list[1].definition = "GLB"
    SET request_cv->cd_value_list[1].active_ind = 1
    SET trace = recpersist
    EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
   ENDIF
   SET found = "N"
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=2056
      AND cv.display_key="CORRELAGENSENDOUT")
    DETAIL
     found = "Y"
    WITH nocounter
   ;end select
   IF (found="N")
    SET request_cv->cd_value_list[1].action_flag = 1
    SET request_cv->cd_value_list[1].code_set = 2056
    SET request_cv->cd_value_list[1].display = "Correlagen Send Out"
    SET request_cv->cd_value_list[1].display_key = "CORRELAGENSENDOUT"
    SET request_cv->cd_value_list[1].description = "Correlagen Send Out"
    SET request_cv->cd_value_list[1].cdf_meaning = ""
    SET request_cv->cd_value_list[1].active_ind = 1
    SET trace = recpersist
    EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
    IF ((reply_cv->qual[1].code_value > 0))
     SET hold_code_value = reply_cv->qual[1].code_value
    ELSE
     SET error_msg = "Error creating accession class for Correlagen Send Out"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
    INSERT  FROM accession_class ac
     SET ac.accession_class_cd = hold_code_value, ac.accession_format_cd = 0.0, ac.updt_applctx =
      reqinfo->updt_applctx,
      ac.updt_dt_tm = cnvtdatetime(curdate,curtime), ac.updt_id = reqinfo->updt_id, ac.updt_cnt = 0,
      ac.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_msg = "Error adding Correlagen Send Out to accession_class table"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
   ENDIF
   SET found = "N"
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=2052
      AND cv.display_key="CORRELAGENREVIEW")
    DETAIL
     found = "Y"
    WITH nocounter
   ;end select
   IF (found="N")
    SET request_cv->cd_value_list[1].action_flag = 1
    SET request_cv->cd_value_list[1].code_set = 2052
    SET request_cv->cd_value_list[1].display = "Correlagen Review"
    SET request_cv->cd_value_list[1].display_key = "CORRELAGENREVIEW"
    SET request_cv->cd_value_list[1].description = "Correlagen Review"
    SET request_cv->cd_value_list[1].cdf_meaning = ""
    SET request_cv->cd_value_list[1].active_ind = 1
    SET trace = recpersist
    EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
    IF ((reply_cv->qual[1].code_value > 0))
     SET hold_code_value = reply_cv->qual[1].code_value
    ELSE
     SET error_msg = "Error creating specimen type for Correlagen Review"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
   ENDIF
   CALL echo(build("here 111"))
   SET found = "N"
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=231
      AND cv.display_key="CORRELAGENSENDOUTSFROZ")
    DETAIL
     found = "Y"
    WITH nocounter
   ;end select
   IF (found="N")
    SET request_cv->cd_value_list[1].action_flag = 1
    SET request_cv->cd_value_list[1].code_set = 231
    SET request_cv->cd_value_list[1].display = "Correlagen Send Outs Froz"
    SET request_cv->cd_value_list[1].display_key = "CORRELAGENSENDOUTSFROZ"
    SET request_cv->cd_value_list[1].description = "Correlagen Send Outs Froz"
    SET request_cv->cd_value_list[1].cdf_meaning = ""
    SET request_cv->cd_value_list[1].active_ind = 1
    SET trace = recpersist
    EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
    IF ((reply_cv->qual[1].code_value > 0))
     SET hold_code_value = reply_cv->qual[1].code_value
    ELSE
     SET error_msg = "Error creating collection class for Correlagen Send Outs Refrig"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
    INSERT  FROM br_coll_class bcc
     SET bcc.activity_type = "RLI", bcc.collection_class = "Correlagen SO Froz", bcc
      .proposed_name_suffix = " ",
      bcc.facility_id = 0.0, bcc.display_name = " ", bcc.storage_tracking_ind = 0,
      bcc.code_value = reply_cv->qual[1].code_value, bcc.updt_cnt = 0, bcc.updt_dt_tm = cnvtdatetime(
       curdate,curtime),
      bcc.updt_id = reqinfo->updt_id, bcc.updt_task = reqinfo->updt_task, bcc.updt_applctx = reqinfo
      ->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_msg = "Error adding Correlagen SO Frozen to br_coll_class"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
    INSERT  FROM collection_class cc
     SET cc.coll_class_cd = hold_code_value, cc.max_class_volume = 10.0, cc.max_class_vol_units =
      null,
      cc.updt_applctx = reqinfo->updt_applctx, cc.updt_dt_tm = cnvtdatetime(curdate,curtime), cc
      .updt_id = reqinfo->updt_id,
      cc.updt_cnt = 0, cc.updt_task = reqinfo->updt_task, cc.max_accession_size = 12,
      cc.max_class_vol_units_cd = 0.0, cc.def_storage_minutes = 0, cc.symbology = "A",
      cc.smg_barcode_adjust = 0, cc.smg_format = "L", cc.container_id_print = "N",
      cc.transfer_temp_cd = 0.0, cc.storage_temp_cd = 0.0, cc.sequence = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_msg = "Error adding Correlagen SO Frozen to collection_class table"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
   ENDIF
   CALL echo(build("here 222"))
   SET found = "N"
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=231
      AND cv.display_key="CORRELAGENSENDOUTSRMTEMP")
    DETAIL
     found = "Y"
    WITH nocounter
   ;end select
   IF (found="N")
    SET request_cv->cd_value_list[1].action_flag = 1
    SET request_cv->cd_value_list[1].code_set = 231
    SET request_cv->cd_value_list[1].display = "Correlagen Send Outs Rm Temp"
    SET request_cv->cd_value_list[1].display_key = "CORRELAGENSENDOUTSRMTEMP"
    SET request_cv->cd_value_list[1].description = "Correlagen Send Outs RM Temp"
    SET request_cv->cd_value_list[1].cdf_meaning = ""
    SET request_cv->cd_value_list[1].active_ind = 1
    SET trace = recpersist
    EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
    IF ((reply_cv->qual[1].code_value > 0))
     SET hold_code_value = reply_cv->qual[1].code_value
    ELSE
     SET error_msg = "Error creating collection class for Correlagen Send Outs Rm Temp"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
    INSERT  FROM br_coll_class bcc
     SET bcc.activity_type = "RLI", bcc.collection_class = "Correlagen SO RmTemp", bcc
      .proposed_name_suffix = " ",
      bcc.facility_id = 0.0, bcc.display_name = " ", bcc.storage_tracking_ind = 0,
      bcc.code_value = reply_cv->qual[1].code_value, bcc.updt_cnt = 0, bcc.updt_dt_tm = cnvtdatetime(
       curdate,curtime),
      bcc.updt_id = reqinfo->updt_id, bcc.updt_task = reqinfo->updt_task, bcc.updt_applctx = reqinfo
      ->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_msg = "Error adding Correlagen SO Rm Temp to br_coll_class"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
    INSERT  FROM collection_class cc
     SET cc.coll_class_cd = hold_code_value, cc.max_class_volume = 10.0, cc.max_class_vol_units =
      null,
      cc.updt_applctx = reqinfo->updt_applctx, cc.updt_dt_tm = cnvtdatetime(curdate,curtime), cc
      .updt_id = reqinfo->updt_id,
      cc.updt_cnt = 0, cc.updt_task = reqinfo->updt_task, cc.max_accession_size = 12,
      cc.max_class_vol_units_cd = 0.0, cc.def_storage_minutes = 0, cc.symbology = "A",
      cc.smg_barcode_adjust = 0, cc.smg_format = "L", cc.container_id_print = "N",
      cc.transfer_temp_cd = 0.0, cc.storage_temp_cd = 0.0, cc.sequence = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_msg = "Error adding Correlagen SE Rm Temp to collection_class table"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
   ENDIF
   CALL echo(build("here 333"))
   SET found = "N"
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=231
      AND cv.display_key="CORRELAGENSENDOUTSREFRIG")
    DETAIL
     found = "Y"
    WITH nocounter
   ;end select
   IF (found="N")
    SET request_cv->cd_value_list[1].action_flag = 1
    SET request_cv->cd_value_list[1].code_set = 231
    SET request_cv->cd_value_list[1].display = "Correlagen Send Outs Refrig"
    SET request_cv->cd_value_list[1].display_key = "CORRELAGENSENDOUTSREFRIG"
    SET request_cv->cd_value_list[1].description = "Correlagen Send Outs Refrig"
    SET request_cv->cd_value_list[1].cdf_meaning = ""
    SET request_cv->cd_value_list[1].active_ind = 1
    SET trace = recpersist
    EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
    IF ((reply_cv->qual[1].code_value > 0))
     SET hold_code_value = reply_cv->qual[1].code_value
    ELSE
     SET error_msg = "Error creating collection class for Correlagen Send Outs Refrig"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
    INSERT  FROM br_coll_class bcc
     SET bcc.activity_type = "RLI", bcc.collection_class = "Correlagen SO Refrig", bcc
      .proposed_name_suffix = " ",
      bcc.facility_id = 0.0, bcc.display_name = " ", bcc.storage_tracking_ind = 0,
      bcc.code_value = reply_cv->qual[1].code_value, bcc.updt_cnt = 0, bcc.updt_dt_tm = cnvtdatetime(
       curdate,curtime),
      bcc.updt_id = reqinfo->updt_id, bcc.updt_task = reqinfo->updt_task, bcc.updt_applctx = reqinfo
      ->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_msg = "Error adding Correlagen SO Refrig to br_coll_class"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
    INSERT  FROM collection_class cc
     SET cc.coll_class_cd = hold_code_value, cc.max_class_volume = 10.0, cc.max_class_vol_units =
      null,
      cc.updt_applctx = reqinfo->updt_applctx, cc.updt_dt_tm = cnvtdatetime(curdate,curtime), cc
      .updt_id = reqinfo->updt_id,
      cc.updt_cnt = 0, cc.updt_task = reqinfo->updt_task, cc.max_accession_size = 12,
      cc.max_class_vol_units_cd = 0.0, cc.def_storage_minutes = 0, cc.symbology = "A",
      cc.smg_barcode_adjust = 0, cc.smg_format = "L", cc.container_id_print = "N",
      cc.transfer_temp_cd = 0.0, cc.storage_temp_cd = 0.0, cc.sequence = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_msg = "Error adding Correlagen SO Refrig to collection_class table"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
   ENDIF
   CALL echo(build("here 444"))
   SET found = "N"
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=231
      AND cv.display_key="CORRELAGENSENDOUTS")
    DETAIL
     found = "Y"
    WITH nocounter
   ;end select
   IF (found="N")
    SET request_cv->cd_value_list[1].action_flag = 1
    SET request_cv->cd_value_list[1].code_set = 231
    SET request_cv->cd_value_list[1].display = "Correlagen Send Outs"
    SET request_cv->cd_value_list[1].display_key = "CORRELAGENSENDOUTS"
    SET request_cv->cd_value_list[1].description = "Correlagen Send Outs"
    SET request_cv->cd_value_list[1].cdf_meaning = ""
    SET request_cv->cd_value_list[1].active_ind = 1
    SET trace = recpersist
    EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
    IF ((reply_cv->qual[1].code_value > 0))
     SET hold_code_value = reply_cv->qual[1].code_value
    ELSE
     SET error_msg = "Error creating collection class for Correlagen Send Outs"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
    INSERT  FROM br_coll_class bcc
     SET bcc.activity_type = "RLI", bcc.collection_class = "Correlagen SO", bcc.proposed_name_suffix
       = " ",
      bcc.facility_id = 0.0, bcc.display_name = " ", bcc.storage_tracking_ind = 0,
      bcc.code_value = reply_cv->qual[1].code_value, bcc.updt_cnt = 0, bcc.updt_dt_tm = cnvtdatetime(
       curdate,curtime),
      bcc.updt_id = reqinfo->updt_id, bcc.updt_task = reqinfo->updt_task, bcc.updt_applctx = reqinfo
      ->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_msg = "Error adding Correlagen SO to br_coll_class"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
    INSERT  FROM collection_class cc
     SET cc.coll_class_cd = hold_code_value, cc.max_class_volume = 10.0, cc.max_class_vol_units =
      null,
      cc.updt_applctx = reqinfo->updt_applctx, cc.updt_dt_tm = cnvtdatetime(curdate,curtime), cc
      .updt_id = reqinfo->updt_id,
      cc.updt_cnt = 0, cc.updt_task = reqinfo->updt_task, cc.max_accession_size = 12,
      cc.max_class_vol_units_cd = 0.0, cc.def_storage_minutes = 0, cc.symbology = "A",
      cc.smg_barcode_adjust = 0, cc.smg_format = "L", cc.container_id_print = "N",
      cc.transfer_temp_cd = 0.0, cc.storage_temp_cd = 0.0, cc.sequence = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_msg = "Error adding Correlagen SO to collection_class table"
     SET error_flag = "T"
     GO TO exit_script
    ENDIF
   ENDIF
 END ;Subroutine
#exit_script
 IF (error_flag="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSEIF (error_flag="T")
  SET reply->error_msg = error_msg
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
