CREATE PROGRAM br_datamart_std_text_config:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_datamart_std_text_config.prg> script"
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
 FREE RECORD deletetext
 RECORD deletetext(
   1 list_0[*]
     2 datamarttextid = f8
 )
 SET deletecount = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   br_datamart_category c,
   br_datamart_text t
  PLAN (d
   WHERE (requestin->list_0[d.seq].report_mean IN (" ", null))
    AND (requestin->list_0[d.seq].filter_mean IN (" ", null)))
   JOIN (c
   WHERE c.category_mean="VB_*")
   JOIN (t
   WHERE t.br_datamart_category_id=c.br_datamart_category_id
    AND t.br_datamart_filter_id=0
    AND t.br_datamart_report_id=0)
  DETAIL
   deletecount += 1, stat = alterlist(deletetext->list_0,deletecount), deletetext->list_0[deletecount
   ].datamarttextid = t.br_datamart_text_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   br_datamart_category c,
   br_datamart_report b,
   br_datamart_text t
  PLAN (d
   WHERE (requestin->list_0[d.seq].report_mean > " "))
   JOIN (c
   WHERE c.category_mean="VB_*")
   JOIN (b
   WHERE b.br_datamart_category_id=c.br_datamart_category_id
    AND b.report_mean=cnvtupper(requestin->list_0[d.seq].report_mean))
   JOIN (t
   WHERE t.br_datamart_category_id=b.br_datamart_category_id
    AND t.br_datamart_filter_id=0
    AND t.br_datamart_report_id=b.br_datamart_report_id)
  DETAIL
   deletecount += 1, stat = alterlist(deletetext->list_0,deletecount), deletetext->list_0[deletecount
   ].datamarttextid = t.br_datamart_text_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   br_datamart_category c,
   br_datamart_filter b,
   br_datamart_text t
  PLAN (d
   WHERE (requestin->list_0[d.seq].filter_mean > " "))
   JOIN (c
   WHERE c.category_mean="VB_*")
   JOIN (b
   WHERE b.br_datamart_category_id=c.br_datamart_category_id
    AND b.filter_mean=cnvtupper(requestin->list_0[d.seq].filter_mean))
   JOIN (t
   WHERE t.br_datamart_category_id=b.br_datamart_category_id
    AND t.br_datamart_filter_id=b.br_datamart_filter_id
    AND t.br_datamart_report_id=0)
  DETAIL
   deletecount += 1, stat = alterlist(deletetext->list_0,deletecount), deletetext->list_0[deletecount
   ].datamarttextid = t.br_datamart_text_id
  WITH nocounter
 ;end select
 DELETE  FROM br_datamart_text t,
   (dummyt d  WITH seq = value(deletecount))
  SET t.seq = 1
  PLAN (d)
   JOIN (t
   WHERE (t.br_datamart_text_id=deletetext->list_0[d.seq].datamarttextid))
  WITH nocounter
 ;end delete
 DELETE  FROM br_long_text t,
   (dummyt d  WITH seq = value(deletecount))
  SET t.seq = 1
  PLAN (d)
   JOIN (t
   WHERE (t.parent_entity_id=deletetext->list_0[d.seq].datamarttextid)
    AND t.parent_entity_name="BR_DATAMART_TEXT")
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
   WHERE b.report_mean=cnvtupper(requestin->list_0[d.seq].report_mean)
    AND (b.br_datamart_category_id=br_metainfo->list_0[d.seq].categoryid))
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
 FREE RECORD customtext
 RECORD customtext(
   1 list_0[*]
     2 datamarttextid = f8
     2 categoryid = f8
     2 reportid = f8
     2 filterid = f8
     2 text_type = vc
     2 text_seq = vc
     2 text = vc
 )
 SET customcount = 0
 SELECT INTO "nl:"
  FROM br_datamart_category b,
   (dummyt d  WITH seq = value(cnt))
  PLAN (d
   WHERE  NOT ((requestin->list_0[d.seq].report_mean > " "))
    AND  NOT ((requestin->list_0[d.seq].filter_mean > " ")))
   JOIN (b
   WHERE b.category_mean="VB_*")
  DETAIL
   customcount += 1, stat = alterlist(customtext->list_0,customcount), customtext->list_0[customcount
   ].categoryid = b.br_datamart_category_id,
   customtext->list_0[customcount].text_type = requestin->list_0[d.seq].text_type, customtext->
   list_0[customcount].text_seq = requestin->list_0[d.seq].sequence, customtext->list_0[customcount].
   text = requestin->list_0[d.seq].text
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM br_datamart_category c,
   br_datamart_report b,
   (dummyt d  WITH seq = value(cnt))
  PLAN (d
   WHERE (requestin->list_0[d.seq].report_mean > " "))
   JOIN (c
   WHERE c.category_mean="VB_*")
   JOIN (b
   WHERE b.br_datamart_category_id=c.br_datamart_category_id
    AND b.report_mean=cnvtupper(requestin->list_0[d.seq].report_mean))
  DETAIL
   customcount += 1, stat = alterlist(customtext->list_0,customcount), customtext->list_0[customcount
   ].categoryid = b.br_datamart_category_id,
   customtext->list_0[customcount].reportid = b.br_datamart_report_id, customtext->list_0[customcount
   ].text_type = requestin->list_0[d.seq].text_type, customtext->list_0[customcount].text_seq =
   requestin->list_0[d.seq].sequence,
   customtext->list_0[customcount].text = requestin->list_0[d.seq].text
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM br_datamart_category c,
   br_datamart_filter b,
   (dummyt d  WITH seq = value(cnt))
  PLAN (d
   WHERE (requestin->list_0[d.seq].filter_mean > " "))
   JOIN (c
   WHERE c.category_mean="VB_*")
   JOIN (b
   WHERE b.br_datamart_category_id=c.br_datamart_category_id
    AND b.filter_mean=cnvtupper(requestin->list_0[d.seq].filter_mean))
  DETAIL
   customcount += 1, stat = alterlist(customtext->list_0,customcount), customtext->list_0[customcount
   ].categoryid = b.br_datamart_category_id,
   customtext->list_0[customcount].filterid = b.br_datamart_filter_id, customtext->list_0[customcount
   ].text_type = requestin->list_0[d.seq].text_type, customtext->list_0[customcount].text_seq =
   requestin->list_0[d.seq].sequence,
   customtext->list_0[customcount].text = requestin->list_0[d.seq].text
  WITH nocounter
 ;end select
 IF (customcount > 0)
  SELECT INTO "nl:"
   j = seq(bedrock_seq,nextval)
   FROM (dummyt d  WITH seq = value(customcount)),
    dual dd
   PLAN (d)
    JOIN (dd)
   DETAIL
    customtext->list_0[d.seq].datamarttextid = cnvtreal(j)
   WITH nocounter
  ;end select
  INSERT  FROM br_datamart_text b,
    (dummyt d  WITH seq = value(customcount))
   SET b.br_datamart_text_id = customtext->list_0[d.seq].datamarttextid, b.br_datamart_report_id =
    customtext->list_0[d.seq].reportid, b.br_datamart_category_id = customtext->list_0[d.seq].
    categoryid,
    b.br_datamart_filter_id = customtext->list_0[d.seq].filterid, b.text_type_mean = cnvtupper(
     customtext->list_0[d.seq].text_type), b.text_seq = cnvtint(customtext->list_0[d.seq].text_seq),
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
    (dummyt d  WITH seq = value(customcount))
   SET b.long_text_id = seq(bedrock_seq,nextval), b.parent_entity_name = "BR_DATAMART_TEXT", b
    .parent_entity_id = customtext->list_0[d.seq].datamarttextid,
    b.long_text = customtext->list_0[d.seq].text, b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(sysdate
     ),
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
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <br_datamart_std_text_config.prg> script"
#exit_script
 CALL echorecord(readme_data)
 FREE RECORD br_metainfo
 FREE RECORD customtext
END GO
