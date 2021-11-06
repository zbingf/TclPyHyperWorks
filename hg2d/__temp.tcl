# D:/github/TclPyHyperWorks/hg2d/abf_file/event_Altoona_7_left.abf
hwc xy curve delete range= "p:all w:all i:all"
hwc xy load file=D:/github/TclPyHyperWorks/hg2d/abf_file/event_Altoona_7_left.abf ydatatype= "Marker Displacement" yrequest= "REQ/10000007 Knuckle-left from Dummy_for_vehBody(Front Left Wheel Center Displacement)" , "REQ/70000087 Dummy_for_vehBody from Knuckle-right(Front Right Wheel Center Displacement)" , "REQ/10000010 Knuckle-right from Dummy_for_vehBody(Rear Right Wheel Center Displacements)" , "REQ/30101011 Coil spring-left on Strut tube (lwr strut)-left(Left Coil Spring Displacement)" , "REQ/30104110 Lwr control arm-right from Vehicle Body(Right jounce bumper disp)" ycomponent= DZ

hwi GetSessionHandle sess;
sess GetClientManagerHandle pm Plot;
pm GetExportCtrlHandle ex
ex SetFormat ¡°RPC¡±
ex SetFilename "D:/github/TclPyHyperWorks/hg2d/abf_file/event_Altoona_7_left_out.rsp"
ex GetFilename
ex Export
hwi CloseStack


# D:/github/TclPyHyperWorks/hg2d/abf_file/event_Altoonal_6.abf
hwc xy curve delete range= "p:all w:all i:all"
hwc xy load file=D:/github/TclPyHyperWorks/hg2d/abf_file/event_Altoonal_6.abf ydatatype= "Marker Displacement" yrequest= "REQ/10000007 Knuckle-left from Dummy_for_vehBody(Front Left Wheel Center Displacement)" , "REQ/70000087 Dummy_for_vehBody from Knuckle-right(Front Right Wheel Center Displacement)" , "REQ/10000010 Knuckle-right from Dummy_for_vehBody(Rear Right Wheel Center Displacements)" , "REQ/30101011 Coil spring-left on Strut tube (lwr strut)-left(Left Coil Spring Displacement)" , "REQ/30104110 Lwr control arm-right from Vehicle Body(Right jounce bumper disp)" ycomponent= DZ

hwi GetSessionHandle sess;
sess GetClientManagerHandle pm Plot;
pm GetExportCtrlHandle ex
ex SetFormat ¡°RPC¡±
ex SetFilename "D:/github/TclPyHyperWorks/hg2d/abf_file/event_Altoonal_6_out.rsp"
ex GetFilename
ex Export
hwi CloseStack


