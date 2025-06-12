CREATE PROGRAM bhs_pharm_code_set_upload:dba
 EXECUTE bhs_sys_stand_subroutine
 FREE RECORD pharm_cust_cs
 RECORD pharm_cust_cs(
   1 md_beg_dt_tm = dq8
   1 md_end_dt_tm = dq8
   1 codeset[*]
     2 mf_code_set = f8
     2 ms_display = vc
     2 ms_cdf_meaning = vc
     2 ms_definition = vc
     2 ms_description = vc
     2 ms_collation_seq = i2
     2 ms_cki = vc
     2 ms_beg_date = vc
     2 ms_end_date = vc
     2 ms_active_ind = i2
     2 ms_concept_cki = vc
     2 ms_alias_type_meaning_ib = vc
     2 ms_alias_inbound = vc
     2 ms_contr_src_inbound = vc
     2 ms_primary_ind_inbound = vc
     2 ms_alias_in_delete_ind = vc
     2 ms_contr_src_outbound = vc
     2 ms_alias_outbound = vc
     2 ms_alias_type_meaning_ob = vc
     2 ms_alias_out_delete_ind = vc
     2 ms_field_name = vc
     2 ms_field_type = vc
     2 ms_field_value = vc
 ) WITH protect
 SET pharm_cust_cs->md_beg_dt_tm = cnvtdatetime((curdate - 90),000000)
 SET pharm_cust_cs->md_end_dt_tm = cnvtdatetime(curdate,235900)
 CALL echo("TIMES:")
 CALL echo(format(cnvtdatetime(pharm_cust_cs->md_beg_dt_tm),";;q"))
 CALL echo(format(cnvtdatetime(pharm_cust_cs->md_end_dt_tm),";;q"))
 SET logical pharm_file "bhscust:bhs_pharm_code_set_upload.csv"
 DECLARE mf_mnemonic_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6011,
   "CDISPENSABLEDRUGNAMES"))
 DECLARE ms_email_filename = vc WITH protect, constant("bhs_pharm_code_set_upload.csv")
 DECLARE mc_delimiter = c1 WITH protect, noconstant(",")
 DECLARE ms_line = vc WITH protect, noconstant(" ")
 DECLARE ms_hold_orig_dt = dq8 WITH procect, noconstant(0)
 DECLARE ml_cs_cnt = i4 WITH protect, noconstant(0)
 DECLARE ms_dclcom_str = vc WITH protect, noconstant(" ")
 DECLARE mn_dclcom_len = i4 WITH protect, noconstant(0)
 DECLARE mn_dclcom_stat = i4 WITH protect, noconstant(0)
 DECLARE mn_test_ind = i4 WITH protect, noconstant(0)
 SELECT DISTINCT
  oc.primary_mnemonic, cv.display_key
  FROM order_catalog_synonym m,
   order_catalog oc,
   ocs_facility_r ofr,
   code_value cv
  PLAN (m)
   JOIN (oc
   WHERE m.catalog_cd=oc.catalog_cd
    AND m.mnemonic_type_cd=mf_mnemonic_cd
    AND oc.active_ind=1)
   JOIN (cv
   WHERE cv.code_set=200
    AND cv.display=oc.primary_mnemonic)
   JOIN (ofr
   WHERE ofr.synonym_id=m.synonym_id)
  ORDER BY oc.primary_mnemonic
  HEAD REPORT
   oc.primary_mnemonic, ml_cs_cnt = 0, mn_test_ind = 1
  HEAD oc.primary_mnemonic
   ml_cs_cnt = (ml_cs_cnt+ 1)
   IF (ml_cs_cnt > size(pharm_cust_cs->codeset,5))
    stat = alterlist(pharm_cust_cs->codeset,ml_cs_cnt)
   ENDIF
   pharm_cust_cs->codeset[ml_cs_cnt].mf_code_set = 104492.00, pharm_cust_cs->codeset[ml_cs_cnt].
   ms_display = oc.primary_mnemonic, pharm_cust_cs->codeset[ml_cs_cnt].ms_cdf_meaning = "",
   pharm_cust_cs->codeset[ml_cs_cnt].ms_definition = "", pharm_cust_cs->codeset[ml_cs_cnt].
   ms_description = oc.primary_mnemonic, pharm_cust_cs->codeset[ml_cs_cnt].ms_collation_seq = 0,
   pharm_cust_cs->codeset[ml_cs_cnt].ms_cki = "", pharm_cust_cs->codeset[ml_cs_cnt].ms_beg_date =
   format(cnvtdatetime(curdate,curtime3),"MM/DD/YYYY HH:MM;;q"), pharm_cust_cs->codeset[ml_cs_cnt].
   ms_end_date = "12/31/2100 23:59",
   pharm_cust_cs->codeset[ml_cs_cnt].ms_active_ind = 1, pharm_cust_cs->codeset[ml_cs_cnt].
   ms_concept_cki = "", pharm_cust_cs->codeset[ml_cs_cnt].ms_alias_type_meaning_ib = "",
   pharm_cust_cs->codeset[ml_cs_cnt].ms_alias_inbound = "", pharm_cust_cs->codeset[ml_cs_cnt].
   ms_contr_src_inbound = "", pharm_cust_cs->codeset[ml_cs_cnt].ms_primary_ind_inbound = "",
   pharm_cust_cs->codeset[ml_cs_cnt].ms_alias_in_delete_ind = "", pharm_cust_cs->codeset[ml_cs_cnt].
   ms_contr_src_outbound = "", pharm_cust_cs->codeset[ml_cs_cnt].ms_alias_outbound = "",
   pharm_cust_cs->codeset[ml_cs_cnt].ms_alias_type_meaning_ob = "", pharm_cust_cs->codeset[ml_cs_cnt]
   .ms_alias_out_delete_ind = "", pharm_cust_cs->codeset[ml_cs_cnt].ms_field_name = "",
   pharm_cust_cs->codeset[ml_cs_cnt].ms_field_type = "", pharm_cust_cs->codeset[ml_cs_cnt].
   ms_field_value = ""
  FOOT REPORT
   stat = alterlist(pharm_cust_cs->codeset,ml_cs_cnt),
   CALL echorecord(pharm_cust_cs)
  WITH nocounter
 ;end select
 IF (curqual < 1)
  GO TO exit_script
 ENDIF
 SELECT DISTINCT INTO pharm_file
  FROM (dummyt d  WITH seq = size(pharm_cust_cs->codeset,5))
  ORDER BY pharm_cust_cs->codeset[d.seq].ms_display
  HEAD REPORT
   ms_line = build(
    "Enter a Code Set number that has Access Indicators set to allow the desired action.",
    mc_delimiter,"The Display of the Code Value.",mc_delimiter,"CDF Meaning of the Code Value.",
    mc_delimiter,
    "Description of the Code Value. This field is required if the Code Set is duplicate checking on this column.",
    mc_delimiter,
    "Definition of the Code Value. This field is required if the Code Set is duplicate checking on this column.",
    mc_delimiter,
    "Collation Seq is used to sequence Code Values for sorting purposes.",mc_delimiter,
    "Collation Seq values should start with 1 and be sequential for the code set.",mc_delimiter,
    "Begin effective date and time of the code value.  Time is optional.Use the format: MM/DD/YYYY HH:MM.",
    mc_delimiter,
    "End effective date and time of the code value.  Time is optional. Use the format: MM/DD/YYYY HH:MM.",
    mc_delimiter,"Active Indicator for the Code Value. 1 = Active  0 or blank = Inactive",
    mc_delimiter,
    "Concept CKI value of the code value.  Do not use this column without permission.",mc_delimiter,
    "Alias Type Meaning of the Inbound Alias.",mc_delimiter,"Inbound Alias for the Code Value.",
    mc_delimiter,"Contributor Source for the Inbound Alias to be attached to the Code Value.",
    mc_delimiter,"Select a display or display key value from Code Set 73.",mc_delimiter,
    "There is no forced implementation of this field at this time.",mc_delimiter,
    "Indicator to denote whether to create or delete the Inbound Alias. 0 or blank = create the Alias",
    mc_delimiter,"Contributor Source for the Outbound Alias to be attached to the Code Value.",
    mc_delimiter,"Alias Type Meaning of the Outbound Alias.",mc_delimiter,
    "Indicator to denote whether to create or delete the Outbound Alias. 0 or blank = create the Alias  1 = delete the Alias",
    mc_delimiter,
    "Name of the Code Value Extension for the Code Set that the Field Value will be placed.  The Code",
    mc_delimiter,"Field Type of the Extension.  1 = Numeric  2 = Alphanumeric",mc_delimiter,
    "Extension Value for the Code Value."), row 0, col 0,
   ms_line, ms_line = build("*Code Set",mc_delimiter,"*Display",mc_delimiter,"CDF Meaning",
    mc_delimiter,"Description",mc_delimiter,"Definition",mc_delimiter,
    "Collation Seq",mc_delimiter,"CKI",mc_delimiter,"Begin Date+Time",
    mc_delimiter,"End Date+Time",mc_delimiter,"Active Ind",mc_delimiter,
    "Concept CKI",mc_delimiter,"Alias Type Meaning inbound",mc_delimiter,"*Alias inbound",
    mc_delimiter,"*Contributor Source inbound",mc_delimiter,"Primary Ind inbound",mc_delimiter,
    "Alias_In_Delete_Ind",mc_delimiter,"*Contributor Source outbound",mc_delimiter,"*Alias outbound",
    mc_delimiter,"Alias Type Meaning outbound",mc_delimiter,"Alias_Out_Delete_Ind",mc_delimiter,
    "*Field Name",mc_delimiter,"Field_Type",mc_delimiter,"Field Value"), row + 1,
   col 0, ms_line
  DETAIL
   ms_line = build(pharm_cust_cs->codeset[d.seq].mf_code_set,mc_delimiter,pharm_cust_cs->codeset[d
    .seq].ms_display,mc_delimiter,pharm_cust_cs->codeset[d.seq].ms_cdf_meaning,
    mc_delimiter,pharm_cust_cs->codeset[d.seq].ms_description,mc_delimiter,pharm_cust_cs->codeset[d
    .seq].ms_definition,mc_delimiter,
    pharm_cust_cs->codeset[d.seq].ms_collation_seq,mc_delimiter,pharm_cust_cs->codeset[d.seq].ms_cki,
    mc_delimiter,pharm_cust_cs->codeset[d.seq].ms_beg_date,
    mc_delimiter,pharm_cust_cs->codeset[d.seq].ms_end_date,mc_delimiter,pharm_cust_cs->codeset[d.seq]
    .ms_active_ind,mc_delimiter,
    pharm_cust_cs->codeset[d.seq].ms_concept_cki,mc_delimiter,pharm_cust_cs->codeset[d.seq].
    ms_alias_type_meaning_ib,mc_delimiter,pharm_cust_cs->codeset[d.seq].ms_alias_inbound,
    mc_delimiter,pharm_cust_cs->codeset[d.seq].ms_contr_src_inbound,mc_delimiter,pharm_cust_cs->
    codeset[d.seq].ms_primary_ind_inbound,mc_delimiter,
    pharm_cust_cs->codeset[d.seq].ms_alias_in_delete_ind,mc_delimiter,pharm_cust_cs->codeset[d.seq].
    ms_contr_src_outbound,mc_delimiter,pharm_cust_cs->codeset[d.seq].ms_alias_outbound,
    mc_delimiter,pharm_cust_cs->codeset[d.seq].ms_alias_type_meaning_ob,mc_delimiter,pharm_cust_cs->
    codeset[d.seq].ms_alias_out_delete_ind,mc_delimiter,
    pharm_cust_cs->codeset[d.seq].ms_field_name,mc_delimiter,pharm_cust_cs->codeset[d.seq].
    ms_field_type,mc_delimiter,pharm_cust_cs->codeset[d.seq].ms_field_value), row + 1, col 0,
   ms_line
  WITH nocounter, formfeed = none, maxcol = 2000,
   format = variable, maxrow = 1
 ;end select
 CALL echo("emailing")
 SET email_list = "tracy.baker@bhs.org"
 SET ms_tmp_str = concat("Files Emailed ",format(sysdate,"dd-mmm-yyyy hh:mm:ss;;d"))
 CALL emailfile(concat("$bhscust/",ms_email_filename),concat("$bhscust/",ms_email_filename),
  email_list,ms_tmp_str,1)
 IF (findfile(concat("bhscust:",ms_email_filename))=1)
  CALL echo("Unable to delete emailed file")
 ELSE
  CALL echo("Emailed File Deleted")
 ENDIF
#exit_script
END GO
