CREATE PROGRAM bhs_hlp_err:dba
 IF (validate(rl_debug_flag)=0)
  DECLARE rl_debug_flag = i4 WITH persistscript, constant(validate(bhs_debug_flag,0))
 ENDIF
 IF (validate(bhs_err->errs)=0)
  RECORD bhs_err(
    1 errs[*]
      2 l_err_cd = i4
      2 s_err_msg = vc
  ) WITH persistscript
 ENDIF
 IF (rl_debug_flag >= 10)
  CALL echo(concat(curprog," helper script executed."))
  IF (rl_debug_flag >= 50)
   CALL echo("  Subroutine bhs_error_thrown declared.")
   CALL echo("  Subroutine bhs_clear_error  declared.")
   CALL echo("  Subroutine bhs_get_error    declared.")
  ENDIF
 ENDIF
 DECLARE bhs_error_thrown(dummy_var=i2) = i2 WITH persistscript
 SUBROUTINE bhs_error_thrown(dummy_var)
   DECLARE ml_cnt = i4 WITH protect, noconstant(0)
   DECLARE ml_err_cd = i4 WITH protect, noconstant(1)
   DECLARE ms_err_msg = vc WITH protect, noconstant(" ")
   WHILE (ml_err_cd != 0)
    SET ml_err_cd = error(ms_err_msg,0)
    IF (ml_err_cd > 0)
     SET ml_cnt = (ml_cnt+ 1)
     SET stat = alterlist(bhs_err->errs,(ml_cnt+ 1))
     SET bhs_err->errs[ml_cnt].l_err_cd = ml_err_cd
     SET bhs_err->errs[ml_cnt].s_err_msg = ms_err_msg
     IF (rl_debug_flag >= 1)
      CALL echo(concat("ERROR[",build(ml_err_cd),"] ",ms_err_msg))
     ENDIF
    ENDIF
   ENDWHILE
   IF (ml_cnt > 0)
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 DECLARE bhs_clear_error(dummy_var=i2) = i2 WITH persistscript
 SUBROUTINE bhs_clear_error(dummy_var)
   DECLARE ml_err_cd = i4 WITH protect, noconstant(1)
   DECLARE ms_err_msg = vc WITH protect, noconstant(" ")
   SET ml_err_cd = error(ms_err_msg,1)
   RETURN(1)
 END ;Subroutine
 DECLARE bhs_get_error(p_index=i4,p_err_msg=vc(ref)) = i2 WITH persistscript
 SUBROUTINE bhs_get_error(p_index,p_err_msg)
   IF (p_index > size(bhs_err->errs,5))
    RETURN(0)
   ENDIF
   SET p_err_msg = concat("[",cnvtstring(bhs_err->errs[p_index].l_err_cd),"]",bhs_err->errs[p_index].
    s_err_msg)
   RETURN(1)
 END ;Subroutine
END GO
