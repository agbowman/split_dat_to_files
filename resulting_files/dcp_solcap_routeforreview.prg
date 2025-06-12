CREATE PROGRAM dcp_solcap_routeforreview
 SET stat = alterlist(reply->solcap,2)
 SET reply->solcap[1].identifier = "2016.1.00025.1"
 SELECT INTO "nl:"
  phases = count(DISTINCT p.pathway_id)
  FROM pathway p
  WHERE p.order_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->end_dt_tm)
   AND p.type_mean IN ("CAREPLAN", "PHASE")
   AND p.review_required_sig_count=1
  DETAIL
   reply->solcap[1].degree_of_use_num = phases
  WITH nocounter
 ;end select
 SET reply->solcap[2].identifier = "2016.1.00025.2"
 SELECT INTO "nl:"
  phases = count(DISTINCT p.pathway_id)
  FROM pathway p
  WHERE p.order_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->end_dt_tm)
   AND p.type_mean IN ("CAREPLAN", "PHASE")
   AND p.review_required_sig_count=2
  DETAIL
   reply->solcap[2].degree_of_use_num = phases
  WITH nocounter
 ;end select
END GO
