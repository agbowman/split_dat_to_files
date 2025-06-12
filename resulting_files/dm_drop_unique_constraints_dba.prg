CREATE PROGRAM dm_drop_unique_constraints:dba
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
 IF (currdb="ORACLE"
  AND currdbuser="V500")
  FREE RECORD dm_drop_ui_cons
  RECORD dm_drop_ui_cons(
    1 tmp_str = vc
    1 tmp_count = i4
    1 qual[*]
      2 constraint_name = vc
      2 constraint_type = vc
      2 constraint_table = vc
  )
  SUBROUTINE do_display(s_str,s_err)
    CALL echo(header_str)
    CALL echo(s_str)
    IF (s_err=1)
     SET errcode = s_err
     SET errmsg = s_str
    ENDIF
  END ;Subroutine
  SET dm_drop_ui_cons->tmp_count = 0
  SET errmsg = fillstring(132," ")
  SET errcode = 0
  SET header_str = fillstring(5,"-")
  SET readme_data->status = "S"
  SET readme_data->message = " "
  EXECUTE dm_readme_status
  CALL do_display("Loading the unique constraints...",0)
  SELECT INTO "nl:"
   c.constraint_name, c.constraint_type, c.table_name
   FROM user_constraints c
   WHERE c.constraint_type="U"
   DETAIL
    dm_drop_ui_cons->tmp_count = (dm_drop_ui_cons->tmp_count+ 1)
    IF ((dm_drop_ui_cons->tmp_count > size(dm_drop_ui_cons->qual,5)))
     stat = alterlist(dm_drop_ui_cons->qual,(dm_drop_ui_cons->tmp_count+ 200))
    ENDIF
    dm_drop_ui_cons->qual[dm_drop_ui_cons->tmp_count].constraint_name = c.constraint_name,
    dm_drop_ui_cons->qual[dm_drop_ui_cons->tmp_count].constraint_type = c.constraint_type,
    dm_drop_ui_cons->qual[dm_drop_ui_cons->tmp_count].constraint_table = c.table_name
   FOOT REPORT
    stat = alterlist(dm_drop_ui_cons->qual,dm_drop_ui_cons->tmp_count)
   WITH nocounter
  ;end select
  CALL do_display("Dropping the unique constraints...",0)
  FOR (xitc = 1 TO dm_drop_ui_cons->tmp_count)
    SET dm_drop_ui_cons->tmp_str = concat("rdb alter table ",dm_drop_ui_cons->qual[xitc].
     constraint_table," drop constraint ",dm_drop_ui_cons->qual[xitc].constraint_name," cascade go")
    CALL do_display(dm_drop_ui_cons->tmp_str,0)
    SET errcode = error(errmsg,1)
    CALL parser(dm_drop_ui_cons->tmp_str)
    SET errcode = error(errmsg,0)
    IF (errcode != 0)
     SET readme_data->status = "F"
     CALL do_display(errmsg,0)
    ENDIF
  ENDFOR
 ELSEIF (currdb="ORACLE"
  AND currdbuser != "V500")
  SET readme_data->status = "S"
  SET readme_data->message = "Auto-success, drop unique constraints only for Oracle/V500"
 ELSEIF (currdb="DB2UDB")
  SET readme_data->status = "S"
  SET readme_data->message = "Auto-success, obsolete tables 8.0 only for Oracle"
 ENDIF
#end_program
 IF (currdb="ORACLE"
  AND currdbuser="V500")
  IF ((readme_data->status="S"))
   SET readme_data->message = "- Readme SUCCESS.  All Unique constraints were dropped."
   CALL do_display(readme_data->message,0)
   FREE RECORD dm_drop_ui_cons
  ELSE
   SET readme_data->message = "- Readme FAILURE. Some unique constraints could NOT be dropped."
   CALL do_display(readme_data->message,1)
  ENDIF
 ENDIF
 EXECUTE dm_readme_status
END GO
