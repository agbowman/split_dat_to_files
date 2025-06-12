CREATE PROGRAM ams_secure_accts
 FREE RECORD users
 RECORD users(
   1 list[*]
     2 person = f8
 )
 EXECUTE ams_define_toolkit_common
 DECLARE inactive_var = f8 WITH constant(uar_get_code_by("MEANING",48,"INACTIVE")), protect
 DECLARE suspend_var = f8 WITH constant(uar_get_code_by("MEANING",48,"SUSPENDED")), protect
 DECLARE active_var = f8 WITH constant(uar_get_code_by("MEANING",48,"ACTIVE")), protect
 DECLARE script_name = vc WITH protect, constant("AMS_SECURE_ACCTS")
 SELECT DISTINCT INTO "nl:"
  p.person_id, status = uar_get_code_display(p.active_status_cd), p.username,
  p.name_last, p.name_first, p.create_dt_tm,
  p.active_status_dt_tm, e.password_change_dt_tm, pn.name_title,
  position = uar_get_code_display(p.position_cd), p.email, ea.attribute_name,
  eu.updt_dt_tm"@SHORTDATETIME"
  FROM prsnl p,
   person_name pn,
   ea_user e,
   ea_user_attribute_reltn eu,
   ea_attribute ea
  PLAN (p
   WHERE p.active_status_cd=active_var)
   JOIN (pn
   WHERE p.person_id=pn.person_id
    AND pn.name_title IN ("Cerner AMS", "Cerner IRC"))
   JOIN (e
   WHERE p.username=e.username)
   JOIN (eu
   WHERE eu.ea_user_id=e.ea_user_id
    AND (eu.ea_attribute_id=
   (SELECT
    ea.ea_attribute_id
    FROM ea_attribute
    WHERE ea.attribute_name="CHANGEPASSWORD"))
    AND eu.updt_dt_tm <= cnvtdatetime((curdate - 14),curtime3))
   JOIN (ea
   WHERE ea.ea_attribute_id=eu.ea_attribute_id
    AND ea.attribute_name="CHANGEPASSWORD")
  HEAD REPORT
   cnt = 0, stat = alterlist(users->list,10)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1
    AND cnt != 1)
    stat = alterlist(users->list,(cnt+ 9))
   ENDIF
   users->list[cnt].person = p.person_id
  FOOT REPORT
   stat = alterlist(users->list,cnt)
  WITH nocounter
 ;end select
 SET rec_size = size(users->list,5)
 FOR (x = 1 TO value(rec_size))
  UPDATE  FROM prsnl p
   SET p.active_ind = 1, p.active_status_cd = suspend_var, p.updt_dt_tm = cnvtdatetime(curdate,
     curtime3),
    p.updt_cnt = (p.updt_cnt+ 1), p.active_status_dt_tm = cnvtdatetime(curdate,curtime3), p
    .end_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   WHERE (p.person_id=users->list[x].person)
  ;end update
  IF (mod(x,100)=0)
   COMMIT
  ENDIF
 ENDFOR
 CALL updtdminfo(script_name)
 COMMIT
END GO
