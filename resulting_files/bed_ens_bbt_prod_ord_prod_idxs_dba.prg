CREATE PROGRAM bed_ens_bbt_prod_ord_prod_idxs:dba
 RECORD reply(
   1 prodindex_list[*]
     2 prodindex_code_value = f8
     2 prodindex_display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 add_list[*]
     2 product_cd = f8
   1 deactivate_list[*]
     2 prod_ord_prod_idx_r_id = f8
 )
 SET reply->status_data.status = "F"
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE bederror(errordescription=vc) = null
 DECLARE bederrorcheck(errordescription=vc) = null
 SUBROUTINE bederror(errordescription)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE bederrorcheck(errordescription)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   CALL bederror(errordescription)
  ENDIF
 END ;Subroutine
 DECLARE prod_idx_to_add_cnt = i4 WITH protect, noconstant(0)
 DECLARE prod_idx_to_rem_cnt = i4 WITH protect, noconstant(0)
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE req_item_size = i4 WITH protect, noconstant(0)
 IF ((request->order_catalog_code_value > 0))
  SET req_item_size = size(request->prodindex_list,5)
  IF (req_item_size > 0)
   SELECT INTO "nl:"
    add_record = decode(po.seq,1,0)
    FROM (dummyt d  WITH seq = value(req_item_size)),
     (dummyt dj  WITH seq = value(1)),
     prod_ord_prod_idx_r po
    PLAN (d
     WHERE (request->prodindex_list[d.seq].prodindex_code_value > 0))
     JOIN (dj)
     JOIN (po
     WHERE (po.catalog_cd=request->order_catalog_code_value)
      AND (po.product_cd=request->prodindex_list[d.seq].prodindex_code_value)
      AND po.active_ind=1)
    DETAIL
     IF (add_record=0)
      prod_idx_to_add_cnt = (prod_idx_to_add_cnt+ 1), stat = alterlist(temp->add_list,
       prod_idx_to_add_cnt), temp->add_list[prod_idx_to_add_cnt].product_cd = request->
      prodindex_list[d.seq].prodindex_code_value
     ENDIF
    FOOT REPORT
     stat = alterlist(temp->add_list,prod_idx_to_add_cnt)
    WITH nocounter, outerjoin = dj
   ;end select
   CALL bederrorcheck("NEW_REC_CHK_ERR")
  ENDIF
  SELECT INTO "nl:"
   FROM prod_ord_prod_idx_r po
   PLAN (po
    WHERE (po.catalog_cd=request->order_catalog_code_value)
     AND po.active_ind=1)
   DETAIL
    IF (po.product_cd > 0
     AND locateval(cnt,1,req_item_size,po.product_cd,request->prodindex_list[cnt].
     prodindex_code_value)=0)
     prod_idx_to_rem_cnt = (prod_idx_to_rem_cnt+ 1), stat = alterlist(temp->deactivate_list,
      prod_idx_to_rem_cnt), temp->deactivate_list[prod_idx_to_rem_cnt].prod_ord_prod_idx_r_id = po
     .prod_ord_prod_idx_r_id
    ENDIF
   FOOT REPORT
    stat = alterlist(temp->deactivate_list,prod_idx_to_rem_cnt)
   WITH nocounter
  ;end select
  CALL bederrorcheck("DEACTV_REC_CHK_ERR")
  IF (prod_idx_to_add_cnt > 0)
   INSERT  FROM prod_ord_prod_idx_r po,
     (dummyt d  WITH seq = value(prod_idx_to_add_cnt))
    SET po.prod_ord_prod_idx_r_id = seq(pathnet_seq,nextval), po.catalog_cd = request->
     order_catalog_code_value, po.product_cd = temp->add_list[d.seq].product_cd,
     po.active_ind = 1, po.active_status_cd = reqdata->active_status_cd, po.active_status_dt_tm =
     cnvtdatetime(curdate,curtime3),
     po.active_status_prsnl_id = reqinfo->updt_id, po.updt_cnt = 0, po.updt_dt_tm = cnvtdatetime(
      curdate,curtime3),
     po.updt_id = reqinfo->updt_id, po.updt_task = reqinfo->updt_task, po.updt_applctx = reqinfo->
     updt_applctx
    PLAN (d)
     JOIN (po)
    WITH nocounter
   ;end insert
   CALL bederrorcheck("ASSOC_INSERT_ERR")
  ENDIF
  IF (prod_idx_to_rem_cnt > 0)
   UPDATE  FROM prod_ord_prod_idx_r po,
     (dummyt d  WITH seq = value(prod_idx_to_rem_cnt))
    SET po.active_ind = 0, po.active_status_dt_tm = cnvtdatetime(curdate,curtime3), po
     .active_status_cd = reqdata->inactive_status_cd,
     po.active_status_prsnl_id = reqinfo->updt_id, po.updt_cnt = (po.updt_cnt+ 1), po.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     po.updt_id = reqinfo->updt_id, po.updt_task = reqinfo->updt_task, po.updt_applctx = reqinfo->
     updt_applctx
    PLAN (d)
     JOIN (po
     WHERE (po.prod_ord_prod_idx_r_id=temp->deactivate_list[d.seq].prod_ord_prod_idx_r_id))
    WITH nocounter
   ;end update
   CALL bederrorcheck("ASSOC_UPDT_ERR")
  ENDIF
  SELECT INTO "nl:"
   FROM prod_ord_prod_idx_r po
   PLAN (po
    WHERE (po.catalog_cd=request->order_catalog_code_value)
     AND po.active_ind=1)
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt = (cnt+ 1), stat = alterlist(reply->prodindex_list,cnt), reply->prodindex_list[cnt].
    prodindex_code_value = po.product_cd,
    reply->prodindex_list[cnt].prodindex_display = uar_get_code_display(po.product_cd)
   FOOT REPORT
    stat = alterlist(reply->prodindex_list,cnt)
   WITH nocounter
  ;end select
  CALL bederrorcheck("POPULATING_REPLY_ERR")
 ENDIF
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
