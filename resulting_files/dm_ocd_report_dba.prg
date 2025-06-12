CREATE PROGRAM dm_ocd_report:dba
 RECORD reply(
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
 SET fname = build("Ocd_Schema_",cnvtstring(ocd_number),".txt")
 SET line80 = fillstring(80," ")
 SET line130 = fillstring(130," ")
 SELECT INTO value(fname)
  d.table_name
  FROM dm_afd_tables d
  WHERE d.alpha_feature_nbr=ocd_number
  ORDER BY d.table_name
  DETAIL
   line80 = concat("/Tablename = ",trim(d.table_name),"/ ;"), line80, row + 1
  WITH maxrow = 1, maxcol = 512, noheading,
   format = variable, formfeed = none
 ;end select
 SELECT DISTINCT INTO value(fname)
  d.code_set, d.description
  FROM dm_afd_code_value_set d
  WHERE d.alpha_feature_nbr=ocd_number
  ORDER BY d.code_set
  DETAIL
   desc = fillstring(60," "), desc = replace(d.description,"/","-",0), desc = replace(desc,",",":",0),
   line130 = concat("/Codeset = ",trim(cnvtstring(d.code_set)),", ",trim(desc),"/ ;"), line130, row
    + 1
  WITH maxrow = 1, maxcol = 512, noheading,
   format = variable, formfeed = none, append
 ;end select
 SELECT INTO value(fname)
  d.application_number, d.description
  FROM dm_ocd_application d
  WHERE d.alpha_feature_nbr=ocd_number
  ORDER BY d.application_number
  DETAIL
   desc = fillstring(60," "), desc = replace(substring(1,60,d.description),"/","-",0), desc = replace
   (desc,",",":",0),
   line130 = concat("/App = ",trim(cnvtstring(d.application_number)),", ",trim(desc),"/ ;"), line130,
   row + 1
  WITH maxrow = 1, maxcol = 512, noheading,
   format = variable, formfeed = none, append
 ;end select
 SELECT INTO value(fname)
  d.task_number, d.description
  FROM dm_ocd_task d
  WHERE d.alpha_feature_nbr=ocd_number
  ORDER BY d.task_number
  DETAIL
   desc = fillstring(60," "), desc = replace(substring(1,60,d.description),"/","-",0), desc = replace
   (desc,",",":",0),
   line130 = concat("/Task = ",trim(cnvtstring(d.task_number)),", ",trim(desc),"/ ;"), line130, row
    + 1
  WITH maxrow = 1, maxcol = 512, noheading,
   format = variable, formfeed = none, append
 ;end select
 SELECT INTO value(fname)
  d.request_number, d.description
  FROM dm_ocd_request d
  WHERE d.alpha_feature_nbr=ocd_number
  ORDER BY d.request_number
  DETAIL
   desc = fillstring(60," "), desc = replace(substring(1,60,d.description),"/","-",0), desc = replace
   (desc,",",":",0),
   line130 = concat("/Req = ",trim(cnvtstring(d.request_number)),", ",trim(desc),"/ ;"), line130, row
    + 1
  WITH maxrow = 1, maxcol = 512, noheading,
   format = variable, formfeed = none, append
 ;end select
 SELECT INTO value(fname)
  d.application_number, d.task_number
  FROM dm_ocd_app_task_r d
  WHERE d.alpha_feature_nbr=ocd_number
  ORDER BY d.application_number, d.task_number
  DETAIL
   line130 = concat("/App_Task = ",trim(cnvtstring(d.application_number)),"_",trim(cnvtstring(d
      .task_number)),"/ ;"), line130, row + 1
  WITH maxrow = 1, maxcol = 512, noheading,
   format = variable, formfeed = none, append
 ;end select
 SELECT INTO value(fname)
  d.task_number, d.request_number
  FROM dm_ocd_task_req_r d
  WHERE d.alpha_feature_nbr=ocd_number
  ORDER BY d.task_number, d.request_number
  DETAIL
   line130 = concat("/Task_Req = ",trim(cnvtstring(d.task_number)),"_",trim(cnvtstring(d
      .request_number)),"/ ;"), line130, row + 1
  WITH maxrow = 1, maxcol = 512, noheading,
   format = variable, formfeed = none, append
 ;end select
 SET reply->status_data.status = "S"
END GO
