CREATE PROGRAM bhs_rpt_item_master_cdm_lookup
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Item Number" = "*"
  WITH outdev, item
 DECLARE mf_billcode_cd = f8 WITH constant(uar_get_code_by("MEANING",13019,"BILL CODE")), protect
 DECLARE mf_itemmaster_cd = f8 WITH constant(uar_get_code_by("MEANING",11001,"ITEM_MASTER")), protect
 SELECT DISTINCT INTO  $OUTDEV
  m.active_ind, item_number = m.stock_nbr, item_short_desc = m.short_desc,
  item_desc = m.description, cdm_number = b1.key6, bill_item_type = uar_get_code_display(b1
   .bill_item_type_cd)
  FROM mm_omf_item_master m,
   bill_item b,
   bill_item_modifier b1
  PLAN (m
   WHERE m.active_ind=1
    AND m.type_cd=mf_itemmaster_cd
    AND (cnvtupper(m.stock_nbr)= $MS_ITEM))
   JOIN (b
   WHERE b.ext_short_desc=m.stock_nbr)
   JOIN (b1
   WHERE b1.bill_item_id=outerjoin(b.bill_item_id)
    AND b1.bill_item_type_cd=outerjoin(mf_billcode_cd))
  ORDER BY item_number
  WITH nocounter, separator = " ", format
 ;end select
#exit_script
END GO
