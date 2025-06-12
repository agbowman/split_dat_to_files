CREATE PROGRAM dm_rdm_route_ivpb_extension:dba
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
 SET readme_data->message = "Readme Failed: Starting script dm_rdm_route_ivpb_extension.prg..."
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 DECLARE ncount = i2 WITH noconstant(0), protect
 SELECT INTO "nl:"
  csx.code_set
  FROM code_set_extension csx
  WHERE csx.code_set=4001
   AND csx.field_name="IVPB"
  DETAIL
   ncount = (ncount+ 1)
  WITH nocounter, maxrec = 1
 ;end select
 IF (ncount > 0)
  SET readme_data->status = "S"
  SET readme_data->message = "Success: Code Set Extension IVPB for Code Set 4001 all ready added"
  GO TO exit_script
 ENDIF
 INSERT  FROM code_set_extension c
  SET c.code_set = 4001, c.field_name = "IVPB", c.field_seq = 0,
   c.field_type = 1, c.field_len = 0, c.field_prompt = "Whether this route is IV Piggyback Enabled",
   c.validation_code_set = 0, c.field_help = "0 (or blank) - not enabled, 1 - enabled", c.updt_id =
   reqinfo->updt_id,
   c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = 0,
   c.updt_dt_tm = cnvtdatetime(curdate,curtime3)
  WITH nocounter
 ;end insert
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_stat->message = concat("<Brief Failure Summary>:",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme performed all required tasks"
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
