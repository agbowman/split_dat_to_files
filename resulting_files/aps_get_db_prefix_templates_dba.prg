CREATE PROGRAM aps_get_db_prefix_templates:dba
 RECORD reply(
   1 prefix_qual[10]
     2 site_cd = f8
     2 site_disp = c40
     2 site_desc = c60
     2 prefix_cd = f8
     2 prefix_display = c40
     2 prefix_name = c2
     2 accession_number = c21
     2 prefix_desc = c60
     2 prefix_updt_cnt = i4
     2 template_id = f8
     2 template_short_desc = vc
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
 SET failed = "F"
 SET code_set = 0
 SET cdf_meaning = fillstring(12," ")
 SET code_value = 0.0
 SET gyn_case_type_cd = 0.0
 SET ngyn_case_type_cd = 0.0
 SET prefix_cnt = 0
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=1301
   AND cv.cdf_meaning IN ("GYN", "NGYN")
  DETAIL
   IF (cv.cdf_meaning="GYN")
    gyn_case_type_cd = cv.code_value
   ENDIF
   IF (cv.cdf_meaning="NGYN")
    ngyn_case_type_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  p.prefix_id, p.prefix_name, p.site_cd,
  wp.template_id, wp.short_desc
  FROM ap_prefix p,
   dummyt d1,
   wp_template wp
  PLAN (p
   WHERE p.case_type_cd IN (gyn_case_type_cd, ngyn_case_type_cd)
    AND p.active_ind=1)
   JOIN (d1)
   JOIN (wp
   WHERE p.worksheet_template_id=wp.template_id
    AND p.worksheet_template_id > 0)
  HEAD REPORT
   prefix_cnt = 0
  DETAIL
   prefix_cnt = (prefix_cnt+ 1)
   IF (mod(prefix_cnt,10)=1
    AND prefix_cnt != 1)
    stat = alter(reply->prefix_qual,(prefix_cnt+ 9))
   ENDIF
   reply->prefix_qual[prefix_cnt].prefix_cd = p.prefix_id, reply->prefix_qual[prefix_cnt].prefix_name
    = p.prefix_name, reply->prefix_qual[prefix_cnt].prefix_display = p.prefix_desc,
   reply->prefix_qual[prefix_cnt].site_cd = p.site_cd, reply->prefix_qual[prefix_cnt].template_id =
   wp.template_id, reply->prefix_qual[prefix_cnt].template_short_desc = wp.short_desc,
   reply->prefix_qual[prefix_cnt].prefix_updt_cnt = p.updt_cnt
  WITH nocounter, outerjoin = d1
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "PREFIX OR WP_TEMPLATE"
  SET failed = "T"
  SET reply->status_data.status = "Z"
 ENDIF
#exit_script
 IF (failed="F")
  SET reply->status_data.status = "S"
  IF (prefix_cnt != 10)
   SET stat = alter(reply->prefix_qual,prefix_cnt)
  ENDIF
 ELSE
  SET stat = alter(reply->prefix_qual,1)
 ENDIF
END GO
