CREATE PROGRAM bed_get_sr_section:dba
 FREE SET reply
 RECORD reply(
   1 section_list[*]
     2 code_value = f8
     2 display = vc
     2 description = vc
     2 sub_list[*]
       3 code_value = f8
       3 display = vc
       3 description = vc
       3 multiplexor_ind = i2
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 DECLARE sparse = vc
 SET tot_sr = 0
 SET sr_count = 0
 DECLARE wcard = vc
 SET wcard = "*"
 DECLARE search_string = vc
 DECLARE sstring = vc
 IF (trim(request->search_txt) > " ")
  SET sstring = trim(cnvtalphanum(request->search_txt))
  IF ((request->search_type_flag="S"))
   SET search_string = concat(cnvtupper(sstring),wcard)
  ELSEIF ((request->search_type_flag="C"))
   SET search_string = concat(wcard,cnvtupper(sstring),wcard)
  ELSE
   SET search_string = cnvtupper(sstring)
  ENDIF
  SET search_string = replace(search_string," ","")
 ELSE
  SET search_string = wcard
 ENDIF
 CALL echo(build("search_string:",search_string))
 DECLARE section_name_parse = vc
 SET section_name_parse = concat("cv.display_key = '",search_string,"'")
 SET sparse = "ss.service_resource_cd = sub.code_value"
 IF ((request->load.multiplexor_ind != 1))
  SET sparse = concat(sparse," and ss.multiplexor_ind = 0")
 ENDIF
 SET stat = alterlist(reply->section_list,100)
 SELECT INTO "NL:"
  FROM code_value cv,
   code_value sub,
   service_resource s,
   resource_group r,
   sub_section ss
  PLAN (s
   WHERE s.active_ind=1
    AND (s.activity_type_cd=request->activity_type_code_value))
   JOIN (cv
   WHERE cv.code_value=s.service_resource_cd
    AND cv.active_ind=1
    AND cv.code_set=221
    AND cv.cdf_meaning="SECTION"
    AND parser(section_name_parse))
   JOIN (r
   WHERE r.parent_service_resource_cd=cv.code_value)
   JOIN (sub
   WHERE sub.code_value=r.child_service_resource_cd
    AND sub.active_ind=1
    AND sub.code_set=221
    AND sub.cdf_meaning="SUBSECTION")
   JOIN (ss
   WHERE parser(sparse))
  ORDER BY cv.display_key, cv.code_value, sub.display_key
  HEAD REPORT
   tot_sr = 0, sr_count = 0
  HEAD cv.code_value
   tot_sr = (tot_sr+ 1), sr_count = (sr_count+ 1)
   IF (sr_count > 100)
    stat = alterlist(reply->section_list,(tot_sr+ 100)), sr_count = 0
   ENDIF
   reply->section_list[tot_sr].code_value = cv.code_value, reply->section_list[tot_sr].display = cv
   .display, reply->section_list[tot_sr].description = cv.description,
   tot_sub_cnt = 0, sub_cnt = 0, stat = alterlist(reply->section_list[tot_sr].sub_list,50)
  DETAIL
   tot_sub_cnt = (tot_sub_cnt+ 1), sub_cnt = (sub_cnt+ 1)
   IF (sub_cnt > 50)
    stat = alterlist(reply->section_list[tot_sr].sub_list,(tot_sub_cnt+ 50)), sub_cnt = 0
   ENDIF
   reply->section_list[tot_sr].sub_list[tot_sub_cnt].code_value = sub.code_value, reply->
   section_list[tot_sr].sub_list[tot_sub_cnt].display = sub.display, reply->section_list[tot_sr].
   sub_list[tot_sub_cnt].description = sub.description,
   reply->section_list[tot_sr].sub_list[tot_sub_cnt].multiplexor_ind = ss.multiplexor_ind
  FOOT  cv.code_value
   stat = alterlist(reply->section_list[tot_sr].sub_list,tot_sub_cnt)
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->section_list,tot_sr)
#exit_script
 IF (tot_sr > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
