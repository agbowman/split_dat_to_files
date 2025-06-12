CREATE PROGRAM ajt_careset_prn_pain
 PROMPT
  "Output to File/Printer/MINE" = mine
 SELECT INTO  $1
  oc.description, oc.primary_mnemonic, ocs.mnemonic,
  os.order_sentence_display_line
  FROM order_sentence_detail osd,
   order_sentence os,
   order_catalog_synonym ocs,
   cs_component cc,
   order_catalog oc,
   dummyt d
  PLAN (oc
   WHERE oc.orderable_type_flag=6
    AND oc.active_ind=1)
   JOIN (d)
   JOIN (cc
   WHERE cc.catalog_cd=oc.catalog_cd)
   JOIN (ocs
   WHERE ocs.synonym_id=cc.comp_id)
   JOIN (os
   WHERE cc.order_sentence_id=os.order_sentence_id)
   JOIN (osd
   WHERE os.order_sentence_id=osd.order_sentence_id
    AND osd.oe_field_meaning_id=142
    AND osd.default_parent_entity_name="CODE_VALUE"
    AND osd.default_parent_entity_id=614498)
  ORDER BY oc.description, ocs.mnemonic, os.order_sentence_display_line
  HEAD oc.description
   row + 0
  DETAIL
   care_set = substring(1,40,oc.description), col 1, oc.primary_mnemonic,
   mnemonic = substring(1,30,ocs.mnemonic), col 45, mnemonic,
   ord_sent = substring(1,80,os.order_sentence_display_line), col 80, ord_sent,
   col 170, osd.order_sentence_id, col 185,
   osd.sequence, row + 1
  WITH maxcol = 250
 ;end select
END GO
