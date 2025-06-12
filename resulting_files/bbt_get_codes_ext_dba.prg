CREATE PROGRAM bbt_get_codes_ext:dba
 RECORD reply(
   1 qual[*]
     2 code_set = i4
     2 code_value = f8
     2 display = c40
     2 display_key = c40
     2 description = vc
     2 definition = vc
     2 cdf_meaning = c12
     2 collation_seq = i4
     2 active_type_cd = f8
     2 active_ind = i2
     2 updt_cnt = i4
     2 ext_cnt = i4
     2 ext[*]
       3 field_name = vc
       3 field_type = i4
       3 field_value = vc
       3 updt_cnt = i4
       3 display = c40
     2 significance_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET val_count = 0
 SET ext_count = 0
 SET nbr_in_array = size(request->codesetlist,5)
 SET stat = alterlist(reply->qual,20)
 SELECT INTO "nl:"
  cv.code_value, cv.code_set, cve.field_name,
  cve.field_type, cve.field_value, cv.display,
  cv.cdf_meaning, cv.collation_seq, cve.field_name,
  cve.field_type, cve.field_value, cve.updt_cnt,
  cve_display =
  IF (cve.field_type=1)
   IF (cnvtreal(cve.field_value) > 0) uar_get_code_display(cnvtreal(cve.field_value))
   ELSE ""
   ENDIF
  ELSE ""
  ENDIF
  , cv.display_key, cv.description,
  cv.definition, cv.active_type_cd, tr.requirement_cd,
  tr.significance_ind
  FROM (dummyt d  WITH seq = value(nbr_in_array)),
   code_value cv,
   code_value_extension cve,
   transfusion_requirements tr
  PLAN (d)
   JOIN (cv
   WHERE (cv.code_set=request->codesetlist[d.seq].code_set)
    AND (((request->codesetlist[d.seq].want_non_active != 1)
    AND cv.active_ind=1) OR ((request->codesetlist[d.seq].want_non_active=1)))
    AND cv.code_value != null
    AND cv.code_value > 0)
   JOIN (cve
   WHERE cve.code_value=outerjoin(cv.code_value))
   JOIN (tr
   WHERE tr.requirement_cd=outerjoin(cv.code_value))
  ORDER BY cv.code_set, cv.collation_seq, cv.code_value
  HEAD cv.code_value
   val_count = (val_count+ 1)
   IF (mod(val_count,20)=1
    AND val_count != 1)
    stat = alterlist(reply->qual,(19+ val_count))
   ENDIF
   reply->qual[val_count].code_set = cv.code_set, reply->qual[val_count].code_value = cv.code_value,
   reply->qual[val_count].display = cv.display,
   reply->qual[val_count].display_key = cv.display_key, reply->qual[val_count].description = cv
   .description, reply->qual[val_count].definition = cv.definition,
   reply->qual[val_count].active_ind = cv.active_ind, reply->qual[val_count].updt_cnt = cv.updt_cnt,
   reply->qual[val_count].active_type_cd = cv.active_type_cd,
   reply->qual[val_count].cdf_meaning = cv.cdf_meaning, reply->qual[val_count].collation_seq = cv
   .collation_seq
   IF (cv.code_set=1613
    AND tr.requirement_cd > 0)
    reply->qual[val_count].significance_ind = tr.significance_ind
   ENDIF
   ext_count = 0, stat = alterlist(reply->qual[val_count].ext,0), stat = alterlist(reply->qual[
    val_count].ext,10)
  DETAIL
   IF (cve.field_name > " ")
    ext_count = (ext_count+ 1)
    IF (mod(ext_count,10)=1
     AND ext_count != 1)
     stat = alterlist(reply->qual[val_count].ext,(9+ ext_count))
    ENDIF
    reply->qual[val_count].ext[ext_count].field_name = cve.field_name, reply->qual[val_count].ext[
    ext_count].field_type = cve.field_type, reply->qual[val_count].ext[ext_count].field_value = cve
    .field_value,
    reply->qual[val_count].ext[ext_count].updt_cnt = cve.updt_cnt, reply->qual[val_count].ext[
    ext_count].display = cve_display
   ENDIF
  FOOT  cv.code_value
   stat = alterlist(reply->qual[val_count].ext,ext_count), reply->qual[val_count].ext_cnt = ext_count
  FOOT REPORT
   stat = alterlist(reply->qual,val_count)
  WITH nocounter
 ;end select
 IF (val_count=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
