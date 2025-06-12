CREATE PROGRAM dm_env_mrg_order:dba
 RECORD reply(
   1 qual[*]
     2 table_name = c40
     2 order_index = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD work(
   1 qual[*]
     2 table_name = c40
     2 order_index = i4
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET tbl_seq = 0
 SET stat = alterlist(reply->qual,request->list_qual)
 SET stat = alterlist(work->qual,request->list_qual)
 FOR (cnt = 1 TO request->list_qual)
   SELECT INTO "nl:"
    d.child_table, xx = max(d.sequence)
    FROM dm_table_tree d
    WHERE (d.child_table=request->qual[cnt].entity_name)
    GROUP BY d.child_table
    DETAIL
     tbl_seq = xx
    WITH nocounter
   ;end select
   SET work->qual[cnt].table_name = request->qual[cnt].entity_name
   IF (curqual=0)
    SET work->qual[cnt].order_index = 1
   ELSE
    SET work->qual[cnt].order_index = tbl_seq
   ENDIF
   IF ((work->qual[cnt].table_name="CODE_VALUE"))
    SET work->qual[cnt].order_index = 0
   ENDIF
 ENDFOR
 SET nbr_of_records = request->list_qual
 SET cnt = 0
 SELECT INTO "nl:"
  tbl_name = work->qual[d.seq].table_name, ord_index = work->qual[d.seq].order_index
  FROM (dummyt d  WITH seq = value(nbr_of_records))
  ORDER BY ord_index
  DETAIL
   cnt = (cnt+ 1), reply->qual[cnt].table_name = work->qual[d.seq].table_name, reply->qual[cnt].
   order_index = work->qual[d.seq].order_index
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
END GO
