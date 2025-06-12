CREATE PROGRAM dcp_solcap_prefer_strength:dba
 SET stat = alterlist(reply->solcap,1)
 SET reply->solcap[1].identifier = "2012.1.00103.1"
 SET reply->solcap[1].degree_of_use_num = 0
 SELECT INTO "nl:"
  FROM order_catalog_synonym ocs
  WHERE validate(ocs.preferred_dose_flag,0) > 0
   AND ocs.active_ind=1
  DETAIL
   reply->solcap[1].degree_of_use_num += 1
  WITH nocounter
 ;end select
 SET last_mod = "001"
END GO
