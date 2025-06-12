CREATE PROGRAM afc_get_cost_adj_sched:dba
 RECORD reply(
   1 cost_adj_desc_qual = i4
   1 cost_adj_desc[*]
     2 cost_adj_sched_id = f8
     2 description = vc
 )
 SET costadjcnt = 0
 CASE (request->select_type)
  OF "ALL":
   SELECT DISTINCT INTO "nl:"
    cas.*
    FROM cost_adj_sched cas
    DETAIL
     costadjcnt = (costadjcnt+ 1), reply->cost_adj_desc_qual = costadjcnt, stat = alterlist(reply->
      cost_adj_desc,costadjcnt),
     reply->cost_adj_desc[costadjcnt].cost_adj_sched_id = cas.cost_adj_sched_id, reply->
     cost_adj_desc[costadjcnt].description = cas.description
    WITH nocounter
   ;end select
  OF "RNG":
   SELECT DISTINCT INTO "nl:"
    cas.*
    FROM cost_adj_sched cas
    WHERE (cas.cost_adj_sched_id=requst->cost_adj_sched_id)
    DETAIL
     costadjcnt = (costadjcnt+ 1), reply->cost_adj_desc_qual = costadjcnt, stat = alterlist(reply->
      cost_adj_desc,costadjcnt),
     reply->cost_adj_desc[costadjcnt].cost_adj_sched_id = cas.cost_adj_sched_id, reply->
     cost_adj_desc[costadjcnt].description = cas.description
    WITH nocounter
   ;end select
 ENDCASE
END GO
