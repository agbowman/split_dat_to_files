CREATE PROGRAM dm_upd_dbprint_default_filter:dba
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
 SET readme_data->message = "Readme failed: starting script dm_upd_dbprint_default_filter..."
 DECLARE errmsg = vc WITH protect, noconstant("")
 FREE RECORD candidates
 RECORD candidates(
   1 qual[*]
     2 person_id = f8
 )
 SET cnt = 0
 SET stat = 0
 SELECT INTO "nl:"
  FROM application_ini ai
  PLAN (ai
   WHERE ai.application_number=5000
    AND ai.section="Favorites"
    AND  NOT ( EXISTS (
   (SELECT
    aft.person_id
    FROM application_ini aft
    WHERE aft.application_number=5000
     AND aft.section="FilterType"
     AND aft.person_id=ai.person_id))))
  DETAIL
   IF (ai.parameter_data != "MyFavorites=")
    cnt = (cnt+ 1), stat = alterlist(candidates->qual,cnt), candidates->qual[cnt].person_id = ai
    .person_id
   ENDIF
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  SET readme_data->message = concat("Readme failed: Error retrieving candidates: ",errmsg," . ")
  GO TO exit_script
 ENDIF
 IF (cnt=0)
  SET readme_data->status = "S"
  SET readme_data->message = concat("No rows need updating.")
  GO TO exit_script
 ENDIF
 INSERT  FROM application_ini ai,
   (dummyt d1  WITH seq = value(cnt))
  SET ai.application_number = 5000, ai.person_id = candidates->qual[d1.seq].person_id, ai.section =
   "FilterType",
   ai.parameter_data = concat("MyFilterType=FAVORITES",char(13)), ai.updt_dt_tm = cnvtdatetime(
    curdate,curtime3)
  PLAN (d1)
   JOIN (ai
   WHERE (ai.person_id=candidates->qual[d1.seq].person_id))
  WITH nocounter
 ;end insert
 IF (error(errmsg,0) > 0)
  SET readme_data->message = concat("Readme failed: Error inserting filter types for users: ",errmsg,
   " . ")
  ROLLBACK
  GO TO exit_script
 ELSE
  COMMIT
  SET readme_data->status = "S"
  SET readme_data->message = concat("Success: Readme performed all required tasks: ")
 ENDIF
#exit_script
 FREE RECORD candidates
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
