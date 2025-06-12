CREATE PROGRAM cls_dischdispreview
 PROMPT
  "Output to File/Printer/MINE" = mine
  WITH outdev
 IF (validate(isodbc,0)=0)
  EXECUTE cclseclogin
 ENDIF
 SET maxsecs = 0
 IF (validate(isodbc,0)=1)
  SET maxsecs = 15
 ENDIF
 SELECT INTO  $OUTDEV
  dischdttm = format(e.disch_dt_tm,"MM/DD/YYYY HH:MM;;D"), e_disch_disposition_disp =
  uar_get_code_display(e.disch_disposition_cd), e.encntr_id,
  e.person_id, p.person_id, p.name_full_formatted,
  e.disch_dt_tm
  FROM encounter e,
   person p
  PLAN (e
   WHERE e.disch_dt_tm != null)
   JOIN (p
   WHERE e.person_id=p.person_id)
  ORDER BY e.disch_dt_tm, e.encntr_id
  WITH maxrec = 1000, maxcol = 170, maxrow = 48,
   landscape, compress
 ;end select
END GO
