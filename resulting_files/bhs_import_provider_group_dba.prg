CREATE PROGRAM bhs_import_provider_group:dba
 RECORD req(
   1 qual[*]
     2 name = vc
     2 groupid = vc
     2 person_id = f8
     2 empid = vc
     2 error = vc
     2 status = vc
 )
 CALL echo("copy rec over")
 SET b = 0
 FOR (y = 1 TO size(requestin->list_0,5))
   IF (textlen(trim(requestin->list_0[y].empid,3)) > 0
    AND textlen(trim(requestin->list_0[y].groupid,3)) > 0
    AND textlen(trim(requestin->list_0[y].name,3)) > 0)
    SET b = (b+ 1)
    SET stat = alterlist(req->qual,b)
    SET req->qual[b].empid = concat("*",trim(requestin->list_0[y].empid,3))
    SET req->qual[b].groupid = requestin->list_0[y].groupid
    SET req->qual[b].name = requestin->list_0[y].name
   ENDIF
 ENDFOR
 CALL echorecord(req)
 DECLARE tempname = vc WITH noconstant(" ")
 DECLARE tempen = vc WITH noconstant(" ")
 DECLARE tempempid = vc WITH noconstant(" ")
 DECLARE temppersonid = f8
 CALL echo("find users by EN")
 SELECT INTO "NL:"
  empid = substring(1,8,req->qual[d.seq].empid), p.person_id
  FROM prsnl p,
   (dummyt d  WITH seq = size(req->qual,5))
  PLAN (d)
   JOIN (p
   WHERE operator(p.username,"like",patstring(req->qual[d.seq].empid,1))
    AND p.active_ind=1)
  ORDER BY empid
  HEAD empid
   cnt = 0, cnt2 = 0, tempen = "",
   tempempid = "",
   CALL echo(build("headEmpID",empid)),
   CALL echo(p.name_full_formatted)
  DETAIL
   cnt = (cnt+ 1), tempen = replace(p.username,"1234567890","1234567890",3), tempempid = replace(req
    ->qual[d.seq].empid,"1234567890","1234567890",3),
   CALL echo(build("tempEN:",cnvtreal(tempen))),
   CALL echo(build("tempEmpId:",cnvtreal(tempempid)))
   IF (cnvtreal(tempen)=cnvtreal(tempempid))
    cnt2 = (cnt2+ 1), temppersonid = p.person_id
   ENDIF
  FOOT  empid
   IF (cnt=1)
    req->qual[d.seq].person_id = p.person_id
   ELSEIF (temppersonid > 0
    AND cnt2=1)
    req->qual[d.seq].person_id = temppersonid
   ELSE
    CALL echo("more then one Found"), req->qual[d.seq].error =
    "More then one person found for this empID", req->qual[d.seq].status = "Z"
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("perform inserts")
 FOR (x = 1 TO size(req->qual,5))
  SELECT INTO "NL:"
   p1.person_id
   FROM prsnl_group_reltn p1
   WHERE (p1.person_id=req->qual[x].person_id)
    AND p1.prsnl_group_id=cnvtreal(req->qual[x].groupid)
    AND p1.active_ind=1
    AND p1.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
   WITH nocounter
  ;end select
  IF (curqual=0
   AND (req->qual[x].person_id > 0))
   CALL echo("actually inserting row")
   INSERT  FROM prsnl_group_reltn p
    SET p.prsnl_group_reltn_id = seq(prsnl_seq,nextval), p.active_ind = 1, p.active_status_cd = 188,
     p.active_status_dt_tm = cnvtdatetime(curdate,curtime3), p.active_status_prsnl_id = 18525013, p
     .beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
     p.contributor_system_cd = 469, p.data_status_cd = 25, p.data_status_dt_tm = cnvtdatetime(curdate,
      curtime3),
     p.data_status_prsnl_id = 18525013, p.end_effective_dt_tm = cnvtdatetime(
      "31-DEC-2100 00:00:00.00"), p.person_id = req->qual[x].person_id,
     p.prsnl_group_id = cnvtreal(req->qual[x].groupid), p.prsnl_group_r_cd = 0, p.updt_applctx = 0,
     p.updt_cnt = 0, p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id = 18525013,
     p.updt_task = 0
    PLAN (p)
   ;end insert
   COMMIT
  ELSEIF (curqual=1)
   SET req->qual[x].error = "Person already exists for this group"
   SET stat = 0
  ELSEIF ((req->qual[x].person_id=0)
   AND textlen(req->qual[x].error) < 1)
   SET req->qual[x].error = "Person not found for this empID"
  ENDIF
 ENDFOR
 CALL echorecord(req)
 SET filename = build2("bhs_import_provider_group",substring(1,12,format(cnvtdatetime(curdate,curtime
     ),"MMDDYYYYHHMM;;q")))
 SELECT INTO value(filename)
  name = substring(1,30,req->qual[d.seq].name), empid = req->qual[d.seq].empid, groupid = req->qual[d
  .seq].groupid,
  person_id = req->qual[d.seq].person_id, error = substring(1,30,req->qual[d.seq].error)
  FROM (dummyt d  WITH seq = size(req->qual,5))
  PLAN (d
   WHERE (req->qual[d.seq].status="Z"))
  WITH format, pcformat('"',","), append
 ;end select
END GO
