CREATE PROGRAM bhs_shields_med_orders
 RECORD temp(
   1 qual[*]
     2 t_order_id = f8
 )
 SET tmp_cnt = 0
 SET t_order_id = 0
 SELECT
  ord.order_id
  FROM orders ord,
   person p,
   encntr_alias ea
  WHERE ord.person_id=p.person_id
   AND ea.encntr_id=ord.encntr_id
   AND ord.contributor_system_cd=196965398.00
   AND ((ord.last_update_provider_id+ 0)=0)
   AND ea.encntr_alias_type_cd=1079
   AND ord.orig_order_dt_tm >= cnvtdatetime("10-aug-2010")
   AND ord.orig_order_dt_tm <= cnvtdatetime("11-may-2011")
   AND ea.active_ind=1
   AND ea.beg_effective_dt_tm < sysdate
   AND ea.end_effective_dt_tm > sysdate
  DETAIL
   tmp_cnt = (tmp_cnt+ 1), stat = alterlist(temp->qual,tmp_cnt), temp->qual[tmp_cnt].t_order_id = ord
   .order_id
 ;end select
 UPDATE  FROM (dummyt d  WITH seq = value(tmp_cnt)),
   order_radiology o
  SET o.exam_status_cd = 4226, o.start_dt_tm = null, o.complete_dt_tm = null
  PLAN (d)
   JOIN (o
   WHERE (o.order_id=temp->qual[d.seq].t_order_id))
  WITH nocounter
 ;end update
 CALL echo(build("number updated :",curqual))
 CALL echo(build("order_id:",temp->qual[tmp_cnt].t_order_id))
 COMMIT
END GO
