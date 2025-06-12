CREATE PROGRAM cps_get_user_favorites:dba
 RECORD reply(
   1 qual[*]
     2 prsnl_id = f8
     2 fav_qual[*]
       3 organization_id = f8
       3 organization_name = vc
       3 org_type_cd = f8
       3 ord_favorite_dest_id = f8
       3 output_dest_id = f8
       3 output_dest_display = vc
       3 favorite_dest_seq = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE cfax = i4 WITH protect, constant(138)
 DECLARE crx = f8 WITH protect, noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(278,"PHARMACY",1,crx)
 DECLARE cfaxtypecd = f8 WITH protect, noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(3000,"FAX",1,cfaxtypecd)
 SELECT INTO "nl:"
  *
  FROM ord_favorite_dest ofd,
   organization org,
   output_dest od,
   device_xref dx,
   (dummyt d  WITH seq = value(size(request->qual,5)))
  PLAN (d)
   JOIN (ofd
   WHERE (ofd.prsnl_id=request->qual[d.seq].prsnl_id))
   JOIN (od
   WHERE od.output_dest_cd=ofd.output_dest_id)
   JOIN (dx
   WHERE dx.device_cd=od.device_cd
    AND dx.usage_type_cd=cfaxtypecd)
   JOIN (org
   WHERE org.organization_id=ofd.organization_id
    AND  EXISTS (
   (SELECT
    otr.organization_id
    FROM org_type_reltn otr
    WHERE otr.organization_id=org.organization_id
     AND otr.org_type_cd=crx)))
  ORDER BY ofd.prsnl_id, ofd.favorite_dest_seq
  HEAD REPORT
   cnt = 0
  HEAD ofd.prsnl_id
   cnt += 1, stat = alterlist(reply->qual,cnt), reply->qual[cnt].prsnl_id = ofd.prsnl_id,
   fav_cnt = 0
  HEAD ofd.favorite_dest_seq
   fav_cnt += 1, stat = alterlist(reply->qual[cnt].fav_qual,fav_cnt), reply->qual[cnt].fav_qual[
   fav_cnt].organization_id = org.organization_id,
   reply->qual[cnt].fav_qual[fav_cnt].organization_name = org.org_name, reply->qual[cnt].fav_qual[
   fav_cnt].output_dest_id = ofd.output_dest_id, reply->qual[cnt].fav_qual[fav_cnt].
   output_dest_display = od.name,
   reply->qual[cnt].fav_qual[fav_cnt].ord_favorite_dest_id = ofd.ord_favorite_dest_id, reply->qual[
   cnt].fav_qual[fav_cnt].favorite_dest_seq = ofd.favorite_dest_seq, reply->qual[cnt].fav_qual[
   fav_cnt].org_type_cd = crx
  WITH nocounter
 ;end select
 CALL echo(build("Curqual=",curqual))
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "ORD_FAVORITE_DEST"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET last_mod = "002"
END GO
