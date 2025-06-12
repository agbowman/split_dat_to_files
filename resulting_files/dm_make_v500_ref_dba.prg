CREATE PROGRAM dm_make_v500_ref:dba
 SELECT INTO "nl:"
  d.username
  FROM dba_users d
  WHERE d.username="V500_REF"
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL parser("rdb create user v500_ref identified by v500_ref")
  CALL parser("default tablespace d_v500_ref_data")
  CALL parser("temporary tablespace d_v500_ref_data go")
  CALL parser("rdb grant dba to v500_ref go")
 ENDIF
END GO
