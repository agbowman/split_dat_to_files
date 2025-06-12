CREATE PROGRAM bed_get_ado_detail:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 details[*]
      2 category_id = f8
      2 category_name = vc
      2 notes = vc
      2 select_ind = i2
      2 options[*]
        3 option_id = f8
        3 preselect_ind = i2
        3 sequence = i4
        3 ord_list[*]
          4 synonym_id = f8
          4 synonym_name = vc
          4 sentence_id = f8
          4 sentence_disp = vc
          4 synonym_vv_ind = i2
          4 sentence_vv_ind = i2
          4 sequence = i4
        3 notes = vc
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
 SET cnt = 0
 FREE RECORD temp
 RECORD temp(
   1 details[*]
     2 detail_id = f8
 )
 SELECT INTO "nl:"
  FROM br_ado_topic_scenario s,
   br_ado_detail d,
   br_ado_category c
  PLAN (s
   WHERE (s.br_ado_topic_scenario_id=request->topic_scenario_id))
   JOIN (d
   WHERE (d.facility_cd=request->facility_code_value)
    AND d.scenario_mean=s.scenario_mean)
   JOIN (c
   WHERE c.br_ado_category_id=d.br_ado_category_id)
  ORDER BY d.scenario_category_seq, d.br_ado_category_id
  HEAD d.br_ado_category_id
   cnt = (cnt+ 1), stat = alterlist(reply->details,cnt), stat = alterlist(temp->details,cnt),
   reply->details[cnt].category_id = d.br_ado_category_id, reply->details[cnt].category_name = c
   .category_name, reply->details[cnt].notes = d.note_txt,
   reply->details[cnt].select_ind = d.select_ind, temp->details[cnt].detail_id = d.br_ado_detail_id
  WITH nocounter
 ;end select
 CALL echorecord(temp)
 IF (cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(cnt)),
    br_ado_option o,
    br_ado_ord_list ol,
    order_catalog_synonym ocs,
    order_sentence s,
    ocs_facility_r ofr,
    filter_entity_reltn f,
    dummyt d1,
    dummyt d2,
    dummyt d3
   PLAN (d)
    JOIN (o
    WHERE (o.br_ado_detail_id=temp->details[d.seq].detail_id))
    JOIN (ol
    WHERE ol.br_ado_option_id=o.br_ado_option_id)
    JOIN (ocs
    WHERE ocs.synonym_id=ol.synonym_id
     AND ocs.active_ind=1)
    JOIN (d1)
    JOIN (s
    WHERE s.order_sentence_id=ol.sentence_id)
    JOIN (d2)
    JOIN (ofr
    WHERE ofr.synonym_id=ocs.synonym_id
     AND ((ofr.facility_cd=0) OR ((ofr.facility_cd=request->facility_code_value))) )
    JOIN (d3)
    JOIN (f
    WHERE f.parent_entity_name="ORDER_SENTENCE"
     AND f.parent_entity_id=s.order_sentence_id
     AND f.filter_entity1_name="LOCATION"
     AND ((f.filter_entity1_id=0) OR ((f.filter_entity1_id=request->facility_code_value))) )
   ORDER BY o.br_ado_detail_id, o.br_ado_option_id, ol.br_ado_ord_list_id
   HEAD o.br_ado_detail_id
    ocnt = 0
   HEAD o.br_ado_option_id
    ocnt = (ocnt+ 1), olcnt = 0, stat = alterlist(reply->details[d.seq].options,ocnt),
    reply->details[d.seq].options[ocnt].option_id = o.br_ado_option_id, reply->details[d.seq].
    options[ocnt].preselect_ind = o.preselect_ind, reply->details[d.seq].options[ocnt].sequence = o
    .option_seq,
    reply->details[d.seq].options[ocnt].notes = o.note_txt
   HEAD ol.br_ado_ord_list_id
    olcnt = (olcnt+ 1), stat = alterlist(reply->details[d.seq].options[ocnt].ord_list,olcnt), reply->
    details[d.seq].options[ocnt].ord_list[olcnt].synonym_id = ol.synonym_id,
    reply->details[d.seq].options[ocnt].ord_list[olcnt].synonym_name = ocs.mnemonic, reply->details[d
    .seq].options[ocnt].ord_list[olcnt].sequence = ol.synonym_seq
    IF (ofr.synonym_id > 0)
     reply->details[d.seq].options[ocnt].ord_list[olcnt].synonym_vv_ind = 1
    ENDIF
    reply->details[d.seq].options[ocnt].ord_list[olcnt].sentence_id = ol.sentence_id, reply->details[
    d.seq].options[ocnt].ord_list[olcnt].sentence_disp = s.order_sentence_display_line
    IF (f.parent_entity_id > 0)
     reply->details[d.seq].options[ocnt].ord_list[olcnt].sentence_vv_ind = 1
    ENDIF
   WITH nocounter, outerjoin = d1, outerjoin = d2,
    outerjoin = d3, dontcare = ofr
  ;end select
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
