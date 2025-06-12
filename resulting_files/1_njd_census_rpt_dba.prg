CREATE PROGRAM 1_njd_census_rpt:dba
 PROMPT
  "Output to File/Printer/MINE" = mine
  WITH outdev
 IF (validate(isodbc,0)=0)
  EXECUTE cclseclogin
 ENDIF
 IF (validate(_separator)=0)
  SET _separator = " "
 ENDIF
 SET maxsecs = 0
 IF (validate(isodbc,0)=1)
  SET maxsecs = 15
 ENDIF
 SELECT INTO  $OUTDEV
  p.name_full_formatted, p.person_id, ed.encntr_id,
  e_loc_nurse_unit_disp = uar_get_code_display(e.loc_nurse_unit_cd), e_loc_room_disp =
  uar_get_code_display(e.loc_room_cd), e_loc_bed_disp = uar_get_code_display(e.loc_bed_cd),
  e_encntr_class_disp = uar_get_code_display(e.encntr_class_cd), e.reg_dt_tm, e.encntr_id,
  ed_encntr_domain_type_disp = uar_get_code_display(ed.encntr_domain_type_cd)
  FROM encounter e,
   encntr_domain ed,
   person p
  PLAN (ed)
   JOIN (e
   WHERE ed.encntr_id=e.encntr_id)
   JOIN (p
   WHERE p.person_id=e.person_id)
  ORDER BY e_loc_nurse_unit_disp, e_loc_room_disp, e_loc_bed_disp
  WITH maxrec = 100, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO
