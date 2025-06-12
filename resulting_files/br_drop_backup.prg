CREATE PROGRAM br_drop_backup
 RECORD tablestodrop(
   1 tables[*]
     2 tbl_name = vc
 )
 DECLARE drop_backup_table(temp_tbl_pattern=vc) = null
 CALL drop_backup_table(request->temp_tbl_pattern)
 SUBROUTINE drop_backup_table(temp_tbl_pattern)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM user_tables ut
    WHERE ut.table_name=patstring(temp_tbl_pattern)
    DETAIL
     cnt = (cnt+ 1),
     CALL echo(ut.table_name), stat = alterlist(tablestodrop->tables,cnt),
     tablestodrop->tables[cnt].tbl_name = ut.table_name
    WITH nocounter
   ;end select
   FOR (i = 1 TO cnt)
     CALL parser(concat("rdb drop table ",tablestodrop->tables[i].tbl_name," go"))
   ENDFOR
   COMMIT
 END ;Subroutine
END GO
