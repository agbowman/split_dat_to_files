CREATE PROGRAM bbd_chg_proc_bagtype_prod:dba
 RECORD reply(
   1 qual[*]
     2 proc_bag_product_id = f8
     2 product_cd = f8
     2 row_number = i4
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
 RECORD prod(
   1 product_id = f8
   1 updt_cnt = i4
 )
 DECLARE check_rec_exist() = i2
 DECLARE insert_rec() = null
 DECLARE update_rec() = null
 SET count1 = 0
 SET y = 0
 SET product_id = 0.0
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET found_rec = 0
 FOR (y = 1 TO request->product_count)
   IF ((request->qual[y].add_row=1))
    SET found_rec = check_rec_exist(null)
    IF (found_rec > 0)
     CALL update_rec(null)
    ELSE
     CALL insert_rec(null)
    ENDIF
   ELSE
    CALL update_rec(null)
   ENDIF
 ENDFOR
 FREE SET prod
 SUBROUTINE check_rec_exist(null)
  SELECT INTO "nl:"
   p.proc_bag_product_id, p.updt_cnt
   FROM proc_bag_product_r p
   WHERE (request->procedure_cd=p.procedure_cd)
    AND (request->bag_type_cd=p.bag_type_cd)
    AND (request->qual[y].product_cd=p.product_cd)
   DETAIL
    request->qual[y].proc_bag_product_id = p.proc_bag_product_id, request->qual[y].updt_cnt = p
    .updt_cnt
   WITH counter
  ;end select
  RETURN(curqual)
 END ;Subroutine
 SUBROUTINE insert_rec(null)
   SET new_pathnet_seq = 0.0
   SELECT INTO "nl:"
    seqn = seq(pathnet_seq,nextval)"###########################;rp0"
    FROM dual
    DETAIL
     new_pathnet_seq = cnvtint(seqn)
    WITH format, nocounter
   ;end select
   SET product_id = new_pathnet_seq
   INSERT  FROM proc_bag_product_r p
    SET p.proc_bag_product_id = product_id, p.procedure_cd = request->procedure_cd, p.bag_type_cd =
     request->bag_type_cd,
     p.product_cd = request->qual[y].product_cd, p.default_expire_days = request->qual[y].
     default_expire_days, p.default_expire_hours = request->qual[y].default_expire_hours,
     p.active_type_cd =
     IF ((request->qual[y].active_ind=1)) reqdata->active_status_cd
     ELSE reqdata->inactive_status_cd
     ENDIF
     , p.active_ind = request->qual[y].active_ind, p.active_dt_tm =
     IF ((request->qual[y].active_ind=1)) cnvtdatetime(curdate,curtime3)
     ELSE null
     ENDIF
     ,
     p.active_status_prsnl_id =
     IF ((request->qual[y].active_ind=1)) reqinfo->updt_id
     ELSE 0
     ENDIF
     , p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id = reqinfo->updt_id,
     p.updt_cnt = 0, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx,
     p.create_dt_tm = cnvtdatetime(curdate,curtime3)
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET failed = "T"
    SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
    SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_proc_bagtype_prod"
    SET reply->status_data.subeventstatus[1].operationname = "insert"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "proc_bag_product_r"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "product insert"
    SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
    SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
    GO TO exit_script
   ELSE
    SET stat = alterlist(reply->qual,y)
    SET reply->qual[y].proc_bag_product_id = product_id
    SET reply->qual[y].product_cd = request->qual[y].product_cd
    SET reply->qual[y].row_number = request->qual[y].row_number
    SET reply->qual[y].updt_cnt = 0
   ENDIF
   RETURN
 END ;Subroutine
 SUBROUTINE update_rec(null)
   SELECT INTO "nl:"
    p.*
    FROM proc_bag_product_r p
    WHERE (p.proc_bag_product_id=request->qual[y].proc_bag_product_id)
     AND (p.updt_cnt=request->qual[y].updt_cnt)
    WITH counter, forupdate(p)
   ;end select
   IF (curqual=0)
    SET failed = "T"
    SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
    SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_proc_bagtype_prod"
    SET reply->status_data.subeventstatus[1].operationname = "lock"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "proc_bag_product_r"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "product lock"
    SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
    SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
    GO TO exit_script
   ENDIF
   UPDATE  FROM proc_bag_product_r p
    SET p.default_expire_days = request->qual[y].default_expire_days, p.default_expire_hours =
     request->qual[y].default_expire_hours, p.active_type_cd =
     IF ((request->qual[y].active_ind=1)) reqdata->active_status_cd
     ELSE reqdata->inactive_status_cd
     ENDIF
     ,
     p.active_ind = request->qual[y].active_ind, p.active_dt_tm =
     IF ((request->qual[y].active_ind=1)) cnvtdatetime(curdate,curtime3)
     ELSE null
     ENDIF
     , p.active_status_prsnl_id =
     IF ((request->qual[y].active_ind=1)) reqinfo->updt_id
     ELSE 0
     ENDIF
     ,
     p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id = reqinfo->updt_id, p.updt_cnt = (
     request->qual[y].updt_cnt+ 1),
     p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx
    WHERE (p.proc_bag_product_id=request->qual[y].proc_bag_product_id)
     AND (p.updt_cnt=request->qual[y].updt_cnt)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET failed = "T"
    SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
    SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_chg_proc_bagtype_prod"
    SET reply->status_data.subeventstatus[1].operationname = "update"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "proc_bag_product_r"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "proc_bag_product_r"
    SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
    SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
    GO TO exit_script
   ELSE
    SET stat = alterlist(reply->qual,y)
    SET reply->qual[y].proc_bag_product_id = request->qual[y].proc_bag_product_id
    SET reply->qual[y].product_cd = request->qual[y].product_cd
    SET reply->qual[y].row_number = request->qual[y].row_number
    SET reply->qual[y].updt_cnt = (request->qual[y].updt_cnt+ 1)
   ENDIF
   RETURN
 END ;Subroutine
#exit_script
 IF (failed="T")
  ROLLBACK
  SET reply->status_data.status = "F"
 ELSE
  COMMIT
  SET reply->status_data.status = "S"
 ENDIF
END GO
