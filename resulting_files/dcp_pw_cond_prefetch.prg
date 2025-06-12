CREATE PROGRAM dcp_pw_cond_prefetch
 RECORD reply(
   1 conditionlist[*]
     2 ekm_name = vc
     2 true_ind = i2
     2 evaluated_ind = i2
     2 info_text = vc
     2 info_list[*]
       3 name = vc
       3 value = vc
 )
 RECORD event(
   1 qual[*]
     2 accession_id = f8
     2 order_id = f8
     2 encntr_id = f8
     2 person_id = f8
     2 logging = c100
     2 cnt = i4
     2 data[*]
       3 misc = vc
 )
 SET eks_common->event_repeat_count = 1
 SET cnt = eks_common->event_repeat_count
 SET stat = alterlist(event->qual,cnt)
 FOR (inx = 1 TO cnt)
   SET event->qual[inx].order_id = 0.0
   SET event->qual[inx].person_id = request->person_id
   SET event->qual[inx].encntr_id = request->encntr_id
   SET event->qual[inx].accession_id = 0.0
 ENDFOR
 CALL echo("this prefetch is rock solid")
END GO
