CREATE PROGRAM dcp_get_plan_ord_history
 SET modify = predeclare
 RECORD reply(
   1 description = c100
   1 pw_group_desc = c100
   1 parent_phase_desc = c100
   1 type_mean = c12
   1 plan_status_cd = f8
   1 plan_status_disp = vc
   1 pathway_id = f8
   1 plan_proposal_history_list[*]
     2 order_proposal_id = f8
     2 updt_dt_tm = dq8
     2 action_prsnl_id = f8
     2 action_prsnl_name = vc
   1 plan_history_list[*]
     2 xml_str = vc
     2 updt_dt_tm = dq8
     2 action_prsnl_id = f8
     2 action_prsnl_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE orders_entity = c6 WITH constant("ORDERS")
 DECLARE proposal_entity = c8 WITH constant("PROPOSAL")
 DECLARE i = i2 WITH noconstant(0)
 DECLARE stat = i2 WITH noconstant(0)
 DECLARE cfailed = c1 WITH noconstant("F")
 DECLARE history_cnt = i4 WITH noconstant(0)
 DECLARE lastmod = c3 WITH private, noconstant("")
 DECLARE worderpropsalcount = i4 WITH noconstant(0)
 DECLARE dparentyentityid = f8 WITH protect, noconstant(0.0)
 DECLARE sparententity = vc WITH protect, noconstant(fillstring(32000," "))
 DECLARE report_failure(opname=vc,opstatus=c1,targetname=vc,targetvalue=vc) = null
 IF ((request->proposal_id > 0.0))
  SET dparentyentityid = request->proposal_id
  SET sparententity = proposal_entity
 ELSE
  SET dparentyentityid = request->order_id
  SET sparententity = orders_entity
 ENDIF
 SELECT INTO "nl:"
  FROM act_pw_comp apc,
   pathway pw
  PLAN (apc
   WHERE apc.parent_entity_id=dparentyentityid
    AND apc.parent_entity_name=sparententity)
   JOIN (pw
   WHERE pw.pathway_id=apc.pathway_id)
  DETAIL
   reply->description = pw.description, reply->pw_group_desc = pw.pw_group_desc, reply->
   parent_phase_desc = pw.parent_phase_desc,
   reply->type_mean = pw.type_mean, reply->plan_status_cd = pw.pw_status_cd, reply->pathway_id = pw
   .pathway_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL report_failure("SELECT","F","DCP_GET_PLAN_ORD_HISTORY",
   "Failed to find the plan details in the PATHWAY table.")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  created_dt_tm_tz = cnvtdatetimeutc(op.created_dt_tm,3,op.created_tz)
  FROM order_proposal op,
   person p
  PLAN (op
   WHERE (op.projected_order_id=request->order_id))
   JOIN (p
   WHERE op.entered_by_prsnl_id=p.person_id)
  ORDER BY created_dt_tm_tz DESC
  DETAIL
   worderpropsalcount = (worderpropsalcount+ 1)
   IF (worderpropsalcount > size(reply->plan_proposal_history_list,5))
    stat = alterlist(reply->plan_proposal_history_list,(worderpropsalcount+ 5))
   ENDIF
   reply->plan_proposal_history_list[worderpropsalcount].order_proposal_id = op.order_proposal_id,
   reply->plan_proposal_history_list[worderpropsalcount].updt_dt_tm = op.created_dt_tm, reply->
   plan_proposal_history_list[worderpropsalcount].action_prsnl_id = op.entered_by_prsnl_id,
   reply->plan_proposal_history_list[worderpropsalcount].action_prsnl_name = p.name_full_formatted
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->plan_proposal_history_list,worderpropsalcount)
 SELECT INTO "nl:"
  FROM act_pw_comp apc,
   long_blob lb,
   person p
  PLAN (apc
   WHERE apc.parent_entity_id=dparentyentityid
    AND apc.parent_entity_name=sparententity)
   JOIN (lb
   WHERE lb.parent_entity_id=apc.act_pw_comp_id
    AND lb.parent_entity_name="ACT_PW_COMP"
    AND lb.active_ind=1)
   JOIN (p
   WHERE lb.updt_id=p.person_id)
  ORDER BY lb.updt_dt_tm DESC
  DETAIL
   history_cnt = (history_cnt+ 1)
   IF (history_cnt > size(reply->plan_history_list,5))
    stat = alterlist(reply->plan_history_list,(history_cnt+ 5))
   ENDIF
   reply->plan_history_list[history_cnt].xml_str = lb.long_blob, reply->plan_history_list[history_cnt
   ].updt_dt_tm = lb.updt_dt_tm, reply->plan_history_list[history_cnt].action_prsnl_id = lb.updt_id,
   reply->plan_history_list[history_cnt].action_prsnl_name = p.name_full_formatted
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->plan_history_list,history_cnt)
 IF (((worderpropsalcount+ history_cnt) <= 0))
  CALL report_failure("SELECT","F","DCP_GET_PLAN_ORD_HISTORY",
   "Failed to find any history in the order_proposal table, nor the long blob table.")
  GO TO exit_script
 ENDIF
 SUBROUTINE report_failure(opname,opstatus,targetname,targetvalue)
   SET cfailed = "T"
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
 SET lastmod = "002"
END GO
