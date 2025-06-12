CREATE PROGRAM bed_get_bb_group_type:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 qual[*]
      2 abo_code_value = f8
      2 abo_display = vc
      2 rh_code_value = f8
      2 rh_display = vc
      2 aborh_code_value = f8
      2 display = vc
      2 description = vc
      2 meaning = vc
      2 standard_code_value = f8
      2 bar_code = vc
      2 active_ind = i2
      2 isbt = vc
      2 result_display[*]
        3 display = vc
        3 description = vc
        3 active_ind = i2
        3 meaning = vc
        3 code_value = f8
        3 chart_name = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE RECORD temp_record_to_store_parent
 RECORD temp_record_to_store_parent(
   1 qual[*]
     2 active_ind = i2
     2 display = vc
     2 description = vc
     2 abo_disp = vc
     2 rh_disp = vc
     2 barcode = vc
     2 code_value = f8
     2 updt_cnt = i4
     2 abo_cd = vc
     2 rh_cd = vc
     2 isbt_meaning = vc
 )
 FREE RECORD temp_record_to_store_children
 RECORD temp_record_to_store_children(
   1 qual[*]
     2 active_ind = i2
     2 display = c40
     2 description = c40
     2 chart_name = vc
     2 meaning = vc
     2 cdf_meaning = vc
     2 standard_aborh_disp = vc
     2 code_value = f8
     2 updt_cnt = i4
     2 standard_aborh_cd = f8
     2 chartname_cd = vc
     2 has_parent_ind = i4
 )
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET failed = "N"
 DECLARE count1 = i2
 DECLARE parentcnt = i2
 DECLARE childcnt = i2
 SET count1 = 0
 SELECT INTO "nl:"
  c.code_value, c.display, cve.field_name,
  cve.field_value, aborh_disp =
  IF (((cve.field_name="ABOOnly_cd") OR (cve.field_name="RhOnly_cd")) ) uar_get_code_display(cnvtreal
    (cve.field_value))
  ELSE " "
  ENDIF
  FROM code_value c,
   code_value_extension cve
  PLAN (c
   WHERE c.code_set=1640)
   JOIN (cve
   WHERE cve.code_value=c.code_value)
  ORDER BY c.code_value
  HEAD REPORT
   stat = alterlist(temp_record_to_store_parent->qual,100), count1 = 0
  HEAD c.code_value
   count1 = (count1+ 1)
   IF (mod(count1,10)=1
    AND count1 > 100)
    stat = alterlist(temp_record_to_store_parent->qual,(count1+ 9))
   ENDIF
   temp_record_to_store_parent->qual[count1].active_ind = c.active_ind, temp_record_to_store_parent->
   qual[count1].display = c.display, temp_record_to_store_parent->qual[count1].description = c
   .description,
   temp_record_to_store_parent->qual[count1].code_value = c.code_value, temp_record_to_store_parent->
   qual[count1].isbt_meaning = c.cdf_meaning, temp_record_to_store_parent->qual[count1].updt_cnt = c
   .updt_cnt
  DETAIL
   IF (cve.field_name="Barcode")
    temp_record_to_store_parent->qual[count1].barcode = cve.field_value
   ENDIF
   IF (cve.field_name="ABOOnly_cd")
    temp_record_to_store_parent->qual[count1].abo_cd = cve.field_value, temp_record_to_store_parent->
    qual[count1].abo_disp = aborh_disp
   ENDIF
   IF (cve.field_name="RhOnly_cd")
    temp_record_to_store_parent->qual[count1].rh_cd = cve.field_value, temp_record_to_store_parent->
    qual[count1].rh_disp = aborh_disp
   ENDIF
  FOOT REPORT
   stat = alterlist(temp_record_to_store_parent->qual,count1)
  WITH counter, outerjoin = d
 ;end select
 SET count1 = 0
 SELECT INTO "nl:"
  c.code_value, c.display, cdf.display,
  cve.field_name, cve.field_value, aborh_disp =
  IF (cve.field_name="ABORH_cd") uar_get_code_display(cnvtreal(cve.field_value))
  ELSE " "
  ENDIF
  FROM code_value c,
   code_value_extension cve,
   common_data_foundation cdf
  PLAN (c
   WHERE c.code_set=1643)
   JOIN (cve
   WHERE cve.code_value=c.code_value)
   JOIN (cdf
   WHERE cdf.cdf_meaning=c.cdf_meaning
    AND cdf.code_set=1643)
  ORDER BY c.code_value
  HEAD REPORT
   stat = alterlist(temp_record_to_store_children->qual,100), count1 = 0
  HEAD c.code_value
   count1 = (count1+ 1)
   IF (mod(count1,10)=1
    AND count1 > 100)
    stat = alterlist(temp_record_to_store_children->qual,(count1+ 9))
   ENDIF
   temp_record_to_store_children->qual[count1].active_ind = c.active_ind,
   temp_record_to_store_children->qual[count1].display = c.display, temp_record_to_store_children->
   qual[count1].description = c.description,
   temp_record_to_store_children->qual[count1].code_value = c.code_value,
   temp_record_to_store_children->qual[count1].updt_cnt = c.updt_cnt, temp_record_to_store_children->
   qual[count1].meaning = cdf.display,
   temp_record_to_store_children->qual[count1].cdf_meaning = c.cdf_meaning,
   temp_record_to_store_children->qual[count1].has_parent_ind = 0
  DETAIL
   IF (cve.field_name="ABORH_cd")
    temp_record_to_store_children->qual[count1].standard_aborh_cd = cnvtreal(cve.field_value),
    temp_record_to_store_children->qual[count1].standard_aborh_disp = aborh_disp
   ENDIF
   IF (cve.field_name="ChartName")
    temp_record_to_store_children->qual[count1].chart_name = cve.field_value
   ENDIF
  FOOT REPORT
   stat = alterlist(temp_record_to_store_children->qual,count1)
  WITH counter, outerjoin = d
 ;end select
 SET temp_record_to_store_parentcnt = size(temp_record_to_store_parent->qual,5)
 SET temp_record_to_store_childrencnt = size(temp_record_to_store_children->qual,5)
 SET childcnt = 0
 SET parentcnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(temp_record_to_store_parentcnt)),
   (dummyt d2  WITH seq = value(temp_record_to_store_childrencnt)),
   dummyt d
  PLAN (d1)
   JOIN (d)
   JOIN (d2
   WHERE (temp_record_to_store_children->qual[d2.seq].standard_aborh_cd=temp_record_to_store_parent->
   qual[d1.seq].code_value))
  ORDER BY temp_record_to_store_parent->qual[d1.seq].code_value, cnvtreal(
    temp_record_to_store_children->qual[d2.seq].standard_aborh_cd)
  HEAD REPORT
   stat = alterlist(reply->qual,100), parentcnt = 0
  HEAD d1.seq
   parentcnt = (parentcnt+ 1)
   IF (mod(parentcnt,10)=1
    AND parentcnt > 100)
    stat = alterlist(reply->qual,(parentcnt+ 9))
   ENDIF
   reply->qual[parentcnt].aborh_code_value = temp_record_to_store_parent->qual[d1.seq].code_value,
   reply->qual[parentcnt].abo_code_value = cnvtreal(temp_record_to_store_parent->qual[d1.seq].abo_cd),
   reply->qual[parentcnt].abo_display = temp_record_to_store_parent->qual[d1.seq].abo_disp,
   reply->qual[parentcnt].rh_code_value = cnvtreal(temp_record_to_store_parent->qual[d1.seq].rh_cd),
   reply->qual[parentcnt].rh_display = temp_record_to_store_parent->qual[d1.seq].rh_disp, reply->
   qual[parentcnt].display = temp_record_to_store_parent->qual[d1.seq].display,
   reply->qual[parentcnt].description = temp_record_to_store_parent->qual[d1.seq].description, reply
   ->qual[parentcnt].bar_code = temp_record_to_store_parent->qual[d1.seq].barcode, reply->qual[
   parentcnt].active_ind = temp_record_to_store_parent->qual[d1.seq].active_ind,
   reply->qual[parentcnt].isbt = temp_record_to_store_parent->qual[d1.seq].isbt_meaning, stat =
   alterlist(reply->qual[parentcnt].result_display,100), childcnt = 0
  HEAD d2.seq
   IF ((temp_record_to_store_children->qual[d2.seq].standard_aborh_cd=temp_record_to_store_parent->
   qual[d1.seq].code_value))
    temp_record_to_store_children->qual[d2.seq].has_parent_ind = 1, childcnt = (childcnt+ 1)
    IF (mod(childcnt,10)=1
     AND childcnt > 100)
     stat = alterlist(reply->qual[parentcnt].result_display,childcnt)
    ENDIF
    reply->qual[parentcnt].result_display[childcnt].display = temp_record_to_store_children->qual[d2
    .seq].display, reply->qual[parentcnt].result_display[childcnt].description =
    temp_record_to_store_children->qual[d2.seq].description, reply->qual[parentcnt].result_display[
    childcnt].active_ind = temp_record_to_store_children->qual[d2.seq].active_ind,
    reply->qual[parentcnt].result_display[childcnt].meaning = cnvtupper(temp_record_to_store_children
     ->qual[d2.seq].meaning), reply->qual[parentcnt].result_display[childcnt].code_value =
    temp_record_to_store_children->qual[d2.seq].code_value, reply->qual[parentcnt].result_display[
    childcnt].chart_name = temp_record_to_store_children->qual[d2.seq].chart_name,
    reply->qual[parentcnt].meaning = cnvtupper(temp_record_to_store_children->qual[d2.seq].meaning),
    reply->qual[parentcnt].standard_code_value = temp_record_to_store_children->qual[d2.seq].
    standard_aborh_cd
   ENDIF
  FOOT  d1.seq
   stat = alterlist(reply->qual[parentcnt].result_display,childcnt)
  FOOT REPORT
   stat = alterlist(reply->qual,parentcnt)
  WITH nocounter, outerjoin = d
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d2  WITH seq = value(temp_record_to_store_childrencnt))
  PLAN (d2
   WHERE (temp_record_to_store_children->qual[d2.seq].has_parent_ind=0))
  HEAD REPORT
   parentcnt = (parentcnt+ 1), stat = alterlist(reply->qual,parentcnt), stat = alterlist(reply->qual[
    parentcnt].result_display,100),
   childcnt = 0
  HEAD d2.seq
   childcnt = (childcnt+ 1)
   IF (mod(childcnt,10)=1
    AND childcnt > 100)
    stat = alterlist(reply->qual[parentcnt].result_display,(childcnt+ 9))
   ENDIF
   reply->qual[parentcnt].aborh_code_value = 0.0, reply->qual[parentcnt].abo_code_value = 0.0, reply
   ->qual[parentcnt].abo_display = "",
   reply->qual[parentcnt].rh_code_value = 0.0, reply->qual[parentcnt].rh_display = "", reply->qual[
   parentcnt].display = "",
   reply->qual[parentcnt].description = "", reply->qual[parentcnt].bar_code = " ", reply->qual[
   parentcnt].active_ind = temp_record_to_store_children->qual[d2.seq].active_ind,
   reply->qual[parentcnt].isbt = "", reply->qual[parentcnt].result_display[childcnt].display =
   temp_record_to_store_children->qual[d2.seq].display, reply->qual[parentcnt].result_display[
   childcnt].description = temp_record_to_store_children->qual[d2.seq].description,
   reply->qual[parentcnt].result_display[childcnt].active_ind = temp_record_to_store_children->qual[
   d2.seq].active_ind, reply->qual[parentcnt].result_display[childcnt].code_value =
   temp_record_to_store_children->qual[d2.seq].code_value, reply->qual[parentcnt].result_display[
   childcnt].chart_name = temp_record_to_store_children->qual[d2.seq].chart_name,
   reply->qual[parentcnt].meaning = cnvtupper(temp_record_to_store_children->qual[d2.seq].meaning),
   reply->qual[parentcnt].result_display[childcnt].meaning = cnvtupper(temp_record_to_store_children
    ->qual[d2.seq].meaning)
  FOOT REPORT
   stat = alterlist(reply->qual[parentcnt].result_display,childcnt)
  WITH nocounter
 ;end select
 CALL echorecord(reply)
#exit_script
 IF (failed="Y")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
