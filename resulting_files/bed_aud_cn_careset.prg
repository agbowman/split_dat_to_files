CREATE PROGRAM bed_aud_cn_careset
 FREE RECORD facility_array
 RECORD facility_array(
   1 qual[*]
     2 code_value = f8
     2 facility = vc
     2 reply_col = i2
   1 over_cnt = c1
 )
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 activity_types[*]
      2 code_value = f8
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 collist[*]
      2 header_text = vc
      2 data_type = i2
      2 hide_ind = i2
    1 rowlist[*]
      2 celllist[*]
        3 date_value = dq8
        3 nbr_value = i4
        3 double_value = f8
        3 string_value = vc
        3 display_flag = i2
    1 high_volume_flag = i2
    1 output_filename = vc
    1 run_status_flag = i2
    1 statlist[*]
      2 statistic_meaning = vc
      2 status_flag = i2
      2 qualifying_items = i4
      2 total_items = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 DECLARE lab_cat_cd = f8
 DECLARE dcp_cd = f8
 DECLARE max_facilities = i2
 SET max_facilities = 51
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=6000
   AND cv.cdf_meaning="GENERAL LAB"
  DETAIL
   lab_cat_cd = cv.code_value
  WITH nocounter, noheading
 ;end select
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=6011
   AND cv.cdf_meaning="DCP"
  DETAIL
   dcp_cd = cv.code_value
  WITH nocounter, noheading
 ;end select
 DECLARE oc_parse = vc
 SET oc_parse = " oc.active_ind = 1 and oc.orderable_type_flag in (2,6)"
 SET acnt = 0
 IF (validate(request->activity_types[1].code_value))
  SET acnt = size(request->activity_types,5)
  IF (acnt > 0)
   SET oc_parse = build2(oc_parse," and oc.activity_type_cd in (")
   FOR (a = 1 TO acnt)
     IF (a=1)
      SET oc_parse = build2(oc_parse,cnvtstring(request->activity_types[a].code_value))
     ELSE
      SET oc_parse = build2(oc_parse,",",cnvtstring(request->activity_types[a].code_value))
     ENDIF
   ENDFOR
   SET oc_parse = build2(oc_parse,")")
  ENDIF
 ENDIF
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM order_catalog oc
   PLAN (oc
    WHERE parser(oc_parse))
   DETAIL
    high_volume_cnt = hv_cnt
   WITH nocounter
  ;end select
  CALL echo(high_volume_cnt)
  IF (high_volume_cnt > 1500)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 1000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET stat = alterlist(reply->collist,9)
 SET reply->collist[1].header_text = "Order Set Description"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Order Set Millennium Name (Primary Synonym)"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Direct Care Provider Synonym"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Clinical Category for Order Set"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Section (Category)"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Note"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Orderables"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Requirement"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Order Sentence"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 SET first_row = 1
 SELECT INTO "nl:"
  test = concat(cnvtstring(oc.catalog_cd),cnvtstring(cc.comp_seq))
  FROM order_catalog oc,
   code_value cv,
   cs_component cc,
   long_text lt,
   order_sentence os,
   order_catalog_synonym ocs,
   order_catalog_synonym ocs2
  PLAN (oc
   WHERE parser(oc_parse))
   JOIN (cv
   WHERE cv.code_value=oc.dcp_clin_cat_cd)
   JOIN (cc
   WHERE cc.catalog_cd=oc.catalog_cd)
   JOIN (lt
   WHERE lt.long_text_id=cc.long_text_id)
   JOIN (os
   WHERE os.order_sentence_id=cc.order_sentence_id)
   JOIN (ocs2
   WHERE ocs2.synonym_id=cc.comp_id)
   JOIN (ocs
   WHERE ocs.catalog_cd=outerjoin(oc.catalog_cd)
    AND ocs.mnemonic_type_cd=outerjoin(dcp_cd))
  ORDER BY oc.primary_mnemonic, cc.comp_seq
  HEAD REPORT
   cnt = 0, stat = alterlist(reply->rowlist,25)
  HEAD test
   cnt = (cnt+ 1)
   IF (mod(cnt,25)=0)
    stat = alterlist(reply->rowlist,(25+ cnt))
   ENDIF
   stat = alterlist(reply->rowlist[cnt].celllist,9), reply->rowlist[cnt].celllist[1].string_value =
   oc.description, reply->rowlist[cnt].celllist[2].string_value = oc.primary_mnemonic,
   reply->rowlist[cnt].celllist[3].double_value = oc.catalog_cd, reply->rowlist[cnt].celllist[5].
   string_value = cc.comp_label, reply->rowlist[cnt].celllist[7].string_value = ocs2.mnemonic
   IF ((reply->rowlist[cnt].celllist[7].string_value > " "))
    CASE (cc.required_ind)
     OF 0:
      CASE (cc.include_exclude_ind)
       OF 0:
        reply->rowlist[cnt].celllist[8].string_value = "Exclude"
       OF 1:
        reply->rowlist[cnt].celllist[8].string_value = "Include"
      ENDCASE
     OF 1:
      reply->rowlist[cnt].celllist[8].string_value = "Required"
    ENDCASE
   ENDIF
   reply->rowlist[cnt].celllist[6].string_value = lt.long_text, reply->rowlist[cnt].celllist[9].
   string_value = os.order_sentence_display_line, reply->rowlist[cnt].celllist[4].string_value = cv
   .display,
   detail_cnt = 0
  HEAD ocs.mnemonic
   first_row = 1, detail_cnt = (detail_cnt+ 1)
   IF (detail_cnt=1)
    reply->rowlist[cnt].celllist[3].string_value = ocs.mnemonic
   ELSE
    reply->rowlist[cnt].celllist[3].string_value = concat(reply->rowlist[cnt].celllist[3].
     string_value,", ",ocs.mnemonic)
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->rowlist,cnt)
  WITH noheading, nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("carenet_caresets.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
