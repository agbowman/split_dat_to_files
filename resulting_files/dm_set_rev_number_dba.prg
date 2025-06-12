CREATE PROGRAM dm_set_rev_number:dba
 SET sdate =  $1
 SET status = cnvtlower( $2)
 SET sversion = cnvtreal(0)
 SELECT INTO "nl:"
  d.schema_version
  FROM dm_schema_version d
  WHERE d.schema_date=cnvtdatetime(sdate)
  DETAIL
   sversion = d.schema_version
  WITH nocounter
 ;end select
 UPDATE  FROM dm_features df
  SET df.schema_version = 0.0
  WHERE df.schema_version=sversion
  WITH nocounter
 ;end update
 IF (status="2d")
  UPDATE  FROM dm_features df
   SET df.schema_version = sversion
   WHERE df.feature_status="2d"
    AND df.schema_version=0.0
   WITH nocounter
  ;end update
 ENDIF
 IF (status="5")
  UPDATE  FROM dm_features df
   SET df.schema_version = sversion
   WHERE df.feature_status="5"
    AND df.schema_version=0.0
   WITH nocounter
  ;end update
 ENDIF
 COMMIT
END GO
