CREATE PROGRAM ct_get_prot_type_config:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 categories[*]
      2 category_cd = f8
      2 category_disp = c40
      2 category_desc = c60
      2 category_mean = c12
      2 item_list[*]
        3 ct_prot_type_config_id = f8
        3 item_cd = f8
        3 item_disp = c40
        3 item_desc = c60
        3 item_mean = c12
        3 item_info = vc
        3 value_cd = f8
        3 value_disp = c40
        3 value_desc = c60
        3 value_mean = c12
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 IF ( NOT (validate(domain_reply)))
  RECORD domain_reply(
    1 logical_domain_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 EXECUTE ct_get_logical_domain_id  WITH replace("REPLY",domain_reply)
 DECLARE cfailed = c1 WITH noconstant("F")
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE item_cnt = i4 WITH protect, noconstant(0)
 DECLARE values_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17907,"VALUES"))
 DECLARE prev_item_cd = f8 WITH private, noconstant(0.0)
 SELECT INTO "nl:"
  FROM code_value cv,
   code_value_group cvg,
   ct_prot_type_config conf
  PLAN (cv
   WHERE cv.code_set=17905
    AND cv.active_ind=1)
   JOIN (cvg
   WHERE cvg.parent_code_value=cv.code_value)
   JOIN (conf
   WHERE (conf.item_cd= Outerjoin(cvg.child_code_value))
    AND (conf.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate)))
    AND (conf.protocol_type_cd= Outerjoin(request->protocol_type_cd)) )
  ORDER BY cv.code_value, cvg.child_code_value
  HEAD REPORT
   cnt = 0
  HEAD cv.code_value
   item_cnt = 0, prev_item_cd = 0.0, cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->categories,(cnt+ 9))
   ENDIF
   reply->categories[cnt].category_cd = cv.code_value
  DETAIL
   IF (prev_item_cd != cvg.child_code_value)
    item_cnt += 1
    IF (mod(item_cnt,10)=1)
     stat = alterlist(reply->categories[cnt].item_list,(item_cnt+ 9))
    ENDIF
    prev_item_cd = cvg.child_code_value, reply->categories[cnt].item_list[item_cnt].item_cd = cvg
    .child_code_value
   ENDIF
   IF (conf.ct_prot_type_config_id > 0.0
    AND (conf.logical_domain_id=domain_reply->logical_domain_id))
    reply->categories[cnt].item_list[item_cnt].ct_prot_type_config_id = conf.ct_prot_type_config_id,
    reply->categories[cnt].item_list[item_cnt].value_cd = conf.config_value_cd
   ENDIF
   IF (uar_get_code_meaning(cvg.child_code_value)="CUSTOMFIELDS")
    reply->categories[cnt].item_list[item_cnt].value_cd = values_cd
   ENDIF
  FOOT  cv.code_value
   stat = alterlist(reply->categories[cnt].item_list,item_cnt)
  FOOT REPORT
   stat = alterlist(reply->categories,cnt)
  WITH nocounter
 ;end select
#exit_script
 IF (cfailed="T")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET last_mod = "001"
 SET mod_date = "May 30, 2019"
END GO
