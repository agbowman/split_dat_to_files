CREATE PROGRAM dm_obsolete_purge_table_rowid:dba
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
 DECLARE syn_owner = c10
 SET syn_owner = " "
 SET readme_data->status = "F"
 SET readme_data->message = "Failed to obsolete Procedure and Synonym"
 IF (currdb="ORACLE")
  SET errmsg = fillstring(132," ")
  SET errcode = 0
  EXECUTE dm_drop_obsolete_objects "DM_PURGE_TABLE_ROWID", "PROCEDURE", 1
  IF (errcode != 0)
   SET readme_data->message = build(errmsg,"- Readme Failed.")
   GO TO exit_script
  ELSE
   CALL echo("*******************************")
   CALL echo("Procedure has been obsoleted...")
   CALL echo("*******************************")
  ENDIF
  SELECT INTO "nl:"
   FROM all_synonyms s
   WHERE s.synonym_name="DM_PURGE_TABLE_ROWID"
   DETAIL
    IF (s.owner="PUBLIC")
     syn_owner = "PUB"
    ELSEIF (s.owner="PRIVATE")
     syn_owner = "PRIV"
    ELSE
     syn_owner = currdbuser
    ENDIF
   WITH nocounter
  ;end select
  IF (curqual > 0
   AND syn_owner="PUB")
   CALL parser("RDB DROP PUBLIC SYNONYM DM_PURGE_TABLE_ROWID GO",1)
   IF (errcode != 0)
    SET readme_data->message = build(errmsg,"- Readme Failed.")
    GO TO exit_script
   ELSE
    CALL echo("***************************")
    CALL echo("Synonym has been obsoleted...")
    CALL echo("***************************")
   ENDIF
  ELSEIF (curqual > 0
   AND syn_owner="PRIV")
   CALL parser("RDB DROP PRIVATE SYNONYM DM_PURGE_TABLE_ROWID GO",1)
   IF (errcode != 0)
    SET readme_data->message = build(errmsg,"- Readme Failed.")
    GO TO exit_script
   ELSE
    CALL echo("***************************")
    CALL echo("Synonym has been obsoleted...")
    CALL echo("***************************")
   ENDIF
  ELSEIF (curqual > 0
   AND syn_owner=currdbuser)
   CALL parser("RDB DROP SYNONYM DM_PURGE_TABLE_ROWID GO",1)
   IF (errcode != 0)
    SET readme_data->message = build(errmsg,"- Readme Failed.")
    GO TO exit_script
   ELSE
    CALL echo("***************************")
    CALL echo("Synonym has been obsoleted...")
    CALL echo("***************************")
   ENDIF
  ELSE
   CALL echo("*************************************")
   CALL echo("Synonym not found, no action taken...")
   CALL echo("*************************************")
  ENDIF
  SELECT INTO "nl:"
   FROM all_synonyms
   WHERE synonym_name="DM_PURGE_TABLE_ROWID"
  ;end select
  IF (curqual > 0)
   SET readme_data->status = "F"
   SET readme_data->message = "Readme Failed. Synonym did not get obsoleted."
  ENDIF
  IF (errcode=0)
   SET readme_data->status = "S"
   SET readme_data->message =
   "Synonym and Procedure - DM_PURGE_TABLE_ROWID were dropped successfully"
  ENDIF
 ELSEIF (currdb="DB2UDB")
  SET readme_data->status = "S"
  SET readme_data->message = "Auto-success for DB2 database"
 ENDIF
#exit_script
 EXECUTE dm_readme_status
END GO
