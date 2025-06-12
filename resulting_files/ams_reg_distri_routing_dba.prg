CREATE PROGRAM ams_reg_distri_routing:dba
 PROMPT
  "Save your Inputs in any CSV file in any one of the  below directories" = "MINE",
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
 FREE RECORD orig_content
 RECORD orig_content(
   1 rec[*]
     2 action_type = vc
     2 dist_name = vc
     2 dist_desc = vc
     2 filter_name = vc
     2 sub_filter_type = vc
     2 sub_filter_name = c100
     2 document_name = vc
     2 printer_name = vc
     2 copies = vc
 )
 FREE RECORD distribution
 RECORD distribution(
   1 qual[*]
     2 action_type = c3
     2 dist_name = vc
     2 dist_desc = vc
     2 filetr_name = vc
     2 sub_filetrs[*]
       3 action_type = c3
       3 sub_filetr_type = vc
       3 sub_filter_name = c100
       3 value_ind = vc
     2 documents[*]
       3 document_name = vc
       3 printer_name = vc
       3 copies = i4
 )
 SELECT
  r.line
  FROM rtl2t r
  HEAD REPORT
   row_count = 0, i = 0, count = 0,
   stat = alterlist(orig_content->rec,10)
  HEAD r.line
   line1 = r.line,
   CALL echo(line1)
   IF (size(trim(line1),1) > 0)
    count = (count+ 1)
    IF (count > 1)
     row_count = (row_count+ 1)
     IF (mod(row_count,10)=1
      AND row_count > 10)
      stat = alterlist(orig_content->rec,(row_count+ 9))
     ENDIF
     orig_content->rec[row_count].dist_name = piece(line1,",",1,"Not Found"), orig_content->rec[
     row_count].dist_desc = piece(line1,",",2,"Not Found"), orig_content->rec[row_count].filter_name
      = piece(line1,",",3,"Not Found"),
     orig_content->rec[row_count].sub_filter_type = piece(line1,",",4,"Not Found"), orig_content->
     rec[row_count].sub_filter_name = piece(line1,",",5,"Not Found"), orig_content->rec[row_count].
     document_name = piece(line1,",",6,"Not Found"),
     orig_content->rec[row_count].printer_name = piece(line1,",",7,"Not Found"), orig_content->rec[
     row_count].copies = piece(line1,",",8,"Not Found")
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(orig_content->rec,row_count)
 ;end select
 SET row_count = 0
 SET sub_filter_count = 0
 SET doc_count = 0
 FOR (i = 1 TO size(orig_content->rec,5))
   IF ((orig_content->rec[i].dist_name != ""))
    SET row_count = (row_count+ 1)
    SET sub_filter_count = 0
    SET doc_count = 0
    SET stat = alterlist(distribution->qual,row_count)
    SET distribution->qual[row_count].dist_name = orig_content->rec[i].dist_name
    SET distribution->qual[row_count].dist_desc = orig_content->rec[i].dist_desc
    SET distribution->qual[row_count].filetr_name = orig_content->rec[i].filter_name
   ENDIF
   IF ((orig_content->rec[i].sub_filter_type != ""))
    SET sub_filter_count = (sub_filter_count+ 1)
    SET stat = alterlist(distribution->qual[row_count].sub_filetrs,sub_filter_count)
    IF ((orig_content->rec[i].sub_filter_type="Encounter Type"))
     SET distribution->qual[row_count].sub_filetrs[sub_filter_count].sub_filetr_type = "ET"
     SET str = cnvtupper(trim(replace(replace(replace(replace(replace(replace(replace(replace(replace
               (replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                          replace(replace(replace(replace(replace(replace(replace(replace(replace(
                                   replace(replace(replace(orig_content->rec[i].sub_filter_name," ",
                                      "",0),",","",0),"~","",0),"`","",0),"!","",0),"@","",0),"#","",
                                0),"$","",0),"%","",0),"^","",0),"&","",0),"*","",0),"(","",0),")",
                         "",0),"-","",0),"_","",0),"+","",0),"=","",0),"{","",0),"}","",0),"|","",0),
                 "\","",0),":","",0),";","",0),'"',"",0),"'","",0),"<","",0),">","",0),".","",0),"/",
         "",0),"?","",0),8))
     SET distribution->qual[row_count].sub_filetrs[sub_filter_count].sub_filter_name = str
    ELSEIF ((orig_content->rec[i].sub_filter_type="Old Encounter Type"))
     SET distribution->qual[row_count].sub_filetrs[sub_filter_count].sub_filetr_type = "OET"
     SET str = cnvtupper(trim(replace(replace(replace(replace(replace(replace(replace(replace(replace
               (replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                          replace(replace(replace(replace(replace(replace(replace(replace(replace(
                                   replace(replace(replace(orig_content->rec[i].sub_filter_name," ",
                                      "",0),",","",0),"~","",0),"`","",0),"!","",0),"@","",0),"#","",
                                0),"$","",0),"%","",0),"^","",0),"&","",0),"*","",0),"(","",0),")",
                         "",0),"-","",0),"_","",0),"+","",0),"=","",0),"{","",0),"}","",0),"|","",0),
                 "\","",0),":","",0),";","",0),'"',"",0),"'","",0),"<","",0),">","",0),".","",0),"/",
         "",0),"?","",0),8))
     SET distribution->qual[row_count].sub_filetrs[sub_filter_count].sub_filter_name = str
    ELSEIF ((orig_content->rec[i].sub_filter_type="Change Encounter Type"))
     SET distribution->qual[row_count].sub_filetrs[sub_filter_count].sub_filetr_type = "CET"
    ELSEIF ((orig_content->rec[i].sub_filter_type="Financial Class"))
     SET distribution->qual[row_count].sub_filetrs[sub_filter_count].sub_filetr_type = "FIN"
     SET str = cnvtupper(trim(replace(replace(replace(replace(replace(replace(replace(replace(replace
               (replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                          replace(replace(replace(replace(replace(replace(replace(replace(replace(
                                   replace(replace(replace(orig_content->rec[i].sub_filter_name," ",
                                      "",0),",","",0),"~","",0),"`","",0),"!","",0),"@","",0),"#","",
                                0),"$","",0),"%","",0),"^","",0),"&","",0),"*","",0),"(","",0),")",
                         "",0),"-","",0),"_","",0),"+","",0),"=","",0),"{","",0),"}","",0),"|","",0),
                 "\","",0),":","",0),";","",0),'"',"",0),"'","",0),"<","",0),">","",0),".","",0),"/",
         "",0),"?","",0),8))
     SET distribution->qual[row_count].sub_filetrs[sub_filter_count].sub_filter_name = str
    ELSEIF ((orig_content->rec[i].sub_filter_type="Med Service"))
     SET distribution->qual[row_count].sub_filetrs[sub_filter_count].sub_filetr_type = "SRV"
     SET str = cnvtupper(trim(replace(replace(replace(replace(replace(replace(replace(replace(replace
               (replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                          replace(replace(replace(replace(replace(replace(replace(replace(replace(
                                   replace(replace(replace(orig_content->rec[i].sub_filter_name," ",
                                      "",0),",","",0),"~","",0),"`","",0),"!","",0),"@","",0),"#","",
                                0),"$","",0),"%","",0),"^","",0),"&","",0),"*","",0),"(","",0),")",
                         "",0),"-","",0),"_","",0),"+","",0),"=","",0),"{","",0),"}","",0),"|","",0),
                 "\","",0),":","",0),";","",0),'"',"",0),"'","",0),"<","",0),">","",0),".","",0),"/",
         "",0),"?","",0),8))
     SET distribution->qual[row_count].sub_filetrs[sub_filter_count].sub_filter_name = str
    ELSEIF ((orig_content->rec[i].sub_filter_type="User Position"))
     SET distribution->qual[row_count].sub_filetrs[sub_filter_count].sub_filetr_type = "POS"
     SET str = cnvtupper(trim(replace(replace(replace(replace(replace(replace(replace(replace(replace
               (replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
                          replace(replace(replace(replace(replace(replace(replace(replace(replace(
                                   replace(replace(replace(orig_content->rec[i].sub_filter_name," ",
                                      "",0),",","",0),"~","",0),"`","",0),"!","",0),"@","",0),"#","",
                                0),"$","",0),"%","",0),"^","",0),"&","",0),"*","",0),"(","",0),")",
                         "",0),"-","",0),"_","",0),"+","",0),"=","",0),"{","",0),"}","",0),"|","",0),
                 "\","",0),":","",0),";","",0),'"',"",0),"'","",0),"<","",0),">","",0),".","",0),"/",
         "",0),"?","",0),8))
     SET distribution->qual[row_count].sub_filetrs[sub_filter_count].sub_filter_name = str
    ELSEIF ((orig_content->rec[i].sub_filter_type="Username"))
     SET distribution->qual[row_count].sub_filetrs[sub_filter_count].sub_filetr_type = "USR"
     SET str = cnvtupper(trim(orig_content->rec[i].sub_filter_name))
     SET distribution->qual[row_count].sub_filetrs[sub_filter_count].sub_filter_name = str
    ELSEIF ((orig_content->rec[i].sub_filter_type="PC Id"))
     SET distribution->qual[row_count].sub_filetrs[sub_filter_count].sub_filetr_type = "PCI"
     SET str = orig_content->rec[i].sub_filter_name
     SET distribution->qual[row_count].sub_filetrs[sub_filter_count].sub_filter_name = str
    ENDIF
    SET distribution->qual[row_count].sub_filetrs[sub_filter_count].action_type = "ADD"
   ENDIF
   IF ((orig_content->rec[i].document_name != ""))
    SET doc_count = (doc_count+ 1)
    SET stat = alterlist(distribution->qual[row_count].documents,doc_count)
    SET distribution->qual[row_count].documents[doc_count].document_name = orig_content->rec[i].
    document_name
    SET distribution->qual[row_count].documents[doc_count].printer_name = orig_content->rec[i].
    printer_name
    SET distribution->qual[row_count].documents[doc_count].copies = cnvtint(orig_content->rec[i].
     copies)
   ENDIF
 ENDFOR
 CALL echorecord(distribution)
 DECLARE distri_id = f8 WITH public
 DECLARE k = i4 WITH public
 DECLARE j = i4 WITH public
 DECLARE var2 = i4 WITH public
 FOR (k = 1 TO size(distribution->qual,5))
   FREE RECORD request
   RECORD request(
     1 pm_doc_distribution_qual = i4
     1 pm_doc_distribution[*]
       2 action_type = c3
       2 distribution_id = f8
       2 distribution_name = c32
       2 distribution_desc = c100
       2 beg_effective_dt_tm = dq8
       2 end_effective_dt_tm = dq8
       2 active_ind_ind = i2
       2 active_ind = i2
       2 active_status_cd = f8
       2 active_status_prsnl_id = f8
       2 active_status_dt_tm = dq8
   )
   SET request->pm_doc_distribution_qual = 1
   SET stat = alterlist(request->pm_doc_distribution,1)
   CALL echo("tested k:")
   CALL echo(k)
   SET request->pm_doc_distribution[1].action_type = "ADD"
   SET request->pm_doc_distribution[1].distribution_desc = distribution->qual[k].dist_desc
   SET request->pm_doc_distribution[1].distribution_name = distribution->qual[k].dist_name
   FREE RECORD reply
   RECORD reply(
     1 pm_doc_distribution_qual = i4
     1 pm_doc_distribution[*] = i4
       2 distribution_id = f8
     1 status_data
       2 status = c1
       2 subeventstatus[2]
         3 operationname = c8
         3 operationstatus = c1
         3 targetobjectname = c15
         3 targetobjectvalue = c100
   )
   EXECUTE pm_ens_distribution  WITH replace("REQUEST",request), replace("REPLY",reply)
   SET distri_id = reply->pm_doc_distribution[1].distribution_id
   FREE RECORD request
   RECORD request(
     1 pm_doc_dist_filter_qual = i4
     1 pm_doc_dist_filter[*]
       2 action_type = c3
       2 dist_filter_id = f8
       2 distribution_id = f8
       2 filter_type = c3
       2 value = c100
       2 value_cd = f8
       2 value_dt_tm = dq8
       2 value_ind_ind = i2
       2 value_ind = i2
       2 exclude_ind_ind = i2
       2 exclude_ind = i2
       2 beg_effective_dt_tm = dq8
       2 end_effective_dt_tm = dq8
       2 active_ind_ind = i2
       2 active_ind = i2
       2 active_status_cd = f8
       2 active_status_prsnl_id = f8
       2 active_status_dt_tm = dq8
   )
   SET request->pm_doc_dist_filter_qual = 1
   SET stat = alterlist(request->pm_doc_dist_filter,1)
   SET request->pm_doc_dist_filter[1].distribution_id = distri_id
   SET request->pm_doc_dist_filter[1].action_type = "ADD"
   SET request->pm_doc_dist_filter[1].filter_type = "TRN"
   SET request->pm_doc_dist_filter[1].value = distribution->qual[k].filetr_name
   SET request->pm_doc_dist_filter[1].value_ind_ind = 1
   SET request->pm_doc_dist_filter[1].exclude_ind_ind = 1
   FREE RECORD reply
   RECORD reply(
     1 pm_doc_dist_filter_qual = i4
     1 pm_doc_dist_filter[*]
       2 dist_filter_id = f8
     1 status_data
       2 status = c1
       2 subeventstatus[2]
         3 operationname = c8
         3 operationstatus = c1
         3 targetobjectname = c15
         3 targetobjectvalue = c100
   )
   EXECUTE pm_ens_dist_filter:dba  WITH replace("REQUEST",request), replace("REPLY",reply)
   SET var2 = 0
   FOR (var2 = 1 TO size(distribution->qual[k].sub_filetrs,5))
     FREE RECORD request
     RECORD request(
       1 pm_doc_dist_filter_qual = i4
       1 pm_doc_dist_filter[*]
         2 action_type = c3
         2 dist_filter_id = f8
         2 distribution_id = f8
         2 filter_type = c3
         2 value = c100
         2 value_cd = f8
         2 value_dt_tm = dq8
         2 value_ind_ind = i2
         2 value_ind = i2
         2 exclude_ind_ind = i2
         2 exclude_ind = i2
         2 beg_effective_dt_tm = dq8
         2 end_effective_dt_tm = dq8
         2 active_ind_ind = i2
         2 active_ind = i2
         2 active_status_cd = f8
         2 active_status_prsnl_id = f8
         2 active_status_dt_tm = dq8
     )
     SET stat = alterlist(request->pm_doc_dist_filter,1)
     SET request->pm_doc_dist_filter_qual = 1
     SET request->pm_doc_dist_filter[1].distribution_id = distri_id
     SET request->pm_doc_dist_filter[1].action_type = "ADD"
     SET request->pm_doc_dist_filter[1].filter_type = distribution->qual[k].sub_filetrs[var2].
     sub_filetr_type
     SET request->pm_doc_dist_filter[1].value = distribution->qual[k].sub_filetrs[var2].
     sub_filter_name
     IF ((distribution->qual[k].sub_filetrs[var2].sub_filetr_type IN ("ET", "OET")))
      SELECT
       cv.code_value
       FROM code_value cv
       WHERE (cv.display_key=request->pm_doc_dist_filter[1].value)
        AND cv.code_set=71
        AND cv.active_ind=1
       HEAD cv.code_value
        request->pm_doc_dist_filter[1].value_cd = cv.code_value
       WITH nocounter
      ;end select
     ELSEIF ((distribution->qual[k].sub_filetrs[var2].sub_filetr_type="CET")
      AND (request->pm_doc_dist_filter[1].value="1"))
      SET request->pm_doc_dist_filter[1].value_ind = 1
     ELSEIF ((distribution->qual[k].sub_filetrs[var2].sub_filetr_type="FIN"))
      SELECT
       cv.code_value
       FROM code_value cv
       WHERE (cv.display_key=request->pm_doc_dist_filter[1].value)
        AND cv.code_set=354
        AND cv.active_ind=1
       HEAD cv.code_value
        request->pm_doc_dist_filter[1].value_cd = cv.code_value
       WITH nocounter
      ;end select
     ELSEIF ((distribution->qual[k].sub_filetrs[var2].sub_filetr_type="SRV"))
      SELECT
       cv.code_value
       FROM code_value cv
       WHERE (cv.display_key=request->pm_doc_dist_filter[1].value)
        AND cv.code_set=34
        AND cv.active_ind=1
       HEAD cv.code_value
        request->pm_doc_dist_filter[1].value_cd = cv.code_value
       WITH nocounter
      ;end select
     ELSEIF ((distribution->qual[k].sub_filetrs[var2].sub_filetr_type="POS"))
      SELECT
       cv.code_value
       FROM code_value cv
       WHERE (cv.display_key=request->pm_doc_dist_filter[1].value)
        AND cv.code_set=88
        AND cv.active_ind=1
       HEAD cv.code_value
        request->pm_doc_dist_filter[1].value_cd = cv.code_value
       WITH nocounter
      ;end select
     ELSEIF ((distribution->qual[k].sub_filetrs[var2].sub_filetr_type="USR"))
      SELECT
       pr.person_id
       FROM prsnl pr
       WHERE (pr.username=request->pm_doc_dist_filter[1].value)
        AND pr.active_ind=1
       HEAD pr.person_id
        request->pm_doc_dist_filter[1].value_cd = pr.person_id
       WITH nocounter
      ;end select
     ENDIF
     SET request->pm_doc_dist_filter[1].value_ind_ind = 1
     SET request->pm_doc_dist_filter[1].exclude_ind_ind = 1
     FREE RECORD reply
     RECORD reply(
       1 pm_doc_dist_filter_qual = i4
       1 pm_doc_dist_filter[*]
         2 dist_filter_id = f8
       1 status_data
         2 status = c1
         2 subeventstatus[2]
           3 operationname = c8
           3 operationstatus = c1
           3 targetobjectname = c15
           3 targetobjectvalue = c100
     )
     EXECUTE pm_ens_dist_filter:dba  WITH replace("REQUEST",request), replace("REPLY",reply)
   ENDFOR
   SET var3 = 0
   FOR (var3 = 1 TO size(distribution->qual[k].documents,5))
     FREE RECORD request
     RECORD request(
       1 pm_doc_destination_qual = i4
       1 pm_doc_destination[*]
         2 action_type = c3
         2 destination_id = f8
         2 document_id = f8
         2 distribution_id = f8
         2 output_dest_cd = f8
         2 copies = i4
         2 batch_ind_ind = i2
         2 batch_ind = i2
         2 beg_effective_dt_tm = dq8
         2 end_effective_dt_tm = dq8
         2 active_ind_ind = i2
         2 active_ind = i2
         2 active_status_cd = f8
         2 active_status_prsnl_id = f8
         2 active_status_dt_tm = dq8
     )
     SET request->pm_doc_destination_qual = 1
     SET stat = alterlist(request->pm_doc_destination,1)
     SET request->pm_doc_destination[1].action_type = "ADD"
     SET request->pm_doc_destination[1].distribution_id = distri_id
     SELECT INTO "NL:"
      p.document_id
      FROM pm_doc_document p
      WHERE (p.document_desc=distribution->qual[k].documents[var3].document_name)
       AND p.active_ind=1
      HEAD p.document_id
       request->pm_doc_destination[1].document_id = p.document_id
      WITH nocounter
     ;end select
     SELECT
      o.output_dest_cd
      FROM output_dest o
      WHERE (o.name=distribution->qual[k].documents[var3].printer_name)
      HEAD o.output_dest_cd
       request->pm_doc_destination[1].output_dest_cd = o.output_dest_cd
      WITH nocounter
     ;end select
     SET request->pm_doc_destination[1].copies = distribution->qual[k].documents[var3].copies
     FREE RECORD reply
     RECORD reply(
       1 pm_doc_destination_qual = i4
       1 pm_doc_destination[*] = i4
         2 destination_id = f8
       1 status_data
         2 status = c1
         2 subeventstatus[2]
           3 operationname = c8
           3 operationstatus = c1
           3 targetobjectname = c15
           3 targetobjectvalue = c100
     )
     EXECUTE pm_ens_destination:dba  WITH replace("REQUEST",request), replace("REPLY",reply)
   ENDFOR
 ENDFOR
 SELECT INTO  $1
  status =
  IF ((reply->status_data[d1.seq].status="S"))
   "Successfully Created Distributions and Associated with Given filters and Printers"
  ENDIF
  FROM (dummyt d1  WITH seq = size(reply->status_data,5))
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
