#!/bin/bash

executable_path="./install/bin/"
base_names=("01-main" "02-switch" "03-equity" "11-join" "12-join-main" 
"21-create-many" "22-create-many-recursive" "23-create-many-once" 
"31-switch-many" "32-switch-many-join" "33-switch-many-cascade" 
"51-fibonacci" 
"61-mutex" "62-mutex" "63-mutex-equity" "64-mutex-join" 
"71-preemption" 
"81-deadlock")
valgrind=""

# Check if --valgrind option is provided
if [[ "$1" == "--valgrind" ]]; then
    valgrind="valgrind --leak-check=full --show-reachable=yes --track-origins=yes"
fi

# Function to run a test and its pthread version with given parameters.
run_test_pair() {
    local base_name=$1
    local parameters=$2

    echo "!!!!!!!!!!!!!!"
    if [[ -z $valgrind ]]; then
        # Run the binary without pthread and time it.
        echo "Running $executable_path$base_name..."
        time ( "$executable_path$base_name" $parameters )
        echo "$base_name completed."
        echo ""

        # Run the corresponding binary with pthread and time it.
        echo "Running $executable_path${base_name}-pthread..."
        time ( "$executable_path${base_name}-pthread" $parameters )
        echo "${base_name}-pthread completed."
    else
        # Run the binary without pthread with valgrind.
        echo "Running $executable_path$base_name with Valgrind..."
        eval "$valgrind" "$executable_path$base_name" $parameters
        echo "$base_name completed."
    fi
    echo "!!!!!!!!!!!!!!"
}

# Variable pour stocker le dernier test exécuté et ses paramètres
last_test=""
last_params=""

# Iterate over the base names.
for base in "${base_names[@]}"; do
    while true; do
        echo "----------------------------------------"
        echo "Do you want to run the test for $base? [Y/n/r] ('r' to rerun the last test)"

        # Capture user choice
        read -r run_test
        run_test=${run_test:-yes} # Default to 'yes' if no input is given.

        # Check for rerun option
        if [[ $run_test =~ ^[Rr]$ ]] && [[ -n $last_test ]]; then
            echo "Enter new parameters for $last_test (press Enter if same as before):"
            read -r new_params
            new_params=${new_params:-$last_params} # Use last params if no input

            # Rerun the last test with new or old parameters
            run_test_pair "$last_test" "$new_params"

            # Update last params in case they were changed
            last_params=$new_params
            continue
        elif [[ $run_test =~ ^[Yy]es$ || $run_test == "" || $run_test =~ ^[Yy]$ ]]; then
            echo "Enter parameters for $base (press Enter if none):"
            read -r params

            # Mémoriser le dernier test et ses paramètres
            last_test=$base
            last_params=$params

            # Run test with the appropriate settings.
            run_test_pair "$base" "$params"
            break
        else
            echo "Skipping $base..."
            break
        fi
    done
done

echo "All tests completed."

echo "All tests completed."
