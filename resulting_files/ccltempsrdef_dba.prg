CREATE PROGRAM ccltempsrdef:dba
 PROMPT
  "Enter MINE/CRT/printer/file: " = mine,
  "ENTER TABLE#:                " = 8
 SELECT INTO  $1
  s.*, s2.*, format = concat(trim(s2.field_format),cnvtstring(s2.field_length,5))
  FROM sr0000_1 s,
   sr0000_2 s2
  WHERE (s.tbl_nbr= $2)
   AND s2.field_length > 0
  HEAD s.tbl_nbr
   "DROP DDLRECORD SRT", s.tbl_nbr"####;RP0", "_RECORD FROM DATABASE SR WITH DEPS_DELETED GO",
   row + 1, "CREATE DDLRECORD SRT", s.tbl_nbr"####;RP0",
   "_RECORD FROM DATABASE SR", row + 1, "TABLE SRT",
   s.tbl_nbr"####;RP0", "_1", row + 1,
   "  1 KEY1", row + 1, "    2 USER             = UN2",
   row + 1, "    2 TABLE_NBR        = AUN4", row + 1,
   "    2 SRKEY            = C30    CCL(SRKEY)", row + 1, "  1 FILLER             = C3",
   row + 1, "  1 DATA", row + 1
  DETAIL
   buffer = fillstring(19," "), num = 19, len = 19
   WHILE (num >= 1
    AND len=19)
    IF (substring(num,1,s2.field_desc) != " ")
     len = num, num = 1
    ENDIF
    ,num = (num - 1)
   ENDWHILE
   num = 1
   WHILE (num <= len)
     chr = cnvtupper(substring(num,1,s2.field_desc))
     IF (((chr BETWEEN "A" AND "Z") OR (chr BETWEEN "0" AND "9")) )
      pos = movestring(chr,1,buffer,num,1)
     ELSE
      pos = movestring("_",1,buffer,num,1)
     ENDIF
     num = (num+ 1)
   ENDWHILE
   "    2 ", buffer, " = ",
   format, "   CCL(", buffer,
   ")", row + 1
  FOOT  s.tbl_nbr
   "END TABLE SRT", s.tbl_nbr"####;RP0", "_1",
   row + 1, "WITH ACCESS_CODE = ", s.tbl_nbr,
   " GO", row + 1
  WITH format = variable, maxcol = 70
 ;end select
END GO
