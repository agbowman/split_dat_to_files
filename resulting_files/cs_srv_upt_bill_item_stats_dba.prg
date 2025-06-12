CREATE PROGRAM cs_srv_upt_bill_item_stats:dba
 CALL echo(concat("CS_SRV_UPT_BILL_ITEM_STATS - ",format(curdate,"MMM DD, YYYY;;D"),format(curtime3,
    " - HH:MM:SS;;S")))
 IF ((g_srvproperties->logreqrep=1))
  CALL echorecord(request)
 ENDIF
 SET reply->status_data.status = "S"
 RECORD cur_stats(
   1 items[*]
     2 bill_item_id = f8
     2 num_hits = f8
 )
 SET billcnt = size(request->bill_stats,5)
 SET stat = alterlist(cur_stats->items,billcnt)
 CALL echo("Read current num_hits for each bill item")
 SELECT INTO "nl:"
  b.num_hits
  FROM bill_item b,
   (dummyt d  WITH seq = value(billcnt))
  PLAN (d)
   JOIN (b
   WHERE (b.bill_item_id=request->bill_stats[d.seq].bill_item_id))
  DETAIL
   cur_stats->items[d.seq].bill_item_id = request->bill_stats[d.seq].bill_item_id, cur_stats->items[d
   .seq].num_hits = b.num_hits
  WITH nocounter
 ;end select
 CALL echo("Update num_hits")
 UPDATE  FROM bill_item b,
   (dummyt d  WITH seq = value(billcnt))
  SET b.num_hits = (cur_stats->items[d.seq].num_hits+ request->bill_stats[d.seq].num_hits)
  PLAN (d)
   JOIN (b
   WHERE (b.bill_item_id=request->bill_stats[d.seq].bill_item_id))
  WITH nocounter
 ;end update
 COMMIT
 IF ((g_srvproperties->logreqrep=1))
  CALL echorecord(reply)
 ENDIF
END GO
