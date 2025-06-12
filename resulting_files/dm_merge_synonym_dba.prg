CREATE PROGRAM dm_merge_synonym:dba
 PROMPT
  'Enter , IN QUOTES, the connect string for the synonyms (e.g. "admin1"): ' =  $1
 FREE SET robjects
 RECORD robjects(
   1 qual[*]
     2 object_name = c50
     2 include_connect_string = i4
 )
 SET count1 = 0
 SET count1 = (count1+ 1)
 SET stat = alterlist(robjects->qual,count1)
 SET robjects->qual[count1].object_name = trim("DM_REF_DOMAIN")
 SET robjects->qual[count1].include_connect_string = 1
 SET count1 = (count1+ 1)
 SET stat = alterlist(robjects->qual,count1)
 SET robjects->qual[count1].object_name = trim("DM_REF_DOMAIN_GROUP")
 SET robjects->qual[count1].include_connect_string = 1
 SET count1 = (count1+ 1)
 SET stat = alterlist(robjects->qual,count1)
 SET robjects->qual[count1].object_name = trim("DM_REF_DOMAIN_R")
 SET robjects->qual[count1].include_connect_string = 1
 SET count1 = (count1+ 1)
 SET stat = alterlist(robjects->qual,count1)
 SET robjects->qual[count1].object_name = trim("DM_REF_FILTER")
 SET robjects->qual[count1].include_connect_string = 1
 FOR (x = 1 TO count1)
   CALL parser(concat("rdb drop public synonym ",trim(robjects->qual[x].object_name)," go"))
   CALL parser(concat("rdb create public synonym ",trim(robjects->qual[x].object_name)))
   IF ((robjects->qual[x].include_connect_string=1))
    CALL parser(concat("for ",trim(robjects->qual[x].object_name),"@", $1," go"))
   ELSE
    CALL parser(concat("for ",trim(robjects->qual[x].object_name)," go"))
   ENDIF
 ENDFOR
END GO
