#!/bin/zsh

echo "Press [CTRL] + c anytime to exit."

DEFAULT_CURRENCY_CODE="USD";
DEFAULT_MODE="1";

function validate_currency_code {
	code=${1:u}
	VALID_CODES=("AED", "ARS", "AUD", "BGN", "BRL", "BSD", "CAD", "CHF", "CLP", "CNY", "COP", "CZK", "DKK", "DOP", "EGP", "EUR", "FJD", "GBP", "GTQ", "HKD", "HRK", "HUF", "IDR", "ILS", "INR", "ISK", "JPY", "KRW", "KZT", "MXN", "MYR", "NOK", "NZD", "PAB", "PEN", "PHP", "PKR", "PLN", "PYG", "RON", "RUB", "SAR", "SEK", "SGD", "THB", "TRY", "TWD", "UAH", "USD", "UYU", "ZA")
	if [[ ${#code} = 3 ]] && [[ "${VALID_CODES[@]}" =~ "${code}" ]]
		then
			return 0
		else
			return 1
	fi
}

function read_user_mode {
	echo "Select Mode:"
	echo "[0] Get Rates"
	echo "[1] Convert"
	read MODE; : ${MODE:=DEFAULT_MODE}
	set_mode
}

function set_mode {
	case $MODE in
		"0")
			enter_currency_param
			;;
		"1")
			enter_conversion_param
			;;
		*)
			echo "Invalid option.  Enter a value between 0 and 1."
			read_user_mode
			;;
	esac
}

function enter_currency_param {
	echo -n "Enter Currency Code (default: 'USD'): "
	read CURRENCY_CODE; : ${CURRENCY_CODE:=$DEFAULT_CURRENCY_CODE}
	if ! `validate_currency_code $CURRENCY_CODE`
		then
			echo "Please enter a valid currency code (https://www.exchangerate-api.com/docs/supported-currencies)"
			enter_currency_param
	fi
	get_rates $CURRENCY_CODE
}

function enter_conversion_param {
	echo -n "Convert From: "
	read CURRENCY_CODE_FROM;
	if ! `validate_currency_code $CURRENCY_CODE_FROM`
		then
			echo "Please enter a valid currency code (https://www.exchangerate-api.com/docs/supported-currencies)"
			enter_conversion_param
	fi
	echo -n "Convert To: "
	read CURRENCY_CODE_TO;
	if ! `validate_currency_code $CURRENCY_CODE_TO`
		then
			echo "Please enter a valid currency code (https://www.exchangerate-api.com/docs/supported-currencies)"
			enter_conversion_param
	fi
	echo -n "Enter quantity: "
	read CONVERSION_QUANTITY;
	convert_currency $CURRENCY_CODE_FROM $CURRENCY_CODE_TO $CONVERSION_QUANTITY
}

function get_rates {
	currency_code_from=${1:u}
	resp="`wget -qO- https://api.exchangerate-api.com/v4/latest/$currency_code_from`"
	echo $currency_code_from
	echo "==============="
	rates=$(echo $resp | ggrep -Po '"rates":{\K([^}]+)' | tr ',' '\n')
	printf "%s\n" $rates
}

function convert_currency {
	currency_code_from=${1:u}
	currency_code_to=${2:u}
	quantity=$3;
	resp="`wget -qO- https://api.exchangerate-api.com/v4/latest/${currency_code_from}`"
	exchangeRate=$(echo $resp | ggrep -Po "\"${currency_code_to}\":\K([^,]+)")
	echo "============================"
	echo "Exchange Rate: $exchangeRate"
	converted_quantity=$((quantity * exchangeRate))
	echo "$quantity $currency_code_from -> $currency_code_to: $converted_quantity"
}

read_user_mode