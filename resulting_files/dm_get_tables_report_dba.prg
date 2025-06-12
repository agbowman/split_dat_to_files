CREATE PROGRAM dm_get_tables_report:dba
 SELECT INTO "table.dat"
  t.table_name, t.definition, t.data_model_section
  FROM dm_tables_doc_local t
  PLAN (t
   WHERE  NOT (t.data_model_section=null)
    AND (t.data_model_section=request->data_model_section))
  ORDER BY t.data_model_section, t.table_name
  HEAD REPORT
   desc = fillstring(100," "), len = 0, beg = 1,
   cnt = 0, info = fillstring(100," ")
  HEAD PAGE
   col 0, "PAGE:", col + 1,
   curpage"###", row + 2
  HEAD t.data_model_section
   sect =
   IF (t.data_model_section > " ") concat(trim(t.data_model_section)," Model")
   ELSE "NO SECTION LISTED"
   ENDIF
   , col 0, sect,
   row + 3
  HEAD t.table_name
   desc = fillstring(90," "), len = 0, beg = 1,
   cnt = 0, col 0, t.table_name,
   len = size(trim(t.definition),1)
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
  FOOT  t.table_name
   row + 2
  FOOT  t.data_model_section
   col 0, "TOTAL TABLES:", col + 1,
   count(t.table_name), BREAK
  FOOT REPORT
   col 0, "TOTAL TABLES:", col + 1,
   count(t.table_name)
  WITH counter
 ;end select
END GO
