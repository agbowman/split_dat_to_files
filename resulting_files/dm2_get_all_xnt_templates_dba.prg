CREATE PROGRAM dm2_get_all_xnt_templates:dba
 FREE RECORD reply
 RECORD reply(
   1 qual_cnt = i4
   1 qual[*]
     2 template_nbr = i4
     2 feature_nbr = i4
     2 name = vc
     2 top_level_table = vc
     2 job_cnt = i4
     2 token_cnt = i4
     2 tokens[*]
       3 token_str = vc
       3 promp_str = vc
       3 data_type_flag = i2
     2 jobs[*]
       3 job_id = f8
       3 job_name = vc
       3 active_flag = i2
       3 token_cnt = i4
       3 token_values[*]
         4 token_str = vc
         4 token_value = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE dgaxt_errmsg = vc WITH protect, noconstant("")
 DECLARE dgaxt_max_job_cnt = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  has_job_ind = negate(nullind(dpj.job_id))
  FROM dm_purge_template dpt,
   dm_purge_job dpj
  PLAN (dpt
   WHERE (dpt.schema_dt_tm=
   (SELECT
    max(dpt2.schema_dt_tm)
    FROM dm_purge_template dpt2
    WHERE dpt2.template_nbr=dpt.template_nbr))
    AND dpt.active_ind=1
    AND dpt.program_str="XNT*"
    AND dpt.feature_nbr > 0)
   JOIN (dpj
   WHERE dpj.template_nbr=outerjoin(dpt.template_nbr))
  ORDER BY dpt.template_nbr
  HEAD REPORT
   job_cnt = 0
  HEAD dpt.template_nbr
   reply->qual_cnt = (reply->qual_cnt+ 1), stat = alterlist(reply->qual,reply->qual_cnt), reply->
   qual[reply->qual_cnt].template_nbr = dpt.template_nbr,
   reply->qual[reply->qual_cnt].name = dpt.name, reply->qual[reply->qual_cnt].feature_nbr = dpt
   .feature_nbr, job_cnt = 0
  DETAIL
   IF (has_job_ind=1)
    job_cnt = (job_cnt+ 1), reply->qual[reply->qual_cnt].job_cnt = job_cnt, stat = alterlist(reply->
     qual[reply->qual_cnt].jobs,reply->qual[reply->qual_cnt].job_cnt),
    reply->qual[reply->qual_cnt].jobs[job_cnt].job_id = dpj.job_id, reply->qual[reply->qual_cnt].
    jobs[job_cnt].active_flag = dpj.active_flag, dgaxt_max_job_cnt = maxval(dgaxt_max_job_cnt,job_cnt
     )
   ENDIF
  WITH nocounter
 ;end select
 IF (error(dgaxt_errmsg,0) > 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "fetching jobs"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = curprog
  SET reply->status_data.subeventstatus[1].targetobjectvalue = dgaxt_errmsg
  GO TO exit_script
 ENDIF
 IF ((reply->qual_cnt > 0))
  SELECT INTO "nl:"
   FROM dm_purge_table dpt,
    (dummyt d  WITH seq = value(reply->qual_cnt))
   PLAN (d)
    JOIN (dpt
    WHERE (dpt.template_nbr=reply->qual[d.seq].template_nbr)
     AND (dpt.schema_dt_tm=
    (SELECT
     max(dpt2.schema_dt_tm)
     FROM dm_purge_table dpt2
     WHERE dpt2.template_nbr=dpt.template_nbr))
     AND dpt.purge_type_flag=5)
   DETAIL
    reply->qual[d.seq].top_level_table = dpt.parent_table
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM dm_purge_token dpt,
    (dummyt d  WITH seq = value(reply->qual_cnt))
   PLAN (d)
    JOIN (dpt
    WHERE (dpt.template_nbr=reply->qual[d.seq].template_nbr)
     AND (dpt.feature_nbr=reply->qual[d.seq].feature_nbr)
     AND (dpt.schema_dt_tm=
    (SELECT
     max(dpt2.schema_dt_tm)
     FROM dm_purge_token dpt2
     WHERE dpt2.template_nbr=dpt.template_nbr))
     AND dpt.token_str != "JOBNAME")
   HEAD REPORT
    token_idx = 0
   DETAIL
    reply->qual[d.seq].token_cnt = (reply->qual[d.seq].token_cnt+ 1), token_idx = reply->qual[d.seq].
    token_cnt, stat = alterlist(reply->qual[d.seq].tokens,reply->qual[d.seq].token_cnt),
    reply->qual[d.seq].tokens[token_idx].promp_str = dpt.prompt_str, reply->qual[d.seq].tokens[
    token_idx].token_str = dpt.token_str, reply->qual[d.seq].tokens[token_idx].data_type_flag = dpt
    .data_type_flag
   WITH nocounter
  ;end select
  IF (error(dgaxt_errmsg,0) > 0)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "fetching tokens"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = curprog
   SET reply->status_data.subeventstatus[1].targetobjectvalue = dgaxt_errmsg
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   FROM dm_purge_job_token dpjt,
    (dummyt d1  WITH seq = value(reply->qual_cnt)),
    (dummyt d2  WITH seq = value(dgaxt_max_job_cnt))
   PLAN (d1
    WHERE (reply->qual[d1.seq].job_cnt > 0))
    JOIN (d2
    WHERE (d2.seq <= reply->qual[d1.seq].job_cnt))
    JOIN (dpjt
    WHERE (dpjt.job_id=reply->qual[d1.seq].jobs[d2.seq].job_id))
   HEAD REPORT
    token_idx = 0
   DETAIL
    IF (dpjt.token_str="JOBNAME")
     reply->qual[d1.seq].jobs[d2.seq].job_name = dpjt.value
    ELSE
     reply->qual[d1.seq].jobs[d2.seq].token_cnt = (reply->qual[d1.seq].jobs[d2.seq].token_cnt+ 1),
     token_idx = reply->qual[d1.seq].jobs[d2.seq].token_cnt, stat = alterlist(reply->qual[d1.seq].
      jobs[d2.seq].token_values,reply->qual[d1.seq].jobs[d2.seq].token_cnt),
     reply->qual[d1.seq].jobs[d2.seq].token_values[token_idx].token_str = dpjt.token_str, reply->
     qual[d1.seq].jobs[d2.seq].token_values[token_idx].token_value = dpjt.value
    ENDIF
   WITH nocounter
  ;end select
  IF (error(dgaxt_errmsg,0) > 0)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "fetching token values"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = curprog
   SET reply->status_data.subeventstatus[1].targetobjectvalue = dgaxt_errmsg
   GO TO exit_script
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
END GO
