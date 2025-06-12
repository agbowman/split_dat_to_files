CREATE PROGRAM bhs_athn_get_plan_comment
 FREE RECORD orequest
 RECORD orequest(
   1 person_id = f8
   1 stale_in_min = i2
   1 phase_look_back_days = i4
   1 comp_look_back_days = i4
   1 querylist[*]
     2 encntr_id = f8
   1 accesslist[*]
     2 encntr_id = f8
   1 facility_cd = f8
   1 load_tapers_only_ind = i2
   1 load_suggested_plans_ind = i2
   1 plantypeincludelist[*]
     2 pathway_type_cd = f8
   1 plantypeexcludelist[*]
     2 pathway_type_cd = f8
   1 skip_component_load_ind = i2
   1 planidincludelist[*]
     2 plan_id = f8
   1 patient_criteria
     2 birth_dt_tm = dq8
     2 birth_tz = i4
     2 postmenstrual_age_in_days = i4
     2 weight = f8
     2 weight_unit_cd = f8
 )
 FREE RECORD oreply
 RECORD oreply(
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = c100
   1 variancelist[*]
     2 variance_reltn_id = f8
     2 parent_entity_name = vc
     2 parent_entity_id = f8
     2 pathway_id = f8
     2 event_id = f8
     2 variance_type_cd = f8
     2 variance_type_disp = vc
     2 variance_type_mean = vc
     2 action_cd = f8
     2 action_disp = vc
     2 action_mean = vc
     2 action_text_id = f8
     2 action_text = vc
     2 action_text_updt_cnt = i4
     2 reason_cd = f8
     2 reason_disp = vc
     2 reason_mean = vc
     2 reason_text_id = f8
     2 reason_text = vc
     2 reason_text_updt_cnt = i4
     2 variance_updt_cnt = i4
     2 active_ind = i2
     2 note_text_id = f8
     2 note_text = vc
     2 note_text_updt_cnt = i4
     2 chart_prsnl_name = vc
     2 chart_dt_tm = dq8
     2 chart_prsnl_id = f8
     2 unchart_prsnl_name = vc
     2 unchart_dt_tm = dq8
     2 unchart_prsnl_id = f8
 )
 SET stat = alterlist(orequest->planidincludelist,1)
 SET orequest->planidincludelist[1].plan_id =  $2
 SET stat = alterlist(orequest->accesslist,1)
 SET orequest->accesslist[1].encntr_id =  $3
 SET orequest->skip_component_load_ind = 0
 SET stat = tdbexecute(600005,601100,601541,"REC",orequest,
  "REC",oreply)
 SET _memory_reply_string = replace(replace(cnvtrectojson(oreply,0,1),'\"',"'",0),
  '"0000-00-00T00:00:00.000+00:00"',"null",0)
END GO
