CREATE PROGRAM drc_get_prod_and_syn_by_group:dba
 FREE SET reply
 RECORD reply(
   1 dose_range_check_name = vc
   1 drc_group_id = f8
   1 products[*]
     2 drc_group_reltn_id = f8
     2 item_id = f8
     2 generic_name = vc
     2 formulation_id = f8
     2 generic_name_list = vc
   1 synonyms[*]
     2 drc_group_reltn_id = f8
     2 synonym_id = f8
     2 mnemonic = vc
     2 drug_synonym_id = f8
     2 mnemonic_list = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE cmeddef = f8 WITH public, noconstant(0.0)
 DECLARE cdesc = f8 WITH public, noconstant(0.0)
 DECLARE csystem = f8 WITH public, noconstant(0.0)
 DECLARE csyspkgtyp = f8 WITH public, noconstant(0.0)
 DECLARE pharm_cd = f8 WITH public, noconstant(0.0)
 DECLARE new_model_check = i2 WITH public, noconstant(0)
 DECLARE prod_cnt = i4 WITH protect, noconstant(0)
 DECLARE syn_cnt = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET cmeddef = uar_get_code_by("MEANING",11001,"MED_DEF")
 SET cdesc = uar_get_code_by("MEANING",11000,"DESC")
 SET csystem = uar_get_code_by("MEANING",4062,"SYSTEM")
 SET csyspkgtyp = uar_get_code_by("MEANING",4062,"SYSPKGTYP")
 SET pharm_cd = uar_get_code_by("MEANING",6000,"PHARMACY")
 IF (pharm_cd=0)
  SELECT INTO "nl:"
   FROM code_value c
   WHERE c.code_set=6000
    AND c.cdf_meaning="PHARMACY"
   DETAIL
    pharm_cd = c.code_value
   WITH nocounter
  ;end select
 ENDIF
 SET reply->drc_group_id = request->drc_group_id
 SET reply->dose_range_check_name = request->dose_range_check_name
 SELECT INTO "nl:"
  dmp.pref_nbr
  FROM dm_prefs dmp
  WHERE dmp.application_nbr=300000
   AND dmp.pref_domain="PHARMNET-INPATIENT"
   AND dmp.pref_name="NEW MODEL"
   AND dmp.person_id=0
   AND dmp.pref_section="FRMLRYMGMT"
  DETAIL
   IF (dmp.pref_nbr=1)
    new_model_check = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (new_model_check=0)
  CALL echo("Old model search")
  SELECT INTO "nl:"
   dgr.active_ind, dgr.drc_group_id, dgr.formulation_id,
   dgr.drc_group_reltn_id, md.cki, md.item_id,
   oii.object_type_cd, oii.identifier_type_cd, oii.active_ind,
   oii.generic_object, oii.object_id, oii.primary_ind,
   oii.value_key
   FROM drc_group_reltn dgr,
    medication_definition md,
    object_identifier_index oii
   PLAN (dgr
    WHERE (dgr.drc_group_id=request->drc_group_id)
     AND dgr.active_ind > 0
     AND dgr.formulation_id > 0.0)
    JOIN (md
    WHERE md.cki=concat("MUL.FRMLTN!",cnvtstring(dgr.formulation_id)))
    JOIN (oii
    WHERE oii.object_type_cd=cmeddef
     AND oii.identifier_type_cd=cdesc
     AND oii.active_ind=1
     AND ((oii.generic_object+ 0)=0)
     AND oii.object_id=md.item_id
     AND oii.primary_ind=1)
   ORDER BY md.cki, oii.value_key
   HEAD REPORT
    prod_cnt = 0, stat = alterlist(reply->products,10)
   HEAD md.cki
    prod_cnt = (prod_cnt+ 1)
    IF (mod(prod_cnt,10)=1)
     stat = alterlist(reply->products,(prod_cnt+ 9))
    ENDIF
    reply->products[prod_cnt].drc_group_reltn_id = dgr.drc_group_reltn_id, reply->products[prod_cnt].
    item_id = oii.object_id, reply->products[prod_cnt].generic_name = oii.value,
    reply->products[prod_cnt].formulation_id = dgr.formulation_id
   HEAD oii.value_key
    IF ((reply->products[prod_cnt].generic_name_list > " "))
     reply->products[prod_cnt].generic_name_list = concat(reply->products[prod_cnt].generic_name_list,
      " & ",trim(oii.value))
    ELSE
     reply->products[prod_cnt].generic_name_list = trim(oii.value)
    ENDIF
   DETAIL
    row + 0
   FOOT  oii.value_key
    row + 0
   FOOT REPORT
    stat = alterlist(reply->products,prod_cnt)
   WITH nocounter
  ;end select
 ELSE
  CALL echo("New model search")
  SELECT INTO "nl:"
   dgr.active_ind, dgr.drc_group_id, dgr.formulation_id,
   dgr.drc_group_reltn_id, md.cki, md.item_id,
   mi.*
   FROM drc_group_reltn dgr,
    medication_definition md,
    med_identifier mi
   PLAN (dgr
    WHERE (dgr.drc_group_id=request->drc_group_id)
     AND dgr.active_ind > 0
     AND dgr.formulation_id > 0.0)
    JOIN (md
    WHERE md.cki=concat("MUL.FRMLTN!",cnvtstring(dgr.formulation_id)))
    JOIN (mi
    WHERE mi.item_id=md.item_id
     AND mi.flex_type_cd IN (csystem, csyspkgtyp)
     AND mi.med_product_id=0.0
     AND mi.med_identifier_type_cd=cdesc
     AND mi.active_ind=1)
   ORDER BY md.cki, mi.value_key
   HEAD REPORT
    prod_cnt = 0, stat = alterlist(reply->products,10)
   HEAD md.cki
    prod_cnt = (prod_cnt+ 1)
    IF (mod(prod_cnt,10)=1)
     stat = alterlist(reply->products,(prod_cnt+ 9))
    ENDIF
    reply->products[prod_cnt].drc_group_reltn_id = dgr.drc_group_reltn_id, reply->products[prod_cnt].
    item_id = mi.item_id, reply->products[prod_cnt].generic_name = mi.value,
    reply->products[prod_cnt].formulation_id = dgr.formulation_id
   HEAD mi.value_key
    IF ((reply->products[prod_cnt].generic_name_list > " "))
     reply->products[prod_cnt].generic_name_list = concat(reply->products[prod_cnt].generic_name_list,
      " & ",trim(mi.value))
    ELSE
     reply->products[prod_cnt].generic_name_list = trim(mi.value)
    ENDIF
   DETAIL
    row + 0
   FOOT  mi.value_key
    row + 0
   FOOT REPORT
    stat = alterlist(reply->products,prod_cnt)
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  dgr.drc_group_reltn_id, dgr.drug_synonym_id, dgr.active_ind,
  dgr.drc_group_id, ocs.cki, ocs.active_ind,
  ocs.mnemonic_key_cap, ocs.synonym_id, ocs.mnemonic
  FROM drc_group_reltn dgr,
   order_catalog_synonym ocs
  PLAN (dgr
   WHERE (dgr.drc_group_id=request->drc_group_id)
    AND dgr.active_ind > 0
    AND dgr.drug_synonym_id > 0.0)
   JOIN (ocs
   WHERE ocs.cki=concat("MUL.ORD-SYN!",cnvtstring(dgr.drug_synonym_id))
    AND ocs.active_ind > 0)
  ORDER BY ocs.cki, ocs.mnemonic_key_cap
  HEAD REPORT
   syn_cnt = 0, stat = alterlist(reply->synonyms,10)
  HEAD ocs.cki
   syn_cnt = (syn_cnt+ 1)
   IF (mod(syn_cnt,10)=1)
    stat = alterlist(reply->synonyms,(syn_cnt+ 9))
   ENDIF
   reply->synonyms[syn_cnt].drc_group_reltn_id = dgr.drc_group_reltn_id, reply->synonyms[syn_cnt].
   synonym_id = ocs.synonym_id, reply->synonyms[syn_cnt].mnemonic = ocs.mnemonic,
   reply->synonyms[syn_cnt].drug_synonym_id = dgr.drug_synonym_id
  HEAD ocs.mnemonic_key_cap
   IF ((reply->synonyms[syn_cnt].mnemonic_list > " "))
    reply->synonyms[syn_cnt].mnemonic_list = concat(reply->synonyms[syn_cnt].mnemonic_list," & ",trim
     (ocs.mnemonic))
   ELSE
    reply->synonyms[syn_cnt].mnemonic_list = trim(ocs.mnemonic)
   ENDIF
  DETAIL
   row + 0
  FOOT  ocs.mnemonic_key_cap
   row + 0
  FOOT REPORT
   stat = alterlist(reply->synonyms,syn_cnt)
  WITH nocounter
 ;end select
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
