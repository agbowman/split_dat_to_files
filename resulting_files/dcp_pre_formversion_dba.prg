CREATE PROGRAM dcp_pre_formversion:dba
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
 SET readme_data->message = "Readme Failed: Starting script dcp_pre_formversion.prg..."
 DECLARE errmsg = vc WITH protect
 DECLARE table_exists = i2 WITH noconstant(0)
 SELECT INTO "NL:"
  FROM user_tab_columns utc
  WHERE utc.table_name="DCP_FORMS_ACTIVITY"
  DETAIL
   table_exists = 1
  WITH nocounter
 ;end select
 IF (table_exists=0)
  SET readme_data->status = "S"
  SET readme_data->message = "New table, readme not needed to create versioning of forms"
  COMMIT
  GO TO exit_script
 ENDIF
 DECLARE schema_change_done = i2 WITH noconstant(0)
 SELECT INTO "nl:"
  FROM user_tab_columns utc
  WHERE utc.table_name="DCP_FORMS_ACTIVITY"
   AND utc.column_name="VERSION_DT_TM"
  DETAIL
   schema_change_done = 1
  WITH nocounter
 ;end select
 IF (schema_change_done=0)
  CALL parser("rdb alter table dcp_forms_ref add (dcp_form_instance_id number) go")
  CALL parser("rdb alter table dcp_forms_def add (dcp_form_instance_id number) go")
  CALL parser("rdb alter table dcp_section_ref add (dcp_section_instance_id number) go")
  CALL parser("rdb alter table dcp_input_ref add (dcp_section_instance_id number) go")
  CALL parser("rdb alter table dcp_forms_activity add (version_dt_tm date) go")
  CALL parser("oragen3 'dcp_forms_ref' go")
  CALL parser("oragen3 'dcp_forms_def' go")
  CALL parser("oragen3 'dcp_section_ref' go")
  CALL parser("oragen3 'dcp_input_ref' go")
  CALL parser("oragen3 'dcp_forms_activity' go")
 ENDIF
 SET cont = 1
 WHILE (cont)
   UPDATE  FROM dcp_forms_ref dfr
    SET dfr.dcp_form_instance_id = cnvtreal(seq(carenet_seq,nextval)), active_ind = 1
    WHERE dfr.dcp_form_instance_id=null
     AND dfr.dcp_forms_ref_id != 0
    WITH maxqual(dfr,50000)
   ;end update
   IF (curqual < 50000)
    SET cont = 0
   ENDIF
   IF (error(errmsg,0) > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed to update DCP_FORMS_REF:",errmsg)
    GO TO exit_script
   ELSE
    COMMIT
   ENDIF
 ENDWHILE
 SET cont = 1
 WHILE (cont)
   UPDATE  FROM dcp_forms_def dfd
    SET dfd.dcp_form_instance_id =
     (SELECT
      dfr.dcp_form_instance_id
      FROM dcp_forms_ref dfr
      WHERE dfr.dcp_forms_ref_id=dfd.dcp_forms_ref_id)
    WHERE dfd.dcp_form_instance_id=null
    WITH maxqual(dfd,50000)
   ;end update
   IF (curqual < 50000)
    SET cont = 0
   ENDIF
   IF (error(errmsg,0) > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed to update DCP_FORMS_DEF:",errmsg)
    GO TO exit_script
   ELSE
    COMMIT
   ENDIF
 ENDWHILE
 CALL echo("PVReadMe 1114: Successfull assignment of dcp_form_instance_id.")
 SET cont = 1
 WHILE (cont)
   UPDATE  FROM dcp_section_ref dsr
    SET dsr.dcp_section_instance_id = cnvtreal(seq(carenet_seq,nextval)), active_ind = 1
    WHERE dsr.dcp_section_instance_id=null
     AND dsr.dcp_section_ref_id != 0
    WITH maxqual(dsr,50000)
   ;end update
   IF (curqual < 50000)
    SET cont = 0
   ENDIF
   IF (error(errmsg,0) > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed to update DCP_SECTION_REF:",errmsg)
    GO TO exit_script
   ELSE
    COMMIT
   ENDIF
 ENDWHILE
 SET cont = 1
 WHILE (cont)
   UPDATE  FROM dcp_input_ref dir
    SET dir.dcp_section_instance_id =
     (SELECT
      dsr.dcp_section_instance_id
      FROM dcp_section_ref dsr
      WHERE dsr.dcp_section_ref_id=dir.dcp_section_ref_id)
    WHERE dir.dcp_section_instance_id=null
    WITH maxqual(dir,50000)
   ;end update
   IF (curqual < 50000)
    SET cont = 0
   ENDIF
   IF (error(errmsg,0) > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed to update DCP_INPUT_REF:",errmsg)
    GO TO exit_script
   ELSE
    COMMIT
   ENDIF
 ENDWHILE
 CALL echo("PVReadMe 1114: Successful assignment of dcp_section_instance_id.")
 SELECT INTO "nl:"
  FROM dcp_forms_activity dfa
  WHERE dfa.version_dt_tm=null
   AND dfa.dcp_forms_activity_id > 0
  WITH maxqual(dfa,10)
 ;end select
 IF (curqual=0)
  SET readme_data->message = "Success: PVReadme 1114:No row to be updated in dcp_forms_activity"
  SET readme_data->status = "S"
  COMMIT
  GO TO exit_script
 ENDIF
 SET cnt = 0
 SET cont = 1
 WHILE (cont)
   SET cnt = (cnt+ 1)
   UPDATE  FROM dcp_forms_activity dfa
    SET dfa.version_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE dfa.version_dt_tm=null
     AND dfa.dcp_forms_activity_id > 0
    WITH maxqual(dfa,50000)
   ;end update
   IF (curqual < 50000)
    SET cont = 0
   ENDIF
   IF (error(errmsg,0) > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed to update DCP_FORMS_ACTIVITY:",errmsg)
    GO TO exit_script
   ELSE
    COMMIT
   ENDIF
 ENDWHILE
 CALL echo(build("PVReadMe 1114: ",cnt," rows updated on dcp_forms_activity."))
 SET readme_data->status = "S"
 SET readme_data->message = build("Success: PVReadMe 1114: updates successfull.")
 COMMIT
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
