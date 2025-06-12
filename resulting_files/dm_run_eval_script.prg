CREATE PROGRAM dm_run_eval_script
 PROMPT
  "enter the number for the date: " = 73929
 SET script_count = 0
 FREE RECORD dm_script_names
 RECORD dm_script_names(
   1 data[*]
     2 script_names = vc
 )
 SELECT INTO "NL:"
  p.datestamp"mm/dd/yyyy;;d", test_date = cnvtstring(p.datestamp)
  FROM dprotect p
  WHERE p.object="P"
   AND p.group=0
   AND (p.datestamp >=  $1)
  DETAIL
   script_count = (script_count+ 1)
   IF (mod(script_count,50)=1)
    test_x = alterlist(dm_script_names->data,(script_count+ 50))
   ENDIF
   dm_script_names->data[script_count].script_names = p.object_name
  WITH nocounter
 ;end select
 SET test_x = alterlist(dm_script_names->data,script_count)
 CALL echo(build("scripts to score:",script_count))
 CALL echorecord(dm_script_names)
 IF (script_count > 0)
  SET dale_x = 1
  WHILE (dale_x <= script_count)
    CALL echo("----------------------------------")
    CALL echo(build("script :",dale_x,"of",script_count))
    CALL echo("----------------------------------")
    EXECUTE dm_eval_script_score dm_script_names->data[dale_x].script_names
    SET dale_x = (dale_x+ 1)
  ENDWHILE
 ENDIF
END GO
