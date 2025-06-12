CREATE PROGRAM da_get_grpcodes:dba
 PROMPT
  "Action" = "",
  "PersonId" = 0
  WITH action, personid
 EXECUTE ccl_prompt_api_dataset "autoset", "advapi", "DATASET"
 DECLARE persnlid = f8
 SET persnlid =  $PERSONID
 IF (( $ACTION="A"))
  SELECT INTO "nl:"
   cv.cdf_meaning, cv.display, cv.code_value
   FROM code_value cv,
    da_group_user_reltn g,
    dummyt d
   PLAN (cv
    WHERE cv.code_set=4002360)
    JOIN (d)
    JOIN (g
    WHERE g.prsnl_id=persnlid
     AND cv.code_value=g.group_cd)
   ORDER BY cv.cdf_meaning, cv.display_key
   HEAD REPORT
    stat = makedataset(100)
   DETAIL
    stat = writerecord(0)
   FOOT REPORT
    stat = closedataset(0)
   WITH outerjoin = d, dontexist, nocounter,
    separator = " ", format, reporthelp
  ;end select
 ELSEIF (( $ACTION="D"))
  SELECT INTO "nl:"
   cdf_meaning = uar_get_code_meaning(d.group_cd), code_display = uar_get_code_display(d.group_cd),
   code_value = d.group_cd
   FROM da_group_user_reltn d
   PLAN (d
    WHERE d.prsnl_id=persnlid)
   ORDER BY cdf_meaning, cnvtupper(uar_get_code_display(d.group_cd))
   HEAD REPORT
    stat = makedataset(100)
   DETAIL
    stat = writerecord(0)
   FOOT REPORT
    stat = closedataset(0)
   WITH nocounter, separator = " ", format,
    reporthelp
  ;end select
 ENDIF
END GO
