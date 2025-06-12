CREATE PROGRAM bed_get_ado_prop_detail:dba
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
          4 synonym_name = vc
          4 unique_identifier = vc
          4 text = vc
          4 user_syn[*]
            5 client_disp = vc
            5 synonym_id = f8
            5 syn_fac_ind = i2
          4 sequence = i4
        3 notes = vc
      2 defined_ind = i2
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
  FROM br_ado_proposed_detail d,
   br_ado_category c
  PLAN (d
   WHERE (d.br_ado_topic_scenario_id=request->topic_scenario_id))
   JOIN (c
   WHERE c.br_ado_category_id=d.br_ado_category_id)
  ORDER BY d.br_ado_category_id
  HEAD d.br_ado_category_id
   cnt = (cnt+ 1), stat = alterlist(reply->details,cnt), stat = alterlist(temp->details,cnt),
   reply->details[cnt].category_id = d.br_ado_category_id, reply->details[cnt].category_name = c
   .category_name, reply->details[cnt].notes = d.note_txt,
   reply->details[cnt].select_ind = d.select_ind, temp->details[cnt].detail_id = d
   .br_ado_proposed_detail_id
  WITH nocounter
 ;end select
 CALL echorecord(temp)
 IF ((request->view_rec_syn_ind=1))
  IF (cnt > 0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(cnt)),
     br_ado_proposed_option o,
     br_ado_proposed_ord_list ol,
     dummyt d1,
     order_catalog_synonym ocs,
     dummyt d2,
     ocs_facility_r ofr
    PLAN (d)
     JOIN (o
     WHERE (o.br_ado_proposed_detail_id=temp->details[d.seq].detail_id))
     JOIN (ol
     WHERE ol.br_ado_proposed_option_id=o.br_ado_proposed_option_id)
     JOIN (d1)
     JOIN (ocs
     WHERE ((ocs.mnemonic_key_cap=cnvtupper(ol.synonym_name)
      AND ocs.mnemonic_key_cap > " ") OR (((ocs.concept_cki=ol.synonym_unique_ident
      AND ocs.concept_cki > " ") OR (ocs.cki=ol.synonym_unique_ident
      AND ocs.cki > " "
      AND ocs.active_ind=1)) )) )
     JOIN (d2)
     JOIN (ofr
     WHERE ofr.synonym_id=ocs.synonym_id
      AND ((ofr.facility_cd=0) OR ((ofr.facility_cd=request->facility_code_value))) )
    ORDER BY o.br_ado_proposed_detail_id, o.br_ado_proposed_option_id, ol.br_ado_proposed_ord_list_id
    HEAD o.br_ado_proposed_detail_id
     ocnt = 0
    HEAD o.br_ado_proposed_option_id
     ocnt = (ocnt+ 1), olcnt = 0, stat = alterlist(reply->details[d.seq].options,ocnt),
     reply->details[d.seq].options[ocnt].option_id = o.br_ado_proposed_option_id, reply->details[d
     .seq].options[ocnt].preselect_ind = o.preselect_ind, reply->details[d.seq].options[ocnt].
     sequence = o.option_seq,
     reply->details[d.seq].options[ocnt].notes = o.note_txt
    HEAD ol.br_ado_proposed_ord_list_id
     olcnt = (olcnt+ 1), scnt = 0, stat = alterlist(reply->details[d.seq].options[ocnt].ord_list,
      olcnt),
     reply->details[d.seq].options[ocnt].ord_list[olcnt].synonym_name = ol.synonym_name, reply->
     details[d.seq].options[ocnt].ord_list[olcnt].sequence = ol.synonym_seq, reply->details[d.seq].
     options[ocnt].ord_list[olcnt].unique_identifier = ol.synonym_unique_ident,
     reply->details[d.seq].options[ocnt].ord_list[olcnt].text = ol.proposed_sentence_txt,
     CALL echo(build("syn: ",ol.synonym_name))
    DETAIL
     scnt = (scnt+ 1), stat = alterlist(reply->details[d.seq].options[ocnt].ord_list[olcnt].user_syn,
      scnt), reply->details[d.seq].options[ocnt].ord_list[olcnt].user_syn[scnt].client_disp = ocs
     .mnemonic,
     reply->details[d.seq].options[ocnt].ord_list[olcnt].user_syn[scnt].synonym_id = ocs.synonym_id
     IF (((ofr.facility_cd=0) OR ((ofr.facility_cd=request->facility_code_value)))
      AND ofr.synonym_id > 0)
      reply->details[d.seq].options[ocnt].ord_list[olcnt].user_syn[scnt].syn_fac_ind = 2
     ELSEIF (ofr.synonym_id=0
      AND ocs.synonym_id > 0)
      reply->details[d.seq].options[ocnt].ord_list[olcnt].user_syn[scnt].syn_fac_ind = 3
     ELSEIF (ofr.synonym_id=0
      AND ocs.synonym_id=0)
      reply->details[d.seq].options[ocnt].ord_list[olcnt].user_syn[scnt].syn_fac_ind = 4
     ENDIF
    WITH nocounter, outerjoin = d1, outerjoin = d2
   ;end select
  ENDIF
  FOR (i = 1 TO cnt)
   SET x = size(reply->details[i].options,5)
   FOR (j = 1 TO x)
     SET y = size(reply->details[i].options[j].ord_list,5)
     CALL echo(build("reply-category",reply->details[i].category_id))
     SELECT INTO "nl:"
      FROM (dummyt d1  WITH seq = value(y)),
       (dummyt d2  WITH seq = value(1)),
       br_ado_detail d,
       br_ado_option o,
       br_ado_ord_list ol
      PLAN (d1
       WHERE maxrec(d2,size(reply->details[i].options[j].ord_list[d1.seq].user_syn,5)))
       JOIN (d2)
       JOIN (d
       WHERE (d.scenario_mean=
       (SELECT
        ts.scenario_mean
        FROM br_ado_topic_scenario ts
        WHERE (ts.br_ado_topic_scenario_id=request->topic_scenario_id)))
        AND (d.facility_cd=request->facility_code_value)
        AND (d.br_ado_category_id=reply->details[i].category_id))
       JOIN (o
       WHERE o.br_ado_detail_id=d.br_ado_detail_id)
       JOIN (ol
       WHERE ol.br_ado_option_id=outerjoin(o.br_ado_option_id)
        AND ol.synonym_id=outerjoin(reply->details[i].options[j].ord_list[d1.seq].user_syn[d2.seq].
        synonym_id))
      DETAIL
       CALL echo(build("******************************")), reply->details[i].defined_ind = 1
       IF ((reply->details[i].options[j].ord_list[d1.seq].user_syn[d2.seq].syn_fac_ind=2)
        AND ol.synonym_id > 0)
        reply->details[i].options[j].ord_list[d1.seq].user_syn[d2.seq].syn_fac_ind = 1
       ENDIF
      WITH nocounter
     ;end select
   ENDFOR
  ENDFOR
 ELSE
  IF (cnt > 0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(cnt)),
     br_ado_proposed_option o,
     br_ado_proposed_ord_list ol,
     order_catalog_synonym ocs,
     ocs_facility_r ofr
    PLAN (d)
     JOIN (o
     WHERE (o.br_ado_proposed_detail_id=temp->details[d.seq].detail_id))
     JOIN (ol
     WHERE ol.br_ado_proposed_option_id=o.br_ado_proposed_option_id)
     JOIN (ocs
     WHERE ((ocs.mnemonic_key_cap=cnvtupper(ol.synonym_name)
      AND ocs.mnemonic_key_cap > " ") OR (((ocs.concept_cki=ol.synonym_unique_ident
      AND ocs.concept_cki > " ") OR (ocs.cki=ol.synonym_unique_ident
      AND ocs.cki > " "
      AND ocs.active_ind=1)) )) )
     JOIN (ofr
     WHERE ofr.synonym_id=ocs.synonym_id
      AND ((ofr.facility_cd=0) OR ((ofr.facility_cd=request->facility_code_value))) )
    ORDER BY o.br_ado_proposed_detail_id, o.br_ado_proposed_option_id, ol.br_ado_proposed_ord_list_id
    HEAD o.br_ado_proposed_detail_id
     ocnt = 0
    HEAD o.br_ado_proposed_option_id
     ocnt = (ocnt+ 1), olcnt = 0, stat = alterlist(reply->details[d.seq].options,ocnt),
     reply->details[d.seq].options[ocnt].option_id = o.br_ado_proposed_option_id, reply->details[d
     .seq].options[ocnt].preselect_ind = o.preselect_ind, reply->details[d.seq].options[ocnt].
     sequence = o.option_seq,
     reply->details[d.seq].options[ocnt].notes = o.note_txt
    HEAD ol.br_ado_proposed_ord_list_id
     olcnt = (olcnt+ 1), scnt = 0, stat = alterlist(reply->details[d.seq].options[ocnt].ord_list,
      olcnt),
     reply->details[d.seq].options[ocnt].ord_list[olcnt].synonym_name = ol.synonym_name, reply->
     details[d.seq].options[ocnt].ord_list[olcnt].unique_identifier = ol.synonym_unique_ident, reply
     ->details[d.seq].options[ocnt].ord_list[olcnt].text = ol.proposed_sentence_txt
    DETAIL
     scnt = (scnt+ 1), stat = alterlist(reply->details[d.seq].options[ocnt].ord_list[olcnt].user_syn,
      scnt), reply->details[d.seq].options[ocnt].ord_list[olcnt].user_syn[scnt].client_disp = ocs
     .mnemonic,
     reply->details[d.seq].options[ocnt].ord_list[olcnt].user_syn[scnt].synonym_id = ocs.synonym_id
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
