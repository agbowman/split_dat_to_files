CREATE PROGRAM bed_get_prsnl_specialty_reltn:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 providers[*]
      2 prsnl_id = f8
      2 prsnl_name_full_formatted = vc
      2 specialties[*]
        3 specialty_cd = f8
        3 primary_ind = i2
        3 specific_locations[*]
          4 location_cd = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE fail = i2 WITH protect, constant(0)
 DECLARE success = i2 WITH protect, constant(1)
 DECLARE nodata = i2 WITH protect, constant(2)
 DECLARE providers_size = i4 WITH protect, constant(size(request->providers,5))
 DECLARE cur_dt_tm = dq8 WITH protect, constant(cnvtdatetime(curdate,curtime3))
 DECLARE location_clause = vc WITH protect, noconstant("pslr.location_cd = outerjoin(0.0)")
 DECLARE error_msg = vc WITH protect, noconstant("")
 DECLARE status_flag = i2 WITH protect, noconstant(fail)
 DECLARE prsnl_clause = vc WITH protect, noconstant("1=1")
 DECLARE validaterequest(null) = i2
 DECLARE retrieveproviderspecialties(null) = i2
 SET status_flag = validaterequest(null)
 IF (status_flag=fail)
  GO TO exit_script
 ENDIF
 SET status_flag = retrieveproviderspecialties(null)
 IF (status_flag=fail)
  GO TO exit_script
 ENDIF
 SUBROUTINE validaterequest(null)
   IF ((request->specialty_cd <= 0.0)
    AND providers_size <= 0)
    SET reply->status_data.subeventstatus[1].targetobjectname = "validateRequest()"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "specialty_cd or at least one provider is required"
    RETURN(fail)
   ENDIF
   IF ((request->only_primary_ind != 0))
    SET request->only_primary_ind = 1
   ENDIF
   IF ((request->retrieve_locations_ind != 0))
    SET request->retrieve_locations_ind = 1
    SET location_clause = "pslr.location_cd > outerjoin(0.0)"
   ENDIF
   RETURN(success)
 END ;Subroutine
 SUBROUTINE retrieveproviderspecialties(null)
   SET data_partition_ind = 0
   SET field_found = 0
   RANGE OF c IS code_value_set
   SET field_found = validate(c.br_client_id)
   FREE RANGE c
   IF (field_found=0)
    SET prg_exists_ind = 0
    SET prg_exists_ind = checkprg("ACM_GET_ACC_LOGICAL_DOMAINS")
    IF (prg_exists_ind > 0)
     SET field_found = 0
     RANGE OF p IS prsnl
     SET field_found = validate(p.logical_domain_id)
     FREE RANGE p
     IF (field_found=1)
      SET data_partition_ind = 1
      FREE SET acm_get_acc_logical_domains_req
      RECORD acm_get_acc_logical_domains_req(
        1 write_mode_ind = i2
        1 concept = i4
      )
      FREE SET acm_get_acc_logical_domains_rep
      RECORD acm_get_acc_logical_domains_rep(
        1 logical_domain_grp_id = f8
        1 logical_domains_cnt = i4
        1 logical_domains[*]
          2 logical_domain_id = f8
        1 status_block
          2 status_ind = i2
          2 error_code = i4
      )
      SET acm_get_acc_logical_domains_req->write_mode_ind = 0
      SET acm_get_acc_logical_domains_req->concept = 2
      EXECUTE acm_get_acc_logical_domains  WITH replace("REQUEST",acm_get_acc_logical_domains_req),
      replace("REPLY",acm_get_acc_logical_domains_rep)
     ENDIF
    ENDIF
   ENDIF
   IF (data_partition_ind=1)
    IF ((acm_get_acc_logical_domains_rep->logical_domains_cnt > 0))
     SET prsnl_clause = concat(prsnl_clause," and p.logical_domain_id in (")
     FOR (d = 1 TO acm_get_acc_logical_domains_rep->logical_domains_cnt)
       IF ((d=acm_get_acc_logical_domains_rep->logical_domains_cnt))
        SET prsnl_clause = build(prsnl_clause,acm_get_acc_logical_domains_rep->logical_domains[d].
         logical_domain_id,")")
       ELSE
        SET prsnl_clause = build(prsnl_clause,acm_get_acc_logical_domains_rep->logical_domains[d].
         logical_domain_id,",")
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
   DECLARE index = i4 WITH protect, noconstant(0)
   DECLARE prov_cnt = i4 WITH protect, noconstant(0)
   DECLARE sp_cnt = i4 WITH protect, noconstant(0)
   DECLARE loc_cnt = i4 WITH protect, noconstant(0)
   DECLARE prov_size = i4 WITH protect, noconstant(0)
   DECLARE block = i4 WITH protect, constant(25)
   DECLARE error_msg = vc WITH protect, noconstant("")
   SELECT
    IF ((request->specialty_cd > 0.0)
     AND providers_size=0)
     FROM prsnl_specialty_reltn psr2,
      prsnl_specialty_reltn psr,
      prsnl_specialty_loc_reltn pslr,
      prsnl p
     PLAN (psr2
      WHERE (psr2.specialty_cd=request->specialty_cd)
       AND psr2.active_ind=1
       AND cnvtdatetime(cur_dt_tm) BETWEEN psr2.beg_effective_dt_tm AND psr2.end_effective_dt_tm)
      JOIN (p
      WHERE parser(prsnl_clause)
       AND p.person_id=psr2.prsnl_id
       AND p.active_ind=1)
      JOIN (psr
      WHERE psr.prsnl_id=p.person_id
       AND psr.primary_ind IN (1, request->only_primary_ind)
       AND psr.active_ind=1
       AND cnvtdatetime(cur_dt_tm) BETWEEN psr.beg_effective_dt_tm AND psr.end_effective_dt_tm)
      JOIN (pslr
      WHERE pslr.prsnl_specialty_reltn_id=outerjoin(psr.prsnl_specialty_reltn_id)
       AND parser(location_clause)
       AND pslr.active_ind=outerjoin(1)
       AND pslr.beg_effective_dt_tm < outerjoin(cnvtdatetime(cur_dt_tm))
       AND pslr.end_effective_dt_tm > outerjoin(cnvtdatetime(cur_dt_tm)))
     WITH nocounter
    ELSEIF ((request->specialty_cd=0.0)
     AND providers_size > 0)
     PLAN (p
      WHERE parser(prsnl_clause)
       AND expand(index,1,providers_size,p.person_id,request->providers[index].prsnl_id))
      JOIN (psr
      WHERE psr.prsnl_id=p.person_id
       AND psr.primary_ind IN (1, request->only_primary_ind)
       AND psr.active_ind=1
       AND cnvtdatetime(cur_dt_tm) BETWEEN psr.beg_effective_dt_tm AND psr.end_effective_dt_tm)
      JOIN (pslr
      WHERE pslr.prsnl_specialty_reltn_id=outerjoin(psr.prsnl_specialty_reltn_id)
       AND parser(location_clause)
       AND pslr.active_ind=outerjoin(1)
       AND pslr.beg_effective_dt_tm < outerjoin(cnvtdatetime(cur_dt_tm))
       AND pslr.end_effective_dt_tm > outerjoin(cnvtdatetime(cur_dt_tm)))
     WITH nocounter, expand = 1
    ELSEIF ((request->specialty_cd > 0.0)
     AND providers_size > 0)
     FROM prsnl_specialty_reltn psr2,
      prsnl_specialty_reltn psr,
      prsnl_specialty_loc_reltn pslr,
      prsnl p
     PLAN (psr2
      WHERE expand(index,1,providers_size,psr2.prsnl_id,request->providers[index].prsnl_id)
       AND (psr2.specialty_cd=request->specialty_cd)
       AND psr2.active_ind=1
       AND cnvtdatetime(cur_dt_tm) BETWEEN psr2.beg_effective_dt_tm AND psr2.end_effective_dt_tm)
      JOIN (p
      WHERE parser(prsnl_clause)
       AND p.person_id=psr2.prsnl_id)
      JOIN (psr
      WHERE psr.prsnl_id=p.person_id
       AND psr.primary_ind IN (1, request->only_primary_ind)
       AND psr.active_ind=1
       AND cnvtdatetime(cur_dt_tm) BETWEEN psr.beg_effective_dt_tm AND psr.end_effective_dt_tm)
      JOIN (pslr
      WHERE pslr.prsnl_specialty_reltn_id=outerjoin(psr.prsnl_specialty_reltn_id)
       AND parser(location_clause)
       AND pslr.active_ind=outerjoin(1)
       AND pslr.beg_effective_dt_tm < outerjoin(cnvtdatetime(cur_dt_tm))
       AND pslr.end_effective_dt_tm > outerjoin(cnvtdatetime(cur_dt_tm)))
     WITH nocounter, expand = 1
    ELSE
    ENDIF
    INTO "nl:"
    FROM prsnl_specialty_reltn psr,
     prsnl_specialty_loc_reltn pslr,
     prsnl p
    PLAN (psr
     WHERE psr.primary_ind IN (1, request->only_primary_ind))
     JOIN (p
     WHERE parser(prsnl_clause)
      AND p.person_id=psr.prsnl_id)
     JOIN (pslr
     WHERE pslr.prsnl_specialty_reltn_id=outerjoin(psr.prsnl_specialty_reltn_id)
      AND parser(location_clause)
      AND pslr.active_ind=outerjoin(1)
      AND pslr.beg_effective_dt_tm < outerjoin(cnvtdatetime(cur_dt_tm))
      AND pslr.end_effective_dt_tm > outerjoin(cnvtdatetime(cur_dt_tm)))
    ORDER BY p.person_id, psr.primary_ind DESC, psr.specialty_cd,
     pslr.location_cd
    HEAD p.person_id
     prov_cnt = (prov_cnt+ 1)
     IF (providers_size > 0)
      stat = alterlist(reply->providers,providers_size)
     ELSE
      IF (prov_cnt=1)
       stat = alterlist(reply->providers,1)
      ELSEIF (mod(prov_cnt,block)=2)
       stat = alterlist(reply->providers,((prov_cnt+ block) - 1))
      ENDIF
     ENDIF
     reply->providers[prov_cnt].prsnl_id = psr.prsnl_id, reply->providers[prov_cnt].
     prsnl_name_full_formatted = trim(p.name_full_formatted,3), sp_cnt = 0
    HEAD psr.primary_ind
     row + 0
    HEAD psr.specialty_cd
     sp_cnt = (sp_cnt+ 1), stat = alterlist(reply->providers[prov_cnt].specialties,sp_cnt), reply->
     providers[prov_cnt].specialties[sp_cnt].specialty_cd = psr.specialty_cd,
     reply->providers[prov_cnt].specialties[sp_cnt].primary_ind = psr.primary_ind, loc_cnt = 0
    HEAD pslr.location_cd
     IF (pslr.location_cd > 0.0)
      loc_cnt = (loc_cnt+ 1), stat = alterlist(reply->providers[prov_cnt].specialties[sp_cnt].
       specific_locations,loc_cnt), reply->providers[prov_cnt].specialties[sp_cnt].
      specific_locations[loc_cnt].location_cd = pslr.location_cd
     ENDIF
    FOOT REPORT
     stat = alterlist(reply->providers,prov_cnt)
    WITH nocounter
   ;end select
   IF (error(error_msg,1))
    SET reply->status_data.subeventstatus[1].targetobjectname = "retrieveProviderSpecialties()"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = error_msg
    RETURN(fail)
   ENDIF
   IF (size(reply->providers,5)=0)
    RETURN(nodata)
   ENDIF
   RETURN(success)
 END ;Subroutine
#exit_script
 IF (status_flag=nodata)
  SET reply->status_data.status = "Z"
 ELSEIF (status_flag=success)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO
