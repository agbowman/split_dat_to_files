CREATE PROGRAM dm_log_errors:dba
 IF (( $6 != 0))
  IF (( $2 > ""))
   CALL parser( $2,1)
  ENDIF
  IF (( $3 > ""))
   CALL parser( $3,1)
  ENDIF
  IF (findstring("ORA-02270", $5)=0)
   SELECT INTO value( $1)
    FROM dual
    DETAIL
      $4, row + 1,  $5,
     row + 3
    WITH format = variable, formfeed = none, maxcol = 256,
     maxrow = 1, append
   ;end select
  ENDIF
 ENDIF
END GO
