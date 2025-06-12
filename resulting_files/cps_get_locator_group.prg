CREATE PROGRAM cps_get_locator_group
 RECORD reply(
   1 recycle_cd = f8
   1 group_qual_cnt = i4
   1 group_qual[*]
     2 locator_view_cd = f8
     2 locator_view_disp = c40
     2 locator_view_desc = c60
     2 location_qual[*]
       3 locator_area_id = f8
       3 location_cd = f8
       3 location_disp = c40
       3 location_desc = c60
       3 location_mean = c12
       3 caption = vc
       3 alert_time = i4
       3 style = i4
       3 top = i4
       3 left = i4
       3 right = i4
       3 bottom = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET reply->status_data.status = "F"
 SET grpkount = 0
 SET lockount = 0
 SET reqgrpkount = request->group_qual_cnt
 SET recycle_cd = 0.0
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 222
 SET cdf_meaning = "PTRECYCLE"
 EXECUTE cpm_get_cd_for_cdf
 SET reply->recycle_cd = code_value
 SELECT INTO "NL:"
  d.seq, lvar.locator_area_id, la.locator_area_id
  FROM locator_view_area_r lvar,
   locator_area la,
   (dummyt d  WITH seq = value(reqgrpkount))
  PLAN (d
   WHERE d.seq > 0)
   JOIN (lvar
   WHERE (lvar.locator_view_cd=request->group_qual[d.seq].locator_view_cd))
   JOIN (la
   WHERE la.locator_area_id=lvar.locator_area_id)
  HEAD d.seq
   lockount = 0, grpkount = (grpkount+ 1)
   IF (mod(grpkount,10)=1)
    stat = alterlist(reply->group_qual,(grpkount+ 10))
   ENDIF
   reply->group_qual[grpkount].locator_view_cd = request->group_qual[d.seq].locator_view_cd
  DETAIL
   lockount = (lockount+ 1)
   IF (mod(lockount,10)=1)
    stat = alterlist(reply->group_qual[grpkount].location_qual,(lockount+ 10))
   ENDIF
   reply->group_qual[grpkount].location_qual[lockount].locator_area_id = la.locator_area_id, reply->
   group_qual[grpkount].location_qual[lockount].location_cd = la.location_cd, reply->group_qual[
   grpkount].location_qual[lockount].caption = la.caption,
   reply->group_qual[grpkount].location_qual[lockount].alert_time = la.alert_time, reply->group_qual[
   grpkount].location_qual[lockount].style = la.style, reply->group_qual[grpkount].location_qual[
   lockount].top = la.top,
   reply->group_qual[grpkount].location_qual[lockount].left = la.left, reply->group_qual[grpkount].
   location_qual[lockount].right = la.right, reply->group_qual[grpkount].location_qual[lockount].
   bottom = la.bottom
  FOOT  lvar.locator_view_cd
   stat = alterlist(reply->group_qual[grpkount].location_qual,lockount)
  WITH nocounter, outerjoin = d
 ;end select
 SET stat = alterlist(reply->group_qual,grpkount)
 SET reply->group_qual_cnt = grpkount
 IF (grpkount=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
