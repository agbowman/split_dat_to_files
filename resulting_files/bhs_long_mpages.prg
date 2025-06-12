CREATE PROGRAM bhs_long_mpages
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SELECT INTO  $OUTDEV
  xyz = substring(1,20,p.name_full_formatted)
  FROM ccl_report_audit cra,
   person p
  PLAN (cra
   WHERE cra.object_name="MP*")
   JOIN (p
   WHERE p.person_id=cra.updt_id
    AND p.person_id=19803089)
  ORDER BY cra.begin_dt_tm
  DETAIL
   col 0, cra.object_name, col 40,
   cra.begin_dt_tm, col 60, cra.end_dt_tm,
   col 80, xyz, row + 1
  WITH format(date,"@SHORTDATETIME")
 ;end select
END GO
