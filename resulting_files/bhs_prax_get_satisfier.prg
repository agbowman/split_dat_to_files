CREATE PROGRAM bhs_prax_get_satisfier
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 DECLARE idx = i4 WITH protect, noconstant(0)
 FREE RECORD result
 RECORD result(
   1 filter_type_cd = f8
   1 filter_type_disp = vc
   1 reasons[*]
     2 reason_cd = f8
     2 reason_disp = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE RECORD req4290300
 RECORD req4290300(
   1 all_effect_ind = i2
   1 filter_entity_reltn_idw = i2
   1 parent_entity_namew = i2
   1 parent_entity_idw = i2
   1 filter_entity1_namew = i2
   1 filter_entity1_idw = i2
   1 filter_entity2_namew = i2
   1 filter_entity2_idw = i2
   1 filter_entity3_namew = i2
   1 filter_entity3_idw = i2
   1 filter_entity4_namew = i2
   1 filter_entity4_idw = i2
   1 filter_entity5_namew = i2
   1 filter_entity5_idw = i2
   1 filter_typew = i2
   1 filter_type_cdw = i2
   1 exclusion_filter_indw = i2
   1 qual[*]
     2 filter_entity_reltn_id = f8
     2 parent_entity_name = vc
     2 parent_entity_id = f8
     2 filter_entity1_id = f8
     2 filter_entity1_name = vc
     2 filter_entity2_id = f8
     2 filter_entity2_name = vc
     2 filter_entity3_id = f8
     2 filter_entity3_name = vc
     2 filter_entity4_id = f8
     2 filter_entity4_name = vc
     2 filter_entity5_id = f8
     2 filter_entity5_name = vc
     2 filter_type = vc
     2 filter_type_cd = f8
     2 exclusion_filter_ind = i2
 ) WITH protect
 FREE RECORD rep4290300
 RECORD rep4290300(
   1 reltn_qual[*]
     2 qual[*]
       3 filter_entity_reltn_id = f8
       3 parent_entity_name = vc
       3 parent_entity_id = f8
       3 parent_entity_display = vc
       3 filter_entity1_name = vc
       3 filter_entity1_id = f8
       3 filter_entity2_name = vc
       3 filter_entity2_id = f8
       3 filter_entity3_name = vc
       3 filter_entity3_id = f8
       3 filter_entity4_name = vc
       3 filter_entity4_id = f8
       3 filter_entity5_name = vc
       3 filter_entity5_id = f8
       3 filter_type_cd = f8
       3 exclusion_filter_ind = i2
       3 beg_effective_dt_tm = q8
       3 end_effective_dt_tm = q8
       3 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 IF (( $3 <= 0.0))
  CALL echo("INVALID SATISFIER TYPE CODE...EXITING")
  GO TO exit_script
 ENDIF
 DECLARE c_expirereasons_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",30620,
   "EXPIREREASONS"))
 DECLARE c_postponereasons_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",30620,
   "POSTPONEREASONS"))
 DECLARE c_refusereasons_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",30620,
   "REFUSEREASONS"))
 DECLARE c_satisfyreasons_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",30620,
   "SATISFYREASONS"))
 DECLARE c_expire_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",30280,"EXPIRE"))
 DECLARE c_postpone_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",30280,"POSTPONE"))
 DECLARE c_refuse_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",30280,"REFUSE"))
 DECLARE c_manual_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",30280,"MANUAL"))
 CALL echo(build("SATISFIER TYPE=",uar_get_code_display(cnvtreal( $3))))
 SET result->filter_type_cd = evaluate(cnvtreal( $3),c_expire_cd,c_expirereasons_cd,c_postpone_cd,
  c_postponereasons_cd,
  c_refuse_cd,c_refusereasons_cd,c_manual_cd,c_satisfyreasons_cd,0.0)
 SET result->filter_type_disp = uar_get_code_display(result->filter_type_cd)
 CALL echo(build("RESULT->FILTER_TYPE_CD=",result->filter_type_cd))
 CALL echo(build("RESULT->FILTER_TYPE_DISP=",result->filter_type_disp))
 DECLARE reason_cnt = i4 WITH protect, noconstant(0)
 DECLARE applicationid = i4 WITH protect, constant(600005)
 DECLARE taskid = i4 WITH protect, constant(4290390)
 DECLARE requestid = i4 WITH protect, constant(4290300)
 IF (( $2 > 0))
  SET req4290300->filter_entity1_namew = 1
  SET req4290300->filter_entity1_idw = 1
  SET req4290300->filter_type_cdw = 1
  SET stat = alterlist(req4290300->qual,1)
  SET req4290300->qual[1].filter_entity1_name = "HM_EXPECT_SAT"
  SET req4290300->qual[1].filter_entity1_id =  $2
  SET req4290300->qual[1].filter_type_cd = result->filter_type_cd
  CALL echo(build("TDBEXECUTE FOR ",requestid))
  SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req4290300,
   "REC",rep4290300,1)
  IF (stat > 0)
   SET errcode = error(errmsg,1)
   CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
     errmsg))
   GO TO exit_script
  ENDIF
  CALL echorecord(rep4290300)
 ENDIF
 IF ((rep4290300->status_data.status="S"))
  IF (size(rep4290300->reltn_qual,5) > 0)
   SET stat = alterlist(result->reasons,size(rep4290300->reltn_qual[1].qual,5))
   FOR (idx = 1 TO size(rep4290300->reltn_qual[1].qual,5))
    SET result->reasons[idx].reason_cd = rep4290300->reltn_qual[1].qual[idx].parent_entity_id
    SET result->reasons[idx].reason_disp = uar_get_code_display(result->reasons[idx].reason_cd)
   ENDFOR
  ENDIF
 ELSE
  IF ((result->filter_type_cd > 0))
   SELECT INTO "NL:"
    FROM filter_type ft,
     code_value cv,
     code_value_extension cve
    PLAN (ft
     WHERE (ft.filter_type_cd=result->filter_type_cd))
     JOIN (cv
     WHERE cv.code_set=ft.parent_type_id
      AND cv.active_ind=1)
     JOIN (cve
     WHERE cve.code_value=outerjoin(cv.code_value))
    ORDER BY cv.display
    HEAD cv.code_value
     IF (((cve.code_value=0) OR (((cve.field_name != "IMMUNIZATIONIND") OR (cve.field_value != "1"))
     )) )
      reason_cnt = (reason_cnt+ 1), stat = alterlist(result->reasons,reason_cnt), result->reasons[
      reason_cnt].reason_cd = cv.code_value,
      result->reasons[reason_cnt].reason_disp = cv.display
     ENDIF
    WITH nocounter, time = 30
   ;end select
  ENDIF
 ENDIF
 SET result->status_data.status = "S"
 CALL echorecord(result)
#exit_script
 IF (size(trim(moutputdevice,3)) > 0)
  DECLARE v1 = vc WITH protect, noconstant("")
  DECLARE v2 = vc WITH protect, noconstant("")
  IF ((result->status_data.status="S"))
   SELECT INTO value(moutputdevice)
    FROM (dummyt d  WITH seq = value(1))
    PLAN (d
     WHERE d.seq > 0)
    HEAD REPORT
     html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
      '"',"UTF-8",'"'," ?>"), col 0, html_tag,
     row + 1, col + 1, "<ReplyMessage>",
     row + 1
    DETAIL
     col + 1, "<Reasons>", row + 1
     FOR (idx = 1 TO size(result->reasons,5))
       col + 1, "<Reason>", row + 1,
       v1 = build("<ReasonCd>",cnvtint(result->reasons[idx].reason_cd),"</ReasonCd>"), col + 1, v1,
       row + 1, v2 = build("<ReasonDisp>",trim(replace(replace(replace(replace(replace(result->
              reasons[idx].reason_disp,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
          "&quot;",0),3),"</ReasonDisp>"), col + 1,
       v2, row + 1, col + 1,
       "</Reason>", row + 1
     ENDFOR
     col + 1, "</Reasons>", row + 1
    FOOT REPORT
     col + 1, "</ReplyMessage>", row + 1
    WITH maxcol = 32000, nocounter, nullreport,
     formfeed = none, format = variable, time = 30
   ;end select
  ENDIF
 ENDIF
 FREE RECORD req4290300
 FREE RECORD rep4290300
END GO
