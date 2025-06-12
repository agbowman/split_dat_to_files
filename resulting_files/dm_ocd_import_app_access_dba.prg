CREATE PROGRAM dm_ocd_import_app_access:dba
 DECLARE def_appgrp_cd = f8 WITH protect, noconstant(0.0)
 DECLARE position_cd = f8 WITH protect, noconstant(0.0)
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=500
   AND c.display_key="DBA"
   AND c.active_ind=1
   AND c.begin_effective_dt_tm < cnvtdatetime(curdate,curtime3)
   AND c.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
  DETAIL
   def_appgrp_cd = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=88
   AND c.display_key="DBA"
   AND c.active_ind=1
   AND c.begin_effective_dt_tm < cnvtdatetime(curdate,curtime3)
   AND c.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
  DETAIL
   position_cd = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  a.position_cd
  FROM application_group a
  WHERE a.position_cd=position_cd
   AND a.app_group_cd=def_appgrp_cd
 ;end select
 IF (curqual=0)
  INSERT  FROM application_group a
   SET a.application_group_id = cnvtint(seq(cpm_seq,nextval)), a.position_cd = position_cd, a
    .app_group_cd = def_appgrp_cd,
    a.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), a.end_effective_dt_tm = cnvtdatetime(
     "01-JAN-2099"), a.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    a.updt_id = 0, a.updt_task = reqinfo->updt_task, a.updt_applctx = 0,
    a.updt_cnt = 0
   WITH nocounter
  ;end insert
 ENDIF
 FREE RECORD apps
 RECORD apps(
   1 count = i4
   1 qual[*]
     2 number = i4
     2 exist = i2
 )
 SET stat = alterlist(apps->qual,0)
 SET apps->count = 0
 SELECT INTO "nl:"
  a.application_number
  FROM application a
  DETAIL
   apps->count = (apps->count+ 1)
   IF (mod(apps->count,100)=1)
    stat = alterlist(apps->qual,(99+ apps->count))
   ENDIF
   apps->qual[apps->count].number = a.application_number, apps->qual[apps->count].exist = 0
  FOOT REPORT
   stat = alterlist(apps->qual,apps->count)
  WITH nocounter
 ;end select
 IF ((apps->count > 0))
  SELECT INTO "nl:"
   aa.application_number
   FROM application_access aa,
    (dummyt d  WITH seq = value(apps->count))
   PLAN (d)
    JOIN (aa
    WHERE (aa.application_number=apps->qual[d.seq].number)
     AND aa.app_group_cd=def_appgrp_cd)
   DETAIL
    apps->qual[d.seq].exist = 1
   WITH nocounter
  ;end select
  INSERT  FROM application_access aa,
    (dummyt d  WITH seq = value(apps->count))
   SET aa.seq = 1, aa.application_access_id = cnvtint(seq(application_access_id_seq,nextval)), aa
    .application_number = apps->qual[d.seq].number,
    aa.app_group_cd = def_appgrp_cd, aa.updt_dt_tm = cnvtdatetime(curdate,curtime3), aa.active_dt_tm
     = cnvtdatetime(curdate,curtime3),
    aa.active_prsnl_id = 0, aa.active_ind = 1, aa.updt_id = 0,
    aa.updt_task = reqinfo->updt_task, aa.updt_applctx = 0, aa.updt_cnt = 0
   PLAN (d
    WHERE (apps->qual[d.seq].exist=0))
    JOIN (aa)
   WITH nocounter
  ;end insert
 ENDIF
 COMMIT
#exit_script
END GO
