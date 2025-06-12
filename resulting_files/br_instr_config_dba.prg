CREATE PROGRAM br_instr_config:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_instr_config.prg> script"
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 DECLARE error_msg = vc
 SET error_flag = "N"
 SET nbr_instr = size(requestin->list_0,5)
 FOR (x = 1 TO nbr_instr)
  SELECT INTO "NL:"
   FROM br_instr b
   WHERE b.br_instr_id=cnvtreal(requestin->list_0[x].sequence)
   WITH nocounter
  ;end select
  IF (curqual=0)
   INSERT  FROM br_instr b
    SET b.br_instr_id = cnvtreal(requestin->list_0[x].sequence), b.manufacturer = requestin->list_0[x
     ].supplier, b.model = requestin->list_0[x].model,
     b.type = requestin->list_0[x].type, b.point_of_care_ind =
     IF (cnvtupper(requestin->list_0[x].poc)="X") 1
     ELSE 0
     ENDIF
     , b.code_name = requestin->list_0[x].code_name,
     b.uni_ind =
     IF (cnvtupper(requestin->list_0[x].uni)="X") 1
     ELSE 0
     ENDIF
     , b.bi_ind =
     IF (cnvtupper(requestin->list_0[x].bi)="X") 1
     ELSE 0
     ENDIF
     , b.hq_ind =
     IF (cnvtupper(requestin->list_0[x].hq)="X") 1
     ELSE 0
     ENDIF
     ,
     b.multiplexor_ind =
     IF (cnvtupper(requestin->list_0[x].multiplexor)="X") 1
     ELSE 0
     ENDIF
     , b.robotics_ind =
     IF (cnvtupper(requestin->list_0[x].robotics)="X") 1
     ELSE 0
     ENDIF
     , b.prev_manufacturer = requestin->list_0[x].previous_supplier,
     b.activity_type_mean = requestin->list_0[x].activity_type, b.manufacturer_alias = requestin->
     list_0[x].supplier_alias, b.model_alias = requestin->list_0[x].model_alias,
     b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task =
     reqinfo->updt_task,
     b.updt_cnt = 0, b.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET error_flag = "T"
    SET error_msg = concat("Unable to insert ",trim(requestin->list_0[x].sequence),
     " into the br_instr table.")
    GO TO exit_script
   ENDIF
  ENDIF
 ENDFOR
 GO TO exit_script
#exit_script
 IF (error_flag="T")
  CALL echo(error_msg)
 ENDIF
 IF (((error_flag="N") OR (error_flag="T")) )
  SET readme_data->status = "S"
  SET readme_data->message = "Readme Succeeded: Ending <br_instr_config.prg> script"
  COMMIT
 ELSE
  SET readme_cata->status = "F"
  SET readme_data->message = "Readme Failed: <br_instr_config.prg> script"
  ROLLBACK
 ENDIF
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
