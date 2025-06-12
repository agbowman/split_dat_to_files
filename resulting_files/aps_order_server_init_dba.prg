CREATE PROGRAM aps_order_server_init:dba
 CALL echo("Creating persistent record structure to hold order format information.")
 SET trace = recpersist
 RECORD order_encntr_info(
   1 encntr_id = f8
   1 encntr_financial_id = f8
   1 location_cd = f8
   1 loc_facility_cd = f8
   1 loc_nurse_unit_cd = f8
   1 loc_room_cd = f8
   1 loc_bed_cd = f8
 )
 RECORD oe_format_info(
   1 communication_type_cd = f8
   1 qual[*]
     2 catalog_cd = f8
     2 primary_mnemonic = vc
     2 dept_display_name = vc
     2 activity_type_cd = f8
     2 activity_subtype_cd = f8
     2 cont_order_method_flag = i2
     2 complete_upon_order_ind = i2
     2 order_review_ind = i2
     2 print_req_ind = i2
     2 requisition_format_cd = f8
     2 requisition_routing_cd = f8
     2 resource_route_lvl = i4
     2 consent_form_ind = i2
     2 consent_form_format_cd = f8
     2 consent_form_routing_cd = f8
     2 dept_dup_check_ind = i2
     2 abn_review_ind = i2
     2 review_hierarchy_id = f8
     2 ref_text_mask = i4
     2 dup_checking_ind = i2
     2 orderable_type_flag = i2
     2 action_type_cd = f8
     2 catalog_type_cd = f8
     2 synonym_id = f8
     2 mnemonic = vc
     2 oe_format_id = f8
     2 fldqual_cnt = i4
     2 fldqual[*]
       3 oe_field_id = f8
       3 oe_field_meaning_id = f8
       3 oe_field_meaning = c25
       3 group_seq = i4
       3 field_seq = i4
       3 value_required_ind = i2
       3 default_value_id = f8
       3 default_value = vc
   1 catalog_cd = f8
   1 action_type_cd = f8
   1 oe_field_meaning_id = f8
   1 qual_idx = i2
   1 fldqual_idx = i2
 )
 SET trace = norecpersist
 DECLARE prepareproviderdata(fieldcnt=i4) = null WITH protect
END GO
