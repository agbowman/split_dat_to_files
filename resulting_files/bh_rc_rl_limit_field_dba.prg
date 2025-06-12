CREATE PROGRAM bh_rc_rl_limit_field:dba
 CALL echo("***** bh_rc_rl_limit_field.prg - 677918 *****")
 DECLARE lchgcnt = i4 WITH noconstant(0)
 EXECUTE bh_rc_rl_common
 DECLARE filltemprec(null) = null
 SUBROUTINE filltemprec(null)
   FOR (lchgcnt = 1 TO size(request->integer_params,5))
     CASE (request->integer_params[lchgcnt].key_txt)
      OF "FIELD_LEN":
       SET tmprec->field_len = request->integer_params[lchgcnt].integer_value
      OF "ORIGINAL_VALUE":
       SET tmprec->original_value = cnvtstring(request->integer_params[lchgcnt].integer_value)
     ENDCASE
   ENDFOR
   SET tmprec->new_value = cnvtstring(tmprec->original_value)
   IF ((tmprec->field_len > 0)
    AND textlen(tmprec->new_value) > 0)
    IF ((tmprec->field_len <= textlen(tmprec->new_value)))
     SET tmprec->new_value = substring(1,tmprec->field_len,tmprec->new_value)
    ENDIF
   ENDIF
   SET tmprec->return_value = cnvtreal(tmprec->new_value)
   CALL echo(tmprec)
 END ;Subroutine
 DECLARE createreply(null) = null
 SUBROUTINE createreply(null)
  CALL addtoreplyintegers("RETURN_VALUE",tmprec->return_value)
  CALL echorecord(tmprec)
 END ;Subroutine
 FREE RECORD tmprec
 RECORD tmprec(
   1 field_len = i4
   1 original_value = vc
   1 new_value = vc
   1 return_value = i4
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
