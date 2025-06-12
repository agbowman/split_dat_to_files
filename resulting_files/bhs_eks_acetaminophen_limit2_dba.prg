CREATE PROGRAM bhs_eks_acetaminophen_limit2:dba
 SET retval = - (1)
 SET log_message = "entering program bhs_eks_acet"
 DECLARE total_dose = f8 WITH noconstant(0.0), protect
 DECLARE textval = vc WITH noconstant(" "), protect
 DECLARE textval = c75 WITH noconstant(" "), protect
 DECLARE modify = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"MODIFY")), protect
 DECLARE acetaminophencodeine_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "ACETAMINOPHENCODEINE")), protect
 DECLARE acetaminophenhydrocodone_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "ACETAMINOPHENHYDROCODONE")), protect
 DECLARE acetaminophen_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,"ACETAMINOPHEN")),
 protect
 DECLARE acetaminophenpropoxyphene_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "ACETAMINOPHENPROPOXYPHENE")), protect
 DECLARE oxycodoneacetaminophen_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "OXYCODONEACETAMINOPHEN")), protect
 DECLARE acetaminophenphenyltoloxamine_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "ACETAMINOPHENPHENYLTOLOXAMINE")), protect
 DECLARE acetaminophentramadol_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "ACETAMINOPHENTRAMADOL")), protect
 DECLARE acetaminophenbutalbital_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "ACETAMINOPHENBUTALBITAL")), protect
 DECLARE acetaminophendiphenhydramine_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "ACETAMINOPHENDIPHENHYDRAMINE")), protect
 DECLARE acetaminophenpentazocine_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "ACETAMINOPHENPENTAZOCINE")), protect
 DECLARE acetaminophenphenylephrine_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "ACETAMINOPHENPHENYLEPHRINE")), protect
 DECLARE acetaminophenpamabrom_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "ACETAMINOPHENPAMABROM")), protect
 DECLARE acetaminophenpseudoephedrine_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "ACETAMINOPHENPSEUDOEPHEDRINE")), protect
 DECLARE acetaminophencaffeine_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "ACETAMINOPHENCAFFEINE")), protect
 DECLARE acetaminophenchlorpheniramine_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "ACETAMINOPHENCHLORPHENIRAMINE")), protect
 DECLARE acetaminophendextromethorphan_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "ACETAMINOPHENDEXTROMETHORPHAN")), protect
 DECLARE acetaminophenguaifenesin_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "ACETAMINOPHENGUAIFENESIN")), protect
 DECLARE acetaminophenaspirin_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "ACETAMINOPHENASPIRIN")), protect
 DECLARE acetaminophenbutalbitalcaffeine_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "ACETAMINOPHENBUTALBITALCAFFEINE")), protect
 DECLARE apapbutalbitalcaffeinecodeine_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "APAPBUTALBITALCAFFEINECODEINE")), protect
 SET total_dose = 0.0
 SET bad_charting = 0
 SELECT INTO "nl:"
  ce.catalog_cd, ce.result_val, ce.result_units_cd,
  ce.result_status_cd, md.strength, md.strength_unit_cd,
  md.given_strength
  FROM medication_definition md,
   order_catalog_synonym ocs,
   orders o,
   clinical_event ce
  WHERE md.item_id=ocs.item_id
   AND ocs.synonym_id=o.synonym_id
   AND o.order_id=ce.order_id
   AND ce.encntr_id=trigger_encntrid
   AND (ce.event_end_dt_tm > (sysdate - 1))
   AND (ce.updt_dt_tm > (sysdate - 1))
   AND ce.event_class_cd=232
   AND ce.catalog_cd IN (apapbutalbitalcaffeinecodeine_var, acetaminophenbutalbitalcaffeine_var,
  acetaminophenaspirin_var, acetaminophenguaifenesin_var, acetaminophendextromethorphan_var,
  acetaminophenchlorpheniramine_var, acetaminophencaffeine_var, acetaminophenpseudoephedrine_var,
  acetaminophenpamabrom_var, acetaminophenphenylephrine_var,
  acetaminophenpentazocine_var, acetaminophendiphenhydramine_var, acetaminophenbutalbital_var,
  acetaminophentramadol_var, acetaminophenphenyltoloxamine_var,
  oxycodoneacetaminophen_var, acetaminophenpropoxyphene_var, acetaminophen_var,
  acetaminophenhydrocodone_var, acetaminophencodeine_var)
  DETAIL
   log_message = concat(log_message,"  ","Inside select")
   IF (ocs.item_id=0)
    IF (ce.result_units_cd=287
     AND  NOT (ce.result_status_cd IN (28, 29, 30, 31))
     AND ce.catalog_cd != acetaminophencodeine_var)
     total_dose = (total_dose+ cnvtreal(ce.result_val))
    ENDIF
    IF (ce.result_units_cd=287
     AND ce.result_status_cd IN (28, 29, 30, 31)
     AND ce.catalog_cd != acetaminophencodeine_var)
     total_dose = (total_dose - cnvtreal(ce.result_val))
    ENDIF
    IF (ce.result_units_cd=314
     AND  NOT (ce.result_status_cd IN (28, 29, 30, 31))
     AND ce.catalog_cd=acetaminophenpropoxyphene_var)
     total_dose = (total_dose+ (cnvtreal(ce.result_val) * 650))
    ENDIF
    IF (ce.result_units_cd=314
     AND ce.result_status_cd IN (28, 29, 30, 31)
     AND ce.catalog_cd=acetaminophenpropoxyphene_var)
     total_dose = (total_dose - (cnvtreal(ce.result_val) * 650))
    ENDIF
    IF (ce.result_units_cd=314
     AND  NOT (ce.result_status_cd IN (28, 29, 30, 31))
     AND ce.catalog_cd=acetaminophenhydrocodone_var)
     total_dose = (total_dose+ (cnvtreal(ce.result_val) * 500))
    ENDIF
    IF (ce.result_units_cd=314
     AND ce.result_status_cd IN (28, 29, 30, 31)
     AND ce.catalog_cd=acetaminophenhydrocodone_var)
     total_dose = (total_dose - (cnvtreal(ce.result_val) * 500))
    ENDIF
    IF (ce.result_units_cd IN (314, 643454)
     AND  NOT (ce.result_status_cd IN (28, 29, 30, 31))
     AND  NOT (ce.catalog_cd IN (acetaminophenpropoxyphene_var, acetaminophenhydrocodone_var)))
     total_dose = (total_dose+ (cnvtreal(ce.result_val) * 325))
    ENDIF
    IF (ce.result_units_cd IN (314, 643454)
     AND ce.result_status_cd IN (28, 29, 30, 31)
     AND  NOT (ce.catalog_cd IN (acetaminophenpropoxyphene_var, acetaminophenhydrocodone_var)))
     total_dose = (total_dose - (cnvtreal(ce.result_val) * 325))
    ENDIF
    IF (ce.result_units_cd=287
     AND  NOT (ce.result_status_cd IN (28, 29, 30, 31))
     AND ce.catalog_cd=acetaminophencodeine_var)
     total_dose = (total_dose+ (cnvtreal(ce.result_val) * 10))
    ENDIF
    IF (ce.result_units_cd=287
     AND ce.result_status_cd IN (28, 29, 30, 31)
     AND ce.catalog_cd=acetaminophencodeine_var)
     total_dose = (total_dose - (cnvtreal(ce.result_val) * 10))
    ENDIF
    IF ( NOT (ce.result_units_cd IN (314, 287, 643454)))
     bad_charting = (bad_charting+ 1)
    ENDIF
   ELSE
    IF (ce.result_units_cd != md.strength_unit_cd)
     bad_charting = (bad_charting+ 1)
    ENDIF
    IF (ce.result_units_cd=287
     AND md.strength_unit_cd=287
     AND  NOT (ce.result_status_cd IN (28, 29, 30, 31)))
     total_dose = (total_dose+ cnvtreal(ce.result_val))
    ENDIF
    IF (ce.result_units_cd=287
     AND md.strength_unit_cd=287
     AND ce.result_status_cd IN (28, 29, 30, 31))
     total_dose = (total_dose - cnvtreal(ce.result_val))
    ENDIF
    IF (((ce.result_units_cd=314
     AND md.strength_unit_cd=314) OR (((ce.result_units_cd=293
     AND md.strength_unit_cd=293) OR (ce.result_units_cd=643454
     AND md.strength_unit_cd=643454)) )) )
     this_dose = (cnvtreal(substring(1,findstring(" ",md.given_strength),md.given_strength)) * (
     cnvtreal(ce.result_val)/ cnvtreal(md.strength))), total_dose = (total_dose+ this_dose)
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SET retval = 0
 IF (total_dose >= 3000
  AND total_dose < 3500)
  SET retval = 100
  SET log_misc1 = concat(trim(cnvtstring(total_dose,11,0)),
   "mg of acetaminophen was charted over the past",
   " 24 hours. The maximum amount of acetaminophen in 24 hours is 4000mg.",
   " Consider contacting the provider if additional doses that will",
   " exceed the 24 hour maximum are required.")
  SET log_message = concat(log_message,"  ",
   "Acetaminophen rule total_dose >= 3000 AND total_dose < 3500 fired.")
 ENDIF
 IF (total_dose >= 3500)
  SET retval = 100
  SET log_misc1 = concat("*** CONTACT PHYSICIAN ***"," @NEWLINE ",trim(cnvtstring(total_dose,11,0)),
   "mg of ","acetaminophen was charted over the past 24 hours.",
   "The maximum amount of acetaminophen in 24 hours is 4000mg. ",
   "Contact the provider if the charted dose will exceed the 24 hour maximum.")
  SET log_message = concat(log_message,"  ","Acetaminophen rule total_dose >= 3500 fired.")
 ENDIF
END GO
