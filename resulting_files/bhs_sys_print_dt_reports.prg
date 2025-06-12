CREATE PROGRAM bhs_sys_print_dt_reports
 FREE RECORD filenames
 RECORD filenames(
   1 cnt = i2
   1 qual[*]
     2 name = vc
 )
 DECLARE tmp_remove = vc
 FREE DEFINE rtl
 DEFINE rtl "ccluserdir:downtimefilenames"
 SELECT INTO "nl:"
  FROM rtlt t
  WHERE t.line > " "
   AND t.line != "EXP"
  DETAIL
   filenames->cnt = (filenames->cnt+ 1), stat = alterlist(filenames->qual,filenames->cnt), filenames
   ->qual[filenames->cnt].name = trim(t.line)
  WITH nocounter
 ;end select
 CALL echorecord(filenames)
 FOR (x = 1 TO filenames->cnt)
   SET spool value(filenames->qual[x].name)  $1
   SET tmp_remove = build2('set stat = remove("',filenames->qual[x].name,'") go')
   CALL echo(build("end - File Name:,",x,":",filenames->qual[x].name))
   CALL echo(tmp_remove)
   CALL parser(tmp_remove)
   SET time_marker = format(cnvtlookahead("10,S",cnvtdatetime(curdate,curtime3)),"YYYYMMDDHHMMSS;;D")
   SELECT INTO "nl:"
    FROM dummyt d
    HEAD REPORT
     WHILE (format(cnvtdatetime(curdate,curtime3),"YYYYMMDDHHMMSS;;D") < time_marker)
      row + 1,row- (1)
     ENDWHILE
    WITH nocounter
   ;end select
 ENDFOR
 SET tmp_remove = build2('set stat = remove("downtimefilenames.dat") go')
 CALL echo(build("end - File Name:,",x,":",downtimefilenames))
 CALL echo(tmp_remove)
 CALL parser(tmp_remove)
END GO
