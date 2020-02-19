#!/bin/zsh

echo "Press [CTRL] + c anytime to exit."

DEFAULT_CURRENCY_CODE="USD";

function enter_currency_param {
	echo -n "Enter Currency Code (default: 'USD'): "
	read CURRENCY_CODE; : ${CURRENCY_CODE:=$DEFAULT_CURRENCY_CODE}
	get_rates $CURRENCY_CODE
}

function get_rates {
	currency_code_from=${1:u}
	resp="`wget -qO- https://api.exchangerate-api.com/v4/latest/$currency_code_from`"
	echo $currency_code_from
	echo "==============="
	rates=$(echo $resp | ggrep -Po '"rates":{\K([^}]+)' | tr ',' '\n')
	printf "%s\n" $rates
}

enter_currency_param