CREATE PROGRAM bhs_eks_tobacco_use:dba
 DECLARE mf_active = f8 WITH constant(uar_get_code_by("MEANING",4002172,"ACTIVE")), protect
 DECLARE mf_tobaccouse = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14003,"SHXTOBACCOUSE")),
 protect
 SET retval = 0
 SELECT INTO "nl:"
  sa.shx_activity_id
  FROM shx_activity sa,
   shx_response sr,
   shx_alpha_response sar
  PLAN (sa
   WHERE sa.person_id=trigger_personid
    AND sa.active_ind=1
    AND sa.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND sa.status_cd=mf_active)
   JOIN (sr
   WHERE sr.shx_activity_id=sa.shx_activity_id
    AND sr.active_ind=1
    AND sr.task_assay_cd=mf_tobaccouse)
   JOIN (sar
   WHERE sar.shx_response_id=sr.shx_response_id
    AND sar.nomenclature_id > 0)
  DETAIL
   retval = 100
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET retval = 0
 ENDIF
END GO
