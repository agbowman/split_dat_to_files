CREATE PROGRAM cps_get_chart_def:dba
 RECORD reply(
   1 chart_definition_id = f8
   1 chart_source_cd = f8
   1 chart_type_cd = f8
   1 chart_title = vc
   1 sex_cd = f8
   1 min_age = f8
   1 max_age = f8
   1 x_type_cd = f8
   1 y_type_cd = f8
   1 y_axis_min_val = f8
   1 y_axis_max_val = f8
   1 y_axis_unit_cd = f8
   1 x_axis_section1_min_val = f8
   1 x_axis_section1_max_val = f8
   1 x_axis_section2_min_val = f8
   1 x_axis_section2_max_val = f8
   1 x_axis_section2_multiplier = f8
   1 x_axis_section1_unit_cd = f8
   1 x_axis_section2_unit_cd = f8
   1 version = vc
   1 beg_effective_dt_tm = dq8
   1 end_effective_dt_tm = dq8
   1 last_action_seq = i4
   1 dataset_cnt = i4
   1 dataset[*]
     2 ref_dataset_id = f8
     2 display_name = vc
     2 display_type_cd = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 last_action_seq = i4
     2 datapoint_cnt = i4
     2 datapoint[*]
       3 ref_datapoint_id = f8
       3 x_val = f8
       3 y_val = f8
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 last_action_seq = i4
   1 datastat_cnt = i4
   1 datastat[*]
     2 ref_datastats_id = f8
     2 x_min_val = f8
     2 x_max_val = f8
     2 median_value = f8
     2 mean_value = f8
     2 coeffnt_var_value = f8
     2 std_dev_value = f8
     2 box_cox_power_value = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 last_action_seq = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SET ierrcode = error(serrmsg,1)
 SELECT INTO "NL:"
  rds.ref_dataset_id, rdp.x_val
  FROM chart_definition chd,
   ref_dataset rds,
   ref_datapoint rdp
  PLAN (chd
   WHERE (chd.chart_definition_id=request->chart_definition_id))
   JOIN (rds
   WHERE rds.chart_definition_id=outerjoin(chd.chart_definition_id)
    AND rds.active_ind=outerjoin(1))
   JOIN (rdp
   WHERE rdp.ref_dataset_id=outerjoin(rds.ref_dataset_id)
    AND rdp.active_ind=outerjoin(1))
  ORDER BY rds.ref_dataset_id, rdp.x_val
  HEAD REPORT
   knt = 0, reply->chart_definition_id = chd.chart_definition_id, reply->chart_source_cd = chd
   .chart_source_cd,
   reply->chart_type_cd = chd.chart_type_cd, reply->sex_cd = chd.sex_cd, reply->min_age = chd.min_age,
   reply->max_age = chd.max_age, reply->chart_title = chd.chart_title, reply->x_type_cd = chd
   .x_type_cd,
   reply->y_type_cd = chd.y_type_cd, reply->y_axis_min_val = chd.y_axis_min_val, reply->
   y_axis_max_val = chd.y_axis_max_val,
   reply->y_axis_unit_cd = chd.y_axis_unit_cd, reply->x_axis_section1_min_val = chd
   .x_axis_section1_min_val, reply->x_axis_section1_max_val = chd.x_axis_section1_max_val,
   reply->x_axis_section2_min_val = chd.x_axis_section2_min_val, reply->x_axis_section2_max_val = chd
   .x_axis_section2_max_val, reply->x_axis_section2_multiplier = chd.x_axis_section2_multiplier,
   reply->x_axis_section1_unit_cd = chd.x_axis_section1_unit_cd, reply->x_axis_section2_unit_cd = chd
   .x_axis_section2_unit_cd, reply->version = chd.version,
   reply->beg_effective_dt_tm = chd.beg_effective_dt_tm, reply->end_effective_dt_tm = chd
   .end_effective_dt_tm, reply->last_action_seq = chd.last_action_seq
  HEAD rds.ref_dataset_id
   knt = (knt+ 1)
   IF (mod(knt,10)=1)
    stat = alterlist(reply->dataset,(knt+ 10))
   ENDIF
   reply->dataset[knt].ref_dataset_id = rds.ref_dataset_id, reply->dataset[knt].display_name = rds
   .display_name, reply->dataset[knt].display_type_cd = rds.display_type_cd,
   reply->dataset[knt].beg_effective_dt_tm = rds.beg_effective_dt_tm, reply->dataset[knt].
   end_effective_dt_tm = rds.end_effective_dt_tm, reply->dataset[knt].last_action_seq = rds
   .last_action_seq,
   rknt = 0
  DETAIL
   rknt = (rknt+ 1)
   IF (mod(rknt,10)=1)
    stat = alterlist(reply->dataset[knt].datapoint,(rknt+ 10))
   ENDIF
   reply->dataset[knt].datapoint[rknt].ref_datapoint_id = rdp.ref_datapoint_id, reply->dataset[knt].
   datapoint[rknt].x_val = rdp.x_val, reply->dataset[knt].datapoint[rknt].y_val = rdp.y_val,
   reply->dataset[knt].datapoint[rknt].beg_effective_dt_tm = rdp.beg_effective_dt_tm, reply->dataset[
   knt].datapoint[rknt].end_effective_dt_tm = rdp.end_effective_dt_tm, reply->dataset[knt].datapoint[
   rknt].last_action_seq = rdp.last_action_seq
  FOOT  rds.ref_dataset_id
   reply->dataset[knt].datapoint_cnt = rknt, stat = alterlist(reply->dataset[knt].datapoint,rknt)
  FOOT REPORT
   reply->dataset_cnt = knt, stat = alterlist(reply->dataset,knt)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "CHART_DEFINITION"
  GO TO exit_script
 ENDIF
 SELECT INTO "NL:"
  FROM ref_datastats rdst
  PLAN (rdst
   WHERE (rdst.chart_definition_id=request->chart_definition_id)
    AND rdst.active_ind=1)
  ORDER BY rdst.x_min_val, rdst.x_max_val
  HEAD REPORT
   knt = 0
  DETAIL
   knt = (knt+ 1)
   IF (mod(knt,10)=1)
    stat = alterlist(reply->datastat,(knt+ 10))
   ENDIF
   reply->datastat[knt].ref_datastats_id = rdst.ref_datastats_id, reply->datastat[knt].x_min_val =
   rdst.x_min_val, reply->datastat[knt].x_max_val = rdst.x_max_val,
   reply->datastat[knt].median_value = rdst.median_value, reply->datastat[knt].mean_value = rdst
   .mean_value, reply->datastat[knt].coeffnt_var_value = rdst.coeffnt_var_value,
   reply->datastat[knt].std_dev_value = rdst.std_dev_value, reply->datastat[knt].box_cox_power_value
    = rdst.box_cox_power_value, reply->datastat[knt].beg_effective_dt_tm = rdst.beg_effective_dt_tm,
   reply->datastat[knt].end_effective_dt_tm = rdst.end_effective_dt_tm, reply->datastat[knt].
   last_action_seq = rdst.last_action_seq
  FOOT REPORT
   reply->datastat_cnt = knt, stat = alterlist(reply->datastat,knt)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "REF_DATASTATS"
  GO TO exit_script
 ENDIF
#exit_script
 CALL echo("***")
 CALL echo("***   Exit Script")
 CALL echo("***")
 IF (failed != false)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  IF (failed=select_error)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=insert_error)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=input_error)
   SET reply->status_data.subeventstatus[1].operationname = "VALIDATION"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSE
   SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
