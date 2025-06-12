CREATE PROGRAM dcp_solcap_pbs_orders:dba
 SET stat = alterlist(reply->solcap,1)
 SET reply->solcap[1].identifier = "2014.2.00038.1"
 SELECT INTO "nl:"
  numberofordersplacedwithpbsdetails = count(DISTINCT od.order_id)
  FROM orders o,
   order_detail od
  PLAN (o
   WHERE o.orig_order_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
    end_dt_tm))
   JOIN (od
   WHERE od.order_id=o.order_id
    AND od.oe_field_meaning="PBSSTATUS"
    AND od.oe_field_value != 0.0)
  HEAD REPORT
   reply->solcap[1].degree_of_use_num = numberofordersplacedwithpbsdetails,
   CALL echo(numberofordersplacedwithpbsdetails)
  WITH nocounter
 ;end select
END GO
