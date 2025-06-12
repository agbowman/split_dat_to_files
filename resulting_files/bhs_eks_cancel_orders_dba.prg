CREATE PROGRAM bhs_eks_cancel_orders:dba
 SET oid = link_orderid
 SET retval = 0
 IF (oid=0)
  GO TO exist_script
 ENDIF
 DECLARE ordered_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 DECLARE x = i4
 DECLARE v_stop_dt_tm = q8
 FREE SET t_record
 RECORD t_record(
   1 discontinued_cd = f8
   1 discontinued_meaning = c12
   1 discontinue_cd = f8
   1 discontinue_meaning = c12
   1 new_ord_start_dt_tm = dq8
   1 order_cnt = i4
   1 orders[*]
     2 order_id = f8
     2 catalog_cd = f8
     2 catalog_type_cd = f8
     2 updt_cnt = i4
     2 oe_format_id = f8
     2 start_dt_tm = dq8
 )
 SELECT INTO "nl:"
  FROM orders o,
   orders o2
  PLAN (o
   WHERE o.order_id=oid)
   JOIN (o2
   WHERE o2.encntr_id=o.encntr_id
    AND o2.catalog_cd=o.catalog_cd
    AND o2.order_status_cd=ordered_cd)
  HEAD REPORT
   t_record->order_cnt = 0
  DETAIL
   t_record->order_cnt = (t_record->order_cnt+ 1), stat = alterlist(t_record->orders,t_record->
    order_cnt), t_record->orders[t_record->order_cnt].order_id = o2.order_id,
   t_record->orders[t_record->order_cnt].catalog_cd = o2.catalog_cd, t_record->orders[t_record->
   order_cnt].catalog_type_cd = o2.catalog_type_cd, t_record->orders[t_record->order_cnt].updt_cnt =
   o2.updt_cnt,
   t_record->orders[t_record->order_cnt].oe_format_id = o2.oe_format_id, t_record->orders[t_record->
   order_cnt].start_dt_tm = o2.current_start_dt_tm
  WITH nocounter
 ;end select
 SET t_record->discontinued_cd = 0.0
 SET t_record->discontinued_meaning = "DISCONTINUED"
 SET stat = uar_get_meaning_by_codeset(6004,t_record->discontinued_meaning,1,t_record->
  discontinued_cd)
 SET t_record->discontinue_cd = 0.0
 SET t_record->discontinue_meaning = "DISCONTINUE"
 SET stat = uar_get_meaning_by_codeset(6003,t_record->discontinue_meaning,1,t_record->discontinue_cd)
 SET v_stop_dt_tm = t_record->new_ord_start_dt_tm
 SET x = 0
 FOR (x = 1 TO t_record->order_cnt)
   SET stat = uar_fill_order_request()
   CALL echo(build("orderid:",t_record->orders[x].order_id))
   SET stat = uar_fill_order(t_record->orders[x].order_id,t_record->discontinued_cd,t_record->
    discontinue_cd,nullterm("STATUSCHANGE"),t_record->orders[x].catalog_cd,
    t_record->orders[x].catalog_type_cd,t_record->orders[x].updt_cnt,t_record->orders[x].oe_format_id
    )
   SET stat = uar_order_perform()
   CALL echo(build(" UAR_ORDER_PERFORM ():",stat))
   COMMIT
 ENDFOR
 SET retval = 100
#exit_script
END GO
