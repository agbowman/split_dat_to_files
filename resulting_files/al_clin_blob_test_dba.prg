CREATE PROGRAM al_clin_blob_test:dba
 DECLARE inerror_cd = f8 WITH protect, noconstant(0)
 SET inerror_cd = uar_get_code_by("MEANING",8,"INERROR")
 DECLARE sign_cd = f8 WITH protect, noconstant(0)
 SET sign_cd = uar_get_code_by("displaykey",21,"SIGN")
 DECLARE compress_cd = f8
 SET stat = uar_get_meaning_by_codeset(120,"OCFCOMP",1,compress_cd)
 DECLARE cnt_blob = i4
 DECLARE first_nurse_blob_ind1 = i2
 DECLARE first_nurse_blob_ind2 = i2
 DECLARE first_nurse_blob_ind3 = i2
 FREE RECORD pt_transfer
 RECORD pt_transfer(
   1 blob_cnt = i4
   1 blob_qual[*]
     2 blob_event_cd = vc
     2 blob_set_name = vc
     2 event_title_text = vc
     2 blob_date = vc
     2 blobs_cnt = i4
     2 blobs_qual[*]
       3 blob_contents = vc
       3 event_id = f8
       3 blob_length = i4
       3 event_title_text = vc
       3 comp_cd = f8
       3 blobseq = i4
     2 action_cnt = i2
     2 action_qual[*]
       3 type = vc
       3 status = vc
       3 prsnl_name = vc
       3 date = vc
 ) WITH protect
 SELECT INTO "nl:"
  FROM clinical_event ce,
   v500_event_set_explode vese,
   v500_event_set_code vesc,
   clinical_event ce1,
   ce_blob ceb,
   ce_event_prsnl cep,
   prsnl pr,
   prsnl pr1
  PLAN (ce
   WHERE ce.encntr_id=76856584
    AND ce.publish_flag=1
    AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime)
    AND  NOT (ce.result_status_cd IN (inerror_cd)))
   JOIN (vese
   WHERE vese.event_cd=ce.event_cd)
   JOIN (vesc
   WHERE vesc.event_set_cd=vese.event_set_cd
    AND vesc.event_set_name IN ("Transfer Summary - Dictated", "Discharge/Transfer Note",
   "Physician Discharge Summary", "Discharge Summary - Dictated", "Discharge Summary - Converted",
   "Nursing Discharge Status Report", "Cardiovascular", "Cardiovascular (new)", "CARDIOVASCULAR TEST",
   "History and Physical - Dictated",
   "RADIOLOGY", "Consultation Note - Dictated", "History and Physical Hospital",
   "Discharge/Transfer Note Hospital"))
   JOIN (ce1
   WHERE ce1.event_id=outerjoin(ce.parent_event_id))
   JOIN (ceb
   WHERE ceb.event_id=ce.event_id
    AND ceb.valid_until_dt_tm >= cnvtdatetime(curdate,curtime))
   JOIN (cep
   WHERE cep.event_id=outerjoin(ce1.event_id)
    AND cep.valid_until_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime))
    AND cep.action_type_cd=outerjoin(sign_cd))
   JOIN (pr
   WHERE pr.person_id=outerjoin(cep.action_prsnl_id))
   JOIN (pr1
   WHERE pr1.person_id=outerjoin(cep.request_prsnl_id))
  ORDER BY ce.event_end_dt_tm DESC, ce.parent_event_id, ce.event_id,
   cep.ce_event_prsnl_id
  HEAD REPORT
   cnt_blob = 0, stat = alterlist(pt_transfer->blob_qual,5), first_nurse_blob_ind1 = 0,
   first_nurse_blob_ind2 = 0, first_nurse_blob_ind3 = 0
  HEAD ce.event_end_dt_tm
   row + 0
  HEAD ce.parent_event_id
   IF (vesc.event_set_name="Nursing Discharge Status Report")
    IF (first_nurse_blob_ind1=0)
     first_nurse_blob_ind1 = 1, cnt_blob = (cnt_blob+ 1)
     IF (mod(cnt_blob,5)=1)
      stat = alterlist(pt_transfer->blob_qual,(cnt_blob+ 5))
     ENDIF
     pt_transfer->blob_qual[cnt_blob].blob_event_cd = trim(uar_get_code_display(ce.event_cd)),
     pt_transfer->blob_qual[cnt_blob].blob_date = format(ce.event_end_dt_tm,"mm/dd/yy hh:mm;;d"),
     pt_transfer->blob_qual[cnt_blob].blob_set_name = vesc.event_set_name,
     pt_transfer->blob_qual[cnt_blob].event_title_text = trim(ce.event_title_text), stat = alterlist(
      pt_transfer->blob_qual[cnt_blob].action_qual,5), cnt_action = 0,
     stat = alterlist(pt_transfer->blob_qual[cnt_blob].blobs_qual,5), cnt_blobs = 0
    ENDIF
   ELSE
    cnt_blob = (cnt_blob+ 1)
    IF (mod(cnt_blob,5)=1)
     stat = alterlist(pt_transfer->blob_qual,(cnt_blob+ 5))
    ENDIF
    pt_transfer->blob_qual[cnt_blob].blob_event_cd = trim(uar_get_code_display(ce.event_cd)),
    pt_transfer->blob_qual[cnt_blob].blob_date = format(ce.event_end_dt_tm,"mm/dd/yy hh:mm;;d"),
    pt_transfer->blob_qual[cnt_blob].blob_set_name = vesc.event_set_name,
    pt_transfer->blob_qual[cnt_blob].event_title_text = trim(ce.event_title_text), stat = alterlist(
     pt_transfer->blob_qual[cnt_blob].action_qual,5), cnt_action = 0,
    stat = alterlist(pt_transfer->blob_qual[cnt_blob].blobs_qual,5), cnt_blobs = 0
   ENDIF
  HEAD ce.event_id
   IF (vesc.event_set_name="Nursing Discharge Status Report")
    IF (first_nurse_blob_ind2=0)
     first_nurse_blob_ind2 = 1, cnt_blobs = (cnt_blobs+ 1)
     IF (mod(cnt_blobs,5)=1)
      stat = alterlist(pt_transfer->blob_qual[cnt_blob].blobs_qual,(cnt_blobs+ 5))
     ENDIF
     pt_transfer->blob_qual[cnt_blob].blobs_qual[cnt_blobs].event_id = ceb.event_id, pt_transfer->
     blob_qual[cnt_blob].blobs_qual[cnt_blobs].event_title_text = trim(ce.event_title_text),
     pt_transfer->blob_qual[cnt_blob].blobs_qual[cnt_blobs].blob_contents = ceb.blob_contents,
     pt_transfer->blob_qual[cnt_blob].blobs_qual[cnt_blobs].blob_length = ceb.blob_length,
     pt_transfer->blob_qual[cnt_blob].blobs_qual[cnt_blobs].comp_cd = ceb.compression_cd, pt_transfer
     ->blob_qual[cnt_blob].blobs_qual[cnt_blobs].blobseq = ceb.blob_seq_num
    ENDIF
   ELSE
    cnt_blobs = (cnt_blobs+ 1)
    IF (mod(cnt_blobs,5)=1)
     stat = alterlist(pt_transfer->blob_qual[cnt_blob].blobs_qual,(cnt_blobs+ 5))
    ENDIF
    pt_transfer->blob_qual[cnt_blob].blobs_qual[cnt_blobs].event_id = ceb.event_id, pt_transfer->
    blob_qual[cnt_blob].blobs_qual[cnt_blobs].event_title_text = trim(ce.event_title_text),
    pt_transfer->blob_qual[cnt_blob].blobs_qual[cnt_blobs].blob_contents = ceb.blob_contents,
    pt_transfer->blob_qual[cnt_blob].blobs_qual[cnt_blobs].comp_cd = ceb.compression_cd, pt_transfer
    ->blob_qual[cnt_blob].blobs_qual[cnt_blobs].blobseq = ceb.blob_seq_num
   ENDIF
   IF (((vesc.event_set_name="Transfer Summary - Dictated") OR (((vesc.event_set_name=
   "Discharge/Transfer Note") OR (((vesc.event_set_name="Physician Discharge Summary") OR (((vesc
   .event_set_name="Discharge/Transfer Note Hospital") OR (((vesc.event_set_name=
   "History and Physical Hospital") OR (vesc.event_set_name="Discharge Summary - Dictated")) )) ))
   )) )) )
    discharge_found = 1
   ENDIF
  HEAD cep.ce_event_prsnl_id
   IF (vesc.event_set_name="Nursing Discharge Status Report")
    IF (first_nurse_blob_ind3=0)
     first_nurse_blob_ind3 = 1
     IF (ce.event_title_text != "Addendum by*"
      AND cep.action_type_cd > 0)
      cnt_action = (cnt_action+ 1)
      IF (mod(cnt_action,5)=1)
       stat = alterlist(pt_transfer->blob_qual[cnt_blob].action_qual,(cnt_action+ 5))
      ENDIF
      pt_transfer->blob_qual[cnt_blob].action_qual[cnt_action].type = trim(uar_get_code_display(cep
        .action_type_cd)), pt_transfer->blob_qual[cnt_blob].action_qual[cnt_action].status = trim(
       uar_get_code_display(cep.action_status_cd)), pt_transfer->blob_qual[cnt_blob].action_qual[
      cnt_action].date = format(cep.action_dt_tm,"mm/dd/yy hh:mm;;d")
      IF (pr.person_id > 0)
       pt_transfer->blob_qual[cnt_blob].action_qual[cnt_action].prsnl_name = trim(pr
        .name_full_formatted)
      ELSEIF (pr1.person_id > 0)
       pt_transfer->blob_qual[cnt_blob].action_qual[cnt_action].prsnl_name = trim(pr1
        .name_full_formatted)
      ENDIF
     ENDIF
    ENDIF
   ELSE
    IF (ce.event_title_text != "Addendum by*"
     AND cep.action_type_cd > 0)
     cnt_action = (cnt_action+ 1)
     IF (mod(cnt_action,5)=1)
      stat = alterlist(pt_transfer->blob_qual[cnt_blob].action_qual,(cnt_action+ 5))
     ENDIF
     pt_transfer->blob_qual[cnt_blob].action_qual[cnt_action].type = trim(uar_get_code_display(cep
       .action_type_cd)), pt_transfer->blob_qual[cnt_blob].action_qual[cnt_action].status = trim(
      uar_get_code_display(cep.action_status_cd)), pt_transfer->blob_qual[cnt_blob].action_qual[
     cnt_action].date = format(cep.action_dt_tm,"mm/dd/yy hh:mm;;d")
     IF (pr.person_id > 0)
      pt_transfer->blob_qual[cnt_blob].action_qual[cnt_action].prsnl_name = trim(pr
       .name_full_formatted)
     ELSEIF (pr1.person_id > 0)
      pt_transfer->blob_qual[cnt_blob].action_qual[cnt_action].prsnl_name = trim(pr1
       .name_full_formatted)
     ENDIF
    ENDIF
   ENDIF
  FOOT  ce.event_id
   row + 0
  FOOT  ce.parent_event_id
   stat = alterlist(pt_transfer->blob_qual[cnt_blob].action_qual,cnt_action), pt_transfer->blob_qual[
   cnt_blob].action_cnt = cnt_action, stat = alterlist(pt_transfer->blob_qual[cnt_blob].blobs_qual,
    cnt_blobs),
   pt_transfer->blob_qual[cnt_blob].blobs_cnt = cnt_blobs
  FOOT REPORT
   stat = alterlist(pt_transfer->blob_qual,cnt_blob,cnt_blob), pt_transfer->blob_cnt = cnt_blob
  WITH nocounter
 ;end select
 CALL echorecord(pt_transfer)
 DECLARE x = i4
 DECLARE y = i4
 DECLARE blob_contents = vc
 DECLARE compression_cd = f8
 FOR (x = 1 TO pt_transfer->blob_cnt)
   FOR (y = 1 TO pt_transfer->blob_qual[x].blobs_cnt)
     IF ((pt_transfer->blob_qual[x].blob_set_name IN ("Cardiovascular", "Cardiovascular (new)",
     "CARDIOVASCULAR TEST")))
      CALL echo(pt_transfer->blob_qual[x].blob_set_name)
      IF ((pt_transfer->blob_qual[x].blobs_qual[y].event_title_text != "Addendum by*"))
       CALL echo(pt_transfer->blob_qual[x].blob_event_cd)
       CALL echo(pt_transfer->blob_qual[x].blob_date)
      ENDIF
      IF (size(pt_transfer->blob_qual[x].blobs_qual[y].blob_contents) > 0)
       SET blob_contents = pt_transfer->blob_qual[x].blobs_qual[y].blob_contents
       SET compression_cd = pt_transfer->blob_qual[x].blobs_qual[y].comp_cd
       SET blob_type = "report"
       CALL echo("&&&&&&&&&&&&&&BLOB CONTENTS&&&&&&&&&&&&&&&&&&&&&&")
       CALL echo(blob_contents)
       CALL echo(build("compression:",compression_cd))
       SET blobnortf = fillstring(65536," ")
       SET blobout2 = fillstring(65536," ")
       SET blob_return_len = 0
       SET bsize = 0
       CALL uar_ocf_uncompress(blob_contents,size(blob_contents),blobout2,size(blobout2),
        blob_return_len)
       CALL echo("&&&&&&&&&&&&&BLOB AFTER UNCOMPRESS&&&&&&&&&&&&&&&&&&&")
       CALL echo(blobout2)
       SET blobout2 = replace(blobout2,"ocf_blob","",0)
       CALL echo("UARRTF2CALL")
       CALL uar_rtf2(blobout2,size(blobout2),blobout2,size(blobout2),bsize,
        0)
       CALL echo("&&&&&&&&&&&&BLOB AFTER UAR_RTF2 CALL&&&&&&&&&&&&&&&&&&&&")
       CALL echo(
        "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^BLOBNORTF:"
        )
       CALL echo(blobout2)
       CALL echo(
        "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^BLOBNORTF:"
        )
      ENDIF
     ENDIF
   ENDFOR
 ENDFOR
END GO
