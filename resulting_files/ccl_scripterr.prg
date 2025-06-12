CREATE PROGRAM ccl_scripterr
 PROMPT
  "Output to File/Printer/MINE:" = "MINE",
  "Server Number (51):" = 51,
  "Sort: (T)ime (P)rog (C)pu (E)la (N)one - (T)?" = "P",
  "Option: (E)rror (C)ost (A)ll - (E)" = "E",
  "Program Name (*):" = "*",
  "Number of Instances (10):" = 10
  WITH outdev, _servernumber, _sort,
  _opttype, _progname, _instances
 DECLARE cost_fname = c50 WITH protect
 DECLARE temp_fname = c50 WITH protect
 DECLARE server_id = i4 WITH protect
 DECLARE p_sort = vc WITH protect
 DECLARE p_option = vc WITH protect
 DECLARE p_program = vc WITH protect
 DECLARE p_instance = i4 WITH protect
 DECLARE stat = i4 WITH protect
 DECLARE errcount = i4 WITH protect
 DECLARE logfilecount = i4 WITH protect
 SET server_id =  $_SERVERNUMBER
 SET p_sort =  $_SORT
 SET p_option =  $_OPTTYPE
 SET p_program =  $_PROGNAME
 SET p_instance =  $_INSTANCES
 SET stat = 0
 SET errcount = 0
 SET logfilecount = 0
 FREE RECORD log_request
 RECORD log_request(
   1 servernum = i2
   1 hostname = vc
   1 logtype = vc
 ) WITH protect
 FREE RECORD log_reply
 RECORD log_reply(
   1 data[*]
     2 buffer = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 SET log_request->servernum = server_id
 SET log_request->hostname = ""
 SET log_request->logtype = "RTL"
 EXECUTE ccl_get_rtlfiles  WITH replace(request,log_request), replace(reply,log_reply)
 SET logfilecount = size(log_reply->data,5)
 SET cost_fname = concat("ccl_err",format(curtime2,"hhmmss;2;m"),".log")
 SET append_mode = 0
 FOR (num = 1 TO logfilecount)
   IF (num <= p_instance)
    SET temp_fname = substring(1,20,log_reply->data[num].buffer)
    CALL echo(concat("...Instance= ",build(num),", searching for file= ",temp_fname))
    IF (findfile(trim(temp_fname)))
     DEFINE rtl trim(temp_fname)
     SELECT
      IF (p_option="A"
       AND append_mode=0)
       WHERE r.line IN ("* Cpu *", "CCL LOG*", "CCL CACHE*", "%CCL-*", "%SYS-*",
       "* Prcname=*", "DISCERN EXPLORER*")
       WITH counter, noheading
      ELSEIF (p_option="A"
       AND append_mode=1)
       WHERE r.line IN ("* Cpu *", "CCL LOG*", "CCL CACHE*", "%CCL-*", "%SYS-*",
       "* Prcname=*", "DISCERN EXPLORER*")
       WITH counter, append, noheading
      ELSEIF (p_option="E"
       AND append_mode=0)
       WHERE r.line IN ("%CCL-*", "%SYS-*", "* Prcname=*")
       WITH counter, noheading
      ELSEIF (p_option="E"
       AND append_mode=1)
       WHERE r.line IN ("%CCL-*", "%SYS-*", "* Prcname=*")
       WITH counter, append, noheading
      ELSEIF (p_option="C"
       AND append_mode=0)
       WHERE r.line IN ("* Cpu *", "* Prcname=*")
       WITH counter, noheading
      ELSEIF (p_option="C"
       AND append_mode=1)
       WHERE r.line IN ("* Cpu *", "* Prcname=*")
       WITH counter, append, noheading
      ELSE
      ENDIF
      INTO trim(cost_fname)
      line = concat(trim(temp_fname),substring(1,110,r.line))
      FROM rtlt r
      WITH counter, noheading
     ;end select
     CALL echo(concat("...file= ",temp_fname,", qual= ",build(curqual)))
     FREE DEFINE rtl
     SET append_mode = 1
    ENDIF
   ENDIF
 ENDFOR
 FREE DEFINE rtl
 DEFINE rtl trim(cost_fname)
 SELECT
  IF (p_sort="T")
   ORDER BY logname, substring(21,12,r.line)
  ELSEIF (p_sort="P")
   ORDER BY logname, substring(34,40,r.line), substring(1,12,r.line)
  ELSEIF (p_sort="C")
   ORDER BY logname, substring(77,5,r.line) DESC, substring(1,12,r.line)
  ELSEIF (p_sort="E")
   ORDER BY logname, substring(86,5,r.line) DESC, substring(1,12,r.line)
  ELSE
  ENDIF
  INTO  $OUTDEV
  logname = substring(1,20,r.line), line = substring(21,(size(r.line,1) - 20),r.line), costdesc =
  substring(64,4,r.line),
  cpu = cnvtreal(substring(77,5,r.line)), cst = cnvtreal(substring(68,5,r.line)), ela = cnvtreal(
   substring(86,6,r.line))
  FROM rtlt r
  WHERE r.line=patstring(concat("*",trim(p_program),"*"))
   AND r.line != " "
  HEAD REPORT
   col 2, "Server log name", col 37,
   "Script errors listed by server log instance", row + 2
  HEAD logname
   logname, row + 1
  DETAIL
   errcount += 1, col 5, line,
   row + 1
  FOOT REPORT
   IF (errcount=0)
    "No errors found", row + 3
   ENDIF
   IF (cnvtupper(p_option) != "E")
    "==========================================================================================================================",
    row + 1, " Total Number of Primary Scripts= ",
    count(cst
    WHERE costdesc="Cost")"############", row + 1, " Cost    Sum= ",
    sum(cst
    WHERE costdesc="Cost")"#########.###", " Avg= ", avg(cst
    WHERE costdesc="Cost")"#########.###",
    " Min= ", min(cst
    WHERE costdesc="Cost")"#########.###", " Max= ",
    max(cst
    WHERE costdesc="Cost")"#########.###", row + 1, " Cpu Sec Sum= ",
    sum(cpu
    WHERE costdesc="Cost")"#########.###", " Avg= ", avg(cpu
    WHERE costdesc="Cost")"#########.###",
    " Min= ", min(cpu
    WHERE costdesc="Cost")"#########.###", " Max= ",
    max(cpu
    WHERE costdesc="Cost")"#########.###", row + 1, " Ela Sec Sum= ",
    sum(ela
    WHERE costdesc="Cost")"#########.###", " Avg= ", avg(ela
    WHERE costdesc="Cost")"#########.###",
    " Min= ", min(ela
    WHERE costdesc="Cost")"#########.###", " Max= ",
    max(ela
    WHERE costdesc="Cost")"#########.###", row + 1
   ENDIF
  WITH counter, maxcol = 140, noformfeed,
   maxrow = 1, nullreport
 ;end select
 FREE DEFINE rtl
 SET stat = remove(cost_fname)
END GO
