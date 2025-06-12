CREATE PROGRAM dm_cmb_create_audit_procs:dba
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
 DECLARE cmb_audit_level(null) = i2
 DECLARE cmb_call_create_audit_procs(null) = null
 IF ((validate(cmb_audit->log_lvl,- (99))=- (99)))
  FREE RECORD cmb_audit
  RECORD cmb_audit(
    1 parent_table = vc
    1 log_lvl = i2
  )
  SET cmb_audit->log_lvl = - (1)
 ENDIF
 SUBROUTINE (ins_cmb_audit(i_request=vc(ref),i_request_ndx=i4,i_call_script=vc,i_child_entity_col=vc,
  i_child_entity_name=vc,i_child_entity_script_name=vc,i_cmb_grp_id=f8(ref),i_operation_type=vc,
  i_rev_cmb_ind=i2,i_pass_log_lvl=i2) =f8)
   DECLARE cmb_temp_pk_id = f8 WITH protect, noconstant(0.0)
   DECLARE cmb_temp_proc_str = vc WITH protect, noconstant("")
   DECLARE cmb_temp_app_flag = i2 WITH protect, noconstant(0)
   DECLARE cmb_temp_encntr_id = f8 WITH protect, noconstant(0.0)
   DECLARE cmb_temp_from_entity_id = f8 WITH protect, noconstant(0.0)
   DECLARE cmb_temp_to_entity_id = f8 WITH protect, noconstant(0.0)
   DECLARE cmb_temp_parent_entity_id = f8 WITH protect, noconstant(0.0)
   DECLARE dm_err_clr = i2 WITH protect, noconstant(0)
   DECLARE dm_err_ins_emsg = vc WITH protect, noconstant("")
   DECLARE cmb_temp_cmb_mode = vc WITH protect, noconstant("")
   DECLARE cmb_temp_trans_type = vc WITH protect, noconstant("")
   DECLARE cmb_temp_date = vc WITH protect, noconstant("")
   IF ((cmb_audit->log_lvl=- (1)))
    SET cmb_audit->parent_table = i_request->parent_table
    SET cmb_audit->log_lvl = cmb_audit_level(cmb_audit->parent_table)
   ENDIF
   IF ((cmb_audit->log_lvl >= i_pass_log_lvl))
    CASE (i_operation_type)
     OF "COMBINE":
      SET cmb_temp_app_flag = i_request->xxx_combine[i_request_ndx].application_flag
      SET cmb_temp_encntr_id = i_request->xxx_combine[i_request_ndx].encntr_id
      SET cmb_temp_from_entity_id = i_request->xxx_combine[i_request_ndx].from_xxx_id
      SET cmb_temp_to_entity_id = i_request->xxx_combine[i_request_ndx].to_xxx_id
      SET cmb_temp_parent_entity_id = i_request->xxx_combine[i_request_ndx].xxx_combine_id
     OF "UNCOMBINE":
      SET cmb_temp_app_flag = i_request->xxx_uncombine[i_request_ndx].application_flag
      SET cmb_temp_encntr_id = 0.0
      SET cmb_temp_from_entity_id = i_request->xxx_uncombine[i_request_ndx].from_xxx_id
      SET cmb_temp_to_entity_id = i_request->xxx_uncombine[i_request_ndx].to_xxx_id
      SET cmb_temp_parent_entity_id = i_request->xxx_uncombine[i_request_ndx].xxx_combine_id
     ELSE
      RETURN(0)
    ENDCASE
    SELECT INTO "nl:"
     y = seq(combine_seq,nextval)
     FROM dual
     DETAIL
      cmb_temp_pk_id = cnvtreal(y)
     WITH nocounter
    ;end select
    IF (i_cmb_grp_id=0)
     SELECT INTO "nl:"
      y = seq(combine_seq,nextval)
      FROM dual
      DETAIL
       i_cmb_grp_id = cnvtreal(y)
      WITH nocounter
     ;end select
    ENDIF
    SET cmb_temp_cmb_mode = replace(i_request->cmb_mode,"'","''")
    SET cmb_temp_trans_type = replace(i_request->transaction_type,"'","''")
    SET cmb_temp_cmb_mode = replace(cmb_temp_cmb_mode,"^","'||chr(94)||'")
    SET cmb_temp_trans_type = replace(cmb_temp_trans_type,"^","'||chr(94)||'")
    SET cmb_temp_cmb_mode = replace(cmb_temp_cmb_mode,char(0),"'||chr(0)||'")
    SET cmb_temp_trans_type = replace(cmb_temp_trans_type,char(0),"'||chr(0)||'")
    IF (curutc=1)
     SET cmb_temp_date = "SYS_EXTRACT_UTC(SYSTIMESTAMP)"
    ELSE
     SET cmb_temp_date = "sysdate"
    ENDIF
    SET cmb_temp_proc_str = build("rdb asis (^begin proc_ins_cmb_audit_auton(",cmb_temp_app_flag,",'",
     i_call_script,"','",
     i_child_entity_col,"','",i_child_entity_name,"','",i_child_entity_script_name,
     "',",cmb_temp_pk_id,",",i_cmb_grp_id,",'",
     cmb_temp_cmb_mode,"',",cmb_temp_encntr_id,",",cmb_temp_from_entity_id,
     ",",i_pass_log_lvl,",'",i_operation_type,"',",
     cmb_temp_parent_entity_id,",'",i_request->parent_table,"', ",cmb_temp_date,
     ",",cmb_temp_to_entity_id,",'",cmb_temp_trans_type,"',",
     i_rev_cmb_ind,",",reqinfo->updt_app,", ",cmb_temp_date,
     ", ",reqinfo->updt_id,",",reqinfo->updt_task,"); END; ^) go")
    IF (dm_debug_cmb=1)
     CALL echo(cmb_temp_proc_str)
    ENDIF
    CALL parser(cmb_temp_proc_str,1)
   ENDIF
   SET dm_err_clr = error(dm_err_ins_emsg,1)
   IF (dm_err_clr > 0)
    SET cmb_temp_pk_id = 0
    SET i_cmb_grp_id = 0
    CALL parser("reset go")
   ENDIF
   RETURN(cmb_temp_pk_id)
 END ;Subroutine
 SUBROUTINE (upd_cmb_audit(i_cmb_audit_id=f8,i_cmb_error_id=f8,i_pass_log_lvl=i2) =null)
   DECLARE cmb_temp_proc_str2 = vc WITH protect, noconstant("")
   DECLARE dm_err_clr2 = i2 WITH protect, noconstant(0)
   DECLARE dm_err_upd_emsg = vc WITH protect, noconstant("")
   DECLARE cmb_temp_date = vc WITH protect, noconstant("")
   IF ((cmb_audit->log_lvl >= i_pass_log_lvl)
    AND i_cmb_audit_id > 0)
    SET cmb_temp_proc_str2 = ""
    IF (curutc=1)
     SET cmb_temp_date = "SYS_EXTRACT_UTC(SYSTIMESTAMP)"
    ELSE
     SET cmb_temp_date = "sysdate"
    ENDIF
    SET cmb_temp_proc_str2 = build("rdb asis (^begin proc_upd_cmb_audit_auton(",i_cmb_audit_id,",",
     i_cmb_error_id,", ",
     cmb_temp_date,", ",reqinfo->updt_app,", ",cmb_temp_date,
     ", ",reqinfo->updt_id,",",reqinfo->updt_task,"); END; ^) go")
    IF (dm_debug_cmb=1)
     CALL echo(cmb_temp_proc_str2)
    ENDIF
    CALL parser(cmb_temp_proc_str2,1)
   ENDIF
   SET dm_err_clr2 = error(dm_err_upd_emsg,1)
 END ;Subroutine
 SUBROUTINE cmb_audit_level(i_parent_table)
   DECLARE temp_audit_lvl = i2 WITH protect, noconstant(0)
   DECLARE temp_info_name_str = vc WITH protect, noconstant("")
   SELECT INTO "nl:"
    FROM user_objects u
    WHERE u.object_type="PROCEDURE"
     AND u.object_name IN ("PROC_INS_CMB_AUDIT_AUTON", "PROC_UPD_CMB_AUDIT_AUTON")
     AND u.status="VALID"
    WITH nocounter
   ;end select
   IF (curqual < 2)
    SET temp_audit_lvl = 0
   ELSE
    IF (i_parent_table="PRSNL")
     SET temp_info_name_str = "COMBINE_AUDIT_LOG_LEVEL::PERSON"
    ELSE
     SET temp_info_name_str = concat("COMBINE_AUDIT_LOG_LEVEL::",i_parent_table)
    ENDIF
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_domain="DATA MANAGEMENT"
      AND di.info_name=temp_info_name_str
     DETAIL
      temp_audit_lvl = di.info_number
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET temp_audit_lvl = 1
     INSERT  FROM dm_info di
      SET di.info_domain = "DATA MANAGEMENT", di.info_name = temp_info_name_str, di.info_number =
       temp_audit_lvl,
       di.updt_id = reqinfo->updt_id, di.updt_task = reqinfo->updt_task, di.updt_applctx = reqinfo->
       updt_applctx,
       di.updt_cnt = 0, di.updt_dt_tm = cnvtdatetime(sysdate)
      WITH nocounter
     ;end insert
    ENDIF
   ENDIF
   IF (dm_debug_cmb=1)
    CALL echo(build("*** Combine Audit Level for parent: ",i_parent_table," is: ",temp_audit_lvl))
   ENDIF
   RETURN(temp_audit_lvl)
 END ;Subroutine
 SUBROUTINE (cmb_create_audit_procs(i_ins_ind=i2,i_upd_ind=i2) =vc)
   DECLARE dm_cmb_audit_emsg = vc WITH protect, noconstant("")
   IF (i_ins_ind=1)
    RDB read "cer_install:proc_ins_cmb_audit_auton.sql"
    END ;Rdb
    IF (error(dm_cmb_audit_emsg,1) != 0)
     RETURN(dm_cmb_audit_emsg)
    ENDIF
   ENDIF
   IF (i_upd_ind=1)
    RDB read "cer_install:proc_upd_cmb_audit_auton.sql"
    END ;Rdb
    IF (error(dm_cmb_audit_emsg,1) != 0)
     RETURN(dm_cmb_audit_emsg)
    ENDIF
   ENDIF
   IF (((i_ins_ind=1) OR (i_upd_ind=1)) )
    SELECT INTO "nl:"
     FROM user_objects u
     WHERE u.object_type="PROCEDURE"
      AND u.object_name IN ("PROC_INS_CMB_AUDIT_AUTON", "PROC_UPD_CMB_AUDIT_AUTON")
      AND u.status="VALID"
     WITH nocounter
    ;end select
    IF (curqual < 2)
     RETURN(
     "ERROR: PROC_INS_CMB_AUDIT_AUTON and PROC_UPD_CMB_AUDIT_AUTON Procedures not found on USER_OBJECTS"
     )
    ENDIF
    SELECT INTO "nl:"
     FROM user_errors e
     WHERE e.name IN ("PROC_INS_CMB_AUDIT_AUTON", "PROC_UPD_CMB_AUDIT_AUTON")
      AND e.type="PROCEDURE"
     DETAIL
      dm_cmb_audit_emsg = concat(dm_cmb_audit_emsg,"ERROR:",e.name,"-",e.text,
       "::")
     WITH nocounter
    ;end select
    IF (curqual > 0)
     RETURN(dm_cmb_audit_emsg)
    ENDIF
   ENDIF
   RETURN("SUCCESS")
 END ;Subroutine
 SUBROUTINE cmb_call_create_audit_procs(null)
   DECLARE dm_ins_ind = i2 WITH protect, noconstant(1)
   DECLARE dm_upd_ind = i2 WITH protect, noconstant(1)
   DECLARE dm_sub_return_val = vc WITH protect, noconstant("")
   DECLARE dm_err_queue_clr = i2 WITH protect, noconstant(0)
   DECLARE dm_err_emsg = vc WITH protect, noconstant("")
   SELECT INTO "nl:"
    FROM user_objects u
    WHERE u.object_type="PROCEDURE"
     AND u.object_name IN ("PROC_INS_CMB_AUDIT_AUTON", "PROC_UPD_CMB_AUDIT_AUTON")
     AND u.status="VALID"
    DETAIL
     IF (u.object_name="PROC_INS_CMB_AUDIT_AUTON")
      dm_ins_ind = 0
     ELSEIF (u.object_name="PROC_UPD_CMB_AUDIT_AUTON")
      dm_upd_ind = 0
     ENDIF
    WITH nocounter
   ;end select
   IF (((dm_ins_ind=1) OR (dm_upd_ind=1)) )
    SET dm_sub_return_val = cmb_create_audit_procs(dm_ins_ind,dm_upd_ind)
   ENDIF
   SET dm_err_queue_clr = error(dm_err_emsg,1)
 END ;Subroutine
 DECLARE dm_emsg = vc WITH protect, noconstant("")
 DECLARE dm_cmb_return_val = vc WITH protect, noconstant("")
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Starting dm_cmb_create_audit_procs script."
 SET dm_cmb_return_val = cmb_create_audit_procs(1,1)
 IF (dm_cmb_return_val != "SUCCESS")
  SET readme_data->message = dm_cmb_return_val
  GO TO exit_script
 ENDIF
 IF (error(dm_emsg,1) != 0)
  SET readme_data->message = concat("ERROR while creating procedures: ",dm_emsg)
  GO TO exit_script
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message =
 "Success: proc_ins_cmb_audit_auton and proc_upd_cmb_audit_auton procedures created in database."
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
