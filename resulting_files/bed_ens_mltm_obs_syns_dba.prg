CREATE PROGRAM bed_ens_mltm_obs_syns:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE bederror(errordescription=vc) = null
 DECLARE bederrorcheck(errordescription=vc) = null
 SUBROUTINE bederror(errordescription)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE bederrorcheck(errordescription)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   CALL bederror(errordescription)
  ENDIF
 END ;Subroutine
 FREE RECORD orders_to_inactivate
 RECORD orders_to_inactivate(
   1 orderables[*]
     2 catalog_cd = f8
     2 new_mnemonic = vc
 )
 DECLARE cs48_inactive_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"INACTIVE"))
 DECLARE cs6011_primary_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"PRIMARY"))
 DECLARE cs13016_ord_cat_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",13016,"ORD CAT"))
 DECLARE req_cnt = i4 WITH protect, constant(size(request->synonyms,5))
 DECLARE temp_cnt = i4 WITH protect, noconstant(0)
 DECLARE order_cnt = i4 WITH protect, noconstant(0)
 DELETE  FROM br_name_value bnv,
   (dummyt d  WITH seq = req_cnt)
  SET bnv.seq = 1
  PLAN (d)
   JOIN (bnv
   WHERE bnv.br_nv_key1="OBSOLETESYN_IGN"
    AND bnv.br_name="ORDER_CATALOG_SYNONYM"
    AND bnv.br_value=cnvtstring(request->synonyms[d.seq].synonym_id))
  WITH nocounter
 ;end delete
 CALL bederrorcheck("ignore delete error")
 FOR (x = 1 TO req_cnt)
   IF ((request->synonyms[x].ignore_ind=1))
    INSERT  FROM br_name_value bnv
     SET bnv.br_name_value_id = seq(bedrock_seq,nextval), bnv.br_nv_key1 = "OBSOLETESYN_IGN", bnv
      .br_name = "ORDER_CATALOG_SYNONYM",
      bnv.br_value = cnvtstring(request->synonyms[x].synonym_id), bnv.updt_applctx = reqinfo->
      updt_applctx, bnv.updt_cnt = 0,
      bnv.updt_dt_tm = cnvtdatetime(curdate,curtime3), bnv.updt_id = reqinfo->updt_id, bnv.updt_task
       = reqinfo->updt_task
     WITH nocounter
    ;end insert
    CALL bederrorcheck("ignore insert error")
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = req_cnt),
   order_catalog_synonym ocs
  PLAN (d
   WHERE (request->synonyms[d.seq].inactivate_ind=1))
   JOIN (ocs
   WHERE (ocs.synonym_id=request->synonyms[d.seq].synonym_id)
    AND ocs.mnemonic_type_cd=cs6011_primary_cd)
  HEAD REPORT
   order_cnt = 0, temp_cnt = 0, stat = alterlist(orders_to_inactivate->orderables,(order_cnt+ 10))
  DETAIL
   temp_cnt = (temp_cnt+ 1)
   IF (temp_cnt > 10)
    temp_cnt = 1, stat = alterlist(orders_to_inactivate->orderables,(order_cnt+ 10))
   ENDIF
   order_cnt = (order_cnt+ 1), orders_to_inactivate->orderables[order_cnt].catalog_cd = ocs
   .catalog_cd, orders_to_inactivate->orderables[order_cnt].new_mnemonic = request->synonyms[d.seq].
   mnemonic
  FOOT REPORT
   stat = alterlist(orders_to_inactivate->orderables,order_cnt)
  WITH nocounter
 ;end select
 CALL bederrorcheck("order select error")
 IF (req_cnt > 0)
  UPDATE  FROM (dummyt d  WITH seq = req_cnt),
    order_catalog_synonym ocs
   SET ocs.active_ind = 0, ocs.active_status_cd = cs48_inactive_cd, ocs.active_status_dt_tm =
    cnvtdatetime(curdate,curtime3),
    ocs.active_status_prsnl_id = reqinfo->updt_id, ocs.mnemonic = request->synonyms[d.seq].mnemonic,
    ocs.mnemonic_key_cap = cnvtupper(request->synonyms[d.seq].mnemonic),
    ocs.updt_applctx = reqinfo->updt_applctx, ocs.updt_cnt = 0, ocs.updt_dt_tm = cnvtdatetime(curdate,
     curtime3),
    ocs.updt_id = reqinfo->updt_id, ocs.updt_task = reqinfo->updt_task
   PLAN (d
    WHERE (request->synonyms[d.seq].inactivate_ind=1))
    JOIN (ocs
    WHERE (ocs.synonym_id=request->synonyms[d.seq].synonym_id))
   WITH nocounter
  ;end update
  CALL bederrorcheck("update ocs table error")
 ENDIF
 IF (order_cnt > 0)
  UPDATE  FROM (dummyt d  WITH seq = order_cnt),
    bill_item bi
   SET bi.active_ind = 0, bi.active_status_cd = cs48_inactive_cd, bi.updt_cnt = (bi.updt_cnt+ 1),
    bi.updt_id = reqinfo->updt_id, bi.updt_dt_tm = cnvtdatetime(curdate,curtime3), bi.updt_task =
    reqinfo->updt_task,
    bi.updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (bi
    WHERE (bi.ext_parent_reference_id=orders_to_inactivate->orderables[d.seq].catalog_cd)
     AND bi.active_ind=1
     AND bi.parent_qual_cd=1.0
     AND bi.ext_parent_contributor_cd=cs13016_ord_cat_cd
     AND bi.ext_child_reference_id=0.0)
   WITH nocounter
  ;end update
  CALL bederrorcheck("update bill_item table error")
  UPDATE  FROM (dummyt d  WITH seq = order_cnt),
    order_catalog oc
   SET oc.active_ind = 0, oc.primary_mnemonic = orders_to_inactivate->orderables[d.seq].new_mnemonic,
    oc.updt_cnt = (oc.updt_cnt+ 1),
    oc.updt_id = reqinfo->updt_id, oc.updt_dt_tm = cnvtdatetime(curdate,curtime3), oc.updt_task =
    reqinfo->updt_task,
    oc.updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (oc
    WHERE (oc.catalog_cd=orders_to_inactivate->orderables[d.seq].catalog_cd))
   WITH nocounter
  ;end update
  CALL bederrorcheck("update oc table error")
  UPDATE  FROM (dummyt d  WITH seq = order_cnt),
    code_value cv
   SET cv.active_ind = 0, cv.active_type_cd = cs48_inactive_cd, cv.updt_cnt = (cv.updt_cnt+ 1),
    cv.updt_id = reqinfo->updt_id, cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_task =
    reqinfo->updt_task,
    cv.updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (cv
    WHERE (cv.code_value=orders_to_inactivate->orderables[d.seq].catalog_cd))
   WITH nocounter
  ;end update
  CALL bederrorcheck("update code_value table error")
 ENDIF
 CALL bederrorcheck("Descriptive error message not provided.")
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
