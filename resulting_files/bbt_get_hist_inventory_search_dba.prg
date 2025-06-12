CREATE PROGRAM bbt_get_hist_inventory_search:dba
 RECORD reply(
   1 more_records = vc
   1 product_id = f8
   1 qual[*]
     2 product_id = f8
     2 product_number = vc
     2 product_sub = vc
     2 abo_cd = f8
     2 abo_cd_disp = c40
     2 rh_cd = f8
     2 rh_cd_disp = c40
     2 product_cd = f8
     2 product_cd_disp = c40
     2 states[*]
       3 states_cd = f8
       3 states_cd_disp = c40
     2 exp_dt_tm = di8
     2 unit_of_meas_cd = f8
     2 unit_of_meas_cd_disp = c40
     2 volume_display = i4
     2 antigens[*]
       3 antigen_cd = f8
       3 antigen_cd_disp = c40
     2 comment_ind = i4
     2 location_cd = f8
     2 location_disp = vc
     2 cur_owner_area_cd = f8
     2 cur_owner_area_disp = c40
     2 cur_inv_area_cd = f8
     2 cur_inv_area_disp = c40
     2 alt_id_display = vc
     2 contributor_system_cd = f8
     2 contributor_system_disp = c40
     2 cross_reference = c40
     2 upload_dt_tm = dq8
     2 electronic_entry_flag = i2
     2 cur_dispense_device_disp = vc
     2 deriv_cur_avail_qty = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE product_count = i2 WITH noconstant(0)
 DECLARE antigen_count = i2 WITH noconstant(0)
 DECLARE states_count = i2 WITH noconstant(0)
 DECLARE event_type_cdf = c12 WITH noconstant(fillstring(12," "))
 DECLARE event_type_cs = i4 WITH constant(1610)
 DECLARE transferred_event_cd = f8 WITH noconstant(0.0)
 DECLARE modified_event_cd = f8 WITH noconstant(0.0)
 DECLARE received_event_cd = f8 WITH noconstant(0.0)
 DECLARE shipped_event_cd = f8 WITH noconstant(0.0)
 DECLARE pooled_event_cd = f8 WITH noconstant(0.0)
 DECLARE pool_product_event_cd = f8 WITH noconstant(0.0)
 DECLARE stat = i2 WITH noconstant(0)
 DECLARE error_message = c132 WITH noconstant(fillstring(132," "))
 DECLARE error_check = i2 WITH noconstant(error(error_message,1))
 DECLARE sscriptname = c29 WITH constant("BBT_GET_HIST_INVENTORY_SEARCH")
 SET reply->status_data.status = "F"
 SELECT
  IF ((request->search_type_flag=1)
   AND (request->product_cd=0.0))INTO "nl:"
   hp.product_id
   FROM bbhist_product hp
   PLAN (hp
    WHERE hp.expire_dt_tm < datetimeadd(cnvtdatetime(curdate,curtime3),request->days_to_expire)
     AND hp.product_id > 0.0
     AND hp.active_ind=1
     AND (((request->cur_owner_area_cd > 0.0)
     AND (hp.owner_area_cd=request->cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0.0)))
     AND (((request->cur_inv_area_cd > 0.0)
     AND (hp.inv_area_cd=request->cur_inv_area_cd)) OR ((request->cur_inv_area_cd=0.0)))
     AND (((request->abo_cd > 0.0)
     AND (hp.abo_cd=request->abo_cd)) OR ((request->abo_cd=0.0)))
     AND (((request->rh_cd > 0.0)
     AND (hp.rh_cd=request->rh_cd)) OR ((request->rh_cd=0.0))) )
  ELSEIF ((request->search_type_flag=1)
   AND (request->product_cd > 0.0))INTO "nl:"
   hp.product_id
   FROM product_index pi,
    bbhist_product hp
   PLAN (pi
    WHERE (pi.product_cat_cd=request->product_cd))
    JOIN (hp
    WHERE hp.product_cd=pi.product_cd
     AND hp.expire_dt_tm < datetimeadd(cnvtdatetime(curdate,curtime3),request->days_to_expire)
     AND hp.product_id > 0.0
     AND hp.active_ind=1
     AND (((request->cur_owner_area_cd > 0.0)
     AND (hp.owner_area_cd=request->cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0.0)))
     AND (((request->cur_inv_area_cd > 0.0)
     AND (hp.inv_area_cd=request->cur_inv_area_cd)) OR ((request->cur_inv_area_cd=0.0)))
     AND (((request->abo_cd > 0.0)
     AND (hp.abo_cd=request->abo_cd)) OR ((request->abo_cd=0.0)))
     AND (((request->rh_cd > 0.0)
     AND (hp.rh_cd=request->rh_cd)) OR ((request->rh_cd=0.0))) )
  ELSEIF ((request->search_type_flag=2)
   AND (request->product_cd=0.0))INTO "nl:"
   hp.product_id
   FROM bbhist_product hp,
    (dummyt d_hpe  WITH seq = value(request->states_count)),
    bbhist_product_event hpe
   PLAN (hp
    WHERE hp.expire_dt_tm < datetimeadd(cnvtdatetime(curdate,curtime3),request->days_to_expire)
     AND hp.product_id > 0.0
     AND hp.active_ind=1
     AND (((request->cur_owner_area_cd > 0.0)
     AND (hp.owner_area_cd=request->cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0.0)))
     AND (((request->cur_inv_area_cd > 0.0)
     AND (hp.inv_area_cd=request->cur_inv_area_cd)) OR ((request->cur_inv_area_cd=0.0)))
     AND (((request->abo_cd > 0.0)
     AND (hp.abo_cd=request->abo_cd)) OR ((request->abo_cd=0.0)))
     AND (((request->rh_cd > 0.0)
     AND (hp.rh_cd=request->rh_cd)) OR ((request->rh_cd=0.0))) )
    JOIN (hpe
    WHERE hpe.product_id=hp.product_id
     AND hpe.active_ind=1)
    JOIN (d_hpe
    WHERE (request->states_data[d_hpe.seq].states_cd=hpe.event_type_cd))
  ELSEIF ((request->search_type_flag=2)
   AND (request->product_cd > 0.0))INTO "nl:"
   hp.product_id
   FROM product_index pi,
    bbhist_product hp,
    (dummyt d_hpe  WITH seq = value(request->states_count)),
    bbhist_product_event hpe
   PLAN (pi
    WHERE (pi.product_cat_cd=request->product_cd))
    JOIN (hp
    WHERE hp.product_cd=pi.product_cd
     AND hp.expire_dt_tm < datetimeadd(cnvtdatetime(curdate,curtime3),request->days_to_expire)
     AND hp.product_id > 0.0
     AND hp.active_ind=1
     AND (((request->cur_owner_area_cd > 0.0)
     AND (hp.owner_area_cd=request->cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0.0)))
     AND (((request->cur_inv_area_cd > 0.0)
     AND (hp.inv_area_cd=request->cur_inv_area_cd)) OR ((request->cur_inv_area_cd=0.0)))
     AND (((request->abo_cd > 0.0)
     AND (hp.abo_cd=request->abo_cd)) OR ((request->abo_cd=0.0)))
     AND (((request->rh_cd > 0.0)
     AND (hp.rh_cd=request->rh_cd)) OR ((request->rh_cd=0.0))) )
    JOIN (hpe
    WHERE hpe.product_id=hp.product_id
     AND hpe.active_ind=1)
    JOIN (d_hpe
    WHERE (request->states_data[d_hpe.seq].states_cd=hpe.event_type_cd))
  ELSEIF ((request->search_type_flag=3)
   AND (request->product_cd=0.0))INTO "nl:"
   hp.product_id
   FROM (dummyt d_hst  WITH seq = value(request->antigen_count)),
    bbhist_special_testing hst,
    bbhist_product hp
   PLAN (d_hst)
    JOIN (hst
    WHERE (hst.special_testing_cd=request->antigen_data[d_hst.seq].antigen_cd)
     AND hst.product_id > 0.0
     AND hst.active_ind=1)
    JOIN (hp
    WHERE hp.product_id=hst.product_id
     AND hp.expire_dt_tm < datetimeadd(cnvtdatetime(curdate,curtime3),request->days_to_expire)
     AND hp.active_ind=1
     AND (((request->cur_owner_area_cd > 0.0)
     AND (hp.owner_area_cd=request->cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0.0)))
     AND (((request->cur_inv_area_cd > 0.0)
     AND (hp.inv_area_cd=request->cur_inv_area_cd)) OR ((request->cur_inv_area_cd=0.0)))
     AND (((request->abo_cd > 0.0)
     AND (hp.abo_cd=request->abo_cd)) OR ((request->abo_cd=0.0)))
     AND (((request->rh_cd > 0.0)
     AND (hp.rh_cd=request->rh_cd)) OR ((request->rh_cd=0.0))) )
  ELSEIF ((request->search_type_flag=3)
   AND (request->product_cd > 0.0))INTO "nl:"
   hp.product_id
   FROM (dummyt d_hst  WITH seq = value(request->antigen_count)),
    bbhist_special_testing hst,
    bbhist_product hp,
    product_index pi
   PLAN (d_hst)
    JOIN (hst
    WHERE (hst.special_testing_cd=request->antigen_data[d_hst.seq].antigen_cd)
     AND hst.product_id > 0.0
     AND hst.active_ind=1)
    JOIN (hp
    WHERE hp.product_id=hst.product_id
     AND hp.expire_dt_tm < datetimeadd(cnvtdatetime(curdate,curtime3),request->days_to_expire)
     AND hp.active_ind=1
     AND (((request->cur_owner_area_cd > 0.0)
     AND (hp.owner_area_cd=request->cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0.0)))
     AND (((request->cur_inv_area_cd > 0.0)
     AND (hp.inv_area_cd=request->cur_inv_area_cd)) OR ((request->cur_inv_area_cd=0.0)))
     AND (((request->abo_cd > 0.0)
     AND (hp.abo_cd=request->abo_cd)) OR ((request->abo_cd=0.0)))
     AND (((request->rh_cd > 0.0)
     AND (hp.rh_cd=request->rh_cd)) OR ((request->rh_cd=0.0))) )
    JOIN (pi
    WHERE pi.product_cd=hp.product_cd
     AND (pi.product_cat_cd=request->product_cd))
  ELSEIF ((request->search_type_flag=4)
   AND (request->product_cd=0.0))INTO "nl:"
   hp.product_id
   FROM (dummyt d_hst  WITH seq = value(request->antigen_count)),
    bbhist_special_testing hst,
    (dummyt d_hpe  WITH seq = value(request->states_count)),
    bbhist_product_event hpe,
    bbhist_product hp
   PLAN (d_hst)
    JOIN (hst
    WHERE (hst.special_testing_cd=request->antigen_data[d_hst.seq].antigen_cd)
     AND hst.product_id > 0.0
     AND hst.active_ind=1)
    JOIN (hpe
    WHERE hpe.product_id=hst.product_id
     AND hpe.active_ind=1)
    JOIN (d_hpe
    WHERE (request->states_data[d_hpe.seq].states_cd=hpe.event_type_cd))
    JOIN (hp
    WHERE hp.product_id=hpe.product_id
     AND hp.expire_dt_tm < datetimeadd(cnvtdatetime(curdate,curtime3),request->days_to_expire)
     AND hp.active_ind=1
     AND (((request->cur_owner_area_cd > 0.0)
     AND (hp.owner_area_cd=request->cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0.0)))
     AND (((request->cur_inv_area_cd > 0.0)
     AND (hp.inv_area_cd=request->cur_inv_area_cd)) OR ((request->cur_inv_area_cd=0.0)))
     AND (((request->abo_cd > 0.0)
     AND (hp.abo_cd=request->abo_cd)) OR ((request->abo_cd=0.0)))
     AND (((request->rh_cd > 0.0)
     AND (hp.rh_cd=request->rh_cd)) OR ((request->rh_cd=0.0))) )
  ELSE INTO "nl:"
   hp.product_id
   FROM (dummyt d_hst  WITH seq = value(request->antigen_count)),
    bbhist_special_testing hst,
    (dummyt d_hpe  WITH seq = value(request->states_count)),
    bbhist_product_event hpe,
    bbhist_product hp,
    product_index pi
   PLAN (d_hst)
    JOIN (hst
    WHERE (hst.special_testing_cd=request->antigen_data[d_hst.seq].antigen_cd)
     AND hst.product_id > 0.0
     AND hst.active_ind=1)
    JOIN (hpe
    WHERE hpe.product_id=hst.product_id
     AND hpe.active_ind=1)
    JOIN (d_hpe
    WHERE (request->states_data[d_hpe.seq].states_cd=hpe.event_type_cd))
    JOIN (hp
    WHERE hp.product_id=hpe.product_id
     AND hp.expire_dt_tm < datetimeadd(cnvtdatetime(curdate,curtime3),request->days_to_expire)
     AND hp.active_ind=1
     AND (((request->cur_owner_area_cd > 0.0)
     AND (hp.owner_area_cd=request->cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0.0)))
     AND (((request->cur_inv_area_cd > 0.0)
     AND (hp.inv_area_cd=request->cur_inv_area_cd)) OR ((request->cur_inv_area_cd=0.0)))
     AND (((request->abo_cd > 0.0)
     AND (hp.abo_cd=request->abo_cd)) OR ((request->abo_cd=0.0)))
     AND (((request->rh_cd > 0.0)
     AND (hp.rh_cd=request->rh_cd)) OR ((request->rh_cd=0.0))) )
    JOIN (pi
    WHERE pi.product_cd=hp.product_cd
     AND (pi.product_cat_cd=request->product_cd))
  ENDIF
  ORDER BY hp.product_id
  HEAD REPORT
   product_count = 0, stat = alterlist(reply->qual,50)
  HEAD hp.product_id
   product_count = (product_count+ 1)
   IF (mod(product_count,50)=1)
    stat = alterlist(reply->qual,(product_count+ 49))
   ENDIF
   reply->qual[product_count].product_id = hp.product_id, reply->qual[product_count].product_number
    = concat(trim(hp.supplier_prefix),trim(hp.product_nbr)), reply->qual[product_count].product_sub
    = hp.product_sub_nbr,
   reply->qual[product_count].abo_cd = hp.abo_cd, reply->qual[product_count].rh_cd = hp.rh_cd, reply
   ->qual[product_count].product_cd = hp.product_cd,
   reply->qual[product_count].exp_dt_tm = hp.expire_dt_tm, reply->qual[product_count].unit_of_meas_cd
    = hp.unit_meas_cd, reply->qual[product_count].volume_display = hp.volume,
   reply->qual[product_count].comment_ind = 0, reply->qual[product_count].cur_owner_area_cd = hp
   .owner_area_cd, reply->qual[product_count].cur_inv_area_cd = hp.inv_area_cd,
   reply->qual[product_count].alt_id_display = hp.alternate_nbr, reply->qual[product_count].
   electronic_entry_flag = 0, reply->qual[product_count].contributor_system_cd = hp
   .contributor_system_cd,
   reply->qual[product_count].cross_reference = hp.cross_reference, reply->qual[product_count].
   upload_dt_tm = hp.upload_dt_tm
  FOOT  hp.product_id
   row + 0
  FOOT REPORT
   stat = alterlist(reply->qual,product_count)
  WITH nocounter
 ;end select
 SET error_check = error(error_message,0)
 IF (error_check=0)
  IF (curqual=0)
   SET reply->status_data.status = "Z"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ELSE
  CALL errorhandler(sscriptname,"F","BBHIST_PRODUCT select",error_message)
  GO TO exit_script
 ENDIF
 IF (product_count > 0)
  SELECT INTO "nl:"
   hst.special_testing_cd
   FROM (dummyt d  WITH seq = value(product_count)),
    bbhist_special_testing hst
   PLAN (d)
    JOIN (hst
    WHERE (hst.product_id=reply->qual[d.seq].product_id)
     AND hst.active_ind=1)
   ORDER BY hst.product_id
   HEAD hst.product_id
    antigen_count = 0, stat = alterlist(reply->qual[d.seq].antigens,5)
   DETAIL
    antigen_count = (antigen_count+ 1)
    IF (mod(antigen_count,5)=1)
     stat = alterlist(reply->qual[d.seq].antigens,(antigen_count+ 4))
    ENDIF
    reply->qual[d.seq].antigens[antigen_count].antigen_cd = hst.special_testing_cd
   FOOT  hst.product_id
    stat = alterlist(reply->qual[d.seq].antigens,antigen_count)
   WITH nocounter
  ;end select
  SET error_check = error(error_message,0)
  IF (error_check != 0)
   CALL errorhandler(sscriptname,"F","BBHIST_SPECIAL_TESTING select",error_message)
   GO TO exit_script
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
  SELECT INTO "nl:"
   hpe.event_type_cd
   FROM (dummyt d  WITH seq = value(product_count)),
    bbhist_product_event hpe
   PLAN (d)
    JOIN (hpe
    WHERE (hpe.product_id=reply->qual[d.seq].product_id)
     AND hpe.active_ind=1)
   HEAD hpe.product_id
    states_count = 0, stat = alterlist(reply->qual[d.seq].states,5)
   HEAD hpe.event_type_cd
    states_count = (states_count+ 1)
    IF (mod(states_count,5)=1)
     stat = alterlist(reply->qual[d.seq].states,(states_count+ 4))
    ENDIF
    reply->qual[d.seq].states[states_count].states_cd = hpe.event_type_cd
   FOOT  hpe.product_id
    stat = alterlist(reply->qual[d.seq].states,states_count)
   WITH nocounter
  ;end select
  SET error_check = error(error_message,0)
  IF (error_check != 0)
   CALL errorhandler(sscriptname,"F","BBHIST_PRODUCT_EVENT select",error_message)
   GO TO exit_script
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
  SELECT INTO "nl:"
   pn.product_id, pn.active_ind
   FROM (dummyt d  WITH seq = value(product_count)),
    product_note pn
   PLAN (d)
    JOIN (pn
    WHERE (pn.bbhist_product_id=reply->qual[d.seq].product_id)
     AND pn.active_ind=1)
   ORDER BY pn.bbhist_product_id
   DETAIL
    reply->qual[d.seq].comment_ind = 1
   WITH nocounter
  ;end select
  SET error_check = error(error_message,0)
  IF (error_check != 0)
   CALL errorhandler(sscriptname,"F","PRODUCT_NOTE select",error_message)
   GO TO exit_script
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
 DECLARE errorhandler(operationname=c25,operationstatus=c1,targetobjectname=c25,targetobjectvalue=vc)
  = null
 SUBROUTINE errorhandler(operationname,operationstatus,targetobjectname,targetobjectvalue)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = operationname
   SET reply->status_data.subeventstatus[1].operationstatus = operationstatus
   SET reply->status_data.subeventstatus[1].targetobjectname = targetobjectname
   SET reply->status_data.subeventstatus[1].targetobjectvalue = targetobjectvalue
 END ;Subroutine
#exit_script
 IF ((request->debug_ind=1))
  CALL echorecord(request)
  CALL echorecord(reply)
 ENDIF
END GO
