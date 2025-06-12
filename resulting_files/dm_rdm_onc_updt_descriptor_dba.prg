CREATE PROGRAM dm_rdm_onc_updt_descriptor:dba
 DECLARE program_version = vc WITH private, constant("001")
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
 SET readme_data->message = "Readme failed: Starting script onc_updt..."
 DECLARE error_cd = f8 WITH protected, noconstant(0.0)
 DECLARE error_msg = c132 WITH protected, noconstant("")
 IF (xntr_add_metadata(readme_data->readme_id,readme_data->instance,"ce_coded_result") != 0)
  GO TO exit_program
 ENDIF
 DECLARE range_inc = f8 WITH protect, noconstant(250000.0)
 DECLARE max_range = f8 WITH protect, noconstant(range_inc)
 DECLARE max_id = f8 WITH protect, noconstant(0.0)
 DECLARE min_range = f8 WITH protect, noconstant(1.0)
 SET minimum_event_id = xntr_alt_min_id(null)
 IF (minimum_event_id=xntr_default_id)
  SELECT INTO "nl:"
   minimum_event_id = min(cecr.event_id)
   FROM ce_coded_result cecr
   WHERE cecr.event_id > 0.0
   DETAIL
    min_range = minimum_event_id
   WITH nocounter
  ;end select
  SET error_cd = error(error_msg,0)
  IF (error_cd != 0)
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to retrieve min_id from CE_CODED_RESULT: ",error_msg)
   GO TO exit_program
  ENDIF
  SELECT INTO "nl:"
   maximum_event_id = max(cecr.event_id)
   FROM ce_coded_result cecr
   DETAIL
    max_id = maximum_event_id
   WITH nocounter
  ;end select
  SET error_cd = error(error_msg,0)
  IF (error_cd != 0)
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to retrieve max_id from CE_CODED_RESULT: ",error_msg)
   GO TO exit_program
  ENDIF
 ELSE
  SET maximum_event_id = xntr_alt_max_id(null)
 ENDIF
 SET readme_data->message = "Readme failed: Updating existing CE_CODED_RESULT descriptor..."
 DECLARE total_updt_cnt = f8 WITH protect, noconstant(0.0)
 DECLARE update_dt_tm = dq8 WITH protect, constant(cnvtdatetime(curdate,curtime3))
 DECLARE range_recalculated_ind = i2 WITH protect, noconstant(0)
 DECLARE parserstring = vc WITH protect, noconstant("")
 CALL echo("*******************************************************")
 CALL echo("Updating descriptor for existing ce_coded_result...")
 CALL echo(concat("-> Process started at: ",format(sysdate,";;q")))
 CALL echo("*******************************************************")
 SET parserstring = xntr_replace_where("cecr.event_id+0 between min_range and max_range",
  "CE_CODED_RESULT","cecr")
 WHILE (min_range <= max_id)
   CALL echo(concat("> Processing range ",build(min_range)," - ",build(max_range)," [",
     format(((cnvtreal(min_range)/ cnvtreal(max_id)) * 100.0),"###.##"),"% complete]..."))
   UPDATE  FROM ce_coded_result cecr
    SET cecr.descriptor = "", cecr.updt_cnt = (cecr.updt_cnt+ 1), cecr.updt_dt_tm = cnvtdatetime(
      update_dt_tm),
     cecr.updt_id = reqinfo->updt_id, cecr.updt_task = reqinfo->updt_task, cecr.updt_applctx =
     reqinfo->updt_applctx
    WHERE parser(parserstring)
     AND cecr.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
     AND (cecr.event_id=
    (SELECT
     ce.event_id
     FROM clinical_event ce
     WHERE (ce.parent_event_id=
     (SELECT
      ofa.event_id
      FROM onc_form_activity ofa
      WHERE ofa.event_id > 0.0))))
   ;end update
   SET total_updt_cnt = (curqual+ total_updt_cnt)
   IF (error(error_msg,0) != 0)
    IF (((findstring("ORA-01555",error_msg) != 0) OR (((findstring("ORA-01650",error_msg) != 0) OR (
    ((findstring("ORA-01562",error_msg) != 0) OR (((findstring("ORA-30036",error_msg) != 0) OR (((
    findstring("ORA-30027",error_msg) != 0) OR (findstring("ORA-01581",error_msg) != 0)) )) )) )) ))
    )
     ROLLBACK
     CALL echo("TRAPPED ROLLBACK SEGMENT ERROR......RESTRUCTURING README")
     SET readme_data->message = error_msg
     IF (range_inc > 2000)
      SET range_inc = ceil((range_inc/ 2))
      SET range_recalculated_ind = 1
     ELSEIF (range_inc > 1000)
      SET range_inc = 1000
      SET range_recalculated_ind = 1
     ELSE
      SET readme_data->status = "F"
      SET readme_data->message = concat("Encountered rollback segment errors; Could not recover...",
       readme_data->message)
      GO TO exit_program
     ENDIF
    ELSE
     SET readme_data->status = "F"
     SET readme_data->message = concat("Failure during CE_CODED_RESULT update:",error_msg)
     GO TO exit_program
    ENDIF
   ELSE
    COMMIT
   ENDIF
   IF (range_recalculated_ind=1)
    SET max_range = ((min_range+ range_inc) - 1)
    SET range_recalculated_ind = 0
   ELSE
    SET min_range = (max_range+ 1)
    SET max_range = (max_range+ range_inc)
   ENDIF
 ENDWHILE
 CALL echo("*******************************************************")
 CALL echo("Updating descriptor for existing ce_coded_result...")
 CALL echo(concat("-> Process completed at: ",format(sysdate,";;q")))
 CALL echo("*******************************************************")
 SET readme_data->status = "S"
 SET readme_data->message = concat("Readme updated ",trim(cnvtstring(total_updt_cnt)),
  " record(s) successfully.")
#exit_program
 IF ((readme_data->status="F"))
  ROLLBACK
 ENDIF
 CALL echorecord(readme_data)
 IF (xntr_bypass_readme_status(null)=0)
  EXECUTE dm_readme_status
 ENDIF
END GO
