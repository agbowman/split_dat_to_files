CREATE PROGRAM aa_get_all_prsnl_servres:dba
 RECORD reply(
   1 service_resource_list[*]
     2 service_resource_cd = f8
     2 parent_cd = f8
     2 section_ind = i2
   1 prsnl_list[*]
     2 prsnl_id = f8
     2 service_resource_list[*]
       3 service_resource_cd = f8
   1 qual[*]
     2 service_resource_list[*]
       3 service_resource_cd = f8
       3 parent_cd = f8
       3 section_ind = i2
   1 new_qual_for_65k = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE validatequal(null) = i4
 DECLARE prsnl_count = i4
 DECLARE sr_count = i4
 DECLARE department_cd = f8
 DECLARE max_list_size = i4 WITH public, constant(64999)
 DECLARE qual_sr_count = i4 WITH public, noconstant(0)
 DECLARE outer_qual_count = i4 WITH public, noconstant(0)
 DECLARE qual_declared = i4 WITH public, noconstant(0)
 CALL uar_get_meaning_by_codeset(223,nullterm("DEPARTMENT"),1,department_cd)
 SET qual_declared = validatequal(null)
 IF (validate(request->load_mode,0))
  SELECT INTO "nl:"
   FROM dm_info dm
   WHERE dm.info_domain="SRS"
    AND dm.info_date >= cnvtdatetimeutc(request->lastupdt_dt_tm,2)
   WITH nocounter
  ;end select
  IF (curqual < 1)
   SET reply->status = "S"
   GO TO exit_script
  ENDIF
 ENDIF
 IF (qual_declared=0)
  SELECT INTO "nl:"
   FROM service_resource sr1,
    resource_group rg,
    service_resource sr2
   PLAN (sr1
    WHERE sr1.active_ind=1
     AND sr1.beg_effective_dt_tm < cnvtdatetime(sysdate)
     AND sr1.end_effective_dt_tm >= cnvtdatetime(sysdate)
     AND sr1.service_resource_cd > 0)
    JOIN (rg
    WHERE (rg.child_service_resource_cd= Outerjoin(sr1.service_resource_cd))
     AND (rg.root_service_resource_cd= Outerjoin(0))
     AND (rg.active_ind= Outerjoin(1))
     AND (rg.beg_effective_dt_tm< Outerjoin(cnvtdatetime(sysdate)))
     AND (rg.end_effective_dt_tm>= Outerjoin(cnvtdatetime(sysdate))) )
    JOIN (sr2
    WHERE (sr2.service_resource_cd= Outerjoin(rg.parent_service_resource_cd))
     AND (sr2.active_ind= Outerjoin(1))
     AND (sr2.beg_effective_dt_tm< Outerjoin(cnvtdatetime(sysdate)))
     AND (sr2.end_effective_dt_tm>= Outerjoin(cnvtdatetime(sysdate))) )
   HEAD REPORT
    sr_count = 0, outer_qual_count = 1, stat = alterlist(reply->qual,outer_qual_count)
   DETAIL
    IF (sr_count=max_list_size)
     stat = alterlist(reply->qual[outer_qual_count].service_resource_list,sr_count), sr_count = 0,
     outer_qual_count += 1,
     stat = alterlist(reply->qual,outer_qual_count)
    ENDIF
    sr_count += 1
    IF (mod(sr_count,10)=1)
     stat = alterlist(reply->qual[outer_qual_count].service_resource_list,(sr_count+ 9))
    ENDIF
    reply->qual[outer_qual_count].service_resource_list[sr_count].service_resource_cd = sr1
    .service_resource_cd, reply->qual[outer_qual_count].service_resource_list[sr_count].parent_cd =
    sr2.service_resource_cd
    IF (sr2.service_resource_type_cd=department_cd)
     reply->qual[outer_qual_count].service_resource_list[sr_count].section_ind = 1
    ELSE
     reply->qual[outer_qual_count].service_resource_list[sr_count].section_ind = 0
    ENDIF
   FOOT REPORT
    IF (sr_count > 0)
     stat = alterlist(reply->qual[outer_qual_count].service_resource_list,sr_count)
    ENDIF
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM service_resource sr1,
    resource_group rg,
    service_resource sr2
   PLAN (sr1
    WHERE sr1.active_ind=1
     AND sr1.beg_effective_dt_tm < cnvtdatetime(sysdate)
     AND sr1.end_effective_dt_tm >= cnvtdatetime(sysdate)
     AND sr1.service_resource_cd > 0)
    JOIN (rg
    WHERE (rg.child_service_resource_cd= Outerjoin(sr1.service_resource_cd))
     AND (rg.root_service_resource_cd= Outerjoin(0))
     AND (rg.active_ind= Outerjoin(1))
     AND (rg.beg_effective_dt_tm< Outerjoin(cnvtdatetime(sysdate)))
     AND (rg.end_effective_dt_tm>= Outerjoin(cnvtdatetime(sysdate))) )
    JOIN (sr2
    WHERE (sr2.service_resource_cd= Outerjoin(rg.parent_service_resource_cd))
     AND (sr2.active_ind= Outerjoin(1))
     AND (sr2.beg_effective_dt_tm< Outerjoin(cnvtdatetime(sysdate)))
     AND (sr2.end_effective_dt_tm>= Outerjoin(cnvtdatetime(sysdate))) )
   HEAD REPORT
    sr_count = 0
   DETAIL
    sr_count += 1
    IF (mod(sr_count,10)=1)
     stat = alterlist(reply->service_resource_list,(sr_count+ 9))
    ENDIF
    reply->service_resource_list[sr_count].service_resource_cd = sr1.service_resource_cd, reply->
    service_resource_list[sr_count].parent_cd = sr2.service_resource_cd
    IF (sr2.service_resource_type_cd=department_cd)
     reply->service_resource_list[sr_count].section_ind = 1
    ELSE
     reply->service_resource_list[sr_count].section_ind = 0
    ENDIF
   FOOT REPORT
    stat = alterlist(reply->service_resource_list,sr_count)
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  FROM prsnl_service_resource_reltn psrr,
   prsnl p
  PLAN (psrr)
   JOIN (p
   WHERE p.person_id=psrr.prsnl_id
    AND p.active_ind=1
    AND p.beg_effective_dt_tm < cnvtdatetime(sysdate)
    AND p.end_effective_dt_tm >= cnvtdatetime(sysdate))
  ORDER BY psrr.prsnl_id
  HEAD REPORT
   prnsl_count = 0
  HEAD psrr.prsnl_id
   sr_count = 0, prsnl_count += 1
   IF (mod(prsnl_count,10)=1)
    stat = alterlist(reply->prsnl_list,(prsnl_count+ 9))
   ENDIF
   reply->prsnl_list[prsnl_count].prsnl_id = psrr.prsnl_id
  DETAIL
   IF (psrr.service_resource_cd > 0)
    sr_count += 1
    IF (mod(sr_count,10)=1)
     stat = alterlist(reply->prsnl_list[prsnl_count].service_resource_list,(sr_count+ 9))
    ENDIF
    reply->prsnl_list[prsnl_count].service_resource_list[sr_count].service_resource_cd = psrr
    .service_resource_cd
   ENDIF
  FOOT  psrr.prsnl_id
   stat = alterlist(reply->prsnl_list[prsnl_count].service_resource_list,sr_count)
  FOOT REPORT
   stat = alterlist(reply->prsnl_list,prsnl_count)
  WITH nocounter
 ;end select
 IF (prsnl_count=0
  AND sr_count=0)
  SET reply->status = "Z"
 ELSE
  SET reply->status = "S"
 ENDIF
 SUBROUTINE validatequal(null)
   RETURN(validate(reply->new_qual_for_65k,- (1)))
 END ;Subroutine
#exit_script
END GO
