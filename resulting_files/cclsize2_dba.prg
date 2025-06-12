CREATE PROGRAM cclsize2:dba
 PROMPT
  "Output name : " = "MINE",
  "Sort by (0:none, 1:size, 2:reqnum, 3:tasknum, 4:progname, 5:srvname) : " = 1,
  "Min size to show (100): " = 100
 DECLARE progname = c41
 DECLARE servername = c41
 SELECT
  IF (( $2=1))
   ORDER BY d.binary_cnt, prog_name
  ELSEIF (( $2=2))
   ORDER BY r.request_number
  ELSEIF (( $2=3))
   ORDER BY t.task_number, r.request_number
  ELSEIF (( $2=4))
   ORDER BY prog_name
  ELSEIF (( $2=5))
   ORDER BY server_name, prog_name
  ELSE
  ENDIF
  INTO  $1
  tdb = uar_get_tdb(r.request_number,progname,servername)"#", cclsize = d.binary_cnt, prog_name =
  cnvtupper(substring(1,30,progname)),
  server_name = substring(1,30,servername), r.request_number, t.task_number,
  cclver = mod(d.ccl_version,100)"###", ccl_reg =
  IF (d.ccl_version > 100) "N"
  ELSE "Y"
  ENDIF
  FROM request r,
   task_request_r t,
   dprotect d
  PLAN (r
   WHERE r.active_ind=1)
   JOIN (t
   WHERE r.request_number=t.request_number)
   JOIN (d
   WHERE 0=d.group
    AND "P"=d.object
    AND cnvtupper(progname)=d.object_name
    AND (d.binary_cnt >=  $3))
 ;end select
END GO
