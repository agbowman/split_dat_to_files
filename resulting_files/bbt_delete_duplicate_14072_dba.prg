CREATE PROGRAM bbt_delete_duplicate_14072:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD codeset14072(
   1 codevaluerows[*]
     2 code_value = f8
     2 cdf_meaning = c12
     2 active_ind = i2
 )
 RECORD duplicates(
   1 cdfs[*]
     2 cdf_meaning = c12
     2 codevalues[*]
       3 code_value = f8
       3 delete_ind = i2
 )
 RECORD deletelist(
   1 codevalues[*]
     2 code_value = f8
 )
 SET serrormsg = fillstring(255," ")
 SET nerrorstatus = error(serrormsg,1)
 SELECT INTO "nl:"
  cv.code_value, cv.cdf_meaning, cv.active_ind
  FROM code_value cv
  WHERE cv.code_set=14072
  HEAD REPORT
   row_cnt = 0, stat = alterlist(codeset14072->codevaluerows,5)
  DETAIL
   row_cnt = (row_cnt+ 1)
   IF (mod(row_cnt,5)=1
    AND row_cnt != 1)
    stat = alterlist(codeset14072->codevaluerows,(row_cnt+ 4))
   ENDIF
   codeset14072->codevaluerows[row_cnt].code_value = cv.code_value, codeset14072->codevaluerows[
   row_cnt].cdf_meaning = cv.cdf_meaning, codeset14072->codevaluerows[row_cnt].active_ind = cv
   .active_ind
  FOOT REPORT
   stat = alterlist(codeset14072->codevaluerows,row_cnt)
  WITH nocounter
 ;end select
 SET nerrorstatus = error(serrormsg,0)
 IF (nerrorstatus != 0)
  GO TO select_error
 ENDIF
 SELECT INTO "nl:"
  cv.code_value, cv.cdf_meaning
  FROM code_value cv,
   (dummyt d_cv  WITH seq = value(size(codeset14072->codevaluerows,5))),
   (dummyt d_be  WITH seq = 1),
   bb_exception be
  PLAN (d_cv)
   JOIN (cv
   WHERE cv.code_set=14072
    AND (codeset14072->codevaluerows[d_cv.seq].cdf_meaning=cv.cdf_meaning)
    AND (codeset14072->codevaluerows[d_cv.seq].code_value != cv.code_value)
    AND cv.active_ind=1)
   JOIN (d_be)
   JOIN (be
   WHERE be.exception_type_cd=cv.code_value)
  ORDER BY cv.cdf_meaning, cv.code_value
  HEAD REPORT
   cdf_cnt = 0, code_cnt = 0, stat = alterlist(duplicates->cdfs,5)
  HEAD cv.cdf_meaning
   code_cnt = 0, cdf_cnt = (cdf_cnt+ 1)
   IF (mod(cdf_cnt,5)=1
    AND cdf_cnt != 1)
    stat = alterlist(duplicates->cdfs,(cdf_cnt+ 4))
   ENDIF
   duplicates->cdfs[cdf_cnt].cdf_meaning = cv.cdf_meaning, stat = alterlist(duplicates->cdfs[cdf_cnt]
    .codevalues,5)
  HEAD cv.code_value
   code_cnt = (code_cnt+ 1)
   IF (mod(code_cnt,5)=1
    AND code_cnt != 1)
    stat = alterlist(duplicates->cdfs[cdf_cnt].codevalues,(code_cnt+ 4))
   ENDIF
   duplicates->cdfs[cdf_cnt].codevalues[code_cnt].code_value = cv.code_value
   IF (be.seq > 0)
    duplicates->cdfs[cdf_cnt].codevalues[code_cnt].delete_ind = 0
   ELSE
    duplicates->cdfs[cdf_cnt].codevalues[code_cnt].delete_ind = 1
   ENDIF
  DETAIL
   row + 0
  FOOT  cv.code_value
   row + 0
  FOOT  cv.cdf_meaning
   stat = alterlist(duplicates->cdfs[cdf_cnt].codevalues,code_cnt), cnt = 1, hasdatacount = 0
   WHILE (cnt <= code_cnt)
    IF ((duplicates->cdfs[cdf_cnt].codevalues[cnt].delete_ind=0))
     hasdatacount = (hasdatacount+ 1)
    ENDIF
    ,cnt = (cnt+ 1)
   ENDWHILE
   IF (code_cnt > 0)
    IF (hasdatacount=0)
     duplicates->cdfs[cdf_cnt].codevalues[1].delete_ind = 0
    ELSEIF (hasdatacount > 1)
     hasdatacount = hasdatacount
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(duplicates->cdfs,cdf_cnt)
  WITH nocounter, outerjoin(d_be)
 ;end select
 SET nerrorstatus = error(serrormsg,0)
 IF (nerrorstatus=0)
  IF (curqual > 0)
   SET count1 = 0
   SET count2 = 0
   SET code_value_cnt = 0
   SET stat = alterlist(deletelist->codevalues,5)
   FOR (count1 = 1 TO size(duplicates->cdfs,5))
     FOR (count2 = 1 TO size(duplicates->cdfs[count1].codevalues,5))
       IF ((duplicates->cdfs[count1].codevalues[count2].delete_ind=1))
        SET code_value_cnt = (code_value_cnt+ 1)
        IF (mod(code_value_cnt,5)=1
         AND code_value_cnt != 1)
         SET stat = alterlist(deletelist->codevalues,(code_value_cnt+ 4))
        ENDIF
        SET deletelist->codevalues[code_value_cnt].code_value = duplicates->cdfs[count1].codevalues[
        count2].code_value
       ENDIF
     ENDFOR
   ENDFOR
   SELECT INTO "nl:"
    cv.*
    FROM (dummyt d  WITH seq = value(size(deletelist->codevalues,5))),
     code_value cv
    PLAN (d)
     JOIN (cv
     WHERE (cv.code_value=deletelist->codevalues[d.seq].code_value))
    WITH nocounter, forupdate(cv)
   ;end select
   SET nerrorstatus = error(serrormsg,0)
   IF (nerrorstatus=0)
    UPDATE  FROM (dummyt d  WITH seq = value(size(deletelist->codevalues,5))),
      code_value cv
     SET cv.active_ind = 0
     PLAN (d)
      JOIN (cv
      WHERE (cv.code_value=deletelist->codevalues[d.seq].code_value))
     WITH nocounter
    ;end update
    SET nerrorstatus = error(serrormsg,0)
    IF (nerrorstatus=0)
     SET reply->status_data.status = "S"
    ELSE
     GO TO select_error
    ENDIF
   ELSE
    GO TO select_error
   ENDIF
  ELSE
   SET reply->status_data.status = "S"
   GO TO exit_script
  ENDIF
 ELSE
  GO TO select_error
 ENDIF
#select_error
 SET reply->status_data.status = "F"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
#exit_script
END GO
