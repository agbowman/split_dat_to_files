CREATE PROGRAM cps_get_users_for_prsnl_groups:dba
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SET stat = alterlist(reply->qual,1)
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET nbr_to_get = cnvtint(size(request->proxy_type_list,5))
 CALL echo(build("nbr_to_get: ",nbr_to_get))
 IF (nbr_to_get < 1)
  SET code_value = 0.0
  SET code_set = 0
  SET code_cnt = 1
  SET cdf_meaning = fillstring(12," ")
  SET code_set = 357
  SET cdf_meaning = "PROXY"
  DECLARE i = i4
  SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,code_value)
  IF (code_cnt > 0)
   CALL echo(build("code_cnt: ",code_cnt))
   SET stat = alterlist(request->proxy_type_list,code_cnt)
   SET request->proxy_type_list[1].proxy_type_cd = code_value
   CALL echo(build("code_value: ",code_value))
   FOR (i = 2 TO code_cnt)
     SET index = i
     SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,index,code_value)
     CALL echo(build("stat: ",stat))
     IF (stat=0)
      CALL echo(build("code_value: ",code_value))
      SET request->proxy_type_list[i].proxy_type_cd = code_value
     ENDIF
   ENDFOR
  ELSE
   GO TO groups_error
  ENDIF
 ENDIF
 SET list_count = size(request->proxy_type_list,5)
 CALL echo(build("list_count: ",list_count))
 SELECT INTO "nl:"
  pgr.person_id, pg.prsnl_group_type_cd, pr.proxy_type_cd
  FROM proxy pr,
   prsnl_group_reltn pgr,
   prsnl_group pg,
   (dummyt d  WITH seq = value(list_count))
  PLAN (d)
   JOIN (pg
   WHERE (pg.prsnl_group_type_cd=request->proxy_type_list[d.seq].proxy_type_cd))
   JOIN (pgr
   WHERE pgr.prsnl_group_id=pg.prsnl_group_id
    AND pgr.active_ind=1
    AND pgr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pgr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (pr
   WHERE pr.group_proxy_id=pgr.prsnl_group_id
    AND pr.active_ind=1
    AND pr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  ORDER BY pgr.person_id, pg.prsnl_group_type_cd, pr.proxy_type_cd
  DETAIL
   count1 = (count1+ 1),
   CALL echo(build("count1: ",count1))
   IF (count1 > size(reply->qual,5))
    stat = alterlist(reply->qual,(count1+ 10))
   ENDIF
   CALL echo(build("pg.prsnl_group_id: ",pg.prsnl_group_id)), reply->qual[count1].prsnl_group_id = pg
   .prsnl_group_id, reply->qual[count1].prsnl_group_name = pg.prsnl_group_name,
   reply->qual[count1].beg_effective_dt_tm = pgr.beg_effective_dt_tm, reply->qual[count1].
   end_effective_dt_tm = pgr.end_effective_dt_tm,
   CALL echo(build("pgr.active_ind: ",pgr.active_ind)),
   reply->qual[count1].active_ind = pgr.active_ind,
   CALL echo(build("pgr.person_id: ",pgr.person_id)), reply->qual[count1].person_id = pgr.person_id,
   reply->qual[count1].proxy_type_cd = pr.proxy_type_cd, reply->qual[count1].group_proxy_type_cd = pg
   .prsnl_group_type_cd
  WITH nocounter
 ;end select
#groups_error
 IF (count1 < 1)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "PROXY"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
  SET stat = alterlist(reply->qual,count1)
 ENDIF
END GO
