CREATE PROGRAM bed_get_dept_by_activity
 SET modify = predeclare
 FREE SET reply
 RECORD reply(
   1 departments[*]
     2 dept_cd = f8
     2 dept_disp = vc
     2 dept_desc = vc
     2 dept_mean = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET lab_srvres_reply
 RECORD lab_srvres_reply(
   1 departments[*]
     2 code_value = f8
     2 sections[*]
       3 code_value = f8
       3 display = c40
       3 description = c60
       3 subsections[*]
         4 code_value = f8
         4 display = c40
         4 description = c60
         4 multiplexor_ind = i2
         4 resources[*]
           5 code_value = f8
           5 display = c40
           5 description = c60
           5 mean = c12
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET depts
 RECORD depts(
   1 depts[*]
     2 dept_cd = f8
     2 srs[*]
       3 service_resource_cd = f8
 )
 DECLARE ndeptaddedcnt = i4 WITH protect, noconstant(0)
 DECLARE ntotrescnt = i4 WITH protect, noconstant(0)
 DECLARE ncurrescnt = i4 WITH protect, noconstant(0)
 DECLARE ntracestore = i4 WITH protect, noconstant(0)
 DECLARE nfoundmatch = i2 WITH protect, noconstant(0)
 DECLARE nrepcnt = i4 WITH protect, noconstant(0)
 DECLARE serrormsg = vc WITH protect, noconstant("")
 DECLARE error_check = i2 WITH protect, noconstant(0)
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE nexpandindex = i4 WITH protect, noconstant(0)
 DECLARE hlx_code = f8 WITH protect, noconstant(0.0)
 DECLARE glb_code = f8 WITH public, noconstant(0.0)
 DECLARE retrievehelixdepts(dummy=i2) = i2
 SET stat = uar_get_meaning_by_codeset(106,"HLX",1,hlx_code)
 SET stat = uar_get_meaning_by_codeset(106,"GLB",1,glb_code)
 SET ntracestore = trace("RECPERSIST")
 SET trace = recpersist
 SET modify = nopredeclare
 EXECUTE bed_get_lab_srvres_by_dept  WITH replace(reply,lab_srvres_reply)
 SET modify = predeclare
 IF (ntracestore=0)
  SET trace = norecpersist
 ENDIF
 FOR (i = 1 TO size(lab_srvres_reply->departments,5))
  SET ntotrescnt = 0
  FOR (j = 1 TO size(lab_srvres_reply->departments[i].sections,5))
    FOR (k = 1 TO size(lab_srvres_reply->departments[i].sections[j].subsections,5))
      SET ncurrescnt = size(lab_srvres_reply->departments[i].sections[j].subsections[k].resources,5)
      IF (ncurrescnt > 0)
       IF (ntotrescnt=0)
        SET ndeptaddedcnt = (ndeptaddedcnt+ 1)
        IF (mod(ndeptaddedcnt,10)=1)
         SET stat = alterlist(depts->depts,(ndeptaddedcnt+ 9))
        ENDIF
        SET depts->depts[ndeptaddedcnt].dept_cd = lab_srvres_reply->departments[i].code_value
       ENDIF
       SET stat = alterlist(depts->depts[ndeptaddedcnt].srs,(ntotrescnt+ ncurrescnt))
       FOR (l = 1 TO ncurrescnt)
        SET ntotrescnt = (ntotrescnt+ 1)
        SET depts->depts[ndeptaddedcnt].srs[ntotrescnt].service_resource_cd = lab_srvres_reply->
        departments[i].sections[j].subsections[k].resources[l].code_value
       ENDFOR
      ENDIF
      IF ((request->activity_type_code_value=glb_code))
       IF (ntotrescnt=0)
        SET ndeptaddedcnt = (ndeptaddedcnt+ 1)
        IF (mod(ndeptaddedcnt,10)=1)
         SET stat = alterlist(depts->depts,(ndeptaddedcnt+ 9))
        ENDIF
        SET depts->depts[ndeptaddedcnt].dept_cd = lab_srvres_reply->departments[i].code_value
       ENDIF
       SET ntotrescnt = (ntotrescnt+ 1)
       SET stat = alterlist(depts->depts[ndeptaddedcnt].srs,ntotrescnt)
       SET depts->depts[ndeptaddedcnt].srs[ntotrescnt].service_resource_cd = lab_srvres_reply->
       departments[i].sections[j].subsections[k].code_value
      ENDIF
    ENDFOR
  ENDFOR
 ENDFOR
 SET stat = alterlist(depts->depts,ndeptaddedcnt)
 CALL echorecord(depts)
 IF ((request->activity_type_code_value=hlx_code))
  CALL retrievehelixdepts(0)
 ELSE
  FOR (i = 1 TO ndeptaddedcnt)
    SET nfoundmatch = 0
    SELECT DISTINCT INTO "nl:"
     apr.service_resource_cd
     FROM discrete_task_assay dta,
      assay_processing_r apr,
      profile_task_r ptr,
      collection_info_qualifiers ciq
     PLAN (apr
      WHERE expand(nexpandindex,1,size(depts->depts[i].srs,5),apr.service_resource_cd,depts->depts[i]
       .srs[nexpandindex].service_resource_cd)
       AND apr.active_ind=1)
      JOIN (dta
      WHERE dta.task_assay_cd=apr.task_assay_cd
       AND ((dta.activity_type_cd+ 0)=request->activity_type_code_value)
       AND dta.active_ind=1)
      JOIN (ptr
      WHERE ptr.task_assay_cd=dta.task_assay_cd
       AND ptr.active_ind=1)
      JOIN (ciq
      WHERE ciq.catalog_cd=ptr.catalog_cd
       AND ((ciq.service_resource_cd=apr.service_resource_cd) OR (ciq.service_resource_cd=0.0)) )
     DETAIL
      nfoundmatch = 1
     WITH nocounter
    ;end select
    IF (nfoundmatch=1)
     SET nrepcnt = (nrepcnt+ 1)
     IF (mod(nrepcnt,10)=1)
      SET stat = alterlist(reply->departments,(nrepcnt+ 9))
     ENDIF
     SET reply->departments[nrepcnt].dept_cd = depts->depts[i].dept_cd
    ENDIF
  ENDFOR
 ENDIF
 SUBROUTINE retrievehelixdepts(dummy)
  CALL echo("IN RetrieveHelixDepts")
  FOR (i = 1 TO ndeptaddedcnt)
    SET nfoundmatch = 0
    SELECT DISTINCT INTO "nl:"
     apr.service_resource_cd
     FROM discrete_task_assay dta,
      assay_processing_r apr,
      profile_task_r ptr,
      collection_info_qualifiers ciq
     WHERE expand(nexpandindex,1,size(depts->depts[i].srs,5),apr.service_resource_cd,depts->depts[i].
      srs[nexpandindex].service_resource_cd)
      AND apr.active_ind=1
      AND dta.task_assay_cd=apr.task_assay_cd
      AND ((dta.activity_type_cd+ 0)=request->activity_type_code_value)
      AND dta.active_ind=1
      AND ptr.task_assay_cd=dta.task_assay_cd
      AND ptr.active_ind=1
      AND ciq.catalog_cd=ptr.catalog_cd
      AND ((ciq.service_resource_cd IN (apr.service_resource_cd, 0.0)) UNION (
     (SELECT DISTINCT INTO "nl:"
      apr.service_resource_cd
      FROM discrete_task_assay dta,
       assay_processing_r apr,
       profile_task_r ptr,
       ucmr_case_step ucs,
       ucmr_workup_criteria uwc,
       collection_info_qualifiers ciq
      WHERE expand(nexpandindex,1,size(depts->depts[i].srs,5),apr.service_resource_cd,depts->depts[i]
       .srs[nexpandindex].service_resource_cd)
       AND apr.active_ind=1
       AND dta.task_assay_cd=apr.task_assay_cd
       AND ((dta.activity_type_cd+ 0)=request->activity_type_code_value)
       AND dta.active_ind=1
       AND ptr.task_assay_cd=dta.task_assay_cd
       AND ptr.active_ind=1
       AND ucs.case_step_cat_cd=ptr.catalog_cd
       AND ucs.active_ind=1
       AND ucs.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
       AND uwc.ucmr_case_workup_id=ucs.ucmr_case_workup_id
       AND uwc.active_ind=1
       AND uwc.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
       AND ciq.catalog_cd=uwc.catalog_cd
       AND ciq.service_resource_cd IN (apr.service_resource_cd, 0.0))))
     DETAIL
      nfoundmatch = 1
     WITH nocounter, rdbunion
    ;end select
    IF (nfoundmatch=1)
     SET nrepcnt = (nrepcnt+ 1)
     IF (mod(nrepcnt,10)=1)
      SET stat = alterlist(reply->departments,(nrepcnt+ 9))
     ENDIF
     SET reply->departments[nrepcnt].dept_cd = depts->depts[i].dept_cd
    ENDIF
  ENDFOR
 END ;Subroutine
 SET stat = alterlist(reply->departments,nrepcnt)
 SET error_check = error(serrormsg,0)
 IF (error_check != 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
 ELSEIF (nrepcnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
