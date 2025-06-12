CREATE PROGRAM ams_del_oef_fields:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Directory" = "",
  "Input File" = ""
  WITH outdev, directory, inputfile
 DECLARE order_var = f8 WITH constant(uar_get_code_by("MEANING",6003,"ORDER")), protect
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
 SET vfailed = false
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
  SET vfailed = exe_error
  SET serrmsg = "User must be a Cerner AMS associate to run this program from Explorer Menu"
  GO TO exit_script
 ENDIF
 SET path = value(logical( $DIRECTORY))
 SET infile =  $INPUTFILE
 SET file_path = build(path,":",infile)
 CALL echo(build(path,":",infile))
 CALL echo(file_path)
 DEFINE rtl2 value(file_path)
 FREE RECORD orig_data
 RECORD orig_data(
   1 qual[*]
     2 format_name = vc
     2 field_desc = vc
 )
 FREE RECORD format_fields
 RECORD format_fields(
   1 formats[*]
     2 format_name = vc
     2 fields[*]
       3 field_desc = vc
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
    stat = alterlist(orig_data->qual,row_count), orig_data->qual[row_count].format_name = piece(r
     .line,",",1,"not found"), orig_data->qual[row_count].field_desc = piece(r.line,",",2,"not found"
     )
   ENDIF
   row_count = (row_count+ 1)
  WITH nocounter
 ;end select
 CALL echorecord(orig_data)
 SET cnt = 0
 CALL echo(size(orig_data->qual,5))
 FOR (i = 1 TO size(orig_data->qual,5))
   IF (trim(orig_data->qual[i].format_name) != "")
    SET cnt = (cnt+ 1)
    SET lbcnt = 0
    SET stat = alterlist(format_fields->formats,cnt)
    SET format_fields->formats[cnt].format_name = orig_data->qual[i].format_name
   ENDIF
   SET lbcnt = (lbcnt+ 1)
   SET stat = alterlist(format_fields->formats[cnt].fields,lbcnt)
   SET format_fields->formats[cnt].fields[lbcnt].field_desc = orig_data->qual[i].field_desc
 ENDFOR
 CALL echorecord(format_fields)
 FREE RECORD del_fields
 RECORD del_fields(
   1 qual[*]
     2 format_name = c200
     2 field_qual[*]
       3 field_name = c200
       3 deleted = i2
 )
 DECLARE format_idex = i4
 DECLARE field_idex = i4
 DECLARE found = i2
 SET format_idex = 0
 SET field_idex = 0
 FOR (format_idex = 1 TO value(size(format_fields->formats,5)))
   SET found = 0
   SET stat = alterlist(del_fields->qual,format_idex)
   FOR (field_idex = 1 TO value(size(format_fields->formats[format_idex].fields,5)))
    SET stat = alterlist(del_fields->qual[format_idex].field_qual,field_idex)
    SELECT
     found_cnt = count(off.oe_field_id)
     FROM oe_format_fields off
     WHERE off.oe_format_id IN (
     (SELECT
      oef.oe_format_id
      FROM order_entry_format oef
      WHERE (oef.oe_format_name=format_fields->formats[format_idex].format_name)))
      AND off.oe_field_id IN (
     (SELECT
      oef.oe_field_id
      FROM order_entry_fields oef
      WHERE (oef.description=format_fields->formats[format_idex].fields[field_idex].field_desc)))
     DETAIL
      found = cnvtint(found_cnt),
      CALL echo("found"),
      CALL echo(found)
      IF (found=0)
       CALL echo("inside if"), del_fields->qual[format_idex].format_name = format_fields->formats[
       format_idex].format_name, del_fields->qual[format_idex].field_qual[field_idex].field_name =
       format_fields->formats[format_idex].fields[field_idex].field_desc,
       del_fields->qual[format_idex].field_qual[field_idex].deleted = 0
      ELSE
       del_fields->qual[format_idex].field_qual[field_idex].deleted = 1
      ENDIF
     WITH nocounter
    ;end select
   ENDFOR
 ENDFOR
 SET x = size(format_fields->formats,5)
 SET init_cnt = 0
 FOR (init_cnt = 1 TO value(size(format_fields->formats,5)))
   FREE SET request_new
   RECORD request_new(
     1 oe_format_id = f8
     1 oe_field_id = f8
     1 action_type_cd = f8
   )
   SET reqinfo->updt_id = reqinfo->updt_id
   SET reqinfo->updt_task = 0
   SELECT
    oef.oe_format_id
    FROM order_entry_format oef
    WHERE (oef.oe_format_name=format_fields->formats[init_cnt].format_name)
    ORDER BY oef.oe_format_id
    HEAD oef.oe_format_id
     request_new->oe_format_id = oef.oe_format_id
    WITH nocounter
   ;end select
   FOR (sub_cnt = 1 TO size(format_fields->formats[init_cnt].fields,5))
     SELECT
      oef.oe_field_id
      FROM order_entry_fields oef
      WHERE (oef.description=format_fields->formats[init_cnt].fields[sub_cnt].field_desc)
      ORDER BY oef.oe_field_id
      HEAD oef.oe_field_id
       request_new->oe_field_id = oef.oe_field_id
      WITH nocounter
     ;end select
     SET request_new->action_type_cd = order_var
     CALL echorecord(request_new)
     EXECUTE orm_del_fmtflds:dba  WITH replace("REQUEST",request_new), replace("REPLY",reply)
   ENDFOR
 ENDFOR
 SELECT INTO  $1
  qual_format_name = del_fields->qual[d1.seq].format_name, qual_field_name = del_fields->qual[d1.seq]
  .field_qual[d2.seq].field_name, qual_deleted = del_fields->qual[d1.seq].field_qual[d2.seq].deleted
  FROM (dummyt d1  WITH seq = value(size(del_fields->qual,5))),
   (dummyt d2  WITH seq = 1)
  PLAN (d1
   WHERE maxrec(d2,size(del_fields->qual[d1.seq].field_qual,5)))
   JOIN (d2)
  ORDER BY qual_format_name
  HEAD REPORT
   row + 0
  HEAD qual_deleted
   cnt = 0, row + 1
   IF (qual_deleted=0)
    col 10, "Following fields were NOT DELETED from the respected formats", row + 1
   ENDIF
  DETAIL
   IF (qual_deleted=0)
    cnt = (cnt+ 1), col 15, qual_format_name,
    col 30, qual_field_name, row + 1
   ENDIF
  FOOT  qual_deleted
   row + 1
   IF (qual_deleted=0)
    col 10, "Total number of formats NOT updated :", col 50,
    cnt, row + 1, col 10,
"check for these Fileds whether they were associated with the format or not OR Given 				field name is not there in the Dat\
abase\
", row + 1
   ENDIF
  FOOT REPORT
   CALL echo("cnt"),
   CALL echo(cnt)
   IF (cnt > 0)
    col 10, "some of the given fields are updated", row + 1
   ELSE
    col 10, "All of the given fields are updated", row + 1
   ENDIF
  WITH nocounter, separator = " ", format,
   maxcol = 300
 ;end select
#exit_script
 IF (vfailed != false)
  SELECT INTO value( $OUTDEV)
   message = trim(substring(1,200,serrmsg),3)
   FROM (dummyt d  WITH seq = 1)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
 IF (vfailed != exe_error)
  CALL updtdminfo(trim(cnvtupper(curprog),3))
 ENDIF
END GO
