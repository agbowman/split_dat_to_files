CREATE PROGRAM cv_solcap_mpps
 SET stat = alterlist(reply->solcap,1)
 SET reply->solcap[1].identifier = "2011.2.00000.1"
 SELECT INTO "nl:"
  mpps_usage = im.value_char
  FROM im_configuration im
  WHERE im.parameter_name="ENABLE_MPPS_UPDATES_CARD"
  DETAIL
   reply->solcap[1].degree_of_use_str = mpps_usage
  WITH nocounter
 ;end select
END GO
