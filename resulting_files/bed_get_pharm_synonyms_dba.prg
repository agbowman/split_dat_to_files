CREATE PROGRAM bed_get_pharm_synonyms:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 synonyms[*]
      2 id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE pharm_cat_cd = f8 WITH public, noconstant(0.0)
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6000
    AND cv.cdf_meaning="PHARMACY"
    AND cv.active_ind=1)
  DETAIL
   pharm_cat_cd = cv.code_value
  WITH nocounter
 ;end select
 DECLARE pharm_act_cd = f8 WITH public, noconstant(0.0)
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=106
    AND cv.cdf_meaning="PHARMACY"
    AND cv.active_ind=1)
  DETAIL
   pharm_act_cd = cv.code_value
  WITH nocounter
 ;end select
 DECLARE brandname_cd = f8 WITH public, noconstant(0.0)
 DECLARE dcp_cd = f8 WITH public, noconstant(0.0)
 DECLARE dispdrug_cd = f8 WITH public, noconstant(0.0)
 DECLARE generictop_cd = f8 WITH public, noconstant(0.0)
 DECLARE ivname_cd = f8 WITH public, noconstant(0.0)
 DECLARE primary_cd = f8 WITH public, noconstant(0.0)
 DECLARE tradetop_cd = f8 WITH public, noconstant(0.0)
 DECLARE rxmnem_cd = f8 WITH public, noconstant(0.0)
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6011
    AND cv.cdf_meaning IN ("BRANDNAME", "DCP", "DISPDRUG", "GENERICTOP", "IVNAME",
   "PRIMARY", "TRADETOP", "RXMNEMONIC")
    AND cv.active_ind=1)
  DETAIL
   IF (cv.cdf_meaning="BRANDNAME")
    brandname_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="DCP")
    dcp_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="DISPDRUG")
    dispdrug_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="GENERICTOP")
    generictop_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="IVNAME")
    ivname_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="PRIMARY")
    primary_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="TRADETOP")
    tradetop_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="RXMNEMONIC")
    rxmnem_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET scnt = 0
 SELECT INTO "NL:"
  FROM order_catalog_synonym ocs
  WHERE ocs.catalog_type_cd=pharm_cat_cd
   AND ocs.activity_type_cd=pharm_act_cd
   AND ocs.mnemonic_type_cd IN (brandname_cd, dcp_cd, dispdrug_cd, generictop_cd, ivname_cd,
  primary_cd, tradetop_cd, rxmnem_cd)
   AND ocs.active_ind=1
  DETAIL
   scnt = (scnt+ 1), stat = alterlist(reply->synonyms,scnt), reply->synonyms[scnt].id = ocs
   .synonym_id
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
