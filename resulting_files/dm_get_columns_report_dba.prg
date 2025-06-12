CREATE PROGRAM dm_get_columns_report:dba
 SELECT INTO "column.dat"
  t.table_name, t.definition, f.column_name,
  f.definition, f.code_set, f.sequence_name
  FROM dm_tables_doc t,
   dm_columns_doc f,
   user_tables ut,
   user_tab_columns uc
  PLAN (ut
   WHERE (ut.table_name=request->table_name))
   JOIN (uc
   WHERE ut.table_name=uc.table_name)
   JOIN (t
   WHERE ut.table_name=t.table_name)
   JOIN (f
   WHERE ut.table_name=f.table_name
    AND uc.column_name=f.column_name)
  ORDER BY t.table_name, f.column_name
  HEAD REPORT
   desc = fillstring(100," "), len = 0, beg = 1,
   cnt = 0, info = fillstring(100," ")
  HEAD PAGE
   col 0, " "
  HEAD t.table_name
   desc = fillstring(90," "), len = 0, beg = 1,
   cnt = 0, col 0, t.table_name,
   row + 1, len = size(trim(t.definition),1)
   WHILE (beg <= len)
     desc = substring(beg,90,t.definition), flag = 0, end_sp = 91
     WHILE (flag=0)
      end_sp = (end_sp - 1),
      IF (substring(end_sp,1,desc)=" ")
       flag = 1, desc = substring(1,end_sp,desc)
      ENDIF
     ENDWHILE
     beg = (beg+ end_sp), col 30, desc,
     row + 1
   ENDWHILE
   row + 2
  DETAIL
   desc = fillstring(90," "), len = 0, beg = 1,
   cnt = 0, col 0, f.column_name
   IF (f.column_name="*_CD")
    info = build("CODE SET: ",f.code_set), col 30, info,
    row + 1
   ELSEIF (f.column_name="*_ID"
    AND f.sequence_name > " ")
    info = build("SEQUENCE NAME: ",f.sequence_name), col 30, info,
    row + 1
   ENDIF
   len = size(trim(f.definition),1)
   WHILE (beg <= len)
     desc = substring(beg,90,f.definition), flag = 0, end_sp = 91
     WHILE (flag=0)
      end_sp = (end_sp - 1),
      IF (substring(end_sp,1,desc)=" ")
       flag = 1, desc = substring(1,end_sp,desc)
      ENDIF
     ENDWHILE
     beg = (beg+ end_sp), col 30, desc,
     row + 1
   ENDWHILE
  FOOT  t.table_name
   row + 3
  WITH counter
 ;end select
END GO
