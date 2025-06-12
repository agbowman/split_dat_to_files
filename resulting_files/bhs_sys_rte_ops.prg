CREATE PROGRAM bhs_sys_rte_ops
 EXECUTE bhs_sys_rte_process_req
 SELECT INTO "nl:"
  FROM bhs_rte_hold brh
  PLAN (brh
   WHERE brh.process_flag=0)
  HEAD REPORT
   r_cnt = 0
  DETAIL
   r_cnt = (rte_req->r_cnt+ 1), stat = alterlist(rte_req->records,r_cnt), rte_req->r_cnt = r_cnt,
   rte_req->records[r_cnt].rec_id = brh.rec_id, rte_req->records[r_cnt].encntr_id = brh.encntr_id,
   rte_req->records[r_cnt].entity_name = trim(brh.parent_entity_name,3),
   rte_req->records[r_cnt].entity_id = trim(brh.parent_entity_id,3)
  WITH nocounter
 ;end select
 FOR (a_r = 1 TO rte_req->r_cnt)
  UPDATE  FROM bhs_rte_hold brh
   SET brh.process_flag = - (1)
   WHERE (brh.rec_id=rte_req->records[a_r].rec_id)
   WITH nocounter
  ;end update
  IF (curqual != 1)
   ROLLBACK
  ELSE
   COMMIT
  ENDIF
 ENDFOR
 EXECUTE bhs_sys_rte_process
 FOR (z_r = 1 TO rte_req->r_cnt)
   IF ((rte_reply->records[z_r].process_ind=successful_flag))
    FOR (p = 1 TO rte_reply->records[z_r].p_cnt)
      IF ((rte_reply->records[z_r].prsnl[p].process_nbr > 0))
       FOR (e = 1 TO rte_reply->records[z_r].e_cnt)
         EXECUTE bhs_sys_rte_forward_result rte_reply->records[z_r].events[e].event_id, rte_reply->
         records[z_r].prsnl[p].prsnl_id, rte_reply->records[z_r].prsnl[p].action
       ENDFOR
      ENDIF
    ENDFOR
   ENDIF
   UPDATE  FROM bhs_rte_hold brh
    SET brh.cont_sys = rte_req->records[r].cont_sys, brh.encntr_id = rte_req->records[r].encntr_id,
     brh.parent_entity_id = rte_req->records[r].entity_id,
     brh.parent_entity_name = rte_req->records[r].entity_name, brh.process_flag = rte_req->records[r]
     .process_ind, brh.process_dt_tm =
     IF ((rte_req->records[r].process_ind > 0)) rte_req->records[r].process_dt_tm
     ENDIF
     ,
     brh.updt_cnt = (brh.updt_cnt+ 1), brh.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE (brh.rec_id=rte_req->records[z_r].rec_id)
    WITH nocounter
   ;end update
   IF (curqual != 1)
    ROLLBACK
   ELSE
    COMMIT
   ENDIF
 ENDFOR
 EXECUTE bhs_sys_rte_process_req
#exit_script
END GO
