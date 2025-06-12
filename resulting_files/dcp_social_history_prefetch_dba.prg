CREATE PROGRAM dcp_social_history_prefetch:dba
 SET eks_common->event_repeat_count = 1
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
 SET stat = alterlist(event->qual,1)
 SET event->qual[1].person_id = request->person_id
END GO
