CREATE PROGRAM bbd_get_act_donation_procs:dba
 RECORD reply(
   1 qual[*]
     2 code_value = f8
     2 cdf_meaning = vc
     2 display = vc
     2 description = vc
     2 definition = vc
     2 code_collation_seq = i2
     2 code_active_ind = i2
     2 code_updt_cnt = i4
     2 code_begin_eff_dt_tm = dq8
     2 code_end_eff_dt_tm = dq8
     2 procedure_id = f8
     2 deferrals_allowed_cd = f8
     2 deferrals_allowed_cd_disp = vc
     2 deferrals_allowed_cd_mean = vc
     2 nbr_per_volume_level = i4
     2 schedule_ind = i2
     2 default_bag_type_cd = f8
     2 default_bag_type_cd_disp = vc
     2 start_stop_ind = i2
     2 don_collation_seq = i2
     2 don_active_ind = i2
     2 don_updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count = 0
 SELECT INTO "nl:"
  c.code_value
  FROM donation_procedure d,
   code_value c
  PLAN (c
   WHERE (c.code_set=request->code_set)
    AND c.code_value > 0
    AND c.active_ind=1)
   JOIN (d
   WHERE d.procedure_cd=c.code_value
    AND d.active_ind=1)
  DETAIL
   count = (count+ 1), stat = alterlist(reply->qual,count), reply->qual[count].code_value = c
   .code_value,
   reply->qual[count].cdf_meaning = c.cdf_meaning, reply->qual[count].display = c.display, reply->
   qual[count].description = c.description,
   reply->qual[count].definition = c.definition, reply->qual[count].code_collation_seq = c
   .collation_seq, reply->qual[count].code_active_ind = c.active_ind,
   reply->qual[count].code_updt_cnt = c.updt_cnt, reply->qual[count].code_begin_eff_dt_tm = c
   .begin_effective_dt_tm, reply->qual[count].code_end_eff_dt_tm = c.end_effective_dt_tm,
   reply->qual[count].procedure_id = d.procedure_id, reply->qual[count].deferrals_allowed_cd = d
   .deferrals_allowed_cd, reply->qual[count].nbr_per_volume_level = d.nbr_per_volume_level,
   reply->qual[count].schedule_ind = d.schedule_ind, reply->qual[count].default_bag_type_cd = d
   .default_bag_type_cd, reply->qual[count].start_stop_ind = d.start_stop_ind,
   reply->qual[count].don_collation_seq = d.collation_seq, reply->qual[count].don_active_ind = d
   .active_ind, reply->qual[count].don_updt_cnt = d.updt_cnt
  WITH nocounter
 ;end select
#exitscript
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
