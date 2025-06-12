CREATE PROGRAM ajt_favorites_prn_pain
 SELECT
  p.name_full_formatted, alsc.short_description, ocs.mnemonic,
  os.order_sentence_display_line, asl.order_sentence_id, asl.synonym_id
  FROM alt_sel_cat alsc,
   alt_sel_list asl,
   order_catalog_synonym ocs,
   order_sentence os,
   order_sentence_detail osd,
   dummyt d2,
   prsnl p
  PLAN (osd
   WHERE osd.default_parent_entity_id=614498
    AND osd.default_parent_entity_name="CODE_VALUE"
    AND osd.oe_field_meaning_id=142
    AND osd.oe_field_id=663786)
   JOIN (os
   WHERE os.order_sentence_id=osd.order_sentence_id
    AND os.parent_entity2_name="ALT_SEL_CAT")
   JOIN (d2)
   JOIN (asl
   WHERE asl.order_sentence_id=os.order_sentence_id)
   JOIN (alsc
   WHERE alsc.alt_sel_category_id=asl.alt_sel_category_id)
   JOIN (ocs
   WHERE ocs.synonym_id=outerjoin(asl.synonym_id))
   JOIN (p
   WHERE p.person_id=alsc.owner_id)
  ORDER BY p.name_full_formatted
 ;end select
END GO
