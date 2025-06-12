CREATE PROGRAM dm_rmc_run_stmt_child:dba
 DECLARE rsc_ndx = i4 WITH protect
 FOR (rsc_ndx = 1 TO size(request->stmt,5))
   IF ((request->stmt[rsc_ndx].end_ind=0))
    CALL parser(request->stmt[rsc_ndx].str,1)
   ELSE
    CALL parser(request->stmt[rsc_ndx].str,0)
   ENDIF
 ENDFOR
END GO
