CREATE PROGRAM dcp_solcap_pharmacy_discharge:dba
 SET stat = alterlist(reply->solcap,2)
 SET reply->solcap[1].identifier = "2012.1.00066.15"
 SELECT INTO "nl:"
  supplydocumentedcount = count(DISTINCT osr.order_id)
  FROM order_supply_review osr
  WHERE osr.updt_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->end_dt_tm
   )
   AND osr.location_exists_ind=1
   AND osr.active_ind=1
  DETAIL
   reply->solcap[1].degree_of_use_num = supplydocumentedcount
  WITH nocounter
 ;end select
 SET reply->solcap[2].identifier = "2012.1.00066.16"
 SELECT INTO "nl:"
  reviewdocumentedcount = count(DISTINCT osr.order_id)
  FROM order_supply_review osr
  WHERE osr.updt_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->end_dt_tm
   )
   AND osr.pharmacy_review_ind=1
   AND osr.active_ind=1
  DETAIL
   reply->solcap[2].degree_of_use_num = reviewdocumentedcount
  WITH nocounter
 ;end select
 SET last_mod = "001"
 CALL echo(build("curdate",curdate))
END GO
