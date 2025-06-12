CREATE PROGRAM dcp_solcap_residentmlp:dba
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE ipatientpharmaciescnt = i4 WITH protect, noconstant(0)
 DECLARE satellite = i4 WITH protect, constant(5)
 DECLARE regular = i4 WITH protect, constant(0)
 DECLARE prescription = i4 WITH protect, constant(1)
 SET stat = alterlist(reply->solcap,2)
 SET reply->solcap[1].identifier = "2010.2.00100.2"
 SELECT INTO "nl:"
  superphysorderscount = count(DISTINCT o.order_id)
  FROM orders o,
   order_action oa
  PLAN (o
   WHERE o.orig_ord_as_flag=prescription)
   JOIN (oa
   WHERE oa.action_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
    end_dt_tm)
    AND oa.order_id=o.order_id
    AND oa.order_action_id > 0.0
    AND oa.supervising_provider_id > 0.0)
  FOOT REPORT
   reply->solcap[1].degree_of_use_num = superphysorderscount
  WITH nocounter
 ;end select
 SET reply->solcap[2].identifier = "2010.2.00100.8"
 SELECT INTO "nl:"
  superphysorderscount = count(DISTINCT o.order_id)
  FROM orders o,
   order_action oa
  PLAN (o
   WHERE ((o.orig_ord_as_flag=regular) OR (o.orig_ord_as_flag=satellite)) )
   JOIN (oa
   WHERE oa.action_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
    end_dt_tm)
    AND oa.order_id=o.order_id
    AND oa.order_action_id > 0.0
    AND oa.supervising_provider_id > 0.0)
  FOOT REPORT
   reply->solcap[2].degree_of_use_num = superphysorderscount
  WITH nocounter
 ;end select
 SET last_mod = "002"
END GO
