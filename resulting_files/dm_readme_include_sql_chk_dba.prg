CREATE PROGRAM dm_readme_include_sql_chk:dba
 IF ((dm_sql_reply->status="F"))
  GO TO exit_script
 ENDIF
 DECLARE sql_obj_name = vc WITH protect, noconstant("")
 DECLARE sql_obj_type = vc WITH protect, noconstant("")
 DECLARE par = c20 WITH protect, noconstant("")
 DECLARE sql_error_msg = vc WITH protect, noconstant("")
 DECLARE sql_chk_num = i4 WITH protect, noconstant(1)
 DECLARE sql_chk_cnt = i4 WITH protect, noconstant(0)
 WHILE (sql_chk_num > 0)
  SET par = reflect(parameter(sql_chk_num,0))
  IF (par=" ")
   SET sql_chk_cnt = (sql_chk_num - 1)
   SET sql_chk_num = 0
  ELSE
   SET sql_chk_cnt = sql_chk_num
   IF (sql_chk_cnt=1)
    SET sql_obj_name = parameter(sql_chk_cnt,0)
    SET sql_obj_name = trim(cnvtupper(sql_obj_name),3)
   ELSEIF (sql_chk_cnt=2)
    SET sql_obj_type = parameter(sql_chk_cnt,0)
    SET sql_obj_type = trim(cnvtupper(sql_obj_type),3)
   ENDIF
   SET sql_chk_num = (sql_chk_num+ 1)
  ENDIF
 ENDWHILE
 IF (sql_chk_cnt < 2)
  SET dm_sql_reply->status = "F"
  SET dm_sql_reply->msg =
  "Incorrect parameters. Usage:dm_readme_include_sql_chk <object_name>, <object_type>"
  CALL echo("Incorrect parameters. Usage:dm_readme_include_sql_chk <object_name>, <object_type>")
  GO TO exit_script
 ELSEIF (((sql_obj_name=" ") OR (sql_obj_type=" ")) )
  SET dm_sql_reply->status = "F"
  SET dm_sql_reply->msg =
  "Incorrect parameters. Usage:dm_readme_include_sql_chk <object_name>, <object_type>"
  CALL echo("Incorrect parameters. Usage:dm_readme_include_sql_chk <object_name>, <object_type>")
  GO TO exit_script
 ENDIF
 IF (currdb="ORACLE")
  SELECT INTO "nl:"
   u.text
   FROM user_errors u
   WHERE u.name=sql_obj_name
    AND u.type=sql_obj_type
   DETAIL
    sql_error_msg = u.text
   WITH nocounter
  ;end select
  IF (curqual)
   SET dm_sql_reply->msg = concat(sql_obj_type," ",sql_obj_name," failed to compile:",sql_error_msg)
   CALL echo(concat(sql_obj_type," ",sql_obj_name," failed to compile:",sql_error_msg))
   SET dm_sql_reply->status = "F"
   GO TO exit_script
  ENDIF
 ENDIF
 IF (currdb="DB2UDB")
  CASE (sql_obj_type)
   OF "FUNCTION":
    SELECT INTO "nl:"
     sr.routinename
     FROM (syscat.routines sr)
     WHERE sr.routinetype="F"
      AND sr.routinename=sql_obj_name
     WITH nocounter
    ;end select
   OF "VIEW":
    SELECT INTO "nl:"
     dm.view_name
     FROM dm2_user_views dm
     WHERE dm.view_name=sql_obj_name
     WITH nocounter
    ;end select
   OF "PROCEDURE":
    SELECT INTO "nl:"
     sr.routinename
     FROM (syscat.routines sr)
     WHERE routinetype="P"
      AND sr.routinename=sql_obj_name
     WITH nocounter
    ;end select
   OF "TRIGGER":
    SELECT INTO "nl:"
     dm.trigger_name
     FROM dm2_user_triggers dm
     WHERE dm.trigger_name=sql_obj_name
     WITH nocounter
    ;end select
  ENDCASE
 ELSE
  SELECT INTO "nl:"
   u.object_name
   FROM user_objects u
   WHERE u.object_name=sql_obj_name
    AND u.object_type=sql_obj_type
    AND u.status="VALID"
   WITH nocounter
  ;end select
 ENDIF
 IF (curqual)
  SET dm_sql_reply->status = "S"
  SET dm_sql_reply->msg = concat(sql_obj_type," ",sql_obj_name," exists and is valid.")
 ELSE
  SET dm_sql_reply->status = "F"
  SET dm_sql_reply->msg = concat(sql_obj_type," ",sql_obj_name," does not exist or is not valid.")
 ENDIF
#exit_script
END GO
