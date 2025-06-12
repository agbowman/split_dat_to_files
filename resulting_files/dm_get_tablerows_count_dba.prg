CREATE PROGRAM dm_get_tablerows_count:dba
 SET db_link = cnvtupper( $1)
 FREE SET table_list
 RECORD table_list(
   1 table_name[*]
     2 tname = vc
     2 rowcount = f8
     2 rowcount2 = f8
   1 table_count = i4
 )
 SET stat = alterlist(table_list->table_name,10)
 SET table_list->table_count = 0
 SELECT INTO "nl:"
  d.table_name
  FROM dm_tables_doc d
  WHERE d.reference_ind=1
  ORDER BY d.table_name
  DETAIL
   table_list->table_count = (table_list->table_count+ 1)
   IF (mod(table_list->table_count,10)=1
    AND (table_list->table_count != 1))
    stat = alterlist(table_list->table_name,(table_list->table_count+ 9))
   ENDIF
   table_list->table_name[table_list->table_count].tname = d.table_name
  WITH nocounter
 ;end select
 SET cnt = 0
 FOR (cnt = 1 TO table_list->table_count)
   CALL parser('select into "nl:"  xxx = count(*) ')
   CALL parser(concat("from ",table_list->table_name[cnt].tname))
   CALL parser(" detail table_list->table_name[cnt]->rowcount = xxx")
   CALL parser(" with counter go")
   CALL parser(concat("rdb drop public synonym temp_",trim(table_list->table_name[cnt].tname)," go"))
   CALL parser(concat("drop table temp_",trim(table_list->table_name[cnt].tname)," go"))
   CALL parser(" commit go")
   CALL parser(concat("rdb create public synonym temp_",trim(table_list->table_name[cnt].tname)))
   CALL parser(concat("for ",trim(table_list->table_name[cnt].tname),"@",db_link," go"))
   SET tb1 = trim(table_list->table_name[cnt].tname)
   EXECUTE oragen3_temp value(tb1)
   CALL parser(" commit go")
   CALL parser('select into "nl:" yyy = count(*) ')
   CALL parser(concat("from temp_",trim(table_list->table_name[cnt].tname)," C "))
   CALL parser(" detail table_list->table_name[cnt]->rowcount2 = yyy")
   CALL parser(" with counter go")
   CALL parser(concat("drop table temp_",trim(table_list->table_name[cnt].tname)," go"))
   CALL parser(concat("rdb drop public synonym temp_",trim(table_list->table_name[cnt].tname)," go"))
   CALL parser(" commit go")
 ENDFOR
 SELECT INTO dm_get_tablerows_count
  *
  FROM dual
  HEAD REPORT
   page_nbr = 0, cnt = 0, line = fillstring(78,"=")
  HEAD PAGE
   col 0, "Page:", page_nbr = (page_nbr+ 1),
   page_nbr"####", col 60, "Date:",
   curdate"dd-mmm-yyyy;;d", row + 1, col 0,
   "Table Name", col 26, "Rows in Current Database",
   col 55, "Rows in Remote Database", row + 1,
   line, row + 1
  DETAIL
   FOR (cnt = 1 TO table_list->table_count)
     table_list->table_name[cnt].tname, col 30, table_list->table_name[cnt].rowcount,
     col 50, table_list->table_name[cnt].rowcount2, row + 1
   ENDFOR
  WITH format = pcformat, noheading, nocounter
 ;end select
END GO
