CREATE PROGRAM dep_role_group_reltn:dba
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
 SET readme_data->message = "Beginning readme to update dep_role_group and dep_role_group_reltn"
 DECLARE num = i4 WITH noconstant(0)
 DECLARE role_id = i4
 DECLARE role_group_id = f8
 DECLARE role_group_pk = f8
 DELETE  FROM dep_role_group_reltn drgr
  WHERE drgr.dep_role_group_id IN (
  (SELECT
   drg.dep_role_group_id
   FROM dep_role_group drg
   WHERE drg.dep_env_id=dep_env_id))
  WITH nocounter
 ;end delete
 IF (error(string_struct_c->ms_err_msg,0) != 0)
  SET readme_data->message = concat("Failure during DELETE from dep_role_group_reltn:",
   string_struct_c->ms_err_msg)
  CALL echo(concat("Failure during DELETE from dep_role_group_reltn:",string_struct_c->ms_err_msg))
  GO TO exit_program
 ENDIF
 DELETE  FROM dep_role_group drg
  WHERE drg.dep_env_id=dep_env_id
  WITH nocounter
 ;end delete
 IF (error(string_struct_c->ms_err_msg,0) != 0)
  SET readme_data->message = concat("Failure during DELETE from dep_role_group:",string_struct_c->
   ms_err_msg)
  CALL echo(concat("Failure during DELETE from dep_role_group:",string_struct_c->ms_err_msg))
  GO TO exit_program
 ENDIF
 SET role_id = 0
 SET role_group_id = 0
 FOR (num = 1 TO size(requestin->list_0,5))
   IF (role_id != cnvtreal(requestin->list_0[num].role_id))
    SELECT INTO "nl:"
     sequence = seq(dm_seq,nextval)
     FROM dual
     DETAIL
      role_group_id = sequence
     WITH nocounter
    ;end select
    IF (error(string_struct_c->ms_err_msg,0) != 0)
     SET readme_data->message = concat("Failure getting next dep_role_group_id sequence from DM_SEQ:",
      string_struct_c->ms_err_msg)
     CALL echo(concat("Failure getting next dep_role_group_id sequence from DM_SEQ:",string_struct_c
       ->ms_err_msg))
     GO TO exit_program
    ENDIF
    INSERT  FROM dep_role_group drg
     SET drg.dep_role_group_id = role_group_id, drg.role_id = cnvtreal(requestin->list_0[num].role_id
       ), drg.dep_env_id = dep_env_id
     WITH nocounter
    ;end insert
    IF (error(string_struct_c->ms_err_msg,0) != 0)
     SET readme_data->message = concat("Failure during INSERT into dep_role_group:",string_struct_c->
      ms_err_msg)
     CALL echo(concat("Failure during INSERT into dep_role_group:",string_struct_c->ms_err_msg))
     GO TO exit_program
    ENDIF
    SET role_id = cnvtreal(requestin->list_0[num].role_id)
   ENDIF
   SELECT INTO "nl:"
    sequence = seq(dm_seq,nextval)
    FROM dual
    DETAIL
     role_group_pk = sequence
    WITH nocounter
   ;end select
   IF (error(string_struct_c->ms_err_msg,0) != 0)
    SET readme_data->message = concat(
     "Failure getting next dep_role_group_reltn_id sequence from DM_SEQ:",string_struct_c->ms_err_msg
     )
    CALL echo(concat("Failure getting next dep_role_group_reltn_id sequence from DM_SEQ:",
      string_struct_c->ms_err_msg))
    GO TO exit_program
   ENDIF
   INSERT  FROM dep_role_group_reltn drgr
    SET drgr.dep_role_group_reltn_id = role_group_pk, drgr.dep_role_group_id = role_group_id, drgr
     .required_role_id = cnvtreal(requestin->list_0[num].required_role_id)
    WITH nocounter
   ;end insert
   IF (error(string_struct_c->ms_err_msg,0) != 0)
    SET readme_data->message = concat("Failure during INSERT into dep_role_group_reltn:",
     string_struct_c->ms_err_msg)
    CALL echo(concat("Failure during INSERT into dep_role_group_reltn:",string_struct_c->ms_err_msg))
    GO TO exit_program
   ENDIF
 ENDFOR
 SET readme_data->status = "S"
#exit_program
 IF ((readme_data->status="F"))
  ROLLBACK
 ELSE
  COMMIT
  SET readme_data->message = "Completed dep_role_group_reltn successfully."
 ENDIF
END GO
