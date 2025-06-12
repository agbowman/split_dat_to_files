CREATE PROGRAM dm_restore_obsolete_table:dba
 DECLARE errcode = i2 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE table_name = vc WITH protect, constant(cnvtupper( $1))
 DECLARE renamed_table = vc WITH protect, noconstant("")
 DECLARE actual_table_exists = i2 WITH protect, noconstant(0)
 DECLARE obsolete_table_exists = i2 WITH protect, noconstant(0)
 IF (trim(table_name)="")
  CALL echo("**************************************************************")
  CALL echo("************ERROR: No input parameter specified***************")
  CALL echo("**************************************************************")
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info d
  WHERE d.info_domain="OBSOLETE_OBJECT_RENAMED"
   AND d.info_char=concat("TABLE|",table_name)
  DETAIL
   renamed_table = d.info_name
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("**************************************************************")
  CALL echo(concat("Cannot restore the table ",table_name," as it is not obsolete"))
  CALL echo("**************************************************************")
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  FROM user_tables ut
  WHERE ut.table_name=table_name
  DETAIL
   actual_table_exists = 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM user_tables ut
  WHERE ut.table_name=renamed_table
  DETAIL
   obsolete_table_exists = 1
  WITH nocounter
 ;end select
 IF (obsolete_table_exists=0
  AND actual_table_exists=0)
  CALL echo("**************************************************************")
  CALL echo(concat("ERROR: the tables ",renamed_table," / ",table_name,
    " do not exist in the dictionary"))
  CALL echo("**************************************************************")
  GO TO exit_program
 ENDIF
 IF (obsolete_table_exists=1
  AND actual_table_exists=1)
  CALL echo("**************************************************************")
  CALL echo(concat("ERROR: the tables ",renamed_table," / ",table_name,
    " both exist in the dictionary"))
  CALL echo("**************************************************************")
  GO TO exit_program
 ENDIF
 IF (obsolete_table_exists=1
  AND actual_table_exists=0)
  CALL parser(concat("rdb alter table ",renamed_table," rename to ",table_name," go"))
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   ROLLBACK
   CALL echo("***********************************************************")
   CALL echo(concat("ERROR: Script failed while renaming table ",errmsg))
   CALL echo("***********************************************************")
   GO TO exit_program
  ELSE
   COMMIT
  ENDIF
 ENDIF
 EXECUTE oragen3 table_name
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  CALL echo("***************************************************************")
  CALL echo(concat("ERROR: Script failed in oragen3 ",errmsg))
  CALL echo("***************************************************************")
  GO TO exit_program
 ENDIF
 DELETE  FROM dm_info
  WHERE info_domain="OBSOLETE_OBJECT*"
   AND info_name IN (table_name, renamed_table)
 ;end delete
 IF (curqual > 2)
  ROLLBACK
  CALL echo("***************************************************************")
  CALL echo(concat("ERROR: More than 2 rows found on dm_info for  ",renamed_table," / ",table_name))
  CALL echo("***************************************************************")
  GO TO exit_program
 ENDIF
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  CALL echo("***************************************************************")
  CALL echo(concat("ERROR: Script failed while deleting dm_info rows ",errmsg))
  CALL echo("***************************************************************")
  GO TO exit_program
 ELSE
  COMMIT
 ENDIF
 CALL echo("*******************************************************************")
 CALL echo(concat("SUCCESS: The table ",table_name," has been restored"))
 CALL echo("*******************************************************************")
#exit_program
END GO
