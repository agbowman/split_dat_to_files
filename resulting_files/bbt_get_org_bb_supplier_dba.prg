CREATE PROGRAM bbt_get_org_bb_supplier:dba
 RECORD reply(
   1 return_inactive_ind = i2
   1 qual[*]
     2 organization_id = f8
     2 org_name = vc
     2 bb_supplier_ind = i2
     2 bb_supplier_id = f8
     2 barcode_value = c20
     2 prefix_ind = i2
     2 prefix_value = c5
     2 default_prefix_ind = i2
     2 alpha_translation_ind = i2
     2 updt_cnt = i4
     2 active_ind = i2
     2 org_type_cd = f8
     2 org_type_disp = c40
     2 org_type_mean = c12
     2 bb_inv_area_ind = i2
     2 bbinvqaul[*]
       3 bb_isbt_supplier_id = f8
       3 bb_inv_area_cd = f8
       3 bb_inv_area_disp = c40
       3 bb_inv_area_mean = c12
       3 isbt_supplier_fin = c5
       3 license_nbr_txt = c15
       3 registration_nbr_txt = c15
       3 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET org_type_code_set = 278
 DECLARE code_cnt = i4 WITH protect, noconstant(1)
 DECLARE lstat = i4 WITH protect, noconstant(0)
 DECLARE lidx = i4 WITH protect, noconstant(0)
 DECLARE lidx2 = i4 WITH protect, noconstant(0)
 DECLARE lreplycnt = i4 WITH protect, noconstant(0)
 DECLARE lloc_type_cs = i4 WITH protect, constant(222)
 DECLARE sbbinvarea_mean = c12 WITH protect, constant("BBINVAREA")
 DECLARE dbbinvareacd = f8 WITH protect, noconstant(0.0)
 DECLARE errmsg = c132 WITH noconstant(fillstring(132," "))
 DECLARE error_check = i2 WITH noconstant(error(errmsg,1))
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET type_cnt = 0
 SET qual_cnt = 0
 SET select_ok_ind = 0
 SET type_cnt = size(request->typelist,5)
 SET stat = alterlist(reply->qual,10)
 SELECT INTO "nl:"
  otr.org_type_cd, cv.cdf_meaning, org.organization_id,
  org.org_name, bbs.seq, bbs.bb_supplier_id,
  bbs.barcode_value, bbs.prefix_ind, bbs.prefix_value,
  bbs.default_prefix_ind, bbs.alpha_translation_ind, bbs.updt_cnt,
  bbs.active_ind
  FROM (dummyt d  WITH seq = value(type_cnt)),
   code_value cv,
   org_type_reltn otr,
   organization org,
   (dummyt d_bbs  WITH seq = 1),
   bb_supplier bbs
  PLAN (d)
   JOIN (cv
   WHERE cv.code_set=org_type_code_set
    AND (cv.cdf_meaning=request->typelist[d.seq].cdf_meaning)
    AND cv.active_ind=1
    AND cv.begin_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND cv.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (otr
   WHERE otr.org_type_cd=cv.code_value
    AND otr.organization_id != null
    AND otr.organization_id > 0
    AND otr.active_ind=1)
   JOIN (org
   WHERE org.organization_id=otr.organization_id
    AND org.active_ind=1)
   JOIN (d_bbs
   WHERE d_bbs.seq=1)
   JOIN (bbs
   WHERE bbs.organization_id=org.organization_id
    AND (((request->return_inactive_ind=1)) OR ((request->return_inactive_ind=0)
    AND bbs.active_ind=1)) )
  HEAD REPORT
   select_ok_ind = 0
  DETAIL
   qual_cnt = (qual_cnt+ 1)
   IF (mod(qual_cnt,10)=1
    AND qual_cnt != 1)
    stat = alterlist(reply->qual,(qual_cnt+ 9))
   ENDIF
   reply->qual[qual_cnt].organization_id = otr.organization_id, reply->qual[qual_cnt].org_name = org
   .org_name, reply->qual[qual_cnt].org_type_cd = otr.org_type_cd
   IF (bbs.seq > 0)
    reply->qual[qual_cnt].bb_supplier_ind = 1, reply->qual[qual_cnt].bb_supplier_id = bbs
    .bb_supplier_id, reply->qual[qual_cnt].barcode_value = bbs.barcode_value,
    reply->qual[qual_cnt].prefix_ind = bbs.prefix_ind, reply->qual[qual_cnt].prefix_value = bbs
    .prefix_value, reply->qual[qual_cnt].default_prefix_ind = bbs.default_prefix_ind,
    reply->qual[qual_cnt].alpha_translation_ind = bbs.alpha_translation_ind, reply->qual[qual_cnt].
    updt_cnt = bbs.updt_cnt, reply->qual[qual_cnt].active_ind = bbs.active_ind
   ELSE
    reply->qual[qual_cnt].bb_supplier_ind = 0, reply->qual[qual_cnt].bb_supplier_id = 0.0, reply->
    qual[qual_cnt].barcode_value = "",
    reply->qual[qual_cnt].prefix_ind = 0, reply->qual[qual_cnt].prefix_value = "", reply->qual[
    qual_cnt].default_prefix_ind = 0,
    reply->qual[qual_cnt].alpha_translation_ind = 0, reply->qual[qual_cnt].updt_cnt = 0, reply->qual[
    qual_cnt].active_ind = 0
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->qual,qual_cnt), select_ok_ind = 1
  WITH nocounter, outerjoin(d_bbs), nullreport
 ;end select
 SET count1 = (count1+ 1)
 IF (count1 != 1)
  SET stat = alter(reply->status_data.subeventstatus,count1)
 ENDIF
 IF (select_ok_ind=1)
  IF (curqual=0)
   SET reply->status_data.status = "Z"
   SET reply->status_data.subeventstatus[1].operationname = "select organizations"
   SET reply->status_data.subeventstatus[1].operationstatus = "Z"
   SET reply->status_data.subeventstatus[1].targetobjectname = "bbt_get_org_bb_supplier"
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "No organizations found for requested types/cdf_meanings"
   GO TO exit_script
  ENDIF
 ELSE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "select organizations"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bbt_get_org_bb_supplier"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Script/CCL error.  Select failed."
  GO TO exit_script
 ENDIF
 SET lstat = uar_get_meaning_by_codeset(lloc_type_cs,nullterm(sbbinvarea_mean),code_cnt,dbbinvareacd)
 IF (dbbinvareacd=0.0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "select organizations"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bbt_get_org_bb_supplier"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Script/CCL error.  Can't retrieve BBInvArea Code Value from code set 222."
 ENDIF
 SET lreplycnt = size(reply->qual,5)
 SET bb_inv_cnt = 0
 SELECT INTO "nl:"
  FROM bb_isbt_supplier biss
  WHERE biss.bb_isbt_supplier_id > 0
   AND (((request->return_inactive_ind=1)) OR ((request->return_inactive_ind=0)
   AND biss.active_ind=1))
  DETAIL
   lidx2 = locateval(lidx,1,size(reply->qual,5),biss.organization_id,reply->qual[lidx].
    organization_id)
   IF (lidx2 > 0)
    bb_inv_cnt = size(reply->qual[lidx2].bbinvqaul,5), bb_inv_cnt = (bb_inv_cnt+ 1), stat = alterlist
    (reply->qual[lidx2].bbinvqaul,bb_inv_cnt),
    reply->qual[lidx2].bbinvqaul[bb_inv_cnt].bb_inv_area_cd = biss.inventory_area_cd, reply->qual[
    lidx2].bbinvqaul[bb_inv_cnt].isbt_supplier_fin = biss.isbt_supplier_fin, reply->qual[lidx2].
    bbinvqaul[bb_inv_cnt].license_nbr_txt = biss.license_nbr_txt,
    reply->qual[lidx2].bbinvqaul[bb_inv_cnt].registration_nbr_txt = biss.registration_nbr_txt, reply
    ->qual[lidx2].bbinvqaul[bb_inv_cnt].active_ind = biss.active_ind, reply->qual[lidx2].bbinvqaul[
    bb_inv_cnt].bb_isbt_supplier_id = biss.bb_isbt_supplier_id,
    reply->qual[lidx2].bb_inv_area_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SET error_check = error(errmsg,0)
 IF (error_check != 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "select ISBT Suppliers"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bbt_get_org_bb_supplier"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
 SET reply->status_data.subeventstatus[1].operationname = "select ISBT Suppliers"
 SET reply->status_data.subeventstatus[1].operationstatus = "S"
 SET reply->status_data.subeventstatus[1].targetobjectname = "bbt_get_org_bb_supplier"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "SUCCESS"
#exit_script
END GO
