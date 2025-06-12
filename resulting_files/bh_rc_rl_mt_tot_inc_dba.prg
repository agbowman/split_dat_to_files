CREATE PROGRAM bh_rc_rl_mt_tot_inc:dba
 CALL echo("***** bh_rc_rl_mt_tot_inc.prg - 677918 *****")
 DECLARE lchgcnt = i4 WITH noconstant(0)
 EXECUTE bh_rc_rl_common
 DECLARE filltemprec(null) = null
 SUBROUTINE filltemprec(null)
   FOR (lchgcnt = 1 TO size(request->integer_params,5))
     CASE (cnvtupper(trim(request->integer_params[lchgcnt].key_txt,3)))
      OF "EMPLOYMENT_INCOME_MONTHLY":
       SET tmprec->employment_income_monthly = request->integer_params[lchgcnt].integer_value
      OF "SSI_MONTHLY":
       SET tmprec->ssi_monthly = request->integer_params[lchgcnt].integer_value
      OF "SSDI_MONTHLY":
       SET tmprec->ssdi_monthly = request->integer_params[lchgcnt].integer_value
      OF "SOC_SEC_MONTHLY":
       SET tmprec->soc_sec_monthly = request->integer_params[lchgcnt].integer_value
      OF "SPOUSE_MONTHLY":
       SET tmprec->spouse_monthly = request->integer_params[lchgcnt].integer_value
      OF "PARENTS_MONTHLY":
       SET tmprec->parents_monthly = request->integer_params[lchgcnt].integer_value
      OF "OTHER_MONTHLY":
       SET tmprec->other_monthly = request->integer_params[lchgcnt].integer_value
     ENDCASE
   ENDFOR
   SET tmprec->total_monthly_income = 0
   SET tmprec->total_monthly_income += tmprec->employment_income_monthly
   SET tmprec->total_monthly_income += tmprec->ssi_monthly
   SET tmprec->total_monthly_income += tmprec->ssdi_monthly
   SET tmprec->total_monthly_income += tmprec->soc_sec_monthly
   SET tmprec->total_monthly_income += tmprec->spouse_monthly
   SET tmprec->total_monthly_income += tmprec->parents_monthly
   SET tmprec->total_monthly_income += tmprec->other_monthly
 END ;Subroutine
 DECLARE createreply(null) = null
 SUBROUTINE createreply(null)
  CALL addtoreplyintegers("TOTAL_MONTHLY_INCOME",tmprec->total_monthly_income)
  CALL echorecord(tmprec)
 END ;Subroutine
 FREE RECORD tmprec
 RECORD tmprec(
   1 total_monthly_income = i4
   1 employment_income_monthly = i4
   1 ssi_monthly = i4
   1 ssdi_monthly = i4
   1 soc_sec_monthly = i4
   1 spouse_monthly = i4
   1 parents_monthly = i4
   1 other_monthly = i4
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
