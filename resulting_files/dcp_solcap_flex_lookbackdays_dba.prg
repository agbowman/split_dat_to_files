CREATE PROGRAM dcp_solcap_flex_lookbackdays:dba
 SET modify = predeclare
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE clinicalvalidwtcd = f8 WITH protect, constant(uar_get_code_by("MEANING",4616007,
   "CLINVALIDWT"))
 DECLARE clinicalvalidhtcd = f8 WITH protect, constant(uar_get_code_by("MEANING",4616007,
   "CLINVALIDHT"))
 SET stat = alterlist(reply->solcap,1)
 SET reply->solcap[1].identifier = "JA2360.1"
 SET reply->solcap[1].degree_of_use_num = 0
 SELECT INTO "nl:"
  FROM clinical_validation cv
  WHERE cv.active_ind=1
   AND cv.measurement_type_cd IN (clinicalvalidwtcd, clinicalvalidhtcd)
  DETAIL
   reply->solcap[1].degree_of_use_num += 1
  WITH nocounter
 ;end select
END GO
