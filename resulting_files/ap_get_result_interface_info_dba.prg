CREATE PROGRAM ap_get_result_interface_info:dba
 IF ( NOT (validate(ap_reply,0)))
  RECORD ap_reply(
    1 qual[*]
      2 order_id = f8
      2 case_specimen_id = f8
      2 checklists[*]
        3 version_concept_cki = vc
        3 worksheets[*]
          4 scd_story_id = f8
          4 foreign_ws_ident = c50
          4 use_content_pkg = i2
        3 use_content_pkg_for_chklist = i2
        3 obx_qual[*]
          4 value_type = vc
          4 cki_type = vc
          4 cki_type_cs = vc
          4 cki_type_text = vc
          4 alt_cki_type = vc
          4 alt_cki_type_cs = vc
          4 alt_cki_type_text = vc
          4 cki = vc
          4 cki_cs = vc
          4 cki_text = vc
          4 alt_cki = vc
          4 alt_cki_cs = vc
          4 alt_cki_text = vc
    1 consult_case_ind = i2
    1 consult_identifier = c40
    1 report_type_cd = f8
    1 stories[*]
      2 scd_story_id = f8
      2 cki_source = c12
      2 cki_identifier = vc
      2 display = c40
      2 description = vc
      2 questions[*]
        3 question_concept_cki = vc
        3 answer_concept_cki = vc
        3 answer_value_text[*]
          4 text_blob = vgc
          4 sequence_number = i4
        3 answer_value_text_format_cd = f8
        3 answer_value_is_number = i2
        3 answer_unit_cd = f8
        3 answer_comment[*]
          4 text_blob = vgc
          4 sequence_number = i4
        3 question_text = vc
        3 question_coding_sys = vc
        3 answer_text = vc
        3 answer_coding_sys = vc
        3 alt_question_cki = vc
        3 alt_question_text = vc
        3 alt_question_coding_sys = vc
        3 alt_answer_cki = vc
        3 alt_answer_text = vc
        3 alt_answer_coding_sys = vc
        3 answer_unit_ident = vc
        3 answer_unit_text = vc
        3 answer_unit_coding_sys = vc
        3 answer_type_text = vc
        3 sub_answer_type_text = vc
        3 answer_sub_ident = vc
      2 foreign_ws_ident = c50
    1 requesting_physician_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD scd_request(
   1 stories[*]
     2 scd_story_id = f8
 )
 RECORD foreign_ws(
   1 qual[*]
     2 foreign_ws_ident = c50
     2 scr_pattern_id = f8
     2 case_worksheet_id = f8
 )
 DECLARE dcaseid = f8 WITH protect, noconstant(0.0)
 DECLARE dprefixid = f8 WITH protect, noconstant(0.0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE idx1 = i4 WITH protect, noconstant(0)
 DECLARE reply_size = i4 WITH protect, noconstant(0)
 DECLARE scd_synoptic_data_extract_exists = i2 WITH protect, noconstant(0)
 DECLARE chklstobxcnt = i4 WITH protect, noconstant(0)
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE foreignwscnt = i4 WITH protect, noconstant(0)
 DECLARE foreignwsidx = i4 WITH protect, noconstant(0)
 DECLARE apreplystoryidx = i4 WITH protect, noconstant(0)
 DECLARE apreplystoryquesidx = i4 WITH protect, noconstant(0)
 DECLARE apreplyanswertextidx = i4 WITH protect, noconstant(0)
 DECLARE eppatterntypecd = f8 WITH protect, noconstant(0.0)
 DECLARE asciiformatcd = f8 WITH protect, noconstant(0.0)
 DECLARE textlen = i4 WITH protect, noconstant(0)
 DECLARE outbuf = vc WITH protect, noconstant(" ")
 DECLARE totlen = i4 WITH protect, noconstant(0)
 DECLARE offset = i4 WITH protect, noconstant(0)
 DECLARE answertextchunksize = i4 WITH protect, constant(32000)
 DECLARE templateident = vc WITH protect, noconstant("")
 SET scd_synoptic_data_extract_exists = checkprg("SCD_SYNOPTIC_DATA_EXTRACT")
 SET ap_reply->status_data.status = "F"
 SELECT INTO "nl:"
  pt.order_id
  FROM pathology_case pc,
   processing_task pt,
   ap_tag apt
  PLAN (pc
   WHERE (ap_request->accession_nbr=pc.accession_nbr))
   JOIN (pt
   WHERE pc.case_id=pt.case_id
    AND pt.create_inventory_flag=4
    AND  NOT (pt.order_id IN (0, null))
    AND pt.cancel_cd=0)
   JOIN (apt
   WHERE pt.case_specimen_tag_id=apt.tag_id)
  ORDER BY apt.tag_sequence
  HEAD REPORT
   cnt = 0, dcaseid = pc.case_id, dprefixid = pc.prefix_id,
   stat = assign(validate(ap_reply->requesting_physician_id),pc.requesting_physician_id)
  DETAIL
   cnt += 1, stat = alterlist(ap_reply->qual,cnt), ap_reply->qual[cnt].order_id = pt.order_id,
   ap_reply->qual[cnt].case_specimen_id = pt.case_specimen_id
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET ap_reply->status_data.status = "S"
 ELSEIF (curqual=0)
  SET ap_reply->status_data.status = "Z"
 ELSE
  SET ap_reply->status_data.status = "F"
 ENDIF
 IF (validate(ap_request->report_event_id,- (99.00)) > 0)
  SELECT INTO "nl:"
   pr.report_type_cd
   FROM prefix_report_r pr,
    case_report cr
   PLAN (pr
    WHERE pr.prefix_id=dprefixid)
    JOIN (cr
    WHERE cr.catalog_cd=pr.catalog_cd
     AND (cr.event_id=ap_request->report_event_id))
   ORDER BY pr.prefix_id
   HEAD REPORT
    ap_reply->report_type_cd = pr.report_type_cd
   WITH nocounter
  ;end select
 ENDIF
 SET reply_size = size(ap_reply->qual,5)
 IF (validate(ap_request->synoptic_interest_flag,- (99))=1
  AND validate(ap_request->report_event_id,- (99.00)) > 0)
  SELECT INTO "nl:"
   ap.case_specimen_id, ap.sequence
   FROM ap_case_synoptic_ws ap,
    case_report cr,
    ap_case_synoptic_ws_data wd
   PLAN (ap
    WHERE expand(idx,1,reply_size,ap.case_specimen_id,ap_reply->qual[idx].case_specimen_id)
     AND ap.status_flag=2)
    JOIN (cr
    WHERE ap.report_id=cr.report_id
     AND (cr.event_id=ap_request->report_event_id))
    JOIN (wd
    WHERE (wd.case_worksheet_id= Outerjoin(ap.case_worksheet_id))
     AND (wd.question_concept_cki= Outerjoin("437728003"))
     AND (wd.question_coding_sys_ident= Outerjoin("SCT"))
     AND (wd.rec_type_flag> Outerjoin(0)) )
   ORDER BY ap.case_specimen_id, ap.sequence, ap.case_worksheet_id
   HEAD REPORT
    locidx = 0, cnt3 = 0, foreignwscnt = 0
   HEAD ap.case_specimen_id
    locidx = locateval(idx,1,reply_size,ap.case_specimen_id,ap_reply->qual[idx].case_specimen_id),
    cnt1 = 0
   DETAIL
    IF (size(trim(ap.foreign_ws_ident,1),1) > 0)
     IF (wd.ap_case_synoptic_ws_data_id > 0.0)
      templateident = wd.answer_concept_cki
     ENDIF
     IF (size(trim(templateident,1),1) <= 0)
      templateident = ap.cap_checklist_cki
     ENDIF
    ELSE
     templateident = ap.cap_checklist_cki
    ENDIF
   FOOT  ap.case_worksheet_id
    IF (size(trim(templateident,1),1) > 0)
     locidx1 = locateval(idx1,1,cnt1,templateident,ap_reply->qual[locidx].checklists[idx1].
      version_concept_cki)
     IF (locidx1 <= 0)
      cnt1 += 1, stat = alterlist(ap_reply->qual[locidx].checklists,cnt1), cnt2 = 0,
      ap_reply->qual[locidx].checklists[cnt1].version_concept_cki = templateident
     ENDIF
     cnt2 = size(ap_reply->qual[locidx].checklists[cnt1].worksheets,5), cnt2 += 1, stat = alterlist(
      ap_reply->qual[locidx].checklists[cnt1].worksheets,cnt2)
     IF (size(trim(ap.foreign_ws_ident,1),1) > 0)
      foreignwscnt += 1, stat = alterlist(foreign_ws->qual,foreignwscnt), foreign_ws->qual[
      foreignwscnt].foreign_ws_ident = ap.foreign_ws_ident,
      foreign_ws->qual[foreignwscnt].scr_pattern_id = ap.scr_pattern_id, foreign_ws->qual[
      foreignwscnt].case_worksheet_id = ap.case_worksheet_id, ap_reply->qual[locidx].checklists[cnt1]
      .worksheets[cnt2].foreign_ws_ident = ap.foreign_ws_ident
      IF (wd.ap_case_synoptic_ws_data_id > 0.0)
       chklstobxcnt = size(ap_reply->qual[locidx].checklists[cnt1].obx_qual,5)
       IF (chklstobxcnt < 1)
        chklstobxcnt += 1, stat = alterlist(ap_reply->qual[locidx].checklists[cnt1].obx_qual,
         chklstobxcnt), ap_reply->qual[locidx].checklists[cnt1].obx_qual[chklstobxcnt].value_type =
        wd.answer_type_txt,
        ap_reply->qual[locidx].checklists[cnt1].obx_qual[chklstobxcnt].cki_type = wd
        .question_concept_cki, ap_reply->qual[locidx].checklists[cnt1].obx_qual[chklstobxcnt].
        cki_type_cs = wd.question_coding_sys_ident, ap_reply->qual[locidx].checklists[cnt1].obx_qual[
        chklstobxcnt].cki_type_text = wd.question_txt,
        ap_reply->qual[locidx].checklists[cnt1].obx_qual[chklstobxcnt].alt_cki_type = wd
        .alt_question_cki, ap_reply->qual[locidx].checklists[cnt1].obx_qual[chklstobxcnt].
        alt_cki_type_cs = wd.alt_question_coding_sys_ident, ap_reply->qual[locidx].checklists[cnt1].
        obx_qual[chklstobxcnt].alt_cki_type_text = wd.alt_question_txt,
        ap_reply->qual[locidx].checklists[cnt1].obx_qual[chklstobxcnt].cki = wd.answer_concept_cki,
        ap_reply->qual[locidx].checklists[cnt1].obx_qual[chklstobxcnt].cki_cs = wd
        .answer_coding_sys_ident, ap_reply->qual[locidx].checklists[cnt1].obx_qual[chklstobxcnt].
        cki_text = wd.answer_txt,
        ap_reply->qual[locidx].checklists[cnt1].obx_qual[chklstobxcnt].alt_cki = wd.alt_answer_cki,
        ap_reply->qual[locidx].checklists[cnt1].obx_qual[chklstobxcnt].alt_cki_cs = wd
        .alt_answer_coding_sys_ident, ap_reply->qual[locidx].checklists[cnt1].obx_qual[chklstobxcnt].
        alt_cki_text = wd.alt_answer_txt,
        ap_reply->qual[locidx].checklists[cnt1].use_content_pkg_for_chklist = 0
       ENDIF
       ap_reply->qual[locidx].checklists[cnt1].worksheets[cnt2].use_content_pkg = 0
      ELSE
       IF (size(ap_reply->qual[locidx].checklists[cnt1].obx_qual,5)=0)
        ap_reply->qual[locidx].checklists[cnt1].use_content_pkg_for_chklist = 1
       ENDIF
       ap_reply->qual[locidx].checklists[cnt1].worksheets[cnt2].use_content_pkg = 1
      ENDIF
     ELSE
      cnt3 += 1, stat = alterlist(scd_request->stories,cnt3), ap_reply->qual[locidx].checklists[cnt1]
      .worksheets[cnt2].scd_story_id = ap.scd_story_id,
      scd_request->stories[cnt3].scd_story_id = ap.scd_story_id
      IF (size(ap_reply->qual[locidx].checklists[cnt1].obx_qual,5)=0)
       ap_reply->qual[locidx].checklists[cnt1].use_content_pkg_for_chklist = 1
      ENDIF
      ap_reply->qual[locidx].checklists[cnt1].worksheets[cnt2].use_content_pkg = 1
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  ae.accession_id
  FROM accession_external_smry ae
  WHERE ae.accession_id=dcaseid
  ORDER BY ae.collected_dt_tm
  DETAIL
   ap_reply->consult_case_ind = 1, ap_reply->consult_identifier = ae.external_accession
  WITH nocounter
 ;end select
 IF (size(scd_request->stories,5) > 0
  AND scd_synoptic_data_extract_exists > 0)
  EXECUTE scd_synoptic_data_extract  WITH replace("REQUEST","SCD_REQUEST"), replace("REPLY",
   "AP_REPLY")
  IF ((ap_reply->status_data.status="F"))
   SET ap_reply->status_data.subeventstatus[1].operationname = "Select"
   SET ap_reply->status_data.subeventstatus[1].operationstatus = "F"
   SET ap_reply->status_data.subeventstatus[1].targetobjectname = "SCD_SYNOPTIC_DATA_EXTRACT"
   SET ap_reply->status_data.subeventstatus[1].targetobjectvalue = "Call to the script unsuccessful"
  ENDIF
 ENDIF
 SET foreignwscnt = size(foreign_ws->qual,5)
 IF (foreignwscnt > 0)
  SET stat = uar_get_meaning_by_codeset(14409,"EP",1,eppatterntypecd)
  SET stat = uar_get_meaning_by_codeset(23,"AS",1,asciiformatcd)
  SET apreplystoryidx = size(ap_reply->stories,5)
  FOR (foreignwsidx = 1 TO foreignwscnt)
    SET apreplystoryidx += 1
    SET stat = alterlist(ap_reply->stories,apreplystoryidx)
    SELECT INTO "nl:"
     FROM scr_pattern scrp
     WHERE (scrp.scr_pattern_id=foreign_ws->qual[foreignwsidx].scr_pattern_id)
      AND scrp.pattern_type_cd=eppatterntypecd
     DETAIL
      ap_reply->stories[apreplystoryidx].cki_source = scrp.cki_source, ap_reply->stories[
      apreplystoryidx].cki_identifier = scrp.cki_identifier, ap_reply->stories[apreplystoryidx].
      display = scrp.display,
      ap_reply->stories[apreplystoryidx].description = scrp.definition, ap_reply->stories[
      apreplystoryidx].foreign_ws_ident = foreign_ws->qual[foreignwsidx].foreign_ws_ident
     WITH nocounter
    ;end select
    SET apreplystoryquesidx = 0
    SELECT INTO "nl:"
     FROM ap_case_synoptic_ws_data acswd,
      long_text lt
     PLAN (acswd
      WHERE (acswd.case_worksheet_id=foreign_ws->qual[foreignwsidx].case_worksheet_id)
       AND acswd.rec_type_flag=0)
      JOIN (lt
      WHERE (lt.long_text_id= Outerjoin(acswd.answer_long_text_id)) )
     ORDER BY acswd.ap_case_synoptic_ws_data_id
     DETAIL
      apreplystoryquesidx += 1, stat = alterlist(ap_reply->stories[apreplystoryidx].questions,
       apreplystoryquesidx), ap_reply->stories[apreplystoryidx].questions[apreplystoryquesidx].
      question_concept_cki = acswd.question_concept_cki,
      ap_reply->stories[apreplystoryidx].questions[apreplystoryquesidx].answer_concept_cki = acswd
      .answer_concept_cki, apreplyanswertextidx = 0
      IF (lt.long_text_id > 0)
       textlen = blobgetlen(lt.long_text), stat = memrealloc(outbuf,1,build("C",textlen)), totlen =
       blobget(outbuf,0,lt.long_text),
       offset = 0
       WHILE (offset < textlen)
         apreplyanswertextidx += 1, stat = alterlist(ap_reply->stories[apreplystoryidx].questions[
          apreplystoryquesidx].answer_value_text,apreplyanswertextidx), ap_reply->stories[
         apreplystoryidx].questions[apreplystoryquesidx].answer_value_text[apreplyanswertextidx].
         sequence_number = apreplyanswertextidx,
         ap_reply->stories[apreplystoryidx].questions[apreplystoryquesidx].answer_value_text[
         apreplyanswertextidx].text_blob = substring(offset,answertextchunksize,outbuf), offset +=
         answertextchunksize
       ENDWHILE
      ELSEIF (size(trim(acswd.answer_value,1),1) > 0)
       apreplyanswertextidx += 1, stat = alterlist(ap_reply->stories[apreplystoryidx].questions[
        apreplystoryquesidx].answer_value_text,apreplyanswertextidx), ap_reply->stories[
       apreplystoryidx].questions[apreplystoryquesidx].answer_value_text[apreplyanswertextidx].
       sequence_number = (apreplyanswertextidx - 1),
       ap_reply->stories[apreplystoryidx].questions[apreplystoryquesidx].answer_value_text[
       apreplyanswertextidx].text_blob = acswd.answer_value
      ENDIF
      IF (size(ap_reply->stories[apreplystoryidx].questions[apreplystoryquesidx].answer_value_text,5)
       > 0)
       IF (acswd.answer_text_format_cd > 0)
        ap_reply->stories[apreplystoryidx].questions[apreplystoryquesidx].answer_value_text_format_cd
         = acswd.answer_text_format_cd
       ELSE
        ap_reply->stories[apreplystoryidx].questions[apreplystoryquesidx].answer_value_text_format_cd
         = asciiformatcd
       ENDIF
      ENDIF
      IF (acswd.answer_type_flag=2)
       ap_reply->stories[apreplystoryidx].questions[apreplystoryquesidx].answer_value_is_number = 1
      ENDIF
      ap_reply->stories[apreplystoryidx].questions[apreplystoryquesidx].answer_unit_cd = acswd
      .answer_unit_cd, ap_reply->stories[apreplystoryidx].questions[apreplystoryquesidx].
      question_text = acswd.question_txt, ap_reply->stories[apreplystoryidx].questions[
      apreplystoryquesidx].question_coding_sys = acswd.question_coding_sys_ident,
      ap_reply->stories[apreplystoryidx].questions[apreplystoryquesidx].answer_text = acswd
      .answer_txt, ap_reply->stories[apreplystoryidx].questions[apreplystoryquesidx].
      answer_coding_sys = acswd.answer_coding_sys_ident, ap_reply->stories[apreplystoryidx].
      questions[apreplystoryquesidx].alt_question_cki = acswd.alt_question_cki,
      ap_reply->stories[apreplystoryidx].questions[apreplystoryquesidx].alt_question_text = acswd
      .alt_question_txt, ap_reply->stories[apreplystoryidx].questions[apreplystoryquesidx].
      alt_question_coding_sys = acswd.alt_question_coding_sys_ident, ap_reply->stories[
      apreplystoryidx].questions[apreplystoryquesidx].alt_answer_cki = acswd.alt_answer_cki,
      ap_reply->stories[apreplystoryidx].questions[apreplystoryquesidx].alt_answer_text = acswd
      .alt_answer_txt, ap_reply->stories[apreplystoryidx].questions[apreplystoryquesidx].
      alt_answer_coding_sys = acswd.alt_answer_coding_sys_ident, ap_reply->stories[apreplystoryidx].
      questions[apreplystoryquesidx].answer_unit_ident = acswd.answer_unit_ident,
      ap_reply->stories[apreplystoryidx].questions[apreplystoryquesidx].answer_unit_text = acswd
      .answer_unit_txt, ap_reply->stories[apreplystoryidx].questions[apreplystoryquesidx].
      answer_unit_coding_sys = acswd.answer_unit_coding_sys_ident, ap_reply->stories[apreplystoryidx]
      .questions[apreplystoryquesidx].answer_type_text = acswd.answer_type_txt,
      ap_reply->stories[apreplystoryidx].questions[apreplystoryquesidx].sub_answer_type_text = acswd
      .sub_answer_type_txt, ap_reply->stories[apreplystoryidx].questions[apreplystoryquesidx].
      answer_sub_ident = acswd.answer_sub_ident
     WITH nocounter
    ;end select
  ENDFOR
 ENDIF
 FREE RECORD foreign_ws
END GO
