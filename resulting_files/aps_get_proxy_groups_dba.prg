CREATE PROGRAM aps_get_proxy_groups:dba
 RECORD reply(
   1 qual[*]
     2 prsnl_group_id = f8
     2 prsnl_group_name = vc
     2 belong_to_group = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE search_flt = c200
 DECLARE search_cdf = c200
 SET val_srch_flt = 0
 SET x = 0
 SET qual_size = cnvtint(size(request->qual,5))
 IF (qual_size=1)
  SET search_cdf = build('cv.cdf_meaning ="',request->qual[1].group_type_cdf,'"')
 ELSEIF (qual_size > 1)
  FOR (x = 1 TO qual_size)
    IF (x=1)
     SET search_cdf = build('cv.cdf_meaning in("',request->qual[x].group_type_cdf)
    ELSEIF (x=qual_size)
     SET search_cdf = build(search_cdf,'","',request->qual[x].group_type_cdf,'")')
    ELSE
     SET search_cdf = build(search_cdf,'","',request->qual[x].group_type_cdf)
    ENDIF
  ENDFOR
 ELSE
  SET search_cdf = 'cv.cdf_meaning in("APCORRGRP","CYTORPTGRP","CYTOTECH",'
  SET search_cdf = build(search_cdf,'"HISTOTECH","PATHOLOGIST","PATHRESIDENT","PATHUSER")')
 ENDIF
 CALL echo(build("CDF = ",search_cdf))
 IF (textlen(trim(request->search_crit))=0)
  CALL echo("has no search crit")
  SET search_flt = "0 = 0"
 ELSE
  CALL echo("has search crit")
  SET search_flt = "cnvtupper(pg.prsnl_group_name) ="
  SET search_flt = build(search_flt,' "',cnvtupper(request->search_crit))
  SET search_flt = build(search_flt,'*"')
 ENDIF
 CALL echo(build("search crit = ",request->search_crit))
 CALL echo(build("search_flt = ",search_flt))
 SELECT INTO "nl:"
  pg.prsnl_group_id, pg.prsnl_group_name, join_path = decode(pgr.seq,1,0)
  FROM code_value cv,
   prsnl_group pg,
   prsnl_group_reltn pgr,
   (dummyt d  WITH seq = 1)
  PLAN (cv
   WHERE cv.code_set=357
    AND parser(search_cdf)
    AND cv.active_ind=1
    AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (pg
   WHERE cv.code_value=pg.prsnl_group_type_cd
    AND parser(search_flt)
    AND pg.active_ind=1
    AND pg.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pg.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (d)
   JOIN (pgr
   WHERE pg.prsnl_group_id=pgr.prsnl_group_id
    AND (pgr.person_id=request->person_id)
    AND pgr.person_id != 0.0
    AND pgr.active_ind=1
    AND pgr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pgr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  HEAD REPORT
   group_cnt = 0
  DETAIL
   group_cnt = (group_cnt+ 1)
   IF (mod(group_cnt,10)=1)
    stat = alterlist(reply->qual,(group_cnt+ 9))
   ENDIF
   reply->qual[group_cnt].prsnl_group_id = pg.prsnl_group_id, reply->qual[group_cnt].prsnl_group_name
    = pg.prsnl_group_name
   IF (join_path=1)
    reply->qual[group_cnt].belong_to_group = 1
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->qual,group_cnt)
  WITH nocounter, outerjoin = d
 ;end select
 IF (curqual <= 0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "PRSNL_GROUP"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
