CREATE PROGRAM ams_rpt_security_audit:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Report Type" = 2,
  "Time Frame" = 0,
  "Limited Begin Date" = "CURDATE",
  "Limited End Date" = "CURDATE"
  WITH outdev, p_report_type, p_time_frame,
  p_beg_date, p_end_date
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 DECLARE serrmsg = vc WITH protect, noconstant("")
 DECLARE ierrcode = i2 WITH protect, noconstant(0)
 EXECUTE ams_define_toolkit_common
 DECLARE dcvnametypepersonnel = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2403228"
   ))
 FREE RECORD rdata
 RECORD rdata(
   1 qual_knt = i4
   1 qual[*]
     2 person_id = f8
     2 full_name = vc
     2 title = vc
     2 status = c40
     2 updt_dt_tm = dq8
     2 beg_eff_dt_tm = dq8
     2 end_eff_dt_tm = dq8
 )
 DECLARE sbegdate = vc WITH protect, noconstant("01-JAN-1970")
 DECLARE senddate = vc WITH protect, noconstant("31-DEC-2100")
 IF (( $P_TIME_FRAME=1))
  SET sbegdate = trim( $P_BEG_DATE,3)
  SET senddate = concat(trim( $P_END_DATE,3)," 23:59:59")
 ENDIF
 SELECT
  IF (( $P_REPORT_TYPE=1))
   PLAN (pl
    WHERE pl.username > " "
     AND pl.active_ind=1
     AND pl.updt_dt_tm BETWEEN cnvtdatetime(sbegdate) AND cnvtdatetime(senddate))
    JOIN (pn
    WHERE pn.person_id=pl.person_id
     AND pn.name_type_cd=dcvnametypepersonnel
     AND pn.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND pn.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     AND cnvtupper(pn.name_title)="CERNER AMS*"
     AND pn.active_ind=1)
  ELSEIF (( $P_REPORT_TYPE=0))
   PLAN (pl
    WHERE pl.username > " "
     AND pl.active_ind=0
     AND pl.updt_dt_tm BETWEEN cnvtdatetime(sbegdate) AND cnvtdatetime(senddate))
    JOIN (pn
    WHERE pn.person_id=pl.person_id
     AND pn.name_type_cd=dcvnametypepersonnel
     AND pn.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND pn.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     AND cnvtupper(pn.name_title)="CERNER AMS*"
     AND pn.active_ind=1)
  ELSE
   PLAN (pl
    WHERE pl.username > " "
     AND pl.updt_dt_tm BETWEEN cnvtdatetime(sbegdate) AND cnvtdatetime(senddate))
    JOIN (pn
    WHERE pn.person_id=pl.person_id
     AND pn.name_type_cd=dcvnametypepersonnel
     AND pn.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND pn.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     AND cnvtupper(pn.name_title)="CERNER AMS*"
     AND pn.active_ind=1)
  ENDIF
  INTO "nl:"
  pl.name_full_formatted, pn.name_title, status =
  IF (pl.active_ind=1) "Active"
  ELSE "Inactive"
  ENDIF
  ,
  pl.beg_effective_dt_tm, pl.end_effective_dt_tm, pl.prsnl_type_cd,
  pn.name_type_cd
  FROM prsnl pl,
   person_name pn
  PLAN (pl
   WHERE pl.username > " ")
   JOIN (pn
   WHERE pn.person_id=pl.person_id
    AND pn.name_type_cd=dcvnametypepersonnel
    AND pn.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pn.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND cnvtupper(pn.name_title)="CERNER AMS*"
    AND pn.active_ind=1)
  ORDER BY status, pl.name_full_formatted, pl.person_id
  HEAD REPORT
   knt = 0, stat = alterlist(rdata->qual,1000)
  HEAD pl.person_id
   knt = (knt+ 1)
   IF (mod(knt,1000)=1
    AND knt != 1)
    stat = alterlist(rdata->qual,(knt+ 999))
   ENDIF
   rdata->qual[knt].person_id = pl.person_id, rdata->qual[knt].full_name = pl.name_full_formatted,
   rdata->qual[knt].title = pn.name_title
   IF (pl.active_ind=1)
    rdata->qual[knt].status = "Active"
   ELSE
    rdata->qual[knt].status = "Inactive"
   ENDIF
   rdata->qual[knt].updt_dt_tm = pl.updt_dt_tm, rdata->qual[knt].beg_eff_dt_tm = pl
   .beg_effective_dt_tm, rdata->qual[knt].end_eff_dt_tm = pl.end_effective_dt_tm
  FOOT REPORT
   rdata->qual_knt = knt, stat = alterlist(rdata->qual,knt)
  WITH nocounter
 ;end select
 IF ((rdata->qual_knt < 1))
  SET failed = select_error
  SET serrmsg = "No Cerner AMS Users Found"
  GO TO exit_script
 ENDIF
 SELECT INTO value( $OUTDEV)
  full_name = trim(substring(1,100,rdata->qual[d.seq].full_name),3), name_title = trim(substring(1,
    100,rdata->qual[d.seq].title),3), status = trim(substring(1,40,rdata->qual[d.seq].status),3),
  updt_dt_tm = format(rdata->qual[d.seq].updt_dt_tm,";;q"), beg_effective_dt_tm = format(rdata->qual[
   d.seq].beg_eff_dt_tm,";;q"), end_effective_dt_tm = format(rdata->qual[d.seq].end_eff_dt_tm,";;q")
  FROM (dummyt d  WITH seq = value(rdata->qual_knt))
  PLAN (d
   WHERE d.seq > 0)
  WITH nocounter, format, separator = " "
 ;end select
#exit_script
 IF (failed != exe_error)
  CALL updtdminfo(trim(cnvtupper(curprog),3))
 ENDIF
 IF (failed != false)
  SELECT INTO value( $OUTDEV)
   message = trim(substring(1,200,serrmsg),3)
   FROM (dummyt d  WITH seq = 1)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = 1)
  WITH nocounter, format, separator = " "
 ;end select
 SET script_ver = "001 02/28/13 Allow Non-Cerner Users to run the report"
END GO
