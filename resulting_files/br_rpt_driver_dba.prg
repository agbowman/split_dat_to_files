CREATE PROGRAM br_rpt_driver:dba
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
 DECLARE rdm_errmsg = c132
 DECLARE errcode = i4
 DECLARE xcnt = i4 WITH protect, noconstant(0)
 DECLARE lloopcnt = i4 WITH protect, noconstant(0)
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Starting <br_rpt_driver.prg> script"
 RECORD tempx(
   1 xlist[*]
     2 xray_name = vc
 )
 RECORD reply(
   1 statlist[*]
     2 statistic_meaning = vc
     2 status_flag = i2
     2 qualifying_items = i4
     2 total_items = i4
   1 collist[*]
     2 header_text = vc
     2 data_type = i2
     2 hide_ind = i2
   1 rowlist[*]
     2 celllist[*]
       3 date_value = dq8
       3 nbr_value = i4
       3 double_value = f8
       3 string_value = vc
       3 display_flag = i2
   1 high_volume_flag = i2
   1 output_filename = vc
   1 run_status_flag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET shared_domain_ind = 0
 RANGE OF c IS code_value_set
 SET fnd = validate(c.br_client_id,"0")
 FREE RANGE c
 IF (fnd="1")
  SET shared_domain_ind = 1
 ELSE
  SET shared_domain_ind = 0
 ENDIF
 IF (shared_domain_ind=1)
  SET readme_data->status = "S"
  SET readme_data->message = "Domain is shared.  Skip execution of readme."
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM br_client_item_reltn bcir,
   br_step bs,
   br_step_dep bsd
  PLAN (bcir
   WHERE bcir.item_type="STEP")
   JOIN (bs
   WHERE bs.step_mean=bcir.item_mean)
   JOIN (bsd
   WHERE bsd.step_mean=bs.step_mean
    AND bsd.dependency_type_flag=2
    AND bsd.xray_name > " ")
  HEAD REPORT
   xcnt = 0
  DETAIL
   xcnt = (xcnt+ 1), stat = alterlist(tempx->xlist,xcnt), tempx->xlist[xcnt].xray_name = cnvtupper(
    bsd.xray_name)
  WITH nocounter
 ;end select
 FOR (lloopcnt = 1 TO xcnt)
   EXECUTE value(tempx->xlist[lloopcnt].xray_name)
   SET hold_br_report_id = 0.0
   SELECT INTO "nl:"
    FROM br_report br
    PLAN (br
     WHERE (br.program_name=tempx->xlist[lloopcnt].xray_name))
    DETAIL
     hold_br_report_id = br.br_report_id
    WITH nocounter
   ;end select
   SET new_hist_id = 0.0
   SELECT INTO "nl:"
    z = seq(bedrock_seq,nextval)
    FROM dual
    DETAIL
     new_hist_id = cnvtreal(z)
    WITH format, nocounter
   ;end select
   IF (hold_br_report_id > 0)
    UPDATE  FROM br_report br
     SET br.last_run_prsnl_id = reqinfo->updt_id, br.last_run_dt_tm = cnvtdatetime(curdate,curtime),
      br.last_run_status_flag = 0,
      br.br_report_history_id = new_hist_id, br.updt_id = reqinfo->updt_id, br.updt_dt_tm =
      cnvtdatetime(curdate,curtime),
      br.updt_task = reqinfo->updt_task, br.updt_applctx = reqinfo->updt_applctx, br.updt_cnt = (br
      .updt_cnt+ 1)
     WHERE br.br_report_id=hold_br_report_id
     WITH nocounter
    ;end update
    IF (error(rdm_errmsg,0) != 0)
     SET readme_data->status = "F"
     SET readme_data->message = concat("Update error:",rdm_errmsg)
     ROLLBACK
     GO TO exit_script
    ENDIF
    INSERT  FROM br_report_history brh
     SET brh.br_report_history_id = new_hist_id, brh.br_report_id = hold_br_report_id, brh
      .run_prsnl_id = reqinfo->updt_id,
      brh.run_dt_tm = cnvtdatetime(curdate,curtime), brh.run_status_flag = 0, brh.updt_id = reqinfo->
      updt_id,
      brh.updt_dt_tm = cnvtdatetime(curdate,curtime), brh.updt_task = reqinfo->updt_task, brh
      .updt_applctx = reqinfo->updt_applctx,
      brh.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (error(rdm_errmsg,0) != 0)
     SET readme_data->status = "F"
     SET readme_data->message = concat("Insert error:",rdm_errmsg)
     ROLLBACK
     GO TO exit_script
    ELSE
     COMMIT
    ENDIF
    SET statx = size(reply->statlist,5)
    IF (statx > 0)
     FOR (sx = 1 TO statx)
      INSERT  FROM br_report_statistics brs
       SET brs.br_report_statistics_id = seq(bedrock_seq,nextval), brs.br_report_history_id =
        new_hist_id, brs.statistic_meaning = reply->statlist[sx].statistic_meaning,
        brs.status_flag = reply->statlist[sx].status_flag, brs.qualifying_items = reply->statlist[sx]
        .qualifying_items, brs.total_items = reply->statlist[sx].total_items,
        brs.updt_id = reqinfo->updt_id, brs.updt_dt_tm = cnvtdatetime(curdate,curtime), brs.updt_task
         = reqinfo->updt_task,
        brs.updt_applctx = reqinfo->updt_applctx, brs.updt_cnt = 0
       WITH nocounter
      ;end insert
      IF (error(rdm_errmsg,0) != 0)
       SET readme_data->status = "F"
       SET readme_data->message = concat("Insert error for br_report_statistics:",rdm_errmsg)
       ROLLBACK
       GO TO exit_script
      ELSE
       COMMIT
      ENDIF
     ENDFOR
    ENDIF
   ENDIF
 ENDFOR
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <br_rpt_driver.prg> script"
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
