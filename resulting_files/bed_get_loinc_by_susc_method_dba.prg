CREATE PROGRAM bed_get_loinc_by_susc_method:dba
 SET modify = predeclare
 RECORD reply(
   1 codes[*]
     2 method_cd = f8
     2 method_disp = vc
     2 method_desc = vc
     2 antibiotics[*]
       3 antibiotic_cd = f8
       3 antibiotic_disp = vc
       3 antibiotic_desc = vc
       3 concept_ident_mic_susc_id = f8
       3 concept_cki = vc
       3 concept_type_flag = i2
       3 ignore_ind = i2
       3 nomenclature_id = f8
       3 loinc_code = vc
       3 loinc_short_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET temp
 RECORD temp(
   1 antibiotics[*]
     2 code_value = f8
 ) WITH protect
 DECLARE error_check = i4 WITH private, noconstant(0)
 DECLARE error_msg = vc WITH protect, noconstant("")
 DECLARE ab_idx = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE x = i4 WITH private, noconstant(0)
 DECLARE y = i4 WITH private, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE cur_size = i4 WITH protect, noconstant(0)
 DECLARE batch_size = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE expand_idx = i4 WITH protect, noconstant(0)
 DECLARE locate_idx = i4 WITH protect, noconstant(0)
 DECLARE new_size = i4 WITH protect, noconstant(0)
 DECLARE start = i4 WITH protect, noconstant(0)
 DECLARE loop_cnt = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=1011
    AND cv.active_ind=1
    AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND cv.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  HEAD REPORT
   cnt = 0
  DETAIL
   IF (cv.cdf_meaning != "ESIDEFAULT")
    cnt = (cnt+ 1)
    IF (mod(cnt,25)=1)
     stat = alterlist(temp->antibiotics,(cnt+ 24))
    ENDIF
    temp->antibiotics[cnt].code_value = cv.code_value
   ENDIF
  FOOT REPORT
   stat = alterlist(temp->antibiotics,cnt)
  WITH nocounter
 ;end select
 IF (size(temp->antibiotics,5)=0)
  GO TO exit_script
 ENDIF
 SET cur_size = size(temp->antibiotics,5)
 IF (cur_size < 100)
  SET batch_size = cur_size
 ELSE
  SET batch_size = 100
 ENDIF
 SET loop_cnt = ceil((cnvtreal(cur_size)/ batch_size))
 SET new_size = (loop_cnt * batch_size)
 SET start = 1
 SET stat = alterlist(temp->antibiotics,new_size)
 FOR (idx = (cur_size+ 1) TO new_size)
   SET temp->antibiotics[idx].code_value = temp->antibiotics[cur_size].code_value
 ENDFOR
 SET stat = alterlist(reply->codes,size(request->methods,5))
 FOR (x = 1 TO size(request->methods,5))
   SET reply->codes[x].method_cd = request->methods[x].method_cd
   SET stat = alterlist(reply->codes[x].antibiotics,cur_size)
   FOR (y = 1 TO cur_size)
     SET reply->codes[x].antibiotics[y].antibiotic_cd = temp->antibiotics[y].code_value
   ENDFOR
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(reply->codes,5))),
   (dummyt d2  WITH seq = value(loop_cnt)),
   concept_ident_mic_susc cims,
   nomenclature n
  PLAN (d1)
   JOIN (d2
   WHERE assign(start,evaluate(d2.seq,1,1,(start+ batch_size))))
   JOIN (cims
   WHERE expand(expand_idx,start,((start+ batch_size) - 1),cims.antibiotic_cd,temp->antibiotics[
    expand_idx].code_value)
    AND (cims.method_cd=reply->codes[d1.seq].method_cd)
    AND cims.active_ind=1
    AND cims.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND cims.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND (cims.concept_type_flag=request->concept_type_flag))
   JOIN (n
   WHERE ((n.concept_cki=cims.concept_cki
    AND trim(cims.concept_cki) > " "
    AND n.primary_vterm_ind=1
    AND n.active_ind=1
    AND n.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND n.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND n.disallowed_ind=0) OR (n.nomenclature_id=0.0)) )
  ORDER BY d1.seq, cims.antibiotic_cd
  HEAD d1.seq
   row + 0
  HEAD cims.antibiotic_cd
   row + 0
  DETAIL
   locate_start = (((d2.seq - 1) * batch_size)+ 1), locate_end = ((locate_start+ batch_size) - 1)
   IF (locate_end > cur_size)
    locate_end = cur_size
   ENDIF
   pos = locateval(ab_idx,locate_start,locate_end,cims.antibiotic_cd,reply->codes[d1.seq].
    antibiotics[ab_idx].antibiotic_cd)
   IF (pos > 0)
    reply->codes[d1.seq].antibiotics[pos].concept_ident_mic_susc_id = cims.concept_ident_mic_susc_id,
    reply->codes[d1.seq].antibiotics[pos].concept_cki = cims.concept_cki, reply->codes[d1.seq].
    antibiotics[pos].concept_type_flag = cims.concept_type_flag,
    reply->codes[d1.seq].antibiotics[pos].ignore_ind = cims.ignore_ind
    IF (n.nomenclature_id > 0.0)
     reply->codes[d1.seq].antibiotics[pos].nomenclature_id = n.nomenclature_id, reply->codes[d1.seq].
     antibiotics[pos].loinc_code = n.source_identifier, reply->codes[d1.seq].antibiotics[pos].
     loinc_short_name = n.short_string
    ENDIF
   ENDIF
  FOOT  cims.antibiotic_cd
   row + 0
  FOOT  d1.seq
   row + 0
  WITH nocounter
 ;end select
#exit_script
 SET error_check = error(error_msg,0)
 IF (error_check != 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = error_msg
 ELSEIF (size(reply->codes,5) > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SET modify = nopredeclare
END GO
