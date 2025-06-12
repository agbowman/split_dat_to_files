CREATE PROGRAM dcp_get_usrs_ppr_for_prsnl_grp:dba
 RECORD reply(
   1 qual[*]
     2 prsnl_group_reltn_id = f8
     2 person_id = f8
     2 name_full_formatted = vc
     2 position_cd = f8
     2 position_disp = vc
     2 position_mean = c12
     2 ppr_qual[*]
       3 ppr_cd = f8
       3 ppr_desc = vc
       3 ppr_reltn_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET prsnl_where = fillstring(300," ")
 IF ((request->prsnl_id > 0))
  SET prsnl_where = concat("pg.prsnl_group_id = request->prsnl_group_id"," and pg.active_ind = 1",
   " and pg.beg_effective_dt_tm <= cnvtdatetime(curdate, curtime3)",
   " and pg.end_effective_dt_tm >= cnvtdatetime(curdate, curtime3)",
   " and pg.person_id = request->prsnl_id")
 ELSE
  SET prsnl_where = concat("pg.prsnl_group_id = request->prsnl_group_id"," and pg.active_ind = 1",
   " and pg.beg_effective_dt_tm <= cnvtdatetime(curdate, curtime3)",
   " and pg.end_effective_dt_tm >= cnvtdatetime(curdate, curtime3)")
 ENDIF
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET count2 = 0
 SELECT INTO "nl:"
  FROM prsnl p,
   prsnl_group_reltn pg,
   team_mem_ppr_reltn t
  PLAN (pg
   WHERE parser(trim(prsnl_where)))
   JOIN (p
   WHERE pg.person_id=p.person_id
    AND p.active_ind=1)
   JOIN (t
   WHERE t.prsnl_group_reltn_id=outerjoin(pg.prsnl_group_reltn_id)
    AND t.active_ind=outerjoin(1)
    AND t.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
    AND t.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3)))
  ORDER BY p.name_full_formatted, pg.prsnl_group_reltn_id, t.team_mem_ppr_reltn_id
  HEAD pg.prsnl_group_reltn_id
   IF (pg.prsnl_group_reltn_id > 0)
    count1 = (count1+ 1)
    IF (mod(count1,10)=1)
     stat = alterlist(reply->qual,(count1+ 9))
    ENDIF
    reply->qual[count1].prsnl_group_reltn_id = pg.prsnl_group_reltn_id, reply->qual[count1].person_id
     = p.person_id, reply->qual[count1].name_full_formatted = p.name_full_formatted,
    reply->qual[count1].position_cd = p.position_cd, count2 = 0
   ENDIF
  HEAD t.team_mem_ppr_reltn_id
   IF (t.team_mem_ppr_reltn_id > 0)
    count2 = (count2+ 1)
    IF (count2 > size(reply->qual[count1].ppr_qual,5))
     stat = alterlist(reply->qual[count1].ppr_qual,(count2+ 10))
    ENDIF
    reply->qual[count1].ppr_qual[count2].ppr_cd = t.ppr_cd, reply->qual[count1].ppr_qual[count2].
    ppr_desc =
    IF (t.ppr_cd > 0) uar_get_code_display(t.ppr_cd)
    ELSE ""
    ENDIF
    , reply->qual[count1].ppr_qual[count2].ppr_reltn_id = t.team_mem_ppr_reltn_id
   ENDIF
  FOOT  pg.prsnl_group_reltn_id
   stat = alterlist(reply->qual[count1].ppr_qual,count2)
  WITH nocounter, dontcare = t, dontcare = cv,
   outerjoin = d1
 ;end select
 IF (count1=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
  SET stat = alterlist(reply->qual,count1)
 ENDIF
END GO
