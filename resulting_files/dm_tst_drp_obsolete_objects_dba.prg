CREATE PROGRAM dm_tst_drp_obsolete_objects:dba
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
 SET errmsg = fillstring(132," ")
 SET errcode = 0
 SUBROUTINE check(dummy)
  IF (errcode != 0)
   SET readme_data->message = build(errmsg,"- Readme Failed.")
   SET readme_data->status = "F"
  ELSE
   SET readme_data->message = "Object was Successfully Dropped. - Readme Success."
   SET readme_data->status = "S"
  ENDIF
  CALL echo(readme_data->message)
 END ;Subroutine
 CALL echo("*** Check for Blank Entries w/ -1...")
 EXECUTE dm_drop_obsolete_objects "", "", - (1)
 CALL echo("Should Error Out")
 CALL check(0)
 CALL echo("*** Check for Wild Entries w/ -1...")
 EXECUTE dm_drop_obsolete_objects "*", "*", - (1)
 CALL echo("Should Error Out")
 CALL check(0)
 CALL echo("*** Check for Wild Entry for Object Name w/ 1...")
 EXECUTE dm_drop_obsolete_objects "*", "", 1
 CALL echo("Should Error Out")
 CALL check(0)
 CALL echo("*** Check for Wild Entry for Object Type w/ 1...")
 EXECUTE dm_drop_obsolete_objects "", "*", 1
 CALL echo("Should Error Out")
 CALL check(0)
 CALL echo("*** Check for Wild Entries w/ 1 ...")
 EXECUTE dm_drop_obsolete_objects "*", "*", 1
 CALL echo("Should Error Out")
 CALL check(0)
 CALL echo("*** Check for '*', TABLE , 1 ...")
 EXECUTE dm_drop_obsolete_objects "*", "TABLE", 1
 CALL echo("Should Error Out")
 CALL check(0)
 CALL echo("*** Check for '*', INDEX, 1 ...")
 EXECUTE dm_drop_obsolete_objects "*", "INDEX", 1
 CALL echo("Should Error Out")
 CALL check(0)
 CALL echo("*** Check for Incorrect Object , '*' , 1 ...")
 EXECUTE dm_drop_obsolete_objects "TEMP_CE_EVENT", "*", 1
 CALL echo("Should Error Out")
 CALL check(0)
 CALL echo("*** Check for Incorrect Object, '*', 1 ...")
 EXECUTE dm_drop_obsolete_objects "XPKTEMP_CE_EVENT", "*", 1
 CALL echo("Should Error Out")
 CALL check(0)
 CALL echo("*** Check for a Non-Existing Object ...")
 EXECUTE dm_drop_obsolete_objects "TEMP_CE_EVENT", "INDEX", 1
 CALL echo("Should Work - Object Not Found are OK")
 CALL check(0)
 CALL echo("*** Check for a Non-Existing Object ...")
 EXECUTE dm_drop_obsolete_objects "XPKTEMP_CE_EVENT", "TABLE", 1
 CALL echo("Should Work - Object Not Found are OK")
 CALL check(0)
 CALL echo("*** Check for a Valid Synonym Drop ...")
 CALL echo("rdb create public synonym MG_JUNK for DM_TABLES_DOC@r7adm1 go")
 CALL parser("rdb create public synonym MG_JUNK for DM_TABLES_DOC@r7adm1 go",1)
 EXECUTE dm_drop_obsolete_objects "MG_JUNK", "SYNONYM", 1
 CALL echo("Should Work")
 CALL check(0)
 CALL echo("*** Check for a Valid Table, Synonym and Index Drop ...")
 CALL echo("rdb create table MG_JUNK as select * from user_tables go")
 CALL parser("rdb create table MG_JUNK as select * from user_tables go",1)
 CALL echo("rdb create public synonym MG_JUNK for v500.mg_junk go")
 CALL parser("rdb create public synonym MG_JUNK for v500.mg_junk go",1)
 CALL echo("rdb create index xiemg_junk on mg_junk (table_name) go")
 CALL parser("rdb create index xiemg_junk on mg_junk (table_name) go",1)
 EXECUTE dm_drop_obsolete_objects "MG_JUNK", "TABLE", 1
 CALL echo("Should Work")
 CALL check(0)
 DELETE  FROM dm_tables_doc
  WHERE table_name="MG_JUNK"
 ;end delete
 DELETE  FROM dm_indexes_doc
  WHERE index_name="XIEMG_JUNK"
 ;end delete
 COMMIT
 CALL echo("*** Check for Valid Index Drop ...")
 CALL echo("rdb create table MG_JUNK as select * from user_tables go")
 CALL parser("rdb create table MG_JUNK as select * from user_tables go",1)
 CALL echo("rdb create index xiemg_junk on mg_junk (table_name) go")
 CALL parser("rdb create index xiemg_junk on mg_junk (table_name) go",1)
 EXECUTE dm_drop_obsolete_objects "XIEMG_JUNK", "INDEX", 1
 CALL echo("Should Work")
 CALL check(0)
 DELETE  FROM dm_indexes_doc
  WHERE index_name="XIEMG_JUNK"
 ;end delete
 COMMIT
 CALL echo("drop mg_junk table via script")
 EXECUTE dm_drop_obsolete_objects "MG_JUNK", "TABLE", 1
 CALL echo("Should Work")
 CALL check(0)
 DELETE  FROM dm_tables_doc
  WHERE table_name="MG_JUNK"
 ;end delete
 COMMIT
 CALL echo("*** Check for Valid Unique Constraint Drop ...")
 CALL echo("rdb create table MG_JUNK as select * from user_tables go")
 CALL parser("rdb create table MG_JUNK as select * from user_tables go",1)
 CALL echo("rdb create index xiemg_junk on mg_junk (tablespace_name) go")
 CALL parser("rdb create index xiemg_junk on mg_junk (tablespace_name) go",1)
 CALL echo(
  "rdb alter table mg_junk add constraint XPKMG_JUNK primary key (table_name) using index tablespace misc go"
  )
 CALL parser(
  "rdb alter table mg_junk add constraint XPKMG_JUNK primary key (table_name) using index tablespace misc go",
  1)
 EXECUTE dm_drop_obsolete_objects "XPKMG_JUNK", "INDEX", 1
 CALL echo("Should Work")
 CALL check(0)
 CALL echo("drop mg_junk table via script")
 EXECUTE dm_drop_obsolete_objects "MG_JUNK", "TABLE", 1
 CALL echo("Should Work")
 CALL check(0)
 DELETE  FROM dm_tables_doc
  WHERE table_name="MG_JUNK"
 ;end delete
 COMMIT
 DELETE  FROM dm_indexes_doc
  WHERE index_name="XPKMG_JUNK"
 ;end delete
 COMMIT
 DELETE  FROM dm_indexes_doc
  WHERE index_name="XIEMG_JUNK"
 ;end delete
 COMMIT
#end_program
 EXECUTE dm_readme_status
END GO
