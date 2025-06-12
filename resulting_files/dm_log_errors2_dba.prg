CREATE PROGRAM dm_log_errors2:dba
 IF (( $4 != 0))
  IF (findstring("ORA-02275", $3)=0)
   SELECT INTO value( $1)
    FROM dual
    DETAIL
      $2, row + 1,  $3,
     row + 3
    WITH format = variable, noheading, formfeed = none,
     maxcol = 512, maxrow = 1, append
   ;end select
  ENDIF
 ENDIF
END GO
