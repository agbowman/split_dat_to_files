CREATE PROGRAM bhs_orc_audit:dba
 SET primary_syn_cd = uar_get_code_by("MEANING",6011,"PRIMARY")
 SET bill_code_cd = uar_get_code_by("MEANING",13019,"BILL CODE")
 SELECT DISTINCT
  orc.active_ind, orc.catalog_cd, orc.catalog_type_cd,
  orc.activity_type_cd, orc.oe_format_id, orc.dcp_clin_cat_cd,
  orcs.catalog_cd, orcs.mnemonic, oef.oe_format_id,
  oef.oe_format_name, cs6000.display, cs6000.code_value,
  cs0106.display, cs0106.code_value, bi.bill_item_id,
  bi.ext_parent_reference_id, bim.bill_item_id, bim.bill_item_type_cd,
  bim.key6
  FROM order_catalog orc,
   order_catalog_synonym orcs,
   order_entry_format oef,
   code_value cs6000,
   code_value cs0106,
   bill_item bi,
   bill_item_modifier bim,
   dummyt d
  PLAN (orc
   WHERE orc.active_ind=1)
   JOIN (orcs
   WHERE orc.catalog_cd=orcs.catalog_cd
    AND orcs.mnemonic_type_cd=primary_syn_cd)
   JOIN (oef
   WHERE outerjoin(orc.oe_format_id)=oef.oe_format_id)
   JOIN (cs6000
   WHERE orc.catalog_type_cd=cs6000.code_value)
   JOIN (cs0106
   WHERE orc.activity_type_cd=cs0106.code_value)
   JOIN (bi
   WHERE outerjoin(orc.catalog_cd)=bi.ext_parent_reference_id)
   JOIN (d)
   JOIN (bim
   WHERE bi.bill_item_id=bim.bill_item_id
    AND bim.bill_item_type_cd=bill_code_cd)
  ORDER BY cs6000.display, cs0106.display, orcs.mnemonic
  HEAD REPORT
   col 0, "HNA Mnemonic", col 40,
   "Catalog Type", col 70, "Activity Type",
   col 100, "Order Entry Format", col 140,
   "Bill Code", row + 1
  HEAD orc.catalog_cd
   col 0, orcs.mnemonic
  DETAIL
   fname = trim(oef.oe_format_name), col 40, cs6000.display,
   col 70, cs0106.display, col 100,
   fname, col 140, bim.key6,
   row + 1
  WITH check, noformfeed, format = pcformat,
   outerjoin = d, maxcol = 400
 ;end select
END GO
