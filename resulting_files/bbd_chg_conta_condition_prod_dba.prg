CREATE PROGRAM bbd_chg_conta_condition_prod:dba
 RECORD reply(
   1 qual[*]
     2 contnr_type_prod_id = f8
     2 product_cd = f8
     2 quantity = i4
     2 row_number = i4
     2 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c30
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c30
       3 targetobjectvalue = vc
       3 sourceobjectqual = i4
 )
 SET count1 = 0
 SET y = 0
 SET product_id = 0.0
 SET reply->status_data.status = "F"
 SET failed = "F"
 FOR (y = 1 TO request->product_count)
   IF ((request->qual[y].add_row=1))
    DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
    SET new_pathnet_seq = 0
    SELECT INTO "nl:"
     seqn = seq(pathnet_seq,nextval)
     FROM dual
     DETAIL
      new_pathnet_seq = seqn
     WITH format, nocounter
    ;end select
    SET product_id = new_pathnet_seq
    INSERT  FROM contnr_type_prod_r p
     SET p.contnr_type_prod_id = product_id, p.container_condition_id = request->
      container_condition_id, p.product_cd = request->qual[y].product_cd,
      p.quantity = request->qual[y].quantity, p.active_ind = request->qual[y].active_ind, p
      .active_status_cd =
      IF ((request->qual[y].active_ind=1)) reqdata->active_status_cd
      ELSE reqdata->inactive_status_cd
      ENDIF
      ,
      p.active_status_dt_tm =
      IF ((request->qual[y].active_ind=1)) cnvtdatetime(curdate,curtime3)
      ELSE null
      ENDIF
      , p.active_status_prsnl_id =
      IF ((request->qual[y].active_ind=1)) reqinfo->updt_id
      ELSE null
      ENDIF
      , p.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      p.updt_id = reqinfo->updt_id, p.updt_cnt = 0, p.updt_task = reqinfo->updt_task,
      p.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET failed = "T"
     SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
     SET reply->status_data.subeventstatus[1].operationname = "insert"
     SET reply->status_data.subeventstatus[1].targetobjectname = "contnr_type_prod_r"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "product insert"
     SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
     GO TO exit_script
    ELSE
     SET stat = alterlist(reply->qual,y)
     SET reply->qual[y].contnr_type_prod_id = product_id
     SET reply->qual[y].product_cd = request->qual[y].product_cd
     SET reply->qual[y].quantity = request->qual[y].quantity
     SET reply->qual[y].row_number = request->qual[y].row_number
     SET reply->qual[y].updt_cnt = 0
    ENDIF
   ELSE
    SELECT INTO "nl:"
     p.*
     FROM contnr_type_prod_r p
     WHERE (p.contnr_type_prod_id=request->qual[y].contnr_type_prod_id)
      AND (p.updt_cnt=request->qual[y].updt_cnt)
     WITH counter, forupdate(p)
    ;end select
    IF (curqual=0)
     SET failed = "T"
     SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
     SET reply->status_data.subeventstatus[1].operationname = "lock"
     SET reply->status_data.subeventstatus[1].targetobjectname = "contnr_type_prod_r"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "product lock"
     SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
     GO TO exit_script
    ENDIF
    UPDATE  FROM contnr_type_prod_r p
     SET p.quantity = request->qual[y].quantity, p.active_status_cd =
      IF ((request->qual[y].active_ind=1)) reqdata->active_status_cd
      ELSE reqdata->inactive_status_cd
      ENDIF
      , p.active_ind = request->qual[y].active_ind,
      p.active_status_dt_tm =
      IF ((request->qual[y].active_ind=1)) cnvtdatetime(curdate,curtime3)
      ELSE null
      ENDIF
      , p.active_status_prsnl_id =
      IF ((request->qual[y].active_ind=1)) reqinfo->updt_id
      ELSE 0
      ENDIF
      , p.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      p.updt_id = reqinfo->updt_id, p.updt_cnt = (request->qual[y].updt_cnt+ 1), p.updt_task =
      reqinfo->updt_task,
      p.updt_applctx = reqinfo->updt_applctx
     WHERE (p.contnr_type_prod_id=request->qual[y].contnr_type_prod_id)
      AND (p.updt_cnt=request->qual[y].updt_cnt)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET failed = "T"
     SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
     SET reply->status_data.subeventstatus[1].operationname = "update"
     SET reply->status_data.subeventstatus[1].targetobjectname = "contnr_type_prod_r"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "update product"
     SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
     GO TO exit_script
    ELSE
     SET stat = alterlist(reply->qual,y)
     SET reply->qual[y].contnr_type_prod_id = request->qual[y].contnr_type_prod_id
     SET reply->qual[y].product_cd = request->qual[y].product_cd
     SET reply->qual[y].quantity = request->qual[y].quantity
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
