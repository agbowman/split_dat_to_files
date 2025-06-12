CREATE PROGRAM bhs_sys_future_ord_update:dba
 SET 6hrs = cnvtlookbehind("6,H",cnvtdatetime(curdate,curtime3))
 FREE RECORD temp
 RECORD temp(
   1 cnt = i4
   1 qual[*]
     2 oid = f8
     2 o_pid = f8
     2 o_dt = vc
     2 e_eid = f8
     2 e_pid = f8
     2 e_reg = vc
     2 e_dc = vc
 )
 SELECT INTO "nl:"
  o.active_ind, o_active_status_disp = uar_get_code_display(o.active_status_cd), o_activity_type_disp
   = uar_get_code_display(o.activity_type_cd),
  o_catalog_disp = uar_get_code_display(o.catalog_cd), o.encntr_id, o_order_status_disp =
  uar_get_code_display(o.order_status_cd),
  o_dept_status_disp = uar_get_code_display(o.dept_status_cd), o.order_mnemonic, o.active_status_cd,
  o.activity_type_cd, o.catalog_cd, o.order_status_cd,
  o.dept_status_cd, o.order_id, o.encntr_id,
  o.person_id, e.encntr_id, e.person_id,
  e.reg_dt_tm, e.disch_dt_tm
  FROM orders o,
   encounter e
  PLAN (o
   WHERE o.encntr_id=0
    AND ((o.dept_status_cd+ 0)=9327.00))
   JOIN (e
   WHERE e.person_id=o.person_id
    AND e.disch_dt_tm IS NOT null
    AND e.disch_dt_tm < cnvtlookbehind("6,H")
    AND e.encntr_class_cd=319456.00
    AND o.orig_order_dt_tm BETWEEN e.reg_dt_tm AND e.disch_dt_tm)
  DETAIL
   temp->cnt = (temp->cnt+ 1), stat = alterlist(temp->qual,temp->cnt), temp->qual[temp->cnt].oid = o
   .order_id,
   temp->qual[temp->cnt].o_pid = o.person_id, temp->qual[temp->cnt].o_dt = format(o.orig_order_dt_tm,
    "mm/dd/yyyy hh:mm;;q"), temp->qual[temp->cnt].e_eid = e.encntr_id,
   temp->qual[temp->cnt].e_pid = e.person_id, temp->qual[temp->cnt].e_reg = format(e.reg_dt_tm,
    "mm/dd/yyyy hh:mm;;q"), temp->qual[temp->cnt].e_dc = format(e.disch_dt_tm,"mm/dd/yyyy hh:mm;;q")
  WITH nocounter
 ;end select
 FOR (x = 1 TO temp->cnt)
  UPDATE  FROM orders o
   SET o.dept_status_cd = 9314, o.order_status_cd = 2545, o.encntr_id = temp->qual[x].e_eid
   WHERE (o.order_id=temp->qual[x].oid)
  ;end update
  COMMIT
 ENDFOR
END GO
