CREATE PROGRAM bed_aud_pft_prsnl_errors:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 paramlist[*]
      2 param_type_mean = vc
      2 pdate1 = dq8
      2 pdate2 = dq8
      2 vlist[*]
        3 dbl_value = f8
        3 string_value = vc
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 collist[*]
      2 header_text = vc
      2 data_type = i2
      2 hide_ind = i2
    1 rowlist[*]
      2 celllist[*]
        3 date_value = dq8
        3 nbr_value = i4
        3 double_value = f8
        3 string_value = vc
        3 display_flag = i2
    1 high_volume_flag = i2
    1 output_filename = vc
    1 run_status_flag = i2
    1 statlist[*]
      2 statistic_meaning = vc
      2 status_flag = i2
      2 qualifying_items = i4
      2 total_items = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 SET fac_cd = get_code_value(278,"FACILITY")
 SET client_cd = get_code_value(278,"CLIENT")
 SET auth_cd = get_code_value(8,"AUTH")
 SET npi_cd = get_code_value(320,"NPI")
 SET upin_cd = get_code_value(320,"DOCUPIN")
 SET license_cd = get_code_value(320,"LICENSENBR")
 SET provider_cd = get_code_value(320,"PROVIDER NUM")
 SET missing_npi = 0
 SET missing_upin = 0
 SET missing_license = 0
 SET missing_provider = 0
 SET total_phys = 0
 SET skip_upin = "Y"
 SET skip_license = "Y"
 SET high_volume_cnt = 0
 CALL echo(high_volume_cnt)
 IF ((request->skip_volume_check_ind=0))
  IF (high_volume_cnt > 30000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 25000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO "NL:"
  FROM org_alias_pool_reltn oa,
   organization o,
   org_type_reltn ot1,
   org_type_reltn ot2
  PLAN (oa
   WHERE oa.alias_entity_alias_type_cd=license_cd
    AND oa.alias_entity_name="PRSNL_ALIAS"
    AND oa.active_ind=1)
   JOIN (o
   WHERE o.organization_id=oa.organization_id
    AND o.active_ind=1)
   JOIN (ot1
   WHERE ot1.organization_id=o.organization_id
    AND ot1.active_ind=1
    AND ot1.org_type_cd=client_cd)
   JOIN (ot2
   WHERE ot2.organization_id=o.organization_id
    AND ot2.active_ind=1
    AND ot2.org_type_cd=fac_cd)
  DETAIL
   skip_license = "N"
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM org_alias_pool_reltn oa,
   organization o,
   org_type_reltn ot1,
   org_type_reltn ot2
  PLAN (oa
   WHERE oa.alias_entity_alias_type_cd=upin_cd
    AND oa.alias_entity_name="PRSNL_ALIAS"
    AND oa.active_ind=1)
   JOIN (o
   WHERE o.organization_id=oa.organization_id
    AND o.active_ind=1)
   JOIN (ot1
   WHERE ot1.organization_id=o.organization_id
    AND ot1.active_ind=1
    AND ot1.org_type_cd=client_cd)
   JOIN (ot2
   WHERE ot2.organization_id=o.organization_id
    AND ot2.active_ind=1
    AND ot2.org_type_cd=fac_cd)
  DETAIL
   skip_upin = "N"
  WITH nocounter
 ;end select
 SET orow = 0
 IF (skip_upin="N")
  IF (skip_license="N")
   SET stat = alterlist(reply->collist,6)
  ELSE
   SET stat = alterlist(reply->collist,5)
  ENDIF
 ELSE
  IF (skip_license="N")
   SET stat = alterlist(reply->collist,5)
  ELSE
   SET stat = alterlist(reply->collist,4)
  ENDIF
 ENDIF
 SET reply->collist[1].header_text = "Person ID"
 SET reply->collist[1].data_type = 2
 SET reply->collist[1].hide_ind = 1
 SET reply->collist[2].header_text = "Name Full Formatted"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Missing Provider Nbr"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Missing NPI Nbr"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 IF (skip_upin="N")
  SET reply->collist[5].header_text = "Missing UPIN"
  SET reply->collist[5].data_type = 1
  SET reply->collist[5].hide_ind = 0
 ENDIF
 IF (skip_license="N")
  IF (skip_upin="N")
   SET reply->collist[6].header_text = "Missing State License Nbr"
   SET reply->collist[6].data_type = 1
   SET reply->collist[6].hide_ind = 0
  ELSE
   SET reply->collist[5].header_text = "Missing State License Nbr"
   SET reply->collist[5].data_type = 1
   SET reply->collist[5].hide_ind = 0
  ENDIF
 ENDIF
 SET orow = 0
 SELECT INTO "NL:"
  nff = cnvtupper(p.name_full_formatted), p.person_id
  FROM prsnl p,
   prsnl_alias pa
  PLAN (p
   WHERE p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
    AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime)
    AND p.physician_ind=1
    AND p.data_status_cd=auth_cd)
   JOIN (pa
   WHERE pa.person_id=outerjoin(p.person_id)
    AND pa.active_ind=outerjoin(1))
  ORDER BY nff, p.person_id
  HEAD REPORT
   orow = 0
  HEAD p.person_id
   npi_ind = 0, upin_ind = 0, license_ind = 0,
   provider_ind = 0
   IF (skip_upin="Y")
    upin_ind = 1
   ENDIF
   IF (skip_license="Y")
    license_ind = 1
   ENDIF
  DETAIL
   IF (pa.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
    AND pa.end_effective_dt_tm >= cnvtdatetime(curdate,curtime))
    IF (pa.prsnl_alias_type_cd=npi_cd)
     npi_ind = 1
    ELSEIF (pa.prsnl_alias_type_cd=upin_cd)
     upin_ind = 1
    ELSEIF (pa.prsnl_alias_type_cd=license_cd)
     license_ind = 1
    ELSEIF (pa.prsnl_alias_type_cd=provider_cd)
     provider_ind = 1
    ENDIF
   ENDIF
  FOOT  p.person_id
   total_phys = (total_phys+ 1)
   IF (((upin_ind=0) OR (((npi_ind=0) OR (((provider_ind=0) OR (license_ind=0)) )) )) )
    orow = (orow+ 1), stat = alterlist(reply->rowlist,orow)
    IF (skip_upin="N")
     IF (skip_license="N")
      stat = alterlist(reply->rowlist[orow].celllist,6)
     ELSE
      stat = alterlist(reply->rowlist[orow].celllist,5)
     ENDIF
    ELSE
     IF (skip_license="N")
      stat = alterlist(reply->rowlist[orow].celllist,5)
     ELSE
      stat = alterlist(reply->rowlist[orow].celllist,4)
     ENDIF
    ENDIF
    reply->rowlist[orow].celllist[1].double_value = p.person_id, reply->rowlist[orow].celllist[2].
    string_value = p.name_full_formatted
    IF (provider_ind=0)
     reply->rowlist[orow].celllist[3].string_value = "X", missing_provider = (missing_provider+ 1)
    ELSE
     reply->rowlist[orow].celllist[3].string_value = " "
    ENDIF
    IF (npi_ind=0)
     reply->rowlist[orow].celllist[4].string_value = "X", missing_npi = (missing_npi+ 1)
    ELSE
     reply->rowlist[orow].celllist[4].string_value = " "
    ENDIF
    IF (upin_ind=0
     AND skip_upin="N")
     reply->rowlist[orow].celllist[5].string_value = "X", missing_upin = (missing_upin+ 1)
    ENDIF
    IF (license_ind=0
     AND skip_license="N")
     missing_license = (missing_license+ 1)
     IF (skip_upin="N")
      reply->rowlist[orow].celllist[6].string_value = "X"
     ELSE
      reply->rowlist[orow].celllist[5].string_value = "X"
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (total_phys > 0)
  IF (missing_npi=0
   AND missing_upin=0
   AND missing_license=0
   AND missing_provider=0)
   SET reply->run_status_flag = 1
  ELSE
   SET reply->run_status_flag = 3
  ENDIF
 ENDIF
 IF (skip_upin="Y")
  IF (skip_license="Y")
   SET stat = alterlist(reply->statlist,2)
  ELSE
   SET stat = alterlist(reply->statlist,3)
  ENDIF
 ELSE
  IF (skip_license="Y")
   SET stat = alterlist(reply->statlist,3)
  ELSE
   SET stat = alterlist(reply->statlist,4)
  ENDIF
 ENDIF
 SET reply->statlist[1].statistic_meaning = "MISSINGNPI"
 SET reply->statlist[1].total_items = total_phys
 SET reply->statlist[1].qualifying_items = missing_npi
 IF (total_phys > 0)
  IF (missing_npi=0)
   SET reply->statlist[1].status_flag = 1
  ELSE
   SET reply->statlist[1].status_flag = 3
  ENDIF
 ELSE
  SET reply->statlist[1].status_flag = 0
 ENDIF
 SET reply->statlist[2].statistic_meaning = "MISSINGPROVIDERNBR"
 SET reply->statlist[2].total_items = total_phys
 SET reply->statlist[2].qualifying_items = missing_provider
 IF (total_phys > 0)
  IF (missing_provider=0)
   SET reply->statlist[2].status_flag = 1
  ELSE
   SET reply->statlist[2].status_flag = 3
  ENDIF
 ELSE
  SET reply->statlist[2].status_flag = 0
 ENDIF
 IF (skip_upin="N")
  SET reply->statlist[3].statistic_meaning = "MISSINGUPIN"
  SET reply->statlist[3].total_items = total_phys
  SET reply->statlist[3].qualifying_items = missing_upin
  IF (total_phys > 0)
   IF (missing_upin=0)
    SET reply->statlist[3].status_flag = 1
   ELSE
    SET reply->statlist[3].status_flag = 3
   ENDIF
  ELSE
   SET reply->statlist[3].status_flag = 0
  ENDIF
 ENDIF
 IF (skip_license="N")
  IF (skip_upin="N")
   SET reply->statlist[4].statistic_meaning = "MISSINGLICENSENBR"
   SET reply->statlist[4].total_items = total_phys
   SET reply->statlist[4].qualifying_items = missing_license
   IF (total_phys > 0)
    IF (missing_license=0)
     SET reply->statlist[4].status_flag = 1
    ELSE
     SET reply->statlist[4].status_flag = 3
    ENDIF
   ELSE
    SET reply->statlist[4].status_flag = 0
   ENDIF
  ELSE
   SET reply->statlist[3].statistic_meaning = "MISSINGLICENSENBR"
   SET reply->statlist[3].total_items = total_phys
   SET reply->statlist[3].qualifying_items = missing_license
   IF (total_phys > 0)
    IF (missing_license=0)
     SET reply->statlist[3].status_flag = 1
    ELSE
     SET reply->statlist[3].status_flag = 3
    ENDIF
   ELSE
    SET reply->statlist[3].status_flag = 0
   ENDIF
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 SUBROUTINE get_code_value(xcodeset,xcdf)
   SET to_return = 0.0
   SELECT INTO "nl:"
    FROM code_value c
    PLAN (c
     WHERE c.code_set=xcodeset
      AND c.cdf_meaning=xcdf
      AND c.active_ind=1)
    DETAIL
     to_return = c.code_value
    WITH nocounter
   ;end select
   RETURN(to_return)
 END ;Subroutine
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("pft_prsnl_errors_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
