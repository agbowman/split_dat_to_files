CREATE PROGRAM dcp_get_plan_cat_phases:dba
 SET modify = predeclare
 RECORD reply(
   1 planlist[*]
     2 pathway_catalog_id = f8
     2 description = vc
     2 active_ind = i2
     2 version = i4
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 owner_name = vc
     2 phaselist[*]
       3 pathway_catalog_id = f8
       3 description = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE nplancnt = i4 WITH noconstant(0)
 DECLARE nphasecnt = i4 WITH noconstant(0)
 DECLARE i18nhandle = i4 WITH noconstant(0)
 DECLARE highbuffer = c20 WITH noconstant(fillstring(20," "))
 DECLARE highvalues = vc
 DECLARE lowvalues = vc
 DECLARE where_clause = vc WITH noconstant(fillstring(500,""))
 DECLARE keyword = c1 WITH noconstant("N")
 SET i18nhandle = uar_i18nalphabet_init()
 CALL uar_i18nalphabet_highchar(i18nhandle,highbuffer,size(highbuffer))
 SET highvalues = trim(highbuffer)
 CALL uar_i18nalphabet_end(i18nhandle)
 SET reply->status_data.status = "F"
 SET lowvalues = trim(cnvtupper(request->description))
 IF (value(size(lowvalues,1)) >= 3)
  SET where_clause = "(pwc.description_key like '*"
  SET where_clause = concat(where_clause,cnvtupper(request->description))
  SET where_clause = concat(where_clause,"*')")
  SET keyword = "Y"
 ELSE
  SET where_clause = "(pwc.description_key BETWEEN LowValues AND HighValues)"
  SET keyword = "N"
 ENDIF
 SELECT INTO "nl:"
  FROM pathway_catalog pwc,
   pw_cat_reltn pcr,
   pathway_catalog pwc2,
   person p
  PLAN (pwc
   WHERE parser(where_clause)
    AND pwc.type_mean IN ("PATHWAY", "CAREPLAN")
    AND ((pwc.active_ind+ 0)=1))
   JOIN (pcr
   WHERE pcr.pw_cat_s_id=outerjoin(pwc.pathway_catalog_id)
    AND pcr.type_mean=outerjoin("GROUP"))
   JOIN (pwc2
   WHERE pwc2.pathway_catalog_id=outerjoin(pcr.pw_cat_t_id)
    AND pwc2.type_mean=outerjoin("PHASE")
    AND ((pwc2.active_ind+ 0)=outerjoin(1)))
   JOIN (p
   WHERE p.person_id=outerjoin(pwc.ref_owner_person_id))
  ORDER BY pwc.description, pwc.pathway_catalog_id, pwc.version,
   pwc2.pathway_catalog_id
  HEAD REPORT
   nplancnt = 0
  HEAD pwc.pathway_catalog_id
   nplancnt = (nplancnt+ 1)
   IF (keyword="N"
    AND nplancnt >= 50)
    stat = alterlist(reply->planlist,nplancnt),
    CALL cancel(1)
   ELSEIF (nplancnt > size(reply->planlist,5))
    stat = alterlist(reply->planlist,(nplancnt+ 10))
   ENDIF
   reply->planlist[nplancnt].pathway_catalog_id = pwc.pathway_catalog_id, reply->planlist[nplancnt].
   description = pwc.description, reply->planlist[nplancnt].active_ind = pwc.active_ind,
   reply->planlist[nplancnt].version = pwc.version, reply->planlist[nplancnt].beg_effective_dt_tm =
   pwc.beg_effective_dt_tm, reply->planlist[nplancnt].end_effective_dt_tm = pwc.end_effective_dt_tm,
   reply->planlist[nplancnt].owner_name = trim(p.name_full_formatted), nphasecnt = 0
  DETAIL
   IF (pwc2.pathway_catalog_id > 0.0)
    nphasecnt = (nphasecnt+ 1)
    IF (nphasecnt > size(reply->planlist[nplancnt].phaselist,5))
     stat = alterlist(reply->planlist[nplancnt].phaselist,(nphasecnt+ 10))
    ENDIF
    reply->planlist[nplancnt].phaselist[nphasecnt].pathway_catalog_id = pwc2.pathway_catalog_id,
    reply->planlist[nplancnt].phaselist[nphasecnt].description = pwc2.description
   ENDIF
  FOOT  pwc.pathway_catalog_id
   stat = alterlist(reply->planlist[nplancnt].phaselist,nphasecnt)
  FOOT REPORT
   stat = alterlist(reply->planlist,nplancnt)
  WITH nocounter
 ;end select
 IF (size(reply->planlist,5) > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
