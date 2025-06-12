CREATE PROGRAM core_get_cd_set_ext_by_set:dba
 SET modify = predeclare
 FREE RECORD reply
 RECORD reply(
   1 cd_value_list[*]
     2 code_value_disp = c40
     2 code_value = f8
     2 active_ind = i2
     2 ext_list[*]
       3 field_name = c32
       3 field_type = i4
       3 field_value = vc
       3 field_exists_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD temp
 RECORD temp(
   1 ext_cnt = i4
   1 ext[*]
     2 field_name = c32
     2 field_type = i4
 )
 DECLARE script_version = vc WITH public, noconstant(" ")
 DECLARE failed = c1 WITH public, noconstant("F")
 DECLARE cv_cnt = i4 WITH public, noconstant(0)
 DECLARE ext_cnt = i4 WITH public, noconstant(0)
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  cse.field_name, cse.field_type
  FROM code_set_extension cse
  PLAN (cse
   WHERE (cse.code_set=request->code_set))
  ORDER BY cse.field_name
  HEAD REPORT
   temp->ext_cnt = 0
  DETAIL
   temp->ext_cnt = (temp->ext_cnt+ 1)
   IF (mod(temp->ext_cnt,10)=1)
    stat = alterlist(temp->ext,(temp->ext_cnt+ 9))
   ENDIF
   temp->ext[temp->ext_cnt].field_name = cse.field_name, temp->ext[temp->ext_cnt].field_type = cse
   .field_type
  FOOT REPORT
   stat = alterlist(temp->ext,temp->ext_cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  cv.display, cv.code_value, cv.active_ind
  FROM code_value cv
  PLAN (cv
   WHERE (cv.code_set=request->code_set)
    AND cv.active_ind=1
    AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND cv.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  ORDER BY cv.code_value
  HEAD REPORT
   cv_cnt = 0
  HEAD cv.code_value
   cv_cnt = (cv_cnt+ 1)
   IF (mod(cv_cnt,10)=1)
    stat = alterlist(reply->cd_value_list,(cv_cnt+ 9))
   ENDIF
   reply->cd_value_list[cv_cnt].code_value_disp = cv.display, reply->cd_value_list[cv_cnt].code_value
    = cv.code_value, reply->cd_value_list[cv_cnt].active_ind = cv.active_ind,
   stat = alterlist(reply->cd_value_list[cv_cnt].ext_list,temp->ext_cnt)
   FOR (x = 1 TO temp->ext_cnt)
    reply->cd_value_list[cv_cnt].ext_list[x].field_name = temp->ext[x].field_name,reply->
    cd_value_list[cv_cnt].ext_list[x].field_type = temp->ext[x].field_type
   ENDFOR
  DETAIL
   row + 0
  FOOT  cv.code_value
   row + 0
  FOOT REPORT
   stat = alterlist(reply->cd_value_list,cv_cnt)
  WITH nocounter
 ;end select
 IF (curqual <= 0)
  SET failed = "T"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  cve.field_name, cve.field_value, cve.code_value
  FROM code_value_extension cve,
   (dummyt d  WITH seq = value(cv_cnt))
  PLAN (d)
   JOIN (cve
   WHERE (cve.code_value=reply->cd_value_list[d.seq].code_value))
  DETAIL
   FOR (x = 1 TO temp->ext_cnt)
     IF (trim(reply->cd_value_list[d.seq].ext_list[x].field_name)=cve.field_name)
      reply->cd_value_list[d.seq].ext_list[x].field_value = cve.field_value, reply->cd_value_list[d
      .seq].ext_list[x].field_exists_ind = 1
     ENDIF
   ENDFOR
  WITH nocounter
 ;end select
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET script_version = "000 04/11/03 JF8275"
END GO
