CREATE PROGRAM codesdk_get_codeset:dba
 RECORD reply(
   1 codes[*]
     2 code_value = f8
     2 cdf_meaning = c12
     2 code_set = i4
     2 description = vc
     2 display = c40
     2 definition = vc
     2 collation_seq = i4
     2 cki = vc
     2 concept_cki = vc
     2 data_status_cd = f8
     2 data_status_disp = vc
     2 data_status_desc = vc
     2 data_status_mean = vc
     2 active_ind = i2
     2 begin_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE dcode_valuelb = f8 WITH protect, noconstant(0.0)
 SET dcode_valuelb = validate(request->codevaluelowerbound,- (1.0))
 SET reply->status_data.status = "F"
 DECLARE cnt = i4 WITH public, noconstant(0)
 DECLARE cap = i4 WITH public, noconstant(0)
 IF ((dcode_valuelb > - (1.0)))
  SELECT INTO "nl:"
   FROM (
    (
    (SELECT
     rownumber = row_number() OVER(
     ORDER BY cv.code_value), cv.code_value, cv.cdf_meaning,
     cv.code_set, cv.description, cv.display,
     cv.definition, cv.collation_seq, cv.cki,
     cv.concept_cki, cv.data_status_cd, cv.active_ind,
     cv.begin_effective_dt_tm, cv.end_effective_dt_tm
     FROM code_value cv
     WHERE (cv.code_set=request->value)
      AND (cv.code_value > request->codevaluelowerbound)
     WITH sqltype("i4","f8","c12","i4","vc",
       "c40","vc","i4","vc","vc",
       "f8","i2","dq8","dq8")))
    c)
   WHERE c.rownumber BETWEEN 1 AND 65000
   ORDER BY c.code_value
   DETAIL
    IF (cnt=cap)
     IF (cap=0)
      cap = 4
     ELSE
      cap *= 2
     ENDIF
     stat = alterlist(reply->codes,cap)
    ENDIF
    cnt += 1, reply->codes[cnt].code_value = c.code_value, reply->codes[cnt].cdf_meaning = c
    .cdf_meaning,
    reply->codes[cnt].code_set = c.code_set, reply->codes[cnt].description = c.description, reply->
    codes[cnt].display = c.display,
    reply->codes[cnt].definition = c.definition, reply->codes[cnt].collation_seq = c.collation_seq,
    reply->codes[cnt].cki = c.cki,
    reply->codes[cnt].concept_cki = c.concept_cki, reply->codes[cnt].data_status_cd = c
    .data_status_cd, reply->codes[cnt].active_ind = c.active_ind,
    reply->codes[cnt].begin_effective_dt_tm = c.begin_effective_dt_tm, reply->codes[cnt].
    end_effective_dt_tm = c.end_effective_dt_tm
   FOOT REPORT
    stat = alterlist(reply->codes,cnt)
   WITH nocounter
  ;end select
  IF (cnt=0)
   SET reply->status_data.status = "Z"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ELSE
  SELECT INTO "nl:"
   FROM code_value c
   WHERE (c.code_set=request->value)
   DETAIL
    IF (cnt=cap)
     IF (cap=0)
      cap = 4
     ELSE
      cap *= 2
     ENDIF
     stat = alterlist(reply->codes,cap)
    ENDIF
    cnt += 1, reply->codes[cnt].code_value = c.code_value, reply->codes[cnt].cdf_meaning = c
    .cdf_meaning,
    reply->codes[cnt].code_set = c.code_set, reply->codes[cnt].description = c.description, reply->
    codes[cnt].display = c.display,
    reply->codes[cnt].definition = c.definition, reply->codes[cnt].collation_seq = c.collation_seq,
    reply->codes[cnt].cki = c.cki,
    reply->codes[cnt].concept_cki = c.concept_cki, reply->codes[cnt].data_status_cd = c
    .data_status_cd, reply->codes[cnt].active_ind = c.active_ind,
    reply->codes[cnt].begin_effective_dt_tm = c.begin_effective_dt_tm, reply->codes[cnt].
    end_effective_dt_tm = c.end_effective_dt_tm
   FOOT REPORT
    stat = alterlist(reply->codes,cnt)
   WITH nocounter
  ;end select
  IF (cnt=0)
   SET reply->status_data.status = "Z"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
END GO
