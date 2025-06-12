CREATE PROGRAM bed_get_pharm_check_database:dba
 FREE SET reply
 RECORD reply(
   1 using_ndc_as_id_ind = i2
   1 using_new_formulary_model_ind = i2
   1 desc_name_pref_ind = i2
   1 desc_nbr_chars_dose_pref_ind = i2
   1 desc_strength_pref_ind = i2
   1 mnem_name_pref_ind = i2
   1 mnem_nbr_chars_dose_pref_ind = i2
   1 mnem_nbr_chars_name_pref_ind = i2
   1 unique_id_format_pref_ind = i2
   1 unique_id_required_pref_ind = i2
   1 ident_sync_pref_ind = i2
   1 legal_stat_alias_created_ind = i2
   1 dup_ndc_flag = i2
   1 ident_sync_rxtype_pref_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET reply->using_ndc_as_id_ind = 0
 SET reply->using_new_formulary_model_ind = 0
 SET reply->desc_name_pref_ind = 0
 SET reply->desc_nbr_chars_dose_pref_ind = 0
 SET reply->desc_strength_pref_ind = 0
 SET reply->mnem_name_pref_ind = 0
 SET reply->mnem_nbr_chars_dose_pref_ind = 0
 SET reply->mnem_nbr_chars_name_pref_ind = 0
 SET reply->unique_id_format_pref_ind = 0
 SET reply->unique_id_required_pref_ind = 0
 SET reply->ident_sync_pref_ind = 0
 SET reply->legal_stat_alias_created_ind = 0
 SELECT INTO "NL:"
  FROM dm_prefs dp
  WHERE dp.application_nbr=300000
   AND dp.pref_domain="PHARMNET"
   AND dp.pref_section="FRMLRYMGMT"
   AND dp.pref_name IN ("RXDRGNOFM", "RXLBLSTR", "RXLBLFORM", "RXLBLNAME", "RXNAMEDIG",
  "RXFRMDIG", "RXNAMEMNE", "RDDSFORMAT", "RDDSUNIQUE")
  DETAIL
   IF (dp.pref_name="RXDRGNOFM"
    AND cnvtupper(dp.pref_str)="NDC")
    reply->using_ndc_as_id_ind = 1
   ELSEIF (dp.pref_name="RXLBLSTR")
    reply->desc_strength_pref_ind = 1
   ELSEIF (dp.pref_name="RXLBLFORM")
    reply->desc_nbr_chars_dose_pref_ind = 1
   ELSEIF (dp.pref_name="RXLBLNAME")
    reply->desc_name_pref_ind = 1
   ELSEIF (dp.pref_name="RXNAMEDIG")
    reply->mnem_nbr_chars_name_pref_ind = 1
   ELSEIF (dp.pref_name="RXFRMDIG")
    reply->mnem_nbr_chars_dose_pref_ind = 1
   ELSEIF (dp.pref_name="RXNAMEMNE")
    reply->mnem_name_pref_ind = 1
   ELSEIF (dp.pref_name="RDDSFORMAT")
    reply->unique_id_format_pref_ind = 1
   ELSEIF (dp.pref_name="RDDSUNIQUE")
    reply->unique_id_required_pref_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM dm_prefs dp
  WHERE dp.application_nbr=300000
   AND dp.pref_domain="PHARMNET-INPATIENT"
   AND dp.pref_section="FRMLRYMGMT"
   AND dp.pref_name="NEW MODEL"
  DETAIL
   IF (dp.pref_nbr=1)
    reply->using_new_formulary_model_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM dm_prefs dp
  WHERE dp.application_nbr=300000
   AND dp.pref_domain="PHARMNET"
   AND dp.pref_section="FORMULARY"
   AND dp.pref_name="IDENTSYNC"
  DETAIL
   IF (dp.pref_nbr=1)
    reply->ident_sync_pref_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM dm_prefs dp
  WHERE dp.application_nbr=300000
   AND dp.pref_domain="PHARMNET"
   AND dp.pref_section="FORMULARY"
   AND dp.pref_name="IDENTSYNCRXTYPE"
  DETAIL
   IF (dp.pref_cd > 0)
    reply->ident_sync_rxtype_pref_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SET multum_contr_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=73
   AND cv.cdf_meaning="MULTUM"
   AND cv.active_ind=1
  DETAIL
   multum_contr_cd = cv.code_value
  WITH nocounter
 ;end select
 SET alias_cnt = 0
 SELECT INTO "NL:"
  FROM code_value_alias cva
  WHERE cva.code_set=4200
   AND cva.contributor_source_cd=multum_contr_cd
   AND cva.alias IN ("0", "2", "3", "4", "5",
  "6")
  DETAIL
   alias_cnt = (alias_cnt+ 1)
  WITH nocounter
 ;end select
 IF (alias_cnt > 5)
  SET reply->legal_stat_alias_created_ind = 1
 ENDIF
 SET reply->dup_ndc_flag = 2
 SELECT INTO "NL:"
  FROM br_name_value b
  WHERE b.br_nv_key1="PHARM_DUP_QUESTION"
  DETAIL
   reply->dup_ndc_flag = cnvtint(trim(b.br_value))
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
