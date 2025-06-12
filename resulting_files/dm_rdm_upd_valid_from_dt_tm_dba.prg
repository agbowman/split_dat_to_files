CREATE PROGRAM dm_rdm_upd_valid_from_dt_tm:dba
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
 IF (validate(xntr_rows->use_alt,"Z")="Z")
  FREE RECORD xntr_rows
  RECORD xntr_rows(
    1 use_alt = c1
    1 extract_id = f8
  )
  SET xntr_rows->use_alt = "N"
  SET xntr_rows->extract_id = 0.0
 ENDIF
 DECLARE xntr_append_where(xntr_table_name=vc,xntr_alias=vc) = vc
 DECLARE xntr_repalce_where(xntr_orig_where=vc,xntr_table_name=vc,xntr_alias=vc) = vc
 DECLARE xntr_alt_min_id(null) = f8
 DECLARE xntr_alt_max_id(null) = f8
 DECLARE xntr_bypass_readme_status(null) = i2
 DECLARE xntr_add_metadata(xntr_readme_id=f8,xntr_instance=i4,xntr_table_name=vc) = i2
 IF ((validate(xntr_default_id,- (99.0))=- (99.0)))
  DECLARE xntr_default_id = f8 WITH public, constant(- (1.0))
 ENDIF
 IF ((validate(xntr_constant_min_val,- (99.0))=- (99.0)))
  DECLARE xntr_constant_min_val = f8 WITH public, constant(5.0)
 ENDIF
 IF ((validate(xntr_constant_max_val,- (99.0))=- (99.0)))
  DECLARE xntr_constant_max_val = f8 WITH public, constant(10.0)
 ENDIF
 SUBROUTINE xntr_append_where(xntr_table_name,xntr_alias)
   IF (validate(xntr_rows->use_alt,"Q")="Q")
    RETURN("1 = 1")
   ENDIF
   IF ((xntr_rows->use_alt != "Y"))
    RETURN("1 = 1")
   ENDIF
   IF (size(trim(xntr_table_name,3),1)=0)
    RETURN("1 = 1")
   ENDIF
   IF ((xntr_rows->extract_id=0.0))
    RETURN("1 = 1")
   ENDIF
   DECLARE xntrdyninclause = vc WITH public, noconstant("")
   IF (size(trim(xntr_alias,3),1) > 0)
    SET xntrdyninclause = concat(trim(xntr_alias,3),".rowid in (")
   ELSE
    SET xntrdyninclause = "rowid in ("
   ENDIF
   SET xntrdyninclause = concat(xntrdyninclause,
    "select dxerd.new_rowid from dm_xntr_extract_row_data dxerd"," where dxerd.table_name = '",
    xntr_table_name,"' and dxerd.extract_id = ",
    trim(cnvtstring(xntr_rows->extract_id)),")")
   RETURN(xntrdyninclause)
 END ;Subroutine
 SUBROUTINE xntr_replace_where(xntr_orig_where,xntr_table_name,xntr_alias)
   IF (validate(xntr_rows->use_alt,"Q")="Q")
    RETURN(xntr_orig_where)
   ENDIF
   IF ((xntr_rows->use_alt != "Y"))
    RETURN(xntr_orig_where)
   ENDIF
   IF (size(trim(xntr_table_name,3),1)=0)
    RETURN(xntr_orig_where)
   ENDIF
   IF ((xntr_rows->extract_id=0.0))
    RETURN("1 = 1")
   ENDIF
   DECLARE xntrdyninclause = vc WITH public, noconstant("")
   IF (size(trim(xntr_alias,3),1) > 0)
    SET xntrdyninclause = concat(trim(xntr_alias,3),".rowid in (")
   ELSE
    SET xntrdyninclause = "rowid in ("
   ENDIF
   SET xntrdyninclause = concat(xntrdyninclause,
    "select dxerd.new_rowid from dm_xntr_extract_row_data dxerd"," where dxerd.table_name = '",
    xntr_table_name,"' and dxerd.extract_id = ",
    trim(cnvtstring(xntr_rows->extract_id)),")")
   RETURN(xntrdyninclause)
 END ;Subroutine
 SUBROUTINE xntr_alt_min_id(null)
   IF (validate(xntr_rows->use_alt,"Q")="Q")
    RETURN(xntr_default_id)
   ENDIF
   IF ((xntr_rows->use_alt != "Y"))
    RETURN(xntr_default_id)
   ENDIF
   RETURN(xntr_constant_min_val)
 END ;Subroutine
 SUBROUTINE xntr_alt_max_id(null)
   IF (validate(xntr_rows->use_alt,"Q")="Q")
    RETURN(xntr_default_id)
   ENDIF
   IF ((xntr_rows->use_alt != "Y"))
    RETURN(xntr_default_id)
   ENDIF
   RETURN(xntr_constant_max_val)
 END ;Subroutine
 SUBROUTINE xntr_bypass_readme_status(null)
   IF (validate(xntr_rows->use_alt,"Q")="Q")
    RETURN(0)
   ENDIF
   IF ((xntr_rows->use_alt != "Y"))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE xntr_add_metadata(xntr_readme_id,xntr_instance,xntr_table_name)
   DECLARE xntr_dxrt_exists_ind = i2 WITH public, noconstant(0)
   DECLARE xntr_dxrt_errmsg = vc WITH protect, noconstant(" ")
   DECLARE xntr_ccl_def_ind = i2 WITH public, noconstant(0)
   DECLARE xntr_ora_tbl_ind = i2 WITH public, noconstant(0)
   IF (validate(xntr_rows->use_alt,"Q")="Y")
    RETURN(0)
   ENDIF
   IF (xntr_readme_id <= 0.0)
    SET readme_data->status = "F"
    SET readme_data->message = "Failed to pass a valid readme_id to xntr_add_metadata()"
    RETURN(1)
   ENDIF
   IF (xntr_instance <= 0)
    SET readme_data->status = "F"
    SET readme_data->message = "Failed to pass a valid instance to xntr_add_metadata()"
    RETURN(1)
   ENDIF
   IF (size(trim(xntr_table_name,3),1)=0)
    SET readme_data->status = "F"
    SET readme_data->message = "Failed to pass a valid table_name to xntr_add_metadata()"
    RETURN(1)
   ENDIF
   SELECT INTO "nl:"
    dta.table_name
    FROM dtableattr dta
    WHERE dta.table_name="DM_XNTR_README_TABLE"
    DETAIL
     xntr_ccl_def_ind = 1
    WITH nocounter
   ;end select
   IF (error(xntr_dxrt_errmsg,0) != 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed to find CCL Definition:",xntr_dxrt_errmsg)
    RETURN(1)
   ENDIF
   IF (xntr_ccl_def_ind=0)
    SELECT INTO "nl:"
     utcol.table_name
     FROM user_tab_columns utcol
     WHERE utcol.table_name="DM_XNTR_README_TABLE"
     DETAIL
      xntr_ora_tbl_ind = 1
     WITH nocounter
    ;end select
    IF (error(xntr_dxrt_errmsg,0) != 0)
     SET readme_data->status = "F"
     SET readme_data->message = concat("Failed to find Orable Table:",xntr_dxrt_errmsg)
     RETURN(1)
    ENDIF
    IF (xntr_ora_tbl_ind=1)
     EXECUTE oragen3 "DM_XNTR_README_TABLE"
    ELSE
     RETURN(0)
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    dxrt.table_name
    FROM dm_xntr_readme_table dxrt
    WHERE dxrt.readme_id=xntr_readme_id
     AND dxrt.readme_instance=xntr_instance
     AND dxrt.table_name=xntr_table_name
    DETAIL
     xntr_dxrt_exists_ind = 1
    WITH nocounter
   ;end select
   IF (error(xntr_dxrt_errmsg,0) != 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed to Query DM_README_XNTR_TABLE:",xntr_dxrt_errmsg)
    RETURN(1)
   ENDIF
   IF (xntr_dxrt_exists_ind=0)
    INSERT  FROM dm_xntr_readme_table dxrt
     SET dxrt.dm_xntr_readme_table_id = seq(dm_clinical_seq,nextval), dxrt.readme_id = xntr_readme_id,
      dxrt.readme_instance = xntr_instance,
      dxrt.table_name = xntr_table_name, dxrt.updt_applctx = reqinfo->updt_applctx, dxrt.updt_cnt = 0,
      dxrt.updt_dt_tm = cnvtdatetime(curdate,curtime3), dxrt.updt_id = reqinfo->updt_id, dxrt
      .updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
    IF (error(xntr_dxrt_errmsg,0) != 0)
     SET readme_data->status = "F"
     SET readme_data->message = concat("Failed to Insert to DM_XNTR_README_TABLE:",xntr_dxrt_errmsg)
     RETURN(1)
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
 SET readme_data->status = "F"
 SET readme_data->message = "Readme failed: starting script dm_rdm_upd_valid_from_dt_tm..."
 DECLARE errmsg = vc WITH protect, noconstant("")
 IF (xntr_add_metadata(readme_data->readme_id,readme_data->instance,"TASK_ACTIVITY_ASSIGNMENT") != 0)
  GO TO exit_script
 ENDIF
 UPDATE  FROM task_activity ta
  SET ta.send_event_valid_from_dt_tm = datetimeadd(cnvtdatetime(curdate,curtime3),(1.0/ 24.0)), ta
   .updt_cnt = (ta.updt_cnt+ 1), ta.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   ta.updt_id = reqinfo->updt_id, ta.updt_applctx = reqinfo->updt_applctx, ta.updt_task = reqinfo->
   updt_task
  WHERE ta.send_event_valid_from_dt_tm = null
   AND ta.event_id > 0
   AND ta.task_type_cd IN (
  (SELECT
   c.code_value
   FROM code_value c
   WHERE c.code_set=6026
    AND ((c.cdf_meaning="PHONE MSG") OR (c.cdf_meaning="REMINDER")) ))
   AND  EXISTS (
  (SELECT
   1
   FROM task_activity_assignment taa
   WHERE ta.task_id=taa.task_id
    AND taa.assign_person_id > 0
    AND parser(xntr_append_where("TASK_ACTIVITY_ASSIGNMENT","taa"))))
  WITH nocounter
 ;end update
 IF (error(errmsg,0) != 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to update the send_event_valid_from_dt_tm column: ",
   errmsg)
  GO TO exit_script
 ENDIF
 COMMIT
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme performed all required tasks"
#exit_script
 CALL echorecord(readme_data)
 IF (xntr_bypass_readme_status(null)=0)
  EXECUTE dm_readme_status
 ENDIF
END GO
