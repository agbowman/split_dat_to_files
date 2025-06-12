CREATE PROGRAM bhs_mmf_store_image
 DECLARE uar_dmsm_getcontenttypelist() = i4 WITH image_axp = "dmsmanagement", image_aix =
 "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
 uar = "DMSM_GetContentTypeList", persist
 DECLARE uar_dmsm_getcontenttype(p1=vc(ref)) = i4 WITH image_axp = "dmsmanagement", image_aix =
 "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
 uar = "DMSM_GetContentType", persist
 DECLARE uar_dmsm_getcontenttypeprops(p1=i4(value)) = i4 WITH image_axp = "dmsmanagement", image_aix
  = "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
 uar = "DMSM_GetContentTypeProps", persist
 DECLARE uar_dmsm_createclassifiedmedia(p1=i4(value)) = i4 WITH image_axp = "dmsmanagement",
 image_aix = "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
 uar = "DMSM_CreateClassifiedMedia", persist
 DECLARE uar_dmsm_getclassifiedmedia(p1=vc(ref),p2=i4(value)) = i4 WITH image_axp = "dmsmanagement",
 image_aix = "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
 uar = "DMSM_GetClassifiedMedia", persist
 DECLARE uar_dmsm_getmediacontent(p1=i4(value),p2=i4(value),p3=i4(value)) = i4 WITH image_axp =
 "dmsmanagement", image_aix = "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
 uar = "DMSM_GetMediaContent", persist
 DECLARE uar_dmsm_getmediaprops(p1=i4(value)) = i4 WITH image_axp = "dmsmanagement", image_aix =
 "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
 uar = "DMSM_GetMediaProps", persist
 DECLARE uar_dmsm_setmediacontent(p1=i4(value),p2=i4(value),p3=vc(ref),p4=i4(value)) = i4 WITH
 image_axp = "dmsmanagement", image_aix = "libdmsmanagement.a(libdmsmanagement.o)", image_win =
 "dmsmanagement",
 uar = "DMSM_SetMediaContent", persist
 DECLARE uar_dmsm_storeclassifiedmedia(p1=i4(value)) = i4 WITH image_axp = "dmsmanagement", image_aix
  = "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
 uar = "DMSM_StoreClassifiedMedia", persist
 DECLARE uar_dmsm_addmediatrackingevent(p1=i4(value),p2=vc(ref),p3=i4(value),p4=i4(value)) = i4 WITH
 image_axp = "dmsmanagement", image_aix = "libdmsmanagement.a(libdmsmanagement.o)", image_win =
 "dmsmanagement",
 uar = "DMSM_AddMediaTrackingEvent", persist
 DECLARE uar_dmsm_getinternalmediacontent(p1=i4(value)) = i4 WITH image_axp = "dmsmanagement",
 image_aix = "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
 uar = "DMSM_GetInternalMediaContent", persist
 DECLARE uar_dmsm_setmediaprops(p1=i4(value),p2=i4(value)) = i4 WITH image_axp = "dmsmanagement",
 image_aix = "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
 uar = "DMSM_SetMediaProps", persist
 DECLARE uar_dmsm_getmediabyxref(p1=i4(value)) = i4 WITH image_axp = "dmsmanagement", image_aix =
 "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
 uar = "DMSM_GetMediaByXRef", persist
 DECLARE uar_dmsm_setmediaxref(p1=i4(value),p2=i4(value)) = i4 WITH image_axp = "dmsmanagement",
 image_aix = "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
 uar = "DMSM_SetMediaXRef", persist
 DECLARE uar_dmsm_getmediaxref(p1=i4(value)) = i4 WITH image_axp = "dmsmanagement", image_aix =
 "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
 uar = "DMSM_GetMediaXRef", persist
 DECLARE uar_dmsm_setmetadata(p1=i4(value),p2=i4(value),p3=i4(value)) = i4 WITH image_axp =
 "dmsmanagement", image_aix = "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
 uar = "DMSM_SetMetadata", persist
 DECLARE uar_dmsm_getmetadataschema(p1=i4(value),p2=i4(value),p3=i4(value)) = i4 WITH image_axp =
 "dmsmanagement", image_aix = "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
 uar = "DMSM_GetMetadataSchema", persist
 DECLARE uar_dmsm_getmediaevents(p1=i4(value)) = i4 WITH image_axp = "dmsmanagement", image_aix =
 "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
 uar = "DMSM_GetMediaEvents", persist
 DECLARE uar_dmsm_getmediacodes(p1=i4(value)) = i4 WITH image_axp = "dmsmanagement", image_aix =
 "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
 uar = "DMSM_GetMediaCodes", persist
 DECLARE uar_dmsm_getclassifiedmedialist(p1=i4(value)) = i4 WITH image_axp = "dmsmanagement",
 image_aix = "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
 uar = "DMSM_GetClassifiedMediaList", persist
 DECLARE uar_srv_getpropcount(p1=i4(value),p2=i4(ref)) = i4 WITH image_axp = "srvcore", image_aix =
 "libsrvcore.a(libsrvcore.o)", image_win = "srvcore",
 uar = "SRV_GetPropCount", persist
 DECLARE uar_srv_getprophandle(p1=i4(value),p2=vc(ref),p3=i4(ref)) = i4 WITH image_axp = "srvcore",
 image_aix = "libsrvcore.a(libsrvcore.o)", image_win = "srvcore",
 uar = "SRV_GetPropHandle", persist
 DECLARE uar_srv_getpropstring(p1=i4(value),p2=vc(ref),p3=vc(ref),p4=i4(ref)) = i4 WITH image_axp =
 "srvcore", image_aix = "libsrvcore.a(libsrvcore.o)", image_win = "srvcore",
 uar = "SRV_GetPropString", persist
 DECLARE uar_srv_getpropint(p1=i4(value),p2=vc(ref),p3=i4(ref)) = i4 WITH image_axp = "srvcore",
 image_aix = "libsrvcore.a(libsrvcore.o)", image_win = "srvcore",
 uar = "SRV_GetPropInt", persist
 DECLARE uar_srv_creatememorybuffer(p1=i4(value),p2=vc(ref),p3=i4(value),p4=i4(value),p5=i4(value),
  p6=vc(ref)) = i4 WITH image_axp = "srvcore", image_aix = "libsrvcore.a(libsrvcore.o)", image_win =
 "srvcore",
 uar = "SRV_CreateMemoryBuffer", persist
 DECLARE uar_srv_getmemorybuffer(p1=i4(value),p2=vc(ref),p3=i4(value),p4=i4(value)) = i4 WITH
 image_axp = "srvcore", image_aix = "libsrvcore.a(libsrvcore.o)", image_win = "srvcore",
 uar = "SRV_GetMemoryBuffer", persist
 DECLARE uar_srv_getmemorybuffersize(p1=i4(value),p2=i4(ref)) = i4 WITH image_axp = "srvcore",
 image_aix = "libsrvcore.a(libsrvcore.o)", image_win = "srvcore",
 uar = "SRV_GetMemoryBufferSize", persist
 DECLARE uar_srv_createfilebuffer(p1=i4(value),p2=vc(ref)) = i4 WITH image_axp = "srvcore", image_aix
  = "libsrvcore.a(libsrvcore.o)", image_win = "srvcore",
 uar = "SRV_CreateFileBuffer", persist
 DECLARE uar_srv_writebuffer(p1=i4(value),p2=vc(ref),p3=i4(value),p4=i4(ref)) = i4 WITH image_axp =
 "srvcore", image_aix = "libsrvcore.a(libsrvcore.o)", image_win = "srvcore",
 uar = "SRV_WriteBuffer", persist
 DECLARE uar_srv_readbuffer(p1=i4(value),p2=vc(ref),p3=i4(value),p4=i4(ref)) = i4 WITH image_axp =
 "srvcore", image_aix = "libsrvcore.a(libsrvcore.o)", image_win = "srvcore",
 uar = "SRV_ReadBuffer", persist
 DECLARE uar_srv_setbufferpos(p1=i4(value),p2=i4(value),p3=i4(value),p4=i4(ref)) = i4 WITH image_axp
  = "srvcore", image_aix = "libsrvcore.a(libsrvcore.o)", image_win = "srvcore",
 uar = "SRV_SetBufferPos", persist
 DECLARE uar_srv_getbufferpos(p1=i4(value),p2=i4(ref)) = i4 WITH image_axp = "srvcore", image_aix =
 "libsrvcore.a(libsrvcore.o)", image_win = "srvcore",
 uar = "SRV_GetBufferPos", persist
 FREE SET uar_srv_closehandle
 DECLARE uar_srv_closehandle(p1=i4(value)) = i4 WITH image_axp = "srvcore", image_aix =
 "libsrvcore.a(libsrvcore.o)", image_win = "srvcore",
 uar = "SRV_CloseHandle", persist
 FREE SET uar_srv_createproplist
 DECLARE uar_srv_createproplist() = i4 WITH image_axp = "srvcore", image_aix =
 "libsrvcore.a(libsrvcore.o)", uar = "SRV_CreatePropList",
 persist
 FREE SET uar_srv_setpropstring
 DECLARE uar_srv_setpropstring(p1=i4(value),p2=vc(ref),p3=vc(ref)) = i4 WITH image_axp = "srvcore",
 image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_SetPropString",
 persist
 FREE SET uar_srv_setpropreal
 DECLARE uar_srv_setpropreal(p1=i4(value),p2=vc(ref),p3=f8(value)) = i4 WITH image_axp = "srvcore",
 image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_SetPropReal",
 persist
 FREE SET uar_srv_setpropint
 DECLARE uar_srv_setpropint(p1=i4(value),p2=vc(ref),p3=i4(value)) = i4 WITH image_axp = "srvcore",
 image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_SetPropInt",
 persist
 FREE SET uar_srv_setprophandle
 DECLARE uar_srv_setprophandle(p1=i4(value),p2=vc(ref),p3=i4(value),p4=i4(value)) = i4 WITH image_axp
  = "srvcore", image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_SetPropHandle",
 persist
 DECLARE bhs_add_ref(i_parent_name=vc,i_parent_id=f8) = i2
 IF (validate(bhs_request->content_type,"-1")="-1")
  FREE RECORD bhs_request
  RECORD bhs_request(
    1 person_id = f8
    1 file_name = vc
    1 content_type = vc
    1 name = vc
    1 path = vc
  ) WITH protect
  SET bhs_request->person_id = 18756781.0
  SET bhs_request->file_name = "test_image1.jpg"
  SET bhs_request->content_type = "CCD"
  SET bhs_request->name = "TEST_IMAGE"
  SET bhs_request->path = concat(trim(logical("ccluserdir"),3),"/")
 ENDIF
 IF (validate(bhs_reply->blob_handle,"-1")="-1")
  FREE RECORD bhs_reply
  RECORD bhs_reply(
    1 blob_handle = vc
  ) WITH protect
 ENDIF
 DECLARE bhs_file_buffer = i4 WITH protect, noconstant(0)
 DECLARE bhs_file_path = vc WITH protect, noconstant(" ")
 DECLARE bhs_content_type = i4 WITH protect, noconstant(0)
 DECLARE bhs_media_handle = i4 WITH protect, noconstant(0)
 DECLARE bhs_media_props = i4 WITH protect, noconstant(0)
 DECLARE bhs_cref_props = i4 WITH protect, noconstant(0)
 DECLARE bhs_temp_ret = i4 WITH protect, noconstant(0)
 DECLARE bhs_blob_handle = c200 WITH protect, noconstant(" ")
 SET bhs_content_type = uar_dmsm_getcontenttype(nullterm(bhs_request->content_type))
 IF (bhs_content_type=0)
  CALL echo(concat("invalid image content type specified - ",bhs_request->content_type))
  GO TO exit_script
 ENDIF
 SET bhs_file_path = concat(trim(bhs_request->path),bhs_request->file_name)
 SET bhs_file_buffer = uar_srv_createfilebuffer(1,nullterm(bhs_file_path))
 IF (bhs_file_buffer=0)
  CALL echo(concat("Error getting image file handle  - ",bhs_request->file_name))
  GO TO exit_script
 ENDIF
 SET bhs_media_handle = uar_dmsm_createclassifiedmedia(bhs_content_type)
 IF (bhs_media_handle=0)
  CALL echo(concat("Error obtaining media handle for content type ",cnvtstring(bhs_content_type)))
  GO TO exit_script
 ENDIF
 SET bhs_media_props = uar_dmsm_getmediaprops(bhs_media_handle)
 IF (bhs_media_props=0)
  CALL echo(concat("Error obtaining media properties for media handle ",cnvtstring(bhs_media_handle))
   )
  GO TO exit_script
 ENDIF
 SET bhs_temp_ret = uar_srv_setpropstring(bhs_media_props,"name",nullterm(bhs_request->name))
 IF (bhs_temp_ret=0)
  CALL echo(concat("Error setting name property for media handle ",cnvtstring(bhs_media_handle)))
  GO TO exit_script
 ENDIF
 SET bhs_temp_ret = uar_dmsm_setmediaprops(bhs_media_handle,bhs_media_props)
 IF (bhs_temp_ret=0)
  CALL bhs_msg(concat("Error saving name property for media handle ",cnvtstring(bhs_media_handle)))
  GO TO exit_script
 ENDIF
 SET bhs_temp_ret = uar_dmsm_setmediacontent(bhs_media_handle,bhs_file_buffer,"image/jpeg",0)
 IF (bhs_temp_ret=0)
  CALL echo(concat("Error setting file_type and file_buffer properties for media handle ",cnvtstring(
     bhs_media_handle)),dm_err->logfile,dm_err->err_ind)
  GO TO exit_script
 ENDIF
 SET bhs_temp_ret = uar_dmsm_storeclassifiedmedia(bhs_media_handle)
 IF (bhs_temp_ret=0)
  CALL echo(concat("Error saving media for media handle ",cnvtstring(bhs_media_handle)))
  GO TO exit_script
 ENDIF
 SET bhs_media_props = uar_dmsm_getmediaprops(bhs_media_handle)
 IF (bhs_media_props=0)
  CALL echo(concat("Error obtaining media properties for media handle ",cnvtstring(bhs_media_handle))
   )
  GO TO exit_script
 ENDIF
 SET bhs_temp_ret = uar_srv_getpropstring(bhs_media_props,"uid",bhs_blob_handle,200)
 IF (bhs_temp_ret=0)
  CALL echo("Error obtaining blob handle ")
  GO TO exit_script
 ENDIF
 CALL echo(concat("blob handle: ",bhs_blob_handle))
 IF (trim(bhs_blob_handle) > " ")
  SET bhs_reply->blob_handle = bhs_blob_handle
 ELSE
  CALL echo("Invalid blob handle obtained")
  GO TO exit_script
 ENDIF
 SET bhs_cref_props = uar_srv_createproplist()
 IF (bhs_cref_props=0)
  CALL echo("Error creating property list ")
  GO TO exit_script
 ENDIF
 SET bhs_temp_ret = bhs_add_ref("PERSON",bhs_request->person_id)
 IF (bhs_temp_ret=0)
  CALL echo("Error creating reference to person for current media")
  GO TO exit_script
 ENDIF
 SET bhs_temp_ret = uar_dmsm_setmediaxref(bhs_media_handle,bhs_cref_props)
 IF (bhs_temp_ret=0)
  CALL echo("Error storing reference to person for current media")
  GO TO exit_script
 ENDIF
 GO TO exit_script
 SUBROUTINE bhs_add_ref(i_parent_name,i_parent_id)
   DECLARE lsubproplist = i4 WITH protect, noconstant(0)
   DECLARE s_ret = i2 WITH protect, noconstant(0)
   SET s_ret = 0
   IF (i_parent_id > 0)
    SET lsubproplist = uar_srv_createproplist()
    IF (lsubproplist != 0)
     IF (uar_srv_setpropstring(lsubproplist,"entityName",nullterm(i_parent_name))
      AND uar_srv_setpropreal(lsubproplist,"entityId",i_parent_id)
      AND uar_srv_setpropint(lsubproplist,"transaction",1))
      IF (uar_srv_setprophandle(bhs_cref_props,"0",lsubproplist,1))
       SET s_ret = 1
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   RETURN(s_ret)
 END ;Subroutine
#exit_script
 CALL echorecord(bhs_request)
 CALL echorecord(bhs_reply)
 IF (bhs_cref_props != 0)
  SET bhs_temp_ret = uar_srv_closehandle(bhs_cref_props)
 ENDIF
 IF (bhs_media_props != 0)
  SET bhs_temp_ret = uar_srv_closehandle(bhs_media_props)
 ENDIF
 IF (bhs_media_handle != 0)
  SET bhs_temp_ret = uar_srv_closehandle(bhs_media_handle)
 ENDIF
 IF (bhs_content_type != 0)
  SET bhs_temp_ret = uar_srv_closehandle(bhs_content_type)
 ENDIF
 IF (bhs_file_buffer != 0)
  SET bhs_temp_ret = uar_srv_closehandle(bhs_file_buffer)
 ENDIF
END GO
