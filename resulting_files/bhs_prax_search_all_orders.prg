CREATE PROGRAM bhs_prax_search_all_orders
 DECLARE smart_string = vc
 DECLARE input_string = vc
 SET input_string = cnvtupper(trim( $2))
 DECLARE displaytext = vc
 SET input_string = replace(input_string,"^","&")
 SET where_params = build("CNVTUPPER(OC.PRIMARY_MNEMONIC) = ","'*",cnvtupper(input_string),"*'"," ")
 IF (( $3="0"))
  SET where_params2 = build("O.catalog_type_cd != 2516 ")
 ELSE
  SET where_params2 = build("O.dcp_clin_cat_cd IN"," ", $3," ")
 ENDIF
 SET where_params1 = build(" OS.ORDER_ENCNTR_GROUP_CD = OUTERJOIN(", $5,")")
 DECLARE primary = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6011,"PRIMARY"))
 DECLARE directcare = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6011,
   "DIRECTCAREPROVIDER"))
 DECLARE torder = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6016,"ORDER"))
 DECLARE tvieworder = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6016,"VIEWORDER"))
 SELECT INTO  $1
  o.synonym_id, mnemonic = trim(replace(replace(replace(replace(replace(o.mnemonic,"&","&amp;",0),"<",
       "&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), pr_mnemonic = trim(replace(replace
    (replace(replace(replace(oc.primary_mnemonic,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
     "&apos;",0),'"',"&quot;",0),3),
  display_line = trim(replace(replace(replace(replace(replace(os.order_sentence_display_line,"&",
        "&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), o.catalog_cd,
  o_activity_type_disp = trim(replace(replace(replace(replace(replace(uar_get_code_display(o
         .activity_type_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0
    ),3),
  o.activity_subtype_cd, os.order_sentence_id, field_display_value = trim(replace(replace(replace(
      replace(replace(osd.oe_field_display_value,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
     "&apos;",0),'"',"&quot;",0),3),
  osd.oe_field_id, osd.oe_field_meaning_id, osd.oe_field_value,
  attribute_name = trim(replace(replace(replace(replace(replace(oe.description,"&","&amp;",0),"<",
       "&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), encntr_group = trim(replace(
    replace(replace(replace(replace(uar_get_code_display(os.order_encntr_group_cd),"&","&amp;",0),"<",
       "&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), def_comment = substring(1,500,trim
   (replace(replace(replace(replace(replace(l.long_text,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),
      "'","&apos;",0),'"',"&quot;",0),3)),
  oc.dup_checking_ind, d.dup_check_seq, d_exact_hit_action_disp = uar_get_code_display(d
   .exact_hit_action_cd),
  d.min_ahead, d_min_ahead_action_disp = uar_get_code_display(d.min_ahead_action_cd), d.min_behind,
  d_min_behind_action_disp = uar_get_code_display(d.min_behind_action_cd), oc
  .disable_order_comment_ind, oc.stop_type_cd,
  oc_stop_type_meaning = uar_get_code_meaning(oc.stop_type_cd), oc.stop_duration, oc
  .stop_duration_unit_cd,
  stop_duration_unit = uar_get_code_meaning(oc.stop_duration_unit_cd)
  FROM order_catalog_synonym o,
   order_sentence os,
   ocs_facility_r ofr,
   order_sentence_detail osd,
   order_entry_fields oe,
   order_catalog_text oct,
   long_text l,
   order_catalog oc,
   dup_checking d
  PLAN (o
   WHERE parser(where_params2)
    AND o.active_ind=1
    AND o.active_status_cd=188
    AND o.hide_flag=0
    AND o.mnemonic_type_cd IN (2583, 2581)
    AND o.oe_format_id != 0)
   JOIN (ofr
   WHERE ofr.synonym_id=outerjoin(o.synonym_id)
    AND (((ofr.facility_cd= $6)) OR (ofr.facility_cd=0)) )
   JOIN (os
   WHERE os.parent_entity_id=outerjoin(o.synonym_id)
    AND os.parent_entity_name=outerjoin("ORDER_CATALOG_SYNONYM")
    AND os.parent_entity2_id=outerjoin(0.0)
    AND parser(where_params1))
   JOIN (osd
   WHERE osd.order_sentence_id=outerjoin(os.order_sentence_id))
   JOIN (oe
   WHERE oe.oe_field_id=outerjoin(osd.oe_field_id))
   JOIN (oct
   WHERE oct.catalog_cd=outerjoin(o.catalog_cd))
   JOIN (l
   WHERE l.long_text_id=outerjoin(oct.long_text_id))
   JOIN (oc
   WHERE oc.catalog_cd=o.catalog_cd
    AND parser(where_params))
   JOIN (d
   WHERE d.catalog_cd=outerjoin(o.catalog_cd)
    AND d.active_ind=outerjoin(1))
  ORDER BY o.synonym_id, os.order_sentence_id
  HEAD REPORT
   html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
    '"',"UTF-8",'"'," ?>"), col 0, html_tag,
   row + 1, col + 1, "<ReplyMessage>",
   row + 1
  HEAD o.synonym_id
   col + 1, "<OrderSynonyms>", row + 1,
   v1 = build("<SynonymID>",cnvtint(o.synonym_id),"</SynonymID>"), col + 1, v1,
   row + 1
   IF (pr_mnemonic=mnemonic)
    displaytext = build(pr_mnemonic)
   ELSE
    displaytext = build(pr_mnemonic," (",mnemonic,")")
   ENDIF
   IF (textlen(displaytext) > 100)
    v2 = build("<Mnemonic>",pr_mnemonic,"</Mnemonic>")
   ELSE
    v2 = build("<Mnemonic>",displaytext,"</Mnemonic>")
   ENDIF
   col + 1, v2, row + 1,
   v3 = build("<CatalogCD>",cnvtint(o.catalog_cd),"</CatalogCD>"), col + 1, v3,
   row + 1, v4 = build("<CatalogTypeCode>",cnvtint(o.catalog_type_cd),"</CatalogTypeCode>"), col + 1,
   v4, row + 1, v5 = build("<ActivityTypeCd>",cnvtint(o.activity_type_cd),"</ActivityTypeCd>"),
   col + 1, v5, row + 1,
   v6 = build("<ActivityTypeDisplay>",o_activity_type_disp,"</ActivityTypeDisplay>"), col + 1, v6,
   row + 1, v61 = build("<ActivitySubType>",cnvtint(o.activity_subtype_cd),"</ActivitySubType>"), col
    + 1,
   v61, row + 1, v63 = build("<StopTypeCd>",cnvtint(oc.stop_type_cd),"</StopTypeCd>"),
   col + 1, v63, row + 1,
   v64 = build("<StopTypeMeaning>",oc_stop_type_meaning,"</StopTypeMeaning>"), col + 1, v64,
   row + 1, v65 = build("<StopDuration>",cnvtint(oc.stop_duration),"</StopDuration>"), col + 1,
   v65, row + 1, v66 = build("<StopDurationUnitCd>",cnvtint(oc.stop_duration_unit_cd),
    "</StopDurationUnitCd>"),
   col + 1, v66, row + 1,
   v67 = build("<StopDurationUnit>",stop_duration_unit,"</StopDurationUnit>"), col + 1, v67,
   row + 1, v7 = build("<MultipleOrderSentInd>",o.multiple_ord_sent_ind,"</MultipleOrderSentInd>"),
   col + 1,
   v7, row + 1, v8 = build("<WitnesssFlag>",o.witness_flag,"</WitnesssFlag>"),
   col + 1, v8, row + 1,
   v62 = build("<ClinicalCategoryCd>",o.dcp_clin_cat_cd,"</ClinicalCategoryCd>"), col + 1, v62,
   row + 1, v11 = build("<OrderFormatId>",cnvtint(o.oe_format_id),"</OrderFormatId>"), col + 1,
   v11, row + 1, v16 = build("<OrderComment>",def_comment,"</OrderComment>"),
   col + 1, v16, row + 1,
   v17 = build("<DupOrderCheckInd>",cnvtint(oc.dup_checking_ind),"</DupOrderCheckInd>"), col + 1, v17,
   row + 1, v18 = build("<ExactHitAction>",d_exact_hit_action_disp,"</ExactHitAction>"), col + 1,
   v18, row + 1, v19 = build("<MinAhead>",cnvtint(d.min_ahead),"</MinAhead>"),
   col + 1, v19, row + 1,
   v20 = build("<MinAheadAction>",d_min_ahead_action_disp,"</MinAheadAction>"), col + 1, v20,
   row + 1, v21 = build("<MinBehind>",cnvtint(d.min_behind),"</MinBehind>"), col + 1,
   v21, row + 1, v22 = build("<MinBehindAction>",d_min_behind_action_disp,"</MinBehindAction>"),
   col + 1, v22, row + 1,
   v23 = build("<DisableOrderCommentFlag>",cnvtint(oc.disable_order_comment_ind),
    "</DisableOrderCommentFlag>"), col + 1, v23,
   row + 1, v24 = build("<DupCheckSequence>",cnvtint(d.dup_check_seq),"</DupCheckSequence>"), col + 1,
   v24, row + 1
  HEAD os.order_sentence_id
   col + 1, "<OrderSentences>", row + 1,
   v16 = build("<EncounterGroup>",encntr_group,"</EncounterGroup>"), col + 1, v16,
   row + 1, v9 = build("<OrderSentenceDisplayLine>",display_line,"</OrderSentenceDisplayLine>"), col
    + 1,
   v9, row + 1, v10 = build("<OrderSentenceId>",cnvtint(os.order_sentence_id),"</OrderSentenceId>"),
   col + 1, v10, row + 1
  DETAIL
   col + 1, "<OrderSentence>", row + 1,
   v11 = build("<FieldMeaningId>",cnvtint(osd.oe_field_meaning_id),"</FieldMeaningId>"), col + 1, v11,
   row + 1, v12 = build("<FieldId>",cnvtint(osd.oe_field_id),"</FieldId>"), col + 1,
   v12, row + 1, v13 = build("<AttributeName>",attribute_name,"</AttributeName>"),
   col + 1, v13, row + 1,
   v14 = build("<DisplayValue>",field_display_value,"</DisplayValue>"), col + 1, v14,
   row + 1, v15 = build("<Value>",cnvtint(osd.default_parent_entity_id),"</Value>"), col + 1,
   v15, row + 1, col + 1,
   "</OrderSentence>", row + 1
  FOOT  os.order_sentence_id
   col + 1, "</OrderSentences>", row + 1
  FOOT  o.synonym_id
   col + 1, "</OrderSynonyms>", row + 1
  FOOT REPORT
   row + 1, col + 1, "</ReplyMessage>",
   row + 1
  WITH maxcol = 32000, maxrow = 0, nocounter,
   nullreport, formfeed = none, format = variable,
   time = 30
 ;end select
END GO
