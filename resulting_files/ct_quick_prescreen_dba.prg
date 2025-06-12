CREATE PROGRAM ct_quick_prescreen:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Evaluation Start Date" = "CURDATE",
  "Evaluation End Date" = "CURDATE",
  "Encounter types to be considered:" = 0,
  "Facility to be evaluated:" = 0,
  "Sex" = 0.000000,
  "Age Qualifier" = 0.000000,
  "Age 1 (years)" = 0,
  "Age 2 (years)" = 0,
  "Race" = 0.000000,
  "Ethnicity" = 0.000000,
  "Terminology Codes" = "276908.000000",
  "Codes" = "",
  "Evaluation by:" = 0,
  "triggerID" = 9855361
  WITH outdev, startdate, enddate,
  encntrtypecd, facilitycd, sex,
  qualifier, age1, age2,
  race, ethnicity, terminology,
  codes, evalby, triggerid
 RECORD ct_quick_prescreen_request(
   1 start_dt = dq8
   1 end_dt = dq8
   1 eanyflag = i2
   1 encntr_type_lst[*]
     2 encntr_type_cd = f8
   1 fanyflag = i2
   1 facility_lst[*]
     2 facility_cd = f8
   1 gender_cd = f8
   1 age_qualifier_cd = f8
   1 age1 = i4
   1 age2 = i4
   1 race_cd = f8
   1 ethnic_grp_cd = f8
   1 terminology_cd = f8
   1 codes[*]
     2 source_identifier = vc
   1 eval_by = i2
   1 prot_master_id = f8
   1 parent_job_id = f8
   1 screener_id = f8
 )
 RECORD org_sec_reply(
   1 orgsecurityflag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD calling_fac_reply(
   1 skip = i2
   1 org_security_ind = i2
   1 org_security_fnd = i2
   1 facility_list[*]
     2 facility_display = vc
     2 facility_cd = f8
 )
 RECORD uniquevalues(
   1 list[*]
     2 value = vc
 )
 IF (validate(i18nuar_def,999)=999)
  CALL echo("Declaring i18nuar_def")
  DECLARE i18nuar_def = i2 WITH persist
  SET i18nuar_def = 1
  DECLARE uar_i18nlocalizationinit(p1=i4,p2=vc,p3=vc,p4=f8) = i4 WITH persist
  DECLARE uar_i18ngetmessage(p1=i4,p2=vc,p3=vc) = vc WITH persist
  DECLARE uar_i18nbuildmessage() = vc WITH persist
  DECLARE uar_i18ngethijridate(imonth=i2(val),iday=i2(val),iyear=i2(val),sdateformattype=vc(ref)) =
  c50 WITH image_axp = "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar =
  "uar_i18nGetHijriDate",
  persist
  DECLARE uar_i18nbuildfullformatname(sfirst=vc(ref),slast=vc(ref),smiddle=vc(ref),sdegree=vc(ref),
   stitle=vc(ref),
   sprefix=vc(ref),ssuffix=vc(ref),sinitials=vc(ref),soriginal=vc(ref)) = c250 WITH image_axp =
  "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar = "i18nBuildFullFormatName",
  persist
  DECLARE uar_i18ngetarabictime(ctime=vc(ref)) = c20 WITH image_axp = "shri18nuar", image_aix =
  "libi18n_locale.a(libi18n_locale.o)", uar = "i18n_GetArabicTime",
  persist
 ENDIF
 DECLARE i18nhandle = i4 WITH public, noconstant(0)
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 DECLARE startdttm = dq8 WITH public
 DECLARE enddttm = dq8 WITH public
 DECLARE cnt = i4 WITH public, noconstant(0)
 DECLARE etypecnt = i4 WITH public
 DECLARE eparse = c20 WITH public
 DECLARE bset = i2 WITH public, noconstant(0)
 DECLARE i = i4 WITH public, noconstant(0)
 DECLARE faccnt = i4 WITH public, noconstant(0)
 DECLARE indx = i4 WITH public, noconstant(0)
 DECLARE terminologycd = f8 WITH public, noconstant(0.0)
 DECLARE dxcodelist = vc WITH public, noconstant("")
 DECLARE dxcodecnt = i4 WITH public, noconstant(0)
 DECLARE code_not_found = vc WITH public, constant("<next_piece_not_found>")
 EXECUTE ct_get_org_security  WITH replace("REPLY","ORG_SEC_REPLY")
 CALL echo(build("org_sec_reply->OrgSecurityFlag: ",org_sec_reply->orgsecurityflag))
 SET ct_quick_prescreen_request->screener_id = reqinfo->updt_id
 SET ct_quick_prescreen_request->start_dt = cnvtdatetime(build2( $STARTDATE,"00:00:00"))
 SET ct_quick_prescreen_request->end_dt = cnvtdatetime(build2( $ENDDATE,"23:59:59"))
 SET ct_quick_prescreen_request->eanyflag = 0
 SET eparse = reflect(parameter(4,0))
 CALL echo(concat("eParse for encounter type parameter = ",eparse))
 IF (((eparse="C1") OR (eparse="I4")) )
  SET ct_quick_prescreen_request->eanyflag = 1
 ELSEIF (substring(1,1,eparse)="L")
  CALL echo("$encntrTypeCd is a list")
  SET etypecnt = 1
  WHILE (parameter(4,etypecnt) > 0)
    CALL echo(parameter(4,etypecnt))
    IF (mod(etypecnt,10)=1)
     SET stat = alterlist(ct_quick_prescreen_request->encntr_type_lst,(etypecnt+ 9))
    ENDIF
    SET ct_quick_prescreen_request->encntr_type_lst[etypecnt].encntr_type_cd = parameter(4,etypecnt)
    SET etypecnt += 1
  ENDWHILE
  SET stat = alterlist(ct_quick_prescreen_request->encntr_type_lst,(etypecnt - 1))
 ELSE
  SET stat = alterlist(ct_quick_prescreen_request->encntr_type_lst,1)
  SET ct_quick_prescreen_request->encntr_type_lst[1].encntr_type_cd = parameter(4,1)
 ENDIF
 SET eparse = reflect(parameter(5,0))
 CALL echo(concat("eParse for facility parameter = ",eparse))
 IF (((eparse="C1") OR (eparse="I4")) )
  IF ((org_sec_reply->orgsecurityflag=0))
   SET ct_quick_prescreen_request->fanyflag = 1
  ELSE
   SET calling_fac_reply->skip = 1
   SET calling_fac_reply->org_security_ind = org_sec_reply->orgsecurityflag
   SET calling_fac_reply->org_security_fnd = 1
   EXECUTE ct_get_facility_list  WITH replace("FACILITYLIST","CALLING_FAC_REPLY")
   SET bset = 1
   SET faccnt = size(calling_fac_reply->facility_list,5)
   SET stat = alterlist(ct_quick_prescreen_request->facility_lst,faccnt)
   FOR (indx = 1 TO faccnt)
     SET ct_quick_prescreen_request->facility_lst[indx].facility_cd = calling_fac_reply->
     facility_list[indx].facility_cd
   ENDFOR
  ENDIF
 ELSEIF (substring(1,1,eparse)="L")
  CALL echo("$facilityCd is a list")
  SET cnt = 1
  WHILE (parameter(5,cnt) > 0)
    CALL echo(parameter(5,cnt))
    IF (mod(cnt,10)=1)
     SET stat = alterlist(ct_quick_prescreen_request->facility_lst,(cnt+ 9))
    ENDIF
    SET ct_quick_prescreen_request->facility_lst[cnt].facility_cd = parameter(5,cnt)
    SET cnt += 1
  ENDWHILE
  SET stat = alterlist(ct_quick_prescreen_request->facility_lst,(cnt - 1))
 ELSE
  SET stat = alterlist(ct_quick_prescreen_request->facility_lst,1)
  SET ct_quick_prescreen_request->facility_lst[1].facility_cd = parameter(5,1)
 ENDIF
 SET ct_quick_prescreen_request->gender_cd = cnvtreal( $SEX)
 SET ct_quick_prescreen_request->age_qualifier_cd = cnvtreal( $QUALIFIER)
 SET ct_quick_prescreen_request->age1 = cnvtint( $AGE1)
 SET ct_quick_prescreen_request->age2 = cnvtint( $AGE2)
 SET ct_quick_prescreen_request->race_cd = cnvtreal( $RACE)
 SET ct_quick_prescreen_request->ethnic_grp_cd = cnvtreal( $ETHNICITY)
 SET ct_quick_prescreen_request->eval_by =  $EVALBY
 SET ct_quick_prescreen_request->prot_master_id =  $TRIGGERID
 SET terminologycd = cnvtreal( $TERMINOLOGY)
 SET dxcodelist = trim( $CODES,4)
 SET dxcodelist = replace(dxcodelist,'"',"",0)
 SET dxcodelist = replace(dxcodelist,"'","",0)
 SET dxcodelist = cleancsvlist(dxcodelist)
 SET dxcodecnt = 1
 IF (dxcodelist != "")
  SET ct_quick_prescreen_request->terminology_cd = terminologycd
  DECLARE tmp = vc WITH protect, noconstant("")
  DECLARE pieceidx = i4 WITH protect, noconstant(1)
  WHILE (tmp != code_not_found
   AND pieceidx < 100)
    SET tmp = piece(dxcodelist,",",pieceidx,code_not_found)
    SET pieceidx += 1
    IF (tmp != code_not_found)
     SET stat = alterlist(ct_quick_prescreen_request->codes,dxcodecnt)
     SET ct_quick_prescreen_request->codes[dxcodecnt].source_identifier = tmp
     SET dxcodecnt += 1
    ENDIF
  ENDWHILE
 ENDIF
 SUBROUTINE (nextsequence(x=i2) =f8)
   DECLARE nsequence = f8 WITH protect
   SELECT INTO "nl:"
    nextseqnum = seq(protocol_def_seq,nextval)
    FROM dual
    DETAIL
     nsequence = nextseqnum
    WITH nocounter
   ;end select
   RETURN(nsequence)
 END ;Subroutine
 DECLARE prescreen_parent_job_id = f8 WITH protect, noconstant(0)
 DECLARE prot_prescreen_job_id = f8 WITH protect, noconstant(0)
 DECLARE he_job_type = i2 WITH protect, constant(3)
 DECLARE pending_job_status_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17917,"PENDING")
  )
 SET prescreen_parent_job_id = nextsequence(0)
 CALL echo(build("the job id is:",prescreen_parent_job_id))
 INSERT  FROM ct_prescreen_job cpj
  SET cpj.ct_prescreen_job_id = prescreen_parent_job_id, cpj.prsnl_id = reqinfo->updt_id, cpj
   .job_type_flag = he_job_type,
   cpj.job_start_dt_tm = cnvtdatetime(sysdate), cpj.job_status_cd = pending_job_status_cd, cpj
   .long_text_id = 0,
   cpj.updt_cnt = 1, cpj.updt_id = reqinfo->updt_id, cpj.updt_task = reqinfo->updt_task,
   cpj.updt_applctx = reqinfo->updt_applctx, cpj.updt_dt_tm = cnvtdatetime(sysdate)
  WITH nocounter
 ;end insert
 SET prot_prescreen_job_id = nextsequence(0)
 INSERT  FROM ct_prot_prescreen_job_info cji
  SET cji.ct_prot_prescreen_job_info_id = prot_prescreen_job_id, cji.ct_prescreen_job_id =
   prescreen_parent_job_id, cji.prot_master_id =  $TRIGGERID,
   cji.completed_flag = 0, cji.chunk_nbr = 0, cji.updt_cnt = 0,
   cji.updt_id = reqinfo->updt_id, cji.updt_task = reqinfo->updt_task, cji.updt_applctx = reqinfo->
   updt_applctx,
   cji.updt_dt_tm = cnvtdatetime(sysdate)
  WITH nocounter
 ;end insert
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  CALL echo("Transaction error, changes rolled back")
 ELSE
  COMMIT
 ENDIF
 SET ct_quick_prescreen_request->parent_job_id = prescreen_parent_job_id
 CALL echorecord(ct_quick_prescreen_request)
 CALL echo("calling filter script")
 SET stat = tdbexecute(4150006,4150039,4150069,"REC",ct_quick_prescreen_request,
  "REC",reply_out)
 CALL echo(build("status of call: ",stat))
 SUBROUTINE cleancsvlist(csvlist)
   DECLARE cleanedlist = vc WITH protect, noconstant("")
   IF (size(csvlist) > 0)
    DECLARE tmp = vc WITH protect, noconstant("")
    DECLARE pieceidx = i4 WITH protect, noconstant(1)
    DECLARE uniquecnt = i4 WITH protect, noconstant(0)
    DECLARE found = i2 WITH protect, noconstant(0)
    WHILE (tmp != code_not_found
     AND pieceidx < 100)
      SET tmp = piece(csvlist,",",pieceidx,code_not_found)
      SET pieceidx += 1
      IF (tmp != code_not_found
       AND textlen(tmp) > 0)
       SET found = 0
       IF (uniquecnt > 0)
        FOR (i = 1 TO uniquecnt)
          IF ((uniquevalues->list[i].value=tmp))
           SET found = 1
          ENDIF
        ENDFOR
       ENDIF
       IF (found=0)
        SET uniquecnt += 1
        IF (mod(uniquecnt,10)=1)
         SET stat = alterlist(uniquevalues->list,(uniquecnt+ 9))
        ENDIF
        SET uniquevalues->list[uniquecnt].value = tmp
       ENDIF
      ENDIF
    ENDWHILE
    IF (uniquecnt > 0)
     SET stat = alterlist(uniquevalues->list,uniquecnt)
     FOR (i = 1 TO uniquecnt)
       IF (i=1)
        SET cleanedlist = uniquevalues->list[i].value
       ELSE
        SET cleanedlist = build(cleanedlist,",",uniquevalues->list[i].value)
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
   RETURN(cleanedlist)
 END ;Subroutine
END GO
