CREATE PROGRAM dl_build_uar_lines_dta
 SELECT
  x.code_value, display_key = cnvtlower(x.display_key), description = cnvtlower(x.description)
  FROM discrete_task_assay dta,
   code_value x
  WHERE dta.task_assay_cd IN (736101, 680299, 723257, 723267, 723277,
  680237, 753794, 726236, 728931, 732703,
  727033, 724838, 880049, 879883, 737662,
  879869, 727419, 737606, 727442, 727349,
  734929, 746129, 786712, 734471, 881223,
  900212, 734052, 905738, 725555, 881217,
  881220, 723480, 803472, 879124, 925418,
  742821, 726115, 807265, 909319, 881311,
  881241, 880790, 881314, 881323, 881317,
  881320, 881326, 881329, 881332, 881335,
  725718, 726029, 734579, 726566, 726569,
  747748, 747738, 725770, 729522, 726832,
  791609, 729041, 726242, 726579, 726685,
  747779, 747789, 726032, 725779, 725298,
  728636, 725361, 725537)
   AND dta.event_cd=x.code_value
   AND x.code_set=72
  HEAD REPORT
   q = char(34), rt = char(13), cnt = 0,
   ln_cd[99] = fillstring(99," ")
  DETAIL
   cnt = (cnt+ 1), cnt, dta.task_assay_cd,
   x.code_value, row + 1, ln = concat("declare ",build(display_key,"_cd"),
    " = f8 with public, constant"),
   ln = concat("     (uar_get_code_by(",q,"displaykey",q,",72,",
    build(q,x.display_key,q,"))")), ln_cd[cnt] = trim(build(display_key,"_cd"))
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
