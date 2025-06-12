CREATE PROGRAM bhs_lot_num_immun_check:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SELECT INTO  $OUTDEV
  FROM ce_med_result cmr,
   clinical_event ce,
   encounter e
  PLAN (cmr
   WHERE cmr.admin_start_dt_tm BETWEEN cnvtdatetime("01-JAN-2018 00:00:00") AND cnvtdatetime(
    "31-DEC-2019 23:59:59")
    AND cmr.substance_lot_number IN ("252380", "252683", "252830", "1602283", "N017686",
   "N017697", "N019923", "N020353", "N022583", "N022728",
   "R009615", "R016971", "S028737", "153", "A124A"))
   JOIN (ce
   WHERE ce.event_id=cmr.event_id)
   JOIN (e
   WHERE e.encntr_id=ce.encntr_id)
  ORDER BY cmr.substance_lot_number, e.loc_facility_cd
  HEAD REPORT
   temp_disp = fillstring(100," "), "lot_number,loc_cd,loc_name,count", row + 1
  HEAD e.loc_facility_cd
   temp_loc_cnt = 0, temp_loc_disp = uar_get_code_display(e.loc_facility_cd)
  DETAIL
   temp_loc_cnt += 1
  FOOT  e.loc_facility_cd
   temp_disp = build(trim(cmr.substance_lot_number,3),",",e.loc_facility_cd,",",trim(temp_loc_disp,3),
    ",",temp_loc_cnt), col 0, temp_disp,
   row + 1
  WITH nocounter, format = variable, maxrow = 1,
   maxcol = 5000, separator = " "
 ;end select
END GO
