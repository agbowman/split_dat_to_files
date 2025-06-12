CREATE PROGRAM bh_rc_rl_grla_tot_inc:dba
 CALL echo("***** bh_rc_rl_grla_tot_inc.prg - 677918 *****")
 DECLARE lchgcnt = i4 WITH noconstant(0)
 EXECUTE bh_rc_rl_common
 DECLARE filltemprec(null) = null
 SUBROUTINE filltemprec(null)
   FOR (lchgcnt = 1 TO size(request->integer_params,5))
     CASE (cnvtupper(trim(request->integer_params[lchgcnt].key_txt,3)))
      OF "CHECKING":
       SET tmprec->checking = request->integer_params[lchgcnt].integer_value
      OF "SAVINGS":
       SET tmprec->savings = request->integer_params[lchgcnt].integer_value
      OF "OTHER":
       SET tmprec->other = request->integer_params[lchgcnt].integer_value
     ENDCASE
   ENDFOR
   SET tmprec->gross_liquid_assets = 0
   SET tmprec->gross_liquid_assets += tmprec->checking
   SET tmprec->gross_liquid_assets += tmprec->savings
   SET tmprec->gross_liquid_assets += tmprec->other
 END ;Subroutine
 DECLARE createreply(null) = null
 SUBROUTINE createreply(null)
  CALL addtoreplyintegers("GROSS_LIQUID_ASSETS",tmprec->gross_liquid_assets)
  CALL echorecord(tmprec)
 END ;Subroutine
 FREE RECORD tmprec
 RECORD tmprec(
   1 checking = i4
   1 savings = i4
   1 other = i4
   1 gross_liquid_assets = i4
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
