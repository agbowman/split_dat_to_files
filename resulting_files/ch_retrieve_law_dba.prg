CREATE PROGRAM ch_retrieve_law:dba
 RECORD reply(
   1 law_id = f8
   1 lookback_days = i4
   1 lookback_type_ind = i2
   1 law_filter[*]
     2 type_flag = i2
     2 included_flag = i2
     2 filter_value[*]
       3 filter_value_cd = f8
       3 filter_description = vc
       3 cdf_meaning = c12
   1 prov_filter[*]
     2 provider_id = f8
     2 provider_name = vc
     2 qual[*]
       3 prov_type_cd = f8
   1 related_ops[*]
     2 batch_name = vc
   1 last_update = vc
   1 no_label_updt_dt_tm = dq8
   1 modifier_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD prov_array
 RECORD prov_array(
   1 qual[*]
     2 provider_id = f8
     2 provider_name = vc
     2 reltn_type[*]
       3 prov_type_cd = f8
 )
 SET reply->status_data.status = "F"
 SET qual_cnt = 0
 DECLARE start_name = f8 WITH noconstant(0.0)
 SET filter_count = 0
 SET filter_value_count = 0
 SET start_name = request->start_name
 SET size_of_prov = 0
 SELECT INTO "nl:"
  p.name_full_formatted, name = trim(substring(1,30,p.name_full_formatted)), cl.updt_dt_tm
  FROM chart_law cl,
   prsnl p
  PLAN (cl
   WHERE cl.law_id=start_name)
   JOIN (p
   WHERE p.person_id=cl.updt_id)
  HEAD REPORT
   reply->last_update = fillstring(100," ")
  DETAIL
   reply->last_update = concat("Last modified by: ",trim(name),"  (",format(cl.updt_dt_tm,
     "mm/dd/yyyy"),")"), reply->no_label_updt_dt_tm = cl.updt_dt_tm, reply->modifier_name = trim(name
    )
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM chart_law_filter_value clfv
  WHERE clfv.law_id=start_name
   AND clfv.type_flag=2
  ORDER BY clfv.description, clfv.parent_entity_id
  HEAD REPORT
   distinct_prov_id_cnt = 0
  HEAD clfv.parent_entity_id
   cnt1 = 0, distinct_prov_id_cnt += 1, stat = alterlist(prov_array->qual,distinct_prov_id_cnt),
   prov_array->qual[distinct_prov_id_cnt].provider_id = clfv.parent_entity_id, prov_array->qual[
   distinct_prov_id_cnt].provider_name = clfv.description
  DETAIL
   cnt1 += 1, stat = alterlist(prov_array->qual[distinct_prov_id_cnt].reltn_type,cnt1), prov_array->
   qual[distinct_prov_id_cnt].reltn_type[cnt1].prov_type_cd = clfv.reltn_type_cd
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  c.law_id, clf.type_flag, clfv.parent_entity_id
  FROM chart_law c,
   chart_law_filter clf,
   chart_law_filter_value clfv,
   (dummyt t1  WITH seq = 1),
   (dummyt t2  WITH seq = 1),
   dummyt d1,
   dummyt d2,
   organization o
  PLAN (c
   WHERE c.law_id=start_name
    AND c.active_ind=1)
   JOIN (t1)
   JOIN (clf
   WHERE clf.law_id=c.law_id)
   JOIN (t2)
   JOIN (clfv
   WHERE clfv.law_id=clf.law_id
    AND clfv.type_flag=clf.type_flag)
   JOIN (d1)
   JOIN (d2)
   JOIN (o
   WHERE o.organization_id=clfv.parent_entity_id)
  ORDER BY clfv.type_flag, clfv.description
  HEAD REPORT
   reply->law_id = c.law_id, reply->lookback_days = c.lookback_days, reply->lookback_type_ind = c
   .lookback_type_ind
  HEAD clf.type_flag
   filter_value_count = 0, filter_count += 1
   IF (mod(filter_count,10)=1)
    stat = alterlist(reply->law_filter[filter_count],(filter_count+ 10))
   ENDIF
   reply->law_filter[filter_count].type_flag = clf.type_flag, reply->law_filter[filter_count].
   included_flag = clf.included_flag
  DETAIL
   IF (clfv.type_flag != 2)
    filter_value_count += 1
    IF (mod(filter_value_count,10)=1)
     stat = alterlist(reply->law_filter[filter_count].filter_value,(filter_value_count+ 10))
    ENDIF
    reply->law_filter[filter_count].filter_value[filter_value_count].filter_value_cd = clfv
    .parent_entity_id
    IF (clfv.type_flag IN (0, 3, 4, 5))
     reply->law_filter[filter_count].filter_value[filter_value_count].filter_description =
     uar_get_code_display(clfv.parent_entity_id)
    ELSEIF (clfv.type_flag IN (1))
     reply->law_filter[filter_count].filter_value[filter_value_count].filter_description = o.org_name
    ENDIF
    IF (clfv.type_flag=3)
     reply->law_filter[filter_count].filter_value[filter_value_count].cdf_meaning =
     uar_get_code_meaning(clfv.parent_entity_id)
    ELSE
     reply->law_filter[filter_count].filter_value[filter_value_count].cdf_meaning = " "
    ENDIF
   ENDIF
  FOOT  clf.type_flag
   stat = alterlist(reply->law_filter[filter_count].filter_value,filter_value_count)
  WITH nocounter, outerjoin = d1, outerjoin = d2,
   dontcare = o
 ;end select
 SET qual_cnt = curqual
 SET stat = alterlist(reply->law_filter[filter_count],filter_count)
 SET size_of_prov = size(prov_array->qual,5)
 FOR (x = 1 TO size_of_prov)
   SET stat = alterlist(reply->prov_filter,x)
   SET reply->prov_filter[x].provider_id = prov_array->qual[x].provider_id
   SET reply->prov_filter[x].provider_name = prov_array->qual[x].provider_name
   SET size_of_types = size(prov_array->qual[x].reltn_type,5)
   FOR (y = 1 TO size_of_types)
    SET stat = alterlist(reply->prov_filter[x].qual,y)
    SET reply->prov_filter[x].qual[y].prov_type_cd = prov_array->qual[x].reltn_type[y].prov_type_cd
   ENDFOR
 ENDFOR
 SELECT DISTINCT INTO "nl:"
  co.batch_name
  FROM charting_operations co
  WHERE co.active_ind=1
   AND co.param_type_flag=18
   AND co.param=cnvtstring(reply->law_id)
  HEAD REPORT
   rel_cnt = 0
  DETAIL
   rel_cnt += 1, stat = alterlist(reply->related_ops,rel_cnt), reply->related_ops[rel_cnt].batch_name
    = co.batch_name
  WITH nocounter
 ;end select
 SET size_rel = 0
 SET size_rel = size(reply->related_ops,5)
 IF (size_rel > 0)
  CALL echo(reply->related_ops[1].batch_name)
 ELSE
  CALL echo("no reltns found")
 ENDIF
 IF (qual_cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
