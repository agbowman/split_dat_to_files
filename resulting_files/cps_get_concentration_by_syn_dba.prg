CREATE PROGRAM cps_get_concentration_by_syn:dba
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 RECORD reply(
   1 concentration_strength = f8
   1 concentration_strength_unit = f8
   1 concentration_volume = f8
   1 concentration_volume_unit = f8
   1 dispense_unit_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE last_mod = c3 WITH private, noconstant("000")
 DECLARE code_set = i4 WITH protect, noconstant(0)
 DECLARE cdf_meaning = c12 WITH protect, noconstant(fillstring(12," "))
 DECLARE multum_contrib_src_cd = f8 WITH protect, noconstant(0.0)
 DECLARE current_ingred_cd = f8 WITH protect, noconstant(0.0)
 DECLARE errmsg = vc WITH protect, noconstant(" ")
 DECLARE multiple_ingredient_ind = i2 WITH protect, noconstant(0)
 DECLARE temp_mmdc = f8 WITH protect, noconstant(0.0)
 DECLARE table_exists = i2 WITH protect, noconstant(0)
 DECLARE drug_syn_id = f8 WITH protect, noconstant(0.0)
 DECLARE cki_str = vc WITH protect, noconstant("")
 DECLARE ingredient_strength_code = f8 WITH protect, noconstant(0.0)
 DECLARE unit_code_set = i4 WITH protext, constant(54)
 IF ((((currevminor2+ (currevminor * 100))+ (currev * 10000)) >= 80204))
  SET table_exists = checkdic("MLTM_NDC_ACT_INGRED_LIST","T",0)
  IF (table_exists < 2)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "checkdic()"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "MLTM_NDC_ACT_INGRED_LIST"
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "The table MLTM_NDC_ACT_INGRED_LIST cannot be accessed."
   GO TO exit_script
  ENDIF
  SET table_exists = checkdic("MLTM_NDC_INGRED_STRENGTH","T",0)
  IF (table_exists < 2)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "checkdic()"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "MLTM_NDC_INGRED_STRENGTH"
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "The table MLTM_NDC_INGRED_STRENGTH cannot be accessed."
   GO TO exit_script
  ENDIF
 ELSE
  SELECT INTO "nl:"
   a.table_name
   FROM dtable a
   WHERE ((a.table_name="MLTM_NDC_ACT_INGRED_LIST") OR (a.table_name="MLTM_NDC_INGRED_STRENGTH"))
   WITH nocounter
  ;end select
  IF (curqual < 2)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "select"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "dtable"
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "MLTM_NDC_INGRED_STRENGTH or MLTM_NDC_ACT_INGRED_LIST cannot be accessed."
   GO TO exit_script
  ENDIF
 ENDIF
 SET code_set = 73
 SET cdf_meaning = "MULTUM"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,multum_contrib_src_cd)
 IF (multum_contrib_src_cd < 1)
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM order_catalog_synonym ocs
  WHERE (ocs.synonym_id=request->synonym_id)
  DETAIL
   drug_syn_id = cnvtreal(substring(13,(size(trim(ocs.cki)) - 12),ocs.cki)), cki_str = ocs.cki
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  mmnm.main_multum_drug_code, mnai.active_ingredient_code
  FROM mltm_mmdc_name_map mmnm,
   mltm_ndc_act_ingred_list mnai
  PLAN (mmnm
   WHERE findstring("MUL.ORD-SYN!",cki_str) > 0
    AND drug_syn_id=mmnm.drug_synonym_id
    AND mmnm.function_id IN (59, 60))
   JOIN (mnai
   WHERE mnai.main_multum_drug_code=mmnm.main_multum_drug_code)
  ORDER BY mmnm.main_multum_drug_code, mnai.active_ingredient_code
  HEAD mmnm.main_multum_drug_code
   temp_mmdc = mmnm.main_multum_drug_code
  DETAIL
   IF (0.0=ingredient_strength_code)
    ingredient_strength_code = mnai.ingredient_strength_code
   ELSE
    multiple_ingredient_ind = 1, ingredient_strength_code = 0.0,
    CALL cancel(1)
   ENDIF
  WITH nocounter
 ;end select
 IF (1 != multiple_ingredient_ind
  AND 0.0 < ingredient_strength_code)
  SELECT INTO "nl:"
   mnis.strength_num_amount, mnis.strength_denom_amount, cva.code_value
   FROM mltm_ndc_ingred_strength mnis,
    mltm_units mu,
    code_value_alias cva
   PLAN (mnis
    WHERE mnis.ingredient_strength_code=ingredient_strength_code)
    JOIN (mu
    WHERE ((mu.unit_id=mnis.strength_denom_unit) OR (mu.unit_id=mnis.strength_num_unit)) )
    JOIN (cva
    WHERE cva.contributor_source_cd=multum_contrib_src_cd
     AND cva.code_set=unit_code_set
     AND cnvtupper(cva.alias)=cnvtupper(mu.unit_abbr))
   DETAIL
    IF (mu.unit_id=mnis.strength_num_unit)
     reply->concentration_strength = mnis.strength_num_amount, reply->concentration_strength_unit =
     cva.code_value
    ELSEIF (mu.unit_id=mnis.strength_denom_unit)
     reply->concentration_volume = mnis.strength_denom_amount, reply->concentration_volume_unit = cva
     .code_value
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (error(errmsg,0) != 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "select"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = ""
  SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
  GO TO exit_script
 ELSEIF (((0.0=ingredient_strength_code) OR (1=multiple_ingredient_ind)) )
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM mltm_ndc_main_drug_code mmdc,
   code_value_alias cva
  PLAN (mmdc
   WHERE mmdc.main_multum_drug_code=temp_mmdc)
   JOIN (cva
   WHERE cva.contributor_source_cd=multum_contrib_src_cd
    AND cva.code_set=unit_code_set
    AND cnvtstring(mmdc.dose_form_code)=cva.alias)
  HEAD mmdc.main_multum_drug_code
   reply->dispense_unit_cd = cva.code_value
  WITH nocounter
 ;end select
 IF (error(errmsg,0) != 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "select"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = ""
  SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
  GO TO exit_script
 ENDIF
 IF ((reply->concentration_strength > 0)
  AND (reply->concentration_volume > 0))
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exit_script
 SET script_version = "MOD 003 SW015124 05/19/2010"
END GO
