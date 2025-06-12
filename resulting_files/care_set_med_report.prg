CREATE PROGRAM care_set_med_report
 FREE RECORD reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET pt
 RECORD pt(
   1 line_cnt = i2
   1 lns[*]
     2 line = vc
 )
 FREE RECORD temp
 RECORD temp(
   1 care_sets[*]
     2 care_set = vc
     2 orderables[*]
       3 catalog_cd = f8
       3 label = vc
       3 mnemonic = vc
       3 status = vc
       3 sentence = vc
       3 usage = vc
       3 sentence_cnt = i4
       3 sentence_list[*]
         4 line = vc
       3 ref_text_ind = i2
 )
 DECLARE failed = c1 WITH public, noconstant("F")
 DECLARE ord_cnt = i4 WITH public, noconstant(0)
 DECLARE cs_cnt = i4 WITH public, noconstant(0)
 DECLARE orderable = f8 WITH public, noconstant(0.0)
 DECLARE pharmacy = f8 WITH public, noconstant(0.0)
 DECLARE label = f8 WITH public, noconstant(0.0)
 DECLARE protocol = f8 WITH public, noconstant(0.0)
 DECLARE tlabel = vc WITH public, noconstant(" ")
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6030
    AND cv.cdf_meaning="ORDERABLE")
  DETAIL
   orderable = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6000
    AND cv.cdf_meaning="PHARMACY")
  DETAIL
   pharmacy = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6030
    AND cv.cdf_meaning="LABEL")
  DETAIL
   label = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6009
    AND cv.cdf_meaning="NURSE PREP")
  DETAIL
   protocol = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  oc.catalog_cd, oc.primary_mnemonic, oc.orderable_type_flag,
  oc.primary_mnemonic, cc.comp_seq, cc.comp_type_cd,
  ocs_ind = nullind(ocs.mnemonic), ocs.mnemonic, ocs.mnemonic_type_cd,
  ocs.catalog_type_cd, ocs.orderable_type_flag, os_ind = nullind(os.order_sentence_display_line),
  os.order_sentence_display_line, os.usage_flag
  FROM order_catalog oc,
   order_catalog_synonym ocs,
   cs_component cc,
   order_sentence os
  PLAN (oc
   WHERE oc.orderable_type_flag=6
    AND oc.active_ind=1)
   JOIN (cc
   WHERE cc.catalog_cd=oc.catalog_cd
    AND cc.comp_type_cd IN (orderable, label))
   JOIN (ocs
   WHERE ocs.synonym_id=outerjoin(cc.comp_id)
    AND ocs.catalog_type_cd=outerjoin(pharmacy)
    AND ocs.active_ind=outerjoin(1))
   JOIN (os
   WHERE os.order_sentence_id=outerjoin(cc.order_sentence_id))
  ORDER BY oc.primary_mnemonic, cc.comp_seq
  HEAD REPORT
   cs_cnt = 0, ord_cnt = 0, tlabel = " "
  HEAD oc.primary_mnemonic
   cs_cnt = (cs_cnt+ 1)
   IF (mod(cs_cnt,10)=1)
    stat = alterlist(temp->care_sets,(cs_cnt+ 9))
   ENDIF
   temp->care_sets[cs_cnt].care_set = oc.primary_mnemonic, ord_cnt = 0, tlabel = " "
  DETAIL
   IF (cc.comp_type_cd=label)
    tlabel = cc.comp_label
   ELSEIF (ocs_ind=0)
    ord_cnt = (ord_cnt+ 1)
    IF (mod(ord_cnt,10)=1)
     stat = alterlist(temp->care_sets[cs_cnt].orderables,(ord_cnt+ 9))
    ENDIF
    temp->care_sets[cs_cnt].orderables[ord_cnt].label = tlabel, temp->care_sets[cs_cnt].orderables[
    ord_cnt].mnemonic = ocs.mnemonic, temp->care_sets[cs_cnt].orderables[ord_cnt].catalog_cd = ocs
    .catalog_cd
    IF (ocs.orderable_type_flag=8)
     temp->care_sets[cs_cnt].orderables[ord_cnt].mnemonic = concat(temp->care_sets[cs_cnt].
      orderables[ord_cnt].mnemonic," (IV Set)")
    ENDIF
    IF (cc.required_ind=1)
     temp->care_sets[cs_cnt].orderables[ord_cnt].status = "Required"
    ELSE
     IF (cc.include_exclude_ind=0)
      temp->care_sets[cs_cnt].orderables[ord_cnt].status = "Exclude"
     ELSEIF (cc.include_exclude_ind=1)
      temp->care_sets[cs_cnt].orderables[ord_cnt].status = "Include"
     ENDIF
    ENDIF
    IF (os.order_sentence_display_line > " "
     AND os_ind=0)
     temp->care_sets[cs_cnt].orderables[ord_cnt].sentence = os.order_sentence_display_line
     CASE (os.usage_flag)
      OF 0:
       temp->care_sets[cs_cnt].orderables[ord_cnt].usage = "All"
      OF 1:
       temp->care_sets[cs_cnt].orderables[ord_cnt].usage = "Administration"
      OF 2:
       temp->care_sets[cs_cnt].orderables[ord_cnt].usage = "Prescription"
     ENDCASE
    ENDIF
   ENDIF
  FOOT  oc.catalog_cd
   stat = alterlist(temp->care_sets[cs_cnt].orderables,ord_cnt)
  FOOT REPORT
   stat = alterlist(temp->care_sets,cs_cnt)
  WITH nocounter
 ;end select
 FOR (x = 1 TO cs_cnt)
  SET ord_cnt = size(temp->care_sets[x].orderables,5)
  IF (ord_cnt > 0)
   SELECT INTO "nl:"
    rtr.text_type_cd, rtr.parent_entity_name, rtr.parent_entity_id
    FROM (dummyt d  WITH seq = value(ord_cnt)),
     ref_text_reltn rtr
    PLAN (d)
     JOIN (rtr
     WHERE rtr.parent_entity_name="ORDERCATALOG"
      AND (rtr.parent_entity_id=temp->care_sets[x].orderables[d.seq].catalog_cd)
      AND rtr.text_type_cd=protocol)
    DETAIL
     temp->care_sets[x].orderables[d.seq].ref_text_ind = 1
    WITH nocounter
   ;end select
  ENDIF
 ENDFOR
 FOR (x = 1 TO cs_cnt)
  SET ord_cnt = size(temp->care_sets[x].orderables,5)
  FOR (y = 1 TO ord_cnt)
    IF ((temp->care_sets[x].orderables[y].sentence > " "))
     EXECUTE dcp_parse_text temp->care_sets[x].orderables[y].sentence, 55
     SET stat = alterlist(temp->care_sets[x].orderables[y].sentence_list,pt->line_cnt)
     SET temp->care_sets[x].orderables[y].sentence_cnt = pt->line_cnt
     FOR (z = 1 TO pt->line_cnt)
       SET temp->care_sets[x].orderables[y].sentence_list[z].line = pt->lns[z].line
     ENDFOR
    ENDIF
  ENDFOR
 ENDFOR
 SELECT
  FROM (dummyt d  WITH seq = 1)
  HEAD REPORT
   line8 = fillstring(8,"-"), line10 = fillstring(10,"-"), line35 = fillstring(35,"-"),
   line70 = fillstring(70,"-"), line_end = fillstring(130,"_")
  HEAD PAGE
   col 50, "CARESET MEDICATIONS REPORT", row + 1,
   col 1, "Date:", dttm = format(cnvtdatetime(curdate,curtime3),cclfmt->shortdatetime),
   col 10, dttm, pageend = concat("Page no: ",cnvtstring(curpage)),
   col 110, pageend, row + 1,
   col 1, line_end, row + 1
  DETAIL
   FOR (x = 1 TO cs_cnt)
    ord_cnt = size(temp->care_sets[x].orderables,5),
    IF (ord_cnt > 0)
     col 1, "CARE SET:", careset = substring(1,100,temp->care_sets[x].care_set),
     col 11, careset, row + 1,
     col 5, "ORDERABLES", col 76,
     "STATUS", col 85, "CATEGORY",
     col 121, "REF TEXT", row + 1,
     col 5, line70, col 76,
     line8, col 85, line35,
     col 121, line10, row + 1
     FOR (y = 1 TO ord_cnt)
       med = substring(1,70,temp->care_sets[x].orderables[y].mnemonic), col 5, med,
       col 76, temp->care_sets[x].orderables[y].status, category = substring(1,35,temp->care_sets[x].
        orderables[y].label),
       col 85, category
       IF ((temp->care_sets[x].orderables[y].ref_text_ind=1))
        col 121, "X"
       ENDIF
       row + 1
       FOR (z = 1 TO temp->care_sets[x].orderables[y].sentence_cnt)
         IF (z=1)
          col 10, "SENTENCE:"
         ENDIF
         col 20, temp->care_sets[x].orderables[y].sentence_list[z].line
         IF (z=1)
          col 76, "USAGE:", col 83,
          temp->care_sets[x].orderables[y].usage
         ENDIF
         row + 1
       ENDFOR
     ENDFOR
     row + 1, col 1, line_end,
     row + 1
    ENDIF
   ENDFOR
  FOOT PAGE
   row + 0
  WITH nocounter
 ;end select
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
