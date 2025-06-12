CREATE PROGRAM ecf_update_map_type_cd
 CALL echo("Updating cmt_cross_map_load table.....")
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
 SET readme_data->message = "Readme failed: starting script ecf_update_map_type_cd..."
 DECLARE errmsg = vc WITH protect, noconstant("")
 UPDATE  FROM cmt_cross_map_load l
  SET l.map_type_cd =
   (SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=29223
     AND cv.active_ind=1
     AND cv.cdf_meaning=l.map_type_mean)
  WHERE l.map_type_cd=0
  WITH nocounter
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("load table map_type_cd Update Failed",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 CALL echo("cmt_cross_map_load table updated.....")
 RECORD cross_maps(
   1 qual[*]
     2 concept_cki = vc
     2 target_concept_cki = vc
     2 map_type_cd = f8
     2 group_sequence = i2
 )
 CALL echo("Finding cmt_cross_map rows.....")
 SELECT INTO "nl:"
  FROM cmt_cross_map c,
   cmt_cross_map_load l
  PLAN (c
   WHERE c.map_type_cd=0)
   JOIN (l
   WHERE l.concept_cki=c.concept_cki
    AND l.target_concept_cki=c.target_concept_cki
    AND l.group_sequence=c.group_sequence)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(cross_maps->qual,cnt), cross_maps->qual[cnt].concept_cki = c
   .concept_cki,
   cross_maps->qual[cnt].target_concept_cki = c.target_concept_cki, cross_maps->qual[cnt].map_type_cd
    = l.map_type_cd, cross_maps->qual[cnt].group_sequence = c.group_sequence
  WITH nocounter
 ;end select
 SET exit_loop = 0
 SET loop_ctr = 0
 CALL echo(build2("Record count:  ",size(cross_maps->qual,5)))
 IF (size(cross_maps->qual,5) > 0)
  WHILE (exit_loop=0
   AND loop_ctr < 300)
    SET loop_ctr = (loop_ctr+ 1)
    CALL echo(concat("UPDATING MAP_TYPE_CD (GROUP: ",trim(cnvtstring(loop_ctr)),")"))
    UPDATE  FROM cmt_cross_map c,
      (dummyt d  WITH seq = size(cross_maps->qual,5))
     SET c.map_type_cd = cross_maps->qual[d.seq].map_type_cd, c.updt_dt_tm = cnvtdatetime(curdate,
       curtime3), c.updt_cnt = (c.updt_cnt+ 1),
      c.updt_applctx = 201906.10
     PLAN (d)
      JOIN (c
      WHERE (c.concept_cki=cross_maps->qual[d.seq].concept_cki)
       AND (c.target_concept_cki=cross_maps->qual[d.seq].target_concept_cki)
       AND (c.group_sequence=cross_maps->qual[d.seq].group_sequence))
     WITH nocounter, maxqual(c,75000)
    ;end update
    IF (curqual < 75000)
     SET exit_loop = 1
    ENDIF
    IF (error(errmsg,0) > 0)
     ROLLBACK
     SET readme_data->status = "F"
     SET readme_data->message = concat("CMT_CROSS_MAP map_type_cd Update Failed",errmsg)
     GO TO exit_script
    ELSE
     COMMIT
    ENDIF
  ENDWHILE
 ENDIF
 CALL echo("cmt_cross_map rows updated")
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme performed all required tasks"
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
