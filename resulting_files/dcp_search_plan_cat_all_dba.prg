CREATE PROGRAM dcp_search_plan_cat_all:dba
 SET modify = predeclare
 RECORD reply(
   1 qual[*]
     2 pathway_catalog_id = f8
     2 version_pw_cat_id = f8
     2 description = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE ncnt = i4 WITH noconstant(0)
 DECLARE i18nhandle = i4 WITH noconstant(0)
 DECLARE highbuffer = c20 WITH noconstant(fillstring(20," "))
 DECLARE highvalues = vc
 DECLARE lowvalues = vc
 DECLARE where_clause = vc WITH noconstant(fillstring(500,""))
 DECLARE imaxreturnplans = i4 WITH noconstant(50)
 SET i18nhandle = uar_i18nalphabet_init()
 CALL uar_i18nalphabet_highchar(i18nhandle,highbuffer,size(highbuffer))
 SET highvalues = trim(highbuffer)
 CALL uar_i18nalphabet_end(i18nhandle)
 SET reply->status_data.status = "F"
 SET lowvalues = trim(cnvtupper(request->search_string))
 IF (value(size(lowvalues,1)) >= 3)
  SET where_clause = "pwc.description_key like '*"
  SET where_clause = concat(where_clause,cnvtupper(request->search_string))
  SET where_clause = concat(where_clause,"*'")
 ELSE
  SET where_clause = "(pwc.description_key BETWEEN LowValues AND HighValues)"
 ENDIF
 SET where_clause = concat(where_clause," AND pwc.type_mean in ('PATHWAY','CAREPLAN')")
 SET where_clause = concat(where_clause,
  " AND pwc.beg_effective_dt_tm <= cnvtdatetime(curdate, curtime3)")
 SET where_clause = concat(where_clause,
  " AND pwc.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)")
 SET where_clause = concat(where_clause," AND pwc.ref_owner_person_id = 0")
 SET where_clause = concat(where_clause," AND pwc.active_ind = 1")
 SELECT INTO "nl:"
  FROM pathway_catalog pwc
  WHERE parser(where_clause)
  ORDER BY pwc.description_key
  HEAD REPORT
   ncnt = 0, stat = alterlist(reply->qual,imaxreturnplans)
  DETAIL
   ncnt = (ncnt+ 1)
   IF ((ncnt > (size(reply->qual,5) - 1)))
    CALL cancel(1)
   ENDIF
   reply->qual[ncnt].pathway_catalog_id = pwc.pathway_catalog_id, reply->qual[ncnt].version_pw_cat_id
    = pwc.version_pw_cat_id, reply->qual[ncnt].description = trim(pwc.description)
  FOOT REPORT
   stat = alterlist(reply->qual,ncnt)
  WITH nocounter
 ;end select
 IF (size(reply->qual,5) > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
