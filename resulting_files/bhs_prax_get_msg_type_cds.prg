CREATE PROGRAM bhs_prax_get_msg_type_cds
 FREE RECORD result
 RECORD result(
   1 msg_types[*]
     2 event_cd = f8
     2 event_disp = vc
     2 default_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE RECORD result_seq
 RECORD result_seq(
   1 list[*]
     2 ref_idx = i4
 ) WITH protect
 DECLARE getmsgtypes(null) = i2
 DECLARE sortresults(null) = i2
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE locidx = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 SET result->status_data.status = "F"
 IF (textlen(trim( $2,3)) <= 0)
  CALL echo("INVALID MESSAGE TYPE PARAMETER...EXITING")
  GO TO exit_script
 ENDIF
 SET stat = getmsgtypes(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET stat = sortresults(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET result->status_data.status = "S"
#exit_script
 CALL echorecord(result)
 IF (size(trim(moutputdevice,3)) > 0)
  DECLARE v1 = vc WITH protect, noconstant("")
  DECLARE v2 = vc WITH protect, noconstant("")
  DECLARE v3 = vc WITH protect, noconstant("")
  IF ((result->status_data.status="S"))
   SELECT INTO value(moutputdevice)
    FROM dummyt d
    PLAN (d
     WHERE d.seq > 0)
    HEAD REPORT
     html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
      '"',"UTF-8",'"'," ?>"), col 0, html_tag,
     row + 1, col + 1, "<ReplyMessage>",
     row + 1, col + 1, "<MessageTypes>",
     row + 1
     FOR (idx = 1 TO size(result_seq->list,5))
       pos = result_seq->list[idx].ref_idx, col + 1, "<MessageType>",
       row + 1, v1 = build("<CodeValue>",cnvtint(result->msg_types[pos].event_cd),"</CodeValue>"),
       col + 1,
       v1, row + 1, v2 = build("<Display>",trim(replace(replace(replace(replace(replace(result->
              msg_types[pos].event_disp,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),
          '"',"&quot;",0),3),"</Display>"),
       col + 1, v2, row + 1,
       v3 = build("<DefaultInd>",result->msg_types[pos].default_ind,"</DefaultInd>"), col + 1, v3,
       row + 1, col + 1, "</MessageType>",
       row + 1
     ENDFOR
     col + 1, "</MessageTypes>", row + 1,
     col + 1, "</ReplyMessage>", row + 1
    WITH maxcol = 32000, nocounter, nullreport,
     formfeed = none, format = variable, time = 30
   ;end select
  ENDIF
 ENDIF
 FREE RECORD result
 FREE RECORD result_seq
 SUBROUTINE getmsgtypes(null)
   DECLARE c_phone_msg_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6026,"PHONE MSG"))
   DECLARE c_msg_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6026,trim( $2,3)))
   DECLARE tcnt = i4 WITH protect, noconstant(0)
   CALL echo(build("C_MSG_TYPE_CD: ",c_msg_type_cd," (",uar_get_code_display(c_msg_type_cd),")"))
   SELECT INTO "NL:"
    FROM message_type_template_reltn mttr,
     clinical_note_template cnt,
     note_type_template_reltn nttr,
     note_type nt,
     name_value_prefs nvp
    PLAN (mttr
     WHERE mttr.message_type_cd=c_msg_type_cd)
     JOIN (cnt
     WHERE cnt.template_id=mttr.template_id
      AND cnt.smart_template_ind < 2
      AND cnt.template_active_ind=1)
     JOIN (nttr
     WHERE nttr.template_id=cnt.template_id)
     JOIN (nt
     WHERE nt.note_type_id=nttr.note_type_id)
     JOIN (nvp
     WHERE nvp.pvc_value=outerjoin(trim(cnvtstring(nt.note_type_id),3))
      AND nvp.parent_entity_name=outerjoin("DETAIL_PREFS")
      AND nvp.active_ind > outerjoin(0)
      AND nvp.pvc_name=outerjoin("MSG_MSGPH_DEFDOCID"))
    HEAD nt.event_cd
     IF (((mttr.default_ind=1) OR (c_msg_type_cd != c_phone_msg_cd)) )
      tcnt = (tcnt+ 1), stat = alterlist(result->msg_types,tcnt), result->msg_types[tcnt].event_cd =
      nt.event_cd,
      result->msg_types[tcnt].event_disp = nt.note_type_description, result->msg_types[tcnt].
      default_ind = evaluate(nvp.name_value_prefs_id,0.0,0,1)
     ENDIF
    WITH nocounter, time = 30
   ;end select
   IF (c_msg_type_cd=c_phone_msg_cd)
    SELECT INTO "NL:"
     FROM detail_prefs dp,
      name_value_prefs nvp,
      note_type nt
     PLAN (dp
      WHERE dp.application_number=600005
       AND dp.view_name="PVINBOX"
       AND dp.comp_name="PVINBOX"
       AND dp.view_seq=0
       AND dp.comp_seq=0
       AND dp.active_ind > 0)
      JOIN (nvp
      WHERE nvp.parent_entity_id=dp.detail_prefs_id
       AND nvp.parent_entity_name="DETAIL_PREFS"
       AND nvp.active_ind > 0
       AND nvp.pvc_name IN ("MSG_MSGPH_DEFTEMPID", "MSG_CNSLT_DEFDOCID"))
      JOIN (nt
      WHERE nt.note_type_id=cnvtreal(nvp.pvc_value))
     HEAD nt.note_type_id
      pos = locateval(locidx,1,tcnt,nt.event_cd,result->msg_types[locidx].event_cd)
      IF (pos=0)
       tcnt = (tcnt+ 1), stat = alterlist(result->msg_types,tcnt), result->msg_types[tcnt].event_cd
        = nt.event_cd,
       result->msg_types[tcnt].event_disp = uar_get_code_display(nt.event_cd),
       CALL echo(build("NVP.PVC_NAME:",nvp.pvc_name))
       IF (nvp.pvc_name="MSG_MSGPH_DEFTEMPID")
        result->msg_types[tcnt].default_ind = 1
       ENDIF
      ELSE
       CALL echo(build("NVP.PVC_NAME:",nvp.pvc_name))
       IF (nvp.pvc_name="MSG_MSGPH_DEFTEMPID")
        result->msg_types[pos].default_ind = 1
       ENDIF
      ENDIF
     WITH nocounter, time = 30
    ;end select
    SELECT INTO "NL:"
     FROM detail_prefs dp,
      name_value_prefs nvp,
      note_type_template_reltn nttr,
      note_type nt
     PLAN (dp
      WHERE dp.application_number=600005
       AND dp.view_name="PVINBOX"
       AND dp.comp_name="PVINBOX"
       AND dp.view_seq=0
       AND dp.comp_seq=0
       AND dp.active_ind > 0)
      JOIN (nvp
      WHERE nvp.parent_entity_id=dp.detail_prefs_id
       AND nvp.parent_entity_name="DETAIL_PREFS"
       AND nvp.active_ind > 0
       AND nvp.pvc_name IN ("MSG_MSGPH_DEFTEMPID", "MSG_CNSLT_DEFDOCID"))
      JOIN (nttr
      WHERE nttr.template_id=cnvtreal(nvp.pvc_value))
      JOIN (nt
      WHERE nt.note_type_id=nttr.note_type_id)
     HEAD nt.note_type_id
      pos = locateval(locidx,1,tcnt,nt.event_cd,result->msg_types[locidx].event_cd)
      IF (pos=0)
       tcnt = (tcnt+ 1), stat = alterlist(result->msg_types,tcnt), result->msg_types[tcnt].event_cd
        = nt.event_cd,
       result->msg_types[tcnt].event_disp = uar_get_code_display(nt.event_cd),
       CALL echo(build("NVP.PVC_NAME:",nvp.pvc_name))
       IF (nvp.pvc_name="MSG_MSGPH_DEFTEMPID")
        result->msg_types[tcnt].default_ind = 1
       ENDIF
      ELSE
       CALL echo(build("NVP.PVC_NAME:",nvp.pvc_name))
       IF (nvp.pvc_name="MSG_MSGPH_DEFTEMPID")
        result->msg_types[pos].default_ind = 1
       ENDIF
      ENDIF
     WITH nocounter, time = 30
    ;end select
   ENDIF
   IF (tcnt=1)
    SET result->msg_types[1].default_ind = 1
   ENDIF
   RETURN(success)
 END ;Subroutine
 SUBROUTINE sortresults(null)
   DECLARE rcnt = i4 WITH protect, noconstant(0)
   IF (size(result->msg_types,5) > 0)
    SET stat = alterlist(result_seq->list,size(result->msg_types,5))
    SELECT INTO "NL:"
     sortkey = cnvtupper(result->msg_types[d.seq].event_disp)
     FROM (dummyt d  WITH seq = size(result->msg_types,5))
     PLAN (d
      WHERE d.seq > 0)
     ORDER BY sortkey
     DETAIL
      rcnt = (rcnt+ 1), result_seq->list[rcnt].ref_idx = d.seq
     WITH nocounter, time = 30
    ;end select
   ENDIF
   CALL echorecord(result_seq)
   RETURN(success)
 END ;Subroutine
END GO
