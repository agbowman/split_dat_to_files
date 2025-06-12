CREATE PROGRAM cps_remove_fenton_charts:dba
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE errormsg = vc WITH protect, noconstant("")
 DECLARE fenton_cd = f8 WITH protect, noconstant(0.0)
 DECLARE fenton_cnt = i4 WITH protect, noconstant(0)
 DECLARE fenton_hist_cnt = i4 WITH protect, noconstant(0)
 FREE RECORD fenton_charts
 RECORD fenton_charts(
   1 id_list[*]
     2 id = f8
 )
 FREE RECORD fenton_charts_hist
 RECORD fenton_charts_hist(
   1 id_list[*]
     2 id = f8
 )
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=255550
   AND cv.display_key="FENTON"
   AND cv.active_ind=1
  DETAIL
   fenton_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  SET errormsg = concat("Failed to select fenton code value: ",errmsg)
  GO TO exit_script
 ENDIF
 IF (fenton_cd <= 0.0)
  SET errormsg = "Code value for FENTON not found."
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  c.chart_definition_id
  FROM chart_definition_hist c
  WHERE c.chart_source_cd=fenton_cd
   AND c.active_ind=1
  HEAD REPORT
   stat = alterlist(fenton_charts_hist->id_list,10), count = 0
  DETAIL
   count = (count+ 1)
   IF (count > 10
    AND mod(count,10)=1)
    stat = alterlist(fenton_charts->id_list,(count+ 9))
   ENDIF
   fenton_charts_hist->id_list[count].id = c.chart_definition_id
  FOOT REPORT
   stat = alterlist(fenton_charts_hist->id_list,count)
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  SET errormsg = concat("Failed to get ids from CHART_DEFINITION_HIST table: ",errmsg)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  c.chart_definition_id
  FROM chart_definition c
  WHERE c.chart_source_cd=fenton_cd
   AND c.active_ind=1
  HEAD REPORT
   stat = alterlist(fenton_charts->id_list,10), count = 0
  DETAIL
   count = (count+ 1)
   IF (count > 10
    AND mod(count,10)=1)
    stat = alterlist(fenton_charts->id_list,(count+ 9))
   ENDIF
   fenton_charts->id_list[count].id = c.chart_definition_id
  FOOT REPORT
   stat = alterlist(fenton_charts->id_list,count)
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  SET errormsg = concat("Failed to get ids from CHART_DEFINITION table: ",errmsg)
  GO TO exit_script
 ENDIF
 SET fenton_cnt = size(fenton_charts->id_list,5)
 IF (fenton_cnt=0)
  SET errormsg = "No fenton charts to remove."
  GO TO exit_script
 ENDIF
 SET fenton_hist_cnt = size(fenton_charts_hist->id_list,5)
 IF (fenton_hist_cnt > 0)
  DELETE  FROM ref_datapoint_hist rd
   WHERE (rd.ref_dataset_id=
   (SELECT
    r.ref_dataset_id
    FROM ref_dataset_hist r
    WHERE (r.chart_definition_id=
    (SELECT
     c.chart_definition_id
     FROM chart_definition_hist c
     WHERE c.chart_source_cd=fenton_cd
      AND c.active_ind=1))))
   WITH nocounter
  ;end delete
  IF (error(errmsg,0) > 0)
   ROLLBACK
   SET errormsg = concat("Failed to delete from REF_DATAPOINT_HIST: ",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
 ENDIF
 DELETE  FROM ref_datapoint rd
  WHERE (rd.ref_dataset_id=
  (SELECT
   r.ref_dataset_id
   FROM ref_dataset r
   WHERE (r.chart_definition_id=
   (SELECT
    c.chart_definition_id
    FROM chart_definition c
    WHERE c.chart_source_cd=fenton_cd
     AND c.active_ind=1))))
  WITH nocounter
 ;end delete
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET errormsg = concat("Failed to delete from REF_DATAPOINT: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 IF (fenton_hist_cnt > 0)
  DELETE  FROM ref_dataset_hist r,
    (dummyt d  WITH seq = value(fenton_hist_cnt))
   SET r.seq = 1
   PLAN (d)
    JOIN (r
    WHERE (r.chart_definition_id=fenton_charts_hist->id_list[d.seq].id))
   WITH nocounter
  ;end delete
  IF (error(errmsg,0) > 0)
   ROLLBACK
   SET errormsg = concat("Failed to delete from REF_DATASET_HIST: ",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
 ENDIF
 DELETE  FROM ref_dataset r,
   (dummyt d  WITH seq = value(fenton_cnt))
  SET r.seq = 1
  PLAN (d)
   JOIN (r
   WHERE (r.chart_definition_id=fenton_charts->id_list[d.seq].id))
  WITH nocounter
 ;end delete
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET errormsg = concat("Failed to delete from REF_DATASET: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 IF (fenton_hist_cnt > 0)
  DELETE  FROM ref_datastats_hist r,
    (dummyt d  WITH seq = value(fenton_hist_cnt))
   SET r.seq = 1
   PLAN (d)
    JOIN (r
    WHERE (r.chart_definition_id=fenton_charts_hist->id_list[d.seq].id))
   WITH nocounter
  ;end delete
  IF (error(errmsg,0) > 0)
   ROLLBACK
   SET errormsg = concat("Failed to delete from REF_DATASTATS_HIST: ",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
 ENDIF
 DELETE  FROM ref_datastats r,
   (dummyt d  WITH seq = value(fenton_cnt))
  SET r.seq = 1
  PLAN (d)
   JOIN (r
   WHERE (r.chart_definition_id=fenton_charts->id_list[d.seq].id))
  WITH nocounter
 ;end delete
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET errormsg = concat("Failed to delete from REF_DATASTATS: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 DELETE  FROM chart_definition_hist c
  WHERE c.chart_source_cd=fenton_cd
   AND c.active_ind=1
  WITH nocounter
 ;end delete
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET errormsg = concat("Failed to delete from CHART_DEFINITION_HIST: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 DELETE  FROM chart_definition c
  WHERE c.chart_source_cd=fenton_cd
   AND c.active_ind=1
  WITH nocounter
 ;end delete
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET errormsg = concat("Failed to delete from CHART_DEFINITION: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET errormsg = "Success: Removed Fenton growth charts from database."
#exit_script
 FREE RECORD fenton_charts
 FREE RECORD fenton_charts_hist
 CALL echo(errormsg)
END GO
