CREATE PROGRAM ams_org_confidentiality:dba
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
 RECORD file_content(
   1 line[*]
     2 col[*]
       3 value = vc
 )
 FREE RECORD person_ord_id_rec
 RECORD person_ord_id_rec(
   1 person_qual[*]
     2 person_name = vc
     2 person_id = f8
     2 org_id_qual[*]
       3 org_id = vc
       3 organization_id = f8
 )
 DECLARE confidentiality_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",87,
   "ROUTINECLINICAL"))
 SET path = value(logical( $DIRECTORY))
 SET infile =  $INPUTFILE
 SET file_path = build(path,":",infile)
 CALL echo(build(path,":",infile))
 CALL echo(file_path)
 DEFINE rtl2 value(file_path)
 SELECT INTO "nl:"
  FROM rtl2t r
  HEAD REPORT
   row_count = 0, stat = alterlist(file_content->line,10)
  DETAIL
   line1 = r.line
   IF (size(trim(line1),1) > 0)
    row_count = (row_count+ 1)
    IF (mod(row_count,10)=1
     AND row_count > 10)
     stat = alterlist(file_content->line,(row_count+ 9))
    ENDIF
    stat = alterlist(file_content->line[row_count].col,10), count = 0
    WHILE (size(trim(line1),1) > 0)
      count = (count+ 1)
      IF (count > 10
       AND mod(count,10)=1)
       stat = alterlist(file_content->line[row_count].col,(count+ 9))
      ENDIF
      IF (substring(1,1,line1)=build('"'))
       position = findstring('"',line1,2,0), file_content->line[row_count].col[count].value =
       substring(2,(position - 2),line1), line1 = substring((position+ 2),size(trim(line1),1),line1)
      ELSE
       position = findstring(",",line1,1,0)
       IF (position > 0)
        file_content->line[row_count].col[count].value = substring(1,(position - 1),line1), line1 =
        substring((position+ 1),size(trim(line1),1),line1)
       ELSE
        file_content->line[row_count].col[count].value = line1, line1 = ""
       ENDIF
      ENDIF
    ENDWHILE
    stat = alterlist(file_content->line[row_count].col,count)
   ENDIF
  FOOT REPORT
   stat = alterlist(file_content->line,row_count)
  WITH nocounter
 ;end select
 DECLARE name = vc
 SELECT INTO "nl:"
  name = substring(1,200,file_content->line[d1.seq].col[1].value)
  FROM (dummyt d1  WITH seq = value(size(file_content->line,5)))
  ORDER BY file_content->line[d1.seq].col[1].value
  HEAD REPORT
   stat = alterlist(person_ord_id_rec->person_qual,10), person_count = 0
  HEAD name
   person_count = (person_count+ 1)
   IF (person_count > 10
    AND mod(person_count,10)=1)
    stat = alterlist(person_ord_id_rec->person_qual,(person_count+ 9))
   ENDIF
   person_ord_id_rec->person_qual[person_count].person_name = file_content->line[d1.seq].col[1].value,
   stat = alterlist(person_ord_id_rec->person_qual[person_count].org_id_qual,10), org_count = 0
  DETAIL
   org_count = (org_count+ 1)
   IF (org_count > 10
    AND mod(org_count,10)=1)
    stat = alterlist(person_ord_id_rec->person_qual[person_count].org_id_qual,(org_count+ 9))
   ENDIF
   person_ord_id_rec->person_qual[person_count].org_id_qual[org_count].org_id = file_content->line[d1
   .seq].col[2].value
  FOOT  name
   stat = alterlist(person_ord_id_rec->person_qual[person_count].org_id_qual,org_count)
  FOOT REPORT
   stat = alterlist(person_ord_id_rec->person_qual,person_count)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(person_ord_id_rec->person_qual,5))),
   prsnl p
  PLAN (d1)
   JOIN (p
   WHERE (p.username=person_ord_id_rec->person_qual[d1.seq].person_name))
  DETAIL
   person_ord_id_rec->person_qual[d1.seq].person_id = p.person_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(person_ord_id_rec->person_qual,5))),
   (dummyt d2  WITH seq = 1),
   organization o
  PLAN (d1
   WHERE maxrec(d2,size(person_ord_id_rec->person_qual[d1.seq].org_id_qual,5)))
   JOIN (d2)
   JOIN (o
   WHERE o.organization_id=cnvtreal(person_ord_id_rec->person_qual[d1.seq].org_id_qual[d2.seq].org_id
    ))
  DETAIL
   person_ord_id_rec->person_qual[d1.seq].org_id_qual[d2.seq].organization_id = o.organization_id
  WITH nocounter
 ;end select
 CALL echorecord(person_ord_id_rec)
 UPDATE  FROM prsnl_org_reltn p,
   (dummyt d1  WITH seq = value(size(person_ord_id_rec->person_qual,5))),
   (dummyt d2  WITH seq = 1)
  SET p.confid_level_cd = confidentiality_cd, p.updt_cnt = (p.updt_cnt+ 1), p.updt_id = reqinfo->
   updt_id,
   p.updt_dt_tm = cnvtdatetime(curdate,curtime3)
  PLAN (d1
   WHERE maxrec(d2,size(person_ord_id_rec->person_qual[d1.seq].org_id_qual,5)))
   JOIN (d2)
   JOIN (p
   WHERE (p.person_id=person_ord_id_rec->person_qual[d1.seq].person_id)
    AND (p.organization_id=person_ord_id_rec->person_qual[d1.seq].org_id_qual[d2.seq].organization_id
   ))
  WITH nocounter
 ;end update
 COMMIT
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
