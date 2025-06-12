CREATE PROGRAM ams_reference_text
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "File Name" = "",
  "Path" = ""
  WITH outdev, file, path
 DECLARE rcnt = i4
 DECLARE row_count = i4
 FREE RECORD temp
 RECORD temp(
   1 qual[*]
     2 flag = i4
     2 text_type_cd = vc
     2 text = vc
     2 comments = vc
     2 facility = vc
     2 order_name = vc
 )
 FREE RECORD request
 RECORD request(
   1 parent_entity_id = f8
   1 parent_entity_name = vc
   1 ref_text_mask = i4
   1 text_type_list[*]
     2 text_type_cd = f8
     2 variation_list[*]
       3 ref_text_variation_id = f8
       3 ref_text_name = vc
       3 variation_state_flag = i2
       3 default_flag = i2
       3 version_list[*]
         4 ref_text_version_id = f8
         4 long_blob_id = f8
         4 long_blob = gvc
         4 active_ind = i2
         4 begin_dt_tm = dq8
         4 end_dt_tm = dq8
         4 auto_invoke_prep_ind = i2
         4 version_state_flag = i2
       3 facility_list[*]
         4 facility_cd = f8
 )
 FREE RECORD request_update
 RECORD request_update(
   1 parent_entity_id = f8
   1 parent_entity_name = vc
   1 ref_text_mask = i4
   1 text_type_list[*]
     2 text_type_cd = f8
     2 variation_list[*]
       3 ref_text_variation_id = f8
       3 ref_text_name = vc
       3 variation_state_flag = i2
       3 default_flag = i2
       3 version_list[*]
         4 ref_text_version_id = f8
         4 long_blob_id = f8
         4 long_blob = gvc
         4 active_ind = i2
         4 begin_dt_tm = dq8
         4 end_dt_tm = dq8
         4 auto_invoke_prep_ind = i2
         4 version_state_flag = i2
       3 facility_list[*]
         4 facility_cd = f8
 )
 SET path = value(logical(trim( $PATH)))
 SET file =  $FILE
 SET file_name = build(path,"/",file)
 DEFINE rtl2 value(file_name)
 SELECT
  r.line
  FROM rtl2t r
  HEAD REPORT
   row_count = 0, i = 0, count = 0,
   stat = alterlist(temp->qual,10)
  HEAD r.line
   line1 = r.line,
   CALL echo(line1), i
   IF (size(trim(line1),1) > 0)
    count = (count+ 1)
    IF (count > 1)
     row_count = (row_count+ 1)
     IF (mod(row_count,10)=1
      AND row_count > 10)
      stat = alterlist(temp->qual,(row_count+ 9))
     ENDIF
     temp->qual[row_count].flag = cnvtint(piece(line1,",",1,"Not Found")), temp->qual[row_count].
     text_type_cd = piece(line1,",",2,"Not Found"), temp->qual[row_count].text = piece(line1,",",3,
      "Not Found"),
     temp->qual[row_count].comments = piece(line1,",",4,"Not Found"), temp->qual[row_count].facility
      = piece(line1,",",5,"Not Found"), temp->qual[row_count].order_name = piece(line1,",",6,
      "Not Found")
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(temp->qual,row_count)
  WITH nocounter, format, separator = ""
 ;end select
 CALL echo(build("Size:",value(size(temp->qual,5))))
 SET rcnt = 0
 SET rcnt_upd = 0
 FOR (i = 1 TO value(size(temp->qual,5)))
   IF ((temp->qual[i].flag=0))
    CALL echo("username")
    CALL echo(cnvtupper(temp->qual[i].order_name))
    SELECT
     cv.code_value
     FROM code_value cv
     WHERE cv.code_set=200
      AND cnvtupper(cv.display)=cnvtupper(temp->qual[i].order_name)
     DETAIL
      request->parent_entity_id = cv.code_value
     WITH nocounter
    ;end select
    SET request->parent_entity_name = "ORDER_CATALOG"
    SET request->ref_text_mask = 0
    SET refcnt = 0
    SET rcnt = (rcnt+ 1)
    SET stat = alterlist(request->text_type_list,rcnt)
    SELECT
     cv.code_value
     FROM code_value cv
     WHERE cnvtupper(cv.display)=cnvtupper(temp->qual[i].text_type_cd)
     DETAIL
      request->text_type_list[rcnt].text_type_cd = cv.code_value
     WITH nocounter
    ;end select
    SET stat = alterlist(request->text_type_list[rcnt].variation_list,rcnt)
    SET request->text_type_list[rcnt].variation_list[rcnt].ref_text_variation_id = 0.0
    SET request->text_type_list[rcnt].variation_list[rcnt].ref_text_name = temp->qual[i].text
    SET request->text_type_list[rcnt].variation_list[rcnt].variation_state_flag = 2
    SET request->text_type_list[rcnt].variation_list[rcnt].default_flag = 0
    SET stat = alterlist(request->text_type_list[rcnt].variation_list[rcnt].version_list,rcnt)
    SET request->text_type_list[rcnt].variation_list[rcnt].version_list[rcnt].ref_text_version_id =
    0.00
    SET request->text_type_list[rcnt].variation_list[rcnt].version_list[rcnt].long_blob_id = 0.00
    SET rhead = concat("{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss Arial;}}",
     "{\colortbl;\red0\green0\blue0;\red255\green255\blue255;}\deftab1134")
    SET reol = "\par "
    SET wr = "\plain \f0 \fs18 \cb2 "
    SET reftext = temp->qual[i].comments
    SET long_blob_text = concat(rhead,wr,reftext,reol)
    SET request->text_type_list[rcnt].variation_list[rcnt].version_list[rcnt].long_blob =
    long_blob_text
    SET request->text_type_list[rcnt].variation_list[rcnt].version_list[rcnt].active_ind = 1
    SET request->text_type_list[rcnt].variation_list[rcnt].version_list[rcnt].begin_dt_tm =
    cnvtdatetime(curdate,curtime)
    SET request->text_type_list[rcnt].variation_list[rcnt].version_list[rcnt].end_dt_tm =
    cnvtdatetime((curdate+ 30),curtime)
    SET request->text_type_list[rcnt].variation_list[rcnt].version_list[rcnt].auto_invoke_prep_ind =
    0
    SET request->text_type_list[rcnt].variation_list[rcnt].version_list[rcnt].version_state_flag = 2
    SET stat = alterlist(request->text_type_list[rcnt].variation_list[rcnt].facility_list,rcnt)
    SELECT
     cv.*
     FROM code_value cv
     WHERE cv.cdf_meaning="FACILITY"
      AND cnvtupper(cv.display)=cnvtupper(temp->qual[i].facility)
     DETAIL
      request->text_type_list[rcnt].variation_list[rcnt].facility_list[rcnt].facility_cd = cv
      .code_value
     WITH nocounter
    ;end select
    CALL echorecord(request)
    EXECUTE orm_add_ref_text:dba  WITH replace("REQUEST",request)
    FREE RECORD request
    RECORD request(
      1 parent_entity_id = f8
      1 parent_entity_name = vc
      1 ref_text_mask = i4
      1 text_type_list[*]
        2 text_type_cd = f8
        2 variation_list[*]
          3 ref_text_variation_id = f8
          3 ref_text_name = vc
          3 variation_state_flag = i2
          3 default_flag = i2
          3 version_list[*]
            4 ref_text_version_id = f8
            4 long_blob_id = f8
            4 long_blob = gvc
            4 active_ind = i2
            4 begin_dt_tm = dq8
            4 end_dt_tm = dq8
            4 auto_invoke_prep_ind = i2
            4 version_state_flag = i2
          3 facility_list[*]
            4 facility_cd = f8
    )
    SET rcnt = 0
   ELSE
    CALL echo("username")
    CALL echo(cnvtupper(temp->qual[i].order_name))
    SELECT
     cv.code_value
     FROM code_value cv
     WHERE cv.code_set=200
      AND cnvtupper(cv.display)=cnvtupper(temp->qual[i].order_name)
     DETAIL
      request_update->parent_entity_id = cv.code_value
     WITH nocounter
    ;end select
    SET request_update->parent_entity_name = "ORDER_CATALOG"
    SET request_update->ref_text_mask = 0
    SET refcnt = 0
    SET rcnt_upd = (rcnt_upd+ 1)
    SET stat = alterlist(request_update->text_type_list,rcnt_upd)
    SELECT
     cv.code_value
     FROM code_value cv
     WHERE cnvtupper(cv.display)=cnvtupper(temp->qual[i].text_type_cd)
     DETAIL
      request_update->text_type_list[rcnt_upd].text_type_cd = cv.code_value
     WITH nocounter
    ;end select
    SET stat = alterlist(request_update->text_type_list[rcnt_upd].variation_list,rcnt_upd)
    SELECT
     rtv.ref_text_variation_id
     FROM ref_text_variation rtv,
      code_value cv
     WHERE cv.code_set=200
      AND cnvtupper(cv.display)=cnvtupper(temp->qual[i].order_name)
      AND rtv.parent_entity_id=cv.code_value
     DETAIL
      request_update->text_type_list[rcnt_upd].variation_list[rcnt_upd].ref_text_variation_id = rtv
      .ref_text_variation_id
     WITH nocounter
    ;end select
    SET request_update->text_type_list[rcnt_upd].variation_list[rcnt_upd].ref_text_name = temp->qual[
    i].text
    SET request_update->text_type_list[rcnt_upd].variation_list[rcnt_upd].variation_state_flag = 4
    SET request_update->text_type_list[rcnt_upd].variation_list[rcnt_upd].default_flag = 0
    SET stat = alterlist(request_update->text_type_list[rcnt_upd].variation_list[rcnt_upd].
     version_list,rcnt_upd)
    SET request_update->text_type_list[rcnt_upd].variation_list[rcnt_upd].version_list[rcnt_upd].
    ref_text_version_id = 0.00
    SELECT
     rtv.ref_text_variation_id
     FROM long_blob_reference lbr,
      code_value cv
     WHERE cv.code_set=200
      AND cnvtupper(cv.display)=cnvtupper(temp->qual[i].order_name)
      AND lbr.parent_entity_id=cv.code_value
     DETAIL
      request_update->text_type_list[rcnt_upd].variation_list[rcnt_upd].version_list[rcnt_upd].
      long_blob_id = lbr.long_blob_id
     WITH nocounter
    ;end select
    SET rhead = concat("{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss Arial;}}",
     "{\colortbl;\red0\green0\blue0;\red255\green255\blue255;}\deftab1134")
    SET reol = "\par "
    SET wr = "\plain \f0 \fs18 \cb2 "
    SET reftext = temp->qual[i].comments
    SET long_blob_text = concat(rhead,wr,reftext,reol)
    SET request_update->text_type_list[rcnt_upd].variation_list[rcnt_upd].version_list[rcnt_upd].
    long_blob = long_blob_text
    SET request_update->text_type_list[rcnt_upd].variation_list[rcnt_upd].version_list[rcnt_upd].
    active_ind = 1
    SET request_update->text_type_list[rcnt_upd].variation_list[rcnt_upd].version_list[rcnt_upd].
    begin_dt_tm = cnvtdatetime(curdate,curtime)
    SET request_update->text_type_list[rcnt_upd].variation_list[rcnt_upd].version_list[rcnt_upd].
    end_dt_tm = cnvtdatetime((curdate+ 30),curtime)
    SET request_update->text_type_list[rcnt_upd].variation_list[rcnt_upd].version_list[rcnt_upd].
    auto_invoke_prep_ind = 0
    SET request_update->text_type_list[rcnt_upd].variation_list[rcnt_upd].version_list[rcnt_upd].
    version_state_flag = 2
    SET stat = alterlist(request_update->text_type_list[rcnt_upd].variation_list[rcnt_upd].
     facility_list,rcnt_upd)
    SELECT
     cv.*
     FROM code_value cv
     WHERE cv.cdf_meaning="FACILITY"
      AND cnvtupper(cv.display)=cnvtupper(temp->qual[i].facility)
     DETAIL
      request_update->text_type_list[rcnt_upd].variation_list[rcnt_upd].facility_list[rcnt_upd].
      facility_cd = cv.code_value
     WITH nocounter
    ;end select
    CALL echorecord(request_update)
    EXECUTE orm_upd_ref_text:dba  WITH replace("REQUEST",request_update)
    FREE RECORD request_update
    RECORD request_update(
      1 parent_entity_id = f8
      1 parent_entity_name = vc
      1 ref_text_mask = i4
      1 text_type_list[*]
        2 text_type_cd = f8
        2 variation_list[*]
          3 ref_text_variation_id = f8
          3 ref_text_name = vc
          3 variation_state_flag = i2
          3 default_flag = i2
          3 version_list[*]
            4 ref_text_version_id = f8
            4 long_blob_id = f8
            4 long_blob = gvc
            4 active_ind = i2
            4 begin_dt_tm = dq8
            4 end_dt_tm = dq8
            4 auto_invoke_prep_ind = i2
            4 version_state_flag = i2
          3 facility_list[*]
            4 facility_cd = f8
    )
    SET rcnt_upd = 0
   ENDIF
 ENDFOR
 SET last_mod = "000 09/29/2015 KP035208  Initial Release"
END GO
