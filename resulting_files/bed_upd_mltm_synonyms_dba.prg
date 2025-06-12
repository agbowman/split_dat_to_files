CREATE PROGRAM bed_upd_mltm_synonyms:dba
 IF ( NOT (validate(reply,0)))
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
 ENDIF
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET cnt = size(request->synonyms,5)
 FOR (x = 1 TO cnt)
   UPDATE  FROM order_catalog_synonym ocs
    SET ocs.mnemonic = request->synonyms[x].mnemonic, ocs.mnemonic_key_cap = trim(cnvtupper(request->
       synonyms[x].mnemonic)), ocs.hide_flag = request->synonyms[x].hide_flag,
     ocs.mnemonic_type_cd = request->synonyms[x].mnemonic_type_code_value, ocs.updt_cnt = (ocs
     .updt_cnt+ 1), ocs.updt_id = reqinfo->updt_id,
     ocs.updt_dt_tm = cnvtdatetime(curdate,curtime), ocs.updt_task = reqinfo->updt_task, ocs
     .updt_applctx = reqinfo->updt_applctx
    WHERE (ocs.synonym_id=request->synonyms[x].synonym_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "Y"
    SET reply->error_msg = concat("Unable to update synonym id: ",trim(cnvtstring(request->synonyms[x
       ].synonym_id))," into the order_catalog_synonym table.")
    GO TO exit_script
   ENDIF
   SET catalog_code = 0.0
   SELECT INTO "nl:"
    FROM order_catalog_synonym ocs,
     code_value cv
    PLAN (ocs
     WHERE (ocs.synonym_id=request->synonyms[x].synonym_id))
     JOIN (cv
     WHERE cv.code_value=ocs.mnemonic_type_cd
      AND cv.code_set=6011
      AND cv.cdf_meaning="PRIMARY"
      AND cv.active_ind=1)
    DETAIL
     catalog_code = ocs.catalog_cd
    WITH nocounter
   ;end select
   IF (catalog_code > 0)
    UPDATE  FROM order_catalog oc
     SET oc.primary_mnemonic = request->synonyms[x].mnemonic, oc.description = request->synonyms[x].
      mnemonic, oc.dept_display_name = request->synonyms[x].mnemonic,
      oc.updt_cnt = (oc.updt_cnt+ 1), oc.updt_id = reqinfo->updt_id, oc.updt_dt_tm = cnvtdatetime(
       curdate,curtime),
      oc.updt_task = reqinfo->updt_task, oc.updt_applctx = reqinfo->updt_applctx
     WHERE oc.catalog_cd=catalog_code
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "Y"
     SET reply->error_msg = concat("Unable to update primary_mnemonic for catalog code value: ",trim(
       cnvtstring(catalog_code))," on the order_catalog table.")
     GO TO exit_script
    ENDIF
    UPDATE  FROM code_value cv
     SET cv.display = substring(1,40,request->synonyms[x].mnemonic), cv.description = substring(1,60,
       request->synonyms[x].mnemonic), cv.display_key = cnvtupper(cnvtalphanum(substring(1,40,request
         ->synonyms[x].mnemonic))),
      cv.updt_cnt = (cv.updt_cnt+ 1), cv.updt_id = reqinfo->updt_id, cv.updt_dt_tm = cnvtdatetime(
       curdate,curtime),
      cv.updt_task = reqinfo->updt_task, cv.updt_applctx = reqinfo->updt_applctx
     WHERE cv.code_value=catalog_code
      AND cv.code_set=200
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "Y"
     SET reply->error_msg = concat(
      "Unable to update display and description for catalog code value: ",trim(cnvtstring(
        catalog_code))," on the code_value table.")
     GO TO exit_script
    ENDIF
    SET parent_code_value = uar_get_code_by("MEANING",13016,"ORD CAT")
    UPDATE  FROM bill_item bi
     SET bi.ext_description = request->synonyms[x].mnemonic, bi.ext_short_desc = substring(0,50,
       request->synonyms[x].mnemonic), bi.updt_cnt = (bi.updt_cnt+ 1),
      bi.updt_id = reqinfo->updt_id, bi.updt_dt_tm = cnvtdatetime(curdate,curtime), bi.updt_task =
      reqinfo->updt_task,
      bi.updt_applctx = reqinfo->updt_applctx
     WHERE bi.ext_parent_reference_id=catalog_code
      AND bi.ext_parent_entity_name="CODE_VALUE"
      AND bi.ext_parent_contributor_cd=parent_code_value
      AND bi.ext_child_contributor_cd=0
     WITH nocounter
    ;end update
   ENDIF
   DELETE  FROM br_name_value b
    WHERE b.br_nv_key1="MLTM_IGN_SYN"
     AND b.br_name="ORDER_CATALOG_SYNONYM"
     AND b.br_value=cnvtstring(request->synonyms[x].synonym_id)
    WITH nocounter
   ;end delete
 ENDFOR
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
