CREATE PROGRAM bed_get_dmart_edu_instr:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 domains[*]
      2 code_value = f8
      2 display = vc
      2 parent_instr[*]
        3 pat_ed_reltn_id = f8
        3 pat_ed_reltn_parent_id = f8
        3 description = vc
        3 instruction_ind = i2
        3 unique_key = vc
        3 too_many_results_ind = i2
        3 has_child_instr_ind = i2
        3 child_instr[*]
          4 pat_ed_reltn_id = f8
          4 pat_ed_reltn_parent_id = f8
          4 description = vc
          4 instruction_ind = i2
          4 unique_key = vc
      2 too_many_results_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE populateparsestringbasedonrequest(dummyvar=i2) = null
 DECLARE setmaxreplyind(domainindex=i4,pcnt=i4,ccnt=i4) = null
 DECLARE search_string_found = i4 WITH protect, noconstant(0)
 DECLARE pcnt = i4 WITH protect, noconstant(0)
 DECLARE parent_instr_cnt = i4 WITH protect, noconstant(0)
 DECLARE ccnt = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE idx1 = i4 WITH protect, noconstant(0)
 DECLARE index = i4 WITH protect, noconstant(0)
 DECLARE instr_parse = vc WITH protect, noconstant("p2.prsnl_id = outerjoin(0.0)")
 DECLARE max_reply = i4 WITH protect, constant(5000)
 SET reply->status_data.status = "F"
 SET req_cnt = 0
 SET req_cnt = size(request->domains,5)
 IF (validate(request->search_text,"") > " ")
  CALL populateparsestringbasedonrequest(0)
 ENDIF
 IF (req_cnt > 0)
  SET stat = alterlist(reply->domains,req_cnt)
  FOR (x = 1 TO req_cnt)
    SET reply->domains[x].code_value = request->domains[x].code_value
    SET reply->domains[x].display = uar_get_code_display(request->domains[x].code_value)
    SET parent_instr_cnt = size(request->domains[x].parent_instructions,5)
    IF (parent_instr_cnt > 0
     AND search_string_found=1)
     SET instr_parse = concat(instr_parse," and p2.pat_ed_reltn_parent_id = ",
      "request->domains[1].parent_instructions[1].parent_instr_code_value")
    ELSEIF (parent_instr_cnt > 0
     AND search_string_found=0)
     SET instr_parse = concat(instr_parse," and p2.pat_ed_reltn_parent_id = ",
      "request->domains[1].parent_instructions[1].parent_instr_code_value")
    ENDIF
  ENDFOR
  SELECT INTO "nl:"
   FROM pat_ed_reltn p1,
    pat_ed_reltn p2
   PLAN (p1
    WHERE expand(idx,1,value(req_cnt),p1.pat_ed_domain_cd,reply->domains[idx].code_value)
     AND p1.active_ind=1
     AND p1.prsnl_id=0.0
     AND p1.pat_ed_reltn_parent_id=0.0
     AND p1.refr_text_id=0.0)
    JOIN (p2
    WHERE p2.pat_ed_reltn_parent_id=outerjoin(p1.pat_ed_reltn_id)
     AND p2.refr_text_id != outerjoin(0.0)
     AND parser(instr_parse))
   ORDER BY p1.pat_ed_reltn_id, p2.pat_ed_reltn_id
   HEAD REPORT
    pcnt = 0
   HEAD p1.pat_ed_reltn_id
    pcnt = (pcnt+ 1), stat = alterlist(reply->domains[index].parent_instr,pcnt), index = locateval(
     idx1,1,value(req_cnt),p1.pat_ed_domain_cd,reply->domains[idx1].code_value),
    reply->domains[index].parent_instr[pcnt].pat_ed_reltn_id = p1.pat_ed_reltn_id, reply->domains[
    index].parent_instr[pcnt].pat_ed_reltn_parent_id = p1.pat_ed_reltn_parent_id, reply->domains[
    index].parent_instr[pcnt].description = p1.pat_ed_reltn_desc,
    reply->domains[index].parent_instr[pcnt].unique_key = p1.key_doc_ident, reply->domains[index].
    parent_instr[pcnt].instruction_ind = 0, ccnt = 0
   HEAD p2.pat_ed_reltn_id
    ccnt = (ccnt+ 1), stat = alterlist(reply->domains[index].parent_instr[pcnt].child_instr,ccnt),
    reply->domains[index].parent_instr[pcnt].child_instr[ccnt].pat_ed_reltn_id = p2.pat_ed_reltn_id,
    reply->domains[index].parent_instr[pcnt].child_instr[ccnt].pat_ed_reltn_parent_id = p2
    .pat_ed_reltn_parent_id, reply->domains[index].parent_instr[pcnt].child_instr[ccnt].description
     = p2.pat_ed_reltn_desc, reply->domains[index].parent_instr[pcnt].child_instr[ccnt].unique_key =
    p2.key_doc_ident,
    reply->domains[index].parent_instr[pcnt].child_instr[ccnt].instruction_ind = 1
   FOOT  p2.pat_ed_reltn_id
    IF (p2.pat_ed_reltn_id=0.0)
     stat = alterlist(reply->domains[req_cnt].parent_instr[pcnt].child_instr,0)
    ENDIF
    IF (size(reply->domains[req_cnt].parent_instr[pcnt].child_instr,5) > 0)
     reply->domains[req_cnt].parent_instr[pcnt].has_child_instr_ind = 1
    ENDIF
   FOOT  p1.pat_ed_reltn_id
    CALL setmaxreplyind(index,pcnt,ccnt)
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM code_value cv,
    pat_ed_reltn p1,
    pat_ed_reltn p2
   PLAN (cv
    WHERE cv.code_set=24849
     AND cv.active_ind=1)
    JOIN (p1
    WHERE p1.pat_ed_domain_cd=cv.code_value
     AND p1.prsnl_id=0
     AND p1.active_ind=1
     AND p1.pat_ed_reltn_parent_id=0.0
     AND p1.refr_text_id=0.0)
    JOIN (p2
    WHERE p2.pat_ed_reltn_parent_id=outerjoin(p1.pat_ed_reltn_id)
     AND p2.refr_text_id != outerjoin(0.00)
     AND p2.prsnl_id=outerjoin(0.00))
   ORDER BY cv.display, cv.code_value, p1.pat_ed_reltn_id,
    p2.pat_ed_reltn_id
   HEAD REPORT
    req_cnt = 0
   HEAD cv.code_value
    req_cnt = (req_cnt+ 1), stat = alterlist(reply->domains,req_cnt), reply->domains[req_cnt].
    code_value = cv.code_value,
    reply->domains[req_cnt].display = cv.display, pcnt = 0
   HEAD p1.pat_ed_reltn_id
    pcnt = (pcnt+ 1), stat = alterlist(reply->domains[req_cnt].parent_instr,pcnt), reply->domains[
    req_cnt].parent_instr[pcnt].pat_ed_reltn_id = p1.pat_ed_reltn_id,
    reply->domains[req_cnt].parent_instr[pcnt].pat_ed_reltn_parent_id = p1.pat_ed_reltn_parent_id,
    reply->domains[req_cnt].parent_instr[pcnt].description = p1.pat_ed_reltn_desc, reply->domains[
    req_cnt].parent_instr[pcnt].unique_key = p1.key_doc_ident,
    reply->domains[req_cnt].parent_instr[pcnt].instruction_ind = 0, ccnt = 0
   HEAD p2.pat_ed_reltn_id
    ccnt = (ccnt+ 1), stat = alterlist(reply->domains[req_cnt].parent_instr[pcnt].child_instr,ccnt),
    reply->domains[req_cnt].parent_instr[pcnt].child_instr[ccnt].pat_ed_reltn_id = p2.pat_ed_reltn_id,
    reply->domains[req_cnt].parent_instr[pcnt].child_instr[ccnt].pat_ed_reltn_parent_id = p2
    .pat_ed_reltn_parent_id, reply->domains[req_cnt].parent_instr[pcnt].child_instr[ccnt].description
     = p2.pat_ed_reltn_desc, reply->domains[req_cnt].parent_instr[pcnt].child_instr[ccnt].unique_key
     = p2.key_doc_ident,
    reply->domains[req_cnt].parent_instr[pcnt].child_instr[ccnt].instruction_ind = 1
   FOOT  p2.pat_ed_reltn_id
    IF (p2.pat_ed_reltn_id=0.0)
     stat = alterlist(reply->domains[req_cnt].parent_instr[pcnt].child_instr,0)
    ENDIF
    IF (size(reply->domains[req_cnt].parent_instr[pcnt].child_instr,5) > 0)
     reply->domains[req_cnt].parent_instr[pcnt].has_child_instr_ind = 1
    ENDIF
   FOOT  p1.pat_ed_reltn_id
    CALL setmaxreplyind(req_cnt,pcnt,ccnt)
   WITH nocounter
  ;end select
 ENDIF
 SUBROUTINE populateparsestringbasedonrequest(dummyvar)
   IF (validate(request->search_text,"") > " ")
    SET search_string_found = 1
    IF ((request->search_type IN ("S", "s"))
     AND (request->search_text > " "))
     SET instr_parse = concat(instr_parse," and cnvtupper(p2.pat_ed_reltn_desc) = '",cnvtupper(trim(
        request->search_text)),"*'")
    ELSEIF ((request->search_type IN ("C", "c"))
     AND (request->search_text > " "))
     SET instr_parse = concat(instr_parse," and cnvtupper(p2.pat_ed_reltn_desc) = '*",cnvtupper(trim(
        request->search_text)),"*'")
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE setmaxreplyind(domainindex,pcnt,ccnt)
   IF (ccnt > max_reply)
    SET reply->domains[domainindex].too_many_results_ind = 1
    SET reply->domains[domainindex].parent_instr[pcnt].too_many_results_ind = 1
    SET stat = alterlist(reply->domains[domainindex].parent_instr[pcnt].child_instr,0)
   ENDIF
 END ;Subroutine
#exit_script
 IF (ccnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
