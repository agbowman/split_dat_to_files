CREATE PROGRAM bb_get_prod_order_inquiry:dba
 RECORD reply(
   1 order_list[*]
     2 product_id = f8
     2 order_id = f8
     2 synonym_id = f8
     2 order_mnemonic = vc
     2 order_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET modify = predeclare
 DECLARE script_name = c25 WITH constant("bb_get_prod_order_inquiry")
 DECLARE activity_type_cs = i4 WITH constant(106)
 DECLARE order_status_cs = i4 WITH constant(6004)
 DECLARE activity_bb_mean = c12 WITH constant("BB")
 DECLARE activity_bb_cd = f8 WITH noconstant(0.0)
 DECLARE activity_bb_product_mean = c12 WITH constant("BB PRODUCT")
 DECLARE activity_bb_product_cd = f8 WITH noconstant(0.0)
 DECLARE order_status_ordered_mean = c12 WITH constant("ORDERED")
 DECLARE order_status_ordered_cd = f8 WITH noconstant(0.0)
 DECLARE errmsg = c132 WITH noconstant(fillstring(132," "))
 DECLARE error_check = i2 WITH noconstant(error(errmsg,1))
 DECLARE uar_error = vc WITH noconstant("")
 DECLARE synonym_id_count = i4 WITH noconstant(0)
 DECLARE order_count = i4 WITH noconstant(0)
 SET activity_bb_cd = uar_get_code_by("MEANING",activity_type_cs,nullterm(activity_bb_mean))
 IF (activity_bb_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve activity type code with meaning of ",trim(
    activity_bb_mean),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET activity_bb_product_cd = uar_get_code_by("MEANING",activity_type_cs,nullterm(
   activity_bb_product_mean))
 IF (activity_bb_product_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve activity type code with meaning of ",trim(
    activity_bb_product_mean),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET order_status_ordered_cd = uar_get_code_by("MEANING",order_status_cs,nullterm(
   order_status_ordered_mean))
 IF (order_status_ordered_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve order status code with meaning of ",trim(
    order_status_ordered_mean),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 IF ((request->donor_orders_ind=0)
  AND (request->transfusion_orders_ind=0))
  CALL errorhandler("F","No security indicator",
   "Transfusion and Donor order security indicators both set to 0.")
 ENDIF
 SET synonym_id_count = size(request->procedures,5)
 IF (synonym_id_count > 0)
  SELECT INTO "nl:"
   o.order_id
   FROM orders o,
    (dummyt d  WITH seq = value(synonym_id_count))
   PLAN (d)
    JOIN (o
    WHERE o.orig_order_dt_tm BETWEEN cnvtdatetime(request->begin_dt_tm) AND cnvtdatetime(request->
     end_dt_tm)
     AND (((request->product_id > 0.0)
     AND (o.product_id=request->product_id)) OR ((request->product_id=0.0)
     AND o.product_id > 0.0))
     AND ((o.order_status_cd+ 0)=order_status_ordered_cd)
     AND o.activity_type_cd IN (activity_bb_cd, activity_bb_product_cd)
     AND (o.synonym_id=request->procedures[d.seq].synonym_id))
   HEAD REPORT
    order_count = 0
   DETAIL
    order_count += 1
    IF (mod(order_count,10)=1)
     stat = alterlist(reply->order_list,(order_count+ 9))
    ENDIF
    reply->order_list[order_count].product_id = o.product_id, reply->order_list[order_count].order_id
     = o.order_id, reply->order_list[order_count].synonym_id = o.synonym_id,
    reply->order_list[order_count].order_mnemonic = o.order_mnemonic, reply->order_list[order_count].
    order_dt_tm = o.orig_order_dt_tm
   FOOT REPORT
    stat = alterlist(reply->order_list,order_count)
   WITH nocounter, orahintcbo("index(o XIE17ORDERS)")
  ;end select
  GO TO set_status
 ELSE
  SELECT INTO "nl:"
   o.order_id
   FROM orders o
   WHERE o.orig_order_dt_tm BETWEEN cnvtdatetime(request->begin_dt_tm) AND cnvtdatetime(request->
    end_dt_tm)
    AND (((request->product_id > 0.0)
    AND (o.product_id=request->product_id)) OR ((request->product_id=0.0)
    AND o.product_id > 0.0))
    AND ((o.order_status_cd+ 0)=order_status_ordered_cd)
    AND o.activity_type_cd IN (activity_bb_cd, activity_bb_product_cd)
   HEAD REPORT
    order_count = 0
   DETAIL
    order_count += 1
    IF (mod(order_count,10)=1)
     stat = alterlist(reply->order_list,(order_count+ 9))
    ENDIF
    reply->order_list[order_count].product_id = o.product_id, reply->order_list[order_count].order_id
     = o.order_id, reply->order_list[order_count].synonym_id = o.synonym_id,
    reply->order_list[order_count].order_mnemonic = o.order_mnemonic, reply->order_list[order_count].
    order_dt_tm = o.orig_order_dt_tm
   FOOT REPORT
    stat = alterlist(reply->order_list,order_count)
   WITH nocounter, orahintcbo("index(o XIE17ORDERS)")
  ;end select
  GO TO set_status
 ENDIF
 SUBROUTINE (errorhandler(operationstatus=c1,targetobjectname=vc,targetobjectvalue=vc) =null)
   DECLARE error_cnt = i2 WITH private, noconstant(0)
   SET error_cnt = size(reply->status_data.subeventstatus,5)
   IF (((error_cnt > 1) OR (error_cnt=1
    AND (reply->status_data.subeventstatus[error_cnt].operationstatus != ""))) )
    SET error_cnt += 1
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[error_cnt].operationname = script_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = operationstatus
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = targetobjectname
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = targetobjectvalue
   GO TO exit_script
 END ;Subroutine
#set_status
 IF (order_count=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO
