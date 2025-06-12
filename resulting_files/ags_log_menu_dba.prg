CREATE PROGRAM ags_log_menu:dba
 IF ( NOT (validate(reply,0)))
  FREE RECORD reply
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 IF (validate(ags_get_code_defined,0)=0)
  EXECUTE ags_get_code
 ENDIF
 IF (validate(ags_log_header_defined,0)=0)
  EXECUTE ags_log_header
 ENDIF
 FREE RECORD msg_rec
 RECORD msg_rec(
   1 qual_knt = i4
   1 qual[*]
     2 line = vc
 )
 IF (get_script_status(0) != esuccessful)
  SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
  SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
  SET msg_rec->qual[msg_rec->qual_knt].line = "EXECUTION ERROR: AGS_LOG_HEADER"
  GO TO msg_menu
 ENDIF
 CALL set_log_level(5)
 FREE RECORD pt
 RECORD pt(
   1 line_cnt = i2
   1 lns[*]
     2 line = vc
 )
 DECLARE accept_value = vc WITH protect, noconstant("")
 DECLARE ijobtype = i2 WITH protect, noconstant(3)
 DECLARE ipurgetype = i2 WITH protect, noconstant(4)
 DECLARE ireporttype = i2 WITH protect, noconstant(4)
 DECLARE sjobtype = vc WITH protect, noconstant("Unknown")
 DECLARE sstringmod = vc WITH protect, noconstant("")
 DECLARE iitemknt = i4 WITH protect, noconstant(0)
 DECLARE imsglength = i2 WITH protect, constant(70)
 DECLARE dworkingjobid = f8 WITH protect, noconstant(0.0)
 DECLARE sworkingfiletype = vc WITH protect, noconstant("")
 DECLARE sworkinganchordate = vc WITH protect, noconstant("")
 DECLARE btouchedanchordatemenu = i2 WITH protect, noconstant(false)
 DECLARE btouchedfiletypemenu = i2 WITH protect, noconstant(false)
 DECLARE a_valid_job(d_job_id=f8) = i2 WITH protect
 DECLARE a_valid_date(s_date=vc) = i2 WITH protect
#main_menu
 SET failed = false
 SET dworkingjobid = 0.0
 SET sworkinganchordate = ""
 SET sworkingfiletype = ""
 SET btouchedanchordatemenu = false
 SET btouchedfiletypemenu = false
 SET stat = initrec(reply)
 CALL ags_set_status_block(ecustom,esuccessful,"","Script defaults to Success")
 CALL video(n)
 CALL clear(1,1)
 CALL box(2,1,22,80)
 CALL line(4,1,80,xhor)
 CALL text(3,3,"AGS Log Menu")
 CALL box(5,5,21,76)
 CALL line(7,5,72,xhor)
 CALL text(6,7," Job Type Menu")
 CALL text(8,7," 1. Purge")
 CALL text(10,7," 2. Report")
 CALL text(12,7," 3. EXIT")
 CALL text(23,2,"Select An Option:  ")
 CALL accept(23,25,"9;H",3
  WHERE curaccept >= 0
   AND curaccept <= 3)
 SET ijobtype = 0
 SET ijobtype = curaccept
 SET sjobtype = "Unknown"
 CASE (ijobtype)
  OF 1:
   SET sjobtype = "Purge"
   GO TO purge_menu
  OF 2:
   SET sjobtype = "Report"
   GO TO report_menu
  OF 3:
   GO TO exit_script
  ELSE
   GO TO main_menu
 ENDCASE
#purge_menu
 CALL clear(1,1)
 CALL box(2,1,22,80)
 CALL line(4,1,80,xhor)
 CALL text(3,3,"AGS Log Menu")
 CALL box(5,5,21,76)
 CALL line(7,5,72,xhor)
 CALL text(6,7," Purge Menu")
 CALL text(8,7," 1. Purge By AGS_JOB_ID")
 CALL text(10,7," 2. Purge By File Type")
 CALL text(12,7," 3. Purge By Date")
 CALL text(14,7," 4. Return to Main Menu")
 CALL text(23,2,"Select An Option:  ")
 CALL accept(23,25,"9;H",4
  WHERE curaccept >= 1
   AND curaccept <= 4)
 SET ipurgetype = 0
 SET ipurgetype = curaccept
 CASE (ipurgetype)
  OF 1:
   GO TO ags_job_id_menu
  OF 2:
   GO TO file_type_menu
  OF 3:
   GO TO anchor_date_menu
  OF 4:
   GO TO main_menu
  ELSE
   GO TO main_menu
 ENDCASE
#report_menu
 CALL clear(1,1)
 CALL box(2,1,22,80)
 CALL line(4,1,80,xhor)
 CALL text(3,3,"AGS Log Menu")
 CALL box(5,5,21,76)
 CALL line(7,5,72,xhor)
 CALL text(6,7," Report Menu")
 CALL text(8,7," 1. Report By AGS_JOB_ID")
 CALL text(10,7," 2. Report By File Type")
 CALL text(12,7," 3. Report By Date")
 CALL text(14,7," 4. Return to Main Menu")
 CALL text(23,2,"Select An Option:  ")
 CALL text(23,2,"Select An Option:  ")
 CALL accept(23,25,"9;H",0
  WHERE curaccept >= 1
   AND curaccept <= 4)
 SET ireporttype = 0
 SET ireporttype = curaccept
 CASE (ireporttype)
  OF 1:
   GO TO ags_job_id_menu
  OF 2:
   GO TO file_type_menu
  OF 3:
   GO TO anchor_date_menu
  OF 4:
   GO TO main_menu
  ELSE
   GO TO main_menu
 ENDCASE
#ags_job_id_menu
 IF (ijobtype=1)
  SET sstringmod = trim(sjobtype)
 ELSEIF (ijobtype=2)
  SET sstringmod = concat(trim(sjobtype)," on")
 ELSE
  SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
  SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
  SET msg_rec->qual[msg_rec->qual_knt].line = "ERROR: Invalid Job Type.  Must be Purge or Report"
  GO TO msg_menu
 ENDIF
 SET dworkingjobid = 0.0
 CALL clear(1,1)
 CALL box(2,1,22,80)
 CALL line(4,1,80,xhor)
 CALL text(3,3,"AGS Log Menu")
 CALL box(5,5,21,76)
 CALL line(7,5,72,xhor)
 CALL text(6,7," Enter AGS_JOB_ID Value")
 CALL text(8,7,concat(" Enter the AGS_JOB_ID value you wish to ",trim(sstringmod)))
 CALL text(23,2,"Enter <0> for Main Menu:  ")
 CALL accept(23,28,"P(20);C")
 SET accept_value = curaccept
 IF (isnumeric(accept_value) < 1)
  SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
  SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
  SET msg_rec->qual[msg_rec->qual_knt].line = "ERROR: Invalid AGS_JOB_ID.  Must be a number"
  GO TO msg_menu
 ENDIF
 SET dworkingjobid = cnvtreal(accept_value)
 IF (dworkingjobid < 1)
  GO TO main_menu
 ENDIF
 IF ( NOT (a_valid_job(dworkingjobid)))
  GO TO msg_menu
 ENDIF
 SET sworkingfiletype = ""
 SET sworkinganchordate = ""
 IF (ijobtype=1)
  GO TO execute_purge
 ELSE
  GO TO execute_report
 ENDIF
#file_type_menu
 IF (ijobtype=1)
  SET sstringmod = trim(sjobtype)
 ELSEIF (ijobtype=2)
  SET sstringmod = concat(trim(sjobtype)," on")
 ELSE
  SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
  SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
  SET msg_rec->qual[msg_rec->qual_knt].line = "ERROR: Invalid Job Type.  Must be Purge or Report"
  GO TO msg_menu
 ENDIF
 SET btouchedfiletypemenu = true
 SET sworkingfiletype = ""
 CALL clear(1,1)
 CALL box(2,1,22,80)
 CALL line(4,1,80,xhor)
 CALL text(3,3,"AGS Log Menu")
 CALL box(5,5,21,76)
 CALL line(7,5,72,xhor)
 CALL text(6,7," Enter File Type")
 CALL text(8,7,concat("Enter the File Type you wish to ",trim(sstringmod)))
 CALL text(10,7,"  <<enter NONE to specify no File Type>>")
 CALL text(23,2,"Enter <0> for Main Menu:  ")
 CALL accept(23,28,"P(20);C")
 SET accept_value = curaccept
 IF (cnvtupper(trim(accept_value))="NONE")
  SET sworkingfiletype = ""
 ELSE
  SET sworkingfiletype = cnvtupper(trim(accept_value))
 ENDIF
 IF (isnumeric(sworkingfiletype) > 0)
  IF (cnvtint(sworkingfiletype)=0)
   GO TO main_menu
  ELSE
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line =
   "ERROR: Invalid File Type.  File Type must be a value from the AGS_JOB table"
   GO TO msg_menu
  ENDIF
 ENDIF
 IF (btouchedanchordatemenu=false)
  GO TO anchor_date_menu
 ENDIF
 IF (ijobtype=1)
  GO TO execute_purge
 ELSE
  GO TO execute_report
 ENDIF
#anchor_date_menu
 IF (ijobtype=1)
  SET sstringmod = trim(sjobtype)
 ELSEIF (ijobtype=2)
  SET sstringmod = trim(sjobtype)
 ELSE
  SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
  SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
  SET msg_rec->qual[msg_rec->qual_knt].line = "ERROR: Invalid Job Type.  Must be Purge or Report"
  GO TO msg_menu
 ENDIF
 SET btouchedanchordatemenu = true
 SET sworkinganchordate = ""
 CALL clear(1,1)
 CALL box(2,1,22,80)
 CALL line(4,1,80,xhor)
 CALL text(3,3,"AGS Log Menu")
 CALL box(5,5,21,76)
 CALL line(7,5,72,xhor)
 CALL text(6,7," Enter Date (DD-MMM-YYYY)")
 CALL text(8,7,concat("Enter the date of the ",trim(sstringmod)))
 IF (ijobtype=1)
  CALL text(10,7,"All AGS_LOG data prior to the Date entered will be deleted")
 ELSE
  CALL text(10,7,"AGS_LOG Reports will be ran on data entered after the date supplied")
 ENDIF
 CALL text(12,7,"  <<enter NONE to specify no date>>")
 CALL text(23,2,"Enter <0> for Main Menu:  ")
 CALL accept(23,28,"P(20);C")
 SET accept_value = curaccept
 IF (cnvtupper(trim(accept_value))="NONE")
  SET sworkinganchordate = ""
 ELSE
  SET sworkinganchordate = cnvtupper(trim(accept_value))
 ENDIF
 IF (isnumeric(sworkinganchordate) > 0)
  IF (cnvtint(sworkinganchordate)=0)
   GO TO main_menu
  ELSE
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line =
   "ERROR: Invalid Date.  Date must be in the format of DD-MMM-YYYY"
   GO TO msg_menu
  ENDIF
 ENDIF
 IF (size(trim(sworkinganchordate),1) > 0)
  IF ( NOT (a_valid_date(sworkinganchordate)))
   GO TO msg_menu
  ENDIF
 ENDIF
 IF (btouchedfiletypemenu=false)
  GO TO file_type_menu
 ENDIF
 IF (ijobtype=1)
  GO TO execute_purge
 ELSE
  GO TO execute_report
 ENDIF
#execute_purge
 IF (dworkingjobid < 1
  AND size(trim(sworkingfiletype),1) < 1
  AND size(trim(sworkinganchordate),1) < 1)
  SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
  SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
  SET msg_rec->qual[msg_rec->qual_knt].line =
  "ERROR: Invalid Data.  If the Job Id is not valued then either the"
  SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
  SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
  SET msg_rec->qual[msg_rec->qual_knt].line = "File Type or Date must be valued"
  GO TO msg_menu
 ENDIF
 EXECUTE ags_purge_log value(dworkingjobid), value(sworkingfiletype), value(sworkinganchordate)
 IF ((reply->status_data.status="S"))
  SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
  SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
  SET msg_rec->qual[msg_rec->qual_knt].line = concat("SUCCESS: AGS_PURGE_LOG (",trim(cnvtstring(
     dworkingjobid)),") (",trim(sworkingfiletype),") (",
   trim(sworkinganchordate),")")
 ELSE
  SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
  SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
  SET msg_rec->qual[msg_rec->qual_knt].line = concat("EXECUTION ERROR: AGS_PURGE_LOG (",trim(
    cnvtstring(dworkingjobid)),") (",trim(sworkingfiletype),") (",
   trim(sworkinganchordate),")")
  SET iitemknt = size(reply->status_data.subeventstatus,5)
  FOR (idx = 1 TO iitemknt)
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = concat(trim(reply->status_data.subeventstatus[idx].
      operationname)," <> ",trim(reply->status_data.subeventstatus[idx].operationstatus)," <> ",trim(
      reply->status_data.subeventstatus[idx].targetobjectname))
    SET pt->line_cnt = 0
    EXECUTE dcp_parse_text value(trim(reply->status_data.subeventstatus[idx].targetobjectvalue)),
    value(imsglength)
    FOR (jdx = 1 TO pt->line_cnt)
      SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
      SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
      SET msg_rec->qual[msg_rec->qual_knt].line = trim(pt->lns[jdx].line)
    ENDFOR
  ENDFOR
 ENDIF
 GO TO msg_menu
#execute_report
 IF (dworkingjobid < 1
  AND size(trim(sworkingfiletype),1) < 1
  AND size(trim(sworkinganchordate),1) < 1)
  SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
  SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
  SET msg_rec->qual[msg_rec->qual_knt].line =
  "ERROR: Invalid Data.  If the Job Id is not valued then either the"
  SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
  SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
  SET msg_rec->qual[msg_rec->qual_knt].line = "File Type or Date must be valued"
  GO TO msg_menu
 ENDIF
 EXECUTE ags_rpt_log_basic value(dworkingjobid), value(sworkingfiletype), value(sworkinganchordate)
 IF ((reply->status_data.status="S"))
  SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
  SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
  SET msg_rec->qual[msg_rec->qual_knt].line = concat("SUCCESS: AGS_RPT_LOG_BASIC (",trim(cnvtstring(
     dworkingjobid)),") (",trim(sworkingfiletype),") (",
   trim(sworkinganchordate),")")
 ELSE
  SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
  SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
  SET msg_rec->qual[msg_rec->qual_knt].line = concat("EXECUTION ERROR: AGS_RPT_LOG_BASIC (",trim(
    cnvtstring(dworkingjobid)),") (",trim(sworkingfiletype),") (",
   trim(sworkinganchordate),")")
  SET iitemknt = size(reply->status_data.subeventstatus,5)
  FOR (idx = 1 TO iitemknt)
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = concat(trim(reply->status_data.subeventstatus[idx].
      operationname)," <> ",trim(reply->status_data.subeventstatus[idx].operationstatus)," <> ",trim(
      reply->status_data.subeventstatus[idx].targetobjectname))
    SET pt->line_cnt = 0
    EXECUTE dcp_parse_text value(trim(reply->status_data.subeventstatus[idx].targetobjectvalue)),
    value(imsglength)
    FOR (jdx = 1 TO pt->line_cnt)
      SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
      SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
      SET msg_rec->qual[msg_rec->qual_knt].line = trim(pt->lns[jdx].line)
    ENDFOR
  ENDFOR
 ENDIF
 GO TO msg_menu
#msg_menu
 CALL clear(1,1)
 CALL box(2,1,22,80)
 CALL line(4,1,80,xhor)
 CALL text(3,3,"AGS Log Menu")
 CALL box(5,5,21,76)
 CALL line(7,5,72,xhor)
 CALL text(6,7," Message Screen")
 IF ((msg_rec->qual_knt < 1))
  CALL text(8,6," Unknown Message")
 ELSE
  SET msg_line_nbr = 8
  SET msg_wknt = 1
  WHILE (msg_line_nbr <= 21
   AND (msg_wknt <= msg_rec->qual_knt))
    CALL text(msg_line_nbr,6,msg_rec->qual[msg_wknt].line)
    SET msg_line_nbr = (msg_line_nbr+ 1)
    SET msg_wknt = (msg_wknt+ 1)
  ENDWHILE
 ENDIF
 SET stat = initrec(msg_rec)
 CALL text(23,2,"Enter <0> for Main Menu:  ")
 CALL accept(23,27,"9;H",0
  WHERE curaccept >= 0)
 GO TO main_menu
 SUBROUTINE a_valid_job(temp_job_id)
   DECLARE found_job = i2 WITH protect, noconstant(false)
   SET found_job = false
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   SELECT INTO "nl:"
    FROM ags_job j
    PLAN (j
     WHERE j.ags_job_id=temp_job_id)
    DETAIL
     found_job = true
    WITH nocounter
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = concat("SCRIPT ERROR :: Validating AGS_JOB_ID (",trim
     (cnvtstring(temp_job_id)),")")
    RETURN(false)
   ENDIF
   IF (found_job=false)
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = concat("SEARCH ERROR :: Validating AGS_JOB_ID (",trim
     (cnvtstring(temp_job_id)),")")
    RETURN(false)
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE a_valid_date(sanchor_date)
   DECLARE sdaynbr = vc WITH protect, noconstant("")
   DECLARE idaynbr = i2 WITH protect, noconstant(0)
   DECLARE smonth = vc WITH protect, noconstant("")
   DECLARE syear = vc WITH protect, noconstant("")
   DECLARE iyear = i4 WITH protect, noconstant(0)
   DECLARE check_date = vc WITH protect, noconstant("")
   DECLARE idashpos = i4 WITH protect, noconstant(0)
   DECLARE ibegpos = i4 WITH protect, noconstant(1)
   DECLARE iendpos = i4 WITH protect, noconstant(0)
   DECLARE ibegday = i2 WITH protect, noconstant(1)
   DECLARE iendday = i2 WITH protect, noconstant(0)
   IF (textlen(trim(sanchor_date)) > 0)
    SET idashpos = findstring("-",trim(sanchor_date),ibegpos,0)
    IF (idashpos > 1
     AND idashpos < 4)
     SET sdaynbr = substring(ibegpos,(idashpos - ibegpos),trim(sanchor_date))
     SET ibegpos = (idashpos+ 1)
     SET idashpos = findstring("-",trim(sanchor_date),ibegpos,0)
     IF (idashpos > ibegpos)
      SET smonth = cnvtupper(substring(ibegpos,(idashpos - ibegpos),trim(sanchor_date)))
      SET ibegpos = (idashpos+ 1)
      SET iendpos = textlen(trim(sanchor_date))
      IF (iendpos > ibegpos)
       IF ((((iendpos - ibegpos)+ 1)=4))
        SET syear = substring(ibegpos,4,trim(sanchor_date))
       ELSE
        SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
        SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
        SET msg_rec->qual[msg_rec->qual_knt].line = concat("INVALID DATE :: (",trim(sanchor_date),
         ") the date must be in the format of DD-MMM-YYYY")
        RETURN(false)
       ENDIF
      ELSE
       SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
       SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
       SET msg_rec->qual[msg_rec->qual_knt].line = concat("INVALID DATE :: (",trim(sanchor_date),
        ") the date must be in the format of DD-MMM-YYYY")
       RETURN(false)
      ENDIF
     ELSE
      SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
      SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
      SET msg_rec->qual[msg_rec->qual_knt].line = concat("INVALID DATE :: (",trim(sanchor_date),
       ") the date must be in the format of DD-MMM-YYYY")
      RETURN(false)
     ENDIF
    ELSE
     SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
     SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
     SET msg_rec->qual[msg_rec->qual_knt].line = concat("INVALID DATE :: (",trim(sanchor_date),
      ") the date must be in the format of DD-MMM-YYYY")
     RETURN(false)
    ENDIF
    IF ( NOT (smonth IN ("JAN", "FEB", "MAR", "APR", "MAY",
    "JUN", "JUL", "AUG", "SEP", "OCT",
    "NOV", "DEC")))
     SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
     SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
     SET msg_rec->qual[msg_rec->qual_knt].line = concat("INVALID DATE :: (",trim(sanchor_date),
      ") The month must be a valid 3 letter month abbreviation")
     RETURN(false)
    ELSE
     IF (isnumeric(syear)=1)
      SET iyear = cnvtint(syear)
      IF (iyear >= 1800
       AND iyear <= 2200)
       SET check_date = concat("15-",trim(smonth),"-",trim(syear))
       SET iendday = 0
       SET iendday = day(datetimefind(cnvtdatetime(value(check_date)),"M","E","P"))
       IF (isnumeric(sdaynbr)=1)
        SET idaynbr = cnvtint(sdaynbr)
        IF (((idaynbr < ibegday) OR (idaynbr > iendday)) )
         SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
         SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
         SET msg_rec->qual[msg_rec->qual_knt].line = concat("INVALID DATE :: (",trim(sanchor_date),
          ") invalid day (",trim(sdaynbr),") for the month (",
          trim(smonth),")")
         RETURN(false)
        ELSE
         RETURN(true)
        ENDIF
       ELSE
        SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
        SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
        SET msg_rec->qual[msg_rec->qual_knt].line = concat("INVALID DATE :: (",trim(sanchor_date),
         ") The day (",trim(sdaynbr),") of the month must be a number")
        RETURN(false)
       ENDIF
      ELSE
       SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
       SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
       SET msg_rec->qual[msg_rec->qual_knt].line = concat("INVALID DATE :: (",trim(sanchor_date),
        ") Year must be between 1800 and 2200")
       RETURN(false)
      ENDIF
     ELSE
      SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
      SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
      SET msg_rec->qual[msg_rec->qual_knt].line = concat("INVALID DATE :: (",trim(sanchor_date),
       ") Year must be between 1800 and 2200")
      RETURN(false)
     ENDIF
    ENDIF
   ELSE
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = concat("INVALID DATE :: (",trim(sanchor_date),
     ") the date must be in the format of DD-MMM-YYYY")
    RETURN(false)
   ENDIF
 END ;Subroutine
#exit_script
 CALL echorecord(reply)
 SET script_ver = "000 11/28/06"
END GO
