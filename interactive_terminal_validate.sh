#!/bin/zsh

echo "Press [CTRL] + c anytime to exit."

DEFAULT_CURRENCY_CODE="USD";

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

function enter_currency_param {
	echo -n "Enter Currency Code (default: 'USD'): "
	read CURRENCY_CODE; : ${CURRENCY_CODE:=$DEFAULT_CURRENCY_CODE}
	if ! `validate_currency_code $CURRENCY_CODE`
		then
			echo "Please enter a valid currency code (https://www.exchangerate-api.com/docs/supported-currencies)"
			enter_currency_param
		else
			get_rates $CURRENCY_CODE
	fi
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