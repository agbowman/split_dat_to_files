CREATE PROGRAM cp_get_ops_details:dba
 RECORD reply(
   1 qual[*]
     2 control_group_name = c100
     2 ops_job_name = c100
     2 batch_descr = c100
     2 dist_descr = c100
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET cnt = 0
 IF ((request->option_selected=1))
  SELECT INTO "nl:"
   ocg.name, oj.name, ojs.batch_selection,
   cd.dist_descr
   FROM ops_control_group ocg,
    charting_operations co,
    ops_job_step ojs,
    ops_job oj,
    ops_task ot,
    chart_distribution cd
   PLAN (cd
    WHERE (cd.distribution_id=request->qualified_id))
    JOIN (co
    WHERE co.param_type_flag=2
     AND co.active_ind=1
     AND co.param=cnvtstring(cd.distribution_id))
    JOIN (ojs
    WHERE ojs.batch_selection=co.batch_name
     AND ojs.request_number=1300008)
    JOIN (oj
    WHERE oj.ops_job_id=ojs.ops_job_id)
    JOIN (ot
    WHERE ot.ops_job_id=oj.ops_job_id)
    JOIN (ocg
    WHERE ocg.ops_control_grp_id=ot.ops_control_grp_id)
   DETAIL
    cnt = (cnt+ 1), stat = alterlist(reply->qual,cnt), reply->qual[cnt].control_group_name = ocg.name,
    reply->qual[cnt].ops_job_name = oj.name, reply->qual[cnt].batch_descr = ojs.batch_selection,
    reply->qual[cnt].dist_descr = cd.dist_descr
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   ocg.name, oj.name, ojs.batch_selection,
   cd.dist_descr
   FROM ops_control_group ocg,
    charting_operations co,
    ops_job_step ojs,
    ops_job oj,
    ops_task ot,
    chart_distribution cd
   PLAN (co
    WHERE co.param_type_flag=2
     AND co.active_ind=1
     AND (co.charting_operations_id=request->qualified_id))
    JOIN (cd
    WHERE cd.distribution_id=cnvtreal(co.param))
    JOIN (ojs
    WHERE ojs.batch_selection=co.batch_name
     AND ojs.request_number=1300008)
    JOIN (oj
    WHERE oj.ops_job_id=ojs.ops_job_id)
    JOIN (ot
    WHERE ot.ops_job_id=oj.ops_job_id)
    JOIN (ocg
    WHERE ocg.ops_control_grp_id=ot.ops_control_grp_id)
   DETAIL
    cnt = (cnt+ 1), stat = alterlist(reply->qual,cnt), reply->qual[cnt].control_group_name = ocg.name,
    reply->qual[cnt].ops_job_name = oj.name, reply->qual[cnt].batch_descr = ojs.batch_selection,
    reply->qual[cnt].dist_descr = cd.dist_descr
   WITH nocounter
  ;end select
 ENDIF
END GO
