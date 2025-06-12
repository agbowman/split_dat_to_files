CREATE PROGRAM dm_ocd_ins_upd_product_chk:dba
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
 SET adm_link = fillstring(20,"")
 SET adm_link_end = fillstring(20,"")
 SET str = fillstring(200,"")
 SET table1 = fillstring(100,"")
 SELECT INTO "nl:"
  adm_len = textlen(a.db_link), a.*
  FROM all_synonyms a
  WHERE a.table_name="DM_ENVIRONMENT"
  DETAIL
   adm_link = cnvtupper(trim(substring(1,(findstring(".",a.db_link) - 1),a.db_link))), adm_link_end
    = cnvtupper(trim(substring((findstring(".",a.db_link)+ 1),adm_len,a.db_link)))
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("Error querying all_synonyms table looking for DM_ENVIRONMENT. Readme Failed.")
  SET readme_data->message =
  "Error querying all_synonyms table looking for DM_ENVIRONMENT. Readme Failed."
  SET readme_data->status = "F"
  GO TO end_program
 ELSE
  SELECT INTO "nl:"
   a.*
   FROM all_synonyms a
   WHERE a.table_name="DM_ALPHA_FEATURES"
    AND a.db_link=concat(adm_link,".",adm_link_end)
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET str = build("Error querying all_synonyms table looking for DM_ALPHA_FEATURES with link:",
    adm_link,".",ad_link_end,". Readme Failed.")
   CALL echo(str)
   SET readme_data->message = str
   SET readme_data->status = "F"
   GO TO end_program
  ENDIF
 ENDIF
 SET table1 = build("USER_TAB_COLUMNS@",adm_link)
 SELECT INTO "nl:"
  utc.table_name, utc.column_name
  FROM (value(table1) utc)
  WHERE utc.table_name="DM_ALPHA_FEATURES"
   AND utc.column_name IN ("PRODUCT_AREA_NUMBER", "PRODUCT_AREA_NAME")
  WITH nocounter
 ;end select
 IF (curqual != 2)
  CALL echo(
   "DM_ALPHA_FEATURES table does not have all of the PRODUCT fields defined in Admin. Readme Failed."
   )
  SET readme_data->message =
  "DM_ALPHA_FEATURES table does not have all of the PRODUCT fields defined in Admin. "
  SET readme_data->message = concat(readme_data->message,"Readme Failed.")
  SET readme_data->status = "F"
  GO TO end_program
 ENDIF
 SELECT INTO "nl:"
  l.attr_name
  FROM dtableattr d,
   dtableattrl l
  WHERE l.structtype="F"
   AND btest(l.stat,11)=0
   AND d.table_name="DM_ALPHA_FEATURES"
   AND l.attr_name IN ("PRODUCT_AREA_NUMBER", "PRODUCT_AREA_NAME")
  WITH nocounter
 ;end select
 IF (curqual != 2)
  CALL echo("DM_ALPHA_FEATURES table has the incorrect CCL definition. Readme Failed.")
  SET readme_data->message =
  "DM_ALPHA_FEATURES table has the incorrect CCL definition. Readme Failed."
  SET readme_data->status = "F"
  GO TO end_program
 ENDIF
 SELECT INTO "nl:"
  daf.product_area_number
  FROM dm_alpha_features daf
  WHERE product_area_number > 0
  WITH nocounter
 ;end select
 IF (curqual < 700)
  CALL echo("Import into DM_ALPHA_FEATURES table failed.  Readme Failed.")
  SET readme_data->message = "Import into DM_ALPHA_FEATURES table failed.  Readme Failed."
  SET readme_data->status = "F"
  GO TO end_program
 ELSE
  CALL echo("DM_ALPHA_FEATURES table populated successfully. Readme Successful.")
  SET readme_data->message = "DM_ALPHA_FEATURES table populated successfully. Readme Successful."
  SET readme_data->status = "S"
 ENDIF
#end_program
 EXECUTE dm_readme_status
END GO
