CREATE PROGRAM core_get_cd_values_by_set:dba
 SET modify = predeclare
 FREE RECORD reply
 RECORD reply(
   1 cd_value_list[*]
     2 active_ind = i2
     2 begin_effective_dt_tm = dq8
     2 cdf_meaning = c12
     2 cki = vc
     2 code_value = f8
     2 collation_seq = i4
     2 concept_cki = vc
     2 auth_ind = i2
     2 data_status_dt_tm = dq8
     2 definition = vc
     2 description = vc
     2 display = c40
     2 display_key = c40
     2 end_effective_dt_tm = dq8
     2 cd_value_group_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE script_version = vc WITH public, noconstant(" ")
 DECLARE failed = c1 WITH public, noconstant("F")
 DECLARE unauth = f8 WITH public, noconstant(0.0)
 SET reply->status_data.status = "F"
 SET unauth = uar_get_code_by("MEANING",8,"UNAUTH")
 IF (request->order_flag)
  SELECT
   IF (request->auth_search_flag)
    PLAN (cvs
     WHERE (cvs.code_set=request->code_set)
      AND cvs.inq_access_ind=1)
     JOIN (cv
     WHERE cv.code_set=cvs.code_set
      AND cv.data_status_cd != unauth
      AND cv.active_ind=1)
     JOIN (cvg
     WHERE cvg.parent_code_value=outerjoin(cv.code_value))
   ELSE
    PLAN (cvs
     WHERE (cvs.code_set=request->code_set)
      AND cvs.inq_access_ind=1)
     JOIN (cv
     WHERE cv.code_set=cvs.code_set)
     JOIN (cvg
     WHERE cvg.parent_code_value=outerjoin(cv.code_value))
   ENDIF
   INTO "nl:"
   cv.active_ind, cv.begin_effective_dt_tm, cv.cdf_meaning,
   cv.cki, cv.code_set, cv.code_value,
   cv.collation_seq, cv.concept_cki, cv.data_status_cd,
   cv.definition, cv.description, cv.display,
   cv.display_key, cv.end_effective_dt_tm, group_ind = nullind(cvg.parent_code_value)
   FROM code_value_set cvs,
    code_value cv,
    code_value_group cvg
   ORDER BY cv.display_key, cv.code_value
   HEAD REPORT
    cv_cnt = 0
   HEAD cv.display_key
    row + 0
   HEAD cv.code_value
    cv_cnt = (cv_cnt+ 1)
    IF (mod(cv_cnt,10)=1)
     stat = alterlist(reply->cd_value_list,(cv_cnt+ 9))
    ENDIF
    reply->cd_value_list[cv_cnt].active_ind = cv.active_ind, reply->cd_value_list[cv_cnt].cdf_meaning
     = cv.cdf_meaning, reply->cd_value_list[cv_cnt].cki = cv.cki,
    reply->cd_value_list[cv_cnt].code_value = cv.code_value, reply->cd_value_list[cv_cnt].
    collation_seq = cv.collation_seq, reply->cd_value_list[cv_cnt].concept_cki = cv.concept_cki,
    reply->cd_value_list[cv_cnt].definition = cv.definition, reply->cd_value_list[cv_cnt].description
     = cv.description, reply->cd_value_list[cv_cnt].display = cv.display,
    reply->cd_value_list[cv_cnt].display_key = cv.display_key, reply->cd_value_list[cv_cnt].
    begin_effective_dt_tm = cnvtdatetime(cv.begin_effective_dt_tm), reply->cd_value_list[cv_cnt].
    end_effective_dt_tm = cnvtdatetime(cv.end_effective_dt_tm),
    reply->cd_value_list[cv_cnt].data_status_dt_tm = cnvtdatetime(cv.data_status_dt_tm)
    IF (cv.data_status_cd != unauth)
     reply->cd_value_list[cv_cnt].auth_ind = 1
    ELSE
     reply->cd_value_list[cv_cnt].auth_ind = 0
    ENDIF
   DETAIL
    IF ( NOT (group_ind))
     reply->cd_value_list[cv_cnt].cd_value_group_ind = true
    ENDIF
   FOOT  cv.code_value
    row + 0
   FOOT  cv.display_key
    row + 0
   FOOT REPORT
    stat = alterlist(reply->cd_value_list,cv_cnt)
   WITH nocounter, maxread(cvg,1)
  ;end select
 ELSE
  SELECT
   IF (request->auth_search_flag)
    PLAN (cvs
     WHERE (cvs.code_set=request->code_set)
      AND cvs.inq_access_ind=1)
     JOIN (cv
     WHERE cv.code_set=cvs.code_set
      AND cv.data_status_cd != unauth
      AND cv.active_ind=1)
     JOIN (cvg
     WHERE cvg.parent_code_value=outerjoin(cv.code_value))
   ELSE
    PLAN (cvs
     WHERE (cvs.code_set=request->code_set)
      AND cvs.inq_access_ind=1)
     JOIN (cv
     WHERE cv.code_set=cvs.code_set)
     JOIN (cvg
     WHERE cvg.parent_code_value=outerjoin(cv.code_value))
   ENDIF
   INTO "nl:"
   cv.active_ind, cv.begin_effective_dt_tm, cv.cdf_meaning,
   cv.cki, cv.code_set, cv.code_value,
   cv.collation_seq, cv.concept_cki, cv.data_status_cd,
   cv.definition, cv.description, cv.display,
   cv.display_key, cv.end_effective_dt_tm, group_ind = nullind(cvg.parent_code_value)
   FROM code_value_set cvs,
    code_value cv,
    code_value_group cvg
   ORDER BY cv.code_value
   HEAD REPORT
    cv_cnt = 0
   HEAD cv.code_value
    cv_cnt = (cv_cnt+ 1)
    IF (mod(cv_cnt,10)=1)
     stat = alterlist(reply->cd_value_list,(cv_cnt+ 9))
    ENDIF
    reply->cd_value_list[cv_cnt].active_ind = cv.active_ind, reply->cd_value_list[cv_cnt].cdf_meaning
     = cv.cdf_meaning, reply->cd_value_list[cv_cnt].cki = cv.cki,
    reply->cd_value_list[cv_cnt].code_value = cv.code_value, reply->cd_value_list[cv_cnt].
    collation_seq = cv.collation_seq, reply->cd_value_list[cv_cnt].concept_cki = cv.concept_cki,
    reply->cd_value_list[cv_cnt].definition = cv.definition, reply->cd_value_list[cv_cnt].description
     = cv.description, reply->cd_value_list[cv_cnt].display = cv.display,
    reply->cd_value_list[cv_cnt].display_key = cv.display_key, reply->cd_value_list[cv_cnt].
    begin_effective_dt_tm = cnvtdatetime(cv.begin_effective_dt_tm), reply->cd_value_list[cv_cnt].
    end_effective_dt_tm = cnvtdatetime(cv.end_effective_dt_tm),
    reply->cd_value_list[cv_cnt].data_status_dt_tm = cnvtdatetime(cv.data_status_dt_tm)
    IF (cv.data_status_cd != unauth)
     reply->cd_value_list[cv_cnt].auth_ind = 1
    ELSE
     reply->cd_value_list[cv_cnt].auth_ind = 0
    ENDIF
   DETAIL
    IF ( NOT (group_ind))
     reply->cd_value_list[cv_cnt].cd_value_group_ind = true
    ENDIF
   FOOT  cv.code_value
    row + 0
   FOOT REPORT
    stat = alterlist(reply->cd_value_list,cv_cnt)
   WITH nocounter, maxread(cvg,1)
  ;end select
 ENDIF
 IF (curqual < 1)
  SET failed = "T"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET script_version = "001 10/16/03 JF8275"
END GO
