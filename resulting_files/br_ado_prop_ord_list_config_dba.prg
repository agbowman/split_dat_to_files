CREATE PROGRAM br_ado_prop_ord_list_config:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_ado_prop_ord_list_config.prg> script"
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE sequence = vc WITH protect
 DECLARE counter = i4 WITH protect, noconstant(1)
 FREE RECORD br_synonym_seq
 RECORD br_synonym_seq(
   1 sequences[*]
     2 synonym_seq = vc
 )
 FREE RECORD br_existsinfo
 RECORD br_existsinfo(
   1 list_0[*]
     2 existsind = i2
     2 option_id = f8
 )
 SET cnt = size(requestin->list_0,5)
 SET stat = alterlist(br_existsinfo->list_0,cnt)
 SET stat = alterlist(br_synonym_seq->sequences,cnt)
 SET sequence = "0"
 SELECT INTO "nl:"
  FROM br_ado_proposed_option o,
   (dummyt d  WITH seq = value(cnt))
  PLAN (d)
   JOIN (o
   WHERE o.option_mean=cnvtupper(requestin->list_0[d.seq].option_mean))
  DETAIL
   br_existsinfo->list_0[d.seq].option_id = o.br_ado_proposed_option_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM br_ado_proposed_ord_list ol,
   (dummyt d  WITH seq = value(cnt))
  PLAN (d)
   JOIN (ol
   WHERE (ol.br_ado_proposed_option_id=br_existsinfo->list_0[d.seq].option_id)
    AND (ol.synonym_unique_ident=requestin->list_0[d.seq].unique_identifier))
  DETAIL
   br_existsinfo->list_0[d.seq].existsind = 1
  WITH nocounter
 ;end select
 FOR (i = 1 TO cnt)
   SET sequence = "1"
   IF (i > 1)
    IF ((br_existsinfo->list_0[i].option_id=br_existsinfo->list_0[(i - 1)].option_id))
     SET counter = (counter+ 1)
    ELSE
     SET counter = 1
    ENDIF
    SET sequence = build(counter)
   ENDIF
   SET br_synonym_seq->sequences[i].synonym_seq = sequence
 ENDFOR
 INSERT  FROM br_ado_proposed_ord_list ol,
   (dummyt d  WITH seq = value(cnt))
  SET ol.br_ado_proposed_ord_list_id = seq(bedrock_seq,nextval), ol.br_ado_proposed_option_id =
   br_existsinfo->list_0[d.seq].option_id, ol.synonym_unique_ident = requestin->list_0[d.seq].
   unique_identifier,
   ol.synonym_name = requestin->list_0[d.seq].synonym, ol.proposed_sentence_txt = requestin->list_0[d
   .seq].sentence_text, ol.synonym_seq = cnvtint(br_synonym_seq->sequences[d.seq].synonym_seq),
   ol.updt_cnt = 0, ol.updt_dt_tm = cnvtdatetime(curdate,curtime3), ol.updt_id = reqinfo->updt_id,
   ol.updt_task = reqinfo->updt_task, ol.updt_applctx = reqinfo->updt_applctx
  PLAN (d
   WHERE (br_existsinfo->list_0[d.seq].existsind=0))
   JOIN (ol)
  WITH nocounter
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure inserting Advisor Order Synonyms >> ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 UPDATE  FROM br_ado_proposed_ord_list ol,
   (dummyt d  WITH seq = value(cnt))
  SET ol.proposed_sentence_txt = requestin->list_0[d.seq].sentence_text, ol.synonym_seq = cnvtint(
    br_synonym_seq->sequences[d.seq].synonym_seq), ol.updt_cnt = (ol.updt_cnt+ 1),
   ol.updt_dt_tm = cnvtdatetime(curdate,curtime3), ol.updt_id = reqinfo->updt_id, ol.updt_task =
   reqinfo->updt_task,
   ol.updt_applctx = reqinfo->updt_applctx
  PLAN (d
   WHERE (br_existsinfo->list_0[d.seq].existsind=1))
   JOIN (ol
   WHERE (ol.br_ado_proposed_option_id=br_existsinfo->list_0[d.seq].option_id)
    AND (ol.synonym_unique_ident=requestin->list_0[d.seq].unique_identifier))
  WITH nocounter
 ;end update
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure Updating Advisor Order Sentence Text >> ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <br_ado_prop_ord_list_config.prg> script"
#exit_script
 FREE RECORD br_existsinfo
END GO
