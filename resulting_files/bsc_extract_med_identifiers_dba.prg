CREATE PROGRAM bsc_extract_med_identifiers:dba
 SET modify = predeclare
 FREE RECORD reply
 RECORD reply(
   1 lot_number = vc
   1 exp_date = dq8
   1 exp_date_tz = i4
   1 expiration_ind = i2
   1 facility_cd = f8
   1 qual[*]
     2 search_string = vc
     2 ident_qual_cnt = i4
     2 ident_qual[*]
       3 identifier_type_cd = f8
       3 identifier_extraction_type = i2
     2 barcode_extraction_type = i2
   1 prefs
     2 bnewmodelchk = i2
     2 use_mltm_syn_match = i4
     2 scanning_lookup_level = i4
   1 execution_notes[*]
     2 note = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH persistscript
 FREE RECORD barcode
 RECORD barcode(
   1 format[*]
     2 barcode_type_cd = f8
     2 prefix = vc
     2 z_data = vc
 )
 FREE RECORD temp_ident
 RECORD temp_ident(
   1 ident_qual_cnt = i4
   1 ident_qual[*]
     2 identifier_type_cd = f8
 )
 FREE RECORD preferred_indentifiers
 RECORD preferred_identifiers(
   1 list[*]
     2 code_value = f8
 )
 FREE RECORD poc_parsing_rules
 RECORD poc_parsing_rules(
   1 list[*]
     2 total_length = i4
     2 initial_skip = i4
     2 ident_length = i4
 )
 FREE RECORD ndc_parsing_rules
 RECORD ndc_parsing_rules(
   1 list[*]
     2 total_length = i4
     2 initial_skip = i4
     2 ident_length = i4
 )
 FREE RECORD gs1_data
 RECORD gs1_data(
   1 ndc = c10
 )
 FREE RECORD gs1_data_temp
 RECORD gs1_data_temp(
   1 data[*]
     2 variable_name = vc
     2 value = vc
     2 data_type = vc
 )
 FREE RECORD gs1_rules
 RECORD gs1_rules(
   1 rules[68]
     2 identifier = c4
     2 ident_length = i4
     2 variable_name = vc
     2 uses_decimal = i2
     2 loc_in_rec = i4
     2 lengths[*]
       3 length = i4
       3 variable_length = i2
       3 alpha = i2
 )
 FREE RECORD rec_request
 RECORD rec_request(
   1 audit_events[*]
     2 audit_solution_cd = f8
     2 audit_event_cd = f8
     2 audit_event_dt_tm = dq8
     2 audit_facility_cd = f8
     2 audit_patient_id = f8
     2 audit_info_text = vc
   1 debug_ind = i2
 )
 DECLARE stat = i4 WITH protect, noconstant(0)
 SET gs1_rules->rules[1].identifier = "01"
 SET gs1_rules->rules[1].ident_length = 2
 SET gs1_rules->rules[1].variable_name = "gtin"
 SET gs1_rules->rules[1].uses_decimal = 0
 SET stat = alterlist(gs1_rules->rules[1].lengths,1)
 SET gs1_rules->rules[1].lengths[1].length = 14
 SET gs1_rules->rules[1].lengths[1].variable_length = 0
 SET gs1_rules->rules[1].lengths[1].alpha = 0
 SET gs1_rules->rules[2].identifier = "10"
 SET gs1_rules->rules[2].ident_length = 2
 SET gs1_rules->rules[2].variable_name = "lotnum"
 SET gs1_rules->rules[2].uses_decimal = 0
 SET stat = alterlist(gs1_rules->rules[2].lengths,1)
 SET gs1_rules->rules[2].lengths[1].length = 20
 SET gs1_rules->rules[2].lengths[1].variable_length = 1
 SET gs1_rules->rules[2].lengths[1].alpha = 1
 SET gs1_rules->rules[3].identifier = "11"
 SET gs1_rules->rules[3].ident_length = 2
 SET gs1_rules->rules[3].variable_name = "prod_date"
 SET gs1_rules->rules[3].uses_decimal = 0
 SET stat = alterlist(gs1_rules->rules[3].lengths,1)
 SET gs1_rules->rules[3].lengths[1].length = 6
 SET gs1_rules->rules[3].lengths[1].variable_length = 0
 SET gs1_rules->rules[3].lengths[1].alpha = 0
 SET gs1_rules->rules[4].identifier = "15"
 SET gs1_rules->rules[4].ident_length = 2
 SET gs1_rules->rules[4].variable_name = "best_date"
 SET gs1_rules->rules[4].uses_decimal = 0
 SET stat = alterlist(gs1_rules->rules[4].lengths,1)
 SET gs1_rules->rules[4].lengths[1].length = 6
 SET gs1_rules->rules[4].lengths[1].variable_length = 0
 SET gs1_rules->rules[4].lengths[1].alpha = 0
 SET gs1_rules->rules[5].identifier = "17"
 SET gs1_rules->rules[5].ident_length = 2
 SET gs1_rules->rules[5].variable_name = "exp_date"
 SET gs1_rules->rules[5].uses_decimal = 0
 SET stat = alterlist(gs1_rules->rules[5].lengths,1)
 SET gs1_rules->rules[5].lengths[1].length = 6
 SET gs1_rules->rules[5].lengths[1].variable_length = 0
 SET gs1_rules->rules[5].lengths[1].alpha = 0
 SET gs1_rules->rules[6].identifier = "03"
 SET gs1_rules->rules[6].ident_length = 2
 SET gs1_rules->rules[6].variable_name = ""
 SET gs1_rules->rules[6].uses_decimal = 0
 SET stat = alterlist(gs1_rules->rules[6].lengths,1)
 SET gs1_rules->rules[6].lengths[1].length = 14
 SET gs1_rules->rules[6].lengths[1].variable_length = 0
 SET gs1_rules->rules[6].lengths[1].alpha = 0
 SET gs1_rules->rules[7].identifier = "04"
 SET gs1_rules->rules[7].ident_length = 2
 SET gs1_rules->rules[7].variable_name = ""
 SET gs1_rules->rules[7].uses_decimal = 0
 SET stat = alterlist(gs1_rules->rules[7].lengths,1)
 SET gs1_rules->rules[7].lengths[1].length = 16
 SET gs1_rules->rules[7].lengths[1].variable_length = 0
 SET gs1_rules->rules[7].lengths[1].alpha = 0
 SET gs1_rules->rules[8].identifier = "14"
 SET gs1_rules->rules[8].ident_length = 2
 SET gs1_rules->rules[8].variable_name = ""
 SET gs1_rules->rules[8].uses_decimal = 0
 SET stat = alterlist(gs1_rules->rules[8].lengths,1)
 SET gs1_rules->rules[8].lengths[1].length = 6
 SET gs1_rules->rules[8].lengths[1].variable_length = 0
 SET gs1_rules->rules[8].lengths[1].alpha = 0
 SET gs1_rules->rules[9].identifier = "16"
 SET gs1_rules->rules[9].ident_length = 2
 SET gs1_rules->rules[9].variable_name = ""
 SET gs1_rules->rules[9].uses_decimal = 0
 SET stat = alterlist(gs1_rules->rules[9].lengths,1)
 SET gs1_rules->rules[9].lengths[1].length = 6
 SET gs1_rules->rules[9].lengths[1].variable_length = 0
 SET gs1_rules->rules[9].lengths[1].alpha = 0
 SET gs1_rules->rules[10].identifier = "18"
 SET gs1_rules->rules[10].ident_length = 2
 SET gs1_rules->rules[10].variable_name = ""
 SET gs1_rules->rules[10].uses_decimal = 0
 SET stat = alterlist(gs1_rules->rules[10].lengths,1)
 SET gs1_rules->rules[10].lengths[1].length = 6
 SET gs1_rules->rules[10].lengths[1].variable_length = 0
 SET gs1_rules->rules[10].lengths[1].alpha = 0
 SET gs1_rules->rules[11].identifier = "19"
 SET gs1_rules->rules[11].ident_length = 2
 SET gs1_rules->rules[11].variable_name = ""
 SET gs1_rules->rules[11].uses_decimal = 0
 SET stat = alterlist(gs1_rules->rules[11].lengths,1)
 SET gs1_rules->rules[11].lengths[1].length = 6
 SET gs1_rules->rules[11].lengths[1].variable_length = 0
 SET gs1_rules->rules[11].lengths[1].alpha = 0
 SET gs1_rules->rules[12].identifier = "31"
 SET gs1_rules->rules[12].ident_length = 2
 SET gs1_rules->rules[12].variable_name = ""
 SET gs1_rules->rules[11].uses_decimal = 0
 SET stat = alterlist(gs1_rules->rules[12].lengths,1)
 SET gs1_rules->rules[12].lengths[1].length = 8
 SET gs1_rules->rules[12].lengths[1].variable_length = 0
 SET gs1_rules->rules[12].lengths[1].alpha = 0
 SET gs1_rules->rules[13].identifier = "32"
 SET gs1_rules->rules[13].ident_length = 2
 SET gs1_rules->rules[13].variable_name = ""
 SET gs1_rules->rules[13].uses_decimal = 0
 SET stat = alterlist(gs1_rules->rules[13].lengths,1)
 SET gs1_rules->rules[13].lengths[1].length = 8
 SET gs1_rules->rules[13].lengths[1].variable_length = 0
 SET gs1_rules->rules[13].lengths[1].alpha = 0
 SET gs1_rules->rules[14].identifier = "33"
 SET gs1_rules->rules[14].ident_length = 2
 SET gs1_rules->rules[14].variable_name = ""
 SET gs1_rules->rules[14].uses_decimal = 0
 SET stat = alterlist(gs1_rules->rules[14].lengths,1)
 SET gs1_rules->rules[14].lengths[1].length = 8
 SET gs1_rules->rules[14].lengths[1].variable_length = 0
 SET gs1_rules->rules[14].lengths[1].alpha = 0
 SET gs1_rules->rules[15].identifier = "34"
 SET gs1_rules->rules[15].ident_length = 2
 SET gs1_rules->rules[15].variable_name = ""
 SET gs1_rules->rules[15].uses_decimal = 0
 SET stat = alterlist(gs1_rules->rules[15].lengths,1)
 SET gs1_rules->rules[15].lengths[1].length = 8
 SET gs1_rules->rules[15].lengths[1].variable_length = 0
 SET gs1_rules->rules[15].lengths[1].alpha = 0
 SET gs1_rules->rules[16].identifier = "35"
 SET gs1_rules->rules[16].ident_length = 2
 SET gs1_rules->rules[16].variable_name = ""
 SET gs1_rules->rules[16].uses_decimal = 0
 SET stat = alterlist(gs1_rules->rules[16].lengths,1)
 SET gs1_rules->rules[16].lengths[1].length = 8
 SET gs1_rules->rules[16].lengths[1].variable_length = 0
 SET gs1_rules->rules[16].lengths[1].alpha = 0
 SET gs1_rules->rules[17].identifier = "36"
 SET gs1_rules->rules[17].ident_length = 2
 SET gs1_rules->rules[17].variable_name = ""
 SET gs1_rules->rules[17].uses_decimal = 0
 SET stat = alterlist(gs1_rules->rules[17].lengths,1)
 SET gs1_rules->rules[17].lengths[1].length = 8
 SET gs1_rules->rules[17].lengths[1].variable_length = 0
 SET gs1_rules->rules[17].lengths[1].alpha = 0
 SET gs1_rules->rules[18].identifier = "41"
 SET gs1_rules->rules[18].ident_length = 2
 SET gs1_rules->rules[18].variable_name = ""
 SET gs1_rules->rules[18].uses_decimal = 0
 SET stat = alterlist(gs1_rules->rules[18].lengths,1)
 SET gs1_rules->rules[18].lengths[1].length = 14
 SET gs1_rules->rules[18].lengths[1].variable_length = 0
 SET gs1_rules->rules[18].lengths[1].alpha = 0
 SET gs1_rules->rules[19].identifier = "12"
 SET gs1_rules->rules[19].ident_length = 2
 SET gs1_rules->rules[19].variable_name = "due_date"
 SET gs1_rules->rules[19].uses_decimal = 0
 SET stat = alterlist(gs1_rules->rules[19].lengths,1)
 SET gs1_rules->rules[19].lengths[1].length = 6
 SET gs1_rules->rules[19].lengths[1].variable_length = 0
 SET gs1_rules->rules[19].lengths[1].alpha = 0
 SET gs1_rules->rules[20].identifier = "13"
 SET gs1_rules->rules[20].ident_length = 2
 SET gs1_rules->rules[20].variable_name = "pack_date"
 SET gs1_rules->rules[20].uses_decimal = 0
 SET stat = alterlist(gs1_rules->rules[20].lengths,1)
 SET gs1_rules->rules[20].lengths[1].length = 6
 SET gs1_rules->rules[20].lengths[1].variable_length = 0
 SET gs1_rules->rules[20].lengths[1].alpha = 0
 SET gs1_rules->rules[21].identifier = "00"
 SET gs1_rules->rules[21].ident_length = 2
 SET gs1_rules->rules[21].variable_name = "sscc"
 SET gs1_rules->rules[21].uses_decimal = 0
 SET stat = alterlist(gs1_rules->rules[21].lengths,1)
 SET gs1_rules->rules[21].lengths[1].length = 18
 SET gs1_rules->rules[21].lengths[1].variable_length = 0
 SET gs1_rules->rules[21].lengths[1].alpha = 0
 SET gs1_rules->rules[22].identifier = "02"
 SET gs1_rules->rules[22].ident_length = 2
 SET gs1_rules->rules[22].variable_name = "gtin_cti"
 SET gs1_rules->rules[22].uses_decimal = 0
 SET stat = alterlist(gs1_rules->rules[22].lengths,1)
 SET gs1_rules->rules[22].lengths[1].length = 14
 SET gs1_rules->rules[22].lengths[1].variable_length = 0
 SET gs1_rules->rules[22].lengths[1].alpha = 0
 SET gs1_rules->rules[23].identifier = "20"
 SET gs1_rules->rules[23].ident_length = 2
 SET gs1_rules->rules[23].variable_name = "var_num"
 SET gs1_rules->rules[23].uses_decimal = 0
 SET stat = alterlist(gs1_rules->rules[23].lengths,1)
 SET gs1_rules->rules[23].lengths[1].length = 2
 SET gs1_rules->rules[23].lengths[1].variable_length = 0
 SET gs1_rules->rules[23].lengths[1].alpha = 0
 SET gs1_rules->rules[24].identifier = "402"
 SET gs1_rules->rules[24].ident_length = 3
 SET gs1_rules->rules[24].variable_name = ""
 SET gs1_rules->rules[24].uses_decimal = 0
 SET stat = alterlist(gs1_rules->rules[24].lengths,1)
 SET gs1_rules->rules[24].lengths[1].length = 17
 SET gs1_rules->rules[24].lengths[1].variable_length = 0
 SET gs1_rules->rules[24].lengths[1].alpha = 0
 SET gs1_rules->rules[25].identifier = "422"
 SET gs1_rules->rules[25].ident_length = 3
 SET gs1_rules->rules[25].variable_name = ""
 SET gs1_rules->rules[25].uses_decimal = 0
 SET stat = alterlist(gs1_rules->rules[25].lengths,1)
 SET gs1_rules->rules[25].lengths[1].length = 3
 SET gs1_rules->rules[25].lengths[1].variable_length = 0
 SET gs1_rules->rules[25].lengths[1].alpha = 0
 SET gs1_rules->rules[26].identifier = "424"
 SET gs1_rules->rules[26].ident_length = 3
 SET gs1_rules->rules[26].variable_name = ""
 SET gs1_rules->rules[26].uses_decimal = 0
 SET stat = alterlist(gs1_rules->rules[26].lengths,1)
 SET gs1_rules->rules[26].lengths[1].length = 3
 SET gs1_rules->rules[26].lengths[1].variable_length = 0
 SET gs1_rules->rules[26].lengths[1].alpha = 0
 SET gs1_rules->rules[27].identifier = "425"
 SET gs1_rules->rules[27].ident_length = 3
 SET gs1_rules->rules[27].variable_name = ""
 SET gs1_rules->rules[27].uses_decimal = 0
 SET stat = alterlist(gs1_rules->rules[27].lengths,1)
 SET gs1_rules->rules[27].lengths[1].length = 3
 SET gs1_rules->rules[27].lengths[1].variable_length = 0
 SET gs1_rules->rules[27].lengths[1].alpha = 0
 SET gs1_rules->rules[28].identifier = "426"
 SET gs1_rules->rules[28].ident_length = 3
 SET gs1_rules->rules[28].variable_name = ""
 SET gs1_rules->rules[28].uses_decimal = 0
 SET stat = alterlist(gs1_rules->rules[28].lengths,1)
 SET gs1_rules->rules[28].lengths[1].length = 3
 SET gs1_rules->rules[28].lengths[1].variable_length = 0
 SET gs1_rules->rules[28].lengths[1].alpha = 0
 SET gs1_rules->rules[29].identifier = "7001"
 SET gs1_rules->rules[29].ident_length = 4
 SET gs1_rules->rules[29].variable_name = ""
 SET gs1_rules->rules[29].uses_decimal = 0
 SET stat = alterlist(gs1_rules->rules[29].lengths,1)
 SET gs1_rules->rules[29].lengths[1].length = 13
 SET gs1_rules->rules[29].lengths[1].variable_length = 0
 SET gs1_rules->rules[29].lengths[1].alpha = 0
 SET gs1_rules->rules[30].identifier = "8001"
 SET gs1_rules->rules[30].ident_length = 4
 SET gs1_rules->rules[30].variable_name = ""
 SET gs1_rules->rules[30].uses_decimal = 0
 SET stat = alterlist(gs1_rules->rules[30].lengths,1)
 SET gs1_rules->rules[30].lengths[1].length = 14
 SET gs1_rules->rules[30].lengths[1].variable_length = 0
 SET gs1_rules->rules[30].lengths[1].alpha = 0
 SET gs1_rules->rules[31].identifier = "8005"
 SET gs1_rules->rules[31].ident_length = 4
 SET gs1_rules->rules[31].variable_name = ""
 SET gs1_rules->rules[31].uses_decimal = 0
 SET stat = alterlist(gs1_rules->rules[31].lengths,1)
 SET gs1_rules->rules[31].lengths[1].length = 6
 SET gs1_rules->rules[31].lengths[1].variable_length = 0
 SET gs1_rules->rules[31].lengths[1].alpha = 0
 SET gs1_rules->rules[32].identifier = "8006"
 SET gs1_rules->rules[32].ident_length = 4
 SET gs1_rules->rules[32].variable_name = ""
 SET gs1_rules->rules[32].uses_decimal = 0
 SET stat = alterlist(gs1_rules->rules[32].lengths,3)
 SET gs1_rules->rules[32].lengths[1].length = 14
 SET gs1_rules->rules[32].lengths[1].variable_length = 0
 SET gs1_rules->rules[32].lengths[1].alpha = 0
 SET gs1_rules->rules[32].lengths[2].length = 2
 SET gs1_rules->rules[32].lengths[2].variable_length = 0
 SET gs1_rules->rules[32].lengths[2].alpha = 0
 SET gs1_rules->rules[32].lengths[3].length = 2
 SET gs1_rules->rules[32].lengths[3].variable_length = 0
 SET gs1_rules->rules[32].lengths[3].alpha = 0
 SET gs1_rules->rules[33].identifier = "8018"
 SET gs1_rules->rules[33].ident_length = 4
 SET gs1_rules->rules[33].variable_name = ""
 SET gs1_rules->rules[33].uses_decimal = 0
 SET stat = alterlist(gs1_rules->rules[33].lengths,1)
 SET gs1_rules->rules[33].lengths[1].length = 18
 SET gs1_rules->rules[33].lengths[1].variable_length = 0
 SET gs1_rules->rules[33].lengths[1].alpha = 0
 SET gs1_rules->rules[34].identifier = "8100"
 SET gs1_rules->rules[34].ident_length = 4
 SET gs1_rules->rules[34].variable_name = ""
 SET gs1_rules->rules[34].uses_decimal = 0
 SET stat = alterlist(gs1_rules->rules[34].lengths,1)
 SET gs1_rules->rules[34].lengths[1].length = 6
 SET gs1_rules->rules[34].lengths[1].variable_length = 0
 SET gs1_rules->rules[34].lengths[1].alpha = 0
 SET gs1_rules->rules[35].identifier = "8101"
 SET gs1_rules->rules[35].ident_length = 4
 SET gs1_rules->rules[35].variable_name = ""
 SET gs1_rules->rules[35].uses_decimal = 0
 SET stat = alterlist(gs1_rules->rules[35].lengths,3)
 SET gs1_rules->rules[35].lengths[1].length = 1
 SET gs1_rules->rules[35].lengths[1].variable_length = 0
 SET gs1_rules->rules[35].lengths[1].alpha = 0
 SET gs1_rules->rules[35].lengths[2].length = 5
 SET gs1_rules->rules[35].lengths[2].variable_length = 0
 SET gs1_rules->rules[35].lengths[2].alpha = 0
 SET gs1_rules->rules[35].lengths[3].length = 5
 SET gs1_rules->rules[35].lengths[3].variable_length = 0
 SET gs1_rules->rules[35].lengths[3].alpha = 0
 SET gs1_rules->rules[36].identifier = "8102"
 SET gs1_rules->rules[36].ident_length = 4
 SET gs1_rules->rules[36].variable_name = ""
 SET gs1_rules->rules[36].uses_decimal = 0
 SET stat = alterlist(gs1_rules->rules[36].lengths,2)
 SET gs1_rules->rules[36].lengths[1].length = 1
 SET gs1_rules->rules[36].lengths[1].variable_length = 0
 SET gs1_rules->rules[36].lengths[1].alpha = 0
 SET gs1_rules->rules[36].lengths[1].length = 1
 SET gs1_rules->rules[36].lengths[1].variable_length = 0
 SET gs1_rules->rules[36].lengths[1].alpha = 0
 SET gs1_rules->rules[37].identifier = "21"
 SET gs1_rules->rules[37].ident_length = 2
 SET gs1_rules->rules[37].variable_name = "serial_num"
 SET gs1_rules->rules[37].uses_decimal = 0
 SET stat = alterlist(gs1_rules->rules[37].lengths,1)
 SET gs1_rules->rules[37].lengths[1].length = 20
 SET gs1_rules->rules[37].lengths[1].variable_length = 1
 SET gs1_rules->rules[37].lengths[1].alpha = 1
 SET gs1_rules->rules[38].identifier = "703"
 SET gs1_rules->rules[38].ident_length = 3
 SET gs1_rules->rules[38].variable_name = ""
 SET gs1_rules->rules[38].uses_decimal = 0
 SET stat = alterlist(gs1_rules->rules[38].lengths,3)
 SET gs1_rules->rules[38].lengths[1].length = 1
 SET gs1_rules->rules[38].lengths[1].variable_length = 0
 SET gs1_rules->rules[38].lengths[1].alpha = 0
 SET gs1_rules->rules[38].lengths[2].length = 3
 SET gs1_rules->rules[38].lengths[2].variable_length = 0
 SET gs1_rules->rules[38].lengths[2].alpha = 0
 SET gs1_rules->rules[38].lengths[3].length = 27
 SET gs1_rules->rules[38].lengths[3].variable_length = 1
 SET gs1_rules->rules[38].lengths[3].alpha = 1
 SET gs1_rules->rules[39].identifier = "22"
 SET gs1_rules->rules[39].ident_length = 2
 SET gs1_rules->rules[39].variable_name = "sec_data"
 SET gs1_rules->rules[39].uses_decimal = 0
 SET stat = alterlist(gs1_rules->rules[39].lengths,1)
 SET gs1_rules->rules[39].lengths[1].length = 29
 SET gs1_rules->rules[39].lengths[1].variable_length = 1
 SET gs1_rules->rules[39].lengths[1].alpha = 1
 SET gs1_rules->rules[40].identifier = "240"
 SET gs1_rules->rules[40].ident_length = 3
 SET gs1_rules->rules[40].variable_name = "add_item_ident"
 SET gs1_rules->rules[40].uses_decimal = 0
 SET stat = alterlist(gs1_rules->rules[40].lengths,1)
 SET gs1_rules->rules[40].lengths[1].length = 30
 SET gs1_rules->rules[40].lengths[1].variable_length = 1
 SET gs1_rules->rules[40].lengths[1].alpha = 1
 SET gs1_rules->rules[41].identifier = "241"
 SET gs1_rules->rules[41].ident_length = 3
 SET gs1_rules->rules[41].variable_name = "cust_part_num"
 SET gs1_rules->rules[41].uses_decimal = 0
 SET stat = alterlist(gs1_rules->rules[41].lengths,1)
 SET gs1_rules->rules[41].lengths[1].length = 30
 SET gs1_rules->rules[41].lengths[1].variable_length = 1
 SET gs1_rules->rules[41].lengths[1].alpha = 1
 SET gs1_rules->rules[42].identifier = "242"
 SET gs1_rules->rules[42].ident_length = 3
 SET gs1_rules->rules[42].variable_name = "made_order"
 SET gs1_rules->rules[42].uses_decimal = 0
 SET stat = alterlist(gs1_rules->rules[42].lengths,1)
 SET gs1_rules->rules[42].lengths[1].length = 6
 SET gs1_rules->rules[42].lengths[1].variable_length = 1
 SET gs1_rules->rules[42].lengths[1].alpha = 0
 SET gs1_rules->rules[43].identifier = "250"
 SET gs1_rules->rules[43].ident_length = 3
 SET gs1_rules->rules[43].variable_name = "sec_ser_num"
 SET gs1_rules->rules[43].uses_decimal = 0
 SET stat = alterlist(gs1_rules->rules[43].lengths,1)
 SET gs1_rules->rules[43].lengths[1].length = 30
 SET gs1_rules->rules[43].lengths[1].variable_length = 1
 SET gs1_rules->rules[43].lengths[1].alpha = 1
 SET gs1_rules->rules[44].identifier = "251"
 SET gs1_rules->rules[44].ident_length = 3
 SET gs1_rules->rules[44].variable_name = "ref_source"
 SET gs1_rules->rules[44].uses_decimal = 0
 SET stat = alterlist(gs1_rules->rules[44].lengths,1)
 SET gs1_rules->rules[44].lengths[1].length = 30
 SET gs1_rules->rules[44].lengths[1].variable_length = 1
 SET gs1_rules->rules[44].lengths[1].alpha = 1
 SET gs1_rules->rules[45].identifier = "253"
 SET gs1_rules->rules[45].ident_length = 3
 SET gs1_rules->rules[45].variable_name = "gdti"
 SET gs1_rules->rules[45].uses_decimal = 0
 SET stat = alterlist(gs1_rules->rules[45].lengths,2)
 SET gs1_rules->rules[45].lengths[1].length = 13
 SET gs1_rules->rules[45].lengths[1].variable_length = 0
 SET gs1_rules->rules[45].lengths[1].alpha = 0
 SET gs1_rules->rules[45].lengths[2].length = 17
 SET gs1_rules->rules[45].lengths[2].variable_length = 1
 SET gs1_rules->rules[45].lengths[2].alpha = 0
 SET gs1_rules->rules[46].identifier = "254"
 SET gs1_rules->rules[46].ident_length = 3
 SET gs1_rules->rules[46].variable_name = ""
 SET gs1_rules->rules[46].uses_decimal = 0
 SET stat = alterlist(gs1_rules->rules[46].lengths,1)
 SET gs1_rules->rules[46].lengths[1].length = 20
 SET gs1_rules->rules[46].lengths[1].variable_length = 1
 SET gs1_rules->rules[46].lengths[1].alpha = 1
 SET gs1_rules->rules[47].identifier = "30"
 SET gs1_rules->rules[47].ident_length = 2
 SET gs1_rules->rules[47].variable_name = ""
 SET gs1_rules->rules[47].uses_decimal = 0
 SET stat = alterlist(gs1_rules->rules[47].lengths,1)
 SET gs1_rules->rules[47].lengths[1].length = 8
 SET gs1_rules->rules[47].lengths[1].variable_length = 1
 SET gs1_rules->rules[47].lengths[1].alpha = 0
 SET gs1_rules->rules[48].identifier = "37"
 SET gs1_rules->rules[48].ident_length = 2
 SET gs1_rules->rules[48].variable_name = ""
 SET gs1_rules->rules[48].uses_decimal = 0
 SET stat = alterlist(gs1_rules->rules[48].lengths,1)
 SET gs1_rules->rules[48].lengths[1].length = 8
 SET gs1_rules->rules[48].lengths[1].variable_length = 1
 SET gs1_rules->rules[48].lengths[1].alpha = 0
 SET gs1_rules->rules[49].identifier = "390"
 SET gs1_rules->rules[49].ident_length = 4
 SET gs1_rules->rules[49].variable_name = ""
 SET gs1_rules->rules[49].uses_decimal = 1
 SET stat = alterlist(gs1_rules->rules[49].lengths,1)
 SET gs1_rules->rules[49].lengths[1].length = 15
 SET gs1_rules->rules[49].lengths[1].variable_length = 1
 SET gs1_rules->rules[49].lengths[1].alpha = 0
 SET gs1_rules->rules[50].identifier = "391"
 SET gs1_rules->rules[50].ident_length = 4
 SET gs1_rules->rules[50].variable_name = ""
 SET gs1_rules->rules[50].uses_decimal = 1
 SET stat = alterlist(gs1_rules->rules[50].lengths,2)
 SET gs1_rules->rules[50].lengths[1].length = 3
 SET gs1_rules->rules[50].lengths[1].variable_length = 0
 SET gs1_rules->rules[50].lengths[1].alpha = 0
 SET gs1_rules->rules[50].lengths[2].length = 15
 SET gs1_rules->rules[50].lengths[2].variable_length = 1
 SET gs1_rules->rules[50].lengths[2].alpha = 0
 SET gs1_rules->rules[51].identifier = "392"
 SET gs1_rules->rules[51].ident_length = 4
 SET gs1_rules->rules[51].variable_name = ""
 SET gs1_rules->rules[51].uses_decimal = 1
 SET stat = alterlist(gs1_rules->rules[51].lengths,1)
 SET gs1_rules->rules[51].lengths[1].length = 15
 SET gs1_rules->rules[51].lengths[1].variable_length = 1
 SET gs1_rules->rules[51].lengths[1].alpha = 0
 SET gs1_rules->rules[52].identifier = "393"
 SET gs1_rules->rules[52].ident_length = 4
 SET gs1_rules->rules[52].variable_name = ""
 SET gs1_rules->rules[52].uses_decimal = 1
 SET stat = alterlist(gs1_rules->rules[52].lengths,2)
 SET gs1_rules->rules[52].lengths[1].length = 3
 SET gs1_rules->rules[52].lengths[1].variable_length = 0
 SET gs1_rules->rules[52].lengths[1].alpha = 0
 SET gs1_rules->rules[52].lengths[2].length = 15
 SET gs1_rules->rules[52].lengths[2].variable_length = 1
 SET gs1_rules->rules[52].lengths[2].alpha = 0
 SET gs1_rules->rules[53].identifier = "400"
 SET gs1_rules->rules[53].ident_length = 3
 SET gs1_rules->rules[53].variable_name = ""
 SET gs1_rules->rules[53].uses_decimal = 0
 SET stat = alterlist(gs1_rules->rules[53].lengths,1)
 SET gs1_rules->rules[53].lengths[1].length = 30
 SET gs1_rules->rules[53].lengths[1].variable_length = 1
 SET gs1_rules->rules[53].lengths[1].alpha = 1
 SET gs1_rules->rules[54].identifier = "401"
 SET gs1_rules->rules[54].ident_length = 3
 SET gs1_rules->rules[54].variable_name = ""
 SET gs1_rules->rules[54].uses_decimal = 0
 SET stat = alterlist(gs1_rules->rules[54].lengths,1)
 SET gs1_rules->rules[54].lengths[1].length = 30
 SET gs1_rules->rules[54].lengths[1].variable_length = 1
 SET gs1_rules->rules[54].lengths[1].alpha = 1
 SET gs1_rules->rules[55].identifier = "403"
 SET gs1_rules->rules[55].ident_length = 3
 SET gs1_rules->rules[55].variable_name = ""
 SET gs1_rules->rules[55].uses_decimal = 0
 SET stat = alterlist(gs1_rules->rules[55].lengths,1)
 SET gs1_rules->rules[55].lengths[1].length = 30
 SET gs1_rules->rules[55].lengths[1].variable_length = 1
 SET gs1_rules->rules[55].lengths[1].alpha = 1
 SET gs1_rules->rules[56].identifier = "420"
 SET gs1_rules->rules[56].ident_length = 3
 SET gs1_rules->rules[56].variable_name = ""
 SET gs1_rules->rules[56].uses_decimal = 0
 SET stat = alterlist(gs1_rules->rules[56].lengths,1)
 SET gs1_rules->rules[56].lengths[1].length = 20
 SET gs1_rules->rules[56].lengths[1].variable_length = 1
 SET gs1_rules->rules[56].lengths[1].alpha = 1
 SET gs1_rules->rules[57].identifier = "421"
 SET gs1_rules->rules[57].ident_length = 3
 SET gs1_rules->rules[57].variable_name = ""
 SET gs1_rules->rules[57].uses_decimal = 0
 SET stat = alterlist(gs1_rules->rules[57].lengths,2)
 SET gs1_rules->rules[57].lengths[1].length = 3
 SET gs1_rules->rules[57].lengths[1].variable_length = 0
 SET gs1_rules->rules[57].lengths[1].alpha = 0
 SET gs1_rules->rules[57].lengths[2].length = 9
 SET gs1_rules->rules[57].lengths[2].variable_length = 1
 SET gs1_rules->rules[57].lengths[2].alpha = 1
 SET gs1_rules->rules[58].identifier = "423"
 SET gs1_rules->rules[58].ident_length = 3
 SET gs1_rules->rules[58].variable_name = ""
 SET gs1_rules->rules[58].uses_decimal = 0
 SET stat = alterlist(gs1_rules->rules[58].lengths,2)
 SET gs1_rules->rules[58].lengths[1].length = 3
 SET gs1_rules->rules[58].lengths[1].variable_length = 0
 SET gs1_rules->rules[58].lengths[1].alpha = 0
 SET gs1_rules->rules[58].lengths[2].length = 12
 SET gs1_rules->rules[58].lengths[2].variable_length = 1
 SET gs1_rules->rules[58].lengths[2].alpha = 0
 SET gs1_rules->rules[59].identifier = "7002"
 SET gs1_rules->rules[59].ident_length = 4
 SET gs1_rules->rules[59].variable_name = ""
 SET gs1_rules->rules[59].uses_decimal = 0
 SET stat = alterlist(gs1_rules->rules[59].lengths,1)
 SET gs1_rules->rules[59].lengths[1].length = 30
 SET gs1_rules->rules[59].lengths[1].variable_length = 1
 SET gs1_rules->rules[59].lengths[1].alpha = 1
 SET gs1_rules->rules[60].identifier = "8002"
 SET gs1_rules->rules[60].ident_length = 4
 SET gs1_rules->rules[60].variable_name = ""
 SET gs1_rules->rules[60].uses_decimal = 0
 SET stat = alterlist(gs1_rules->rules[60].lengths,1)
 SET gs1_rules->rules[60].lengths[1].length = 20
 SET gs1_rules->rules[60].lengths[1].variable_length = 0
 SET gs1_rules->rules[60].lengths[1].alpha = 0
 SET gs1_rules->rules[61].identifier = "8003"
 SET gs1_rules->rules[61].ident_length = 4
 SET gs1_rules->rules[61].variable_name = ""
 SET gs1_rules->rules[61].uses_decimal = 0
 SET stat = alterlist(gs1_rules->rules[61].lengths,2)
 SET gs1_rules->rules[61].lengths[1].length = 14
 SET gs1_rules->rules[61].lengths[1].variable_length = 0
 SET gs1_rules->rules[61].lengths[1].alpha = 0
 SET gs1_rules->rules[61].lengths[2].length = 16
 SET gs1_rules->rules[61].lengths[2].variable_length = 1
 SET gs1_rules->rules[61].lengths[2].alpha = 1
 SET gs1_rules->rules[62].identifier = "8004"
 SET gs1_rules->rules[62].ident_length = 4
 SET gs1_rules->rules[62].variable_name = ""
 SET gs1_rules->rules[62].uses_decimal = 0
 SET stat = alterlist(gs1_rules->rules[62].lengths,1)
 SET gs1_rules->rules[62].lengths[1].length = 30
 SET gs1_rules->rules[62].lengths[1].variable_length = 1
 SET gs1_rules->rules[62].lengths[1].alpha = 1
 SET gs1_rules->rules[63].identifier = "8007"
 SET gs1_rules->rules[63].ident_length = 4
 SET gs1_rules->rules[63].variable_name = ""
 SET gs1_rules->rules[63].uses_decimal = 0
 SET stat = alterlist(gs1_rules->rules[63].lengths,1)
 SET gs1_rules->rules[63].lengths[1].length = 30
 SET gs1_rules->rules[63].lengths[1].variable_length = 1
 SET gs1_rules->rules[63].lengths[1].alpha = 1
 SET gs1_rules->rules[64].identifier = "8008"
 SET gs1_rules->rules[64].ident_length = 4
 SET gs1_rules->rules[64].variable_name = ""
 SET gs1_rules->rules[64].uses_decimal = 0
 SET stat = alterlist(gs1_rules->rules[64].lengths,2)
 SET gs1_rules->rules[64].lengths[1].length = 8
 SET gs1_rules->rules[64].lengths[1].variable_length = 0
 SET gs1_rules->rules[64].lengths[1].alpha = 0
 SET gs1_rules->rules[64].lengths[2].length = 4
 SET gs1_rules->rules[64].lengths[2].variable_length = 1
 SET gs1_rules->rules[64].lengths[2].alpha = 0
 SET gs1_rules->rules[65].identifier = "8020"
 SET gs1_rules->rules[65].ident_length = 4
 SET gs1_rules->rules[65].variable_name = ""
 SET gs1_rules->rules[65].uses_decimal = 0
 SET stat = alterlist(gs1_rules->rules[65].lengths,1)
 SET gs1_rules->rules[65].lengths[1].length = 25
 SET gs1_rules->rules[65].lengths[1].variable_length = 1
 SET gs1_rules->rules[65].lengths[1].alpha = 1
 SET gs1_rules->rules[66].identifier = "8110"
 SET gs1_rules->rules[66].ident_length = 4
 SET gs1_rules->rules[66].variable_name = ""
 SET gs1_rules->rules[66].uses_decimal = 0
 SET stat = alterlist(gs1_rules->rules[66].lengths,1)
 SET gs1_rules->rules[66].lengths[1].length = 30
 SET gs1_rules->rules[66].lengths[1].variable_length = 1
 SET gs1_rules->rules[66].lengths[1].alpha = 1
 SET gs1_rules->rules[67].identifier = "9"
 SET gs1_rules->rules[67].ident_length = 1
 SET gs1_rules->rules[67].variable_name = ""
 SET gs1_rules->rules[67].uses_decimal = 0
 SET stat = alterlist(gs1_rules->rules[67].lengths,2)
 SET gs1_rules->rules[67].lengths[1].length = 1
 SET gs1_rules->rules[67].lengths[1].variable_length = 0
 SET gs1_rules->rules[67].lengths[1].alpha = 0
 SET gs1_rules->rules[67].lengths[2].length = 30
 SET gs1_rules->rules[67].lengths[2].variable_length = 1
 SET gs1_rules->rules[67].lengths[2].alpha = 1
 DECLARE preferredtype = i2 WITH protect, constant(1)
 DECLARE gs1type = i2 WITH protect, constant(2)
 DECLARE gs1alttype = i2 WITH protect, constant(4)
 DECLARE ndctype = i2 WITH protect, constant(8)
 DECLARE ndcalttype = i2 WITH protect, constant(16)
 DECLARE mckessontype = i2 WITH protect, constant(32)
 DECLARE omnicelltype = i2 WITH protect, constant(64)
 DECLARE pocruletype = i2 WITH protect, constant(128)
 DECLARE rawtype = i2 WITH protect, constant(256)
 DECLARE prefixtype = i2 WITH protect, constant(512)
 DECLARE start_time = f8 WITH private, noconstant(curtime3)
 DECLARE elapsed_time = f8 WITH private, noconstant(0.0)
 DECLARE sbarcode = vc WITH protect, noconstant("")
 DECLARE dorgid = f8 WITH protect, noconstant(0.0)
 DECLARE lbarcodelength = i4 WITH protect, noconstant(0)
 DECLARE sbarcodeprefix = vc WITH protect, noconstant("")
 DECLARE sbarcodezdata = vc WITH protect, noconstant("")
 DECLARE bnewmodelchk = i2 WITH protect, noconstant(0)
 DECLARE bbarcodeformatsloaded = i2 WITH protect, noconstant(0)
 DECLARE bprocessed = i2 WITH protect, noconstant(0)
 DECLARE dstat = f8 WITH protect, noconstant(0.0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE cndc = f8 WITH protect, constant(uar_get_code_by("MEANING",11000,"NDC"))
 DECLARE last_mod = c3 WITH private, noconstant("")
 DECLARE mod_date = c10 WITH private, noconstant("")
 DECLARE debug_ind = i2 WITH protect, noconstant(validate(request->debug_ind,0))
 DECLARE proc_pref_items_ind = i2 WITH protect, noconstant(validate(request->
   processpreferreditems_ind,1))
 DECLARE have_preferred_ind = i2 WITH protect, noconstant(0)
 DECLARE have_poc_ind = i2 WITH protect, noconstant(0)
 DECLARE have_ndc_ind = i2 WITH protect, noconstant(0)
 DECLARE gs1_cur_loc = i4 WITH protect, noconstant(1)
 DECLARE cgs1_stop = c1 WITH protect, constant(char(124))
 DECLARE cgs_sep = vc WITH protect, constant("\u001D")
 DECLARE cgs1 = f8 WITH protect, constant(uar_get_code_by("MEANING",4002139,"GS1"))
 IF (debug_ind > 0)
  CALL echo(build("proc_pref_items_ind: ",proc_pref_items_ind))
 ENDIF
 DECLARE getpocprefs(null) = null
 DECLARE getbarcodeformats(null) = null
 DECLARE getpmipref(null) = null
 DECLARE processpreferreditems(null) = null
 DECLARE proccessprefreturn(null) = null
 DECLARE populategs1structure(null) = null
 DECLARE recordauditinfo(null) = null
 DECLARE ipreffound = i2 WITH protect, constant(1)
 DECLARE iprefnotfound = i2 WITH protect, constant(2)
 DECLARE ipreferror = i2 WITH protect, constant(0)
 DECLARE itypestr = i2 WITH protect, constant(0)
 DECLARE itypedbl = i2 WITH protect, constant(1)
 DECLARE itypeint = i2 WITH protect, constant(2)
 FREE RECORD preference_struct
 RECORD preference_struct(
   1 prefs[*]
     2 pref_name = vc
     2 pref_name_upper = vc
     2 pref_type = i4
     2 pref_stat = i2
     2 pref_val[*]
       3 val_str = vc
       3 val_int = i4
       3 val_dbl = f8
 )
 DECLARE initalizeprefread(null) = i2
 DECLARE proccesssingleprefread(null) = i2
 DECLARE releasehandles(null) = null
 DECLARE cnvtprefnamestoupper(null) = null
 SUBROUTINE (getprefbycontextint(spreftofetch=vc,scontextstring=vc,svaluestring=vc,iretprefvalue=i4(
   ref)) =i2)
   CALL debugecho("/********Entering GetPrefByContextInt********/")
   DECLARE istat = i2 WITH protect, noconstant(0)
   DECLARE iretstat = i2 WITH protect, noconstant(0)
   SET istat = alterlist(preference_struct->prefs,0)
   SET istat = alterlist(preference_struct->prefs,1)
   SET preference_struct->prefs[1].pref_name = spreftofetch
   SET preference_struct->prefs[1].pref_type = itypeint
   SET iretstat = getprefbystructsub(scontextstring,svaluestring,1)
   IF (iretstat != ipreffound)
    CALL debugecho("Preference not found")
    RETURN(iretstat)
   ENDIF
   IF (size(preference_struct->prefs,5) > 0)
    IF ((preference_struct->prefs[1].pref_stat=ipreffound))
     IF (size(preference_struct->prefs[1].pref_val,5) > 0)
      IF (validate(request->debug_ind,1))
       CALL echorecord(preference_struct)
      ENDIF
      SET iretprefvalue = preference_struct->prefs[1].pref_val[1].val_int
      CALL debugecho(build("GetPrefByContextInt returning value: ",iretprefvalue))
     ELSE
      CALL debugecho("No pref_vals returned")
      RETURN(ipreferror)
     ENDIF
    ENDIF
   ELSE
    CALL debugecho("No prefs returned")
    RETURN(ipreferror)
   ENDIF
   RETURN(preference_struct->prefs[1].pref_stat)
 END ;Subroutine
 SUBROUTINE (getprefbycontextdbl(spreftofetch=vc,scontextstring=vc,svaluestring=vc,dretprefvalue=f8(
   ref)) =i2)
   CALL debugecho("/********Entering GetPrefByContextDbl********/")
   DECLARE istat = i2 WITH protect, noconstant(0)
   DECLARE iretstat = i2 WITH protect, noconstant(0)
   SET istat = alterlist(preference_struct->prefs,0)
   SET istat = alterlist(preference_struct->prefs,1)
   SET preference_struct->prefs[1].pref_name = spreftofetch
   SET preference_struct->prefs[1].pref_type = itypedbl
   SET iretstat = getprefbystructsub(scontextstring,svaluestring,1)
   IF (iretstat != ipreffound)
    CALL debugecho("Preference not found")
    RETURN(iretstat)
   ENDIF
   IF (size(preference_struct->prefs,5) > 0)
    IF ((preference_struct->prefs[1].pref_stat=ipreffound))
     IF (size(preference_struct->prefs[1].pref_val,5) > 0)
      SET dretprefvalue = preference_struct->prefs[1].pref_val[1].val_dbl
      CALL debugecho(build("GetPrefByContextDbl returning value: ",dretprefvalue))
     ELSE
      CALL debugecho("No pref_vals returned")
      RETURN(ipreferror)
     ENDIF
    ENDIF
   ELSE
    CALL debugecho("No prefs returned")
    RETURN(ipreferror)
   ENDIF
   RETURN(preference_struct->prefs[1].pref_stat)
 END ;Subroutine
 SUBROUTINE (getprefbycontext(spreftofetch=vc,scontextstring=vc,svaluestring=vc,sretprefvalue=vc(ref)
  ) =i2)
   CALL debugecho("/********Entering GetPrefByContext********/")
   DECLARE istat = i2 WITH protect, noconstant(0)
   DECLARE iretstat = i2 WITH protect, noconstant(0)
   SET istat = alterlist(preference_struct->prefs,0)
   SET istat = alterlist(preference_struct->prefs,1)
   SET preference_struct->prefs[1].pref_name = spreftofetch
   SET preference_struct->prefs[1].pref_type = itypestr
   SET iretstat = getprefbystructsub(scontextstring,svaluestring,1)
   IF (iretstat != ipreffound)
    CALL debugecho("Preference not found")
    RETURN(iretstat)
   ENDIF
   IF (size(preference_struct->prefs,5) > 0)
    IF ((preference_struct->prefs[1].pref_stat=ipreffound))
     IF (size(preference_struct->prefs[1].pref_val,5) > 0)
      SET sretprefvalue = preference_struct->prefs[1].pref_val[1].val_str
      CALL debugecho(build("GetPrefByContext returning value: ",sretprefvalue))
     ELSE
      CALL debugecho("No pref_vals returned")
      RETURN(ipreferror)
     ENDIF
    ENDIF
   ELSE
    CALL debugecho("No prefs returned")
    RETURN(ipreferror)
   ENDIF
   RETURN(preference_struct->prefs[1].pref_stat)
 END ;Subroutine
 SUBROUTINE (getprefbystruct(scontextstring=vc,svaluestring=vc) =i2)
   DECLARE iretstat = i2 WITH protect, noconstant(0)
   SET iretstat = getprefbystructsub(scontextstring,svaluestring,0)
   RETURN(iretstat)
 END ;Subroutine
 SUBROUTINE (getprefbystructsub(scontextstring=vc,svaluestring=vc,bsimplepref=i2) =i2)
   CALL debugecho("/********Entering GetPrefByContext********/")
   DECLARE ssectionname = vc WITH protect, noconstant("config")
   DECLARE sgroupname = vc WITH protect, noconstant("medication_administration")
   DECLARE hpref = i4 WITH protect, noconstant(0)
   DECLARE hgroup = i4 WITH protect, noconstant(0)
   DECLARE hsection = i4 WITH protect, noconstant(0)
   DECLARE hgroup2 = i4 WITH protect, noconstant(0)
   DECLARE idxentry = h WITH protect, noconstant(0)
   DECLARE status = i2 WITH protect, noconstant(0)
   DECLARE entrycount = h WITH protect, noconstant(0)
   DECLARE idxval = h WITH protect, noconstant(0)
   DECLARE hentry = h WITH protect, noconstant(0)
   DECLARE attrcount = h WITH protect, noconstant(0)
   DECLARE idxattr = h WITH protect, noconstant(0)
   DECLARE hattr = i4 WITH protect, noconstant(0)
   DECLARE valcount = h WITH protect, noconstant(0)
   DECLARE hval = i4 WITH protect, noconstant(0)
   DECLARE attrname = c100
   DECLARE entryname = c100
   DECLARE namelen = h WITH noconstant(100)
   DECLARE valname = c100
   DECLARE stempstring = c20 WITH public, noconstant("")
   DECLARE iretstat = i2 WITH protect, noconstant(0)
   CALL debugecho(build("Fetching preference at level: ",scontextstring))
   CALL debugecho(build("Fetching preference for context_id: ",svaluestring))
   CALL debugecho(build("Fetching preference from section: ",ssectionname))
   CALL debugecho(build("Fetching preference from group: ",sgroupname))
   CALL cnvtprefnamestoupper(null)
   IF (initalizeprefread(null)=ipreferror)
    CALL debugecho("Error Setting up to read Preferences")
    CALL releasehandles(null)
    RETURN(ipreferror)
   ENDIF
   SET status = uar_prefperform(hpref)
   IF (status != 1)
    CALL debugecho("Error:GetPrefByContext - Failed to perform.")
    CALL releasehandles(null)
    RETURN(ipreferror)
   ENDIF
   SET iretstat = proccessprefreply(null)
   CALL releasehandles(null)
   RETURN(iretstat)
 END ;Subroutine
 SUBROUTINE releasehandles(null)
   CALL debugecho("Cleaning up...")
   IF (hattr > 0)
    CALL debugecho("Destroyed hAttr")
    SET status = uar_prefdestroyinstance(hattr)
   ENDIF
   IF (hgroup > 0)
    CALL debugecho("Destroyed hGroup")
    SET status = uar_prefdestroygroup(hgroup)
   ENDIF
   IF (hgroup2 > 0)
    CALL debugecho("Destroyed hGroup2")
    SET status = uar_prefdestroygroup(hgroup2)
   ENDIF
   IF (hsection > 0)
    CALL debugecho("Destroyed hSection")
    SET status = uar_prefdestroysection(hsection)
   ENDIF
   IF (hpref > 0)
    CALL debugecho("Destroyed hPref")
    SET status = uar_prefdestroyinstance(hpref)
   ENDIF
   CALL debugecho("...Done Cleaning")
 END ;Subroutine
 SUBROUTINE proccesssingleprefread(null)
   CALL debugecho("Proccessing a Single Pref Value...")
   DECLARE idxsearch = i4 WITH protect, noconstant(0)
   DECLARE idxfound = i4 WITH protect, noconstant(0)
   DECLARE istat = i4 WITH protect, noconstant(0)
   DECLARE iprefvalcnt = i4 WITH protect, noconstant(0)
   DECLARE upentryname = c100 WITH protect, noconstant("")
   SET upentryname = cnvtupper(trim(entryname,3))
   SET idxfound = locateval(idxsearch,1,size(preference_struct->prefs,5),upentryname,
    preference_struct->prefs[idxsearch].pref_name_upper)
   IF (idxfound > 0)
    SET iprefvalcnt = (size(preference_struct->prefs[idxfound].pref_val,5)+ 1)
    SET istat = alterlist(preference_struct->prefs[idxfound].pref_val,iprefvalcnt)
    IF ((preference_struct->prefs[idxfound].pref_type=itypestr))
     SET preference_struct->prefs[idxfound].pref_val[iprefvalcnt].val_str = valname
     CALL debugecho(build("/* Preference found raw value: ",valname," converted value: ",
       preference_struct->prefs[idxfound].pref_val[iprefvalcnt].val_str," */"))
     SET preference_struct->prefs[idxfound].pref_stat = ipreffound
    ELSEIF ((preference_struct->prefs[idxfound].pref_type=itypedbl))
     SET preference_struct->prefs[idxfound].pref_val[iprefvalcnt].val_dbl = cnvtreal(trim(valname,3))
     CALL debugecho(build("/* Preference found raw value: ",valname," converted value: ",
       preference_struct->prefs[idxfound].pref_val[iprefvalcnt].val_dbl," */"))
     SET preference_struct->prefs[idxfound].pref_stat = ipreffound
    ELSEIF ((preference_struct->prefs[idxfound].pref_type=itypeint))
     SET preference_struct->prefs[idxfound].pref_val[iprefvalcnt].val_int = cnvtint(trim(valname,3))
     CALL debugecho(build("/* Preference found raw value: ",valname," converted value: ",
       preference_struct->prefs[idxfound].pref_val[iprefvalcnt].val_int," */"))
     SET preference_struct->prefs[idxfound].pref_stat = ipreffound
    ELSE
     SET iprefvalcnt -= 1
     SET istat = alterlist(preference_struct->prefs[idxfound].pref_val,iprefvalcnt)
     CALL debugecho("...Unknown Pref Type")
     RETURN(iprefnotfound)
    ENDIF
    CALL debugecho("...Pref Found And Added")
    RETURN(ipreffound)
   ENDIF
   CALL debugecho("... Pref not matched")
   RETURN(iprefnotfound)
 END ;Subroutine
 SUBROUTINE initalizeprefread(null)
   CALL debugecho("Initalizing for pref read...")
   DECLARE idxit = i4 WITH protect, noconstant(0)
   FOR (idxit = 1 TO size(preference_struct->prefs,5))
    SET preference_struct->prefs[idxit].pref_stat = iprefnotfound
    SET istat = alterlist(preference_struct->prefs[idxit].pref_val,0)
   ENDFOR
   EXECUTE prefrtl
   SET hpref = uar_prefcreateinstance(0)
   IF (hpref=0)
    CALL debugecho("Error:GetPrefByContext - Invalid hPref handle. Try logging in.")
    RETURN(ipreferror)
   ENDIF
   SET status = uar_prefaddcontext(hpref,nullterm(scontextstring),nullterm(svaluestring))
   IF (status != 1)
    CALL debugecho(build("Error:GetPrefByContext - Failed to add context: ",stempcontlvl))
    RETURN(ipreferror)
   ENDIF
   SET status = uar_prefsetsection(hpref,nullterm(ssectionname))
   IF (status != 1)
    CALL debugecho(build("Error:GetPrefByContext - Failed to set",ssectionname," section."))
    RETURN(ipreferror)
   ENDIF
   SET hgroup = uar_prefcreategroup()
   IF (hgroup=0)
    CALL debugecho("Error:GetPrefByContext - Failed to create group.")
    RETURN(ipreferror)
   ENDIF
   SET status = uar_prefsetgroupname(hgroup,nullterm(sgroupname))
   IF (status != 1)
    CALL debugecho(build("Error:GetPrefByContext - Failed to set ",sgroupname," group."))
    RETURN(ipreferror)
   ENDIF
   SET status = uar_prefaddgroup(hpref,hgroup)
   IF (status != 1)
    CALL debugecho("Error:GetPrefByContext - Failed to add group.")
    CALL releasehandles(null)
    RETURN(ipreferror)
   ENDIF
   CALL debugecho("...Initalize Complete")
   RETURN(iprefnotfound)
 END ;Subroutine
 SUBROUTINE proccessprefreply(null)
   CALL debugecho("Processing returned prefrences...")
   DECLARE iprefsubstatus = i4 WITH protect, noconstant(0)
   DECLARE batleastonepreffound = i2 WITH protect, noconstant(0)
   SET hsection = uar_prefgetsectionbyname(hpref,nullterm(ssectionname))
   IF (hsection=0)
    CALL debugecho(build("Error:GetPrefByContext - Failed to get",ssectionname," section."))
    RETURN(ipreferror)
   ENDIF
   SET hgroup2 = uar_prefgetgroupbyname(hsection,nullterm(sgroupname))
   IF (hgroup2=0)
    CALL echo(build("Error:GetPrefByContext - Failed to get ",sgroupname," group."))
    RETURN(ipreferror)
   ENDIF
   SET entrycount = 0
   SET status = uar_prefgetgroupentrycount(hgroup2,entrycount)
   IF (status != 1)
    CALL debugecho("Error:GetPrefByContext - Failed to get number of entry count.")
    RETURN(ipreferror)
   ENDIF
   FOR (idxentry = 0 TO (entrycount - 1))
     SET entryname = ""
     SET namelen = 100
     SET hentry = uar_prefgetgroupentry(hgroup2,idxentry)
     SET status = uar_prefgetentryname(hentry,entryname,namelen)
     CALL debugecho("Entry Found")
     CALL debugecho(build("entryName: ",entryname,"|<END"))
     SET attrcount = 0
     SET status = uar_prefgetentryattrcount(hentry,attrcount)
     IF (status != 1)
      CALL debugecho("GetPrefByContext - Invalid entryAttrCount.")
     ELSE
      FOR (idxattr = 0 TO (attrcount - 1))
        SET attrname = ""
        SET namelen = 100
        SET hattr = uar_prefgetentryattr(hentry,idxattr)
        SET status = uar_prefgetattrname(hattr,attrname,namelen)
        CALL debugecho("Attribute Found")
        CALL debugecho(build("attrName: ",attrname,"|<END"))
        SET valcount = 0
        SET status = uar_prefgetattrvalcount(hattr,valcount)
        FOR (idxval = 0 TO (valcount - 1))
          SET valname = ""
          SET namelen = 100
          SET hval = uar_prefgetattrval(hattr,valname,namelen,idxval)
          CALL debugecho("Preference Found")
          CALL debugecho(build("valName: ",valname,"|<END"))
          SET iprefsubstatus = proccesssingleprefread(null)
          IF (iprefsubstatus=ipreferror)
           CALL debugecho("...ERROR FOUND ")
           RETURN(ipreferror)
          ELSEIF (iprefsubstatus=ipreffound)
           SET batleastonepreffound = 1
           IF (bsimplepref)
            CALL debugecho("...Simple Pref Found, Return")
           ENDIF
          ENDIF
        ENDFOR
      ENDFOR
     ENDIF
   ENDFOR
   IF (batleastonepreffound=1)
    CALL debugecho(build("Matching Prefs Found"))
    CALL debugecho("...Processing Complete")
    RETURN(ipreffound)
   ELSE
    CALL debugecho(build("No Matching Preference found."))
    CALL debugecho("...Processing Complete")
    RETURN(iprefnotfound)
   ENDIF
 END ;Subroutine
 SUBROUTINE (debugecho(sprint=vc) =null)
   IF (validate(request->debug_ind,1))
    CALL echo(sprint)
   ENDIF
 END ;Subroutine
 SUBROUTINE cnvtprefnamestoupper(null)
   CALL debugecho("Capitalize all requested pref names...")
   DECLARE idxpref = i4 WITH protect, noconstant(0)
   FOR (idxpref = 1 TO size(preference_struct->prefs,5))
     SET preference_struct->prefs[idxpref].pref_name_upper = cnvtupper(trim(preference_struct->prefs[
       idxpref].pref_name,3))
   ENDFOR
   CALL debugecho("...Done capitalizing")
 END ;Subroutine
 SUBROUTINE (finditembyidentifiergeneric(sidentifierin=vc,didentifiertypecd=f8,lsrchidx=i4,
  ibarcodeextractiontypes=i2,iexcludetype=i2) =null)
   CALL echo(
    "bsc_process_med_generic.inc - ****** Entering FindItemByIdentifierGeneric Subroutine ******")
   DECLARE nobjstatus = i2 WITH private, noconstant(0)
   DECLARE lreplycnt = i4 WITH protect, noconstant(0)
   DECLARE lsyncnt = i4 WITH protect, noconstant(0)
   DECLARE lrtecnt = i4 WITH protect, noconstant(0)
   DECLARE dstatus = i2 WITH private, noconstant(0)
   DECLARE iexistingcnt = i4 WITH private, noconstant(0)
   DECLARE inewcnt = i4 WITH private, noconstant(0)
   DECLARE lidentcnt = i4 WITH private, noconstant(0)
   DECLARE formulary_source_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002358,
     "RXFORMULARY"))
   IF (debug_ind > 0)
    CALL echo(build("bsc_process_med_generic.inc - sIdentifierIn:",sidentifierin))
    CALL echo(build("bsc_process_med_generic.inc - dIdentifierTypeCd:",didentifiertypecd))
   ENDIF
   IF (textlen(sidentifierin) <= 0)
    RETURN
   ENDIF
   SET nobjstatus = checkprg("RX_GET_PRODUCT_SEARCH")
   IF (nobjstatus > 0
    AND bnewmodelchk=1)
    DECLARE lcnt = i4 WITH protect, noconstant(0)
    DECLARE litemcnt = i4 WITH protect, noconstant(0)
    DECLARE lreplysize = i4 WITH protect, noconstant(0)
    RECORD search_request(
      1 search_string = vc
      1 item_id_ind = i2
      1 item_id = f8
      1 ident_qual[*]
        2 identifier_type_cd = f8
      1 other_identifier_cd = f8
      1 med_type_qual[*]
        2 med_type_flag = i2
      1 med_filter_ind = i2
      1 intermittent_filter_ind = i2
      1 continuous_filter_ind = i2
      1 tpn_filter_ind = i2
      1 fac_qual[*]
        2 facility_cd = f8
      1 disp_loc_cd = f8
      1 show_all_ind = i2
      1 formulary_status_cd = f8
      1 set_items_ind = i2
      1 set_med_type_qual[*]
        2 set_med_type_flag = i2
      1 active_ind = i2
      1 pharmacy_type_cd = f8
      1 prev_item_id = f8
      1 max_rec = i4
      1 full_search_string = vc
      1 item_qual[*]
        2 item_id = f8
        2 med_product_id = f8
      1 exclude_fac_flex_ind = i2
      1 qoh_loc1_cd = f8
      1 qoh_loc2_cd = f8
      1 stock_pkg_for_qoh_ind = i2
      1 inv_track_level_ind = i2
      1 pharm_loc_cd = f8
    )
    RECORD search_reply(
      1 items[*]
        2 item_id = f8
        2 active_ind = i2
        2 manf_item_id = f8
        2 med_type_flag = i2
        2 med_filter_ind = i2
        2 intermittent_filter_ind = i2
        2 continuous_filter_ind = i2
        2 tpn_filter_ind = i2
        2 oe_format_flag = i2
        2 dispense_category_cd = f8
        2 formulary_status_cd = f8
        2 formulary_status = vc
        2 ndc = vc
        2 mnemonic = vc
        2 generic_name = vc
        2 description = vc
        2 brand_name = vc
        2 charge_number = vc
        2 other_identifier = vc
        2 strength_form = vc
        2 form_cd = f8
        2 form = vc
        2 strength = f8
        2 strength_unit_cd = f8
        2 strength_unit = vc
        2 volume = f8
        2 volume_unit_cd = f8
        2 volume_unit = vc
        2 primary_ind = i2
        2 brand_ind = i2
        2 divisble_ind = i2
        2 price_sched_id = f8
        2 dispense_qty = f8
        2 dispense_qty_unit_cd = f8
        2 manufacturer = vc
        2 facs[*]
          3 facility_cd = f8
          3 facility = vc
        2 med_product_id = f8
        2 inner_ndc = vc
        2 qoh_exists_ind_loc1 = i2
        2 qoh_loc1 = f8
        2 qoh_loc1_unit = vc
        2 qoh_exists_ind_loc2 = i2
        2 qoh_loc2 = f8
        2 qoh_loc2_unit = vc
      1 elapsed_time = f8
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    )
    SET search_request->search_string = cnvtupper(cnvtalphanum(sidentifierin))
    IF (didentifiertypecd > 0)
     SET dstat = alterlist(search_request->ident_qual,1)
     SET search_request->ident_qual[1].identifier_type_cd = didentifiertypecd
    ELSEIF (lsrchidx > 0)
     IF (debug_ind > 0)
      CALL echo(build("bsc_process_med_finditembyidentifier.inc - lSrchIdx:",lsrchidx))
     ENDIF
     SET lidentcnt = 0
     FOR (lcnt = 1 TO processing_rules->qual[lsrchidx].ident_qual_cnt)
       IF (((band(ibarcodeextractiontypes,processing_rules->qual[lsrchidx].ident_qual[lcnt].
        identifier_extraction_type) > 0
        AND iexcludetype=0) OR (band(ibarcodeextractiontypes,processing_rules->qual[lsrchidx].
        ident_qual[lcnt].identifier_extraction_type)=0
        AND iexcludetype=1)) )
        SET lidentcnt += 1
        IF (mod(lidentcnt,10)=1)
         SET dstat = alterlist(search_request->ident_qual,(lidentcnt+ 9))
        ENDIF
        SET search_request->ident_qual[lidentcnt].identifier_type_cd = processing_rules->qual[
        lsrchidx].ident_qual[lcnt].identifier_type_cd
       ENDIF
     ENDFOR
     SET dstat = alterlist(search_request->ident_qual,lidentcnt)
    ELSE
     FREE RECORD search_request
     FREE RECORD search_reply
     RETURN
    ENDIF
    SET dstat = alterlist(search_request->med_type_qual,2)
    SET search_request->med_type_qual[1].med_type_flag = 0
    SET search_request->med_type_qual[2].med_type_flag = 2
    SET search_request->med_filter_ind = 1
    SET search_request->intermittent_filter_ind = 1
    SET search_request->continuous_filter_ind = 1
    IF (dfacilitycd >= 0)
     SET dstat = alterlist(search_request->fac_qual,2)
     SET search_request->fac_qual[1].facility_cd = 0
     SET search_request->fac_qual[2].facility_cd = dfacilitycd
    ENDIF
    SET search_request->show_all_ind = 0
    SET search_request->set_items_ind = 0
    SET search_request->active_ind = 1
    SET search_request->pharmacy_type_cd = cinpatient
    SET search_request->max_rec = 10
    IF (debug_ind > 0)
     CALL echo("bsc_process_med_generic - Request to RX_GET_PRODUCT_SEARCH:")
     CALL echorecord(search_request)
    ENDIF
    SET modify = nopredeclare
    EXECUTE rx_get_product_search  WITH replace("REQUEST",search_request), replace("REPLY",
     search_reply)
    SET modify = predeclare
    IF (debug_ind > 0)
     CALL echo("bsc_process_med_generic - Reply from RX_GET_PRODUCT_SEARCH:")
     CALL echorecord(search_reply)
    ENDIF
    IF ((search_reply->status_data.status="S"))
     SET litemcnt = size(search_reply->items,5)
     SET sndcreturned = search_reply->items[1].ndc
    ENDIF
    SET inewcnt = size(search_reply->items,5)
    IF (inewcnt > 0)
     SET iexistingcnt = size(items->qual,5)
     SET dstat = alterlist(items->qual,(inewcnt+ iexistingcnt))
     FOR (lcnt = 1 TO inewcnt)
       SET items->qual[(iexistingcnt+ lcnt)].item_id = search_reply->items[lcnt].item_id
       SET items->qual[(iexistingcnt+ lcnt)].barcode = search_request->search_string
       SET items->qual[(iexistingcnt+ lcnt)].med_product_id = search_reply->items[lcnt].
       med_product_id
     ENDFOR
     SET barcode_source_cd = formulary_source_cd
    ELSE
     IF (debug_ind > 0)
      CALL echo("*** FindItemByIdentifierGeneric - No order catalogs could be found in the formulary"
       )
     ENDIF
    ENDIF
    FREE RECORD search_request
    FREE RECORD search_reply
   ENDIF
   IF (debug_ind > 0)
    CALL echorecord(items)
   ENDIF
   CALL echo(
    "bsc_process_med_generic.inc - ****** Exiting FindItemByIdentifierGeneric Subroutine ******")
 END ;Subroutine
 SELECT INTO "nl:"
  FROM dm_prefs dmp
  WHERE dmp.application_nbr=300000
   AND dmp.person_id=0
   AND dmp.pref_domain="PHARMNET-INPATIENT"
   AND dmp.pref_section="FRMLRYMGMT"
   AND dmp.pref_name="NEW MODEL"
  DETAIL
   IF (dmp.pref_nbr=1)
    bnewmodelchk = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (debug_ind > 0)
  CALL echo(build("bsc_extract_med_identifiers - bNewModelChk:",bnewmodelchk))
 ENDIF
 SET reply->prefs.bnewmodelchk = bnewmodelchk
 SET reply->status_data.status = "F"
 CALL getorgidandfacilitycd(request->location_cd)
 SET sbarcode = trim(request->barcode,3)
 SET lbarcodelength = textlen(sbarcode)
 IF (debug_ind > 0)
  CALL echo(build("bsc_extract_med_identifiers - sBarcode:",request->barcode))
  CALL echo(build("bsc_extract_med_identifiers - lBarcodeLength:",lbarcodelength))
  CALL echo(build("bsc_extract_med_identifiers - request:",request))
 ENDIF
 IF (lbarcodelength <= 0)
  CALL addexecutionnote("Invalid Barcode - empty barcode submitted")
  GO TO exit_script
 ENDIF
 IF (debug_ind > 0)
  CALL echo(build("bsc_extract_med_identifiers - Barcode:",sbarcode))
 ENDIF
 CALL getpocprefs(null)
 IF (bnewmodelchk=1)
  CALL getpmipref(null)
  IF (proc_pref_items_ind=1
   AND size(preferred_identifiers->list,5) > 0)
   CALL processpreferreditems(null)
  ENDIF
  IF (((proc_pref_items_ind=0) OR ((reply->prefs.scanning_lookup_level != 2))) )
   CALL getprefix(sbarcode,sbarcodeprefix)
   CALL getzdata(sbarcode,sbarcodezdata)
   IF (((textlen(trim(sbarcodeprefix,3)) > 0) OR (textlen(trim(sbarcodezdata,3)) > 0)) )
    CALL processidentifier(sbarcodeprefix,sbarcodezdata,sbarcode,0,prefixtype)
   ELSE
    SET bprocessed = 1
    CALL processgs1identifiers(sbarcode)
    CALL processndc(sbarcode,ndctype)
    CALL processmckesson(sbarcode)
    CALL processomnicell(sbarcode)
   ENDIF
   CALL processidentifier("","",sbarcode,0,rawtype)
  ENDIF
 ENDIF
 IF ((reply->prefs.scanning_lookup_level=1))
  IF (debug_ind > 0)
   CALL echo("bsc_extract_med_identifiers - scanning_lookup_level pref=1")
  ENDIF
  CALL addexecutionnote(
   "Multum NDC lookup will not be used, due to preference scanning_lookup_level = 1")
 ELSEIF ((reply->prefs.scanning_lookup_level=0))
  IF (debug_ind > 0)
   CALL echo("bsc_extract_med_identifiers - scanning_lookup_level pref=0")
  ENDIF
  IF (bprocessed=0)
   CALL processgs1identifiers(sbarcode)
   CALL processndc(sbarcode,ndctype)
   CALL processmckesson(sbarcode)
  ENDIF
 ENDIF
 CALL processrules(sbarcode)
#exit_script
 FREE RECORD barcode
 FREE RECORD temp_ident
 FREE RECORD preferred_identifiers
 FREE RECORD poc_parsing_rules
 FREE RECORD ndc_parsing_rules
 CALL recordauditinfo(null)
 SET errcode = error(errmsg,1)
 IF (errcode > 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus.operationname = errmsg
 ELSEIF (size(reply->qual,5) > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 IF (debug_ind > 0)
  CALL echorecord(reply)
 ENDIF
 SET elapsed_time = ((curtime3 - start_time)/ 100)
 CALL addexecutionnote(build("bsc_extract_med_identifiers script elapsed time (seconds): ",
   elapsed_time))
 SUBROUTINE (addtosearchstructure(ssearchstring=vc,didentifiertypecd=f8,ibarcodeextractiontype=i2) =
  null)
   CALL echo("bsc_extract_med_identifiers - ****** Entering AddToSearchStructure Subroutine ******")
   DECLARE lidx = i4 WITH protect, noconstant(0)
   DECLARE lcnt = i4 WITH protect, noconstant(0)
   DECLARE lprevcnt = i4 WITH protect, noconstant(0)
   DECLARE lsearch = i4 WITH protect, noconstant(0)
   DECLARE lidentpos = i4 WITH protect, noconstant(0)
   IF (textlen(ssearchstring) > 0)
    SET lidx = locateval(lcnt,1,size(reply->qual,5),ssearchstring,reply->qual[lcnt].search_string)
    IF (lidx=0)
     SET lidx = (size(reply->qual,5)+ 1)
     SET dstat = alterlist(reply->qual,lidx)
     SET reply->qual[lidx].search_string = trim(ssearchstring,3)
     SET reply->qual[lidx].barcode_extraction_type = ibarcodeextractiontype
    ELSE
     SET reply->qual[lidx].barcode_extraction_type = bor(reply->qual[lidx].barcode_extraction_type,
      ibarcodeextractiontype)
    ENDIF
    SET lprevcnt = reply->qual[lidx].ident_qual_cnt
    IF (didentifiertypecd > 0)
     SET lidentpos = locateval(lsearch,1,size(reply->qual[lidx].ident_qual,5),didentifiertypecd,reply
      ->qual[lidx].ident_qual[lsearch].identifier_type_cd)
     IF (lidentpos=0)
      SET reply->qual[lidx].ident_qual_cnt = (lprevcnt+ 1)
      SET dstat = alterlist(reply->qual[lidx].ident_qual,(lprevcnt+ 1))
      SET reply->qual[lidx].ident_qual[(lprevcnt+ 1)].identifier_type_cd = didentifiertypecd
      SET reply->qual[lidx].ident_qual[(lprevcnt+ 1)].identifier_extraction_type =
      ibarcodeextractiontype
     ELSE
      SET reply->qual[lidx].ident_qual[lidentpos].identifier_extraction_type = bor(reply->qual[lidx].
       ident_qual[lidentpos].identifier_extraction_type,ibarcodeextractiontype)
     ENDIF
    ELSEIF ((temp_ident->ident_qual_cnt > 0))
     FOR (lcnt = 1 TO temp_ident->ident_qual_cnt)
      SET lidentpos = locateval(lsearch,1,size(reply->qual[lidx].ident_qual,5),temp_ident->
       ident_qual[lcnt].identifier_type_cd,reply->qual[lidx].ident_qual[lsearch].identifier_type_cd)
      IF (lidentpos=0)
       SET reply->qual[lidx].ident_qual_cnt = (lprevcnt+ temp_ident->ident_qual_cnt)
       SET dstat = alterlist(reply->qual[lidx].ident_qual,reply->qual[lidx].ident_qual_cnt)
       SET reply->qual[lidx].ident_qual[(lprevcnt+ lcnt)].identifier_type_cd = temp_ident->
       ident_qual[lcnt].identifier_type_cd
       SET reply->qual[lidx].ident_qual[(lprevcnt+ lcnt)].identifier_extraction_type =
       ibarcodeextractiontype
      ELSE
       SET reply->qual[lidx].ident_qual[lidentpos].identifier_extraction_type = bor(reply->qual[lidx]
        .ident_qual[lidentpos].identifier_extraction_type,ibarcodeextractiontype)
      ENDIF
     ENDFOR
     SET dstat = alterlist(temp_ident->ident_qual,0)
    ENDIF
   ENDIF
   CALL echo("bsc_extract_med_identifiers - ****** Exiting AddToSearchStructure Subroutine ******")
 END ;Subroutine
 SUBROUTINE (determineidentifiertypes(sbcprefix=vc,sbczdata=vc,ipreferredonly=i2) =null)
   CALL echo(
    "bsc_extract_med_identifiers - ****** Entering DetermineIdentifierTypes Subroutine ******")
   DECLARE lcnt = i4 WITH protect, noconstant(0)
   DECLARE lformatcnt = i4 WITH protect, noconstant(0)
   DECLARE lmatchcnt = i4 WITH protect, noconstant(0)
   DECLARE dbarcodetypecd = f8 WITH protect, noconstant(0.0)
   DECLARE sidentmeaning = c12 WITH protect, noconstant("")
   DECLARE didenttypecd = f8 WITH protect, noconstant(0.0)
   DECLARE lpreferredcnt = i4 WITH protect, noconstant(0)
   SET dstat = alterlist(temp_ident->ident_qual,0)
   SET lformatcnt = size(barcode->format,5)
   IF (ipreferredonly=0)
    FOR (lcnt = 1 TO lformatcnt)
      IF ((trim(sbcprefix,3)=barcode->format[lcnt].prefix)
       AND (trim(sbczdata,3)=barcode->format[lcnt].z_data))
       IF (debug_ind > 0)
        CALL echo(build(
          "bsc_extract_med_identifiers - Successfully matched prefix and z-data with barcode format:",
          barcode->format[lcnt].barcode_type_cd))
       ENDIF
       SET dbarcodetypecd = barcode->format[lcnt].barcode_type_cd
       SET sidentmeaning = trim(uar_get_code_meaning(dbarcodetypecd),3)
       SET dstat = uar_get_meaning_by_codeset(11000,sidentmeaning,1,didenttypecd)
       IF (didenttypecd > 0)
        SET lmatchcnt += 1
        SET dstat = alterlist(temp_ident->ident_qual,lmatchcnt)
        SET temp_ident->ident_qual[lmatchcnt].identifier_type_cd = didenttypecd
       ENDIF
      ENDIF
    ENDFOR
   ELSE
    FOR (lcnt = 1 TO lformatcnt)
      SET lpreferredcnt = size(preferred_identifiers->list,5)
      CALL echo(build("lPreferredCnt: ",lpreferredcnt))
      CALL echorecord(preferred_identifiers)
      FOR (lcnt2 = 1 TO lpreferredcnt)
        IF ((barcode->format[lcnt].barcode_type_cd=preferred_identifiers->list[lcnt2].code_value))
         IF ((sbcprefix=barcode->format[lcnt].prefix)
          AND (sbczdata=barcode->format[lcnt].z_data))
          IF (debug_ind > 0)
           CALL echo(build("bsc_extract_med_identifiers - Successfully matched prefix and z-data ",
             "with barcode format:",barcode->format[lcnt].barcode_type_cd))
          ENDIF
          SET dbarcodetypecd = barcode->format[lcnt].barcode_type_cd
          SET sidentmeaning = trim(uar_get_code_meaning(dbarcodetypecd),3)
          SET dstat = uar_get_meaning_by_codeset(11000,sidentmeaning,1,didenttypecd)
          IF (didenttypecd > 0)
           SET lmatchcnt += 1
           SET dstat = alterlist(temp_ident->ident_qual,lmatchcnt)
           SET temp_ident->ident_qual[lmatchcnt].identifier_type_cd = didenttypecd
          ENDIF
         ENDIF
        ENDIF
      ENDFOR
    ENDFOR
   ENDIF
   SET temp_ident->ident_qual_cnt = lmatchcnt
   CALL echo(
    "bsc_extract_med_identifiers - ****** Exiting DetermineIdentifierTypes Subroutine ******")
 END ;Subroutine
 SUBROUTINE getbarcodeformats(null)
   CALL echo("bsc_extract_med_identifiers - ****** Entering GetBarcodeFormats Subroutine ******")
   DECLARE lcnt = i4 WITH protect, noconstant(0)
   IF (bbarcodeformatsloaded=0)
    SET bbarcodeformatsloaded = 1
    IF (dorgid > 0)
     SELECT INTO "nl:"
      FROM org_barcode_org obo,
       org_barcode_format obf
      PLAN (obo
       WHERE obo.scan_organization_id IN (0, dorgid))
       JOIN (obf
       WHERE ((obf.organization_id=obo.label_organization_id
        AND obo.scan_organization_id > 0) OR (obf.organization_id=dorgid
        AND obo.scan_organization_id=0)) )
      HEAD REPORT
       lcnt = 0
      DETAIL
       IF (uar_get_code_meaning(obf.barcode_type_cd) IN ("CDM", "DESC", "DESC_SHORT", "GENERIC_NAME",
       "BRAND_NAME",
       "PYXIS", "UB92", "HCPCS", "RX MISC1", "RX MISC2",
       "RX MISC3", "RX MISC4", "RX MISC5", "RX DEVICE1", "RX DEVICE2",
       "RX DEVICE3", "RX DEVICE4", "RX DEVICE5"))
        lcnt += 1
        IF (mod(lcnt,10)=1)
         dstat = alterlist(barcode->format,(lcnt+ 9))
        ENDIF
        barcode->format[lcnt].barcode_type_cd = obf.barcode_type_cd, barcode->format[lcnt].prefix =
        trim(obf.prefix), barcode->format[lcnt].z_data = trim(obf.z_data)
       ENDIF
      FOOT REPORT
       dstat = alterlist(barcode->format,lcnt)
      WITH nocounter
     ;end select
     IF (lcnt=0)
      IF (debug_ind > 0)
       CALL echo(concat("*** No identifier barcode formats qualified for organization_id: ",
         cnvtstring(dorgid,20,2)))
      ENDIF
      RETURN
     ENDIF
    ENDIF
    IF (debug_ind > 0)
     CALL echorecord(barcode)
    ENDIF
   ENDIF
   CALL echo("bsc_extract_med_identifiers - ****** Exiting GetBarcodeFormats Subroutine ******")
 END ;Subroutine
 SUBROUTINE (getorgidandfacilitycd(dlocationcd=f8) =null)
   CALL echo("bsc_extract_med_identifiers - ****** Entering GetOrgIdAndFacilityCd Subroutine ******")
   IF (debug_ind > 0)
    CALL echo(build("bsc_extract_med_identifiers - Our starting location is:",dlocationcd))
   ENDIF
   SELECT INTO "nl:"
    FROM location l
    WHERE l.location_cd=dlocationcd
     AND l.active_ind=1
    DETAIL
     dorgid = l.organization_id
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL echo(concat("*** Organization not found for location_cd: ",cnvtstring(dlocationcd,20,2)))
   ELSEIF (curqual > 1)
    SET dorgid = 0
    CALL echo(concat("*** Multiple orgs found for location_cd: ",cnvtstring(dlocationcd,20,2)))
   ENDIF
   IF (uar_get_code_meaning(dlocationcd)="FACILITY")
    SET reply->facility_cd = dlocationcd
   ELSE
    DECLARE nobjstatus = i2 WITH private, noconstant(0)
    SET nobjstatus = checkprg("DCP_GET_LOC_PARENT_HIERARCHY")
    IF (debug_ind > 0)
     CALL echo(build(
       "bsc_extract_med_identifiers - dcp_get_loc_parent_hierarchy script object status:",nobjstatus)
      )
    ENDIF
    IF (nobjstatus > 0)
     RECORD loc_request(
       1 locations[*]
         2 location_cd = f8
       1 skip_org_security_ind = i2
     )
     RECORD loc_reply(
       1 facilities[*]
         2 facility_cd = f8
         2 facility_disp = c40
         2 facility_desc = c60
         2 buildings[*]
           3 building_cd = f8
           3 building_disp = c40
           3 building_desc = c60
           3 units[*]
             4 unit_cd = f8
             4 unit_disp = c40
             4 unit_desc = c60
             4 rooms[*]
               5 room_cd = f8
               5 room_disp = c40
               5 room_desc = c60
       1 status_data
         2 status = c1
         2 subeventstatus[1]
           3 operationname = c25
           3 operationstatus = c1
           3 targetobjectname = c25
           3 targetobjectvalue = vc
     )
     SET dstat = alterlist(loc_request->locations,1)
     SET loc_request->locations[1].location_cd = dlocationcd
     IF (debug_ind > 0)
      CALL echo("bsc_extract_med_identifiers - calling dcp_get_loc_parent_hierarchy")
     ENDIF
     SET modify = nopredeclare
     EXECUTE dcp_get_loc_parent_hierarchy  WITH replace("REQUEST",loc_request), replace("REPLY",
      loc_reply)
     SET modify = predeclare
     IF ((loc_reply->status_data.status="S"))
      DECLARE lsize = i4 WITH protect, noconstant(0)
      SET lsize = size(loc_reply->facilities,5)
      IF (lsize=1)
       SET reply->facility_cd = loc_reply->facilities[1].facility_cd
       CALL echo(build("Facility found for location_cd, facility_cd is: ",reply->facility_cd))
      ELSEIF (lsize=0)
       CALL echo(concat("Facility not found for location_cd: ",cnvtstring(dlocationcd,20,2)))
      ELSE
       CALL echo(concat("Multiple facilities found for location_cd: ",cnvtstring(dlocationcd,20,2)))
      ENDIF
     ENDIF
     FREE RECORD temp
     FREE RECORD loc_request
     FREE RECORD loc_reply
    ENDIF
   ENDIF
   CALL echo("bsc_extract_med_identifiers - ****** Exiting GetOrgIdAndFacilityCd Subroutine ******")
 END ;Subroutine
 SUBROUTINE (getprefix(sbarcodein=vc,sprefix=vc(ref)) =null)
   CALL echo("bsc_extract_med_identifiers - ****** Entering GetPrefix Subroutine ******")
   DECLARE lcnt = i4 WITH protect, noconstant(0)
   DECLARE schar = c1 WITH protect, noconstant("")
   FOR (lcnt = 1 TO textlen(sbarcodein))
    SET schar = substring(lcnt,1,sbarcodein)
    IF (isnumeric(schar)=1)
     SET sprefix = substring(1,(lcnt - 1),sbarcodein)
     SET lcnt = textlen(sbarcodein)
    ENDIF
   ENDFOR
   IF (debug_ind > 0)
    CALL echo(build("bsc_extract_med_identifiers - Prefix:",sprefix))
   ENDIF
   CALL echo("bsc_extract_med_identifiers - ****** Exiting GetPrefix Subroutine ******")
 END ;Subroutine
 SUBROUTINE (getzdata(sbarcodein=vc,szdata=vc(ref)) =null)
   CALL echo("bsc_extract_med_identifiers - ****** Entering GetZData Subroutine ******")
   DECLARE lpos = i4 WITH protect, noconstant(0)
   SET lpos = findstring("/Z",sbarcodein)
   IF (lpos > 0)
    SET szdata = substring((lpos+ 2),(textlen(sbarcodein) - (lpos+ 1)),sbarcodein)
   ENDIF
   IF (debug_ind > 0)
    CALL echo(build("bsc_extract_med_identifiers - Z-data:",szdata))
   ENDIF
   CALL echo("bsc_extract_med_identifiers - ****** Exiting GetZData Subroutine ******")
 END ;Subroutine
 SUBROUTINE (processidentifier(sbcprefix=vc,sbczdata=vc,sidentifierin=vc,ipreferredonly=i2,
  ibarcodeextractiontype=i2) =null)
   CALL echo("bsc_extract_med_identifiers - ****** Entering ProcessIdentifier Subroutine ******")
   DECLARE dbarcodetypecd = f8 WITH protect, noconstant(0.0)
   DECLARE lprefixlength = i4 WITH protect, noconstant(0)
   DECLARE lzdatalength = i4 WITH protect, noconstant(0)
   DECLARE sidentifier = vc WITH protect, noconstant("")
   DECLARE lidentlength = i4 WITH protect, noconstant(0)
   CALL getbarcodeformats(null)
   IF (size(barcode->format,5) > 0)
    CALL determineidentifiertypes(sbcprefix,sbczdata,ipreferredonly)
    IF ((temp_ident->ident_qual_cnt > 0))
     SET sidentifier = sidentifierin
     SET lprefixlength = textlen(trim(sbcprefix))
     SET lzdatalength = textlen(trim(sbczdata))
     IF (((lprefixlength > 0) OR (lzdatalength > 0)) )
      SET lidentlength = (textlen(trim(sidentifierin,3)) - lprefixlength)
      IF (lzdatalength > 0)
       SET lidentlength = ((lidentlength - lzdatalength) - 2)
      ENDIF
      SET sidentifier = substring((lprefixlength+ 1),lidentlength,sidentifierin)
     ENDIF
     CALL addtosearchstructure(sidentifier,0.0,ibarcodeextractiontype)
    ENDIF
   ENDIF
   CALL echo("bsc_extract_med_identifiers - ****** Exiting ProcessIdentifier Subroutine ******")
 END ;Subroutine
 SUBROUTINE (processmckesson(sbarcodein=vc) =null)
   CALL echo("bsc_extract_med_identifiers - ****** Entering ProcessMcKesson Subroutine ******")
   DECLARE sndc = c14 WITH protect, noconstant("")
   DECLARE sformatind = c1 WITH protect, noconstant("")
   DECLARE sexpdate = c6 WITH protect, noconstant("")
   IF (isnumeric(sbarcodein)=1
    AND lbarcodelength IN (16, 18)
    AND substring(1,1,sbarcodein)="3")
    SET sformatind = substring(12,1,sbarcodein)
    IF (sformatind="1")
     SET sndc = build("0",substring(2,10,sbarcodein))
    ELSEIF (sformatind="2")
     SET sndc = build(substring(2,5,sbarcodein),"0",substring(7,5,sbarcodein))
    ELSEIF (sformatind="3")
     SET sndc = build(substring(2,9,sbarcodein),"0",substring(11,1,sbarcodein))
    ENDIF
    SET sexpdate = trim(substring(13,(lbarcodelength - 12),sbarcodein))
    CALL validatemckessonexpirationdate(sexpdate)
    CALL addtosearchstructure(sndc,cndc,mckessontype)
   ENDIF
   CALL echo("bsc_extract_med_identifiers - ****** Exiting ProcessMcKesson Subroutine ******")
 END ;Subroutine
 SUBROUTINE (processndc(sbarcodein=vc,ibarcodeextractiontype=i2) =null)
   DECLARE char_cnt = i4 WITH noconstant(0)
   DECLARE temp_ndc1 = c37 WITH noconstant(fillstring(37," "))
   DECLARE temp_ndc2 = c77 WITH noconstant(fillstring(77," "))
   DECLARE temp_ndc3 = c11 WITH noconstant(fillstring(11," "))
   DECLARE temp_ndc4 = c77 WITH noconstant(fillstring(77," "))
   DECLARE idx = i4 WITH noconstant(0)
   DECLARE sfoundruleind = i2 WITH noconstant(0)
   DECLARE ialtbarcodeextractiontype = i4 WITH noconstant(0)
   CALL echo("bsc_extract_med_identifiers - ****** Entering ProcessNDC Subroutine ******")
   IF (ibarcodeextractiontype=gs1type)
    SET ialtbarcodeextractiontype = gs1alttype
   ELSE
    SET ialtbarcodeextractiontype = ndcalttype
   ENDIF
   SET temp_ndc1 = trim(cnvtalphanum(sbarcodein))
   SET temp_ndc4 = trim(sbarcodein)
   SET char_cnt = textlen(trim(temp_ndc4))
   FOR (idx = 1 TO size(ndc_parsing_rules->list,5))
     IF ((char_cnt=ndc_parsing_rules->list[idx].total_length))
      SET temp_ndc2 = substring((ndc_parsing_rules->list[idx].initial_skip+ 1),ndc_parsing_rules->
       list[idx].ident_length,temp_ndc4)
      SET sfoundruleind = 1
      SET idx = size(ndc_parsing_rules->list,5)
     ENDIF
   ENDFOR
   IF (sfoundruleind=1)
    SET char_cnt = textlen(trim(temp_ndc2))
    IF (char_cnt != 10
     AND char_cnt != 11)
     CALL addtosearchstructure(temp_ndc2,cndc,ialtbarcodeextractiontype)
    ENDIF
   ELSE
    SET char_cnt = textlen(trim(temp_ndc1))
    IF ( NOT (char_cnt IN (10, 11)))
     CALL addtosearchstructure(temp_ndc1,cndc,ialtbarcodeextractiontype)
    ENDIF
    IF (char_cnt=10)
     SET temp_ndc2 = temp_ndc1
    ELSEIF (char_cnt=11)
     SET temp_ndc2 = temp_ndc1
    ELSEIF (char_cnt=12)
     SET temp_ndc2 = substring(2,10,temp_ndc1)
    ELSEIF (char_cnt=13)
     SET temp_ndc2 = substring(3,10,temp_ndc1)
    ELSEIF (char_cnt=14)
     SET temp_ndc2 = substring(4,10,temp_ndc1)
    ELSEIF (char_cnt=15)
     SET temp_ndc2 = substring(4,10,temp_ndc1)
    ELSEIF (char_cnt=16)
     SET temp_ndc2 = substring(6,10,temp_ndc1)
    ELSEIF (((char_cnt=35) OR (((char_cnt=37) OR (((char_cnt=32) OR (char_cnt=33)) )) )) )
     SET temp_ndc2 = substring(6,10,temp_ndc1)
    ENDIF
   ENDIF
   SET char_cnt = textlen(trim(temp_ndc2))
   IF (char_cnt=11)
    CALL addtosearchstructure(temp_ndc2,cndc,ialtbarcodeextractiontype)
   ELSEIF (char_cnt=10)
    SET temp_ndc3 = trim(temp_ndc2)
    CALL finditembyidentifiergeneric(temp_ndc3,cndc,0,ibarcodeextractiontype,0)
    CALL addtosearchstructure(temp_ndc3,cndc,ibarcodeextractiontype)
    IF (size(items->qual,5) <= 0)
     IF (debug_ind > 0)
      CALL echo("bsc_process_med_barcode - No items found for 10 digit NDC, now padding")
     ENDIF
     SET temp_ndc3 = build("0",trim(temp_ndc2))
     CALL addtosearchstructure(temp_ndc3,cndc,ialtbarcodeextractiontype)
     SET temp_ndc3 = build(substring(1,5,temp_ndc2),"0",substring(6,5,temp_ndc2))
     CALL addtosearchstructure(temp_ndc3,cndc,ialtbarcodeextractiontype)
     SET temp_ndc3 = build(substring(1,9,temp_ndc2),"0",substring(10,1,temp_ndc2))
     CALL addtosearchstructure(temp_ndc3,cndc,ialtbarcodeextractiontype)
    ENDIF
   ENDIF
   CALL echo("bsc_extract_med_identifiers - ****** Exiting ProcessNDC Subroutine ******")
 END ;Subroutine
 SUBROUTINE (processomnicell(sbarcodein=vc) =null)
   CALL echo("bsc_extract_med_identifiers - ****** Entering ProcessOmnicell Subroutine ******")
   IF (isnumeric(sbarcodein)=1
    AND lbarcodelength=10
    AND substring(1,1,sbarcodein) IN ("0", "1"))
    DECLARE lcnt = i4 WITH protect, noconstant(0)
    DECLARE schar = c1 WITH protect, noconstant("")
    DECLARE nvalid = i2 WITH protect, noconstant(1)
    FOR (lcnt = 6 TO lbarcodelength)
     SET schar = substring(lcnt,1,sbarcodein)
     IF ( NOT (schar IN ("0", "1")))
      SET nvalid = 0
      SET lcnt = lbarcodelength
     ENDIF
    ENDFOR
    IF (nvalid=1)
     CALL processidentifier("","",substring(2,4,sbarcodein),0,omnicelltype)
    ENDIF
   ENDIF
   CALL echo("bsc_extract_med_identifiers - ****** Exiting ProcessOmnicell Subroutine ******")
 END ;Subroutine
 SUBROUTINE (validatemckessonexpirationdate(sexpdatein=vc) =null)
   IF (textlen(trim(sexpdatein))=4)
    CALL validateexpirationdate(substring(3,2,sexpdatein),substring(1,2,sexpdatein),"00")
   ELSEIF (textlen(trim(sexpdatein))=6)
    CALL validateexpirationdate(substring(5,2,sexpdatein),substring(1,2,sexpdatein),substring(3,2,
      sexpdatein))
   ELSE
    SET reply->expiration_ind = 0
    CALL echo("bsc_extract_med_identifiers - McKesson Invalid Expiration Date Format")
   ENDIF
 END ;Subroutine
 SUBROUTINE (validategs1expirationdate(sexpdatein=vc) =null)
   IF (textlen(trim(sexpdatein))=6)
    CALL validateexpirationdate(substring(1,2,sexpdatein),substring(3,2,sexpdatein),substring(5,2,
      sexpdatein))
   ELSE
    SET reply->expiration_ind = 0
    CALL echo("bsc_extract_med_identifiers - GS1 Invalid Expiration Date Format")
   ENDIF
 END ;Subroutine
 SUBROUTINE (validateexpirationdate(syear=vc,smonth=vc,sday=vc) =null)
   CALL echo("bsc_extract_med_identifiers - ****** Entering ValidateExpirationDate Subroutine ******"
    )
   DECLARE nunknown = i2 WITH protect, constant(0)
   DECLARE nexpired_date = i2 WITH protect, constant(1)
   DECLARE ninvalid_date = i2 WITH protect, constant(2)
   DECLARE nvalid_date = i2 WITH protect, constant(3)
   DECLARE ldatelength = i4 WITH protect, noconstant(0)
   DECLARE lmonth = i4 WITH protect, noconstant(0)
   DECLARE lday = i4 WITH protect, noconstant(0)
   DECLARE ldaysinmonth = i4 WITH protect, noconstant(0)
   DECLARE lyear = i4 WITH protect, noconstant(0)
   DECLARE sfailed = i2 WITH protect, noconstant(0)
   DECLARE qcurdate = dq8 WITH protect, noconstant(0)
   DECLARE idate = i4 WITH protect, noconstant(0)
   DECLARE sexpdate = vc WITH protect, noconstant("")
   DECLARE qcuryear = i4 WITH protect, noconstant(0)
   IF (isnumeric(syear)=1
    AND isnumeric(sday)=1
    AND isnumeric(smonth)=1)
    IF (textlen(trim(syear))=2)
     SET lyear = cnvtint(syear)
     SET qcuryear = cnvtint(substring(7,2,format(cnvtdatetimeutc(cnvtdatetime(curdate,0),2),";;D")))
     IF (((lyear - qcuryear) <= 99)
      AND ((lyear - qcuryear) >= 51))
      SET lyear += 1900
     ELSEIF (((lyear - qcuryear) <= - (50))
      AND ((lyear - qcuryear) >= - (99)))
      SET lyear += 2100
     ELSE
      SET lyear += 2000
     ENDIF
    ELSEIF (textlen(trim(syear))=4)
     SET lyear = cnvtint(syear)
    ELSE
     SET sfailed = 1
    ENDIF
    IF (textlen(trim(smonth))=2)
     SET lmonth = cnvtint(smonth)
     IF (((lmonth > 12) OR (lmonth < 1)) )
      SET sfailed = 1
     ENDIF
    ENDIF
    IF (lmonth IN (1, 3, 5, 7, 8,
    10, 12))
     SET ldaysinmonth = 31
    ELSEIF (lmonth IN (4, 6, 9, 11))
     SET ldaysinmonth = 30
    ELSEIF (lmonth=2)
     SET ldaysinmonth = 28
     IF (mod(lyear,4)=0)
      SET ldaysinmonth = 29
     ENDIF
    ENDIF
    IF (textlen(trim(sday))=2)
     SET lday = cnvtint(sday)
     IF (lday=0)
      SET lday = ldaysinmonth
     ELSEIF (((lday < 1) OR (lday > ldaysinmonth)) )
      SET sfailed = 1
     ENDIF
    ELSE
     SET sfailed = 1
    ENDIF
   ELSE
    SET sfailed = 1
   ENDIF
   IF (sfailed=0)
    SET qcurdate = cnvtdatetimeutc(cnvtdatetime(curdate,0),2)
    IF (textlen(trim(syear))=2)
     IF (((trim(sday)="00") OR (trim(sday)="")) )
      SET sexpdate = build(syear,smonth,"01")
      SET idate = cnvtdate2(sexpdate,"YYMMDD")
      SET reply->exp_date = cnvtdatetimeutc(datetimefind(cnvtdatetime(idate,0),"M","E","B"),2)
      SET reply->exp_date_tz = curtimezonesys
      SET reply->expiration_ind = nvalid_date
     ELSE
      SET sexpdate = build(syear,smonth,sday)
      SET reply->exp_date = cnvtdatetimeutc(cnvtdatetime(cnvtdate2(sexpdate,"YYMMDD"),0),2)
      SET reply->exp_date_tz = curtimezonesys
      SET reply->expiration_ind = nvalid_date
     ENDIF
    ELSEIF (textlen(trim(syear))=4)
     SET sexpdate = build(syear,smonth,sday)
     SET reply->exp_date = cnvtdatetimeutc(cnvtdatetime(cnvtdate2(sexpdate,"YYYYMMDD"),0),2)
     SET reply->exp_date_tz = curtimezonesys
     SET reply->expiration_ind = nvalid_date
    ELSE
     SET sfailed = 1
    ENDIF
    IF (datetimediff(qcurdate,reply->exp_date) > 0)
     SET reply->expiration_ind = nexpired_date
    ENDIF
   ENDIF
   IF (sfailed=1)
    SET reply->expiration_ind = ninvalid_date
    CALL echo("bsc_extract_med_identifiers - Invalid Expiration Date Format")
   ENDIF
   CALL echo("bsc_extract_med_identifiers - ****** Exiting ValidateExpirationDate Subroutine ******")
 END ;Subroutine
 SUBROUTINE getpocprefs(null)
   CALL echo("bsc_extract_med_identifiers - ****** Entering GetPOCPrefs Subroutine ******")
   DECLARE hpref = i4 WITH protect, noconstant(0)
   DECLARE hgroup = i4 WITH protect, noconstant(0)
   DECLARE hsection = i4 WITH protect, noconstant(0)
   DECLARE hgroup2 = i4 WITH protect, noconstant(0)
   DECLARE idxentry = i4 WITH protect, noconstant(0)
   DECLARE status = i2 WITH protect, noconstant(0)
   DECLARE entrycount = i4 WITH protect, noconstant(0)
   DECLARE idxval = i4 WITH protect, noconstant(0)
   DECLARE hentry = i4 WITH protect, noconstant(0)
   DECLARE attrcount = i4 WITH protect, noconstant(0)
   DECLARE idxattr = i4 WITH protect, noconstant(0)
   DECLARE hattr = i4 WITH protect, noconstant(0)
   DECLARE valcount = i4 WITH protect, noconstant(0)
   DECLARE hval = i4 WITH protect, noconstant(0)
   DECLARE attrname = c100 WITH protect, noconstant("")
   DECLARE valname = c100 WITH protect, noconstant("")
   DECLARE facilitycd = c20 WITH public, noconstant("")
   SET reply->prefs.use_mltm_syn_match = 0
   SET reply->prefs.scanning_lookup_level = 0
   SET facilitycd = trim(cnvtstring(reply->facility_cd,20,2))
   EXECUTE prefrtl
   SET hpref = uar_prefcreateinstance(0)
   IF (hpref=0)
    CALL echo("bad hPref, try logging in")
   ELSE
    SET status = uar_prefaddcontext(hpref,"default","system")
    IF (status=1
     AND textlen(facilitycd) > 0)
     SET status = uar_prefaddcontext(hpref,"facility",nullterm(facilitycd))
    ENDIF
    IF (status != 1)
     CALL echo("bad context")
    ELSE
     SET status = uar_prefsetsection(hpref,"component")
     IF (status != 1)
      CALL echo("bad section")
     ELSE
      SET hgroup = uar_prefcreategroup()
      SET status = uar_prefsetgroupname(hgroup,"pocscanningpolicies")
      IF (status != 1)
       CALL echo("bad group name")
      ELSE
       SET status = uar_prefaddgroup(hpref,hgroup)
       SET status = uar_prefperform(hpref)
       SET hsection = uar_prefgetsectionbyname(hpref,"component")
       SET hgroup2 = uar_prefgetgroupbyname(hsection,"pocscanningpolicies")
       SET entrycount = 0
       SET status = uar_prefgetgroupentrycount(hgroup2,entrycount)
       IF (validate(debug_ind)
        AND debug_ind > 0)
        CALL echo(build("entry count:",entrycount))
       ENDIF
       SET idxentry = 0
       DECLARE entryname = c100
       DECLARE namelen = i4 WITH noconstant(100)
       FOR (idxentry = 0 TO (entrycount - 1))
         SET hentry = uar_prefgetgroupentry(hgroup2,idxentry)
         SET namelen = 100
         SET entryname = " "
         SET status = uar_prefgetentryname(hentry,entryname,namelen)
         IF (validate(debug_ind)
          AND debug_ind > 0)
          CALL echo(build("entry name: ",entryname))
         ENDIF
         SET attrcount = 0
         SET status = uar_prefgetentryattrcount(hentry,attrcount)
         IF (status != 1)
          CALL echo("bad entryAttrCount")
         ELSE
          IF (validate(debug_ind)
           AND debug_ind > 0)
           CALL echo(build("attrCount:",attrcount))
          ENDIF
          SET idxattr = 0
          FOR (idxattr = 0 TO (attrcount - 1))
            SET hattr = uar_prefgetentryattr(hentry,idxattr)
            IF (validate(debug_ind)
             AND debug_ind > 0)
             CALL echo(build("hAttr:",hattr))
            ENDIF
            SET namelen = 100
            SET status = uar_prefgetattrname(hattr,attrname,namelen)
            IF (validate(debug_ind)
             AND debug_ind > 0)
             CALL echo(build("   attribute name: ",attrname))
            ENDIF
            SET valcount = 0
            SET status = uar_prefgetattrvalcount(hattr,valcount)
            SET idxval = 0
            FOR (idxval = 0 TO (valcount - 1))
              SET namelen = 100
              SET hval = uar_prefgetattrval(hattr,valname,namelen,idxval)
              IF (validate(debug_ind)
               AND debug_ind > 0)
               CALL echo(build("      val:",valname))
              ENDIF
              IF (cnvtupper(trim(entryname,3))="USE_MLTM_SYN_MATCH")
               SET reply->prefs.use_mltm_syn_match = cnvtint(trim(valname,3))
              ENDIF
              IF (cnvtupper(trim(entryname,3))="SCANNING_LOOKUP_LEVEL")
               SET reply->prefs.scanning_lookup_level = cnvtint(trim(valname,3))
              ENDIF
            ENDFOR
          ENDFOR
         ENDIF
       ENDFOR
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF (debug_ind > 0)
    CALL echo(build("USE_MLTM_SYN_MATCH preference = ",reply->prefs.use_mltm_syn_match))
    CALL echo(build("SCANNING_LOOKUP_LEVEL preference = ",reply->prefs.scanning_lookup_level))
   ENDIF
   CALL echo("bsc_extract_med_identifiers - ****** Exiting GetPOCPrefs Subroutine ******")
 END ;Subroutine
 SUBROUTINE (addexecutionnote(snotein=vc) =null)
   CALL echo("bsc_extract_med_identifiers - ****** Entering AddExecutionNote Subroutine ******")
   DECLARE lnotecnt = i4 WITH protect, noconstant(0)
   SET lnotecnt = (size(reply->execution_notes,5)+ 1)
   SET dstat = alterlist(reply->execution_notes,lnotecnt)
   SET reply->execution_notes[lnotecnt].note = snotein
   IF (debug_ind > 0)
    CALL echo(build("Execution note: ",snotein))
   ENDIF
   CALL echo("bsc_extract_med_identifiers - ****** Exiting AddExecutionNote Subroutine ******")
 END ;Subroutine
 SUBROUTINE getpmipref(null)
   CALL echo("bsc_extract_med_identifiers - ****** Entering GetPMIPref Subroutine ******")
   DECLARE positioncd = c20 WITH public, noconstant("")
   DECLARE facilitycd = c20 WITH public, noconstant("")
   DECLARE system = c20 WITH public, noconstant("")
   DECLARE idxpocscanpref = i2 WITH public, noconstant(1)
   DECLARE idxndcscanpref = i2 WITH public, noconstant(2)
   DECLARE idxpreferpref = i2 WITH public, noconstant(3)
   DECLARE istat = i2 WITH protect, noconstant(0)
   SET istat = alterlist(preference_struct->prefs,3)
   SET preference_struct->prefs[idxpocscanpref].pref_name = "POC_SCANNING_RULES"
   SET preference_struct->prefs[idxpocscanpref].pref_type = itypestr
   SET preference_struct->prefs[idxndcscanpref].pref_name = "NDC_SCANNING_RULES"
   SET preference_struct->prefs[idxndcscanpref].pref_type = itypestr
   SET preference_struct->prefs[idxpreferpref].pref_name = "PREFERRED_MED_IDENTIFIERS"
   SET preference_struct->prefs[idxpreferpref].pref_type = itypedbl
   SET positioncd = trim(cnvtstring(reqinfo->position_cd,20,2))
   CALL getprefbystruct("position",positioncd)
   CALL proccessprefreturn(null)
   IF (have_preferred_ind=1
    AND have_poc_ind=1
    AND have_ndc_ind=1)
    RETURN
   ENDIF
   SET facilitycd = trim(cnvtstring(reply->facility_cd,20,2))
   CALL getprefbystruct("facility",facilitycd)
   CALL proccessprefreturn(null)
   IF (have_preferred_ind=1
    AND have_poc_ind=1
    AND have_ndc_ind=1)
    RETURN
   ENDIF
   SET system = "system"
   CALL getprefbystruct("default",system)
   CALL proccessprefreturn(null)
   IF (have_preferred_ind=1
    AND have_poc_ind=1
    AND have_ndc_ind=1)
    RETURN
   ENDIF
   CALL addexecutionnote("At least one pref not found in medication admin section")
   CALL echo("bsc_extract_med_identifiers - ****** Exiting GetPMIPref Subroutine ******")
 END ;Subroutine
 SUBROUTINE proccessprefreturn(null)
   DECLARE prefcnt = i4 WITH protect, noconstant(0)
   DECLARE idxit = i4 WITH protect, noconstant(0)
   IF ((preference_struct->prefs[idxpocscanpref].pref_stat=ipreffound)
    AND have_poc_ind != 1)
    SET have_poc_ind = 1
    SET prefcnt = size(preference_struct->prefs[idxpocscanpref].pref_val,5)
    SET dstat = alterlist(poc_parsing_rules->list,prefcnt)
    FOR (idxit = 1 TO prefcnt)
      CALL parsepreftorule(preference_struct->prefs[idxpocscanpref].pref_val[idxit].val_str,
       poc_parsing_rules,idxit)
    ENDFOR
   ENDIF
   IF ((preference_struct->prefs[idxndcscanpref].pref_stat=ipreffound)
    AND have_ndc_ind != 1)
    SET have_ndc_ind = 1
    SET prefcnt = size(preference_struct->prefs[idxndcscanpref].pref_val,5)
    SET dstat = alterlist(ndc_parsing_rules->list,prefcnt)
    FOR (idxit = 1 TO prefcnt)
      CALL parsepreftorule(preference_struct->prefs[idxndcscanpref].pref_val[idxit].val_str,
       ndc_parsing_rules,idxit)
    ENDFOR
   ENDIF
   IF ((preference_struct->prefs[idxpreferpref].pref_stat=ipreffound)
    AND have_preferred_ind != 1)
    SET have_preferred_ind = 1
    SET prefcnt = size(preference_struct->prefs[idxpreferpref].pref_val,5)
    SET dstat = alterlist(preferred_identifiers->list,prefcnt)
    FOR (idxit = 1 TO prefcnt)
      SET preferred_identifiers->list[idxit].code_value = preference_struct->prefs[idxpreferpref].
      pref_val[idxit].val_dbl
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE (parsepreftorule(sprefval=vc,sprefstruct=vc(ref),idxprefstruct=i4) =null)
   DECLARE idxparsestart = i4 WITH protect, noconstant(1)
   DECLARE idxparseend = i4 WITH protect, noconstant(1)
   SET idxparsestart = 1
   SET idxparseend = findstring(",",sprefval,idxparsestart,0)
   SET sprefstruct->list[idxprefstruct].total_length = cnvtint(trim(substring(idxparsestart,(
      idxparseend - idxparsestart),sprefval),3))
   SET idxparsestart = (idxparseend+ 1)
   SET idxparseend = findstring(",",sprefval,idxparsestart,0)
   SET sprefstruct->list[idxprefstruct].initial_skip = cnvtint(trim(substring(idxparsestart,(
      idxparseend - idxparsestart),sprefval),3))
   SET idxparsestart = (idxparseend+ 1)
   SET idxparseend = findstring(",",sprefval,idxparsestart,0)
   IF (idxparseend=0)
    SET idxparseend = size(sprefval,1)
   ENDIF
   SET sprefstruct->list[idxprefstruct].ident_length = cnvtint(trim(substring(idxparsestart,(
      idxparseend - idxparsestart),sprefval),3))
   IF (debug_ind > 0)
    CALL echo(build("total_length: ",sprefstruct->list[idxprefstruct].total_length))
    CALL echo(build("initial_skip: ",sprefstruct->list[idxprefstruct].initial_skip))
    CALL echo(build("ident_length: ",sprefstruct->list[idxprefstruct].ident_length))
   ENDIF
 END ;Subroutine
 SUBROUTINE (processrules(sbarcodein=vc) =null)
   DECLARE char_cnt = i4 WITH noconstant(0)
   DECLARE parsed_pref_barcode = c77 WITH noconstant(fillstring(77," "))
   DECLARE rule_found_ind = i2 WITH noconstant(0)
   DECLARE temp_ndc = c77 WITH noconstant(fillstring(77," "))
   DECLARE lprefixlength = i4 WITH noconstant(0)
   DECLARE parsed_identifier = c77 WITH noconstant(fillstring(77," "))
   CALL getprefix(sbarcodein,sbarcodeprefix)
   SET lprefixlength = textlen(trim(sbarcodeprefix))
   IF (lprefixlength > 0)
    SET char_cnt = (textlen(trim(sbarcodein,3)) - lprefixlength)
   ELSE
    SET char_cnt = textlen(trim(sbarcodein))
   ENDIF
   SET temp_ndc = trim(sbarcodein)
   CALL echo(
    "bsc_extract_med_identifiers - ****** Entering ProcessBarcodeWithRules Subroutine ******")
   IF (debug_ind > 0)
    CALL echo(build("size(poc_parsing_rules->list,5):",size(poc_parsing_rules->list,5)))
   ENDIF
   FOR (idx = 1 TO size(poc_parsing_rules->list,5))
     IF ((char_cnt=poc_parsing_rules->list[idx].total_length))
      SET parsed_pref_barcode = substring(((poc_parsing_rules->list[idx].initial_skip+ 1)+
       lprefixlength),poc_parsing_rules->list[idx].ident_length,temp_ndc)
      SET rule_found_ind = 1
      IF (debug_ind > 0)
       CALL echo("rule_found_ind set to 1")
      ENDIF
      SET idx = size(poc_parsing_rules->list,5)
     ENDIF
   ENDFOR
   IF (rule_found_ind=1)
    SET parsed_identifier = parsed_pref_barcode
    SET parsed_pref_barcode = concat(sbarcodeprefix,parsed_pref_barcode)
    CALL processidentifier(sbarcodeprefix,"",parsed_pref_barcode,0,pocruletype)
    CALL processidentifier(sbarcodeprefix,"",parsed_pref_barcode,1,preferredtype)
    IF (debug_ind > 0)
     CALL echo(build("parsed_pref_barcode:",parsed_pref_barcode))
    ENDIF
   ENDIF
   CALL echo("bsc_extract_med_identifiers - ****** Exiting ProcessBarcodeWithRules Subroutine ******"
    )
 END ;Subroutine
 SUBROUTINE processpreferreditems(null)
   CALL echo("bsc_extract_med_identifiers - ****** Entering ProcessPreferredItems Subroutine ******")
   CALL getprefix(sbarcode,sbarcodeprefix)
   CALL getzdata(sbarcode,sbarcodezdata)
   IF (((textlen(trim(sbarcodeprefix,3)) > 0) OR (textlen(trim(sbarcodezdata,3)) > 0)) )
    CALL processidentifier(sbarcodeprefix,sbarcodezdata,sbarcode,1,preferredtype)
   ENDIF
   CALL processidentifier("","",sbarcode,1,preferredtype)
   CALL echo("bsc_extract_med_identifiers - ****** Exiting ProcessPreferredItems Subroutine ******")
 END ;Subroutine
 SUBROUTINE (processgs1identifiers(sbarcodein=vc) =null)
   CALL echo("bsc_extract_med_identifiers - ****** Entering ProcessGS1Identifiers Subroutine ******")
   IF (debug_ind > 0)
    CALL echorecord(gs1_rules)
   ENDIF
   CALL parsegs1barcode(sbarcodein)
   CALL populategs1structure(null)
   CALL echorecord(gs1_data)
   IF ((gs1_data->ndc != ""))
    IF (debug_ind > 0)
     CALL echorecord(gs1_data)
    ENDIF
    CALL processndc(gs1_data->ndc,gs1type)
   ENDIF
   CALL echo("bsc_extract_med_identifiers - ****** Exiting ProcessGS1Identifiers Subroutine ******")
 END ;Subroutine
 SUBROUTINE (parsegs1barcode(sbarcodein=vc) =null)
   CALL echo("bsc_extract_med_identifiers - ****** Entering ParseGS1Barcode Subroutine ******")
   DECLARE barcode_size = i4 WITH protect, noconstant(0)
   DECLARE rule_size = i4 WITH protect, noconstant(0)
   DECLARE rule_cnt_idx = i4 WITH protect, noconstant(0)
   DECLARE decimal_ind = i4 WITH protect, noconstant(0)
   DECLARE ident_length = i4 WITH protect, noconstant(0)
   DECLARE rule_found_ind = i2 WITH protect, noconstant(0)
   DECLARE rule_ident = vc WITH protect, noconstant("")
   DECLARE success_ind = i2 WITH protect, noconstant(1)
   SET barcode_size = size(sbarcodein)
   SET rule_size = size(gs1_rules->rules,5)
   WHILE (gs1_cur_loc < barcode_size)
     SET rule_found_ind = 0
     SET rule_ident = ""
     FOR (rule_cnt_idx = 1 TO rule_size)
      SET ident_length = gs1_rules->rules[rule_cnt_idx].ident_length
      IF (ident_length > 0)
       SET decimal_ind = gs1_rules->rules[rule_cnt_idx].uses_decimal
       SET rule_ident = substring(gs1_cur_loc,(ident_length - decimal_ind),sbarcodein)
       IF ((rule_ident=gs1_rules->rules[rule_cnt_idx].identifier))
        SET success_ind = processgs1rule(sbarcodein,rule_cnt_idx)
        SET rule_found_ind = 1
        SET rule_cnt_idx = rule_size
       ENDIF
      ENDIF
     ENDFOR
     IF (((rule_found_ind=0) OR (success_ind=0)) )
      CALL addexecutionnote("A rule was not found or ProcessGS1Rule returned a failure.")
      SET gs1_cur_loc = barcode_size
     ENDIF
   ENDWHILE
   IF (debug_ind > 0)
    CALL echorecord(gs1_data_temp)
   ENDIF
   CALL echo("bsc_extract_med_identifiers - ****** Exiting ParseGS1Barcode Subroutine ******")
 END ;Subroutine
 SUBROUTINE (processgs1rule(sbarcodein=vc,lrulenum=i4) =i2)
   CALL echo("bsc_extract_med_identifiers - ****** Entering ProcessGS1Rule Subroutine ******")
   DECLARE end_loc = i4 WITH protect, noconstant(0)
   DECLARE ident_length = i4 WITH protect, noconstant(0)
   DECLARE extracted_string = vc WITH protect, noconstant("")
   DECLARE length_cnt_idx = i4 WITH protect, noconstant(0)
   DECLARE success_ind = i2 WITH protect, noconstant(1)
   DECLARE rec = i4 WITH protect, noconstant(0)
   DECLARE rule_length_cnt = i4 WITH protect, noconstant(0)
   DECLARE max_val = i4 WITH protect, noconstant(0)
   DECLARE left_over = i4 WITH protect, noconstant(0)
   SET gs1_cur_loc += gs1_rules->rules[lrulenum].ident_length
   SET rule_length_cnt = size(gs1_rules->rules[lrulenum].lengths,5)
   IF (debug_ind > 0)
    CALL echo(build("lRuleNum: ",lrulenum))
    CALL echo(build("variable_name: ",gs1_rules->rules[lrulenum].variable_name))
    CALL echo(build("gs1_cur_loc_before_AI: ",gs1_cur_loc))
    CALL echo(build("gs1_cur_loc_start: ",gs1_cur_loc))
    CALL echo(build("rule_length_cnt: ",rule_length_cnt))
   ENDIF
   FOR (length_cnt_idx = 1 TO rule_length_cnt)
     IF ((gs1_rules->rules[lrulenum].lengths[length_cnt_idx].variable_length=0))
      SET ident_length = gs1_rules->rules[lrulenum].lengths[length_cnt_idx].length
      SET extracted_string = concat(trim(extracted_string),substring(gs1_cur_loc,ident_length,
        sbarcodein))
      SET gs1_cur_loc += ident_length
      IF (debug_ind > 0)
       CALL echo(build("Fixed length: ",ident_length))
       CALL echo(build("gs1_cur_loc: ",gs1_cur_loc))
      ENDIF
     ELSE
      IF (findstring(cgs1_stop,sbarcodein,gs1_cur_loc,0) > 0)
       SET end_loc = findstring(cgs1_stop,sbarcodein,gs1_cur_loc,0)
       SET ident_length = (end_loc - gs1_cur_loc)
       SET extracted_string = concat(trim(extracted_string),substring(gs1_cur_loc,ident_length,
         sbarcodein))
       SET gs1_cur_loc = (end_loc+ 1)
      ELSEIF (findstring(cgs_sep,sbarcodein,gs1_cur_loc,0) > 0)
       SET end_loc = findstring(cgs_sep,sbarcodein,gs1_cur_loc,0)
       SET ident_length = (end_loc - gs1_cur_loc)
       SET extracted_string = concat(trim(extracted_string),substring(gs1_cur_loc,ident_length,
         sbarcodein))
       SET gs1_cur_loc = (end_loc+ 6)
      ELSE
       IF (debug_ind > 0)
        CALL echo(build("Stop character not found, may be the last variable length data item."))
       ENDIF
       SET max_val = gs1_rules->rules[lrulenum].lengths[length_cnt_idx].length
       SET left_over = ((size(sbarcodein)+ 1) - gs1_cur_loc)
       IF (debug_ind > 0)
        CALL echo(build("Max length when stop not found: ",max_val))
        CALL echo(build("size_barcode: ",size(sbarcodein)))
        CALL echo(build("gs1_cur_loc: ",gs1_cur_loc))
        CALL echo(build("left_over: ",left_over))
       ENDIF
       IF (max_val >= left_over)
        SET extracted_string = concat(trim(extracted_string),substring(gs1_cur_loc,left_over,
          sbarcodein))
        SET gs1_cur_loc += left_over
       ELSE
        SET success_ind = 0
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   IF (success_ind=1)
    IF (debug_ind > 0)
     CALL echo(build("extracted_string: ",extracted_string))
     CALL echo(build("variable_name: ",gs1_rules->rules[lrulenum].variable_name))
    ENDIF
    SET dstat = alterlist(gs1_data_temp->data,(size(gs1_data_temp->data,5)+ 1))
    SET gs1_data_temp->data[size(gs1_data_temp->data,5)].value = extracted_string
    SET gs1_data_temp->data[size(gs1_data_temp->data,5)].variable_name = gs1_rules->rules[lrulenum].
    variable_name
    CALL echo("bsc_extract_med_identifiers - ****** Exiting ProcessGS1Rule Subroutine ******")
    RETURN(1)
   ELSE
    CALL addexecutionnote("A GS1 rule was not found so the GS1 logic was exited.")
    CALL echo("bsc_extract_med_identifiers - ****** Exiting ProcessGS1Rule Subroutine ******")
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE populategs1structure(null)
   CALL echo("bsc_extract_med_identifiers - ****** Entering PopulateGS1Structure Subroutine ******")
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE lcnt = i4 WITH protect, noconstant(0)
   IF (locateval(lcnt,1,size(gs1_data_temp->data,5),"gtin",gs1_data_temp->data[lcnt].variable_name)
    > 0)
    FOR (cnt = 1 TO size(gs1_data_temp->data,5))
      IF ((gs1_data_temp->data[cnt].variable_name="gtin"))
       SET gs1_data->ndc = substring(4,10,gs1_data_temp->data[cnt].value)
      ELSEIF ((gs1_data_temp->data[cnt].variable_name="lotnum"))
       SET reply->lot_number = gs1_data_temp->data[cnt].value
      ELSEIF ((gs1_data_temp->data[cnt].variable_name="exp_date"))
       CALL validategs1expirationdate(gs1_data_temp->data[cnt].value)
      ENDIF
    ENDFOR
    CALL fillrecauditinfo(cgs1)
   ELSE
    IF (debug_ind > 0)
     CALL echo("Gtin identifier was not found - ignoring any partial GS1 data")
    ENDIF
   ENDIF
   CALL echo("bsc_extract_med_identifiers - ****** Exiting PopulateGS1Structure Subroutine ******")
 END ;Subroutine
 SUBROUTINE (fillrecauditinfo(deventtype=f8) =null)
   CALL echo("bsc_extract_med_identifiers - ****** Entering FillRecAuditInfo Subroutine ******")
   DECLARE llistcnt = i4 WITH protect, noconstant(size(rec_request->audit_events,5))
   SET llistcnt += 1
   SET stat = alterlist(rec_request->audit_events,llistcnt)
   SET rec_request->audit_events[llistcnt].audit_solution_cd = request->audit_solution_cd
   SET rec_request->audit_events[llistcnt].audit_event_cd = deventtype
   SET rec_request->audit_events[llistcnt].audit_event_dt_tm = cnvtdatetime(sysdate)
   SET rec_request->audit_events[llistcnt].audit_facility_cd = reply->facility_cd
   CALL echo("bsc_extract_med_identifiers - ****** Exiting FillRecAuditInfo Subroutine ******")
 END ;Subroutine
 SUBROUTINE recordauditinfo(null)
   CALL echo("bsc_extract_med_identifiers - ****** Entering RecordAuditInfo Subroutine ******")
   SET rec_request->debug_ind = debug_ind
   IF (debug_ind > 0)
    CALL echorecord(rec_request)
   ENDIF
   IF (size(rec_request->audit_events,5) > 0)
    SET modify = nopredeclare
    EXECUTE bsc_rec_audit_info  WITH replace("REQUEST",rec_request), replace("REPLY",rec_reply)
    SET modify = predeclare
    IF ((rec_reply->status_data.status="F"))
     CALL addexecutionnote(rec_reply->status_data.subeventstatus.targetobjectvalue)
    ENDIF
   ENDIF
   CALL echo("bsc_extract_med_identifiers - ****** Exiting RecordAuditInfo Subroutine ******")
 END ;Subroutine
 SET last_mod = "010"
 SET mod_date = "04/04/2022"
 SET modify = nopredeclare
END GO
