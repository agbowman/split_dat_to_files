CREATE PROGRAM bhs_sys_pause
 SET pause_seconds =  $1
 SET time_marker_value = build('format(cnvtlookahead(",', $1,
  ',S", cnvtdatetime(curdate, curtime3)), "YYYYMMDDHHMMSS;;D")')
 CALL echo(time_marker_value)
 SET time_marker = parser(time_marker_value)
 CALL echo(time_marker)
 SELECT INTO "nl:"
  FROM dummyt d
  HEAD REPORT
   WHILE (format(cnvtdatetime(curdate,curtime3),"YYYYMMDDHHMMSS;;D") < time_marker)
    row + 1,row- (1)
   ENDWHILE
  WITH nocounter
 ;end select
END GO
