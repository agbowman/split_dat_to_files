CREATE PROGRAM bhs_athn_get_encntr_ids
 RECORD out_rec(
   1 encntr_ids = vc
 )
 DECLARE t_line = vc
 SELECT INTO "nl:"
  FROM encounter e
  PLAN (e
   WHERE (e.person_id= $2)
    AND e.active_ind=1)
  ORDER BY e.encntr_id
  HEAD REPORT
   first_ind = 1
  HEAD e.encntr_id
   IF (first_ind=0)
    t_line = concat(trim(t_line),char(44),trim(cnvtstring(e.encntr_id)))
   ELSE
    first_ind = 0, t_line = trim(cnvtstring(e.encntr_id))
   ENDIF
  FOOT REPORT
   out_rec->encntr_ids = t_line
  WITH nocounter, time = 30
 ;end select
 CALL echojson(out_rec, $1)
END GO
