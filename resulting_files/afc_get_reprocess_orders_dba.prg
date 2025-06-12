CREATE PROGRAM afc_get_reprocess_orders:dba
 RECORD orders(
   1 order_qual = i4
   1 orders[*]
     2 order_id = f8
     2 catalog_cd = f8
     2 m_cs_order_id = f8
     2 cs_order_id = f8
     2 cs_catalog_cd = f8
     2 order_mnemonic = c25
     2 orig_order_dt_tm = dq8
     2 person_id = f8
     2 person_name = c25
     2 encntr_id = f8
     2 activity_type_cd = f8
     2 activity_type_disp = c20
     2 accession = c18
     2 order_status_cd = f8
     2 ordered_flag = i2
     2 inlab_flag = i2
     2 collected_flag = i2
     2 completed_flag = i2
     2 charge_event_id = f8
     2 ce_ordered_flag = i2
     2 ce_collected_flag = i2
     2 ce_completed_flag = i2
     2 ce_inlab_flag = i2
     2 quantity = i4
     2 start_dt_tm = dq8
     2 stop_dt_tm = dq8
     2 service_resource_cd = f8
 )
 SET afc_get_reprocess_orders_vrsn = "42414.009"
 DECLARE code_set = i4
 DECLARE cdf_meaning = c12
 DECLARE cnt = i4
 SET begdate = format(cnvtdatetime(request->beg_dt_tm),"dd-mmm-yyyy hh:mm:ss;;d")
 SET enddate = format(cnvtdatetime(request->end_dt_tm),"dd-mmm-yyyy hh:mm:ss;;d")
 CALL echo(begdate,0)
 CALL echo(" to ",0)
 CALL echo(enddate)
 DECLARE ce_ordered = f8
 SET code_set = 13029
 SET cdf_meaning = "ORDERED"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,ce_ordered)
 DECLARE ce_collected = f8
 SET code_set = 13029
 SET cdf_meaning = "COLLECTED"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,ce_collected)
 DECLARE ce_complete = f8
 SET code_set = 13029
 SET cdf_meaning = "COMPLETE"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,ce_complete)
 DECLARE ce_inlab = f8
 SET code_set = 13029
 SET cdf_meaning = "IN LAB"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,ce_inlab)
 EXECUTE afc_get_missing_orders
 CALL echo(build("CE_ORDERED: ",ce_ordered))
 CALL echo(build("CE_COLLECTED: ",ce_collected))
 CALL echo(build("CE_COMPLETE: ",ce_complete))
 DECLARE ce_ord_cont = f8
 DECLARE code_set = i4
 DECLARE cdf_meaning = c12
 DECLARE cnt = i4
 SET code_set = 13016
 SET cdf_meaning = "ORD ID"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,ce_ord_cont)
 DECLARE ce_ord_cat_cont = f8
 SET code_set = 13016
 SET cdf_meaning = "ORD CAT"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,ce_ord_cat_cont)
 SET count = 0
 SELECT INTO "nl:"
  d1.seq
  FROM (dummyt d1  WITH seq = value(orders->order_qual))
  ORDER BY orders->orders[d1.seq].person_id, orders->orders[d1.seq].orig_order_dt_tm
  DETAIL
   IF ((((orders->orders[d1.seq].ce_completed_flag=0)
    AND (orders->orders[d1.seq].completed_flag=1)) OR ((((orders->orders[d1.seq].ce_ordered_flag=0)
    AND (orders->orders[d1.seq].ordered_flag=1)) OR ((((orders->orders[d1.seq].ce_collected_flag=0)
    AND (orders->orders[d1.seq].collected_flag=1)) OR ((orders->orders[d1.seq].ce_inlab_flag=0)
    AND (orders->orders[d1.seq].inlab_flag=1))) )) )) )
    count = (count+ 1), count2 = 0, reply->charge_event_qual = count,
    stat = alterlist(reply->charge_event,count), reply->charge_event[count].ext_master_event_id =
    IF ((orders->orders[d1.seq].cs_order_id != 0)) orders->orders[d1.seq].cs_order_id
    ELSE orders->orders[d1.seq].order_id
    ENDIF
    , reply->charge_event[count].ext_master_event_cont_cd = ce_ord_cont,
    reply->charge_event[count].ext_master_reference_id =
    IF ((orders->orders[d1.seq].cs_catalog_cd != 0)) orders->orders[d1.seq].cs_catalog_cd
    ELSE orders->orders[d1.seq].catalog_cd
    ENDIF
    , reply->charge_event[count].ext_master_reference_cont_cd = ce_ord_cat_cont, reply->charge_event[
    count].ext_parent_event_id =
    IF ((orders->orders[d1.seq].cs_order_id != 0)) orders->orders[d1.seq].cs_order_id
    ELSE 0
    ENDIF
    ,
    reply->charge_event[count].ext_parent_event_cont_cd =
    IF ((orders->orders[d1.seq].cs_order_id != 0)) ce_ord_cont
    ELSE 0
    ENDIF
    , reply->charge_event[count].ext_parent_reference_id =
    IF ((orders->orders[d1.seq].cs_order_id != 0)) orders->orders[d1.seq].cs_catalog_cd
    ELSE 0
    ENDIF
    , reply->charge_event[count].ext_parent_reference_cont_cd =
    IF ((orders->orders[d1.seq].cs_order_id != 0)) ce_ord_cat_cont
    ELSE 0
    ENDIF
    ,
    reply->charge_event[count].ext_item_event_id = orders->orders[d1.seq].order_id, reply->
    charge_event[count].ext_item_event_cont_cd = ce_ord_cont, reply->charge_event[count].
    ext_item_reference_id = orders->orders[d1.seq].catalog_cd,
    reply->charge_event[count].ext_item_reference_cont_cd = ce_ord_cat_cont, reply->charge_event[
    count].order_id = orders->orders[d1.seq].order_id, reply->charge_event[count].order_mnemonic =
    orders->orders[d1.seq].order_mnemonic,
    reply->charge_event[count].activity_type_disp = orders->orders[d1.seq].activity_type_disp, reply
    ->charge_event[count].person_id = orders->orders[d1.seq].person_id, reply->charge_event[count].
    person_name = orders->orders[d1.seq].person_name,
    reply->charge_event[count].encntr_id = orders->orders[d1.seq].encntr_id, reply->charge_event[
    count].accession = orders->orders[d1.seq].accession
    IF ((orders->orders[d1.seq].ce_ordered_flag=0)
     AND (orders->orders[d1.seq].ordered_flag=1))
     count2 = (count2+ 1), stat = alterlist(reply->charge_event[count].charge_event_act,count2),
     reply->charge_event[count].charge_event_act[count2].charge_type_cd = 0,
     reply->charge_event[count].charge_event_act[count2].cea_type_cd = ce_ordered, reply->
     charge_event[count].charge_event_act[count2].service_resource_cd = orders->orders[d1.seq].
     service_resource_cd, reply->charge_event[count].charge_event_act[count2].service_dt_tm = orders
     ->orders[d1.seq].orig_order_dt_tm,
     reply->charge_event[count].charge_event_act[count2].quantity = orders->orders[d1.seq].quantity,
     reply->charge_event[count].charge_event_act[count2].result = cnvtstring(datetimediff(orders->
       orders[d1.seq].stop_dt_tm,orders->orders[d1.seq].start_dt_tm,4))
    ENDIF
    IF ((orders->orders[d1.seq].ce_collected_flag=0)
     AND (orders->orders[d1.seq].collected_flag=1))
     count2 = (count2+ 1), stat = alterlist(reply->charge_event[count].charge_event_act,count2),
     reply->charge_event[count].charge_event_act[count2].charge_type_cd = 0,
     reply->charge_event[count].charge_event_act[count2].cea_type_cd = ce_collected, reply->
     charge_event[count].charge_event_act[count2].service_resource_cd = orders->orders[d1.seq].
     service_resource_cd, reply->charge_event[count].charge_event_act[count2].service_dt_tm = orders
     ->orders[d1.seq].orig_order_dt_tm,
     reply->charge_event[count].charge_event_act[count2].quantity = orders->orders[d1.seq].quantity,
     reply->charge_event[count].charge_event_act[count2].result = cnvtstring(datetimediff(orders->
       orders[d1.seq].stop_dt_tm,orders->orders[d1.seq].start_dt_tm,4))
    ENDIF
    IF ((orders->orders[d1.seq].ce_completed_flag=0)
     AND (orders->orders[d1.seq].completed_flag=1))
     count2 = (count2+ 1), stat = alterlist(reply->charge_event[count].charge_event_act,count2),
     reply->charge_event[count].charge_event_act[count2].charge_type_cd = 0,
     reply->charge_event[count].charge_event_act[count2].cea_type_cd = ce_complete, reply->
     charge_event[count].charge_event_act[count2].service_resource_cd = orders->orders[d1.seq].
     service_resource_cd, reply->charge_event[count].charge_event_act[count2].service_dt_tm = orders
     ->orders[d1.seq].orig_order_dt_tm,
     reply->charge_event[count].charge_event_act[count2].quantity = orders->orders[d1.seq].quantity,
     reply->charge_event[count].charge_event_act[count2].result = cnvtstring(datetimediff(orders->
       orders[d1.seq].stop_dt_tm,orders->orders[d1.seq].start_dt_tm,4))
    ENDIF
    IF ((orders->orders[d1.seq].ce_inlab_flag=0)
     AND (orders->orders[d1.seq].inlab_flag=1))
     count2 = (count2+ 1), stat = alterlist(reply->charge_event[count].charge_event_act,count2),
     reply->charge_event[count].charge_event_act[count2].charge_type_cd = 0,
     reply->charge_event[count].charge_event_act[count2].cea_type_cd = ce_inlab, reply->charge_event[
     count].charge_event_act[count2].service_resource_cd = orders->orders[d1.seq].service_resource_cd,
     reply->charge_event[count].charge_event_act[count2].service_dt_tm = orders->orders[d1.seq].
     orig_order_dt_tm,
     reply->charge_event[count].charge_event_act[count2].quantity = orders->orders[d1.seq].quantity,
     reply->charge_event[count].charge_event_act[count2].result = cnvtstring(datetimediff(orders->
       orders[d1.seq].stop_dt_tm,orders->orders[d1.seq].start_dt_tm,4))
    ENDIF
    reply->charge_event[count].charge_event_act_qual = count2
   ENDIF
  WITH nocounter
 ;end select
 SET reply->charge_event_qual = count
 FREE SET orders
END GO
