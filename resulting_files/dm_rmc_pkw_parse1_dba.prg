CREATE PROGRAM dm_rmc_pkw_parse1:dba
 DECLARE drpw_size = i4
 DECLARE drpw_loop = i4
 SET drpw_size = size(request->stmt,5)
 FOR (drpw_loop = 1 TO drpw_size)
   IF (drpw_loop != drpw_size)
    CALL parser(request->stmt[drpw_loop].str,0)
   ELSE
    CALL parser(request->stmt[drpw_loop].str,1)
   ENDIF
 ENDFOR
END GO
