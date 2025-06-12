CREATE PROGRAM dm_combine_activity_rpt2:dba
 PAINT
 CALL clear(1,1)
 SET sdate = fillstring(50," ")
 SET edate = fillstring(50," ")
 SET start_date = fillstring(50," ")
 SET end_date = fillstring(50," ")
 CALL text(1,1,"Start of the date range, without quotes, in format 15-JAN-1997")
 CALL accept(2,1,"p(50);cu")
 SET sdate = curaccept
 SET start_date = build(sdate," 00:00:00")
 CALL text(4,1,"End of the date range, without quotes, in format 15-JAN-1997")
 CALL accept(5,1,"p(50);cu")
 SET edate = curaccept
 SET end_date = build(edate," 23:59:59")
 CALL clear(1,1)
 SELECT INTO mine
  pc.updt_dt_tm, pc.person_combine_id, s_date = cnvtdatetime(start_date),
  e_date = cnvtdatetime(end_date)
  FROM person_combine pc,
   person_combine_det pcd
  PLAN (pc
   WHERE pc.active_ind=1
    AND pc.updt_dt_tm >= cnvtdatetime(start_date)
    AND pc.updt_dt_tm <= cnvtdatetime(end_date))
   JOIN (pcd
   WHERE pc.person_combine_id=pcd.person_combine_id)
  ORDER BY pc.updt_dt_tm
  HEAD REPORT
   cmb_cnt = 0, det_cnt = 0, cnt = 0,
   max_c = 0, min_c = 10000, cnt_1000 = 0,
   title = "COMBINE ACTIVITY", program_name = "COMBINE ACTIVITY", eor = 0
  HEAD PAGE
   col 00, "REPORT:  ", program_name,
   col 105, "TIME:        ", curtime"HH:MM;;M",
   row + 1, col 00, "USER:  ",
   curuser, col 105, "PREPARED ON: ",
   curdate"DDMMMYY;;D", row + 1, col 105,
   "Page: ", curpage"###;l", row + 1,
   col 0, "Period: ", s_date"dd-mmm-yyyy;;q",
   " through ", e_date"dd-mmm-yyyy;;q", row + 2
   IF (eor=0)
    col 0, "DATE/TIME", col 20,
    "PERSON_COMBINE_ID", col 50, "NUMBER OF COMBINE DETAIL ROWS",
    row + 1
   ENDIF
  HEAD pc.person_combine_id
   cmb_cnt += 1, col 0, pc.updt_dt_tm"DD-MM-YYYY HH:MM",
   col 20, pc.person_combine_id"##############;R"
  FOOT  pc.person_combine_id
   cnt = count(pcd.person_combine_det_id), det_cnt += cnt
   IF (cnt > max_c)
    max_c = cnt
   ENDIF
   IF (min_c > cnt)
    min_c = cnt
   ENDIF
   IF (cnt >= 1000)
    cnt_1000 += 1
   ENDIF
   col 60, cnt"##########;R", row + 1
  FOOT REPORT
   eor = 1, aver = (det_cnt/ cmb_cnt), row + 2,
   col 0, "SUMMARY", row + 1,
   col 0, "-------", row + 1,
   col 0, "TOTAL PERSON COMBINES                              = ", cmb_cnt,
   row + 1, col 0, "TOTAL PERSON COMBINE DETAIL ROWS                   = ",
   det_cnt, row + 1, col 0,
   "AVERAGE NUMBER OF DETAIL ROWS PER COMBINE          = ", aver, row + 1,
   col 0, "MAXIMUM NUMBER OF DETAIL ROWS IN A COMBINE         = ", max_c,
   row + 1, col 0, "MINIMUM NUMBER OF DETAIL ROWS IN A COMBINE         = ",
   min_c, row + 1, col 0,
   "NUMBER OF COMBINES WITH MORE THAN 1000 DETAIL ROWS = ", cnt_1000
  WITH nocounter
 ;end select
 SELECT INTO mine
  pc.updt_dt_tm, pc.encntr_combine_id, s_date = cnvtdatetime(start_date),
  e_date = cnvtdatetime(end_date)
  FROM encntr_combine pc,
   encntr_combine_det pcd
  PLAN (pc
   WHERE pc.active_ind=1
    AND pc.updt_dt_tm >= cnvtdatetime(start_date)
    AND pc.updt_dt_tm <= cnvtdatetime(end_date))
   JOIN (pcd
   WHERE pc.encntr_combine_id=pcd.encntr_combine_id)
  ORDER BY pc.updt_dt_tm
  HEAD REPORT
   cmb_cnt = 0, det_cnt = 0, cnt = 0,
   max_c = 0, min_c = 10000, cnt_1000 = 0,
   title = "COMBINE ACTIVITY", program_name = "COMBINE ACTIVITY", eor = 0
  HEAD PAGE
   col 00, "REPORT:  ", program_name,
   col 105, "TIME:        ", curtime"HH:MM;;M",
   row + 1, col 00, "USER:  ",
   curuser, col 105, "PREPARED ON: ",
   curdate"DDMMMYY;;D", row + 1, col 105,
   "Page: ", curpage"###;l", row + 1,
   col 0, "Period: ", s_date"dd-mmm-yyyy;;q",
   " through ", e_date"dd-mmm-yyyy;;q", row + 2
   IF (eor=0)
    col 0, "DATE/TIME", col 20,
    "ENCNTR_COMBINE_ID", col 50, "NUMBER OF COMBINE DETAIL ROWS",
    row + 1
   ENDIF
  HEAD pc.encntr_combine_id
   cmb_cnt += 1, col 0, pc.updt_dt_tm"DD-MM-YYYY HH:MM",
   col 20, pc.encntr_combine_id"##############;R"
  FOOT  pc.encntr_combine_id
   cnt = count(pcd.encntr_combine_det_id), det_cnt += cnt
   IF (cnt > max_c)
    max_c = cnt
   ENDIF
   IF (min_c > cnt)
    min_c = cnt
   ENDIF
   IF (cnt >= 1000)
    cnt_1000 += 1
   ENDIF
   col 60, cnt"##########;R", row + 1
  FOOT REPORT
   eor = 1, aver = (det_cnt/ cmb_cnt), row + 2,
   col 0, "SUMMARY", row + 1,
   col 0, "-------", row + 1,
   col 0, "TOTAL ENCOUNTER COMBINES                           = ", cmb_cnt,
   row + 1, col 0, "TOTAL ENCOUNTER COMBINE DETAIL ROWS                = ",
   det_cnt, row + 1, col 0,
   "AVERAGE NUMBER OF DETAIL ROWS PER COMBINE          = ", aver, row + 1,
   col 0, "MAXIMUM NUMBER OF DETAIL ROWS IN A COMBINE         = ", max_c,
   row + 1, col 0, "MINIMUM NUMBER OF DETAIL ROWS IN A COMBINE         = ",
   min_c, row + 1, col 0,
   "NUMBER OF COMBINES WITH MORE THAN 1000 DETAIL ROWS = ", cnt_1000
  WITH nocounter
 ;end select
END GO
