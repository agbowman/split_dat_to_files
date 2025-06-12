CREATE PROGRAM aps_get_folders:dba
 RECORD reply(
   1 folder_qual[*]
     2 folder_id = f8
     2 folder_name = c255
     2 parent_folder_id = f8
     2 create_prsnl_id = f8
     2 public_ind = i2
     2 default_bitmap = i4
     2 anonymous_bitmap = i4
     2 comment = vc
     2 updt_cnt = i4
     2 entities_exist_ind = i2
     2 proxy_qual[*]
       3 parent_entity_id = f8
       3 parent_entity_name = c32
       3 display = c100
       3 permission_bitmap = i4
       3 belong_to_group_ind = i2
       3 folder_contact_ind = i2
       3 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET proxy_cnt = 0
 SET cnt = 0
 SELECT INTO "nl:"
  af.folder_id
  FROM ap_folder af,
   long_text lt,
   (dummyt d  WITH seq = 1),
   ap_folder_entity afe
  PLAN (af
   WHERE (((af.create_prsnl_id=request->user_id)) OR (af.public_ind=1
    AND af.folder_id != 0)) )
   JOIN (lt
   WHERE af.comment_id=lt.long_text_id)
   JOIN (d)
   JOIN (afe
   WHERE afe.folder_id=af.folder_id)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->folder_qual,(cnt+ 9))
   ENDIF
   reply->folder_qual[cnt].folder_id = af.folder_id, reply->folder_qual[cnt].folder_name = af
   .folder_name, reply->folder_qual[cnt].parent_folder_id = af.parent_folder_id,
   reply->folder_qual[cnt].create_prsnl_id = af.create_prsnl_id, reply->folder_qual[cnt].public_ind
    = af.public_ind, reply->folder_qual[cnt].default_bitmap = af.default_bitmap,
   reply->folder_qual[cnt].anonymous_bitmap = af.anonymous_bitmap, reply->folder_qual[cnt].updt_cnt
    = af.updt_cnt, reply->folder_qual[cnt].comment = lt.long_text
   IF (afe.seq != 0)
    reply->folder_qual[cnt].entities_exist_ind = 1
   ELSE
    reply->folder_qual[cnt].entities_exist_ind = 0
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->folder_qual,cnt)
  WITH nocounter, outerjoin = d, maxqual(afe,1)
 ;end select
 IF (cnt > 0)
  SELECT INTO "nl:"
   prsnl_join = decode(pr.seq,1,0)
   FROM ap_folder_proxy afp,
    prsnl pr,
    (dummyt d  WITH seq = value(cnt))
   PLAN (d)
    JOIN (afp
    WHERE (reply->folder_qual[d.seq].folder_id=afp.folder_id))
    JOIN (pr
    WHERE afp.parent_entity_name="PRSNL"
     AND afp.parent_entity_id=pr.person_id)
   ORDER BY d.seq
   HEAD d.seq
    proxy_cnt = 0
   DETAIL
    proxy_cnt = (proxy_cnt+ 1)
    IF (mod(proxy_cnt,10)=1)
     stat = alterlist(reply->folder_qual[d.seq].proxy_qual,(proxy_cnt+ 9))
    ENDIF
    reply->folder_qual[d.seq].proxy_qual[proxy_cnt].permission_bitmap = afp.permission_bitmap, reply
    ->folder_qual[d.seq].proxy_qual[proxy_cnt].parent_entity_id = pr.person_id, reply->folder_qual[d
    .seq].proxy_qual[proxy_cnt].parent_entity_name = "PRSNL",
    reply->folder_qual[d.seq].proxy_qual[proxy_cnt].display = pr.name_full_formatted, reply->
    folder_qual[d.seq].proxy_qual[proxy_cnt].belong_to_group_ind = 0, reply->folder_qual[d.seq].
    proxy_qual[proxy_cnt].folder_contact_ind = afp.contact_ind,
    reply->folder_qual[d.seq].proxy_qual[proxy_cnt].updt_cnt = afp.updt_cnt
   FOOT  d.seq
    stat = alterlist(reply->folder_qual[d.seq].proxy_qual,proxy_cnt)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   prsnl_group_join = decode(pg.seq,1,0), prsnl_group_reltn_join = decode(pgr.seq,1,0)
   FROM ap_folder_proxy afp,
    prsnl_group pg,
    prsnl_group_reltn pgr,
    (dummyt d  WITH seq = value(cnt)),
    (dummyt d4  WITH seq = 1)
   PLAN (d)
    JOIN (afp
    WHERE (reply->folder_qual[d.seq].folder_id=afp.folder_id))
    JOIN (pg
    WHERE afp.parent_entity_name="PRSNL_GROUP"
     AND afp.parent_entity_id=pg.prsnl_group_id)
    JOIN (d4)
    JOIN (pgr
    WHERE pgr.prsnl_group_id=pg.prsnl_group_id
     AND (pgr.person_id=request->user_id)
     AND pgr.active_ind=1
     AND cnvtdatetime(curdate,curtime3) BETWEEN pgr.beg_effective_dt_tm AND pgr.end_effective_dt_tm)
   ORDER BY d.seq
   HEAD d.seq
    proxy_cnt = cnvtint(size(reply->folder_qual[d.seq].proxy_qual,5))
   DETAIL
    IF (prsnl_group_reltn_join=1)
     proxy_cnt = (proxy_cnt+ 1), stat = alterlist(reply->folder_qual[d.seq].proxy_qual,proxy_cnt),
     reply->folder_qual[d.seq].proxy_qual[proxy_cnt].permission_bitmap = afp.permission_bitmap,
     reply->folder_qual[d.seq].proxy_qual[proxy_cnt].parent_entity_id = pg.prsnl_group_id, reply->
     folder_qual[d.seq].proxy_qual[proxy_cnt].parent_entity_name = "PRSNL_GROUP", reply->folder_qual[
     d.seq].proxy_qual[proxy_cnt].display = pg.prsnl_group_name,
     reply->folder_qual[d.seq].proxy_qual[proxy_cnt].belong_to_group_ind = 1, reply->folder_qual[d
     .seq].proxy_qual[proxy_cnt].folder_contact_ind = afp.contact_ind, reply->folder_qual[d.seq].
     proxy_qual[proxy_cnt].updt_cnt = afp.updt_cnt
    ELSEIF (prsnl_group_join=1)
     proxy_cnt = (proxy_cnt+ 1), stat = alterlist(reply->folder_qual[d.seq].proxy_qual,proxy_cnt),
     reply->folder_qual[d.seq].proxy_qual[proxy_cnt].permission_bitmap = afp.permission_bitmap,
     reply->folder_qual[d.seq].proxy_qual[proxy_cnt].parent_entity_id = pg.prsnl_group_id, reply->
     folder_qual[d.seq].proxy_qual[proxy_cnt].parent_entity_name = "PRSNL_GROUP", reply->folder_qual[
     d.seq].proxy_qual[proxy_cnt].display = pg.prsnl_group_name,
     reply->folder_qual[d.seq].proxy_qual[proxy_cnt].belong_to_group_ind = 0, reply->folder_qual[d
     .seq].proxy_qual[proxy_cnt].folder_contact_ind = afp.contact_ind, reply->folder_qual[d.seq].
     proxy_qual[proxy_cnt].updt_cnt = afp.updt_cnt
    ENDIF
   FOOT  d.seq
    stat = alterlist(reply->folder_qual[d.seq].proxy_qual,proxy_cnt)
   WITH nocounter, outerjoin = d4
  ;end select
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_FOLDER"
  SET reply->status_data.status = "Z"
 ENDIF
END GO
