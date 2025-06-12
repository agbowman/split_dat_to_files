CREATE PROGRAM bh_rc_rl_mt_emp_inc:dba
 CALL echo("***** bh_rc_rl_mt_emp_inc.prg - 677918 *****")
 DECLARE lchgcnt = i4 WITH noconstant(0)
 EXECUTE bh_rc_rl_common
 DECLARE filltemprec(null) = null
 SUBROUTINE filltemprec(null)
   FOR (lchgcnt = 1 TO size(request->integer_params,5))
     CASE (request->integer_params[lchgcnt].key_txt)
      OF "EMPLOYMENT_INCOME_MONTHLY":
       SET tmprec->employment_income_annual = (request->integer_params[lchgcnt].integer_value * 12)
     ENDCASE
   ENDFOR
 END ;Subroutine
 DECLARE createreply(null) = null
 SUBROUTINE createreply(null)
  CALL addtoreplyintegers("EMPLOYMENT_INCOME_ANNUAL",tmprec->employment_income_annual)
  CALL echorecord(tmprec)
 END ;Subroutine
 FREE RECORD tmprec
 RECORD tmprec(
   1 employment_income_annual = i4
 )
 IF (size(request->integer_params,5) > 0)
  CALL filltemprec(null)
  CALL createreply(null)
 ENDIF
 IF (fillerrorcheck("SCRIPT")=true)
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL writelogfile(null)
END GO
