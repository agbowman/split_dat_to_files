CREATE PROGRAM bbt_rpt_recon_prod_cor:dba
 RECORD pool_comp(
   1 cmp_list[*]
     2 product_id = f8
     2 product_nbr = c20
     2 product_sub_nbr = c5
     2 product_disp = c40
     2 supplier_prefix = c5
     2 abo_disp = c40
     2 rh_disp = c40
     2 exp_dt_tm = di8
     2 correction_flag = i2
     2 current_ind = i2
 )
 RECORD special_test(
   1 spec_tst[*]
     2 special_testing_cd = f8
     2 special_testing_disp = vc
     2 status_flag = i2
   1 spec_tst_print_list[*]
     2 special_test_line = vc
 )
 SET sub_get_location_name = fillstring(25," ")
 SET sub_get_location_address1 = fillstring(100," ")
 SET sub_get_location_address2 = fillstring(100," ")
 SET sub_get_location_address3 = fillstring(100," ")
 SET sub_get_location_address4 = fillstring(100," ")
 SET sub_get_location_citystatezip = fillstring(100," ")
 SET sub_get_location_country = fillstring(100," ")
 IF ((request->address_location_cd != 0))
  SET addr_type_cd = 0.0
  SET code_cnt = 1
  SET stat = uar_get_meaning_by_codeset(212,"BUSINESS",code_cnt,addr_type_cd)
  IF (addr_type_cd=0.0)
   SET sub_get_location_name = "<<INFORMATION NOT FOUND>>"
  ELSE
   SELECT INTO "nl:"
    a.street_addr, a.street_addr2, a.street_addr3,
    a.street_addr4, a.city, a.state,
    a.zipcode, a.country, l.location_cd
    FROM address a
    WHERE a.active_ind=1
     AND a.address_type_cd=addr_type_cd
     AND a.parent_entity_name="LOCATION"
     AND (a.parent_entity_id=request->address_location_cd)
    DETAIL
     sub_get_location_name = uar_get_code_display(request->address_location_cd),
     sub_get_location_address1 = a.street_addr, sub_get_location_address2 = a.street_addr2,
     sub_get_location_address3 = a.street_addr3, sub_get_location_address4 = a.street_addr4,
     sub_get_location_citystatezip = concat(trim(a.city),", ",trim(a.state),"  ",trim(a.zipcode)),
     sub_get_location_country = a.country
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET sub_get_location_name = "<<INFORMATION NOT FOUND>>"
   ENDIF
  ENDIF
 ELSE
  SET sub_get_location_name = "<<INFORMATION NOT FOUND>>"
 ENDIF
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
   1 product_no = vc
   1 product_sub_no = vc
   1 supplier_prefix = vc
   1 product_type = vc
   1 volume = vc
   1 unit_of_measure = vc
   1 expire_dt_tm = vc
   1 abo = vc
   1 rh = vc
   1 currently = vc
   1 added = vc
   1 component_products = vc
   1 in_recon = vc
   1 removed = vc
   1 aborh = vc
   1 expires = vc
   1 yes = vc
   1 corrected = vc
   1 dt_tm = vc
   1 tech_id = vc
   1 reason = vc
   1 note = vc
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
   1 no_data = vc
   1 alternate_number = vc
   1 product_category = vc
   1 supplier_name = vc
   1 patient = vc
   1 intended_use = vc
   1 attribute_antigen = vc
   1 product_type_bc = vc
 )
 SET captions->correction_type = uar_i18ngetmessage(i18nhandle,"correction_type","Correction Type: ")
 SET captions->demographic = uar_i18ngetmessage(i18nhandle,"demographic","Demographic")
 SET captions->current = uar_i18ngetmessage(i18nhandle,"current","Current")
 SET captions->previous = uar_i18ngetmessage(i18nhandle,"previous","Previous")
 SET captions->product_no = uar_i18ngetmessage(i18nhandle,"product_no","Product Number")
 SET captions->product_sub_no = uar_i18ngetmessage(i18nhandle,"product_sub_no","Product Sub Number")
 SET captions->supplier_prefix = uar_i18ngetmessage(i18nhandle,"supplier_prefix","Supplier Prefix")
 SET captions->product_type = uar_i18ngetmessage(i18nhandle,"product_type","Product Type")
 SET captions->volume = uar_i18ngetmessage(i18nhandle,"volume","Volume")
 SET captions->unit_of_measure = uar_i18ngetmessage(i18nhandle,"unit_of_measure","Unit of Measure")
 SET captions->supplier_name = uar_i18ngetmessage(i18nhandle,"supplier_name","Supplier Name")
 SET captions->expire_dt_tm = uar_i18ngetmessage(i18nhandle,"expire_dt_tm","Expiration Date/Time")
 SET captions->abo = uar_i18ngetmessage(i18nhandle,"abo","ABO")
 SET captions->rh = uar_i18ngetmessage(i18nhandle,"rh","Rh")
 SET captions->currently = uar_i18ngetmessage(i18nhandle,"currently","Currently")
 SET captions->component_products = uar_i18ngetmessage(i18nhandle,"component_products",
  "COMPONENT PRODUCTS:")
 SET captions->in_recon = uar_i18ngetmessage(i18nhandle,"in_recon","In Recon")
 SET captions->removed = uar_i18ngetmessage(i18nhandle,"removed","Removed")
 SET captions->aborh = uar_i18ngetmessage(i18nhandle,"aborh","ABO/Rh")
 SET captions->expires = uar_i18ngetmessage(i18nhandle,"expires","Expires")
 SET captions->yes = uar_i18ngetmessage(i18nhandle,"yes","Yes")
 SET captions->added = uar_i18ngetmessage(i18nhandle,"added","Added")
 SET captions->corrected = uar_i18ngetmessage(i18nhandle,"corrected","CORRECTED:")
 SET captions->dt_tm = uar_i18ngetmessage(i18nhandle,"dt_tm","Date/Time")
 SET captions->tech_id = uar_i18ngetmessage(i18nhandle,"tech_id","Tech ID")
 SET captions->reason = uar_i18ngetmessage(i18nhandle,"reason","Reason")
 SET captions->note = uar_i18ngetmessage(i18nhandle,"note","Note")
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
 SET captions->donation_type = uar_i18ngetmessage(i18nhandle,"donation_type","Donation Type")
 SET captions->disease = uar_i18ngetmessage(i18nhandle,"disease","Disease")
 SET captions->alternate_number = uar_i18ngetmessage(i18nhandle,"alternate_number","Alternate Number"
  )
 SET captions->product_category = uar_i18ngetmessage(i18nhandle,"product_category","Product Category"
  )
 SET captions->intended_use = uar_i18ngetmessage(i18nhandle,"intended_use","Intended Use")
 SET captions->patient = uar_i18ngetmessage(i18nhandle,"patient","Patient")
 SET captions->attribute_antigen = uar_i18ngetmessage(i18nhandle,"attribute_antigen",
  "Attribute/Antigen")
 SET captions->no_data = uar_i18ngetmessage(i18nhandle,"no_data","(none)")
 SET captions->auto_cross = uar_i18ngetmessage(i18nhandle,"auto_cross","Autologous Crossover")
 SET captions->auto_only = uar_i18ngetmessage(i18nhandle,"auto_only","Autologous Only")
 SET captions->auto_bio = uar_i18ngetmessage(i18nhandle,"auto_bio","Autologous Biohazardous")
 SET captions->dir_cross = uar_i18ngetmessage(i18nhandle,"dir_cross","Directed Crossover")
 SET captions->dir_only = uar_i18ngetmessage(i18nhandle,"dir_only","Directed Only")
 SET captions->dir_bio = uar_i18ngetmessage(i18nhandle,"dir_bio","Directed Biohazardous")
 SET captions->emer_only = uar_i18ngetmessage(i18nhandle,"emer_only","Emergency Only")
 SET captions->not_spec = uar_i18ngetmessage(i18nhandle,"not_spec","Not Specified")
 SET captions->product_type_bc = uar_i18ngetmessage(i18nhandle,"product_type_bc",
  "Product Type Barcode")
 DECLARE removed_flag = i2 WITH protect, constant(0)
 DECLARE added_flag = i2 WITH protect, constant(1)
 DECLARE current_flag = i2 WITH protect, constant(2)
 DECLARE spec_test_line_cnt = i2 WITH protect, noconstant(0)
 DECLARE special_test_cnt = i2 WITH protect, noconstant(0)
 DECLARE datafoundflag = i2 WITH protect, noconstant(false)
 SUBROUTINE (getspecialtestingdisplaylines(statusflag=i2) =i2)
   DECLARE i = i2 WITH protect, noconstant(0)
   DECLARE st_display = vc WITH protect, noconstant(fillstring(90," "))
   DECLARE st_display_temp = vc WITH protect, noconstant("")
   SET spec_test_line_cnt = 0
   SET stat = alterlist(special_test->spec_tst_print_list,1)
   FOR (i = 1 TO special_test_cnt)
     IF ((special_test->spec_tst[i].status_flag=statusflag))
      IF (spec_test_line_cnt=0)
       SET spec_test_line_cnt = 1
       SET st_display = trim(special_test->spec_tst[i].special_testing_disp)
      ELSE
       SET st_display_temp = concat(trim(special_test->spec_tst[i].special_testing_disp),", ",trim(
         st_display))
       IF (size(trim(st_display_temp)) > 84)
        SET special_test->spec_tst_print_list[spec_test_line_cnt].special_test_line = st_display
        SET spec_test_line_cnt += 1
        SET stat = alterlist(special_test->spec_tst_print_list,spec_test_line_cnt)
        SET st_display = fillstring(90," ")
        SET st_display = trim(special_test->spec_tst[i].special_testing_disp)
       ELSE
        SET st_display = st_display_temp
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   IF (spec_test_line_cnt > 0)
    SET special_test->spec_tst_print_list[spec_test_line_cnt].special_test_line = st_display
   ENDIF
   RETURN(spec_test_line_cnt)
 END ;Subroutine
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
 SET line = fillstring(125,"_")
 SET prd_cnt = 0
 SET cmp_cnt = 0
 SET cur_cnt = 0
 SET k = 0
 SET stat = alterlist(pool_comp->cmp_list,10)
 SET found_cmp = "N"
 SET page_break = "Y"
 SELECT INTO cpm_cfn_info->file_name_logical
  cp.product_id, d_flag = decode(cp_p.seq,"CP_P    ",cp_rel_p.seq,"CP_REL_P",st.seq,
   "ST      ",stc.seq,"STC     ",pt.seq,"PT      ",
   ptc.seq,"PTC     ","XXXXXXXX"), cp_abo_disp = uar_get_code_display(cp.abo_cd),
  cp_rh_disp = uar_get_code_display(cp.rh_cd), cp_unit_meas = uar_get_code_display(cp.unit_meas_cd),
  cp.expire_dt_tm,
  cp_reason_disp = uar_get_code_display(cp.correction_reason_cd), cp.correction_id, cp.updt_dt_tm,
  cp_donation_type_disp = uar_get_code_display(cp.donation_type_cd), cp_disease_disp =
  uar_get_code_display(cp.disease_cd), prefix_null = nullind(cp.supplier_prefix),
  alternate_null = nullind(cp.alternate_nbr), sub_nbr_null = nullind(cp.product_sub_nbr),
  intended_use_null = nullind(cp.intended_use_print_parm_txt),
  cp.updt_id, prs.username, pr.product_nbr,
  pr.product_sub_nbr, pr_product_disp = uar_get_code_display(pr.product_cd), pr_cur_unit_meas =
  uar_get_code_display(pr.cur_unit_meas_cd),
  pr_donation_type_disp = uar_get_code_display(pr.donation_type_cd), pr_disease_disp =
  uar_get_code_display(pr.disease_cd), bp.supplier_prefix,
  bp.cur_volume, bp_abo_disp = uar_get_code_display(bp.cur_abo_cd), bp_rh_disp = uar_get_code_display
  (bp.cur_rh_cd),
  cp_p.product_id, cp_p.product_nbr, cp_p.product_sub_nbr,
  cp_p.pooled_product_id, cp_p_product_disp = uar_get_code_display(cp_p.product_cd), cp_p_bp_abo_disp
   = uar_get_code_display(cp_p_bp.cur_abo_cd),
  cp_p_bp_rh_disp = uar_get_code_display(cp_p_bp.cur_rh_cd), cp_p_bp.supplier_prefix, cp_rel
  .correction_flag,
  cp_rel_p.product_id, cp_rel_p.product_nbr, cp_rel_p.product_sub_nbr,
  cp_rel_p_product_disp = uar_get_code_display(cp_rel_p.product_cd), cp_rel_bp_abo_disp =
  uar_get_code_display(cp_rel_bp.cur_abo_cd), cp_rel_bp_rh_disp = uar_get_code_display(cp_rel_bp
   .cur_rh_cd),
  cp_rel_bp.supplier_prefix, cp_pool_nbr_sort = decode(cp_p.seq,concat(trim(cp_p_bp.supplier_prefix),
    trim(cp_p.product_nbr)," ",trim(cp_p.product_sub_nbr)),cp_rel.seq,concat(trim(cp_rel_bp
     .supplier_prefix),trim(cp_rel_p.product_nbr)," ",trim(cp_rel_p.product_sub_nbr)),
   "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"), nullind_cp_product_type_barcode = nullind(cp
   .product_type_barcode)
  FROM corrected_product cp,
   prsnl prs,
   product pr,
   blood_product bp,
   organization o_curr,
   organization o_prev,
   (dummyt d_cp  WITH seq = 1),
   product cp_p,
   blood_product cp_p_bp,
   (dummyt d_rel  WITH seq = 1),
   corrected_product cp_rel,
   product cp_rel_p,
   blood_product cp_rel_bp,
   (dummyt d_st  WITH seq = 1),
   special_testing st,
   (dummyt d_stc  WITH seq = 1),
   corrected_special_tests stc,
   (dummyt d_pt  WITH seq = 1),
   auto_directed ad,
   person pt,
   (dummyt d_ptc  WITH seq = 1),
   corrected_product pt_cp,
   person ptc
  PLAN (cp
   WHERE cp.updt_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->end_dt_tm)
    AND cp.correction_type_cd=chg_recon_cd
    AND cp.correction_flag=1)
   JOIN (prs
   WHERE prs.person_id=cp.updt_id)
   JOIN (pr
   WHERE pr.product_id=cp.product_id
    AND (((request->cur_owner_area_cd > 0.0)
    AND (request->cur_owner_area_cd=pr.cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0.0)))
    AND (((request->cur_inv_area_cd > 0.0)
    AND (request->cur_inv_area_cd=pr.cur_inv_area_cd)) OR ((request->cur_inv_area_cd=0.0))) )
   JOIN (bp
   WHERE bp.product_id=pr.product_id)
   JOIN (o_curr
   WHERE o_curr.organization_id=pr.cur_supplier_id)
   JOIN (o_prev
   WHERE o_prev.organization_id=cp.supplier_id)
   JOIN (((d_cp
   WHERE d_cp.seq=1)
   JOIN (cp_p
   WHERE cp_p.pooled_product_id=cp.product_id)
   JOIN (cp_p_bp
   WHERE cp_p_bp.product_id=cp_p.product_id)
   ) ORJOIN ((((d_rel
   WHERE d_rel.seq=1)
   JOIN (cp_rel
   WHERE cp_rel.related_correction_id=cp.correction_id
    AND cp_rel.person_id=0)
   JOIN (cp_rel_p
   WHERE cp_rel_p.product_id=cp_rel.product_id)
   JOIN (cp_rel_bp
   WHERE cp_rel_bp.product_id=cp_rel_p.product_id)
   ) ORJOIN ((((d_st
   WHERE d_st.seq=1)
   JOIN (st
   WHERE st.product_id=cp.product_id
    AND st.active_ind=1)
   ) ORJOIN ((((d_stc
   WHERE d_stc.seq=1)
   JOIN (stc
   WHERE stc.correction_id=cp.correction_id)
   ) ORJOIN ((((d_pt
   WHERE d_pt.seq=1)
   JOIN (ad
   WHERE ad.product_id=cp.product_id
    AND ad.active_ind=1)
   JOIN (pt
   WHERE pt.person_id=ad.person_id)
   ) ORJOIN ((d_ptc
   WHERE d_ptc.seq=1)
   JOIN (pt_cp
   WHERE pt_cp.related_correction_id=cp.correction_id
    AND pt_cp.person_id > 0)
   JOIN (ptc
   WHERE ptc.person_id=pt_cp.person_id)
   )) )) )) )) ))
  ORDER BY cp.correction_id DESC, pr.product_id, d_flag,
   cp_rel.correction_flag
  HEAD REPORT
   cmp_cnt = 0, pr_product_cat_disp = fillstring(29," "), cp_product_cat_disp = fillstring(29," "),
   pr_intended_use = fillstring(29," "), cp_intended_use = fillstring(29," "), patient_found_ind = 0,
   i = 0
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
   col 1, captions->correction_type, col 19,
   chg_recon_disp, row + 1, col 9,
   captions->demographic, col 38, captions->current,
   col 66, captions->previous, row + 1,
   col 1, "------------------------", col 27,
   "-----------------------------", col 57, "-----------------------------",
   row + 1, page_break = "Y"
  HEAD cp.correction_id
   IF (cp.correction_id > 0.0)
    datafoundflag = true, patient_found_ind = 0, cmp_cnt = 0,
    stat = alterlist(pool_comp->cmp_list,10), special_test_cnt = 0, stat = alterlist(special_test->
     spec_tst,10)
    IF (row > 55)
     BREAK
    ENDIF
    IF (page_break != "Y")
     col 1, "*", row + 1
    ENDIF
    page_break = "N", col 1, captions->product_no,
    col 27, pr.product_nbr, col 57,
    cp.product_nbr, row + 1
    IF (row > 56)
     BREAK
    ENDIF
    col 1, captions->product_sub_no, col 27,
    pr.product_sub_nbr
    IF (sub_nbr_null=0)
     IF (size(trim(cp.product_sub_nbr))=0)
      col 57, captions->no_data
     ELSE
      col 57, cp.product_sub_nbr
     ENDIF
    ENDIF
    row + 1
    IF (row > 56)
     BREAK
    ENDIF
    col 1, captions->supplier_prefix, col 27,
    bp.supplier_prefix
    IF (prefix_null=0)
     IF (size(trim(cp.supplier_prefix))=0)
      col 57, captions->no_data
     ELSE
      col 57, cp.supplier_prefix
     ENDIF
    ENDIF
    row + 1
    IF (row > 56)
     BREAK
    ENDIF
    col 1, captions->product_type, col 27,
    pr_product_disp
    IF (cp.product_cd > 0)
     cp_product_disp = uar_get_code_display(cp.product_cd), col 57, cp_product_disp
    ENDIF
    row + 1
    IF (row > 56)
     BREAK
    ENDIF
    col 1, captions->expire_dt_tm, expire_dt_tm = cnvtdatetime(pr.cur_expire_dt_tm)
    IF (expire_dt_tm > cnvtdatetime(" "))
     col 27, expire_dt_tm"@DATECONDENSED;;d", col 35,
     expire_dt_tm"@TIMENOSECONDS;;M"
    ENDIF
    expire_dt_tm = cnvtdatetime(cp.expire_dt_tm)
    IF (expire_dt_tm > cnvtdatetime(" "))
     col 57, expire_dt_tm"@DATECONDENSED;;d", col 65,
     expire_dt_tm"@TIMENOSECONDS;;M"
    ENDIF
    row + 1
    IF (row > 56)
     BREAK
    ENDIF
    col 1, captions->abo, col 27,
    bp_abo_disp"##########", col 57, cp_abo_disp"###############",
    row + 1
    IF (row > 56)
     BREAK
    ENDIF
    col 1, captions->rh, col 27,
    bp_rh_disp"###############", col 57, cp_rh_disp"###############",
    row + 1
    IF (row > 56)
     BREAK
    ENDIF
    IF (alternate_null=0)
     col 1, captions->alternate_number, col 27,
     pr.alternate_nbr
     IF (size(trim(cp.alternate_nbr))=0)
      col 57, captions->no_data
     ELSE
      col 57, cp.alternate_nbr
     ENDIF
     row + 1
     IF (row > 56)
      BREAK
     ENDIF
    ENDIF
    IF (cp.product_cat_cd > 0)
     pr_product_cat_disp = uar_get_code_display(pr.product_cat_cd), cp_product_cat_disp =
     uar_get_code_display(cp.product_cat_cd), col 1,
     captions->product_category, col 27, pr_product_cat_disp,
     col 57, cp_product_cat_disp, row + 1
     IF (row > 56)
      BREAK
     ENDIF
    ENDIF
    IF (nullind_cp_product_type_barcode=0)
     col 1, captions->product_type_bc
     IF (size(trim(cp.product_type_barcode))=0)
      col 27, pr.product_type_barcode, col 57,
      captions->no_data
     ELSE
      col 27, pr.product_type_barcode, col 57,
      cp.product_type_barcode
     ENDIF
     row + 1
     IF (row > 56)
      BREAK
     ENDIF
    ENDIF
    IF (cp.supplier_id > 0)
     col 1, captions->supplier_name, col 27,
     o_curr.org_name"#############################", col 57, o_prev.org_name
     "#############################",
     row + 1
     IF (row > 56)
      BREAK
     ENDIF
    ENDIF
    col 1, captions->donation_type
    IF (size(trim(pr_donation_type_disp)) > 0)
     col 27, pr_donation_type_disp"#############################"
    ENDIF
    IF (size(trim(cp_donation_type_disp)) > 0)
     col 57, cp_donation_type_disp"#############################"
    ENDIF
    row + 1
    IF (row > 56)
     BREAK
    ENDIF
    col 1, captions->disease
    IF (size(trim(pr_disease_disp)) > 0)
     col 27, pr_disease_disp"#############################"
    ENDIF
    IF (size(trim(cp_disease_disp)) > 0)
     col 57, cp_disease_disp"#############################"
    ENDIF
    row + 1
    IF (row > 56)
     BREAK
    ENDIF
    IF (intended_use_null=0)
     pr_intended_use = intended_use_definition(pr.intended_use_print_parm_txt), cp_intended_use =
     intended_use_definition(cp.intended_use_print_parm_txt), col 1,
     captions->intended_use, col 27, pr_intended_use
     IF (size(trim(cp.intended_use_print_parm_txt))=0)
      col 57, captions->no_data
     ELSE
      col 57, cp_intended_use
     ENDIF
     row + 1
     IF (row > 56)
      BREAK
     ENDIF
    ENDIF
   ENDIF
  DETAIL
   found_cmp = "N"
   IF (d_flag="CP_REL_P")
    IF (cp_rel_p.product_id > 0.0)
     found_cmp = "N", lidx = 1
     WHILE (found_cmp != "Y"
      AND lidx <= cmp_cnt)
       IF ((pool_comp->cmp_list[lidx].product_id=cp_rel_p.product_id))
        found_cmp = "Y"
       ELSE
        lidx += 1
       ENDIF
     ENDWHILE
     IF (found_cmp="N")
      cmp_cnt += 1
      IF (mod(cmp_cnt,10)=1
       AND cmp_cnt != 1)
       stat = alterlist(pool_comp->cmp_list,(cmp_cnt+ 9))
      ENDIF
      pool_comp->cmp_list[cmp_cnt].correction_flag = cp_rel.correction_flag, pool_comp->cmp_list[
      cmp_cnt].current_ind = 0, pool_comp->cmp_list[cmp_cnt].product_id = cp_rel_p.product_id,
      pool_comp->cmp_list[cmp_cnt].product_nbr = cp_rel_p.product_nbr, pool_comp->cmp_list[cmp_cnt].
      product_sub_nbr = cp_rel_p.product_sub_nbr, pool_comp->cmp_list[cmp_cnt].product_disp =
      cp_rel_p_product_disp,
      pool_comp->cmp_list[cmp_cnt].supplier_prefix = cp_rel_bp.supplier_prefix, pool_comp->cmp_list[
      cmp_cnt].abo_disp = cp_rel_bp_abo_disp, pool_comp->cmp_list[cmp_cnt].rh_disp =
      cp_rel_bp_rh_disp,
      pool_comp->cmp_list[cmp_cnt].exp_dt_tm = cp_rel_p.cur_expire_dt_tm
     ELSE
      pool_comp->cmp_list[lidx].correction_flag = cp_rel.correction_flag
     ENDIF
    ENDIF
   ELSEIF (d_flag="CP_P    ")
    IF (cp_p.product_id > 0.0)
     found_cmp = "N", lidx = 1
     WHILE (found_cmp != "Y"
      AND lidx <= cmp_cnt)
       IF ((pool_comp->cmp_list[lidx].product_id=cp_p.product_id))
        found_cmp = "Y"
       ELSE
        lidx += 1
       ENDIF
     ENDWHILE
     IF (found_cmp="N")
      cmp_cnt += 1
      IF (mod(cmp_cnt,10)=1
       AND cmp_cnt != 1)
       stat = alterlist(pool_comp->cmp_list,(cmp_cnt+ 9))
      ENDIF
      pool_comp->cmp_list[cmp_cnt].correction_flag = 0, pool_comp->cmp_list[cmp_cnt].current_ind = 1,
      pool_comp->cmp_list[cmp_cnt].product_id = cp_p.product_id,
      pool_comp->cmp_list[cmp_cnt].product_nbr = cp_p.product_nbr, pool_comp->cmp_list[cmp_cnt].
      product_sub_nbr = cp_p.product_sub_nbr, pool_comp->cmp_list[cmp_cnt].product_disp =
      cp_p_product_disp,
      pool_comp->cmp_list[cmp_cnt].supplier_prefix = cp_p_bp.supplier_prefix, pool_comp->cmp_list[
      cmp_cnt].abo_disp = cp_p_bp_abo_disp, pool_comp->cmp_list[cmp_cnt].rh_disp = cp_p_bp_rh_disp,
      pool_comp->cmp_list[cmp_cnt].exp_dt_tm = cp_p.cur_expire_dt_tm
     ELSE
      pool_comp->cmp_list[lidx].current_ind = 1
     ENDIF
    ENDIF
   ELSEIF (d_flag="PT      ")
    IF (patient_found_ind=0)
     col 1, captions->patient, patient_found_ind = 1
    ENDIF
    col 27, pt.name_full_formatted"######################", row + 1
    IF (row > 56)
     BREAK
    ENDIF
   ELSEIF (d_flag="PTC     ")
    IF (patient_found_ind=0)
     col 1, captions->patient, patient_found_ind = 1
    ENDIF
    col 57, ptc.name_full_formatted"######################", row + 1
    IF (row > 56)
     BREAK
    ENDIF
   ELSEIF (((d_flag="ST      ") OR (d_flag="STC     ")) )
    special_test_cnt += 1
    IF (special_test_cnt > size(special_test->spec_tst,5))
     stat = alterlist(special_test->spec_tst,(special_test_cnt+ 5))
    ENDIF
    IF (d_flag="ST      ")
     special_test->spec_tst[special_test_cnt].special_testing_cd = st.special_testing_cd,
     special_test->spec_tst[special_test_cnt].status_flag = current_flag, special_test->spec_tst[
     special_test_cnt].special_testing_disp = uar_get_code_display(st.special_testing_cd)
    ELSEIF (d_flag="STC     ")
     special_test->spec_tst[special_test_cnt].special_testing_cd = stc.special_testing_cd,
     special_test->spec_tst[special_test_cnt].status_flag = stc.new_spec_test_ind, special_test->
     spec_tst[special_test_cnt].special_testing_disp = uar_get_code_display(stc.special_testing_cd)
    ENDIF
   ENDIF
  FOOT  cp.correction_id
   IF (cp.correction_id > 0.0)
    IF (special_test_cnt > 0)
     stat = alterlist(special_test->spec_tst,special_test_cnt), col 1, captions->attribute_antigen
     IF (getspecialtestingdisplaylines(current_flag) > 0)
      col 27, captions->current
      FOR (i = 1 TO spec_test_line_cnt)
        col 37, special_test->spec_tst_print_list[i].special_test_line, row + 1
        IF (row > 56)
         BREAK
        ENDIF
      ENDFOR
     ENDIF
     IF (getspecialtestingdisplaylines(added_flag) > 0)
      col 27, captions->added
      FOR (i = 1 TO spec_test_line_cnt)
        col 37, special_test->spec_tst_print_list[i].special_test_line, row + 1
        IF (row > 56)
         BREAK
        ENDIF
      ENDFOR
     ENDIF
     IF (getspecialtestingdisplaylines(removed_flag) > 0)
      col 27, captions->removed
      FOR (i = 1 TO spec_test_line_cnt)
        col 37, special_test->spec_tst_print_list[i].special_test_line, row + 1
        IF (row > 56)
         BREAK
        ENDIF
      ENDFOR
     ENDIF
    ENDIF
    stat = alterlist(pool_comp->cmp_list,cmp_cnt)
    IF (row > 50)
     BREAK
    ENDIF
    col 49, captions->currently, col 59,
    captions->added, row + 1, col 1,
    captions->component_products, col 30, captions->product_no,
    col 49, captions->in_recon, col 58,
    captions->removed, col 68, captions->product_type,
    CALL center(captions->aborh,90,104), col 106, captions->expires,
    row + 1, col 24, "-------------------------",
    col 50, "-------", col 58,
    "-------", col 66, "-----------------------",
    col 90, "---------------", col 106,
    "------------", row + 1, k = 0,
    j = 0
    FOR (j = 1 TO cmp_cnt)
      prod_nbr_display = concat(trim(pool_comp->cmp_list[j].supplier_prefix),trim(pool_comp->
        cmp_list[j].product_nbr)," ",trim(pool_comp->cmp_list[j].product_sub_nbr)), col 24,
      prod_nbr_display
      IF ((pool_comp->cmp_list[j].current_ind=1))
       col 50, captions->yes
      ENDIF
      IF ((pool_comp->cmp_list[j].correction_flag=2))
       col 57, captions->removed
      ELSEIF ((pool_comp->cmp_list[j].correction_flag=3))
       col 58, captions->added
      ENDIF
      col 66, pool_comp->cmp_list[j].product_disp, aborh_disp = concat(trim(pool_comp->cmp_list[j].
        abo_disp)," ",trim(pool_comp->cmp_list[j].rh_disp)),
      col 90, aborh_disp"###############", expire_dt_tm = cnvtdatetime(pool_comp->cmp_list[j].
       exp_dt_tm)
      IF (expire_dt_tm > cnvtdatetime(" "))
       col 106, expire_dt_tm"@DATECONDENSED;;d", col 114,
       expire_dt_tm"@TIMENOSECONDS;;M"
      ENDIF
      row + 1
      IF (row > 53)
       BREAK
      ENDIF
    ENDFOR
    row + 1
    IF (row > 53)
     BREAK
    ENDIF
    col 1, captions->corrected, col 17,
    captions->dt_tm, col 31, captions->tech_id,
    col 47, captions->reason, col 83,
    captions->note, row + 1, col 15,
    "-------------", col 30, "----------",
    col 42, "--------------------", col 63,
    "-----------------------------------------------------------", row + 1, updt_dt_tm = cnvtdatetime
    (cp.updt_dt_tm)
    IF (updt_dt_tm > cnvtdatetime(" "))
     col 15, updt_dt_tm"@DATECONDENSED;;d", col 23,
     updt_dt_tm"@TIMENOSECONDS;;M"
    ENDIF
    col 30, prs.username"######", col 42,
    cp_reason_disp, b_cnt = 1, col_cnt = 63,
    start_col_cnt = 63, max_width = 62, pos_left = 62,
    b_strg = cp.correction_note, b_str_len = size(trim(b_strg))
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
           IF (((substring(b_cnt_sub,1,b_strg)=" ") OR (substring(b_cnt_sub,2,b_strg)=concat(char(13),
            char(10)))) )
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
    row + 1
    IF (row > 56)
     BREAK
    ENDIF
    stat = alterlist(pool_comp->cmp_list,0)
   ENDIF
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
  WITH nocounter, maxrow = 63, compress,
   nolandscape, nullreport
 ;end select
 IF (((datafoundflag=true) OR ((request->null_ind=1))) )
  SET rpt_cnt += 1
  SET stat = alterlist(reply->rpt_list,rpt_cnt)
  SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
  SET datafoundflag = false
 ENDIF
 FREE RECORD special_test
 FREE RECORD pool_comp
 SET reply->status_data.status = "S"
#exit_script
END GO
