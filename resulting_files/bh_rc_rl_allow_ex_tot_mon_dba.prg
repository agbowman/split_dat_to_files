CREATE PROGRAM bh_rc_rl_allow_ex_tot_mon:dba
 CALL echo("***** bh_rc_rl_allow_ex_tot_mon.prg - 677918 *****")
 DECLARE lchgcnt = i4 WITH noconstant(0)
 EXECUTE bh_rc_rl_common
 DECLARE filltemprec(null) = null
 SUBROUTINE filltemprec(null)
   FOR (lchgcnt = 1 TO size(request->integer_params,5))
     CASE (cnvtupper(trim(request->integer_params[lchgcnt].key_txt,3)))
      OF "COURT_ORD_OBLIG_MONTHLY":
       SET tmprec->court_ord_oblig_monthly = request->integer_params[lchgcnt].integer_value
      OF "CHILD_CARE_EXP_MONTHLY":
       SET tmprec->child_care_exp_monthly = request->integer_params[lchgcnt].integer_value
      OF "DEP_SUPPORT_MONTHLY":
       SET tmprec->dep_support_monthly = request->integer_params[lchgcnt].integer_value
      OF "MAJOR_MED_MONTHLY":
       SET tmprec->major_med_monthly = request->integer_params[lchgcnt].integer_value
      OF "MAND_DED_TORET_MONTHLY":
       SET tmprec->mand_ded_toret_monthly = request->integer_params[lchgcnt].integer_value
     ENDCASE
   ENDFOR
   SET tmprec->tot_allow_exp_monthly = 0
   SET tmprec->tot_allow_exp_monthly += tmprec->court_ord_oblig_monthly
   SET tmprec->tot_allow_exp_monthly += tmprec->child_care_exp_monthly
   SET tmprec->tot_allow_exp_monthly += tmprec->dep_support_monthly
   SET tmprec->tot_allow_exp_monthly += tmprec->major_med_monthly
   SET tmprec->tot_allow_exp_monthly += tmprec->mand_ded_toret_monthly
 END ;Subroutine
 DECLARE createreply(null) = null
 SUBROUTINE createreply(null)
  CALL addtoreplyintegers("TOT_ALLOW_EXP_MONTHLY",tmprec->tot_allow_exp_monthly)
  CALL echorecord(tmprec)
 END ;Subroutine
 FREE RECORD tmprec
 RECORD tmprec(
   1 tot_allow_exp_monthly = i4
   1 court_ord_oblig_monthly = i4
   1 child_care_exp_monthly = i4
   1 dep_support_monthly = i4
   1 major_med_monthly = i4
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
