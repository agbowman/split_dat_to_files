CREATE PROGRAM ddbuildpgm4_q
 PROMPT
  "Output to File/Printer/MINE " = mine,
  "Enter Verified Date " = 091797
 SET maxsecs = 0
 IF (isodbc)
  SET maxsecs = 10
 ENDIF
 SELECT DISTINCT INTO  $1
  c.accession_nbr, c.event_cd, event_disp = uar_get_code_display(c.event_cd),
  c.event_tag, c.verified_dt_tm"MMMMMMMMM DD, YYYY;;D", p.name_full_formatted,
  p.sex_cd, sex_disp = uar_get_code_display(p.sex_cd), e.encntr_type_cd,
  encntr_type_disp = uar_get_code_display(e.encntr_type_cd), e.location_cd, location_disp =
  uar_get_code_display(e.location_cd),
  e.updt_dt_tm, e.active_ind, o.person_id,
  o.order_mnemonic
  FROM clinical_event c,
   person p,
   encounter e,
   orders o
  PLAN (c
   WHERE c.verified_dt_tm BETWEEN cnvtdatetime(cnvtdate( $2),0) AND cnvtdatetime(cnvtdate( $2),235959
    )
    AND c.event_cd BETWEEN 16354 AND 16360)
   JOIN (p
   WHERE p.person_id=c.person_id
    AND p.sex_cd=2342)
   JOIN (e
   WHERE e.encntr_id=c.encntr_id
    AND e.active_ind=1)
   JOIN (o
   WHERE o.person_id=p.person_id
    AND o.order_mnemonic="Add US")
  ORDER BY c.accession_nbr, c.event_cd
  WITH format, maxrec = 100, maxcol = 250,
   time = value(maxsecs)
 ;end select
END GO
