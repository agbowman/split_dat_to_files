CREATE PROGRAM br_datamart_std_filter_config:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_datamart_std_filter_config.prg> script"
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE num = i4 WITH noconstant(0)
 SET cnt = size(requestin->list_0,5)
 FREE RECORD br_existsinfo
 RECORD br_existsinfo(
   1 list_0[*]
     2 existsind = i2
     2 categoryid = f8
     2 filter_id = f8
     2 del_values_ind = i2
 )
 SET stat = alterlist(br_existsinfo->list_0,cnt)
 FREE RECORD filters_to_del
 RECORD filters_to_del(
   1 filters[*]
     2 category_id = f8
     2 filter_id = f8
 )
 FREE RECORD tfilter
 RECORD tfilter(
   1 filters[*]
     2 filter_limit = i4
 )
 SET stat = alterlist(tfilter->filters,cnt)
 FOR (x = 1 TO cnt)
   IF (validate(requestin->list_0[x].filter_limit,"F") != "F")
    SET tfilter->filters[x].filter_limit = cnvtint(trim(requestin->list_0[x].filter_limit))
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  FROM br_datamart_category b,
   (dummyt d  WITH seq = value(cnt))
  PLAN (d)
   JOIN (b
   WHERE b.category_mean=cnvtupper(requestin->list_0[d.seq].topic_mean))
  DETAIL
   br_existsinfo->list_0[d.seq].categoryid = b.br_datamart_category_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM br_datamart_filter b,
   (dummyt d  WITH seq = value(cnt))
  PLAN (d)
   JOIN (b
   WHERE (b.br_datamart_category_id=br_existsinfo->list_0[d.seq].categoryid)
    AND b.filter_mean=cnvtupper(requestin->list_0[d.seq].filter_mean))
  DETAIL
   br_existsinfo->list_0[d.seq].existsind = 1
   IF (cnvtupper(b.filter_category_mean) != cnvtupper(requestin->list_0[d.seq].filter_category_mean))
    br_existsinfo->list_0[d.seq].del_values_ind = 1, br_existsinfo->list_0[d.seq].filter_id = b
    .br_datamart_filter_id
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   br_datamart_filter b
  PLAN (d)
   JOIN (b
   WHERE (b.br_datamart_category_id=br_existsinfo->list_0[d.seq].categoryid))
  ORDER BY b.br_datamart_filter_id
  HEAD REPORT
   tot_del = 0, filters = 0, stat = alterlist(filters_to_del->filters,100)
  DETAIL
   pos = 0, filter_mean = cnvtupper(b.filter_mean)
   FOR (i = 1 TO cnt)
     IF (filter_mean=cnvtupper(requestin->list_0[i].filter_mean))
      pos = i, i = cnt
     ENDIF
   ENDFOR
   IF (pos=0)
    tot_del += 1, filters += 1
    IF (filters > 100)
     stat = alterlist(filters_to_del->filters,(tot_del+ 100)), filters = 1
    ENDIF
    filters_to_del->filters[tot_del].category_id = b.br_datamart_category_id, filters_to_del->
    filters[tot_del].filter_id = b.br_datamart_filter_id
   ENDIF
  FOOT REPORT
   stat = alterlist(filters_to_del->filters,tot_del)
  WITH nocounter
 ;end select
 DELETE  FROM br_datamart_value b,
   (dummyt d  WITH seq = value(cnt))
  SET b.seq = 1
  PLAN (d
   WHERE (br_existsinfo->list_0[d.seq].del_values_ind=1))
   JOIN (b
   WHERE (b.br_datamart_category_id=br_existsinfo->list_0[d.seq].categoryid)
    AND (b.br_datamart_filter_id=br_existsinfo->list_0[d.seq].filter_id))
  WITH nocounter
 ;end delete
 INSERT  FROM br_datamart_filter b,
   (dummyt d  WITH seq = value(cnt))
  SET b.br_datamart_filter_id = seq(bedrock_seq,nextval), b.br_datamart_category_id = br_existsinfo->
   list_0[d.seq].categoryid, b.filter_mean = cnvtupper(requestin->list_0[d.seq].filter_mean),
   b.filter_display = requestin->list_0[d.seq].display, b.filter_seq = cnvtint(requestin->list_0[d
    .seq].sequence), b.filter_category_mean = cnvtupper(requestin->list_0[d.seq].filter_category_mean
    ),
   b.filter_limit = tfilter->filters[d.seq].filter_limit, b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime
   (sysdate),
   b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
   updt_applctx
  PLAN (d
   WHERE (br_existsinfo->list_0[d.seq].existsind=0))
   JOIN (b)
  WITH nocounter
 ;end insert
 UPDATE  FROM br_datamart_filter b,
   (dummyt d  WITH seq = value(cnt))
  SET b.filter_display = requestin->list_0[d.seq].display, b.filter_seq = cnvtint(requestin->list_0[d
    .seq].sequence), b.filter_category_mean = cnvtupper(requestin->list_0[d.seq].filter_category_mean
    ),
   b.filter_limit = tfilter->filters[d.seq].filter_limit, b.updt_cnt = (b.updt_cnt+ 1), b.updt_dt_tm
    = cnvtdatetime(sysdate),
   b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
   updt_applctx
  PLAN (d
   WHERE (br_existsinfo->list_0[d.seq].existsind=1))
   JOIN (b
   WHERE (b.br_datamart_category_id=br_existsinfo->list_0[d.seq].categoryid)
    AND b.filter_mean=cnvtupper(requestin->list_0[d.seq].filter_mean))
  WITH nocounter
 ;end update
 SET tot_del = size(filters_to_del->filters,5)
 IF (tot_del > 0)
  DELETE  FROM br_datamart_value v,
    (dummyt d  WITH seq = value(tot_del))
   SET v.seq = 1
   PLAN (d)
    JOIN (v
    WHERE (v.br_datamart_filter_id=filters_to_del->filters[d.seq].filter_id)
     AND (v.br_datamart_category_id=filters_to_del->filters[d.seq].category_id))
   WITH nocounter
  ;end delete
  DELETE  FROM br_datamart_report_filter_r b,
    (dummyt d  WITH seq = value(tot_del))
   SET b.seq = 1
   PLAN (d)
    JOIN (b
    WHERE (b.br_datamart_filter_id=filters_to_del->filters[d.seq].filter_id))
   WITH nocounter
  ;end delete
  FOR (i = 1 TO tot_del)
    DELETE  FROM br_datamart_default_detail dd
     WHERE dd.br_datamart_default_id IN (
     (SELECT
      dd2.br_datamart_default_id
      FROM br_datamart_default_detail dd2,
       br_datamart_default bd
      WHERE dd2.br_datamart_default_id=bd.br_datamart_default_id
       AND (bd.br_datamart_filter_id=filters_to_del->filters[i].filter_id)))
     WITH nocounter
    ;end delete
  ENDFOR
  DELETE  FROM br_datamart_default b,
    (dummyt d  WITH seq = value(tot_del))
   SET b.seq = 1
   PLAN (d)
    JOIN (b
    WHERE (b.br_datamart_filter_id=filters_to_del->filters[d.seq].filter_id))
   WITH nocounter
  ;end delete
  DELETE  FROM br_datamart_text b,
    (dummyt d  WITH seq = value(tot_del))
   SET b.seq = 1
   PLAN (d)
    JOIN (b
    WHERE (b.br_datamart_category_id=filters_to_del->filters[d.seq].category_id)
     AND (b.br_datamart_filter_id=filters_to_del->filters[d.seq].filter_id))
   WITH nocounter
  ;end delete
  DELETE  FROM br_datamart_filter b,
    (dummyt d  WITH seq = value(tot_del))
   SET b.seq = 1
   PLAN (d)
    JOIN (b
    WHERE (b.br_datamart_category_id=filters_to_del->filters[d.seq].category_id)
     AND (b.br_datamart_filter_id=filters_to_del->filters[d.seq].filter_id))
   WITH nocounter
  ;end delete
 ENDIF
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed inserting datamart filters >> ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <br_datamart_std_filter_config.prg> script"
#exit_script
 CALL echorecord(readme_data)
 FREE RECORD br_existsinfo
END GO
