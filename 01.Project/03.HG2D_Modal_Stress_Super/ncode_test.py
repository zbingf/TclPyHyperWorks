

str_single_z1_x = '<StrainGauge AngleOffset="0" ID="Gauge_#id#_Z1" Location="#id#" LocationType="ElementCentroid" Orientation="1,0,0" ResultsFrom="OneSurface" ShellSurface="Bottom" Type="Single"/>'
str_single_z1_y = '<StrainGauge AngleOffset="0" ID="Gauge_#id#_Z1" Location="#id#" LocationType="ElementCentroid" Orientation="0,1,0" ResultsFrom="OneSurface" ShellSurface="Bottom" Type="Single"/>'
str_single_z1_z = '<StrainGauge AngleOffset="0" ID="Gauge_#id#_Z1" Location="#id#" LocationType="ElementCentroid" Orientation="0,0,1" ResultsFrom="OneSurface" ShellSurface="Bottom" Type="Single"/>'
str_single_z2_x = '<StrainGauge AngleOffset="0" ID="Gauge_#id#_Z2" Location="#id#" LocationType="ElementCentroid" Orientation="1,0,0" ResultsFrom="OneSurface" ShellSurface="Top" Type="Single"/>'
str_single_z2_y = '<StrainGauge AngleOffset="0" ID="Gauge_#id#_Z2" Location="#id#" LocationType="ElementCentroid" Orientation="0,1,0" ResultsFrom="OneSurface" ShellSurface="Top" Type="Single"/>'
str_single_z2_z = '<StrainGauge AngleOffset="0" ID="Gauge_#id#_Z2" Location="#id#" LocationType="ElementCentroid" Orientation="0,0,1" ResultsFrom="OneSurface" ShellSurface="Top" Type="Single"/>'

str_single_z1_svm = '<StrainGauge AngleOffset="0" ID="Gauge_#id#_Z1" Location="#id#" LocationType="ElementCentroid" Orientation="1,0,0" ResultsFrom="OneSurface" ShellSurface="Bottom" Type="Rectangular"/>'
str_single_z2_svm = '<StrainGauge AngleOffset="0" ID="Gauge_#id#_Z2" Location="#id#" LocationType="ElementCentroid" Orientation="1,0,0" ResultsFrom="OneSurface" ShellSurface="Top" Type="Rectangular"/>'


def write_asg(file_path, str_z1, str_z2, list1):
	f = open(file_path, 'w')
	f.write('<Gauges>\n')
	for n in list1:
		f.write(str_z1.replace('#id#', str(n))+'\n')
		f.write(str_z2.replace('#id#', str(n))+'\n')

	# print(','.join([str(n) for n in range(1,1000)]))
	f.write('</Gauges>\n')
	f.close()
	return None


str_vx = ",1,0,0\n"
str_vy = ",0,1,0\n"
str_vz = ",0,0,1\n"

list1 = [n for n in range(1,5400,20)]

def write_csv(file_path, str_v, list1):
	f = open(file_path, 'w')
	f.write('elem_id,vx,vy,vz\n')
	for n in list1:
		f.write(str(n)+str_v)

	f.close()
	return None

write_asg('gauge_5000_x.asg', str_single_z1_x, str_single_z2_x, list1)
write_csv('gauge_5000_x.csv', str_vx, list1)

# write_asg('gauge_1000_y.asg', str_single_z1_y, str_single_z2_y)
# write_csv('gauge_1000_y.csv', str_vy)

# write_asg('gauge_1000_z.asg', str_single_z1_z, str_single_z2_z)
# write_csv('gauge_1000_z.csv', str_vz)


# write_asg('gauge_1000_svm.asg', str_single_z1_svm, str_single_z2_svm, list1)
# write_csv('gauge_1000_z.csv', str_vz)

print(','.join([str(n) for n in list1]))