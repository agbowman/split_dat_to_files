CREATE PROGRAM bbd_chg_proc_outcomes:dba
 RECORD reply(
   1 qual[*]
     2 procedure_outcome_id = f8
     2 outcome_cd = f8
     2 row_number = i2
     2 updt_cnt = i4
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
 SET count1 = 0
 SET y = 0
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET outcome_id = 0.0
 FOR (y = 1 TO request->outcome_count)
   IF ((request->qual[y].add_row=1))
    SET new_pathnet_seq = 0.0
    SELECT INTO "nl:"
     seqn = seq(pathnet_seq,nextval)"###########################;rp0"
     FROM dual
     DETAIL
      new_pathnet_seq = cnvtint(seqn)
     WITH format, nocounter
    ;end select
    SET outcome_id = new_pathnet_seq
    INSERT  FROM procedure_outcome_r p
     SET p.procedure_outcome_id = outcome_id, p.procedure_cd = request->procedure_cd, p.outcome_cd =
      request->qual[y].outcome_cd,
      p.order_processing_ind = request->qual[y].order_processing_ind, p.count_as_donation_ind =
      request->qual[y].count_as_donation_ind, p.add_product_ind = request->qual[y].add_product_ind,
      p.synonym_id = request->qual[y].synonym_id, p.active_ind = request->qual[y].active_ind, p
      .active_type_cd =
      IF ((request->qual[y].active_ind=1)) reqdata->active_status_cd
      ELSE reqdata->inactive_status_cd
      ENDIF
      ,
      p.active_dt_tm =
      IF ((request->qual[y].active_ind=1)) cnvtdatetime(curdate,curtime3)
      ELSE null
      ENDIF
      , p.inactive_dt_tm =
      IF ((request->qual[y].active_ind=0)) cnvtdatetime(curdate,curtime3)
      ELSE null
      ENDIF
      , p.active_status_prsnl_id =
      IF ((request->qual[y].active_ind=1)) reqinfo->updt_id
      ELSE 0
      ENDIF
      ,
      p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id = reqinfo->updt_id, p.updt_cnt = 0,
      p.updt_task = reqinfo->updt_task, p.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), p
      .updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET failed = "T"
     SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
     SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_proc_outcomes"
     SET reply->status_data.subeventstatus[1].operationname = "insert"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "procedure outcome r"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "procedure_outcome_r"
     SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
     SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
     GO TO exit_script
    ELSE
     SET stat = alterlist(reply->qual,y)
     SET reply->qual[y].procedure_outcome_id = outcome_id
     SET reply->qual[y].outcome_cd = request->qual[y].outcome_cd
     SET reply->qual[y].row_number = request->qual[y].row_number
     SET reply->qual[y].updt_cnt = 0
    ENDIF
   ELSE
    SELECT INTO "nl:"
     p.*
     FROM procedure_outcome_r p
     WHERE (p.procedure_outcome_id=request->qual[y].procedure_outcome_id)
      AND (p.updt_cnt=request->qual[y].updt_cnt)
     WITH counter, forupdate(p)
    ;end select
    IF (curqual=0)
     SET failed = "T"
     SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
     SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_proc_outcomes"
     SET reply->status_data.subeventstatus[1].operationname = "lock"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "procedure outcome"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "procedure_outcome"
     SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
     SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
     GO TO exit_script
    ENDIF
    UPDATE  FROM procedure_outcome_r p
     SET p.procedure_outcome_id = request->qual[y].procedure_outcome_id, p.procedure_cd = request->
      procedure_cd, p.outcome_cd = request->qual[y].outcome_cd,
      p.order_processing_ind = request->qual[y].order_processing_ind, p.count_as_donation_ind =
      request->qual[y].count_as_donation_ind, p.add_product_ind = request->qual[y].add_product_ind,
      p.synonym_id = request->qual[y].synonym_id, p.active_ind = request->qual[y].active_ind, p
      .active_type_cd =
      IF ((request->qual[y].active_ind=1)) reqdata->active_status_cd
      ELSE reqdata->inactive_status_cd
      ENDIF
      ,
      p.active_dt_tm =
      IF ((request->qual[y].active_ind=1)) cnvtdatetime(curdate,curtime3)
      ELSE null
      ENDIF
      , p.inactive_dt_tm =
      IF ((request->qual[y].active_ind=0)) cnvtdatetime(curdate,curtime3)
      ELSE null
      ENDIF
      , p.active_status_prsnl_id =
      IF ((request->qual[y].active_ind=1)) reqinfo->updt_id
      ELSE 0
      ENDIF
      ,
      p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id = reqinfo->updt_id, p.updt_cnt = (
      request->qual[y].updt_cnt+ 1),
      p.updt_task = reqinfo->updt_task, p.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), p
      .updt_applctx = reqinfo->updt_applctx
     WHERE (p.procedure_outcome_id=request->qual[y].procedure_outcome_id)
      AND (p.updt_cnt=request->qual[y].updt_cnt)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET failed = "T"
     SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
     SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_proc_outcomes"
     SET reply->status_data.subeventstatus[1].operationname = "update"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "procedure outcome r"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "procedure outcome r"
     SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
     SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
     GO TO exit_script
    ELSE
     SET stat = alterlist(reply->qual,y)
     SET reply->qual[y].procedure_outcome_id = request->qual[y].procedure_outcome_id
     SET reply->qual[y].outcome_cd = request->qual[y].outcome_cd
     SET reply->qual[y].row_number = request->qual[y].row_number
     SET reply->qual[y].updt_cnt = (request->qual[y].updt_cnt+ 1)
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
