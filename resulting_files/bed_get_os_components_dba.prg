CREATE PROGRAM bed_get_os_components:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 sections[*]
      2 name = vc
      2 sequence = i4
      2 comp_reference = vc
    1 notes[*]
      2 text = vc
      2 sequence = i4
      2 comp_reference = vc
    1 component_synonyms[*]
      2 synonym_id = f8
      2 mnemonic = vc
      2 sequence = i4
      2 include_exclude_ind = i2
      2 required_ind = i2
      2 add_sent_ind = i2
      2 sentence
        3 sentence_id = f8
        3 display = vc
      2 mnemonic_type
        3 code_value = f8
        3 display = vc
        3 meaning = vc
      2 hide_flag = i2
      2 comp_reference = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE cnt = i4 WITH protect
 DECLARE list_cnt = i4 WITH protect
 DECLARE tot_cnt = i4 WITH protect
 DECLARE cnt2 = i4 WITH protect
 DECLARE list_cnt2 = i4 WITH protect
 SET cnt = 0
 SET list_cnt = 0
 SET cnt2 = 0
 SET list_cnt2 = 0
 SET tot_cnt = 0
 SELECT INTO "nl:"
  FROM cs_component cs,
   code_value cv
  PLAN (cs
   WHERE (cs.catalog_cd=request->order_set_code_value))
   JOIN (cv
   WHERE cv.code_set=6030
    AND cv.cdf_meaning="LABEL"
    AND cv.active_ind=1
    AND cv.code_value=cs.comp_type_cd)
  HEAD REPORT
   cnt = 0, list_cnt = 0, stat = alterlist(reply->sections,10)
  DETAIL
   cnt = (cnt+ 1), list_cnt = (list_cnt+ 1)
   IF (list_cnt > 10)
    stat = alterlist(reply->sections,(cnt+ 10)), list_cnt = 1
   ENDIF
   reply->sections[cnt].name = cs.comp_label, reply->sections[cnt].sequence = cs.comp_seq, reply->
   sections[cnt].comp_reference = cs.comp_reference
  FOOT REPORT
   stat = alterlist(reply->sections,cnt)
  WITH nocounter
 ;end select
 SET tot_cnt = (tot_cnt+ cnt)
 SELECT INTO "nl:"
  FROM cs_component cs,
   long_text lt,
   code_value cv
  PLAN (cs
   WHERE (cs.catalog_cd=request->order_set_code_value))
   JOIN (lt
   WHERE lt.long_text_id=cs.long_text_id)
   JOIN (cv
   WHERE cv.code_set=6030
    AND cv.cdf_meaning="NOTE"
    AND cv.active_ind=1
    AND cv.code_value=cs.comp_type_cd)
  HEAD REPORT
   cnt = 0, list_cnt = 0, stat = alterlist(reply->notes,10)
  DETAIL
   cnt = (cnt+ 1), list_cnt = (list_cnt+ 1)
   IF (list_cnt > 10)
    stat = alterlist(reply->notes,(cnt+ 10)), list_cnt = 1
   ENDIF
   reply->notes[cnt].text = lt.long_text, reply->notes[cnt].sequence = cs.comp_seq, reply->notes[cnt]
   .comp_reference = cs.comp_reference
  FOOT REPORT
   stat = alterlist(reply->notes,cnt)
  WITH nocounter
 ;end select
 SET tot_cnt = (tot_cnt+ cnt)
 SELECT INTO "nl:"
  FROM cs_component cs,
   order_catalog_synonym ocs,
   order_sentence os,
   code_value cv,
   code_value cv2
  PLAN (cs
   WHERE (cs.catalog_cd=request->order_set_code_value))
   JOIN (ocs
   WHERE ocs.synonym_id=cs.comp_id)
   JOIN (os
   WHERE os.order_sentence_id=outerjoin(cs.order_sentence_id)
    AND os.order_sentence_id > outerjoin(0))
   JOIN (cv
   WHERE cv.code_set=6030
    AND cv.cdf_meaning="ORDERABLE"
    AND cv.active_ind=1
    AND cv.code_value=cs.comp_type_cd)
   JOIN (cv2
   WHERE cv2.code_value=ocs.mnemonic_type_cd)
  ORDER BY cs.comp_id
  HEAD REPORT
   cnt = 0, list_cnt = 0, stat = alterlist(reply->component_synonyms,10)
  DETAIL
   cnt = (cnt+ 1), list_cnt = (list_cnt+ 1)
   IF (list_cnt > 10)
    stat = alterlist(reply->component_synonyms,(cnt+ 10)), list_cnt = 1
   ENDIF
   reply->component_synonyms[cnt].synonym_id = cs.comp_id, reply->component_synonyms[cnt].mnemonic =
   ocs.mnemonic, reply->component_synonyms[cnt].sequence = cs.comp_seq,
   reply->component_synonyms[cnt].include_exclude_ind = cs.include_exclude_ind, reply->
   component_synonyms[cnt].required_ind = cs.required_ind, reply->component_synonyms[cnt].sentence.
   sentence_id = os.order_sentence_id,
   reply->component_synonyms[cnt].sentence.display = os.order_sentence_display_line, reply->
   component_synonyms[cnt].mnemonic_type.code_value = cv2.code_value, reply->component_synonyms[cnt].
   mnemonic_type.display = cv2.display,
   reply->component_synonyms[cnt].mnemonic_type.meaning = cv2.cdf_meaning
   IF (ocs.oe_format_id > 0
    AND ((ocs.orderable_type_flag != 2) OR (ocs.orderable_type_flag != 6)) )
    reply->component_synonyms[cnt].add_sent_ind = 1
   ELSE
    reply->component_synonyms[cnt].add_sent_ind = 0
   ENDIF
   reply->component_synonyms[cnt].hide_flag = ocs.hide_flag, reply->component_synonyms[cnt].
   comp_reference = cs.comp_reference
  FOOT REPORT
   stat = alterlist(reply->component_synonyms,cnt)
  WITH nocounter
 ;end select
 SET tot_cnt = (tot_cnt+ cnt)
#exit_script
 IF (tot_cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
