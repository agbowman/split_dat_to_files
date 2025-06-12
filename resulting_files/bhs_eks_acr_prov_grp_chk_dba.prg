CREATE PROGRAM bhs_eks_acr_prov_grp_chk:dba
 DECLARE mf_provider_group_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",19189,
   "PROVIDERGROUP"))
 DECLARE ms_group_name_key = vc WITH protect, constant("ACR PILOT")
 DECLARE ml_qual_ind = i2 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM prsnl_group pg,
   prsnl_group_reltn pgr,
   prsnl p
  PLAN (pg
   WHERE pg.active_ind=1
    AND pg.prsnl_group_class_cd=mf_provider_group_cd
    AND pg.prsnl_group_name_key=ms_group_name_key)
   JOIN (pgr
   WHERE pgr.active_ind=1
    AND pg.prsnl_group_id=pgr.prsnl_group_id)
   JOIN (p
   WHERE p.active_ind=1
    AND pgr.person_id=p.person_id
    AND (p.person_id=reqinfo->updt_id))
  DETAIL
   ml_qual_ind = 1
  WITH nocounter
 ;end select
 IF (ml_qual_ind > 0)
  SET retval = 100
  SET log_message = build2("Provider found: ",reqinfo->updt_id)
 ELSE
  SET retval = 0
  SET log_message = build2("Provider NOT found in ACR Pilot provider group: ",reqinfo->updt_id)
 ENDIF
 CALL echo("***")
 CALL echo(log_message)
END GO
