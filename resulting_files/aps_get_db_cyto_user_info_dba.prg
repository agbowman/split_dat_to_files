CREATE PROGRAM aps_get_db_cyto_user_info:dba
 RECORD reply(
   1 limits_qual[*]
     2 role = c40
     2 prsnl_id = f8
     2 username = c50
     2 role_cdf = c12
     2 requeue_flag = i2
   1 security_qual[*]
     2 role = c40
     2 prsnl_id = f8
     2 username = c50
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET reply->status_data.status = "F"
 SET stat = alterlist(reply->limits_qual,1)
 SET stat = alterlist(reply->security_qual,1)
 DECLARE i = i4
 DECLARE flag = i4
 SET cnt = 0
 SELECT INTO "nl:"
  not_on_table = decode(d1.seq,"security","limits"), c.display, p.name_full_formatted,
  pgr.prsnl_group_reltn_id, csl.sequence, css.sequence
  FROM code_value c,
   prsnl_group pg,
   prsnl_group_reltn pgr,
   prsnl p,
   dummyt d1,
   dummyt d2,
   cyto_screening_limits csl,
   cyto_screening_security css
  PLAN (c
   WHERE 357=c.code_set
    AND c.cdf_meaning IN ("CYTOTECH", "PATHOLOGIST", "PATHRESIDENT"))
   JOIN (pg
   WHERE c.code_value=pg.prsnl_group_type_cd
    AND pg.active_ind=1
    AND pg.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND pg.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (pgr
   WHERE pg.prsnl_group_id=pgr.prsnl_group_id
    AND pgr.active_ind=1)
   JOIN (p
   WHERE pgr.person_id=p.person_id)
   JOIN (((d1
   WHERE 1=d1.seq)
   JOIN (css
   WHERE p.person_id=css.prsnl_id
    AND 1=css.active_ind)
   ) ORJOIN ((d2
   WHERE 1=d2.seq)
   JOIN (csl
   WHERE p.person_id=csl.prsnl_id
    AND 1=csl.active_ind)
   ))
  HEAD REPORT
   x = 0, y = 0
  DETAIL
   posy = 0, posx = 0
   IF (not_on_table="security"
    AND c.cdf_meaning="CYTOTECH")
    posx = locateval(i,1,x,p.person_id,reply->security_qual[i].prsnl_id)
    IF (posx=0)
     x = (x+ 1)
     IF (x > 1)
      stat = alterlist(reply->security_qual,x)
     ENDIF
     reply->security_qual[x].role = c.display, reply->security_qual[x].prsnl_id = p.person_id, reply
     ->security_qual[x].username = p.name_full_formatted
    ENDIF
   ENDIF
   IF (not_on_table="limits")
    flag = 0, posy = locateval(i,1,y,p.person_id,reply->limits_qual[i].prsnl_id)
    IF (posy=0)
     IF ((((request->checkpathslidelmt=1)
      AND ((c.cdf_meaning="PATHOLOGIST") OR (c.cdf_meaning="PATHRESIDENT")) ) OR (c.cdf_meaning=
     "CYTOTECH")) )
      y = (y+ 1), posy = y
      IF (mod(y,10)=1)
       stat = alterlist(reply->limits_qual,(y+ 9))
      ENDIF
      flag = 1
     ENDIF
    ELSE
     IF (c.cdf_meaning="CYTOTECH")
      flag = 1
     ENDIF
    ENDIF
    IF (flag=1)
     reply->limits_qual[posy].role = c.display, reply->limits_qual[posy].role_cdf = c.cdf_meaning,
     reply->limits_qual[posy].prsnl_id = p.person_id,
     reply->limits_qual[posy].username = p.name_full_formatted, reply->limits_qual[posy].requeue_flag
      = csl.requeue_flag
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->security_qual,x), stat = alterlist(reply->limits_qual,y)
  WITH nocounter, outerjoin = d1, dontexist,
   outerjoin = d2, dontexist
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
