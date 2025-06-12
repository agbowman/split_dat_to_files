CREATE PROGRAM dcp_search_regimen_cat_all_flx:dba
 SET modify = predeclare
 RECORD reply(
   1 regimenlist[*]
     2 catalog_id = f8
     2 synonym_id = f8
     2 synonym_name = vc
     2 primary_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE ncnt = i4 WITH noconstant(0)
 DECLARE searchstring = vc
 DECLARE searchtype = vc
 DECLARE rcf_where_clause = vc WITH noconstant(fillstring(500,""))
 DECLARE rcs_where_clause = vc WITH noconstant(fillstring(500,""))
 DECLARE rc_where_clause = vc WITH noconstant(fillstring(500,""))
 DECLARE maxqual = i4 WITH noconstant(50)
 DECLARE contains_search = vc WITH protect, constant("CONTAINS")
 SET reply->status_data.status = "F"
 SET searchstring = cnvtupper(trim(request->description,3))
 SET searchtype = trim(request->search_type,3)
 IF (value(request->max_qual) > 0)
  SET maxqual = request->max_qual
 ENDIF
 IF (textlen(searchstring)=0)
  DECLARE i18nhandle = i4 WITH noconstant(uar_i18nalphabet_init())
  DECLARE lowcharbuffer = c20 WITH protect, noconstant(fillstring(1," "))
  CALL uar_i18nalphabet_lowchar(i18nhandle,lowcharbuffer,1)
  SET searchstring = cnvtupper(trim(lowcharbuffer))
  CALL uar_i18nalphabet_end(i18nhandle)
 ENDIF
 SET searchstring = replace(searchstring,"\","\\",0)
 SET rc_where_clause = "rc.active_ind = 1"
 SET rc_where_clause = concat(rc_where_clause,
  " AND rc.beg_effective_dt_tm <= cnvtdatetime(curdate, curtime3)")
 SET rc_where_clause = concat(rc_where_clause,
  " AND rc.end_effective_dt_tm = cnvtdatetime('31-DEC-2100')")
 SET rc_where_clause = concat(rc_where_clause," AND rc.regimen_catalog_id > 0")
 SET rcs_where_clause = "rcs.regimen_catalog_id = rc.regimen_catalog_id"
 SET rcs_where_clause = concat(rcs_where_clause," AND rcs.regimen_cat_synonym_id > 0")
 IF (((searchtype=contains_search) OR (searchtype=""
  AND size(searchstring) >= 3)) )
  SET rcs_where_clause = concat(rcs_where_clause,build(' AND rcs.synonym_key like "*',searchstring,
    '*"'))
 ELSE
  SET rcs_where_clause = concat(rcs_where_clause,build(' AND rcs.synonym_key like "',searchstring,
    '*"'))
 ENDIF
 SET rcf_where_clause = "rcf.regimen_catalog_id = rcs.regimen_catalog_id"
 IF ((request->facility_cd > 0))
  SET rcf_where_clause = concat(rcf_where_clause,build(
    " AND rcf.location_cd in (request->facility_cd, 0)"))
 ELSE
  SET rcf_where_clause = concat(rcf_where_clause,build(" AND rcf.location_cd >= 0"))
 ENDIF
 SELECT DISTINCT INTO "nl:"
  rcs.regimen_catalog_id, rcs.regimen_cat_synonym_id, rcs.synonym_display,
  rcs.primary_ind
  FROM regimen_catalog rc,
   regimen_cat_synonym rcs,
   regimen_cat_facility_r rcf
  PLAN (rc
   WHERE parser(rc_where_clause))
   JOIN (rcs
   WHERE parser(rcs_where_clause))
   JOIN (rcf
   WHERE parser(rcf_where_clause))
  ORDER BY rcs.synonym_key
  HEAD REPORT
   ncnt = 0, stat = alterlist(reply->regimenlist,maxqual)
  DETAIL
   ncnt = (ncnt+ 1)
   IF (ncnt <= maxqual)
    reply->regimenlist[ncnt].catalog_id = rcs.regimen_catalog_id, reply->regimenlist[ncnt].synonym_id
     = rcs.regimen_cat_synonym_id, reply->regimenlist[ncnt].synonym_name = trim(rcs.synonym_display),
    reply->regimenlist[ncnt].primary_ind = rcs.primary_ind
   ELSE
    CALL cancel(1)
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->regimenlist,ncnt), replysize = ncnt
  WITH nocounter
 ;end select
 IF (size(reply->regimenlist,5) > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
 DECLARE last_mod = vc WITH protect, constant("001 DG025750 06/26/2013")
END GO
