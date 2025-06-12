CREATE PROGRAM dm_daf_parser:dba
 DECLARE ddp_loop_cnt = i4 WITH protect, noconstant(0)
 FOR (ddp_loop_cnt = 1 TO ddp_request->cnt)
   IF ((ddp_loop_cnt=ddp_request->cnt))
    CALL parser(ddp_request->stmt[ddp_loop_cnt].str,1)
   ELSE
    CALL parser(ddp_request->stmt[ddp_loop_cnt].str,0)
   ENDIF
 ENDFOR
END GO
