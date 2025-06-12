CREATE PROGRAM dcp_upd_apache_ref:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = vc
       3 operationstatus = c1
       3 targetobjectname = vc
       3 targetobjectvalue = vc
 )
 DECLARE meaning_code(p1,p2) = f8
 EXECUTE FROM 1000_initialize TO 1099_initialize_exit
 EXECUTE FROM 2000_process TO 2099_process_exit
 GO TO 9999_exit_program
 SUBROUTINE meaning_code(mc_codeset,mc_meaning)
   SET mc_code = 0.0
   SET mc_text = fillstring(12," ")
   SET mc_text = mc_meaning
   SET mc_stat = uar_get_meaning_by_codeset(mc_codeset,mc_text,1,mc_code)
   IF (mc_code > 0.0)
    RETURN(mc_code)
   ELSE
    RETURN(- (1.0))
   ENDIF
 END ;Subroutine
#1000_initialize
 SET reply->status_data.status = "F"
 SET risk_adjustment_ref_id = 0.0
 SET cnt = 0
#1099_initialize_exit
#2000_process
 IF ((request->risk_adjustment_ref_id > 0.0))
  SET risk_adjustment_ref_id = request->risk_adjustment_ref_id
  EXECUTE FROM 2100_update_ref TO 2199_update_ref_exit
 ELSE
  EXECUTE FROM 2200_write_ref TO 2299_write_ref_exit
 ENDIF
 EXECUTE FROM 2300_locations TO 2399_locations_exit
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#2099_process_exit
#2100_update_ref
 UPDATE  FROM risk_adjustment_ref rar
  SET rar.organization_id = request->org_id, rar.region_flag = request->region_flag, rar.bed_count =
   request->bedcount,
   rar.teach_type_flag = request->teach_type_flag, rar.icu_day_start_time = request->icu_day_start_tm,
   rar.accept_worst_lab_ind = request->accept_worst_lab_ind,
   rar.accept_worst_vitals_ind = request->accept_worst_vitals_ind, rar.accept_urine_output_ind =
   request->accept_urine_output_ind, rar.accept_tiss_acttx_if_ind = request->accept_tiss_acttx_if_ind,
   rar.accept_tiss_nonacttx_if_ind = request->accept_tiss_nonacttx_if_ind, rar
   .auto_calc_intubated_ind = request->auto_calc_intubated_ind, rar.updt_id = reqinfo->updt_id,
   rar.updt_dt_tm = cnvtdatetime(curdate,curtime), rar.updt_applctx = reqinfo->updt_applctx, rar
   .updt_task = reqinfo->updt_task,
   rar.updt_cnt = (rar.updt_cnt+ 1)
  WHERE rar.risk_adjustment_ref_id=risk_adjustment_ref_id
  WITH nocounter
 ;end update
#2199_update_ref_exit
#2200_write_ref
 SET risk_adjustment_ref_id = 0.0
 SELECT INTO "nl:"
  j = seq(carenet_seq,nextval)
  FROM dual
  DETAIL
   risk_adjustment_ref_id = cnvtreal(j)
  WITH format, nocounter
 ;end select
 IF (risk_adjustment_ref_id=0)
  CALL echo("risk_adjustment_ref_id error")
  SET failed_ind = "Y"
  SET failed_text = "Error reading from carenet sequence."
 ENDIF
 CALL echo(build("rar_id:",risk_adjustment_ref_id))
 INSERT  FROM risk_adjustment_ref rar
  SET rar.risk_adjustment_ref_id = risk_adjustment_ref_id, rar.organization_id = request->org_id, rar
   .region_flag = request->region_flag,
   rar.bed_count = request->bedcount, rar.teach_type_flag = request->teach_type_flag, rar
   .icu_day_start_time = request->icu_day_start_tm,
   rar.accept_worst_lab_ind = request->accept_worst_lab_ind, rar.accept_worst_vitals_ind = request->
   accept_worst_vitals_ind, rar.accept_urine_output_ind = request->accept_urine_output_ind,
   rar.accept_tiss_acttx_if_ind = request->accept_tiss_acttx_if_ind, rar.accept_tiss_nonacttx_if_ind
    = request->accept_tiss_nonacttx_if_ind, rar.auto_calc_intubated_ind = request->
   auto_calc_intubated_ind,
   rar.active_ind = 1, rar.active_status_dt_tm = cnvtdatetime(curdate,curtime), rar
   .active_status_prsnl_id = reqinfo->updt_id,
   rar.active_status_cd = reqdata->active_status_cd, rar.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   rar.updt_id = reqinfo->updt_id,
   rar.updt_task = reqinfo->updt_task, rar.updt_applctx = reqinfo->updt_applctx, rar.updt_cnt = 0
  WITH nocounter
 ;end insert
#2299_write_ref_exit
#2300_locations
 IF ((request->risk_adjustment_ref_id > 0.0))
  UPDATE  FROM location l
   SET l.icu_ind = 0
   PLAN (l
    WHERE (l.organization_id=request->org_id)
     AND l.icu_ind=1)
   WITH nocounter
  ;end update
 ENDIF
 SET cnt = size(request->location_list,5)
 FOR (x = 1 TO cnt)
   UPDATE  FROM location l
    SET l.icu_ind = 1, l.updt_dt_tm = cnvtdatetime(curdate,curtime3), l.updt_id = reqinfo->updt_id,
     l.updt_task = reqinfo->updt_task, l.updt_applctx = reqinfo->updt_applctx, l.updt_cnt = (l
     .updt_cnt+ 1)
    PLAN (l
     WHERE (l.location_cd=request->location_list[x].location_cd))
    WITH nocounter
   ;end update
 ENDFOR
#2399_locations_exit
#9999_exit_program
 CALL echorecord(reply)
END GO
