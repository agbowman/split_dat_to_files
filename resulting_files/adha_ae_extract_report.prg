CREATE PROGRAM adha_ae_extract_report
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 DECLARE pharmacy_var = f8 WITH constant(uar_get_code_by("MEANING",4062,"PHARMACY")), protect
 DECLARE medproduct_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4063,"MEDPRODUCT")), protect
 DECLARE description_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",11000,"DESCRIPTION")),
 protect
 DECLARE ndc_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",11000,"NDC")), protect
 DECLARE retail_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4500,"RETAIL")), protect
 SELECT INTO  $OUTDEV
  facility = cv.display, ndc = m.value, product_name = m1.value,
  manufacturer = uar_get_code_display(mi.manufacturer_cd)
  FROM med_identifier m,
   med_identifier m1,
   med_flex_object_idx mf,
   med_def_flex md,
   manufacturer_item mi,
   med_product mp,
   code_value cv
  PLAN (m
   WHERE m.med_identifier_type_cd=ndc_var
    AND m.pharmacy_type_cd=retail_var)
   JOIN (m1
   WHERE m.med_product_id=m1.med_product_id
    AND m1.med_identifier_type_cd=description_var
    AND m1.pharmacy_type_cd=r)
   JOIN (mf
   WHERE mf.parent_entity_id=m.med_product_id
    AND mf.flex_object_type_cd=medproduct_var
    AND mf.active_ind=1)
   JOIN (md
   WHERE md.med_def_flex_id=mf.med_def_flex_id
    AND md.pharmacy_type_cd=retail_var
    AND md.flex_type_cd=pharmacy_var
    AND md.active_ind=1)
   JOIN (mp
   WHERE mp.med_product_id=m.med_product_id
    AND mp.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=md.parent_entity_id
    AND cv.active_ind=1)
   JOIN (mi
   WHERE mi.item_id=mp.manf_item_id)
  ORDER BY m.value, m1.value, cv.display
  WITH nocounter, separator = " ", format
 ;end select
 SET lastmod = " 000 07/04/16 MS035369         Initial Release "
END GO
