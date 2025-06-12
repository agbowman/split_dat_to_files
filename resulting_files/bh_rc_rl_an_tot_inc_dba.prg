CREATE PROGRAM bh_rc_rl_an_tot_inc:dba
 CALL echo("***** bh_rc_rl_an_tot_inc.prg - 677918 *****")
 DECLARE lchgcnt = i4 WITH noconstant(0)
 EXECUTE bh_rc_rl_common
 DECLARE filltemprec(null) = null
 SUBROUTINE filltemprec(null)
   FOR (lchgcnt = 1 TO size(request->integer_params,5))
     CASE (cnvtupper(trim(request->integer_params[lchgcnt].key_txt,3)))
      OF "EMPLOYMENT_INCOME_ANNUAL":
       SET tmprec->employment_income_annual = request->integer_params[lchgcnt].integer_value
      OF "SSI_ANNUAL":
       SET tmprec->ssi_annual = request->integer_params[lchgcnt].integer_value
      OF "SSDI_ANNUAL":
       SET tmprec->ssdi_annual = request->integer_params[lchgcnt].integer_value
      OF "SOC_SEC_ANNUAL":
       SET tmprec->soc_sec_annual = request->integer_params[lchgcnt].integer_value
      OF "SPOUSE_ANNUAL":
       SET tmprec->spouse_annual = request->integer_params[lchgcnt].integer_value
      OF "PARENTS_ANNUAL":
       SET tmprec->parents_annual = request->integer_params[lchgcnt].integer_value
      OF "OTHER_ANNUAL":
       SET tmprec->other_annual = request->integer_params[lchgcnt].integer_value
     ENDCASE
   ENDFOR
   SET tmprec->total_annual_income = 0
   SET tmprec->total_annual_income = tmprec->employment_income_annual
   SET tmprec->total_annual_income += tmprec->ssi_annual
   SET tmprec->total_annual_income += tmprec->ssdi_annual
   SET tmprec->total_annual_income += tmprec->soc_sec_annual
   SET tmprec->total_annual_income += tmprec->spouse_annual
   SET tmprec->total_annual_income += tmprec->parents_annual
   SET tmprec->total_annual_income += tmprec->other_annual
 END ;Subroutine
 DECLARE createreply(null) = null
 SUBROUTINE createreply(null)
  CALL addtoreplyintegers("TOTAL_ANNUAL_INCOME",tmprec->total_annual_income)
  CALL echorecord(tmprec)
 END ;Subroutine
 FREE RECORD tmprec
 RECORD tmprec(
   1 total_annual_income = i4
   1 employment_income_annual = i4
   1 ssi_annual = i4
   1 ssdi_annual = i4
   1 soc_sec_annual = i4
   1 spouse_annual = i4
   1 parents_annual = i4
   1 other_annual = i4
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
