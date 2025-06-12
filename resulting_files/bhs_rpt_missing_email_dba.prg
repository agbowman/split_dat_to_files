CREATE PROGRAM bhs_rpt_missing_email:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Days to look back:" = "1",
  "Location" = ""
  WITH outdev, d_days_back, d_loc
 DECLARE mc_days_to_look_back = i4 WITH protect, constant(cnvtint( $D_DAYS_BACK))
 DECLARE mc_loc = f8 WITH protect, constant(cnvtreal( $D_LOC))
 SELECT DISTINCT INTO  $OUTDEV
  patient_name = p.name_full_formatted, mrn = pa.alias, reg_dt_tm = e.reg_dt_tm
  FROM encounter e,
   person p,
   person_alias pa
  PLAN (e
   WHERE e.reg_dt_tm >= cnvtdatetime((curdate - mc_days_to_look_back),curtime3)
    AND e.loc_facility_cd=mc_loc)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND  NOT ( EXISTS (
   (SELECT
    "x"
    FROM phone ph
    WHERE ph.parent_entity_name="PERSON_PATIENT"
     AND ph.parent_entity_id=p.person_id
     AND ph.phone_type_cd=170
     AND ph.active_ind=1))))
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.active_ind=1
    AND pa.person_alias_type_cd=2
    AND pa.end_effective_dt_tm > sysdate)
  ORDER BY p.name_full_formatted
  WITH nocounter, maxcol = 32000, separator = " ",
   format
 ;end select
END GO
