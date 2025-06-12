CREATE PROGRAM codecache_getsetlist:dba
 RECORD reply(
   1 codeset_list[*]
     2 codeset = i4
 )
 SET list_cap = 0
 SET list_size = 0
 SELECT INTO "nl:"
  c.code_set
  FROM code_value_set c
  DETAIL
   IF (list_size=list_cap)
    IF (list_cap=0)
     list_cap = 16
    ELSE
     list_cap = (list_cap * 2)
    ENDIF
    stat = alterlist(reply->codeset_list,list_cap)
   ENDIF
   list_size = (list_size+ 1), reply->codeset_list[list_size].codeset = c.code_set
  WITH nocounter
 ;end select
 IF (list_size < list_cap)
  SET stat = alterlist(reply->codeset_list,list_size)
 ENDIF
END GO
