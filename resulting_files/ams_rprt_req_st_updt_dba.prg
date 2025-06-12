CREATE PROGRAM ams_rprt_req_st_updt:dba
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
 SET script_failed = false
 SET table_name = fillstring(50," ")
 DECLARE serrmsg = vc WITH protect, noconstant("")
 DECLARE ierrcode = i2 WITH protect, noconstant(0)
 DECLARE bamsassociate = i2 WITH protect, noconstant(false)
 EXECUTE ams_define_toolkit_common
 SET bamsassociate = isamsuser(reqinfo->updt_id)
 IF ( NOT (bamsassociate))
  SET script_failed = exe_error
  SET serrmsg = "User must be a Cerner AMS associate to run this program from Explorer Menu"
  GO TO exit_script
 ENDIF
 DECLARE file_name = vc
 DECLARE email = vc
 SET file_name = "report_request_status_update.csv"
 SET email = "DL_BLR_PROD_SUPPORT_PS@cerner.com"
 DECLARE pending_var = f8 WITH constant(uar_get_code_by("MEANING",367571,"PENDING")), protect
 DECLARE inprocessed_var = f8 WITH constant(uar_get_code_by("MEANING",367571,"INPROCESS")), protect
 DECLARE errdms_var = f8 WITH constant(uar_get_code_by("MEANING",367571,"DMSERR")), protect
 DECLARE arcerr_var = f8 WITH constant(uar_get_code_by("MEANING",367571,"ARCHIVEERR")), protect
 DECLARE findmerr_var = f8 WITH constant(uar_get_code_by("MEANING",367571,"FINDPMERR")), protect
 DECLARE errret_var = f8 WITH constant(uar_get_code_by("MEANING",367571,"RETRIEVALERR")), protect
 DECLARE errtrans_var = f8 WITH constant(uar_get_code_by("MEANING",367571,"TRANSFORMERR")), protect
 DECLARE errdeb_var = f8 WITH constant(uar_get_code_by("MEANING",367571,"DEBUGFILEERR")), protect
 DECLARE foerr_var = f8 WITH constant(uar_get_code_by("MEANING",367571,"FOERR")), protect
 DECLARE pdferr_var = f8 WITH constant(uar_get_code_by("MEANING",367571,"PDFERR")), protect
 DECLARE errprocesrpt_var = f8 WITH constant(uar_get_code_by("MEANING",367571,"ERRPROCESRPT")),
 protect
 DECLARE findrrerr_var = f8 WITH constant(uar_get_code_by("MEANING",367571,"FINDRRERR")), protect
 DECLARE facesheeterr_var = f8 WITH constant(uar_get_code_by("MEANING",367571,"FACESHEETERR")),
 protect
 DECLARE watermarkerr_var = f8 WITH constant(uar_get_code_by("MEANING",367571,"WATERMARKERR")),
 protect
 SELECT INTO value(file_name)
  report_request_id = crr.report_request_id, request_stat = uar_get_code_display(crr.report_status_cd
   ), request_date = crr.request_dt_tm"@SHORTDATETIME"
  FROM cr_report_request crr
  WHERE ((crr.request_dt_tm < cnvtlookbehind("10,MIN",sysdate)
   AND crr.request_dt_tm > cnvtlookbehind("60,MIN",sysdate)
   AND crr.report_status_cd=pending_var) OR (((crr.request_dt_tm < cnvtlookbehind("10,MIN",sysdate)
   AND crr.request_dt_tm > cnvtlookbehind("60,MIN",sysdate)
   AND crr.report_status_cd=inprocessed_var) OR (crr.request_dt_tm < cnvtlookbehind("10,MIN",sysdate)
   AND crr.request_dt_tm > cnvtlookbehind("60,MIN",sysdate)
   AND crr.report_status_cd IN (errdms_var, arcerr_var, findmerr_var, errret_var, errtrans_var,
  errdeb_var, foerr_var, pdferr_var, errprocesrpt_var, findrrerr_var,
  facesheeterr_var, watermarkerr_var))) ))
  HEAD REPORT
   line_d = fillstring(90,"*"), line_e = fillstring(110,"-"), blank_line = fillstring(130," "),
   col 0, blank_line, row + 1,
   CALL center("*** Report requests status Report ***",0,120), row + 1, col 0,
   "Report Date: ", curdate"MM/DD/YY;;D", row + 1
  HEAD PAGE
   row + 1, col 0, line_d,
   row + 1, col 0, "Report_Request_ID",
   col 25, "Request_Status", col 60,
   "Request_Date", row + 1, col 0,
   line_d, row + 1
  DETAIL
   report_request_id, col 0, report_request_id,
   request_status = trim(substring(1,30,request_stat)), col 30, request_status,
   request_date, col 60, request_date,
   row + 1
  FOOT PAGE
   row + 1, col 0, line_e,
   row + 1, col 0,
   "Note: Request Type:    1- Adhoc;     2- Expedite;    4- Distribution;     8- MRP "
  WITH nocounter
 ;end select
 IF (curqual=0)
  GO TO exit_program
 ENDIF
 DECLARE subject_line = vc
 SET subject_line = "Report Request Status Report"
 SET dclcom = concat('sed "s/$/`echo \\\r`/" ',file_name," | uuencode ",file_name,' | mail -s "',
  subject_line,'" ',email)
 CALL echo(dclcom)
 SET len = size(trim(dclcom))
 SET status = 0
 CALL dcl(dclcom,len,status)
 SET dclcom = concat("rm ",trim(file_name),"*")
 SET len = size(trim(dclcom))
 SET status = 0
 CALL dcl(dclcom,len,status)
#exit_program
 IF (script_failed != false)
  SELECT INTO value( $OUTDEV)
   message = trim(substring(1,200,serrmsg),3)
   FROM (dummyt d  WITH seq = 1)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
 IF (script_failed != exe_error)
  CALL updtdminfo(trim(cnvtupper(curprog),3))
 ENDIF
END GO
