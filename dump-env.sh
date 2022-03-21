#!/usr/bin/env bash

POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    -t|--template)
      TEMPLATE="$2"
      shift # past argument
      shift # past value
      ;;
    -p|--prefix)
      PREFIX="$2"
      shift # past argument
      shift # past value
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

# If we do not use a template just dump the env replacing the prefixes
if [[ ! "$TEMPLATE" ]]; then
    while IFS='=' read -r name value; do
        # Skip lines that start with '#'
        [[ ${name} =~ ^#.* ]] && continue

        # Skip empty name
        [[ -z ${name} ]] && continue
        no_prefix="${name#"$PREFIX"}"
        echo "${no_prefix}=${!name}"
    done < <(env)
fi

# Print only the key-value pairs that appear in the template
while IFS='=' read -r name value; do
    # Skip lines that start with '#'
    [[ ${name} =~ ^#.* ]] && continue

    # Skip empty name
    [[ -z ${name} ]] && continue

    prefixed_name="${PREFIX}${name}"
    # If the variable is set (with prefix) use that the value
    if [[ -v ${prefixed_name} ]]; then
        echo "$name=${!prefixed_name}"
    # If the variable is set (without prefix) use that the value
    elif [[ -v ${name} ]]; then
        echo "$name=${!name}"
    # If the variable is NOT set use the template value
    else
        echo "$name=$value"
    fi
done < <(cat "$TEMPLATE" || true)