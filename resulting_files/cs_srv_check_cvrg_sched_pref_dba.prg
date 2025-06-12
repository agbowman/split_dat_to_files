CREATE PROGRAM cs_srv_check_cvrg_sched_pref:dba
 CALL echo(build("Begin cs_srv_check_cvrg_sched_pref, version [",nullterm("467952.001"),"]"))
 SET reply->status_data.status = "F"
 SET reply->cvrg_preference = "Y"
 IF ( NOT (validate(dm_info_domain)))
  DECLARE dm_info_domain = vc WITH protect, constant("CHARGE SERVICES")
 ENDIF
 IF ( NOT (validate(dm_info_name)))
  DECLARE dm_info_name = vc WITH protect, constant("STORE CHARGE CVRG SCHED INFO")
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain=dm_info_domain
   AND di.info_name=dm_info_name
  DETAIL
   reply->cvrg_preference = di.info_char
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
 IF ((g_srvproperties->logreqrep=1))
  CALL echorecord(reply)
 ENDIF
END GO
