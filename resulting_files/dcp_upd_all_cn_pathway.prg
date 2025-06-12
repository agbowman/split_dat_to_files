CREATE PROGRAM dcp_upd_all_cn_pathway
 SET modify = nopredeclare
 SET dcp_info_ind = 0
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="DATA MANAGEMENT"
   AND di.info_name="PATHWAYS"
  DETAIL
   dcp_info_ind = 1
  WITH nocounter
 ;end select
 IF (dcp_info_ind=1)
  DELETE  FROM dm_info
   WHERE info_domain="DATA MANAGEMENT"
    AND info_name="PATHWAYS"
   WITH nocounter
  ;end delete
  COMMIT
 ENDIF
 SET modify = predeclare
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD path_temp(
   1 qual[*]
     2 pathway_id = f8
 )
 SET reply->status_data.status = "F"
 DECLARE p_pathway_cnt = i4 WITH noconstant(0)
 DECLARE p_x = i4 WITH noconstant(0)
 DECLARE p_scriptfailed = c1 WITH noconstant("F")
 DECLARE p_tf_cnt = i4 WITH noconstant(0)
 DECLARE p_order_comp_cd = f8 WITH constant(uar_get_code_by("MEANING",16750,"ORDER CREATE"))
 DECLARE p_outcome_comp_cd = f8 WITH constant(uar_get_code_by("MEANING",16750,"RESULT OUTCO"))
 DECLARE p_comp_activated_cd = f8 WITH constant(uar_get_code_by("MEANING",16789,"ACTIVATED"))
 IF ((((p_order_comp_cd=- (1))) OR ((((p_outcome_comp_cd=- (1))) OR ((p_comp_activated_cd=- (1))))
 )) )
  CALL echo("Unable to load code values")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM pathway p
  PLAN (p
   WHERE  NOT ( EXISTS (
   (SELECT
    cn.pathway_id
    FROM cn_pathway_st cn
    WHERE p.pathway_id=cn.pw_group_nbr
     AND cn.type_mean="PHASE")))
    AND p.pathway_id > 0)
  HEAD REPORT
   p_pathway_cnt = 0
  DETAIL
   p_pathway_cnt = (p_pathway_cnt+ 1)
   IF (p_pathway_cnt > size(path_temp->qual,5))
    stat = alterlist(path_temp->qual,(p_pathway_cnt+ 200))
   ENDIF
   path_temp->qual[p_pathway_cnt].pathway_id = p.pathway_id
  FOOT REPORT
   stat = alterlist(path_temp->qual,p_pathway_cnt)
  WITH nocounter
 ;end select
 FOR (p_x = 1 TO value(p_pathway_cnt))
   RECORD request(
     1 dc_ind = i2
     1 new_ind = i2
     1 pathway_id = f8
     1 encntr_id = f8
     1 qual_time_frame[*]
       2 act_time_frame_id = f8
       2 encntr_id = f8
   ) WITH public
   SET request->dc_ind = 2
   SET request->new_ind = 1
   SET request->pathway_id = path_temp->qual[p_x].pathway_id
   SET request->encntr_id = - (1)
   SET p_tf_cnt = 0
   SELECT INTO "nl:"
    FROM act_time_frame atf,
     act_pw_comp apc
    PLAN (atf
     WHERE (atf.pathway_id=request->pathway_id))
     JOIN (apc
     WHERE apc.act_time_frame_id=atf.act_time_frame_id
      AND apc.comp_type_cd IN (p_order_comp_cd, p_outcome_comp_cd))
    ORDER BY atf.act_time_frame_id, apc.act_time_frame_id, apc.activated_dt_tm
    HEAD REPORT
     p_tf_cnt = 0
    HEAD atf.act_time_frame_id
     p_tf_cnt = (p_tf_cnt+ 1)
     IF (p_tf_cnt > value(size(request->qual_time_frame,5)))
      stat = alterlist(request->qual_time_frame,(p_tf_cnt+ 10))
     ENDIF
     request->qual_time_frame[p_tf_cnt].act_time_frame_id = atf.act_time_frame_id, p_found = 0
    DETAIL
     IF (p_found=0
      AND apc.comp_status_cd=p_comp_activated_cd)
      request->qual_time_frame[p_tf_cnt].encntr_id = apc.encntr_id, p_found = 1
     ENDIF
    FOOT  atf.act_time_frame_id
     IF (p_found=0)
      request->qual_time_frame[p_tf_cnt].encntr_id = apc.encntr_id
     ENDIF
     p_found = 0
    FOOT REPORT
     stat = alterlist(request->qual_time_frame,p_tf_cnt)
    WITH nocounter
   ;end select
   CALL echo(build("Loop#",p_x,", ID#",path_temp->qual[p_x].pathway_id))
   IF (value(size(request->qual_time_frame,5)) > 0)
    SET p_scriptfailed = callprg(dcp_upd_omf_pathway)
   ENDIF
   IF (p_scriptfailed="T")
    CALL echo("dcp_upd_omf_pathway returned failure - ROLLBACK")
    ROLLBACK
   ELSE
    CALL echo("dcp_upd_omf_pathway returned success - COMMIT")
    COMMIT
   ENDIF
   FREE RECORD request
 ENDFOR
 FREE RECORD path_temp
#exit_script
END GO
