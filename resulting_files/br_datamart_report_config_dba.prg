CREATE PROGRAM br_datamart_report_config:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_datamart_report_config.prg> script"
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE catcnt = i4 WITH protect, noconstant(0)
 DECLARE tot_del = i4 WITH protect, noconstant(0)
 DECLARE cat_id = f8 WITH protect, noconstant(0.0)
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
     2 conditional_section = vc
     2 mp_add_label = i2
     2 mp_default = i2
     2 mp_date_format = i2
 )
 FREE RECORD reports_to_del
 RECORD reports_to_del(
   1 reports[*]
     2 report_id = f8
 )
 SET cnt = size(requestin->list_0,5)
 SET stat = alterlist(br_existsinfo->list_0,cnt)
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
 IF (error(errmsg,0) > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure fetching category >> ",errmsg)
  GO TO exit_script
 ENDIF
 IF (catcnt > 1)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Multiple category ids found for topic mean ",requestin->list_0[d
   .seq].topic_mean)
  GO TO exit_script
 ENDIF
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
   IF (validate(requestin->list_0[y].conditional_section,"") > " ")
    SET br_existsinfo->list_0[y].conditional_section = cnvtupper(requestin->list_0[y].
     conditional_section)
   ELSE
    SET br_existsinfo->list_0[y].conditional_section = ""
   ENDIF
   IF (validate(requestin->list_0[y].mp_add_label,"") > " ")
    IF (cnvtupper(requestin->list_0[y].mp_add_label)="YES")
     SET br_existsinfo->list_0[y].mp_add_label = 1
    ELSE
     SET br_existsinfo->list_0[y].mp_add_label = 0
    ENDIF
   ELSE
    SET br_existsinfo->list_0[y].mp_add_label = 0
   ENDIF
   IF (validate(requestin->list_0[y].mp_default,"") > " ")
    IF (cnvtupper(requestin->list_0[y].mp_default)="ON")
     SET br_existsinfo->list_0[y].mp_default = 0
    ELSE
     SET br_existsinfo->list_0[y].mp_default = 1
    ENDIF
   ELSE
    SET br_existsinfo->list_0[y].mp_default = 0
   ENDIF
   IF (validate(requestin->list_0[y].mp_date_format,"") > " ")
    IF (cnvtupper(requestin->list_0[y].mp_date_format)="YES")
     SET br_existsinfo->list_0[y].mp_date_format = 1
    ELSE
     SET br_existsinfo->list_0[y].mp_date_format = 0
    ENDIF
   ELSE
    SET br_existsinfo->list_0[y].mp_date_format = 0
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  FROM br_datamart_report b,
   (dummyt d  WITH seq = value(cnt))
  PLAN (d)
   JOIN (b
   WHERE b.report_mean=cnvtupper(requestin->list_0[d.seq].report_mean)
    AND b.br_datamart_category_id=cat_id)
  DETAIL
   br_existsinfo->list_0[d.seq].existsind = 1
  WITH nocounter
 ;end select
 DECLARE report_mean = vc
 SELECT INTO "nl:"
  FROM br_datamart_report r
  PLAN (r
   WHERE r.br_datamart_category_id=cat_id)
  ORDER BY r.br_datamart_report_id
  HEAD REPORT
   tot_del = 0, reports = 0, stat = alterlist(reports_to_del->reports,100)
  DETAIL
   pos = 0, report_mean = cnvtupper(r.report_mean)
   FOR (i = 1 TO cnt)
     IF (report_mean=cnvtupper(requestin->list_0[i].report_mean))
      pos = i, i = cnt
     ENDIF
   ENDFOR
   IF (pos=0)
    tot_del += 1, reports += 1
    IF (reports > 100)
     stat = alterlist(reports_to_del->reports,(tot_del+ 100)), reports = 1
    ENDIF
    reports_to_del->reports[tot_del].report_id = r.br_datamart_report_id
   ENDIF
  FOOT REPORT
   stat = alterlist(reports_to_del->reports,tot_del)
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure finding del reports >> ",errmsg)
  GO TO exit_script
 ENDIF
 IF (tot_del > 0)
  CALL delreportfilters(null)
  CALL delreports(null)
 ENDIF
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
   b.mpage_truncate_ind = br_existsinfo->list_0[d.seq].mp_truncate, b.cond_report_mean =
   br_existsinfo->list_0[d.seq].conditional_section, b.mpage_add_label_ind = br_existsinfo->list_0[d
   .seq].mp_add_label,
   b.mpage_default_ind = br_existsinfo->list_0[d.seq].mp_default, b.mpage_date_format_ind =
   br_existsinfo->list_0[d.seq].mp_date_format, b.updt_cnt = 0,
   b.updt_dt_tm = cnvtdatetime(sysdate), b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->
   updt_task,
   b.updt_applctx = reqinfo->updt_applctx
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
   b.mpage_truncate_ind = br_existsinfo->list_0[d.seq].mp_truncate, b.cond_report_mean =
   br_existsinfo->list_0[d.seq].conditional_section, b.mpage_add_label_ind = br_existsinfo->list_0[d
   .seq].mp_add_label,
   b.mpage_default_ind = br_existsinfo->list_0[d.seq].mp_default, b.mpage_date_format_ind =
   br_existsinfo->list_0[d.seq].mp_date_format, b.updt_cnt = (b.updt_cnt+ 1),
   b.updt_dt_tm = cnvtdatetime(sysdate), b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->
   updt_task,
   b.updt_applctx = reqinfo->updt_applctx
  PLAN (d
   WHERE (br_existsinfo->list_0[d.seq].existsind=1))
   JOIN (b
   WHERE b.report_mean=cnvtupper(requestin->list_0[d.seq].report_mean)
    AND b.br_datamart_category_id=cat_id)
  WITH nocounter
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure updating datamart reports >> ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SUBROUTINE delreportfilters(null)
   DECLARE filtercnt = i4 WITH protect, noconstant(0)
   CALL echorecord(reports_to_del)
   FREE RECORD delfilterrequest
   RECORD delfilterrequest(
     1 filters[*]
       2 br_datamart_filter_id = f8
       2 reports[*]
         3 br_datamart_report_id = f8
       2 preserve_shared_filters_ind = i2
   )
   FREE RECORD delfilterreply
   RECORD delfilterreply(
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(tot_del)),
     br_datamart_report_filter_r r
    PLAN (d)
     JOIN (r
     WHERE (r.br_datamart_report_id=reports_to_del->reports[d.seq].report_id))
    ORDER BY r.br_datamart_filter_id
    HEAD r.br_datamart_filter_id
     filtercnt += 1, stat = alterlist(delfilterrequest->filters,filtercnt), delfilterrequest->
     filters[filtercnt].br_datamart_filter_id = r.br_datamart_filter_id,
     delfilterrequest->filters[filtercnt].preserve_shared_filters_ind = 1, stat = alterlist(
      delfilterrequest->filters[filtercnt].reports,1), delfilterrequest->filters[filtercnt].reports[1
     ].br_datamart_report_id = r.br_datamart_report_id
    WITH nocounter
   ;end select
   IF (error(errmsg,0) > 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed to get filter ids. >> ",errmsg)
    GO TO exit_script
   ENDIF
   EXECUTE br_datamart_del_filters  WITH replace("REQUEST",delfilterrequest), replace("REPLY",
    delfilterreply)
   IF ((delfilterreply->status_data.status="F"))
    SET readme_data->status = "F"
    SET readme_data->message = delfilterreply->status_data.subeventstatus[1].targetobjectvalue
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE delreports(null)
   DECLARE reportcnt = i4 WITH protect, noconstant(0)
   FREE RECORD delreportrequest
   RECORD delreportrequest(
     1 reports[*]
       2 br_datamart_report_id = f8
   )
   FREE RECORD delreportreply
   RECORD delreportreply(
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(tot_del)),
     br_datamart_report r
    PLAN (d)
     JOIN (r
     WHERE (r.br_datamart_report_id=reports_to_del->reports[d.seq].report_id))
    ORDER BY r.br_datamart_report_id
    HEAD r.br_datamart_report_id
     reportcnt += 1, stat = alterlist(delreportrequest->reports,reportcnt), delreportrequest->
     reports[reportcnt].br_datamart_report_id = r.br_datamart_report_id
    WITH nocounter
   ;end select
   IF (error(errmsg,0) > 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed to get report ids. >> ",errmsg)
    GO TO exit_script
   ENDIF
   EXECUTE br_datamart_del_reports  WITH replace("REQUEST",delreportrequest), replace("REPLY",
    delreportreply)
   IF ((delreportreply->status_data.status="F"))
    SET readme_data->status = "F"
    SET readme_data->message = delreportreply->status_data.subeventstatus[1].targetobjectvalue
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <br_datamart_report_config.prg> script"
#exit_script
 CALL echorecord(readme_data)
 FREE RECORD br_existsinfo
 FREE RECORD delreportrequest
 FREE RECORD delfilterrequest
 FREE RECORD reports_to_del
 FREE RECORD delfilterreply
 FREE RECORD delreportreply
END GO
