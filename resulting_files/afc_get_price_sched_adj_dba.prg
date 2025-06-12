CREATE PROGRAM afc_get_price_sched_adj:dba
 RECORD reply(
   1 cost_adj_sched_qual = i4
   1 cost_adj_sched[*]
     2 cost_adj_sched_id = f8
     2 cost_adj_sched_desc = vc
     2 price_sched_adj_id = f8
 )
 SET costadjcnt = 0
 SELECT DISTINCT INTO "nl:"
  psa.*, cas.*
  FROM price_schedule_adj psa,
   cost_adj_sched cas
  PLAN (psa
   WHERE (psa.price_sched_id=request->price_sched_id))
   JOIN (cas
   WHERE cas.cost_adj_sched_id=psa.cost_adj_sched_id)
  DETAIL
   costadjcnt = (costadjcnt+ 1), reply->cost_adj_sched_qual = costadjcnt, stat = alterlist(reply->
    cost_adj_sched,costadjcnt),
   reply->cost_adj_sched[costadjcnt].price_sched_adj_id = psa.price_sched_adj_id, reply->
   cost_adj_sched[costadjcnt].cost_adj_sched_id = psa.cost_adj_sched_id, reply->cost_adj_sched[
   costadjcnt].cost_adj_sched_desc = cas.description
  WITH nocounter
 ;end select
END GO
