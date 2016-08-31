#the following line combines the last line to prevent this file from being sourced twice
if [ "x$dsl_sh" = "x" ]; then dsl_sh="sourced"
. /lib/cfgmgr/cfgmgr.sh

#----------------------------------------------------------

dsl_wan_conf="/etc/lantiq_dsl_wan.conf"
dsl_wan2_conf="/etc/lantiq_dsl_wan2.conf"
prepare_dsl_wan_conf()
{
	local type=$($CONFIG get dsl_wan_type)
	local wan_mode=vdsl_ptm
	[ "$type" = "adsl" ] && wan_mode=adsl_atm

	echo "cfg_wan_mode=\"$wan_mode\"" > $dsl_wan_conf
	echo "cfg_wan_mode=\"$wan_mode\"" > $dsl_wan2_conf
}

#----------------------------------------------------------

print_interop_bits_adjustment() # $1: country, $2: isp, $3: vdsl/adsl
{
	if [ "$3" = "vdsl" ]; then
		case "$1/$2" in
		UK/*)
			echo -e "\tdms 1562 0 1 8"						# All UK ISPs need these commands
			echo -e "\tdms 549 0 2 240B 0000"
			echo -e "\tdmms 1C44 0 1 BFFF 4000"
			;;
		Sweden/Telia)
			echo -e "\tdms 0x1562 0x0 0x1 0x6"             # TELIASONERA Fixes
			echo -e "\tdms 0xE843 0x2 0x1 0x1"             # TELIASONERA Fixes
			;;
		esac
	else
		case "$1/$2" in
		France/Orange)
			echo -e "\tdmms 0x6743 0x1C 0x1 0x200 0x200"   # Improve downstream performance & stability under REIN/Impulse noise
			echo -e "\tdmms 0x6743 0x1C 0x1 0x100 0x0"     # Improve downstream performance & stability for fixed RFI disturber
			echo -e "\tdmms 0x6743 0x1 0x1 0x80 0x80"      # FT bit
			echo -e "\tdmms 0x6743 0x14 0x1 0x40 0x40"     # Favour DS SNRM over DS INP
			echo -e "\tdmms 0x6743 0x17 0x1 0x20 0x20"     # Eanble the REIN adaptation in training phase.
			echo -e "\tdmms 0x6743 0x1A 0x1 0x10 0x10"     # DS performance at mid-long loops with BRCM DSLAM in ADSL2+ mode.
			echo -e "\tdmms 0x549 0x0 0x1 0x49 0x49"       # Reboot Criteria (1) for FT (LOS, LOM & LCD)
			echo -e "\tdmms 0x549 0x1 0x1 0x3 0x3"         # Reboot Criteria (2) for FT (SES30 & ES90)
			echo -e "\tdmms 0x6743 0x1D 0x1 0x8000 0x8000" # Avoid declaring LOM from CPE side, in particular when no NearEnd CRCs are observed by removing the ceiling on the 15 bit loaded tones. This is required to avoid second retrain in FT evoultive test cases as well unnecessary LOM reboot
			;;
		Spain/Telefonica*)
			echo -e "\tdmms 0x6743 0x17 0x1 0x8000 0x8000" # DS LATN reporting gap in Anx-A/M as compared to AR7
			echo -e "\tdmms 0x6743 0x14 0x1 0x40 0x40"     # Favour DS SNRM over DS INP
			echo -e "\tdmms 0x6743 0x14 0x1 0x2000 0x2000" # Inproved US performance against GSPN DSLAMs
			echo -e "\tdmms 0x6743 0x1A 0x1 0x20 0x20"     # Telefonica bit 1
			echo -e "\tdmms 0x6743 0x17 0x1 0x8000 0x8000" # Telefonica bit 3
			echo -e "\tdmms 0x6743 0x1C 0x1 0x4000 0x4000" # Telefonica bit 4
			echo -e "\tdmms 0x6743 0x1A 0x1 0x10 0x10"     # DS performance at mid-long loops with BRCM DSLAM in ADSL2+ mode.
			;;
		Greece/OTE)
			echo -e "\tdmms 0x6743 0x14 0x1 0x2000 0x2000" # Inproved US performance against GSPN DSLAMs
			;;
		Norway/Comlabs)
			echo -e "\tdmms 0x6743 0x0 0x1 0x100 0x100"   # Comlabs (Norway) bit
			;;
		UK/*)
			echo -e "\tdms 549 0 2 204B 0000"				# All UK ISPs need this command
			;;
		esac
	fi
}

print_scr_WaitForConfiguration()
{
	cat <<EOF
[WaitForConfiguration]={
}

EOF
}

print_scr_WaitForLinkActivate() # $1: country, $2: isp, $3: vdsl/adsl
{
	cat <<EOF
[WaitForLinkActivate]={
EOF

	print_interop_bits_adjustment "$1" "$2" "$3"

	cat <<EOF
}

EOF
}

print_scr_WaitForRestart()
{
	cat <<EOF
[WaitForRestart]={
}

EOF
}

print_scr_Common()
{
	cat <<EOF
[Common]={
}

EOF
}

print_dsl_scr() # $1: country, $2: isp, $3: vdsl/adsl
{
	print_scr_WaitForConfiguration "$1" "$2" "$3"
	print_scr_WaitForLinkActivate "$1" "$2" "$3"
	print_scr_WaitForRestart "$1" "$2" "$3"
	print_scr_Common "$1" "$2" "$3"
}

vdsl_scr_file=/opt/lantiq/bin/vdsl.scr
adsl_scr_file=/opt/lantiq/bin/adsl.scr
prepare_dsl_scr()
{
	local country=$($CONFIG get dsl_wan_country)
	local isp=$($CONFIG get dsl_wan_isp)

	print_dsl_scr "$country" "$isp" "vdsl" > $vdsl_scr_file
	print_dsl_scr "$country" "$isp" "adsl" > $adsl_scr_file
}

prepare_dsl_scr_and_restart_dsl_link()
{
	prepare_dsl_scr
	/opt/lantiq/bin/dsl_cpe_pipe.sh acs 2
	sleep 1
}

derive_dsl_iop_type()
{
	local type=$($CONFIG get dsl_wan_type)
	local country=$($CONFIG get dsl_wan_country)
	local isp=$($CONFIG get dsl_wan_isp)

	case "$type/$country/$isp" in
	vdsl/UK/*|vdsl/Sweden/Telia|adsl/France/Orange|adsl/Greece/OTE|adsl/Norway/Comlabs|adsl/UK/*)
		echo "$type/$country/$isp"
		;;
	adsl/Spain/Telefonica*)
		echo "$type/$country/Telefonica"
		;;
	*) echo "$type/normal" ;;
	esac
}

set_dsl_iop_type()
{
	local dsl_iop_type="$(derive_dsl_iop_type)"
	[ "$($CONFIG get i_dsl_iop_type)" = "$dsl_iop_type" ] && return 1
	$CONFIG set i_dsl_iop_type="$dsl_iop_type" && return 0
}

prepare_dsl_scr_and_restart_dsl_link_if_needed()
{
	set_dsl_iop_type && prepare_dsl_scr_and_restart_dsl_link
}

dsl_set_induced_configs()
{
	$CONFIG set i_dsl_iop_type="$(derive_dsl_iop_type)"
}

fi #-------------------- this must be the last line -----------------------------
