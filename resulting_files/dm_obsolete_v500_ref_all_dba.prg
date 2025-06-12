CREATE PROGRAM dm_obsolete_v500_ref_all:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET readme_data->status = "F"
 DECLARE indexsize = i4 WITH protect, noconstant(0)
 DECLARE tablesize = i4 WITH protect, noconstant(0)
 DECLARE funcsize = i4 WITH protect, noconstant(0)
 DECLARE parse_str = vc WITH protect, noconstant("")
 DECLARE triesloop = i4 WITH protect, noconstant(0)
 DECLARE listloop = i4 WITH protect, noconstant(0)
 DECLARE droptotal = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE errcode = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM dba_users du
  WHERE du.username="V500_REF"
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET readme_data->status = "S"
  SET readme_data->message = "Success.  V500_REF user has already been dropped."
  GO TO rdm_exit
 ENDIF
 SET parse_str = "rdb drop user V500_REF cascade go"
 CALL parser(parse_str)
 SELECT INTO "nl:"
  FROM dba_users du
  WHERE du.username="V500_REF"
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET readme_data->status = "S"
  SET readme_data->message = "Success.  V500_REF User successfully droped."
 ELSE
  SET readme_data->status = "F"
  IF (error(errmsg,0) != 0)
   SET readme_data->message = concat("Failure.  Unable to drop V500_REF user. ",errmsg)
  ELSE
   SET readme_data->message = "Failure.  Unable to drop V500_REF user."
  ENDIF
 ENDIF
#rdm_exit
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
