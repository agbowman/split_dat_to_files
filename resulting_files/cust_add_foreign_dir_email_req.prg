CREATE PROGRAM cust_add_foreign_dir_email_req
 SET message = noinformation
 DECLARE revision_nbr = i4 WITH protect, constant(1)
 DECLARE active_ind = i2 WITH protect, constant(1)
 DECLARE updt_id = f8 WITH protect, noconstant(reqinfo->updt_id)
 DECLARE updt_task = i4 WITH protect, constant(3202004)
 DECLARE updt_applctx = f8 WITH protect, constant(reqinfo->updt_applctx)
 DECLARE updt_cnt = i4 WITH protect, constant(0)
 DECLARE updt_dt_tm = dq8 WITH protect, constant(sysdate)
 DECLARE header = vc
 SET header = build("Logical Domain","|","Parent Organization Name","|","Organization Name",
  "|","Organization Mailing Address","|","Organization Billing Address","|",
  "Organization URL","|","Organization Telephone Number","|","Organization Fax Number",
  "|","Provider NPI","|","Provider Position/Role","|",
  "Service Email","|","Provider Last Name","|","Provider First Name",
  "|","Provider Middle Name","|","Service Formatted Display Name","|",
  "Provider Date of Birth","|","Provider Gender","|","Provider Suffix",
  "|","Provider Prefix","|","Provider Degree","|",
  "Specialty Name","|","Specialty Telephone Number","|","Specialty Mobile Number",
  "|","Specialty Pager Number","|","Specialty Fax Number","|",
  "Specialty Description","|","Active Indicator","|","Address Type",
  "|","Address Street 1","|","Address Street 2","|",
  "Address Street 3","|","Address Street 4","|","Address City",
  "|","Address State","|","Address Zipcode")
 DECLARE external_secure_email_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",43,
   "EXTSECEMAIL"))
 DECLARE gender_male_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",57,"MALE"))
 DECLARE gender_female_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",57,"FEMALE"))
 DECLARE address_business_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",212,"BUSINESS"))
 DECLARE address_billing_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",212,"BILLING"))
 DECLARE address_mailing_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",212,"MAILING"))
 DECLARE address_professional_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",212,
   "PROFESSIONAL"))
 DECLARE record_list_buffer = i4 WITH protect, constant(20)
 DECLARE file_record_cnt = i4 WITH protect, noconstant(0)
 DECLARE logical_domain_record_cnt = i4 WITH protect, noconstant(0)
 DECLARE provider_record_cnt = i4 WITH protect, noconstant(0)
 DECLARE organization_record_cnt = i4 WITH protect, noconstant(0)
 DECLARE membership_record_cnt = i4 WITH protect, noconstant(0)
 DECLARE member_service_reltn_record_cnt = i4 WITH protect, noconstant(0)
 DECLARE service_record_cnt = i4 WITH protect, noconstant(0)
 DECLARE member_specialty_reltn_record_cnt = i4 WITH protect, noconstant(0)
 DECLARE specialty_record_cnt = i4 WITH protect, noconstant(0)
 DECLARE address_record_cnt = i4 WITH protect, noconstant(0)
 DECLARE data_load_index = i4 WITH protect, noconstant(1)
 DECLARE service_email_missing_msg = vc WITH protect, noconstant("<no_issues>")
 DECLARE valid_us_states_msg = vc
 SET valid_us_states_msg = build(valid_us_states_msg,
  "AL,AK,AS,AZ,AR,CA,CO,CT,DE,DC,FL,GA,GU,HI,ID,IL,IN,IA,",
  "KS,KY,LA,ME,MD,MA,MI,MN,MS,MO,MT,NE,NV,NH,NJ,NM,NY,NC,ND,MP,OH,OK,OR,PA,PR,RI,SC,SD,TN,TX,UM,UT,VT,VA,VI,",
  "WA,WV,WI,WY")
 DECLARE parsed_state = vc WITH protect
 DECLARE map_key = vc
 DECLARE map_value = vc
 DECLARE us_states_map(mode=vc,map_key=vc,map_value=vc) = i4 WITH map = "HASH"
 DECLARE is_valid_state_code(state_code=vc) = i2
 SUBROUTINE is_valid_state_code(state_code)
   RETURN(us_states_map("F",state_code,map_value))
 END ;Subroutine
 DECLARE validate_state(line_number=i4,state_code=vc) = vc
 SUBROUTINE validate_state(line_number,state_code)
   IF (is_empty(state_code))
    RETURN(state_code)
   ENDIF
   SET state_code_uppr = cnvtupper(state_code)
   IF (is_valid_state_code(state_code_uppr))
    RETURN(state_code_uppr)
   ENDIF
   CALL echo(build("Failed to parse the data load file [direct_external_upload.txt] at=[",line_number,
     "] with state code=[",state_code,"]"))
   CALL echo(build("Valid state codes are=[",valid_us_states_msg,"]"))
   ROLLBACK
   GO TO exit_script
 END ;Subroutine
 DECLARE add_to_map(state_code=vc,state_name=vc) = null
 SUBROUTINE add_to_map(state_code,state_name)
   SET stat = us_states_map("A",cnvtupper(state_code),cnvtupper(state_name))
 END ;Subroutine
 DECLARE populate_us_map(null) = null
 SUBROUTINE populate_us_map(null)
   CALL add_to_map("AL","Alabama")
   CALL add_to_map("AK","Alaska")
   CALL add_to_map("AS","American Samoa")
   CALL add_to_map("AZ","Arizona")
   CALL add_to_map("AR","Arkansas")
   CALL add_to_map("CA","California")
   CALL add_to_map("CO","Colorado")
   CALL add_to_map("CT","Connecticut")
   CALL add_to_map("DE","Delaware")
   CALL add_to_map("DC","District of Columbia")
   CALL add_to_map("FL","Florida")
   CALL add_to_map("GA","Georgia")
   CALL add_to_map("GU","Guam")
   CALL add_to_map("HI","Hawaii")
   CALL add_to_map("ID","Idaho")
   CALL add_to_map("IL","Illinois")
   CALL add_to_map("IN","Indiana")
   CALL add_to_map("IA","Iowa")
   CALL add_to_map("KS","Kansas")
   CALL add_to_map("KY","Kentucky")
   CALL add_to_map("LA","Louisiana")
   CALL add_to_map("ME","Maine")
   CALL add_to_map("MD","Maryland")
   CALL add_to_map("MA","Massachusetts")
   CALL add_to_map("MI","Michigan")
   CALL add_to_map("MN","Minnesota")
   CALL add_to_map("MS","Mississippi")
   CALL add_to_map("MO","Missouri")
   CALL add_to_map("MT","Montana")
   CALL add_to_map("NE","Nebraska")
   CALL add_to_map("NV","Nevada")
   CALL add_to_map("NH","New Hampshire")
   CALL add_to_map("NJ","New Jersey")
   CALL add_to_map("NM","New Mexico")
   CALL add_to_map("NY","New York")
   CALL add_to_map("NC","North Carolina")
   CALL add_to_map("ND","North Dakota")
   CALL add_to_map("MP","Northern Mariana Islands")
   CALL add_to_map("OH","Ohio")
   CALL add_to_map("OK","Oklahoma")
   CALL add_to_map("OR","Oregon")
   CALL add_to_map("PA","Pennsylvania")
   CALL add_to_map("PR","Puerto Rico")
   CALL add_to_map("RI","Rhode Island")
   CALL add_to_map("SC","South Carolina")
   CALL add_to_map("SD","South Dakota")
   CALL add_to_map("TN","Tennessee")
   CALL add_to_map("TX","Texas")
   CALL add_to_map("UM","United States Minor Outlying Islands")
   CALL add_to_map("UT","Utah")
   CALL add_to_map("VT","Vermont")
   CALL add_to_map("VA","Virginia")
   CALL add_to_map("VI","Virgin Islands, U.S.")
   CALL add_to_map("WA","Washington")
   CALL add_to_map("WV","West Virginia")
   CALL add_to_map("WI","Wisconsin")
   CALL add_to_map("WY","Wyoming")
 END ;Subroutine
 DECLARE detect_error(null) = null
 SUBROUTINE detect_error(null)
   DECLARE error_msg = vc WITH protect
   DECLARE error_code = i4 WITH protect, noconstant(0)
   SET error_code = error(error_msg,0)
   IF (error_code != 0)
    CALL echo(build("Error code: [",error_code,"]; Reverting changes..."))
    CALL echo(error_msg)
    ROLLBACK
    GO TO exit_script
   ENDIF
 END ;Subroutine
 DECLARE generate_identifier(null) = f8
 SUBROUTINE generate_identifier(null)
   DECLARE identifier = f8 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    value = seq(reference_seq,nextval)
    FROM dual
    DETAIL
     identifier = value
    WITH format, nocounter
   ;end select
   RETURN(identifier)
 END ;Subroutine
 FREE RECORD data_load
 RECORD data_load(
   1 row[*]
     2 logical_domain_id = f8
     2 parent_organization = vc
     2 organization_name = vc
     2 org_mailing_address = vc
     2 org_billing_address = vc
     2 org_url = vc
     2 org_telephone_number = vc
     2 org_fax_number = vc
     2 provider_npi = vc
     2 provider_position = vc
     2 service_email = vc
     2 provider_last_name = vc
     2 provider_first_name = vc
     2 provider_middle_name = vc
     2 service_formatted_display_name = vc
     2 provider_date_of_birth = vc
     2 provider_gender = vc
     2 provider_suffix = vc
     2 provider_prefix = vc
     2 provider_degree = vc
     2 specialty_name = vc
     2 specialty_telephone_number = vc
     2 specialty_mobile_number = vc
     2 specialty_pager_number = vc
     2 specialty_fax_number = vc
     2 specialty_description = vc
     2 address_type = vc
     2 address_street1 = vc
     2 address_street2 = vc
     2 address_street3 = vc
     2 address_street4 = vc
     2 address_city = vc
     2 address_state = vc
     2 address_zipcode = vc
 ) WITH protect
 DECLARE get_next_piece(line_number=i4,line=vc,index=i4) = vc
 SUBROUTINE get_next_piece(line_number,line,index)
   DECLARE returnval = vc WITH protect
   DECLARE header_name = vc WITH protect
   SET header_name = piece(header,"|",index,"<column_name_unspecified>")
   SET returnval = piece(line,"|",index,"<no_data>")
   IF (returnval="<no_data>"
    AND header_name != "<column_name_unspecified>")
    CALL echo(build("Failed to parse the data load file [direct_external_upload] at =[",line_number,
      "] on column[",index,"]=[",
      header_name,"] for line=[",line,"]"))
    GO TO exit_script
   ENDIF
   RETURN(trim(returnval))
 END ;Subroutine
 DECLARE is_empty(text=vc) = i2
 SUBROUTINE is_empty(text)
  IF (textlen(trim(text))=0)
   RETURN(1)
  ENDIF
  RETURN(0)
 END ;Subroutine
 DECLARE is_blank_line(line=vc) = i2
 SUBROUTINE is_blank_line(line)
   RETURN(is_empty(replace(line,"|","")))
 END ;Subroutine
 DECLARE parse_data_load(direct_load_file=vc) = null
 SUBROUTINE parse_data_load(direct_load_file)
   CALL echo(build("Parsing data load file [",direct_load_file,"]..."))
   FREE SET files_loc
   SET logical files_loc value(direct_load_file)
   FREE DEFINE rtl2
   DEFINE rtl2 "files_loc"
   SELECT INTO "nl:"
    line = trim(r.line)
    FROM rtl2t r
    DETAIL
     IF (is_blank_line(line)=0
      AND cnvtupper(substring(1,14,line)) != "LOGICAL DOMAIN"
      AND ((size(trim(piece(line,"|",27,"1")))=0) OR (cnvtint(trim(piece(line,"|",27,"1")))=1)) )
      file_record_cnt = (file_record_cnt+ 1)
      IF (mod(file_record_cnt,record_list_buffer)=1)
       stat = alterlist(data_load->row,((file_record_cnt+ record_list_buffer) - 1))
      ENDIF
      data_load->row[file_record_cnt].logical_domain_id = cnvtreal(trim(piece(line,"|",
         data_load_index,"0"))), data_load_index = (data_load_index+ 1), data_load->row[
      file_record_cnt].parent_organization = get_next_piece(file_record_cnt,line,data_load_index),
      data_load_index = (data_load_index+ 1), data_load->row[file_record_cnt].organization_name =
      get_next_piece(file_record_cnt,line,data_load_index), data_load_index = (data_load_index+ 1),
      data_load->row[file_record_cnt].org_mailing_address = get_next_piece(file_record_cnt,line,
       data_load_index), data_load_index = (data_load_index+ 1), data_load->row[file_record_cnt].
      org_billing_address = get_next_piece(file_record_cnt,line,data_load_index),
      data_load_index = (data_load_index+ 1), data_load->row[file_record_cnt].org_url =
      get_next_piece(file_record_cnt,line,data_load_index), data_load_index = (data_load_index+ 1),
      data_load->row[file_record_cnt].org_telephone_number = get_next_piece(file_record_cnt,line,
       data_load_index), data_load_index = (data_load_index+ 1), data_load->row[file_record_cnt].
      org_fax_number = get_next_piece(file_record_cnt,line,data_load_index),
      data_load_index = (data_load_index+ 1), data_load->row[file_record_cnt].provider_npi =
      get_next_piece(file_record_cnt,line,data_load_index), data_load_index = (data_load_index+ 1),
      data_load->row[file_record_cnt].provider_position = get_next_piece(file_record_cnt,line,
       data_load_index), data_load_index = (data_load_index+ 1), data_load->row[file_record_cnt].
      service_email = get_next_piece(file_record_cnt,line,data_load_index),
      data_load_index = (data_load_index+ 1), data_load->row[file_record_cnt].provider_last_name =
      get_next_piece(file_record_cnt,line,data_load_index), data_load_index = (data_load_index+ 1),
      data_load->row[file_record_cnt].provider_first_name = get_next_piece(file_record_cnt,line,
       data_load_index), data_load_index = (data_load_index+ 1), data_load->row[file_record_cnt].
      provider_middle_name = get_next_piece(file_record_cnt,line,data_load_index),
      data_load_index = (data_load_index+ 1), data_load->row[file_record_cnt].
      service_formatted_display_name = get_next_piece(file_record_cnt,line,data_load_index),
      data_load_index = (data_load_index+ 1),
      data_load->row[file_record_cnt].provider_date_of_birth = get_next_piece(file_record_cnt,line,
       data_load_index), data_load_index = (data_load_index+ 1), data_load->row[file_record_cnt].
      provider_gender = get_next_piece(file_record_cnt,line,data_load_index),
      data_load_index = (data_load_index+ 1), data_load->row[file_record_cnt].provider_suffix =
      get_next_piece(file_record_cnt,line,data_load_index), data_load_index = (data_load_index+ 1),
      data_load->row[file_record_cnt].provider_prefix = get_next_piece(file_record_cnt,line,
       data_load_index), data_load_index = (data_load_index+ 1), data_load->row[file_record_cnt].
      provider_degree = get_next_piece(file_record_cnt,line,data_load_index),
      data_load_index = (data_load_index+ 1), data_load->row[file_record_cnt].specialty_name =
      get_next_piece(file_record_cnt,line,data_load_index), data_load_index = (data_load_index+ 1),
      data_load->row[file_record_cnt].specialty_telephone_number = get_next_piece(file_record_cnt,
       line,data_load_index), data_load_index = (data_load_index+ 1), data_load->row[file_record_cnt]
      .specialty_mobile_number = get_next_piece(file_record_cnt,line,data_load_index),
      data_load_index = (data_load_index+ 1), data_load->row[file_record_cnt].specialty_pager_number
       = get_next_piece(file_record_cnt,line,data_load_index), data_load_index = (data_load_index+ 1),
      data_load->row[file_record_cnt].specialty_fax_number = get_next_piece(file_record_cnt,line,
       data_load_index), data_load_index = (data_load_index+ 1), data_load->row[file_record_cnt].
      specialty_description = get_next_piece(file_record_cnt,line,data_load_index),
      data_load_index = (data_load_index+ 2), data_load->row[file_record_cnt].address_type =
      get_next_piece(file_record_cnt,line,data_load_index), data_load_index = (data_load_index+ 1),
      data_load->row[file_record_cnt].address_street1 = get_next_piece(file_record_cnt,line,
       data_load_index), data_load_index = (data_load_index+ 1), data_load->row[file_record_cnt].
      address_street2 = get_next_piece(file_record_cnt,line,data_load_index),
      data_load_index = (data_load_index+ 1), data_load->row[file_record_cnt].address_street3 =
      get_next_piece(file_record_cnt,line,data_load_index), data_load_index = (data_load_index+ 1),
      data_load->row[file_record_cnt].address_street4 = get_next_piece(file_record_cnt,line,
       data_load_index), data_load_index = (data_load_index+ 1), data_load->row[file_record_cnt].
      address_city = get_next_piece(file_record_cnt,line,data_load_index),
      data_load_index = (data_load_index+ 1), parsed_state = get_next_piece(file_record_cnt,line,
       data_load_index), data_load->row[file_record_cnt].address_state = validate_state(
       file_record_cnt,parsed_state),
      data_load_index = (data_load_index+ 1), data_load->row[file_record_cnt].address_zipcode =
      get_next_piece(file_record_cnt,line,data_load_index)
      IF (is_empty(data_load->row[file_record_cnt].specialty_name)=1
       AND ((size(data_load->row[file_record_cnt].specialty_telephone_number) > 0) OR (((size(
       data_load->row[file_record_cnt].specialty_mobile_number) > 0) OR (((size(data_load->row[
       file_record_cnt].specialty_pager_number) > 0) OR (((size(data_load->row[file_record_cnt].
       specialty_fax_number) > 0) OR (size(data_load->row[file_record_cnt].specialty_description) > 0
      )) )) )) )) )
       data_load->row[file_record_cnt].specialty_name = "Unspecified"
      ENDIF
      IF (is_empty(data_load->row[file_record_cnt].service_email)=1)
       IF (service_email_missing_msg="<no_issues>")
        service_email_missing_msg = build(file_record_cnt)
       ELSE
        service_email_missing_msg = build(",",service_email_missing_msg,file_record_cnt)
       ENDIF
      ENDIF
      data_load_index = 1
     ENDIF
    FOOT REPORT
     stat = alterlist(data_load->row,file_record_cnt)
    WITH nocounter
   ;end select
   IF (size(data_load->row,5)=0)
    CALL echo("")
    CALL echo("No rows found in data load file. Exiting script.")
    ROLLBACK
    GO TO exit_script
   ENDIF
   IF (service_email_missing_msg != "<no_issues>")
    CALL echo("")
    CALL echo(build("Required field Service Email was not provided for rows=[",
      service_email_missing_msg,"].Exiting script."))
    GO TO exit_script
   ENDIF
   CALL echo(build("    Loaded [",file_record_cnt,"] active rows."))
 END ;Subroutine
 FREE RECORD ld_records
 RECORD ld_records(
   1 logical_domain[*]
     2 logical_domain_id = f8
 ) WITH protect
 DECLARE purge_existing_data(null) = null
 SUBROUTINE purge_existing_data(null)
   CALL echo("Reconciling with logical domains...")
   DECLARE index = i4
   SELECT INTO "nl:"
    FROM logical_domain ld
    WHERE expand(index,1,size(data_load->row,5),ld.logical_domain_id,data_load->row[index].
     logical_domain_id)
    DETAIL
     logical_domain_record_cnt = (logical_domain_record_cnt+ 1)
     IF (mod(logical_domain_record_cnt,record_list_buffer)=1)
      stat = alterlist(ld_records->logical_domain,((logical_domain_record_cnt+ record_list_buffer) -
       1))
     ENDIF
     ld_records->logical_domain[logical_domain_record_cnt].logical_domain_id = ld.logical_domain_id
    FOOT REPORT
     stat = alterlist(ld_records->logical_domain,logical_domain_record_cnt)
    WITH expand = 1, nocounter
   ;end select
   CALL echo("Resetting existing data...")
   DELETE  FROM hpd_address ha
    WHERE ha.hpd_address_id != 0
     AND expand(index,1,size(ld_records->logical_domain,5),ha.logical_domain_id,ld_records->
     logical_domain[index].logical_domain_id)
    WITH expand = 0, nocounter
   ;end delete
   CALL detect_error(null)
   DELETE  FROM hpd_member_service_reltn hmsr
    WHERE hmsr.hpd_member_service_reltn_id != 0
     AND hmsr.hpd_membership_id IN (
    (SELECT
     hm.hpd_membership_id
     FROM hpd_membership hm,
      hpd_provider hp
     WHERE expand(index,1,size(ld_records->logical_domain,5),hp.logical_domain_id,ld_records->
      logical_domain[index].logical_domain_id)
      AND hm.hpd_provider_id=hp.hpd_provider_id
     WITH expand = 0))
    WITH nocounter
   ;end delete
   CALL detect_error(null)
   DELETE  FROM hpd_service hs
    WHERE hs.hpd_service_id != 0
     AND  NOT ( EXISTS (
    (SELECT
     "x"
     FROM hpd_member_service_reltn hmsr
     WHERE hmsr.hpd_service_id != 0
      AND hmsr.hpd_service_id=hs.hpd_service_id)))
    WITH nocounter
   ;end delete
   CALL detect_error(null)
   DELETE  FROM hpd_member_specialty_reltn hmsr
    WHERE hmsr.hpd_member_specialty_reltn_id != 0
     AND hmsr.hpd_specialty_id IN (
    (SELECT
     hs.hpd_specialty_id
     FROM hpd_specialty hs
     WHERE expand(index,1,size(ld_records->logical_domain,5),hs.logical_domain_id,ld_records->
      logical_domain[index].logical_domain_id)
     WITH expand = 0))
    WITH nocounter
   ;end delete
   CALL detect_error(null)
   DELETE  FROM hpd_specialty hs
    WHERE hs.hpd_specialty_id != 0
     AND  NOT ( EXISTS (
    (SELECT
     "x"
     FROM hpd_member_specialty_reltn hmsr
     WHERE hmsr.hpd_specialty_id != 0
      AND hmsr.hpd_specialty_id=hs.hpd_specialty_id)))
    WITH nocounter
   ;end delete
   CALL detect_error(null)
   DELETE  FROM hpd_membership hm
    WHERE hm.hpd_membership_id != 0
     AND hm.hpd_provider_id IN (
    (SELECT
     hp.hpd_provider_id
     FROM hpd_provider hp
     WHERE expand(index,1,size(ld_records->logical_domain,5),hp.logical_domain_id,ld_records->
      logical_domain[index].logical_domain_id)
     WITH expand = 0))
    WITH nocounter
   ;end delete
   CALL detect_error(null)
   DELETE  FROM hpd_organization ho
    WHERE ho.hpd_organization_id != 0
     AND expand(index,1,size(ld_records->logical_domain,5),ho.logical_domain_id,ld_records->
     logical_domain[index].logical_domain_id)
    WITH expand = 0, nocounter
   ;end delete
   CALL detect_error(null)
   DELETE  FROM hpd_provider hp
    WHERE hp.hpd_provider_id != 0
     AND expand(index,1,size(ld_records->logical_domain,5),hp.logical_domain_id,ld_records->
     logical_domain[index].logical_domain_id)
    WITH expand = 0, nocounter
   ;end delete
   CALL detect_error(null)
 END ;Subroutine
 DECLARE compare_text(input1=vc,input2=vc) = i2
 SUBROUTINE compare_text(input1,input2)
   IF (cnvtupper(input1)=cnvtupper(input2))
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 FREE RECORD providers
 RECORD providers(
   1 provider[*]
     2 hpd_provider_id = f8
     2 last_name = vc
     2 first_name = vc
     2 middle_name = vc
     2 date_of_birth = vc
     2 gender_cd = f8
     2 internal_prsnl_id = f8
     2 provider_npi = vc
     2 prefix = vc
     2 suffix = vc
     2 logical_domain_id = f8
 ) WITH protect
 DECLARE consolidate_providers(last_name=vc,first_name=vc,middle_name=vc,date_of_birth=vc,gender=vc,
  provider_npi=vc,prefix=vc,suffix=vc,logical_domain_id=f8) = f8
 SUBROUTINE consolidate_providers(last_name,first_name,middle_name,date_of_birth,gender,provider_npi,
  prefix,suffix,logical_domain_id)
   DECLARE gender_cd = f8 WITH protect, noconstant(0)
   IF (((cnvtupper(gender)="M") OR (cnvtupper(gender)="MALE")) )
    SET gender_cd = gender_male_cd
   ELSEIF (((cnvtupper(gender)="F") OR (cnvtupper(gender)="FEMALE")) )
    SET gender_cd = gender_female_cd
   ELSEIF (size(gender) > 0)
    CALL echo(build("Unable to match gender [",gender,"] to a gender code for provider [",last_name,
      ", ",
      first_name,"]. Must be 'M' or 'MALE' for male, or 'F' or 'FEMALE' for female."))
   ENDIF
   DECLARE provider_id = f8 WITH protect, noconstant(0)
   FOR (j = 1 TO provider_record_cnt)
     IF (compare_text(providers->provider[j].last_name,last_name)
      AND compare_text(providers->provider[j].first_name,first_name)
      AND compare_text(providers->provider[j].middle_name,middle_name)
      AND compare_text(providers->provider[j].date_of_birth,date_of_birth)
      AND (providers->provider[j].gender_cd=gender_cd)
      AND compare_text(providers->provider[j].provider_npi,provider_npi)
      AND (providers->provider[j].logical_domain_id=logical_domain_id))
      SET provider_id = providers->provider[j].hpd_provider_id
      SET j = provider_record_cnt
     ENDIF
   ENDFOR
   IF (provider_id=0)
    SET provider_record_cnt = (provider_record_cnt+ 1)
    IF (mod(provider_record_cnt,record_list_buffer)=1)
     SET stat = alterlist(providers->provider,((provider_record_cnt+ record_list_buffer) - 1))
    ENDIF
    SET provider_id = generate_identifier(null)
    SET providers->provider[provider_record_cnt].hpd_provider_id = provider_id
    SET providers->provider[provider_record_cnt].last_name = last_name
    SET providers->provider[provider_record_cnt].first_name = first_name
    SET providers->provider[provider_record_cnt].middle_name = middle_name
    SET providers->provider[provider_record_cnt].date_of_birth = date_of_birth
    SET providers->provider[provider_record_cnt].gender_cd = gender_cd
    SET providers->provider[provider_record_cnt].provider_npi = provider_npi
    SET providers->provider[provider_record_cnt].internal_prsnl_id = populate_internal_prsnl_id(
     provider_npi)
    SET providers->provider[provider_record_cnt].prefix = prefix
    SET providers->provider[provider_record_cnt].suffix = suffix
    SET providers->provider[provider_record_cnt].logical_domain_id = logical_domain_id
   ENDIF
   RETURN(provider_id)
 END ;Subroutine
 DECLARE populate_internal_prsnl_id(provider_npi=vc) = f8
 SUBROUTINE populate_internal_prsnl_id(provider_npi)
   RETURN(0.0)
 END ;Subroutine
 DECLARE validate_provider_searchable(index=i4) = null
 SUBROUTINE validate_provider_searchable(index)
   SET last_name = providers->provider[index].last_name
   SET first_name = providers->provider[index].first_name
   SET middle_name = providers->provider[index].middle_name
   SET date_of_birth = providers->provider[index].date_of_birth
   SET gender_cd = providers->provider[index].gender_cd
   SET provider_npi = providers->provider[index].provider_npi
   SET prefix = providers->provider[index].prefix
   SET suffix = providers->provider[index].suffix
   IF (is_empty(first_name)=1
    AND is_empty(last_name)=1
    AND ((is_empty(middle_name)=0) OR (((is_empty(date_of_birth)=0) OR (((is_empty(provider_npi)=0)
    OR (((is_empty(prefix)=0) OR (((is_empty(suffix)=0) OR (gender_cd > 0)) )) )) )) )) )
    DECLARE provider_diagnostic_text = vc WITH protect, noconstant("")
    SET provider_diagnostic_text = build("Inserted provider [",index,
     "] will not be searchable since it is missing one of [First Name, Last Name]. Invalid provider with data = {"
     )
    SET provider_diagnostic_text = build(provider_diagnostic_text,"last_name [",last_name,"], ",
     "first_name [",
     first_name,"], ","middle_name [",middle_name,"], ",
     "date_of_birth [",date_of_birth,"], ","gender_cd [",gender_cd,
     "], ","provider_npi [",date_of_birth,"], ","prefix [",
     prefix,"], ","suffix [",suffix,"] }")
    CALL echo(provider_diagnostic_text)
   ENDIF
 END ;Subroutine
 DECLARE insert_providers(null) = null
 SUBROUTINE insert_providers(null)
  CALL echo(build("Inserting [",provider_record_cnt,"] Providers..."))
  FOR (j = 1 TO provider_record_cnt)
    INSERT  FROM hpd_provider hp
     SET hp.hpd_provider_id = providers->provider[j].hpd_provider_id, hp.last_name = providers->
      provider[j].last_name, hp.first_name = providers->provider[j].first_name,
      hp.middle_name = providers->provider[j].middle_name, hp.date_of_birth = providers->provider[j].
      date_of_birth, hp.gender_cd = providers->provider[j].gender_cd,
      hp.provider_npi = providers->provider[j].provider_npi, hp.internal_prsnl_id = providers->
      provider[j].internal_prsnl_id, hp.prefix_txt = providers->provider[j].prefix,
      hp.suffix_txt = providers->provider[j].suffix, hp.logical_domain_id = providers->provider[j].
      logical_domain_id, hp.active_ind = active_ind,
      hp.revision_nbr = revision_nbr, hp.updt_applctx = updt_applctx, hp.updt_id = updt_id,
      hp.updt_task = updt_task, hp.updt_cnt = updt_cnt, hp.updt_dt_tm = cnvtdatetime(updt_dt_tm)
     WITH nocounter
    ;end insert
    CALL detect_error(null)
    CALL validate_provider_searchable(j)
  ENDFOR
 END ;Subroutine
 FREE RECORD organizations
 RECORD organizations(
   1 organization[*]
     2 hpd_organization_id = f8
     2 parent_organization_name = vc
     2 parent_hpd_organization_id = f8
     2 organization_name = vc
     2 mailing_address = vc
     2 billing_address = vc
     2 labeled_uri = vc
     2 telephone_number = vc
     2 fax_number = vc
     2 logical_domain_id = f8
 ) WITH protect
 DECLARE consolidate_organizations(parent_organization_name=vc,organization_name=vc,mailing_address=
  vc,billing_address=vc,labeled_uri=vc,
  telephone_number=vc,fax_number=vc,logical_domain_id=f8) = f8
 SUBROUTINE consolidate_organizations(parent_organization_name,organization_name,mailing_address,
  billing_address,labeled_uri,telephone_number,fax_number,logical_domain_id)
   DECLARE organization_id = f8 WITH protect, noconstant(0)
   FOR (j = 1 TO organization_record_cnt)
     IF (compare_text(organizations->organization[j].parent_organization_name,
      parent_organization_name)
      AND compare_text(organizations->organization[j].organization_name,organization_name)
      AND compare_text(organizations->organization[j].mailing_address,mailing_address)
      AND compare_text(organizations->organization[j].billing_address,billing_address)
      AND (organizations->organization[j].logical_domain_id=logical_domain_id))
      SET organization_id = organizations->organization[j].hpd_organization_id
      SET j = organization_record_cnt
     ENDIF
   ENDFOR
   IF (organization_id=0)
    IF (is_empty(parent_organization_name)
     AND is_empty(organization_name)
     AND is_empty(mailing_address)
     AND is_empty(billing_address)
     AND is_empty(labeled_uri)
     AND is_empty(fax_number))
     RETURN(0)
    ENDIF
    SET organization_record_cnt = (organization_record_cnt+ 1)
    IF (mod(organization_record_cnt,record_list_buffer)=1)
     SET stat = alterlist(organizations->organization,((organization_record_cnt+ record_list_buffer)
       - 1))
    ENDIF
    SET organization_id = generate_identifier(null)
    SET organizations->organization[organization_record_cnt].hpd_organization_id = organization_id
    SET organizations->organization[organization_record_cnt].parent_organization_name =
    parent_organization_name
    SET organizations->organization[organization_record_cnt].parent_hpd_organization_id = 0
    SET organizations->organization[organization_record_cnt].organization_name = organization_name
    SET organizations->organization[organization_record_cnt].mailing_address = mailing_address
    SET organizations->organization[organization_record_cnt].billing_address = billing_address
    SET organizations->organization[organization_record_cnt].labeled_uri = labeled_uri
    SET organizations->organization[organization_record_cnt].telephone_number = telephone_number
    SET organizations->organization[organization_record_cnt].fax_number = fax_number
    SET organizations->organization[organization_record_cnt].logical_domain_id = logical_domain_id
   ENDIF
   RETURN(organization_id)
 END ;Subroutine
 DECLARE populate_parent_organization_id(null) = null
 SUBROUTINE populate_parent_organization_id(null)
  DECLARE parent_organization_id = f8 WITH protect, noconstant(0)
  FOR (j = 1 TO organization_record_cnt)
   SET parent_organization_id = 0
   IF ((organizations->organization[j].parent_organization_name != ""))
    FOR (k = 1 TO organization_record_cnt)
      IF (compare_text(organizations->organization[j].parent_organization_name,organizations->
       organization[k].organization_name))
       SET parent_organization_id = organizations->organization[k].hpd_organization_id
       SET k = organization_record_cnt
      ENDIF
    ENDFOR
    IF (parent_organization_id != 0)
     SET organizations->organization[j].parent_hpd_organization_id = parent_organization_id
    ELSE
     CALL echo(build("Unable to find identifier for parent organization [",organizations->
       organization[j].parent_organization_name,"] for organization [",organizations->organization[j]
       .organization_name,"], it will not be linked to the organization hierarchy."))
    ENDIF
   ENDIF
  ENDFOR
 END ;Subroutine
 DECLARE validate_organization_searchable(index=i4) = null
 SUBROUTINE validate_organization_searchable(index)
   SET parent_organization_name = organizations->organization[index].parent_organization_name
   SET organization_name = organizations->organization[index].organization_name
   SET mailing_address = organizations->organization[index].mailing_address
   SET billing_address = organizations->organization[index].billing_address
   SET labeled_uri = organizations->organization[index].labeled_uri
   SET telephone_number = organizations->organization[index].telephone_number
   SET fax_number = organizations->organization[index].fax_number
   IF (is_empty(organization_name)=1
    AND ((is_empty(parent_organization_name)=0) OR (((is_empty(mailing_address)=0) OR (((is_empty(
    billing_address)=0) OR (((is_empty(labeled_uri)=0) OR (((is_empty(telephone_number)=0) OR (
   is_empty(fax_number)=0)) )) )) )) )) )
    DECLARE organization_diagnostic_text = vc WITH protect, noconstant("")
    SET organization_diagnostic_text = build("Inserted organization [",index,
     "] will not be searchable since it is missing Organization Name. Invalid organization with data = {"
     )
    SET organization_diagnostic_text = build(organization_diagnostic_text,
     "parent_organization_name [",parent_organization_name,"], ","mailing_address [",
     mailing_address,"], ","billing_address [",billing_address,"], ",
     "labeled_uri [",labeled_uri,"], ","telephone_number [",telephone_number,
     "], ","fax_number [",fax_number,"] }")
    CALL echo(organization_diagnostic_text)
   ENDIF
 END ;Subroutine
 DECLARE insert_organizations(null) = null
 SUBROUTINE insert_organizations(null)
   CALL echo(build("Inserting [",organization_record_cnt,"] Organizations..."))
   FOR (j = 1 TO organization_record_cnt)
    INSERT  FROM hpd_organization ho
     SET ho.hpd_organization_id = organizations->organization[j].hpd_organization_id, ho
      .parent_hpd_organization_id = 0, ho.organization_name = organizations->organization[j].
      organization_name,
      ho.mailing_address = organizations->organization[j].mailing_address, ho.billing_address =
      organizations->organization[j].billing_address, ho.labeled_uri = organizations->organization[j]
      .labeled_uri,
      ho.telephone_number_txt = organizations->organization[j].telephone_number, ho.fax_number_txt =
      organizations->organization[j].fax_number, ho.logical_domain_id = organizations->organization[j
      ].logical_domain_id,
      ho.active_ind = active_ind, ho.revision_nbr = revision_nbr, ho.updt_applctx = updt_applctx,
      ho.updt_id = updt_id, ho.updt_task = updt_task, ho.updt_cnt = updt_cnt,
      ho.updt_dt_tm = cnvtdatetime(updt_dt_tm)
     WITH nocounter
    ;end insert
    CALL detect_error(null)
   ENDFOR
   FOR (j = 1 TO organization_record_cnt)
     UPDATE  FROM hpd_organization ho
      SET ho.parent_hpd_organization_id = organizations->organization[j].parent_hpd_organization_id,
       ho.updt_applctx = updt_applctx, ho.updt_id = updt_id,
       ho.updt_task = updt_task, ho.updt_cnt = updt_cnt, ho.updt_dt_tm = cnvtdatetime(updt_dt_tm)
      WHERE (ho.hpd_organization_id=organizations->organization[j].hpd_organization_id)
      WITH nocounter
     ;end update
     CALL detect_error(null)
     CALL validate_organization_searchable(j)
   ENDFOR
 END ;Subroutine
 FREE RECORD memberships
 RECORD memberships(
   1 membership[*]
     2 hpd_membership_id = f8
     2 hpd_provider_id = f8
     2 hpd_organization_id = f8
 ) WITH protect
 DECLARE consolidate_memberships(hpd_provider_id=f8,hpd_organization_id=f8) = f8
 SUBROUTINE consolidate_memberships(hpd_provider_id,hpd_organization_id)
   DECLARE membership_id = f8 WITH protect, noconstant(0)
   FOR (j = 1 TO membership_record_cnt)
     IF ((memberships->membership[j].hpd_provider_id=hpd_provider_id)
      AND (memberships->membership[j].hpd_organization_id=hpd_organization_id))
      SET membership_id = memberships->membership[j].hpd_membership_id
      SET j = membership_record_cnt
     ENDIF
   ENDFOR
   IF (membership_id=0)
    SET membership_record_cnt = (membership_record_cnt+ 1)
    IF (mod(membership_record_cnt,record_list_buffer)=1)
     SET stat = alterlist(memberships->membership,((membership_record_cnt+ record_list_buffer) - 1))
    ENDIF
    SET membership_id = generate_identifier(null)
    SET memberships->membership[membership_record_cnt].hpd_membership_id = membership_id
    SET memberships->membership[membership_record_cnt].hpd_provider_id = hpd_provider_id
    SET memberships->membership[membership_record_cnt].hpd_organization_id = hpd_organization_id
   ENDIF
   RETURN(membership_id)
 END ;Subroutine
 DECLARE insert_memberships(null) = null
 SUBROUTINE insert_memberships(null)
  CALL echo(build("Inserting [",membership_record_cnt,"] Memberships..."))
  FOR (j = 1 TO membership_record_cnt)
   INSERT  FROM hpd_membership hm
    SET hm.hpd_membership_id = memberships->membership[j].hpd_membership_id, hm.hpd_provider_id =
     memberships->membership[j].hpd_provider_id, hm.hpd_organization_id = memberships->membership[j].
     hpd_organization_id,
     hm.active_ind = active_ind, hm.revision_nbr = revision_nbr, hm.updt_applctx = updt_applctx,
     hm.updt_id = updt_id, hm.updt_task = updt_task, hm.updt_cnt = updt_cnt,
     hm.updt_dt_tm = cnvtdatetime(updt_dt_tm)
    WITH nocounter
   ;end insert
   CALL detect_error(null)
  ENDFOR
 END ;Subroutine
 FREE RECORD specialties
 RECORD specialties(
   1 specialty[*]
     2 hpd_specialty_id = f8
     2 specialty_name = vc
     2 telephone_number = vc
     2 mobile_number = vc
     2 pager_number = vc
     2 fax_number = vc
     2 description = vc
     2 logical_domain_id = f8
 ) WITH protect
 DECLARE consolidate_specialties(specialty_name=vc,telephone_number=vc,mobile_number=vc,pager_number=
  vc,fax_number=vc,
  description=vc,logical_domain_id=f8) = f8
 SUBROUTINE consolidate_specialties(specialty_name,telephone_number,mobile_number,pager_number,
  fax_number,description,logical_domain_id)
   DECLARE specialty_id = f8 WITH protect, noconstant(0)
   FOR (j = 1 TO specialty_record_cnt)
     IF (compare_text(specialties->specialty[j].specialty_name,specialty_name)
      AND compare_text(specialties->specialty[j].telephone_number,telephone_number)
      AND compare_text(specialties->specialty[j].mobile_number,mobile_number)
      AND compare_text(specialties->specialty[j].pager_number,pager_number)
      AND compare_text(specialties->specialty[j].fax_number,fax_number)
      AND (specialties->specialty[j].logical_domain_id=logical_domain_id))
      SET specialty_id = specialties->specialty[j].hpd_specialty_id
      SET j = specialty_record_cnt
     ENDIF
   ENDFOR
   IF (specialty_id=0)
    SET specialty_record_cnt = (specialty_record_cnt+ 1)
    IF (mod(specialty_record_cnt,record_list_buffer)=1)
     SET stat = alterlist(specialties->specialty,((specialty_record_cnt+ record_list_buffer) - 1))
    ENDIF
    SET specialty_id = generate_identifier(null)
    SET specialties->specialty[specialty_record_cnt].hpd_specialty_id = specialty_id
    SET specialties->specialty[specialty_record_cnt].specialty_name = specialty_name
    SET specialties->specialty[specialty_record_cnt].telephone_number = telephone_number
    SET specialties->specialty[specialty_record_cnt].mobile_number = mobile_number
    SET specialties->specialty[specialty_record_cnt].pager_number = pager_number
    SET specialties->specialty[specialty_record_cnt].fax_number = fax_number
    SET specialties->specialty[specialty_record_cnt].description = description
    SET specialties->specialty[specialty_record_cnt].logical_domain_id = logical_domain_id
   ENDIF
   RETURN(specialty_id)
 END ;Subroutine
 DECLARE validate_specialty_searchable(index=i4) = null
 SUBROUTINE validate_specialty_searchable(index)
   SET specialty_name = specialties->specialty[index].specialty_name
   SET telephone_number = specialties->specialty[index].telephone_number
   SET mobile_number = specialties->specialty[index].mobile_number
   SET pager_number = specialties->specialty[index].pager_number
   SET fax_number = specialties->specialty[index].fax_number
   SET description = specialties->specialty[index].description
   IF (is_empty(specialty_name)=1
    AND ((is_empty(telephone_number)=0) OR (((is_empty(mobile_number)=0) OR (((is_empty(pager_number)
   =0) OR (((is_empty(fax_number)=0) OR (is_empty(description)=0)) )) )) )) )
    DECLARE specialty_diagnostic_text = vc WITH protect, noconstant("")
    SET specialty_diagnostic_text = build("Inserted specialty [",index,
     "] will not be searchable since it is missing Specialty Name. Invalid specialty with data = {")
    SET specialty_diagnostic_text = build(specialty_diagnostic_text,"telephone_number [",
     telephone_number,"], ","mobile_number [",
     mobile_number,"], ","pager_number [",pager_number,"], ",
     "fax_number [",fax_number,"], ","description [",description,
     "] }")
    CALL echo(specialty_diagnostic_text)
   ENDIF
 END ;Subroutine
 DECLARE insert_specialties(null) = null
 SUBROUTINE insert_specialties(null)
  CALL echo(build("Inserting [",specialty_record_cnt,"] Specialties..."))
  FOR (j = 1 TO specialty_record_cnt)
    INSERT  FROM hpd_specialty hs
     SET hs.hpd_specialty_id = specialties->specialty[j].hpd_specialty_id, hs.specialty_name =
      specialties->specialty[j].specialty_name, hs.telephone_number_txt = specialties->specialty[j].
      telephone_number,
      hs.mobile_number_txt = specialties->specialty[j].mobile_number, hs.pager_number_txt =
      specialties->specialty[j].pager_number, hs.fax_number_txt = specialties->specialty[j].
      fax_number,
      hs.description = specialties->specialty[j].description, hs.logical_domain_id = specialties->
      specialty[j].logical_domain_id, hs.active_ind = active_ind,
      hs.revision_nbr = revision_nbr, hs.updt_applctx = updt_applctx, hs.updt_id = updt_id,
      hs.updt_task = updt_task, hs.updt_cnt = updt_cnt, hs.updt_dt_tm = cnvtdatetime(updt_dt_tm)
     WITH nocounter
    ;end insert
    CALL detect_error(null)
    CALL validate_specialty_searchable(j)
  ENDFOR
 END ;Subroutine
 FREE RECORD member_specialty_reltns
 RECORD member_specialty_reltns(
   1 member_specialty_reltn[*]
     2 hpd_member_specialty_reltn_id = f8
     2 hpd_membership_id = f8
     2 hpd_specialty_id = f8
 ) WITH protect
 DECLARE consolidate_member_specialty_reltns(hpd_membership_id=f8,hpd_specialty_id=f8) = f8
 SUBROUTINE consolidate_member_specialty_reltns(hpd_membership_id,hpd_specialty_id)
   DECLARE member_specialty_id = f8 WITH protect, noconstant(0)
   FOR (j = 1 TO member_specialty_reltn_record_cnt)
     IF ((member_specialty_reltns->member_specialty_reltn[j].hpd_membership_id=hpd_membership_id)
      AND (member_specialty_reltns->member_specialty_reltn[j].hpd_specialty_id=hpd_specialty_id))
      SET member_specialty_id = member_specialty_reltns->member_specialty_reltn[j].
      hpd_member_specialty_reltn_id
      SET j = member_specialty_reltn_record_cnt
     ENDIF
   ENDFOR
   IF (member_specialty_id=0)
    SET member_specialty_reltn_record_cnt = (member_specialty_reltn_record_cnt+ 1)
    IF (mod(member_specialty_reltn_record_cnt,record_list_buffer)=1)
     SET stat = alterlist(member_specialty_reltns->member_specialty_reltn,((
      member_specialty_reltn_record_cnt+ record_list_buffer) - 1))
    ENDIF
    SET member_specialty_id = generate_identifier(null)
    SET member_specialty_reltns->member_specialty_reltn[member_specialty_reltn_record_cnt].
    hpd_member_specialty_reltn_id = member_specialty_id
    SET member_specialty_reltns->member_specialty_reltn[member_specialty_reltn_record_cnt].
    hpd_membership_id = hpd_membership_id
    SET member_specialty_reltns->member_specialty_reltn[member_specialty_reltn_record_cnt].
    hpd_specialty_id = hpd_specialty_id
   ENDIF
   RETURN(member_specialty_id)
 END ;Subroutine
 DECLARE insert_member_specialty_reltns(null) = null
 SUBROUTINE insert_member_specialty_reltns(null)
  CALL echo(build("Inserting [",member_specialty_reltn_record_cnt,
    "] Membership-Specialty relationships..."))
  FOR (j = 1 TO member_specialty_reltn_record_cnt)
   INSERT  FROM hpd_member_specialty_reltn hmsr
    SET hmsr.hpd_member_specialty_reltn_id = member_specialty_reltns->member_specialty_reltn[j].
     hpd_member_specialty_reltn_id, hmsr.hpd_membership_id = member_specialty_reltns->
     member_specialty_reltn[j].hpd_membership_id, hmsr.hpd_specialty_id = member_specialty_reltns->
     member_specialty_reltn[j].hpd_specialty_id,
     hmsr.active_ind = active_ind, hmsr.updt_applctx = updt_applctx, hmsr.updt_id = updt_id,
     hmsr.updt_task = updt_task, hmsr.updt_cnt = updt_cnt, hmsr.updt_dt_tm = cnvtdatetime(updt_dt_tm)
    WITH nocounter
   ;end insert
   CALL detect_error(null)
  ENDFOR
 END ;Subroutine
 FREE RECORD addresses
 RECORD addresses(
   1 address[*]
     2 hpd_address_id = f8
     2 hpd_organization_id = f8
     2 address_type_cd = f8
     2 street_address1 = vc
     2 street_address2 = vc
     2 street_address3 = vc
     2 street_address4 = vc
     2 city_name = vc
     2 state_name = vc
     2 zipcode = vc
     2 logical_domain_id = f8
 ) WITH protect
 DECLARE consolidate_addresses(hpd_organization_id=f8,type=vc,street1=vc,street2=vc,street3=vc,
  street4=vc,city_name=vc,state_name=vc,zipcode=vc,logical_domain_id=f8) = f8
 SUBROUTINE consolidate_addresses(hpd_organization_id,type,street1,street2,street3,street4,city_name,
  state,zipcode,logical_domain_id)
   DECLARE address_type_cd = f8 WITH protect, noconstant(0)
   CASE (cnvtupper(type))
    OF "BUSINESS":
     SET address_type_cd = address_business_cd
    OF "BILLING":
     SET address_type_cd = address_billing_cd
    OF "MAILING":
     SET address_type_cd = address_mailing_cd
    OF "PROFESSIONAL":
     SET address_type_cd = address_professional_cd
   ENDCASE
   DECLARE address_id = f8 WITH protect, noconstant(0)
   FOR (j = 1 TO address_record_cnt)
     IF ((addresses->address[j].hpd_organization_id=hpd_organization_id)
      AND (addresses->address[j].address_type_cd=address_type_cd)
      AND compare_text(addresses->address[j].street_address1,street1)
      AND compare_text(addresses->address[j].street_address2,street2)
      AND compare_text(addresses->address[j].street_address3,street3)
      AND compare_text(addresses->address[j].street_address4,street4)
      AND compare_text(addresses->address[j].city_name,city_name)
      AND compare_text(addresses->address[j].state_name,state)
      AND compare_text(addresses->address[j].zipcode,zipcode)
      AND (addresses->address[j].logical_domain_id=logical_domain_id))
      SET address_id = addresses->address[j].hpd_address_id
      SET j = address_record_cnt
     ENDIF
   ENDFOR
   IF (address_id=0)
    SET address_record_cnt = (address_record_cnt+ 1)
    IF (mod(address_record_cnt,record_list_buffer)=1)
     SET stat = alterlist(addresses->address,((address_record_cnt+ record_list_buffer) - 1))
    ENDIF
    SET address_id = generate_identifier(null)
    SET addresses->address[address_record_cnt].hpd_address_id = address_id
    SET addresses->address[address_record_cnt].hpd_organization_id = hpd_organization_id
    SET addresses->address[address_record_cnt].address_type_cd = address_type_cd
    SET addresses->address[address_record_cnt].street_address1 = street1
    SET addresses->address[address_record_cnt].street_address2 = street2
    SET addresses->address[address_record_cnt].street_address3 = street3
    SET addresses->address[address_record_cnt].street_address4 = street4
    SET addresses->address[address_record_cnt].city_name = city_name
    SET addresses->address[address_record_cnt].state_name = state
    SET addresses->address[address_record_cnt].zipcode = zipcode
    SET addresses->address[address_record_cnt].logical_domain_id = logical_domain_id
   ENDIF
   RETURN(address_id)
 END ;Subroutine
 DECLARE validate_address_searchable(index=i4) = null
 SUBROUTINE validate_address_searchable(index)
   SET address_type_cd = addresses->address[index].address_type_cd
   SET street1 = addresses->address[index].street_address1
   SET street2 = addresses->address[index].street_address2
   SET street3 = addresses->address[index].street_address3
   SET street4 = addresses->address[index].street_address4
   SET city_name = addresses->address[index].city_name
   SET state_name = addresses->address[index].state_name
   SET zipcode = addresses->address[index].zipcode
   IF (is_empty(city_name)=1
    AND is_empty(state_name)=1
    AND is_empty(zipcode)=1
    AND ((is_empty(street1)=0) OR (((is_empty(street2)=0) OR (((is_empty(street3)=0) OR (((is_empty(
    street4)=0) OR (address_type_cd > 0)) )) )) )) )
    DECLARE address_diagnostic_text = vc WITH protect, noconstant("")
    SET address_diagnostic_text = build("Inserted address [",index,
     "] will not be searchable since it is missing one of [City, State, Zipcode]. Invalid address with data = {"
     )
    SET address_diagnostic_text = build(address_diagnostic_text,"address_type_cd [",address_type_cd,
     "], ","street_address1 [",
     street1,"], ","street_address2 [",street2,"], ",
     "street_address3 [",street3,"], ","street_address4 [",street4,
     "], ","city_name [",city_name,"], ","state [",
     state_name,"], ","zipcode [",zipcode,"] }")
    CALL echo(address_diagnostic_text)
   ENDIF
 END ;Subroutine
 DECLARE insert_addresses(null) = null
 SUBROUTINE insert_addresses(null)
  CALL echo(build("Inserting [",address_record_cnt,"] Addresses..."))
  FOR (j = 1 TO address_record_cnt)
    INSERT  FROM hpd_address ha
     SET ha.hpd_address_id = addresses->address[j].hpd_address_id, ha.hpd_organization_id = addresses
      ->address[j].hpd_organization_id, ha.address_type_cd = addresses->address[j].address_type_cd,
      ha.street_address1 = addresses->address[j].street_address1, ha.street_address2 = addresses->
      address[j].street_address2, ha.street_address3 = addresses->address[j].street_address3,
      ha.street_address4 = addresses->address[j].street_address4, ha.city_name = addresses->address[j
      ].city_name, ha.state_name = addresses->address[j].state_name,
      ha.zipcode_txt = addresses->address[j].zipcode, ha.revision_nbr = revision_nbr, ha.active_ind
       = active_ind,
      ha.logical_domain_id = addresses->address[j].logical_domain_id, ha.updt_id = updt_id, ha
      .updt_dt_tm = cnvtdatetime(updt_dt_tm),
      ha.updt_task = updt_task, ha.updt_applctx = updt_applctx, ha.updt_cnt = updt_cnt
     WITH nocounter
    ;end insert
    CALL detect_error(null)
    CALL validate_address_searchable(j)
  ENDFOR
 END ;Subroutine
 FREE RECORD services
 RECORD services(
   1 service[*]
     2 hpd_service_id = f8
     2 service_email_address = vc
     2 formatted_display_name = vc
     2 email_type_cd = f8
 ) WITH protect
 DECLARE consolidate_services(service_email_address=vc,formatted_display_name=vc,email_type_cd=f8) =
 f8
 SUBROUTINE consolidate_services(service_email_address,formatted_display_name,email_type_cd)
   DECLARE service_id = f8 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM hpd_service hs
    WHERE hs.service_email_address=service_email_address
    DETAIL
     service_id = hs.hpd_service_id
    WITH nocounter
   ;end select
   IF (service_id=0)
    FOR (j = 1 TO service_record_cnt)
      IF (compare_text(services->service[j].service_email_address,service_email_address))
       SET service_id = services->service[j].hpd_service_id
       SET j = service_record_cnt
      ENDIF
    ENDFOR
    IF (service_id=0)
     SET service_record_cnt = (service_record_cnt+ 1)
     IF (mod(service_record_cnt,record_list_buffer)=1)
      SET stat = alterlist(services->service,((service_record_cnt+ record_list_buffer) - 1))
     ENDIF
     SET service_id = generate_identifier(null)
     SET services->service[service_record_cnt].hpd_service_id = service_id
     SET services->service[service_record_cnt].service_email_address = service_email_address
     SET services->service[service_record_cnt].formatted_display_name = formatted_display_name
     SET services->service[service_record_cnt].email_type_cd = email_type_cd
    ENDIF
   ELSE
    CALL echo(build("Found match to email [",service_email_address,
      "] from existing records. Using identifier:",service_id))
   ENDIF
   RETURN(service_id)
 END ;Subroutine
 DECLARE insert_services(null) = null
 SUBROUTINE insert_services(null)
  CALL echo(build("Inserting [",service_record_cnt,"] Services..."))
  FOR (j = 1 TO service_record_cnt)
   INSERT  FROM hpd_service hs
    SET hs.hpd_service_id = services->service[j].hpd_service_id, hs.service_email_address = services
     ->service[j].service_email_address, hs.formatted_display_name = services->service[j].
     formatted_display_name,
     hs.email_type_cd = services->service[j].email_type_cd, hs.active_ind = active_ind, hs
     .revision_nbr = revision_nbr,
     hs.updt_applctx = updt_applctx, hs.updt_id = updt_id, hs.updt_task = updt_task,
     hs.updt_cnt = updt_cnt, hs.updt_dt_tm = cnvtdatetime(updt_dt_tm)
    WITH nocounter
   ;end insert
   CALL detect_error(null)
  ENDFOR
 END ;Subroutine
 FREE RECORD member_service_reltns
 RECORD member_service_reltns(
   1 member_service_reltn[*]
     2 hpd_member_service_reltn_id = f8
     2 hpd_membership_id = f8
     2 hpd_service_id = f8
 ) WITH protect
 DECLARE consolidate_member_service_reltns(hpd_membership_id=f8,hpd_service_id=f8) = f8
 SUBROUTINE consolidate_member_service_reltns(hpd_membership_id,hpd_service_id)
   DECLARE member_service_id = f8 WITH protect, noconstant(0)
   FOR (j = 1 TO member_service_reltn_record_cnt)
     IF ((member_service_reltns->member_service_reltn[j].hpd_membership_id=hpd_membership_id)
      AND (member_service_reltns->member_service_reltn[j].hpd_service_id=hpd_service_id))
      SET member_service_id = member_service_reltns->member_service_reltn[j].
      hpd_member_service_reltn_id
      SET j = member_service_reltn_record_cnt
     ENDIF
   ENDFOR
   IF (member_service_id=0)
    SET member_service_reltn_record_cnt = (member_service_reltn_record_cnt+ 1)
    IF (mod(member_service_reltn_record_cnt,record_list_buffer)=1)
     SET stat = alterlist(member_service_reltns->member_service_reltn,((
      member_service_reltn_record_cnt+ record_list_buffer) - 1))
    ENDIF
    SET member_service_id = generate_identifier(null)
    SET member_service_reltns->member_service_reltn[member_service_reltn_record_cnt].
    hpd_member_service_reltn_id = member_service_id
    SET member_service_reltns->member_service_reltn[member_service_reltn_record_cnt].
    hpd_membership_id = hpd_membership_id
    SET member_service_reltns->member_service_reltn[member_service_reltn_record_cnt].hpd_service_id
     = hpd_service_id
   ENDIF
   RETURN(member_service_id)
 END ;Subroutine
 DECLARE insert_member_service_reltns(null) = null
 SUBROUTINE insert_member_service_reltns(null)
  CALL echo(build("Inserting [",member_service_reltn_record_cnt,"] Member-Service relationships..."))
  FOR (j = 1 TO member_service_reltn_record_cnt)
   INSERT  FROM hpd_member_service_reltn hmsr
    SET hmsr.hpd_member_service_reltn_id = member_service_reltns->member_service_reltn[j].
     hpd_member_service_reltn_id, hmsr.hpd_membership_id = member_service_reltns->
     member_service_reltn[j].hpd_membership_id, hmsr.hpd_service_id = member_service_reltns->
     member_service_reltn[j].hpd_service_id,
     hmsr.active_ind = active_ind, hmsr.updt_applctx = updt_applctx, hmsr.updt_id = updt_id,
     hmsr.updt_task = updt_task, hmsr.updt_cnt = updt_cnt, hmsr.updt_dt_tm = cnvtdatetime(updt_dt_tm)
    WITH nocounter
   ;end insert
   CALL detect_error(null)
  ENDFOR
 END ;Subroutine
 CALL populate_us_map(null)
 CALL parse_data_load("direct_external_upload.txt")
 CALL purge_existing_data(null)
 DECLARE address_hpd_organization_id = f8 WITH protect, noconstant(0)
 CALL echo("Consolidating record structures...")
 FOR (i = 1 TO size(data_load->row,5))
   SET provider_id = consolidate_providers(data_load->row[i].provider_last_name,data_load->row[i].
    provider_first_name,data_load->row[i].provider_middle_name,data_load->row[i].
    provider_date_of_birth,data_load->row[i].provider_gender,
    data_load->row[i].provider_npi,data_load->row[i].provider_prefix,data_load->row[i].
    provider_suffix,data_load->row[i].logical_domain_id)
   SET organization_id = consolidate_organizations(data_load->row[i].parent_organization,data_load->
    row[i].organization_name,data_load->row[i].org_mailing_address,data_load->row[i].
    org_billing_address,data_load->row[i].org_url,
    data_load->row[i].org_telephone_number,data_load->row[i].org_fax_number,data_load->row[i].
    logical_domain_id)
   SET membership_id = 0.0
   SET address_id = 0.0
   IF (organization_id > 0)
    SET membership_id = consolidate_memberships(provider_id,organization_id)
    SET address_id = consolidate_addresses(organization_id,data_load->row[i].address_type,data_load->
     row[i].address_street1,data_load->row[i].address_street2,data_load->row[i].address_street3,
     data_load->row[i].address_street4,data_load->row[i].address_city,data_load->row[i].address_state,
     data_load->row[i].address_zipcode,data_load->row[i].logical_domain_id)
   ENDIF
   IF (membership_id > 0)
    SET specialty_id = consolidate_specialties(data_load->row[i].specialty_name,data_load->row[i].
     specialty_telephone_number,data_load->row[i].specialty_mobile_number,data_load->row[i].
     specialty_pager_number,data_load->row[i].specialty_fax_number,
     data_load->row[i].specialty_description,data_load->row[i].logical_domain_id)
    SET member_specialty_id = consolidate_member_specialty_reltns(membership_id,specialty_id)
    SET service_id = consolidate_services(data_load->row[i].service_email,data_load->row[i].
     service_formatted_display_name,external_secure_email_cd)
    SET member_service_id = consolidate_member_service_reltns(membership_id,service_id)
   ENDIF
 ENDFOR
 CALL populate_parent_organization_id(null)
 CALL insert_providers(null)
 CALL insert_organizations(null)
 CALL insert_memberships(null)
 CALL insert_specialties(null)
 CALL insert_member_specialty_reltns(null)
 CALL insert_services(null)
 CALL insert_member_service_reltns(null)
 CALL insert_addresses(null)
 COMMIT
#exit_script
 FREE RECORD data_load
 FREE RECORD ld_records
 FREE RECORD providers
 FREE RECORD organizations
 FREE RECORD memberships
 FREE RECORD member_service_reltns
 FREE RECORD services
 FREE RECORD member_specialty_reltns
 FREE RECORD specialties
 FREE RECORD addresses
 SET message = information
END GO
