CREATE PROGRAM agc_test_emc
 SELECT
  p.name_full_formatted, ppr.*
  FROM person p,
   person_person_reltn ppr
  PLAN (ppr
   WHERE ppr.active_ind >= 1
    AND ppr.person_reltn_type_cd=1152
    AND ppr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ppr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (p
   WHERE ppr.related_person_id=p.person_id)
 ;end select
END GO
