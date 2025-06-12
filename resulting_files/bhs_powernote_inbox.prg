CREATE PROGRAM bhs_powernote_inbox
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Physician PN Number" = "*",
  "Start Date" = "CURDATE",
  "End Date Time" = "CURDATE"
  WITH outdev, phy_pn, start_dt_tm,
  end_dt_tm
 SELECT INTO  $OUTDEV
  pr.name_full_formatted, pr.person_id, p.person_id,
  p.name_full_formatted, pr1.name_full_formatted, c.request_dt_tm
  FROM ce_event_prsnl c,
   person p,
   prsnl pr,
   prsnl pr1
  PLAN (c
   WHERE c.action_type_cd != 104
    AND c.action_status_cd != 653
    AND c.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND c.request_dt_tm != null)
   JOIN (p
   WHERE c.person_id=p.person_id)
   JOIN (pr
   WHERE pr.person_id=c.action_prsnl_id
    AND ((pr.physician_ind+ 0)=1)
    AND pr.username=patstring( $2))
   JOIN (pr1
   WHERE pr1.person_id=c.request_prsnl_id)
  ORDER BY c.request_dt_tm, p.person_id
  HEAD REPORT
   d0 = headreportsection(rpt_render)
  WITH nocounter, separator = " ", format
 ;end select
END GO
