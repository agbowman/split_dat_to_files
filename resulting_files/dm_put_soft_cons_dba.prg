CREATE PROGRAM dm_put_soft_cons:dba
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
 SET stat = alterlist(ins_upd->qual,size(request->qual,5))
 SELECT INTO "NL:"
  a.child_column, a.child_table, a.child_where,
  a.parent_column, a.parent_table
  FROM dm_soft_constraints a,
   (dummyt d  WITH seq = value(size(request->qual,5)))
  PLAN (d)
   JOIN (a
   WHERE (a.parent_table=request->qual[d.seq].parent_table)
    AND (a.child_table=request->qual[d.seq].child_table)
    AND (a.child_column=request->qual[d.seq].child_column))
  DETAIL
   cnt = d.seq, ins_upd->qual[cnt].update_ind = 1
  WITH nocounter
 ;end select
 UPDATE  FROM dm_soft_constraints dsc,
   (dummyt d  WITH seq = value(size(request->qual,5)))
  SET dsc.child_where = request->qual[d.seq].child_where, dsc.parent_column = request->qual[d.seq].
   parent_column
  PLAN (d
   WHERE (ins_upd->qual[d.seq].update_ind=1))
   JOIN (dsc
   WHERE (dsc.parent_table=request->qual[d.seq].parent_table)
    AND (dsc.child_table=request->qual[d.seq].child_table)
    AND (dsc.child_column=request->qual[d.seq].child_column))
  WITH nocounter
 ;end update
 INSERT  FROM dm_soft_constraints dsc,
   (dummyt d  WITH seq = value(size(request->qual,5)))
  SET dsc.child_column = request->qual[d.seq].child_column, dsc.child_table = request->qual[d.seq].
   child_table, dsc.child_where = request->qual[d.seq].child_where,
   dsc.parent_column = request->qual[d.seq].parent_column, dsc.parent_table = request->qual[d.seq].
   parent_table
  PLAN (d
   WHERE (ins_upd->qual[d.seq].update_ind=0))
   JOIN (dsc)
  WITH nocounter
 ;end insert
 SET reply->status_data.status = "S"
 COMMIT
END GO
