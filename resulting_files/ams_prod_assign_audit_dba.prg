CREATE PROGRAM ams_prod_assign_audit:dba
 PAINT
 DECLARE numrows = i4 WITH constant(20), protect
 DECLARE numcols = i4 WITH constant(75), protect
 DECLARE soffrow = i4 WITH constant(6), protect
 DECLARE soffcol = i4 WITH constant(3), protect
 DECLARE quesrow = i4 WITH constant(22), protect
 DECLARE maxrows = i4 WITH protect
 DECLARE cnt = i4 WITH protect
 DECLARE arow = i4 WITH protect
 DECLARE rowstr = c75 WITH protect
 DECLARE pick = i4 WITH protect
 DECLARE ccl_ver = i4 WITH protect, noconstant(cnvtint(build(currev,currevminor,currevminor2)))
 DECLARE status = c1 WITH protect, noconstant("F")
 DECLARE debug_ind = i2 WITH protect
 DECLARE statusstr = vc WITH protect
 DECLARE last_mod = vc WITH protect
 DECLARE i = i4 WITH protect
 RECORD log(
   1 qual_cnt = i4
   1 qual[*]
     2 smsgtype = c12
     2 dmsg_dt_tm = dq8
     2 smsg = vc
 ) WITH protect
 DECLARE validatelogin(null) = null WITH protect
 DECLARE clearscreen(null) = null WITH protect
 DECLARE drawmenu(title=vc,detailline=vc,warningline=vc) = null WITH protect
 DECLARE emailfile(vcrecep=vc,vcfrom=vc,vcsubj=vc,vcbody=vc,vcfile=vc) = i2 WITH protect
 DECLARE getclient(null) = vc WITH protect
 DECLARE gethnaemail(null) = vc WITH protect
 DECLARE addlogmsg(msgtype=vc,msg=vc) = null WITH protect
 DECLARE createlogfile(filename=vc) = null WITH protect
 DECLARE drawscrollbox(begrow=i4,begcol=i4,endrow=i4,endcol=i4) = null WITH protect
 DECLARE downarrow(newrow=c75) = null WITH protect
 DECLARE uparrow(newrow=c75) = null WITH protect
 SUBROUTINE validatelogin(null)
   EXECUTE cclseclogin
   SET message = nowindow
   IF ((xxcclseclogin->loggedin != 1))
    SET status = "F"
    SET statusstr = "You must be logged in securely. Please run the program again."
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE clearscreen(null)
   DECLARE i = i4 WITH protect
   SET i = soffrow
   WHILE (i <= numrows)
    CALL clear(i,soffcol,numcols)
    SET i = (i+ 1)
   ENDWHILE
   CALL clear((numrows+ 2),soffcol,numcols)
 END ;Subroutine
 SUBROUTINE drawmenu(title,detailline,warningline)
   CALL clear(1,1)
   CALL box((soffrow - 5),(soffcol - 1),(numrows+ 3),(numcols+ 3))
   CALL video(r)
   CALL text((soffrow - 4),soffcol,title)
   CALL text((soffrow - 3),soffcol,detailline)
   CALL video(b)
   CALL text((soffrow - 2),soffcol,warningline)
   CALL video(n)
   CALL line((soffrow - 1),(soffcol - 1),(numcols+ 2),xhor)
   CALL line((soffrow+ 15),(soffcol - 1),(numcols+ 2),xhor)
   CALL text((soffrow+ 16),soffcol,"Choose an option:")
 END ;Subroutine
 SUBROUTINE emailfile(vcrecep,vcfrom,vcsubj,vcbody,vcfile)
   DECLARE retval = i2
   RECORD email_request(
     1 recepstr = vc
     1 fromstr = vc
     1 subjectstr = vc
     1 bodystr = vc
     1 filenamestr = vc
   ) WITH protect
   RECORD email_reply(
     1 status = c1
     1 errorstr = vc
   ) WITH protect
   SET email_request->recepstr = vcrecep
   SET email_request->fromstr = vcfrom
   SET email_request->subjectstr = vcsubj
   SET email_request->bodystr = vcbody
   SET email_request->filenamestr = vcfile
   EXECUTE ams_run_email_file  WITH replace("REQUEST",email_request), replace("REPLY",email_reply)
   IF ((email_reply->status="S"))
    SET retval = 1
   ELSE
    SET retval = 0
   ENDIF
   RETURN(retval)
 END ;Subroutine
 SUBROUTINE getclient(null)
   DECLARE retval = vc WITH protect, noconstant("")
   SET retval = logical("CLIENT_MNEMONIC")
   IF (retval="")
    SELECT INTO "nl:"
     d.info_char
     FROM dm_info d
     WHERE d.info_domain="DATA MANAGEMENT"
      AND d.info_name="CLIENT MNEMONIC"
     DETAIL
      retval = trim(d.info_char)
     WITH nocounter
    ;end select
   ENDIF
   IF (retval="")
    SET retval = "unknown"
   ENDIF
   RETURN(retval)
 END ;Subroutine
 SUBROUTINE gethnaemail(null)
   DECLARE retval = vc WITH protect
   SELECT INTO "nl:"
    p.email
    FROM prsnl p
    WHERE (p.person_id=reqinfo->updt_id)
    DETAIL
     retval = trim(p.email)
    WITH nocounter
   ;end select
   RETURN(retval)
 END ;Subroutine
 SUBROUTINE addlogmsg(msgtype,msg)
   SET log->qual_cnt = (log->qual_cnt+ 1)
   IF (mod(log->qual_cnt,50)=1)
    SET stat = alterlist(log->qual,(log->qual_cnt+ 49))
   ENDIF
   SET log->qual[log->qual_cnt].smsgtype = msgtype
   SET log->qual[log->qual_cnt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_cnt].smsg = msg
 END ;Subroutine
 SUBROUTINE createlogfile(filename)
   DECLARE logcnt = i4 WITH protect
   IF (ccl_ver >= 871)
    SET modify = filestream
   ENDIF
   SET stat = alterlist(log->qual,log->qual_cnt)
   FREE SET output_log
   SET logical output_log value(nullterm(concat("CCLUSERDIR:",trim(cnvtlower(filename)))))
   SELECT INTO output_log
    FROM (dummyt d  WITH seq = 1)
    HEAD REPORT
     outline = fillstring(254," ")
    DETAIL
     FOR (logcnt = 1 TO log->qual_cnt)
       outline = trim(substring(1,254,concat(format(log->qual[logcnt].smsgtype,"############")," :: ",
          format(log->qual[logcnt].dmsg_dt_tm,"dd-mmm-yyyy hh:mm:ss;;q")," :: ",trim(log->qual[logcnt
           ].smsg)))), col 0, outline
       IF ((logcnt != log->qual_cnt))
        row + 1
       ENDIF
     ENDFOR
    WITH nocounter, formfeed = none, format = stream,
     append, maxcol = 255, maxrow = 1
   ;end select
 END ;Subroutine
 SUBROUTINE drawscrollbox(begrow,begcol,endrow,endcol)
  CALL box(begrow,begcol,endrow,endcol)
  CALL scrollinit((begrow+ 1),(begcol+ 1),(endrow - 1),(endcol - 1))
 END ;Subroutine
 SUBROUTINE downarrow(newrow)
   IF (arow=maxrows)
    CALL scrolldown(maxrows,maxrows,newrow)
   ELSE
    SET arow = (arow+ 1)
    CALL scrolldown((arow - 1),arow,newrow)
   ENDIF
 END ;Subroutine
 SUBROUTINE uparrow(newrow)
   IF (arow=1)
    CALL scrollup(arow,arow,rowstr)
   ELSE
    SET arow = (arow - 1)
    CALL scrollup((arow+ 1),arow,rowstr)
   ENDIF
 END ;Subroutine
 IF (validate(debug,0))
  IF (debug=1)
   SET debug_ind = 1
  ELSE
   SET debug_ind = 0
   SET trace = callecho
   SET trace = notest
   SET trace = nordbdebug
   SET trace = nordbbind
   SET trace = noechoinput
   SET trace = noechoinput2
   SET trace = noechorecord
   SET trace = noshowuar
   SET trace = noechosub
   SET trace = nowarning
   SET trace = nowarning2
   SET message = noinformation
   SET trace = nocost
  ENDIF
 ELSE
  SET debug_ind = 0
  SET trace = callecho
  SET trace = notest
  SET trace = nordbdebug
  SET trace = nordbbind
  SET trace = noechoinput
  SET trace = noechoinput2
  SET trace = noechorecord
  SET trace = noshowuar
  SET trace = noechosub
  SET trace = nowarning
  SET trace = nowarning2
  SET message = noinformation
  SET trace = nocost
 ENDIF
 SET last_mod = "005"
 DECLARE loadrequestforordsent(ord_sent_pos=i4) = i2 WITH protect
 DECLARE loadrequest(null) = i2 WITH protect
 DECLARE loadrequestforivset(null) = i2 WITH protect
 DECLARE getordersents(searchmode=i2,searchid=f8) = i4 WITH protect
 DECLARE setverificationreportlevel(reportlevel=i4) = i2 WITH protect
 DECLARE auditprimarymode(null) = null WITH protect
 DECLARE singlesentencemode(null) = null WITH protect
 DECLARE adhocordermode(null) = null WITH protect
 DECLARE auditivsetmode(null) = null WITH protect
 DECLARE getsynonymfromuser(null) = f8 WITH protect
 DECLARE auditpowerplanmode(null) = null WITH protect
 DECLARE processrequest(ord_sents_pos=i4) = i2 WITH protect
 DECLARE processrequestforivset(iv_sets_pos=i4) = i2 WITH protect
 DECLARE createoutputfile(filename=vc) = null WITH protect
 DECLARE getpatientlocinfofromuser(null) = null WITH protect
 DECLARE getpatientweightfromuser(null) = null WITH protect
 DECLARE loaditemdetails(null) = null WITH protect
 DECLARE checkverificationreportlevel(null) = i2 WITH protect
 DECLARE setmedordertypecd(ord_sent_pos=i4) = null WITH protect
 DECLARE usestrengthorvolume(searchmode=i2,searchid=f8) = i2 WITH protect
 DECLARE explodevolumedose(ingredstr=f8,ingredstrunitcd=f8,itemid=f8) = f8 WITH protect
 DECLARE explodestrengthdose(ingredvol=f8,ingredvolunitcd=f8,itemid=f8) = f8 WITH protect
 DECLARE getconvertedstrength(itemid=f8,targetunitcd=f8) = f8 WITH protect
 DECLARE getconvertedvolume(itemid=f8,targetunitcd=f8) = f8 WITH protect
 DECLARE convertvaluetounit(curvalue=f8,curunitcd=f8,targetunitcd=f8) = f8 WITH protect
 DECLARE calculatefinitedose(null) = null WITH protect
 DECLARE calculateorderprice(pos=i4) = null WITH protect
 DECLARE createsummaryreportinfo(null) = null WITH protect
 DECLARE getivingredientoefid(null) = f8 WITH protect
 DECLARE incrementerrorcnt(progname=vc,inccnt=f8,infodetail=vc) = i2 WITH protect
 DECLARE geterrorcnt(progname=vc) = f8 WITH protect
 DECLARE deleteerrorcnt(progname=vc) = i4 WITH protect
 DECLARE title_line = c75 WITH protect, constant(
  "                        AMS Product Assignment Audit                        ")
 DECLARE detail_line = c75 WITH protect, constant(
  "     Determine which product will be assigned to an order by the system     ")
 DECLARE script_name = c21 WITH protect, constant("AMS_PROD_ASSIGN_AUDIT")
 DECLARE med_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",18309,"MED"))
 DECLARE int_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",18309,"INTERMITTENT"))
 DECLARE iv_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",18309,"IV"))
 DECLARE pharm_cat_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6000,"PHARMACY"))
 DECLARE pharm_act_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",106,"PHARMACY"))
 DECLARE action_order_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6003,"ORDER"))
 DECLARE inpatient_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4500,"INPATIENT"))
 DECLARE system_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4062,"SYSTEM"))
 DECLARE retail_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4500,"RETAIL"))
 DECLARE desc_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",11000,"DESC"))
 DECLARE ndc_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",11000,"NDC"))
 DECLARE kilogram_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",54,"KG"))
 DECLARE iv_solutions_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16389,"IVSOLUTIONS"))
 DECLARE iv_ingred_oef_id = f8 WITH protect, constant(getivingredientoefid(null))
 DECLARE from_str = vc WITH protect, constant("ams_product_assignment_audit@cerner.com")
 DECLARE syn_type_brand = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"BRANDNAME"))
 DECLARE syn_type_primary = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"PRIMARY"))
 DECLARE syn_type_c = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"DISPDRUG"))
 DECLARE syn_type_dcp = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"DCP"))
 DECLARE syn_type_e = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"IVNAME"))
 DECLARE syn_type_m = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"GENERICTOP"))
 DECLARE syn_type_n = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"TRADETOP"))
 DECLARE syn_type_rx = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"RXMNEMONIC"))
 DECLARE syn_type_y = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"GENERICPROD"))
 DECLARE syn_type_z = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"TRADEPROD"))
 DECLARE ord_sent_filter_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",30620,"ORDERSENT"))
 DECLARE single_sent_mode = i2 WITH protect, constant(1)
 DECLARE ad_hoc_order_mode = i2 WITH protect, constant(2)
 DECLARE primary_mode = i2 WITH protect, constant(3)
 DECLARE powerplan_mode = i2 WITH protect, constant(4)
 DECLARE iv_set_mode = i2 WITH protect, constant(5)
 DECLARE search_by_syn = i2 WITH protect, constant(1)
 DECLARE search_by_primary = i2 WITH protect, constant(2)
 DECLARE search_by_all_primary = i2 WITH protect, constant(3)
 DECLARE search_by_powerplan = i2 WITH protect, constant(4)
 DECLARE search_by_all_powerplan = i2 WITH protect, constant(5)
 DECLARE search_by_iv_set = i2 WITH protect, constant(6)
 DECLARE search_by_all_iv_set = i2 WITH protect, constant(7)
 DECLARE item_mode = i2 WITH protect, constant(1)
 DECLARE ingredient_mode = i2 WITH protect, constant(2)
 DECLARE only_strength_is_valid = i2 WITH protect, constant(0)
 DECLARE only_volume_is_valid = i2 WITH protect, constant(1)
 DECLARE strength_and_volume_are_valid = i2 WITH protect, constant(2)
 DECLARE strength_and_volume_are_invalid = i2 WITH protect, constant(3)
 DECLARE product_no_strength = i2 WITH protect, constant(- (1))
 DECLARE product_no_volume = i2 WITH protect, constant(- (2))
 DECLARE cannot_convert_unit = i2 WITH protect, constant(- (3))
 DECLARE unit_ckis_not_found = i2 WITH protect, constant(- (4))
 DECLARE unknown_error = i2 WITH protect, constant(- (5))
 DECLARE programmode = i2 WITH protect
 DECLARE logfilename = vc WITH protect, noconstant(" ")
 DECLARE facilitycd = f8 WITH protect
 DECLARE nurseunitcd = f8 WITH protect
 DECLARE encountertypecd = f8 WITH protect
 DECLARE checkallprimariesind = i2 WITH protect
 DECLARE checkallplansind = i2 WITH protect
 DECLARE checkallivsetsind = i2 WITH protect
 DECLARE patientweight = f8 WITH protect
 DECLARE outputfilename = vc WITH protect
 DECLARE totalsentcnt = i4 WITH protect
 DECLARE totalivsetcnt = i4 WITH protect
 DECLARE strengthdosefieldid = f8 WITH protect
 DECLARE strengthdoseunitfieldid = f8 WITH protect
 DECLARE volumedosefieldid = f8 WITH protect
 DECLARE volumedoseunitfieldid = f8 WITH protect
 DECLARE freetextdosefieldid = f8 WITH protect
 DECLARE freetextratefieldid = f8 WITH protect
 DECLARE routefieldid = f8 WITH protect
 DECLARE formfieldid = f8 WITH protect
 DECLARE ratefieldid = f8 WITH protect
 DECLARE infuseoverfieldid = f8 WITH protect
 DECLARE normalizedratefieldid = f8 WITH protect
 DECLARE frequencyfieldid = f8 WITH protect
 DECLARE apapercent = f8 WITH protect
 DECLARE sentaparate = f8 WITH protect
 DECLARE planaparate = f8 WITH protect
 DECLARE ivsetaparate = f8 WITH protect
 DECLARE bodystr = vc WITH protect
 DECLARE subjectstr = vc WITH protect
 DECLARE criticalerrorcnt = i4 WITH protect
 DECLARE nosenterrorcnt = i4 WITH protect
 DECLARE noproderrorcnt = i4 WITH protect
 DECLARE missingdetailcnt = i4 WITH protect
 DECLARE builderrorcnt = i4 WITH protect
 DECLARE facilitydisp = vc WITH protect
 DECLARE auditcatdisp = vc WITH protect
 DECLARE auditplandisp = vc WITH protect
 DECLARE auditivsetdisp = vc WITH protect
 DECLARE apacnt = f8 WITH protect
 SET logfilename = concat("ams_prod_assign_audit_",cnvtlower(format(cnvtdatetime(curdate,curtime3),
    "dd_mmm_yyyy_hh_mm;;q")),".log")
 RECORD apa_request(
   1 catalog_group[*]
     2 route_cd = f8
     2 form_cd = f8
     2 facility_cd = f8
     2 pat_locn_cd = f8
     2 encounter_type_cd = f8
     2 skip_iv_ind = i2
     2 order_type_list[*]
       3 med_order_type_cd = f8
     2 catalog_list[*]
       3 catalog_cd = f8
       3 synonym_id = f8
       3 strength = f8
       3 strength_unit_cd = f8
       3 volume = f8
       3 volume_unit_cd = f8
       3 orderable_type_flag = i2
       3 freetext_dose = vc
 ) WITH protect
 RECORD aps_request(
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
   1 care_locn_cd = f8
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
 ) WITH protect
 RECORD aps_reply(
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
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 RECORD ord_sents(
   1 list[*]
     2 catalog_cd = f8
     2 mnemonic = vc
     2 primary_disp = vc
     2 plan_disp = vc
     2 pathway_catalog_id = f8
     2 dcp_clin_cat_cd = f8
     2 dcp_clin_sub_cat_cd = f8
     2 mnemonic_type_cd = f8
     2 synonym_id = f8
     2 syn_oe_format_id = f8
     2 syn_oef = vc
     2 rx_mask = i4
     2 synonym_vv_fac = f8
     2 incomplete_os_ind = i2
     2 missing_field_text = vc
     2 os_vv_fac = f8
     2 os_disp_line = vc
     2 order_sentence_id = f8
     2 error_text = vc
     2 os_oe_format_id = f8
     2 route_cd = f8
     2 route_mask_mismatch_ind = i2
     2 form_cd = f8
     2 order_type_list[*]
       3 med_order_type_cd = f8
     2 strength = f8
     2 strength_unit_cd = f8
     2 volume = f8
     2 volume_unit_cd = f8
     2 normalized_unit_ind = i2
     2 normalized_dose = f8
     2 normalized_dose_unit = f8
     2 orderable_type_flag = i2
     2 freetext_dose = vc
     2 rate = f8
     2 infuse_over = f8
     2 set_id = f8
     2 set_desc = vc
     2 set_price_sched_id = f8
     2 set_price_sched_formula_type_flag = i2
     2 items[*]
       3 item_id = f8
       3 item_desc = vc
       3 qpd = f8
       3 assigned_by = vc
       3 round_disp_qty_ind = i2
       3 price_sched_id = f8
       3 price_sched_formula_type_flag = i2
       3 manf_item_id = f8
     2 cost = f8
     2 price = f8
 ) WITH protect
 RECORD iv_sets(
   1 set_list[*]
     2 catalog_cd = f8
     2 primary_disp = vc
     2 route_cd = f8
     2 form_cd = f8
     2 med_order_type_cd = f8
     2 plan_disp = vc
     2 pathway_catalog_id = f8
     2 dcp_clin_cat_cd = f8
     2 dcp_clin_sub_cat_cd = f8
     2 set_id = f8
     2 set_desc = vc
     2 set_price_sched_id = f8
     2 set_price_sched_formula_type_flag = i2
     2 syn_list[*]
       3 syn_catalog_cd = f8
       3 syn_mnemonic = vc
       3 syn_mnemonic_type_cd = f8
       3 synonym_id = f8
       3 syn_oe_format_id = f8
       3 syn_oef = vc
       3 rx_mask = i4
       3 synonym_vv_fac = f8
       3 sequence = i2
       3 incomplete_os_ind = i2
       3 missing_field_text = vc
       3 os_disp_line = vc
       3 order_sentence_id = f8
       3 error_text = vc
       3 os_oe_format_id = f8
       3 orderable_type_flag = i2
       3 frequency_cd = f8
       3 strength = f8
       3 strength_unit_cd = f8
       3 volume = f8
       3 volume_unit_cd = f8
       3 normalized_rate = f8
       3 rate = f8
       3 freetext_rate = vc
       3 infuse_over = f8
       3 item_id = f8
       3 item_desc = vc
       3 qpd = f8
       3 assigned_by = vc
       3 round_disp_qty_ind = i2
       3 price_sched_id = f8
       3 price_sched_formula_type_flag = i2
       3 manf_item_id = f8
     2 cost = f8
     2 price = f8
 ) WITH protect
 RECORD item_info(
   1 list[*]
     2 item_id = f8
     2 str = f8
     2 strunitcd = f8
     2 vol = f8
     2 volunitcd = f8
 ) WITH protect
 RECORD price_request(
   1 pricing_ind = i4
   1 price_schedule_id = f8
   1 total_price = f8
   1 care_locn_cd = f8
   1 inv_loc_cd = f8
   1 facility_cd = f8
   1 encounter_type_cd = f8
   1 bill_list[*]
     2 item_id = f8
     2 dose_quantity = f8
     2 price = f8
     2 manf_id = f8
     2 tnf_cost = f8
   1 no_cost_ind = i2
 ) WITH protect
 RECORD price_reply(
   1 total_price = f8
   1 bill_list[*]
     2 cost = f8
     2 tax_amt = f8
     2 price_sched_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 CALL validatelogin(null)
 IF (debug_ind=1)
  CALL addlogmsg("INFO","Beginning ams_auto_prod_assign_utility")
 ENDIF
#main_menu
 SET sentaparate = geterrorcnt(build(script_name,"|SENTENCES"))
 SET planaparate = geterrorcnt(build(script_name,"|POWER_PLANS"))
 SET ivsetaparate = geterrorcnt(build(script_name,"|IV_SETS"))
 CALL drawmenu(title_line,detail_line,"")
 CALL text((soffrow+ 3),(soffcol+ 26),"1 Single Order Sentence")
 CALL text((soffrow+ 4),(soffcol+ 26),"2 Adhoc Order")
 CALL text((soffrow+ 5),(soffcol+ 26),"3 All Sentences for a Primary")
 CALL text((soffrow+ 6),(soffcol+ 26),"4 All Sentences for a PowerPlan")
 CALL text((soffrow+ 7),(soffcol+ 26),"5 IV Set")
 CALL text((soffrow+ 8),(soffcol+ 26),"6 Set Facility and Nurse Unit")
 CALL text((soffrow+ 9),(soffcol+ 26),"7 Set Patient's Weight")
 CALL text((soffrow+ 10),(soffcol+ 26),"8 Exit")
 CALL text((soffrow+ 11),soffcol,"Last run stats:")
 CALL text((soffrow+ 12),soffcol,build2("Sentences:  ",trim(cnvtstring(sentaparate,5,2)),"%"))
 CALL text((soffrow+ 13),soffcol,build2("PowerPlans: ",trim(cnvtstring(planaparate,5,2)),"%"))
 CALL text((soffrow+ 14),soffcol,build2("IV Sets:    ",trim(cnvtstring(ivsetaparate,5,2)),"%"))
 CALL accept(quesrow,(soffcol+ 18),"9;",8
  WHERE curaccept IN (1, 2, 3, 4, 5,
  6, 7, 8))
 CASE (curaccept)
  OF 1:
   SET programmode = single_sent_mode
   CALL singlesentencemode(null)
  OF 2:
   SET programmode = ad_hoc_order_mode
   CALL adhocordermode(null)
  OF 3:
   SET programmode = primary_mode
   CALL auditprimarymode(null)
  OF 4:
   SET programmode = powerplan_mode
   CALL auditpowerplanmode(null)
  OF 5:
   SET programmode = iv_set_mode
   CALL auditivsetmode(null)
  OF 6:
   CALL getpatientlocinfofromuser(null)
   GO TO main_menu
  OF 7:
   CALL clearscreen(null)
   CALL getpatientweightfromuser(null)
   GO TO main_menu
  OF 8:
   GO TO exit_script
 ENDCASE
 SUBROUTINE createsummaryreportinfo(null)
   DECLARE modestr = vc WITH protect
   IF (programmode=powerplan_mode)
    IF (checkallplansind=1)
     SET modestr = "ALL POWERPLANS"
    ELSE
     SET modestr = auditplandisp
    ENDIF
    SET bodystr = build2("Product Assignment Summary Report for ",modestr,char(13),
     "Total number of order sentences: ",trim(cnvtstring(totalsentcnt)),
     char(13),"Total number of IV sets: ",trim(cnvtstring(totalivsetcnt)),char(13),"APA rate: ",
     trim(cnvtstring(apapercent,11,2)),"%",char(13),"Number of critical product assignment errors: ",
     trim(cnvtstring(criticalerrorcnt)),
     char(13),"Number of synonyms without an order sentence: ",trim(cnvtstring(nosenterrorcnt)),char(
      13),"Number of sentences with no product available when verifying: ",
     trim(cnvtstring(noproderrorcnt)),char(13),"Number of sentences missing required details: ",trim(
      cnvtstring(missingdetailcnt)),char(13),
     "Number of general build errors: ",trim(cnvtstring(builderrorcnt)))
   ELSEIF (programmode=iv_set_mode)
    IF (checkallivsetsind=1)
     SET modestr = "ALL IV SETS"
    ELSE
     SET modestr = auditivsetdisp
    ENDIF
    SET bodystr = build2("Product Assignment Summary Report for ",modestr,char(13),
     "Total number of IV sets: ",trim(cnvtstring(totalivsetcnt)),
     char(13),"APA rate: ",trim(cnvtstring(apapercent,11,2)),"%",char(13),
     "Number of critical product assignment errors: ",trim(cnvtstring(criticalerrorcnt)),char(13),
     "Number of synonyms without an order sentence: ",trim(cnvtstring(nosenterrorcnt)),
     char(13),"Number of sentences with no product available when verifying: ",trim(cnvtstring(
       noproderrorcnt)),char(13),"Number of sentences missing required details: ",
     trim(cnvtstring(missingdetailcnt)),char(13),"Number of general build errors: ",trim(cnvtstring(
       builderrorcnt)))
   ELSEIF (programmode=primary_mode)
    IF (checkallprimariesind=1)
     SET modestr = "ALL PRIMARIES"
    ELSE
     SET modestr = auditcatdisp
    ENDIF
    SET bodystr = build2("Product Assignment Summary Report for ",modestr,char(13),
     "Total number of order sentences: ",trim(cnvtstring(totalsentcnt)),
     char(13),"APA rate: ",trim(cnvtstring(apapercent,11,2)),"%",char(13),
     "Number of critical product assignment errors: ",trim(cnvtstring(criticalerrorcnt)),char(13),
     "Number of synonyms without an order sentence: ",trim(cnvtstring(nosenterrorcnt)),
     char(13),"Number of sentences with no product available when verifying: ",trim(cnvtstring(
       noproderrorcnt)),char(13),"Number of sentences missing required details: ",
     trim(cnvtstring(missingdetailcnt)),char(13),"Number of general build errors: ",trim(cnvtstring(
       builderrorcnt)))
   ENDIF
   SET subjectstr = build2("Product assignment results for ",trim(facilitydisp)," : ",trim(curdomain)
    )
 END ;Subroutine
 SUBROUTINE getivingredientoefid(null)
   DECLARE retval = f8 WITH protect
   SELECT INTO "nl:"
    oefp.oe_format_id
    FROM order_entry_format_parent oefp
    PLAN (oefp
     WHERE oefp.catalog_type_cd=pharm_cat_cd
      AND cnvtupper(oefp.oe_format_name)="IV INGREDIENT")
    DETAIL
     retval = oefp.oe_format_id
    WITH nocounter
   ;end select
   RETURN(retval)
 END ;Subroutine
 SUBROUTINE calculatefinitedose(null)
   DECLARE found = i2 WITH protect
   DECLARE cnt = i4 WITH protect, noconstant(1)
   WHILE (found=0
    AND cnt <= size(ord_sents->list,5))
    IF ((ord_sents->list[cnt].normalized_unit_ind=1))
     SET found = 1
    ENDIF
    SET cnt = (cnt+ 1)
   ENDWHILE
   IF (found=1)
    IF (patientweight=0)
     CALL text((soffrow+ 3),soffcol,"Order sentences based on the patient's weight were found.")
     CALL getpatientweightfromuser(null)
    ENDIF
    SELECT INTO "nl:"
     dc.uom_numerator_cd
     FROM (dummyt d  WITH seq = value(size(ord_sents->list,5))),
      dose_calculator_uom dc
     PLAN (d
      WHERE (ord_sents->list[d.seq].normalized_unit_ind=1))
      JOIN (dc
      WHERE (((dc.uom_cd=ord_sents->list[d.seq].strength_unit_cd)) OR ((dc.uom_cd=ord_sents->list[d
      .seq].volume_unit_cd)))
       AND dc.uom_type_flag=3
       AND dc.uom_denominator_cd=kilogram_cd)
     DETAIL
      IF ((ord_sents->list[d.seq].strength > 0))
       ord_sents->list[d.seq].normalized_dose = ord_sents->list[d.seq].strength, ord_sents->list[d
       .seq].normalized_dose_unit = ord_sents->list[d.seq].strength_unit_cd, ord_sents->list[d.seq].
       strength = (ord_sents->list[d.seq].strength * patientweight),
       ord_sents->list[d.seq].strength_unit_cd = dc.uom_numerator_cd, ord_sents->list[d.seq].
       os_disp_line = build2(ord_sents->list[d.seq].os_disp_line," = ",trim(cnvtstring(ord_sents->
          list[d.seq].strength))," ",trim(uar_get_code_display(ord_sents->list[d.seq].
          strength_unit_cd)),
        " calculated dose")
      ELSEIF ((ord_sents->list[d.seq].volume > 0))
       ord_sents->list[d.seq].normalized_dose = ord_sents->list[d.seq].volume, ord_sents->list[d.seq]
       .normalized_dose_unit = ord_sents->list[d.seq].volume_unit_cd, ord_sents->list[d.seq].volume
        = (ord_sents->list[d.seq].volume * patientweight),
       ord_sents->list[d.seq].volume_unit_cd = dc.uom_numerator_cd, ord_sents->list[d.seq].
       os_disp_line = build2(ord_sents->list[d.seq].os_disp_line," = ",trim(cnvtstring(ord_sents->
          list[d.seq].volume))," ",trim(uar_get_code_display(ord_sents->list[d.seq].volume_unit_cd)),
        " calculated dose")
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE setmedordertypecd(ord_sent_pos)
   DECLARE pos = i4 WITH protect
   DECLARE routecnt = i4 WITH protect
   DECLARE routecd = f8 WITH protect
   DECLARE idx = i4 WITH protect
   RECORD route_types(
     1 list[*]
       2 route_cd = f8
       2 type = i4
   ) WITH protect
   IF (ord_sent_pos > 0)
    SELECT INTO "nl:"
     cve.code_value, cve.field_value
     FROM code_value_extension cve
     PLAN (cve
      WHERE (cve.code_value=ord_sents->list[ord_sent_pos].route_cd)
       AND cve.code_set=4001
       AND cve.field_name="ORDERED AS")
     DETAIL
      CASE (cnvtint(cve.field_value))
       OF 1:
        IF (band(ord_sents->list[ord_sent_pos].rx_mask,4) > 0)
         stat = alterlist(ord_sents->list[ord_sent_pos].order_type_list,1), ord_sents->list[
         ord_sent_pos].order_type_list[1].med_order_type_cd = med_type_cd
        ELSE
         ord_sents->list[ord_sent_pos].route_mask_mismatch_ind = 1
        ENDIF
       OF 2:
        IF (band(ord_sents->list[ord_sent_pos].rx_mask,4) > 0)
         stat = alterlist(ord_sents->list[ord_sent_pos].order_type_list,1), ord_sents->list[
         ord_sent_pos].order_type_list[1].med_order_type_cd = int_type_cd
         IF ((ord_sents->list[ord_sent_pos].rate=0)
          AND (ord_sents->list[ord_sent_pos].infuse_over=0))
          IF ((ord_sents->list[ord_sent_pos].missing_field_text=""))
           missingdetailcnt = (missingdetailcnt+ 1), ord_sents->list[ord_sent_pos].missing_field_text
            = "Sentence is missing a Rate and Infuse Over"
          ELSE
           ord_sents->list[ord_sent_pos].missing_field_text = concat(ord_sents->list[ord_sent_pos].
            missing_field_text,", Rate and Infuse Over")
          ENDIF
         ENDIF
        ELSE
         ord_sents->list[ord_sent_pos].route_mask_mismatch_ind = 1
        ENDIF
       OF 4:
        IF (((band(ord_sents->list[ord_sent_pos].rx_mask,1) > 0) OR (band(ord_sents->list[
         ord_sent_pos].rx_mask,2) > 0)) )
         stat = alterlist(ord_sents->list[ord_sent_pos].order_type_list,1), ord_sents->list[
         ord_sent_pos].order_type_list[1].med_order_type_cd = iv_type_cd
        ELSE
         ord_sents->list[ord_sent_pos].route_mask_mismatch_ind = 1
         IF (band(ord_sents->list[ord_sent_pos].rx_mask,4) > 0)
          stat = alterlist(ord_sents->list[ord_sent_pos].order_type_list,1), ord_sents->list[
          ord_sent_pos].order_type_list[1].med_order_type_cd = med_type_cd
         ENDIF
        ENDIF
       OF 3:
        IF (band(ord_sents->list[ord_sent_pos].rx_mask,4) > 0)
         stat = alterlist(ord_sents->list[ord_sent_pos].order_type_list,2), ord_sents->list[
         ord_sent_pos].order_type_list[1].med_order_type_cd = med_type_cd, ord_sents->list[
         ord_sent_pos].order_type_list[2].med_order_type_cd = int_type_cd
        ELSE
         ord_sents->list[ord_sent_pos].route_mask_mismatch_ind = 1
        ENDIF
       OF 5:
        IF (band(ord_sents->list[ord_sent_pos].rx_mask,4) > 0)
         stat = alterlist(ord_sents->list[ord_sent_pos].order_type_list,1), ord_sents->list[
         ord_sent_pos].order_type_list[1].med_order_type_cd = med_type_cd
        ELSEIF (((band(ord_sents->list[ord_sent_pos].rx_mask,1) > 0) OR (band(ord_sents->list[
         ord_sent_pos].rx_mask,2) > 0)) )
         stat = alterlist(ord_sents->list[ord_sent_pos].order_type_list,1), ord_sents->list[
         ord_sent_pos].order_type_list[1].med_order_type_cd = iv_type_cd
        ELSE
         ord_sents->list[ord_sent_pos].route_mask_mismatch_ind = 1
        ENDIF
       OF 6:
        IF (band(ord_sents->list[ord_sent_pos].rx_mask,4) > 0)
         stat = alterlist(ord_sents->list[ord_sent_pos].order_type_list,1), ord_sents->list[
         ord_sent_pos].order_type_list[1].med_order_type_cd = int_type_cd
         IF ((ord_sents->list[ord_sent_pos].rate=0)
          AND (ord_sents->list[ord_sent_pos].infuse_over=0))
          IF ((ord_sents->list[ord_sent_pos].missing_field_text=""))
           missingdetailcnt = (missingdetailcnt+ 1), ord_sents->list[ord_sent_pos].missing_field_text
            = "Sentence is missing a Rate and Infuse Over"
          ELSE
           ord_sents->list[ord_sent_pos].missing_field_text = concat(ord_sents->list[ord_sent_pos].
            missing_field_text,", Rate and Infuse Over")
          ENDIF
         ENDIF
        ELSEIF (((band(ord_sents->list[ord_sent_pos].rx_mask,1) > 0) OR (band(ord_sents->list[
         ord_sent_pos].rx_mask,2) > 0)) )
         stat = alterlist(ord_sents->list[ord_sent_pos].order_type_list,1), ord_sents->list[
         ord_sent_pos].order_type_list[1].med_order_type_cd = iv_type_cd
        ELSE
         ord_sents->list[ord_sent_pos].route_mask_mismatch_ind = 1
        ENDIF
       OF 7:
        IF (band(ord_sents->list[ord_sent_pos].rx_mask,4) > 0)
         stat = alterlist(ord_sents->list[ord_sent_pos].order_type_list,2), ord_sents->list[
         ord_sent_pos].order_type_list[1].med_order_type_cd = med_type_cd, ord_sents->list[
         ord_sent_pos].order_type_list[2].med_order_type_cd = int_type_cd
        ELSEIF (((band(ord_sents->list[ord_sent_pos].rx_mask,1) > 0) OR (band(ord_sents->list[
         ord_sent_pos].rx_mask,2) > 0)) )
         stat = alterlist(ord_sents->list[ord_sent_pos].order_type_list,1), ord_sents->list[
         ord_sent_pos].order_type_list[1].med_order_type_cd = iv_type_cd
        ELSE
         ord_sents->list[ord_sent_pos].route_mask_mismatch_ind = 1
        ENDIF
      ENDCASE
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "nl:"
     cve.code_value, cve.field_value
     FROM code_value_extension cve
     PLAN (cve
      WHERE cve.code_set=4001
       AND cve.field_name="ORDERED AS")
     ORDER BY cve.code_value
     HEAD REPORT
      routecnt = 0, stat = alterlist(route_types->list,50)
     DETAIL
      routecnt = (routecnt+ 1)
      IF (mod(routecnt,10)=1
       AND routecnt > 50)
       stat = alterlist(route_types->list,(routecnt+ 9))
      ENDIF
      route_types->list[routecnt].route_cd = cve.code_value, route_types->list[routecnt].type =
      cnvtint(cve.field_value)
     FOOT REPORT
      stat = alterlist(route_types->list,routecnt)
     WITH nocounter
    ;end select
    FOR (i = 1 TO size(ord_sents->list,5))
      SET routecd = ord_sents->list[i].route_cd
      SET pos = locatevalsort(idx,1,size(route_types->list,5),routecd,route_types->list[idx].route_cd
       )
      IF (pos > 0)
       CASE (route_types->list[pos].type)
        OF 1:
         IF (band(ord_sents->list[i].rx_mask,4) > 0)
          SET stat = alterlist(ord_sents->list[i].order_type_list,1)
          SET ord_sents->list[i].order_type_list[1].med_order_type_cd = med_type_cd
         ELSE
          SET ord_sents->list[i].route_mask_mismatch_ind = 1
         ENDIF
        OF 2:
         IF (band(ord_sents->list[i].rx_mask,4) > 0)
          SET stat = alterlist(ord_sents->list[i].order_type_list,1)
          SET ord_sents->list[i].order_type_list[1].med_order_type_cd = int_type_cd
          IF ((ord_sents->list[i].rate=0)
           AND (ord_sents->list[i].infuse_over=0))
           IF ((ord_sents->list[i].missing_field_text=""))
            SET missingdetailcnt = (missingdetailcnt+ 1)
            SET ord_sents->list[i].missing_field_text = "Sentence is missing a Rate and Infuse Over"
           ELSE
            SET ord_sents->list[i].missing_field_text = concat(ord_sents->list[i].missing_field_text,
             ", Rate and Infuse Over")
           ENDIF
          ENDIF
         ELSE
          SET ord_sents->list[i].route_mask_mismatch_ind = 1
         ENDIF
        OF 4:
         IF (((band(ord_sents->list[i].rx_mask,1) > 0) OR (band(ord_sents->list[i].rx_mask,2) > 0)) )
          SET stat = alterlist(ord_sents->list[i].order_type_list,1)
          SET ord_sents->list[i].order_type_list[1].med_order_type_cd = iv_type_cd
         ELSE
          SET ord_sents->list[i].route_mask_mismatch_ind = 1
          IF (band(ord_sents->list[i].rx_mask,4) > 0)
           SET stat = alterlist(ord_sents->list[i].order_type_list,1)
           SET ord_sents->list[i].order_type_list[1].med_order_type_cd = med_type_cd
          ENDIF
         ENDIF
        OF 3:
         IF (band(ord_sents->list[i].rx_mask,4) > 0)
          SET stat = alterlist(ord_sents->list[i].order_type_list,2)
          SET ord_sents->list[i].order_type_list[1].med_order_type_cd = med_type_cd
          SET ord_sents->list[i].order_type_list[2].med_order_type_cd = int_type_cd
         ELSE
          SET ord_sents->list[i].route_mask_mismatch_ind = 1
         ENDIF
        OF 5:
         IF (band(ord_sents->list[i].rx_mask,4) > 0)
          SET stat = alterlist(ord_sents->list[i].order_type_list,1)
          SET ord_sents->list[i].order_type_list[1].med_order_type_cd = med_type_cd
         ELSEIF (((band(ord_sents->list[i].rx_mask,1) > 0) OR (band(ord_sents->list[i].rx_mask,2) > 0
         )) )
          SET stat = alterlist(ord_sents->list[i].order_type_list,1)
          SET ord_sents->list[i].order_type_list[1].med_order_type_cd = iv_type_cd
         ELSE
          SET ord_sents->list[i].route_mask_mismatch_ind = 1
         ENDIF
        OF 6:
         IF (band(ord_sents->list[i].rx_mask,4) > 0)
          SET stat = alterlist(ord_sents->list[i].order_type_list,1)
          SET ord_sents->list[i].order_type_list[1].med_order_type_cd = int_type_cd
          IF ((ord_sents->list[i].rate=0)
           AND (ord_sents->list[i].infuse_over=0))
           IF ((ord_sents->list[i].missing_field_text=""))
            SET missingdetailcnt = (missingdetailcnt+ 1)
            SET ord_sents->list[i].missing_field_text = "Sentence is missing a Rate and Infuse Over"
           ELSE
            SET ord_sents->list[i].missing_field_text = concat(ord_sents->list[i].missing_field_text,
             ", Rate and Infuse Over")
           ENDIF
          ENDIF
         ELSEIF (((band(ord_sents->list[i].rx_mask,1) > 0) OR (band(ord_sents->list[i].rx_mask,2) > 0
         )) )
          SET stat = alterlist(ord_sents->list[i].order_type_list,1)
          SET ord_sents->list[i].order_type_list[1].med_order_type_cd = iv_type_cd
         ELSE
          SET ord_sents->list[i].route_mask_mismatch_ind = 1
         ENDIF
        OF 7:
         IF (band(ord_sents->list[i].rx_mask,4) > 0)
          SET stat = alterlist(ord_sents->list[i].order_type_list,2)
          SET ord_sents->list[i].order_type_list[1].med_order_type_cd = med_type_cd
          SET ord_sents->list[i].order_type_list[2].med_order_type_cd = int_type_cd
         ELSEIF (((band(ord_sents->list[i].rx_mask,1) > 0) OR (band(ord_sents->list[i].rx_mask,2) > 0
         )) )
          SET stat = alterlist(ord_sents->list[i].order_type_list,1)
          SET ord_sents->list[i].order_type_list[1].med_order_type_cd = iv_type_cd
         ELSE
          SET ord_sents->list[i].route_mask_mismatch_ind = 1
         ENDIF
       ENDCASE
      ENDIF
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE checkverificationreportlevel(null)
   IF (setverificationreportlevel(0))
    RETURN(1)
   ELSE
    CALL text(soffrow,soffcol,"This program must set the verificationreportlevel property on the 112"
     )
    CALL text((soffrow+ 1),soffcol,
     "server to 0 before running. There was an error encountered while attempting")
    CALL text((soffrow+ 2),soffcol,
     "to set the property. Ensure the account you logged into CCL with has privs")
    CALL text((soffrow+ 3),soffcol,
     "to change server properties and cycle servers or have the property changed")
    CALL text((soffrow+ 4),soffcol,"before running this program.")
    CALL text(quesrow,soffcol,"Continue?:")
    CALL accept(quesrow,(soffcol+ 10),"A;CUS","Y"
     WHERE curaccept IN ("Y"))
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE getsynonymfromuser(null)
   DECLARE synid = f8 WITH protect
   DECLARE syndisp = vc WITH protect
   DECLARE syncnt = i4 WITH protect
   RECORD audit_syns(
     1 list[*]
       2 synonym_id = f8
       2 mnemonic = c60
       2 mnemonic_type_disp = c5
   ) WITH protect
   WHILE (synid=0)
     CALL text(soffrow,soffcol,"Enter synonym to audit (Shift+F5 to select):")
     SET help = promptmsg("Synonym starts with:")
     SET help = pos(3,1,15,80)
     SET help =
     SELECT INTO "nl:"
      synonym = substring(1,65,ocs.mnemonic), type = substring(1,5,evaluate(ocs.mnemonic_type_cd,
        syn_type_brand,"Brand",syn_type_primary,"Primary",
        syn_type_c,"C Disp",syn_type_dcp,"DCP",syn_type_e,
        "E",syn_type_m,"M",syn_type_n,"N",
        "N/A"))
      FROM order_catalog_synonym ocs,
       order_catalog oc,
       ocs_facility_r ofr
      PLAN (ocs
       WHERE ocs.catalog_type_cd=pharm_cat_cd
        AND ocs.activity_type_cd=pharm_act_cd
        AND ocs.active_ind=1
        AND  NOT (ocs.mnemonic_type_cd IN (syn_type_rx, syn_type_y, syn_type_z))
        AND cnvtupper(ocs.mnemonic) >= cnvtupper(curaccept))
       JOIN (oc
       WHERE oc.catalog_cd=ocs.catalog_cd
        AND oc.orderable_type_flag IN (0, 1))
       JOIN (ofr
       WHERE ofr.synonym_id=ocs.synonym_id
        AND ofr.facility_cd IN (0, facilitycd))
      ORDER BY cnvtupper(ocs.mnemonic)
     ;end select
     CALL accept((soffrow+ 1),(soffcol+ 3),"P(65);CP")
     IF (textlen(trim(curaccept))=65)
      SET syndisp = concat(substring(1,64,cnvtupper(curaccept)),"*")
     ELSE
      SET syndisp = trim(cnvtupper(curaccept))
     ENDIF
     SET help = off
     IF (cnvtupper(curaccept)="QUIT")
      GO TO main_menu
     ELSE
      SELECT INTO "nl:"
       ocs.mnemonic, ocs.synonym_id
       FROM order_catalog_synonym ocs,
        order_catalog oc
       PLAN (ocs
        WHERE ocs.catalog_type_cd=pharm_cat_cd
         AND ocs.activity_type_cd=pharm_act_cd
         AND ocs.active_ind=1
         AND  NOT (ocs.mnemonic_type_cd IN (syn_type_rx, syn_type_y, syn_type_z))
         AND cnvtupper(ocs.mnemonic)=patstring(syndisp))
        JOIN (oc
        WHERE oc.catalog_cd=ocs.catalog_cd
         AND oc.orderable_type_flag IN (0, 1))
       HEAD REPORT
        syncnt = 0
       DETAIL
        syncnt = (syncnt+ 1), stat = alterlist(audit_syns->list,syncnt), audit_syns->list[syncnt].
        synonym_id = ocs.synonym_id,
        audit_syns->list[syncnt].mnemonic = ocs.mnemonic, audit_syns->list[syncnt].mnemonic_type_disp
         = substring(1,5,evaluate(ocs.mnemonic_type_cd,syn_type_brand,"Brand",syn_type_primary,
          "Primary",
          syn_type_c,"C Disp",syn_type_dcp,"DCP",syn_type_e,
          "E",syn_type_m,"M",syn_type_n,"N",
          "N/A")), synid = ocs.synonym_id
       WITH nocounter
      ;end select
      IF (curqual=0)
       CALL text((soffrow+ 2),soffcol,"No synonym found! Enter valid pharmacy synonym.")
      ELSE
       IF (syncnt=1)
        CALL clear((soffrow+ 2),soffcol,numcols)
        RETURN(synid)
       ELSE
        CALL text((soffrow+ 2),soffcol,
         "Multiple synonyms exist with the same display. Select one to continue.")
        SET maxrows = 8
        CALL drawscrollbox((soffrow+ 5),(soffcol+ 1),numrows,(numcols+ 1))
        SET cnt = 0
        WHILE (cnt < maxrows
         AND cnt < syncnt)
          SET cnt = (cnt+ 1)
          SET rowstr = build2(cnvtstring(cnt,2,0,r)," ",audit_syns->list[cnt].mnemonic,audit_syns->
           list[cnt].mnemonic_type_disp)
          CALL scrolltext(cnt,rowstr)
        ENDWHILE
        SET cnt = 1
        SET arow = 1
        SET pick = 0
        WHILE (pick=0)
          CALL text(quesrow,soffcol,"(S)elect or (M)ain Menu?:")
          CALL accept(quesrow,(soffcol+ 25),"A;CUS","S"
           WHERE curaccept IN ("S", "M"))
          CASE (curscroll)
           OF 0:
            IF (curaccept="S")
             SET pick = 1
             SET synid = audit_syns->list[cnt].synonym_id
             FOR (i = (soffrow+ 2) TO (quesrow - 2))
               CALL clear(i,soffcol,numcols)
             ENDFOR
             RETURN(synid)
            ELSE
             SET pick = 1
             GO TO main_menu
            ENDIF
           OF 1:
            IF (cnt < syncnt)
             SET cnt = (cnt+ 1)
             SET rowstr = build2(cnvtstring(cnt,2,0,r)," ",audit_syns->list[cnt].mnemonic,audit_syns
              ->list[cnt].mnemonic_type_disp)
             CALL downarrow(rowstr)
            ENDIF
           OF 2:
            IF (cnt > 1)
             SET cnt = (cnt - 1)
             SET rowstr = build2(cnvtstring(cnt,2,0,r)," ",audit_syns->list[cnt].mnemonic,audit_syns
              ->list[cnt].mnemonic_type_disp)
             CALL uparrow(rowstr)
            ENDIF
          ENDCASE
        ENDWHILE
       ENDIF
      ENDIF
     ENDIF
   ENDWHILE
 END ;Subroutine
 SUBROUTINE auditivsetmode(null)
   DECLARE rowcnt = i4 WITH protect
   DECLARE finished = i2 WITH protect
   DECLARE auditivsetcatcd = f8 WITH protect
   SET outputfilename = build(cnvtlower(curdomain),"_iv_set_apa_results.csv")
   CALL clearscreen(null)
   SET stat = initrec(iv_sets)
   SET stat = initrec(ord_sents)
   SET checkallprimariesind = 0
   SET checkallivsetsind = 0
   SET checkallplansind = 0
   SET missingdetailcnt = 0
   SET apacnt = 0
   IF (checkverificationreportlevel(null))
    IF (((facilitycd=0) OR (((nurseunitcd=0) OR (encountertypecd=0)) )) )
     CALL getpatientlocinfofromuser(null)
    ENDIF
    WHILE (auditivsetcatcd=0
     AND checkallivsetsind=0)
      SET finished = 0
      CALL text(soffrow,soffcol,"Enter IV set to audit or ALL (Shift+F5 to select):")
      SET help = promptmsg("IV set starts with:")
      SET help = pos(3,1,15,80)
      SET help =
      SELECT INTO "nl:"
       iv_set = oc.primary_mnemonic
       FROM order_catalog oc,
        order_catalog_synonym ocs,
        ocs_facility_r ofr
       PLAN (oc
        WHERE oc.catalog_type_cd=pharm_cat_cd
         AND oc.orderable_type_flag=8
         AND oc.active_ind=1
         AND cnvtupper(oc.primary_mnemonic) >= cnvtupper(curaccept))
        JOIN (ocs
        WHERE ocs.catalog_cd=oc.catalog_cd
         AND ocs.mnemonic_type_cd=syn_type_primary)
        JOIN (ofr
        WHERE ofr.synonym_id=ocs.synonym_id
         AND ofr.facility_cd IN (0, facilitycd))
       ORDER BY cnvtupper(oc.primary_mnemonic)
       WITH nocounter
      ;end select
      CALL accept((soffrow+ 1),(soffcol+ 3),"P(70);CP")
      SET auditivsetdisp = trim(cnvtupper(curaccept))
      SET help = off
      IF (cnvtupper(curaccept)="QUIT")
       GO TO main_menu
      ELSEIF (cnvtupper(curaccept)="ALL")
       SET checkallivsetsind = 1
       CALL text((soffrow+ 2),soffcol,"Finding all IV sets that are available for the facility")
       SET totalivsetcnt = getordersents(search_by_all_iv_set,null)
       CALL clear((soffrow+ 2),soffcol,numcols)
       CALL text((soffrow+ 2),soffcol,"Processing all IV sets may take a significant amount of time")
       CALL text((soffrow+ 3),soffcol,build2("Count of IV sets: ",trim(cnvtstring(totalivsetcnt))))
       CALL text((soffrow+ 4),soffcol,"Continue?:")
       CALL accept((soffrow+ 4),(soffcol+ 10),"A;CU"
        WHERE curaccept IN ("Y", "N"))
       IF (curaccept="N")
        GO TO main_menu
       ELSE
        CALL clear((soffrow+ 2),soffcol,numcols)
        CALL clear((soffrow+ 3),soffcol,numcols)
        CALL clear((soffrow+ 4),soffcol,numcols)
       ENDIF
      ELSE
       SELECT INTO "nl:"
        iv_set = oc.primary_mnemonic
        FROM order_catalog oc
        PLAN (oc
         WHERE oc.catalog_type_cd=pharm_cat_cd
          AND oc.orderable_type_flag=8
          AND oc.active_ind=1
          AND cnvtupper(oc.primary_mnemonic)=auditivsetdisp)
        DETAIL
         auditivsetcatcd = oc.catalog_cd
        WITH nocounter
       ;end select
       IF (curqual=0)
        CALL text((soffrow+ 2),soffcol,"No IV set found! Enter valid IV set")
       ELSE
        CALL clear((soffrow+ 2),soffcol,numcols)
        SET totalivsetcnt = getordersents(search_by_iv_set,auditivsetcatcd)
       ENDIF
      ENDIF
      IF (totalivsetcnt > 0)
       CALL text((soffrow+ 2),soffcol,"Processing all IV sets...")
       SET stat = loadrequestforivset(null)
       IF (stat=0)
        CALL text((soffrow+ 3),soffcol,build("Error:",statusstr))
        CALL text(quesrow,soffcol,"Continue?:")
        CALL accept(quesrow,(soffcol+ 10),"A;CUS","Y"
         WHERE curaccept IN ("Y"))
       ELSE
        CALL text((soffrow+ 2),(soffcol+ 26),"done")
        WHILE (finished=0)
          IF (checkallivsetsind=1)
           CALL text((soffrow+ 3),soffcol,"Enter filename to create in CCLUSERDIR (or MINE):")
           CALL accept((soffrow+ 4),(soffcol+ 1),"P(74);C",outputfilename)
           IF (((cnvtupper(curaccept)="*.CSV") OR (cnvtupper(curaccept)="MINE")) )
            SET outputfilename = trim(cnvtlower(curaccept))
            CALL clear((soffrow+ 5),soffcol,numcols)
            CALL createoutputfile(outputfilename)
            IF (outputfilename != "mine")
             CALL text((soffrow+ 5),soffcol,"The file has successfully been created in CCLUSERDIR")
             CALL text((soffrow+ 6),soffcol,"Do you want to email the file?:")
             CALL accept((soffrow+ 6),(soffcol+ 31),"A;CU","Y"
              WHERE curaccept IN ("Y", "N"))
             IF (curaccept="Y")
              CALL text((soffrow+ 7),soffcol,"Enter recepient's email address:")
              CALL accept((soffrow+ 8),(soffcol+ 1),"P(74);C",gethnaemail(null)
               WHERE trim(curaccept) > " ")
              CALL createsummaryreportinfo(null)
              IF (emailfile(curaccept,from_str,subjectstr,bodystr,outputfilename))
               CALL text((soffrow+ 14),soffcol,"Emailed file successfully")
              ELSE
               CALL text((soffrow+ 14),soffcol,"Email failed. Manually grab file from CCLUSERDIR")
              ENDIF
              CALL text(quesrow,soffcol,"Continue?:")
              CALL accept(quesrow,(soffcol+ 10),"A;CU","Y"
               WHERE curaccept IN ("Y"))
              SET finished = 1
             ELSE
              SET finished = 1
             ENDIF
            ELSE
             GO TO main_menu
            ENDIF
           ELSE
            CALL text((soffrow+ 2),soffcol,"Output file must be MINE or have .csv extension")
           ENDIF
          ELSE
           SET rowcnt = 3
           FOR (i = 1 TO size(iv_sets->set_list[1].syn_list,5))
             CALL clear((soffrow+ 2),soffcol,numcols)
             IF (rowcnt < 13)
              CALL text((soffrow+ 2),soffcol,"Ingredients:")
              CALL text((soffrow+ rowcnt),(soffcol+ 3),substring(1,31,iv_sets->set_list[1].syn_list[i
                ].syn_mnemonic))
              CALL text((soffrow+ rowcnt),(soffcol+ 35),substring(1,40,iv_sets->set_list[1].syn_list[
                i].os_disp_line))
             ENDIF
             SET rowcnt = (rowcnt+ 1)
           ENDFOR
           SET rowcnt = (rowcnt+ 1)
           IF ((iv_sets->set_list[1].set_id > 0)
            AND rowcnt < 13)
            CALL text((soffrow+ rowcnt),soffcol,substring(1,75,build2("IV Set: ",trim(cnvtstring(
                 iv_sets->set_list[1].set_id))," - ",iv_sets->set_list[1].set_desc)))
           ELSEIF ((iv_sets->set_list[1].set_id=0)
            AND rowcnt < 13)
            CALL text((soffrow+ rowcnt),soffcol,"IV Set: None")
           ENDIF
           SET rowcnt = (rowcnt+ 1)
           FOR (i = 1 TO size(iv_sets->set_list[1].syn_list,5))
            IF ((iv_sets->set_list[1].syn_list[i].item_id > 0)
             AND rowcnt < 13)
             CALL text((soffrow+ rowcnt),(soffcol+ 3),substring(1,72,build2("Item: ",trim(cnvtstring(
                  iv_sets->set_list[1].syn_list[i].item_id))," - ",iv_sets->set_list[1].syn_list[i].
                item_desc)))
             SET rowcnt = (rowcnt+ 1)
             CALL text((soffrow+ rowcnt),(soffcol+ 6),build2("Method: ",iv_sets->set_list[1].
               syn_list[i].assigned_by))
             CALL text((soffrow+ rowcnt),(soffcol+ 25),build2("QPD: ",trim(cnvtstring(iv_sets->
                 set_list[1].syn_list[i].qpd,11,4))))
            ELSEIF ((iv_sets->set_list[1].syn_list[i].item_id=0)
             AND rowcnt < 13)
             CALL text((soffrow+ rowcnt),(soffcol+ 3),"Item: None")
            ENDIF
            SET rowcnt = (rowcnt+ 1)
           ENDFOR
           CALL text((soffrow+ 14),soffcol,build2("Price: ",format(cnvtstring(iv_sets->set_list[1].
               price,11,2),"#######.##;$,")))
           CALL text((soffrow+ 14),(soffcol+ 25),build2("Cost: ",format(cnvtstring(iv_sets->set_list[
               1].cost,11,2),"#######.##;$,")))
           CALL text(quesrow,soffcol,"(A)udit another IV set or (M)ain Menu:")
           CALL accept(quesrow,(soffcol+ 38),"A;CU","M"
            WHERE curaccept IN ("A", "M"))
           IF (curaccept="M")
            SET finished = 1
           ELSE
            CALL clearscreen(null)
            SET finished = 1
            SET auditivsetcatcd = 0
           ENDIF
          ENDIF
        ENDWHILE
       ENDIF
      ELSE
       CALL text((soffrow+ 3),soffcol,"No sentences found for IV set")
       CALL text(quesrow,soffcol,"Continue?:")
       CALL accept(quesrow,(soffcol+ 10),"A;CUS","Y"
        WHERE curaccept IN ("Y"))
      ENDIF
    ENDWHILE
   ENDIF
   GO TO main_menu
 END ;Subroutine
 SUBROUTINE adhocordermode(null)
   DECLARE synid = f8 WITH protect
   DECLARE fieldcnt = i4 WITH protect
   DECLARE codevalue = f8 WITH protect
   DECLARE cvcnt = i4 WITH protect
   DECLARE promptmsg = vc WITH protect
   DECLARE passed = i2 WITH protect
   DECLARE finished = i2 WITH protect
   RECORD fields(
     1 catalog_cd = f8
     1 mnemonic = vc
     1 primary_disp = vc
     1 synonym_id = f8
     1 rx_mask = i4
     1 orderable_type_flag = i4
     1 format_name = vc
     1 list[*]
       2 field_disp = vc
       2 field_type_flag = i2
       2 field_meaning = vc
       2 accept_flag = i2
       2 code_set = i4
       2 value = vc
   ) WITH protect
   CALL clearscreen(null)
   SET stat = initrec(iv_sets)
   SET stat = initrec(ord_sents)
   IF (checkverificationreportlevel(null))
    IF (((facilitycd=0) OR (((nurseunitcd=0) OR (encountertypecd=0)) )) )
     CALL getpatientlocinfofromuser(null)
    ENDIF
    SET synid = getsynonymfromuser(null)
    SELECT INTO "nl:"
     oefp.oe_format_name, ocs.catalog_cd
     FROM order_catalog_synonym ocs,
      order_catalog oc,
      order_entry_format_parent oefp,
      oe_format_fields off,
      order_entry_fields oef,
      oe_field_meaning ofm
     PLAN (ocs
      WHERE ocs.synonym_id=synid)
      JOIN (oc
      WHERE oc.catalog_cd=ocs.catalog_cd)
      JOIN (oefp
      WHERE oefp.oe_format_id=ocs.oe_format_id)
      JOIN (off
      WHERE off.oe_format_id=ocs.oe_format_id
       AND off.action_type_cd=action_order_cd
       AND off.accept_flag IN (0, 1))
      JOIN (oef
      WHERE oef.oe_field_id=off.oe_field_id)
      JOIN (ofm
      WHERE ofm.oe_field_meaning_id=oef.oe_field_meaning_id
       AND ofm.oe_field_meaning IN ("STRENGTHDOSE", "STRENGTHDOSEUNIT", "VOLUMEDOSE",
      "VOLUMEDOSEUNIT", "FREETXTDOSE",
      "RXROUTE", "DRUGFORM"))
     ORDER BY off.group_seq, off.field_seq
     HEAD REPORT
      fieldcnt = 0, fields->catalog_cd = oc.catalog_cd, fields->mnemonic = ocs.mnemonic,
      fields->primary_disp = oc.primary_mnemonic, fields->synonym_id = ocs.synonym_id, fields->
      rx_mask = ocs.rx_mask,
      fields->orderable_type_flag = oc.orderable_type_flag, fields->format_name = oefp.oe_format_name
     DETAIL
      fieldcnt = (fieldcnt+ 1), stat = alterlist(fields->list,fieldcnt), fields->list[fieldcnt].
      code_set = oef.codeset,
      fields->list[fieldcnt].field_disp = oef.description, fields->list[fieldcnt].field_meaning = ofm
      .oe_field_meaning, fields->list[fieldcnt].field_type_flag = oef.field_type_flag,
      fields->list[fieldcnt].accept_flag = off.accept_flag
     WITH nocounter
    ;end select
    IF (fieldcnt=0)
     CALL text((soffrow+ 2),soffcol,"Error: Synonym does not have an OEF")
     CALL text((soffrow+ 4),soffcol,"Continue?:")
     CALL accept((soffrow+ 4),(soffcol+ 10),"A;CU"
      WHERE curaccept IN ("Y"))
     GO TO main_menu
    ENDIF
    WHILE (finished=0)
      CALL text((soffrow+ 2),soffcol,concat("OEF: ",fields->format_name))
      FOR (i = 1 TO size(fields->list,5))
       CALL text(((soffrow+ 7)+ i),soffcol,fields->list[i].field_disp)
       CALL text(((soffrow+ 7)+ i),(soffcol+ 57),evaluate(fields->list[i].accept_flag,0,"Required",
         "Optional"))
      ENDFOR
      CALL text((soffrow+ 7),soffcol,"Enter order entry details (Shift+F5 to select):")
      FOR (i = 1 TO size(fields->list,5))
       SET passed = 0
       WHILE (passed=0)
         CASE (fields->list[i].field_type_flag)
          OF 0:
           CALL accept(((soffrow+ 7)+ i),(soffcol+ 30),"X(25);C"," ")
           IF (cnvtupper(curaccept) != "QUIT")
            IF ((fields->list[i].accept_flag=1)
             AND trim(curaccept)="")
             SET passed = 1
            ELSEIF (trim(curaccept) > "")
             SET fields->list[i].value = trim(curaccept)
             SET passed = 1
            ENDIF
           ELSE
            GO TO main_menu
           ENDIF
          OF 2:
           CALL accept(((soffrow+ 7)+ i),(soffcol+ 30),"N(25);C")
           IF (cnvtupper(curaccept) != "QUIT")
            IF ((fields->list[i].accept_flag=1)
             AND trim(curaccept)="")
             SET passed = 1
            ELSEIF (trim(curaccept) > "")
             SET fields->list[i].value = trim(curaccept)
             SET passed = 1
            ENDIF
           ELSE
            GO TO main_menu
           ENDIF
          OF 6:
           SET promptmsg = build2(trim(fields->list[i].field_disp)," starts with:")
           SET help = promptmsg(value(promptmsg))
           SET help = pos(3,1,15,40)
           SET help =
           SELECT INTO "nl:"
            cv.display
            FROM code_value cv
            PLAN (cv
             WHERE (cv.code_set=fields->list[i].code_set)
              AND cnvtupper(cv.display) >= cnvtupper(curaccept)
              AND cv.active_ind=1)
            ORDER BY cnvtupper(cv.display)
            WITH nocounter
           ;end select
           CALL accept(((soffrow+ 7)+ i),(soffcol+ 30),"P(25);CP"," ")
           SET help = off
           CALL clear((soffrow+ 14),soffcol,numcols)
           IF (cnvtupper(curaccept) != "QUIT")
            IF ((fields->list[i].accept_flag=1)
             AND trim(curaccept)=null)
             SET passed = 1
            ELSE
             SET cvcnt = 0
             SELECT INTO "nl:"
              cv.code_value
              FROM code_value cv
              PLAN (cv
               WHERE (cv.code_set=fields->list[i].code_set)
                AND cv.display_key=cnvtalphanum(cnvtupper(trim(curaccept)))
                AND cnvtupper(cv.display)=cnvtupper(trim(curaccept))
                AND cv.active_ind=1)
              DETAIL
               cvcnt = (cvcnt+ 1), codevalue = cv.code_value
              WITH nocounter
             ;end select
             IF (cvcnt=1)
              SET fields->list[i].value = trim(cnvtstring(codevalue))
              SET passed = 1
             ELSEIF (cvcnt > 1)
              CALL text((soffrow+ 14),soffcol,build2(
                "WARNING: Multiple code values with same display found. Sending: ",trim(cnvtstring(
                  codevalue))))
              SET passed = 1
             ELSE
              CALL text((soffrow+ 14),soffcol,build2("No code value found with display ",trim(
                 curaccept)," on code set ",trim(cnvtstring(fields->list[i].code_set))))
             ENDIF
            ENDIF
           ELSE
            GO TO main_menu
           ENDIF
           IF (debug_ind=1)
            CALL addlogmsg("INFO","fields record after being populated in adhocOrderMode()")
            CALL echorecord(fields,logfilename,1)
           ENDIF
         ENDCASE
       ENDWHILE
      ENDFOR
      SET stat = alterlist(ord_sents->list,1)
      SET ord_sents->list[1].catalog_cd = fields->catalog_cd
      SET ord_sents->list[1].mnemonic = fields->mnemonic
      SET ord_sents->list[1].orderable_type_flag = fields->orderable_type_flag
      SET ord_sents->list[1].primary_disp = fields->primary_disp
      SET ord_sents->list[1].rx_mask = fields->rx_mask
      SET ord_sents->list[1].synonym_id = fields->synonym_id
      SET ord_sents->list[1].syn_oef = fields->format_name
      FOR (i = 1 TO size(fields->list,5))
        CASE (fields->list[i].field_meaning)
         OF "STRENGTHDOSE":
          SET ord_sents->list[1].strength = cnvtreal(fields->list[i].value)
         OF "STRENGTHDOSEUNIT":
          SET ord_sents->list[1].strength_unit_cd = cnvtreal(fields->list[i].value)
         OF "VOLUMEDOSE":
          SET ord_sents->list[1].volume = cnvtreal(fields->list[i].value)
         OF "VOLUMEDOSEUNIT":
          SET ord_sents->list[1].volume_unit_cd = cnvtreal(fields->list[i].value)
         OF "FREETXTDOSE":
          SET ord_sents->list[1].freetext_dose = fields->list[i].value
         OF "RXROUTE":
          SET ord_sents->list[1].route_cd = cnvtreal(fields->list[i].value)
         OF "DRUGFORM":
          SET ord_sents->list[1].form_cd = cnvtreal(fields->list[i].value)
        ENDCASE
      ENDFOR
      IF (debug_ind=1)
       CALL addlogmsg("INFO","ord_sents record after being populated in adhocOrderMode()")
       CALL echorecord(ord_sents,logfilename,1)
      ENDIF
      SET stat = loadrequestforordsent(1)
      IF (stat=1)
       IF ((ord_sents->list[1].items[1].item_id > 0))
        IF ((ord_sents->list[1].set_id > 0))
         CALL text((soffrow+ 3),soffcol,"IV Set:")
         CALL text((soffrow+ 3),(soffcol+ 8),substring(1,(numcols - 8),build2(trim(cnvtstring(
              ord_sents->list[1].set_id))," - ",substring(1,60,ord_sents->list[1].set_desc))))
        ELSE
         CALL text((soffrow+ 3),soffcol,"Item:")
         CALL text((soffrow+ 3),(soffcol+ 6),substring(1,(numcols - 6),build2(trim(cnvtstring(
              ord_sents->list[1].items[1].item_id))," - ",substring(1,60,ord_sents->list[1].items[1].
             item_desc))))
         CALL text((soffrow+ 5),soffcol,build2("QPD: ",cnvtstring(ord_sents->list[1].items[1].qpd,11,
            4)))
        ENDIF
       ELSE
        CALL text((soffrow+ 3),soffcol,"Item:")
        CALL text((soffrow+ 3),(soffcol+ 6),"None")
       ENDIF
       IF ((ord_sents->list[1].error_text=""))
        CALL text((soffrow+ 4),soffcol,"Method:")
        CALL text((soffrow+ 4),(soffcol+ 8),substring(1,(numcols - 8),ord_sents->list[1].items[1].
          assigned_by))
       ELSE
        CALL text((soffrow+ 4),soffcol,"Error:")
        CALL text((soffrow+ 4),(soffcol+ 8),substring(1,(numcols - 8),ord_sents->list[1].error_text))
       ENDIF
      ELSE
       CALL text((soffrow+ 3),soffcol,"An error occurred while processing the request")
      ENDIF
      CALL text(quesrow,soffcol,"(A)udit another adhoc order or (M)ain Menu:")
      CALL accept(quesrow,(soffcol+ 43),"A;CU","M"
       WHERE curaccept IN ("A", "M"))
      IF (curaccept="M")
       SET finished = 1
      ELSE
       SET finished = 0
       CALL clear((soffrow+ 3),soffcol,numcols)
       CALL clear((soffrow+ 4),soffcol,numcols)
       CALL clear((soffrow+ 5),soffcol,numcols)
       CALL clear((soffrow+ 8),(soffcol+ 30),(numcols - 30))
       CALL clear((soffrow+ 9),(soffcol+ 30),(numcols - 30))
       CALL clear((soffrow+ 10),(soffcol+ 30),(numcols - 30))
       CALL clear((soffrow+ 11),(soffcol+ 30),(numcols - 30))
       CALL clear((soffrow+ 12),(soffcol+ 30),(numcols - 30))
       CALL clear((soffrow+ 13),(soffcol+ 30),(numcols - 30))
       CALL clear((soffrow+ 14),(soffcol+ 30),(numcols - 30))
      ENDIF
    ENDWHILE
   ENDIF
   GO TO main_menu
 END ;Subroutine
 SUBROUTINE auditpowerplanmode(null)
   DECLARE auditpathwaycompid = f8 WITH protect
   DECLARE finished = i2 WITH protect
   SET outputfilename = build(cnvtlower(curdomain),"_powerplan_apa_results.csv")
   CALL clearscreen(null)
   SET stat = initrec(iv_sets)
   SET stat = initrec(ord_sents)
   SET checkallprimariesind = 0
   SET checkallivsetsind = 0
   SET checkallplansind = 0
   SET auditpathwaycompid = 0
   SET apacnt = 0
   IF (checkverificationreportlevel(null))
    IF (((facilitycd=0) OR (((nurseunitcd=0) OR (encountertypecd=0)) )) )
     CALL getpatientlocinfofromuser(null)
    ENDIF
    WHILE (auditpathwaycompid=0
     AND checkallplansind=0)
      CALL text(soffrow,soffcol,"Enter PowerPlan to audit or ALL (Shift+F5 to select):")
      SET help = promptmsg("PowerPlan starts with:")
      SET help = pos(3,1,15,80)
      SET help =
      SELECT INTO "nl:"
       powerplan = pc.description
       FROM pathway_catalog pc,
        pw_cat_flex pcf
       PLAN (pc
        WHERE pc.type_mean IN ("CAREPLAN", "PATHWAY")
         AND pc.description_key >= cnvtupper(curaccept)
         AND pc.active_ind=1
         AND pc.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
         AND pc.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
        JOIN (pcf
        WHERE pcf.pathway_catalog_id=pc.pathway_catalog_id
         AND pcf.parent_entity_name="CODE_VALUE"
         AND pcf.parent_entity_id IN (0, facilitycd))
       ORDER BY pc.description_key
      ;end select
      CALL accept((soffrow+ 1),(soffcol+ 3),"P(70);CP")
      SET auditplandisp = trim(cnvtupper(curaccept))
      SET help = off
      IF (cnvtupper(curaccept)="QUIT")
       GO TO main_menu
      ELSEIF (cnvtupper(curaccept)="ALL")
       SET checkallplansind = 1
       CALL text((soffrow+ 2),soffcol,
        "Finding all PowerPlan order sentences that are available for the facility")
       SET totalsentcnt = getordersents(search_by_all_powerplan,null)
       CALL clear((soffrow+ 2),soffcol,numcols)
       CALL text((soffrow+ 2),soffcol,
        "Processing all order sentences may take a significant amount of time")
       CALL text((soffrow+ 3),soffcol,build2("Count of order sentences: ",trim(cnvtstring(
           totalsentcnt))))
       CALL text((soffrow+ 4),soffcol,"Continue?:")
       CALL accept((soffrow+ 4),(soffcol+ 10),"A;CU"
        WHERE curaccept IN ("Y", "N"))
       IF (curaccept="N")
        GO TO main_menu
       ELSE
        CALL clear((soffrow+ 2),soffcol,numcols)
        CALL clear((soffrow+ 3),soffcol,numcols)
        CALL clear((soffrow+ 4),soffcol,numcols)
       ENDIF
      ELSE
       SET auditpathwaycompid = 0
       SELECT INTO "nl:"
        pc.description, pc.pathway_catalog_id
        FROM pathway_catalog pc,
         pw_cat_flex pcf
        PLAN (pc
         WHERE pc.type_mean IN ("CAREPLAN", "PATHWAY")
          AND pc.description_key=auditplandisp
          AND pc.active_ind=1
          AND pc.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
          AND pc.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
         JOIN (pcf
         WHERE pcf.pathway_catalog_id=pc.pathway_catalog_id
          AND pcf.parent_entity_name="CODE_VALUE"
          AND pcf.parent_entity_id IN (0, facilitycd))
        DETAIL
         auditpathwaycompid = pc.pathway_catalog_id
        WITH nocounter
       ;end select
       IF (auditpathwaycompid=0)
        CALL text((soffrow+ 2),soffcol,"No PowerPlan found! Enter valid PowerPlan")
       ELSE
        CALL clear((soffrow+ 2),soffcol,numcols)
        SET totalsentcnt = getordersents(search_by_powerplan,auditpathwaycompid)
       ENDIF
      ENDIF
      IF (totalsentcnt > 0)
       CALL text((soffrow+ 2),soffcol,"Processing all order sentences...")
       SET stat = loadrequest(null)
       IF (stat=0)
        CALL text((soffrow+ 3),soffcol,build("Error:",statusstr))
        CALL text(quesrow,soffcol,"Continue?:")
        CALL accept(quesrow,(soffcol+ 10),"A;CUS","Y"
         WHERE curaccept IN ("Y"))
       ELSE
        IF (size(iv_sets->set_list,5) > 0)
         SET stat = loadrequestforivset(null)
         IF (stat=0)
          CALL text((soffrow+ 3),soffcol,build("Error:",statusstr))
          CALL text(quesrow,soffcol,"Continue?:")
          CALL accept(quesrow,(soffcol+ 10),"A;CUS","Y"
           WHERE curaccept IN ("Y"))
          GO TO main_menu
         ENDIF
        ENDIF
        CALL text((soffrow+ 2),(soffcol+ 33),"done")
        WHILE (finished=0)
          CALL text((soffrow+ 3),soffcol,"Enter filename to create in CCLUSERDIR (or MINE):")
          CALL accept((soffrow+ 4),(soffcol+ 1),"P(74);C",outputfilename)
          IF (((cnvtupper(curaccept)="*.CSV") OR (cnvtupper(curaccept)="MINE")) )
           SET outputfilename = trim(cnvtlower(curaccept))
           CALL clear((soffrow+ 5),soffcol,numcols)
           CALL createoutputfile(outputfilename)
           IF (outputfilename != "mine")
            CALL text((soffrow+ 5),soffcol,"The file has successfully been created in CCLUSERDIR")
            CALL text((soffrow+ 6),soffcol,"Do you want to email the file?:")
            CALL accept((soffrow+ 6),(soffcol+ 31),"A;CU","Y"
             WHERE curaccept IN ("Y", "N"))
            IF (curaccept="Y")
             CALL text((soffrow+ 7),soffcol,"Enter recepient's email address:")
             CALL accept((soffrow+ 8),(soffcol+ 1),"P(74);C",gethnaemail(null)
              WHERE trim(curaccept) > " ")
             CALL createsummaryreportinfo(null)
             IF (emailfile(curaccept,from_str,subjectstr,bodystr,outputfilename))
              CALL text((soffrow+ 14),soffcol,"Emailed file successfully")
             ELSE
              CALL text((soffrow+ 14),soffcol,"Email failed. Manually grab file from CCLUSERDIR")
             ENDIF
             CALL text(quesrow,soffcol,"Continue?:")
             CALL accept(quesrow,(soffcol+ 10),"A;CU","Y"
              WHERE curaccept IN ("Y"))
             SET finished = 1
            ELSE
             SET finished = 1
             SET auditpathwaycompid = 1
            ENDIF
           ELSE
            GO TO main_menu
           ENDIF
          ELSE
           CALL text((soffrow+ 2),soffcol,"Output file must be MINE or have .csv extension")
          ENDIF
        ENDWHILE
       ENDIF
      ELSE
       CALL text((soffrow+ 3),soffcol,"No sentences found within PowerPlan")
       CALL text(quesrow,soffcol,"Continue?:")
       CALL accept(quesrow,(soffcol+ 10),"A;CUS","Y"
        WHERE curaccept IN ("Y"))
      ENDIF
    ENDWHILE
   ENDIF
   GO TO main_menu
 END ;Subroutine
 SUBROUTINE singlesentencemode(null)
   DECLARE synid = f8 WITH protect
   DECLARE syndisp = vc WITH protect
   DECLARE sentcnt = i4 WITH protect
   DECLARE syncnt = i4 WITH protect
   DECLARE idx = i4 WITH protect
   RECORD audit_syns(
     1 list[*]
       2 synonym_id = f8
       2 mnemonic = c60
       2 mnemonic_type_disp = c5
   ) WITH protect
   CALL clearscreen(null)
   SET stat = initrec(iv_sets)
   SET stat = initrec(ord_sents)
   IF (checkverificationreportlevel(null))
    IF (((facilitycd=0) OR (((nurseunitcd=0) OR (encountertypecd=0)) )) )
     CALL getpatientlocinfofromuser(null)
    ENDIF
    SET synid = getsynonymfromuser(null)
    SET totalsentcnt = getordersents(search_by_syn,synid)
    SET message = window
    SET maxrows = 7
    CALL drawscrollbox((soffrow+ 6),(soffcol+ 1),numrows,(numcols+ 1))
    CALL text((soffrow+ 2),soffcol,"Select an order sentence to test")
    SET cnt = 0
    WHILE (cnt < maxrows
     AND cnt < size(ord_sents->list,5))
      SET cnt = (cnt+ 1)
      SET rowstr = build2(cnvtstring(cnt,2,0,r)," ",substring(1,60,ord_sents->list[cnt].os_disp_line)
       )
      CALL scrolltext(cnt,rowstr)
    ENDWHILE
    SET cnt = 1
    SET arow = 1
    SET pick = 0
    WHILE (pick=0)
      CALL text(quesrow,soffcol,"(S)elect or (M)ain Menu?:")
      CALL accept(quesrow,(soffcol+ 25),"A;CUS","S"
       WHERE curaccept IN ("S", "M"))
      CASE (curscroll)
       OF 0:
        IF (curaccept="S")
         IF (size(ord_sents->list,5) > 0)
          CALL clear((soffrow+ 2),soffcol,numcols)
          CALL clear((soffrow+ 3),soffcol,numcols)
          CALL clear((soffrow+ 4),soffcol,numcols)
          CALL clear((soffrow+ 5),soffcol,numcols)
          CALL text((soffrow+ 2),soffcol,"Sentence:")
          CALL text((soffrow+ 2),(soffcol+ 10),substring(1,65,ord_sents->list[cnt].os_disp_line))
          SET stat = loadrequestforordsent(cnt)
          IF (debug_ind=1)
           CALL addlogmsg("INFO",build("stat from loadRequestForOrdSent() = ",stat))
           CALL addlogmsg("INFO","Product assignment complete. Displaying results")
           CALL addlogmsg("INFO","****************************************************")
          ENDIF
          IF (stat=1)
           IF ((ord_sents->list[cnt].items[1].item_id > 0))
            IF ((ord_sents->list[cnt].set_id > 0))
             CALL text((soffrow+ 3),soffcol,"IV Set:")
             CALL text((soffrow+ 3),(soffcol+ 8),substring(1,(numcols - 8),build2(trim(cnvtstring(
                  ord_sents->list[cnt].set_id))," - ",substring(1,60,ord_sents->list[cnt].set_desc)))
              )
             CALL text((soffrow+ 5),(soffcol+ 30),build2("Price: ",trim(format(cnvtstring(ord_sents->
                  list[cnt].price,11,2),"#######.##;$,"))))
             CALL text((soffrow+ 5),(soffcol+ 60),build2("Cost: ",trim(format(cnvtstring(ord_sents->
                  list[cnt].cost,11,2),"#######.##;$,"))))
            ELSE
             CALL text((soffrow+ 3),soffcol,"Item:")
             CALL text((soffrow+ 3),(soffcol+ 6),substring(1,(numcols - 6),build2(trim(cnvtstring(
                  ord_sents->list[cnt].items[1].item_id))," - ",substring(1,60,ord_sents->list[cnt].
                 items[1].item_desc))))
             CALL text((soffrow+ 5),soffcol,build2("QPD: ",trim(cnvtstring(ord_sents->list[cnt].
                 items[1].qpd,11,4))))
             CALL text((soffrow+ 5),(soffcol+ 30),build2("Price: ",trim(format(cnvtstring(ord_sents->
                  list[cnt].price,11,2),"#######.##;$,"))))
             CALL text((soffrow+ 5),(soffcol+ 60),build2("Cost: ",trim(format(cnvtstring(ord_sents->
                  list[cnt].cost,11,2),"#######.##;$,"))))
            ENDIF
           ELSE
            CALL text((soffrow+ 3),soffcol,"Item:")
            CALL text((soffrow+ 3),(soffcol+ 6),"None")
           ENDIF
           IF ((ord_sents->list[cnt].error_text=""))
            CALL text((soffrow+ 4),soffcol,"Method:")
            CALL text((soffrow+ 4),(soffcol+ 8),substring(1,(numcols - 8),ord_sents->list[cnt].items[
              1].assigned_by))
           ELSE
            CALL text((soffrow+ 4),soffcol,"Error:")
            CALL text((soffrow+ 4),(soffcol+ 8),substring(1,(numcols - 8),ord_sents->list[cnt].
              error_text))
           ENDIF
          ELSE
           CALL text((soffrow+ 3),soffcol,"An error occurred while processing the request")
          ENDIF
         ELSE
          CALL clear((soffrow+ 2),soffcol,numcols)
          CALL text((soffrow+ 2),soffcol,"No sentences found for synonym")
         ENDIF
        ELSE
         SET pick = 1
        ENDIF
       OF 1:
        IF (cnt < size(ord_sents->list,5))
         SET cnt = (cnt+ 1)
         SET rowstr = build2(cnvtstring(cnt,2,0,r)," ",substring(1,60,ord_sents->list[cnt].
           os_disp_line))
         CALL downarrow(rowstr)
        ENDIF
       OF 2:
        IF (cnt > 1)
         SET cnt = (cnt - 1)
         SET rowstr = build2(cnvtstring(cnt,2,0,r)," ",substring(1,60,ord_sents->list[cnt].
           os_disp_line))
         CALL uparrow(rowstr)
        ENDIF
      ENDCASE
    ENDWHILE
   ENDIF
   GO TO main_menu
 END ;Subroutine
 SUBROUTINE auditprimarymode(null)
   DECLARE auditcatcd = f8 WITH protect
   DECLARE finished = i2 WITH protect
   SET outputfilename = build(cnvtlower(curdomain),"_primary_apa_results.csv")
   CALL clearscreen(null)
   SET stat = initrec(iv_sets)
   SET stat = initrec(ord_sents)
   SET checkallprimariesind = 0
   SET checkallivsetsind = 0
   SET checkallplansind = 0
   SET apacnt = 0
   SET auditcatcd = 0
   IF (checkverificationreportlevel(null))
    IF (((facilitycd=0) OR (((nurseunitcd=0) OR (encountertypecd=0)) )) )
     CALL getpatientlocinfofromuser(null)
    ENDIF
    WHILE (auditcatcd=0
     AND checkallprimariesind=0)
      CALL text(soffrow,soffcol,"Enter primary mnemonic to audit or ALL (Shift+F5 to select):")
      SET help = promptmsg("Primary starts with:")
      SET help = pos(3,1,15,80)
      SET help =
      SELECT INTO "nl:"
       primary = oc.primary_mnemonic
       FROM order_catalog oc
       PLAN (oc
        WHERE oc.catalog_type_cd=pharm_cat_cd
         AND oc.orderable_type_flag IN (0, 1)
         AND oc.active_ind=1
         AND cnvtupper(oc.primary_mnemonic) >= cnvtupper(curaccept))
       ORDER BY cnvtupper(oc.primary_mnemonic)
      ;end select
      CALL accept((soffrow+ 1),(soffcol+ 3),"P(70);CP")
      SET auditcatdisp = trim(cnvtupper(curaccept))
      SET help = off
      IF (cnvtupper(curaccept)="QUIT")
       GO TO main_menu
      ELSEIF (cnvtupper(curaccept)="ALL")
       SET checkallprimariesind = 1
       CALL text((soffrow+ 2),soffcol,
        "Finding all synonym order sentences that are available for the facility")
       SET totalsentcnt = getordersents(search_by_all_primary,null)
       CALL clear((soffrow+ 2),soffcol,numcols)
       CALL text((soffrow+ 2),soffcol,
        "Processing all order sentences may take a significant amount of time")
       CALL text((soffrow+ 3),soffcol,build2("Count of order sentences: ",trim(cnvtstring(
           totalsentcnt))))
       CALL text((soffrow+ 4),soffcol,"Continue?:")
       CALL accept((soffrow+ 4),(soffcol+ 10),"A;CU"
        WHERE curaccept IN ("Y", "N"))
       IF (curaccept="N")
        GO TO main_menu
       ELSE
        CALL clear((soffrow+ 2),soffcol,numcols)
        CALL clear((soffrow+ 3),soffcol,numcols)
        CALL clear((soffrow+ 4),soffcol,numcols)
       ENDIF
      ELSE
       SELECT INTO "nl:"
        oc.primary_mnemonic, oc.catalog_cd
        FROM order_catalog oc
        PLAN (oc
         WHERE oc.catalog_type_cd=pharm_cat_cd
          AND oc.orderable_type_flag IN (0, 1)
          AND oc.active_ind=1
          AND cnvtupper(oc.primary_mnemonic)=auditcatdisp)
        DETAIL
         auditcatcd = oc.catalog_cd
        WITH nocounter
       ;end select
       IF (curqual=0)
        CALL text((soffrow+ 2),soffcol,"No primary found! Enter valid pharmacy primary")
       ELSE
        SET totalsentcnt = getordersents(search_by_primary,auditcatcd)
        CALL clear((soffrow+ 2),soffcol,numcols)
       ENDIF
      ENDIF
    ENDWHILE
    IF (totalsentcnt > 0)
     CALL text((soffrow+ 2),soffcol,"Processing all order sentences...")
     SET stat = loadrequest(null)
     IF (stat=0)
      CALL text((soffrow+ 3),soffcol,build("Error:",statusstr))
      CALL text(quesrow,soffcol,"Continue?:")
      CALL accept(quesrow,(soffcol+ 10),"A;CUS","Y"
       WHERE curaccept IN ("Y"))
     ELSE
      CALL text((soffrow+ 2),(soffcol+ 33),"done")
      WHILE (finished=0)
        CALL text((soffrow+ 3),soffcol,"Enter filename to create in CCLUSERDIR (or MINE):")
        CALL accept((soffrow+ 4),(soffcol+ 1),"P(74);C",outputfilename)
        IF (((cnvtupper(curaccept)="*.CSV") OR (cnvtupper(curaccept)="MINE")) )
         SET outputfilename = trim(cnvtlower(curaccept))
         CALL clear((soffrow+ 5),soffcol,numcols)
         CALL createoutputfile(outputfilename)
         IF (outputfilename != "mine")
          CALL text((soffrow+ 5),soffcol,"The file has successfully been created in CCLUSERDIR")
          CALL text((soffrow+ 6),soffcol,"Do you want to email the file?:")
          CALL accept((soffrow+ 6),(soffcol+ 31),"A;CU","Y"
           WHERE curaccept IN ("Y", "N"))
          IF (curaccept="Y")
           CALL text((soffrow+ 7),soffcol,"Enter recepient's email address:")
           CALL accept((soffrow+ 8),(soffcol+ 1),"P(74);C",gethnaemail(null)
            WHERE trim(curaccept) > " ")
           CALL createsummaryreportinfo(null)
           IF (emailfile(curaccept,from_str,subjectstr,bodystr,outputfilename))
            CALL text((soffrow+ 14),soffcol,"Emailed file successfully")
           ELSE
            CALL text((soffrow+ 14),soffcol,"Email failed. Manually grab file from CCLUSERDIR")
           ENDIF
           CALL text(quesrow,soffcol,"Continue?:")
           CALL accept(quesrow,(soffcol+ 10),"A;CU","Y"
            WHERE curaccept IN ("Y"))
           SET finished = 1
          ELSE
           SET finished = 1
          ENDIF
         ELSE
          GO TO main_menu
         ENDIF
        ELSE
         CALL text((soffrow+ 2),soffcol,"Output file must be MINE or have .csv extension")
        ENDIF
      ENDWHILE
     ENDIF
    ELSE
     CALL text((soffrow+ 3),soffcol,"No sentences found for primary")
     CALL text(quesrow,soffcol,"Continue?:")
     CALL accept(quesrow,(soffcol+ 10),"A;CUS","Y"
      WHERE curaccept IN ("Y"))
    ENDIF
   ENDIF
   GO TO main_menu
 END ;Subroutine
 SUBROUTINE getpatientweightfromuser(null)
   CALL text((soffrow+ 4),soffcol,"Enter patient's weight in kg:")
   CALL accept((soffrow+ 4),(soffcol+ 30),"9(6);"
    WHERE curaccept > 0.0)
   SET patientweight = curaccept
   CALL clear((soffrow+ 3),soffcol,numcols)
   CALL clear((soffrow+ 4),soffcol,numcols)
 END ;Subroutine
 SUBROUTINE getpatientlocinfofromuser(null)
   DECLARE facility_group_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",222,
     "FACILITY"))
   DECLARE building_group_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",222,
     "BUILDING"))
   DECLARE nurseunitdisp = vc WITH protect
   DECLARE encountertypedisp = vc WITH protect
   CALL clearscreen(null)
   SET facilitycd = 0
   SET nurseunitcd = 0
   SET encountertypecd = 0
   CALL text(soffrow,soffcol,
    "Fill out the following patient demographic info. (Shift + F5 to select)")
   WHILE (facilitycd=0)
     CALL text((soffrow+ 1),soffcol,"Facility display:")
     SET help = promptmsg("Facility display starts with:")
     SET help = pos(3,1,15,80)
     SET help =
     SELECT INTO "nl:"
      facility = cv.display
      FROM code_value cv
      PLAN (cv
       WHERE cv.code_set=220
        AND cv.active_ind=1
        AND cv.cdf_meaning="FACILITY"
        AND cnvtupper(cv.display) >= cnvtupper(curaccept))
      ORDER BY cv.display_key
     ;end select
     CALL accept((soffrow+ 1),(soffcol+ 20),"P(40);CP")
     SET facilitydisp = trim(cnvtupper(curaccept))
     SET help = off
     IF (cnvtupper(curaccept)="QUIT")
      GO TO main_menu
     ENDIF
     SELECT INTO "nl:"
      cv.code_value
      FROM code_value cv
      WHERE cv.code_set=220
       AND cv.active_ind=1
       AND cv.cdf_meaning="FACILITY"
       AND trim(cnvtupper(cv.display))=cnvtupper(facilitydisp)
      DETAIL
       facilitycd = cv.code_value
      WITH nocounter
     ;end select
     IF (curqual != 1)
      CALL text((soffrow+ 2),soffcol,"No facility found! Enter a valid facility display value.")
     ELSE
      CALL clear((soffrow+ 2),soffcol,numcols)
     ENDIF
   ENDWHILE
   WHILE (nurseunitcd=0)
     CALL text((soffrow+ 2),soffcol,"Nurse unit display:")
     SET help = promptmsg("Nurse unit display starts with:")
     SET help = pos(3,1,15,80)
     SET help =
     SELECT INTO "nl:"
      nurse_unit = cv.display
      FROM code_value cv,
       location_group lg,
       location_group lg2
      PLAN (cv
       WHERE cv.code_set=220
        AND cv.active_ind=1
        AND cv.cdf_meaning IN ("AMBULATORY", "ANCILSURG", "NURSEUNIT", "WAITROOM")
        AND cnvtupper(cv.display) >= cnvtupper(curaccept))
       JOIN (lg
       WHERE lg.child_loc_cd=cv.code_value
        AND lg.root_loc_cd=0
        AND lg.location_group_type_cd=building_group_type_cd)
       JOIN (lg2
       WHERE lg2.child_loc_cd=lg.parent_loc_cd
        AND lg2.root_loc_cd=0
        AND lg2.location_group_type_cd=facility_group_type_cd
        AND lg2.parent_loc_cd=facilitycd)
      ORDER BY cv.display_key
     ;end select
     CALL accept((soffrow+ 2),(soffcol+ 20),"P(40);CP")
     SET nurseunitdisp = trim(cnvtupper(curaccept))
     SET help = off
     IF (cnvtupper(curaccept)="QUIT")
      GO TO main_menu
     ENDIF
     SELECT INTO "nl:"
      cv.code_value
      FROM code_value cv,
       location_group lg,
       location_group lg2
      PLAN (cv
       WHERE cv.code_set=220
        AND cv.active_ind=1
        AND cv.cdf_meaning IN ("AMBULATORY", "ANCILSURG", "NURSEUNIT", "WAITROOM")
        AND trim(cnvtupper(cv.display))=cnvtupper(nurseunitdisp))
       JOIN (lg
       WHERE lg.child_loc_cd=cv.code_value
        AND lg.root_loc_cd=0
        AND lg.location_group_type_cd=building_group_type_cd)
       JOIN (lg2
       WHERE lg2.child_loc_cd=lg.parent_loc_cd
        AND lg2.root_loc_cd=0
        AND lg2.location_group_type_cd=facility_group_type_cd
        AND lg2.parent_loc_cd=facilitycd)
      DETAIL
       nurseunitcd = cv.code_value
      WITH nocounter
     ;end select
     IF (curqual != 1)
      CALL text((soffrow+ 3),soffcol,
       "No nurse unit found! Enter a valid unit display value for the facility.")
     ELSE
      CALL clear((soffrow+ 3),soffcol,numcols)
     ENDIF
   ENDWHILE
   WHILE (encountertypecd=0)
     CALL text((soffrow+ 3),soffcol,"Encounter type:")
     SET help = promptmsg("Encounter type display starts with:")
     SET help = pos(3,1,15,80)
     SET help =
     SELECT INTO "nl:"
      encounter_type = cv.display
      FROM code_value cv
      PLAN (cv
       WHERE cv.code_set=71
        AND cv.active_ind=1
        AND cnvtupper(cv.display) >= cnvtupper(curaccept))
      ORDER BY cv.display_key
     ;end select
     CALL accept((soffrow+ 3),(soffcol+ 20),"P(40);CP","Inpatient")
     SET encountertypedisp = trim(cnvtupper(curaccept))
     SET help = off
     IF (cnvtupper(curaccept)="QUIT")
      GO TO main_menu
     ENDIF
     SELECT INTO "nl:"
      cv.code_value
      FROM code_value cv
      WHERE cv.code_set=71
       AND cv.active_ind=1
       AND trim(cnvtupper(cv.display))=cnvtupper(encountertypedisp)
      DETAIL
       encountertypecd = cv.code_value
      WITH nocounter
     ;end select
     IF (curqual != 1)
      CALL text((soffrow+ 4),soffcol,"Enter a valid encounter type display value from code set 71.")
     ELSE
      CALL clear((soffrow+ 4),soffcol,numcols)
     ENDIF
   ENDWHILE
   CALL clearscreen(null)
 END ;Subroutine
 SUBROUTINE createoutputfile(filename)
   DECLARE rowcnt = i4 WITH protect
   DECLARE rateind = i2 WITH protect
   DECLARE virtualviewind = i2 WITH protect
   DECLARE i = i4 WITH protect
   DECLARE j = i4 WITH protect
   DECLARE cnt = i4 WITH protect
   DECLARE errortext = vc WITH protect
   RECORD output_rec(
     1 list[*]
       2 iv_set_ind = i2
       2 powerplan = vc
       2 clinical_cat = vc
       2 sub_clinical_cat = vc
       2 synonym_type = vc
       2 synonym = vc
       2 synonym_oef = vc
       2 rx_mask = vc
       2 syn_virtual_view = vc
       2 order_sentence = vc
       2 required_fields_missing = vc
       2 error_message = vc
       2 assignment_type = vc
       2 iv_set_desc = vc
       2 item_desc = vc
       2 item_qpd = vc
       2 order_price = vc
       2 order_cost = vc
       2 pathway_catalog_id = vc
       2 synonym_id = vc
       2 order_sent_id = vc
       2 iv_set_id = vc
       2 item_id = vc
   ) WITH protect
   SET builderrorcnt = 0
   FOR (cnt = 1 TO size(ord_sents->list,5))
     SET errortext = ord_sents->list[cnt].error_text
     IF ((ord_sents->list[cnt].syn_oe_format_id=0))
      SET builderrorcnt = (builderrorcnt+ 1)
      SET errortext = build2(errortext,"Synonym missing OEF. ")
     ENDIF
     IF ((ord_sents->list[cnt].rx_mask=0))
      SET builderrorcnt = (builderrorcnt+ 1)
      SET errortext = build2(errortext,"Synonym missing rx mask. ")
     ENDIF
     IF ((ord_sents->list[cnt].os_oe_format_id > 0)
      AND (ord_sents->list[cnt].syn_oe_format_id > 0)
      AND (ord_sents->list[cnt].os_oe_format_id != ord_sents->list[cnt].syn_oe_format_id))
      SET builderrorcnt = (builderrorcnt+ 1)
      SET errortext = build2(errortext,"Sentence OEF does not match synonym OEF. ")
     ENDIF
     IF ((ord_sents->list[cnt].route_mask_mismatch_ind=1)
      AND (ord_sents->list[cnt].rx_mask > 0))
      SET builderrorcnt = (builderrorcnt+ 1)
      SET errortext = build2(errortext,"Route's order type setting does not match rx mask. ")
     ENDIF
     IF (programmode=powerplan_mode)
      IF ((ord_sents->list[cnt].mnemonic_type_cd IN (syn_type_y, syn_type_z, syn_type_rx)))
       SET builderrorcnt = (builderrorcnt+ 1)
       SET errortext = build2(errortext,"Type of synonym is invalid for a PowerPlan. ")
      ENDIF
      IF ((ord_sents->list[cnt].synonym_vv_fac=- (1)))
       SET builderrorcnt = (builderrorcnt+ 1)
       SET errortext = build2(errortext,
        "Synonym is virtual viewed off, it will not be orderable from the PowerPlan. ")
      ENDIF
     ENDIF
     SET ord_sents->list[cnt].error_text = errortext
   ENDFOR
   FOR (i = 1 TO size(iv_sets->set_list,5))
     SET virtualviewind = 0
     FOR (j = 1 TO size(iv_sets->set_list[i].syn_list,5))
       IF ((iv_sets->set_list[i].syn_list[j].synonym_vv_fac >= 0))
        SET virtualviewind = 1
       ENDIF
     ENDFOR
     IF (virtualviewind=0)
      FOR (j = 1 TO size(iv_sets->set_list[i].syn_list,5))
        SET builderrorcnt = (builderrorcnt+ 1)
        SET errortext = iv_sets->set_list[i].syn_list[j].error_text
        SET iv_sets->set_list[i].syn_list[j].error_text = build2(errortext,
         "All synonyms in IV set are virtual viewed off. It will not be searchable in PowerChart. ")
      ENDFOR
     ENDIF
   ENDFOR
   FOR (i = 1 TO size(iv_sets->set_list,5))
     IF ((iv_sets->set_list[i].med_order_type_cd=iv_type_cd))
      IF ((iv_sets->set_list[i].syn_list[1].order_sentence_id > 0))
       IF ((iv_sets->set_list[i].syn_list[1].volume=0))
        SET missingdetailcnt = (missingdetailcnt+ 1)
        SET errortext = iv_sets->set_list[i].syn_list[1].missing_field_text
        IF (errortext="")
         SET iv_sets->set_list[i].syn_list[1].missing_field_text =
         "Sentence is missing a Volume Dose"
        ELSE
         SET iv_sets->set_list[i].syn_list[1].missing_field_text = build2(errortext,", Volume Dose")
        ENDIF
       ENDIF
       IF ((iv_sets->set_list[i].syn_list[1].rate=0)
        AND (iv_sets->set_list[i].syn_list[1].infuse_over=0)
        AND (iv_sets->set_list[i].syn_list[1].freetext_rate=""))
        SET rateind = 0
       ELSE
        SET rateind = 1
       ENDIF
       IF (rateind=0)
        FOR (j = 1 TO size(iv_sets->set_list[i].syn_list,5))
          IF ((iv_sets->set_list[i].syn_list[j].normalized_rate > 0))
           SET rateind = 1
          ENDIF
        ENDFOR
        IF (rateind=0)
         SET missingdetailcnt = (missingdetailcnt+ 1)
         SET errortext = iv_sets->set_list[i].syn_list[1].missing_field_text
         IF (errortext="")
          SET iv_sets->set_list[i].syn_list[1].missing_field_text =
          "Sentence is missing a Rate and Infuse Over"
         ELSE
          SET iv_sets->set_list[i].syn_list[1].missing_field_text = build2(errortext,
           ", Rate and Infuse Over")
         ENDIF
        ENDIF
       ENDIF
      ENDIF
      FOR (j = 2 TO size(iv_sets->set_list[i].syn_list,5))
        IF ((iv_sets->set_list[i].syn_list[j].order_sentence_id > 0))
         IF ((iv_sets->set_list[i].syn_list[j].volume=0)
          AND (iv_sets->set_list[i].syn_list[j].strength=0))
          SET missingdetailcnt = (missingdetailcnt+ 1)
          SET iv_sets->set_list[i].syn_list[j].missing_field_text = "Sentence is missing a Dose"
         ENDIF
        ENDIF
      ENDFOR
     ELSE
      IF ((iv_sets->set_list[i].syn_list[1].order_sentence_id > 0))
       IF ((((iv_sets->set_list[i].syn_list[1].volume=0)
        AND (iv_sets->set_list[i].syn_list[1].strength=0)) OR ((iv_sets->set_list[i].syn_list[1].
       volume_unit_cd=0)
        AND (iv_sets->set_list[i].syn_list[1].strength_unit_cd=0))) )
        SET missingdetailcnt = (missingdetailcnt+ 1)
        SET errortext = iv_sets->set_list[i].syn_list[1].missing_field_text
        IF (errortext="")
         SET iv_sets->set_list[i].syn_list[1].missing_field_text = "Sentence is missing a Dose"
        ELSE
         SET iv_sets->set_list[i].syn_list[1].missing_field_text = build2(errortext,", Dose")
        ENDIF
       ENDIF
       IF ((iv_sets->set_list[i].syn_list[1].rate=0)
        AND (iv_sets->set_list[i].syn_list[1].infuse_over=0))
        SET missingdetailcnt = (missingdetailcnt+ 1)
        SET errortext = iv_sets->set_list[i].syn_list[1].missing_field_text
        IF (errortext="")
         SET iv_sets->set_list[i].syn_list[1].missing_field_text =
         "Sentence is missing a Rate and Infuse Over"
        ELSE
         SET iv_sets->set_list[i].syn_list[1].missing_field_text = build2(errortext,
          ", Rate and Infuse Over")
        ENDIF
       ENDIF
       IF ((iv_sets->set_list[i].syn_list[1].frequency_cd=0))
        SET missingdetailcnt = (missingdetailcnt+ 1)
        SET errortext = iv_sets->set_list[i].syn_list[1].missing_field_text
        IF (errortext="")
         SET iv_sets->set_list[i].syn_list[1].missing_field_text = "Sentence is missing a Frequency"
        ELSE
         SET iv_sets->set_list[i].syn_list[1].missing_field_text = build2(errortext,", Frequency")
        ENDIF
       ENDIF
       IF ((iv_sets->set_list[i].route_cd=0))
        SET missingdetailcnt = (missingdetailcnt+ 1)
        SET errortext = iv_sets->set_list[i].syn_list[1].missing_field_text
        IF (errortext="")
         SET iv_sets->set_list[i].syn_list[1].missing_field_text = "Sentence is missing a Route"
        ELSE
         SET iv_sets->set_list[i].syn_list[1].missing_field_text = build2(errortext,", Route")
        ENDIF
       ENDIF
       FOR (j = 2 TO size(iv_sets->set_list[i].syn_list,5))
         IF ((iv_sets->set_list[i].syn_list[j].order_sentence_id > 0))
          IF ((((iv_sets->set_list[i].syn_list[j].volume=0)
           AND (iv_sets->set_list[i].syn_list[j].strength=0)) OR ((iv_sets->set_list[i].syn_list[j].
          volume_unit_cd=0)
           AND (iv_sets->set_list[i].syn_list[j].strength_unit_cd=0))) )
           SET missingdetailcnt = (missingdetailcnt+ 1)
           SET iv_sets->set_list[i].syn_list[j].missing_field_text = "Sentence is missing a Dose"
          ENDIF
         ENDIF
       ENDFOR
      ENDIF
     ENDIF
   ENDFOR
   IF (programmode=primary_mode)
    SELECT INTO value(filename)
     primary_mnemonic = substring(1,100,ord_sents->list[d1.seq].primary_disp), synonym_type =
     substring(1,100,uar_get_code_display(ord_sents->list[d1.seq].mnemonic_type_cd)), synonym =
     substring(1,100,ord_sents->list[d1.seq].mnemonic),
     synonym_oef = substring(1,100,ord_sents->list[d1.seq].syn_oef), rx_mask = ord_sents->list[d1.seq
     ].rx_mask, syn_virtual_view = substring(1,100,evaluate(ord_sents->list[d1.seq].synonym_vv_fac,
       0.0,"All",uar_get_code_display(ord_sents->list[d1.seq].synonym_vv_fac))),
     order_sentence = substring(1,200,ord_sents->list[d1.seq].os_disp_line), required_fields_missing
      = substring(1,1000,ord_sents->list[d1.seq].missing_field_text), error_message = substring(1,
      1000,ord_sents->list[d1.seq].error_text),
     ord_sent_virtual_view =
     IF ((ord_sents->list[d1.seq].os_oe_format_id > 0)) substring(1,100,evaluate(ord_sents->list[d1
        .seq].os_vv_fac,0.0,"All",uar_get_code_display(ord_sents->list[d1.seq].os_vv_fac)))
     ELSE "None"
     ENDIF
     , assignment_type = trim(substring(1,200,ord_sents->list[d1.seq].items[d2.seq].assigned_by)),
     iv_set_desc = trim(substring(1,100,ord_sents->list[d1.seq].set_desc)),
     item_desc = substring(1,100,ord_sents->list[d1.seq].items[d2.seq].item_desc), item_qpd =
     ord_sents->list[d1.seq].items[d2.seq].qpd, order_price = ord_sents->list[d1.seq].price
     "#######.##;$,",
     order_cost = ord_sents->list[d1.seq].cost"#######.##;$,", catalog_cd = ord_sents->list[d1.seq].
     catalog_cd, synonym_id = ord_sents->list[d1.seq].synonym_id,
     order_sent_id = ord_sents->list[d1.seq].order_sentence_id, iv_set_id = ord_sents->list[d1.seq].
     set_id, item_id = ord_sents->list[d1.seq].items[d2.seq].item_id
     FROM (dummyt d1  WITH seq = value(size(ord_sents->list,5))),
      (dummyt d2  WITH seq = 1)
     PLAN (d1
      WHERE maxrec(d2,size(ord_sents->list[d1.seq].items,5)))
      JOIN (d2)
     ORDER BY cnvtlower(ord_sents->list[d1.seq].primary_disp), primary_mnemonic, cnvtlower(ord_sents
       ->list[d1.seq].mnemonic),
      synonym, order_sentence
     WITH format = stream, pcformat('"',",",1), format
    ;end select
   ELSEIF (programmode=powerplan_mode)
    FOR (i = 1 TO size(ord_sents->list,5))
      FOR (j = 1 TO size(ord_sents->list[i].items,5))
        SET rowcnt = (rowcnt+ 1)
        IF (mod(rowcnt,100)=1)
         SET stat = alterlist(output_rec->list,(rowcnt+ 99))
        ENDIF
        SET output_rec->list[rowcnt].powerplan = substring(1,100,ord_sents->list[i].plan_disp)
        SET output_rec->list[rowcnt].clinical_cat = substring(1,100,uar_get_code_display(ord_sents->
          list[i].dcp_clin_cat_cd))
        SET output_rec->list[rowcnt].sub_clinical_cat = substring(1,100,uar_get_code_display(
          ord_sents->list[i].dcp_clin_sub_cat_cd))
        SET output_rec->list[rowcnt].synonym_type = substring(1,100,uar_get_code_display(ord_sents->
          list[i].mnemonic_type_cd))
        SET output_rec->list[rowcnt].synonym = substring(1,100,ord_sents->list[i].mnemonic)
        SET output_rec->list[rowcnt].synonym_oef = substring(1,100,ord_sents->list[i].syn_oef)
        SET output_rec->list[rowcnt].rx_mask = trim(cnvtstring(ord_sents->list[i].rx_mask))
        SET output_rec->list[rowcnt].syn_virtual_view = substring(1,100,evaluate(ord_sents->list[i].
          synonym_vv_fac,0.0,"All",- (1.0),"None",
          uar_get_code_display(ord_sents->list[i].synonym_vv_fac)))
        SET output_rec->list[rowcnt].order_sentence = substring(1,200,ord_sents->list[i].os_disp_line
         )
        SET output_rec->list[rowcnt].required_fields_missing = substring(1,1000,ord_sents->list[i].
         missing_field_text)
        SET output_rec->list[rowcnt].error_message = substring(1,1000,ord_sents->list[i].error_text)
        SET output_rec->list[rowcnt].assignment_type = trim(substring(1,200,ord_sents->list[i].items[
          j].assigned_by))
        SET output_rec->list[rowcnt].iv_set_desc = trim(substring(1,100,ord_sents->list[i].set_desc))
        SET output_rec->list[rowcnt].item_desc = substring(1,100,ord_sents->list[i].items[j].
         item_desc)
        SET output_rec->list[rowcnt].item_qpd = trim(cnvtstring(ord_sents->list[i].items[j].qpd,11,4)
         )
        SET output_rec->list[rowcnt].order_price = trim(format(cnvtstring(ord_sents->list[i].price,11,
           2),"#######.##;$,"))
        SET output_rec->list[rowcnt].order_cost = trim(format(cnvtstring(ord_sents->list[i].cost,11,2
           ),"#######.##;$,"))
        SET output_rec->list[rowcnt].pathway_catalog_id = trim(cnvtstring(ord_sents->list[i].
          pathway_catalog_id))
        SET output_rec->list[rowcnt].synonym_id = trim(cnvtstring(ord_sents->list[i].synonym_id))
        SET output_rec->list[rowcnt].order_sent_id = trim(cnvtstring(ord_sents->list[i].
          order_sentence_id))
        SET output_rec->list[rowcnt].iv_set_id = trim(cnvtstring(ord_sents->list[i].set_id))
        SET output_rec->list[rowcnt].item_id = trim(cnvtstring(ord_sents->list[i].items[j].item_id))
      ENDFOR
    ENDFOR
    FOR (i = 1 TO size(iv_sets->set_list,5))
      FOR (j = 1 TO size(iv_sets->set_list[i].syn_list,5))
        SET rowcnt = (rowcnt+ 1)
        IF (mod(rowcnt,100)=1)
         SET stat = alterlist(output_rec->list,(rowcnt+ 99))
        ENDIF
        SET output_rec->list[rowcnt].iv_set_ind = 1
        SET output_rec->list[rowcnt].powerplan = substring(1,100,iv_sets->set_list[i].plan_disp)
        SET output_rec->list[rowcnt].clinical_cat = substring(1,100,uar_get_code_display(iv_sets->
          set_list[i].dcp_clin_cat_cd))
        SET output_rec->list[rowcnt].sub_clinical_cat = substring(1,100,iv_sets->set_list[i].
         primary_disp)
        IF ((iv_sets->set_list[i].med_order_type_cd=iv_type_cd))
         SET output_rec->list[rowcnt].synonym_type = "Continuous IV Set"
        ELSE
         SET output_rec->list[rowcnt].synonym_type = "Intermittent IV Set"
        ENDIF
        SET output_rec->list[rowcnt].synonym = substring(1,100,iv_sets->set_list[i].syn_list[j].
         syn_mnemonic)
        SET output_rec->list[rowcnt].synonym_oef = substring(1,100,iv_sets->set_list[i].syn_list[j].
         syn_oef)
        SET output_rec->list[rowcnt].rx_mask = trim(cnvtstring(iv_sets->set_list[i].syn_list[j].
          rx_mask))
        SET output_rec->list[rowcnt].syn_virtual_view = substring(1,100,evaluate(iv_sets->set_list[i]
          .syn_list[j].synonym_vv_fac,0.0,"All",- (1.0),"None",
          uar_get_code_display(ord_sents->list[i].synonym_vv_fac)))
        SET output_rec->list[rowcnt].order_sentence = substring(1,200,iv_sets->set_list[i].syn_list[j
         ].os_disp_line)
        SET output_rec->list[rowcnt].required_fields_missing = substring(1,1000,iv_sets->set_list[i].
         syn_list[j].missing_field_text)
        SET output_rec->list[rowcnt].error_message = substring(1,1000,iv_sets->set_list[i].syn_list[j
         ].error_text)
        SET output_rec->list[rowcnt].assignment_type = trim(substring(1,200,iv_sets->set_list[i].
          syn_list[j].assigned_by))
        SET output_rec->list[rowcnt].iv_set_desc = trim(substring(1,100,iv_sets->set_list[i].set_desc
          ))
        SET output_rec->list[rowcnt].item_desc = substring(1,100,iv_sets->set_list[i].syn_list[j].
         item_desc)
        SET output_rec->list[rowcnt].item_qpd = trim(cnvtstring(iv_sets->set_list[i].syn_list[j].qpd,
          11,4))
        SET output_rec->list[rowcnt].order_price = trim(format(cnvtstring(iv_sets->set_list[i].price,
           11,2),"#######.##;$,"))
        SET output_rec->list[rowcnt].order_cost = trim(format(cnvtstring(iv_sets->set_list[i].cost,11,
           2),"#######.##;$,"))
        SET output_rec->list[rowcnt].pathway_catalog_id = trim(cnvtstring(iv_sets->set_list[i].
          pathway_catalog_id))
        SET output_rec->list[rowcnt].synonym_id = trim(cnvtstring(iv_sets->set_list[i].syn_list[j].
          synonym_id))
        SET output_rec->list[rowcnt].order_sent_id = trim(cnvtstring(iv_sets->set_list[i].syn_list[j]
          .order_sentence_id))
        SET output_rec->list[rowcnt].iv_set_id = trim(cnvtstring(iv_sets->set_list[i].set_id))
        SET output_rec->list[rowcnt].item_id = trim(cnvtstring(iv_sets->set_list[i].syn_list[j].
          item_id))
      ENDFOR
    ENDFOR
    IF (mod(rowcnt,100) != 0)
     SET stat = alterlist(output_rec->list,rowcnt)
    ENDIF
    SELECT INTO value(filename)
     powerplan = substring(1,1000,output_rec->list[d1.seq].powerplan), clinical_cat = substring(1,
      1000,output_rec->list[d1.seq].clinical_cat), sub_clinical_cat = substring(1,1000,output_rec->
      list[d1.seq].sub_clinical_cat),
     synonym_type = substring(1,1000,output_rec->list[d1.seq].synonym_type), synonym = substring(1,
      1000,output_rec->list[d1.seq].synonym), synonym_oef = substring(1,1000,output_rec->list[d1.seq]
      .synonym_oef),
     rx_mask = substring(1,1000,output_rec->list[d1.seq].rx_mask), syn_virtual_view = substring(1,
      1000,output_rec->list[d1.seq].syn_virtual_view), order_sentence = substring(1,1000,output_rec->
      list[d1.seq].order_sentence),
     required_fields_missing = substring(1,1000,output_rec->list[d1.seq].required_fields_missing),
     error_message = substring(1,1000,output_rec->list[d1.seq].error_message), assignment_type =
     substring(1,1000,output_rec->list[d1.seq].assignment_type),
     iv_set_desc = substring(1,1000,output_rec->list[d1.seq].iv_set_desc), item_desc = substring(1,
      1000,output_rec->list[d1.seq].item_desc), item_qpd = substring(1,1000,output_rec->list[d1.seq].
      item_qpd),
     order_price = substring(1,1000,output_rec->list[d1.seq].order_price), order_cost = substring(1,
      1000,output_rec->list[d1.seq].order_cost), pathway_catalog_id = substring(1,1000,output_rec->
      list[d1.seq].pathway_catalog_id),
     synonym_id = substring(1,1000,output_rec->list[d1.seq].synonym_id), order_sent_id = substring(1,
      1000,output_rec->list[d1.seq].order_sent_id), iv_set_id = substring(1,1000,output_rec->list[d1
      .seq].iv_set_id),
     item_id = substring(1,1000,output_rec->list[d1.seq].item_id)
     FROM (dummyt d1  WITH seq = value(size(output_rec->list,5)))
     PLAN (d1)
     ORDER BY cnvtlower(output_rec->list[d1.seq].powerplan), powerplan, clinical_cat,
      sub_clinical_cat, output_rec->list[d1.seq].iv_set_ind, cnvtlower(output_rec->list[d1.seq].
       synonym),
      synonym, order_sentence
     WITH format = stream, pcformat('"',",",1), format
    ;end select
   ELSEIF (programmode=iv_set_mode)
    SELECT INTO value(filename)
     iv_set = substring(1,100,iv_sets->set_list[d1.seq].primary_disp), iv_set_type =
     IF ((iv_sets->set_list[d1.seq].med_order_type_cd=iv_type_cd)) "Continuous"
     ELSE "Intermittent"
     ENDIF
     , synonym_type = substring(1,100,uar_get_code_display(iv_sets->set_list[d1.seq].syn_list[d2.seq]
       .syn_mnemonic_type_cd)),
     synonym = substring(1,100,iv_sets->set_list[d1.seq].syn_list[d2.seq].syn_mnemonic), synonym_oef
      = substring(1,100,iv_sets->set_list[d1.seq].syn_list[d2.seq].syn_oef), rx_mask = iv_sets->
     set_list[d1.seq].syn_list[d2.seq].rx_mask,
     syn_virtual_view = substring(1,100,evaluate(iv_sets->set_list[d1.seq].syn_list[d2.seq].
       synonym_vv_fac,0.0,"All",- (1.0),"None",
       uar_get_code_display(iv_sets->set_list[d1.seq].syn_list[d2.seq].synonym_vv_fac))),
     order_sentence = substring(1,200,iv_sets->set_list[d1.seq].syn_list[d2.seq].os_disp_line),
     required_fields_missing = substring(1,1000,iv_sets->set_list[d1.seq].syn_list[d2.seq].
      missing_field_text),
     error_message = substring(1,1000,iv_sets->set_list[d1.seq].syn_list[d2.seq].error_text),
     assignment_type = trim(substring(1,200,iv_sets->set_list[d1.seq].syn_list[d2.seq].assigned_by)),
     iv_set_desc = trim(substring(1,100,iv_sets->set_list[d1.seq].set_desc)),
     item_desc = substring(1,100,iv_sets->set_list[d1.seq].syn_list[d2.seq].item_desc), item_qpd =
     iv_sets->set_list[d1.seq].syn_list[d2.seq].qpd, order_price = iv_sets->set_list[d1.seq].price
     "#######.##;$,",
     order_cost = iv_sets->set_list[d1.seq].cost"#######.##;$,", catalog_cd = iv_sets->set_list[d1
     .seq].catalog_cd, synonym_id = iv_sets->set_list[d1.seq].syn_list[d2.seq].synonym_id,
     order_sent_id = iv_sets->set_list[d1.seq].syn_list[d2.seq].order_sentence_id, iv_set_id =
     iv_sets->set_list[d1.seq].set_id, item_id = iv_sets->set_list[d1.seq].syn_list[d2.seq].item_id
     FROM (dummyt d1  WITH seq = value(size(iv_sets->set_list,5))),
      (dummyt d2  WITH seq = 1)
     PLAN (d1
      WHERE maxrec(d2,size(iv_sets->set_list[d1.seq].syn_list,5)))
      JOIN (d2)
     ORDER BY cnvtlower(iv_sets->set_list[d1.seq].primary_disp), iv_set, iv_sets->set_list[d1.seq].
      syn_list[d2.seq].sequence
     WITH format = stream, pcformat('"',",",1), format
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE processrequestforivset(iv_sets_pos)
   DECLARE idx = i4 WITH protect
   DECLARE i = i4 WITH protect
   DECLARE retval = i2 WITH protect
   DECLARE num = i4 WITH protect
   DECLARE pos = i4 WITH protect
   DECLARE c = i4 WITH protect
   SET stat = tdbexecute(560250,560250,560250,"REC",apa_request,
    "REC",apa_reply)
   IF (debug_ind=1)
    CALL addlogmsg("INFO",build("stat from tdbexecute of 112 call = ",stat))
    CALL addlogmsg("INFO","apa_reply inside processRequestForIvSet():")
    CALL echorecord(apa_reply,logfilename,1)
   ENDIF
   IF (stat=0)
    IF (validate(apa_reply->catalog_group[1].catalog_group_id,0))
     IF ((apa_reply->catalog_group[1].set_item_id > 0))
      SET iv_sets->set_list[iv_sets_pos].set_id = apa_reply->catalog_group[1].set_item_id
      SET retval = 1
     ELSE
      SET iv_sets->set_list[iv_sets_pos].set_desc = "None"
      SET retval = 0
     ENDIF
     FOR (num = 1 TO size(apa_reply->catalog_group[1].catalog_list,5))
      SET pos = locateval(i,1,size(apa_reply->catalog_group[1].catalog_list,5),apa_reply->
       catalog_group[1].catalog_list[num].synonym_id,iv_sets->set_list[iv_sets_pos].syn_list[i].
       synonym_id)
      IF ((apa_reply->catalog_group[1].catalog_list[num].item_id > 0)
       AND (apa_reply->catalog_group[1].set_item_id > 0))
       SET iv_sets->set_list[iv_sets_pos].syn_list[pos].item_id = apa_reply->catalog_group[1].
       catalog_list[num].item_id
       SET iv_sets->set_list[iv_sets_pos].syn_list[pos].qpd = apa_reply->catalog_group[1].
       catalog_list[num].qpd
       SET iv_sets->set_list[iv_sets_pos].syn_list[pos].assigned_by = "APA"
      ELSE
       SET stat = initrec(aps_request)
       SET aps_request->catalog_cd = iv_sets->set_list[iv_sets_pos].syn_list[pos].syn_catalog_cd
       SET aps_request->synonym_id = iv_sets->set_list[iv_sets_pos].syn_list[pos].synonym_id
       SET aps_request->route_cd = iv_sets->set_list[iv_sets_pos].route_cd
       SET aps_request->facility_cd = facilitycd
       SET aps_request->form_cd = iv_sets->set_list[iv_sets_pos].form_cd
       CASE (iv_sets->set_list[iv_sets_pos].med_order_type_cd)
        OF med_type_cd:
         SET aps_request->order_type = 1
        OF iv_type_cd:
         SET aps_request->order_type = 2
        OF int_type_cd:
         SET aps_request->order_type = 3
       ENDCASE
       SET aps_request->strength = iv_sets->set_list[iv_sets_pos].syn_list[pos].strength
       SET aps_request->strength_unit = iv_sets->set_list[iv_sets_pos].syn_list[pos].strength_unit_cd
       SET aps_request->volume = iv_sets->set_list[iv_sets_pos].syn_list[pos].volume
       SET aps_request->volume_unit = iv_sets->set_list[iv_sets_pos].syn_list[pos].volume_unit_cd
       SET aps_request->tier_level = 4
       SET aps_request->pat_loc_cd = nurseunitcd
       SET aps_request->encounter_type_cd = encountertypecd
       IF (debug_ind=1)
        CALL addlogmsg("INFO","aps_request structure in processRequestForIvSet():")
        CALL echorecord(aps_request,logfilename,1)
       ENDIF
       SET stat = initrec(aps_reply)
       SET message = window
       EXECUTE rx_get_items_for_order_catalog  WITH replace("REQUEST",aps_request), replace("REPLY",
        aps_reply)
       IF (debug_ind=1)
        CALL addlogmsg("INFO","aps_reply structure in processRequestForIvSet():")
        CALL echorecord(aps_reply,logfilename,1)
       ENDIF
       IF ((aps_reply->status_data.status="F"))
        SET retval = - (1)
        SET status = "F"
        SET statusstr = "rx_get_items_for_order_catalog failed"
        RETURN(retval)
       ELSE
        SET apspos = locateval(idx,1,size(aps_reply->product,5),1,aps_reply->product[idx].
         true_product)
        IF (apspos > 0)
         SET iv_sets->set_list[iv_sets_pos].syn_list[pos].item_id = aps_reply->product[apspos].
         item_id
         SET iv_sets->set_list[iv_sets_pos].syn_list[pos].qpd = aps_reply->product[apspos].disp_qty
         SET iv_sets->set_list[iv_sets_pos].syn_list[pos].assigned_by = "APS"
        ELSEIF (size(aps_reply->product,5)=0)
         SET noproderrorcnt = (noproderrorcnt+ 1)
         SET iv_sets->set_list[iv_sets_pos].syn_list[pos].error_text =
         "No products will be available when verifying. "
         SET iv_sets->set_list[iv_sets_pos].syn_list[pos].assigned_by = "None"
        ELSE
         SET iv_sets->set_list[iv_sets_pos].syn_list[pos].item_desc = " "
         SET iv_sets->set_list[iv_sets_pos].syn_list[pos].item_id = 0
         SET iv_sets->set_list[iv_sets_pos].syn_list[pos].qpd = 0
         SET iv_sets->set_list[iv_sets_pos].syn_list[pos].assigned_by = "None"
        ENDIF
       ENDIF
      ENDIF
     ENDFOR
    ELSE
     SET iv_sets->set_list[iv_sets_pos].syn_list[1].error_text =
     "Unknown error occurred during product assignment. Check if 112 server is running"
    ENDIF
   ELSE
    SET retval = - (1)
    SET status = "F"
    SET statusstr = "Error received from the 112 server. Ensure server is still running."
    RETURN(retval)
   ENDIF
   RETURN(retval)
 END ;Subroutine
 SUBROUTINE processrequest(ord_sents_pos)
   DECLARE retval = i2 WITH protect
   DECLARE pos = i4 WITH protect
   DECLARE num = i4 WITH protect
   DECLARE itemerrorind = i2 WITH protect
   DECLARE errormsg = vc WITH protect
   DECLARE explodedvoldose = f8 WITH protect
   DECLARE explodedstrdose = f8 WITH protect
   DECLARE itemusestrengthorvolume = i2 WITH protect
   DECLARE ingredusestrengthorvolume = i2 WITH protect
   DECLARE criticalerrorstr = vc WITH protect, noconstant(
    "Critical Error. All other orders signed in same conversation would not APA.")
   SET stat = tdbexecute(560250,560250,560250,"REC",apa_request,
    "REC",apa_reply)
   IF (debug_ind=1)
    CALL addlogmsg("INFO",build("stat from tdbexecute of 112 call = ",stat))
    CALL addlogmsg("INFO","apa_reply inside processRequest():")
    CALL echorecord(apa_reply,logfilename,1)
   ENDIF
   IF (stat=0)
    IF (validate(apa_reply->catalog_group[1].catalog_group_id,0))
     SET stat = alterlist(ord_sents->list[ord_sents_pos].items,size(apa_reply->catalog_group[1].
       catalog_list,5))
     IF ((apa_reply->catalog_group[1].set_item_id > 0))
      SET ord_sents->list[ord_sents_pos].set_id = apa_reply->catalog_group[1].set_item_id
      FOR (num = 1 TO size(apa_reply->catalog_group[1].catalog_list,5))
        SET ord_sents->list[ord_sents_pos].items[num].item_id = apa_reply->catalog_group[1].
        catalog_list[num].item_id
        SET ord_sents->list[ord_sents_pos].items[num].qpd = apa_reply->catalog_group[1].catalog_list[
        num].qpd
        SET ord_sents->list[ord_sents_pos].items[num].assigned_by = "APA"
      ENDFOR
     ELSEIF ((apa_reply->catalog_group[1].catalog_list[1].item_id > 0))
      FOR (num = 1 TO size(apa_reply->catalog_group[1].catalog_list,5))
        SET itemerrorind = 0
        SET ord_sents->list[ord_sents_pos].items[num].item_id = apa_reply->catalog_group[1].
        catalog_list[num].item_id
        SET ord_sents->list[ord_sents_pos].items[num].qpd = apa_reply->catalog_group[1].catalog_list[
        num].qpd
        SET itemusestrengthorvolume = usestrengthorvolume(item_mode,apa_reply->catalog_group[1].
         catalog_list[num].item_id)
        SET ingredusestrengthorvolume = usestrengthorvolume(ingredient_mode,cnvtreal(ord_sents_pos))
        IF (debug_ind=1)
         CALL addlogmsg("INFO",build("Entering ExplodeDose() logic for item_id:",apa_reply->
           catalog_group[1].catalog_list[1].item_id))
         CALL addlogmsg("INFO",build("itemUseStrengthOrVolume = ",itemusestrengthorvolume))
         CALL addlogmsg("INFO",build("ingredUseStrengthOrVolume = ",ingredusestrengthorvolume))
        ENDIF
        IF (itemusestrengthorvolume=strength_and_volume_are_valid)
         IF (((ingredusestrengthorvolume=only_strength_is_valid) OR (ingredusestrengthorvolume=
         strength_and_volume_are_valid)) )
          SET explodedvoldose = explodevolumedose(ord_sents->list[ord_sents_pos].strength,ord_sents->
           list[ord_sents_pos].strength_unit_cd,apa_reply->catalog_group[1].catalog_list[num].item_id
           )
          IF (debug_ind=1)
           CALL addlogmsg("INFO",build("explodedVolDose = ",explodedvoldose))
          ENDIF
          IF (explodedvoldose <= 0)
           CASE (explodedvoldose)
            OF 0:
             SET errormsg = "Volume on order is 0. Product concentration might be too high. "
            OF unknown_error:
             SET errormsg = "Unknown error occurred calculating volume of order. "
            OF product_no_strength:
             SET errormsg = build2("Product assigned by server does not have a strength. ",
              "Cannot determine order's volume. ")
            OF cannot_convert_unit:
             SET errormsg = build2("Order only has strength. Product has volume and strength. ",
              "Cannot convert order's strength to product. ")
            OF unit_ckis_not_found:
             SET errormsg = "One or more UOMs on the product or order do not have a CKI. "
           ENDCASE
           IF (explodedvoldose != 0)
            SET itemerrorind = 1
            SET criticalerrorcnt = (criticalerrorcnt+ 1)
            SET ord_sents->list[ord_sents_pos].items[num].assigned_by = criticalerrorstr
            SET ord_sents->list[ord_sents_pos].error_text = errormsg
           ELSE
            SET itemerrorind = 0
            SET ord_sents->list[ord_sents_pos].error_text = errormsg
           ENDIF
          ENDIF
         ELSEIF (ingredusestrengthorvolume=only_volume_is_valid)
          SET explodedstrdose = explodestrengthdose(ord_sents->list[ord_sents_pos].volume,ord_sents->
           list[ord_sents_pos].volume_unit_cd,apa_reply->catalog_group[1].catalog_list[num].item_id)
          IF (debug_ind=1)
           CALL addlogmsg("INFO",build("explodedStrDose = ",explodedstrdose))
          ENDIF
          IF (explodedstrdose <= 0)
           SET itemerrorind = 1
           CASE (explodedstrdose)
            OF unknown_error:
             SET errormsg = "Unknown error occurred calculating strength of order. "
            OF product_no_volume:
             SET errormsg = build2("Product assigned by server does not have a volume. ",
              "Cannot determine order's strength. ")
            OF cannot_convert_unit:
             SET errormsg = build2("Order only has volume. Product has volume and strength. ",
              " Cannot convert order's volume to product. ")
            OF unit_ckis_not_found:
             SET errormsg = "One or more UOMs on the product or order do not have a CKI. "
           ENDCASE
           SET criticalerrorcnt = (criticalerrorcnt+ 1)
           SET ord_sents->list[ord_sents_pos].items[num].assigned_by = criticalerrorstr
           SET ord_sents->list[ord_sents_pos].error_text = errormsg
          ENDIF
         ELSEIF (ingredusestrengthorvolume=strength_and_volume_are_invalid
          AND (ord_sents->list[ord_sents_pos].freetext_dose > ""))
          SET itemerrorind = 0
         ELSE
          SET itemerrorind = 1
          SET errormsg = "Ingredient has invalid strength and volume after assignment"
          SET criticalerrorcnt = (criticalerrorcnt+ 1)
          SET ord_sents->list[ord_sents_pos].items[num].assigned_by = criticalerrorstr
          SET ord_sents->list[ord_sents_pos].error_text = errormsg
         ENDIF
        ELSE
         IF (debug_ind=1)
          CALL addlogmsg("INFO",
           "Performing validation checking to ensure strength and volume are convertible")
         ENDIF
         SET explodedstrdose = getconvertedstrength(ord_sents->list[ord_sents_pos].items[num].item_id,
          ord_sents->list[ord_sents_pos].strength_unit_cd)
         SET explodedvoldose = getconvertedvolume(ord_sents->list[ord_sents_pos].items[num].item_id,
          ord_sents->list[ord_sents_pos].volume_unit_cd)
         IF (debug_ind=1)
          CALL addlogmsg("INFO",build("explodedStrDose = ",explodedstrdose))
          CALL addlogmsg("INFO",build("explodedVolDose = ",explodedvoldose))
         ENDIF
         IF (((explodedstrdose=unit_ckis_not_found) OR (explodedvoldose=unit_ckis_not_found))
          AND itemusestrengthorvolume != ingredusestrengthorvolume
          AND (ord_sents->list[ord_sents_pos].items[num].qpd=1.0))
          SET itemerrorind = 0
          IF (itemusestrengthorvolume=only_strength_is_valid)
           SET errormsg = build2("Order only has volume. Product only has strength. ",
            "Bulk dispense category on product will allow assignment. ",
            "Consider changing sentence or product to match. ")
          ELSEIF (itemusestrengthorvolume=only_volume_is_valid)
           SET errormsg = build2("Order only has strength. Product only has volume. ",
            "Bulk dispense category on product will allow assignment. ",
            "Consider changing sentence or product to match. ")
          ENDIF
          SET ord_sents->list[ord_sents_pos].error_text = errormsg
         ELSEIF (explodedstrdose=cannot_convert_unit)
          SET itemerrorind = 1
          SET errormsg =
          "Order only has strength. Product only has strength.The units are not convertible. "
          SET criticalerrorcnt = (criticalerrorcnt+ 1)
          SET ord_sents->list[ord_sents_pos].items[num].assigned_by = criticalerrorstr
          SET ord_sents->list[ord_sents_pos].error_text = errormsg
         ELSEIF (explodedvoldose=cannot_convert_unit)
          SET itemerrorind = 1
          SET errormsg =
          "Order only has volume. Product only has volume.The units are not convertible. "
          SET criticalerrorcnt = (criticalerrorcnt+ 1)
          SET ord_sents->list[ord_sents_pos].items[num].assigned_by = criticalerrorstr
          SET ord_sents->list[ord_sents_pos].error_text = errormsg
         ELSEIF (((explodedstrdose=unit_ckis_not_found) OR (explodedvoldose=unit_ckis_not_found)) )
          SET itemerrorind = 1
          SET errormsg = "One or more UOMs on the product or order do not have a CKI. "
          SET criticalerrorcnt = (criticalerrorcnt+ 1)
          SET ord_sents->list[ord_sents_pos].items[num].assigned_by = criticalerrorstr
          SET ord_sents->list[ord_sents_pos].error_text = errormsg
         ENDIF
        ENDIF
        IF (itemerrorind=0)
         SET ord_sents->list[ord_sents_pos].items[num].assigned_by = "APA"
        ENDIF
      ENDFOR
     ELSE
      SET ord_sents->list[ord_sents_pos].items[1].item_desc = " "
      SET ord_sents->list[ord_sents_pos].items[1].item_id = 0
      SET ord_sents->list[ord_sents_pos].items[1].qpd = 0
      SET ord_sents->list[ord_sents_pos].items[1].assigned_by = "None"
     ENDIF
     IF (validate(apa_reply->catalog_group[1].catalog_list[1].catalog_cd,0))
      IF ((apa_reply->catalog_group[1].catalog_list[1].item_id=0)
       AND (apa_reply->catalog_group[1].set_item_id=0))
       IF ((ord_sents->list[ord_sents_pos].order_type_list[1].med_order_type_cd > 0))
        SET stat = initrec(aps_request)
        SET aps_request->catalog_cd = ord_sents->list[ord_sents_pos].catalog_cd
        SET aps_request->synonym_id = ord_sents->list[ord_sents_pos].synonym_id
        SET aps_request->route_cd = ord_sents->list[ord_sents_pos].route_cd
        SET aps_request->facility_cd = facilitycd
        SET aps_request->form_cd = ord_sents->list[ord_sents_pos].form_cd
        CASE (ord_sents->list[ord_sents_pos].order_type_list[1].med_order_type_cd)
         OF med_type_cd:
          SET aps_request->order_type = 1
         OF iv_type_cd:
          SET aps_request->order_type = 2
         OF int_type_cd:
          SET aps_request->order_type = 3
        ENDCASE
        SET aps_request->strength = ord_sents->list[ord_sents_pos].strength
        SET aps_request->strength_unit = ord_sents->list[ord_sents_pos].strength_unit_cd
        SET aps_request->volume = ord_sents->list[ord_sents_pos].volume
        SET aps_request->volume_unit = ord_sents->list[ord_sents_pos].volume_unit_cd
        SET aps_request->tier_level = 4
        SET aps_request->pat_loc_cd = nurseunitcd
        SET aps_request->encounter_type_cd = encountertypecd
        IF (debug_ind=1)
         CALL addlogmsg("INFO","aps_request structure in processRequest:")
         CALL echorecord(aps_request,logfilename,1)
        ENDIF
        SET stat = initrec(aps_reply)
        SET message = window
        EXECUTE rx_get_items_for_order_catalog  WITH replace("REQUEST",aps_request), replace("REPLY",
         aps_reply)
        IF (debug_ind=1)
         CALL addlogmsg("INFO","aps_reply structure in processRequest:")
         CALL echorecord(aps_reply,logfilename,1)
        ENDIF
        IF ((aps_reply->status_data.status="F"))
         SET retval = - (1)
         SET status = "F"
         SET statusstr = "rx_get_items_for_order_catalog failed"
         RETURN(retval)
        ELSE
         SET pos = locateval(num,1,size(aps_reply->product,5),1,aps_reply->product[num].true_product)
         IF (pos > 0)
          SET ord_sents->list[ord_sents_pos].items[1].item_id = aps_reply->product[pos].item_id
          SET ord_sents->list[ord_sents_pos].items[1].qpd = aps_reply->product[pos].disp_qty
          SET ord_sents->list[ord_sents_pos].items[1].assigned_by = "APS"
         ELSEIF (size(aps_reply->product,5)=0)
          SET noproderrorcnt = (noproderrorcnt+ 1)
          SET ord_sents->list[ord_sents_pos].error_text =
          "No products will be available when verifying. "
          SET ord_sents->list[ord_sents_pos].items[1].assigned_by = "None"
         ENDIF
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    ELSE
     SET stat = alterlist(ord_sents->list[ord_sents_pos].items,1)
     SET ord_sents->list[ord_sents_pos].items[1].item_desc = ""
     SET ord_sents->list[ord_sents_pos].items[1].item_id = 0
     SET ord_sents->list[ord_sents_pos].items[1].qpd = 0
     SET ord_sents->list[ord_sents_pos].error_text =
     "Unknown error occurred during product assignment. Check if 112 server is running"
    ENDIF
   ELSE
    SET retval = - (1)
    SET status = "F"
    SET statusstr = "Error received from the 112 server. Ensure server is still running. "
    RETURN(retval)
   ENDIF
   IF ((ord_sents->list[ord_sents_pos].items[1].assigned_by="APA"))
    SET retval = 1
   ELSE
    SET retval = 0
   ENDIF
   RETURN(retval)
 END ;Subroutine
 SUBROUTINE loadrequestforivset(null)
   DECLARE ordsentind = i2 WITH protect
   DECLARE pricecnt = i4 WITH protect
   DECLARE setcnt = f8 WITH protect
   DECLARE loopcnt = i4 WITH protect
   DECLARE i = i4 WITH protect
   IF (programmode != powerplan_mode)
    SET criticalerrorcnt = 0
    SET noproderrorcnt = 0
   ENDIF
   FOR (loopcnt = 1 TO size(iv_sets->set_list,5))
     SET setcnt = (setcnt+ 1)
     IF (checkallivsetsind=1)
      CALL text((soffrow+ 14),(soffcol+ 30),build2("Assigning product to IV set ",trim(cnvtstring(
          setcnt))," of ",trim(cnvtstring(totalivsetcnt))))
     ELSEIF (programmode=powerplan_mode)
      SET totalivsetcnt = size(iv_sets->set_list,5)
      CALL text((soffrow+ 14),(soffcol+ 30),build2("Assigning product to IV set ",trim(cnvtstring(
          setcnt))," of ",trim(cnvtstring(totalivsetcnt))))
     ENDIF
     SET ordsentind = 0
     FOR (i = 1 TO size(iv_sets->set_list[loopcnt].syn_list,5))
       IF ((iv_sets->set_list[loopcnt].syn_list[i].order_sentence_id > 0))
        SET ordsentind = 1
       ENDIF
     ENDFOR
     IF (ordsentind=1)
      SET stat = initrec(apa_request)
      SET stat = alterlist(apa_request->catalog_group,1)
      SET stat = alterlist(apa_request->catalog_group[1].order_type_list,1)
      SET stat = alterlist(apa_request->catalog_group[1].catalog_list,size(iv_sets->set_list[loopcnt]
        .syn_list,5))
      SET apa_request->catalog_group[1].encounter_type_cd = encountertypecd
      SET apa_request->catalog_group[1].facility_cd = facilitycd
      SET apa_request->catalog_group[1].form_cd = iv_sets->set_list[loopcnt].form_cd
      SET apa_request->catalog_group[1].pat_locn_cd = nurseunitcd
      SET apa_request->catalog_group[1].route_cd = iv_sets->set_list[loopcnt].route_cd
      SET apa_request->catalog_group[1].skip_iv_ind = 0
      SET apa_request->catalog_group[1].order_type_list[1].med_order_type_cd = iv_sets->set_list[
      loopcnt].med_order_type_cd
      FOR (i = 1 TO size(iv_sets->set_list[loopcnt].syn_list,5))
        SET apa_request->catalog_group[1].catalog_list[i].catalog_cd = iv_sets->set_list[loopcnt].
        syn_list[i].syn_catalog_cd
        SET apa_request->catalog_group[1].catalog_list[i].orderable_type_flag = iv_sets->set_list[
        loopcnt].syn_list[i].orderable_type_flag
        SET apa_request->catalog_group[1].catalog_list[i].strength = iv_sets->set_list[loopcnt].
        syn_list[i].strength
        SET apa_request->catalog_group[1].catalog_list[i].strength_unit_cd = iv_sets->set_list[
        loopcnt].syn_list[i].strength_unit_cd
        SET apa_request->catalog_group[1].catalog_list[i].synonym_id = iv_sets->set_list[loopcnt].
        syn_list[i].synonym_id
        SET apa_request->catalog_group[1].catalog_list[i].volume = iv_sets->set_list[loopcnt].
        syn_list[i].volume
        SET apa_request->catalog_group[1].catalog_list[i].volume_unit_cd = iv_sets->set_list[loopcnt]
        .syn_list[i].volume_unit_cd
      ENDFOR
      IF (debug_ind=1)
       CALL addlogmsg("INFO","apa_request structure after being loaded by loadRequestForIvSet():")
       CALL echorecord(apa_request,logfilename,1)
      ENDIF
      SET stat = processrequestforivset(loopcnt)
      IF ((stat=- (1)))
       RETURN(0)
      ELSEIF (stat=1)
       SET apacnt = (apacnt+ 1)
      ENDIF
     ENDIF
     IF (checkallivsetsind=1)
      SET apapercent = ((apacnt/ setcnt) * 100)
      CALL text(quesrow,(soffcol+ 57),build2("APA rate: ",trim(cnvtstring(apapercent,11,2)),"% "))
     ELSEIF (programmode=powerplan_mode)
      SET apapercent = ((apacnt/ (setcnt+ totalsentcnt)) * 100)
      CALL text(quesrow,(soffcol+ 57),build2("APA rate: ",trim(cnvtstring(apapercent,11,2)),"% "))
     ENDIF
   ENDFOR
   IF (checkallivsetsind=1)
    IF (deleteerrorcnt(build(script_name,"|IV_SETS")) > 1)
     SET status = "F"
     SET statusstr = build2("Error removing dm_info row for ",build(script_name,"|IV_SETS"))
     GO TO exit_script
    ENDIF
    IF (incrementerrorcnt(build(script_name,"|IV_SETS"),round(apapercent,2),
     "Percentage of IV sets that APA:")=0)
     SET status = "F"
     SET statusstr = build2("Failed to set error count for audit: IV_SETS")
     GO TO exit_script
    ELSE
     COMMIT
    ENDIF
   ELSEIF (checkallplansind=1)
    IF (deleteerrorcnt(build(script_name,"|POWER_PLANS")) > 1)
     SET status = "F"
     SET statusstr = build2("Error removing dm_info row for ",build(script_name,"|POWER_PLANS"))
     GO TO exit_script
    ENDIF
    IF (incrementerrorcnt(build(script_name,"|POWER_PLANS"),round(apapercent,2),
     "Percentage of sentences within PowerPlans that APA:")=0)
     SET status = "F"
     SET statusstr = build2("Failed to set error count for audit: POWER_PLANS")
     GO TO exit_script
    ELSE
     COMMIT
    ENDIF
   ENDIF
   CALL loaditemdetails(null)
   SET setcnt = 0
   FOR (pricecnt = 1 TO size(iv_sets->set_list,5))
     SET setcnt = (setcnt+ 1)
     IF (checkallivsetsind=1)
      CALL text((soffrow+ 14),(soffcol+ 30),build2("Calculating price for IV set ",trim(cnvtstring(
          setcnt))," of ",trim(cnvtstring(totalivsetcnt))))
     ELSEIF (programmode=powerplan_mode)
      CALL text((soffrow+ 14),(soffcol+ 30),build2("Calculating price for IV set ",trim(cnvtstring(
          setcnt))," of ",trim(cnvtstring(totalivsetcnt))))
     ENDIF
     IF ((iv_sets->set_list[pricecnt].set_price_sched_id > 0))
      CALL calculateorderprice(pricecnt)
     ENDIF
   ENDFOR
   CALL clear((soffrow+ 14),soffcol,numcols)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE loadrequestforordsent(ord_sent_pos)
   CALL setmedordertypecd(ord_sent_pos)
   SET stat = initrec(apa_request)
   SET stat = alterlist(apa_request->catalog_group,1)
   SET stat = alterlist(apa_request->catalog_group[1].order_type_list,size(ord_sents->list[
     ord_sent_pos].order_type_list,5))
   SET stat = alterlist(apa_request->catalog_group[1].catalog_list,1)
   SET apa_request->catalog_group[1].encounter_type_cd = encountertypecd
   SET apa_request->catalog_group[1].facility_cd = facilitycd
   SET apa_request->catalog_group[1].form_cd = ord_sents->list[ord_sent_pos].form_cd
   SET apa_request->catalog_group[1].pat_locn_cd = nurseunitcd
   SET apa_request->catalog_group[1].route_cd = ord_sents->list[ord_sent_pos].route_cd
   SET apa_request->catalog_group[1].skip_iv_ind = 0
   FOR (i = 1 TO size(ord_sents->list[ord_sent_pos].order_type_list,5))
     SET apa_request->catalog_group[1].order_type_list[i].med_order_type_cd = ord_sents->list[
     ord_sent_pos].order_type_list[i].med_order_type_cd
   ENDFOR
   SET apa_request->catalog_group[1].catalog_list[1].catalog_cd = ord_sents->list[ord_sent_pos].
   catalog_cd
   SET apa_request->catalog_group[1].catalog_list[1].freetext_dose = ord_sents->list[ord_sent_pos].
   freetext_dose
   SET apa_request->catalog_group[1].catalog_list[1].orderable_type_flag = ord_sents->list[
   ord_sent_pos].orderable_type_flag
   SET apa_request->catalog_group[1].catalog_list[1].strength = ord_sents->list[ord_sent_pos].
   strength
   SET apa_request->catalog_group[1].catalog_list[1].strength_unit_cd = ord_sents->list[ord_sent_pos]
   .strength_unit_cd
   SET apa_request->catalog_group[1].catalog_list[1].synonym_id = ord_sents->list[ord_sent_pos].
   synonym_id
   SET apa_request->catalog_group[1].catalog_list[1].volume = ord_sents->list[ord_sent_pos].volume
   SET apa_request->catalog_group[1].catalog_list[1].volume_unit_cd = ord_sents->list[ord_sent_pos].
   volume_unit_cd
   IF (debug_ind=1)
    CALL addlogmsg("INFO","apa_request structure after being loaded by loadRequestForOrdSent():")
    CALL echorecord(apa_request,logfilename,1)
   ENDIF
   SET stat = processrequest(ord_sent_pos)
   IF ((stat=- (1)))
    RETURN(0)
   ENDIF
   CALL loaditemdetails(null)
   CALL calculateorderprice(ord_sent_pos)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE getordersents(searchmode,searchid)
   DECLARE setcnt = i4 WITH protect
   DECLARE rowcnt = i4 WITH protect
   DECLARE sentcnt = i4 WITH protect
   DECLARE ivsentcnt = i4 WITH protect
   DECLARE pos = i4 WITH protect
   DECLARE idx = i4 WITH protect
   DECLARE missingtext = vc WITH protect
   DECLARE fieldfoundind = i2 WITH protect
   DECLARE plantype = vc WITH protect
   IF (((strengthdosefieldid=0) OR (((strengthdoseunitfieldid=0) OR (((volumedosefieldid=0) OR (((
   volumedoseunitfieldid=0) OR (((freetextdosefieldid=0) OR (((routefieldid=0) OR (((formfieldid=0)
    OR (((ratefieldid=0) OR (((infuseoverfieldid=0) OR (((normalizedratefieldid=0) OR (((
   frequencyfieldid=0) OR (freetextratefieldid=0)) )) )) )) )) )) )) )) )) )) )) )
    SELECT INTO "nl:"
     oef.oe_field_id
     FROM oe_field_meaning ofm,
      order_entry_fields oef
     PLAN (ofm
      WHERE ofm.oe_field_meaning IN ("STRENGTHDOSE", "STRENGTHDOSEUNIT", "VOLUMEDOSE",
      "VOLUMEDOSEUNIT", "FREETXTDOSE",
      "RXROUTE", "DRUGFORM", "RATE", "INFUSEOVER", "NORMALIZEDRATE",
      "FREQ", "FREETEXTRATE"))
      JOIN (oef
      WHERE oef.oe_field_meaning_id=ofm.oe_field_meaning_id)
     DETAIL
      CASE (ofm.oe_field_meaning)
       OF "STRENGTHDOSE":
        strengthdosefieldid = oef.oe_field_id
       OF "STRENGTHDOSEUNIT":
        strengthdoseunitfieldid = oef.oe_field_id
       OF "VOLUMEDOSE":
        volumedosefieldid = oef.oe_field_id
       OF "VOLUMEDOSEUNIT":
        volumedoseunitfieldid = oef.oe_field_id
       OF "FREETXTDOSE":
        freetextdosefieldid = oef.oe_field_id
       OF "RXROUTE":
        routefieldid = oef.oe_field_id
       OF "DRUGFORM":
        formfieldid = oef.oe_field_id
       OF "RATE":
        ratefieldid = oef.oe_field_id
       OF "INFUSEOVER":
        infuseoverfieldid = oef.oe_field_id
       OF "NORMALIZEDRATE":
        normalizedratefieldid = oef.oe_field_id
       OF "FREQ":
        frequencyfieldid = oef.oe_field_id
       OF "FREETEXTRATE":
        freetextratefieldid = oef.oe_field_id
      ENDCASE
     WITH nocounter
    ;end select
   ENDIF
   IF (searchmode=search_by_syn)
    SELECT INTO "nl:"
     ocs.mnemonic, oefp.oe_format_name, os.order_sentence_display_line
     FROM order_catalog_synonym ocs,
      order_entry_format_parent oefp,
      (left JOIN oe_format_fields oeff ON oeff.oe_format_id=oefp.oe_format_id
       AND oeff.action_type_cd=action_order_cd
       AND ((oeff.value_required_ind=1) OR (oeff.accept_flag=0)) ),
      (left JOIN order_entry_fields oef ON oef.oe_field_id=oeff.oe_field_id),
      (left JOIN oe_field_meaning ofm ON ofm.oe_field_meaning_id=oef.oe_field_meaning_id
       AND ofm.oe_field_meaning != "REQSTARTDTTM"),
      order_catalog oc,
      ord_cat_sent_r ocsr,
      order_sentence os,
      filter_entity_reltn fer,
      (left JOIN order_sentence_detail osd ON osd.order_sentence_id=fer.parent_entity_id),
      (left JOIN code_value_extension cve ON cve.code_value=osd.default_parent_entity_id
       AND cve.code_set=54
       AND cve.field_name="PHARM_UNIT")
     PLAN (ocs
      WHERE ocs.catalog_type_cd=pharm_cat_cd
       AND ocs.activity_type_cd=pharm_act_cd
       AND ocs.synonym_id=searchid
       AND  NOT (ocs.mnemonic_type_cd IN (syn_type_rx, syn_type_y, syn_type_z))
       AND ocs.active_ind=1
       AND ((ocs.hide_flag = null) OR (ocs.hide_flag=0)) )
      JOIN (oefp
      WHERE oefp.oe_format_id=ocs.oe_format_id)
      JOIN (oeff)
      JOIN (oef)
      JOIN (ofm)
      JOIN (oc
      WHERE oc.catalog_cd=ocs.catalog_cd)
      JOIN (ocsr
      WHERE ocsr.synonym_id=ocs.synonym_id)
      JOIN (os
      WHERE os.order_sentence_id=ocsr.order_sentence_id
       AND os.usage_flag IN (0, 1))
      JOIN (fer
      WHERE fer.parent_entity_id=os.order_sentence_id
       AND fer.filter_type_cd=ord_sent_filter_cd
       AND fer.filter_entity1_id IN (0, facilitycd))
      JOIN (osd)
      JOIN (cve)
     ORDER BY ocs.catalog_cd, ocs.synonym_id, ocsr.display_seq,
      os.order_sentence_display_line, os.order_sentence_id, ofm.oe_field_meaning_id,
      osd.oe_field_id
     HEAD REPORT
      rowcnt = 0, sentcnt = 0, missingdetailcnt = 0
     HEAD os.order_sentence_id
      rowcnt = (rowcnt+ 1)
      IF (mod(rowcnt,50)=1)
       stat = alterlist(ord_sents->list,(rowcnt+ 49))
      ENDIF
      IF (os.order_sentence_id > 0)
       sentcnt = (sentcnt+ 1)
      ENDIF
      ord_sents->list[rowcnt].os_vv_fac = fer.filter_entity1_id, ord_sents->list[rowcnt].catalog_cd
       = oc.catalog_cd, ord_sents->list[rowcnt].mnemonic = ocs.mnemonic,
      ord_sents->list[rowcnt].primary_disp = oc.primary_mnemonic, ord_sents->list[rowcnt].
      mnemonic_type_cd = ocs.mnemonic_type_cd, ord_sents->list[rowcnt].syn_oef = oefp.oe_format_name,
      ord_sents->list[rowcnt].syn_oe_format_id = ocs.oe_format_id, ord_sents->list[rowcnt].
      os_oe_format_id = os.oe_format_id, ord_sents->list[rowcnt].orderable_type_flag = oc
      .orderable_type_flag,
      ord_sents->list[rowcnt].os_disp_line = os.order_sentence_display_line, ord_sents->list[rowcnt].
      order_sentence_id = os.order_sentence_id, ord_sents->list[rowcnt].rx_mask = ocs.rx_mask,
      ord_sents->list[rowcnt].synonym_id = ocs.synonym_id
     HEAD ofm.oe_field_meaning_id
      fieldfoundind = 0
     HEAD osd.oe_field_id
      IF (ofm.oe_field_meaning_id=osd.oe_field_meaning_id)
       fieldfoundind = 1
      ENDIF
      CASE (osd.oe_field_id)
       OF strengthdosefieldid:
        ord_sents->list[rowcnt].strength = osd.oe_field_value
       OF strengthdoseunitfieldid:
        ord_sents->list[rowcnt].strength_unit_cd = osd.default_parent_entity_id
       OF volumedosefieldid:
        ord_sents->list[rowcnt].volume = osd.oe_field_value
       OF volumedoseunitfieldid:
        ord_sents->list[rowcnt].volume_unit_cd = osd.default_parent_entity_id
       OF freetextdosefieldid:
        ord_sents->list[rowcnt].freetext_dose = osd.oe_field_display_value
       OF routefieldid:
        ord_sents->list[rowcnt].route_cd = osd.default_parent_entity_id
       OF formfieldid:
        ord_sents->list[rowcnt].form_cd = osd.default_parent_entity_id
       OF ratefieldid:
        ord_sents->list[rowcnt].rate = osd.oe_field_value
       OF infuseoverfieldid:
        ord_sents->list[rowcnt].infuse_over = osd.oe_field_value
      ENDCASE
      IF (osd.oe_field_id IN (strengthdoseunitfieldid, volumedoseunitfieldid)
       AND band(cnvtint(cve.field_value),32) > 0)
       ord_sents->list[rowcnt].normalized_unit_ind = 1
      ENDIF
     FOOT  ofm.oe_field_meaning_id
      IF (fieldfoundind=0
       AND ofm.oe_field_meaning_id > 0)
       IF (((oeff.default_parent_entity_id > 0) OR (oeff.default_value > " ")) )
        CASE (oeff.oe_field_id)
         OF strengthdosefieldid:
          ord_sents->list[rowcnt].strength = cnvtreal(oeff.default_value),ord_sents->list[rowcnt].
          os_disp_line = build2(ord_sents->list[rowcnt].os_disp_line," = Strength Dose of ",trim(oeff
            .default_value)," defaulted from OEF")
         OF strengthdoseunitfieldid:
          ord_sents->list[rowcnt].strength_unit_cd = oeff.default_parent_entity_id,ord_sents->list[
          rowcnt].os_disp_line = build2(ord_sents->list[rowcnt].os_disp_line,
           " = Strength Dose Unit of ",trim(uar_get_code_display(oeff.default_parent_entity_id)),
           " defaulted from OEF")
         OF volumedosefieldid:
          ord_sents->list[rowcnt].volume = cnvtreal(oeff.default_value),ord_sents->list[rowcnt].
          os_disp_line = build2(ord_sents->list[rowcnt].os_disp_line," = Volume Dose of ",trim(oeff
            .default_value)," defaulted from OEF")
         OF volumedoseunitfieldid:
          ord_sents->list[rowcnt].volume_unit_cd = oeff.default_parent_entity_id,ord_sents->list[
          rowcnt].os_disp_line = build2(ord_sents->list[rowcnt].os_disp_line,
           " = Volume Dose Unit of ",trim(uar_get_code_display(oeff.default_parent_entity_id)),
           " defaulted from OEF")
         OF freetextdosefieldid:
          ord_sents->list[rowcnt].freetext_dose = oeff.default_value,ord_sents->list[rowcnt].
          os_disp_line = build2(ord_sents->list[rowcnt].os_disp_line," = Freetext Dose of ",trim(oeff
            .default_value)," defaulted from OEF")
         OF routefieldid:
          ord_sents->list[rowcnt].route_cd = oeff.default_parent_entity_id,ord_sents->list[rowcnt].
          os_disp_line = build2(ord_sents->list[rowcnt].os_disp_line," = Route of ",trim(
            uar_get_code_display(oeff.default_parent_entity_id))," defaulted from OEF")
         OF formfieldid:
          ord_sents->list[rowcnt].form_cd = oeff.default_parent_entity_id,ord_sents->list[rowcnt].
          os_disp_line = build2(ord_sents->list[rowcnt].os_disp_line," = Form of ",trim(
            uar_get_code_display(oeff.default_parent_entity_id))," defaulted from OEF")
         OF ratefieldid:
          ord_sents->list[rowcnt].rate = cnvtreal(oeff.default_value),ord_sents->list[rowcnt].
          os_disp_line = build2(ord_sents->list[rowcnt].os_disp_line," = Rate of ",trim(oeff
            .default_value)," defaulted from OEF")
         OF infuseoverfieldid:
          ord_sents->list[rowcnt].infuse_over = cnvtreal(oeff.default_value),ord_sents->list[rowcnt].
          os_disp_line = build2(ord_sents->list[rowcnt].os_disp_line," = Infuse Over of ",trim(oeff
            .default_value)," defaulted from OEF")
        ENDCASE
       ELSE
        missingtext = ord_sents->list[rowcnt].missing_field_text
        IF (ofm.oe_field_meaning IN ("STRENGTHDOSE", "STRENGTHDOSEUNIT", "VOLUMEDOSE",
        "VOLUMEDOSEUNIT", "FREETXTDOSE",
        "RXROUTE", "DRUGFORM"))
         ord_sents->list[rowcnt].incomplete_os_ind = 1
        ENDIF
        IF (missingtext="")
         missingdetailcnt = (missingdetailcnt+ 1), missingtext = build2("Sentence is missing a ",oeff
          .label_text)
        ELSE
         missingtext = build2(missingtext,", ",oeff.label_text)
        ENDIF
        ord_sents->list[rowcnt].missing_field_text = missingtext
       ENDIF
      ENDIF
     FOOT REPORT
      IF (mod(rowcnt,50) != 0)
       stat = alterlist(ord_sents->list,rowcnt)
      ENDIF
     WITH nocounter
    ;end select
   ELSEIF (searchmode=search_by_primary)
    SELECT INTO "nl:"
     ocs.mnemonic, ofr.facility_cd, oefp.oe_format_name,
     os.order_sentence_display_line
     FROM order_catalog_synonym ocs,
      order_entry_format_parent oefp,
      (left JOIN oe_format_fields oeff ON oeff.oe_format_id=oefp.oe_format_id
       AND oeff.action_type_cd=action_order_cd
       AND ((oeff.value_required_ind=1) OR (oeff.accept_flag=0)) ),
      (left JOIN order_entry_fields oef ON oef.oe_field_id=oeff.oe_field_id),
      (left JOIN oe_field_meaning ofm ON ofm.oe_field_meaning_id=oef.oe_field_meaning_id
       AND ofm.oe_field_meaning != "REQSTARTDTTM"),
      order_catalog oc,
      ocs_facility_r ofr,
      (left JOIN ord_cat_sent_r ocsr ON ocsr.synonym_id=ofr.synonym_id
       AND  EXISTS (
      (SELECT
       fer2.parent_entity_id
       FROM filter_entity_reltn fer2
       WHERE fer2.parent_entity_id=ocsr.order_sentence_id
        AND fer2.filter_type_cd=ord_sent_filter_cd
        AND fer2.filter_entity1_id IN (0, facilitycd)))),
      (left JOIN order_sentence os ON os.order_sentence_id=ocsr.order_sentence_id
       AND os.usage_flag IN (0, 1)),
      (left JOIN filter_entity_reltn fer ON fer.parent_entity_id=os.order_sentence_id
       AND fer.filter_type_cd=ord_sent_filter_cd
       AND fer.filter_entity1_id IN (0, facilitycd)),
      (left JOIN order_sentence_detail osd ON osd.order_sentence_id=fer.parent_entity_id),
      (left JOIN code_value_extension cve ON cve.code_value=osd.default_parent_entity_id
       AND cve.code_set=54
       AND cve.field_name="PHARM_UNIT")
     PLAN (ocs
      WHERE ocs.catalog_type_cd=pharm_cat_cd
       AND ocs.activity_type_cd=pharm_act_cd
       AND ocs.catalog_cd=searchid
       AND  NOT (ocs.mnemonic_type_cd IN (syn_type_rx, syn_type_y, syn_type_z))
       AND ocs.active_ind=1
       AND ((ocs.hide_flag = null) OR (ocs.hide_flag=0)) )
      JOIN (oefp
      WHERE oefp.oe_format_id=ocs.oe_format_id)
      JOIN (oeff)
      JOIN (oef)
      JOIN (ofm)
      JOIN (oc
      WHERE oc.catalog_cd=ocs.catalog_cd
       AND oc.orderable_type_flag IN (0, 1))
      JOIN (ofr
      WHERE ofr.synonym_id=ocs.synonym_id
       AND ofr.facility_cd IN (0, facilitycd))
      JOIN (ocsr)
      JOIN (os)
      JOIN (fer)
      JOIN (osd)
      JOIN (cve)
     ORDER BY ocs.catalog_cd, ocs.synonym_id, ocsr.display_seq,
      os.order_sentence_display_line, os.order_sentence_id, ofm.oe_field_meaning_id,
      osd.oe_field_id
     HEAD REPORT
      rowcnt = 0, sentcnt = 0, missingdetailcnt = 0,
      nosenterrorcnt = 0
     HEAD ocs.synonym_id
      IF (os.order_sentence_id=0
       AND ocsr.order_sentence_id=0)
       rowcnt = (rowcnt+ 1)
       IF (mod(rowcnt,50)=1)
        stat = alterlist(ord_sents->list,(rowcnt+ 49))
       ENDIF
       ord_sents->list[rowcnt].synonym_vv_fac = ofr.facility_cd, ord_sents->list[rowcnt].catalog_cd
        = oc.catalog_cd, ord_sents->list[rowcnt].mnemonic = ocs.mnemonic,
       ord_sents->list[rowcnt].primary_disp = oc.primary_mnemonic, ord_sents->list[rowcnt].
       mnemonic_type_cd = ocs.mnemonic_type_cd, ord_sents->list[rowcnt].syn_oef = oefp.oe_format_name,
       ord_sents->list[rowcnt].syn_oe_format_id = ocs.oe_format_id, ord_sents->list[rowcnt].
       orderable_type_flag = oc.orderable_type_flag, ord_sents->list[rowcnt].rx_mask = ocs.rx_mask,
       ord_sents->list[rowcnt].synonym_id = ocs.synonym_id, ord_sents->list[rowcnt].os_disp_line =
       "None", ord_sents->list[rowcnt].incomplete_os_ind = 1
      ENDIF
     HEAD os.order_sentence_id
      IF (os.order_sentence_id > 0)
       sentcnt = (sentcnt+ 1), rowcnt = (rowcnt+ 1)
       IF (mod(rowcnt,50)=1)
        stat = alterlist(ord_sents->list,(rowcnt+ 49))
       ENDIF
       ord_sents->list[rowcnt].os_vv_fac = fer.filter_entity1_id, ord_sents->list[rowcnt].
       synonym_vv_fac = ofr.facility_cd, ord_sents->list[rowcnt].catalog_cd = oc.catalog_cd,
       ord_sents->list[rowcnt].mnemonic = ocs.mnemonic, ord_sents->list[rowcnt].primary_disp = oc
       .primary_mnemonic, ord_sents->list[rowcnt].mnemonic_type_cd = ocs.mnemonic_type_cd,
       ord_sents->list[rowcnt].syn_oef = oefp.oe_format_name, ord_sents->list[rowcnt].
       syn_oe_format_id = ocs.oe_format_id, ord_sents->list[rowcnt].os_oe_format_id = os.oe_format_id,
       ord_sents->list[rowcnt].orderable_type_flag = oc.orderable_type_flag, ord_sents->list[rowcnt].
       os_disp_line = os.order_sentence_display_line, ord_sents->list[rowcnt].order_sentence_id = os
       .order_sentence_id,
       ord_sents->list[rowcnt].rx_mask = ocs.rx_mask, ord_sents->list[rowcnt].synonym_id = ocs
       .synonym_id
      ELSEIF (ocsr.order_sentence_id=0)
       nosenterrorcnt = (nosenterrorcnt+ 1)
      ENDIF
     HEAD ofm.oe_field_meaning_id
      fieldfoundind = 0
     HEAD osd.oe_field_id
      IF (ofm.oe_field_meaning_id=osd.oe_field_meaning_id)
       fieldfoundind = 1
      ENDIF
      CASE (osd.oe_field_id)
       OF strengthdosefieldid:
        ord_sents->list[rowcnt].strength = osd.oe_field_value
       OF strengthdoseunitfieldid:
        ord_sents->list[rowcnt].strength_unit_cd = osd.default_parent_entity_id
       OF volumedosefieldid:
        ord_sents->list[rowcnt].volume = osd.oe_field_value
       OF volumedoseunitfieldid:
        ord_sents->list[rowcnt].volume_unit_cd = osd.default_parent_entity_id
       OF freetextdosefieldid:
        ord_sents->list[rowcnt].freetext_dose = osd.oe_field_display_value
       OF routefieldid:
        ord_sents->list[rowcnt].route_cd = osd.default_parent_entity_id
       OF formfieldid:
        ord_sents->list[rowcnt].form_cd = osd.default_parent_entity_id
       OF ratefieldid:
        ord_sents->list[rowcnt].rate = osd.oe_field_value
       OF infuseoverfieldid:
        ord_sents->list[rowcnt].infuse_over = osd.oe_field_value
      ENDCASE
      IF (osd.oe_field_id IN (strengthdoseunitfieldid, volumedoseunitfieldid)
       AND band(cnvtint(cve.field_value),32) > 0)
       ord_sents->list[rowcnt].normalized_unit_ind = 1
      ENDIF
     FOOT  ofm.oe_field_meaning_id
      IF (fieldfoundind=0
       AND ofm.oe_field_meaning_id > 0
       AND os.order_sentence_id > 0)
       IF (((oeff.default_parent_entity_id > 0) OR (oeff.default_value > " ")) )
        CASE (oeff.oe_field_id)
         OF strengthdosefieldid:
          ord_sents->list[rowcnt].strength = cnvtreal(oeff.default_value),ord_sents->list[rowcnt].
          os_disp_line = build2(ord_sents->list[rowcnt].os_disp_line," = Strength Dose of ",trim(oeff
            .default_value)," defaulted from OEF")
         OF strengthdoseunitfieldid:
          ord_sents->list[rowcnt].strength_unit_cd = oeff.default_parent_entity_id,ord_sents->list[
          rowcnt].os_disp_line = build2(ord_sents->list[rowcnt].os_disp_line,
           " = Strength Dose Unit of ",trim(uar_get_code_display(oeff.default_parent_entity_id)),
           " defaulted from OEF")
         OF volumedosefieldid:
          ord_sents->list[rowcnt].volume = cnvtreal(oeff.default_value),ord_sents->list[rowcnt].
          os_disp_line = build2(ord_sents->list[rowcnt].os_disp_line," = Volume Dose of ",trim(oeff
            .default_value)," defaulted from OEF")
         OF volumedoseunitfieldid:
          ord_sents->list[rowcnt].volume_unit_cd = oeff.default_parent_entity_id,ord_sents->list[
          rowcnt].os_disp_line = build2(ord_sents->list[rowcnt].os_disp_line,
           " = Volume Dose Unit of ",trim(uar_get_code_display(oeff.default_parent_entity_id)),
           " defaulted from OEF")
         OF freetextdosefieldid:
          ord_sents->list[rowcnt].freetext_dose = oeff.default_value,ord_sents->list[rowcnt].
          os_disp_line = build2(ord_sents->list[rowcnt].os_disp_line," = Freetext Dose of ",trim(oeff
            .default_value)," defaulted from OEF")
         OF routefieldid:
          ord_sents->list[rowcnt].route_cd = oeff.default_parent_entity_id,ord_sents->list[rowcnt].
          os_disp_line = build2(ord_sents->list[rowcnt].os_disp_line," = Route of ",trim(
            uar_get_code_display(oeff.default_parent_entity_id))," defaulted from OEF")
         OF formfieldid:
          ord_sents->list[rowcnt].form_cd = oeff.default_parent_entity_id,ord_sents->list[rowcnt].
          os_disp_line = build2(ord_sents->list[rowcnt].os_disp_line," = Form of ",trim(
            uar_get_code_display(oeff.default_parent_entity_id))," defaulted from OEF")
         OF ratefieldid:
          ord_sents->list[rowcnt].rate = cnvtreal(oeff.default_value),ord_sents->list[rowcnt].
          os_disp_line = build2(ord_sents->list[rowcnt].os_disp_line," = Rate of ",trim(oeff
            .default_value)," defaulted from OEF")
         OF infuseoverfieldid:
          ord_sents->list[rowcnt].infuse_over = cnvtreal(oeff.default_value),ord_sents->list[rowcnt].
          os_disp_line = build2(ord_sents->list[rowcnt].os_disp_line," = Infuse Over of ",trim(oeff
            .default_value)," defaulted from OEF")
        ENDCASE
       ELSE
        missingtext = ord_sents->list[rowcnt].missing_field_text
        IF (ofm.oe_field_meaning IN ("STRENGTHDOSE", "STRENGTHDOSEUNIT", "VOLUMEDOSE",
        "VOLUMEDOSEUNIT", "FREETXTDOSE",
        "RXROUTE", "DRUGFORM"))
         ord_sents->list[rowcnt].incomplete_os_ind = 1
        ENDIF
        IF (missingtext="")
         missingdetailcnt = (missingdetailcnt+ 1), missingtext = build2("Sentence is missing a ",oeff
          .label_text)
        ELSE
         missingtext = build2(missingtext,", ",oeff.label_text)
        ENDIF
        ord_sents->list[rowcnt].missing_field_text = missingtext
       ENDIF
      ENDIF
     FOOT REPORT
      IF (mod(rowcnt,50) != 0)
       stat = alterlist(ord_sents->list,rowcnt)
      ENDIF
     WITH nocounter
    ;end select
   ELSEIF (searchmode=search_by_all_primary)
    SELECT INTO "nl:"
     ocs.mnemonic, ofr.facility_cd, oefp.oe_format_name,
     os.order_sentence_display_line
     FROM order_catalog_synonym ocs,
      order_entry_format_parent oefp,
      (left JOIN oe_format_fields oeff ON oeff.oe_format_id=oefp.oe_format_id
       AND oeff.action_type_cd=action_order_cd
       AND ((oeff.value_required_ind=1) OR (oeff.accept_flag=0)) ),
      (left JOIN order_entry_fields oef ON oef.oe_field_id=oeff.oe_field_id),
      (left JOIN oe_field_meaning ofm ON ofm.oe_field_meaning_id=oef.oe_field_meaning_id
       AND ofm.oe_field_meaning != "REQSTARTDTTM"),
      order_catalog oc,
      ocs_facility_r ofr,
      (left JOIN ord_cat_sent_r ocsr ON ocsr.synonym_id=ofr.synonym_id
       AND  EXISTS (
      (SELECT
       fer2.parent_entity_id
       FROM filter_entity_reltn fer2
       WHERE fer2.parent_entity_id=ocsr.order_sentence_id
        AND fer2.filter_type_cd=ord_sent_filter_cd
        AND fer2.filter_entity1_id IN (0, facilitycd)))),
      (left JOIN order_sentence os ON os.order_sentence_id=ocsr.order_sentence_id
       AND os.usage_flag IN (0, 1)),
      (left JOIN filter_entity_reltn fer ON fer.parent_entity_id=os.order_sentence_id
       AND fer.filter_type_cd=ord_sent_filter_cd
       AND fer.filter_entity1_id IN (0, facilitycd)),
      (left JOIN order_sentence_detail osd ON osd.order_sentence_id=fer.parent_entity_id),
      (left JOIN code_value_extension cve ON cve.code_value=osd.default_parent_entity_id
       AND cve.code_set=54
       AND cve.field_name="PHARM_UNIT")
     PLAN (ocs
      WHERE ocs.catalog_type_cd=pharm_cat_cd
       AND ocs.activity_type_cd=pharm_act_cd
       AND  NOT (ocs.mnemonic_type_cd IN (syn_type_rx, syn_type_y, syn_type_z))
       AND ocs.active_ind=1
       AND ((ocs.hide_flag = null) OR (ocs.hide_flag=0)) )
      JOIN (oefp
      WHERE oefp.oe_format_id=ocs.oe_format_id)
      JOIN (oeff)
      JOIN (oef)
      JOIN (ofm)
      JOIN (oc
      WHERE oc.catalog_cd=ocs.catalog_cd
       AND oc.orderable_type_flag IN (0, 1))
      JOIN (ofr
      WHERE ofr.synonym_id=ocs.synonym_id
       AND ofr.facility_cd IN (0, facilitycd))
      JOIN (ocsr)
      JOIN (os)
      JOIN (fer)
      JOIN (osd)
      JOIN (cve)
     ORDER BY ocs.catalog_cd, ocs.synonym_id, ocsr.display_seq,
      os.order_sentence_display_line, os.order_sentence_id, ofm.oe_field_meaning_id,
      osd.oe_field_id
     HEAD REPORT
      rowcnt = 0, sentcnt = 0, missingdetailcnt = 0,
      nosenterrorcnt = 0
     HEAD ocs.synonym_id
      IF (os.order_sentence_id=0
       AND ocsr.order_sentence_id=0)
       rowcnt = (rowcnt+ 1)
       IF (mod(rowcnt,1000)=1)
        stat = alterlist(ord_sents->list,(rowcnt+ 999))
       ENDIF
       ord_sents->list[rowcnt].synonym_vv_fac = ofr.facility_cd, ord_sents->list[rowcnt].catalog_cd
        = oc.catalog_cd, ord_sents->list[rowcnt].mnemonic = ocs.mnemonic,
       ord_sents->list[rowcnt].primary_disp = oc.primary_mnemonic, ord_sents->list[rowcnt].
       mnemonic_type_cd = ocs.mnemonic_type_cd, ord_sents->list[rowcnt].syn_oef = oefp.oe_format_name,
       ord_sents->list[rowcnt].syn_oe_format_id = ocs.oe_format_id, ord_sents->list[rowcnt].
       orderable_type_flag = oc.orderable_type_flag, ord_sents->list[rowcnt].rx_mask = ocs.rx_mask,
       ord_sents->list[rowcnt].synonym_id = ocs.synonym_id, ord_sents->list[rowcnt].os_disp_line =
       "None", ord_sents->list[rowcnt].incomplete_os_ind = 1
      ENDIF
     HEAD os.order_sentence_id
      IF (os.order_sentence_id > 0)
       sentcnt = (sentcnt+ 1), rowcnt = (rowcnt+ 1)
       IF (mod(rowcnt,1000)=1)
        stat = alterlist(ord_sents->list,(rowcnt+ 999))
       ENDIF
       ord_sents->list[rowcnt].os_vv_fac = fer.filter_entity1_id, ord_sents->list[rowcnt].
       synonym_vv_fac = ofr.facility_cd, ord_sents->list[rowcnt].catalog_cd = oc.catalog_cd,
       ord_sents->list[rowcnt].mnemonic = ocs.mnemonic, ord_sents->list[rowcnt].primary_disp = oc
       .primary_mnemonic, ord_sents->list[rowcnt].mnemonic_type_cd = ocs.mnemonic_type_cd,
       ord_sents->list[rowcnt].syn_oef = oefp.oe_format_name, ord_sents->list[rowcnt].
       syn_oe_format_id = ocs.oe_format_id, ord_sents->list[rowcnt].os_oe_format_id = os.oe_format_id,
       ord_sents->list[rowcnt].orderable_type_flag = oc.orderable_type_flag, ord_sents->list[rowcnt].
       os_disp_line = os.order_sentence_display_line, ord_sents->list[rowcnt].order_sentence_id = os
       .order_sentence_id,
       ord_sents->list[rowcnt].rx_mask = ocs.rx_mask, ord_sents->list[rowcnt].synonym_id = ocs
       .synonym_id
      ELSEIF (ocsr.order_sentence_id=0)
       nosenterrorcnt = (nosenterrorcnt+ 1)
      ENDIF
     HEAD ofm.oe_field_meaning_id
      fieldfoundind = 0
     HEAD osd.oe_field_id
      IF (ofm.oe_field_meaning_id=osd.oe_field_meaning_id)
       fieldfoundind = 1
      ENDIF
      CASE (osd.oe_field_id)
       OF strengthdosefieldid:
        ord_sents->list[rowcnt].strength = osd.oe_field_value
       OF strengthdoseunitfieldid:
        ord_sents->list[rowcnt].strength_unit_cd = osd.default_parent_entity_id
       OF volumedosefieldid:
        ord_sents->list[rowcnt].volume = osd.oe_field_value
       OF volumedoseunitfieldid:
        ord_sents->list[rowcnt].volume_unit_cd = osd.default_parent_entity_id
       OF freetextdosefieldid:
        ord_sents->list[rowcnt].freetext_dose = osd.oe_field_display_value
       OF routefieldid:
        ord_sents->list[rowcnt].route_cd = osd.default_parent_entity_id
       OF formfieldid:
        ord_sents->list[rowcnt].form_cd = osd.default_parent_entity_id
       OF ratefieldid:
        ord_sents->list[rowcnt].rate = osd.oe_field_value
       OF infuseoverfieldid:
        ord_sents->list[rowcnt].infuse_over = osd.oe_field_value
      ENDCASE
      IF (osd.oe_field_id IN (strengthdoseunitfieldid, volumedoseunitfieldid)
       AND band(cnvtint(cve.field_value),32) > 0)
       ord_sents->list[rowcnt].normalized_unit_ind = 1
      ENDIF
     FOOT  ofm.oe_field_meaning_id
      IF (fieldfoundind=0
       AND ofm.oe_field_meaning_id > 0
       AND os.order_sentence_id > 0)
       IF (((oeff.default_parent_entity_id > 0) OR (oeff.default_value > " ")) )
        CASE (oeff.oe_field_id)
         OF strengthdosefieldid:
          ord_sents->list[rowcnt].strength = cnvtreal(oeff.default_value),ord_sents->list[rowcnt].
          os_disp_line = build2(ord_sents->list[rowcnt].os_disp_line," = Strength Dose of ",trim(oeff
            .default_value)," defaulted from OEF")
         OF strengthdoseunitfieldid:
          ord_sents->list[rowcnt].strength_unit_cd = oeff.default_parent_entity_id,ord_sents->list[
          rowcnt].os_disp_line = build2(ord_sents->list[rowcnt].os_disp_line,
           " = Strength Dose Unit of ",trim(uar_get_code_display(oeff.default_parent_entity_id)),
           " defaulted from OEF")
         OF volumedosefieldid:
          ord_sents->list[rowcnt].volume = cnvtreal(oeff.default_value),ord_sents->list[rowcnt].
          os_disp_line = build2(ord_sents->list[rowcnt].os_disp_line," = Volume Dose of ",trim(oeff
            .default_value)," defaulted from OEF")
         OF volumedoseunitfieldid:
          ord_sents->list[rowcnt].volume_unit_cd = oeff.default_parent_entity_id,ord_sents->list[
          rowcnt].os_disp_line = build2(ord_sents->list[rowcnt].os_disp_line,
           " = Volume Dose Unit of ",trim(uar_get_code_display(oeff.default_parent_entity_id)),
           " defaulted from OEF")
         OF freetextdosefieldid:
          ord_sents->list[rowcnt].freetext_dose = oeff.default_value,ord_sents->list[rowcnt].
          os_disp_line = build2(ord_sents->list[rowcnt].os_disp_line," = Freetext Dose of ",trim(oeff
            .default_value)," defaulted from OEF")
         OF routefieldid:
          ord_sents->list[rowcnt].route_cd = oeff.default_parent_entity_id,ord_sents->list[rowcnt].
          os_disp_line = build2(ord_sents->list[rowcnt].os_disp_line," = Route of ",trim(
            uar_get_code_display(oeff.default_parent_entity_id))," defaulted from OEF")
         OF formfieldid:
          ord_sents->list[rowcnt].form_cd = oeff.default_parent_entity_id,ord_sents->list[rowcnt].
          os_disp_line = build2(ord_sents->list[rowcnt].os_disp_line," = Form of ",trim(
            uar_get_code_display(oeff.default_parent_entity_id))," defaulted from OEF")
         OF ratefieldid:
          ord_sents->list[rowcnt].rate = cnvtreal(oeff.default_value),ord_sents->list[rowcnt].
          os_disp_line = build2(ord_sents->list[rowcnt].os_disp_line," = Rate of ",trim(oeff
            .default_value)," defaulted from OEF")
         OF infuseoverfieldid:
          ord_sents->list[rowcnt].infuse_over = cnvtreal(oeff.default_value),ord_sents->list[rowcnt].
          os_disp_line = build2(ord_sents->list[rowcnt].os_disp_line," = Infuse Over of ",trim(oeff
            .default_value)," defaulted from OEF")
        ENDCASE
       ELSE
        missingtext = ord_sents->list[rowcnt].missing_field_text
        IF (ofm.oe_field_meaning IN ("STRENGTHDOSE", "STRENGTHDOSEUNIT", "VOLUMEDOSE",
        "VOLUMEDOSEUNIT", "FREETXTDOSE",
        "RXROUTE", "DRUGFORM"))
         ord_sents->list[rowcnt].incomplete_os_ind = 1
        ENDIF
        IF (missingtext="")
         missingdetailcnt = (missingdetailcnt+ 1), missingtext = build2("Sentence is missing a ",oeff
          .label_text)
        ELSE
         missingtext = build2(missingtext,", ",oeff.label_text)
        ENDIF
        ord_sents->list[rowcnt].missing_field_text = missingtext
       ENDIF
      ENDIF
     FOOT REPORT
      IF (mod(rowcnt,1000) != 0)
       stat = alterlist(ord_sents->list,rowcnt)
      ENDIF
     WITH nocounter
    ;end select
   ELSEIF (searchmode=search_by_powerplan)
    SELECT INTO "nl:"
     pc.type_mean
     FROM pathway_catalog pc
     PLAN (pc
      WHERE pc.pathway_catalog_id=searchid
       AND pc.active_ind=1
       AND pc.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND pc.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
     DETAIL
      plantype = pc.type_mean
     WITH nocounter
    ;end select
    SELECT
     IF (plantype="CAREPLAN")INTO "nl:"
      ocs.mnemonic, oefp.oe_format_name, os.order_sentence_display_line,
      clinical_cat = uar_get_code_display(pcmp.dcp_clin_cat_cd), sub_clin_cat = uar_get_code_display(
       pcmp.dcp_clin_sub_cat_cd)
      FROM pathway_catalog pc,
       pw_cat_flex pcf,
       order_catalog_synonym ocs,
       (left JOIN ocs_facility_r ofr ON ofr.synonym_id=ocs.synonym_id
        AND ofr.facility_cd IN (0, facilitycd)),
       order_catalog oc,
       order_entry_format_parent oefp,
       (left JOIN oe_format_fields oeff ON oeff.oe_format_id=oefp.oe_format_id
        AND oeff.action_type_cd=action_order_cd
        AND ((oeff.value_required_ind=1) OR (oeff.accept_flag=0)) ),
       (left JOIN order_entry_fields oef ON oef.oe_field_id=oeff.oe_field_id),
       (left JOIN oe_field_meaning ofm ON ofm.oe_field_meaning_id=oef.oe_field_meaning_id
        AND ofm.oe_field_meaning != "REQSTARTDTTM"),
       pathway_comp pcmp,
       (left JOIN pw_comp_os_reltn pcor ON pcor.pathway_comp_id=pcmp.pathway_comp_id),
       (left JOIN order_sentence os ON os.order_sentence_id=pcor.order_sentence_id),
       (left JOIN order_sentence_detail osd ON osd.order_sentence_id=os.order_sentence_id),
       (left JOIN code_value_extension cve ON cve.code_value=osd.default_parent_entity_id
        AND cve.code_set=54
        AND cve.field_name="PHARM_UNIT")
      PLAN (pc
       WHERE pc.pathway_catalog_id=searchid
        AND pc.type_mean="CAREPLAN"
        AND pc.active_ind=1
        AND pc.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND pc.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
       JOIN (pcf
       WHERE pcf.pathway_catalog_id=pc.pathway_catalog_id
        AND pcf.parent_entity_name="CODE_VALUE"
        AND pcf.parent_entity_id IN (0, facilitycd))
       JOIN (pcmp
       WHERE pcmp.pathway_catalog_id=pc.pathway_catalog_id
        AND pcmp.active_ind=1
        AND pcmp.parent_entity_name="ORDER_CATALOG_SYNONYM")
       JOIN (ocs
       WHERE ocs.synonym_id=pcmp.parent_entity_id
        AND ocs.catalog_type_cd=pharm_cat_cd
        AND ocs.activity_type_cd=pharm_act_cd)
       JOIN (ofr)
       JOIN (oc
       WHERE oc.catalog_cd=ocs.catalog_cd
        AND oc.orderable_type_flag IN (0, 1))
       JOIN (oefp
       WHERE oefp.oe_format_id=ocs.oe_format_id)
       JOIN (oeff)
       JOIN (oef)
       JOIN (ofm)
       JOIN (pcor)
       JOIN (os)
       JOIN (osd)
       JOIN (cve)
     ELSEIF (plantype="PATHWAY")INTO "nl:"
      ocs.mnemonic, oefp.oe_format_name, os.order_sentence_display_line,
      clinical_cat = uar_get_code_display(pcmp.dcp_clin_cat_cd), sub_clin_cat = uar_get_code_display(
       pcmp.dcp_clin_sub_cat_cd)
      FROM pathway_catalog pc,
       pw_cat_reltn pcr,
       pw_cat_flex pcf,
       order_catalog_synonym ocs,
       (left JOIN ocs_facility_r ofr ON ofr.synonym_id=ocs.synonym_id
        AND ofr.facility_cd IN (0, facilitycd)),
       order_catalog oc,
       order_entry_format_parent oefp,
       (left JOIN oe_format_fields oeff ON oeff.oe_format_id=oefp.oe_format_id
        AND oeff.action_type_cd=action_order_cd
        AND ((oeff.value_required_ind=1) OR (oeff.accept_flag=0)) ),
       (left JOIN order_entry_fields oef ON oef.oe_field_id=oeff.oe_field_id),
       (left JOIN oe_field_meaning ofm ON ofm.oe_field_meaning_id=oef.oe_field_meaning_id
        AND ofm.oe_field_meaning != "REQSTARTDTTM"),
       pathway_comp pcmp,
       (left JOIN pw_comp_os_reltn pcor ON pcor.pathway_comp_id=pcmp.pathway_comp_id),
       (left JOIN order_sentence os ON os.order_sentence_id=pcor.order_sentence_id),
       (left JOIN order_sentence_detail osd ON osd.order_sentence_id=os.order_sentence_id),
       (left JOIN code_value_extension cve ON cve.code_value=osd.default_parent_entity_id
        AND cve.code_set=54
        AND cve.field_name="PHARM_UNIT")
      PLAN (pc
       WHERE pc.pathway_catalog_id=searchid
        AND pc.type_mean="PATHWAY"
        AND pc.active_ind=1
        AND pc.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND pc.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
       JOIN (pcr
       WHERE pcr.pw_cat_s_id=pc.pathway_catalog_id)
       JOIN (pcf
       WHERE pcf.pathway_catalog_id=pc.pathway_catalog_id
        AND pcf.parent_entity_name="CODE_VALUE"
        AND pcf.parent_entity_id IN (0, facilitycd))
       JOIN (pcmp
       WHERE pcmp.pathway_catalog_id=pcr.pw_cat_t_id
        AND pcmp.active_ind=1
        AND pcmp.parent_entity_name="ORDER_CATALOG_SYNONYM")
       JOIN (ocs
       WHERE ocs.synonym_id=pcmp.parent_entity_id
        AND ocs.catalog_type_cd=pharm_cat_cd
        AND ocs.activity_type_cd=pharm_act_cd)
       JOIN (ofr)
       JOIN (oc
       WHERE oc.catalog_cd=ocs.catalog_cd
        AND oc.orderable_type_flag IN (0, 1))
       JOIN (oefp
       WHERE oefp.oe_format_id=ocs.oe_format_id)
       JOIN (oeff)
       JOIN (oef)
       JOIN (ofm)
       JOIN (pcor)
       JOIN (os)
       JOIN (osd)
       JOIN (cve)
     ELSE
     ENDIF
     ORDER BY pc.description_key, clinical_cat, sub_clin_cat,
      ocs.mnemonic_key_cap, pcor.order_sentence_seq, os.order_sentence_id,
      ofm.oe_field_meaning_id, osd.oe_field_id
     HEAD REPORT
      rowcnt = 0, sentcnt = 0, missingdetailcnt = 0,
      nosenterrorcnt = 0
     HEAD ocs.synonym_id
      IF (os.order_sentence_id=0)
       rowcnt = (rowcnt+ 1)
       IF (mod(rowcnt,50)=1)
        stat = alterlist(ord_sents->list,(rowcnt+ 49))
       ENDIF
       ord_sents->list[rowcnt].pathway_catalog_id = pc.pathway_catalog_id, ord_sents->list[rowcnt].
       dcp_clin_cat_cd = pcmp.dcp_clin_cat_cd, ord_sents->list[rowcnt].dcp_clin_sub_cat_cd = pcmp
       .dcp_clin_sub_cat_cd,
       ord_sents->list[rowcnt].plan_disp = pc.description
       IF (ofr.synonym_id=0)
        ord_sents->list[rowcnt].synonym_vv_fac = - (1.0)
       ELSE
        ord_sents->list[rowcnt].synonym_vv_fac = ofr.facility_cd
       ENDIF
       ord_sents->list[rowcnt].catalog_cd = oc.catalog_cd, ord_sents->list[rowcnt].mnemonic = ocs
       .mnemonic, ord_sents->list[rowcnt].primary_disp = oc.primary_mnemonic,
       ord_sents->list[rowcnt].mnemonic_type_cd = ocs.mnemonic_type_cd, ord_sents->list[rowcnt].
       syn_oef = oefp.oe_format_name, ord_sents->list[rowcnt].syn_oe_format_id = ocs.oe_format_id,
       ord_sents->list[rowcnt].orderable_type_flag = oc.orderable_type_flag, ord_sents->list[rowcnt].
       rx_mask = ocs.rx_mask, ord_sents->list[rowcnt].synonym_id = ocs.synonym_id,
       ord_sents->list[rowcnt].os_disp_line = "None", ord_sents->list[rowcnt].incomplete_os_ind = 1
      ENDIF
     HEAD os.order_sentence_id
      IF (os.order_sentence_id > 0)
       sentcnt = (sentcnt+ 1), rowcnt = (rowcnt+ 1)
       IF (mod(rowcnt,50)=1)
        stat = alterlist(ord_sents->list,(rowcnt+ 49))
       ENDIF
       ord_sents->list[rowcnt].pathway_catalog_id = pc.pathway_catalog_id, ord_sents->list[rowcnt].
       dcp_clin_cat_cd = pcmp.dcp_clin_cat_cd, ord_sents->list[rowcnt].dcp_clin_sub_cat_cd = pcmp
       .dcp_clin_sub_cat_cd,
       ord_sents->list[rowcnt].plan_disp = pc.description
       IF (ofr.synonym_id=0)
        ord_sents->list[rowcnt].synonym_vv_fac = - (1.0)
       ELSE
        ord_sents->list[rowcnt].synonym_vv_fac = ofr.facility_cd
       ENDIF
       ord_sents->list[rowcnt].catalog_cd = oc.catalog_cd, ord_sents->list[rowcnt].mnemonic = ocs
       .mnemonic, ord_sents->list[rowcnt].primary_disp = oc.primary_mnemonic,
       ord_sents->list[rowcnt].mnemonic_type_cd = ocs.mnemonic_type_cd, ord_sents->list[rowcnt].
       syn_oef = oefp.oe_format_name, ord_sents->list[rowcnt].syn_oe_format_id = ocs.oe_format_id,
       ord_sents->list[rowcnt].os_oe_format_id = os.oe_format_id, ord_sents->list[rowcnt].
       orderable_type_flag = oc.orderable_type_flag, ord_sents->list[rowcnt].os_disp_line = os
       .order_sentence_display_line,
       ord_sents->list[rowcnt].order_sentence_id = os.order_sentence_id, ord_sents->list[rowcnt].
       rx_mask = ocs.rx_mask, ord_sents->list[rowcnt].synonym_id = ocs.synonym_id
      ELSE
       nosenterrorcnt = (nosenterrorcnt+ 1)
      ENDIF
     HEAD ofm.oe_field_meaning_id
      fieldfoundind = 0
     HEAD osd.oe_field_id
      IF (ofm.oe_field_meaning_id=osd.oe_field_meaning_id)
       fieldfoundind = 1
      ENDIF
      CASE (osd.oe_field_id)
       OF strengthdosefieldid:
        ord_sents->list[rowcnt].strength = osd.oe_field_value
       OF strengthdoseunitfieldid:
        ord_sents->list[rowcnt].strength_unit_cd = osd.default_parent_entity_id
       OF volumedosefieldid:
        ord_sents->list[rowcnt].volume = osd.oe_field_value
       OF volumedoseunitfieldid:
        ord_sents->list[rowcnt].volume_unit_cd = osd.default_parent_entity_id
       OF freetextdosefieldid:
        ord_sents->list[rowcnt].freetext_dose = osd.oe_field_display_value
       OF routefieldid:
        ord_sents->list[rowcnt].route_cd = osd.default_parent_entity_id
       OF formfieldid:
        ord_sents->list[rowcnt].form_cd = osd.default_parent_entity_id
       OF ratefieldid:
        ord_sents->list[rowcnt].rate = osd.oe_field_value
       OF infuseoverfieldid:
        ord_sents->list[rowcnt].infuse_over = osd.oe_field_value
      ENDCASE
      IF (osd.oe_field_id IN (strengthdoseunitfieldid, volumedoseunitfieldid)
       AND band(cnvtint(cve.field_value),32) > 0)
       ord_sents->list[rowcnt].normalized_unit_ind = 1
      ENDIF
     FOOT  ofm.oe_field_meaning_id
      IF (fieldfoundind=0
       AND ofm.oe_field_meaning_id > 0
       AND os.order_sentence_id > 0)
       IF (((oeff.default_parent_entity_id > 0) OR (oeff.default_value > " ")) )
        CASE (oeff.oe_field_id)
         OF strengthdosefieldid:
          ord_sents->list[rowcnt].strength = cnvtreal(oeff.default_value),ord_sents->list[rowcnt].
          os_disp_line = build2(ord_sents->list[rowcnt].os_disp_line," = Strength Dose of ",trim(oeff
            .default_value)," defaulted from OEF")
         OF strengthdoseunitfieldid:
          ord_sents->list[rowcnt].strength_unit_cd = oeff.default_parent_entity_id,ord_sents->list[
          rowcnt].os_disp_line = build2(ord_sents->list[rowcnt].os_disp_line,
           " = Strength Dose Unit of ",trim(uar_get_code_display(oeff.default_parent_entity_id)),
           " defaulted from OEF")
         OF volumedosefieldid:
          ord_sents->list[rowcnt].volume = cnvtreal(oeff.default_value),ord_sents->list[rowcnt].
          os_disp_line = build2(ord_sents->list[rowcnt].os_disp_line," = Volume Dose of ",trim(oeff
            .default_value)," defaulted from OEF")
         OF volumedoseunitfieldid:
          ord_sents->list[rowcnt].volume_unit_cd = oeff.default_parent_entity_id,ord_sents->list[
          rowcnt].os_disp_line = build2(ord_sents->list[rowcnt].os_disp_line,
           " = Volume Dose Unit of ",trim(uar_get_code_display(oeff.default_parent_entity_id)),
           " defaulted from OEF")
         OF freetextdosefieldid:
          ord_sents->list[rowcnt].freetext_dose = oeff.default_value,ord_sents->list[rowcnt].
          os_disp_line = build2(ord_sents->list[rowcnt].os_disp_line," = Freetext Dose of ",trim(oeff
            .default_value)," defaulted from OEF")
         OF routefieldid:
          ord_sents->list[rowcnt].route_cd = oeff.default_parent_entity_id,ord_sents->list[rowcnt].
          os_disp_line = build2(ord_sents->list[rowcnt].os_disp_line," = Route of ",trim(
            uar_get_code_display(oeff.default_parent_entity_id))," defaulted from OEF")
         OF formfieldid:
          ord_sents->list[rowcnt].form_cd = oeff.default_parent_entity_id,ord_sents->list[rowcnt].
          os_disp_line = build2(ord_sents->list[rowcnt].os_disp_line," = Form of ",trim(
            uar_get_code_display(oeff.default_parent_entity_id))," defaulted from OEF")
         OF ratefieldid:
          ord_sents->list[rowcnt].rate = cnvtreal(oeff.default_value),ord_sents->list[rowcnt].
          os_disp_line = build2(ord_sents->list[rowcnt].os_disp_line," = Rate of ",trim(oeff
            .default_value)," defaulted from OEF")
         OF infuseoverfieldid:
          ord_sents->list[rowcnt].infuse_over = cnvtreal(oeff.default_value),ord_sents->list[rowcnt].
          os_disp_line = build2(ord_sents->list[rowcnt].os_disp_line," = Infuse Over of ",trim(oeff
            .default_value)," defaulted from OEF")
        ENDCASE
       ELSE
        missingtext = ord_sents->list[rowcnt].missing_field_text
        IF (ofm.oe_field_meaning IN ("STRENGTHDOSE", "STRENGTHDOSEUNIT", "VOLUMEDOSE",
        "VOLUMEDOSEUNIT", "FREETXTDOSE",
        "RXROUTE", "DRUGFORM"))
         ord_sents->list[rowcnt].incomplete_os_ind = 1
        ENDIF
        IF (missingtext="")
         missingdetailcnt = (missingdetailcnt+ 1), missingtext = build2("Sentence is missing a ",oeff
          .label_text)
        ELSE
         missingtext = build2(missingtext,", ",oeff.label_text)
        ENDIF
        ord_sents->list[rowcnt].missing_field_text = missingtext
       ENDIF
      ENDIF
     FOOT REPORT
      IF (mod(rowcnt,50) != 0)
       stat = alterlist(ord_sents->list,rowcnt)
      ENDIF
     WITH nocounter
    ;end select
    SELECT
     IF (plantype="CAREPLAN")INTO "nl:"
      ocs.mnemonic, oefp.oe_format_name, os.order_sentence_display_line,
      clinical_cat = uar_get_code_display(pcmp.dcp_clin_cat_cd), sub_clin_cat = uar_get_code_display(
       pcmp.dcp_clin_sub_cat_cd), oc.catalog_cd,
      oc.primary_mnemonic
      FROM pathway_catalog pc,
       pw_cat_flex pcf,
       pathway_comp pcmp,
       order_catalog_synonym ocs,
       order_catalog oc,
       cs_component cc,
       order_catalog_synonym ocs2,
       order_entry_format_parent oefp,
       dummyt d,
       pw_comp_os_reltn pcor,
       order_sentence os,
       order_sentence_detail osd
      PLAN (pc
       WHERE pc.pathway_catalog_id=searchid
        AND pc.type_mean="CAREPLAN"
        AND pc.active_ind=1
        AND pc.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND pc.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
       JOIN (pcf
       WHERE pcf.pathway_catalog_id=pc.pathway_catalog_id
        AND pcf.parent_entity_name="CODE_VALUE"
        AND pcf.parent_entity_id IN (0, facilitycd))
       JOIN (pcmp
       WHERE pcmp.pathway_catalog_id=pc.pathway_catalog_id
        AND pcmp.active_ind=1
        AND pcmp.parent_entity_name="ORDER_CATALOG_SYNONYM")
       JOIN (ocs
       WHERE ocs.synonym_id=pcmp.parent_entity_id
        AND ocs.catalog_type_cd=pharm_cat_cd
        AND ocs.activity_type_cd=pharm_act_cd)
       JOIN (oc
       WHERE oc.catalog_cd=ocs.catalog_cd
        AND oc.orderable_type_flag=8)
       JOIN (cc
       WHERE cc.catalog_cd=oc.catalog_cd)
       JOIN (ocs2
       WHERE ocs2.synonym_id=cc.comp_id)
       JOIN (oefp
       WHERE oefp.oe_format_id=ocs2.oe_format_id)
       JOIN (d)
       JOIN (pcor
       WHERE pcor.iv_comp_syn_id=ocs2.synonym_id
        AND pcor.pathway_comp_id=pcmp.pathway_comp_id)
       JOIN (os
       WHERE os.order_sentence_id=pcor.order_sentence_id)
       JOIN (osd
       WHERE osd.order_sentence_id=os.order_sentence_id)
     ELSEIF (plantype="PATHWAY")INTO "nl:"
      ocs.mnemonic, oefp.oe_format_name, os.order_sentence_display_line,
      clinical_cat = uar_get_code_display(pcmp.dcp_clin_cat_cd), sub_clin_cat = uar_get_code_display(
       pcmp.dcp_clin_sub_cat_cd), oc.catalog_cd,
      oc.primary_mnemonic
      FROM pathway_catalog pc,
       pw_cat_reltn pcr,
       pw_cat_flex pcf,
       pathway_comp pcmp,
       order_catalog_synonym ocs,
       order_catalog oc,
       cs_component cc,
       order_catalog_synonym ocs2,
       order_entry_format_parent oefp,
       dummyt d,
       pw_comp_os_reltn pcor,
       order_sentence os,
       order_sentence_detail osd
      PLAN (pc
       WHERE pc.pathway_catalog_id=searchid
        AND pc.type_mean="PATHWAY"
        AND pc.active_ind=1
        AND pc.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND pc.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
       JOIN (pcr
       WHERE pcr.pw_cat_s_id=pc.pathway_catalog_id)
       JOIN (pcf
       WHERE pcf.pathway_catalog_id=pc.pathway_catalog_id
        AND pcf.parent_entity_name="CODE_VALUE"
        AND pcf.parent_entity_id IN (0, facilitycd))
       JOIN (pcmp
       WHERE pcmp.pathway_catalog_id=pcr.pw_cat_t_id
        AND pcmp.active_ind=1
        AND pcmp.parent_entity_name="ORDER_CATALOG_SYNONYM")
       JOIN (ocs
       WHERE ocs.synonym_id=pcmp.parent_entity_id
        AND ocs.catalog_type_cd=pharm_cat_cd
        AND ocs.activity_type_cd=pharm_act_cd)
       JOIN (oc
       WHERE oc.catalog_cd=ocs.catalog_cd
        AND oc.orderable_type_flag=8)
       JOIN (cc
       WHERE cc.catalog_cd=oc.catalog_cd)
       JOIN (ocs2
       WHERE ocs2.synonym_id=cc.comp_id)
       JOIN (oefp
       WHERE oefp.oe_format_id=ocs2.oe_format_id)
       JOIN (d)
       JOIN (pcor
       WHERE pcor.iv_comp_syn_id=ocs2.synonym_id
        AND pcor.pathway_comp_id=pcmp.pathway_comp_id)
       JOIN (os
       WHERE os.order_sentence_id=pcor.order_sentence_id)
       JOIN (osd
       WHERE osd.order_sentence_id=os.order_sentence_id)
     ELSE
     ENDIF
     ORDER BY pc.description_key, clinical_cat, sub_clin_cat,
      ocs.mnemonic, pcmp.pathway_comp_id, cc.comp_seq,
      os.order_sentence_id, osd.oe_field_id
     HEAD REPORT
      setcnt = 0
     HEAD pcmp.pathway_comp_id
      firstdiluent = 0, ivsentcnt = 0, setcnt = (setcnt+ 1)
      IF (mod(setcnt,50)=1)
       stat = alterlist(iv_sets->set_list,(setcnt+ 49))
      ENDIF
      iv_sets->set_list[setcnt].catalog_cd = oc.catalog_cd, iv_sets->set_list[setcnt].primary_disp =
      oc.primary_mnemonic, iv_sets->set_list[setcnt].plan_disp = pc.description,
      iv_sets->set_list[setcnt].dcp_clin_cat_cd = pcmp.dcp_clin_cat_cd, iv_sets->set_list[setcnt].
      dcp_clin_sub_cat_cd = pcmp.dcp_clin_sub_cat_cd, iv_sets->set_list[setcnt].pathway_catalog_id =
      pc.pathway_catalog_id
      IF (oc.dcp_clin_cat_cd=iv_solutions_cd)
       iv_sets->set_list[setcnt].med_order_type_cd = iv_type_cd
      ELSE
       iv_sets->set_list[setcnt].med_order_type_cd = int_type_cd
      ENDIF
     HEAD cc.comp_seq
      ivsentcnt = (ivsentcnt+ 1)
      IF (mod(ivsentcnt,2)=1)
       stat = alterlist(iv_sets->set_list[setcnt].syn_list,(ivsentcnt+ 1))
      ENDIF
      IF (firstdiluent=0
       AND ocs2.rx_mask=1)
       firstdiluent = cc.comp_seq
      ENDIF
      iv_sets->set_list[setcnt].syn_list[ivsentcnt].syn_catalog_cd = ocs2.catalog_cd, iv_sets->
      set_list[setcnt].syn_list[ivsentcnt].syn_mnemonic = ocs2.mnemonic, iv_sets->set_list[setcnt].
      syn_list[ivsentcnt].syn_mnemonic_type_cd = ocs2.mnemonic_type_cd,
      iv_sets->set_list[setcnt].syn_list[ivsentcnt].synonym_id = ocs2.synonym_id, iv_sets->set_list[
      setcnt].syn_list[ivsentcnt].rx_mask = ocs2.rx_mask, iv_sets->set_list[setcnt].syn_list[
      ivsentcnt].sequence = cc.comp_seq
      IF (oc.dcp_clin_cat_cd=iv_solutions_cd)
       IF (firstdiluent=cc.comp_seq)
        iv_sets->set_list[setcnt].syn_list[ivsentcnt].syn_oe_format_id = ocs2.oe_format_id, iv_sets->
        set_list[setcnt].syn_list[ivsentcnt].syn_oef = oefp.oe_format_name
       ELSE
        IF (iv_ingred_oef_id > 0)
         iv_sets->set_list[setcnt].syn_list[ivsentcnt].syn_oe_format_id = iv_ingred_oef_id, iv_sets->
         set_list[setcnt].syn_list[ivsentcnt].syn_oef = "IV Ingredient"
        ELSE
         iv_sets->set_list[setcnt].syn_list[ivsentcnt].syn_oef =
         "Error finding IV Ingredient oe_format_id"
        ENDIF
       ENDIF
      ELSE
       IF (cc.comp_seq=1)
        iv_sets->set_list[setcnt].syn_list[ivsentcnt].syn_oe_format_id = ocs2.oe_format_id, iv_sets->
        set_list[setcnt].syn_list[ivsentcnt].syn_oef = oefp.oe_format_name
       ELSE
        IF (iv_ingred_oef_id > 0)
         iv_sets->set_list[setcnt].syn_list[ivsentcnt].syn_oe_format_id = iv_ingred_oef_id, iv_sets->
         set_list[setcnt].syn_list[ivsentcnt].syn_oef = "IV Ingredient"
        ELSE
         iv_sets->set_list[setcnt].syn_list[ivsentcnt].syn_oef =
         "Error finding IV Ingredient oe_format_id"
        ENDIF
       ENDIF
      ENDIF
      iv_sets->set_list[setcnt].syn_list[ivsentcnt].os_disp_line = os.order_sentence_display_line,
      iv_sets->set_list[setcnt].syn_list[ivsentcnt].order_sentence_id = os.order_sentence_id, iv_sets
      ->set_list[setcnt].syn_list[ivsentcnt].os_oe_format_id = os.oe_format_id,
      iv_sets->set_list[setcnt].syn_list[ivsentcnt].orderable_type_flag = ocs2.orderable_type_flag
     HEAD osd.oe_field_id
      CASE (osd.oe_field_id)
       OF strengthdosefieldid:
        iv_sets->set_list[setcnt].syn_list[ivsentcnt].strength = osd.oe_field_value
       OF strengthdoseunitfieldid:
        iv_sets->set_list[setcnt].syn_list[ivsentcnt].strength_unit_cd = osd.default_parent_entity_id
       OF volumedosefieldid:
        iv_sets->set_list[setcnt].syn_list[ivsentcnt].volume = osd.oe_field_value
       OF volumedoseunitfieldid:
        iv_sets->set_list[setcnt].syn_list[ivsentcnt].volume_unit_cd = osd.default_parent_entity_id
       OF routefieldid:
        iv_sets->set_list[setcnt].route_cd = osd.default_parent_entity_id
       OF formfieldid:
        iv_sets->set_list[setcnt].form_cd = osd.default_parent_entity_id
       OF ratefieldid:
        iv_sets->set_list[setcnt].syn_list[ivsentcnt].rate = osd.oe_field_value
       OF infuseoverfieldid:
        iv_sets->set_list[setcnt].syn_list[ivsentcnt].infuse_over = osd.oe_field_value
       OF normalizedratefieldid:
        iv_sets->set_list[setcnt].syn_list[ivsentcnt].normalized_rate = osd.oe_field_value
       OF frequencyfieldid:
        iv_sets->set_list[setcnt].syn_list[ivsentcnt].frequency_cd = osd.default_parent_entity_id
       OF freetextratefieldid:
        iv_sets->set_list[setcnt].syn_list[ivsentcnt].freetext_rate = osd.oe_field_display_value
      ENDCASE
     FOOT  pcmp.pathway_comp_id
      IF (mod(ivsentcnt,2) != 0)
       stat = alterlist(iv_sets->set_list[setcnt].syn_list,ivsentcnt)
      ENDIF
     FOOT REPORT
      IF (mod(setcnt,50) != 0)
       stat = alterlist(iv_sets->set_list,setcnt)
      ENDIF
     WITH nocounter, outerjoin = d
    ;end select
   ELSEIF (searchmode=search_by_all_powerplan)
    SELECT INTO "nl:"
     ocs.mnemonic, oefp.oe_format_name, os.order_sentence_display_line,
     clinical_cat = uar_get_code_display(pcmp.dcp_clin_cat_cd), sub_clin_cat = uar_get_code_display(
      pcmp.dcp_clin_sub_cat_cd)
     FROM pathway_catalog pc,
      pw_cat_flex pcf,
      order_catalog_synonym ocs,
      (left JOIN ocs_facility_r ofr ON ofr.synonym_id=ocs.synonym_id
       AND ofr.facility_cd IN (0, facilitycd)),
      order_catalog oc,
      order_entry_format_parent oefp,
      (left JOIN oe_format_fields oeff ON oeff.oe_format_id=oefp.oe_format_id
       AND oeff.action_type_cd=action_order_cd
       AND ((oeff.value_required_ind=1) OR (oeff.accept_flag=0)) ),
      (left JOIN order_entry_fields oef ON oef.oe_field_id=oeff.oe_field_id),
      (left JOIN oe_field_meaning ofm ON ofm.oe_field_meaning_id=oef.oe_field_meaning_id
       AND ofm.oe_field_meaning != "REQSTARTDTTM"),
      pathway_comp pcmp,
      (left JOIN pw_comp_os_reltn pcor ON pcor.pathway_comp_id=pcmp.pathway_comp_id),
      (left JOIN order_sentence os ON os.order_sentence_id=pcor.order_sentence_id),
      (left JOIN order_sentence_detail osd ON osd.order_sentence_id=os.order_sentence_id),
      (left JOIN code_value_extension cve ON cve.code_value=osd.default_parent_entity_id
       AND cve.code_set=54
       AND cve.field_name="PHARM_UNIT")
     PLAN (pc
      WHERE pc.type_mean="CAREPLAN"
       AND pc.active_ind=1
       AND pc.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND pc.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
      JOIN (pcf
      WHERE pcf.pathway_catalog_id=pc.pathway_catalog_id
       AND pcf.parent_entity_name="CODE_VALUE"
       AND pcf.parent_entity_id IN (0, facilitycd))
      JOIN (pcmp
      WHERE pcmp.pathway_catalog_id=pc.pathway_catalog_id
       AND pcmp.active_ind=1
       AND pcmp.parent_entity_name="ORDER_CATALOG_SYNONYM")
      JOIN (ocs
      WHERE ocs.synonym_id=pcmp.parent_entity_id
       AND ocs.catalog_type_cd=pharm_cat_cd
       AND ocs.activity_type_cd=pharm_act_cd)
      JOIN (ofr)
      JOIN (oc
      WHERE oc.catalog_cd=ocs.catalog_cd
       AND oc.orderable_type_flag IN (0, 1))
      JOIN (oefp
      WHERE oefp.oe_format_id=ocs.oe_format_id)
      JOIN (oeff)
      JOIN (oef)
      JOIN (ofm)
      JOIN (pcor)
      JOIN (os)
      JOIN (osd)
      JOIN (cve)
     ORDER BY pc.description_key, clinical_cat, sub_clin_cat,
      ocs.mnemonic_key_cap, pcor.order_sentence_seq, os.order_sentence_id,
      ofm.oe_field_meaning_id, osd.oe_field_id
     HEAD REPORT
      rowcnt = 0, sentcnt = 0, missingdetailcnt = 0,
      nosenterrorcnt = 0
     HEAD ocs.synonym_id
      IF (os.order_sentence_id=0)
       rowcnt = (rowcnt+ 1)
       IF (mod(rowcnt,50)=1)
        stat = alterlist(ord_sents->list,(rowcnt+ 49))
       ENDIF
       ord_sents->list[rowcnt].pathway_catalog_id = pc.pathway_catalog_id, ord_sents->list[rowcnt].
       dcp_clin_cat_cd = pcmp.dcp_clin_cat_cd, ord_sents->list[rowcnt].dcp_clin_sub_cat_cd = pcmp
       .dcp_clin_sub_cat_cd,
       ord_sents->list[rowcnt].plan_disp = pc.description
       IF (ofr.synonym_id=0)
        ord_sents->list[rowcnt].synonym_vv_fac = - (1.0)
       ELSE
        ord_sents->list[rowcnt].synonym_vv_fac = ofr.facility_cd
       ENDIF
       ord_sents->list[rowcnt].catalog_cd = oc.catalog_cd, ord_sents->list[rowcnt].mnemonic = ocs
       .mnemonic, ord_sents->list[rowcnt].primary_disp = oc.primary_mnemonic,
       ord_sents->list[rowcnt].mnemonic_type_cd = ocs.mnemonic_type_cd, ord_sents->list[rowcnt].
       syn_oef = oefp.oe_format_name, ord_sents->list[rowcnt].syn_oe_format_id = ocs.oe_format_id,
       ord_sents->list[rowcnt].orderable_type_flag = oc.orderable_type_flag, ord_sents->list[rowcnt].
       rx_mask = ocs.rx_mask, ord_sents->list[rowcnt].synonym_id = ocs.synonym_id,
       ord_sents->list[rowcnt].os_disp_line = "None", ord_sents->list[rowcnt].incomplete_os_ind = 1
      ENDIF
     HEAD os.order_sentence_id
      IF (os.order_sentence_id > 0)
       sentcnt = (sentcnt+ 1), rowcnt = (rowcnt+ 1)
       IF (mod(rowcnt,50)=1)
        stat = alterlist(ord_sents->list,(rowcnt+ 49))
       ENDIF
       ord_sents->list[rowcnt].pathway_catalog_id = pc.pathway_catalog_id, ord_sents->list[rowcnt].
       dcp_clin_cat_cd = pcmp.dcp_clin_cat_cd, ord_sents->list[rowcnt].dcp_clin_sub_cat_cd = pcmp
       .dcp_clin_sub_cat_cd,
       ord_sents->list[rowcnt].plan_disp = pc.description
       IF (ofr.synonym_id=0)
        ord_sents->list[rowcnt].synonym_vv_fac = - (1.0)
       ELSE
        ord_sents->list[rowcnt].synonym_vv_fac = ofr.facility_cd
       ENDIF
       ord_sents->list[rowcnt].catalog_cd = oc.catalog_cd, ord_sents->list[rowcnt].mnemonic = ocs
       .mnemonic, ord_sents->list[rowcnt].primary_disp = oc.primary_mnemonic,
       ord_sents->list[rowcnt].mnemonic_type_cd = ocs.mnemonic_type_cd, ord_sents->list[rowcnt].
       syn_oef = oefp.oe_format_name, ord_sents->list[rowcnt].syn_oe_format_id = ocs.oe_format_id,
       ord_sents->list[rowcnt].os_oe_format_id = os.oe_format_id, ord_sents->list[rowcnt].
       orderable_type_flag = oc.orderable_type_flag, ord_sents->list[rowcnt].os_disp_line = os
       .order_sentence_display_line,
       ord_sents->list[rowcnt].order_sentence_id = os.order_sentence_id, ord_sents->list[rowcnt].
       rx_mask = ocs.rx_mask, ord_sents->list[rowcnt].synonym_id = ocs.synonym_id
      ELSE
       nosenterrorcnt = (nosenterrorcnt+ 1)
      ENDIF
     HEAD ofm.oe_field_meaning_id
      fieldfoundind = 0
     HEAD osd.oe_field_id
      IF (ofm.oe_field_meaning_id=osd.oe_field_meaning_id)
       fieldfoundind = 1
      ENDIF
      CASE (osd.oe_field_id)
       OF strengthdosefieldid:
        ord_sents->list[rowcnt].strength = osd.oe_field_value
       OF strengthdoseunitfieldid:
        ord_sents->list[rowcnt].strength_unit_cd = osd.default_parent_entity_id
       OF volumedosefieldid:
        ord_sents->list[rowcnt].volume = osd.oe_field_value
       OF volumedoseunitfieldid:
        ord_sents->list[rowcnt].volume_unit_cd = osd.default_parent_entity_id
       OF freetextdosefieldid:
        ord_sents->list[rowcnt].freetext_dose = osd.oe_field_display_value
       OF routefieldid:
        ord_sents->list[rowcnt].route_cd = osd.default_parent_entity_id
       OF formfieldid:
        ord_sents->list[rowcnt].form_cd = osd.default_parent_entity_id
       OF ratefieldid:
        ord_sents->list[rowcnt].rate = osd.oe_field_value
       OF infuseoverfieldid:
        ord_sents->list[rowcnt].infuse_over = osd.oe_field_value
      ENDCASE
      IF (osd.oe_field_id IN (strengthdoseunitfieldid, volumedoseunitfieldid)
       AND band(cnvtint(cve.field_value),32) > 0)
       ord_sents->list[rowcnt].normalized_unit_ind = 1
      ENDIF
     FOOT  ofm.oe_field_meaning_id
      IF (fieldfoundind=0
       AND ofm.oe_field_meaning_id > 0
       AND os.order_sentence_id > 0)
       IF (((oeff.default_parent_entity_id > 0) OR (oeff.default_value > " ")) )
        CASE (oeff.oe_field_id)
         OF strengthdosefieldid:
          ord_sents->list[rowcnt].strength = cnvtreal(oeff.default_value),ord_sents->list[rowcnt].
          os_disp_line = build2(ord_sents->list[rowcnt].os_disp_line," = Strength Dose of ",trim(oeff
            .default_value)," defaulted from OEF")
         OF strengthdoseunitfieldid:
          ord_sents->list[rowcnt].strength_unit_cd = oeff.default_parent_entity_id,ord_sents->list[
          rowcnt].os_disp_line = build2(ord_sents->list[rowcnt].os_disp_line,
           " = Strength Dose Unit of ",trim(uar_get_code_display(oeff.default_parent_entity_id)),
           " defaulted from OEF")
         OF volumedosefieldid:
          ord_sents->list[rowcnt].volume = cnvtreal(oeff.default_value),ord_sents->list[rowcnt].
          os_disp_line = build2(ord_sents->list[rowcnt].os_disp_line," = Volume Dose of ",trim(oeff
            .default_value)," defaulted from OEF")
         OF volumedoseunitfieldid:
          ord_sents->list[rowcnt].volume_unit_cd = oeff.default_parent_entity_id,ord_sents->list[
          rowcnt].os_disp_line = build2(ord_sents->list[rowcnt].os_disp_line,
           " = Volume Dose Unit of ",trim(uar_get_code_display(oeff.default_parent_entity_id)),
           " defaulted from OEF")
         OF freetextdosefieldid:
          ord_sents->list[rowcnt].freetext_dose = oeff.default_value,ord_sents->list[rowcnt].
          os_disp_line = build2(ord_sents->list[rowcnt].os_disp_line," = Freetext Dose of ",trim(oeff
            .default_value)," defaulted from OEF")
         OF routefieldid:
          ord_sents->list[rowcnt].route_cd = oeff.default_parent_entity_id,ord_sents->list[rowcnt].
          os_disp_line = build2(ord_sents->list[rowcnt].os_disp_line," = Route of ",trim(
            uar_get_code_display(oeff.default_parent_entity_id))," defaulted from OEF")
         OF formfieldid:
          ord_sents->list[rowcnt].form_cd = oeff.default_parent_entity_id,ord_sents->list[rowcnt].
          os_disp_line = build2(ord_sents->list[rowcnt].os_disp_line," = Form of ",trim(
            uar_get_code_display(oeff.default_parent_entity_id))," defaulted from OEF")
         OF ratefieldid:
          ord_sents->list[rowcnt].rate = cnvtreal(oeff.default_value),ord_sents->list[rowcnt].
          os_disp_line = build2(ord_sents->list[rowcnt].os_disp_line," = Rate of ",trim(oeff
            .default_value)," defaulted from OEF")
         OF infuseoverfieldid:
          ord_sents->list[rowcnt].infuse_over = cnvtreal(oeff.default_value),ord_sents->list[rowcnt].
          os_disp_line = build2(ord_sents->list[rowcnt].os_disp_line," = Infuse Over of ",trim(oeff
            .default_value)," defaulted from OEF")
        ENDCASE
       ELSE
        missingtext = ord_sents->list[rowcnt].missing_field_text
        IF (ofm.oe_field_meaning IN ("STRENGTHDOSE", "STRENGTHDOSEUNIT", "VOLUMEDOSE",
        "VOLUMEDOSEUNIT", "FREETXTDOSE",
        "RXROUTE", "DRUGFORM"))
         ord_sents->list[rowcnt].incomplete_os_ind = 1
        ENDIF
        IF (missingtext="")
         missingdetailcnt = (missingdetailcnt+ 1), missingtext = build2("Sentence is missing a ",oeff
          .label_text)
        ELSE
         missingtext = build2(missingtext,", ",oeff.label_text)
        ENDIF
        ord_sents->list[rowcnt].missing_field_text = missingtext
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     ocs.mnemonic, oefp.oe_format_name, os.order_sentence_display_line,
     clinical_cat = uar_get_code_display(pcmp.dcp_clin_cat_cd), sub_clin_cat = uar_get_code_display(
      pcmp.dcp_clin_sub_cat_cd), oc.catalog_cd,
     oc.primary_mnemonic
     FROM pathway_catalog pc,
      pw_cat_flex pcf,
      pathway_comp pcmp,
      order_catalog_synonym ocs,
      order_catalog oc,
      cs_component cc,
      order_catalog_synonym ocs2,
      order_entry_format_parent oefp,
      dummyt d,
      pw_comp_os_reltn pcor,
      order_sentence os,
      order_sentence_detail osd
     PLAN (pc
      WHERE pc.type_mean="CAREPLAN"
       AND pc.active_ind=1
       AND pc.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND pc.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
      JOIN (pcf
      WHERE pcf.pathway_catalog_id=pc.pathway_catalog_id
       AND pcf.parent_entity_name="CODE_VALUE"
       AND pcf.parent_entity_id IN (0, facilitycd))
      JOIN (pcmp
      WHERE pcmp.pathway_catalog_id=pc.pathway_catalog_id
       AND pcmp.active_ind=1
       AND pcmp.parent_entity_name="ORDER_CATALOG_SYNONYM")
      JOIN (ocs
      WHERE ocs.synonym_id=pcmp.parent_entity_id
       AND ocs.catalog_type_cd=pharm_cat_cd
       AND ocs.activity_type_cd=pharm_act_cd)
      JOIN (oc
      WHERE oc.catalog_cd=ocs.catalog_cd
       AND oc.orderable_type_flag=8)
      JOIN (cc
      WHERE cc.catalog_cd=oc.catalog_cd)
      JOIN (ocs2
      WHERE ocs2.synonym_id=cc.comp_id)
      JOIN (oefp
      WHERE oefp.oe_format_id=ocs2.oe_format_id)
      JOIN (d)
      JOIN (pcor
      WHERE pcor.iv_comp_syn_id=ocs2.synonym_id
       AND pcor.pathway_comp_id=pcmp.pathway_comp_id)
      JOIN (os
      WHERE os.order_sentence_id=pcor.order_sentence_id)
      JOIN (osd
      WHERE osd.order_sentence_id=os.order_sentence_id)
     ORDER BY pc.description_key, clinical_cat, sub_clin_cat,
      ocs.mnemonic, pcmp.pathway_comp_id, cc.comp_seq,
      os.order_sentence_id, osd.oe_field_id
     HEAD REPORT
      setcnt = 0
     HEAD pcmp.pathway_comp_id
      firstdiluent = 0, ivsentcnt = 0, setcnt = (setcnt+ 1)
      IF (mod(setcnt,50)=1)
       stat = alterlist(iv_sets->set_list,(setcnt+ 49))
      ENDIF
      iv_sets->set_list[setcnt].catalog_cd = oc.catalog_cd, iv_sets->set_list[setcnt].primary_disp =
      oc.primary_mnemonic, iv_sets->set_list[setcnt].plan_disp = pc.description,
      iv_sets->set_list[setcnt].dcp_clin_cat_cd = pcmp.dcp_clin_cat_cd, iv_sets->set_list[setcnt].
      dcp_clin_sub_cat_cd = pcmp.dcp_clin_sub_cat_cd, iv_sets->set_list[setcnt].pathway_catalog_id =
      pc.pathway_catalog_id
      IF (oc.dcp_clin_cat_cd=iv_solutions_cd)
       iv_sets->set_list[setcnt].med_order_type_cd = iv_type_cd
      ELSE
       iv_sets->set_list[setcnt].med_order_type_cd = int_type_cd
      ENDIF
     HEAD cc.comp_seq
      ivsentcnt = (ivsentcnt+ 1)
      IF (mod(ivsentcnt,2)=1)
       stat = alterlist(iv_sets->set_list[setcnt].syn_list,(ivsentcnt+ 1))
      ENDIF
      IF (firstdiluent=0
       AND ocs2.rx_mask=1)
       firstdiluent = cc.comp_seq
      ENDIF
      iv_sets->set_list[setcnt].syn_list[ivsentcnt].syn_catalog_cd = ocs2.catalog_cd, iv_sets->
      set_list[setcnt].syn_list[ivsentcnt].syn_mnemonic = ocs2.mnemonic, iv_sets->set_list[setcnt].
      syn_list[ivsentcnt].syn_mnemonic_type_cd = ocs2.mnemonic_type_cd,
      iv_sets->set_list[setcnt].syn_list[ivsentcnt].synonym_id = ocs2.synonym_id, iv_sets->set_list[
      setcnt].syn_list[ivsentcnt].rx_mask = ocs2.rx_mask, iv_sets->set_list[setcnt].syn_list[
      ivsentcnt].sequence = cc.comp_seq
      IF (oc.dcp_clin_cat_cd=iv_solutions_cd)
       IF (firstdiluent=cc.comp_seq)
        iv_sets->set_list[setcnt].syn_list[ivsentcnt].syn_oe_format_id = ocs2.oe_format_id, iv_sets->
        set_list[setcnt].syn_list[ivsentcnt].syn_oef = oefp.oe_format_name
       ELSE
        IF (iv_ingred_oef_id > 0)
         iv_sets->set_list[setcnt].syn_list[ivsentcnt].syn_oe_format_id = iv_ingred_oef_id, iv_sets->
         set_list[setcnt].syn_list[ivsentcnt].syn_oef = "IV Ingredient"
        ELSE
         iv_sets->set_list[setcnt].syn_list[ivsentcnt].syn_oef =
         "Error finding IV Ingredient oe_format_id"
        ENDIF
       ENDIF
      ELSE
       IF (cc.comp_seq=1)
        iv_sets->set_list[setcnt].syn_list[ivsentcnt].syn_oe_format_id = ocs2.oe_format_id, iv_sets->
        set_list[setcnt].syn_list[ivsentcnt].syn_oef = oefp.oe_format_name
       ELSE
        IF (iv_ingred_oef_id > 0)
         iv_sets->set_list[setcnt].syn_list[ivsentcnt].syn_oe_format_id = iv_ingred_oef_id, iv_sets->
         set_list[setcnt].syn_list[ivsentcnt].syn_oef = "IV Ingredient"
        ELSE
         iv_sets->set_list[setcnt].syn_list[ivsentcnt].syn_oef =
         "Error finding IV Ingredient oe_format_id"
        ENDIF
       ENDIF
      ENDIF
      iv_sets->set_list[setcnt].syn_list[ivsentcnt].os_disp_line = os.order_sentence_display_line,
      iv_sets->set_list[setcnt].syn_list[ivsentcnt].order_sentence_id = os.order_sentence_id, iv_sets
      ->set_list[setcnt].syn_list[ivsentcnt].os_oe_format_id = os.oe_format_id,
      iv_sets->set_list[setcnt].syn_list[ivsentcnt].orderable_type_flag = ocs2.orderable_type_flag
     HEAD osd.oe_field_id
      CASE (osd.oe_field_id)
       OF strengthdosefieldid:
        iv_sets->set_list[setcnt].syn_list[ivsentcnt].strength = osd.oe_field_value
       OF strengthdoseunitfieldid:
        iv_sets->set_list[setcnt].syn_list[ivsentcnt].strength_unit_cd = osd.default_parent_entity_id
       OF volumedosefieldid:
        iv_sets->set_list[setcnt].syn_list[ivsentcnt].volume = osd.oe_field_value
       OF volumedoseunitfieldid:
        iv_sets->set_list[setcnt].syn_list[ivsentcnt].volume_unit_cd = osd.default_parent_entity_id
       OF routefieldid:
        iv_sets->set_list[setcnt].route_cd = osd.default_parent_entity_id
       OF formfieldid:
        iv_sets->set_list[setcnt].form_cd = osd.default_parent_entity_id
       OF ratefieldid:
        iv_sets->set_list[setcnt].syn_list[ivsentcnt].rate = osd.oe_field_value
       OF infuseoverfieldid:
        iv_sets->set_list[setcnt].syn_list[ivsentcnt].infuse_over = osd.oe_field_value
       OF normalizedratefieldid:
        iv_sets->set_list[setcnt].syn_list[ivsentcnt].normalized_rate = osd.oe_field_value
       OF frequencyfieldid:
        iv_sets->set_list[setcnt].syn_list[ivsentcnt].frequency_cd = osd.default_parent_entity_id
       OF freetextratefieldid:
        iv_sets->set_list[setcnt].syn_list[ivsentcnt].freetext_rate = osd.oe_field_display_value
      ENDCASE
     FOOT  pcmp.pathway_comp_id
      IF (mod(ivsentcnt,2) != 0)
       stat = alterlist(iv_sets->set_list[setcnt].syn_list,ivsentcnt)
      ENDIF
     WITH nocounter, outerjoin = d
    ;end select
    SELECT INTO "nl:"
     ocs.mnemonic, oefp.oe_format_name, os.order_sentence_display_line,
     clinical_cat = uar_get_code_display(pcmp.dcp_clin_cat_cd), sub_clin_cat = uar_get_code_display(
      pcmp.dcp_clin_sub_cat_cd)
     FROM pathway_catalog pc,
      pw_cat_reltn pcr,
      pw_cat_flex pcf,
      order_catalog_synonym ocs,
      (left JOIN ocs_facility_r ofr ON ofr.synonym_id=ocs.synonym_id
       AND ofr.facility_cd IN (0, facilitycd)),
      order_catalog oc,
      order_entry_format_parent oefp,
      (left JOIN oe_format_fields oeff ON oeff.oe_format_id=oefp.oe_format_id
       AND oeff.action_type_cd=action_order_cd
       AND ((oeff.value_required_ind=1) OR (oeff.accept_flag=0)) ),
      (left JOIN order_entry_fields oef ON oef.oe_field_id=oeff.oe_field_id),
      (left JOIN oe_field_meaning ofm ON ofm.oe_field_meaning_id=oef.oe_field_meaning_id
       AND ofm.oe_field_meaning != "REQSTARTDTTM"),
      pathway_comp pcmp,
      (left JOIN pw_comp_os_reltn pcor ON pcor.pathway_comp_id=pcmp.pathway_comp_id),
      (left JOIN order_sentence os ON os.order_sentence_id=pcor.order_sentence_id),
      (left JOIN order_sentence_detail osd ON osd.order_sentence_id=os.order_sentence_id),
      (left JOIN code_value_extension cve ON cve.code_value=osd.default_parent_entity_id
       AND cve.code_set=54
       AND cve.field_name="PHARM_UNIT")
     PLAN (pc
      WHERE pc.type_mean="PATHWAY"
       AND pc.active_ind=1
       AND pc.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND pc.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
      JOIN (pcr
      WHERE pcr.pw_cat_s_id=pc.pathway_catalog_id)
      JOIN (pcf
      WHERE pcf.pathway_catalog_id=pc.pathway_catalog_id
       AND pcf.parent_entity_name="CODE_VALUE"
       AND pcf.parent_entity_id IN (0, facilitycd))
      JOIN (pcmp
      WHERE pcmp.pathway_catalog_id=pcr.pw_cat_t_id
       AND pcmp.active_ind=1
       AND pcmp.parent_entity_name="ORDER_CATALOG_SYNONYM")
      JOIN (ocs
      WHERE ocs.synonym_id=pcmp.parent_entity_id
       AND ocs.catalog_type_cd=pharm_cat_cd
       AND ocs.activity_type_cd=pharm_act_cd)
      JOIN (ofr)
      JOIN (oc
      WHERE oc.catalog_cd=ocs.catalog_cd
       AND oc.orderable_type_flag IN (0, 1))
      JOIN (oefp
      WHERE oefp.oe_format_id=ocs.oe_format_id)
      JOIN (oeff)
      JOIN (oef)
      JOIN (ofm)
      JOIN (pcor)
      JOIN (os)
      JOIN (osd)
      JOIN (cve)
     ORDER BY pc.description_key, clinical_cat, sub_clin_cat,
      ocs.mnemonic_key_cap, pcor.order_sentence_seq, os.order_sentence_id,
      ofm.oe_field_meaning_id, osd.oe_field_id
     HEAD ocs.synonym_id
      IF (os.order_sentence_id=0)
       rowcnt = (rowcnt+ 1)
       IF (mod(rowcnt,50)=1)
        stat = alterlist(ord_sents->list,(rowcnt+ 49))
       ENDIF
       ord_sents->list[rowcnt].pathway_catalog_id = pc.pathway_catalog_id, ord_sents->list[rowcnt].
       dcp_clin_cat_cd = pcmp.dcp_clin_cat_cd, ord_sents->list[rowcnt].dcp_clin_sub_cat_cd = pcmp
       .dcp_clin_sub_cat_cd,
       ord_sents->list[rowcnt].plan_disp = pc.description
       IF (ofr.synonym_id=0)
        ord_sents->list[rowcnt].synonym_vv_fac = - (1.0)
       ELSE
        ord_sents->list[rowcnt].synonym_vv_fac = ofr.facility_cd
       ENDIF
       ord_sents->list[rowcnt].catalog_cd = oc.catalog_cd, ord_sents->list[rowcnt].mnemonic = ocs
       .mnemonic, ord_sents->list[rowcnt].primary_disp = oc.primary_mnemonic,
       ord_sents->list[rowcnt].mnemonic_type_cd = ocs.mnemonic_type_cd, ord_sents->list[rowcnt].
       syn_oef = oefp.oe_format_name, ord_sents->list[rowcnt].syn_oe_format_id = ocs.oe_format_id,
       ord_sents->list[rowcnt].orderable_type_flag = oc.orderable_type_flag, ord_sents->list[rowcnt].
       rx_mask = ocs.rx_mask, ord_sents->list[rowcnt].synonym_id = ocs.synonym_id,
       ord_sents->list[rowcnt].os_disp_line = "None", ord_sents->list[rowcnt].incomplete_os_ind = 1
      ENDIF
     HEAD os.order_sentence_id
      IF (os.order_sentence_id > 0)
       sentcnt = (sentcnt+ 1), rowcnt = (rowcnt+ 1)
       IF (mod(rowcnt,50)=1)
        stat = alterlist(ord_sents->list,(rowcnt+ 49))
       ENDIF
       ord_sents->list[rowcnt].pathway_catalog_id = pc.pathway_catalog_id, ord_sents->list[rowcnt].
       dcp_clin_cat_cd = pcmp.dcp_clin_cat_cd, ord_sents->list[rowcnt].dcp_clin_sub_cat_cd = pcmp
       .dcp_clin_sub_cat_cd,
       ord_sents->list[rowcnt].plan_disp = pc.description
       IF (ofr.synonym_id=0)
        ord_sents->list[rowcnt].synonym_vv_fac = - (1.0)
       ELSE
        ord_sents->list[rowcnt].synonym_vv_fac = ofr.facility_cd
       ENDIF
       ord_sents->list[rowcnt].catalog_cd = oc.catalog_cd, ord_sents->list[rowcnt].mnemonic = ocs
       .mnemonic, ord_sents->list[rowcnt].primary_disp = oc.primary_mnemonic,
       ord_sents->list[rowcnt].mnemonic_type_cd = ocs.mnemonic_type_cd, ord_sents->list[rowcnt].
       syn_oef = oefp.oe_format_name, ord_sents->list[rowcnt].syn_oe_format_id = ocs.oe_format_id,
       ord_sents->list[rowcnt].os_oe_format_id = os.oe_format_id, ord_sents->list[rowcnt].
       orderable_type_flag = oc.orderable_type_flag, ord_sents->list[rowcnt].os_disp_line = os
       .order_sentence_display_line,
       ord_sents->list[rowcnt].order_sentence_id = os.order_sentence_id, ord_sents->list[rowcnt].
       rx_mask = ocs.rx_mask, ord_sents->list[rowcnt].synonym_id = ocs.synonym_id
      ELSE
       nosenterrorcnt = (nosenterrorcnt+ 1)
      ENDIF
     HEAD ofm.oe_field_meaning_id
      fieldfoundind = 0
     HEAD osd.oe_field_id
      IF (ofm.oe_field_meaning_id=osd.oe_field_meaning_id)
       fieldfoundind = 1
      ENDIF
      CASE (osd.oe_field_id)
       OF strengthdosefieldid:
        ord_sents->list[rowcnt].strength = osd.oe_field_value
       OF strengthdoseunitfieldid:
        ord_sents->list[rowcnt].strength_unit_cd = osd.default_parent_entity_id
       OF volumedosefieldid:
        ord_sents->list[rowcnt].volume = osd.oe_field_value
       OF volumedoseunitfieldid:
        ord_sents->list[rowcnt].volume_unit_cd = osd.default_parent_entity_id
       OF freetextdosefieldid:
        ord_sents->list[rowcnt].freetext_dose = osd.oe_field_display_value
       OF routefieldid:
        ord_sents->list[rowcnt].route_cd = osd.default_parent_entity_id
       OF formfieldid:
        ord_sents->list[rowcnt].form_cd = osd.default_parent_entity_id
       OF ratefieldid:
        ord_sents->list[rowcnt].rate = osd.oe_field_value
       OF infuseoverfieldid:
        ord_sents->list[rowcnt].infuse_over = osd.oe_field_value
      ENDCASE
      IF (osd.oe_field_id IN (strengthdoseunitfieldid, volumedoseunitfieldid)
       AND band(cnvtint(cve.field_value),32) > 0)
       ord_sents->list[rowcnt].normalized_unit_ind = 1
      ENDIF
     FOOT  ofm.oe_field_meaning_id
      IF (fieldfoundind=0
       AND ofm.oe_field_meaning_id > 0
       AND os.order_sentence_id > 0)
       IF (((oeff.default_parent_entity_id > 0) OR (oeff.default_value > " ")) )
        CASE (oeff.oe_field_id)
         OF strengthdosefieldid:
          ord_sents->list[rowcnt].strength = cnvtreal(oeff.default_value),ord_sents->list[rowcnt].
          os_disp_line = build2(ord_sents->list[rowcnt].os_disp_line," = Strength Dose of ",trim(oeff
            .default_value)," defaulted from OEF")
         OF strengthdoseunitfieldid:
          ord_sents->list[rowcnt].strength_unit_cd = oeff.default_parent_entity_id,ord_sents->list[
          rowcnt].os_disp_line = build2(ord_sents->list[rowcnt].os_disp_line,
           " = Strength Dose Unit of ",trim(uar_get_code_display(oeff.default_parent_entity_id)),
           " defaulted from OEF")
         OF volumedosefieldid:
          ord_sents->list[rowcnt].volume = cnvtreal(oeff.default_value),ord_sents->list[rowcnt].
          os_disp_line = build2(ord_sents->list[rowcnt].os_disp_line," = Volume Dose of ",trim(oeff
            .default_value)," defaulted from OEF")
         OF volumedoseunitfieldid:
          ord_sents->list[rowcnt].volume_unit_cd = oeff.default_parent_entity_id,ord_sents->list[
          rowcnt].os_disp_line = build2(ord_sents->list[rowcnt].os_disp_line,
           " = Volume Dose Unit of ",trim(uar_get_code_display(oeff.default_parent_entity_id)),
           " defaulted from OEF")
         OF freetextdosefieldid:
          ord_sents->list[rowcnt].freetext_dose = oeff.default_value,ord_sents->list[rowcnt].
          os_disp_line = build2(ord_sents->list[rowcnt].os_disp_line," = Freetext Dose of ",trim(oeff
            .default_value)," defaulted from OEF")
         OF routefieldid:
          ord_sents->list[rowcnt].route_cd = oeff.default_parent_entity_id,ord_sents->list[rowcnt].
          os_disp_line = build2(ord_sents->list[rowcnt].os_disp_line," = Route of ",trim(
            uar_get_code_display(oeff.default_parent_entity_id))," defaulted from OEF")
         OF formfieldid:
          ord_sents->list[rowcnt].form_cd = oeff.default_parent_entity_id,ord_sents->list[rowcnt].
          os_disp_line = build2(ord_sents->list[rowcnt].os_disp_line," = Form of ",trim(
            uar_get_code_display(oeff.default_parent_entity_id))," defaulted from OEF")
         OF ratefieldid:
          ord_sents->list[rowcnt].rate = cnvtreal(oeff.default_value),ord_sents->list[rowcnt].
          os_disp_line = build2(ord_sents->list[rowcnt].os_disp_line," = Rate of ",trim(oeff
            .default_value)," defaulted from OEF")
         OF infuseoverfieldid:
          ord_sents->list[rowcnt].infuse_over = cnvtreal(oeff.default_value),ord_sents->list[rowcnt].
          os_disp_line = build2(ord_sents->list[rowcnt].os_disp_line," = Infuse Over of ",trim(oeff
            .default_value)," defaulted from OEF")
        ENDCASE
       ELSE
        missingtext = ord_sents->list[rowcnt].missing_field_text
        IF (ofm.oe_field_meaning IN ("STRENGTHDOSE", "STRENGTHDOSEUNIT", "VOLUMEDOSE",
        "VOLUMEDOSEUNIT", "FREETXTDOSE",
        "RXROUTE", "DRUGFORM"))
         ord_sents->list[rowcnt].incomplete_os_ind = 1
        ENDIF
        IF (missingtext="")
         missingdetailcnt = (missingdetailcnt+ 1), missingtext = build2("Sentence is missing a ",oeff
          .label_text)
        ELSE
         missingtext = build2(missingtext,", ",oeff.label_text)
        ENDIF
        ord_sents->list[rowcnt].missing_field_text = missingtext
       ENDIF
      ENDIF
     FOOT REPORT
      IF (mod(rowcnt,50) != 0)
       stat = alterlist(ord_sents->list,rowcnt)
      ENDIF
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     ocs.mnemonic, oefp.oe_format_name, os.order_sentence_display_line,
     clinical_cat = uar_get_code_display(pcmp.dcp_clin_cat_cd), sub_clin_cat = uar_get_code_display(
      pcmp.dcp_clin_sub_cat_cd), oc.catalog_cd,
     oc.primary_mnemonic
     FROM pathway_catalog pc,
      pw_cat_reltn pcr,
      pw_cat_flex pcf,
      pathway_comp pcmp,
      order_catalog_synonym ocs,
      order_catalog oc,
      cs_component cc,
      order_catalog_synonym ocs2,
      order_entry_format_parent oefp,
      dummyt d,
      pw_comp_os_reltn pcor,
      order_sentence os,
      order_sentence_detail osd
     PLAN (pc
      WHERE pc.type_mean="PATHWAY"
       AND pc.active_ind=1
       AND pc.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND pc.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
      JOIN (pcr
      WHERE pcr.pw_cat_s_id=pc.pathway_catalog_id)
      JOIN (pcf
      WHERE pcf.pathway_catalog_id=pc.pathway_catalog_id
       AND pcf.parent_entity_name="CODE_VALUE"
       AND pcf.parent_entity_id IN (0, facilitycd))
      JOIN (pcmp
      WHERE pcmp.pathway_catalog_id=pcr.pw_cat_t_id
       AND pcmp.active_ind=1
       AND pcmp.parent_entity_name="ORDER_CATALOG_SYNONYM")
      JOIN (ocs
      WHERE ocs.synonym_id=pcmp.parent_entity_id
       AND ocs.catalog_type_cd=pharm_cat_cd
       AND ocs.activity_type_cd=pharm_act_cd)
      JOIN (oc
      WHERE oc.catalog_cd=ocs.catalog_cd
       AND oc.orderable_type_flag=8)
      JOIN (cc
      WHERE cc.catalog_cd=oc.catalog_cd)
      JOIN (ocs2
      WHERE ocs2.synonym_id=cc.comp_id)
      JOIN (oefp
      WHERE oefp.oe_format_id=ocs2.oe_format_id)
      JOIN (d)
      JOIN (pcor
      WHERE pcor.iv_comp_syn_id=ocs2.synonym_id
       AND pcor.pathway_comp_id=pcmp.pathway_comp_id)
      JOIN (os
      WHERE os.order_sentence_id=pcor.order_sentence_id)
      JOIN (osd
      WHERE osd.order_sentence_id=os.order_sentence_id)
     ORDER BY pc.description_key, clinical_cat, sub_clin_cat,
      ocs.mnemonic, pcmp.pathway_comp_id, cc.comp_seq,
      os.order_sentence_id, osd.oe_field_id
     HEAD pcmp.pathway_comp_id
      firstdiluent = 0, ivsentcnt = 0, setcnt = (setcnt+ 1)
      IF (mod(setcnt,50)=1)
       stat = alterlist(iv_sets->set_list,(setcnt+ 49))
      ENDIF
      iv_sets->set_list[setcnt].catalog_cd = oc.catalog_cd, iv_sets->set_list[setcnt].primary_disp =
      oc.primary_mnemonic, iv_sets->set_list[setcnt].plan_disp = pc.description,
      iv_sets->set_list[setcnt].dcp_clin_cat_cd = pcmp.dcp_clin_cat_cd, iv_sets->set_list[setcnt].
      dcp_clin_sub_cat_cd = pcmp.dcp_clin_sub_cat_cd, iv_sets->set_list[setcnt].pathway_catalog_id =
      pc.pathway_catalog_id
      IF (oc.dcp_clin_cat_cd=iv_solutions_cd)
       iv_sets->set_list[setcnt].med_order_type_cd = iv_type_cd
      ELSE
       iv_sets->set_list[setcnt].med_order_type_cd = int_type_cd
      ENDIF
     HEAD cc.comp_seq
      ivsentcnt = (ivsentcnt+ 1)
      IF (mod(ivsentcnt,2)=1)
       stat = alterlist(iv_sets->set_list[setcnt].syn_list,(ivsentcnt+ 1))
      ENDIF
      IF (firstdiluent=0
       AND ocs2.rx_mask=1)
       firstdiluent = cc.comp_seq
      ENDIF
      iv_sets->set_list[setcnt].syn_list[ivsentcnt].syn_catalog_cd = ocs2.catalog_cd, iv_sets->
      set_list[setcnt].syn_list[ivsentcnt].syn_mnemonic = ocs2.mnemonic, iv_sets->set_list[setcnt].
      syn_list[ivsentcnt].syn_mnemonic_type_cd = ocs2.mnemonic_type_cd,
      iv_sets->set_list[setcnt].syn_list[ivsentcnt].synonym_id = ocs2.synonym_id, iv_sets->set_list[
      setcnt].syn_list[ivsentcnt].rx_mask = ocs2.rx_mask, iv_sets->set_list[setcnt].syn_list[
      ivsentcnt].sequence = cc.comp_seq
      IF (oc.dcp_clin_cat_cd=iv_solutions_cd)
       IF (firstdiluent=cc.comp_seq)
        iv_sets->set_list[setcnt].syn_list[ivsentcnt].syn_oe_format_id = ocs2.oe_format_id, iv_sets->
        set_list[setcnt].syn_list[ivsentcnt].syn_oef = oefp.oe_format_name
       ELSE
        IF (iv_ingred_oef_id > 0)
         iv_sets->set_list[setcnt].syn_list[ivsentcnt].syn_oe_format_id = iv_ingred_oef_id, iv_sets->
         set_list[setcnt].syn_list[ivsentcnt].syn_oef = "IV Ingredient"
        ELSE
         iv_sets->set_list[setcnt].syn_list[ivsentcnt].syn_oef =
         "Error finding IV Ingredient oe_format_id"
        ENDIF
       ENDIF
      ELSE
       IF (cc.comp_seq=1)
        iv_sets->set_list[setcnt].syn_list[ivsentcnt].syn_oe_format_id = ocs2.oe_format_id, iv_sets->
        set_list[setcnt].syn_list[ivsentcnt].syn_oef = oefp.oe_format_name
       ELSE
        IF (iv_ingred_oef_id > 0)
         iv_sets->set_list[setcnt].syn_list[ivsentcnt].syn_oe_format_id = iv_ingred_oef_id, iv_sets->
         set_list[setcnt].syn_list[ivsentcnt].syn_oef = "IV Ingredient"
        ELSE
         iv_sets->set_list[setcnt].syn_list[ivsentcnt].syn_oef =
         "Error finding IV Ingredient oe_format_id"
        ENDIF
       ENDIF
      ENDIF
      iv_sets->set_list[setcnt].syn_list[ivsentcnt].os_disp_line = os.order_sentence_display_line,
      iv_sets->set_list[setcnt].syn_list[ivsentcnt].order_sentence_id = os.order_sentence_id, iv_sets
      ->set_list[setcnt].syn_list[ivsentcnt].os_oe_format_id = os.oe_format_id,
      iv_sets->set_list[setcnt].syn_list[ivsentcnt].orderable_type_flag = ocs2.orderable_type_flag
     HEAD osd.oe_field_id
      CASE (osd.oe_field_id)
       OF strengthdosefieldid:
        iv_sets->set_list[setcnt].syn_list[ivsentcnt].strength = osd.oe_field_value
       OF strengthdoseunitfieldid:
        iv_sets->set_list[setcnt].syn_list[ivsentcnt].strength_unit_cd = osd.default_parent_entity_id
       OF volumedosefieldid:
        iv_sets->set_list[setcnt].syn_list[ivsentcnt].volume = osd.oe_field_value
       OF volumedoseunitfieldid:
        iv_sets->set_list[setcnt].syn_list[ivsentcnt].volume_unit_cd = osd.default_parent_entity_id
       OF routefieldid:
        iv_sets->set_list[setcnt].route_cd = osd.default_parent_entity_id
       OF formfieldid:
        iv_sets->set_list[setcnt].form_cd = osd.default_parent_entity_id
       OF ratefieldid:
        iv_sets->set_list[setcnt].syn_list[ivsentcnt].rate = osd.oe_field_value
       OF infuseoverfieldid:
        iv_sets->set_list[setcnt].syn_list[ivsentcnt].infuse_over = osd.oe_field_value
       OF normalizedratefieldid:
        iv_sets->set_list[setcnt].syn_list[ivsentcnt].normalized_rate = osd.oe_field_value
       OF frequencyfieldid:
        iv_sets->set_list[setcnt].syn_list[ivsentcnt].frequency_cd = osd.default_parent_entity_id
       OF freetextratefieldid:
        iv_sets->set_list[setcnt].syn_list[ivsentcnt].freetext_rate = osd.oe_field_display_value
      ENDCASE
     FOOT  pcmp.pathway_comp_id
      IF (mod(ivsentcnt,2) != 0)
       stat = alterlist(iv_sets->set_list[setcnt].syn_list,ivsentcnt)
      ENDIF
     FOOT REPORT
      IF (mod(setcnt,50) != 0)
       stat = alterlist(iv_sets->set_list,setcnt)
      ENDIF
     WITH nocounter, outerjoin = d
    ;end select
   ELSEIF (searchmode=search_by_iv_set)
    SELECT INTO "nl:"
     oc.catalog_cd, oc.primary_mnemonic
     FROM order_catalog oc,
      cs_component cc,
      order_catalog_synonym ocs,
      order_entry_format_parent oefp,
      order_sentence os,
      order_sentence_detail osd
     PLAN (oc
      WHERE oc.catalog_cd=searchid
       AND oc.catalog_type_cd=pharm_cat_cd
       AND oc.orderable_type_flag=8
       AND oc.active_ind=1)
      JOIN (cc
      WHERE cc.catalog_cd=oc.catalog_cd)
      JOIN (ocs
      WHERE ocs.synonym_id=cc.comp_id)
      JOIN (oefp
      WHERE oefp.oe_format_id=ocs.oe_format_id)
      JOIN (os
      WHERE os.order_sentence_id=outerjoin(cc.order_sentence_id))
      JOIN (osd
      WHERE osd.order_sentence_id=outerjoin(os.order_sentence_id))
     ORDER BY cnvtupper(oc.primary_mnemonic), oc.catalog_cd, cc.comp_seq,
      osd.oe_field_id
     HEAD REPORT
      setcnt = 0, nosenterrorcnt = 0
     HEAD oc.catalog_cd
      firstdiluent = 0, ivsentcnt = 0, setcnt = (setcnt+ 1)
      IF (mod(setcnt,50)=1)
       stat = alterlist(iv_sets->set_list,(setcnt+ 49))
      ENDIF
      iv_sets->set_list[setcnt].catalog_cd = oc.catalog_cd, iv_sets->set_list[setcnt].primary_disp =
      oc.primary_mnemonic
      IF (oc.dcp_clin_cat_cd=iv_solutions_cd)
       iv_sets->set_list[setcnt].med_order_type_cd = iv_type_cd
      ELSE
       iv_sets->set_list[setcnt].med_order_type_cd = int_type_cd
      ENDIF
     HEAD cc.comp_seq
      ivsentcnt = (ivsentcnt+ 1)
      IF (mod(ivsentcnt,2)=1)
       stat = alterlist(iv_sets->set_list[setcnt].syn_list,(ivsentcnt+ 1))
      ENDIF
      IF (firstdiluent=0
       AND ocs.rx_mask=1)
       firstdiluent = cc.comp_seq
      ENDIF
      iv_sets->set_list[setcnt].syn_list[ivsentcnt].syn_catalog_cd = ocs.catalog_cd, iv_sets->
      set_list[setcnt].syn_list[ivsentcnt].syn_mnemonic = ocs.mnemonic, iv_sets->set_list[setcnt].
      syn_list[ivsentcnt].syn_mnemonic_type_cd = ocs.mnemonic_type_cd,
      iv_sets->set_list[setcnt].syn_list[ivsentcnt].synonym_id = ocs.synonym_id, iv_sets->set_list[
      setcnt].syn_list[ivsentcnt].rx_mask = ocs.rx_mask, iv_sets->set_list[setcnt].syn_list[ivsentcnt
      ].sequence = cc.comp_seq
      IF (oc.dcp_clin_cat_cd=iv_solutions_cd)
       IF (firstdiluent=cc.comp_seq)
        iv_sets->set_list[setcnt].syn_list[ivsentcnt].syn_oe_format_id = ocs.oe_format_id, iv_sets->
        set_list[setcnt].syn_list[ivsentcnt].syn_oef = oefp.oe_format_name
       ELSE
        IF (iv_ingred_oef_id > 0)
         iv_sets->set_list[setcnt].syn_list[ivsentcnt].syn_oe_format_id = iv_ingred_oef_id, iv_sets->
         set_list[setcnt].syn_list[ivsentcnt].syn_oef = "IV Ingredient"
        ELSE
         iv_sets->set_list[setcnt].syn_list[ivsentcnt].syn_oef =
         "Error finding IV Ingredient oe_format_id"
        ENDIF
       ENDIF
      ELSE
       IF (cc.comp_seq=1)
        iv_sets->set_list[setcnt].syn_list[ivsentcnt].syn_oe_format_id = ocs.oe_format_id, iv_sets->
        set_list[setcnt].syn_list[ivsentcnt].syn_oef = oefp.oe_format_name
       ELSE
        IF (iv_ingred_oef_id > 0)
         iv_sets->set_list[setcnt].syn_list[ivsentcnt].syn_oe_format_id = iv_ingred_oef_id, iv_sets->
         set_list[setcnt].syn_list[ivsentcnt].syn_oef = "IV Ingredient"
        ELSE
         iv_sets->set_list[setcnt].syn_list[ivsentcnt].syn_oef =
         "Error finding IV Ingredient oe_format_id"
        ENDIF
       ENDIF
      ENDIF
      iv_sets->set_list[setcnt].syn_list[ivsentcnt].os_disp_line = os.order_sentence_display_line,
      iv_sets->set_list[setcnt].syn_list[ivsentcnt].order_sentence_id = os.order_sentence_id, iv_sets
      ->set_list[setcnt].syn_list[ivsentcnt].os_oe_format_id = os.oe_format_id,
      iv_sets->set_list[setcnt].syn_list[ivsentcnt].orderable_type_flag = ocs.orderable_type_flag
     HEAD osd.oe_field_id
      CASE (osd.oe_field_id)
       OF strengthdosefieldid:
        iv_sets->set_list[setcnt].syn_list[ivsentcnt].strength = osd.oe_field_value
       OF strengthdoseunitfieldid:
        iv_sets->set_list[setcnt].syn_list[ivsentcnt].strength_unit_cd = osd.default_parent_entity_id
       OF volumedosefieldid:
        iv_sets->set_list[setcnt].syn_list[ivsentcnt].volume = osd.oe_field_value
       OF volumedoseunitfieldid:
        iv_sets->set_list[setcnt].syn_list[ivsentcnt].volume_unit_cd = osd.default_parent_entity_id
       OF routefieldid:
        iv_sets->set_list[setcnt].route_cd = osd.default_parent_entity_id
       OF formfieldid:
        iv_sets->set_list[setcnt].form_cd = osd.default_parent_entity_id
       OF ratefieldid:
        iv_sets->set_list[setcnt].syn_list[ivsentcnt].rate = osd.oe_field_value
       OF infuseoverfieldid:
        iv_sets->set_list[setcnt].syn_list[ivsentcnt].infuse_over = osd.oe_field_value
       OF normalizedratefieldid:
        iv_sets->set_list[setcnt].syn_list[ivsentcnt].normalized_rate = osd.oe_field_value
       OF frequencyfieldid:
        iv_sets->set_list[setcnt].syn_list[ivsentcnt].frequency_cd = osd.default_parent_entity_id
       OF freetextratefieldid:
        iv_sets->set_list[setcnt].syn_list[ivsentcnt].freetext_rate = osd.oe_field_display_value
      ENDCASE
     FOOT  oc.catalog_cd
      IF (mod(ivsentcnt,2) != 0)
       stat = alterlist(iv_sets->set_list[setcnt].syn_list,ivsentcnt)
      ENDIF
     FOOT REPORT
      IF (mod(setcnt,50) != 0)
       stat = alterlist(iv_sets->set_list,setcnt)
      ENDIF
     WITH nocounter
    ;end select
   ELSEIF (searchmode=search_by_all_iv_set)
    SELECT INTO "nl:"
     oc.catalog_cd, oc.primary_mnemonic
     FROM order_catalog oc,
      order_catalog_synonym setocs,
      cs_component cc,
      (left JOIN order_sentence os ON os.order_sentence_id=cc.order_sentence_id),
      (left JOIN order_sentence_detail osd ON osd.order_sentence_id=os.order_sentence_id),
      ocs_facility_r ofr,
      order_catalog_synonym ocs,
      (left JOIN ocs_facility_r ofr2 ON ofr2.synonym_id=ocs.synonym_id
       AND ofr2.facility_cd IN (0, facilitycd)),
      order_entry_format_parent oefp
     PLAN (oc
      WHERE oc.catalog_type_cd=pharm_cat_cd
       AND oc.orderable_type_flag=8
       AND oc.active_ind=1)
      JOIN (cc
      WHERE cc.catalog_cd=oc.catalog_cd)
      JOIN (os)
      JOIN (osd)
      JOIN (setocs
      WHERE setocs.catalog_cd=cc.catalog_cd)
      JOIN (ofr
      WHERE ofr.synonym_id=setocs.synonym_id
       AND ofr.facility_cd IN (0, facilitycd))
      JOIN (ocs
      WHERE ocs.synonym_id=cc.comp_id)
      JOIN (ofr2)
      JOIN (oefp
      WHERE oefp.oe_format_id=ocs.oe_format_id)
     ORDER BY cnvtupper(oc.primary_mnemonic), oc.catalog_cd, cc.comp_seq,
      osd.oe_field_id
     HEAD REPORT
      setcnt = 0, nosenterrorcnt = 0
     HEAD oc.catalog_cd
      firstdiluent = 0, ivsentcnt = 0, setcnt = (setcnt+ 1)
      IF (mod(setcnt,50)=1)
       stat = alterlist(iv_sets->set_list,(setcnt+ 49))
      ENDIF
      iv_sets->set_list[setcnt].catalog_cd = oc.catalog_cd, iv_sets->set_list[setcnt].primary_disp =
      oc.primary_mnemonic
      IF (oc.dcp_clin_cat_cd=iv_solutions_cd)
       iv_sets->set_list[setcnt].med_order_type_cd = iv_type_cd
      ELSE
       iv_sets->set_list[setcnt].med_order_type_cd = int_type_cd
      ENDIF
     HEAD cc.comp_seq
      ivsentcnt = (ivsentcnt+ 1)
      IF (mod(ivsentcnt,2)=1)
       stat = alterlist(iv_sets->set_list[setcnt].syn_list,(ivsentcnt+ 1))
      ENDIF
      IF (firstdiluent=0
       AND ocs.rx_mask=1)
       firstdiluent = cc.comp_seq
      ENDIF
      iv_sets->set_list[setcnt].syn_list[ivsentcnt].syn_catalog_cd = ocs.catalog_cd, iv_sets->
      set_list[setcnt].syn_list[ivsentcnt].syn_mnemonic = ocs.mnemonic, iv_sets->set_list[setcnt].
      syn_list[ivsentcnt].syn_mnemonic_type_cd = ocs.mnemonic_type_cd,
      iv_sets->set_list[setcnt].syn_list[ivsentcnt].synonym_id = ocs.synonym_id, iv_sets->set_list[
      setcnt].syn_list[ivsentcnt].rx_mask = ocs.rx_mask, iv_sets->set_list[setcnt].syn_list[ivsentcnt
      ].sequence = cc.comp_seq
      IF (ofr2.synonym_id=0)
       iv_sets->set_list[setcnt].syn_list[ivsentcnt].synonym_vv_fac = - (1.0)
      ELSE
       iv_sets->set_list[setcnt].syn_list[ivsentcnt].synonym_vv_fac = ofr2.facility_cd
      ENDIF
      IF (oc.dcp_clin_cat_cd=iv_solutions_cd)
       IF (firstdiluent=cc.comp_seq)
        iv_sets->set_list[setcnt].syn_list[ivsentcnt].syn_oe_format_id = ocs.oe_format_id, iv_sets->
        set_list[setcnt].syn_list[ivsentcnt].syn_oef = oefp.oe_format_name
       ELSE
        IF (iv_ingred_oef_id > 0)
         iv_sets->set_list[setcnt].syn_list[ivsentcnt].syn_oe_format_id = iv_ingred_oef_id, iv_sets->
         set_list[setcnt].syn_list[ivsentcnt].syn_oef = "IV Ingredient"
        ELSE
         iv_sets->set_list[setcnt].syn_list[ivsentcnt].syn_oef =
         "Error finding IV Ingredient oe_format_id"
        ENDIF
       ENDIF
      ELSE
       IF (cc.comp_seq=1)
        iv_sets->set_list[setcnt].syn_list[ivsentcnt].syn_oe_format_id = ocs.oe_format_id, iv_sets->
        set_list[setcnt].syn_list[ivsentcnt].syn_oef = oefp.oe_format_name
       ELSE
        IF (iv_ingred_oef_id > 0)
         iv_sets->set_list[setcnt].syn_list[ivsentcnt].syn_oe_format_id = iv_ingred_oef_id, iv_sets->
         set_list[setcnt].syn_list[ivsentcnt].syn_oef = "IV Ingredient"
        ELSE
         iv_sets->set_list[setcnt].syn_list[ivsentcnt].syn_oef =
         "Error finding IV Ingredient oe_format_id"
        ENDIF
       ENDIF
      ENDIF
      iv_sets->set_list[setcnt].syn_list[ivsentcnt].os_disp_line = os.order_sentence_display_line,
      iv_sets->set_list[setcnt].syn_list[ivsentcnt].order_sentence_id = os.order_sentence_id, iv_sets
      ->set_list[setcnt].syn_list[ivsentcnt].os_oe_format_id = os.oe_format_id,
      iv_sets->set_list[setcnt].syn_list[ivsentcnt].orderable_type_flag = ocs.orderable_type_flag
     HEAD osd.oe_field_id
      CASE (osd.oe_field_id)
       OF strengthdosefieldid:
        iv_sets->set_list[setcnt].syn_list[ivsentcnt].strength = osd.oe_field_value
       OF strengthdoseunitfieldid:
        iv_sets->set_list[setcnt].syn_list[ivsentcnt].strength_unit_cd = osd.default_parent_entity_id
       OF volumedosefieldid:
        iv_sets->set_list[setcnt].syn_list[ivsentcnt].volume = osd.oe_field_value
       OF volumedoseunitfieldid:
        iv_sets->set_list[setcnt].syn_list[ivsentcnt].volume_unit_cd = osd.default_parent_entity_id
       OF routefieldid:
        iv_sets->set_list[setcnt].route_cd = osd.default_parent_entity_id
       OF formfieldid:
        iv_sets->set_list[setcnt].form_cd = osd.default_parent_entity_id
       OF ratefieldid:
        iv_sets->set_list[setcnt].syn_list[ivsentcnt].rate = osd.oe_field_value
       OF infuseoverfieldid:
        iv_sets->set_list[setcnt].syn_list[ivsentcnt].infuse_over = osd.oe_field_value
       OF normalizedratefieldid:
        iv_sets->set_list[setcnt].syn_list[ivsentcnt].normalized_rate = osd.oe_field_value
       OF frequencyfieldid:
        iv_sets->set_list[setcnt].syn_list[ivsentcnt].frequency_cd = osd.default_parent_entity_id
       OF freetextratefieldid:
        iv_sets->set_list[setcnt].syn_list[ivsentcnt].freetext_rate = osd.oe_field_display_value
      ENDCASE
     FOOT  oc.catalog_cd
      IF (mod(ivsentcnt,2) != 0)
       stat = alterlist(iv_sets->set_list[setcnt].syn_list,ivsentcnt)
      ENDIF
     FOOT REPORT
      IF (mod(setcnt,50) != 0)
       stat = alterlist(iv_sets->set_list,setcnt)
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   IF (searchmode != search_by_iv_set
    AND searchmode != search_by_all_iv_set)
    CALL calculatefinitedose(null)
    IF (debug_ind=1)
     CALL addlogmsg("INFO","ord_sents record after being loaded in getOrderSents():")
     CALL echorecord(ord_sents,logfilename,1)
    ENDIF
    RETURN(sentcnt)
   ELSE
    IF (debug_ind=1)
     CALL addlogmsg("INFO","iv_sets record after being loaded in getOrderSents():")
     CALL echorecord(iv_sets,logfilename,1)
    ENDIF
    RETURN(setcnt)
   ENDIF
 END ;Subroutine
 SUBROUTINE loadrequest(null)
   DECLARE loopcnt = i4 WITH protect
   DECLARE pricecnt = i4 WITH protect
   DECLARE sentcnt = f8 WITH protect
   CALL setmedordertypecd(0)
   SET criticalerrorcnt = 0
   SET noproderrorcnt = 0
   FOR (loopcnt = 1 TO size(ord_sents->list,5))
     IF ((ord_sents->list[loopcnt].order_sentence_id > 0))
      SET sentcnt = (sentcnt+ 1)
     ENDIF
     CALL text((soffrow+ 14),(soffcol+ 30),build2("Assigning product to sentence ",trim(cnvtstring(
         sentcnt))," of ",trim(cnvtstring(totalsentcnt))))
     IF ((ord_sents->list[loopcnt].incomplete_os_ind=0)
      AND (ord_sents->list[loopcnt].order_sentence_id > 0))
      SET stat = initrec(apa_request)
      SET stat = alterlist(apa_request->catalog_group,1)
      SET stat = alterlist(apa_request->catalog_group[1].order_type_list,size(ord_sents->list[loopcnt
        ].order_type_list,5))
      SET stat = alterlist(apa_request->catalog_group[1].catalog_list,1)
      SET apa_request->catalog_group[1].encounter_type_cd = encountertypecd
      SET apa_request->catalog_group[1].facility_cd = facilitycd
      SET apa_request->catalog_group[1].form_cd = ord_sents->list[loopcnt].form_cd
      SET apa_request->catalog_group[1].pat_locn_cd = nurseunitcd
      SET apa_request->catalog_group[1].route_cd = ord_sents->list[loopcnt].route_cd
      SET apa_request->catalog_group[1].skip_iv_ind = 0
      FOR (i = 1 TO size(ord_sents->list[loopcnt].order_type_list,5))
        SET apa_request->catalog_group[1].order_type_list[i].med_order_type_cd = ord_sents->list[
        loopcnt].order_type_list[i].med_order_type_cd
      ENDFOR
      SET apa_request->catalog_group[1].catalog_list[1].catalog_cd = ord_sents->list[loopcnt].
      catalog_cd
      SET apa_request->catalog_group[1].catalog_list[1].freetext_dose = ord_sents->list[loopcnt].
      freetext_dose
      SET apa_request->catalog_group[1].catalog_list[1].orderable_type_flag = ord_sents->list[loopcnt
      ].orderable_type_flag
      SET apa_request->catalog_group[1].catalog_list[1].strength = ord_sents->list[loopcnt].strength
      SET apa_request->catalog_group[1].catalog_list[1].strength_unit_cd = ord_sents->list[loopcnt].
      strength_unit_cd
      SET apa_request->catalog_group[1].catalog_list[1].synonym_id = ord_sents->list[loopcnt].
      synonym_id
      SET apa_request->catalog_group[1].catalog_list[1].volume = ord_sents->list[loopcnt].volume
      SET apa_request->catalog_group[1].catalog_list[1].volume_unit_cd = ord_sents->list[loopcnt].
      volume_unit_cd
      SET stat = processrequest(loopcnt)
      IF ((stat=- (1)))
       RETURN(0)
      ELSEIF (stat=1)
       SET apacnt = (apacnt+ 1)
      ENDIF
     ELSEIF ((ord_sents->list[loopcnt].incomplete_os_ind=1)
      AND (ord_sents->list[loopcnt].order_sentence_id > 0))
      SET stat = alterlist(ord_sents->list[loopcnt].items,1)
      SET ord_sents->list[loopcnt].items[1].item_desc = " "
      SET ord_sents->list[loopcnt].items[1].item_id = 0
      SET ord_sents->list[loopcnt].items[1].qpd = 0
      SET ord_sents->list[loopcnt].items[1].assigned_by = "None"
     ELSE
      SET stat = alterlist(ord_sents->list[loopcnt].items,1)
     ENDIF
     SET apapercent = ((apacnt/ sentcnt) * 100)
     CALL text(quesrow,(soffcol+ 57),build2("APA rate: ",trim(cnvtstring(apapercent,11,2)),"% "))
   ENDFOR
   IF (checkallprimariesind=1)
    IF (deleteerrorcnt(build(script_name,"|SENTENCES")) > 1)
     SET status = "F"
     SET statusstr = build2("Error removing dm_info row for ",build(script_name,"|SENTENCES"))
     GO TO exit_script
    ENDIF
    IF (incrementerrorcnt(build(script_name,"|SENTENCES"),round(apapercent,2),
     "Percentage of sentences that APA:")=0)
     SET status = "F"
     SET statusstr = build2("Failed to set error count for audit: SENTENCES")
     GO TO exit_script
    ELSE
     COMMIT
    ENDIF
   ENDIF
   CALL loaditemdetails(null)
   SET sentcnt = 0
   CALL clear((soffrow+ 14),soffcol,numcols)
   FOR (pricecnt = 1 TO size(ord_sents->list,5))
     IF ((ord_sents->list[pricecnt].order_sentence_id > 0))
      SET sentcnt = (sentcnt+ 1)
     ENDIF
     CALL text((soffrow+ 14),(soffcol+ 30),build2("Calculating price for sentence ",trim(cnvtstring(
         sentcnt))," of ",trim(cnvtstring(totalsentcnt))))
     IF ((ord_sents->list[pricecnt].order_sentence_id > 0))
      CALL calculateorderprice(pricecnt)
     ENDIF
   ENDFOR
   CALL clear((soffrow+ 14),soffcol,numcols)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE loaditemdetails(null)
  IF (size(iv_sets->set_list,5) > 0)
   SELECT INTO "nl:"
    mi.item_id, mi.value
    FROM (dummyt d1  WITH seq = value(size(iv_sets->set_list,5))),
     med_def_flex mdf,
     med_flex_object_idx mfoi,
     med_oe_defaults mod,
     med_identifier mi,
     price_sched ps
    PLAN (d1
     WHERE (iv_sets->set_list[d1.seq].set_id > 0))
     JOIN (mdf
     WHERE (mdf.item_id=iv_sets->set_list[d1.seq].set_id)
      AND mdf.pharmacy_type_cd=inpatient_type_cd
      AND mdf.flex_type_cd=system_type_cd)
     JOIN (mfoi
     WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
      AND mfoi.parent_entity_name="MED_OE_DEFAULTS")
     JOIN (mod
     WHERE mod.med_oe_defaults_id=mfoi.parent_entity_id)
     JOIN (mi
     WHERE mi.item_id=mdf.item_id
      AND mi.item_id != 0
      AND mi.med_identifier_type_cd=desc_cd
      AND mi.med_product_id=0
      AND mi.active_ind=1
      AND mi.primary_ind=1
      AND mi.pharmacy_type_cd=inpatient_type_cd)
     JOIN (ps
     WHERE ps.price_sched_id=outerjoin(mod.price_sched_id))
    DETAIL
     iv_sets->set_list[d1.seq].set_desc = trim(mi.value), iv_sets->set_list[d1.seq].
     set_price_sched_id = mod.price_sched_id, iv_sets->set_list[d1.seq].
     set_price_sched_formula_type_flag = ps.formula_type_flg
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    mi.item_id, mi.value
    FROM (dummyt d1  WITH seq = value(size(iv_sets->set_list,5))),
     (dummyt d2  WITH seq = 1),
     med_def_flex mdf,
     med_flex_object_idx mfoi,
     med_flex_object_idx mfoi2,
     med_oe_defaults mod,
     med_identifier mi,
     dispense_category dc,
     med_identifier ndc,
     med_product mp,
     price_sched ps
    PLAN (d1
     WHERE maxrec(d2,size(iv_sets->set_list[d1.seq].syn_list,5)))
     JOIN (d2)
     JOIN (mdf
     WHERE (mdf.item_id=iv_sets->set_list[d1.seq].syn_list[d2.seq].item_id)
      AND mdf.pharmacy_type_cd=inpatient_type_cd
      AND mdf.flex_type_cd=system_type_cd)
     JOIN (mfoi
     WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
      AND mfoi.parent_entity_name="MED_OE_DEFAULTS")
     JOIN (mfoi2
     WHERE mfoi2.med_def_flex_id=mdf.med_def_flex_id
      AND mfoi2.parent_entity_name="MED_PRODUCT"
      AND mfoi2.sequence=1)
     JOIN (mod
     WHERE mod.med_oe_defaults_id=mfoi.parent_entity_id)
     JOIN (ps
     WHERE ps.price_sched_id=outerjoin(mod.price_sched_id))
     JOIN (mi
     WHERE mi.item_id=mdf.item_id
      AND mi.item_id != 0
      AND mi.med_identifier_type_cd=desc_cd
      AND mi.med_product_id=0
      AND mi.active_ind=1
      AND mi.primary_ind=1
      AND mi.pharmacy_type_cd=inpatient_type_cd)
     JOIN (dc
     WHERE dc.dispense_category_cd=mod.dispense_category_cd)
     JOIN (ndc
     WHERE ndc.item_id=mdf.item_id
      AND ndc.med_product_id=mfoi2.parent_entity_id
      AND ndc.med_identifier_type_cd=ndc_cd
      AND ndc.active_ind=1
      AND ndc.pharmacy_type_cd=inpatient_type_cd)
     JOIN (mp
     WHERE mp.med_product_id=ndc.med_product_id)
    DETAIL
     iv_sets->set_list[d1.seq].syn_list[d2.seq].item_desc = trim(mi.value), iv_sets->set_list[d1.seq]
     .syn_list[d2.seq].price_sched_id = mod.price_sched_id, iv_sets->set_list[d1.seq].syn_list[d2.seq
     ].manf_item_id = mp.manf_item_id,
     iv_sets->set_list[d1.seq].syn_list[d2.seq].price_sched_formula_type_flag = ps.formula_type_flg
     IF (dc.round_disp_qty_ind=1)
      iv_sets->set_list[d1.seq].syn_list[d2.seq].round_disp_qty_ind = 1, iv_sets->set_list[d1.seq].
      syn_list[d2.seq].qpd = ceil(iv_sets->set_list[d1.seq].syn_list[d2.seq].qpd)
     ENDIF
    WITH nocounter
   ;end select
   IF (debug_ind=1)
    CALL addlogmsg("INFO","iv_sets record after descriptions are loaded by loadItemDetails():")
    CALL echorecord(iv_sets,logfilename,1)
   ENDIF
  ENDIF
  IF (size(ord_sents->list,5) > 0)
   SELECT INTO "nl:"
    mi.item_id, mi.value
    FROM (dummyt d1  WITH seq = value(size(ord_sents->list,5))),
     med_def_flex mdf,
     med_flex_object_idx mfoi,
     med_oe_defaults mod,
     med_identifier mi,
     price_sched ps
    PLAN (d1
     WHERE (ord_sents->list[d1.seq].set_id > 0))
     JOIN (mdf
     WHERE (mdf.item_id=ord_sents->list[d1.seq].set_id)
      AND mdf.pharmacy_type_cd=inpatient_type_cd
      AND mdf.flex_type_cd=system_type_cd)
     JOIN (mfoi
     WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
      AND mfoi.parent_entity_name="MED_OE_DEFAULTS")
     JOIN (mod
     WHERE mod.med_oe_defaults_id=mfoi.parent_entity_id)
     JOIN (mi
     WHERE mi.item_id=mdf.item_id
      AND mi.item_id != 0
      AND mi.med_identifier_type_cd=desc_cd
      AND mi.med_product_id=0
      AND mi.active_ind=1
      AND mi.primary_ind=1
      AND mi.pharmacy_type_cd=inpatient_type_cd)
     JOIN (ps
     WHERE ps.price_sched_id=outerjoin(mod.price_sched_id))
    DETAIL
     ord_sents->list[d1.seq].set_desc = trim(mi.value), ord_sents->list[d1.seq].set_price_sched_id =
     mod.price_sched_id, ord_sents->list[d1.seq].set_price_sched_formula_type_flag = ps
     .formula_type_flg
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    mi.item_id, mi.value
    FROM (dummyt d1  WITH seq = value(size(ord_sents->list,5))),
     (dummyt d2  WITH seq = 1),
     med_def_flex mdf,
     med_flex_object_idx mfoi,
     med_flex_object_idx mfoi2,
     med_oe_defaults mod,
     med_identifier mi,
     dispense_category dc,
     med_identifier ndc,
     med_product mp,
     price_sched ps
    PLAN (d1
     WHERE maxrec(d2,size(ord_sents->list[d1.seq].items,5)))
     JOIN (d2)
     JOIN (mdf
     WHERE (mdf.item_id=ord_sents->list[d1.seq].items[d2.seq].item_id)
      AND mdf.pharmacy_type_cd=inpatient_type_cd
      AND mdf.flex_type_cd=system_type_cd)
     JOIN (mfoi
     WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
      AND mfoi.parent_entity_name="MED_OE_DEFAULTS")
     JOIN (mfoi2
     WHERE mfoi2.med_def_flex_id=mdf.med_def_flex_id
      AND mfoi2.parent_entity_name="MED_PRODUCT"
      AND mfoi2.sequence=1)
     JOIN (mod
     WHERE mod.med_oe_defaults_id=mfoi.parent_entity_id)
     JOIN (ps
     WHERE ps.price_sched_id=outerjoin(mod.price_sched_id))
     JOIN (mi
     WHERE mi.item_id=mdf.item_id
      AND mi.item_id != 0
      AND mi.med_identifier_type_cd=desc_cd
      AND mi.med_product_id=0
      AND mi.active_ind=1
      AND mi.primary_ind=1
      AND mi.pharmacy_type_cd=inpatient_type_cd)
     JOIN (dc
     WHERE dc.dispense_category_cd=mod.dispense_category_cd)
     JOIN (ndc
     WHERE ndc.item_id=mdf.item_id
      AND ndc.med_product_id=mfoi2.parent_entity_id
      AND ndc.med_identifier_type_cd=ndc_cd
      AND ndc.active_ind=1
      AND ndc.pharmacy_type_cd=inpatient_type_cd)
     JOIN (mp
     WHERE mp.med_product_id=ndc.med_product_id)
    DETAIL
     ord_sents->list[d1.seq].items[d2.seq].item_desc = trim(mi.value), ord_sents->list[d1.seq].items[
     d2.seq].price_sched_id = mod.price_sched_id, ord_sents->list[d1.seq].items[d2.seq].manf_item_id
      = mp.manf_item_id,
     ord_sents->list[d1.seq].items[d2.seq].price_sched_formula_type_flag = ps.formula_type_flg
     IF (dc.round_disp_qty_ind=1)
      ord_sents->list[d1.seq].items[d2.seq].round_disp_qty_ind = 1, ord_sents->list[d1.seq].items[d2
      .seq].qpd = ceil(ord_sents->list[d1.seq].items[d2.seq].qpd)
     ENDIF
    WITH nocounter
   ;end select
   IF (debug_ind=1)
    CALL addlogmsg("INFO","ord_sents record after descriptions are loaded by loadItemDetails():")
    CALL echorecord(ord_sents,logfilename,1)
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE calculateorderprice(pos)
   DECLARE idx = i4 WITH protect
   DECLARE itemcnt = i4 WITH protect
   DECLARE totalcost = f8 WITH protect
   SET stat = initrec(price_request)
   SET stat = initrec(price_reply)
   IF (programmode=iv_set_mode)
    IF ((iv_sets->set_list[pos].set_id > 0))
     SET itemcnt = size(iv_sets->set_list[pos].syn_list,5)
     SET price_request->price_schedule_id = iv_sets->set_list[pos].set_price_sched_id
     SET price_request->pricing_ind = iv_sets->set_list[pos].set_price_sched_formula_type_flag
     SET price_request->total_price = 0.0
     SET price_request->care_locn_cd = nurseunitcd
     SET price_request->inv_loc_cd = 0.0
     SET price_request->facility_cd = facilitycd
     SET price_request->encounter_type_cd = encountertypecd
     SET stat = alterlist(price_request->bill_list,itemcnt)
     FOR (idx = 1 TO itemcnt)
       SET price_request->bill_list[idx].item_id = iv_sets->set_list[pos].syn_list[idx].item_id
       SET price_request->bill_list[idx].dose_quantity = iv_sets->set_list[pos].syn_list[idx].qpd
       SET price_request->bill_list[idx].price = 0.0
       SET price_request->bill_list[idx].manf_id = iv_sets->set_list[pos].syn_list[idx].manf_item_id
       SET price_request->bill_list[idx].tnf_cost = 0.0
     ENDFOR
     IF (debug_ind=1)
      CALL addlogmsg("INFO","price_request structure after being loaded by calculateOrderPrice():")
      CALL echorecord(price_request,logfilename,1)
     ENDIF
     SET message = window
     SET stat = initrec(price_reply)
     EXECUTE rx_get_cost_wrapper  WITH replace("REQUEST",price_request), replace("REPLY",price_reply)
     IF (debug_ind=1)
      CALL addlogmsg("INFO","price_reply structure:")
      CALL echorecord(price_reply,logfilename,1)
     ENDIF
     SET totalcost = 0.0
     FOR (idx = 1 TO size(price_reply->bill_list,5))
       SET totalcost = (totalcost+ price_reply->bill_list[idx].cost)
     ENDFOR
     SET iv_sets->set_list[pos].price = price_reply->total_price
     SET iv_sets->set_list[pos].cost = totalcost
    ENDIF
   ELSE
    SET itemcnt = size(ord_sents->list[pos].items,5)
    IF (itemcnt > 0)
     IF ((ord_sents->list[pos].set_price_sched_id > 0))
      SET price_request->price_schedule_id = ord_sents->list[pos].set_price_sched_id
      SET price_request->pricing_ind = ord_sents->list[pos].set_price_sched_formula_type_flag
     ELSE
      SET price_request->price_schedule_id = ord_sents->list[pos].items[1].price_sched_id
      SET price_request->pricing_ind = ord_sents->list[pos].items[1].price_sched_formula_type_flag
     ENDIF
     SET price_request->total_price = 0.0
     SET price_request->care_locn_cd = nurseunitcd
     SET price_request->inv_loc_cd = 0.0
     SET price_request->facility_cd = facilitycd
     SET price_request->encounter_type_cd = encountertypecd
     SET stat = alterlist(price_request->bill_list,itemcnt)
     FOR (idx = 1 TO itemcnt)
       SET price_request->bill_list[idx].item_id = ord_sents->list[pos].items[idx].item_id
       SET price_request->bill_list[idx].dose_quantity = ord_sents->list[pos].items[idx].qpd
       SET price_request->bill_list[idx].price = 0.0
       SET price_request->bill_list[idx].manf_id = ord_sents->list[pos].items[idx].manf_item_id
       SET price_request->bill_list[idx].tnf_cost = 0.0
     ENDFOR
     IF (debug_ind=1)
      CALL addlogmsg("INFO","price_request structure after being loaded by calculateOrderPrice():")
      CALL echorecord(price_request,logfilename,1)
     ENDIF
     SET message = window
     SET stat = initrec(price_reply)
     EXECUTE rx_get_cost_wrapper  WITH replace("REQUEST",price_request), replace("REPLY",price_reply)
     IF (debug_ind=1)
      CALL addlogmsg("INFO","price_reply structure:")
      CALL echorecord(price_reply,logfilename,1)
     ENDIF
     SET totalcost = 0.0
     FOR (idx = 1 TO size(price_reply->bill_list,5))
       SET totalcost = (totalcost+ price_reply->bill_list[idx].cost)
     ENDFOR
     SET ord_sents->list[pos].price = price_reply->total_price
     SET ord_sents->list[pos].cost = totalcost
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE explodevolumedose(ingredstr,ingredstrunitcd,itemid)
   DECLARE volumedose = f8 WITH protect
   DECLARE productvol = f8 WITH protect
   DECLARE productstr = f8 WITH protect
   DECLARE productstrunitcd = f8 WITH protect
   DECLARE itempos = i4 WITH protect
   SET itempos = locateval(i,1,size(item_info->list,5),itemid,item_info->list[i].item_id)
   IF (debug_ind=1)
    CALL addlogmsg("INFO","Inside explodeVolumeDose()")
    CALL addlogmsg("INFO",build("itemPos = ",itempos))
   ENDIF
   IF (itempos > 0)
    SET productvol = item_info->list[itempos].vol
    SET productstr = item_info->list[itempos].str
    SET productstrunitcd = item_info->list[itempos].strunitcd
    IF (productstr <= 0.0)
     RETURN(cnvtreal(product_no_strength))
    ELSE
     IF (productstrunitcd != ingredstrunitcd)
      IF (debug_ind=1)
       CALL addlogmsg("INFO","productStrUnitCd does not match ingredStrUnitCd")
       CALL addlogmsg("INFO",build("productStrUnitCd = ",productstrunitcd))
       CALL addlogmsg("INFO",build("ingredStrUnitCd = ",ingredstrunitcd))
      ENDIF
      SET productstr = getconvertedstrength(itemid,ingredstrunitcd)
      IF (productstr <= 0)
       RETURN(productstr)
      ENDIF
     ENDIF
     SET volumedose = round((ingredstr * (productvol/ productstr)),2)
     IF (debug_ind=1)
      CALL addlogmsg("INFO",build("volumeDose being returned = ",volumedose))
      CALL addlogmsg("INFO",build("round(",ingredstr," * ","(",productvol,
        "/",productstr,"),2)"))
     ENDIF
     RETURN(volumedose)
    ENDIF
   ELSE
    RETURN(cnvtreal(unknown_error))
   ENDIF
 END ;Subroutine
 SUBROUTINE explodestrengthdose(ingredvol,ingredvolunitcd,itemid)
   DECLARE strengthdose = f8 WITH protect
   DECLARE productvol = f8 WITH protect
   DECLARE productstr = f8 WITH protect
   DECLARE productvolunitcd = f8 WITH protect
   DECLARE itempos = i4 WITH protect
   SET itempos = locateval(i,1,size(item_info->list,5),itemid,item_info->list[i].item_id)
   IF (debug_ind=1)
    CALL addlogmsg("INFO","Inside explodeStrengthDose()")
    CALL addlogmsg("INFO",build("itemPos = ",itempos))
   ENDIF
   IF (itempos > 0)
    SET productvol = item_info->list[itempos].vol
    SET productstr = item_info->list[itempos].str
    SET productvolunitcd = item_info->list[itempos].volunitcd
    IF (productvol <= 0.0)
     RETURN(cnvtreal(product_no_volume))
    ELSE
     IF (productvolunitcd != ingredvolunitcd)
      IF (debug_ind=1)
       CALL addlogmsg("INFO","productVolUnitCd does not match ingredVolUnitCd")
       CALL addlogmsg("INFO",build("productVolUnitCd = ",productvolunitcd))
       CALL addlogmsg("INFO",build("ingredVolUnitCd = ",ingredvolunitcd))
      ENDIF
      SET productvol = getconvertedvolume(itemid,ingredvolunitcd)
      IF (productvol <= 0)
       RETURN(productvol)
      ENDIF
     ENDIF
     SET strengthdose = round((ingredvol * (productstr/ productvol)),4)
     IF (debug_ind=1)
      CALL addlogmsg("INFO",build("strengthDose being returned = ",strengthdose))
      CALL addlogmsg("INFO",build("round(",ingredvol," * ","(",productstr,
        "/",productvol,"),4)"))
     ENDIF
     RETURN(strengthdose)
    ENDIF
   ELSE
    RETURN(cnvtreal(unknown_error))
   ENDIF
 END ;Subroutine
 SUBROUTINE getconvertedstrength(itemid,targetunitcd)
   DECLARE convertstr = f8 WITH protect
   SET itempos = locateval(i,1,size(item_info->list,5),itemid,item_info->list[i].item_id)
   IF (debug_ind=1)
    CALL addlogmsg("INFO","Inside getConvertedStrength()")
   ENDIF
   IF (itempos > 0)
    IF ((item_info->list[itempos].str=0))
     RETURN(cnvtreal(product_no_strength))
    ELSE
     IF ((item_info->list[itempos].strunitcd=targetunitcd))
      RETURN(item_info->list[itempos].str)
     ELSE
      SET convertstr = convertvaluetounit(item_info->list[itempos].str,item_info->list[itempos].
       strunitcd,targetunitcd)
      IF (debug_ind=1)
       CALL addlogmsg("INFO",build("convertStr = ",convertstr))
      ENDIF
      RETURN(convertstr)
     ENDIF
    ENDIF
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE getconvertedvolume(itemid,targetunitcd)
   DECLARE convertvol = f8 WITH protect
   SET itempos = locateval(i,1,size(item_info->list,5),itemid,item_info->list[i].item_id)
   IF (debug_ind=1)
    CALL addlogmsg("INFO","Inside getConvertedVolume()")
   ENDIF
   IF (itempos > 0)
    IF ((item_info->list[itempos].vol=0))
     RETURN(cnvtreal(product_no_volume))
    ELSE
     IF ((item_info->list[itempos].volunitcd=targetunitcd))
      RETURN(item_info->list[itempos].vol)
     ELSE
      SET convertvol = convertvaluetounit(item_info->list[itempos].vol,item_info->list[itempos].
       volunitcd,targetunitcd)
      IF (debug_ind=1)
       CALL addlogmsg("INFO",build("convertVol = ",convertvol))
      ENDIF
      RETURN(convertvol)
     ENDIF
    ENDIF
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE convertvaluetounit(curvalue,curunitcd,targetunitcd)
   DECLARE calculatedvalue = f8 WITH protect
   DECLARE formula = vc WITH protect
   DECLARE fromcki = vc WITH protect
   DECLARE targetcki = vc WITH protect
   RECORD ocf_request(
     1 to_unit_cki = vc
     1 from_unit_cki = vc
     1 to_unit_cd = f8
     1 from_unit_cd = f8
   ) WITH protect
   IF (debug_ind=1)
    CALL addlogmsg("INFO","Inside convertValueToUnit()")
    CALL addlogmsg("INFO",build("curUnitCd = ",curunitcd))
    CALL addlogmsg("INFO",build("targetUnitCd = ",targetunitcd))
   ENDIF
   SELECT INTO "nl:"
    cv.cki
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=54
      AND cv.code_value IN (curunitcd, targetunitcd))
    DETAIL
     IF (cv.code_value=curunitcd)
      fromcki = trim(cv.cki)
     ELSE
      targetcki = trim(cv.cki)
     ENDIF
    WITH nocounter
   ;end select
   IF (debug_ind=1)
    CALL addlogmsg("INFO","Inside convertValueToUnit()")
    CALL addlogmsg("INFO",build("fromCki = ",fromcki))
    CALL addlogmsg("INFO",build("targetCki = ",targetcki))
   ENDIF
   IF (fromcki > ""
    AND targetcki > "")
    SET ocf_request->from_unit_cki = fromcki
    SET ocf_request->from_unit_cd = curunitcd
    SET ocf_request->to_unit_cki = targetcki
    SET ocf_request->to_unit_cd = targetunitcd
    SET stat = tdbexecute(1000300,1000300,1000300,"REC",ocf_request,
     "REC",ocf_reply)
    IF (stat=0)
     IF (debug_ind=1)
      CALL addlogmsg("INFO",build("ocf_reply->formula = ",ocf_reply->formula))
     ENDIF
     IF ((ocf_reply->formula != ""))
      SET formula = build2(ocf_reply->formula," ",curvalue)
      SET calculatedvalue = parser(formula)
      IF (debug_ind=1)
       CALL addlogmsg("INFO",build("calculatedValue = ",calculatedvalue))
      ENDIF
      RETURN(calculatedvalue)
     ELSE
      RETURN(cnvtreal(cannot_convert_unit))
     ENDIF
    ELSE
     SET status = "F"
     SET statusstr = "Error calling omf_get_formula"
     GO TO exit_script
     RETURN(0)
    ENDIF
   ELSE
    RETURN(cnvtreal(unit_ckis_not_found))
   ENDIF
 END ;Subroutine
 SUBROUTINE usestrengthorvolume(searchmode,searchid)
   DECLARE idx = i4 WITH protect
   DECLARE itempos = i4 WITH protect
   DECLARE strind = i2 WITH protect
   DECLARE strunitind = i2 WITH protect
   DECLARE volind = i2 WITH protect
   DECLARE volunitind = i2 WITH protect
   IF (debug_ind=1)
    CALL addlogmsg("INFO",build("Inside useStrengthOrVolume(), mode = ",searchmode))
   ENDIF
   IF (searchmode=item_mode)
    SET itempos = locateval(idx,1,size(item_info->list,5),searchid,item_info->list[idx].item_id)
    IF (itempos > 0
     AND programmode != single_sent_mode)
     IF ((item_info->list[itempos].str > 0.0))
      SET strind = 1
     ENDIF
     IF ((item_info->list[itempos].strunitcd > 0.0))
      SET strunitind = 1
     ENDIF
     IF ((item_info->list[itempos].vol > 0.0))
      SET volind = 1
     ENDIF
     IF ((item_info->list[itempos].volunitcd > 0.0))
      SET volunitind = 1
     ENDIF
    ELSE
     SELECT INTO "nl:"
      md.strength, md.strength_unit_cd, md.volume,
      md.volume_unit_cd
      FROM med_dispense md
      PLAN (md
       WHERE md.item_id=searchid
        AND md.pharmacy_type_cd=inpatient_type_cd)
      DETAIL
       IF (itempos > 0)
        itempos = itempos
       ELSE
        itempos = (size(item_info->list,5)+ 1), stat = alterlist(item_info->list,itempos)
       ENDIF
       item_info->list[itempos].item_id = md.item_id, item_info->list[itempos].str = md.strength,
       item_info->list[itempos].strunitcd = md.strength_unit_cd,
       item_info->list[itempos].vol = md.volume, item_info->list[itempos].volunitcd = md
       .volume_unit_cd
       IF (md.strength > 0.0)
        strind = 1
       ENDIF
       IF (md.strength_unit_cd > 0.0)
        strunitind = 1
       ENDIF
       IF (md.volume > 0.0)
        volind = 1
       ENDIF
       IF (md.volume_unit_cd > 0.0)
        volunitind = 1
       ENDIF
      WITH nocounter
     ;end select
    ENDIF
    IF (debug_ind=1)
     CALL addlogmsg("INFO","item_info record after being loaded in useStrengthOrVolume():")
     CALL echorecord(item_info,logfilename,1)
    ENDIF
    IF (strind=1
     AND strunitind=1
     AND volind=1
     AND volunitind=1)
     RETURN(strength_and_volume_are_valid)
    ELSEIF (strind=1
     AND strunitind=1)
     RETURN(only_strength_is_valid)
    ELSEIF (volind=1
     AND volunitind=1)
     RETURN(only_volume_is_valid)
    ELSE
     RETURN(strength_and_volume_are_invalid)
    ENDIF
   ELSEIF (searchmode=ingredient_mode)
    IF ((ord_sents->list[searchid].strength > 0.0))
     SET strind = 1
    ENDIF
    IF ((ord_sents->list[searchid].strength_unit_cd > 0.0))
     SET strunitind = 1
    ENDIF
    IF ((ord_sents->list[searchid].volume > 0.0))
     SET volind = 1
    ENDIF
    IF ((ord_sents->list[searchid].volume_unit_cd > 0.0))
     SET volunitind = 1
    ENDIF
    IF (strind=1
     AND strunitind=1
     AND volind=1
     AND volunitind=1)
     RETURN(strength_and_volume_are_valid)
    ELSEIF (strind=1
     AND strunitind=1)
     RETURN(only_strength_is_valid)
    ELSEIF (volind=1
     AND volunitind=1)
     RETURN(only_volume_is_valid)
    ELSE
     RETURN(strength_and_volume_are_invalid)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE setverificationreportlevel(reportlevel)
   DECLARE numofinstances = i4 WITH protect
   DECLARE servercnt = i4 WITH protect
   DECLARE verificationreportlevel = i4 WITH protect
   DECLARE pos = i4 WITH protect
   RECORD scp_req(
     1 request_type = vc
     1 nodename = vc
     1 rowset[*]
       2 serverid = i4
       2 entryid = i4
       2 serverdescrip = vc
       2 serverpath = vc
       2 serverparam = vc
       2 restartpolicy = c1
       2 numinstances = i4
       2 proplist[*]
         3 propname = vc
         3 propvalue = vc
   ) WITH protect
   RECORD scp_instances(
     1 list[*]
       2 serverid = i4
   ) WITH protect
   CALL clearscreen(null)
   CALL text(soffrow,soffcol,build2("Setting verificationreportlevel=",trim(cnvtstring(reportlevel)),
     " and cycling 112 server..."))
   SET scp_req->nodename = curnode
   SET scp_req->request_type = "QUERY_ENTRY"
   SET stat = alterlist(scp_req->rowset,1)
   SET scp_req->rowset[1].entryid = 112
   EXECUTE oensit_scp_functions  WITH replace("REQUEST",scp_req), replace("REPLY",scp_reply)
   IF ((scp_reply->status_data.status != "S"))
    SET status = "F"
    SET statusstr = "Error querying 112 server entry. "
    SET statusstr = build2(statusstr,scp_reply->status_data.subeventstatus[1].targetobjectvalue)
    RETURN(0)
   ENDIF
   SET numofinstances = scp_reply->rowset[1].numinstances
   SET pos = locateval(i,1,size(scp_reply->rowset[1].proplist,5),"VERIFICATIONREPORTLEVEL",cnvtupper(
     scp_reply->rowset[1].proplist[i].propname))
   IF (pos > 0)
    SET verificationreportlevel = cnvtint(scp_reply->rowset[1].proplist[pos].propvalue)
   ELSE
    SET verificationreportlevel = 1
   ENDIF
   IF (verificationreportlevel != reportlevel)
    SET stat = initrec(scp_req)
    SET scp_req->request_type = "MODIFY_ENTRY_PROP"
    SET scp_req->nodename = curnode
    SET stat = alterlist(scp_req->rowset,1)
    SET scp_req->rowset[1].entryid = 112
    SET stat = alterlist(scp_req->rowset[1].proplist,1)
    SET scp_req->rowset[1].proplist[1].propname = "verificationreportlevel"
    SET scp_req->rowset[1].proplist[1].propvalue = trim(cnvtstring(reportlevel))
    EXECUTE oensit_scp_functions  WITH replace("REQUEST",scp_req), replace("REPLY",scp_reply)
    IF ((scp_reply->status_data.status != "S"))
     SET status = "F"
     SET statusstr = "Error setting verificationreportlevel. "
     SET statusstr = build2(statusstr,scp_reply->status_data.subeventstatus[1].targetobjectvalue)
     RETURN(0)
    ENDIF
    SET stat = initrec(scp_req)
    SET scp_req->request_type = "FETCH_SERVER"
    SET scp_req->nodename = curnode
    EXECUTE oensit_scp_functions  WITH replace("REQUEST",scp_req), replace("REPLY",scp_reply)
    IF ((scp_reply->status_data.status != "S"))
     SET status = "F"
     SET statusstr = "Error fetching all running servers on node. "
     SET statusstr = build2(statusstr,scp_reply->status_data.subeventstatus[1].targetobjectvalue)
     RETURN(0)
    ENDIF
    FOR (i = 1 TO size(scp_reply->rowset,5))
      IF ((scp_reply->rowset[i].entryid=112))
       SET servercnt = (servercnt+ 1)
       SET stat = alterlist(scp_instances->list,servercnt)
       SET scp_instances->list[servercnt].serverid = scp_reply->rowset[i].serverid
      ENDIF
    ENDFOR
    SET stat = initrec(scp_req)
    SET scp_req->request_type = "START_SERVER"
    SET scp_req->nodename = curnode
    SET stat = alterlist(scp_req->rowset,1)
    SET scp_req->rowset[1].entryid = 112
    FOR (i = 1 TO numofinstances)
     EXECUTE oensit_scp_functions  WITH replace("REQUEST",scp_req), replace("REPLY",scp_reply)
     IF ((scp_reply->status_data.status != "S"))
      SET status = "F"
      SET statusstr = "Error starting 112 server. "
      SET statusstr = build2(statusstr,scp_reply->status_data.subeventstatus[1].targetobjectvalue)
      RETURN(0)
     ENDIF
    ENDFOR
    CALL pause(3)
    FOR (i = 1 TO size(scp_instances->list,5))
      SET stat = initrec(scp_req)
      SET scp_req->request_type = "STOP_SERVER"
      SET scp_req->nodename = curnode
      SET stat = alterlist(scp_req->rowset,1)
      SET scp_req->rowset[1].serverid = scp_instances->list[i].serverid
      EXECUTE oensit_scp_functions  WITH replace("REQUEST",scp_req), replace("REPLY",scp_reply)
      IF ((scp_reply->status_data.status != "S"))
       SET status = "F"
       SET statusstr = "Error stopping 112 server. "
       SET statusstr = build2(statusstr,scp_reply->status_data.subeventstatus[1].targetobjectvalue)
       RETURN(0)
      ENDIF
    ENDFOR
    CALL clear(soffrow,soffcol,numcols)
    RETURN(1)
   ELSE
    CALL clear(soffrow,soffcol,numcols)
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE incrementerrorcnt(progname,inccnt,infodetail)
   DECLARE retval = i2 WITH noconstant(0), protect
   DECLARE found = i2 WITH noconstant(0), protect
   DECLARE infonbr = i4 WITH protect
   DECLARE lastupdt = dq8 WITH protect
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="AMS_TOOLKIT"
     AND d.info_name=progname
    DETAIL
     found = 1, infonbr = (d.info_number+ inccnt), lastupdt = d.updt_dt_tm
    WITH nocounter
   ;end select
   IF (found=0)
    INSERT  FROM dm_info d
     SET d.info_domain = "AMS_TOOLKIT", d.info_name = progname, d.info_date = cnvtdatetime(curdate,
       curtime3),
      d.info_number = inccnt, d.info_char = trim(infodetail), d.updt_dt_tm = cnvtdatetime(curdate,
       curtime3),
      d.updt_cnt = 0, d.updt_id = reqinfo->updt_id, d.updt_task = - (267)
     WITH nocounter
    ;end insert
    IF (curqual=1)
     SET retval = 1
    ENDIF
   ELSE
    IF (datetimediff(cnvtdatetime(curdate,curtime3),lastupdt,3) > 23)
     UPDATE  FROM dm_info d
      SET d.info_number = infonbr, d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_cnt = (d
       .updt_cnt+ 1),
       d.updt_id = reqinfo->updt_id, d.updt_task = - (267)
      WHERE d.info_domain="AMS_TOOLKIT"
       AND d.info_name=progname
      WITH nocounter
     ;end update
     IF (curqual=1)
      SET retval = 1
     ENDIF
    ELSE
     SET retval = 1
    ENDIF
   ENDIF
   RETURN(retval)
 END ;Subroutine
 SUBROUTINE geterrorcnt(progname)
   DECLARE retval = f8 WITH protect
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="AMS_TOOLKIT"
     AND d.info_name=progname
    DETAIL
     retval = d.info_number
    WITH nocounter
   ;end select
   RETURN(retval)
 END ;Subroutine
 SUBROUTINE deleteerrorcnt(progname)
   DECLARE retval = i4 WITH protect
   DELETE  FROM dm_info d
    WHERE d.info_domain="AMS_TOOLKIT"
     AND d.info_name=patstring(progname)
    WITH nocounter
   ;end delete
   SET retval = curqual
   RETURN(retval)
 END ;Subroutine
#exit_script
 CALL setverificationreportlevel(1)
 CALL clear(1,1)
 SET message = nowindow
 IF (status="F")
  CALL echo(statusstr)
 ENDIF
 IF (debug_ind=1)
  CALL createlogfile(logfilename)
 ENDIF
 SET last_mod = "001"
END GO
