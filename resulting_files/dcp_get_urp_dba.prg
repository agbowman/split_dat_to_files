CREATE PROGRAM dcp_get_urp:dba
 SET modify = predeclare
 RECORD reply(
   1 person_list[*]
     2 person_id = f8
     2 name_full_formatted = vc
     2 urp_list[*]
       3 urp = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE last_mod = c3 WITH private, noconstant("")
 DECLARE mod_date = c10 WITH private, noconstant("")
 DECLARE person_cnt = i4 WITH protect, noconstant(0)
 DECLARE urp_cnt = i4 WITH protect, noconstant(0)
 DECLARE req_person_cnt = i4 WITH protect, noconstant(size(request->person_list,5))
 DECLARE start = i4 WITH protect, noconstant(1)
 DECLARE nsize = i4 WITH protect, constant(50)
 DECLARE ntotal = i4 WITH noconstant((ceil((cnvtreal(req_person_cnt)/ nsize)) * nsize))
 DECLARE lidx = i4 WITH protect, noconstant(0)
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE cprsnl_org_reltn_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",23052,
   "ACCESSCNTRL"))
 DECLARE corg_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",278,"CLIENT"))
 DECLARE cactive_status_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 CALL echo("***********************************************")
 CALL echo(build("cPRSNL_ORG_RELTN_TYPE_CD=",cprsnl_org_reltn_type_cd))
 CALL echo(build("cORG_TYPE_CD=",corg_type_cd))
 CALL echo(build("cACTIVE_STATUS_CD=",cactive_status_cd))
 CALL echo("***********************************************")
 SET reply->status_data.status = "F"
 SET stat = alterlist(request->person_list,ntotal)
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
   prsnl p,
   prsnl_org_reltn_type port
  PLAN (d1
   WHERE initarray(start,evaluate(d1.seq,1,1,(start+ nsize))))
   JOIN (p
   WHERE expand(lidx,start,(start+ (nsize - 1)),p.person_id,request->person_list[lidx].person_id))
   JOIN (port
   WHERE port.prsnl_id=outerjoin(p.person_id)
    AND port.active_ind=outerjoin(1)
    AND port.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
    AND port.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3))
    AND port.org_type_cd=outerjoin(corg_type_cd)
    AND port.prsnl_org_reltn_type_cd=outerjoin(cprsnl_org_reltn_type_cd)
    AND port.active_status_cd=outerjoin(cactive_status_cd))
  ORDER BY p.person_id
  HEAD REPORT
   person_cnt = 0
  HEAD p.person_id
   person_cnt = (person_cnt+ 1), stat = alterlist(reply->person_list,person_cnt), reply->person_list[
   person_cnt].person_id = p.person_id,
   reply->person_list[person_cnt].name_full_formatted = p.name_full_formatted, urp_cnt = 0
  HEAD port.role_profile
   IF (size(trim(port.role_profile,3),1) > 0)
    urp_cnt = (urp_cnt+ 1), stat = alterlist(reply->person_list[person_cnt].urp_list,urp_cnt), reply
    ->person_list[person_cnt].urp_list[urp_cnt].urp = port.role_profile
   ENDIF
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,1)
 IF (errcode > 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus.operationname = errmsg
 ELSEIF (size(reply->person_list,5) > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SET last_mod = "000"
 SET mod_date = "12/06/2006"
 SET modify = nopredeclare
END GO
