CREATE PROGRAM bbt_chg_device_transfer:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET transfer_cdf = "6"
 DECLARE transfer_cd = f8
 DECLARE from_device = f8
 DECLARE status_count = i4
 DECLARE pidx = i4
 DECLARE nbr_of_products = i4
 SET transfer_cd = 0.0
 SET status_count = 0
 SET pidx = 0
 SET cdf_meaning = fillstring(12," ")
 SET cdf_meaning = transfer_cdf
 SET stat = uar_get_meaning_by_codeset(1610,cdf_meaning,1,transfer_cd)
 CALL echo(transfer_cd)
 IF (stat=1)
  SET failed = "T"
  SET status_count = (status_count+ 1)
  IF (status_count > 1)
   SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
  ENDIF
  SET reply->status_data.subeventstatus[status_count].operationname = "UAR"
  SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
  SET reply->status_data.subeventstatus[status_count].targetobjectname = "Code value"
  SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
  "Unable to retrieve product event code value"
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 SUBROUTINE add_product_event(sub_product_id,sub_person_id,sub_encntr_id,sub_order_id,
  sub_bb_result_id,sub_event_type_cd,sub_event_dt_tm,sub_event_prsnl_id,sub_event_status_flag,
  sub_override_ind,sub_override_reason_cd,sub_related_product_event_id,sub_active_ind,
  sub_active_status_cd,sub_active_status_dt_tm,sub_active_status_prsnl_id)
   SET gsub_product_event_status = "  "
   SET product_event_id = 0.0
   SET sub_product_event_id = 0.0
   DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
   SET new_pathnet_seq = 0
   SELECT INTO "nl:"
    seqn = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     new_pathnet_seq = seqn
    WITH format, nocounter
   ;end select
   IF (curqual=0)
    SET gsub_product_event_status = "FS"
   ELSE
    SET sub_product_event_id = new_pathnet_seq
    INSERT  FROM product_event pe
     SET pe.product_event_id = sub_product_event_id, pe.product_id = sub_product_id, pe.person_id =
      IF (sub_person_id=null) 0
      ELSE sub_person_id
      ENDIF
      ,
      pe.encntr_id =
      IF (sub_encntr_id=null) 0
      ELSE sub_encntr_id
      ENDIF
      , pe.order_id =
      IF (sub_order_id=null) 0
      ELSE sub_order_id
      ENDIF
      , pe.bb_result_id = sub_bb_result_id,
      pe.event_type_cd = sub_event_type_cd, pe.event_dt_tm = cnvtdatetime(sub_event_dt_tm), pe
      .event_prsnl_id = sub_event_prsnl_id,
      pe.event_status_flag = sub_event_status_flag, pe.override_ind = sub_override_ind, pe
      .override_reason_cd = sub_override_reason_cd,
      pe.related_product_event_id = sub_related_product_event_id, pe.active_ind = sub_active_ind, pe
      .active_status_cd = sub_active_status_cd,
      pe.active_status_dt_tm = cnvtdatetime(sub_active_status_dt_tm), pe.active_status_prsnl_id =
      sub_active_status_prsnl_id, pe.updt_cnt = 0,
      pe.updt_dt_tm = cnvtdatetime(curdate,curtime3), pe.updt_id = reqinfo->updt_id, pe.updt_task =
      reqinfo->updt_task,
      pe.updt_applctx = reqinfo->updt_applctx, pe.event_tz =
      IF (curutc=1) curtimezoneapp
      ELSE 0
      ENDIF
     WITH nocounter
    ;end insert
    SET product_event_id = sub_product_event_id
    SET new_product_event_id = sub_product_event_id
    IF (curqual=0)
     SET gsub_product_event_status = "FA"
    ELSE
     SET gsub_product_event_status = "OK"
    ENDIF
   ENDIF
 END ;Subroutine
 SET nbr_of_products = size(request->products,5)
 FOR (pidx = 1 TO nbr_of_products)
   SET from_device = 0.0
   SELECT INTO "nl:"
    p.product_id
    FROM product p
    WHERE (p.product_id=request->products[pidx].product_id)
     AND p.active_ind=1
     AND (p.updt_cnt=request->products[pidx].updt_cnt)
    DETAIL
     from_device = p.cur_dispense_device_id
    WITH nocounter, forupdate(p)
   ;end select
   IF (curqual=0)
    SET failed = "T"
    SET status_count = (status_count+ 1)
    IF (status_count > 1)
     SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
    ENDIF
    SET reply->status_data.subeventstatus[status_count].operationname = "SELECT"
    SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
    SET reply->status_data.subeventstatus[status_count].targetobjectname = "Product"
    SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
    "Unable to lock product row"
    SET reply->status_data.status = "F"
    GO TO exit_script
   ENDIF
   UPDATE  FROM product p
    SET p.cur_dispense_device_id = request->to_device_id, p.locked_ind = 0, p.updt_cnt = (p.updt_cnt
     + 1),
     p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id = reqinfo->updt_id, p.updt_task =
     reqinfo->updt_task,
     p.updt_applctx = reqinfo->updt_applctx
    WHERE (p.product_id=request->products[pidx].product_id)
     AND (p.updt_cnt=request->products[pidx].updt_cnt)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET failed = "T"
    SET status_count = (status_count+ 1)
    IF (status_count > 1)
     SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
    ENDIF
    SET reply->status_data.subeventstatus[status_count].operationname = "UPDATE"
    SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
    SET reply->status_data.subeventstatus[status_count].targetobjectname = "Product"
    SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
    "Unable to update device on product"
    SET reply->status_data.status = "F"
    GO TO exit_script
   ENDIF
   SET gsub_product_event_status = "  "
   SET product_event_id = 0.0
   CALL add_product_event(request->products[pidx].product_id,0,0,0,0,
    transfer_cd,cnvtdatetime(curdate,curtime3),reqinfo->updt_id,0,0,
    0,0,0,reqdata->active_status_cd,cnvtdatetime(curdate,curtime3),
    reqinfo->updt_id)
   IF (gsub_product_event_status="FS")
    SET failed = "T"
    SET status_count = (status_count+ 1)
    IF (status_count > 1)
     SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
    ENDIF
    SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
    SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
    SET reply->status_data.subeventstatus[status_count].targetobjectname = "Product Event"
    SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
    "Unable to insert transfered product event due to product event id"
    SET reply->status_data.status = "F"
    GO TO exit_script
   ELSEIF (gsub_product_event_status="FA")
    SET failed = "T"
    SET status_count = (status_count+ 1)
    IF (status_count > 1)
     SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
    ENDIF
    SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
    SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
    SET reply->status_data.subeventstatus[status_count].targetobjectname = "Product Event"
    SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
    "Unable to insert transfered product event"
    SET reply->status_data.status = "F"
    GO TO exit_script
   ENDIF
   INSERT  FROM bb_device_transfer dt
    SET dt.product_event_id = product_event_id, dt.product_id = request->products[pidx].product_id,
     dt.from_device_id = from_device,
     dt.to_device_id = request->to_device_id, dt.reason_cd = request->reason_cd, dt.updt_cnt = 0,
     dt.updt_dt_tm = cnvtdatetime(curdate,curtime3), dt.updt_id = reqinfo->updt_id, dt.updt_task =
     reqinfo->updt_task,
     dt.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET failed = "T"
    SET status_count = (status_count+ 1)
    IF (status_count > 1)
     SET stat = alterlist(reply->status_data.subeventstatus,(status_count+ 1))
    ENDIF
    SET reply->status_data.subeventstatus[status_count].operationname = "INSERT"
    SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
    SET reply->status_data.subeventstatus[status_count].targetobjectname = "BB DEVICE TRANSFER "
    SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
    "Unable to insert bb device transfer"
    SET reply->status_data.status = "F"
    GO TO exit_script
   ENDIF
 ENDFOR
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->status_data.status="F"))
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
