CREATE PROGRAM dcp_get_pat_reltn:dba
 RECORD reply(
   1 data[*]
     2 reltn_disp = vc
     2 prsnl_name = vc
     2 prsnl_id = f8
     2 reltn_id = f8
     2 prsnl_reltn_ind = i2
     2 reltn_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp_reply(
   1 data[*]
     2 reltn_disp = vc
     2 prsnl_name = vc
     2 prsnl_id = f8
     2 reltn_id = f8
     2 prsnl_reltn_ind = i2
     2 reltn_cd = f8
 )
 DECLARE count1 = i4
 DECLARE count2 = i4
 DECLARE stat = i4
 DECLARE pzero = c1
 DECLARE ezero = c1
 DECLARE grpcnt = i4
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET count2 = 0
 SET stat = 0.0
 SET pzero = "T"
 SET ezero = "T"
 IF ((request->prsnl_id > 0))
  SET prsnl_group_reltn_where = "pgr.person_id = request->prsnl_id"
 ELSE
  SET prsnl_group_reltn_where = "pgr.person_id = pgr.person_id"
 ENDIF
 SET grpcnt = size(request->group_list,5)
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(grpcnt)),
   prsnl_group_reltn pgr,
   team_mem_ppr_reltn team,
   encntr_prsnl_reltn epr,
   prsnl pr
  PLAN (d1)
   JOIN (pgr
   WHERE (pgr.prsnl_group_id=request->group_list[d1.seq].group_id_value_cd)
    AND parser(prsnl_group_reltn_where))
   JOIN (team
   WHERE team.prsnl_group_reltn_id=pgr.prsnl_group_reltn_id
    AND team.active_ind=1
    AND team.beg_effective_dt_tm < cnvtdatetime(sysdate)
    AND team.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (epr
   WHERE (epr.encntr_id=request->encntr_id)
    AND epr.expiration_ind=0
    AND epr.beg_effective_dt_tm < cnvtdatetime(sysdate)
    AND epr.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND epr.prsnl_person_id=pgr.person_id
    AND epr.encntr_prsnl_r_cd=team.ppr_cd)
   JOIN (pr
   WHERE pr.person_id=epr.prsnl_person_id
    AND pr.active_ind=1)
  ORDER BY cnvtupper(trim(pr.name_full_formatted,3)) DESC
  HEAD REPORT
   stat = alterlist(reply->data,10)
  DETAIL
   count1 += 1
   IF (mod(count1,10)=2)
    stat = alterlist(reply->data,(count1+ 9))
   ENDIF
   reply->data[count1].reltn_disp = uar_get_code_display(epr.encntr_prsnl_r_cd), reply->data[count1].
   prsnl_name = pr.name_full_formatted, reply->data[count1].prsnl_id = pr.person_id,
   reply->data[count1].reltn_id = epr.encntr_prsnl_reltn_id, reply->data[count1].prsnl_reltn_ind = 0,
   reply->data[count1].reltn_cd = epr.encntr_prsnl_r_cd
  FOOT REPORT
   stat = alterlist(reply->data,count1)
   IF (count1 > 0)
    ezero = "F"
   ENDIF
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(grpcnt)),
   prsnl_group_reltn pgr,
   team_mem_ppr_reltn team,
   person_prsnl_reltn ppr,
   prsnl pr
  PLAN (d1)
   JOIN (pgr
   WHERE (pgr.prsnl_group_id=request->group_list[d1.seq].group_id_value_cd)
    AND parser(prsnl_group_reltn_where))
   JOIN (team
   WHERE team.prsnl_group_reltn_id=pgr.prsnl_group_reltn_id
    AND team.ppr_flag=0
    AND team.active_ind=1
    AND team.beg_effective_dt_tm < cnvtdatetime(sysdate)
    AND team.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (ppr
   WHERE (ppr.person_id=request->person_id)
    AND ppr.active_ind=1
    AND ppr.beg_effective_dt_tm < cnvtdatetime(sysdate)
    AND ppr.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND ppr.person_prsnl_r_cd=team.ppr_cd
    AND ppr.prsnl_person_id=pgr.person_id)
   JOIN (pr
   WHERE ppr.prsnl_person_id=pr.person_id
    AND pr.active_ind=1)
  ORDER BY cnvtupper(trim(pr.name_full_formatted,3))
  HEAD REPORT
   stat = alterlist(temp_reply->data,10)
  DETAIL
   count2 += 1
   IF (mod(count2,10)=2)
    stat = alterlist(temp_reply->data,(count2+ 9))
   ENDIF
   IF (count2 > 0)
    pzero = "F"
   ENDIF
   temp_reply->data[count2].reltn_disp = uar_get_code_display(ppr.person_prsnl_r_cd), temp_reply->
   data[count2].prsnl_name = pr.name_full_formatted, temp_reply->data[count2].prsnl_id = pr.person_id,
   temp_reply->data[count2].reltn_id = ppr.person_prsnl_reltn_id, temp_reply->data[count2].
   prsnl_reltn_ind = 1, temp_reply->data[count2].reltn_cd = ppr.person_prsnl_r_cd
  FOOT REPORT
   stat = alterlist(temp_reply->data,count2)
 ;end select
 SET stat = alterlist(reply->data,(count1+ count2))
 SET y = 1
 FOR (x = (count1+ 1) TO (count1+ count2))
   SET reply->data[x].reltn_disp = temp_reply->data[y].reltn_disp
   SET reply->data[x].prsnl_name = temp_reply->data[y].prsnl_name
   SET reply->data[x].prsnl_id = temp_reply->data[y].prsnl_id
   SET reply->data[x].reltn_id = temp_reply->data[y].reltn_id
   SET reply->data[x].prsnl_reltn_ind = temp_reply->data[y].prsnl_reltn_ind
   SET reply->data[x].reltn_cd = temp_reply->data[y].reltn_cd
   SET y += 1
 ENDFOR
 IF (pzero="T"
  AND ezero="T")
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
