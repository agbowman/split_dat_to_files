CREATE PROGRAM dm_modify_table_gen:dba
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="DATA MANAGEMENT"
   AND di.info_name="INHOUSE DOMAIN"
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo(
   "******************************************************************************************")
  CALL echo(
   "          DM_MODIFY_TABLE_GEN should no longer be used to make changes to tables.         ")
  CALL echo(
   "******************************************************************************************")
  GO TO exit_script
 ENDIF
 SET trace = nocost
 SET message = noinformation
 DECLARE table_owner = vc
 DECLARE formatted_table_owner = vc
 DECLARE data_model_section = vc
 DECLARE start = i4
 DECLARE length = i4
 SELECT INTO "nl:"
  dms.owner_name, dtd.table_name
  FROM dm_data_model_section dms,
   dm_tables_doc dtd
  PLAN (dtd
   WHERE dtd.table_name=cnvtupper(value( $2)))
   JOIN (dms
   WHERE dms.data_model_section=dtd.data_model_section)
  DETAIL
   table_owner = dms.owner_name, data_model_section = trim(dms.data_model_section)
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo(concat("Table_name=",cnvtupper(value( $2))," could not be found in dm_tables_doc"))
  CALL echo("If further assistance is needed, please contact Dan Murphy, Tony Myers,")
  CALL echo("Dwight Sloan or Charley Donnici.")
  GO TO exit_script
 ENDIF
 CASE (table_owner)
  OF "MYERS, TONY":
  OF "MURPHY, DAN":
  OF "SLOAN, DWIGHT":
  OF "DONNICI, CHARLEY":
   SET start = findstring(",",table_owner,1)
   IF (start > 0)
    SET formatted_table_owner = concat(substring((start+ 2),((size(table_owner) - start) - 1),
      table_owner)," ",substring(1,(start - 1),table_owner))
   ELSE
    SET formatted_table_owner = table_owner
   ENDIF
   CALL echo("DM_MODIFY_TABLE_GEN should no longer be used to make")
   CALL echo("changes to tables.")
   CALL echo(concat("Please contact ",formatted_table_owner,"."))
   CALL echo(concat("He is the Database Architect that owns the ",data_model_section,
     " data model section"))
   CALL echo(concat("where the ",cnvtupper(value( $2))," table resides and"))
   CALL echo("will assist in the design of any table modifications.")
   CALL echo("")
  ELSE
   CALL echo("DM_MODIFY_TABLE_GEN should no longer be used to make")
   CALL echo("changes to tables.  Please contact Dan Murphy, Tony Myers,")
   CALL echo("Dwight Sloan or Charley Donnici for assistance in determining")
   CALL echo("the database architect assigned to this data model section")
 ENDCASE
#exit_script
END GO
