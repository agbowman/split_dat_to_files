CREATE PROGRAM bbd_rpt_donortypes:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET count1 = 0
 SET report_complete_ind = "N"
 SET line = fillstring(125,"_")
 SET cur_username = fillstring(10," ")
 SET cur_username = get_username(reqinfo->updt_id)
 SELECT INTO "cer_temp:bbddonortypes.txt"
  c.*
  FROM code_value c
  PLAN (c
   WHERE c.code_set=14216
    AND c.code_value > 0)
  ORDER BY c.collation_seq
  HEAD PAGE
   col 1, "Cerner Health Systems",
   CALL center("D O N O R   T Y P E S   R E P O R T",1,125),
   col 107, "Time:", col 121,
   curtime"hh:mm;;m", row + 1, col 107,
   "As of Date:", col 119, curdate"ddmmmyy;;d",
   row + 3, col 13, "Donor Type Display",
   col 46, "Donor Type Description", col 79,
   "Effective", col 95, "End Effective",
   col 113, "Active", row + 1,
   col 7, "------------------------------", col 42,
   "------------------------------", col 77, "-------------",
   col 95, "-------------", col 113,
   "------", row + 1
  DETAIL
   col 7, c.display"###################", col 42,
   c.description"###################", col 77, c.begin_effective_dt_tm"ddmmmyy;;d",
   col 85, c.begin_effective_dt_tm"hh:mm;;m", col 95,
   c.end_effective_dt_tm"ddmmmyy;;d", col 103, c.end_effective_dt_tm"hh:mm;;m"
   IF (c.active_ind=1)
    col 114, "YES"
   ELSE
    col 114, "NO"
   ENDIF
   row + 1
   IF (row > 56)
    BREAK
   ENDIF
  FOOT PAGE
   row 57, col 1, line,
   row + 1, col 1, "Report ID: BBD_RPT_DONORTYPES",
   col 58, "Page:", col 64,
   curpage"###", col 109, "Printed:",
   col 119, curdate"ddmmmyy;;d", row + 1,
   col 109, "By:", col 119,
   cur_username
  FOOT REPORT
   row 60, col 51, "* * * End of Report * * *",
   report_complete_ind = "Y"
  WITH nullreport, counter, maxrow = 61,
   compress, nolandscape
 ;end select
 SET count1 = (count1+ 1)
 IF (count1 > 1)
  SET stat = alterlist(reply->status_data.subeventstatus,(count1+ 1))
 ENDIF
 IF (report_complete_ind="Y")
  SET reply->status_data.status = "S"
  SET reply->status_data.subeventstatus[count1].operationname = "Report Complete"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbd_rpt_donortypes"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue = "Report completed successfully"
 ELSE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationname = "Abnormal End"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbd_rpt_donortypes"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue = "Report ended abnormally"
 ENDIF
 GO TO exit_script
 DECLARE get_username(sub_person_id) = c10
 SUBROUTINE get_username(sub_person_id)
   SET sub_get_username = fillstring(10," ")
   SELECT INTO "nl:"
    pnl.username
    FROM prsnl pnl
    WHERE pnl.person_id=sub_person_id
     AND pnl.person_id != null
     AND pnl.person_id > 0.0
    DETAIL
     sub_get_username = pnl.username
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET inc_i18nhandle = 0
    SET inc_h = uar_i18nlocalizationinit(inc_i18nhandle,curprog,"",curcclrev)
    SET sub_get_username = uar_i18ngetmessage(inc_i18nhandle,"inc_unknown","<Unknown>")
   ENDIF
   RETURN(sub_get_username)
 END ;Subroutine
#exit_script
END GO
