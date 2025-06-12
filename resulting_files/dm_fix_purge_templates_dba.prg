CREATE PROGRAM dm_fix_purge_templates:dba
 FREE RECORD d_purge_rec
 RECORD d_purge_rec(
   1 cnt = i4
   1 qual[*]
     2 purge_template_nbr = i4
     2 feature_nbr = i4
     2 ocd_nbr = i4
     2 exist_flag = i2
   1 packaging_flag = i2
   1 inhouse_flag = i2
   1 install_flag = i2
 )
 SET d_purge_rec->packaging_flag = 0
 SET d_purge_rec->inhouse_flag = 0
 SET d_purge_rec->install_flag = 0
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="DATA MANAGEMENT"
   AND ((di.info_name="PACKAGING DOMAIN") OR (di.info_name="INHOUSE DOMAIN"))
  DETAIL
   IF (di.info_name="INHOUSE DOMAIN")
    d_purge_rec->inhouse_flag = 1
   ENDIF
   IF (di.info_name="PACKAGING DOMAIN")
    d_purge_recpackaging_flag = 1
   ENDIF
  WITH nocounter
 ;end select
 IF ((d_purge_rec->inhouse_flag=1))
  CALL echo("****************")
  CALL echo("This process CAN NOT be run from a Cerner Engineering Domain !!!")
  CALL echo("****************")
  GO TO end_program
 ENDIF
 SET r_file_exist = 0
 SET r_file_exist = findfile("cer_install:dm_fix_purge_templates.csv")
 IF ( NOT (r_file_exist))
  CALL echo("****************")
  CALL echo(
   "Purge Template Data File 'dm_fix_purge_templates.csv' does not exist in the CER_INSTALL directory."
   )
  CALL echo("****************")
  GO TO end_program
 ENDIF
 FREE DEFINE rtl
 SET logical dm_purge_data_file "cer_install:dm_fix_purge_templates.csv"
 DEFINE rtl "dm_purge_data_file"
 SELECT INTO "nl:"
  new_line = r.line
  FROM rtlt r
  HEAD REPORT
   d_purge_rec->cnt = 0, stat = alterlist(d_purge_rec->qual,d_purge_rec->cnt), ocd_cnt = 0
  DETAIL
   r_1st_comma_pos = 0, r_2nd_comma_pos = 0, r_total_length = 0,
   r_template_nbr = 0, r_feature_nbr = 0, r_ocd_nbr = 0,
   r_1st_comma_pos = findstring(",",r.line,1,0), r_2nd_comma_pos = findstring(",",r.line,1,1),
   r_total_length = textlen(trim(r.line)),
   r_template_nbr = cnvtint(build(substring(1,(r_1st_comma_pos - 1),r.line))), r_feature_nbr =
   cnvtint(build(substring((r_1st_comma_pos+ 1),((r_2nd_comma_pos - r_1st_comma_pos) - 1),r.line))),
   r_ocd_nbr = cnvtint(build(substring((r_2nd_comma_pos+ 1),r_total_length,r.line))),
   d_purge_rec->cnt = (d_purge_rec->cnt+ 1), stat = alterlist(d_purge_rec->qual,d_purge_rec->cnt),
   d_purge_rec->qual[d_purge_rec->cnt].purge_template_nbr = r_template_nbr,
   d_purge_rec->qual[d_purge_rec->cnt].feature_nbr = r_feature_nbr, d_purge_rec->qual[d_purge_rec->
   cnt].ocd_nbr = r_ocd_nbr, d_purge_rec->qual[d_purge_rec->cnt].exist_flag = 0
  WITH nocounter, format = stream, maxrow = 1
 ;end select
 IF ((d_purge_rec->cnt=0))
  CALL echo("****************")
  CALL echo("Error reading Purge Template Data File 'dm_fix_purge_templates.csv' from CER_INSTALL.")
  CALL echo("****************")
  GO TO end_program
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info di,
   dm_alpha_features_env de,
   (dummyt d  WITH seq = value(d_purge_rec->cnt))
  PLAN (d)
   JOIN (di
   WHERE di.info_domain="DATA MANAGEMENT"
    AND di.info_name="DM_ENV_ID")
   JOIN (de
   WHERE de.environment_id=di.info_number
    AND (de.alpha_feature_nbr=d_purge_rec->qual[d.seq].ocd_nbr))
  ORDER BY de.alpha_feature_nbr
  DETAIL
   d_purge_rec->qual[d.seq].exist_flag = 1
  WITH nocounter
 ;end select
 IF ( NOT (curqual))
  CALL echo("****************")
  CALL echo("There are NO Distribution Packages installed in this environment...")
  CALL echo("****************")
  GO TO end_program
 ENDIF
 CALL echo("****************")
 CALL echo("Determine ADMIN database link:")
 CALL echo("****************")
 SET r_adm_link = fillstring(20," ")
 SELECT INTO "nl:"
  FROM all_synonyms a
  WHERE a.synonym_name="DM_ENVIRONMENT"
  DETAIL
   r_adm_link = cnvtlower(substring(1,(findstring(".",a.db_link) - 1),a.db_link))
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("*****************************************************************")
  CALL echo("Error querying all_synonyms looking for DM_ENVIRONMENT.")
  CALL echo(errmsg)
  CALL echo("You may need to exit CCL and retry.")
  CALL echo("*****************************************************************")
  GO TO end_program
 ENDIF
 CALL echo("****************")
 CALL echo("Checking if the OCD column exists on the following tables:")
 CALL echo("  DM_ADM_PURGE_TEMPLATE, DM_ADM_PURGE_TOKEN & DM_ADM_PURGE_TABLE.")
 CALL echo("****************")
 SET r_template_ind = 0
 SET r_token_ind = 0
 SET r_table_ind = 0
 SET r_admin_tale = fillstring(30," ")
 SET r_admin_table = build("USER_TAB_COLUMNS@",r_adm_link)
 SELECT INTO "nl:"
  c.table_name, c.column_name
  FROM (value(r_admin_table) c)
  WHERE c.table_name IN ("DM_ADM_PURGE_TEMPLATE", "DM_ADM_PURGE_TOKEN", "DM_ADM_PURGE_TABLE")
   AND c.column_name="OCD"
  DETAIL
   IF (c.table_name="DM_ADM_PURGE_TEMPLATE")
    r_template_ind = 1
   ENDIF
   IF (c.table_name="DM_ADM_PURGE_TOKEN")
    r_token_ind = 1
   ENDIF
   IF (c.table_name="DM_ADM_PURGE_TOKEN")
    r_table_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (((r_template_ind=0) OR (((r_token_ind=0) OR (r_table_ind=0)) )) )
  CALL echo("****************")
  IF (r_template_ind=0)
   CALL echo("The OCD column is missing on the DM_ADM_PURGE_TEMPLATE table.")
  ENDIF
  IF (r_token_ind=0)
   CALL echo("The OCD column is missing on the DM_ADM_PURGE_TOKEN    table.")
  ENDIF
  IF (r_table_ind=0)
   CALL echo("The OCD column is missing on the DM_ADM_PURGE_TABLE    table.")
  ENDIF
  CALL echo("")
  CALL echo("Please run DM_OCD_SETUP_ADMIN to add the column on the above mentioned Admin tables.")
  CALL echo("****************")
  GO TO end_program
 ENDIF
 CALL echo("****************")
 CALL echo("Checking if a synonym exists for the following tables:")
 CALL echo("  DM_ADM_PURGE_TEMPLATE, DM_ADM_PURGE_TOKEN & DM_ADM_PURGE_TABLE.")
 CALL echo("****************")
 SET r_template_ind = 0
 SET r_token_ind = 0
 SET r_table_ind = 0
 SELECT INTO "nl:"
  FROM all_synonyms a
  WHERE a.synonym_name IN ("DM_ADM_PURGE_TEMPLATE", "DM_ADM_PURGE_TOKEN", "DM_ADM_PURGE_TABLE")
  DETAIL
   IF (a.synonym_name="DM_ADM_PURGE_TEMPLATE")
    r_template_ind = 1
   ENDIF
   IF (a.synonym_name="DM_ADM_PURGE_TOKEN")
    r_token_ind = 1
   ENDIF
   IF (a.synonym_name="DM_ADM_PURGE_TOKEN")
    r_table_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (((r_template_ind=0) OR (((r_token_ind=0) OR (r_table_ind=0)) )) )
  CALL echo("****************")
  IF (r_template_ind=0)
   CALL echo("Creating PUBLIC synonym for DM_ADM_PURGE_TEMPLATE table.")
   CALL parser(build("rdb create public synonym DM_ADM_PURGE_TEMPLATE for DM_ADM_PURGE_TEMPLATE@",
     r_adm_link," go"))
  ENDIF
  IF (r_token_ind=0)
   CALL echo("Creating PUBLIC synonym for DM_ADM_PURGE_TOKEN table.")
   CALL parser(build("rdb create public synonym DM_ADM_PURGE_TOKEN for DM_ADM_PURGE_TOKEN@",
     r_adm_link," go"))
  ENDIF
  IF (r_table_ind=0)
   CALL echo("Creating PUBLIC synonym for DM_ADM_PURGE_TABLE table.")
   CALL parser(build("rdb create public synonym DM_ADM_PURGE_TABLE for DM_ADM_PURGE_TABLE@",
     r_adm_link," go"))
  ENDIF
  CALL echo("****************")
  SET r_template_ind = 0
  SET r_token_ind = 0
  SET r_table_ind = 0
  SELECT INTO "nl:"
   FROM all_synonyms a
   WHERE a.synonym_name IN ("DM_ADM_PURGE_TEMPLATE", "DM_ADM_PURGE_TOKEN", "DM_ADM_PURGE_TABLE")
   DETAIL
    IF (a.synonym_name="DM_ADM_PURGE_TEMPLATE")
     r_template_ind = 1
    ENDIF
    IF (a.synonym_name="DM_ADM_PURGE_TOKEN")
     r_token_ind = 1
    ENDIF
    IF (a.synonym_name="DM_ADM_PURGE_TOKEN")
     r_table_ind = 1
    ENDIF
   WITH nocounter
  ;end select
  IF (((r_template_ind=0) OR (((r_token_ind=0) OR (r_table_ind=0)) )) )
   CALL echo("****************")
   IF (r_template_ind=0)
    CALL echo("Failed to build a PUBLIC synonym for DM_ADM_PURGE_TEMPLATE table.")
   ENDIF
   IF (r_token_ind=0)
    CALL echo("Failed to build a PUBLIC synonym for DM_ADM_PURGE_TOKEN table.")
   ENDIF
   IF (r_table_ind=0)
    CALL echo("Failed to build a PUBLIC synonym for DM_ADM_PURGE_TABLE table.")
   ENDIF
   CALL echo("****************")
   GO TO end_program
  ENDIF
 ENDIF
 CALL echo("****************")
 CALL echo("Checking if the CCL definition exists for the following tables:")
 CALL echo("  DM_ADM_PURGE_TEMPLATE, DM_ADM_PURGE_TOKEN & DM_ADM_PURGE_TABLE.")
 CALL echo("****************")
 SET r_template_ind = 0
 SET r_token_ind = 0
 SET r_table_ind = 0
 SELECT INTO "nl:"
  d.table_name, l.attr_name
  FROM dtableattr d,
   dtableattrl l
  WHERE l.structtype="F"
   AND btest(l.stat,11)=0
   AND d.table_name IN ("DM_ADM_PURGE_TEMPLATE", "DM_ADM_PURGE_TOKEN", "DM_ADM_PURGE_TABLE")
   AND l.attr_name="OCD"
  DETAIL
   IF (d.table_name="DM_ADM_PURGE_TEMPLATE")
    r_template_ind = 1
   ENDIF
   IF (d.table_name="DM_ADM_PURGE_TOKEN")
    r_token_ind = 1
   ENDIF
   IF (d.table_name="DM_ADM_PURGE_TABLE")
    r_table_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (((r_template_ind=0) OR (((r_token_ind=0) OR (r_table_ind=0)) )) )
  CALL echo("****************")
  IF (r_template_ind=0)
   CALL echo("Creating CCL DEF for DM_ADM_PURGE_TEMPLATE table.")
   CALL parser(build("oragen3 'DM_ADM_PURGE_TEMPLATE@",r_adm_link,"' go"))
  ENDIF
  IF (r_token_ind=0)
   CALL echo("Creating CCL DEF for DM_ADM_PURGE_TOKEN table.")
   CALL parser(build("oragen3 'DM_ADM_PURGE_TOKEN@",r_adm_link,"' go"))
  ENDIF
  IF (r_table_ind=0)
   CALL echo("Creating CCL DEF for DM_ADM_PURGE_TABLE table.")
   CALL parser(build("oragen3 'DM_ADM_PURGE_TABLE@",r_adm_link,"' go"))
  ENDIF
  CALL echo("****************")
  SET r_template_ind = 0
  SET r_token_ind = 0
  SET r_table_ind = 0
  SELECT INTO "nl:"
   d.table_name, l.attr_name
   FROM dtableattr d,
    dtableattrl l
   WHERE l.structtype="F"
    AND btest(l.stat,11)=0
    AND d.table_name IN ("DM_ADM_PURGE_TEMPLATE", "DM_ADM_PURGE_TOKEN", "DM_ADM_PURGE_TABLE")
    AND l.attr_name="OCD"
   DETAIL
    IF (d.table_name="DM_ADM_PURGE_TEMPLATE")
     r_template_ind = 1
    ENDIF
    IF (d.table_name="DM_ADM_PURGE_TOKEN")
     r_token_ind = 1
    ENDIF
    IF (d.table_name="DM_ADM_PURGE_TABLE ")
     r_table_ind = 1
    ENDIF
   WITH nocounter
  ;end select
  IF (((r_template_ind=0) OR (((r_token_ind=0) OR (r_table_ind=0)) )) )
   CALL echo("****************")
   IF (r_template_ind=0)
    CALL echo("Failed to build CCL DEF for DM_ADM_PURGE_TEMPLATE table.")
   ENDIF
   IF (r_token_ind=0)
    CALL echo("Failed to build CCL DEF for DM_ADM_PURGE_TOKEN table.")
   ENDIF
   IF (r_table_ind=0)
    CALL echo("Failed to build CCL DEF for DM_ADM_PURGE_TABLE table.")
   ENDIF
   CALL echo("****************")
   GO TO end_program
  ENDIF
 ENDIF
 CALL echo("****************")
 CALL echo(
  "Updating DM_ADM_PURGE_TEMPLATE table with the correct Distribution Package Number information ... "
  )
 CALL echo("****************")
 UPDATE  FROM dm_adm_purge_template a,
   (dummyt d  WITH seq = value(d_purge_rec->cnt))
  SET a.ocd = d_purge_rec->qual[d.seq].ocd_nbr
  PLAN (d
   WHERE (d_purge_rec->qual[d.seq].exist_flag=1))
   JOIN (a
   WHERE ((a.ocd = null) OR (a.ocd=0))
    AND (a.template_nbr=d_purge_rec->qual[d.seq].purge_template_nbr)
    AND (a.feature_nbr=d_purge_rec->qual[d.seq].feature_nbr))
  WITH nocounter
 ;end update
 COMMIT
 CALL echo("****************")
 CALL echo(build("Nbr of Rows Updated: ",curqual))
 CALL echo("****************")
 IF (curqual > 0)
  SET d_purge_rec->install_flag = 1
 ENDIF
 CALL echo("****************")
 CALL echo(
  "Updating DM_ADM_PURGE_TABLE table with the correct Distribution Package Number information ... ")
 CALL echo("****************")
 UPDATE  FROM dm_adm_purge_table a,
   (dummyt d  WITH seq = value(d_purge_rec->cnt))
  SET a.ocd = d_purge_rec->qual[d.seq].ocd_nbr
  PLAN (d
   WHERE (d_purge_rec->qual[d.seq].exist_flag=1))
   JOIN (a
   WHERE ((a.ocd = null) OR (a.ocd=0))
    AND (a.template_nbr=d_purge_rec->qual[d.seq].purge_template_nbr)
    AND (a.feature_nbr=d_purge_rec->qual[d.seq].feature_nbr))
  WITH nocounter
 ;end update
 COMMIT
 CALL echo("****************")
 CALL echo(build("Nbr of Rows Updated: ",curqual))
 CALL echo("****************")
 IF (curqual > 0)
  SET d_purge_rec->install_flag = 1
 ENDIF
 CALL echo("****************")
 CALL echo(
  "Updating DM_ADM_PURGE_TOKEN table with the correct Distribution Package Number information ... ")
 CALL echo("****************")
 UPDATE  FROM dm_adm_purge_token a,
   (dummyt d  WITH seq = value(d_purge_rec->cnt))
  SET a.ocd = d_purge_rec->qual[d.seq].ocd_nbr
  PLAN (d
   WHERE (d_purge_rec->qual[d.seq].exist_flag=1))
   JOIN (a
   WHERE ((a.ocd = null) OR (a.ocd=0))
    AND (a.template_nbr=d_purge_rec->qual[d.seq].purge_template_nbr)
    AND (a.feature_nbr=d_purge_rec->qual[d.seq].feature_nbr))
  WITH nocounter
 ;end update
 COMMIT
 CALL echo("****************")
 CALL echo(build("Nbr of Rows Updated: ",curqual))
 CALL echo("****************")
 IF (curqual > 0)
  SET d_purge_rec->install_flag = 1
 ENDIF
 CALL echo("")
 CALL echo("")
 CALL echo("****************")
 CALL echo(
  "Success: The Distribution Package Numbers have successfully been updated on the Purge Template Tables."
  )
 CALL echo("****************")
 IF (d_purge_rec->install_flag)
  CALL echo("****************")
  CALL echo("Now attempting to install any new or changed Purge Templates.")
  CALL echo("****************")
  EXECUTE dm_purge_adm_tmpl_chg_add
  CALL echo("****************")
  CALL echo("Finished installing new or changed Purge Templates.")
  CALL echo("****************")
 ENDIF
#end_program
 CALL echo("")
 CALL echo("")
 CALL echo("****************")
 CALL echo("Exit Program ...")
 CALL echo("****************")
END GO
