CREATE PROGRAM bed_get_os_pp_rebuild_logging:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
    1 skip_volume_check_ind = i2
    1 output_filename = vc
  ) WITH protect
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
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 RECORD temp(
   1 tqual[*]
     2 phaseid = f8
     2 powerplan = vc
     2 synonym = vc
     2 old_ord_sent_disp_line = vc
     2 new_ord_sent_disp_line = vc
     2 usage_flag = i2
     2 error = vc
 ) WITH protect
 DECLARE row_nbr = i4 WITH protect, noconstant(0)
 DECLARE pp_num = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET stat = alterlist(reply->collist,6)
 SET reply->collist[1].header_text = "Powerplan"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Synonym"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Old Clinical Display Line"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "New Clinical Display Line"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Sentence Type"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Error"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SELECT INTO "NL:"
  FROM os_rbld_ord_sent os,
   pathway_comp pc,
   pathway_catalog p,
   os_rbld_msg osm,
   order_sentence sent
  PLAN (os
   WHERE os.os_rbld_ord_sent_id > 0
    AND os.new_parent_entity_name="PATHWAY_COMP"
    AND ((os.committed_flag > 1) OR (os.committed_flag=1
    AND os.new_ord_sent_disp_line <= " ")) )
   JOIN (pc
   WHERE pc.pathway_comp_id=os.new_parent_entity_id)
   JOIN (p
   WHERE p.pathway_catalog_id=pc.pathway_catalog_id)
   JOIN (sent
   WHERE sent.order_sentence_id=os.order_sentence_id)
   JOIN (osm
   WHERE osm.os_rbld_ord_sent_id=outerjoin(os.os_rbld_ord_sent_id)
    AND osm.severity_flag >= outerjoin(3))
  ORDER BY cnvtupper(p.display_description), cnvtupper(os.parent_synonym_text)
  HEAD os.os_rbld_ord_sent_id
   pp_num = (pp_num+ 1), msg_nbr = 0, stat = alterlist(temp->tqual,pp_num)
   IF (p.type_mean="PHASE")
    temp->tqual[pp_num].phaseid = p.pathway_catalog_id
   ENDIF
   temp->tqual[pp_num].powerplan = p.description, temp->tqual[pp_num].synonym = os
   .parent_synonym_text, temp->tqual[pp_num].old_ord_sent_disp_line = os.old_ord_sent_disp_line,
   temp->tqual[pp_num].new_ord_sent_disp_line = os.new_ord_sent_disp_line, temp->tqual[pp_num].
   usage_flag = sent.usage_flag
  HEAD osm.os_rbld_msg_id
   IF (osm.os_rbld_msg_id > 0)
    temp->tqual[pp_num].error = osm.message_txt, temp->tqual[pp_num].new_ord_sent_disp_line = ""
   ENDIF
  WITH nocounter
 ;end select
 IF (pp_num > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = pp_num),
    pw_cat_reltn pw,
    pathway_catalog pcat
   PLAN (d
    WHERE (temp->tqual[d.seq].phaseid > 0))
    JOIN (pw
    WHERE (pw.pw_cat_t_id=temp->tqual[d.seq].phaseid)
     AND pw.type_mean="GROUP")
    JOIN (pcat
    WHERE pcat.pathway_catalog_id=pw.pw_cat_s_id)
   DETAIL
    temp->tqual[d.seq].powerplan = pcat.description
  ;end select
 ENDIF
 FOR (t = 1 TO pp_num)
   SET row_nbr = (row_nbr+ 1)
   SET stat = alterlist(reply->rowlist,row_nbr)
   SET stat = alterlist(reply->rowlist[row_nbr].celllist,6)
   SET reply->rowlist[row_nbr].celllist[1].string_value = temp->tqual[t].powerplan
   SET reply->rowlist[row_nbr].celllist[2].string_value = temp->tqual[t].synonym
   SET reply->rowlist[row_nbr].celllist[3].string_value = temp->tqual[t].old_ord_sent_disp_line
   SET reply->rowlist[row_nbr].celllist[4].string_value = temp->tqual[t].new_ord_sent_disp_line
   IF ((reply->rowlist[row_nbr].celllist[4].string_value <= " "))
    SET reply->rowlist[row_nbr].celllist[6].string_value = "Clinical display line would be empty"
   ENDIF
   IF ((temp->tqual[t].usage_flag=1))
    SET reply->rowlist[row_nbr].celllist[5].string_value = "Medication Administration"
   ELSEIF ((temp->tqual[t].usage_flag=2))
    SET reply->rowlist[row_nbr].celllist[5].string_value = "Prescription"
   ENDIF
   IF ((temp->tqual[t].error > " "))
    SET reply->rowlist[row_nbr].celllist[6].string_value = temp->tqual[t].error
   ENDIF
 ENDFOR
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
 IF ((request->skip_volume_check_ind=0))
  IF (size(reply->rowlist,5) > 5000)
   SET reply->high_volume_flag = 2
   SET stat = alterlist(reply->rowlist,0)
   GO TO exit_script
  ELSEIF (size(reply->rowlist,5) > 3000)
   SET reply->high_volume_flag = 1
   SET stat = alterlist(reply->rowlist,0)
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build(concat("os_rebuild_logging.csv"))
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
