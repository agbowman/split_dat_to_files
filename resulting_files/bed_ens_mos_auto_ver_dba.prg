CREATE PROGRAM bed_ens_mos_auto_ver:dba
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
 FREE SET tsent
 RECORD tsent(
   1 sent[*]
     2 sent_id = f8
 )
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET cnt = size(request->sentences,5)
 IF ((request->updt_all_ind=1))
  SET pharm_ct = 0.0
  SET pharm_ct = uar_get_code_by("MEANING",6000,"PHARMACY")
  SET pharm_at = 0.0
  SET pharm_at = uar_get_code_by("MEANING",106,"PHARMACY")
  SET primary_code_value = 0.0
  SET primary_code_value = uar_get_code_by("MEANING",6011,"PRIMARY")
  SET brand_code_value = 0.0
  SET brand_code_value = uar_get_code_by("MEANING",6011,"BRANDNAME")
  SET dcp_code_value = 0.0
  SET dcp_code_value = uar_get_code_by("MEANING",6011,"DCP")
  SET c_code_value = 0.0
  SET c_code_value = uar_get_code_by("MEANING",6011,"DISPDRUG")
  SET e_code_value = 0.0
  SET e_code_value = uar_get_code_by("MEANING",6011,"IVNAME")
  SET m_code_value = 0.0
  SET m_code_value = uar_get_code_by("MEANING",6011,"GENERICTOP")
  SET n_code_value = 0.0
  SET n_code_value = uar_get_code_by("MEANING",6011,"TRADETOP")
  SET y_code_value = 0.0
  SET y_code_value = uar_get_code_by("MEANING",6011,"GENERICPROD")
  SET z_code_value = 0.0
  SET z_code_value = uar_get_code_by("MEANING",6011,"TRADEPROD")
  DECLARE oc_parse = vc
  SET oc_parse = concat(
   "oc.catalog_type_cd = pharm_ct and oc.activity_type_cd = pharm_at and oc.orderable_type_flag in (0,1,null)",
   " and oc.active_ind = 1 ")
  DECLARE ocs_parse = vc
  IF ((request->usage_flag=2))
   SET ocs_parse = concat(
    "ocs.mnemonic_type_cd IN (primary_code_value, brand_code_value, dcp_code_value,",
    "c_code_value, e_code_value, m_code_value, n_code_value, y_code_value, z_code_value)")
  ELSE
   SET ocs_parse = concat(
    "ocs.mnemonic_type_cd IN (primary_code_value, brand_code_value, dcp_code_value,",
    "c_code_value, e_code_value, m_code_value, n_code_value)")
  ENDIF
  SET tcnt = 0
  SELECT INTO "nl:"
   FROM order_catalog oc,
    order_catalog_synonym ocs,
    ord_cat_sent_r ocsr,
    order_sentence os
   PLAN (oc
    WHERE parser(oc_parse))
    JOIN (ocs
    WHERE ocs.catalog_cd=oc.catalog_cd
     AND parser(ocs_parse)
     AND ocs.active_ind=1
     AND ocs.hide_flag IN (0, null))
    JOIN (ocsr
    WHERE ocsr.synonym_id=ocs.synonym_id
     AND ocsr.active_ind=1)
    JOIN (os
    WHERE os.order_sentence_id=ocsr.order_sentence_id
     AND (os.usage_flag=request->usage_flag))
   ORDER BY os.order_sentence_id
   HEAD REPORT
    cnt = 0, tcnt = 0, stat = alterlist(tsent->sent,100)
   HEAD os.order_sentence_id
    cnt = (cnt+ 1), tcnt = (tcnt+ 1)
    IF (cnt > 100)
     stat = alterlist(tsent->sent,(tcnt+ 100)), cnt = 1
    ENDIF
    tsent->sent[tcnt].sent_id = os.order_sentence_id
   FOOT REPORT
    stat = alterlist(tsent->sent,tcnt)
   WITH nocounter
  ;end select
  IF (tcnt=0)
   GO TO exit_script
  ENDIF
  SET ierrcode = 0
  UPDATE  FROM order_sentence o,
    (dummyt d  WITH seq = value(tcnt))
   SET o.ic_auto_verify_flag = request->all_multum_clinical_checking, o.discern_auto_verify_flag =
    request->all_discern_rules_checking, o.updt_id = reqinfo->updt_id,
    o.updt_dt_tm = cnvtdatetime(curdate,curtime), o.updt_task = reqinfo->updt_task, o.updt_applctx =
    reqinfo->updt_applctx,
    o.updt_cnt = (o.updt_cnt+ 1)
   PLAN (d)
    JOIN (o
    WHERE (o.order_sentence_id=tsent->sent[d.seq].sent_id))
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->error_msg = serrmsg
   GO TO exit_script
  ENDIF
 ELSE
  IF (cnt=0)
   GO TO exit_script
  ENDIF
  SET ierrcode = 0
  UPDATE  FROM order_sentence o,
    (dummyt d  WITH seq = value(cnt))
   SET o.ic_auto_verify_flag = request->sentences[d.seq].multum_clinical_checking, o
    .discern_auto_verify_flag = request->sentences[d.seq].discern_rules_checking, o.updt_id = reqinfo
    ->updt_id,
    o.updt_dt_tm = cnvtdatetime(curdate,curtime), o.updt_task = reqinfo->updt_task, o.updt_applctx =
    reqinfo->updt_applctx,
    o.updt_cnt = (o.updt_cnt+ 1)
   PLAN (d)
    JOIN (o
    WHERE (o.order_sentence_id=request->sentences[d.seq].sentence_id))
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->error_msg = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
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
