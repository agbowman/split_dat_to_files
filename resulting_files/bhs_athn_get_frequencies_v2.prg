CREATE PROGRAM bhs_athn_get_frequencies_v2
 FREE RECORD result
 RECORD result(
   1 frequencies[*]
     2 frequency_cd = f8
     2 description = vc
     2 display = vc
     2 frequency_type = i2
     2 frequency_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE RECORD req500518
 RECORD req500518(
   1 activity_type_cd = f8
 ) WITH protect
 FREE RECORD rep500518
 RECORD rep500518(
   1 data_cnt = i4
   1 data[*]
     2 frequency_cd = f8
     2 freq_desc = vc
     2 freq_display = vc
     2 freq_meaning = vc
     2 frequency_type = i2
     2 active_ind = i2
     2 frequency_id = f8
     2 hybrid_ind = i2
     2 prn_default_ind = i2
   1 status_data
     2 status = vc
     2 substatus = i2
     2 subeventstatus[1]
       3 operationname = vc
       3 operationstatus = vc
       3 targetobjectname = vc
       3 targetobjectvalue = vc
 ) WITH protect
 FREE RECORD req300021
 RECORD req300021(
   1 frequency_cd = f8
   1 order_id = f8
   1 order_provider_id = f8
   1 catalog_cd = f8
   1 med_class_cd = f8
   1 nurse_unit_cd = f8
   1 activity_type_cd = f8
   1 exclude_inactive_sched_ind = i2
 ) WITH protect
 FREE RECORD rep300021
 RECORD rep300021(
   1 frequency_id = f8
   1 frequency_type = i4
   1 prn_default_ind = i2
   1 hybrid_ind = i2
   1 status_data
     2 status = vc
     2 substatus = i2
     2 subeventstatus[1]
       3 operationname = vc
       3 operationstatus = vc
       3 targetobjectname = vc
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE callgetfreqid(null) = i2
 DECLARE callgetfreqlist(null) = i2
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 SET result->status_data.status = "F"
 IF (( $5 <= 0.0))
  CALL echo("INVALID ACTIVITY TYPE CD PARAMETER...EXITING")
  GO TO exit_script
 ENDIF
 IF (( $6=1))
  IF (( $2 <= 0.0))
   CALL echo("INVALID ORDER PROVIDER ID PARAMETER...EXITING")
   GO TO exit_script
  ELSEIF (( $3 <= 0.0))
   CALL echo("INVALID CATALOG CD PARAMETER...EXITING")
   GO TO exit_script
  ELSEIF (( $4 <= 0.0))
   CALL echo("INVALID NURSE UNIT CD PARAMETER...EXITING")
   GO TO exit_script
  ENDIF
 ENDIF
 SET stat = callgetfreqlist(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 IF (( $6=1))
  SET stat = callgetfreqid(null)
  IF (stat=fail)
   GO TO exit_script
  ENDIF
 ENDIF
 SET result->status_data.status = "S"
#exit_script
 CALL echorecord(result)
 IF (size(trim(moutputdevice,3)) > 0)
  DECLARE v1 = vc WITH protect, noconstant("")
  DECLARE v2 = vc WITH protect, noconstant("")
  DECLARE v3 = vc WITH protect, noconstant("")
  DECLARE v4 = vc WITH protect, noconstant("")
  DECLARE v5 = vc WITH protect, noconstant("")
  IF ((result->status_data.status="S"))
   SELECT INTO value(moutputdevice)
    FROM dummyt d
    PLAN (d
     WHERE d.seq > 0)
    HEAD REPORT
     html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
      '"',"UTF-8",'"'," ?>"), col 0, html_tag,
     row + 1, col + 1, "<ReplyMessage>",
     row + 1, col + 1, "<Frequencies>",
     row + 1
     FOR (idx = 1 TO size(result->frequencies,5))
       col + 1, "<Frequency>", row + 1,
       v1 = build("<FrequencyCd>",cnvtint(result->frequencies[idx].frequency_cd),"</FrequencyCd>"),
       col + 1, v1,
       row + 1, v2 = build("<Description>",trim(replace(replace(replace(replace(replace(result->
              frequencies[idx].description,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),
          '"',"&quot;",0),3),"</Description>"), col + 1,
       v2, row + 1, v3 = build("<Display>",trim(replace(replace(replace(replace(replace(result->
              frequencies[idx].display,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
          "&quot;",0),3),"</Display>"),
       col + 1, v3, row + 1,
       v4 = build("<FrequencyType>",result->frequencies[idx].frequency_type,"</FrequencyType>"), col
        + 1, v4,
       row + 1, v5 = build("<FrequencyId>",cnvtint(result->frequencies[idx].frequency_id),
        "</FrequencyId>"), col + 1,
       v5, row + 1, col + 1,
       "</Frequency>", row + 1
     ENDFOR
     col + 1, "</Frequencies>", row + 1,
     col + 1, "</ReplyMessage>", row + 1
    WITH maxcol = 32000, nocounter, nullreport,
     formfeed = none, format = variable, time = 30
   ;end select
  ENDIF
 ENDIF
 FREE RECORD result
 FREE RECORD req500518
 FREE RECORD rep500518
 FREE RECORD req300021
 FREE RECORD rep300021
 SUBROUTINE callgetfreqlist(null)
   DECLARE applicationid = i4 WITH protect, constant(600005)
   DECLARE taskid = i4 WITH protect, constant(500196)
   DECLARE requestid = i4 WITH protect, constant(500518)
   DECLARE freqcnt = i4 WITH protect, noconstant(0)
   SET req500518->activity_type_cd =  $5
   CALL echorecord(req500518)
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req500518,
    "REC",rep500518,1)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    RETURN(fail)
   ENDIF
   CALL echorecord(rep500518)
   IF ((rep500518->status_data.status != "F"))
    SET stat = alterlist(result->frequencies,rep500518->data_cnt)
    FOR (idx = 1 TO rep500518->data_cnt)
      IF ((rep500518->data[idx].active_ind=1))
       SET freqcnt = (freqcnt+ 1)
       SET result->frequencies[freqcnt].frequency_cd = rep500518->data[idx].frequency_cd
       SET result->frequencies[freqcnt].description = rep500518->data[idx].freq_desc
       SET result->frequencies[freqcnt].display = rep500518->data[idx].freq_display
       SET result->frequencies[freqcnt].frequency_id = rep500518->data[idx].frequency_id
       SET result->frequencies[freqcnt].frequency_type = rep500518->data[idx].frequency_type
      ENDIF
    ENDFOR
    SET stat = alterlist(result->frequencies,freqcnt)
    RETURN(success)
   ENDIF
   RETURN(fail)
 END ;Subroutine
 SUBROUTINE callgetfreqid(null)
   DECLARE applicationid = i4 WITH protect, constant(600005)
   DECLARE taskid = i4 WITH protect, constant(500196)
   DECLARE requestid = i4 WITH protect, constant(300021)
   FOR (idx = 1 TO size(result->frequencies,5))
     SET req300021->frequency_cd = result->frequencies[idx].frequency_cd
     SET req300021->order_provider_id =  $2
     SET req300021->catalog_cd =  $3
     SET req300021->nurse_unit_cd =  $4
     SET req300021->activity_type_cd =  $5
     SET req300021->exclude_inactive_sched_ind = 1
     CALL echorecord(req300021)
     SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req300021,
      "REC",rep300021,1)
     IF (stat > 0)
      SET errcode = error(errmsg,1)
      CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
        errmsg))
      RETURN(fail)
     ENDIF
     CALL echorecord(rep300021)
     IF ((rep300021->status_data.status="F"))
      RETURN(fail)
     ENDIF
     SET result->frequencies[idx].frequency_id = rep300021->frequency_id
     SET result->frequencies[idx].frequency_type = rep300021->frequency_type
   ENDFOR
   RETURN(success)
 END ;Subroutine
END GO
