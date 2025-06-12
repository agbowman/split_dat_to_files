CREATE PROGRAM dm2_get_sql_id_list
 PROMPT
  "Enter Program Name:" = "",
  "Search Type" = ""
  WITH pname, searchtype
 DECLARE script_var = vc WITH constant(concat("*", $PNAME,"*"))
 EXECUTE ccl_prompt_api_dataset "autoset"
 IF (( $SEARCHTYPE="S"))
  SELECT INTO "nl:"
   v.sql_id, v.sql_text
   FROM v$sql v
   WHERE (v.sql_id= $PNAME)
    AND v.sql_text != "*V$SQL*"
   HEAD REPORT
    stat = makedataset(100)
   DETAIL
    stat = writerecord(0)
   FOOT REPORT
    stat = closedataset(0)
   WITH maxrec = 100, nocounter, reporthelp
  ;end select
 ELSE
  SELECT INTO "nl:"
   v.sql_id, v.sql_text
   FROM v$sql v
   WHERE v.sql_text=patstring(script_var)
    AND v.sql_text != "*V$SQL*"
   HEAD REPORT
    stat = makedataset(100)
   DETAIL
    stat = writerecord(0)
   FOOT REPORT
    stat = closedataset(0)
   WITH maxrec = 100, nocounter, reporthelp
  ;end select
 ENDIF
 IF (curqual=0)
  SELECT INTO "nl:"
   id = 0, text = concat("No queries found that contain ", $PNAME," in the comment")
   FROM dummyt
   HEAD REPORT
    stat = makedataset(100)
   DETAIL
    stat = writerecord(0)
   FOOT REPORT
    stat = closedataset(0)
   WITH maxrec = 100, nocounter, reporthelp
  ;end select
 ENDIF
END GO
