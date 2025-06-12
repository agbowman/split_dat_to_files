CREATE PROGRAM de_importer:dba
 DECLARE modversion = vc WITH constant("0.0.3")
 EXECUTE cclseclogin
 IF (validate(xxcclseclogin)=1)
  IF ((xxcclseclogin->loggedin=0))
   CALL text(7,15,"Must login to use this program! Press enter to exit:")
   CALL accept(8,15,"A;CU","")
   GO TO end_of_program
  ENDIF
 ENDIF
 SET message = noinformation
 DECLARE check_import_record(x) = c1
 DECLARE format_csv_output(x) = c1
 DECLARE client_format_csv_output(x) = c1
 DECLARE clear_import_vars(x) = c1
 DECLARE add_legacy_interface(x) = c1
 DECLARE import_oen_scripts(x) = c1
 DECLARE get_organization_id(x) = f8
 DECLARE get_logical_domain_id(current_users_ld=f8) = f8
 DECLARE gather_adt_request_info(x) = f8
 DECLARE gather_adt_request_info_by_alias_pool_cd(x) = f8
 DECLARE uar_si_decode_base64(p1=vc(ref),p2=i4(ref),p3=vc(ref),p4=i4(ref),p5=i4(ref)) = i4
 DECLARE set_resonance_xds_csv(x) = vc
 DECLARE add_org_defaults(x) = c1
 DECLARE display_org_defaults_status(x) = c1
 DECLARE start_device_contributor_system_relationships(x) = c1
 DECLARE import_res_adt_interface(x) = c1
 DECLARE add_system_org_reltn(x) = c1
 DECLARE trigger_patient_adt(x) = c1
 DECLARE trigger_patient_query(x) = c1
 DECLARE trigger_patient_provide(x) = c1
 DECLARE write_resonance_cert_keystore(x) = c1
 DECLARE get_client_mnemonic(x) = vc
 DECLARE write_resonance_prod_keystore(x) = c1
 DECLARE import_hub_resonance_mod_obj_script(x) = vc
 DECLARE import_res_util_interface(x) = c1
 DECLARE import_hub_resonance_utility_mod_obj_script(x) = vc
 DECLARE set_resonance_xds_cs_12025_snomedct_out(x) = vc
 DECLARE set_resonance_xds_cs_12030_out(x) = vc
 DECLARE char_cr = vc WITH constant(char(13))
 DECLARE char_lf = vc WITH constant(char(10))
 DECLARE inbound_alias_txt = vc WITH constant("IN")
 DECLARE outbound_alias_txt = vc WITH constant("OUT")
 DECLARE both_alias_txt = vc WITH constant("BOTH")
 DECLARE contributor_source_code_set = i4 WITH constant(73)
 DECLARE max_alias_size = i4 WITH constant(255)
 DECLARE max_alias_type_meaning_size = i4 WITH constant(12)
 DECLARE skip_insert = i2 WITH constant(0)
 DECLARE perform_insert = i2 WITH constant(1)
 DECLARE active_ind_active = i2 WITH constant(1)
 DECLARE alias_import_cust_ind = i4 WITH constant(0)
 DECLARE alias_import_res_xds_ind = i4 WITH constant(2)
 DECLARE max_status = i4 WITH constant(12)
 DECLARE unknown_error = i4 WITH constant(- (1))
 DECLARE in_process = i4 WITH constant(0)
 DECLARE successful = i4 WITH constant(1)
 DECLARE code_set_error = i4 WITH constant(2)
 DECLARE contrib_src_error = i4 WITH constant(3)
 DECLARE cv_display_key_error = i4 WITH constant(4)
 DECLARE missing_alias_error = i4 WITH constant(5)
 DECLARE alias_length_error = i4 WITH constant(6)
 DECLARE a_t_m_length_error = i4 WITH constant(7)
 DECLARE alias_direction_error = i4 WITH constant(8)
 DECLARE alias_exists = i4 WITH constant(9)
 DECLARE dup_outbound_alias_error = i4 WITH constant(10)
 DECLARE cv_mult_display_key_error = i4 WITH constant(11)
 DECLARE cv_inactive_error = i4 WITH constant(12)
 DECLARE cv_match_not_found = i4 WITH constant(0)
 DECLARE cv_match_display_key = i4 WITH constant(1)
 DECLARE cv_match_description = i4 WITH constant(2)
 DECLARE cv_match_cdf_meaning = i4 WITH constant(3)
 DECLARE no_cdf_meaning_txt = vc WITH constant("NOCDFMEANING")
 DECLARE mm_manuf_cdf_meaning_txt = vc WITH constant("MM_MANUF")
 DECLARE get_custom_csv_txt = vc WITH constant(
  "Enter the CSV File Name with the Aliases to be imported (lowercase only):")
 DECLARE csvfilename = vc WITH noconstant("")
 DECLARE csvfiletxt = vc WITH noconstant("")
 DECLARE csvrowtxt = vc WITH noconstant("")
 DECLARE csvrownum = i4 WITH noconstant(2)
 DECLARE doneparsing = i2 WITH noconstant(0)
 DECLARE import_alias_rec_size = i4 WITH noconstant(0)
 DECLARE outputcsvfilename = vc WITH noconstant("")
 DECLARE outputcsv = vc WITH noconstant("")
 DECLARE clientoutputcsv = vc WITH noconstant("")
 DECLARE updt_task_id = i4 WITH constant(99100115)
 DECLARE updt_applctx_id = i4 WITH constant(99100115)
 DECLARE status = i2 WITH noconstant(1)
 DECLARE dcl_cmd = vc WITH noconstant("")
 DECLARE logicaldomainid = f8 WITH noconstant(0)
 DECLARE currentuserld = f8
 SET currentuserld = get_user_logical_domain(reqinfo->updt_id)
 DECLARE currentuseremail = vc WITH noconstant("")
 DECLARE currentdomain = vc WITH constant(cnvtlower(curdomain))
 FREE RECORD import_alias_rec
 RECORD import_alias_rec(
   1 importstatus[*]
     2 code_set = vc
     2 code_set_display = vc
     2 contributor_source_display_key = vc
     2 cv_display_key = vc
     2 alias = vc
     2 alias_type_meaning = vc
     2 alias_direction = vc
     2 contributor_source_cd = f8
     2 code_value = f8
     2 cdf_meaning = vc
     2 code_value_matched_by = i4
     2 status = i4
 )
 DECLARE communitycontributorsystemdef = vc WITH noconstant("")
 SET communitycontributorsystemdef = get_res_contributor_system_display(currentuserld)
 DECLARE resonance_xds_default_src = vc WITH noconstant("")
 SET resonance_xds_default_src = get_contrib_src_display_by_contrib_sys_display(
  communitycontributorsystemdef)
 DECLARE resonance_xds_src = vc WITH noconstant("")
 DECLARE get_resonance_xds_txt = vc WITH constant(
  "Enter the name of the Resonance XDS Contributor Source:")
 DECLARE ressystemorgtype = i2 WITH constant(1)
 DECLARE ihe_src_key_txt = vc WITH constant("IHE")
 DECLARE nucc_src_key_txt = vc WITH constant("NUCC")
 SET modify maxvarlen 52428800
#new_res_xds_csv_menu
 CALL clear(1,1)
 CALL box(4,1,24,78)
 CALL text(3,2,"New Resonance XDS",w)
 CALL text(5,5,"1)Import Aliases")
 CALL text(7,5,"2)Resonance Implementation Automation")
 CALL text(9,5,"3)CommonWell Auto-Enrollment Implementation Automation")
 CALL text(11,5,"4)Export Resonance and Commonwell Truststore/Keystore/Certs")
 CALL text(17,5,"7)Resonance Support")
 CALL text(19,5,"8)Export Resonance Scripts")
 CALL text(21,5,"9)Exit")
 CALL text(23,2,"Selection")
 CALL accept(23,12,"9;",9)
 CASE (curaccept)
  OF 1:
   GO TO new_res_xds_import_aliases_menu
  OF 2:
   GO TO new_res_xds_res_imp_auto_menu
  OF 3:
   GO TO new_res_xds_cw_imp_auto_menu
  OF 4:
   GO TO new_res_xds_import_res_cw_certs_menu
  OF 7:
   GO TO new_res_xds_res_support_menu
  OF 8:
   GO TO new_res_xds_import_res_scripts_menu
  OF 9:
   GO TO end_of_program
 ENDCASE
 GO TO new_res_xds_csv_menu
#new_res_xds_import_aliases_menu
 CALL clear(1,1)
 CALL box(4,1,24,78)
 CALL text(3,2,"Import Aliases",w)
 CALL text(5,5,"1)Audit Aliases")
 CALL text(7,5,"2)Import Aliases (Aliases will be committed to the Database)")
 CALL text(21,5,"9)Return to the previous menu")
 CALL text(23,2,"Selection")
 CALL accept(23,12,"9;",9)
 CASE (curaccept)
  OF 1:
   CALL start_alias_import(alias_import_res_xds_ind,skip_insert)
  OF 2:
   CALL start_alias_import(alias_import_res_xds_ind,perform_insert)
  OF 9:
   GO TO new_res_xds_csv_menu
 ENDCASE
 GO TO new_res_xds_import_aliases_menu
#new_res_xds_res_imp_auto_menu
 CALL clear(1,1)
 CALL box(4,1,24,78)
 CALL text(3,2,"Resonance Implementation Automation",w)
 CALL text(5,5,"1)Import Legacy ADT Interface")
 CALL text(7,5,"2)Add Org Defaults")
 CALL text(9,5,"3)Add System/Organization/Alias Pool Relationships")
 CALL text(11,5,"4)Update existing Org Defaults with Default Event_CD")
 CALL text(13,5,"5)Copy PDF Config to Other Orgs (WARNING beta)")
 CALL text(21,5,"9)Return to the previous menu")
 CALL text(23,2,"Selection")
 CALL accept(23,12,"9;",9)
 CASE (curaccept)
  OF 1:
   CALL import_res_adt_interface(1)
  OF 2:
   CALL begin_org_defaults(currentuserld)
  OF 3:
   CALL begin_add_system_org_reltn(currentuserld,ressystemorgtype)
  OF 4:
   CALL update_org_defaults_default_event_cd(currentuserld)
  OF 5:
   CALL start_device_contributor_system_relationships(1)
  OF 9:
   GO TO new_res_xds_csv_menu
 ENDCASE
 GO TO new_res_xds_res_imp_auto_menu
#new_res_xds_cw_imp_auto_menu
 CALL clear(1,1)
 CALL box(4,1,24,78)
 CALL text(3,2,"CommonWell Auto-Enrollment Implementation Automation",w)
 CALL text(5,5,"1)Import Resonance Utility")
 CALL text(21,5,"9)Return to the previous menu")
 CALL text(23,2,"Selection")
 CALL accept(23,12,"9;",9)
 CASE (curaccept)
  OF 1:
   CALL import_res_util_interface(1)
  OF 9:
   GO TO new_res_xds_csv_menu
 ENDCASE
 GO TO new_res_xds_cw_imp_auto_menu
#new_res_xds_import_res_cw_certs_menu
 CALL clear(1,1)
 CALL box(4,1,24,78)
 CALL text(3,2,"Export Res/CW Truststore/Keystore/Certs",w)
 CALL text(5,5,"1)Non-Prod")
 CALL text(7,5,"2)Prod")
 CALL text(21,5,"9)Return to the previous menu")
 CALL text(23,2,"Selection")
 CALL accept(23,12,"9;",9)
 CASE (curaccept)
  OF 1:
   GO TO new_res_xds_res_cw_non_prod_certs_menu
  OF 2:
   GO TO new_res_xds_res_cw_prod_certs_menu
  OF 9:
   GO TO new_res_xds_csv_menu
 ENDCASE
 GO TO new_res_xds_import_res_cw_certs_menu
#new_res_xds_res_support_menu
 CALL clear(1,1)
 CALL box(4,1,24,78)
 CALL text(3,2,"Resonance Support",w)
 CALL text(5,5,"1)Trigger Single ADT")
 CALL text(7,5,"2)Trigger Query")
 CALL text(9,5,"3)Trigger Provide (CONSENT NOT CHECKED)")
 CALL text(11,5,"4)Trigger Historical ADTs")
 CALL text(13,5,"5)Trigger Historical ADTs by Alias_Pool_Cd")
 CALL text(15,5,"6)Get estimated volume for Doc Queries, Provides, and ADTs")
 CALL text(21,5,"9)Return to the previous menu")
 CALL text(23,2,"Selection")
 CALL accept(23,12,"9;",9)
 CASE (curaccept)
  OF 1:
   CALL trigger_patient_adt(1)
  OF 2:
   CALL trigger_patient_query(1)
  OF 3:
   CALL trigger_patient_provide(1)
  OF 4:
   CALL gather_adt_request_info(1)
  OF 5:
   CALL gather_adt_request_info_by_alias_pool_cd(1)
  OF 6:
   CALL estimated_resonance_report(currentuserld)
  OF 9:
   GO TO new_res_xds_csv_menu
 ENDCASE
 GO TO new_res_xds_res_support_menu
#new_res_xds_import_res_scripts_menu
 CALL clear(1,1)
 CALL box(4,1,24,78)
 CALL text(3,2,"Export Resonance Scripts",w)
 CALL text(5,5,"1)Include latest XDS_MOD_OBJ")
 CALL text(7,5,"2)Include latest resonance_utility_mod_obj")
 CALL text(21,5,"9)Return to the previous menu")
 CALL text(23,2,"Selection")
 CALL accept(23,12,"9;",9)
 CASE (curaccept)
  OF 1:
   CALL import_hub_resonance_mod_obj_script(1)
  OF 2:
   CALL import_hub_resonance_utility_mod_obj_script(1)
  OF 9:
   GO TO new_res_xds_csv_menu
 ENDCASE
 GO TO new_res_xds_import_res_scripts_menu
#new_res_xds_res_cw_non_prod_certs_menu
 CALL clear(1,1)
 CALL box(4,1,24,78)
 CALL text(3,2,"Non-Prod Certificates",w)
 CALL text(5,5,"1)Export Resonance Keystore to backend")
 CALL text(21,5,"9)Return to the previous menu")
 CALL text(23,2,"Selection")
 CALL accept(23,12,"9;",9)
 CASE (curaccept)
  OF 1:
   CALL write_resonance_cert_keystore(null)
  OF 9:
   GO TO new_res_xds_import_res_cw_certs_menu
 ENDCASE
 GO TO new_res_xds_res_cw_non_prod_certs_menu
#new_res_xds_res_cw_prod_certs_menu
 CALL clear(1,1)
 CALL box(4,1,24,78)
 CALL text(3,2,"Prod Truststore/Keystore/Certs",w)
 CALL text(5,5,"1)Export Resonance Keystore to backend")
 CALL text(21,5,"9)Return to the previous menu")
 CALL text(23,2,"Selection")
 CALL accept(23,12,"9;",9)
 CASE (curaccept)
  OF 1:
   CALL write_resonance_prod_keystore(null)
  OF 9:
   GO TO new_res_xds_import_res_cw_certs_menu
 ENDCASE
 GO TO new_res_xds_res_cw_prod_certs_menu
#end_of_program
 CALL clear(1,1)
 SUBROUTINE (start_alias_import(import_type=i4,import_ind=i2) =c1)
   DECLARE send_alias_email_txt = vc WITH constant("Email alias audit reports?")
   DECLARE importindtxt = vc WITH noconstant("")
   DECLARE emailsubject = vc WITH noconstant("")
   DECLARE emailsubjectstandard = vc WITH noconstant("")
   DECLARE emailsubjectclient = vc WITH noconstant("")
   CALL clear_import_vars(1)
   IF (import_type=0)
    SET csvfilename = cnvtlower(get_file_name(get_custom_csv_txt,""))
    SET outputcsvfilename = concat("import_audit_",csvfilename)
    SET csvfiletxt = read_file(csvfilename)
   ELSEIF (import_type=2)
    SET resonance_xds_src = get_file_name(get_resonance_xds_txt,resonance_xds_default_src)
    SET csvfilename = "resonance_xds_csv.csv"
    SET outputcsvfilename = concat("import_audit_",csvfilename)
    SET csvfiletxt = set_resonance_xds_csv(1)
    SET csvfiletxt = build2(csvfiletxt,set_resonance_xds_cs_4_out(resonance_xds_src))
    SET csvfiletxt = build2(csvfiletxt,set_resonance_xds_cs_15_out(resonance_xds_src))
    SET csvfiletxt = build2(csvfiletxt,set_resonance_xds_cs_27_out(resonance_xds_src))
    SET csvfiletxt = build2(csvfiletxt,set_resonance_xds_cs_43_out(resonance_xds_src))
    SET csvfiletxt = build2(csvfiletxt,set_resonance_xds_cs_57_out(resonance_xds_src))
    SET csvfiletxt = build2(csvfiletxt,get_display_to_alias(resonance_xds_src,62,outbound_alias_txt))
    SET csvfiletxt = build2(csvfiletxt,get_display_to_alias(resonance_xds_src,74,outbound_alias_txt))
    SET csvfiletxt = build2(csvfiletxt,get_display_to_alias(resonance_xds_src,89,outbound_alias_txt))
    SET csvfiletxt = build2(csvfiletxt,set_resonance_xds_cs_212_out(resonance_xds_src))
    SET csvfiletxt = build2(csvfiletxt,set_resonance_xds_cs_213_out(resonance_xds_src))
    SET csvfiletxt = build2(csvfiletxt,get_display_to_alias(resonance_xds_src,263,outbound_alias_txt)
     )
    SET csvfiletxt = build2(csvfiletxt,set_resonance_xds_cs_278_out(resonance_xds_src))
    SET csvfiletxt = build2(csvfiletxt,set_resonance_xds_cs_278_nucc_out(nucc_src_key_txt))
    SET csvfiletxt = build2(csvfiletxt,set_resonance_xds_cs_282_out(resonance_xds_src))
    SET csvfiletxt = build2(csvfiletxt,get_display_to_alias(resonance_xds_src,319,outbound_alias_txt)
     )
    SET csvfiletxt = build2(csvfiletxt,set_resonance_xds_cs_4002390_out(ihe_src_key_txt))
    SET csvfiletxt = build2(csvfiletxt,set_resonance_xds_cs_12025_snomedct_out(1))
    SET csvfiletxt = build2(csvfiletxt,set_resonance_xds_cs_12030_out(1))
    SET csvfiletxt = build2(csvfiletxt,set_resonance_xds_cs_4002390_in(ihe_src_key_txt))
   ELSE
    CALL clear(1,1)
    CALL text(7,15,"import_type wasn't set! Press enter to exit!:")
    CALL accept(8,15,"#;;CU","")
    GO TO new_res_xds_import_aliases_menu
   ENDIF
   SET message no window
   IF (size(trim(csvfiletxt)) >= 1)
    CALL clear(1,1)
    CALL read_csv(csvfiletxt)
    CALL check_import_record(1)
    CALL import_aliases(import_ind)
    SET outputcsv = format_csv_output(1)
    CALL write_file(build(outputcsvfilename),outputcsv,"wb")
    SET clientoutputcsvfilename = concat("client_",outputcsvfilename)
    SET clientoutputcsv = client_format_csv_output(1)
    CALL write_file(build(clientoutputcsvfilename),clientoutputcsv,"wb")
    SET currentuseremail = get_email_address(send_alias_email_txt)
    IF (import_ind=1)
     SET importindtxt = "IMPORT"
    ELSE
     SET importindtxt = "AUDIT"
    ENDIF
    SET emailsubjectstandard = build2("Standard Audit for ",currentdomain," ",format(cnvtdatetime(
       curdate,curtime),"MM/DD/YYYY HH:MM:SS ;;Q")," MODE: ",
     importindtxt)
    SET emailsubjectclient = build2("Client Audit for ",currentdomain," ",format(cnvtdatetime(curdate,
       curtime),"MM/DD/YYYY HH:MM:SS ;;Q")," MODE: ",
     importindtxt)
    IF (currentuseremail != "0")
     IF (cursys2="AIX")
      SET dcl_cmd = concat(build2("uuencode ",outputcsvfilename," ",outputcsvfilename," |mail ",
        currentuseremail))
      CALL dcl(dcl_cmd,size(trim(dcl_cmd)),status)
      SET dcl_cmd = concat(build2("uuencode ",clientoutputcsvfilename," ",clientoutputcsvfilename,
        " |mail ",
        currentuseremail))
      CALL dcl(dcl_cmd,size(trim(dcl_cmd)),status)
     ELSEIF (cursys2="LNX")
      SET dcl_cmd = concat(build2("uuencode ",outputcsvfilename," ",outputcsvfilename," |mail ",
        currentuseremail,' -s "',emailsubjectstandard,'"'))
      CALL dcl(dcl_cmd,size(trim(dcl_cmd)),status)
      SET dcl_cmd = concat(build2("uuencode ",clientoutputcsvfilename," ",clientoutputcsvfilename,
        " |mail ",
        currentuseremail,' -s "',emailsubjectclient,'"'))
      CALL dcl(dcl_cmd,size(trim(dcl_cmd)),status)
     ELSEIF (cursys2="HPX")
      SET dcl_cmd = concat(build2("uuencode ",outputcsvfilename," ",outputcsvfilename,
        ' |mail -m -s "',
        emailsubjectstandard,'" ',currentuseremail))
      CALL dcl(dcl_cmd,size(trim(dcl_cmd)),status)
      SET dcl_cmd = concat(build2("uuencode ",clientoutputcsvfilename," ",clientoutputcsvfilename,
        ' |mail -m -s "',
        emailsubjectclient,'" ',currentuseremail))
      CALL dcl(dcl_cmd,size(trim(dcl_cmd)),status)
     ELSE
      CALL uar_send_mail(nullterm(currentuseremail),nullterm(emailsubject),nullterm(build2(outputcsv,
         char(10))),nullterm("clinical_hub_alias_importer"),5,
       nullterm("IPM.NOTE"))
      CALL uar_send_mail(nullterm(currentuseremail),nullterm(emailsubject),nullterm(build2(
         clientoutputcsv,char(10))),nullterm("clinical_hub_alias_importer"),5,
       nullterm("IPM.NOTE"))
     ENDIF
     IF (status != 1
      AND ((cursys2="LNX") OR (status != 0
      AND ((cursys2="AIX") OR (status != 1
      AND cursys2="HPX")) )) )
      CALL uar_send_mail(nullterm(currentuseremail),nullterm(emailsubject),nullterm(build2(outputcsv,
         char(10))),nullterm("clinical_hub_alias_importer"),5,
       nullterm("IPM.NOTE"))
      CALL uar_send_mail(nullterm(currentuseremail),nullterm(emailsubject),nullterm(build2(
         clientoutputcsv,char(10))),nullterm("clinical_hub_alias_importer"),5,
       nullterm("IPM.NOTE"))
     ENDIF
    ENDIF
    CALL clear(1,1)
    CALL text(7,15,"Import completed! Please review the audit file:")
    CALL text(8,15,build("Standard Audit: ",logical("CCLUSERDIR"),"/",outputcsvfilename))
    CALL text(9,15,build("  Client Audit: ",logical("CCLUSERDIR"),"/",clientoutputcsvfilename))
    CALL text(11,15,"Press enter to exit:")
    CALL accept(12,15,"#;;CU","")
   ELSE
    CALL clear(1,1)
    CALL text(7,15,"CSV wasn't found or didn't contain any data. Press enter to exit!:")
    CALL accept(8,15,"#;;CU","")
    GO TO new_res_xds_import_aliases_menu
   ENDIF
 END ;Subroutine
 SUBROUTINE (read_file(file_name=vc) =vc)
   RECORD frec(
     1 file_desc = i4
     1 file_name = vc
     1 file_buf = vc
     1 file_dir = i4
     1 file_offset = i4
   )
   DECLARE file_contents = vc
   DECLARE len = i4
   SET frec->file_name = build2(file_name)
   SET frec->file_buf = "r"
   SET stat = cclio("OPEN",frec)
   SET frec->file_dir = 2
   SET stat = cclio("SEEK",frec)
   SET len = cclio("TELL",frec)
   SET frec->file_dir = 0
   SET stat = cclio("SEEK",frec)
   SET stat = memrealloc(file_contents,1,build("C",len))
   SET frec->file_buf = notrim(file_contents)
   SET stat = cclio("READ",frec)
   SET stat = cclio("CLOSE",frec)
   RETURN(frec->file_buf)
 END ;Subroutine
 SUBROUTINE (read_csv(input_csv=vc) =c1)
   WHILE (doneparsing=0)
     SET csvrowtxt = trim(piece(input_csv,char_cr,csvrownum,"Not Found"),3)
     SET csvrownum += 1
     CALL parse_csv_row(csvrowtxt)
     IF (csvrowtxt="Not Found")
      SET doneparsing = 1
     ENDIF
   ENDWHILE
 END ;Subroutine
 SUBROUTINE (parse_csv_row(csv_row_txt=vc) =c1)
   IF (piece(csv_row_txt,",",1,"",3) != "Not Found")
    SET import_alias_rec_size += 1
    SET stat = alterlist(import_alias_rec->importstatus,import_alias_rec_size)
    SET import_alias_rec->importstatus[import_alias_rec_size].code_set = piece(csv_row_txt,",",1,"",3
     )
    SET import_alias_rec->importstatus[import_alias_rec_size].contributor_source_display_key =
    cnvtupper(cnvtalphanum(piece(csv_row_txt,",",2,"",3)))
    SET import_alias_rec->importstatus[import_alias_rec_size].cv_display_key = cnvtupper(cnvtalphanum
     (piece(csv_row_txt,",",3,"",3)))
    SET import_alias_rec->importstatus[import_alias_rec_size].cdf_meaning = cnvtupper(piece(
      csv_row_txt,",",4,"",3))
    IF (size(trim(import_alias_rec->importstatus[import_alias_rec_size].cdf_meaning)) <= 0)
     SET import_alias_rec->importstatus[import_alias_rec_size].cdf_meaning = " "
    ENDIF
    SET import_alias_rec->importstatus[import_alias_rec_size].alias = piece(csv_row_txt,",",5,"",3)
    IF (findstring("\0",import_alias_rec->importstatus[import_alias_rec_size].alias)=1)
     SET import_alias_rec->importstatus[import_alias_rec_size].alias = replace(import_alias_rec->
      importstatus[import_alias_rec_size].alias,"\0","0",1)
    ENDIF
    SET import_alias_rec->importstatus[import_alias_rec_size].alias_type_meaning = cnvtupper(piece(
      csv_row_txt,",",6,"",3))
    IF (findstring("\0",import_alias_rec->importstatus[import_alias_rec_size].alias_type_meaning)=1)
     SET import_alias_rec->importstatus[import_alias_rec_size].alias_type_meaning = replace(
      import_alias_rec->importstatus[import_alias_rec_size].alias_type_meaning,"\0","0",1)
    ENDIF
    IF (size(trim(import_alias_rec->importstatus[import_alias_rec_size].alias_type_meaning)) <= 0)
     SET import_alias_rec->importstatus[import_alias_rec_size].alias_type_meaning = " "
    ENDIF
    SET import_alias_rec->importstatus[import_alias_rec_size].status = in_process
    SET import_alias_rec->importstatus[import_alias_rec_size].code_value_matched_by =
    cv_match_not_found
    IF (cnvtupper(piece(csv_row_txt,",",7,"",3))=both_alias_txt)
     SET import_alias_rec->importstatus[import_alias_rec_size].alias_direction = inbound_alias_txt
     SET import_alias_rec_size += 1
     SET stat = alterlist(import_alias_rec->importstatus,import_alias_rec_size)
     SET import_alias_rec->importstatus[import_alias_rec_size].code_set = piece(csv_row_txt,",",1,"",
      3)
     SET import_alias_rec->importstatus[import_alias_rec_size].contributor_source_display_key =
     cnvtupper(cnvtalphanum(piece(csv_row_txt,",",2,"",3)))
     SET import_alias_rec->importstatus[import_alias_rec_size].cv_display_key = cnvtupper(
      cnvtalphanum(piece(csv_row_txt,",",3,"",3)))
     SET import_alias_rec->importstatus[import_alias_rec_size].cdf_meaning = cnvtupper(piece(
       csv_row_txt,",",4,"",3))
     IF (size(trim(import_alias_rec->importstatus[import_alias_rec_size].cdf_meaning)) <= 0)
      SET import_alias_rec->importstatus[import_alias_rec_size].cdf_meaning = " "
     ENDIF
     SET import_alias_rec->importstatus[import_alias_rec_size].alias = piece(csv_row_txt,",",5,"",3)
     IF (findstring("\0",import_alias_rec->importstatus[import_alias_rec_size].alias)=1)
      SET import_alias_rec->importstatus[import_alias_rec_size].alias = replace(import_alias_rec->
       importstatus[import_alias_rec_size].alias,"\0","0",1)
     ENDIF
     SET import_alias_rec->importstatus[import_alias_rec_size].alias_type_meaning = cnvtupper(piece(
       csv_row_txt,",",6,"",3))
     IF (findstring("\0",import_alias_rec->importstatus[import_alias_rec_size].alias_type_meaning)=1)
      SET import_alias_rec->importstatus[import_alias_rec_size].alias_type_meaning = replace(
       import_alias_rec->importstatus[import_alias_rec_size].alias_type_meaning,"\0","0",1)
     ENDIF
     IF (size(trim(import_alias_rec->importstatus[import_alias_rec_size].alias_type_meaning)) <= 0)
      SET import_alias_rec->importstatus[import_alias_rec_size].alias_type_meaning = " "
     ENDIF
     SET import_alias_rec->importstatus[import_alias_rec_size].status = in_process
     SET import_alias_rec->importstatus[import_alias_rec_size].code_value_matched_by =
     cv_match_not_found
     SET import_alias_rec->importstatus[import_alias_rec_size].alias_direction = outbound_alias_txt
    ELSE
     SET import_alias_rec->importstatus[import_alias_rec_size].alias_direction = cnvtupper(piece(
       csv_row_txt,",",7,"",3))
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE check_import_record(dummy_var)
   FOR (checkimportaliasesnum = 1 TO size(import_alias_rec->importstatus,5))
     IF ((import_alias_rec->importstatus[checkimportaliasesnum].status=in_process))
      IF ((import_alias_rec->importstatus[checkimportaliasesnum].code_set=""))
       SET import_alias_rec->importstatus[checkimportaliasesnum].status = code_set_error
      ENDIF
     ENDIF
     IF ((import_alias_rec->importstatus[checkimportaliasesnum].status=in_process))
      IF ((import_alias_rec->importstatus[checkimportaliasesnum].alias_direction=""))
       SET import_alias_rec->importstatus[checkimportaliasesnum].status = alias_direction_error
      ENDIF
     ENDIF
     IF ((import_alias_rec->importstatus[checkimportaliasesnum].status=in_process))
      IF ((import_alias_rec->importstatus[checkimportaliasesnum].alias=""))
       SET import_alias_rec->importstatus[checkimportaliasesnum].status = missing_alias_error
      ENDIF
     ENDIF
     IF ((import_alias_rec->importstatus[checkimportaliasesnum].status=in_process))
      IF ((import_alias_rec->importstatus[checkimportaliasesnum].cv_display_key=""))
       SET import_alias_rec->importstatus[checkimportaliasesnum].status = cv_display_key_error
      ENDIF
     ENDIF
     IF ((import_alias_rec->importstatus[checkimportaliasesnum].status=in_process))
      IF ((import_alias_rec->importstatus[checkimportaliasesnum].contributor_source_display_key=""))
       SET import_alias_rec->importstatus[checkimportaliasesnum].status = contrib_src_error
      ENDIF
     ENDIF
     IF ((import_alias_rec->importstatus[checkimportaliasesnum].status=in_process))
      IF (size(import_alias_rec->importstatus[checkimportaliasesnum].alias) > max_alias_size)
       SET import_alias_rec->importstatus[checkimportaliasesnum].status = alias_length_error
      ENDIF
     ENDIF
     IF ((import_alias_rec->importstatus[checkimportaliasesnum].status=in_process))
      IF (size(trim(import_alias_rec->importstatus[checkimportaliasesnum].alias_type_meaning)) >
      max_alias_type_meaning_size)
       SET import_alias_rec->importstatus[checkimportaliasesnum].status = a_t_m_length_error
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE (import_aliases(import_aliases_commit_ind=i2) =c1)
   FOR (importaliasesnum = 1 TO size(import_alias_rec->importstatus,5))
    IF (((mod(importaliasesnum,100)=0) OR (importaliasesnum=size(import_alias_rec->importstatus,5)))
    )
     CALL clear(1,1)
     SET message = nowindow
     CALL echo(build2("Importing Aliases: ",importaliasesnum," of ",cnvtreal(size(import_alias_rec->
         importstatus,5))))
     CALL echo(build2("Percent Done: ",((cnvtreal(importaliasesnum)/ cnvtreal(size(import_alias_rec->
         importstatus,5))) * 100)))
    ENDIF
    IF ((import_alias_rec->importstatus[importaliasesnum].status=in_process))
     IF ((import_alias_rec->importstatus[importaliasesnum].alias_direction=inbound_alias_txt))
      CALL import_inbound_alias(importaliasesnum,import_aliases_commit_ind)
     ELSEIF ((import_alias_rec->importstatus[importaliasesnum].alias_direction=outbound_alias_txt))
      CALL import_outbound_alias(importaliasesnum,import_aliases_commit_ind)
     ELSE
      SET import_alias_rec->importstatus[importaliasesnum].status = 8
     ENDIF
    ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE (import_aliases_check(import_alias_check=i4) =vc)
   DECLARE blank_cdf_meaning_cnt = i4 WITH noconstant(0)
   DECLARE defined_cdf_meaning_cnt = i4 WITH noconstant(0)
   DECLARE nocdfmeaning_cdf_meaning_cnt = i4 WITH noconstant(0)
   IF ((import_alias_rec->importstatus[import_alias_check].status=in_process))
    SELECT INTO "nl:"
     cv.code_value
     FROM code_value cv
     WHERE cv.code_set=contributor_source_code_set
      AND (cv.display_key=import_alias_rec->importstatus[import_alias_check].
     contributor_source_display_key)
      AND cv.active_ind=active_ind_active
     DETAIL
      import_alias_rec->importstatus[import_alias_check].contributor_source_cd = cv.code_value
     WITH counter
    ;end select
    IF ( NOT (curqual > 0))
     SET import_alias_rec->importstatus[import_alias_check].status = contrib_src_error
    ENDIF
   ENDIF
   IF ((import_alias_rec->importstatus[import_alias_check].status=in_process))
    SELECT INTO "nl:"
     cvs.code_set
     FROM code_value_set cvs
     WHERE cvs.code_set=cnvtint(import_alias_rec->importstatus[import_alias_check].code_set)
     DETAIL
      import_alias_rec->importstatus[import_alias_check].code_set_display = cvs.display
     WITH counter
    ;end select
    IF ( NOT (curqual > 0))
     SET import_alias_rec->importstatus[import_alias_check].status = code_set_error
    ENDIF
   ENDIF
   IF ((import_alias_rec->importstatus[import_alias_check].status=in_process))
    SET blank_cdf_meaning_cnt = 0
    SET defined_cdf_meaning_cnt = 0
    SET nocdfmeaning_cdf_meaning_cnt = 0
    SELECT INTO "nl:"
     cv.code_value, cv.code_set
     FROM code_value cv
     WHERE (cv.display_key=import_alias_rec->importstatus[import_alias_check].cv_display_key)
      AND cv.code_set=cnvtint(import_alias_rec->importstatus[import_alias_check].code_set)
     DETAIL
      IF (size(trim(cv.cdf_meaning))=0
       AND size(trim(import_alias_rec->importstatus[import_alias_check].cdf_meaning))=size(trim(cv
        .cdf_meaning)))
       IF (cv.active_ind=active_ind_active)
        blank_cdf_meaning_cnt += 1, import_alias_rec->importstatus[import_alias_check].code_value =
        cv.code_value, import_alias_rec->importstatus[import_alias_check].code_value_matched_by =
        cv_match_display_key,
        import_alias_rec->importstatus[import_alias_check].status = in_process
       ELSEIF ( NOT ((import_alias_rec->importstatus[import_alias_check].code_value > 0.0)))
        import_alias_rec->importstatus[import_alias_check].status = cv_inactive_error
       ENDIF
      ELSEIF (trim(import_alias_rec->importstatus[import_alias_check].cdf_meaning)=trim(cv
       .cdf_meaning))
       IF (cv.active_ind=active_ind_active)
        defined_cdf_meaning_cnt += 1, import_alias_rec->importstatus[import_alias_check].code_value
         = cv.code_value, import_alias_rec->importstatus[import_alias_check].code_value_matched_by =
        cv_match_display_key,
        import_alias_rec->importstatus[import_alias_check].status = in_process
       ELSEIF ( NOT ((import_alias_rec->importstatus[import_alias_check].code_value > 0.0)))
        import_alias_rec->importstatus[import_alias_check].status = cv_inactive_error
       ENDIF
      ELSEIF (trim(import_alias_rec->importstatus[import_alias_check].cdf_meaning)=no_cdf_meaning_txt
      )
       IF (cv.active_ind=active_ind_active)
        nocdfmeaning_cdf_meaning_cnt += 1, import_alias_rec->importstatus[import_alias_check].
        code_value = cv.code_value, import_alias_rec->importstatus[import_alias_check].
        code_value_matched_by = cv_match_display_key,
        import_alias_rec->importstatus[import_alias_check].status = in_process
       ELSEIF ( NOT ((import_alias_rec->importstatus[import_alias_check].code_value > 0.0)))
        import_alias_rec->importstatus[import_alias_check].status = cv_inactive_error
       ENDIF
      ENDIF
     WITH counter
    ;end select
    IF (((blank_cdf_meaning_cnt > 1) OR (((defined_cdf_meaning_cnt > 1) OR (
    nocdfmeaning_cdf_meaning_cnt > 1)) )) )
     SET import_alias_rec->importstatus[import_alias_check].status = cv_mult_display_key_error
    ELSEIF ( NOT ((import_alias_rec->importstatus[import_alias_check].code_value > 0))
     AND (import_alias_rec->importstatus[import_alias_check].status=in_process))
     SET blank_cdf_meaning_cnt = 0
     SET defined_cdf_meaning_cnt = 0
     SET nocdfmeaning_cdf_meaning_cnt = 0
     SELECT INTO "nl:"
      cv.code_value, cv.code_set
      FROM code_value cv
      WHERE cv.code_set=cnvtint(import_alias_rec->importstatus[import_alias_check].code_set)
       AND (cnvtupper(cnvtalphanum(cv.description))=import_alias_rec->importstatus[import_alias_check
      ].cv_display_key)
      DETAIL
       IF (size(trim(cv.cdf_meaning))=0
        AND size(trim(import_alias_rec->importstatus[import_alias_check].cdf_meaning))=size(trim(cv
         .cdf_meaning)))
        IF (cv.active_ind=active_ind_active)
         blank_cdf_meaning_cnt += 1, import_alias_rec->importstatus[import_alias_check].code_value =
         cv.code_value, import_alias_rec->importstatus[import_alias_check].code_value_matched_by =
         cv_match_description,
         import_alias_rec->importstatus[import_alias_check].status = in_process
        ELSEIF ( NOT ((import_alias_rec->importstatus[import_alias_check].code_value > 0.0)))
         import_alias_rec->importstatus[import_alias_check].status = cv_inactive_error
        ENDIF
       ELSEIF (trim(import_alias_rec->importstatus[import_alias_check].cdf_meaning)=trim(cv
        .cdf_meaning))
        IF (cv.active_ind=active_ind_active)
         defined_cdf_meaning_cnt += 1, import_alias_rec->importstatus[import_alias_check].code_value
          = cv.code_value, import_alias_rec->importstatus[import_alias_check].code_value_matched_by
          = cv_match_description,
         import_alias_rec->importstatus[import_alias_check].status = in_process
        ELSEIF ( NOT ((import_alias_rec->importstatus[import_alias_check].code_value > 0.0)))
         import_alias_rec->importstatus[import_alias_check].status = cv_inactive_error
        ENDIF
       ELSEIF (trim(import_alias_rec->importstatus[import_alias_check].cdf_meaning)=
       no_cdf_meaning_txt)
        IF (cv.active_ind=active_ind_active)
         nocdfmeaning_cdf_meaning_cnt += 1, import_alias_rec->importstatus[import_alias_check].
         code_value = cv.code_value, import_alias_rec->importstatus[import_alias_check].
         code_value_matched_by = cv_match_description,
         import_alias_rec->importstatus[import_alias_check].status = in_process
        ELSEIF ( NOT ((import_alias_rec->importstatus[import_alias_check].code_value > 0.0)))
         import_alias_rec->importstatus[import_alias_check].status = cv_inactive_error
        ENDIF
       ENDIF
      WITH counter
     ;end select
     IF (((blank_cdf_meaning_cnt > 1) OR (((defined_cdf_meaning_cnt > 1) OR (
     nocdfmeaning_cdf_meaning_cnt > 1)) )) )
      SET import_alias_rec->importstatus[import_alias_check].status = cv_mult_display_key_error
     ELSEIF ( NOT ((import_alias_rec->importstatus[import_alias_check].code_value > 0))
      AND (import_alias_rec->importstatus[import_alias_check].status=in_process)
      AND trim(import_alias_rec->importstatus[import_alias_check].cdf_meaning)=no_cdf_meaning_txt)
      SET blank_cdf_meaning_cnt = 0
      SET defined_cdf_meaning_cnt = 0
      SET nocdfmeaning_cdf_meaning_cnt = 0
      SELECT INTO "nl:"
       cv.code_value, cv.code_set
       FROM code_value cv
       WHERE cv.code_set=cnvtint(import_alias_rec->importstatus[import_alias_check].code_set)
        AND (cnvtupper(cnvtalphanum(cv.cdf_meaning))=import_alias_rec->importstatus[
       import_alias_check].cv_display_key)
       DETAIL
        IF (size(trim(cv.cdf_meaning))=0
         AND size(trim(import_alias_rec->importstatus[import_alias_check].cdf_meaning))=size(trim(cv
          .cdf_meaning)))
         IF (cv.active_ind=active_ind_active)
          blank_cdf_meaning_cnt += 1, import_alias_rec->importstatus[import_alias_check].code_value
           = cv.code_value, import_alias_rec->importstatus[import_alias_check].code_value_matched_by
           = cv_match_cdf_meaning,
          import_alias_rec->importstatus[import_alias_check].status = in_process
         ELSEIF ( NOT ((import_alias_rec->importstatus[import_alias_check].code_value > 0.0)))
          import_alias_rec->importstatus[import_alias_check].status = cv_inactive_error
         ENDIF
        ELSEIF (trim(import_alias_rec->importstatus[import_alias_check].cdf_meaning)=trim(cv
         .cdf_meaning))
         IF (cv.active_ind=active_ind_active)
          defined_cdf_meaning_cnt += 1, import_alias_rec->importstatus[import_alias_check].code_value
           = cv.code_value, import_alias_rec->importstatus[import_alias_check].code_value_matched_by
           = cv_match_cdf_meaning,
          import_alias_rec->importstatus[import_alias_check].status = in_process
         ELSEIF ( NOT ((import_alias_rec->importstatus[import_alias_check].code_value > 0.0)))
          import_alias_rec->importstatus[import_alias_check].status = cv_inactive_error
         ENDIF
        ELSEIF (trim(import_alias_rec->importstatus[import_alias_check].cdf_meaning)=
        no_cdf_meaning_txt)
         IF (cv.active_ind=active_ind_active)
          nocdfmeaning_cdf_meaning_cnt += 1, import_alias_rec->importstatus[import_alias_check].
          code_value = cv.code_value, import_alias_rec->importstatus[import_alias_check].
          code_value_matched_by = cv_match_cdf_meaning,
          import_alias_rec->importstatus[import_alias_check].status = in_process
         ELSEIF ( NOT ((import_alias_rec->importstatus[import_alias_check].code_value > 0.0)))
          import_alias_rec->importstatus[import_alias_check].status = cv_inactive_error
         ENDIF
        ENDIF
       WITH counter
      ;end select
     ENDIF
     IF ((import_alias_rec->importstatus[import_alias_check].status=in_process))
      IF (((blank_cdf_meaning_cnt > 1) OR (((defined_cdf_meaning_cnt > 1) OR (
      nocdfmeaning_cdf_meaning_cnt > 1)) )) )
       SET import_alias_rec->importstatus[import_alias_check].status = cv_mult_display_key_error
      ELSEIF ( NOT (curqual > 0))
       SET import_alias_rec->importstatus[import_alias_check].status = cv_display_key_error
      ENDIF
     ENDIF
    ENDIF
    IF ( NOT ((import_alias_rec->importstatus[import_alias_check].code_value > 0))
     AND (import_alias_rec->importstatus[import_alias_check].status=in_process))
     SET import_alias_rec->importstatus[import_alias_check].status = cv_display_key_error
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (import_inbound_alias(import_aliases_num=i4,commit_ind=i2) =c1)
  CALL import_aliases_check(import_aliases_num)
  IF ((import_alias_rec->importstatus[import_aliases_num].status=in_process))
   SELECT INTO "nl:"
    cva.alias, cva.updt_applctx, cva.updt_cnt,
    cva.updt_dt_tm, cva.updt_id
    FROM code_value_alias cva
    WHERE cva.code_set=cnvtint(import_alias_rec->importstatus[import_aliases_num].code_set)
     AND (cva.alias=import_alias_rec->importstatus[import_aliases_num].alias)
     AND (cva.contributor_source_cd=import_alias_rec->importstatus[import_aliases_num].
    contributor_source_cd)
     AND (cva.alias_type_meaning=import_alias_rec->importstatus[import_aliases_num].
    alias_type_meaning)
    WITH counter
   ;end select
   IF (curqual=0)
    SET import_alias_rec->importstatus[import_aliases_num].status = successful
    IF ((import_alias_rec->importstatus[import_aliases_num].contributor_source_cd > 0.0)
     AND size(trim(import_alias_rec->importstatus[import_aliases_num].alias)) > 0
     AND (import_alias_rec->importstatus[import_aliases_num].code_value > 0.0))
     IF (commit_ind=perform_insert)
      INSERT  FROM code_value_alias cva
       SET code_set = cnvtint(import_alias_rec->importstatus[import_aliases_num].code_set),
        contributor_source_cd = import_alias_rec->importstatus[import_aliases_num].
        contributor_source_cd, alias = import_alias_rec->importstatus[import_aliases_num].alias,
        code_value = import_alias_rec->importstatus[import_aliases_num].code_value,
        alias_type_meaning = import_alias_rec->importstatus[import_aliases_num].alias_type_meaning,
        updt_applctx = updt_applctx_id,
        updt_id = updt_task_id, updt_dt_tm = cnvtdatetime(sysdate), updt_cnt = 0
      ;end insert
      COMMIT
     ENDIF
    ELSE
     SET import_alias_rec->importstatus[import_aliases_num].status = unknown_error
    ENDIF
   ELSE
    SET import_alias_rec->importstatus[import_aliases_num].status = alias_exists
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE (import_outbound_alias(import_aliases_num=i4,commit_ind=i2) =c1)
  CALL import_aliases_check(import_aliases_num)
  IF ((import_alias_rec->importstatus[import_aliases_num].status=in_process))
   SELECT INTO "nl:"
    cvo.alias, cvo.updt_applctx, cvo.updt_cnt,
    cvo.updt_dt_tm, cvo.updt_id
    FROM code_value_outbound cvo
    WHERE cvo.code_set=cnvtint(import_alias_rec->importstatus[import_aliases_num].code_set)
     AND (cvo.code_value=import_alias_rec->importstatus[import_aliases_num].code_value)
     AND (cvo.contributor_source_cd=import_alias_rec->importstatus[import_aliases_num].
    contributor_source_cd)
     AND (cvo.alias_type_meaning=import_alias_rec->importstatus[import_aliases_num].
    alias_type_meaning)
    WITH counter
   ;end select
   IF (curqual=0)
    SET import_alias_rec->importstatus[import_aliases_num].status = successful
    IF ((import_alias_rec->importstatus[import_aliases_num].contributor_source_cd > 0.0)
     AND size(trim(import_alias_rec->importstatus[import_aliases_num].alias)) > 0
     AND (import_alias_rec->importstatus[import_aliases_num].code_value > 0.0))
     IF (commit_ind=perform_insert)
      INSERT  FROM code_value_outbound
       SET code_set = cnvtint(import_alias_rec->importstatus[import_aliases_num].code_set),
        contributor_source_cd = import_alias_rec->importstatus[import_aliases_num].
        contributor_source_cd, alias = import_alias_rec->importstatus[import_aliases_num].alias,
        code_value = import_alias_rec->importstatus[import_aliases_num].code_value,
        alias_type_meaning = import_alias_rec->importstatus[import_aliases_num].alias_type_meaning,
        updt_applctx = updt_applctx_id,
        updt_id = updt_task_id, updt_dt_tm = cnvtdatetime(sysdate), updt_cnt = 0
      ;end insert
      COMMIT
     ENDIF
    ELSE
     SET import_alias_rec->importstatus[import_aliases_num].status = unknown_error
    ENDIF
   ELSE
    SET import_alias_rec->importstatus[import_aliases_num].status = dup_outbound_alias_error
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE format_csv_output(dummy_var)
   DECLARE statusfound = i2 WITH noconstant(0)
   DECLARE tempoutputcsv = vc WITH noconstant("")
   SET tempoutputcsv = trim("",3)
   CALL clear(1,1)
   SET message = nowindow
   SET tempoutputcsv = build2(
    "STATUS,CODE_SET,CODE_SET_DISPLAY,CONTRIBUTOR_SOURCE_DISPLAY_KEY,CONTIBUTOR_SOURCE_CD",
    ",CODE_VALUE_DISPLAY_KEY,CDF_MEANING,CODE_VALUE,ALIAS,ALIAS_TYPE_MEANING,ALIAS_DIRECTION,STATUS,CODE_VALUE_MATCHED_BY"
    )
   FOR (statusnum = - (1) TO max_status)
     SET statusfound = 0
     CASE (statusnum)
      OF unknown_error:
       SET tempoutputcsv = build2(tempoutputcsv,char_cr,char_lf,"Unknown Error")
      OF in_process:
       SET tempoutputcsv = build2(tempoutputcsv,char_cr,char_lf,"Alias in process")
      OF successful:
       SET tempoutputcsv = build2(tempoutputcsv,char_cr,char_lf,"Successful")
      OF code_set_error:
       SET tempoutputcsv = build2(tempoutputcsv,char_cr,char_lf,"Missing/Invalid/Inactive Code_set")
      OF contrib_src_error:
       SET tempoutputcsv = build2(tempoutputcsv,char_cr,char_lf,
        "Missing/Invalid/Inactive Contributor Source")
      OF cv_display_key_error:
       SET tempoutputcsv = build2(tempoutputcsv,char_cr,char_lf,"Missing/Invalid Display Key")
      OF missing_alias_error:
       SET tempoutputcsv = build2(tempoutputcsv,char_cr,char_lf,"Missing Alias")
      OF alias_length_error:
       SET tempoutputcsv = build2(tempoutputcsv,char_cr,char_lf,"Alias over 255 characters")
      OF a_t_m_length_error:
       SET tempoutputcsv = build2(tempoutputcsv,char_cr,char_lf,
        "Aliast Type Meaning over 12 characters")
      OF alias_direction_error:
       SET tempoutputcsv = build2(tempoutputcsv,char_cr,char_lf,"Unkown alias direction")
      OF alias_exists:
       SET tempoutputcsv = build2(tempoutputcsv,char_cr,char_lf,
        "Alias/contributor source/alias type meaning row already exists")
      OF dup_outbound_alias_error:
       SET tempoutputcsv = build2(tempoutputcsv,char_cr,char_lf,
        "Outbound code_set/code_value/contributor_source_cd/alias_type_meaning has already been set")
      OF cv_mult_display_key_error:
       SET tempoutputcsv = build2(tempoutputcsv,char_cr,char_lf,
        "Multiple code_values found for defined display_key/cdf_meaning")
      OF cv_inactive_error:
       SET tempoutputcsv = build2(tempoutputcsv,char_cr,char_lf,"The code_values are inactive")
     ENDCASE
     FOR (formatnum = 1 TO size(import_alias_rec->importstatus,5))
       IF ((statusnum=import_alias_rec->importstatus[formatnum].status))
        SET statusfound = 1
        SET tempoutputcsv = build2(tempoutputcsv,char_cr,char_lf,',"',trim(import_alias_rec->
          importstatus[formatnum].code_set,3),
         '","',trim(import_alias_rec->importstatus[formatnum].code_set_display,3),'","',trim(
          import_alias_rec->importstatus[formatnum].contributor_source_display_key,3),'","',
         trim(cnvtstring(import_alias_rec->importstatus[formatnum].contributor_source_cd),3),'","',
         trim(import_alias_rec->importstatus[formatnum].cv_display_key,3),'","',trim(import_alias_rec
          ->importstatus[formatnum].cdf_meaning,3),
         '","',trim(cnvtstring(import_alias_rec->importstatus[formatnum].code_value),3),'","',trim(
          import_alias_rec->importstatus[formatnum].alias,3),'","',
         trim(import_alias_rec->importstatus[formatnum].alias_type_meaning,3),'","',trim(
          import_alias_rec->importstatus[formatnum].alias_direction,3),'","',trim(cnvtstring(
           import_alias_rec->importstatus[formatnum].status),3),
         '","',trim(cnvtstring(import_alias_rec->importstatus[formatnum].code_value_matched_by),3),
         '"')
       ENDIF
     ENDFOR
     IF (statusfound=0)
      SET tempoutputcsv = build2(tempoutputcsv,char_cr,char_lf,"None Found",char_cr,
       char_lf)
     ELSE
      SET tempoutputcsv = build2(tempoutputcsv,char_cr,char_lf)
     ENDIF
   ENDFOR
   RETURN(tempoutputcsv)
 END ;Subroutine
 SUBROUTINE client_format_csv_output(dummy_var)
   DECLARE statusfound = i2 WITH noconstant(0)
   DECLARE tempoutputcsv = vc WITH noconstant("")
   SET tempoutputcsv = trim("",3)
   CALL clear(1,1)
   SET message = nowindow
   SET tempoutputcsv = build2(
    "STATUS,CODE_SET,CODE_SET_DISPLAY,CONTRIBUTOR_SOURCE_DISPLAY_KEY,CONTIBUTOR_SOURCE_CD",
    ",CODE_VALUE_DISPLAY_KEY,CDF_MEANING,CODE_VALUE,ALIAS,ALIAS_TYPE_MEANING,ALIAS_DIRECTION,STATUS,CODE_VALUE_MATCHED_BY"
    )
   FOR (statusnum = - (1) TO max_status)
     SET statusfound = 0
     CASE (statusnum)
      OF successful:
       SET tempoutputcsv = build2(tempoutputcsv,char_cr,char_lf,"Successful")
      OF alias_exists:
       SET tempoutputcsv = build2(tempoutputcsv,char_cr,char_lf,
        "Alias/contributor source/alias type meaning row already exists")
      OF dup_outbound_alias_error:
       SET tempoutputcsv = build2(tempoutputcsv,char_cr,char_lf,
        "Outbound code_set/code_value/contributor_source_cd/alias_type_meaning has already been set")
      OF cv_inactive_error:
       SET tempoutputcsv = build2(tempoutputcsv,char_cr,char_lf,"The code_values are inactive")
     ENDCASE
     FOR (formatnum = 1 TO size(import_alias_rec->importstatus,5))
       IF ((statusnum=import_alias_rec->importstatus[formatnum].status)
        AND ((statusnum=successful) OR (((statusnum=alias_exists) OR (((statusnum=
       dup_outbound_alias_error) OR (statusnum=cv_inactive_error)) )) )) )
        SET statusfound = 1
        SET tempoutputcsv = build2(tempoutputcsv,char_cr,char_lf,',"',trim(import_alias_rec->
          importstatus[formatnum].code_set,3),
         '","',trim(import_alias_rec->importstatus[formatnum].code_set_display,3),'","',trim(
          import_alias_rec->importstatus[formatnum].contributor_source_display_key,3),'","',
         trim(cnvtstring(import_alias_rec->importstatus[formatnum].contributor_source_cd),3),'","',
         trim(import_alias_rec->importstatus[formatnum].cv_display_key,3),'","',trim(import_alias_rec
          ->importstatus[formatnum].cdf_meaning,3),
         '","',trim(cnvtstring(import_alias_rec->importstatus[formatnum].code_value),3),'","',trim(
          import_alias_rec->importstatus[formatnum].alias,3),'","',
         trim(import_alias_rec->importstatus[formatnum].alias_type_meaning,3),'","',trim(
          import_alias_rec->importstatus[formatnum].alias_direction,3),'","',trim(cnvtstring(
           import_alias_rec->importstatus[formatnum].status),3),
         '","',trim(cnvtstring(import_alias_rec->importstatus[formatnum].code_value_matched_by),3),
         '"')
       ENDIF
     ENDFOR
     IF (statusfound=0
      AND ((statusnum=successful) OR (((statusnum=alias_exists) OR (((statusnum=
     dup_outbound_alias_error) OR (statusnum=cv_inactive_error)) )) )) )
      SET tempoutputcsv = build2(tempoutputcsv,char_cr,char_lf,"None Found",char_cr,
       char_lf)
     ELSE
      SET tempoutputcsv = build2(tempoutputcsv,char_cr,char_lf)
     ENDIF
   ENDFOR
   RETURN(tempoutputcsv)
 END ;Subroutine
 SUBROUTINE (write_file(filename=vc,messagebody=vc,writemode=vc) =c1)
   FREE SET cclio_rec
   RECORD cclio_rec(
     1 file_desc = i4
     1 file_offset = i4
     1 file_dir = i4
     1 file_name = vc
     1 file_buf = vc
   )
   SET cclio_rec->file_name = filename
   SET cclio_rec->file_buf = writemode
   SET stat = cclio("OPEN",cclio_rec)
   SET cclio_rec->file_buf = messagebody
   SET stat = cclio("WRITE",cclio_rec)
   SET stat = cclio("CLOSE",cclio_rec)
 END ;Subroutine
 SUBROUTINE (get_file_name(default_get_file_txt=vc,default_get_file_name=vc) =vc)
   CALL clear(1,1)
   CALL text(7,15,default_get_file_txt)
   CALL accept(8,15,"##############################################;;C",default_get_file_name)
   RETURN(curaccept)
 END ;Subroutine
 SUBROUTINE clear_import_vars(dummy_var)
   SET stat = initrec(import_alias_rec)
   SET csvfilename = ""
   SET csvfiletxt = ""
   SET csvrowtxt = ""
   SET csvrownum = 2
   SET doneparsing = 0
   SET import_alias_rec_size = 0
   SET outputcsvfilename = ""
   SET outputcsv = ""
 END ;Subroutine
 SUBROUTINE set_resonance_xds_csv(dummy_var)
   DECLARE resonance_xds_csv = vc WITH noconstant("")
   SET resonance_xds_csv = build2(
    "CODE_SET,CONTRIBUTOR SOURCE (DISPLAY_KEY or Display),CODE_VALUE (DISPLAY KEY or Display)",
    ",CDF_MEANING,Alias,ALIAS TYPE MEANING,IN/OUT Bound alias (IN for inbound and OUT for outbound)",
    char_cr,char_lf)
   RETURN(resonance_xds_csv)
 END ;Subroutine
 SUBROUTINE (set_code_value_to_alias(copy_contrib_source=vc,copy_cdf_meaning=vc,copy_code_set=vc,
  copy_dest=vc) =vc)
   DECLARE tempdisplaytoaliascsv = vc WITH noconstant("")
   SELECT INTO "nl:"
    cv.display, cv.code_set, cv.code_value
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=copy_code_set)
    ORDER BY cv.display
    DETAIL
     IF (((cv.cdf_meaning=copy_cdf_meaning) OR (size(copy_cdf_meaning)=0)) )
      tempdisplaytoaliascsv = build2(tempdisplaytoaliascsv,trim(cnvtstring(cv.code_set)),',"',trim(
        copy_contrib_source),'","',
       trim(cv.display),'",NOCDFMEANING',',"',build2("CD:",trim(cnvtstring(cv.code_value))),'",,',
       trim(copy_dest),char_cr,char_lf)
     ENDIF
    WITH nocounter
   ;end select
   RETURN(tempdisplaytoaliascsv)
 END ;Subroutine
 SUBROUTINE (get_display_to_alias(copy_contrib_source=vc,copy_code_set=vc,copy_dest=vc) =vc)
   DECLARE tempdisplaytoaliascsv = vc WITH noconstant("")
   SELECT INTO "nl:"
    cv.display, cv.code_set, cv.code_value
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=copy_code_set)
    ORDER BY cv.display
    DETAIL
     tempdisplaytoaliascsv = build2(tempdisplaytoaliascsv,trim(cnvtstring(cv.code_set)),',"',trim(
       copy_contrib_source),'","',
      trim(cv.display),'",NOCDFMEANING',',"',trim(cv.display),'",,',
      trim(copy_dest),char_cr,char_lf)
    WITH nocounter
   ;end select
   RETURN(tempdisplaytoaliascsv)
 END ;Subroutine
 SUBROUTINE (set_resonance_xds_cs_4_out(contrib_source=vc) =c1)
   DECLARE tempdisplaytoaliascsv = vc WITH noconstant("")
   SET tempdisplaytoaliascsv = build2("4,",contrib_source,",MRN,NOCDFMEANING,MRN,,OUT",char_cr,
    char_lf,
    "4,",contrib_source,",Community Medical Record Number,NOCDFMEANING,CMRN,,OUT",char_cr,char_lf,
    "4,",contrib_source,",CMRN,NOCDFMEANING,CMRN,,OUT",char_cr,char_lf)
   RETURN(tempdisplaytoaliascsv)
 END ;Subroutine
 SUBROUTINE (set_resonance_xds_cs_15_out(contrib_source=vc) =c1)
   DECLARE tempdisplaytoaliascsv = vc WITH noconstant("")
   SET tempdisplaytoaliascsv = build2("15,",contrib_source,",?LAND ISLANDS,NOCDFMEANING,AX,,OUT",
    char_cr,char_lf,
    "15,",contrib_source,",AFGHANISTAN,NOCDFMEANING,AF,,OUT",char_cr,char_lf,
    "15,",contrib_source,",African Intellectual Property Organization,NOCDFMEANING,OA,,OUT",char_cr,
    char_lf,
    "15,",contrib_source,",African Regional Industrial Property Organization,NOCDFMEANING,AP,,OUT",
    char_cr,char_lf,
    "15,",contrib_source,",ALBANIA,NOCDFMEANING,AL,,OUT",char_cr,char_lf,
    "15,",contrib_source,",ALGERIA,NOCDFMEANING,DZ,,OUT",char_cr,char_lf,
    "15,",contrib_source,",AMERICAN SAMOA,NOCDFMEANING,AS,,OUT",char_cr,char_lf,
    "15,",contrib_source,",ANDORRA,NOCDFMEANING,AD,,OUT",char_cr,char_lf,
    "15,",contrib_source,",ANGOLA,NOCDFMEANING,AO,,OUT",char_cr,char_lf,
    "15,",contrib_source,",ANGUILLA,NOCDFMEANING,AI,,OUT",char_cr,char_lf,
    "15,",contrib_source,",ANTARCTICA,NOCDFMEANING,AQ,,OUT",char_cr,char_lf,
    "15,",contrib_source,",ANTIGUA AND BARBUDA,NOCDFMEANING,AG,,OUT",char_cr,char_lf,
    "15,",contrib_source,",ARGENTINA,NOCDFMEANING,AR,,OUT",char_cr,char_lf,
    "15,",contrib_source,",Argentina,NOCDFMEANING,RA,,OUT",char_cr,char_lf,
    "15,",contrib_source,",ARMENIA,NOCDFMEANING,AM,,OUT",char_cr,char_lf,
    "15,",contrib_source,",ARUBA,NOCDFMEANING,AW,,OUT",char_cr,char_lf,
    "15,",contrib_source,",Ascension Island,NOCDFMEANING,AC,,OUT",char_cr,char_lf,
    "15,",contrib_source,",AUSTRALIA,NOCDFMEANING,AU,,OUT",char_cr,char_lf,
    "15,",contrib_source,",AUSTRIA,NOCDFMEANING,AT,,OUT",char_cr,char_lf,
    "15,",contrib_source,",AZERBAIJAN,NOCDFMEANING,AZ,,OUT",char_cr,char_lf,
    "15,",contrib_source,",BAHAMAS,NOCDFMEANING,BS,,OUT",char_cr,char_lf,
    "15,",contrib_source,",BAHRAIN,NOCDFMEANING,BH,,OUT",char_cr,char_lf,
    "15,",contrib_source,",BANGLADESH,NOCDFMEANING,BD,,OUT",char_cr,char_lf,
    "15,",contrib_source,",BARBADOS,NOCDFMEANING,BB,,OUT",char_cr,char_lf,
    "15,",contrib_source,",BELARUS,NOCDFMEANING,BY,,OUT",char_cr,char_lf,
    "15,",contrib_source,",BELGIUM,NOCDFMEANING,BE,,OUT",char_cr,char_lf,
    "15,",contrib_source,",BELIZE,NOCDFMEANING,BZ,,OUT",char_cr,char_lf,
    "15,",contrib_source,",Benelux Trademarks and Designs Office,NOCDFMEANING,BX,,OUT",char_cr,
    char_lf,
    "15,",contrib_source,",BENIN,NOCDFMEANING,BJ,,OUT",char_cr,char_lf,
    "15,",contrib_source,",Benin,NOCDFMEANING,DY,,OUT",char_cr,char_lf,
    "15,",contrib_source,",BERMUDA,NOCDFMEANING,BM,,OUT",char_cr,char_lf,
    "15,",contrib_source,",BHUTAN,NOCDFMEANING,BT,,OUT",char_cr,char_lf,
    "15,",contrib_source,",Bolivia [cf. Botswana: identical code element],NOCDFMEANING,RB,,OUT",
    char_cr,char_lf,
    "15,",contrib_source,',"BOLIVIA, PLURINATIONAL STATE OF",NOCDFMEANING,BO,,OUT',char_cr,char_lf,
    "15,",contrib_source,',"BONAIRE, SINT EUSTATIUS AND SABA",NOCDFMEANING,BQ,,OUT',char_cr,char_lf,
    "15,",contrib_source,",BOSNIA AND HERZEGOVINA,NOCDFMEANING,BA,,OUT",char_cr,char_lf,
    "15,",contrib_source,",BOTSWANA,NOCDFMEANING,BW,,OUT",char_cr,char_lf,
    "15,",contrib_source,",BOUVET ISLAND,NOCDFMEANING,BV,,OUT",char_cr,char_lf,
    "15,",contrib_source,",BRAZIL,NOCDFMEANING,BR,,OUT",char_cr,char_lf,
    "15,",contrib_source,",BRITISH INDIAN OCEAN TERRITORY,NOCDFMEANING,IO,,OUT",char_cr,char_lf,
    "15,",contrib_source,",BRUNEI DARUSSALAM,NOCDFMEANING,BN,,OUT",char_cr,char_lf,
    "15,",contrib_source,",BULGARIA,NOCDFMEANING,BG,,OUT",char_cr,char_lf,
    "15,",contrib_source,",BURKINA FASO,NOCDFMEANING,BF,,OUT",char_cr,char_lf,
    "15,",contrib_source,",Burma,NOCDFMEANING,BU,,OUT",char_cr,char_lf,
    "15,",contrib_source,",BURUNDI,NOCDFMEANING,BI,,OUT",char_cr,char_lf,
    "15,",contrib_source,",C?TE DIVOIRE,NOCDFMEANING,CI,,OUT",char_cr,char_lf,
    "15,",contrib_source,",CAMBODIA,NOCDFMEANING,KH,,OUT",char_cr,char_lf,
    "15,",contrib_source,",CAMEROON,NOCDFMEANING,CM,,OUT",char_cr,char_lf,
    "15,",contrib_source,",CANADA,NOCDFMEANING,CA,,OUT",char_cr,char_lf,
    "15,",contrib_source,",Canary Islands,NOCDFMEANING,IC,,OUT",char_cr,char_lf,
    "15,",contrib_source,",CAPE VERDE,NOCDFMEANING,CV,,OUT",char_cr,char_lf,
    "15,",contrib_source,",CAYMAN ISLANDS,NOCDFMEANING,KY,,OUT",char_cr,char_lf,
    "15,",contrib_source,",CENTRAL AFRICAN REPUBLIC,NOCDFMEANING,CF,,OUT",char_cr,char_lf,
    "15,",contrib_source,',"Ceuta, Melilla",NOCDFMEANING,EA,,OUT',char_cr,char_lf,
    "15,",contrib_source,",CHAD,NOCDFMEANING,TD,,OUT",char_cr,char_lf,
    "15,",contrib_source,",CHILE,NOCDFMEANING,CL,,OUT",char_cr,char_lf,
    "15,",contrib_source,",CHINA,NOCDFMEANING,CN,,OUT",char_cr,char_lf,
    "15,",contrib_source,",China,NOCDFMEANING,RC,,OUT",char_cr,char_lf,
    "15,",contrib_source,",CHRISTMAS ISLAND,NOCDFMEANING,CX,,OUT",char_cr,char_lf,
    "15,",contrib_source,",Clipperton Island,NOCDFMEANING,CP,,OUT",char_cr,char_lf,
    "15,",contrib_source,",COCOS (KEELING) ISLANDS,NOCDFMEANING,CC,,OUT",char_cr,char_lf,
    "15,",contrib_source,",COLOMBIA,NOCDFMEANING,CO,,OUT",char_cr,char_lf,
    "15,",contrib_source,",COMOROS,NOCDFMEANING,KM,,OUT",char_cr,char_lf,
    "15,",contrib_source,",CONGO,NOCDFMEANING,CG,,OUT",char_cr,char_lf,
    "15,",contrib_source,',"CONGO, THE DEMOCRATIC REPUBLIC OF THE",NOCDFMEANING,CD,,OUT',char_cr,
    char_lf,
    "15,",contrib_source,",COOK ISLANDS,NOCDFMEANING,CK,,OUT",char_cr,char_lf,
    "15,",contrib_source,",COSTA RICA,NOCDFMEANING,CR,,OUT",char_cr,char_lf,
    "15,",contrib_source,",CROATIA,NOCDFMEANING,HR,,OUT",char_cr,char_lf,
    "15,",contrib_source,",CUBA,NOCDFMEANING,CU,,OUT",char_cr,char_lf,
    "15,",contrib_source,",CURA?AO,NOCDFMEANING,CW,,OUT",char_cr,char_lf,
    "15,",contrib_source,",CYPRUS,NOCDFMEANING,CY,,OUT",char_cr,char_lf,
    "15,",contrib_source,",CZECH REPUBLIC,NOCDFMEANING,CZ,,OUT",char_cr,char_lf,
    "15,",contrib_source,",DENMARK,NOCDFMEANING,DK,,OUT",char_cr,char_lf,
    "15,",contrib_source,",Diego Garcia,NOCDFMEANING,DG,,OUT",char_cr,char_lf,
    "15,",contrib_source,",DJIBOUTI,NOCDFMEANING,DJ,,OUT",char_cr,char_lf,
    "15,",contrib_source,",DOMINICA,NOCDFMEANING,DM,,OUT",char_cr,char_lf,
    "15,",contrib_source,",DOMINICAN REPUBLIC,NOCDFMEANING,DO,,OUT",char_cr,char_lf,
    "15,",contrib_source,",East Timor,NOCDFMEANING,TP,,OUT",char_cr,char_lf,
    "15,",contrib_source,",ECUADOR,NOCDFMEANING,EC,,OUT",char_cr,char_lf,
    "15,",contrib_source,",EGYPT,NOCDFMEANING,EG,,OUT",char_cr,char_lf,
    "15,",contrib_source,",EL SALVADOR,NOCDFMEANING,SV,,OUT",char_cr,char_lf,
    "15,",contrib_source,",EQUATORIAL GUINEA,NOCDFMEANING,GQ,,OUT",char_cr,char_lf,
    "15,",contrib_source,",ERITREA,NOCDFMEANING,ER,,OUT",char_cr,char_lf,
    "15,",contrib_source,",ESTONIA,NOCDFMEANING,EE,,OUT",char_cr,char_lf,
    "15,",contrib_source,",Estonia,NOCDFMEANING,EW,,OUT",char_cr,char_lf,
    "15,",contrib_source,",ETHIOPIA,NOCDFMEANING,ET,,OUT",char_cr,char_lf,
    "15,",contrib_source,",Eurasian Patent Organization,NOCDFMEANING,EV,,OUT",char_cr,char_lf,
    "15,",contrib_source,",European Patent Organization,NOCDFMEANING,EP,,OUT",char_cr,char_lf,
    "15,",contrib_source,",European Trademark Office,NOCDFMEANING,EM,,OUT",char_cr,char_lf,
    "15,",contrib_source,",European Union,NOCDFMEANING,EU,,OUT",char_cr,char_lf,
    "15,",contrib_source,",FALKLAND ISLANDS (MALVINAS),NOCDFMEANING,FK,,OUT",char_cr,char_lf,
    "15,",contrib_source,",FAROE ISLANDS,NOCDFMEANING,FO,,OUT",char_cr,char_lf,
    "15,",contrib_source,",FIJI,NOCDFMEANING,FJ,,OUT",char_cr,char_lf,
    "15,",contrib_source,",FINLAND,NOCDFMEANING,FI,,OUT",char_cr,char_lf,
    "15,",contrib_source,",Finland,NOCDFMEANING,SF,,OUT",char_cr,char_lf,
    "15,",contrib_source,",FRANCE,NOCDFMEANING,FR,,OUT",char_cr,char_lf,
    "15,",contrib_source,',"France, Metropolitan",NOCDFMEANING,FX,,OUT',char_cr,char_lf,
    "15,",contrib_source,",FRENCH GUIANA,NOCDFMEANING,GF,,OUT",char_cr,char_lf,
    "15,",contrib_source,",FRENCH POLYNESIA,NOCDFMEANING,PF,,OUT",char_cr,char_lf,
    "15,",contrib_source,",FRENCH SOUTHERN TERRITORIES,NOCDFMEANING,TF,,OUT",char_cr,char_lf,
    "15,",contrib_source,",GABON,NOCDFMEANING,GA,,OUT",char_cr,char_lf,
    "15,",contrib_source,",GAMBIA,NOCDFMEANING,GM,,OUT",char_cr,char_lf,
    "15,",contrib_source,",GEORGIA,NOCDFMEANING,GE,,OUT",char_cr,char_lf,
    "15,",contrib_source,",GERMANY,NOCDFMEANING,DE,,OUT",char_cr,char_lf,
    "15,",contrib_source,",GHANA,NOCDFMEANING,GH,,OUT",char_cr,char_lf,
    "15,",contrib_source,",GIBRALTAR,NOCDFMEANING,GI,,OUT",char_cr,char_lf,
    "15,",contrib_source,",GREECE,NOCDFMEANING,GR,,OUT",char_cr,char_lf,
    "15,",contrib_source,",GREENLAND,NOCDFMEANING,GL,,OUT",char_cr,char_lf,
    "15,",contrib_source,",GRENADA,NOCDFMEANING,GD,,OUT",char_cr,char_lf,
    "15,",contrib_source,",Grenada,NOCDFMEANING,WG,,OUT",char_cr,char_lf,
    "15,",contrib_source,",GUADELOUPE,NOCDFMEANING,GP,,OUT",char_cr,char_lf,
    "15,",contrib_source,",GUAM,NOCDFMEANING,GU,,OUT",char_cr,char_lf,
    "15,",contrib_source,",GUATEMALA,NOCDFMEANING,GT,,OUT",char_cr,char_lf,
    "15,",contrib_source,",GUERNSEY,NOCDFMEANING,GG,,OUT",char_cr,char_lf,
    "15,",contrib_source,",GUINEA,NOCDFMEANING,GN,,OUT",char_cr,char_lf,
    "15,",contrib_source,",GUINEA-BISSAU,NOCDFMEANING,GW,,OUT",char_cr,char_lf,
    "15,",contrib_source,",GUYANA,NOCDFMEANING,GY,,OUT",char_cr,char_lf,
    "15,",contrib_source,",HAITI,NOCDFMEANING,HT,,OUT",char_cr,char_lf,
    "15,",contrib_source,",Haiti,NOCDFMEANING,RH,,OUT",char_cr,char_lf,
    "15,",contrib_source,",HEARD ISLAND AND MCDONALD ISLANDS,NOCDFMEANING,HM,,OUT",char_cr,char_lf,
    "15,",contrib_source,",HOLY SEE (VATICAN CITY STATE),NOCDFMEANING,VA,,OUT",char_cr,char_lf,
    "15,",contrib_source,",HONDURAS,NOCDFMEANING,HN,,OUT",char_cr,char_lf,
    "15,",contrib_source,",HONG KONG,NOCDFMEANING,HK,,OUT",char_cr,char_lf,
    "15,",contrib_source,",HUNGARY,NOCDFMEANING,HU,,OUT",char_cr,char_lf,
    "15,",contrib_source,",ICELAND,NOCDFMEANING,IS,,OUT",char_cr,char_lf,
    "15,",contrib_source,",INDIA,NOCDFMEANING,IN,,OUT",char_cr,char_lf,
    "15,",contrib_source,",INDONESIA,NOCDFMEANING,ID,,OUT",char_cr,char_lf,
    "15,",contrib_source,",Indonesia,NOCDFMEANING,RI,,OUT",char_cr,char_lf,
    "15,",contrib_source,",International Bureau of WIPO,NOCDFMEANING,IB,,OUT",char_cr,char_lf,
    "15,",contrib_source,',"IRAN, ISLAMIC REPUBLIC OF",NOCDFMEANING,IR,,OUT',char_cr,char_lf,
    "15,",contrib_source,",IRAQ,NOCDFMEANING,IQ,,OUT",char_cr,char_lf,
    "15,",contrib_source,",IRELAND,NOCDFMEANING,IE,,OUT",char_cr,char_lf,
    "15,",contrib_source,",ISLE OF MAN,NOCDFMEANING,IM,,OUT",char_cr,char_lf,
    "15,",contrib_source,",ISRAEL,NOCDFMEANING,IL,,OUT",char_cr,char_lf,
    "15,",contrib_source,",ITALY,NOCDFMEANING,IT,,OUT",char_cr,char_lf,
    "15,",contrib_source,",Jamaica,NOCDFMEANING,JA,,OUT",char_cr,char_lf,
    "15,",contrib_source,",JAMAICA,NOCDFMEANING,JM,,OUT",char_cr,char_lf,
    "15,",contrib_source,",JAPAN,NOCDFMEANING,JP,,OUT",char_cr,char_lf,
    "15,",contrib_source,",JERSEY,NOCDFMEANING,JE,,OUT",char_cr,char_lf,
    "15,",contrib_source,",JORDAN,NOCDFMEANING,JO,,OUT",char_cr,char_lf,
    "15,",contrib_source,",KAZAKHSTAN,NOCDFMEANING,KZ,,OUT",char_cr,char_lf,
    "15,",contrib_source,",KENYA,NOCDFMEANING,KE,,OUT",char_cr,char_lf,
    "15,",contrib_source,",KIRIBATI,NOCDFMEANING,KI,,OUT",char_cr,char_lf,
    "15,",contrib_source,',"KOREA, DEMOCRATIC PEOPLES REPUBLIC OF",NOCDFMEANING,KP,,OUT',char_cr,
    char_lf,
    "15,",contrib_source,',"KOREA, REPUBLIC OF",NOCDFMEANING,KR,,OUT',char_cr,char_lf,
    "15,",contrib_source,",KUWAIT,NOCDFMEANING,KW,,OUT",char_cr,char_lf,
    "15,",contrib_source,",KYRGYZSTAN,NOCDFMEANING,KG,,OUT",char_cr,char_lf,
    "15,",contrib_source,",LAO PEOPLES DEMOCRATIC REPUBLIC,NOCDFMEANING,LA,,OUT",char_cr,char_lf,
    "15,",contrib_source,",LATVIA,NOCDFMEANING,LV,,OUT",char_cr,char_lf,
    "15,",contrib_source,",LEBANON,NOCDFMEANING,LB,,OUT",char_cr,char_lf,
    "15,",contrib_source,",Lebanon,NOCDFMEANING,RL,,OUT",char_cr,char_lf,
    "15,",contrib_source,",LESOTHO,NOCDFMEANING,LS,,OUT",char_cr,char_lf,
    "15,",contrib_source,",LIBERIA,NOCDFMEANING,LR,,OUT",char_cr,char_lf,
    "15,",contrib_source,",LIBYA,NOCDFMEANING,LY,,OUT",char_cr,char_lf,
    "15,",contrib_source,",Libya Fezzan,NOCDFMEANING,LF,,OUT",char_cr,char_lf,
    "15,",contrib_source,",Liechtenstein,NOCDFMEANING,FL,,OUT",char_cr,char_lf,
    "15,",contrib_source,",LIECHTENSTEIN,NOCDFMEANING,LI,,OUT",char_cr,char_lf,
    "15,",contrib_source,",LITHUANIA,NOCDFMEANING,LT,,OUT",char_cr,char_lf,
    "15,",contrib_source,",LUXEMBOURG,NOCDFMEANING,LU,,OUT",char_cr,char_lf,
    "15,",contrib_source,",MACAO,NOCDFMEANING,MO,,OUT",char_cr,char_lf,
    "15,",contrib_source,',"MACEDONIA, THE FORMER YUGOSLAV REPUBLIC OF",NOCDFMEANING,MK,,OUT',char_cr,
    char_lf,
    "15,",contrib_source,",MADAGASCAR,NOCDFMEANING,MG,,OUT",char_cr,char_lf,
    "15,",contrib_source,",Madagascar,NOCDFMEANING,RM,,OUT",char_cr,char_lf,
    "15,",contrib_source,",MALAWI,NOCDFMEANING,MW,,OUT",char_cr,char_lf,
    "15,",contrib_source,",MALAYSIA,NOCDFMEANING,MY,,OUT",char_cr,char_lf,
    "15,",contrib_source,",MALDIVES,NOCDFMEANING,MV,,OUT",char_cr,char_lf,
    "15,",contrib_source,",MALI,NOCDFMEANING,ML,,OUT",char_cr,char_lf,
    "15,",contrib_source,",MALTA,NOCDFMEANING,MT,,OUT",char_cr,char_lf,
    "15,",contrib_source,",MARSHALL ISLANDS,NOCDFMEANING,MH,,OUT",char_cr,char_lf,
    "15,",contrib_source,",MARTINIQUE,NOCDFMEANING,MQ,,OUT",char_cr,char_lf,
    "15,",contrib_source,",MAURITANIA,NOCDFMEANING,MR,,OUT",char_cr,char_lf,
    "15,",contrib_source,",MAURITIUS,NOCDFMEANING,MU,,OUT",char_cr,char_lf,
    "15,",contrib_source,",MAYOTTE,NOCDFMEANING,YT,,OUT",char_cr,char_lf,
    "15,",contrib_source,",MEXICO,NOCDFMEANING,MX,,OUT",char_cr,char_lf,
    "15,",contrib_source,',"MICRONESIA, FEDERATED STATES OF",NOCDFMEANING,FM,,OUT',char_cr,char_lf,
    "15,",contrib_source,',"MOLDOVA, REPUBLIC OF",NOCDFMEANING,MD,,OUT',char_cr,char_lf,
    "15,",contrib_source,",MONACO,NOCDFMEANING,MC,,OUT",char_cr,char_lf,
    "15,",contrib_source,",MONGOLIA,NOCDFMEANING,MN,,OUT",char_cr,char_lf,
    "15,",contrib_source,",MONTENEGRO,NOCDFMEANING,ME,,OUT",char_cr,char_lf,
    "15,",contrib_source,",MONTSERRAT,NOCDFMEANING,MS,,OUT",char_cr,char_lf,
    "15,",contrib_source,",MOROCCO,NOCDFMEANING,MA,,OUT",char_cr,char_lf,
    "15,",contrib_source,",MOZAMBIQUE,NOCDFMEANING,MZ,,OUT",char_cr,char_lf,
    "15,",contrib_source,",MYANMAR,NOCDFMEANING,MM,,OUT",char_cr,char_lf,
    "15,",contrib_source,",NAMIBIA,NOCDFMEANING,NA,,OUT",char_cr,char_lf,
    "15,",contrib_source,",NAURU,NOCDFMEANING,NR,,OUT",char_cr,char_lf,
    "15,",contrib_source,",NEPAL,NOCDFMEANING,NP,,OUT",char_cr,char_lf,
    "15,",contrib_source,",NETHERLANDS,NOCDFMEANING,NL,,OUT",char_cr,char_lf,
    "15,",contrib_source,",Netherlands Antilles,NOCDFMEANING,AN,,OUT",char_cr,char_lf,
    "15,",contrib_source,",Neutral Zone,NOCDFMEANING,NT,,OUT",char_cr,char_lf,
    "15,",contrib_source,",NEW CALEDONIA,NOCDFMEANING,NC,,OUT",char_cr,char_lf,
    "15,",contrib_source,",NEW ZEALAND,NOCDFMEANING,NZ,,OUT",char_cr,char_lf,
    "15,",contrib_source,",NICARAGUA,NOCDFMEANING,NI,,OUT",char_cr,char_lf,
    "15,",contrib_source,",NIGER,NOCDFMEANING,NE,,OUT",char_cr,char_lf,
    "15,",contrib_source,",Niger,NOCDFMEANING,RN,,OUT",char_cr,char_lf,
    "15,",contrib_source,",NIGERIA,NOCDFMEANING,NG,,OUT",char_cr,char_lf,
    "15,",contrib_source,",NIUE,NOCDFMEANING,NU,,OUT",char_cr,char_lf,
    "15,",contrib_source,",NORFOLK ISLAND,NOCDFMEANING,NF,,OUT",char_cr,char_lf,
    "15,",contrib_source,",NORTHERN MARIANA ISLANDS,NOCDFMEANING,MP,,OUT",char_cr,char_lf,
    "15,",contrib_source,",NORWAY,NOCDFMEANING,NO,,OUT",char_cr,char_lf,
    "15,",contrib_source,",OMAN,NOCDFMEANING,OM,,OUT",char_cr,char_lf,
    "15,",contrib_source,",PAKISTAN,NOCDFMEANING,PK,,OUT",char_cr,char_lf,
    "15,",contrib_source,",PALAU,NOCDFMEANING,PW,,OUT",char_cr,char_lf,
    "15,",contrib_source,',"PALESTINE, STATE OF",NOCDFMEANING,PS,,OUT',char_cr,char_lf,
    "15,",contrib_source,",PANAMA,NOCDFMEANING,PA,,OUT",char_cr,char_lf,
    "15,",contrib_source,",PAPUA NEW GUINEA,NOCDFMEANING,PG,,OUT",char_cr,char_lf,
    "15,",contrib_source,",PARAGUAY,NOCDFMEANING,PY,,OUT",char_cr,char_lf,
    "15,",contrib_source,
    ",Patent Office of the Cooperation Council for the Arab States of the Gulf (GCC),NOCDFMEANING,GC,,OUT",
    char_cr,char_lf,
    "15,",contrib_source,",PERU,NOCDFMEANING,PE,,OUT",char_cr,char_lf,
    "15,",contrib_source,",PHILIPPINES,NOCDFMEANING,PH,,OUT",char_cr,char_lf,
    "15,",contrib_source,",Philippines,NOCDFMEANING,PI,,OUT",char_cr,char_lf,
    "15,",contrib_source,",Philippines,NOCDFMEANING,RP,,OUT",char_cr,char_lf,
    "15,",contrib_source,",PITCAIRN,NOCDFMEANING,PN,,OUT",char_cr,char_lf,
    "15,",contrib_source,",POLAND,NOCDFMEANING,PL,,OUT",char_cr,char_lf,
    "15,",contrib_source,",PORTUGAL,NOCDFMEANING,PT,,OUT",char_cr,char_lf,
    "15,",contrib_source,",PUERTO RICO,NOCDFMEANING,PR,,OUT",char_cr,char_lf,
    "15,",contrib_source,",QATAR,NOCDFMEANING,QA,,OUT",char_cr,char_lf,
    "15,",contrib_source,",R?UNION,NOCDFMEANING,RE,,OUT",char_cr,char_lf,
    "15,",contrib_source,",ROMANIA,NOCDFMEANING,RO,,OUT",char_cr,char_lf,
    "15,",contrib_source,",RUSSIAN FEDERATION,NOCDFMEANING,RU,,OUT",char_cr,char_lf,
    "15,",contrib_source,",RWANDA,NOCDFMEANING,RW,,OUT",char_cr,char_lf,
    "15,",contrib_source,",SAINT BARTH?LEMY,NOCDFMEANING,BL,,OUT",char_cr,char_lf,
    "15,",contrib_source,',"SAINT HELENA, ASCENSION AND TRISTAN DA CUNHA",NOCDFMEANING,SH,,OUT',
    char_cr,char_lf,
    "15,",contrib_source,",SAINT KITTS AND NEVIS,NOCDFMEANING,KN,,OUT",char_cr,char_lf,
    "15,",contrib_source,",SAINT LUCIA,NOCDFMEANING,LC,,OUT",char_cr,char_lf,
    "15,",contrib_source,",Saint Lucia,NOCDFMEANING,WL,,OUT",char_cr,char_lf,
    "15,",contrib_source,",SAINT MARTIN (FRENCH PART),NOCDFMEANING,MF,,OUT",char_cr,char_lf,
    "15,",contrib_source,",SAINT PIERRE AND MIQUELON,NOCDFMEANING,PM,,OUT",char_cr,char_lf,
    "15,",contrib_source,",Saint Vincent,NOCDFMEANING,WV,,OUT",char_cr,char_lf,
    "15,",contrib_source,",SAINT VINCENT AND THE GRENADINES,NOCDFMEANING,VC,,OUT",char_cr,char_lf,
    "15,",contrib_source,",SAMOA,NOCDFMEANING,WS,,OUT",char_cr,char_lf,
    "15,",contrib_source,",SAN MARINO,NOCDFMEANING,SM,,OUT",char_cr,char_lf,
    "15,",contrib_source,",SAO TOME AND PRINCIPE,NOCDFMEANING,ST,,OUT",char_cr,char_lf,
    "15,",contrib_source,",SAUDI ARABIA,NOCDFMEANING,SA,,OUT",char_cr,char_lf,
    "15,",contrib_source,",SENEGAL,NOCDFMEANING,SN,,OUT",char_cr,char_lf,
    "15,",contrib_source,",SERBIA,NOCDFMEANING,RS,,OUT",char_cr,char_lf,
    "15,",contrib_source,",SERBIA AND MONTENEGRO,NOCDFMEANING,CS,,OUT",char_cr,char_lf,
    "15,",contrib_source,",SEYCHELLES,NOCDFMEANING,SC,,OUT",char_cr,char_lf,
    "15,",contrib_source,",SIERRA LEONE,NOCDFMEANING,SL,,OUT",char_cr,char_lf,
    "15,",contrib_source,",SINGAPORE,NOCDFMEANING,SG,,OUT",char_cr,char_lf,
    "15,",contrib_source,",SINT MAARTEN (DUTCH PART),NOCDFMEANING,SX,,OUT",char_cr,char_lf,
    "15,",contrib_source,",SLOVAKIA,NOCDFMEANING,SK,,OUT",char_cr,char_lf,
    "15,",contrib_source,",SLOVENIA,NOCDFMEANING,SI,,OUT",char_cr,char_lf,
    "15,",contrib_source,",SOLOMON ISLANDS,NOCDFMEANING,SB,,OUT",char_cr,char_lf,
    "15,",contrib_source,",SOMALIA,NOCDFMEANING,SO,,OUT",char_cr,char_lf,
    "15,",contrib_source,",SOUTH AFRICA,NOCDFMEANING,ZA,,OUT",char_cr,char_lf,
    "15,",contrib_source,",SOUTH GEORGIA AND THE SOUTH SANDWICH ISLANDS,NOCDFMEANING,GS,,OUT",char_cr,
    char_lf,
    "15,",contrib_source,",SOUTH SUDAN,NOCDFMEANING,SS,,OUT",char_cr,char_lf,
    "15,",contrib_source,",SPAIN,NOCDFMEANING,ES,,OUT",char_cr,char_lf,
    "15,",contrib_source,",SRI LANKA,NOCDFMEANING,LK,,OUT",char_cr,char_lf,
    "15,",contrib_source,",SUDAN,NOCDFMEANING,SD,,OUT",char_cr,char_lf,
    "15,",contrib_source,",SURINAME,NOCDFMEANING,SR,,OUT",char_cr,char_lf,
    "15,",contrib_source,",SVALBARD AND JAN MAYEN,NOCDFMEANING,SJ,,OUT",char_cr,char_lf,
    "15,",contrib_source,",SWAZILAND,NOCDFMEANING,SZ,,OUT",char_cr,char_lf,
    "15,",contrib_source,",SWEDEN,NOCDFMEANING,SE,,OUT",char_cr,char_lf,
    "15,",contrib_source,",SWITZERLAND,NOCDFMEANING,CH,,OUT",char_cr,char_lf,
    "15,",contrib_source,",SYRIAN ARAB REPUBLIC,NOCDFMEANING,SY,,OUT",char_cr,char_lf,
    "15,",contrib_source,',"TAIWAN, PROVINCE OF CHINA",NOCDFMEANING,TW,,OUT',char_cr,char_lf,
    "15,",contrib_source,",TAJIKISTAN,NOCDFMEANING,TJ,,OUT",char_cr,char_lf,
    "15,",contrib_source,',"TANZANIA, UNITED REPUBLIC OF",NOCDFMEANING,TZ,,OUT',char_cr,char_lf,
    "15,",contrib_source,",THAILAND,NOCDFMEANING,TH,,OUT",char_cr,char_lf,
    "15,",contrib_source,",TIMOR-LESTE,NOCDFMEANING,TL,,OUT",char_cr,char_lf,
    "15,",contrib_source,",TOGO,NOCDFMEANING,TG,,OUT",char_cr,char_lf,
    "15,",contrib_source,",TOKELAU,NOCDFMEANING,TK,,OUT",char_cr,char_lf,
    "15,",contrib_source,",TONGA,NOCDFMEANING,TO,,OUT",char_cr,char_lf,
    "15,",contrib_source,",TRINIDAD AND TOBAGO,NOCDFMEANING,TT,,OUT",char_cr,char_lf,
    "15,",contrib_source,",Tristan da Cunha,NOCDFMEANING,TA,,OUT",char_cr,char_lf,
    "15,",contrib_source,",TUNISIA,NOCDFMEANING,TN,,OUT",char_cr,char_lf,
    "15,",contrib_source,",TURKEY,NOCDFMEANING,TR,,OUT",char_cr,char_lf,
    "15,",contrib_source,",TURKMENISTAN,NOCDFMEANING,TM,,OUT",char_cr,char_lf,
    "15,",contrib_source,",TURKS AND CAICOS ISLANDS,NOCDFMEANING,TC,,OUT",char_cr,char_lf,
    "15,",contrib_source,",TUVALU,NOCDFMEANING,TV,,OUT",char_cr,char_lf,
    "15,",contrib_source,",UGANDA,NOCDFMEANING,UG,,OUT",char_cr,char_lf,
    "15,",contrib_source,",UKRAINE,NOCDFMEANING,UA,,OUT",char_cr,char_lf,
    "15,",contrib_source,
    ",Union of Countries under the European Community Patent Convention,NOCDFMEANING,EF,,OUT",char_cr,
    char_lf,
    "15,",contrib_source,",UNITED ARAB EMIRATES,NOCDFMEANING,AE,,OUT",char_cr,char_lf,
    "15,",contrib_source,",UNITED KINGDOM,NOCDFMEANING,GB,,OUT",char_cr,char_lf,
    "15,",contrib_source,",United Kingdom,NOCDFMEANING,UK,,OUT",char_cr,char_lf,
    "15,",contrib_source,",UNITED STATES,NOCDFMEANING,US,,OUT",char_cr,char_lf,
    "15,",contrib_source,",US,NOCDFMEANING,US,,OUT",char_cr,char_lf,
    "15,",contrib_source,",USA,NOCDFMEANING,US,,OUT",char_cr,char_lf,
    "15,",contrib_source,",UNITED STATES MINOR OUTLYING ISLANDS,NOCDFMEANING,UM,,OUT",char_cr,char_lf,
    "15,",contrib_source,",URUGUAY,NOCDFMEANING,UY,,OUT",char_cr,char_lf,
    "15,",contrib_source,",USSR,NOCDFMEANING,SU,,OUT",char_cr,char_lf,
    "15,",contrib_source,",UZBEKISTAN,NOCDFMEANING,UZ,,OUT",char_cr,char_lf,
    "15,",contrib_source,",VANUATU,NOCDFMEANING,VU,,OUT",char_cr,char_lf,
    "15,",contrib_source,",Venezuela,NOCDFMEANING,YV,,OUT",char_cr,char_lf,
    "15,",contrib_source,',"VENEZUELA, BOLIVARIAN REPUBLIC",NOCDFMEANING,VE,,OUT',char_cr,char_lf,
    "15,",contrib_source,",VIET NAM,NOCDFMEANING,VN,,OUT",char_cr,char_lf,
    "15,",contrib_source,',"VIRGIN ISLANDS, BRITISH",NOCDFMEANING,VG,,OUT',char_cr,char_lf,
    "15,",contrib_source,',"VIRGIN ISLANDS, U.S.",NOCDFMEANING,VI,,OUT',char_cr,char_lf,
    "15,",contrib_source,",WALLIS AND FUTUNA,NOCDFMEANING,WF,,OUT",char_cr,char_lf,
    "15,",contrib_source,",WESTERN SAHARA,NOCDFMEANING,EH,,OUT",char_cr,char_lf,
    "15,",contrib_source,",World Intellectual Property Organization,NOCDFMEANING,WO,,OUT",char_cr,
    char_lf,
    "15,",contrib_source,",YEMEN,NOCDFMEANING,YE,,OUT",char_cr,char_lf,
    "15,",contrib_source,",Yugoslavia,NOCDFMEANING,YU,,OUT",char_cr,char_lf,
    "15,",contrib_source,",Zaire,NOCDFMEANING,ZR,,OUT",char_cr,char_lf,
    "15,",contrib_source,",ZAMBIA,NOCDFMEANING,ZM,,OUT",char_cr,char_lf,
    "15,",contrib_source,",ZIMBABWE,NOCDFMEANING,ZW,,OUT",char_cr,char_lf)
   RETURN(tempdisplaytoaliascsv)
 END ;Subroutine
 SUBROUTINE (set_resonance_xds_cs_27_out(contrib_source=vc) =c1)
   DECLARE tempdisplaytoaliascsv = vc WITH noconstant("")
   SET tempdisplaytoaliascsv = build2("27,",contrib_source,
    ",Hispanic or Latino,NOCDFMEANING,2135-2,,OUT",char_cr,char_lf,
    "27,",contrib_source,",not Hispanic or Latino,NOCDFMEANING,2186-5,,OUT",char_cr,char_lf,
    "27,",contrib_source,",Unknown,NOCDFMEANING,Unknown,,OUT",char_cr,char_lf,
    "27,",contrib_source,",Hispanic,NOCDFMEANING,2135-2,,OUT",char_cr,char_lf,
    "27,",contrib_source,",Non-Hispanic,NOCDFMEANING,2186-5,,OUT",char_cr,char_lf)
   RETURN(tempdisplaytoaliascsv)
 END ;Subroutine
 SUBROUTINE (set_resonance_xds_cs_43_out(contrib_source=vc) =c1)
   DECLARE tempdisplaytoaliascsv = vc WITH noconstant("")
   SET tempdisplaytoaliascsv = build2("43,",contrib_source,",Professional,NOCDFMEANING,WPN,,OUT",
    char_cr,char_lf,
    "43,",contrib_source,",Business,NOCDFMEANING,WPN,,OUT",char_cr,char_lf,
    "43,",contrib_source,",Home,NOCDFMEANING,PRN,,OUT",char_cr,char_lf,
    "43,",contrib_source,",Primary Home,NOCDFMEANING,PRN,,OUT",char_cr,char_lf,
    "43,",contrib_source,",cell,NOCDFMEANING,ORN,,OUT",char_cr,char_lf,
    "43,",contrib_source,",Emergency Phone,NOCDFMEANING,EMR,,OUT",char_cr,char_lf)
   RETURN(tempdisplaytoaliascsv)
 END ;Subroutine
 SUBROUTINE (set_resonance_xds_cs_57_out(contrib_source=vc) =c1)
   DECLARE tempdisplaytoaliascsv = vc WITH noconstant("")
   SET tempdisplaytoaliascsv = build2("57,",contrib_source,",Male,NOCDFMEANING,M,,OUT",char_cr,
    char_lf,
    "57,",contrib_source,",Female,NOCDFMEANING,F,,OUT",char_cr,char_lf,
    "57,",contrib_source,",Unknown,NOCDFMEANING,U,,OUT",char_cr,char_lf,
    "57,",contrib_source,",Unspecified,NOCDFMEANING,U,,OUT",char_cr,char_lf)
   RETURN(tempdisplaytoaliascsv)
 END ;Subroutine
 SUBROUTINE (set_resonance_xds_cs_212_out(contrib_source=vc) =c1)
   DECLARE tempdisplaytoaliascsv = vc WITH noconstant("")
   SET tempdisplaytoaliascsv = build2("212,",contrib_source,",Business,NOCDFMEANING,B,,OUT",char_cr,
    char_lf,
    "212,",contrib_source,",Home,NOCDFMEANING,H,,OUT",char_cr,char_lf,
    "212,",contrib_source,",Mailing,NOCDFMEANING,M,,OUT",char_cr,char_lf,
    "212,",contrib_source,",Professional,NOCDFMEANING,O,,OUT",char_cr,char_lf,
    "212,",contrib_source,",Temporary,NOCDFMEANING,C,,OUT",char_cr,char_lf)
   RETURN(tempdisplaytoaliascsv)
 END ;Subroutine
 SUBROUTINE (set_resonance_xds_cs_213_out(contrib_source=vc) =c1)
   DECLARE tempdisplaytoaliascsv = vc WITH noconstant("")
   SET tempdisplaytoaliascsv = build2("213,",contrib_source,",Current,NOCDFMEANING,L,,OUT",char_cr,
    char_lf,
    "213,",contrib_source,",Adopted,NOCDFMEANING,C,,OUT",char_cr,char_lf,
    "213,",contrib_source,",Legal,NOCDFMEANING,L,,OUT",char_cr,char_lf,
    "213,",contrib_source,",Maiden,NOCDFMEANING,M,,OUT",char_cr,char_lf,
    "213,",contrib_source,",OTHER,NOCDFMEANING,O,,OUT",char_cr,char_lf,
    "213,",contrib_source,",ALTERNATE,NOCDFMEANING,A,,OUT",char_cr,char_lf)
   RETURN(tempdisplaytoaliascsv)
 END ;Subroutine
 SUBROUTINE (set_resonance_xds_cs_278_out(contrib_source=vc) =c1)
   DECLARE tempdisplaytoaliascsv = vc WITH noconstant("")
   SET tempdisplaytoaliascsv = build2("278,",contrib_source,
    ",FACILITY,NOCDFMEANING,Hospital Setting,HCFACTYPCODE,OUT",char_cr,char_lf)
   RETURN(tempdisplaytoaliascsv)
 END ;Subroutine
 SUBROUTINE (set_resonance_xds_cs_278_nucc_out(contrib_source=vc) =c1)
   DECLARE tempdisplaytoaliascsv = vc WITH noconstant("")
   SET tempdisplaytoaliascsv = build2("278,",contrib_source,
    ",FACILITY,NOCDFMEANING,General Medicine,PRACSETCODE,OUT",char_cr,char_lf)
   RETURN(tempdisplaytoaliascsv)
 END ;Subroutine
 SUBROUTINE (set_resonance_xds_cs_282_out(contrib_source=vc) =c1)
   DECLARE tempdisplaytoaliascsv = vc WITH noconstant("")
   SET tempdisplaytoaliascsv = build2("282,",contrib_source,
    ",American Indian or Alaska Native,NOCDFMEANING,1002-5,,OUT",char_cr,char_lf,
    "282,",contrib_source,",Asian,NOCDFMEANING,2028-9,,OUT",char_cr,char_lf,
    "282,",contrib_source,",Black or African American,NOCDFMEANING,2054-5,,OUT",char_cr,char_lf,
    "282,",contrib_source,",Native Hawaiian or Other Pacific Islander,NOCDFMEANING,2076-8,,OUT",
    char_cr,char_lf,
    "282,",contrib_source,",Other Race,NOCDFMEANING,2131-1,,OUT",char_cr,char_lf,
    "282,",contrib_source,",Asian Indian,NOCDFMEANING,2029-7,,OUT",char_cr,char_lf,
    "282,",contrib_source,",Chinese,NOCDFMEANING,2034-7,,OUT",char_cr,char_lf,
    "282,",contrib_source,",Filipino,NOCDFMEANING,2036-2,,OUT",char_cr,char_lf,
    "282,",contrib_source,",Japanese,NOCDFMEANING,2039-6,,OUT",char_cr,char_lf,
    "282,",contrib_source,",Korean,NOCDFMEANING,2040-4,,OUT",char_cr,char_lf,
    "282,",contrib_source,",Vietnamese,NOCDFMEANING,2047-9,,OUT",char_cr,char_lf,
    "282,",contrib_source,",Hispanic/Spanish,NOCDFMEANING,69854-8,,OUT",char_cr,char_lf,
    "282,",contrib_source,",Other Pacific Islander,NOCDFMEANING,2500-7,,OUT",char_cr,char_lf,
    "282,",contrib_source,",Native Hawaiian,NOCDFMEANING,2079-2,,OUT",char_cr,char_lf,
    "282,",contrib_source,",Guamanian,NOCDFMEANING,2087-5,,OUT",char_cr,char_lf,
    "282,",contrib_source,",Chamorro,NOCDFMEANING,2088-3,,OUT",char_cr,char_lf,
    "282,",contrib_source,",Samoan,NOCDFMEANING,2080-0,,OUT",char_cr,char_lf,
    "282,",contrib_source,",White,NOCDFMEANING,2106-3,,OUT",char_cr,char_lf)
   RETURN(tempdisplaytoaliascsv)
 END ;Subroutine
 SUBROUTINE (set_resonance_xds_cs_4002390_out(contrib_source=vc) =c1)
   DECLARE tempdisplaytoaliascsv = vc WITH noconstant("")
   SET tempdisplaytoaliascsv = build2("4002390,",contrib_source,
    ",CCD with CDA Consolidated Templates V1,NOCDFMEANING,urn:ihe:pcc:xphr:2007,FORMATCODE,OUT",
    char_cr,char_lf,
    "4002390,",contrib_source,
    ",CCD with CDA Consolidated Templates V2,NOCDFMEANING,urn:ihe:pcc:xphr:2007,FORMATCODE,OUT",
    char_cr,char_lf,
    "4002390,",contrib_source,
    ",CDA Wrapped PDF,NOCDFMEANING,urn:ihe:iti:xds-sd:pdf:2008,FORMATCODE,OUT",char_cr,char_lf)
   RETURN(tempdisplaytoaliascsv)
 END ;Subroutine
 SUBROUTINE (set_resonance_xds_cs_4002390_in(contrib_source=vc) =vc)
   DECLARE tempdisplaytoaliascsv = vc WITH noconstant("")
   SET tempdisplaytoaliascsv = build2("4002390,",contrib_source,
    ",CDA,NOCDFMEANING,urn:ihe:pcc:xphr:2007,FORMATCODE,IN",char_cr,char_lf,
    "4002390,",contrib_source,
    ",CDA Wrapped PDF,NOCDFMEANING,urn:ihe:iti:xds-sd:pdf:2008,FORMATCODE,IN",char_cr,char_lf)
   RETURN(tempdisplaytoaliascsv)
 END ;Subroutine
 SUBROUTINE set_resonance_xds_cs_12025_snomedct_out(dummy_var)
   DECLARE tempdisplaytoaliascsv = vc WITH noconstant("")
   SET tempdisplaytoaliascsv = build2("12025,SNOMEDCT,Active,NOCDFMEANING,55561003,,IN",char_cr,
    char_lf)
   RETURN(tempdisplaytoaliascsv)
 END ;Subroutine
 SUBROUTINE set_resonance_xds_cs_12030_out(dummy_var)
   DECLARE tempdisplaytoaliascsv = vc WITH noconstant("")
   SET tempdisplaytoaliascsv = build2("12030,SNOMEDCT,Active,NOCDFMEANING,55561003,,IN",char_cr,
    char_lf,"12030,SNOMEDCT,Inactive,NOCDFMEANING,73425007,,IN",char_cr,
    char_lf,"12030,SNOMEDCT,Resolved,NOCDFMEANING,413322009,,IN",char_cr,char_lf,
    "12030,HL7,active,NOCDFMEANING,active,,IN",
    char_cr,char_lf,"12030,HL7,suspended,NOCDFMEANING,suspended,,IN",char_cr,char_lf,
    "12030,HL7,aborted,NOCDFMEANING,aborted,,IN",char_cr,char_lf,
    "12030,HL7,completed,NOCDFMEANING,completed,,IN",char_cr,
    char_lf)
   RETURN(tempdisplaytoaliascsv)
 END ;Subroutine
 SUBROUTINE (update_oen_personality(interface_name=vc,op_name=vc,op_value=vc) =c1)
   IF (size(trim(op_value)) < 1)
    SET op_value = " "
   ENDIF
   UPDATE  FROM oen_personality
    SET value = op_value
    WHERE name=op_name
     AND interfaceid IN (
    (SELECT
     interfaceid
     FROM oen_procinfo
     WHERE proc_name=interface_name))
   ;end update
   IF (curqual=1)
    COMMIT
   ENDIF
 END ;Subroutine
 SUBROUTINE (get_contributor_system_cd(passed_contributor_system_display=vc) =f8)
   DECLARE validcontributorsys = i2 WITH noconstant(0)
   DECLARE getcontributorsysnamekey = vc WITH noconstant("")
   DECLARE getcontributorsyscd = f8 WITH noconstant(0.0)
   WHILE (validcontributorsys=0)
     CALL clear(1,1)
     CALL text(7,15,"Please enter the contributor system display name:")
     CALL accept(7,51,"###########################################;;C",
      passed_contributor_system_display)
     SET getcontributorsysnamekey = trim(curaccept)
     SELECT INTO "nl:"
      cv.code_value
      FROM code_value cv
      WHERE cv.display_key=cnvtupper(cnvtalphanum(getcontributorsysnamekey))
       AND cv.code_set=89
       AND cv.code_value > 0.0
       AND cv.active_ind=1
       AND cv.end_effective_dt_tm >= cnvtdatetime(sysdate)
      DETAIL
       getcontributorsyscd = cv.code_value
      WITH counter
     ;end select
     IF (curqual > 0)
      SET validcontributorsys = 1
      RETURN(getcontributorsyscd)
     ELSE
      CALL clear(1,1)
      CALL text(7,15,"Contributor System was not found! Try again?")
      CALL accept(8,15,"A;CU","Y")
      IF (curaccept != "Y")
       RETURN(0.0)
      ENDIF
     ENDIF
   ENDWHILE
 END ;Subroutine
 SUBROUTINE (get_res_contributor_system_display(passed_logical_domain_id=f8) =vc)
   DECLARE getcontributorsysdisplay = vc WITH noconstant("XDS_CONTRIBUTOR_SYSTEM")
   DECLARE gateway_home_community_cd = f8 WITH constant(uar_get_code_by("Meaning",4002669,
     "GATEHOMECOM"))
   DECLARE healthexchangepatientidentifiercd = f8 WITH constant(uar_get_code_by("DisplayKey",4,
     "HEALTHEXCHANGEPATIENTIDENTIFIER"))
   DECLARE resonanceorgsearchstring = vc WITH constant("*RESONANCE*")
   SELECT INTO "nl:"
    cs.display
    FROM contributor_system cs,
     org_alias_pool_reltn oapr,
     organization o,
     prsnl p
    PLAN (cs
     WHERE cs.contributor_system_cd > 0.0
      AND cs.active_ind=1
      AND cs.end_effective_dt_tm >= cnvtdatetime(sysdate))
     JOIN (oapr
     WHERE oapr.organization_id=cs.organization_id
      AND oapr.alias_entity_alias_type_cd=healthexchangepatientidentifiercd)
     JOIN (o
     WHERE o.organization_id=oapr.organization_id
      AND o.org_name_key IN (patstring(resonanceorgsearchstring)))
     JOIN (p
     WHERE p.person_id=cs.prsnl_person_id
      AND p.logical_domain_id=passed_logical_domain_id)
    DETAIL
     getcontributorsysdisplay = cs.display
    WITH nocounter
   ;end select
   IF (curqual=0)
    SELECT INTO "nl:"
     cs.display
     FROM contributor_system cs,
      prsnl p
     PLAN (cs
      WHERE cs.enhanced_processing_cd=gateway_home_community_cd
       AND cs.contributor_system_cd > 0.0
       AND cs.active_ind=1
       AND cs.end_effective_dt_tm >= cnvtdatetime(sysdate))
      JOIN (p
      WHERE p.person_id=cs.prsnl_person_id
       AND p.logical_domain_id=passed_logical_domain_id)
     DETAIL
      getcontributorsysdisplay = cs.display
     WITH nocounter
    ;end select
   ENDIF
   RETURN(getcontributorsysdisplay)
 END ;Subroutine
 SUBROUTINE (get_contrib_src_display_by_contrib_sys_display(passed_contributor_system_display=vc) =vc
  )
   DECLARE getcontributorsrcdisplay = vc WITH noconstant("XDS_CONTRIBUTOR_SOURCE")
   SELECT INTO "nl:"
    cv.code_value
    FROM code_value cv,
     contributor_system cs,
     code_value cv2
    PLAN (cv
     WHERE cv.display_key=cnvtupper(cnvtalphanum(passed_contributor_system_display))
      AND cv.code_set=89
      AND cv.code_value > 0.0
      AND cv.active_ind=1
      AND cv.end_effective_dt_tm >= cnvtdatetime(sysdate))
     JOIN (cs
     WHERE cs.contributor_system_cd=cv.code_value)
     JOIN (cv2
     WHERE cv2.code_value=cs.contributor_source_cd
      AND cv2.code_set=73
      AND cv2.code_value > 0.0
      AND cv2.active_ind=1
      AND cv2.end_effective_dt_tm >= cnvtdatetime(sysdate))
    DETAIL
     getcontributorsrcdisplay = cv2.display
    WITH counter
   ;end select
   RETURN(getcontributorsrcdisplay)
 END ;Subroutine
 SUBROUTINE (begin_org_defaults(users_logical_domain_id=f8) =c1)
   SET logicaldomainid = get_logical_domain_id(users_logical_domain_id)
   IF ((logicaldomainid=- (1)))
    GO TO new_res_xds_csv_menu
   ENDIF
   RECORD add_org_defaults_request(
     1 qual[*]
       2 organization_id = f8
       2 info_type_cd = f8
       2 info_sub_type_cd = f8
       2 info_text = vc
       2 value_cd = f8
       2 value_numeric = i4
   )
   RECORD add_orgs(
     1 qual[*]
       2 organization_id = f8
       2 organization_name = vc
       2 oid_ind = i4
   )
   DECLARE xds_document_info_type_cd = f8 WITH constant(uar_get_code_by("Meaning",355,"XDSDOCUMENT"))
   DECLARE days_to_retrieve_sub_info_type_cd = f8 WITH constant(uar_get_code_by("Meaning",356,
     "DAYSTORETR"))
   DECLARE document_status_sub_info_type_cd = f8 WITH constant(uar_get_code_by("Meaning",356,
     "DOCUMENTSTAT"))
   DECLARE retrieve_doc_sub_info_type_cd = f8 WITH constant(uar_get_code_by("Meaning",356,
     "RETRIEVEDOC"))
   DECLARE parse_doc_sub_info_type_cd = f8 WITH constant(uar_get_code_by("Meaning",356,"PARSEDOC"))
   DECLARE default_document_type_sub_info_type_cd = f8 WITH constant(uar_get_code_by("Meaning",356,
     "DEFDOCTYPE"))
   DECLARE archiving_indicator_sub_info_type_cd = f8 WITH constant(uar_get_code_by("Meaning",356,
     "ODMDARCHVIND"))
   DECLARE authorization_mode_sub_info_type_cd = f8 WITH constant(uar_get_code_by("Meaning",356,
     "ODMDAUTHMODE"))
   DECLARE report_template_sub_info_type_cd = f8 WITH constant(uar_get_code_by("Meaning",356,
     "ODMDRPTMPLID"))
   DECLARE retrieve_doc_value_cd = f8 WITH constant(uar_get_code_by("Meaning",4002689,"RETRQUERY"))
   DECLARE parse_doc_value_cd = f8 WITH constant(uar_get_code_by("Meaning",4002690,"PARSERETR"))
   DECLARE document_status_submitted = vc WITH constant("Submitted")
   DECLARE document_status_approved = vc WITH constant("Approved")
   DECLARE document_status_deprecated = vc WITH constant("Deprecated")
   DECLARE approved_value_cd = f8 WITH constant(1.00)
   DECLARE deprecated_value_cd = f8 WITH constant(2.00)
   DECLARE default_value_numeric = i4 WITH constant(0)
   DECLARE days_to_retrieve_info_text = vc WITH constant("180")
   DECLARE days_to_retrieve_value_cd = f8 WITH constant(0.00)
   DECLARE facility_org_type_cd = f8 WITH constant(uar_get_code_by("Meaning",278,"FACILITY"))
   DECLARE oid_entity_type_org = vc WITH constant("ORGANIZATION")
   DECLARE oid_entity_type_alias_pool = vc WITH constant("ALIAS_POOL")
   DECLARE orgsdefaultsadded = i2 WITH noconstant(0)
   DECLARE orgsdefaultsmissingoids = i2 WITH noconstant(0)
   DECLARE isvalid = i2 WITH noconstant(1)
   DECLARE isactive = i2 WITH noconstant(0)
   DECLARE default_event_cd = f8 WITH noconstant(0.0)
   DECLARE default_event_cd_display = vc WITH noconstant("")
   DECLARE validdefaulteventcd = i2 WITH noconstant(0)
   IF ( NOT (days_to_retrieve_sub_info_type_cd > 0))
    CALL clear(1,1)
    SET message = nowindow
    CALL text(7,15,
     "Code Value not returned for CDF Meaning of DAYSTORETR on codeset 356. Verify code value is active"
     )
    CALL text(8,15,"Press enter to continue")
    CALL accept(9,15,"A;CU","")
    SET isvalid = 0
   ENDIF
   IF ( NOT (document_status_sub_info_type_cd > 0))
    CALL clear(1,1)
    SET message = nowindow
    CALL text(7,15,
     "Code Value not returned for CDF Meaning of DOCUMENTSTAT on codeset 356. Verify code value is active"
     )
    CALL text(8,15,"Press enter to continue")
    CALL accept(9,15,"A;CU","")
    SET isvalid = 0
   ENDIF
   IF ( NOT (retrieve_doc_sub_info_type_cd > 0))
    CALL clear(1,1)
    SET message = nowindow
    CALL text(7,15,
     "Code Value not returned for CDF Meaning of RETRIEVEDOC on codeset 356. Verify code value is active"
     )
    CALL text(8,15,"Press enter to continue")
    CALL accept(9,15,"A;CU","")
    SET isvalid = 0
   ENDIF
   IF ( NOT (parse_doc_sub_info_type_cd > 0))
    CALL clear(1,1)
    SET message = nowindow
    CALL text(7,15,
     "Code Value not returned for CDF Meaning of PARSEDOC on codeset 356. Verify code value is active"
     )
    CALL text(8,15,"Press enter to continue")
    CALL accept(9,15,"A;CU","")
    SET isvalid = 0
   ENDIF
   IF ( NOT (retrieve_doc_value_cd > 0))
    CALL clear(1,1)
    SET message = nowindow
    CALL text(7,15,
     "Code Value not returned for CDF Meaning of RETRQUERY on codeset 4002689. Verify code value is active"
     )
    CALL text(8,15,"Press enter to continue")
    CALL accept(9,15,"A;CU","")
    SET isvalid = 0
   ENDIF
   IF ( NOT (parse_doc_value_cd > 0))
    CALL clear(1,1)
    SET message = nowindow
    CALL text(7,15,
     "Code Value not returned for CDF Meaning of PARSERETR on codeset 4002690. Verify code value is active"
     )
    CALL text(8,15,"Press enter to continue")
    CALL accept(9,15,"A;CU","")
    SET isvalid = 0
   ENDIF
   IF ( NOT (xds_document_info_type_cd > 0))
    CALL clear(1,1)
    SET message = nowindow
    CALL text(7,15,
     "Code Value not returned for CDF Meaning of XDSDOCUMENT on codeset 355. Verify code value is active"
     )
    CALL text(8,15,"Press enter to continue")
    CALL accept(9,15,"A;CU","")
    SET isvalid = 0
   ENDIF
   IF ( NOT (default_document_type_sub_info_type_cd > 0))
    SET isactive = 0
    SELECT INTO "nl:"
     cv.cdf_meaning, cv.active_ind
     FROM code_value cv
     PLAN (cv
      WHERE cv.code_set=356
       AND cv.cdf_meaning="DEFDOCTYPE")
     DETAIL
      isactive = cv.active_ind
     WITH nocounter
    ;end select
    IF (curqual > 0)
     CALL clear(1,1)
     SET message = nowindow
     CALL text(7,15,
      "Code Value not returned for CDF Meaning of DEFDOCTYPE on codeset 356. Verify code value is active"
      )
     CALL text(8,15,"Press enter to continue")
     CALL accept(9,15,"A;CU","")
     SET isvalid = 0
    ENDIF
   ENDIF
   IF ( NOT (archiving_indicator_sub_info_type_cd > 0))
    SET isactive = 0
    SELECT INTO "nl:"
     cv.cdf_meaning, cv.active_ind
     FROM code_value cv
     PLAN (cv
      WHERE cv.code_set=356
       AND cv.cdf_meaning="ODMDARCHVIND")
     DETAIL
      isactive = cv.active_ind
     WITH nocounter
    ;end select
    IF (curqual > 0)
     CALL clear(1,1)
     SET message = nowindow
     CALL text(7,15,
      "Code Value not returned for CDF Meaning of ODMDARCHVIND on codeset 356. Verify code value is active"
      )
     CALL text(8,15,"Press enter to continue")
     CALL accept(9,15,"A;CU","")
     SET isvalid = 0
    ENDIF
   ENDIF
   IF ( NOT (authorization_mode_sub_info_type_cd > 0))
    SET isactive = 0
    SELECT INTO "nl:"
     cv.cdf_meaning, cv.active_ind
     FROM code_value cv
     PLAN (cv
      WHERE cv.code_set=356
       AND cv.cdf_meaning="ODMDAUTHMODE")
     DETAIL
      isactive = cv.active_ind
     WITH nocounter
    ;end select
    IF (curqual > 0)
     CALL clear(1,1)
     SET message = nowindow
     CALL text(7,15,
      "Code Value not returned for CDF Meaning of ODMDAUTHMODE on codeset 356. Verify code value is active"
      )
     CALL text(8,15,"Press enter to continue")
     CALL accept(9,15,"A;CU","")
     SET isvalid = 0
    ENDIF
   ENDIF
   IF ( NOT (report_template_sub_info_type_cd > 0))
    SET isactive = 0
    SELECT INTO "nl:"
     cv.cdf_meaning, cv.active_ind
     FROM code_value cv
     PLAN (cv
      WHERE cv.code_set=356
       AND cv.cdf_meaning="ODMDRPTMPLID")
     DETAIL
      isactive = cv.active_ind
     WITH nocounter
    ;end select
    IF (curqual > 0)
     CALL clear(1,1)
     SET message = nowindow
     CALL text(7,15,
      "Code Value not returned for CDF Meaning of ODMDRPTMPLID on codeset 356. Verify code value is active"
      )
     CALL text(8,15,"Press enter to continue")
     CALL accept(9,15,"A;CU","")
     SET isvalid = 0
    ENDIF
   ENDIF
   IF (isvalid=1)
    WHILE (validdefaulteventcd=0)
      CALL clear(1,1)
      CALL text(7,15,"Please enter the default event_cd code_value:")
      CALL accept(7,62,"################################;;CU")
      SET default_event_cd = cnvtreal(curaccept)
      SELECT INTO "nl:"
       cv.code_value
       FROM code_value cv
       WHERE cv.code_value=default_event_cd
        AND cv.code_set=72
        AND cv.active_ind=1
        AND cv.end_effective_dt_tm >= cnvtdatetime(sysdate)
       DETAIL
        default_event_cd_display = cv.display
       WITH counter
      ;end select
      IF (curqual > 0)
       SET validdefaulteventcd = 1
       CALL clear(1,1)
       CALL text(7,15,build2("Is this the correct event_cd: ",trim(default_event_cd_display,3)))
       CALL accept(8,15,"A;CU","Y")
       IF (curaccept != "Y")
        SET validdefaulteventcd = 0
        SET default_event_cd = 0.0
        SET default_event_cd_display = ""
       ELSE
        SET validdefaulteventcd = 1
       ENDIF
      ELSE
       CALL clear(1,1)
       CALL text(7,15,"The event_cd was not found! Try again?")
       CALL accept(8,15,"A;CU","Y")
       IF (curaccept != "Y")
        SET default_event_cd = 0.0
        SET default_event_cd_display = ""
        SET validdefaulteventcd = 1
        CALL clear(1,1)
        CALL text(7,15,"No valid event_cd entered, default event_cd will not be configured.")
        CALL text(8,15,"Press enter to continue.")
        CALL accept(9,15,"A;CU","")
       ENDIF
      ENDIF
    ENDWHILE
    CALL find_orgs_to_add(logicaldomainid)
    CALL clear(1,1)
    SET message = nowindow
    CALL echo("The following Organizations will have Org Defaults added:")
    FOR (echoorgs = 1 TO size(add_orgs->qual,5))
      IF ((add_orgs->qual[echoorgs].oid_ind=1))
       SET orgsdefaultsadded = 1
       CALL echo(build2(" ",add_orgs->qual[echoorgs].organization_name))
      ENDIF
    ENDFOR
    IF (orgsdefaultsadded=0)
     CALL echo(" None Found!")
    ENDIF
    CALL echo("")
    CALL echo("")
    CALL clear(1,1)
    CALL text(7,15,"Scroll up to view the rows that will be added. Continue? (Y/N)")
    CALL accept(8,15,"A;CU","Y")
    IF (cnvtupper(trim(curaccept))="Y")
     FOR (addorgs = 1 TO size(add_orgs->qual,5))
       IF ((add_orgs->qual[addorgs].oid_ind=1))
        CALL populate_org_default_req(add_orgs->qual[addorgs].organization_id)
       ENDIF
     ENDFOR
    ELSE
     CALL clear(1,1)
     CALL text(7,15,"NOT adding organization defaults. Press enter to continue:")
     CALL accept(8,15,"A;CU","")
    ENDIF
   ELSE
    CALL clear(1,1)
    SET message = nowindow
    CALL text(7,15,"Not adding organization defaults due to code_value issues. Resolve and try again"
     )
    CALL text(8,15,"Press enter to exit")
    CALL accept(9,15,"A;CU","")
   ENDIF
 END ;Subroutine
 SUBROUTINE (find_orgs_to_add(passed_users_logical_domain_id=f8) =c1)
   IF (validate(xds_document_info_type_cd)=0)
    DECLARE xds_document_info_type_cd = f8 WITH constant(uar_get_code_by("Meaning",355,"XDSDOCUMENT")
     )
   ENDIF
   IF (validate(facility_org_type_cd)=0)
    DECLARE facility_org_type_cd = f8 WITH constant(uar_get_code_by("Meaning",278,"FACILITY"))
   ENDIF
   IF (validate(oid_entity_type_org)=0)
    DECLARE oid_entity_type_org = vc WITH constant("ORGANIZATION")
   ENDIF
   DECLARE findorgnum = i4 WITH noconstant(0)
   SELECT INTO "nl:"
    o.organization_id
    FROM organization o,
     org_type_reltn otr,
     si_oid so
    PLAN (o
     WHERE o.logical_domain_id=passed_users_logical_domain_id
      AND  NOT ( EXISTS (
     (SELECT
      oi.organization_id
      FROM org_info oi
      WHERE oi.organization_id=o.organization_id
       AND oi.info_type_cd=xds_document_info_type_cd))))
     JOIN (otr
     WHERE otr.organization_id=o.organization_id
      AND otr.org_type_cd=facility_org_type_cd)
     JOIN (so
     WHERE (so.entity_id= Outerjoin(otr.organization_id))
      AND (so.entity_type= Outerjoin(oid_entity_type_org)) )
    DETAIL
     findorgnum += 1, stat = alterlist(add_orgs->qual,findorgnum), add_orgs->qual[findorgnum].
     organization_id = o.organization_id,
     add_orgs->qual[findorgnum].organization_name = o.org_name
     IF (((trim(so.oid_txt,3) != "") OR (trim(so.oid_txt,3) != null)) )
      add_orgs->qual[findorgnum].oid_ind = 1
     ELSE
      add_orgs->qual[findorgnum].oid_ind = 0
     ENDIF
    WITH counter
   ;end select
 END ;Subroutine
 SUBROUTINE (populate_org_default_req(temp_org_id=f8) =c1)
   IF (validate(document_status_submitted)=0)
    DECLARE document_status_submitted = vc WITH constant("Submitted")
   ENDIF
   IF (validate(document_status_approved)=0)
    DECLARE document_status_approved = vc WITH constant("Approved")
   ENDIF
   IF (validate(document_status_deprecated)=0)
    DECLARE document_status_deprecated = vc WITH constant("Deprecated")
   ENDIF
   IF (validate(approved_value_cd)=0)
    DECLARE approved_value_cd = f8 WITH constant(1.00)
   ENDIF
   IF (validate(deprecated_value_cd)=0)
    DECLARE deprecated_value_cd = f8 WITH constant(2.00)
   ENDIF
   IF (validate(default_value_numeric)=0)
    DECLARE default_value_numeric = i4 WITH constant(0)
   ENDIF
   IF (validate(days_to_retrieve_sub_info_type_cd)=0)
    DECLARE days_to_retrieve_sub_info_type_cd = f8 WITH constant(uar_get_code_by("Meaning",356,
      "DAYSTORETR"))
   ENDIF
   IF (validate(document_status_sub_info_type_cd)=0)
    DECLARE document_status_sub_info_type_cd = f8 WITH constant(uar_get_code_by("Meaning",356,
      "DOCUMENTSTAT"))
   ENDIF
   IF (validate(retrieve_doc_sub_info_type_cd)=0)
    DECLARE retrieve_doc_sub_info_type_cd = f8 WITH constant(uar_get_code_by("Meaning",356,
      "RETRIEVEDOC"))
   ENDIF
   IF (validate(parse_doc_sub_info_type_cd)=0)
    DECLARE parse_doc_sub_info_type_cd = f8 WITH constant(uar_get_code_by("Meaning",356,"PARSEDOC"))
   ENDIF
   IF (validate(retrieve_doc_value_cd)=0)
    DECLARE retrieve_doc_value_cd = f8 WITH constant(uar_get_code_by("Meaning",4002689,"RETRQUERY"))
   ENDIF
   IF (validate(parse_doc_value_cd)=0)
    DECLARE parse_doc_value_cd = f8 WITH constant(uar_get_code_by("Meaning",4002690,"PARSERETR"))
   ENDIF
   IF (validate(days_to_retrieve_info_text)=0)
    DECLARE days_to_retrieve_info_text = vc WITH constant("180")
   ENDIF
   IF (validate(days_to_retrieve_value_cd)=0)
    DECLARE days_to_retrieve_value_cd = f8 WITH constant(0.00)
   ENDIF
   IF (validate(default_document_type_sub_info_type_cd)=0)
    DECLARE default_document_type_sub_info_type_cd = f8 WITH constant(uar_get_code_by("Meaning",356,
      "DEFDOCTYPE"))
   ENDIF
   IF (validate(default_event_cd)=0)
    DECLARE default_event_cd = f8 WITH noconstant(0.00)
   ENDIF
   IF (validate(default_event_cd_display)=0)
    DECLARE default_event_cd_display = vc WITH noconstant("")
   ENDIF
   DECLARE addorgdefaultsnum = i4 WITH noconstant(0)
   SET stat = initrec(add_org_defaults_request)
   IF (stat=1)
    SET addorgdefaultsnum += 1
    SET stat = alterlist(add_org_defaults_request->qual,addorgdefaultsnum)
    SET add_org_defaults_request->qual[addorgdefaultsnum].organization_id = temp_org_id
    SET add_org_defaults_request->qual[addorgdefaultsnum].info_type_cd = xds_document_info_type_cd
    SET add_org_defaults_request->qual[addorgdefaultsnum].info_sub_type_cd =
    days_to_retrieve_sub_info_type_cd
    SET add_org_defaults_request->qual[addorgdefaultsnum].info_text = days_to_retrieve_info_text
    SET add_org_defaults_request->qual[addorgdefaultsnum].value_cd = days_to_retrieve_value_cd
    SET add_org_defaults_request->qual[addorgdefaultsnum].value_numeric = default_value_numeric
    SET addorgdefaultsnum += 1
    SET stat = alterlist(add_org_defaults_request->qual,addorgdefaultsnum)
    SET add_org_defaults_request->qual[addorgdefaultsnum].organization_id = temp_org_id
    SET add_org_defaults_request->qual[addorgdefaultsnum].info_type_cd = xds_document_info_type_cd
    SET add_org_defaults_request->qual[addorgdefaultsnum].info_sub_type_cd =
    document_status_sub_info_type_cd
    SET add_org_defaults_request->qual[addorgdefaultsnum].info_text = document_status_approved
    SET add_org_defaults_request->qual[addorgdefaultsnum].value_cd = approved_value_cd
    SET add_org_defaults_request->qual[addorgdefaultsnum].value_numeric = default_value_numeric
    SET addorgdefaultsnum += 1
    SET stat = alterlist(add_org_defaults_request->qual,addorgdefaultsnum)
    SET add_org_defaults_request->qual[addorgdefaultsnum].organization_id = temp_org_id
    SET add_org_defaults_request->qual[addorgdefaultsnum].info_type_cd = xds_document_info_type_cd
    SET add_org_defaults_request->qual[addorgdefaultsnum].info_sub_type_cd =
    document_status_sub_info_type_cd
    SET add_org_defaults_request->qual[addorgdefaultsnum].info_text = document_status_deprecated
    SET add_org_defaults_request->qual[addorgdefaultsnum].value_cd = deprecated_value_cd
    SET add_org_defaults_request->qual[addorgdefaultsnum].value_numeric = default_value_numeric
    SET addorgdefaultsnum += 1
    SET stat = alterlist(add_org_defaults_request->qual,addorgdefaultsnum)
    SET add_org_defaults_request->qual[addorgdefaultsnum].organization_id = temp_org_id
    SET add_org_defaults_request->qual[addorgdefaultsnum].info_type_cd = xds_document_info_type_cd
    SET add_org_defaults_request->qual[addorgdefaultsnum].info_sub_type_cd =
    retrieve_doc_sub_info_type_cd
    SET add_org_defaults_request->qual[addorgdefaultsnum].info_text = trim("",3)
    SET add_org_defaults_request->qual[addorgdefaultsnum].value_cd = retrieve_doc_value_cd
    SET add_org_defaults_request->qual[addorgdefaultsnum].value_numeric = default_value_numeric
    SET addorgdefaultsnum += 1
    SET stat = alterlist(add_org_defaults_request->qual,addorgdefaultsnum)
    SET add_org_defaults_request->qual[addorgdefaultsnum].organization_id = temp_org_id
    SET add_org_defaults_request->qual[addorgdefaultsnum].info_type_cd = xds_document_info_type_cd
    SET add_org_defaults_request->qual[addorgdefaultsnum].info_sub_type_cd =
    parse_doc_sub_info_type_cd
    SET add_org_defaults_request->qual[addorgdefaultsnum].info_text = trim("",3)
    SET add_org_defaults_request->qual[addorgdefaultsnum].value_cd = parse_doc_value_cd
    SET add_org_defaults_request->qual[addorgdefaultsnum].value_numeric = default_value_numeric
    IF (default_event_cd > 0.00)
     SET addorgdefaultsnum += 1
     SET stat = alterlist(add_org_defaults_request->qual,addorgdefaultsnum)
     SET add_org_defaults_request->qual[addorgdefaultsnum].organization_id = temp_org_id
     SET add_org_defaults_request->qual[addorgdefaultsnum].info_type_cd = xds_document_info_type_cd
     SET add_org_defaults_request->qual[addorgdefaultsnum].info_sub_type_cd =
     default_document_type_sub_info_type_cd
     SET add_org_defaults_request->qual[addorgdefaultsnum].info_text = trim(default_event_cd_display,
      3)
     SET add_org_defaults_request->qual[addorgdefaultsnum].value_cd = default_event_cd
     SET add_org_defaults_request->qual[addorgdefaultsnum].value_numeric = default_value_numeric
    ENDIF
   ELSE
    CALL clear(1,1)
    CALL text(7,15,"Couldn't clear record structure! Exiting program")
    CALL accept(8,15,"A;CU","")
    GO TO end_of_program
   ENDIF
   CALL add_org_defaults(1)
 END ;Subroutine
 SUBROUTINE (update_org_defaults_default_event_cd(users_logical_domain_id=f8) =c1)
   SET logicaldomainid = get_logical_domain_id(users_logical_domain_id)
   IF ((logicaldomainid=- (1)))
    GO TO new_res_xds_csv_menu
   ENDIF
   FREE RECORD add_org_defaults_request
   RECORD add_org_defaults_request(
     1 qual[*]
       2 organization_id = f8
       2 info_type_cd = f8
       2 info_sub_type_cd = f8
       2 info_text = vc
       2 value_cd = f8
       2 value_numeric = i4
   )
   FREE RECORD add_orgs
   RECORD add_orgs(
     1 qual[*]
       2 organization_id = f8
       2 organization_name = vc
       2 oid_ind = i4
   )
   DECLARE xds_document_info_type_cd = f8 WITH constant(uar_get_code_by("Meaning",355,"XDSDOCUMENT"))
   DECLARE days_to_retrieve_sub_info_type_cd = f8 WITH constant(uar_get_code_by("Meaning",356,
     "DAYSTORETR"))
   DECLARE document_status_sub_info_type_cd = f8 WITH constant(uar_get_code_by("Meaning",356,
     "DOCUMENTSTAT"))
   DECLARE retrieve_doc_sub_info_type_cd = f8 WITH constant(uar_get_code_by("Meaning",356,
     "RETRIEVEDOC"))
   DECLARE parse_doc_sub_info_type_cd = f8 WITH constant(uar_get_code_by("Meaning",356,"PARSEDOC"))
   DECLARE default_document_type_sub_info_type_cd = f8 WITH constant(uar_get_code_by("Meaning",356,
     "DEFDOCTYPE"))
   DECLARE archiving_indicator_sub_info_type_cd = f8 WITH constant(uar_get_code_by("Meaning",356,
     "ODMDARCHVIND"))
   DECLARE authorization_mode_sub_info_type_cd = f8 WITH constant(uar_get_code_by("Meaning",356,
     "ODMDAUTHMODE"))
   DECLARE report_template_sub_info_type_cd = f8 WITH constant(uar_get_code_by("Meaning",356,
     "ODMDRPTMPLID"))
   DECLARE retrieve_doc_value_cd = f8 WITH constant(uar_get_code_by("Meaning",4002689,"RETRQUERY"))
   DECLARE parse_doc_value_cd = f8 WITH constant(uar_get_code_by("Meaning",4002690,"PARSERETR"))
   DECLARE document_status_submitted = vc WITH constant("Submitted")
   DECLARE document_status_approved = vc WITH constant("Approved")
   DECLARE document_status_deprecated = vc WITH constant("Deprecated")
   DECLARE approved_value_cd = f8 WITH constant(1.00)
   DECLARE deprecated_value_cd = f8 WITH constant(2.00)
   DECLARE default_value_numeric = i4 WITH constant(0)
   DECLARE days_to_retrieve_info_text = vc WITH constant("180")
   DECLARE days_to_retrieve_value_cd = f8 WITH constant(0.00)
   DECLARE facility_org_type_cd = f8 WITH constant(uar_get_code_by("Meaning",278,"FACILITY"))
   DECLARE oid_entity_type_org = vc WITH constant("ORGANIZATION")
   DECLARE oid_entity_type_alias_pool = vc WITH constant("ALIAS_POOL")
   DECLARE orgsdefaultsadded = i2 WITH noconstant(0)
   DECLARE orgsdefaultsmissingoids = i2 WITH noconstant(0)
   DECLARE isvalid = i2 WITH noconstant(1)
   DECLARE isactive = i2 WITH noconstant(0)
   DECLARE default_event_cd = f8 WITH noconstant(0.0)
   DECLARE default_event_cd_display = vc WITH noconstant("")
   DECLARE validdefaulteventcd = i2 WITH noconstant(0)
   DECLARE findorgnum = i4 WITH noconstant(0)
   IF ( NOT (days_to_retrieve_sub_info_type_cd > 0))
    CALL clear(1,1)
    SET message = nowindow
    CALL text(7,15,
     "Code Value not returned for CDF Meaning of DAYSTORETR on codeset 356. Verify code value is active"
     )
    CALL text(8,15,"Press enter to continue")
    CALL accept(9,15,"A;CU","")
    SET isvalid = 0
   ENDIF
   IF ( NOT (document_status_sub_info_type_cd > 0))
    CALL clear(1,1)
    SET message = nowindow
    CALL text(7,15,
     "Code Value not returned for CDF Meaning of DOCUMENTSTAT on codeset 356. Verify code value is active"
     )
    CALL text(8,15,"Press enter to continue")
    CALL accept(9,15,"A;CU","")
    SET isvalid = 0
   ENDIF
   IF ( NOT (retrieve_doc_sub_info_type_cd > 0))
    CALL clear(1,1)
    SET message = nowindow
    CALL text(7,15,
     "Code Value not returned for CDF Meaning of RETRIEVEDOC on codeset 356. Verify code value is active"
     )
    CALL text(8,15,"Press enter to continue")
    CALL accept(9,15,"A;CU","")
    SET isvalid = 0
   ENDIF
   IF ( NOT (parse_doc_sub_info_type_cd > 0))
    CALL clear(1,1)
    SET message = nowindow
    CALL text(7,15,
     "Code Value not returned for CDF Meaning of PARSEDOC on codeset 356. Verify code value is active"
     )
    CALL text(8,15,"Press enter to continue")
    CALL accept(9,15,"A;CU","")
    SET isvalid = 0
   ENDIF
   IF ( NOT (retrieve_doc_value_cd > 0))
    CALL clear(1,1)
    SET message = nowindow
    CALL text(7,15,
     "Code Value not returned for CDF Meaning of RETRQUERY on codeset 4002689. Verify code value is active"
     )
    CALL text(8,15,"Press enter to continue")
    CALL accept(9,15,"A;CU","")
    SET isvalid = 0
   ENDIF
   IF ( NOT (parse_doc_value_cd > 0))
    CALL clear(1,1)
    SET message = nowindow
    CALL text(7,15,
     "Code Value not returned for CDF Meaning of PARSERETR on codeset 4002690. Verify code value is active"
     )
    CALL text(8,15,"Press enter to continue")
    CALL accept(9,15,"A;CU","")
    SET isvalid = 0
   ENDIF
   IF ( NOT (xds_document_info_type_cd > 0))
    CALL clear(1,1)
    SET message = nowindow
    CALL text(7,15,
     "Code Value not returned for CDF Meaning of XDSDOCUMENT on codeset 355. Verify code value is active"
     )
    CALL text(8,15,"Press enter to continue")
    CALL accept(9,15,"A;CU","")
    SET isvalid = 0
   ENDIF
   IF ( NOT (default_document_type_sub_info_type_cd > 0))
    SET isactive = 0
    SELECT INTO "nl:"
     cv.cdf_meaning, cv.active_ind
     FROM code_value cv
     PLAN (cv
      WHERE cv.code_set=356
       AND cv.cdf_meaning="DEFDOCTYPE")
     DETAIL
      isactive = cv.active_ind
     WITH nocounter
    ;end select
    IF (curqual > 0)
     CALL clear(1,1)
     SET message = nowindow
     CALL text(7,15,
      "Code Value not returned for CDF Meaning of DEFDOCTYPE on codeset 356. Verify code value is active"
      )
     CALL text(8,15,"Press enter to continue")
     CALL accept(9,15,"A;CU","")
     SET isvalid = 0
    ENDIF
   ENDIF
   IF ( NOT (archiving_indicator_sub_info_type_cd > 0))
    SET isactive = 0
    SELECT INTO "nl:"
     cv.cdf_meaning, cv.active_ind
     FROM code_value cv
     PLAN (cv
      WHERE cv.code_set=356
       AND cv.cdf_meaning="ODMDARCHVIND")
     DETAIL
      isactive = cv.active_ind
     WITH nocounter
    ;end select
    IF (curqual > 0)
     CALL clear(1,1)
     SET message = nowindow
     CALL text(7,15,
      "Code Value not returned for CDF Meaning of ODMDARCHVIND on codeset 356. Verify code value is active"
      )
     CALL text(8,15,"Press enter to continue")
     CALL accept(9,15,"A;CU","")
     SET isvalid = 0
    ENDIF
   ENDIF
   IF ( NOT (authorization_mode_sub_info_type_cd > 0))
    SET isactive = 0
    SELECT INTO "nl:"
     cv.cdf_meaning, cv.active_ind
     FROM code_value cv
     PLAN (cv
      WHERE cv.code_set=356
       AND cv.cdf_meaning="ODMDAUTHMODE")
     DETAIL
      isactive = cv.active_ind
     WITH nocounter
    ;end select
    IF (curqual > 0)
     CALL clear(1,1)
     SET message = nowindow
     CALL text(7,15,
      "Code Value not returned for CDF Meaning of ODMDAUTHMODE on codeset 356. Verify code value is active"
      )
     CALL text(8,15,"Press enter to continue")
     CALL accept(9,15,"A;CU","")
     SET isvalid = 0
    ENDIF
   ENDIF
   IF ( NOT (report_template_sub_info_type_cd > 0))
    SET isactive = 0
    SELECT INTO "nl:"
     cv.cdf_meaning, cv.active_ind
     FROM code_value cv
     PLAN (cv
      WHERE cv.code_set=356
       AND cv.cdf_meaning="ODMDRPTMPLID")
     DETAIL
      isactive = cv.active_ind
     WITH nocounter
    ;end select
    IF (curqual > 0)
     CALL clear(1,1)
     SET message = nowindow
     CALL text(7,15,
      "Code Value not returned for CDF Meaning of ODMDRPTMPLID on codeset 356. Verify code value is active"
      )
     CALL text(8,15,"Press enter to continue")
     CALL accept(9,15,"A;CU","")
     SET isvalid = 0
    ENDIF
   ENDIF
   IF (isvalid=1)
    WHILE (validdefaulteventcd=0)
      CALL clear(1,1)
      CALL text(7,15,"Please enter the default event_cd code_value:")
      CALL accept(7,62,"################################;;CU")
      SET default_event_cd = cnvtreal(curaccept)
      SELECT INTO "nl:"
       cv.code_value
       FROM code_value cv
       WHERE cv.code_value=default_event_cd
        AND cv.code_set=72
        AND cv.active_ind=1
        AND cv.end_effective_dt_tm >= cnvtdatetime(sysdate)
       DETAIL
        default_event_cd_display = cv.display
       WITH counter
      ;end select
      IF (curqual > 0)
       SET validdefaulteventcd = 1
       CALL clear(1,1)
       CALL text(7,15,build2("Is this the correct event_cd: ",trim(default_event_cd_display,3)))
       CALL accept(8,15,"A;CU","Y")
       IF (curaccept != "Y")
        SET validdefaulteventcd = 0
        SET default_event_cd = 0.0
        SET default_event_cd_display = ""
       ELSE
        SET validdefaulteventcd = 1
       ENDIF
      ELSE
       CALL clear(1,1)
       CALL text(7,15,"The event_cd was not found! Try again?")
       CALL accept(8,15,"A;CU","Y")
       IF (curaccept != "Y")
        SET default_event_cd = 0.0
        SET default_event_cd_display = ""
        SET validdefaulteventcd = 1
        CALL clear(1,1)
        CALL text(7,15,"No valid event_cd entered, default event_cd will not be configured.")
        CALL text(8,15,"Press enter to Exit.")
        CALL accept(9,15,"A;CU","")
        GO TO new_res_xds_res_imp_auto_menu
       ENDIF
      ENDIF
    ENDWHILE
    SELECT DISTINCT INTO "nl:"
     oi.organization_id
     FROM org_info oi,
      organization o
     PLAN (oi
      WHERE oi.info_type_cd=xds_document_info_type_cd
       AND  NOT ( EXISTS (
      (SELECT
       oi2.organization_id
       FROM org_info oi2
       WHERE oi2.organization_id=oi.organization_id
        AND oi2.info_sub_type_cd=default_document_type_sub_info_type_cd))))
      JOIN (o
      WHERE o.organization_id=oi.organization_id
       AND o.logical_domain_id=logicaldomainid)
     DETAIL
      findorgnum += 1, stat = alterlist(add_orgs->qual,findorgnum), add_orgs->qual[findorgnum].
      organization_id = o.organization_id,
      add_orgs->qual[findorgnum].organization_name = o.org_name
     WITH counter
    ;end select
    CALL clear(1,1)
    SET message = nowindow
    CALL echo(
     "The following Organizations Org Defaults have not been configured with the Default Event_CD:")
    FOR (echoorgs = 1 TO size(add_orgs->qual,5))
     SET orgsdefaultsadded = 1
     CALL echo(build2(" ",add_orgs->qual[echoorgs].organization_name))
    ENDFOR
    IF (orgsdefaultsadded=0)
     CALL echo(" None Found!")
    ENDIF
    CALL echo("")
    CALL echo("")
    CALL clear(1,1)
    CALL text(7,15,"Scroll up to view the rows that will be added. Continue? (Y/N)")
    CALL accept(8,15,"A;CU","Y")
    IF (cnvtupper(trim(curaccept))="Y")
     FOR (addorgs = 1 TO size(add_orgs->qual,5))
       DECLARE addorgdefaultsnum = i4 WITH noconstant(0)
       SET stat = initrec(add_org_defaults_request)
       IF (stat=1)
        IF (default_event_cd > 0.00)
         SET addorgdefaultsnum += 1
         SET stat = alterlist(add_org_defaults_request->qual,addorgdefaultsnum)
         SET add_org_defaults_request->qual[addorgdefaultsnum].organization_id = add_orgs->qual[
         addorgs].organization_id
         SET add_org_defaults_request->qual[addorgdefaultsnum].info_type_cd =
         xds_document_info_type_cd
         SET add_org_defaults_request->qual[addorgdefaultsnum].info_sub_type_cd =
         default_document_type_sub_info_type_cd
         SET add_org_defaults_request->qual[addorgdefaultsnum].info_text = trim(
          default_event_cd_display,3)
         SET add_org_defaults_request->qual[addorgdefaultsnum].value_cd = default_event_cd
         SET add_org_defaults_request->qual[addorgdefaultsnum].value_numeric = default_value_numeric
        ENDIF
       ELSE
        CALL clear(1,1)
        CALL text(7,15,"Couldn't clear record structure! Exiting program")
        CALL accept(8,15,"A;CU","")
        GO TO end_of_program
       ENDIF
       CALL add_org_defaults(1)
     ENDFOR
    ELSE
     CALL clear(1,1)
     CALL text(7,15,"NOT adding organization defaults. Press enter to continue:")
     CALL accept(8,15,"A;CU","")
    ENDIF
   ELSE
    CALL clear(1,1)
    SET message = nowindow
    CALL text(7,15,"Not adding organization defaults due to code_value issues. Resolve and try again"
     )
    CALL text(8,15,"Press enter to exit")
    CALL accept(9,15,"A;CU","")
   ENDIF
 END ;Subroutine
 SUBROUTINE add_org_defaults(dummy_var)
  EXECUTE sim_add_organization_info  WITH replace("REQUEST","ADD_ORG_DEFAULTS_REQUEST")
  COMMIT
 END ;Subroutine
 SUBROUTINE display_org_defaults_status(dummy_var)
   CALL clear(1,1)
   SET message = nowindow
   CALL echo("The following Organizations Org Defaults were configured:")
   FOR (echoorgs = 1 TO size(add_orgs->qual,5))
     IF ((add_orgs->qual[echoorgs].oid_ind=1))
      SET orgsdefaultsadded = 1
      CALL echo(build2(" ",add_orgs->qual[echoorgs].organization_name))
     ENDIF
   ENDFOR
   IF (orgsdefaultsadded=0)
    CALL echo(" None Found!")
   ENDIF
   CALL echo("")
   CALL echo("")
   CALL echo(
    "The following Organizations were not configured since they did not have OIDs associated:")
   FOR (echoorgs = 1 TO size(add_orgs->qual,5))
     IF ((add_orgs->qual[echoorgs].oid_ind=0))
      SET orgsdefaultsmissingoids = 1
      CALL echo(build2(" ",add_orgs->qual[echoorgs].organization_name))
     ENDIF
   ENDFOR
   IF (orgsdefaultsmissingoids=0)
    CALL echo(" None Found!")
   ENDIF
   CALL echo("")
   CALL echo("")
   CALL echo("Please review output from above and press enter to continue!")
   CALL accept(8,15,"A;CU","")
 END ;Subroutine
 SUBROUTINE (get_logical_domain_id(current_users_ld=f8) =f8)
   DECLARE validld = i1 WITH noconstant(0)
   DECLARE getlogicaldomainid = f8 WITH noconstant(current_users_ld)
   DECLARE mnemonicld = vc WITH noconstant("")
   WHILE (validld=0)
     IF ( NOT ((getlogicaldomainid > - (1))))
      CALL clear(1,1)
      CALL text(7,15,"Please enter the logical_domain_id:")
      CALL accept(7,51,"##############;;CU","")
      SET getlogicaldomainid = cnvtint(curaccept)
     ENDIF
     SELECT INTO "nl:"
      ld.logical_domain_id, ld.mnemonic
      FROM logical_domain ld
      PLAN (ld
       WHERE ld.logical_domain_id=getlogicaldomainid
        AND (ld.logical_domain_id > - (1)))
      DETAIL
       IF (ld.logical_domain_id=0)
        mnemonicld = "Default Logical Domain"
       ELSE
        mnemonicld = ld.mnemonic
       ENDIF
      WITH counter
     ;end select
     IF (curqual > 0)
      CALL clear(1,1)
      CALL text(7,15,"Is this the correct Mnemonic? ")
      CALL text(7,45,mnemonicld)
      CALL accept(8,15,"A;CU","Y")
      IF (curaccept="Y")
       SET validld = 1
       RETURN(cnvtint(getlogicaldomainid))
      ELSE
       SET getlogicaldomainid = - (1)
      ENDIF
     ELSE
      CALL clear(1,1)
      CALL text(7,15,"Logical_domain_id was not found! Try again?")
      CALL accept(7,59,"A;CU","Y")
      SET getlogicaldomainid = - (1)
      IF (curaccept != "Y")
       RETURN(- (1))
      ENDIF
     ENDIF
   ENDWHILE
 END ;Subroutine
 SUBROUTINE (get_user_logical_domain(personid=f8) =f8)
   DECLARE getuserld = f8 WITH noconstant(0.0)
   SELECT INTO "nl:"
    pr.logical_domain_id
    FROM prsnl pr
    PLAN (pr
     WHERE pr.person_id=personid)
    DETAIL
     getuserld = pr.logical_domain_id
    WITH nocounter
   ;end select
   RETURN(cnvtint(getuserld))
 END ;Subroutine
 SUBROUTINE (begin_add_system_org_reltn(users_logical_domain_id=f8,add_system_org_type=i2) =c1)
   RECORD add_system_org_reltn_request(
     1 qual[*]
       2 contributor_system_cd = f8
       2 organization_id = f8
       2 organization_name = vc
       2 alias_pool_cd = f8
       2 primary_ind = i2
   )
   IF (validate(xds_document_info_type_cd)=0)
    DECLARE xds_document_info_type_cd = f8 WITH constant(uar_get_code_by("Meaning",355,"XDSDOCUMENT")
     )
   ENDIF
   IF (validate(facility_org_type_cd)=0)
    DECLARE facility_org_type_cd = f8 WITH constant(uar_get_code_by("Meaning",278,"FACILITY"))
   ENDIF
   IF (validate(oid_entity_type_org)=0)
    DECLARE oid_entity_type_org = vc WITH constant("ORGANIZATION")
   ENDIF
   IF (validate(oid_entity_type_alias_pool)=0)
    DECLARE oid_entity_type_alias_pool = vc WITH constant("ALIAS_POOL")
   ENDIF
   IF (validate(ressystemorgtype)=0)
    DECLARE ressystemorgtype = i2 WITH constant(1)
   ENDIF
   DECLARE findorgnum = i4 WITH noconstant(0)
   DECLARE systemorgreltnprimaryind = i4 WITH noconstant(0)
   DECLARE healthexchangepatientidentifiercd = f8 WITH constant(uar_get_code_by("DisplayKey",4,
     "HEALTHEXCHANGEPATIENTIDENTIFIER"))
   SET logicaldomainid = get_logical_domain_id(users_logical_domain_id)
   IF ((logicaldomainid=- (1)))
    GO TO new_res_xds_csv_menu
   ENDIF
   IF (validate(communitycontributorsystemdef)=0)
    DECLARE communitycontributorsystemdef = vc WITH constant("AD_RES_DEFAULT")
   ENDIF
   DECLARE communitycontributorsystemcd = f8 WITH noconstant(0.0)
   DECLARE primarypersonaliaspoolcd = f8 WITH noconstant(0.0)
   SET communitycontributorsystemcd = get_contributor_system_cd(communitycontributorsystemdef)
   IF (communitycontributorsystemcd=0.0)
    GO TO new_res_xds_csv_menu
   ENDIF
   SET primarypersonaliaspoolcd = get_alias_pool_cd(logicaldomainid)
   IF (primarypersonaliaspoolcd=0.0)
    GO TO new_res_xds_csv_menu
   ENDIF
   SELECT INTO "nl:"
    so.oid_txt
    FROM si_oid so
    PLAN (so
     WHERE so.entity_id=primarypersonaliaspoolcd
      AND so.entity_type=oid_entity_type_alias_pool)
    WITH counter
   ;end select
   IF ( NOT (curqual > 0))
    CALL clear(1,1)
    CALL text(7,15,
     "Alias Pool does not have an OID assigned. Please add an OID and try again (press enter to exit)!"
     )
    CALL accept(8,15,"A;CU","")
    GO TO new_res_xds_csv_menu
   ENDIF
   CALL clear(1,1)
   CALL text(7,15,"Set Primary Indicator to 1? (Y/N)")
   CALL accept(7,59,"A;CU","Y")
   IF (cnvtupper(trim(curaccept))="Y")
    SET systemorgreltnprimaryind = 1
   ELSE
    SET systemorgreltnprimaryind = 0
   ENDIF
   IF (systemorgreltnprimaryind=1)
    SELECT DISTINCT INTO "nl:"
     o.organization_id, o.org_name, oapr.alias_entity_alias_type_cd
     FROM organization o,
      org_type_reltn otr,
      org_alias_pool_reltn oapr,
      si_oid so
     PLAN (o
      WHERE o.logical_domain_id=logicaldomainid
       AND  NOT ( EXISTS (
      (SELECT
       ssor.organization_id
       FROM si_system_org_reltn ssor
       WHERE ssor.organization_id=o.organization_id
        AND ssor.contributor_system_cd=communitycontributorsystemcd
        AND ssor.primary_ind=1))))
      JOIN (otr
      WHERE otr.organization_id=o.organization_id
       AND otr.org_type_cd=facility_org_type_cd)
      JOIN (oapr
      WHERE (oapr.organization_id= Outerjoin(otr.organization_id))
       AND (oapr.alias_entity_alias_type_cd= Outerjoin(healthexchangepatientidentifiercd)) )
      JOIN (so
      WHERE (so.entity_id= Outerjoin(otr.organization_id))
       AND (so.entity_type= Outerjoin(oid_entity_type_org)) )
     DETAIL
      IF (((trim(so.oid_txt,3) != "") OR (trim(so.oid_txt,3) != null)) )
       findorgnum += 1, stat = alterlist(add_system_org_reltn_request->qual,findorgnum),
       add_system_org_reltn_request->qual[findorgnum].contributor_system_cd =
       communitycontributorsystemcd,
       add_system_org_reltn_request->qual[findorgnum].organization_id = o.organization_id,
       add_system_org_reltn_request->qual[findorgnum].organization_name = o.org_name,
       add_system_org_reltn_request->qual[findorgnum].alias_pool_cd = primarypersonaliaspoolcd,
       add_system_org_reltn_request->qual[findorgnum].primary_ind = systemorgreltnprimaryind
      ENDIF
     WITH counter
    ;end select
   ELSEIF (systemorgreltnprimaryind=0)
    SELECT DISTINCT INTO "nl:"
     o.organization_id
     FROM organization o,
      org_type_reltn otr,
      si_oid so
     PLAN (o
      WHERE o.logical_domain_id=logicaldomainid
       AND  NOT ( EXISTS (
      (SELECT
       ssor.organization_id
       FROM si_system_org_reltn ssor
       WHERE ssor.organization_id=o.organization_id
        AND ssor.contributor_system_cd=communitycontributorsystemcd
        AND ssor.alias_pool_cd=primarypersonaliaspoolcd
        AND ssor.primary_ind=0))))
      JOIN (otr
      WHERE otr.organization_id=o.organization_id
       AND otr.org_type_cd=facility_org_type_cd)
      JOIN (so
      WHERE (so.entity_id= Outerjoin(otr.organization_id))
       AND (so.entity_type= Outerjoin(oid_entity_type_org)) )
     DETAIL
      IF (((trim(so.oid_txt,3) != "") OR (trim(so.oid_txt,3) != null)) )
       findorgnum += 1, stat = alterlist(add_system_org_reltn_request->qual,findorgnum),
       add_system_org_reltn_request->qual[findorgnum].contributor_system_cd =
       communitycontributorsystemcd,
       add_system_org_reltn_request->qual[findorgnum].organization_id = o.organization_id,
       add_system_org_reltn_request->qual[findorgnum].organization_name = o.org_name,
       add_system_org_reltn_request->qual[findorgnum].alias_pool_cd = primarypersonaliaspoolcd,
       add_system_org_reltn_request->qual[findorgnum].primary_ind = systemorgreltnprimaryind
      ENDIF
     WITH counter
    ;end select
   ENDIF
   CALL clear(1,1)
   SET message = nowindow
   IF (size(add_system_org_reltn_request->qual,5) > 0)
    CALL echo("The following rows will be added:")
    CALL echo("     Organizations:")
    FOR (addsysorgreltnum = 1 TO size(add_system_org_reltn_request->qual,5))
      CALL echo(build2("                    ",add_system_org_reltn_request->qual[addsysorgreltnum].
        organization_name))
    ENDFOR
    CALL echo("")
    CALL echo("")
    CALL echo(build2("Contributor System: ",trim(uar_get_code_display(communitycontributorsystemcd)))
     )
    CALL echo("")
    CALL echo("")
    CALL echo(build2("        Alias Pool: ",trim(uar_get_code_display(primarypersonaliaspoolcd))))
    CALL echo("")
    CALL echo("")
    CALL echo(build2("  Primary Indicator: ",trim(cnvtstring(systemorgreltnprimaryind))))
    CALL clear(1,1)
    CALL text(7,15,"Scroll up to view the rows that will be added. Continue? (Y/N)")
    CALL accept(8,15,"A;CU","Y")
    IF (cnvtupper(trim(curaccept))="Y")
     CALL add_system_org_reltn(1)
    ELSE
     GO TO new_res_xds_csv_menu
    ENDIF
   ELSE
    CALL text(7,15,"No new Orgs/Systems/Pool relationships were found! Press enter to exit")
    CALL accept(8,15,"A;CU","")
    GO TO new_res_xds_csv_menu
   ENDIF
 END ;Subroutine
 SUBROUTINE add_system_org_reltn(dummy_var)
  EXECUTE sim_add_system_org_reltn  WITH replace("REQUEST","ADD_SYSTEM_ORG_RELTN_REQUEST")
  COMMIT
 END ;Subroutine
 SUBROUTINE (get_alias_pool_cd(passed_alias_pool_ld=f8) =f8)
   DECLARE validaliaspool = i2 WITH noconstant(0)
   DECLARE getaliaspoolname = vc WITH noconstant("")
   DECLARE getaliaspoolnamekey = vc WITH noconstant("")
   DECLARE getaliaspoolcd = f8 WITH noconstant(0.0)
   DECLARE aliaspoolcodeset = i4 WITH constant(263)
   DECLARE alias_pool_type_mrn_cd = f8 WITH constant(uar_get_code_by("Meaning",4,"MRN"))
   DECLARE defaultaliaspool = vc WITH noconstant("")
   DECLARE tempaliaspoolcount = i4 WITH noconstant(0)
   SELECT DISTINCT INTO "nl:"
    oapr.alias_pool_cd, num_found = count(*)
    FROM org_alias_pool_reltn oapr
    WHERE oapr.organization_id IN (
    (SELECT
     o.organization_id
     FROM organization o
     WHERE o.logical_domain_id=passed_alias_pool_ld))
     AND oapr.alias_entity_alias_type_cd=alias_pool_type_mrn_cd
    GROUP BY oapr.alias_pool_cd
    ORDER BY num_found DESC
    DETAIL
     IF (num_found > tempaliaspoolcount)
      defaultaliaspool = uar_get_code_display(oapr.alias_pool_cd)
     ENDIF
    WITH nocounter
   ;end select
   WHILE (validaliaspool=0)
     CALL clear(1,1)
     CALL text(7,15,"Please enter the Alias Pool display name:")
     CALL accept(7,51,"###########################################;;CU",defaultaliaspool)
     SET getaliaspoolname = trim(curaccept)
     SET getaliaspoolnamekey = cnvtupper(cnvtalphanum(getaliaspoolname))
     SELECT INTO "nl:"
      ap.alias_pool_cd
      FROM code_value cv,
       alias_pool ap
      PLAN (cv
       WHERE cv.code_set=aliaspoolcodeset
        AND cv.display_key=getaliaspoolnamekey
        AND cv.active_ind=1)
       JOIN (ap
       WHERE ap.alias_pool_cd=cv.code_value
        AND ap.alias_pool_cd > 0.0
        AND ap.logical_domain_id=passed_alias_pool_ld)
      DETAIL
       getaliaspoolcd = ap.alias_pool_cd
      WITH counter
     ;end select
     IF (curqual > 0)
      SET validaliaspool = 1
      RETURN(getaliaspoolcd)
     ELSE
      CALL clear(1,1)
      CALL text(7,15,"Alias Pool was not found! Try again?")
      CALL accept(7,59,"A;CU","Y")
      IF (curaccept != "Y")
       RETURN(0.0)
      ENDIF
     ENDIF
   ENDWHILE
 END ;Subroutine
 SUBROUTINE (add_personality_trait_to_request(personality_name=vc,personality_value=vc) =c1)
   IF (validate(oenctl_add_procinfo_size)=0)
    DECLARE oenctl_add_procinfo_size = i4 WITH noconstant(0)
   ENDIF
   SET oenctl_add_procinfo_size = (size(oenctl_add_procinfo_request->trait_list,5)+ 1)
   SET stat = alterlist(oenctl_add_procinfo_request->trait_list,oenctl_add_procinfo_size)
   SET oenctl_add_procinfo_request->trait_list[oenctl_add_procinfo_size].name = trim(personality_name
    )
   SET oenctl_add_procinfo_request->trait_list[oenctl_add_procinfo_size].value = trim(
    personality_value)
 END ;Subroutine
 SUBROUTINE add_legacy_interface(dummy_var)
   DECLARE nodecount = i2 WITH noconstant(0)
   DECLARE nodeselected = i2 WITH noconstant(0)
   DECLARE setnodename = vc WITH noconstant("")
   DECLARE nodefound = i2 WITH noconstant(0)
   DECLARE executeimportinterface = i2 WITH noconstant(0)
   DECLARE temp_interface_pid = i4 WITH noconstant(0)
   DECLARE temp_interface_scp = i4 WITH noconstant(0)
   DECLARE temp_interface_name = vc WITH noconstant("")
   FREE RECORD interface_total_rec
   RECORD interface_total_rec(
     1 multinodeflag = i2
     1 importnodename = vc
     1 importnodeavailable = i2
     1 total_interfaces = i4
     1 node[*]
       2 nodename = vc
       2 interfacecount = i4
       2 roomavailable = i2
   )
   SELECT INTO "nl:"
    ol.value
    FROM oen_personality ol
    PLAN (ol
     WHERE ol.interfaceid=997
      AND ol.name="MULTINODE_FLAG")
    DETAIL
     interface_total_rec->multinodeflag = cnvtint(ol.value)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    ol.value
    FROM oen_personality ol
    PLAN (ol
     WHERE ol.interfaceid=997
      AND ol.name="PRIMARY_INTERFACE_NODE")
    DETAIL
     interface_total_rec->importnodename = cnvtupper(ol.value)
    WITH nocounter
   ;end select
   SET interface_total_rec->importnodeavailable = 1
   IF ((interface_total_rec->importnodeavailable=1))
    SELECT INTO "nl:"
     op.proc_name
     FROM oen_procinfo op
     PLAN (op
      WHERE trim(cnvtupper(op.proc_name)) IN (trim(cnvtupper(oenctl_add_procinfo_request->proc_name))
      ))
     WITH counter
    ;end select
    IF (curqual=0)
     CALL clear(1,1)
     SET message = nowindow
     CALL echo(build2("Importing ",oenctl_add_procinfo_request->proc_name))
     SET executeimportinterface = 1
     IF (size(trim(oenctl_add_procinfo_request->proc_desc)) < 1)
      SET oenctl_add_procinfo_request->proc_desc = trim("DEFAULT DESC")
     ENDIF
     IF ((interface_total_rec->multinodeflag=0))
      SET oenctl_add_procinfo_request->primary_node = trim("")
     ELSE
      SET oenctl_add_procinfo_request->primary_node = trim(interface_total_rec->importnodename)
     ENDIF
    ELSE
     CALL text(7,15,"Interface already exists! Press enter to continue")
     CALL accept(8,15,"A;CU","")
     SET executeimportinterface = 0
    ENDIF
    IF (executeimportinterface=1)
     DECLARE stats_binding = vc
     DECLARE appid = i4
     DECLARE taskid = i4
     DECLARE reqid = i4
     DECLARE happ = i4
     DECLARE htask = i4
     DECLARE hreq = i4
     DECLARE hstep = i4
     DECLARE hitem = i4
     DECLARE hrep = i4
     DECLARE hsrvreq = i4
     SET stats_binding = ""
     SET appid = 1241002
     SET taskid = 1242002
     SET reqid = 1243204
     SET perform_status = "F"
     SET iret = uar_crmbeginapp(appid,happ)
     IF (iret=0)
      SET iret = uar_crmbegintask(happ,taskid,htask)
      IF (iret=0)
       SET iret = uar_crmbeginreq(htask,"oenctl_add_procinfo",reqid,hstep)
       IF (iret=0)
        SET hreq = uar_crmgetrequest(hstep)
        IF (hreq != 0)
         CALL uar_srvsetstring(hreq,"proc_name",nullterm(oenctl_add_procinfo_request->proc_name))
         CALL uar_srvsetstring(hreq,"proc_desc",nullterm(oenctl_add_procinfo_request->proc_desc))
         CALL uar_srvsetstring(hreq,"service",nullterm(oenctl_add_procinfo_request->service))
         CALL uar_srvsetstring(hreq,"user_name",nullterm(oenctl_add_procinfo_request->user_name))
         IF ((oenctl_add_procinfo_request->primary_node != ""))
          CALL uar_srvsetstring(hreq,"primary_node",nullterm(oenctl_add_procinfo_request->
            primary_node))
         ENDIF
         FOR (addtrait = 1 TO size(oenctl_add_procinfo_request->trait_list,5))
           SET trait_list = uar_srvadditem(hreq,"trait_list")
           SET stat = uar_srvsetstring(trait_list,"name",nullterm(oenctl_add_procinfo_request->
             trait_list[addtrait].name))
           SET stat = uar_srvsetstring(trait_list,"value",nullterm(oenctl_add_procinfo_request->
             trait_list[addtrait].value))
         ENDFOR
         IF (stats_binding != "")
          SET iret = uar_crmperformas(hstep,nullterm(stats_binding))
         ELSE
          SET iret = uar_crmperform(hstep)
         ENDIF
         IF (iret != 0)
          CALL text(24,5,concat("CRM perform failed:",build(iret)))
         ELSE
          SET perform_status = "S"
         ENDIF
         SET hreq = 0
        ELSE
         CALL text(24,5,concat("CrmGetoenctl_add_procinfo_request failed:",build(iret)))
        ENDIF
       ELSE
        CALL text(24,5,concat("Begin task unsuccessful: ",build(iret)))
       ENDIF
       CALL uar_crmendtask(htask)
       SET htask = 0
      ELSE
       CALL text(24,5,concat("Unsuccessful begin task: ",build(iret)))
      ENDIF
      CALL uar_crmendapp(happ)
      SET happ = 0
     ELSE
      CALL text(24,5,concat("Begin app failed with code: ",build(iret)))
     ENDIF
     SET hrep = uar_crmgetreply(hstep)
     CALL echo(build("proc_id          [",uar_srvgetulong(hrep,"proc_id"),"]"))
     CALL echo(build("query_status     [",uar_srvgetulong(hrep,"query_status"),"]"))
     IF (uar_srvgetulong(hrep,"query_status") != 1)
      SET message = nowindow
      FOR (repeatecho = 1 TO 10)
        CALL echo(" ")
      ENDFOR
      CALL clear(1,1)
      CALL clear(1,1)
      CALL text(7,15,"Import failed! Scroll up to see error.")
      CALL text(8,15,"View Requests (Y/N)?")
      CALL accept(9,15,"A;CU","Y")
      IF (curaccept="Y")
       CALL clear(1,1)
       CALL echorecord(interface_total_rec)
       CALL clear(1,1)
       CALL echorecord(oenctl_add_procinfo_request)
       CALL clear(1,1)
       CALL text(8,15,"Scroll up to see requests. Press enter to exit.")
       CALL accept(9,15,"A;CU","")
      ENDIF
      GO TO new_res_xds_csv_menu
     ELSE
      SET temp_interface_pid = uar_srvgetulong(hrep,"proc_id")
      SELECT INTO "nl:"
       op.interfaceid, op.scp_eid, op.proc_name
       FROM oen_procinfo op
       WHERE op.interfaceid=temp_interface_pid
       DETAIL
        temp_interface_scp = op.scp_eid, temp_interface_name = op.proc_name
       WITH counter
      ;end select
      SET message = nowindow
      CALL clear(1,1)
      CALL text(7,15,"Import Successful!")
      CALL text(8,15,build2("Interface Name: ",temp_interface_name))
      CALL text(9,15,build2("  Interface ID: ",trim(cnvtstring(temp_interface_pid),3)))
      CALL text(10,15,build2("     SCP Entry: ",trim(cnvtstring(temp_interface_scp),3)))
      CALL text(12,15,"Press enter to continue!")
      CALL accept(13,15,"A;CU","")
     ENDIF
    ENDIF
   ELSE
    CALL clear(1,1)
    CALL text(7,15,
     "There is no room to add new interfaces! Please delete one or more interfaces and try again!")
    CALL accept(8,15,"A;CU","")
    GO TO new_res_xds_csv_menu
   ENDIF
 END ;Subroutine
 SUBROUTINE import_res_adt_interface(dummy_var)
   FREE RECORD oenctl_add_procinfo_request
   RECORD oenctl_add_procinfo_request(
     1 proc_id = i4
     1 proc_name = vc
     1 proc_desc = vc
     1 proc_path = vc
     1 proc_parm = vc
     1 service = vc
     1 user_name = vc
     1 trait_list[*]
       2 name = vc
       2 value = vc
     1 std_interface_id = i4
     1 primary_node = vc
   )
   DECLARE prod_import = c1 WITH noconstant("")
   DECLARE import_mod_obj = c1 WITH noconstant("")
   DECLARE packesocd = f8 WITH noconstant(0.0)
   DECLARE pack1modobj = vc WITH noconstant(" ")
   DECLARE res_leg_adt_port = vc WITH constant("13999")
   DECLARE res_leg_adt_ip = vc WITH constant("0.0.0.0")
   DECLARE res_leg_adt_port_txt = vc WITH constant(
    "Enter Port (the port the adt comchannel will be listening on):")
   DECLARE res_leg_adt_ip_txt = vc WITH constant(
    "Enter IP (use default value if the adt comchannel is on the same node):")
   DECLARE res_adt_default_sys = vc WITH constant("XDS_ADT_SYSTEM")
   IF (validate(communitycontributorsystemdef)=0)
    DECLARE communitycontributorsystemdef = vc WITH constant("XDS_CONTRIBUTOR_SYSTEM")
   ENDIF
   DECLARE res_adt_proc_name = vc WITH constant("RESONANCE_PIX_ADT_OUT_01")
   DECLARE res_adt_proc_name_txt = vc WITH constant("Enter interface name:")
   DECLARE res_adt_proc_desc = vc WITH constant("ADTs out to Resonance PIX Manager")
   DECLARE productionflag = vc WITH noconstant("")
   DECLARE remotehost = vc WITH noconstant("")
   DECLARE remoteport = vc WITH noconstant("")
   SET packesocd = get_contributor_system_cd(res_adt_default_sys)
   SET remotehost = get_file_name(res_leg_adt_ip_txt,res_leg_adt_ip)
   SET remoteport = get_file_name(res_leg_adt_port_txt,res_leg_adt_port)
   CALL clear(1,1)
   CALL text(7,15,"Import the latest version of the XDS_MOD_OBJ?:")
   CALL accept(8,15,"#;;C","Y")
   SET import_mod_obj = cnvtupper(curaccept)
   IF (cnvtupper(import_mod_obj)="Y")
    SET pack1modobj = import_hub_resonance_mod_obj_script(1)
    IF (trim(pack1modobj,3)="")
     SET pack1modobj = " "
    ENDIF
   ENDIF
   IF (packesocd > 0.0)
    SET oenctl_add_procinfo_request->proc_name = get_file_name(res_adt_proc_name_txt,
     res_adt_proc_name)
    CALL clear(1,1)
    CALL text(7,15,"Prod build?:")
    CALL accept(8,15,"#;;C","N")
    SET prod_import = cnvtupper(curaccept)
    IF (cnvtupper(prod_import)="Y")
     SET productionflag = "Y"
    ELSE
     SET productionflag = "N"
    ENDIF
    SET oenctl_add_procinfo_request->proc_desc = res_adt_proc_desc
    SET oenctl_add_procinfo_request->service = "Outbound"
    SET oenctl_add_procinfo_request->user_name = "Imported"
    CALL add_personality_trait_to_request("ENABLEOENSTATUS","1")
    CALL add_personality_trait_to_request("PACKESO",cnvtstring(packesocd))
    CALL add_personality_trait_to_request("PRODUCTION",productionflag)
    CALL add_personality_trait_to_request("REMOTEHOST",remotehost)
    CALL add_personality_trait_to_request("PORT",remoteport)
    CALL add_personality_trait_to_request("QUEUEQUOTA","100000")
    CALL add_personality_trait_to_request("REMOTE_ACKNOWLEDGMENT","ACK")
    CALL add_personality_trait_to_request("TRACE_LEVEL","2")
    CALL add_personality_trait_to_request("CONNECTLISTEN","I")
    CALL add_personality_trait_to_request("STARTOFMESSAGE","<011>")
    CALL add_personality_trait_to_request("ENDOFMESSAGE","<028><013>")
    CALL add_personality_trait_to_request("ESI_FIELD",
     "PERSON_GROUP.PAT_GROUP.PID.PATIENT_ID_EXT.PAT_ID")
    CALL add_personality_trait_to_request("STEPS","OGSIVC")
    CALL add_personality_trait_to_request("TRANSACTION_LOG","Y")
    CALL add_personality_trait_to_request("PACK1",pack1modobj)
    CALL add_personality_trait_to_request("PACK3"," ")
    CALL add_personality_trait_to_request("I11","I")
    CALL add_legacy_interface(1)
   ELSE
    CALL clear(1,1)
    CALL text(7,15,"Contributor System wasn't found! Press enter to exit!")
    CALL accept(8,15,"A;CU","")
   ENDIF
 END ;Subroutine
 SUBROUTINE import_oen_scripts(dummy_var)
  SELECT INTO "nl:"
   os.script_name
   FROM oen_script os
   PLAN (os
    WHERE cnvtupper(trim(os.script_name))=cnvtupper(trim(oenctl_add_script_request->sc_name)))
   WITH counter
  ;end select
  IF (curqual=0)
   DECLARE stats_binding = vc
   DECLARE appid = i4
   DECLARE taskid = i4
   DECLARE reqid = i4
   DECLARE happ = i4
   DECLARE htask = i4
   DECLARE hreq = i4
   DECLARE hstep = i4
   DECLARE hitem = i4
   DECLARE hrep = i4
   DECLARE hsrvreq = i4
   SET stats_binding = ""
   SET appid = 1241002
   SET taskid = 1242002
   SET reqid = 1243210
   SET perform_status = "F"
   SET iret = uar_crmbeginapp(appid,happ)
   IF (iret=0)
    SET iret = uar_crmbegintask(happ,taskid,htask)
    IF (iret=0)
     SET iret = uar_crmbeginreq(htask,"oenctl_add_script",reqid,hstep)
     IF (iret=0)
      SET hreq = uar_crmgetrequest(hstep)
      IF (hreq != 0)
       CALL uar_srvsetstring(hreq,"sc_name",nullterm(oenctl_add_script_request->sc_name))
       CALL uar_srvsetstring(hreq,"sc_desc",nullterm(oenctl_add_script_request->sc_desc))
       CALL uar_srvsetstring(hreq,"sc_type",nullterm(oenctl_add_script_request->sc_type))
       CALL uar_srvsetstring(hreq,"sc_body",nullterm(oenctl_add_script_request->sc_body))
       CALL uar_srvsetulong(hreq,"not_executable",oenctl_add_script_request->not_executable)
       CALL uar_srvsetlong(hreq,"read_only",oenctl_add_script_request->read_only)
       IF (stats_binding != "")
        SET iret = uar_crmperformas(hstep,nullterm(stats_binding))
       ELSE
        SET iret = uar_crmperform(hstep)
       ENDIF
       IF (iret != 0)
        CALL text(24,5,concat("CRM perform failed:",build(iret)))
       ELSE
        SET perform_status = "S"
       ENDIF
       SET hreq = 0
      ELSE
       CALL text(24,5,concat("CrmGetoenctl_add_procinfo_request failed:",build(iret)))
      ENDIF
     ELSE
      CALL text(24,5,concat("Begin task unsuccessful: ",build(iret)))
     ENDIF
     CALL uar_crmendtask(htask)
     SET htask = 0
    ELSE
     CALL text(24,5,concat("Unsuccessful begin task: ",build(iret)))
    ENDIF
    CALL uar_crmendapp(happ)
    SET happ = 0
   ELSE
    CALL text(24,5,concat("Begin app failed with code: ",build(iret)))
   ENDIF
   SET hrep = uar_crmgetreply(hstep)
   CALL echo(build("query_status     [",uar_srvgetulong(hrep,"query_status"),"]"))
   IF (uar_srvgetulong(hrep,"query_status") != 1)
    CALL clear(1,1)
    CALL text(7,15,"Importing script failed!")
    CALL accept(8,15,"A;CU","")
    GO TO new_res_xds_csv_menu
   ENDIF
  ELSE
   CALL clear(1,1)
   CALL text(7,15,build2("Script: ",oenctl_add_script_request->sc_name," Already Exists!"))
   CALL accept(8,15,"A;CU","")
  ENDIF
 END ;Subroutine
 SUBROUTINE (include_oen_scripts(oen_script_name=vc) =c1)
   FREE RECORD oenctl_build_script_request
   RECORD oenctl_build_script_request(
     1 sc_name = vc
   )
   FREE RECORD oenctl_build_script_reply
   RECORD oenctl_build_script_reply(
     1 query_status = i4
     1 build_status = i2
     1 proclistforscr[*]
       2 proc_name = vc
     1 error_lines[*]
       2 contents = vc
     1 failed_nodes[*]
       2 node = vc
   )
   DECLARE oen_formatted_script_name = vc WITH noconstant("")
   SELECT INTO "nl:"
    os.script_name
    FROM oen_script os
    PLAN (os
     WHERE cnvtupper(trim(os.script_name))=cnvtupper(trim(oen_script_name)))
    DETAIL
     oen_formatted_script_name = os.script_name
    WITH counter
   ;end select
   IF (curqual=1)
    DECLARE stats_binding = vc
    DECLARE appid = i4
    DECLARE taskid = i4
    DECLARE reqid = i4
    DECLARE happ = i4
    DECLARE htask = i4
    DECLARE hreq = i4
    DECLARE hstep = i4
    DECLARE hitem = i4
    DECLARE hitemcount = i4
    DECLARE hrep = i4
    DECLARE hsrvreq = i4
    SET stats_binding = ""
    SET appid = 1241002
    SET taskid = 1242002
    SET reqid = 1243215
    SET perform_status = "F"
    SET iret = uar_crmbeginapp(appid,happ)
    IF (iret=0)
     SET iret = uar_crmbegintask(happ,taskid,htask)
     IF (iret=0)
      SET iret = uar_crmbeginreq(htask,"oenctl_build_script",reqid,hstep)
      IF (iret=0)
       SET hreq = uar_crmgetrequest(hstep)
       IF (hreq != 0)
        CALL uar_srvsetstring(hreq,"sc_name",nullterm(oen_formatted_script_name))
        IF (stats_binding != "")
         SET iret = uar_crmperformas(hstep,nullterm(stats_binding))
        ELSE
         SET iret = uar_crmperform(hstep)
        ENDIF
        IF (iret != 0)
         CALL text(24,5,concat("CRM perform failed:",build(iret)))
        ELSE
         SET perform_status = "S"
        ENDIF
        SET hreq = 0
       ELSE
        CALL text(24,5,concat("CrmGetoenctl_add_procinfo_request failed:",build(iret)))
       ENDIF
      ELSE
       CALL text(24,5,concat("Begin task unsuccessful: ",build(iret)))
      ENDIF
      CALL uar_crmendtask(htask)
      SET htask = 0
     ELSE
      CALL text(24,5,concat("Unsuccessful begin task: ",build(iret)))
     ENDIF
     CALL uar_crmendapp(happ)
     SET happ = 0
    ELSE
     CALL text(24,5,concat("Begin app failed with code: ",build(iret)))
    ENDIF
    SET hrep = uar_crmgetreply(hstep)
    CALL echo(build("query_status     [",uar_srvgetulong(hrep,"query_status"),"]"))
    SET oenctl_build_script_reply->query_status = uar_srvgetulong(hrep,"query_status")
    SET oenctl_build_script_reply->build_status = uar_srvgetshort(hrep,"build_status")
    SET hitemcount = uar_srvgetitemcount(hrep,"ProcListForScr")
    FOR (proclistforscrnum = 1 TO hitemcount)
      SET hitem = uar_srvgetitem(hrep,"ProcListForScr",(proclistforscrnum - 1))
      SET stat = alterlist(oenctl_build_script_reply->proclistforscr,proclistforscrnum)
      SET oenctl_build_script_reply->proclistforscr[proclistforscrnum].proc_name =
      uar_srvgetstringptr(hitem,"proc_name")
    ENDFOR
    SET hitemcount = uar_srvgetitemcount(hrep,"Error_Lines")
    FOR (error_lines = 1 TO hitemcount)
      SET hitem = uar_srvgetitem(hrep,"Error_Lines",(error_lines - 1))
      SET stat = alterlist(oenctl_build_script_reply->error_lines,error_lines)
      SET oenctl_build_script_reply->error_lines[error_lines].contents = uar_srvgetstringptr(hitem,
       "contents")
    ENDFOR
    SET hitemcount = uar_srvgetitemcount(hrep,"failed_nodes")
    FOR (failed_nodes = 1 TO hitemcount)
      SET hitem = uar_srvgetitem(hrep,"failed_nodes",(failed_nodes - 1))
      SET stat = alterlist(oenctl_build_script_reply->failed_nodes,failed_nodes)
      SET oenctl_build_script_reply->failed_nodes[failed_nodes].node = uar_srvgetstringptr(hitem,
       "node")
    ENDFOR
    IF ((oenctl_build_script_reply->query_status != 1))
     CALL clear(1,1)
     SET message = nowindow
     CALL echorecord(oenctl_build_script_reply)
     CALL clear(1,1)
     CALL text(7,15,"Import failed! Scroll up for more information and press enter to continue.")
     CALL text(8,15,build2("Script: ",oen_formatted_script_name))
     CALL accept(9,15,"A;CU","")
     GO TO new_res_xds_csv_menu
    ELSEIF ((oenctl_build_script_reply->build_status != 1))
     CALL clear(1,1)
     SET message = nowindow
     IF (size(oenctl_build_script_reply->proclistforscr,5) > 0)
      CALL echo("Include failed! Please verify the following interface(s) are not running:")
      CALL echo(build2("Script: ",oen_formatted_script_name))
      FOR (includefailed = 1 TO size(oenctl_build_script_reply->proclistforscr,5))
        CALL echo(trim(oenctl_build_script_reply->proclistforscr[includefailed].proc_name))
      ENDFOR
      CALL echo("")
      CALL echo("")
      CALL echo("Press enter to continue")
      CALL accept(8,15,"A;CU","")
     ELSEIF (size(oenctl_build_script_reply->error_lines,5) > 0)
      CALL echo("The following errors were found while including the script:")
      CALL echo(build2("Script: ",oen_formatted_script_name))
      FOR (includefailed = 1 TO size(oenctl_build_script_reply->error_lines,5))
        CALL echo(trim(oenctl_build_script_reply->error_lines[includefailed].contents))
      ENDFOR
      CALL echo("")
      CALL echo("")
      CALL echo("Press enter to continue")
      CALL accept(8,15,"A;CU","")
     ELSEIF (size(oenctl_build_script_reply->failed_nodes,5) > 0)
      CALL echo("The script could not be included on the following nodes:")
      CALL echo(build2("Script: ",oen_formatted_script_name))
      FOR (includefailed = 1 TO size(oenctl_build_script_reply->failed_nodes,5))
        CALL echo(trim(oenctl_build_script_reply->failed_nodes[includefailed].node))
      ENDFOR
      CALL echo("")
      CALL echo("")
      CALL echo("Press enter to continue")
      CALL accept(8,15,"A;CU","")
     ELSE
      CALL echo("Unknown error occured!")
      CALL echo(build2("Script: ",oen_formatted_script_name))
      CALL echo("")
      CALL echo("")
      CALL echo("Press enter to continue")
      CALL accept(8,15,"A;CU","")
     ENDIF
    ELSE
     CALL clear(1,1)
     CALL text(7,15,"Script was successfully included! Press enter to continue!")
     CALL text(8,15,build2("Script: ",oen_formatted_script_name))
     CALL accept(9,15,"A;CU","")
    ENDIF
   ELSE
    CALL clear(1,1)
    CALL text(7,15,build2("Script: ",import_oen_scripts," Doesn't Exist!"))
    CALL accept(8,15,"A;CU","")
   ENDIF
 END ;Subroutine
 SUBROUTINE (get_email_address(default_email_prompt=vc) =vc)
   DECLARE validemail = i2 WITH noconstant(0)
   DECLARE tempemailaddress = vc WITH noconstant("")
   DECLARE tempemailaddressverfication = vc WITH noconstant("")
   CALL clear(1,1)
   CALL text(7,15,default_email_prompt)
   CALL accept(8,15,"A;CU","Y")
   IF (curaccept="Y")
    WHILE (validemail=0)
      CALL clear(1,1)
      CALL text(7,15,"Please type in your Cerner Email address:")
      CALL accept(8,15,"###########################################################;;C","")
      SET tempemailaddress = trim(cnvtlower(curaccept))
      CALL text(10,15,"Please re-type in your Cerner Email address:")
      CALL accept(11,15,"###########################################################;;C","")
      SET tempemailaddressverfication = trim(cnvtlower(curaccept))
      IF (tempemailaddress=tempemailaddressverfication)
       IF (findstring("cerner.com",tempemailaddress) > 1)
        SET validemail = 1
       ELSE
        CALL clear(1,1)
        CALL text(7,15,"Not a Cerner Address! Do you want to try again?")
        CALL accept(8,15,"A;CU","Y")
        IF (curaccept != "Y")
         RETURN("0")
        ENDIF
       ENDIF
      ELSE
       CALL clear(1,1)
       CALL text(7,15,"The email addresses do not match! Do you want to try again!")
       CALL accept(8,15,"A;CU","Y")
       IF (curaccept != "Y")
        RETURN("0")
       ENDIF
      ENDIF
    ENDWHILE
    RETURN(tempemailaddress)
   ELSE
    RETURN("0")
   ENDIF
 END ;Subroutine
 SUBROUTINE trigger_patient_adt(dummy_var)
   DECLARE continue_with_backload = vc WITH noconstant("")
   CALL clear(1,1)
   CALL text(4,15,"WARNING - You must update the route script before running this backload!")
   CALL text(5,15,
    "If the route script is not updated, ADTs will be sent to all outbound ADT interfaces!")
   CALL text(6,15,"All ADTs generated by this process will have XDSTRA in the cqm_refnum field.")
   CALL text(7,15,"Example route script update:")
   CALL text(8,15,'of "ADT":')
   CALL text(9,15,'  set hist_check = get_string_value("cqm_refnum")')
   CALL text(10,15,'  if(findstring("XDSTRA", hist_check) > 0)')
   CALL text(11,15,"    SET STAT = ALTERLIST(OENROUTE->ROUTE_LIST, 1)")
   CALL text(12,15,"    SET OENROUTE->ROUTE_LIST[1]->R_PID = <Resonance PID>")
   CALL text(13,15,"    Set oenstatus->status = 1")
   CALL text(14,15,"  else")
   CALL text(15,15,"    <existing ADT logic>")
   CALL text(16,15,"*Above is an example only and is not meant to be used as-is for all clients!")
   CALL text(17,15," Please test all changes in Non-Prod before moving into Production.")
   CALL text(19,15,"Press enter to continue:")
   CALL accept(20,15,"###########################################;;C","")
   RECORD person_found(
     1 qual[*]
       2 person_id = f8
       2 mnemonic = vc
       2 logical_domain_id = f8
       2 name_full_formatted = vc
   )
   SET stat = alterlist(person_found->qual,1)
   CALL clear(1,1)
   CALL text(7,15,"Please enter the Person_ID:")
   CALL accept(7,51,"##############;;CU","")
   SET person_found->qual[1].person_id = cnvtreal(curaccept)
   SELECT INTO "nl:"
    p.person_id, p.name_full_formatted, ld.mnemonic,
    ld.logical_domain_id
    FROM person p,
     logical_domain ld
    PLAN (p
     WHERE (p.person_id=person_found->qual[1].person_id))
     JOIN (ld
     WHERE ld.logical_domain_id=p.logical_domain_id)
    DETAIL
     IF ((person_found->qual[1].person_id=p.person_id))
      person_found->qual[1].name_full_formatted = p.name_full_formatted
      IF (ld.logical_domain_id=0.0)
       person_found->qual[1].mnemonic = "Default Logical Domain"
      ELSE
       person_found->qual[1].mnemonic = ld.mnemonic
      ENDIF
      person_found->qual[1].logical_domain_id = ld.logical_domain_id
     ENDIF
    WITH nocounter
   ;end select
   IF ((person_found->qual[1].person_id > 0.0))
    FOR (x = 1 TO size(person_found->qual,5))
      CALL trigger_adt_outbound(person_found->qual[x].person_id,1)
    ENDFOR
    GO TO new_res_xds_res_support_menu
   ELSE
    CALL clear(1,1)
    CALL text(7,15,"Person_ID not found! Press enter to return to the Testing Utility!")
    CALL accept(8,15,"A;CU","")
    GO TO new_res_xds_res_support_menu
   ENDIF
 END ;Subroutine
 SUBROUTINE trigger_patient_query(dummy_var)
   IF ( NOT (validate(reply_prefetch,0)))
    RECORD reply_prefetch(
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c8
          3 operationstatus = c1
          3 targetobjectname = c15
          3 targetobjectvalue = c100
    )
   ENDIF
   FREE SET person_found
   RECORD person_found(
     1 qual[*]
       2 person_id = f8
       2 organization_id = f8
       2 name_full_formatted = vc
       2 mnemonic = vc
       2 logical_domain_id = f8
   )
   DECLARE iret = i4 WITH public, noconstant(0)
   DECLARE happ = i4 WITH public, noconstant(0)
   DECLARE htask = i4 WITH public, noconstant(0)
   DECLARE hreq = i4 WITH public, noconstant(0)
   DECLARE hrequest = i4 WITH public, noconstant(0)
   DECLARE hreply = i4 WITH public, noconstant(0)
   DECLARE hitem = i4 WITH public, noconstant(0)
   DECLARE sreturn = vc WITH public, noconstant("")
   DECLARE xdsdocument_type_cd = f8 WITH public, constant(uar_get_code_by("Displaykey",355,
     "XDSDOCUMENT"))
   SET reply_prefetch->status_data.status = "F"
   EXECUTE srvrtl
   EXECUTE crmrtl
   SET stat = alterlist(person_found->qual,1)
   CALL clear(1,1)
   CALL text(7,15,"Please enter the Person_ID:")
   CALL accept(7,51,"##############;;CU","")
   SET person_found->qual[1].person_id = cnvtreal(curaccept)
   SELECT INTO "nl:"
    p.person_id, p.name_full_formatted, ld.mnemonic,
    ld.logical_domain_id
    FROM person p,
     logical_domain ld,
     encounter e,
     org_info oi
    PLAN (p
     WHERE (p.person_id=person_found->qual[1].person_id))
     JOIN (ld
     WHERE ld.logical_domain_id=p.logical_domain_id)
     JOIN (e
     WHERE e.person_id=p.person_id)
     JOIN (oi
     WHERE oi.organization_id=e.organization_id
      AND oi.info_type_cd=xdsdocument_type_cd)
    ORDER BY e.encntr_id DESC
    DETAIL
     IF ((person_found->qual[1].person_id=p.person_id))
      person_found->qual[1].name_full_formatted = p.name_full_formatted
      IF (ld.logical_domain_id=0.0)
       person_found->qual[1].mnemonic = "Default Logical Domain"
      ELSE
       person_found->qual[1].mnemonic = ld.mnemonic
      ENDIF
      person_found->qual[1].logical_domain_id = ld.logical_domain_id, person_found->qual[1].
      organization_id = e.organization_id
     ENDIF
    WITH nocounter, maxrec = 1
   ;end select
   IF ((person_found->qual[1].person_id > 0.0))
    CALL execute_prefetch(1)
    CALL clear(1,1)
    CALL text(7,15,build2("Query triggered for ",person_found->qual[1].name_full_formatted,"!"))
    CALL text(9,15,build2("Patient belongs to LD: ",person_found->qual[1].mnemonic))
    CALL accept(10,15,"A;CU","")
    GO TO new_res_xds_res_support_menu
   ELSE
    CALL clear(1,1)
    CALL text(7,15,
     "Either Person_ID was not found or Org Defaults not set up! Press enter to return to the Testing Utility!"
     )
    CALL accept(8,15,"A;CU","")
    GO TO new_res_xds_res_support_menu
   ENDIF
   SET reply_prefetch->status_data.status = "S"
   IF (hreq > 0)
    CALL uar_crmendreq(hreq)
   ENDIF
   IF (htask > 0)
    CALL uar_crmendtask(htask)
   ENDIF
   IF (happ > 0)
    CALL uar_crmendapp(happ)
   ENDIF
 END ;Subroutine
 SUBROUTINE execute_prefetch(dummy_var)
   FOR (x = 1 TO size(person_found->qual,5))
     IF ((person_found->qual[x].organization_id > 0))
      SET iret = uar_crmbeginapp(3202004,happ)
      IF (iret=0)
       SET iret = uar_crmbegintask(happ,3202004,htask)
       IF (iret=0)
        SET iret = uar_crmbeginreq(htask,"QueryForDocument",1215225,hreq)
        IF (iret=0
         AND hreq != 0)
         SET hrequest = uar_crmgetrequest(hreq)
         IF (hrequest > 0)
          SET iret = uar_srvsetdouble(hrequest,"person_id",person_found->qual[x].person_id)
          SET iret = uar_srvsetdouble(hrequest,"organization_id",person_found->qual[x].
           organization_id)
          SET iret = uar_crmperform(hreq)
          IF (iret=0)
           SET hreply = uar_crmgetreply(hreq)
           IF (hreply != 0)
            SET sreturn = uar_srvgetstringptr(hreply,"status")
           ENDIF
          ELSE
           SET hreply = uar_crmgetreply(hreq)
           IF (hreply != 0)
            SET sreturn = uar_srvgetstringptr(hreply,"status")
           ENDIF
           IF (hreq > 0)
            CALL uar_crmendreq(hreq)
           ENDIF
           IF (htask > 0)
            CALL uar_crmendtask(htask)
           ENDIF
           IF (happ > 0)
            CALL uar_crmendapp(happ)
           ENDIF
          ENDIF
         ELSE
          SET reply_prefetch->status_data.subeventstatus[1].targetobjectvalue =
          "Unable to call QueryForDocument transaction on Server 508"
         ENDIF
        ELSE
         SET reply_prefetch->status_data.subeventstatus[1].targetobjectvalue =
         "Unable to call QueryForDocument transaction on Server 508"
        ENDIF
       ELSE
        SET reply_prefetch->status_data.subeventstatus[1].targetobjectvalue =
        "Unable to call QueryForDocument transaction on Server 508"
       ENDIF
      ELSE
       SET reply_prefetch->status_data.subeventstatus[1].targetobjectvalue =
       "Unable to call QueryForDocument transaction on Server 508"
      ENDIF
      IF (hreq > 0)
       CALL uar_crmendreq(hreq)
      ENDIF
      IF (htask > 0)
       CALL uar_crmendtask(htask)
      ENDIF
      IF (happ > 0)
       CALL uar_crmendapp(happ)
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE trigger_patient_provide(dummy_var)
   FREE SET person_found
   RECORD person_found(
     1 qual[*]
       2 person_id = f8
       2 encntr_id = f8
       2 organization_id = f8
       2 name_full_formatted = vc
       2 mnemonic = vc
       2 logical_domain_id = f8
       2 contributor_system_cd = f8
       2 template_id = f8
       2 load_num = i4
       2 ccd_processed = i4
       2 authorization_mode = i2
   )
   DECLARE queuestarttime = dq8
   DECLARE queueendtime = dq8
   DECLARE queuetotaltime = dq8
   DECLARE queueestimatedtimeleft = i4 WITH noconstant(0)
   DECLARE queueestimatedhoursleft = i4 WITH noconstant(0)
   DECLARE queueestimatedminutesleft = i4 WITH noconstant(0)
   DECLARE queueestimatedsecondsleft = i4 WITH noconstant(0)
   IF (validate(communitycontributorsystemdef)=0)
    DECLARE communitycontributorsystemdef = vc WITH constant("AD_RES_DEFAULT")
   ENDIF
   DECLARE contribsysusagetypecd = f8 WITH constant(uar_get_code_by("MEANING",3000,"CONTRIBSYS"))
   DECLARE xdsdocument_type_cd = f8 WITH public, constant(uar_get_code_by("Displaykey",355,
     "XDSDOCUMENT"))
   SET stat = alterlist(person_found->qual,1)
   CALL clear(1,1)
   CALL text(7,15,"Please enter the Person_ID:")
   CALL accept(8,15,"##############;;CU","")
   SET person_found->qual[1].person_id = cnvtreal(curaccept)
   SELECT INTO "nl:"
    e.encntr_id
    FROM person p,
     encounter e
    PLAN (p
     WHERE (p.person_id=person_found->qual[1].person_id))
     JOIN (e
     WHERE e.person_id=p.person_id)
    DETAIL
     IF ((person_found->qual[1].encntr_id < e.encntr_id))
      person_found->qual[1].encntr_id = e.encntr_id
     ENDIF
    WITH nocounter
   ;end select
   IF ( NOT (curqual > 0))
    CALL clear(1,1)
    SET message = nowindow
    CALL text(7,15,"Person_id not found or no encounters found for person_id! Press enter to exit.")
    CALL accept(8,15,"A;CU","")
    GO TO new_res_xds_res_support_menu
   ENDIF
   CALL clear(1,1)
   CALL text(7,15,"Please enter the Encntr_ID (leave blank for Person Level CCD):")
   CALL accept(8,15,"##############;;CU",person_found->qual[1].encntr_id)
   SET person_found->qual[1].encntr_id = cnvtreal(curaccept)
   IF ((person_found->qual[1].encntr_id > 0.0))
    SELECT INTO "nl:"
     e.encntr_id
     FROM encounter e
     PLAN (e
      WHERE (e.person_id=person_found->qual[1].person_id)
       AND (e.encntr_id=person_found->qual[1].encntr_id))
     WITH nocounter
    ;end select
    IF ( NOT (curqual > 0))
     CALL clear(1,1)
     SET message = nowindow
     CALL text(7,15,"Could not find row for person_id and encntr_id! Press enter to exit.")
     CALL accept(8,15,"A;CU","")
     GO TO new_res_xds_res_support_menu
    ENDIF
   ENDIF
   SET person_found->qual[1].contributor_system_cd = get_contributor_system_cd(
    communitycontributorsystemdef)
   IF ((person_found->qual[1].contributor_system_cd=0.0))
    GO TO new_res_xds_res_support_menu
   ENDIF
   CALL clear(1,1)
   CALL text(7,15,"Attempting to find Template_ID...")
   SELECT DISTINCT INTO "nl:"
    uar_get_code_display(dor.output_content_type_cd), dor.template_id, dor.default_ind
    FROM device_xref dx,
     device_output_reltn dor,
     device d,
     cr_report_template crt
    PLAN (dx
     WHERE dx.parent_entity_name="CONTRIBUTOR_SYSTEM"
      AND (dx.parent_entity_id=person_found->qual[1].contributor_system_cd)
      AND dx.usage_type_cd=contribsysusagetypecd)
     JOIN (d
     WHERE d.device_cd=dx.device_cd)
     JOIN (dor
     WHERE dor.device_cd=d.device_cd
      AND dor.template_id > 0.0)
     JOIN (crt
     WHERE (crt.template_id= Outerjoin(dor.template_id))
      AND (crt.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
    ORDER BY dor.default_ind DESC
    DETAIL
     person_found->qual[1].template_id = dor.template_id
    WITH maxrec = 1, nocounter
   ;end select
   IF ((person_found->qual[1].template_id=0.0))
    SELECT INTO "nl:"
     sdtr.contributor_system_cd, sdi.report_template_id, sdi.updt_dt_tm
     FROM si_document_transaction_log sdtr,
      si_document_info sdi
     PLAN (sdtr
      WHERE (sdtr.contributor_system_cd=person_found->qual[1].contributor_system_cd))
      JOIN (sdi
      WHERE sdi.parent_si_document_info_id=sdtr.si_document_info_id)
     ORDER BY sdi.updt_dt_tm DESC
     DETAIL
      person_found->qual[1].template_id = sdi.report_template_id
     WITH maxrec = 1, nocounter
    ;end select
   ENDIF
   CALL clear(1,1)
   CALL text(7,15,"Please enter the Template_ID:")
   CALL accept(8,15,"##############;;CU",person_found->qual[1].template_id)
   SET person_found->qual[1].template_id = cnvtreal(curaccept)
   SELECT DISTINCT INTO "nl:"
    crt.template_id
    FROM cr_report_template crt
    PLAN (crt
     WHERE (crt.template_id=person_found->qual[1].template_id)
      AND (crt.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
    DETAIL
     person_found->qual[1].template_id = crt.template_id
    WITH maxrec = 1, nocounter
   ;end select
   IF ( NOT (curqual > 0))
    CALL clear(1,1)
    SET message = nowindow
    CALL text(7,15,"No Template_ID found! Press enter to exit.")
    CALL accept(8,15,"A;CU","")
    GO TO new_res_xds_res_support_menu
   ENDIF
   CALL clear(1,1)
   CALL text(7,15,"Please enter the authorization_mode:")
   CALL text(8,15,
    "*Denotes the manner in which to apply authorization when extracting the data for the request.")
   CALL text(9,15,
    " 0 - Indicates that authorization is based on the user in context (ex: uses current user account)."
    )
   CALL text(10,15," 1 - Indicates that the report is generated on behalf of an external provider ")
   CALL text(11,15,"     using the DefaultUser profile for authorization (ex: External User).")
   CALL text(12,15," 2 - Indicates that the report is generated on behalf of a patient using ")
   CALL text(13,15,"	 the PatientUser profile for authorization (ex: Patient User).")
   CALL accept(14,15,"##############;;CU","1")
   SET person_found->qual[1].authorization_mode = cnvtint(curaccept)
   IF ((((person_found->qual[1].authorization_mode > 3)) OR ((person_found->qual[1].
   authorization_mode < 0))) )
    CALL clear(1,1)
    SET message = nowindow
    CALL text(7,15,"Invalid authorization_mode set! Press enter to exit.")
    CALL accept(8,15,"A;CU","")
    GO TO new_res_xds_res_support_menu
   ENDIF
   CALL clear(1,1)
   CALL text(7,15,"Enter the number of CCDs you want to generate for this patient:")
   CALL accept(8,15,"##############;;CU","1")
   SET person_found->qual[1].load_num = cnvtint(curaccept)
   IF ((person_found->qual[1].encntr_id > 0))
    SELECT INTO "nl:"
     p.person_id, e.encntr_id, p.name_full_formatted,
     ld.mnemonic, ld.logical_domain_id
     FROM person p,
      logical_domain ld,
      encounter e,
      org_info oi
     PLAN (p
      WHERE (p.person_id=person_found->qual[1].person_id))
      JOIN (ld
      WHERE ld.logical_domain_id=p.logical_domain_id)
      JOIN (e
      WHERE e.person_id=p.person_id
       AND (e.encntr_id=person_found->qual[1].encntr_id))
      JOIN (oi
      WHERE oi.organization_id=e.organization_id
       AND oi.info_type_cd=xdsdocument_type_cd)
     ORDER BY e.encntr_id DESC
     DETAIL
      IF ((person_found->qual[1].person_id=p.person_id))
       person_found->qual[1].name_full_formatted = p.name_full_formatted, person_found->qual[1].
       mnemonic = ld.mnemonic, person_found->qual[1].logical_domain_id = ld.logical_domain_id,
       person_found->qual[1].organization_id = e.organization_id
      ENDIF
     WITH nocounter, maxrec = 1
    ;end select
   ELSE
    SELECT INTO "nl:"
     p.person_id, e.encntr_id, p.name_full_formatted,
     ld.mnemonic, ld.logical_domain_id
     FROM person p,
      logical_domain ld,
      encounter e
     PLAN (p
      WHERE (p.person_id=person_found->qual[1].person_id))
      JOIN (ld
      WHERE ld.logical_domain_id=p.logical_domain_id)
      JOIN (e
      WHERE e.person_id=p.person_id)
     ORDER BY e.encntr_id DESC
     DETAIL
      IF ((person_found->qual[1].person_id=p.person_id))
       person_found->qual[1].name_full_formatted = p.name_full_formatted, person_found->qual[1].
       mnemonic = ld.mnemonic, person_found->qual[1].logical_domain_id = ld.logical_domain_id,
       person_found->qual[1].organization_id = e.organization_id
      ENDIF
     WITH nocounter, maxrec = 1
    ;end select
   ENDIF
   IF ((person_found->qual[1].person_id > 0.0))
    CALL clear(1,1)
    CALL text(7,15,"Starting CCD Generation")
    SET queuestarttime = curtime3
    FOR (load_num = 1 TO person_found->qual[1].load_num)
      IF (mod(person_found->qual[1].ccd_processed,5)=1)
       SET queueendtime = curtime3
       SET queuetotaltime = ((queueendtime - queuestarttime)/ 100)
       SET queueestimatedtimeleft = ((queuetotaltime * (person_found->qual[1].load_num - person_found
       ->qual[1].ccd_processed))/ person_found->qual[1].ccd_processed)
       SET queueestimatedhoursleft = (queueestimatedtimeleft/ 3600)
       SET queueestimatedtimeleft -= (3600 * queueestimatedhoursleft)
       SET queueestimatedminutesleft = (queueestimatedtimeleft/ 60)
       SET queueestimatedtimeleft -= (60 * queueestimatedminutesleft)
       SET queueestimatedsecondsleft = queueestimatedtimeleft
       IF (queueestimatedhoursleft=0
        AND queueestimatedminutesleft=0
        AND queueestimatedsecondsleft=0)
        CALL clear(1,1)
        CALL text(7,15,build2("ADTs Generated: ",trim(cnvtstring(person_found->qual[1].ccd_processed),
           3),"/",trim(cnvtstring(person_found->qual[1].load_num),3)))
        CALL text(8,15,build2("Estimated time left: Calculating"))
       ELSEIF (queueestimatedhoursleft > 0)
        CALL clear(1,1)
        CALL text(7,15,build2("ADTs Generated: ",trim(cnvtstring(person_found->qual[1].ccd_processed),
           3),"/",trim(cnvtstring(person_found->qual[1].load_num),3)))
        CALL text(8,15,build2("Estimated time left: ",trim(cnvtstring(queueestimatedhoursleft)),
          " Hours ",trim(cnvtstring(queueestimatedminutesleft))," Minutes ",
          trim(cnvtstring(queueestimatedsecondsleft))," Seconds"))
       ELSEIF (queueestimatedminutesleft > 0)
        CALL clear(1,1)
        CALL text(7,15,build2("ADTs Generated: ",trim(cnvtstring(person_found->qual[1].ccd_processed),
           3),"/",trim(cnvtstring(person_found->qual[1].load_num),3)))
        CALL text(8,15,build2("Estimated time left: ",trim(cnvtstring(queueestimatedminutesleft)),
          " Minutes ",trim(cnvtstring(queueestimatedsecondsleft))," Seconds"))
       ELSE
        CALL clear(1,1)
        CALL text(7,15,build2("ADTs Generated: ",trim(cnvtstring(person_found->qual[1].ccd_processed),
           3),"/",trim(cnvtstring(person_found->qual[1].load_num),3)))
        CALL text(8,15,build2("Estimated time left: ",trim(cnvtstring(queueestimatedsecondsleft)),
          " Seconds"))
       ENDIF
      ENDIF
      CALL execute_provide(person_found->qual[1].person_id,person_found->qual[1].encntr_id,
       person_found->qual[1].organization_id,person_found->qual[1].contributor_system_cd,person_found
       ->qual[1].template_id,
       person_found->qual[1].authorization_mode)
      SET person_found->qual[1].ccd_processed += 1
    ENDFOR
    CALL clear(1,1)
    CALL text(7,15,build2("  Provide triggered for: ",person_found->qual[1].name_full_formatted,"!"))
    CALL text(9,15,build2("  Patient belongs to LD: ",person_found->qual[1].mnemonic))
    IF ((person_found->qual[1].encntr_id > 0))
     CALL text(10,15,build2("               CCD Type: Encounter Level"))
    ELSE
     CALL text(10,15,build2("               CCD Type: Person Level"))
    ENDIF
    CALL text(11,15,build2("Number of CCDs Provided: ",cnvtstring(person_found->qual[1].load_num)))
    CALL accept(12,15,"A;CU","")
    GO TO new_res_xds_res_support_menu
   ELSE
    CALL clear(1,1)
    CALL text(7,15,
     "Either Person_ID or the Encntr_ID was incorrect! Press enter to return to the Testing Utility!"
     )
    CALL accept(8,15,"A;CU","")
    GO TO new_res_xds_res_support_menu
   ENDIF
 END ;Subroutine
 SUBROUTINE (execute_provide(provide_person_id=f8,provide_encntr_id=f8,provide_organization_id=f8,
  provide_contributor_system_cd=f8,provide_template_id=f8,provide_authorization_mode=i2) =c1)
   RECORD reply(
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c8
         3 operationstatus = c1
         3 targetobjectname = c15
         3 targetobjectvalue = c100
   )
   DECLARE hmsg = i4 WITH protect, noconstant(0)
   DECLARE hreq = i4 WITH private, noconstant(0)
   DECLARE hrep = i4 WITH private, noconstant(0)
   DECLARE hstatusdata = i4 WITH protect, noconstant(0)
   DECLARE nsrvstat = i2 WITH protect, noconstant(0)
   DECLARE hitem = i4 WITH protect, noconstant(0)
   DECLARE sstatus = c1 WITH protect, noconstant(" ")
   DECLARE soperationname = c25 WITH protect, noconstant(fillstring(25," "))
   DECLARE soperationstatus = c1 WITH protect, noconstant(" ")
   DECLARE stargetobjectname = c25 WITH protect, noconstant(fillstring(25," "))
   DECLARE stargetobjectvalue = vc WITH protect, noconstant(" ")
   DECLARE serrortext = vc WITH protect, noconstant("")
   DECLARE ccdsubmitfailed = i2 WITH protect, noconstant(0)
   DECLARE logging = i2 WITH constant(1)
   SET hmsg = uar_srvselectmessage(1370051)
   IF (hmsg=0)
    IF (logging=1)
     CALL echo(build("ERROR - Unable to obtain message for TDB 1370051"))
    ENDIF
    SET reply->status_data.status = "D "
    IF (hmsg > 0)
     SET stat = uar_srvdestroyinstance(hmsg)
    ENDIF
    IF (hreq > 0)
     SET stat = uar_srvdestroyinstance(hreq)
    ENDIF
    IF (hrep > 0)
     SET stat = uar_srvdestroyinstance(hrep)
    ENDIF
   ENDIF
   SET hreq = uar_srvcreaterequest(hmsg)
   IF (hreq=0)
    IF (logging=1)
     CALL echo(build("ERROR - Unable to obtain message for TDB 1370051"))
    ENDIF
    SET reply->status_data.status = "E "
    IF (hmsg > 0)
     SET stat = uar_srvdestroyinstance(hmsg)
    ENDIF
    IF (hreq > 0)
     SET stat = uar_srvdestroyinstance(hreq)
    ENDIF
    IF (hrep > 0)
     SET stat = uar_srvdestroyinstance(hrep)
    ENDIF
   ENDIF
   SET hrep = uar_srvcreatereply(hmsg)
   IF (hrep=0)
    IF (logging=1)
     CALL echo(build("ERROR - Unable to obtain message for TDB 1370051"))
    ENDIF
    SET reply->status_data.status = "Y "
    IF (hmsg > 0)
     SET stat = uar_srvdestroyinstance(hmsg)
    ENDIF
    IF (hreq > 0)
     SET stat = uar_srvdestroyinstance(hreq)
    ENDIF
    IF (hrep > 0)
     SET stat = uar_srvdestroyinstance(hrep)
    ENDIF
   ENDIF
   SET nsrvstat = uar_srvsetdouble(hreq,"person_id",provide_person_id)
   IF (provide_encntr_id > 0)
    SET nsrvstat = uar_srvsetdouble(hreq,"encntr_id",provide_encntr_id)
   ENDIF
   SET nsrvstat = uar_srvsetdouble(hreq,"report_template_id",provide_template_id)
   SET nsrvstat = uar_srvsetshort(hreq,"device_id",0)
   SET nsrvstat = uar_srvsetshort(hreq,"archive_ind",0)
   SET nsrvstat = uar_srvsetdouble(hreq,"contributor_system_id",provide_contributor_system_cd)
   SET nsrvstat = uar_srvsetshort(hreq,"authorization_mode",provide_authorization_mode)
   SET nsrvstat = uar_srvsetshort(hreq,"provider_patient_reltn_cd",0)
   IF ( NOT (provide_encntr_id > 0))
    SET nsrvstat = uar_srvsetdouble(hreq,"custodial_organization_id",provide_organization_id)
   ENDIF
   SET nsrvstat = uar_srvexecute(hmsg,hreq,hrep)
   IF (nsrvstat=0)
    SET hstatusdata = uar_srvgetstruct(hrep,"status_data")
    SET sstatus = uar_srvgetstringptr(hstatusdata,"status")
    IF (logging=1)
     CALL echo(build("CCD Request Status = ",sstatus))
    ENDIF
    IF (sstatus != "S")
     IF (logging=1)
      CALL echo("Transcation Failed.")
     ENDIF
     IF (uar_srvgetitemcount(hstatusdata,"subeventstatus") > 0)
      SET hitem = uar_srvgetitem(hstatusdata,"subeventstatus",0)
      SET stargetobjectvalue = uar_srvgetstringptr(hitem,"TargetObjectValue")
      IF (logging=1)
       CALL echo(build(" TargetObjectValue:",substring(1,400,stargetobjectvalue),"."))
      ENDIF
     ENDIF
     SET ccdsubmitfailed = 1
    ENDIF
   ELSE
    IF (logging=1)
     CALL echo("SrvExecute Failed. Either Server 388 is not running or invalid request.")
    ENDIF
    SET ccdsubmitfailed = 1
   ENDIF
   IF (ccdsubmitfailed=1)
    IF (hmsg > 0)
     SET stat = uar_srvdestroyinstance(hmsg)
    ENDIF
    IF (hreq > 0)
     SET stat = uar_srvdestroyinstance(hreq)
    ENDIF
    IF (hrep > 0)
     SET stat = uar_srvdestroyinstance(hrep)
    ENDIF
   ELSE
    SET reply->status_data.status = "S"
   ENDIF
   IF (hmsg > 0)
    SET stat = uar_srvdestroyinstance(hmsg)
   ENDIF
   IF (hreq > 0)
    SET stat = uar_srvdestroyinstance(hreq)
   ENDIF
   IF (hrep > 0)
    SET stat = uar_srvdestroyinstance(hrep)
   ENDIF
 END ;Subroutine
 SUBROUTINE (trigger_adt_outbound(adt_person_id=f8,requestisinteractive=i2) =c1)
   IF (validate(reply,"-999")="-999")
    RECORD reply(
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    )
   ENDIF
   IF (validate(false,0)=0
    AND validate(false,1)=1)
    DECLARE false = i2 WITH public, constant(0)
   ENDIF
   IF (validate(true,0)=0
    AND validate(true,1)=1)
    DECLARE true = i2 WITH public, constant(1)
   ENDIF
   IF (validate(gen_nbr_error,0)=0
    AND validate(gen_nbr_error,1)=1)
    DECLARE gen_nbr_error = i2 WITH public, constant(3)
   ENDIF
   IF (validate(insert_error,0)=0
    AND validate(insert_error,1)=1)
    DECLARE insert_error = i2 WITH public, constant(4)
   ENDIF
   IF (validate(update_error,0)=0
    AND validate(update_error,1)=1)
    DECLARE update_error = i2 WITH public, constant(5)
   ENDIF
   IF (validate(replace_error,0)=0
    AND validate(replace_error,1)=1)
    DECLARE replace_error = i2 WITH public, constant(6)
   ENDIF
   IF (validate(delete_error,0)=0
    AND validate(delete_error,1)=1)
    DECLARE delete_error = i2 WITH public, constant(7)
   ENDIF
   IF (validate(undelete_error,0)=0
    AND validate(undelete_error,1)=1)
    DECLARE undelete_error = i2 WITH public, constant(8)
   ENDIF
   IF (validate(remove_error,0)=0
    AND validate(remove_error,1)=1)
    DECLARE remove_error = i2 WITH public, constant(9)
   ENDIF
   IF (validate(attribute_error,0)=0
    AND validate(attribute_error,1)=1)
    DECLARE attribute_error = i2 WITH public, constant(10)
   ENDIF
   IF (validate(lock_error,0)=0
    AND validate(lock_error,1)=1)
    DECLARE lock_error = i2 WITH public, constant(11)
   ENDIF
   IF (validate(none_found,0)=0
    AND validate(none_found,1)=1)
    DECLARE none_found = i2 WITH public, constant(12)
   ENDIF
   IF (validate(select_error,0)=0
    AND validate(select_error,1)=1)
    DECLARE select_error = i2 WITH public, constant(13)
   ENDIF
   IF (validate(update_cnt_error,0)=0
    AND validate(update_cnt_error,1)=1)
    DECLARE update_cnt_error = i2 WITH public, constant(14)
   ENDIF
   IF (validate(not_found,0)=0
    AND validate(not_found,1)=1)
    DECLARE not_found = i2 WITH public, constant(15)
   ENDIF
   IF (validate(inactivate_error,0)=0
    AND validate(inactivate_error,1)=1)
    DECLARE inactivate_error = i2 WITH public, constant(17)
   ENDIF
   IF (validate(activate_error,0)=0
    AND validate(activate_error,1)=1)
    DECLARE activate_error = i2 WITH public, constant(18)
   ENDIF
   IF (validate(uar_error,0)=0
    AND validate(uar_error,1)=1)
    DECLARE uar_error = i2 WITH public, constant(20)
   ENDIF
   IF (validate(duplicate_error,- (1)) != 21)
    DECLARE duplicate_error = i2 WITH protect, noconstant(21)
   ENDIF
   IF (validate(ccl_error,- (1)) != 22)
    DECLARE ccl_error = i2 WITH protect, noconstant(22)
   ENDIF
   IF (validate(execute_error,- (1)) != 23)
    DECLARE execute_error = i2 WITH protect, noconstant(23)
   ENDIF
   DECLARE failed = i2 WITH protect, noconstant(false)
   DECLARE table_name = vc WITH protect, noconstant(" ")
   DECLARE call_echo_ind = i2 WITH protect, noconstant(0)
   DECLARE pmhc_contributory_system_cd = f8 WITH protect, noconstant(0.0)
   DECLARE transaction_type = i2 WITH protect, noconstant(0)
   DECLARE get_person_action = i2 WITH protect, constant(105)
   DECLARE modify_person_action = i2 WITH protect, constant(101)
   DECLARE hsrvmsg = i4 WITH noconstant(0)
   DECLARE hsrvreqmsg = i4 WITH noconstant(0)
   DECLARE hsrvrep = i4 WITH noconstant(0)
   DECLARE hsrvreq = i4 WITH noconstant(0)
   DECLARE hcqmmsg = i4 WITH noconstant(0)
   DECLARE hcqminfo = i4 WITH noconstant(0)
   DECLARE hesoinfo = i4 WITH noconstant(0)
   DECLARE htriginfo = i4 WITH noconstant(0)
   DECLARE hlonglist = i4 WITH noconstant(0)
   DECLARE hstatus = i4 WITH noconstant(0)
   DECLARE htempperson = i4 WITH noconstant(0)
   DECLARE htempperson2 = i4 WITH noconstant(0)
   DECLARE hmsg = i4 WITH noconstant(0)
   DECLARE hrep = i4 WITH noconstant(0)
   DECLARE happ = i4 WITH noconstant(0)
   DECLARE htask = i4 WITH noconstant(0)
   DECLARE hreq = i4 WITH noconstant(0)
   DECLARE cclsrvsetdate(hinst,fldname,fdate) = i4
   IF ((person_found->qual[x].person_id=0))
    SET failed = attribute_error
    SET table_name = "person_id is 0.0"
    CALL end_adt_request(1)
   ENDIF
   SET stat = uar_crmbeginapp(100000,happ)
   SET stat = uar_crmbegintask(happ,100000,htask)
   SET stat = uar_crmbeginreq(htask,"",114604,hmsg)
   SET hreq = uar_crmgetrequest(hmsg)
   SET stat = uar_srvsetshort(hreq,"action",get_person_action)
   SET stat = uar_srvsetdouble(hreq,"person_id",adt_person_id)
   SET stat = uar_srvsetshort(hreq,"all_person_aliases",1)
   SET stat = uar_crmperform(hmsg)
   SET hrep = uar_crmgetreply(hmsg)
   SET htempperson = uar_srvgetstruct(hrep,"PERSON")
   SET htempperson2 = uar_srvgetstruct(htempperson,"PERSON")
   SET stat = uar_srvgetdouble(htempperson2,"PERSON_ID")
   SET hsrvreqmsg = uar_srvselectmessage(1215013)
   IF (hsrvreqmsg=0)
    SET failed = uar_error
    SET table_name = "Unable to obtain message for TDB 1215013"
    CALL end_adt_request(1)
   ENDIF
   SET hsrvreq = uar_srvcreaterequest(hsrvreqmsg)
   SET hsrvrep = uar_srvcreatereply(hsrvreqmsg)
   CALL uar_srvdestroymessage(hsrvreqmsg)
   SET hreqmsg = 0
   SET hcqmmsg = uar_srvgetstruct(hsrvreq,"message")
   SET hcqminfo = uar_srvgetstruct(hcqmmsg,"cqminfo")
   SET htriginfo = uar_srvgetstruct(hcqmmsg,"triginfo")
   SET hesoinfo = uar_srvgetstruct(hcqmmsg,"esoinfo")
   SET stat = uar_srvcopy(htriginfo,hrep)
   IF (stat=0)
    SET failed = uar_error
    SET table_name = "Error copying 114604 reply into 1215001 request"
    CALL end_adt_request(1)
   ENDIF
   SET stat = uar_srvsetstring(hcqminfo,"appname","FSIESO")
   SET stat = uar_srvsetstring(hcqminfo,"contribalias","PM_TRANSACTION")
   SET stat = uar_srvsetstring(hcqminfo,"contribrefnum","XDSTRA")
   SET stat = cclsrvsetdate(hcqminfo,"contribdttm",cnvtdatetime(sysdate))
   SET stat = uar_srvsetlong(hcqminfo,"priority",99)
   SET stat = uar_srvsetstring(hcqminfo,"class","PM_TRANS")
   SET stat = uar_srvsetstring(hcqminfo,"type","ADT")
   SET stat = uar_srvsetstring(hcqminfo,"subtype","A04")
   SET stat = uar_srvsetstring(hcqminfo,"subtype_detail",cnvtstring(person_found->qual[x].person_id))
   SET stat = uar_srvsetlong(hcqminfo,"debug_ind",0)
   SET stat = uar_srvsetlong(hcqminfo,"verbosity_flag",1)
   SET hlonglist = uar_srvadditem(hesoinfo,"longList")
   SET stat = uar_srvsetstring(hlonglist,"StrMeaning","person first event")
   SET stat = uar_srvsetlong(hlonglist,"lVal",0)
   SET hlonglist = uar_srvadditem(hesoinfo,"longList")
   SET stat = uar_srvsetstring(hlonglist,"StrMeaning","encntr first event")
   SET stat = uar_srvsetlong(hlonglist,"lVal",0)
   SET hlonglist = uar_srvadditem(hesoinfo,"longList")
   SET stat = uar_srvsetstring(hlonglist,"StrMeaning","encntr event ind")
   SET stat = uar_srvsetlong(hlonglist,"lVal",0)
   SET hlonglist = uar_srvadditem(hesoinfo,"longList")
   SET stat = uar_srvsetstring(hlonglist,"StrMeaning","action type")
   SET stat = uar_srvsetlong(hlonglist,"lVal",modify_person_action)
   SET hsrvmsg = uar_srvselectmessage(1215001)
   IF (hsrvreqmsg=0)
    SET failed = uar_error
    SET table_name = "Unable to obtain message for TDB 1215001"
    CALL end_adt_request(1)
   ENDIF
   SET stat = uar_srvexecute(hsrvmsg,hsrvreq,hsrvrep)
   IF (stat != 0)
    SET failed = uar_error
    CASE (stat)
     OF 1:
      SET table_name = "Communication error in SrvExecute (1215001), no server available."
     OF 2:
      SET table_name = "Data inconsistency or mismatch in message in SrvExecute (1215001)."
     OF 3:
      SET table_name = "No handler to service request in SrvExecute (1215001)."
    ENDCASE
    CALL end_adt_request(1)
   ENDIF
   SET hstatus = uar_srvgetstruct(hsrvrep,"Sb")
   SET stat = uar_srvgetlong(hstatus,"STATUS_CD")
   IF (stat != 0)
    SET failed = uar_error
    SET table_name = "Request to FSI_SRVCQM Server failed."
   ENDIF
   CALL end_adt_request(requestisinteractive)
 END ;Subroutine
 SUBROUTINE (end_adt_request(isinteractive=i2) =c1)
   IF (hsrvmsg)
    CALL uar_srvdestroymessage(hsrvmsg)
    SET hsrvmsg = 0
   ENDIF
   IF (hsrvreq)
    CALL uar_srvdestroyinstance(hsrvreq)
    SET hsrvreq = 0
   ENDIF
   IF (hsrvrep)
    CALL uar_srvdestroyinstance(hsrvrep)
    SET hsrvrep = 0
   ENDIF
   IF (hreq > 0)
    CALL uar_crmendreq(hmsg)
   ENDIF
   IF (htask > 0)
    CALL uar_crmendtask(htask)
   ENDIF
   IF (happ > 0)
    CALL uar_crmendapp(happ)
   ENDIF
   IF (failed=false)
    SET reply->status_data.status = "S"
   ELSE
    SET reply->status_data.status = "F"
    IF (failed != true
     AND failed != false)
     IF ((validate(pm_subeventstatus_sub_,- (99))=- (99)))
      DECLARE pm_subeventstatus_sub_ = i2 WITH public, constant(1)
      SUBROUTINE (s_next_subeventstatus(s_null=i4) =i4)
        DECLARE s_stat = i4 WITH private, noconstant(0)
        DECLARE stx1 = i4 WITH private, noconstant(size(reply->status_data.subeventstatus,5))
        IF ((((reply->status_data.subeventstatus[stx1].operationname > " ")) OR ((((reply->
        status_data.subeventstatus[stx1].operationstatus > " ")) OR ((((reply->status_data.
        subeventstatus[stx1].targetobjectname > " ")) OR ((reply->status_data.subeventstatus[stx1].
        targetobjectvalue > " "))) )) )) )
         SET stx1 += 1
         SET s_stat = alter(reply->status_data.subeventstatus,stx1)
        ENDIF
        RETURN(stx1)
      END ;Subroutine
      SUBROUTINE (s_add_subeventstatus(s_oname=vc,s_ostatus=c1,s_tname=vc,s_tvalue=vc) =i4)
        DECLARE stx1 = i4 WITH private, noconstant(s_next_subeventstatus(1))
        SET reply->status_data.subeventstatus[stx1].operationname = s_oname
        SET reply->status_data.subeventstatus[stx1].operationstatus = s_ostatus
        SET reply->status_data.subeventstatus[stx1].targetobjectname = s_tname
        SET reply->status_data.subeventstatus[stx1].targetobjectvalue = s_tvalue
        RETURN(stx1)
      END ;Subroutine
      SUBROUTINE (s_add_subeventstatus_cclerr(s_null=i4) =i4)
        DECLARE serrmsg = vc WITH private, noconstant("")
        DECLARE ierrcode = i4 WITH private, noconstant(1)
        WHILE (ierrcode)
         SET ierrcode = error(serrmsg,0)
         IF (ierrcode)
          CALL s_add_subeventstatus("CCLERR","F",trim(curprog),serrmsg)
         ENDIF
        ENDWHILE
        RETURN(1)
      END ;Subroutine
      SUBROUTINE (s_log_subeventstatus(s_null=i4) =i4)
        DECLARE wi = i4 WITH protect, noconstant(0)
        DECLARE s_curprog = vc WITH protect, constant(curprog)
        FOR (wi = 1 TO size(reply->status_data.subeventstatus,5))
          CALL s_sch_msgview(s_curprog,nullterm(build(reply->status_data.subeventstatus[wi].
             operationname,",",reply->status_data.subeventstatus[wi].operationstatus,",",reply->
             status_data.subeventstatus[wi].targetobjectname,
             ",",reply->status_data.subeventstatus[wi].targetobjectvalue)),0)
        ENDFOR
      END ;Subroutine
      SUBROUTINE (s_clear_subeventstatus(s_null=i4) =i4)
        SET stat = alter(reply->status_data.subeventstatus,1)
        SET reply->status_data.subeventstatus[1].operationname = ""
        SET reply->status_data.subeventstatus[1].operationstatus = ""
        SET reply->status_data.subeventstatus[1].targetobjectname = ""
        SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
      END ;Subroutine
      SUBROUTINE (s_sch_msgview(t_event=vc,t_message=vc,t_log_level=i4) =i2)
       IF (t_event > " "
        AND t_log_level BETWEEN 0 AND 4
        AND t_message > " ")
        DECLARE hlog = i4 WITH protect, noconstant(0)
        DECLARE hstat = i4 WITH protect, noconstant(0)
        CALL uar_syscreatehandle(hlog,hstat)
        IF (hlog != 0)
         CALL uar_sysevent(hlog,t_log_level,nullterm(t_event),nullterm(t_message))
         CALL uar_sysdestroyhandle(hlog)
        ENDIF
       ENDIF
       RETURN(1)
      END ;Subroutine
     ENDIF
     CASE (failed)
      OF lock_error:
       CALL s_add_subeventstatus("LOCK","F",trim(curprog),table_name)
      OF select_error:
       CALL s_add_subeventstatus("SELECT","F",trim(curprog),table_name)
      OF update_error:
       CALL s_add_subeventstatus("UPDATE","F",trim(curprog),table_name)
      OF insert_error:
       CALL s_add_subeventstatus("INSERT","F",trim(curprog),table_name)
      OF gen_nbr_error:
       CALL s_add_subeventstatus("GEN_NBR","F",trim(curprog),table_name)
      OF replace_error:
       CALL s_add_subeventstatus("REPLACE","F",trim(curprog),table_name)
      OF delete_error:
       CALL s_add_subeventstatus("DELETE","F",trim(curprog),table_name)
      OF undelete_error:
       CALL s_add_subeventstatus("UNDELETE","F",trim(curprog),table_name)
      OF remove_error:
       CALL s_add_subeventstatus("REMOVE","F",trim(curprog),table_name)
      OF attribute_error:
       CALL s_add_subeventstatus("ATTRIBUTE","F",trim(curprog),table_name)
      OF none_found:
       CALL s_add_subeventstatus("NONE_FOUND","F",trim(curprog),table_name)
      OF update_cnt_error:
       CALL s_add_subeventstatus("UPDATE_CNT","F",trim(curprog),table_name)
      OF not_found:
       CALL s_add_subeventstatus("NOT_FOUND","F",trim(curprog),table_name)
      OF inactivate_error:
       CALL s_add_subeventstatus("INACTIVATE","F",trim(curprog),table_name)
      OF activate_error:
       CALL s_add_subeventstatus("ACTIVATE","F",trim(curprog),table_name)
      OF uar_error:
       CALL s_add_subeventstatus("UAR_ERROR","F",trim(curprog),table_name)
      OF execute_error:
       CALL s_add_subeventstatus("EXECUTE","F",trim(curprog),table_name)
      OF duplicate_error:
       CALL s_add_subeventstatus("DUPLICATE","F",trim(curprog),table_name)
      OF ccl_error:
       CALL s_add_subeventstatus("CCLERROR","F",trim(curprog),table_name)
      ELSE
       CALL s_add_subeventstatus("UNKNOWN","F",trim(curprog),table_name)
     ENDCASE
     SET reqinfo->commit_ind = false
     CALL s_add_subeventstatus_cclerr(1)
     CALL s_log_subeventstatus(1)
    ENDIF
   ENDIF
   SUBROUTINE cclsrvsetdate(hinst,fldname,fdate)
     DECLARE datestr = vc
     FREE SET sdate
     RECORD sdate(
       1 d1 = c1
       1 d2 = c1
       1 d3 = c1
       1 d4 = c1
       1 d5 = c1
       1 d6 = c1
       1 d7 = c1
       1 d8 = c1
     )
     SET datestr = format(cnvtdatetimeutc(fdate,1),"yyyy-mm-dd hh:mm:ss.cc;;Q")
     SET sdate->d1 = char(cnvtint(substring(1,2,datestr)))
     SET sdate->d2 = char(cnvtint(substring(3,2,datestr)))
     SET sdate->d3 = char(cnvtint(substring(6,2,datestr)))
     SET sdate->d4 = char(cnvtint(substring(9,2,datestr)))
     SET sdate->d5 = char(cnvtint(substring(12,2,datestr)))
     SET sdate->d6 = char(cnvtint(substring(15,2,datestr)))
     SET sdate->d7 = char(cnvtint(substring(18,2,datestr)))
     SET sdate->d8 = char(cnvtint(substring(21,2,datestr)))
     RETURN(uar_srvsetdate2(hinst,nullterm(fldname),sdate))
   END ;Subroutine
   IF (isinteractive=1)
    IF ((reply->status_data.status="S"))
     CALL clear(1,1)
     CALL text(7,15,build2("ADT triggered for ",person_found->qual[1].name_full_formatted,"!"))
     CALL text(9,15,build2("Patient belongs to LD: ",person_found->qual[1].mnemonic))
     CALL accept(10,15,"A;CU","")
    ELSE
     CALL clear(1,1)
     CALL text(7,15,build2("ADT Trigger failed! Press enter to exit!"))
     CALL accept(10,15,"A;CU","")
    ENDIF
    GO TO new_res_xds_res_support_menu
   ENDIF
 END ;Subroutine
 SUBROUTINE gather_adt_request_info(dummy_var)
   DECLARE continue_with_backload = vc WITH noconstant("")
   CALL clear(1,1)
   CALL text(4,15,"WARNING - You must update the route script before running this backload!")
   CALL text(5,15,
    "If the route script is not updated, ADTs will be sent to all outbound ADT interfaces!")
   CALL text(6,15,"All ADTs generated by this process will have XDSTRA in the cqm_refnum field.")
   CALL text(7,15,
    "Example route script update (can use Option 1 (trigger single ADT) to test route script changes):"
    )
   CALL text(8,15,'of "ADT":')
   CALL text(9,15,'  set hist_check = get_string_value("cqm_refnum")')
   CALL text(10,15,'  if(findstring("XDSTRA", hist_check) > 0)')
   CALL text(11,15,"    SET STAT = ALTERLIST(OENROUTE->ROUTE_LIST, 1)")
   CALL text(12,15,"    SET OENROUTE->ROUTE_LIST[1]->R_PID = <Resonance PID>")
   CALL text(13,15,"    Set oenstatus->status = 1")
   CALL text(14,15,"  else")
   CALL text(15,15,"    <existing ADT logic>")
   CALL text(16,15,"*Above is an example only and is not meant to be used as-is for all clients!")
   CALL text(17,15," Please test all changes in Non-Prod before moving into Production.")
   CALL text(19,15,"Type CONTINUEWITHBACKLOAD to continue or press enter to exit:")
   CALL accept(20,15,"###########################################;;C","")
   SET continue_with_backload = trim(curaccept)
   IF (continue_with_backload != "CONTINUEWITHBACKLOAD")
    GO TO new_res_xds_res_support_menu
   ENDIF
   FREE SET person_found
   RECORD person_found(
     1 start_date_time = vc
     1 ld_or_org_extract = i2
     1 logical_domain_id = f8
     1 organization[*]
       2 organization_id = f8
     1 qual[*]
       2 person_id = f8
     1 begin_date = vc
     1 begin_time = vc
     1 end_date = vc
     1 end_time = vc
     1 adt_processed = i4
   )
   DECLARE queuestarttime = dq8
   DECLARE queueendtime = dq8
   DECLARE queuetotaltime = dq8
   DECLARE queueestimatedtimeleft = i4 WITH noconstant(0)
   DECLARE queueestimatedhoursleft = i4 WITH noconstant(0)
   DECLARE queueestimatedminutesleft = i4 WITH noconstant(0)
   DECLARE queueestimatedsecondsleft = i4 WITH noconstant(0)
   DECLARE continueaddingorganizations = i2 WITH noconstant(1)
   DECLARE orgnum = i4 WITH noconstant(0)
   SET person_found->adt_processed = 0
   CALL clear(1,1)
   CALL text(7,15,"Do you want generate Person Level ADTs by logical domain or by Organizations?:")
   CALL text(9,15,"1: By Logical Domain")
   CALL text(11,15,"2: By Organization(s)")
   CALL text(13,15,"3: Exit")
   CALL accept(15,15,"#;;CU","")
   IF (cnvtint(curaccept)=1)
    SET person_found->ld_or_org_extract = 1
    SET person_found->logical_domain_id = get_logical_domain_id(currentuserld)
   ELSEIF (cnvtint(curaccept)=2)
    SET person_found->ld_or_org_extract = 2
    WHILE (continueaddingorganizations=1)
      SET orgnum += 1
      SET stat = alterlist(person_found->organization,orgnum)
      SET person_found->organization[orgnum].organization_id = get_organization_id(1)
      CALL clear(1,1)
      CALL text(7,15,"Do you want to add anymore organizations?")
      CALL accept(7,80,"A;CU","N")
      IF (curaccept != "Y")
       SET continueaddingorganizations = 0
      ENDIF
    ENDWHILE
    IF ( NOT ((person_found->organization[1].organization_id > 0)))
     GO TO new_res_xds_res_support_menu
    ENDIF
   ELSEIF (cnvtint(curaccept)=3)
    GO TO new_res_xds_res_support_menu
   ELSE
    CALL clear(1,1)
    SET message = nowindow
    CALL echo("")
    CALL echo("")
    CALL echo("You must choose to extract by either LD or Orgs! Press enter exit!")
    CALL accept(1,1,"A;CU","")
    GO TO new_res_xds_res_support_menu
   ENDIF
   CALL clear(1,1)
   CALL text(13,2,"Enter beginning date in format MM/DD/YYYY: ")
   CALL text(14,2,"  Enter beginning time in format HH:MM:SS: ")
   CALL text(15,2,"   Enter ending date in format MM/DD/YYYY: ")
   CALL text(16,2,"     Enter ending time in format HH:MM:SS: ")
   CALL accept(13,45,"99D99D9999;CD",format((curdate - 30),"MM/DD/YYYY;;D"))
   SET person_found->begin_date = curaccept
   CALL accept(14,45,"99D99D99;CS",format(0,"HH:MM:SS;2;M"))
   SET person_found->begin_time = curaccept
   CALL accept(15,45,"99D99D9999;CDS",format(curdate,"MM/DD/YYYY;;D"))
   SET person_found->end_date = curaccept
   CALL accept(16,45,"99D99D99;CS",format(235959,"HH:MM:SS;2;M"))
   SET person_found->end_time = curaccept
   SET programstarttime = curtime3
   SET message = nowindow
   CALL clear(1,1)
   CALL echo("Gathering persons")
   DECLARE personnum = i4 WITH noconstant(0)
   DECLARE orgidnum = i4
   IF ((person_found->ld_or_org_extract=1))
    SELECT DISTINCT INTO "nl:"
     e.person_id
     FROM organization o,
      location l,
      encounter e,
      person p
     PLAN (o
      WHERE (o.logical_domain_id=person_found->logical_domain_id))
      JOIN (l
      WHERE ((l.organization_id=o.organization_id) OR (l.location_cd=0)) )
      JOIN (e
      WHERE e.location_cd=l.location_cd
       AND e.organization_id=o.organization_id
       AND e.person_id != 0
       AND e.updt_dt_tm BETWEEN cnvtdatetime(cnvtdate2(person_found->begin_date,"MM/DD/YYYY"),
       cnvttime2(person_found->begin_time,"hh:mm:ss")) AND cnvtdatetime(cnvtdate2(person_found->
        end_date,"MM/DD/YYYY"),cnvttime2(person_found->end_time,"hh:mm:ss"))
       AND  NOT ( EXISTS (
      (SELECT
       1
       FROM encounter e2
       WHERE e2.person_id=e.person_id
        AND e2.updt_dt_tm > cnvtdatetime(cnvtdate2(person_found->end_date,"MM/DD/YYYY"),cnvttime2(
         person_found->end_time,"hh:mm:ss"))))))
      JOIN (p
      WHERE p.person_id=e.person_id
       AND p.logical_domain_id=o.logical_domain_id
       AND p.active_ind=1)
     DETAIL
      personnum += 1, stat = alterlist(person_found->qual,personnum), person_found->qual[personnum].
      person_id = p.person_id
     WITH counter
    ;end select
   ELSEIF ((person_found->ld_or_org_extract=2))
    SELECT DISTINCT INTO "nl:"
     e.person_id
     FROM organization o,
      location l,
      encounter e,
      person p
     PLAN (o
      WHERE expand(orgidnum,1,size(person_found->organization,5),o.organization_id,person_found->
       organization[orgidnum].organization_id))
      JOIN (l
      WHERE ((l.organization_id=o.organization_id) OR (l.location_cd=0)) )
      JOIN (e
      WHERE e.location_cd=l.location_cd
       AND e.organization_id=o.organization_id
       AND e.person_id != 0
       AND e.updt_dt_tm BETWEEN cnvtdatetime(cnvtdate2(person_found->begin_date,"MM/DD/YYYY"),
       cnvttime2(person_found->begin_time,"hh:mm:ss")) AND cnvtdatetime(cnvtdate2(person_found->
        end_date,"MM/DD/YYYY"),cnvttime2(person_found->end_time,"hh:mm:ss"))
       AND  NOT ( EXISTS (
      (SELECT
       1
       FROM encounter e2
       WHERE e2.person_id=e.person_id
        AND e2.updt_dt_tm > cnvtdatetime(cnvtdate2(person_found->end_date,"MM/DD/YYYY"),cnvttime2(
         person_found->end_time,"hh:mm:ss"))))))
      JOIN (p
      WHERE p.person_id=e.person_id
       AND p.logical_domain_id=o.logical_domain_id
       AND p.active_ind=1)
     DETAIL
      personnum += 1, stat = alterlist(person_found->qual,personnum), person_found->qual[personnum].
      person_id = e.person_id
     WITH counter
    ;end select
   ELSE
    CALL clear(1,1)
    SET message = nowindow
    CALL echo("")
    CALL echo("")
    CALL echo("Must choose to extract by either Logical Domain or Organization! Exiting!")
    CALL accept(1,1,"A;CU","")
    GO TO new_res_xds_res_support_menu
   ENDIF
   CALL clear(1,1)
   CALL text(7,15,build2("Persons found: ",trim(cnvtstring(size(person_found->qual,5)),3)))
   CALL text(8,15,build2("Generate ADTs? Y/N"))
   CALL accept(9,15,"A;CU","N")
   IF (curaccept="Y")
    SET queuestarttime = curtime3
    FOR (x = 1 TO size(person_found->qual,5))
      IF (mod(person_found->adt_processed,5)=1)
       SET queueendtime = curtime3
       SET queuetotaltime = ((queueendtime - queuestarttime)/ 100)
       SET queueestimatedtimeleft = ((queuetotaltime * (size(person_found->qual,5) - person_found->
       adt_processed))/ person_found->adt_processed)
       SET queueestimatedhoursleft = (queueestimatedtimeleft/ 3600)
       SET queueestimatedtimeleft -= (3600 * queueestimatedhoursleft)
       SET queueestimatedminutesleft = (queueestimatedtimeleft/ 60)
       SET queueestimatedtimeleft -= (60 * queueestimatedminutesleft)
       SET queueestimatedsecondsleft = queueestimatedtimeleft
       IF (queueestimatedhoursleft=0
        AND queueestimatedminutesleft=0
        AND queueestimatedsecondsleft=0)
        CALL clear(1,1)
        CALL text(7,15,build2("ADTs Generated: ",trim(cnvtstring(person_found->adt_processed),3),"/",
          trim(cnvtstring(size(person_found->qual,5)),3)))
        CALL text(8,15,build2("Estimated time left: Calculating"))
       ELSEIF (queueestimatedhoursleft > 0)
        CALL clear(1,1)
        CALL text(7,15,build2("ADTs Generated: ",trim(cnvtstring(person_found->adt_processed),3),"/",
          trim(cnvtstring(size(person_found->qual,5)),3)))
        CALL text(8,15,build2("Estimated time left: ",trim(cnvtstring(queueestimatedhoursleft)),
          " Hours ",trim(cnvtstring(queueestimatedminutesleft))," Minutes ",
          trim(cnvtstring(queueestimatedsecondsleft))," Seconds"))
       ELSEIF (queueestimatedminutesleft > 0)
        CALL clear(1,1)
        CALL text(7,15,build2("ADTs Generated: ",trim(cnvtstring(person_found->adt_processed),3),"/",
          trim(cnvtstring(size(person_found->qual,5)),3)))
        CALL text(8,15,build2("Estimated time left: ",trim(cnvtstring(queueestimatedminutesleft)),
          " Minutes ",trim(cnvtstring(queueestimatedsecondsleft))," Seconds"))
       ELSE
        CALL clear(1,1)
        CALL text(7,15,build2("ADTs Generated: ",trim(cnvtstring(person_found->adt_processed),3),"/",
          trim(cnvtstring(size(person_found->qual,5)),3)))
        CALL text(8,15,build2("Estimated time left: ",trim(cnvtstring(queueestimatedsecondsleft)),
          " Seconds"))
       ENDIF
      ENDIF
      CALL trigger_adt_outbound(person_found->qual[x].person_id,0)
      SET person_found->adt_processed += 1
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE gather_adt_request_info_by_alias_pool_cd(dummy_var)
   DECLARE continue_with_backload = vc WITH noconstant("")
   CALL clear(1,1)
   CALL text(4,15,"WARNING - You must update the route script before running this backload!")
   CALL text(5,15,
    "If the route script is not updated, ADTs will be sent to all outbound ADT interfaces!")
   CALL text(6,15,"All ADTs generated by this process will have XDSTRA in the cqm_refnum field.")
   CALL text(7,15,
    "Example route script update (can use Option 1 (trigger single ADT) to test route script changes):"
    )
   CALL text(8,15,'of "ADT":')
   CALL text(9,15,'  set hist_check = get_string_value("cqm_refnum")')
   CALL text(10,15,'  if(findstring("XDSTRA", hist_check) > 0)')
   CALL text(11,15,"    SET STAT = ALTERLIST(OENROUTE->ROUTE_LIST, 1)")
   CALL text(12,15,"    SET OENROUTE->ROUTE_LIST[1]->R_PID = <Resonance PID>")
   CALL text(13,15,"    Set oenstatus->status = 1")
   CALL text(14,15,"  else")
   CALL text(15,15,"    <existing ADT logic>")
   CALL text(16,15,"*Above is an example only and is not meant to be used as-is for all clients!")
   CALL text(17,15," Please test all changes in Non-Prod before moving into Production.")
   CALL text(19,15,"Type CONTINUEWITHBACKLOAD to continue or press enter to exit:")
   CALL accept(20,15,"###########################################;;C","")
   SET continue_with_backload = trim(curaccept)
   IF (continue_with_backload != "CONTINUEWITHBACKLOAD")
    GO TO new_res_xds_res_support_menu
   ENDIF
   FREE SET person_found
   RECORD person_found(
     1 start_date_time = vc
     1 logical_domain_id = f8
     1 organization[*]
       2 organization_id = f8
     1 qual[*]
       2 person_id = f8
     1 begin_date = vc
     1 begin_time = vc
     1 end_date = vc
     1 end_time = vc
     1 adt_processed = i4
     1 alias_pool_cd = f8
   )
   DECLARE queuestarttime = dq8
   DECLARE queueendtime = dq8
   DECLARE queuetotaltime = dq8
   DECLARE queueestimatedtimeleft = i4 WITH noconstant(0)
   DECLARE queueestimatedhoursleft = i4 WITH noconstant(0)
   DECLARE queueestimatedminutesleft = i4 WITH noconstant(0)
   DECLARE queueestimatedsecondsleft = i4 WITH noconstant(0)
   DECLARE continueaddingorganizations = i2 WITH noconstant(1)
   DECLARE orgnum = i4 WITH noconstant(0)
   SET person_found->adt_processed = 0
   SET person_found->alias_pool_cd = get_alias_pool_cd(currentuserld)
   IF ( NOT ((person_found->alias_pool_cd > 0.0)))
    GO TO new_res_xds_res_support_menu
   ENDIF
   CALL clear(1,1)
   CALL text(13,2,"Enter beginning date in format MM/DD/YYYY: ")
   CALL text(14,2,"  Enter beginning time in format HH:MM:SS: ")
   CALL text(15,2,"   Enter ending date in format MM/DD/YYYY: ")
   CALL text(16,2,"     Enter ending time in format HH:MM:SS: ")
   CALL accept(13,45,"99D99D9999;CD",format((curdate - 30),"MM/DD/YYYY;;D"))
   SET person_found->begin_date = curaccept
   CALL accept(14,45,"99D99D99;CS",format(0,"HH:MM:SS;2;M"))
   SET person_found->begin_time = curaccept
   CALL accept(15,45,"99D99D9999;CDS",format(curdate,"MM/DD/YYYY;;D"))
   SET person_found->end_date = curaccept
   CALL accept(16,45,"99D99D99;CS",format(235959,"HH:MM:SS;2;M"))
   SET person_found->end_time = curaccept
   SET programstarttime = curtime3
   SET message = nowindow
   CALL clear(1,1)
   CALL echo("Gathering persons")
   DECLARE personnum = i4 WITH noconstant(0)
   DECLARE orgidnum = i4
   IF ((person_found->alias_pool_cd > 0.0))
    SELECT DISTINCT INTO "nl:"
     pa.person_id
     FROM person_alias pa
     PLAN (pa
      WHERE (pa.alias_pool_cd=person_found->alias_pool_cd)
       AND pa.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
       AND pa.updt_dt_tm BETWEEN cnvtdatetime(cnvtdate2(person_found->begin_date,"MM/DD/YYYY"),
       cnvttime2(person_found->begin_time,"hh:mm:ss")) AND cnvtdatetime(cnvtdate2(person_found->
        end_date,"MM/DD/YYYY"),cnvttime2(person_found->end_time,"hh:mm:ss"))
       AND  NOT ( EXISTS (
      (SELECT
       1
       FROM encounter e2
       WHERE e2.person_id=pa.person_id
        AND e2.updt_dt_tm > cnvtdatetime(cnvtdate2(person_found->end_date,"MM/DD/YYYY"),cnvttime2(
         person_found->end_time,"hh:mm:ss"))))))
     DETAIL
      personnum += 1, stat = alterlist(person_found->qual,personnum), person_found->qual[personnum].
      person_id = pa.person_id
     WITH counter
    ;end select
   ELSE
    CALL clear(1,1)
    SET message = nowindow
    CALL echo("")
    CALL echo("")
    CALL echo("You must select an alias pool, press enter to exit!")
    CALL accept(1,1,"A;CU","")
    GO TO new_res_xds_res_support_menu
   ENDIF
   CALL clear(1,1)
   CALL text(7,15,build2("Persons found: ",trim(cnvtstring(size(person_found->qual,5)),3)))
   CALL text(8,15,build2("Generate ADTs? Y/N"))
   CALL accept(9,15,"A;CU","N")
   IF (curaccept="Y")
    SET queuestarttime = curtime3
    FOR (x = 1 TO size(person_found->qual,5))
      IF (mod(person_found->adt_processed,5)=1)
       SET queueendtime = curtime3
       SET queuetotaltime = ((queueendtime - queuestarttime)/ 100)
       SET queueestimatedtimeleft = ((queuetotaltime * (size(person_found->qual,5) - person_found->
       adt_processed))/ person_found->adt_processed)
       SET queueestimatedhoursleft = (queueestimatedtimeleft/ 3600)
       SET queueestimatedtimeleft -= (3600 * queueestimatedhoursleft)
       SET queueestimatedminutesleft = (queueestimatedtimeleft/ 60)
       SET queueestimatedtimeleft -= (60 * queueestimatedminutesleft)
       SET queueestimatedsecondsleft = queueestimatedtimeleft
       IF (queueestimatedhoursleft=0
        AND queueestimatedminutesleft=0
        AND queueestimatedsecondsleft=0)
        CALL clear(1,1)
        CALL text(7,15,build2("ADTs Generated: ",trim(cnvtstring(person_found->adt_processed),3),"/",
          trim(cnvtstring(size(person_found->qual,5)),3)))
        CALL text(8,15,build2("Estimated time left: Calculating"))
       ELSEIF (queueestimatedhoursleft > 0)
        CALL clear(1,1)
        CALL text(7,15,build2("ADTs Generated: ",trim(cnvtstring(person_found->adt_processed),3),"/",
          trim(cnvtstring(size(person_found->qual,5)),3)))
        CALL text(8,15,build2("Estimated time left: ",trim(cnvtstring(queueestimatedhoursleft)),
          " Hours ",trim(cnvtstring(queueestimatedminutesleft))," Minutes ",
          trim(cnvtstring(queueestimatedsecondsleft))," Seconds"))
       ELSEIF (queueestimatedminutesleft > 0)
        CALL clear(1,1)
        CALL text(7,15,build2("ADTs Generated: ",trim(cnvtstring(person_found->adt_processed),3),"/",
          trim(cnvtstring(size(person_found->qual,5)),3)))
        CALL text(8,15,build2("Estimated time left: ",trim(cnvtstring(queueestimatedminutesleft)),
          " Minutes ",trim(cnvtstring(queueestimatedsecondsleft))," Seconds"))
       ELSE
        CALL clear(1,1)
        CALL text(7,15,build2("ADTs Generated: ",trim(cnvtstring(person_found->adt_processed),3),"/",
          trim(cnvtstring(size(person_found->qual,5)),3)))
        CALL text(8,15,build2("Estimated time left: ",trim(cnvtstring(queueestimatedsecondsleft)),
          " Seconds"))
       ENDIF
      ENDIF
      CALL trigger_adt_outbound(person_found->qual[x].person_id,0)
      SET person_found->adt_processed += 1
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE get_organization_id(dummy_var)
   DECLARE validorg = i1 WITH noconstant(0)
   DECLARE getorganizationid = f8 WITH noconstant(0)
   DECLARE orgname = vc WITH noconstant("")
   WHILE (validorg=0)
     CALL clear(1,1)
     CALL text(7,15,"Please enter the organization_id:")
     CALL accept(7,51,"##############;;CU","")
     SET getorganizationid = cnvtint(curaccept)
     SELECT INTO "nl:"
      o.organization_id, o.org_name
      FROM organization o
      WHERE o.organization_id=getorganizationid
       AND o.organization_id > 0
      DETAIL
       orgname = o.org_name
      WITH counter, orahintcbo("index(o xpkorganization)")
     ;end select
     IF (curqual > 0)
      CALL clear(1,1)
      CALL text(7,15,"Is this the correct Organization: ")
      CALL text(7,51,orgname)
      CALL accept(8,15,"A;CU","Y")
      IF (curaccept="Y")
       SET validorg = 1
       RETURN(getorganizationid)
      ELSE
       SET getorganizationid = 0
      ENDIF
     ELSE
      CALL clear(1,1)
      CALL text(7,15,"Organization_id was not found! Try again?")
      CALL accept(7,59,"A;CU","Y")
      IF (curaccept != "Y")
       RETURN(0)
      ENDIF
     ENDIF
   ENDWHILE
 END ;Subroutine
 SUBROUTINE (base_64_decode(src_string=vc,first_delimiter=vc,second_delimiter=vc,first_offset=i4,
  second_offset=i4) =vc)
   DECLARE ipos1 = i4 WITH private, noconstant(0)
   DECLARE ipos2 = i4 WITH private, noconstant(0)
   DECLARE iinblobsize = i4 WITH private, noconstant(0)
   DECLARE ioutbufsize = i4 WITH private, noconstant(0)
   DECLARE ioutblobsize = i4 WITH private, noconstant(0)
   DECLARE strblob = vc WITH private, noconstant("")
   DECLARE strtempblob = vc WITH private, noconstant("")
   DECLARE strinblob = vc WITH private, noconstant("")
   DECLARE decodedstr = vc WITH private, noconstant("")
   DECLARE base64padding = vc WITH private, constant("=")
   IF (first_delimiter="")
    SET ipos1 = 1
   ELSE
    SET ipos1 = (findstring(first_delimiter,src_string)+ first_offset)
   ENDIF
   IF (second_delimiter="")
    SET ipos2 = size(src_string)
   ELSE
    SET ipos2 = (findstring(second_delimiter,src_string,ipos1)+ second_offset)
   ENDIF
   SET strblob = substring(ipos1,(ipos2 - ipos1),src_string)
   WHILE ( NOT (mod(size(strblob),4) IN (0, 1)))
     SET strblob = build(strblob,base64padding)
   ENDWHILE
   SET iinblobsize = size(strblob)
   SET strtempblob = strblob
   SET strinblob = strblob
   SET ioutbufsize = size(strtempblob)
   SET bretstat = uar_si_decode_base64(strinblob,iinblobsize,strtempblob,ioutbufsize,ioutblobsize)
   SET decodedstr = substring(1,ioutblobsize,strtempblob)
   RETURN(decodedstr)
 END ;Subroutine
 SUBROUTINE (write_prompt_program(prompt_file_name=vc,prompt_base64_body=vc) =vc)
   DECLARE prompt_body_string = vc WITH noconstant("")
   DECLARE prompt_formatted_file_name = vc WITH noconstant("")
   SET prompt_formatted_file_name = build2(trim(logical("CCLUSERDIR"),3),"/",prompt_file_name)
   SET prompt_body_string = base_64_decode(prompt_base64_body,"","",0,0)
   CALL write_file(build2(prompt_formatted_file_name),prompt_body_string,"wb")
   CALL clear(1,1)
   CALL text(7,15,"Import completed! Please review the audit file:")
   CALL text(8,15,build("File location: ",prompt_formatted_file_name))
   CALL text(11,15,"Press enter to continue:")
   CALL accept(12,15,"#;;CU","")
 END ;Subroutine
 SUBROUTINE (write_output(prompt_file_name=vc,prompt_base64_body=vc) =vc)
   DECLARE prompt_body_string = vc WITH noconstant("")
   DECLARE prompt_formatted_file_name = vc WITH noconstant("")
   SET prompt_formatted_file_name = build2(trim(logical("CCLUSERDIR"),3),"/",prompt_file_name)
   SET prompt_body_string = prompt_base64_body
   CALL write_file(build2(prompt_formatted_file_name),prompt_body_string,"wb")
   CALL clear(1,1)
   CALL text(7,15,"Import completed!")
   CALL text(8,15,build("File location: ",prompt_formatted_file_name))
   CALL text(11,15,"Press enter to continue:")
   CALL accept(12,15,"#;;CU","")
 END ;Subroutine
 SUBROUTINE (write_keystore(prompt_file_name=vc,prompt_base64_body=vc,prompt_eof_char=i4) =vc)
   DECLARE prompt_body_string = vc WITH noconstant("")
   DECLARE prompt_formatted_file_name = vc WITH noconstant("")
   IF (prompt_eof_char > 0)
    SET prompt_body_string = build2(base_64_decode(prompt_base64_body,"","",0,0),char(prompt_eof_char
      ))
   ELSE
    SET prompt_body_string = build2(base_64_decode(prompt_base64_body,"","",0,0))
   ENDIF
   CALL write_file(build2(prompt_file_name),prompt_body_string,"wb")
   CALL clear(1,1)
   CALL text(7,15,"Import completed!")
   CALL text(8,15,build("File location: ",prompt_file_name))
   CALL text(11,15,"Press enter to continue:")
   CALL accept(12,15,"#;;CU","")
 END ;Subroutine
 SUBROUTINE (estimated_resonance_report(users_logical_domain_id=f8) =c1)
   FREE RECORD est_volume
   RECORD est_volume(
     1 prevdayoftheweek = i4
     1 prevfriday = i4
     1 currentdate = dq8
     1 previousdate = dq8
     1 startdatetime = dq8
     1 enddatetime = dq8
     1 avg_adt_volume = i4
     1 avg_provide_volume = i4
     1 avg_query_volume = i4
     1 logical_domain[*]
       2 mnemonic = vc
       2 logical_domain_id = f8
       2 total_adt = i4
       2 total_query = i4
       2 total_provide = i4
       2 organization[*]
         3 org_name = vc
         3 organization_id = f8
         3 est_adt_volume = i4
         3 est_provide_volume = i4
         3 est_query_volume = i4
   )
   DECLARE logicaldomainid = f8 WITH noconstant(0)
   DECLARE logical_domain_index = i4 WITH noconstant(0)
   DECLARE organization_index = i4 WITH noconstant(0)
   SET logicaldomainid = get_logical_domain_id(users_logical_domain_id)
   IF ((logicaldomainid=- (1)))
    GO TO res_import_prgs_and_prompts_menu
   ENDIF
   SET est_volume->currentdate = curdate
   SET est_volume->previousdate = (est_volume->currentdate - 1)
   IF (weekday(est_volume->previousdate)=0)
    SET est_volume->startdatetime = cnvtdatetime((cnvtdate(est_volume->previousdate) - 2),0000)
    SET est_volume->enddatetime = cnvtdatetime((cnvtdate(est_volume->previousdate) - 2),2359)
   ELSEIF (weekday(est_volume->previousdate)=6)
    SET est_volume->startdatetime = cnvtdatetime((cnvtdate(est_volume->previousdate) - 1),0000)
    SET est_volume->enddatetime = cnvtdatetime((cnvtdate(est_volume->previousdate) - 1),2359)
   ELSE
    SET est_volume->startdatetime = cnvtdatetime((curdate - 1),0000)
    SET est_volume->enddatetime = cnvtdatetime((curdate - 1),2359)
   ENDIF
   CALL echo(build2("  est_volume->currentDate = ",format(est_volume->currentdate,
      "MM/DD/YYYY hh:mm:ss;;Q")))
   CALL echo(build2("est_volume->startDateTime = ",format(est_volume->startdatetime,
      "MM/DD/YYYY hh:mm:ss;;Q")))
   CALL echo(build2("  est_volume->endDateTime = ",format(est_volume->enddatetime,
      "MM/DD/YYYY hh:mm:ss;;Q")))
   SET message = nowindow
   CALL clear(1,1)
   CALL echo("Gathering ADT estimates...")
   SELECT INTO "nl"
    ld.mnemonic, ld.logical_domain_id, o.org_name,
    o.organization_id, e.updt_cnt, transaction_count = count(*)
    FROM encounter e,
     organization o,
     logical_domain ld
    PLAN (e
     WHERE e.updt_dt_tm BETWEEN cnvtdatetime(est_volume->startdatetime) AND cnvtdatetime(est_volume->
      enddatetime))
     JOIN (o
     WHERE (o.organization_id= Outerjoin(e.organization_id))
      AND o.logical_domain_id=logicaldomainid)
     JOIN (ld
     WHERE ld.logical_domain_id=o.logical_domain_id)
    GROUP BY ld.mnemonic, ld.logical_domain_id, o.org_name,
     o.organization_id, e.updt_cnt
    ORDER BY o.org_name
    DETAIL
     logical_domain_index = 0, organization_index = 0
     FOR (x = 1 TO size(est_volume->logical_domain,5))
       IF ((est_volume->logical_domain[x].logical_domain_id=ld.logical_domain_id))
        logical_domain_index = x, x = (size(est_volume->logical_domain,5)+ 1)
       ENDIF
     ENDFOR
     IF ( NOT (logical_domain_index > 0))
      logical_domain_index = (size(est_volume->logical_domain,5)+ 1), stat = alterlist(est_volume->
       logical_domain,logical_domain_index), est_volume->logical_domain[logical_domain_index].
      logical_domain_id = ld.logical_domain_id,
      est_volume->logical_domain[logical_domain_index].mnemonic = ld.mnemonic
     ENDIF
     FOR (y = 1 TO size(est_volume->logical_domain[logical_domain_index].organization,5))
       IF ((est_volume->logical_domain[logical_domain_index].organization[y].organization_id=o
       .organization_id))
        IF (e.updt_cnt > 0)
         est_volume->logical_domain[logical_domain_index].organization[y].est_adt_volume += (
         transaction_count * e.updt_cnt)
        ELSE
         est_volume->logical_domain[logical_domain_index].organization[y].est_adt_volume +=
         transaction_count
        ENDIF
        organization_index = y, y = (size(est_volume->logical_domain[logical_domain_index].
         organization,5)+ 1)
       ENDIF
     ENDFOR
     IF ( NOT (organization_index > 0))
      organization_index = (size(est_volume->logical_domain[logical_domain_index].organization,5)+ 1),
      stat = alterlist(est_volume->logical_domain[logical_domain_index].organization,
       organization_index), est_volume->logical_domain[logical_domain_index].organization[
      organization_index].organization_id = o.organization_id,
      est_volume->logical_domain[logical_domain_index].organization[organization_index].org_name = o
      .org_name
      IF (e.updt_cnt > 0)
       est_volume->logical_domain[logical_domain_index].organization[organization_index].
       est_adt_volume = (transaction_count * e.updt_cnt)
      ELSE
       est_volume->logical_domain[logical_domain_index].organization[organization_index].
       est_adt_volume = transaction_count
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   SET message = nowindow
   CALL clear(1,1)
   CALL echo("Gathering ADT estimates...Completed!")
   CALL echo("Gathering provide estimates...")
   SELECT INTO "nl"
    ld.mnemonic, ld.logical_domain_id, o.org_name,
    o.organization_id, transaction_count = count(*)
    FROM encounter e,
     organization o,
     logical_domain ld
    PLAN (e
     WHERE e.disch_dt_tm BETWEEN cnvtdatetime(est_volume->startdatetime) AND cnvtdatetime(est_volume
      ->enddatetime)
      AND e.active_ind=1)
     JOIN (o
     WHERE (o.organization_id= Outerjoin(e.organization_id))
      AND o.logical_domain_id=logicaldomainid)
     JOIN (ld
     WHERE ld.logical_domain_id=o.logical_domain_id)
    GROUP BY ld.mnemonic, ld.logical_domain_id, o.org_name,
     o.organization_id
    ORDER BY o.org_name
    DETAIL
     logical_domain_index = 0, organization_index = 0
     FOR (x = 1 TO size(est_volume->logical_domain,5))
       IF ((est_volume->logical_domain[x].logical_domain_id=ld.logical_domain_id))
        logical_domain_index = x, x = (size(est_volume->logical_domain,5)+ 1)
       ENDIF
     ENDFOR
     IF ( NOT (logical_domain_index > 0))
      logical_domain_index = (size(est_volume->logical_domain,5)+ 1), stat = alterlist(est_volume->
       logical_domain,logical_domain_index), est_volume->logical_domain[logical_domain_index].
      logical_domain_id = ld.logical_domain_id,
      est_volume->logical_domain[logical_domain_index].mnemonic = ld.mnemonic
     ENDIF
     FOR (y = 1 TO size(est_volume->logical_domain[logical_domain_index].organization,5))
       IF ((est_volume->logical_domain[logical_domain_index].organization[y].organization_id=o
       .organization_id))
        est_volume->logical_domain[logical_domain_index].organization[y].est_provide_volume =
        transaction_count, organization_index = y, y = (size(est_volume->logical_domain[
         logical_domain_index].organization,5)+ 1)
       ENDIF
     ENDFOR
     IF ( NOT (organization_index > 0))
      organization_index = (size(est_volume->logical_domain[logical_domain_index].organization,5)+ 1),
      stat = alterlist(est_volume->logical_domain[logical_domain_index].organization,
       organization_index), est_volume->logical_domain[logical_domain_index].organization[
      organization_index].organization_id = o.organization_id,
      est_volume->logical_domain[logical_domain_index].organization[organization_index].org_name = o
      .org_name, est_volume->logical_domain[logical_domain_index].organization[organization_index].
      est_provide_volume = transaction_count
     ENDIF
    WITH nocounter
   ;end select
   SET message = nowindow
   CALL clear(1,1)
   CALL echo("Gathering ADT estimates...Completed!")
   CALL echo("Gathering provide estimates...Completed!")
   CALL echo("Gathering auto-query estimates...")
   SELECT INTO "nl"
    ld.mnemonic, ld.logical_domain_id, o.org_name,
    o.organization_id, transaction_count = count(*)
    FROM pm_transaction pt,
     encounter e,
     organization o,
     logical_domain ld
    PLAN (pt
     WHERE pt.updt_dt_tm BETWEEN cnvtdatetime(est_volume->startdatetime) AND cnvtdatetime(est_volume
      ->enddatetime)
      AND pt.transaction="ADMT")
     JOIN (e
     WHERE e.encntr_id=pt.n_encntr_id)
     JOIN (o
     WHERE o.organization_id=e.organization_id
      AND o.logical_domain_id=logicaldomainid)
     JOIN (ld
     WHERE ld.logical_domain_id=o.logical_domain_id)
    GROUP BY ld.mnemonic, ld.logical_domain_id, o.org_name,
     o.organization_id
    ORDER BY o.org_name
    DETAIL
     logical_domain_index = 0, organization_index = 0
     FOR (x = 1 TO size(est_volume->logical_domain,5))
       IF ((est_volume->logical_domain[x].logical_domain_id=ld.logical_domain_id))
        logical_domain_index = x, x = (size(est_volume->logical_domain,5)+ 1)
       ENDIF
     ENDFOR
     IF ( NOT (logical_domain_index > 0))
      logical_domain_index = (size(est_volume->logical_domain,5)+ 1), stat = alterlist(est_volume->
       logical_domain,logical_domain_index), est_volume->logical_domain[logical_domain_index].
      logical_domain_id = ld.logical_domain_id,
      est_volume->logical_domain[logical_domain_index].mnemonic = ld.mnemonic
     ENDIF
     FOR (y = 1 TO size(est_volume->logical_domain[logical_domain_index].organization,5))
       IF ((est_volume->logical_domain[logical_domain_index].organization[y].organization_id=o
       .organization_id))
        est_volume->logical_domain[logical_domain_index].organization[y].est_query_volume =
        transaction_count, organization_index = y, y = (size(est_volume->logical_domain[
         logical_domain_index].organization,5)+ 1)
       ENDIF
     ENDFOR
     IF ( NOT (organization_index > 0))
      organization_index = (size(est_volume->logical_domain[logical_domain_index].organization,5)+ 1),
      stat = alterlist(est_volume->logical_domain[logical_domain_index].organization,
       organization_index), est_volume->logical_domain[logical_domain_index].organization[
      organization_index].organization_id = o.organization_id,
      est_volume->logical_domain[logical_domain_index].organization[organization_index].org_name = o
      .org_name, est_volume->logical_domain[logical_domain_index].organization[organization_index].
      est_query_volume = transaction_count
     ENDIF
    WITH nocounter
   ;end select
   SET message = nowindow
   CALL clear(1,1)
   FOR (x = 1 TO size(est_volume->logical_domain,5))
     CALL echo("")
     IF ((est_volume->logical_domain[x].mnemonic=""))
      CALL echo(build2("Logical Domain:  Default Logical Domain"))
      CALL echo(build2("Logical Domain ID: ",trim(cnvtstring(est_volume->logical_domain[x].
          logical_domain_id))))
     ELSE
      CALL echo(build2("Logical Domain: ",est_volume->logical_domain[x].mnemonic))
      CALL echo(build2("Logical Domain ID: ",trim(cnvtstring(est_volume->logical_domain[x].
          logical_domain_id))))
     ENDIF
     CALL echo("")
     FOR (y = 1 TO size(est_volume->logical_domain[x].organization,5))
       CALL echo(build2("  Organization Name: ",est_volume->logical_domain[x].organization[y].
         org_name))
       CALL echo(build2("           Estimated ADT Volume: ",trim(cnvtstring(est_volume->
           logical_domain[x].organization[y].est_adt_volume))))
       CALL echo(build2("    Estimated Auto-Query Volume: ",trim(cnvtstring(est_volume->
           logical_domain[x].organization[y].est_query_volume))))
       CALL echo(build2("       Estimated Provide Volume: ",trim(cnvtstring(est_volume->
           logical_domain[x].organization[y].est_provide_volume))))
       CALL echo("")
       CALL echo("")
       CALL echo("")
       SET est_volume->logical_domain[x].total_adt += est_volume->logical_domain[x].organization[y].
       est_adt_volume
       SET est_volume->logical_domain[x].total_provide += est_volume->logical_domain[x].organization[
       y].est_provide_volume
       SET est_volume->logical_domain[x].total_query += est_volume->logical_domain[x].organization[y]
       .est_query_volume
     ENDFOR
     CALL echo("")
     CALL echo("")
     CALL echo("")
     CALL echo(build2("        Total Estimated ADTs: ",trim(cnvtstring(est_volume->logical_domain[x].
         total_adt))))
     CALL echo(build2("Total Estimated Auto-Queries: ",trim(cnvtstring(est_volume->logical_domain[x].
         total_query))))
     CALL echo(build2("    Total Estimated Provides: ",trim(cnvtstring(est_volume->logical_domain[x].
         total_provide))))
     CALL echo("")
     CALL echo("")
     CALL echo("")
     CALL echo("Scroll up to view estimates")
     CALL echo("Press enter to continue:")
     CALL accept(1,1,"A;CU","")
   ENDFOR
 END ;Subroutine
 SUBROUTINE write_resonance_cert_keystore(null)
   DECLARE version_num = vc WITH constant("v1")
   DECLARE client_mnemonic_string = vc WITH noconstant("")
   DECLARE resonance_cert_keystore_base64 = vc WITH noconstant("")
   DECLARE resonance_cert_keystore_file_name = vc WITH noconstant("")
   DECLARE eof_char = i4 WITH constant(24)
   DECLARE raw_keystore_path = vc WITH noconstant("")
   DECLARE keystore_path = vc WITH noconstant("")
   DECLARE keystore_password = vc WITH noconstant("")
   DECLARE keystore_name = vc WITH noconstant("")
   DECLARE default_resonance_comserver_name = vc WITH constant("RESONANCE")
   DECLARE keystore_private_key = vc WITH noconstant("")
   DECLARE keystore_signkeyalias = vc WITH noconstant("")
   DECLARE cur_date_fomatted = vc WITH constant(datetimezoneformat(cnvtdatetime(sysdate),
     curtimezoneapp,"DD-MM-YYYY-HH-mm-ss"))
   SET resonance_cert_keystore_file_name = trim(build2("oen_xds_keystore_",cur_date_fomatted),3)
   SET resonance_cert_keystore_base64 = build2(
    "/u3+7QAAAAIAAAADAAAAAgAOZGlnaWNlcnRyb290Y2EAAAFZBE8rlgAFWC41MDkAAAOqMIIDpjCCAo6gAwIBAgIBMzANBgkqhki",
    "G9w0BAQsFADBkMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMS",
    "MwIQYDVQQDExpEaWdpQ2VydCBUZXN0IFJvb3QgQ0EgU0hBMjAeFw0wNjExMTAwMDAwMDBaFw0zMTExMTAwMDAwMDBaMGQxCzAJB",
    "gNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xIzAhBgNVBAMTGkRpZ2lD",
    "ZXJ0IFRlc3QgUm9vdCBDQSBTSEEyMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA0DLGgpMXqI2YZ15ULS61yqyqiBM",
    "pmRtM9/w/1pqoA/GEri19VMFuvtPTWgu9IQf0dQsRMy2d8V4INSj43YyQeXnxPzanTSqza95yoH/h4xUM/pNqAlXlO8c+cYMyCD",
    "zTQ0vrEWcvPZOtXYABac9E9ceT015RdD5pORjMwTcb6NxydZr8nRd9/J66L4R17IKvTU74IwA6fwNd0UnXbhVhGdeEAe+eIEvJ5",
    "WlWxDeS6ZdZuSZvh24QxhxpucTzSq81HHCHw4a1kOel2oqlDlUY698atS0nxfw3IR30heQ/g793Mce9SX9u2dPPAZtSaW8/38Tw",
    "KbNOa9zkRFn7oF+cZQIDAQABo2MwYTAOBgNVHQ8BAf8EBAMCAYYwDwYDVR0TAQH/BAUwAwEB/zAdBgNVHQ4EFgQU9kZ+Gxa7N5l",
    "j9z/YhSzkyepYDx4wHwYDVR0jBBgwFoAU9kZ+Gxa7N5lj9z/YhSzkyepYDx4wDQYJKoZIhvcNAQELBQADggEBAAeQacFm1sFPOI",
    "EvXDVi3IH2RKF7he0p/M0bK2Soj137LMf+ctpM3bFKJPY97YIE0g7T1qgR8TN2sK0moumMTPjWCdFWJyN4yakS6tPIWEG2XobJ9",
    "H1riuVXLKd2M/1yhqUyt1o5KtbOGQXLFd3qdp4A1tcXuK2wyMTiSCYS3Uow61JdEw6MeyrMIpZl9GtvaXTz6LdnozAbhKC7bVUy",
    "7ob0T4E03fQ8hIQCNPupvY7Db1/XmIw8QWVd6AOH7EE3P8xbWOvcTWZ5XbstWY014GeJFXZ7YreaAg8sYa6CzasuHkr/rxeZ8yz",
    "OmCTTTSPk5Ju5bTfAyEpgkl5fDvntJQgAAAACABZkaWdpY2VydGludGVybWVkaWF0ZWNhAAABWQROd0MABVguNTA5AAAGTTCCBk",
    "kwggUxoAMCAQICBDOqqqowDQYJKoZIhvcNAQELBQAwZDELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA",
    "1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEjMCEGA1UEAxMaRGlnaUNlcnQgVGVzdCBSb290IENBIFNIQTIwHhcNMDYxMTEwMDAwMDAw",
    "WhcNMzExMTEwMDAwMDAwWjBxMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWN",
    "lcnQuY29tMTAwLgYDVQQDEydEaWdpQ2VydCBUZXN0IEludGVybWVkaWF0ZSBSb290IENBIFNIQTIwggEiMA0GCSqGSIb3DQEBAQ",
    "UAA4IBDwAwggEKAoIBAQCYmoVPoEPAa5nKL9S8L8pyyoMTHG7qo3smHogxFF7UxCSqD5tT3OWBN/XwWNcncGgSepNy2y2TPs6sN",
    "qQl8Gn+CwYS77eKaRzH15YCNiFaVom0mFXLyeMGg9PQEOO7v0kIQx0lX9ex0VCLNbSMPjDKTMhh9PWM4CP2SOSk1gWPp5Z8/bdf",
    "0aT3XCXwFop90/7O8Tbt+uDhQ1EV/t0cW+21Z1dcSBmVMEMdtxhnEp8qbH5a9awXNsr12lJ8JeA20DFKNdLXWbXdcGTUBNwtS9z",
    "F53b59FnRQeHDOpEJUpMtERVvkyakCDJm9vZ9PT/3s+yKaNHKVd75QQAtA1pts/xTAgMBAAGjggL0MIIC8DAOBgNVHQ8BAf8EBA",
    "MCAYYwggHGBgNVHSAEggG9MIIBuTCCAbUGC2CGSAGG/WwBAwACMIIBpDA6BggrBgEFBQcCARYuaHR0cDovL3d3dy5kaWdpY2Vyd",
    "C5jb20vc3NsLWNwcy1yZXBvc2l0b3J5Lmh0bTCCAWQGCCsGAQUFBwICMIIBVh6CAVIAQQBuAHkAIAB1AHMAZQAgAG8AZgAgAHQA",
    "aABpAHMAIABDAGUAcgB0AGkAZgBpAGMAYQB0AGUAIABjAG8AbgBzAHQAaQB0AHUAdABlAHMAIABhAGMAYwBlAHAAdABhAG4AYwB",
    "lACAAbwBmACAAdABoAGUAIABEAGkAZwBpAEMAZQByAHQAIABDAFAALwBDAFAAUwAgAGEAbgBkACAAdABoAGUAIABSAGUAbAB5AG",
    "kAbgBnACAAUABhAHIAdAB5ACAAQQBnAHIAZQBlAG0AZQBuAHQAIAB3AGgAaQBjAGgAIABsAGkAbQBpAHQAIABsAGkAYQBiAGkAb",
    "ABpAHQAeQAgAGEAbgBkACAAYQByAGUAIABpAG4AYwBvAHIAcABvAHIAYQB0AGUAZAAgAGgAZQByAGUAaQBuACAAYgB5ACAAcgBl",
    "AGYAZQByAGUAbgBjAGUALjAPBgNVHRMBAf8EBTADAQH/MDgGCCsGAQUFBwEBBCwwKjAoBggrBgEFBQcwAYYcaHR0cDovL29jc3B",
    "0ZXN0LmRpZ2ljZXJ0LmNvbTCBiAYDVR0fBIGAMH4wPaA7oDmGN2h0dHA6Ly9jcmwzdGVzdC5kaWdpY2VydC5jb20vRGlnaUNlcn",
    "RUZXN0Um9vdENBU0hBMi5jcmwwPaA7oDmGN2h0dHA6Ly9jcmw0dGVzdC5kaWdpY2VydC5jb20vRGlnaUNlcnRUZXN0Um9vdENBU",
    "0hBMi5jcmwwHQYDVR0OBBYEFIlV/Ym84hA8+21OHzD5+YKLXGHiMB8GA1UdIwQYMBaAFPZGfhsWuzeZY/c/2IUs5MnqWA8eMA0G",
    "CSqGSIb3DQEBCwUAA4IBAQCxcT8ZHB4GlwbqGddBRlrKt28mxp8QupZXwxE3Flaz2o7ncWrJvBFzk0lZ6ijSF2U5ZtQWNHIYZ1R",
    "gN2MjTe1xe1609R7UR+TQ4VjtpcxRBkhS8IZQohkAbsyjnpWwVg4aTe4nJvmP7vgz2iuqBbtLV/7vZD86HPDmEgXuNdrBwA9f5Z",
    "FAzwBDuMh0lw56HtH4ZNuP8grjulnPpjHu2F8xJKvKThFozcP/RNXbD9tC+4w9xfe6ublTXtcBGnhN1ORKtcSlAXckKorYp6U7/",
    "8qP1D0wy6X4wZitp4dhyuq9ER/mAjonKkPfTfqumHgJYXoy2u/uxZCmCitWBAGxNSHHAAAAAgAncnNuY3N2Y2RlZmF1bHRfY2Vy",
    "dF9jZXJuZXJyZXNvbmFuY2VfY29tAAABWQRPWucABVguNTA5AAAFlzCCBZMwggR7oAMCAQICEAJnPLgYhe3Y78tPy+MvzKAwDQY",
    "JKoZIhvcNAQELBQAwcTELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0Lm",
    "NvbTEwMC4GA1UEAxMnRGlnaUNlcnQgVGVzdCBJbnRlcm1lZGlhdGUgUm9vdCBDQSBTSEEyMB4XDTE2MTExMDAwMDAwMFoXDTE3M",
    "TExMDEyMDAwMFowgZAxCzAJBgNVBAYTAlVTMREwDwYDVQQIEwhNaXNzb3VyaTEUMBIGA1UEBxMLS2Fuc2FzIENpdHkxJjAkBgNV",
    "BAoTHUNlcm5lciBDb3Jwb3JhdGlvbi0gUmVzb25hbmNlMTAwLgYDVQQDEydyc25jc3ZjZGVmYXVsdC5jZXJ0LmNlcm5lcnJlc29",
    "uYW5jZS5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCNMM/8hey5MGROHQX9qT77tpBWLceXX0frGwm0BuGgC2",
    "yWMwJmo1CjFEBERf2YcN0x/rZMxA3SZO4cCBJdRmGzflruiyCVHW4H0YoT4jm4PKUGxYSNwVnteoBJXVkl6QFeB6aRlnj6Vq7aV",
    "FBp9FI0bPRMICXt9bjX6ezpVjDDBVZnBXsOJrpbNooym8S3rNE02oHKVQRoiD1iOKUUSYcKA5rwzqAURc+qxWevd9ZyFrfry9eI",
    "gxoOWKqD/nHqJ8wFBNK98oxD1yE99EVVRFfXwuAlaBcDB5xo5BL4ZCoY1aXncaSC120cSGqCO4Dl3Z1oRiw+m83aq+ZsUKOANmN",
    "DAgMBAAGjggIFMIICATAfBgNVHSMEGDAWgBSJVf2JvOIQPPttTh8w+fmCi1xh4jAdBgNVHQ4EFgQU22Z0au2RHHcHsmTN7x/bLQ",
    "ZNjnAwMgYDVR0RBCswKYIncnNuY3N2Y2RlZmF1bHQuY2VydC5jZXJuZXJyZXNvbmFuY2UuY29tMA4GA1UdDwEB/wQEAwIFoDAdB",
    "gNVHSUEFjAUBggrBgEFBQcDAQYIKwYBBQUHAwIwgZUGA1UdHwSBjTCBijBDoEGgP4Y9aHR0cDovL2NybDN0ZXN0LmRpZ2ljZXJ0",
    "LmNvbS9EaWdpQ2VydFRlc3RJbnRlcm1lZGlhdGVTSEEyLmNybDBDoEGgP4Y9aHR0cDovL2NybDN0ZXN0LmRpZ2ljZXJ0LmNvbS9",
    "EaWdpQ2VydFRlc3RJbnRlcm1lZGlhdGVTSEEyLmNybDAwBgNVHSAEKTAnMA0GC2CGSAGG/WxjAAIEMAwGCmCGSAGG/WxjAQswCA",
    "YGZ4EMAQICMIGDBggrBgEFBQcBAQR3MHUwKAYIKwYBBQUHMAGGHGh0dHA6Ly9vY3NwdGVzdC5kaWdpY2VydC5jb20wSQYIKwYBB",
    "QUHMAKGPWh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRlc3RJbnRlcm1lZGlhdGUtU0hBMi5jcnQwDAYDVR0T",
    "AQH/BAIwADANBgkqhkiG9w0BAQsFAAOCAQEATMPoC39fzElddRfEz6iVgSEsABODBBa3wmGANnVfhB9L86LCyL+WA0zyNnkVt13",
    "lSVm/PCyAuHndkBtzcHmxA0cWhSurT0sx7jn3uHDd7AaUEp3ywhzllxzJ3EANayE3K4MATnU2mOO+dZCpxEMtFkJ8soMMdm8HnQ",
    "dp93YFD0+BoVgloMkfZYdgtKsCty492Ceh0KcN0m/UwGsEspJ+Cn24qvlsokwMWZZTW7nGI/Cm9yauVASrmmzoDSHA29gJ02bnQ",
    "HUfqKLe82vZAYZeFhAkyUR+u6+hRYde0aHS4gUyiFlkcaqnFIuSFulWZh4dtOXCZQMvX6Tehc96fvl0kgaKwIhN+eGkQ2TYc1zg",
    "8e34osEY")
   SELECT DISTINCT INTO "nl:"
    sop.property_name, sop.property_value_txt
    FROM si_oen_comchannel soc,
     si_oen_chann_endpoint_r socer,
     si_oen_endpoint soe,
     si_oen_property sop,
     si_oen_context sc
    PLAN (sc
     WHERE cnvtupper(sc.context_name)=default_resonance_comserver_name)
     JOIN (soc
     WHERE soc.si_oen_context_id=sc.si_oen_context_id)
     JOIN (socer
     WHERE socer.si_oen_comchannel_id=soc.si_oen_comchannel_id)
     JOIN (soe
     WHERE soe.si_oen_endpoint_id=socer.si_oen_endpoint_id)
     JOIN (sop
     WHERE sop.property_set_id=soe.connection_property_id
      AND sop.property_name IN ("keystore", "keystorePassword"))
    ORDER BY sop.property_name
    DETAIL
     IF (sop.property_name="keystore")
      raw_keystore_path = trim(sop.property_value_txt,3), keystore_name = substring((findstring("/",
        raw_keystore_path,1,1)+ 1),size(raw_keystore_path,1),raw_keystore_path), keystore_path = trim
      (substring(findstring("/",raw_keystore_path,1,0),((findstring("/",raw_keystore_path,1,1) -
        findstring("/",raw_keystore_path,1,0))+ 1),raw_keystore_path),3)
     ELSEIF (sop.property_name="keystorePassword")
      keystore_password = trim(sop.property_value_txt,3)
     ENDIF
    WITH nocounter
   ;end select
   IF ( NOT (size(trim(keystore_path,3),1) > 0))
    SET keystore_path = build2(trim(logical("CCLUSERDIR"),3),"/")
   ENDIF
   IF ( NOT (size(trim(keystore_password,3),1) > 0))
    SET keystore_password = "NOT FOUND"
   ENDIF
   SELECT DISTINCT INTO "nl:"
    sop.property_name, sop.property_value_txt
    FROM si_oen_comchannel soc,
     si_oen_chann_endpoint_r socer,
     si_oen_endpoint soe,
     si_oen_property sop,
     si_oen_context sc
    PLAN (sc
     WHERE cnvtupper(sc.context_name)="RESONANCE")
     JOIN (soc
     WHERE soc.si_oen_context_id=sc.si_oen_context_id)
     JOIN (socer
     WHERE socer.si_oen_comchannel_id=soc.si_oen_comchannel_id)
     JOIN (soe
     WHERE soe.si_oen_endpoint_id=socer.si_oen_endpoint_id)
     JOIN (sop
     WHERE sop.property_set_id=soe.protocol_property_id
      AND sop.property_name IN ("signKeyAlias"))
    ORDER BY sop.property_name
    DETAIL
     IF (sop.property_name="signKeyAlias")
      keystore_signkeyalias = trim(sop.property_value_txt,3), keystore_private_key = trim(sop
       .property_value_txt,3)
     ENDIF
    WITH nocounter
   ;end select
   IF ( NOT (size(trim(keystore_private_key,3),1) > 0))
    SET keystore_private_key =
    "NOT FOUND - Using default alias (please check comchannels for valid signKeyAlias)"
    SET keystore_signkeyalias = currentdomain
   ENDIF
   CALL write_keystore(build2(keystore_path,resonance_cert_keystore_file_name),
    resonance_cert_keystore_base64,eof_char)
   SET client_mnemonic_string = cnvtalphanum(get_client_mnemonic(1))
   IF (client_mnemonic_string="unknown")
    SET client_mnemonic_string = "<client_mnemonic>"
   ENDIF
   CALL clear(1,1)
   CALL text(3,2,"DEFAULT keystore password is changeit")
   CALL text(4,2,build2("CURRENT keystore password is ",keystore_password))
   CALL text(5,2,build2("CURRENT signKeyAlias is ",keystore_private_key))
   CALL text(7,2,"Please update password before creating the private key:")
   CALL text(8,2,build2("keytool -storepasswd -keystore ",resonance_cert_keystore_file_name))
   CALL text(10,2,"1. Creating private key: ")
   CALL text(11,2,build2("  keytool -genkey -alias ",keystore_signkeyalias," -keyalg RSA -keystore ",
     resonance_cert_keystore_file_name," -keysize 2048 -sigalg SHA256withRSA"))
   CALL text(12,2,build2("       What is your first and last name?: ",client_mnemonic_string,
     ".cert.cernerresonance.com "))
   CALL text(13,2,build2("            What is the name of your OU?: Millennium"))
   CALL text(14,2,build2("  What is the name of your Organization?: Cerner"))
   CALL text(15,2,build2("          What is the name of your city?: Kansas City"))
   CALL text(16,2,build2("         What is the name of your state?: Missouri"))
   CALL text(17,2,build2("    What is the two-letter country code?: US"))
   CALL text(18,2,build2(" "))
   CALL text(19,2,build2("2. Generate CSR (all on one line):"))
   CALL text(20,2,build2("keytool -keystore ",resonance_cert_keystore_file_name," -certreq -alias ",
     keystore_signkeyalias," -file ad_",
     keystore_signkeyalias,"_csr -keysize 2048 -sigalg SHA256withRSA"))
   CALL accept(1,1,"A;CU","")
 END ;Subroutine
 SUBROUTINE get_client_mnemonic(dummy_var)
   DECLARE client_mnemonic = vc WITH protect, noconstant("")
   SET client_mnemonic = logical("CLIENT_MNEMONIC")
   IF (client_mnemonic="")
    SELECT INTO "nl:"
     d.info_char
     FROM dm_info d
     WHERE d.info_domain="DATA MANAGEMENT"
      AND d.info_name="CLIENT MNEMONIC"
     DETAIL
      client_mnemonic = trim(d.info_char)
     WITH nocounter
    ;end select
   ENDIF
   IF (client_mnemonic="")
    SET client_mnemonic = "unknown"
   ENDIF
   SET client_mnemonic = trim(client_mnemonic,3)
   RETURN(cnvtlower(client_mnemonic))
 END ;Subroutine
 SUBROUTINE write_resonance_prod_keystore(null)
   DECLARE version_num = vc WITH constant("v1")
   DECLARE client_mnemonic_string = vc WITH noconstant("")
   DECLARE resonance_prod_keystore_base64 = vc WITH noconstant("")
   DECLARE resonance_prod_keystore_file_name = vc WITH noconstant("")
   DECLARE eof_char = i4 WITH constant(109)
   DECLARE raw_keystore_path = vc WITH noconstant("")
   DECLARE keystore_path = vc WITH noconstant("")
   DECLARE keystore_password = vc WITH noconstant("")
   DECLARE keystore_name = vc WITH noconstant("")
   DECLARE default_resonance_comserver_name = vc WITH constant("RESONANCE")
   DECLARE keystore_private_key = vc WITH noconstant("")
   DECLARE keystore_signkeyalias = vc WITH noconstant("")
   DECLARE cur_date_fomatted = vc WITH constant(datetimezoneformat(cnvtdatetime(sysdate),
     curtimezoneapp,"DD-MM-YYYY-HH-mm-ss"))
   SET resonance_prod_keystore_file_name = trim(build2("oen_xds_keystore_",cur_date_fomatted),3)
   SET resonance_prod_keystore_base64 = build2(
    "/u3+7QAAAAIAAAAFAAAAAgBQY2VybmVyIGNvcnBvcmF0aW9uIHJlc29uYW5jZSBpbnRlcm1lZGlhdGUgY2",
    "EgZzIgKGRpZ2ljZXJ0IGRpcmVjdCBzZWN1cmUgcm9vdCBjYSkAAAF65JjEbgAFWC41MDkAAAU9MIIFOTCC",
    "BCGgAwIBAgIQD1ynu/aquKlUmSM5cc+AgDANBgkqhkiG9w0BAQsFADBqMQswCQYDVQQGEwJVUzEXMBUGA1",
    "UEChMORGlnaUNlcnQsIEluYy4xGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xJzAlBgNVBAMTHkRpZ2lD",
    "ZXJ0IERpcmVjdCBTZWN1cmUgUm9vdCBDQTAeFw0yMTAzMTUxMjAwMDBaFw0zMTAzMTUxMjAwMDBaMIGSMQ",
    "swCQYDVQQGEwJVUzERMA8GA1UECBMITWlzc291cmkxGzAZBgNVBAoTEkNlcm5lciBDb3Jwb3JhdGlvbjEZ",
    "MBcGA1UECxMQQ2VybmVyIFJlc29uYW5jZTE4MDYGA1UEAxMvQ2VybmVyIENvcnBvcmF0aW9uIFJlc29uYW",
    "5jZSBJbnRlcm1lZGlhdGUgQ0EgRzIwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDEFqZY8Hat",
    "ztuglxeUNMBu1iV6k2hk/U9nwN043rcUdtvhbapgdgd5aH4nrusdqnF0rS3oOPBx/5Xq+nFt4TnCbesCo2",
    "cn8aH1Urn2epFPECdsPNjaDwz9UPd7OFLaW/Vcbh4Kqgz204yKeF88n5DNn+HguNa29xBU2/rMLApJCtEy",
    "OBSpG6smXKz4oOpaXo4rMqjYKhPhxNOeLRNtJPz40sdDwZ2VfVkzcIG0eiLprJqTTO7wiOsUNj38aECb5y",
    "W/0cHaIT6EpvrwEmtB9JT8HSIXqYWvbiifJdn6E7FT6vA7swsPqaGQmAKbeyR7eKSPNNRxA2FPaXVX2AHT",
    "g1j5AgMBAAGjggGwMIIBrDAfBgNVHSMEGDAWgBR8xW/e69srMU1Oan4h5UjO1TLN+TASBgNVHRMBAf8ECD",
    "AGAQH/AgEAMHwGCCsGAQUFBwEBBHAwbjBGBggrBgEFBQcwAoY6aHR0cDovL2NhY2VydHMuZGlnaWNlcnQu",
    "Y29tL0RpZ2lDZXJ0RGlyZWN0U2VjdXJlUm9vdENBLmNydDAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AuZG",
    "lnaWNlcnQuY29tMIGIBgNVHR8EgYAwfjA9oDugOYY3aHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lD",
    "ZXJ0RGlyZWN0U2VjdXJlUm9vdENBLmNybDA9oDugOYY3aHR0cDovL2NybDQuZGlnaWNlcnQuY29tL0RpZ2",
    "lDZXJ0RGlyZWN0U2VjdXJlUm9vdENBLmNybDA9BgNVHSAENjA0MDIGBFUdIAAwKjAoBggrBgEFBQcCARYc",
    "aHR0cHM6Ly93d3cuZGlnaWNlcnQuY29tL0NQUzAOBgNVHQ8BAf8EBAMCAYYwHQYDVR0OBBYEFNr1zGBLep",
    "wt6BMRzITxEw/qLuDvMA0GCSqGSIb3DQEBCwUAA4IBAQArtYaFAtUbH6RY6YPZ0JPicNfYXv+GT4lKqN9V",
    "s5+EK+gju/p3TKUQUFEPB5LV7eINYbWWOjv+sGLdGXjeFqAe3hw+lhjJQhB9EulJom57O3XoHl262F/DAI",
    "cjv5cdnKu9xw5PVYjdBnthOgr3YrEEGeLQUx6g42tYmknHLtN8QFEC5aD61+1Fxkrt77kwk2nVRNbzqcjR",
    "Xy2c7GZxxaxmM6IFgtoUbiH+lvB99y7UxeGSNuxpcoFaOqPTOJqXW7+qT/pVuqDTIp4K9Pj33chBRLrJqs",
    "2ko9C/OTNECPYo+YgwOSOn1h9ANN24c+0G93gpcuTH/if6EfuLrrCIVbRFAAAAAgAeZGlnaWNlcnQgZGly",
    "ZWN0IHNlY3VyZSByb290IGNhAAABeuSYsMsABVguNTA5AAADpDCCA6AwggKIoAMCAQICEAOd83sJkXDGP6",
    "0F2Kk7lB0wDQYJKoZIhvcNAQELBQAwajELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMu",
    "MRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMScwJQYDVQQDEx5EaWdpQ2VydCBEaXJlY3QgU2VjdXJlIF",
    "Jvb3QgQ0EwHhcNMTYxMDI1MDAwMDAwWhcNMzYxMDI1MDAwMDAwWjBqMQswCQYDVQQGEwJVUzEXMBUGA1UE",
    "ChMORGlnaUNlcnQsIEluYy4xGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xJzAlBgNVBAMTHkRpZ2lDZX",
    "J0IERpcmVjdCBTZWN1cmUgUm9vdCBDQTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAMb58Y2W",
    "MF1Oo7by1Z3g43dn/lXGNgZG5HZku3fsdUgWbVYdl//zZ01V6SmXQWtPZdqqaFeKdE//VDSuJCVyDVv7DN",
    "yIuuzvUEwhc1iO9TFe3KRaYflya3UZCVAwfcexQ7mYaJ3JVLvPzhXHijdIK32pYKZw2vNPdiBN7f33XHF6",
    "ayggy22s8DfEEJLxkmdFU9nUI/Zm8i14EWr21VPMFkxeGCEOAM3hXNWl8m2RP/rWdovHKfeZWuTgijLssp",
    "RCXFBhMuxVqud9Vbh8q1IQwRteC7o/utWwsEMLPCcFOIcfP/9ChWAQbncAoeAqkhPRwCAhTd7TAzvG3PjI",
    "HBIAVIsCAwEAAaNCMEAwHQYDVR0OBBYEFHzFb97r2ysxTU5qfiHlSM7VMs35MA8GA1UdEwEB/wQFMAMBAf",
    "8wDgYDVR0PAQH/BAQDAgGGMA0GCSqGSIb3DQEBCwUAA4IBAQA/Md8d5JP4sng+7tS+wSgZ+Jkm2RM7F3Sb",
    "DnPTzTenvBHtvP+sL9p3jV1H57F5sqDdiCfH/0oh1t4UfHmtVZ5SpW6aILmJ60kX68o9CSXBLIKq9WDPp2",
    "deNJDqFHXSkbCa6LJW/CloL62pXHp8vDCP7HBlSrSMU2VhVBo24YkoO58AOE/WRkjPqLExf4Q1DeZiNPWz",
    "lv7nPcwJ/dKeYEdYJB8z3rw2iJogWDtvqa7Ia7/oChTPZwiMRVPVFstv4wV1xn/vzhjGMXn4lw4D/Riznu",
    "oiyW+UfaVnObjzYoJhYcwTTFxHAoVA2y3xMIt7DIN+kjBb1L2z0KLuN+WTs9kqAAAAAgBKY2VybmVyIGNv",
    "cnBvcmF0aW9uIHJlc29uYW5jZSBpbnRlcm1lZGlhdGUgY2EgKGRpZ2ljZXJ0IGZlZGVyYXRlZCB0cnVzdC",
    "BjYSkAAAF65Jk6OAAFWC41MDkAAAWVMIIFkTCCBHmgAwIBAgIQDVNa5zudUxqvqtjgJob59zANBgkqhkiG",
    "9w0BAQsFADBlMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZG",
    "lnaWNlcnQuY29tMSQwIgYDVQQDExtEaWdpQ2VydCBGZWRlcmF0ZWQgVHJ1c3QgQ0EwHhcNMTUxMTExMTIw",
    "MDAwWhcNMjExMTExMTIwMDAwWjB8MQswCQYDVQQGEwJVUzEbMBkGA1UEChMSQ2VybmVyIENvcnBvcmF0aW",
    "9uMRkwFwYDVQQLExBDZXJuZXIgUmVzb25hbmNlMTUwMwYDVQQDEyxDZXJuZXIgQ29ycG9yYXRpb24gUmVz",
    "b25hbmNlIEludGVybWVkaWF0ZSBDQTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBANv4wv9Bcz",
    "pU2mPPMpDTbf+4lmbahX0kZ3dvXtnr7F5+fbNWye571Vo7ISbZM8Mo0RxBBJOZGjvza6Kp4H3y1AWtJhbs",
    "dSeiN66p3xeHp6PIx5qSMlVZxX7WXFwhXOOn9NxHWYGvYyFhpW4Hhykg7rSnSARe8F7Gk4nck1mBdqaL8T",
    "PJYuC07ouiKsEc/QpPhgrRYukQ8miZyOFQHN2ew22BEGJ2aynFSdtkGAAFEskqeb2LD11FNp6DdoO6fZW4",
    "X76HfkjMm1tg2OOzx25MPyOp5D8mUUNI17TDnfygIEtKvkbmucEiy/B42ndLpmBADlLeLgF6969SxejLvH",
    "NIs4MCAwEAAaOCAiQwggIgMBIGA1UdEwEB/wQIMAYBAf8CAQAwDgYDVR0PAQH/BAQDAgGGMIGOBggrBgEF",
    "BQcBAQSBgTB/MFcGCCsGAQUFBzAChktodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vYWlhQ2VybmVyQ2",
    "9ycG9yYXRpb25SZXNvbmFuY2VJbnRlcm1lZGlhdGVDQS5wN2MwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3Nw",
    "LmRpZ2ljZXJ0LmNvbTCBgwYDVR0fBHwwejA7oDmgN4Y1aHR0cDovL2NybDQuZGlnaWNlcnQuY29tL0RpZ2",
    "lDZXJ0RmVkZXJhdGVkVHJ1c3RDQS5jcmwwO6A5oDeGNWh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdp",
    "Q2VydEZlZGVyYXRlZFRydXN0Q0EuY3JsMIGiBgNVHSAEgZowgZcwOAYKYIZIAYb9bAACBDAqMCgGCCsGAQ",
    "UFBwIBFhxodHRwczovL3d3dy5kaWdpY2VydC5jb20vQ1BTMAwGCmCGSAGG/WwEAQEwDAYKYIZIAYb9bAQB",
    "AjALBglghkgBhv1sBAIwDAYKYIZIAYb9bAQDAjALBglghkgBhv1sAQEwCwYJYIZIAYb9bAELMAoGCGCGSA",
    "GG/WwGMB0GA1UdDgQWBBRfJHSWDiGoj82Y8Nr2EHeUKNWKNjAfBgNVHSMEGDAWgBRGCDhaqY4guwyvXjG6",
    "ibMov6yMNjANBgkqhkiG9w0BAQsFAAOCAQEAaBcJisYEOe+/iugqMttKKLt52dFdAXkkDuK00maQcjaaLH",
    "gQWy/XAlAp6B4IHNuTxbzq0KS6Ub3XHNsoERSOrriNulCculrk3YK/4k/7XPtYg60QUqA7XUUl/LAOZT7v",
    "i50DaQqpHglKObwmvB+t5pZYWqqKWqHz3IAxTikbU0RUJrcXwqQq9CLaCt6edRW3Y/IG4YYl4jg+ZPCKqs",
    "W0QHaX08bp4fcUOULMbFxPSc42T/rWC+hBqsNnNdNbEWSkiS8rs28zYRzEF1XYfqWSI7XxrFKhJbj+2plm",
    "vlWcvLIaUaBo1YjarWf6oRNM1aT6BpCDbh7jAYTZFto7uTg3uQAAAAIAG2RpZ2ljZXJ0IGFzc3VyZWQgaW",
    "Qgcm9vdCBjYQAAAXrkmORcAAVYLjUwOQAAA7swggO3MIICn6ADAgECAhAM5+DlF9hG/o/lYPwb8DA5MA0G",
    "CSqGSIb3DQEBBQUAMGUxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEH",
    "d3dy5kaWdpY2VydC5jb20xJDAiBgNVBAMTG0RpZ2lDZXJ0IEFzc3VyZWQgSUQgUm9vdCBDQTAeFw0wNjEx",
    "MTAwMDAwMDBaFw0zMTExMTAwMDAwMDBaMGUxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbm",
    "MxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xJDAiBgNVBAMTG0RpZ2lDZXJ0IEFzc3VyZWQgSUQgUm9v",
    "dCBDQTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAK0OFc7kQ4BcsYfzt2D5cRKlrtwmlIiq9M",
    "71IDkoWGAM+IDaqRWVMmE8tbEohIqK3J8KDIMXeo+QrIrneVNcMYQq9g+YMjZ2zN7dPKii72r7IfJSYd+f",
    "INcf4rHZ/hhk0hJbX/lYGDW8R82hNvlrf9SwOD7BG8OMM9nYLxj+KA+zp4PWw25EwGE1lhb+WZyLdm3X8a",
    "JLDSv/C3LanmDQjpA1xnhVhyChz+VtCshJfDGYM2wi6YfQMlqiuhOCEe05F52ZOnKh5vqk2dUXMXWuhX0i",
    "rj8BRob2KHnIsdrkVxfEfhwOsLSSplazvbKX7aqn8LfFqD+VFtD/oZbrCF8Yd08CAwEAAaNjMGEwDgYDVR",
    "0PAQH/BAQDAgGGMA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFEXroq/0ksuCMS1Ri6enIZ3zbcgPMB8G",
    "A1UdIwQYMBaAFEXroq/0ksuCMS1Ri6enIZ3zbcgPMA0GCSqGSIb3DQEBBQUAA4IBAQCiDrzf4u3w43Jzem",
    "SUv/dyZtgy5EJ1Yq6H6/LV2d5Ws5/MzhQouQ2XYFwSTFjk0z2DSUVYlzVpGqhH6lbGeasS2GeBhN9/CTyU",
    "5rgmLCC9PbMoifdf/yLil4Qf6WXvh+DfwWdJs13rsgkq6ybteL59PyvztyY1bV+JAbZJW58BBZurPSXBzL",
    "Z/wvFvhsb6ZGjrgS2U60K3+owe3WLxvlBnt2y98/Efaww2BxZ/N3ypW2168RJGYIPXJwS+S86XvsNnKmgR",
    "34DnDDNmvxMNFG7zfx9jEB76jRslbWyPpbdhAbHSoyahEHGdreLD+cOZUbcrBwjOLuZQsqf6CkUvovDyAA",
    "AAAgA5ZGlnaWNlcnQgZmVkZXJhdGVkIHRydXN0IGNhIChkaWdpY2VydCBhc3N1cmVkIGlkIHJvb3QgY2Ep",
    "AAABeuSZBQkABVguNTA5AAAGmjCCBpYwggV+oAMCAQICEAaC+x+Bd3aleZEsPtkQ7/EwDQYJKoZIhvcNAQ",
    "ELBQAwZTELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2lj",
    "ZXJ0LmNvbTEkMCIGA1UEAxMbRGlnaUNlcnQgQXNzdXJlZCBJRCBSb290IENBMB4XDTExMTExODEyMDAwMF",
    "oXDTIzMTExODEyMDAwMFowZTELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UE",
    "CxMQd3d3LmRpZ2ljZXJ0LmNvbTEkMCIGA1UEAxMbRGlnaUNlcnQgRmVkZXJhdGVkIFRydXN0IENBMIIBIj",
    "ANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA18s+s4YaZpVmK64H8rlEnzfZy241vbGfUdgahfaJhs1m",
    "VQPT7iejEttJDZelmeGYTH0o+dbmmFLhEGmq52eWbTdOyvwVXamwX8dMTmJh7OKu7jpAmJfg4U17UPewVh",
    "LTmtiGQJ2zZA5fa6OUE5d23R6y+JOaX8cv1zmQm8ZVGTRl74l3hBlMEn5wmQRyUCZ/+4wkcSUsFx7BUKXu",
    "7UM6NUV/gd2q/uiwVZ9Zd5gSUBlsW+rjUHDH4E5d4xgPswSkRSAc1yTHEvYZfZLHQf5iOB9RuhFl91P5/2",
    "Fez8poz0NnegI8zyNCOCk/TtgWSc2WqOmBCH8RFm+y2BsvJN9fxQIDAQABo4IDQDCCAzwwDwYDVR0TAQH/",
    "BAUwAwEB/zAOBgNVHQ8BAf8EBAMCAYYwfwYIKwYBBQUHAQEEczBxMCQGCCsGAQUFBzABhhhodHRwOi8vb2",
    "NzcC5kaWdpY2VydC5jb20wSQYIKwYBBQUHMAKGPWh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9haWFE",
    "aWdpQ2VydEZlZGVyYXRlZFRydXN0Q0FwdC5wN2MwgYEGA1UdHwR6MHgwOqA4oDaGNGh0dHA6Ly9jcmwzLm",
    "RpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcmwwOqA4oDaGNGh0dHA6Ly9jcmw0LmRp",
    "Z2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcmwwggHSBgNVHSAEggHJMIIBxTCCAbQGCm",
    "CGSAGG/WwAAgQwggGkMDoGCCsGAQUFBwIBFi5odHRwOi8vd3d3LmRpZ2ljZXJ0LmNvbS9zc2wtY3BzLXJl",
    "cG9zaXRvcnkuaHRtMIIBZAYIKwYBBQUHAgIwggFWHoIBUgBBAG4AeQAgAHUAcwBlACAAbwBmACAAdABoAG",
    "kAcwAgAEMAZQByAHQAaQBmAGkAYwBhAHQAZQAgAGMAbwBuAHMAdABpAHQAdQB0AGUAcwAgAGEAYwBjAGUA",
    "cAB0AGEAbgBjAGUAIABvAGYAIAB0AGgAZQAgAEQAaQBnAGkAQwBlAHIAdAAgAEMAUAAvAEMAUABTACAAYQ",
    "BuAGQAIAB0AGgAZQAgAFIAZQBsAHkAaQBuAGcAIABQAGEAcgB0AHkAIABBAGcAcgBlAGUAbQBlAG4AdAAg",
    "AHcAaABpAGMAaAAgAGwAaQBtAGkAdAAgAGwAaQBhAGIAaQBsAGkAdAB5ACAAYQBuAGQAIABhAHIAZQAgAG",
    "kAbgBjAG8AcgBwAG8AcgBhAHQAZQBkACAAaABlAHIAZQBpAG4AIABiAHkAIAByAGUAZgBlAHIAZQBuAGMA",
    "ZQAuMAsGCWCGSAGG/WwDFTAdBgNVHQ4EFgQURgg4WqmOILsMr14xuomzKL+sjDYwHwYDVR0jBBgwFoAURe",
    "uir/SSy4IxLVGLp6chnfNtyA8wDQYJKoZIhvcNAQELBQADggEBAFcTDr0lyJZhnyymsNWDDtOI1ytfu6Rz",
    "zDMmy8Qwk3ii8Me2F4SXWK5mdX7WIm6ikZXjCpQFCeapkUbdt30cC+9E5WVqovrFmUW740kk3nqgdH4v5r",
    "gkSwoxiUzDwTx+E0lpulN2oOZsFMBvJuFgTE/q33wdhNEfh37YyK689+P1qMSi3GQDo9sOnRfAwFj64mED",
    "J1huQQ2WjZjT4uqvzODbP6YZAoUwezQRIbxyDlFeJTE1/OT5vZ0bnsXNTX1u8IbdUnmlNmyWs1hhsp73q5",
    "fJ35p3wdFJ5ePMVmtr8hb3xxVMHEjqKI1oAkWdVonzaAO8rokqJaXIl2wwrKh/ZfXYfFfN4xJ49uNeSJQw",
    "jcRNUczybQ")
   SELECT DISTINCT INTO "nl:"
    sop.property_name, sop.property_value_txt
    FROM si_oen_comchannel soc,
     si_oen_chann_endpoint_r socer,
     si_oen_endpoint soe,
     si_oen_property sop,
     si_oen_context sc
    PLAN (sc
     WHERE cnvtupper(sc.context_name)=default_resonance_comserver_name)
     JOIN (soc
     WHERE soc.si_oen_context_id=sc.si_oen_context_id)
     JOIN (socer
     WHERE socer.si_oen_comchannel_id=soc.si_oen_comchannel_id)
     JOIN (soe
     WHERE soe.si_oen_endpoint_id=socer.si_oen_endpoint_id)
     JOIN (sop
     WHERE sop.property_set_id=soe.connection_property_id
      AND sop.property_name IN ("keystore", "keystorePassword"))
    ORDER BY sop.property_name
    DETAIL
     IF (sop.property_name="keystore")
      raw_keystore_path = trim(sop.property_value_txt,3), keystore_name = substring((findstring("/",
        raw_keystore_path,1,1)+ 1),size(raw_keystore_path,1),raw_keystore_path), keystore_path = trim
      (substring(findstring("/",raw_keystore_path,1,0),((findstring("/",raw_keystore_path,1,1) -
        findstring("/",raw_keystore_path,1,0))+ 1),raw_keystore_path),3)
     ELSEIF (sop.property_name="keystorePassword")
      keystore_password = trim(sop.property_value_txt,3)
     ENDIF
    WITH nocounter
   ;end select
   IF ( NOT (size(trim(keystore_path,3),1) > 0))
    SET keystore_path = build2(trim(logical("CCLUSERDIR"),3),"/")
   ENDIF
   IF ( NOT (size(trim(keystore_password,3),1) > 0))
    SET keystore_password = "NOT FOUND"
   ENDIF
   SELECT DISTINCT INTO "nl:"
    sop.property_name, sop.property_value_txt
    FROM si_oen_comchannel soc,
     si_oen_chann_endpoint_r socer,
     si_oen_endpoint soe,
     si_oen_property sop,
     si_oen_context sc
    PLAN (sc
     WHERE cnvtupper(sc.context_name)="RESONANCE")
     JOIN (soc
     WHERE soc.si_oen_context_id=sc.si_oen_context_id)
     JOIN (socer
     WHERE socer.si_oen_comchannel_id=soc.si_oen_comchannel_id)
     JOIN (soe
     WHERE soe.si_oen_endpoint_id=socer.si_oen_endpoint_id)
     JOIN (sop
     WHERE sop.property_set_id=soe.protocol_property_id
      AND sop.property_name IN ("signKeyAlias"))
    ORDER BY sop.property_name
    DETAIL
     IF (sop.property_name="signKeyAlias")
      keystore_signkeyalias = trim(sop.property_value_txt,3), keystore_private_key = trim(sop
       .property_value_txt,3)
     ENDIF
    WITH nocounter
   ;end select
   IF ( NOT (size(trim(keystore_private_key,3),1) > 0))
    SET keystore_private_key =
    "NOT FOUND - Using default alias (please check comchannels for valid signKeyAlias)"
    SET keystore_signkeyalias = currentdomain
   ENDIF
   CALL write_keystore(build2(keystore_path,resonance_prod_keystore_file_name),
    resonance_prod_keystore_base64,eof_char)
   SET client_mnemonic_string = cnvtalphanum(get_client_mnemonic(1))
   IF (client_mnemonic_string="unknown")
    SET client_mnemonic_string = "<client_mnemonic>"
   ENDIF
   CALL clear(1,1)
   CALL text(3,2,"DEFAULT keystore password is changeit")
   CALL text(4,2,build2("CURRENT keystore password is ",keystore_password))
   CALL text(5,2,build2("CURRENT signKeyAlias is ",keystore_private_key))
   CALL text(7,2,"Please update password before creating the private key:")
   CALL text(8,2,build2("keytool -storepasswd -keystore ",resonance_prod_keystore_file_name))
   CALL text(10,2,"1. Creating private key: ")
   CALL text(11,2,build2("  keytool -genkey -alias ",keystore_signkeyalias," -keyalg RSA -keystore ",
     resonance_prod_keystore_file_name," -keysize 2048 -sigalg SHA256withRSA"))
   CALL text(12,2,build2("       What is your first and last name?: ",client_mnemonic_string,
     ".cernerresonance.com "))
   CALL text(13,2,build2("            What is the name of your OU?: Millennium"))
   CALL text(14,2,build2("  What is the name of your Organization?: Cerner"))
   CALL text(15,2,build2("          What is the name of your city?: Kansas City"))
   CALL text(16,2,build2("         What is the name of your state?: Missouri"))
   CALL text(17,2,build2("    What is the two-letter country code?: US"))
   CALL text(18,2,build2(" "))
   CALL text(19,2,build2("2. Generate CSR (all on one line):"))
   CALL text(20,2,build2("keytool -keystore ",resonance_prod_keystore_file_name," -certreq -alias ",
     keystore_signkeyalias," -file ad_",
     keystore_signkeyalias,"_csr -keysize 2048 -sigalg SHA256withRSA"))
   CALL accept(1,1,"A;CU","")
 END ;Subroutine
 SUBROUTINE import_hub_resonance_mod_obj_script(dummy_var)
   DECLARE resonance_xds_mod_obj_ver = vc WITH constant("_V9")
   DECLARE resonance_xds_mod_obj_name = vc WITH constant(build("XDS_MOD_OBJ",
     resonance_xds_mod_obj_ver))
   DECLARE resonance_xds_mod_obj_desc = vc WITH constant(
    "Outbound ADT Mod Obj for Resonance Connections")
   DECLARE resonance_xds_mod_obj_base64 = vc WITH noconstant("")
   FREE RECORD oenctl_add_script_request
   RECORD oenctl_add_script_request(
     1 sc_name = vc
     1 sc_desc = vc
     1 sc_type = vc
     1 sc_body = vc
     1 not_executable = i4
     1 read_only = i4
   )
   SET resonance_xds_mod_obj_base64 = build2(
    "LyoNCiAqICAtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0",
    "tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0NCiAqICBTY3JpcHQgTmFtZTogIFhEU19NT0RfT0JKRUNUDQogKiAgRGVzY3JpcH",
    "Rpb246ICBPSUQgY29kaW5nIGFuZCBBRFQgYnVpbGQgZm9yIFJlc29uYW5jZQ0KICogIFR5cGU6ICBPcGVuIEVuZ2luZSBNb2RpZ",
    "nkgT2JqZWN0IFNjcmlwdA0KICogIC0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t",
    "LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLQ0KICogIEF1dGhvcjogIFJlcyBIdWIgVGVhbQ0KICogIER",
    "vbWFpbjogIFBST0QNCiAqICBDcmVhdGlvbiBEYXRlOiAgMDIvMTMvMjAxNCAxNToyNDoyMg0KICogIFZlcnNpb246IDkNCiAqIC",
    "AtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tL",
    "S0tLS0tLS0tLS0tLS0tLS0tLS0NCiAqICAwMDEgMDkvMDcvMjAxNiAgQWRkZWQgbG9naWMgdG8gaW5jbHVkZSBSZXZlcnNlIEVu",
    "ZCBFZmZlY3RpdmUgcm93cyBpbiBtZXJnZSBsb2dpYw0KICoNCiAqLw0KDQoNCg0KZGVjbGFyZSBtc2hfNF9vaWQgPSB2YyB3aXR",
    "oIG5vY29uc3RhbnQoIiIpO0xlYXZlIEJsYW5rIGZvciBhcHBlbmRpbmcgbG9naWMNCmRlY2xhcmUgZFBlcnNvbklkID0gZjggd2",
    "l0aCBjb25zdGFudChjbnZ0cmVhbChnZXRfZG91YmxlX3ZhbHVlKCJwZXJzb25faWQiKSkpDQpkZWNsYXJlIGRFbmNudHJJZCA9I",
    "GY4IHdpdGggY29uc3RhbnQoY252dHJlYWwoZ2V0X29lbl9yZXBseV9sb25nKCJlbmNudHJfaWQiKSkpDQo7ZGVjbGFyZSBkQ29u",
    "dHJpYnV0b3JTeXN0ZW1DZCA9IGY4IHdpdGggY29uc3RhbnQoY252dHJlYWwoV2hhdElzKCJQQUNLRVNPIikpKQ0KZGVjbGFyZSB",
    "kQ29udHJpYnV0b3JTeXN0ZW1DZCA9IGY4IHdpdGggY29uc3RhbnQoVUFSX0dFVF9DT0RFX0JZKCJEaXNwbGF5a2V5Iiw4OSwiWE",
    "RTQ09OVFJJQlVUT1JTWVNURU0iKSkNCg0KZGVjbGFyZSBkb2IgPSAgdmMNCmRlY2xhcmUgaW5ib3VuZF9kb2IgPSB2Yw0KZGVjb",
    "GFyZSBpbmJvdW5kX2R0dG0gPSB2Yw0KZGVjbGFyZSBkdHRtID0gdmMNCmRlY2xhcmUgZXZuZHR0bSA9IHZjDQpkZWNsYXJlIGlu",
    "Ym91bmRfZXZuZHR0bSA9IHZjDQpkZWNsYXJlIGNzX29yZ19vaWRfdHh0ID0gdmMNCmRlY2xhcmUgb3JnX3R5cGVfY2QJCQkJCT0",
    "gZjggd2l0aCBjb25zdGFudCh1YXJfZ2V0X2NvZGVfYnkoIk1FQU5JTkciLCAyNzgsICJDT01NVU5JVFkiKSkgOztIQyBPUkcNCm",
    "ZyZWUgcmVjb3JkIGFsaWFzX3Bvb2xfY2RfbGlzdA0KcmVjb3JkIGFsaWFzX3Bvb2xfY2RfbGlzdA0KKA0KICAgIDEgcXVhbFsqX",
    "Q0KICAgICAgMiBhbGlhc19wb29sX2NkCT0gZjgNCikNCg0KDQppZihvZW5fcmVwbHktPkNPTlRST0xfR1JPVVAgWzFdLT5NU0gg",
    "WzFdLT5tZXNzYWdlX3R5cGUtPm1lc3NnX3R5cGUgPSAiQURUIiBhbmQgDQoob2VuX3JlcGx5LT5DT05UUk9MX0dST1VQIFsxXS0",
    "+TVNIIFsxXS0+bWVzc2FnZV90eXBlLT5tZXNzZ190cmlnZ2VyIGluDQooIkEwMSIsIkEwNCIsIkEwNSIsIkEwOCIsIkE0MCIsIk",
    "EzNCIsIkE0NCIsICJBMjgiLCAiQTMxIikpDQphbmQgKHNpemUob2VuX3JlcGx5LT5QRVJTT05fR1JPVVAgWzFdLT5QQVRfR1JPV",
    "VAgWzFdLT5QSUQsNSkgPiAwKSkNCg0KICBpZiAob2VuX3JlcGx5LT5DT05UUk9MX0dST1VQIFsxXS0+TVNIIFsxXS0+bWVzc2Fn",
    "ZV90eXBlLT5tZXNzZ190cmlnZ2VyIGluICgiQTM0IiwiQTQ0IikgKQ0KICAgIFNldCBvZW5fcmVwbHktPkNPTlRST0xfR1JPVVA",
    "gWzFdLT5NU0ggWzFdLT5tZXNzYWdlX3R5cGUtPm1lc3NnX3RyaWdnZXIgPSAiQTQwIg0KICBlbHNlaWYob2VuX3JlcGx5LT5DT0",
    "5UUk9MX0dST1VQIFsxXS0+TVNIIFsxXS0+bWVzc2FnZV90eXBlLT5tZXNzZ190cmlnZ2VyIGluICgiQTI4IikpDQogICAgU2V0I",
    "G9lbl9yZXBseS0+Q09OVFJPTF9HUk9VUCBbMV0tPk1TSCBbMV0tPm1lc3NhZ2VfdHlwZS0+bWVzc2dfdHJpZ2dlciA9ICJBMDgi",
    "DQogIGVsc2VpZihvZW5fcmVwbHktPkNPTlRST0xfR1JPVVAgWzFdLT5NU0ggWzFdLT5tZXNzYWdlX3R5cGUtPm1lc3NnX3RyaWd",
    "nZXIgaW4gKCJBMzEiKSkNCiAgIAlTZXQgb2VuX3JlcGx5LT5DT05UUk9MX0dST1VQIFsxXS0+TVNIIFsxXS0+bWVzc2FnZV90eX",
    "BlLT5tZXNzZ190cmlnZ2VyID0gIkEwOCINCiAgZW5kaWYNCg0KO0hhcmRjb2RlIE1pbGxlbml1bSAvIFJlc29uYW5jZSBPSURzD",
    "QpTZXQgb2VuX3JlcGx5LT5DT05UUk9MX0dST1VQIFsxXS0+TVNIIFsxXS0+c2VuZGluZ19hcHBsaWNhdGlvbi0+bmFtZV9pZCA9",
    "ICIiDQpTZXQgb2VuX3JlcGx5LT5DT05UUk9MX0dST1VQIFsxXS0+TVNIIFsxXS0+c2VuZGluZ19hcHBsaWNhdGlvbi0+dW5pdl9",
    "pZCA9ICIyLjE2Ljg0MC4xLjExMzg4My4zLjEzLjIiDQpTZXQgb2VuX3JlcGx5LT5DT05UUk9MX0dST1VQIFsxXS0+TVNIIFsxXS",
    "0+c2VuZGluZ19hcHBsaWNhdGlvbi0+dW5pdl9pZF90eXBlID0gIklTTyINClNldCBvZW5fcmVwbHktPkNPTlRST0xfR1JPVVAgW",
    "zFdLT5NU0ggWzFdLT5yZWNlaXZpbmdfYXBwbGljYXRpb24tPm5hbWVfaWQgPSAiIg0KU2V0IG9lbl9yZXBseS0+Q09OVFJPTF9H",
    "Uk9VUCBbMV0tPk1TSCBbMV0tPnJlY2VpdmluZ19hcHBsaWNhdGlvbi0+dW5pdl9pZCA9ICIyLjE2Ljg0MC4xLjExMzg4My4zLjE",
    "zLjMuMyINClNldCBvZW5fcmVwbHktPkNPTlRST0xfR1JPVVAgWzFdLT5NU0ggWzFdLT5yZWNlaXZpbmdfYXBwbGljYXRpb24tPn",
    "VuaXZfaWRfdHlwZSA9ICJJU08iDQoNCjsgR2V0IE9SRyBJRCAvIEFwcGx5IEFmZmluaXR5IERvbWFpbiBPSUQgTVNIIDUNCgk7O",
    "ztHZXR0aW5nIE9JRCBmb3IgUmVzb25hbmNlIENvbW11bml0eShCYXNlZCBvbiB0aGUgT3JnIHRoYXQgaXMgb24gdGhlIGNvbnRy",
    "aWJ1dG9yIHN5c3RlbSkNCgljYWxsIGVjaG8oYnVpbGQyKCJjb250cmlidXRvciBzeXN0ZW0gY2Q6ICIsIGRDb250cmlidXRvclN",
    "5c3RlbUNkKSkNCglleGVjdXRlIG9lbmNwbV9tc2dsb2coQlVJTEQoImNvbnRyaWJ1dG9yIHN5c3RlbSBjZDogIiwgZENvbnRyaW",
    "J1dG9yU3lzdGVtQ2QpKQkNCiAgICBpZihkQ29udHJpYnV0b3JTeXN0ZW1DZCA+IDApDQogICAgICAgIHNlbGVjdCBzby5vaWRfd",
    "Hh0IGZyb20gU0lfT0lEIHNvLCBjb250cmlidXRvcl9zeXN0ZW0gY3MNCiAgICAgICAgcGxhbiBjcw0KICAgICAgICAgICAgd2hl",
    "cmUgY3MuY29udHJpYnV0b3Jfc3lzdGVtX2NkID0gZENvbnRyaWJ1dG9yU3lzdGVtQ2QgDQogICAgICAgIGpvaW4gc28gICAgICA",
    "gIA0KICAgICAgICAgICAgd2hlcmUgc28uZW50aXR5X3R5cGUgPSAiT1JHQU5JWkFUSU9OIg0KICAgICAgICAgICAgYW5kIHNvLm",
    "VudGl0eV9pZCA9IGNzLm9yZ2FuaXphdGlvbl9pZA0KICAgICAgIGRldGFpbA0KICAgICAgICAgICBjc19vcmdfb2lkX3R4dCA9I",
    "HNvLm9pZF90eHQNCiAgICBlbmRpZg0KICAgIGNhbGwgZWNobyAoYnVpbGQyKCJjc19vcmdfb2lkX3R4dCA6ICIsIGNzX29yZ19v",
    "aWRfdHh0ICkpDQogICAgDQoJU2V0IG9lbl9yZXBseS0+Q09OVFJPTF9HUk9VUCBbMV0tPk1TSCBbMV0tPnJlY2VpdmluZ19mYWN",
    "pbGl0eS0+bmFtZV9pZCA9ICIiIA0KCVNldCBvZW5fcmVwbHktPkNPTlRST0xfR1JPVVAgWzFdLT5NU0ggWzFdLT5yZWNlaXZpbm",
    "dfZmFjaWxpdHktPnVuaXZfaWQgPSBjc19vcmdfb2lkX3R4dCANCglTZXQgb2VuX3JlcGx5LT5DT05UUk9MX0dST1VQIFsxXS0+T",
    "VNIIFsxXS0+cmVjZWl2aW5nX2ZhY2lsaXR5LT51bml2X2lkX3R5cGUgPSAiSVNPIg0KCQ0KCTs7O1VzZSBhcHBlbmQgbG9naWMg",
    "dG8gY3JlYXRlIE1TSCA0IGlmIGRlZmF1bHQgaXMgYmxhbmsNCglpZihtc2hfNF9vaWQgPSAiIikNCiAgCSBzZXQgbXNoXzRfb2l",
    "kID0gY29uY2F0KGNzX29yZ19vaWRfdHh0LCIuOTk5NDgyIikNCgllbmRpZg0KCQ0KCVNldCBvZW5fcmVwbHktPkNPTlRST0xfR1",
    "JPVVAgWzFdLT5NU0ggWzFdLT5zZW5kaW5nX2ZhY2lsaXR5LT5uYW1lX2lkID0gIiIgDQoJU2V0IG9lbl9yZXBseS0+Q09OVFJPT",
    "F9HUk9VUCBbMV0tPk1TSCBbMV0tPnNlbmRpbmdfZmFjaWxpdHktPnVuaXZfaWQgPSAgbXNoXzRfb2lkDQoJU2V0IG9lbl9yZXBs",
    "eS0+Q09OVFJPTF9HUk9VUCBbMV0tPk1TSCBbMV0tPnNlbmRpbmdfZmFjaWxpdHktPnVuaXZfaWRfdHlwZSA9ICAiSVNPIg0KDQo",
    "JO0dldCBhbGlhc19wb29sX2NkIGJhc2VkIG9uIFNJX1NZU1RFTV9PUkdfUkVMVE4NCgljYWxsIGVjaG8oYnVpbGQyKCJFbmNvdW",
    "50ZXIgSUQ6ICIsIGRFbmNudHJJZCApKQ0KCWV4ZWN1dGUgb2VuY3BtX21zZ2xvZyhCVUlMRCgiRW5jb3VudGVyIElEOiAiLCBkR",
    "W5jbnRySWQpKQ0KCTs7O0dldCBhbGwgYWxpYXNfcG9vbF9jZCB2YWx1ZXMgZm9yIHJlYWx0aW9uc2hpcHMgdGhhdCBleGlzdA0K",
    "ICAgCWRlY2xhcmUgYWxpYXNfY250ID0gaTQNCiAgICBzZWxlY3QgIGludG8gIm5sOiINCgkgIHNzb3IuQUxJQVNfUE9PTF9DRA0",
    "KCSAgZnJvbSBTSV9TWVNURU1fT1JHX1JFTFROIHNzb3INCgl3aGVyZSBzc29yLkNPTlRSSUJVVE9SX1NZU1RFTV9DRCA9IGRDb2",
    "50cmlidXRvclN5c3RlbUNkDQoJCWFuZCBOT1QgRVhJU1RTIChzZWxlY3Qgb3RyLm9yZ2FuaXphdGlvbl9pZCBmcm9tIG9yZ190e",
    "XBlX3JlbHRuIG90ciB3aGVyZSBvdHIub3JnYW5pemF0aW9uX2lkID0gc3Nvci5vcmdhbml6YXRpb25faWQgDQogICAgICAgICAg",
    "ICAgICAgICAgIGFuZCBvdHIub3JnX3R5cGVfY2QgPSBvcmdfdHlwZV9jZCkgDQoJCWFuZCBzc29yLlBSSU1BUllfSU5EID0gMQ0",
    "KICAgICAgaGVhZCByZXBvcnQNCiAgCQlhbGlhc19jbnQgPSAwDQogICAgICBkZXRhaWwNCiAgICAgIAlhbGlhc19jbnQgPSBhbG",
    "lhc19jbnQgKyAxDQogICAgICAJU1RBVCA9IGFsdGVybGlzdChhbGlhc19wb29sX2NkX2xpc3QgLT4gcXVhbCwgYWxpYXNfY250K",
    "Q0KICAgICAgIAkJYWxpYXNfcG9vbF9jZF9saXN0IC0+IHF1YWxbYWxpYXNfY250XS5hbGlhc19wb29sX2NkID0gc3Nvci5BTElB",
    "U19QT09MX0NEDQogICAgd2l0aCBub2NvdW50ZXINCglpZihzaXplKGFsaWFzX3Bvb2xfY2RfbGlzdC0+cXVhbCw1KSA9IDApDQo",
    "JICAgZXhlY3V0ZSBvZW5jcG1fbXNnbG9nKEJVSUxEKCIqKiogTUVTU0FHRSBTS0lQUEVEOiBOTyBBTElBU19QT09MX0NEX1JFTF",
    "ROIEZPVU5EIikpDQoJICAgU2V0IG9lbnN0YXR1cy0+aWdub3JlID0gMQ0KCSAgIGdvIHRvIGVuZF9vZl9zY3JpcHQNCgllbmRpZ",
    "g0KDQo7QWRkIGxlYWRpbmcgMCdzIGJhY2sgdG8gU1NODQpkZWNsYXJlIHNzbiA9IHZjDQpzZXQgc3NuID0gdHJpbShvZW5fcmVw",
    "bHktPlBFUlNPTl9HUk9VUCBbMV0tPlBBVF9HUk9VUCBbMV0tPlBJRCBbMV0tPnNzbl9uYnIpDQppZiAoU0laRSh0cmltKHNzbik",
    "pID4gMCkNCiBzZXQgc3NuID0gb2VuX3JlcGx5LT5QRVJTT05fR1JPVVAgWzFdLT5QQVRfR1JPVVAgWzFdLT5QSUQgWzFdLT5zc2",
    "5fbmJyDQogc2V0IHNzbiA9IHJlcGxhY2Uoc3NuLCAiLSIsICIiKQ0KIHNldCBzc24gPSBmb3JtYXQoc3NuLCAiIyMjIyMjIyMjO",
    "1AwIikNCiBTZXQgb2VuX3JlcGx5LT5QRVJTT05fR1JPVVAgWzFdLT5QQVRfR1JPVVAgWzFdLT5QSUQgWzFdLT5zc25fbmJyID0g",
    "c3NuDQpFTkRJRg0KDQo7TWFraW5nIHN1cmUgUmVzb25hbmNlIGNhbiBoYW5kbGUgdGltZSBzdGFtcA0KaWYgKHNpemUob2VuX3J",
    "lcGx5LT5DT05UUk9MX0dST1VQIFsxXS0+RVZOLDUpID4gMCkNCiBzZXQgaW5ib3VuZF9kdHRtID0gb2VuX3JlcGx5LT5DT05UUk",
    "9MX0dST1VQIFsxXS0+TVNIIFsxXS0+bWVzc2FnZV90aW1lX3N0YW1wDQogc2V0IGR0dG0gID0gc3Vic3RyaW5nKDEsIDE0LCBpb",
    "mJvdW5kX2R0dG0pDQogU2V0IG9lbl9yZXBseS0+Q09OVFJPTF9HUk9VUCBbMV0tPk1TSCBbMV0tPm1lc3NhZ2VfdGltZV9zdGFt",
    "cCA9IGR0dG0NCiBzZXQgaW5ib3VuZF9ldm5kdHRtID0gb2VuX3JlcGx5LT5DT05UUk9MX0dST1VQIFsxXS0+RVZOIFsxXS0+ZXZ",
    "lbnRfZHRfdG0gDQogc2V0IGV2bmR0dG0gPSBzdWJzdHJpbmcoMSwgMTQsIGluYm91bmRfZXZuZHR0bSkNCiBTZXQgb2VuX3JlcG",
    "x5LT5DT05UUk9MX0dST1VQIFsxXS0+RVZOIFsxXS0+ZXZlbnRfZHRfdG0gPSBldm5kdHRtDQogU2V0IG9lbl9yZXBseS0+Q09OV",
    "FJPTF9HUk9VUCBbMV0tPkVWTiBbMV0tPmV2ZW50X3R5cGVfY2QgPSBvZW5fcmVwbHktPkNPTlRST0xfR1JPVVAgWzFdLT5NU0gg",
    "WzFdLT5tZXNzYWdlX3R5cGUtPm1lc3NnX3RyaWdnZXINCmVuZGlmDQoNCjtNb2RpZnkgRE9CIHRvIFJlc29uYW5jZSBzdGFuZGF",
    "yZHMNCklGIChvZW5fcmVwbHktPlBFUlNPTl9HUk9VUCBbMV0tPlBBVF9HUk9VUCBbMV0tPlBJRCBbMV0tPmRhdGVfb2ZfYmlydG",
    "ggIT0gIiIpDQogU2V0IGluYm91bmRfZG9iID0gb2VuX3JlcGx5LT5QRVJTT05fR1JPVVAgWzFdLT5QQVRfR1JPVVAgWzFdLT5QS",
    "UQgWzFdLT5kYXRlX29mX2JpcnRoDQogU2V0IGRvYiA9IHN1YnN0cmluZygxLCA4LCAgaW5ib3VuZF9kb2IpDQogU2V0IG9lbl9y",
    "ZXBseS0+UEVSU09OX0dST1VQIFsxXS0+UEFUX0dST1VQIFsxXS0+UElEIFsxXS0+ZGF0ZV9vZl9iaXJ0aCA9IGRvYg0KRUxTRQ0",
    "KIGV4ZWN1dGUgb2VuY3BtX21zZ2xvZyhCVUlMRCgiKioqIE1FU1NBR0UgU0tJUFBFRDogRE9CIGlzIGVtcHR5IikpDQogU2V0IG",
    "9lbnN0YXR1cy0+aWdub3JlID0gMQ0KIGdvIHRvIGVuZF9vZl9zY3JpcHQNCkVORElGDQoNCjtDaGVjayBHZW5kZXINCklGIChvZ",
    "W5fcmVwbHktPlBFUlNPTl9HUk9VUCBbMV0tPlBBVF9HUk9VUCBbMV0tPlBJRCBbMV0tPnNleCA9ICIiKQ0KIGV4ZWN1dGUgb2Vu",
    "Y3BtX21zZ2xvZyhCVUlMRCgiKioqIE1FU1NBR0UgU0tJUFBFRDogR2VuZGVyIGlzIGVtcHR5IikpDQogU2V0IG9lbnN0YXR1cy0",
    "+aWdub3JlID0gMQ0KIGdvIHRvIGVuZF9vZl9zY3JpcHQNCkVORElGDQoNCjtDcmVhdGUgUElELTMNCmlmKGRQZXJzb25JZD4wKQ",
    "0KICA7R2V0IGFuZCBzZXQgYWxsIGFsaWFzZXMgZnJvbSB0aGUgYWxpYXNfcG9vbA0KICBTRVQgU1RBVCA9IGFsdGVybGlzdChvZ",
    "W5fcmVwbHktPlBFUlNPTl9HUk9VUCBbMV0tPlBBVF9HUk9VUCBbMV0tPlBJRCBbMV0tPnBhdGllbnRfaWRfaW50LDApDQogIGRl",
    "Y2xhcmUgYWxpYXNfcG9vbF9jbnQgPSBpMiB3aXRoIG5vY29uc3RhbnQoMCkNCiAgZGVjbGFyZSBhbGlhc19jbnQgPSBpNA0KICB",
    "zZWxlY3QgaW50byAibmw6IiANCiAgcGEuYWxpYXMsDQogIHBhLmFsaWFzX3Bvb2xfY2QsDQogIHNvLm9pZF90eHQgDQogIGZyb2",
    "0gcGVyc29uX2FsaWFzIHBhLA0KICAJc2lfb2lkIHNvDQogIHBsYW4gcGEgd2hlcmUgZXhwYW5kKGFsaWFzX3Bvb2xfY250LDEsc",
    "2l6ZShhbGlhc19wb29sX2NkX2xpc3QtPnF1YWwsNSkscGEuYWxpYXNfcG9vbF9jZCwNCgkJYWxpYXNfcG9vbF9jZF9saXN0LT5x",
    "dWFsW2FsaWFzX3Bvb2xfY250XS5hbGlhc19wb29sX2NkKQ0KICAJYW5kIHBhLnBlcnNvbl9pZD1kUGVyc29uSWQgDQogIAlhbmQ",
    "gcGEuZW5kX2VmZmVjdGl2ZV9kdF90bT5jbnZ0ZGF0ZXRpbWUoY3VyZGF0ZSxjdXJ0aW1lMykgDQogIAlhbmQgcGEuYWN0aXZlX2",
    "luZD0xIA0KICBqb2luIHNvIHdoZXJlIHNvLkVOVElUWV9JRCA9IHBhLkFMSUFTX1BPT0xfQ0QNCgkJCWFuZCBzby5FTlRJVFlfT",
    "kFNRSA9ICdDT0RFX1ZBTFVFJw0KICBoZWFkIHJlcG9ydA0KICAJYWxpYXNfY250ID0gMA0KICBkZXRhaWwNCiAgCWFsaWFzX2Nu",
    "dCA9IGFsaWFzX2NudCArIDENCiAgCVNUQVQgPSBhbHRlcmxpc3Qob2VuX3JlcGx5LT5QRVJTT05fR1JPVVAgWzFdLT5QQVRfR1J",
    "PVVAgWzFdLT5QSUQgWzFdLT5wYXRpZW50X2lkX2ludCwgYWxpYXNfY250KQ0KICAgIG9lbl9yZXBseS0+UEVSU09OX0dST1VQIF",
    "sxXS0+UEFUX0dST1VQIFsxXS0+UElEIFsxXS0+cGF0aWVudF9pZF9pbnQgW2FsaWFzX2NudF0tPmlkID0gcGEuYWxpYXMNCglvZ",
    "W5fcmVwbHktPlBFUlNPTl9HUk9VUCBbMV0tPlBBVF9HUk9VUCBbMV0tPlBJRCBbMV0tPnBhdGllbnRfaWRfaW50IFthbGlhc19j",
    "bnRdLT5hc3NpZ25fYXV0aC0+dW5pdl9pZCA9IHNvLm9pZF90eHQNCiAgICBvZW5fcmVwbHktPlBFUlNPTl9HUk9VUCBbMV0tPlB",
    "BVF9HUk9VUCBbMV0tPlBJRCBbMV0tPnBhdGllbnRfaWRfaW50IFthbGlhc19jbnRdLT5hc3NpZ25fYXV0aC0+dW5pdl9pZF90eX",
    "BlID0gIklTTyINCmVuZGlmDQoNCjtEZWxldGUgbWVzc2FnZSBpZiBubyBQSUQtMyBpcyBibGFuaw0KU2V0IFBJRDNfU1ogPSBTS",
    "VpFKG9lbl9yZXBseS0+UEVSU09OX0dST1VQIFsxXS0+UEFUX0dST1VQIFsxXS0+UElEIFsxXS0+cGF0aWVudF9pZF9pbnQsIDUp",
    "DQpJRihQSUQzX1NaIDwgMSkgDQogIGV4ZWN1dGUgb2VuY3BtX21zZ2xvZyhCVUlMRCgiKioqIE1FU1NBR0UgU0tJUFBFRDogTm8",
    "gQ01STiBmb3VuZCIpKQ0KICBTZXQgb2Vuc3RhdHVzLT5pZ25vcmUgPSAxDQogIGdvIHRvIGVuZF9vZl9zY3JpcHQNCkVORElGDQ",
    "oNCjtSZW1vdmUgYW55IFBJRDsxMSB0aGF0IGlzIG5vdCBhIEhPTUUgKEgpIGFkZHJlc3MNClNldCBQSUQxMV9TWiA9IFNJWkUob",
    "2VuX3JlcGx5LT5QRVJTT05fR1JPVVAgWzFdLT5QQVRfR1JPVVAgWzFdLT5QSUQgWzFdLT5wYXRpZW50X2FkZHJlc3MsIDUpDQog",
    "IA0KaWYoUElEMTFfU1ogPjApDQogIFNldCBYID0gMQ0KICB3aGlsZShYIDw9IFBJRDExX1NaKQ0KICAgaWYodHJpbShvZW5fcmV",
    "wbHktPlBFUlNPTl9HUk9VUCBbMV0tPlBBVF9HUk9VUCBbMV0tPlBJRCBbMV0tPnBhdGllbnRfYWRkcmVzcyBbWF0tPnR5cGVzKS",
    "AhPSAiSCIpDQogICAgU2V0IFNUQVQgPSBhbHRlcmxpc3Qob2VuX3JlcGx5LT5QRVJTT05fR1JPVVAgWzFdLT5QQVRfR1JPVVAgW",
    "zFdLT5QSUQgWzFdLT5wYXRpZW50X2FkZHJlc3MsIFBJRDExX1NaLTEsIFgtMSkNCiAgICBTZXQgUElEMTFfU1ogPSBQSUQxMV9T",
    "WiAtIDENCiAgIGVsc2UNCiAgICBTZXQgWCA9IFggKyAxDQogICBlbmRpZg0KICBlbmR3aGlsZQ0KZW5kaWYNCg0KOyBNYWtlIHN",
    "1cmUgemlwIGlzIG9ubHkgNSBudW1iZXJzLiBSZW1vdmUgdHJhaWxpbmcgZm91ciBpZiB0aGV5IGV4aXN0DQppZiAoU0laRShvZW",
    "5fcmVwbHktPlBFUlNPTl9HUk9VUCBbMV0tPlBBVF9HUk9VUCBbMV0tPlBJRCBbMV0tPnBhdGllbnRfYWRkcmVzcywgNSkpDQogI",
    "GRlY2xhcmUgWklQX0NPREUgPSB2Yw0KICBzZXQgWklQX0NPREUgPSBvZW5fcmVwbHktPlBFUlNPTl9HUk9VUCBbMV0tPlBBVF9H",
    "Uk9VUCBbMV0tPlBJRCBbMV0tPnBhdGllbnRfYWRkcmVzcyBbMV0tPnppcF9jb2RlDQogIHNldCBvZW5fcmVwbHktPlBFUlNPTl9",
    "HUk9VUCBbMV0tPlBBVF9HUk9VUCBbMV0tPlBJRCBbMV0tPnBhdGllbnRfYWRkcmVzcyBbMV0tPnppcF9jb2RlID0gc3Vic3RyaW",
    "5nKDEsNSxaSVBfQ09ERSkNCmVuZGlmDQoNCjtSZW1vdmUgYW55IFBJRDs1IHRoYXQgaXMgbm90IGEgQ3VycmVudCAvIExlZ2FsI",
    "G5hbWUgKEwpDQpTZXQgUElENV9TWiA9IFNJWkUob2VuX3JlcGx5LT5QRVJTT05fR1JPVVAgWzFdLT5QQVRfR1JPVVAgWzFdLT5Q",
    "SUQgWzFdLT5wYXRpZW50X25hbWUsIDUpDQppZihQSUQ1X1NaID4wKQ0KICBTZXQgWCA9IDENCiAgd2hpbGUoWCA8PSBQSUQ1X1N",
    "aKQ0KICAgIGlmKHRyaW0ob2VuX3JlcGx5LT5QRVJTT05fR1JPVVAgWzFdLT5QQVRfR1JPVVAgWzFdLT5QSUQgWzFdLT5wYXRpZW",
    "50X25hbWUgW1hdLT5uYW1lX3R5cGVfY2QpICE9ICJMIikNCiAgICAgU2V0IFNUQVQgPSBhbHRlcmxpc3Qob2VuX3JlcGx5LT5QR",
    "VJTT05fR1JPVVAgWzFdLT5QQVRfR1JPVVAgWzFdLT5QSUQgWzFdLT5wYXRpZW50X25hbWUsIFBJRDVfU1otMSwgWC0xKQ0KICAg",
    "ICBTZXQgUElENV9TWiA9IFBJRDVfU1ogLSAxDQogICAgZWxzZQ0KICAgICBTZXQgWCA9IFggKyAxDQogICAgZW5kaWYNCiAgZW5",
    "kd2hpbGUNCmVuZGlmDQo7OztJZ25vcmUgbWVzc2FnZSBpZiBsZWdhbCBuYW1lIGlzIGJsYW5rDQpTZXQgUElENV9TWiA9IFNJWk",
    "Uob2VuX3JlcGx5LT5QRVJTT05fR1JPVVAgWzFdLT5QQVRfR1JPVVAgWzFdLT5QSUQgWzFdLT5wYXRpZW50X25hbWUsIDUpDQppZ",
    "ihQSUQ1X1NaID0gMCkNCiAgZXhlY3V0ZSBvZW5jcG1fbXNnbG9nKEJVSUxEKCIqKiogTUVTU0FHRSBTS0lQUEVEOiBObyBMZWdh",
    "bCBOYW1lIGZvdW5kIikpDQogIFNldCBvZW5zdGF0dXMtPmlnbm9yZSA9IDENCiAgZ28gdG8gZW5kX29mX3NjcmlwdA0KZW5kaWY",
    "NCg0KO21vZGlmeSBNUkcgc2VnbWVudA0KDQoNCg0KaWYgKHNpemUob2VuX3JlcGx5LT5QRVJTT05fR1JPVVAgWzFdLT5QQVRfR1",
    "JPVVAgWzFdLT5NUkcsNSkgPiAwKQ0KDQoNCglkZWNsYXJlIEFMSUFTUE9PTENPREVTRVQgCQkJPSBpNCB3aXRoIGNvbnN0YW50K",
    "DI2MykNCglkZWNsYXJlIE1SR19GUk9NX1BFUlNPTl9JRCAJCQk9IGY4IHdpdGggbm9jb25zdGFudCgwLjApDQoJZGVjbGFyZSBN",
    "UkdfQ01STl9UWVBFX0NEIAkJCT0gZjggd2l0aCBjb25zdGFudCh1YXJfZ2V0X2NvZGVfYnkoIkRJU1BMQVlLRVkiLCA0LCAiQ09",
    "NTVVOSVRZTUVESUNBTFJFQ09SRE5VTUJFUiIpKQ0KCWRlY2xhcmUgTVJHX0NNUk5fQ0QJCQkJCT0gZjggd2l0aCBjb25zdGFudC",
    "h1YXJfZ2V0X2NvZGVfYnkoIkRJU1BMQVlLRVkiLCAyNjMsICJDTVJOIikpDQoJZGVjbGFyZSBNUkdfSU5FRkZfQ09NQl9BQ1RJT",
    "05fQ0QgCT0gZjggd2l0aCBjb25zdGFudCh1YXJfZ2V0X2NvZGVfYnkoIkRJU1BMQVlLRVkiLCAzMjcsICJNQUtFSU5FRkZFQ1RJ",
    "VkUiKSkNCglkZWNsYXJlIE1SR19SRVZFTkRFRkZfQUNUSU9OX0NEIAk9IGY4IHdpdGggY29uc3RhbnQodWFyX2dldF9jb2RlX2J",
    "5KCJESVNQTEFZS0VZIiwgMzI3LCAiUkVWRVJTRUVOREVGRkVDVElWRSIpKSA7MDAxDQoJZGVjbGFyZSBNUkdOVU0JCQkJCQk9IG",
    "k0IHdpdGggbm9jb25zdGFudCgwKQ0KCWRlY2xhcmUgZmluZE1yZ0F0dGVtcHQJCQkJPSBpNCB3aXRoIG5vY29uc3RhbnQoMCkNC",
    "glkZWNsYXJlIG1heE1ybk1lcmdlQXR0ZW1wdAkJCT0gaTQgd2l0aCBub2NvbnN0YW50KDIwKQ0KCWRlY2xhcmUgbXJnX2FsaWFz",
    "X3Bvb2xfY250IAkJCT0gaTIgd2l0aCBub2NvbnN0YW50KDApDQoJZGVjbGFyZSBtcmdfZm91bmQJCQkJCT0gaTIgd2l0aCBub2N",
    "vbnN0YW50KDApDQoJZXhlY3V0ZSBvZW5jcG1fbXNnbG9nKEJVSUxEKCJNUkcgTVJOIikpOywNCgkNCiAgICAgIAk7dHJpbShvZW",
    "5fcmVwbHktPlBFUlNPTl9HUk9VUCBbMV0tPlBBVF9HUk9VUCBbMV0tPk1SRyBbMV0tPnByaW9yX3BhdF9pZF9pbnQgW1hdLT5hc",
    "3NpZ25fYXV0aC0+bmFtZV9pZCkpKQ0KCQ0KCTtjbGVhciBtcmcgc2VnbWVudA0KCXNldCBzdGF0ID0gYWx0ZXJsaXN0KG9lbl9y",
    "ZXBseS0+UEVSU09OX0dST1VQIFsxXS0+UEFUX0dST1VQIFsxXS0+TVJHLCAwKQ0KCXNldCBzdGF0ID0gYWx0ZXJsaXN0KG9lbl9",
    "yZXBseS0+UEVSU09OX0dST1VQIFsxXS0+UEFUX0dST1VQIFsxXS0+TVJHLCAxKQ0KCQ0KCXNldCAgTVJHX0ZST01fUEVSU09OX0",
    "lEID0gZ2V0X2RvdWJsZV92YWx1ZSgiZnJvbV9wZXJzb25faWQiKQ0KDQoJd2hpbGUgKG1yZ19mb3VuZCAhPSAxKQ0KCQ0KCQlzZ",
    "XQgbXJnTnVtID0gMA0KCQkNCgkJc2VsZWN0IGludG8gIm5sIgkJDQoJCQl1YXJfZ2V0X2NvZGVfZGlzcGxheShwYS5hbGlhc19w",
    "b29sX2NkKQ0KCQkJLHBhLmFsaWFzDQoJCQkscGEucGVyc29uX2lkDQoJCQksc28ub2lkX3R4dA0KCQlmcm9tIA0KCQkJIHBlcnN",
    "vbl9jb21iaW5lIHBjDQoJCQkscGVyc29uX2NvbWJpbmVfZGV0IHBkDQoJCQkscGVyc29uX2FsaWFzIHBhDQoJCQksc2lfb2lkIH",
    "NvDQoJCXBsYW4gcGMgDQoJCQl3aGVyZSBwYy5mcm9tX3BlcnNvbl9pZCA9IE1SR19GUk9NX1BFUlNPTl9JRA0KCQkJCWFuZCBwY",
    "y5hY3RpdmVfaW5kICsgMCA9IDENCgkJCQlhbmQgcGMuZW5jbnRyX2lkICsgMCA9IDAgOzsgZXhjbHVkZXMgdGhlIGVuY291bnRl",
    "ciBtb3ZlIHJlY29yZHMNCgkJam9pbiBwZA0KCQkJd2hlcmUgcGQucGVyc29uX2NvbWJpbmVfaWQgPSBwYy5wZXJzb25fY29tYml",
    "uZV9pZA0KCQkJCWFuZCBwZC5lbnRpdHlfbmFtZSA9ICJQRVJTT05fQUxJQVMiCQ0KCQlqb2luIHBhDQoJCQl3aGVyZSBwYS5wZX",
    "Jzb25fYWxpYXNfaWQgPSBwZC5lbnRpdHlfaWQNCgkJam9pbiBzbw0KCQkJd2hlcmUgc28uZW50aXR5X2lkID0gb3V0ZXJqb2luK",
    "HBhLmFsaWFzX3Bvb2xfY2QpDQoJCQkJYW5kIHNvLkVOVElUWV9OQU1FID0gb3V0ZXJqb2luKCJDT0RFX1ZBTFVFIikNCgkJCQlh",
    "bmQgc28uZW50aXR5X3R5cGUgPSBvdXRlcmpvaW4oIkFMSUFTX1BPT0wiKQ0KCQkJCQ0KCQlvcmRlciBieSBwYS51cGR0X2R0X1R",
    "tIGRlc2MNCgkJZGV0YWlsDQoJCQkJDQoJCQlpZiAoZXhwYW5kKG1yZ19hbGlhc19wb29sX2NudCwxLHNpemUoYWxpYXNfcG9vbF",
    "9jZF9saXN0LT5xdWFsLDUpLHBhLmFsaWFzX3Bvb2xfY2QsDQoJCQkJCWFsaWFzX3Bvb2xfY2RfbGlzdC0+cXVhbFttcmdfYWxpY",
    "XNfcG9vbF9jbnRdLmFsaWFzX3Bvb2xfY2QpDQoJCQkJO2FuZCBwZC5jb21iaW5lX2FjdGlvbl9jZCA9IE1SR19JTkVGRl9DT01C",
    "X0FDVElPTl9DRA0KCQkJCWFuZCBwZC5jb21iaW5lX2FjdGlvbl9jZCBpbiAoTVJHX0lORUZGX0NPTUJfQUNUSU9OX0NELCBNUkd",
    "fUkVWRU5ERUZGX0FDVElPTl9DRCkgOzAwMQ0KCQkJCWFuZCBwYS5hY3RpdmVfaW5kICsgMCA9IDENCgkJCQk7YW5kIHBhLmVuZF",
    "9lZmZlY3RpdmVfZHRfVG0gPD0gY252dGRhdGV0aW1lKGN1cmRhdGUsY3VydGltZSkNCgkJCQlhbmQgcGQucHJldl9lbmRfZWZmX",
    "2R0X3RtID49IGNudnRkYXRldGltZSgiMzEtREVDLTIxMDAgMDA6MDA6MDAiKSkNCgkJCQkJDQoJCQkJICBtcmdOdW0gPSBtcmdO",
    "dW0gKyAxDQoJCQkJICBzdGF0ID0gYWx0ZXJsaXN0KG9lbl9yZXBseS0+UEVSU09OX0dST1VQIFsxXS0+UEFUX0dST1VQIFsxXS0",
    "+TVJHIFsxXS0+cHJpb3JfcGF0X2lkX2ludCwgbXJnTnVtKQ0KCQkJCSAgb2VuX3JlcGx5LT5QRVJTT05fR1JPVVAgWzFdLT5QQV",
    "RfR1JPVVAgWzFdLT5NUkcgWzFdLT5wcmlvcl9wYXRfaWRfaW50IFttcmdOdW1dLT5pZCA9IHBhLmFsaWFzDQoJCQkJICBvZW5fc",
    "mVwbHktPlBFUlNPTl9HUk9VUCBbMV0tPlBBVF9HUk9VUCBbMV0tPk1SRyBbMV0tPnByaW9yX3BhdF9pZF9pbnQgW21yZ051bV0t",
    "PmFzc2lnbl9hdXRoLT51bml2X2lkID0gc28ub2lkX3R4dA0KCQkJCSAgb2VuX3JlcGx5LT5QRVJTT05fR1JPVVAgWzFdLT5QQVR",
    "fR1JPVVAgWzFdLT5NUkcgWzFdLT5wcmlvcl9wYXRfaWRfaW50IFttcmdOdW1dLT5hc3NpZ25fYXV0aC0+dW5pdl9pZF90eXBlID",
    "0gIklTTyINCgkJCQkgIG9lbl9yZXBseS0+UEVSU09OX0dST1VQIFsxXS0+UEFUX0dST1VQIFsxXS0+TVJHIFsxXS0+cHJpb3Jfc",
    "GF0X2lkX2ludCBbbXJnTnVtXS0+YXNzaWduX2F1dGgtPm5hbWVfaWQgPSAiIg0KCQkJCSAgb2VuX3JlcGx5LT5QRVJTT05fR1JP",
    "VVAgWzFdLT5QQVRfR1JPVVAgWzFdLT5NUkcgWzFdLT5wcmlvcl9wYXRfaWRfaW50IFttcmdOdW1dLT5hc3NpZ25fZmFjX2lkLT5",
    "uYW1lX2lkID0gIiINCgkJCQkgIG9lbl9yZXBseS0+UEVSU09OX0dST1VQIFsxXS0+UEFUX0dST1VQIFsxXS0+TVJHIFsxXS0+cH",
    "Jpb3JfcGF0X2lkX2ludCBbbXJnTnVtXS0+YXNzaWduX2ZhY19pZC0+dW5pdl9pZCA9ICIiDQoJCQkJICBvZW5fcmVwbHktPlBFU",
    "lNPTl9HUk9VUCBbMV0tPlBBVF9HUk9VUCBbMV0tPk1SRyBbMV0tPnByaW9yX3BhdF9pZF9pbnQgW21yZ051bV0tPmFzc2lnbl9m",
    "YWNfaWQtPnVuaXZfaWRfdHlwZSA9ICIiDQoJCQkJICBvZW5fcmVwbHktPlBFUlNPTl9HUk9VUCBbMV0tPlBBVF9HUk9VUCBbMV0",
    "tPk1SRyBbMV0tPnByaW9yX3BhdF9pZF9pbnQgW21yZ051bV0tPmVmZmVjdGl2ZV9kYXRlID0gIiINCgkJCQkgIG9lbl9yZXBseS",
    "0+UEVSU09OX0dST1VQIFsxXS0+UEFUX0dST1VQIFsxXS0+TVJHIFsxXS0+cHJpb3JfcGF0X2lkX2ludCBbbXJnTnVtXS0+ZXhwa",
    "XJhdGlvbl9kYXRlID0gIiINCgkJCWVuZGlmDQoJCQ0KCQkJc2V0IG1yZ19mb3VuZCA9IDENCgkJd2l0aCBub2NvdW50ZXINCgkJ",
    "DQoJCWlmIChtcmdfZm91bmQgPSAwKQ0KCQkJc2V0IGZpbmRNcmdBdHRlbXB0ID0gZmluZE1yZ0F0dGVtcHQgKyAxDQoJCQkNCgk",
    "JCTtzdG9wIGludGVyZmFjZSBpZiBtZXJnZSByb3dzIGFyZSBub3QgZm91bmQgd2l0aGluIHRoZSBtYXggbnVtYmVyIG9mIGF0dG",
    "VtcHRzDQoJCQlpZiAoZmluZE1yZ0F0dGVtcHQgPj0gbWF4TXJuTWVyZ2VBdHRlbXB0KQ0KCQkJCWV4ZWN1dGUgb2VuY3BtX21zZ",
    "2xvZyhCVUlMRCgiQ29tYmluZSByb3dzIG5vdCBmb3VuZCBpbiBEYXRhYmFzZS4gU2h1dHRpbmcgZG93biBpbnRlcmZhY2UhIikp",
    "DQoJCQkJc2V0IG9lbnN0YXR1cy0+c3RhdHVzID0gMCANCgkJCQlnbyB0byBlbmRfb2Zfc2NyaXB0DQoJCQllbmRpZg0KCQkNCgk",
    "JCTt1c2UgZm9yIGxvb3AgdG8gY2FsbCBwYXVzZSBzaW5jZSBmdW5jdGlvbiBkb2VzIG5vdCBiZWhhdmUgdGhlIHNhbWUgaW4gc2",
    "9tZSBkb21haW5zDQoJCQlmb3IgKHggPSAxIHRvIDUpDQoJCQkJY2FsbCBwYXVzZSAoMSkNCgkJCWVuZGZvcg0KCQllbmRpZg0KC",
    "WVuZHdoaWxlDQoJDQoJaWYgKHNpemUob2VuX3JlcGx5LT5QRVJTT05fR1JPVVAgWzFdLT5QQVRfR1JPVVAgWzFdLT5NUkcgWzFd",
    "LT5wcmlvcl9wYXRfaWRfaW50LCA1KSA8IDEpDQoJICBleGVjdXRlIG9lbmNwbV9tc2dsb2coQlVJTEQoIioqKiBNRVNTQUdFIFN",
    "LSVBQRUQ6IE5vIG1lcmdlZCBhbGlhc2VzIGZvdW5kIHRvIHNlbmQiKSkNCgkJU2V0IG9lbnN0YXR1cy0+aWdub3JlID0gMQ0KCQ",
    "lnbyB0byBlbmRfb2Zfc2NyaXB0DQoJZW5kaWYNCg0KZW5kaWYJCQ0KDQogIA0KO1JlbW92ZSB1bm5lY2Vzc2FyeSBkZW1vZ3Jhc",
    "GhpY3MNClNldCBzdGF0ID0gYWx0ZXJsaXN0KG9lbl9yZXBseS0+UEVSU09OX0dST1VQIFsxXS0+UEFUX0dST1VQIFsxXS0+UElE",
    "IFsxXS0+cmFjZSwgMCkNCmlmIChzaXplKG9lbl9yZXBseS0+Q09OVFJPTF9HUk9VUCBbMV0tPkVWTiw1KSA+IDApDQogU2V0IHN",
    "0YXQgPSBhbHRlcmxpc3Qob2VuX3JlcGx5LT5DT05UUk9MX0dST1VQIFsxXS0+RVZOIFsxXS0+b3BlcmF0b3JfaWQsMCkNCmVuZG",
    "lmDQpTZXQgc3RhdCA9IGFsdGVybGlzdChvZW5fcmVwbHktPlBFUlNPTl9HUk9VUCBbMV0tPlBBVF9HUk9VUCBbMV0tPlBJRCBbM",
    "V0tPmFsdGVybmF0ZV9wYXRfaWQsIDApDQpTZXQgc3RhdCA9IGFsdGVybGlzdChvZW5fcmVwbHktPlBFUlNPTl9HUk9VUCBbMV0t",
    "PlBBVF9HUk9VUCBbMV0tPlBJRCBbMV0tPnBhdGllbnRfYWxpYXMsIDApDQpTZXQgc3RhdCA9IGFsdGVybGlzdChvZW5fcmVwbHk",
    "tPlBFUlNPTl9HUk9VUCBbMV0tPlBBVF9HUk9VUCBbMV0tPlBJRCBbMV0tPnBoX25icl9ob21lICwgMCkNClNldCBzdGF0ID0gYW",
    "x0ZXJsaXN0KG9lbl9yZXBseS0+UEVSU09OX0dST1VQIFsxXS0+UEFUX0dST1VQIFsxXS0+UElEIFsxXS0+bW90aGVyc19pZCwgM",
    "CkNClNldCBzdGF0ID0gYWx0ZXJsaXN0KG9lbl9yZXBseS0+UEVSU09OX0dST1VQIFsxXS0+UEFUX0dST1VQIFsxXS0+UElEIFsx",
    "XS0+Y2l0aXplbnNoaXAsIDApDQpTZXQgc3RhdCA9IGFsdGVybGlzdChvZW5fcmVwbHktPlBFUlNPTl9HUk9VUCBbMV0tPlBBVF9",
    "HUk9VUCBbMV0tPlBJRCBbMV0tPnJhY2UsIDApDQpTZXQgc3RhdCA9IGFsdGVybGlzdChvZW5fcmVwbHktPlBFUlNPTl9HUk9VUC",
    "BbMV0tPlBBVF9HUk9VUCBbMV0tPlBJRCBbMV0tPnBoX25icl9idXMgLCAwKQ0KU2V0IG9lbl9yZXBseS0+UEVSU09OX0dST1VQI",
    "FsxXS0+UEFUX0dST1VQIFsxXS0+UElEIFsxXS0+Y291bnR5X2NvZGUgPSAiIg0KU2V0IG9lbl9yZXBseS0+UEVSU09OX0dST1VQ",
    "IFsxXS0+UEFUX0dST1VQIFsxXS0+UElEIFsxXS0+bWFyaXRhbF9zdGF0dXMgPSAiIg0KU2V0IG9lbl9yZXBseS0+UEVSU09OX0d",
    "ST1VQIFsxXS0+UEFUX0dST1VQIFsxXS0+UElEIFsxXS0+cmVsaWdpb24gPSAiIg0KU2V0IG9lbl9yZXBseS0+UEVSU09OX0dST1",
    "VQIFsxXS0+UEFUX0dST1VQIFsxXS0+UElEIFsxXS0+ZXRobmljX2dycCA9ICIiDQpTZXQgb2VuX3JlcGx5LT5QRVJTT05fR1JPV",
    "VAgWzFdLT5QQVRfR1JPVVAgWzFdLT5QSUQgWzFdLT5iaXJ0aHBsYWNlID0gIiINClNldCBvZW5fcmVwbHktPlBFUlNPTl9HUk9V",
    "UCBbMV0tPlBBVF9HUk9VUCBbMV0tPlBJRCBbMV0tPm11bHRpcGxlX2JpcnRoX2luZCA9ICIiDQpTZXQgb2VuX3JlcGx5LT5QRVJ",
    "TT05fR1JPVVAgWzFdLT5QQVRfR1JPVVAgWzFdLT5QSUQgWzFdLT5iaXJ0aF9vcmRlciA9ICIiDQpTZXQgb2VuX3JlcGx5LT5QRV",
    "JTT05fR1JPVVAgWzFdLT5QQVRfR1JPVVAgWzFdLT5QSUQgWzFdLT5wYXRfZGVhdGhfZHRfdG0gPSAiIg0KU2V0IG9lbl9yZXBse",
    "S0+UEVSU09OX0dST1VQIFsxXS0+UEFUX0dST1VQIFsxXS0+UElEIFsxXS0+cGF0X2RlYXRoX2luZCA9ICIiDQpTZXQgb2VuX3Jl",
    "cGx5LT5QRVJTT05fR1JPVVAgWzFdLT5QQVRfR1JPVVAgWzFdLT5QSUQgWzFdLT5tb3RoZXJzX21haWRlbl9uYW1lLT5sYXN0X25",
    "hbWUgPSAiIg0KU2V0IG9lbl9yZXBseS0+UEVSU09OX0dST1VQIFsxXS0+UEFUX0dST1VQIFsxXS0+UElEIFsxXS0+bW90aGVyc1",
    "9tYWlkZW5fbmFtZS0+Zmlyc3RfbmFtZSA9ICIiDQpTZXQgb2VuX3JlcGx5LT5QRVJTT05fR1JPVVAgWzFdLT5QQVRfR1JPVVAgW",
    "zFdLT5QSUQgWzFdLT5tb3RoZXJzX21haWRlbl9uYW1lLT5taWRkbGVfbmFtZSA9ICIiDQpTZXQgb2VuX3JlcGx5LT5QRVJTT05f",
    "R1JPVVAgWzFdLT5QQVRfR1JPVVAgWzFdLT5QSUQgWzFdLT5tb3RoZXJzX21haWRlbl9uYW1lLT5zdWZmaXggPSAiIg0KU2V0IG9",
    "lbl9yZXBseS0+UEVSU09OX0dST1VQIFsxXS0+UEFUX0dST1VQIFsxXS0+UElEIFsxXS0+bW90aGVyc19tYWlkZW5fbmFtZS0+cH",
    "JlZml4ID0gIiINClNldCBvZW5fcmVwbHktPlBFUlNPTl9HUk9VUCBbMV0tPlBBVF9HUk9VUCBbMV0tPlBJRCBbMV0tPm1vdGhlc",
    "nNfbWFpZGVuX25hbWUtPmRlZ3JlZSA9ICIiDQpTZXQgb2VuX3JlcGx5LT5QRVJTT05fR1JPVVAgWzFdLT5QQVRfR1JPVVAgWzFd",
    "LT5QSUQgWzFdLT5tb3RoZXJzX21haWRlbl9uYW1lLT5uYW1lX3R5cGVfY2QgPSAiIg0KU2V0IG9lbl9yZXBseS0+UEVSU09OX0d",
    "ST1VQIFsxXS0+UEFUX0dST1VQIFsxXS0+UElEIFsxXS0+cGF0aWVudF9hY2NvdW50X25ici0+aWQgPSAiIg0KU2V0IG9lbl9yZX",
    "BseS0+UEVSU09OX0dST1VQIFsxXS0+UEFUX0dST1VQIFsxXS0+UElEIFsxXS0+cGF0aWVudF9hY2NvdW50X25ici0+Y2hlY2tfZ",
    "GlnaXQgPSAiIg0KU2V0IG9lbl9yZXBseS0+UEVSU09OX0dST1VQIFsxXS0+UEFUX0dST1VQIFsxXS0+UElEIFsxXS0+cGF0aWVu",
    "dF9hY2NvdW50X25ici0+Y2hlY2tfZGlnaXRfc2NoZW1lID0gIiINClNldCBvZW5fcmVwbHktPlBFUlNPTl9HUk9VUCBbMV0tPlB",
    "BVF9HUk9VUCBbMV0tPlBJRCBbMV0tPnBhdGllbnRfYWNjb3VudF9uYnItPmFzc2lnbl9hdXRoLT5uYW1lX2lkID0gIiINClNldC",
    "BvZW5fcmVwbHktPlBFUlNPTl9HUk9VUCBbMV0tPlBBVF9HUk9VUCBbMV0tPlBJRCBbMV0tPnBhdGllbnRfYWNjb3VudF9uYnItP",
    "mFzc2lnbl9hdXRoLT51bml2X2lkID0gIiINClNldCBvZW5fcmVwbHktPlBFUlNPTl9HUk9VUCBbMV0tPlBBVF9HUk9VUCBbMV0t",
    "PlBJRCBbMV0tPnBhdGllbnRfYWNjb3VudF9uYnItPmFzc2lnbl9hdXRoLT51bml2X2lkX3R5cGUgPSAiIg0KU2V0IG9lbl9yZXB",
    "seS0+UEVSU09OX0dST1VQIFsxXS0+UEFUX0dST1VQIFsxXS0+UElEIFsxXS0+cGF0aWVudF9hY2NvdW50X25ici0+dHlwZV9jZC",
    "A9ICIiDQpTZXQgb2VuX3JlcGx5LT5QRVJTT05fR1JPVVAgWzFdLT5QQVRfR1JPVVAgWzFdLT5QSUQgWzFdLT5wYXRpZW50X2FjY",
    "291bnRfbmJyLT5hc3NpZ25fZmFjX2lkLT5uYW1lX2lkID0gIiINClNldCBvZW5fcmVwbHktPlBFUlNPTl9HUk9VUCBbMV0tPlBB",
    "VF9HUk9VUCBbMV0tPlBJRCBbMV0tPnBhdGllbnRfYWNjb3VudF9uYnItPmFzc2lnbl9mYWNfaWQtPnVuaXZfaWQgPSAiIg0KU2V",
    "0IG9lbl9yZXBseS0+UEVSU09OX0dST1VQIFsxXS0+UEFUX0dST1VQIFsxXS0+UElEIFsxXS0+cGF0aWVudF9hY2NvdW50X25ici",
    "0+YXNzaWduX2ZhY19pZC0+dW5pdl9pZF90eXBlID0gIiINClNldCBvZW5fcmVwbHktPlBFUlNPTl9HUk9VUCBbMV0tPlBBVF9HU",
    "k9VUCBbMV0tPlBJRCBbMV0tPnBhdGllbnRfYWNjb3VudF9uYnItPmVmZmVjdGl2ZV9kYXRlID0gIiINClNldCBvZW5fcmVwbHkt",
    "PlBFUlNPTl9HUk9VUCBbMV0tPlBBVF9HUk9VUCBbMV0tPlBJRCBbMV0tPnBhdGllbnRfYWNjb3VudF9uYnItPmV4cGlyYXRpb25",
    "fZGF0ZSA9ICIiDQpTZXQgb2VuX3JlcGx5LT5QRVJTT05fR1JPVVAgWzFdLT5QQVRfR1JPVVAgWzFdLT5QSUQgWzFdLT5kcml2ZX",
    "JzX2xpY19uYnItPmxpY2Vuc2VfbnVtYmVyID0gIiINClNldCBvZW5fcmVwbHktPlBFUlNPTl9HUk9VUCBbMV0tPlBBVF9HUk9VU",
    "CBbMV0tPlBJRCBbMV0tPmRyaXZlcnNfbGljX25ici0+aXNzX3N0X3Byb3ZfY3RyeSA9ICIiDQpTZXQgb2VuX3JlcGx5LT5QRVJT",
    "T05fR1JPVVAgWzFdLT5QQVRfR1JPVVAgWzFdLT5QSUQgWzFdLT5kcml2ZXJzX2xpY19uYnItPmV4cGlyYXRpb25fZHRfdG0gPSA",
    "iIg0KU2V0IG9lbl9yZXBseS0+UEVSU09OX0dST1VQIFsxXS0+UEFUX0dST1VQIFsxXS0+UElEIFsxXS0+dmV0X21pbF9zdGF0LT",
    "5pZGVudGlmaWVyID0gIiINClNldCBvZW5fcmVwbHktPlBFUlNPTl9HUk9VUCBbMV0tPlBBVF9HUk9VUCBbMV0tPlBJRCBbMV0tP",
    "nZldF9taWxfc3RhdC0+dGV4dCA9ICIiDQpTZXQgb2VuX3JlcGx5LT5QRVJTT05fR1JPVVAgWzFdLT5QQVRfR1JPVVAgWzFdLT5Q",
    "SUQgWzFdLT52ZXRfbWlsX3N0YXQtPmNvZGluZ19zeXN0ZW0gPSAiIg0KU2V0IG9lbl9yZXBseS0+UEVSU09OX0dST1VQIFsxXS0",
    "+UEFUX0dST1VQIFsxXS0+UElEIFsxXS0+dmV0X21pbF9zdGF0LT5hbHRfaWRlbnRpZmllciA9ICIiDQpTZXQgb2VuX3JlcGx5LT",
    "5QRVJTT05fR1JPVVAgWzFdLT5QQVRfR1JPVVAgWzFdLT5QSUQgWzFdLT52ZXRfbWlsX3N0YXQtPmFsdF90ZXh0ID0gIiINClNld",
    "CBvZW5fcmVwbHktPlBFUlNPTl9HUk9VUCBbMV0tPlBBVF9HUk9VUCBbMV0tPlBJRCBbMV0tPnZldF9taWxfc3RhdC0+YWx0X2Nv",
    "ZGluZ19zeXN0ZW0gPSAiIg0KU2V0IG9lbl9yZXBseS0+UEVSU09OX0dST1VQIFsxXS0+UEFUX0dST1VQIFsxXS0+UElEIFsxXS0",
    "+bmF0aW9uYWxpdHktPmlkZW50aWZpZXIgPSAiIg0KU2V0IG9lbl9yZXBseS0+UEVSU09OX0dST1VQIFsxXS0+UEFUX0dST1VQIF",
    "sxXS0+UElEIFsxXS0+bmF0aW9uYWxpdHktPnRleHQgPSAiIg0KU2V0IG9lbl9yZXBseS0+UEVSU09OX0dST1VQIFsxXS0+UEFUX",
    "0dST1VQIFsxXS0+UElEIFsxXS0+bmF0aW9uYWxpdHktPmNvZGluZ19zeXN0ZW0gPSAiIg0KU2V0IG9lbl9yZXBseS0+UEVSU09O",
    "X0dST1VQIFsxXS0+UEFUX0dST1VQIFsxXS0+UElEIFsxXS0+bmF0aW9uYWxpdHktPmFsdF9pZGVudGlmaWVyID0gIiINClNldCB",
    "vZW5fcmVwbHktPlBFUlNPTl9HUk9VUCBbMV0tPlBBVF9HUk9VUCBbMV0tPlBJRCBbMV0tPm5hdGlvbmFsaXR5LT5hbHRfdGV4dC",
    "A9ICIiDQpTZXQgb2VuX3JlcGx5LT5QRVJTT05fR1JPVVAgWzFdLT5QQVRfR1JPVVAgWzFdLT5QSUQgWzFdLT5uYXRpb25hbGl0e",
    "S0+YWx0X2NvZGluZ19zeXN0ZW0gPSAiIg0KU2V0IG9lbl9yZXBseS0+UEVSU09OX0dST1VQIFsxXS0+UEFUX0dST1VQIFsxXS0+",
    "UElEIFsxXS0+bGFuZ3VhZ2VfcGF0aWVudC0+aWRlbnRpZmllciA9ICIiDQpTZXQgb2VuX3JlcGx5LT5QRVJTT05fR1JPVVAgWzF",
    "dLT5QQVRfR1JPVVAgWzFdLT5QSUQgWzFdLT5sYW5ndWFnZV9wYXRpZW50LT50ZXh0ID0gIiINClNldCBvZW5fcmVwbHktPlBFUl",
    "NPTl9HUk9VUCBbMV0tPlBBVF9HUk9VUCBbMV0tPlBJRCBbMV0tPmxhbmd1YWdlX3BhdGllbnQtPmNvZGluZ19zeXN0ZW0gPSAiI",
    "g0KU2V0IG9lbl9yZXBseS0+UEVSU09OX0dST1VQIFsxXS0+UEFUX0dST1VQIFsxXS0+UElEIFsxXS0+bGFuZ3VhZ2VfcGF0aWVu",
    "dC0+YWx0X2lkZW50aWZpZXIgPSAiIg0KU2V0IG9lbl9yZXBseS0+UEVSU09OX0dST1VQIFsxXS0+UEFUX0dST1VQIFsxXS0+UEl",
    "EIFsxXS0+bGFuZ3VhZ2VfcGF0aWVudC0+YWx0X3RleHQgPSAiIg0KU2V0IG9lbl9yZXBseS0+UEVSU09OX0dST1VQIFsxXS0+UE",
    "FUX0dST1VQIFsxXS0+UElEIFsxXS0+bGFuZ3VhZ2VfcGF0aWVudC0+YWx0X2NvZGluZ19zeXN0ZW0gPSAiIg0KU2V0IG9lbl9yZ",
    "XBseS0+UEVSU09OX0dST1VQIFsxXS0+UEFUX0dST1VQIFsxXS0+UElEIFsxXS0+cGF0aWVudF9pZF9leHQtPmlkID0gIiINClNl",
    "dCBvZW5fcmVwbHktPlBFUlNPTl9HUk9VUCBbMV0tPlBBVF9HUk9VUCBbMV0tPlBJRCBbMV0tPnBhdGllbnRfaWRfZXh0LT5hc3N",
    "pZ25fYXV0aC0+bmFtZV9pZCA9ICAiIg0KU2V0IG9lbl9yZXBseS0+UEVSU09OX0dST1VQIFsxXS0+UEFUX0dST1VQIFsxXS0+UE",
    "lEIFsxXS0+cGF0aWVudF9pZF9leHQtPmFzc2lnbl9hdXRoLT51bml2X2lkID0gIiINClNldCBvZW5fcmVwbHktPlBFUlNPTl9HU",
    "k9VUCBbMV0tPlBBVF9HUk9VUCBbMV0tPlBJRCBbMV0tPnBhdGllbnRfaWRfZXh0LT5hc3NpZ25fYXV0aC0+dW5pdl9pZF90eXBl",
    "ID0gIiINClNldCBvZW5fcmVwbHktPlBFUlNPTl9HUk9VUCBbMV0tPlBBVF9HUk9VUCBbMV0tPlBJRCBbMV0tPnBhdGllbnRfaWR",
    "fZXh0LT50eXBlX2NkID0gIiINClNldCBvZW5fcmVwbHktPlBFUlNPTl9HUk9VUCBbMV0tPlBBVF9HUk9VUCBbMV0tPlBJRCBbMV",
    "0tPnBhdGllbnRfaWRfZXh0LT5jaGVja19kaWdpdCA9ICIiDQpTZXQgb2VuX3JlcGx5LT5QRVJTT05fR1JPVVAgWzFdLT5QQVRfR",
    "1JPVVAgWzFdLT5QSUQgWzFdLT5wYXRpZW50X2lkX2V4dC0+Y2hlY2tfZGlnaXRfc2NoZW1lID0gIiINClNldCBvZW5fcmVwbHkt",
    "PlBFUlNPTl9HUk9VUCBbMV0tPlBBVF9HUk9VUCBbMV0tPlBJRCBbMV0tPnBhdGllbnRfaWRfZXh0LT50eXBlX2NkID0gIiINClN",
    "ldCBvZW5fcmVwbHktPlBFUlNPTl9HUk9VUCBbMV0tPlBBVF9HUk9VUCBbMV0tPlBJRCBbMV0tPnBhdGllbnRfaWRfZXh0LT5hc3",
    "NpZ25fZmFjX2lkLT5uYW1lX2lkID0gIiINClNldCBvZW5fcmVwbHktPlBFUlNPTl9HUk9VUCBbMV0tPlBBVF9HUk9VUCBbMV0tP",
    "lBJRCBbMV0tPnBhdGllbnRfaWRfZXh0LT5hc3NpZ25fZmFjX2lkLT51bml2X2lkID0gIiINClNldCBvZW5fcmVwbHktPlBFUlNP",
    "Tl9HUk9VUCBbMV0tPlBBVF9HUk9VUCBbMV0tPlBJRCBbMV0tPnBhdGllbnRfaWRfZXh0LT5hc3NpZ25fZmFjX2lkLT51bml2X2l",
    "kX3R5cGUgPSAiIg0KU2V0IG9lbl9yZXBseS0+UEVSU09OX0dST1VQIFsxXS0+UEFUX0dST1VQIFsxXS0+UElEIFsxXS0+cGF0aW",
    "VudF9pZF9leHQtPmVmZmVjdGl2ZV9kYXRlID0gIiINClNldCBvZW5fcmVwbHktPlBFUlNPTl9HUk9VUCBbMV0tPlBBVF9HUk9VU",
    "CBbMV0tPlBJRCBbMV0tPnBhdGllbnRfaWRfZXh0LT5leHBpcmF0aW9uX2RhdGUgPSAiIg0KDQo7UmVtb3ZlIHVubmVjZXNzYXJ5",
    "IHNlZ21lbnRzDQpzZXQgc3RhdCA9IGFsdGVybGlzdChvZW5fcmVwbHktPlBFUlNPTl9HUk9VUFsxXS0+Q0xJTl9HUk9VUCwgMCk",
    "NCnNldCBzdGF0ID0gYWx0ZXJsaXN0KG9lbl9yZXBseS0+UEVSU09OX0dST1VQWzFdLT5GSU5fR1JPVVAsIDApDQpzZXQgc3RhdC",
    "A9IGFsdGVybGlzdChvZW5fcmVwbHktPlBFUlNPTl9HUk9VUFsxXS0+UEFUX0dST1VQWzFdLT5OVEUsIDApDQpzZXQgc3RhdCA9I",
    "GFsdGVybGlzdChvZW5fcmVwbHktPlBFUlNPTl9HUk9VUFsxXS0+UEFUX0dST1VQWzFdLT5QRDEsIDApDQpzZXQgc3RhdCA9IGFs",
    "dGVybGlzdChvZW5fcmVwbHktPlBFUlNPTl9HUk9VUFsxXS0+UEFUX0dST1VQWzFdLT5aUEksIDApDQpzZXQgc3RhdCA9IGFsdGV",
    "ybGlzdChvZW5fcmVwbHktPlBFUlNPTl9HUk9VUFsxXS0+UEFUX0dST1VQWzFdLT5aQ04sIDApDQpzZXQgc3RhdCA9IGFsdGVybG",
    "lzdChvZW5fcmVwbHktPlBFUlNPTl9HUk9VUFsxXS0+UEFUX0dST1VQWzFdLT5aRUksIDApDQpzZXQgc3RhdCA9IGFsdGVybGlzd",
    "ChvZW5fcmVwbHktPlBFUlNPTl9HUk9VUFsxXS0+UEFUX0dST1VQWzFdLT5OSzEsIDApDQpzZXQgc3RhdCA9IGFsdGVybGlzdChv",
    "ZW5fcmVwbHktPlBFUlNPTl9HUk9VUFsxXS0+UEFUX0dST1VQWzFdLT5aS0ksIDApDQpzZXQgc3RhdCA9IGFsdGVybGlzdChvZW5",
    "fcmVwbHktPlBFUlNPTl9HUk9VUFsxXS0+UEFUX0dST1VQWzFdLT5QVjEsIDApDQpzZXQgc3RhdCA9IGFsdGVybGlzdChvZW5fcm",
    "VwbHktPlBFUlNPTl9HUk9VUFsxXS0+UEFUX0dST1VQWzFdLT5QVjIsIDApDQpzZXQgc3RhdCA9IGFsdGVybGlzdChvZW5fcmVwb",
    "HktPlBFUlNPTl9HUk9VUFsxXS0+UEFUX0dST1VQWzFdLT5aVkksIDApDQpzZXQgc3RhdCA9IGFsdGVybGlzdChvZW5fcmVwbHkt",
    "PlBFUlNPTl9HUk9VUFsxXS0+UEFUX0dST1VQWzFdLT5aQkUsIDApDQpzZXQgc3RhdCA9IGFsdGVybGlzdChvZW5fcmVwbHktPlB",
    "FUlNPTl9HUk9VUFsxXS0+UEFUX0dST1VQWzFdLT5aRlAsIDApDQpzZXQgc3RhdCA9IGFsdGVybGlzdChvZW5fcmVwbHktPlBFUl",
    "NPTl9HUk9VUFsxXS0+UEFUX0dST1VQWzFdLT5aRlYsIDApDQpzZXQgc3RhdCA9IGFsdGVybGlzdChvZW5fcmVwbHktPlBFUlNPT",
    "l9HUk9VUFsxXS0+UEFUX0dST1VQWzFdLT5aRk0sIDApDQpzZXQgc3RhdCA9IGFsdGVybGlzdChvZW5fcmVwbHktPlBFUlNPTl9H",
    "Uk9VUFsxXS0+UEFUX0dST1VQWzFdLT5aRkQsIDApDQpzZXQgc3RhdCA9IGFsdGVybGlzdChvZW5fcmVwbHktPlBFUlNPTl9HUk9",
    "VUFsxXS0+UEFUX0dST1VQWzFdLT5PQlgsIDApDQpzZXQgc3RhdCA9IGFsdGVybGlzdChvZW5fcmVwbHktPlBFUlNPTl9HUk9VUF",
    "sxXS0+UEFUX0dST1VQWzFdLT5BTDFfR1JPVVAsIDApIA0KDQplbHNlDQogc2V0IG9lbnN0YXR1cy0+aWdub3JlID0gMQ0KZW5ka",
    "WYNCg0KI2VuZF9vZl9zY3JpcHQNCg0KU1VCUk9VVElORSBnZXRfb2VuX3JlcGx5X2xvbmcoIHNlYV9uYW1lICkNCg0KICBkZWNs",
    "YXJlIHhfaSAgICAgICAgPSBpMg0KICBkZWNsYXJlIGxpc3Rfc2l6ZSAgPSBpMg0KDQogIHNldCB4X2kgICAgICAgID0gMA0KICB",
    "zZXQgbGlzdF9zaXplICA9IDANCiAgc2V0IGxpc3Rfc2l6ZSA9IHNpemUob2VuX3JlcGx5LT5jZXJuZXItPmxvbmdMaXN0LCA1KQ",
    "0KICBpZiggbGlzdF9zaXplID4gMCApDQogICAgIGZvciggeF9pID0gMCB0byAoIGxpc3Rfc2l6ZSAtIDEgKSApDQogICAgICAgI",
    "CBpZiggb2VuX3JlcGx5LT5jZXJuZXItPmxvbmdMaXN0W3hfaV0uU1RSTUVBTklORyA9IGNudnRsb3dlciggc2VhX25hbWUgKSAp",
    "DQogICAgICAgICAgICByZXR1cm4oIG9lbl9yZXBseS0+Y2VybmVyLT5sb25nTGlzdFt4X2ldLkxWQUwgKQ0KICAgICAgICAgZW5",
    "kaWYNCiAgICAgZW5kZm9yDQogIGVsc2UNCiAgICAgY2FsbCBlY2hvKCAibG9uZ0xpc3QgaXMgZW1wdHkiICkNCiAgZW5kaWYNCi",
    "AgcmV0dXJuICggLTEgKQ0KDQpFTkQNCg0Kc3Vicm91dGluZSBXaGF0SXModHJhaXRfbmFtZSkNCmRlY2xhcmUgc3RyaW5nX3Zhb",
    "HVlID0gdmMNCg0Kc2VsZWN0IGludG8gIm5sOiINCmQuc2VxDQpmcm9tIChkdW1teXQgZCB3aXRoIHNlcSA9IHZhbHVlKHNpemUo",
    "b2VuX3Byb2MtPnRyYWl0X2xpc3QsNSkpKQ0Kd2hlcmUgb2VuX3Byb2MtPnRyYWl0X2xpc3RbZC5zZXFdLT5uYW1lID0gdHJpbSh",
    "jbnZ0dXBwZXIodHJhaXRfbmFtZSkpDQpkZXRhaWwNCnN0cmluZ192YWx1ZSA9IG9lbl9wcm9jLT50cmFpdF9saXN0W2Quc2VxXS",
    "0+dmFsdWUNCndpdGggbm9jb3VudGVyDQoNCmlmKGN1cnF1YWwgPSAwKQ0KZXhlY3V0ZSBvZW5jcG1fbXNnbG9nKGNvbmNhdCgiV",
    "HJhaXQgbm90IGZvdW5kOiAiLHRyYWl0X25hbWUpKQ0Kc2V0IG9lbnN0YXR1cy0+c3RhdHVzID0gMCAgICAgOy8vZGVjbGFyZSBm",
    "YWlsdXJlDQpnbyB0byBzY3JpcHRfZXhpdA0KZWxzZQ0KY2FsbCBlY2hvKGNvbmNhdCgidHJhaXQgdmFsdWU6ICIsc3RyaW5nX3Z",
    "hbHVlKSkNCnJldHVybihzdHJpbmdfdmFsdWUpDQplbmRpZg0KDQplbmQgOy8vIFdoYXRJcw0KU1VCUk9VVElORSBHRVRfRE9VQk",
    "xFX1ZBTFVFKFNUUklOR19NRUFOSU5HKQ0KREVDTEFSRSBFU09fSURYID0gSTQNCkRFQ0xBUkUgTElTVF9TSVpFID0gSTQNCkRFQ",
    "0xBUkUgU1RBVFZBUiA9IEMyMA0KDQpTRVQgRVNPX0lEWCA9IDANClNFVCBMSVNUX1NJWkUgPSAwDQoNClNFVCBTVEFUVkFSID0g",
    "KFZBTElEQVRFKG9lbl9yZXBseS0+Q0VSTkVSLCAiTk9DRVJORVJBUkVBIikpDQpJRiAoU1RBVFZBUiA9ICJOT0NFUk5FUkFSRUE",
    "iKQ0KICAgICBSRVRVUk4oIi0xIikNCkVMU0UNCiAgICAgU0VUIEVTT19JRFggPSAwDQogICAgIFNFVCBMSVNUX1NJWkUgPSAwDQ",
    "ogICAgIFNFVCBMSVNUX1NJWkUgPSBTSVpFKG9lbl9yZXBseS0+Q0VSTkVSLT5ET1VCTEVMSVNULDUpDQoNCiAgICAgSUYoIExJU",
    "1RfU0laRSA+IDAgKQ0KICAgICAgICAgIFNFVCBFU09fWCA9IDENCiAgICAgICAgICBGT1IgKCBFU09fWCA9IDEgVE8gTElTVF9T",
    "SVpFICkNCiAgICAgICAgICAgICAgIElGKG9lbl9yZXBseS0+Q0VSTkVSLT5ET1VCTEVMSVNUW0VTT19YXS0+U1RSTUVBTklORyA",
    "9IFNUUklOR19NRUFOSU5HKQ0KICAgICAgICAgICAgICAgICAgICBTRVQgRVNPX0lEWCA9IEVTT19YDQogICAgICAgICAgICAgIC",
    "BFTkRJRg0KICAgICAgICAgIEVOREZPUg0KICAgICBFTkRJRg0KDQoNCiAgICAgSUYoIEVTT19JRFggPiAwICkNCiAgICAgICAgI",
    "CBSRVRVUk4ob2VuX3JlcGx5LT5DRVJORVItPkRPVUJMRUxJU1RbRVNPX0lEWF0tPkRWQUwpDQogICAgIEVMU0UNCiAgICAgICAg",
    "ICBSRVRVUk4oMCkNCiAgICAgRU5ESUYNCkVORElGDQpFTkQgO0dFVF9ET1VCTEUgVkFMVUU")
   SET oenctl_add_script_request->sc_name = resonance_xds_mod_obj_name
   SET oenctl_add_script_request->sc_desc = resonance_xds_mod_obj_desc
   SET oenctl_add_script_request->sc_type = "ModObj"
   SET oenctl_add_script_request->not_executable = 0
   SET oenctl_add_script_request->read_only = 0
   SET oenctl_add_script_request->sc_body = build2(base_64_decode(resonance_xds_mod_obj_base64,"","",
     0,0))
   CALL import_oen_scripts(1)
   CALL include_oen_scripts(oenctl_add_script_request->sc_name)
   RETURN(resonance_xds_mod_obj_name)
 END ;Subroutine
 SUBROUTINE import_res_util_interface(dummy_var)
   FREE RECORD oenctl_add_procinfo_request
   RECORD oenctl_add_procinfo_request(
     1 proc_id = i4
     1 proc_name = vc
     1 proc_desc = vc
     1 proc_path = vc
     1 proc_parm = vc
     1 service = vc
     1 user_name = vc
     1 trait_list[*]
       2 name = vc
       2 value = vc
     1 std_interface_id = i4
     1 primary_node = vc
   )
   DECLARE prod_import = c1 WITH noconstant("")
   DECLARE import_mod_obj = c1 WITH noconstant("")
   DECLARE packesocd = f8 WITH noconstant(0.0)
   DECLARE pack1modobj = vc WITH noconstant(" ")
   DECLARE res_adt_default_sys = vc WITH constant("XDS_ADT_SYSTEM")
   IF (validate(communitycontributorsystemdef)=0)
    DECLARE communitycontributorsystemdef = vc WITH constant("XDS_CONTRIBUTOR_SYSTEM")
   ENDIF
   DECLARE res_util_proc_name = vc WITH constant("RESONANCE_UTILITY_OUT_01")
   DECLARE res_util_proc_name_txt = vc WITH constant("Enter interface name:")
   DECLARE res_util_proc_desc = vc WITH constant("Outbound Resonance Utility")
   DECLARE productionflag = vc WITH noconstant("")
   SET packesocd = get_contributor_system_cd(res_adt_default_sys)
   CALL clear(1,1)
   CALL text(7,15,"Import the latest version of the resonance_utility_mod_obj?:")
   CALL accept(8,15,"#;;C","Y")
   SET import_mod_obj = cnvtupper(curaccept)
   IF (cnvtupper(import_mod_obj)="Y")
    SET pack1modobj = import_hub_resonance_utility_mod_obj_script(1)
    IF (trim(pack1modobj,3)="")
     SET pack1modobj = " "
    ENDIF
   ENDIF
   IF (packesocd > 0.0)
    SET oenctl_add_procinfo_request->proc_name = get_file_name(res_util_proc_name_txt,
     res_util_proc_name)
    CALL clear(1,1)
    CALL text(7,15,"Prod build?:")
    CALL accept(8,15,"#;;C","N")
    SET prod_import = cnvtupper(curaccept)
    IF (cnvtupper(prod_import)="Y")
     SET productionflag = "Y"
    ELSE
     SET productionflag = "N"
    ENDIF
    SET oenctl_add_procinfo_request->proc_desc = res_util_proc_desc
    SET oenctl_add_procinfo_request->service = "Outbound"
    SET oenctl_add_procinfo_request->user_name = "Imported"
    CALL add_personality_trait_to_request("ENABLEOENSTATUS","1")
    CALL add_personality_trait_to_request("PACKESO",cnvtstring(packesocd))
    CALL add_personality_trait_to_request("PRODUCTION",productionflag)
    CALL add_personality_trait_to_request("QUEUEQUOTA","100000")
    CALL add_personality_trait_to_request("REMOTE_ACKNOWLEDGMENT","ACK")
    CALL add_personality_trait_to_request("TRACE_LEVEL","2")
    CALL add_personality_trait_to_request("CONNECTLISTEN","I")
    CALL add_personality_trait_to_request("STARTOFMESSAGE","<011>")
    CALL add_personality_trait_to_request("ENDOFMESSAGE","<028><013>")
    CALL add_personality_trait_to_request("ESI_FIELD",
     "PERSON_GROUP.PAT_GROUP.PID.PATIENT_ID_EXT.PAT_ID")
    CALL add_personality_trait_to_request("TRANSACTION_LOG","Y")
    CALL add_personality_trait_to_request("PACK1",pack1modobj)
    CALL add_personality_trait_to_request("PROTOCOL","DISK")
    CALL add_personality_trait_to_request("OUTPUTFILEPATTERN","/dev/null")
    CALL add_personality_trait_to_request("STEPS","OGSVC")
    CALL add_personality_trait_to_request("G2","PC")
    CALL add_personality_trait_to_request("I11","I")
    CALL add_legacy_interface(1)
   ELSE
    CALL clear(1,1)
    CALL text(7,15,"Contributor System wasn't found! Press enter to exit!")
    CALL accept(8,15,"A;CU","")
   ENDIF
 END ;Subroutine
 SUBROUTINE import_hub_resonance_utility_mod_obj_script(dummy_var)
   DECLARE resonance_util_mod_obj_ver = vc WITH constant("_V1_05")
   DECLARE resonance_util_mod_obj_name = vc WITH constant(build("resonance_utility_mod_obj"))
   DECLARE resonance_util_mod_obj_desc = vc WITH constant(
    "Outbound ADT Mod Obj for Resonance Utility")
   DECLARE resonance_util_mod_obj_base64 = vc WITH noconstant("")
   FREE RECORD oenctl_add_script_request
   RECORD oenctl_add_script_request(
     1 sc_name = vc
     1 sc_desc = vc
     1 sc_type = vc
     1 sc_body = vc
     1 not_executable = i4
     1 read_only = i4
   )
   SET resonance_util_mod_obj_base64 = build2(
    "LyoqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKg0",
    "KICogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgKg",
    "0KICogIENvcHlyaWdodCBOb3RpY2U6ICAoYykgMTk4MyBMYWJvcmF0b3J5IEluZm9ybWF0aW9uIFN5c3RlbXMgJiAgICAgICAgK",
    "g0KICogICAgICAgICAgICAgICAgICAgICAgICAgICAgICBUZWNobm9sb2d5LCBJbmMuICAgICAgICAgICAgICAgICAgICAgICAg",
    "Kg0KICogICAgICAgUmV2aXNpb24gICAgICAoYykgMTk4NC0yMDEzIENlcm5lciBDb3Jwb3JhdGlvbiAgICAgICAgICAgICAgICA",
    "gKg0KICogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIC",
    "AgKg0KICogIENlcm5lciAoUikgUHJvcHJpZXRhcnkgUmlnaHRzIE5vdGljZTogIEFsbCByaWdodHMgcmVzZXJ2ZWQuICAgICAgI",
    "CAgKg0KICogIFRoaXMgbWF0ZXJpYWwgY29udGFpbnMgdGhlIHZhbHVhYmxlIHByb3BlcnRpZXMgYW5kIHRyYWRlIHNlY3JldHMg",
    "b2YgKg0KICogIENlcm5lciBDb3Jwb3JhdGlvbiBvZiBLYW5zYXMgQ2l0eSwgTWlzc291cmksIFVuaXRlZCBTdGF0ZXMgb2YgICA",
    "gICAgKg0KICogIEFtZXJpY2EgKENlcm5lciksIGVtYm9keWluZyBzdWJzdGFudGlhbCBjcmVhdGl2ZSBlZmZvcnRzIGFuZCAgIC",
    "AgICAgKg0KICogIGNvbmZpZGVudGlhbCBpbmZvcm1hdGlvbiwgaWRlYXMgYW5kIGV4cHJlc3Npb25zLCBubyBwYXJ0IG9mIHdoa",
    "WNoICAgKg0KICogIG1heSBiZSByZXByb2R1Y2VkIG9yIHRyYW5zbWl0dGVkIGluIGFueSBmb3JtIG9yIGJ5IGFueSBtZWFucywg",
    "b3IgICAgKg0KICogIHJldGFpbmVkIGluIGFueSBzdG9yYWdlIG9yIHJldHJpZXZhbCBzeXN0ZW0gd2l0aG91dCB0aGUgZXhwcmV",
    "zcyAgICAgKg0KICogIHdyaXR0ZW4gcGVybWlzc2lvbiBvZiBDZXJuZXIuICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIC",
    "AgICAgICAgKg0KICogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgI",
    "CAgICAgICAgKg0KICogIENlcm5lciBpcyBhIHJlZ2lzdGVyZWQgbWFyayBvZiBDZXJuZXIgQ29ycG9yYXRpb24uICAgICAgICAg",
    "ICAgICAgICAgKg0KICogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICA",
    "gICAgICAgICAgKg0KICoqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKi",
    "oqKioqKioqKioqKg0KIA0KICAgICAgICAgIERhdGUgV3JpdHRlbjogICAgICAgMDYvMDkvMjAxNg0KICAgICAgICAgIFNvdXJjZ",
    "SBmaWxlIG5hbWU6ICAgcmVzb25hbmNlX3V0aWxpdHlfbW9kX29iai5wcmcNCiAgICAgICAgICBPYmplY3QgbmFtZToNCiAgICAg",
    "ICAgICBSZXF1ZXN0ICM6ICAgICAgICAgIG4vYQ0KIA0KICAgICAgICAgIFByb2R1Y3Q6ICAgICAgICAgICAgQ09SRSBWNTAwDQo",
    "gICAgICAgICAgUHJvZHVjdCBUZWFtOiAgICAgICBDT1JFIFY1MDANCiAgICAgICAgICBITkEgVmVyc2lvbjogICAgICAgIFY1MD",
    "ANCiAgICAgICAgICBDQ0wgVmVyc2lvbjoNCiANCiAgICAgICAgICBQcm9ncmFtIHB1cnBvc2U6ICAgIG1vZCBvYmplY3QgZm9yI",
    "HRoZSBSZXNvbmFuY2UgVXRpbGl0eQ0KIA0KIA0KICAgICAgICAgIFRhYmxlcyByZWFkOiAgICAgICAgTm9uZS4NCiAgICAgICAg",
    "ICBUYWJsZXMgdXBkYXRlZDogICAgIE5vbmUNCiAgICAgICAgICBFeGVjdXRpbmcgZnJvbToNCiANCiANCiAgICAgICAgICBTcGV",
    "jaWFsIE5vdGVzOiAgICAgIE5vbmUNCiANCiAqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKi",
    "oqKioqKioqKioqKioqKioqKioqKioqKioNCiAqICAgICAgICAgICAgICAgICAgR0VORVJBVEVEIE1PRElGSUNBVElPTiBDT05UU",
    "k9MIExPRyAgICAgICAgICAgICAgICAgICoNCiAqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioq",
    "KioqKioqKioqKioqKioqKioqKioqKioqKioNCiAqICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICA",
    "gICAgICAgICAgICAgICAgICAgICAgICAgICoNCiAqTW9kICAgICBEYXRlICAgICAgICBFbmdpbmVlciAgICAgICAgICAgICAgQ2",
    "9tbWVudCAgICAgICAgICAgICAgICAgICAgICoNCiAqLS0tLS0tICAtLS0tLS0tLS0tICAtLS0tLS0tLS0tLS0tLS0tLS0tLSAgL",
    "S0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLSoNCiAqMDAxCSAgMTIvMTMvMjAxNiAgU1MwMTk1ODAJCQkJYWRkZWQgbGRfZW5h",
    "YmxlZCBmbGFnIHRvIHJlcXVlc3QNCiAqMDAyICAgICAwNS8yNi8yMDE3ICBTUzAxOTU4MAkJCQlhZGRlZCBhYmlsaXR5IHRvIGZ",
    "sZXggdXNlcg0KICowMDMgICAgIDA3LzI3LzIwMTcgIFNTMDE5NTgwCQkJCWFkZGVkIGFiaWxpdHkgdG8gZmxleCBob3cgZW5jb3",
    "VudGVycyBhcmUgb2J0YWluZWQuDQogKjAwNCAgICAgMDkvMTQvMjAxNyAgU1MwMTk1ODAJCQkJYWRkZWQgYWJpbGlpdHkgdG8gZ",
    "mxleCBtaW5pbXVtIGFnZQ0KICoqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioq",
    "KioqKioqKioqKioqKioqKg0KIA0KICoqKioqKioqKioqKioqKioqKiAgRU5EIE9GIEFMTCBNT0RDT05UUk9MIEJMT0NLUyAgKio",
    "qKioqKioqKioqKioqKioqKioqLw0KIA0KOyoqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKi",
    "oqKioqKioqKioqKioqKioqKioqKioqKg0KOyogICAgICAgICAgICAgICAgICAgICAgICAgICAgIHZlcnNpb24gMS4wNSAgICAgI",
    "CAgIAkJCQkJKg0KOyogICAgICAgICAgICAgICAgICAgICAJCQkJICAgICAgICAJCQkJCQkJKg0KOyogICAgICAgICAgICAgICAg",
    "ICAgICAgICAgICAgICAgIE5PVEUJCQkgICAgICAgIAkJCQkqDQo7KiAgVGhpcyBpbnRlcmZhY2Ugd2lsbCBxdWV1ZSB1cCBpZiB",
    "0aGUgaW50ZXJmYWNlIGl0IGlzIG1vbml0b3JpbmcgCQkqDQo7KiAgKHJlcXVlc3QtPmxlZ2FjeV9hZHRfaW50ZWZhY2VbMV0tPn",
    "Byb2NfbmFtZSkgcXVldWVzIHVwIGFuZCB3aWxsIAkqDQo7KiAgYmVnaW4gcHJvY2Vzc2luZyBhZ2FpbiBvbmNlIHRoZSBpbnRlc",
    "mZhY2UgYmVpbmcgbW9uaXRvcmVkIHN0YXJ0cwkqDQo7KiAgcHJvY2Vzc2luZyBhZ2Fpbi4JCQkJCQkJCQkJCQkJKg0KOyoqKioq",
    "KioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKg0KDQogDQo",
    "7b25seSBwcm9jZXNzIEFEVCB0cmFuc2FjdGlvbnMNCmlmKG9lbl9yZXBseS0+Q09OVFJPTF9HUk9VUCBbMV0tPk1TSCBbMV0tPm",
    "1lc3NhZ2VfdHlwZS0+bWVzc2dfdHlwZSAhPSAiQURUIiBvciANCihvZW5fcmVwbHktPkNPTlRST0xfR1JPVVAgWzFdLT5NU0ggW",
    "zFdLT5tZXNzYWdlX3R5cGUtPm1lc3NnX3RyaWdnZXIgbm90IGluDQooIkEwMSIsIkEwNCIpKSkNCglzZXQgb2Vuc3RhdHVzLT5p",
    "Z25vcmUgPSAxDQoJZ28gdG8gZW5kX29mX3NjcmlwdA0KZW5kaWYNCg0Kc2VsZWN0IGludG8gIm5sOiINCglwLnBlcnNvbl9pZA0",
    "KCSxwLmFjdGl2ZV9pbmQNCmZyb20NCglwZXJzb24gcA0KcGxhbiBwDQoJd2hlcmUgcC5wZXJzb25faWQgPSBvZW5fcmVwbHktPm",
    "Nlcm5lci0+cGVyc29uX2luZm8tPnBlcnNvbiBbMV0tPnBlcnNvbl9pZCANCgkJYW5kIHAuYWN0aXZlX2luZCA9IDENCndpdGggY",
    "291bnRlcg0KDQppZiAoY3VycXVhbCBub3QgPiAwKQ0KCWV4ZWN1dGUgb2VuY3BtX21zZ2xvZyhidWlsZDIoIi0tLS0tPkluYWN0",
    "aXZlIFBlcnNvbiEgSWdub3JpbmchIixjaGFyKDApKSkNCglzZXQgb2Vuc3RhdHVzLT5pZ25vcmUgPSAxDQoJZ28gdG8gZW5kX29",
    "mX3NjcmlwdAkNCmVuZGlmDQoNCnJlY29yZCByZXF1ZXN0DQooDQoJMSBsZWdhY3lfdXRpbGl0eV9waWQJCQkJCQk9IGk0DQoJMS",
    "B1cGRhdGVfdWRmCQkJCQkJCQk9IGk0DQoJMSBsZWdhY3lfYWR0X2ludGVmYWNlWypdDQoJCTIgcHJvY19uYW1lIAkJCQkJCQk9I",
    "HZjDQoJMSBwZXJzb25faWQJCQkJCQkJCQk9IGY4DQoJMSBlbmNudHJfaWQJCQkJCQkJCQk9IGY4DQoJMSBxdWV1ZV9pZAkJCQkJ",
    "CQkJCT0gZjgNCgkxIHRyaWdnZXJfaWQJCQkJCQkJCT0gZjgNCgkxIHRyYW5zYWN0aW9uX2lkCQkJCQkJCT0gZjgNCgkxIHBtX3R",
    "yYW5zYWN0aW9uCQkJCQkJCT0gdmMNCgkxIGNxbV9yZWZudW0JCQkJCQkJCT0gdmMNCgkxIHVzZXJfaWQJCQkJCQkJCQk9IGY4DQ",
    "oJMSB0aW1lX3NpbmNlX3Byb2Nlc3NlZAkJCQkJCT0gaTQNCgkxIHRyYW5zYWN0aW9uX3Byb2Nlc3NlZAkJCQkJCT0gaTINCgkxI",
    "HRyYW5zYWN0aW9uX2V4aXN0cwkJCQkJCT0gaTINCgkxIHRpbWVfdG9fd2FpdAkJCQkJCQkJPSBpNA0KCTEgbWluX3RpbWVfdG9f",
    "d2FpdAkJCQkJCQk9IGk0DQoJMSB0cmFuc2FjdGlvbl9leGlzdF93YWl0CQkJCQk9IGk0DQoJMSB0cmlnZ2VyX2N3X2F1dG9fZW5",
    "yb2xsbWVudAkJCQk9IGkyIDsgMD1ObywgMT1CYXRjaCBBRFRzIE9ubHksIDI9QWxsIEFEVHMNCgkxIGN3X2Vucm9sbF9pZl9wZX",
    "Jzb25fZXhpc3RzCQkJCT0gaTIgOyA7MSA9IHllcywgb25seSBpZiBvbmUgbWF0Y2ggcmV0dXJuZWQuIDIgPSB5ZXMsIGV2ZW4ga",
    "WYgbXVsdGlwbGUgbWF0Y2hlcyByZXR1cm5lZA0KCTEgY3dfY2hlY2tfcGF0aWVudHNfYWdlCQkJCQkJPSBpMiA7IDE9WWVzDQoJ",
    "MSB0cmlnZ2VyX2F1dG9fcXVlcmllcwkJCQkJCT0gaTIgOyAwPU5vLCAxPVllcw0KCTEgcHJldl9jd19hdXRvX2Vucm9sbF9zdGF",
    "0dXNfY2QJCQkJPSBmOCA7IGxhdGVzdCBzdGF0dXMgY29kZSBmcm9tIHBlcnNvbl9pbmZvDQoJMSBsZF9lbmFibGVkCQkJCQkJCQ",
    "k9IGkyIDsgc2V0IHRvIDEgaWYgaW1wbGVtZW50aW5nIGF1dG8tZW5yb2xsbWVudCBpbiBhIExEDQoJMSB1c2VybmFtZQkJCQkJC",
    "QkJCT0gdmMgOzAwMg0KCTEgdXNlX2FkdF9lbmNudHJfaWQJCQkJCQkJPSBpMiA7IHNldCB0byAxIHRvIG9ubHkgcmVmZXJlbmNl",
    "IGVuY250cl9pZCBmcm9tIEFEVCBhbmQgYnlwYXNzIGxvZ2ljIHRvIGxvb2sgdXAgdmFsaWQgQURULiA7MDAzDQoJMSBtaW5fYWd",
    "lCQkJCQkJCQkJPSBpNCANCgkxIGRpc2FibGVfYWRkcmVzc19ub3JtYWxpemF0aW9uX21hdGNoX2xvZ2ljCT0gaTQgOzAwNSA7c2",
    "V0IHRvIDEgdG8gbm90IGRpc2FibGUgYWRkcmVzcyBub3JtYWxpemF0aW9uIGxvZ2ljDQopDQoNCi8qKioqKioqKioqKioqKioqK",
    "ioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKg0KKioqKioqKioqKioqKioqKioqKioqKioqKioq",
    "KioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqDQoqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKio",
    "qKioqKioqKioqKioqKioqKioqKioqKioqKioNCjsgQ2xpZW50IENvbmZpZ3VyYXRpb24gQmVnaW4NCioqKioqKioqKioqKioqKi",
    "oqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKg0KKioqKioqKioqKioqKioqKioqKioqKioqK",
    "ioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqDQoqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioq",
    "KioqKioqKioqKioqKioqKioqKioqKioqKioqKi8NCjtzZXQgY2xpZW50IHNldHRpbmdzIGhlcmUNCjtjb21tb253ZWxsIGF1dG8",
    "tZW5yb2xsbWVudCByZXF1ZXN0IHNldHRpbmdzDQpzZXQgcmVxdWVzdC0+dHJpZ2dlcl9jd19hdXRvX2Vucm9sbG1lbnQgCQkJCT",
    "0gMA0Kc2V0IHJlcXVlc3QtPmN3X2Vucm9sbF9pZl9wZXJzb25fZXhpc3RzCQkJCQk9IDANCnNldCByZXF1ZXN0LT5jd19jaGVja",
    "19wYXRpZW50c19hZ2UJCQkJCQk9IDENCnNldCByZXF1ZXN0LT5sZF9lbmFibGVkCQkJCQkJCQkJPSAwDQoNCjtTZXQgdGhlIG1p",
    "bmltdW0gYWdlIGZvciBlbnJvbGxtZW50IGlmIHJlcXVlc3QtPmN3X2NoZWNrX3BhdGllbnRzX2FnZSBpcyBzZXQgdG8gMToNCnN",
    "ldCByZXF1ZXN0LT5taW5fYWdlCQkJCQkJCQkJPSAxOSA7MDA0DQoNCjtkZWZpbmUgaW50ZXJmYWNlIHRoYXQgc2hvdWxkIGJlIG",
    "1vbml0b3JlZA0Kc2V0IHN0YXQgPSBhbHRlcmxpc3QgKCByZXF1ZXN0LT5sZWdhY3lfYWR0X2ludGVmYWNlLCAxKQ0Kc2V0IHJlc",
    "XVlc3QtPmxlZ2FjeV9hZHRfaW50ZWZhY2VbMV0tPnByb2NfbmFtZSAJCQk9ICJSRVNPTkFOQ0VfUElYX0FEVF9PVVRfMDEiDQoN",
    "CjthdXRvLXF1ZXJ5IHJlcXVlc3Qgc2V0dGluZ3MNCnNldCByZXF1ZXN0LT50cmlnZ2VyX2F1dG9fcXVlcmllcwkJCQkJCT0gMA0",
    "KDQo7dXNlcm5hbWUgdG8gdXNlIGlmIHVzZXJfaWQgZnJvbSB0cmFuc2FjdGlvbiA9IDANCjtUaGUgbmFtZSBvZiB0aGUgdXNlci",
    "BpcyBzZW50IGluIHRoZSBKV1QgcmVxdWVzdCBzdWJqZWN0SWQNCjt1c2VybmFtZSBtdXN0IGJlIGFjdGl2ZSwgaGF2ZSBhbiBhY",
    "3RpdmVfc3RhdHVzX2NkIG9mIDE4OCwgYW5kIGEgbmFtZQ0KO1Nob3VsZCBvbmx5IGJlIGNoYW5nZWQgaWYgQ0VSTkVSIGFjY291",
    "bnQgaXMgbm90IGFjdGl2ZQ0Kc2V0IHJlcXVlc3QtPnVzZXJuYW1lIAkJCQkJCQkJCT0gIkNFUk5FUiIgOzAwMg0KDQo7aWYgc2V",
    "0IHRvIDAsIGxvZ2ljIHdpbGwgYmUgdXNlZCB0byBmaW5kIHRoZSBtb3N0IHJlY2VudCB2YWxpZCBlbmNudHJfaWQNCjtpZiBzZX",
    "QgdG8gMSwgY3VycmVudCBlbmNudHJfaWQgZnJvbSB0aGUgYWR0IHdpbGwgYmUgdXNlZC4gTG9naWMgd2lsbCBub3QgYmUgdXNlZ",
    "CB0byBsb29rIHVwIHZhbGlkIGVuY291bnRlci4NCnNldCByZXF1ZXN0LT51c2VfYWR0X2VuY250cl9pZAkJCQkJCQk9IDAgOzAw",
    "Mw0KDQo7aWYgc2V0IHRvIDAsIHRoZSBhdXRvLWVucm9sbG1lbnQgcHJvY2VzcyB3aWxsIGF0dGVtcHQgdG8gbm9ybWFsaXplIHR",
    "oZSBzdGF0ZSBhbmQgc3RyZWV0IGFkZHJlc3MNCjt3aGVuIGV2YWx1YXRpbmcgQ29tbW9uV2VsbCBtYXRjaGVzLiBOb3JtYWxpem",
    "VkIHZhbHVlIGlzIG9ubHkgdXNlZCBmb3IgbWF0Y2hpbmcgYW5kIGlzIG5vdCBzZW50DQo7dG8gQ29tbW9uV2VsbC4NCjtpZiBzZ",
    "XQgdG8gMSwgdGhlIGF1dG8tZW5yb2xsbWVudCBwcm9jZXNzIHdpbGwgbm90IGF0dGVtcHQgdG8gbm9ybWFsaXplIHRoZSBzdGF0",
    "ZSBhbmQgc3RyZWV0IGFkZHJlc3MNCjt3aGVuIGV2YWx1YXRpbmcgQ29tbW9uV2VsbCBtYXRjaGVzLg0Kc2V0IHJlcXVlc3QtPmR",
    "pc2FibGVfYWRkcmVzc19ub3JtYWxpemF0aW9uX21hdGNoX2xvZ2ljICA9IDAgOzAwNQ0KDQovKioqKioqKioqKioqKioqKioqKi",
    "oqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioNCioqKioqKioqKioqKioqKioqKioqKioqKioqKioqK",
    "ioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKg0KKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioq",
    "KioqKioqKioqKioqKioqKioqKioqKioqDQo7IENsaWVudCBDb25maWd1cmF0aW9uIEVuZA0KKioqKioqKioqKioqKioqKioqKio",
    "qKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqDQoqKioqKioqKioqKioqKioqKioqKioqKioqKioqKi",
    "oqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioNCioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqK",
    "ioqKioqKioqKioqKioqKioqKioqKioqLw0KDQpleGVjdXRlIG9lbmNwbV9tc2dsb2coQlVJTEQyKCJQcm9jZXNzZWQgU3RhcnQg",
    "YXQ6ICIsIGZvcm1hdChjbnZ0ZGF0ZXRpbWUoY3VyZGF0ZSxjdXJ0aW1lMyksICJERC9NTS9ZWVlZIGhoOm1tOnNzOztRIiksIGN",
    "oYXIoMCkpKQ0KDQpleGVjdXRlIHJlc29uYW5jZV91dGlsaXR5X3ByZyAiTUlORSINCg0KO2lnbm9yZSB0cmFuc2FjdGlvbiBhbm",
    "QgZ28gdG8gZW5kIG9mIHNjcmlwdAkJDQpzZXQgb2Vuc3RhdHVzLT5pZ25vcmUgPSAxDQpnbyB0byBlbmRfb2Zfc2NyaXB0DQoJC",
    "Q0KI2VuZF9vZl9zY3JpcHQNCg0KZXhlY3V0ZSBvZW5jcG1fbXNnbG9nKEJVSUxEMigiUHJvY2Vzc2VkIEVuZCBhdDogIiwgZm9y",
    "bWF0KGNudnRkYXRldGltZShjdXJkYXRlLGN1cnRpbWUzKSwgIkREL01NL1lZWVkgaGg6bW06c3M7O1EiKSwgY2hhcigwKSkpDQo",
    "NCg==")
   SET oenctl_add_script_request->sc_name = resonance_util_mod_obj_name
   SET oenctl_add_script_request->sc_desc = resonance_util_mod_obj_desc
   SET oenctl_add_script_request->sc_type = "ModObj"
   SET oenctl_add_script_request->not_executable = 0
   SET oenctl_add_script_request->read_only = 0
   SET oenctl_add_script_request->sc_body = build2(base_64_decode(resonance_util_mod_obj_base64,"","",
     0,0))
   CALL import_oen_scripts(1)
   CALL include_oen_scripts(oenctl_add_script_request->sc_name)
   RETURN(resonance_util_mod_obj_name)
 END ;Subroutine
 SUBROUTINE start_device_contributor_system_relationships(dummy_var)
   DECLARE targetcontributorsystemcd = f8 WITH noconstant(0.0)
   DECLARE targetorganizationid = f8 WITH noconstant(0.0)
   CALL clear(1,1)
   SET message = nowindow
   CALL text(7,15,"You will be prompted for the target contributor system")
   CALL text(8,15,"and target organization that should be copied.")
   CALL text(9,15,"Press enter to continue:")
   CALL accept(10,15,"A;CU","")
   SET targetcontributorsystemcd = get_contributor_system_cd(communitycontributorsystemdef)
   IF ( NOT (targetcontributorsystemcd > 0.0))
    GO TO new_res_xds_res_imp_auto_menu
   ENDIF
   SET targetorganizationid = get_organization_id(1)
   IF ( NOT (targetorganizationid > 0.0))
    GO TO new_res_xds_res_imp_auto_menu
   ENDIF
   CALL create_device_contributor_system_relationships(targetcontributorsystemcd,targetorganizationid
    )
 END ;Subroutine
 SUBROUTINE (create_device_contributor_system_relationships(device_contributor_system_cd=f8,
  device_organization_id=f8) =c1)
   RECORD current_dev_reltn_for_consys(
     1 event_sets[*]
       2 event_set_cd = f8
     1 filtered_orgs[*]
       2 organization_id = f8
   )
   RECORD filtered_add_dev_reltn_for_consys_request(
     1 qual[*]
       2 device_output_reltn_id = f8
       2 organization_id = f8
       2 event_set_cd = f8
       2 contributor_system_cd = f8
   )
   DECLARE custcdawrappedpdfcd = f8 WITH constant(uar_get_code_by("MEANING",4002390,"PDFCDA"))
   DECLARE custenvelopeprocesscd = f8 WITH constant(uar_get_code_by("MEANING",4002587,"XDSPROVIDE"))
   DECLARE devreltnnum = i4 WITH noconstant(0)
   DECLARE orgidnum = i4
   SELECT DISTINCT INTO "nl:"
    dor.device_output_reltn_id, dorr.event_set_cd, xr.parent_entity_id
    FROM device_xref xr,
     device_output_reltn dor,
     device_output_reltn_r dorr
    PLAN (xr
     WHERE xr.parent_entity_id=device_contributor_system_cd
      AND xr.parent_entity_name="CONTRIBUTOR_SYSTEM")
     JOIN (dor
     WHERE dor.device_cd=xr.device_cd
      AND dor.output_content_type_cd=custcdawrappedpdfcd
      AND dor.envelope_process_cd=custenvelopeprocesscd)
     JOIN (dorr
     WHERE dorr.device_output_reltn_id=dor.device_output_reltn_id
      AND dorr.organization_id=device_organization_id)
    DETAIL
     devreltnnum += 1, stat = alterlist(current_dev_reltn_for_consys->event_sets,devreltnnum),
     current_dev_reltn_for_consys->event_sets[devreltnnum].event_set_cd = dorr.event_set_cd
    WITH nocounter
   ;end select
   IF ( NOT (size(current_dev_reltn_for_consys->event_sets,5) > 0))
    CALL clear(1,1)
    SET message = nowindow
    CALL text(7,15,"No event_sets found for specified organization!")
    CALL text(8,15,"Press enter to exit")
    CALL accept(9,15,"A;CU","")
    GO TO new_res_xds_res_imp_auto_menu
   ENDIF
   SET devreltnnum = 0
   SELECT DISTINCT INTO "nl:"
    dor.device_output_reltn_id, dorr.organization_id, dorr.event_set_cd,
    xr.parent_entity_id
    FROM device_xref xr,
     device_output_reltn dor,
     device_output_reltn_r dorr
    PLAN (xr
     WHERE xr.parent_entity_id=device_contributor_system_cd
      AND xr.parent_entity_name="CONTRIBUTOR_SYSTEM")
     JOIN (dor
     WHERE dor.device_cd=xr.device_cd
      AND dor.output_content_type_cd=custcdawrappedpdfcd
      AND dor.envelope_process_cd=custenvelopeprocesscd)
     JOIN (dorr
     WHERE dorr.device_output_reltn_id=dor.device_output_reltn_id)
    DETAIL
     devreltnnum += 1, stat = alterlist(current_dev_reltn_for_consys->filtered_orgs,devreltnnum),
     current_dev_reltn_for_consys->filtered_orgs[devreltnnum].organization_id = dorr.organization_id
    WITH nocounter
   ;end select
   SET devreltnnum = 0
   SELECT DISTINCT INTO "nl:"
    so.entity_id
    FROM si_oid so
    PLAN (so
     WHERE so.entity_name="ORGANIZATION"
      AND so.active_ind=1
      AND so.end_effective_dt_tm >= cnvtdatetime(curdate,curtime)
      AND  NOT (expand(orgidnum,1,size(current_dev_reltn_for_consys->filtered_orgs,5),so.entity_id,
      current_dev_reltn_for_consys->filtered_orgs[orgidnum].organization_id)))
    DETAIL
     FOR (eventsetcnt = 1 TO size(current_dev_reltn_for_consys->event_sets,5))
       devreltnnum += 1, stat = alterlist(filtered_add_dev_reltn_for_consys_request->qual,devreltnnum
        ), filtered_add_dev_reltn_for_consys_request->qual[devreltnnum].device_output_reltn_id = 0.00,
       filtered_add_dev_reltn_for_consys_request->qual[devreltnnum].organization_id = so.entity_id,
       filtered_add_dev_reltn_for_consys_request->qual[devreltnnum].event_set_cd =
       current_dev_reltn_for_consys->event_sets[eventsetcnt].event_set_cd,
       filtered_add_dev_reltn_for_consys_request->qual[devreltnnum].contributor_system_cd =
       device_contributor_system_cd
     ENDFOR
    WITH nocounter
   ;end select
   IF (size(filtered_add_dev_reltn_for_consys_request->qual,5) > 0)
    CALL echo("The following Organizations/event sets will be configured:")
    FOR (echoadddev = 1 TO size(filtered_add_dev_reltn_for_consys_request->qual,5))
      CALL echo(build2("ORG_ID: ",filtered_add_dev_reltn_for_consys_request->qual[echoadddev].
        organization_id,"   EVENT_SET_CD: ",filtered_add_dev_reltn_for_consys_request->qual[
        echoadddev].event_set_cd))
    ENDFOR
    CALL clear(1,1)
    CALL text(7,15,"Scroll up to view the rows that will be added. Continue? (Y/N)")
    CALL accept(8,15,"A;CU","Y")
    IF (cnvtupper(trim(curaccept))="Y")
     EXECUTE sim_add_dev_reltn_for_consys  WITH replace("REQUEST",
      "FILTERED_ADD_DEV_RELTN_FOR_CONSYS_REQUEST")
     COMMIT
     CALL clear(1,1)
     SET message = nowindow
     CALL text(7,15,"Contributor System / Organization / Event_Set mapping completed!")
     CALL text(8,15,"Press enter to exit")
     CALL accept(9,15,"A;CU","")
     GO TO new_res_xds_res_imp_auto_menu
    ELSE
     CALL clear(1,1)
     SET message = nowindow
     CALL text(7,15,"Not configuring!")
     CALL text(8,15,"Press enter to exit")
     CALL accept(9,15,"A;CU","")
     GO TO new_res_xds_res_imp_auto_menu
    ENDIF
   ELSE
    CALL clear(1,1)
    SET message = nowindow
    CALL text(7,15,
     "Did not find any organizations (with OIDs) that have not already been configured.")
    CALL text(8,15,"Press enter to exit")
    CALL accept(9,15,"A;CU","")
    GO TO new_res_xds_res_imp_auto_menu
   ENDIF
 END ;Subroutine
END GO
