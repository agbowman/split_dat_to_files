CREATE PROGRAM aps_get_cases_by_order_id:dba
 RECORD reply(
   1 qual[10]
     2 current_dt_tm = dq8
     2 patient_number = vc
     2 patient_name = vc
     2 encntr_id = f8
     2 patient_age = c12
     2 req_physician_name = vc
     2 birth_dt_tm = dq8
     2 room_num_cd = f8
     2 room_num_disp = c12
     2 bed_num_cd = f8
     2 bed_num_disp = c12
     2 case_collect_dt_tm = dq8
     2 prefix_cd = f8
     2 prefix_disp = c2
     2 status_cd = f8
     2 status_disp = c20
     2 status_desc = c20
     2 report_name = vc
     2 primary_mnemonic = vc
     2 event_id = f8
     2 report_id = f8
     2 catalog_cd = f8
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
  FROM pathology_case pc,
   case_report cr,
   report_task rt,
   order_catalog oc,
   prsnl p,
   encounter e,
   person p1
  PLAN (pc
   WHERE (request->accession_nbr=pc.accession_nbr))
   JOIN (p
   WHERE pc.requesting_physician_id=p.person_id)
   JOIN (rt
   WHERE (request->order_id=rt.order_id))
   JOIN (cr
   WHERE rt.report_id=cr.report_id)
   JOIN (oc
   WHERE cr.catalog_cd=oc.catalog_cd)
   JOIN (e
   WHERE e.encntr_id=pc.encntr_id)
   JOIN (p1
   WHERE e.person_id=p1.person_id)
  ORDER BY pc.case_id
  HEAD REPORT
   cnt = 0
  HEAD pc.case_id
   cnt = (cnt+ 1), stat = alter(reply->qual,cnt)
  DETAIL
   reply->qual[cnt].current_dt_tm = cnvtdatetime(curdate,curtime3), reply->qual[cnt].event_id = cr
   .event_id, reply->qual[cnt].report_id = cr.report_id,
   reply->qual[cnt].status_cd = cr.status_cd, reply->qual[cnt].case_collect_dt_tm = cnvtdatetime(pc
    .case_collect_dt_tm), reply->qual[cnt].req_physician_name = trim(p.name_full_formatted),
   reply->qual[cnt].primary_mnemonic = oc.primary_mnemonic, reply->qual[cnt].report_name = oc
   .description, reply->qual[cnt].patient_name = p1.name_full_formatted,
   reply->qual[cnt].birth_dt_tm = p1.birth_dt_tm, reply->qual[cnt].patient_age = cnvtage(cnvtdate2(
     format(p1.birth_dt_tm,"mm/dd/yyyy;;d"),"mm/dd/yyyy"),cnvtint(format(p1.birth_dt_tm,"hhmm;;m"))),
   reply->qual[cnt].room_num_cd = e.loc_room_cd,
   reply->qual[cnt].bed_num_cd = e.loc_bed_cd, reply->qual[cnt].prefix_cd = pc.prefix_id, reply->
   qual[cnt].encntr_id = pc.encntr_id
  WITH nocounter
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
 SET stat = alter(reply->qual,cnt)
 SELECT INTO "nl:"
  frmt_mrn = cnvtalias(ea.alias,ea.alias_pool_cd), ea.*
  FROM encntr_alias ea,
   (dummyt d1  WITH value(size(reply->qual,5)))
  PLAN (d1
   WHERE (reply->qual[d1.seq].encntr_id > 0))
   JOIN (ea
   WHERE (ea.encntr_id=reply->qual[d1.seq].encntr_id)
    AND ea.encntr_alias_type_cd=mrn_alias_type_cd
    AND ea.active_ind=1
    AND ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  DETAIL
   reply->qual[d1.seq].patient_number = frmt_mrn
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->qual[1].patient_number = "Unknown"
 ENDIF
#exit_script
END GO
