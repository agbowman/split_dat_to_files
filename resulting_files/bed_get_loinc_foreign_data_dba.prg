CREATE PROGRAM bed_get_loinc_foreign_data:dba
 SET modify = predeclare
 FREE SET reply
 RECORD reply(
   1 codes[*]
     2 dta_loinc_id = f8
     2 activity_type = vc
     2 short_name = vc
     2 long_name = vc
     2 specimen_type = vc
     2 loinc = vc
     2 active_ind = i2
     2 nomenclature_id = f8
     2 principle_type_cd = f8
     2 principle_type_disp = vc
     2 principle_type_mean = vc
     2 contributor_system_cd = f8
     2 contributor_system_disp = vc
     2 contributor_system_mean = vc
     2 language_cd = f8
     2 language_disp = vc
     2 language_mean = vc
     2 source_vocabulary_cd = f8
     2 source_vocabulary_disp = vc
     2 source_vocabulary_mean = vc
     2 source_string = c255
     2 short_string = c60
     2 mnemonic = c25
     2 source_identifier = vc
     2 concept_identifier = vc
     2 concept_cki = vc
     2 vocab_axis_cd = f8
     2 vocab_axis_disp = vc
     2 vocab_axis_mean = vc
     2 concept_source_cd = f8
     2 concept_source_disp = vc
     2 concept_source_mean = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE count = i4 WITH public, noconstant(0)
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE error_check = i4 WITH protect, noconstant(0)
 DECLARE serrormsg = vc WITH protect, noconstant("")
 DECLARE const_loinc_cki = c6 WITH protect, constant("LOINC!")
 DECLARE const_source_vocab_cs = i4 WITH protect, constant(400)
 DECLARE const_loinc = c5 WITH protect, constant("LOINC")
 DECLARE dloinccd = f8 WITH protect, noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(const_source_vocab_cs,const_loinc,1,dloinccd)
 SET reply->status_data.status = "F"
 SET count = 0
 SELECT INTO "nl:"
  FROM br_dta_loinc bdl,
   nomenclature n
  PLAN (bdl
   WHERE (bdl.wizard_mean_txt=request->wizard_mean)
    AND (bdl.source_identifier_name=request->source_identifier))
   JOIN (n
   WHERE ((n.concept_cki=concat(const_loinc_cki,trim(bdl.loinc_txt))
    AND n.source_vocabulary_cd=dloinccd
    AND n.primary_vterm_ind=1
    AND n.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND n.active_ind=1
    AND n.disallowed_ind=0) OR (n.principle_type_cd=0.0
    AND n.nomenclature_id=0.0)) )
  ORDER BY bdl.br_dta_loinc_id, n.nomenclature_id DESC
  HEAD bdl.br_dta_loinc_id
   count = (count+ 1)
   IF (mod(count,10)=1)
    stat = alterlist(reply->codes,(count+ 9))
   ENDIF
   reply->codes[count].dta_loinc_id = bdl.br_dta_loinc_id, reply->codes[count].activity_type = bdl
   .activity_type_txt, reply->codes[count].short_name = bdl.short_dta_name,
   reply->codes[count].long_name = bdl.long_dta_name, reply->codes[count].specimen_type = bdl
   .specimen_type_txt, reply->codes[count].loinc = bdl.loinc_txt,
   reply->codes[count].active_ind = n.active_ind, reply->codes[count].concept_cki = n.concept_cki,
   reply->codes[count].concept_identifier = n.concept_identifier,
   reply->codes[count].concept_source_cd = n.concept_source_cd, reply->codes[count].
   contributor_system_cd = n.contributor_system_cd, reply->codes[count].language_cd = n.language_cd,
   reply->codes[count].mnemonic = n.mnemonic, reply->codes[count].nomenclature_id = n.nomenclature_id,
   reply->codes[count].principle_type_cd = n.principle_type_cd,
   reply->codes[count].short_string = n.short_string, reply->codes[count].source_identifier = n
   .source_identifier, reply->codes[count].source_string = n.source_string,
   reply->codes[count].source_vocabulary_cd = n.source_vocabulary_cd, reply->codes[count].
   vocab_axis_cd = n.vocab_axis_cd
  HEAD n.nomenclature_id
   row + 0
  DETAIL
   row + 0
  FOOT  n.nomenclature_id
   row + 0
  FOOT  bdl.loinc_txt
   row + 0
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->codes,count)
#exit_script
 SET error_check = error(serrormsg,0)
 IF (error_check != 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
 ELSEIF (count > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
