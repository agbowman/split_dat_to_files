CREATE PROGRAM dm2_create_dual_view:dba
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
 FREE RECORD vc_hold
 RECORD vc_hold(
   1 d_ora_version = vc
   1 d_f_drop = vc
   1 d_s_drop = vc
   1 d_type_drop = vc
   1 d_v_drop = vc
   1 d_err_msg = vc
   1 d_syn_stmt = vc
   1 d_func_stmt = vc
   1 d_view_stmt = vc
   1 d_array_stmt = vc
 )
 DECLARE d_o_name = c30
 DECLARE d_o_type = c30
 DECLARE d_e_stmt = c300
 DECLARE d_v_check = i2
 DECLARE d_f_check = i2
 DECLARE d_s_check = i2
 DECLARE d_syn_fail_ind = i2
 DECLARE d_err_msg = c132
 DECLARE d_desc = c132
 SET readme_data->status = "F"
 SET d_syn_fail_ind = 0
 IF (currdb != "ORACLE")
  SET readme_data->status = "S"
  SET readme_data->message = "Not executed since not using Oracle Database"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  p.*
  FROM product_component_version p
  WHERE cnvtupper(p.product)="ORACLE*"
  DETAIL
   vc_hold->d_ora_version = p.version
  WITH nocounter
 ;end select
 IF (cnvtint(cnvtalphanum(vc_hold->d_ora_version)) < 90000)
  SET readme_data->status = "S"
  SET readme_data->message = "Not executed since not Oracle Version 9 or higher"
  GO TO exit_script
 ENDIF
 SET d_f_check = d_check_object("CERNER_DUAL_FUNCTION","FUNCTION")
 SET d_v_check = d_check_object("CERNER_DUAL","VIEW")
 SET d_s_check = d_check_object("DUAL","SYNONYM")
 IF (d_f_check=1
  AND d_v_check=1
  AND d_s_check=1)
  SET readme_data->status = "S"
  SET readme_data->message = "All objects currently exist."
  GO TO exit_script
 ENDIF
 SET vc_hold->d_array_stmt = "create or replace type cerner_dual_array as table of number"
 CALL d_exe_stmt(vc_hold->d_array_stmt,"CREATE CERNER_DUAL_ARRAY")
 IF (d_check_object("CERNER_DUAL_ARRAY","TYPE")=0)
  SET readme_data->message = "Type not created"
  SET readme_data->status = "F"
  GO TO exit_script
 ENDIF
 SET vc_hold->d_func_stmt = concat("create or replace function cerner_dual_function ",
  "return cerner_dual_array ","PIPELINED as begin   "," pipe row(1);    "," return; ",
  " end; ")
 CALL d_exe_stmt(vc_hold->d_func_stmt,"CREATE CERNER_DUAL_FUNCTION")
 IF (d_check_object("CERNER_DUAL_FUNCTION","FUNCTION")=0)
  SET readme_data->message = "Function not created"
  SET readme_data->status = "F"
  GO TO exit_script
 ENDIF
 SET vc_hold->d_view_stmt = concat(" create or replace view cerner_dual as ",
  "  select *  from table( cerner_dual_function )")
 CALL d_exe_stmt(vc_hold->d_view_stmt,"CREATE CERNER_DUAL")
 IF (d_check_object("CERNER_DUAL","VIEW")=0)
  SET readme_data->message = "View not created"
  SET readme_data->status = "F"
  GO TO exit_script
 ENDIF
 IF (d_s_check=1)
  SET vc_hold->d_s_drop = "drop synonym dual"
  CALL d_exe_stmt(vc_hold->d_v_drop,"DROP SYNONYM DUAL")
 ENDIF
 SET vc_hold->d_syn_stmt = "create synonym dual for cerner_dual"
 CALL d_exe_stmt(vc_hold->d_syn_stmt,"CREATE SYNONYM DUAL")
 IF (d_check_object("DUAL","SYNONYM")=0)
  SET readme_data->message = "Synonym not created"
  SET readme_data->status = "F"
  SET d_syn_fail_ind = 1
  GO TO exit_script
 ENDIF
 SET readme_data->status = "S"
 SUBROUTINE d_check_object(d_o_name,d_o_type)
  SELECT INTO "nl:"
   FROM dm2_user_objects o
   WHERE o.object_name=cnvtupper(d_o_name)
    AND o.object_type=cnvtupper(d_o_type)
    AND o.status="VALID"
   WITH nocounter
  ;end select
  IF (curqual > 0)
   RETURN(1)
  ELSE
   RETURN(0)
  ENDIF
 END ;Subroutine
 SUBROUTINE d_exe_stmt(d_e_stmt,d_desc)
   IF (validate(bg_err_check,1) > 0)
    CALL echo(concat("RDB ASIS('",d_e_stmt,"')"),0)
    CALL echo("go")
   ENDIF
   SET d_err_msg = cnvtstring(error(d_err_msg,1))
   CALL parser(concat("RDB ASIS('",trim(d_e_stmt),"')"),0)
   CALL parser("go")
   IF (error(d_err_msg,0) > 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Statement:",trim(d_desc)," failed.","Error: ",trim(d_err_msg))
    GO TO exit_script
   ENDIF
 END ;Subroutine
 IF ((readme_data->status="S"))
  SET readme_data->message = "All objects created successfully."
 ENDIF
#exit_script
 IF ((readme_data->status="F")
  AND d_syn_fail_ind=0)
  IF (d_check_object("DUAL","SYNONYM")=1)
   SET vc_hold->d_syn_stmt = ""
   SET vc_hold->d_syn_stmt = "rdb drop synonym dual;"
   CALL parser(vc_hold->d_syn_stmt,0)
   CALL parser("go",1)
   IF (validate(bg_err_check,1) > 0)
    CALL echo(d_syn_stmt,0)
    CALL echo("go",1)
   ENDIF
   IF (d_check_object("DUAL","SYNONYM")=1)
    CALL echo("ERROR DROPPING SYNONYM DUAL--- SYNONYM NEEDS TO BE DROPPED!!!")
   ENDIF
  ENDIF
 ENDIF
 IF ((readme_data->readme_id > 0))
  EXECUTE dm_readme_status
 ELSE
  CALL echo("##################################################")
  CALL echo(readme_data->message)
  CALL echo("##################################################")
 ENDIF
 COMMIT
END GO
