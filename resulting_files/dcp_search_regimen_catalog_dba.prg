CREATE PROGRAM dcp_search_regimen_catalog:dba
 SET modify = predeclare
 RECORD reply(
   1 regimenlist[*]
     2 regimen_catalog_id = f8
     2 regimen_name = vc
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
 DECLARE imaxreturnregimens = i4 WITH noconstant(50)
 SET i18nhandle = uar_i18nalphabet_init()
 CALL uar_i18nalphabet_highchar(i18nhandle,highbuffer,size(highbuffer))
 SET highvalues = trim(highbuffer)
 CALL uar_i18nalphabet_end(i18nhandle)
 SET reply->status_data.status = "F"
 SET lowvalues = trim(cnvtupper(request->search_string))
 IF (value(size(lowvalues,1)) >= 3)
  SET where_clause = "rcs.synonym_key like '*"
  SET where_clause = concat(where_clause,cnvtupper(request->search_string))
  SET where_clause = concat(where_clause,"*'")
 ELSE
  SET where_clause = "rcs.synonym_key BETWEEN LowValues AND HighValues"
 ENDIF
 SELECT INTO "nl:"
  FROM regimen_cat_synonym rcs
  WHERE parser(where_clause)
   AND rcs.primary_ind=1
   AND rcs.regimen_catalog_id > 0
  ORDER BY rcs.synonym_key
  HEAD REPORT
   ncnt = 0, stat = alterlist(reply->regimenlist,imaxreturnregimens)
  DETAIL
   ncnt = (ncnt+ 1)
   IF ((ncnt > (size(reply->regimenlist,5) - 1)))
    CALL cancel(1)
   ENDIF
   reply->regimenlist[ncnt].regimen_catalog_id = rcs.regimen_catalog_id, reply->regimenlist[ncnt].
   regimen_name = trim(rcs.synonym_display)
  FOOT REPORT
   stat = alterlist(reply->regimenlist,ncnt)
  WITH nocounter
 ;end select
 IF (size(reply->regimenlist,5) > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
