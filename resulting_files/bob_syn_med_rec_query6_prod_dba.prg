CREATE PROGRAM bob_syn_med_rec_query6_prod:dba
 DECLARE log_message = vc WITH noconstant(" ")
 FREE RECORD t_record
 RECORD t_record(
   1 person_id = f8
   1 encntr_id = f8
   1 order_cnt = i4
   1 orders[*]
     2 order_id = f8
     2 compliance_ind = i2
 )
 SET t_record->person_id = trigger_personid
 SET t_record->encntr_id = trigger_encntrid
 SET retval = 50
 DECLARE med_rec_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"MEDRECONCILIATION"))
 DECLARE pharm_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6000,"PHARMACY"))
 DECLARE not_taking_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",30254,"NOTTAKING"))
 DECLARE still_as_prescribed_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",30254,
   "STILLTAKINGASPRESCRIBED"))
 DECLARE still_not_as_prescribed_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",30254,
   "STILLTAKINGNOTASPRESCRIBED"))
 DECLARE given_in_office_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",30254,
   "GIVENINPHYSICIANOFFICE"))
 DECLARE unable_to_obtain_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",30254,"UNABLETOOBTAIN"))
 DECLARE investigating_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",30254,"INVESTIGATING"))
 DECLARE ordered_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED"))
 DECLARE suspended_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"SUSPENDED"))
 SELECT INTO "nl:"
  FROM orders o
  PLAN (o
   WHERE (o.person_id=t_record->person_id)
    AND o.orig_ord_as_flag IN (1, 2, 3)
    AND ((o.order_status_cd+ 0) IN (ordered_cd, suspended_cd)))
  DETAIL
   t_record->order_cnt = (t_record->order_cnt+ 1), stat = alterlist(t_record->orders,t_record->
    order_cnt), t_record->orders[t_record->order_cnt].order_id = o.order_id
  WITH nocounter
 ;end select
 IF ((t_record->order_cnt=0))
  CALL echo("No orders found.")
  SET retval = 0
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = t_record->order_cnt),
   order_compliance_detail ocd,
   order_compliance oc
  PLAN (d)
   JOIN (ocd
   WHERE (ocd.order_nbr=t_record->orders[d.seq].order_id))
   JOIN (oc
   WHERE oc.order_compliance_id=ocd.order_compliance_id
    AND (oc.encntr_id=t_record->encntr_id))
  ORDER BY ocd.order_nbr, ocd.updt_dt_tm DESC
  HEAD ocd.order_nbr
   IF (ocd.compliance_status_cd IN (not_taking_cd, still_as_prescribed_cd, still_not_as_prescribed_cd,
   given_in_office_cd))
    t_record->orders[d.seq].compliance_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = t_record->order_cnt)
  PLAN (d
   WHERE (t_record->orders[d.seq].compliance_ind=0))
  DETAIL
   retval = 100
  WITH nocounter
 ;end select
 IF (retval=100)
  GO TO exit_script
 ENDIF
 SET retval = 0
#exit_script
 CALL echorecord(t_record)
 CALL echo(build(log_message,"retval=",retval))
END GO
