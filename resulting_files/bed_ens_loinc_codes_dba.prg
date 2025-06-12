CREATE PROGRAM bed_ens_loinc_codes:dba
 SET modify = predeclare
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE active = c6 WITH protect, constant("ACTIVE")
 DECLARE inactive = c8 WITH protect, constant("INACTIVE")
 DECLARE dactivecd = f8 WITH protect, noconstant(0.0)
 DECLARE dinactivecd = f8 WITH protect, noconstant(0.0)
 DECLARE loinc = c6 WITH protect, constant("LOINC!")
 DECLARE sfailed = c1 WITH protect, noconstant("N")
 DECLARE sconceptcki = vc WITH protect, noconstant("")
 DECLARE dloincid = f8 WITH protect, noconstant(0.0)
 DECLARE serrmsg = vc WITH protect, noconstant(fillstring(132," "))
 DECLARE ierrcode = i4 WITH protect, noconstant(0)
 DECLARE ndupfoundflag = i2 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET dactivecd = uar_get_code_by("MEANING",48,"ACTIVE")
 SET dinactivecd = uar_get_code_by("MEANING",48,"INACTIVE")
 FOR (x = 1 TO size(request->codes,5))
   SET ierrcode = 0
   IF ((request->codes[x].ignore_ind=1))
    SET sconceptcki = ""
   ELSEIF (substring(1,6,request->codes[x].loinc_code)=loinc)
    SET sconceptcki = request->codes[x].loinc_code
   ELSE
    SET sconceptcki = concat(loinc,request->codes[x].loinc_code)
   ENDIF
   SET ndupfoundflag = 0
   SELECT INTO "nl:"
    FROM concept_identifier_dta cid
    PLAN (cid
     WHERE (cid.task_assay_cd=request->codes[x].assay_code_value)
      AND (cid.service_resource_cd=request->codes[x].service_resource_code_value)
      AND (cid.specimen_type_cd=request->codes[x].specimen_type_code)
      AND (cid.concept_type_flag=request->codes[x].code_type_ind)
      AND cid.end_effective_dt_tm=cnvtdatetime("31 DEC 2100 00:00")
      AND (cid.concept_identifier_dta_id != request->codes[x].concept_identifier_dta_id))
    DETAIL
     IF ((request->codes[x].ignore_ind=cid.ignore_ind)
      AND trim(sconceptcki)=trim(cid.concept_cki))
      ndupfoundflag = 1
     ELSE
      ndupfoundflag = 2
     ENDIF
    WITH nocounter
   ;end select
   IF (ndupfoundflag=0)
    IF ((request->codes[x].concept_identifier_dta_id > 0.0))
     SET ierrcode = 0
     UPDATE  FROM concept_identifier_dta cid
      SET cid.active_ind = 0, cid.active_status_cd = dinactivecd, cid.end_effective_dt_tm =
       cnvtdatetime(curdate,curtime3),
       cid.active_status_dt_tm = cnvtdatetime(curdate,curtime3), cid.active_status_prsnl_id = reqinfo
       ->updt_id, cid.updt_applctx = reqinfo->updt_applctx,
       cid.updt_cnt = (cid.updt_cnt+ 1), cid.updt_dt_tm = cnvtdatetime(curdate,curtime3), cid.updt_id
        = reqinfo->updt_id,
       cid.updt_task = reqinfo->updt_task
      PLAN (cid
       WHERE (cid.concept_identifier_dta_id=request->codes[x].concept_identifier_dta_id))
      WITH nocounter
     ;end update
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET sfailed = "Y"
      GO TO exit_script
     ENDIF
    ENDIF
    IF (((size(trim(request->codes[x].loinc_code)) > 0) OR ((request->codes[x].ignore_ind=1))) )
     SET dloincid = 0.0
     SELECT INTO "nl:"
      y = seq(pathnet_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       dloincid = cnvtreal(y)
      WITH format, counter
     ;end select
     INSERT  FROM concept_identifier_dta cid
      SET cid.active_ind = 1, cid.active_status_cd = dactivecd, cid.active_status_dt_tm =
       cnvtdatetime(curdate,curtime3),
       cid.active_status_prsnl_id = reqinfo->updt_id, cid.beg_effective_dt_tm = cnvtdatetime(curdate,
        curtime3), cid.concept_cki = sconceptcki,
       cid.concept_identifier_dta_id = dloincid, cid.concept_type_flag = request->codes[x].
       code_type_ind, cid.end_effective_dt_tm = cnvtdatetime("31 DEC 2100 00:00"),
       cid.ignore_ind = request->codes[x].ignore_ind, cid.service_resource_cd = request->codes[x].
       service_resource_code_value, cid.specimen_type_cd = request->codes[x].specimen_type_code,
       cid.task_assay_cd = request->codes[x].assay_code_value, cid.updt_applctx = reqinfo->
       updt_applctx, cid.updt_cnt = 0,
       cid.updt_dt_tm = cnvtdatetime(curdate,curtime3), cid.updt_id = reqinfo->updt_id, cid.updt_task
        = reqinfo->updt_task
      WITH nocounter
     ;end insert
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET sfailed = "Y"
      GO TO exit_script
     ENDIF
    ENDIF
   ELSEIF (ndupfoundflag=2)
    SET sfailed = "P"
   ENDIF
 ENDFOR
#exit_script
 IF (sfailed="Y")
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = serrmsg
 ELSEIF (sfailed="P")
  SET reply->status_data.status = "P"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET reqinfo->commit_ind = 1
END GO
