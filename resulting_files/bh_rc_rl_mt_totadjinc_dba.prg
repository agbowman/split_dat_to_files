CREATE PROGRAM bh_rc_rl_mt_totadjinc:dba
 CALL echo("***** bh_rc_rl_mt_totadjinc.prg - 677918 *****")
 DECLARE lchgcnt = i4 WITH noconstant(0)
 EXECUTE bh_rc_rl_common
 DECLARE filltemprec(null) = null
 SUBROUTINE filltemprec(null)
   FOR (lchgcnt = 1 TO size(request->integer_params,5))
     CASE (cnvtupper(trim(request->integer_params[lchgcnt].key_txt,3)))
      OF "TOTAL_MONTHLY_INCOME":
       SET tmprec->total_monthly_income = request->integer_params[lchgcnt].integer_value
      OF "MONTHLY_EXCEPTIONAL_EXPENSES":
       SET tmprec->monthly_exceptional_expenses = request->integer_params[lchgcnt].integer_value
     ENDCASE
   ENDFOR
   SET tmprec->total_adj_monthly_income = 0
   SET tmprec->total_adj_monthly_income = (tmprec->total_monthly_income - tmprec->
   monthly_exceptional_expenses)
 END ;Subroutine
 DECLARE createreply(null) = null
 SUBROUTINE createreply(null)
   CALL addtoreplyintegers("TOTAL_ADJ_MONTHLY_INCOME",tmprec->total_adj_monthly_income)
   CALL addtoreplyintegers("TOTAL_ADJ_ANNUAL_INCOME",(tmprec->total_adj_monthly_income * 12))
   CALL echorecord(tmprec)
 END ;Subroutine
 FREE RECORD tmprec
 RECORD tmprec(
   1 total_adj_monthly_income = i4
   1 total_monthly_income = i4
   1 monthly_exceptional_expenses = i4
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
