CREATE PROGRAM bhs_rad_boaudit_chgrpt
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 DECLARE mf_rad_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",106,"RADIOLOGY"))
 DECLARE mf_bo_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",13019,"BILLCODE"))
 SELECT DISTINCT INTO  $OUTDEV
  procedure_description = b.ext_description, cdm_cpt = bi.key6, charge_description = bi.key7
  FROM bill_item b,
   bill_item_modifier bi
  PLAN (b
   WHERE b.ext_owner_cd=mf_rad_cd
    AND b.active_ind=1
    AND b.ext_parent_reference_id=0)
   JOIN (bi
   WHERE b.bill_item_id=bi.bill_item_id
    AND bi.active_ind=1
    AND bi.bill_item_type_cd=mf_bo_cd)
  ORDER BY b.ext_parent_entity_name, b.ext_parent_reference_id, b.ext_short_desc DESC
  WITH nocounter, separator = " ", format
 ;end select
END GO
