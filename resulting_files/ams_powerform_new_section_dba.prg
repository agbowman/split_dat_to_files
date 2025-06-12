CREATE PROGRAM ams_powerform_new_section:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Directory" = "",
  "Input File" = ""
  WITH outdev, directory, inputfile
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 DECLARE serrmsg = vc WITH protect, noconstant("")
 DECLARE ierrcode = i2 WITH protect, noconstant(0)
 DECLARE bamsassociate = i2 WITH protect, noconstant(false)
 DECLARE smessage = vc WITH protect, noconstant("")
 FREE RECORD rdata
 RECORD rdata(
   1 qual_knt = i4
   1 qual[*]
     2 object_name = vc
     2 user_name = vc
     2 compiled_dt_tm = vc
     2 source_name = vc
 )
 EXECUTE ams_define_toolkit_common
 SET bamsassociate = isamsuser(reqinfo->updt_id)
 IF ( NOT (bamsassociate))
  SET failed = exe_error
  SET serrmsg = "User must be a Cerner AMS associate to run this program from Explorer Menu"
  GO TO exit_script
 ENDIF
 SET path = value(logical( $DIRECTORY))
 SET infile =  $INPUTFILE
 SET file_path = build(path,":",infile)
 CALL echo(build(path,":",infile))
 CALL echo(file_path)
 DEFINE rtl2 value(file_path)
 FREE RECORD lbl_sec_dta
 RECORD lbl_sec_dta(
   1 sections[*]
     2 section_name = vc
     2 section_def = vc
     2 header = vc
     2 label_cnt = i4
     2 labels[*]
       3 lbl_name = vc
     2 dtas[*]
       3 dta_name = vc
       3 dta_width_ind = i2
       3 dta_height_ind = i2
 )
 FREE RECORD orig_sec_data
 RECORD orig_sec_data(
   1 qual[*]
     2 sec_desc = vc
     2 sec_def = vc
     2 header = vc
     2 number = i4
     2 label_desc = vc
     2 dta_desc = vc
     2 dta_wid = i4
     2 dta_height = i4
 )
 DECLARE cnt = i4
 DECLARE lbcnt = i4
 SELECT INTO  $1
  r.line
  FROM rtl2t r
  HEAD REPORT
   row_count = 0
  HEAD r.line
   line1 = r.line
   IF (row_count > 0)
    stat = alterlist(orig_sec_data->qual,row_count), orig_sec_data->qual[row_count].sec_desc = piece(
     r.line,",",1,"not found"), orig_sec_data->qual[row_count].sec_def = piece(r.line,",",2,
     "not found"),
    orig_sec_data->qual[row_count].header = piece(r.line,",",3,"not found"), orig_sec_data->qual[
    row_count].number = cnvtint(piece(r.line,",",4,"not found")), orig_sec_data->qual[row_count].
    label_desc = piece(r.line,",",5,"not found"),
    orig_sec_data->qual[row_count].dta_desc = piece(r.line,",",6,"not found"), orig_sec_data->qual[
    row_count].dta_wid = cnvtint(piece(r.line,",",7,"not found")), orig_sec_data->qual[row_count].
    dta_height = cnvtint(piece(r.line,",",8,"not found"))
   ENDIF
   row_count = (row_count+ 1)
  WITH nocounter
 ;end select
 SET cnt = 0
 CALL echo(size(orig_sec_data->qual,5))
 FOR (i = 1 TO size(orig_sec_data->qual,5))
   IF (trim(orig_sec_data->qual[i].sec_desc) != "")
    SET cnt = (cnt+ 1)
    SET lbcnt = 0
    SET stat = alterlist(lbl_sec_dta->sections,cnt)
    SET lbl_sec_dta->sections[cnt].section_def = orig_sec_data->qual[i].sec_def
    SET lbl_sec_dta->sections[cnt].section_name = orig_sec_data->qual[i].sec_desc
    SET lbl_sec_dta->sections[cnt].header = orig_sec_data->qual[i].header
    SET lbl_sec_dta->sections[cnt].label_cnt = orig_sec_data->qual[i].number
   ENDIF
   SET lbcnt = (lbcnt+ 1)
   SET stat = alterlist(lbl_sec_dta->sections[cnt].labels,lbcnt)
   SET stat = alterlist(lbl_sec_dta->sections[cnt].dtas,lbcnt)
   SET lbl_sec_dta->sections[cnt].labels[lbcnt].lbl_name = orig_sec_data->qual[i].label_desc
   SET lbl_sec_dta->sections[cnt].dtas[lbcnt].dta_name = orig_sec_data->qual[i].dta_desc
   SET lbl_sec_dta->sections[cnt].dtas[lbcnt].dta_width_ind = orig_sec_data->qual[i].dta_wid
   SET lbl_sec_dta->sections[cnt].dtas[lbcnt].dta_height_ind = orig_sec_data->qual[i].dta_height
 ENDFOR
 DECLARE x = i4
 DECLARE init_cnt = i4
 SET x = size(lbl_sec_dta->sections,5)
 SET init_cnt = 0
 FOR (init_cnt = 1 TO size(lbl_sec_dta->sections,5))
   FREE SET request
   RECORD request(
     1 dcp_section_ref_id = f8
     1 description = vc
     1 definition = vc
     1 task_assay_cd = f8
     1 event_cd = f8
     1 active_ind = i2
     1 width = i4
     1 height = i4
     1 updt_cnt = i4
     1 input_list[*]
       2 description = vc
       2 module = vc
       2 input_ref_seq = i4
       2 input_type = i4
       2 nv[*]
         3 pvc_name = vc
         3 pvc_value = vc
         3 merge_name = vc
         3 merge_id = f8
         3 sequence = i2
     1 cki = vc
     1 dcp_forms_ref_id = f8
   )
   SET request->dcp_forms_ref_id = 0.00
   SET request->dcp_section_ref_id = 0.00
   SET request->description = lbl_sec_dta->sections[init_cnt].section_name
   SET request->definition = lbl_sec_dta->sections[init_cnt].section_def
   SET request->task_assay_cd = 0.00
   SET request->event_cd = 0.00
   SET request->cki = ""
   SET request->active_ind = 1
   SET request->width = 860
   SET request->height = 300
   SET request->updt_cnt = 1
   DECLARE cnt = i4
   DECLARE req_size = i4
   DECLARE lbl_top = i4
   DECLARE lbl_height = i4
   DECLARE lbl_left = i4
   DECLARE lbl_width = i4
   DECLARE dta_top = i4
   DECLARE dta_height = i4
   DECLARE dta_left = i4
   DECLARE dta_width = i4
   DECLARE total_width = i4
   DECLARE list_size = i4
   DECLARE list_cnt = i4
   DECLARE i = i4
   DECLARE j = i4
   SET cnt = 1
   SET stat = alterlist(request->input_list,cnt)
   SET request->input_list[cnt].description = "Label"
   SET request->input_list[cnt].module = ""
   SET request->input_list[cnt].input_ref_seq = 1
   SET request->input_list[cnt].input_type = 1
   SET stat = alterlist(request->input_list[cnt].nv,7)
   SET request->input_list[cnt].nv[1].pvc_name = "position"
   SET request->input_list[cnt].nv[1].pvc_value = "10,10,860,46"
   SET request->input_list[cnt].nv[1].merge_name = ""
   SET request->input_list[cnt].nv[1].merge_id = 0.00
   SET request->input_list[cnt].nv[1].sequence = 0
   SET request->input_list[cnt].nv[2].pvc_name = "caption"
   SET request->input_list[cnt].nv[2].pvc_value = lbl_sec_dta->sections[init_cnt].header
   SET request->input_list[cnt].nv[2].merge_name = ""
   SET request->input_list[cnt].nv[2].merge_id = 0
   SET request->input_list[cnt].nv[2].sequence = 0
   SET request->input_list[cnt].nv[3].pvc_name = "baclcolor"
   SET request->input_list[cnt].nv[3].pvc_value = "8454016"
   SET request->input_list[cnt].nv[3].merge_name = ""
   SET request->input_list[cnt].nv[3].merge_id = 0
   SET request->input_list[cnt].nv[3].sequence = 0
   SET request->input_list[cnt].nv[4].pvc_name = "facename"
   SET request->input_list[cnt].nv[4].pvc_value = "Tahoma"
   SET request->input_list[cnt].nv[4].merge_name = ""
   SET request->input_list[cnt].nv[4].merge_id = 0
   SET request->input_list[cnt].nv[4].sequence = 0
   SET request->input_list[cnt].nv[5].pvc_name = "pointsize"
   SET request->input_list[cnt].nv[5].pvc_value = "12"
   SET request->input_list[cnt].nv[5].merge_name = ""
   SET request->input_list[cnt].nv[5].merge_id = 0
   SET request->input_list[cnt].nv[5].sequence = 0
   SET request->input_list[cnt].nv[6].pvc_name = "fonteffects"
   SET request->input_list[cnt].nv[6].pvc_value = "1"
   SET request->input_list[cnt].nv[6].merge_name = ""
   SET request->input_list[cnt].nv[6].merge_id = 0
   SET request->input_list[cnt].nv[6].sequence = 0
   SET request->input_list[cnt].nv[7].pvc_name = "header_role"
   SET request->input_list[cnt].nv[7].pvc_value = "true"
   SET request->input_list[cnt].nv[7].merge_name = ""
   SET request->input_list[cnt].nv[7].merge_id = 0
   SET request->input_list[cnt].nv[7].sequence = 0
   SET i = 0
   SET j = 0
   SET rs_cnt = 0
   SET list_cnt = lbl_sec_dta->sections[init_cnt].label_cnt
   SET stat = alterlist(request->input_list,((list_cnt * 2)+ 1))
   FOR (cnt = (cnt+ 1) TO (list_cnt+ 1))
     SET rs_cnt = (rs_cnt+ 1)
     CALL echo(build("check label left:",lbl_left))
     CALL echo(build("check dta width:",dta_width))
     CALL echo(build("check total width:",total_width))
     IF (i=0
      AND lbl_left < 850)
      SET lbl_left = 10
      SET lbl_top = 66
      SET lbl_width = 195
      SET lbl_height = 20
     ELSEIF (total_width >= 850)
      SET i = 0
      SET lbl_left = 10
      SET lbl_top = ((dta_top+ max_dta_hieght)+ 20)
      SET lbl_width = 195
      SET lbl_height = 20
      SET max_dta_hieght = 36
     ENDIF
     IF (i=0)
      SET i = 1
      SET lbl_left = 10
     ELSE
      SET lbl_left = ((20+ lbl_left)+ dta_width)
     ENDIF
     SET request->input_list[cnt].description = "Label"
     SET request->input_list[cnt].module = ""
     SET request->input_list[cnt].input_ref_seq = cnt
     SET request->input_list[cnt].input_type = 1
     SET stat = alterlist(request->input_list[cnt].nv,6)
     SET request->input_list[cnt].nv[1].pvc_name = "position"
     SET request->input_list[cnt].nv[1].pvc_value = build(lbl_left,",",lbl_top,",",(lbl_width+
      lbl_left),
      ",",(lbl_top+ lbl_height))
     SET request->input_list[cnt].nv[1].merge_name = ""
     SET request->input_list[cnt].nv[1].merge_id = 0.00
     SET request->input_list[cnt].nv[1].sequence = 0
     SET request->input_list[cnt].nv[2].pvc_name = "caption"
     SET request->input_list[cnt].nv[2].pvc_value = lbl_sec_dta->sections[init_cnt].labels[rs_cnt].
     lbl_name
     SET request->input_list[cnt].nv[2].merge_name = ""
     SET request->input_list[cnt].nv[2].merge_id = 0.00
     SET request->input_list[cnt].nv[2].sequence = 0
     SET request->input_list[cnt].nv[3].pvc_name = "backcolor"
     SET request->input_list[cnt].nv[3].pvc_value = "12632256"
     SET request->input_list[cnt].nv[3].merge_name = ""
     SET request->input_list[cnt].nv[3].merge_id = 0.00
     SET request->input_list[cnt].nv[3].sequence = 0
     SET request->input_list[cnt].nv[4].pvc_name = "facename"
     SET request->input_list[cnt].nv[4].pvc_value = "Tahoma"
     SET request->input_list[cnt].nv[4].merge_name = ""
     SET request->input_list[cnt].nv[4].merge_id = 0.00
     SET request->input_list[cnt].nv[4].sequence = 0
     SET request->input_list[cnt].nv[5].pvc_name = "pointsize"
     SET request->input_list[cnt].nv[5].pvc_value = "10"
     SET request->input_list[cnt].nv[5].merge_name = ""
     SET request->input_list[cnt].nv[5].merge_id = 0.00
     SET request->input_list[cnt].nv[5].sequence = 0
     SET request->input_list[cnt].nv[6].pvc_name = "fonteffects"
     SET request->input_list[cnt].nv[6].pvc_value = "1"
     SET request->input_list[cnt].nv[6].merge_name = ""
     SET request->input_list[cnt].nv[6].merge_id = 0.00
     SET request->input_list[cnt].nv[6].sequence = 0
     SET cnt = (cnt+ list_cnt)
     IF (j=0
      AND dta_left < 850)
      SET dta_left = 10
      SET dta_top = 96
      SET max_dta_hieght = 36
     ELSEIF (total_width >= 850)
      SET total_width = 0
      SET j = 0
      SET dta_left = 10
      SET dta_top = ((lbl_top+ 20)+ 10)
     ENDIF
     IF (j=0)
      SET dta_left = 10
      SET j = 1
     ELSE
      SET dta_left = ((20+ dta_left)+ dta_width)
     ENDIF
     IF ((lbl_sec_dta->sections[init_cnt].dtas[rs_cnt].dta_width_ind=1))
      SET dta_width = 195
     ELSEIF ((lbl_sec_dta->sections[init_cnt].dtas[rs_cnt].dta_width_ind=2))
      SET dta_width = ((195 * 2)+ 20)
     ELSEIF ((lbl_sec_dta->sections[init_cnt].dtas[rs_cnt].dta_width_ind=3))
      SET dta_width = ((195 * 3)+ 40)
     ELSEIF ((lbl_sec_dta->sections[init_cnt].dtas[rs_cnt].dta_width_ind=4))
      SET dta_width = ((195 * 4)+ 50)
     ENDIF
     IF ((lbl_sec_dta->sections[init_cnt].dtas[rs_cnt].dta_height_ind=1))
      SET dta_height = 36
     ELSEIF ((lbl_sec_dta->sections[init_cnt].dtas[rs_cnt].dta_height_ind=2))
      SET dta_height = ((36 * 2)+ 20)
     ELSEIF ((lbl_sec_dta->sections[init_cnt].dtas[rs_cnt].dta_height_ind=3))
      SET dta_height = ((36 * 3)+ 40)
     ELSEIF ((lbl_sec_dta->sections[init_cnt].dtas[rs_cnt].dta_height_ind=4))
      SET dta_height = ((36 * 4)+ 50)
     ENDIF
     IF (max_dta_hieght < dta_height)
      SET max_dta_hieght = dta_height
     ENDIF
     IF (dta_left=10)
      SET total_width = ((total_width+ 10)+ dta_width)
     ELSE
      SET total_width = ((total_width+ 20)+ dta_width)
     ENDIF
     IF ((lbl_sec_dta->sections[init_cnt].dtas[rs_cnt].dta_name="Unknown_Type"))
      SET request->input_list[cnt].description = ""
      SET request->input_list[cnt].module = ""
      SET request->input_list[cnt].input_ref_seq = cnt
      SET request->input_list[cnt].input_type = 0
     ELSEIF ((lbl_sec_dta->sections[init_cnt].dtas[rs_cnt].dta_name="FlexUnit_Control"))
      SET request->input_list[cnt].description = ""
      SET request->input_list[cnt].module = ""
      SET request->input_list[cnt].input_ref_seq = cnt
      SET request->input_list[cnt].input_type = 3
     ELSEIF ((lbl_sec_dta->sections[init_cnt].dtas[rs_cnt].dta_name="List_Control"))
      SET request->input_list[cnt].description = ""
      SET request->input_list[cnt].module = ""
      SET request->input_list[cnt].input_ref_seq = cnt
      SET request->input_list[cnt].input_type = 4
     ELSEIF ((lbl_sec_dta->sections[init_cnt].dtas[rs_cnt].dta_name="MAGrid_Control"))
      SET request->input_list[cnt].description = ""
      SET request->input_list[cnt].module = ""
      SET request->input_list[cnt].input_ref_seq = cnt
      SET request->input_list[cnt].input_type = 5
     ELSEIF ((lbl_sec_dta->sections[init_cnt].dtas[rs_cnt].dta_name="FreeText_Control"))
      SET request->input_list[cnt].description = ""
      SET request->input_list[cnt].module = ""
      SET request->input_list[cnt].input_ref_seq = cnt
      SET request->input_list[cnt].input_type = 6
     ELSEIF ((lbl_sec_dta->sections[init_cnt].dtas[rs_cnt].dta_name="Calculation_Control"))
      SET request->input_list[cnt].description = ""
      SET request->input_list[cnt].module = ""
      SET request->input_list[cnt].input_ref_seq = cnt
      SET request->input_list[cnt].input_type = 7
     ELSEIF ((lbl_sec_dta->sections[init_cnt].dtas[rs_cnt].dta_name="StaticUnit_Control"))
      SET request->input_list[cnt].description = ""
      SET request->input_list[cnt].module = ""
      SET request->input_list[cnt].input_ref_seq = cnt
      SET request->input_list[cnt].input_type = 8
     ELSEIF ((lbl_sec_dta->sections[init_cnt].dtas[rs_cnt].dta_name="AlphaCombo_Control"))
      SET request->input_list[cnt].description = ""
      SET request->input_list[cnt].module = ""
      SET request->input_list[cnt].input_ref_seq = cnt
      SET request->input_list[cnt].input_type = 9
     ELSEIF ((lbl_sec_dta->sections[init_cnt].dtas[rs_cnt].dta_name="DateTime_Control"))
      SET request->input_list[cnt].description = ""
      SET request->input_list[cnt].module = ""
      SET request->input_list[cnt].input_ref_seq = cnt
      SET request->input_list[cnt].input_type = 10
     ELSEIF ((lbl_sec_dta->sections[init_cnt].dtas[rs_cnt].dta_name="Allergy_Control"))
      SET request->input_list[cnt].description = ""
      SET request->input_list[cnt].module = ""
      SET request->input_list[cnt].input_ref_seq = cnt
      SET request->input_list[cnt].input_type = 11
     ELSEIF ((lbl_sec_dta->sections[init_cnt].dtas[rs_cnt].dta_name="ImageHolder_Control"))
      SET request->input_list[cnt].description = ""
      SET request->input_list[cnt].module = ""
      SET request->input_list[cnt].input_ref_seq = cnt
      SET request->input_list[cnt].input_type = 12
     ELSEIF ((lbl_sec_dta->sections[init_cnt].dtas[rs_cnt].dta_name="RTFEditor_Control"))
      SET request->input_list[cnt].description = ""
      SET request->input_list[cnt].module = ""
      SET request->input_list[cnt].input_ref_seq = cnt
      SET request->input_list[cnt].input_type = 13
     ELSEIF ((lbl_sec_dta->sections[init_cnt].dtas[rs_cnt].dta_name="Discrete_Grid"))
      SET request->input_list[cnt].description = ""
      SET request->input_list[cnt].module = ""
      SET request->input_list[cnt].input_ref_seq = cnt
      SET request->input_list[cnt].input_type = 14
     ELSEIF ((lbl_sec_dta->sections[init_cnt].dtas[rs_cnt].dta_name="RAlpha_Grid"))
      SET request->input_list[cnt].description = ""
      SET request->input_list[cnt].module = ""
      SET request->input_list[cnt].input_ref_seq = cnt
      SET request->input_list[cnt].input_type = 15
     ELSEIF ((lbl_sec_dta->sections[init_cnt].dtas[rs_cnt].dta_name="Comment_Control"))
      SET request->input_list[cnt].description = ""
      SET request->input_list[cnt].module = ""
      SET request->input_list[cnt].input_ref_seq = cnt
      SET request->input_list[cnt].input_type = 16
     ELSEIF ((lbl_sec_dta->sections[init_cnt].dtas[rs_cnt].dta_name="Power_Grid"))
      SET request->input_list[cnt].description = ""
      SET request->input_list[cnt].module = ""
      SET request->input_list[cnt].input_ref_seq = cnt
      SET request->input_list[cnt].input_type = 17
     ELSEIF ((lbl_sec_dta->sections[init_cnt].dtas[rs_cnt].dta_name="Provider_Control"))
      SET request->input_list[cnt].description = ""
      SET request->input_list[cnt].module = ""
      SET request->input_list[cnt].input_ref_seq = cnt
      SET request->input_list[cnt].input_type = 18
     ELSEIF ((lbl_sec_dta->sections[init_cnt].dtas[rs_cnt].dta_name="Ultra_Grid"))
      SET request->input_list[cnt].description = ""
      SET request->input_list[cnt].module = ""
      SET request->input_list[cnt].input_ref_seq = cnt
      SET request->input_list[cnt].input_type = 19
     ELSEIF ((lbl_sec_dta->sections[init_cnt].dtas[rs_cnt].dta_name="Tracking_Control"))
      SET request->input_list[cnt].description = ""
      SET request->input_list[cnt].module = ""
      SET request->input_list[cnt].input_ref_seq = cnt
      SET request->input_list[cnt].input_type = 20
     ELSEIF ((lbl_sec_dta->sections[init_cnt].dtas[rs_cnt].dta_name="Conversion_Control"))
      SET request->input_list[cnt].description = ""
      SET request->input_list[cnt].module = ""
      SET request->input_list[cnt].input_ref_seq = cnt
      SET request->input_list[cnt].input_type = 21
     ELSEIF ((lbl_sec_dta->sections[init_cnt].dtas[rs_cnt].dta_name="Numeric_Control"))
      SET request->input_list[cnt].description = ""
      SET request->input_list[cnt].module = ""
      SET request->input_list[cnt].input_ref_seq = cnt
      SET request->input_list[cnt].input_type = 22
     ELSEIF ((lbl_sec_dta->sections[init_cnt].dtas[rs_cnt].dta_name="Nomenclature_Control"))
      SET request->input_list[cnt].description = ""
      SET request->input_list[cnt].module = ""
      SET request->input_list[cnt].input_ref_seq = cnt
      SET request->input_list[cnt].input_type = 23
     ELSEIF ((lbl_sec_dta->sections[init_cnt].dtas[rs_cnt].dta_name="Tracking_Control"))
      SET request->input_list[cnt].description = "Tracking Control"
      SET request->input_list[cnt].module = "PVTRACKFORMS"
      SET request->input_list[cnt].input_ref_seq = cnt
      SET request->input_list[cnt].input_type = 1
     ELSEIF ((lbl_sec_dta->sections[init_cnt].dtas[rs_cnt].dta_name="CareNet_Control"))
      SET request->input_list[cnt].description = "Tracking Control"
      SET request->input_list[cnt].module = "PVTRACKFORMS"
      SET request->input_list[cnt].input_ref_seq = cnt
      SET request->input_list[cnt].input_type = 2
     ELSEIF ((lbl_sec_dta->sections[init_cnt].dtas[rs_cnt].dta_name="MedProfile_Control"))
      SET request->input_list[cnt].description = ""
      SET request->input_list[cnt].module = ""
      SET request->input_list[cnt].input_ref_seq = cnt
      SET request->input_list[cnt].input_type = 1
     ELSEIF ((lbl_sec_dta->sections[init_cnt].dtas[rs_cnt].dta_name="ProblemDx_Control"))
      SET request->input_list[cnt].description = "Problem List/Diagnosis"
      SET request->input_list[cnt].module = "PFEXTCTRLS"
      SET request->input_list[cnt].input_ref_seq = cnt
      SET request->input_list[cnt].input_type = 2
     ELSEIF ((lbl_sec_dta->sections[init_cnt].dtas[rs_cnt].dta_name="PregnancyHistory_Control"))
      SET request->input_list[cnt].description = "Pregnancy History"
      SET request->input_list[cnt].module = "PFEXTCTRLS"
      SET request->input_list[cnt].input_ref_seq = cnt
      SET request->input_list[cnt].input_type = 3
     ELSEIF ((lbl_sec_dta->sections[init_cnt].dtas[rs_cnt].dta_name="ProcedureHistory_Control"))
      SET request->input_list[cnt].description = "Procedure History"
      SET request->input_list[cnt].module = "PFEXTCTRLS"
      SET request->input_list[cnt].input_ref_seq = cnt
      SET request->input_list[cnt].input_type = 4
     ELSEIF ((lbl_sec_dta->sections[init_cnt].dtas[rs_cnt].dta_name="FamilyHistory_Control"))
      SET request->input_list[cnt].description = "Family History"
      SET request->input_list[cnt].module = "PFEXTCTRLS"
      SET request->input_list[cnt].input_ref_seq = cnt
      SET request->input_list[cnt].input_type = 5
     ELSEIF ((lbl_sec_dta->sections[init_cnt].dtas[rs_cnt].dta_name="MedList_Control"))
      SET request->input_list[cnt].description = "Medication List"
      SET request->input_list[cnt].module = "PFEXTCTRLS"
      SET request->input_list[cnt].input_ref_seq = cnt
      SET request->input_list[cnt].input_type = 6
     ELSEIF ((lbl_sec_dta->sections[init_cnt].dtas[rs_cnt].dta_name="PastMedHistory_Control"))
      SET request->input_list[cnt].description = "Past Medical History"
      SET request->input_list[cnt].module = "PFEXTCTRLS"
      SET request->input_list[cnt].input_ref_seq = cnt
      SET request->input_list[cnt].input_type = 7
     ELSEIF ((lbl_sec_dta->sections[init_cnt].dtas[rs_cnt].dta_name="SocialHistory_Control"))
      SET request->input_list[cnt].description = "Social History"
      SET request->input_list[cnt].module = "PFEXTCTRLS"
      SET request->input_list[cnt].input_ref_seq = cnt
      SET request->input_list[cnt].input_type = 8
     ELSEIF ((lbl_sec_dta->sections[init_cnt].dtas[rs_cnt].dta_name="CommunicationPreference_Control"
     ))
      SET request->input_list[cnt].description = "Communication Preference"
      SET request->input_list[cnt].module = "PFEXTCTRLS"
      SET request->input_list[cnt].input_ref_seq = cnt
      SET request->input_list[cnt].input_type = 9
     ENDIF
     SET stat = alterlist(request->input_list[cnt].nv,2)
     SET request->input_list[cnt].nv[1].pvc_name = "position"
     SET request->input_list[cnt].nv[1].pvc_value = build(dta_left,",",dta_top,",",(dta_width+
      dta_left),
      ",",(dta_top+ dta_height))
     SET request->input_list[cnt].nv[1].merge_name = ""
     SET request->input_list[cnt].nv[1].merge_id = 0.00
     SET request->input_list[cnt].nv[1].sequence = 0
     SET request->input_list[cnt].nv[2].pvc_name = "discrete_task_assay"
     SET request->input_list[cnt].nv[2].pvc_value = ""
     SET request->input_list[cnt].nv[2].merge_name = "discrete_task_assay"
     SET request->input_list[cnt].nv[2].merge_id = 0.00
     SET request->input_list[cnt].nv[2].sequence = 0
     SET cnt = (cnt - list_cnt)
   ENDFOR
   FREE RECORD reply
   RECORD reply(
     1 dcp_section_ref_id = f8
     1 updt_cnt = i4
     1 status_data
       2 status = c1
       2 subeventstatus[*]
         3 operationname = c8
         3 operationstatus = c1
         3 targetobjectname = c15
         3 targetobjectvalue = c100
   )
   CALL echorecord(request)
   EXECUTE dcp_upd_dcp_sect:dba  WITH replace("REQUEST",request), replace("REPLY",reply)
   CALL echorecord(reply)
 ENDFOR
 SELECT INTO  $OUTDEV
  status = "Succesfully created sections into the powerform tool"
  FROM dummyt d1
  WITH nocounter, format
 ;end select
#exit_script
 IF (failed != false)
  SELECT INTO value( $OUTDEV)
   message = trim(substring(1,200,serrmsg),3)
   FROM (dummyt d  WITH seq = 1)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
 IF (failed != exe_error)
  CALL updtdminfo(trim(cnvtupper(curprog),3))
 ENDIF
END GO
