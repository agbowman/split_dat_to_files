CREATE PROGRAM aps_get_case_synoptic_ws:dba
 RECORD reply(
   1 ws_qual[*]
     2 case_worksheet_id = f8
     2 case_specimen_id = f8
     2 specimen_tag_id = f8
     2 specimen_tag_disp = c10
     2 specimen_tag_seq = i2
     2 sequence = i2
     2 scr_pattern_id = f8
     2 scr_pattern_disp = c40
     2 scd_story_id = f8
     2 task_assay_cd = f8
     2 report_id = f8
     2 report_disp = c40
     2 status_flag = i2
     2 updt_cnt = i4
     2 updt_id = f8
     2 updt_id_disp = vc
     2 updt_dt_tm = dq8
     2 pattern_description = vc
     2 pattern_cki_source = vc
     2 pattern_cki_identifier = vc
     2 foreign_ws_ident = vc
     2 foreign_ws_result_text = gvc
     2 pattern_active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE subevent_add(op_name=vc(value),op_status=vc(value),obj_name=vc(value),obj_value=vc(value))
  = null WITH protect
 SUBROUTINE subevent_add(op_name,op_status,obj_name,obj_value)
   DECLARE se_itm = i4 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET se_itm = size(reply->status_data.subeventstatus,5)
   SET stat = alter(reply->status_data.subeventstatus,(se_itm+ 1))
   SET reply->status_data.subeventstatus[se_itm].operationname = cnvtupper(substring(1,25,trim(
      op_name)))
   SET reply->status_data.subeventstatus[se_itm].operationstatus = cnvtupper(substring(1,1,trim(
      op_status)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectname = cnvtupper(substring(1,25,trim(
      obj_name)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectvalue = obj_value
 END ;Subroutine
 DECLARE nwscount = i4 WITH protect, noconstant(0)
 DECLARE textlen = i4 WITH protect, noconstant(0)
 DECLARE outbuf = vc WITH protect, noconstant(" ")
 DECLARE totlen = i4 WITH protect, noconstant(0)
 DECLARE ap_entry_mode_cd = f8 WITH constant(uar_get_code_by("MEANING",29520,"APSYNOPTIC"))
#script
 SET reply->status_data.status = "F"
 IF ((request->case_id > 0))
  SELECT INTO "nl:"
   ws.*
   FROM ap_case_synoptic_ws ws,
    case_report rep,
    scr_pattern scr,
    prsnl pr,
    ap_tag at,
    case_specimen cs,
    service_directory sd,
    long_text lt
   PLAN (rep
    WHERE (rep.case_id=request->case_id))
    JOIN (ws
    WHERE ws.report_id=rep.report_id)
    JOIN (scr
    WHERE scr.scr_pattern_id=ws.scr_pattern_id)
    JOIN (pr
    WHERE pr.person_id=ws.updt_id)
    JOIN (cs
    WHERE cs.case_specimen_id=ws.case_specimen_id)
    JOIN (at
    WHERE at.tag_id=cs.specimen_tag_id)
    JOIN (sd
    WHERE sd.catalog_cd=rep.catalog_cd)
    JOIN (lt
    WHERE lt.long_text_id > outerjoin(0)
     AND lt.long_text_id=outerjoin(ws.foreign_ws_result_text_id))
   ORDER BY at.tag_sequence, ws.sequence
   DETAIL
    nwscount = (nwscount+ 1)
    IF (mod(nwscount,10)=1)
     stat = alterlist(reply->ws_qual,(nwscount+ 9))
    ENDIF
    reply->ws_qual[nwscount].case_worksheet_id = ws.case_worksheet_id, reply->ws_qual[nwscount].
    case_specimen_id = ws.case_specimen_id, reply->ws_qual[nwscount].specimen_tag_id = cs
    .specimen_tag_id,
    reply->ws_qual[nwscount].specimen_tag_disp = at.tag_disp, reply->ws_qual[nwscount].
    specimen_tag_seq = at.tag_sequence, reply->ws_qual[nwscount].sequence = ws.sequence,
    reply->ws_qual[nwscount].scr_pattern_id = ws.scr_pattern_id, reply->ws_qual[nwscount].
    scr_pattern_disp = scr.display, reply->ws_qual[nwscount].scd_story_id = ws.scd_story_id,
    reply->ws_qual[nwscount].task_assay_cd = ws.task_assay_cd, reply->ws_qual[nwscount].report_id =
    ws.report_id
    IF (rep.report_sequence > 0)
     reply->ws_qual[nwscount].report_disp = concat(sd.short_description," ",cnvtstring((rep
       .report_sequence+ 1)))
    ELSE
     reply->ws_qual[nwscount].report_disp = sd.short_description
    ENDIF
    reply->ws_qual[nwscount].status_flag = ws.status_flag, reply->ws_qual[nwscount].updt_cnt = ws
    .updt_cnt, reply->ws_qual[nwscount].updt_id = ws.updt_id,
    reply->ws_qual[nwscount].updt_id_disp = pr.name_full_formatted, reply->ws_qual[nwscount].
    updt_dt_tm = ws.updt_dt_tm, reply->ws_qual[nwscount].pattern_description = scr.definition,
    reply->ws_qual[nwscount].pattern_cki_source = scr.cki_source, reply->ws_qual[nwscount].
    pattern_cki_identifier = scr.cki_identifier, reply->ws_qual[nwscount].pattern_active_ind = scr
    .active_ind,
    reply->ws_qual[nwscount].foreign_ws_ident = ws.foreign_ws_ident, reply->ws_qual[nwscount].
    foreign_ws_result_text = null
    IF (lt.long_text_id > 0)
     textlen = blobgetlen(lt.long_text), stat = memrealloc(outbuf,1,build("C",textlen)), totlen =
     blobget(outbuf,0,lt.long_text),
     reply->ws_qual[nwscount].foreign_ws_result_text = notrim(outbuf)
    ENDIF
   FOOT REPORT
    stat = alterlist(reply->ws_qual,nwscount)
   WITH nocounter
  ;end select
 ENDIF
 IF (nwscount=0)
  CALL subevent_add("SELECT","F","TABLE","AP_CASE_SYNOPTIC_WS")
  SET reply->status_data.status = "Z"
 ELSE
  SELECT INTO "nl:"
   scr.scr_pattern_id
   FROM (dummyt d  WITH seq = value(nwscount)),
    scr_pattern scr
   PLAN (d
    WHERE (reply->ws_qual[d.seq].pattern_cki_source="CAP_ECC_F")
     AND (reply->ws_qual[d.seq].pattern_active_ind=0)
     AND (((reply->ws_qual[d.seq].foreign_ws_ident=null)) OR (size(trim(reply->ws_qual[d.seq].
      foreign_ws_ident,1),1)=0)) )
    JOIN (scr
    WHERE (scr.cki_source=reply->ws_qual[d.seq].pattern_cki_source)
     AND (scr.definition=reply->ws_qual[d.seq].pattern_description)
     AND scr.active_ind=1
     AND scr.entry_mode_cd=ap_entry_mode_cd)
   ORDER BY d.seq, scr.updt_dt_tm DESC
   DETAIL
    reply->ws_qual[d.seq].scr_pattern_id = scr.scr_pattern_id, reply->ws_qual[d.seq].scr_pattern_disp
     = scr.display, reply->ws_qual[d.seq].pattern_description = scr.definition,
    reply->ws_qual[d.seq].pattern_cki_source = scr.cki_source, reply->ws_qual[d.seq].
    pattern_cki_identifier = scr.cki_identifier, reply->ws_qual[d.seq].pattern_active_ind = scr
    .active_ind
   WITH nocounter
  ;end select
  SET reply->status_data.status = "S"
 ENDIF
END GO
