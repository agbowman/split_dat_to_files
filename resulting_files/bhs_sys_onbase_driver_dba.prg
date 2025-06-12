CREATE PROGRAM bhs_sys_onbase_driver:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 DECLARE staticsourcedir = vc WITH protect, noconstant(" ")
 DECLARE htmlsourcedir = vc WITH protect, noconstant(" ")
 SET staticsourcedir = "\\Certification\ciscustomcode$\Development\mPages\onBase"
 SET htmlsourcedir = "bhscust:"
 CALL echo(build("StaticSourceDir: ",staticsourcedir))
 CALL echo(build("HTMLSourceDir: ",htmlsourcedir))
 RECORD getrequest(
   1 module_dir = vc
   1 module_name = vc
   1 basblob = i2
 )
 RECORD getreply(
   1 info_line[*]
     2 new_line = vc
   1 data_blob = gvc
   1 data_blob_size = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET getrequest->module_dir = htmlsourcedir
 SET getrequest->module_name = "onbase.html"
 SET getrequest->basblob = 1
 EXECUTE eks_get_source  WITH replace(request,getrequest), replace(reply,getreply)
 SET getreply->data_blob = replace(getreply->data_blob,"$SOURCE_DIR$",staticsourcedir,0)
 RECORD putrequest(
   1 source_dir = vc
   1 source_filename = vc
   1 nbrlines = i4
   1 line[*]
     2 linedata = vc
   1 overflowpage[*]
     2 ofr_qual[*]
       3 ofr_line = vc
   1 isblob = c1
   1 document_size = i4
   1 document = gvc
 )
 SET putrequest->source_dir =  $OUTDEV
 SET putrequest->isblob = "1"
 SET putrequest->document = getreply->data_blob
 SET putrequest->document_size = size(putrequest->document)
 EXECUTE eks_put_source  WITH replace(request,putrequest), replace(reply,putreply)
#exit_script
END GO
