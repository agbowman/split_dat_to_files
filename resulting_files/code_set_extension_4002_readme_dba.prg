CREATE PROGRAM code_set_extension_4002_readme:dba
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
 DECLARE addnewextension(sextensiontoadd=vc) = null
 DECLARE error_cd = f8 WITH noconstant(0.0)
 DECLARE error_msg = c255 WITH noconstant("")
 SET readme_data->status = "F"
 SET readme_data->message = "Readme failed: Starting code_set_extension_4002_readme..."
 CALL addnewextension("TREATASPILL")
 CALL addnewextension("CONVERT_RETAIN_FORMULATION")
 SET readme_data->status = "S"
 SET readme_data->message =
 "Code Set Extension TREATASPILL and CONVERT_RETAIN_FORMULATION were successfully inserted in code set 4002"
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
 SUBROUTINE addnewextension(sextensiontoadd)
   SELECT INTO "nl:"
    FROM code_set_extension cse
    WHERE cse.field_name=sextensiontoadd
     AND cse.code_set=4002
    WITH nocounter
   ;end select
   SET error_cd = error(error_msg,0)
   IF (error_cd != 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed while querying CODE_SET_EXTENSION ",sextensiontoadd,
     ": ",error_msg)
    GO TO exit_script
   ENDIF
   IF (curqual=0)
    INSERT  FROM code_set_extension cse
     SET cse.code_set = 4002, cse.field_name = sextensiontoadd, cse.field_type = 1,
      cse.updt_dt_tm = cnvtdatetime(curdate,curtime3), cse.updt_id = reqinfo->updt_id, cse.updt_task
       = reqinfo->updt_task,
      cse.updt_applctx = reqinfo->updt_applctx, cse.updt_cnt = 0
     WITH nocounter
    ;end insert
    SET error_cd = error(error_msg,0)
    IF (error_cd != 0)
     SET readme_data->status = "F"
     SET readme_data->message = concat("Failed inserting in CODE_SET_EXTENSION ",sextensiontoadd,": ",
      error_msg)
     ROLLBACK
     GO TO exit_script
    ENDIF
    UPDATE  FROM code_value_set cvs
     SET cvs.extension_ind = 1, cvs.updt_id = reqinfo->updt_id, cvs.updt_cnt = (cvs.updt_cnt+ 1),
      cvs.updt_task = reqinfo->updt_task, cvs.updt_applctx = reqinfo->updt_applctx, cvs.updt_dt_tm =
      cnvtdatetime(curdate,curtime3)
     WHERE cvs.code_set=4002
     WITH nocounter
    ;end update
    SET error_cd = error(error_msg,0)
    IF (error_cd != 0)
     SET readme_data->status = "F"
     SET readme_data->message = concat("Failed updating in CODE_VALUE_SET ",sextensiontoadd,": ",
      error_msg)
     ROLLBACK
     GO TO exit_script
    ELSE
     COMMIT
    ENDIF
    SELECT INTO "nl:"
     FROM code_set_extension cse
     WHERE cse.code_set=4002
      AND cse.field_name=sextensiontoadd
     WITH nocounter
    ;end select
    SET error_cd = error(error_msg,0)
    IF (error_cd != 0)
     SET readme_data->status = "F"
     SET readme_data->message = concat("Failed while querying CODE_SET_EXTENSION ",sextensiontoadd,
      " after updates: ",error_msg)
     GO TO exit_script
    ENDIF
    IF (curqual < 1)
     SET readme_data->status = "F"
     SET readme_data->message = "The Readme was unsuccessful. Please try again."
     GO TO exit_script
    ENDIF
   ENDIF
 END ;Subroutine
END GO
