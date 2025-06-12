CREATE PROGRAM ams_ppr_filter_serv:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select the Directory" = "",
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
 SET script_failed = false
 SET table_name = fillstring(50," ")
 DECLARE serrmsg = vc WITH protect, noconstant("")
 DECLARE ierrcode = i2 WITH protect, noconstant(0)
 DECLARE bamsassociate = i2 WITH protect, noconstant(false)
 EXECUTE ams_define_toolkit_common
 SET bamsassociate = isamsuser(reqinfo->updt_id)
 IF ( NOT (bamsassociate))
  SET script_failed = exe_error
  SET serrmsg = "User must be a Cerner AMS associate to run this program from Explorer Menu"
  GO TO exit_script
 ENDIF
 SET path = value(logical( $DIRECTORY))
 SET infile =  $INPUTFILE
 SET file_path = build(path,":",infile)
 CALL echo(build(path,":",infile))
 CALL echo(file_path)
 FREE RECORD temp
 RECORD temp(
   1 list[*]
     2 facility = vc
     2 code_set = vc
     2 val = vc
 )
 FREE RECORD rc
 RECORD rc(
   1 list[*]
     2 facility = f8
     2 code_set = f8
     2 value[*]
       3 val = f8
 )
 FREE RECORD fac
 RECORD fac(
   1 fcnt = i4
   1 list[*]
     2 fac_name = vc
 )
 FREE RECORD req_data
 RECORD req_data(
   1 validate_refdata_ind = i2
   1 delete_all_ind = i2
   1 filter_entity[*]
     2 filter_type_cd = f8
     2 filter_type_data_id = f8
     2 filter_entity1_id = f8
     2 filter_entity1_name = vc
     2 filter_entity2_id = f8
     2 filter_entity2_name = vc
     2 filter_entity3_id = f8
     2 filter_entity3_name = vc
     2 filter_entity4_id = f8
     2 filter_entity4_name = vc
     2 filter_entity5_id = f8
     2 filter_entity5_name = vc
     2 status = i2
     2 action_flag = i2
     2 children_exist_ind = i2
     2 safe_for_action = i2
     2 values[*]
       3 parent_entity_id = f8
       3 parent_entity_name = vc
       3 exclusion_filter_ind = i2
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 filter_entity_reltn_id = f8
       3 action_flag_values = i2
       3 status_values = i2
       3 validated_data = i2
 )
 DEFINE rtl2 value(file_path)
 SELECT
  r.line
  FROM rtl2t r
  HEAD REPORT
   row_count = 0, count = 0, stat = alterlist(temp->list,10)
  HEAD r.line
   line1 = r.line,
   CALL echo(line1)
   IF (size(trim(line1),1) > 0)
    count = (count+ 1)
    IF (count > 1)
     row_count = (row_count+ 1)
     IF (mod(row_count,10)=0)
      stat = alterlist(temp->list,(row_count+ 9))
     ENDIF
     temp->list[row_count].facility = piece(r.line,",",1,"0"), temp->list[row_count].code_set = piece
     (r.line,",",2,"0"), temp->list[row_count].val = piece(r.line,",",3,"0")
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(temp->list,count)
  WITH nocounter
 ;end select
 SET fac_cnt = 0
 SET f_cnt = 0
 FOR (i = 1 TO size(temp->list,5))
  IF ((temp->list[i].facility != ""))
   SET val_cnt = 0
   SET f_flag = 0
   SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.display_key=cnvtupper(temp->list[i].facility)
     AND cv.code_set=220
     AND cv.active_ind=1
    HEAD REPORT
     fac_cnt = (fac_cnt+ 1), stat = alterlist(rc->list,fac_cnt), rc->list[fac_cnt].facility = cv
     .code_value
    WITH nocounter
   ;end select
   IF (curqual <= 0.00)
    SET f_cnt = (f_cnt+ 1)
    SET f_flag = 1
    SET stat = alterlist(fac->list,f_cnt)
    SET fac->list[f_cnt].fac_name = temp->list[i].facility
    SET fac->fcnt = f_cnt
   ENDIF
  ENDIF
  IF (f_flag != 1)
   IF ((temp->list[i].code_set != ""))
    SET var = cnvtupper(replace(piece(temp->list[i].code_set,"-",2,"not found")," ",""))
    SELECT
     cv.code_value
     FROM code_value cv
     WHERE cv.display_key=var
      AND cv.active_ind=1
     HEAD REPORT
      rc->list[fac_cnt].code_set = cv.code_value
     WITH nocounter
    ;end select
   ENDIF
   IF ((temp->list[i].val != ""))
    SET val_cnt = (val_cnt+ 1)
    SET stat = alterlist(rc->list[fac_cnt].value,val_cnt)
    SELECT
     cv.code_value
     FROM code_value cv
     WHERE cnvtupper(cv.description)=cnvtupper(trim(temp->list[i].val))
      AND cv.code_set=34
      AND cv.active_ind=1
     HEAD REPORT
      rc->list[fac_cnt].value[val_cnt].val = cv.code_value
     WITH nocounter
    ;end select
   ENDIF
  ENDIF
 ENDFOR
 SET fil_cnt = 0
 FOR (i = 1 TO size(rc->list,5))
   SET fil_cnt = (fil_cnt+ 1)
   SET val_cnt = 0
   SELECT INTO "nl:"
    fer.filter_entity1_id, fer.filter_entity1_name, fer.filter_type_cd,
    fer.parent_entity_id, fer.parent_entity_name, fer.filter_entity_reltn_id
    FROM filter_entity_reltn fer,
     filter_type_data ftd
    PLAN (ftd
     WHERE (ftd.filter_entity1_id=rc->list[i].facility)
      AND (ftd.filter_type_cd=rc->list[i].code_set))
     JOIN (fer
     WHERE fer.filter_type_cd=ftd.filter_type_cd
      AND fer.filter_entity1_id=ftd.filter_entity1_id
      AND fer.filter_entity1_name=ftd.filter_entity1_name)
    HEAD ftd.filter_entity1_id
     stat = alterlist(req_data->filter_entity,fil_cnt), req_data->filter_entity[fil_cnt].
     filter_type_cd = ftd.filter_type_cd, req_data->filter_entity[fil_cnt].filter_entity1_id = ftd
     .filter_entity1_id,
     req_data->filter_entity[fil_cnt].filter_entity1_name = ftd.filter_entity1_name, req_data->
     filter_entity[fil_cnt].filter_type_data_id = ftd.filter_type_data_id
    DETAIL
     val_cnt = (val_cnt+ 1), stat = alterlist(req_data->filter_entity[fil_cnt].values,val_cnt),
     req_data->filter_entity[fil_cnt].values[val_cnt].filter_entity_reltn_id = fer
     .filter_entity_reltn_id,
     req_data->filter_entity[fil_cnt].values[val_cnt].parent_entity_id = fer.parent_entity_id,
     req_data->filter_entity[fil_cnt].values[val_cnt].parent_entity_name = fer.parent_entity_name
    WITH nocounter
   ;end select
   SET stat = alterlist(req_data->filter_entity,fil_cnt)
   SET req_data->filter_entity[fil_cnt].filter_entity1_id = rc->list[fil_cnt].facility
   SET req_data->filter_entity[fil_cnt].filter_entity1_name = "LOCATION"
   SET req_data->filter_entity[fil_cnt].filter_type_cd = rc->list[fil_cnt].code_set
   SET req_data->filter_entity[fil_cnt].action_flag = 1
   FOR (j = 1 TO size(rc->list[fil_cnt].value,5))
     SET val_cnt = (val_cnt+ 1)
     SET stat = alterlist(req_data->filter_entity[fil_cnt].values,val_cnt)
     SET req_data->filter_entity[fil_cnt].values[val_cnt].parent_entity_id = rc->list[fil_cnt].value[
     j].val
     SET req_data->filter_entity[fil_cnt].values[val_cnt].parent_entity_name = "CODE_VALUE"
     SET req_data->filter_entity[fil_cnt].values[val_cnt].action_flag_values = 1
   ENDFOR
 ENDFOR
 SET req_data->validate_refdata_ind = 1.00
 EXECUTE ppr_ens_filter_ref  WITH replace(request,req_data)
 IF ((fac->fcnt=0))
  SELECT INTO  $OUTDEV
   status = "Succesfully Moved"
   FROM dummyt d1
  ;end select
 ELSE
  SELECT INTO  $OUTDEV
   fac_name = fac->list[d.seq].fac_name
   FROM (dummyt d  WITH seq = value(size(fac->list,5)))
   PLAN (d)
   HEAD REPORT
    col 0, "Errors in file data :", row + 1,
    col 10, "Facilty Name"
   DETAIL
    col 25, fac_name, row + 1
   WITH nocounter, format
  ;end select
 ENDIF
 IF (script_failed != false)
  SELECT INTO value( $OUTDEV)
   message = trim(substring(1,200,serrmsg),3)
   FROM (dummyt d  WITH seq = 1)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
 IF (script_failed != exe_error)
  CALL updtdminfo(trim(cnvtupper(curprog),3))
 ENDIF
END GO
