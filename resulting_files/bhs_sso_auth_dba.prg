CREATE PROGRAM bhs_sso_auth:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Cerner Username" = ""
  WITH outdev, s_username
 DECLARE ms_username = vc WITH protect, constant(trim(cnvtupper( $S_USERNAME)))
 DECLARE mf_phys_id = f8 WITH protect, noconstant(0.0)
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE mf_pss_grp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",357,"PEDISVSSPFLD"))
 DECLARE mf_wnerta_grp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",357,
   "WNERENALTRANSPLANT"))
 CALL echo(build2("mf_PSS_GRP_CD: ",mf_pss_grp_cd))
 CALL echo(build2("mf_WNERTA_GRP_CD: ",mf_wnerta_grp_cd))
 IF (trim(ms_username) <= " ")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM prsnl p,
   prsnl_group_reltn pgr,
   prsnl_group pg,
   dummyt d
  PLAN (p
   WHERE p.username=ms_username)
   JOIN (d)
   JOIN (pgr
   WHERE pgr.person_id=p.person_id
    AND pgr.active_ind=1)
   JOIN (pg
   WHERE pg.prsnl_group_id=pgr.prsnl_group_id
    AND pg.active_ind=1
    AND pg.prsnl_group_type_cd IN (mf_pss_grp_cd, mf_wnerta_grp_cd))
  HEAD REPORT
   ms_tmp = "<AuthenticationResponse>"
  HEAD p.person_id
   ms_tmp = concat(ms_tmp,"<ErrorMessage></ErrorMessage>"), ms_tmp = concat(ms_tmp,
    "<IsActive>Yes</IsActive>"), ms_tmp = concat(ms_tmp,"<IsAuthenticated>Yes</IsAuthenticated>"),
   ms_tmp = concat(ms_tmp,"<FirstName>",trim(p.name_first_key),"</FirstName>"), ms_tmp = concat(
    ms_tmp,"<LastName>",trim(p.name_last_key),"</LastName>"), ms_tmp = concat(ms_tmp,"<EmailAddress>",
    trim(p.email),"</EmailAddress>"),
   ms_tmp = concat(ms_tmp,"<ClinicianId>",trim(cnvtstring(p.person_id)),"</ClinicianId>"), ms_tmp =
   concat(ms_tmp,"<Facility>")
   IF (pg.prsnl_group_type_cd=mf_pss_grp_cd)
    ms_tmp = concat(ms_tmp,"PSS</Facility>")
   ELSEIF (pg.prsnl_group_type_cd=mf_wnerta_grp_cd)
    ms_tmp = concat(ms_tmp,"WNR</Facility>")
   ELSE
    ms_tmp = concat(ms_tmp,"BHS</Facility>")
   ENDIF
   ms_tmp = concat(ms_tmp,"<ClinicianIdAssigningAuth></ClinicianIdAssigningAuth>"), ms_tmp = concat(
    ms_tmp,"<Roles>"), ms_tmp = concat(ms_tmp,"<RolesItem>",trim(uar_get_code_display(p.position_cd)),
    "</RolesItem>"),
   ms_tmp = concat(ms_tmp,"</Roles>")
  FOOT REPORT
   ms_tmp = concat(ms_tmp,"</AuthenticationResponse>")
  WITH nocounter, outerjoin = d
 ;end select
 IF (((curqual < 1) OR (trim(ms_tmp) <= " ")) )
  SET ms_tmp = "<AuthenticationResponse>"
  SET ms_tmp = concat(ms_tmp,"<ErrorMessage></ErrorMessage>")
  SET ms_tmp = concat(ms_tmp,"<IsActive>No</IsActive>")
  SET ms_tmp = concat(ms_tmp,"<IsAuthenticated>No</IsAuthenticated>")
  SET ms_tmp = concat(ms_tmp,"<FirstName></FirstName>")
  SET ms_tmp = concat(ms_tmp,"<LastName></LastName>")
  SET ms_tmp = concat(ms_tmp,"<EmailAddress></EmailAddress>")
  SET ms_tmp = concat(ms_tmp,"<ClinicianId></ClinicianId>")
  SET ms_tmp = concat(ms_tmp,"<Facility></Facility>")
  SET ms_tmp = concat(ms_tmp,"<ClinicianIdAssigningAuth></ClinicianIdAssigningAuth>")
  SET ms_tmp = concat(ms_tmp,"<Roles>")
  SET ms_tmp = concat(ms_tmp,"<RolesItem></RolesItem>")
  SET ms_tmp = concat(ms_tmp,"</Roles>")
  SET ms_tmp = concat(ms_tmp,"</AuthenticationResponse>")
 ENDIF
#exit_script
 CALL echo(ms_tmp)
 SET _memory_reply_string = ms_tmp
END GO
