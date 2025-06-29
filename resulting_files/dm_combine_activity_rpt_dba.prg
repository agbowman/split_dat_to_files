CREATE PROGRAM dm_combine_activity_rpt:dba
 PAINT
 CALL clear(1,1)
 SET start_date = fillstring(50," ")
 SET end_date = fillstring(50," ")
 CALL text(1,1,"Start of the date range, without quotes (eg. 11-SEP-1999)")
 CALL accept(2,1,"p(11);cu")
 SET start_date = curaccept
 CALL text(4,1,"End of the date range, without quotes (eg. 11-SEP-1999)")
 CALL accept(5,1,"p(11);cu")
 SET end_date = curaccept
 CALL clear(1,1)
 RECORD rtotal(
   1 personcmb[*]
     2 actdate = dq8
     2 totalcmb = f8
     2 totaldet = f8
     2 maxdet = f8
     2 maxcmbid = f8
     2 maxcmbstime = dq8
     2 maxcmbetime = dq8
     2 maxname = c30
     2 mindet = f8
     2 nbr1000 = f8
   1 encntrcmb[*]
     2 actdate = dq8
     2 totalcmb = f8
     2 totaldet = f8
     2 maxdet = f8
     2 maxcmbid = f8
     2 maxcmbstime = dq8
     2 maxcmbetime = dq8
     2 maxname = c30
     2 mindet = f8
     2 nbr1000 = f8
 )
 IF (start_date=end_date)
  SET totaldays = 1
 ELSE
  SET totaldays = (datetimecmp(cnvtdatetime(end_date),cnvtdatetime(start_date))+ 1)
 ENDIF
 SET date_buffer = cnvtdatetime(start_date)
 FOR (day_cnt = 1 TO totaldays)
   SET stat = alterlist(rtotal->personcmb,day_cnt)
   SET rtotal->personcmb[day_cnt].actdate = date_buffer
   SET date_buffer = datetimeadd(date_buffer,1)
   SELECT INTO "nl:"
    pc.updt_dt_tm, pc.person_combine_id, pcd.person_combine_det_id
    FROM person_combine pc,
     person_combine_det pcd,
     person p
    PLAN (pc
     WHERE datetimecmp(pc.updt_dt_tm,cnvtdatetime(rtotal->personcmb[day_cnt].actdate))=0
      AND pc.active_ind=1)
     JOIN (pcd
     WHERE pc.person_combine_id=pcd.person_combine_id)
     JOIN (p
     WHERE p.person_id=pc.updt_id)
    HEAD REPORT
     cnt = 0, cmb_cnt = 0, det_cnt = 0,
     max_det = 0, min_det = 10000, cnt_1k = 0
    HEAD pc.person_combine_id
     cmb_cnt += 1
    FOOT  pc.person_combine_id
     cnt = count(pcd.person_combine_id), stime = min(pcd.updt_dt_tm), etime = max(pcd.updt_dt_tm),
     det_cnt += cnt
     IF (max_det < cnt)
      max_det = cnt, rtotal->personcmb[day_cnt].maxcmbid = pc.person_combine_id, rtotal->personcmb[
      day_cnt].maxname = substring(1,30,p.name_full_formatted),
      rtotal->personcmb[day_cnt].maxcmbstime = cnvtdatetime(stime), rtotal->personcmb[day_cnt].
      maxcmbetime = cnvtdatetime(etime)
     ENDIF
     IF (min_det > cnt)
      min_det = cnt
     ENDIF
     IF (cnt >= 1000)
      cnt_1k += 1
     ENDIF
    FOOT REPORT
     rtotal->personcmb[day_cnt].totalcmb = cmb_cnt, rtotal->personcmb[day_cnt].totaldet = det_cnt,
     rtotal->personcmb[day_cnt].maxdet = max_det,
     rtotal->personcmb[day_cnt].mindet = min_det, rtotal->personcmb[day_cnt].nbr1000 = cnt_1k
    WITH nocounter
   ;end select
 ENDFOR
 SELECT INTO mine
  d.seq, s_date = cnvtdatetime(start_date), e_date = cnvtdatetime(end_date)
  FROM (dummyt d  WITH seq = value(totaldays))
  HEAD REPORT
   title = "COMBINE ACTIVITY", eor = 0, tot_cmb = 0,
   tot_det = 0, max_c = 0, min_c = 10000,
   tot_1k = 0, avg1 = 0, avg2 = 0
  HEAD PAGE
   col 0, "PERSON COMBINE ACTIVITY REPORT", col 100,
   "Page        : ", curpage"###;l", row + 1,
   col 00, "Generated by ", curuser,
   col 100, "Date        : ", curdate"DD-MMM-YYYY;;D",
   row + 1, col 100, "Time        : ",
   curtime"HH:MM;;M", row + 1, col 0,
   "Period of combine activities: ", s_date"dd-mmm-yyyy;;q", " through ",
   e_date"dd-mmm-yyyy;;q", row + 1, col 0,
   "-------------------------------------------------------------", row + 3
   IF (eor=0)
    col 0, "Explanation of columns", row + 1,
    col 0, "AVG  =  Average number of detail rows of all combines", row + 1,
    col 0, "MAX  =  The largest number of detail rows in a combine", row + 1,
    col 0, "MIN  =  The least number of detail rows in a combine", row + 1,
    col 0, ">1K  =  Number of combines with more than 1000 detail rows", row + 3,
    col 0, "DATE", col + 10,
    "TOTAL COMBINES", col + 3, "TOTAL DETAIL ROWS",
    col + 5, "AVG", col + 7,
    "MAX", col + 7, "MIN",
    col + 7, ">1K", row + 1,
    col 0, "-----------   --------------   -----------------", col + 3,
    "-------   -------   -------   -------", row + 1
   ENDIF
  DETAIL
   avg1 = (rtotal->personcmb[d.seq].totaldet/ rtotal->personcmb[d.seq].totalcmb), tot_cmb += rtotal->
   personcmb[d.seq].totalcmb, tot_det += rtotal->personcmb[d.seq].totaldet
   IF ((max_c < rtotal->personcmb[d.seq].maxdet))
    max_c = rtotal->personcmb[d.seq].maxdet
   ENDIF
   IF ((min_c > rtotal->personcmb[d.seq].mindet)
    AND (rtotal->personcmb[d.seq].mindet != 0))
    min_c = rtotal->personcmb[d.seq].mindet
   ENDIF
   tot_1k += rtotal->personcmb[d.seq].nbr1000
   IF ((rtotal->personcmb[d.seq].totalcmb=0))
    col 0, rtotal->personcmb[d.seq].actdate"DD-MMM-YYYY;;q", col 14,
    "*** No person combine activities on this day ***", row + 1
   ELSE
    row + 1, col 0, rtotal->personcmb[d.seq].actdate"DD-MMM-YYYY;;q",
    col 15, rtotal->personcmb[d.seq].totalcmb"############;r", col 32,
    rtotal->personcmb[d.seq].totaldet"###############;r", col 52, avg1"#####;r",
    col 61, rtotal->personcmb[d.seq].maxdet"######;r", col 72,
    rtotal->personcmb[d.seq].mindet"#####;r", col 82, rtotal->personcmb[d.seq].nbr1000"#####;r",
    row + 1, col 14, "person_combine_id with max # of details: ",
    rtotal->personcmb[d.seq].maxcmbid"#########;l", " by ", rtotal->personcmb[d.seq].maxname,
    row + 1, col 14, "started on ",
    rtotal->personcmb[d.seq].maxcmbstime"HH:MM.SS;;q", " and finished on ", rtotal->personcmb[d.seq].
    maxcmbetime"HH:MM.SS;;q",
    row + 2
   ENDIF
  FOOT REPORT
   avg2 = (tot_det/ tot_cmb), eor = 1, BREAK,
   col 0, "Summary", row + 1,
   col 0, "=======", row + 2,
   col 0, "Total person combines                               =  ", tot_cmb"#######;r",
   row + 1, col 0, "Total person combine detail rows                    =  ",
   tot_det"#######;r", row + 1, col 0,
   "Average number of detail rows per combine           =  ", avg2"#######;r", row + 1,
   col 0, "Maximum number of detail rows in a day              =  ", max_c"#######;r",
   row + 1, col 0, "Minimum number of detail rows in a day              =  ",
   min_c"#######;r", row + 1, col 0,
   "Number of combines with more than 1000 detail rows  =  ", tot_1k"#######;r"
  WITH nocounter
 ;end select
 SET date_buffer = cnvtdatetime(start_date)
 FOR (day_cnt = 1 TO totaldays)
   SET stat = alterlist(rtotal->encntrcmb,day_cnt)
   SET rtotal->encntrcmb[day_cnt].actdate = date_buffer
   SET date_buffer = datetimeadd(date_buffer,1)
   SELECT INTO "nl:"
    pc.updt_dt_tm, pc.encntr_combine_id, pcd.encntr_combine_det_id
    FROM encntr_combine pc,
     encntr_combine_det pcd,
     person p
    PLAN (pc
     WHERE datetimecmp(pc.updt_dt_tm,cnvtdatetime(rtotal->encntrcmb[day_cnt].actdate))=0
      AND pc.active_ind=1)
     JOIN (pcd
     WHERE pc.encntr_combine_id=pcd.encntr_combine_id)
     JOIN (p
     WHERE p.person_id=pc.updt_id)
    HEAD REPORT
     cnt = 0, cmb_cnt = 0, det_cnt = 0,
     max_det = 0, min_det = 10000, cnt_1k = 0
    HEAD pc.encntr_combine_id
     cmb_cnt += 1
    FOOT  pc.encntr_combine_id
     cnt = count(pcd.encntr_combine_id), stime = min(pcd.updt_dt_tm), etime = max(pcd.updt_dt_tm),
     det_cnt += cnt
     IF (max_det < cnt)
      max_det = cnt, rtotal->encntrcmb[day_cnt].maxcmbid = pc.encntr_combine_id, rtotal->encntrcmb[
      day_cnt].maxname = substring(1,30,p.name_full_formatted),
      rtotal->encntrcmb[day_cnt].maxcmbstime = cnvtdatetime(stime), rtotal->encntrcmb[day_cnt].
      maxcmbetime = cnvtdatetime(etime)
     ENDIF
     IF (min_det > cnt)
      min_det = cnt
     ENDIF
     IF (cnt >= 1000)
      cnt_1k += 1
     ENDIF
    FOOT REPORT
     rtotal->encntrcmb[day_cnt].totalcmb = cmb_cnt, rtotal->encntrcmb[day_cnt].totaldet = det_cnt,
     rtotal->encntrcmb[day_cnt].maxdet = max_det,
     rtotal->encntrcmb[day_cnt].mindet = min_det, rtotal->encntrcmb[day_cnt].nbr1000 = cnt_1k
    WITH nocounter
   ;end select
 ENDFOR
 SELECT INTO mine
  d.seq, s_date = cnvtdatetime(start_date), e_date = cnvtdatetime(end_date)
  FROM (dummyt d  WITH seq = value(totaldays))
  HEAD REPORT
   title = "COMBINE ACTIVITY", eor = 0, tot_cmb = 0,
   tot_det = 0, max_c = 0, min_c = 10000,
   tot_1k = 0, avg1 = 0, avg2 = 0
  HEAD PAGE
   col 0, "ENCOUNTER COMBINE ACTIVITY REPORT", col 100,
   "Page        : ", curpage"###;l", row + 1,
   col 00, "Generated by ", curuser,
   col 100, "Date        : ", curdate"DD-MMM-YYYY;;D",
   row + 1, col 100, "Time        : ",
   curtime"HH:MM;;M", row + 1, col 0,
   "Period of combine activities: ", s_date"dd-mmm-yyyy;;q", " through ",
   e_date"dd-mmm-yyyy;;q", row + 1, col 0,
   "-------------------------------------------------------------", row + 3
   IF (eor=0)
    col 0, "Explanation of columns", row + 1,
    col 0, "AVG  =  Average number of detail rows of all combines", row + 1,
    col 0, "MAX  =  The largest number of detail rows in a combine", row + 1,
    col 0, "MIN  =  The least number of detail rows in a combine", row + 1,
    col 0, ">1K  =  Number of combines with more than 1000 detail rows", row + 3,
    col 0, "DATE", col + 10,
    "TOTAL COMBINES", col + 3, "TOTAL DETAIL ROWS",
    col + 5, "AVG", col + 7,
    "MAX", col + 7, "MIN",
    col + 7, ">1K", row + 1,
    col 0, "-----------   --------------   -----------------", col + 3,
    "-------   -------   -------   -------", row + 1
   ENDIF
  DETAIL
   avg1 = (rtotal->encntrcmb[d.seq].totaldet/ rtotal->encntrcmb[d.seq].totalcmb), tot_cmb += rtotal->
   encntrcmb[d.seq].totalcmb, tot_det += rtotal->encntrcmb[d.seq].totaldet
   IF ((max_c < rtotal->encntrcmb[d.seq].maxdet))
    max_c = rtotal->encntrcmb[d.seq].maxdet
   ENDIF
   IF ((min_c > rtotal->encntrcmb[d.seq].mindet)
    AND (rtotal->encntrcmb[d.seq].mindet != 0))
    min_c = rtotal->encntrcmb[d.seq].mindet
   ENDIF
   tot_1k += rtotal->encntrcmb[d.seq].nbr1000
   IF ((rtotal->encntrcmb[d.seq].totalcmb=0))
    col 0, rtotal->encntrcmb[d.seq].actdate"DD-MMM-YYYY;;q", col 14,
    "*** No encounter combine activities on this day ***", row + 1
   ELSE
    row + 1, col 0, rtotal->encntrcmb[d.seq].actdate"DD-MMM-YYYY;;q",
    col 15, rtotal->encntrcmb[d.seq].totalcmb"############;r", col 32,
    rtotal->encntrcmb[d.seq].totaldet"###############;r", col 52, avg1"#####;r",
    col 61, rtotal->encntrcmb[d.seq].maxdet"######;r", col 72,
    rtotal->encntrcmb[d.seq].mindet"#####;r", col 82, rtotal->encntrcmb[d.seq].nbr1000"#####;r",
    row + 1, col 14, "encntr_combine_id with max # of details: ",
    rtotal->encntrcmb[d.seq].maxcmbid"#########;l", " by ", rtotal->encntrcmb[d.seq].maxname,
    row + 1, col 14, "started on ",
    rtotal->encntrcmb[d.seq].maxcmbstime"HH:MM.SS;;q", " and finished on ", rtotal->encntrcmb[d.seq].
    maxcmbetime"HH:MM.SS;;q",
    row + 2
   ENDIF
  FOOT REPORT
   avg2 = (tot_det/ tot_cmb), eor = 1, BREAK,
   col 0, "Summary", row + 1,
   col 0, "=======", row + 2,
   col 0, "Total encounter combines                            =  ", tot_cmb"#######;r",
   row + 1, col 0, "Total encounter combine detail rows                 =  ",
   tot_det"#######;r", row + 1, col 0,
   "Average number of detail rows per combine           =  ", avg2"#######;r", row + 1,
   col 0, "Maximum number of detail rows in a day              =  ", max_c"#######;r",
   row + 1, col 0, "Minimum number of detail rows in a day              =  ",
   min_c"#######;r", row + 1, col 0,
   "Number of combines with more than 1000 detail rows  =  ", tot_1k"#######;r"
  WITH nocounter
 ;end select
END GO
