CREATE PROGRAM acm_get_pat_lists_definition:dba
 DECLARE s_cdf_meaning = c12 WITH public, noconstant(fillstring(12," "))
 DECLARE s_code_value = f8 WITH public, noconstant(0.0)
 SUBROUTINE (loadcodevalue(code_set=i4,cdf_meaning=vc,option_flag=i2) =f8)
   SET s_cdf_meaning = cdf_meaning
   SET s_code_value = 0.0
   SET stat = uar_get_meaning_by_codeset(code_set,s_cdf_meaning,1,s_code_value)
   IF (((stat != 0) OR (s_code_value <= 0)) )
    SET s_code_value = 0.0
    CASE (option_flag)
     OF 0:
      SET table_name = build("ERROR-->loadcodevalue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(table_name)
      SET failed = uar_error
      GO TO exit_script
     OF 1:
      CALL echo(build("INFO-->loadcodevalue (",code_set,",",'"',s_cdf_meaning,
        '"',",",option_flag,") not found, CURPROG [",curprog,
        "]"))
    ENDCASE
   ELSE
    CALL echo(build("SUCCESS-->loadcodevalue (",code_set,",",'"',s_cdf_meaning,
      '"',",",option_flag,") CODE_VALUE [",s_code_value,
      "]"))
   ENDIF
   RETURN(s_code_value)
 END ;Subroutine
 RECORD reply(
   1 patient_list_qual[*]
     2 patient_list_id = f8
     2 name = vc
     2 description = vc
     2 patient_list_type_cd = f8
     2 owner_id = f8
     2 access_cd = f8
     2 arguments[*]
       3 argument_name = vc
       3 argument_value = vc
       3 parent_entity_name = vc
       3 parent_entity_id = f8
     2 encntr_type_filters[*]
       3 encntr_type_cd = f8
       3 encntr_class_cd = f8
     2 proxies[*]
       3 prsnl_id = f8
       3 prsnl_group_id = f8
       3 list_access_cd = f8
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
     2 status = c1
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE counter = i4 WITH noconstant(0)
 DECLARE argument_ctr = i4 WITH protect, noconstant(0)
 DECLARE encntr_ctr = i4 WITH protect, noconstant(0)
 DECLARE reltn_ctr = i4 WITH protect, noconstant(0)
 DECLARE req_size = i4 WITH protect, noconstant(size(request->patient_list_qual,5))
 DECLARE owner_cd = f8 WITH protect, noconstant(loadcodevalue(27380,"OWNER",0))
 DECLARE stat = i2 WITH protect
 SET stat = alterlist(reply->patient_list_qual,req_size)
 FOR (i = 1 TO req_size)
   SET reply->patient_list_qual[i].patient_list_id = request->patient_list_qual[i].patient_list_id
   IF ((request->patient_list_qual[i].prsnl_id <= 0))
    SET request->patient_list_qual[i].prsnl_id = reqinfo->updt_id
   ENDIF
   SET reply->patient_list_qual[i].status = "Z"
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(req_size)),
   dcp_patient_list pl,
   dcp_pl_argument pa
  PLAN (d
   WHERE (request->patient_list_qual[d.seq].patient_list_id > 0))
   JOIN (pl
   WHERE (pl.patient_list_id=request->patient_list_qual[d.seq].patient_list_id))
   JOIN (pa
   WHERE (pa.patient_list_id= Outerjoin(pl.patient_list_id)) )
  HEAD d.seq
   argument_ctr = 0, reply->patient_list_qual[d.seq].patient_list_id = pl.patient_list_id, reply->
   patient_list_qual[d.seq].name = pl.name,
   reply->patient_list_qual[d.seq].description = pl.description, reply->patient_list_qual[d.seq].
   patient_list_type_cd = pl.patient_list_type_cd, reply->patient_list_qual[d.seq].owner_id = pl
   .owner_prsnl_id
   IF ((pl.owner_prsnl_id=request->patient_list_qual[d.seq].prsnl_id))
    reply->patient_list_qual[d.seq].access_cd = owner_cd
   ENDIF
   reply->patient_list_qual[d.seq].status = "S"
  DETAIL
   IF (pa.argument_id != 0)
    argument_ctr += 1
    IF (mod(argument_ctr,10)=1)
     stat = alterlist(reply->patient_list_qual[d.seq].arguments,(argument_ctr+ 9))
    ENDIF
    reply->patient_list_qual[d.seq].arguments[argument_ctr].argument_name = pa.argument_name, reply->
    patient_list_qual[d.seq].arguments[argument_ctr].argument_value = pa.argument_value, reply->
    patient_list_qual[d.seq].arguments[argument_ctr].parent_entity_name = pa.parent_entity_name,
    reply->patient_list_qual[d.seq].arguments[argument_ctr].parent_entity_id = pa.parent_entity_id
   ENDIF
  FOOT  d.seq
   IF ((reply->patient_list_qual[d.seq].access_cd=0))
    reply->patient_list_qual[d.seq].status = "F"
   ELSE
    reply->patient_list_qual[d.seq].status = "S"
   ENDIF
   stat = alterlist(reply->patient_list_qual[d.seq].arguments,argument_ctr)
  WITH nocounter
 ;end select
 SET counter = curqual
 IF (curqual=0)
  GO TO exitscript
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(req_size)),
   dcp_pl_encntr_filter pe
  PLAN (d
   WHERE (request->patient_list_qual[d.seq].patient_list_id > 0))
   JOIN (pe
   WHERE (pe.patient_list_id=reply->patient_list_qual[d.seq].patient_list_id))
  HEAD d.seq
   encntr_ctr = 0
  DETAIL
   IF (pe.encntr_filter_id != 0)
    encntr_ctr += 1
    IF (mod(encntr_ctr,10)=1)
     stat = alterlist(reply->patient_list_qual[d.seq].encntr_type_filters,(encntr_ctr+ 9))
    ENDIF
    reply->patient_list_qual[d.seq].encntr_type_filters[encntr_ctr].encntr_type_cd = pe
    .encntr_type_cd, reply->patient_list_qual[d.seq].encntr_type_filters[encntr_ctr].encntr_class_cd
     = pe.encntr_class_cd
   ENDIF
  FOOT  d.seq
   stat = alterlist(reply->patient_list_qual[d.seq].encntr_type_filters,encntr_ctr)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(req_size)),
   dcp_pl_reltn pr,
   prsnl_group_reltn pgr
  PLAN (d
   WHERE (request->patient_list_qual[d.seq].patient_list_id > 0))
   JOIN (pr
   WHERE (pr.patient_list_id=reply->patient_list_qual[d.seq].patient_list_id))
   JOIN (pgr
   WHERE (pgr.prsnl_group_id= Outerjoin(pr.prsnl_group_id)) )
  HEAD d.seq
   reltn_ctr = 0
  HEAD pr.reltn_id
   IF (pr.reltn_id != 0)
    reltn_ctr += 1
    IF (mod(reltn_ctr,10)=1)
     stat = alterlist(reply->patient_list_qual[d.seq].proxies,(reltn_ctr+ 9))
    ENDIF
    reply->patient_list_qual[d.seq].proxies[reltn_ctr].prsnl_id = pr.prsnl_id, reply->
    patient_list_qual[d.seq].proxies[reltn_ctr].prsnl_group_id = pr.prsnl_group_id, reply->
    patient_list_qual[d.seq].proxies[reltn_ctr].list_access_cd = pr.list_access_cd,
    reply->patient_list_qual[d.seq].proxies[reltn_ctr].beg_effective_dt_tm = cnvtdatetime(pr
     .beg_effective_dt_tm), reply->patient_list_qual[d.seq].proxies[reltn_ctr].end_effective_dt_tm =
    cnvtdatetime(pr.end_effective_dt_tm)
    IF ((reply->patient_list_qual[d.seq].access_cd=0)
     AND (pr.prsnl_id=request->patient_list_qual[d.seq].prsnl_id))
     reply->patient_list_qual[d.seq].access_cd = pr.list_access_cd
    ENDIF
   ENDIF
  DETAIL
   IF ((reply->patient_list_qual[d.seq].access_cd=0)
    AND (pgr.person_id=request->patient_list_qual[d.seq].prsnl_id))
    reply->patient_list_qual[d.seq].access_cd = pr.list_access_cd
   ENDIF
  FOOT  d.seq
   IF ((reply->patient_list_qual[d.seq].access_cd=0))
    reply->patient_list_qual[d.seq].status = "F"
   ELSE
    reply->patient_list_qual[d.seq].status = "S"
   ENDIF
   stat = alterlist(reply->patient_list_qual[d.seq].proxies,reltn_ctr)
  WITH nocounter
 ;end select
#exitscript
 IF (counter=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
