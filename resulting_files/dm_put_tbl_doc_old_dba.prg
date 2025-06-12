CREATE PROGRAM dm_put_tbl_doc_old:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD ins_upd(
   1 qual[*]
     2 update_ind = i4
 )
 SET stat = alterlist(ins_upd->qual,size(request->qual))
 SELECT INTO "nl:"
  FROM dm_tables_doc dcd,
   (dummyt d  WITH seq = value(size(request->qual,5)))
  PLAN (d)
   JOIN (dcd
   WHERE (dcd.table_name=request->qual[d.seq].table_name))
  DETAIL
   cnt = d.seq, ins_upd->qual[cnt].update_ind = 1
  WITH nocounter
 ;end select
 UPDATE  FROM dm_tables_doc dcd,
   (dummyt d  WITH seq = value(size(request->qual,5)))
  SET dcd.reference_ind = request->qual[d.seq].reference_ind, dcd.human_reqd_ind = request->qual[d
   .seq].human_reqd_ind
  PLAN (d
   WHERE (ins_upd->qual[d.seq].update_ind=1))
   JOIN (dcd
   WHERE (dcd.table_name=request->qual[d.seq].table_name))
  WITH nocounter
 ;end update
 INSERT  FROM dm_tables_doc dcd,
   (dummyt d  WITH seq = value(size(request->qual,5)))
  SET dcd.table_name = request->qual[d.seq].table_name, dcd.reference_ind = request->qual[d.seq].
   reference_ind, dcd.human_reqd_ind = request->qual[d.seq].human_reqd_ind
  PLAN (d
   WHERE (ins_upd->qual[d.seq].update_ind=0))
   JOIN (dcd)
  WITH nocounter
 ;end insert
 SET reply->status_data.status = "S"
 COMMIT
END GO
