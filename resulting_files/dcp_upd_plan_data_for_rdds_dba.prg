CREATE PROGRAM dcp_upd_plan_data_for_rdds:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "FAIL:dcp_upd_plan_data_for_rdds.prg failed"
 FREE RECORD internal
 RECORD internal(
   1 list[*]
     2 pathway_catalog_id = f8
     2 version_pw_cat_id = f8
     2 description = vc
 )
 FREE RECORD os
 RECORD os(
   1 list[*]
     2 order_sentence_id = f8
     2 pathway_comp_id = f8
     2 iv_comp_syn_id = f8
 )
 SELECT INTO "nl:"
  pwc.description, pwc.pathway_catalog_id, pwc.version_pw_cat_id,
  pwc.active_ind
  FROM pathway_catalog pwc
  WHERE pwc.type_mean IN ("PATHWAY", "CAREPLAN")
   AND pwc.ref_owner_person_id=0
   AND pwc.end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
  ORDER BY pwc.description, pwc.active_ind DESC
  HEAD REPORT
   cnt = 0
  HEAD pwc.description
   prev_description = fillstring(100,""), curr_description = fillstring(100,""), description =
   fillstring(100,""),
   act_cnt = 0, inact_cnt = 0, first_inact_idx = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (cnt > size(internal->list,5))
    stat = alterlist(internal->list,(cnt+ 100))
   ENDIF
   internal->list[cnt].pathway_catalog_id = pwc.pathway_catalog_id, internal->list[cnt].
   version_pw_cat_id = pwc.version_pw_cat_id, curr_description = trim(pwc.description)
   IF (pwc.active_ind=0
    AND first_inact_idx=0)
    first_inact_idx = cnt
   ENDIF
   IF (curr_description=prev_description)
    IF (pwc.active_ind=0)
     inact_cnt = (inact_cnt+ 1)
     IF (first_inact_idx != cnt)
      description = build(trim(curr_description)," (",(inact_cnt+ 101),")")
     ELSE
      description = build(trim(curr_description)," (",(inact_cnt+ 100),")")
     ENDIF
     IF (inact_cnt=1
      AND first_inact_idx > 1)
      internal->list[first_inact_idx].description = build(trim(curr_description)," (101)")
     ENDIF
    ELSE
     act_cnt = (act_cnt+ 1)
     IF (act_cnt > 0)
      description = build(trim(curr_description)," (",(act_cnt+ 200),")")
     ELSE
      description = trim(curr_description)
     ENDIF
    ENDIF
    internal->list[cnt].description = description
   ELSE
    internal->list[cnt].description = trim(curr_description)
   ENDIF
   prev_description = trim(curr_description)
  FOOT  pwc.description
   prev_description = "", curr_description = ""
  FOOT REPORT
   stat = alterlist(internal->list,cnt)
  WITH nocounter
 ;end select
 FOR (i = 1 TO value(size(internal->list,5)))
  IF ((internal->list[i].version_pw_cat_id=0))
   UPDATE  FROM pathway_catalog pc
    SET pc.version_pw_cat_id = internal->list[i].pathway_catalog_id
    WHERE (pc.pathway_catalog_id=internal->list[i].pathway_catalog_id)
   ;end update
   SET internal->list[i].version_pw_cat_id = internal->list[i].pathway_catalog_id
  ENDIF
  UPDATE  FROM pathway_catalog pc
   SET pc.description = trim(internal->list[i].description), pc.description_key = trim(cnvtupper(
      internal->list[i].description))
   WHERE (pc.version_pw_cat_id=internal->list[i].version_pw_cat_id)
  ;end update
 ENDFOR
 FREE RECORD internal
 SELECT INTO "nl:"
  FROM pathway_catalog pwc,
   pathway_comp pc,
   pw_comp_os_reltn pcor,
   order_sentence os
  PLAN (pwc
   WHERE pwc.type_mean IN ("PATHWAY", "CAREPLAN")
    AND pwc.end_effective_dt_tm=cnvtdatetime("31-DEC-2100"))
   JOIN (pc
   WHERE pc.pathway_catalog_id=pwc.pathway_catalog_id)
   JOIN (pcor
   WHERE pcor.pathway_comp_id=pc.pathway_comp_id
    AND  NOT ( EXISTS (
   (SELECT
    ocsr.order_sentence_id
    FROM ord_cat_sent_r ocsr
    WHERE ocsr.order_sentence_id=pcor.order_sentence_id))))
   JOIN (os
   WHERE os.order_sentence_id=pcor.order_sentence_id
    AND ((os.parent_entity_id != pcor.pathway_comp_id) OR (os.parent_entity_name != "PATHWAY_COMP"))
   )
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (cnt > size(os->list,5))
    stat = alterlist(os->list,(cnt+ 100))
   ENDIF
   os->list[cnt].order_sentence_id = pcor.order_sentence_id, os->list[cnt].pathway_comp_id = pcor
   .pathway_comp_id, os->list[cnt].iv_comp_syn_id = pcor.iv_comp_syn_id
  FOOT REPORT
   stat = alterlist(os->list,cnt)
  WITH nocounter
 ;end select
 FOR (i = 1 TO value(size(os->list,5)))
   UPDATE  FROM order_sentence os
    SET os.parent_entity_name = "PATHWAY_COMP", os.parent_entity_id = os->list[i].pathway_comp_id, os
     .parent_entity2_name =
     IF ((os->list[i].iv_comp_syn_id > 0)) "CS_COMP"
     ELSE " "
     ENDIF
     ,
     os.parent_entity2_id = os->list[i].iv_comp_syn_id
    WHERE (os.order_sentence_id=os->list[i].order_sentence_id)
   ;end update
 ENDFOR
 FREE RECORD os
 SET errmsg = fillstring(132," ")
 SET errcode = 1
 SET errcode = error(errmsg,0)
 IF (errcode=0)
  COMMIT
  SET readme_data->status = "S"
  SET readme_data->message = "dcp_upd_plan_data_for_rdds.prg completed successfully"
 ELSE
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = "dcp_upd_plan_data_for_rdds.prg failed"
 ENDIF
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
