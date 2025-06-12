CREATE PROGRAM bhs_sys_purge_cea:dba
 FREE RECORD temp
 RECORD temp(
   1 cnt = i4
   1 qual[*]
     2 eventid = f8
 )
 CALL echo("main select")
 SELECT INTO "nl:"
  FROM ce_event_action cea,
   clinical_event ce
  PLAN (cea
   WHERE cea.action_prsnl_id > 0
    AND cea.updt_dt_tm > cnvtdatetime((curdate - 1),0))
   JOIN (ce
   WHERE cea.event_id=ce.event_id
    AND ce.event_class_cd=232
    AND ce.valid_until_dt_tm > sysdate)
  DETAIL
   temp->cnt = (temp->cnt+ 1), stat = alterlist(temp->qual,temp->cnt), temp->qual[temp->cnt].eventid
    = cea.ce_event_action_id
  WITH nocounter
 ;end select
 CALL echo("after select")
 CALL echo(build2("temp->cnt: ",temp->cnt))
 CALL echo(build2("temp->qual: ",size(temp->qual,5)))
 IF (curqual > 0)
  IF ((temp->cnt=0))
   GO TO exit_script
  ENDIF
  DELETE  FROM ce_prcs_queue cpq,
    (dummyt d  WITH seq = temp->cnt)
   SET cpq.seq = 1
   PLAN (d)
    JOIN (cpq
    WHERE (cpq.ce_event_action_id=temp->qual[d.seq].eventid))
   WITH nocounter, maxcommit = 1000
  ;end delete
  CALL echo(build("deleted records:",curqual))
  DELETE  FROM ce_event_action cea,
    (dummyt d  WITH seq = temp->cnt)
   SET cea.seq = 1
   PLAN (d)
    JOIN (cea
    WHERE (cea.ce_event_action_id=temp->qual[d.seq].eventid))
   WITH nocounter, maxcommit = 1000
  ;end delete
  CALL echo(build("deleted records:",curqual))
  COMMIT
 ENDIF
#exit_script
END GO
