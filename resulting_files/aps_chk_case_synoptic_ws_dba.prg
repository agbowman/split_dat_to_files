CREATE PROGRAM aps_chk_case_synoptic_ws:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD def_worksheet_req(
   1 specimen_cd = f8
   1 prefix_id = f8
   1 catalog_cd = f8
   1 default_only_flag = i2
 )
 IF ((validate(def_worksheet_rep->curqual,- (99))=- (99)))
  RECORD def_worksheet_rep(
    1 ws_qual[*]
      2 scr_pattern_id = f8
      2 scr_pattern_disp = c40
      2 task_assay_cd = f8
      2 sequence = i2
      2 pattern_description = vc
      2 pattern_cki_source = vc
      2 pattern_cki_identifier = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD all_worksheet_req(
   1 specimen_cd = f8
   1 prefix_id = f8
   1 catalog_cd = f8
   1 default_only_flag = i2
 )
 IF ((validate(all_worksheet_rep->curqual,- (99))=- (99)))
  RECORD all_worksheet_rep(
    1 ws_qual[*]
      2 scr_pattern_id = f8
      2 scr_pattern_disp = c40
      2 task_assay_cd = f8
      2 sequence = i2
      2 pattern_description = vc
      2 pattern_cki_source = vc
      2 pattern_cki_identifier = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD chg_worksheet_req(
   1 ins_qual[*]
     2 case_specimen_id = f8
     2 sequence = i4
     2 scr_pattern_id = f8
     2 scd_story_id = f8
     2 task_assay_cd = f8
     2 report_id = f8
     2 status_flag = i2
     2 entity_key = i4
     2 foreign_ws_ident = vc
     2 foreign_ws_result_text = gvc
     2 foreign_ws_data[*]
       3 question_concept_cki = vc
       3 answer_concept_cki = vc
       3 answer_value = gvc
       3 answer_unit = vc
       3 answer_text_format_cd = f8
       3 answer_type_flag = i2
       3 fields[*]
         4 field_name = vc
         4 type_flag = i2
         4 field_value_num = i4
         4 field_value_dbl = f8
         4 field_value_str = gvc
   1 upd_qual[*]
     2 case_worksheet_id = f8
     2 case_specimen_id = f8
     2 sequence = i4
     2 scr_pattern_id = f8
     2 scd_story_id = f8
     2 task_assay_cd = f8
     2 report_id = f8
     2 status_flag = i2
     2 updt_cnt = i4
     2 entity_key = i4
     2 foreign_ws_ident = vc
     2 foreign_ws_result_text = gvc
     2 foreign_ws_data[*]
       3 question_concept_cki = vc
       3 answer_concept_cki = vc
       3 answer_value = gvc
       3 answer_unit = vc
       3 answer_text_format_cd = f8
       3 answer_type_flag = i2
       3 fields[*]
         4 field_name = vc
         4 type_flag = i2
         4 field_value_num = i4
         4 field_value_dbl = f8
         4 field_value_str = gvc
   1 del_qual[*]
     2 case_worksheet_id = f8
   1 report_stale_ind = i2
   1 report_stale_dt_tm = dq8
   1 process_foreign_ws_ind = i2
 )
 IF ((validate(chg_worksheet_rep->curqual,- (99))=- (99)))
  RECORD chg_worksheet_rep(
    1 ws_qual[*]
      2 entity_key = i4
      2 case_worksheet_id = f8
      2 updt_cnt = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD tmp_syn_cur(
   1 qual[*]
     2 case_worksheet_id = f8
     2 sequence = i4
     2 scr_pattern_id = f8
     2 scd_story_id = f8
     2 task_assay_cd = f8
     2 report_id = f8
     2 status_flag = i2
     2 updt_cnt = i4
     2 foreign_ws_ident = vc
     2 foreign_ws_result_text = gvc
     2 orig_scr_pattern_id = f8
     2 pattern_cki_source = vc
     2 pattern_active_ind = i2
     2 pattern_description = vc
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
 DECLARE nspeccount = i4 WITH protect, noconstant(0)
 DECLARE dreportid = f8 WITH protect, noconstant(0.0)
 DECLARE nitem = i4 WITH protect, noconstant(0)
 DECLARE ninscount = i4 WITH protect, noconstant(0)
 DECLARE nupdcount = i4 WITH protect, noconstant(0)
 DECLARE ndelcount = i4 WITH protect, noconstant(0)
 DECLARE ndefwscount = i4 WITH protect, noconstant(0)
 DECLARE nallwscount = i4 WITH protect, noconstant(0)
 DECLARE nwsindex = i4 WITH protect, noconstant(0)
 DECLARE nwscurrentcount = i4 WITH protect, noconstant(0)
 DECLARE nlocator = i4 WITH protect, noconstant(0)
 DECLARE synoptic_enabled_ind = i2 WITH noconstant(0)
 DECLARE textlen = i4 WITH protect, noconstant(0)
 DECLARE outbuf = vc WITH protect, noconstant(" ")
 DECLARE totlen = i4 WITH protect, noconstant(0)
 DECLARE ap_entry_mode_cd = f8 WITH constant(uar_get_code_by("MEANING",29520,"APSYNOPTIC"))
#script
 SET reply->status_data.status = "S"
 SELECT INTO "nl:"
  FROM dm_info di
  PLAN (di
   WHERE di.info_domain="ANATOMIC PATHOLOGY"
    AND di.info_name="SYNOPTIC REPORTING")
  DETAIL
   synoptic_enabled_ind = di.info_number
  WITH nocounter
 ;end select
 IF (synoptic_enabled_ind=0)
  GO TO exit_script
 ENDIF
 SET chg_worksheet_req->report_stale_ind = 0
 SET nspeccount = size(request->spec_qual,5)
 FOR (nitem = 1 TO nspeccount)
  IF ((request->spec_qual[nitem].delete_flag=0))
   SET stat = alterlist(tmp_syn_cur->qual,0)
   SET nwscurrentcount = 0
   SELECT INTO "nl:"
    ap.*
    FROM ap_case_synoptic_ws ap,
     long_text lt,
     scr_pattern scr
    PLAN (ap
     WHERE (ap.case_specimen_id=request->spec_qual[nitem].case_specimen_id))
     JOIN (scr
     WHERE scr.scr_pattern_id > outerjoin(0)
      AND scr.scr_pattern_id=outerjoin(ap.scr_pattern_id))
     JOIN (lt
     WHERE lt.long_text_id > outerjoin(0)
      AND lt.long_text_id=outerjoin(ap.foreign_ws_result_text_id))
    DETAIL
     nwscurrentcount = (nwscurrentcount+ 1), stat = alterlist(tmp_syn_cur->qual,nwscurrentcount),
     tmp_syn_cur->qual[nwscurrentcount].case_worksheet_id = ap.case_worksheet_id,
     tmp_syn_cur->qual[nwscurrentcount].sequence = ap.sequence, tmp_syn_cur->qual[nwscurrentcount].
     scr_pattern_id = ap.scr_pattern_id, tmp_syn_cur->qual[nwscurrentcount].orig_scr_pattern_id = ap
     .scr_pattern_id,
     tmp_syn_cur->qual[nwscurrentcount].scd_story_id = ap.scd_story_id, tmp_syn_cur->qual[
     nwscurrentcount].task_assay_cd = ap.task_assay_cd, tmp_syn_cur->qual[nwscurrentcount].report_id
      = ap.report_id,
     tmp_syn_cur->qual[nwscurrentcount].status_flag = ap.status_flag, tmp_syn_cur->qual[
     nwscurrentcount].updt_cnt = ap.updt_cnt, tmp_syn_cur->qual[nwscurrentcount].foreign_ws_ident =
     ap.foreign_ws_ident,
     tmp_syn_cur->qual[nwscurrentcount].pattern_cki_source = scr.cki_source, tmp_syn_cur->qual[
     nwscurrentcount].pattern_active_ind = scr.active_ind, tmp_syn_cur->qual[nwscurrentcount].
     pattern_description = scr.definition
     IF (lt.long_text_id > 0)
      textlen = blobgetlen(lt.long_text), stat = memrealloc(outbuf,1,build("C",textlen)), totlen =
      blobget(outbuf,0,lt.long_text),
      tmp_syn_cur->qual[nwscurrentcount].foreign_ws_result_text = notrim(outbuf)
     ENDIF
    WITH nocounter
   ;end select
   IF (nwscurrentcount > 0)
    SELECT INTO "nl:"
     scr.scr_pattern_id
     FROM (dummyt d  WITH seq = value(nwscurrentcount)),
      scr_pattern scr
     PLAN (d
      WHERE (tmp_syn_cur->qual[d.seq].pattern_cki_source="CAP_ECC_F")
       AND (tmp_syn_cur->qual[d.seq].pattern_active_ind=0))
      JOIN (scr
      WHERE (scr.cki_source=tmp_syn_cur->qual[d.seq].pattern_cki_source)
       AND (scr.definition=tmp_syn_cur->qual[d.seq].pattern_description)
       AND scr.active_ind=1
       AND scr.entry_mode_cd=ap_entry_mode_cd)
     ORDER BY d.seq, scr.updt_dt_tm DESC
     DETAIL
      tmp_syn_cur->qual[d.seq].scr_pattern_id = scr.scr_pattern_id
     WITH nocounter
    ;end select
   ENDIF
   SELECT INTO "nl:"
    cs.*
    FROM pathology_case pc,
     case_report cr,
     prefix_report_r pr,
     case_specimen cs
    PLAN (cs
     WHERE (request->spec_qual[nitem].case_specimen_id=cs.case_specimen_id))
     JOIN (pc
     WHERE pc.case_id=cs.case_id)
     JOIN (cr
     WHERE cr.case_id=cs.case_id)
     JOIN (pr
     WHERE pr.prefix_id=pc.prefix_id
      AND pr.catalog_cd=cr.catalog_cd
      AND pr.primary_ind=1)
    DETAIL
     def_worksheet_req->specimen_cd = cs.specimen_cd, def_worksheet_req->prefix_id = pc.prefix_id,
     def_worksheet_req->catalog_cd = cr.catalog_cd,
     def_worksheet_req->default_only_flag = 1, all_worksheet_req->specimen_cd = cs.specimen_cd,
     all_worksheet_req->prefix_id = pc.prefix_id,
     all_worksheet_req->catalog_cd = cr.catalog_cd, all_worksheet_req->default_only_flag = 0,
     dreportid = cr.report_id
    WITH nocounter
   ;end select
   SET stat = alterlist(def_worksheet_rep->ws_qual,0)
   EXECUTE aps_get_synoptic_allowed_ws  WITH replace("REQUEST","DEF_WORKSHEET_REQ"), replace("REPLY",
    "DEF_WORKSHEET_REP")
   IF ((def_worksheet_rep->status_data.status="F"))
    CALL subevent_add("EXEC","F","SCRIPT","APS_GET_SYNOPTIC_ALLOWED")
    SET reply->status_data.status = "F"
    GO TO exit_script
   ENDIF
   SET ndefwscount = size(def_worksheet_rep->ws_qual,5)
   IF (nwscurrentcount > 0)
    SET stat = alterlist(all_worksheet_rep->ws_qual,0)
    EXECUTE aps_get_synoptic_allowed_ws  WITH replace("REQUEST","ALL_WORKSHEET_REQ"), replace("REPLY",
     "ALL_WORKSHEET_REP")
    IF ((all_worksheet_rep->status_data.status="F"))
     CALL subevent_add("EXEC","F","SCRIPT","APS_GET_SYNOPTIC_ALLOWED")
     SET reply->status_data.status = "F"
     GO TO exit_script
    ENDIF
    SET nallwscount = size(all_worksheet_rep->ws_qual,5)
    FOR (nwsindex = 1 TO nwscurrentcount)
      IF ((tmp_syn_cur->qual[nwsindex].scd_story_id=0)
       AND size(trim(tmp_syn_cur->qual[nwsindex].foreign_ws_ident,1),1)=0)
       IF (locateval(nlocator,1,ndefwscount,tmp_syn_cur->qual[nwsindex].scr_pattern_id,
        def_worksheet_rep->ws_qual[nlocator].scr_pattern_id)=0)
        SET ndelcount = (ndelcount+ 1)
        SET stat = alterlist(chg_worksheet_req->del_qual,ndelcount)
        SET chg_worksheet_req->del_qual[ndelcount].case_worksheet_id = tmp_syn_cur->qual[nwsindex].
        case_worksheet_id
       ENDIF
      ELSE
       IF (locateval(nlocator,1,nallwscount,tmp_syn_cur->qual[nwsindex].scr_pattern_id,
        all_worksheet_rep->ws_qual[nlocator].scr_pattern_id)=0)
        SET nupdcount = (nupdcount+ 1)
        SET stat = alterlist(chg_worksheet_req->upd_qual,nupdcount)
        SET chg_worksheet_req->upd_qual[nupdcount].case_worksheet_id = tmp_syn_cur->qual[nwsindex].
        case_worksheet_id
        SET chg_worksheet_req->upd_qual[nupdcount].case_specimen_id = 0
        SET chg_worksheet_req->upd_qual[nupdcount].sequence = tmp_syn_cur->qual[nwsindex].sequence
        SET chg_worksheet_req->upd_qual[nupdcount].scr_pattern_id = tmp_syn_cur->qual[nwsindex].
        orig_scr_pattern_id
        SET chg_worksheet_req->upd_qual[nupdcount].scd_story_id = tmp_syn_cur->qual[nwsindex].
        scd_story_id
        SET chg_worksheet_req->upd_qual[nupdcount].task_assay_cd = tmp_syn_cur->qual[nwsindex].
        task_assay_cd
        SET chg_worksheet_req->upd_qual[nupdcount].report_id = tmp_syn_cur->qual[nwsindex].report_id
        SET chg_worksheet_req->upd_qual[nupdcount].status_flag = 3
        SET chg_worksheet_req->upd_qual[nupdcount].updt_cnt = tmp_syn_cur->qual[nwsindex].updt_cnt
        SET chg_worksheet_req->upd_qual[nupdcount].foreign_ws_ident = tmp_syn_cur->qual[nwsindex].
        foreign_ws_ident
        SET chg_worksheet_req->upd_qual[nupdcount].foreign_ws_result_text = tmp_syn_cur->qual[
        nwsindex].foreign_ws_result_text
        IF ((tmp_syn_cur->qual[nwsindex].status_flag=2))
         SET chg_worksheet_req->report_stale_ind = 1
         SET chg_worksheet_req->report_stale_dt_tm = cnvtdatetime(curdate,curtime3)
        ENDIF
       ENDIF
      ENDIF
    ENDFOR
    FOR (nwsindex = 1 TO ndefwscount)
      IF (locateval(nlocator,1,nwscurrentcount,def_worksheet_rep->ws_qual[nwsindex].scr_pattern_id,
       tmp_syn_cur->qual[nlocator].scr_pattern_id)=0)
       SET ninscount = (ninscount+ 1)
       SET stat = alterlist(chg_worksheet_req->ins_qual,ninscount)
       SET chg_worksheet_req->ins_qual[ninscount].case_specimen_id = request->spec_qual[nitem].
       case_specimen_id
       SET chg_worksheet_req->ins_qual[ninscount].sequence = def_worksheet_rep->ws_qual[nwsindex].
       sequence
       SET chg_worksheet_req->ins_qual[ninscount].scr_pattern_id = def_worksheet_rep->ws_qual[
       nwsindex].scr_pattern_id
       SET chg_worksheet_req->ins_qual[ninscount].scd_story_id = 0
       SET chg_worksheet_req->ins_qual[ninscount].task_assay_cd = def_worksheet_rep->ws_qual[nwsindex
       ].task_assay_cd
       SET chg_worksheet_req->ins_qual[ninscount].report_id = dreportid
       SET chg_worksheet_req->ins_qual[ninscount].status_flag = 0
      ENDIF
    ENDFOR
   ELSE
    IF (ndefwscount > 0)
     SELECT INTO "nl:"
      d.seq
      FROM (dummyt d  WITH seq = size(def_worksheet_rep->ws_qual,5))
      PLAN (d)
      DETAIL
       ninscount = (ninscount+ 1), stat = alterlist(chg_worksheet_req->ins_qual,ninscount),
       chg_worksheet_req->ins_qual[ninscount].case_specimen_id = request->spec_qual[nitem].
       case_specimen_id,
       chg_worksheet_req->ins_qual[ninscount].sequence = def_worksheet_rep->ws_qual[d.seq].sequence,
       chg_worksheet_req->ins_qual[ninscount].scr_pattern_id = def_worksheet_rep->ws_qual[d.seq].
       scr_pattern_id, chg_worksheet_req->ins_qual[ninscount].scd_story_id = 0,
       chg_worksheet_req->ins_qual[ninscount].task_assay_cd = def_worksheet_rep->ws_qual[d.seq].
       task_assay_cd, chg_worksheet_req->ins_qual[ninscount].report_id = dreportid, chg_worksheet_req
       ->ins_qual[ninscount].status_flag = 0
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
  ENDIF
  IF ((request->spec_qual[nitem].delete_flag=1))
   SELECT INTO "nl:"
    ap.*
    FROM ap_case_synoptic_ws ap,
     long_text lt
    PLAN (ap
     WHERE (ap.case_specimen_id=request->spec_qual[nitem].case_specimen_id))
     JOIN (lt
     WHERE lt.long_text_id > outerjoin(0)
      AND lt.long_text_id=outerjoin(ap.foreign_ws_result_text_id))
    DETAIL
     IF (ap.scd_story_id=0
      AND size(trim(ap.foreign_ws_ident,1),1)=0)
      ndelcount = (ndelcount+ 1), stat = alterlist(chg_worksheet_req->del_qual,ndelcount),
      chg_worksheet_req->del_qual[ndelcount].case_worksheet_id = ap.case_worksheet_id
     ELSE
      nupdcount = (nupdcount+ 1), stat = alterlist(chg_worksheet_req->upd_qual,nupdcount),
      chg_worksheet_req->upd_qual[nupdcount].case_worksheet_id = ap.case_worksheet_id,
      chg_worksheet_req->upd_qual[nupdcount].case_specimen_id = 0, chg_worksheet_req->upd_qual[
      nupdcount].sequence = ap.sequence, chg_worksheet_req->upd_qual[nupdcount].scr_pattern_id = ap
      .scr_pattern_id,
      chg_worksheet_req->upd_qual[nupdcount].scd_story_id = ap.scd_story_id, chg_worksheet_req->
      upd_qual[nupdcount].task_assay_cd = ap.task_assay_cd, chg_worksheet_req->upd_qual[nupdcount].
      report_id = ap.report_id,
      chg_worksheet_req->upd_qual[nupdcount].status_flag = 3, chg_worksheet_req->upd_qual[nupdcount].
      updt_cnt = ap.updt_cnt, chg_worksheet_req->upd_qual[nupdcount].foreign_ws_ident = ap
      .foreign_ws_ident
      IF (lt.long_text_id > 0)
       textlen = blobgetlen(lt.long_text), stat = memrealloc(outbuf,1,build("C",textlen)), totlen =
       blobget(outbuf,0,lt.long_text),
       chg_worksheet_req->upd_qual[nupdcount].foreign_ws_result_text = notrim(outbuf)
      ENDIF
      IF (ap.status_flag=2)
       chg_worksheet_req->report_stale_ind = 1, chg_worksheet_req->report_stale_dt_tm = cnvtdatetime(
        curdate,curtime3)
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
 ENDFOR
 IF (((ninscount > 0) OR (((ndelcount > 0) OR (nupdcount > 0)) )) )
  EXECUTE aps_chg_case_synoptic_ws  WITH replace("REQUEST","CHG_WORKSHEET_REQ"), replace("REPLY",
   "CHG_WORKSHEET_REP")
  IF ((chg_worksheet_rep->status_data.status="F"))
   CALL subevent_add("CHANGE","F","TABLE","AP_CASE_SYNOPTIC_WS")
   SET reply->status_data.status = "F"
  ENDIF
 ENDIF
#exit_script
 CALL echorecord(request)
 CALL echorecord(tmp_syn_cur)
 CALL echorecord(def_worksheet_rep)
 CALL echorecord(all_worksheet_rep)
 CALL echorecord(chg_worksheet_req)
 CALL echorecord(chg_worksheet_rep)
 FREE RECORD tmp_syn_cur
 FREE RECORD def_worksheet_req
 FREE RECORD def_worksheet_rep
 FREE RECORD all_worksheet_req
 FREE RECORD all_worksheet_rep
 FREE RECORD chg_worksheet_req
 FREE RECORD chg_worksheet_rep
END GO
