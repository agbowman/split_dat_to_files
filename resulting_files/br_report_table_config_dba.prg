CREATE PROGRAM br_report_table_config:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_report_table_config.prg> script"
 FREE RECORD br_info
 RECORD br_info(
   1 list_0[*]
     2 updt_rpt_id = f8
 )
 DECLARE errmsg = vc WITH protect, noconstant("")
 SET row_cnt = size(requestin->list_0,5)
 SET stat = alterlist(br_info->list_0,row_cnt)
 SELECT INTO "nl:"
  br.br_report_id
  FROM br_report br,
   (dummyt d  WITH seq = value(row_cnt))
  PLAN (d)
   JOIN (br
   WHERE cnvtupper(trim(br.program_name))=cnvtupper(requestin->list_0[d.seq].program_name))
  DETAIL
   br_info->list_0[d.seq].updt_rpt_id = br.br_report_id
  WITH nocounter
 ;end select
 INSERT  FROM br_report b,
   (dummyt d  WITH seq = value(row_cnt))
  SET b.br_report_id = seq(reference_seq,nextval), b.br_client_id = 0.0, b.report_name = requestin->
   list_0[d.seq].report_name,
   b.program_name = cnvtupper(requestin->list_0[d.seq].program_name), b.step_cat_mean = requestin->
   list_0[d.seq].step_cat, b.sequence = cnvtint(requestin->list_0[d.seq].rpt_sequence),
   b.report_type_flag = cnvtint(requestin->list_0[d.seq].report_type_flag), b.solution_mean =
   requestin->list_0[d.seq].solution_mean, b.solution_disp = requestin->list_0[d.seq].solution_disp,
   b.refresh_nbr_of_days = cnvtint(requestin->list_0[d.seq].refresh_nbr_of_days), b.updt_dt_tm =
   cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id,
   b.updt_task = reqinfo->updt_task, b.updt_cnt = 0, b.updt_applctx = reqinfo->updt_applctx
  PLAN (d
   WHERE (br_info->list_0[d.seq].updt_rpt_id=0))
   JOIN (b)
  WITH nocounter
 ;end insert
 IF (error(errmsg,1) != 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Insert failed: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 UPDATE  FROM br_report b,
   (dummyt d  WITH seq = value(row_cnt))
  SET b.report_name = requestin->list_0[d.seq].report_name, b.program_name = cnvtupper(trim(requestin
     ->list_0[d.seq].program_name)), b.step_cat_mean = requestin->list_0[d.seq].step_cat,
   b.report_type_flag = cnvtint(requestin->list_0[d.seq].report_type_flag), b.solution_mean =
   requestin->list_0[d.seq].solution_mean, b.solution_disp = requestin->list_0[d.seq].solution_disp,
   b.refresh_nbr_of_days = cnvtint(requestin->list_0[d.seq].refresh_nbr_of_days), b.updt_dt_tm =
   cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id,
   b.updt_task = reqinfo->updt_task, b.updt_cnt = (b.updt_cnt+ 1), b.updt_applctx = reqinfo->
   updt_applctx
  PLAN (d
   WHERE (br_info->list_0[d.seq].updt_rpt_id > 0))
   JOIN (b
   WHERE (b.br_report_id=br_info->list_0[d.seq].updt_rpt_id))
  WITH nocounter
 ;end update
 IF (error(errmsg,1) != 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Update failed: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <br_report_table_config.prg> script"
#exit_script
END GO
