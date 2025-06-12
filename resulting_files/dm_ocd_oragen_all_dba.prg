CREATE PROGRAM dm_ocd_oragen_all:dba
 DECLARE obj_passivity = i2
 SET obj_passivity = 0
 SELECT INTO "nl:"
  FROM dm_alpha_features_env doe,
   dm_info di
  WHERE di.info_domain="DATA MANAGEMENT"
   AND di.info_name="DM_ENV_ID"
   AND doe.environment_id=di.info_number
   AND (doe.alpha_feature_nbr= $1)
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("***")
  CALL echo(build("*** DM_OCD_ORAGEN_ALL: OCD (", $1,") not found in this environment!"))
  CALL echo("***")
  GO TO end_program
 ENDIF
 FREE RECORD tables
 RECORD tables(
   1 count = i4
   1 t[*]
     2 name = vc
 )
 SET tables->count = 0
 SET stat = alterlist(tables->t,0)
 SELECT INTO "nl:"
  l.attr_name
  FROM dtableattr a,
   dtableattrl l
  WHERE a.table_name="DM_CB_OBJECTS"
  DETAIL
   obj_passivity = 1
  WITH nocounter
 ;end select
 IF (obj_passivity=1)
  SELECT INTO "nl:"
   FROM user_tab_columns u
   WHERE u.table_name="DM_CB_OBJECTS"
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET obj_passivity = 0
  ENDIF
 ENDIF
 SELECT
  IF (obj_passivity=1)INTO "nl:"
   FROM dm_afd_tables d
   WHERE (d.alpha_feature_nbr= $1)
    AND  NOT ( EXISTS (
   (SELECT
    o.object_name
    FROM dm_cb_objects o
    WHERE o.object_type="TABLE"
     AND o.object_status="DROP"
     AND o.active_ind=1
     AND o.object_name=d.table_name)))
  ELSE INTO "nl:"
   FROM dm_afd_tables d
   WHERE (d.alpha_feature_nbr= $1)
  ENDIF
  HEAD REPORT
   cnt = 0
  DETAIL
   tables->count = (tables->count+ 1), cnt = tables->count, stat = alterlist(tables->t,cnt),
   tables->t[cnt].name = d.table_name
  WITH nocounter
 ;end select
 SET tbl_cnt = 0
 FOR (tbl_cnt = 1 TO tables->count)
   CALL parser(concat("execute oragen3 '",trim(tables->t[tbl_cnt].name),"' go"),1)
 ENDFOR
#end_program
END GO
