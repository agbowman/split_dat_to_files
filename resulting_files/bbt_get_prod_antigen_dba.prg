CREATE PROGRAM bbt_get_prod_antigen:dba
 RECORD reply(
   1 qual[*]
     2 product_id = f8
     2 qual2[*]
       3 special_testing_cd = f8
       3 special_testing_disp = c40
       3 special_testing_desc = vc
       3 special_testing_mean = c12
       3 special_isbt = vc
     2 opposite_qual[*]
       3 special_testing_cd = f8
       3 special_testing_disp = c40
       3 opposite_cd = f8
       3 opposite_disp = c40
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE special_testing_code_set = i4 WITH protect, constant(1612)
 DECLARE opposite_cnt = i2 WITH protect, noconstant(0)
 DECLARE max_qual2_cnt = i2 WITH protect, noconstant(0)
 SET err_cnt = 0
 SET qual_cnt = 0
 SET qual2_cnt = 0
 SET reply->status_data.status = "F"
 SET nbr_of_products = size(request->qual,5)
 SET y = 0
 SET idx = 0
 SET failed = "F"
 SELECT INTO "nl:"
  d.seq, st.special_testing_cd
  FROM (dummyt d  WITH seq = value(nbr_of_products)),
   special_testing st,
   bb_isbt_attribute_r biar,
   bb_isbt_attribute bia,
   code_value cv
  PLAN (d)
   JOIN (st
   WHERE (st.product_id=request->qual[d.seq].product_id)
    AND st.active_ind=1)
   JOIN (biar
   WHERE (biar.attribute_cd= Outerjoin(st.special_testing_cd))
    AND (biar.active_ind= Outerjoin(1)) )
   JOIN (bia
   WHERE (bia.bb_isbt_attribute_id= Outerjoin(biar.bb_isbt_attribute_id))
    AND (bia.active_ind= Outerjoin(1)) )
   JOIN (cv
   WHERE cv.code_value=st.special_testing_cd
    AND cv.active_ind=1)
  ORDER BY st.product_id, cv.collation_seq
  HEAD REPORT
   err_cnt = 0
  HEAD st.product_id
   qual_cnt += 1, qual2_cnt = 0, stat = alterlist(reply->qual,qual_cnt),
   stat = alterlist(reply->qual[qual_cnt].qual2,qual2_cnt), reply->qual[qual_cnt].product_id =
   request->qual[d.seq].product_id
  DETAIL
   qual2_cnt += 1
   IF (qual2_cnt > max_qual2_cnt)
    max_qual2_cnt = qual2_cnt
   ENDIF
   stat = alterlist(reply->qual[qual_cnt].qual2,qual2_cnt), reply->qual[qual_cnt].qual2[qual2_cnt].
   special_testing_cd = st.special_testing_cd, reply->qual[qual_cnt].qual2[qual2_cnt].special_isbt =
   bia.standard_display
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET err_cnt += 1
  SET reply->status_data.subeventstatus[err_cnt].operationname = "select"
  SET reply->status_data.subeventstatus[err_cnt].operationstatus = "F"
  SET reply->status_data.subeventstatus[err_cnt].targetobjectname = "special_testing"
  SET reply->status_data.subeventstatus[err_cnt].targetobjectvalue =
  "unable to return product antigens specified"
  SET reply->status_data.status = "Z"
 ENDIF
 SELECT INTO "nl:"
  dproductid = reply->qual[d1.seq].product_id
  FROM (dummyt d1  WITH seq = value(size(reply->qual,5))),
   (dummyt d2  WITH seq = value(max_qual2_cnt)),
   code_value cv,
   code_value_extension cve
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(reply->qual[d1.seq].qual2,5))
   JOIN (cv
   WHERE cv.code_set=special_testing_code_set
    AND (cv.code_value=reply->qual[d1.seq].qual2[d2.seq].special_testing_cd)
    AND ((cv.cdf_meaning="-") OR (cv.cdf_meaning="+")) )
   JOIN (cve
   WHERE cve.code_set=cv.code_set
    AND cve.code_value=cv.code_value
    AND cve.field_name="Opposite")
  ORDER BY dproductid
  HEAD dproductid
   opp_cnt = 0, opposite_cnt = 0, stat = alterlist(reply->qual[d1.seq].opposite_qual,opposite_cnt),
   dfieldvalue = 0.0, cnt = 0, cnt2 = 0,
   noppositeexist = 0
  DETAIL
   noppositeexist = 0, dfieldvalue = cnvtreal(cve.field_value)
   IF (dfieldvalue > 0)
    cnt2 = size(reply->qual[d1.seq].qual2,5)
    FOR (cnt = 1 TO cnt2)
      IF ((dfieldvalue=reply->qual[d1.seq].qual2[cnt].special_testing_cd))
       FOR (opp_cnt = 1 TO opposite_cnt)
         IF ((reply->qual[d1.seq].opposite_qual[opp_cnt].special_testing_cd=dfieldvalue)
          AND (reply->qual[d1.seq].opposite_qual[opp_cnt].opposite_cd=reply->qual[d1.seq].qual2[d2
         .seq].special_testing_cd))
          noppositeexist = 1, opp_cnt = opposite_cnt
         ENDIF
       ENDFOR
       IF (noppositeexist=0)
        opposite_cnt += 1, stat = alterlist(reply->qual[d1.seq].opposite_qual,opposite_cnt), reply->
        qual[d1.seq].opposite_qual[opposite_cnt].special_testing_cd = reply->qual[d1.seq].qual2[d2
        .seq].special_testing_cd,
        reply->qual[d1.seq].opposite_qual[opposite_cnt].opposite_cd = dfieldvalue
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
#exit_script
END GO
