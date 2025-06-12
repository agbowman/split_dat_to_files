CREATE PROGRAM dm_ocd_check_rev:dba
 SET ocd_version = 0.000
 SELECT INTO "nl:"
  df.schema_version
  FROM dm_features df
  WHERE df.feature_number IN (
  (SELECT
   do.feature_number
   FROM dm_ocd_features do,
    dm_alpha_features_env de
   WHERE (de.environment_id= $1)
    AND do.schema_ind=1
    AND do.alpha_feature_nbr=de.alpha_feature_nbr))
   AND df.feature_status="5"
  DETAIL
   IF (df.schema_version > ocd_version)
    ocd_version = df.schema_version
   ENDIF
  WITH nocounter
 ;end select
 SET to_version = 0.000
 SELECT INTO "nl:"
  FROM dm_environment de
  WHERE (de.environment_id= $1)
  DETAIL
   to_version = de.schema_version
  WITH nocounter
 ;end select
 IF (to_version < ocd_version)
  SELECT
   *
   FROM dual
   DETAIL
    col 10, "****************************************************************", row + 2,
    col 10, "THIS REV CANNOT BE INSTALLED!", row + 2,
    tempstr = build("HIGHEST OCD REV (",ocd_version,") IS HIGHER THAN THIS REV (",to_version,") ."),
    col 10, tempstr,
    row + 2, col 10, "****************************************************************",
    row + 2
   WITH nocounter, maxcol = 132, maxrow = 1
  ;end select
 ELSE
  SELECT
   *
   FROM dual
   DETAIL
    col 10, "****************************************************************", row + 2,
    col 10, "THIS REV CAN BE INSTALLED", row + 2,
    tempstr = build("HIGHEST OCD REV (",ocd_version,") IS LESS THAN THIS REV (",to_version,") ."),
    col 10, tempstr,
    row + 2, col 10, "****************************************************************",
    row + 2
   WITH nocounter, maxcol = 132, maxrow = 1
  ;end select
 ENDIF
END GO
