CREATE PROGRAM bh_rc_rl_mand_toret_ann:dba
 CALL echo("***** bh_rc_rl_mand_toret_ann.prg - 677918 *****")
 DECLARE lchgcnt = i4 WITH noconstant(0)
 EXECUTE bh_rc_rl_common
 DECLARE filltemprec(null) = null
 SUBROUTINE filltemprec(null)
   FOR (lchgcnt = 1 TO size(request->integer_params,5))
     CASE (cnvtupper(trim(request->integer_params[lchgcnt].key_txt,3)))
      OF "MAND_DED_TORET_ANNUAL":
       SET tmprec->mand_ded_toret_monthly = (request->integer_params[lchgcnt].integer_value/ 12)
     ENDCASE
   ENDFOR
 END ;Subroutine
 DECLARE createreply(null) = null
 SUBROUTINE createreply(null)
  CALL addtoreplyintegers("MAND_DED_TORET_MONTHLY",tmprec->mand_ded_toret_monthly)
  CALL echorecord(tmprec)
 END ;Subroutine
 FREE RECORD tmprec
 RECORD tmprec(
   1 mand_ded_toret_monthly = i4
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
