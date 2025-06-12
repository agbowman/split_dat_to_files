CREATE PROGRAM bhs_rpt_braden_orders
 DECLARE tmpline = vc WITH protect, noconstant(" ")
 SELECT
  p.name_full_formatted, ea.alias, cv4.display,
  cv5.display, cv6.display, cv7.display,
  cv2.display_key, e.reg_dt_tm
  FROM encounter e,
   encntr_alias ea,
   code_value cv2,
   code_value cv3,
   code_value cv4,
   code_value cv5,
   code_value cv6,
   code_value cv7,
   person p
  WHERE cv2.code_set=71
   AND cv2.display_key IN ("INPATIENT", "OBSERVATION", "DAYSTAY")
   AND e.encntr_type_cd=cv2.code_value
   AND e.reg_dt_tm BETWEEN cnvtdatetime(cnvtdate(09182010),0) AND cnvtdatetime(cnvtdate(09252010),0)
   AND  NOT ( EXISTS (
  (SELECT
   1
   FROM code_value cv,
    orders o
   WHERE cv.code_set=200
    AND cv.display_key="BRADENASSESSMENT"
    AND o.catalog_cd=cv.code_value
    AND o.encntr_id=e.encntr_id
    AND rownum <= 1)))
   AND ea.encntr_id=e.encntr_id
   AND ea.encntr_alias_type_cd=cv3.code_value
   AND cv3.display_key="FINNBR"
   AND p.person_id=e.person_id
   AND e.loc_facility_cd=cv4.code_value
   AND e.loc_building_cd=cv5.code_value
   AND e.loc_nurse_unit_cd=cv6.code_value
   AND e.loc_bed_cd=cv7.code_value
  HEAD REPORT
   row 0, col 0, "Patient Name;Account#;Encounter Type;Admit Dt Tm;Facility;Building;Nurse Unit;Bed"
  DETAIL
   tmpline = build(p.name_full_formatted,";",ea.alias,";",cv2.display_key,
    ";",format(e.reg_dt_tm,";;Q"),";",cv4.display,";",
    cv5.display,";",cv6.display,";",cv7.display), row + 1, col 0,
   tmpline
  FOOT REPORT
   row + 0
 ;end select
END GO
