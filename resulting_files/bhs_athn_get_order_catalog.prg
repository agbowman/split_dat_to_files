CREATE PROGRAM bhs_athn_get_order_catalog
 DECLARE v303 = vc
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
  osd.oe_field_id, osd.oe_field_meaning_id, osd_oe_field_value =
  IF (osd.default_parent_entity_name="CODE_VALUE") osd.default_parent_entity_id
  ELSE
   IF (osd.oe_field_value > 0) osd.oe_field_value
   ELSE 0
   ENDIF
  ENDIF
  ,
  attribute_name = trim(replace(replace(replace(replace(replace(oe.description,"&","&amp;",0),"<",
       "&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), encntr_group = trim(replace(
    replace(replace(replace(replace(uar_get_code_display(os.order_encntr_group_cd),"&","&amp;",0),"<",
       "&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), def_ord_comment = substring(1,500,
   trim(replace(replace(replace(replace(replace(l.long_text,"&","&amp;",0),"<","&lt;",0),">","&gt;",0
       ),"'","&apos;",0),'"',"&quot;",0),3)),
  def_sen_comment = substring(1,500,trim(replace(replace(replace(replace(replace(ll.long_text,"&",
         "&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3)), oc
  .dup_checking_ind, d.dup_check_seq,
  d_exact_hit_action_disp = uar_get_code_display(d.exact_hit_action_cd), d.min_ahead,
  d_min_ahead_action_disp = uar_get_code_display(d.min_ahead_action_cd),
  d.min_behind, d_min_behind_action_disp = uar_get_code_display(d.min_behind_action_cd), d
  .outpat_flex_ind,
  d_outpat_exact_hit_action_disp = uar_get_code_display(d.outpat_exact_hit_action_cd), d
  .outpat_min_ahead, d_outpat_min_ahead_action_disp = uar_get_code_display(d
   .outpat_min_ahead_action_cd),
  d.outpat_min_behind, d_outpat_min_behind_action_disp = uar_get_code_display(d
   .outpat_min_behind_action_cd), oc.disable_order_comment_ind,
  oc.stop_type_cd, oc_stop_type_meaning = uar_get_code_meaning(oc.stop_type_cd), oc.stop_duration,
  oc.stop_duration_unit_cd, stop_duration_unit = uar_get_code_meaning(oc.stop_duration_unit_cd)
  FROM order_catalog_synonym o,
   order_sentence os,
   order_sentence_detail osd,
   order_entry_fields oe,
   order_catalog_text oct,
   long_text l,
   long_text ll,
   order_catalog oc,
   dup_checking d,
   cs_component cs
  PLAN (o
   WHERE (o.synonym_id= $2))
   JOIN (os
   WHERE (os.parent_entity_id= Outerjoin(o.synonym_id))
    AND (os.order_sentence_id= Outerjoin( $3)) )
   JOIN (osd
   WHERE (osd.order_sentence_id= Outerjoin(os.order_sentence_id)) )
   JOIN (oe
   WHERE (oe.oe_field_id= Outerjoin(osd.oe_field_id)) )
   JOIN (oct
   WHERE (oct.catalog_cd= Outerjoin(o.catalog_cd)) )
   JOIN (l
   WHERE (l.long_text_id= Outerjoin(oct.long_text_id)) )
   JOIN (oc
   WHERE oc.catalog_cd=o.catalog_cd)
   JOIN (d
   WHERE (d.catalog_cd= Outerjoin(o.catalog_cd))
    AND (d.active_ind= Outerjoin(1)) )
   JOIN (ll
   WHERE (ll.long_text_id= Outerjoin(os.ord_comment_long_text_id)) )
   JOIN (cs
   WHERE (cs.catalog_cd= Outerjoin(o.catalog_cd)) )
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
    v2 = build("<Mnemonic>",trim(replace(pr_mnemonic,"Â ","",0),3),"</Mnemonic>")
   ELSE
    v2 = build("<Mnemonic>",trim(replace(displaytext,"Â ","",0),3),"</Mnemonic>")
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
   row + 1, v621 = build("<SynonymCKI>",trim(replace(replace(replace(replace(replace(o.cki,"&",
          "&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</SynonymCKI>"),
   col + 1,
   v621, row + 1, v622 = build("<CatalogCKI>",trim(replace(replace(replace(replace(replace(oc.cki,"&",
          "&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</CatalogCKI>"),
   col + 1, v622, row + 1,
   v623 = build("<roundingRuleCd>",cnvtint(o.rounding_rule_cd),"</roundingRuleCd>"), col + 1, v623,
   row + 1, v624 = build("<lockTargetDoseInd>",cnvtint(o.lock_target_dose_ind),"</lockTargetDoseInd>"
    ), col + 1,
   v624, row + 1, v625 = build("<maxDoseCalcBSAValue>",o.max_dose_calc_bsa_value,
    "</maxDoseCalcBSAValue>"),
   col + 1, v625, row + 1,
   v626 = build("<maxFinalDose>",o.max_final_dose,"</maxFinalDose>"), col + 1, v626,
   row + 1, v627 = build("<maxFinalDoseUnitCd>",cnvtint(o.max_final_dose_unit_cd),
    "</maxFinalDoseUnitCd>"), col + 1,
   v627, row + 1, v628 = build("<preferredDoseFlag>",cnvtint(o.preferred_dose_flag),
    "</preferredDoseFlag>"),
   col + 1, v628, row + 1,
   v11 = build("<OrderFormatId>",cnvtint(o.oe_format_id),"</OrderFormatId>"), col + 1, v11,
   row + 1, v16 = build("<OrderComment>",
    IF (def_sen_comment != " ") trim(replace(def_sen_comment,"–","-",0),3)
    ELSE trim(replace(def_ord_comment,"–","-",0),3)
    ENDIF
    ,"</OrderComment>"), col + 1,
   v16, row + 1, v161 = build("<lockDownDetailsFlag>",cnvtint(cs.lockdown_details_flag),
    "</lockDownDetailsFlag>"),
   col + 1, v161, row + 1,
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
   v24, row + 1, v241 = build("<OutpatFlexIndicator>",d.outpat_flex_ind,"</OutpatFlexIndicator>"),
   col + 1, v241, row + 1,
   v242 = build("<OutpatExactHitAction>",d_outpat_exact_hit_action_disp,"</OutpatExactHitAction>"),
   col + 1, v242,
   row + 1, v243 = build("<OutpatMinAhead>",cnvtstring(d.outpat_min_ahead),"</OutpatMinAhead>"), col
    + 1,
   v243, row + 1, v244 = build("<OutpatMinAheadAction>",d_outpat_min_ahead_action_disp,
    "</OutpatMinAheadAction>"),
   col + 1, v244, row + 1,
   v245 = build("<OutpatMinBehind>",cnvtstring(d.outpat_min_behind),"</OutpatMinBehind>"), col + 1,
   v245,
   row + 1, v246 = build("<OutpatMinBehindAction>",d_outpat_min_behind_action_disp,
    "</OutpatMinBehindAction>"), col + 1,
   v246, row + 1, col + 1,
   "<Catalog>", row + 1, v301 = build("<Value>",cnvtint(o.catalog_cd),"</Value>"),
   col + 1, v301, row + 1,
   v302 = build("<Meaning>",trim(replace(replace(replace(replace(replace(uar_get_code_meaning(o
           .catalog_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
    "</Meaning>"), col + 1, v302,
   row + 1, v303 = build("<Display>",trim(replace(replace(replace(replace(replace(replace(
           uar_get_code_display(o.catalog_cd),"Ã‚Â ","",0),"&","&amp;",0),"<","&lt;",0),">",
        "&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</Display>"), col + 1,
   v303, row + 1, col + 1,
   "</Catalog>", row + 1, col + 1,
   "<CatalogType>", row + 1, v401 = build("<Value>",cnvtint(o.catalog_type_cd),"</Value>"),
   col + 1, v401, row + 1,
   v402 = build("<Meaning>",trim(replace(replace(replace(replace(replace(uar_get_code_meaning(o
           .catalog_type_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",
      0),3),"</Meaning>"), col + 1, v402,
   row + 1, v403 = build("<Display>",trim(replace(replace(replace(replace(replace(
          uar_get_code_display(o.catalog_type_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
       "&apos;",0),'"',"&quot;",0),3),"</Display>"), col + 1,
   v403, row + 1, col + 1,
   "</CatalogType>", row + 1, col + 1,
   "<ActivityType>", row + 1, v501 = build("<Value>",cnvtint(o.activity_type_cd),"</Value>"),
   col + 1, v501, row + 1,
   v502 = build("<Meaning>",trim(replace(replace(replace(replace(replace(uar_get_code_meaning(o
           .activity_type_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",
      0),3),"</Meaning>"), col + 1, v502,
   row + 1, v503 = build("<Display>",trim(replace(replace(replace(replace(replace(
          uar_get_code_display(o.activity_type_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
       "&apos;",0),'"',"&quot;",0),3),"</Display>"), col + 1,
   v503, row + 1, col + 1,
   "</ActivityType>", row + 1, col + 1,
   "<ActivitySubTypeCD>", row + 1, v601 = build("<Value>",cnvtint(o.activity_subtype_cd),"</Value>"),
   col + 1, v601, row + 1,
   v602 = build("<Meaning>",trim(replace(replace(replace(replace(replace(uar_get_code_meaning(o
           .activity_subtype_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
      "&quot;",0),3),"</Meaning>"), col + 1, v602,
   row + 1, v603 = build("<Display>",trim(replace(replace(replace(replace(replace(
          uar_get_code_display(o.activity_subtype_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
       "&apos;",0),'"',"&quot;",0),3),"</Display>"), col + 1,
   v603, row + 1, col + 1,
   "</ActivitySubTypeCD>", row + 1, col + 1,
   "<ClinicalCategory>", row + 1, v701 = build("<Value>",cnvtint(o.dcp_clin_cat_cd),"</Value>"),
   col + 1, v701, row + 1,
   v702 = build("<Meaning>",trim(replace(replace(replace(replace(replace(uar_get_code_meaning(o
           .dcp_clin_cat_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",
      0),3),"</Meaning>"), col + 1, v702,
   row + 1, v703 = build("<Display>",trim(replace(replace(replace(replace(replace(
          uar_get_code_display(o.dcp_clin_cat_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
       "&apos;",0),'"',"&quot;",0),3),"</Display>"), col + 1,
   v703, row + 1, col + 1,
   "</ClinicalCategory>", row + 1, col + 1,
   "<StopType>", row + 1, v801 = build("<Value>",cnvtint(oc.stop_type_cd),"</Value>"),
   col + 1, v801, row + 1,
   v802 = build("<Meaning>",trim(replace(replace(replace(replace(replace(uar_get_code_meaning(oc
           .stop_type_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),
     3),"</Meaning>"), col + 1, v802,
   row + 1, v803 = build("<Display>",trim(replace(replace(replace(replace(replace(
          uar_get_code_display(oc.stop_type_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
       "&apos;",0),'"',"&quot;",0),3),"</Display>"), col + 1,
   v803, row + 1, col + 1,
   "</StopType>", row + 1, col + 1,
   "<PharmacyType>", row + 1, v804 = build("<DiluentInd>",evaluate(band(o.rx_mask,1),0,0,1),
    "</DiluentInd>"),
   col + 1, v804, row + 1,
   v805 = build("<AdditiveInd>",evaluate(band(o.rx_mask,2),0,0,1),"</AdditiveInd>"), col + 1, v805,
   row + 1, v806 = build("<MedInd>",evaluate(band(o.rx_mask,4),0,0,1),"</MedInd>"), col + 1,
   v806, row + 1, col + 1,
   "</PharmacyType>", row + 1, v900 = build("<TitrateableInd>",o.ingredient_rate_conversion_ind,
    "</TitrateableInd>"),
   col + 1, v900, row + 1,
   v901 = build("<ModifiableFlag>",oc.modifiable_flag,"</ModifiableFlag>"), col + 1, v901,
   row + 1, col + 1, "<OrderSentencesList>",
   row + 1
  HEAD os.order_sentence_id
   col + 1, "<OrderSentences>", row + 1,
   v16 = build("<EncounterGroup>",encntr_group,"</EncounterGroup>"), col + 1, v16,
   row + 1, v9 = build("<OrderSentenceDisplayLine>",display_line,"</OrderSentenceDisplayLine>"), col
    + 1,
   v9, row + 1
   IF (os.order_sentence_id != 0)
    v10 = build("<OrderSentenceId>",cnvtint(os.order_sentence_id),"</OrderSentenceId>"), col + 1, v10,
    row + 1
   ENDIF
   col + 1, "<OrderSentenceList>", row + 1
  DETAIL
   col + 1, "<OrderSentence>", row + 1
   IF (os.order_sentence_id != 0)
    v11 = build("<FieldMeaningId>",cnvtint(osd.oe_field_meaning_id),"</FieldMeaningId>"), col + 1,
    v11,
    row + 1, v12 = build("<FieldId>",cnvtint(osd.oe_field_id),"</FieldId>"), col + 1,
    v12, row + 1, v13 = build("<AttributeName>",attribute_name,"</AttributeName>"),
    col + 1, v13, row + 1,
    v14 = build("<DisplayValue>",field_display_value,"</DisplayValue>"), col + 1, v14,
    row + 1, v15 = build("<Value>",cnvtint(osd_oe_field_value),"</Value>"), col + 1,
    v15, row + 1
   ENDIF
   col + 1, "</OrderSentence>", row + 1
  FOOT  os.order_sentence_id
   col + 1, "</OrderSentenceList>", row + 1,
   col + 1, "</OrderSentences>", row + 1
  FOOT  o.synonym_id
   col + 1, "</OrderSentencesList>", row + 1,
   col + 1, "</OrderSynonyms>", row + 1
  FOOT REPORT
   row + 1, col + 1, "</ReplyMessage>",
   row + 1
  WITH maxcol = 32000, maxrow = 0, nocounter,
   nullreport, formfeed = none, format = variable,
   time = 30
 ;end select
END GO
