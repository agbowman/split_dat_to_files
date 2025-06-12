CREATE PROGRAM afc_add_csops_summ_front:dba
 CALL echo("executing afc_add_csops_summ")
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 CALL echorecord(request,"ccluserdir:rs4231.dat")
 SET isum = 0
 DECLARE credit_cd = f8
 DECLARE debit_cd = f8
 SET codeset = 13028
 SET cdf_meaning = "CR"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,credit_cd)
 CALL echo(build("the credit_cd code value is: ",credit_cd))
 SET codeset = 13028
 SET cdf_meaning = "DR"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,debit_cd)
 CALL echo(build("the debit_cd code value is: ",debit_cd))
 CALL echo("executing afc_add_csops_summ!!!!!!!!!")
 CALL add_csops_summ(0)
 SUBROUTINE add_csops_summ(aa)
  FOR (isum = 1 TO size(request->charges,5))
    SET new_nbr = 0.0
    SELECT INTO "nl:"
     y = seq(cssumm_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      new_nbr = cnvtreal(y)
     WITH format, counter
    ;end select
    SET request->csops_summ_id = new_nbr
    INSERT  FROM csops_summ s
     SET s.csops_summ_id = request->csops_summ_id, s.job_name_cd = request->job_name_cd, s.job_status
       = request->job_status,
      s.batch_num = request->batch_num, s.sequence = request->seq, s.start_dt_tm = cnvtdatetime(
       request->start_dt_tm),
      s.end_dt_tm = cnvtdatetime(request->end_dt_tm), s.interface_file_id = request->charges[isum].
      interface_file_id, s.charge_type_cd = request->charges[isum].charge_type_cd,
      s.raw_count =
      IF ((request->charges[isum].charge_type_cd=credit_cd)) - ((1 * request->charges[isum].raw_count
       ))
      ELSEIF ((request->charges[isum].charge_type_cd=debit_cd)) request->charges[isum].raw_count
      ENDIF
      , s.quantity =
      IF ((request->charges[isum].charge_type_cd=credit_cd)) - ((1 * request->charges[isum].
       total_quantity))
      ELSEIF ((request->charges[isum].charge_type_cd=debit_cd)) request->charges[isum].total_quantity
      ENDIF
      , s.amount =
      IF ((request->charges[isum].charge_type_cd=credit_cd)) - ((1 * request->charges[isum].
       total_amount))
      ELSEIF ((request->charges[isum].charge_type_cd=debit_cd)) request->charges[isum].total_amount
      ENDIF
     WITH nocounter
    ;end insert
    CALL echo(build("RS4231 Amount for AFC_ADD_CSOPS_SUMM: ",request->charges[isum].total_amount))
    SET reply->status_data.status = "S"
  ENDFOR
  CALL echo(build("new_nbr is ",new_nbr))
 END ;Subroutine
 COMMIT
END GO
