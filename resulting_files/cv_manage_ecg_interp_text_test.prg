CREATE PROGRAM cv_manage_ecg_interp_text_test
 SET trace = rdbdebug
 SET trace = rdbbind
 SET reqdata->loglevel = 4
 SET modify = predeclare
 FREE RECORD request
 FREE RECORD reply
 RECORD request(
   1 qual[*]
     2 interpretation_text = vc
     2 interpretation_id = f8
   1 action = i2
 )
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE stat = i4 WITH protect
 DECLARE test1_var = c1 WITH protect, noconstant("F")
 DECLARE test2_var = c1 WITH protect, noconstant("F")
 DECLARE test3_var = c1 WITH protect, noconstant("F")
 DECLARE test4_var = c1 WITH protect, noconstant("F")
 DECLARE test5_var = c1 WITH protect, noconstant("F")
 DECLARE test6_var = c1 WITH protect, noconstant("F")
 SET stat = alterlist(request->qual,1)
 SET request->qual[1].interpretation_text = "This is the text for test 1"
 SELECT INTO "nl:"
  FROM cv_step cs
  WHERE cs.cv_step_id != 0.0
  DETAIL
   request->qual[1].interpretation_id = cs.cv_step_id
  WITH nocounter, maxqual(cs,1)
 ;end select
 SELECT INTO "nl:"
  FROM long_text lt
  WHERE lt.parent_entity_name="CV_STEP"
   AND (lt.parent_entity_id=request->qual[1].interpretation_id)
  WITH nocounter
 ;end select
 IF (curqual=0)
  EXECUTE cv_manage_ecg_interp_text
 ELSE
  CALL echo(concat("Interp already exists for cv_step_id ",cnvtstring(request->qual[1].
     interpretation_id),". Remove interp and test again"))
  GO TO exit_script
 ENDIF
 SET test1_var = reply->status_data.status
 CALL echorecord(request)
 CALL echorecord(reply)
 SELECT
  lt.long_text, lt.*
  FROM long_text lt
  WHERE (lt.parent_entity_id=request->qual[1].interpretation_id)
   AND lt.parent_entity_name="CV_STEP"
  WITH nocounter
 ;end select
 SET stat = initrec(reply)
 SET request->qual[1].interpretation_text = "This is the text for test 2"
 EXECUTE cv_manage_ecg_interp_text
 SET test2_var = reply->status_data.status
 CALL echorecord(request)
 CALL echorecord(reply)
 SELECT
  lt.long_text, lt.*
  FROM long_text lt
  WHERE (lt.parent_entity_id=request->qual[1].interpretation_id)
   AND lt.parent_entity_name="CV_STEP"
  WITH nocounter
 ;end select
 SET stat = initrec(reply)
 SET request->action = 1
 EXECUTE cv_manage_ecg_interp_text
 SET test3_var = reply->status_data.status
 CALL echorecord(request)
 CALL echorecord(reply)
 SELECT
  lt.long_text, lt.*
  FROM long_text lt
  WHERE (lt.parent_entity_id=request->qual[1].interpretation_id)
   AND lt.parent_entity_name="CV_STEP"
  WITH nocounter
 ;end select
 SET stat = initrec(reply)
 SET stat = initrec(request)
 SET stat = alterlist(request->qual,10)
 SELECT INTO "nl:"
  FROM cv_step cs
  WHERE cs.cv_step_id != 0.0
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt += 1, request->qual[cnt].interpretation_id = cs.cv_step_id, request->qual[cnt].
   interpretation_text = concat("This is the text for test 4, item number ",cnvtstring(cnt))
  WITH nocounter, maxqual(cs,10)
 ;end select
 SELECT INTO "nl:"
  FROM long_text lt,
   (dummyt d  WITH seq = value(10))
  PLAN (d)
   JOIN (lt
   WHERE lt.parent_entity_name="CV_STEP"
    AND (lt.parent_entity_id=request->qual[d.seq].interpretation_id))
  WITH nocounter
 ;end select
 IF (curqual=0)
  EXECUTE cv_manage_ecg_interp_text
 ELSE
  CALL echo("Interps already exists for some cv_step_ids. Remove interps and test again")
  GO TO exit_script
 ENDIF
 SET test4_var = reply->status_data.status
 CALL echorecord(request)
 CALL echorecord(reply)
 SELECT
  lt.long_text, lt.*
  FROM long_text lt,
   (dummyt d  WITH seq = value(10))
  PLAN (d)
   JOIN (lt
   WHERE (lt.parent_entity_id=request->qual[d.seq].interpretation_id)
    AND lt.parent_entity_name="CV_STEP")
  WITH nocounter
 ;end select
 SET stat = initrec(reply)
 FOR (i = 1 TO 10)
   SET request->qual[i].interpretation_text = concat("This is the text for test 5, item number ",
    cnvtstring(i))
 ENDFOR
 EXECUTE cv_manage_ecg_interp_text
 SET test5_var = reply->status_data.status
 CALL echorecord(request)
 CALL echorecord(reply)
 SELECT
  lt.long_text, lt.*
  FROM long_text lt,
   (dummyt d  WITH seq = value(10))
  PLAN (d)
   JOIN (lt
   WHERE (lt.parent_entity_id=request->qual[d.seq].interpretation_id)
    AND lt.parent_entity_name="CV_STEP")
  WITH nocounter
 ;end select
 SET stat = initrec(reply)
 SET request->action = 1
 EXECUTE cv_manage_ecg_interp_text
 SET test6_var = reply->status_data.status
 CALL echorecord(request)
 CALL echorecord(reply)
 SELECT
  lt.long_text, lt.*
  FROM long_text lt,
   (dummyt d  WITH seq = value(10))
  PLAN (d)
   JOIN (lt
   WHERE (lt.parent_entity_id=request->qual[d.seq].interpretation_id)
    AND lt.parent_entity_name="CV_STEP")
  WITH nocounter
 ;end select
#exit_script
 CALL echo(concat("TEST 1 - Insert interpretation text for 1 step. Result - ",test1_var,
   ". Expected result - S."))
 CALL echo(concat("TEST 2 - Update interpretation text for 1 step. Result - ",test2_var,
   ". Expected result - S."))
 CALL echo(concat("TEST 3 - Delete interpretation text for 1 step. Result - ",test3_var,
   ". Expected result - S."))
 CALL echo(concat("TEST 4 - Insert interpretation text for 10 steps. Result - ",test4_var,
   ". Expected result - S."))
 CALL echo(concat("TEST 5 - Update interpretation text for 10 steps. Result - ",test5_var,
   ". Expected result - S."))
 CALL echo(concat("TEST 6 - Delete interpretation text for 10 steps. Result - ",test6_var,
   ". Expected result - S."))
 SET modify = nopredeclare
 SET trace = nordbdebug
 SET trace = nordbbind
 SET reqdata->loglevel = 0
END GO
