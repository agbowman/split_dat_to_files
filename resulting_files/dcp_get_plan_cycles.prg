CREATE PROGRAM dcp_get_plan_cycles
 SET modify = predeclare
 RECORD reply(
   1 standard_cycle_nbr = i4
   1 cycle_begin_nbr = i4
   1 cycle_end_nbr = i4
   1 cycle_increment_nbr = i4
   1 cycle_label_cd = f8
   1 cycle_display_end_ind = i2
   1 cycle_lock_end_ind = i2
   1 plan_list[*]
     2 pw_group_nbr = f8
     2 pw_group_desc = vc
     2 order_dt_tm = dq8
     2 order_prsnl_name = vc
     2 cycle_nbr = i4
     2 order_tz = i4
     2 cycle_label_cd = f8
     2 communication_type = vc
     2 provider_name = vc
     2 cycle_end_nbr = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD data
 RECORD data(
   1 qual[*]
     2 pathway_catalog_id = f8
 )
 DECLARE void_status_cd = f8 WITH constant(uar_get_code_by("MEANING",16769,"VOID"))
 DECLARE dropped_status_cd = f8 WITH constant(uar_get_code_by("MEANING",16769,"DROPPED"))
 DECLARE discontinued_status_cd = f8 WITH constant(uar_get_code_by("MEANING",16769,"DISCONTINUED"))
 DECLARE i = i2 WITH noconstant(0)
 DECLARE stat = i2 WITH noconstant(0)
 DECLARE cfailed = c1 WITH noconstant("F")
 DECLARE pw_status_cd = f8 WITH noconstant(0.0)
 DECLARE plan_cnt = i2 WITH noconstant(0)
 DECLARE num = i4 WITH noconstant(0)
 DECLARE max = i4 WITH noconstant(0)
 DECLARE report_failure(opname=vc,opstatus=c1,targetname=vc,targetvalue=vc) = null
 SELECT INTO "nl:"
  FROM pathway_catalog pc
  WHERE (pc.version_pw_cat_id=
  (SELECT
   pc2.version_pw_cat_id
   FROM pathway_catalog pc2
   WHERE (pc2.pathway_catalog_id=request->pathway_catalog_id)))
  HEAD REPORT
   plan_cnt = 0
  DETAIL
   plan_cnt = (plan_cnt+ 1)
   IF (plan_cnt > size(data->qual,5))
    stat = alterlist(data->qual,(plan_cnt+ 5))
   ENDIF
   data->qual[plan_cnt].pathway_catalog_id = pc.pathway_catalog_id
   IF ((pc.pathway_catalog_id=request->pathway_catalog_id))
    reply->standard_cycle_nbr = pc.standard_cycle_nbr, reply->cycle_begin_nbr = pc.cycle_begin_nbr,
    reply->cycle_display_end_ind = pc.cycle_display_end_ind,
    reply->cycle_end_nbr = pc.cycle_end_nbr, reply->cycle_increment_nbr = pc.cycle_increment_nbr,
    reply->cycle_label_cd = pc.cycle_label_cd,
    reply->cycle_lock_end_ind = pc.cycle_lock_end_ind
   ENDIF
  FOOT REPORT
   stat = alterlist(data->qual,plan_cnt), max = plan_cnt
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL report_failure("SELECT","F","DCP_GET_PLAN_CYCLES",
   "Failed to find plan versions and the latest standard_cycle_nbr in the PATHWAY_CATALOG table")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  pw.pw_cat_group_id
  FROM pathway pw,
   pathway_action pa,
   prsnl p
  PLAN (pw
   WHERE expand(num,1,max,pw.pw_cat_group_id,data->qual[num].pathway_catalog_id)
    AND (pw.person_id=request->person_id)
    AND  NOT (pw.pw_status_cd IN (void_status_cd, dropped_status_cd, discontinued_status_cd)))
   JOIN (pa
   WHERE pa.pathway_id=pw.pathway_id
    AND pa.pw_action_seq=1)
   JOIN (p
   WHERE p.person_id IN (pa.action_prsnl_id, pa.provider_id))
  ORDER BY pw.cycle_nbr, pw.pw_group_nbr, p.person_id
  HEAD REPORT
   plan_cnt = 0
  HEAD pw.pw_group_nbr
   plan_cnt = (plan_cnt+ 1)
   IF (plan_cnt > size(reply->plan_list,5))
    stat = alterlist(reply->plan_list,(plan_cnt+ 5))
   ENDIF
   reply->plan_list[plan_cnt].pw_group_nbr = pw.pw_group_nbr, reply->plan_list[plan_cnt].
   pw_group_desc = pw.pw_group_desc, reply->plan_list[plan_cnt].order_dt_tm = pw.order_dt_tm,
   reply->plan_list[plan_cnt].cycle_nbr = pw.cycle_nbr, reply->plan_list[plan_cnt].order_tz = pw
   .order_tz, reply->plan_list[plan_cnt].cycle_label_cd = pw.cycle_label_cd,
   reply->plan_list[plan_cnt].communication_type = trim(uar_get_code_display(pa.communication_type_cd
     )), reply->plan_list[plan_cnt].cycle_end_nbr = pw.cycle_end_nbr
  HEAD p.person_id
   IF (p.person_id=pa.action_prsnl_id)
    reply->plan_list[plan_cnt].order_prsnl_name = trim(p.name_full_formatted)
   ENDIF
   IF (p.person_id=pa.provider_id)
    reply->plan_list[plan_cnt].provider_name = trim(p.name_full_formatted)
   ENDIF
  FOOT REPORT
   IF (plan_cnt > 0)
    stat = alterlist(reply->plan_list,plan_cnt)
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL report_failure("SELECT","Z","DCP_GET_PLAN_CYCLES",
   "Failed to find the plan_list in the PATHWAY table")
  GO TO exit_script
 ENDIF
 SUBROUTINE report_failure(opname,opstatus,targetname,targetvalue)
   IF (opstatus="F")
    SET cfailed = "T"
   ENDIF
   SET reply->status_data.subeventstatus[1].operationname = trim(opname)
   SET reply->status_data.subeventstatus[1].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[1].targetobjectname = trim(targetname)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = trim(targetvalue)
 END ;Subroutine
#exit_script
 IF (cfailed="T")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 FREE RECORD data
END GO
