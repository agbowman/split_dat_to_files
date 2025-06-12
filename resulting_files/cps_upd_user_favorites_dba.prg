CREATE PROGRAM cps_upd_user_favorites:dba
 RECORD reply(
   1 qual[*]
     2 prsnl_id = f8
     2 fav_qual[*]
       3 organization_id = f8
       3 organization_name = vc
       3 ord_favorite_dest_id = f8
       3 output_dest_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD internal_data(
   1 qual[*]
     2 organization_id = f8
     2 ord_favorite_dest_id = f8
 )
 DECLARE crx = f8 WITH protect, noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(278,"PHARMACY",1,crx)
 IF ((request->prsnl_id <= 0))
  GO TO exit_script
 ENDIF
 DELETE  FROM ord_favorite_dest ofd
  SET ofd.seq = ofd.seq
  WHERE (ofd.prsnl_id=request->prsnl_id)
 ;end delete
 CALL echo("Done deleting.",1)
 IF (value(size(request->fav_qual,5))=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(internal_data->qual,value(size(request->fav_qual,5)))
 SELECT INTO "nl:"
  *
  FROM (dummyt d  WITH seq = value(size(request->fav_qual,5))),
   output_dest ods,
   device_xref dx
  PLAN (d)
   JOIN (ods
   WHERE (ods.output_dest_cd=request->fav_qual[d.seq].output_dest_id))
   JOIN (dx
   WHERE dx.device_cd=ods.device_cd
    AND dx.parent_entity_name="ORGANIZATION"
    AND  EXISTS (
   (SELECT
    otr.organization_id
    FROM org_type_reltn otr
    WHERE otr.organization_id=dx.parent_entity_id
     AND otr.org_type_cd=crx)))
  DETAIL
   internal_data->qual[d.seq].organization_id = dx.parent_entity_id
  WITH nocounter
 ;end select
 CALL echo("Done looking up organization_id...",1)
 FOR (x = 1 TO value(size(request->fav_qual,5)))
   SELECT INTO "nl:"
    lnextseq = seq(outputctx_seq,nextval)"##############################;rp0"
    FROM dual
    DETAIL
     internal_data->qual[x].ord_favorite_dest_id = lnextseq
    WITH nocounter
   ;end select
 ENDFOR
 CALL echo("Done assigning new ids...",1)
 INSERT  FROM ord_favorite_dest ofd,
   (dummyt d  WITH seq = value(size(request->fav_qual,5)))
  SET ofd.ord_favorite_dest_id = internal_data->qual[d.seq].ord_favorite_dest_id, ofd.output_dest_id
    = request->fav_qual[d.seq].output_dest_id, ofd.prsnl_id = request->prsnl_id,
   ofd.favorite_dest_seq = d.seq, ofd.organization_id = internal_data->qual[d.seq].organization_id
  PLAN (d)
   JOIN (ofd)
  WITH nocounter
 ;end insert
 CALL echo("Done inserting new rows on ord_favorite_dest table...",1)
 SELECT INTO "nl:"
  *
  FROM ord_favorite_dest ofd,
   organization org
  PLAN (ofd
   WHERE (ofd.prsnl_id=request->prsnl_id))
   JOIN (org
   WHERE org.organization_id=ofd.organization_id)
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
   ord_favorite_dest_id = ofd.ord_favorite_dest_id
  WITH nocounter
 ;end select
 CALL echo("Done populating reply...",1)
#exit_script
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "ORD_FAVORITE_DEST"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 SET last_mod = "003 02/08/05 BP9613"
END GO
