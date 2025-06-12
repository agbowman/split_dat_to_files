CREATE PROGRAM cps_get_person_proxy:dba
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
 FREE SET reply
 RECORD reply(
   1 person_id = f8
   1 person_name = c100
   1 proxylist[*]
     2 proxy_type_cd = f8
     2 proxy_type_disp = c40
     2 proxy_type_mean = c12
     2 proxy_person_id = f8
     2 proxy_person_name = c100
     2 group_proxy_id = f8
     2 group_proxy_name = c100
     2 group_proxy_type_cd = f8
     2 group_proxy_type_disp = c40
     2 group_proxy_type_mean = c12
     2 group_ind = i2
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 proxy_id = f8
     2 active_ind = i2
     2 take_proxy_status_flag = i2
     2 prsnl_group_name = vc
     2 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count = 0
 DECLARE proxy_cd = f8
 SELECT INTO "nl:"
  FROM prsnl p
  PLAN (p
   WHERE (p.person_id=request->person_id))
  DETAIL
   reply->person_id = p.person_id, reply->person_name = p.name_full_formatted
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM proxy p,
   prsnl pr
  PLAN (p
   WHERE (p.proxy_person_id=request->person_id)
    AND p.person_id != 0
    AND p.proxy_id != 0
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (pr
   WHERE pr.person_id=p.person_id)
  HEAD REPORT
   col + 0
  DETAIL
   count = (count+ 1)
   IF (count > size(reply->proxylist,5))
    stat = alterlist(reply->proxylist,(count+ 10))
   ENDIF
   reply->proxylist[count].proxy_id = p.proxy_id, reply->proxylist[count].proxy_person_id = p
   .person_id, reply->proxylist[count].proxy_person_name = pr.name_full_formatted,
   reply->proxylist[count].group_ind = 0, reply->proxylist[count].proxy_type_cd = p.proxy_type_cd,
   reply->proxylist[count].take_proxy_status_flag = p.take_proxy_status_flag,
   reply->proxylist[count].active_ind = p.active_ind, reply->proxylist[count].beg_effective_dt_tm = p
   .beg_effective_dt_tm, reply->proxylist[count].end_effective_dt_tm = p.end_effective_dt_tm,
   reply->proxylist[count].updt_cnt = p.updt_cnt
  FOOT REPORT
   col + 0
  WITH nocounter
 ;end select
 CALL echo(build("person id:",request->person_id))
 SELECT INTO "nl:"
  FROM prsnl_group_reltn pgr,
   prsnl_group pg,
   prsnl pr,
   proxy p
  PLAN (pgr
   WHERE (pgr.person_id=request->person_id)
    AND pgr.active_ind=1
    AND pgr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pgr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (p
   WHERE p.group_proxy_id=pgr.prsnl_group_id
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (pr
   WHERE pr.person_id=p.person_id)
   JOIN (pg
   WHERE pg.prsnl_group_id=pgr.prsnl_group_id)
  HEAD REPORT
   col + 0
  DETAIL
   IF (uar_get_code_meaning(pg.prsnl_group_type_cd)="PROXY")
    count = (count+ 1)
    IF (count > size(reply->proxylist,5))
     stat = alterlist(reply->proxylist,(count+ 10))
    ENDIF
    reply->proxylist[count].proxy_id = p.proxy_id, reply->proxylist[count].proxy_person_id = p
    .person_id, reply->proxylist[count].proxy_person_name = pr.name_full_formatted,
    reply->proxylist[count].group_proxy_id = p.group_proxy_id, reply->proxylist[count].group_ind = 1,
    reply->proxylist[count].proxy_type_cd = p.proxy_type_cd,
    reply->proxylist[count].group_proxy_type_cd = pg.prsnl_group_type_cd, reply->proxylist[count].
    prsnl_group_name = pg.prsnl_group_name, reply->proxylist[count].group_proxy_type_mean =
    uar_get_code_meaning(pg.prsnl_group_type_cd),
    reply->proxylist[count].active_ind = pgr.active_ind, reply->proxylist[count].beg_effective_dt_tm
     = p.beg_effective_dt_tm, reply->proxylist[count].end_effective_dt_tm = p.end_effective_dt_tm,
    reply->proxylist[count].updt_cnt = p.updt_cnt
   ENDIF
  FOOT REPORT
   col + 0
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->proxylist,count)
 IF (count < 1)
  SET ierrcode = 0
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TASK_ACTIVITY"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  ELSE
   CALL echo("Here")
   SET reply->status_data.status = "Z"
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET script_version = "004 06/02/05 MH2659"
END GO
