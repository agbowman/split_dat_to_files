CREATE PROGRAM bbd_chg_proc_bagtype_rel:dba
 RECORD reply(
   1 qual[*]
     2 procedure_bag_type_id = f8
     2 procedure_cd = f8
     2 bag_type_cd = f8
     2 updt_cnt = i4
     2 add_row = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c15
       3 sourceobjectqual = i4
       3 sourceobjectvalue = c50
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c50
       3 sub_event_dt_tm = di8
 )
 SET y = 0
 SET proc_id = 0.0
 SET reply->status_data.status = "F"
 SET failed = "F"
 FOR (y = 1 TO request->bagtype_cnt)
   IF ((request->qual[y].add_row=1))
    SET new_pathnet_seq = 0.0
    SELECT INTO "nl:"
     seqn = seq(pathnet_seq,nextval)"###########################;rp0"
     FROM dual
     DETAIL
      new_pathnet_seq = cnvtint(seqn)
     WITH format, nocounter
    ;end select
    SET proc_id = new_pathnet_seq
    INSERT  FROM procedure_bag_type_r p
     SET p.procedure_bag_type_id = proc_id, p.procedure_cd = request->procedure_cd, p.bag_type_cd =
      request->qual[y].bag_type_cd,
      p.active_type_cd = reqdata->active_status_cd, p.active_ind = 1, p.active_dt_tm = cnvtdatetime(
       curdate,curtime3),
      p.active_status_prsnl_id = reqinfo->updt_id, p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p
      .updt_id = reqinfo->updt_id,
      p.updt_cnt = 0, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx,
      p.create_dt_tm = cnvtdatetime(curdate,curtime3)
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET failed = "T"
     SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
     SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_proc_bagtype_rel"
     SET reply->status_data.subeventstatus[1].operationname = "insert"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "procedure_bag_type_r"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "procedure bag type insert"
     SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
     SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
     GO TO exit_script
    ELSE
     SET stat = alterlist(reply->qual,y)
     SET reply->qual[y].procedure_bag_type_id = proc_id
     SET reply->qual[y].procedure_cd = request->procedure_cd
     SET reply->qual[y].bag_type_cd = request->qual[y].bag_type_cd
     SET reply->qual[y].updt_cnt = 0
     SET reply->qual[y].add_row = 1
    ENDIF
   ELSE
    SELECT INTO "nl:"
     p.*
     FROM procedure_bag_type_r p
     WHERE (p.procedure_bag_type_id=request->qual[y].procedure_bag_type_id)
      AND (p.updt_cnt=request->qual[y].updt_cnt)
     WITH counter, forupdate(p)
    ;end select
    IF (curqual=0)
     SET failed = "T"
     SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
     SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_proc_bagtype_rel"
     SET reply->status_data.subeventstatus[1].operationname = "lock"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "procedure_bag_type_r"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "procedure bag type lock"
     SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
     SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
     GO TO exit_script
    ENDIF
    UPDATE  FROM procedure_bag_type_r p
     SET p.active_type_cd = reqdata->inactive_status_cd, p.active_ind = 0, p.updt_dt_tm =
      cnvtdatetime(curdate,curtime3),
      p.updt_id = reqinfo->updt_id, p.updt_cnt = (request->qual[y].updt_cnt+ 1), p.updt_task =
      reqinfo->updt_task,
      p.updt_applctx = reqinfo->updt_applctx
     WHERE (p.procedure_bag_type_id=request->qual[y].procedure_bag_type_id)
      AND (p.updt_cnt=request->qual[y].updt_cnt)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET failed = "T"
     SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
     SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_proc_bagtype_rel"
     SET reply->status_data.subeventstatus[1].operationname = "update"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "procedure_bag_type_r"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "procedure bag type insert"
     SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
     SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
     GO TO exit_script
    ELSE
     SET stat = alterlist(reply->qual,y)
     SET reply->qual[y].procedure_bag_type_id = request->qual[y].procedure_bag_type_id
     SET reply->qual[y].procedure_cd = request->procedure_cd
     SET reply->qual[y].bag_type_cd = request->qual[y].bag_type_cd
     SET reply->qual[y].updt_cnt = (request->qual[y].updt_cnt+ 1)
     SET reply->qual[y].add_row = 0
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF (failed="T")
  ROLLBACK
  SET reply->status_data.status = "F"
 ELSE
  COMMIT
  SET reply->status_data.status = "S"
 ENDIF
END GO
