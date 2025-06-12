CREATE PROGRAM br_upd_class_display_name_key:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_upd_class_display_name_key.prg> script"
 DECLARE errmsg = vc WITH protect
 DECLARE errcode = i4 WITH protect, noconstant(0)
 RECORD temp(
   1 tqual[*]
     2 ac_class_def_id = f8
     2 class_display_name_key = vc
 ) WITH protect
 DECLARE cnt = i4 WITH noconstant(0), protect
 SELECT INTO "nl:"
  FROM ac_class_def a
  WHERE a.class_display_name_key > ""
   AND a.updt_task=3202004
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(temp->tqual,cnt), temp->tqual[cnt].ac_class_def_id = a
   .ac_class_def_id,
   temp->tqual[cnt].class_display_name_key = a.class_display_name_key
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme Failed: Selecting ac_class_def: ",errmsg)
  GO TO exit_script
 ENDIF
 IF (cnt > 0)
  UPDATE  FROM ac_class_def a,
    (dummyt d  WITH seq = value(cnt))
   SET a.class_display_name_key = cnvtupper(cnvtalphanum(temp->tqual[d.seq].class_display_name_key)),
    a.updt_dt_tm = cnvtdatetime(curdate,curtime3), a.updt_id = reqinfo->updt_id,
    a.updt_task = reqinfo->updt_task, a.updt_applctx = reqinfo->updt_applctx, a.updt_cnt = (a
    .updt_cnt+ 1)
   PLAN (d)
    JOIN (a
    WHERE (a.ac_class_def_id=temp->tqual[d.seq].ac_class_def_id))
   WITH nocounter
  ;end update
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Readme Failed: Inserting ac_class_def: ",errmsg)
   GO TO exit_script
  ENDIF
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <br_upd_class_display_name_key.prg> script"
 IF (errcode=0)
  COMMIT
 ENDIF
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
