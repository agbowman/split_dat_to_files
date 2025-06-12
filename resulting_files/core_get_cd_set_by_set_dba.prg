CREATE PROGRAM core_get_cd_set_by_set:dba
 SET modify = predeclare
 IF (validate(reply)=0)
  FREE RECORD reply
  RECORD reply(
    1 active_ind_dup_ind = i2
    1 add_access_ind = i2
    1 alias_dup_ind = i2
    1 cache_ind = i2
    1 cdf_meaning_dup_ind = i2
    1 chg_access_ind = i2
    1 code_set = i4
    1 definition = vc
    1 def_dup_rule_flag = i2
    1 del_access_ind = i2
    1 description = vc
    1 display = c40
    1 display_dup_ind = i2
    1 display_key = c40
    1 display_key_dup_ind = i2
    1 extension_ind = i2
    1 inq_access_ind = i2
    1 definition_dup_ind = i2
    1 code_value_count = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE script_version = vc WITH public, noconstant(" ")
 DECLARE failed = c1 WITH public, noconstant("F")
 DECLARE cv_count = i4 WITH public, noconstant(0)
 DECLARE cur_info_name = vc WITH public, noconstant(" ")
 DECLARE cur_info_date = i4 WITH public, noconstant(0)
 DECLARE info_cnt = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant(" ")
 SET reply->status_data.status = "F"
 SET cur_info_name = build2("CODE SET ",build(request->code_set))
 SET info_cnt = 0
 SELECT INTO "nl:"
  dm.info_number, dm.info_date
  FROM dm_info dm
  WHERE dm.info_domain="CCB_CODE_VALUE_COUNT"
   AND dm.info_name=cur_info_name
  DETAIL
   cv_count = dm.info_number, cur_info_date = cnvtdate(dm.info_date), info_cnt = (info_cnt+ 1)
  WITH nocounter
 ;end select
 IF (error(errmsg,0) != 0)
  SET failed = "T"
  GO TO exit_script
 ENDIF
 IF (info_cnt != 1)
  DELETE  FROM dm_info
   WHERE info_domain="CCB_CODE_VALUE_COUNT"
    AND info_name=cur_info_name
  ;end delete
  IF (error(errmsg,0) != 0)
   SET failed = "T"
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   cnt = count(cv.code_value)
   FROM code_value cv
   WHERE (cv.code_set=request->code_set)
   DETAIL
    cv_count = cnt
   WITH nocounter
  ;end select
  IF (curqual < 1)
   SET failed = "T"
   GO TO exit_script
  ENDIF
  IF (error(errmsg,0) != 0)
   SET failed = "T"
   GO TO exit_script
  ENDIF
  INSERT  FROM dm_info
   (info_domain, info_name, info_number,
   info_date, updt_dt_tm, updt_cnt)
   VALUES("CCB_CODE_VALUE_COUNT", cur_info_name, cv_count,
   cnvtdatetime(curdate,curtime3), cnvtdatetime(curdate,curtime3), 0)
   WITH nocounter
  ;end insert
  IF (error(errmsg,0) != 0)
   SET failed = "T"
   GO TO exit_script
  ENDIF
  COMMIT
  SET reply->code_value_count = cv_count
 ELSEIF ((cur_info_date < (curdate - 30)))
  SELECT INTO "nl:"
   cnt = count(cv.code_value)
   FROM code_value cv
   WHERE (cv.code_set=request->code_set)
   DETAIL
    cv_count = cnt
   WITH nocounter
  ;end select
  IF (error(errmsg,0) != 0)
   SET failed = "T"
   GO TO exit_script
  ENDIF
  UPDATE  FROM dm_info dm
   SET dm.info_number = cv_count, dm.info_date = cnvtdatetime(curdate,curtime3), dm.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    dm.updt_cnt = (dm.updt_cnt+ 1)
   WHERE info_domain="CCB_CODE_VALUE_COUNT"
    AND info_name=cur_info_name
   WITH nocounter
  ;end update
  IF (error(errmsg,0) != 0)
   SET failed = "T"
   GO TO exit_script
  ENDIF
  COMMIT
  SET reply->code_value_count = cv_count
 ELSE
  SET reply->code_value_count = cv_count
 ENDIF
 SELECT INTO "nl:"
  cvs.active_ind_dup_ind, cvs.add_access_ind, cvs.alias_dup_ind,
  cvs.cache_ind, cvs.cdf_meaning_dup_ind, cvs.chg_access_ind,
  cvs.code_set, cvs.definition, cvs.def_dup_rule_flag,
  cvs.del_access_ind, cvs.description, cvs.display,
  cvs.display_dup_ind, cvs.display_key, cvs.display_key_dup_ind,
  cvs.extension_ind, cvs.inq_access_ind, cvs.definition_dup_ind
  FROM code_value_set cvs
  PLAN (cvs
   WHERE (cvs.code_set=request->code_set))
  DETAIL
   reply->active_ind_dup_ind = cvs.active_ind_dup_ind, reply->add_access_ind = cvs.add_access_ind,
   reply->alias_dup_ind = cvs.alias_dup_ind,
   reply->cache_ind = cvs.cache_ind, reply->cdf_meaning_dup_ind = cvs.cdf_meaning_dup_ind, reply->
   chg_access_ind = cvs.chg_access_ind,
   reply->code_set = cvs.code_set, reply->definition = cvs.definition, reply->def_dup_rule_flag = cvs
   .def_dup_rule_flag,
   reply->del_access_ind = cvs.del_access_ind, reply->description = cvs.description, reply->display
    = cvs.display,
   reply->display_dup_ind = cvs.display_dup_ind, reply->display_key = cvs.display_key, reply->
   display_key_dup_ind = cvs.display_key_dup_ind,
   reply->extension_ind = cvs.extension_ind, reply->inq_access_ind = cvs.inq_access_ind, reply->
   definition_dup_ind = cvs.definition_dup_ind
  WITH nocounter
 ;end select
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
 SET script_version = "000 02/25/03 JF8275"
END GO
