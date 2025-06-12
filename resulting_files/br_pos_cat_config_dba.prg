CREATE PROGRAM br_pos_cat_config:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_pos_cat_config.prg> script"
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 SET cat_cnt = size(requestin->list_0,5)
 FOR (x = 1 TO cat_cnt)
  SELECT INTO "NL:"
   FROM br_position_category bpc
   WHERE cnvtupper(bpc.description)=cnvtupper(requestin->list_0[x].category)
   WITH nocounter
  ;end select
  IF (curqual=0
   AND cnvtupper(requestin->list_0[x].category) != "HEALTH INFORMATION MANAGEMENT")
   SET new_id = 0.0
   SELECT INTO "NL:"
    j = seq(reference_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     new_id = cnvtreal(j)
    WITH format, counter
   ;end select
   INSERT  FROM br_position_category bpc
    SET bpc.active_ind = 1, bpc.category_id = new_id, bpc.description = requestin->list_0[x].category,
     bpc.step_cat_mean = requestin->list_0[x].step_cat_mean, bpc.updt_dt_tm = cnvtdatetime(curdate,
      curtime3), bpc.updt_id = reqinfo->updt_id,
     bpc.updt_task = reqinfo->updt_task, bpc.updt_applctx = reqinfo->updt_applctx, bpc.updt_cnt = 0
    WITH nocounter
   ;end insert
   SET errcode = error(errmsg,0)
   IF (errcode > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Readme Failed: Inserting br_position_category row: ",errmsg)
    GO TO exit_script
   ELSE
    COMMIT
   ENDIF
  ELSEIF (curqual=0
   AND cnvtupper(requestin->list_0[x].category)="HEALTH INFORMATION MANAGEMENT")
   UPDATE  FROM br_position_category bpc
    SET bpc.active_ind = 1, bpc.description = requestin->list_0[x].category, bpc.step_cat_mean =
     requestin->list_0[x].step_cat_mean,
     bpc.updt_dt_tm = cnvtdatetime(curdate,curtime3), bpc.updt_id = reqinfo->updt_id, bpc.updt_task
      = reqinfo->updt_task,
     bpc.updt_applctx = reqinfo->updt_applctx, bpc.updt_cnt = (bpc.updt_cnt+ 1)
    WHERE cnvtupper(bpc.description)="MEDICAL RECORDS"
    WITH nocounter
   ;end update
   SET errcode = error(errmsg,0)
   IF (errcode > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Readme Failed: Updating br_position_category row: ",errmsg)
    GO TO exit_script
   ELSE
    COMMIT
   ENDIF
  ENDIF
 ENDFOR
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <br_pos_cat_config.prg> script"
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
