CREATE PROGRAM bbt_tag_pilot_lbl:dba
 RECORD antibody(
   1 antibodylist[10]
     2 antibody_cd = f8
     2 antibody_disp = c15
     2 trans_req_ind = i2
 )
 RECORD antigen(
   1 antigenlist[10]
     2 antigen_cd = f8
     2 antigen_disp = c15
 )
 RECORD component(
   1 cmpntlist[10]
     2 product_id = f8
     2 product_cd = f8
     2 product_disp = c40
     2 product_nbr = c20
     2 serial_nbr = c22
     2 product_sub_nbr = c5
     2 alternate_nbr = c20
     2 cur_abo_cd = f8
     2 cur_abo_disp = c20
     2 cur_rh_cd = f8
     2 cur_rh_disp = c20
     2 supplier_prefix = c5
 )
 SET antbdy = 0
 SET antibody_cnt = 0
 SET addtnl_antibody_ind = 0
 DECLARE antibody_disp = c109
 SET antibody_disp = ""
 SET antgen = 0
 SET antigen_cnt = 0
 SET addtnl_antigen_ind = 0
 DECLARE antigen_disp = c109
 SET antigen_disp = ""
 SET cmpnt = 0
 SET cmpnt_cnt = 0
 SET addtnl_cmpnt_ind = 0
 DECLARE cmpnt_disp_row = c109
 SET cmpnt_disp_row = ""
 DECLARE cmpnt_disp = c34
 SET cmpnt_col = 0
 SET rpt_row = 0
 DECLARE tech_name = c15
 DECLARE product_disp = c40
 DECLARE product_desc = c60
 DECLARE product_nbr = c20
 DECLARE serial_nbr = c22
 DECLARE product_sub_nbr = c5
 DECLARE product_flag_chars = c2 WITH public, noconstant("  ")
 DECLARE product_nbr_full = c30
 DECLARE alternate_nbr = c20
 DECLARE segment_nbr = c20
 DECLARE cur_unit_meas_disp = c15
 DECLARE bb_id_nbr = c20
 DECLARE cur_abo_disp = c20
 DECLARE cur_rh_disp = c20
 DECLARE supplier_prefix = c5
 DECLARE accession = c20
 DECLARE xm_result_value_alpha = c15
 DECLARE xm_result_event_prsnl_username = c15
 DECLARE reason_disp = c15
 DECLARE name_full_formatted = c50
 DECLARE alias_mrn = c25
 DECLARE alias_fin = c25
 DECLARE alias_ssn = c25
 DECLARE alias_mrn_formatted = c25
 DECLARE alias_fin_formatted = c25
 DECLARE alias_ssn_formatted = c25
 DECLARE age = c12
 DECLARE sex_disp = c6
 DECLARE patient_location = c30
 DECLARE prvdr_name_full_formatted = c50
 DECLARE person_abo_disp = c20
 DECLARE person_rh_disp = c20
 DECLARE dispense_tech_username = c15
 DECLARE dispense_courier = c50
 DECLARE dispense_prvdr_name = c50
 DECLARE admit_prvdr_name = c50
 DECLARE qty_vol_disp = c36
 DECLARE qty_vol_disp_1 = c36 WITH public, noconstant(" ")
 DECLARE derivative_ind = i2 WITH public, noconstant(0)
 DECLARE patient_name_barcode = vc WITH public, noconstant(" ")
 DECLARE mrn_barcode = vc WITH public, noconstant(" ")
 DECLARE fin_barcode = vc WITH public, noconstant(" ")
 DECLARE dob_barcode = vc WITH public, noconstant(" ")
 DECLARE bbid_barcode = vc WITH public, noconstant(" ")
 DECLARE person_aborh_barcode = vc WITH public, noconstant(" ")
 DECLARE product_barcode_nbr = c20 WITH public, noconstant(" ")
 DECLARE product_num_barcode = vc WITH public, noconstant(" ")
 DECLARE product_type_barcode_nbr = vc WITH public, noconstant(" ")
 DECLARE product_type_barcode = vc WITH public, noconstant(" ")
 SUBROUTINE (getreportfilename(sfilename=vc) =vc)
   DECLARE nfileexists = i2 WITH noconstant(0)
   DECLARE nnextseq = i2 WITH noconstant(0)
   DECLARE snewfilename = vc WITH noconstant("")
   DECLARE sfileextension = c4 WITH noconstant("")
   DECLARE sfilenamenoextension = vc WITH noconstant("")
   SET nfileexists = findfile(sfilename)
   IF (nfileexists=1)
    WHILE (nfileexists=1)
      SET sfileextension = substring((textlen(sfilename) - 3),4,sfilename)
      SET sfilenamenoextension = substring(1,(textlen(sfilename) - 4),sfilename)
      SET nnextseq += 1
      SET snewfilename = build(sfilenamenoextension,"_",cnvtstring(nnextseq),sfileextension)
      SET nfileexists = findfile(snewfilename)
    ENDWHILE
   ELSE
    SET snewfilename = sfilename
   ENDIF
   RETURN(snewfilename)
 END ;Subroutine
 SET tot_tag_cnt = size(request->taglist,5)
 SET rpt_date = 0
 EXECUTE cpm_create_file_name_logical "bbt_tag_pilot", "txt", "x"
 SET rpt_filename = cpm_cfn_info->file_name
 SELECT INTO cpm_cfn_info->file_name_logical
  d.seq
  FROM (dummyt d  WITH seq = value(tot_tag_cnt))
  HEAD REPORT
   signature12 = fillstring(12,"_"), signature14 = fillstring(14,"_"), signature27 = fillstring(27,
    "_")
  HEAD PAGE
   rpt_row = 0
  DETAIL
   patient_name_barcode = " ", mrn_barcode = " ", fin_barcode = " ",
   dob_barcode = " ", bbid_barcode = " ", person_aborh_barcode = " ",
   product_num_barcode = " ", pe_event_dt_tm = cnvtdatetime(tag_request->taglist[d.seq].
    pe_event_dt_tm), tech_name = trim(tag_request->taglist[d.seq].tech_name),
   product_disp = trim(tag_request->taglist[d.seq].product_disp), product_desc = trim(tag_request->
    taglist[d.seq].product_desc), product_nbr = trim(tag_request->taglist[d.seq].product_nbr),
   serial_nbr = trim(tag_request->taglist[d.seq].serial_nbr), product_sub_nbr = trim(tag_request->
    taglist[d.seq].product_sub_nbr), product_flag_chars = trim(tag_request->taglist[d.seq].flag_chars
    ),
   product_nbr_full = concat(trim(tag_request->taglist[d.seq].supplier_prefix),trim(tag_request->
     taglist[d.seq].product_nbr)," ",trim(tag_request->taglist[d.seq].product_sub_nbr))
   IF (textlen(trim(product_nbr))=13)
    product_barcode_nbr = concat(trim(tag_request->taglist[d.seq].product_nbr),trim(tag_request->
      taglist[d.seq].flag_chars))
   ELSE
    product_barcode_nbr = trim(tag_request->taglist[d.seq].product_barcode_nbr)
   ENDIF
   IF (textlen(trim(product_barcode_nbr)) > 0)
    IF (findstring("!",trim(product_barcode_nbr),1,0)=1
     AND textlen(trim(product_barcode_nbr)) >= 13
     AND textlen(trim(product_barcode_nbr)) <= 19)
     product_num_barcode = concat("e",trim(product_barcode_nbr),"u")
    ELSEIF (textlen(trim(product_barcode_nbr))=15)
     product_num_barcode = concat("=",trim(product_barcode_nbr),"u")
    ELSE
     product_num_barcode = concat("r",trim(product_barcode_nbr),"u")
    ENDIF
   ENDIF
   alternate_nbr = trim(tag_request->taglist[d.seq].alternate_nbr), segment_nbr = trim(tag_request->
    taglist[d.seq].segment_nbr), product_type_barcode_nbr = tag_request->taglist[d.seq].
   product_type_barcode
   IF (textlen(trim(product_type_barcode_nbr)) > 0)
    product_type_barcode = concat("<",trim(product_type_barcode_nbr),"v")
   ENDIF
   IF ((tag_request->taglist[d.seq].cur_volume > 0))
    cur_volume = trim(cnvtstring(tag_request->taglist[d.seq].cur_volume))
   ELSE
    cur_volume = " "
   ENDIF
   cur_unit_meas_disp = trim(tag_request->taglist[d.seq].cur_unit_meas_disp), bb_id_nbr = trim(
    tag_request->taglist[d.seq].bb_id_nbr)
   IF (textlen(trim(bb_id_nbr)) > 0)
    bbid_barcode = concat("r",trim(bb_id_nbr),"s")
   ENDIF
   product_expire_dt_tm = cnvtdatetime(tag_request->taglist[d.seq].product_expire_dt_tm),
   derivative_ind = tag_request->taglist[d.seq].derivative_ind
   IF ((tag_request->taglist[d.seq].derivative_ind != 1))
    cur_abo_disp = trim(tag_request->taglist[d.seq].cur_abo_disp), cur_rh_disp = trim(tag_request->
     taglist[d.seq].cur_rh_disp), supplier_prefix = trim(tag_request->taglist[d.seq].supplier_prefix),
    qty_vol_disp = concat("VOL: ",trim(cnvtstring(tag_request->taglist[d.seq].cur_volume))," ",trim(
      tag_request->taglist[d.seq].cur_unit_meas_disp)), qty_vol_disp_1 = concat(trim(cnvtstring(
       tag_request->taglist[d.seq].cur_volume))," ",trim(tag_request->taglist[d.seq].
      cur_unit_meas_disp))
   ELSE
    cur_abo_disp = " ", cur_rh_disp = " ", supplier_prefix = " "
    IF ((tag_request->taglist[d.seq].item_unit_per_vial=0))
     qty_vol_disp = concat("QTY: ",trim(cnvtstring(tag_request->taglist[d.seq].quantity)),"  VOL: ",
      trim(cnvtstring(tag_request->taglist[d.seq].item_volume))," ",
      trim(tag_request->taglist[d.seq].item_unit_meas_disp)), qty_vol_disp_1 = concat(trim(cnvtstring
       (tag_request->taglist[d.seq].quantity)),"  VOL: ",trim(cnvtstring(tag_request->taglist[d.seq].
        item_volume))," ",trim(tag_request->taglist[d.seq].item_unit_meas_disp))
    ELSE
     qty_vol_disp = concat("QTY: ",trim(cnvtstring(tag_request->taglist[d.seq].quantity)),
      "  IU PER: ",trim(cnvtstring(tag_request->taglist[d.seq].item_unit_per_vial)),"  TOT IU: ",
      trim(cnvtstring(tag_request->taglist[d.seq].item_volume))), qty_vol_disp_1 = concat(trim(
       cnvtstring(tag_request->taglist[d.seq].quantity)),"  IU PER: ",trim(cnvtstring(tag_request->
        taglist[d.seq].item_unit_per_vial)),"  TOT IU: ",trim(cnvtstring(tag_request->taglist[d.seq].
        item_volume)))
    ENDIF
   ENDIF
   accession = trim(tag_request->taglist[d.seq].accession), xm_result_value_alpha = trim(tag_request
    ->taglist[d.seq].xm_result_value_alpha), xm_result_event_prsnl_username = trim(tag_request->
    taglist[d.seq].xm_result_event_prsnl_username),
   xm_result_event_dt_tm = cnvtdatetime(tag_request->taglist[d.seq].xm_result_event_dt_tm),
   xm_expire_dt_tm = cnvtdatetime(tag_request->taglist[d.seq].xm_expire_dt_tm), reason_disp = trim(
    tag_request->taglist[d.seq].reason_disp)
   IF (((tag_type != emergency_tag) OR ((tag_request->taglist[d.seq].unknown_patient_ind != 1))) )
    name_full_formatted = trim(tag_request->taglist[d.seq].name_full_formatted)
    IF (textlen(trim(name_full_formatted)) > 0)
     patient_name_barcode = concat("r",trim(name_full_formatted),"n")
    ENDIF
    alias_mrn = trim(tag_request->taglist[d.seq].alias_mrn), alias_mrn_formatted = trim(tag_request->
     taglist[d.seq].alias_mrn_formatted)
    IF (textlen(trim(alias_mrn)) > 0)
     mrn_barcode = concat("r",trim(alias_mrn),"i")
    ENDIF
    alias_fin = trim(tag_request->taglist[d.seq].alias_fin), alias_fin_formatted = trim(tag_request->
     taglist[d.seq].alias_fin_formatted)
    IF (textlen(trim(alias_fin)) > 0)
     fin_barcode = concat("r",trim(alias_fin),"f")
    ENDIF
    alias_ssn = trim(tag_request->taglist[d.seq].alias_ssn), alias_ssn_formatted = trim(tag_request->
     taglist[d.seq].alias_ssn_formatted), age = trim(tag_request->taglist[d.seq].age),
    sex_disp = trim(tag_request->taglist[d.seq].sex_disp), patient_location = trim(tag_request->
     taglist[d.seq].patient_location), prvdr_name_full_formatted = trim(tag_request->taglist[d.seq].
     prvdr_name_full_formatted),
    person_abo_disp = trim(tag_request->taglist[d.seq].person_abo_disp), person_rh_disp = trim(
     tag_request->taglist[d.seq].person_rh_disp)
    IF (textlen(trim(tag_request->taglist[d.seq].person_aborh_barcode)) > 0)
     person_aborh_barcode = concat("r",trim(tag_request->taglist[d.seq].person_aborh_barcode),"b")
    ENDIF
    birth_dt_tm = cnvtdatetime(tag_request->taglist[d.seq].birth_dt_tm)
    IF (birth_dt_tm > 0)
     dob_barcode = build("r",cnvtstring(year(birth_dt_tm)),format(cnvtstring(julian(birth_dt_tm)),
       "###;P0;"),format(cnvtstring(hour(birth_dt_tm)),"##;P0;"),format(cnvtstring(minute(birth_dt_tm
         )),"##;P0;"),
      "s")
    ENDIF
   ELSE
    name_full_formatted = tag_request->taglist[d.seq].unknown_patient_text
    IF (textlen(trim(name_full_formatted)) > 0)
     patient_name_barcode = concat("r",trim(name_full_formatted),"n")
    ENDIF
    alias_mrn = " ", mrn_barcode = " ", alias_fin = " ",
    fin_barcode = " ", age = " ", sex_disp = " ",
    patient_location = " ", prvdr_name_full_formatted = " ", person_abo_disp = " ",
    person_rh_disp = " ", person_aborh_barcode = " ", birth_dt_tm = cnvtdatetime(""),
    dob_barcode = " "
   ENDIF
   antibody_cnt = cnvtint(tag_request->taglist[d.seq].antibody_cnt), stat = alter(antibody->
    antibodylist,tag_request->taglist[d.seq].antibody_cnt)
   FOR (antbdy = 1 TO antibody_cnt)
     antibody->antibodylist[antbdy].antibody_cd = tag_request->taglist[d.seq].antibodylist[antbdy].
     antibody_cd, antibody->antibodylist[antbdy].antibody_disp = trim(tag_request->taglist[d.seq].
      antibodylist[antbdy].antibody_disp), antibody->antibodylist[antbdy].trans_req_ind = tag_request
     ->taglist[d.seq].antibodylist[antbdy].trans_req_ind
   ENDFOR
   antigen_cnt = cnvtint(tag_request->taglist[d.seq].antigen_cnt), stat = alter(antigen->antigenlist,
    tag_request->taglist[d.seq].antigen_cnt)
   FOR (antgen = 1 TO antigen_cnt)
    antigen->antigenlist[antgen].antigen_cd = tag_request->taglist[d.seq].antigenlist[antgen].
    antigen_cd,antigen->antigenlist[antgen].antigen_disp = trim(tag_request->taglist[d.seq].
     antigenlist[antgen].antigen_disp)
   ENDFOR
   cmpnt_cnt = tag_request->taglist[d.seq].cmpnt_cnt, stat = alter(component->cmpntlist,tag_request->
    taglist[d.seq].cmpnt_cnt)
   FOR (cmpnt = 1 TO cmpnt_cnt)
     component->cmpntlist[cmpnt].product_id = tag_request->taglist[d.seq].cmpntlist[cmpnt].product_id,
     component->cmpntlist[cmpnt].product_cd = tag_request->taglist[d.seq].cmpntlist[cmpnt].product_cd,
     component->cmpntlist[cmpnt].product_disp = trim(tag_request->taglist[d.seq].cmpntlist[cmpnt].
      product_disp),
     component->cmpntlist[cmpnt].product_nbr = trim(tag_request->taglist[d.seq].cmpntlist[cmpnt].
      product_nbr), component->cmpntlist[cmpnt].serial_nbr = trim(tag_request->taglist[d.seq].
      cmpntlist[cmpnt].serial_nbr), component->cmpntlist[cmpnt].product_sub_nbr = trim(tag_request->
      taglist[d.seq].cmpntlist[cmpnt].product_sub_nbr),
     component->cmpntlist[cmpnt].cur_abo_cd = tag_request->taglist[d.seq].cmpntlist[cmpnt].cur_abo_cd,
     component->cmpntlist[cmpnt].cur_abo_disp = trim(tag_request->taglist[d.seq].cmpntlist[cmpnt].
      cur_abo_disp), component->cmpntlist[cmpnt].supplier_prefix = trim(tag_request->taglist[d.seq].
      cmpntlist[cmpnt].supplier_prefix),
     component->cmpntlist[cmpnt].cur_rh_cd = tag_request->taglist[d.seq].cmpntlist[cmpnt].cur_rh_cd,
     component->cmpntlist[cmpnt].cur_rh_disp = trim(tag_request->taglist[d.seq].cmpntlist[cmpnt].
      cur_rh_disp)
   ENDFOR
   dispense_tech_username = trim(tag_request->taglist[d.seq].dispense_tech_username), dispense_dt_tm
    = cnvtdatetime(tag_request->taglist[d.seq].dispense_dt_tm), dispense_courier = trim(tag_request->
    taglist[d.seq].dispense_courier),
   dispense_prvdr_name = trim(tag_request->taglist[d.seq].dispense_prvdr_name), row + 1,
   product_nbr_print = trim(concat(trim(supplier_prefix),trim(product_nbr)," ",trim(product_sub_nbr))
    ),
   col 001, product_nbr_print, row + 1,
   col 001, alternate_nbr, row + 1,
   col 001, segment_nbr, row + 1,
   col 001, supplier_prefix, row + 1
   IF (product_expire_dt_tm > 0)
    col 001, product_expire_dt_tm"@SHORTDATE", col 010,
    product_expire_dt_tm"@TIMENOSECONDS"
   ENDIF
   row + 1, product_aborh_disp = concat(trim(cur_abo_disp)," ",trim(cur_rh_disp)), col 001,
   product_aborh_disp
  FOOT  d.seq
   IF (d.seq > 0
    AND d.seq != tot_tag_cnt)
    BREAK
   ENDIF
  WITH maxcol = 132, maxrow = 07, compress,
   nolandscape, nullreport
 ;end select
END GO
