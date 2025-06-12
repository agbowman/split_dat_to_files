CREATE PROGRAM cmn_rdm_stw_remove_dt_opt:dba
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
 DECLARE getfilteridsforqualdispdtoptions(null) = null WITH protect
 DECLARE deldatamartvalueforfilters(null) = null WITH protect
 DECLARE deldatamartdefaultforfilters(null) = null WITH protect
 DECLARE deldatamartreportfilterrforfilters(null) = null WITH protect
 DECLARE dellongtextforfilters(null) = null WITH protect
 DECLARE deldatamarttextforfilters(null) = null WITH protect
 DECLARE delfilters(null) = null WITH protect
 RECORD ce_rpt_templates_filters(
   1 qual[*]
     2 filter_id = f8
 )
 SUBROUTINE getfilteridsforqualdispdtoptions(null)
   DECLARE errmsg = vc WITH protect, noconstant("")
   DECLARE count = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM br_datamart_filter bf
    WHERE bf.filter_mean IN ("SMART_DT_QUAL_OPT", "SMART_DT_DISPLAY_OPT", "SMART_RPT_DT_QUAL_OPT",
    "SMART_RPT_DT_DISPLAY_OPT")
    ORDER BY bf.br_datamart_filter_id
    DETAIL
     count = (count+ 1), stat = alterlist(ce_rpt_templates_filters->qual,count),
     ce_rpt_templates_filters->qual[count].filter_id = bf.br_datamart_filter_id
    WITH nocounter
   ;end select
   IF (error(errmsg,0) > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Error getting filter ids from br_datamart_filter: ",errmsg)
    GO TO exit_script
   ENDIF
   CALL echorecord(ce_rpt_templates_filters)
 END ;Subroutine
 SUBROUTINE deldatamartvalueforfilters(null)
   DECLARE errmsg = vc WITH protect, noconstant("")
   DECLARE count = i4 WITH protect, noconstant(0)
   DELETE  FROM br_datamart_value bv
    WHERE expand(count,1,size(ce_rpt_templates_filters->qual,5),bv.br_datamart_filter_id,
     ce_rpt_templates_filters->qual[count].filter_id)
    WITH nocounter
   ;end delete
   IF (error(errmsg,0) > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Error deleting from br_datamart_value: ",errmsg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE deldatamartdefaultforfilters(null)
   DECLARE errmsg = vc WITH protect, noconstant("")
   DECLARE count = i4 WITH protect, noconstant(0)
   DELETE  FROM br_datamart_default bd
    WHERE expand(count,1,size(ce_rpt_templates_filters->qual,5),bd.br_datamart_filter_id,
     ce_rpt_templates_filters->qual[count].filter_id)
    WITH nocounter
   ;end delete
   IF (error(errmsg,0) > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Error deleting from br_datamart_default: ",errmsg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE deldatamartreportfilterrforfilters(null)
   DECLARE errmsg = vc WITH protect, noconstant("")
   DECLARE count = i4 WITH protect, noconstant(0)
   DELETE  FROM br_datamart_report_filter_r brf
    WHERE expand(count,1,size(ce_rpt_templates_filters->qual,5),brf.br_datamart_filter_id,
     ce_rpt_templates_filters->qual[count].filter_id)
    WITH nocounter
   ;end delete
   IF (error(errmsg,0) > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Error deleting from br_datamart_report_filter_r: ",errmsg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE dellongtextforfilters(null)
   DECLARE errmsg = vc WITH protect, noconstant("")
   DECLARE count = i4 WITH protect, noconstant(0)
   DELETE  FROM br_long_text blt
    WHERE blt.parent_entity_id IN (
    (SELECT
     bt.br_datamart_text_id
     FROM br_datamart_text bt
     WHERE expand(count,1,size(ce_rpt_templates_filters->qual,5),bt.br_datamart_filter_id,
      ce_rpt_templates_filters->qual[count].filter_id)))
    WITH nocounter
   ;end delete
   IF (error(errmsg,0) > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Error deleting from br_long_text: ",errmsg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE deldatamarttextforfilters(null)
   DECLARE errmsg = vc WITH protect, noconstant("")
   DECLARE count = i4 WITH protect, noconstant(0)
   DELETE  FROM br_datamart_text bt
    WHERE expand(count,1,size(ce_rpt_templates_filters->qual,5),bt.br_datamart_filter_id,
     ce_rpt_templates_filters->qual[count].filter_id)
    WITH nocounter
   ;end delete
   IF (error(errmsg,0) > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Error deleting from br_datamart_text: ",errmsg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE delfilters(null)
   DECLARE errmsg = vc WITH protect, noconstant("")
   DECLARE count = i4 WITH protect, noconstant(0)
   DELETE  FROM br_datamart_filter bf
    WHERE expand(count,1,size(ce_rpt_templates_filters->qual,5),bf.br_datamart_filter_id,
     ce_rpt_templates_filters->qual[count].filter_id)
    WITH nocounter
   ;end delete
   IF (error(errmsg,0) > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Error deleting from br_datamart_filter: ",errmsg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SET readme_data->status = "F"
 SET readme_data->message = "Readme failure: Starting Script cmn_rdm_stw_remove_dt_opt."
 CALL getfilteridsforqualdispdtoptions(null)
 CALL deldatamartvalueforfilters(null)
 CALL deldatamartdefaultforfilters(null)
 CALL deldatamartreportfilterrforfilters(null)
 CALL dellongtextforfilters(null)
 CALL deldatamarttextforfilters(null)
 CALL delfilters(null)
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme deleted the filters successfully."
 COMMIT
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
