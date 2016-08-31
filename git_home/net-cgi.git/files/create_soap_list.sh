#!/bin/bash

. ${0%/*}/net-cgi.config || . $(pwd)/net-cgi.config

# write output to file ./support_soap_list by default, and you can pass
# one argument in command line to specify another file to save all output APIs.
# e.g.:
#	create_soap_list.sh		# write to file "./support_soap_list"
#	create_soap_list.sh /tmp/soap	# write to file "/tmp/soap"	
exec >${1:-support_soap_list}

Version()
{
	printf "Version: V2.00\n"
}
Version

DeviceConfig()
{
	printf "DeviceConfig:%s\n" \
		"ConfigurationStarted" \
		"ConfigurationFinished" \
		"SetEnable" \
		"Reboot" \
		"SetGUILanguage" \
		"SetConfiguration" \
		"Loaddefault" \
		"SetTimeZone" \
		"SetFirmware" \
		"SetBlockSiteEnable" \
		"SetBlockSiteName" \
		"AddStaticRoute" \
		"DelStaticRoute" \
		"GetStaticRouteTbl" \
		"EnableTrafficMeter" \
		"GetTrafficMeterEnabled" \
		"SetTrafficMeterOptions" \
		"GetTrafficMeterOptions" \
		"GetInfo" \
		"GetTimeZoneInfo" \
		"GetConfigInfo" \
		"GetBlockSiteInfo" \
		"GetTrafficMeterStatistics" \
		"CheckNewFirmware" \
		"UpdateNewFirmware" \
		"ResetToFactoryDefault" \
		"IsDLNASupported" \
		"IsDLNAEnabled" \
		"SetDLNAStatus" \
		"GetQoSEnableStatus" \
		"SetQoSEnableStatus" \
		"GetBandwidthControlEnableStatus" \
		"SetBandwidthControlEnableStatus" \
		"UpdateAdminPassword" \
		"GetQoSRules" \
		"UpdateQoSPriority" \
		"AddQoSRuleByMAC" \
		"AddQoSRuleByEthernetPort" \
		"AddQoSRule" \
		"DeleteQoSRule"

	if [ $HAVE_SECURITY = 1 ]; then
		printf "DeviceConfig:%s\n" \
			"SetBlockDeviceEnable" \
			"GetBlockDeviceEnableStatus" \
			"EnableBlockDeviceForAll" \
			"GetBlockDeviceStateByDefault" \
			"SetBlockDeviceStateByDefault" \
			"SetBlockDeviceByMAC" \
			"GetDeviceListByMode" \
			"GetDeviceListAll" \
			"DeleteBlockDeviceByMAC"
	fi
}
DeviceConfig

DeviceInfo()
{
	printf "DeviceInfo:%s\n" \
		"GetInfo" \
		"GetSysUpTime" \
		"GetSystemLogs" \
		"GetSystemInfo" \
		"GetAttachDevice"

	if [ $HAVE_QOS = 1 ]; then
		printf "DeviceInfo:%s\n" \
			"GetSupportFeatureList" \
			"GetAttachDevice2" \
			"SetDeviceNameIconByMac"
	fi
}
DeviceInfo

WANIPConnection()
{
	if [ $HAVE_WAN = 1 ]; then
		printf "WANIPConnection:%s\n" \
			"SetConnectionType" \
			"SetIPInterfaceInfo" \
			"SetMACAddress" \
			"SetSmartWizardDetection" \
			"SetMaxMTUSize" \
			"GetConnectionTypeInfo" \
			"GetInfo" \
			"GetPortMappingInfo" \
			"GetInternetPortInfo" \
			"AddPortMapping" \
			"DeletePortMapping" \
			"GetRemoteManagementEnableStatus" \
			"SetRemoteManagementEnable"
	fi
}
WANIPConnection

WANEthernetLinkConfig()
{
	if [ $HAVE_WAN = 1 ]; then
		printf "WANEthernetLinkConfig:%s\n" \
			"GetEthernetLinkStatus" \
			"SetWANRelease" \
			"SetWANRenew"
	fi
}
WANEthernetLinkConfig

WAN3GInterfaceConfig()
{
	if [ $HAVE_BROADBAND = 1 ]; then
		printf "WAN3GInterfaceConfig:%s\n" \
			"SetInterfaceOrder" \
			"SetConnectionType" \
			"SetWirelessBroadbandConfig" \
			"GetInfo" \
			"GetWirelessBroadbandInfo" \
			"GetSIMStatus" \
			"GetModemStatus" \
			"GetCountryISPList"
	fi
}
WAN3GInterfaceConfig

LANConfigSecurity()
{
	printf "LANConfigSecurity:%s\n" \
		"SetConfigLANSubnet" \
		"SetConfigLANIP" \
		"SetConfigDHCPEnabled" \
		"SetConfigLAN" \
		"SetConfigPassword" \
		"GetInfo"
}
LANConfigSecurity

WLANConfiguration()
{
	if [ $HAVE_WIFI = 1 ]; then
		printf "WLANConfiguration:%s\n" \
			"SetEnable" \
			"SetConfigPassword" \
			"SetChannel" \
			"SetSSIDBroadcast" \
			"SetSSID" \
			"SetWLANNoSecurity" \
			"SetWLANWEPByKeys" \
			"SetWLANWEPByPassphrase" \
			"SetWLANWPAPSKByPassphrase" \
			"SetWPSMode" \
			"PressWPSPBC" \
			"SetGuestAccessNetwork" \
			"SetGuestAccessEnabled2" \
			"SetGuestAccessEnabled" \
			"GetInfo" \
			"Is5GSupported" \
			"GetSSIDBroadcast" \
			"GetWEPSecurityKeys" \
			"GetWPASecurityKeys" \
			"GetSSID" \
			"GetChannelInfo" \
			"GetRegion" \
			"GetWirelessMode" \
			"GetWPSMode" \
			"GetWPSPINInfo" \
			"GetGuestAccessEnabled" \
			"GetGuestAccessNetworkInfo" \
			"GetAvailableChannel" \
			"GetSupportMode" \
			"Set5GEnable" \
			"Set5GChannel" \
			"Set5GSSID" \
			"Set5GWLANNoSecurity" \
			"Set5GWLANWEPByKeys" \
			"Set5GWLANWEPByPassphrase" \
			"Set5GWLANWPAPSKByPassphrase" \
			"Set5GGuestAccessEnabled2" \
			"Set5GGuestAccessEnabled" \
			"Set5GGuestAccessNetwork" \
			"Get5GInfo" \
			"Get5GSSID" \
			"Get5GChannelInfo" \
			"Get5GWirelessMode" \
			"Get5GWPASecurityKeys" \
			"Get5GWEPSecurityKeys" \
			"Get5GGuestAccessEnabled" \
			"Get5GGuestAccessNetworkInfo"
	fi
}
WLANConfiguration

Time()
{
	printf "Time:%s\n" \
		"GetInfo"
}
Time

ParentalControl()
{
	printf "ParentalControl:%s\n" \
		"Authenticate" \
		"GetDNSMasqDeviceID" \
		"SetDNSMasqDeviceID" \
		"EnableParentalControl" \
		"GetAllMACAddresses" \
		"DeleteMACAddress" \
		"GetEnableStatus"
}
ParentalControl

AdvancedQoS()
{
	if [ $HAVE_QOS = 1 ]; then
		printf "AdvancedQoS:%s\n" \
			"SetQoSEnableStatus" \
			"SetBandwidthControlOptions" \
			"SetDevicePriorityByMAC" \
			"GetQoSEnableStatus" \
			"GetBandwidthControlOptions" \
			"SetOOKLASpeedTestStart" \
			"GetOOKLASpeedTestResult" \
			"GetDeviceProirityByMAC" \
			"GetCurrentBandwidthByMAC" \
			"GetHistoricalTrafficByMAC" \
			"GetCurrentAppBandwidth" \
			"GetHistoricalAppTraffic" \
			"GetCurrentAppBandwidthByMAC" \
			"GetHistoricalAppTrafficByMAC"
	fi
}
AdvancedQoS
