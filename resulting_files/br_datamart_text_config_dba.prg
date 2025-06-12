CREATE PROGRAM br_datamart_text_config:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_datamart_text_config.prg> script"
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE x = i4 WITH protect, noconstant(0)
 SET cnt = size(requestin->list_0,5)
 FREE RECORD br_metainfo
 RECORD br_metainfo(
   1 list_0[*]
     2 datamarttextid = f8
     2 categoryid = f8
     2 reportid = f8
     2 filterid = f8
     2 existsind = i2
     2 texttypemeanmatches = i2
 )
 DELETE  FROM br_long_text t
  WHERE t.parent_entity_name="BR_DATAMART_TEXT"
   AND t.parent_entity_id IN (
  (SELECT
   d.br_datamart_text_id
   FROM br_datamart_text d,
    br_datamart_category c
   WHERE c.category_mean=cnvtupper(requestin->list_0[1].topic_mean)
    AND d.br_datamart_category_id=c.br_datamart_category_id))
  WITH nocounter
 ;end delete
 DELETE  FROM br_datamart_text t
  WHERE t.br_datamart_category_id IN (
  (SELECT
   c.br_datamart_category_id
   FROM br_datamart_category c
   WHERE c.category_mean=cnvtupper(requestin->list_0[1].topic_mean)))
  WITH nocounter
 ;end delete
 SET stat = alterlist(br_metainfo->list_0,cnt)
 SELECT INTO "nl:"
  FROM br_datamart_category b,
   (dummyt d  WITH seq = value(cnt))
  PLAN (d)
   JOIN (b
   WHERE b.category_mean=cnvtupper(requestin->list_0[d.seq].topic_mean))
  DETAIL
   br_metainfo->list_0[d.seq].categoryid = b.br_datamart_category_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM br_datamart_report b,
   (dummyt d  WITH seq = value(cnt))
  PLAN (d)
   JOIN (b
   WHERE (b.br_datamart_category_id=br_metainfo->list_0[d.seq].categoryid)
    AND b.report_mean=cnvtupper(requestin->list_0[d.seq].report_mean))
  DETAIL
   br_metainfo->list_0[d.seq].reportid = b.br_datamart_report_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM br_datamart_filter b,
   (dummyt d  WITH seq = value(cnt))
  PLAN (d)
   JOIN (b
   WHERE (b.br_datamart_category_id=br_metainfo->list_0[d.seq].categoryid)
    AND b.filter_mean=cnvtupper(requestin->list_0[d.seq].filter_mean))
  DETAIL
   br_metainfo->list_0[d.seq].filterid = b.br_datamart_filter_id
  WITH nocounter
 ;end select
 FOR (x = 1 TO cnt)
   SELECT INTO "nl:"
    seqval = seq(bedrock_seq,nextval)
    FROM dual
    DETAIL
     br_metainfo->list_0[x].datamarttextid = cnvtreal(seqval)
    WITH nocounter
   ;end select
 ENDFOR
 INSERT  FROM br_datamart_text b,
   (dummyt d  WITH seq = value(cnt))
  SET b.br_datamart_text_id = br_metainfo->list_0[d.seq].datamarttextid, b.br_datamart_report_id =
   br_metainfo->list_0[d.seq].reportid, b.br_datamart_category_id = br_metainfo->list_0[d.seq].
   categoryid,
   b.br_datamart_filter_id = br_metainfo->list_0[d.seq].filterid, b.text_type_mean = cnvtupper(
    requestin->list_0[d.seq].text_type), b.text_seq = cnvtint(requestin->list_0[d.seq].sequence),
   b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(sysdate), b.updt_id = reqinfo->updt_id,
   b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx
  PLAN (d)
   JOIN (b)
  WITH nocounter
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure inserting datamart text >> ",errmsg)
  GO TO exit_script
 ENDIF
 INSERT  FROM br_long_text b,
   (dummyt d  WITH seq = value(cnt))
  SET b.long_text_id = seq(bedrock_seq,nextval), b.parent_entity_name = "BR_DATAMART_TEXT", b
   .parent_entity_id = br_metainfo->list_0[d.seq].datamarttextid,
   b.long_text = requestin->list_0[d.seq].text, b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(sysdate),
   b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
   updt_applctx
  PLAN (d)
   JOIN (b)
  WITH nocounter
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed inserting datamart long text >> ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <br_datamart_text_config.prg> script"
#exit_script
 CALL echorecord(readme_data)
 FREE RECORD br_metainfo
END GO
