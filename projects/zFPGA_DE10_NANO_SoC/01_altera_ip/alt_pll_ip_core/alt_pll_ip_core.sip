set_global_assignment -entity "alt_pll_ip_core" -library "lib_alt_pll_ip_core" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "alt_pll_ip_core" -library "lib_alt_pll_ip_core" -name IP_TOOL_VERSION "14.0"
set_global_assignment -entity "alt_pll_ip_core" -library "lib_alt_pll_ip_core" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_alt_pll_ip_core" -name SPD_FILE [file join $::quartus(sip_path) "alt_pll_ip_core.spd"]
