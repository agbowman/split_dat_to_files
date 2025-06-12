CREATE PROGRAM ccl_get_report_object_list
 RECORD reply(
   1 object_list[*]
     2 object_name = c30
     2 object_description = vc
     2 object_type = c12
     2 username = vc
     2 ccl_group = i2
     2 section_list[*]
       3 section_name = c30
     2 updt_dt_tm = dq8
   1 verified_objecttype_list[*]
     2 display = vc
     2 meaning = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE cnt = i4 WITH noconstant(0), protect
 DECLARE cnt2 = i4 WITH noconstant(0), protect
 DECLARE errmsg = vc WITH noconstant(fillstring(255," ")), protect
 DECLARE section_cnt = i4 WITH noconstant(0), protect
 DECLARE sectionqual = vc WITH noconstant(""), protect
 DECLARE objecttype = vc
 DECLARE typequal = vc
 DECLARE num = i4
 SET typequal = 'RO.OBJECT_TYPE = ""'
 SET objecttype_cv = 0.0
 SET validobjectcount = 0
 SET validflag = 0
 SET allflag = 0
 SET objecttypecount = size(request->unverified_objecttype_list,5)
 SET allcount = 0
 SET icount = 1
 SET jcount = 1
 IF (trim(request->object_type) > " ")
  SET typequal = "RO.OBJECT_TYPE = trim(request->object_type)"
 ELSE
  WHILE (icount <= objecttypecount)
    IF ((request->unverified_objecttype_list[icount].unverified_objecttype="ALL"))
     SET cnt2 = (cnt2+ 1)
     SET stat = alterlist(reply->verified_objecttype_list,cnt2)
     SET reply->verified_objecttype_list[cnt2].meaning = "ALL"
     SET reply->verified_objecttype_list[cnt2].display = "ALL"
     SELECT INTO "nl:"
      cv.code_value
      FROM code_value cv
      WHERE cv.code_set=4000860
       AND cv.active_ind=1
      DETAIL
       cnt2 = (cnt2+ 1), allcount = cnt2, stat = alterlist(reply->verified_objecttype_list,cnt2),
       reply->verified_objecttype_list[cnt2].meaning = uar_get_code_meaning(cv.code_value), reply->
       verified_objecttype_list[cnt2].display = uar_get_code_display(cv.code_value), validflag = 1,
       allflag = 1
      WITH nocounter
     ;end select
    ELSE
     SET objecttype_cv = uar_get_code_by("MEANING",4000860,nullterm(request->
       unverified_objecttype_list[icount].unverified_objecttype))
     IF (objecttype_cv > 0.0
      AND allflag=0)
      SET validobjectcount = (validobjectcount+ 1)
      SET stat = alterlist(reply->verified_objecttype_list,validobjectcount)
      SET reply->verified_objecttype_list[validobjectcount].meaning = uar_get_code_meaning(
       objecttype_cv)
      SET reply->verified_objecttype_list[validobjectcount].display = uar_get_code_display(
       objecttype_cv)
      SET validflag = 1
     ENDIF
    ENDIF
    SET objecttype_cv = 0.0
    SET icount = (icount+ 1)
    SET cnt2 = 0
  ENDWHILE
  IF (validflag=1)
   IF (allflag=1)
    SET typequal =
    "expand(num,2,allcount, RO.OBJECT_TYPE, reply->verified_objecttype_list[num].meaning)"
   ELSE
    SET typequal = "("
    FOR (icount = 1 TO objecttypecount)
     IF (icount != 1)
      SET typequal = concat(typequal," OR")
     ENDIF
     SET typequal = concat(typequal," RO.OBJECT_TYPE = reply->verified_objecttype_list[",build(icount
       ),"].meaning")
    ENDFOR
    SET typequal = concat(typequal,")")
   ENDIF
  ELSE
   SET typequal = 'RO.OBJECT_TYPE = ""'
  ENDIF
 ENDIF
 IF ((request->bgetsections=0))
  SELECT INTO "nl:"
   ro.object_name, ro.object_description, p.username,
   ro.ccl_group, ro.object_type, ro.updt_dt_tm
   FROM ccl_report_object ro,
    prsnl p
   PLAN (ro
    WHERE ro.object_name=patstring(cnvtupper(request->object_name))
     AND parser(typequal)
     AND (ro.ccl_group >= request->ccl_group)
     AND ro.active_ind=1)
    JOIN (p
    WHERE p.person_id=ro.updt_id)
   ORDER BY ro.object_name, ro.ccl_group
   DETAIL
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(reply->object_list,(cnt+ 9))
    ENDIF
    reply->object_list[cnt].object_name = ro.object_name, reply->object_list[cnt].object_description
     = ro.object_description, reply->object_list[cnt].username = p.username,
    reply->object_list[cnt].ccl_group = ro.ccl_group, reply->object_list[cnt].object_type = ro
    .object_type, reply->object_list[cnt].updt_dt_tm = ro.updt_dt_tm
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->object_list,cnt)
 ELSE
  IF (size(request->section_type_list,5) > 0)
   SET sectionqual = "ls.section_type_ind = request->section_type_list[1].section_type_ind"
  ELSE
   SET sectionqual = "ls.section_type_ind >= 0"
  ENDIF
  SELECT INTO "nl:"
   ro.object_name, ro.object_description, p.username,
   ro.ccl_group, ro.object_type, ls.section_name,
   ro.updt_dt_tm
   FROM ccl_report_object ro,
    ccl_report_object_r ror,
    ccl_layout_section ls,
    prsnl p
   PLAN (ls
    WHERE parser(sectionqual))
    JOIN (ror
    WHERE ror.section_id=ls.section_id)
    JOIN (ro
    WHERE ro.object_id=ror.object_id
     AND ro.object_name=patstring(cnvtupper(request->object_name))
     AND parser(typequal)
     AND (ro.ccl_group >= request->ccl_group)
     AND ro.active_ind=1)
    JOIN (p
    WHERE p.person_id=ro.updt_id)
   ORDER BY ro.object_name, ro.ccl_group, ls.section_name
   HEAD ro.object_name
    row + 0
   HEAD ro.ccl_group
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(reply->object_list,(cnt+ 9))
    ENDIF
    reply->object_list[cnt].object_name = ro.object_name, reply->object_list[cnt].object_description
     = ro.object_description, reply->object_list[cnt].username = p.username,
    reply->object_list[cnt].ccl_group = ro.ccl_group, reply->object_list[cnt].object_type = ro
    .object_type, reply->object_list[cnt].updt_dt_tm = ro.updt_dt_tm,
    section_cnt = 0
   DETAIL
    section_cnt = (section_cnt+ 1)
    IF (mod(section_cnt,10)=1)
     stat = alterlist(reply->object_list[cnt].section_list,(section_cnt+ 9))
    ENDIF
    reply->object_list[cnt].section_list[section_cnt].section_name = ls.section_name
   FOOT  ro.ccl_group
    stat = alterlist(reply->object_list[cnt].section_list,section_cnt)
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->object_list,cnt)
 ENDIF
 IF (curqual=0)
  SET errcode = error(errmsg,1)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CCL_REPORT_OBJECT"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
