CREATE PROGRAM dm_ins_arc_dm_info:dba
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
 IF (validate(requestin->list_0[1].info_name,"X")="X")
  CALL echo("*****************************************")
  CALL echo("*****FAILED: requestin doesn't exist*****")
  CALL echo("*****************************************")
  SET readme_data->status = "F"
  SET readme_data->message = "FAILED: requestin doesn't exist"
 ELSE
  CALL echo("*****************************************")
  CALL echo("******* CSV File Finished Loading *******")
  CALL echo("*****************************************")
  FOR (ri_ndx = 1 TO size(requestin->list_0,5))
    IF ((requestin->list_0[ri_ndx].info_number=null))
     SET requestin->list_0[ri_ndx].info_number = "0"
    ENDIF
    UPDATE  FROM dm_info di
     SET di.info_number = cnvtreal(requestin->list_0[ri_ndx].info_number), di.info_char = requestin->
      list_0[ri_ndx].info_char, di.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      di.updt_id = reqinfo->updt_id, di.updt_cnt = (di.updt_cnt+ 1), di.updt_task = reqinfo->
      updt_task,
      di.updt_applctx = reqinfo->updt_applctx
     WHERE (di.info_name=requestin->list_0[ri_ndx].info_name)
      AND (di.info_domain=requestin->list_0[ri_ndx].info_domain)
     WITH nocounter
    ;end update
    IF (error(readme_data->message,0) != 0)
     ROLLBACK
     SET readme_data->status = "F"
     GO TO exit_program
    ENDIF
    IF (curqual=0)
     INSERT  FROM dm_info di
      SET di.info_name = requestin->list_0[ri_ndx].info_name, di.info_domain = requestin->list_0[
       ri_ndx].info_domain, di.info_number = cnvtreal(requestin->list_0[ri_ndx].info_number),
       di.info_char = requestin->list_0[ri_ndx].info_char, di.updt_dt_tm = cnvtdatetime(curdate,
        curtime3), di.updt_id = reqinfo->updt_id,
       di.updt_cnt = 0, di.updt_task = reqinfo->updt_task, di.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
    ENDIF
    IF (error(readme_data->message,0) != 0)
     ROLLBACK
     SET readme_data->status = "F"
     GO TO exit_program
    ENDIF
    CALL echo(build("ri_ndx=",ri_ndx))
  ENDFOR
  COMMIT
 ENDIF
#exit_program
END GO
