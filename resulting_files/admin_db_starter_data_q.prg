CREATE PROGRAM admin_db_starter_data_q
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
  WITH format, maxrec = 150, maxcol = 132,
   maxrow = 60, time = value(maxsecs)
 ;end select
END GO
