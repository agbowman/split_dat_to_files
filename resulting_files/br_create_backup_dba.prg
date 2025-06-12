CREATE PROGRAM br_create_backup:dba
 DECLARE create_backup_table(orig_tbl=vc,temp_tbl_prefix=vc,temp_tbl_suffix=vc) = null
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
 SET readme_data->message = "Readme Failed: Starting <br_create_backup.prg> script"
 FOR (i = 1 TO size(request->tables,5))
   CALL create_backup_table(request->tables[i].table_name,request->tables[i].temp_tbl_prefix,request
    ->tables[i].temp_tbl_suffix)
 ENDFOR
 SUBROUTINE create_backup_table(orig_tbl,temp_tbl_prefix,temp_tbl_suffix)
   DECLARE err = i4
   DECLARE errmsg = vc
   DECLARE temp_tbl = vc
   DECLARE temp_counter = i4 WITH noconstant(0)
   DECLARE temp_found = i2 WITH noconstant(1)
   WHILE (temp_found)
     SET temp_counter = (temp_counter+ 1)
     SET temp_tbl = build(cnvtupper(temp_tbl_prefix),temp_counter,cnvtupper(temp_tbl_suffix))
     SELECT INTO "nl:"
      FROM user_tables ut
      WHERE ut.table_name=temp_tbl
      WITH nocounter
     ;end select
     IF (error(errmsg,0) > 0)
      ROLLBACK
      SET readme_data->status = "F"
      SET readme_data->message = concat("Failed to check if the table name exists: ",errmsg)
      GO TO exit_script
     ELSE
      COMMIT
     ENDIF
     SET temp_found = curqual
   ENDWHILE
   DECLARE orig_tspace = vc
   SELECT INTO "nl:"
    FROM user_tables ut
    WHERE ut.table_name=cnvtupper(orig_tbl)
    DETAIL
     orig_tspace = ut.tablespace_name
    WITH nocounter
   ;end select
   IF (error(errmsg,0) > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed to get the tablespace name of original table: ",errmsg)
    GO TO exit_script
   ELSE
    COMMIT
   ENDIF
   IF (curqual)
    CALL parser(concat("rdb create table ",temp_tbl))
    CALL parser(concat(" tablespace ",orig_tspace))
    CALL parser(concat(" as select * from ",orig_tbl))
    CALL parser(" go")
    SET err = error(errmsg,1)
    IF (err=0)
     COMMIT
     CALL echo(concat("SUCCESS create table ",temp_tbl," as copy of ",orig_tbl))
    ELSE
     CALL echo(concat("FAILURE create table ",temp_tbl," as copy of ",orig_tbl))
     ROLLBACK
     SET readme_data->status = "F"
     SET readme_data->message = concat("Readme Failed: FAILURE create table ",temp_tbl," as copy of ",
      orig_tbl," due to error: ",
      errmsg)
     GO TO exit_script
    ENDIF
   ENDIF
 END ;Subroutine
 SET readme_data->status = "S"
 SET readme_data->message = "br_create_backup.prg Successful"
#exit_script
END GO
