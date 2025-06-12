CREATE PROGRAM bed_get_mos_dup_ip_sent:dba
 FREE SET reply
 RECORD reply(
   1 sentences[*]
     2 synonym_id = f8
     2 sentence_id = f8
     2 sent_display = vc
     2 encntr_group_code_value = f8
     2 sent_display_full = vc
     2 duplicates[*]
       3 synonym_id = f8
       3 sentence_id = f8
       3 sent_display = vc
       3 encntr_group_code_value = f8
       3 oe_format_id = f8
       3 sent_display_full = vc
       3 filter
         4 age_min_value = f8
         4 age_max_value = f8
         4 age_code_value = f8
         4 pma_min_value = f8
         4 pma_max_value = f8
         4 pma_code_value = f8
         4 weight_min_value = f8
         4 weight_max_value = f8
         4 weight_code_value = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 DECLARE build_facility_code(sentences_index=i4,fsize=i4) = vc
 DECLARE req_cnt = i2 WITH protect, noconstant(0)
 DECLARE action_code = f8 WITH protect, noconstant(0)
 DECLARE prn_id = f8 WITH protech, noconstant(0)
 SET reply->status_data.status = "F"
 SET req_cnt = size(request->sentences,5)
 SET action_code = uar_get_code_by("MEANING",6003,"ORDER")
 IF (req_cnt=0)
  GO TO exit_script
 ENDIF
 SET prn_id = 0.0
 SELECT INTO "nl:"
  FROM oe_field_meaning o
  WHERE o.oe_field_meaning="SCH/PRN"
  DETAIL
   prn_id = o.oe_field_meaning_id
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->sentences,req_cnt)
 FOR (x = 1 TO req_cnt)
   SET reply->sentences[x].synonym_id = request->sentences[x].synonym_id
   SET reply->sentences[x].sentence_id = request->sentences[x].sentence_id
   SET reply->sentences[x].sent_display = request->sentences[x].sent_display
   SET reply->sentences[x].encntr_group_code_value = request->sentences[x].encntr_group_code_value
   SET reply->sentences[x].sent_display_full = request->sentences[x].sent_display_full
   DECLARE max_dup_cnt = f8 WITH protect
   DECLARE tformat_id = f8 WITH protect
   DECLARE tcnt = i2 WITH protect
   DECLARE cnt = i2 WITH protect
   DECLARE fsize = i2 WITH protect
   DECLARE temp_field_disp_value = vc
   DECLARE temp_oe_field_label = vc
   DECLARE order_sentence = vc
   DECLARE order_sentence_full = vc
   DECLARE os_value = vc
   DECLARE facility_entity_id_parse = vc
   SET max_dup_cnt = 0
   SET tformat_id = 0
   SELECT INTO "nl:"
    FROM order_catalog_synonym ocs
    WHERE (ocs.synonym_id=request->sentences[x].synonym_id)
    DETAIL
     tformat_id = ocs.oe_format_id
    WITH nocounter
   ;end select
   SET tcnt = 0
   SET fsize = size(request->sentences[x].facilities,5)
   CALL echo(fsize)
   IF (fsize > 0)
    SET facility_entity_id_parse = build_facility_code(x,fsize)
    SELECT DISTINCT INTO "nl:"
     os.order_sentence_id
     FROM ord_cat_sent_r ocsr,
      order_sentence os,
      order_sentence_detail osd,
      order_entry_fields oef,
      oe_format_fields off,
      filter_entity_reltn f,
      order_sentence_filter osf
     PLAN (ocsr
      WHERE (ocsr.synonym_id=request->sentences[x].synonym_id)
       AND ((ocsr.order_sentence_id+ 0) != request->sentences[x].sentence_id)
       AND ocsr.active_ind=1)
      JOIN (os
      WHERE os.order_sentence_id=ocsr.order_sentence_id
       AND ((os.oe_format_id+ 0)=tformat_id)
       AND os.usage_flag=1
       AND os.order_encntr_group_cd IN (0, request->sentences[x].encntr_group_code_value))
      JOIN (osd
      WHERE osd.order_sentence_id=os.order_sentence_id)
      JOIN (oef
      WHERE oef.oe_field_id=osd.oe_field_id)
      JOIN (off
      WHERE off.oe_field_id=oef.oe_field_id
       AND off.action_type_cd=action_code
       AND ((off.oe_format_id+ 0)=tformat_id))
      JOIN (f
      WHERE parser(facility_entity_id_parse)
       AND f.parent_entity_name="ORDER_SENTENCE"
       AND f.parent_entity_id=os.order_sentence_id
       AND f.filter_entity1_name="LOCATION")
      JOIN (osf
      WHERE osf.order_sentence_id=outerjoin(os.order_sentence_id))
     ORDER BY os.order_sentence_id, off.group_seq, off.field_seq
     HEAD REPORT
      cnt = 0, tcnt = 0, stat = alterlist(reply->sentences[x].duplicates,10)
     HEAD os.order_sentence_id
      temp_field_code_value = 0, temp_field_disp_value = "", order_sentence = "",
      order_sentence_full = "", gseq = 0, os_value = "",
      dtcnt = 0
     DETAIL
      temp_field_code_value = osd.oe_field_value, temp_field_disp_value = osd.oe_field_display_value,
      dtcnt = (dtcnt+ 1)
      IF (oef.field_type_flag=7)
       IF (temp_field_disp_value IN ("YES", "1"))
        temp_field_disp_value = "Yes"
       ENDIF
       IF (temp_field_disp_value IN ("NO", "0"))
        temp_field_disp_value = "No"
       ENDIF
      ENDIF
      os_value = temp_field_disp_value
      IF (oef.field_type_flag=7)
       IF (temp_field_disp_value="Yes")
        IF (oef.oe_field_meaning_id=prn_id)
         os_value = "PRN"
        ELSE
         IF (off.disp_yes_no_flag IN (0, 1))
          os_value = off.label_text
         ELSE
          os_value = ""
         ENDIF
        ENDIF
       ELSEIF (temp_field_disp_value="No")
        IF (oef.oe_field_meaning_id=prn_id)
         os_value = ""
        ELSE
         IF (off.disp_yes_no_flag IN (0, 2))
          os_value = off.clin_line_label
         ELSE
          os_value = ""
         ENDIF
        ENDIF
       ENDIF
      ELSE
       IF (off.clin_line_label > " ")
        IF (off.clin_suffix_ind=1)
         os_value = concat(trim(temp_field_disp_value)," ",trim(off.clin_line_label))
        ELSE
         os_value = concat(trim(off.clin_line_label)," ",trim(temp_field_disp_value))
        ENDIF
       ENDIF
      ENDIF
      IF (dtcnt=1)
       order_sentence_full = trim(os_value)
       IF (off.clin_line_ind=1)
        order_sentence = trim(os_value)
       ENDIF
       gseq = off.group_seq
      ELSE
       IF (os_value > " ")
        IF (gseq=off.group_seq)
         order_sentence_full = concat(trim(order_sentence_full)," ",trim(os_value))
         IF (off.clin_line_ind=1)
          order_sentence = concat(trim(order_sentence)," ",trim(os_value))
         ENDIF
        ELSE
         order_sentence_full = concat(trim(order_sentence_full),", ",trim(os_value))
         IF (off.clin_line_ind=1)
          order_sentence = concat(trim(order_sentence),", ",trim(os_value))
         ENDIF
         gseq = off.group_seq
        ENDIF
       ENDIF
      ENDIF
     FOOT  os.order_sentence_id
      IF ((request->sentences[x].filter.age_min_value=osf.age_min_value)
       AND (request->sentences[x].filter.age_max_value=osf.age_max_value)
       AND (request->sentences[x].filter.age_code_value=osf.age_unit_cd)
       AND (request->sentences[x].filter.pma_min_value=osf.pma_min_value)
       AND (request->sentences[x].filter.pma_max_value=osf.pma_max_value)
       AND (request->sentences[x].filter.pma_code_value=osf.pma_unit_cd)
       AND (request->sentences[x].filter.weight_min_value=osf.weight_min_value)
       AND (request->sentences[x].filter.weight_max_value=osf.weight_max_value)
       AND (request->sentences[x].filter.weight_code_value=osf.weight_unit_cd))
       IF ((((trim(order_sentence_full,3)=request->sentences[x].sent_display_full)) OR ((os
       .order_sentence_display_line=request->sentences[x].sent_display))) )
        cnt = (cnt+ 1), tcnt = (tcnt+ 1)
        IF (cnt > 10)
         stat = alterlist(reply->sentences[x].duplicates,(tcnt+ 10)), cnt = 1
        ENDIF
        reply->sentences[x].duplicates[tcnt].synonym_id = request->sentences[x].synonym_id, reply->
        sentences[x].duplicates[tcnt].sentence_id = os.order_sentence_id, reply->sentences[x].
        duplicates[tcnt].sent_display = os.order_sentence_display_line,
        reply->sentences[x].duplicates[tcnt].encntr_group_code_value = os.order_encntr_group_cd,
        reply->sentences[x].duplicates[tcnt].oe_format_id = os.oe_format_id, reply->sentences[x].
        duplicates[tcnt].sent_display_full = trim(order_sentence_full,3),
        reply->sentences[x].duplicates[tcnt].filter.age_min_value = osf.age_min_value, reply->
        sentences[x].duplicates[tcnt].filter.age_max_value = osf.age_max_value, reply->sentences[x].
        duplicates[tcnt].filter.age_code_value = osf.age_unit_cd,
        reply->sentences[x].duplicates[tcnt].filter.pma_min_value = osf.pma_min_value, reply->
        sentences[x].duplicates[tcnt].filter.pma_max_value = osf.pma_max_value, reply->sentences[x].
        duplicates[tcnt].filter.pma_code_value = osf.pma_unit_cd,
        reply->sentences[x].duplicates[tcnt].filter.weight_min_value = osf.weight_min_value, reply->
        sentences[x].duplicates[tcnt].filter.weight_max_value = osf.weight_max_value, reply->
        sentences[x].duplicates[tcnt].filter.weight_code_value = osf.weight_unit_cd
       ENDIF
      ENDIF
     FOOT REPORT
      stat = alterlist(reply->sentences[x].duplicates,tcnt)
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
 SUBROUTINE build_facility_code(sentences_index,fsize)
   DECLARE parse_facility_code = vc
   DECLARE factcnt = i2
   DECLARE facility_entity_id_parse = vc
   SET factcnt = 0
   SET parse_facility_code = build(parse_facility_code,"0,")
   FOR (f = 1 TO fsize)
     IF (factcnt > 999)
      SET parse_facility_code = replace(parse_facility_code,",","",2)
      SET parse_facility_code = build(parse_facility_code,") or f.filter_entity1_id IN (")
      SET factcnt = 0
     ENDIF
     SET parse_facility_code = build(parse_facility_code,request->sentences[sentences_index].
      facilities[f].facility_code_value,",")
     SET factcnt = (factcnt+ 1)
   ENDFOR
   SET parse_facility_code = replace(parse_facility_code,",","",2)
   SET facility_entity_id_parse = build(facility_entity_id_parse,"f.filter_entity1_id IN (",
    parse_facility_code,")")
   RETURN(facility_entity_id_parse)
 END ;Subroutine
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
