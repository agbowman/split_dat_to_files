CREATE PROGRAM cps_get_codevalues
 RECORD reply(
   1 code_count = i4
   1 codelist[100]
     2 code_value = f8
     2 display = c40
     2 display_key = c40
     2 description = c60
     2 definition = c1000
     2 beg_effective_dt = dq8
     2 end_effective_dt = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c15
       3 sourceobjectqual = i4
       3 sourceobjectvalue = c50
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c50
       3 sub_event_dt_tm = di8
 )
 EXECUTE cps_get_codevalues_subfun parser("c.code_set = request->codeset"), parser(
  IF ((request->cdf_ind=1)) " c.cdf_meaning = request->cdf"
  ELSE " 0=0"
  ENDIF
  ), parser(
  IF ((request->primary_ind_ind=1)) " c.primary_ind = request->primary_ind"
  ELSE "0=0"
  ENDIF
  ),
 parser(
  IF ((request->collation_ind=1)) " c.collation_seq = request->collation"
  ELSE "0=0"
  ENDIF
  )
 CALL echo("code_count is",0)
 CALL echo(reply->code_count)
END GO
