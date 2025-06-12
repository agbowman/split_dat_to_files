CREATE PROGRAM dm_columns_doc_fix:dba
 FREE SET rows
 RECORD rows(
   1 list[*]
     2 table_name = vc
     2 column_name = vc
   1 count = i4
 )
 SET rows->count = 0
 SET stat = alterlist(rows->list,10)
 SET buff[20] = fillstring(132," ")
 SET i = 0
 SET j = 0
 SET n = 0
 SELECT INTO "nl:"
  dcd.table_name, dcd.column_name, dcd.root_entity_name,
  dcd.root_entity_attr, dcd.parent_entity_col
  FROM dm_columns_doc dcd
  WHERE dcd.root_entity_name > " "
   AND dcd.root_entity_attr > " "
   AND dcd.parent_entity_col > " "
  DETAIL
   rows->count = (rows->count+ 1)
   IF (mod(rows->count,10)=1)
    stat = alterlist(rows->list,(rows->count+ 9))
   ENDIF
   rows->list[rows->count].table_name = dcd.table_name, rows->list[rows->count].column_name = dcd
   .column_name
  WITH nocounter
 ;end select
 FOR (i = 1 TO rows->count)
   SET j = (j+ 1)
   SET buff[j] = "update into dm_columns_doc dcd "
   SET j = (j+ 1)
   SET buff[j] = 'set parent_entity_col = " " '
   SET j = (j+ 1)
   SET buff[j] = concat('where table_name = "',rows->list[i].table_name,'"')
   SET j = (j+ 1)
   SET buff[j] = concat('and column_name = "',rows->list[i].column_name,'"'," go")
   FOR (n = 1 TO j)
     CALL parser(buff[n])
   ENDFOR
   SET j = 0
 ENDFOR
 FOR (i = 1 TO rows->count)
   IF ((rows->list[i].table_name IN ("TRANS_TRANS_RELTN", "GL_INTERFACE_ALIAS")))
    SET j = (j+ 1)
    SET buff[j] = "delete from dm_columns_doc dcd where dcd.table_name = "
    SET j = (j+ 1)
    SET buff[j] = concat('"',rows->list[i].table_name,'" ')
    SET j = (j+ 1)
    SET buff[j] = " go"
    FOR (n = 1 TO j)
      CALL parser(buff[n])
    ENDFOR
    SET j = 0
    COMMIT
   ENDIF
 ENDFOR
END GO
