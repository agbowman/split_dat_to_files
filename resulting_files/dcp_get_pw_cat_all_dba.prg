CREATE PROGRAM dcp_get_pw_cat_all:dba
 RECORD reply(
   1 qual[*]
     2 pathway_catalog_id = f8
     2 description = vc
     2 active_ind = i2
     2 version = i4
     2 version_pw_cat_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET ncnt = 0
 SET reply->status_data.status = "F"
 SET i18nhandle = uar_i18nalphabet_init()
 SET highbuffer = "                    "
 CALL uar_i18nalphabet_highchar(i18nhandle,highbuffer,size(highbuffer))
 SET highvalues = trim(highbuffer)
 CALL uar_i18nalphabet_end(i18nhandle)
 SELECT INTO "nl:"
  pwc.pathway_catalog_id, pwc.description_key
  FROM pathway_catalog pwc
  WHERE ((pwc.description_key BETWEEN trim(cnvtupper(request->description)) AND highvalues) OR ((
  request->description=" ")))
   AND pwc.type_mean=null
  ORDER BY pwc.description_key, version
  HEAD REPORT
   ncnt = 0
  DETAIL
   ncnt = (ncnt+ 1)
   IF (ncnt > size(reply->qual,5))
    stat = alterlist(reply->qual,(ncnt+ 10))
   ENDIF
   reply->qual[ncnt].pathway_catalog_id = pwc.pathway_catalog_id, reply->qual[ncnt].description =
   trim(pwc.description), reply->qual[ncnt].active_ind = pwc.active_ind,
   reply->qual[ncnt].version = pwc.version, reply->qual[ncnt].version_pw_cat_id = pwc
   .version_pw_cat_id
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SET stat = alterlist(reply->qual,ncnt)
END GO
