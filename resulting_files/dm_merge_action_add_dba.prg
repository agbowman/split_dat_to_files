CREATE PROGRAM dm_merge_action_add:dba
 RECORD reply(
   1 qual[*]
     2 from_rowid = vc
     2 merge_id = f8
     2 old_merge_id = f8
     2 row_index = i4
     2 target_rowid = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c15
       3 sourceobjectqual = i4
       3 sourceobjectvalue = c50
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c50
       3 sub_event_dt_tm = di8
 )
 SET reply->status_data.status = "F"
 SET stat = alterlist(reply->qual,size(request->qual,5))
 FOR (icnt = 1 TO size(request->qual,5))
   SELECT INTO "nl:"
    d.*, y = seq(dm_merge_seq,nextval)
    FROM dual d
    DETAIL
     reply->qual[icnt].merge_id = y
    WITH nocounter
   ;end select
   SET reply->qual[icnt].row_index = request->qual[icnt].row_index
   SET reply->qual[icnt].target_rowid = request->qual[icnt].to_rowid
 ENDFOR
 UPDATE  FROM dm_merge_action dma,
   (dummyt d  WITH seq = value(size(request->qual,5)))
  SET dma.active_ind = 0
  PLAN (d)
   JOIN (dma
   WHERE (dma.from_rowid=request->qual[d.seq].from_rowid))
  WITH nocounter, outerjoin = d
 ;end update
 INSERT  FROM dm_merge_action dma,
   (dummyt d  WITH seq = value(size(request->qual,5)))
  SET dma.active_ind = 1, dma.to_rowid =
   IF (trim(request->qual[d.seq].to_rowid)=null) null
   ELSE request->qual[d.seq].to_rowid
   ENDIF
   , dma.ref_domain_name = request->ref_domain_name,
   dma.table_name = request->table_name, dma.db_link = "LOC_MRG_LINK", dma.merge_status_flag = 7,
   dma.merge_id = reply->qual[d.seq].merge_id, dma.from_value = request->qual[d.seq].from_value, dma
   .to_value = request->qual[d.seq].to_value,
   dma.from_rowid = request->qual[d.seq].from_rowid, dma.env_source_id = request->env_source_id, dma
   .env_target_id = request->env_target_id,
   dma.merge_dt_tm = cnvtdatetime(curdate,curtime3), dma.code_set = request->code_set, dma.master_ind
    = request->master_ind,
   dma.audit_ind = request->audit_ind
  PLAN (d
   WHERE (reply->qual[d.seq].old_merge_id=0))
   JOIN (dma
   WHERE (reply->qual[d.seq].merge_id=dma.merge_id))
  WITH nocounter, outerjoin = d
 ;end insert
 SET reply->status_data.status = "S"
 COMMIT
END GO
