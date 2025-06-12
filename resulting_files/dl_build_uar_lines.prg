CREATE PROGRAM dl_build_uar_lines
 SELECT
  x.code_value, display_key = cnvtlower(x.display_key), description = cnvtlower(x.description)
  FROM code_value x
  WHERE x.code_set=71
   AND x.code_value IN (679656, 679657, 679677, 679683, 679659,
  679662)
  HEAD REPORT
   q = char(34), rt = char(13), cnt = 0,
   ln_cd[99] = fillstring(99," ")
  DETAIL
   ln = concat("declare ",build(display_key,"_cd")," = f8 with public, constant"), ln, row + 1,
   ln = concat("     (uar_get_code_by(",q,"DISPLAYKEY",q,",72,",
    build(q,x.display_key,q,"))")), ln, row + 1,
   cnt = (cnt+ 1), ln_cd[cnt] = trim(build(display_key,"_cd"))
  FOOT REPORT
   FOR (i = 1 TO cnt)
     z9 = build(ln_cd[i],","), z9, row + 1
   ENDFOR
   FOR (i = 1 TO cnt)
     z = concat("       elseif (c.event_cd = ",build(ln_cd[i],")  "," ",(cnt - (i - 1)))), z, row + 1
   ENDFOR
  WITH noforms, noformfeed, format = variable,
   maxcol = 999
 ;end select
END GO
