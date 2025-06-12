CREATE PROGRAM bbt_get_max_product_expiration:dba
 SUBROUTINE (subevent_add(op_name=vc(value),op_status=vc(value),obj_name=vc(value),obj_value=vc(value
   )) =null WITH protect)
   DECLARE se_itm = i4 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET se_itm = size(reply->status_data.subeventstatus,5)
   SET stat = alter(reply->status_data.subeventstatus,(se_itm+ 1))
   SET reply->status_data.subeventstatus[se_itm].operationname = cnvtupper(substring(1,25,trim(
      op_name)))
   SET reply->status_data.subeventstatus[se_itm].operationstatus = cnvtupper(substring(1,1,trim(
      op_status)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectname = cnvtupper(substring(1,25,trim(
      obj_name)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectvalue = obj_value
 END ;Subroutine
 RECORD reply(
   1 max_product_expire_dt_tm = dq8
   1 create_dt_tm = dq8
   1 component_qual[*]
     2 product_nbr = c30
     2 current_expire_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD product_info(
   1 pooled_product_ind = i2
   1 modified_product_ind = i2
   1 day_interval = c10
   1 hour_interval = c10
   1 recv_dt_tm = dq8
   1 drawn_dt_tm = dq8
   1 create_dt_tm = dq8
 )
 SET reply->status_data.status = "F"
 DECLARE dpooledeventtypecd = f8 WITH noconstant(0.0)
 DECLARE ncodecnt = i2 WITH noconstant(1)
 DECLARE ndaysind = i2 WITH noconstant(0)
 DECLARE nhoursind = i2 WITH noconstant(0)
 SET stat = uar_get_meaning_by_codeset(1610,"18",value(ncodecnt),dpooledeventtypecd)
 IF (ncodecnt > 1)
  CALL subevent_add("SELECT","F","CODE_VALUE",
   "Selecting for cdf_meaning of 18 (cs 1610) returned multiple values.")
  GO TO exit_script
 ELSEIF (ncodecnt=0)
  CALL subevent_add("SELECT","F","CODE_VALUE",
   "Selecting for cdf_meaning of 18 (cs 1610) returned no values.")
  GO TO exit_script
 ENDIF
 SELECT
  IF ((request->product_cd > 0.0))
   PLAN (p
    WHERE (p.product_id=request->product_id))
    JOIN (pi
    WHERE (pi.product_cd=request->product_cd))
    JOIN (bp
    WHERE (bp.product_id= Outerjoin(p.product_id)) )
  ELSE
  ENDIF
  INTO "nl:"
  p.product_id
  FROM product p,
   product_index pi,
   blood_product bp
  PLAN (p
   WHERE (p.product_id=request->product_id))
   JOIN (pi
   WHERE pi.product_cd=p.product_cd)
   JOIN (bp
   WHERE (bp.product_id= Outerjoin(p.product_id)) )
  DETAIL
   product_info->pooled_product_ind = p.pooled_product_ind, product_info->modified_product_ind = p
   .modified_product_ind, product_info->day_interval = build(pi.max_days_expire,",D"),
   product_info->hour_interval = build(pi.max_hrs_expire,",H")
   IF (pi.max_hrs_expire > 0)
    nhoursind = 1
   ENDIF
   IF (pi.max_days_expire > 0)
    ndaysind = 1
   ENDIF
   IF ((request->new_receive_dt_tm > 0))
    product_info->recv_dt_tm = request->new_receive_dt_tm
   ELSE
    product_info->recv_dt_tm = p.recv_dt_tm
   ENDIF
   product_info->drawn_dt_tm = bp.drawn_dt_tm, product_info->create_dt_tm = p.create_dt_tm, reply->
   create_dt_tm = p.create_dt_tm
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL subevent_add("SELECT","F","PRODUCT","No product found for product id passed in.")
  GO TO exit_script
 ENDIF
 IF ((product_info->drawn_dt_tm > 0))
  SET reply->max_product_expire_dt_tm = cnvtlookahead(product_info->day_interval,product_info->
   drawn_dt_tm)
  IF (nhoursind=1)
   SET reply->max_product_expire_dt_tm = cnvtlookahead(product_info->hour_interval,reply->
    max_product_expire_dt_tm)
  ELSE
   IF (ndaysind=1)
    SET reply->max_product_expire_dt_tm = cnvtdatetime(cnvtdate(reply->max_product_expire_dt_tm),2359
     )
   ENDIF
  ENDIF
 ELSEIF ((product_info->recv_dt_tm > 0))
  SET reply->max_product_expire_dt_tm = cnvtlookahead(product_info->day_interval,product_info->
   recv_dt_tm)
  IF (nhoursind=1)
   SET reply->max_product_expire_dt_tm = cnvtlookahead(product_info->hour_interval,reply->
    max_product_expire_dt_tm)
  ELSE
   IF (ndaysind=1)
    SET reply->max_product_expire_dt_tm = cnvtdatetime(cnvtdate(reply->max_product_expire_dt_tm),2359
     )
   ENDIF
  ENDIF
 ENDIF
 IF ((product_info->pooled_product_ind=1))
  IF ((reply->max_product_expire_dt_tm=0))
   SELECT INTO "nl:"
    pe.product_event_id
    FROM product_event pe
    PLAN (pe
     WHERE (pe.product_id=request->product_id)
      AND pe.event_type_cd=dpooledeventtypecd)
    DETAIL
     reply->max_product_expire_dt_tm = cnvtlookahead(product_info->day_interval,pe.event_dt_tm),
     reply->max_product_expire_dt_tm = cnvtlookahead(product_info->hour_interval,reply->
      max_product_expire_dt_tm)
    WITH nocounter
   ;end select
   IF ((reply->max_product_expire_dt_tm=0))
    CALL subevent_add("SELECT","F","PRODUCT_EVENT",
     "No POOLED PRODUCT event found for pooled product.")
    GO TO exit_script
   ENDIF
  ENDIF
  SELECT INTO "nl:"
   p.product_id
   FROM product p,
    blood_product bp
   PLAN (p
    WHERE (p.pooled_product_id=request->product_id))
    JOIN (bp
    WHERE (bp.product_id= Outerjoin(p.product_id)) )
   HEAD REPORT
    ncompcnt = 0
   DETAIL
    ncompcnt += 1
    IF (mod(ncompcnt,5)=1)
     stat = alterlist(reply->component_qual,(ncompcnt+ 4))
    ENDIF
    reply->component_qual[ncompcnt].product_nbr = concat(bp.supplier_prefix,p.product_nbr," ",p
     .product_sub_nbr), reply->component_qual[ncompcnt].current_expire_dt_tm = p.cur_expire_dt_tm
   FOOT REPORT
    stat = alterlist(reply->component_qual,ncompcnt)
   WITH nocounter
  ;end select
  IF (curqual=0)
   CALL subevent_add("SELECT","F","PRODUCT","No component products found for pooled product.")
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((reply->max_product_expire_dt_tm=0))
  SET reply->max_product_expire_dt_tm = cnvtlookahead(product_info->day_interval,product_info->
   create_dt_tm)
  IF (nhoursind=1)
   SET reply->max_product_expire_dt_tm = cnvtlookahead(product_info->hour_interval,reply->
    max_product_expire_dt_tm)
  ELSE
   IF (ndaysind=0)
    SET reply->max_product_expire_dt_tm = cnvtdatetime(cnvtdate(reply->max_product_expire_dt_tm),2359
     )
   ENDIF
  ENDIF
 ENDIF
 IF ((reply->max_product_expire_dt_tm=0))
  CALL subevent_add("SELECT","F","PRODUCT","No valid max expirt date time found.")
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 FREE SET product_info
END GO
