CREATE PROGRAM bhs_syn_med_rec_query6_build:dba
 DECLARE log_message = vc WITH noconstant(" ")
 FREE RECORD t_record
 RECORD t_record(
   1 person_id = f8
   1 perf_dt_tm = dq8
   1 orders[*]
     2 order_id = f8
     2 compliance_ind = i2
 )
 SET retval = 0
 SET t_record->person_id = trigger_personid
 DECLARE med_rec_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"MEDRECONCILIATION"))
 DECLARE pharm_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6000,"PHARMACY"))
 DECLARE not_taking_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",30254,"NOTTAKING"))
 DECLARE still_as_prescribed_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",30254,
   "STILLTAKINGASPRESCRIBED"))
 DECLARE still_not_as_prescribed_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",30254,
   "STILLTAKINGNOTASPRESCRIBED"))
 DECLARE ordered_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED"))
 DECLARE suspended_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"SUSPENDED"))
 DECLARE compliance_ind = i2
 SET compliance_ind = 1
 SELECT INTO "nl:"
  FROM orders o
  PLAN (o
   WHERE (o.person_id=t_record->person_id)
    AND o.orig_ord_as_flag IN (1, 2, 3)
    AND ((o.order_status_cd+ 0) IN (ordered_cd, suspended_cd))
    AND  NOT ( EXISTS (
   (SELECT
    oc.order_nbr
    FROM order_compliance_detail oc
    WHERE oc.order_nbr=o.order_id
     AND oc.compliance_status_cd IN (not_taking_cd, still_as_prescribed_cd,
    still_not_as_prescribed_cd)))))
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET retval = 100
 ELSE
  SET retval = 0
 ENDIF
 SET log_message = build(log_message,"retval = ",retval)
END GO
