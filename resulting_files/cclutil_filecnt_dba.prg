CREATE PROGRAM cclutil_filecnt:dba
 SET message = noinformation
 DECLARE dirname = vc
 SET total = 0
 SET gtotal = 0
 SET com_line = 0
 SET gcom_line = 0
 SET logical "DIR1" "cer_code1:[ccllib]"
 SET logical "DIR2" "cer_code1:[ccluar]"
 SET logical "DIR3" "cer_code1:[ccluarx]"
 SET logical "DIR4" "cer_code1:[cclsqloci]"
 SET logical "DIR5" "cer_code1:[cclisam]"
 SET logical "DIR6" "cer_code1:[cclsrv]"
 FOR (xnum = 1 TO 6)
   SET dirname = build("DIR",xnum)
   EXECUTE cclutil_filecnt2 value(dirname), "*.c,*.h,*.cpp"
   SET gtotal += total
   SET gcom_line += com_line
   CALL echo(build(dirname,",",logical(dirname)," Total=",total,
     " Comment=",com_line))
 ENDFOR
 CALL echo(build("Grand Total=",gtotal,",comment=",gcom_line))
END GO
