CREATE PROGRAM compass_get_patient_list:dba
 FREE RECORD reply
 RECORD reply(
   1 patient_list_id = f8
   1 name = vc
   1 description = vc
   1 patient_list_type_cd = f8
   1 owner_id = f8
   1 prsnl_access_cd = f8
   1 execution_dt_tm = dq8
   1 execution_status_cd = f8
   1 execution_status_disp = vc
   1 arguments[*]
     2 argument_name = vc
     2 argument_value = vc
     2 parent_entity_name = vc
     2 parent_entity_id = f8
   1 encntr_type_filters[*]
     2 encntr_type_cd = f8
   1 patients[*]
     2 person_id = f8
     2 person_name = vc
     2 encntr_id = f8
     2 priority = i4
     2 active_ind = i2
     2 filter_ind = i2
     2 responsible_prsnl_id = f8
     2 responsible_prsnl_name = vc
     2 responsible_reltn_cd = f8
     2 responsible_reltn_disp = vc
     2 responsible_reltn_id = f8
     2 responsible_reltn_flag = i2
     2 organization_id = f8
     2 confid_level_cd = f8
     2 confid_level_disp = c40
     2 confid_level = i4
     2 birthdate = dq8
     2 birth_tz = i4
     2 end_effective_dt_tm = dq8
     2 service_cd = f8
     2 service_disp = c40
     2 gender_cd = f8
     2 gender_disp = c40
     2 temp_location_cd = f8
     2 temp_location_disp = c40
     2 vip_cd = f8
     2 visit_reason = vc
     2 visitor_status_cd = f8
     2 visitor_status_disp = c40
     2 deceased_date = dq8
     2 deceased_tz = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET reqinfo->updt_id = request->prsnl_id
 DECLARE listtype = vc WITH constant(uar_get_code_meaning(request->patient_list_type_cd))
 CASE (listtype)
  OF "CUSTOM":
   EXECUTE dcp_get_pl_custom2
  OF "CARETEAM":
   EXECUTE dcp_get_pl_careteam2
  OF "LOCATION":
   EXECUTE dcp_get_pl_census
  OF "LOCATIONGRP":
   EXECUTE dcp_get_pl_census
  OF "VRELTN":
   EXECUTE dcp_get_pl_reltn
  OF "LRELTN":
   EXECUTE dcp_get_pl_reltn
  OF "RELTN":
   EXECUTE dcp_get_pl_reltn
  OF "PROVIDERGRP":
   EXECUTE dcp_get_pl_provider_group2
  OF "SERVICE":
   EXECUTE dcp_get_pl_census
  OF "ASSIGNMENT":
   EXECUTE dcp_get_pl_asgmt
  OF "ANC_ASGMT":
   EXECUTE dcp_get_pl_ancillary_asgmt
  OF "QUERY":
   EXECUTE dcp_get_pl_query
  OF "SCHEDULE":
   EXECUTE dcp_get_pl_schedule
  OF "MILITARYUNIT":
   EXECUTE dcp_get_pl_military_unit
  ELSE
   GO TO error
 ENDCASE
 SET script_version = "MOD 001 03/04/11 po016255"
#error
 CALL echorecord(reply)
END GO
