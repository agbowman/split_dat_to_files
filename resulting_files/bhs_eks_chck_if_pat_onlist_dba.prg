CREATE PROGRAM bhs_eks_chck_if_pat_onlist:dba
 DECLARE mf_careteam = f8 WITH constant(uar_get_code_by("DISPLAYKEY",19189,"CARETEAM")), protect
 DECLARE ml_listcodes = i4 WITH constant(357), protect
 SET retval = - (1)
 SELECT INTO "nl:"
  FROM code_value cv,
   prsnl_group pg,
   dcp_pl_custom_entry plce
  PLAN (cv
   WHERE cv.code_set=ml_listcodes
    AND cv.cdf_meaning="CARETEAM"
    AND cv.display=trim(replace(opt_param,'"',""),3))
   JOIN (pg
   WHERE pg.prsnl_group_type_cd=cv.code_value
    AND pg.prsnl_group_class_cd=mf_careteam)
   JOIN (plce
   WHERE plce.prsnl_group_id=pg.prsnl_group_id
    AND plce.person_id=trigger_personid)
  WITH nocount
 ;end select
 IF (curqual=0)
  SET retval = 0
  SET log_message = "person not on list"
 ELSEIF (curqual >= 0)
  SET retval = 100
  SET log_message = "person found on list"
 ENDIF
END GO
