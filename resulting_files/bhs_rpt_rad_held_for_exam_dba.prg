CREATE PROGRAM bhs_rpt_rad_held_for_exam:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Completion Date" = "SYSDATE",
  "Select End Completion  Date" = "SYSDATE",
  "Main Facility" = value(0.0),
  "Select Rad Section" = value(0.0)
  WITH outdev, s_start_date, s_end_date,
  f_facility, f_section
 DECLARE ms_cs14192_completed = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14192,"COMPLETED")),
 protect
 DECLARE mf_cs223_subsection = f8 WITH constant(uar_get_code_by("DISPLAYKEY",223,"SUBSECTION")),
 protect
 DECLARE mf_cs223_section = f8 WITH constant(uar_get_code_by("DISPLAYKEY",223,"SECTION")), protect
 DECLARE mf_cs223_department = f8 WITH constant(uar_get_code_by("DISPLAYKEY",223,"DEPARTMENT")),
 protect
 DECLARE mf_cs223_institution = f8 WITH constant(uar_get_code_by("DISPLAYKEY",223,"INSTITUTION")),
 protect
 DECLARE mf_cs221_cbc = f8 WITH constant(uar_get_code_by("DISPLAYKEY",221,"COMPBREASTCENTER")),
 protect
 DECLARE mf_cs221_bri = f8 WITH constant(uar_get_code_by("DISPLAYKEY",221,"BRI")), protect
 DECLARE mf_cs221_bnh = f8 WITH constant(uar_get_code_by("DISPLAYKEY",221,"BNH")), protect
 DECLARE mf_cs221_bwh = f8 WITH constant(uar_get_code_by("DISPLAYKEY",221,"BWH")), protect
 DECLARE mf_cs221_fmc = f8 WITH constant(uar_get_code_by("DISPLAYKEY",221,"FMC")), protect
 DECLARE mf_cs221_bmc = f8 WITH constant(uar_get_code_by("DISPLAYKEY",221,"BMC")), protect
 DECLARE mf_cs48_active = f8 WITH constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE")), protect
 DECLARE mf_cs6000_radiology = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6000,"RADIOLOGY")),
 protect
 DECLARE mf_by_whom = f8 WITH noconstant(0), protect
 DECLARE mf_was_held = f8 WITH noconstant(0), protect
 DECLARE mf_yes = f8 WITH noconstant(0), protect
 DECLARE mf_cs319_fin_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"FIN NBR")), protect
 DECLARE ms_opr_var = vc WITH protect
 DECLARE ms_opr_var1 = vc WITH protect
 DECLARE ms_lcheck = vc WITH protect
 DECLARE ml_gcnt = i4 WITH noconstant(0), protect
 FREE RECORD grec2
 RECORD grec1(
   1 list[*]
     2 mf_cv = f8
     2 ms_disp = c15
 )
 IF (ms_lcheck="L")
  SET ms_opr_var = "IN"
  WHILE (ms_lcheck > " ")
    SET ml_gcnt += 1
    SET ms_lcheck = substring(1,1,reflect(parameter(parameter2( $F_FACILITY),ml_gcnt)))
    CALL echo(ms_lcheck)
    IF (ms_lcheck > " ")
     IF (mod(ml_gcnt,5)=1)
      SET stat = alterlist(grec1->list,(ml_gcnt+ 4))
     ENDIF
     SET grec1->list[ml_gcnt].mf_cv = cnvtint(parameter(parameter2( $F_FACILITY),ml_gcnt))
     SET grec1->list[ml_gcnt].ms_disp = uar_get_code_display(parameter(parameter2( $F_FACILITY),
       ml_gcnt))
    ENDIF
  ENDWHILE
  SET ml_gcnt -= 1
  SET stat = alterlist(grec1->list,ml_gcnt)
 ELSE
  SET stat = alterlist(grec1->list,1)
  SET ml_gcnt = 1
  SET grec1->list[1].mf_cv =  $F_FACILITY
  IF ((grec1->list[1].mf_cv=0.0))
   SET grec1->list[1].ms_disp = "All Locations"
   SET ms_opr_var = "!="
  ELSE
   SET grec1->list[1].ms_disp = uar_get_code_display(grec1->list[1].mf_cv)
   SET ms_opr_var = "="
  ENDIF
 ENDIF
 SET lcheck = substring(1,1,reflect(parameter(parameter2( $F_SECTION),0)))
 FREE RECORD grec2
 RECORD grec2(
   1 list[*]
     2 mf_cv = f8
     2 ms_disp = c15
 )
 SET gcnt = 0
 IF (lcheck="L")
  SET ms_opr_var1 = "IN"
  WHILE (lcheck > " ")
    SET gcnt += 1
    SET lcheck = substring(1,1,reflect(parameter(parameter2( $F_SECTION),gcnt)))
    CALL echo(lcheck)
    IF (lcheck > " ")
     IF (mod(gcnt,5)=1)
      SET stat = alterlist(grec2->list,(gcnt+ 4))
     ENDIF
     SET grec2->list[gcnt].mf_cv = cnvtint(parameter(parameter2( $F_SECTION),gcnt))
     SET grec2->list[gcnt].ms_disp = uar_get_code_display(parameter(parameter2( $F_SECTION),gcnt))
    ENDIF
  ENDWHILE
  SET gcnt -= 1
  SET stat = alterlist(grec2->list,gcnt)
 ELSE
  SET stat = alterlist(grec2->list,1)
  SET gcnt = 1
  SET grec2->list[1].mf_cv =  $F_SECTION
  IF ((grec2->list[1].mf_cv=0.0))
   SET grec2->list[1].ms_disp = "All Section"
   SET ms_opr_var1 = "!="
  ELSE
   SET grec2->list[1].ms_disp = uar_get_code_display(grec2->list[1].mf_cv)
   SET ms_opr_var1 = "="
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM rad_tech_field rtf
  WHERE cnvtupper(rtf.field_desc) IN ("WAS PATIENT HELD DURING EXPOSURE?", 'IF "YES" BY WHOM?')
   AND rtf.active_ind=1
  ORDER BY rtf.field_id
  HEAD rtf.field_id
   IF (cnvtupper(rtf.field_desc)="WAS PATIENT HELD DURING EXPOSURE?")
    mf_was_held = rtf.field_id
   ELSEIF (cnvtupper(rtf.field_desc)='IF "YES" BY WHOM?')
    mf_by_whom = rtf.field_id
   ENDIF
  WITH nocounter, maxrec = 1000, time = 60
 ;end select
 CALL echo(build("mf_by_whom = ",mf_by_whom))
 SELECT INTO "nl:"
  FROM rad_tech_field rtf,
   rad_tech_fld_fmt_r rt
  PLAN (rt
   WHERE rt.active_ind=1
    AND rt.parent_field_id=mf_was_held)
   JOIN (rtf
   WHERE rtf.field_id=rt.field_id
    AND rtf.active_ind=1)
  DETAIL
   IF (cnvtupper(rtf.field_desc)="YES")
    mf_yes = rtf.field_id
   ENDIF
  WITH nocounter
 ;end select
 CALL echo(build("mf_yes2 = ",mf_yes))
 SELECT INTO  $OUTDEV
  fin = substring(1,10,trim(fin.alias,3)), procedure_name = substring(1,100,trim(o.order_mnemonic,3)),
  was_patient_held_during_exposure = substring(1,10,trim(rtf.field_desc,3)),
  held_by = substring(1,100,trim(rtcd1.data_text,3)), date_of_exam = format(orad.complete_dt_tm,
   "mm/dd/yyyy hh:mm;;d")
  FROM orders o,
   encounter e,
   person p,
   encntr_alias fin,
   order_radiology orad,
   rad_tech_cmt_data rtcd,
   rad_tech_cmt_data rtcd1,
   rad_tech_field rtf,
   rad_tech_field rtf1,
   rad_exam re,
   resource_group inst,
   service_resource radept,
   resource_group dept,
   service_resource radsec,
   resource_group section,
   service_resource ss,
   resource_group subsection
  PLAN (orad
   WHERE orad.complete_dt_tm BETWEEN cnvtdatetime( $S_START_DATE) AND cnvtdatetime( $S_END_DATE)
    AND orad.exam_status_cd=ms_cs14192_completed)
   JOIN (o
   WHERE o.order_id=orad.order_id
    AND o.catalog_type_cd=mf_cs6000_radiology
    AND o.active_ind=1)
   JOIN (e
   WHERE e.encntr_id=o.encntr_id
    AND e.active_status_cd=mf_cs48_active)
   JOIN (fin
   WHERE fin.encntr_id=e.encntr_id
    AND fin.active_status_cd=mf_cs48_active
    AND fin.encntr_alias_type_cd=mf_cs319_fin_cd
    AND fin.end_effective_dt_tm >= cnvtdatetime(sysdate)
    AND fin.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND fin.active_ind=1)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_status_cd=mf_cs48_active)
   JOIN (inst
   WHERE inst.parent_service_resource_cd IN (mf_cs221_bnh, mf_cs221_bwh, mf_cs221_bmc, mf_cs221_fmc,
   mf_cs221_bri)
    AND operator(inst.parent_service_resource_cd,ms_opr_var, $F_FACILITY)
    AND inst.resource_group_type_cd=mf_cs223_institution
    AND inst.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00")
    AND inst.active_ind=1)
   JOIN (radept
   WHERE radept.service_resource_cd=inst.child_service_resource_cd
    AND radept.discipline_type_cd=mf_cs6000_radiology
    AND radept.service_resource_type_cd=mf_cs223_department
    AND radept.active_ind=1
    AND radept.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00"))
   JOIN (dept
   WHERE dept.parent_service_resource_cd=radept.service_resource_cd
    AND dept.resource_group_type_cd=mf_cs223_department
    AND dept.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00")
    AND dept.active_ind=1)
   JOIN (radsec
   WHERE radsec.service_resource_cd=dept.child_service_resource_cd
    AND radsec.discipline_type_cd=mf_cs6000_radiology
    AND radsec.service_resource_type_cd=mf_cs223_section
    AND radsec.active_ind=1
    AND radsec.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00"))
   JOIN (section
   WHERE section.parent_service_resource_cd=radsec.service_resource_cd
    AND operator(section.parent_service_resource_cd,ms_opr_var1, $F_SECTION)
    AND section.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00")
    AND section.active_ind=1)
   JOIN (ss
   WHERE ss.service_resource_cd=section.child_service_resource_cd
    AND ss.discipline_type_cd=mf_cs6000_radiology
    AND ss.service_resource_type_cd=mf_cs223_subsection
    AND ss.active_ind=1
    AND ss.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00"))
   JOIN (subsection
   WHERE subsection.parent_service_resource_cd=ss.service_resource_cd
    AND subsection.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00")
    AND subsection.active_ind=1
    AND subsection.resource_group_type_cd=mf_cs223_subsection)
   JOIN (re
   WHERE re.order_id=o.order_id
    AND re.service_resource_cd=subsection.child_service_resource_cd)
   JOIN (rtcd
   WHERE rtcd.order_id=o.order_id
    AND rtcd.data_choice_ind=1
    AND rtcd.parent_field_id=mf_was_held)
   JOIN (rtcd1
   WHERE (rtcd1.order_id= Outerjoin(o.order_id))
    AND (rtcd1.field_id= Outerjoin(mf_by_whom)) )
   JOIN (rtf
   WHERE rtf.active_ind=1
    AND rtf.field_id=mf_yes
    AND rtf.field_id=rtcd.field_id
    AND rtf.active_ind=1)
   JOIN (rtf1
   WHERE rtf1.field_id=rtcd.parent_field_id
    AND rtf1.field_id=mf_was_held
    AND rtf1.active_ind=1)
  WITH nocounter, format, separator = "  "
 ;end select
END GO
