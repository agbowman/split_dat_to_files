CREATE PROGRAM dcp_get_apache_ref:dba
 RECORD reply(
   1 rar_list[*]
     2 risk_adjustment_ref_id = f8
     2 org_id = f8
     2 org_name = vc
     2 bedcount = i2
     2 region_flag = i2
     2 teach_type_flag = i2
     2 icu_day_start_tm = i4
     2 accept_worst_lab_ind = i2
     2 accept_worst_vitals_ind = i2
     2 accept_urine_output_ind = i2
     2 accept_tiss_acttx_if_ind = i2
     2 accept_tiss_nonacttx_if_ind = i2
     2 auto_calc_intubated_ind = i2
     2 location_list[*]
       3 risk_adjustment_location_id = f8
       3 location_cd = f8
       3 location_disp = vc
       3 location_desc = vc
       3 location_mean = vc
       3 location_type_flag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = vc
       3 operationstatus = c1
       3 targetobjectname = vc
       3 targetobjectvalue = vc
 )
 EXECUTE FROM 1000_initialize TO 1099_initialize_exit
 EXECUTE FROM 2000_read TO 2099_read_exit
 GO TO 9999_exit_program
 SUBROUTINE meaning_code(mc_codeset,mc_meaning)
   SET mc_code = 0.0
   SET mc_text = fillstring(12," ")
   SET mc_text = mc_meaning
   SET mc_stat = uar_get_meaning_by_codeset(mc_codeset,nullterm(mc_text),1,mc_code)
   IF (mc_code > 0.0)
    RETURN(mc_code)
   ELSE
    RETURN(- (1.0))
   ENDIF
 END ;Subroutine
#1000_initialize
 SET reply->status_data.status = "F"
#1099_initialize_exit
#2000_read
 SET count0 = 0
 SET count1 = 0
 SELECT INTO "nl:"
  FROM risk_adjustment_ref rar,
   organization o,
   location l
  PLAN (rar
   WHERE rar.active_ind=1)
   JOIN (o
   WHERE o.organization_id=rar.organization_id
    AND o.active_ind=1)
   JOIN (l
   WHERE l.organization_id=outerjoin(rar.organization_id)
    AND l.icu_ind=outerjoin(1))
  HEAD REPORT
   count0 = 0
  HEAD rar.organization_id
   count0 = (count0+ 1), stat = alterlist(reply->rar_list,count0), reply->rar_list[count0].org_id =
   rar.organization_id,
   reply->rar_list[count0].org_name = o.org_name, reply->rar_list[count0].risk_adjustment_ref_id =
   rar.risk_adjustment_ref_id, reply->rar_list[count0].teach_type_flag = rar.teach_type_flag,
   reply->rar_list[count0].region_flag = rar.region_flag, reply->rar_list[count0].bedcount = rar
   .bed_count, reply->rar_list[count0].icu_day_start_tm = rar.icu_day_start_time,
   reply->rar_list[count0].accept_worst_lab_ind = rar.accept_worst_lab_ind, reply->rar_list[count0].
   accept_worst_vitals_ind = rar.accept_worst_vitals_ind, reply->rar_list[count0].
   accept_urine_output_ind = rar.accept_urine_output_ind,
   reply->rar_list[count0].accept_tiss_acttx_if_ind = rar.accept_tiss_acttx_if_ind, reply->rar_list[
   count0].accept_tiss_nonacttx_if_ind = rar.accept_tiss_nonacttx_if_ind, reply->rar_list[count0].
   auto_calc_intubated_ind = rar.auto_calc_intubated_ind,
   count1 = 0
  DETAIL
   IF (l.location_cd > 0)
    count1 = (count1+ 1), stat = alterlist(reply->rar_list[count0].location_list,count1), reply->
    rar_list[count0].location_list[count1].location_cd = l.location_cd
   ENDIF
  WITH nocounter
 ;end select
 IF (count0 > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#2099_read_exit
#9999_exit_program
 CALL echorecord(reply)
END GO
