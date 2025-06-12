CREATE PROGRAM ch_add_law:dba
 RECORD reply(
   1 law_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET number_to_get = 0
 DECLARE new_nbr = f8 WITH noconstant(0.0)
 DECLARE logical_domain_id = f8 WITH noconstant(0.0)
 SET leaf_new_nbr = 0
 SET x = 0
 SET t = 0
 SET v = 0
 SET z = 0
 SET prov_type_cnt = 0
 SET prov_cnt = 0
 SET code_set = 0
 SET code_display = fillstring(40,"")
 SET code_value = 0.0
 SET reply->status_data.status = "F"
 SET failed = fillstring(1," ")
 SET failed = "F"
 SET active_code = 0.0
 SET code_value1 = 0.0
 SET cdf_meaning1 = fillstring(12," ")
 SET code_set1 = 48
 SET cdf_meaning1 = "ACTIVE"
 SET stat = uar_get_meaning_by_codeset(code_set1,cdf_meaning1,1,code_value1)
 SET active_code = code_value1
 IF ((request->requesting_prsnl_id > 0.0))
  SELECT INTO "NL:"
   p.logical_domain_id
   FROM prsnl p,
    logical_domain ld
   PLAN (p
    WHERE (p.person_id=request->requesting_prsnl_id))
    JOIN (ld
    WHERE ld.logical_domain_id=p.logical_domain_id)
   DETAIL
    logical_domain_id = p.logical_domain_id
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  y = seq(reference_seq,nextval)
  FROM dual
  DETAIL
   new_nbr = y
  WITH format, counter
 ;end select
 IF (curqual=0)
  SET failed = "T"
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
  SET failed = "F"
  SET reply->law_id = new_nbr
 ENDIF
 INSERT  FROM chart_law c
  SET c.law_id = new_nbr, c.law_descr = request->chart_law[1].law_descr, c.lookback_days = request->
   chart_law[1].lookback_days,
   c.lookback_type_ind = request->chart_law[1].lookback_type_ind, c.active_ind = 1, c
   .active_status_cd = active_code,
   c.active_status_prsnl_id = reqinfo->updt_id, c.active_status_dt_tm = cnvtdatetime(curdate,curtime3
    ), c.updt_cnt = 0,
   c.updt_dt_tm = cnvtdatetime(curdate,curtime), c.updt_id = reqinfo->updt_id, c.updt_applctx =
   reqinfo->updt_applctx,
   c.updt_task = reqinfo->updt_task, c.logical_domain_id = logical_domain_id
  WITH nocounter
 ;end insert
 IF (curqual > 0)
  CALL echo(concat("insert chart law: ",cnvtstring(new_nbr)))
 ENDIF
 SET number_to_get = size(request->chart_law[1].law_filter,5)
 FOR (z = 1 TO number_to_get)
   INSERT  FROM chart_law_filter clf
    SET clf.law_id = new_nbr, clf.type_flag = request->chart_law[1].law_filter[z].type_flag, clf
     .included_flag = request->chart_law[1].law_filter[z].include_flag,
     clf.active_ind = 1, clf.active_status_cd = active_code, clf.active_status_prsnl_id = reqinfo->
     updt_id,
     clf.active_status_dt_tm = cnvtdatetime(curdate,curtime3), clf.updt_cnt = 0, clf.updt_dt_tm =
     cnvtdatetime(curdate,curtime),
     clf.updt_id = reqinfo->updt_id, clf.updt_applctx = reqinfo->updt_applctx, clf.updt_task =
     reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (curqual > 0)
    CALL echo(concat("insert chart_law_filter: ",cnvtstring(new_nbr)))
   ENDIF
   SET sequence = 0
   IF ((request->chart_law[1].law_filter[z].type_flag=2))
    SET prov_cnt = size(request->chart_law[1].prov_filter,5)
    FOR (x = 1 TO prov_cnt)
     SET prov_type_cnt = size(request->chart_law[1].prov_filter[x].qual,5)
     FOR (t = 1 TO prov_type_cnt)
      SET sequence = (sequence+ 1)
      INSERT  FROM chart_law_filter_value clfv
       SET clfv.description = request->chart_law[1].law_filter[z].filter_value[x].filter_description,
        clfv.law_id = new_nbr, clfv.type_flag = request->chart_law[1].law_filter[z].type_flag,
        clfv.key_sequence = sequence, clfv.parent_entity_id = request->chart_law[1].law_filter[z].
        filter_value[x].filter_value_cd, clfv.parent_entity_name = evaluate(request->chart_law[1].
         law_filter[z].type_flag,1,"ORGANIZATION",2,"PRSNL",
         "CODE_VALUE"),
        clfv.reltn_type_cd = request->chart_law[1].prov_filter[x].qual[t].prov_type_cd, clfv
        .active_ind = 1, clfv.active_status_cd = active_code,
        clfv.active_status_dt_tm = cnvtdatetime(curdate,curtime3), clfv.active_status_prsnl_id =
        reqinfo->updt_id, clfv.updt_cnt = 0,
        clfv.updt_dt_tm = cnvtdatetime(curdate,curtime), clfv.updt_id = reqinfo->updt_id, clfv
        .updt_applctx = reqinfo->updt_applctx,
        clfv.updt_task = reqinfo->updt_task
      ;end insert
     ENDFOR
    ENDFOR
   ELSE
    SET filter_values_to_get = size(request->chart_law[1].law_filter[z].filter_value,5)
    FOR (y = 1 TO filter_values_to_get)
     SET sequence = (sequence+ 1)
     INSERT  FROM chart_law_filter_value clfv
      SET clfv.law_id = new_nbr, clfv.description = request->chart_law[1].law_filter[z].filter_value[
       y].filter_description, clfv.type_flag = request->chart_law[1].law_filter[z].type_flag,
       clfv.key_sequence = sequence, clfv.parent_entity_id = request->chart_law[1].law_filter[z].
       filter_value[y].filter_value_cd, clfv.parent_entity_name = evaluate(request->chart_law[1].
        law_filter[z].type_flag,1,"ORGANIZATION",2,"PRSNL",
        "CODE_VALUE"),
       clfv.reltn_type_cd = 0.0, clfv.active_ind = 1, clfv.active_status_cd = active_code,
       clfv.active_status_dt_tm = cnvtdatetime(curdate,curtime3), clfv.active_status_prsnl_id =
       reqinfo->updt_id, clfv.updt_cnt = 0,
       clfv.updt_dt_tm = cnvtdatetime(curdate,curtime), clfv.updt_id = reqinfo->updt_id, clfv
       .updt_applctx = reqinfo->updt_applctx,
       clfv.updt_task = reqinfo->updt_task
     ;end insert
    ENDFOR
   ENDIF
 ENDFOR
 IF ((reply->status_data.status="Z"))
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "Z"
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
  SET reply->law_id = new_nbr
 ENDIF
END GO
