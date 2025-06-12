CREATE PROGRAM dm_ocd_get_report:dba
 RECORD reply(
   1 ocd_number = i4
   1 tbl[*]
     2 table_name = vc
   1 tbl_cnt = i4
   1 cs[*]
     2 code_set = i4
     2 description = vc
   1 cs_cnt = i4
   1 app[*]
     2 application = f8
     2 description = vc
   1 app_cnt = i4
   1 task[*]
     2 task = f8
     2 description = vc
   1 task_cnt = i4
   1 req[*]
     2 request = f8
     2 description = vc
   1 req_cnt = i4
   1 apptask[*]
     2 app = f8
     2 task = f8
   1 apptask_cnt = i4
   1 taskreq[*]
     2 task = f8
     2 req = f8
   1 taskreq_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET ocd_number = request->ocd_number
 SELECT DISTINCT INTO "nl:"
  d.table_name
  FROM dm_afd_tables d
  WHERE d.alpha_feature_nbr=ocd_number
  ORDER BY d.table_name
  DETAIL
   reply->tbl_cnt = (reply->tbl_cnt+ 1), stat = alterlist(reply->tbl,reply->tbl_cnt), reply->tbl[
   reply->tbl_cnt].table_name = d.table_name
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
  d.code_set, d.description
  FROM dm_afd_code_value_set d
  WHERE d.alpha_feature_nbr=ocd_number
  ORDER BY d.code_set
  DETAIL
   reply->cs_cnt = (reply->cs_cnt+ 1), stat = alterlist(reply->cs,reply->cs_cnt), reply->cs[reply->
   cs_cnt].code_set = d.code_set,
   reply->cs[reply->cs_cnt].description = substring(1,60,d.description)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  d.application_number, d.description
  FROM dm_ocd_application d
  WHERE d.alpha_feature_nbr=ocd_number
  ORDER BY d.application_number
  DETAIL
   reply->app_cnt = (reply->app_cnt+ 1), stat = alterlist(reply->app,reply->app_cnt), reply->app[
   reply->app_cnt].application = d.application_number,
   reply->app[reply->app_cnt].description = substring(1,60,d.description)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  d.task_number, d.description
  FROM dm_ocd_task d
  WHERE d.alpha_feature_nbr=ocd_number
  ORDER BY d.task_number
  DETAIL
   reply->task_cnt = (reply->task_cnt+ 1), stat = alterlist(reply->task,reply->task_cnt), reply->
   task[reply->task_cnt].task = d.task_number,
   reply->task[reply->task_cnt].description = substring(1,60,d.description)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  d.request_number, d.description
  FROM dm_ocd_request d
  WHERE d.alpha_feature_nbr=ocd_number
  ORDER BY d.request_number
  DETAIL
   reply->req_cnt = (reply->req_cnt+ 1), stat = alterlist(reply->req,reply->req_cnt), reply->req[
   reply->req_cnt].request = d.request_number,
   reply->req[reply->req_cnt].description = substring(1,60,d.description)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  d.application_number, d.task_number
  FROM dm_ocd_app_task_r d
  WHERE d.alpha_feature_nbr=ocd_number
  ORDER BY d.application_number, d.task_number
  DETAIL
   reply->apptask_cnt = (reply->apptask_cnt+ 1), stat = alterlist(reply->apptask,reply->apptask_cnt),
   reply->apptask[reply->apptask_cnt].application = d.application_number,
   reply->apptask[reply->apptask_cnt].task = d.task_number
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  d.task_number, d.request_number
  FROM dm_ocd_task_req_r d
  WHERE d.alpha_feature_nbr=ocd_number
  ORDER BY d.task_number, d.request_number
  DETAIL
   reply->taskreq_cnt = (reply->taskreq_cnt+ 1), stat = alterlist(reply->taskreq,reply->taskreq_cnt),
   reply->taskreq[reply->taskreq_cnt].task = d.task_number,
   reply->taskreq[reply->taskreq_cnt].request = d.request_number
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
END GO
