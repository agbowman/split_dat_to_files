CREATE PROGRAM aps_get_omf_pathologist_list:dba
 SET reply->status_data.status = "F"
 SET v_cv_count = 0
 SET context->start_value = cnvtalphanum(context->start_value)
 SET request->start_value = cnvtalphanum(request->start_value)
 SELECT
  IF (context_ind=1)
   WHERE c.code_set=357
    AND ((c.cdf_meaning="PATHOLGIST") OR (c.cdf_meaning="PATHRESIDENT"))
    AND c.active_ind=1
    AND pg.prsnl_group_type_cd=c.code_value
    AND pg.active_ind=1
    AND pr.prsnl_group_id=pg.prsnl_group_id
    AND pr.active_ind=1
    AND p.person_id=pr.person_id
    AND p.active_ind=1
    AND ((concat(p.name_last_key,p.name_first_key) > cnvtupper(context->start_value)
    AND concat(p.name_last_key,p.name_first_key)=value(concat(cnvtupper(request->start_value),"*")))
    OR (concat(p.name_last_key,p.name_first_key)=cnvtupper(context->start_value)
    AND (((p.name_first_key > context->string1)) OR ((p.name_first_key=context->string1)
    AND (p.person_id > context->num1))) ))
  ELSE
   WHERE c.code_set=357
    AND ((c.cdf_meaning="PATHOLOGIST") OR (c.cdf_meaning="PATHRESIDENT"))
    AND c.active_ind=1
    AND pg.prsnl_group_type_cd=c.code_value
    AND pg.active_ind=1
    AND pr.prsnl_group_id=pg.prsnl_group_id
    AND pr.active_ind=1
    AND p.person_id=pr.person_id
    AND p.active_ind=1
    AND concat(p.name_last_key,p.name_first_key)=value(concat(cnvtupper(request->start_value),"*"))
  ENDIF
  INTO "nl:"
  p.person_id, name_full = concat(trim(p.name_last_key,3),", ",trim(p.name_first_key,3))
  FROM code_value c,
   prsnl_group pg,
   prsnl_group_reltn pr,
   prsnl p
  ORDER BY p.name_last_key, p.name_first_key, p.person_id
  DETAIL
   v_cv_count = (v_cv_count+ 1), stat = alterlist(reply->datacoll,v_cv_count), reply->datacoll[
   v_cv_count].description = name_full,
   reply->datacoll[v_cv_count].currcv = cnvtstring(p.person_id,32,2)
   IF (v_cv_count=maxqualrows)
    context->context_ind = (context->context_ind+ 1), context->start_value = concat(p.name_last_key,p
     .name_first_key), context->string1 = p.name_first_key,
    context->num1 = p.person_id, context->maxqual = maxqualrows
   ENDIF
  WITH nocounter, maxqual(p,value(maxqualrows))
 ;end select
END GO
