CREATE PROGRAM bh_rc_rl_mt_exc_exp:dba
 CALL echo("***** bh_rc_rl_mt_exc_exp.prg - 677918 *****")
 DECLARE lchgcnt = i4 WITH noconstant(0)
 EXECUTE bh_rc_rl_common
 DECLARE filltemprec(null) = null
 SUBROUTINE filltemprec(null)
   FOR (lchgcnt = 1 TO size(request->integer_params,5))
     CASE (cnvtupper(trim(request->integer_params[lchgcnt].key_txt,3)))
      OF "MAJOR_MEDICAL_MONTHLY":
       SET tmprec->major_medical_monthly = request->integer_params[lchgcnt].integer_value
      OF "MAJOR_CASUALTY_MONTHLY":
       SET tmprec->major_casualty_monthly = request->integer_params[lchgcnt].integer_value
      OF "CHILDCARE_MONTHLY":
       SET tmprec->childcare_monthly = request->integer_params[lchgcnt].integer_value
     ENDCASE
   ENDFOR
   SET tmprec->monthly_exceptional_expenses = 0
   SET tmprec->monthly_exceptional_expenses = tmprec->major_medical_monthly
   SET tmprec->monthly_exceptional_expenses += tmprec->major_casualty_monthly
   SET tmprec->monthly_exceptional_expenses += tmprec->childcare_monthly
 END ;Subroutine
 DECLARE createreply(null) = null
 SUBROUTINE createreply(null)
  CALL addtoreplyintegers("MONTHLY_EXCEPTIONAL_EXPENSES",tmprec->monthly_exceptional_expenses)
  CALL echorecord(tmprec)
 END ;Subroutine
 FREE RECORD tmprec
 RECORD tmprec(
   1 monthly_exceptional_expenses = i4
   1 major_medical_monthly = i4
   1 major_casualty_monthly = i4
   1 childcare_monthly = i4
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
