CREATE PROGRAM dl_create_uar:dba
 PROMPT
  "PRINTER " = "MINE"
 SELECT INTO  $1
  x.code_value, display_key = cnvtlower(x.display_key), description = cnvtlower(x.description)
  FROM code_value x
  WHERE x.code_set=88
  HEAD REPORT
   q = char(34), rt = char(13), lntext[999] = fillstring(99," "),
   cnt = 0
  DETAIL
   ln = concat("declare ",build(display_key,"_cd")," = f8 with public, constant"), ln, row + 1,
   ln = concat("     (uar_get_code_by(",q,"DISPLAYKEY",q,",88,",
    build(q,x.display_key,q,"))")), ln, row + 1,
   cnt = (cnt+ 1), lntext[cnt] = build(display_key,"_cd,")
  FOOT REPORT
   row + 2
   WHILE (cnt > 0)
     lntext[cnt], row + 1, cnt = (cnt - 1)
   ENDWHILE
  WITH noforms, format = variable, noformfeed
 ;end select
END GO
