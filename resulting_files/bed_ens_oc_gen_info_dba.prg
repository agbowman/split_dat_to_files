CREATE PROGRAM bed_ens_oc_gen_info:dba
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET active_cd = 0.0
 SET inactive_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=48
   AND cv.cdf_meaning IN ("ACTIVE", "INACTIVE")
  DETAIL
   IF (cv.cdf_meaning="ACTIVE")
    active_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="INACTIVE")
    inactive_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET primary_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=6011
   AND cv.cdf_meaning="PRIMARY"
  DETAIL
   primary_cd = cv.code_value
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
 SET oc_cnt = size(request->olist,5)
 FOR (o = 1 TO oc_cnt)
   IF ((request->olist[o].active_ind=1))
    SET active_status_cd = active_cd
    SET active_dt_tm = cnvtdatetime(curdate,curtime)
    SET inactive_dt_tm = null
   ELSE
    SET active_status_cd = inactive_cd
    SET active_dt_tm = null
    SET inactive_dt_tm = cnvtdatetime(curdate,curtime)
   ENDIF
   SET curr_primary_mnemonic = fillstring(100," ")
   SET curr_active_ind = 0
   SELECT INTO "NL:"
    FROM order_catalog oc
    WHERE (oc.catalog_cd=request->olist[o].catalog_cd)
    DETAIL
     curr_primary_mnemonic = oc.primary_mnemonic, curr_active_ind = oc.active_ind
    WITH nocounter
   ;end select
   UPDATE  FROM order_catalog oc
    SET oc.description = request->olist[o].description, oc.primary_mnemonic = request->olist[o].
     primary_mnemonic, oc.dept_display_name = request->olist[o].dept_name,
     oc.catalog_type_cd = request->olist[o].catalog_type_cd, oc.activity_type_cd = request->olist[o].
     activity_type_cd, oc.activity_subtype_cd = request->olist[o].activity_subtype_cd,
     oc.active_ind = request->olist[o].active_ind, oc.updt_cnt = (oc.updt_cnt+ 1), oc.updt_id =
     reqinfo->updt_id,
     oc.updt_dt_tm = cnvtdatetime(curdate,curtime), oc.updt_task = reqinfo->updt_task, oc
     .updt_applctx = reqinfo->updt_applctx
    WHERE (oc.catalog_cd=request->olist[o].catalog_cd)
    WITH nocounter
   ;end update
   UPDATE  FROM bill_item bi
    SET bi.ext_description = request->olist[o].description, bi.ext_short_desc = substring(1,50,
      request->olist[o].primary_mnemonic), bi.ext_owner_cd = request->olist[o].activity_type_cd,
     bi.active_ind = request->olist[o].active_ind, bi.active_status_cd =
     IF ((request->olist[o].active_ind=1)) active_cd
     ELSE inactive_cd
     ENDIF
     , bi.updt_cnt = (bi.updt_cnt+ 1),
     bi.updt_id = reqinfo->updt_id, bi.updt_dt_tm = cnvtdatetime(curdate,curtime), bi.updt_task =
     reqinfo->updt_task,
     bi.updt_applctx = reqinfo->updt_applctx
    WHERE (bi.ext_parent_reference_id=request->olist[o].catalog_cd)
     AND bi.parent_qual_cd=1.0
     AND bi.ext_parent_contributor_cd=ord_cat_value
     AND bi.ext_child_reference_id=0.0
    WITH nocounter
   ;end update
   IF (curqual=0
    AND (request->olist[o].active_ind=1))
    INSERT  FROM bill_item bi
     SET bi.bill_item_id = seq(bill_item_seq,nextval), bi.ext_parent_reference_id = request->olist[o]
      .catalog_cd, bi.ext_parent_contributor_cd = ord_cat_value,
      bi.ext_parent_entity_name = "CODE_VALUE", bi.parent_qual_cd = 1.0, bi.ext_child_reference_id =
      0.0,
      bi.ext_child_contributor_cd = 0.0, bi.ext_child_entity_name = null, bi.ext_description =
      request->olist[o].description,
      bi.ext_owner_cd = request->olist[o].activity_type_cd, bi.ext_short_desc = substring(1,50,
       request->olist[o].primary_mnemonic), bi.active_ind = 1,
      bi.active_status_cd = active_cd, bi.active_status_dt_tm = cnvtdatetime(curdate,curtime3), bi
      .active_status_prsnl_id = reqinfo->updt_id,
      bi.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), bi.end_effective_dt_tm = cnvtdatetime(
       "31-DEC-2100"), bi.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      bi.updt_id = reqinfo->updt_id, bi.updt_task = reqinfo->updt_task, bi.updt_cnt = 0,
      bi.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
   ENDIF
   IF ((curr_primary_mnemonic != request->olist[o].primary_mnemonic))
    UPDATE  FROM order_catalog_synonym ocs
     SET ocs.mnemonic = request->olist[o].primary_mnemonic, ocs.mnemonic_key_cap = cnvtupper(request
       ->olist[o].primary_mnemonic), ocs.updt_cnt = (ocs.updt_cnt+ 1),
      ocs.updt_id = reqinfo->updt_id, ocs.updt_dt_tm = cnvtdatetime(curdate,curtime), ocs.updt_task
       = reqinfo->updt_task,
      ocs.updt_applctx = reqinfo->updt_applctx
     WHERE (ocs.catalog_cd=request->olist[o].catalog_cd)
      AND ocs.mnemonic=curr_primary_mnemonic
      AND ocs.mnemonic_type_cd=primary_cd
     WITH nocounter
    ;end update
   ENDIF
   IF (curr_active_ind=1
    AND (request->olist[o].active_ind=1))
    UPDATE  FROM order_catalog_synonym ocs
     SET ocs.catalog_type_cd = request->olist[o].catalog_type_cd, ocs.activity_type_cd = request->
      olist[o].activity_type_cd, ocs.activity_subtype_cd = request->olist[o].activity_subtype_cd,
      ocs.updt_cnt = (ocs.updt_cnt+ 1), ocs.updt_id = reqinfo->updt_id, ocs.updt_dt_tm = cnvtdatetime
      (curdate,curtime),
      ocs.updt_task = reqinfo->updt_task, ocs.updt_applctx = reqinfo->updt_applctx
     WHERE (ocs.catalog_cd=request->olist[o].catalog_cd)
     WITH nocounter
    ;end update
   ELSEIF (curr_active_ind=1
    AND (request->olist[o].active_ind=0))
    UPDATE  FROM order_catalog_synonym ocs
     SET ocs.catalog_type_cd = request->olist[o].catalog_type_cd, ocs.activity_type_cd = request->
      olist[o].activity_type_cd, ocs.activity_subtype_cd = request->olist[o].activity_subtype_cd,
      ocs.active_ind = request->olist[o].active_ind, ocs.active_status_cd = active_status_cd, ocs
      .active_status_dt_tm = cnvtdatetime(curdate,curtime),
      ocs.updt_cnt = (ocs.updt_cnt+ 1), ocs.updt_id = reqinfo->updt_id, ocs.updt_dt_tm = cnvtdatetime
      (curdate,curtime),
      ocs.updt_task = reqinfo->updt_task, ocs.updt_applctx = reqinfo->updt_applctx
     WHERE (ocs.catalog_cd=request->olist[o].catalog_cd)
     WITH nocounter
    ;end update
   ELSEIF (curr_active_ind=0
    AND (request->olist[o].active_ind=1))
    UPDATE  FROM order_catalog_synonym ocs
     SET ocs.catalog_type_cd = request->olist[o].catalog_type_cd, ocs.activity_type_cd = request->
      olist[o].activity_type_cd, ocs.activity_subtype_cd = request->olist[o].activity_subtype_cd,
      ocs.updt_cnt = (ocs.updt_cnt+ 1), ocs.updt_id = reqinfo->updt_id, ocs.updt_dt_tm = cnvtdatetime
      (curdate,curtime),
      ocs.updt_task = reqinfo->updt_task, ocs.updt_applctx = reqinfo->updt_applctx
     WHERE (ocs.catalog_cd=request->olist[o].catalog_cd)
     WITH nocounter
    ;end update
    UPDATE  FROM order_catalog_synonym ocs
     SET ocs.active_ind = request->olist[o].active_ind, ocs.active_status_cd = active_status_cd, ocs
      .active_status_dt_tm = cnvtdatetime(curdate,curtime),
      ocs.updt_cnt = (ocs.updt_cnt+ 1), ocs.updt_id = reqinfo->updt_id, ocs.updt_dt_tm = cnvtdatetime
      (curdate,curtime),
      ocs.updt_task = reqinfo->updt_task, ocs.updt_applctx = reqinfo->updt_applctx
     WHERE (ocs.catalog_cd=request->olist[o].catalog_cd)
      AND ocs.mnemonic_type_cd=primary_cd
     WITH nocounter
    ;end update
   ENDIF
   SELECT INTO "NL:"
    FROM service_directory sd
    WHERE (sd.catalog_cd=request->olist[o].catalog_cd)
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET catalog_type_mean = fillstring(12," ")
    SELECT INTO "NL:"
     FROM code_value cv
     WHERE (cv.code_value=request->olist[o].catalog_type_cd)
     DETAIL
      catalog_type_mean = cv.cdf_meaning
     WITH nocounter
    ;end select
    IF (((catalog_type_mean="GENERAL LAB") OR (catalog_type_mean="RADIOLOGY")) )
     INSERT  FROM service_directory sd
      SET sd.catalog_cd = request->olist[o].catalog_cd, sd.description = request->olist[o].dept_name,
       sd.short_description = request->olist[o].dept_name,
       sd.active_ind = request->olist[o].active_ind, sd.active_status_cd = active_status_cd, sd
       .active_status_dt_tm = cnvtdatetime(curdate,curtime),
       sd.active_dt_tm =
       IF ((request->olist[o].active_ind=1)) cnvtdatetime(curdate,curtime)
       ELSE null
       ENDIF
       , sd.inactive_dt_tm =
       IF ((request->olist[o].active_ind=0)) cnvtdatetime(curdate,curtime)
       ELSE null
       ENDIF
       , sd.updt_cnt = 0,
       sd.updt_id = reqinfo->updt_id, sd.updt_dt_tm = cnvtdatetime(curdate,curtime), sd.updt_task =
       reqinfo->updt_task,
       sd.updt_applctx = reqinfo->updt_applctx, sd.synonym_id = 0, sd.bb_processing_cd = request->
       olist[o].procedure_type_cd,
       sd.bb_default_phases_cd = 0, sd.active_status_prsnl_id = reqinfo->updt_id, sd
       .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
       sd.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), sd.end_effective_dt_tm = cnvtdatetime
       ("31-dec-2100 00:00:00.00")
      WITH nocounter
     ;end insert
    ENDIF
   ELSE
    UPDATE  FROM service_directory sd
     SET sd.description = request->olist[o].dept_name, sd.short_description = request->olist[o].
      dept_name, sd.bb_processing_cd = request->olist[o].procedure_type_cd,
      sd.updt_cnt = (sd.updt_cnt+ 1), sd.updt_id = reqinfo->updt_id, sd.updt_dt_tm = cnvtdatetime(
       curdate,curtime),
      sd.updt_task = reqinfo->updt_task, sd.updt_applctx = reqinfo->updt_applctx
     WHERE (sd.catalog_cd=request->olist[o].catalog_cd)
     WITH nocounter
    ;end update
   ENDIF
   UPDATE  FROM code_value cv
    SET cv.description = substring(1,60,request->olist[o].description), cv.display = substring(1,40,
      request->olist[o].primary_mnemonic), cv.display_key = substring(1,40,cnvtupper(cnvtalphanum(
        request->olist[o].primary_mnemonic))),
     cv.active_ind = request->olist[o].active_ind, cv.updt_cnt = (cv.updt_cnt+ 1), cv.updt_id =
     reqinfo->updt_id,
     cv.updt_dt_tm = cnvtdatetime(curdate,curtime), cv.updt_task = reqinfo->updt_task, cv
     .updt_applctx = reqinfo->updt_applctx
    WHERE (code_value=request->olist[o].catalog_cd)
   ;end update
 ENDFOR
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
 CALL echorecord(reply)
END GO
