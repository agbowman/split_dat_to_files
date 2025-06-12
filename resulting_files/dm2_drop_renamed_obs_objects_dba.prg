CREATE PROGRAM dm2_drop_renamed_obs_objects:dba
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
 FREE RECORD renamed_tbls
 RECORD renamed_tbls(
   1 tbl[*]
     2 renamed_tbl_name = vc
     2 table_name = vc
 )
 DECLARE errmsg = c132 WITH public
 DECLARE ltblcnt = i2 WITH public, noconstant(0)
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed:  Starting Script dm2_drop_renamed_obs_objects.prg"
 SELECT INTO "NL:"
  d.info_name
  FROM dm_info d
  WHERE d.info_domain="OBSOLETE_OBJECT_RENAMED"
   AND d.info_char="TABLE|*"
  HEAD REPORT
   ltblcnt = 0
  DETAIL
   ltblcnt = (ltblcnt+ 1), stat = alterlist(renamed_tbls->tbl,ltblcnt), renamed_tbls->tbl[ltblcnt].
   renamed_tbl_name = d.info_name,
   renamed_tbls->tbl[ltblcnt].table_name = substring(7,textlen(d.info_char),d.info_char)
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed selecting values to populate record structure :",errmsg)
  GO TO exit_script
 ENDIF
 IF (ltblcnt > 0)
  IF (currdb="ORACLE")
   FOR (lcnt = 1 TO ltblcnt)
     EXECUTE dm_drop_obsolete_objects value(renamed_tbls->tbl[lcnt].renamed_tbl_name), "TABLE", 1
     IF (error(errmsg,0) > 0)
      SET readme_data->status = "F"
      SET readme_data->message = build("FAILED in dm_drop_obsolete_objects for ",renamed_tbls->tbl[
       lcnt].renamed_tbl_name," :",errmsg)
      GO TO exit_script
     ENDIF
     SELECT INTO "nl:"
      FROM dtableattr a
      PLAN (a
       WHERE (a.table_name=renamed_tbls->tbl[lcnt].table_name))
      WITH nocounter
     ;end select
     IF (curqual > 0)
      CALL parser(concat("drop table ",renamed_tbls->tbl[lcnt].table_name," go"))
      IF (error(errmsg,0) != 0)
       CALL echo(
        "Error dropping table definition(ccl level).Issue the following command to manually drop the definition"
        )
       CALL echo(concat("drop table  ",renamed_tbls->tbl[lcnt].table_name," go "))
       SET readme_data->status = "F"
       SET readme_data->message = concat("Error dropping table at ccl level:",errmsg)
       ROLLBACK
       GO TO exit_script
      ELSE
       COMMIT
      ENDIF
     ENDIF
     DELETE  FROM dm_info di
      WHERE di.info_domain="OBSOLETE_OBJECT_RENAMED"
       AND (di.info_name=renamed_tbls->tbl[lcnt].renamed_tbl_name)
      WITH nocounter
     ;end delete
     IF (error(errmsg,0) > 0)
      ROLLBACK
      SET readme_data->status = "F"
      SET readme_data->message = concat("Failed in deleting from dm_info :",errmsg)
      GO TO exit_script
     ELSE
      COMMIT
     ENDIF
   ENDFOR
   SET readme_data->status = "S"
   SET readme_data->message = "SUCCESS: Renamed table objects were removed"
   GO TO exit_script
  ELSEIF (currdb="DB2UDB")
   SET readme_data->status = "S"
   SET readme_data->message = "Auto-success for DB2 database"
   GO TO exit_script
  ENDIF
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = "SUCCESS: No tables left to drop."
  GO TO exit_script
 ENDIF
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
 FREE RECORD renamed_tbls
END GO
