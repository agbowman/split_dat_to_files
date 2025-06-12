CREATE PROGRAM bhs_inbox_lc1
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Physician PN Number" = "*",
  "Start Date" = "CURDATE",
  "End Date Time" = "CURDATE"
  WITH outdev, phy_pn, start_dt_tm,
  end_dt_tm
 SELECT
  c.request_prsnl_id, pr1.name_full_formatted, c.action_prsnl_id,
  pr.name_full_formatted, c.request_dt_tm, c.request_dt_tm
  FROM ce_event_prsnl c,
   prsnl pr,
   prsnl pr1
  PLAN (c
   WHERE c.action_type_cd != 614384.00
    AND c.action_type_cd IN (106, 107)
    AND c.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND c.request_dt_tm BETWEEN cnvtdatetime( $START_DT_TM) AND cnvtdatetime( $END_DT_TM)
    AND c.request_prsnl_id != 0.00)
   JOIN (pr
   WHERE pr.person_id=c.action_prsnl_id
    AND pr.physician_ind=1
    AND  NOT (((pr.position_cd+ 0) IN (68877695.0, 925850.0))))
   JOIN (pr1
   WHERE pr1.person_id=c.request_prsnl_id
    AND  NOT (((pr1.position_cd+ 0) IN (68877695.0, 925850.0))))
  WITH time = 30
 ;end select
END GO
