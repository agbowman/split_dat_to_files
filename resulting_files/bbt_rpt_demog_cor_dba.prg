CREATE PROGRAM bbt_rpt_demog_cor:dba
 RECORD products_rec(
   1 products[*]
     2 product_id = f8
     2 autodir_states[*]
       3 product_event_id = f8
       3 person_list[*]
         4 person_id = f8
         4 encntr_id = f8
         4 ad_disp_name = c27
         4 ad_disp_name_curr = c27
         4 ad_disp_alias = c20
         4 ad_disp_alias_curr = c20
         4 updt_dt_tm = dq8
         4 username = c6
         4 correction_reason = vc
       3 donated_list[*]
         4 donated_by_relative = i2
         4 donated_by_relative_curr = i2
         4 donated_updt_dt_tm = dq8
         4 donated_username = c6
         4 donated_correction_reason = vc
       3 expected_list[*]
         4 expected_usage_dt_tm = dq8
         4 expected_usage_dt_tm_curr = dq8
         4 expected_updt_dt_tm = dq8
         4 expected_username = c6
         4 expected_correction_reason = vc
     2 displayed_in_report = i2
 )
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
   1 correction_type = vc
   1 demographic = vc
   1 current = vc
   1 previous = vc
   1 corrected = vc
   1 tech_id = vc
   1 correction_reason = vc
   1 product_number = vc
   1 product_sub_no = vc
   1 supplier_prefix = vc
   1 alternate_number = vc
   1 product_class = vc
   1 product_category = vc
   1 product_type = vc
   1 shipping_condition = vc
   1 visual_inspection = vc
   1 supplier_name = vc
   1 drawn_dt_tm = vc
   1 none = vc
   1 received_dt_tm = vc
   1 expiration_dt_tm = vc
   1 abo = vc
   1 rh = vc
   1 intended_use = vc
   1 segment_number = vc
   1 volume = vc
   1 unit_of_measure = vc
   1 patient_name = vc
   1 patient_id = vc
   1 usage_dt_tm = vc
   1 donated_by_relative = vc
   1 yes = vc
   1 no = vc
   1 owner_area = vc
   1 inventory_area = vc
   1 manufacturer_name = vc
   1 international_units = vc
   1 quantity = vc
   1 correction_notes = vc
   1 end_of_report = vc
   1 inc_title = vc
   1 inc_time = vc
   1 inc_as_of_date = vc
   1 inc_blood_bank_owner = vc
   1 inc_inventory_area = vc
   1 inc_beg_dt_tm = vc
   1 inc_end_dt_tm = vc
   1 inc_report_id = vc
   1 inc_page = vc
   1 inc_printed = vc
   1 no_data = vc
   1 donation_type = vc
   1 disease = vc
   1 auto_cross = vc
   1 auto_only = vc
   1 auto_bio = vc
   1 dir_cross = vc
   1 dir_only = vc
   1 dir_bio = vc
   1 emer_only = vc
   1 not_spec = vc
   1 product_type_bc = vc
   1 units_per_vial = vc
   1 serial_number = vc
 )
 SET captions->auto_cross = uar_i18ngetmessage(i18nhandle,"auto_cross","Autologous Crossover")
 SET captions->auto_only = uar_i18ngetmessage(i18nhandle,"auto_only","Autologous Only")
 SET captions->auto_bio = uar_i18ngetmessage(i18nhandle,"auto_bio","Autologous Biohazardous")
 SET captions->dir_cross = uar_i18ngetmessage(i18nhandle,"dir_cross","Directed Crossover")
 SET captions->dir_only = uar_i18ngetmessage(i18nhandle,"dir_only","Directed Only")
 SET captions->dir_bio = uar_i18ngetmessage(i18nhandle,"dir_bio","Directed Biohazardous")
 SET captions->emer_only = uar_i18ngetmessage(i18nhandle,"emer_only","Emergency Only")
 SET captions->not_spec = uar_i18ngetmessage(i18nhandle,"not_spec","Not Specified")
 SET captions->correction_type = uar_i18ngetmessage(i18nhandle,"correction_type","Correction Type:")
 SET captions->demographic = uar_i18ngetmessage(i18nhandle,"demographic","Demographic")
 SET captions->current = uar_i18ngetmessage(i18nhandle,"current","Current")
 SET captions->previous = uar_i18ngetmessage(i18nhandle,"previous","Previous")
 SET captions->corrected = uar_i18ngetmessage(i18nhandle,"corrected","Corrected")
 SET captions->tech_id = uar_i18ngetmessage(i18nhandle,"tech_id","Tech ID")
 SET captions->correction_reason = uar_i18ngetmessage(i18nhandle,"correction_reason",
  "Correction Reason")
 SET captions->product_number = uar_i18ngetmessage(i18nhandle,"product_number","Product Number")
 SET captions->product_sub_no = uar_i18ngetmessage(i18nhandle,"product_sub_no","Product Sub Number")
 SET captions->supplier_prefix = uar_i18ngetmessage(i18nhandle,"supplier_prefix","Supplier Prefix")
 SET captions->alternate_number = uar_i18ngetmessage(i18nhandle,"alternate_number","Alternate Number"
  )
 SET captions->product_class = uar_i18ngetmessage(i18nhandle,"product_class","Product Class")
 SET captions->product_category = uar_i18ngetmessage(i18nhandle,"product_category","Product Category"
  )
 SET captions->product_type = uar_i18ngetmessage(i18nhandle,"product_type","Product Type")
 SET captions->shipping_condition = uar_i18ngetmessage(i18nhandle,"shipping_condition",
  "Shipping Condition")
 SET captions->visual_inspection = uar_i18ngetmessage(i18nhandle,"visual_inspection",
  "Visual Inspection")
 SET captions->supplier_name = uar_i18ngetmessage(i18nhandle,"supplier_name","Supplier Name")
 SET captions->drawn_dt_tm = uar_i18ngetmessage(i18nhandle,"drawn_dt_tm","Drawn Date/Time")
 SET captions->none = uar_i18ngetmessage(i18nhandle,"none","None")
 SET captions->received_dt_tm = uar_i18ngetmessage(i18nhandle,"received_dt_tm","Received Date/Time")
 SET captions->expiration_dt_tm = uar_i18ngetmessage(i18nhandle,"expiration_dt_tm",
  "Expiration Date/Time")
 SET captions->abo = uar_i18ngetmessage(i18nhandle,"abo","ABO")
 SET captions->rh = uar_i18ngetmessage(i18nhandle,"rh","Rh")
 SET captions->intended_use = uar_i18ngetmessage(i18nhandle,"intended_use","Intended Use")
 SET captions->segment_number = uar_i18ngetmessage(i18nhandle,"segment_number","Segment Number")
 SET captions->volume = uar_i18ngetmessage(i18nhandle,"volume","Volume")
 SET captions->unit_of_measure = uar_i18ngetmessage(i18nhandle,"unit_of_measure","Unit of Measure")
 SET captions->patient_name = uar_i18ngetmessage(i18nhandle,"patient_name","Patient Name")
 SET captions->patient_id = uar_i18ngetmessage(i18nhandle,"patient_id","Patient ID")
 SET captions->usage_dt_tm = uar_i18ngetmessage(i18nhandle,"usage_dt_tm","Usage date/time")
 SET captions->donated_by_relative = uar_i18ngetmessage(i18nhandle,"donated_by_relative",
  "Donated By Relative")
 SET captions->yes = uar_i18ngetmessage(i18nhandle,"yes","Yes")
 SET captions->no = uar_i18ngetmessage(i18nhandle,"no","No")
 SET captions->owner_area = uar_i18ngetmessage(i18nhandle,"owner_area","Owner Area")
 SET captions->inventory_area = uar_i18ngetmessage(i18nhandle,"inventory_area","Inventory Area")
 SET captions->manufacturer_name = uar_i18ngetmessage(i18nhandle,"manufacturer_name",
  "Manufacturer Name")
 SET captions->international_units = uar_i18ngetmessage(i18nhandle,"international_units","IU")
 SET captions->quantity = uar_i18ngetmessage(i18nhandle,"quantity","Quantity")
 SET captions->correction_notes = uar_i18ngetmessage(i18nhandle,"correction_notes","Correction Notes"
  )
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  "* * * End of Report * * *")
 SET captions->inc_title = uar_i18ngetmessage(i18nhandle,"inc_title",
  "P R O D U C T   C O R R E C T I O N S")
 SET captions->inc_time = uar_i18ngetmessage(i18nhandle,"inc_time","Time:")
 SET captions->inc_as_of_date = uar_i18ngetmessage(i18nhandle,"inc_as_of_date","As of Date:")
 SET captions->inc_blood_bank_owner = uar_i18ngetmessage(i18nhandle,"inc_blood_bank_owner",
  "Blood Bank Owner: ")
 SET captions->inc_inventory_area = uar_i18ngetmessage(i18nhandle,"inc_inventory_area",
  "Inventory Area: ")
 SET captions->inc_beg_dt_tm = uar_i18ngetmessage(i18nhandle,"inc_beg_dt_tm","Beginnning Date/Time:")
 SET captions->inc_end_dt_tm = uar_i18ngetmessage(i18nhandle,"inc_end_dt_tm","Ending Date/Time:")
 SET captions->inc_report_id = uar_i18ngetmessage(i18nhandle,"inc_report_id",
  "Report ID: BBT_RPT_PROD_COR")
 SET captions->inc_page = uar_i18ngetmessage(i18nhandle,"inc_page","Page:")
 SET captions->inc_printed = uar_i18ngetmessage(i18nhandle,"inc_printed","Printed:")
 SET captions->no_data = uar_i18ngetmessage(i18nhandle,"no_data","(none)")
 SET captions->donation_type = uar_i18ngetmessage(i18nhandle,"donation_type","Donation Type")
 SET captions->disease = uar_i18ngetmessage(i18nhandle,"disease","Disease")
 SET captions->product_type_bc = uar_i18ngetmessage(i18nhandle,"product_type_bc",
  "Product Type Barcode")
 SET captions->units_per_vial = uar_i18ngetmessage(i18nhandle,"units_per_vial","IU per vial")
 SET captions->serial_number = uar_i18ngetmessage(i18nhandle,"serial_number","Serial Number")
 SET p_cnt = 0
 SET p_idx = 0
 SET pos = 0
 SET stat = 0
 SET x = 0
 SET stat = alterlist(products_rec->products,10)
 SET ad_cnt = 0
 SET cur_corr_id = 0.0
 SET last_owner_area_disp = fillstring(40," ")
 SET last_inv_area_disp = fillstring(40," ")
 SUBROUTINE (intended_use_definition(sintendeduse=c1) =vc)
   CASE (sintendeduse)
    OF "A":
     RETURN(captions->auto_cross)
    OF "1":
     RETURN(captions->auto_only)
    OF "X":
     RETURN(captions->auto_bio)
    OF "3":
     RETURN(captions->dir_bio)
    OF "D":
     RETURN(captions->dir_cross)
    OF "2":
     RETURN(captions->dir_only)
    OF "!":
     RETURN(captions->emer_only)
    OF "0":
     RETURN(captions->not_spec)
    ELSE
     RETURN("")
   ENDCASE
 END ;Subroutine
 SELECT INTO "nl:"
  cp.product_id, pr.product_id, pr.cur_owner_area_cd,
  pr.cur_inv_area_cd, cp.correction_type_cd, cp.correction_flag
  FROM (dummyt d1  WITH seq = 1),
   corrected_product cp,
   product pr
  PLAN (d1)
   JOIN (cp
   WHERE cp.correction_type_cd=demog_cd
    AND cp.updt_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->end_dt_tm)
    AND ((cp.correction_flag=0) OR (cp.correction_flag = null))
    AND cp.correction_id != null
    AND cp.correction_id > 0
    AND cp.product_id != null
    AND cp.product_id > 0)
   JOIN (pr
   WHERE cp.product_id=pr.product_id
    AND (((request->cur_owner_area_cd > 0.0)
    AND (request->cur_owner_area_cd=pr.cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0.0)))
    AND (((request->cur_inv_area_cd > 0.0)
    AND (request->cur_inv_area_cd=pr.cur_inv_area_cd)) OR ((request->cur_inv_area_cd=0.0))) )
  ORDER BY cp.product_id
  HEAD REPORT
   p_cnt = 0
  HEAD cp.product_id
   p_cnt += 1
   IF (mod(p_cnt,10)=1
    AND p_cnt != 1)
    stat = alterlist(products_rec->products,(p_cnt+ 9))
   ENDIF
   products_rec->products[p_cnt].product_id = cp.product_id
  FOOT REPORT
   stat = alterlist(products_rec->products,p_cnt)
  WITH nocounter
 ;end select
 IF ((request->null_ind=0)
  AND p_cnt=0)
  GO TO exit_script
 ELSE
  SET datafoundflag = true
 ENDIF
 SELECT INTO "nl:"
  pr.product_id, ad.product_event_id, ad.person_id,
  ad.encntr_id, ad.expected_usage_dt_tm, ad.donated_by_relative_ind,
  ad_per.name_full_formatted"####################", ad_ea.alias"####################"
  FROM product pr,
   auto_directed ad,
   person ad_per,
   encntr_alias ad_ea
  PLAN (pr
   WHERE expand(p_idx,1,p_cnt,pr.product_id,products_rec->products[p_idx].product_id))
   JOIN (ad
   WHERE (ad.product_id= Outerjoin(pr.product_id))
    AND (ad.active_ind= Outerjoin(1)) )
   JOIN (ad_per
   WHERE (ad_per.person_id= Outerjoin(ad.person_id)) )
   JOIN (ad_ea
   WHERE (ad_ea.encntr_id= Outerjoin(ad.encntr_id))
    AND (ad_ea.encntr_id> Outerjoin(0.0))
    AND (ad_ea.encntr_alias_type_cd= Outerjoin(mrn_encntr_alias_type_cd)) )
  ORDER BY pr.product_id
  HEAD REPORT
   x = 0
  HEAD pr.product_id
   x += 1, products_rec->products[x].displayed_in_report = 0, ad_cnt = 0,
   stat = alterlist(products_rec->products[x].autodir_states,0)
  HEAD ad.product_event_id
   IF (ad.product_event_id > 0.0
    AND ad.person_id > 0.0
    AND ad.encntr_id > 0.0)
    ad_cnt += 1
    IF (ad_cnt > size(products_rec->products[x].autodir_states,5))
     stat = alterlist(products_rec->products[x].autodir_states,(ad_cnt+ 2))
    ENDIF
    products_rec->products[x].autodir_states[ad_cnt].product_event_id = ad.product_event_id, stat =
    alterlist(products_rec->products[x].autodir_states[ad_cnt].person_list,1), products_rec->
    products[x].autodir_states[ad_cnt].person_list[1].person_id = ad.person_id,
    products_rec->products[x].autodir_states[ad_cnt].person_list[1].encntr_id = ad.encntr_id,
    products_rec->products[x].autodir_states[ad_cnt].person_list[1].ad_disp_name_curr = ad_per
    .name_full_formatted, products_rec->products[x].autodir_states[ad_cnt].person_list[1].
    ad_disp_name = ""
    IF (size(trim(cnvtalias(ad_ea.alias,ad_ea.alias_pool_cd))) > 0)
     products_rec->products[x].autodir_states[ad_cnt].person_list[1].ad_disp_alias_curr = cnvtalias(
      ad_ea.alias,ad_ea.alias_pool_cd)
    ELSE
     products_rec->products[x].autodir_states[ad_cnt].person_list[1].ad_disp_alias_curr = captions->
     no_data
    ENDIF
    products_rec->products[x].autodir_states[ad_cnt].person_list[1].ad_disp_alias = "", stat =
    alterlist(products_rec->products[x].autodir_states[ad_cnt].expected_list,1), products_rec->
    products[x].autodir_states[ad_cnt].expected_list[1].expected_usage_dt_tm_curr = cnvtdatetime(ad
     .expected_usage_dt_tm),
    stat = alterlist(products_rec->products[x].autodir_states[ad_cnt].donated_list,1), products_rec->
    products[x].autodir_states[ad_cnt].donated_list[1].donated_by_relative = - (1), products_rec->
    products[x].autodir_states[ad_cnt].donated_list[1].donated_by_relative_curr = ad
    .donated_by_relative_ind
   ENDIF
  FOOT  pr.product_id
   stat = alterlist(products_rec->products[x].autodir_states,ad_cnt)
  FOOT REPORT
   x = 0
  WITH nocounter
 ;end select
 SET stat = alterlist(cor_pr->cor_rec,10)
 SELECT INTO cpm_cfn_info->file_name_logical
  pr.product_id, d_flg = decode(bp.seq,"BP ",de.seq,"DE ","XXX"), ad_ind = decode(ad.seq,"AD","XX"),
  cp.correction_id, cp.abo_cd, cp.rh_cd,
  cp_abo_disp = uar_get_code_display(cp.abo_cd), cp_rh_disp = uar_get_code_display(cp.rh_cd), cp
  .intended_use_print_parm_txt,
  cp.expire_dt_tm";;f", cp.drawn_dt_tm, cp.product_id,
  cp.product_nbr, cp.serial_number_txt, cp.product_sub_nbr,
  cp.updt_dt_tm, cp_ship_cond_disp = uar_get_code_display(cp.ship_cond_cd), cp_vis_insp_disp =
  uar_get_code_display(cp.vis_insp_cd),
  cp_product_disp = uar_get_code_display(cp.product_cd), cp_product_cat_disp = uar_get_code_display(
   cp.product_cat_cd), cp_product_class_disp = uar_get_code_display(cp.product_class_cd),
  cp_reason_disp = uar_get_code_display(cp.correction_reason_cd), cp_unit_meas_disp =
  uar_get_code_display(cp.unit_meas_cd), cp_owner_area_disp = uar_get_code_display(cp
   .cur_owner_area_cd),
  cp_inv_area_disp = uar_get_code_display(cp.cur_inv_area_cd), cp_donation_type_disp =
  uar_get_code_display(cp.donation_type_cd), cp_disease_disp = uar_get_code_display(cp.disease_cd),
  pr.product_nbr, pr.serial_number_txt, pr.product_sub_nbr,
  pr.alternate_nbr, pr.cur_expire_dt_tm, pr.intended_use_print_parm_txt,
  pr_orig_ship_cond_disp = uar_get_code_display(r.ship_cond_cd), pr_orig_vis_insp_disp =
  uar_get_code_display(r.vis_insp_cd), pr_product_disp = uar_get_code_display(pr.product_cd),
  pr_product_cat_disp = uar_get_code_display(pr.product_cat_cd), pr_product_class_disp =
  uar_get_code_display(pr.product_class_cd), cur_unit_meas_disp = uar_get_code_display(pr
   .cur_unit_meas_cd),
  pr_owner_area_disp = uar_get_code_display(pr.cur_owner_area_cd), pr_inv_area_disp =
  uar_get_code_display(pr.cur_inv_area_cd), pr_donation_type_disp = uar_get_code_display(pr
   .donation_type_cd),
  pr_disease_disp = uar_get_code_display(pr.disease_cd), prs.username, og1.org_name
  "####################",
  og.org_name"####################", bp.supplier_prefix, bp.segment_nbr,
  bp_abo_disp = uar_get_code_display(bp.cur_abo_cd), bp_rh_disp = uar_get_code_display(bp.cur_rh_cd),
  bp.cur_volume,
  bp.drawn_dt_tm, de.cur_avail_qty, de.manufacturer_id,
  de.cur_intl_units, de_item_volume = decode(de.seq,de.item_volume,0), de.units_per_vial,
  cp.person_id, cp.encntr_id, cp.expected_usage_dt_tm";;f",
  cp.updt_id, cp.updt_dt_tm, cp.volume,
  cp.manufacturer_id, cp.cur_avail_qty"#######", cp.cur_intl_units"#######",
  cp.units_per_vial_cnt"#######", og_de.org_name"####################", o_de.org_name
  "####################"
  FROM (dummyt d_p  WITH seq = value(p_cnt)),
   corrected_product cp,
   product pr,
   prsnl prs,
   (dummyt d3  WITH seq = 1),
   organization og1,
   (dummyt d6  WITH seq = 1),
   organization og,
   (dummyt d_og_de  WITH seq = 1),
   organization og_de,
   (dummyt d7  WITH seq = 1),
   blood_product bp,
   derivative de,
   (dummyt d_o_de  WITH seq = 1),
   organization o_de,
   auto_directed ad,
   (dummyt d12  WITH seq = 1),
   (dummyt d_r  WITH seq = 1),
   receipt r,
   dummyt d_cp_per,
   person cp_per,
   dummyt d_cp_ea,
   encntr_alias cp_ea,
   dummyt d_cp_ad,
   auto_directed cp_ad,
   dummyt d_cp_pe_per,
   person cp_pe_per,
   dummyt d_cp_pe_ea,
   encntr_alias cp_pe_ea
  PLAN (d_p)
   JOIN (pr
   WHERE (pr.product_id=products_rec->products[d_p.seq].product_id))
   JOIN (cp
   WHERE cp.correction_type_cd=demog_cd
    AND cp.updt_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->end_dt_tm)
    AND cp.correction_id != null
    AND cp.correction_id > 0
    AND cp.product_id=pr.product_id)
   JOIN (prs
   WHERE prs.person_id=cp.updt_id)
   JOIN (d_r
   WHERE d_r.seq=1)
   JOIN (r
   WHERE r.product_id=pr.product_id)
   JOIN (d3
   WHERE d3.seq=1)
   JOIN (og1
   WHERE pr.cur_supplier_id=og1.organization_id
    AND pr.cur_supplier_id > 0)
   JOIN (d6
   WHERE d6.seq=1)
   JOIN (og
   WHERE og.organization_id=cp.supplier_id
    AND og.organization_id > 0
    AND og.organization_id != null)
   JOIN (d_og_de
   WHERE d_og_de.seq=1)
   JOIN (og_de
   WHERE og_de.organization_id=cp.manufacturer_id
    AND og_de.organization_id > 0
    AND og_de.organization_id != null)
   JOIN (d7
   WHERE d7.seq=1)
   JOIN (((bp
   WHERE cp.product_id=bp.product_id)
   JOIN (d12
   WHERE d12.seq=1)
   JOIN (ad
   WHERE ad.product_id=cp.product_id
    AND ad.active_ind=1)
   ) ORJOIN ((de
   WHERE cp.product_id=de.product_id)
   JOIN (d_o_de
   WHERE d_o_de.seq=1)
   JOIN (o_de
   WHERE o_de.organization_id=de.manufacturer_id)
   )) JOIN (d_cp_ad)
   JOIN (cp_ad
   WHERE cp_ad.product_event_id=cp.product_event_id
    AND cp_ad.product_event_id > 0.0)
   JOIN (d_cp_pe_per)
   JOIN (cp_pe_per
   WHERE cp_pe_per.person_id=cp_ad.person_id)
   JOIN (d_cp_pe_ea)
   JOIN (cp_pe_ea
   WHERE cp_pe_ea.encntr_id=cp_ad.encntr_id
    AND cp_pe_ea.encntr_id > 0.0
    AND cp_pe_ea.encntr_alias_type_cd=mrn_encntr_alias_type_cd)
   JOIN (d_cp_per)
   JOIN (cp_per
   WHERE cp_per.person_id=cp.person_id
    AND cp_per.person_id > 0.0)
   JOIN (d_cp_ea)
   JOIN (cp_ea
   WHERE cp_ea.encntr_id=cp.encntr_id
    AND cp_ea.encntr_alias_type_cd=mrn_encntr_alias_type_cd
    AND cp_ea.encntr_id > 0.0)
  ORDER BY pr_owner_area_disp, pr_inv_area_disp, pr.product_id,
   cp.correction_id DESC, d_flg
  HEAD REPORT
   correction_type_flag = " ", page_break = "N", new_report = "Y",
   equal_line = fillstring(126,"=")
   IF (size(trim(last_owner_area_disp))=0
    AND size(trim(last_inv_area_disp))=0)
    last_owner_area_disp = pr_owner_area_disp, last_inv_area_disp = pr_inv_area_disp
   ENDIF
  HEAD PAGE
   row 0,
   CALL center(captions->inc_title,1,125), col 107,
   captions->inc_time, col 121, curtime"@TIMENOSECONDS;;m",
   row + 1, col 107, captions->inc_as_of_date,
   col 119, curdate"@DATECONDENSED;;d", inc_i18nhandle = 0,
   inc_h = uar_i18nlocalizationinit(inc_i18nhandle,curprog,"",curcclrev), row 0
   IF (sub_get_location_name="<<INFORMATION NOT FOUND>>")
    inc_info_not_found = uar_i18ngetmessage(inc_i18nhandle,"inc_information_not_found",
     "<<INFORMATION NOT FOUND>>"), col 1, inc_info_not_found
   ELSE
    col 1, sub_get_location_name
   ENDIF
   row + 1
   IF (sub_get_location_name != "<<INFORMATION NOT FOUND>>")
    IF (sub_get_location_address1 != " ")
     col 1, sub_get_location_address1, row + 1
    ENDIF
    IF (sub_get_location_address2 != " ")
     col 1, sub_get_location_address2, row + 1
    ENDIF
    IF (sub_get_location_address3 != " ")
     col 1, sub_get_location_address3, row + 1
    ENDIF
    IF (sub_get_location_address4 != " ")
     col 1, sub_get_location_address4, row + 1
    ENDIF
    IF (sub_get_location_citystatezip != ",   ")
     col 1, sub_get_location_citystatezip, row + 1
    ENDIF
    IF (sub_get_location_country != " ")
     col 1, sub_get_location_country, row + 1
    ENDIF
   ENDIF
   row + 1, dt_tm = cnvtdatetime(request->beg_dt_tm), col 32,
   captions->inc_beg_dt_tm, col 56, dt_tm"@DATECONDENSED;;d",
   col 64, dt_tm"@TIMENOSECONDS;;m", dt_tm = cnvtdatetime(request->end_dt_tm),
   col 74, captions->inc_end_dt_tm, col 92,
   dt_tm"@DATECONDENSED;;d", col 100, dt_tm"@TIMENOSECONDS;;m",
   row + 2, col 1, captions->inc_blood_bank_owner
   IF ((request->cur_owner_area_cd=0.0))
    cur_owner_area_disp = validate(last_owner_area_disp,cur_owner_area_disp)
   ENDIF
   col 19, cur_owner_area_disp, row + 1,
   col 1, captions->inc_inventory_area
   IF ((request->cur_inv_area_cd=0.0))
    cur_inv_area_disp = validate(last_inv_area_disp,cur_inv_area_disp)
   ENDIF
   col 17, cur_inv_area_disp, row + 2,
   col 1, captions->correction_type, col 18,
   demog_disp, row + 2, col 8,
   captions->demographic, col 37, captions->current,
   col 64, captions->previous, col 88,
   captions->corrected, col 100, captions->tech_id,
   col 109, captions->correction_reason, row + 1,
   col 1, "-------------------------", col 27,
   "---------------------------", col 55, "---------------------------",
   col 86, "-------------", col 100,
   "-------", col 108, "------------------",
   row + 1
  HEAD pr.product_id
   IF (row >= 56)
    BREAK
   ENDIF
   cor_idx = 0, stat = alterlist(cor_pr->cor_rec,0), stat = alterlist(cor_pr->cor_rec,10),
   ad_disp_name = fillstring(27," "), ad_disp_alias = fillstring(20," "), ad_expected_usage_dt_tm =
   cnvtdatetime(""),
   current_aborh_disp = fillstring(40," "), current_volume = 0, current_supplier_prefix = fillstring(
    5," "),
   current_segment_nbr = fillstring(25," ")
   IF (((last_owner_area_disp != pr_owner_area_disp) OR (last_inv_area_disp != pr_inv_area_disp)) )
    last_owner_area_disp = pr_owner_area_disp, last_inv_area_disp = pr_inv_area_disp, BREAK
   ENDIF
   col 1, "*"
  HEAD cp.correction_id
   cor_idx += 1
   IF (mod(cor_idx,10)=1
    AND cor_idx != 1)
    stat = alterlist(cor_pr->cor_rec,(cor_idx+ 9))
   ENDIF
   cor_pr->cor_rec[cor_idx].correction_type_cd = cp.correction_type_cd, cor_pr->cor_rec[cor_idx].
   ship_cond = cp_ship_cond_disp
   IF (cp.ship_cond_cd > 0.0)
    cor_pr->cor_rec[cor_idx].ship_cond_cd_chg_ind = 1
   ENDIF
   cor_pr->cor_rec[cor_idx].vis_insp = cp_vis_insp_disp
   IF (cp.vis_insp_cd > 0.0)
    cor_pr->cor_rec[cor_idx].vis_insp_cd_chg_ind = 1
   ENDIF
   cor_pr->cor_rec[cor_idx].product_nbr = cp.product_nbr
   IF (cp.product_nbr != null)
    cor_pr->cor_rec[cor_idx].product_nbr_chg_ind = 1
   ENDIF
   cor_pr->cor_rec[cor_idx].serial_nbr = cp.serial_number_txt
   IF (cp.serial_number_txt != null)
    cor_pr->cor_rec[cor_idx].serial_nbr_chg_ind = 1
   ENDIF
   cor_pr->cor_rec[cor_idx].product_sub_nbr = cp.product_sub_nbr
   IF (cp.product_sub_nbr != null)
    cor_pr->cor_rec[cor_idx].product_sub_nbr_chg_ind = 1
   ENDIF
   cor_pr->cor_rec[cor_idx].supplier_prefix = cp.supplier_prefix
   IF (cp.supplier_prefix != null)
    cor_pr->cor_rec[cor_idx].supplier_prefix_chg_ind = 1
   ENDIF
   cor_pr->cor_rec[cor_idx].alternate_nbr = cp.alternate_nbr
   IF (cp.alternate_nbr != null)
    cor_pr->cor_rec[cor_idx].alternate_nbr_chg_ind = 1
   ENDIF
   cor_pr->cor_rec[cor_idx].product_type = cp_product_disp
   IF (cp.product_cd > 0.0)
    cor_pr->cor_rec[cor_idx].product_cd_chg_ind = 1
   ENDIF
   cor_pr->cor_rec[cor_idx].product_type_bc = cp.product_type_barcode
   IF (cp.product_type_barcode != null)
    cor_pr->cor_rec[cor_idx].product_type_bc_chg_ind = 1
   ENDIF
   cor_pr->cor_rec[cor_idx].product_cat = cp_product_cat_disp
   IF (cp.product_cat_cd > 0.0)
    cor_pr->cor_rec[cor_idx].product_cat_cd_chg_ind = 1
   ENDIF
   cor_pr->cor_rec[cor_idx].product_class = cp_product_class_disp
   IF (cp.product_class_cd > 0.0)
    cor_pr->cor_rec[cor_idx].product_class_cd_chg_ind = 1
   ENDIF
   cor_pr->cor_rec[cor_idx].org_name = og.org_name
   IF (cp.supplier_id > 0.0)
    cor_pr->cor_rec[cor_idx].supplier_id_chg_ind = 1
   ENDIF
   cor_pr->cor_rec[cor_idx].recv_dt_tm = cp.recv_dt_tm
   IF (cp.recv_dt_tm != null)
    cor_pr->cor_rec[cor_idx].recv_dt_tm_chg_ind = 1
   ENDIF
   cor_pr->cor_rec[cor_idx].volume = cp.volume
   IF (cp.volume != null)
    cor_pr->cor_rec[cor_idx].volume_chg_ind = 1
   ENDIF
   cor_pr->cor_rec[cor_idx].unit_of_measure = cp_unit_meas_disp
   IF (cp.unit_meas_cd > 0.0)
    cor_pr->cor_rec[cor_idx].unit_meas_cd_chg_ind = 1
   ENDIF
   cor_pr->cor_rec[cor_idx].expire_dt_tm = cp.expire_dt_tm
   IF (cp.expire_dt_tm != null)
    cor_pr->cor_rec[cor_idx].expire_dt_tm_chg_ind = 1
   ENDIF
   cor_pr->cor_rec[cor_idx].drawn_dt_tm = cp.drawn_dt_tm
   IF (cp.drawn_dt_tm != null)
    cor_pr->cor_rec[cor_idx].drawn_dt_tm_chg_ind = 1
   ENDIF
   cor_pr->cor_rec[cor_idx].abo_cd = cp.abo_cd
   IF (cp.abo_cd > 0.0)
    cor_pr->cor_rec[cor_idx].abo_cd_chg_ind = 1
   ENDIF
   cor_pr->cor_rec[cor_idx].rh_cd = cp.rh_cd
   IF (cp.rh_cd > 0.0)
    cor_pr->cor_rec[cor_idx].rh_cd_chg_ind = 1
   ENDIF
   cor_pr->cor_rec[cor_idx].abo_disp = cp_abo_disp, cor_pr->cor_rec[cor_idx].rh_disp = cp_rh_disp,
   cor_pr->cor_rec[cor_idx].intended_use = intended_use_definition(cp.intended_use_print_parm_txt)
   IF (cp.intended_use_print_parm_txt != null)
    cor_pr->cor_rec[cor_idx].intended_use_chg_ind = 1
   ENDIF
   cor_pr->cor_rec[cor_idx].segment_nbr = cp.segment_nbr
   IF (cp.segment_nbr != null)
    cor_pr->cor_rec[cor_idx].segment_nbr_chg_ind = 1
   ENDIF
   cor_pr->cor_rec[cor_idx].owner_area_disp = cp_owner_area_disp
   IF (cp.cur_owner_area_cd > 0.0)
    cor_pr->cor_rec[cor_idx].cur_owner_area_cd_chg_ind = 1
   ENDIF
   cor_pr->cor_rec[cor_idx].inv_area_disp = cp_inv_area_disp
   IF (cp.cur_inv_area_cd > 0.0)
    cor_pr->cor_rec[cor_idx].cur_inv_area_cd_chg_ind = 1
   ENDIF
   cor_pr->cor_rec[cor_idx].manufacturer_id = cp.manufacturer_id
   IF (cp.manufacturer_id > 0.0)
    cor_pr->cor_rec[cor_idx].manufacturer_id_chg_ind = 1
   ENDIF
   cor_pr->cor_rec[cor_idx].manu_name = og_de.org_name, cor_pr->cor_rec[cor_idx].cur_avail_qty = cp
   .cur_avail_qty
   IF (cp.cur_avail_qty > 0.0)
    cor_pr->cor_rec[cor_idx].cur_avail_qty_chg_ind = 1
   ENDIF
   cor_pr->cor_rec[cor_idx].cur_intl_units = cp.cur_intl_units
   IF (cp.cur_intl_units > 0.0)
    cor_pr->cor_rec[cor_idx].cur_intl_units_chg_ind = 1
   ENDIF
   cor_pr->cor_rec[cor_idx].units_per_vial = cp.units_per_vial_cnt
   IF (cp.units_per_vial_cnt > 0.0)
    cor_pr->cor_rec[cor_idx].units_per_vial_chg_ind = 1
   ENDIF
   cor_pr->cor_rec[cor_idx].correction_note = cp.correction_note
   IF (size(trim(cp.correction_note),1) > 0)
    cor_pr->cor_rec[cor_idx].correction_note_chg_ind = 1
   ENDIF
   cor_pr->cor_rec[cor_idx].updt_dt_tm = cp.updt_dt_tm, cor_pr->cor_rec[cor_idx].username = substring
   (1,6,prs.username), cor_pr->cor_rec[cor_idx].correction_reason = substring(1,18,cp_reason_disp),
   cor_pr->cor_rec[cor_idx].donation_type_disp = cp_donation_type_disp
   IF (cp.donation_type_cd >= 0.0)
    cor_pr->cor_rec[cor_idx].donation_type_chg_ind = 1
   ENDIF
   cor_pr->cor_rec[cor_idx].disease_disp = cp_disease_disp
   IF (cp.disease_cd >= 0.0)
    cor_pr->cor_rec[cor_idx].disease_chg_ind = 1
   ENDIF
  DETAIL
   IF (d_flg="BP")
    current_volume = bp.cur_volume, current_supplier_prefix = bp.supplier_prefix, current_segment_nbr
     = bp.segment_nbr
   ELSEIF (d_flg="DE")
    current_volume = de_item_volume
   ENDIF
   IF (ad_ind="AD")
    cor_pr->cor_rec[cor_idx].ad_ind = 1
    IF (cur_corr_id != cp.correction_id)
     cur_corr_id = cp.correction_id
     IF (cp.product_event_id > 0.0)
      pos = locateval(p_idx,1,size(products_rec->products[d_p.seq].autodir_states,5),cp
       .product_event_id,products_rec->products[d_p.seq].autodir_states[p_idx].product_event_id)
      IF (pos < 1)
       IF (cp.expected_usage_dt_tm < 1.0
        AND (cp.donated_by_relative_ind=- (1.0))
        AND cp.person_id < 1.0
        AND cp.encntr_id < 1.0)
        ad_cnt = (size(products_rec->products[d_p.seq].autodir_states,5)+ 1), stat = alterlist(
         products_rec->products[d_p.seq].autodir_states,ad_cnt), stat = alterlist(products_rec->
         products[d_p.seq].autodir_states[ad_cnt].person_list,1),
        products_rec->products[d_p.seq].autodir_states[ad_cnt].person_list[1].person_id = cp_pe_per
        .person_id, products_rec->products[d_p.seq].autodir_states[ad_cnt].person_list[1].
        ad_disp_name = cp_pe_per.name_full_formatted, products_rec->products[d_p.seq].autodir_states[
        ad_cnt].person_list[1].encntr_id = cp_pe_ea.encntr_id,
        products_rec->products[d_p.seq].autodir_states[ad_cnt].person_list[1].ad_disp_alias =
        cnvtalias(cp_pe_ea.alias,cp_pe_ea.alias_pool_cd), products_rec->products[d_p.seq].
        autodir_states[ad_cnt].person_list[1].updt_dt_tm = cnvtdatetime(cp.updt_dt_tm), products_rec
        ->products[d_p.seq].autodir_states[ad_cnt].person_list[1].username = substring(1,6,prs
         .username),
        products_rec->products[d_p.seq].autodir_states[ad_cnt].person_list[1].correction_reason =
        cp_reason_disp, stat = alterlist(products_rec->products[d_p.seq].autodir_states[ad_cnt].
         expected_list,1), products_rec->products[d_p.seq].autodir_states[ad_cnt].expected_list[1].
        expected_usage_dt_tm = cnvtdatetime(cp_ad.expected_usage_dt_tm),
        products_rec->products[d_p.seq].autodir_states[ad_cnt].expected_list[1].expected_updt_dt_tm
         = cnvtdatetime(cp.updt_dt_tm), products_rec->products[d_p.seq].autodir_states[ad_cnt].
        expected_list[1].expected_username = substring(1,6,prs.username), products_rec->products[d_p
        .seq].autodir_states[ad_cnt].expected_list[1].expected_correction_reason = cp_reason_disp,
        stat = alterlist(products_rec->products[d_p.seq].autodir_states[ad_cnt].donated_list,1),
        products_rec->products[d_p.seq].autodir_states[ad_cnt].donated_list[1].donated_by_relative =
        cp_ad.donated_by_relative_ind, products_rec->products[d_p.seq].autodir_states[ad_cnt].
        donated_list[1].donated_updt_dt_tm = cnvtdatetime(cp.updt_dt_tm),
        products_rec->products[d_p.seq].autodir_states[ad_cnt].donated_list[1].donated_username =
        substring(1,6,prs.username), products_rec->products[d_p.seq].autodir_states[ad_cnt].
        donated_list[1].donated_correction_reason = cp_reason_disp, products_rec->products[d_p.seq].
        autodir_states[ad_cnt].donated_list[1].donated_by_relative_curr = - (1)
       ENDIF
      ELSE
       IF (size(trim(cp_per.name_full_formatted)) > 0)
        x = size(products_rec->products[d_p.seq].autodir_states[pos].person_list,5)
        IF (x=1)
         IF (size(trim(products_rec->products[d_p.seq].autodir_states[pos].person_list[1].
           ad_disp_name)) > 0)
          x += 1, stat = alterlist(products_rec->products[d_p.seq].autodir_states[pos].person_list,x)
         ENDIF
        ELSE
         x += 1, stat = alterlist(products_rec->products[d_p.seq].autodir_states[pos].person_list,x)
        ENDIF
        IF (size(trim(cp_per.name_full_formatted)) > 0)
         products_rec->products[d_p.seq].autodir_states[pos].person_list[x].ad_disp_name = cp_per
         .name_full_formatted
        ENDIF
        IF (size(trim(cnvtalias(cp_ea.alias,cp_ea.alias_pool_cd))) > 0)
         products_rec->products[d_p.seq].autodir_states[pos].person_list[x].ad_disp_alias = cnvtalias
         (cp_ea.alias,cp_ea.alias_pool_cd)
        ELSE
         products_rec->products[d_p.seq].autodir_states[pos].person_list[x].ad_disp_alias = captions
         ->no_data
        ENDIF
        IF (cp.updt_dt_tm > 0)
         products_rec->products[d_p.seq].autodir_states[pos].person_list[x].updt_dt_tm = cnvtdatetime
         (cp.updt_dt_tm)
        ENDIF
        IF (size(prs.username) > 0)
         products_rec->products[d_p.seq].autodir_states[pos].person_list[x].username = substring(1,6,
          prs.username)
        ENDIF
        IF (size(cp_reason_disp) > 0)
         products_rec->products[d_p.seq].autodir_states[pos].person_list[x].correction_reason =
         cp_reason_disp
        ENDIF
       ENDIF
       IF (cp.expected_usage_dt_tm > 0)
        x = size(products_rec->products[d_p.seq].autodir_states[pos].expected_list,5)
        IF (x=1)
         IF ((products_rec->products[d_p.seq].autodir_states[pos].expected_list[1].
         expected_usage_dt_tm > 0))
          x += 1, stat = alterlist(products_rec->products[d_p.seq].autodir_states[pos].expected_list,
           x)
         ENDIF
        ELSE
         x += 1, stat = alterlist(products_rec->products[d_p.seq].autodir_states[pos].expected_list,x
          )
        ENDIF
        products_rec->products[d_p.seq].autodir_states[pos].expected_list[x].expected_usage_dt_tm =
        cnvtdatetime(cp.expected_usage_dt_tm), products_rec->products[d_p.seq].autodir_states[pos].
        expected_list[x].expected_updt_dt_tm = cnvtdatetime(cp.updt_dt_tm), products_rec->products[
        d_p.seq].autodir_states[pos].expected_list[x].expected_username = substring(1,6,prs.username),
        products_rec->products[d_p.seq].autodir_states[pos].expected_list[x].
        expected_correction_reason = cp_reason_disp
       ENDIF
       IF ((cp.donated_by_relative_ind > - (1)))
        x = size(products_rec->products[d_p.seq].autodir_states[pos].donated_list,5)
        IF (x=1)
         IF ((products_rec->products[d_p.seq].autodir_states[pos].donated_list[1].donated_by_relative
          > - (1)))
          x += 1, stat = alterlist(products_rec->products[d_p.seq].autodir_states[pos].donated_list,x
           ), products_rec->products[d_p.seq].autodir_states[pos].donated_list[x].
          donated_by_relative_curr = - (1)
         ENDIF
        ELSE
         x += 1, stat = alterlist(products_rec->products[d_p.seq].autodir_states[pos].donated_list,x),
         products_rec->products[d_p.seq].autodir_states[pos].donated_list[x].donated_by_relative_curr
          = - (1)
        ENDIF
        products_rec->products[d_p.seq].autodir_states[pos].donated_list[x].donated_by_relative = cp
        .donated_by_relative_ind, products_rec->products[d_p.seq].autodir_states[pos].donated_list[x]
        .donated_updt_dt_tm = cnvtdatetime(cp.updt_dt_tm), products_rec->products[d_p.seq].
        autodir_states[pos].donated_list[x].donated_username = substring(1,6,prs.username),
        products_rec->products[d_p.seq].autodir_states[pos].donated_list[x].donated_correction_reason
         = cp_reason_disp
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ELSE
    cor_pr->cor_rec[cor_idx].ad_ind = 0
   ENDIF
  FOOT  pr.product_id
   IF (cp.correction_id > 0.0)
    first_time = "Y", new_line = "N", row + 1
    FOR (x = 1 TO cor_idx)
     IF (first_time="Y")
      first_time = "N", col 1, captions->product_number,
      prod_nbr_display = trim(pr.product_nbr), col 27, prod_nbr_display
     ENDIF
     ,
     IF ((cor_pr->cor_rec[x].product_nbr_chg_ind=1))
      IF (new_line="N")
       new_line = "Y"
      ELSE
       row + 1
       IF (row > 56)
        BREAK
       ENDIF
      ENDIF
      col 55, cor_pr->cor_rec[x].product_nbr"###############", updt_dt_tm = cnvtdatetime(cor_pr->
       cor_rec[x].updt_dt_tm),
      col 86, updt_dt_tm"@DATECONDENSED;;d", col 94,
      updt_dt_tm"@TIMENOSECONDS;;M", col 100, cor_pr->cor_rec[x].username"######",
      col 108, cor_pr->cor_rec[x].correction_reason
     ENDIF
    ENDFOR
    row + 1
    IF (row > 56)
     BREAK
    ENDIF
    first_time = "Y", new_line = "N"
    FOR (x = 1 TO cor_idx)
     IF (first_time="Y")
      first_time = "N", col 1, captions->product_sub_no,
      col 27, pr.product_sub_nbr
     ENDIF
     ,
     IF ((cor_pr->cor_rec[x].product_sub_nbr_chg_ind=1))
      IF (new_line="N")
       new_line = "Y"
      ELSE
       row + 1
       IF (row > 56)
        BREAK
       ENDIF
      ENDIF
      IF (size(trim(cor_pr->cor_rec[x].product_sub_nbr))=0)
       col 55, captions->no_data
      ELSE
       col 55, cor_pr->cor_rec[x].product_sub_nbr"#####"
      ENDIF
      updt_dt_tm = cnvtdatetime(cor_pr->cor_rec[x].updt_dt_tm), col 86, updt_dt_tm"@DATECONDENSED;;d",
      col 94, updt_dt_tm"@TIMENOSECONDS;;M", col 100,
      cor_pr->cor_rec[x].username"######", col 108, cor_pr->cor_rec[x].correction_reason
     ENDIF
    ENDFOR
    row + 1
    IF (row > 56)
     BREAK
    ENDIF
    first_time = "Y", new_line = "N"
    FOR (x = 1 TO cor_idx)
      IF (first_time="Y")
       first_time = "N"
       IF (((pr.serial_number_txt != null) OR (trim(cor_pr->cor_rec[x].serial_nbr) != null)) )
        col 1, captions->serial_number, col 27,
        pr.serial_number_txt
        IF (size(trim(cor_pr->cor_rec[x].serial_nbr)) > 0)
         IF (new_line="N")
          new_line = "Y"
         ELSE
          row + 1
          IF (row > 56)
           BREAK
          ENDIF
         ENDIF
         col 55, cor_pr->cor_rec[x].serial_nbr"####################", updt_dt_tm = cnvtdatetime(
          cor_pr->cor_rec[x].updt_dt_tm),
         col 86, updt_dt_tm"@DATECONDENSED;;d", col 94,
         updt_dt_tm"@TIMENOSECONDS;;M", col 100, cor_pr->cor_rec[x].username"######",
         col 108, cor_pr->cor_rec[x].correction_reason
        ENDIF
        row + 1
       ENDIF
      ENDIF
    ENDFOR
    IF (row > 56)
     BREAK
    ENDIF
    IF (d_flg="BP")
     first_time = "Y", new_line = "N"
     FOR (x = 1 TO cor_idx)
      IF (first_time="Y")
       first_time = "N", col 1, captions->supplier_prefix,
       col 27, current_supplier_prefix
      ENDIF
      ,
      IF ((cor_pr->cor_rec[x].supplier_prefix_chg_ind=1))
       IF (new_line="N")
        new_line = "Y"
       ELSE
        row + 1
        IF (row > 56)
         BREAK
        ENDIF
       ENDIF
       IF (size(trim(cor_pr->cor_rec[x].supplier_prefix))=0)
        col 55, captions->no_data
       ELSE
        col 55, cor_pr->cor_rec[x].supplier_prefix"#####"
       ENDIF
       updt_dt_tm = cnvtdatetime(cor_pr->cor_rec[x].updt_dt_tm), col 86, updt_dt_tm
       "@DATECONDENSED;;d",
       col 94, updt_dt_tm"@TIMENOSECONDS;;M", col 100,
       cor_pr->cor_rec[x].username"######", col 108, cor_pr->cor_rec[x].correction_reason
      ENDIF
     ENDFOR
     row + 1
     IF (row > 56)
      BREAK
     ENDIF
    ENDIF
    first_time = "Y", new_line = "N"
    FOR (x = 1 TO cor_idx)
     IF (first_time="Y")
      first_time = "N"
      IF (pr.alternate_nbr != null)
       col 1, captions->alternate_number, col 27,
       pr.alternate_nbr, row + 1
      ENDIF
     ENDIF
     ,
     IF ((cor_pr->cor_rec[x].alternate_nbr_chg_ind=1))
      IF (new_line="N")
       new_line = "Y"
      ELSE
       row + 1
       IF (row > 56)
        BREAK
       ENDIF
      ENDIF
      IF (size(trim(cor_pr->cor_rec[x].alternate_nbr))=0)
       col 55, captions->no_data
      ELSE
       col 55, cor_pr->cor_rec[x].alternate_nbr"####################"
      ENDIF
      updt_dt_tm = cnvtdatetime(cor_pr->cor_rec[x].updt_dt_tm), col 86, updt_dt_tm"@DATECONDENSED;;d",
      col 94, updt_dt_tm"@TIMENOSECONDS;;M", col 100,
      cor_pr->cor_rec[x].username"######", col 108, cor_pr->cor_rec[x].correction_reason
     ENDIF
    ENDFOR
    IF (row > 56)
     BREAK
    ENDIF
    first_time = "Y", new_line = "N"
    FOR (x = 1 TO cor_idx)
     IF (first_time="Y")
      first_time = "N", col 1, captions->product_class,
      col 27, pr_product_class_disp
     ENDIF
     ,
     IF (size(trim(cor_pr->cor_rec[x].product_class)) > 0)
      IF (new_line="N")
       new_line = "Y"
      ELSE
       row + 1
       IF (row > 56)
        BREAK
       ENDIF
      ENDIF
      col 55, cor_pr->cor_rec[x].product_class"#########################", updt_dt_tm = cnvtdatetime(
       cor_pr->cor_rec[x].updt_dt_tm),
      col 86, updt_dt_tm"@DATECONDENSED;;d", col 94,
      updt_dt_tm"@TIMENOSECONDS;;M", col 100, cor_pr->cor_rec[x].username"######",
      col 108, cor_pr->cor_rec[x].correction_reason
     ENDIF
    ENDFOR
    row + 1
    IF (row > 56)
     BREAK
    ENDIF
    first_time = "Y", new_line = "N"
    FOR (x = 1 TO cor_idx)
     IF (first_time="Y")
      first_time = "N", col 1, captions->product_category,
      col 27, pr_product_cat_disp
     ENDIF
     ,
     IF (size(trim(cor_pr->cor_rec[x].product_cat)) > 0)
      IF (new_line="N")
       new_line = "Y"
      ELSE
       row + 1
       IF (row > 56)
        BREAK
       ENDIF
      ENDIF
      col 55, cor_pr->cor_rec[x].product_cat"#########################", updt_dt_tm = cnvtdatetime(
       cor_pr->cor_rec[x].updt_dt_tm),
      col 86, updt_dt_tm"@DATECONDENSED;;d", col 94,
      updt_dt_tm"@TIMENOSECONDS;;M", col 100, cor_pr->cor_rec[x].username"######",
      col 108, cor_pr->cor_rec[x].correction_reason
     ENDIF
    ENDFOR
    row + 1
    IF (row > 56)
     BREAK
    ENDIF
    first_time = "Y", new_line = "N"
    FOR (x = 1 TO cor_idx)
     IF (first_time="Y")
      first_time = "N", col 1, captions->product_type,
      col 27, pr_product_disp
     ENDIF
     ,
     IF (size(trim(cor_pr->cor_rec[x].product_type)) > 0)
      IF (new_line="N")
       new_line = "Y"
      ELSE
       row + 1
       IF (row > 56)
        BREAK
       ENDIF
      ENDIF
      col 55, cor_pr->cor_rec[x].product_type"#########################", updt_dt_tm = cnvtdatetime(
       cor_pr->cor_rec[x].updt_dt_tm),
      col 86, updt_dt_tm"@DATECONDENSED;;d", col 94,
      updt_dt_tm"@TIMENOSECONDS;;M", col 100, cor_pr->cor_rec[x].username"######",
      col 108, cor_pr->cor_rec[x].correction_reason
     ENDIF
    ENDFOR
    row + 1
    IF (row > 56)
     BREAK
    ENDIF
    first_time = "Y", new_line = "N"
    FOR (x = 1 TO cor_idx)
     IF (first_time="Y")
      first_time = "N", col 1, captions->product_type_bc
      IF (size(trim(pr.product_type_barcode)) < 1)
       col 27, captions->no_data
      ELSE
       col 27, pr.product_type_barcode"#########################"
      ENDIF
     ENDIF
     ,
     IF ((cor_pr->cor_rec[x].product_type_bc_chg_ind > 0))
      IF (new_line="N")
       new_line = "Y"
      ELSE
       row + 1
       IF (row > 56)
        BREAK
       ENDIF
      ENDIF
      IF (size(trim(cor_pr->cor_rec[x].product_type_bc)) < 1)
       col 55, captions->no_data
      ELSE
       col 55, cor_pr->cor_rec[x].product_type_bc"#########################"
      ENDIF
      updt_dt_tm = cnvtdatetime(cor_pr->cor_rec[x].updt_dt_tm), col 86, updt_dt_tm"@DATECONDENSED;;d",
      col 94, updt_dt_tm"@TIMENOSECONDS;;M", col 100,
      cor_pr->cor_rec[x].username"######", col 108, cor_pr->cor_rec[x].correction_reason
     ENDIF
    ENDFOR
    row + 1
    IF (row > 56)
     BREAK
    ENDIF
    first_time = "Y", new_line = "N"
    FOR (x = 1 TO cor_idx)
     IF (first_time="Y")
      first_time = "N", col 1, captions->shipping_condition,
      col 27, pr_orig_ship_cond_disp
     ENDIF
     ,
     IF (size(trim(cor_pr->cor_rec[x].ship_cond)) > 0)
      IF (new_line="N")
       new_line = "Y"
      ELSE
       row + 1
       IF (row > 56)
        BREAK
       ENDIF
      ENDIF
      col 55, cor_pr->cor_rec[x].ship_cond"#########################", updt_dt_tm = cnvtdatetime(
       cor_pr->cor_rec[x].updt_dt_tm),
      col 86, updt_dt_tm"@DATECONDENSED;;d", col 94,
      updt_dt_tm"@TIMENOSECONDS;;M", col 100, cor_pr->cor_rec[x].username"######",
      col 108, cor_pr->cor_rec[x].correction_reason
     ENDIF
    ENDFOR
    row + 1
    IF (row > 56)
     BREAK
    ENDIF
    first_time = "Y", new_line = "N"
    FOR (x = 1 TO cor_idx)
     IF (first_time="Y")
      first_time = "N", col 1, captions->visual_inspection,
      col 27, pr_orig_vis_insp_disp
     ENDIF
     ,
     IF (size(trim(cor_pr->cor_rec[x].vis_insp)) > 0)
      IF (new_line="N")
       new_line = "Y"
      ELSE
       row + 1
       IF (row > 56)
        BREAK
       ENDIF
      ENDIF
      col 55, cor_pr->cor_rec[x].vis_insp"#########################", updt_dt_tm = cnvtdatetime(
       cor_pr->cor_rec[x].updt_dt_tm),
      col 86, updt_dt_tm"@DATECONDENSED;;d", col 94,
      updt_dt_tm"@TIMENOSECONDS;;M", col 100, cor_pr->cor_rec[x].username"######",
      col 108, cor_pr->cor_rec[x].correction_reason
     ENDIF
    ENDFOR
    row + 1
    IF (row > 56)
     BREAK
    ENDIF
    first_time = "Y", new_line = "N"
    FOR (x = 1 TO cor_idx)
     IF (first_time="Y")
      first_time = "N", col 1, captions->supplier_name,
      col 27, og1.org_name
     ENDIF
     ,
     IF (size(trim(cor_pr->cor_rec[x].org_name)) > 0)
      IF (new_line="N")
       new_line = "Y"
      ELSE
       row + 1
       IF (row > 56)
        BREAK
       ENDIF
      ENDIF
      col 55, cor_pr->cor_rec[x].org_name"#########################", updt_dt_tm = cnvtdatetime(
       cor_pr->cor_rec[x].updt_dt_tm),
      col 86, updt_dt_tm"@DATECONDENSED;;d", col 94,
      updt_dt_tm"@TIMENOSECONDS;;M", col 100, cor_pr->cor_rec[x].username"######",
      col 108, cor_pr->cor_rec[x].correction_reason
     ENDIF
    ENDFOR
    row + 1
    IF (row > 56)
     BREAK
    ENDIF
    first_time = "Y", new_line = "N"
    FOR (x = 1 TO cor_idx)
     IF (first_time="Y")
      first_time = "N", col 1, captions->drawn_dt_tm
      IF (d_flg="BP")
       drawn_dt_tm = cnvtdatetime(bp.drawn_dt_tm)
       IF (drawn_dt_tm > cnvtdatetime(" "))
        col 27, drawn_dt_tm"@DATECONDENSED;;d", col 35,
        drawn_dt_tm"@TIMENOSECONDS;;M"
       ENDIF
      ELSE
       col 27, captions->none
      ENDIF
     ENDIF
     ,
     IF ((cor_pr->cor_rec[x].drawn_dt_tm_chg_ind=1))
      IF (new_line="N")
       new_line = "Y"
      ELSE
       row + 1
       IF (row > 56)
        BREAK
       ENDIF
      ENDIF
      drawn_dt_tm = cnvtdatetime(cor_pr->cor_rec[x].drawn_dt_tm), col 55, drawn_dt_tm
      "@DATECONDENSED;;d",
      col 63, drawn_dt_tm"@TIMENOSECONDS;;M", updt_dt_tm = cnvtdatetime(cor_pr->cor_rec[x].updt_dt_tm
       ),
      col 86, updt_dt_tm"@DATECONDENSED;;d", col 94,
      updt_dt_tm"@TIMENOSECONDS;;M", col 100, cor_pr->cor_rec[x].username"######",
      col 108, cor_pr->cor_rec[x].correction_reason
     ENDIF
    ENDFOR
    row + 1
    IF (row > 56)
     BREAK
    ENDIF
    first_time = "Y", new_line = "N"
    FOR (x = 1 TO cor_idx)
     IF (first_time="Y")
      first_time = "N", col 1, captions->received_dt_tm,
      recv_dt_tm = cnvtdatetime(pr.recv_dt_tm)
      IF (recv_dt_tm > cnvtdatetime(" "))
       col 27, recv_dt_tm"@DATECONDENSED;;d", col 35,
       recv_dt_tm"@TIMENOSECONDS;;M"
      ENDIF
     ENDIF
     ,
     IF ((cor_pr->cor_rec[x].recv_dt_tm_chg_ind=1))
      IF (new_line="N")
       new_line = "Y"
      ELSE
       row + 1
       IF (row > 56)
        BREAK
       ENDIF
      ENDIF
      recv_dt_tm = cnvtdatetime(cor_pr->cor_rec[x].recv_dt_tm), col 55, recv_dt_tm"@DATECONDENSED;;d",
      col 63, recv_dt_tm"@TIMENOSECONDS;;M", updt_dt_tm = cnvtdatetime(cor_pr->cor_rec[x].updt_dt_tm),
      col 86, updt_dt_tm"@DATECONDENSED;;d", col 94,
      updt_dt_tm"@TIMENOSECONDS;;M", col 100, cor_pr->cor_rec[x].username"######",
      col 108, cor_pr->cor_rec[x].correction_reason
     ENDIF
    ENDFOR
    row + 1
    IF (row > 56)
     BREAK
    ENDIF
    first_time = "Y", new_line = "N"
    FOR (x = 1 TO cor_idx)
     IF (first_time="Y")
      first_time = "N", col 1, captions->expiration_dt_tm,
      expire_dt_tm = cnvtdatetime(pr.cur_expire_dt_tm), col 27, expire_dt_tm"@DATECONDENSED;;d",
      col 35, expire_dt_tm"@TIMENOSECONDS;;M"
     ENDIF
     ,
     IF ((cor_pr->cor_rec[x].expire_dt_tm_chg_ind=1))
      IF (new_line="N")
       new_line = "Y"
      ELSE
       row + 1
       IF (row > 56)
        BREAK
       ENDIF
      ENDIF
      expire_dt_tm = cnvtdatetime(cor_pr->cor_rec[x].expire_dt_tm), col 55, expire_dt_tm
      "@DATECONDENSED;;d",
      col 63, expire_dt_tm"@TIMENOSECONDS;;M", updt_dt_tm = cnvtdatetime(cor_pr->cor_rec[x].
       updt_dt_tm),
      col 86, updt_dt_tm"@DATECONDENSED;;d", col 94,
      updt_dt_tm"@TIMENOSECONDS;;M", col 100, cor_pr->cor_rec[x].username"######",
      col 108, cor_pr->cor_rec[x].correction_reason
     ENDIF
    ENDFOR
    row + 1
    IF (row > 56)
     BREAK
    ENDIF
    IF (d_flg="BP")
     first_time = "Y", new_line = "N"
     FOR (x = 1 TO cor_idx)
      IF (first_time="Y")
       first_time = "N"
       IF (d_flg="BP")
        col 1, captions->abo, col 27,
        bp_abo_disp"#################"
       ENDIF
      ENDIF
      ,
      IF ((cor_pr->cor_rec[x].abo_cd_chg_ind=1))
       IF (new_line="N")
        new_line = "Y"
       ELSE
        row + 1
        IF (row > 56)
         BREAK
        ENDIF
       ENDIF
       col 55, cor_pr->cor_rec[x].abo_disp"#####################", updt_dt_tm = cnvtdatetime(cor_pr->
        cor_rec[x].updt_dt_tm),
       col 86, updt_dt_tm"@DATECONDENSED;;d", col 94,
       updt_dt_tm"@TIMENOSECONDS;;M", col 100, cor_pr->cor_rec[x].username"######",
       col 108, cor_pr->cor_rec[x].correction_reason
      ENDIF
     ENDFOR
     row + 1
     IF (row > 56)
      BREAK
     ENDIF
     first_time = "Y", new_line = "N"
     FOR (x = 1 TO cor_idx)
      IF (first_time="Y")
       first_time = "N"
       IF (d_flg="BP")
        col 1, captions->rh, col 27,
        bp_rh_disp"##################"
       ENDIF
      ENDIF
      ,
      IF ((cor_pr->cor_rec[x].rh_cd_chg_ind=1))
       IF (new_line="N")
        new_line = "Y"
       ELSE
        row + 1
        IF (row > 56)
         BREAK
        ENDIF
       ENDIF
       col 55, cor_pr->cor_rec[x].rh_disp"#####################", updt_dt_tm = cnvtdatetime(cor_pr->
        cor_rec[x].updt_dt_tm),
       col 86, updt_dt_tm"@DATECONDENSED;;d", col 94,
       updt_dt_tm"@TIMENOSECONDS;;M", col 100, cor_pr->cor_rec[x].username"######",
       col 108, cor_pr->cor_rec[x].correction_reason
      ENDIF
     ENDFOR
     row + 1
     IF (row > 56)
      BREAK
     ENDIF
    ENDIF
    IF (d_flg="BP")
     first_time = "Y", new_line = "N"
     FOR (x = 1 TO cor_idx)
      IF (first_time="Y")
       first_time = "N", col 1, captions->intended_use,
       cur_intended_use = intended_use_definition(pr.intended_use_print_parm_txt), col 27,
       cur_intended_use
      ENDIF
      ,
      IF ((cor_pr->cor_rec[x].intended_use_chg_ind=1))
       IF (new_line="N")
        new_line = "Y"
       ELSE
        row + 1
        IF (row > 56)
         BREAK
        ENDIF
       ENDIF
       col 55, cor_pr->cor_rec[x].intended_use, updt_dt_tm = cnvtdatetime(cor_pr->cor_rec[x].
        updt_dt_tm),
       col 86, updt_dt_tm"@DATECONDENSED;;d", col 94,
       updt_dt_tm"@TIMENOSECONDS;;M", col 100, cor_pr->cor_rec[x].username"######",
       col 108, cor_pr->cor_rec[x].correction_reason
      ENDIF
     ENDFOR
     row + 1
     IF (row > 56)
      BREAK
     ENDIF
    ENDIF
    first_time = "Y", new_line = "N"
    FOR (x = 1 TO cor_idx)
     IF (first_time="Y")
      first_time = "N", col 1, captions->segment_number,
      col 27, current_segment_nbr
     ENDIF
     ,
     IF ((cor_pr->cor_rec[x].segment_nbr_chg_ind=1))
      IF (d_flg="BP")
       IF (new_line="N")
        new_line = "Y"
       ELSE
        row + 1
        IF (row > 56)
         BREAK
        ENDIF
       ENDIF
       IF (size(trim(cor_pr->cor_rec[x].segment_nbr))=0)
        col 55, captions->no_data
       ELSE
        col 55, cor_pr->cor_rec[x].segment_nbr
       ENDIF
       updt_dt_tm = cnvtdatetime(cor_pr->cor_rec[x].updt_dt_tm), col 86, updt_dt_tm
       "@DATECONDENSED;;d",
       col 94, updt_dt_tm"@TIMENOSECONDS;;M", col 100,
       cor_pr->cor_rec[x].username"######", col 108, cor_pr->cor_rec[x].correction_reason
      ENDIF
     ENDIF
    ENDFOR
    row + 1
    IF (row > 56)
     BREAK
    ENDIF
    first_time = "Y", new_line = "N"
    FOR (x = 1 TO cor_idx)
     IF (first_time="Y")
      first_time = "N", col 1, captions->volume,
      vol = trim(cnvtstring(current_volume,4,0,r)), col 27, vol
     ENDIF
     ,
     IF ((cor_pr->cor_rec[x].volume_chg_ind=1))
      IF (new_line="N")
       new_line = "Y"
      ELSE
       row + 1
       IF (row > 56)
        BREAK
       ENDIF
      ENDIF
      vol = trim(cnvtstring(cor_pr->cor_rec[x].volume,4,0,r)), col 55, vol,
      updt_dt_tm = cnvtdatetime(cor_pr->cor_rec[x].updt_dt_tm), col 86, updt_dt_tm"@DATECONDENSED;;d",
      col 94, updt_dt_tm"@TIMENOSECONDS;;M", col 100,
      cor_pr->cor_rec[x].username"######", col 108, cor_pr->cor_rec[x].correction_reason
     ENDIF
    ENDFOR
    row + 1
    IF (row > 56)
     BREAK
    ENDIF
    first_time = "Y", new_line = "N"
    FOR (x = 1 TO cor_idx)
     IF (first_time="Y")
      first_time = "N", col 1, captions->unit_of_measure,
      col 27, cur_unit_meas_disp
     ENDIF
     ,
     IF (size(trim(cor_pr->cor_rec[x].unit_of_measure)) > 0)
      IF (new_line="N")
       new_line = "Y"
      ELSE
       row + 1
       IF (row > 56)
        BREAK
       ENDIF
      ENDIF
      col 55, cor_pr->cor_rec[x].unit_of_measure, updt_dt_tm = cnvtdatetime(cor_pr->cor_rec[x].
       updt_dt_tm),
      col 86, updt_dt_tm"@DATECONDENSED;;d", col 94,
      updt_dt_tm"@TIMENOSECONDS;;M", col 100, cor_pr->cor_rec[x].username"######",
      col 108, cor_pr->cor_rec[x].correction_reason
     ENDIF
    ENDFOR
    row + 1
    IF (row > 56)
     BREAK
    ENDIF
    first_time = "Y", new_line = "N"
    FOR (x = 1 TO cor_idx)
     IF (first_time="Y")
      first_time = "N", col 1, captions->donation_type
      IF (size(trim(pr_donation_type_disp))=0)
       col 27, captions->no_data
      ELSE
       col 27, pr_donation_type_disp"###########################"
      ENDIF
     ENDIF
     ,
     IF ((cor_pr->cor_rec[x].donation_type_chg_ind=1))
      IF (new_line="N")
       new_line = "Y"
      ELSE
       row + 1
       IF (row > 56)
        BREAK
       ENDIF
      ENDIF
      IF (size(trim(cor_pr->cor_rec[x].donation_type_disp))=0)
       col 55, captions->no_data
      ELSE
       col 55, cor_pr->cor_rec[x].donation_type_disp"###########################"
      ENDIF
      updt_dt_tm = cnvtdatetime(cor_pr->cor_rec[x].updt_dt_tm), col 86, updt_dt_tm"@DATECONDENSED;;d",
      col 94, updt_dt_tm"@TIMENOSECONDS;;M", col 100,
      cor_pr->cor_rec[x].username"######", col 108, cor_pr->cor_rec[x].correction_reason
     ENDIF
    ENDFOR
    row + 1
    IF (row > 56)
     BREAK
    ENDIF
    first_time = "Y", new_line = "N"
    FOR (x = 1 TO cor_idx)
     IF (first_time="Y")
      first_time = "N", col 1, captions->disease
      IF (size(trim(pr_disease_disp))=0)
       col 27, captions->no_data
      ELSE
       col 27, pr_disease_disp"###########################"
      ENDIF
     ENDIF
     ,
     IF ((cor_pr->cor_rec[x].disease_chg_ind=1))
      IF (new_line="N")
       new_line = "Y"
      ELSE
       row + 1
       IF (row > 56)
        BREAK
       ENDIF
      ENDIF
      IF (size(trim(cor_pr->cor_rec[x].disease_disp))=0)
       col 55, captions->no_data
      ELSE
       col 55, cor_pr->cor_rec[x].disease_disp"###########################"
      ENDIF
      updt_dt_tm = cnvtdatetime(cor_pr->cor_rec[x].updt_dt_tm), col 86, updt_dt_tm"@DATECONDENSED;;d",
      col 94, updt_dt_tm"@TIMENOSECONDS;;M", col 100,
      cor_pr->cor_rec[x].username"######", col 108, cor_pr->cor_rec[x].correction_reason
     ENDIF
    ENDFOR
    row + 1
    IF (row > 56)
     BREAK
    ENDIF
    IF (size(products_rec->products[d_p.seq].autodir_states,5) > 0
     AND (products_rec->products[d_p.seq].displayed_in_report=0))
     products_rec->products[d_p.seq].displayed_in_report = 1
     FOR (x = 1 TO size(products_rec->products[d_p.seq].autodir_states,5))
       col 1, captions->patient_name
       FOR (p_idx = 1 TO size(products_rec->products[d_p.seq].autodir_states[x].person_list,5))
         col 27, products_rec->products[d_p.seq].autodir_states[x].person_list[p_idx].
         ad_disp_name_curr"###########################"
         IF (size(trim(products_rec->products[d_p.seq].autodir_states[x].person_list[p_idx].
           ad_disp_name)) > 0)
          col 55, products_rec->products[d_p.seq].autodir_states[x].person_list[p_idx].ad_disp_name
          "###########################", updt_dt_tm = cnvtdatetime(products_rec->products[d_p.seq].
           autodir_states[x].person_list[p_idx].updt_dt_tm)
          IF (updt_dt_tm > 0)
           col 86, updt_dt_tm"@DATECONDENSED;;d", col 94,
           updt_dt_tm"@TIMENOSECONDS;;M"
          ENDIF
          col 100, products_rec->products[d_p.seq].autodir_states[x].person_list[p_idx].username
          "######", col 108,
          products_rec->products[d_p.seq].autodir_states[x].person_list[p_idx].correction_reason
         ENDIF
         row + 1
         IF (row > 56)
          BREAK
         ENDIF
       ENDFOR
       col 3, captions->patient_id
       FOR (p_idx = 1 TO size(products_rec->products[d_p.seq].autodir_states[x].person_list,5))
         col 27, products_rec->products[d_p.seq].autodir_states[x].person_list[p_idx].
         ad_disp_alias_curr"#####################"
         IF (size(trim(products_rec->products[d_p.seq].autodir_states[x].person_list[p_idx].
           ad_disp_alias)) > 0)
          col 55, products_rec->products[d_p.seq].autodir_states[x].person_list[p_idx].ad_disp_alias
          "#####################", updt_dt_tm = cnvtdatetime(products_rec->products[d_p.seq].
           autodir_states[x].person_list[p_idx].updt_dt_tm)
          IF (updt_dt_tm > 0)
           col 86, updt_dt_tm"@DATECONDENSED;;d", col 94,
           updt_dt_tm"@TIMENOSECONDS;;M"
          ENDIF
          col 100, products_rec->products[d_p.seq].autodir_states[x].person_list[p_idx].username
          "######", col 108,
          products_rec->products[d_p.seq].autodir_states[x].person_list[p_idx].correction_reason
         ENDIF
         row + 1
         IF (row > 56)
          BREAK
         ENDIF
       ENDFOR
       col 3, captions->usage_dt_tm
       FOR (p_idx = 1 TO size(products_rec->products[d_p.seq].autodir_states[x].expected_list,5))
         IF ((products_rec->products[d_p.seq].autodir_states[x].expected_list[p_idx].
         expected_usage_dt_tm_curr > 0))
          col 27, products_rec->products[d_p.seq].autodir_states[x].expected_list[p_idx].
          expected_usage_dt_tm_curr"@DATECONDENSED;;d", col 35,
          products_rec->products[d_p.seq].autodir_states[x].expected_list[p_idx].
          expected_usage_dt_tm_curr"@TIMENOSECONDS;;M"
         ENDIF
         IF ((products_rec->products[d_p.seq].autodir_states[x].expected_list[p_idx].
         expected_usage_dt_tm > 0))
          expected_usage_dt_tm = cnvtdatetime(products_rec->products[d_p.seq].autodir_states[x].
           expected_list[p_idx].expected_usage_dt_tm), col 55, expected_usage_dt_tm
          "@DATECONDENSED;;d",
          col 63, expected_usage_dt_tm"@TIMENOSECONDS;;M", updt_dt_tm = cnvtdatetime(products_rec->
           products[d_p.seq].autodir_states[x].expected_list[p_idx].expected_updt_dt_tm)
          IF (updt_dt_tm > 0)
           col 86, updt_dt_tm"@DATECONDENSED;;d", col 94,
           updt_dt_tm"@TIMENOSECONDS;;M"
          ENDIF
          col 100, products_rec->products[d_p.seq].autodir_states[x].expected_list[p_idx].
          expected_username"######", col 108,
          products_rec->products[d_p.seq].autodir_states[x].expected_list[p_idx].
          expected_correction_reason
         ENDIF
         row + 1
         IF (row > 56)
          BREAK
         ENDIF
       ENDFOR
       col 3, captions->donated_by_relative
       FOR (p_idx = 1 TO size(products_rec->products[d_p.seq].autodir_states[x].donated_list,5))
         IF ((products_rec->products[d_p.seq].autodir_states[x].donated_list[p_idx].
         donated_by_relative_curr=1))
          col 27, captions->yes
         ELSEIF ((products_rec->products[d_p.seq].autodir_states[x].donated_list[p_idx].
         donated_by_relative_curr=0))
          col 27, captions->no
         ENDIF
         IF ((products_rec->products[d_p.seq].autodir_states[x].donated_list[p_idx].
         donated_by_relative > - (1))
          AND (products_rec->products[d_p.seq].autodir_states[x].donated_list[p_idx].
         donated_by_relative != products_rec->products[d_p.seq].autodir_states[x].donated_list[p_idx]
         .donated_by_relative_curr))
          IF ((products_rec->products[d_p.seq].autodir_states[x].donated_list[p_idx].
          donated_by_relative=1))
           col 55, captions->yes
          ELSEIF ((products_rec->products[d_p.seq].autodir_states[x].donated_list[p_idx].
          donated_by_relative=0))
           col 55, captions->no
          ENDIF
          updt_dt_tm = cnvtdatetime(products_rec->products[d_p.seq].autodir_states[x].donated_list[
           p_idx].donated_updt_dt_tm)
          IF (updt_dt_tm > 0)
           col 86, updt_dt_tm"@DATECONDENSED;;d", col 94,
           updt_dt_tm"@TIMENOSECONDS;;M"
          ENDIF
          col 100, products_rec->products[d_p.seq].autodir_states[x].donated_list[p_idx].
          donated_username"######", col 108,
          products_rec->products[d_p.seq].autodir_states[x].donated_list[p_idx].
          donated_correction_reason
         ENDIF
         row + 1
         IF (row > 56)
          BREAK
         ENDIF
       ENDFOR
     ENDFOR
    ENDIF
    first_time = "Y", new_line = "N"
    FOR (x = 1 TO cor_idx)
     IF (first_time="Y")
      first_time = "N", col 1, captions->owner_area,
      col 27, pr_owner_area_disp
     ENDIF
     ,
     IF (size(trim(cor_pr->cor_rec[x].owner_area_disp)) > 0)
      IF (new_line="N")
       new_line = "Y"
      ELSE
       row + 1
       IF (row > 56)
        BREAK
       ENDIF
      ENDIF
      col 55, cor_pr->cor_rec[x].owner_area_disp, updt_dt_tm = cnvtdatetime(cor_pr->cor_rec[x].
       updt_dt_tm),
      col 86, updt_dt_tm"@DATECONDENSED;;d", col 94,
      updt_dt_tm"@TIMENOSECONDS;;M", col 100, cor_pr->cor_rec[x].username"######",
      col 108, cor_pr->cor_rec[x].correction_reason
     ENDIF
    ENDFOR
    row + 1
    IF (row > 56)
     BREAK
    ENDIF
    first_time = "Y", new_line = "N"
    FOR (x = 1 TO cor_idx)
     IF (first_time="Y")
      first_time = "N", col 1, captions->inventory_area,
      col 27, pr_inv_area_disp
     ENDIF
     ,
     IF (size(trim(cor_pr->cor_rec[x].inv_area_disp)) > 0)
      IF (new_line="N")
       new_line = "Y"
      ELSE
       row + 1
       IF (row > 56)
        BREAK
       ENDIF
      ENDIF
      col 55, cor_pr->cor_rec[x].inv_area_disp, updt_dt_tm = cnvtdatetime(cor_pr->cor_rec[x].
       updt_dt_tm),
      col 86, updt_dt_tm"@DATECONDENSED;;d", col 94,
      updt_dt_tm"@TIMENOSECONDS;;M", col 100, cor_pr->cor_rec[x].username"######",
      col 108, cor_pr->cor_rec[x].correction_reason
     ENDIF
    ENDFOR
    row + 1
    IF (row > 56)
     BREAK
    ENDIF
    first_time = "Y", new_line = "N"
    FOR (x = 1 TO cor_idx)
     IF (first_time="Y")
      first_time = "N", col 1, captions->manufacturer_name
      IF (d_flg="DE")
       col 27, o_de.org_name
      ELSE
       col 27, "                         "
      ENDIF
     ENDIF
     ,
     IF (size(trim(cor_pr->cor_rec[x].manu_name)) > 0)
      IF (d_flg="DE")
       IF (new_line="N")
        new_line = "Y"
       ELSE
        row + 1
        IF (row > 56)
         BREAK
        ENDIF
       ENDIF
       col 55, cor_pr->cor_rec[x].manu_name, updt_dt_tm = cnvtdatetime(cor_pr->cor_rec[x].updt_dt_tm),
       col 86, updt_dt_tm"@DATECONDENSED;;d", col 94,
       updt_dt_tm"@TIMENOSECONDS;;M", col 100, cor_pr->cor_rec[x].username"######",
       col 108, cor_pr->cor_rec[x].correction_reason
      ENDIF
     ENDIF
    ENDFOR
    row + 1
    IF (row > 56)
     BREAK
    ENDIF
    first_time = "Y", new_line = "N"
    FOR (x = 1 TO cor_idx)
     IF (first_time="Y")
      first_time = "N", col 1, captions->international_units
      IF (d_flg="DE")
       IF (de.cur_intl_units > 0)
        col 27, de.cur_intl_units
       ENDIF
      ELSE
       col 27, "                         "
      ENDIF
     ENDIF
     ,
     IF ((cor_pr->cor_rec[x].cur_intl_units_chg_ind=1))
      IF (d_flg="DE")
       IF (new_line="N")
        new_line = "Y"
       ELSE
        row + 1
        IF (row > 56)
         BREAK
        ENDIF
       ENDIF
       col 55, cor_pr->cor_rec[x].cur_intl_units, updt_dt_tm = cnvtdatetime(cor_pr->cor_rec[x].
        updt_dt_tm),
       col 86, updt_dt_tm"@DATECONDENSED;;d", col 94,
       updt_dt_tm"@TIMENOSECONDS;;M", col 100, cor_pr->cor_rec[x].username"######",
       col 108, cor_pr->cor_rec[x].correction_reason
      ENDIF
     ENDIF
    ENDFOR
    row + 1
    IF (row > 56)
     BREAK
    ENDIF
    first_time = "Y", new_line = "N"
    FOR (x = 1 TO cor_idx)
     IF (first_time="Y")
      first_time = "N", col 1, captions->quantity
      IF (d_flg="DE")
       col 27, de.cur_avail_qty
      ELSE
       col 27, "                         "
      ENDIF
     ENDIF
     ,
     IF ((cor_pr->cor_rec[x].cur_avail_qty_chg_ind=1))
      IF (d_flg="DE")
       IF (new_line="N")
        new_line = "Y"
       ELSE
        row + 1
        IF (row > 56)
         BREAK
        ENDIF
       ENDIF
       col 55, cor_pr->cor_rec[x].cur_avail_qty, updt_dt_tm = cnvtdatetime(cor_pr->cor_rec[x].
        updt_dt_tm),
       col 86, updt_dt_tm"@DATECONDENSED;;d", col 94,
       updt_dt_tm"@TIMENOSECONDS;;M", col 100, cor_pr->cor_rec[x].username"######",
       col 108, cor_pr->cor_rec[x].correction_reason
      ENDIF
     ENDIF
    ENDFOR
    row + 1
    IF (row > 56)
     BREAK
    ENDIF
    first_time = "Y", new_line = "N"
    FOR (x = 1 TO cor_idx)
     IF (first_time="Y")
      first_time = "N", col 1, captions->units_per_vial
      IF (d_flg="DE")
       IF (de.units_per_vial > 0)
        col 27, de.units_per_vial
       ENDIF
      ELSE
       col 27, "                         "
      ENDIF
     ENDIF
     ,
     IF ((cor_pr->cor_rec[x].units_per_vial_chg_ind=1))
      IF (d_flg="DE")
       IF (new_line="N")
        new_line = "Y"
       ELSE
        row + 1
        IF (row > 56)
         BREAK
        ENDIF
       ENDIF
       col 55, cor_pr->cor_rec[x].units_per_vial, updt_dt_tm = cnvtdatetime(cor_pr->cor_rec[x].
        updt_dt_tm),
       col 86, updt_dt_tm"@DATECONDENSED;;d", col 94,
       updt_dt_tm"@TIMENOSECONDS;;M", col 100, cor_pr->cor_rec[x].username"######",
       col 108, cor_pr->cor_rec[x].correction_reason
      ENDIF
     ENDIF
    ENDFOR
    row + 1
    IF (row > 56)
     BREAK
    ENDIF
    first_time = "Y", new_line = "N", x = 0
    FOR (x = 1 TO cor_idx)
      b_str_len = 0
      IF (first_time="Y")
       first_time = "N", col 1, captions->correction_notes
      ENDIF
      b_cnt = 1, start_col_cnt = 26, col_cnt = 26,
      pos_left = 54, max_width = 54
      IF ((cor_pr->cor_rec[x].correction_note_chg_ind=1))
       IF (new_line="N")
        new_line = "Y"
       ELSE
        row + 1
        IF (row > 56)
         BREAK
        ENDIF
       ENDIF
       updt_dt_tm = cnvtdatetime(cor_pr->cor_rec[x].updt_dt_tm), col 86, updt_dt_tm
       "@DATECONDENSED;;d",
       col 94, updt_dt_tm"@TIMENOSECONDS;;M", col 100,
       cor_pr->cor_rec[x].username"######", col 108, cor_pr->cor_rec[x].correction_reason,
       b_strg = cor_pr->cor_rec[x].correction_note, b_str_len = size(trim(b_strg))
       IF (b_str_len > 0)
        WHILE (b_cnt <= b_str_len)
          IF (substring(b_cnt,2,b_strg)=concat(char(13),char(10)))
           b_cnt += 2, col_cnt = start_col_cnt, pos_left = max_width
          ELSE
           text->s_char = substring(b_cnt,1,b_strg)
           IF ((text->s_char=" "))
            IF ((col_cnt > (start_col_cnt+ max_width)))
             b_cnt += 1, row + 1
             IF (row > 55)
              BREAK
             ENDIF
             col_cnt = start_col_cnt, pos_left = max_width
            ELSE
             b_cnt += 1, col col_cnt, text->s_char,
             col_cnt += 1, pos_left -= 1
            ENDIF
           ELSE
            cont_flg = "Y", word_len = 0, inc_flg = "N",
            b_cnt_sub = (b_cnt+ 1)
            WHILE (cont_flg="Y")
              IF (((substring(b_cnt_sub,1,b_strg)=" ") OR (substring(b_cnt_sub,2,b_strg)=concat(char(
                13),char(10)))) )
               cont_flg = "N"
              ELSE
               word_len += 1
               IF (word_len > pos_left)
                inc_flg = "Y", cont_flg = "N"
               ELSE
                b_cnt_sub += 1
               ENDIF
              ENDIF
            ENDWHILE
            IF (inc_flg="Y")
             b_cnt += 1, row + 1
             IF (row > 55)
              BREAK
             ENDIF
             col_cnt = start_col_cnt, pos_left = max_width, col col_cnt,
             text->s_char, col_cnt += 1, pos_left -= 1
            ELSE
             b_cnt += 1, col col_cnt, text->s_char,
             col_cnt += 1, pos_left -= 1
            ENDIF
           ENDIF
          ENDIF
        ENDWHILE
       ENDIF
      ENDIF
    ENDFOR
    row + 1
    IF (row > 56)
     BREAK
    ENDIF
    stat = alterlist(cor_pr->cor_rec,0)
   ENDIF
   ad_disp_name = fillstring(27," "), ad_disp_alias = fillstring(20," "), ad_expected_usage_dt_tm =
   cnvtdatetime(""),
   current_aborh_disp = fillstring(40," "), current_volume = 0, current_supplier_prefix = fillstring(
    5," "),
   current_segment_nbr = fillstring(25," ")
  FOOT PAGE
   row 57, col 1,
   "------------------------------------------------------------------------------------------------------------------------------"
,
   row + 1, col 1, captions->inc_report_id,
   col 58, captions->inc_page, col 64,
   curpage"###", col 109, captions->inc_printed,
   col 119, curdate"@DATECONDENSED;;d", row + 1
  FOOT REPORT
   row 60, col 51, captions->end_of_report
  WITH nocounter, maxrow = 61, outerjoin(d_p),
   outerjoin(d_r), outerjoin(d3), dontcare(og1),
   dontcare(r), outerjoin(d6), dontcare(og),
   dontcare(og_de), outerjoin(d7), outerjoin(d12),
   outerjoin(d_o_de), dontcare(cp_per), dontcare(cp_ad),
   dontcare(cp_pe_per), dontcare(cp_pe_ea), nullreport,
   compress, nolandscape
 ;end select
 IF (((datafoundflag=true) OR ((request->null_ind=1))) )
  SET rpt_cnt += 1
  SET stat = alterlist(reply->rpt_list,rpt_cnt)
  SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
  SET datafoundflag = false
 ENDIF
#exit_script
END GO
