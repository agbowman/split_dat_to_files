CREATE PROGRAM bed_ens_mltm_oc_cnum:dba
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
 DECLARE primary_cd = f8
 DECLARE catalog_cd = f8
 SET catalog_cd = 0
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET cnt = size(request->synonyms,5)
 DECLARE temp_concept_cki = vc
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
   SET catalog_cd = 0
   SELECT INTO "nl:"
    FROM order_catalog_synonym ocs
    WHERE ocs.mnemonic_type_cd=primary_cd
     AND (ocs.synonym_id=request->synonyms[x].synonym_id)
    DETAIL
     catalog_cd = ocs.catalog_cd
    WITH nocounter
   ;end select
   SET temp_concept_cki = ""
   IF (validate(request->synonyms[x].cnum_concept_cki))
    SET temp_concept_cki = request->synonyms[x].cnum_concept_cki
   ENDIF
   UPDATE  FROM order_catalog_synonym ocs
    SET ocs.cki = request->synonyms[x].cnum, ocs.concept_cki = temp_concept_cki, ocs.ref_text_mask =
     64,
     ocs.updt_dt_tm = cnvtdatetime(curdate,curtime3), ocs.updt_id = reqinfo->updt_id, ocs.updt_task
      = reqinfo->updt_task,
     ocs.updt_cnt = (updt_cnt+ 1), ocs.updt_applctx = reqinfo->updt_applctx
    WHERE (ocs.synonym_id=request->synonyms[x].synonym_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "Y"
    SET reply->error_msg = concat("Unable to update synonym: ",trim(cnvtstring(request->synonyms[x].
       synonym_id))," on the order catalog synonym table")
    GO TO exit_script
   ENDIF
   DELETE  FROM br_name_value b
    WHERE b.br_nv_key1="MLTM_IGN_CNUM"
     AND b.br_value=cnvtstring(request->synonyms[x].synonym_id)
     AND b.br_name="ORDER_CATALOG_SYNONYM"
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
