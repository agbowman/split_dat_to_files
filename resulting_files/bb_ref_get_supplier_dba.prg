CREATE PROGRAM bb_ref_get_supplier:dba
 RECORD reply(
   1 qual[*]
     2 organization_id = f8
     2 org_name = vc
     2 bb_supplier_id = f8
     2 barcode_value = c20
     2 prefix_ind = i2
     2 prefix_value = c5
     2 default_prefix_ind = i2
     2 alpha_translation_ind = i2
     2 active_ind = i2
     2 isbt_sup_fin_list[*]
       3 bb_isbt_supplier_id = f8
       3 isbt_fin = c5
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE d278_bbsuppl_cd = f8
 DECLARE scdf_meaning = c12
 DECLARE lcnt = i4
 DECLARE qual_cnt = i4
 DECLARE isbt_cnt = i4
 DECLARE idx_var = i4
 DECLARE idx_var2 = i4
 DECLARE loc_var = i4
 DECLARE list_size = i4
 SET serrormsg = fillstring(255," ")
 SET serror_check = error(serrormsg,1)
 SET d278_bbsuppl_cd = 0.0
 SET scdf_meaning = "BBSUPPL"
 SET stat = uar_get_meaning_by_codeset(278,scdf_meaning,1,d278_bbsuppl_cd)
 IF (d278_bbsuppl_cd=0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Code lookup for BBSUPPL in codeset 278 failed"
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "F"
 SET qual_cnt = 0
 SET isbt_cnt = 0
 SET idx_var = 0
 SET list_size = 0
 SET stat = alterlist(reply->qual,10)
 SELECT
  IF ((request->active_flag=2))
   PLAN (otr
    WHERE otr.org_type_cd=d278_bbsuppl_cd)
    JOIN (org
    WHERE org.organization_id=otr.organization_id)
  ELSE
   PLAN (otr
    WHERE otr.org_type_cd=d278_bbsuppl_cd
     AND (otr.active_ind=request->active_flag))
    JOIN (org
    WHERE org.organization_id=otr.organization_id
     AND (org.active_ind=request->active_flag))
  ENDIF
  INTO "nl:"
  otr.org_type_cd, org.org_name
  FROM org_type_reltn otr,
   organization org
  DETAIL
   qual_cnt = (qual_cnt+ 1)
   IF (mod(qual_cnt,10)=1
    AND qual_cnt != 1)
    stat = alterlist(reply->qual,(qual_cnt+ 9))
   ENDIF
   reply->qual[qual_cnt].organization_id = otr.organization_id, reply->qual[qual_cnt].org_name = org
   .org_name
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->qual,qual_cnt)
 SELECT INTO "nl:"
  *
  FROM bb_supplier bbs,
   (dummyt d  WITH seq = value(qual_cnt))
  PLAN (d)
   JOIN (bbs
   WHERE (bbs.organization_id=reply->qual[d.seq].organization_id)
    AND bbs.active_ind=1)
  DETAIL
   reply->qual[d.seq].bb_supplier_id = bbs.bb_supplier_id, reply->qual[d.seq].barcode_value = bbs
   .barcode_value, reply->qual[d.seq].prefix_ind = bbs.prefix_ind,
   reply->qual[d.seq].prefix_value = bbs.prefix_value, reply->qual[d.seq].default_prefix_ind = bbs
   .default_prefix_ind, reply->qual[d.seq].alpha_translation_ind = bbs.alpha_translation_ind,
   reply->qual[d.seq].active_ind = bbs.active_ind
  WITH nocounter
 ;end select
 SET serror_check = error(serrormsg,0)
 IF (serror_check=0)
  IF (curqual > 0)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ELSE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
 ENDIF
 SET qual_cnt = 0
 SET isbt_cnt = 0
 SET idx_var = 0
 SELECT INTO "nl:"
  *
  FROM bb_isbt_supplier biss
  WHERE expand(lcnt,1,size(reply->qual,5),biss.organization_id,reply->qual[lcnt].organization_id)
   AND biss.active_ind=1
  ORDER BY biss.organization_id, biss.isbt_supplier_fin
  HEAD biss.organization_id
   idx_var = 0, loc_var = locateval(idx_var2,1,size(reply->qual,5),biss.organization_id,reply->qual[
    idx_var2].organization_id)
  HEAD biss.isbt_supplier_fin
   IF (loc_var != 0)
    idx_var = (idx_var+ 1), stat = alterlist(reply->qual[loc_var].isbt_sup_fin_list,idx_var), reply->
    qual[loc_var].isbt_sup_fin_list[idx_var].bb_isbt_supplier_id = biss.bb_isbt_supplier_id,
    reply->qual[loc_var].isbt_sup_fin_list[idx_var].isbt_fin = biss.isbt_supplier_fin
   ENDIF
  WITH nocounter
 ;end select
 SET serror_check = error(serrormsg,0)
 IF (serror_check=0)
  IF (curqual > 0)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ELSE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
 ENDIF
#exit_script
END GO
