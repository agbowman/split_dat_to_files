CREATE PROGRAM ams_decentralized_security
 FREE RECORD users
 RECORD users(
   1 list[*]
     2 person = f8
 )
 EXECUTE ams_define_toolkit_common
 DECLARE inactive_var = f8 WITH constant(uar_get_code_by("MEANING",48,"INACTIVE")), protect
 DECLARE active_var = f8 WITH constant(uar_get_code_by("MEANING",48,"ACTIVE")), protect
 DECLARE script_name = vc WITH protect, constant("AMS_DECENTRALIZED_SECURITY")
 SELECT DISTINCT INTO "nl:"
  p.person_id, status = uar_get_code_display(p.active_status_cd), p.username,
  p.name_last, p.name_first, p.create_dt_tm,
  p.active_status_dt_tm, pn.name_title, position = uar_get_code_display(p.position_cd),
  p.email
  FROM prsnl p,
   person_name pn
  PLAN (p
   WHERE p.active_status_cd=active_var)
   JOIN (pn
   WHERE p.person_id=pn.person_id
    AND pn.name_title IN ("Cerner AMS", "Cerner IRC", "Cerner CommWx"))
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
   SELECT INTO "nl:"
    p.prsnl_id
    FROM prsnl_priv p
    WHERE p.name="AMS Support"
     AND (p.prsnl_id=users->list[x].person)
   ;end select
   IF (curqual=0)
    INSERT  FROM prsnl_priv
     SET prsnl_priv_id = seq(patient_privacy_seq,nextval), prsnl_id = users->list[x].person, name =
      "AMS Support",
      active_ind = 1, active_status_cd = active_var, active_status_dt_tm = cnvtdatetime(curdate,
       curtime),
      beg_effective_dt_tm = cnvtdatetime(curdate,curtime), end_effective_dt_tm = cnvtdatetime(
       "31-DEC-2100 00:00:00"), super_user_ind = 1,
      updt_applctx = 9999, updt_dt_tm = cnvtdatetime(curdate,curtime), updt_task = 9999
    ;end insert
   ENDIF
   IF (mod(x,100)=0)
    COMMIT
   ENDIF
 ENDFOR
 CALL updtdminfo(script_name)
 COMMIT
END GO
