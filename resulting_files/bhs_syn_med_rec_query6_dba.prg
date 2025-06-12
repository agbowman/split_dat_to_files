CREATE PROGRAM bhs_syn_med_rec_query6:dba
 FREE RECORD t_record
 RECORD t_record(
   1 encntr_id = f8
   1 perf_dt_tm = dq8
   1 orders[*]
     2 order_id = f8
     2 compliance_ind = i2
 )
 SET retval = 0
 SET t_record->encntr_id = trigger_encntrid
 DECLARE med_rec_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"MEDRECONCILIATION"))
 DECLARE pharm_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6000,"PHARMACY"))
 DECLARE unable_to_obtain_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",30254,"UNABLETOOBTAIN"))
 DECLARE investigating_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",30254,"INVESTIGATING"))
 DECLARE ordered_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED"))
 DECLARE suspended_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"SUSPENDED"))
 DECLARE compliance_ind = i2
 SET compliance_ind = 1
 SELECT INTO "nl:"
  FROM orders o
  PLAN (o
   WHERE (o.encntr_id=t_record->encntr_id)
    AND o.orig_ord_as_flag IN (1, 2, 3)
    AND ((o.order_status_cd+ 0) IN (ordered_cd, suspended_cd)))
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (cnt > size(t_record->orders,5))
    stat = alterlist(t_record->orders,(cnt+ 10))
   ENDIF
   t_record->orders[cnt].order_id = o.order_id
  FOOT REPORT
   stat = alterlist(t_record->orders,cnt)
 ;end select
 SELECT INTO "nl:"
  FROM order_compliance_detail oc,
   (dummyt d  WITH seq = value(size(t_record->orders,5)))
  PLAN (d)
   JOIN (oc
   WHERE (oc.order_nbr=t_record->orders[d.seq].order_id)
    AND  NOT (oc.compliance_status_cd IN (unable_to_obtain_cd, investigating_cd)))
  DETAIL
   t_record->orders[d.seq].compliance_ind = 1
  WITH nocounter
 ;end select
 FOR (x = 1 TO size(t_record->orders,5))
   IF ((t_record->orders[x].compliance_ind=0))
    SET compliance_ind = 0
   ENDIF
 ENDFOR
 CALL echorecord(t_record)
 IF (compliance_ind=1)
  SET retval = 0
 ELSE
  SET retval = 100
 ENDIF
END GO
