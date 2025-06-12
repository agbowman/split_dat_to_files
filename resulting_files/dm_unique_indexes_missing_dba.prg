CREATE PROGRAM dm_unique_indexes_missing:dba
 FREE SET table_list
 RECORD table_list(
   1 table_name[*]
     2 tname = c32
     2 column_count = i4
     2 index_found = i4
     2 column_name[25]
       3 cname = c32
   1 table_count = i4
 )
 SET stat = alterlist(table_list->table_name,10)
 SET table_list->table_count = 0
 SELECT INTO "nl:"
  dcd.table_name, dcd.column_name
  FROM dm_columns_doc dcd
  WHERE unique_ident_ind=1
  ORDER BY dcd.table_name
  HEAD dcd.table_name
   table_list->table_count = (table_list->table_count+ 1), tcount = table_list->table_count
   IF (mod(table_list->table_count,10)=1
    AND (table_list->table_count != 1))
    stat = alterlist(table_list->table_name,(table_list->table_count+ 9))
   ENDIF
   table_list->table_name[tcount].tname = dcd.table_name, table_list->table_name[tcount].column_count
    = 0, ccount = 0
  DETAIL
   tcount = table_list->table_count, table_list->table_name[tcount].column_count = (table_list->
   table_name[tcount].column_count+ 1), ccount = table_list->table_name[tcount].column_count,
   table_list->table_name[tcount].column_name[ccount].cname = dcd.column_name
  WITH nocounter
 ;end select
 FREE SET index_list
 RECORD index_list(
   1 index_name[*]
     2 tname = c32
     2 iname = c32
     2 column_count = i4
     2 column_name[25]
       3 cname = c32
   1 index_count = i4
 )
 SET stat = alterlist(index_list->index_name,10)
 SET index_list->index_count = 0
 SELECT INTO "nl:"
  ui.table_name, ui.index_name, uic.column_name
  FROM user_indexes ui,
   user_ind_columns uic
  WHERE ui.uniqueness="UNIQUE"
   AND ui.table_name=uic.table_name
   AND ui.index_name=uic.index_name
  ORDER BY ui.table_name, ui.index_name, uic.column_name
  HEAD ui.index_name
   index_list->index_count = (index_list->index_count+ 1), tcount = index_list->index_count
   IF (mod(index_list->index_count,10)=1
    AND (index_list->index_count != 1))
    stat = alterlist(index_list->index_name,(index_list->index_count+ 9))
   ENDIF
   index_list->index_name[tcount].iname = ui.index_name, index_list->index_name[tcount].tname = ui
   .table_name, index_list->index_name[tcount].column_count = 0,
   ccount = 0
  DETAIL
   index_list->index_name[tcount].column_count = (index_list->index_name[tcount].column_count+ 1),
   ccount = index_list->index_name[tcount].column_count, index_list->index_name[tcount].column_name[
   ccount].cname = uic.column_name
  WITH nocounter
 ;end select
 SET i = 0
 SET j = 0
 SET column_count = 0.0
 SET stmt = fillstring(255," ")
 FOR (i = 1 TO table_list->table_count)
  SET table_list->table_name[i].index_found = 0
  FOR (j = 1 TO index_list->index_count)
    IF ((table_list->table_name[i].tname=index_list->index_name[j].tname)
     AND (table_list->table_name[i].column_count=index_list->index_name[j].column_count))
     SET match = 1
     FOR (k = 1 TO index_list->index_name[i].column_count)
       IF ((table_list->table_name[i].column_name[k].cname != index_list->index_name[j].column_name[k
       ].cname))
        SET match = 0
       ENDIF
     ENDFOR
     IF (match=1)
      SET table_list->table_name[i].index_found = 1
     ENDIF
    ENDIF
  ENDFOR
 ENDFOR
 SELECT
  d.*
  FROM dual d
  DETAIL
   FOR (i = 1 TO table_list->table_count)
     IF ((table_list->table_name[i].index_found=0))
      table_list->table_name[i].tname, row + 1
     ENDIF
   ENDFOR
  WITH nocounter
 ;end select
END GO
