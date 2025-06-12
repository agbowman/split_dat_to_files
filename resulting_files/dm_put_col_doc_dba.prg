CREATE PROGRAM dm_put_col_doc:dba
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
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM dm_columns_doc dcd,
   (dummyt d  WITH seq = value(size(request->qual,5)))
  PLAN (d)
   JOIN (dcd
   WHERE (dcd.column_name=request->qual[d.seq].column_name)
    AND (dcd.table_name=request->qual[d.seq].table_name))
  DETAIL
   i = d.seq, ins_upd->qual[i].update_ind = 1
  WITH nocounter
 ;end select
 UPDATE  FROM dm_columns_doc dcd,
   (dummyt d  WITH seq = value(size(request->qual,5)))
  SET dcd.constant_value = request->qual[d.seq].constant_value, dcd.exception_flg = request->qual[d
   .seq].exception_flg, dcd.merge_updateable_ind = request->qual[d.seq].merge_updateable_ind,
   dcd.parent_entity_col = request->qual[d.seq].parent_entity_col, dcd.root_entity_attr = request->
   qual[d.seq].root_entity_attr, dcd.root_entity_name = request->qual[d.seq].root_entity_name,
   dcd.sequence_name = request->qual[d.seq].sequence_name, dcd.unique_ident_ind = request->qual[d.seq
   ].unique_ident_ind
  PLAN (d
   WHERE (ins_upd->qual[d.seq].update_ind=1))
   JOIN (dcd
   WHERE (dcd.column_name=request->qual[d.seq].column_name)
    AND (dcd.table_name=request->qual[d.seq].table_name))
  WITH nocounter
 ;end update
 INSERT  FROM dm_columns_doc dcd,
   (dummyt d  WITH seq = value(size(request->qual,5)))
  SET dcd.column_name = request->qual[d.seq].column_name, dcd.constant_value = request->qual[d.seq].
   constant_value, dcd.exception_flg = request->qual[d.seq].exception_flg,
   dcd.merge_updateable_ind = request->qual[d.seq].merge_updateable_ind, dcd.parent_entity_col =
   request->qual[d.seq].parent_entity_col, dcd.root_entity_attr = request->qual[d.seq].
   root_entity_attr,
   dcd.root_entity_name = request->qual[d.seq].root_entity_name, dcd.sequence_name = request->qual[d
   .seq].sequence_name, dcd.table_name = request->qual[d.seq].table_name,
   dcd.unique_ident_ind = request->qual[d.seq].unique_ident_ind
  PLAN (d
   WHERE (ins_upd->qual[d.seq].update_ind=0))
   JOIN (dcd)
  WITH nocounter
 ;end insert
 SET reply->status_data.status = "S"
 COMMIT
END GO
