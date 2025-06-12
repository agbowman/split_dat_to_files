CREATE PROGRAM dcp_gen_valid_encounters_recs:dba
 RECORD gve_request(
   1 force_org_security_ind = i2
   1 prsnl_id = f8
   1 persons[*]
     2 person_id = f8
   1 force_encntrs_ind = i2
   1 provider_ind = i2
   1 exclude_life_reltns[*]
     2 person_prsnl_reltn_id = f8
   1 exclude_visit_reltns[*]
     2 encntr_prsnl_reltn_id = f8
   1 include_reltn_type_cd = f8
   1 encntr_lookback_days = i4
   1 encntr_from_dt_tm = dq8
   1 encntr_to_dt_tm = dq8
 ) WITH persistscript
 RECORD gve_reply(
   1 restrict_ind = i2
   1 persons[*]
     2 person_id = f8
     2 restrict_ind = i2
     2 encntrs[*]
       3 encntr_id = f8
       3 encntr_type_cd = f8
       3 encntr_type_disp = vc
       3 encntr_type_class_cd = f8
       3 encntr_type_class_disp = vc
       3 encntr_status_cd = f8
       3 encntr_status_disp = vc
       3 reg_dt_tm = dq8
       3 pre_reg_dt_tm = dq8
       3 location_cd = f8
       3 loc_facility_cd = f8
       3 loc_facility_disp = vc
       3 loc_building_cd = f8
       3 loc_building_disp = vc
       3 loc_nurse_unit_cd = f8
       3 loc_nurse_unit_disp = vc
       3 loc_room_cd = f8
       3 loc_room_disp = vc
       3 loc_bed_cd = f8
       3 loc_bed_disp = vc
       3 reason_for_visit = vc
       3 financial_class_cd = f8
       3 financial_class_disp = vc
       3 beg_effective_dt_tm = dq8
       3 disch_dt_tm = dq8
       3 med_service_cd = f8
       3 diet_type_cd = f8
       3 isolation_cd = f8
       3 encntr_financial_id = f8
       3 arrive_dt_tm = dq8
       3 provider_list[*]
         4 provider_id = f8
         4 provider_name = vc
         4 relationship_cd = f8
         4 relationship_disp = vc
         4 relationship_mean = c12
       3 organization_id = f8
       3 time_zone_indx = i4
       3 est_arrive_dt_tm = dq8
       3 est_disch_dt_tm = dq8
       3 contributor_system_cd = f8
       3 contributor_system_disp = vc
       3 contributor_system_mean = vc
       3 loc_temp_cd = f8
       3 loc_temp_disp = vc
       3 alias_list[*]
         4 alias = vc
         4 alias_type_cd = f8
         4 alias_type_disp = vc
         4 alias_type_mean = vc
         4 alias_status_cd = f8
         4 alias_status_disp = vc
         4 alias_status_mean = vc
         4 contributor_system_cd = f8
         4 contributor_system_disp = vc
         4 contributor_system_mean = vc
       3 encntr_type_class_mean = c12
       3 encntr_status_mean = c12
       3 med_service_disp = vc
       3 isolation_disp = vc
       3 location_disp = vc
       3 diet_type_disp = vc
       3 diet_type_mean = vc
       3 inpatient_admit_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH persistscript
 SET script_version = "001 04/25/03 SF3151"
END GO
