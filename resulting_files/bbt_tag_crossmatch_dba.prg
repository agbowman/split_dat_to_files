CREATE PROGRAM bbt_tag_crossmatch:dba
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
 IF (validate(i18nuar_def,999)=999)
  CALL echo("Declaring i18nuar_def")
  DECLARE i18nuar_def = i2 WITH persist
  SET i18nuar_def = 1
  DECLARE uar_i18nlocalizationinit(p1=i4,p2=vc,p3=vc,p4=f8) = i4 WITH persist
  DECLARE uar_i18ngetmessage(p1=i4,p2=vc,p3=vc) = vc WITH persist
  DECLARE uar_i18nbuildmessage() = vc WITH persist
  DECLARE uar_i18ngethijridate(imonth=i2(val),iday=i2(val),iyear=i2(val),sdateformattype=vc(ref)) =
  c50 WITH image_axp = "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar =
  "uar_i18nGetHijriDate",
  persist
  DECLARE uar_i18nbuildfullformatname(sfirst=vc(ref),slast=vc(ref),smiddle=vc(ref),sdegree=vc(ref),
   stitle=vc(ref),
   sprefix=vc(ref),ssuffix=vc(ref),sinitials=vc(ref),soriginal=vc(ref)) = c250 WITH image_axp =
  "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar = "i18nBuildFullFormatName",
  persist
  DECLARE uar_i18ngetarabictime(ctime=vc(ref)) = c20 WITH image_axp = "shri18nuar", image_aix =
  "libi18n_locale.a(libi18n_locale.o)", uar = "i18n_GetArabicTime",
  persist
 ENDIF
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 RECORD captions(
   1 crossmatch_transfusion = vc
   1 patient = vc
   1 acc_num = vc
   1 unit_num = vc
   1 med_rec = vc
   1 age = vc
   1 sex = vc
   1 product = vc
   1 desc = vc
   1 financial_num = vc
   1 location = vc
   1 donor_type = vc
   1 patient_type = vc
   1 blood_bank_id = vc
   1 unit_exp = vc
   1 doctor = vc
   1 crossmatch_interp = vc
   1 crossmatch_expiration = vc
   1 before_transfusion = vc
   1 identified_recipient = vc
   1 clerical_check = vc
   1 of_the_wristband = vc
   1 number_on_form = vc
   1 released_date = vc
   1 further_certify = vc
   1 unit_number = vc
   1 stated_on_form = vc
   1 transported_by = vc
   1 time_started = vc
   1 received_date = vc
   1 by_time = vc
   1 time_ended = vc
   1 transfusionist = vc
   1 leukofiltered = vc
   1 irradiated = vc
   1 cmv_neg = vc
   1 vol_reduced = vc
   1 autologous = vc
   1 directed = vc
   1 hla_typed = vc
   1 hgb_s_neg = vc
   1 iga_deficient = vc
   1 other = vc
   1 absc = vc
   1 return_to_bb = vc
   1 in_30_min = vc
   1 refrigerator = vc
   1 hospital_name = vc
   1 hospital_address = vc
   1 clia_num = vc
   1 original_to_chart = vc
   1 copy_to_lab = vc
 )
 SET captions->crossmatch_transfusion = uar_i18ngetmessage(i18nhandle,"crossmatch_transfusion",
  "CROSSMATCH TRANSFUSION TAG")
 SET captions->patient = uar_i18ngetmessage(i18nhandle,"patient","PATIENT:")
 SET captions->acc_num = uar_i18ngetmessage(i18nhandle,"acc_num","ACC:")
 SET captions->unit_num = uar_i18ngetmessage(i18nhandle,"unit_num","UNIT NO:")
 SET captions->med_rec = uar_i18ngetmessage(i18nhandle,"med_rec","MED REC:")
 SET captions->age = uar_i18ngetmessage(i18nhandle,"age","AGE:")
 SET captions->sex = uar_i18ngetmessage(i18nhandle,"sex","SEX:")
 SET captions->product = uar_i18ngetmessage(i18nhandle,"product","PRODUCT:")
 SET captions->desc = uar_i18ngetmessage(i18nhandle,"desc","DESC:")
 SET captions->financial_num = uar_i18ngetmessage(i18nhandle,"financial_num","FINANCIAL #:")
 SET captions->location = uar_i18ngetmessage(i18nhandle,"location","LOC:")
 SET captions->donor_type = uar_i18ngetmessage(i18nhandle,"donor_type","DONOR TYPE:")
 SET captions->patient_type = uar_i18ngetmessage(i18nhandle,"patient_type","PATIENT TYPE:")
 SET captions->blood_bank_id = uar_i18ngetmessage(i18nhandle,"blood_bank_id","BLOOD BANK ID:")
 SET captions->unit_exp = uar_i18ngetmessage(i18nhandle,"unit_exp","UNIT EXP:")
 SET captions->doctor = uar_i18ngetmessage(i18nhandle,"doctor","DOCTOR:")
 SET captions->crossmatch_interp = uar_i18ngetmessage(i18nhandle,"crossmatch_interp",
  "CROSSMATCH INTERP         TECH             DATE      TIME")
 SET captions->crossmatch_expiration = uar_i18ngetmessage(i18nhandle,"crossmatch_expiration",
  "CROSSMATCH EXPIRATION:")
 SET captions->before_transfusion = uar_i18ngetmessage(i18nhandle,"before_transfusion",
  "BEFORE STARTING TRANSFUSION, I CERTIFY THAT I HAVE")
 SET captions->identified_recipient = uar_i18ngetmessage(i18nhandle,"identified_recipient",
  "IDENTIFIED THE RECIPIENT BY INSPECTION")
 SET captions->clerical_check = uar_i18ngetmessage(i18nhandle,"clerical_check",
  "CLERICAL CHECK BY:______________")
 SET captions->of_the_wristband = uar_i18ngetmessage(i18nhandle,"of_the_wristband",
  "OF THE WRISTBAND AND THAT THE NAME AND MED RECORD")
 SET captions->number_on_form = uar_i18ngetmessage(i18nhandle,"number_on_form",
  "NUMBER ARE THE SAME AS ON THIS FORM.  I")
 SET captions->released_date = uar_i18ngetmessage(i18nhandle,"released_date",
  "RELEASED DATE:_________")
 SET captions->further_certify = uar_i18ngetmessage(i18nhandle,"further_certify",
  "FURTHER CERTIFY THAT THE DONOR UNIT LABEL HAS THE SAME")
 SET captions->unit_number = uar_i18ngetmessage(i18nhandle,"unit_number",
  "UNIT NUMBER, ABO GROUP, AND RH AS")
 SET captions->stated_on_form = uar_i18ngetmessage(i18nhandle,"stated_on_form","STATED ON THIS FORM")
 SET captions->transported_by = uar_i18ngetmessage(i18nhandle,"transported_by","TRANSPORTED BY:")
 SET captions->time_started = uar_i18ngetmessage(i18nhandle,"time_started","TIME STARTED")
 SET captions->received_date = uar_i18ngetmessage(i18nhandle,"received_date",
  "RECEIVED          DATE:_________")
 SET captions->by_time = uar_i18ngetmessage(i18nhandle,"by_time","BY:___________   &TIME:_________")
 SET captions->time_ended = uar_i18ngetmessage(i18nhandle,"time_ended","TIME ENDED")
 SET captions->transfusionist = uar_i18ngetmessage(i18nhandle,"transfusionist","TRANSFUSIONIST")
 SET captions->leukofiltered = uar_i18ngetmessage(i18nhandle,"leukofiltered","LEUKOFILTERED:  _____")
 SET captions->irradiated = uar_i18ngetmessage(i18nhandle,"irradiated","IRRADIATED:     _____")
 SET captions->cmv_neg = uar_i18ngetmessage(i18nhandle,"cmv_neg","CMV NEG:        _____")
 SET captions->vol_reduced = uar_i18ngetmessage(i18nhandle,"vol_reduced","VOLUME REDUCED: _____")
 SET captions->autologous = uar_i18ngetmessage(i18nhandle,"autologous","AUTOLOGOUS:     _____")
 SET captions->directed = uar_i18ngetmessage(i18nhandle,"directed","DIRECTED:       _____")
 SET captions->hla_typed = uar_i18ngetmessage(i18nhandle,"hla_typed","HLA TYPED:      _____")
 SET captions->hgb_s_neg = uar_i18ngetmessage(i18nhandle,"hgb_s_neg","HGB S NEG:      _____")
 SET captions->iga_deficient = uar_i18ngetmessage(i18nhandle,"iga_deficient","IGA DEFICIENT:  _____")
 SET captions->other = uar_i18ngetmessage(i18nhandle,"other","OTHER: ______________")
 SET captions->absc = uar_i18ngetmessage(i18nhandle,"absc","ABSC:           _____")
 SET captions->return_to_bb = uar_i18ngetmessage(i18nhandle,"return_to_bb",
  "RETURN TO BLOOD BANK IF TRANSFUSION NOT STARTED")
 SET captions->in_30_min = uar_i18ngetmessage(i18nhandle,"in_30_min",
  "IN 30 MIN.  DO NOT PLACE THIS UNIT IN AN UNMONITORED")
 SET captions->refrigerator = uar_i18ngetmessage(i18nhandle,"refrigerator",
  "REFRIGERATOR, MICROWAVE OR NEAR A HEATING VENT.")
 SET captions->hospital_name = uar_i18ngetmessage(i18nhandle,"hospital_name","HOSPITAL NAME")
 SET captions->hospital_address = uar_i18ngetmessage(i18nhandle,"hospital_address","HOSPITAL ADDRESS"
  )
 SET captions->clia_num = uar_i18ngetmessage(i18nhandle,"clia_num","CLIA # ")
 SET captions->original_to_chart = uar_i18ngetmessage(i18nhandle,"original_to_chart",
  "ORIGINAL TO CHART")
 SET captions->copy_to_lab = uar_i18ngetmessage(i18nhandle,"copy_to_lab","COPY TO LAB")
 SET rpt_date = 0
 EXECUTE cpm_create_file_name_logical "bbt_tag_xm", "txt", "x"
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
   dispense_prvdr_name = trim(tag_request->taglist[d.seq].dispense_prvdr_name), rpt_row = 4, rpt_row
    += 2
   IF (curpage > 1)
    rpt_row -= 1
   ENDIF
   row rpt_row, col 049, captions->crossmatch_transfusion,
   rpt_row += 2, row rpt_row, col 006,
   captions->patient, col 020, name_full_formatted,
   col 055, captions->acc_num, col 060,
   accession, col 092, captions->unit_num,
   col 101, product_nbr_full, rpt_row += 1,
   row rpt_row, col 006, captions->med_rec,
   col 020, alias_mrn_formatted, col 055,
   captions->age, col 060, age,
   col 074, captions->sex, col 079,
   sex_disp, rpt_row += 1, product_disp_35 = substring(1,35,product_disp),
   row rpt_row, col 006, captions->product,
   col 020, product_disp_35, col 055,
   captions->desc, col 061, product_desc,
   rpt_row += 1, person_aborh_disp = concat(trim(person_abo_disp)," ",trim(person_rh_disp)),
   person_aborh_disp_23 = substring(1,23,person_aborh_disp),
   product_aborh_disp = concat(trim(cur_abo_disp)," ",trim(cur_rh_disp)), product_aborh_disp_23 =
   substring(1,23,product_aborh_disp), row rpt_row,
   col 006, captions->financial_num, col 020,
   alias_fin_formatted, col 055, captions->location,
   col 060, patient_location, col 092,
   captions->donor_type, col 105, product_aborh_disp_23,
   rpt_row += 1, row rpt_row, col 006,
   captions->patient_type, col 020, person_aborh_disp_23,
   col 055, captions->blood_bank_id, col 070,
   bb_id_nbr, col 092, captions->unit_exp
   IF (product_expire_dt_tm > 0)
    col 105, product_expire_dt_tm"@SHORTDATE4YR", col 119,
    product_expire_dt_tm"@TIMENOSECONDS"
   ENDIF
   rpt_row += 1, row rpt_row, col 006,
   captions->doctor, col 020, prvdr_name_full_formatted,
   col 092, qty_vol_disp, rpt_row = 26
   IF (curpage > 1)
    rpt_row -= 1
   ENDIF
   row rpt_row, col 006, captions->crossmatch_interp,
   rpt_row += 1, row rpt_row, col 007,
   xm_result_value_alpha, col 027, xm_result_event_prsnl_username
   IF (xm_result_event_dt_tm > 0)
    col 046, xm_result_event_dt_tm"@SHORTDATE4YR", col 59,
    xm_result_event_dt_tm"@TIMENOSECONDS"
   ENDIF
   rpt_row += 1, row rpt_row, col 006,
   captions->crossmatch_expiration
   IF (xm_expire_dt_tm > 0)
    col 029, xm_expire_dt_tm"@SHORTDATE4YR", col 40,
    xm_expire_dt_tm"@TIMENOSECONDS"
   ENDIF
   rpt_row += 2, row rpt_row, col 004,
   captions->before_transfusion, col 055, captions->identified_recipient,
   col 096, captions->clerical_check, rpt_row += 1,
   row rpt_row, col 004, captions->of_the_wristband,
   col 054, captions->number_on_form, col 096,
   captions->released_date, rpt_row += 1, row rpt_row,
   col 004, captions->further_certify, col 059,
   captions->unit_number, col 096, captions->by_time,
   rpt_row += 1, row rpt_row, col 004,
   captions->stated_on_form, rpt_row += 1, row rpt_row,
   col 043, signature27, col 073,
   signature12, col 096, captions->transported_by,
   col 116, signature14, rpt_row += 1,
   row rpt_row, col 048, captions->transfusionist,
   col 075, captions->time_started, col 096,
   captions->received_date, rpt_row += 1, row rpt_row,
   col 096, captions->by_time, rpt_row += 1,
   row rpt_row, col 045, signature27,
   col 075, signature12, rpt_row += 1,
   row rpt_row, col 050, captions->transfusionist,
   col 075, captions->time_ended, rpt_row += 5,
   row rpt_row, col 006, captions->leukofiltered,
   col 033, captions->irradiated, col 060,
   captions->cmv_neg, col 090, captions->vol_reduced,
   rpt_row += 1, row rpt_row, col 006,
   captions->autologous, col 033, captions->directed,
   col 060, captions->hla_typed, col 090,
   captions->hgb_s_neg, rpt_row += 1, row rpt_row,
   col 006, captions->iga_deficient, col 033,
   captions->other, col 060, captions->absc,
   rpt_row += 2, row rpt_row, col 006,
   captions->return_to_bb, col 054, captions->in_30_min,
   rpt_row += 1, row rpt_row, col 006,
   captions->refrigerator, rpt_row = 52, row rpt_row,
   col 094, captions->hospital_name, rpt_row += 1,
   row rpt_row, col 094, captions->hospital_address,
   rpt_row += 1, row rpt_row, col 094,
   captions->hospital_address, rpt_row += 1, row rpt_row,
   col 094, captions->clia_num, rpt_row += 1,
   row rpt_row, col 058, captions->original_to_chart,
   rpt_row += 1, row rpt_row, col 061,
   captions->copy_to_lab
  FOOT  d.seq
   IF (d.seq > 0
    AND d.seq != tot_tag_cnt)
    BREAK
   ENDIF
  WITH maxcol = 132, maxrow = 61, compress,
   nolandscape, nullreport
 ;end select
 FREE SET captions
END GO
