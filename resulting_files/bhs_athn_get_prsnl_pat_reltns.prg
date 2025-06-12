CREATE PROGRAM bhs_athn_get_prsnl_pat_reltns
 RECORD out_rec(
   1 encntr_reltn = vc
   1 person_reltn = vc
 )
 DECLARE person_id = f8
 SET out_rec->encntr_reltn = "NO"
 SET out_rec->person_reltn = "NO"
 SELECT INTO "nl:"
  FROM encounter e
  PLAN (e
   WHERE (e.encntr_id= $2))
  HEAD REPORT
   person_id = e.person_id
  WITH nocounter, time = 30
 ;end select
 SELECT INTO "nl:"
  FROM encntr_prsnl_reltn epr
  PLAN (epr
   WHERE (epr.encntr_id= $2)
    AND (epr.prsnl_person_id= $3)
    AND epr.active_ind=1
    AND ((epr.expire_dt_tm > sysdate) OR (epr.expire_dt_tm = null)) )
  HEAD REPORT
   out_rec->encntr_reltn = "YES"
  WITH nocounter, time = 30
 ;end select
 SELECT INTO "nl:"
  FROM person_prsnl_reltn ppr
  PLAN (ppr
   WHERE ppr.person_id=person_id
    AND (ppr.prsnl_person_id= $3)
    AND ppr.active_ind=1
    AND ppr.beg_effective_dt_tm < sysdate
    AND ppr.end_effective_dt_tm > sysdate)
  HEAD REPORT
   out_rec->person_reltn = "YES"
  WITH nocounter, time = 30
 ;end select
 CALL echojson(out_rec, $1)
END GO
