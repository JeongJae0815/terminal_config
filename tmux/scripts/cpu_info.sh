#!/usr/bin/env bash
# setting the locale, some users have issues with different locales, this forces the correct one
export LC_ALL=en_US.UTF-8
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/helpers.sh"
cpu_percentage_format="%3.1f%%"
# function for getting the refresh rate
get_tmux_option() {
  local option=$1
  local default_value=$2
  local option_value=$(tmux show-option -gqv "$option")
  if [ -z $option_value ]; then
    echo $default_value
  else
    echo $option_value
  fi
}

get_percent()
{
	case $(uname -s) in
		Linux)
#			percent=$(LC_NUMERIC=en_US.UTF-8 top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}')
			load=`cached_eval ps -aux | awk '{print $3}' | tail -n+2 | awk '{s+=$1} END {print s}'`
			cpus=$(cpus_number)
			echo "$load $cpus" | awk -v format="$cpu_percentage_format" '{printf format, $1/$2}'
			#echo $percent
		;;
		
		Darwin)
			percent=$(ps -A -o %cpu | awk '{s+=$1} END {print s "%"}')
			echo $percent
		;;

		CYGWIN*|MINGW32*|MSYS*|MINGW*)
			# TODO - windows compatability
		;;
	esac
}

main()
{
	# storing the refresh rate in the variable RATE, default is 5
	RATE=$(get_tmux_option "@dracula-refresh-rate" 5)
	cpu_percent=$(get_percent)
	echo "CPU $cpu_percent"
	sleep $RATE
}

# run main driver
main
