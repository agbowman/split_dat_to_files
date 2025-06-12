CREATE PROGRAM cps_get_proxy:dba
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
 DECLARE cdx = i4 WITH noconstant(0)
 FREE SET internal
 RECORD internal(
   1 type_knt = i4
   1 type_list[*]
     2 proxy_type_cd = f8
 )
 FREE SET reply
 RECORD reply(
   1 proxy_cnt = i4
   1 qual[*]
     2 proxy_id = f8
     2 person_id = f8
     2 person_name = vc
     2 person_name_last = vc
     2 person_name_first = vc
     2 proxy_person_id = f8
     2 proxy_person_name = vc
     2 proxy_person_name_last = vc
     2 proxy_person_name_first = vc
     2 active_ind = i2
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 take_proxy_status_flag = i2
     2 proxy_type_cd = f8
     2 proxy_type_disp = c40
     2 proxy_type_desc = c60
     2 proxy_type_mean = c12
     2 group_proxy_id = f8
     2 group_proxy_name = vc
     2 group_proxy_ind = i2
     2 group_proxy_type_cd = f8
     2 group_proxy_type_disp = vc
     2 group_proxy_type_mean = c12
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
 SET ierrcode = 0
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c,
   (dummyt d  WITH seq = value(size(request->type_list,5)))
  PLAN (d
   WHERE d.seq > 0)
   JOIN (c
   WHERE c.code_set=16189
    AND (c.cdf_meaning=request->type_list[d.seq].proxy_meaning))
  HEAD REPORT
   knt = 0, stat = alterlist(internal->type_list,10)
  DETAIL
   knt = (knt+ 1)
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(internal->type_list,(knt+ 9))
   ENDIF
   internal->type_list[knt].proxy_type_cd = c.code_value
  FOOT REPORT
   internal->type_knt = knt, stat = alterlist(internal->type_list,knt)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 IF ((request->person_id_is_proxy_ind=1))
  SELECT
   IF ((request->active_only_ind=1))
    PLAN (p
     WHERE (p.proxy_person_id=request->person_id)
      AND expand(cdx,1,internal->type_knt,p.proxy_type_cd,internal->type_list[cdx].proxy_type_cd)
      AND p.active_ind=1
      AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
     JOIN (p1
     WHERE p1.person_id=p.proxy_person_id)
     JOIN (p2
     WHERE p2.person_id=p.person_id)
     JOIN (pg
     WHERE pg.prsnl_group_id=p.group_proxy_id)
   ELSEIF ((request->active_only_ind=2))
    PLAN (p
     WHERE (p.proxy_person_id=request->person_id)
      AND expand(cdx,1,internal->type_knt,p.proxy_type_cd,internal->type_list[cdx].proxy_type_cd)
      AND p.active_ind=1
      AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
     JOIN (p1
     WHERE p1.person_id=p.proxy_person_id)
     JOIN (p2
     WHERE p2.person_id=p.person_id)
     JOIN (pg
     WHERE pg.prsnl_group_id=p.group_proxy_id)
   ELSE
    PLAN (p
     WHERE (p.proxy_person_id=request->person_id)
      AND expand(cdx,1,internal->type_knt,p.proxy_type_cd,internal->type_list[cdx].proxy_type_cd))
     JOIN (p1
     WHERE p1.person_id=p.proxy_person_id)
     JOIN (p2
     WHERE p2.person_id=p.person_id)
     JOIN (pg
     WHERE pg.prsnl_group_id=p.group_proxy_id)
   ENDIF
   INTO "nl:"
   FROM proxy p,
    prsnl p1,
    prsnl p2,
    prsnl_group pg
   HEAD REPORT
    knt = 0, stat = alterlist(reply->qual,10)
   DETAIL
    knt = (knt+ 1)
    IF (mod(knt,10)=1
     AND knt != 1)
     stat = alterlist(reply->qual,(knt+ 9))
    ENDIF
    reply->qual[knt].proxy_id = p.proxy_id, reply->qual[knt].person_id = p.proxy_person_id, reply->
    qual[knt].person_name = p1.name_full_formatted,
    reply->qual[knt].person_name_last = p1.name_last, reply->qual[knt].person_name_first = p1
    .name_first, reply->qual[knt].proxy_person_id = p.person_id,
    reply->qual[knt].proxy_person_name = p2.name_full_formatted, reply->qual[knt].
    proxy_person_name_last = p2.name_last, reply->qual[knt].proxy_person_name_first = p2.name_first,
    reply->qual[knt].group_proxy_id = p.group_proxy_id, reply->qual[knt].group_proxy_name = pg
    .prsnl_group_name, reply->qual[knt].group_proxy_type_cd = pg.prsnl_group_type_cd,
    reply->qual[knt].group_proxy_type_mean = uar_get_code_meaning(pg.prsnl_group_type_cd)
    IF ((reply->qual[knt].group_proxy_id > 0))
     reply->qual[knt].group_proxy_ind = 1
    ENDIF
    reply->qual[knt].active_ind = p.active_ind, reply->qual[knt].beg_effective_dt_tm = p
    .beg_effective_dt_tm, reply->qual[knt].end_effective_dt_tm = p.end_effective_dt_tm,
    reply->qual[knt].take_proxy_status_flag = p.take_proxy_status_flag, reply->qual[knt].
    proxy_type_cd = p.proxy_type_cd, reply->qual[knt].updt_cnt = p.updt_cnt
   FOOT REPORT
    reply->proxy_cnt = knt, stat = alterlist(reply->qual,knt)
   WITH nocounter
  ;end select
  SELECT
   IF ((request->active_only_ind=1))
    PLAN (pgr
     WHERE (pgr.person_id=request->person_id)
      AND pgr.active_ind=1
      AND pgr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND pgr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
     JOIN (p
     WHERE p.group_proxy_id=pgr.prsnl_group_id
      AND expand(cdx,1,internal->type_knt,p.proxy_type_cd,internal->type_list[cdx].proxy_type_cd)
      AND p.active_ind=1
      AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
     JOIN (p1
     WHERE p1.person_id=p.person_id)
     JOIN (p2
     WHERE p2.person_id=p.proxy_person_id)
     JOIN (pg
     WHERE pg.prsnl_group_id=pgr.prsnl_group_id)
   ELSEIF ((request->active_only_ind=2))
    PLAN (pgr
     WHERE (pgr.person_id=request->person_id)
      AND pgr.active_ind=1
      AND pgr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
     JOIN (p
     WHERE p.group_proxy_id=pgr.prsnl_group_id
      AND expand(cdx,1,internal->type_knt,p.proxy_type_cd,internal->type_list[cdx].proxy_type_cd)
      AND p.active_ind=1
      AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
     JOIN (p1
     WHERE p1.person_id=p.person_id)
     JOIN (p2
     WHERE p2.person_id=p.proxy_person_id)
     JOIN (pg
     WHERE pg.prsnl_group_id=pgr.prsnl_group_id)
   ELSE
    PLAN (pgr
     WHERE (pgr.person_id=request->person_id))
     JOIN (p
     WHERE p.group_proxy_id=pgr.prsnl_group_id
      AND expand(cdx,1,internal->type_knt,p.proxy_type_cd,internal->type_list[cdx].proxy_type_cd))
     JOIN (p1
     WHERE p1.person_id=p.person_id)
     JOIN (p2
     WHERE p2.person_id=p.proxy_person_id)
     JOIN (pg
     WHERE pg.prsnl_group_id=pgr.prsnl_group_id)
   ENDIF
   INTO "nl:"
   FROM proxy p,
    prsnl p1,
    prsnl p2,
    prsnl_group pg,
    prsnl_group_reltn pgr
   HEAD REPORT
    knt = size(reply->qual,5), stat = alterlist(reply->qual,(knt+ 10))
   DETAIL
    knt = (knt+ 1)
    IF (mod(knt,10)=1
     AND knt != 1)
     stat = alterlist(reply->qual,(knt+ 9))
    ENDIF
    reply->qual[knt].proxy_id = p.proxy_id, reply->qual[knt].person_id = p1.person_id, reply->qual[
    knt].person_name = p1.name_full_formatted,
    reply->qual[knt].person_name_last = p1.name_last, reply->qual[knt].person_name_first = p1
    .name_first, reply->qual[knt].proxy_person_id = p2.person_id,
    reply->qual[knt].proxy_person_name = p2.name_full_formatted, reply->qual[knt].
    proxy_person_name_last = p2.name_last, reply->qual[knt].proxy_person_name_first = p2.name_first,
    reply->qual[knt].group_proxy_id = p.group_proxy_id, reply->qual[knt].group_proxy_name = pg
    .prsnl_group_name, reply->qual[knt].group_proxy_type_cd = pg.prsnl_group_type_cd,
    reply->qual[knt].group_proxy_type_mean = uar_get_code_meaning(pg.prsnl_group_type_cd)
    IF ((reply->qual[knt].group_proxy_id > 0))
     reply->qual[knt].group_proxy_ind = 1
    ENDIF
    reply->qual[knt].active_ind = p.active_ind, reply->qual[knt].beg_effective_dt_tm = p
    .beg_effective_dt_tm, reply->qual[knt].end_effective_dt_tm = p.end_effective_dt_tm,
    reply->qual[knt].take_proxy_status_flag = p.take_proxy_status_flag, reply->qual[knt].
    proxy_type_cd = p.proxy_type_cd, reply->qual[knt].updt_cnt = p.updt_cnt
   FOOT REPORT
    reply->proxy_cnt = knt, stat = alterlist(reply->qual,knt)
   WITH nocounter
  ;end select
 ELSE
  SELECT
   IF ((request->active_only_ind=1))
    PLAN (p
     WHERE (p.person_id=request->person_id)
      AND expand(cdx,1,internal->type_knt,p.proxy_type_cd,internal->type_list[cdx].proxy_type_cd)
      AND p.active_ind=1
      AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
     JOIN (p1
     WHERE p1.person_id=p.person_id)
     JOIN (p2
     WHERE p2.person_id=p.proxy_person_id)
     JOIN (pg
     WHERE pg.prsnl_group_id=p.group_proxy_id)
   ELSEIF ((request->active_only_ind=2))
    PLAN (p
     WHERE (p.person_id=request->person_id)
      AND expand(cdx,1,internal->type_knt,p.proxy_type_cd,internal->type_list[cdx].proxy_type_cd)
      AND p.active_ind=1
      AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
     JOIN (p1
     WHERE p1.person_id=p.person_id)
     JOIN (p2
     WHERE p2.person_id=p.proxy_person_id)
     JOIN (pg
     WHERE pg.prsnl_group_id=p.group_proxy_id)
   ELSE
    PLAN (p
     WHERE (p.person_id=request->person_id)
      AND expand(cdx,1,internal->type_knt,p.proxy_type_cd,internal->type_list[cdx].proxy_type_cd))
     JOIN (p1
     WHERE p1.person_id=p.person_id)
     JOIN (p2
     WHERE p2.person_id=p.proxy_person_id)
     JOIN (pg
     WHERE pg.prsnl_group_id=p.group_proxy_id)
   ENDIF
   INTO "nl:"
   FROM proxy p,
    prsnl p1,
    prsnl p2,
    prsnl_group pg
   HEAD REPORT
    knt = 0, stat = alterlist(reply->qual,10)
   DETAIL
    knt = (knt+ 1)
    IF (mod(knt,10)=1
     AND knt != 1)
     stat = alterlist(reply->qual,(knt+ 9))
    ENDIF
    reply->qual[knt].proxy_id = p.proxy_id, reply->qual[knt].person_id = p.person_id, reply->qual[knt
    ].person_name = p1.name_full_formatted,
    reply->qual[knt].person_name_last = p1.name_last, reply->qual[knt].person_name_first = p1
    .name_first, reply->qual[knt].proxy_person_id = p.proxy_person_id,
    reply->qual[knt].proxy_person_name = p2.name_full_formatted, reply->qual[knt].
    proxy_person_name_last = p2.name_last, reply->qual[knt].proxy_person_name_first = p2.name_first,
    reply->qual[knt].group_proxy_id = p.group_proxy_id, reply->qual[knt].group_proxy_name = pg
    .prsnl_group_name, reply->qual[knt].group_proxy_type_cd = pg.prsnl_group_type_cd,
    reply->qual[knt].group_proxy_type_mean = uar_get_code_meaning(pg.prsnl_group_type_cd)
    IF ((reply->qual[knt].group_proxy_id > 0))
     reply->qual[knt].group_proxy_ind = 1
    ENDIF
    reply->qual[knt].active_ind = p.active_ind, reply->qual[knt].beg_effective_dt_tm = p
    .beg_effective_dt_tm, reply->qual[knt].end_effective_dt_tm = p.end_effective_dt_tm,
    reply->qual[knt].take_proxy_status_flag = p.take_proxy_status_flag, reply->qual[knt].
    proxy_type_cd = p.proxy_type_cd, reply->qual[knt].updt_cnt = p.updt_cnt
   FOOT REPORT
    reply->proxy_cnt = knt, stat = alterlist(reply->qual,knt)
   WITH nocounter
  ;end select
 ENDIF
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "PROXY"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 FOR (ii = 1 TO internal->type_knt)
   CALL echo(cnvtstring(internal->type_list[ii].proxy_type_cd))
 ENDFOR
#exit_script
 IF (failed=false)
  IF ((reply->proxy_cnt < 1))
   SET reply->status_data.status = "Z"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
 SET script_version = "010 11/17/05 AR010912"
END GO
