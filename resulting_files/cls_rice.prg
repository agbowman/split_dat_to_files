CREATE PROGRAM cls_rice
 PROMPT
  "Output to File/Printer/MINE" = mine
  WITH outdev
 IF (validate(isodbc,0)=0)
  EXECUTE cclseclogin
 ENDIF
 SELECT INTO  $OUTDEV
  p.name_full_formatted, e_loc_nurse_unit_disp = uar_get_code_display(e.loc_nurse_unit_cd),
  e_loc_room_disp = uar_get_code_display(e.loc_room_cd),
  e_loc_bed_disp = uar_get_code_display(e.loc_bed_cd), e_encntr_type_disp = uar_get_code_display(e
   .encntr_type_cd), e_encntr_status_disp = uar_get_code_display(e.encntr_status_cd),
  p_sex_disp = uar_get_code_display(p.sex_cd), p.birth_dt_tm, mr_num = substring(1,10,ea.alias),
  acctnum = substring(1,12,ea1.alias), p.name_first_key, p.name_first,
  p.person_id, e.encntr_id, e.person_id,
  ea.encntr_id
  FROM encounter e,
   person p,
   encntr_alias ea,
   encntr_alias ea1
  PLAN (p
   WHERE p.name_first="CISINTST")
   JOIN (e
   WHERE e.person_id=p.person_id)
   JOIN (ea
   WHERE e.encntr_id=ea.encntr_id
    AND ea.encntr_alias_type_cd=1079)
   JOIN (ea1
   WHERE e.encntr_id=ea1.encntr_id
    AND ea1.encntr_alias_type_cd=1077)
  ORDER BY p.name_full_formatted
  WITH format, skipreport = 1
 ;end select
END GO
