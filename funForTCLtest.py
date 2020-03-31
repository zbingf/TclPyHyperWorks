import sys
import numpy
import itertools,math


def test(inputData,num):
	# num=int(num)
	outputData=inputData*num
	return outputData



calType=str(sys.argv[1])

verN=len(sys.argv)
verStr=''
for n in range(2,verN,1):
	verStr=verStr+str(sys.argv[n])+','

verStr=verStr[0:-1]


# inputData=str(sys.argv[2])
evalStr=calType+'({})'.format(verStr)
print(eval(evalStr))
