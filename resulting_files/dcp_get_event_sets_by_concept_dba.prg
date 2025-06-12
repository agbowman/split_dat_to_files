CREATE PROGRAM dcp_get_event_sets_by_concept:dba
 RECORD reply(
   1 concepts[*]
     2 concept_cki = vc
     2 event_sets[*]
       3 event_set_cd = f8
       3 event_set_cd_disp = vc
       3 event_set_name = vc
       3 event_codes[*]
         4 event_cd = f8
         4 event_cd_disp = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 event_sets[*]
     2 event_set_cd = f8
     2 event_codes[*]
       3 event_cd = f8
       3 event_cd_disp = vc
 )
 DECLARE queryeventsets(null) = null
 DECLARE queryeventcodes(null) = null
 DECLARE batch_size = i4 WITH constant(20)
 DECLARE nstart = i4 WITH noconstant(1)
 DECLARE cur_list_size = i4 WITH noconstant(0)
 DECLARE loop_cnt = i4 WITH noconstant(0)
 DECLARE new_list_size = i4 WITH noconstant(0)
 DECLARE idx = i4 WITH noconstant(1), protected
 DECLARE num1 = i4 WITH noconstant(1), protected
 SET reply->status_data.status = "F"
 CALL queryeventsets(null)
 IF ((request->event_code_ind=1))
  CALL queryeventcodes(null)
 ENDIF
 SET reply->status_data.status = "S"
 GO TO exit_script
 SUBROUTINE queryeventsets(null)
   SET cur_list_size = size(request->concepts,5)
   SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
   SET new_list_size = (loop_cnt * batch_size)
   SET stat = alterlist(request->concepts,new_list_size)
   SET stat = alterlist(reply->concepts,new_list_size)
   FOR (idx = (cur_list_size+ 1) TO new_list_size)
     SET request->concepts[idx].concept_cki = request->concepts[cur_list_size].concept_cki
   ENDFOR
   FOR (idx = 1 TO new_list_size)
     SET reply->concepts[idx].concept_cki = request->concepts[idx].concept_cki
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(loop_cnt)),
     code_value cv,
     v500_event_set_explode ese,
     v500_event_set_explode ese2,
     v500_event_set_code esc
    PLAN (d1
     WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
     JOIN (cv
     WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),cv.concept_cki,request->concepts[idx].
      concept_cki))
     JOIN (ese
     WHERE ese.event_set_cd=cv.code_value
      AND cv.active_ind=1
      AND (((request->retrieve_all_prim_children=1)) OR (ese.event_set_level=0)) )
     JOIN (ese2
     WHERE ese2.event_cd=ese.event_cd
      AND ese2.event_set_level=0)
     JOIN (esc
     WHERE esc.event_set_cd=ese2.event_set_cd)
    ORDER BY cv.concept_cki
    HEAD cv.concept_cki
     index = locateval(num1,1,cur_list_size,cv.concept_cki,request->concepts[num1].concept_cki), cnt1
      = 0
    DETAIL
     cnt1 = (cnt1+ 1)
     IF (mod(cnt1,5)=1)
      stat = alterlist(reply->concepts[index].event_sets,(cnt1+ 4))
     ENDIF
     reply->concepts[index].event_sets[cnt1].event_set_cd = esc.event_set_cd, reply->concepts[index].
     event_sets[cnt1].event_set_cd_disp = esc.event_set_cd_disp, reply->concepts[index].event_sets[
     cnt1].event_set_name = esc.event_set_name
    FOOT  cv.concept_cki
     stat = alterlist(reply->concepts[index].event_sets,cnt1)
    WITH nocounter
   ;end select
   SET stat = alterlist(reply->concepts,cur_list_size)
   IF (curqual=0)
    SET reply->status_data.status = "Z"
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE queryeventcodes(null)
   SET cnt = 0
   FOR (i = 1 TO size(reply->concepts,5))
     FOR (j = 1 TO size(reply->concepts[i].event_sets,5))
       SET cnt = (cnt+ 1)
       IF (mod(cnt,10)=1)
        SET stat = alterlist(temp->event_sets,(cnt+ 9))
       ENDIF
       SET temp->event_sets[cnt].event_set_cd = reply->concepts[i].event_sets[j].event_set_cd
     ENDFOR
   ENDFOR
   SET stat = alterlist(temp->event_sets,cnt)
   SET cur_list_size = size(temp->event_sets,5)
   IF (cur_list_size=0)
    SET reply->status_data.status = "Z"
    GO TO exit_script
   ENDIF
   SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
   SET new_list_size = (loop_cnt * batch_size)
   SET stat = alterlist(temp->event_sets,new_list_size)
   FOR (idx = (cur_list_size+ 1) TO new_list_size)
     SET temp->event_sets[idx].event_set_cd = temp->event_sets[cur_list_size].event_set_cd
   ENDFOR
   SELECT INTO "nl:"
    vese.event_cd
    FROM (dummyt d1  WITH seq = value(loop_cnt)),
     v500_event_set_explode vese,
     v500_event_code vec
    PLAN (d1
     WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
     JOIN (vese
     WHERE expand(idx,nstart,((nstart+ batch_size) - 1),vese.event_set_cd,temp->event_sets[idx].
      event_set_cd))
     JOIN (vec
     WHERE vec.event_cd=vese.event_cd)
    ORDER BY vese.event_cd
    HEAD vese.event_set_cd
     index = locateval(num1,1,cur_list_size,vese.event_set_cd,temp->event_sets[num1].event_set_cd),
     cnt = 0
    DETAIL
     cnt = (cnt+ 1)
     IF (mod(cnt,5)=1)
      stat = alterlist(temp->event_sets[index].event_codes,(cnt+ 4))
     ENDIF
     temp->event_sets[index].event_codes[cnt].event_cd = vese.event_cd, temp->event_sets[index].
     event_codes[cnt].event_cd_disp = vec.event_cd_disp
    FOOT  vese.event_set_cd
     stat = alterlist(temp->event_sets[index].event_codes,cnt)
    WITH nocounter
   ;end select
   SET stat = alterlist(temp->event_sets,cur_list_size)
   SET cnt = 1
   FOR (i = 1 TO size(reply->concepts,5))
     FOR (j = 1 TO size(reply->concepts[i].event_sets,5))
       SET eccount = size(temp->event_sets[cnt].event_codes,5)
       SET stat = alterlist(reply->concepts[i].event_sets[j].event_codes,eccount)
       FOR (idx = 1 TO eccount)
        SET reply->concepts[i].event_sets[j].event_codes[idx].event_cd = temp->event_sets[cnt].
        event_codes[idx].event_cd
        SET reply->concepts[i].event_sets[j].event_codes[idx].event_cd_disp = temp->event_sets[cnt].
        event_codes[idx].event_cd_disp
       ENDFOR
       SET cnt = (cnt+ 1)
     ENDFOR
   ENDFOR
 END ;Subroutine
#exit_script
END GO
