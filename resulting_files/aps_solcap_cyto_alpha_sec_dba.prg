CREATE PROGRAM aps_solcap_cyto_alpha_sec:dba
 DECLARE solcap_cnt = i4 WITH protect, noconstant(0)
 DECLARE other_cnt = i4 WITH protect, noconstant(0)
 SET solcap_cnt = (solcap_cnt+ 1)
 SET stat = alterlist(reply->solcap,1)
 SET reply->solcap[solcap_cnt].identifier = "2010.2.00084.2"
 SET reply->solcap[solcap_cnt].degree_of_use_num = 0
 SET reply->solcap[solcap_cnt].distinct_user_count = 0
 SET reply->solcap[solcap_cnt].degree_of_use_str = "NO"
 SET other_cnt = (other_cnt+ 1)
 SET stat = alterlist(reply->solcap[solcap_cnt].other,1)
 SET stat = alterlist(reply->solcap[solcap_cnt].other[other_cnt].value,2)
 SET reply->solcap[solcap_cnt].other[other_cnt].category_name =
 "Service Resource specific parameters defined?"
 SET reply->solcap[solcap_cnt].other[other_cnt].value[1].display = "Cyto Alpha Security parameters"
 SET reply->solcap[solcap_cnt].other[other_cnt].value[2].display = "Follow-up Tracking parameters"
 SET reply->solcap[solcap_cnt].other[other_cnt].value[1].value_str = "NO"
 SET reply->solcap[solcap_cnt].other[other_cnt].value[2].value_str = "NO"
 SELECT INTO "nl:"
  cas.service_resource_cd, cas.definition_ind
  FROM cyto_alpha_security cas
  WHERE cas.service_resource_cd > 0
   AND cas.definition_ind IN (0, 1)
  DETAIL
   reply->solcap[solcap_cnt].other[other_cnt].value[1].value_str = "YES", reply->solcap[solcap_cnt].
   degree_of_use_str = "YES"
  WITH nocounter, maxrec = 1
 ;end select
 SELECT INTO "nl:"
  cas.service_resource_cd, cas.definition_ind
  FROM cyto_alpha_security cas
  WHERE cas.service_resource_cd > 0
   AND cas.definition_ind IN (0, 2)
  DETAIL
   reply->solcap[solcap_cnt].other[other_cnt].value[2].value_str = "YES", reply->solcap[solcap_cnt].
   degree_of_use_str = "YES"
  WITH nocounter, maxrec = 1
 ;end select
END GO
