CREATE PROGRAM dm_rmc_seqmatch_xlats_child:dba
 DECLARE drs_loop = i4
 FOR (drs_loop = 1 TO size(request->stmt,5))
   IF (drs_loop != size(request->stmt,5))
    CALL parser(request->stmt[drs_loop].str,0)
   ELSE
    CALL parser(request->stmt[drs_loop].str,1)
   ENDIF
 ENDFOR
 SET reply->row_count = curqual
END GO
