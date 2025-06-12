CREATE PROGRAM afc_get_ps_for_ca:dba
 RECORD reply(
   1 price_sched_desc_qual = i4
   1 price_sched_desc[*]
     2 price_sched_id = f8
     2 price_sched_desc = vc
 )
 SET priceschedcnt = 0
 SELECT DISTINCT INTO "nl:"
  ps.*
  FROM price_schedule_adj psa,
   price_sched ps
  PLAN (psa
   WHERE (psa.cost_adj_sched_id=request->cost_adj_sched_id))
   JOIN (ps
   WHERE ps.price_sched_id=psa.price_sched_id
    AND ps.active_ind=1)
  DETAIL
   priceschedcnt = (priceschedcnt+ 1), reply->price_sched_desc_qual = priceschedcnt, stat = alterlist
   (reply->price_sched_desc,priceschedcnt),
   reply->price_sched_desc[priceschedcnt].price_sched_id = ps.price_sched_id, reply->
   price_sched_desc[priceschedcnt].price_sched_desc = ps.price_sched_desc
  WITH nocounter
 ;end select
END GO
