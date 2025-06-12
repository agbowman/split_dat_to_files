CREATE PROGRAM br_upd_ocs_sentences:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Starting <br_upd_ocs_sentences.prg> script"
 DECLARE serrmsg = c132 WITH public, noconstant("")
 DECLARE ierrcode = i4 WITH public, noconstant(0)
 DECLARE cnt = i2 WITH public, noconstant(0)
 DECLARE scnt = i2 WITH public, noconstant(0)
 SET error_flag = "N"
 RECORD temp(
   1 syn[*]
     2 synonym_id = f8
     2 sentence_id = f8
     2 bmultiplesentenceids = i2
 )
 UPDATE  FROM order_sentence_detail o
  SET o.oe_field_value = 1, o.updt_dt_tm = cnvtdatetime(curdate,curtime), o.updt_cnt = (o.updt_cnt+ 1
   )
  PLAN (o
   WHERE o.field_type_flag=7
    AND o.oe_field_display_value="Yes"
    AND o.updt_task=3202004)
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme Update (2) Failed:",serrmsg)
  ROLLBACK
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET cnt = 0
 SELECT INTO "nl:"
  FROM ord_cat_sent_r r
  PLAN (r
   WHERE r.updt_task=3202004)
  ORDER BY r.synonym_id
  HEAD r.synonym_id
   scnt = 0, cnt = (cnt+ 1), stat = alterlist(temp->syn,cnt),
   temp->syn[cnt].synonym_id = r.synonym_id
  DETAIL
   scnt = (scnt+ 1)
   IF (scnt=1)
    temp->syn[cnt].sentence_id = r.order_sentence_id, temp->syn[cnt].bmultiplesentenceids = 0
   ELSE
    temp->syn[cnt].bmultiplesentenceids = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (cnt=0)
  SET readme_data->status = "S"
  SET readme_data->message = "Readme Succeeded: Nothing qualified on ord_cat_sent_r table."
  GO TO exit_script
 ENDIF
 UPDATE  FROM order_catalog_synonym o,
   (dummyt d1  WITH seq = value(size(temp->syn,5)))
  SET o.multiple_ord_sent_ind = 0, o.order_sentence_id = temp->syn[d1.seq].sentence_id, o.updt_dt_tm
    = cnvtdatetime(curdate,curtime),
   o.updt_cnt = (o.updt_cnt+ 1)
  PLAN (d1
   WHERE (temp->syn[d1.seq].synonym_id > 0)
    AND (temp->syn[d1.seq].bmultiplesentenceids=0))
   JOIN (o
   WHERE (o.synonym_id=temp->syn[d1.seq].synonym_id))
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme Update (1) Failed:",serrmsg)
  ROLLBACK
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 UPDATE  FROM order_catalog_synonym o,
   (dummyt d1  WITH seq = value(size(temp->syn,5)))
  SET o.multiple_ord_sent_ind = 1, o.order_sentence_id = 0, o.updt_dt_tm = cnvtdatetime(curdate,
    curtime),
   o.updt_cnt = (o.updt_cnt+ 1)
  PLAN (d1
   WHERE (temp->syn[d1.seq].synonym_id > 0)
    AND (temp->syn[d1.seq].bmultiplesentenceids=1))
   JOIN (o
   WHERE (o.synonym_id=temp->syn[d1.seq].synonym_id))
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme Update (2) Failed:",serrmsg)
  ROLLBACK
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <br_upd_ocs_sentences_mod.prg> script"
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
