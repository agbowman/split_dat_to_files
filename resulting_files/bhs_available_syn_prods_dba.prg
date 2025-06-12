CREATE PROGRAM bhs_available_syn_prods:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Mnemonic Type:" = 0
  WITH outdev, type
 FREE RECORD request
 RECORD request(
   1 catalog_cd = f8
   1 synonym_id = f8
   1 route_cd = f8
   1 facility_cd = f8
   1 form_cd = f8
   1 order_type = i2
   1 strength = f8
   1 strength_unit = f8
   1 volume = f8
   1 volume_unit = f8
   1 tier_level = i2
   1 maintain_route_form_ind = i2
   1 med_filter_ind = i2
   1 int_filter_ind = i2
   1 cont_filter_ind = i2
   1 pat_loc_cd = f8
   1 encounter_type_cd = f8
 )
 FREE RECORD out
 RECORD out(
   1 qual[*]
     2 synonym_id = f8
     2 catalog_cd = f8
     2 catdesc = vc
     2 syntype = vc
     2 synmnemonic = vc
 )
 RECORD trueout(
   1 qual[*]
     2 synonym_id = f8
     2 catalog_cd = f8
     2 catdesc = c80
     2 syntype = c80
     2 synmnemonic = c80
     2 proddesc = c80
     2 prdndc = c15
     2 itemid = f8
     2 prodmatch = vc
 )
 SET stat = alterlist(out->qual,1)
 SET count = 0
 SELECT INTO "NL:"
  oc.catalog_cd, oc.description, ocs.synonym_id,
  synonymtype = uar_get_code_display(ocs.mnemonic_type_cd), ocs.mnemonic
  FROM order_catalog oc,
   order_catalog_synonym ocs,
   synonym_item_r sir,
   med_def_flex mdf
  PLAN (oc
   WHERE oc.catalog_type_cd=2516
    AND oc.active_ind=1)
   JOIN (ocs
   WHERE ocs.catalog_cd=oc.catalog_cd
    AND ocs.mnemonic_type_cd IN ( $TYPE)
    AND ((ocs.active_ind+ 0)=1)
    AND  EXISTS (
   (SELECT
    ofr.synonym_id
    FROM ocs_facility_r ofr
    WHERE ofr.synonym_id=ocs.synonym_id)))
   JOIN (sir
   WHERE sir.synonym_id=outerjoin(ocs.synonym_id))
   JOIN (mdf
   WHERE mdf.item_id=outerjoin(sir.item_id)
    AND mdf.active_ind=outerjoin(1)
    AND mdf.flex_type_cd=outerjoin(665857.00)
    AND mdf.sequence=outerjoin(0))
  ORDER BY ocs.catalog_cd, ocs.catalog_type_cd, ocs.synonym_id,
   mdf.item_id DESC
  HEAD ocs.catalog_cd
   stat = 0
  HEAD ocs.synonym_id
   stat = 0
  HEAD mdf.item_id
   IF (mdf.item_id <= 0)
    count = (count+ 1), stat = alterlist(out->qual,count), out->qual[count].synonym_id = ocs
    .synonym_id,
    out->qual[count].catalog_cd = oc.catalog_cd, out->qual[count].catdesc = oc.description, out->
    qual[count].syntype = synonymtype,
    out->qual[count].synmnemonic = ocs.mnemonic
   ENDIF
  WITH nocounter, time = 30
 ;end select
 SET trueoutcnt = 0
 FOR (x = 1 TO count)
   SET request->catalog_cd = out->qual[x].catalog_cd
   SET request->synonym_id = out->qual[x].synonym_id
   FREE RECORD reply
   RECORD reply(
     1 actual_tier_level = i2
     1 product[*]
       2 item_id = f8
       2 description = vc
       2 product_info = vc
       2 route_cd = f8
       2 form_cd = f8
       2 divisible_ind = i2
       2 base_factor = f8
       2 disp_qty = f8
       2 disp_qty_cd = f8
       2 strength = f8
       2 strength_unit_cd = f8
       2 volume = f8
       2 volume_unit_cd = f8
       2 identifier_type_cd = f8
       2 dispense_category_cd = f8
       2 price_sched_id = f8
       2 formulary_status_cd = f8
       2 order_alert1_cd = f8
       2 order_alert2_cd = f8
       2 true_product = i2
       2 alert_qual[*]
         3 order_alert_cd = f8
       2 dispense_factor = f8
       2 infinite_div_ind = i2
       2 med_filter_ind = i2
       2 cont_filter_ind = i2
       2 int_filter_ind = i2
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   EXECUTE bhs_get_items_for_ord_cat
   CALL echo(build("replyStatus: ",reply->status))
   CALL echorecord(reply)
   IF ((reply->status="S"))
    FOR (y = 1 TO size(reply->product,5))
      SET trueoutcnt = (trueoutcnt+ 1)
      SET stat = alterlist(trueout->qual,trueoutcnt)
      SET trueout->qual[trueoutcnt].synonym_id = out->qual[x].synonym_id
      SET trueout->qual[trueoutcnt].catalog_cd = out->qual[x].catalog_cd
      IF (y=1)
       SET trueout->qual[trueoutcnt].catdesc = out->qual[x].catdesc
       SET trueout->qual[trueoutcnt].syntype = out->qual[x].syntype
       SET trueout->qual[trueoutcnt].synmnemonic = out->qual[x].synmnemonic
      ENDIF
      SET trueout->qual[trueoutcnt].proddesc = reply->product[y].description
      SET trueout->qual[trueoutcnt].itemid = reply->product[y].item_id
    ENDFOR
   ENDIF
 ENDFOR
 SELECT INTO "NL:"
  synonym_id = cnvtstring(trueout->qual[d3.seq].synonym_id)
  FROM med_identifier mi,
   (dummyt d3  WITH seq = size(trueout->qual,5))
  PLAN (d3)
   JOIN (mi
   WHERE (mi.item_id=trueout->qual[d3.seq].itemid)
    AND mi.med_identifier_type_cd=3109.00
    AND mi.med_product_id=0
    AND mi.active_ind=1
    AND mi.primary_ind=1)
  ORDER BY synonym_id
  HEAD synonym_id
   tempmnem = trueout->qual[d3.seq].synmnemonic
  DETAIL
   IF (cnvtupper(trim(mi.value,3))=cnvtupper(trim(tempmnem,3)))
    trueout->qual[d3.seq].prodmatch = "X"
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO  $OUTDEV
  syonym_id = cnvtstring(trueout->qual[d3.seq].synonym_id), catalog_cd = cnvtstring(trueout->qual[d3
   .seq].catalog_cd), cat_desc = trueout->qual[d3.seq].catdesc,
  syn_type = trueout->qual[d3.seq].syntype, syn_mnemonic = trueout->qual[d3.seq].synmnemonic,
  prod_desc = trueout->qual[d3.seq].proddesc,
  prod_itemid = trueout->qual[d3.seq].itemid, prod_to_rxmnemonic_match = trueout->qual[d3.seq].
  prodmatch
  FROM (dummyt d3  WITH seq = size(trueout->qual,5))
  PLAN (d3)
  WITH nocounter, separator = " ", format,
   time = 15
 ;end select
 CALL echorecord(trueout,"testinIt")
END GO
