CREATE PROGRAM bhs_rpt_sn_comp_item:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 DECLARE mf_cs11000_cdm = f8 WITH constant(uar_get_code_by("DISPLAYKEY",11000,"CHARGENUMBER")),
 protect
 DECLARE component_charge_nbr = vc WITH protect
 DECLARE component_desc = vc WITH protect
 DECLARE component_id = vc WITH protect
 DECLARE item_active = i4 WITH protect
 DECLARE bin_desc = vc WITH protect
 DECLARE bin_id = vc WITH protect
 DECLARE class = vc WITH protect
 SELECT INTO  $OUTDEV
  class = substring(1,100,moim.class_name), bin_id = substring(1,100,moim.stock_nbr), bin_desc =
  substring(1,100,moim.description),
  item_active = moim.active_ind, component_id = substring(1,100,moim2.stock_nbr), component_desc =
  substring(1,100,moim2.description),
  component_charge_nbr = substring(1,100,i.value)
  FROM item_component ic,
   mm_omf_item_master moim,
   mm_omf_item_master moim2,
   identifier i
  PLAN (ic)
   JOIN (moim
   WHERE moim.item_master_id=ic.item_id)
   JOIN (moim2
   WHERE moim2.item_master_id=ic.component_id)
   JOIN (i
   WHERE i.parent_entity_id=moim2.item_master_id
    AND i.identifier_type_cd=mf_cs11000_cdm
    AND i.active_ind=1)
  ORDER BY moim.class_name, moim.stock_nbr, moim2.stock_nbr
  WITH nocounter, separator = " ", format
 ;end select
END GO
