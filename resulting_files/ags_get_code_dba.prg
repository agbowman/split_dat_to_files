CREATE PROGRAM ags_get_code:dba
 IF (validate(ags_get_code_defined,0)=0)
  DECLARE ags_get_code_defined = i2 WITH constant(1), persistscript
  CALL echo("")
  CALL echo("<=== AGS_GET_CODE.PRG Begin ===>")
  CALL echo("MOD:000 10/23/06")
  DECLARE ags_get_code_by(code_by=vc,x_code_set=i4,x_match=vc) = f8 WITH copy
  DECLARE ags_get_code_meaning(code=f8) = c12 WITH copy
  DECLARE ags_get_code_display(code=f8) = c40 WITH copy
  DECLARE ags_get_meaning_by_codeset(x_code_set,x_meaning) = f8 WITH copy
  SUBROUTINE ags_get_code_by(code_by,x_code_set,x_match)
    FREE SET t_code
    DECLARE t_code = f8 WITH public, noconstant(0.0)
    IF (trim(code_by) > ""
     AND x_code_set > 0
     AND trim(x_match) > "")
     FREE SET t_match
     DECLARE t_match = c12 WITH public, noconstant(fillstring(12," "))
     SET t_match = x_match
     SET t_code = uar_get_code_by(nullterm(code_by),cnvtint(x_code_set),nullterm(t_match))
     IF (t_code <= 1)
      CALL echo("   uar_get_meaning_by failed - selecting row from code_value table")
      SELECT INTO "nl:"
       FROM code_value cv
       WHERE cv.code_set=x_code_set
        AND cv.begin_effective_dt_tm < cnvtdatetime(curdate,curtime3)
        AND cv.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
        AND cv.active_ind=1
        AND ((cv.cdf_meaning=trim(t_match)) OR (((cv.display=trim(x_match)) OR (cv.display_key=trim(
        x_match))) ))
       DETAIL
        t_code = cv.code_value
       WITH maxqual(cv,1)
      ;end select
      IF (curqual < 1)
       CALL echo("   no rows qualified on code_value table")
      ENDIF
     ENDIF
    ENDIF
    RETURN(t_code)
  END ;Subroutine
  SUBROUTINE ags_get_meaning_by_codeset(x_code_set,x_meaning)
    FREE SET t_code
    DECLARE t_code = f8
    SET t_code = 0.0
    IF (x_code_set > 0
     AND trim(x_meaning) > "")
     FREE SET t_meaning
     DECLARE t_meaning = c12
     SET t_meaning = fillstring(12," ")
     SET t_meaning = x_meaning
     FREE SET t_rc
     SET t_rc = uar_get_meaning_by_codeset(cnvtint(x_code_set),nullterm(t_meaning),1,t_code)
     IF (t_code <= 0)
      CALL echo("   uar_get_meaning_by_codeset failed")
      CALL echo("   selecting row from code_value table")
      SELECT INTO "nl:"
       cv.*
       FROM code_value cv
       WHERE cv.code_set=x_code_set
        AND cv.cdf_meaning=trim(x_meaning)
        AND cv.begin_effective_dt_tm < cnvtdatetime(curdate,curtime3)
        AND cv.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
        AND cv.active_ind=1
       DETAIL
        t_code = cv.code_value
       WITH maxqual(cv,1)
      ;end select
      IF (curqual < 1)
       CALL echo("   no rows qualified on code_value table")
      ENDIF
     ENDIF
    ENDIF
    RETURN(t_code)
  END ;Subroutine
  SUBROUTINE ags_get_code_meaning(code)
    FREE SET t_meaning
    DECLARE t_meaning = c12
    SET t_meaning = fillstring(12," ")
    IF (code > 0)
     SET t_meaning = uar_get_code_meaning(code)
     IF (trim(t_meaning)="")
      CALL echo("   uar_get_code_meaning failed")
      CALL echo("   selecting row from code_value table")
      SELECT INTO "nl:"
       cv.*
       FROM code_value cv
       WHERE cv.code_value=code
        AND cv.begin_effective_dt_tm < cnvtdatetime(curdate,curtime3)
        AND cv.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
        AND cv.active_ind=1
       DETAIL
        t_meaning = cv.cdf_meaning
       WITH maxqual(cv,1)
      ;end select
      IF (curqual < 1)
       CALL echo("   no rows qualified on code_value table")
      ENDIF
     ENDIF
    ENDIF
    RETURN(trim(t_meaning,3))
  END ;Subroutine
  SUBROUTINE ags_get_code_display(code)
    FREE SET t_display
    DECLARE t_display = c40
    SET t_display = fillstring(40," ")
    IF (code > 0)
     SET t_display = uar_get_code_display(cnvtreal(code))
     IF (trim(t_display)="")
      CALL echo("   uar_get_code_display failed")
      CALL echo("   selecting row from code_value table")
      SELECT INTO "nl:"
       cv.*
       FROM code_value cv
       WHERE cv.code_value=code
        AND cv.begin_effective_dt_tm < cnvtdatetime(curdate,curtime3)
        AND cv.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
        AND cv.active_ind=1
       DETAIL
        t_display = cv.display
       WITH maxqual(cv,1)
      ;end select
      IF (curqual < 1)
       CALL echo("   no rows qualified on code_value table")
      ENDIF
     ENDIF
    ENDIF
    RETURN(trim(t_display,3))
  END ;Subroutine
  CALL echo("<=== AGS_GET_CODE.PRG End ===>")
 ENDIF
END GO
