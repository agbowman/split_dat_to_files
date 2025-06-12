CREATE PROGRAM dm_get_code_values:dba
 RECORD reply(
   1 qual[*]
     2 code_value = f8
     2 code_set = f8
     2 cdf_meaning = vc
     2 cdf_null_ind = i2
     2 display = vc
     2 disp_null_ind = i2
     2 display_key = vc
     2 description = vc
     2 descr_null_ind = i2
     2 definition = vc
     2 def_null_ind = i2
     2 collation_seq = i4
     2 active_ind = i2
     2 data_status_cd = f8
     2 cki = vc
     2 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE cdf_meaning_dup_ind = i2 WITH protect, noconstant(0)
 DECLARE display_key_dup_ind = i2 WITH protect, noconstant(0)
 DECLARE display_dup_ind = i2 WITH protect, noconstant(0)
 DECLARE definition_dup_ind = i2 WITH protect, noconstant(0)
 DECLARE nulldisp = i2 WITH protect, noconstant(0)
 DECLARE nulldef = i2 WITH protect, noconstant(0)
 DECLARE nulldescr = i2 WITH protect, noconstant(0)
 DECLARE nullcdf = i2 WITH protect, noconstant(0)
 DECLARE count1 = i4 WITH protect, noconstant(0)
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 SELECT INTO "nl:"
  cv.display_dup_ind, cv.display_key_dup_ind, cv.cdf_meaning_dup_ind,
  cv.definition_dup_ind
  FROM code_value_set cv
  WHERE (cv.code_set=request->code_set)
  DETAIL
   display_dup_ind = cv.display_dup_ind, display_key_dup_ind = cv.display_key_dup_ind,
   cdf_meaning_dup_ind = cv.cdf_meaning_dup_ind,
   definition_dup_ind = cv.definition_dup_ind
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,1)
 IF (errcode != 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
  GO TO exit_program
 ENDIF
 IF ((request->cv_mode=0))
  SELECT
   IF (cdf_meaning_dup_ind=1)
    x = cv.cdf_meaning
   ELSEIF (display_key_dup_ind=1)
    x = cv.display_key
   ELSEIF (display_dup_ind=1)
    x = cv.display
   ELSEIF (definition_dup_ind=1)
    x = cv.definition
   ELSEIF (display_key_dup_ind=0
    AND display_dup_ind=0
    AND cdf_meaning_dup_ind=0
    AND definition_dup_ind=0)
    x = cv.display
   ELSE
   ENDIF
   INTO "nl:"
   cv.code_value, cv.code_set, nullcdf = nullind(cv.cdf_meaning),
   cv.cdf_meaning, nulldisp = nullind(cv.display), cv.display,
   nulldescr = nullind(cv.description), cv.description, nulldef = nullind(cv.definition),
   cv.display_key, cv.definition, cv.collation_seq,
   cv.active_ind, cv.data_status_cd, cv.cki,
   cv.updt_cnt
   FROM code_value cv
   WHERE (request->code_set=cv.code_set)
   ORDER BY x
   HEAD REPORT
    count1 = 0
   DETAIL
    count1 += 1, stat = alterlist(reply->qual,count1), reply->qual[count1].code_value = cv.code_value,
    reply->qual[count1].code_set = cv.code_set, reply->qual[count1].cdf_meaning = cv.cdf_meaning,
    reply->qual[count1].display = cv.display,
    reply->qual[count1].description = cv.description, reply->qual[count1].definition = cv.definition,
    reply->qual[count1].display_key = cv.display_key,
    reply->qual[count1].collation_seq = cv.collation_seq, reply->qual[count1].active_ind = cv
    .active_ind, reply->qual[count1].data_status_cd = cv.data_status_cd,
    reply->qual[count1].cki = cv.cki, reply->qual[count1].updt_cnt = cv.updt_cnt
    IF (nullcdf=1)
     reply->qual[count1].cdf_null_ind = 1
    ELSE
     reply->qual[count1].cdf_null_ind = 0
    ENDIF
    IF (nulldescr=1)
     reply->qual[count1].descr_null_ind = 1
    ELSE
     reply->qual[count1].descr_null_ind = 0
    ENDIF
    IF (nulldef=1)
     reply->qual[count1].def_null_ind = 1
    ELSE
     reply->qual[count1].def_null_ind = 0
    ENDIF
    IF (nulldisp=1)
     reply->qual[count1].disp_null_ind = 1
    ELSE
     reply->qual[count1].disp_null_ind = 0
    ENDIF
   WITH nocounter
  ;end select
  SET errcode = error(errmsg,1)
  IF (errcode != 0)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
   GO TO exit_program
  ENDIF
 ELSE
  SELECT
   IF (cdf_meaning_dup_ind=1)
    x = cv.cdf_meaning
   ELSEIF (display_key_dup_ind=1)
    x = cv.display_key
   ELSEIF (display_dup_ind=1)
    x = cv.display
   ELSEIF (definition_dup_ind=1)
    x = cv.definition
   ELSEIF (display_key_dup_ind=0
    AND display_dup_ind=0
    AND cdf_meaning_dup_ind=0
    AND definition_dup_ind=0)
    x = cv.display
   ELSE
   ENDIF
   INTO "nl:"
   cv.code_value, cv.code_set, nullcdf = nullind(cv.cdf_meaning),
   cv.cdf_meaning, nulldisp = nullind(cv.display), cv.display,
   nulldescr = nullind(cv.description), cv.description, nulldef = nullind(cv.definition),
   cv.definition, cv.display_key, cv.collation_seq,
   cv.active_ind, cv.data_status_cd, cv.updt_cnt
   FROM code_value cv
   WHERE (request->code_set=cv.code_set)
    AND cv.active_ind=1
   ORDER BY x
   HEAD REPORT
    count1 = 0
   DETAIL
    count1 += 1, stat = alterlist(reply->qual,count1), reply->qual[count1].code_value = cv.code_value,
    reply->qual[count1].code_set = cv.code_set, reply->qual[count1].cdf_meaning = cv.cdf_meaning,
    reply->qual[count1].display = cv.display,
    reply->qual[count1].display_key = cv.display_key, reply->qual[count1].description = cv
    .description, reply->qual[count1].definition = cv.definition,
    reply->qual[count1].collation_seq = cv.collation_seq, reply->qual[count1].active_ind = cv
    .active_ind, reply->qual[count1].data_status_cd = cv.data_status_cd,
    reply->qual[count1].cki = cv.cki, reply->qual[count1].updt_cnt = cv.updt_cnt
    IF (nullcdf=1)
     reply->qual[count1].cdf_null_ind = 1
    ELSE
     reply->qual[count1].cdf_null_ind = 0
    ENDIF
    IF (nulldescr=1)
     reply->qual[count1].descr_null_ind = 1
    ELSE
     reply->qual[count1].descr_null_ind = 0
    ENDIF
    IF (nulldef=1)
     reply->qual[count1].def_null_ind = 1
    ELSE
     reply->qual[count1].def_null_ind = 0
    ENDIF
    IF (nulldisp=1)
     reply->qual[count1].disp_null_ind = 1
    ELSE
     reply->qual[count1].disp_null_ind = 0
    ENDIF
   WITH nocounter
  ;end select
  SET errcode = error(errmsg,1)
  IF (errcode != 0)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
   GO TO exit_program
  ENDIF
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = build3(3,
   "No code values returned for code set ",cnvtint(request->code_set),".")
 ELSEIF (size(reply->qual,5) > 65000)
  SET stat = alterlist(reply->qual,0)
  SET reply->status_data.subeventstatus[1].targetobjectvalue = build3(3,
   "Number of code values retrieved for code set ",cnvtint(request->code_set),
   " exceeds the limit of 65K.")
 ELSE
  SET reply->status_data.status = "S"
  SET stat = alterlist(reply->qual,count1)
 ENDIF
#exit_program
END GO
