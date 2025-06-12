CREATE PROGRAM ags_purge_log:dba
 PROMPT
  "AGS_JOB_ID (0.0) = " = 0.0,
  "File Type = " = "",
  "Anchor Date (DD-MMM-YYYY) = " = ""
  WITH did, stype, sdate
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
 IF (get_script_status(0) != esuccessful)
  GO TO exit_script
 ENDIF
 CALL set_log_level(5)
 CALL echo("***")
 CALL echo("***   BEG> AGS_PURGE_LOG")
 CALL echo("***")
 DECLARE djobid = f8 WITH protect, noconstant(0.0)
 DECLARE sfiletype = vc WITH protect, noconstant("")
 DECLARE sanchordate = vc WITH protect, noconstant("")
 FREE RECORD date
 RECORD date(
   1 anchordttm = dq8
 )
 DECLARE found_job = i2 WITH protect, noconstant(false)
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
 SET djobid =  $DID
 SET sfiletype =  $STYPE
 SET sanchordate =  $SDATE
 SET sfiletype = cnvtupper(trim(sfiletype))
 IF (djobid > 0)
  SET found_job = false
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  SELECT INTO "nl:"
   FROM ags_job j
   PLAN (j
    WHERE j.ags_job_id=djobid)
   DETAIL
    found_job = true
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   CALL ags_set_status_block(eselect,efailure,"dJobId VALIDATION",trim(serrmsg))
   GO TO exit_script
  ENDIF
  IF (found_job=false)
   CALL ags_set_status_block(eattribute,efailure,"dJobId VALIDATION",
    "dJobId Must be on the AGS_JOB table")
   GO TO exit_script
  ENDIF
 ELSE
  SET found_job = true
 ENDIF
 SET sanchordate = cnvtupper(trim(sanchordate))
 IF (textlen(trim(sanchordate)) > 0)
  SET idashpos = findstring("-",trim(sanchordate),ibegpos,0)
  IF (idashpos > 1
   AND idashpos < 4)
   SET sdaynbr = substring(ibegpos,(idashpos - ibegpos),trim(sanchordate))
   SET ibegpos = (idashpos+ 1)
   SET idashpos = findstring("-",trim(sanchordate),ibegpos,0)
   IF (idashpos > ibegpos)
    SET smonth = cnvtupper(substring(ibegpos,(idashpos - ibegpos),trim(sanchordate)))
    SET ibegpos = (idashpos+ 1)
    SET iendpos = textlen(trim(sanchordate))
    IF (iendpos > ibegpos)
     IF ((((iendpos - ibegpos)+ 1)=4))
      SET syear = substring(ibegpos,4,trim(sanchordate))
     ELSE
      CALL ags_set_status_block(eattribute,efailure,"ANCHOR_DATE VALIDATION",
       "Anchor Date must be in the format DD-MMM-YYYY")
      GO TO exit_script
     ENDIF
    ELSE
     CALL ags_set_status_block(eattribute,efailure,"ANCHOR_DATE VALIDATION",
      "Anchor Date must be in the format DD-MMM-YYYY")
     GO TO exit_script
    ENDIF
   ELSE
    CALL ags_set_status_block(eattribute,efailure,"ANCHOR_DATE VALIDATION",
     "Anchor Date must be in the format DD-MMM-YYYY")
    GO TO exit_script
   ENDIF
  ELSE
   CALL ags_set_status_block(eattribute,efailure,"ANCHOR_DATE VALIDATION",
    "Anchor Date must be in the format DD-MMM-YYYY")
   GO TO exit_script
  ENDIF
  IF ( NOT (smonth IN ("JAN", "FEB", "MAR", "APR", "MAY",
  "JUN", "JUL", "AUG", "SEP", "OCT",
  "NOV", "DEC")))
   CALL ags_set_status_block(eattribute,efailure,"ANCHOR_DATE VALIDATION",
    "The month must be a valid 3 letter month abbreviation")
   GO TO exit_script
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
       CALL ags_set_status_block(eattribute,efailure,"ANCHOR_DATE VALIDATION",concat("Invalid day (",
         trim(sdaynbr),") for the month (",trim(smonth),")"))
       GO TO exit_script
      ELSE
       SET check_date = concat(trim(sdaynbr),"-",trim(smonth),"-",trim(syear),
        " 00:00:00")
       SET date->anchordttm = cnvtdatetime(value(check_date))
      ENDIF
     ELSE
      CALL ags_set_status_block(eattribute,efailure,"ANCHOR_DATE VALIDATION",concat("The day (",trim(
         sdaynbr),") of the month must be a number"))
      GO TO exit_script
     ENDIF
    ELSE
     CALL ags_set_status_block(eattribute,efailure,"ANCHOR_DATE VALIDATION",
      "Year must be between 1800 and 2200")
     GO TO exit_script
    ENDIF
   ELSE
    CALL ags_set_status_block(eattribute,efailure,"ANCHOR_DATE VALIDATION",
     "Year must be between 1800 and 2200")
    GO TO exit_script
   ENDIF
  ENDIF
 ELSE
  IF (djobid < 1
   AND textlen(sfiletype) < 1)
   CALL ags_set_status_block(eattribute,efailure,"PROMPT VALIDATION",
    "If the JOB_ID or FILE_TYPE are not valued then the ANCHOR_DATE must be valued")
   GO TO exit_script
  ENDIF
 ENDIF
 IF (djobid > 0)
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  DELETE  FROM ags_log a
   PLAN (a
    WHERE a.ags_job_id=djobid)
   WITH nocounter, maxcommit = 1000
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   CALL ags_set_status_block(edelete,efailure,"AGS_JOG by dJobId",trim(serrmsg))
   GO TO exit_script
  ENDIF
  COMMIT
 ENDIF
 IF (size(trim(sfiletype),1) > 0
  AND (date->anchordttm > 0))
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  DELETE  FROM ags_log a
   PLAN (a
    WHERE a.ags_job_id IN (
    (SELECT
     ags_job_id
     FROM ags_job
     WHERE file_type=sfiletype))
     AND a.log_dt_tm < cnvtdatetime(date->anchordttm))
   WITH nocounter, maxcommit = 1000
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   CALL ags_set_status_block(edelete,efailure,"AGS_JOG by FileType/Date",trim(serrmsg))
   GO TO exit_script
  ENDIF
  COMMIT
 ELSEIF (size(trim(sfiletype),1) > 0)
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  DELETE  FROM ags_log a
   PLAN (a
    WHERE a.ags_job_id IN (
    (SELECT
     ags_job_id
     FROM ags_job
     WHERE file_type=sfiletype)))
   WITH nocounter, maxcommit = 1000
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   CALL ags_set_status_block(edelete,efailure,"AGS_JOG by FileType",trim(serrmsg))
   GO TO exit_script
  ENDIF
  COMMIT
 ENDIF
 IF ((date->anchordttm > 0)
  AND size(trim(sfiletype),1) < 1)
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  DELETE  FROM ags_log a
   PLAN (a
    WHERE a.log_dt_tm < cnvtdatetime(date->anchordttm))
   WITH nocounter, maxcommit = 1000
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   CALL ags_set_status_block(edelete,efailure,"AGS_JOG by Date",trim(serrmsg))
   GO TO exit_script
  ENDIF
  COMMIT
 ENDIF
#exit_script
 CALL echo("***")
 CALL echo("***   END> AGS_PURGE_LOG")
 CALL echo("***")
 SET script_ver = "000 11/28/06"
END GO
