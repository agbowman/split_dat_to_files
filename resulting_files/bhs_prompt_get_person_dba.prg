CREATE PROGRAM bhs_prompt_get_person:dba
 PROMPT
  "Last Name" = "",
  "First Name" = ""
  WITH last_name, first_name
 EXECUTE ccl_prompt_api_dataset "dataset"
 DECLARE lname = vc
 DECLARE fname = vc
 SET lname = cnvtupper(concat(trim( $LAST_NAME,3),"*"))
 SET fname = cnvtupper(concat(trim( $FIRST_NAME,3),"*"))
 SELECT INTO "nl:"
  p.person_id, pat_name = substring(1,35,p.name_full_formatted)
  FROM person p
  PLAN (p
   WHERE p.name_last_key=patstring(lname)
    AND p.name_first_key=patstring(fname)
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  ORDER BY p.name_full_formatted
  HEAD REPORT
   pcnt = 0, stat = makedataset(10), vpid = addrealfield("PID","Person ID:",0),
   vname = addstringfield("Name","Name:",1,35)
  DETAIL
   pcnt = getnextrecord(0), stat = setrealfield(pcnt,vpid,p.person_id), stat = setstringfield(pcnt,
    vname,pat_name)
  FOOT REPORT
   stat = closedataset(0)
  WITH check.maxrec = 100
 ;end select
#exit_prg
END GO
