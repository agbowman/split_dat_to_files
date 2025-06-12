CREATE PROGRAM bh_rc_rl_alt_slide_tot:dba
 CALL echo("***** bh_rc_rl_alt_slide_tot.prg - 677918 *****")
 DECLARE lchgcnt = i4 WITH noconstant(0)
 EXECUTE bh_rc_rl_common
 DECLARE filltemprec(null) = null
 SUBROUTINE filltemprec(null)
  FOR (lchgcnt = 1 TO size(request->integer_params,5))
    CASE (request->integer_params[lchgcnt].key_txt)
     OF "ALT_SLIDE":
      SET tmprec->slide = request->integer_params[lchgcnt].integer_value
     OF "ALT_ADDITIONAL_SLIDE":
      SET tmprec->additional_slide = request->integer_params[lchgcnt].integer_value
    ENDCASE
  ENDFOR
  SET tmprec->slide_total = (tmprec->slide+ tmprec->additional_slide)
 END ;Subroutine
 DECLARE createreply(null) = null
 SUBROUTINE createreply(null)
  CALL addtoreplyintegers("ALT_SLIDE_TOTAL",tmprec->slide_total)
  CALL echorecord(tmprec)
 END ;Subroutine
 FREE RECORD tmprec
 RECORD tmprec(
   1 slide = i4
   1 additional_slide = i4
   1 slide_total = i4
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
