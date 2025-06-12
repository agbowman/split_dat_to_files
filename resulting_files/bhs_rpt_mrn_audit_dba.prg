CREATE PROGRAM bhs_rpt_mrn_audit:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 IF ( NOT (validate(reply->status_data.status,0)))
  RECORD reply(
    1 ops_event = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE mf_ssnpersonaliastype_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"SSN"))
 DECLARE mf_mrnpersonaliastype_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"MRN"))
 DECLARE mf_bmcmrnaliaspool_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",263,"BMCMRN")
  )
 DECLARE mf_bnhmrnaliaspool_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",263,"BNHMRN")
  )
 DECLARE mf_fmcmrnaliaspool_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",263,"FMCMRN")
  )
 DECLARE mf_mlhmrnaliaspool_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",263,"MLHMRN")
  )
 DECLARE mn_email_ind = i2 WITH protect, noconstant(0)
 DECLARE ms_message_file = vc WITH protect, noconstant(" ")
 DECLARE ms_address_list = vc WITH protect, noconstant(" ")
 DECLARE ms_body = vc WITH protect, noconstant(" ")
 DECLARE ms_subject = vc WITH protect, noconstant(" ")
 DECLARE ms_outdest = vc WITH protect, noconstant(" ")
 DECLARE ms_filename = vc WITH protect, noconstant(" ")
 DECLARE md_run_dt_tm = dq8 WITH protect
 SET md_run_dt_tm = cnvtdatetime(curdate,curtime)
 IF (((findstring("@", $OUTDEV) > 0) OR (( $OUTDEV="OPS"))) )
  SET ms_filename = concat("missing_mrn_audit_",format(cnvtdatetime(md_run_dt_tm),"yyyymmdd;;D"),
   ".csv")
  SET mn_email_ind = 1
  SET ms_outdest = ms_filename
  SET ms_address_list =  $OUTDEV
 ELSE
  SET ms_outdest =  $OUTDEV
 ENDIF
 SELECT
  IF (mn_email_ind=1)
   WITH format, format = stream, pcformat('"',",",1),
    nocounter
  ELSE
  ENDIF
  INTO value(ms_outdest)
  p.person_id, p.name_full_formatted, dob = format(p.birth_dt_tm,"mm/dd/yyyy;;D"),
  ssn = cnvtalias(ssn.alias,ssn.alias_pool_cd), bmcmrn = bmcmrn.alias, bnhmrn = bnhmrn.alias,
  fmcmrn = fmcmrn.alias, mlhmrn = mlhmrn.alias
  FROM person p,
   person_alias ssn,
   person_alias bmcmrn,
   person_alias bnhmrn,
   person_alias fmcmrn,
   person_alias mlhmrn
  PLAN (p
   WHERE p.active_ind=1
    AND  EXISTS (
   (SELECT
    e.person_id
    FROM encounter e
    WHERE e.person_id=p.person_id))
    AND (( NOT ( EXISTS (
   (SELECT
    bmcmrn0.person_id
    FROM person_alias bmcmrn0
    WHERE bmcmrn0.person_id=p.person_id
     AND bmcmrn0.person_alias_type_cd=mf_mrnpersonaliastype_cd
     AND bmcmrn0.alias_pool_cd=mf_bmcmrnaliaspool_cd
     AND bmcmrn0.active_ind=1
     AND bmcmrn0.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))))) OR ((( NOT ( EXISTS (
   (SELECT
    bnhmrn0.person_id
    FROM person_alias bnhmrn0
    WHERE bnhmrn0.person_id=p.person_id
     AND bnhmrn0.person_alias_type_cd=mf_mrnpersonaliastype_cd
     AND bnhmrn0.alias_pool_cd=mf_bnhmrnaliaspool_cd
     AND bnhmrn0.active_ind=1
     AND bnhmrn0.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))))) OR ((( NOT ( EXISTS (
   (SELECT
    fmcmrn0.person_id
    FROM person_alias fmcmrn0
    WHERE fmcmrn0.person_id=p.person_id
     AND fmcmrn0.person_alias_type_cd=mf_mrnpersonaliastype_cd
     AND fmcmrn0.alias_pool_cd=mf_fmcmrnaliaspool_cd
     AND fmcmrn0.active_ind=1
     AND fmcmrn0.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))))) OR ( NOT ( EXISTS (
   (SELECT
    mlhmrn0.person_id
    FROM person_alias mlhmrn0
    WHERE mlhmrn0.person_id=p.person_id
     AND mlhmrn0.person_alias_type_cd=mf_mrnpersonaliastype_cd
     AND mlhmrn0.alias_pool_cd=mf_mlhmrnaliaspool_cd
     AND mlhmrn0.active_ind=1
     AND mlhmrn0.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")))))) )) )) )
   JOIN (ssn
   WHERE (ssn.person_id= Outerjoin(p.person_id))
    AND (ssn.person_alias_type_cd= Outerjoin(mf_ssnpersonaliastype_cd))
    AND (ssn.active_ind= Outerjoin(1))
    AND (ssn.end_effective_dt_tm= Outerjoin(cnvtdatetime("31-DEC-2100 00:00:00"))) )
   JOIN (bmcmrn
   WHERE (bmcmrn.person_id= Outerjoin(p.person_id))
    AND (bmcmrn.person_alias_type_cd= Outerjoin(mf_mrnpersonaliastype_cd))
    AND (bmcmrn.alias_pool_cd= Outerjoin(mf_bmcmrnaliaspool_cd))
    AND (bmcmrn.active_ind= Outerjoin(1))
    AND (bmcmrn.end_effective_dt_tm= Outerjoin(cnvtdatetime("31-DEC-2100 00:00:00"))) )
   JOIN (bnhmrn
   WHERE (bnhmrn.person_id= Outerjoin(p.person_id))
    AND (bnhmrn.person_alias_type_cd= Outerjoin(mf_mrnpersonaliastype_cd))
    AND (bnhmrn.alias_pool_cd= Outerjoin(mf_bnhmrnaliaspool_cd))
    AND (bnhmrn.active_ind= Outerjoin(1))
    AND (bnhmrn.end_effective_dt_tm= Outerjoin(cnvtdatetime("31-DEC-2100 00:00:00"))) )
   JOIN (fmcmrn
   WHERE (fmcmrn.person_id= Outerjoin(p.person_id))
    AND (fmcmrn.person_alias_type_cd= Outerjoin(mf_mrnpersonaliastype_cd))
    AND (fmcmrn.alias_pool_cd= Outerjoin(mf_fmcmrnaliaspool_cd))
    AND (fmcmrn.active_ind= Outerjoin(1))
    AND (fmcmrn.end_effective_dt_tm= Outerjoin(cnvtdatetime("31-DEC-2100 00:00:00"))) )
   JOIN (mlhmrn
   WHERE (mlhmrn.person_id= Outerjoin(p.person_id))
    AND (mlhmrn.person_alias_type_cd= Outerjoin(mf_mrnpersonaliastype_cd))
    AND (mlhmrn.alias_pool_cd= Outerjoin(mf_mlhmrnaliaspool_cd))
    AND (mlhmrn.active_ind= Outerjoin(1))
    AND (mlhmrn.end_effective_dt_tm= Outerjoin(cnvtdatetime("31-DEC-2100 00:00:00"))) )
  ORDER BY p.name_full_formatted
  WITH format, separator = " ", nocounter
 ;end select
 IF (mn_email_ind=1)
  IF (( $OUTDEV="OPS"))
   SELECT INTO "nl:"
    FROM dm_info di
    PLAN (di
     WHERE di.info_domain="BHS_RPT_MRN_AUDIT"
      AND di.info_char="EMAIL")
    HEAD REPORT
     ms_address_list = " "
    DETAIL
     IF (ms_address_list=" ")
      ms_address_list = trim(di.info_name)
     ELSE
      ms_address_list = concat(ms_address_list," ",trim(di.info_name))
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
  EXECUTE bhs_ma_email_file
  SET ms_subject = concat("Missing MRN Audit for ",format(cnvtdatetime(md_run_dt_tm),"mm/dd/yyyy;;D")
   )
  CALL emailfile(ms_filename,ms_filename,ms_address_list,ms_subject,0)
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 SET reply->ops_event = "Ops Job completed successfully"
 SET reply->status_data.subeventstatus[1].operationstatus = "S"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "Ops Job completed successfully"
 SET reply->status_data.subeventstatus[1].targetobjectname = ""
END GO
