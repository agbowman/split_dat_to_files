CREATE PROGRAM aps_get_cases_by_event_id:dba
 RECORD reply(
   1 current_dt_tm = dq8
   1 req_physician_name = vc
   1 room_num_cd = f8
   1 room_num_disp = c12
   1 bed_num_cd = f8
   1 bed_num_disp = c12
   1 case_collect_dt_tm = dq8
   1 prefix_cd = f8
   1 prefix_disp = c2
   1 status_cd = f8
   1 status_disp = c20
   1 status_desc = c20
   1 report_name = vc
   1 primary_mnemonic = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET code_set = 0
 SET cdf_meaning = fillstring(12," ")
 SET code_value = 0.0
 SET mrn_alias_type_cd = 0.0
 SET code_set = 319
 SET cdf_meaning = "MRN"
 EXECUTE cpm_get_cd_for_cdf
 SET mrn_alias_type_cd = code_value
 CALL echo(build("<",mrn_alias_type_cd,">"))
 SET reply->status_data.status = "Q"
 SET cnt = 0
 SET cancel_status_cd = 0.0
 SELECT INTO "nl:"
  pc.case_id
  FROM case_report cr,
   pathology_case pc,
   prsnl p,
   encounter e
  PLAN (cr
   WHERE (cr.event_id=request->event_id))
   JOIN (pc
   WHERE cr.case_id=pc.case_id)
   JOIN (p
   WHERE pc.requesting_physician_id=p.person_id)
   JOIN (e
   WHERE pc.encntr_id=e.encntr_id)
  ORDER BY pc.case_id
  HEAD REPORT
   cnt = 0
  HEAD pc.case_id
   cnt = (cnt+ 1)
  DETAIL
   reply->current_dt_tm = cnvtdatetime(curdate,curtime3), reply->status_cd = cr.status_cd, reply->
   case_collect_dt_tm = cnvtdatetime(pc.case_collect_dt_tm),
   reply->req_physician_name = trim(p.name_full_formatted), reply->room_num_cd = e.loc_room_cd, reply
   ->bed_num_cd = e.loc_bed_cd,
   reply->prefix_cd = pc.prefix_id
  WITH outerjoin = d1, nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "PATHOLOGY_CASE"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO
