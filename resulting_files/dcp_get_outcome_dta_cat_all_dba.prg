CREATE PROGRAM dcp_get_outcome_dta_cat_all:dba
 RECORD reply(
   1 list[*]
     2 description = vc
     2 task_assay_cd = f8
     2 mnemonic = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE num = i4 WITH noconstant(0)
 DECLARE cfailed = c1 WITH noconstant("F")
 DECLARE where_clause = vc WITH noconstant(fillstring(500,""))
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE i18nhandle = i4 WITH noconstant(0)
 DECLARE highbuffer = c20 WITH noconstant(fillstring(20," "))
 DECLARE highvalue = vc
 DECLARE lowbuffer = c20 WITH noconstant(fillstring(20," "))
 DECLARE lowvalue = vc
 SET i18nhandle = uar_i18nalphabet_init()
 CALL uar_i18nalphabet_nextdchar(i18nhandle,cnvtupper(substring(1,1,request->search_string)),1,
  highbuffer,size(highbuffer))
 SET highvalue = trim(highbuffer)
 IF (highvalue="")
  CALL uar_i18nalphabet_highchar(i18nhandle,highbuffer,size(highbuffer))
  SET highvalue = trim(highbuffer)
 ENDIF
 IF (value(size(request->search_string,1)) >= 3)
  SET where_clause = concat("oc.description_key LIKE '*",cnvtupper(request->search_string),"*'")
 ELSEIF ((request->search_string > " "))
  SET where_clause =
  "oc.description_key BETWEEN trim(cnvtupper(request->search_string)) AND highValue"
 ELSE
  CALL uar_i18nalphabet_lowalnum(i18nhandle,lowbuffer,size(lowbuffer))
  SET lowvalue = trim(lowbuffer)
  SET where_clause = "oc.description_key BETWEEN lowValue AND highValue"
  SET where_clause = concat(where_clause," and oc.outcome_catalog_id > 0.0")
 ENDIF
 CALL uar_i18nalphabet_end(i18nhandle)
 SELECT DISTINCT INTO "nl:"
  FROM outcome_catalog oc,
   discrete_task_assay dta
  PLAN (oc
   WHERE parser(where_clause))
   JOIN (dta
   WHERE oc.task_assay_cd=dta.task_assay_cd)
  ORDER BY oc.description_key, oc.task_assay_cd
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (cnt > size(reply->list,5))
    stat = alterlist(reply->list,(cnt+ 10))
   ENDIF
   reply->list[cnt].description = trim(oc.description), reply->list[cnt].task_assay_cd = oc
   .task_assay_cd, reply->list[cnt].mnemonic = dta.mnemonic
  FOOT REPORT
   stat = alterlist(reply->list,cnt)
  WITH nocounter
 ;end select
 IF (cfailed="T")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET last_mod = "XXX"
END GO
