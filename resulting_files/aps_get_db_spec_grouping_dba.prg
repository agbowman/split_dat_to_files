CREATE PROGRAM aps_get_db_spec_grouping:dba
 RECORD reply(
   1 qual[*]
     2 category_cd = f8
     2 category_desc = vc
     2 updt_cnt = i4
     2 specimen_qual[*]
       3 source_cd = f8
   1 prefix_qual[*]
     2 prefix_cd = f8
     2 prefix_name = c2
     2 site_cd = f8
     2 site_disp = vc
     2 specimen_grouping_cd = f8
     2 updt_cnt = i4
   1 spec_type_qual[*]
     2 display = vc
     2 cdf_meaning = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET categ_cnt = 0
 SET spec_cnt = 0
 SET pre_cnt = 0
 SET type_cnt = 0
 SET stat = alterlist(reply->qual,1)
 SET stat = alterlist(reply->qual[1].specimen_qual,1)
 SET stat = alterlist(reply->prefix_qual,1)
 SET stat = alterlist(reply->spec_type_qual,1)
 SELECT INTO "nl:"
  c.code_value, c.description, c.updt_cnt,
  source_cd = decode(spgr_r.seq,spgr_r.source_cd,0.0)
  FROM code_value c,
   specimen_grouping_r spgr_r,
   (dummyt d1  WITH seq = 1)
  PLAN (c
   WHERE c.code_set=1312)
   JOIN (d1)
   JOIN (spgr_r
   WHERE c.code_value=spgr_r.category_cd)
  ORDER BY c.code_value
  HEAD REPORT
   categ_cnt = 0, spec_cnt = 0
  HEAD c.code_value
   categ_cnt = (categ_cnt+ 1), stat = alterlist(reply->qual,categ_cnt), spec_cnt = 0,
   reply->qual[categ_cnt].category_cd = c.code_value, reply->qual[categ_cnt].category_desc = c
   .description, reply->qual[categ_cnt].updt_cnt = c.updt_cnt
  DETAIL
   IF (source_cd > 0.0)
    spec_cnt = (spec_cnt+ 1), stat = alterlist(reply->qual[categ_cnt].specimen_qual,spec_cnt), reply
    ->qual[categ_cnt].specimen_qual[spec_cnt].source_cd = spgr_r.source_cd
   ENDIF
  FOOT  c.code_value
   stat = alterlist(reply->qual[categ_cnt].specimen_qual,spec_cnt)
  WITH nocounter, outerjoin = d1
 ;end select
 SET stat = alterlist(reply->qual,categ_cnt)
 SELECT INTO "nl:"
  ap.prefix_id
  FROM ap_prefix ap
  WHERE ap.prefix_id != 0.0
  HEAD REPORT
   pre_cnt = 0
  DETAIL
   pre_cnt = (pre_cnt+ 1), stat = alterlist(reply->prefix_qual,pre_cnt), reply->prefix_qual[pre_cnt].
   prefix_cd = ap.prefix_id,
   reply->prefix_qual[pre_cnt].prefix_name = ap.prefix_name, reply->prefix_qual[pre_cnt].site_cd = ap
   .site_cd, reply->prefix_qual[pre_cnt].specimen_grouping_cd = ap.specimen_grouping_cd,
   reply->prefix_qual[pre_cnt].updt_cnt = ap.updt_cnt
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->prefix_qual,pre_cnt)
 SELECT INTO "nl:"
  cdf.code_set
  FROM common_data_foundation cdf
  WHERE cdf.code_set=1306
  HEAD REPORT
   type_cnt = 0
  DETAIL
   type_cnt = (type_cnt+ 1), stat = alterlist(reply->spec_type_qual,type_cnt), reply->spec_type_qual[
   type_cnt].display = cdf.display,
   reply->spec_type_qual[type_cnt].cdf_meaning = cdf.cdf_meaning
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->spec_type_qual,type_cnt)
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "SPECIMEN GROUPING"
  SET reply->status_data.status = "Z"
  SET failed = "T"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
