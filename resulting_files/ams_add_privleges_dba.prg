CREATE PROGRAM ams_add_privleges:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Directory" = "",
  "Pass Input File name Here" = ""
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
 FREE RECORD privdata
 RECORD privdata(
   1 privilege[*]
     2 position = vc
     2 privilege = vc
     2 privilegevalue = vc
 )
 FREE RECORD data
 RECORD data(
   1 qual[*]
     2 privilegevaluecd = f8
     2 loggroupcd = f8
     2 privilegecd = f8
     2 contextlist[*]
       3 personid = f8
       3 positioncd = f8
       3 pprcd = f8
       3 locationcd = f8
     2 exceptionlist[*]
       3 exceptiontypecd = f8
       3 exceptionentityname = c40
       3 exceptionid = f8
       3 eventsetname = c100
     2 grouplist[*]
       3 log_grouping_cd = f8
 )
 SELECT INTO "nl:"
  r.line
  FROM rtl2t r
  HEAD REPORT
   row_count = 0, i = 0, header_flag = 0,
   stat = alterlist(privdata->privilege,10)
  HEAD r.line
   line1 = r.line,
   CALL echo(line1)
   IF (size(trim(line1),1) > 0)
    header_flag = (header_flag+ 1)
    IF (header_flag > 1)
     row_count = (row_count+ 1)
     IF (mod(row_count,10)=1
      AND row_count > 10)
      stat = alterlist(privdata->privilege,(row_count+ 9))
     ENDIF
     privdata->privilege[row_count].position = piece(r.line,",",1,"Not Found"), privdata->privilege[
     row_count].privilege = piece(r.line,",",2,"Not Found"), privdata->privilege[row_count].
     privilegevalue = piece(r.line,",",3,"Not Found")
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(privdata->privilege,row_count)
  WITH nocounter, format, separator = ""
 ;end select
 SET row_count = 0
 SET cnt = 0
 FOR (i = 1 TO size(privdata->privilege,5))
   IF (i > 1)
    SET j = (i - 1)
   ELSE
    SET j = 1
   ENDIF
   IF (i=1)
    SELECT INTO "nl:"
     cv.code_value
     FROM code_value cv
     PLAN (cv
      WHERE cv.display_key=cnvtupper(cnvtalphanum(privdata->privilege[i].privilege))
       AND cv.code_set=6016
       AND cv.active_ind=1)
     HEAD cv.code_value
      cnt = (cnt+ 1), stat = alterlist(data->qual,cnt), data->qual[cnt].privilegecd = cv.code_value
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     cv.code_value
     FROM code_value cv
     PLAN (cv
      WHERE cv.display_key=cnvtupper(cnvtalphanum(privdata->privilege[i].privilegevalue))
       AND cv.code_set=6017
       AND cv.active_ind=1)
     HEAD cv.code_value
      data->qual[cnt].privilegevaluecd = cv.code_value
     WITH nocounter
    ;end select
   ELSEIF ((privdata->privilege[j].privilege != privdata->privilege[i].privilege))
    SELECT INTO "nl:"
     cv.code_value
     FROM code_value cv
     PLAN (cv
      WHERE cv.display_key=cnvtupper(cnvtalphanum(privdata->privilege[i].privilege))
       AND cv.code_set=6016
       AND cv.active_ind=1)
     HEAD cv.code_value
      cnt = (cnt+ 1), stat = alterlist(data->qual,cnt), data->qual[cnt].privilegecd = cv.code_value
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     cv.code_value
     FROM code_value cv
     PLAN (cv
      WHERE cv.display_key=cnvtupper(cnvtalphanum(privdata->privilege[i].privilegevalue))
       AND cv.code_set=6017
       AND cv.active_ind=1)
     HEAD cv.code_value
      data->qual[cnt].privilegevaluecd = cv.code_value
     WITH nocounter
    ;end select
    SET j = i
    SET row_count = 0
   ENDIF
   IF ((privdata->privilege[j].privilege=privdata->privilege[i].privilege))
    SELECT INTO "nl:"
     cv.code_value
     FROM code_value cv
     PLAN (cv
      WHERE cv.display_key=cnvtupper(cnvtalphanum(privdata->privilege[i].position))
       AND cv.code_set=88
       AND cv.active_ind=1)
     HEAD cv.code_value
      row_count = (row_count+ 1), stat = alterlist(data->qual[cnt].contextlist,row_count),
      CALL echo(row_count),
      data->qual[cnt].contextlist[row_count].positioncd = cv.code_value
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
 RECORD request1(
   1 privilegevaluecd = f8
   1 loggroupcd = f8
   1 privilegecd = f8
   1 contextlist[*]
     2 personid = f8
     2 positioncd = f8
     2 pprcd = f8
     2 locationcd = f8
   1 exceptionlist[*]
     2 exceptiontypecd = f8
     2 exceptionentityname = c40
     2 exceptionid = f8
     2 eventsetname = c100
   1 grouplist[*]
     2 log_grouping_cd = f8
   1 activityprivdefid = f8
 )
 SET var = 0
 SET var1 = 0
 FOR (var = 1 TO size(data->qual,5))
   SET request1->privilegevaluecd = data->qual[var].privilegevaluecd
   SET request1->privilegecd = data->qual[var].privilegecd
   SET j = 0
   SET cnt = 0
   FOR (var1 = 1 TO size(data->qual[var].contextlist,5))
     SET cnt = (cnt+ 1)
     SET stat = alterlist(request1->contextlist,cnt)
     SET request1->contextlist[cnt].positioncd = data->qual[var].contextlist[var1].positioncd
   ENDFOR
   EXECUTE dcp_add_privilege:dba  WITH replace("REQUEST",request1)
 ENDFOR
 SELECT INTO "AMS_Add_Privilege_Output.csv"
  privilege = uar_get_code_display(p.privilege_cd), value = uar_get_code_display(p.priv_value_cd),
  position = uar_get_code_display(plr.position_cd),
  message = "SUCCESS"
  FROM (dummyt d1  WITH seq = size(data->qual,5)),
   (dummyt d2  WITH seq = 1),
   privilege p,
   priv_loc_reltn plr
  PLAN (d1)
   JOIN (d2)
   JOIN (p
   WHERE (p.privilege_cd=data->qual[d1.seq].privilegecd)
    AND (p.priv_value_cd=data->qual[d1.seq].privilegevaluecd))
   JOIN (plr
   WHERE plr.priv_loc_reltn_id=p.priv_loc_reltn_id
    AND (plr.position_cd=data->qual[d1.seq].contextlist[d2.seq].positioncd))
  WITH separator = " ", format
 ;end select
 SELECT INTO  $1
  "Output values has been saved in a file named AMS_Add_Privilege_Output.csv"
  FROM dummyt
  WITH separator = " ", format
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
