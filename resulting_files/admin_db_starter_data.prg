CREATE PROGRAM admin_db_starter_data
 PROMPT
  "Output to File/Printer/MINE " = mine,
  "Codeset # : " = 0
 SET maxsecs = 0
 IF (isodbc)
  SET maxsecs = 10
 ENDIF
 SELECT INTO  $1
  d.code_set, d.code_value, d.display,
  d.active_ind, d.cdf_meaning, d.description,
  d.updt_dt_tm, dc.owner_name, dc.description
  FROM dm_code_value d,
   dm_code_set dc
  WHERE (d.code_set= $2)
   AND d.code_set=dc.code_set
  HEAD REPORT
   line1 = fillstring(100,"*"), expr1 = format(curtime,"hh:mm;;m"), expr2 = format(curdate,
    "mm/dd/yy;;d"),
   row 1, col 46, "Admin Database",
   row 1, col 98, expr1,
   row 1, col 104, expr2,
   row + 1
  HEAD PAGE
   row + 2, col 8, "Code Set",
   col 16, d.code_set, col 33,
   dc.description, col 88, "Owner:",
   col 97, dc.owner_name, row + 2,
   col 8, "Code Value", col 22,
   "Display", col 51, "CDF Meaning",
   col 70, "Active Ind.", col 88,
   "Update Date/Time", row + 1
  DETAIL
   IF (((row+ 3) >= maxrow))
    BREAK
   ENDIF
   row + 1, col 3, d.code_value,
   col 22, d.display, col 51,
   d.cdf_meaning, col 71, d.active_ind,
   col 91, d.updt_dt_tm
  FOOT REPORT
   row + 2, row + 2, col 8,
   "Total:", col 15, count(d.code_set)
  WITH maxrec = 150, maxcol = 132, maxrow = 60,
   time = value(maxsecs), noheading, format = variable
 ;end select
END GO
