CREATE PROGRAM bed_aud_mos_admin:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 paramlist[*]
      2 param_type_mean = vc
      2 pdate1 = dq8
      2 pdate2 = dq8
      2 vlist[*]
        3 dbl_value = f8
        3 string_value = vc
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 collist[*]
      2 header_text = vc
      2 data_type = i2
      2 hide_ind = i2
    1 rowlist[*]
      2 celllist[*]
        3 date_value = dq8
        3 nbr_value = i4
        3 double_value = f8
        3 string_value = vc
        3 display_flag = i2
    1 high_volume_flag = i2
    1 output_filename = vc
    1 run_status_flag = i2
    1 statlist[*]
      2 statistic_meaning = vc
      2 status_flag = i2
      2 qualifying_items = i4
      2 total_items = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 SET total_col = 0
 SET prim_pharm_id = 0
 DECLARE pharm_cd = f8
 DECLARE order_cd = f8
 DECLARE prim_cd = f8
 DECLARE dcp_cd = f8
 DECLARE brand_cd = f8
 DECLARE c_cd = f8
 DECLARE e_cd = f8
 DECLARE m_cd = f8
 DECLARE n_cd = f8
 SET pharm_cd = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET order_cd = uar_get_code_by("MEANING",6003,"ORDER")
 SET prim_cd = uar_get_code_by("MEANING",6011,"PRIMARY")
 SET dcp_cd = uar_get_code_by("MEANING",6011,"DCP")
 SET brand_cd = uar_get_code_by("MEANING",6011,"BRANDNAME")
 SET c_cd = uar_get_code_by("MEANING",6011,"DISPDRUG")
 SET e_cd = uar_get_code_by("MEANING",6011,"IVNAME")
 SET m_cd = uar_get_code_by("MEANING",6011,"GENERICTOP")
 SET n_cd = uar_get_code_by("MEANING",6011,"TRADETOP")
 SELECT INTO "nl:"
  FROM order_entry_format oef
  PLAN (oef
   WHERE cnvtupper(oef.oe_format_name)="PRIMARY PHARMACY"
    AND oef.action_type_cd=order_cd)
  DETAIL
   prim_pharm_id = oef.oe_format_id
  WITH nocounter
 ;end select
 FREE RECORD fields
 RECORD fields(
   1 qual[*]
     2 meaning = vc
 )
 SET stat = alterlist(fields->qual,18)
 SET fields->qual[1].meaning = "STRENGTHDOSE"
 SET fields->qual[2].meaning = "STRENGTHDOSEUNIT"
 SET fields->qual[3].meaning = "VOLUMEDOSE"
 SET fields->qual[4].meaning = "VOLUMEDOSEUNIT"
 SET fields->qual[5].meaning = "FREETXTDOSE"
 SET fields->qual[6].meaning = "RXROUTE"
 SET fields->qual[7].meaning = "DRUGFORM"
 SET fields->qual[8].meaning = "FREQ"
 SET fields->qual[9].meaning = "RXPRIORITY"
 SET fields->qual[10].meaning = "SCH/PRN"
 SET fields->qual[11].meaning = "PRNREASON"
 SET fields->qual[12].meaning = "FREETEXTRATE"
 SET fields->qual[13].meaning = "RATE"
 SET fields->qual[14].meaning = "RATEUNIT"
 SET fields->qual[15].meaning = "INFUSEOVER"
 SET fields->qual[16].meaning = "INFUSEOVERUNIT"
 SET fields->qual[17].meaning = "DURATION"
 SET fields->qual[18].meaning = "DURATIONUNIT"
 SET fcnt = 18
 SELECT DISTINCT INTO "nl:"
  ofm.oe_field_meaning
  FROM order_catalog oc,
   order_catalog_synonym ocs,
   ord_cat_sent_r r,
   order_sentence os,
   order_sentence_detail osd,
   oe_field_meaning ofm
  PLAN (oc
   WHERE oc.catalog_type_cd=pharm_cd
    AND oc.orderable_type_flag IN (0, 1)
    AND oc.active_ind=1)
   JOIN (ocs
   WHERE ocs.catalog_cd=oc.catalog_cd
    AND ocs.mnemonic_type_cd IN (prim_cd, dcp_cd, brand_cd, c_cd, e_cd,
   m_cd, n_cd)
    AND ocs.active_ind=1
    AND ocs.oe_format_id > 0
    AND ocs.oe_format_id != prim_pharm_id)
   JOIN (r
   WHERE r.synonym_id=ocs.synonym_id
    AND r.active_ind=1)
   JOIN (os
   WHERE os.order_sentence_id=r.order_sentence_id
    AND os.usage_flag IN (0, 1))
   JOIN (osd
   WHERE osd.order_sentence_id=os.order_sentence_id)
   JOIN (ofm
   WHERE ofm.oe_field_meaning_id=osd.oe_field_meaning_id
    AND  NOT (ofm.oe_field_meaning IN ("STRENGTHDOSE", "STRENGTHDOSEUNIT", "VOLUMEDOSE",
   "VOLUMEDOSEUNIT", "FREETXTDOSE",
   "RXROUTE", "DRUGFORM", "FREQ", "RXPRIORITY", "SCH/PRN",
   "PRNREASON", "FREETEXTRATE", "RATE", "RATEUNIT", "INFUSEOVER",
   "INFUSEOVERUNIT", "DURATION", "DURATIONUNIT")))
  HEAD ofm.oe_field_meaning
   fcnt = (fcnt+ 1), stat = alterlist(fields->qual,fcnt), fields->qual[fcnt].meaning = ofm
   .oe_field_meaning
  WITH nocounter
 ;end select
 FREE SET sent
 RECORD sent(
   1 qual[*]
     2 id = f8
     2 primary = vc
     2 synonym = vc
     2 key_cap = vc
     2 type = vc
     2 format = vc
     2 sent_id = f8
     2 sentence = vc
     2 usage_flag = vc
     2 oc_cki = vc
     2 ocs_cki = vc
     2 ident = vc
     2 comment = vc
     2 sequence = vc
     2 det[*]
       3 field = vc
       3 value = vc
 )
 FREE SET syn
 RECORD syn(
   1 qual[*]
     2 id = f8
 )
 SET cnt = 0
 SELECT INTO "nl:"
  FROM order_catalog oc,
   order_catalog_synonym ocs,
   order_catalog_synonym ocs2
  PLAN (oc
   WHERE oc.catalog_type_cd=pharm_cd
    AND oc.orderable_type_flag IN (0, 1)
    AND oc.active_ind=1)
   JOIN (ocs
   WHERE ocs.catalog_cd=oc.catalog_cd
    AND ocs.mnemonic_type_cd=prim_cd
    AND ocs.active_ind=1
    AND ocs.oe_format_id > 0
    AND ocs.oe_format_id != prim_pharm_id)
   JOIN (ocs2
   WHERE ocs2.catalog_cd=outerjoin(oc.catalog_cd)
    AND ocs2.active_ind=outerjoin(1)
    AND ocs2.oe_format_id > outerjoin(0)
    AND ocs2.oe_format_id != outerjoin(prim_pharm_id))
  ORDER BY cnvtupper(oc.primary_mnemonic), ocs2.mnemonic_key_cap
  HEAD ocs.synonym_id
   cnt = (cnt+ 1), stat = alterlist(syn->qual,cnt), syn->qual[cnt].id = ocs.synonym_id
  HEAD ocs2.synonym_id
   IF (ocs2.mnemonic_type_cd IN (dcp_cd, brand_cd, c_cd, e_cd, m_cd,
   n_cd))
    cnt = (cnt+ 1), stat = alterlist(syn->qual,cnt), syn->qual[cnt].id = ocs2.synonym_id
   ENDIF
  WITH nocounter
 ;end select
 CALL echo(cnt)
 IF (cnt=0)
  GO TO exit_script
 ENDIF
 SET dcnt = 0
 SET scnt = 0
 DECLARE select_cnt = i4 WITH private, noconstant(0)
 DECLARE in_clause_size = i4 WITH private, constant(250)
 DECLARE start_idx = i4
 DECLARE end_idx = i4
 IF (mod(cnt,in_clause_size)=0)
  SET select_cnt = (cnt/ in_clause_size)
 ELSE
  SET select_cnt = ((cnt/ in_clause_size)+ 1)
 ENDIF
 FOR (xx = 1 TO select_cnt)
   SET syn_cnt = 0
   FREE SET syn2
   RECORD syn2(
     1 qual[*]
       2 id = f8
   )
   IF (select_cnt=1)
    FOR (z = 1 TO cnt)
      SET syn_cnt = (syn_cnt+ 1)
      SET stat = alterlist(syn2->qual,syn_cnt)
      SET syn2->qual[syn_cnt].id = syn->qual[z].id
    ENDFOR
   ELSE
    SET start_idx = (((xx - 1) * in_clause_size)+ 1)
    IF (xx < select_cnt)
     SET end_idx = (start_idx+ in_clause_size)
    ELSE
     SET end_idx = cnt
    ENDIF
    FOR (z = start_idx TO end_idx)
      SET syn_cnt = (syn_cnt+ 1)
      SET stat = alterlist(syn2->qual,syn_cnt)
      SET syn2->qual[syn_cnt].id = syn->qual[z].id
    ENDFOR
   ENDIF
   SET stat = load_sent(xx)
 ENDFOR
 SUBROUTINE load_sent(xx)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(syn2->qual,5))),
    order_catalog_synonym ocs,
    order_catalog oc,
    ord_cat_sent_r r,
    order_sentence os,
    order_sentence_detail osd,
    code_value cv,
    order_entry_format oef,
    long_text lt,
    oe_field_meaning ofm,
    order_entry_fields f
   PLAN (d)
    JOIN (ocs
    WHERE (ocs.synonym_id=syn2->qual[d.seq].id))
    JOIN (oc
    WHERE oc.catalog_cd=ocs.catalog_cd)
    JOIN (r
    WHERE r.synonym_id=ocs.synonym_id
     AND r.active_ind=1)
    JOIN (os
    WHERE os.order_sentence_id=r.order_sentence_id
     AND os.usage_flag IN (0, 1))
    JOIN (osd
    WHERE osd.order_sentence_id=os.order_sentence_id)
    JOIN (cv
    WHERE cv.code_value=osd.default_parent_entity_id)
    JOIN (oef
    WHERE oef.oe_format_id=ocs.oe_format_id
     AND oef.action_type_cd=order_cd)
    JOIN (lt
    WHERE lt.long_text_id=outerjoin(os.ord_comment_long_text_id))
    JOIN (ofm
    WHERE ofm.oe_field_meaning_id=osd.oe_field_meaning_id)
    JOIN (f
    WHERE f.oe_field_id=osd.oe_field_id
     AND f.field_type_flag != 13)
   ORDER BY d.seq, r.display_seq, r.order_sentence_disp_line
   HEAD r.order_sentence_id
    dcnt = 0, scnt = (scnt+ 1), stat = alterlist(sent->qual,scnt),
    sent->qual[scnt].sent_id = r.order_sentence_id, sent->qual[scnt].sentence = r
    .order_sentence_disp_line, sent->qual[scnt].id = ocs.synonym_id,
    sent->qual[scnt].primary = oc.primary_mnemonic, sent->qual[scnt].synonym = ocs.mnemonic, sent->
    qual[scnt].key_cap = ocs.mnemonic_key_cap,
    sent->qual[scnt].type = uar_get_code_display(ocs.mnemonic_type_cd), sent->qual[scnt].format = oef
    .oe_format_name
    IF (os.usage_flag=0)
     sent->qual[scnt].usage_flag = "Both"
    ELSE
     sent->qual[scnt].usage_flag = "Medication Administration"
    ENDIF
    sent->qual[scnt].oc_cki = oc.cki, sent->qual[scnt].ocs_cki = ocs.cki, sent->qual[scnt].ident = os
    .external_identifier,
    sent->qual[scnt].comment = lt.long_text, sent->qual[scnt].sequence = cnvtstring(r.display_seq)
   DETAIL
    dcnt = (dcnt+ 1), stat = alterlist(sent->qual[scnt].det,dcnt), sent->qual[scnt].det[dcnt].field
     = ofm.oe_field_meaning
    IF (osd.default_parent_entity_id > 0)
     sent->qual[scnt].det[dcnt].value = cv.display
    ELSE
     IF (f.field_type_flag=7
      AND trim(osd.oe_field_display_value)="1")
      sent->qual[scnt].det[dcnt].value = "Yes"
     ELSEIF (f.field_type_flag=7
      AND trim(osd.oe_field_display_value)="0")
      sent->qual[scnt].det[dcnt].value = "Yes"
     ELSE
      sent->qual[scnt].det[dcnt].value = osd.oe_field_display_value
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  RETURN(0)
 END ;Subroutine
 IF (scnt=0)
  GO TO exit_script
 ENDIF
 CALL echo(scnt)
 SET total_col = ((fcnt * 2)+ 14)
 SET stat = alterlist(reply->collist,total_col)
 SET reply->collist[1].header_text = "Orderable"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Synonym"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Mnemonic Key Cap"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 1
 SET reply->collist[4].header_text = "Synonym Type"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Synonym ID"
 SET reply->collist[5].data_type = 2
 SET reply->collist[5].hide_ind = 1
 SET reply->collist[6].header_text = "Order Entry Format"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Catalog CKI"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Synonym CKI"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Order Sentence ID"
 SET reply->collist[9].data_type = 2
 SET reply->collist[9].hide_ind = 1
 SET reply->collist[10].header_text = "Order Sentence"
 SET reply->collist[10].data_type = 1
 SET reply->collist[10].hide_ind = 0
 SET reply->collist[11].header_text = "Medication Administration or Prescription?"
 SET reply->collist[11].data_type = 1
 SET reply->collist[11].hide_ind = 0
 SET reply->collist[12].header_text = "Order Sentence Sequence"
 SET reply->collist[12].data_type = 1
 SET reply->collist[12].hide_ind = 0
 SET reply->collist[13].header_text = "Sentence External ID"
 SET reply->collist[13].data_type = 1
 SET reply->collist[13].hide_ind = 1
 SET num = 13
 FOR (x = 1 TO fcnt)
   SET num = (num+ 1)
   SET reply->collist[num].header_text = concat("Order Entry Field ",trim(cnvtstring(x)))
   SET reply->collist[num].data_type = 1
   SET reply->collist[num].hide_ind = 0
   SET num = (num+ 1)
   SET reply->collist[num].header_text = concat("Order Entry Field Value",trim(cnvtstring(x)))
   SET reply->collist[num].data_type = 1
   SET reply->collist[num].hide_ind = 0
 ENDFOR
 SET reply->collist[total_col].header_text = "Order Sentence Comment"
 SET reply->collist[total_col].data_type = 1
 SET reply->collist[total_col].hide_ind = 0
 SET rcnt = 0
 FOR (x = 1 TO scnt)
   SET rcnt = (rcnt+ 1)
   SET stat = alterlist(reply->rowlist,rcnt)
   SET stat = alterlist(reply->rowlist[rcnt].celllist,total_col)
   SET reply->rowlist[rcnt].celllist[1].string_value = sent->qual[x].primary
   SET reply->rowlist[rcnt].celllist[2].string_value = sent->qual[x].synonym
   SET reply->rowlist[rcnt].celllist[3].string_value = sent->qual[x].key_cap
   SET reply->rowlist[rcnt].celllist[4].string_value = sent->qual[x].type
   SET reply->rowlist[rcnt].celllist[5].double_value = sent->qual[x].id
   SET reply->rowlist[rcnt].celllist[6].string_value = sent->qual[x].format
   SET reply->rowlist[rcnt].celllist[7].string_value = sent->qual[x].oc_cki
   SET reply->rowlist[rcnt].celllist[8].string_value = sent->qual[x].ocs_cki
   SET reply->rowlist[rcnt].celllist[9].double_value = sent->qual[x].sent_id
   SET reply->rowlist[rcnt].celllist[10].string_value = sent->qual[x].sentence
   SET reply->rowlist[rcnt].celllist[11].string_value = sent->qual[x].usage_flag
   SET reply->rowlist[rcnt].celllist[12].string_value = sent->qual[x].sequence
   SET reply->rowlist[rcnt].celllist[13].string_value = sent->qual[x].ident
   SET reply->rowlist[rcnt].celllist[total_col].string_value = sent->qual[x].comment
   SET num = 14
   FOR (y = 1 TO fcnt)
    SET reply->rowlist[rcnt].celllist[num].string_value = fields->qual[y].meaning
    SET num = (num+ 2)
   ENDFOR
   FOR (y = 1 TO size(sent->qual[x].det,5))
     FOR (z = 14 TO total_col)
       IF ((sent->qual[x].det[y].field=reply->rowlist[rcnt].celllist[z].string_value))
        SET reply->rowlist[rcnt].celllist[(z+ 1)].string_value = sent->qual[x].det[y].value
       ENDIF
     ENDFOR
   ENDFOR
 ENDFOR
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
 IF (rcnt > 5000)
  SET reply->high_volume_flag = 2
  SET stat = alterlist(reply->collist,0)
  SET stat = alterlist(reply->rowlist,0)
  SET reply->output_filename = build("mos_admin_audit.csv")
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
END GO
