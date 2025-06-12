CREATE PROGRAM cdi_add_clipboard_items:dba
 RECORD reply(
   1 pages[*]
     2 cdi_clipboard_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD m_dm2_seq_stat(
   1 n_status = i4
   1 s_error_msg = vc
 ) WITH protect
 DECLARE count = i4 WITH noconstant(0), protect
 DECLARE new_rows = i4 WITH noconstant(value(size(request->pages,5))), protect
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 IF (new_rows > 0)
  SET stat = alterlist(reply->pages,new_rows)
  EXECUTE dm2_dar_get_bulk_seq "reply->pages", new_rows, "cdi_clipboard_id",
  1, "CDI_SEQ"
  INSERT  FROM (dummyt d  WITH seq = new_rows),
    cdi_clipboard c
   SET c.cdi_clipboard_id = reply->pages[d.seq].cdi_clipboard_id, c.object_file = request->pages[d
    .seq].object_file, c.anno_file = request->pages[d.seq].anno_file,
    c.copy_dt_tm = cnvtdatetime(request->pages[d.seq].copy_dt_tm), c.media_object_file_ident =
    request->pages[d.seq].media_object_file_ident, c.media_object_anno_ident = request->pages[d.seq].
    media_object_anno_ident,
    c.copy_user_id = request->copy_user_id, c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = 0,
    c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_id = reqinfo->updt_id, c.updt_task =
    reqinfo->updt_task
   PLAN (d)
    JOIN (c)
   WITH nocounter
  ;end insert
 ENDIF
 IF (curqual=new_rows)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET stat = alterlist(reply->pages,0)
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
