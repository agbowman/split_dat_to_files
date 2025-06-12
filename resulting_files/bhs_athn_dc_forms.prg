CREATE PROGRAM bhs_athn_dc_forms
 RECORD orequest(
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
   1 multum_mmdc_cki = vc
   1 ndc_list[*]
     2 ndc = vc
   1 med_product_ind = i2
   1 no_compounds_ind = i2
   1 use_prod_assign_ind = i2
   1 product_filter_ind = i2
 )
 RECORD oreply(
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
     2 med_type_flag = i2
     2 med_product_qual[*]
       3 manf_item_id = f8
       3 sequence = i2
       3 active_ind = i2
       3 brand_ind = i2
       3 ndc = vc
       3 manufacturer_cd = f8
       3 manufacturer_name = vc
       3 med_product_id = f8
       3 innerndcqual[*]
         4 inner_ndc = vc
     2 prod_assign_flag = i2
   1 product_filter_applied = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD prequest(
   1 synonym_cki = vc
 )
 RECORD preply(
   1 synonym_list[*]
     2 synonym_id = f8
     2 mnemonic = vc
     2 mnemonic_type_cd = f8
     2 mnemonic_type_disp = vc
     2 mnemonic_type_mean = c12
     2 cki = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD out_rec(
   1 meds[*]
     2 med = vc
 )
 SELECT INTO "nl:"
  FROM encounter e
  PLAN (e
   WHERE (e.encntr_id= $2))
  HEAD REPORT
   orequest->facility_cd = e.loc_facility_cd
  WITH nocounter, time = 30
 ;end select
 SELECT INTO "nl:"
  FROM order_catalog_synonym ocs
  PLAN (ocs
   WHERE (ocs.synonym_id= $3))
  HEAD REPORT
   orequest->catalog_cd = ocs.catalog_cd, prequest->synonym_cki = ocs.cki
  WITH nocounter, time = 30
 ;end select
 IF ((prequest->synonym_cki <= " "))
  SET stat = tdbexecute(600005,500199,380023,"REC",orequest,
   "REC",oreply)
  SET stat = alterlist(out_rec->meds,size(oreply->product,5))
  FOR (i = 0 TO size(oreply->product,5))
    SET out_rec->meds[i].med = oreply->product[i].description
  ENDFOR
  GO TO end_script
 ENDIF
 IF ((prequest->synonym_cki >= " "))
  SET stat = tdbexecute(600005,500199,965281,"REC",prequest,
   "REC",preply)
  SET stat = alterlist(out_rec->meds,size(preply->synonym_list,5))
  FOR (i = 0 TO size(preply->synonym_list,5))
    SET out_rec->meds[i].med = preply->synonym_list[i].mnemonic
  ENDFOR
  GO TO end_script
 ENDIF
#end_script
 SET memory_reply_string = cnvtrectojson(out_rec)
END GO
