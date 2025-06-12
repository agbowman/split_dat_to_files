CREATE PROGRAM ams_get_synonym_sentences:dba
 PROMPT
  "synonym_id" = "",
  "user's facility_cd" = ""
  WITH synid, userfaccd
 DECLARE visibile_ind = i2 WITH protect, constant(1)
 DECLARE invisibile_ind = i2 WITH protect, constant(0)
 DECLARE ord_sent_filter_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",30620,"ORDERSENT"))
 DECLARE recordpos = i4 WITH protect
 DECLARE sentpos = i4 WITH protect
 DECLARE commentpos = i4 WITH protect
 DECLARE encntrgrouppos = i4 WITH protect
 DECLARE sentidpos = i4 WITH protect
 DECLARE vvind = i2 WITH protect
 EXECUTE ccl_prompt_api_dataset "AUTOSET", "DATASET", "ADVAPI"
 SELECT INTO "nl:"
  os.order_sentence_display_line, ocsr.display_seq, vv_setting = evaluate(fer.filter_entity_reltn_id,
   0.0,0,1),
  encntr_group = evaluate(os.order_encntr_group_cd,0.0,"All",uar_get_code_display(os
    .order_encntr_group_cd))
  FROM ord_cat_sent_r ocsr,
   order_sentence os,
   (left JOIN filter_entity_reltn fer ON fer.parent_entity_id=os.order_sentence_id
    AND fer.parent_entity_name="ORDER_SENTENCE"
    AND fer.filter_entity1_name="LOCATION"
    AND fer.filter_type_cd=ord_sent_filter_cd
    AND fer.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND fer.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND fer.filter_entity1_id IN (0.0,  $USERFACCD)),
   long_text lt
  PLAN (ocsr
   WHERE (ocsr.synonym_id= $SYNID))
   JOIN (os
   WHERE os.order_sentence_id=ocsr.order_sentence_id
    AND os.parent_entity_id=ocsr.synonym_id
    AND os.parent_entity_name="ORDER_CATALOG_SYNONYM"
    AND os.usage_flag IN (0, 1))
   JOIN (fer)
   JOIN (lt
   WHERE lt.long_text_id=os.ord_comment_long_text_id)
  ORDER BY vv_setting DESC, ocsr.display_seq
  HEAD REPORT
   stat = makedataset(20), sentpos = addstringfield("SENTENCE","Sentence",visibile_ind,255),
   commentpos = addstringfield("COMMENT","Comment",visibile_ind,100),
   encntrgrouppos = addstringfield("ENCOUNTERGROUP","Encounter Group",visibile_ind,40), sentidpos =
   addrealfield("SENTENCE_ID","sentence_id",invisibile_ind), stat = setkeyfield(sentidpos,1)
  DETAIL
   recordpos = getnextrecord(0), stat = setstringfield(recordpos,sentpos,trim(os
     .order_sentence_display_line)), stat = setstringfield(recordpos,commentpos,trim(lt.long_text)),
   stat = setstringfield(recordpos,encntrgrouppos,trim(encntr_group)), stat = setrealfield(recordpos,
    sentidpos,os.order_sentence_id)
   IF (fer.filter_entity_reltn_id > 0.0)
    stat = adddefaultkey(cnvtstring(os.order_sentence_id))
   ENDIF
  FOOT REPORT
   stat = closedataset(0), stat = alterlist(reply->default_key_list,recordpos)
  WITH nocounter, reporthelp, check
 ;end select
END GO
