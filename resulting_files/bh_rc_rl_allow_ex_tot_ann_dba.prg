CREATE PROGRAM bh_rc_rl_allow_ex_tot_ann:dba
 CALL echo("***** bh_rc_rl_allow_ex_tot_ann.prg - 677918 *****")
 DECLARE lchgcnt = i4 WITH noconstant(0)
 EXECUTE bh_rc_rl_common
 DECLARE filltemprec(null) = null
 SUBROUTINE filltemprec(null)
   FOR (lchgcnt = 1 TO size(request->integer_params,5))
     CASE (cnvtupper(trim(request->integer_params[lchgcnt].key_txt,3)))
      OF "TOT_ALLOW_EXP_MONTHLY":
       SET tmprec->tot_allow_exp_annual = (request->integer_params[lchgcnt].integer_value * 12)
     ENDCASE
   ENDFOR
 END ;Subroutine
 DECLARE createreply(null) = null
 SUBROUTINE createreply(null)
  CALL addtoreplyintegers("TOT_ALLOW_EXP_ANNUAL",tmprec->tot_allow_exp_annual)
  CALL echorecord(tmprec)
 END ;Subroutine
 FREE RECORD tmprec
 RECORD tmprec(
   1 tot_allow_exp_annual = i4
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
