CREATE PROGRAM dms_wtslocation_load:dba
 DECLARE nbr_recs = i4 WITH public, noconstant(0)
 DECLARE cnt = i4 WITH public, noconstant(0)
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 SET nbr_recs = size(requestin->list_0,5)
 FOR (cnt = 1 TO nbr_recs)
  SELECT INTO "nl:"
   FROM pc_attribute pca
   WHERE (pca.attribute_name=requestin->list_0[cnt].attribute_name)
    AND (pca.attribute_loc_path=requestin->list_0[cnt].attribute_loc_path)
    AND (pca.attribute_loc_name=requestin->list_0[cnt].attribute_loc_name)
   WITH nocounter
  ;end select
  IF (curqual > 0)
   CALL echo(build("PC attribute: ",requestin->list_0[cnt].attribute_name,
     ", already exists...skipping insert..."))
  ELSE
   INSERT  FROM pc_attribute pca
    SET pca.attribute_id = seq(reference_seq,nextval), pca.attribute_name = requestin->list_0[cnt].
     attribute_name, pca.attribute_display_name = requestin->list_0[cnt].attribute_display_name,
     pca.attribute_desc = requestin->list_0[cnt].attribute_desc, pca.attribute_loc_path = requestin->
     list_0[cnt].attribute_loc_path, pca.attribute_loc_name = requestin->list_0[cnt].
     attribute_loc_name,
     pca.active_ind = 0, pca.updt_dt_tm = cnvtdatetime(curdate,curtime3), pca.updt_id = 0.0,
     pca.updt_task = reqinfo->updt_task, pca.updt_applctx = 0, pca.updt_cnt = 0
    WITH nocounter
   ;end insert
   SET errcode = error(errmsg,1)
   IF (errcode != 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed inserting into the pc_attribute table: ",errmsg)
    GO TO exit_script
   ENDIF
  ENDIF
 ENDFOR
 FREE RECORD wtslocation_config
 RECORD wtslocation_config(
   1 list[6]
     2 name = vc
 )
 SET wtslocation_config->list[1].name = "separate_temp_dirs"
 SET wtslocation_config->list[2].name = "delete_files_in_temp_dir"
 SET wtslocation_config->list[3].name = "debug_level"
 SET wtslocation_config->list[4].name = "log_file_location"
 SET wtslocation_config->list[5].name = "security_level"
 FOR (cnt = 1 TO 5)
  SELECT INTO "nl:"
   FROM wts_location wts
   WHERE (wts.configuration_name=wtslocation_config->list[cnt].name)
   WITH nocounter
  ;end select
  IF (curqual > 0)
   CALL echo(build("WTS Location configuration:  ",wtslocation_config->list[cnt].name,
     ", already exists...skipping insert..."))
  ELSE
   INSERT  FROM wts_location wts
    SET wts.wts_location_id = seq(reference_seq,nextval), wts.configuration_name = wtslocation_config
     ->list[cnt].name, wts.configuration_value_txt = " ",
     wts.updt_dt_tm = cnvtdatetime(curdate,curtime3), wts.updt_id = 0.0, wts.updt_task = reqinfo->
     updt_task,
     wts.updt_applctx = 0, wts.updt_cnt = 0
    WITH nocounter
   ;end insert
   SET errcode = error(errmsg,1)
   IF (errcode != 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed inserting into the wts_location table: ",errmsg)
    GO TO exit_script
   ENDIF
  ENDIF
 ENDFOR
 SET readme_data->status = "S"
#exit_script
 IF ((readme_data->status="S"))
  COMMIT
  SET readme_data->message = "WTS Location reference data successfully loaded."
 ELSE
  ROLLBACK
 ENDIF
 FREE RECORD wtslocation_config
END GO
