CREATE PROGRAM bed_ens_mos_reset_sentences:dba
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 FREE SET temp_qual
 RECORD temp_qual(
   1 sentences[*]
     2 sentence_id = f8
 )
 FREE SET upd_ocs
 RECORD upd_ocs(
   1 syns[*]
     2 upd_ind = i2
     2 synonym_id = f8
     2 mul_sent_ind = i2
     2 order_sent_id = f8
 )
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET error_flag = "N"
 SET tcnt = 0
 SET tsyn_cnt = 0
 IF ((request->reset_ind=0))
  GO TO exit_script
 ENDIF
 SET pharm_ct = 0.0
 SET pharm_ct = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET pharm_at = 0.0
 SET pharm_at = uar_get_code_by("MEANING",106,"PHARMACY")
 SET pre_ord_sent_ind = 0
 IF (validate(request->remove_pre_order_sent_ind))
  IF ((request->remove_pre_order_sent_ind=1))
   SET pre_ord_sent_ind = 1
  ENDIF
 ENDIF
 DECLARE osparse = vc
 DECLARE csvfile = vc
 IF (pre_ord_sent_ind=1)
  SET osparse = "os.external_identifier = 'MUL.OP*' and os.usage_flag = 2"
  SET csvfile = "br_prescrip_order_sent_backup.csv"
 ELSE
  SET osparse = "os.external_identifier = 'MUL.IP*' and os.usage_flag = 1"
  SET csvfile = "br_order_sent_backup.csv"
 ENDIF
 SELECT INTO value(csvfile)
  synonym_type = uar_get_code_display(ocs.mnemonic_type_cd), e_type = uar_get_code_display(os
   .order_encntr_group_cd)
  FROM order_catalog oc,
   order_catalog_synonym ocs,
   ord_cat_sent_r ocsr,
   order_sentence os,
   order_sentence_detail osd,
   oe_field_meaning oem
  PLAN (os
   WHERE parser(osparse))
   JOIN (osd
   WHERE osd.order_sentence_id=os.order_sentence_id)
   JOIN (oem
   WHERE oem.oe_field_meaning_id=osd.oe_field_meaning_id)
   JOIN (ocsr
   WHERE ocsr.order_sentence_id=os.order_sentence_id)
   JOIN (ocs
   WHERE ocs.synonym_id=ocsr.synonym_id)
   JOIN (oc
   WHERE oc.catalog_cd=ocs.catalog_cd)
  ORDER BY oc.description, oc.catalog_cd, ocs.mnemonic,
   ocs.synonym_id, os.order_sentence_id, osd.sequence
  HEAD REPORT
   cnt = 0, tcnt = 0, stat = alterlist(temp_qual->sentences,100),
   syn_cnt = 0, tsyn_cnt = 0, stat = alterlist(upd_ocs->syns,100),
   col 0, "EXTERNAL_IDENTIFIER,", "CATALOG_DESCRIPTION,",
   "PRIMARY_MNEMONIC,", "CATALOG_CKI,", "MNEMONIC,",
   "MNEMONIC_TYPE,", "SYNONYM_CKI,", "SENTENCE_SCRIPT,",
   "USAGE_FLAG,", "ENCOUNTER_GROUP,", "SEQUENCE,",
   "OE_FIELD_MEANING,", "OE_FIELD_VALUE,"
  HEAD ocs.synonym_id
   syn_cnt = (syn_cnt+ 1), tsyn_cnt = (tsyn_cnt+ 1)
   IF (syn_cnt > 100)
    stat = alterlist(upd_ocs->syns,(tsyn_cnt+ 100)), syn_cnt = 1
   ENDIF
   upd_ocs->syns[tsyn_cnt].synonym_id = ocs.synonym_id
  HEAD os.order_sentence_id
   cnt = (cnt+ 1), tcnt = (tcnt+ 1)
   IF (cnt > 100)
    stat = alterlist(temp_qual->sentences,(tcnt+ 100)), cnt = 1
   ENDIF
   temp_qual->sentences[tcnt].sentence_id = os.order_sentence_id
  DETAIL
   IF (os.order_encntr_group_cd=0)
    temp_etype = "All"
   ELSE
    temp_etype = e_type
   ENDIF
   row + 1, out_line = concat('"',trim(os.external_identifier),'"',",",'"',
    trim(oc.description),'"',",",'"',trim(oc.primary_mnemonic),
    '"',",",'"',trim(oc.cki),'"',
    ",",'"',trim(ocs.mnemonic),'"',",",
    '"',trim(synonym_type),'"',",",'"',
    trim(ocs.cki),'"',",",'"',trim(os.order_sentence_display_line),
    '"',",",'"',trim(cnvtstring(os.usage_flag)),'"',
    ",",'"',trim(temp_etype),'"',",",
    '"',trim(cnvtstring(osd.sequence)),'"',",",'"',
    trim(oem.oe_field_meaning),'"',",",'"',trim(osd.oe_field_display_value),
    '"'), col 0,
   out_line
  FOOT REPORT
   stat = alterlist(temp_qual->sentences,tcnt), stat = alterlist(upd_ocs->syns,tsyn_cnt)
  WITH check, maxcol = 3000, format = variable,
   nullreport, noformfeed, landscape,
   maxrow = 1
 ;end select
 IF (tcnt > 0)
  SET ierrcode = 0
  DELETE  FROM order_sentence_detail osd,
    (dummyt d  WITH seq = value(tcnt))
   SET osd.seq = 1
   PLAN (d)
    JOIN (osd
    WHERE (osd.order_sentence_id=temp_qual->sentences[d.seq].sentence_id))
   WITH nocounter
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = "ORDER_SENTENCE_DETAIL"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  DELETE  FROM order_sentence os,
    (dummyt d  WITH seq = value(tcnt))
   SET os.seq = 1
   PLAN (d)
    JOIN (os
    WHERE (os.order_sentence_id=temp_qual->sentences[d.seq].sentence_id))
   WITH nocounter
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = "ORDER_SENTENCE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  DELETE  FROM filter_entity_reltn f,
    (dummyt d  WITH seq = value(tcnt))
   SET f.seq = 1
   PLAN (d)
    JOIN (f
    WHERE (f.parent_entity_id=temp_qual->sentences[d.seq].sentence_id)
     AND f.parent_entity_name="ORDER_SENTENCE")
   WITH nocounter
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = "FILTER_ENTITY_RELTN"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  DELETE  FROM long_text l,
    (dummyt d  WITH seq = value(tcnt))
   SET l.seq = 1
   PLAN (d)
    JOIN (l
    WHERE (l.parent_entity_id=temp_qual->sentences[d.seq].sentence_id)
     AND l.parent_entity_name="ORDER_SENTENCE")
   WITH nocounter
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = "LONG_TEXT"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  DELETE  FROM ord_cat_sent_r o,
    (dummyt d  WITH seq = value(tcnt))
   SET o.seq = 1
   PLAN (d)
    JOIN (o
    WHERE (o.order_sentence_id=temp_qual->sentences[d.seq].sentence_id))
   WITH nocounter
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = "ORD_CAT_SENT_R"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
 IF (tsyn_cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(tsyn_cnt)),
    order_catalog_synonym ocs,
    ord_cat_sent_r ocsr
   PLAN (d)
    JOIN (ocs
    WHERE (ocs.synonym_id=upd_ocs->syns[d.seq].synonym_id))
    JOIN (ocsr
    WHERE ocsr.synonym_id=outerjoin(ocs.synonym_id))
   ORDER BY d.seq
   HEAD d.seq
    sent_cnt = 0
   DETAIL
    IF (ocsr.synonym_id > 0)
     sent_cnt = (sent_cnt+ 1), upd_ocs->syns[d.seq].order_sent_id = ocsr.order_sentence_id
    ENDIF
   FOOT  ocs.synonym_id
    IF (sent_cnt=0)
     IF (((ocs.multiple_ord_sent_ind > 0) OR (ocs.order_sentence_id > 0)) )
      upd_ocs->syns[d.seq].mul_sent_ind = 0, upd_ocs->syns[d.seq].order_sent_id = 0.0, upd_ocs->syns[
      d.seq].upd_ind = 1
     ENDIF
    ELSEIF (sent_cnt=1)
     IF (((ocs.multiple_ord_sent_ind > 0) OR (((ocs.order_sentence_id=0) OR (ocs.order_sentence_id
      != ocsr.order_sentence_id)) )) )
      upd_ocs->syns[d.seq].mul_sent_ind = 0, upd_ocs->syns[d.seq].upd_ind = 1
     ENDIF
    ELSE
     IF (((ocs.multiple_ord_sent_ind=0) OR (ocs.order_sentence_id > 0)) )
      upd_ocs->syns[d.seq].mul_sent_ind = 1, upd_ocs->syns[d.seq].order_sent_id = 0.0, upd_ocs->syns[
      d.seq].upd_ind = 1
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  SET ierrcode = 0
  UPDATE  FROM order_catalog_synonym o,
    (dummyt d  WITH seq = value(tsyn_cnt))
   SET o.multiple_ord_sent_ind = upd_ocs->syns[d.seq].mul_sent_ind, o.order_sentence_id = upd_ocs->
    syns[d.seq].order_sent_id, o.updt_id = reqinfo->updt_id,
    o.updt_dt_tm = cnvtdatetime(curdate,curtime), o.updt_task = reqinfo->updt_task, o.updt_applctx =
    reqinfo->updt_applctx,
    o.updt_cnt = (o.updt_cnt+ 1)
   PLAN (d
    WHERE (upd_ocs->syns[d.seq].upd_ind=1))
    JOIN (o
    WHERE (o.synonym_id=upd_ocs->syns[d.seq].synonym_id))
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = "UPDATE OCS"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
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
