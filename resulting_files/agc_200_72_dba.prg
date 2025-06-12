CREATE PROGRAM agc_200_72:dba
 SELECT
  c200_code_value = c200.code_value, c200_display = c200.display, c200_alias = decode(cva200.seq,
   substring(1,25,cva200.alias)," "),
  c72_code_value = c72.code_value, c72_display = substring(1,25,c72.display), c72_alias = substring(1,
   25,cva72.alias)
  FROM code_value c200,
   code_value_alias cva200,
   code_value c72,
   code_value_alias cva72
  PLAN (c200
   WHERE c200.code_set=200
    AND c200.active_ind=1)
   JOIN (cva200
   WHERE cva200.code_value=outerjoin(c200.code_value)
    AND cva200.code_set=outerjoin(200))
   JOIN (c72
   WHERE c72.display_key=outerjoin(c200.display_key)
    AND c72.code_set=outerjoin(72)
    AND c72.active_ind=outerjoin(1))
   JOIN (cva72
   WHERE cva72.code_value=outerjoin(c72.code_value)
    AND cva72.code_set=outerjoin(72))
  ORDER BY c200.display
  HEAD REPORT
   disp_header = concat("Dif",char(124),"200_cd",char(124),"200_disp",
    char(124),"200_alias",char(124),"72_cd",char(124),
    "72_disp",char(124),"72_alias",char(124)), col 0, disp_header,
   row + 1
  DETAIL
   IF (cva72.alias != cva200.alias)
    disp_line = concat(char(42),char(124),trim(cnvtstring(c200_code_value)),char(124),trim(
      c200_display),
     char(124),trim(c200_alias),char(124),trim(cnvtstring(c72_code_value)),char(124),
     trim(c72_display),char(124),trim(c72_alias),char(124))
   ELSE
    disp_line = concat(char(124),trim(cnvtstring(c200_code_value)),char(124),trim(c200_display),char(
      124),
     trim(c200_alias),char(124),trim(cnvtstring(c72_code_value)),char(124),trim(c72_display),
     char(124),trim(c72_alias),char(124))
   ENDIF
   col 1, disp_line, row + 1
  WITH formfeed = none, maxcol = 1000
 ;end select
END GO
