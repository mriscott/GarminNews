watch=fr735xt
sdkroot=/opt/ciq

News.prg : source/*.mc
	monkeyc  -y ../developer_key.der -o ./News.prg -f ./monkey.jungle 

run: News.prg
	connectiq &
	monkeydo ./News.prg ${watch}
	
package: 
	monkeyc -e -a ${sdkroot}/bin/api.db -i ${sdkroot}/bin/api.debug.xml -o ./News.iq -y ../developer_key.der -w -u ${sdkroot}/bin/devices.xml -p ${sdkroot}/bin/projectInfo.xml -f ./monkey.jungle
