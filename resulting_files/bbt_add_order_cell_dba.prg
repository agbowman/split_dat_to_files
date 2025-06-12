CREATE PROGRAM bbt_add_order_cell:dba
 RECORD reply(
   1 qualreply[*]
     2 cell_cd = f8
     2 product_id = f8
     2 order_cell_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET nbr_to_add = size(request->qual,5)
 SET y = 0
 SET idx = 0
 SET failed = "F"
 SET d_cnt = 0
 SET d_cnt = 0
 FOR (idx = 1 TO nbr_to_add)
  SELECT INTO "nl:"
   seqn = seq(pathnet_seq,nextval)
   FROM dual
   DETAIL
    d_cnt += 1, stat = alterlist(reply->qualreply,d_cnt), reply->qualreply[d_cnt].order_cell_id =
    seqn,
    reply->qualreply[d_cnt].cell_cd = request->qual[idx].cell_cd, reply->qualreply[d_cnt].product_id
     = request->qual[idx].product_id
   WITH format, nocounter
  ;end select
  IF (curqual=0)
   GO TO row_failed
  ENDIF
 ENDFOR
 INSERT  FROM bb_order_cell o,
   (dummyt d1  WITH seq = value(d_cnt))
  SET o.order_cell_id = reply->qualreply[d1.seq].order_cell_id, o.order_id = request->order_id, o
   .cell_cd = request->qual[d1.seq].cell_cd,
   o.product_id = request->qual[d1.seq].product_id, o.bb_result_id = 0, o.updt_cnt = 0,
   o.updt_dt_tm = cnvtdatetime(sysdate), o.updt_id = reqinfo->updt_id, o.updt_task = reqinfo->
   updt_task,
   o.updt_applctx = reqinfo->updt_applctx
  PLAN (d1)
   JOIN (o)
  WITH counter
 ;end insert
 IF (curqual=0)
  SET y += 1
  IF (y > 1)
   SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
  ENDIF
  SET reply->status_data.subeventstatus[y].operationname = "insert"
  SET reply->status_data.subeventstatus[y].operationstatus = "F"
  SET reply->status_data.subeventstatus[y].targetobjectname = "order_cell"
  SET reply->status_data.subeventstatus[y].targetobjectvalue = cnvtstring(request->qual[idx].cell_cd,
   32,2)
  SET failed = "T"
  GO TO row_failed
 ENDIF
#row_failed
 IF (failed="T")
  SET reply->status_data.status = "Z"
  SET reply->status_data.operationname = "add"
  SET reply->status_data.operationstatus = "F"
  SET reply->status_data.targetobjectname = "order_cell"
  SET reply->status_data.targetobjectvalue = "order_cell not added"
  SET stat = alterlist(reply->qualreply,1)
  SET reqinfo->commit_ind = 0
  GO TO end_script
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
#end_script
END GO
