CREATE PROGRAM bed_get_bb_code_loinc:dba
 SET modify = predeclare
 RECORD reply(
   1 code_set_list[*]
     2 code_set = i4
     2 codes[*]
       3 code_cd = f8
       3 code_disp = vc
       3 code_desc = vc
       3 loinc_codes[*]
         4 concept_ident_bb_code_id = f8
         4 concept_cki = vc
         4 loinc_code = vc
         4 ignore_ind = i2
         4 concept_type_flag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE lidx = i4 WITH protect, noconstant(0)
 DECLARE lcnt2 = i4 WITH protect, noconstant(0)
 DECLARE lcnt3 = i4 WITH protect, noconstant(0)
 DECLARE x = i4 WITH protect, noconstant(0)
 DECLARE lidx2 = i4 WITH protect, noconstant(0)
 DECLARE lpos = i4 WITH protect, noconstant(0)
 DECLARE error_check = i4 WITH protect, noconstant(0)
 DECLARE serrormsg = vc WITH protect, noconstant("")
 DECLARE nstat = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET nstat = alterlist(reply->code_set_list,size(request->code_set_list,5))
 FOR (x = 1 TO size(request->code_set_list,5))
   SET reply->code_set_list[x].code_set = request->code_set_list[x].code_set
 ENDFOR
 SELECT
  IF ((request->concept_type_flag=0))
   PLAN (cv
    WHERE expand(lidx,1,size(request->code_set_list,5),cv.code_set,request->code_set_list[lidx].
     code_set)
     AND cv.active_ind=1
     AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND cv.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (cibc
    WHERE ((cibc.code_set=cv.code_set
     AND cibc.code_value=cv.code_value
     AND cibc.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND cibc.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     AND cibc.active_ind=1) OR (cibc.code_value=0.0)) )
  ELSE
   PLAN (cv
    WHERE expand(lidx,1,size(request->code_set_list,5),cv.code_set,request->code_set_list[lidx].
     code_set)
     AND cv.active_ind=1
     AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND cv.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (cibc
    WHERE ((cibc.code_set=cv.code_set
     AND cibc.code_value=cv.code_value
     AND cibc.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND cibc.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     AND cibc.active_ind=1
     AND (cibc.concept_type_flag=request->concept_type_flag)) OR (cibc.code_value=0.0)) )
  ENDIF
  INTO "nl:"
  FROM code_value cv,
   concept_ident_bb_code cibc
  ORDER BY cv.code_set, cv.code_value
  HEAD cv.code_set
   lpos = locateval(lidx2,1,size(reply->code_set_list,5),cv.code_set,reply->code_set_list[lidx2].
    code_set), lcnt2 = 0
  HEAD cv.code_value
   nvalid = 0
   IF (((cv.code_set=1612
    AND ((cv.cdf_meaning="+") OR (cv.cdf_meaning="-")) ) OR (cv.code_set=1613)) )
    nvalid = 1, lcnt2 = (lcnt2+ 1)
    IF (lcnt2 > size(reply->code_set_list[lpos].codes,5))
     nstat = alterlist(reply->code_set_list[lpos].codes,(lcnt2+ 10))
    ENDIF
    reply->code_set_list[lpos].codes[lcnt2].code_cd = cv.code_value
   ENDIF
   lcnt3 = 0
  DETAIL
   IF (nvalid=1)
    IF (cibc.concept_ident_bb_code_id > 0.0)
     lcnt3 = (lcnt3+ 1), nstat = alterlist(reply->code_set_list[lpos].codes[lcnt2].loinc_codes[lcnt3],
      lcnt3), reply->code_set_list[lpos].codes[lcnt2].loinc_codes[lcnt3].concept_ident_bb_code_id =
     cibc.concept_ident_bb_code_id,
     reply->code_set_list[lpos].codes[lcnt2].loinc_codes[lcnt3].concept_type_flag = cibc
     .concept_type_flag, reply->code_set_list[lpos].codes[lcnt2].loinc_codes[lcnt3].concept_cki =
     cibc.concept_cki, reply->code_set_list[lpos].codes[lcnt2].loinc_codes[lcnt3].loinc_code =
     replace(cibc.concept_cki,"LOINC!","",1),
     reply->code_set_list[lpos].codes[lcnt2].loinc_codes[lcnt3].ignore_ind = cibc.ignore_ind
    ENDIF
   ENDIF
  FOOT  cv.code_value
   row + 0
  FOOT  cv.code_set
   nstat = alterlist(reply->code_set_list[lpos].codes,lcnt2)
  WITH nocounter
 ;end select
 SET error_check = error(serrormsg,0)
 IF (error_check != 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
  GO TO exit_script
 ENDIF
 IF (size(reply->code_set_list,5) > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exit_script
 SET modify = nopredeclare
END GO
