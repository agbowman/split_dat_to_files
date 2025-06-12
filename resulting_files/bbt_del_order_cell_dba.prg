CREATE PROGRAM bbt_del_order_cell:dba
 RECORD reply(
   1 all_cells_deleted = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET reply->all_cells_deleted = "N"
 SET failed = "F"
 DELETE  FROM bb_order_cell o
  WHERE (o.order_cell_id=request->order_cell_id)
  WITH nocounter
 ;end delete
 IF (curqual=0)
  SET reply->status_data.operationname = "delete"
  SET reply->status_data.operationstatus = "F"
  SET reply->status_data.targetobjectname = "order_cell"
  SET reply->status_data.targetobjectvalue = "Unable to remove product/cell from bb order cell"
  SET failed = "T"
  GO TO row_failed
 ENDIF
 SELECT INTO "nl:"
  o.order_id
  FROM bb_order_cell o
  WHERE (o.order_id=request->order_id)
 ;end select
 IF (curqual=0)
  SET reply->all_cells_deleted = "Y"
 ENDIF
#row_failed
 IF (failed="T")
  SET reqinfo->commit_ind = 0
  GO TO end_script
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
#end_script
END GO
