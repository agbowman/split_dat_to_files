CREATE PROGRAM bhs_rpt_dup_provider_alias_dly:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start date" = "CURDATE",
  "End Date" = "CURDATE",
  "Enter email" = "",
  "Run in OPS" = 0
  WITH outdev, s_start_date, s_end_date,
  email, ops_ind
 EXECUTE bhs_ma_email_file
 FREE RECORD dups
 RECORD dups(
   1 cntalias = i4
   1 alias[*]
     2 person_id = f8
     2 alias = vc
     2 alias_type = vc
     2 alias_cnt = i4
 )
 FREE RECORD frec
 RECORD frec(
   1 file_desc = w8
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
 DECLARE ms_eml_subject = vc WITH protect, noconstant(concat(
   "Daily Duplicate Provider Aliases Report - ",ms_rundate))
 DECLARE ms_start_date = vc WITH noconstant( $S_START_DATE), protect
 DECLARE ms_end_date = vc WITH noconstant( $S_END_DATE), protect
 DECLARE ms_recipients = vc WITH protect, noconstant( $EMAIL)
 DECLARE ml_dup_chk = i2 WITH noconstant(0), protect
 SET frec->file_name = ms_file_name
 SET frec->file_buf = "w"
 IF (( $OPS_IND=1))
  SET ms_start_date = format(datetimefind(cnvtlookbehind("1,D",cnvtdatetime(curdate,0)),"D","B","B"),
   "DD-MMM-YYYY;;D")
  SET ms_start_date = format(cnvtdatetime(cnvtdate2(ms_start_date,"DD-MMM-YYYY"),0),";;Q")
  SET ms_end_date = format(datetimefind(cnvtlookbehind("0,D",cnvtdatetime(curdate,0)),"D","E","E"),
   "DD-MMM-YYYY;;D")
  SET ms_end_date = format(cnvtdatetime(cnvtdate2(ms_end_date,"DD-MMM-YYYY"),235959),";;Q")
 ENDIF
 SET stat = cclio("OPEN",frec)
 SELECT INTO "NL:"
  FROM prsnl_alias pa,
   prsnl_alias pa1
  PLAN (pa
   WHERE pa.updt_dt_tm BETWEEN cnvtdatetime(cnvtdate2(ms_start_date,"DD-MMM-YYYY"),0) AND
   cnvtdatetime(cnvtdate2(ms_end_date,"DD-MMM-YYYY"),235959)
    AND textlen(trim(pa.alias)) > 0
    AND pa.end_effective_dt_tm > sysdate
    AND pa.active_ind=1
    AND pa.prsnl_alias_type_cd IN (mf_npi_cd, mf_externalid_cd, mf_licensenbr_cd, mf_docnbr_cd,
   mf_docdea_cd,
   mf_spi_cd))
   JOIN (pa1
   WHERE pa1.active_ind=1
    AND trim(pa1.alias,3)=trim(pa.alias,3)
    AND pa1.prsnl_alias_type_cd=pa.prsnl_alias_type_cd)
  ORDER BY pa1.prsnl_alias_type_cd, pa1.alias, pa1.prsnl_alias_id
  HEAD REPORT
   stat = alterlist(dups->alias,10)
  HEAD pa.alias
   dups->cntalias += 1
   IF (mod(dups->cntalias,10)=1
    AND (dups->cntalias > 1))
    stat = alterlist(dups->alias,(dups->cntalias+ 9))
   ENDIF
   dups->alias[dups->cntalias].alias = trim(pa.alias,3), dups->alias[dups->cntalias].alias_type =
   trim(uar_get_code_display(pa.prsnl_alias_type_cd),3)
  HEAD pa1.prsnl_alias_id
   dups->alias[dups->cntalias].alias_cnt += 1
   IF ((dups->alias[dups->cntalias].alias_cnt > 1))
    ml_dup_chk = 1
   ENDIF
  FOOT REPORT
   stat = alterlist(dups->alias,dups->cntalias)
  WITH nocounter, format, separator = " "
 ;end select
 IF (( $OPS_IND=0))
  SELECT INTO  $OUTDEV
   alias = substring(1,100,dups->alias[d1.seq].alias), alias_type = substring(1,100,dups->alias[d1
    .seq].alias_type), count = dups->alias[d1.seq].alias_cnt
   FROM (dummyt d1  WITH seq = size(dups->alias,5))
   PLAN (d1
    WHERE (dups->alias[d1.seq].alias_cnt > 1))
   WITH nocounter, separator = " ", format
  ;end select
 ELSEIF (( $OPS_IND=1))
  IF (ml_dup_chk=1)
   SELECT INTO "NL:"
    alias = dups->alias[d1.seq].alias, alias_type = dups->alias[d1.seq].alias_type, count = dups->
    alias[d1.seq].alias_cnt
    FROM (dummyt d1  WITH seq = size(dups->alias,5))
    PLAN (d1
     WHERE (dups->alias[d1.seq].alias_cnt > 1))
    HEAD REPORT
     frec->file_buf = concat('"',"Alias Count",'"',ms_field_sep,'"',
      "Alias Type",'"',ms_field_sep,'"',"Alias",
      '"',ms_field_sep,char(13)), stat = cclio("WRITE",frec)
    DETAIL
     frec->file_buf = concat('"',cnvtstring(dups->alias[d1.seq].alias_cnt,0),'"',ms_field_sep,'"',
      dups->alias[d1.seq].alias_type,'"',ms_field_sep,'"',dups->alias[d1.seq].alias,
      '"',ms_field_sep,char(13)), stat = cclio("WRITE",frec)
    WITH nocounter
   ;end select
   SET stat = cclio("CLOSE",frec)
   CALL emailfile(ms_file_name,ms_file_name,ms_recipients,ms_eml_subject,1)
  ELSEIF (ml_dup_chk=0)
   CALL emailfile(ms_file_name,ms_file_name,ms_recipients,
    "No Duplicate Aliases Found Since Yesterday",1)
  ENDIF
 ENDIF
#exit_script
END GO
