CREATE PROGRAM afc_get_cost_adj:dba
 RECORD reply(
   1 cost_adj_qual = i4
   1 cost_adj[*]
     2 cost_adj_id = f8
     2 cost_adj_flex_id = f8
     2 lower_threshold = f8
     2 upper_threshold = f8
     2 adjustment_type = i2
     2 adjustment = f8
 )
 SET costadjcnt = 0
 SELECT DISTINCT INTO "nl:"
  ca.*
  FROM cost_adj ca
  WHERE (ca.cost_adj_flex_id=request->cost_adj_flex_id)
  ORDER BY ca.lower_threshold
  DETAIL
   costadjcnt = (costadjcnt+ 1), reply->cost_adj_qual = costadjcnt, stat = alterlist(reply->cost_adj,
    costadjcnt),
   reply->cost_adj[costadjcnt].cost_adj_flex_id = ca.cost_adj_flex_id, reply->cost_adj[costadjcnt].
   cost_adj_id = ca.cost_adj_id, reply->cost_adj[costadjcnt].lower_threshold = ca.lower_threshold,
   reply->cost_adj[costadjcnt].upper_threshold = ca.upper_threshold, reply->cost_adj[costadjcnt].
   adjustment_type = ca.adjustment_type_flag, reply->cost_adj[costadjcnt].adjustment = ca
   .adjustment_amt
  WITH nocounter
 ;end select
END GO
