CREATE PROGRAM bbt_get_pooled_by_prod:dba
 RECORD reply(
   1 pool_option_id = f8
   1 qual[*]
     2 product_nbr = c20
     2 product_sub_nbr = c5
     2 supplier_prefix = c5
     2 pooled_ind = i2
     2 updt_cnt = i4
     2 bp_updt_cnt = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = i4
     2 updt_applctx = i4
     2 product_id = f8
     2 cur_abo_cd = f8
     2 cur_abo_disp = c40
     2 cur_rh_cd = f8
     2 cur_rh_disp = c40
     2 cur_volume = i4
     2 cur_unit_meas_cd = f8
     2 cur_unit_meas_disp = c40
     2 cur_expire_dt_tm = dq8
     2 earliest_event_dt_tm = dq8
     2 original_volume = i4
     2 electronic_entry_flag = i2
     2 donation_type_cd = f8
     2 disease_cd = f8
     2 product_cd = f8
     2 intended_use_print_parm_txt = c1
     2 product_type_disp = c40
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE history_ind = i2 WITH noconstant(0)
 SET err_cnt = 0
 SET qual_cnt = 0
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  p.pooled_product_ind, p.pooled_product_id
  FROM product p
  PLAN (p
   WHERE (p.product_id=request->product_id))
  DETAIL
   stat = alterlist(reply->qual,qual_cnt)
   IF (p.pooled_product_ind=1)
    request->pooled_ind = 1, reply->pool_option_id = p.pool_option_id
   ELSE
    IF (p.pooled_product_id > 0)
     request->pooled_ind = 2, request->pooled_product_id = p.pooled_product_id
    ELSE
     request->pooled_ind = 0, reply->status_data.status = "S"
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  SELECT INTO "nl:"
   hp.product_id, hp.pooled_product_ind
   FROM bbhist_product hp
   PLAN (hp
    WHERE (hp.product_id=request->product_id))
   DETAIL
    stat = alterlist(reply->qual,qual_cnt), history_ind = 1
    IF (hp.pooled_product_ind=1)
     request->pooled_ind = 1
    ELSE
     IF (hp.pooled_product_id > 0.0)
      request->pooled_ind = 2, request->pooled_product_id = hp.pooled_product_id
     ELSE
      request->pooled_ind = 0, reply->status_data.status = "S"
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET err_cnt += 1
   SET reply->status_data.subeventstatus[err_cnt].operationname = "select"
   SET reply->status_data.subeventstatus[err_cnt].operationstatus = "Z"
   SET reply->status_data.subeventstatus[err_cnt].targetobjectname = "product"
   SET reply->status_data.subeventstatus[err_cnt].targetobjectvalue =
   "Unable to find product specified"
   SET reply->status_data.status = "Z"
   GO TO end_script
  ENDIF
 ENDIF
 IF (history_ind=0)
  IF ((request->pooled_ind=1))
   SELECT INTO "nl:"
    p.product_nbr, p.pooled_product_id, p.product_id,
    p.cur_expire_dt_tm, p.cur_unit_meas_cd, bp.cur_abo_cd,
    bp.cur_rh_cd, bp.cur_volume, bp.updt_cnt
    FROM product p,
     blood_product bp,
     product_event pe
    PLAN (p
     WHERE (p.pooled_product_id=request->product_id))
     JOIN (bp
     WHERE p.product_id=bp.product_id)
     JOIN (pe
     WHERE (pe.product_id= Outerjoin(bp.product_id)) )
    ORDER BY p.product_id, pe.event_dt_tm
    HEAD REPORT
     qual_cnt = 0
    HEAD p.product_id
     qual_cnt += 1
     IF (mod(qual_cnt,3)=1)
      stat = alterlist(reply->qual,(qual_cnt+ 2))
     ENDIF
     reply->qual[qual_cnt].product_nbr = p.product_nbr, reply->qual[qual_cnt].product_sub_nbr = p
     .product_sub_nbr, reply->qual[qual_cnt].pooled_ind = request->pooled_ind,
     reply->qual[qual_cnt].product_id = p.product_id, reply->qual[qual_cnt].cur_expire_dt_tm = p
     .cur_expire_dt_tm, reply->qual[qual_cnt].cur_unit_meas_cd = p.cur_unit_meas_cd,
     reply->qual[qual_cnt].supplier_prefix = bp.supplier_prefix, reply->qual[qual_cnt].cur_abo_cd =
     bp.cur_abo_cd, reply->qual[qual_cnt].cur_rh_cd = bp.cur_rh_cd,
     reply->qual[qual_cnt].cur_volume = bp.cur_volume, reply->qual[qual_cnt].updt_cnt = p.updt_cnt,
     reply->qual[qual_cnt].bp_updt_cnt = bp.updt_cnt,
     reply->qual[qual_cnt].updt_dt_tm = p.updt_dt_tm, reply->qual[qual_cnt].updt_id = p.updt_id,
     reply->qual[qual_cnt].updt_task = p.updt_task,
     reply->qual[qual_cnt].updt_applctx = p.updt_applctx, reply->qual[qual_cnt].earliest_event_dt_tm
      = pe.event_dt_tm, reply->qual[qual_cnt].original_volume = bp.orig_volume,
     reply->qual[qual_cnt].electronic_entry_flag = p.electronic_entry_flag, reply->qual[qual_cnt].
     donation_type_cd = p.donation_type_cd, reply->qual[qual_cnt].disease_cd = p.disease_cd,
     reply->qual[qual_cnt].product_cd = p.product_cd, reply->qual[qual_cnt].
     intended_use_print_parm_txt = trim(p.intended_use_print_parm_txt,3), reply->qual[qual_cnt].
     product_type_disp = trim(uar_get_code_display(p.product_cd))
    DETAIL
     row + 0
    FOOT  p.product_id
     row + 0
    FOOT REPORT
     stat = alterlist(reply->qual,qual_cnt)
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET err_cnt += 1
    SET reply->status_data.subeventstatus[err_cnt].operationname = "select"
    SET reply->status_data.subeventstatus[err_cnt].operationstatus = "Z"
    SET reply->status_data.subeventstatus[err_cnt].targetobjectname = "product"
    SET reply->status_data.subeventstatus[err_cnt].targetobjectvalue =
    "unable to return components of pooled product specified"
    SET reply->status_data.status = "Z"
   ELSE
    SET reply->status_data.status = "S"
   ENDIF
  ELSE
   SELECT INTO "nl:"
    p.product_nbr, p.pooled_product_id, p.product_id
    FROM product p
    WHERE (p.product_id=request->pooled_product_id)
    HEAD REPORT
     qual_cnt = 0
    DETAIL
     qual_cnt += 1
     IF (mod(qual_cnt,3)=1)
      stat = alterlist(reply->qual,(qual_cnt+ 2))
     ENDIF
     reply->qual[qual_cnt].product_nbr = p.product_nbr, reply->qual[qual_cnt].pooled_ind = request->
     pooled_ind, reply->qual[qual_cnt].intended_use_print_parm_txt = trim(p
      .intended_use_print_parm_txt,3)
    FOOT REPORT
     stat = alterlist(reply->qual,qual_cnt)
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET err_cnt += 1
    SET reply->status_data.subeventstatus[err_cnt].operationname = "select"
    SET reply->status_data.subeventstatus[err_cnt].operationstatus = "Z"
    SET reply->status_data.subeventstatus[err_cnt].targetobjectname = "product"
    SET reply->status_data.subeventstatus[err_cnt].targetobjectvalue =
    "unable to return pooled product of component specified"
    SET reply->status_data.status = "Z"
   ELSE
    SET reply->status_data.status = "S"
   ENDIF
  ENDIF
 ELSE
  IF ((request->pooled_ind=1))
   SELECT INTO "nl:"
    hp.*
    FROM bbhist_product hp
    PLAN (hp
     WHERE (hp.pooled_product_id=request->product_id))
    HEAD REPORT
     qual_cnt = 0
    DETAIL
     qual_cnt += 1
     IF (mod(qual_cnt,3)=1)
      stat = alterlist(reply->qual,(qual_cnt+ 2))
     ENDIF
     reply->qual[qual_cnt].product_nbr = hp.product_nbr, reply->qual[qual_cnt].product_sub_nbr = hp
     .product_sub_nbr, reply->qual[qual_cnt].pooled_ind = request->pooled_ind,
     reply->qual[qual_cnt].product_id = hp.product_id, reply->qual[qual_cnt].cur_expire_dt_tm = hp
     .expire_dt_tm, reply->qual[qual_cnt].cur_unit_meas_cd = hp.unit_meas_cd,
     reply->qual[qual_cnt].supplier_prefix = hp.supplier_prefix, reply->qual[qual_cnt].cur_abo_cd =
     hp.abo_cd, reply->qual[qual_cnt].cur_rh_cd = hp.rh_cd,
     reply->qual[qual_cnt].cur_volume = hp.volume, reply->qual[qual_cnt].updt_cnt = hp.updt_cnt,
     reply->qual[qual_cnt].updt_dt_tm = hp.updt_dt_tm,
     reply->qual[qual_cnt].updt_id = hp.updt_id, reply->qual[qual_cnt].updt_task = hp.updt_task,
     reply->qual[qual_cnt].updt_applctx = hp.updt_applctx,
     reply->qual[qual_cnt].electronic_entry_flag = 0, reply->qual[qual_cnt].donation_type_cd = 0.0,
     reply->qual[qual_cnt].disease_cd = 0.0,
     reply->qual[qual_cnt].product_cd = hp.product_cd
    FOOT REPORT
     stat = alterlist(reply->qual,qual_cnt)
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET err_cnt += 1
    SET reply->status_data.subeventstatus[err_cnt].operationname = "select"
    SET reply->status_data.subeventstatus[err_cnt].operationstatus = "Z"
    SET reply->status_data.subeventstatus[err_cnt].targetobjectname = "product"
    SET reply->status_data.subeventstatus[err_cnt].targetobjectvalue =
    "Unable to return components of pooled product specified"
    SET reply->status_data.status = "Z"
   ELSE
    SET reply->status_data.status = "S"
   ENDIF
  ELSE
   SELECT INTO "nl:"
    hp.product_nbr
    FROM bbhist_product hp
    PLAN (hp
     WHERE (hp.product_id=request->pooled_product_id))
    HEAD REPORT
     qual_cnt = 0
    DETAIL
     qual_cnt += 1
     IF (mod(qual_cnt,3)=1)
      stat = alterlist(reply->qual,(qual_cnt+ 2))
     ENDIF
     reply->qual[qual_cnt].product_nbr = hp.product_nbr, reply->qual[qual_cnt].pooled_ind = request->
     pooled_ind
    FOOT REPORT
     stat = alterlist(reply->qual,qual_cnt)
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET err_cnt += 1
    SET reply->status_data.subeventstatus[err_cnt].operationname = "select"
    SET reply->status_data.subeventstatus[err_cnt].operationstatus = "Z"
    SET reply->status_data.subeventstatus[err_cnt].targetobjectname = "product"
    SET reply->status_data.subeventstatus[err_cnt].targetobjectvalue =
    "unable to return pooled product of component specified"
    SET reply->status_data.status = "Z"
   ELSE
    SET reply->status_data.status = "S"
   ENDIF
  ENDIF
 ENDIF
#end_script
END GO
