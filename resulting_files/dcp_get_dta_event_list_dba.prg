CREATE PROGRAM dcp_get_dta_event_list:dba
 SET modify = predeclare
 RECORD reply(
   1 list[*]
     2 task_assay_cd = f8
     2 task_assay_disp = c40
     2 task_assay_mean = c12
     2 mnemonic = c50
     2 description = c100
     2 result_type_cd = f8
     2 result_type_disp = c40
     2 result_type_mean = c12
     2 event_cd = f8
     2 event_disp = c40
     2 event_mean = c12
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE max_rows = i4 WITH constant(100)
 DECLARE num = i4 WITH noconstant(0)
 DECLARE high = i4 WITH noconstant(size(request->typelist,5))
 DECLARE buffer = c11 WITH protect, noconstant(fillstring(11," "))
 DECLARE cfailed = c1 WITH noconstant("F")
 DECLARE ssearch = vc WITH protect, noconstant(cnvtupper(trim(request->search_string,3)))
 DECLARE last_mod = c3 WITH protect, noconstant("000")
 DECLARE i18nhandle = i4 WITH protect, noconstant(0)
 SET i18nhandle = uar_i18nalphabet_init()
 CALL uar_i18nalphabet_highchar(i18nhandle,buffer,size(buffer))
 DECLARE highvalues = vc WITH protect, constant(cnvtupper(trim(buffer)))
 IF (textlen(ssearch)=0)
  SET buffer = fillstring(11," ")
  CALL uar_i18nalphabet_lowchar(i18nhandle,buffer,size(buffer))
  SET ssearch = cnvtupper(trim(buffer))
 ENDIF
 CALL uar_i18nalphabet_end(i18nhandle)
 SELECT
  IF (high > 0)
   PLAN (dta
    WHERE dta.mnemonic_key_cap BETWEEN ssearch AND highvalues
     AND expand(num,1,high,dta.default_result_type_cd,request->typelist[num].result_type_cd)
     AND dta.active_ind=1)
  ELSE
   PLAN (dta
    WHERE dta.mnemonic_key_cap BETWEEN ssearch AND highvalues
     AND dta.active_ind=1)
  ENDIF
  INTO "nl:"
  FROM discrete_task_assay dta
  ORDER BY dta.mnemonic_key_cap
  HEAD REPORT
   cnt = 0, stat = alterlist(reply->list,max_rows)
  DETAIL
   cnt = (cnt+ 1)
   IF (cnt <= max_rows)
    reply->list[cnt].task_assay_cd = dta.task_assay_cd, reply->list[cnt].mnemonic = dta.mnemonic,
    reply->list[cnt].description = dta.description,
    reply->list[cnt].result_type_cd = dta.default_result_type_cd, reply->list[cnt].event_cd = dta
    .event_cd
   ENDIF
  FOOT REPORT
   IF (cnt < max_rows)
    stat = alterlist(reply->list,cnt)
   ENDIF
  WITH nocounter
 ;end select
 IF (cfailed="T")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET modify = nopredeclare
 SET last_mod = "004"
END GO
