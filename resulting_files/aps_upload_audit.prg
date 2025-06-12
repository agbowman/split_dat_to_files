CREATE PROGRAM aps_upload_audit
 PAINT
 CALL clear(1,1)
 CALL video(r)
 CALL text(2,24,"        Anatomic Pathology         ")
 CALL text(3,24,"     S e c u r e    L o g i n      ")
 CALL video(n)
 CALL box(1,1,23,80)
 CALL line(4,1,80,xhor)
 CALL line(1,22,4,xvert)
 CALL line(1,60,4,xvert)
 IF (curenv=0)
  SET xloginck = validate(xxcclseclogin->loggedin,99)
  IF (xloginck != 1)
   SET trace = recpersist
   RECORD xxcclseclogin(
     1 loggedin = i4
   )
   SET trace = norecpersist
   SET valid = 0
   WHILE (valid=0)
     CALL clear(15,10,69)
     CALL clear(16,10,69)
     CALL clear(17,10,69)
     CALL clear(18,10,69)
     CALL clear(19,10,69)
     CALL clear(20,10,69)
     CALL clear(21,10,69)
     CALL clear(22,10,69)
     CALL text(15,25,"     UserName")
     CALL accept(15,40,"p(30);cu")
     SET p1 = curaccept
     CALL clear(15,40,39)
     CALL text(15,40,p1)
     CALL text(16,25,"       Domain")
     CALL accept(16,40,"p(30);cu")
     SET p2 = curaccept
     CALL clear(16,40,39)
     CALL text(16,40,p2)
     SET password = fillstring(30," ")
     CALL text(17,25,"     Password")
     CALL accept(17,40,"p(30);cue"," ")
     CALL clear(16,40,39)
     SET password = curaccept
     CALL text(17,40,". . . . . .")
     CALL video(b)
     CALL text(24,5,"communicating with database...")
     SET stat = uar_sec_login(nullterm(cnvtupper(p1)),nullterm(cnvtupper(p2)),nullterm(cnvtupper(
        password)))
     CALL video(n)
     CALL clear(24,5,74)
     IF (stat=0)
      CALL clear(20,20,59)
      CALL text(20,30,"SECURITY LOGIN SUCCESS")
      SET valid = 1
      SET xxcclseclogin->loggedin = 1 WITH persist
     ELSE
      CALL clear(20,20,59)
      CALL text(19,20,build("SECURITY LOGIN FAILURE WITH STATUS -->",stat,"<--"))
      SET valid = 0
     ENDIF
     CALL text(21,31,"Enter Y to continue")
     CALL accept(22,39,"p;cu","Y")
     IF (curaccept != "Y")
      SET valid = 1
     ENDIF
   ENDWHILE
   CALL clear(1,1)
  ELSE
   CALL text(16,23,"You are logged in.  Exit ccl to logout.")
   CALL pause(2)
  ENDIF
 ENDIF
 DECLARE blob_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",25,"BLOB"))
 DECLARE blobout = gvc WITH protect, noconstant("")
 FREE SET reply
 RECORD reply(
   1 print_status_data
     2 print_directory = c19
     2 print_filename = c40
     2 print_dir_and_filename = c60
 )
#accessretry
 CALL refreshscreen("   AP History  Upload  A u d i t   ")
 SET accept_accession_nbr = "                  "
 SET help =
 SELECT INTO "NL:"
  accession = pc.accession_nbr"##################;l", name = decode(p.seq,p.name_full_formatted,
   "Not Found")"####################", case_id = pc.case_id,
  ext_acc_nbr = pc.ext_accession_nbr
  FROM pathology_case pc,
   dummyt d,
   person p
  PLAN (pc
   WHERE pc.case_id > 0
    AND pc.accession_nbr >= curaccept)
   JOIN (d)
   JOIN (p
   WHERE pc.person_id=p.person_id)
  ORDER BY accession
  WITH nocounter, outerjoin = d
 ;end select
 SET help = promptmsg("HELP: enter starting accession_nbr: ")
 SET accept_accession_nbr = "00000SO19980002362"
 SET accept = video(iu)
 CALL text(6,20,"Enter a valid accession")
 CALL video(l)
 CALL text(8,20,"This is the Cerner accession not the external.")
 CALL text(17,45,"Press <HELP> to search.")
 CALL video(n)
 CALL accept(6,45,"PPPPPPPPPPPPPPPPPP;CUP",accept_accession_nbr)
 SET accept_accession_nbr = curaccept
 SET help = off
 IF (textlen(trim(curaccept))=0)
  GO TO end_program
 ENDIF
 SET placeholder_cd = uar_get_code_by("MEANING",53,"PLACEHOLDER")
 CALL clear(6,3,70)
 CALL text(6,3,"Validating Case    - Working")
 SET pc_case_id = 0.0
 SELECT INTO "nl:"
  pc.case_id
  FROM pathology_case pc
  PLAN (pc
   WHERE pc.accession_nbr=accept_accession_nbr
    AND pc.case_id != 0)
  DETAIL
   pc_case_id = pc.case_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL clear(6,3,70)
  CALL text(6,3,"validating Case    - Failed")
  CALL text(24,5,"INVALID, try again ...                                       ")
  CALL pause(5)
  GO TO accessretry
 ELSE
  CALL clear(6,3,70)
  CALL refreshscreen("   AP History  Upload  A u d i t   ")
  CALL displaycase(1)
  CALL text(6,3,"Validating Case    - Successful")
 ENDIF
 SET print_filename = "                                                   "
 SET logical ap value(trim(logical("CER_PRINT")))
 SET print_filename = concat("ap:aps_","_",trim(accept_accession_nbr))
 CALL text(7,3,"Pathology Case     - Working")
 SELECT INTO value(print_filename)
  pc.case_number, pc_case_type_cd = uar_get_code_display(pc.case_type_cd)
  FROM pathology_case pc
  WHERE pc_case_id=pc.case_id
  HEAD REPORT
   line = fillstring(125,"'"), col 0, line,
   row + 1, col 0, "'",
   col 2, accept_accession_nbr, col 25,
   "Pathology_case", col 124, "'",
   row + 1, line, row + 1
  DETAIL
   row + 1, col 10, "- - - - - - - - - - - - - - - - - -",
   col 5, "CASE_ID", col 40,
   pc.case_id, row + 1, col 10,
   "- - - - - - - - - - - - - - - - - -", col 5, "ACCESSION_NBR",
   col 40, pc.accession_nbr, row + 1,
   col 10, "- - - - - - - - - - - - - - - - - -", col 5,
   "ACCESSIONED_DT_TM", col 40, pc.accessioned_dt_tm,
   row + 1, col 10, "- - - - - - - - - - - - - - - - - -",
   col 5, "ACCESSION_PRSNL_ID", col 40,
   pc.accession_prsnl_id, row + 1, col 10,
   "- - - - - - - - - - - - - - - - - -", col 5, "PERSON_ID",
   col 40, pc.person_id, row + 1,
   col 10, "- - - - - - - - - - - - - - - - - -", col 5,
   "ENCNTR_ID", col 40, pc.encntr_id,
   row + 1, col 10, "- - - - - - - - - - - - - - - - - -",
   col 5, "GROUP_ID", col 40,
   pc.group_id, row + 1, col 10,
   "- - - - - - - - - - - - - - - - - -", col 5, "PREFIX_ID",
   col 40, pc.prefix_id, row + 1,
   col 10, "- - - - - - - - - - - - - - - - - -", col 5,
   "CASE_YEAR", col 40, pc.case_year,
   row + 1, col 10, "- - - - - - - - - - - - - - - - - -",
   col 5, "CASE_NUMBER", col 40,
   pc.case_number, row + 1, col 10,
   "- - - - - - - - - - - - - - - - - -", col 5, "RESPONSIBLE_RESIDENT_ID",
   col 40, pc.responsible_resident_id, row + 1,
   col 10, "- - - - - - - - - - - - - - - - - -", col 5,
   "RESPONSIBLE_PATHOLOGIST_ID", col 40, pc.responsible_pathologist_id,
   row + 1, col 10, "- - - - - - - - - - - - - - - - - -",
   col 5, "REQUESTING_PHYSICIAN_ID", col 40,
   pc.requesting_physician_id, row + 1, col 10,
   "- - - - - - - - - - - - - - - - - -", col 5, "MAIN_REPORT_CMPLETE_DT_TM",
   col 40, pc.main_report_cmplete_dt_tm, row + 1,
   col 10, "- - - - - - - - - - - - - - - - - -", col 5,
   "CASE_RECEIVED_DT_TM", col 40, pc.case_received_dt_tm,
   row + 1, col 10, "- - - - - - - - - - - - - - - - - -",
   col 5, "CASE_COLLECT_DT_TM", col 40,
   pc.case_collect_dt_tm, row + 1, col 10,
   "- - - - - - - - - - - - - - - - - -", col 5, "LOC_FACILITY_CD",
   col 40, pc.loc_facility_cd, row + 1,
   col 10, "- - - - - - - - - - - - - - - - - -", col 5,
   "LOC_BUILDING_CD", col 40, pc.loc_building_cd,
   row + 1, col 10, "- - - - - - - - - - - - - - - - - -",
   col 5, "LOC_NURSE_UNIT_CD", col 40,
   pc.loc_nurse_unit_cd, row + 1, col 10,
   "- - - - - - - - - - - - - - - - - -", col 5, "COMMENTS",
   col 40, pc.comments
   "##########################################################################################", row
    + 1,
   col 10, "- - - - - - - - - - - - - - - - - -", col 5,
   "CANCEL_CD", col 40, pc.cancel_cd,
   row + 1, col 10, "- - - - - - - - - - - - - - - - - -",
   col 5, "CANCEL_DT_TM", col 40,
   pc.cancel_dt_tm, row + 1, col 10,
   "- - - - - - - - - - - - - - - - - -", col 5, "CANCEL_ID",
   col 40, pc.cancel_id, row + 1,
   col 10, "- - - - - - - - - - - - - - - - - -", col 5,
   "ORIGIN_FLAG", col 40, pc.origin_flag,
   row + 1, col 10, "- - - - - - - - - - - - - - - - - -",
   col 5, "RESERVED_IND", col 40,
   pc.reserved_ind, row + 1, col 10,
   "- - - - - - - - - - - - - - - - - -", col 5, "CHR_IND",
   col 40, pc.chr_ind, row + 1,
   col 10, "- - - - - - - - - - - - - - - - - -", col 5,
   "CASE_TYPE_CD", col 40, pc.case_type_cd,
   row + 1, col 10, "- - - - - - - - - - - - - - - - - -",
   col 40, pc_case_type_cd, row + 1,
   col 10, "= = = = = = = = = = = = = = = = = =", col 5,
   "AUTOPSY_SCOPE_CD", col 40, pc.autopsy_scope_cd,
   row + 1, col 10, "- - - - - - - - - - - - - - - - - -",
   col 5, "AUTOPSY_DESCRIPTION", col 40,
   pc.autopsy_description
   "###########################################################################################", row
    + 1, col 10,
   "- - - - - - - - - - - - - - - - - -", col 5, "UPDT_DT_TM",
   col 40, pc.updt_dt_tm, row + 1,
   col 10, "- - - - - - - - - - - - - - - - - -", col 5,
   "UPDT_ID", col 40, pc.updt_id,
   row + 1, col 10, "- - - - - - - - - - - - - - - - - -",
   col 5, "UPDT_TASK", col 40,
   pc.updt_task, row + 1, col 10,
   "- - - - - - - - - - - - - - - - - -", col 5, "UPDT_CNT",
   col 40, pc.updt_cnt, row + 1,
   col 10, "- - - - - - - - - - - - - - - - - -", col 5,
   "UPDT_APPLCTX", col 40, pc.updt_applctx,
   row + 2
  FOOT REPORT
   row + 1, col 0, line,
   row + 1
  WITH nocounter, append
 ;end select
 IF (curqual=0)
  CALL clear(7,3,70)
  CALL text(7,3,"Pathology Case     - Failed")
 ELSE
  CALL text(7,3,"Pathology Case     - Successful")
 ENDIF
 CALL text(8,3,"Case report        - Working")
 SELECT INTO value(print_filename)
  cr.*, cr_catalog_cd = uar_get_code_display(cr.catalog_cd), cr_status_cd = uar_get_code_display(cr
   .status_cd)
  FROM case_report cr
  PLAN (cr
   WHERE pc_case_id=cr.case_id)
  HEAD REPORT
   line = fillstring(125,"'"), col 0, line,
   row + 1, col 0, "'",
   col 2, accept_accession_nbr, col 25,
   "Case_Report", col 124, "'",
   row + 1, line, row + 1
  DETAIL
   row + 1, col 10, "- - - - - - - - - - - - - - - - - -",
   col 5, "report_id", col 40,
   cr.report_id, row + 1, col 10,
   "- - - - - - - - - - - - - - - - - -", col 5, "case_id  ",
   col 40, cr.case_id, row + 1,
   col 10, "- - - - - - - - - - - - - - - - - -", col 5,
   "event_id", col 40, cr.event_id,
   row + 1, col 10, "- - - - - - - - - - - - - - - - - -",
   col 5, "catalog_cd", col 40,
   cr.catalog_cd, row + 1, col 10,
   "= = = = = = = = = = = = = = = = = =", col 40, cr_catalog_cd,
   row + 1, col 10, "- - - - - - - - - - - - - - - - - -",
   col 5, "report_sequence", col 40,
   cr.report_sequence, row + 1, col 10,
   "- - - - - - - - - - - - - - - - - -", col 5, "request_dt_tm",
   col 40, cr.request_dt_tm, row + 1,
   col 10, "- - - - - - - - - - - - - - - - - -", col 5,
   "request_prsnl_id", col 40, cr.request_prsnl_id,
   row + 1, col 10, "- - - - - - - - - - - - - - - - - -",
   col 5, "status_cd", col 40,
   cr.status_cd, row + 1, col 10,
   "= = = = = = = = = = = = = = = = = =", col 40, cr_status_cd,
   row + 1, col 10, "- - - - - - - - - - - - - - - - - -",
   col 5, "status_prsnl_id", col 40,
   cr.status_prsnl_id, row + 1, col 10,
   "- - - - - - - - - - - - - - - - - -", col 5, "status_dt_tm",
   col 40, cr.status_dt_tm, row + 1,
   col 10, "- - - - - - - - - - - - - - - - - -", col 5,
   "cancel_cd", col 40, cr.cancel_cd,
   row + 1, col 10, "- - - - - - - - - - - - - - - - - -",
   col 5, "cancel_prsnl_id", col 40,
   cr.cancel_prsnl_id, row + 1, col 10,
   "- - - - - - - - - - - - - - - - - -", col 5, "cancel_dt_tm",
   col 40, cr.cancel_dt_tm, row + 1,
   col 10, "- - - - - - - - - - - - - - - - - -", col 5,
   "updt_applctx", col 40, cr.updt_applctx,
   row + 1, col 10, "- - - - - - - - - - - - - - - - - -",
   col 5, "updt_id", col 40,
   cr.updt_id, row + 1, col 10,
   "- - - - - - - - - - - - - - - - - -", col 5, "updt_cnt",
   col 40, cr.updt_cnt, row + 1,
   col 10, "- - - - - - - - - - - - - - - - - -", col 5,
   "updt_task", col 40, cr.updt_task,
   row + 1, col 10, "- - - - - - - - - - - - - - - - - -",
   col 5, "updt_dt_tm", col 40,
   cr.updt_dt_tm, row + 2
  FOOT REPORT
   row + 1, col 0, line,
   row + 1
  WITH nocounter, append
 ;end select
 IF (curqual=0)
  CALL clear(8,3,70)
  CALL text(8,3,"Case Report        - Failed")
 ELSE
  CALL text(8,3,"Case Report        - Successful")
 ENDIF
 CALL text(9,3,"Code Value CS-120  - Working")
 SET compressed_cd = 0.0
 SET uncompressed_cd = 0.0
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=120
  DETAIL
   IF (cv.cdf_meaning="NOCOMP")
    uncompressed_cd = cv.code_value
   ENDIF
   IF (cv.cdf_meaning="OCFCOMP")
    compressed_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL video(b)
  CALL text(9,3,"Code Value CS-120  - FAILURE")
  CALL video(n)
  CALL pause(5)
  GO TO end_reporttext
 ELSE
  CALL text(9,3,"Code Value CS-120  - Successful")
 ENDIF
 CALL text(10,3,"Code Value CS-1305 - Working")
 SET cancel_cd = 0.0
 SET verified_cd = 0.0
 SET corrected_cd = 0.0
 SELECT INTO "nl:"
  cv.code_value, cv.cdf_meaning
  FROM code_value cv
  WHERE cv.code_set=1305
   AND cv.cdf_meaning IN ("CANCEL", "VERIFIED", "CORRECTED")
  DETAIL
   CASE (cv.cdf_meaning)
    OF "CANCEL":
     cancel_cd = cv.code_value
    OF "VERIFIED":
     verified_cd = cv.code_value
    OF "CORRECTED":
     corrected_cd = cv.code_value
   ENDCASE
  WITH nocounter
 ;end select
 IF (verified_cd=0)
  CALL video(b)
  CALL text(10,3,"Code Value CS-1305 - FAILURE")
  CALL video(n)
  CALL pause(5)
  GO TO end_reporttext
 ELSE
  CALL text(10,3,"Code Value CS-1305 - Successful")
 ENDIF
 SET num_of_rpts = 0
 FREE SET temp
 RECORD temp(
   1 report_qual[*]
     2 report_id = f8
     2 report_disp = vc
 )
 CALL text(11,3,"Counting reports   - Working")
 SELECT INTO "nl:"
  cr.report_id
  FROM case_report cr,
   pathology_case pc,
   order_catalog oc
  PLAN (pc
   WHERE pc.accession_nbr=accept_accession_nbr)
   JOIN (cr
   WHERE pc.case_id=cr.case_id)
   JOIN (oc
   WHERE cr.catalog_cd=oc.catalog_cd)
  DETAIL
   num_of_rpts += 1, stat = alterlist(temp->report_qual,num_of_rpts), temp->report_qual[num_of_rpts].
   report_disp = oc.primary_mnemonic,
   temp->report_qual[num_of_rpts].report_id = cr.report_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL video(b)
  CALL text(11,3,"Counting reports   - FAILURE")
  CALL video(n)
  CALL pause(5)
  GO TO end_reporttext
 ELSE
  CALL text(11,3,"Counting reports   - Successful")
  CALL text(11,35,build("(",num_of_rpts,")"))
 ENDIF
 IF (num_of_rpts > 0)
  CALL text(12,3,"Loading reports    - Working")
 ELSEIF (num_of_rpts=0)
  SET accept_rpt_nbr = 0
  CALL video(b)
  CALL text(12,3,"Loading reports    - None Found")
  CALL video(n)
  CALL pause(5)
  GO TO end_reporttext
 ENDIF
 RECORD tmptext(
   1 qual[*]
     2 text = vc
 )
 DECLARE uar_get_ceblobsize(p1=f8(ref),p2=vc(ref)) = i4 WITH image_aix =
 "uar_ce_blob.a(uar_ce_blob.o)", uar = "uar_get_ceblobsize", persist
 DECLARE uar_get_ceblob(p1=f8(ref),p2=vc(ref),p3=vc(ref),p4=i4(value)) = i4 WITH image_aix =
 "uar_ce_blob.a(uar_ce_blob.o)", uar = "uar_get_ceblob", persist
 RECORD recdate(
   1 datetime = dq8
 ) WITH protect
 DECLARE format = i2
 DECLARE outbuffer = vc
 DECLARE nortftext = vc
 SET format = 0
 DECLARE txt_pos = i4
 DECLARE start = i4
 DECLARE len = i4
 DECLARE linecnt = i4
 SUBROUTINE (rtf_to_text(rtftext=vc,format=i2,line_len=i2) =null)
   SET all_len = 0
   SET start = 0
   SET len = 0
   SET text_pos = 0
   SET linecnt = 0
   SET inbuffer = fillstring(value(size(rtftext))," ")
   SET outbufferlen = 0
   SET bfl = 0
   SET bfl2 = 1
   SET outbuffer = ""
   SET nortftext = ""
   SET stat = memrealloc(outbuffer,1,build("C",value(size(rtftext))))
   SET stat = memrealloc(nortftext,1,build("C",value(size(rtftext))))
   IF (substring(1,5,rtftext)=asis("{\rtf"))
    SET inbuffer = trim(rtftext)
    CALL uar_rtf2(inbuffer,size(inbuffer),outbuffer,size(outbuffer),outbufferlen,
     bfl)
   ELSE
    SET outbuffer = trim(rtftext)
   ENDIF
   SET nortftext = trim(outbuffer)
   SET stat = alterlist(tmptext->qual,0)
   SET crchar = concat(char(13),char(10))
   SET lfchar = char(10)
   SET ffchar = char(12)
   IF (format > 0)
    SET all_len = cnvtint(size(trim(outbuffer)))
    SET tot_len = 0
    SET start = 1
    SET bigfirst = "Y"
    SET crstart = start
    WHILE (all_len > tot_len)
      SET crpos = crstart
      SET crfirst = "Y"
      SET loaded = "N"
      WHILE ((crpos <= ((crstart+ line_len)+ 1))
       AND loaded="N"
       AND all_len > tot_len)
       IF ((crpos=((crstart+ line_len)+ 1))
        AND crfirst="N")
        SET start = crstart
        SET first = "Y"
        SET text_pos = ((start+ line_len) - 1)
        IF (bigfirst="Y"
         AND text_pos >= all_len)
         SET text_pos = start
        ENDIF
        SET bigfirst = "N"
        WHILE (text_pos >= start
         AND all_len > tot_len)
          IF (text_pos=start)
           SET text_pos = ((start+ line_len) - 1)
           SET linecnt += 1
           SET stat = alterlist(tmptext->qual,linecnt)
           SET len = ((text_pos - start)+ 1)
           SET tmptext->qual[linecnt].text = substring(start,len,outbuffer)
           SET start = (text_pos+ 1)
           SET crstart = (text_pos+ 1)
           SET text_pos = 0
           SET tot_len = ((tot_len+ len) - 1)
           SET loaded = "Y"
          ELSE
           IF (substring(text_pos,1,outbuffer)=" ")
            SET len = (text_pos - start)
            IF (cnvtint(size(trim(substring(start,len,outbuffer)))) > 0)
             SET linecnt += 1
             SET stat = alterlist(tmptext->qual,linecnt)
             SET tmptext->qual[linecnt].text = substring(start,len,outbuffer)
             SET loaded = "Y"
            ENDIF
            SET start = (text_pos+ 1)
            SET crstart = (text_pos+ 1)
            SET text_pos = 0
            SET tot_len += len
           ELSE
            IF (first="Y")
             SET first = "N"
             SET tot_len += 1
            ENDIF
            SET text_pos -= 1
           ENDIF
          ENDIF
        ENDWHILE
       ELSE
        SET crfirst = "N"
        IF (((substring(crpos,1,outbuffer)=crchar) OR (((substring(crpos,1,outbuffer)=lfchar) OR (
        substring(crpos,1,outbuffer)=ffchar)) )) )
         SET crlen = (crpos - crstart)
         SET linecnt += 1
         SET stat = alterlist(tmptext->qual,linecnt)
         SET tmptext->qual[linecnt].text = substring(crstart,crlen,outbuffer)
         SET loaded = "Y"
         IF (substring(crpos,1,outbuffer)=crchar)
          SET crstart = (crpos+ textlen(crchar))
         ELSEIF (substring(crpos,1,outbuffer)=lfchar)
          SET crstart = (crpos+ textlen(lfchar))
         ELSEIF (substring(crpos,1,outbuffer)=ffchar)
          SET crstart = (crpos+ textlen(ffchar))
         ENDIF
         SET tot_len += crlen
        ENDIF
       ENDIF
       SET crpos += 1
      ENDWHILE
    ENDWHILE
   ENDIF
   SET rtftext = fillstring(value(size(rtftext))," ")
   SET inbuffer = fillstring(value(size(rtftext))," ")
 END ;Subroutine
 DECLARE outbufmaxsiz = i2
 DECLARE tblobin = c32000
 DECLARE tblobout = c32000
 DECLARE blobin = c32000
 DECLARE blobout = c32000
 SUBROUTINE (decompress_text(tblobin=vc) =null)
   SET tblobout = fillstring(32000," ")
   SET blobout = fillstring(32000," ")
   SET outbufmaxsiz = 0
   SET blobin = trim(tblobin)
   CALL uar_ocf_uncompress(blobin,size(blobin),blobout,size(blobout),outbufmaxsiz)
   SET tblobout = blobout
   SET tblobin = fillstring(32000," ")
   SET blobin = fillstring(32000," ")
 END ;Subroutine
 SELECT INTO value(print_filename)
  ce.event_id, pc_case_collect_dt_tm = pc.case_collect_dt_tm"mm/dd/yy;;d", pc.accession_nbr,
  cv.description, join_path = decode(ceb.seq,"A-TEXT",cecr.seq,"B-ALPHA",cen.seq,
   "C-SIGNLINE",cecr2.seq,"D-SNOMED"," "), nomenclature_id = decode(cecr2.seq,cecr2.nomenclature_id,
   0.0),
  n2.source_string, lb.long_blob_id, lb.parent_entity_name,
  lb.parent_entity_id, pc_case_collect_dt_tm = pc.case_collect_dt_tm"mm/dd/yy;;d", pc.accession_nbr,
  ce.event_id, cv.description"###########################################################", ceb
  .event_id,
  cen.event_id, pc.person_id, ce.task_assay_cd,
  cecr2_group_nbr = decode(cecr2.seq,cecr2.group_nbr,0), cecr2.nomenclature_id, n2.source_string,
  alpha = decode(ceb3.seq,"F","T")
  FROM case_report cr,
   (dummyt d  WITH seq = value(num_of_rpts)),
   pathology_case pc,
   clinical_event ce,
   code_value cv,
   (dummyt d1  WITH seq = 1),
   ce_blob_result ceb,
   ce_event_note cen,
   (dummyt d4  WITH seq = 1),
   ce_coded_result cecr,
   nomenclature n,
   (dummyt d5  WITH seq = 1),
   ce_blob_result ceb3,
   (dummyt d2  WITH seq = 1),
   long_blob lb,
   (dummyt d3  WITH seq = 1),
   ce_coded_result cecr2,
   ce_blob_result ceb2,
   nomenclature n2
  PLAN (pc
   WHERE pc.accession_nbr=accept_accession_nbr
    AND pc.cancel_cd IN (null, 0))
   JOIN (d)
   JOIN (cr
   WHERE pc.case_id=cr.case_id
    AND (cr.report_id=temp->report_qual[d.seq].report_id)
    AND cr.status_cd != cancel_cd)
   JOIN (ce
   WHERE cr.event_id=ce.parent_event_id
    AND ce.event_class_cd != placeholder_cd
    AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime))
   JOIN (cv
   WHERE ce.task_assay_cd=cv.code_value)
   JOIN (((d1
   WHERE 1=d1.seq)
   JOIN (ceb
   WHERE ce.event_id=ceb.event_id
    AND ceb.storage_cd=blob_cd
    AND ceb.valid_until_dt_tm > cnvtdatetime(curdate,curtime))
   ) ORJOIN ((((d2
   WHERE 1=d2.seq)
   JOIN (cen
   WHERE ce.event_id=cen.event_id
    AND cen.valid_until_dt_tm > cnvtdatetime(curdate,curtime))
   JOIN (lb
   WHERE lb.parent_entity_name="CE_EVENT_NOTE"
    AND lb.parent_entity_id=cen.ce_event_note_id)
   ) ORJOIN ((((d3
   WHERE 1=d3.seq)
   JOIN (cecr2
   WHERE ce.event_id=cecr2.event_id
    AND cecr2.valid_until_dt_tm > cnvtdatetime(curdate,curtime))
   JOIN (ceb2
   WHERE cecr2.event_id=ceb2.event_id
    AND ceb2.storage_cd=blob_cd
    AND ceb2.valid_until_dt_tm > cnvtdatetime(curdate,curtime))
   JOIN (n2
   WHERE cecr2.nomenclature_id=n2.nomenclature_id)
   ) ORJOIN ((d4
   WHERE 1=d4.seq)
   JOIN (cecr
   WHERE ce.event_id=cecr.event_id
    AND cecr.valid_until_dt_tm > cnvtdatetime(curdate,curtime))
   JOIN (n
   WHERE cecr.nomenclature_id=n.nomenclature_id)
   JOIN (d5
   WHERE 1=d5.seq)
   JOIN (ceb3
   WHERE cecr.event_id=ceb3.event_id
    AND ceb3.storage_cd=blob_cd
    AND ceb3.valid_until_dt_tm > cnvtdatetime(curdate,curtime))
   )) )) ))
  ORDER BY ce.event_id, join_path, cecr2_group_nbr
  HEAD REPORT
   col 0, "Accession: ", pc.accession_nbr,
   row + 1
  HEAD d.seq
   col 0, "REPORT: ", col 9,
   temp->report_qual[d.seq].report_disp, row + 1
  DETAIL
   CASE (join_path)
    OF "A-TEXT":
     row + 1,col 0,
     "======================================================================================================================",
     row + 1,col 5,cv.description,
     recdate->datetime = cnvtdatetimeutc(ceb.valid_from_dt_tm),blobsize = uar_get_ceblobsize(ceb
      .event_id,recdate),blobout = "",
     IF (blobsize > 0)
      stat = memrealloc(blobout,1,build("C",blobsize)), status = uar_get_ceblob(ceb.event_id,recdate,
       blobout,blobsize)
     ENDIF
     ,
     CALL rtf_to_text(blobout,1,112)
     FOR (z = 1 TO size(tmptext->qual,5))
       row + 1, col 7, "*",
       col 10, tmptext->qual[z].text
     ENDFOR
    OF "B-ALPHA":
     IF (alpha="T")
      row + 1, col 0,
      "======================================================================================================================",
      row + 1, col 5, cv.description,
      row + 1, col 6, "->",
      col + 1, n.source_string"####################################"
     ENDIF
    OF "C-SIGNLINE":
     tblobin = lb.long_blob,
     IF (cen.compression_cd=compressed_cd)
      CALL decompress_text(tblobin)
     ELSE
      tblobout = substring(1,(textlen(trim(tblobin)) - textlen("ocf_blob")),tblobin)
     ENDIF
     ,
     CALL rtf_to_text(tblobout,1,112)row + 1,col 15,
     "----- signature line ----------------------------------------------------------------------------------",
     FOR (z = 1 TO size(tmptext->qual,5))
       row + 1, col 20, tmptext->qual[z].text
     ENDFOR
    OF "D-SNOMED":
     row + 1,col 15,"+++++ diagnostic code group #",
     col + 1,cecr2_group_nbr"###",col + 1,
     "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++",row + 1,col 20,
     "      source id -> ",col + 1,n2.source_identifier"##########",
     row + 1,col 20,"  source string -> ",
     col + 1,n2.source_string"####################################",row + 1,
     col 20,"nomenclature id -> ",col + 1,
     cecr2.nomenclature_id"####################################",row + 1,col 20,
     "       event id -> ",col + 1,cecr2.event_id,
     row + 1,col 20,"       sequence -> ",
     col + 1,cecr2.seq"###"
    ELSE
     row + 1,col 15,"????? unknown "
   ENDCASE
  WITH nocounter, outerjoin = d5, append,
   memsort
 ;end select
 IF (curqual=0)
  CALL video(b)
  CALL text(12,3,"Loading reports    - NONE FOUND")
  CALL video(n)
  CALL pause(5)
 ELSE
  CALL text(12,3,"Loading reports    - Successful")
 ENDIF
#end_reporttext
 CALL text(24,5,"Press Return")
 CALL accept(24,3,"P;CU",".")
 FREE SET file_loc
 SET logical file_loc value(trim(print_filename))
 IF (findfile(concat(trim(print_filename),".dat"))=1)
  CALL text(24,5,"Loading file for view...")
  FREE DEFINE rtl
  DEFINE rtl "file_loc"
  SELECT
   ap_history_upload_audit = rtlt.line
   FROM rtlt
   WITH nocounter
  ;end select
  CALL text(24,5,"Cleaning work files...")
  SET dcl_cmd_del = concat("DELETE ",value(trim(print_filename)),".dat;")
  SET dcl_stat = 0
  CALL dcl(trim(dcl_cmd_del),textlen(trim(dcl_cmd_del)),dcl_stat)
 ELSE
  CALL text(24,5,"NO FILES WERE LOCATED... ")
  CALL pause(5)
 ENDIF
 GO TO accessretry
 SUBROUTINE refreshscreen(utilname)
   CALL clear(1,1)
   CALL video(r)
   CALL text(2,24,"        Anatomic Pathology         ")
   CALL text(3,24,utilname)
   CALL video(n)
   CALL box(1,1,23,80)
   CALL line(4,1,80,xhor)
   CALL line(1,22,4,xvert)
   CALL line(1,60,4,xvert)
 END ;Subroutine
 SUBROUTINE displaycase(dummy)
   CALL text(2,3,"Current Case:")
   CALL video(l)
   CALL text(3,3,accept_accession_nbr)
   CALL video(n)
 END ;Subroutine
#end_program
 CALL clear(1,1)
 CALL text(24,0,"Exiting Program...                                                      ")
END GO
