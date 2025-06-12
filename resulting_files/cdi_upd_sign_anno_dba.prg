CREATE PROGRAM cdi_upd_sign_anno:dba
 IF (validate(reply->status_data.status)=0)
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE rows_to_update_count = i4 WITH noconstant(0), public
 DECLARE req_size = i4 WITH noconstant(0), protect
 DECLARE num = i4 WITH noconstant(0), protect
 DECLARE itemp = i4 WITH noconstant(0), protect
 DECLARE inserted_rows = i4 WITH noconstant(0), protect
 DECLARE updated_rows = i4 WITH noconstant(0), protect
 DECLARE pos = i4 WITH noconstant(0), protect
 SET reply->status_data.status = "F"
 SET req_size = value(size(request->sign_anno_rec,5))
 IF (req_size > 0)
  SELECT INTO "NL:"
   c.event_prsnl_id
   FROM cdi_sign_anno c
   WHERE expand(num,1,req_size,c.event_prsnl_id,request->sign_anno_rec[num].event_prsnl_id)
   DETAIL
    rows_to_update_count = (rows_to_update_count+ 1), pos = locateval(itemp,1,req_size,c
     .event_prsnl_id,request->sign_anno_rec[itemp].event_prsnl_id), request->sign_anno_rec[pos].
    update_rec = 1
   WITH nocounter, forupdatewait(c)
  ;end select
  IF (rows_to_update_count > 0)
   UPDATE  FROM cdi_sign_anno c,
     (dummyt d  WITH seq = req_size)
    SET c.page_nbr = request->sign_anno_rec[d.seq].page_nbr, c.anno_valid_ind = request->
     sign_anno_rec[d.seq].anno_valid_ind, c.updt_cnt = (c.updt_cnt+ 1),
     c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_task = reqinfo->updt_task, c.updt_id =
     reqinfo->updt_id,
     c.updt_applctx = reqinfo->updt_applctx
    PLAN (d
     WHERE (request->sign_anno_rec[d.seq].update_rec=1))
     JOIN (c
     WHERE (c.event_prsnl_id=request->sign_anno_rec[d.seq].event_prsnl_id))
    WITH nocounter
   ;end update
   SET updated_rows = curqual
   IF (updated_rows < rows_to_update_count)
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
    GO TO exit_script
   ENDIF
  ENDIF
  IF (rows_to_update_count < req_size)
   INSERT  FROM cdi_sign_anno c,
     (dummyt d  WITH seq = req_size)
    SET c.cdi_sign_anno_id = seq(cdi_seq,nextval), c.event_prsnl_id = request->sign_anno_rec[d.seq].
     event_prsnl_id, c.page_nbr = request->sign_anno_rec[d.seq].page_nbr,
     c.anno_valid_ind = request->sign_anno_rec[d.seq].anno_valid_ind, c.updt_cnt = 0, c.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     c.updt_task = reqinfo->updt_task, c.updt_id = reqinfo->updt_id, c.updt_applctx = reqinfo->
     updt_applctx
    PLAN (d
     WHERE (request->sign_anno_rec[d.seq].update_rec=0))
     JOIN (c)
    WITH nocounter
   ;end insert
   SET inserted_rows = curqual
   IF (((inserted_rows+ updated_rows) < req_size))
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#exit_script
 IF ((reply->status_data.status != "S"))
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "cdi_upd_sign_anno"
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
