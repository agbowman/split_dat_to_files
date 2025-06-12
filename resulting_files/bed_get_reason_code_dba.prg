CREATE PROGRAM bed_get_reason_code:dba
 FREE SET reply
 RECORD reply(
   1 reason_code_categories[*]
     2 code_set = i4
     2 reason_codes[*]
       3 code_value = f8
       3 display = vc
       3 meaning = vc
       3 reason_type
         4 code_value = f8
         4 display = vc
         4 meaning = vc
       3 reason_group
         4 code_value = f8
         4 display = vc
         4 meaning = vc
       3 alias = vc
       3 post_primary_ind = i2
       3 post_secondary_ind = i2
       3 post_tertiary_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE error_flag = vc
 DECLARE catcnt = i4
 DECLARE codecnt = i4
 DECLARE postmethod = vc
 DECLARE ppi = i2
 DECLARE psi = i2
 DECLARE pti = i2
 DECLARE al1 = vc
 DECLARE al2 = vc
 SET reply->status_data.status = "F"
 SET error_flag = "N"
 SET catcnt = 0
 SET codecnt = 0
 SELECT INTO "nl:"
  FROM code_value cv,
   code_value_extension cve1,
   code_value_extension cve2,
   pft_denial_code_ref pdcr,
   code_value cv2,
   code_value cv3,
   pft_alias pa,
   dummyt d1,
   dummyt d2,
   dummyt d3,
   dummyt d4,
   dummyt d5
  PLAN (cv
   WHERE ((cv.code_set=26398) OR (((cv.code_set=26399) OR (cv.code_set=24730)) ))
    AND cv.active_ind=1)
   JOIN (d1)
   JOIN (cve1
   WHERE cve1.code_value=cv.code_value
    AND cve1.field_name="X12B")
   JOIN (d5)
   JOIN (pa
   WHERE pa.code_value=cv.code_value)
   JOIN (d2)
   JOIN (cve2
   WHERE cve2.code_value=cv.code_value
    AND cve2.field_name="POST NO POST METHOD")
   JOIN (d3)
   JOIN (pdcr
   WHERE pdcr.denial_cd=cv.code_value)
   JOIN (cv2
   WHERE cv2.code_value=pdcr.denial_group_cd)
   JOIN (d4)
   JOIN (cv3
   WHERE cv3.code_value=pdcr.denial_type_cd)
  ORDER BY cv.code_set, cv.display
  HEAD cv.code_set
   catcnt = (catcnt+ 1), stat = alterlist(reply->reason_code_categories,catcnt), reply->
   reason_code_categories[catcnt].code_set = cv.code_set,
   codecnt = 0
  HEAD cv.code_value
   codecnt = (codecnt+ 1), al1 = " ", al2 = " ",
   al1 = cve1.field_value, al2 = pa.alias
  DETAIL
   stat = alterlist(reply->reason_code_categories[catcnt].reason_codes,codecnt), reply->
   reason_code_categories[catcnt].reason_codes[codecnt].code_value = cv.code_value, reply->
   reason_code_categories[catcnt].reason_codes[codecnt].display = cv.display,
   reply->reason_code_categories[catcnt].reason_codes[codecnt].meaning = cv.cdf_meaning
   IF (al1 > " ")
    reply->reason_code_categories[catcnt].reason_codes[codecnt].alias = al1
   ELSE
    reply->reason_code_categories[catcnt].reason_codes[codecnt].alias = al2
   ENDIF
   postmethod = cve2.field_value
   CASE (postmethod)
    OF "0":
     ppi = 1,psi = 1,pti = 1
    OF "1":
     ppi = 0,psi = 0,pti = 0
    OF "2":
     ppi = 1,psi = 0,pti = 1
    OF "3":
     ppi = 1,psi = 0,pti = 0
    OF "4":
     ppi = 1,psi = 1,pti = 0
    OF "5":
     ppi = 0,psi = 0,pti = 1
    OF "6":
     ppi = 0,psi = 1,pti = 0
    OF "7":
     ppi = 0,psi = 1,pti = 1
    ELSE
     ppi = 0,psi = 0,pti = 0
   ENDCASE
   reply->reason_code_categories[catcnt].reason_codes[codecnt].post_primary_ind = ppi, reply->
   reason_code_categories[catcnt].reason_codes[codecnt].post_secondary_ind = psi, reply->
   reason_code_categories[catcnt].reason_codes[codecnt].post_tertiary_ind = pti,
   reply->reason_code_categories[catcnt].reason_codes[codecnt].reason_group.code_value = cv2
   .code_value, reply->reason_code_categories[catcnt].reason_codes[codecnt].reason_group.display =
   cv2.display, reply->reason_code_categories[catcnt].reason_codes[codecnt].reason_group.meaning =
   cv2.cdf_meaning,
   reply->reason_code_categories[catcnt].reason_codes[codecnt].reason_type.code_value = cv3
   .code_value, reply->reason_code_categories[catcnt].reason_codes[codecnt].reason_type.display = cv3
   .display, reply->reason_code_categories[catcnt].reason_codes[codecnt].reason_type.meaning = cv3
   .cdf_meaning
  WITH nocounter, outerjoin = d1, outerjoin = d2,
   outerjoin = d3, outerjoin = d4, outerjoin = d5,
   dontcare = cve1, dontcare = cve2, dontcare = cv2,
   dontcare = cv3, dontcare = pa
 ;end select
#exit_script
 IF (error_flag="Y")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
