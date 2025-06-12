CREATE PROGRAM cls_enc_stats_by_date_type
 SET cnt = 0
 SET cnt2 = 0
 SET cnt3 = 0
 SET cnt4 = 0
 SET cnt5 = 0
 SET cnt6 = 0
 SELECT
  e.active_ind, e_active_status_disp = uar_get_code_display(e.active_status_cd), e.disch_dt_tm,
  e_med_service_disp = uar_get_code_display(e.med_service_cd), e.encntr_id, e.reg_dt_tm,
  e_encntr_status_disp = uar_get_code_display(e.encntr_status_cd), e_encntr_type_disp =
  uar_get_code_display(e.encntr_type_cd), e.encntr_type_cd
  FROM encounter e
  WHERE e.disch_dt_tm IS NOT null
  ORDER BY e.encntr_type_cd
  HEAD REPORT
   cnt = 0, cnt2 = 0, cnt3 = 0,
   cnt4 = 0, cnt5 = 0, cnt6 = 0,
   line = fillstring(131,"_"), today = format(curdate,"MM/DD/YYYY;;D"), now = format(curtime3,
    "HH:MM:SS;;S"),
   col 0,
   CALL center("Count by Patient Type Where Status Is Not Discharged",0,132), row + 1,
   col 0,
   CALL center("And Disch_Dt_Tm is not Null",0,132), row + 2,
   col 1, "Enc Type Cd", col 15,
   "Encounter Type", col 38, "Converted",
   col 51, "Unconverted", col 72,
   "Total", row + 1, col 0,
   line, row + 2
  HEAD e.encntr_type_cd
   cnt = 0, cnt2 = 0, cnt3 = 0
  DETAIL
   cnt3 = (cnt3+ 1), cnt6 = (cnt6+ 1)
   IF (e.med_service_cd=703444)
    cnt = (cnt+ 1), cnt4 = (cnt4+ 1)
   ELSE
    cnt2 = (cnt2+ 1), cnt5 = (cnt5+ 1)
   ENDIF
  FOOT  e.encntr_type_cd
   col 3, e.encntr_type_cd"#########;R", col 15,
   e_encntr_type_disp, col 40, cnt"#######;R",
   col 55, cnt2"#######;R", col 70,
   cnt3"#######;R", row + 1, cnt = 0
  FOOT REPORT
   row + 2, col 15, "Total Rows: ",
   col 40, cnt4"#######;R", col 55,
   cnt5"#######;R", col 70, cnt6"#######;R",
   row + 2, col 0, " Date: ",
   today, "  ", now,
   row + 2, col 0,
   CALL center("End of Report",0,80)
 ;end select
END GO
