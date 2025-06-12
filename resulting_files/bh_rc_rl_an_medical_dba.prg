CREATE PROGRAM bh_rc_rl_an_medical:dba
 CALL echo("***** bh_rc_rl_an_medical.prg - 677918 *****")
 DECLARE lchgcnt = i4 WITH noconstant(0)
 EXECUTE bh_rc_rl_common
 DECLARE filltemprec(null) = null
 SUBROUTINE filltemprec(null)
   FOR (lchgcnt = 1 TO size(request->integer_params,5))
     CASE (request->integer_params[lchgcnt].key_txt)
      OF "MAJOR_MEDICAL_ANNUAL":
       SET tmprec->major_medical_monthly = (request->integer_params[lchgcnt].integer_value/ 12)
     ENDCASE
   ENDFOR
 END ;Subroutine
 DECLARE createreply(null) = null
 SUBROUTINE createreply(null)
  CALL addtoreplyintegers("MAJOR_MEDICAL_MONTHLY",tmprec->major_medical_monthly)
  CALL echorecord(tmprec)
 END ;Subroutine
 FREE RECORD tmprec
 RECORD tmprec(
   1 major_medical_monthly = i4
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
