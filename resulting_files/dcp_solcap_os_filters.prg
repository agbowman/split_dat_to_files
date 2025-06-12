CREATE PROGRAM dcp_solcap_os_filters
 SET modify = predeclare
 DECLARE istatus = i2 WITH protect, noconstant(0)
 SET istatus = alterlist(reply->solcap,1)
 SET reply->solcap[1].identifier = "2011.2.00092.1"
 SELECT INTO "nl:"
  inumberofosfilters = count(*)
  FROM order_sentence_filter osf
  WHERE osf.updt_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->end_dt_tm
   )
  DETAIL
   reply->solcap[1].degree_of_use_num = inumberofosfilters
  WITH nocounter
 ;end select
 SET last_mod = "001"
END GO
