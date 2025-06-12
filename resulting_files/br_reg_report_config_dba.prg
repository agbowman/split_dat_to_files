CREATE PROGRAM br_reg_report_config:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_reg_report_config.prg> script"
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE cnt = i4 WITH protect, noconstant(0)
 FREE RECORD br_existsinfo
 RECORD br_existsinfo(
   1 list_0[*]
     2 existsind = i2
     2 mpage_pos = i2
     2 mpage_seq = i4
     2 mp_label = i2
     2 mp_nbr_label = i2
     2 mp_link = i2
     2 mp_exp_collapse = i2
     2 mp_lookback = i2
     2 mp_max_results = i2
     2 mp_scrolling = i2
     2 mp_truncate = i2
 )
 SET cnt = size(requestin->list_0,5)
 SET stat = alterlist(br_existsinfo->list_0,cnt)
 FOR (y = 1 TO cnt)
   IF (validate(requestin->list_0[y].mpage_pos,"") > " ")
    IF (cnvtupper(requestin->list_0[y].mpage_pos)="LEFT")
     SET br_existsinfo->list_0[y].mpage_pos = 1
    ELSEIF (cnvtupper(requestin->list_0[y].mpage_pos)="RIGHT")
     SET br_existsinfo->list_0[y].mpage_pos = 2
    ELSEIF (cnvtupper(requestin->list_0[y].mpage_pos)="ORGANIZER")
     SET br_existsinfo->list_0[y].mpage_pos = 3
    ELSE
     SET br_existsinfo->list_0[y].mpage_pos = 0
    ENDIF
   ELSE
    SET br_existsinfo->list_0[y].mpage_pos = 0
   ENDIF
   IF (validate(requestin->list_0[y].mpage_seq,"") > " ")
    SET br_existsinfo->list_0[y].mpage_seq = cnvtint(requestin->list_0[y].mpage_seq)
   ELSE
    SET br_existsinfo->list_0[y].mpage_seq = 0
   ENDIF
   IF (validate(requestin->list_0[y].mp_label,"") > " ")
    IF (cnvtupper(requestin->list_0[y].mp_label)="YES")
     SET br_existsinfo->list_0[y].mp_label = 1
    ELSE
     SET br_existsinfo->list_0[y].mp_label = 0
    ENDIF
   ELSE
    SET br_existsinfo->list_0[y].mp_label = 0
   ENDIF
   IF (validate(requestin->list_0[y].mp_nbr_label,"") > " ")
    IF (cnvtupper(requestin->list_0[y].mp_nbr_label)="YES")
     SET br_existsinfo->list_0[y].mp_nbr_label = 1
    ELSE
     SET br_existsinfo->list_0[y].mp_nbr_label = 0
    ENDIF
   ELSE
    SET br_existsinfo->list_0[y].mp_nbr_label = 0
   ENDIF
   IF (validate(requestin->list_0[y].mp_link,"") > " ")
    IF (cnvtupper(requestin->list_0[y].mp_link)="YES")
     SET br_existsinfo->list_0[y].mp_link = 1
    ELSE
     SET br_existsinfo->list_0[y].mp_link = 0
    ENDIF
   ELSE
    SET br_existsinfo->list_0[y].mp_link = 0
   ENDIF
   IF (validate(requestin->list_0[y].mp_exp_collapse,"") > " ")
    IF (cnvtupper(requestin->list_0[y].mp_exp_collapse)="YES")
     SET br_existsinfo->list_0[y].mp_exp_collapse = 1
    ELSE
     SET br_existsinfo->list_0[y].mp_exp_collapse = 0
    ENDIF
   ELSE
    SET br_existsinfo->list_0[y].mp_exp_collapse = 0
   ENDIF
   IF (validate(requestin->list_0[y].mp_lookback,"") > " ")
    IF (cnvtupper(requestin->list_0[y].mp_lookback)="YES")
     SET br_existsinfo->list_0[y].mp_lookback = 1
    ELSE
     SET br_existsinfo->list_0[y].mp_lookback = 0
    ENDIF
   ELSE
    SET br_existsinfo->list_0[y].mp_lookback = 0
   ENDIF
   IF (validate(requestin->list_0[y].mp_max_results,"") > " ")
    IF (cnvtupper(requestin->list_0[y].mp_max_results)="YES")
     SET br_existsinfo->list_0[y].mp_max_results = 1
    ELSE
     SET br_existsinfo->list_0[y].mp_max_results = 0
    ENDIF
   ELSE
    SET br_existsinfo->list_0[y].mp_max_results = 0
   ENDIF
   IF (validate(requestin->list_0[y].mp_scrolling,"") > " ")
    IF (cnvtupper(requestin->list_0[y].mp_scrolling)="YES")
     SET br_existsinfo->list_0[y].mp_scrolling = 1
    ELSE
     SET br_existsinfo->list_0[y].mp_scrolling = 0
    ENDIF
   ELSE
    SET br_existsinfo->list_0[y].mp_scrolling = 0
   ENDIF
   IF (validate(requestin->list_0[y].mp_truncate,"") > " ")
    IF (cnvtupper(requestin->list_0[y].mp_truncate)="YES")
     SET br_existsinfo->list_0[y].mp_truncate = 1
    ELSE
     SET br_existsinfo->list_0[y].mp_truncate = 0
    ENDIF
   ELSE
    SET br_existsinfo->list_0[y].mp_truncate = 0
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  FROM br_datamart_report b,
   (dummyt d  WITH seq = value(cnt))
  PLAN (d)
   JOIN (b
   WHERE b.report_mean=cnvtupper(requestin->list_0[d.seq].report_mean))
  DETAIL
   br_existsinfo->list_0[d.seq].existsind = 1
  WITH nocounter
 ;end select
 INSERT  FROM br_datamart_report b,
   (dummyt d  WITH seq = value(cnt))
  SET b.br_datamart_report_id = seq(bedrock_seq,nextval), b.br_datamart_category_id =
   (SELECT
    b2.br_datamart_category_id
    FROM br_datamart_category b2
    WHERE b2.category_mean=cnvtupper(requestin->list_0[d.seq].topic_mean)), b.report_name = requestin
   ->list_0[d.seq].report_display,
   b.report_mean = cnvtupper(requestin->list_0[d.seq].report_mean), b.report_seq = cnvtint(requestin
    ->list_0[d.seq].sequence), b.lighthouse_value = requestin->list_0[d.seq].lighthouse_goal,
   b.mpage_pos_flag = br_existsinfo->list_0[d.seq].mpage_pos, b.mpage_pos_seq = br_existsinfo->
   list_0[d.seq].mpage_seq, b.mpage_label_ind = br_existsinfo->list_0[d.seq].mp_label,
   b.mpage_nbr_label_ind = br_existsinfo->list_0[d.seq].mp_nbr_label, b.mpage_link_ind =
   br_existsinfo->list_0[d.seq].mp_link, b.mpage_exp_collapse_ind = br_existsinfo->list_0[d.seq].
   mp_exp_collapse,
   b.mpage_lookback_ind = br_existsinfo->list_0[d.seq].mp_lookback, b.mpage_max_results_ind =
   br_existsinfo->list_0[d.seq].mp_max_results, b.mpage_scroll_ind = br_existsinfo->list_0[d.seq].
   mp_scrolling,
   b.mpage_truncate_ind = br_existsinfo->list_0[d.seq].mp_truncate, b.updt_cnt = 0, b.updt_dt_tm =
   cnvtdatetime(curdate,curtime3),
   b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
   updt_applctx
  PLAN (d
   WHERE (br_existsinfo->list_0[d.seq].existsind=0))
   JOIN (b)
  WITH nocounter
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure inserting datamart reports >> ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 UPDATE  FROM br_datamart_report b,
   (dummyt d  WITH seq = value(cnt))
  SET b.lighthouse_value = requestin->list_0[d.seq].lighthouse_goal, b.report_name = requestin->
   list_0[d.seq].report_display, b.report_seq = cnvtint(requestin->list_0[d.seq].sequence),
   b.mpage_pos_flag = br_existsinfo->list_0[d.seq].mpage_pos, b.mpage_pos_seq = br_existsinfo->
   list_0[d.seq].mpage_seq, b.mpage_label_ind = br_existsinfo->list_0[d.seq].mp_label,
   b.mpage_nbr_label_ind = br_existsinfo->list_0[d.seq].mp_nbr_label, b.mpage_link_ind =
   br_existsinfo->list_0[d.seq].mp_link, b.mpage_exp_collapse_ind = br_existsinfo->list_0[d.seq].
   mp_exp_collapse,
   b.mpage_lookback_ind = br_existsinfo->list_0[d.seq].mp_lookback, b.mpage_max_results_ind =
   br_existsinfo->list_0[d.seq].mp_max_results, b.mpage_scroll_ind = br_existsinfo->list_0[d.seq].
   mp_scrolling,
   b.mpage_truncate_ind = br_existsinfo->list_0[d.seq].mp_truncate, b.updt_cnt = (b.updt_cnt+ 1), b
   .updt_dt_tm = cnvtdatetime(curdate,curtime3),
   b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
   updt_applctx
  PLAN (d
   WHERE (br_existsinfo->list_0[d.seq].existsind=1))
   JOIN (b
   WHERE b.report_mean=cnvtupper(requestin->list_0[d.seq].report_mean))
  WITH nocounter
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure inserting datamart reports >> ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <br_reg_report_config.prg> script"
#exit_script
 FREE RECORD br_existsinfo
END GO
