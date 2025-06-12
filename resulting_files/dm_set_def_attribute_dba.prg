CREATE PROGRAM dm_set_def_attribute:dba
 CALL echo("Resetting defining_attribute_ind to zero for all rows...")
 UPDATE  FROM dm_columns_doc dcd
  SET dcd.defining_attribute_ind = 0
  WHERE 1=1
 ;end update
 COMMIT
 FREE SET table_list
 RECORD table_list(
   1 qual[*]
     2 table_name = vc
     2 column_name = vc
     2 index_name = vc
     2 uniqueness = vc
   1 count = i4
 )
 SET table_list->count = 0
 SET stat = alterlist(table_list->qual,10)
 SET i = 0
 SET j = 0
 SET n = 0
 SET buff[20] = fillstring(132," ")
 CALL echo("Retreiving table and index information...")
 SELECT INTO "nl:"
  uic.table_name, uic.column_name, ui.index_name,
  ui.uniqueness
  FROM user_ind_columns uic,
   user_indexes ui
  WHERE uic.table_name=ui.table_name
   AND ui.uniqueness="UNIQUE"
   AND uic.index_name=ui.index_name
  DETAIL
   table_list->count = (table_list->count+ 1)
   IF (mod(table_list->count,10)=1)
    stat = alterlist(table_list->qual,(table_list->count+ 9))
   ENDIF
   table_list->qual[table_list->count].table_name = ui.table_name, table_list->qual[table_list->count
   ].column_name = uic.column_name, table_list->qual[table_list->count].index_name = ui.index_name,
   table_list->qual[table_list->count].uniqueness = ui.uniqueness
  WITH nocounter
 ;end select
 SET trace symbol mark
 CALL echo("Setting defining_attribute_ind to one for columns with unique indexes...")
 FOR (i = 1 TO table_list->count)
   SET n = (n+ 1)
   SET buff[n] = " update into dm_columns_doc dcd "
   SET n = (n+ 1)
   SET buff[n] = " set dcd.defining_attribute_ind = 1 "
   SET n = (n+ 1)
   SET buff[n] = concat(' where dcd.table_name = "',table_list->qual[i].table_name,'"')
   SET n = (n+ 1)
   SET buff[n] = concat(' and dcd.column_name = "',table_list->qual[i].column_name,'"',"go")
   FOR (j = 1 TO n)
     CALL parser(buff[j])
   ENDFOR
   SET n = 0
   SET trace = symbol
 ENDFOR
 COMMIT
END GO
