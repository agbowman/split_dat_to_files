CREATE PROGRAM br_name_value_config:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_name_value_config.prg> script"
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 SET nbr_value = size(requestin->list_0,5)
 FOR (x = 1 TO nbr_value)
   IF (((cnvtupper(requestin->list_0[x].mean)="EDWAITAREA") OR (cnvtupper(requestin->list_0[x].mean)=
   "EDCOAREA")) )
    SELECT INTO "NL:"
     FROM br_name_value b
     WHERE cnvtupper(b.br_nv_key1)=cnvtupper(requestin->list_0[x].mean)
     DETAIL
      requestin->list_0[x].mean = cnvtstring(b.br_name_value_id)
     WITH nocounter
    ;end select
   ENDIF
   SELECT INTO "NL:"
    FROM br_name_value b
    WHERE cnvtupper(b.br_nv_key1)=cnvtupper(requestin->list_0[x].key1)
     AND cnvtupper(b.br_name)=cnvtupper(requestin->list_0[x].mean)
     AND cnvtupper(b.br_value)=cnvtupper(requestin->list_0[x].display)
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET new_name_id = 0.0
    SELECT INTO "NL:"
     j = seq(bedrock_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      new_name_id = cnvtreal(j)
     WITH format, counter
    ;end select
    INSERT  FROM br_name_value b
     SET b.br_name_value_id = new_name_id, b.br_nv_key1 = requestin->list_0[x].key1, b.br_name =
      requestin->list_0[x].mean,
      b.br_value = requestin->list_0[x].display, b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b
      .updt_id = reqinfo->updt_id,
      b.updt_task = reqinfo->updt_task, b.updt_cnt = 0, b.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    SET errcode = error(errmsg,0)
    IF (errcode > 0)
     ROLLBACK
     SET readme_data->status = "F"
     SET readme_data->message = concat("Readme Failed: Inserting into br_name_value: ",errmsg)
     GO TO exit_script
    ELSE
     COMMIT
    ENDIF
   ENDIF
 ENDFOR
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <br_name_value_config.prg> script"
 GO TO exit_script
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
