CREATE PROGRAM dcp_get_privs_by_privstring:dba
 RECORD reply(
   1 privilege_cd = f8
   1 privilege_disp = c40
   1 privilege_desc = c60
   1 privilege_mean = c12
   1 priv_status = c1
   1 privs[*]
     2 privilege_id = f8
     2 position_cd = f8
     2 position_disp = c40
     2 position_desc = c60
     2 position_mean = c12
     2 ppr_cd = f8
     2 ppr_disp = c40
     2 ppr_desc = c60
     2 ppr_mean = c12
     2 priv_value_cd = f8
     2 priv_value_disp = c40
     2 priv_value_desc = c60
     2 priv_value_mean = c12
     2 except_cnt = i4
     2 excepts[*]
       3 exception_entity_name = c40
       3 exception_type_cd = f8
       3 exception_type_disp = c40
       3 exception_type_desc = c60
       3 exception_type_mean = c12
       3 exception_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->priv_status = "F"
 SET reply->status_data.status = "F"
 DECLARE x = i4 WITH public, noconstant(0)
 DECLARE y = i4 WITH public, noconstant(0)
 DECLARE privilege_cd = f8 WITH public, noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(6016,request->privilege_mean,1,privilege_cd)
 SET reply->privilege_cd = privilege_cd
 SELECT INTO "nl:"
  FROM privilege p,
   priv_loc_reltn plr
  PLAN (p
   WHERE p.privilege_cd=privilege_cd
    AND p.active_ind=1)
   JOIN (plr
   WHERE plr.priv_loc_reltn_id=p.priv_loc_reltn_id)
  DETAIL
   x = (x+ 1)
   IF (x > size(reply->privs,5))
    stat = alterlist(reply->privs,(x+ 9))
   ENDIF
   reply->privs[x].position_cd = plr.position_cd, reply->privs[x].ppr_cd = plr.ppr_cd, reply->privs[x
   ].priv_value_cd = p.priv_value_cd,
   reply->privs[x].privilege_id = p.privilege_id
  FOOT REPORT
   stat = alterlist(reply->privs,x)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->priv_status = "Z"
  SET reply->status_data.status = "Z"
  GO TO programend
 ELSE
  SET reply->priv_status = "S"
  SET reply->status_data.status = "S"
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(x)),
   privilege_exception pe,
   v500_event_set_code v
  PLAN (d)
   JOIN (pe
   WHERE (pe.privilege_id=reply->privs[d.seq].privilege_id)
    AND pe.active_ind=1)
   JOIN (v
   WHERE v.event_set_name=outerjoin(cnvtupper(trim(pe.event_set_name))))
  HEAD d.seq
   y = 0
  DETAIL
   y = (y+ 1)
   IF (y > size(reply->privs[d.seq].excepts,5))
    stat = alterlist(reply->privs[d.seq].excepts,(y+ 9))
   ENDIF
   reply->privs[d.seq].excepts[y].exception_entity_name = pe.exception_entity_name, reply->privs[d
   .seq].excepts[y].exception_type_cd = pe.exception_type_cd
   IF (pe.exception_id > 0)
    reply->privs[d.seq].excepts[y].exception_id = pe.exception_id
   ELSE
    reply->privs[d.seq].excepts[y].exception_id = v.event_set_cd
   ENDIF
  FOOT  d.seq
   stat = alterlist(reply->privs[d.seq].excepts,y), reply->privs[d.seq].except_cnt = y
  WITH nocounter
 ;end select
#programend
END GO
