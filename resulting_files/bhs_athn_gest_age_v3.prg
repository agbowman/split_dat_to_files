CREATE PROGRAM bhs_athn_gest_age_v3
 DECLARE person_id = f8 WITH protect, constant( $2)
 FREE RECORD oreply
 RECORD oreply(
   1 person_id = vc
   1 gest_age_at_birth = vc
   1 active_dt_tm = vc
 )
 SELECT INTO "nl:"
  FROM person_patient p
  PLAN (p
   WHERE p.person_id=person_id
    AND p.beg_effective_dt_tm < sysdate
    AND p.end_effective_dt_tm > sysdate
    AND p.active_ind=1)
  HEAD REPORT
   oreply->person_id = cnvtstring(p.person_id), oreply->gest_age_at_birth = cnvtstring(p
    .gest_age_at_birth), oreply->active_dt_tm = format(p.active_status_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"
    )
  WITH nocounter, nullreport, formfeed = none,
   maxrec = 1, format = variable, maxrow = 0,
   time = 10
 ;end select
 SET _memory_reply_string = cnvtrectojson(oreply,5)
END GO
