CREATE PROGRAM dcp_add_charting_agent_readme:dba
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
 DECLARE powerformcd = f8 WITH noconstant(0.0)
 DECLARE dcpformsref = c13 WITH constant("DCP_FORMS_REF")
 DECLARE curqualtotal = i4
 SET curqualtotal = 0
 SET readme_data->status = "F"
 RECORD qualdata(
   1 qual[*]
     2 task_charting_agent_r_id = f8
     2 reference_task_id = f8
     2 dcp_forms_ref_id = f8
 ) WITH public
 DECLARE qualrows = i4
 SET qualrows = 0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=255090
   AND cv.cdf_meaning="POWERFORM"
  DETAIL
   powerformcd = cv.code_value
  WITH nocounter
 ;end select
 IF (((curqual=0) OR (powerformcd <= 0.0)) )
  SET readme_data->message =
  "FAILURE - The code value for POWERFORM in code set 255090 was not found"
  GO TO exit_script
 ENDIF
 SELECT DISTINCT INTO "nl:"
  ot.reference_task_id, ot.dcp_forms_ref_id
  FROM order_task ot
  WHERE ot.reference_task_id > 0.0
   AND  NOT ( EXISTS (
  (SELECT
   tcar.reference_task_id, tcar.charting_agent_entity_name, tcar.charting_agent_entity_id
   FROM task_charting_agent_r tcar
   WHERE tcar.reference_task_id=ot.reference_task_id
    AND tcar.charting_agent_entity_name="DCP_FORMS_REF"
    AND tcar.charting_agent_entity_id=ot.dcp_forms_ref_id
   WITH nocounter)))
  HEAD REPORT
   stat = alterlist(qualdata->qual,100)
  DETAIL
   IF (ot.dcp_forms_ref_id > 0.0)
    qualrows = (qualrows+ 1)
    IF (qualrows > size(qualdata->qual,5))
     stat = alterlist(qualdata->qual,(qualrows+ 100))
    ENDIF
    qualdata->qual[qualrows].reference_task_id = ot.reference_task_id, qualdata->qual[qualrows].
    dcp_forms_ref_id = ot.dcp_forms_ref_id
   ENDIF
  FOOT REPORT
   stat = alterlist(qualdata->qual,qualrows)
  WITH nocounter
 ;end select
 FOR (i = 1 TO qualrows)
   SELECT INTO "nl:"
    refseq = seq(reference_seq,nextval)
    FROM dual
    DETAIL
     qualdata->qual[i].task_charting_agent_r_id = refseq
    WITH nocounter
   ;end select
 ENDFOR
 IF (qualrows > 0)
  DECLARE commitpass = i4
  DECLARE maxcommit = i4
  DECLARE numberofcommits = i4
  DECLARE startindex = i4
  DECLARE endindex = i4
  SET commitpass = 1
  SET maxcommit = 5000
  SET numberofcommits = ceil((cnvtreal(qualrows)/ cnvtreal(maxcommit)))
  SET startindex = 0
  SET endindex = 0
  FOR (commitpass = 1 TO numberofcommits)
    SET startindex = (endindex+ 1)
    IF (commitpass=numberofcommits)
     SET endindex = qualrows
    ELSE
     SET endindex = (maxcommit * commitpass)
    ENDIF
    INSERT  FROM task_charting_agent_r tcar,
      (dummyt d  WITH seq = value(qualrows))
     SET tcar.task_charting_agent_r_id = qualdata->qual[d.seq].task_charting_agent_r_id, tcar
      .reference_task_id = qualdata->qual[d.seq].reference_task_id, tcar.charting_agent_cd =
      powerformcd,
      tcar.charting_agent_entity_name = dcpformsref, tcar.charting_agent_entity_id = qualdata->qual[d
      .seq].dcp_forms_ref_id, tcar.updt_applctx = 0,
      tcar.updt_cnt = 0, tcar.updt_dt_tm = cnvtdatetime(curdate,curtime3), tcar.updt_id = 0,
      tcar.updt_task = 0
     PLAN (d
      WHERE d.seq >= startindex
       AND d.seq <= endindex)
      JOIN (tcar)
     WITH nocounter
    ;end insert
    SET curqualtotal = (curqualtotal+ curqual)
    COMMIT
  ENDFOR
 ENDIF
 FREE RECORD qualdata
 UPDATE  FROM task_charting_agent_r tcar
  SET tcar.charting_agent_cd = powerformcd
  WHERE tcar.charting_agent_cd <= 0
  WITH nocounter
 ;end update
 DECLARE errmsg = c132
 SET errmsg = fillstring(132," ")
 IF (((error(errmsg,0) != 0) OR (qualrows != curqualtotal)) )
  SET readme_data->status = "F"
  SET readme_data->message = concat("FAILURE - There was an error inserting order_task ",
   "rows into the task_charting_agent_r table.  ",build(" ",curqualtotal),"/",build(" ",qualrows),
   " rows were written.")
 ELSE
  SET readme_data->status = "S"
  IF (qualrows=0)
   SET readme_data->message = concat("SUCCESS - All distinct rows on the order_task ",
    "table are already on the task_charting_agent_r table.")
  ELSE
   SET readme_data->message = concat("SUCCESS - All distinct order_task rows were ",
    "successfully inserted into the task_charting_agent_r table.")
  ENDIF
 ENDIF
#exit_script
 IF ((readme_data->readme_id > 0))
  EXECUTE dm_readme_status
  COMMIT
 ELSE
  CALL echo("")
  CALL echo("*******************************************************************************")
  CALL echo(readme_data->message)
  CALL echo("*******************************************************************************")
  CALL echo("")
  EXECUTE dm_readme_status
  COMMIT
 ENDIF
END GO
