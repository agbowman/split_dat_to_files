CREATE PROGRAM bhs_syonyms_with_products:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 FREE RECORD request
 RECORD request(
   1 return_all_ind = i2
   1 pharm_type_cd = f8
   1 synonym_list[1]
     2 synonym_id = f8
     2 route_cd = f8
     2 form_cd = f8
     2 facility_cd = f8
     2 encounter_type_cd = f8
     2 pat_loc_cd = f8
     2 med_filter_ind = i2
     2 int_filter_ind = i2
     2 cont_filter_ind = i2
 )
 FREE RECORD out
 RECORD out(
   1 maxprodcnt = i2
   1 qual[*]
     2 synonym_id = f8
     2 catalog_cd = f8
     2 catdesc = c80
     2 syntype = c80
     2 synmnemonic = c80
     2 prodcnt = i2
     2 prod[*]
       3 proddesc = c80
       3 pyxisid = vc
       3 prdndc = c15
       3 itemid = f8
 )
 SET stat = alterlist(out->qual,1)
 SET count = 0
 DECLARE pyxis = f8 WITH protect, constant(uar_get_code_by("MEANING",11000,"PYXIS"))
 DECLARE generic_name = f8 WITH protect, constant(uar_get_code_by("MEANING",11000,"GENERIC_NAME"))
 SELECT INTO "NL:"
  oc.catalog_cd, oc.description, ocs.synonym_id,
  synonymtype = uar_get_code_display(ocs.mnemonic_type_cd), ocs.mnemonic
  FROM order_catalog oc,
   order_catalog_synonym ocs
  PLAN (oc
   WHERE oc.catalog_type_cd=2516
    AND oc.active_ind=1)
   JOIN (ocs
   WHERE ocs.catalog_cd=oc.catalog_cd
    AND ocs.active_ind=1
    AND  EXISTS (
   (SELECT
    sir.synonym_id
    FROM synonym_item_r sir
    WHERE sir.synonym_id=ocs.synonym_id))
    AND  EXISTS (
   (SELECT
    ofr.synonym_id
    FROM ocs_facility_r ofr
    WHERE ofr.synonym_id=ocs.synonym_id)))
  DETAIL
   count = (count+ 1), stat = alterlist(out->qual,count), out->qual[count].synonym_id = ocs
   .synonym_id,
   out->qual[count].catalog_cd = oc.catalog_cd, out->qual[count].catdesc = trim(oc.description,3),
   out->qual[count].syntype = trim(synonymtype,3),
   out->qual[count].synmnemonic = trim(ocs.mnemonic,3)
  WITH nocounter
 ;end select
 FOR (x = 1 TO count)
   SET request->return_all_ind = 1
   SET request->synonym_list[1].synonym_id = out->qual[x].synonym_id
   FREE RECORD reply
   RECORD reply(
     1 synonym_list[*]
       2 synonym_id = f8
       2 product[*]
         3 item_id = f8
         3 description = vc
         3 product_info = vc
         3 route_cd = f8
         3 form_cd = f8
         3 divisible_ind = i2
         3 base_factor = f8
         3 disp_qty = f8
         3 disp_qty_cd = f8
         3 strength = f8
         3 strength_unit_cd = f8
         3 volume = f8
         3 volume_unit_cd = f8
         3 dispense_category_cd = f8
         3 formulary_status_cd = f8
         3 dispense_factor = f8
         3 infinite_div_ind = i2
         3 med_filter_ind = i2
         3 int_filter_ind = i2
         3 cont_filter_ind = i2
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   EXECUTE bhs_get_items_for_synonym
   CALL echo(reply->status)
   IF ((reply->status="S"))
    SET stat = alterlist(out->qual[x].prod,size(reply->synonym_list[1].product,5))
    SET out->qual[x].prodcnt = size(reply->synonym_list[1].product,5)
    IF ((out->qual[x].prodcnt >= out->maxprodcnt))
     SET out->maxprodcnt = out->qual[x].prodcnt
    ENDIF
    FOR (y = 1 TO size(reply->synonym_list[1].product,5))
      SET out->qual[x].prod[y].proddesc = reply->synonym_list[1].product[y].description
      CALL echo(out->qual[x].prod[y].proddesc)
      SET out->qual[x].prod[y].itemid = reply->synonym_list[1].product[y].item_id
    ENDFOR
   ENDIF
 ENDFOR
 SELECT INTO  $OUTDEV
  syonym_id = out->qual[d3.seq].synonym_id, catalog_cd = out->qual[d3.seq].catalog_cd, cat_desc = out
  ->qual[d3.seq].catdesc,
  syn_type = out->qual[d3.seq].syntype, syn_mnemonic = out->qual[d3.seq].synmnemonic, gen_name =
  substring(0,80,mi2.value),
  prod_itemid = out->qual[d3.seq].prod[d4.seq].itemid, pyxis_id = mi.value, dttm = format(sir
   .updt_dt_tm,";;q")
  FROM (dummyt d3  WITH seq = size(out->qual,5)),
   (dummyt d4  WITH seq = out->maxprodcnt),
   dummyt d5,
   med_identifier mi,
   med_identifier mi2,
   synonym_item_r sir
  PLAN (d3)
   JOIN (d4
   WHERE (d4.seq <= out->qual[d3.seq].prodcnt)
    AND (out->qual[d3.seq].prod[d4.seq].itemid > 0))
   JOIN (mi2
   WHERE mi2.item_id=outerjoin(out->qual[d3.seq].prod[d4.seq].itemid)
    AND mi2.med_identifier_type_cd=outerjoin(generic_name)
    AND mi2.primary_ind=outerjoin(1)
    AND mi2.med_product_id=outerjoin(0)
    AND mi2.active_ind=outerjoin(1))
   JOIN (d5)
   JOIN (sir
   WHERE (sir.item_id=out->qual[d3.seq].prod[d4.seq].itemid)
    AND (sir.synonym_id=out->qual[d3.seq].synonym_id))
   JOIN (mi
   WHERE (mi.item_id=out->qual[d3.seq].prod[d4.seq].itemid)
    AND mi.med_identifier_type_cd=pyxis
    AND mi.primary_ind=1
    AND mi.med_product_id=0
    AND mi.active_ind=1)
  ORDER BY sir.updt_dt_tm
  WITH nocounter, separator = " ", format,
   time = 15, outerjoin = d5
 ;end select
END GO
