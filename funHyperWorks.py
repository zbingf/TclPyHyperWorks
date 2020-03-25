import sys
import numpy
import itertools,math
def removeDup(inputData):
	'''
		去重复
	'''
	list1=[]
	str1=''
	listData=inputData.split(' ')
	for temp in listData:
		if temp not in list1:
			list1.append(temp)
			str1=str1+' '+temp
	str1=str1[1:]
	return str1
def dis_2Point(n1,n2,arrLoc):
	# 两点间距
	arrX,arrY,arrZ=arrLoc[0],arrLoc[1],arrLoc[2]
	disTemp=((arrX[n1]-arrX[n2])**2+(arrY[n1]-arrY[n2])**2+(arrZ[n1]-arrZ[n2])**2)**0.5
	return disTemp
def diff_2Point(n1,n2,arrLoc):
	# 矢量 n2 → n1
	arrX,arrY,arrZ=arrLoc[0],arrLoc[1],arrLoc[2]
	return [arrX[n1]-arrX[n2],arrY[n1]-arrY[n2],arrZ[n1]-arrZ[n2]]
def dis_pointToLine(n1,n2,n3,arrLoc):
	# 点到直线距离
	d12=dis_2Point(n1,n2,arrLoc)
	d13=dis_2Point(n1,n3,arrLoc)
	d23=dis_2Point(n2,n3,arrLoc)
	p=(d12+d13+d23)/2
	s=(p*(p-d12)*(p-d13)*(p-d23))**0.5
	h=s*2/d23
	return round(h*100)/100
def fun_face3Point(n1,n2,n3,arrLoc):
	# 3点确定面
	# 
	xList,yList,zList=arrLoc[0].tolist(),arrLoc[1].tolist(),arrLoc[2].tolist()
	n1x,n1y,n1z=xList[n1],yList[n1],zList[n1]
	n2x,n2y,n2z=xList[n2],yList[n2],zList[n2]
	n3x,n3y,n3z=xList[n3],yList[n3],zList[n3]
	x1,y1,z1=diff_2Point(n1,n2,arrLoc)
	x2,y2,z2=diff_2Point(n1,n3,arrLoc)
	A=numpy.linalg.det(numpy.array([[y1,z1],[y2,z2]]))
	B=numpy.linalg.det(numpy.array([[z1,x1],[z2,x2]]))
	C=numpy.linalg.det(numpy.array([[x1,y1],[x2,y2]]))
	D=-numpy.linalg.det(numpy.array([[n1x,n1y,n1z],[x1,y1,z1],[x2,y2,z2]]))
	return A,B,C,D
def v_face3Point(n1,n2,n3,arrLoc):
	# 3点确定 法向量
	xList,yList,zList=arrLoc[0].tolist(),arrLoc[1].tolist(),arrLoc[2].tolist()
	n1x,n1y,n1z=xList[n1],yList[n1],zList[n1]
	n2x,n2y,n2z=xList[n2],yList[n2],zList[n2]
	n3x,n3y,n3z=xList[n3],yList[n3],zList[n3]
	x=(n2y-n1y)*(n3z-n1z)-(n3y-n1y)*(n2z-n1z)
	y=(n2z-n1z)*(n3x-n1x)-(n3z-n1z)*(n2x-n1x)
	z=(n2x-n1x)*(n3y-n1y)-(n3x-n1x)*(n2y-n1y)
	return x,y,z
def dis_pointToFace(n,n1,n2,n3,arrLoc):
	# 点到面距离
	xList,yList,zList=arrLoc[0].tolist(),arrLoc[1].tolist(),arrLoc[2].tolist()
	nx,ny,nz=xList[n],yList[n],zList[n]
	A,B,C,D=fun_face3Point(n1,n2,n3,arrLoc)
	lower=((A**2+B**2+C**2)**0.5)
	upper=abs(nx*A+ny*B+nz*C+D)
	if lower==0:
		return 1e4
	dis=upper/lower
	return round(dis*100)/100

def v_paraller(vPlane1,vPlane2,tolerance):
	# 向量平行 判定

	vPlane1=[round(vPlane1[0]*10)/10,round(vPlane1[1]*10)/10,round(vPlane1[2]*10)/10]
	vPlane2=[round(vPlane2[0]*10)/10,round(vPlane2[1]*10)/10,round(vPlane2[2]*10)/10]
	d1=abs(vPlane1[0]*vPlane2[0]+vPlane1[1]*vPlane2[1]+vPlane1[2]*vPlane2[2])
	d2=(((vPlane1[0]**2+vPlane1[1]**2+vPlane1[2]**2)**0.5)*((vPlane2[0]**2+vPlane2[1]**2+vPlane2[2]**2)**0.5))
	# print(d1-d2)
	if abs(d1-d2)<tolerance:
		# print(abs(d1-d2))
		return True
	# print(abs(d1-d2))
	return False
def angle_2V(vPlane1,vPlane2):
	# 矢量夹角
	cosTheta=abs(vPlane1[0]*vPlane2[0]+vPlane1[1]*vPlane2[1]+vPlane1[2]*vPlane2[2])/(((vPlane1[0]**2+vPlane1[1]**2+vPlane1[2]**2)**0.5)*((vPlane2[0]**2+vPlane2[1]**2+vPlane2[2]**2)**0.5))
	if cosTheta >1:
		cosTheta=1
	angleTheta=(math.acos(cosTheta))*180/(math.pi)
	return angleTheta
def v_perpendicular(vPlane1,vPlane2,tolerance):
	# 垂直判断
	angleTheta=angle_2V(vPlane1,vPlane2)
	if angleTheta > 90-tolerance:
		return True
	else:
		return False
def dis_C8_2(numList,arrLoc,maxlength):
	# 8 点间距离不超过 maxlength
	if len(numList)!=8:
		return False
	C8_2=itertools.combinations(numList,2)
	list2=[]
	for n1 in C8_2:
		temp=dis_2Point(n1[0],n1[1],arrLoc)
		if temp<maxlength:
			list2.append(temp)
	if len(list2)==28:
		return True
	else:
		return False
# ————————————————————————————————————————————————
class pointJudge:
	# 点判定
	arrX,arrY,arrZ=[],[],[]
	arrLoc=[]
	locDictMin={}
	locDictMax={}
	locDictMinSecond={}
	o1,o2,o3,o4,o5,o6,o7,o8=[],[],[],[],[],[],[],[]
	i1,i2,i3,i4,i5,i6,i7,i8=[],[],[],[],[],[],[],[]
	maxlength=200

	def __init__(self,inputData):
		self.dataCal(inputData)
	@classmethod
	def dataCal(self,inputData):
		log=[]
		list1=inputData.split(' ')
		list2=[]
		for temp in list1:
			list2.append(float(temp))
		lenList1=len(list2)
		xData,yData,zData=[n for n in range(0,lenList1,3)],[n for n in range(1,lenList1,3)],[n for n in range(2,lenList1,3)]

		arr1=numpy.array(list2)
		arrX,arrY,arrZ=arr1[xData],arr1[yData],arr1[zData]
		arrLoc=[arrX,arrY,arrZ]
		maxF=[]
		minF=[]
		minSecondList=[]
		locDictMin={}
		locDictMax={}
		locDictMinSecond={}
		for n in range(0,len(arrX),1):
			dis1=((arrX-arrX[n])**2+(arrY-arrY[n])**2+(arrZ-arrZ[n])**2)**0.5
			dis2=sorted(dis1)
			disList1=dis1.tolist()
			min1,max1=dis2[1],dis2[-1]
			maxF.append(max1)
			minF.append(min1)
			minSecond=disList1.index(dis2[2])
			minSecondList.append(dis2[2])

			# 相邻 最近\最远 点
			locDictMin[n]=disList1.index(min1)
			locDictMax[n]=disList1.index(max1)
			locDictMinSecond[n]=minSecond

		maxFsort=sorted(maxF)
		# #print(maxFsort)
		o1=maxF.index(maxFsort[-1])
		i1=locDictMin[o1]
		o2=locDictMax[o1]
		i2=locDictMin[o2]

		self.minDis=min(minF)
		self.maxDis=maxFsort[-1]
		self.o1,self.o2,self.i1,self.i2=o1,o2,i1,i2
		self.arrLoc=arrLoc
		self.arrX,self.arrY,self.arrZ=arrX,arrY,arrZ
		self.locDictMin=locDictMin
		self.locDictMax=locDictMax
		self.locDictMinSecond=locDictMinSecond
	@classmethod
	def point8plane(self,tolerance=0.01):
		'''
			8点共面计算
		'''
		o1,o2,i1,i2=self.o1,self.o2,self.i1,self.i2
		arrLoc=self.arrLoc
		locDictMin=self.locDictMin
		maxlength=self.maxlength

		set16=set([n for n in range(0,16,1)])
		doublelist=[]
		# print(set16)
		while True:
			list1=list(set16)
			d1=[list1[0],locDictMin[list1[0]]]
			doublelist.append(d1)
			set16=set16-set(d1)
			if len(set16)==0:
				break
		plane=[]
		C8_4=itertools.combinations(doublelist,4)
		#print(doublelist)
		for n in C8_4:
			# print(n)
			in1,in2,in3,in4=n[0][0],n[1][0],n[2][0],n[3][0]
			ou1,ou2,ou3,ou4=n[0][1],n[1][1],n[2][1],n[3][1]
			loclist=[in1,in2,in3,in4,ou1,ou2,ou3,ou4]
			# print([i1,o1,i2,o2,i3,o3,i4,o4])
			if dis_C8_2(loclist,arrLoc,maxlength)==False:
				continue
			if ((o1 in loclist and o2 not in loclist) or (o2 in loclist and o1 not in loclist))==False:
				continue
			# print([i1,o1,i2,o2,i3,o3,i4,o4])
			# print('dis_C8_2')
			ilist=[in1,in2,in3,in4]
			olist=[ou1,ou2,ou3,ou4]
			dlist=[]
			for itemp in ilist:
				dlist.append(dis_pointToFace(itemp,ou2,ou3,ou4,arrLoc))
				dlist.append(dis_pointToFace(itemp,ou1,ou3,ou4,arrLoc))
				dlist.append(dis_pointToFace(itemp,ou2,ou1,ou4,arrLoc))
				dlist.append(dis_pointToFace(itemp,ou2,ou3,ou1,arrLoc))
			for otemp in olist:
				dlist.append(dis_pointToFace(otemp,in2,in3,in4,arrLoc))
				dlist.append(dis_pointToFace(otemp,in1,in3,in4,arrLoc))
				dlist.append(dis_pointToFace(otemp,in2,in1,in4,arrLoc))
				dlist.append(dis_pointToFace(otemp,in2,in3,in1,arrLoc))
			mean1=sum(dlist)/len(dlist)
			if mean1<tolerance:
				plane.append(loclist)
		#print(plane)
		set16=set([n for n in range(0,16,1)])
		if len(plane)==2:
			plane1,plane2=plane[0],plane[1]
			if o1 in plane2:
				plane1,plane2=plane2,plane1
			# print(plane1,plane2,set16)
			if set(plane1)|set(plane2) == set16:
				list1,list2=plane1,plane2
			else:
				return r'{False} {plane 8 point error}'
		elif len(plane)<2:
			return r'{False} {plane too few}'
		elif len(plane)>2:
			return r'{False} {plane too more}'
		# print(plane)
		return plane
	@classmethod
	def plan8PointLoc(self,plane):
		'''
			对已知共面的8点进行排序
			共面8点 排序
		'''
		o1,o2,i1,i2=self.o1,self.o2,self.i1,self.i2
		maxDis=self.maxDis
		arrLoc=self.arrLoc
		locDictMin,locDictMax=self.locDictMin,self.locDictMax

		list1,list2=plane[0],plane[1]
		if o1 in plane[1]:
			list1,list2=plane[1],plane[0]
		# print(list1,list2)
		# plane1 对角线最长计算
		C8_2=itertools.combinations(list1,2)
		maxTemp=0
		for temp in C8_2:
			tempList=list(temp)
			dis1=dis_2Point(temp[0],temp[1],arrLoc)
			if dis1>maxTemp:
				maxTemp=dis1
				maxn=tempList
		# plane1 点1 对角点 3 定位，点5 点7临时复制
		#print(maxn)
		if o1 in maxn:
			o3=list(set(maxn)-set([o1]))[0]
			i3=locDictMin[o3]
			temp1=list(set(list1)-set([o1,i1,o3,i3]))
			C4_2=itertools.combinations(temp1,2)
			maxTemp=0
			maxn=0
			for temp in C4_2:
				tempList=list(temp)
				dis1=dis_2Point(tempList[0],tempList[1],arrLoc)
				if dis1>maxTemp:
					maxTemp=dis1
					maxn=tempList
			o5,o7=maxn[0],maxn[1]
			i5,i7=locDictMin[o5],locDictMin[o7]
		else:
			# print(o1)
			o5,o7=maxn[0],maxn[1]
			i5,i7=locDictMin[o5],locDictMin[o7]
			#print([o5,o7,i5,i7,o1,i1])
			tempList=list(set(list1)-set([o5,o7,i5,i7,o1,i1]))
			#print(tempList)
			if dis_2Point(tempList[0],o1,arrLoc)>dis_2Point(tempList[1],o1,arrLoc):
				o3=tempList[0]
				i3=tempList[1]
			else:
				o3=tempList[1]
				i3=tempList[0]
		# print([o1,o3,o5,o7,i1,i3,i5,i7])
		# plane2 对角线最长计算
		C8_2=itertools.combinations(list2,2)
		maxTemp=0
		for temp in C8_2:
			tempList=list(temp)
			dis1=dis_2Point(tempList[0],tempList[1],arrLoc)
			if dis1>maxTemp:
				maxTemp=dis1
				maxn=tempList
		# plane2 点2 的对角点 4 ，点6、8临时赋值
		if o2 in maxn:
			o4=list(set(maxn)-set([o2]))[0]
			i4=locDictMin[o4]
			# ##print(list2)
			temp1=list(set(list2)-set([o2,i2,o4,i4]))
			C4_2=itertools.combinations(temp1,2)
			maxTemp=0
			for temp in C4_2:
				tempList=list(temp)
				dis1=dis_2Point(tempList[0],tempList[1],arrLoc)
				if dis1>maxTemp:
					maxTemp=dis1
					maxn=tempList
			o6,o8=maxn[0],maxn[1]
			i6,i8=locDictMin[o6],locDictMin[o8]
		else:
			o6,o8=maxn[0],maxn[1]
			i6,i8=locDictMin[o6],locDictMin[o8]
			tempList=list(set(list2)-set([o6,o8,i6,i8,o2,i2]))
			if dis_2Point(tempList[0],o2,arrLoc)>dis_2Point(tempList[1],o2,arrLoc):
				o4=tempList[0]
				i4=tempList[1]
			else:
				o4=tempList[1]
				i4=tempList[0]

		#print([o2,o4,o6,o8,i2,i4,i6,i8])
		# self.o1,self.o2,self.o3,self.o4,self.o5,self.o6,self.o7,self.o8=o1,o2,o3,o4,o5,o6,o7,o8
		# self.i1,self.i2,self.i3,self.i4,self.i5,self.i6,self.i7,self.i8=i1,i2,i3,i4,i5,i6,i7,i8
		return [o1,o2,o3,o4,o5,o6,o7,o8,i1,i2,i3,i4,i5,i6,i7,i8]
	@classmethod
	def rectangularBoxCal(self):
		'''
			矩形钢判定
			计算范围： 共鸣 ，矩形钢 ，16端点
		'''
		# o1,o2,i1,i2=self.o1,self.o2,self.i1,self.i2
		maxDis=self.maxDis
		arrLoc=self.arrLoc
		locDictMin,locDictMax=self.locDictMin,self.locDictMax
		arrX,arrY,arrZ=self.arrX,self.arrY,self.arrZ
		maxlength=self.maxlength
		# 共面容差
		tolerance0=0.01
		tGain=tolerance0
		# print(tolerance0,tGain)
		ncal=0
		nEnd=5
		if maxlength>maxDis:
			maxlength=maxDis*0.9
		# print(maxlength)
		while True:
			self.maxlength=maxlength
			plane=self.point8plane(tolerance0)
			ncal+=1
			if r'{False} {plane too more}' in plane:
				tolerance0=tolerance0*0.9
				maxlength=maxlength*0.9
			elif r'{False} {plane too few}' in plane:
				tolerance0=tolerance0*1.1
				maxlength=maxlength*1.1
			else:
				break
			if ncal>nEnd:
				return plane
		# print(plane)
		list1,list2=plane[0],plane[1]
		listAll=self.plan8PointLoc(plane)
		o1,o2,o3,o4,o5,o6,o7,o8,i1,i2,i3,i4,i5,i6,i7,i8=listAll
		#print(listAll)
		# print([o1,i1,o3,i3,o5,i5,o7,i7])
		# print([o2,i2,o4,i4,o6,i6,o8,i8])
		p1=[o1,o3,o5,o7]
		p2=[o2,o4,o8,o6]
		# print(p2)
		A4_4=itertools.permutations(p2,4)
		for n in A4_4:
			# print(n)
			log=[]
			v1=diff_2Point(n[0],p1[0],arrLoc)
			v2=diff_2Point(n[1],p1[1],arrLoc)
			v3=diff_2Point(n[2],p1[2],arrLoc)
			v4=diff_2Point(n[3],p1[3],arrLoc)
			C4_2=itertools.combinations([v1,v2,v3,v4],2)
			for n1 in C4_2:
				# print(n1)
				log.append(v_paraller(n1[0],n1[1],0.1))
			# print(p2)
			# print(log)
			if sum(log)==len(log):
				p2=list(n)
		# print(p2)
		# 顺序调整为 1-4 , 3-2 , 5-8 , 7-6
		# print(dis_2Point(o1,o5,arrLoc),dis_2Point(o3,o7,arrLoc))
		# print(dis_2Point(o2,o8,arrLoc),dis_2Point(o4,o6,arrLoc))
		o4,o2,o8,o6=p2[0],p2[1],p2[2],p2[3]
		i2,i4,i6,i8=locDictMin[o2],locDictMin[o4],locDictMin[o6],locDictMin[o8]
		
		# 是否为矩形钢判断
		# 面面垂直
		d1=dis_pointToFace(o3,o1,o4,o8,arrLoc)
		d2=dis_pointToFace(o7,o1,o4,o8,arrLoc)
		d11=dis_pointToFace(o1,o2,o3,o7,arrLoc)
		d12=dis_pointToFace(o5,o2,o3,o7,arrLoc)

		d3=dis_pointToFace(o3,o1,o4,o6,arrLoc)
		d4=dis_pointToFace(o5,o1,o4,o6,arrLoc)
		d13=dis_pointToFace(o1,o3,o5,o8,arrLoc)
		d14=dis_pointToFace(o7,o3,o5,o8,arrLoc)
		# print([d1,d2,d11,d12,d3,d4,d13,d14])
		if (numpy.std([d1,d2,d11,d12])<0.1 and numpy.std([d3,d4,d13,d14])<0.1)==False:
			return '{False} {not isCuboid}'
		# 宽度获取
		# 定义Y向为1458 法向量
		vPlane1458=v_face3Point(o4,o1,o8,arrLoc)
		#print(o4,o1,o8,vPlane1458)
		vyStr='%0.2f %0.2f %0.2f'%(vPlane1458[0],vPlane1458[1],vPlane1458[2])
		widthY=dis_pointToFace(o3,o1,o4,o8,arrLoc)
		#print(fun_face3Point(o1,o4,o8,arrLoc))
		widthZ=dis_pointToFace(o1,o5,o3,o2,arrLoc)
		#print(fun_face3Point(o5,o3,o2,arrLoc))
		thickness=dis_pointToFace(o3,o1,o4,o8,arrLoc)-dis_pointToFace(i3,o1,o4,o8,arrLoc)
		length=(dis_2Point(o1,o4,arrLoc)+dis_2Point(o3,o2,arrLoc)+dis_2Point(o5,o8,arrLoc)+dis_2Point(o7,o6,arrLoc))/4
		xList,yList,zList=arrX.tolist(),arrY.tolist(),arrZ.tolist()
		center1=[(xList[o1]+xList[o3])/2,(yList[o1]+yList[o3])/2,(zList[o1]+zList[o3])/2]
		center2=[(xList[o2]+xList[o4])/2,(yList[o2]+yList[o4])/2,(zList[o2]+zList[o4])/2]
		center1Str='%0.2f %0.2f %0.2f'%(center1[0],center1[1],center1[2])
		center2Str='%0.2f %0.2f %0.2f'%(center2[0],center2[1],center2[2])
		outputStr='{%0.2f} {%0.2f} {%0.2f} {%0.2f} {%s} {%s} {%s}'%(thickness,widthY,widthZ,length,center1Str,center2Str,vyStr)
		return '{True}'+' '+outputStr
	@classmethod
	def lengthJudgeMin(self,lengthLimit=30):
		'''
			各个端点距离 均小于 lengthLimit
			
		'''
		maxDis=self.maxDis
		if maxDis<lengthLimit:
			return r'{True} {less than lengthLimit}'
		return r'{False} {more than lengthLimit}'


def isRectangularBox(inputData):
	try:
		a=pointJudge(inputData)
		res=a.rectangularBoxCal()
	except:
		return r'{False} {error}'
	return res



#——————————————————————————
#——————————————————————————
try:
	calType=str(sys.argv[1])
	inputData=str(sys.argv[2])
	evalStr=calType+'(inputData)'
	print(eval(evalStr))
except:
	pass

#——————————————————————————

# test='553.69161228425 328.62332853948 351.4660410141 532.56069919722 296.58050943669 319.42322191131 532.56069919722 579.42322191131 36.580509436693 553.69161228425 611.4660410141 68.623328539483 489.66375747186 306.82385826927 329.66657074389 534.9791468237 291.88204633276 314.72475880738 534.9791468237 574.72475880738 31.882046332764 489.66375747186 589.66657074389 46.82385826927 560.33624252814 330.33342925611 353.17614173073 560.33624252814 613.17614173073 70.333429256111 515.0208531763 345.27524119262 368.11795366724 515.0208531763 628.11795366724 85.275241192617 496.30838771575 308.5339589859 331.37667146052 496.30838771575 591.37667146052 48.533958985898 517.43930080278 340.57677808869 363.41949056331 517.43930080278 623.41949056331 80.576778088687'
# print(isRectangularBox(test))

# test='465 5.0000000000001 -526.99569690486 465 55 -496.95266595348 465 5.0000000000001 -333.00430309514 465 55 -363.04733404652 505 55 -363.04733404652 505 55 -496.95266595348 505 5 -526.99569690486 505 5.0000000000001 -333.00430309514 510 60 -493.94836285835 510 60 -366.05163714165 510 -5.7731597280508e-015 -530 510 -5.7731597280508e-015 -330 460 60 -366.05163714165 460 60 -493.94836285835 460 7.1510364496672e-014 -530 460 7.8560682123105e-014 -330'
# print(isRectangularBox(test))

# test='517.43930080278 623.41949056331 80.576778088687 517.43930080278 340.57677808869 363.41949056331 496.30838771575 591.37667146052 48.533958985898 496.30838771575 308.5339589859 331.37667146052 515.0208531763 628.11795366724 85.275241192617 515.0208531763 345.27524119262 368.11795366724 560.33624252814 613.17614173073 70.333429256111 560.33624252814 330.33342925611 353.17614173073 489.66375747186 589.66657074389 46.82385826927 534.9791468237 574.72475880738 31.882046332764 534.9791468237 291.88204633276 314.72475880738 489.66375747186 306.82385826927 329.66657074389 553.69161228425 611.4660410141 68.623328539483 532.56069919722 579.42322191131 36.580509436693 532.56069919722 296.58050943669 319.42322191131 553.69161228425 328.62332853948 351.4660410141'
# print(isRectangularBox(test))

# test='585 -115.01181878422 333.9252603332 585 139.40641085933 30.721421134041 585 -49.741454317602 333.9252603332 585 177.70863301528 62.860801618368 580 -43.21441787094 333.9252603332 580 181.53885523088 66.074739666801 580 135.57618864374 27.507483085609 580 -121.53885523088 333.9252603332 630 -43.214417870941 333.9252603332 630 -121.53885523088 333.9252603332 630 135.57618864374 27.507483085608 630 181.53885523088 66.074739666801 625 -115.01181878422 333.9252603332 625 -49.741454317602 333.9252603332 625 177.70863301528 62.860801618368 625 139.40641085933 30.721421134041'
# print(isRectangularBox(test))

# # 60*50
# test='-424.67123660947 427.9931367283 270.57142775184 -561.96322780707 427.99313672829 74.498144181329 -447.82941994424 466.29535888424 293.53141430116 -569.2949941489 466.29535888424 120.060596613 -451.93293792174 466.91164305141 299.95210192113 -574.11838062978 466.91164305141 125.45320546474 -424.14311792001 420.94897646427 272.40011806195 -565.32026101959 420.94897646427 70.778262546735 -434.05594148157 499.05102353573 258.70521227075 -406.26612147984 453.08835694859 231.15322841156 -524.41816255258 453.08835694859 62.414626461008 -533.21628216277 499.05102353573 117.08956937901 -410.36963945733 453.70464111576 237.57391603153 -433.52782279211 492.00686327171 260.53390258085 -536.57331537529 492.00686327171 113.36968774442 -529.24154903346 453.70464111576 67.807235312748'
# print(isRectangularBox(test))

# # 60*50
# test='5 435 2623.0043030951 5 435 135.02151547569 5 485 2653.0473340465 5 485 104.97848452431 2.8105644040431e-014 490 2656.0516371417 2.8105644040432e-014 490 101.97418142917 -2.6645352591004e-015 430 2620 -1.6653345369377e-016 430 138.02581857083 50 490 2656.0516371417 50 430 2620 50 430 138.02581857083 50 490 101.97418142917 45 435 2623.0043030951 45 485 2653.0473340465 45 485 104.97848452431 45 435 135.02151547569'
# print(isRectangularBox(test))

# # 60*50
# test='5 5 -433.00430309514 5 5.0000000000001 -526.99569690486 5 55 -463.04733404652 5 55 -496.95266595348 2.8105644040432e-014 60 -466.05163714165 2.8105644040432e-014 60 -493.94836285835 0 0 -430 0 0 -530 50 60 -466.05163714165 50 0 -430 50 0 -530 50 60 -493.94836285835 45 5 -433.00430309514 45 55 -463.04733404652 45 55 -496.95266595348 45 5 -526.99569690486'
# print(isRectangularBox(test))

# # 60*50
# test='585 -763.55582633311 319.93078581951 585 -588.07444186346 15.988112135544 585 -705.82079941414 319.93078581951 585 -523.7956808948 4.6540322902594 630 -700.04729672225 319.93078581951 630 -517.36780479794 3.5206243057311 580 -700.04729672225 319.93078581951 580 -517.36780479794 3.5206243057311 580 -594.50231796032 17.121520120072 630 -594.50231796032 17.121520120072 630 -769.329329025 319.93078581951 580 -769.329329025 319.93078581951 625 -763.5558263331 319.93078581951 625 -705.82079941414 319.93078581951 625 -523.7956808948 4.6540322902594 625 -588.07444186346 15.988112135543'
# print(isRectangularBox(test))

