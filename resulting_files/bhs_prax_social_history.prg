CREATE PROGRAM bhs_prax_social_history
 FREE RECORD shx_fhx
 RECORD shx_fhx(
   1 person_id = f8
   1 mrn = vc
   1 name = vc
   1 social[*]
     2 shx_category_ref_id = f8
     2 shx_category_def_id = f8
     2 category_cd = f8
     2 category = vc
     2 assessment = vc
     2 details[*]
       3 shx_activity_group_id = f8
       3 shx_activity_id = f8
       3 active_ind = i4
       3 details = c500
       3 last_update_date = vc
       3 last_updated_by = vc
       3 last_review_date = vc
       3 last_review_by = vc
       3 comments[*]
         4 comment_id = f8
         4 comments_date = vc
         4 comment_prsnl = vc
         4 comments = c500
       3 alpha_response[*]
         4 task_assay_cd = f8
         4 task_assay_display = vc
         4 nomenclature_id = f8
         4 nomenclature_display = vc
       3 freetext[*]
         4 task_assay_cd = f8
         4 task_assay_display = vc
         4 free_text_value = vc
 )
 DECLARE mrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",4,"MRN"))
 DECLARE fhx = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",351,"FAMILYHIST"))
 DECLARE active_status_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",4002172,"ACTIVE")
  )
 DECLARE json = vc WITH protect, noconstant("")
 DECLARE vcnt = i4
 DECLARE acnt = i4
 IF (( $3=2))
  SET where_params = build("SA.ACTIVE_IND != 2")
 ELSE
  SET where_params = build("SA.ACTIVE_IND =", $3)
 ENDIF
 SELECT INTO "NL:"
  FROM person_alias p,
   person pe
  PLAN (pe
   WHERE (pe.person_id= $2)
    AND pe.active_ind=1)
   JOIN (p
   WHERE p.person_id=pe.person_id
    AND p.person_alias_type_cd=mrn_cd
    AND p.active_ind=1)
  HEAD REPORT
   shx_fhx->mrn = p.alias, shx_fhx->name = pe.name_full_formatted, shx_fhx->person_id = p.person_id
  WITH time = 30, format, separator = " "
 ;end select
 SELECT INTO "NL:"
  s_category_disp = uar_get_code_display(s.category_cd), sc.shx_category_def_id, sc
  .shx_category_ref_id,
  sa.type_mean, details = l.long_text, sa_assessment_disp = uar_get_code_display(sa.assessment_cd),
  pr.name_full_formatted
  FROM shx_category_ref s,
   shx_category_def sc,
   shx_activity sa,
   long_text l,
   prsnl pr
  PLAN (s
   WHERE s.category_cd > 0)
   JOIN (sc
   WHERE sc.shx_category_ref_id=s.shx_category_ref_id
    AND sc.beg_effective_dt_tm < sysdate
    AND sc.end_effective_dt_tm > sysdate)
   JOIN (sa
   WHERE (sa.person_id= $2)
    AND sa.shx_category_ref_id=s.shx_category_ref_id
    AND sa.shx_category_def_id=sc.shx_category_def_id
    AND sa.status_cd=active_status_cd
    AND parser(where_params))
   JOIN (l
   WHERE l.long_text_id=outerjoin(sa.long_text_id))
   JOIN (pr
   WHERE pr.person_id=sa.updt_id)
  ORDER BY s.shx_category_ref_id, sa.type_mean, sa.shx_activity_id,
   sa.updt_dt_tm DESC
  HEAD s.shx_category_ref_id
   vcnt = (vcnt+ 1), stat = alterlist(shx_fhx->social,vcnt), shx_fhx->social[vcnt].category =
   s_category_disp,
   shx_fhx->social[vcnt].category_cd = s.category_cd, shx_fhx->social[vcnt].shx_category_def_id = sc
   .shx_category_def_id, shx_fhx->social[vcnt].shx_category_ref_id = sc.shx_category_ref_id,
   acnt = 0
  DETAIL
   IF (sa.type_mean="ASSESSMENT")
    shx_fhx->social[vcnt].assessment = sa_assessment_disp
   ELSEIF (sa.type_mean="DETAIL")
    acnt = (acnt+ 1), stat = alterlist(shx_fhx->social[vcnt].details,acnt), shx_fhx->social[vcnt].
    details[acnt].details = details,
    shx_fhx->social[vcnt].details[acnt].shx_activity_id = sa.shx_activity_id, shx_fhx->social[vcnt].
    details[acnt].shx_activity_group_id = sa.shx_activity_group_id, shx_fhx->social[vcnt].details[
    acnt].active_ind = sa.active_ind,
    shx_fhx->social[vcnt].details[acnt].last_update_date = format(sa.updt_dt_tm,"MM-DD-YY HH:MM;;D"),
    shx_fhx->social[vcnt].details[acnt].last_updated_by = pr.name_full_formatted
   ENDIF
  WITH time = 30, nocounter
 ;end select
 SELECT INTO "NL:"
  shx_activity_id = shx_fhx->social[d1.seq].details[d2.seq].shx_activity_id, review_dt = format(sah
   .action_dt_tm,"MM-DD-YY HH:MM;;D"), pr.name_full_formatted
  FROM (dummyt d1  WITH seq = value(size(shx_fhx->social,5))),
   (dummyt d2  WITH seq = 1),
   shx_action sah,
   prsnl pr
  PLAN (d1
   WHERE maxrec(d2,size(shx_fhx->social[d1.seq].details,5)))
   JOIN (d2)
   JOIN (sah
   WHERE (sah.shx_activity_id=shx_fhx->social[d1.seq].details[d2.seq].shx_activity_id)
    AND sah.action_type_mean="REVIEW")
   JOIN (pr
   WHERE pr.person_id=sah.prsnl_id)
  ORDER BY shx_fhx->social[d1.seq].details[d2.seq].shx_activity_id, sah.action_dt_tm DESC
  HEAD shx_activity_id
   shx_fhx->social[d1.seq].details[d2.seq].last_review_date = review_dt, shx_fhx->social[d1.seq].
   details[d2.seq].last_review_by = pr.name_full_formatted
  WITH time = 30
 ;end select
 SELECT INTO "NL:"
  comments = substring(1,500,trim(l.long_text,3)), sc.comment_prsnl_id, sc.comment_dt_tm,
  shx_activity_group_id = shx_fhx->social[d1.seq].details[d2.seq].shx_activity_group_id, l
  .long_text_id, pr.name_full_formatted
  FROM (dummyt d1  WITH seq = value(size(shx_fhx->social,5))),
   (dummyt d2  WITH seq = 1),
   shx_comment sc,
   long_text l,
   prsnl pr
  PLAN (d1
   WHERE maxrec(d2,size(shx_fhx->social[d1.seq].details,5)))
   JOIN (d2)
   JOIN (sc
   WHERE (sc.shx_activity_group_id=shx_fhx->social[d1.seq].details[d2.seq].shx_activity_group_id))
   JOIN (l
   WHERE l.long_text_id=sc.long_text_id)
   JOIN (pr
   WHERE pr.person_id=sc.comment_prsnl_id)
  ORDER BY shx_fhx->social[d1.seq].details[d2.seq].shx_activity_group_id, sc.comment_dt_tm
  HEAD shx_activity_group_id
   ccnt = 0
  DETAIL
   ccnt = (ccnt+ 1), stat = alterlist(shx_fhx->social[d1.seq].details[d2.seq].comments,ccnt), shx_fhx
   ->social[d1.seq].details[d2.seq].comments[ccnt].comment_id = l.long_text_id,
   shx_fhx->social[d1.seq].details[d2.seq].comments[ccnt].comments = comments, shx_fhx->social[d1.seq
   ].details[d2.seq].comments[ccnt].comments_date = format(sc.comment_dt_tm,"MM-DD-YY HH:MM;;D"),
   shx_fhx->social[d1.seq].details[d2.seq].comments[ccnt].comment_prsnl = pr.name_full_formatted
  WITH time = 30, nocounter
 ;end select
 SELECT INTO "NL:"
  sr.task_assay_cd, sr.response_val, sr.shx_activity_id,
  cv.definition
  FROM (dummyt d1  WITH seq = value(size(shx_fhx->social,5))),
   (dummyt d2  WITH seq = 1),
   shx_response sr,
   code_value cv
  PLAN (d1
   WHERE maxrec(d2,size(shx_fhx->social[d1.seq].details,5)))
   JOIN (d2)
   JOIN (sr
   WHERE (sr.shx_activity_id=shx_fhx->social[d1.seq].details[d2.seq].shx_activity_id)
    AND sr.response_type="FREETEXT")
   JOIN (cv
   WHERE cv.code_value=sr.task_assay_cd)
  ORDER BY sr.shx_activity_id
  HEAD sr.shx_activity_id
   ccnt = 0
  DETAIL
   ccnt = (ccnt+ 1), stat = alterlist(shx_fhx->social[d1.seq].details[d2.seq].freetext,ccnt), shx_fhx
   ->social[d1.seq].details[d2.seq].freetext[ccnt].task_assay_cd = sr.task_assay_cd,
   shx_fhx->social[d1.seq].details[d2.seq].freetext[ccnt].task_assay_display = cv.definition, shx_fhx
   ->social[d1.seq].details[d2.seq].freetext[ccnt].free_text_value = sr.response_val
  WITH time = 30, nocounter
 ;end select
 SELECT INTO "NL:"
  sr.task_assay_cd, sr.shx_activity_id, cv.definition,
  sar.nomenclature_id, sar.other_text, n.source_string
  FROM (dummyt d1  WITH seq = value(size(shx_fhx->social,5))),
   (dummyt d2  WITH seq = 1),
   shx_response sr,
   code_value cv,
   shx_alpha_response sar,
   nomenclature n
  PLAN (d1
   WHERE maxrec(d2,size(shx_fhx->social[d1.seq].details,5)))
   JOIN (d2)
   JOIN (sr
   WHERE (sr.shx_activity_id=shx_fhx->social[d1.seq].details[d2.seq].shx_activity_id)
    AND sr.response_type="ALPHA")
   JOIN (cv
   WHERE cv.code_value=sr.task_assay_cd)
   JOIN (sar
   WHERE sar.shx_response_id=sr.shx_response_id)
   JOIN (n
   WHERE n.nomenclature_id=sar.nomenclature_id)
  ORDER BY sr.shx_activity_id
  HEAD sr.shx_activity_id
   ccnt = 0
  DETAIL
   ccnt = (ccnt+ 1), stat = alterlist(shx_fhx->social[d1.seq].details[d2.seq].alpha_response,ccnt),
   shx_fhx->social[d1.seq].details[d2.seq].alpha_response[ccnt].task_assay_cd = sr.task_assay_cd,
   shx_fhx->social[d1.seq].details[d2.seq].alpha_response[ccnt].task_assay_display = cv.definition,
   shx_fhx->social[d1.seq].details[d2.seq].alpha_response[ccnt].nomenclature_id = sar.nomenclature_id,
   shx_fhx->social[d1.seq].details[d2.seq].alpha_response[ccnt].nomenclature_display = n
   .source_string
  WITH time = 30, nocounter
 ;end select
 DECLARE v1 = vc WITH protect, noconstant("")
 DECLARE v2 = vc WITH protect, noconstant("")
 DECLARE v3 = vc WITH protect, noconstant("")
 DECLARE v4 = vc WITH protect, noconstant("")
 DECLARE v5 = vc WITH protect, noconstant("")
 DECLARE v6 = vc WITH protect, noconstant("")
 DECLARE v7 = vc WITH protect, noconstant("")
 DECLARE v8 = vc WITH protect, noconstant("")
 DECLARE v9 = vc WITH protect, noconstant("")
 DECLARE v10 = vc WITH protect, noconstant("")
 DECLARE v11 = vc WITH protect, noconstant("")
 DECLARE v12 = vc WITH protect, noconstant("")
 DECLARE v13 = vc WITH protect, noconstant("")
 DECLARE v14 = vc WITH protect, noconstant("")
 DECLARE v15 = vc WITH protect, noconstant("")
 DECLARE v16 = vc WITH protect, noconstant("")
 DECLARE v17 = vc WITH protect, noconstant("")
 DECLARE v18 = vc WITH protect, noconstant("")
 DECLARE v19 = vc WITH protect, noconstant("")
 DECLARE v20 = vc WITH protect, noconstant("")
 DECLARE v21 = vc WITH protect, noconstant("")
 DECLARE v22 = vc WITH protect, noconstant("")
 DECLARE v23 = vc WITH protect, noconstant("")
 DECLARE v24 = vc WITH protect, noconstant("")
 DECLARE v25 = vc WITH protect, noconstant("")
 DECLARE v26 = vc WITH protect, noconstant("")
 DECLARE v27 = vc WITH protect, noconstant("")
 DECLARE v28 = vc WITH protect, noconstant("")
 DECLARE v29 = vc WITH protect, noconstant("")
 DECLARE v30 = vc WITH protect, noconstant("")
 SELECT INTO  $1
  FROM (dummyt d1  WITH size(value(1)))
  WHERE d1.seq > 0
  HEAD REPORT
   col 0, "{", row + 1,
   col + 1, '"SHX_FHX":{', row + 1,
   v1 = build('"PERSON_ID":',shx_fhx->person_id,","), col + 1, v1,
   row + 1, v2 = build('"MRN":"',shx_fhx->mrn,'",'), col + 1,
   v2, row + 1, v3 = build('"NAME":"',shx_fhx->name,'",'),
   col + 1, v3, row + 1,
   col + 1, '"SOCIAL":[', row + 1
   FOR (i = 1 TO size(shx_fhx->social,5))
     col + 1, "{", row + 1,
     v4 = build('"SHX_CATEGORY_REF_ID":',shx_fhx->social[i].shx_category_ref_id,","), col + 1, v4,
     row + 1, v5 = build('"SHX_CATEGORY_DEF_ID":',shx_fhx->social[i].shx_category_def_id,","), col +
     1,
     v5, row + 1, v6 = build('"CATEGORY_CD":',shx_fhx->social[i].category_cd,","),
     col + 1, v6, row + 1,
     v7 = build('"CATEGORY":"',trim(shx_fhx->social[i].category,3),'",'), col + 1, v7,
     row + 1, v8 = build('"ASSESSMENT":"',trim(shx_fhx->social[i].assessment,3),'",'), col + 1,
     v8, row + 1, col + 1,
     '"DETAILS":[', row + 1
     FOR (j = 1 TO size(shx_fhx->social[i].details,5))
       col + 1, "{", row + 1,
       v9 = build('"SHX_ACTIVITY_GROUP_ID":',shx_fhx->social[i].details[j].shx_activity_group_id,","),
       col + 1, v9,
       row + 1, v10 = build('"SHX_ACTIVITY_ID":',shx_fhx->social[i].details[j].shx_activity_id,","),
       col + 1,
       v10, row + 1, v11 = build('"ACTIVE_IND":',shx_fhx->social[i].details[j].active_ind,","),
       col + 1, v11, row + 1,
       v12 = build('"DETAILS":"',trim(shx_fhx->social[i].details[j].details,3),'",'), col + 1, v12,
       row + 1, v13 = build('"LAST_UPDATE_DATE":"',trim(shx_fhx->social[i].details[j].
         last_update_date,3),'",'), col + 1,
       v13, row + 1, v14 = build('"LAST_UPDATED_BY":"',trim(shx_fhx->social[i].details[j].
         last_updated_by,3),'",'),
       col + 1, v14, row + 1,
       v15 = build('"LAST_REVIEW_DATE":"',trim(shx_fhx->social[i].details[j].last_review_date,3),'",'
        ), col + 1, v15,
       row + 1, v16 = build('"LAST_REVIEW_BY":"',trim(shx_fhx->social[i].details[j].last_review_by,3),
        '",'), col + 1,
       v16, row + 1, col + 1,
       '"COMMENTS":[', row + 1
       FOR (k = 1 TO size(shx_fhx->social[i].details[j].comments,5))
         IF ((shx_fhx->social[i].details[j].comments[k].comment_id > 0.00))
          col + 1, "{", row + 1,
          v17 = build('"COMMENT_ID":',shx_fhx->social[i].details[j].comments[k].comment_id,","), col
           + 1, v17,
          row + 1, v18 = build('"COMMENTS_DATE":"',trim(shx_fhx->social[i].details[j].comments[k].
            comments_date,3),'",'), col + 1,
          v18, row + 1, v19 = build('"COMMENT_PRSNL":"',trim(shx_fhx->social[i].details[j].comments[k
            ].comment_prsnl,3),'",'),
          col + 1, v19, row + 1,
          v20 = build('"COMMENTS":"',trim(replace(shx_fhx->social[i].details[j].comments[k].comments,
             '"','\"',0),3),'"'), col + 1, v20,
          row + 1
          IF (k=size(shx_fhx->social[i].details[j].comments,5))
           col + 1, "}"
          ELSE
           col + 1, "},"
          ENDIF
          row + 1
         ENDIF
       ENDFOR
       col + 1, "],", row + 1,
       col + 1, '"ALPHA_RESPONSE":[', row + 1
       FOR (l = 1 TO size(shx_fhx->social[i].details[j].alpha_response,5))
         IF ((shx_fhx->social[i].details[j].alpha_response[l].task_assay_cd > 0.00))
          col + 1, "{", row + 1,
          v21 = build('"TASK_ASSAY_CD":',shx_fhx->social[i].details[j].alpha_response[l].
           task_assay_cd,","), col + 1, v21,
          row + 1, v22 = build('"TASK_ASSAY_DISPLAY":"',trim(shx_fhx->social[i].details[j].
            alpha_response[l].task_assay_display,3),'",'), col + 1,
          v22, row + 1, v23 = build('"NOMENCLATURE_ID":',shx_fhx->social[i].details[j].
           alpha_response[l].nomenclature_id,","),
          col + 1, v23, row + 1,
          v24 = build('"NOMENCLATURE_DISPLAY":"',trim(shx_fhx->social[i].details[j].alpha_response[l]
            .nomenclature_display,3),'"'), col + 1, v24,
          row + 1
          IF (l=size(shx_fhx->social[i].details[j].alpha_response,5))
           col + 1, "}"
          ELSE
           col + 1, "},"
          ENDIF
          row + 1
         ENDIF
       ENDFOR
       col + 1, "],", row + 1,
       col + 1, '"FREETEXT":[', row + 1
       FOR (m = 1 TO size(shx_fhx->social[i].details[j].freetext,5))
         IF ((shx_fhx->social[i].details[j].freetext[m].task_assay_cd > 0.00))
          col + 1, "{", row + 1,
          v25 = build('"TASK_ASSAY_CD":',shx_fhx->social[i].details[j].freetext[m].task_assay_cd,","),
          col + 1, v25,
          row + 1, v26 = build('"TASK_ASSAY_DISPLAY":"',trim(shx_fhx->social[i].details[j].freetext[m
            ].task_assay_display,3),'",'), col + 1,
          v26, row + 1, v27 = build('"FREE_TEXT_VALUE":"',trim(shx_fhx->social[i].details[j].
            freetext[m].free_text_value,3),'"'),
          col + 1, v27, row + 1
          IF (m=size(shx_fhx->social[i].details[j].freetext,5))
           col + 1, "}"
          ELSE
           col + 1, "},"
          ENDIF
          row + 1
         ENDIF
       ENDFOR
       col + 1, "]", row + 1
       IF (j=size(shx_fhx->social[i].details,5))
        col + 1, "}"
       ELSE
        col + 1, "},"
       ENDIF
       row + 1
     ENDFOR
     col + 1, "]", row + 1
     IF (i=size(shx_fhx->social,5))
      col + 1, "}"
     ELSE
      col + 1, "},"
     ENDIF
     row + 1
   ENDFOR
   col + 1, "]", row + 1
  FOOT REPORT
   col + 1, "}", row + 1,
   col + 1, "}"
  WITH nocounter, nullreport, formfeed = none,
   maxcol = 32000, format = variable, maxrow = 0,
   time = 30
 ;end select
END GO
