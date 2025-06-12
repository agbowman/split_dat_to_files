CREATE PROGRAM bed_get_datamart_map_values:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 value_sets[*]
      2 value_set_id = f8
      2 values[*]
        3 code = vc
        3 code_description = vc
        3 source_vocab_cd = f8
        3 val_set_item_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
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
 DECLARE cpt4_cd = f8
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=400
    AND cv.cdf_meaning="CPT4"
    AND cv.active_ind=1)
  DETAIL
   cpt4_cd = cv.code_value
  WITH nocounter
 ;end select
 SET vs_cnt = 0
 SET value_cnt = 0
 SET req_vs_count = size(request->value_set_ids,5)
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(req_vs_count)),
   br_datam_val_set_item dmv,
   code_value cv,
   br_datam_val_set_item_meas dmvd
  PLAN (d)
   JOIN (dmv
   WHERE (dmv.br_datam_val_set_id=request->value_set_ids[d.seq].value_set_id))
   JOIN (dmvd
   WHERE dmvd.br_datam_val_set_item_id=dmv.br_datam_val_set_item_id
    AND dmvd.mapping_required_ind=1)
   JOIN (cv
   WHERE cv.code_set=outerjoin(400)
    AND cv.cdf_meaning=outerjoin(trim(dmv.source_vocab_mean)))
  ORDER BY dmv.br_datam_val_set_id, dmv.source_vocab_item_ident, dmvd.br_datam_val_set_item_id
  HEAD dmv.br_datam_val_set_id
   IF (dmv.br_datam_val_set_id > 0)
    vs_cnt = (vs_cnt+ 1), value_cnt = 0, stat = alterlist(reply->value_sets,vs_cnt),
    reply->value_sets[vs_cnt].value_set_id = dmv.br_datam_val_set_id
   ENDIF
  HEAD dmv.source_vocab_item_ident
   value_cnt = (value_cnt+ 1), stat = alterlist(reply->value_sets[vs_cnt].values,value_cnt), reply->
   value_sets[vs_cnt].values[value_cnt].code = trim(dmv.source_vocab_item_ident),
   reply->value_sets[vs_cnt].values[value_cnt].source_vocab_cd = cv.code_value, reply->value_sets[
   vs_cnt].values[value_cnt].val_set_item_id = dmv.br_datam_val_set_item_id
  HEAD dmvd.br_datam_val_set_item_id
   IF (dmvd.vocab_item_desc != null
    AND dmvd.vocab_item_desc > " ")
    reply->value_sets[vs_cnt].values[value_cnt].code_description = trim(dmvd.vocab_item_desc)
   ELSE
    reply->value_sets[vs_cnt].values[value_cnt].code_description = trim(dmvd.drug_desc)
   ENDIF
  WITH nocounter
 ;end select
 CALL bederrorcheck("Error selecting from br_datamart_map_value,br_datamart_map_value_dtl table")
 SET reply_cnt = size(reply->value_sets,5)
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(reply_cnt)),
   (dummyt d2  WITH seq = 1),
   nomenclature n
  PLAN (d
   WHERE maxrec(d2,size(reply->value_sets[d.seq].values,5)))
   JOIN (d2
   WHERE (reply->value_sets[d.seq].values[d2.seq].source_vocab_cd=cpt4_cd))
   JOIN (n
   WHERE n.source_vocabulary_cd=cpt4_cd
    AND (n.source_identifier=reply->value_sets[d.seq].values[d2.seq].code)
    AND n.active_ind=1
    AND n.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  ORDER BY d2.seq
  HEAD d2.seq
   reply->value_sets[d.seq].values[d2.seq].code_description = n.source_string
  WITH nocounter
 ;end select
 CALL bederrorcheck("Error selecting from nomenclature table")
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO
