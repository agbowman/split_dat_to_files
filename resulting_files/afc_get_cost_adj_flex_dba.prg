CREATE PROGRAM afc_get_cost_adj_flex:dba
 RECORD reply(
   1 cost_adj_flex_qual = i4
   1 cost_adj_flex[*]
     2 cost_adj_flex_id = f8
     2 cost_adj_sched_id = f8
     2 parent_entity_id = f8
     2 parent_entity_name = vc
     2 min_charge_amt = f8
     2 description = vc
 )
 SET costadjcnt = 0
 SELECT INTO "nl:"
  caf.*, cs.*
  FROM cost_adj_flex caf,
   class_node cs
  PLAN (caf
   WHERE (caf.cost_adj_sched_id=request->cost_adj_sched_id))
   JOIN (cs
   WHERE cs.class_node_id=caf.parent_entity_id)
  DETAIL
   costadjcnt = (costadjcnt+ 1), reply->cost_adj_flex_qual = costadjcnt, stat = alterlist(reply->
    cost_adj_flex,costadjcnt),
   reply->cost_adj_flex[costadjcnt].cost_adj_flex_id = caf.cost_adj_flex_id, reply->cost_adj_flex[
   costadjcnt].cost_adj_sched_id = caf.cost_adj_sched_id, reply->cost_adj_flex[costadjcnt].
   parent_entity_id = caf.parent_entity_id,
   reply->cost_adj_flex[costadjcnt].parent_entity_name = caf.parent_entity_name, reply->
   cost_adj_flex[costadjcnt].min_charge_amt = caf.min_charge_amt, reply->cost_adj_flex[costadjcnt].
   description = cs.description
  WITH nocounter
 ;end select
END GO
