CREATE PROGRAM agc_lab_test:dba
 DECLARE lab_event_disp = f8
 SET lab_event_disp = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=93
   AND cv.display_key="LABORATORY"
   AND cv.active_ind=1
  DETAIL
   lab_event_disp = cv.code_value
  WITH nocounter
 ;end select
 DECLARE chem_event_disp = f8
 SET chem_event_disp = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=93
   AND cv.display_key="CHEMISTRY"
   AND cv.active_ind=1
  DETAIL
   chem_event_disp = cv.code_value
  WITH nocounter
 ;end select
 DECLARE endo_event_disp = f8
 SET endo_event_disp = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=93
   AND cv.display_key="ENDOCRINETUMORMARKER"
   AND cv.active_ind=1
  DETAIL
   endo_event_disp = cv.code_value
  WITH nocounter
 ;end select
 DECLARE heme_event_disp = f8
 SET heme_event_disp = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=93
   AND cv.display_key="HEMATOLOGY"
   AND cv.active_ind=1
  DETAIL
   heme_event_disp = cv.code_value
  WITH nocounter
 ;end select
 DECLARE immu_event_disp = f8
 SET immu_event_disp = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=93
   AND cv.display_key="IMMUNOSEROLOGY"
   AND cv.active_ind=1
  DETAIL
   immu_event_disp = cv.code_value
  WITH nocounter
 ;end select
 DECLARE urine_event_disp = f8
 SET urine_event_disp = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=93
   AND cv.display_key="URINETEST"
   AND cv.active_ind=1
  DETAIL
   urine_event_disp = cv.code_value
  WITH nocounter
 ;end select
 SELECT
  parenta = uar_get_code_display(esca.event_set_cd), parentb = uar_get_code_display(esca2
   .event_set_cd), child = decode(esca3.seq,uar_get_code_display(esca3.event_set_cd)," ")
  FROM v500_event_set_canon esca,
   v500_event_set_canon esca2,
   dummyt d1,
   v500_event_set_canon esca3
  PLAN (esca
   WHERE esca.event_set_cd IN (chem_event_disp, endo_event_disp, heme_event_disp, immu_event_disp,
   urine_event_disp)
    AND esca.parent_event_set_cd=lab_event_disp)
   JOIN (esca2
   WHERE esca.event_set_cd=esca2.parent_event_set_cd)
   JOIN (d1)
   JOIN (esca3
   WHERE esca2.event_set_cd=esca3.parent_event_set_cd)
  WITH outerjoin = d1, dontcare = esca3
 ;end select
END GO
