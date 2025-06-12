CREATE PROGRAM br_datamart_rpt_default_config:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_datamart_rpt_default_config.prg> script"
 SET cnt = size(requestin->list_0,5)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE catcnt = i4 WITH protect, noconstant(0)
 DECLARE cat_id = f8 WITH protect, noconstant(0.0)
 SELECT INTO "nl:"
  FROM br_datamart_category bdc,
   (dummyt d  WITH seq = value(cnt))
  PLAN (d)
   JOIN (bdc
   WHERE bdc.category_mean=cnvtupper(requestin->list_0[d.seq].topic_mean))
  ORDER BY bdc.br_datamart_category_id
  HEAD bdc.br_datamart_category_id
   IF (bdc.br_datamart_category_id > 0)
    catcnt += 1, cat_id = bdc.br_datamart_category_id
   ENDIF
  WITH nocounter
 ;end select
 IF (catcnt > 1)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Multiple category ids found for topic mean ",requestin->list_0[d
   .seq].topic_mean)
  GO TO exit_script
 ENDIF
 FOR (y = 1 TO cnt)
   IF (cnvtupper(requestin->list_0[y].mp_param_mean)="MP_LOOK_BACK_UNITS")
    SET vflag = 0
    IF ((requestin->list_0[y].default_value="ALLENC*"))
     SET vflag = 1
    ELSEIF ((requestin->list_0[y].default_value="CURRENC*"))
     SET vflag = 2
    ENDIF
    IF (vflag > 0)
     UPDATE  FROM br_datamart_value v2
      SET v2.value_type_flag = vflag, v2.mpage_param_mean = "mp_look_back_units", v2
       .mpage_param_value = "",
       v2.parent_entity_id = 0, v2.parent_entity_name = " ", v2.updt_cnt = (v2.updt_cnt+ 1),
       v2.updt_dt_tm = cnvtdatetime(sysdate), v2.updt_id = reqinfo->updt_id, v2.updt_task = reqinfo->
       updt_task,
       v2.updt_applctx = reqinfo->updt_applctx
      WHERE v2.br_datamart_value_id IN (
      (SELECT
       v.br_datamart_value_id
       FROM br_datamart_value v,
        br_datamart_report c,
        br_datamart_report_filter_r r
       WHERE c.report_mean=cnvtupper(requestin->list_0[y].report_mean)
        AND c.br_datamart_category_id=cat_id
        AND r.br_datamart_report_id=c.br_datamart_report_id
        AND v.br_datamart_filter_id=r.br_datamart_filter_id
        AND v.br_datamart_category_id=c.br_datamart_category_id
        AND cnvtupper(v.mpage_param_mean)="MP_LOOK_BACK"))
      WITH nocounter
     ;end update
     IF (error(errmsg,0) > 0)
      ROLLBACK
      SET readme_data->status = "F"
      SET readme_data->message = concat("Failure updating existing datamart report defaults >> ",
       errmsg)
      GO TO exit_script
     ELSE
      COMMIT
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 DELETE  FROM br_datamart_report_default
  WHERE br_datamart_report_id IN (
  (SELECT
   t.br_datamart_report_id
   FROM br_datamart_report t
   WHERE t.br_datamart_category_id=cat_id))
  WITH nocounter
 ;end delete
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE cnt = i4 WITH protect, noconstant(0)
 SET cnt = size(requestin->list_0,5)
 INSERT  FROM br_datamart_report_default b,
   (dummyt d  WITH seq = value(cnt))
  SET b.br_datamart_report_default_id = seq(bedrock_seq,nextval), b.br_datamart_report_id =
   (SELECT
    b2.br_datamart_report_id
    FROM br_datamart_report b2
    WHERE b2.report_mean=cnvtupper(requestin->list_0[d.seq].report_mean)
     AND b2.br_datamart_category_id=cat_id), b.mpage_param_mean = cnvtupper(requestin->list_0[d.seq].
    mp_param_mean),
   b.mpage_param_value = requestin->list_0[d.seq].default_value, b.updt_cnt = 0, b.updt_dt_tm =
   cnvtdatetime(sysdate),
   b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
   updt_applctx
  PLAN (d)
   JOIN (b)
  WITH nocounter
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure inserting datamart report defaults >> ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <br_datamart_rpt_default_config.prg> script"
#exit_script
 CALL echorecord(readme_data)
 FREE RECORD br_existsinfo
END GO
