CREATE PROGRAM dm_remove_db_links:dba
 SET parser_buf[100] = fillstring(132," ")
 SET cnt = 0
 SET z = fillstring(6," ")
 SELECT INTO "nl:"
  FROM all_db_links a
  DETAIL
   cnt = (cnt+ 1), len = (findstring(".",a.db_link) - 1)
   IF (a.owner="PUBLIC")
    z = "PUBLIC"
   ELSE
    z = " "
   ENDIF
   parser_buf[cnt] = concat("rdb drop ",z," database link ",substring(1,len,a.db_link)," go")
  WITH nocounter
 ;end select
 FOR (x = 1 TO cnt)
   CALL parser(parser_buf[x])
 ENDFOR
END GO
