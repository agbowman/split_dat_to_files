CREATE PROGRAM ct_data_capture_driver:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 text = vgc
    1 text_type = vc
    1 file_name = vc
    1 large_text_qual[*]
      2 text_segment = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 subject_data[*]
      2 subject_key = vc
      2 study_event_data[*]
        3 study_event_oid = vc
        3 audit_user_oid = vc
        3 audit_location_oid = vc
        3 form_data[*]
          4 form_oid = vc
          4 item_group_data[*]
            5 item_group_oid = vc
            5 item_group_repeat_key = vc
            5 audit_performed_by = vc
            5 audit_performed_timestamp = vc
            5 item_data[*]
              6 item_oid = vc
              6 item_type = vc
              6 value = vc
              6 is_null = i2
              6 measurement_unit_oid = vc
              6 audit_performed_by = vc
              6 audit_performed_timestamp = vc
              6 audit_record_id = vc
  )
 ENDIF
 FREE RECORD drec
 RECORD drec(
   1 line_cnt = i4
   1 line_qual[*]
     2 disp_line = vc
 )
 DECLARE script_version = vc WITH protect, noconstant(" ")
 DECLARE failed = c1 WITH protect, noconstant("S")
 DECLARE program_name = vc WITH protect, noconstant(fillstring(30," "))
 DECLARE format_script_dt_tm = vc WITH protect
 SET format_script_dt_tm = format(cnvtdatetime(curdate,curtime3),"YYYY-MM-DDTHH:MM:SS-06:00;;D")
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE performed_by_size = i4 WITH protect, noconstant(0)
 DECLARE performed_timestamp_size = i4 WITH protect, noconstant(0)
 DECLARE start_odm(dummy=i4) = null
 DECLARE end_odm(dummy=i4) = null
 DECLARE start_audit_records(dummy=i4) = null
 DECLARE end_audit_records(dummy=i4) = null
 DECLARE start_item_data(subject_data_idx=i4,study_event_data_idx=i4,form_data_idx=i4,
  item_group_data_idx=i4,item_data_idx=i4) = null
 DECLARE start_item_group_data(subject_data_idx=i4,study_event_data_idx=i4,form_data_idx=i4,
  item_group_data_idx=i4) = null
 DECLARE end_item_group_data(dummy=i4) = null
 DECLARE start_audit_record(subject_data_idx=i4,study_event_data_idx=i4) = null
 DECLARE end_audit_record(dummy=i4) = null
 DECLARE start_form_data(subject_data_idx=i4,study_event_data_idx=i4,form_data_idx=i4) = null
 DECLARE end_form_data(dummy=i4) = null
 DECLARE start_study_event_data(subject_data_idx=i4,study_event_data_idx=i4) = null
 DECLARE end_study_event_data(dummy=i4) = null
 DECLARE start_subject_data(subject_data_idx=i4) = null
 DECLARE end_subject_data(dummy=i4) = null
 DECLARE start_clinical_data(dummy=i4) = null
 DECLARE end_clinical_data(dummy=i4) = null
 DECLARE add_line(line=vc) = null
 DECLARE encode_value(value=vc) = vc
 DECLARE start_item_group_audit_record(subject_data_idx=i4,study_event_data_idx=i4,form_data_idx=i4,
  item_group_data_idx=i4) = null
 DECLARE start_item_audit_record(subject_data_idx=i4,study_event_data_idx=i4,form_data_idx=i4,
  item_group_data_idx=i4,item_data_idx=i4) = null
 IF (trim(request->script_name) > " ")
  SET program_name = cnvtupper(trim(request->script_name))
  SET scriptexists = checkprg(program_name)
  CALL echo(build("scriptexists = ",scriptexists))
  IF (scriptexists=0)
   SET failed = "F"
   SET reply->status_data.subeventstatus[1].operationname = "EXECUTE"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "Script"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = build("program(",program_name,
    ") was not found in the object library")
   GO TO exit_script
  ENDIF
  EXECUTE value(program_name)
  IF ((reply->status_data.status != "S"))
   SET failed = reply->status_data.status
   GO TO exit_script_text_comp
  ENDIF
 ENDIF
 IF (size(reply->text,1) > 0)
  GO TO exit_script_text_comp
 ENDIF
 CALL start_odm(0)
 CALL start_clinical_data(0)
 FOR (a = 1 TO size(reply->subject_data,5))
   CALL start_subject_data(a)
   FOR (b = 1 TO size(reply->subject_data[a].study_event_data,5))
     CALL start_study_event_data(a,b)
     IF (((textlen(reply->subject_data[a].study_event_data[b].audit_location_oid) > 0) OR (textlen(
      reply->subject_data[a].study_event_data[b].audit_user_oid) > 0)) )
      CALL start_audit_record(a,b)
      CALL end_audit_record(0)
     ENDIF
     FOR (c = 1 TO size(reply->subject_data[a].study_event_data[b].form_data,5))
       CALL start_form_data(a,b,c)
       FOR (d = 1 TO size(reply->subject_data[a].study_event_data[b].form_data[c].item_group_data,5))
         CALL start_item_group_data(a,b,c,d)
         SET performed_by_size = textlen(reply->subject_data[a].study_event_data[b].form_data[c].
          item_group_data[d].audit_performed_by)
         SET performed_timestamp_size = textlen(reply->subject_data[a].study_event_data[b].form_data[
          c].item_group_data[d].audit_performed_timestamp)
         IF (performed_by_size > 0
          AND performed_timestamp_size > 0)
          CALL start_item_group_audit_record(a,b,c,d)
          CALL end_audit_record(0)
         ENDIF
         FOR (e = 1 TO size(reply->subject_data[a].study_event_data[b].form_data[c].item_group_data[d
          ].item_data,5))
           CALL start_item_data(a,b,c,d,e)
         ENDFOR
         CALL end_item_group_data(0)
       ENDFOR
       CALL end_form_data(0)
     ENDFOR
     CALL end_study_event_data(0)
   ENDFOR
   CALL end_subject_data(0)
 ENDFOR
 CALL start_audit_records(0)
 FOR (a = 1 TO size(reply->subject_data,5))
   FOR (b = 1 TO size(reply->subject_data[a].study_event_data,5))
     FOR (c = 1 TO size(reply->subject_data[a].study_event_data[b].form_data,5))
       FOR (d = 1 TO size(reply->subject_data[a].study_event_data[b].form_data[c].item_group_data,5))
         FOR (e = 1 TO size(reply->subject_data[a].study_event_data[b].form_data[c].item_group_data[d
          ].item_data,5))
           CALL start_item_audit_record(a,b,c,d,e)
         ENDFOR
       ENDFOR
     ENDFOR
   ENDFOR
 ENDFOR
 CALL end_audit_records(0)
 CALL end_clinical_data(0)
 CALL end_odm(0)
 SUBROUTINE encode_value(value)
   DECLARE newvalue = vc WITH protect, noconstant(" ")
   SET newvalue = nullterm(value)
   SET newvalue = replace(newvalue,"&","&amp;",0)
   SET newvalue = replace(newvalue,"<","&lt;",0)
   SET newvalue = replace(newvalue,">","&gt;",0)
   SET newvalue = replace(newvalue,"'","&apos;",0)
   SET newvalue = replace(newvalue,'"',"&quot;",0)
   RETURN(newvalue)
 END ;Subroutine
 SUBROUTINE start_item_data(subject_data_idx,study_event_data_idx,form_data_idx,item_group_data_idx,
  item_data_idx)
   DECLARE newvalue = vc WITH protect, noconstant(" ")
   DECLARE itemdatatype = vc WITH protect, noconstant(" ")
   DECLARE auditrecordid = vc WITH protect, noconstant(" ")
   DECLARE measurementunitid = vc WITH protect, noconstant(" ")
   DECLARE itemdatatype_encode = vc WITH protect, noconstant(" ")
   DECLARE auditrecordid_encode = vc WITH protect, noconstant(" ")
   DECLARE measurementunitid_encode = vc WITH protect, noconstant(" ")
   DECLARE itemoid_encode = vc WITH protect, noconstant(" ")
   SET auditrecordid = " "
   SET itemdatatype_encode = encode_value(reply->subject_data[subject_data_idx].study_event_data[
    study_event_data_idx].form_data[form_data_idx].item_group_data[item_group_data_idx].item_data[
    item_data_idx].item_type)
   SET itemdatatype = trim(itemdatatype_encode)
   IF (size(itemdatatype,1) < 1)
    SET itemdatatype = "ItemData"
   ENDIF
   SET auditrecordid_encode = encode_value(reply->subject_data[subject_data_idx].study_event_data[
    study_event_data_idx].form_data[form_data_idx].item_group_data[item_group_data_idx].item_data[
    item_data_idx].audit_record_id)
   IF (textlen(auditrecordid_encode) > 0)
    SET auditrecordid = concat(' AuditRecordID="',auditrecordid_encode,'" ')
   ENDIF
   SET measurementunitid_encode = encode_value(reply->subject_data[subject_data_idx].
    study_event_data[study_event_data_idx].form_data[form_data_idx].item_group_data[
    item_group_data_idx].item_data[item_data_idx].measurement_unit_oid)
   IF (textlen(measurementunitid_encode) > 0)
    SET measurementunitid = concat(' MeasurementUnitOID="',measurementunitid_encode,'" ')
   ENDIF
   SET itemoid_encode = encode_value(reply->subject_data[subject_data_idx].study_event_data[
    study_event_data_idx].form_data[form_data_idx].item_group_data[item_group_data_idx].item_data[
    item_data_idx].item_oid)
   CALL add_line(concat("<",itemdatatype,auditrecordid,measurementunitid,' ItemOID="',
     itemoid_encode,'">'))
   SET newvalue = encode_value(reply->subject_data[subject_data_idx].study_event_data[
    study_event_data_idx].form_data[form_data_idx].item_group_data[item_group_data_idx].item_data[
    item_data_idx].value)
   CALL add_line(trim(newvalue))
   CALL add_line(concat("</",trim(itemdatatype),">"))
 END ;Subroutine
 SUBROUTINE start_item_group_data(subject_data_idx,study_event_data_idx,form_data_idx,
  item_group_data_idx)
   DECLARE itemgroupkeystr = vc WITH protect, noconstant(" ")
   DECLARE itemgroupkeystr_encode = vc WITH protect, noconstant(" ")
   DECLARE itemgroupoid_encode = vc WITH protect, noconstant(" ")
   SET itemgroupkeystr_encode = encode_value(reply->subject_data[subject_data_idx].study_event_data[
    study_event_data_idx].form_data[form_data_idx].item_group_data[item_group_data_idx].
    item_group_repeat_key)
   IF (size(itemgroupkeystr_encode,1) > 0)
    SET itemgroupkeystr = concat('" ItemGroupRepeatKey="',itemgroupkeystr_encode)
   ELSE
    SET itemgroupkeystr = ""
   ENDIF
   SET itemgroupoid_encode = encode_value(reply->subject_data[subject_data_idx].study_event_data[
    study_event_data_idx].form_data[form_data_idx].item_group_data[item_group_data_idx].
    item_group_oid)
   CALL add_line(concat('<ItemGroupData ItemGroupOID="',itemgroupoid_encode,trim(itemgroupkeystr),
     '">'))
 END ;Subroutine
 SUBROUTINE end_item_group_data(dummy)
   CALL add_line("</ItemGroupData>")
 END ;Subroutine
 SUBROUTINE start_audit_record(subject_data_idx,study_event_data_idx)
   DECLARE performed_by = vc WITH protect, noconstant(" ")
   DECLARE location_encode = vc WITH protect, noconstant(" ")
   SET performed_by = encode_value(reply->subject_data[subject_data_idx].study_event_data[
    study_event_data_idx].audit_user_oid)
   SET location_encode = encode_value(reply->subject_data[subject_data_idx].study_event_data[
    study_event_data_idx].audit_location_oid)
   CALL add_line("<AuditRecord>")
   CALL add_line(concat('<UserRef UserOID="',performed_by,'"/>'))
   CALL add_line(concat('<LocationRef LocationOID="',location_encode,'"/>'))
 END ;Subroutine
 SUBROUTINE start_item_audit_record(subject_data_idx,study_event_data_idx,form_data_idx,
  item_group_data_idx,item_data_idx)
   DECLARE audit_rec_id = vc WITH protect, noconstant(" ")
   SET audit_rec_id = encode_value(reply->subject_data[subject_data_idx].study_event_data[
    study_event_data_idx].form_data[form_data_idx].item_group_data[item_group_data_idx].item_data[
    item_data_idx].audit_record_id)
   DECLARE performed_by = vc WITH protect, noconstant(" ")
   SET performed_by = encode_value(reply->subject_data[subject_data_idx].study_event_data[
    study_event_data_idx].form_data[form_data_idx].item_group_data[item_group_data_idx].item_data[
    item_data_idx].audit_performed_by)
   DECLARE performed_dtm = vc WITH protect, noconstant(" ")
   SET performed_dtm = encode_value(reply->subject_data[subject_data_idx].study_event_data[
    study_event_data_idx].form_data[form_data_idx].item_group_data[item_group_data_idx].item_data[
    item_data_idx].audit_performed_timestamp)
   IF (textlen(audit_rec_id) > 0)
    CALL add_line(concat('<AuditRecord ID="',audit_rec_id,'">'))
    IF (textlen(performed_by) > 0)
     CALL add_line(concat('<UserRef UserOID="',performed_by,'"/>'))
    ENDIF
    IF (textlen(performed_dtm) > 0)
     CALL add_line(concat("<DateTimeStamp>",performed_dtm,"</DateTimeStamp>"))
    ENDIF
    CALL end_audit_record(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE end_audit_record(dummy)
   CALL add_line("</AuditRecord>")
 END ;Subroutine
 SUBROUTINE start_form_data(subject_data_idx,study_event_data_idx,form_data_idx)
   DECLARE formoid_encode = vc WITH protect, noconstant(" ")
   SET formoid_encode = encode_value(reply->subject_data[subject_data_idx].study_event_data[
    study_event_data_idx].form_data[form_data_idx].form_oid)
   CALL add_line(concat('<FormData FormOID="',formoid_encode,'">'))
 END ;Subroutine
 SUBROUTINE end_form_data(dummy)
   CALL add_line("</FormData>")
 END ;Subroutine
 SUBROUTINE start_study_event_data(subject_data_idx,study_event_data_idx)
   DECLARE studyeventoid_encode = vc WITH protect, noconstant(" ")
   SET studyeventoid_encode = encode_value(reply->subject_data[subject_data_idx].study_event_data[
    study_event_data_idx].study_event_oid)
   CALL add_line(concat('<StudyEventData StudyEventOID="',studyeventoid_encode,'">'))
 END ;Subroutine
 SUBROUTINE end_study_event_data(dummy)
   CALL add_line("</StudyEventData>")
 END ;Subroutine
 SUBROUTINE start_subject_data(subject_data_idx)
   DECLARE enrollid_encode = vc WITH protect, noconstant(" ")
   SET enrollid_encode = encode_value(request->person[subject_data_idx].enroll_ident)
   CALL add_line(concat('<SubjectData SubjectKey="',enrollid_encode,'">'))
 END ;Subroutine
 SUBROUTINE end_subject_data(dummy)
   CALL add_line("</SubjectData>")
 END ;Subroutine
 SUBROUTINE start_clinical_data(dummy)
   DECLARE studyid_encode = vc WITH protect, noconstant(" ")
   SET studyid_encode = encode_value(request->study_ident)
   CALL add_line(concat('<ClinicalData StudyOID="',studyid_encode,'" MetaDataVersionOID="001">'))
 END ;Subroutine
 SUBROUTINE end_clinical_data(dummy)
   CALL add_line("</ClinicalData>")
 END ;Subroutine
 SUBROUTINE start_odm(dummy)
   CALL add_line('<ODM xmlns="http://www.cdisc.org/ns/odm/v1.3"')
   CALL add_line(
    ' xmlns:ds="http://www.w3.org/2000/09/xmldsig#" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"'
    )
   CALL add_line(
    ' xsi:schemaLocation="http://www.cdisc.org/ns/odm/v1.3 ODM1-3-0.xsd" ODMVersion="1.3" FileOID="000-00-0000"'
    )
   CALL add_line(concat(' FileType="Snapshot" Description="CDASH Form" AsOfDateTime="',
     format_script_dt_tm,'"'))
   CALL add_line(concat(' CreationDateTime="',format_script_dt_tm,'"'))
   CALL add_line(">")
 END ;Subroutine
 SUBROUTINE end_odm(dummy)
   CALL add_line("</ODM>")
 END ;Subroutine
 SUBROUTINE start_audit_records(dummy)
   CALL add_line("<AuditRecords>")
 END ;Subroutine
 SUBROUTINE end_audit_records(dummy)
   CALL add_line("</AuditRecords>")
 END ;Subroutine
 SUBROUTINE add_line(line)
   SET drec->line_cnt = (drec->line_cnt+ 1)
   SET stat = alterlist(drec->line_qual,drec->line_cnt)
   SET drec->line_qual[drec->line_cnt].disp_line = line
 END ;Subroutine
 SUBROUTINE start_item_group_audit_record(subject_data_idx,study_event_data_idx,form_data_idx,
  item_group_data_idx)
   DECLARE performed_by = vc WITH protect, noconstant(" ")
   DECLARE timestamp_encode = vc WITH protect, noconstant(" ")
   SET performed_by = encode_value(reply->subject_data[subject_data_idx].study_event_data[
    study_event_data_idx].form_data[form_data_idx].item_group_data[item_group_data_idx].
    audit_performed_by)
   CALL add_line("<AuditRecord>")
   CALL add_line(concat('<UserRef UserOID="',performed_by,'"/>'))
   SET timestamp_encode = encode_value(reply->subject_data[subject_data_idx].study_event_data[
    study_event_data_idx].form_data[form_data_idx].item_group_data[item_group_data_idx].
    audit_performed_timestamp)
   CALL add_line(concat("<DateTimeStamp>",timestamp_encode,"</DateTimeStamp>"))
 END ;Subroutine
#exit_script
 FOR (lidx = 1 TO drec->line_cnt)
   SET reply->text = concat(reply->text,drec->line_qual[lidx].disp_line)
 ENDFOR
#exit_script_text_comp
 IF (failed != "S")
  SET reply->status_data.status = failed
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echo(reply->text)
 SET last_mod = "007"
 SET mod_date = "March 11, 2014"
END GO
