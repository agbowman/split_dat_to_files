CREATE PROGRAM ct_get_custom_fields:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 groups[*]
      2 group_cd = f8
      2 group_mean = c12
      2 group_desc = vc
      2 group_disp = vc
      2 reltns[*]
        3 ct_custom_fld_grp_rel_id = f8
        3 group_cd = f8
        3 field_key = vc
    1 fields[*]
      2 ct_custom_field_id = f8
      2 field_label = vc
      2 field_type_cd = f8
      2 field_type_disp = vc
      2 field_type_desc = vc
      2 field_type_mean = c12
      2 field_key = vc
      2 code_set = i4
      2 upt_cnt = i4
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
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE grp_cnt = i4 WITH protect, noconstant(0)
 DECLARE reltn_cnt = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM ct_custom_field cf
  PLAN (cf
   WHERE cf.active_ind=1
    AND (cf.logical_domain_id=domain_reply->logical_domain_id))
  ORDER BY cf.field_label
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->fields,(cnt+ 9))
   ENDIF
   reply->fields[cnt].ct_custom_field_id = cf.ct_custom_field_id, reply->fields[cnt].field_type_cd =
   cf.field_type_cd, reply->fields[cnt].field_label = cf.field_label,
   reply->fields[cnt].field_key = cf.field_key, reply->fields[cnt].code_set = cf.code_set, reply->
   fields[cnt].upt_cnt = cf.updt_cnt
  FOOT REPORT
   stat = alterlist(reply->fields,cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv,
   ct_custom_field_group_reltn cfgr
  PLAN (cv
   WHERE cv.code_set=17911
    AND cv.active_ind=1)
   JOIN (cfgr
   WHERE (cfgr.group_cd= Outerjoin(cv.code_value))
    AND (cfgr.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
  HEAD REPORT
   grp_cnt = 0
  HEAD cv.code_value
   grp_cnt += 1
   IF (mod(grp_cnt,10)=1)
    stat = alterlist(reply->groups,(grp_cnt+ 9))
   ENDIF
   reply->groups[grp_cnt].group_cd = cv.code_value, reply->groups[grp_cnt].group_disp = cv.display,
   reply->groups[grp_cnt].group_desc = cv.description,
   reply->groups[grp_cnt].group_mean = cv.cdf_meaning, reltn_cnt = 0
  HEAD cfgr.ct_custom_fld_grp_rel_id
   IF (cfgr.ct_custom_fld_grp_rel_id > 0.0
    AND (cfgr.logical_domain_id=domain_reply->logical_domain_id))
    reltn_cnt += 1
    IF (mod(reltn_cnt,10)=1)
     stat = alterlist(reply->groups[grp_cnt].reltns,(reltn_cnt+ 9))
    ENDIF
    reply->groups[grp_cnt].reltns[reltn_cnt].ct_custom_fld_grp_rel_id = cfgr.ct_custom_fld_grp_rel_id,
    reply->groups[grp_cnt].reltns[reltn_cnt].group_cd = cfgr.group_cd, reply->groups[grp_cnt].reltns[
    reltn_cnt].field_key = cfgr.field_key
   ENDIF
  FOOT  cv.code_value
   stat = alterlist(reply->groups[grp_cnt].reltns,reltn_cnt)
  FOOT REPORT
   stat = alterlist(reply->groups,grp_cnt)
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
 SET last_mod = "001"
 SET mod_date = "February 27, 2019"
END GO
