CREATE PROGRAM bed_ens_mltm_oc_dnum:dba
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE primary_cd = f8
 DECLARE display = vc
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET cnt = size(request->orderables,5)
 DECLARE temp_cnum = vc
 DECLARE temp_cnum_concept_cki = vc
 DECLARE temp_dnum = vc
 DECLARE temp_dnum_concept_cki = vc
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=6011
   AND cv.cdf_meaning="PRIMARY"
   AND cv.active_ind=1
  DETAIL
   primary_cd = cv.code_value
  WITH nocounter
 ;end select
 FOR (x = 1 TO cnt)
   SET temp_dnum = concat("MUL.ORD!",request->orderables[x].dnum)
   SET temp_cnum = concat("MUL.ORD-SYN!",cnvtstring(request->orderables[x].drug_synonym_id))
   SET temp_cnum_concept_cki = ""
   SET temp_dnum_concept_cki = ""
   IF (validate(request->orderables[x].dnum_concept_cki))
    SET temp_dnum = request->orderables[x].dnum
    SET temp_dnum_concept_cki = request->orderables[x].dnum_concept_cki
   ENDIF
   IF (validate(request->orderables[x].cnum))
    SET temp_cnum = request->orderables[x].cnum
   ENDIF
   IF (validate(request->orderables[x].cnum_concept_cki))
    SET temp_cnum_concept_cki = request->orderables[x].cnum_concept_cki
   ENDIF
   UPDATE  FROM code_value cv
    SET cv.cki = temp_dnum, cv.concept_cki = temp_dnum_concept_cki, cv.active_dt_tm = cnvtdatetime(
      curdate,curtime3),
     cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_id = reqinfo->updt_id, cv.updt_task =
     reqinfo->updt_task,
     cv.updt_applctx = reqinfo->updt_applctx, cv.updt_cnt = (cv.updt_cnt+ 1)
    WHERE (cv.code_value=request->orderables[x].code_value)
     AND cv.code_set=200
   ;end update
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Unable to update ",trim(cnvtstring(request->orderables[x].code_value)),
     " into codeset 200.")
    GO TO exit_script
   ENDIF
   UPDATE  FROM order_catalog oc
    SET oc.cki = temp_dnum, oc.concept_cki = temp_dnum_concept_cki, oc.ref_text_mask = 64,
     oc.updt_dt_tm = cnvtdatetime(curdate,curtime3), oc.updt_id = reqinfo->updt_id, oc.updt_task =
     reqinfo->updt_task,
     oc.updt_cnt = (updt_cnt+ 1), oc.updt_applctx = reqinfo->updt_applctx
    WHERE (oc.catalog_cd=request->orderables[x].code_value)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Unable to update orderable: ",trim(cnvtstring(request->orderables[x].
       code_value))," on the order catalog table")
    GO TO exit_script
   ENDIF
   UPDATE  FROM order_catalog_synonym ocs
    SET ocs.cki = temp_cnum, ocs.concept_cki = temp_cnum_concept_cki, ocs.ref_text_mask = 64,
     ocs.updt_dt_tm = cnvtdatetime(curdate,curtime3), ocs.updt_id = reqinfo->updt_id, ocs.updt_task
      = reqinfo->updt_task,
     ocs.updt_cnt = (updt_cnt+ 1), ocs.updt_applctx = reqinfo->updt_applctx
    WHERE (ocs.catalog_cd=request->orderables[x].code_value)
     AND ocs.mnemonic_type_cd=primary_cd
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Unable to update orderable: ",trim(cnvtstring(request->orderables[x].
       code_value))," on the order catalog synonym table")
    GO TO exit_script
   ENDIF
   DELETE  FROM br_name_value b
    WHERE b.br_nv_key1="MLTM_IGN_DNUM"
     AND b.br_value=cnvtstring(request->orderables[x].code_value)
     AND b.br_name="ORDER_CATALOG"
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
