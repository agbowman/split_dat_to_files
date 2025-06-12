CREATE PROGRAM ajt_fix_favorites_prn_pain
 FREE RECORD items_2_fix
 RECORD items_2_fix(
   1 list[*]
     2 order_sentence_id = f8
     2 sequence = i4
     2 new_order_sentence_display_line = vc
 )
 DECLARE cnt = i4
 SET cnt = 0
 SELECT
  p.name_full_formatted, alsc.owner_id, alsc.short_description,
  asl.order_sentence_id, asl.synonym_id
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
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,100)=1)
    stat = alterlist(items_2_fix->list,(cnt+ 99))
   ENDIF
   items_2_fix->list[cnt].order_sentence_id = os.order_sentence_id, items_2_fix->list[cnt].sequence
    = osd.sequence, items_2_fix->list[cnt].new_order_sentence_display_line = replace(os
    .order_sentence_display_line,"PRN for Pain,","PRN,",0)
  FOOT REPORT
   stat = alterlist(items_2_fix->list,cnt)
  WITH nocounter
 ;end select
 DELETE  FROM order_sentence_detail osd,
   (dummyt d  WITH seq = value(cnt))
  SET osd.seq = 1
  PLAN (d)
   JOIN (osd
   WHERE (osd.order_sentence_id=items_2_fix->list[d.seq].order_sentence_id)
    AND (osd.sequence=items_2_fix->list[d.seq].sequence))
  WITH counter
 ;end delete
 UPDATE  FROM order_sentence os,
   (dummyt d  WITH seq = value(cnt))
  SET os.order_sentence_display_line = items_2_fix->list[d.seq].new_order_sentence_display_line
  PLAN (d)
   JOIN (os
   WHERE (os.order_sentence_id=items_2_fix->list[d.seq].order_sentence_id))
  WITH counter
 ;end update
END GO
