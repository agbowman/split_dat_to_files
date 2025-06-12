CREATE PROGRAM afc_add_csops_summ:dba
 EXECUTE cclseclogin
 SET message = nowindow
 CALL echo("executing afc_add_csops_summ")
 DECLARE afc_add_csops_summ_version = vc
 SET afc_add_csops_summ_version = "323720.FT.007"
 SET reply->status_data.status = "F"
 SET isum = 0
 DECLARE credit_cd = f8
 DECLARE debit_cd = f8
 SET codeset = 13028
 SET cdf_meaning = "CR"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,credit_cd)
 SET codeset = 13028
 SET cdf_meaning = "DR"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,debit_cd)
 IF (size(csops_request2->charges,5) > 0)
  CALL add_csops_summ(0)
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SUBROUTINE add_csops_summ(aa)
  FOR (isum = 1 TO size(csops_request2->charges,5))
    INSERT  FROM csops_summ s
     SET s.csops_summ_id = cnvtreal(seq(cssumm_seq,nextval)), s.job_name_cd = csops_request2->
      job_name_cd, s.job_status = csops_request2->job_status,
      s.batch_num = csops_request2->batch_num, s.sequence = csops_request2->seq, s.start_dt_tm =
      cnvtdatetime(csops_request2->start_dt_tm),
      s.end_dt_tm = cnvtdatetime(csops_request2->end_dt_tm), s.interface_file_id = csops_request2->
      charges[isum].interface_file_id, s.charge_type_cd = csops_request2->charges[isum].
      charge_type_cd,
      s.raw_count =
      IF ((csops_request2->charges[isum].charge_type_cd=credit_cd)) - ((1 * csops_request2->charges[
       isum].raw_count))
      ELSEIF ((csops_request2->charges[isum].charge_type_cd=debit_cd)) csops_request2->charges[isum].
       raw_count
      ENDIF
      , s.quantity =
      IF ((csops_request2->charges[isum].charge_type_cd=credit_cd)) - ((1 * csops_request2->charges[
       isum].total_quantity))
      ELSEIF ((csops_request2->charges[isum].charge_type_cd=debit_cd)) csops_request2->charges[isum].
       total_quantity
      ENDIF
      , s.amount =
      IF ((csops_request2->charges[isum].charge_type_cd=credit_cd)) - ((1 * csops_request2->charges[
       isum].total_amount))
      ELSEIF ((csops_request2->charges[isum].charge_type_cd=debit_cd)) csops_request2->charges[isum].
       total_amount
      ENDIF
     WITH nocounter
    ;end insert
  ENDFOR
  SET reply->status_data.status = "S"
 END ;Subroutine
 COMMIT
END GO
