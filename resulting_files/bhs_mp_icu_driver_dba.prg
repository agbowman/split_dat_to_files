CREATE PROGRAM bhs_mp_icu_driver:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select ICU Bed:" = 0
  WITH outdev, f_bed_cd
 EXECUTE bhs_check_domain
 EXECUTE bhs_hlp_ccl
 DECLARE mf_bed_cd = f8 WITH protect, constant( $F_BED_CD)
 DECLARE mf_unit_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mf_encntr_id = f8 WITH protect, noconstant(0.0)
 DECLARE mf_person_id = f8 WITH protect, noconstant(0.0)
 DECLARE ms_msg = vc WITH protect, noconstant(" ")
 DECLARE ms_email_body = vc WITH protect, noconstant(" ")
 DECLARE ms_email_list = vc WITH protect, noconstant(" ")
 DECLARE ms_dclcom_str = vc WITH protect, noconstant(" ")
 DECLARE ml_dclcom_len = i4 WITH protect, noconstant(0.0)
 DECLARE mn_dclcom_stat = i2 WITH protect, noconstant(0)
 SELECT DISTINCT
  bed_cd = lg1.child_loc_cd, room_cd = lg2.child_loc_cd, unit_cd = lg2.parent_loc_cd
  FROM location_group lg1,
   location_group lg2,
   code_value cv1,
   code_value cv2,
   code_value cv3
  PLAN (lg1
   WHERE lg1.child_loc_cd=mf_bed_cd
    AND lg1.active_ind=1
    AND lg1.end_effective_dt_tm > sysdate)
   JOIN (lg2
   WHERE lg2.child_loc_cd=lg1.parent_loc_cd
    AND lg2.active_ind=1
    AND lg2.end_effective_dt_tm > sysdate)
   JOIN (cv1
   WHERE cv1.code_value=lg1.child_loc_cd
    AND cv1.active_ind=1
    AND cv1.cdf_meaning="BED")
   JOIN (cv2
   WHERE cv2.code_value=lg2.child_loc_cd
    AND cv2.active_ind=1
    AND cv2.cdf_meaning="ROOM")
   JOIN (cv3
   WHERE cv3.code_value=lg2.parent_loc_cd
    AND cv3.active_ind=1
    AND cv3.cdf_meaning="NURSEUNIT")
  HEAD lg2.parent_loc_cd
   mf_unit_cd = lg2.parent_loc_cd
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  ed.person_id, ed.encntr_id
  FROM encntr_domain ed,
   encounter e
  PLAN (ed
   WHERE ed.loc_nurse_unit_cd=mf_unit_cd
    AND ed.loc_bed_cd=mf_bed_cd
    AND ed.active_ind=1
    AND ed.end_effective_dt_tm > sysdate)
   JOIN (e
   WHERE e.encntr_id=ed.encntr_id
    AND e.person_id=ed.person_id
    AND e.loc_bed_cd=ed.loc_bed_cd
    AND e.disch_dt_tm=null)
  HEAD e.person_id
   mf_encntr_id = e.encntr_id, mf_person_id = e.person_id
  WITH nocounter
 ;end select
 SET trace = recpersist
 EXECUTE bhs_mp_standard_driver "MINE", "", "bhscust:",
 "bhs_mp_icu_main.html", mf_encntr_id, mf_person_id,
 1
 SELECT INTO value( $OUTDEV)
  FROM dummyt d
  DETAIL
   row 0, putrequest->document
  WITH nocounter, format, maxrec = 10000,
   maxcol = 10000
 ;end select
 UPDATE  FROM dm_info di
  SET di.updt_dt_tm = cnvtdatetime(sysdate)
  WHERE trim(di.info_domain,3)="BHS_MP_ICU_DRIVER"
   AND di.info_number=mf_bed_cd
  WITH nocounter
 ;end update
 COMMIT
 SET ms_msg = "SUCCESS"
 SET trace = norecpersist
#exit_script
END GO
