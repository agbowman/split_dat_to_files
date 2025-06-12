CREATE PROGRAM dm_afd_insert_env:dba
 SET envid = 0
 SELECT INTO "nl:"
  d.environment_id
  FROM dm_environment d
  WHERE d.environment_name=env_name
  DETAIL
   envid = d.environment_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("Invalid Environment Name")
  GO TO end_prg
 ENDIF
 UPDATE  FROM dm_alpha_features_env
  SET start_dt_tm = cnvtdatetime(curdate,curtime3), end_dt_tm = cnvtdatetime("31-DEC-2100"), status
    = "WORKING"
  WHERE (alpha_feature_nbr=request->afdnumber)
   AND environment_id=envid
  WITH nocounter
 ;end update
 IF (curqual=0)
  INSERT  FROM dm_alpha_features_env
   (alpha_feature_nbr, environment_id, start_dt_tm,
   end_dt_tm, status)
   VALUES(request->afdnumber, envid, cnvtdatetime(curdate,curtime3),
   cnvtdatetime("31-DEC-2100"), "WORKING")
  ;end insert
 ENDIF
 COMMIT
#end_prg
END GO
