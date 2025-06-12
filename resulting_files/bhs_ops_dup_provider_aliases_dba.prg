CREATE PROGRAM bhs_ops_dup_provider_aliases:dba
 EXECUTE bhs_ma_email_file
 EXECUTE bhs_hlp_ftp
 FREE RECORD frec
 RECORD frec(
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
   1 file_name = vc
   1 file_buf = vc
 )
 DECLARE mf_npi_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",320,"NPI"))
 DECLARE mf_externalid_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",320,"EXTERNALID"))
 DECLARE mf_licensenbr_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",320,"LICENSENBR"))
 DECLARE mf_docnbr_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",320,"DOCNBR"))
 DECLARE mf_docdea_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",320,"DOCDEA"))
 DECLARE mf_spi_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",320,"SPI"))
 DECLARE ms_field_sep = vc WITH protect, constant(",")
 DECLARE ms_rundate = vc WITH protect, constant(format(curdate,"mm-dd-yy;;d"))
 DECLARE ms_file_name = vc WITH protect, constant(concat("dup_provider_aliases_rpt_",ms_rundate,
   ".csv"))
 DECLARE ms_eml_subject = vc WITH protect, constant(concat("Duplicate Provider Aliases Report - ",
   ms_rundate))
 DECLARE ms_ftp_ip = vc WITH protect, constant("transfer.baystatehealth.org")
 DECLARE ms_ftp_un = vc WITH protect, constant("CernerFTP")
 DECLARE ms_ftp_pw = vc WITH protect, constant("gJeZD64")
 DECLARE ms_loc_dir = vc WITH protect, constant(logical("ccluserdir"))
 DECLARE ms_ftp_path = vc WITH protect, constant("/CISCORE/bhs_dup_prov/prod")
 DECLARE ms_recipients = vc WITH protect, noconstant("")
 DECLARE ms_ftp_cmd = vc WITH protect, noconstant("")
 SET frec->file_name = ms_file_name
 SET frec->file_buf = "w"
 SET stat = cclio("OPEN",frec)
 SELECT INTO "nl:"
  d.info_name
  FROM dm_info d
  PLAN (d
   WHERE d.info_domain="BHS_OPS_DUP_PROVIDER_ALIASES")
  DETAIL
   ms_recipients = d.info_name
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  counter = count(*), alias_type = uar_get_code_meaning(pa.prsnl_alias_type_cd), alias = trim(pa
   .alias)
  FROM prsnl_alias pa
  WHERE pa.person_id > 0
   AND pa.active_ind=1
   AND textlen(trim(pa.alias)) > 0
   AND pa.prsnl_alias_type_cd IN (mf_npi_cd, mf_externalid_cd, mf_licensenbr_cd, mf_docnbr_cd,
  mf_docdea_cd,
  mf_spi_cd)
  GROUP BY pa.alias, pa.prsnl_alias_type_cd
  HAVING count(*) > 1
  ORDER BY alias_type
  HEAD REPORT
   frec->file_buf = concat('"',"Alias Count",'"',ms_field_sep,'"',
    "Alias Type",'"',ms_field_sep,'"',"Alias",
    '"',ms_field_sep,char(13)), stat = cclio("WRITE",frec)
  DETAIL
   frec->file_buf = concat('"',trim(cnvtstring(counter)),'"',ms_field_sep,'"',
    trim(alias_type),'"',ms_field_sep,'"',trim(alias),
    '"',ms_field_sep,char(13)), stat = cclio("WRITE",frec)
  WITH nocounter
 ;end select
 SET stat = cclio("CLOSE",frec)
 SET ms_ftp_cmd = concat("put ",ms_file_name)
 SET stat = bhs_ftp_cmd(ms_ftp_cmd,ms_ftp_ip,ms_ftp_un,ms_ftp_pw,ms_loc_dir,
  ms_ftp_path)
 CALL emailfile(ms_file_name,ms_file_name,ms_recipients,ms_eml_subject,1)
#exit_script
END GO
