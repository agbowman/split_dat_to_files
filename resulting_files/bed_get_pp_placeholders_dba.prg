CREATE PROGRAM bed_get_pp_placeholders:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 comp_types[*]
      2 comp_type_flag = i2
      2 placeholders[*]
        3 placeholder_id = f8
        3 name = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE SET temp_p
 RECORD temp_p(
   1 comp_types[*]
     2 comp_type_flag = i2
     2 placeholders[*]
       3 placeholder_id = f8
       3 name = vc
       3 valid_reltns = i2
 )
 DECLARE req_size = i4 WITH noconstant(0), protect
 SET reply->status_data.status = "F"
 SET req_size = size(request->comp_types,5)
 IF (req_size=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->comp_types,req_size)
 SET stat = alterlist(temp_p->comp_types,req_size)
 FOR (x = 1 TO req_size)
  SET reply->comp_types[x].comp_type_flag = request->comp_types[x].comp_type_flag
  SET temp_p->comp_types[x].comp_type_flag = request->comp_types[x].comp_type_flag
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(req_size)),
   br_pw_comp_placehldr p
  PLAN (d)
   JOIN (p
   WHERE (p.comp_type_flag=temp_p->comp_types[d.seq].comp_type_flag))
  ORDER BY d.seq
  HEAD d.seq
   cnt = 0, tcnt = 0, stat = alterlist(temp_p->comp_types[d.seq].placeholders,10)
  DETAIL
   cnt = (cnt+ 1), tcnt = (tcnt+ 1)
   IF (cnt > 10)
    stat = alterlist(temp_p->comp_types[d.seq].placeholders,(tcnt+ 10)), cnt = 1
   ENDIF
   temp_p->comp_types[d.seq].placeholders[tcnt].name = p.placehldr_name, temp_p->comp_types[d.seq].
   placeholders[tcnt].placeholder_id = p.br_pw_comp_placehldr_id
  FOOT  d.seq
   stat = alterlist(temp_p->comp_types[d.seq].placeholders,tcnt)
  WITH nocounter
 ;end select
 IF ((request->return_placeholders_w_reltns=1))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(req_size)),
    (dummyt d2  WITH seq = 1),
    br_pw_comp_placehldr_r r,
    pathway_comp p,
    pathway_catalog c,
    pw_cat_reltn pw_reltn,
    pathway_catalog pw_cat_pp
   PLAN (d
    WHERE maxrec(d2,size(temp_p->comp_types[d.seq].placeholders,5)))
    JOIN (d2)
    JOIN (r
    WHERE (r.br_pw_comp_placehldr_id=temp_p->comp_types[d.seq].placeholders[d2.seq].placeholder_id))
    JOIN (p
    WHERE p.pathway_uuid=r.pathway_uuid
     AND p.parent_entity_name="LONG_TEXT"
     AND p.active_ind=1)
    JOIN (c
    WHERE c.pathway_catalog_id=p.pathway_catalog_id
     AND c.active_ind=1
     AND c.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (pw_reltn
    WHERE pw_reltn.pw_cat_t_id=outerjoin(c.pathway_catalog_id)
     AND pw_reltn.type_mean=outerjoin("GROUP"))
    JOIN (pw_cat_pp
    WHERE pw_cat_pp.pathway_catalog_id=outerjoin(pw_reltn.pw_cat_s_id)
     AND pw_cat_pp.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
   ORDER BY d.seq, d2.seq, pw_cat_pp.pathway_catalog_id,
    c.pathway_catalog_id
   HEAD d.seq
    x = 1
   HEAD d2.seq
    x = 1
   HEAD pw_cat_pp.pathway_catalog_id
    IF (pw_cat_pp.pathway_catalog_id != 0
     AND c.type_mean="PHASE"
     AND c.ref_owner_person_id=0.0)
     temp_p->comp_types[d.seq].placeholders[d2.seq].valid_reltns = 1
    ENDIF
   HEAD c.pathway_catalog_id
    IF (pw_cat_pp.pathway_catalog_id=0
     AND c.type_mean="CAREPLAN"
     AND c.ref_owner_person_id=0.0)
     temp_p->comp_types[d.seq].placeholders[d2.seq].valid_reltns = 1
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 FOR (x = 1 TO req_size)
   SET p_size = size(temp_p->comp_types[x].placeholders,5)
   SET stat = alterlist(reply->comp_types[x].placeholders,p_size)
   SET cnt = 0
   FOR (y = 1 TO p_size)
     IF ((((request->return_placeholders_w_reltns=0)) OR ((temp_p->comp_types[x].placeholders[y].
     valid_reltns=1))) )
      SET cnt = (cnt+ 1)
      SET reply->comp_types[x].placeholders[cnt].name = temp_p->comp_types[x].placeholders[y].name
      SET reply->comp_types[x].placeholders[cnt].placeholder_id = temp_p->comp_types[x].placeholders[
      y].placeholder_id
     ENDIF
   ENDFOR
   SET stat = alterlist(reply->comp_types[x].placeholders,cnt)
 ENDFOR
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
