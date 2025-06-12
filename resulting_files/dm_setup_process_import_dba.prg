CREATE PROGRAM dm_setup_process_import:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET reply->status_data.status = "f"
 CALL echo(cnvtstring(requestin->list_0[1].process_id))
 IF ((requestin->list_0[1].process_id=" "))
  CALL echo("Blank row detected")
  GO TO ext_prg
 ENDIF
 IF ((requestin->list_0[1].run_after=" "))
  SET requestin->list_0[1].run_after = "0.0"
 ENDIF
 IF ((requestin->list_0[1].blocks_to_process=" "))
  SET requestin->list_0[1].blocks_to_process = "0.0"
 ENDIF
 SET old_act_ind = 0
 SET new_act_stat_dt_tm = cnvtdatetime(curdate,curtime3)
 SELECT INTO "nl:"
  d.active_ind
  FROM dm_pkt_setup_process d
  WHERE d.process_id=cnvtreal(requestin->list_0[1].process_id)
   AND d.effective_feature=cnvtreal(requestin->list_0[1].effective_feature)
  DETAIL
   old_act_ind = d.active_ind, new_act_stat_dt_tm = d.active_status_dt_tm
  WITH nocounter
 ;end select
 IF (cnvtint(requestin->list_0[1].active_ind) != old_act_ind)
  SET new_act_stat_dt_tm = cnvtdatetime(curdate,curtime3)
 ENDIF
 UPDATE  FROM dm_pkt_setup_process dsp
  SET dsp.pre_schema_downtime_ind = cnvtint(requestin->list_0[1].pre_schema_downtime_ind), dsp
   .post_schema_downtime_ind = cnvtint(requestin->list_0[1].post_schema_downtime_ind), dsp.change_ind
    = 1,
   dsp.run_after_process_id = cnvtreal(requestin->list_0[1].run_after), dsp.from_rev = cnvtint(
    requestin->list_0[1].from_rev), dsp.run_once_ind = cnvtint(requestin->list_0[1].run_once_ind),
   dsp.function_id = cnvtreal(requestin->list_0[1].function_id), dsp.owner_email = cnvtupper(
    substring(1,20,requestin->list_0[1].owner_name)), dsp.description = substring(1,100,requestin->
    list_0[1].description),
   dsp.program_name = substring(1,100,requestin->list_0[1].program_name), dsp.script_name = substring
   (1,100,requestin->list_0[1].script_name), dsp.data_file_name = substring(1,100,requestin->list_0[1
    ].data_file_name),
   dsp.error_routine_name = substring(1,100,requestin->list_0[1].error_routine_name), dsp
   .before_install_ind = cnvtint(requestin->list_0[1].before_install_ind), dsp.before_refresh_ind =
   cnvtint(requestin->list_0[1].before_refresh_ind),
   dsp.after_install_ind = cnvtint(requestin->list_0[1].after_install_ind), dsp.after_refresh_ind =
   cnvtint(requestin->list_0[1].after_refresh_ind), dsp.updt_applctx = reqinfo->updt_applctx,
   dsp.updt_dt_tm = cnvtdatetime(curdate,curtime3), dsp.updt_cnt = (dsp.updt_cnt+ 1), dsp.updt_id =
   reqinfo->updt_id,
   dsp.updt_task = reqinfo->updt_task, dsp.blocks_to_process = cnvtint(requestin->list_0[1].
    blocks_to_process), dsp.process_type = cnvtint(requestin->list_0[1].process_type),
   dsp.active_ind = cnvtint(requestin->list_0[1].active_ind), dsp.active_status_dt_tm = cnvtdatetime(
    new_act_stat_dt_tm), dsp.instance_nbr = cnvtint(requestin->list_0[1].instance)
  WHERE dsp.process_id=cnvtreal(requestin->list_0[1].process_id)
   AND dsp.effective_feature=cnvtreal(requestin->list_0[1].effective_feature)
  WITH nocounter
 ;end update
 IF (curqual=0)
  CALL echo("Process id not found.  Inserting new row.")
  INSERT  FROM dm_pkt_setup_process dsp
   SET dsp.pre_schema_downtime_ind = cnvtint(requestin->list_0[1].pre_schema_downtime_ind), dsp
    .post_schema_downtime_ind = cnvtint(requestin->list_0[1].post_schema_downtime_ind), dsp
    .change_ind = 1,
    dsp.blocks_to_process = cnvtint(requestin->list_0[1].blocks_to_process), dsp.run_after_process_id
     = cnvtreal(requestin->list_0[1].run_after), dsp.from_rev = cnvtint(requestin->list_0[1].from_rev
     ),
    dsp.effective_feature = cnvtreal(requestin->list_0[1].effective_feature), dsp.run_once_ind =
    cnvtint(requestin->list_0[1].run_once_ind), dsp.function_id = cnvtreal(requestin->list_0[1].
     function_id),
    dsp.owner_email = cnvtupper(substring(1,20,requestin->list_0[1].owner_name)), dsp.description =
    substring(1,100,requestin->list_0[1].description), dsp.process_type = cnvtint(requestin->list_0[1
     ].process_type),
    dsp.program_name = substring(1,100,requestin->list_0[1].program_name), dsp.script_name =
    substring(1,100,requestin->list_0[1].script_name), dsp.data_file_name = substring(1,100,requestin
     ->list_0[1].data_file_name),
    dsp.error_routine_name = substring(1,100,requestin->list_0[1].error_routine_name), dsp
    .before_install_ind = cnvtint(requestin->list_0[1].before_install_ind), dsp.before_refresh_ind =
    cnvtint(requestin->list_0[1].before_refresh_ind),
    dsp.after_install_ind = cnvtint(requestin->list_0[1].after_install_ind), dsp.after_refresh_ind =
    cnvtint(requestin->list_0[1].after_refresh_ind), dsp.updt_applctx = reqinfo->updt_applctx,
    dsp.updt_dt_tm = cnvtdatetime(curdate,curtime3), dsp.updt_cnt = 0, dsp.updt_id = reqinfo->updt_id,
    dsp.updt_task = reqinfo->updt_task, dsp.process_id = cnvtreal(requestin->list_0[1].process_id),
    dsp.active_ind = cnvtint(requestin->list_0.active_ind),
    dsp.active_status_dt_tm = cnvtdatetime(curdate,curtime3), dsp.instance_nbr = cnvtint(requestin->
     list_0[1].instance)
   WITH nocounter
  ;end insert
 ENDIF
 IF (curqual=0)
  SET reqinfo->commit_ind = 3
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
 COMMIT
#ext_prg
END GO
