CREATE PROGRAM dcp_get_outcome_cat_all:dba
 SET modify = predeclare
 RECORD reply(
   1 list[*]
     2 description = vc
     2 expectation = vc
     2 outcome_catalog_id = f8
     2 outcome_class_cd = f8
     2 outcome_class_disp = c40
     2 outcome_class_mean = c12
     2 task_assay_cd = f8
     2 task_assay_disp = c40
     2 task_assay_mean = c12
     2 outcome_type_cd = f8
     2 outcome_type_disp = c40
     2 outcome_type_mean = c12
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE num = i4 WITH noconstant(0)
 DECLARE noutcometypelistcnt = i4 WITH noconstant(0)
 DECLARE ssearchstring = vc WITH noconstant(cnvtupper(cnvtalphanum(request->search_string)))
 DECLARE cfailed = c1 WITH noconstant("F")
 DECLARE where_clause = vc WITH noconstant(fillstring(500,""))
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE is_outcome_available_for_facility(null) = null
 DECLARE i18nhandle = i4 WITH noconstant(0)
 DECLARE highbuffer = c20 WITH noconstant(fillstring(20," "))
 DECLARE highvalue = vc
 DECLARE lowbuffer = c20 WITH noconstant(fillstring(20," "))
 DECLARE lowvalue = vc
 SET noutcometypelistcnt = size(request->type_filter_list,5)
 IF ((request->task_assay_cd > 0))
  SET where_clause = "oc.task_assay_cd = request->task_assay_cd"
 ELSE
  SET i18nhandle = uar_i18nalphabet_init()
  CALL uar_i18nalphabet_highchar(i18nhandle,highbuffer,size(highbuffer))
  SET highvalue = trim(concat(substring(1,1,ssearchstring),highbuffer))
  IF (value(size(request->search_string,1)) >= 3)
   SET where_clause = concat("oc.description_key LIKE '*",ssearchstring,"*'")
  ELSEIF ((request->search_string > " "))
   SET where_clause = "oc.description_key BETWEEN trim(sSearchString) AND highValue"
  ELSE
   CALL uar_i18nalphabet_lowalnum(i18nhandle,lowbuffer,size(lowbuffer))
   SET lowvalue = trim(lowbuffer)
   SET where_clause = "oc.description_key BETWEEN lowValue AND highValue"
   SET where_clause = concat(where_clause," and oc.outcome_catalog_id > 0.0")
  ENDIF
  CALL uar_i18nalphabet_end(i18nhandle)
 ENDIF
 IF (noutcometypelistcnt > 0)
  SET where_clause = concat(where_clause,
   " and expand(num,1,nOutcomeTypeListCnt,oc.outcome_type_cd,request->type_filter_list[num]->outcome_type_cd)"
   )
 ENDIF
 IF ((request->outcome_class_cd > 0))
  SET where_clause = concat(where_clause," and oc.outcome_class_cd = request->outcome_class_cd")
 ENDIF
 SELECT INTO "nl:"
  FROM outcome_catalog oc
  PLAN (oc
   WHERE parser(where_clause))
  ORDER BY oc.description_key, oc.expectation_key
  HEAD REPORT
   cnt = 0
  DETAIL
   IF ((((request->filter_on_active_ind != 1)) OR ((request->filter_on_active_ind=1)
    AND oc.active_ind=1)) )
    cnt = (cnt+ 1)
    IF (cnt > size(reply->list,5))
     stat = alterlist(reply->list,(cnt+ 10))
    ENDIF
    reply->list[cnt].description = trim(oc.description), reply->list[cnt].expectation = trim(oc
     .expectation), reply->list[cnt].outcome_catalog_id = oc.outcome_catalog_id,
    reply->list[cnt].outcome_class_cd = oc.outcome_class_cd, reply->list[cnt].task_assay_cd = oc
    .task_assay_cd, reply->list[cnt].outcome_type_cd = oc.outcome_type_cd
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->list,cnt)
  WITH nocounter
 ;end select
 IF ((request->location_cd > 0.00))
  CALL is_outcome_available_for_facility(null)
 ENDIF
 SUBROUTINE is_outcome_available_for_facility(null)
   DECLARE availableatallfacility = i4 WITH noconstant(0), protect
   DECLARE availableatgivenfacility = i4 WITH noconstant(0), protect
   DECLARE outcomecnt = i4 WITH noconstant(0), protect
   DECLARE outcomeidx = i4 WITH noconstant(0), protect
   DECLARE outidx = i4 WITH noconstant(0), protect
   SET outcomecnt = size(reply->list,5)
   SELECT INTO "n1:"
    oclr.*
    FROM outcome_cat_loc_reltn oclr
    WHERE expand(outcomeidx,1,size(reply->list,5),oclr.outcome_catalog_id,reply->list[outcomeidx].
     outcome_catalog_id)
    ORDER BY oclr.outcome_catalog_id, oclr.location_cd
    HEAD REPORT
     availableatallfacility = 1, availableatgivenfacility = 0
    HEAD oclr.outcome_catalog_id
     availableatallfacility = 0, outidx = locateval(outidx,1,value(outcomecnt),oclr
      .outcome_catalog_id,reply->list[outidx].outcome_catalog_id)
    DETAIL
     IF ((oclr.location_cd=request->location_cd))
      availableatgivenfacility = 1
     ENDIF
    FOOT  oclr.outcome_catalog_id
     IF (availableatallfacility=0
      AND availableatgivenfacility=0)
      outcomecnt = (outcomecnt - 1), outidx = (outidx - 1), stat = alterlist(reply->list,outcomecnt,
       outidx)
     ENDIF
     availableatallfacility = 1, availableatgivenfacility = 0
    WITH nocounter
   ;end select
 END ;Subroutine
 IF (cfailed="T")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET last_mod = "006"
END GO
