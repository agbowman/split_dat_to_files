CREATE PROGRAM dcp_apache_recalc_all_patients:dba
 DECLARE count = i4
 FREE RECORD request
 RECORD request(
   1 person_id = f8
   1 encntr_id = f8
   1 cc_start_day = i2
   1 icu_admit_dt_tm = dq8
 )
 RECORD recalc_list(
   1 count = i4
   1 list[*]
     2 person_id = f8
     2 encntr_id = f8
     2 icu_admit_dt_tm = dq8
     2 person_id = f8
 )
 EXECUTE apachertl
 SELECT INTO "nl:"
  FROM risk_adjustment ra,
   risk_adjustment_day rad
  PLAN (ra
   WHERE ra.active_ind=1)
   JOIN (rad
   WHERE ra.risk_adjustment_id=rad.risk_adjustment_id
    AND rad.active_ind=1
    AND rad.cc_day=1)
  HEAD REPORT
   recalc_list->count = 0, count = 0
  DETAIL
   count = (count+ 1), stat = alterlist(recalc_list->list,count), recalc_list->list[count].encntr_id
    = ra.encntr_id,
   recalc_list->list[count].person_id = ra.person_id, recalc_list->list[count].icu_admit_dt_tm = ra
   .icu_admit_dt_tm, recalc_list->count = count
  WITH nocounter
 ;end select
 CALL echo(build("going to recalc patients =",recalc_list->count))
 FOR (x = 1 TO recalc_list->count)
   SET request->encntr_id = recalc_list->list[x].encntr_id
   SET request->person_id = recalc_list->list[x].person_id
   SET request->icu_admit_dt_tm = recalc_list->list[x].icu_admit_dt_tm
   SET request->cc_start_day = 1
   EXECUTE dcp_recalc_apache_predictions
 ENDFOR
#9999_exit_program
END GO
