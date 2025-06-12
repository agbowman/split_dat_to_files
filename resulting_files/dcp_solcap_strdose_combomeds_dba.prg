CREATE PROGRAM dcp_solcap_strdose_combomeds:dba
 SET stat = alterlist(reply->solcap,1)
 SET reply->solcap[1].identifier = "2012.1.00140.1"
 SELECT INTO "nl:"
  numofcombinationmedswithstrengthdose = count(DISTINCT od3.order_id)
  FROM orders o,
   order_detail od1,
   order_detail od2,
   order_detail od3
  PLAN (o
   WHERE o.orig_order_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
    end_dt_tm))
   JOIN (od1
   WHERE od1.order_id=o.order_id
    AND od1.oe_field_meaning="COMBIDOSINGINGREDID"
    AND od1.oe_field_value != 0.0)
   JOIN (od2
   WHERE od2.order_id=od1.order_id
    AND od2.oe_field_meaning="STRENGTHDOSE"
    AND od2.oe_field_value != 0.0)
   JOIN (od3
   WHERE od3.order_id=od2.order_id
    AND od3.oe_field_meaning="STRENGTHDOSEUNIT"
    AND od3.oe_field_value != 0.0)
  HEAD REPORT
   reply->solcap[1].degree_of_use_num = numofcombinationmedswithstrengthdose
  WITH nocounter
 ;end select
 SET last_mod = "001"
 CALL echo(build("curdate",curdate))
END GO
