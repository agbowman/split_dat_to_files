CREATE PROGRAM dd_unit_test_ens_document:dba
 DECLARE today_dt_tm = f8 WITH protect, constant(cnvtdatetime(curdate,curtime3))
 DECLARE end_dt_tm = f8 WITH protect, noconstant(cnvtdatetime("31-DEC-2100 00:00:00.00"))
 DECLARE parent_entity_name = vc WITH protect, constant("DD_DOCUMENT")
 DECLARE parent_entity_id = f8 WITH protect, constant(93939.00)
 DECLARE session_id = f8 WITH protect, constant(getnextseq("scd_act_seq"))
 DECLARE session_user_id = f8 WITH protect, constant(getsessionuserid(null))
 DECLARE session_data_id = f8 WITH protect, constant(getnextseq("scd_act_seq"))
 DECLARE person_id = f8 WITH protect, constant(getpersonid(null))
 DECLARE encounter_id = f8 WITH protect, constant(getencounterid(person_id))
 DECLARE ce_active_doc_eventid = vc WITH protect, noconstant("ACTIVE_DOC_EVENTID")
 DECLARE ce_version = vc WITH protect, constant("CE_VERSION")
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE bskipiniteventrep = i2 WITH protect, noconstant(0)
 DECLARE errmsg = vc
 DECLARE setup(dummyvar=i2) = null
 DECLARE teardown(dummyvar=i2) = null
 DECLARE testinsertdocument(null) = null
 DECLARE testupdatedocument(null) = null
 DECLARE testdeletedocument(null) = null
 DECLARE testemptysessionuserid(null) = null
 DECLARE testinsertexistingdocument(null) = null
 DECLARE testupdatenonexistingdocument(null) = null
 DECLARE testdeletenonexistingdocument(null) = null
 DECLARE testinsertexistingdocumentblob(null) = null
 DECLARE testinsertblobwithinvalidaction(null) = null
 DECLARE testupdatedocumentwithnoeventid(null) = null
 DECLARE testupdatenonexistingdocumentblob(null) = null
 DECLARE testinsertdocumentwithnoeventreply(null) = null
 DECLARE testinsertsessionwithinvalidaction(null) = null
 DECLARE testinsertdocumentwithinvalidaction(null) = null
 DECLARE testinsertdocumentwithhighseveritycd(null) = null
 DECLARE testinsertdocumentwithfailurestatuscd(null) = null
 DECLARE testinsertdocumentwithemptyeventreply(null) = null
 DECLARE testinsertdocumentwithinvalidsessionid(null) = null
 DECLARE testinsertdocumentnoversioninsessiondata(null) = null
 DECLARE testinsertdocumentwithnochangesubstatuscd(null) = null
 DECLARE testsessionversionupdateonsavewithzeroversion(null) = null
 DECLARE testinsertdocumentwithmissingrequestfield(null) = null
 DECLARE testinsertdocumentwithnoeventidandreferencenbr(null) = null
 DECLARE getpersonid(null) = f8
 DECLARE getsessionuserid(null) = f8
 DECLARE populateeventrep(null) = null
 DECLARE getnextseq(seq_name=vc) = f8
 DECLARE getencounterid(personid=f8) = f8
 DECLARE validateversion(text=vc,expectedval=vc) = null
 DECLARE deletfromtabledoesnotexist(null) = null
 DECLARE insertddsessiondata(sessiondataid=f8,sessionid=f8) = null
 DECLARE insertddsession(sessionid=f8,userid=f8,parententityid=f8,parententityname=vc) = null
 FREE RECORD ensdocrequest
 RECORD ensdocrequest(
   1 mdoc_row_reference_nbr = vc
   1 doc_row_reference_nbr = vc
   1 dd_session_id = f8
   1 session_user_id = f8
   1 unlock_ind = i2
   1 long_blob[*]
     2 action_type = c3
     2 long_blob_id = f8
     2 blob_length = i4
     2 long_blob = vgc
     2 parent_entity_id = f8
     2 parent_entity_name = c32
   1 dd_document[*]
     2 action_type = c3
     2 dd_document_id = f8
     2 author_id = f8
     2 beg_effective_dt_tm = dq8
     2 document_grouping_id = f8
     2 document_text_id = f8
     2 encntr_id = f8
     2 end_effective_dt_tm = dq8
     2 event_cd = f8
     2 event_id = f8
     2 person_id = f8
     2 title_txt = vc
     2 service_dt_tm = dq8
     2 service_tz = i4
     2 updt_id = f8
 )
 FREE RECORD event_rep
 RECORD event_rep(
   1 sb[1]
     2 severitycd = f8
     2 statuscd = f8
     2 substatuslist[*]
       3 substatuscd = f8
   1 rb_list[*]
     2 updt_cnt = i4
     2 event_id = f8
     2 reference_nbr = vc
     2 parent_event_id = f8
 )
 FREE RECORD ensdocreply
 RECORD ensdocreply(
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 cps_error
     2 cnt = i4
     2 data[*]
       3 code = i4
       3 severity_level = i4
       3 supp_err_txt = c32
       3 def_msg = vc
       3 row_data
         4 lvl_1_idx = i4
         4 lvl_2_idx = i4
         4 lvl_3_idx = i4
 )
 SUBROUTINE setup(dummyvar)
   SET stat = initrec(ensdocrequest)
   SET stat = initrec(ensdocreply)
   IF (bskipiniteventrep=0)
    SET stat = initrec(event_rep)
   ENDIF
   CALL insertddsession(session_id,session_user_id,parent_entity_id,parent_entity_name)
   CALL insertddsessiondata(session_data_id,session_id)
 END ;Subroutine
 SUBROUTINE testinsertdocument(null)
   CALL populateeventrep(null)
   SET stat = alterlist(ensdocrequest->long_blob,1)
   SET ensdocrequest->long_blob[1].action_type = "ADD"
   SET ensdocrequest->long_blob[1].long_blob_id = getnextseq("long_data_seq")
   SET ensdocrequest->long_blob[1].blob_length = 19
   SET ensdocrequest->long_blob[1].long_blob = "Testing LONB_BLOB_1"
   SET ensdocrequest->long_blob[1].parent_entity_id = parent_entity_id
   SET ensdocrequest->long_blob[1].parent_entity_name = parent_entity_name
   SET stat = alterlist(ensdocrequest->dd_document,1)
   SET ensdocrequest->mdoc_row_reference_nbr = "Hello Adico"
   SET ensdocrequest->doc_row_reference_nbr = "Boujour Adico"
   SET ensdocrequest->dd_document[1].action_type = "ADD"
   SET ensdocrequest->dd_document[1].dd_document_id = getnextseq("scd_act_seq")
   SET ensdocrequest->dd_document[1].author_id = session_user_id
   SET ensdocrequest->dd_document[1].beg_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->dd_document[1].document_grouping_id = parent_entity_id
   SET ensdocrequest->dd_document[1].document_text_id = 1111
   SET ensdocrequest->dd_document[1].encntr_id = encounter_id
   SET ensdocrequest->dd_document[1].end_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->dd_document[1].event_cd = 1111
   SET ensdocrequest->dd_document[1].event_id = 0
   SET ensdocrequest->dd_document[1].person_id = person_id
   SET ensdocrequest->dd_document[1].title_txt = "testInsertDocument_1"
   SET ensdocrequest->dd_document[1].updt_id = 11111
   SET ensdocrequest->dd_document[1].service_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->unlock_ind = 0
   SET ensdocrequest->dd_session_id = session_id
   SET ensdocrequest->session_user_id = session_user_id
   EXECUTE dd_ens_document  WITH replace("REQUEST",ensdocrequest), replace("REPLY",ensdocreply)
   CALL cclutassertvcequal(curref,"testInsertDocument reply->status","S",ensdocreply->status_data.
    status)
   CALL validateversion("testInsertDocument version","1")
 END ;Subroutine
 SUBROUTINE testinsertdocumentwithnoeventidandreferencenbr(null)
   CALL populateeventrep(null)
   SET stat = alterlist(ensdocrequest->long_blob,1)
   SET ensdocrequest->long_blob[1].action_type = "ADD"
   SET ensdocrequest->long_blob[1].long_blob_id = getnextseq("long_data_seq")
   SET ensdocrequest->long_blob[1].blob_length = 19
   SET ensdocrequest->long_blob[1].long_blob = "Testing LONB_BLOB_1"
   SET ensdocrequest->long_blob[1].parent_entity_id = parent_entity_id
   SET ensdocrequest->long_blob[1].parent_entity_name = parent_entity_name
   SET stat = alterlist(ensdocrequest->dd_document,1)
   SET ensdocrequest->mdoc_row_reference_nbr = ""
   SET ensdocrequest->doc_row_reference_nbr = ""
   SET ensdocrequest->dd_document[1].action_type = "ADD"
   SET ensdocrequest->dd_document[1].dd_document_id = getnextseq("scd_act_seq")
   SET ensdocrequest->dd_document[1].author_id = session_user_id
   SET ensdocrequest->dd_document[1].beg_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->dd_document[1].document_grouping_id = parent_entity_id
   SET ensdocrequest->dd_document[1].document_text_id = 1111
   SET ensdocrequest->dd_document[1].encntr_id = encounter_id
   SET ensdocrequest->dd_document[1].end_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->dd_document[1].event_cd = 1111
   SET ensdocrequest->dd_document[1].event_id = 0
   SET ensdocrequest->dd_document[1].person_id = person_id
   SET ensdocrequest->dd_document[1].title_txt = "testInsertDocument_1"
   SET ensdocrequest->dd_document[1].updt_id = 11111
   SET ensdocrequest->dd_document[1].service_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->unlock_ind = 0
   SET ensdocrequest->dd_session_id = session_id
   SET ensdocrequest->session_user_id = session_user_id
   EXECUTE dd_ens_document  WITH replace("REQUEST",ensdocrequest), replace("REPLY",ensdocreply)
   CALL cclutassertvcequal(curref,"testInsertDocumentWithNoEventIdAndReferenceNbr reply->status","F",
    ensdocreply->status_data.status)
   CALL validateversion("testInsertDocumentWithNoEventIdAndReferenceNbr version","0")
 END ;Subroutine
 SUBROUTINE testinsertexistingdocument(null)
   CALL populateeventrep(null)
   SET dd_document_id = getnextseq("scd_act_seq")
   SET long_blob_id = getnextseq("long_data_seq")
   INSERT  FROM dd_document d
    SET d.active_ind = 1, d.author_id = session_user_id, d.beg_effective_dt_tm = cnvtdatetime(
      today_dt_tm),
     d.dd_document_id = dd_document_id, d.document_grouping_id = parent_entity_id, d.document_text_id
      = 1111,
     d.encntr_id = encounter_id, d.end_effective_dt_tm = cnvtdatetime(today_dt_tm), d.event_cd = 1111,
     d.event_id = 1111, d.person_id = person_id, d.service_dt_tm = cnvtdatetime(today_dt_tm),
     d.service_tz = 5, d.title_txt = "testInsertDocument_1", d.updt_applctx = 0,
     d.updt_cnt = 0, d.updt_dt_tm = cnvtdatetime(today_dt_tm), d.updt_id = 1111,
     d.updt_task = 1
    WITH nocounter
   ;end insert
   SET stat = alterlist(ensdocrequest->long_blob,1)
   SET ensdocrequest->long_blob[1].action_type = "ADD"
   SET ensdocrequest->long_blob[1].long_blob_id = long_blob_id
   SET ensdocrequest->long_blob[1].blob_length = 17
   SET ensdocrequest->long_blob[1].long_blob = "Testing LONB_BLOB"
   SET ensdocrequest->long_blob[1].parent_entity_id = parent_entity_id
   SET ensdocrequest->long_blob[1].parent_entity_name = parent_entity_name
   SET stat = alterlist(ensdocrequest->dd_document,1)
   SET ensdocrequest->mdoc_row_reference_nbr = "Hello Adico"
   SET ensdocrequest->doc_row_reference_nbr = "Boujour Adico"
   SET ensdocrequest->dd_document[1].action_type = "ADD"
   SET ensdocrequest->dd_document[1].dd_document_id = dd_document_id
   SET ensdocrequest->dd_document[1].author_id = session_user_id
   SET ensdocrequest->dd_document[1].beg_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->dd_document[1].document_grouping_id = parent_entity_id
   SET ensdocrequest->dd_document[1].document_text_id = 1111
   SET ensdocrequest->dd_document[1].encntr_id = encounter_id
   SET ensdocrequest->dd_document[1].end_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->dd_document[1].event_cd = 1111
   SET ensdocrequest->dd_document[1].event_id = 0
   SET ensdocrequest->dd_document[1].person_id = person_id
   SET ensdocrequest->dd_document[1].title_txt = "testInsertDocument_1"
   SET ensdocrequest->dd_document[1].updt_id = 11111
   SET ensdocrequest->dd_document[1].service_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->unlock_ind = 0
   SET ensdocrequest->dd_session_id = session_id
   SET ensdocrequest->session_user_id = session_user_id
   EXECUTE dd_ens_document  WITH replace("REQUEST",ensdocrequest), replace("REPLY",ensdocreply)
   CALL deletfromtabledoesnotexist(null)
   CALL cclutassertvcequal(curref,"testInsertExistingDocument reply->status","F",ensdocreply->
    status_data.status)
   CALL validateversion("testInsertExistingDocument version","0")
 END ;Subroutine
 SUBROUTINE testinsertexistingdocumentblob(null)
   CALL populateeventrep(null)
   SET dd_document_id = getnextseq("scd_act_seq")
   SET long_blob_id = getnextseq("long_data_seq")
   SET stat = alterlist(ensdocrequest->long_blob,1)
   SET ensdocrequest->long_blob[1].action_type = "ADD"
   SET ensdocrequest->long_blob[1].long_blob_id = long_blob_id
   SET ensdocrequest->long_blob[1].blob_length = 19
   SET ensdocrequest->long_blob[1].long_blob = "Testing LONB_BLOB_1"
   SET ensdocrequest->long_blob[1].parent_entity_id = parent_entity_id
   SET ensdocrequest->long_blob[1].parent_entity_name = parent_entity_name
   SET stat = alterlist(ensdocrequest->dd_document,1)
   SET ensdocrequest->mdoc_row_reference_nbr = "Hello Adico"
   SET ensdocrequest->doc_row_reference_nbr = "Boujour Adico"
   SET ensdocrequest->dd_document[1].action_type = "ADD"
   SET ensdocrequest->dd_document[1].dd_document_id = dd_document_id
   SET ensdocrequest->dd_document[1].author_id = session_user_id
   SET ensdocrequest->dd_document[1].beg_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->dd_document[1].document_grouping_id = parent_entity_id
   SET ensdocrequest->dd_document[1].document_text_id = 1111
   SET ensdocrequest->dd_document[1].encntr_id = encounter_id
   SET ensdocrequest->dd_document[1].end_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->dd_document[1].event_cd = 1111
   SET ensdocrequest->dd_document[1].event_id = 0
   SET ensdocrequest->dd_document[1].person_id = person_id
   SET ensdocrequest->dd_document[1].title_txt = "testInsertDocument_1"
   SET ensdocrequest->dd_document[1].updt_id = 11111
   SET ensdocrequest->dd_document[1].service_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->unlock_ind = 0
   SET ensdocrequest->dd_session_id = session_id
   SET ensdocrequest->session_user_id = session_user_id
   EXECUTE dd_ens_document  WITH replace("REQUEST",ensdocrequest), replace("REPLY",ensdocreply)
   CALL cclutassertvcequal(curref,"testInsertExistingDocumentBlob reply->status","S",ensdocreply->
    status_data.status)
   CALL validateversion("testInsertExistingDocumentBlob version","1")
   SET stat = alterlist(ensdocrequest->long_blob,1)
   SET ensdocrequest->long_blob[1].action_type = "ADD"
   SET ensdocrequest->long_blob[1].long_blob_id = long_blob_id
   SET ensdocrequest->long_blob[1].blob_length = 19
   SET ensdocrequest->long_blob[1].long_blob = "Testing LONB_BLOB_1"
   SET ensdocrequest->long_blob[1].parent_entity_id = parent_entity_id
   SET ensdocrequest->long_blob[1].parent_entity_name = parent_entity_name
   SET ensdocrequest->unlock_ind = 0
   SET ensdocrequest->dd_session_id = session_id
   SET ensdocrequest->session_user_id = session_user_id
   EXECUTE dd_ens_document  WITH replace("REQUEST",ensdocrequest), replace("REPLY",ensdocreply)
   CALL deletfromtabledoesnotexist(null)
   CALL cclutassertvcequal(curref,"testInsertExistingDocumentBlob reply->status","F",ensdocreply->
    status_data.status)
   CALL validateversion("testInsertExistingDocumentBlob version","1")
 END ;Subroutine
 SUBROUTINE testinsertdocumentwithemptyeventreply(null)
   SET dd_document_id = getnextseq("scd_act_seq")
   SET stat = alterlist(ensdocrequest->long_blob,1)
   SET ensdocrequest->long_blob[1].action_type = "ADD"
   SET ensdocrequest->long_blob[1].long_blob_id = getnextseq("long_data_seq")
   SET ensdocrequest->long_blob[1].blob_length = 19
   SET ensdocrequest->long_blob[1].long_blob = "Testing LONB_BLOB"
   SET ensdocrequest->long_blob[1].parent_entity_id = parent_entity_id
   SET ensdocrequest->long_blob[1].parent_entity_name = parent_entity_name
   SET stat = alterlist(ensdocrequest->dd_document,1)
   SET ensdocrequest->mdoc_row_reference_nbr = "Hello Adico"
   SET ensdocrequest->doc_row_reference_nbr = "Boujour Adico"
   SET ensdocrequest->dd_document[1].action_type = "ADD"
   SET ensdocrequest->dd_document[1].dd_document_id = dd_document_id
   SET ensdocrequest->dd_document[1].author_id = session_user_id
   SET ensdocrequest->dd_document[1].beg_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->dd_document[1].document_grouping_id = parent_entity_id
   SET ensdocrequest->dd_document[1].document_text_id = 1111
   SET ensdocrequest->dd_document[1].encntr_id = encounter_id
   SET ensdocrequest->dd_document[1].end_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->dd_document[1].event_cd = 1111
   SET ensdocrequest->dd_document[1].event_id = 0
   SET ensdocrequest->dd_document[1].person_id = person_id
   SET ensdocrequest->dd_document[1].title_txt = "testInsertDocument_1"
   SET ensdocrequest->dd_document[1].updt_id = 11111
   SET ensdocrequest->dd_document[1].service_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->unlock_ind = 0
   SET ensdocrequest->dd_session_id = session_id
   SET ensdocrequest->session_user_id = session_user_id
   EXECUTE dd_ens_document  WITH replace("REQUEST",ensdocrequest), replace("REPLY",ensdocreply)
   CALL cclutassertvcequal(curref,"testInsertDocumentWithEmptyEventReply reply->status","F",
    ensdocreply->status_data.status)
   CALL validateversion("testInsertDocumentWithEmptyEventReply version","0")
 END ;Subroutine
 SUBROUTINE testinsertdocumentwithhighseveritycd(null)
   CALL populateeventrep(null)
   SET stat = alterlist(ensdocrequest->long_blob,1)
   SET ensdocrequest->long_blob[1].action_type = "ADD"
   SET ensdocrequest->long_blob[1].long_blob_id = getnextseq("long_data_seq")
   SET ensdocrequest->long_blob[1].blob_length = 19
   SET ensdocrequest->long_blob[1].long_blob = "Testing LONB_BLOB"
   SET ensdocrequest->long_blob[1].parent_entity_id = parent_entity_id
   SET ensdocrequest->long_blob[1].parent_entity_name = parent_entity_name
   SET stat = alterlist(ensdocrequest->dd_document,1)
   SET ensdocrequest->mdoc_row_reference_nbr = "Hello Adico"
   SET ensdocrequest->doc_row_reference_nbr = "Boujour Adico"
   SET ensdocrequest->dd_document[1].action_type = "ADD"
   SET ensdocrequest->dd_document[1].dd_document_id = getnextseq("scd_act_seq")
   SET ensdocrequest->dd_document[1].author_id = session_user_id
   SET ensdocrequest->dd_document[1].beg_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->dd_document[1].document_grouping_id = parent_entity_id
   SET ensdocrequest->dd_document[1].document_text_id = 1111
   SET ensdocrequest->dd_document[1].encntr_id = encounter_id
   SET ensdocrequest->dd_document[1].end_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->dd_document[1].event_cd = 1111
   SET ensdocrequest->dd_document[1].event_id = 0
   SET ensdocrequest->dd_document[1].person_id = person_id
   SET ensdocrequest->dd_document[1].title_txt = "testInsertDocument_1"
   SET ensdocrequest->dd_document[1].updt_id = 11111
   SET ensdocrequest->dd_document[1].service_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->unlock_ind = 0
   SET ensdocrequest->dd_session_id = session_id
   SET ensdocrequest->session_user_id = session_user_id
   SET event_rep->sb.severitycd = 99
   EXECUTE dd_ens_document  WITH replace("REQUEST",ensdocrequest), replace("REPLY",ensdocreply)
   CALL cclutassertvcequal(curref,"testInsertDocumentWithHighSeverityCd reply->status","F",
    ensdocreply->status_data.status)
   CALL validateversion("testInsertDocumentWithHighSeverityCd version","0")
 END ;Subroutine
 SUBROUTINE testupdatedocument(null)
   CALL populateeventrep(null)
   SET long_blob_id = getnextseq("long_data_seq")
   SET dd_document_id = getnextseq("scd_act_seq")
   SET long_blob_id_historical = getnextseq("long_data_seq")
   SET dd_document_id_historical = getnextseq("scd_act_seq")
   SET stat = alterlist(ensdocrequest->long_blob,1)
   SET ensdocrequest->long_blob[1].action_type = "ADD"
   SET ensdocrequest->long_blob[1].long_blob_id = long_blob_id
   SET ensdocrequest->long_blob[1].blob_length = 17
   SET ensdocrequest->long_blob[1].long_blob = "Testing LONB_BLOB"
   SET ensdocrequest->long_blob[1].parent_entity_id = parent_entity_id
   SET ensdocrequest->long_blob[1].parent_entity_name = parent_entity_name
   SET stat = alterlist(ensdocrequest->dd_document,1)
   SET ensdocrequest->mdoc_row_reference_nbr = "Hello Adico"
   SET ensdocrequest->doc_row_reference_nbr = "Boujour Adico"
   SET ensdocrequest->dd_document[1].action_type = "ADD"
   SET ensdocrequest->dd_document[1].dd_document_id = dd_document_id
   SET ensdocrequest->dd_document[1].author_id = session_user_id
   SET ensdocrequest->dd_document[1].beg_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->dd_document[1].document_grouping_id = parent_entity_id
   SET ensdocrequest->dd_document[1].document_text_id = 1111
   SET ensdocrequest->dd_document[1].encntr_id = encounter_id
   SET ensdocrequest->dd_document[1].end_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->dd_document[1].event_cd = 1111
   SET ensdocrequest->dd_document[1].event_id = 0.0
   SET ensdocrequest->dd_document[1].person_id = person_id
   SET ensdocrequest->dd_document[1].title_txt = "testInsertDocument_1"
   SET ensdocrequest->dd_document[1].updt_id = 11111
   SET ensdocrequest->dd_document[1].service_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->unlock_ind = 0
   SET ensdocrequest->dd_session_id = session_id
   SET ensdocrequest->session_user_id = session_user_id
   EXECUTE dd_ens_document  WITH replace("REQUEST",ensdocrequest), replace("REPLY",ensdocreply)
   CALL validateversion("testUpdateDocument version","1")
   SET stat = alterlist(ensdocrequest->long_blob,1)
   SET ensdocrequest->long_blob[1].action_type = "ADD"
   SET ensdocrequest->long_blob[1].long_blob_id = long_blob_id_historical
   SET ensdocrequest->long_blob[1].blob_length = 17
   SET ensdocrequest->long_blob[1].long_blob = "Testing LONB_BLOB"
   SET ensdocrequest->long_blob[1].parent_entity_id = parent_entity_id
   SET ensdocrequest->long_blob[1].parent_entity_name = parent_entity_name
   SET stat = alterlist(ensdocrequest->dd_document,2)
   SET ensdocrequest->dd_document[1].action_type = "ADD"
   SET ensdocrequest->dd_document[1].dd_document_id = dd_document_id_historical
   SET ensdocrequest->dd_document[1].author_id = session_user_id
   SET ensdocrequest->dd_document[1].beg_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->dd_document[1].document_grouping_id = parent_entity_id
   SET ensdocrequest->dd_document[1].document_text_id = 1111
   SET ensdocrequest->dd_document[1].encntr_id = encounter_id
   SET ensdocrequest->dd_document[1].end_effective_dt_tm = cnvtdatetime(end_dt_tm)
   SET ensdocrequest->dd_document[1].event_cd = 1111
   SET ensdocrequest->dd_document[1].event_id = 12345.0
   SET ensdocrequest->dd_document[1].person_id = person_id
   SET ensdocrequest->dd_document[1].title_txt = "testInsertDocument_1"
   SET ensdocrequest->dd_document[1].updt_id = 11111
   SET ensdocrequest->dd_document[1].service_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->dd_document[2].action_type = "UPD"
   SET ensdocrequest->dd_document[2].dd_document_id = dd_document_id
   SET ensdocrequest->dd_document[2].author_id = session_user_id
   SET ensdocrequest->dd_document[2].beg_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->dd_document[2].document_grouping_id = parent_entity_id
   SET ensdocrequest->dd_document[2].document_text_id = 11113
   SET ensdocrequest->dd_document[2].encntr_id = encounter_id
   SET ensdocrequest->dd_document[2].end_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->dd_document[2].event_cd = 1111
   SET ensdocrequest->dd_document[2].event_id = 12345.0
   SET ensdocrequest->dd_document[2].person_id = person_id
   SET ensdocrequest->dd_document[2].title_txt = "testInsertDocument__UPDATED"
   SET ensdocrequest->dd_document[2].updt_id = 111119
   SET ensdocrequest->dd_document[2].service_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->mdoc_row_reference_nbr = " "
   SET ensdocrequest->doc_row_reference_nbr = " "
   SET ensdocrequest->unlock_ind = 0
   SET ensdocrequest->dd_session_id = session_id
   SET ensdocrequest->session_user_id = session_user_id
   SET event_rep->rb_list[1].updt_cnt = 2
   EXECUTE dd_ens_document  WITH replace("REQUEST",ensdocrequest), replace("REPLY",ensdocreply)
   CALL cclutassertvcequal(curref,"testUpdateDocument reply->status","S",ensdocreply->status_data.
    status)
   CALL validateversion("testUpdateDocument version","2")
 END ;Subroutine
 SUBROUTINE testupdatenonexistingdocumentblob(null)
   CALL populateeventrep(null)
   SET long_blob_id = getnextseq("long_data_seq")
   SET dd_document_id = getnextseq("scd_act_seq")
   SET long_blob_id_historical = getnextseq("long_data_seq")
   SET dd_document_id_historical = getnextseq("scd_act_seq")
   SET stat = alterlist(ensdocrequest->long_blob,1)
   SET ensdocrequest->long_blob[1].action_type = "ADD"
   SET ensdocrequest->long_blob[1].long_blob_id = long_blob_id
   SET ensdocrequest->long_blob[1].blob_length = 17
   SET ensdocrequest->long_blob[1].long_blob = "Testing LONB_BLOB"
   SET ensdocrequest->long_blob[1].parent_entity_id = parent_entity_id
   SET ensdocrequest->long_blob[1].parent_entity_name = parent_entity_name
   SET stat = alterlist(ensdocrequest->dd_document,1)
   SET ensdocrequest->mdoc_row_reference_nbr = "Hello Adico"
   SET ensdocrequest->doc_row_reference_nbr = "Boujour Adico"
   SET ensdocrequest->dd_document[1].action_type = "ADD"
   SET ensdocrequest->dd_document[1].dd_document_id = dd_document_id
   SET ensdocrequest->dd_document[1].author_id = session_user_id
   SET ensdocrequest->dd_document[1].beg_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->dd_document[1].document_grouping_id = parent_entity_id
   SET ensdocrequest->dd_document[1].document_text_id = 1111
   SET ensdocrequest->dd_document[1].encntr_id = encounter_id
   SET ensdocrequest->dd_document[1].end_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->dd_document[1].event_cd = 1111
   SET ensdocrequest->dd_document[1].event_id = 0.0
   SET ensdocrequest->dd_document[1].person_id = person_id
   SET ensdocrequest->dd_document[1].title_txt = "testInsertDocument_1"
   SET ensdocrequest->dd_document[1].updt_id = 11111
   SET ensdocrequest->dd_document[1].service_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->unlock_ind = 0
   SET ensdocrequest->dd_session_id = session_id
   SET ensdocrequest->session_user_id = session_user_id
   EXECUTE dd_ens_document  WITH replace("REQUEST",ensdocrequest), replace("REPLY",ensdocreply)
   CALL validateversion("testUpdateNonExistingDocumentBlob version","1")
   SET stat = alterlist(ensdocrequest->long_blob,1)
   SET ensdocrequest->long_blob[1].action_type = "UPD"
   SET ensdocrequest->long_blob[1].long_blob_id = getnextseq("long_data_seq")
   SET ensdocrequest->long_blob[1].blob_length = 17
   SET ensdocrequest->long_blob[1].long_blob = "Testing LONB_BLOB"
   SET ensdocrequest->long_blob[1].parent_entity_id = parent_entity_id
   SET ensdocrequest->long_blob[1].parent_entity_name = parent_entity_name
   SET stat = alterlist(ensdocrequest->dd_document,2)
   SET ensdocrequest->dd_document[1].action_type = "ADD"
   SET ensdocrequest->dd_document[1].dd_document_id = dd_document_id_historical
   SET ensdocrequest->dd_document[1].author_id = session_user_id
   SET ensdocrequest->dd_document[1].beg_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->dd_document[1].document_grouping_id = parent_entity_id
   SET ensdocrequest->dd_document[1].document_text_id = 1111
   SET ensdocrequest->dd_document[1].encntr_id = encounter_id
   SET ensdocrequest->dd_document[1].end_effective_dt_tm = cnvtdatetime(end_dt_tm)
   SET ensdocrequest->dd_document[1].event_cd = 1111
   SET ensdocrequest->dd_document[1].event_id = 12345.0
   SET ensdocrequest->dd_document[1].person_id = person_id
   SET ensdocrequest->dd_document[1].title_txt = "testInsertDocument_1"
   SET ensdocrequest->dd_document[1].updt_id = 11111
   SET ensdocrequest->dd_document[1].service_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->dd_document[2].action_type = "UPD"
   SET ensdocrequest->dd_document[2].dd_document_id = dd_document_id
   SET ensdocrequest->dd_document[2].author_id = session_user_id
   SET ensdocrequest->dd_document[2].beg_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->dd_document[2].document_grouping_id = parent_entity_id
   SET ensdocrequest->dd_document[2].document_text_id = 11113
   SET ensdocrequest->dd_document[2].encntr_id = encounter_id
   SET ensdocrequest->dd_document[2].end_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->dd_document[2].event_cd = 1111
   SET ensdocrequest->dd_document[2].event_id = 12345.0
   SET ensdocrequest->dd_document[2].person_id = person_id
   SET ensdocrequest->dd_document[2].title_txt = "testInsertDocument__UPDATED"
   SET ensdocrequest->dd_document[2].updt_id = 111119
   SET ensdocrequest->dd_document[2].service_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->mdoc_row_reference_nbr = " "
   SET ensdocrequest->doc_row_reference_nbr = " "
   SET ensdocrequest->unlock_ind = 0
   SET ensdocrequest->dd_session_id = session_id
   SET ensdocrequest->session_user_id = session_user_id
   SET event_rep->rb_list[1].updt_cnt = 2
   EXECUTE dd_ens_document  WITH replace("REQUEST",ensdocrequest), replace("REPLY",ensdocreply)
   CALL cclutassertvcequal(curref,"testUpdateNonExistingDocumentBlob reply->status","F",ensdocreply->
    status_data.status)
   CALL validateversion("testUpdateNonExistingDocumentBlob version","1")
 END ;Subroutine
 SUBROUTINE testupdatenonexistingdocument(null)
   CALL populateeventrep(null)
   SET long_blob_id = getnextseq("long_data_seq")
   SET dd_document_id = getnextseq("scd_act_seq")
   SET long_blob_id_historical = getnextseq("long_data_seq")
   SET dd_document_id_historical = getnextseq("scd_act_seq")
   SET stat = alterlist(ensdocrequest->long_blob,1)
   SET ensdocrequest->long_blob[1].action_type = "ADD"
   SET ensdocrequest->long_blob[1].long_blob_id = long_blob_id
   SET ensdocrequest->long_blob[1].blob_length = 17
   SET ensdocrequest->long_blob[1].long_blob = "Testing LONB_BLOB"
   SET ensdocrequest->long_blob[1].parent_entity_id = parent_entity_id
   SET ensdocrequest->long_blob[1].parent_entity_name = parent_entity_name
   SET stat = alterlist(ensdocrequest->dd_document,1)
   SET ensdocrequest->mdoc_row_reference_nbr = "Hello Adico"
   SET ensdocrequest->doc_row_reference_nbr = "Boujour Adico"
   SET ensdocrequest->dd_document[1].action_type = "ADD"
   SET ensdocrequest->dd_document[1].dd_document_id = dd_document_id
   SET ensdocrequest->dd_document[1].author_id = session_user_id
   SET ensdocrequest->dd_document[1].beg_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->dd_document[1].document_grouping_id = parent_entity_id
   SET ensdocrequest->dd_document[1].document_text_id = 1111
   SET ensdocrequest->dd_document[1].encntr_id = encounter_id
   SET ensdocrequest->dd_document[1].end_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->dd_document[1].event_cd = 1111
   SET ensdocrequest->dd_document[1].event_id = 0.0
   SET ensdocrequest->dd_document[1].person_id = person_id
   SET ensdocrequest->dd_document[1].title_txt = "testInsertDocument_1"
   SET ensdocrequest->dd_document[1].updt_id = 11111
   SET ensdocrequest->dd_document[1].service_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->unlock_ind = 0
   SET ensdocrequest->dd_session_id = session_id
   SET ensdocrequest->session_user_id = session_user_id
   EXECUTE dd_ens_document  WITH replace("REQUEST",ensdocrequest), replace("REPLY",ensdocreply)
   CALL validateversion("testUpdateNonExistingDocument version","1")
   SET stat = alterlist(ensdocrequest->long_blob,1)
   SET ensdocrequest->long_blob[1].action_type = "ADD"
   SET ensdocrequest->long_blob[1].long_blob_id = long_blob_id_historical
   SET ensdocrequest->long_blob[1].blob_length = 17
   SET ensdocrequest->long_blob[1].long_blob = "Testing LONB_BLOB"
   SET ensdocrequest->long_blob[1].parent_entity_id = parent_entity_id
   SET ensdocrequest->long_blob[1].parent_entity_name = parent_entity_name
   SET stat = alterlist(ensdocrequest->dd_document,2)
   SET ensdocrequest->dd_document[1].action_type = "ADD"
   SET ensdocrequest->dd_document[1].dd_document_id = dd_document_id_historical
   SET ensdocrequest->dd_document[1].author_id = session_user_id
   SET ensdocrequest->dd_document[1].beg_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->dd_document[1].document_grouping_id = parent_entity_id
   SET ensdocrequest->dd_document[1].document_text_id = 1111
   SET ensdocrequest->dd_document[1].encntr_id = encounter_id
   SET ensdocrequest->dd_document[1].end_effective_dt_tm = cnvtdatetime(end_dt_tm)
   SET ensdocrequest->dd_document[1].event_cd = 1111
   SET ensdocrequest->dd_document[1].event_id = 12345.0
   SET ensdocrequest->dd_document[1].person_id = person_id
   SET ensdocrequest->dd_document[1].title_txt = "testInsertDocument_1"
   SET ensdocrequest->dd_document[1].updt_id = 11111
   SET ensdocrequest->dd_document[1].service_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->dd_document[2].action_type = "UPD"
   SET ensdocrequest->dd_document[2].dd_document_id = getnextseq("scd_act_seq")
   SET ensdocrequest->dd_document[2].author_id = 11100
   SET ensdocrequest->dd_document[2].beg_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->dd_document[2].document_grouping_id = parent_entity_id
   SET ensdocrequest->dd_document[2].document_text_id = 11113
   SET ensdocrequest->dd_document[2].encntr_id = encounter_id
   SET ensdocrequest->dd_document[2].end_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->dd_document[2].event_cd = 1111
   SET ensdocrequest->dd_document[2].event_id = 12345.0
   SET ensdocrequest->dd_document[2].person_id = person_id
   SET ensdocrequest->dd_document[2].title_txt = "testInsertDocument__UPDATED"
   SET ensdocrequest->dd_document[2].updt_id = 111119
   SET ensdocrequest->dd_document[2].service_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->mdoc_row_reference_nbr = " "
   SET ensdocrequest->doc_row_reference_nbr = " "
   SET ensdocrequest->unlock_ind = 0
   SET ensdocrequest->dd_session_id = session_id
   SET ensdocrequest->session_user_id = session_user_id
   SET event_rep->rb_list[1].updt_cnt = 2
   EXECUTE dd_ens_document  WITH replace("REQUEST",ensdocrequest), replace("REPLY",ensdocreply)
   CALL cclutassertvcequal(curref,"testUpdateNonExistingDocument reply->status","F",ensdocreply->
    status_data.status)
   CALL validateversion("testUpdateNonExistingDocument version","1")
 END ;Subroutine
 SUBROUTINE testupdatedocumentwithnoeventid(null)
   CALL populateeventrep(null)
   SET long_blob_id = getnextseq("long_data_seq")
   SET dd_document_id = getnextseq("scd_act_seq")
   SET long_blob_id_historical = getnextseq("long_data_seq")
   SET dd_document_id_historical = getnextseq("scd_act_seq")
   SET stat = alterlist(ensdocrequest->long_blob,1)
   SET ensdocrequest->long_blob[1].action_type = "ADD"
   SET ensdocrequest->long_blob[1].long_blob_id = long_blob_id
   SET ensdocrequest->long_blob[1].blob_length = 17
   SET ensdocrequest->long_blob[1].long_blob = "Testing LONB_BLOB"
   SET ensdocrequest->long_blob[1].parent_entity_id = parent_entity_id
   SET ensdocrequest->long_blob[1].parent_entity_name = parent_entity_name
   SET stat = alterlist(ensdocrequest->dd_document,1)
   SET ensdocrequest->mdoc_row_reference_nbr = "Hello Adico"
   SET ensdocrequest->doc_row_reference_nbr = "Boujour Adico"
   SET ensdocrequest->dd_document[1].action_type = "ADD"
   SET ensdocrequest->dd_document[1].dd_document_id = dd_document_id
   SET ensdocrequest->dd_document[1].author_id = session_user_id
   SET ensdocrequest->dd_document[1].beg_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->dd_document[1].document_grouping_id = parent_entity_id
   SET ensdocrequest->dd_document[1].document_text_id = 1111
   SET ensdocrequest->dd_document[1].encntr_id = encounter_id
   SET ensdocrequest->dd_document[1].end_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->dd_document[1].event_cd = 1111
   SET ensdocrequest->dd_document[1].event_id = 0.0
   SET ensdocrequest->dd_document[1].person_id = person_id
   SET ensdocrequest->dd_document[1].title_txt = "testInsertDocument_1"
   SET ensdocrequest->dd_document[1].updt_id = 11111
   SET ensdocrequest->dd_document[1].service_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->unlock_ind = 0
   SET ensdocrequest->dd_session_id = session_id
   SET ensdocrequest->session_user_id = session_user_id
   EXECUTE dd_ens_document  WITH replace("REQUEST",ensdocrequest), replace("REPLY",ensdocreply)
   CALL validateversion("testUpdateDocument version","1")
   SET stat = alterlist(ensdocrequest->long_blob,1)
   SET ensdocrequest->long_blob[1].action_type = "ADD"
   SET ensdocrequest->long_blob[1].long_blob_id = long_blob_id_historical
   SET ensdocrequest->long_blob[1].blob_length = 17
   SET ensdocrequest->long_blob[1].long_blob = "Testing LONB_BLOB"
   SET ensdocrequest->long_blob[1].parent_entity_id = parent_entity_id
   SET ensdocrequest->long_blob[1].parent_entity_name = parent_entity_name
   SET stat = alterlist(ensdocrequest->dd_document,2)
   SET ensdocrequest->dd_document[1].action_type = "ADD"
   SET ensdocrequest->dd_document[1].dd_document_id = dd_document_id_historical
   SET ensdocrequest->dd_document[1].author_id = session_user_id
   SET ensdocrequest->dd_document[1].beg_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->dd_document[1].document_grouping_id = parent_entity_id
   SET ensdocrequest->dd_document[1].document_text_id = 1111
   SET ensdocrequest->dd_document[1].encntr_id = encounter_id
   SET ensdocrequest->dd_document[1].end_effective_dt_tm = cnvtdatetime(end_dt_tm)
   SET ensdocrequest->dd_document[1].event_cd = 1111
   SET ensdocrequest->dd_document[1].event_id = 12345.0
   SET ensdocrequest->dd_document[1].person_id = person_id
   SET ensdocrequest->dd_document[1].title_txt = "testInsertDocument_1"
   SET ensdocrequest->dd_document[1].updt_id = 11111
   SET ensdocrequest->dd_document[1].service_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->dd_document[2].action_type = "UPD"
   SET ensdocrequest->dd_document[2].dd_document_id = dd_document_id
   SET ensdocrequest->dd_document[2].author_id = 11100
   SET ensdocrequest->dd_document[2].beg_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->dd_document[2].document_grouping_id = parent_entity_id
   SET ensdocrequest->dd_document[2].document_text_id = 11113
   SET ensdocrequest->dd_document[2].encntr_id = encounter_id
   SET ensdocrequest->dd_document[2].end_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->dd_document[2].event_cd = 1111
   SET ensdocrequest->dd_document[2].event_id = 0.0
   SET ensdocrequest->dd_document[2].person_id = person_id
   SET ensdocrequest->dd_document[2].title_txt = "testInsertDocument__UPDATED"
   SET ensdocrequest->dd_document[2].updt_id = 111119
   SET ensdocrequest->dd_document[2].service_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->mdoc_row_reference_nbr = " "
   SET ensdocrequest->doc_row_reference_nbr = " "
   SET ensdocrequest->unlock_ind = 0
   SET ensdocrequest->dd_session_id = session_id
   SET ensdocrequest->session_user_id = session_user_id
   SET event_rep->rb_list[1].updt_cnt = 2
   EXECUTE dd_ens_document  WITH replace("REQUEST",ensdocrequest), replace("REPLY",ensdocreply)
   CALL cclutassertvcequal(curref,"testUpdateDocument reply->status","F",ensdocreply->status_data.
    status)
   CALL validateversion("testUpdateDocument version","1")
 END ;Subroutine
 SUBROUTINE testdeletedocument(null)
   CALL populateeventrep(null)
   SET long_blob_id = getnextseq("long_data_seq")
   SET dd_document_id = getnextseq("scd_act_seq")
   SET stat = alterlist(ensdocrequest->long_blob,1)
   SET ensdocrequest->long_blob[1].action_type = "ADD"
   SET ensdocrequest->long_blob[1].long_blob_id = long_blob_id
   SET ensdocrequest->long_blob[1].blob_length = 17
   SET ensdocrequest->long_blob[1].long_blob = "Testing LONB_BLOB"
   SET ensdocrequest->long_blob[1].parent_entity_id = parent_entity_id
   SET ensdocrequest->long_blob[1].parent_entity_name = parent_entity_name
   SET stat = alterlist(ensdocrequest->dd_document,1)
   SET ensdocrequest->mdoc_row_reference_nbr = "Hello Adico"
   SET ensdocrequest->doc_row_reference_nbr = "Boujour Adico"
   SET ensdocrequest->dd_document[1].action_type = "ADD"
   SET ensdocrequest->dd_document[1].dd_document_id = dd_document_id
   SET ensdocrequest->dd_document[1].author_id = session_user_id
   SET ensdocrequest->dd_document[1].beg_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->dd_document[1].document_grouping_id = parent_entity_id
   SET ensdocrequest->dd_document[1].document_text_id = 1111
   SET ensdocrequest->dd_document[1].encntr_id = encounter_id
   SET ensdocrequest->dd_document[1].end_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->dd_document[1].event_cd = 1111
   SET ensdocrequest->dd_document[1].event_id = 0
   SET ensdocrequest->dd_document[1].person_id = person_id
   SET ensdocrequest->dd_document[1].title_txt = "testInsertDocument_1"
   SET ensdocrequest->dd_document[1].updt_id = 11111
   SET ensdocrequest->dd_document[1].service_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->unlock_ind = 0
   SET ensdocrequest->dd_session_id = session_id
   SET ensdocrequest->session_user_id = session_user_id
   EXECUTE dd_ens_document  WITH replace("REQUEST",ensdocrequest), replace("REPLY",ensdocreply)
   CALL insertddsession(session_id,session_user_id,parent_entity_id,parent_entity_name)
   CALL insertddsessiondata(session_data_id,session_id)
   SET stat = alterlist(ensdocrequest->long_blob,1)
   SET ensdocrequest->long_blob[1].action_type = "DEL"
   SET ensdocrequest->long_blob[1].long_blob_id = long_blob_id
   SET stat = alterlist(ensdocrequest->dd_document,1)
   SET ensdocrequest->mdoc_row_reference_nbr = "Hello Adico"
   SET ensdocrequest->doc_row_reference_nbr = "Boujour Adico"
   SET ensdocrequest->dd_document[1].action_type = "DEL"
   SET ensdocrequest->dd_document[1].dd_document_id = dd_document_id
   SET ensdocrequest->unlock_ind = 1
   SET ensdocrequest->dd_session_id = session_id
   SET ensdocrequest->session_user_id = session_user_id
   EXECUTE dd_ens_document  WITH replace("REQUEST",ensdocrequest), replace("REPLY",ensdocreply)
   CALL cclutassertvcequal(curref,"testDeleteDocument reply->status","S",ensdocreply->status_data.
    status)
 END ;Subroutine
 SUBROUTINE testdeletenonexistingdocument(null)
   CALL populateeventrep(null)
   SET stat = alterlist(ensdocrequest->long_blob,1)
   SET ensdocrequest->long_blob[1].action_type = "ADD"
   SET ensdocrequest->long_blob[1].long_blob_id = getnextseq("long_data_seq")
   SET ensdocrequest->long_blob[1].blob_length = 17
   SET ensdocrequest->long_blob[1].long_blob = "Testing LONB_BLOB"
   SET ensdocrequest->long_blob[1].parent_entity_id = parent_entity_id
   SET ensdocrequest->long_blob[1].parent_entity_name = parent_entity_name
   SET stat = alterlist(ensdocrequest->dd_document,1)
   SET ensdocrequest->mdoc_row_reference_nbr = "Hello Adico"
   SET ensdocrequest->doc_row_reference_nbr = "Boujour Adico"
   SET ensdocrequest->dd_document[1].action_type = "ADD"
   SET ensdocrequest->dd_document[1].dd_document_id = getnextseq("scd_act_seq")
   SET ensdocrequest->dd_document[1].author_id = session_user_id
   SET ensdocrequest->dd_document[1].beg_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->dd_document[1].document_grouping_id = parent_entity_id
   SET ensdocrequest->dd_document[1].document_text_id = 1111
   SET ensdocrequest->dd_document[1].encntr_id = encounter_id
   SET ensdocrequest->dd_document[1].end_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->dd_document[1].event_cd = 1111
   SET ensdocrequest->dd_document[1].event_id = 0
   SET ensdocrequest->dd_document[1].person_id = person_id
   SET ensdocrequest->dd_document[1].title_txt = "testInsertDocument_1"
   SET ensdocrequest->dd_document[1].updt_id = 11111
   SET ensdocrequest->dd_document[1].service_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->unlock_ind = 0
   SET ensdocrequest->dd_session_id = session_id
   SET ensdocrequest->session_user_id = session_user_id
   EXECUTE dd_ens_document  WITH replace("REQUEST",ensdocrequest), replace("REPLY",ensdocreply)
   CALL insertddsession(session_id,93847.00,parent_entity_id,parent_entity_name)
   CALL insertddsessiondata(session_data_id,session_id)
   SET stat = alterlist(ensdocrequest->long_blob,1)
   SET ensdocrequest->long_blob[1].action_type = "ADD"
   SET ensdocrequest->long_blob[1].long_blob_id = getnextseq("long_data_seq")
   SET ensdocrequest->long_blob[1].blob_length = 17
   SET ensdocrequest->long_blob[1].long_blob = "Testing LONB_BLOB"
   SET ensdocrequest->long_blob[1].parent_entity_id = parent_entity_id
   SET ensdocrequest->long_blob[1].parent_entity_name = parent_entity_name
   SET stat = alterlist(ensdocrequest->dd_document,1)
   SET ensdocrequest->mdoc_row_reference_nbr = "Hello Adico"
   SET ensdocrequest->doc_row_reference_nbr = "Boujour Adico"
   SET ensdocrequest->dd_document[1].action_type = "DEL"
   SET ensdocrequest->dd_document[1].dd_document_id = getnextseq("scd_act_seq")
   SET ensdocrequest->unlock_ind = 1
   SET ensdocrequest->dd_session_id = session_id
   EXECUTE dd_ens_document  WITH replace("REQUEST",ensdocrequest), replace("REPLY",ensdocreply)
   CALL cclutassertvcequal(curref,"testDeleteNonExistingDocument reply->status","F",ensdocreply->
    status_data.status)
 END ;Subroutine
 SUBROUTINE testdeletenonexistingdocumentblob(null)
   CALL populateeventrep(null)
   SET stat = alterlist(ensdocrequest->long_blob,1)
   SET ensdocrequest->long_blob[1].action_type = "ADD"
   SET ensdocrequest->long_blob[1].long_blob_id = getnextseq("long_data_seq")
   SET ensdocrequest->long_blob[1].blob_length = 17
   SET ensdocrequest->long_blob[1].long_blob = "Testing LONB_BLOB"
   SET ensdocrequest->long_blob[1].parent_entity_id = parent_entity_id
   SET ensdocrequest->long_blob[1].parent_entity_name = parent_entity_name
   SET stat = alterlist(ensdocrequest->dd_document,1)
   SET ensdocrequest->mdoc_row_reference_nbr = "Hello Adico"
   SET ensdocrequest->doc_row_reference_nbr = "Boujour Adico"
   SET ensdocrequest->dd_document[1].action_type = "ADD"
   SET ensdocrequest->dd_document[1].dd_document_id = getnextseq("scd_act_seq")
   SET ensdocrequest->dd_document[1].author_id = session_user_id
   SET ensdocrequest->dd_document[1].beg_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->dd_document[1].document_grouping_id = parent_entity_id
   SET ensdocrequest->dd_document[1].document_text_id = 1111
   SET ensdocrequest->dd_document[1].encntr_id = encounter_id
   SET ensdocrequest->dd_document[1].end_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->dd_document[1].event_cd = 1111
   SET ensdocrequest->dd_document[1].event_id = 0
   SET ensdocrequest->dd_document[1].person_id = person_id
   SET ensdocrequest->dd_document[1].title_txt = "testInsertDocument_1"
   SET ensdocrequest->dd_document[1].updt_id = 11111
   SET ensdocrequest->dd_document[1].service_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->unlock_ind = 0
   SET ensdocrequest->dd_session_id = 99939082.00
   SET ensdocrequest->session_user_id = session_user_id
   EXECUTE dd_ens_document  WITH replace("REQUEST",ensdocrequest), replace("REPLY",ensdocreply)
   CALL insertddsession(session_id,93847.00,parent_entity_id,parent_entity_name)
   CALL insertddsessiondata(session_data_id,session_id)
   SET stat = alterlist(ensdocrequest->long_blob,1)
   SET ensdocrequest->long_blob[1].action_type = "DEL"
   SET ensdocrequest->long_blob[1].long_blob_id = getnextseq("long_data_seq")
   SET stat = alterlist(ensdocrequest->dd_document,1)
   SET ensdocrequest->mdoc_row_reference_nbr = "Hello Adico"
   SET ensdocrequest->doc_row_reference_nbr = "Boujour Adico"
   SET ensdocrequest->dd_document[1].action_type = "DEL"
   SET ensdocrequest->dd_document[1].dd_document_id = getnextseq("scd_act_seq")
   SET ensdocrequest->unlock_ind = 1
   SET ensdocrequest->dd_session_id = session_id
   EXECUTE dd_ens_document  WITH replace("REQUEST",ensdocrequest), replace("REPLY",ensdocreply)
   CALL cclutassertvcequal(curref,"testDeleteNonExistingDocument reply->status","F",ensdocreply->
    status_data.status)
 END ;Subroutine
 SUBROUTINE testinsertblobwithinvalidaction(null)
   CALL populateeventrep(null)
   SET long_blob_id = getnextseq("long_data_seq")
   SET dd_document_id = getnextseq("scd_act_seq")
   SET stat = alterlist(ensdocrequest->long_blob,1)
   SET ensdocrequest->long_blob[1].action_type = "  "
   SET ensdocrequest->long_blob[1].long_blob_id = long_blob_id
   SET ensdocrequest->long_blob[1].blob_length = 17
   SET ensdocrequest->long_blob[1].long_blob = "Testing LONB_BLOB"
   SET ensdocrequest->long_blob[1].parent_entity_id = parent_entity_id
   SET ensdocrequest->long_blob[1].parent_entity_name = parent_entity_name
   SET stat = alterlist(ensdocrequest->dd_document,1)
   SET ensdocrequest->mdoc_row_reference_nbr = "Hello Adico"
   SET ensdocrequest->doc_row_reference_nbr = "Boujour Adico"
   SET ensdocrequest->dd_document[1].action_type = "ADD"
   SET ensdocrequest->dd_document[1].dd_document_id = dd_document_id
   SET ensdocrequest->dd_document[1].author_id = session_user_id
   SET ensdocrequest->dd_document[1].beg_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->dd_document[1].document_grouping_id = parent_entity_id
   SET ensdocrequest->dd_document[1].document_text_id = 1111
   SET ensdocrequest->dd_document[1].encntr_id = encounter_id
   SET ensdocrequest->dd_document[1].end_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->dd_document[1].event_cd = 1111
   SET ensdocrequest->dd_document[1].event_id = 0
   SET ensdocrequest->dd_document[1].person_id = person_id
   SET ensdocrequest->dd_document[1].title_txt = "testInsertDocument_1"
   SET ensdocrequest->dd_document[1].updt_id = 11111
   SET ensdocrequest->dd_document[1].service_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->unlock_ind = 0
   SET ensdocrequest->dd_session_id = session_id
   SET ensdocrequest->session_user_id = session_user_id
   EXECUTE dd_ens_document  WITH replace("REQUEST",ensdocrequest), replace("REPLY",ensdocreply)
   CALL cclutassertvcequal(curref,"testInsertDocumentWithInvalidAction reply->status","F",ensdocreply
    ->status_data.status)
   CALL validateversion("testInsertBlobWithInvalidAction version","0")
 END ;Subroutine
 SUBROUTINE testinsertdocumentwithinvalidaction(null)
   CALL populateeventrep(null)
   SET long_blob_id = getnextseq("long_data_seq")
   SET dd_document_id = getnextseq("scd_act_seq")
   SET stat = alterlist(ensdocrequest->long_blob,1)
   SET ensdocrequest->long_blob[1].action_type = "ADD"
   SET ensdocrequest->long_blob[1].long_blob_id = long_blob_id
   SET ensdocrequest->long_blob[1].blob_length = 17
   SET ensdocrequest->long_blob[1].long_blob = "Testing LONB_BLOB"
   SET ensdocrequest->long_blob[1].parent_entity_id = parent_entity_id
   SET ensdocrequest->long_blob[1].parent_entity_name = parent_entity_name
   SET stat = alterlist(ensdocrequest->dd_document,1)
   SET ensdocrequest->mdoc_row_reference_nbr = "Hello Adico"
   SET ensdocrequest->doc_row_reference_nbr = "Boujour Adico"
   SET ensdocrequest->dd_document[1].action_type = " "
   SET ensdocrequest->dd_document[1].dd_document_id = dd_document_id
   SET ensdocrequest->dd_document[1].author_id = session_user_id
   SET ensdocrequest->dd_document[1].beg_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->dd_document[1].document_grouping_id = parent_entity_id
   SET ensdocrequest->dd_document[1].document_text_id = 1111
   SET ensdocrequest->dd_document[1].encntr_id = encounter_id
   SET ensdocrequest->dd_document[1].end_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->dd_document[1].event_cd = 1111
   SET ensdocrequest->dd_document[1].event_id = 0
   SET ensdocrequest->dd_document[1].person_id = person_id
   SET ensdocrequest->dd_document[1].title_txt = "testInsertDocument_1"
   SET ensdocrequest->dd_document[1].updt_id = 11111
   SET ensdocrequest->dd_document[1].service_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->unlock_ind = 0
   SET ensdocrequest->dd_session_id = session_id
   SET ensdocrequest->session_user_id = session_user_id
   EXECUTE dd_ens_document  WITH replace("REQUEST",ensdocrequest), replace("REPLY",ensdocreply)
   CALL cclutassertvcequal(curref,"testInsertDocumentWithInvalidAction reply->status","F",ensdocreply
    ->status_data.status)
   CALL validateversion("testInsertDocumentWithInvalidAction version","0")
 END ;Subroutine
 SUBROUTINE testinsertdocumentwithinvalidsessionid(null)
   CALL populateeventrep(null)
   SET long_blob_id = getnextseq("long_data_seq")
   SET dd_document_id = getnextseq("scd_act_seq")
   SET stat = alterlist(ensdocrequest->long_blob,1)
   SET ensdocrequest->long_blob[1].action_type = "ADD"
   SET ensdocrequest->long_blob[1].long_blob_id = long_blob_id
   SET ensdocrequest->long_blob[1].blob_length = 17
   SET ensdocrequest->long_blob[1].long_blob = "Testing LONB_BLOB"
   SET ensdocrequest->long_blob[1].parent_entity_id = parent_entity_id
   SET ensdocrequest->long_blob[1].parent_entity_name = parent_entity_name
   SET stat = alterlist(ensdocrequest->dd_document,1)
   SET ensdocrequest->mdoc_row_reference_nbr = "Hello Adico"
   SET ensdocrequest->doc_row_reference_nbr = "Boujour Adico"
   SET ensdocrequest->dd_document[1].action_type = "ADD"
   SET ensdocrequest->dd_document[1].dd_document_id = dd_document_id
   SET ensdocrequest->dd_document[1].author_id = session_user_id
   SET ensdocrequest->dd_document[1].beg_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->dd_document[1].document_grouping_id = parent_entity_id
   SET ensdocrequest->dd_document[1].document_text_id = 1111
   SET ensdocrequest->dd_document[1].encntr_id = encounter_id
   SET ensdocrequest->dd_document[1].end_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->dd_document[1].event_cd = 1111
   SET ensdocrequest->dd_document[1].event_id = 0
   SET ensdocrequest->dd_document[1].person_id = person_id
   SET ensdocrequest->dd_document[1].title_txt = "testInsertDocument_1"
   SET ensdocrequest->dd_document[1].updt_id = 11111
   SET ensdocrequest->dd_document[1].service_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->unlock_ind = 0
   SET ensdocrequest->dd_session_id = 1111.00
   SET ensdocrequest->session_user_id = session_user_id
   EXECUTE dd_ens_document  WITH replace("REQUEST",ensdocrequest), replace("REPLY",ensdocreply)
   CALL cclutassertvcequal(curref,"testInsertDocumentWithInvalidSessionId status","F",ensdocreply->
    status_data.status)
   CALL validateversion("testInsertDocumentWithInvalidSessionId version","0")
 END ;Subroutine
 SUBROUTINE testinsertdocumentnoversioninsessiondata(null)
   DELETE  FROM dd_session_data
    WHERE dd_session_id=session_id
   ;end delete
   CALL populateeventrep(null)
   SET stat = alterlist(ensdocrequest->long_blob,1)
   SET ensdocrequest->long_blob[1].action_type = "ADD"
   SET ensdocrequest->long_blob[1].long_blob_id = getnextseq("long_data_seq")
   SET ensdocrequest->long_blob[1].blob_length = 19
   SET ensdocrequest->long_blob[1].long_blob = "Testing LONB_BLOB_1"
   SET ensdocrequest->long_blob[1].parent_entity_id = parent_entity_id
   SET ensdocrequest->long_blob[1].parent_entity_name = parent_entity_name
   SET stat = alterlist(ensdocrequest->dd_document,1)
   SET ensdocrequest->mdoc_row_reference_nbr = "Hello Adico"
   SET ensdocrequest->doc_row_reference_nbr = "Boujour Adico"
   SET ensdocrequest->dd_document[1].action_type = "ADD"
   SET ensdocrequest->dd_document[1].dd_document_id = getnextseq("scd_act_seq")
   SET ensdocrequest->dd_document[1].author_id = session_user_id
   SET ensdocrequest->dd_document[1].beg_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->dd_document[1].document_grouping_id = parent_entity_id
   SET ensdocrequest->dd_document[1].document_text_id = 1111
   SET ensdocrequest->dd_document[1].encntr_id = encounter_id
   SET ensdocrequest->dd_document[1].end_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->dd_document[1].event_cd = 1111
   SET ensdocrequest->dd_document[1].event_id = 0
   SET ensdocrequest->dd_document[1].person_id = person_id
   SET ensdocrequest->dd_document[1].title_txt = "testInsertDocument_1"
   SET ensdocrequest->dd_document[1].updt_id = 11111
   SET ensdocrequest->dd_document[1].service_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->unlock_ind = 0
   SET ensdocrequest->dd_session_id = session_id
   SET ensdocrequest->session_user_id = session_user_id
   EXECUTE dd_ens_document  WITH replace("REQUEST",ensdocrequest), replace("REPLY",ensdocreply)
   CALL cclutassertvcequal(curref,"testInsertDocumentNoVersionInSessionData status","F",ensdocreply->
    status_data.status)
   CALL validateversion("testInsertDocumentNoVersionInSessionData version",trim(" "))
 END ;Subroutine
 SUBROUTINE testinsertdocumentwithnochangesubstatuscd(null)
   CALL populateeventrep(null)
   SET long_blob_id = getnextseq("long_data_seq")
   SET dd_document_id = getnextseq("scd_act_seq")
   SET long_blob_id_historical = getnextseq("long_data_seq")
   SET dd_document_id_historical = getnextseq("scd_act_seq")
   SET stat = alterlist(ensdocrequest->long_blob,1)
   SET ensdocrequest->long_blob[1].action_type = "ADD"
   SET ensdocrequest->long_blob[1].long_blob_id = long_blob_id
   SET ensdocrequest->long_blob[1].blob_length = 17
   SET ensdocrequest->long_blob[1].long_blob = "Testing LONB_BLOB"
   SET ensdocrequest->long_blob[1].parent_entity_id = parent_entity_id
   SET ensdocrequest->long_blob[1].parent_entity_name = parent_entity_name
   SET stat = alterlist(ensdocrequest->dd_document,1)
   SET ensdocrequest->mdoc_row_reference_nbr = "Hello Adico"
   SET ensdocrequest->doc_row_reference_nbr = "Boujour Adico"
   SET ensdocrequest->dd_document[1].action_type = "ADD"
   SET ensdocrequest->dd_document[1].dd_document_id = dd_document_id
   SET ensdocrequest->dd_document[1].author_id = session_user_id
   SET ensdocrequest->dd_document[1].beg_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->dd_document[1].document_grouping_id = parent_entity_id
   SET ensdocrequest->dd_document[1].document_text_id = 1111
   SET ensdocrequest->dd_document[1].encntr_id = encounter_id
   SET ensdocrequest->dd_document[1].end_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->dd_document[1].event_cd = 1111
   SET ensdocrequest->dd_document[1].event_id = 0.0
   SET ensdocrequest->dd_document[1].person_id = person_id
   SET ensdocrequest->dd_document[1].title_txt = "testInsertDocument_1"
   SET ensdocrequest->dd_document[1].updt_id = 11111
   SET ensdocrequest->dd_document[1].service_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->unlock_ind = 0
   SET ensdocrequest->dd_session_id = session_id
   SET ensdocrequest->session_user_id = session_user_id
   EXECUTE dd_ens_document  WITH replace("REQUEST",ensdocrequest), replace("REPLY",ensdocreply)
   CALL validateversion("testUpdateDocument version","1")
   SET stat = alterlist(ensdocrequest->long_blob,1)
   SET ensdocrequest->long_blob[1].action_type = "ADD"
   SET ensdocrequest->long_blob[1].long_blob_id = long_blob_id_historical
   SET ensdocrequest->long_blob[1].blob_length = 17
   SET ensdocrequest->long_blob[1].long_blob = "Testing LONB_BLOB"
   SET ensdocrequest->long_blob[1].parent_entity_id = parent_entity_id
   SET ensdocrequest->long_blob[1].parent_entity_name = parent_entity_name
   SET stat = alterlist(ensdocrequest->dd_document,2)
   SET ensdocrequest->dd_document[1].action_type = "ADD"
   SET ensdocrequest->dd_document[1].dd_document_id = dd_document_id_historical
   SET ensdocrequest->dd_document[1].author_id = session_user_id
   SET ensdocrequest->dd_document[1].beg_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->dd_document[1].document_grouping_id = parent_entity_id
   SET ensdocrequest->dd_document[1].document_text_id = 1111
   SET ensdocrequest->dd_document[1].encntr_id = encounter_id
   SET ensdocrequest->dd_document[1].end_effective_dt_tm = cnvtdatetime(end_dt_tm)
   SET ensdocrequest->dd_document[1].event_cd = 1111
   SET ensdocrequest->dd_document[1].event_id = 12345.0
   SET ensdocrequest->dd_document[1].person_id = person_id
   SET ensdocrequest->dd_document[1].title_txt = "testInsertDocument_1"
   SET ensdocrequest->dd_document[1].updt_id = 11111
   SET ensdocrequest->dd_document[1].service_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->dd_document[2].action_type = "UPD"
   SET ensdocrequest->dd_document[2].dd_document_id = dd_document_id
   SET ensdocrequest->dd_document[2].author_id = 11100
   SET ensdocrequest->dd_document[2].beg_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->dd_document[2].document_grouping_id = parent_entity_id
   SET ensdocrequest->dd_document[2].document_text_id = 11113
   SET ensdocrequest->dd_document[2].encntr_id = encounter_id
   SET ensdocrequest->dd_document[2].end_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->dd_document[2].event_cd = 1111
   SET ensdocrequest->dd_document[2].event_id = 12345.0
   SET ensdocrequest->dd_document[2].person_id = person_id
   SET ensdocrequest->dd_document[2].title_txt = "testInsertDocument__UPDATED"
   SET ensdocrequest->dd_document[2].updt_id = 111119
   SET ensdocrequest->dd_document[2].service_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->mdoc_row_reference_nbr = " "
   SET ensdocrequest->doc_row_reference_nbr = " "
   SET ensdocrequest->unlock_ind = 0
   SET ensdocrequest->dd_session_id = session_id
   SET ensdocrequest->session_user_id = session_user_id
   SET event_rep->sb.substatuslist[1].substatuscd = 1
   EXECUTE dd_ens_document  WITH replace("REQUEST",ensdocrequest), replace("REPLY",ensdocreply)
   CALL cclutassertvcequal(curref,"testInsertDocumentWithNoChangeSubStatusCd reply->status","S",
    ensdocreply->status_data.status)
   CALL validateversion("testInsertDocumentWithNoChangeSubStatusCd version","1")
 END ;Subroutine
 SUBROUTINE testinsertdocumentwithfailurestatuscd(null)
   CALL populateeventrep(null)
   SET long_blob_id = getnextseq("long_data_seq")
   SET dd_document_id = getnextseq("scd_act_seq")
   SET long_blob_id_historical = getnextseq("long_data_seq")
   SET dd_document_id_historical = getnextseq("scd_act_seq")
   SET stat = alterlist(ensdocrequest->long_blob,1)
   SET ensdocrequest->long_blob[1].action_type = "ADD"
   SET ensdocrequest->long_blob[1].long_blob_id = long_blob_id
   SET ensdocrequest->long_blob[1].blob_length = 17
   SET ensdocrequest->long_blob[1].long_blob = "Testing LONB_BLOB"
   SET ensdocrequest->long_blob[1].parent_entity_id = parent_entity_id
   SET ensdocrequest->long_blob[1].parent_entity_name = parent_entity_name
   SET stat = alterlist(ensdocrequest->dd_document,1)
   SET ensdocrequest->mdoc_row_reference_nbr = "Hello Adico"
   SET ensdocrequest->doc_row_reference_nbr = "Boujour Adico"
   SET ensdocrequest->dd_document[1].action_type = "ADD"
   SET ensdocrequest->dd_document[1].dd_document_id = dd_document_id
   SET ensdocrequest->dd_document[1].author_id = session_user_id
   SET ensdocrequest->dd_document[1].beg_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->dd_document[1].document_grouping_id = parent_entity_id
   SET ensdocrequest->dd_document[1].document_text_id = 1111
   SET ensdocrequest->dd_document[1].encntr_id = encounter_id
   SET ensdocrequest->dd_document[1].end_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->dd_document[1].event_cd = 1111
   SET ensdocrequest->dd_document[1].event_id = 0.0
   SET ensdocrequest->dd_document[1].person_id = person_id
   SET ensdocrequest->dd_document[1].title_txt = "testInsertDocument_1"
   SET ensdocrequest->dd_document[1].updt_id = 11111
   SET ensdocrequest->dd_document[1].service_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->unlock_ind = 0
   SET ensdocrequest->dd_session_id = session_id
   SET ensdocrequest->session_user_id = session_user_id
   EXECUTE dd_ens_document  WITH replace("REQUEST",ensdocrequest), replace("REPLY",ensdocreply)
   CALL validateversion("testUpdateDocument version","1")
   SET stat = alterlist(ensdocrequest->long_blob,1)
   SET ensdocrequest->long_blob[1].action_type = "ADD"
   SET ensdocrequest->long_blob[1].long_blob_id = long_blob_id_historical
   SET ensdocrequest->long_blob[1].blob_length = 17
   SET ensdocrequest->long_blob[1].long_blob = "Testing LONB_BLOB"
   SET ensdocrequest->long_blob[1].parent_entity_id = parent_entity_id
   SET ensdocrequest->long_blob[1].parent_entity_name = parent_entity_name
   SET stat = alterlist(ensdocrequest->dd_document,2)
   SET ensdocrequest->dd_document[1].action_type = "ADD"
   SET ensdocrequest->dd_document[1].dd_document_id = dd_document_id_historical
   SET ensdocrequest->dd_document[1].author_id = session_user_id
   SET ensdocrequest->dd_document[1].beg_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->dd_document[1].document_grouping_id = parent_entity_id
   SET ensdocrequest->dd_document[1].document_text_id = 1111
   SET ensdocrequest->dd_document[1].encntr_id = encounter_id
   SET ensdocrequest->dd_document[1].end_effective_dt_tm = cnvtdatetime(end_dt_tm)
   SET ensdocrequest->dd_document[1].event_cd = 1111
   SET ensdocrequest->dd_document[1].event_id = 12345.0
   SET ensdocrequest->dd_document[1].person_id = person_id
   SET ensdocrequest->dd_document[1].title_txt = "testInsertDocument_1"
   SET ensdocrequest->dd_document[1].updt_id = 11111
   SET ensdocrequest->dd_document[1].service_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->dd_document[2].action_type = "UPD"
   SET ensdocrequest->dd_document[2].dd_document_id = dd_document_id
   SET ensdocrequest->dd_document[2].author_id = 11100
   SET ensdocrequest->dd_document[2].beg_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->dd_document[2].document_grouping_id = parent_entity_id
   SET ensdocrequest->dd_document[2].document_text_id = 11113
   SET ensdocrequest->dd_document[2].encntr_id = encounter_id
   SET ensdocrequest->dd_document[2].end_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->dd_document[2].event_cd = 1111
   SET ensdocrequest->dd_document[2].event_id = 12345.0
   SET ensdocrequest->dd_document[2].person_id = person_id
   SET ensdocrequest->dd_document[2].title_txt = "testInsertDocument__UPDATED"
   SET ensdocrequest->dd_document[2].updt_id = 111119
   SET ensdocrequest->dd_document[2].service_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->mdoc_row_reference_nbr = " "
   SET ensdocrequest->doc_row_reference_nbr = " "
   SET ensdocrequest->unlock_ind = 0
   SET ensdocrequest->dd_session_id = session_id
   SET ensdocrequest->session_user_id = session_user_id
   SET event_rep->sb.statuscd = 3.0
   EXECUTE dd_ens_document  WITH replace("REQUEST",ensdocrequest), replace("REPLY",ensdocreply)
   CALL cclutassertvcequal(curref,"testInsertDocumentWithFailureStatusCd reply->status","F",
    ensdocreply->status_data.status)
   CALL validateversion("testInsertDocumentWithFailureStatusCd version","1")
 END ;Subroutine
 SUBROUTINE testinsertdocumentwithmissingrequestfield(null)
   FREE RECORD ensdocrequest2
   RECORD ensdocrequest2(
     1 reference_nbr = vc
     1 doc_row_reference_nbr = vc
     1 dd_session_id = f8
     1 session_user_id = f8
     1 unlock_ind = i2
     1 long_blob[*]
       2 action_type = c3
       2 long_blob_id = f8
       2 blob_length = i4
       2 long_blob = vgc
       2 parent_entity_id = f8
       2 parent_entity_name = c32
     1 dd_document[*]
       2 action_type = c3
       2 dd_document_id = f8
       2 author_id = f8
       2 beg_effective_dt_tm = dq8
       2 document_grouping_id = f8
       2 document_text_id = f8
       2 encntr_id = f8
       2 end_effective_dt_tm = dq8
       2 event_cd = f8
       2 event_id = f8
       2 person_id = f8
       2 title_txt = vc
       2 service_dt_tm = dq8
       2 service_tz = i4
       2 updt_id = f8
   )
   SET stat = initrec(ensdocrequest2)
   CALL populateeventrep(null)
   SET stat = alterlist(ensdocrequest2->long_blob,1)
   SET ensdocrequest2->long_blob[1].action_type = "ADD"
   SET ensdocrequest2->long_blob[1].long_blob_id = getnextseq("long_data_seq")
   SET ensdocrequest2->long_blob[1].blob_length = 19
   SET ensdocrequest2->long_blob[1].long_blob = "Testing LONB_BLOB_1"
   SET ensdocrequest2->long_blob[1].parent_entity_id = parent_entity_id
   SET ensdocrequest2->long_blob[1].parent_entity_name = parent_entity_name
   SET stat = alterlist(ensdocrequest->dd_document,1)
   SET ensdocrequest2->reference_nbr = "Hello Adico"
   SET ensdocrequest2->doc_row_reference_nbr = "Boujour Adico"
   SET ensdocrequest2->dd_document[1].action_type = "ADD"
   SET ensdocrequest2->dd_document[1].dd_document_id = getnextseq("scd_act_seq")
   SET ensdocrequest2->dd_document[1].author_id = session_user_id
   SET ensdocrequest2->dd_document[1].beg_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest2->dd_document[1].document_grouping_id = parent_entity_id
   SET ensdocrequest2->dd_document[1].document_text_id = 1111
   SET ensdocrequest2->dd_document[1].encntr_id = encounter_id
   SET ensdocrequest2->dd_document[1].end_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest2->dd_document[1].event_cd = 1111
   SET ensdocrequest2->dd_document[1].event_id = 0
   SET ensdocrequest2->dd_document[1].person_id = person_id
   SET ensdocrequest2->dd_document[1].title_txt = "testInsertDocument_1"
   SET ensdocrequest2->dd_document[1].updt_id = 11111
   SET ensdocrequest2->dd_document[1].service_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest2->unlock_ind = 0
   SET ensdocrequest2->dd_session_id = session_id
   SET ensdocrequest2->session_user_id = session_user_id
   EXECUTE dd_ens_document  WITH replace("REQUEST",ensdocrequest2), replace("REPLY",ensdocreply)
   CALL cclutassertvcequal(curref,"testInsertDocument reply->status","F",ensdocreply->status_data.
    status)
   FREE RECORD ensdocrequest2
   RECORD ensdocrequest2(
     1 mdoc_row_reference_nbr = vc
     1 reference_nbr = vc
     1 dd_session_id = f8
     1 session_user_id = f8
     1 unlock_ind = i2
     1 long_blob[*]
       2 action_type = c3
       2 long_blob_id = f8
       2 blob_length = i4
       2 long_blob = vgc
       2 parent_entity_id = f8
       2 parent_entity_name = c32
     1 dd_document[*]
       2 action_type = c3
       2 dd_document_id = f8
       2 author_id = f8
       2 beg_effective_dt_tm = dq8
       2 document_grouping_id = f8
       2 document_text_id = f8
       2 encntr_id = f8
       2 end_effective_dt_tm = dq8
       2 event_cd = f8
       2 event_id = f8
       2 person_id = f8
       2 title_txt = vc
       2 service_dt_tm = dq8
       2 service_tz = i4
       2 updt_id = f8
   )
   SET stat = initrec(ensdocrequest2)
   CALL populateeventrep(null)
   SET stat = alterlist(ensdocrequest2->long_blob,1)
   SET ensdocrequest2->long_blob[1].action_type = "ADD"
   SET ensdocrequest2->long_blob[1].long_blob_id = getnextseq("long_data_seq")
   SET ensdocrequest2->long_blob[1].blob_length = 19
   SET ensdocrequest2->long_blob[1].long_blob = "Testing LONB_BLOB_1"
   SET ensdocrequest2->long_blob[1].parent_entity_id = parent_entity_id
   SET ensdocrequest2->long_blob[1].parent_entity_name = parent_entity_name
   SET stat = alterlist(ensdocrequest->dd_document,1)
   SET ensdocrequest2->mdoc_row_reference_nbr = "Hello Adico"
   SET ensdocrequest2->reference_nbr = "Boujour Adico"
   SET ensdocrequest2->dd_document[1].action_type = "ADD"
   SET ensdocrequest2->dd_document[1].dd_document_id = getnextseq("scd_act_seq")
   SET ensdocrequest2->dd_document[1].author_id = session_user_id
   SET ensdocrequest2->dd_document[1].beg_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest2->dd_document[1].document_grouping_id = parent_entity_id
   SET ensdocrequest2->dd_document[1].document_text_id = 1111
   SET ensdocrequest2->dd_document[1].encntr_id = encounter_id
   SET ensdocrequest2->dd_document[1].end_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest2->dd_document[1].event_cd = 1111
   SET ensdocrequest2->dd_document[1].event_id = 0
   SET ensdocrequest2->dd_document[1].person_id = person_id
   SET ensdocrequest2->dd_document[1].title_txt = "testInsertDocument_1"
   SET ensdocrequest2->dd_document[1].updt_id = 11111
   SET ensdocrequest2->dd_document[1].service_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest2->unlock_ind = 0
   SET ensdocrequest2->dd_session_id = session_id
   SET ensdocrequest2->session_user_id = session_user_id
   EXECUTE dd_ens_document  WITH replace("REQUEST",ensdocrequest2), replace("REPLY",ensdocreply)
   CALL cclutassertvcequal(curref,"testInsertDocument reply->status","F",ensdocreply->status_data.
    status)
   FREE RECORD ensdocrequest2
 END ;Subroutine
 SUBROUTINE testinsertdocumentwithnoeventreply(null)
   FREE RECORD event_rep
   SET stat = alterlist(ensdocrequest->long_blob,1)
   SET ensdocrequest->long_blob[1].action_type = "ADD"
   SET ensdocrequest->long_blob[1].long_blob_id = getnextseq("long_data_seq")
   SET ensdocrequest->long_blob[1].blob_length = 17
   SET ensdocrequest->long_blob[1].long_blob = "Testing LONB_BLOB"
   SET ensdocrequest->long_blob[1].parent_entity_id = parent_entity_id
   SET ensdocrequest->long_blob[1].parent_entity_name = parent_entity_name
   SET stat = alterlist(ensdocrequest->dd_document,1)
   SET ensdocrequest->mdoc_row_reference_nbr = "Hello Adico"
   SET ensdocrequest->doc_row_reference_nbr = "Boujour Adico"
   SET ensdocrequest->dd_document[1].action_type = "ADD"
   SET ensdocrequest->dd_document[1].dd_document_id = getnextseq("scd_act_seq")
   SET ensdocrequest->dd_document[1].author_id = session_user_id
   SET ensdocrequest->dd_document[1].beg_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->dd_document[1].document_grouping_id = parent_entity_id
   SET ensdocrequest->dd_document[1].document_text_id = 1111
   SET ensdocrequest->dd_document[1].encntr_id = encounter_id
   SET ensdocrequest->dd_document[1].end_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->dd_document[1].event_cd = 1111
   SET ensdocrequest->dd_document[1].event_id = 0
   SET ensdocrequest->dd_document[1].person_id = person_id
   SET ensdocrequest->dd_document[1].title_txt = "testInsertDocument_1"
   SET ensdocrequest->dd_document[1].updt_id = 11111
   SET ensdocrequest->dd_document[1].service_dt_tm = cnvtdatetime(curdate,curtime3)
   SET ensdocrequest->unlock_ind = 0
   SET ensdocrequest->dd_session_id = session_id
   SET ensdocrequest->session_user_id = session_user_id
   EXECUTE dd_ens_document  WITH replace("REQUEST",ensdocrequest), replace("REPLY",ensdocreply)
   CALL deletfromtabledoesnotexist(null)
   CALL cclutassertvcequal(curref,"testInsertDocumentWithNoEventReply reply->status","F",ensdocreply
    ->status_data.status)
   CALL validateversion("testInsertDocumentWithNoEventReply version","0")
   SET bskipiniteventrep = 1
 END ;Subroutine
 SUBROUTINE teardown(dummyvar)
   ROLLBACK
 END ;Subroutine
 SUBROUTINE insertddsession(dsessionid,duserid,dparententityid,sparententityname)
  DELETE  FROM dd_session
   WHERE dd_session_id=dsessionid
  ;end delete
  INSERT  FROM dd_session d
   SET d.dd_session_id = dsessionid, d.session_dt_tm = cnvtdatetime(curdate,curtime3), d
    .session_user_id = duserid,
    d.parent_entity_id = dparententityid, d.parent_entity_name = sparententityname, d.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    d.updt_id = dsessionid, d.updt_task = dsessionid, d.updt_applctx = dsessionid,
    d.updt_cnt = 0
   WITH nocounter
  ;end insert
 END ;Subroutine
 SUBROUTINE insertddsessiondata(dsessiondataid,dsessionid)
  DELETE  FROM dd_session_data
   WHERE dd_session_id=dsessionid
  ;end delete
  INSERT  FROM dd_session_data d
   SET d.dd_session_data_id = dsessiondataid, d.dd_session_id = dsessionid, d.session_data_key =
    ce_version,
    d.content_instance_ident = " ", d.short_txt = "0", d.long_blob_id = 0.0,
    d.updt_cnt = 0, d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_id = dsessiondataid,
    d.updt_task = dsessiondataid, d.updt_applctx = dsessiondataid
   WITH nocounter
  ;end insert
 END ;Subroutine
 SUBROUTINE populateeventrep(null)
   SET event_rep->sb.severitycd = 2
   SET event_rep->sb.statuscd = 0.0
   SET stat = alterlist(event_rep->sb.substatuslist,1)
   SET event_rep->sb.substatuslist[1].substatuscd = 0.0
   SET stat = alterlist(event_rep->rb_list,2)
   SET event_rep->rb_list[1].updt_cnt = 1
   SET event_rep->rb_list[1].event_id = 12345.0
   SET event_rep->rb_list[1].parent_event_id = 12345.0
   SET event_rep->rb_list[1].reference_nbr = "Hello Adico"
   SET event_rep->rb_list[2].updt_cnt = 1
   SET event_rep->rb_list[2].event_id = 23456.0
   SET event_rep->rb_list[2].parent_event_id = 12345.0
   SET event_rep->rb_list[2].reference_nbr = "Boujour Adico"
 END ;Subroutine
 SUBROUTINE getnextseq(seq_name)
   SET next_seq = 0.0
   SET seq_string = concat("seq(",seq_name,", nextval)")
   SELECT INTO "nl:"
    number = parser(seq_string)"##################;rp0"
    FROM dual
    DETAIL
     next_seq = cnvtreal(number)
    WITH format, counter
   ;end select
   IF (next_seq <= 0.0)
    SET failure = "T"
    CALL cps_add_error(cps_inval_data,cps_script_fail,"Unable to generate next sequence",
     cps_inval_data_msg,0,
     0,0)
   ENDIF
   RETURN(next_seq)
 END ;Subroutine
 SUBROUTINE deletfromtabledoesnotexist(null)
  DELETE  FROM table_does_not_exist
   WHERE column_does_not_exist > 0
  ;end delete
  SET stat = error(errmsg,1)
 END ;Subroutine
 SUBROUTINE validateversion(stext,sexpectedval)
   DECLARE curversion = vc WITH noconstant("")
   SELECT INTO "nl"
    sd.short_txt
    FROM dd_session_data sd
    WHERE sd.dd_session_id=session_id
     AND sd.session_data_key=ce_version
    DETAIL
     curversion = sd.short_txt
    WITH nocounter
   ;end select
   CALL cclutassertvcequal(curref,stext,sexpectedval,trim(curversion))
 END ;Subroutine
 SUBROUTINE getsessionuserid(null)
   DECLARE dsessionuserid = f8 WITH noconstant(0.0)
   SELECT INTO "nl"
    dsessionuserid = p.person_id
    FROM prsnl p
    WHERE p.name_last_key="RIBEIRO"
     AND p.name_first_key="ADILSON"
    WITH nocounter
   ;end select
   RETURN(dsessionuserid)
 END ;Subroutine
 SUBROUTINE getpersonid(null)
   DECLARE dpersonid = f8 WITH noconstant(0.0)
   SELECT INTO "nl"
    dpersonid = p.person_id
    FROM person p
    WHERE p.name_last_key="CVNET"
     AND p.name_first_key="GOLIATH"
     AND p.name_middle_key="M"
    WITH nocounter
   ;end select
   RETURN(dpersonid)
 END ;Subroutine
 SUBROUTINE getencounterid(dpersonid)
   DECLARE dencounterid = f8 WITH noconstant(0.0)
   SELECT INTO "nl"
    dencounterid = e.encntr_id
    FROM encounter e
    WHERE e.person_id=dpersonid
    WITH nocounter
   ;end select
   RETURN(dencounterid)
 END ;Subroutine
 SUBROUTINE cclutassertvcequal(a,b,c,d)
  DECLARE x = i2 WITH protect, noconstant(0)
  RETURN(x)
 END ;Subroutine
 SUBROUTINE cclutassertf8equal(a,b,c,d)
  DECLARE x = i2 WITH protect, noconstant(0)
  RETURN(x)
 END ;Subroutine
 SUBROUTINE cclutasserti4equal(a,b,c,d)
  DECLARE x = i2 WITH protect, noconstant(0)
  RETURN(x)
 END ;Subroutine
 CALL setup(0)
 CALL testinsertcontribution(null)
 CALL teardown(0)
 CALL setup(0)
 CALL testinsertcontributionmissingdocrefnbr(null)
 CALL teardown(0)
 CALL setup(0)
 CALL testinsertcontributionmissingmdocrefnbr(null)
 CALL teardown(0)
 CALL setup(0)
 CALL testinsertexistingcontribution(null)
 CALL teardown(0)
 CALL setup(0)
 CALL testinsertcontributionwithemptyeventreply(null)
 CALL teardown(0)
 CALL setup(0)
 CALL testinsertcontributionwithhighseveritycd(null)
 CALL teardown(0)
 CALL setup(0)
 CALL testupdatesessiondatawithinvalidaction(null)
 CALL teardown(0)
 CALL setup(0)
 CALL testinsertcontributionwithinvalidaction(null)
 CALL teardown(0)
 CALL setup(0)
 CALL testinsertcontributionwithfailurestatuscd(null)
 CALL teardown(0)
 CALL setup(0)
 CALL testupdatecontribution(null)
 CALL teardown(0)
 CALL setup(0)
 CALL testupdatenonexistingcontribution(null)
 CALL teardown(0)
 CALL setup(0)
 CALL testupdatecontributionignoresdoceventid(null)
 CALL teardown(0)
 CALL setup(0)
 CALL testupdatecontributionignoresmdoceventid(null)
 CALL teardown(0)
 CALL setup(0)
 CALL testupdatecontributionignorespersonid(null)
 CALL teardown(0)
 CALL setup(0)
 CALL testupdatecontributionchangeauthorid(null)
 CALL teardown(0)
 CALL setup(0)
 CALL testupdatecontributionchangeencntrid(null)
 CALL teardown(0)
 CALL setup(0)
 CALL testupdatecontributionwithnochangesubstatuscd(null)
 CALL teardown(0)
 CALL setup(0)
 CALL testupdatecontributionwithskipsubstatuscd(null)
 CALL teardown(0)
 CALL setup(0)
 CALL testupdatecontributionwithfailurestatuscd(null)
 CALL teardown(0)
 CALL setup(0)
 CALL testdeletecontribution(null)
 CALL teardown(0)
 CALL setup(0)
 CALL testinsertcontributionunlock(null)
 CALL teardown(0)
 CALL setup(0)
 CALL testupdatecontributionunlock(null)
 CALL teardown(0)
 CALL echorecord(ensdocreply)
 CALL setup(0)
 CALL testinsertcontributionwithinvalidsessionid(null)
 CALL teardown(0)
 CALL setup(0)
 CALL testupdatecontributionwithinvalidsessionid(null)
 CALL teardown(0)
 CALL setup(0)
 CALL testinsertcontributionnoversioninsessiondata(null)
 CALL teardown(0)
 CALL setup(0)
 CALL testupdatecontributionnoversioninsessiondata(null)
 CALL teardown(0)
 CALL setup(0)
 CALL testupdatesessiondatawithinvalidaction(null)
 CALL teardown(0)
 CALL setup(0)
 CALL testinsertcontributionwithmissingrequestfield(null)
 CALL teardown(0)
 CALL setup(0)
 CALL testinsertcontributionwithnoeventreply(null)
 CALL teardown(0)
 CALL setup(0)
 CALL testnewaddendumupdatebody(null)
 CALL teardown(0)
 CALL echorecord(ensdocreply)
 CALL setup(0)
 CALL testupdateaddendumupdatebody(null)
 CALL teardown(0)
END GO
