CREATE PROGRAM afc_srv_get_charge_event:dba
 RECORD reply(
   1 error = c80
   1 charge_event_id = f8
   1 master_event_id = f8
   1 master_event_cd = f8
   1 master_ref_id = f8
   1 master_ref_cd = f8
   1 parent_event_id = f8
   1 parent_event_cd = f8
   1 parent_ref_id = f8
   1 parent_ref_cd = f8
   1 item_event_id = f8
   1 item_event_cd = f8
   1 item_ref_id = f8
   1 item_ref_cd = f8
   1 order_srv_res_cd = f8
   1 perform_srv_res_cd = f8
   1 verify_srv_res_cd = f8
   1 loaded_srv_res_cd = f8
   1 order_phys_id = f8
   1 perform_phys_id = f8
   1 verify_phys_id = f8
   1 order_id = f8
   1 charge_type_cd = f8
   1 order_loc_cd = f8
   1 order_event_flg = i2
   1 research_acct_id = f8
   1 abn_status_cd = f8
 )
 SET count = 0
 SET reply->order_event_flg = 0
 CALL echo("request in->")
 CALL echo(build("	master_event_id: ",request->master_event_id))
 CALL echo(build("	master_event_cd: ",request->master_event_cd))
 CALL echo(build("	item_event_id: ",request->item_event_id))
 CALL echo(build("	item_event_cd: ",request->item_event_cd))
 SELECT INTO "nl:"
  c.*, ca.cea_prsnl_id, ca.cea_type_cd,
  p.physician_ind
  FROM charge_event_act ca,
   dummyt d1,
   prsnl p,
   charge_event c
  PLAN (c
   WHERE (c.ext_m_event_id=request->master_event_id)
    AND (c.ext_m_event_cont_cd=request->master_event_cd)
    AND (c.ext_i_event_id=request->item_event_id)
    AND (c.ext_i_event_cont_cd=request->item_event_cd)
    AND c.active_ind=1)
   JOIN (ca
   WHERE c.charge_event_id=ca.charge_event_id
    AND ca.active_ind=1)
   JOIN (d1)
   JOIN (p
   WHERE p.person_id=ca.cea_prsnl_id
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND p.end_effective_dt_tm >= cnvtdatetime(sysdate))
  HEAD c.charge_event_id
   count += 1, reply->charge_event_id = c.charge_event_id, reply->master_event_id = c.ext_m_event_id,
   reply->master_event_cd = c.ext_m_event_cont_cd, reply->master_ref_id = c.ext_m_reference_id, reply
   ->master_ref_cd = c.ext_m_reference_cont_cd,
   reply->parent_event_id = c.ext_p_event_id, reply->parent_event_cd = c.ext_p_event_cont_cd, reply->
   parent_ref_id = c.ext_p_reference_id,
   reply->parent_ref_cd = c.ext_p_reference_cont_cd, reply->item_event_id = c.ext_i_event_id, reply->
   item_event_cd = c.ext_i_event_cont_cd,
   reply->item_ref_id = c.ext_i_reference_id, reply->item_ref_cd = c.ext_i_reference_cont_cd, reply->
   order_id = c.order_id,
   reply->charge_type_cd = ca.charge_type_cd, reply->research_acct_id = c.research_account_id, reply
   ->abn_status_cd = c.abn_status_cd
  DETAIL
   IF ((ca.cea_type_cd= $1))
    reply->order_event_flg = 1, reply->order_srv_res_cd = ca.service_resource_cd, reply->order_loc_cd
     = ca.service_loc_cd
   ENDIF
   IF ((ca.cea_type_cd= $1)
    AND p.physician_ind=1)
    reply->order_phys_id = ca.cea_prsnl_id
   ENDIF
   IF ((ca.cea_type_cd= $2)
    AND p.physician_ind=1)
    reply->order_phys_id = ca.cea_prsnl_id
   ENDIF
   IF ((ca.cea_type_cd= $3))
    reply->perform_srv_res_cd = ca.service_resource_cd
   ENDIF
   IF ((ca.cea_type_cd= $4)
    AND p.physician_ind=1)
    reply->perform_phys_id = ca.cea_prsnl_id
   ENDIF
   IF ((ca.cea_type_cd= $5))
    reply->verify_srv_res_cd = ca.service_resource_cd
   ENDIF
   IF ((ca.cea_type_cd= $6)
    AND p.physician_ind=1)
    reply->verify_phys_id = ca.cea_prsnl_id
   ENDIF
   IF ((ca.cea_type_cd= $7))
    reply->loaded_srv_res_cd = ca.service_resource_cd
   ENDIF
  WITH outerjoin = d1, nocounter
 ;end select
 SET reply->error = ""
 IF (count > 1)
  SET reply->error = "More than one row returned"
 ENDIF
 IF (count=0)
  SET reply->error = "No rows returned"
 ENDIF
END GO
