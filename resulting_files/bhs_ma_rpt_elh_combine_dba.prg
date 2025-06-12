CREATE PROGRAM bhs_ma_rpt_elh_combine:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "FIN" = ""
  WITH outdev, s_fin
 SELECT INTO  $OUTDEV
  facility = uar_get_code_display(elh.loc_facility_cd), building = uar_get_code_display(elh
   .loc_building_cd), nurse_unit = uar_get_code_display(elh.loc_nurse_unit_cd),
  room = uar_get_code_display(elh.loc_room_cd), bed = uar_get_code_display(elh.loc_bed_cd),
  active_ind =
  IF (elh.active_ind=1) "Active"
  ELSE "Inactive"
  ENDIF
  ,
  encounter_type = uar_get_code_display(elh.encntr_type_cd), medical_service = uar_get_code_display(
   elh.med_service_cd), accommodation = uar_get_code_display(elh.accommodation_cd),
  transaction_date = elh.transaction_dt_tm"mm/dd/yyyy", transaction_time = elh.transaction_dt_tm
  "hh:mm:ss;;s", elh.encntr_loc_hist_id,
  beg_effective_date = elh.beg_effective_dt_tm"mm/dd/yyyy", beg_effective_time = elh
  .beg_effective_dt_tm"hh:mm:ss;;s", end_effective_date = elh.end_effective_dt_tm"mm/dd/yyyy",
  end_effective_time = elh.end_effective_dt_tm"hh:mm:ss;;s", elh.updt_cnt, elh.updt_id,
  elh.updt_task, elh.updt_applctx, elh.updt_dt_tm
  FROM encntr_loc_hist elh
  PLAN (elh
   WHERE (elh.encntr_id=
   (SELECT
    x.encntr_id
    FROM encntr_alias x
    WHERE x.alias=trim( $S_FIN,3)
     AND x.encntr_alias_type_cd=value(uar_get_code_by("MEANING",319,"FIN NBR"))
     AND x.active_ind=1
     AND x.beg_effective_dt_tm < sysdate
     AND x.end_effective_dt_tm > sysdate)))
  ORDER BY elh.encntr_id, elh.beg_effective_dt_tm, elh.end_effective_dt_tm,
   elh.encntr_loc_hist_id
  WITH nocounter, heading, maxrow = 1,
   formfeed = none, format, separator = " "
 ;end select
#exit_script
END GO
