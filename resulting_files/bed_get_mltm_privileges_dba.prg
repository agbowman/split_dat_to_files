CREATE PROGRAM bed_get_mltm_privileges:dba
 FREE SET reply
 RECORD reply(
   1 priv_mean
     2 code_value = f8
     2 display = vc
   1 privileges[*]
     2 privilege_id = f8
     2 priv_value
       3 code_value = f8
       3 display = vc
       3 mean = vc
     2 position
       3 code_value = f8
       3 display = vc
     2 exceptions[*]
       3 code_value = f8
       3 display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE parse_privilege = vc
 DECLARE parse_priv_loc_reltn = vc
 SET reply->status_data.status = "F"
 SET pharmacy_code_value = 0.0
 SET position_code_value = 0.0
 SET priv_value_code_value = 0.0
 SET exception_type_code_value = 0.0
 SET individual_type_code_value = 0.0
 SET cnt = 0
 SET sub_cnt = 0
 SET list_cnt = 0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.cdf_meaning="PHARMACY"
   AND cv.code_set=6000
   AND cv.active_ind=1
  DETAIL
   pharmacy_code_value = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.cdf_meaning="ORDERABLES"
   AND cv.code_set=6015
   AND cv.active_ind=1
  DETAIL
   exception_type_code_value = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.cdf_meaning="INDIVIDUAL"
   AND cv.code_set=6019
   AND cv.active_ind=1
  DETAIL
   individual_type_code_value = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE (cv.cdf_meaning=request->priv_mean)
   AND cv.code_set=6016
   AND cv.active_ind=1
  DETAIL
   reply->priv_mean.code_value = cv.code_value, reply->priv_mean.display = cv.display
  WITH nocounter
 ;end select
 IF ((request->position_mean > " "))
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE (cv.cdf_meaning=request->position_mean)
    AND cv.code_set=88
    AND cv.active_ind=1
   DETAIL
    position_code_value = cv.code_value
   WITH nocounter
  ;end select
  SET parse_priv_loc_reltn = build("plr.position_cd = ",position_code_value," and plr.active_ind = 1"
   )
 ELSE
  SET parse_priv_loc_reltn = "plr.active_ind = 1"
 ENDIF
 IF ((request->priv_value_mean > " "))
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE (cv.cdf_meaning=request->priv_value_mean)
    AND cv.code_set=6017
    AND cv.active_ind=1
   DETAIL
    priv_value_code_value = cv.code_value
   WITH nocounter
  ;end select
  SET parse_privilege = build("p.priv_value_cd = ",priv_value_code_value," and p.active_ind = 1")
 ELSE
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE cv.code_set=6017
    AND cv.cdf_meaning IN ("INCLUDE", "EXCLUDE")
    AND cv.active_ind=1
   HEAD REPORT
    comma_flag = 0
   DETAIL
    IF (comma_flag=0)
     parse_privilege = build("p.priv_value_cd IN ( ",cv.code_value)
    ELSE
     parse_privilege = build(parse_privilege,", ",cv.code_value)
    ENDIF
    comma_flag = 1
  ;end select
  SET parse_privilege = concat(parse_privilege,") and p.active_ind = 1")
 ENDIF
 SELECT INTO "nl:"
  FROM privilege p,
   priv_loc_reltn plr,
   privilege_exception pe,
   order_catalog oc,
   code_value cv
  PLAN (p
   WHERE (p.privilege_cd=reply->priv_mean.code_value)
    AND parser(parse_privilege))
   JOIN (plr
   WHERE plr.priv_loc_reltn_id=p.priv_loc_reltn_id
    AND plr.position_cd > 0
    AND parser(parse_priv_loc_reltn))
   JOIN (pe
   WHERE pe.privilege_id=p.privilege_id
    AND ((pe.exception_type_cd=exception_type_code_value) OR (pe.exception_type_cd=
   individual_type_code_value))
    AND pe.exception_entity_name="ORDER CATALOG")
   JOIN (cv
   WHERE cv.code_value=plr.position_cd
    AND cv.active_ind=1)
   JOIN (oc
   WHERE oc.catalog_cd=pe.exception_id
    AND oc.catalog_type_cd=pharmacy_code_value)
  ORDER BY p.privilege_id
  HEAD REPORT
   cnt = 0
  HEAD p.privilege_id
   cnt = (cnt+ 1), sub_cnt = 0
   IF (mod(cnt,100)=1)
    stat = alterlist(reply->privileges,(cnt+ 99))
   ENDIF
   reply->privileges[cnt].privilege_id = p.privilege_id, reply->privileges[cnt].position.code_value
    = plr.position_cd, reply->privileges[cnt].priv_value.code_value = p.priv_value_cd,
   reply->privileges[cnt].position.display = cv.display
  DETAIL
   sub_cnt = (sub_cnt+ 1)
   IF (mod(sub_cnt,100)=1)
    stat = alterlist(reply->privileges[cnt].exceptions,(sub_cnt+ 99))
   ENDIF
   reply->privileges[cnt].exceptions[sub_cnt].code_value = pe.exception_id
  FOOT  p.privilege_id
   stat = alterlist(reply->privileges[cnt].exceptions,sub_cnt)
  FOOT REPORT
   stat = alterlist(reply->privileges,cnt)
  WITH counter
 ;end select
 IF (cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = cnt),
    code_value cv
   PLAN (d)
    JOIN (cv
    WHERE (cv.code_value=reply->privileges[d.seq].priv_value.code_value))
   DETAIL
    reply->privileges[d.seq].priv_value.display = cv.display, reply->privileges[d.seq].priv_value.
    mean = cv.cdf_meaning
   WITH nocounter
  ;end select
  FOR (x = 1 TO cnt)
   SET list_cnt = size(reply->privileges[x].exceptions,5)
   IF (list_cnt > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = list_cnt),
      code_value cv
     PLAN (d)
      JOIN (cv
      WHERE (cv.code_value=reply->privileges[x].exceptions[d.seq].code_value))
     DETAIL
      reply->privileges[x].exceptions[d.seq].display = cv.display
     WITH nocounter
    ;end select
   ENDIF
  ENDFOR
 ENDIF
#exit_script
 IF (cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
