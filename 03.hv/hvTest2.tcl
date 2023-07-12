# hyperview tcl代码


set t 1
hwi  OpenStack
	hwi GetSessionHandle sess$t 
	sess$t GetProjectHandle prj$t
	prj$t GetPageHandle pg$t [prj$t GetActivePage]
	pg$t GetWindowHandle win$t [pg$t GetActiveWindow]
	win$t GetClientHandle cln$t 
	cln$t GetModelHandle mdl$t [cln$t GetActiveModel]
	set setid  [ mdl$t AddSelectionSet element ]
	mdl$t GetSelectionSetHandle elem$t $setid 
	elem$t Add "contour > 200 "
	mdl$t GetQueryCtrlHandle qry$t 
	qry$t SetQuery "element.id,contour.value"
	qry$t SetSelectionSet $setid
	qry$t WriteData "result1.csv"
	mdl$t RemoveSelectionSet $setid 
hwi CloseStack





hwi OpenStack
	hwi GetSessionHandle session_handle
	session_handle GetProjectHandle project_handle
	project_handle GetPageHandle page_handle [project_handle GetActivePage]
	page_handle GetWindowHandle window_handle [page_handle GetActiveWindow]
	window_handle GetClientHandle client_handle
	client_handle GetModelHandle model_handle [client_handle GetActiveModel]

	model_handle GetSelectionSetHandle selection_set_handle [model_handle AddSelectionSet elem]

	selection_set_handle Clear
	selection_set_handle Add "idlist 17425 17532 17529 17535 16022 14354 14379 15925 14381 17536 17424 16882"
	puts "\nNum: [selection_set_handle GetSize]\nType: [selection_set_handle GetType]s"

hwi CloseStack



# ===============

hwi OpenStack
hwi GetSessionHandle session_handle
session_handle GetProjectHandle project_handle
project_handle GetPageHandle page_handle [project_handle GetActivePage]
page_handle GetWindowHandle window_handle [page_handle GetActiveWindow]
window_handle GetClientHandle client_handle
client_handle GetModelHandle model_handle [client_handle GetActiveModel]

model_handle GetSelectionSetHandle selection_set_handle [model_handle AddSelectionSet node]
selection_set_handle SetLabel "OurNodeSelectionSet"
puts "Possible list selections: [selection_set_handle GetSelectByList]"

selection_set_handle Clear
selection_set_handle Add all
puts "Add all : [selection_set_handle GetSize] [selection_set_handle GetType]s"

#add node with a particular ID
selection_set_handle Clear
selection_set_handle Add "id 1"
#if your model has different pools use the following command 
#and replace poolName with your pool name
#set poolName "MyPoolName"; selection_set_handle Add "$poolName id 1"
puts "Add id 1 : [selection_set_handle GetSize] [selection_set_handle GetType]s"

#add nodes in the ID range of 1 to 100
selection_set_handle Clear
selection_set_handle Add "id 1-100"

#add nodes in the ID range of 101 to 200 and 205 to 300 from poolName
set poolName "MyPoolName";
selection_set_handle Add "$poolname idlist 101-200, 205-300"

puts "Add id 1-100 : [selection_set_handle GetSize] [selection_set_handle GetType]s"

#add all nodes in the specified component-ID range (1-100)
#add assembly uses the same syntax as add component
selection_set_handle Clear
selection_set_handle Add "component 1-100"
puts "Add component 1-100 : [selection_set_handle GetSize] [selection_set_handle GetType]s"

#add all nodes on the specified component, 
#replace compName by your component name
set compName component1
selection_set_handle Clear
selection_set_handle Add "component == $compName"
puts "Add nodes on component $compName : [selection_set_handle GetSize] [selection_set_handle GetType]s"

#add all nodes with a contour value above 0.0 
selection_set_handle Clear
selection_set_handle Add "contour > 0.0"
puts "Add contour value above 0 : [selection_set_handle GetSize] [selection_set_handle GetType]s"

#add entities from another selectionset of a given poolName
selection_set_handle Clear

model_handle GetSelectionSetHandle selection_set_handle2 [model_handle AddSelectionSet node]; selection_set_handle2 Add "id 1-100"

selection_set_handle Add "<poolName> selectionset == [selection_set_handle2 GetID] "
#if <poolName> is not specified, then the selection will be done from the User_set pool as default

puts "Add another selection set : [selection_set_handle GetSize] [selection_set_handle GetType]s"
selection_set_handle2 ReleaseHandle

#add all nodes inside a defined sphere
selection_set_handle Clear
set x 247.5; set y 327.1; set z 574.5; set radius 1.2
selection_set_handle Add "sphere $x $y $z $radius"
puts "Add nodes in defined shpere : [selection_set_handle GetSize] [selection_set_handle GetType]s"

#add all nodes adjacent to the current selection
selection_set_handle Clear
selection_set_handle Add "id 1 "
puts "Add node with id 1 : [selection_set_handle GetSize] [selection_set_handle GetType]s"
selection_set_handle Add "adjacent"
puts "Add all adjacent nodes : [selection_set_handle GetSize] [selection_set_handle GetType]s"

#add all nodes attached to the current selection
selection_set_handle Clear
selection_set_handle Add "id 1 "
puts "Add node with id 1 : [selection_set_handle GetSize] [selection_set_handle GetType]s"
selection_set_handle Add "attached"
puts "Add all attached nodes : [selection_set_handle GetSize] [selection_set_handle GetType]s"


#add all nodes attached to elements of the defined dimension
#examples for dimension: 1(beams,bars), 2(shells),3(solids), 0(mass elements)
selection_set_handle Clear
selection_set_handle Add "dimension 2"
puts "Add nodes attached to 2D elements : [selection_set_handle GetSize] [selection_set_handle GetType]s"

#to find the top 10 or bottom 10 entities from the contour plot
selection_set_handle Clear
selection_set_handle Add "contour top 10"
selection_set_handle Add "contour bottom 10"

#to find entities with contour values greater than or less than certain values
selection_set_handle Add "contour > 50"
selection_set_handle Add "contour < 0.5"

#to find entity with maximum and minimum contour value from the given entity set under poolName
set poolName "MyPoolName";
selection_set_handle Add "$poolname contour maxofset <set_id>"
selection_set_handle Add "$poolname contour minofset <set_id>"

# Add entities intersecting a plane whose normal is X-axis and the base point is -642, 23, -339 with a tolerance value of 1.0
selection_set_handle Add "plane 1.0 x -642 23 -339"

# Select entities by face
# This command assumes there is atleast one entity already existing in the set
selection_set_handle Add “face”


# Reverse rule is not a part of Add
# You simply call Reverse API on the set handle
selection_set_handle Reverse

hwi CloseStack